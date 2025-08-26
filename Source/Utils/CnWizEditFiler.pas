{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
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
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��༭���ļ���ȡ�൥Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�� GExperts 1.2 Src �� GX_EditReader ��ֲ����
*           ��ԭʼ������ GExperts License �ı���
*
*           EditFilerLoadFileFromStream �� Stream �ı���Ҫ��
*                        D567            D2005~2007               D2009 ������  Lazarus
*           �����ļ�     Ansi            Utf8����ָ���� Ansi��    Utf16         Utf8
*           IDE �ڴ�     Ansi            Utf8����ָ���� Ansi��    Utf16         Utf8
*
*           EditFilerSaveFileToStream �õ��� Stream �ı�����Ϊ��
*                        D567            D2005~2007               D2009 ������  Lazarus
*           �����ļ�     Ansi            Utf8���ɽ���� Ansi��    Utf16         Utf8
*           IDE �ڴ�     Ansi            Utf8���ɽ���� Ansi��    Utf16         Utf8
*
*           ע����� Utf8 ָ�������� Ansi ʱ���轫 IsAnsi/NeedAnsi ������Ϊ True
*
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.01.31 V1.4
*               �ع� ReadFromStream �� SaveToStream ����Ϊ���������� MemoryStream
*               �Ķ���ϴ󣬴���������
*           2025.01.29 V1.3
*               �޸� EditFilerLoadFileFromStream ����Ϊ��ʹ��� Save �汾����һ�µ�
*               Ansi��Ansi/Utf8��Utf16�����ļ�����δ����Ӧ��Save �汾����
*           2017.04.29 V1.2
*               ���� Unicode �����¶��ļ�ʱδת��Ϊ Utf16 ������
*           2003.06.17 V1.1
*               �޸��ļ���������д���ܣ�LiuXiao��
*           2003.03.02 V1.0
*               ������Ԫ����ֲ������By �ܾ���
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
  {* ֻ֧�� Module ����ı༭���ļ�����֧�� dfm ֮���}
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
    // ���ļ����ݴ������У����û BOM �� UTF16 ��ʽ��β�� #0
    // �ļ��Ǵ�����ʽʱ���ܹ����ļ�����ת��Ϊ UTF16
    // �ļ����ڴ���ʽʱ���ܹ��� IDE �ڲ��� UTF8 ����ת��Ϊ UTF16

{$ENDIF}
    procedure SaveToStream(Stream: TStream; CheckUtf8: Boolean = False);
    // ������Ϊ�� BOM �� Ansi �� Utf8 ��ʽ��β�� #0��D5/6/7 ��ֻ֧�� Ansi
    // BDS �2005 ���ϣ������Ƿ� Unicode ���������������ļ��� IDE ��򿪻��Ǵ�����ʽ��
    // CheckUtf8 �� True ʱ���ļ������ IDE �ڲ� Utf8 �����ת���� Ansi������ͳһΪ Utf8��

{$IFDEF DELPHI_OTA}
    // TODO: ������������δ�� UTF8 ���䣬���Ƽ�ʹ��
    procedure SaveToStreamFromPos(Stream: TStream); {$IFDEF SUPPORT_DEPRECATED} deprecated; {$ENDIF}
    procedure SaveToStreamToPos(Stream: TStream); {$IFDEF SUPPORT_DEPRECATED} deprecated; {$ENDIF}
{$ENDIF}

{$IFDEF UNICODE}
    procedure ReadFromStreamW(Stream: TStream);
    // �� Stream ����д���ļ��򻺳��У�����ԭ�����ݡ�Ҫ�������� UTF16���� BOM
    // �ļ��Ǵ�����ʽʱ���ܹ��� UTF16 ����ת��Ϊ�ļ���Ӧ����
    // �ļ����ڴ���ʽʱ���ܹ��� UTF16 ����ת��Ϊ IDE ����� UTF8 ����
{$ENDIF}
    // LiuXiao �������������������
    procedure ReadFromStream(Stream: TStream; CheckUtf8: Boolean = False);
    // �� Stream ����д���ļ��򻺳��У�����ԭ�����ݣ��� Stream �� Position �͹��λ���޹أ�
    // Ҫ�������� Ansi �� Utf8���� BOM����Ҫ�� Stream β #0��׼ȷ���������� #0 �������ֶ����ַ���
    // д����ʱ����� BDS/Lazarus �� Stream ��������� Ansi���� CheckUtf8 ����Ϊ True �Խ��� Ansi �� Utf8 ��ת�����ʺϱ༭�����塣
    // д�ļ�ʱ�Ǵ�����ʽʱ��Ŀǰ D567 ֻ֧�� Ansi �ճ�д��BDS ��������֧�� Ansi���� CheckUtf8 Ϊ True�� �� Utf8
    // �ڲ���ͳһת UTF8 ��ת UTF16 ���ж��ļ�����д�롣

{$IFDEF DELPHI_OTA}
    // TODO: ������������δ�� UTF8 ���䣬���Ƽ�ʹ��
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
{* ��װ������д�� Filer ���ļ����ݣ�Ҫ�������� BOM��β������ #0����ʽ Ansi��Ansi/Utf8��Utf16
  ����� BDS 2005 �� 2007 ���� Stream ������ Ansi ��ʽ������� IsAnsi ��Ϊ True
  ������ Ansi �� Utf8 ��ת�����ʺϱ༭�����壬������ļ�ģʽҲ�ڲ��Զ�������룬����ת����
  D5/6/7 �� Unicode �����»���� IsAnsi��Stream �е����ݱ���̶�Ϊ Ansi �� Utf16��
  Lazarus �����ݱ����� Utf8����� IsAnsi ��� True ʱ��Stream ���ݻ�ת���� Utf8��
  ������Ϊ�����ļ��Ǵ��̻��� IDE �ڲ��򿪾���ˡ�}

procedure EditFilerSaveFileToStream(const FileName: string; Stream: TStream; NeedAnsi: Boolean = False);
{* ��װ���� Filer �����ļ��������������о�Ϊ�� BOM ��ԭʼ��ʽ��Ansi��Ansi/Utf8��Utf16����β���� #0��
  �� Lazarus/BDS 2005 �� 2007 ��罫 NeedAnsi ��Ϊ True ʱ���ú����Ὣ Utf8 ��ת���� Ansi�����򱣳� Utf8��
  �� Unicode �����»���� NeedAnsi ����������� Stream �е����ݹ̶�Ϊ Utf16��
  ������Ϊ�����ļ��Ǵ��̻��� IDE �ڲ��򿪾���ˡ�}

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

  FBufSize := 32760; // D7 �����°汾�������ֵ����˻ᵼ�¶������󣬱��
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
  // ���� Editors ���Ƿ��и��ļ�
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
    // ������ View as Text ʱ���޷��õ�Դ��� SourceEditor �ӿ�
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

    // ע��˴����ݵı������ļ�����
{$IFDEF IDE_STRING_ANSI_UTF8}
    // D2005~2007 �£��� TCnWideStringList ����ļ����ݱ��벢����Ϊ UTF16
    List := TCnWideStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile);
      Utf16Text := List.Text;

      if CheckUtf8 then
        Text := AnsiString(Utf16Text)                // �ٸ��ݲ����� Utf16 תΪ Utf8
      else
        Text := CnUtf8EncodeWideString(Utf16Text);   // ��ֱ��תΪ AnsiString

      Stream.Write(Text[1], Length(Text) * SizeOf(AnsiChar));
      Stream.Write(TheEnd, 1);
    finally
      List.Free;
    end;
{$ELSE}
  {$IFDEF UNICODE}
    // D2009 �����ϣ���ϵͳ�Դ� TStringList ����ļ����ݱ��벢����Ϊ UTF16
    List := TStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile);
      Utf16Text := List.Text;

      if CheckUtf8 then
        Text := AnsiString(Utf16Text)                // �ٸ��ݲ����� Utf16 תΪ Utf8
      else
        Text := CnUtf8EncodeWideString(Utf16Text);   // ��ֱ��תΪ AnsiString

      Stream.Write(Text[1], Length(Text) * SizeOf(AnsiChar));
      Stream.Write(TheEnd, 1);
    finally
      List.Free;
    end
  {$ELSE}
    {$IFDEF LAZARUS}
    // Lazarus �£��� TCnWideStringList ����ļ����ݱ��벢����Ϊ UTF16
    List := TCnWideStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile);
      Utf16Text := List.Text;

      if CheckUtf8 then
        Text := AnsiString(Utf16Text)                // �ٸ��ݲ����� Utf16 תΪ Utf8
      else
        Text := CnUtf8EncodeWideString(Utf16Text);   // ��ֱ��תΪ AnsiString

      Stream.Write(Text[1], Length(Text) * SizeOf(AnsiChar));
      Stream.Write(TheEnd, 1);
    finally
      List.Free;
    end;
    {$ELSE}
    // D567��ֻ֧�� Ansi��������⴦��
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
      // ��������������� Utf8 ��ʽ�������� #0�������ַ�������Ϊβ���� #0 �ˣ������ٶ�һ��
      SetLength(Utf8Text, Stream.Size - 1);
      Stream.Position := 0;
      Stream.Read(Utf8Text[1], Stream.Size - 1);

      // ת�� Ansi
      Text := CnUtf8ToAnsi(PAnsiChar(Utf8Text));

      // ��д�� Stream���Ӹ� #0
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

    // Unicode �����£�Ҫ�����ļ��� BOM ת���� UTF16������ֱ�Ӹ����ļ���
    List := TStringList.Create;
    try
      List.LoadFromStream(FStreamFile); // �ڲ�������ļ� BOM ��¼����룬Ȼ��ת���� UTF16
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

    // ��������������� Utf8 ��ʽ�������� #0�������ַ�����β���� #0 �ˣ�ת Utf16 ��β��Ҳ�п� #0 ��
    SetLength(Utf8Text, Stream.Size);
    Stream.Position := 0;
    Stream.Read(Utf8Text[1], Stream.Size);
    Text := CnUtf8DecodeToWideString(Utf8Text);

    // д Stream ʱ��дһ�����ַ���д���� #0 ȥ
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
    // TODO: �ļ������ UTF8 ����
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
    // TODO: �ļ������ UTF8 ����
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

    // Unicode �����£�Ҫ�����ļ��� BOM ת�� UTF16 �� Stream ���ݣ�����ֱ�Ӹ����ļ���
    List := TStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile); // List ������ Utf16������¼���ļ�����

      // �� Stream �� Utf16 �������� Utf16Text �ٸ� List
      SetLength(Utf16Text, Stream.Size div 2);
      Stream.Position := 0;
      Stream.Read(Utf16Text[1], Length(Utf16Text) * SizeOf(WideChar));
      List.Text := Utf16Text;

      FStreamFile.Size := 0;
      List.SaveToStream(FStreamFile); // List ����ʱ����֮ǰ��¼���ļ�����ת���󱣴�
    finally
      List.Free;
    end;
  end
  else
  begin
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    FEditWrite.DeleteTo(MaxInt);

    // �ⲿ����� Utf16 ��ʽβ���޿� #0 ���ݣ�������Ҫ���Ͽ� #0 ת�� Utf8
    SetLength(Utf16Text, Stream.Size div 2);
    Stream.Position := 0;
    Stream.Read(Utf16Text[1], Length(Utf16Text) * SizeOf(WideChar));
    Utf8Text := CnUtf8EncodeWideString(Utf16Text);

    // Utf8 β���� #0���� FEditWrite.Insert һ����д�룬������ PAnsiChar �� #0 ��β
    if Length(Utf8Text) > 0 then
      FEditWrite.Insert(PAnsiChar(Utf8Text));
  end;
