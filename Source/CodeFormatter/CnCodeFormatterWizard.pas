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

unit CnCodeFormatterWizard;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ������ʽ��ר�ҵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ master@cnpack.org
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5
* ���ݲ��ԣ����ޣ�PWin9X/2000/XP/7 Delphi 5/6/7 + C++Builder 5/6��
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2024.11.02 V1.1
*               �ָ��۵�״̬��Ҫ��ʱ�ָ����� IDE �����·�����ʱ��
*           2015.03.11 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODEFORMATTERWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  {$IFDEF DELPHI_OTA} ToolsAPI, {$ELSE} LCLProc, {$ENDIF} IniFiles, StdCtrls, ComCtrls, Menus,
  TypInfo, Contnrs, ExtCtrls, mPasLex, CnSpin, CnConsts, CnCommon, CnWizConsts,
  CnWizClasses, CnWizMultiLang, CnWizOptions, CnWizManager, CnIDEStrings,
{$IFDEF CNWIZARDS_CNINPUTHELPER} {$IFDEF DELPHI_OTA}
  CnInputHelper, CnInputSymbolList, CnInputIdeSymbolList,
{$ENDIF} {$ENDIF}
  CnStrings, CnPasCodeParser, CnWizUtils, CnFormatterIntf, CnCodeFormatRules,
  {$IFDEF DELPHI_OTA} CnWizDebuggerNotifier, {$ENDIF} CnEditControlWrapper;

type
  TCnCodeFormatterWizard = class(TCnSubMenuWizard)
  private
    FIdOptions: Integer;
    FIdFormatCurrent: Integer;
    FLibHandle: THandle;
    FGetProvider: TCnGetFormatterProvider;

    // Pascal Format Settings
    FDirectiveMode: TCnCompDirectiveMode;
    FUsesUnitSingleLine: Boolean;
    FUseIgnoreArea: Boolean;
    FKeepUserLineBreak: Boolean;
    FSpaceAfterOperator: Byte;
    FSpaceBeforeOperator: Byte;
    FSpaceBeforeASM: Byte;
    FTabSpaceCount: Byte;
    FSpaceTabASMKeyword: Byte;
    FWrapWidth: Integer;
    FBeginStyle: TCnBeginStyle;
    FKeywordStyle: TCnKeywordStyle;
    FWrapMode: TCnCodeWrapMode;
    FWrapNewLineWidth: Integer;
    FUseIDESymbols: Boolean;

    FBreakpoints: TObjectList;  // �ļ��Ķϵ���Ϣ
    FBookmarks: TObjectList;    // �ļ�����ǩ��Ϣ
    FElideLines: TList;         // �ļ����۵���Ϣ
{$IFDEF IDE_EDITOR_ELIDE}
    FElideTimer: TTimer;        // �ָ��۵��е���ʱ
    FElideMarks: PDWORD;
{$ENDIF}

{$IFDEF CNWIZARDS_CNINPUTHELPER}
{$IFDEF DELPHI_OTA}
    FInputHelper: TCnInputHelper;
    FSymbolListMgr: TCnSymbolListMgr;
    FPreNamesList: TCnAnsiStringList;  // Lazy Create
    FPreNamesArray: array of PAnsiChar;
    procedure CheckObtainIDESymbols;
{$ENDIF}
{$ENDIF}

{$IFDEF DELPHI_OTA}
    // ��ȡ�е��۵���Ϣ
    procedure ObtainLineElideInfo(List: TList);

    // ���� DWORD ���黹ԭ�ϵ���Ϣ������ 0 �򳬹� Count ʱ����
    procedure RestoreBreakpoints(LineMarks: PDWORD; Count: Integer = MaxInt);
    // ���� DWORD �����Լ�֮ǰ�洢�� FBookmarks ��ԭ��ǩ��Ϣ
    procedure RestoreBookmarks(EditView: IOTAEditView; LineMarks: PDWORD);

