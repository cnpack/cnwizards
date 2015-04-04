{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2015 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnCodeFormatterWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码格式化专家单元
* 单元作者：刘啸(LiuXiao) liuxiao@cnpack.org
* 备    注：
* 开发平台：WinXP + Delphi 5
* 兼容测试：暂无（PWin9X/2000/XP/7 Delphi 5/6/7 + C++Builder 5/6）
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2015.03.11 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODEFORMATTERWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, StdCtrls, ComCtrls, CnSpin,
  CnConsts, CnCommon, CnWizConsts, CnWizClasses, CnWizMultiLang, CnWizOptions,
  CnWizUtils, CnFormatterIntf, CnCodeFormatRules;

type
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
    procedure chkAutoWrapClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

  TCnCodeFormatterWizard = class(TCnSubMenuWizard)
  private
    FIdOptions: Integer;
    FIdFormatCurrent: Integer;

    FLibHandle: THandle;
    FGetProvider: TCnGetFormatterProvider;

    // Pascal Format Settings
    FUsesUnitSingleLine: Boolean;
    FUseIgnoreArea: Boolean;
    FSpaceAfterOperator: Byte;
    FSpaceBeforeOperator: Byte;
    FSpaceBeforeASM: Byte;
    FTabSpaceCount: Byte;
    FSpaceTabASMKeyword: Byte;
    FWrapWidth: Integer;
    FBeginStyle: TBeginStyle;
    FKeywordStyle: TKeywordStyle;
    FWrapMode: TCodeWrapMode;

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
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure AcquireSubActions; override;

    property KeywordStyle: TKeywordStyle read FKeywordStyle write FKeywordStyle;
    property BeginStyle: TBeginStyle read FBeginStyle write FBeginStyle;
    property WrapMode: TCodeWrapMode read FWrapMode write FWrapMode;
    property TabSpaceCount: Byte read FTabSpaceCount write FTabSpaceCount;
    property SpaceBeforeOperator: Byte read FSpaceBeforeOperator write FSpaceBeforeOperator;
    property SpaceAfterOperator: Byte read FSpaceAfterOperator write FSpaceAfterOperator;
    property SpaceBeforeASM: Byte read FSpaceBeforeASM write FSpaceBeforeASM;
    property SpaceTabASMKeyword: Byte read FSpaceTabASMKeyword write FSpaceTabASMKeyword;
    property WrapWidth: Integer read FWrapWidth write FWrapWidth;
    property UsesUnitSingleLine: Boolean read FUsesUnitSingleLine write FUsesUnitSingleLine;
    property UseIgnoreArea: Boolean read FUseIgnoreArea write FUseIgnoreArea;
  end;

var
  CnCodeFormatterForm: TCnCodeFormatterForm;

{$ENDIF CNWIZARDS_CNCODEFORMATTERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODEFORMATTERWIZARD}

{$R *.DFM}

const
{$IFDEF UNICODE}
  DLLName: string = 'CnFormatLibW.dll';
{$ELSE}
  DLLName: string = 'CnFormatLib.dll';
{$ENDIF}

  csUsesUnitSingleLine = 'UsesUnitSingleLine';
  csUseIgnoreArea = 'UseIgnoreArea';
  csSpaceAfterOperator = 'SpaceAfterOperator';
  csSpaceBeforeOperator = 'SpaceBeforeOperator';
  csSpaceBeforeASM = 'SpaceBeforeASM';
  csTabSpaceCount = 'TabSpaceCount';
  csSpaceTabASMKeyword = 'SpaceTabASMKeyword';
  csWrapWidth = 'WrapWidth';
  csWrapMode = 'WrapMode';
  csBeginStyle = 'BeginStyle';
  csKeywordStyle = 'KeywordStyle';
  
{ TCnCodeFormatterWizard }

procedure TCnCodeFormatterWizard.AcquireSubActions;
begin
  FIdFormatCurrent := RegisterASubAction(SCnCodeFormatterWizardFormatCurrent,
    SCnCodeFormatterWizardFormatCurrentCaption, 0, SCnCodeFormatterWizardFormatCurrentHint);
  // Other Menus
  
  AddSepMenu;
  FIdOptions := RegisterASubAction(SCnCodeFormatterWizardConfig,
    SCnCodeFormatterWizardConfigCaption, 0, SCnCodeFormatterWizardConfigHint);
end;

procedure TCnCodeFormatterWizard.Config;
begin
  with TCnCodeFormatterForm.Create(nil) do
  begin
    cbbKeywordStyle.ItemIndex := Ord(FKeywordStyle);
    cbbBeginStyle.ItemIndex := Ord(FBeginStyle);
    seTab.Value := FTabSpaceCount;
    chkAutoWrap.Checked := (FWrapMode = cwmSimple);
    seWrapLine.Value := FWrapWidth;
    seSpaceBefore.Value := FSpaceBeforeOperator;
    seSpaceAfter.Value := FSpaceAfterOperator;
    chkUsesSinglieLine.Checked := FUsesUnitSingleLine;

    seASMHeadIndent.Value := FSpaceBeforeASM;
    seAsmTab.Value := FSpaceTabASMKeyword;
    chkIgnoreArea.Checked := FUseIgnoreArea;

    if ShowModal = mrOK then
    begin
      FKeywordStyle := TKeywordStyle(cbbKeywordStyle.ItemIndex);
      FBeginStyle := TBeginStyle(cbbBeginStyle.ItemIndex);
      FTabSpaceCount := seTab.Value;
      FWrapWidth := seWrapLine.Value;
      if chkAutoWrap.Checked then
        FWrapMode := cwmSimple
      else
        FWrapMode := cwmNone;

      FSpaceBeforeOperator := seSpaceBefore.Value;
      FSpaceAfterOperator := seSpaceAfter.Value;
      FUsesUnitSingleLine := chkUsesSinglieLine.Checked;

      FSpaceBeforeASM := seASMHeadIndent.Value;
      FSpaceTabASMKeyword := seAsmTab.Value;
      FUseIgnoreArea := chkIgnoreArea.Checked;
    end;
    
    Free;
  end;
end;

constructor TCnCodeFormatterWizard.Create;
begin
  inherited;
  FLibHandle := LoadLibrary(PChar(MakePath(WizOptions.DllPath) + DLLName));
  if FLibHandle <> 0 then
    FGetProvider := TCnGetFormatterProvider(GetProcAddress(FLibHandle, 'GetCodeFormatterProvider'));
end;

destructor TCnCodeFormatterWizard.Destroy;
begin
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

class procedure TCnCodeFormatterWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := SCnCodeFormatterWizardName;
  Author := SCnPack_GuYueChunQiu + ';' + SCnPack_LiuXiao;
  Email := SCnPack_GuYueChunQiuEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnCodeFormatterWizardComment;
end;

procedure TCnCodeFormatterWizard.LoadSettings(Ini: TCustomIniFile);
begin
  FUsesUnitSingleLine := Ini.ReadBool('', csUsesUnitSingleLine, CnPascalCodeForVCLRule.UsesUnitSingleLine);
  FUseIgnoreArea := Ini.ReadBool('', csUseIgnoreArea, CnPascalCodeForVCLRule.UseIgnoreArea);
  FSpaceAfterOperator := Ini.ReadInteger('', csSpaceAfterOperator, CnPascalCodeForVCLRule.SpaceAfterOperator);
  FSpaceBeforeOperator := Ini.ReadInteger('', csSpaceBeforeOperator, CnPascalCodeForVCLRule.SpaceBeforeOperator);
  FSpaceBeforeASM := Ini.ReadInteger('', csSpaceBeforeASM, CnPascalCodeForVCLRule.SpaceBeforeASM);
  FTabSpaceCount := Ini.ReadInteger('', csTabSpaceCount, CnPascalCodeForVCLRule.TabSpaceCount);
  FSpaceTabASMKeyword := Ini.ReadInteger('', csSpaceTabASMKeyword, CnPascalCodeForVCLRule.SpaceTabASMKeyword);
  FWrapWidth := Ini.ReadInteger('', csWrapWidth, CnPascalCodeForVCLRule.WrapWidth);
  FWrapMode := TCodeWrapMode(Ini.ReadInteger('', csWrapMode, Ord(CnPascalCodeForVCLRule.CodeWrapMode)));
  FBeginStyle := TBeginStyle(Ini.ReadInteger('', csBeginStyle, Ord(CnPascalCodeForVCLRule.BeginStyle)));
  FKeywordStyle := TKeywordStyle(Ini.ReadInteger('', csKeywordStyle, Ord(CnPascalCodeForVCLRule.KeywordStyle)));
end;

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
  AWrapMode: DWORD;
  AUsesSingleLine: LongBool;
  AUseIgnoreArea: LongBool;
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
    bsNextLine: ABeginStyle := CN_RULE_BEGIN_STYLE_NEXTLINE;
    bsSameLine: ABeginStyle := CN_RULE_BEGIN_STYLE_SAMELINE;
  end;

  ATabSpace := FTabSpaceCount;
  ASpaceBeforeOperator := FSpaceBeforeOperator;
  ASpaceAfterOperator := FSpaceAfterOperator;
  ASpaceBeforeAsm := FSpaceBeforeASM;
  ASpaceTabAsm := FSpaceTabASMKeyword;
  ALineWrapWidth := FWrapWidth;

  case FWrapMode of
    cwmNone: AWrapMode := CN_RULE_CODE_WRAP_MODE_NONE;
    cwmSimple: AWrapMode := CN_RULE_CODE_WRAP_MODE_SIMPLE;
  end;

  AUsesSingleLine := LongBool(FUsesUnitSingleLine);
  AUseIgnoreArea := LongBool(FUseIgnoreArea);

  Intf.SetPascalFormatRule(ADirectiveMode, AKeywordStyle, ABeginStyle, AWrapMode,
    ATabSpace, ASpaceBeforeOperator, ASpaceAfterOperator, ASpaceBeforeAsm,
    ASpaceTabAsm, ALineWrapWidth, AUsesSingleLine, AUseIgnoreArea);
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
  Ini.WriteInteger('', csWrapMode, Ord(FWrapMode));
  Ini.WriteInteger('', csBeginStyle, Ord(FBeginStyle));
  Ini.WriteInteger('', csKeywordStyle, Ord(FKeywordStyle));
end;

procedure TCnCodeFormatterWizard.SubActionExecute(Index: Integer);
var
  Formatter: ICnPascalFormatterIntf;
{$IFDEF UNICODE}
  S: string;
  Res: PChar;
{$ELSE}
  S: AnsiString;
  Res: PAnsiChar;
{$ENDIF}
  ErrCode, SourceLine, SourceCol, SourcePos: Integer;
  CurrentToken: PAnsiChar;
begin
  if Index = FIdOptions then
    Config
  else if Index = FIdFormatCurrent then
  begin
    PutPascalFormatRules;

    Formatter := FGetProvider();
    if Formatter <> nil then
    begin
      try
{$IFDEF UNICODE}
        S := CnOtaGetCurrentEditorSourceW;
        Res := Formatter.FormatOnePascalUnitW(PChar(S), Length(S));
{$ELSE}
        S := AnsiString(CnOtaGetCurrentEditorSource);
        Res := Formatter.FormatOnePascalUnit(PAnsiChar(S), Length(S));
{$ENDIF}
        if Res <> nil then
        begin
{$IFDEF UNICODE}
          CnOtaSetCurrentEditorSourceW(string(Res));
{$ELSE}
          CnOtaSetCurrentEditorSource(string(Res));
{$ENDIF}
        end
        else
        begin
          ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
            SourcePos, CurrentToken);

          CnOtaGotoEditPos(OTAEditPos(SourceCol, SourceLine));
          ErrorDlg(Format(SCnCodeFormatterErrPascalFmt, [SourceLine, SourceCol,
            GetErrorStr(ErrCode), CurrentToken]));

//          ErrorDlg(Format('Error Code %d, Line %d, Col %d, Pos %d, Token %s', [ErrCode,
//            SourceLine, SourceCol, SourcePos, CurrentToken]));
        end;
      finally
        Formatter := nil;
      end;
    end;
  end;
end;

procedure TCnCodeFormatterWizard.SubActionUpdate(Index: Integer);
begin

end;

procedure TCnCodeFormatterForm.chkAutoWrapClick(Sender: TObject);
begin
  seWrapLine.Enabled := chkAutoWrap.Checked;
end;

procedure TCnCodeFormatterForm.FormShow(Sender: TObject);
begin
  chkAutoWrapClick(chkAutoWrap);
end;

function TCnCodeFormatterForm.GetHelpTopic: string;
begin
  Result := 'CnCodeFormatterWizard';
end;

initialization
{$IFNDEF BCB5}  // 目前只支持 Delphi。
{$IFNDEF BCB6}
  RegisterCnWizard(TCnCodeFormatterWizard);
{$ENDIF}
{$ENDIF}

{$ENDIF CNWIZARDS_CNCODEFORMATTERWIZARD}
end.
