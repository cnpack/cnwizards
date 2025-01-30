{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is partly derived from GExperts 1.2                             }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnWizEditFiler;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：编辑器文件读取类单元
* 单元作者：CnPack 开发组
* 备    注：该单元由 GExperts 1.2 Src 的 GX_EditReader 移植而来
*           其原始内容受 GExperts License 的保护
*
*           EditFilerLoadFileFromStream 对 Stream 的编码要求：
*                        D567            D2005~2007               D2009 或以上
*           磁盘文件     Ansi            Utf8（可指定成 Ansi）    Utf16
*           IDE 内存     Ansi            Utf8（可指定成 Ansi）    Utf16
*
*           EditFilerSaveFileToStream 得到的 Stream 的编码行为：
*                        D567            D2005~2007               D2009 或以上
*           磁盘文件     Ansi            Utf8（可解码成 Ansi）    Utf16
*           IDE 内存     Ansi            Utf8（可解码成 Ansi）    Utf16
*
*           注意控制 Utf8 指定或解码成 Ansi 时，需将 CheckUtf8 参数为 True
*
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2025.01.29 V1.3
*               修改 EditFilerLoadFileFromStream 的行为，使其和 Save 版本保持一致的
*               Ansi、Ansi/Utf8、Utf16，但文件编码未能适应，Save 版本类似
*           2017.04.29 V1.2
*               修正 Unicode 环境下读文件时未转换为 Utf16 的问题
*           2003.06.17 V1.1
*               修改文件名，加入写功能（LiuXiao）
*           2003.03.02 V1.0
*               创建单元，移植而来（By 周劲羽）
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Math, ToolsAPI, CnWizConsts
  {$IFDEF BDS}, CnWideStrings {$ENDIF};

type
  TModuleMode = (mmModule, mmFile);

  TCnEditFiler = class(TObject)
  {* 只支持 Module 级别的编辑器文件，不支持 dfm 之类的}
  private
    FSourceInterfaceAllocated: Boolean;
    FModuleNotifier: IOTAModuleNotifier;
    FEditIntf: IOTASourceEditor;
    FEditRead: IOTAEditReader;
    FEditWrite: IOTAEditWriter;
    FModIntf: IOTAModule;
    FNotifierIndex: Integer;
    FBuf: Pointer;
    FBufSize: Integer;
    FFileName: string;
    FMode: TModuleMode;
    FStreamFile: TStream;
    procedure AllocateFileData;
    function GetLineCount: Integer;
    procedure SetBufSize(New: Integer);
    procedure InternalGotoLine(Line: Integer; Offset: Boolean);
    function GetFileSize: Integer;
  protected
    procedure SetFileName(const Value: string);
    procedure ReleaseModuleNotifier;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    procedure FreeFileData;
    procedure Reset;
    procedure GotoLine(L: Integer);
    procedure GotoOffsetLine(L: Integer);
    procedure ShowSource;
    procedure ShowForm;
{$IFDEF UNICODE}
    procedure SaveToStreamW(Stream: TStream);
    // 将文件内容存入流中，如果是 TMemoryStream，存成没 BOM 的 UTF16 格式，否则 Utf8 格式，尾部 #0
{$ENDIF}
    procedure SaveToStream(Stream: TStream; CheckUtf8: Boolean = False);
    // 读出均为无 BOM 的 Ansi 或 Utf8 格式，尾部 #0。
    // BDS 里，当文件在 IDE 里打开、且 CheckUtf8 是 True 并且是 MemoryStream 时，
    // Utf8 会转换成 Ansi，否则保持 Utf8。D5/6/7 中只支持 Ansi
    procedure SaveToStreamFromPos(Stream: TStream);
    procedure SaveToStreamToPos(Stream: TStream);

