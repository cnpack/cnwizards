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

unit CnEditorExtractString;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ���Դ���г�ȡ�ַ�����Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2023.02.10 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ToolsAPI,
  TypInfo, StdCtrls, ExtCtrls, ComCtrls, IniFiles, Clipbrd, Buttons, ActnList, Menus,
  CnConsts, CnCommon, CnHashMap, CnWizConsts, CnWizUtils, CnCodingToolsetWizard,
  CnWizMultiLang, CnEditControlWrapper, mPasLex, mwBCBTokenList, CnIDEStrings,
  CnPasCodeParser, CnCppCodeParser, CnWidePasParser, CnWideCppParser;

type
  TCnPasStringHeadType = (htVar, htConst, htResourcestring);

  TCnPasStringAreaType = (atInterface, atImplementation);

  TCnCppStringHeadType = (htCharPoint, htAnsiString);

  TCnEditorExtractString = class(TCnBaseCodingToolset)
  private
    FUseUnderLine: Boolean;
    FIgnoreSingleChar: Boolean;
    FMaxWords: Integer;
    FMaxPinYinWords: Integer;
    FPrefix: string;
    FIdentWordStyle: TCnIdentWordStyle;
    FUseFullPinYin: Boolean;
    FShowPreview: Boolean;
    FIgnoreSimpleFormat: Boolean;
    FEditStream: TMemoryStream;
    FPasParser: TCnGeneralPasStructParser;
    FCppParser: TCnGeneralCppStructParser;
    FTokenListRef: TCnIdeStringList;
    FBeforeImpl: Boolean;
    FPasToArea: Integer;
    FPasMakeType: Integer;
    FCppMakeType: Integer;
    function CanExtract(const S: PCnIdeTokenChar): Boolean;
  protected
    function GetSourceTokenStr(Token: TCnGeneralPasToken): TCnIdeTokenString;
    // �� Pas �� C/C++ ����Ч��Token �϶�ʱ�� Token ���ã�̫��ʱ�ӵ�ǰԴ�ļ����ڴ�������
    function ScanPas: Boolean;
    function ScanCpp: Boolean;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;

    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    function GetState: TWizardState; override;
    procedure Execute; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;

    function Scan: Boolean;
    {* ɨ�赱ǰԴ���е��ַ���������ɨ���Ƿ�ɹ���
    ���ڲ����� Stream/Parser���������� TokenListRef �У��Լ� FBeforeImpl}
    procedure MakeUnique;
    {* �� TokenListRef �е��ַ������ز����� 1 �Ⱥ�׺}
    function GeneratePasDecl(OutList: TCnIdeStringList; HeadType: TCnPasStringHeadType): Boolean;
    {* �� FTokenListRef ������ var �� const �������飬�ڲ�Ҫʹ�� FEditStream���������ݷ� OutList ��}
    function GenerateCppDecl(OutList: TCnIdeStringList; HeadType: TCnCppStringHeadType): Boolean;
    {* �� FTokenListRef ������ AnsiString �� char * �������飬�ڲ�Ҫʹ�� FEditStream���������ݷ� OutList ��}
    function Replace(AddCStr: Boolean = False): Integer;
    {* ���ַ����滻Ϊ���������������������ڲ�Ҫʹ�� FEditStream�������滻�ĸ����������� Pascal �� C/C++}
    function InsertPasDecl(Area: TCnPasStringAreaType; HeadType: TCnPasStringHeadType): Integer;
    {* ���������뵱ǰ Pascal Դ��ָ�����֡����ز��������}
    function InsertCppDecl(HeadType: TCnCppStringHeadType): Integer;
    {* ���������뵱ǰ C/C++ Դ��ָ�����֡����ز��������}

    procedure FreeTokens;
    {* ������Ϻ������������ͷ��ڴ�}
    property TokenListRef: TCnIdeStringList read FTokenListRef;
    {* ɨ�����������������}
    property BeforeImpl: Boolean read FBeforeImpl;
    {* �Ƿ����� implementation ֮ǰ���ַ���}

  published
    property IgnoreSingleChar: Boolean read FIgnoreSingleChar write FIgnoreSingleChar;
    {* ɨ��ʱ�Ƿ���Ե��ַ����ַ���}
    property IgnoreSimpleFormat: Boolean read FIgnoreSimpleFormat write FIgnoreSimpleFormat;
    {* ɨ��ʱ�Ƿ���Լ򵥵ĸ�ʽ���ַ���}

    property Prefix: string read FPrefix write FPrefix;
    {* ���ɵı�������ǰ׺����Ϊ�գ������Ƽ�}
    property UseUnderLine: Boolean read FUseUnderLine write FUseUnderLine;
    {* �������ķִ��Ƿ�ʹ���»�����Ϊ�ָ���}
    property IdentWordStyle: TCnIdentWordStyle read FIdentWordStyle write FIdentWordStyle;
    {* �������ķִʷ��ȫ��д����ȫСд��������ĸ��д���Сд}
    property UseFullPinYin: Boolean read FUseFullPinYin write FUseFullPinYin;
    {* ��������ʱ��ʹ��ȫƴ����ƴ������ĸ��True Ϊǰ��}
    property MaxPinYinWords: Integer read FMaxPinYinWords write FMaxPinYinWords;
    {* ����ƴ���ִʸ���}
    property MaxWords: Integer read FMaxWords write FMaxWords;
    {* ������ͨӢ�ķִʸ���}
    property ShowPreview: Boolean read FShowPreview write FShowPreview;
    {* �Ƿ���ʾԤ������}
    property PasMakeType: Integer read FPasMakeType write FPasMakeType;
    {* ���ɵ� Pascal �ַ��������� var ���� const ���� resourcestring}
    property PasToArea: Integer read FPasToArea write FPasToArea;
    {* ���ɵ� Pascal �ַ������������� interface ���� implementation}
    property CppMakeType: Integer read FCppMakeType write FCppMakeType;
    {* ���ɵ� C/C++ �ַ��������� AnsiString ���� char *}
  end;

  TCnExtractStringForm = class(TCnTranslateForm)
    grpScanOption: TGroupBox;
    chkIgnoreSingleChar: TCheckBox;
    chkIgnoreSimpleFormat: TCheckBox;
    grpPinYinOption: TGroupBox;
    lblPinYin: TLabel;
    cbbPinYinRule: TComboBox;
    btnReScan: TButton;
    pnl1: TPanel;
    lvStrings: TListView;
    mmoPreview: TMemo;
    spl1: TSplitter;
    cbbMakeType: TComboBox;
    lblMake: TLabel;
    lblToArea: TLabel;
    cbbToArea: TComboBox;
    btnHelp: TButton;
    btnReplace: TButton;
    btnClose: TButton;
    lblPrefix: TLabel;
    edtPrefix: TEdit;
    lblStyle: TLabel;
    cbbIdentWordStyle: TComboBox;
    lblMaxWords: TLabel;
    edtMaxWords: TEdit;
    udMaxWords: TUpDown;
    lblMaxPinYin: TLabel;
    edtMaxPinYin: TEdit;
    udMaxPinYin: TUpDown;
    chkUseUnderLine: TCheckBox;
    chkShowPreview: TCheckBox;
    btnCopy: TSpeedButton;
    actlstExtract: TActionList;
    actRescan: TAction;
    actCopy: TAction;
    actReplace: TAction;
    actEdit: TAction;
    actDelete: TAction;
    pmStrings: TPopupMenu;
    Edit1: TMenuItem;
    Delete1: TMenuItem;
    procedure chkShowPreviewClick(Sender: TObject);
    procedure lvStringsData(Sender: TObject; Item: TListItem);
    procedure FormCreate(Sender: TObject);
    procedure lvStringsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvStringsDblClick(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actRescanExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actlstExtractUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure actDeleteExecute(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    FTool: TCnEditorExtractString;
    procedure UpdateTokenToListView;
    procedure LoadSettings;
    procedure SaveSettings;
  protected
    function GetHelpTopic: string; override;
  public
    property Tool: TCnEditorExtractString read FTool write FTool;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  CnPasSourceStringPosKinds: TCodePosKinds = [pkField, pkProcedure, pkFunction,
    pkConstructor, pkDestructor, pkFieldDot];

  CnCppSourceStringPosKinds: TCodePosKinds = [pkField, pkProcedure, pkFunction,
    pkConstructor, pkDestructor, pkFieldDot];

  SCN_PAS_HEAD_STRS: array[TCnPasStringHeadType] of string = ('var', 'const', 'resourcestring');

  SCN_PAS_AREA_STRS: array[TCnPasStringAreaType] of string = ('interface', 'implementation');

  SCN_CPP_HEAD_STRS: array[TCnCppStringHeadType] of string = ('char *', 'AnsiString');

  CN_DEF_MAX_WORDS = 6;

{ TCnExtractStringForm }

procedure TCnExtractStringForm.chkShowPreviewClick(Sender: TObject);
begin
  mmoPreview.Visible := chkShowPreview.Checked;
  // spl1.Visible := chkShowPreview.Checked;
end;

procedure TCnExtractStringForm.UpdateTokenToListView;
begin
  lvStrings.Items.Count := FTool.FTokenListRef.Count;
  lvStrings.Invalidate;
end;

procedure TCnExtractStringForm.lvStringsData(Sender: TObject;
  Item: TListItem);
var
  Token: TCnGeneralPasToken;
begin
  if (Item.Index >= 0) and (Item.Index < FTool.TokenListRef.Count) then
  begin
    Token := TCnGeneralPasToken(FTool.TokenListRef.Objects[Item.Index]);
    Item.Caption := IntToStr(Item.Index + 1);
    Item.Data := Token;

    with Item.SubItems do
    begin
      Add(FTool.TokenListRef[Item.Index]);
      Add(FTool.GetSourceTokenStr(Token));
    end;
  end;
end;

procedure TCnExtractStringForm.LoadSettings;
begin
  if FTool = nil then
    Exit;

  edtPrefix.Text := FTool.Prefix;
  cbbIdentWordStyle.ItemIndex := Ord(FTool.IdentWordStyle);
  if FTool.UseFullPinYin then
    cbbPinYinRule.ItemIndex := 1
  else
    cbbPinYinRule.ItemIndex := 0;
  udMaxWords.Position := FTool.MaxWords;
  udMaxPinYin.Position := FTool.MaxPinYinWords;
  chkUseUnderLine.Checked := FTool.UseUnderLine;
  chkIgnoreSingleChar.Checked := FTool.IgnoreSingleChar;
  chkIgnoreSimpleFormat.Checked := FTool.IgnoreSimpleFormat;
  chkShowPreview.Checked := FTool.ShowPreview;
  cbbMakeType.ItemIndex := FTool.PasMakeType;
  cbbToArea.ItemIndex := FTool.PasToArea;
end;

procedure TCnExtractStringForm.SaveSettings;
begin
  if FTool = nil then
    Exit;

  FTool.Prefix := edtPrefix.Text;
  FTool.IdentWordStyle := TCnIdentWordStyle(cbbIdentWordStyle.ItemIndex);
  FTool.UseFullPinYin := cbbPinYinRule.ItemIndex = 1;

  FTool.MaxWords := udMaxWords.Position;
  FTool.MaxPinYinWords := udMaxPinYin.Position;
  FTool.UseUnderLine := chkUseUnderLine.Checked;
  FTool.IgnoreSingleChar := chkIgnoreSingleChar.Checked;
  FTool.IgnoreSimpleFormat := chkIgnoreSimpleFormat.Checked;
  FTool.ShowPreview := chkShowPreview.Checked;
  FTool.PasMakeType := cbbMakeType.ItemIndex;
  FTool.PasToArea := cbbToArea.ItemIndex;
end;

procedure TCnExtractStringForm.FormCreate(Sender: TObject);
var
  EditorCanvas: TCanvas;
  I: TCnPasStringHeadType;
  J: TCnPasStringAreaType;
  K: TCnCppStringHeadType;
begin
  btnCopy.Caption := '';

  if CurrentIsDelphiSource then
  begin
    for I := Low(SCN_PAS_HEAD_STRS) to High(SCN_PAS_HEAD_STRS) do
      cbbMakeType.Items.Add(SCN_PAS_HEAD_STRS[I]);
    for J := Low(SCN_PAS_AREA_STRS) to High(SCN_PAS_AREA_STRS) do
      cbbToArea.Items.Add(SCN_PAS_AREA_STRS[J]);
  end
  else if CurrentIsCSource then
  begin
    for K := Low(SCN_CPP_HEAD_STRS) to High(SCN_CPP_HEAD_STRS) do
      cbbMakeType.Items.Add(SCN_CPP_HEAD_STRS[K]);
    lblToArea.Enabled := False;
    cbbToArea.Enabled := False;
  end;

  cbbMakeType.ItemIndex := 0;
  cbbToArea.ItemIndex := 0;

  EditorCanvas := EditControlWrapper.GetEditControlCanvas(CnOtaGetCurrentEditControl);
  if EditorCanvas <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Get EditConrol Canvas Font ' + EditorCanvas.Font.Name);
{$ENDIF}
    if EditorCanvas.Font.Name <> mmoPreview.Font.Name then
      mmoPreview.Font.Name := EditorCanvas.Font.Name;
    mmoPreview.Font.Size := EditorCanvas.Font.Size;
    mmoPreview.Font.Style := EditorCanvas.Font.Style - [fsUnderline, fsStrikeOut, fsItalic];
  end;
end;

procedure TCnExtractStringForm.lvStringsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
const
  CnBeforeLine = 1;
  CnAfterLine = 4;
var
  Token: TCnGeneralPasToken;
begin
  if not Selected or (Item = nil) or (Item.Data = nil) then
    Exit;

  Token := TCnGeneralPasToken(Item.Data);
  mmoPreview.Lines.Text := CnOtaGetLineText(Token.EditLine - CnBeforeLine,
    nil, CnBeforeLine + CnAfterLine);
end;

function TCnExtractStringForm.GetHelpTopic: string;
begin
  Result := 'CnEditorExtractString';
end;

procedure TCnExtractStringForm.lvStringsDblClick(Sender: TObject);
begin
  actEdit.Execute;
end;

procedure TCnExtractStringForm.actCopyExecute(Sender: TObject);
var
  L: TCnIdeStringList;
  PHT: TCnPasStringHeadType;
  CHT: TCnCppStringHeadType;
begin
  if (FTool.TokenListRef = nil) or (FTool.TokenListRef.Count <= 0) then
    Exit;

  L := TCnIdeStringList.Create;
  try
    if CurrentIsDelphiSource then
    begin
      PHT := TCnPasStringHeadType(cbbMakeType.ItemIndex);
      if FTool.GeneratePasDecl(L, PHT) then
      begin
        Clipboard.AsText := L.Text;
        InfoDlg(Format(SCnEditorExtractStringCopiedFmt, [L.Count - 1, SCN_PAS_HEAD_STRS[PHT]]));
      end;
    end
    else if CurrentIsCSource then
    begin
      CHT := TCnCppStringHeadType(cbbMakeType.ItemIndex);
      if FTool.GenerateCppDecl(L, CHT) then
      begin
        Clipboard.AsText := L.Text;
        InfoDlg(Format(SCnEditorExtractStringCopiedFmt, [L.Count - 1, SCN_CPP_HEAD_STRS[CHT]]));
      end;
    end;
  finally
    L.Free;
  end;
end;

procedure TCnExtractStringForm.actRescanExecute(Sender: TObject);
begin
  if FTool = nil then
    Exit;

  SaveSettings;
  if FTool.Scan then
  begin
    if FTool.TokenListRef.Count <= 0 then
    begin
      ErrorDlg(SCnEditorExtractStringNotFound);
      Exit;
    end;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Rescan OK. To Make Unique.');
{$ENDIF}

    FTool.MakeUnique;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('Make Unique OK. Update To ListView.');
{$ENDIF}

    if FTool.BeforeImpl then
      cbbToArea.ItemIndex := Ord(atInterface)
    else
      cbbToArea.ItemIndex := Ord(atImplementation);

    UpdateTokenToListView;
  end;
end;

procedure TCnExtractStringForm.actEditExecute(Sender: TObject);
var
  Idx, K: Integer;
  S, OldName, OldValue: string;
  Token: TCnGeneralPasToken;
begin
  if lvStrings.Selected = nil then
    Exit;

  Idx := lvStrings.Selected.Index;
  if (Idx < 0) or (Idx >= FTool.TokenListRef.Count) then
    Exit;

  S := FTool.TokenListRef[Idx];
  OldName := S;
  Token := TCnGeneralPasToken(FTool.TokenListRef.Objects[Idx]);
  if Token <> nil then
    OldValue := Token.Token
  else
    OldValue := '';

  if CnWizInputQuery(SCnEditorExtractStringChangeName, SCnEditorExtractStringEnterNewName, S) then
  begin
    if (S <> OldName) and (S <> '') then
    begin
      // �õ������ֺ;�ֵ����������������������ֺͲ�ͬ�ھ�ֵ�ģ������˳���
      // ����ж�������־�ֵ���򶼸��ĳ�������
      for K := 0 to FTool.TokenListRef.Count - 1 do
      begin
        if (FTool.TokenListRef[K] = S) then // ����������������
        begin
          Token := TCnGeneralPasToken(FTool.TokenListRef.Objects[K]);
          if Token.Token <> OldValue then   // ����ֵ�����ھ�ֵ
          begin
            ErrorDlg(SCnEditorExtractStringDuplicatedName);
            Exit;
          end;
        end;
      end;

      for K := 0 to FTool.TokenListRef.Count - 1 do
      begin
        if (FTool.TokenListRef[K] = OldName) then // ���������ھ�����
        begin
          Token := TCnGeneralPasToken(FTool.TokenListRef.Objects[K]);
          if Token.Token = OldValue then          // ����ֵ���ھ�ֵ
          begin
            FTool.TokenListRef[K] := S;           // �򶼸ĳ�������
          end;
        end;
      end;

      lvStrings.Invalidate;
    end;
  end;
end;

procedure TCnExtractStringForm.actReplaceExecute(Sender: TObject);
var
  N, S: Integer;
begin
  if not QueryDlg(SCnEditorExtractStringAskReplace) then
    Exit;

  if CurrentIsCSource and (TCnCppStringHeadType(cbbMakeType.ItemIndex) = htAnsiString) then
    N := FTool.Replace(True)
  else
    N := FTool.Replace;

  if N > 0 then
  begin
    S := 0;
    if CurrentIsDelphiSource then
      S := FTool.InsertPasDecl(TCnPasStringAreaType(cbbToArea.ItemIndex),
        TCnPasStringHeadType(cbbMakeType.ItemIndex))
    else if CurrentIsCSource then
      S := FTool.InsertCppDecl(TCnCppStringHeadType(cbbMakeType.ItemIndex));

    if S > 0 then
    begin
      InfoDlg(Format(SCnEditorExtractStringReplacedFmt, [N, S]));
      Close;
    end;
  end;
end;

procedure TCnExtractStringForm.actlstExtractUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if (Action = actEdit) or (Action = actDelete) then
    (Action as TCustomAction).Enabled := lvStrings.Selected <> nil
  else if {(Action = actCopy) or } (Action = actReplace) then
    (Action as TCustomAction).Enabled := lvStrings.Items.Count > 0
  else if Action = actRescan then
    (Action as TCustomAction).Enabled := CurrentIsSource;
end;

procedure TCnExtractStringForm.actDeleteExecute(Sender: TObject);
var
  Idx: Integer;
begin
  if lvStrings.Selected = nil then
    Exit;

  Idx := lvStrings.Selected.Index;
  if (Idx < 0) or (Idx >= FTool.TokenListRef.Count) then
    Exit;

  FTool.TokenListRef.Delete(Idx);
  UpdateTokenToListView;

  if FTool.TokenListRef.Count = 0 then
    mmoPreview.Lines.Clear;
end;

procedure TCnExtractStringForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

{ TCnEditorExtractString }

function TCnEditorExtractString.CanExtract(const S: PCnIdeTokenChar): Boolean;
var
  L: Integer;
begin
  Result := False;
{$IFDEF IDE_STRING_ANSI_UTF8} // �� Unicode ����������� PWideChar �󳤶ȣ�ֻ���� Windows API
  L := lstrlenW(S);
{$ELSE}
  L := StrLen(S);             // �� Unicode ����������� PAnsiChar �󳤶ȣ��Լ� Unicode ����������� PWideChar �󳤶�
{$ENDIF}
  if L <= 2 then // �����Ż�ȫ������
    Exit;

  if FIgnoreSingleChar and (L = 3) and (S[0] = '''') and (S[2] = '''') then // �����ַ�Ҳ����
    Exit;

  if FIgnoreSingleChar and (L = 3) and (S[0] = '"') and (S[2] = '"') then // �����ַ�Ҳ����
    Exit;

  if FIgnoreSingleChar and (L = 4) and (S[0] = '''') and (S[1] = '''')
    and (S[2] = '''') and (S[2] = '''') then // ����������Ҳ����
    Exit;

  if FIgnoreSimpleFormat and IsSimpleFormat(S) then
    Exit;

  Result := True;
end;

constructor TCnEditorExtractString.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  FIdentWordStyle := iwsUpperCase;
  FPrefix := 'S';
  FMaxWords := CN_DEF_MAX_WORDS;
  FMaxPinYinWords := CN_DEF_MAX_WORDS;
  FUseUnderLine := True;
  FIgnoreSingleChar := True;
  FIgnoreSimpleFormat := True;
  FShowPreview := True;
end;

destructor TCnEditorExtractString.Destroy;
begin
  FTokenListRef.Free;
  FPasParser.Free;
  FCppParser.Free;
  FEditStream.Free;
  inherited;
end;

procedure TCnEditorExtractString.Execute;
var
  EditView: IOTAEditView;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  with TCnExtractStringForm.Create(Application) do
  begin
    Tool := Self;
    LoadSettings;

    if ShowModal = mrOK then
    begin
      SaveSettings;

    end;

    Free;
  end;
end;

procedure TCnEditorExtractString.FreeTokens;
begin
  FreeAndNil(FTokenListRef);
  FreeAndNil(FPasParser);
  FreeAndNil(FCppParser);
  FreeAndNil(FEditStream);
end;

function TCnEditorExtractString.GeneratePasDecl(OutList: TCnIdeStringList;
  HeadType: TCnPasStringHeadType): Boolean;
var
  I, L: Integer;
  Token: TCnGeneralPasToken;
begin
  Result := False;
  if (OutList = nil) or (FTokenListRef = nil) or (FTokenListRef.Count <= 0) then
    Exit;

  L := EditControlWrapper.GetBlockIndent;
  OutList.Clear;
  OutList.Add(SCN_PAS_HEAD_STRS[HeadType]);

  if HeadType in [htVar] then
  begin
    for I := 0 to FTokenListRef.Count - 1 do
    begin
      Token := TCnGeneralPasToken(FTokenListRef.Objects[I]);
      OutList.Add(Spc(L) + FTokenListRef[I] + ': string = ' + GetSourceTokenStr(Token) + ';');
    end;
    RemoveDuplicatedStrings(OutList);
    Result := True;
  end
  else if HeadType in [htConst, htResourcestring] then
  begin
    for I := 0 to FTokenListRef.Count - 1 do
    begin
      Token := TCnGeneralPasToken(FTokenListRef.Objects[I]);
      OutList.Add(Spc(L) + FTokenListRef[I] + ' = ' + GetSourceTokenStr(Token) + ';');
    end;
    RemoveDuplicatedStrings(OutList);
    Result := True;
  end;
end;

function TCnEditorExtractString.GenerateCppDecl(OutList: TCnIdeStringList;
  HeadType: TCnCppStringHeadType): Boolean;
var
  I: Integer;
  Token: TCnGeneralCppToken;
begin
  Result := False;
  if (OutList = nil) or (FTokenListRef = nil) or (FTokenListRef.Count <= 0) then
    Exit;

  OutList.Clear;
  if HeadType in [htAnsiString] then
  begin
    for I := 0 to FTokenListRef.Count - 1 do
    begin
      Token := TCnGeneralCppToken(FTokenListRef.Objects[I]);
      OutList.Add('const AnsiString ' + FTokenListRef[I] + ' = ' + GetSourceTokenStr(Token) + ';');
    end;
    RemoveDuplicatedStrings(OutList);
    Result := True;
  end
  else if HeadType in [htCharPoint] then
  begin
    for I := 0 to FTokenListRef.Count - 1 do
    begin
      Token := TCnGeneralCppToken(FTokenListRef.Objects[I]);
      OutList.Add('const char * ' + FTokenListRef[I] + ' = ' + GetSourceTokenStr(Token) + ';');
    end;
    RemoveDuplicatedStrings(OutList);
    Result := True;
  end;
end;

function TCnEditorExtractString.GetCaption: string;
begin
  Result := SCnEditorExtractStringMenuCaption;
end;

function TCnEditorExtractString.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

procedure TCnEditorExtractString.GetToolsetInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorExtractStringName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorExtractString.GetHint: string;
begin
  Result := SCnEditorExtractStringMenuHint;
end;

function TCnEditorExtractString.GetSourceTokenStr(Token: TCnGeneralPasToken): TCnIdeTokenString;
var
  P: PByte;
begin
  Result := '';
  if (Token <> nil) and (Token.TokenLength > 0) then
  begin
    if Token.TokenLength < CN_TOKEN_MAX_SIZE then
      Result := TCnIdeTokenString(Token.Token)
    else if (FEditStream <> nil) and
      (FEditStream.Size >= (Token.TokenPos + Token.TokenLength) * SizeOf(Char)) then
    begin
      SetLength(Result, Token.TokenLength);
      P := FEditStream.Memory;
      Inc(P, Token.TokenPos * SizeOf(Char));
      Move(P^, Result[1], Token.TokenLength * SizeOf(Char));
    end;
  end;
end;

function TCnEditorExtractString.GetState: TWizardState;
begin
  Result := inherited GetState;
  if wsEnabled in Result then
  begin
    if not CurrentIsSource then
      Result := [];
  end;
end;

function TCnEditorExtractString.InsertPasDecl(Area: TCnPasStringAreaType;
  HeadType: TCnPasStringHeadType): Integer;
const
  KINDS: array[TCnPasStringAreaType] of TTokenKind = (tkInterface, tkImplementation);
var
  Lex: TCnGeneralWidePasLex;
  Stream: TMemoryStream;
  EditView: IOTAEditView;
  InsPos: Integer;
  Names: TCnIdeStringList;
  S: TCnIdeTokenString;
  EditWriter: IOTAEditWriter;
begin
  Result := 0;
  // �� interface �� implementation ��� uses �ķֺſգ�������������� uses��ֱ�Ӳ������

  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  Stream := nil;
  Lex := nil;
  Names := nil;

  try
    Stream := TMemoryStream.Create;
    CnGeneralSaveEditorToStream(EditView.Buffer, Stream); // Ansi/Wide/Wide

    Lex := TCnGeneralWidePasLex.Create;
    Lex.Origin := Stream.Memory;

    while (Lex.TokenID <> tkNull) and (Lex.TokenID <> KINDS[Area]) do
      Lex.NextNoJunk;

    if Lex.TokenID = tkNull then
      Exit;

    // �˿��ҵ��� interface �� implementation����¼��β��λ��
    InsPos := Lex.TokenPos + Length(Lex.Token);

    while (Lex.TokenID <> tkNull) and (Lex.TokenID <> tkUses) do
      Lex.NextNoJunk;

    if Lex.TokenID <> tkNull then
    begin
      // �˿��ҵ��� uses�����Һ���ĵ�һ���ֺ�
      while (Lex.TokenID <> tkNull) and (Lex.TokenID <> tkSemiColon) do
        Lex.NextNoJunk;

      if Lex.TokenID <> tkNull then
      begin
        // �ҵ��� uses ��ĵ�һ���ֺţ��ټ�¼��β��λ��
        InsPos := Lex.TokenPos + Length(Lex.Token);
      end;
    end;

    // ���ø�λ�ã�����ɱ༭���������λ�ã��ٲ��뻻�мӿ��м�����
    Names := TCnIdeStringList.Create;
    if not GeneratePasDecl(Names, HeadType) then
      Exit;

    if Names.Count <= 1 then
      Exit;

    Result := Names.Count - 1;
    Names.Insert(0, '');
    Names.Insert(0, '');
    S := Names.Text;

    if Length(S) > 2 then // ȥ��ĩβ����Ļس�
    begin
      if (S[Length(S) - 1] = #13) and (S[Length(S)] = #10) then
        Delete(S, Length(S) - 1, 2);
    end;

    EditWriter := CnOtaGetEditWriterForSourceEditor;

{$IFDEF IDE_WIDECONTROL}
    // ����ʱ��Wide Ҫ�� Utf8 ת��
    EditWriter.CopyTo(Length(UTF8Encode(Copy(Lex.Origin, 1, InsPos))));
  {$IFDEF UNICODE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(S)));
  {$ELSE}
    EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(S)));
  {$ENDIF}
{$ELSE}
    EditWriter.CopyTo(InsPos);
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(S)));
{$ENDIF}
    EditWriter := nil;
  finally
    Names.Free;
    Lex.Free;
    Stream.Free;
  end;
end;

procedure TCnEditorExtractString.MakeUnique;
var
  I, J: Integer;
  Map: TCnStrToStrHashMap;
  S, H: string;
  Token: TCnGeneralPasToken;
begin
  if FTokenListRef.Count <= 1 then
    Exit;

  Map := TCnStrToStrHashMap.Create;
  try
    for I := 0 to FTokenListRef.Count - 1 do
    begin
      Token := TCnGeneralPasToken(FTokenListRef.Objects[I]);
      if Map.Find(string(FTokenListRef[I]), S) then
      begin
        if S <> string(GetSourceTokenStr(Token)) then
        begin
          // ��ͬ���ģ���ֵ��ͬ��Ҫ����
          J := 1;
          H := FTokenListRef[I];
          repeat
            FTokenListRef[I] := H + IntToStr(J);
            Inc(J);
          until not Map.Find(string(FTokenListRef[I]), S);

          // ������Ҫ���
          Map.Add(string(FTokenListRef[I]), string(GetSourceTokenStr(Token)));
        end;
        // ͬ��ֵͬ����
      end
      else // ��ͬ���ģ�ֱ�����
        Map.Add(string(FTokenListRef[I]), string(GetSourceTokenStr(Token)));
    end;
  finally
    Map.Free;
  end;
end;

function TCnEditorExtractString.Replace(AddCStr: Boolean): Integer;
var
  I, LastTokenPos: Integer;
  EditView: IOTAEditView;
  Token, StartToken, EndToken, PrevToken: TCnGeneralPasToken;
  NewCode: TCnIdeTokenString;
  EditWriter: IOTAEditWriter;
begin
  Result := 0;
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  StartToken := TCnGeneralPasToken(FTokenListRef.Objects[0]);
  EndToken := TCnGeneralPasToken(FTokenListRef.Objects[FTokenListRef.Count - 1]);
  PrevToken := nil;

{$IFDEF DEBUG}
  CnDebugger.LogInteger(FTokenListRef.Count, 'CnEditorExtractString To Replace Token Count.');
{$ENDIF}

  // ƴ���滻����ַ���
  for I := 0 to FTokenListRef.Count - 1 do
  begin
    Token := TCnGeneralPasToken(FTokenListRef.Objects[I]);

    if PrevToken = nil then
      NewCode := FTokenListRef[I]
    else
    begin
      // ����һ Token ��β�ͣ������� Token ��ͷ���ټ��滻������֣��� Ansi/Wide/Wide String ������
      LastTokenPos := PrevToken.TokenPos + PrevToken.TokenLength;

      if CurrentIsDelphiSource then
        NewCode := NewCode + Copy(FPasParser.Source, LastTokenPos + 1,
          Token.TokenPos - LastTokenPos) + FTokenListRef[I]
      else if CurrentIsCSource then
        NewCode := NewCode + Copy(FCppParser.Source, LastTokenPos + 1,
          Token.TokenPos - LastTokenPos) + FTokenListRef[I];
    end;

    if AddCStr then
      NewCode := NewCode + '.c_str()';

    Inc(Result);
    PrevToken := TCnGeneralPasToken(FTokenListRef.Objects[I]);
  end;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('CnEditorExtractString Replace New Code Generated. To Write to Editor.');
{$ENDIF}

  EditWriter := CnOtaGetEditWriterForSourceEditor;

{$IFDEF IDE_WIDECONTROL}
  // ����ʱ��Wide Ҫ�� Utf8 ת��
  if CurrentIsDelphiSource then
  begin
    EditWriter.CopyTo(Length(UTF8Encode(Copy(FPasParser.Source, 1, StartToken.TokenPos))));
    EditWriter.DeleteTo(Length(UTF8Encode(Copy(FPasParser.Source, 1, EndToken.TokenPos + EndToken.TokenLength))));
  end
  else if CurrentIsCSource then
  begin
    EditWriter.CopyTo(Length(UTF8Encode(Copy(FCppParser.Source, 1, StartToken.TokenPos))));
    EditWriter.DeleteTo(Length(UTF8Encode(Copy(FCppParser.Source, 1, EndToken.TokenPos + EndToken.TokenLength))));
  end;

  {$IFDEF UNICODE}
  EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(NewCode)));
  {$ELSE}
  EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(NewCode)));
  {$ENDIF}
{$ELSE}
  EditWriter.CopyTo(StartToken.TokenPos);
  EditWriter.DeleteTo(EndToken.TokenPos + (EndToken.TokenLength));
  EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));
{$ENDIF}
  EditWriter := nil;
