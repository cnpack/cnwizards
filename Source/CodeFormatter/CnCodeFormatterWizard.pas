{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2016 CnPack 开发组                       }
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
  ToolsAPI, IniFiles, StdCtrls, ComCtrls, Menus, TypInfo, Contnrs, mPasLex, CnSpin,
  CnConsts, CnCommon, CnWizConsts, CnWizClasses, CnWizMultiLang, CnWizOptions,
{$IFDEF CNWIZARDS_CNINPUTHELPER}
  CnWizManager, CnInputHelper, CnInputSymbolList, CnInputIdeSymbolList,
{$ENDIF}
  CnStrings, CnPasCodeParser, CnWizUtils, CnFormatterIntf, CnCodeFormatRules,
  CnWizDebuggerNotifier, CnEditControlWrapper;

type
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
    FWrapNewLineWidth: Integer;

    FUseIDESymbols: Boolean;
    FBreakpoints: TObjectList;
    FBookmarks: TObjectList;

{$IFDEF CNWIZARDS_CNINPUTHELPER}
    FInputHelper: TCnInputHelper;
    FSymbolListMgr: TSymbolListMgr;
    FPreNamesList: TCnAnsiStringList;  // Lazy Create
    FPreNamesArray: array of PAnsiChar;
    procedure CheckObtainIDESymbols;
{$ENDIF}

    // 获取指定文件中的断点信息
    procedure ObtainBreakpointsByFile(const FileName: string);
    // 根据 DWORD 数组还原断点信息，碰到 0 或超过 Count 时结束
    procedure RestoreBreakpoints(LineMarks: PDWORD; Count: Integer = MaxInt);
    // 根据 DWORD 数组以及之前存储的 FBookmarks 还原书签信息
    procedure RestoreBookmarks(EditView: IOTAEditView; LineMarks: PDWORD);

    function PutPascalFormatRules: Boolean;
    function CheckSelectionPosition(StartPos: TOTACharPos; EndPos: TOTACharPos;
      View: IOTAEditView): Boolean;
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
    property WrapNewLineWidth: Integer read FWrapNewLineWidth write FWrapNewLineWidth;
    property UsesUnitSingleLine: Boolean read FUsesUnitSingleLine write FUsesUnitSingleLine;
    property UseIgnoreArea: Boolean read FUseIgnoreArea write FUseIgnoreArea;
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
    { Public declarations }
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
{$IFDEF UNICODE}
  DLLName: string = 'CnFormatLibW.dll'; // D2009 ~ 最新 用 Unicode 版
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  DLLName: string = 'CnFormatLibW.dll'; // D2005 ~ 2007 也用 Unicode 版但用 UTF8
  {$ELSE}
  DLLName: string = 'CnFormatLib.dll';  // D5~7 下用 Ansi 版
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

function TCnCodeFormatterWizard.CheckSelectionPosition(StartPos,
  EndPos: TOTACharPos; View: IOTAEditView): Boolean;
const
  InvalidTokens: set of TTokenKind =
    [tkBorComment, tkAnsiComment];