{$IFDEF UNICODE}
    procedure ReadFromStreamW(Stream: TStream);
    // 从 Stream 整个写到文件或缓冲中，覆盖原有内容。要求流中是 UTF16，无 BOM
    // 文件是磁盘形式时，能够将 UTF16 编码转换为文件对应编码
{$ENDIF}
    // LiuXiao 添加三个读入流函数。
    procedure ReadFromStream(Stream: TStream; CheckUtf8: Boolean = False);
    // 从 Stream 整个写到文件或缓冲中，覆盖原有内容，与 Stream 的 Position 和光标位置无关，
    // 要求流中是 Ansi 或 Utf8，无 BOM，不要求 Stream 尾 #0（准确来讲不能是 #0 否则会出现多余字符）
    // 写文件时 Stream 内容不进行转换。写缓冲时如果是 BDS 且 Stream 是 MemoryStream 时，
    // Stream 内容如果是 Ansi，则 CheckUtf8 得设为 True 以进行 Ansi 到 Utf8 的转换以适合编辑器缓冲。
    // 注意：文件是磁盘形式时，目前只能原封不动写入文件，无法转换编码

    // TODO: 以下两函数暂未做 UTF8 适配
    procedure ReadFromStreamInPos(Stream: TStream);
    procedure ReadFromStreamInsertToPos(Stream: TStream);

    function GetCurrentBufferPos: Integer;
    property BufSize: Integer read FBufSize write SetBufSize;
    property FileName: string read FFileName write SetFileName;
    property LineCount: Integer read GetLineCount;
    property Mode: TModuleMode read FMode;
    property FileSize: Integer read GetFileSize;
  end;

procedure EditFilerLoadFileFromStream(const FileName: string; Stream: TStream; CheckUtf8: Boolean = False);
{* 封装的用流写入 Filer 的文件内容，要求流中无 BOM，尾部无需 #0。
  内部写文件时不进行转换。写缓冲时如果是 BDS 2005 到 2007 里且 Stream 是 MemoryStream，
  则可由 CheckUtf8 设为 True 来进行 Ansi 到 Utf8 的转换以适合编辑器缓冲，D5/6/7 中不会转换。
  Unicode 环境下会忽略 CheckUtf8，Stream 中必须固定为 Utf16。也就是 Ansi、Ansi/Utf8、Utf16}

procedure EditFilerSaveFileToStream(const FileName: string; Stream: TStream; CheckUtf8: Boolean = False);
{* 封装的用 Filer 读出文件内容至流，流中均为无 BOM 的原始格式（Ansi、Ansi/Utf8、Utf16），尾部 #0。
  注意：BDS 2005 到 2007 里，当文件内容来自 IDE 内存时内部一定是 UTF8 格式，
  如将 CheckUtf8 设为 True 并且是 MemoryStream 时，该函数会将 Utf8 会转换成 Ansi，否则保持 Utf8
  而 Unicode 环境下文件内容来自磁盘时会忽略 CheckUtf8，Stream 中固定为 Utf16，
  如文件内容来自磁盘，则保持文件编码，不一定是 Ansi 还是 Utf8 还是 Utf 16。
  D5/6/7 中只支持 Ansi，都可以直接  PChar(Stream.Memory) 使用}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizUtils;

procedure EditFilerLoadFileFromStream(const FileName: string; Stream: TStream; CheckUtf8: Boolean);
begin
  with TCnEditFiler.Create(FileName) do
  try
{$IFDEF UNICODE}
    ReadFromStreamW(Stream);
{$ELSE}
    ReadFromStream(Stream, CheckUtf8);
{$ENDIF}
  finally
    Free;
  end;
end;

procedure EditFilerSaveFileToStream(const FileName: string; Stream: TStream; CheckUtf8: Boolean);
begin
  with TCnEditFiler.Create(FileName) do
  try
{$IFDEF UNICODE}
    SaveToStreamW(Stream);
{$ELSE}
    SaveToStream(Stream, CheckUtf8);
{$ENDIF}
  finally
    Free;
  end;
end;

type
  TModuleFreeNotifier = class(TNotifierObject, IOTAModuleNotifier)
  private
    FOwner: TCnEditFiler;
  public
    constructor Create(Owner: TCnEditFiler);
    destructor Destroy; override;
    procedure ModuleRenamed(const NewName: String);
    function CheckOverwrite: Boolean;
  end;

{ TModuleFreeNotifier }

function TModuleFreeNotifier.CheckOverwrite: Boolean;
begin
  Result := True;
end;

constructor TModuleFreeNotifier.Create(Owner: TCnEditFiler);
begin
  inherited Create;

  FOwner := Owner;
