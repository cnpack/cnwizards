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
*                        D567            D2005~2007               D2009 或以上  Lazarus
*           磁盘文件     Ansi            Utf8（可指定成 Ansi）    Utf16         Utf8
*           IDE 内存     Ansi            Utf8（可指定成 Ansi）    Utf16         Utf8
*
*           EditFilerSaveFileToStream 得到的 Stream 的编码行为：
*                        D567            D2005~2007               D2009 或以上  Lazarus
*           磁盘文件     Ansi            Utf8（可解码成 Ansi）    Utf16         Utf8
*           IDE 内存     Ansi            Utf8（可解码成 Ansi）    Utf16         Utf8
*
*           注意控制 Utf8 指定或解码成 Ansi 时，需将 IsAnsi/NeedAnsi 参数设为 True
*
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2025.01.31 V1.4
*               重构 ReadFromStream 及 SaveToStream 的行为，不再依赖 MemoryStream
*               改动面较大，待完整测试
*           2025.01.29 V1.3
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
  SysUtils, Classes, Math, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} CnWizConsts,
  CnWideStrings {$IFDEF LAZARUS}, SrcEditorIntf {$ENDIF};

type
  TModuleMode = (mmModule, mmFile);

  TCnEditFiler = class(TObject)
  {* 只支持 Module 级别的编辑器文件，不支持 dfm 之类的}
  private
    FSourceInterfaceAllocated: Boolean;
{$IFDEF DELPHI_OTA}
    FModuleNotifier: IOTAModuleNotifier;
    FEditIntf: IOTASourceEditor;
    FEditRead: IOTAEditReader;
    FEditWrite: IOTAEditWriter;
    FModIntf: IOTAModule;
{$ENDIF}
{$IFDEF LAZARUS}
    FEditor: TSourceEditorInterface;
{$ENDIF}
    FNotifierIndex: Integer;
    FBuf: Pointer;
    FBufSize: Integer;
    FFileName: string;
    FMode: TModuleMode;
    FStreamFile: TStream;
    procedure AllocateFileData;
    procedure SetBufSize(New: Integer);
    function GetLineCount: Integer;
{$IFDEF DELPHI_OTA}
    procedure InternalGotoLine(Line: Integer; Offset: Boolean);
{$ENDIF}
    function GetFileSize: Integer;
  protected
    procedure SetFileName(const Value: string);
 {$IFDEF DELPHI_OTA}
    procedure ReleaseModuleNotifier;
 {$ENDIF}
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    procedure FreeFileData;
    procedure Reset;
{$IFDEF DELPHI_OTA}
    procedure GotoLine(L: Integer);
    procedure GotoOffsetLine(L: Integer);
    procedure ShowSource;
    procedure ShowForm;
{$ENDIF}

{$IFDEF UNICODE}
    procedure SaveToStreamW(Stream: TStream);
    // 将文件内容存入流中，存成没 BOM 的 UTF16 格式，尾部 #0
    // 文件是磁盘形式时，能够将文件编码转换为 UTF16
    // 文件是内存形式时，能够将 IDE 内部的 UTF8 编码转换为 UTF16

{$ENDIF}
    procedure SaveToStream(Stream: TStream; CheckUtf8: Boolean = False);
    // 读出均为无 BOM 的 Ansi 或 Utf8 格式，尾部 #0。D5/6/7 中只支持 Ansi
    // BDS 里（2005 以上，无论是否 Unicode 编译器），无论文件在 IDE 里打开还是磁盘形式，
    // CheckUtf8 是 True 时，文件编码或 IDE 内部 Utf8 编码会转换成 Ansi，否则统一为 Utf8。

{$IFDEF DELPHI_OTA}
    // TODO: 以下两函数暂未做 UTF8 适配，不推荐使用
    procedure SaveToStreamFromPos(Stream: TStream); {$IFDEF SUPPORT_DEPRECATED} deprecated; {$ENDIF}
    procedure SaveToStreamToPos(Stream: TStream); {$IFDEF SUPPORT_DEPRECATED} deprecated; {$ENDIF}
{$ENDIF}