end;

function TCnEditorExtractString.ScanPas: Boolean;
var
  I: Integer;
  EditView: IOTAEditView;
  Token: TCnGeneralPasToken;
  Info: TCodePosInfo;
  S: TCnIdeTokenString;
  Lex: TCnGeneralWidePasLex;
{$IFNDEF UNICODE}
{$IFNDEF IDE_STRING_ANSI_UTF8}
  CurrPos: Integer;
  EditPos: TOTAEditPos;
{$ENDIF}
{$ENDIF}
begin
  Result := False;
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  Lex := nil;

  try
    FreeTokens;

    FPasParser := TCnGeneralPasStructParser.Create;
{$IFDEF BDS}
    FPasParser.UseTabKey := True;
    FPasParser.TabWidth := EditControlWrapper.GetTabWidth;
{$ENDIF}

    FEditStream := TMemoryStream.Create;
    CnGeneralSaveEditorToStream(EditView.Buffer, FEditStream); // Ansi/Utf16/Utf16

{$IFDEF DEBUG}
    CnDebugger.LogMsg('CnEditorExtractString Scan Pascal to ParseString.');
{$ENDIF}

    // ������ǰ��ʾ��Դ�ļ��е��ַ���
    CnGeneralPasParserParseString(FPasParser, FEditStream);
    for I := 0 to FPasParser.Count - 1 do
    begin
      Token := FPasParser.Tokens[I];
      if CanExtract(Token.Token) then
      begin
        ConvertGeneralTokenPos(Pointer(EditView), Token);