end;

destructor TModuleFreeNotifier.Destroy;
begin
  Assert(FOwner <> nil);
  FOwner.FreeFileData;
  FOwner.FModuleNotifier := nil;

  inherited Destroy;
end;

procedure TModuleFreeNotifier.ModuleRenamed(const NewName: String);
begin
  // We might want to handle this and change the stored file name
end;

resourcestring
  SNoEditReader = 'FEditRead: No Editor Reader Interface (You have found a bug!)';
  SNoEditWriter = 'FEditWrite: No Editor Writer Interface (You have found a bug!)';

constructor TCnEditFiler.Create(const FileName: string);
begin
  inherited Create;

  FBufSize := 32760; // Large buffers are faster, but too large causes crashes
  FNotifierIndex := InvalidNotifierIndex;
  FMode := mmModule;
  if FileName <> '' then
    SetFileName(FileName);
end;

// Use the FreeFileData to release the references
// to the internal editor buffer or the external
// file on disk in order not to block the file
// or track the editor (which may disappear) for
// possibly extended periods of time.
//
// Calls to edit reader will always (re-)allocate
// references again by calling the "AllocateFileData"
// method, so calling "FreeFileData" essentially comes
// for free, only reducing the length a reference
// is held to an entity.
procedure TCnEditFiler.FreeFileData;
begin
  FreeAndNil(FStreamFile);
  FEditRead := nil;
  FEditWrite := nil;
  FEditIntf := nil;

  ReleaseModuleNotifier;
  FModIntf := nil;

  FSourceInterfaceAllocated := False;
end;

destructor TCnEditFiler.Destroy;
begin
  FreeFileData;

  if FBuf <> nil then
    FreeMem(FBuf);
  FBuf := nil;
  FEditRead := nil;
  FEditWrite := nil;

  inherited Destroy;
end;

procedure TCnEditFiler.AllocateFileData;

  procedure AllocateFromDisk;
  begin
    if not FileExists(FFileName) then
      raise Exception.CreateFmt(SCnFileDoesNotExist, [FFileName]);

    FMode := mmFile;
    try
      FStreamFile := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite);
    except
      FStreamFile := TFileStream.Create(FFileName, fmOpenRead);
    end;
  end;

begin
  if FSourceInterfaceAllocated then
    Exit;

  if BorlandIDEServices = nil then
  begin
    AllocateFromDisk;
    Exit;
  end;

  // Get module interface
  Assert(FModIntf = nil);
  FModIntf := CnOtaGetModule(FFileName);
  if FModIntf = nil  then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditReader: Module not open in the IDE - opening from disk');
{$ENDIF}
    AllocateFromDisk;
  end
  else if CnOtaGetSourceEditorFromModule(FModIntf, FileName) = nil then
  begin
    // 当窗体 View as Text 时，无法得到源码的 SourceEditor 接口
    AllocateFromDisk;
  end
  else
  begin
    FMode := mmModule;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditReader: Got module for ' + FFileName);
{$ENDIF}

    // Allocate notifier for module
    Assert(FModuleNotifier = nil);
    FModuleNotifier := TModuleFreeNotifier.Create(Self);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditReader: Got FModuleNotifier');
{$ENDIF}
    if FModuleNotifier = nil then
    begin
      FModIntf := nil;

      raise Exception.CreateFmt(SCnNoModuleNotifier, [FFileName]);
    end;
    FNotifierIndex := FModIntf.AddNotifier(FModuleNotifier);

    // Get Editor Interface
    Assert(FEditIntf = nil);

    FEditIntf := CnOtaGetSourceEditorFromModule(FModIntf, FFileName);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditReader: Got FEditIntf for module');
{$ENDIF}
    if FEditIntf = nil then
    begin
      ReleaseModuleNotifier;
      FModIntf := nil;

      // Should we do this instead?
      //FreeFileData;

      // Sometimes causes "Instance of TEditClass has a dangling reference count of 3"
      // Happens in BCB5 when trying to focus a .h when the .dfm is being vewed as text
      // Maybe fixed in 1.0?
      raise Exception.CreateFmt(SCnNoEditorInterface, [FFileName]);
    end;

    // Get Reader interface }
    Assert((FEditRead = nil) and (FEditWrite = nil));
    FEditRead := FEditIntf.CreateReader;
    FEditWrite := FEditIntf.CreateUndoableWriter;
    if (FEditRead = nil) or (FEditWrite = nil) then
    begin
      ReleaseModuleNotifier;
      FModIntf := nil;
      FEditIntf := nil;
      if FEditRead = nil then
        raise Exception.Create(SNoEditReader);
      if FEditWrite = nil then
        raise Exception.Create(SNoEditWriter);
    end;
  end;

  FSourceInterfaceAllocated := True;