var
  Stream: TMemoryStream;
  Lex: TmwPasLex;
  NowPos: TOTACharPos;
  PrevToken: TTokenKind;
  NS, NE: Integer;

  // 1 > = < 2 分别返回 1 0 -1
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
  // 检查起始位置是否合法，比如不能在注释里面等
  Result := True;
  Stream := TMemoryStream.Create;
  Lex := TmwPasLex.Create;
  try
    CnOtaSaveEditorToStream(View.Buffer, Stream);
    Lex.Origin := PAnsiChar(Stream.Memory);

    PrevToken := tkUnknown;
    NowPos.CharIndex := 0;
    NowPos.Line := 0;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('CheckSelectionPosition. StartPos %d:%d. EndPos %d:%d', [StartPos.Line, StartPos.CharIndex,
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

      // 当前 Token 是注释、位置等于光标位置且前一 Token 是 CRLFCo
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

      if (NS > 0) and (NE > 0) then // 俩都比过了
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

{$IFDEF CNWIZARDS_CNINPUTHELPER}
    chkUseIDESymbols.Checked := FUseIDESymbols;
{$ELSE}
    chkUseIDESymbols.Enabled := False;
{$ENDIF}

    seASMHeadIndent.Value := FSpaceBeforeASM;
    seAsmTab.Value := FSpaceTabASMKeyword;
    chkIgnoreArea.Checked := FUseIgnoreArea;

    if ShowModal = mrOK then
    begin
      FKeywordStyle := TKeywordStyle(cbbKeywordStyle.ItemIndex);
      FBeginStyle := TBeginStyle(cbbBeginStyle.ItemIndex);
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
    end;
    
    Free;
  end;
end;

constructor TCnCodeFormatterWizard.Create;
begin
  inherited;
  FBreakpoints := TObjectList.Create(True);
  FBookmarks := TObjectList.Create(True);
  FLibHandle := LoadLibrary(PChar(MakePath(WizOptions.DllPath) + DLLName));
  if FLibHandle <> 0 then
    FGetProvider := TCnGetFormatterProvider(GetProcAddress(FLibHandle, 'GetCodeFormatterProvider'));
end;

destructor TCnCodeFormatterWizard.Destroy;
begin
{$IFDEF CNWIZARDS_CNINPUTHELPER}
  FPreNamesList.Free;
  SetLength(FPreNamesArray, 0);
{$ENDIF}

  FBookmarks.Free;
  FBreakpoints.Free;
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
  FWrapNewLineWidth := Ini.ReadInteger('', csWrapNewLineWidth, CnPascalCodeForVCLRule.WrapNewLineWidth);
  FWrapMode := TCodeWrapMode(Ini.ReadInteger('', csWrapMode, Ord(CnPascalCodeForVCLRule.CodeWrapMode)));
  FBeginStyle := TBeginStyle(Ini.ReadInteger('', csBeginStyle, Ord(CnPascalCodeForVCLRule.BeginStyle)));
  FKeywordStyle := TKeywordStyle(Ini.ReadInteger('', csKeywordStyle, Ord(CnPascalCodeForVCLRule.KeywordStyle)));
{$IFDEF CNWIZARDS_CNINPUTHELPER}
  FUseIDESymbols := Ini.ReadBool('', csUseIDESymbols, False);
{$ENDIF}
end;

{$IFDEF CNWIZARDS_CNINPUTHELPER}

procedure TCnCodeFormatterWizard.CheckObtainIDESymbols;
var
  IDESymbols, UnitNames: TSymbolList;
  Buffer: IOTAEditBuffer;
  PosInfo: TCodePosInfo;
  I: Integer;

  procedure AddNameWithoutDuplicate(const AName: AnsiString);
  var
    Idx: Integer;
  begin
    if FPreNamesList.Find(AName, Idx) then
    begin
      // 有同名的，连原先同名的都要删掉，免得混乱
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
  CnDebugger.LogMsg('TCnCodeFormatterWizard IDE Symbols Got Count: ' + IntToStr(IDESymbols.Count));
{$ENDIF}
  end;

  UnitNames := FSymbolListMgr.ListByClass(TUnitNameList);
  if UnitNames <> nil then
  begin
    PosInfo.PosKind := pkIntfUses;
    PosInfo.AreaKind := akIntfUses;
    UnitNames.Reload(Buffer, '', PosInfo);

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnCodeFormatterWizard Unit Names Got Count: ' + IntToStr(UnitNames.Count));
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

  SetLength(FPreNamesArray, FPreNamesList.Count + 1); // 末尾一个 nil
  FillChar(FPreNamesArray[0], Length(FPreNamesArray) * SizeOf(PAnsiChar), 0);

  for I := 0 to FPreNamesList.Count - 1 do
    FPreNamesArray[I] := PAnsiChar(FPreNamesList[I]);
end;

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
  ANewLineWrapWidth := FWrapNewLineWidth;

  case FWrapMode of
    cwmNone: AWrapMode := CN_RULE_CODE_WRAP_MODE_NONE;
    cwmSimple: AWrapMode := CN_RULE_CODE_WRAP_MODE_SIMPLE;
    cwmAdvanced: AWrapMode := CN_RULE_CODE_WRAP_MODE_ADVANCED;
  end;

  AUsesSingleLine := LongBool(FUsesUnitSingleLine);
  AUseIgnoreArea := LongBool(FUseIgnoreArea);

  Intf.SetPascalFormatRule(ADirectiveMode, AKeywordStyle, ABeginStyle, AWrapMode,
    ATabSpace, ASpaceBeforeOperator, ASpaceAfterOperator, ASpaceBeforeAsm,
    ASpaceTabAsm, ALineWrapWidth, ANewLineWrapWidth, AUsesSingleLine, AUseIgnoreArea);
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
{$IFDEF CNWIZARDS_CNINPUTHELPER}
  Ini.WriteBool('', csUseIDESymbols, FUseIDESymbols);
{$ENDIF}
end;

procedure TCnCodeFormatterWizard.SubActionExecute(Index: Integer);
var
  Formatter: ICnPascalFormatterIntf;
  View: IOTAEditView;
  Src: string;
  Res: PChar;
  I, ErrCode, SourceLine, SourceCol, SourcePos: Integer;
  CurrentToken: PAnsiChar;
  Block: IOTAEditBlock;
  StartPos, EndPos, StartPosIn, EndPosIn: Integer;
  StartRec, EndRec: TOTACharPos;
  ErrLine: string;
  BpBmLineMarks: array of DWORD;
  OutLineMarks: PDWORD;

  // 将解析器中返回的出错列转换成 IDE 里内部使用的列供定位，BDS 以上是 Utf8
  function ConvertToEditorCol(const Line: string; Col: Integer): Integer;
  var
    S: WideString;
  begin
{$IFDEF IDE_STRING_ANSI_UTF8}
    // Col 返回的是 Unicode 的列，Line 是 Ansi 的，需要转成 Utf8 的列
    S := WideString(Line);
    S := Copy(S, 1, Col);
    Result := Length(UTF8Encode(S));
{$ELSE}
  {$IFDEF UNICODE}
    // Col 返回的是 Unicode 的列，Line 是 Unicode 的，需要转成 Utf8 的列
    S := Copy(Line, 1, Col);
    Result := Length(UTF8Encode(S));
  {$ELSE}
    Result := Col;
  {$ENDIF}
{$ENDIF}
  end;

  // 将解析器中返回的出错列转换成 IDE 里显示的列供显示，均是 Ansi
  function ConvertToVisibleCol(const Line: string; Col: Integer): Integer;
  var
    S: WideString;
  begin
{$IFDEF IDE_STRING_ANSI_UTF8}
    // Col 返回的是 Unicode 的列，Line 是 Ansi 的，需要转成 Ansi 的列
    S := WideString(Line);
    S := Copy(S, 1, Col);
    Result := Length(AnsiString(S));
{$ELSE}
  {$IFDEF UNICODE}
    // Col 返回的是 Unicode 的列，Line 是 Unicode 的，需要转成 Ansi 的列
    S := Copy(Line, 1, Col);
    Result := Length(AnsiString(S));
  {$ELSE}
    Result := Col;
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

    // 记录断点信息
    ObtainBreakpointsByFile(CnOtaGetCurrentSourceFileName);
    SaveBookMarksToObjectList(View, FBookmarks);
    if (FBreakpoints.Count = 0) and (FBookmarks.Count = 0) then
      Formatter.SetInputLineMarks(nil);

{$IFDEF CNWIZARDS_CNINPUTHELPER}
    CheckObtainIDESymbols;
    if Length(FPreNamesArray) > 0 then
    begin
      Formatter.SetPreIdentifierNames(PLPSTR(FPreNamesArray));
      SetLength(FPreNamesArray, 0);
      FPreNamesList.Clear;
    end;
{$ENDIF}

    if (View.Block = nil) or not View.Block.IsValid then // 无选择区
    begin
      try
        Screen.Cursor := crHourGlass;

        // 传递断点与书签的行号
        if FBreakpoints.Count + FBookmarks.Count > 0 then
        begin
          SetLength(BpBmLineMarks, FBreakpoints.Count + FBookmarks.Count + 1); // 末尾多一个 0
          for I := 0 to FBreakpoints.Count - 1 do
            BpBmLineMarks[I] := DWORD(TCnBreakpointDescriptor(FBreakpoints[I]).LineNumber);
          for I := 0 to FBookmarks.Count - 1 do
            BpBmLineMarks[I + FBreakpoints.Count] := DWORD(TCnBookmarkObject(FBookmarks[I]).Line);
          BpBmLineMarks[FBreakpoints.Count + FBookmarks.Count] := 0;

          Formatter.SetInputLineMarks(@(BpBmLineMarks[0]));
        end;
        SetLength(BpBmLineMarks, 0);

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
        if Res <> nil then
        begin
{$IFDEF UNICODE}
          // Utf16 内部转 Utf8 写入
          CnOtaSetCurrentEditorSourceW(string(Res));
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
          // Utf8 直接写入
          CnOtaSetCurrentEditorSourceUtf8(string(Res));
  {$ELSE}
          // Ansi 转 Utf8 写入
          CnOtaSetCurrentEditorSource(string(Res));
  {$ENDIF}
{$ENDIF}

          // 恢复断点与书签信息
          OutLineMarks := Formatter.RetrieveOutputLinkMarks;
          if FBookmarks.Count = 0 then
            RestoreBreakpoints(OutLineMarks)
          else
          begin
            RestoreBreakpoints(OutLineMarks, FBreakpoints.Count);
            // 恢复书签
            Inc(OutLineMarks, FBreakpoints.Count);
            RestoreBookmarks(View, OutLineMarks);
          end;
        end
        else
        begin
          ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
            SourcePos, CurrentToken);
          Screen.Cursor := crDefault;

          ErrLine := CnOtaGetLineText(SourceLine, View.Buffer);
          CnOtaGotoEditPos(OTAEditPos(ConvertToEditorCol(ErrLine, SourceCol), SourceLine));
          ErrorDlg(Format(SCnCodeFormatterErrPascalFmt, [SourceLine, ConvertToVisibleCol(ErrLine, SourceCol),
            GetErrorStr(ErrCode), CurrentToken]));
        end;
      finally
        Formatter := nil;
        Screen.Cursor := crDefault;
      end;
    end
    else // 有选择区
    begin
      try
        Screen.Cursor := crHourGlass;
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

        View := CnOtaGetTopMostEditView;
        if View <> nil then
        begin
          Block := View.Block;
          if (Block <> nil) and Block.IsValid then
          begin
            // 选择块起止位置延伸到行模式
            if not CnOtaGetBlockOffsetForLineMode(StartRec, EndRec, View) then
              Exit;

            // 如果选择区起始位置在注释中间，无法处理，出错
            if not CheckSelectionPosition(StartRec, EndRec, View) then
            begin
              ErrorDlg(SCnCodeFormatterWizardErrSelection);
              Exit;
            end;

            // 传递选择区间断点的行号
            if FBreakpoints.Count > 0 then
            begin
              for I := FBreakpoints.Count - 1 downto 0 do
                if not TCnBreakpointDescriptor(FBreakpoints[I]).LineNumber in
                  [StartRec.Line, EndRec.Line] then
                  FBreakpoints.Delete(I);
            end;

            if FBookmarks.Count > 0 then
            begin
              for I := FBookmarks.Count - 1 downto 0 do
                if not TCnBookmarkObject(FBookmarks[I]).Line in
                  [StartRec.Line, EndRec.Line] then
                  FBookmarks.Delete(I);
            end;

            if FBreakpoints.Count + FBookmarks.Count > 0 then
            begin
              SetLength(BpBmLineMarks, FBreakpoints.Count + FBookmarks.Count + 1); // 末尾多一个 0
              for I := 0 to FBreakpoints.Count - 1 do
                BpBmLineMarks[I] := DWORD(TCnBreakpointDescriptor(FBreakpoints[I]).LineNumber);
              for I := 0 to FBookmarks.Count - 1 do
                BpBmLineMarks[I + FBreakpoints.Count] := DWORD(TCnBookmarkObject(FBookmarks[I]).Line);

              BpBmLineMarks[FBreakpoints.Count + FBookmarks.Count] := 0;
              Formatter.SetInputLineMarks(@(BpBmLineMarks[0]));
            end
            else
              Formatter.SetInputLineMarks(nil);
            SetLength(BpBmLineMarks, 0);

            StartPos := CnOtaEditPosToLinePos(OTAEditPos(StartRec.CharIndex, StartRec.Line), View);
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(EndRec.CharIndex, EndRec.Line), View);

            // 此时 StartPos 和 EndPos 标记了当前选择区内要处理的文本
{$IFDEF UNICODE}
            // Src/Res Utf16，俩 LinearPos 是 Utf8 的偏移量，需要转换
            StartPosIn := Length(UTF8Decode(Copy(Utf8Encode(Src), 1, StartPos + 1))) - 1;
            EndPosIn := Length(UTF8Decode(Copy(Utf8Encode(Src), 1, EndPos + 1))) - 1;
            Res := Formatter.FormatPascalBlockW(PChar(Src), Length(Src), StartPosIn, EndPosIn);

            // Remove FF FE BOM if exists
            if (Res <> nil) and (StrLen(Res) > 1) and (Res[0] = #$FEFF) then
              Inc(Res);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
            // Src/Res Utf8
            StartPosIn := StartPos;
            EndPosIn := EndPos;
            Res := Formatter.FormatPascalBlockUtf8(PAnsiChar(Src), Length(Src), StartPosIn, EndPosIn);

            // Remove EF BB BF BOM if exist
            if (Res <> nil) and (StrLen(Res) > 3) and
              (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
              Inc(Res, 3);
  {$ELSE}
            // Src/Res Ansi
            StartPosIn := StartPos;
            EndPosIn := EndPos;
            // IDE 内的线性 Pos 是 0 开始的，使用 Src 来 Copy 时的下标以 1 开始，因此需要加 1
            Res := Formatter.FormatPascalBlock(PAnsiChar(Src), Length(Src), StartPosIn, EndPosIn);
  {$ENDIF}
{$ENDIF}

            if Res <> nil then
            begin
{$IFDEF DEBUG}
              CnDebugger.LogRawString('Format Selection Result: ' + Res);
{$ENDIF}
              {$IFDEF IDE_STRING_ANSI_UTF8}
              CnOtaReplaceCurrentSelectionUtf8(Res, True, True, True);
              {$ELSE}
              // Ansi/Unicode 均可用
              CnOtaReplaceCurrentSelection(Res, True, True, True);
              {$ENDIF}

              // 恢复断点与书签信息
              OutLineMarks := Formatter.RetrieveOutputLinkMarks;
              if FBookmarks.Count = 0 then
                RestoreBreakpoints(OutLineMarks)
              else
              begin
                RestoreBreakpoints(OutLineMarks, FBreakpoints.Count);
                // 恢复书签信息
                Inc(OutLineMarks, FBreakpoints.Count);
                RestoreBookmarks(View, OutLineMarks);
              end;
            end
            else
            begin
              ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
                SourcePos, CurrentToken);
              Screen.Cursor := crDefault;

              ErrLine := CnOtaGetLineText(SourceLine, View.Buffer);
              CnOtaGotoEditPos(OTAEditPos(ConvertToEditorCol(ErrLine, SourceCol), SourceLine));
              ErrorDlg(Format(SCnCodeFormatterErrPascalFmt, [SourceLine, ConvertToVisibleCol(ErrLine, SourceCol),
                GetErrorStr(ErrCode), CurrentToken]));
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

procedure TCnCodeFormatterForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if seNewLine.Value < seWrapLine.Value then
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

procedure TCnCodeFormatterWizard.ObtainBreakpointsByFile(
  const FileName: string);
var
  DS: IOTADebuggerServices;
  SB: IOTASourceBreakpoint;
  BD: TCnBreakpointDescriptor;
  I: Integer;

  function CheckDuplicated(const AFileName: string; ALineNumber: Integer): TCnBreakpointDescriptor;
  var
    I: Integer;
    B: TCnBreakpointDescriptor;
  begin
    Result := nil;
    for I := 0 to FBreakpoints.Count - 1 do
    begin
      B := TCnBreakpointDescriptor(FBreakpoints[I]);
      if (B.FileName = AFileName) and (B.LineNumber = ALineNumber) then
      begin
        Result := B;
        Exit;
      end;
    end;
  end;

begin
  FBreakpoints.Clear;
  if BorlandIDEServices.QueryInterface(IOTADebuggerServices, DS) <> S_OK then
    Exit;

  for I := 0 to DS.SourceBkptCount - 1 do
  begin
    SB := DS.SourceBkpts[I];
    if (FileName = '') or (SB.FileName = FileName) then
    begin
      BD := CheckDuplicated(SB.FileName, SB.LineNumber);
      if BD <> nil then
        BD.Enabled := sb.Enabled
      else
      begin
        BD := TCnBreakpointDescriptor.Create;
        BD.FileName := SB.FileName;
        BD.LineNumber := SB.LineNumber;
        BD.Enabled := SB.Enabled;
        FBreakpoints.Add(BD);
      end;
    end;
  end;
end;

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
  // 如果 OTA 接口没 Bug 而支持新增断点的话
  I := 0;
  if BorlandIDEServices.QueryInterface(IOTADebuggerServices, DS) = S_OK then
  begin
    while (LineMarks^ <> 0) and (I < Count) do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogInteger(LineMarks^, 'Will Create Breakpoint using OTA at');
{$ENDIF}
      // 当前文件新增 OutLineMarks^ 行的断点，并设置 Enabled
      BP := DS.NewSourceBreakpoint(CnOtaGetCurrentSourceFileName, LineMarks^, nil);
      if (BP <> nil) and not TCnBreakpointDescriptor(FBreakpoints[I]).Enabled then
        BP.Enabled := False;

      Inc(I);
      Inc(LineMarks);
    end;
  end;
{$ELSE}
  // OTA 接口有 Bug 无法新增断点，只能用滚屏并模拟点击的方式新增
  Prev := 0;
  I := 0;
  while (LineMarks^ <> 0) and (I < Count) do
  begin
    if LineMarks^ = Prev then // 相邻的同行的要忽略一个，免得两次点击后消失
    begin
      Inc(LineMarks);
      Inc(I);
      Continue;
    end;

    Prev := LineMarks^;
{$IFDEF DEBUG}
    CnDebugger.LogInteger(LineMarks^, 'Will Create Breakpoint using Click at');
{$ENDIF}
    // 当前文件新增 OutLineMarks^ 行的断点，但无法处理 Enabled
    EditControlWrapper.ClickBreakpointAtActualLine(LineMarks^);
    Inc(I);
    Inc(LineMarks);
  end;
{$ENDIF}
end;

procedure TCnCodeFormatterWizard.RestoreBookmarks(EditView: IOTAEditView; LineMarks: PDWORD);
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

initialization
{$IFNDEF BCB5}  // 目前只支持 Delphi。
{$IFNDEF BCB6}
  RegisterCnWizard(TCnCodeFormatterWizard);
{$ENDIF}
{$ENDIF}

{$ENDIF CNWIZARDS_CNCODEFORMATTERWIZARD}
end.
