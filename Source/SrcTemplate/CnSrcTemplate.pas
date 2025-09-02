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

unit CnSrcTemplate;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�Դ����ģ��ר�ҵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.10.07 V1.1
*               �������ǰ Pascal ��Ԫÿ���������Ӵ���Ƭ�εĹ��ܣ����δ����
*           2005.08.22 V1.0
*               �� CnCodingToolsetWizard �з������
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCTEMPLATE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, IniFiles, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} Menus,
  OmniXML, OmniXMLPersistent, CnWizMultiLang, CnWizMacroUtils, CnWizClasses,
  CnConsts, CnWizConsts, CnWizUtils, CnWizManager {$IFDEF FPC} , LCLProc {$ENDIF}
  {$IFDEF BDS}, CnEditControlWrapper {$ENDIF};

type

{ TCnTemplateItem }

  TCnSrcTemplate = class;
  TCnTemplateCollection = class;

  TCnTemplateItem = class(TCollectionItem)
  private
    FEnabled: Boolean;
    FCaption: string;
    FIconName: string;
    FContent: string;
    FHint: string;
    FInsertPos: TCnEditorInsertPos;
    FShortCut: TShortCut;
    FActionIndex: Integer;
    FSavePos: Boolean;
    FCollection: TCnTemplateCollection;
    FForDelphi: Boolean;
    FForBcb: Boolean;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    property Collection: TCnTemplateCollection read FCollection;
  published
    property Enabled: Boolean read FEnabled write FEnabled;
    property ShortCut: TShortCut read FShortCut write FShortCut;
    property SavePos: Boolean read FSavePos write FSavePos;
    property InsertPos: TCnEditorInsertPos read FInsertPos write FInsertPos;
    property Caption: string read FCaption write FCaption;
    property Content: string read FContent write FContent;
    property Hint: string read FHint write FHint;
    property IconName: string read FIconName write FIconName;

    property ForDelphi: Boolean read FForDelphi write FForDelphi default {$IFDEF BCB5OR6} False {$ELSE} True {$ENDIF};
    property ForBcb: Boolean read FForBcb write FForBcb default {$IFDEF BDS} True {$ELSE} {$IFDEF DELPHI} False {$ELSE} True {$ENDIF} {$ENDIF};
  end;

{ TCnTemplateCollection }

  TCnTemplateCollection = class(TCollection)
  private
    FWizard: TCnSrcTemplate;
    function GetItems(Index: Integer): TCnTemplateItem;
    procedure SetItems(Index: Integer; const Value: TCnTemplateItem);
  protected
    property Wizard: TCnSrcTemplate read FWizard;
  public
    constructor Create(AWizard: TCnSrcTemplate);
    function LoadFromFile(const FileName: string): Boolean;
    function SaveToFile(const FileName: string): Boolean;
    function Add: TCnTemplateItem;
    property Items[Index: Integer]: TCnTemplateItem read GetItems write SetItems; default;
  end;

{ TCnSrcTemplate }

  TCnSrcTemplate = class(TCnSubMenuWizard)
  private
    FConfigIndex: Integer;
    FInsertToProcIndex: Integer;
    FInsertInitIndex: Integer;
    FLastIndexRef: Integer;
    FProcBatchCode: string;
    FInitBatchCode: string;
    FCollection: TCnTemplateCollection;
    FExecuting: Boolean;

    procedure UpdateActions;
    procedure DoExecute(Editor: TCnTemplateItem);
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure LoadCollection;
    procedure SaveCollection;

    procedure InsertCodeToProc;
    procedure InsertInitToUnits;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LanguageChanged(Sender: TObject); override;
    procedure AcquireSubActions; override;
    procedure Execute; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    property Collection: TCnTemplateCollection read FCollection;
  end;