{$IFDEF UNICODE}
    procedure ReadFromStreamW(Stream: TStream);
    // 从 Stream 整个写到文件或缓冲中，覆盖原有内容。要求流中是 UTF16，无 BOM
    // 文件是磁盘形式时，能够将 UTF16 编码转换为文件对应编码
    // 文件是内存形式时，能够将 UTF16 编码转换为 IDE 所需的 UTF8 编码
{$ENDIF}
    // LiuXiao 添加三个读入流函数。
    procedure ReadFromStream(Stream: TStream; CheckUtf8: Boolean = False);
    // 从 Stream 整个写到文件或缓冲中，覆盖原有内容，与 Stream 的 Position 和光标位置无关，
    // 要求流中是 Ansi 或 Utf8，无 BOM，不要求 Stream 尾 #0（准确来讲不能是 #0 否则会出现多余字符）
    // 写缓冲时如果是 BDS/Lazarus 且 Stream 内容如果是 Ansi，则 CheckUtf8 得设为 True 以进行 Ansi 到 Utf8 的转换以适合编辑器缓冲。
    // 写文件时是磁盘形式时，目前 D567 只支持 Ansi 照常写，BDS 或以上则支持 Ansi（需 CheckUtf8 为 True） 或 Utf8
    // 内部会统一转 UTF8 再转 UTF16 再判断文件编码写入。

{$IFDEF DELPHI_OTA}
    // TODO: 以下两函数暂未做 UTF8 适配，不推荐使用
    procedure ReadFromStreamInPos(Stream: TStream); {$IFDEF SUPPORT_DEPRECATED} deprecated; {$ENDIF}
    procedure ReadFromStreamInsertToPos(Stream: TStream); {$IFDEF SUPPORT_DEPRECATED} deprecated; {$ENDIF}

    function GetCurrentBufferPos: Integer;
{$ENDIF}
    property BufSize: Integer read FBufSize write SetBufSize;
    property FileName: string read FFileName write SetFileName;
    property LineCount: Integer read GetLineCount;
    property Mode: TModuleMode read FMode;
    property FileSize: Integer read GetFileSize;
  end;

procedure EditFilerLoadFileFromStream(const FileName: string; Stream: TStream; IsAnsi: Boolean = False);
{* 封装的用流写入 Filer 的文件内容，要求流中无 BOM，尾部无需 #0，格式 Ansi、Ansi/Utf8、Utf16
  如果是 BDS 2005 到 2007 里且 Stream 内容是 Ansi 格式，则可由 IsAnsi 设为 True
  来进行 Ansi 到 Utf8 的转换以适合编辑器缓冲，如果是文件模式也内部自动适配编码，不会转换。
  D5/6/7 与 Unicode 环境下会忽略 IsAnsi，Stream 中的内容必须固定为 Ansi 及 Utf16。
  Lazarus 下内容必须是 Utf8，因此 IsAnsi 如果 True 时，Stream 内容会转换成 Utf8。
  以上行为无论文件是磁盘还是 IDE 内部打开均如此。}

procedure EditFilerSaveFileToStream(const FileName: string; Stream: TStream; NeedAnsi: Boolean = False);
{* 封装的用 Filer 读出文件内容至流，流中均为无 BOM 的原始格式（Ansi、Ansi/Utf8、Utf16），尾部有 #0。
  在 Lazarus/BDS 2005 到 2007 里，如将 NeedAnsi 设为 True 时，该函数会将 Utf8 会转换成 Ansi，否则保持 Utf8，
  而 Unicode 环境下会忽略 NeedAnsi 参数，输出的 Stream 中的内容固定为 Utf16。
  以上行为无论文件是磁盘还是 IDE 内部打开均如此。}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizUtils;