end;

procedure TCnEditFiler.SetFileName(const Value: string);
begin
  if SameText(Value, FFileName) then
    Exit;

  FreeFileData;

  // Assigning an empty string clears allocation.
  if Value = '' then
    Exit;

  FFileName := Value;
  Reset;
end;

procedure TCnEditFiler.SetBufSize(New: Integer);
begin
  if (FBuf = nil) and (New <> FBufSize) then
    FBufSize := New;
  // 32K is the max we can read from an edit reader at once
  Assert(FBufSize <= 1024 * 32);
end;

procedure TCnEditFiler.ShowSource;
begin
  AllocateFileData;

  Assert(Assigned(FEditIntf));

  if FMode = mmModule then
    FEditIntf.Show;
end;

procedure TCnEditFiler.ShowForm;
begin
  AllocateFileData;
  Assert(Assigned(FModIntf));

  if FMode = mmModule then
    CnOtaShowFormForModule(FModIntf);
end;

procedure TCnEditFiler.GotoLine(L: Integer);
begin
  InternalGotoLine(L, False);
end;

procedure TCnEditFiler.GotoOffsetLine(L: Integer);
begin
  InternalGotoLine(L, True);
end;

procedure TCnEditFiler.InternalGotoLine(Line: Integer; Offset: Boolean);
var
  EditView: IOTAEditView;
  EditPos: TOTAEditPos;
  S: Integer;
  ViewCount: Integer;
begin
  AllocateFileData;

  //{$IFDEF Debug} CnDebugger.LogMsg('LineCount ' + IntToStr(LineCount)); {$ENDIF}
  if Line > LineCount then Exit;
  if Line < 1 then
    Line := 1;

  Assert(FModIntf <> nil);
  ShowSource;

  Assert(FEditIntf <> nil);
  ViewCount := FEditIntf.EditViewCount;
  if ViewCount < 1 then
    Exit;

  EditView := FEditIntf.EditViews[0];
  if EditView <> nil then
  begin
    EditPos.Col := 1;
    EditPos.Line := Line;
    if Offset then
    begin
      EditView.CursorPos := EditPos;
      S := Line - (EditView.ViewSize.cy div 2);
      if S < 1 then S := 1;
      EditPos.Line := S;
      EditView.TopPos := EditPos;
    end
    else
    begin
      EditView.TopPos := EditPos;
      EditView.CursorPos := EditPos;
      ShowSource;
    end;
    EditView.Paint;
  end;
end;

function TCnEditFiler.GetLineCount: Integer;
begin
  if FMode = mmModule then
  begin
    AllocateFileData;
    Assert(FEditIntf <> nil);

    Result := FEditIntf.GetLinesInBuffer;
  end
  else
    Result := -1;
end;

procedure TCnEditFiler.Reset;
begin
  if FMode = mmFile then
  begin
    // We do not need to allocate file data
    // in order to set the stream position
    if FStreamFile <> nil then
      FStreamFile.Position := 0;
  end;
end;