{ TCnSrcTemplateForm }

  TCnSrcTemplateForm = class(TCnTranslateForm)
    grp1: TGroupBox;
    ListView: TListView;
    btnAdd: TButton;
    btnDelete: TButton;
    btnClear: TButton;
    btnEdit: TButton;
    btnUp: TButton;
    btnDown: TButton;
    btnImport: TButton;
    btnExport: TButton;
    btnHelp: TButton;
    btnOK: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormCreate(Sender: TObject);
  private
    FWizard: TCnSrcTemplate;
    FItemChanged: Boolean;
    procedure UpdateListViewItem(Index: Integer);
    procedure UpdateListView;
    procedure UpdateButtons;
  protected
    function GetHelpTopic: string; override;
  public
    property ItemChanged: Boolean read FItemChanged write FItemChanged;
    {* ��Ŀ�Ƿ�ı����������ʱʹ��}
  end;

const
  csEditorInsertPosDescs: array[TCnEditorInsertPos] of PString = (
    @SCnEIPCurrPos, @SCnEIPBOL, @SCnEIPEOL, @SCnEIPBOF, @SCnEIPEOF, @SCnEIPProcHead);

{$ENDIF CNWIZARDS_CNSRCTEMPLATE}

implementation

{$IFDEF CNWIZARDS_CNSRCTEMPLATE}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  mPasLex, CnSrcTemplateEditFrm, CnWizOptions, CnWizShortCut, CnCommon,
  CnWizMacroFrm, CnWizMacroText, CnWizCommentFrm, CnIDEStrings;

{$R *.DFM}

{ TCnTemplateItem }

procedure TCnTemplateItem.Assign(Source: TPersistent);
begin
  if Source is TCnTemplateItem then
  begin
    FEnabled := TCnTemplateItem(Source).FEnabled;
    FIconName := TCnTemplateItem(Source).FIconName;
    FContent := TCnTemplateItem(Source).FContent;
    FShortCut := TCnTemplateItem(Source).FShortCut;
    FCaption := TCnTemplateItem(Source).FCaption;
    FSavePos := TCnTemplateItem(Source).FSavePos;
    FHint := TCnTemplateItem(Source).FHint;
    FInsertPos := TCnTemplateItem(Source).FInsertPos;
  end
  else
    inherited Assign(Source);
end;

constructor TCnTemplateItem.Create(Collection: TCollection);
begin
  Assert(Collection is TCnTemplateCollection);
  inherited Create(Collection);
  FCollection := TCnTemplateCollection(Collection);
  FEnabled := True;
  FInsertPos := ipCurrPos;
  FSavePos := False;
  FActionIndex := -1;
  FIconName := SCnSrcTemplateIconName;

{$IFDEF FPC}
  FForDelphi := True;
{$ELSE}
{$IFDEF BDS}
  FForDelphi := True;
  FForBcb := True;
{$ELSE}
  {$IFDEF DELPHI}
  FForDelphi := True;
  {$ELSE}
  FForBcb := True;
  {$ENDIF}
{$ENDIF}
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.TraceObject(Self);
{$ENDIF}
end;

{ TCnTemplateCollection }

function TCnTemplateCollection.Add: TCnTemplateItem;
begin
  Result := TCnTemplateItem(inherited Add);
end;

constructor TCnTemplateCollection.Create(AWizard: TCnSrcTemplate);
begin
  inherited Create(TCnTemplateItem);
  FWizard := AWizard;
end;

function TCnTemplateCollection.GetItems(Index: Integer): TCnTemplateItem;
begin
  Result := TCnTemplateItem(inherited Items[Index]);
end;

procedure TCnTemplateCollection.SetItems(Index: Integer;
  const Value: TCnTemplateItem);
begin
  inherited Items[Index] := Value;
end;