{$IFDEF IDE_EDITOR_ELIDE}
    // ���� DWORD �����Լ��۵���������ԭ�۵�״̬
    procedure RestoreElideLines(LineMarks: PDWORD);
    procedure ElideOnTimer(Sender: TObject);
{$ENDIF}
{$ENDIF}

    function CheckSelectionPosition(StartPos: TOTACharPos; EndPos: TOTACharPos;
      View: TCnEditViewSourceInterface): Boolean;

    function PutPascalFormatRules: Boolean;
    function GetErrorStr(Err: Integer): string;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure AcquireSubActions; override;

    property DirectiveMode: TCnCompDirectiveMode read FDirectiveMode write FDirectiveMode;
    property KeywordStyle: TCnKeywordStyle read FKeywordStyle write FKeywordStyle;
    property BeginStyle: TCnBeginStyle read FBeginStyle write FBeginStyle;
    property WrapMode: TCnCodeWrapMode read FWrapMode write FWrapMode;
    property TabSpaceCount: Byte read FTabSpaceCount write FTabSpaceCount;
    property SpaceBeforeOperator: Byte read FSpaceBeforeOperator write
      FSpaceBeforeOperator;
    property SpaceAfterOperator: Byte read FSpaceAfterOperator write FSpaceAfterOperator;
    property SpaceBeforeASM: Byte read FSpaceBeforeASM write FSpaceBeforeASM;
    property SpaceTabASMKeyword: Byte read FSpaceTabASMKeyword write FSpaceTabASMKeyword;
    property WrapWidth: Integer read FWrapWidth write FWrapWidth;
    property WrapNewLineWidth: Integer read FWrapNewLineWidth write FWrapNewLineWidth;
    property UsesUnitSingleLine: Boolean read FUsesUnitSingleLine write
      FUsesUnitSingleLine;
    property UseIgnoreArea: Boolean read FUseIgnoreArea write FUseIgnoreArea;
    property KeepUserLineBreak: Boolean read FKeepUserLineBreak write FKeepUserLineBreak;
    property UseIDESymbols: Boolean read FUseIDESymbols write FUseIDESymbols;
  end;

  TCnCodeFormatterForm = class(TCnTranslateForm)
    pgcFormatter: TPageControl;
    tsPascal: TTabSheet;
    grpCommon: TGroupBox;
    lblKeyword: TLabel;
    cbbKeywordStyle: TComboBox;
    lblBegin: TLabel;
    cbbBeginStyle: TComboBox;
    lblTab: TLabel;
    seTab: TCnSpinEdit;
    seWrapLine: TCnSpinEdit;
    lblSpaceBefore: TLabel;
    seSpaceBefore: TCnSpinEdit;
    lblSpaceAfter: TLabel;
    seSpaceAfter: TCnSpinEdit;
    chkUsesSinglieLine: TCheckBox;
    grpAsm: TGroupBox;
    chkIgnoreArea: TCheckBox;
    seASMHeadIndent: TCnSpinEdit;
    lblAsmHeadIndent: TLabel;
    lblASMTab: TLabel;
    seAsmTab: TCnSpinEdit;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    chkAutoWrap: TCheckBox;
    btnShortCut: TButton;
    lblNewLine: TLabel;
    seNewLine: TCnSpinEdit;
    chkUseIDESymbols: TCheckBox;
    cbbDirectiveMode: TComboBox;
    lblDirectiveMode: TLabel;
    chkKeepUserLineBreak: TCheckBox;
    procedure chkAutoWrapClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnShortCutClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure seWrapLineChange(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    FWizard: TCnCodeFormatterWizard;
  protected
    function GetHelpTopic: string; override;
  public

  end;

{$ENDIF CNWIZARDS_CNCODEFORMATTERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODEFORMATTERWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
{$IFDEF LAZARUS}
  DLLName: string = 'CnFormatLibW.dll';   // Lazarus �� Unicode ��
{$ELSE}
{$IFDEF UNICODE}
  {$IFDEF WIN64}
  DLLName: string = 'CnFormatLibW64.dll'; // 64 λ�� 64 λ DLL
  {$ELSE}
  DLLName: string = 'CnFormatLibW.dll';   // D2009 ~ ���� �� Unicode ��
  {$ENDIF}
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  DLLName: string = 'CnFormatLibW.dll';   // D2005 ~ 2007 Ҳ�� Unicode �浫�� UTF8
  {$ELSE}
  DLLName: string = 'CnFormatLib.dll';    // D5~7 ���� Ansi ��
  {$ENDIF}
{$ENDIF}
{$ENDIF}

  csUsesUnitSingleLine = 'UsesUnitSingleLine';
  csUseIgnoreArea = 'UseIgnoreArea';
  csSpaceAfterOperator = 'SpaceAfterOperator';
  csSpaceBeforeOperator = 'SpaceBeforeOperator';
  csSpaceBeforeASM = 'SpaceBeforeASM';
  csTabSpaceCount = 'TabSpaceCount';
  csSpaceTabASMKeyword = 'SpaceTabASMKeyword';
  csWrapWidth = 'WrapWidth';
  csWrapNewLineWidth = 'WrapNewLineWidth';
  csWrapMode = 'WrapMode';
  csBeginStyle = 'BeginStyle';
  csKeywordStyle = 'KeywordStyle';
  csDirectiveMode = 'DirectiveMode';
  csKeepUserLineBreak = 'KeepUserLineBreak';
  csUseIDESymbols = 'UseIDESymbols';

{ TCnCodeFormatterWizard }

procedure TCnCodeFormatterWizard.AcquireSubActions;
begin
  FIdFormatCurrent := RegisterASubAction(SCnCodeFormatterWizardFormatCurrent,
    SCnCodeFormatterWizardFormatCurrentCaption, TextToShortCut('Ctrl+W'),
    SCnCodeFormatterWizardFormatCurrentHint);

  AddSepMenu;
  FIdOptions := RegisterASubAction(SCnCodeFormatterWizardConfig,
    SCnCodeFormatterWizardConfigCaption, 0, SCnCodeFormatterWizardConfigHint);
end;

function TCnCodeFormatterWizard.CheckSelectionPosition(StartPos, EndPos:
  TOTACharPos; View: TCnEditViewSourceInterface): Boolean;
const
  InvalidTokens: set of TTokenKind =
    [tkBorComment, tkAnsiComment];
var
  Stream: TMemoryStream;
  Lex: TmwPasLex;
  NowPos: TOTACharPos;
  PrevToken: TTokenKind;
  NS, NE: Integer;

  // 1 > = < 2 �ֱ𷵻� 1 0 -1

  function CompareCharPos(Pos1, Pos2: TOTACharPos): Integer;
  begin
    if Pos1.Line > Pos2.Line then
      Result := 1
    else if Pos1.Line < Pos2.Line then
      Result := -1
    else
    begin
      if Pos1.CharIndex > Pos2.CharIndex then
        Result := 1
      else if Pos1.CharIndex < Pos2.CharIndex then
        Result := -1
      else
        Result := 0;
    end;
  end;

begin
  // �����ʼλ���Ƿ�Ϸ������粻����ע�������
  Result := True;
  Stream := TMemoryStream.Create;
  Lex := TmwPasLex.Create;
  try
{$IFDEF DELPHI_OTA}
    CnOtaSaveEditorToStream(View.Buffer, Stream);
{$ENDIF}
{$IFDEF LAZARUS}
    CnOtaSaveEditorToStream(View, Stream);
{$ENDIF}

    Lex.Origin := PAnsiChar(Stream.Memory);

    PrevToken := tkUnknown;
    NowPos.CharIndex := 0;
    NowPos.Line := 0;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('CheckSelectionPosition. StartPos %d:%d. EndPos %d:%d', [StartPos.Line,
      StartPos.CharIndex,
      EndPos.Line, EndPos.CharIndex]);
{$ENDIF}

    while Lex.TokenID <> tkNull do
    begin
      NowPos.CharIndex := Lex.TokenPos - Lex.LinePos + 1;
      NowPos.Line := Lex.LineNumber + 1;

{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Now Pos %d:%d. Token %s', [NowPos.Line, NowPos.CharIndex,
//      GetEnumName(TypeInfo(TTokenKind), Ord(Lex.TokenID))]);
{$ENDIF}
      // ��ǰ Token ��ע�͡�λ�õ��ڹ��λ����ǰһ Token �� CRLFCo
      NS := CompareCharPos(NowPos, StartPos);
      if (NS = 0) and (PrevToken = tkCRLFCo) and (Lex.TokenID in InvalidTokens) then
      begin
        Result := False;
        Exit;
      end;

      NE := CompareCharPos(NowPos, EndPos);
      if (NE = 0) and (PrevToken = tkCRLFCo) and (Lex.TokenID in InvalidTokens) then
      begin
        Result := False;
        Exit;
      end;

      if (NS > 0) and (NE > 0) then // �����ȹ���
        Exit;

      PrevToken := Lex.TokenID;
      Lex.Next;
    end;
  finally
    Stream.Free;
    Lex.Free;
  end;
  Result := True;
end;

procedure TCnCodeFormatterWizard.Config;
begin
  with TCnCodeFormatterForm.Create(nil) do
  begin
    FWizard := Self;

    cbbKeywordStyle.ItemIndex := Ord(FKeywordStyle);
    cbbBeginStyle.ItemIndex := Ord(FBeginStyle);
    seTab.Value := FTabSpaceCount;
    chkAutoWrap.Checked := (FWrapMode <> cwmNone);
    seWrapLine.Value := FWrapWidth;
    seNewLine.Value := FWrapNewLineWidth;
    seSpaceBefore.Value := FSpaceBeforeOperator;
    seSpaceAfter.Value := FSpaceAfterOperator;
    chkUsesSinglieLine.Checked := FUsesUnitSingleLine;
    cbbDirectiveMode.ItemIndex := Ord(FDirectiveMode);

{$IFDEF CNWIZARDS_CNINPUTHELPER}
    chkUseIDESymbols.Checked := FUseIDESymbols;
{$ELSE}
    chkUseIDESymbols.Enabled := False;
{$ENDIF}

    seASMHeadIndent.Value := FSpaceBeforeASM;
    seAsmTab.Value := FSpaceTabASMKeyword;
    chkIgnoreArea.Checked := FUseIgnoreArea;
    chkKeepUserLineBreak.Checked := FKeepUserLineBreak;

    if ShowModal = mrOK then
    begin
      FKeywordStyle := TCnKeywordStyle(cbbKeywordStyle.ItemIndex);
      FBeginStyle := TCnBeginStyle(cbbBeginStyle.ItemIndex);
      FTabSpaceCount := seTab.Value;
      FWrapWidth := seWrapLine.Value;
      FWrapNewLineWidth := seNewLine.Value;
      if chkAutoWrap.Checked then
        FWrapMode := cwmAdvanced
      else
        FWrapMode := cwmNone;

      FSpaceBeforeOperator := seSpaceBefore.Value;
      FSpaceAfterOperator := seSpaceAfter.Value;
      FUsesUnitSingleLine := chkUsesSinglieLine.Checked;
{$IFDEF CNWIZARDS_CNINPUTHELPER}
      FUseIDESymbols := chkUseIDESymbols.Checked;
{$ENDIF}
      FSpaceBeforeASM := seASMHeadIndent.Value;
      FSpaceTabASMKeyword := seAsmTab.Value;
      FUseIgnoreArea := chkIgnoreArea.Checked;
      FDirectiveMode := TCnCompDirectiveMode(cbbDirectiveMode.ItemIndex);
      FKeepUserLineBreak := chkKeepUserLineBreak.Checked;
    end;

    Free;
  end;
end;

constructor TCnCodeFormatterWizard.Create;
begin
  inherited;
  FBreakpoints := TObjectList.Create(True);
  FBookmarks := TObjectList.Create(True);
  FElideLines := TList.Create;

{$IFDEF IDE_EDITOR_ELIDE}
  FElideTimer := TTimer.Create(nil);
  FElideTimer.Interval := 3000;
  FElideTimer.OnTimer := ElideOnTimer;
  FElideTimer.Enabled := False;
{$ENDIF}

  FLibHandle := LoadLibrary(PChar(MakePath(WizOptions.DllPath) + DLLName));
  if FLibHandle <> 0 then
    FGetProvider := TCnGetFormatterProvider(GetProcAddress(FLibHandle,
      'GetCodeFormatterProvider'));
end;

destructor TCnCodeFormatterWizard.Destroy;
begin
{$IFDEF CNWIZARDS_CNINPUTHELPER}
{$IFDEF DELPHI_OTA}
  FPreNamesList.Free;
  SetLength(FPreNamesArray, 0);
{$ENDIF}
{$ENDIF}

{$IFDEF IDE_EDITOR_ELIDE}
  FElideTimer.Free;
{$ENDIF}

  FElideLines.Free;
  FBookmarks.Free;
  FBreakpoints.Free;
  if FLibHandle <> 0 then
    FreeLibrary(FLibHandle);
  inherited;
end;

procedure TCnCodeFormatterWizard.Execute;
begin

end;

function TCnCodeFormatterWizard.GetCaption: string;
begin
  Result := SCnCodeFormatterWizardMenuCaption;
end;

function TCnCodeFormatterWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnCodeFormatterWizard.GetErrorStr(Err: Integer): string;
begin
  case Err of
    CN_ERRCODE_PASCAL_IDENT_EXP:
      Result := SCnCodeFormatterErrPascalIdentExp;
    CN_ERRCODE_PASCAL_STRING_EXP:
      Result := SCnCodeFormatterErrPascalStringExp;
    CN_ERRCODE_PASCAL_NUMBER_EXP:
      Result := SCnCodeFormatterErrPascalNumberExp;
    CN_ERRCODE_PASCAL_CHAR_EXP:
      Result := SCnCodeFormatterErrPascalCharExp;
    CN_ERRCODE_PASCAL_SYMBOL_EXP:
      Result := SCnCodeFormatterErrPascalSymbolExp;
    CN_ERRCODE_PASCAL_PARSE_ERR:
      Result := SCnCodeFormatterErrPascalParseErr;
    CN_ERRCODE_PASCAL_INVALID_BIN:
      Result := SCnCodeFormatterErrPascalInvalidBin;
    CN_ERRCODE_PASCAL_INVALID_STRING:
      Result := SCnCodeFormatterErrPascalInvalidString;
    CN_ERRCODE_PASCAL_INVALID_BOOKMARK:
      Result := SCnCodeFormatterErrPascalInvalidBookmark;
    CN_ERRCODE_PASCAL_LINE_TOOLONG:
      Result := SCnCodeFormatterErrPascalLineTooLong;
    CN_ERRCODE_PASCAL_ENDCOMMENT_EXP:
      Result := SCnCodeFormatterErrPascalEndCommentExp;
    CN_ERRCODE_PASCAL_NOT_SUPPORT:
      Result := SCnCodeFormatterErrPascalNotSupport;
    CN_ERRCODE_PASCAL_ERROR_DIRECTIVE:
      Result := SCnCodeFormatterErrPascalErrorDirective;
    CN_ERRCODE_PASCAL_NO_METHODHEADING:
      Result := SCnCodeFormatterErrPascalNoMethodHeading;
    CN_ERRCODE_PASCAL_NO_STRUCTTYPE:
      Result := SCnCodeFormatterErrPascalNoStructType;
    CN_ERRCODE_PASCAL_NO_TYPEDCONSTANT:
      Result := SCnCodeFormatterErrPascalNoTypedConstant;
    CN_ERRCODE_PASCAL_NO_EQUALCOLON:
      Result := SCnCodeFormatterErrPascalNoEqualColon;
    CN_ERRCODE_PASCAL_NO_DECLSECTION:
      Result := SCnCodeFormatterErrPascalNoDeclSection;
    CN_ERRCODE_PASCAL_NO_PROCFUNC:
      Result := SCnCodeFormatterErrPascalNoProcFunc;
    CN_ERRCODE_PASCAL_UNKNOWN_GOAL:
      Result := SCnCodeFormatterErrPascalUnknownGoal;
    CN_ERRCODE_PASCAL_ERROR_INTERFACE:
      Result := SCnCodeFormatterErrPascalErrorInterface;
    CN_ERRCODE_PASCAL_INVALID_STATEMENT:
      Result := SCnCodeFormatterErrPascalInvalidStatement;
  else
    Result := SCnCodeFormatterErrUnknown;
  end;
end;

function TCnCodeFormatterWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnCodeFormatterWizard.GetHint: string;
begin
  Result := SCnCodeFormatterWizardMenuHint;
end;

function TCnCodeFormatterWizard.GetState: TWizardState;
begin
  if Active then
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnCodeFormatterWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnCodeFormatterWizardName;
  Author := SCnPack_GuYueChunQiu + ';' + SCnPack_LiuXiao;
  Email := SCnPack_GuYueChunQiuEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnCodeFormatterWizardComment;
end;

function TCnCodeFormatterWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent +
    '�ؼ���,��Сд,����,�Զ�����,ǰ��,����ָ��,ע��,����,��ռ,���,����,���,' +
    'keyword,case,sensitive,indent,linebreak,compile,directive,comment,' +
    'keep,asm,head,uses,width,';
end;

procedure TCnCodeFormatterWizard.LoadSettings(Ini: TCustomIniFile);
begin
  FUsesUnitSingleLine := Ini.ReadBool('', csUsesUnitSingleLine,
    CnPascalCodeForVCLRule.UsesUnitSingleLine);
  FUseIgnoreArea := Ini.ReadBool('', csUseIgnoreArea, CnPascalCodeForVCLRule.UseIgnoreArea);
  FSpaceAfterOperator := Ini.ReadInteger('', csSpaceAfterOperator,
    CnPascalCodeForVCLRule.SpaceAfterOperator);
  FSpaceBeforeOperator := Ini.ReadInteger('', csSpaceBeforeOperator,
    CnPascalCodeForVCLRule.SpaceBeforeOperator);
  FSpaceBeforeASM := Ini.ReadInteger('', csSpaceBeforeASM,
    CnPascalCodeForVCLRule.SpaceBeforeASM);
  FTabSpaceCount := Ini.ReadInteger('', csTabSpaceCount, CnPascalCodeForVCLRule.TabSpaceCount);
  FSpaceTabASMKeyword := Ini.ReadInteger('', csSpaceTabASMKeyword,
    CnPascalCodeForVCLRule.SpaceTabASMKeyword);
  FWrapWidth := Ini.ReadInteger('', csWrapWidth, CnPascalCodeForVCLRule.WrapWidth);
  FWrapNewLineWidth := Ini.ReadInteger('', csWrapNewLineWidth,
    CnPascalCodeForVCLRule.WrapNewLineWidth);
  FWrapMode := TCnCodeWrapMode(Ini.ReadInteger('', csWrapMode,
    Ord(CnPascalCodeForVCLRule.CodeWrapMode)));
  FBeginStyle := TCnBeginStyle(Ini.ReadInteger('', csBeginStyle,
    Ord(CnPascalCodeForVCLRule.BeginStyle)));
  FKeywordStyle := TCnKeywordStyle(Ini.ReadInteger('', csKeywordStyle,
    Ord(CnPascalCodeForVCLRule.KeywordStyle)));
  FDirectiveMode := TCnCompDirectiveMode(Ini.ReadInteger('', csDirectiveMode,
    Ord(CnPascalCodeForVCLRule.CompDirectiveMode)));
  FKeepUserLineBreak := Ini.ReadBool('', csKeepUserLineBreak,
    CnPascalCodeForVCLRule.KeepUserLineBreak);
{$IFDEF CNWIZARDS_CNINPUTHELPER}
  FUseIDESymbols := Ini.ReadBool('', csUseIDESymbols, False);
{$ENDIF}
end;

{$IFDEF CNWIZARDS_CNINPUTHELPER}
{$IFDEF DELPHI_OTA}

procedure TCnCodeFormatterWizard.CheckObtainIDESymbols;
var
  IDESymbols, UnitNames: TCnSymbolList;
  Buffer: IOTAEditBuffer;
  PosInfo: TCodePosInfo;
  I: Integer;

  procedure AddNameWithoutDuplicate(const AName: AnsiString);
  var
    Idx: Integer;
  begin
    if FPreNamesList.Find(AName, Idx) then
    begin
      // ��ͬ���ģ���ԭ��ͬ���Ķ�Ҫɾ������û���
      FPreNamesList.Delete(Idx);
    end
    else
      FPreNamesList.Add(AName);
  end;

begin
  SetLength(FPreNamesArray, 0);
  if not FUseIDESymbols then
    Exit;

  Buffer := CnOtaGetEditBuffer;
  if Buffer = nil then
    Exit;

  FInputHelper := TCnInputHelper(CnWizardMgr.WizardByClassName('TCnInputHelper'));
  if (FInputHelper = nil) or not FInputHelper.Active then
    Exit;

  FSymbolListMgr := FInputHelper.SymbolListMgr;
  if FSymbolListMgr = nil then
    Exit;

  PosInfo.IsPascal := True;

  IDESymbols := FSymbolListMgr.ListByClass(TIDESymbolList);
  if IDESymbols <> nil then
  begin
    PosInfo.PosKind := pkProcedure;
    PosInfo.AreaKind := akImplementation;
    IDESymbols.Reload(Buffer, '', PosInfo);

{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnCodeFormatterWizard IDE Symbols Got Count: ' +
      IntToStr(IDESymbols.Count));
{$ENDIF}
  end;

  UnitNames := FSymbolListMgr.ListByClass(TCnUnitNameList);
  if UnitNames <> nil then
  begin
    PosInfo.PosKind := pkIntfUses;
    PosInfo.AreaKind := akIntfUses;
    UnitNames.Reload(Buffer, '', PosInfo);

{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnCodeFormatterWizard Unit Names Got Count: ' + IntToStr
      (UnitNames.Count));
{$ENDIF}
  end;

  if FPreNamesList <> nil then
    FPreNamesList.Clear
  else
  begin
    FPreNamesList := TCnAnsiStringList.Create;
    FPreNamesList.CaseSensitive := False;
    FPreNamesList.Duplicates := dupIgnore;
    FPreNamesList.Sorted := True;
  end;

  if (IDESymbols.Count = 0) and (UnitNames.Count = 0) then
    Exit;

  for I := 0 to IDESymbols.Count - 1 do
    AddNameWithoutDuplicate(AnsiString(IDESymbols.Items[I].Name));
  for I := 0 to UnitNames.Count - 1 do
    AddNameWithoutDuplicate(AnsiString(UnitNames.Items[I].Name));

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnCodeFormatterWizard Pre Names Count: ' + IntToStr(FPreNamesList.Count));
{$ENDIF}

  SetLength(FPreNamesArray, FPreNamesList.Count + 1); // ĩβһ�� nil
  FillChar(FPreNamesArray[0], Length(FPreNamesArray) * SizeOf(PAnsiChar), 0);

  for I := 0 to FPreNamesList.Count - 1 do
    FPreNamesArray[I] := PAnsiChar(FPreNamesList[I]);
end;

{$ENDIF}
{$ENDIF}

function TCnCodeFormatterWizard.PutPascalFormatRules: Boolean;
var
  Intf: ICnPascalFormatterIntf;
  ADirectiveMode: DWORD;
  AKeywordStyle: DWORD;
  ABeginStyle: DWORD;
  ATabSpace: DWORD;
  ASpaceBeforeOperator: DWORD;
  ASpaceAfterOperator: DWORD;
  ASpaceBeforeAsm: DWORD;
  ASpaceTabAsm: DWORD;
  ALineWrapWidth: DWORD;
  ANewLineWrapWidth: DWORD;
  AWrapMode: DWORD;
  AUsesSingleLine: LongBool;
  AUseIgnoreArea: LongBool;
  AUsesLineWrapWidth: DWORD;
  AKeepUserLineBreak: LongBool;
begin
  Result := False;
  if FGetProvider = nil then
    Exit;
  Intf := FGetProvider();

  if Intf = nil then
    Exit;

  ADirectiveMode := CN_RULE_DIRECTIVE_MODE_DEFAULT;
  AKeywordStyle := CN_RULE_KEYWORD_STYLE_DEFAULT;
  AWrapMode := CN_RULE_CODE_WRAP_MODE_DEFAULT;

  case FDirectiveMode of
    cdmAsComment:
      ADirectiveMode := CN_RULE_DIRECTIVE_MODE_ASCOMMENT;
    cdmOnlyFirst:
      ADirectiveMode := CN_RULE_DIRECTIVE_MODE_ONLYFIRST;
  end;

  case FKeywordStyle of
    ksLowerCaseKeyword:
      AKeywordStyle := CN_RULE_KEYWORD_STYLE_LOWER;
    ksUpperCaseKeyword:
      AKeywordStyle := CN_RULE_KEYWORD_STYLE_UPPER;
    ksPascalKeyword:
      AKeywordStyle := CN_RULE_KEYWORD_STYLE_UPPERFIRST;
    ksNoChange:
      AKeywordStyle := CN_RULE_KEYWORD_STYLE_NOCHANGE;
  end;

  ABeginStyle := CN_RULE_BEGIN_STYLE_DEFAULT;
  case FBeginStyle of
    bsNextLine:
      ABeginStyle := CN_RULE_BEGIN_STYLE_NEXTLINE;
    bsSameLine:
      ABeginStyle := CN_RULE_BEGIN_STYLE_SAMELINE;
  end;

  ATabSpace := FTabSpaceCount;
  ASpaceBeforeOperator := FSpaceBeforeOperator;
  ASpaceAfterOperator := FSpaceAfterOperator;
  ASpaceBeforeAsm := FSpaceBeforeASM;
  ASpaceTabAsm := FSpaceTabASMKeyword;
  ALineWrapWidth := FWrapWidth;
  ANewLineWrapWidth := FWrapNewLineWidth;
  AUsesLineWrapWidth := FWrapWidth;

  case FWrapMode of
    cwmNone:
      begin
        AWrapMode := CN_RULE_CODE_WRAP_MODE_ADVANCED; // ������ʱ��������ʹ�ó����У���ñ��벻��
        ALineWrapWidth := 512;
        ANewLineWrapWidth := 768;
      end;
    cwmSimple:
      AWrapMode := CN_RULE_CODE_WRAP_MODE_SIMPLE;
    cwmAdvanced:
      AWrapMode := CN_RULE_CODE_WRAP_MODE_ADVANCED;
  end;

  AUsesSingleLine := LongBool(FUsesUnitSingleLine);
  AUseIgnoreArea := LongBool(FUseIgnoreArea);
  AKeepUserLineBreak := LongBool(FKeepUserLineBreak);

  Intf.SetPascalFormatRule(ADirectiveMode, AKeywordStyle, ABeginStyle, AWrapMode,
    ATabSpace, ASpaceBeforeOperator, ASpaceAfterOperator, ASpaceBeforeAsm,
    ASpaceTabAsm, ALineWrapWidth, ANewLineWrapWidth, AUsesSingleLine, AUseIgnoreArea,
    AUsesLineWrapWidth, AKeepUserLineBreak);
  Result := True;
end;

procedure TCnCodeFormatterWizard.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool('', csUsesUnitSingleLine, FUsesUnitSingleLine);
  Ini.WriteBool('', csUseIgnoreArea, FUseIgnoreArea);
  Ini.WriteInteger('', csSpaceAfterOperator, FSpaceAfterOperator);
  Ini.WriteInteger('', csSpaceBeforeOperator, FSpaceBeforeOperator);
  Ini.WriteInteger('', csSpaceBeforeASM, FSpaceBeforeASM);
  Ini.WriteInteger('', csTabSpaceCount, FTabSpaceCount);
  Ini.WriteInteger('', csSpaceTabASMKeyword, FSpaceTabASMKeyword);
  Ini.WriteInteger('', csWrapWidth, FWrapWidth);
  Ini.WriteInteger('', csWrapNewLineWidth, FWrapNewLineWidth);
  Ini.WriteInteger('', csWrapMode, Ord(FWrapMode));
  Ini.WriteInteger('', csBeginStyle, Ord(FBeginStyle));
  Ini.WriteInteger('', csKeywordStyle, Ord(FKeywordStyle));
  Ini.WriteInteger('', csDirectiveMode, Ord(FDirectiveMode));
  Ini.WriteBool('', csKeepUserLineBreak, FKeepUserLineBreak);

{$IFDEF CNWIZARDS_CNINPUTHELPER}
  Ini.WriteBool('', csUseIDESymbols, FUseIDESymbols);
{$ENDIF}
end;

procedure TCnCodeFormatterWizard.SubActionExecute(Index: Integer);
var
  Formatter: ICnPascalFormatterIntf;
  View: TCnEditViewSourceInterface;
  Src: string;
  Res: PChar;
  I, Idx, ErrCode, SourceLine, SourceCol, SourcePos: Integer;
  CurrentToken: PAnsiChar;
  StartPos, EndPos, StartPosIn, EndPosIn: Integer;
  HasSel: Boolean;
  StartRec, EndRec: TOTACharPos;
{$IFDEF DELPHI_OTA}
  Block: IOTAEditBlock;
  EP, ErrPos: TOTAEditPos;
{$ENDIF}
{$IFDEF LAZARUS}
  P: TPoint;
{$ENDIF}
  ErrLine: string;
  BpBmLineMarks: array of Cardinal;
  OutLineMarks: PDWORD;

  // ���������з��صĳ�����ת���� IDE ���ڲ�ʹ�õ��й���λ��BDS ������ Utf8

  function ConvertToEditorCol(const Line: string; Col: Integer): Integer;
{$IFDEF BDS}
  var
    S: WideString;
{$ENDIF}
  begin
{$IFDEF IDE_STRING_ANSI_UTF8}
    // Col ���ص��� Unicode ���У�Line �� Ansi �ģ���Ҫת�� Utf8 ����
    S := WideString(Line);
    S := Copy(S, 1, Col);
    Result := Length(UTF8Encode(S));
{$ELSE}
  {$IFDEF UNICODE}
    // Col ���ص��� Unicode ���У�Line �� Unicode �ģ���Ҫת�� Utf8 ����
    S := Copy(Line, 1, Col);
    Result := Length(UTF8Encode(S));
  {$ELSE}
    Result := Col;
  {$ENDIF}
{$ENDIF}
  end;

  // ���������з��صĳ�����ת���� IDE ����ʾ���й���ʾ������ Ansi
  function ConvertToVisibleCol(const Line: string; Col: Integer): Integer;
{$IFNDEF STAND_ALONE}
  var
{$IFDEF LAZARUS}
    S: UnicodeString;
{$ENDIF}
{$IFDEF DELPHI_OTA}
    S: WideString;
{$ENDIF}
{$ENDIF}
  begin
{$IFDEF LAZARUS}
    // Col ���ص��� Unicode ���У�Line �� Utf8 �ģ���Ҫת�� Ansi ����
    S := UnicodeString(Line);
    S := Copy(S, 1, Col);
    Result := Length(AnsiString(S));
{$ENDIF}
{$IFDEF DELPHI_OTA}
{$IFDEF IDE_STRING_ANSI_UTF8}
    // Col ���ص��� Unicode ���У�Line �� Ansi �ģ���Ҫת�� Ansi ����
    S := WideString(Line);
    S := Copy(S, 1, Col);
    Result := Length(AnsiString(S));
{$ELSE}
  {$IFDEF UNICODE}
    // Col ���ص��� Unicode ���У�Line �� Unicode �ģ���Ҫת�� Ansi ����
    S := Copy(Line, 1, Col);
    Result := Length(AnsiString(S));
  {$ELSE}
    Result := Col;
  {$ENDIF}
{$ENDIF}
{$ENDIF}
  end;

begin
  if Index = FIdOptions then
    Config
  else if Index = FIdFormatCurrent then
  begin
    PutPascalFormatRules;

    Formatter := FGetProvider();
    if Formatter = nil then
      Exit;
    View := CnOtaGetTopMostEditView;
    if not Assigned(View) then
      Exit;

{$IFDEF IDE_EDITOR_ELIDE}
    FElideTimer.Enabled := False;
    FElideMarks := nil;
{$ENDIF}

{$IFDEF DELPHI_OTA}
    // ��¼�ϵ㡢��ǩ���۵��С������Ϣ
    CnWizGetBreakpointsByFile(CnOtaGetCurrentSourceFileName, FBreakpoints);
    SaveBookMarksToObjectList(View, FBookmarks);
    ObtainLineElideInfo(FElideLines);

{$IFDEF CNWIZARDS_CNINPUTHELPER}
    CheckObtainIDESymbols;
    if Length(FPreNamesArray) > 0 then
    begin
      Formatter.SetPreIdentifierNames(PLPSTR(FPreNamesArray));
      SetLength(FPreNamesArray, 0);
      FPreNamesList.Clear;
    end;
{$ENDIF}
    HasSel := (View.Block <> nil) and View.Block.IsValid;
{$ENDIF}

{$IFDEF LAZARUS}
    HasSel := Length(View.Selection) > 0;
{$ENDIF}

    if not HasSel then // ��ѡ����
    begin
      try
        Screen.Cursor := crHourGlass;

        // ���ݵ�ǰ�����кš��ϵ㡢��ǩ���۵���ʼ���к�
        SetLength(BpBmLineMarks, 1 + FBreakpoints.Count + FBookmarks.Count
          + FElideLines.Count + 1); // ĩβ��һ�� 0
{$IFDEF DELPHI_OTA}
        EP := View.CursorPos;
        BpBmLineMarks[0] := EP.Line;
{$ENDIF}
{$IFDEF LAZARUS}
        BpBmLineMarks[0] := View.CursorTextXY.Y;
{$ENDIF}
        Idx := 1;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Before Format. Cursor Line: %d', [BpBmLineMarks[0]]);
{$ENDIF}

{$IFDEF DELPHI_OTA}
        if FBreakpoints.Count > 0 then
        begin
          for I := 0 to FBreakpoints.Count - 1 do
            BpBmLineMarks[I + Idx] := DWORD(TCnBreakpointDescriptor(FBreakpoints
              [I]).LineNumber);
          Inc(Idx, FBreakpoints.Count);
        end;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Before Format. Breakpoint Count: %d', [FBreakpoints.Count]);
{$ENDIF}

        if FBookmarks.Count > 0 then
        begin
          for I := 0 to FBookmarks.Count - 1 do
            BpBmLineMarks[I + Idx] := DWORD(TCnBookmarkObject(FBookmarks[I]).Line);
          Inc(Idx, FBookmarks.Count);
        end;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Before Format. Bookmark Count: %d', [FBookmarks.Count]);
{$ENDIF}

        if FElideLines.Count > 0 then
        begin
          for I := 0 to FElideLines.Count - 1 do
            BpBmLineMarks[I + Idx] := DWORD(FElideLines[I]);
        end;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Before Format. Elide Line Count: %d', [FElideLines.Count]);
{$ENDIF}
{$ENDIF}

        Formatter.SetInputLineMarks(@(BpBmLineMarks[0]));
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Before Format. All Line Marks: %d', [Length(BpBmLineMarks)]);
        CnDebugger.LogCardinalArray(BpBmLineMarks, 'In Line Marks:');
{$ENDIF}

{$IFDEF LAZARUS}
        // Src/Res Utf8
        Src := CnOtaGetCurrentEditorSource(False);
        Res := Formatter.FormatOnePascalUnitUtf8(PAnsiChar(Src), Length(Src));

        // Remove EF BB BF BOM if exist
        if (Res <> nil) and (StrLen(Res) > 3) and
          (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
          Inc(Res, 3);

{$ENDIF}

{$IFDEF DELPHI_OTA}
{$IFDEF UNICODE}
        // Src/Res Utf16
        Src := CnOtaGetCurrentEditorSourceW;
        Res := Formatter.FormatOnePascalUnitW(PChar(Src), Length(Src));

        // Remove FF FE BOM if exists
        if (Res <> nil) and (StrLen(Res) > 1) and (Res[0] = #$FEFF) then
          Inc(Res);
        // CnDebugger.LogMemDump(PChar(Res), Length(Res) * SizeOf(Char));
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
        // Src/Res Utf8
        Src := CnOtaGetCurrentEditorSource(False);
        Res := Formatter.FormatOnePascalUnitUtf8(PAnsiChar(Src), Length(Src));

        // Remove EF BB BF BOM if exist
        if (Res <> nil) and (StrLen(Res) > 3) and
          (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
          Inc(Res, 3);
        // CnDebugger.LogMemDump(PAnsiChar(Res), Length(Res));
  {$ELSE}
        // Src/Res Ansi
        Src := CnOtaGetCurrentEditorSource(True);
        Res := Formatter.FormatOnePascalUnit(PAnsiChar(Src), Length(Src));
  {$ENDIF}
{$ENDIF}
{$ENDIF}

        if Res <> nil then
        begin
          // hq200306 ���䣬δ�����仯ʱ�����иĶ�
          if TrimRight(Src) = TrimRight(string(Res)) then
            Exit;

{$IFDEF LAZARUS}
          // Utf8 ֱ��д��
          CnOtaSetCurrentEditorSource(string(Res));
{$ENDIF}

{$IFDEF DELPHI_OTA}
{$IFDEF UNICODE}
          // Utf16 �ڲ�ת Utf8 д��
          CnOtaSetCurrentEditorSourceW(string(Res));
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
          // Utf8 ֱ��д��
          CnOtaSetCurrentEditorSourceUtf8(string(Res));
  {$ELSE}
          // Ansi ת Utf8 д��
          CnOtaSetCurrentEditorSource(string(Res));
  {$ENDIF}
{$ENDIF}
{$ENDIF}

          // �ָ���ꡢ�ϵ㡢��ǩ���۵���Ϣ
          OutLineMarks := Formatter.RetrieveOutputLinkMarks;
{$IFDEF DEBUG}
          CnDebugger.LogCardinalArray(OutLineMarks, Int32Len(OutLineMarks) + 1, 'Out Line Marks:');
{$ENDIF}

          // �ָ����λ��
{$IFDEF DELPHI_OTA}
          EP.Line := OutLineMarks^;
          View.SetCursorPos(EP);
{$ENDIF}
{$IFDEF LAZARUS}
          P := View.CursorTextXY;
          P.Y := OutLineMarks^;
          View.CursorTextXY := P;
          CnLazSourceEditorCenterLine(View, View.CursorTextXY.Y);
{$ENDIF}
          Inc(OutLineMarks);
{$IFDEF LAZARUS}
{$IFDEF DEBUG}
          CnDebugger.LogFmt('After Format. Restore Cursor Line: %d', [View.CursorTextXY.Y]);
{$ENDIF}
{$ENDIF}

{$IFDEF DELPHI_OTA}
          // �ָ��ϵ�
          Idx := FBreakpoints.Count;
          if Idx > 0 then
          begin
            RestoreBreakpoints(OutLineMarks, Idx);
            Inc(OutLineMarks, Idx);
          end;
{$IFDEF DEBUG}
          CnDebugger.LogFmt('After Format. Restore Breakpoints: %d', [Idx]);
{$ENDIF}
          // �ָ���ǩ
          Idx := FBookmarks.Count;
          if Idx > 0 then
          begin
            RestoreBookmarks(View, OutLineMarks); // �ڲ����ֻ���� FBookmarks.Count ��
            Inc(OutLineMarks, Idx);
          end;
{$IFDEF DEBUG}
          CnDebugger.LogFmt('After Format. Restore Bookmarks: %d', [Idx]);
{$ENDIF}

{$IFDEF IDE_EDITOR_ELIDE}
          // �ָ��۵�״̬
          RestoreElideLines(OutLineMarks);
{$ENDIF}

          View.MoveViewToCursor;
          View.Paint;
{$ENDIF}
        end
        else // ���û�н��
        begin
          ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
            SourcePos, CurrentToken);
          Screen.Cursor := crDefault;
{$IFDEF DEBUG}
          CnDebugger.LogFmt('Format Error at Line %d, Col %d', [SourceLine, SourceCol]);
{$ENDIF}

{$IFDEF DELPHI_OTA}
          ErrLine := CnOtaGetLineText(SourceLine, View.Buffer);
          CnOtaGotoEditPos(OTAEditPos(ConvertToEditorCol(ErrLine, SourceCol),
            SourceLine), nil, False);

          ErrorDlg(Format(SCnCodeFormatterErrPascalFmt, [SourceLine,
            ConvertToVisibleCol(ErrLine, SourceCol),
            GetErrorStr(ErrCode), CurrentToken]) + SCnCodeFormatterErrMaybeComment);
{$ENDIF}
{$IFDEF LAZARUS}
          P := View.CursorTextXY;
          P.X := SourceCol;   // ���� Utf8������ת��
          P.Y := SourceLine;
          View.CursorTextXY := P;

          ErrorDlg(Format(SCnCodeFormatterErrPascalFmt, [SourceLine, SourceCol,
            GetErrorStr(ErrCode), CurrentToken]) + SCnCodeFormatterErrMaybeComment);
{$ENDIF}
        end;
      finally
        Formatter := nil;
        Screen.Cursor := crDefault;
      end;
    end
    else // ��ѡ����
    begin
      try
        Screen.Cursor := crHourGlass;
{$IFDEF LAZARUS}
        // Src/Res Utf8
        Src := CnOtaGetCurrentEditorSource(False);
{$ENDIF}
{$IFDEF DELPHI_OTA}
{$IFDEF UNICODE}
        // Src/Res Utf16
        Src := CnOtaGetCurrentEditorSourceW;
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
        // Src/Res Utf8
        Src := CnOtaGetCurrentEditorSource(False);
  {$ELSE}
        // Src/Res Ansi
        Src := CnOtaGetCurrentEditorSource(True);
  {$ENDIF}
{$ENDIF}
{$ENDIF}

        View := CnOtaGetTopMostEditView;
        if View <> nil then
        begin
          HasSel := False;
{$IFDEF DELPHI_OTA}
          Block := View.Block;
          HasSel := (Block <> nil) and Block.IsValid;
{$ENDIF}
{$IFDEF LAZARUS}
          HasSel := Length(View.Selection) > 0;
{$ENDIF}
          if HasSel then
          begin
            // ѡ�����ֹλ�����쵽��ģʽ
            if not CnOtaGetBlockOffsetForLineMode(StartRec, EndRec, View) then
              Exit;

            // ���ѡ������ʼλ����ע���м䣬�޷���������
            if not CheckSelectionPosition(StartRec, EndRec, View) then
            begin
              ErrorDlg(SCnCodeFormatterWizardErrSelection);
              Exit;
            end;

{$IFDEF DELPHI_OTA}
            // ����ѡ������ϵ���к�
            if FBreakpoints.Count > 0 then
            begin
              for I := FBreakpoints.Count - 1 downto 0 do
              begin
                if not TCnBreakpointDescriptor(FBreakpoints[I]).LineNumber in
                  [StartRec.Line, EndRec.Line] then
                  FBreakpoints.Delete(I);
              end;
            end;

            if FBookmarks.Count > 0 then
            begin
              for I := FBookmarks.Count - 1 downto 0 do
              begin
                if not TCnBookmarkObject(FBookmarks[I]).Line in
                  [StartRec.Line, EndRec.Line] then
                  FBookmarks.Delete(I);
              end;
            end;

            if FBreakpoints.Count + FBookmarks.Count > 0 then
            begin
              SetLength(BpBmLineMarks, FBreakpoints.Count + FBookmarks.Count + 1);
              // ĩβ��һ�� 0

              for I := 0 to FBreakpoints.Count - 1 do
                BpBmLineMarks[I] := DWORD(TCnBreakpointDescriptor(FBreakpoints[I]).LineNumber);
              for I := 0 to FBookmarks.Count - 1 do
                BpBmLineMarks[I + FBreakpoints.Count] := DWORD(TCnBookmarkObject
                  (FBookmarks[I]).Line);

              BpBmLineMarks[FBreakpoints.Count + FBookmarks.Count] := 0;
              Formatter.SetInputLineMarks(@(BpBmLineMarks[0]));

{$IFDEF DEBUG}
              CnDebugger.LogFmt('Before Format Selection. All Line Marks: %d', [Length(BpBmLineMarks)]);
              CnDebugger.LogCardinalArray(BpBmLineMarks, 'In Line Marks:');
{$ENDIF}
            end
            else
              Formatter.SetInputLineMarks(nil);
{$ENDIF}
{$IFDEF LAZARUS}
            Formatter.SetInputLineMarks(nil);
{$ENDIF}
            SetLength(BpBmLineMarks, 0);

            StartPos := CnOtaEditPosToLinePos(OTAEditPos(StartRec.CharIndex,
              StartRec.Line), View);
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(EndRec.CharIndex, EndRec.Line),
              View);

{$IFDEF DEBUG}
//          CnDebugger.LogRawString('Format Selection To Process: ' + Src);
{$ENDIF}
            // ��ʱ StartPos �� EndPos ����˵�ǰѡ������Ҫ������ı�

{$IFDEF LAZARUS}
        // Src/Res Utf8
        StartPosIn := StartPos;
        EndPosIn := EndPos;
        Res := Formatter.FormatPascalBlockUtf8(PAnsiChar(Src), Length(Src),
          StartPosIn, EndPosIn);

        // Remove EF BB BF BOM if exist
        if (Res <> nil) and (StrLen(Res) > 3) and
          (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
          Inc(Res, 3);
{$ENDIF}

{$IFDEF DELPHI_OTA}
{$IFDEF UNICODE}
            // Src/Res Utf16���� LinearPos �� Utf8 ��ƫ��������Ҫת��
            StartPosIn := Length(UTF8Decode(Copy(Utf8Encode(Src), 1, StartPos + 1))) - 1;
            EndPosIn := Length(UTF8Decode(Copy(Utf8Encode(Src), 1, EndPos + 1))) - 1;
            Res := Formatter.FormatPascalBlockW(PChar(Src), Length(Src),
              StartPosIn, EndPosIn);

            // Remove FF FE BOM if exists
            if (Res <> nil) and (StrLen(Res) > 1) and (Res[0] = #$FEFF) then
              Inc(Res);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
            // Src/Res Utf8
            StartPosIn := StartPos;
            EndPosIn := EndPos;
            Res := Formatter.FormatPascalBlockUtf8(PAnsiChar(Src), Length(Src),
              StartPosIn, EndPosIn);

            // Remove EF BB BF BOM if exist
            if (Res <> nil) and (StrLen(Res) > 3) and
              (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
              Inc(Res, 3);
  {$ELSE}
            // Src/Res Ansi
            StartPosIn := StartPos;
            EndPosIn := EndPos;
            // IDE �ڵ����� Pos �� 0 ��ʼ�ģ�ʹ�� Src �� Copy ʱ���±��� 1 ��ʼ�������Ҫ�� 1
            Res := Formatter.FormatPascalBlock(PAnsiChar(Src), Length(Src),
              StartPosIn, EndPosIn);
  {$ENDIF}
{$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
            CnDebugger.LogFmt('Format StartPos %d, EndPos %d.', [StartPosIn, EndPosIn]);
{$ENDIF}

            if Res <> nil then
            begin
{$IFDEF DEBUG}
              // CnDebugger.LogRawString('Format Selection Result: ' + Res);
{$ENDIF}

{$IFDEF DELPHI_OTA}
              {$IFDEF IDE_STRING_ANSI_UTF8}
              CnOtaReplaceCurrentSelectionUtf8(Res, True, True, True);
              {$ELSE}
              // Ansi/Unicode ������
              CnOtaReplaceCurrentSelection(Res, True, True, True);
              {$ENDIF}
{$ENDIF}
{$IFDEF LAZARUS}
              View.ReplaceLines(View.BlockBegin.Y, View.BlockEnd.Y, Res, True);
{$ENDIF}

{$IFDEF DELPHI_OTA}
              // �ָ��ϵ�����ǩ��Ϣ
              OutLineMarks := Formatter.RetrieveOutputLinkMarks;
{$IFDEF DEBUG}
              CnDebugger.LogCardinalArray(OutLineMarks, Int32Len(OutLineMarks) + 1, 'Out Line Marks:');
{$ENDIF}
              if FBookmarks.Count = 0 then
                RestoreBreakpoints(OutLineMarks)
              else
              begin
                RestoreBreakpoints(OutLineMarks, FBreakpoints.Count);
                // �ָ���ǩ��Ϣ
                Inc(OutLineMarks, FBreakpoints.Count);
                RestoreBookmarks(View, OutLineMarks);
              end;
{$ENDIF}
            end
            else // ��ʽ��ѡ����ʧ��
            begin
              ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
                SourcePos, CurrentToken);
              Screen.Cursor := crDefault;
{$IFDEF DEBUG}
              CnDebugger.LogFmt('Format Error at Line %d, Col %d', [SourceLine, SourceCol]);
{$ENDIF}
{$IFDEF DELPHI_OTA}
              ErrLine := CnOtaGetLineText(SourceLine, View.Buffer);
              ErrPos := OTAEditPos(ConvertToEditorCol(ErrLine, SourceCol), SourceLine);
{$IFDEF DEBUG}
              CnDebugger.LogFmt('Format Error Converted EditPos is Line %d, Col %d', [ErrPos.Line, ErrPos.Col]);
{$ENDIF}
              CnOtaGotoEditPos(ErrPos);
              ErrorDlg(Format(SCnCodeFormatterErrPascalFmt, [SourceLine,
                ConvertToVisibleCol(ErrLine, SourceCol),
                GetErrorStr(ErrCode), CurrentToken]) + SCnCodeFormatterErrMaybeComment);
{$ENDIF}

{$IFDEF LAZARUS}
              P := View.CursorTextXY;
              P.X := SourceCol;
              P.Y := SourceLine;
              View.CursorTextXY := P;

              ErrorDlg(Format(SCnCodeFormatterErrPascalFmt, [SourceLine, SourceCol,
                GetErrorStr(ErrCode), CurrentToken]) + SCnCodeFormatterErrMaybeComment);
{$ENDIF}
            end;
          end;
        end;
      finally
        Screen.Cursor := crDefault;
        Formatter := nil;
      end;
    end;
  end;
end;

procedure TCnCodeFormatterWizard.SubActionUpdate(Index: Integer);
var
  S: string;
begin
  if Index = FIdFormatCurrent then
  begin
    S := CnOtaGetCurrentSourceFile;
    SubActions[Index].Enabled := IsDprOrPas(S) or IsInc(S) or IsDpk(S);
  end
  else
    SubActions[Index].Enabled := True;
end;

procedure TCnCodeFormatterForm.chkAutoWrapClick(Sender: TObject);
begin
  seWrapLine.Enabled := chkAutoWrap.Checked;
  seNewLine.Enabled := chkAutoWrap.Checked;
end;

procedure TCnCodeFormatterForm.FormShow(Sender: TObject);
begin
  chkAutoWrapClick(chkAutoWrap);
end;

function TCnCodeFormatterForm.GetHelpTopic: string;
begin
  Result := 'CnCodeFormatterWizard';
end;

procedure TCnCodeFormatterForm.btnShortCutClick(Sender: TObject);
begin
  if FWizard.ShowShortCutDialog(GetHelpTopic) then
    FWizard.DoSaveSettings;
end;

procedure TCnCodeFormatterForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (ModalResult = mrOK) and (seNewLine.Value < seWrapLine.Value) then
  begin
    ErrorDlg(SCnCodeFormatterWizardErrLineWidth);
    CanClose := False;
  end;
end;

procedure TCnCodeFormatterForm.seWrapLineChange(Sender: TObject);
begin
  seNewLine.MinValue := seWrapLine.Value;
end;

procedure TCnCodeFormatterForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

{$IFDEF DELPHI_OTA}

procedure TCnCodeFormatterWizard.RestoreBreakpoints(LineMarks: PDWORD; Count: Integer);
var
  I: Integer;
{$IFDEF OTA_NEW_BREAKPOINT_NOBUG}
  DS: IOTADebuggerServices;
  BP: IOTABreakpoint;
{$ELSE}
  Prev: DWORD;
{$ENDIF}
begin
  if (LineMarks = nil) or (Count = 0) then
    Exit;

{$IFDEF OTA_NEW_BREAKPOINT_NOBUG}
  // ��� OTA �ӿ�û Bug ��֧�������ϵ�Ļ�
  I := 0;
  if BorlandIDEServices.QueryInterface(IOTADebuggerServices, DS) = S_OK then
  begin
    while (LineMarks^ <> 0) and (I < Count) do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogInteger(LineMarks^, 'Will Create Breakpoint using OTA at');
{$ENDIF}
      // ��ǰ�ļ����� OutLineMarks^ �еĶϵ㣬������ Enabled
      BP := DS.NewSourceBreakpoint(CnOtaGetCurrentSourceFileName, LineMarks^, nil);
      if (BP <> nil) and not TCnBreakpointDescriptor(FBreakpoints[I]).Enabled then
        BP.Enabled := False;

      Inc(I);
      Inc(LineMarks);
    end;
  end;
{$ELSE}
  // OTA �ӿ��� Bug �޷������ϵ㣬ֻ���ù�����ģ�����ķ�ʽ����
  Prev := 0;
  I := 0;
  while (LineMarks^ <> 0) and (I < Count) do
  begin
    if LineMarks^ = Prev then // ���ڵ�ͬ�е�Ҫ����һ����������ε������ʧ
    begin
      Inc(LineMarks);
      Inc(I);
      Continue;
    end;

    Prev := LineMarks^;
{$IFDEF DEBUG}
    CnDebugger.LogInteger(LineMarks^, 'Will Create Breakpoint using Click at');
{$ENDIF}
    // ��ǰ�ļ����� OutLineMarks^ �еĶϵ㣬���޷����� Enabled
    EditControlWrapper.ClickBreakpointAtActualLine(LineMarks^);
    Inc(I);
    Inc(LineMarks);
  end;
{$ENDIF}
end;

procedure TCnCodeFormatterWizard.RestoreBookmarks(EditView: IOTAEditView;
  LineMarks: PDWORD);
var
  I: Integer;
begin
  if (LineMarks = nil) or (EditView = nil) then
    Exit;

  I := 0;
  while LineMarks^ <> 0 do
  begin
    if I >= FBookmarks.Count then
      Break;

    TCnBookmarkObject(FBookmarks[I]).Line := LineMarks^;
    Inc(I);
    Inc(LineMarks);
  end;

  ReplaceBookMarksFromObjectList(EditView, FBookmarks);
end;

procedure TCnCodeFormatterWizard.ObtainLineElideInfo(List: TList);
var
  I: Integer;
begin
  CnOtaGetLinesElideInfo(List);

  if List.Count > 0 then
  begin
    for I := List.Count - 1 downto 0 do
    begin
      if (I and 1) <> 0 then // ����Ҫɾ����ֻ���۵��鿪ʼ���к�
        List.Delete(I);
    end;
  end;
end;

{$IFDEF IDE_EDITOR_ELIDE}

procedure TCnCodeFormatterWizard.ElideOnTimer(Sender: TObject);
var
  Control: TControl;
begin
  Control := CnOtaGetCurrentEditControl;
  if (FElideMarks = nil) or (Control = nil) then
    Exit;

  while FElideMarks^ <> 0 do
  begin
    EditControlWrapper.ElideLine(Control, FElideMarks^);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('In Timer to Restore Elide Lines Line: %d', [FElideMarks^]);
{$ENDIF}
    Inc(FElideMarks);
  end;
end;

procedure TCnCodeFormatterWizard.RestoreElideLines(LineMarks: PDWORD);
begin
  FElideMarks := LineMarks;
  FElideTimer.Enabled := True;
end;

{$ENDIF}
{$ENDIF}

initialization
{$IFNDEF BCB5OR6}  // Ŀǰֻ֧�� Delphi/Lazarus��
  RegisterCnWizard(TCnCodeFormatterWizard);
{$ENDIF}

{$ENDIF CNWIZARDS_CNCODEFORMATTERWIZARD}
end.