procedure TCnEditFiler.SaveToStream(Stream: TStream; CheckUtf8: Boolean);
var
  Pos: Integer;
  Size: Integer;
{$IFDEF IDE_WIDECONTROL}
  Text: AnsiString;
{$IFDEF UNICOEE}
  List: TCnWideStringList;
  Utf16Text: string;
{$ELSE}
  List: TStringList;
  Utf16Text: WideString;
{$ENDIF}
{$ENDIF}
const
  TheEnd: AnsiChar = AnsiChar(#0); // Leave typed constant as is - needed for streaming code
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    // 注意此处内容的编码是文件编码
{$IFDEF IDE_STRING_ANSI_UTF8}
    // D2005~2007 下，用 TCnWideStringList 检测文件内容编码并加载为 UTF16
    List := TCnWideStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile);
      Utf16Text := List.Text;

      if CheckUtf8 then
        Text := AnsiString(Utf16Text)                // 再根据参数将 Utf16 转为 Utf8
      else
        Text := CnUtf8EncodeWideString(Utf16Text);   // 或直接转为 AnsiString

      Stream.Write(Text[1], Length(Text) * SizeOf(AnsiChar));
      Stream.Write(TheEnd, 1);
    finally
      List.Free;
    end;
{$ELSE}
  {$IFDEF UNICODE}
    // D2009 或以上，用系统自带 TStringList 检测文件内容编码并加载为 UTF16
    List := TStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile);
      Utf16Text := List.Text;

      if CheckUtf8 then
        Text := AnsiString(Utf16Text)                // 再根据参数将 Utf16 转为 Utf8
      else
        Text := CnUtf8EncodeWideString(Utf16Text);   // 或直接转为 AnsiString

      Stream.Write(Text[1], Length(Text) * SizeOf(AnsiChar));
      Stream.Write(TheEnd, 1);
    finally
      List.Free;
    end
  {$ELSE}
    // D567下只支持 Ansi，无需额外处理
    FStreamFile.Position := 0;
    Stream.CopyFrom(FStreamFile, FStreamFile.Size);
    Stream.Write(TheEnd, 1);
  {$ENDIF}
{$ENDIF}
  end
  else
  begin
    Pos := 0;
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);
    if FEditRead = nil then
      raise Exception.Create(SNoEditReader);
    // Delphi 5+ sometimes returns -1 here, for an unknown reason
    Size := FEditRead.GetText(Pos, FBuf, BufSize);
    if Size = -1 then
    begin
      FreeFileData;
      AllocateFileData;
      Size := FEditRead.GetText(Pos, FBuf, BufSize);
    end;
    if Size > 0 then
    begin
      Pos := Pos + Size;
      while Size = BufSize do
      begin
        Stream.Write(FBuf^, Size);
        Size := FEditRead.GetText(Pos, FBuf, BufSize);
        Pos := Pos + Size;
      end;
      Stream.Write(FBuf^, Size);
    end;
    Stream.Write(TheEnd, 1);

{$IFDEF IDE_WIDECONTROL}
    if CheckUtf8 and (Stream is TMemoryStream) then
    begin
      Text := CnUtf8ToAnsi(PAnsiChar((Stream as TMemoryStream).Memory));
      Stream.Size := Length(Text) + 1;
      Stream.Position := 0;
      Stream.Write(PAnsiChar(Text)^, Length(Text) + 1);
    end;
{$ENDIF}
  end;
end;

{$IFDEF UNICODE}

procedure TCnEditFiler.SaveToStreamW(Stream: TStream);
var
  Pos: Integer;
  Size: Integer;
  Text: string;
  List: TStringList;
const
  TheEnd: AnsiChar = AnsiChar(#0); // Leave typed constant as is - needed for streaming code
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    // Unicode 环境下，要根据文件的 BOM 转换成 UTF16，不能直接复制文件流
    List := TStringList.Create;
    try
      List.LoadFromStream(FStreamFile); // 内部会根据文件 BOM 记录其编码，然后转换成 UTF16
      Text := List.Text;
      Stream.Write(Text[1], Length(Text) * SizeOf(Char));
      Stream.Write(TheEnd, 1);  // Write UTF16 #$0000
      Stream.Write(TheEnd, 1);
    finally
      List.Free;
    end;
  end
  else
  begin
    Pos := 0;
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);
    if FEditRead = nil then
      raise Exception.Create(SNoEditReader);

    // Delphi 5+ sometimes returns -1 here, for an unknown reason
    Size := FEditRead.GetText(Pos, FBuf, BufSize);
    if Size = -1 then
    begin
      FreeFileData;
      AllocateFileData;
      Size := FEditRead.GetText(Pos, FBuf, BufSize);
    end;
    if Size > 0 then
    begin
      Pos := Pos + Size;
      while Size = BufSize do
      begin
        Stream.Write(FBuf^, Size);
        Size := FEditRead.GetText(Pos, FBuf, BufSize);
        Pos := Pos + Size;
      end;
      Stream.Write(FBuf^, Size);
    end;
    Stream.Write(TheEnd, 1);  // Write UTF16 #$0000
    Stream.Write(TheEnd, 1);

    if Stream is TMemoryStream then
    begin
      Text := Utf8Decode(PAnsiChar((Stream as TMemoryStream).Memory));
      Stream.Size := (Length(Text) + 1) * SizeOf(Char);
      Stream.Position := 0;
      Stream.Write(PChar(Text)^, (Length(Text) + 1) * SizeOf(Char));
    end;
  end;