{$IFDEF UNICODE}
        ParsePasCodePosInfoW(PChar(FEditStream.Memory), Token.EditLine, Token.EditCol, Info); // Utf16
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
        ParsePasCodePosInfoW(PWideChar(FEditStream.Memory), Token.EditLine, Token.EditCol, Info); // Utf16
  {$ELSE}
        EditPos.Line := Token.EditLine;
        EditPos.Col := Token.EditCol;
        CurrPos := CnOtaGetLinePosFromEditPos(EditPos);

        Info := ParsePasCodePosInfo(PChar(FEditStream.Memory), CurrPos); // Ansi
  {$ENDIF}
{$ENDIF}
        Token.Tag := Ord(Info.PosKind);
      end
      else
        Token.Tag := Ord(pkUnknown);
    end;

{$IFDEF DEBUG}
    CnDebugger.LogInteger(FPasParser.Count, 'PasParser.Count');
{$ENDIF}

    if FTokenListRef = nil then
      FTokenListRef := TCnIdeStringList.Create
    else
      FTokenListRef.Clear;

    for I := 0 to FPasParser.Count - 1 do
    begin
      Token := FPasParser.Tokens[I];
      if TCodePosKind(Token.Tag) in CnPasSourceStringPosKinds then
      begin
        S := ConvertStringToIdent(string(Token.Token), FPrefix, FUseUnderLine,
          FIdentWordStyle, FUseFullPinYin, FMaxPinYinWords, FMaxWords);
        // �� D2005~2007 ���� AnsiString �� WideString ��ת����Ҳ��Ӱ��

        FTokenListRef.AddObject(S, Token);
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogInteger(FTokenListRef.Count, 'Pascal TokensRefList.Count');
{$ENDIF}

    FBeforeImpl := False;
    if FTokenListRef.Count > 0 then
    begin
      Token := TCnGeneralPasToken(FTokenListRef.Objects[0]);

      // ���� implementation������һ���Ƿ�����ǰ��
      FEditStream.Position := 0;
      Lex := TCnGeneralWidePasLex.Create;
      Lex.Origin := FEditStream.Memory;

      while not (Lex.TokenID in [tkNull, tkImplementation]) do
        Lex.NextNoJunk;

      if Lex.TokenID = tkImplementation then
      begin
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
        FBeforeImpl := Token.LineNumber < Lex.LineNumber - 1;
{$ELSE}
        FBeforeImpl := Token.LineNumber < Lex.LineNumber;
{$ENDIF}
      end;
    end;
    Result := True;
  finally
    Lex.Free;
  end;