procedure EditFilerLoadFileFromStream(const FileName: string; Stream: TStream; IsAnsi: Boolean);
begin
  with TCnEditFiler.Create(FileName) do
  try
{$IFDEF UNICODE}
    ReadFromStreamW(Stream);
{$ELSE}
    ReadFromStream(Stream, IsAnsi);
{$ENDIF}
  finally
    Free;
  end;
end;

procedure EditFilerSaveFileToStream(const FileName: string; Stream: TStream; NeedAnsi: Boolean);
begin
  with TCnEditFiler.Create(FileName) do
  try
{$IFDEF UNICODE}
    SaveToStreamW(Stream);
{$ELSE}
    SaveToStream(Stream, NeedAnsi);
{$ENDIF}
  finally
    Free;
  end;
end;

{$IFDEF DELPHI_OTA}

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

end;

{$ENDIF}

resourcestring
  SNoEditReader = 'FEditRead: No Editor Reader Interface';
  SNoEditWriter = 'FEditWrite: No Editor Writer Interface';

constructor TCnEditFiler.Create(const FileName: string);
begin
  inherited Create;

  FBufSize := 32760; // D7 或以下版本，这个数值设大了会导致读出错误，别改
  FNotifierIndex := InvalidNotifierIndex;
  FMode := mmModule;
  if FileName <> '' then
    SetFileName(FileName);
end;

procedure TCnEditFiler.FreeFileData;
begin
  FreeAndNil(FStreamFile);
{$IFDEF DELPHI_OTA}
  FEditRead := nil;
  FEditWrite := nil;
  FEditIntf := nil;

  ReleaseModuleNotifier;
  FModIntf := nil;
{$ENDIF}
  FSourceInterfaceAllocated := False;
end;

destructor TCnEditFiler.Destroy;
begin
  FreeFileData;

  if FBuf <> nil then
    FreeMem(FBuf);

{$IFDEF DELPHI_OTA}
  FBuf := nil;
  FEditRead := nil;
  FEditWrite := nil;
{$ENDIF}
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

{$IFDEF LAZARUS}
  // 遍历 Editors 找是否有该文件
  FEditor := CnOtaGetEditor(FFileName);
  if FEditor = nil then
  begin
    AllocateFromDisk;
    Exit;
  end;
{$ENDIF}

{$IFDEF DELPHI_OTA}
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
{$ENDIF}

  FSourceInterfaceAllocated := True;
end;

procedure TCnEditFiler.SetFileName(const Value: string);
begin
  if SameText(Value, FFileName) then
    Exit;

  FreeFileData;

  if Value = '' then
    Exit;

  FFileName := Value;
  Reset;
end;

procedure TCnEditFiler.SetBufSize(New: Integer);
begin
  if (FBuf = nil) and (New <> FBufSize) then
    FBufSize := New;
end;

{$IFDEF DELPHI_OTA}

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

{$ENDIF}

function TCnEditFiler.GetLineCount: Integer;
begin
  Result := -1;
  if FMode = mmModule then
  begin
    AllocateFileData;
{$IFDEF DELPHI_OTA}
    Assert(FEditIntf <> nil);
    Result := FEditIntf.GetLinesInBuffer;
{$ENDIF}

{$IFDEF LAZARUS}
    if FEditor <> nil then
      Result := FEditor.Lines.Count;
{$ENDIF}
  end
  else
    Result := -1;
end;

procedure TCnEditFiler.Reset;
begin
  if FMode = mmFile then
  begin
    if FStreamFile <> nil then
      FStreamFile.Position := 0;
  end;
end;