end;

{$ENDIF}

function TCnEditFiler.GetCurrentBufferPos: Integer;
var
  EditorPos: TOTAEditPos;
  CharPos: TOTACharPos;
  EditView: IOTAEditView;
begin
  AllocateFileData;

  Assert(FEditIntf <> nil);

  Result := -1;
  Assert(FEditIntf.EditViewCount > 0);

  EditView := FEditIntf.EditViews[0];
  if EditView <> nil then
  begin
    EditorPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditorPos, CharPos);
    Result := EditView.CharPosToPos(CharPos);
  end;
end;

procedure TCnEditFiler.SaveToStreamFromPos(Stream: TStream);
var
  Pos: Integer;
  Size: Integer;
begin
  AllocateFileData;

  Reset;

  if Mode = mmFile then
  begin
    // TODO: 文件编码的 UTF8 处理
    Assert(FStreamFile <> nil);
    FStreamFile.Position := 0;
    Stream.CopyFrom(FStreamFile, FStreamFile.Size);
  end
  else
  begin
    Pos := GetCurrentBufferPos;
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);
    if FEditRead = nil then
      raise Exception.Create(SNoEditReader);

    Size := FEditRead.GetText(Pos, FBuf, BufSize);
    if Size > 0 then
    begin
      Pos := Pos + Size;
      while Size = BufSize do
      begin
        Stream.Write(FBuf^, Size);
        Size := FEditRead.GetText(Pos, FBuf, BufSize);
        Pos := Pos + Size;
      end;
      Stream.Write(FBuf^, Size);
    end;
  end;
end;

// The character at the current position is not written to the stream
procedure TCnEditFiler.SaveToStreamToPos(Stream: TStream);
var
  Pos, AfterPos: Integer;
  ToReadSize, Size: Integer;
  NullChar: char;
begin
  AllocateFileData;

  Reset;

  if Mode = mmFile then
  begin
    // TODO: 文件编码的 UTF8 处理
    Assert(FStreamFile <> nil);
    FStreamFile.Position := 0;
    Stream.CopyFrom(FStreamFile, FStreamFile.Size);
  end
  else
  begin
    AfterPos := GetCurrentBufferPos;
    Pos := 0;
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);
    if FEditRead = nil then
      raise Exception.Create(SNoEditReader);

    ToReadSize := Min(BufSize, AfterPos - Pos);
    Size := FEditRead.GetText(Pos, FBuf, ToReadSize);
    if Size > 0 then
    begin
      Pos := Pos + Size;
      while Size = BufSize do
      begin
        Stream.Write(FBuf^, Size);
        ToReadSize := Min(BufSize, AfterPos - Pos);
        Size := FEditRead.GetText(Pos, FBuf, ToReadSize);
        Pos := Pos + Size;
      end;
      Stream.Write(FBuf^, Size);
    end;
  end;
  NullChar := #0;
  Stream.Write(NullChar, SizeOf(NullChar));
end;

procedure TCnEditFiler.ReleaseModuleNotifier;
begin
  if FNotifierIndex <> InvalidNotifierIndex then
    FModIntf.RemoveNotifier(FNotifierIndex);
  FNotifierIndex := InvalidNotifierIndex;
  FModuleNotifier := nil;
end;

{$IFDEF UNICODE}