end;

function TCnEditorExtractString.ScanCpp: Boolean;
var
  I: Integer;
  EditView: IOTAEditView;
  Token: TCnGeneralCppToken;
{$IFNDEF UNICODE}
  CurrPos: Integer;
  EditPos: TOTAEditPos;
{$ENDIF}
  Info: TCodePosInfo;
  S: TCnIdeTokenString;
begin
  Result := False;
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  FreeTokens;

  FCppParser := TCnGeneralCppStructParser.Create;
{$IFDEF BDS}
  FCppParser.UseTabKey := True;
  FCppParser.TabWidth := EditControlWrapper.GetTabWidth;
{$ENDIF}

  FEditStream := TMemoryStream.Create;
  CnGeneralSaveEditorToStream(EditView.Buffer, FEditStream);

{$IFDEF DEBUG}
  CnDebugger.LogMsg('CnEditorExtractString Scan C/C++ to ParseString.');
{$ENDIF}

  // ������ǰ��ʾ��Դ�ļ��е��ַ���
  CnGeneralCppParserParseString(FCppParser, FEditStream);
  for I := 0 to FCppParser.Count - 1 do
  begin
    Token := FCppParser.Tokens[I];
    if CanExtract(Token.Token) then
    begin
      ConvertGeneralTokenPos(Pointer(EditView), Token);