procedure TCnEditFiler.SaveToStream(Stream: TStream; CheckUtf8: Boolean);
const
  TheEnd: AnsiChar = AnsiChar(#0);
var
  Pos: Integer;
  Size: Integer;
  NeedCheck: Boolean;
{$IFDEF IDE_WIDECONTROL}
  Text, Utf8Text: AnsiString;
{$IFDEF UNICODE}
  List: TStringList;
  Utf16Text: string;
{$ELSE}
  List: TCnWideStringList;
  Utf16Text: WideString;
{$ENDIF}
{$ELSE}
  Text, Utf8Text: AnsiString;
  List: TCnWideStringList;
  Utf16Text: WideString;
{$ENDIF}
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
    {$IFDEF LAZARUS}
    // Lazarus 下，用 TCnWideStringList 检测文件内容编码并加载为 UTF16
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
    // D567下只支持 Ansi，无需额外处理
    FStreamFile.Position := 0;
    Stream.CopyFrom(FStreamFile, FStreamFile.Size);
    Stream.Write(TheEnd, 1);
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
  end
  else
  begin
    Pos := 0;
{$IFDEF LAZARUS}
    Utf8Text := FEditor.Lines.Text;
    if Length(Utf8Text) > 0 then
      Stream.Write(Utf8Text[1], Length(Utf8Text));
    Stream.Write(TheEnd, 1);
{$ELSE}
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
{$ENDIF}

    NeedCheck := False;
{$IFDEF IDE_WIDECONTROL}
    NeedCheck := True;
{$ENDIF}
{$IFDEF LAZARUS}
    NeedCheck := True;
{$ENDIF}

    if NeedCheck and CheckUtf8 then
    begin
      // 缓冲区里读出的是 Utf8 格式的流，有 #0，读成字符串后因为尾部有 #0 了，所以少读一个
      SetLength(Utf8Text, Stream.Size - 1);
      Stream.Position := 0;
      Stream.Read(Utf8Text[1], Stream.Size - 1);

      // 转成 Ansi
      Text := CnUtf8ToAnsi(PAnsiChar(Utf8Text));

      // 再写回 Stream，加个 #0
      Stream.Size := Length(Text) + 1;
      Stream.Position := 0;
      Stream.Write(PAnsiChar(Text)^, Length(Text) + 1);
    end;
  end;
end;

{$IFDEF UNICODE}

procedure TCnEditFiler.SaveToStreamW(Stream: TStream);
const
  TheEnd: AnsiChar = AnsiChar(#0); // Leave typed constant as is - needed for streaming code
var
  Pos: Integer;
  Size: Integer;
  Utf8Text: AnsiString;
  Text: string;
  List: TStringList;
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

    // 缓冲区里读出的是 Utf8 格式的流，无 #0，读成字符串后尾部有 #0 了，转 Utf16 后尾部也有宽 #0 了
    SetLength(Utf8Text, Stream.Size);
    Stream.Position := 0;
    Stream.Read(Utf8Text[1], Stream.Size);
    Text := CnUtf8DecodeToWideString(Utf8Text);

    // 写 Stream 时多写一个宽字符，写进宽 #0 去
    Stream.Size := (Length(Text) + 1) * SizeOf(Char);
    Stream.Position := 0;
    Stream.Write(PChar(Text)^, (Length(Text) + 1) * SizeOf(Char));
  end;
end;

{$ENDIF}

{$IFDEF DELPHI_OTA}

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

{$ENDIF}

{$IFDEF UNICODE}

procedure TCnEditFiler.ReadFromStreamW(Stream: TStream);
var
  Utf8Text: AnsiString;
  List: TStringList;
  Utf16Text: string;
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    // Unicode 环境下，要根据文件的 BOM 转换 UTF16 的 Stream 内容，不能直接复制文件流
    List := TStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile); // List 内容是 Utf16，并记录了文件编码

      // 把 Stream 的 Utf16 内容塞给 Utf16Text 再给 List
      SetLength(Utf16Text, Stream.Size div 2);
      Stream.Position := 0;
      Stream.Read(Utf16Text[1], Length(Utf16Text) * SizeOf(WideChar));
      List.Text := Utf16Text;

      FStreamFile.Size := 0;
      List.SaveToStream(FStreamFile); // List 保存时根据之前记录的文件编码转换后保存
    finally
      List.Free;
    end;
  end
  else
  begin
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    FEditWrite.DeleteTo(MaxInt);

    // 外部传入的 Utf16 格式尾部无宽 #0 内容，在这里要加上宽 #0 转成 Utf8
    SetLength(Utf16Text, Stream.Size div 2);
    Stream.Position := 0;
    Stream.Read(Utf16Text[1], Length(Utf16Text) * SizeOf(WideChar));
    Utf8Text := CnUtf8EncodeWideString(Utf16Text);

    // Utf8 尾部有 #0，用 FEditWrite.Insert 一次性写入，正好有 PAnsiChar 且 #0 结尾
    if Length(Utf8Text) > 0 then
      FEditWrite.Insert(PAnsiChar(Utf8Text));
  end;
end;

{$ENDIF}

// 从 Stream 整个写到文件或缓冲中，覆盖原有内容，与 Stream 的 Position 和光标位置无关。
procedure TCnEditFiler.ReadFromStream(Stream: TStream; CheckUtf8: Boolean);
var
  AnsiText: AnsiString;
  Utf8Text: AnsiString;
  Utf16Text: WideString;
{$IFDEF UNICODE}
  List: TStringList;
{$ELSE}
  List: TCnWideStringList;
{$ENDIF}
  Size: Integer;
  NeedCheck: Boolean;
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  NeedCheck := False;
{$IFDEF LAZARUS}
  NeedCheck := True;
{$ENDIF}
{$IFDEF IDE_WIDECONTROL}
  NeedCheck := True;
{$ENDIF}

  if NeedCheck then
  begin
    // 改用 Read/Write 搬内容到 AnsiText 或 Utf8Text 中，脱离 TMemoryStream 限制
    Stream.Position := 0;
    if CheckUtf8 then
    begin
      // Stream 内容是 Ansi，一次全部读入后转成 Utf8
      SetLength(AnsiText, Stream.Size);
      Stream.Read(AnsiText[1], Stream.Size);
      Utf8Text := CnAnsiToUtf8(AnsiText);
    end
    else
    begin
      // Stream 内容是 Utf8，一次全部读入
      SetLength(Utf8Text, Stream.Size);
      Stream.Read(Utf8Text[1], Stream.Size);
    end;
  end;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

{$IFDEF LAZARUS}
    // 和 IDE_WIDE_CONTROL 里的非 UNICODE 部分等同
    // 此时 Utf8Text 里是 Utf8 内容且末尾有 #0，要转 UTF16 以放到 StringList 里
    Utf16Text := CnUtf8DecodeToWideString(Utf8Text);

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
{$ELSE}
{$IFDEF IDE_WIDECONTROL}
    // 此时 Utf8Text 里是 Utf8 内容且末尾有 #0，要转 UTF16 以放到 StringList 里
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
{$ENDIF}
  end
  else
  begin
{$IFDEF LAZARUS}
    // 文件打开状态下，写入 Utf8 内容
    if FEditor = nil then
      raise Exception.Create(SNoEditWriter);

    FEditor.Lines.Text := Utf8Text;
{$ELSE}
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    FEditWrite.DeleteTo(MaxInt);

{$IFDEF IDE_WIDECONTROL}
    // 此时 Utf8Text 里是 Utf8 内容且末尾有 #0，不分块，直接写入
    FEditWrite.Insert(PAnsiChar(Utf8Text));
{$ELSE}
    // D567 下照常分块写入
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
{$ENDIF}
{$ENDIF}
  end;
end;

{$IFDEF DELPHI_OTA}

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

{$ENDIF}

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
{$IFDEF LAZARUS}
    Result := 0;
    if FEditor <> nil then
      Result := Length(FEditor.Lines.Text);
{$ENDIF}

{$IFDEF DELPHI_OTA}
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
{$ENDIF}
  end;
end;

end.