procedure TCnEditFiler.ReadFromStreamW(Stream: TStream);
var
  Size: Integer;
  Utf8Text: AnsiString;
  List: TStringList;
  Utf16Text: string;
  Utf8Stream: TMemoryStream;
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    if Stream is TMemoryStream then
    begin
      // Unicode 环境下，要根据文件的 BOM 转换 UTF16 的 Stream 内容，不能直接复制文件流
      List := TStringList.Create;
      try
        FStreamFile.Position := 0;
        List.LoadFromStream(FStreamFile); // List 内容是 Utf16，并记录了文件编码

        // 把 Stream 的 Utf16 内容塞给 Utf16Text 再给 List
        SetLength(Utf16Text, Stream.Size div 2);
        Stream.Position := 0;
        Move((Stream as TMemoryStream).Memory^, Utf16Text[1], Length(Utf16Text) * SizeOf(WideChar));
        List.Text := Utf16Text;

        FStreamFile.Size := 0;
        List.SaveToStream(FStreamFile); // List 保存时根据之前记录的文件编码转换后保存
      finally
        List.Free;
      end;
    end;
  end
  else
  begin
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    FEditWrite.DeleteTo(MaxInt);

    Utf8Stream := nil;
    try
      if Stream is TMemoryStream then // 外部传入的 UTF16 格式内容在这里要转成 Utf8
      begin
        SetLength(Utf16Text, Stream.Size div 2);
        Stream.Position := 0;
        Move((Stream as TMemoryStream).Memory^, Utf16Text[1], Length(Utf16Text) * SizeOf(WideChar));
        Utf8Text := CnUtf8EncodeWideString(Utf16Text);

        Utf8Stream := TMemoryStream.Create;
        Utf8Stream.Size := Length(Utf8Text);
        Utf8Stream.Position := 0;
        Utf8Stream.Write(PAnsiChar(Utf8Text)^, Length(Utf8Text));
      end;

      if FBuf = nil then
        GetMem(FBuf, BufSize + 1);

      if Utf8Stream <> nil then
      begin
        if Utf8Stream.Size > 0 then
        begin
          Utf8Stream.Position := 0;
          repeat
            FillChar(FBuf^, BufSize + 1, 0);
            Size := Utf8Stream.Read(FBuf^, BufSize);
            FEditWrite.Insert(FBuf);
          until Size <> BufSize;
        end
      end
      else // 没转 UTF8
      begin
        if Stream.Size > 0 then
        begin
          Stream.Position := 0;
          repeat
            FillChar(FBuf^, BufSize + 1, 0);
            Size := Stream.Read(FBuf^, BufSize);
            FEditWrite.Insert(FBuf);
          until Size <> BufSize;
        end;
      end;
    finally
      Utf8Stream.Free;
    end;
  end;
end;

{$ENDIF}

// 从 Stream 整个写到文件或缓冲中，覆盖原有内容，与 Stream 的 Position 和光标位置无关。
procedure TCnEditFiler.ReadFromStream(Stream: TStream; CheckUtf8: Boolean);
var
  Size: Integer;
{$IFDEF IDE_WIDECONTROL}
  AnsiText: AnsiString;
  Utf8Text: AnsiString;
  Utf16Text: WideString;
{$IFDEF UNICODE}
  List: TStringList;
{$ELSE}
  List: TCnWideStringList;
{$ENDIF}
{$ENDIF}
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