{$IFDEF UNICODE}
      ParseCppCodePosInfoW(PChar(FEditStream.Memory), Token.EditLine, Token.EditCol, Info);
{$ELSE}
      EditPos.Line := Token.EditLine;
      EditPos.Col := Token.EditCol;
      CurrPos := CnOtaGetLinePosFromEditPos(EditPos);

      Info := ParseCppCodePosInfo(PChar(FEditStream.Memory), CurrPos);
{$ENDIF}
      Token.Tag := Ord(Info.PosKind);
    end
    else
      Token.Tag := Ord(pkUnknown);
  end;

{$IFDEF DEBUG}
  CnDebugger.LogInteger(FCppParser.Count, 'CppParser.Count');
{$ENDIF}

  if FTokenListRef = nil then
    FTokenListRef := TCnIdeStringList.Create
  else
    FTokenListRef.Clear;

  for I := 0 to FCppParser.Count - 1 do
  begin
    Token := FCppParser.Tokens[I];
    if TCodePosKind(Token.Tag) in CnCppSourceStringPosKinds then
    begin
      S := ConvertStringToIdent(string(Token.Token), FPrefix, FUseUnderLine,
        FIdentWordStyle, FUseFullPinYin, FMaxPinYinWords, FMaxWords);
      // �� D2005~2007 ���� AnsiString �� WideString ��ת����Ҳ��Ӱ��

      FTokenListRef.AddObject(S, Token);
    end;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogInteger(FTokenListRef.Count, 'C/C++ TokensRefList.Count');
{$ENDIF}
  Result := True;