end;

{$ENDIF}

// �� Stream ����д���ļ��򻺳��У�����ԭ�����ݣ��� Stream �� Position �͹��λ���޹ء�
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
    // ���� Read/Write �����ݵ� AnsiText �� Utf8Text �У����� TMemoryStream ����
    Stream.Position := 0;
    if CheckUtf8 then
    begin
      // Stream ������ Ansi��һ��ȫ�������ת�� Utf8
      SetLength(AnsiText, Stream.Size);
      Stream.Read(AnsiText[1], Stream.Size);
      Utf8Text := CnAnsiToUtf8(AnsiText);
    end
    else
    begin
      // Stream ������ Utf8��һ��ȫ������
      SetLength(Utf8Text, Stream.Size);
      Stream.Read(Utf8Text[1], Stream.Size);
    end;
  end;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

{$IFDEF LAZARUS}
    // �� IDE_WIDE_CONTROL ��ķ� UNICODE ���ֵ�ͬ
    // ��ʱ Utf8Text ���� Utf8 ������ĩβ�� #0��Ҫת UTF16 �Էŵ� StringList ��
    Utf16Text := CnUtf8DecodeToWideString(Utf8Text);

    // D2005~2007 �£�Ҫ�� CnWideStringList ��ֵ����������ļ��� BOM��ת�� UTF16 ������д���ļ�
    List := TCnWideStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile); // List ������ Utf16������¼���ļ�����

      List.Text := Utf16Text;

      FStreamFile.Size := 0;
      List.SaveToStream(FStreamFile, List.LoadFormat); // List ����ʱ����֮ǰ��¼���ļ�����ת���󱣴�
    finally
      List.Free;
    end;
{$ELSE}
{$IFDEF IDE_WIDECONTROL}
    // ��ʱ Utf8Text ���� Utf8 ������ĩβ�� #0��Ҫת UTF16 �Էŵ� StringList ��
    Utf16Text := CnUtf8DecodeToWideString(Utf8Text);
  {$IFDEF UNICODE}
    // Unicode �����£�Ҫ�� StringList ��ֵ�������ڲ������ļ��� BOM��ת�� UTF16 ������д���ļ�
    List := TStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile); // List ������ Utf16������¼���ļ�����

      List.Text := Utf16Text;

      FStreamFile.Size := 0;
      List.SaveToStream(FStreamFile); // List ����ʱ����֮ǰ��¼���ļ�����ת���󱣴�
    finally
      List.Free;
    end;
  {$ELSE}
    // D2005~2007 �£�Ҫ�� CnWideStringList ��ֵ����������ļ��� BOM��ת�� UTF16 ������д���ļ�
    List := TCnWideStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile); // List ������ Utf16������¼���ļ�����

      List.Text := Utf16Text;

      FStreamFile.Size := 0;
      List.SaveToStream(FStreamFile, List.LoadFormat); // List ����ʱ����֮ǰ��¼���ļ�����ת���󱣴�
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
    // �ļ���״̬�£�д�� Utf8 ����
    if FEditor = nil then
      raise Exception.Create(SNoEditWriter);

    FEditor.Lines.Text := Utf8Text;
{$ELSE}
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    FEditWrite.DeleteTo(MaxInt);

{$IFDEF IDE_WIDECONTROL}
    // ��ʱ Utf8Text ���� Utf8 ������ĩβ�� #0�����ֿ飬ֱ��д��
    FEditWrite.Insert(PAnsiChar(Utf8Text));
{$ELSE}
    // D567 ���ճ��ֿ�д��
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

// �������ݸ��ǵ�ǰλ�õ��ı�
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

// �����ݲ��뵱ǰ�ı��ĵ�ǰλ�á�
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