function TCnTemplateCollection.LoadFromFile(const FileName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  try
    if not FileExists(FileName) then
      Exit;

    TOmniXMLReader.LoadFromFile(Self, FileName);
    // �ֲ� XML �����ַ�����ʱ�� #13#10 ��� #10 �����⡣LiuXiao
    for I := 0 to Count - 1 do
    begin
      Items[I].Content := StringReplace(Items[I].Content, #10, #13#10, [rfReplaceAll]);
      Items[I].Content := StringReplace(Items[I].Content, #13#13, #13, [rfReplaceAll]);
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function TCnTemplateCollection.SaveToFile(const FileName: string): Boolean;
begin
  try
    TOmniXMLWriter.SaveToFile(Self, FileName, pfAuto, ofIndent);
    Result := True;
  except
    Result := False;
  end;
end;

{ TCnSrcTemplate }

procedure TCnSrcTemplate.Config;
begin
  inherited;
  with TCnSrcTemplateForm.Create(nil) do
  try
    ShowModal;
    DoSaveSettings;
    if ItemChanged then
      SaveCollection;
  finally
    Free;
  end;

  UpdateActions;
end;

constructor TCnSrcTemplate.Create;
begin
  inherited;
  FCollection := TCnTemplateCollection.Create(Self);
end;

destructor TCnSrcTemplate.Destroy;
begin
  FCollection.Free;
  inherited;
end;

procedure TCnSrcTemplate.DoExecute(Editor: TCnTemplateItem);
var
  MacroText: TCnWizMacroText;
  Content: string;
  AIcon: TIcon;
  CursorPos: Integer;
begin
  if FExecuting then Exit;
  
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnSrcTemplate.DoExecute');
{$ENDIF}

  FExecuting := True;
  MacroText := TCnWizMacroText.Create(Editor.FContent);
  try
    if MacroText.Macros.Count > 0 then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogStrings(MacroText.Macros, 'UserMacros');
    {$ENDIF}
      if (Editor.FActionIndex >= 0) and not SubActions[Editor.FActionIndex].Icon.Empty then
        AIcon := SubActions[Editor.FActionIndex].Icon
      else
        AIcon := Icon;
      if not GetEditorMacroValue(MacroText.Macros, Editor.FCaption, AIcon) then
        Exit;
    end;
    CursorPos := 0;
    Content := MacroText.OutputText(CursorPos);
    EdtInsertTextToCurSource(Content, Editor.FInsertPos, Editor.FSavePos, CursorPos);
  finally
    MacroText.Free;
    FExecuting := False;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnSrcTemplate.DoExecute');
{$ENDIF}
end;

procedure TCnSrcTemplate.Execute;
begin

end;

function TCnSrcTemplate.GetCaption: string;
begin
  Result := SCnSrcTemplateMenuCaption;
end;

function TCnSrcTemplate.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnSrcTemplate.GetHint: string;
begin
  Result := SCnSrcTemplateMenuHint;
end;

function TCnSrcTemplate.GetState: TWizardState;
begin
  if Active then 
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnSrcTemplate.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnSrcTemplateName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnSrcTemplateComment;
end;

procedure TCnSrcTemplate.LanguageChanged(Sender: TObject);
begin
  inherited;
  LoadCollection;
  if Active then
    UpdateActions;
end;

procedure TCnSrcTemplate.LoadCollection;
begin
  if not FCollection.LoadFromFile(WizOptions.GetUserFileName(SCnSrcTemplateDataName,
    True, SCnSrcTemplateDataDefName)) then
    ErrorDlg(SCnSrcTemplateReadDataError);
end;

procedure TCnSrcTemplate.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  LoadCollection;
{$IFDEF DEBUG}
  CnDebugger.TraceCollection(FCollection);
{$ENDIF}
end;

procedure TCnSrcTemplate.SaveCollection;
begin
  if not FCollection.SaveToFile(WizOptions.GetUserFileName(SCnSrcTemplateDataName,
    False, SCnSrcTemplateDataDefName)) then
    ErrorDlg(SCnSrcTemplateWriteDataError);
  WizOptions.CheckUserFile(SCnSrcTemplateDataName, SCnSrcTemplateDataDefName);
end;

procedure TCnSrcTemplate.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnSrcTemplate.ResetSettings(Ini: TCustomIniFile);
begin
  WizOptions.CleanUserFile(SCnSrcTemplateDataName);
end;

procedure TCnSrcTemplate.SubActionExecute(Index: Integer);
var
  I: Integer;
begin
  inherited;
  if Index = FConfigIndex then
  begin
    Config;
  end
  else if Index = FInsertToProcIndex then
  begin
    InsertCodeToProc;
  end
  else if Index = FInsertInitIndex then
  begin
    InsertInitToUnits;
  end
  else
  begin
    for I := 0 to FCollection.Count - 1 do
    begin
      if FCollection[I].FEnabled and (FCollection[I].FActionIndex = Index) then
      begin
        DoExecute(FCollection[I]);
        Exit;
      end;
    end;
  end;
end;

procedure TCnSrcTemplate.SubActionUpdate(Index: Integer);
begin
  if Index > FConfigIndex then
  begin
    SubActions[Index].Enabled := Action.Enabled and CurrentIsSource;
    Exit;
  end;
  inherited;
end;

procedure TCnSrcTemplate.AcquireSubActions;
begin
  FConfigIndex := RegisterASubAction(SCnSrcTemplateConfigName,
    SCnSrcTemplateConfigCaption, 0, SCnSrcTemplateConfigHint,
    SCnSrcTemplateIconName);

  AddSepMenu;
  FInsertToProcIndex := RegisterASubAction(SCnSrcTemplateInsertToProcName,
    SCnSrcTemplateInsertToProcCaption, 0, SCnSrcTemplateInsertToProcHint);

  FInsertInitIndex := RegisterASubAction(SCnSrcTemplateInsertInitToUnitsName,
    SCnSrcTemplateInsertInitToUnitsCaption, 0, SCnSrcTemplateInsertInitToUnitsHint);

  FLastIndexRef := FInsertInitIndex;

  AddSepMenu;
  UpdateActions;
end;

procedure TCnSrcTemplate.UpdateActions;
var
  I: Integer;

  function ItemCanShow(Item: TCnTemplateItem): Boolean;
  begin
    Result := False;
    if Item = nil then
      Exit;
    if not Item.Enabled then
      Exit;

{$IFDEF FPC}
   Result := Item.ForDelphi;
{$ELSE}
{$IFDEF BDS}
   Result := Item.ForDelphi or Item.ForBcb;
{$ELSE}
  {$IFDEF DELPHI}
  Result := Item.ForDelphi;
  {$ELSE}
  Result := Item.ForBcb;
  {$ENDIF}
{$ENDIF}
{$ENDIF}
  end;
begin
  if not Active then
    Exit;

  WizShortCutMgr.BeginUpdate;
  try
    // ע����� Active Ϊ False���� FLastIndexRef ����Ϊ 0�������
    while SubActionCount > FLastIndexRef + 1 do
      DeleteSubAction(FLastIndexRef + 1);

    for I := 0 to FCollection.Count - 1 do
    begin
{$IFDEF DEBUG}
      CnDebugger.TraceObject(FCollection[I]);
{$ENDIF}
      if ItemCanShow(FCollection[I]) then
      begin
        with FCollection[I] do
        begin
          FActionIndex := RegisterASubAction(SCnSrcTemplateItem + IntToStr(I),
            FCaption, FShortCut, FHint, FIconName);
          SubActions[FActionIndex].ShortCut := FShortCut;
        end;
      end
      else
        FCollection[I].FActionIndex := -1;
    end;
  finally
    WizShortCutMgr.EndUpdate;
  end;
end;

function TCnSrcTemplate.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '��,macro,template';
end;

procedure TCnSrcTemplate.InsertCodeToProc;
const
  PROC_NAME = '%ProcName%';
  DEF_PROC_CODE = '  CnDebugger.LogMsg(''%ProcName%'');';
var
  I, J: Integer;
  S, T, ProcName: string;
  EditView: TCnEditViewSourceInterface;
  Stream: TMemoryStream;
  PasParser: TCnGeneralPasStructParser;
  CharPos: TOTACharPos;
  AfterToken, Token: TCnGeneralPasToken;
  ProcNames: TStringList;
  Lines, Cols: TList;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

{$IFDEF DELPHI_OTA}
  S := EditView.Buffer.FileName;
{$ENDIF}
{$IFDEF LAZARUS}
  S := EditView.FileName;
{$ENDIF}
  if not IsDprOrPas(S) and not IsInc(S) then
  begin
    ErrorDlg(SCnSrcTemplateSourceTypeNotSupport);
    Exit;
  end;

  if FProcBatchCode = '' then
    FProcBatchCode := DEF_PROC_CODE;
  S := CnWizInputMultiLineBox(SCnInformation, SCnSrcTemplateInsertToProcPrompt, FProcBatchCode);
  if S = '' then
    Exit;

  FProcBatchCode := S;

  PasParser := nil;
  Stream := nil;
  ProcNames := nil;
  Lines := nil;
  Cols := nil;

  try
    PasParser := TCnGeneralPasStructParser.Create;
    Stream := TMemoryStream.Create;
    ProcNames := TStringList.Create;
    Lines := TList.Create;
    Cols := TList.Create;

{$IFDEF BDS}
    PasParser.UseTabKey := True;
    PasParser.TabWidth := EditControlWrapper.GetTabWidth;;
{$ENDIF}

{$IFDEF DELPHI_OTA}
    S := EditView.Buffer.FileName;
    CnGeneralSaveEditorToStream(EditView.Buffer, Stream);
{$ENDIF}
{$IFDEF LAZARUS}
    S := EditView.FileName;
    CnGeneralSaveEditorToStream(EditView, Stream);
{$ENDIF}

    // ������ǰ��ʾ��Դ�ļ�
    CnGeneralPasParserParseSource(PasParser, Stream, IsDpr(S) {$IFDEF LAZARUS} or IsLpr(S) {$ENDIF}, False);
    CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
    PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

    // ��Ҫ��������ݺ�λ��
    for I := 0 to PasParser.Count - 1 do
    begin
      Token := PasParser.Tokens[I];
      if Token.IsMethodStart and (Token.TokenID <> tkBegin)then
      begin
        // �� Procedure/Function ��
        ProcName := '';
        if I < PasParser.Count - 1 then
        begin
          J := 1;
          AfterToken := PasParser.Tokens[I + J];
          while AfterToken.TokenID in [tkIdentifier, tkPoint] do
          begin
            ProcName := ProcName + AfterToken.Token;
            Inc(J);
            if I + J >= PasParser.Count - 1 then
              Break;
            AfterToken := PasParser.Tokens[I + J];
          end;
        end;

        if ProcName = '' then // �������������
          ProcName := '<Unknown>';

        // ProceNames ���ܳ��� Lines
        if ProcNames.Count = Lines.Count then // ���������ȣ����ȼ�һ
          ProcNames.Add(ProcName)
        else if ProcNames.Count > Lines.Count then
        begin
          if ProcNames.Count = 0 then
            ProcNames.Add(ProcName)
          else // ��� ProcNames ���� Lines ������˵������ IFDEF ʱ��� procedure ��Ӧһ�� begin end ������
            ProcNames[ProcNames.Count - 1] := ProcName;
            // Ӧ����ǰ ProcName ȡ�����һ��
        end;
        Continue;
      end;

      if Token.IsMethodStart and (Token.TokenID = tkBegin) then
      begin
        Lines.Add(Pointer(Token.LineNumber + 2)); // �� 2 ����Ϊ 0 ��ʼ����һ��
        Cols.Add(Pointer(Token.CharIndex));

        // Lines ������ʱӦ���� ProcNames��������ڣ��� ProcNames Ҫ�ظ���ĩ��
        // �Ա����� IFDEF ʱһ�� procedure ��Ӧ��� begin end ������
        if Lines.Count > ProcNames.Count then
          ProcNames.Add(ProcNames[ProcNames.Count - 1]);
        Continue;
      end;
    end;

    for I := Lines.Count - 1 downto 0 do
    begin
      T := StringReplace(FProcBatchCode, PROC_NAME, ProcNames[I], [rfReplaceAll]);

      if Integer(Cols[I]) > 0 then      // �� begin ��������ͬ
        T := Spc(Integer(Cols[I])) + T;

      // �� T ���� Token ���ڵ��е���һ��
      CnOtaInsertSingleLine(Integer(Lines[I]), T);
    end;

    InfoDlg(Format(SCnSrcTemplateInsertToProcCountFmt, [Lines.Count]));
  finally
    Cols.Free;
    Lines.Free;
    ProcNames.Free;
    Stream.Free;
    PasParser.Free;
  end;
end;

procedure TCnSrcTemplate.InsertInitToUnits;
const
  UNIT_NAME = '%UnitName%';
  DEF_INIT_CODE = '  CnDebugger.LogMsg(''%UnitName%'');';
var
  S, F: string;
  FS: TStringList;
  I, C: Integer;

  procedure ProcessFile(const FileName: string; const Code: string);
  const
    CRLF = #13#10;
  var
    Stream, Dest: TMemoryStream;
    Lex: TCnGeneralWidePasLex;
    PosInit, PosFinal, PosEnd, LenInit, L: Integer;
    Str: TCnIdeTokenString;
  begin
    Stream := nil;
    Dest := nil;
    Lex := nil;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('SrcTemplate ProcessFile %s', [FileName]);
{$ENDIF}

    try
      Stream := TMemoryStream.Create;
      CnGeneralFilerSaveFileToStream(FileName, Stream);

      Lex := TCnGeneralWidePasLex.Create;
      Lex.Origin := Stream.Memory;

      PosInit := 0;
      PosFinal := 0;
      PosEnd := 0;
      LenInit := 0;

      while Lex.TokenID <> tkNull do
      begin
        case Lex.TokenID of
          tkInitialization:
            begin
              PosInit := Lex.TokenPos;  // ���һ�� initialization
              LenInit := Length(Lex.Token);
            end;
          tkFinalization:
            begin
              PosFinal := Lex.TokenPos;  // ���һ�� finalization
            end;
          tkEnd:
            begin
              PosEnd := Lex.TokenPos;    // ���һ�� end
            end;
        end;
        Lex.NextNoJunk;
      end;

      // ȷ������λ�ã��ֺü��������L ������ղ���λ��
      if PosInit > 0 then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('PosInit %d. InitLen %d', [PosInit, LenInit]);
{$ENDIF}

        // �� initialization��ֱ����������س������뼰����
        Str := TCnIdeTokenString(CRLF + Code + CRLF);
        L := PosInit + LenInit;
      end
      else if PosFinal > 0 then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('PosFinal %d.', [PosFinal]);
{$ENDIF}

        // û�� initialization��ֻ�� finalization������ǰ����� initialization �س��ʹ��뼰����
        Str := TCnIdeTokenString('initialization' + CRLF + Code + CRLF);
        L := PosFinal;
      end
      else if PosEnd > 0 then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('PosEnd %d.', [PosEnd]);
{$ENDIF}

        // initialization �� finalization ��û�У������һ�� end ǰ���� initialization �س��ʹ��뼰����
        Str := TCnIdeTokenString('initialization' + CRLF + Code + CRLF + CRLF);
        L := PosEnd;
      end
      else
        Exit;

      Dest := TMemoryStream.Create;
      Stream.Position := 0;
      Dest.CopyFrom(Stream, L * SizeOf(TCnIdeTokenChar));
      Dest.Write(Str[1], Length(Str) * SizeOf(TCnIdeTokenChar));
      Dest.CopyFrom(Stream, Stream.Size - (L + 1) * SizeOf(TCnIdeTokenChar));
      // +1 ��ȥ��ĩβ�� #0����Ϊ���治��Ҫ

      CnGeneralFilerLoadFileFromStream(FileName, Dest);
    finally
      Dest.Free;
      Stream.Free;
      Lex.Free;
    end;
  end;

begin
  FS := TStringList.Create;
  if not CnOtaGetProjectSourceFiles(FS, False) then
  begin
    ErrorDlg(SCnSrcTemplateErrorProjectSource);
    Exit;
  end;

  try
    if FInitBatchCode = '' then
      FInitBatchCode := DEF_INIT_CODE;
    S := CnWizInputMultiLineBox(SCnInformation, SCnSrcTemplateInsertInitToUnitsPrompt, FInitBatchCode);
    if S = '' then
      Exit;

    FInitBatchCode := S;

    // ѭ�������ļ�
    C := 0;
    for I := 0 to FS.Count - 1 do
    begin
      F := _CnChangeFileExt(_CnExtractFileName(FS[I]), '');
      S := StringReplace(FInitBatchCode, UNIT_NAME, F, [rfReplaceAll]); // ���ļ����滻����� S ׼������

      ProcessFile(FS[I], S);
      Inc(C);
    end;

    InfoDlg(Format(SCnSrcTemplateInsertInitToUnitsCountFmt, [C]));
  finally
    FS.Free;
  end;
end;

{ TCnSrcTemplateForm }

procedure TCnSrcTemplateForm.FormCreate(Sender: TObject);
begin
  inherited;
  FWizard := TCnSrcTemplate(CnWizardMgr.WizardByClass(TCnSrcTemplate));
  Assert(Assigned(FWizard));
  EnlargeListViewColumns(ListView);
  UpdateListView;
end;

procedure TCnSrcTemplateForm.UpdateListViewItem(Index: Integer);
begin
  with ListView.Items[Index] do
  begin
    Caption := FWizard.FCollection[Index].FCaption;
    SubItems.Clear;
    if FWizard.FCollection[Index].FEnabled then
      SubItems.Add(SCnEnabled)
    else
      SubItems.Add(SCnDisabled);
    SubItems.Add(ShortCutToText(FWizard.FCollection[Index].FShortCut));
  end;
end;

procedure TCnSrcTemplateForm.UpdateListView;
var
  I: Integer;
begin
  ListView.Items.Clear;
  for I := 0 to FWizard.FCollection.Count - 1 do
  begin
    ListView.Items.Add;
    UpdateListViewItem(I);
  end;
  ListView.Selected := ListView.TopItem;
  UpdateButtons;
end;

procedure TCnSrcTemplateForm.UpdateButtons;
var
  HasSelected: Boolean;
begin
  HasSelected := Assigned(ListView.Selected);
  btnDelete.Enabled := HasSelected;
  btnClear.Enabled := ListView.Items.Count > 0;
  btnEdit.Enabled := HasSelected;
  btnUp.Enabled := HasSelected and (ListView.Selected.Index > 0);
  btnDown.Enabled := HasSelected and (ListView.Selected.Index < ListView.Items.Count - 1);
end;

procedure TCnSrcTemplateForm.ListViewChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  UpdateButtons;
end;

procedure TCnSrcTemplateForm.btnAddClick(Sender: TObject);
var
  ACaption: string;
  AHint: string;
  AIconName: string;
  AShortCut: TShortCut;
  AInsertPos: TCnEditorInsertPos;
  AEnabled: Boolean;
  ASavePos: Boolean;
  AContent: string;
  AForDelphi: Boolean;
  AForBcb: Boolean;
begin
  ACaption := '';
  AHint := '';
  AIconName := '';
  AShortCut := 0;
  AInsertPos := ipCurrPos;
  AEnabled := True;
  ASavePos := False;
  AContent := '';

{$IFDEF FPC}
  AForDelphi := True;
  AForBcb := False;
{$ENDIF}
{$IFDEF BDS}
  AForDelphi := True;
  AForBcb := True;
{$ELSE}
  {$IFDEF DELPHI}
  AForDelphi := True;
  AForBcb := False;
  {$ELSE}
  AForDelphi := False;
  AForBcb := True;
  {$ENDIF}
{$ENDIF}

  if ShowEditorEditForm(ACaption, AHint, AIconName, AShortCut, AInsertPos,
    AEnabled, ASavePos, AContent, AForDelphi, AForBcb) then
  begin
    with FWizard.FCollection.Add do
    begin
      FCaption := ACaption;
      FHint := AHint;
      FIconName := AIconName;
      FShortCut := AShortCut;
      FInsertPos := AInsertPos;
      FEnabled := AEnabled;
      FSavePos := ASavePos;
      FContent := AContent;
      FForDelphi := AForDelphi;
      FForBcb := AForBcb;
      ListView.Items.Add;
      UpdateListViewItem(ListView.Items.Count - 1);
      ListView.Selected := ListView.Items[ListView.Items.Count - 1];
      FItemChanged := True;
    end;
  end;
end;

procedure TCnSrcTemplateForm.btnDeleteClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := ListView.Selected;
  if not Assigned(Item) then Exit;
  if QueryDlg(SCnSrcTemplateWizardDelete) then
  begin
    FWizard.FCollection.Delete(Item.Index);
    Item.Free;
    UpdateButtons;
    FItemChanged := True;
  end;
end;

procedure TCnSrcTemplateForm.btnClearClick(Sender: TObject);
begin
  if QueryDlg(SCnSrcTemplateWizardClear) then
  begin
    ListView.Items.Clear;
    FWizard.FCollection.Clear;
    UpdateButtons;
    FItemChanged := True;
  end;
end;

procedure TCnSrcTemplateForm.btnEditClick(Sender: TObject);
begin
  if not Assigned(ListView.Selected) then Exit;
  if ShowEditorEditForm(FWizard.FCollection[ListView.Selected.Index]) then
  begin
    UpdateListViewItem(ListView.Selected.Index);
    UpdateButtons;
    FItemChanged := True;
  end;
end;

procedure TCnSrcTemplateForm.btnUpClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := ListView.Selected;
  if Assigned(Item) and (Item.Index > 0) then
  begin
    FWizard.FCollection[Item.Index].Index := Item.Index - 1;
    UpdateListViewItem(Item.Index - 1);
    UpdateListViewItem(Item.Index);
    ListView.Selected := ListView.Items[Item.Index - 1];
    UpdateButtons;
    FItemChanged := True;
  end;
end;

procedure TCnSrcTemplateForm.btnDownClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := ListView.Selected;
  if Assigned(Item) and (Item.Index < ListView.Items.Count - 1) then
  begin
    FWizard.FCollection[Item.Index].Index := Item.Index + 1;
    UpdateListViewItem(Item.Index + 1);
    UpdateListViewItem(Item.Index);
    ListView.Selected := ListView.Items[Item.Index + 1];
    UpdateButtons;
    FItemChanged := True;
  end;
end;

procedure TCnSrcTemplateForm.btnImportClick(Sender: TObject);
var
  EditorCollection: TCnTemplateCollection;
begin
  if OpenDialog.FileName = '' then
    OpenDialog.FileName := WizOptions.GetUserFileName(SCnSrcTemplateDataName,
      True, SCnSrcTemplateDataDefName);
  if OpenDialog.Execute then
  begin
    EditorCollection := TCnTemplateCollection.Create(nil);
    try
      if EditorCollection.LoadFromFile(OpenDialog.FileName) then
      begin
        if QueryDlg(SCnSrcTemplateImportAppend) then
        begin
          while EditorCollection.Count > 0 do
          begin
            FWizard.FCollection.Add.Assign(EditorCollection.Items[0]);
            EditorCollection.Delete(0);
          end;
        end
        else
        begin
          FWizard.FCollection.Assign(EditorCollection);
        end;
        UpdateListView;
        FItemChanged := True;
      end
      else
        ErrorDlg(SCnSrcTemplateReadDataError);
    finally
      EditorCollection.Free;
    end;
  end;
end;

procedure TCnSrcTemplateForm.btnExportClick(Sender: TObject);
begin
  if SaveDialog.FileName = '' then
    SaveDialog.FileName := WizOptions.GetUserFileName(SCnSrcTemplateDataName,
      False, SCnSrcTemplateDataDefName);
  if SaveDialog.Execute then
  begin
    if not FWizard.FCollection.SaveToFile(SaveDialog.FileName) then
      ErrorDlg(SCnSrcTemplateWriteDataError);
  end;
end;

procedure TCnSrcTemplateForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnSrcTemplateForm.GetHelpTopic: string;
begin
  Result := 'CnSrcTemplate';
end;

initialization
  RegisterCnWizard(TCnSrcTemplate); // ע��ר��

{$ENDIF CNWIZARDS_CNSRCTEMPLATE}
end.