end;

function TCnEditorExtractString.Scan: Boolean;
begin
  Result := False;
  if CurrentIsDelphiSource then
    Result := ScanPas
  else if CurrentIsCSource then
    Result := ScanCpp;
end;

function TCnEditorExtractString.InsertCppDecl(HeadType: TCnCppStringHeadType): Integer;
var
  List: TCnGeneralWideBCBTokenList;
  Stream: TMemoryStream;
  EditView: IOTAEditView;
  InsPos, DirLine: Integer;
  Names: TCnIdeStringList;
  S: TCnIdeTokenString;
  EditWriter: IOTAEditWriter;
begin
  Result := 0;
  // �����һ�� #include ��ֱ�Ӳ������

  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  Stream := nil;
  List := nil;
  Names := nil;

  try
    Stream := TMemoryStream.Create;
    CnGeneralSaveEditorToStream(EditView.Buffer, Stream); // Ansi/Utf16/Utf16

    List := TCnGeneralWideBCBTokenList.Create;
    List.DirectivesAsComments := False;
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
    List.SetOrigin(Stream.Memory, Stream.Size div SizeOf(WideChar));
{$ELSE}
    List.SetOrigin(Stream.Memory, Stream.Size);
{$ENDIF}

    InsPos := 0;
    DirLine := 0;
    while List.RunID <> ctknull do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Meet %s at %d', [GetEnumName(TypeInfo(TCTokenKind), Ord(List.RunID)), List.RunPosition]);
{$ENDIF}
      if List.RunID in [ctkdirinclude, ctkdirpragma] then
      begin
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
        DirLine := List.LineNumber;
{$ELSE}
        DirLine := List.RunLineNumber; // ��¼����������� directive ���к�
{$ENDIF}
      end
      else if (List.RunID = ctkcrlf)
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
        and (List.LineNumber = DirLine)
{$ELSE}
        and (List.RunLineNumber = DirLine)
{$ENDIF}
        then
      begin
        InsPos := List.RunPosition + List.TokenLength;
      end;

      List.Next;
    end;

    // ���ø�λ�ã�����ɱ༭���������λ�ã��ٲ��뻻�мӿ��м�����
    Names := TCnIdeStringList.Create;
    if not GenerateCppDecl(Names, HeadType) then
      Exit;

    if Names.Count <= 1 then
      Exit;

    Result := Names.Count - 1;
    Names.Insert(0, '');
    Names.Add('');
    S := Names.Text;

    EditWriter := CnOtaGetEditWriterForSourceEditor;

{$IFDEF IDE_WIDECONTROL}
    // ����ʱ��Wide Ҫ�� Utf8 ת��
    EditWriter.CopyTo(Length(UTF8Encode(Copy(List.Origin, 1, InsPos))));
  {$IFDEF UNICODE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(S)));
  {$ELSE}
    EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(S)));
  {$ENDIF}
{$ELSE}
    EditWriter.CopyTo(InsPos);
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(S)));
{$ENDIF}
    EditWriter := nil;
  finally
    Names.Free;
    List.Free;
    Stream.Free;
  end;
end;

initialization
  RegisterCnCodingToolset(TCnEditorExtractString); // ע�Ṥ��

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