{$IFDEF IDE_WIDECONTROL}
    if CheckUtf8 and (Stream is TMemoryStream) then
    begin
      SetLength(AnsiText, Stream.Size);
      Move((Stream as TMemoryStream).Memory^, AnsiText[1], Stream.Size);
      Utf8Text := CnAnsiToUtf8(AnsiText);
    end
    else
    begin
      SetLength(Utf8Text, Stream.Size);
      Move((Stream as TMemoryStream).Memory^, Utf8Text[1], Stream.Size);
    end;

    // 此时 Utf8Text 里是 Utf8 内容，要转 UTF16 以放到 StringList 里
    Utf16Text := CnUtf8DecodeToWideString(Utf8Text);
  {$IFDEF UNICODE}
    // Unicode 环境下，要给 StringList 赋值，让其内部根据文件的 BOM，转换 UTF16 的内容写入文件
    List := TStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile); // List 内容是 Utf16，并记录了文件编码

      List.Text := Utf16Text;

      FStreamFile.Size := 0;
      List.SaveToStream(FStreamFile); // List 保存时根据之前记录的文件编码转换后保存
    finally
      List.Free;
    end;
  {$ELSE}
    // D2005~2007 下，要给 CnWideStringList 赋值，让其根据文件的 BOM，转换 UTF16 的内容写入文件
    List := TCnWideStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile); // List 内容是 Utf16，并记录了文件编码

      List.Text := Utf16Text;

      FStreamFile.Size := 0;
      List.SaveToStream(FStreamFile, List.LoadFormat); // List 保存时根据之前记录的文件编码转换后保存
    finally
      List.Free;
    end;
  {$ENDIF}
{$ELSE}
    Stream.Position := 0;
    FStreamFile.Size := 0;
    FStreamFile.CopyFrom(Stream, Stream.Size);
{$ENDIF}
  end
  else
  begin
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    FEditWrite.DeleteTo(MaxInt);

{$IFDEF IDE_WIDECONTROL}
    if CheckUtf8 and (Stream is TMemoryStream) then // Stream 内容是 Ansi，BDS 以上得转 Utf8，无需尾部 #0
    begin
      Utf8Text := CnAnsiToUtf8(PAnsiChar((Stream as TMemoryStream).Memory));
      Stream.Size := Length(Utf8Text);
      Stream.Position := 0;
      Stream.Write(PAnsiChar(Utf8Text)^, Length(Utf8Text));
    end;
{$ENDIF}

    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);

    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      repeat
        FillChar(FBuf^, BufSize + 1, 0);
        Size := Stream.Read(FBuf^, BufSize);
        FEditWrite.Insert(FBuf);
      until Size <> BufSize;
    end;
  end;
end;

// 流的内容覆盖当前位置的文本
procedure TCnEditFiler.ReadFromStreamInPos(Stream: TStream);
var
  Size: Integer;
  CurrPos: Integer;
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    Stream.Position := 0;
    FStreamFile.Size := 0;
    FStreamFile.CopyFrom(Stream, Stream.Size);
  end
  else
  begin
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    CurrPos := CnOtaGetCurrLinearPos;
    FEditWrite.CopyTo(CurrPos);

    FEditWrite.DeleteTo(CurrPos + Stream.Size);
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);

    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      repeat
        FillChar(FBuf^, BufSize + 1, 0);
        Size := Stream.Read(FBuf^, BufSize);
        FEditWrite.Insert(FBuf);
      until Size <> BufSize;
    end;
  end;
end;

// 流内容插入当前文本的当前位置。
procedure TCnEditFiler.ReadFromStreamInsertToPos(Stream: TStream);
var
  Size: Integer;
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    Stream.Position := 0;
    FStreamFile.Size := 0;
    FStreamFile.CopyFrom(Stream, Stream.Size);
  end
  else
  begin
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    FEditWrite.CopyTo(CnOtaGetCurrLinearPos);
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);

    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      repeat
        FillChar(FBuf^, BufSize + 1, 0);
        Size := Stream.Read(FBuf^, BufSize);
        FEditWrite.Insert(FBuf);
      until Size <> BufSize;
    end;
  end;
end;

function TCnEditFiler.GetFileSize: Integer;
var
  Size: Integer;
begin
  Reset;
  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);
    Result := FStreamFile.Size;
  end
  else
  begin
    Result := 0;
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);

    if FEditRead = nil then
      raise Exception.Create(SNoEditReader);
    // Delphi 5+ sometimes returns -1 here, for an unknown reason
    Size := FEditRead.GetText(Result, FBuf, BufSize);
    if Size = -1 then
    begin
      FreeFileData;
      AllocateFileData;
      Size := FEditRead.GetText(Result, FBuf, BufSize);
    end;

    if Size > 0 then
    begin
      Inc(Result, Size);
      while Size = BufSize do
      begin
        Size := FEditRead.GetText(Result, FBuf, BufSize);
        Inc(Result, Size);
      end;
    end;
  end;
end;

end.

