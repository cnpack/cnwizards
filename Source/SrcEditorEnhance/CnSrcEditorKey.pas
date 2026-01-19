{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnSrcEditorKey;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器按键扩展工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：当前编辑器的 IOTAEditPosition 的 SearchAgain 方法经常返回 False
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2015.04.25
*             在 D2005 以上使用 Wide Parser 修正 Utf8/Unicode 转换为 AnsiString
*                 解析时可能丢字符信息的问题。
*           2015.02.03
*             加入禁止光标超出行尾的功能，默认禁用
*           2011.06.14
*             加入行首尾按左右键折行的功能
*           2008.12.25
*             加入 F2 修改当前变量名的功能
*           2005.08.30
*             创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, Menus, Clipbrd, ActnList, StdCtrls, ComCtrls, Imm, Math, TypInfo,
  CnPasCodeParser, CnCommon, CnConsts, CnWizUtils, CnWizConsts, CnWizOptions,
  CnWizIdeUtils, CnEditControlWrapper, CnWizNotifier, CnWizMethodHook, CnNative,
  CnWizCompilerConst, CnSrcEditorNav,
  {$IFDEF IDE_WIDECONTROL}
  CnWidePasParser, CnWideCppParser,
  {$ENDIF}
  CnCppCodeParser, Contnrs;

type
  TCnAutoMatchType = (btNone, btBracket, btSquare, btCurly, btQuote, btDitto); // () [] {} '' ""

  TCnRenameIdentifierType = (ritInvalid, ritUnit, ritCurrentProc, ritInnerProc, ritCppHPair, ritCurrentBlock);
  // Pascal： 整个文件、当前最外层过程、当前最内层过程、当前 Block
  // C/C++：  整个文件、当前最外层大括号（如果非namespace）或次外层（最外是namespace)
              // 当前最内层大括号、整个 Cpp 以及相应的 H文 件、当前大括号。

//==============================================================================
// 代码编辑器按键扩展功能
//==============================================================================

{ TCnSrcEditorKey }

  TCnSrcEditorKey = class(TPersistent)
  private
    FActive: Boolean;
    FOnEnhConfig: TNotifyEvent;
    FNavMgrRef: TCnSrcEditorNavMgr; // 供拦截 Alt 左右键配合用
    FAutoMatchEntered: Boolean;
    FAutoMatchType: TCnAutoMatchType;
    FRepaintView: TCnNativeUInt; // 供传递重画参数用
    FSmartCopy: Boolean;
    FSmartPaste: Boolean;
    FPasteReplace: Boolean;
    FShiftEnter: Boolean;
    FAutoIndent: Boolean;
    FAutoIndentList: TStringList;
    FHomeExt: Boolean;
    FHomeFirstChar: Boolean;
    FCursorBeforeEOL: Boolean;
    FLeftLineWrap: Boolean;
    FRightLineWrap: Boolean;
    FF3Search: Boolean;
    FAutoBracket: Boolean;
    FF2Rename: Boolean;
    FRenameShortCut: TShortCut;
    FRenameKey: Word;
    FRenameShift: TShiftState;
    FSemicolonLastChar: Boolean;
    FAutoEnterEnd: Boolean;
    FKeepSearch: Boolean;
    FCorIdeModule: HModule;
    FSearchWrap: Boolean;
    FUpperFirstLetter: Boolean;

    FCursorMoving: Boolean;
{$IFNDEF DELPHI10_UP}
    FSaveLineNo: Integer;
    FNeedChangeInsert: Boolean;

    procedure IdleDoAutoInput(Sender: TObject);
    procedure IdleDoAutoIndent(Sender: TObject);
    procedure IdleDoCBracketIndent(Sender: TObject);
{$ENDIF}
    function ProcessSmartPaste(View: IOTAEditView): Boolean;
    procedure SetKeepSearch(const Value: Boolean);
    procedure SetRenameShortCut(const Value: TShortCut);
  protected
    procedure SetActive(Value: Boolean);
    procedure DoEnhConfig;
    function DoAutoMatchEnter(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoSmartCopy(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoShiftEnter(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
{$IFNDEF DELPHI10_UP}
    function DoAutoIndent(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
{$ENDIF}
    function DoHomeExtend(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoLeftRightLineWrap(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoSemicolonLastChar(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoSearchAgain(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoRename(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
{$IFDEF IDE_WIDECONTROL}
    // Unicode/Utf8 版本，用于 D2005 或以上，解决转换成 Ansi 后会丢字符的问题
    function DoRenameW(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    procedure ConvertToUtf8Stream(Stream: TStream);
{$ENDIF}
    procedure EditControlKeyDown(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure EditControlSysKeyDown(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure EditControlKeyUp(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure ExecuteInsertCharOnIdle(Sender: TObject);

    procedure SnapCursorToEol;
    procedure EditorChanged(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);
{$IFDEF DELPHI104_SYDNEY_UP}
    procedure EditorMouseUp(Editor: TCnEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
{$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    procedure ResetSettings(Ini: TCustomIniFile);
    procedure LanguageChanged(Sender: TObject);

    function IsValidRenameIdent(const Ident: string): Boolean;
  published
    property Active: Boolean read FActive write SetActive;
    property SmartCopy: Boolean read FSmartCopy write FSmartCopy;
    property SmartPaste: Boolean read FSmartPaste write FSmartPaste;
    property PasteReplace: Boolean read FPasteReplace write FPasteReplace;
    property ShiftEnter: Boolean read FShiftEnter write FShiftEnter;
    property F3Search: Boolean read FF3Search write FF3Search;
    property F2Rename: Boolean read FF2Rename write FF2Rename;
    property RenameShortCut: TShortCut read FRenameShortCut write SetRenameShortCut;
    property KeepSearch: Boolean read FKeepSearch write SetKeepSearch;
    property SearchWrap: Boolean read FSearchWrap write FSearchWrap;
    property AutoIndent: Boolean read FAutoIndent write FAutoIndent;
    property AutoIndentList: TStringList read FAutoIndentList;
    property HomeExt: Boolean read FHomeExt write FHomeExt;
    property HomeFirstChar: Boolean read FHomeFirstChar write FHomeFirstChar;
    property CursorBeforeEOL: Boolean read FCursorBeforeEOL write FCursorBeforeEOL;
    property LeftLineWrap: Boolean read FLeftLineWrap write FLeftLineWrap;
    property RightLineWrap: Boolean read FRightLineWrap write FRightLineWrap;
    property AutoBracket: Boolean read FAutoBracket write FAutoBracket;
    property SemicolonLastChar: Boolean read FSemicolonLastChar write FSemicolonLastChar;
    property AutoEnterEnd: Boolean read FAutoEnterEnd write FAutoEnterEnd;
    property UpperFirstLetter: Boolean read FUpperFirstLetter write FUpperFirstLetter;
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF} CnIDEStrings, CnSrcEditorEnhance, CnWizManager,
  CnSourceHighlight, mPasLex, mwBCBTokenList, CnIdentRenameFrm, CnWideStrings;

{ TCnSrcEditorKey }

type
  TControlHack = class(TControl);
  TClickEventProc = procedure(ASelf: TObject; Sender: TObject);
{$IFDEF IDE_HAS_EDITOR_SEARCHPANEL}
  TDoSearchProc = procedure(ASelf: TObject; const Text: string);
{$ENDIF}

const
  SCnAutoIndentFile = 'AutoIndent.dat';
  {$IFDEF WIN64}
  SCnSrchDialogOKButtonClick = '_ZN7Srchdlg11TSrchDialog13OKButtonClickEPN6System7TObjectE';
  {$ELSE}
  SCnSrchDialogOKButtonClick = '@Srchdlg@TSrchDialog@OKButtonClick$qqrp14System@TObject';
  {$ENDIF}
  SCnSrchDialogComboName = 'SearchText';
  SCnHistoryPropComboBoxClassName = 'THistoryPropComboBox';
  SCnCaseSenseCheckBoxName = 'CaseSense';
  SCnWholeWordsCheckBoxName = 'WholeWords';
  SCnRegExpCheckBoxName = 'RegExp';
  SCnPropCheckBoxClassName = 'TPropCheckBox';

{$IFDEF IDE_HAS_EDITOR_SEARCHPANEL}
  SCnSearchPanelCaseSenseBoxName = 'CaseSenseBox';
  SCnSearchPanelWholeWordBoxName = 'WholeWordBox';
  SCnSearchPanelRegExBoxName = 'RegExBox';

{$IFDEF DELPHI120_ATHENS_UP}
  {$IFDEF WIN64}
  SCnEditWindowDoSearch = '_ZN10Editorform11TEditWindow8DoSearchEN6System13UnicodeStringE';
  {$ELSE}
  SCnEditWindowDoSearch = '@Editorform@TEditWindow@DoSearch$qqrx20System@UnicodeString';
  {$ENDIF}
{$ELSE}
  SCnEditWindowDoSearch = '@Editorform@TEditWindow@DoSearch$qqr20System@UnicodeString';
{$ENDIF}

  {$IFDEF WIN64}
  SCnEditWindowSearchUpClick = '_ZN10Editorform11TEditWindow13SearchUpClickEPN6System7TObjectE';
  SCnEditWindowSearchDnClick = '_ZN10Editorform11TEditWindow13SearchDnClickEPN6System7TObjectE';
  {$ELSE}
  SCnEditWindowSearchUpClick = '@Editorform@TEditWindow@SearchUpClick$qqrp14System@TObject';
  SCnEditWindowSearchDnClick = '@Editorform@TEditWindow@SearchDnClick$qqrp14System@TObject';
  {$ENDIF}
{$ENDIF}

var
  FOldSearchText: string = '';

  FOldSrchDialogOKButtonClick: Pointer = nil;
  FSearchDialogMethodHook: TCnMethodHook = nil;
{$IFDEF IDE_HAS_EDITOR_SEARCHPANEL}
  FOldEditWindowDoSearch: Pointer = nil;
  FOldEditWindowSearchUpClick: Pointer = nil;
  FOldEditWindowSearchDnClick: Pointer = nil;

  FEditWindowDoSearchMethodHook: TCnMethodHook = nil;
  FEditWindowSearchUpClickMethodHook: TCnMethodHook = nil;
  FEditWindowSearchDnClickMethodHook: TCnMethodHook = nil;
{$ENDIF}

  // 记录当前的搜索选项，有 IDE 搜索框以及编辑器下部的搜索条
  FCaseSense: Boolean;
  FWholeWords: Boolean;
  FRegExp: Boolean;

procedure CnSrchDialogOKButtonClick(ASelf, Sender: TObject);
var
  AForm: TCustomForm;
  AComp: TComponent;
  ANotify: TNotifyEvent;
{$IFDEF BDS}
  Len: Integer;
  WideText: WideString;
{$ENDIF}
begin
  if Sender is TButton then
  begin
    if (Sender as TComponent).Owner is TCustomForm then
    begin
      AForm := (Sender as TComponent).Owner as TCustomForm;
      AComp := AForm.FindComponent(SCnSrchDialogComboName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnHistoryPropComboBoxClassName)) then
      begin
{$IFNDEF BDS}
        if TControlHack(AComp).Text <> '' then // 记录 IDE 中的查找历史
          FOldSearchText := TControlHack(AComp).Text;
{$ELSE}
        // BDS 下 AComp 不是普通 Control 而是 WideControl，其 Text 属性是 WideString
        // 不能直接获得，需要获取地址再转换
        Len := TControl(AComp).Perform(WM_GETTEXTLENGTH, 0, 0);
        if Len > 0 then
        begin
          SetLength(WideText, Len);
{$IFDEF WIN64}
          TControl(AComp).Perform(WM_GETTEXT, (Len + 1) * SizeOf(Char), NativeUInt(WideText));
{$ELSE}
          TControl(AComp).Perform(WM_GETTEXT, (Len + 1) * SizeOf(Char), Longint(WideText));
{$ENDIF}

          FOldSearchText := string(WideText);
        end;
{$ENDIF}
      end;

      // 记录其他搜索选项备 F3Search 功能使用
      AComp := AForm.FindComponent(SCnCaseSenseCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FCaseSense := TCheckBox(AComp).Checked; // 记录 IDE 中的查找选项之大小写

      AComp := AForm.FindComponent(SCnWholeWordsCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FWholeWords := TCheckBox(AComp).Checked; // 记录 IDE 中的查找选项之整词

      AComp := AForm.FindComponent(SCnRegExpCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FRegExp := TCheckBox(AComp).Checked; // 记录 IDE 中的查找选项之正则

{$IFDEF DEBUG}
      CnDebugger.LogFmt('F3 Search: Get Options: Case %d, Word %d, Reg %d. ',
        [Integer(FCaseSense), Integer(FWholeWords), Integer(FRegExp)]);
{$ENDIF}
    end;
  end;

  if FOldSrchDialogOKButtonClick <> nil then
  begin
    if FSearchDialogMethodHook.UseDDteours then
      TClickEventProc(FSearchDialogMethodHook.Trampoline)(ASelf, Sender)
    else
    begin
      FSearchDialogMethodHook.UnhookMethod;
      TMethod(ANotify).Code := FOldSrchDialogOKButtonClick;
      TMethod(ANotify).Data := ASelf;
      ANotify(Sender);
      FSearchDialogMethodHook.HookMethod;
    end;
  end;
end;

{$IFDEF IDE_HAS_EDITOR_SEARCHPANEL}

procedure GetherSearchPanelOptions(AOwner: TComponent);
var
  Comp: TComponent;
  I: Integer;
  F1, F2, F3: Boolean;
begin
  if (AOwner = nil) or not AOwner.ClassNameIs(SCnEditorFormClassName) then
    Exit;

  F1 := False;
  F2 := False;
  F3 := False;
  for I := 0 to AOwner.ComponentCount - 1 do
  begin
    Comp := AOwner.Components[I];
    if (Comp is TCustomCheckBox) and Comp.ClassNameIs(SCnPropCheckBoxClassName) then
    begin
      if Comp.Name = SCnSearchPanelCaseSenseBoxName then
      begin
        FCaseSense := TCheckBox(Comp).Checked;
{$IFDEF DEBUG}
        CnDebugger.LogBoolean(FCaseSense, 'GetherSearchPanelOptions CaseSense');
{$ENDIF}
        F1 := True;
      end
      else if Comp.Name = SCnSearchPanelWholeWordBoxName then
      begin
        FWholeWords := TCheckBox(Comp).Checked;
{$IFDEF DEBUG}
        CnDebugger.LogBoolean(FWholeWords, 'GetherSearchPanelOptions WholeWords');
{$ENDIF}
        F2 := True;
      end
      else if Comp.Name = SCnSearchPanelRegExBoxName then
      begin
        FRegExp := TCheckBox(Comp).Checked;
{$IFDEF DEBUG}
        CnDebugger.LogBoolean(FWholeWords, 'GetherSearchPanelOptions RegExp');
{$ENDIF}
        F3 := True;
      end;
    end;

    if F1 and F2 and F3 then
      Exit;
  end;
end;

procedure CnEditWindowDoSearch(ASelf: Pointer; const Text: string);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Hooked EditWindowDoSearch: Got Search Text ' + Text);
{$ENDIF}

  FOldSearchText := Text;
  if FOldEditWindowDoSearch <> nil then
  begin
    if FEditWindowDoSearchMethodHook.UseDDteours then
      TDoSearchProc(FEditWindowDoSearchMethodHook.Trampoline)(ASelf, Text)
    else
    begin
      FEditWindowDoSearchMethodHook.UnhookMethod;
      TDoSearchProc(FOldEditWindowDoSearch)(ASelf, Text);
      FEditWindowDoSearchMethodHook.HookMethod;
    end;
  end;
end;

procedure CnEditWindowSearchUpClick(ASelf, Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Hooked EditWindowSearchUpClick.');
{$ENDIF}
  if ASelf is TComponent then
    GetherSearchPanelOptions(ASelf as TComponent);

  if FOldEditWindowSearchUpClick <> nil then
  begin
    if FEditWindowSearchUpClickMethodHook.UseDDteours then
      TClickEventProc(FEditWindowSearchUpClickMethodHook.Trampoline)(ASelf, Sender)
    else
    begin
      FEditWindowSearchUpClickMethodHook.UnhookMethod;
      TClickEventProc(FOldEditWindowSearchUpClick)(ASelf, Sender);
      FEditWindowSearchUpClickMethodHook.HookMethod;
    end;
  end;
end;

procedure CnEditWindowSearchDnClick(ASelf, Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Hooked EditWindowSearchDnClick.');
{$ENDIF}
  if ASelf is TComponent then
    GetherSearchPanelOptions(ASelf as TComponent);

  if FOldEditWindowSearchDnClick <> nil then
  begin
    if FEditWindowSearchDnClickMethodHook.UseDDteours then
      TClickEventProc(FEditWindowSearchDnClickMethodHook.Trampoline)(ASelf, Sender)
    else
    begin
      FEditWindowSearchDnClickMethodHook.UnhookMethod;
      TClickEventProc(FOldEditWindowSearchDnClick)(ASelf, Sender);
      FEditWindowSearchDnClickMethodHook.HookMethod;
    end;
  end;
end;

{$ENDIF}

constructor TCnSrcEditorKey.Create;
var
  Wizard: TCnSrcEditorEnhance;
begin
  inherited;
  FActive := True;
  FAutoIndentList := TStringList.Create;
  FRenameShortCut := TextToShortCut('F2');

  FCorIdeModule := LoadLibrary(CorIdeLibName);
  if FCorIdeModule <> 0 then
  begin
    FOldSrchDialogOKButtonClick := GetProcAddress(FCorIdeModule, SCnSrchDialogOKButtonClick);
    if FOldSrchDialogOKButtonClick <> nil then
    begin
      FOldSrchDialogOKButtonClick := GetBplMethodAddress(FOldSrchDialogOKButtonClick);
      if FOldSrchDialogOKButtonClick <> nil then
        FSearchDialogMethodHook := TCnMethodHook.Create(FOldSrchDialogOKButtonClick, @CnSrchDialogOKButtonClick);
    end;
{$IFDEF IDE_HAS_EDITOR_SEARCHPANEL}
    FOldEditWindowDoSearch := GetProcAddress(FCorIdeModule, SCnEditWindowDoSearch);
    if FOldEditWindowDoSearch <> nil then
    begin
      FOldEditWindowDoSearch := GetBplMethodAddress(FOldEditWindowDoSearch);
      if FOldEditWindowDoSearch <> nil then
        FEditWindowDoSearchMethodHook := TCnMethodHook.Create(FOldEditWindowDoSearch, @CnEditWindowDoSearch);
    end;

    FOldEditWindowSearchUpClick := GetProcAddress(FCorIdeModule, SCnEditWindowSearchUpClick);
    if FOldEditWindowSearchUpClick <> nil then
    begin
      FOldEditWindowSearchUpClick := GetBplMethodAddress(FOldEditWindowSearchUpClick);
      if FOldEditWindowSearchUpClick <> nil then
        FEditWindowSearchUpClickMethodHook := TCnMethodHook.Create(FOldEditWindowSearchUpClick, @CnEditWindowSearchUpClick);
    end;

    FOldEditWindowSearchDnClick := GetProcAddress(FCorIdeModule, SCnEditWindowSearchDnClick);
    if FOldEditWindowSearchDnClick <> nil then
    begin
      FOldEditWindowSearchDnClick := GetBplMethodAddress(FOldEditWindowSearchDnClick);
      if FOldEditWindowSearchDnClick <> nil then
        FEditWindowSearchDnClickMethodHook := TCnMethodHook.Create(FOldEditWindowSearchDnClick, @CnEditWindowSearchDnClick);
    end;

{$IFDEF DEBUG}
    if FOldEditWindowDoSearch = nil then
      CnDebugger.LogMsgWarning('SrcEditorKey EditWindowDoSearch NOT Found.');
    if FOldEditWindowSearchUpClick = nil then
      CnDebugger.LogMsgWarning('SrcEditorKey EditWindowSearchUpClick NOT Found.');
    if FOldEditWindowSearchDnClick = nil then
      CnDebugger.LogMsgWarning('SrcEditorKey EditWindowSearchDnClick NOT Found.');
{$ENDIF}

{$ENDIF}
  end;

  EditControlWrapper.AddKeyDownNotifier(EditControlKeyDown);
  EditControlWrapper.AddSysKeyDownNotifier(EditControlSysKeyDown);
  EditControlWrapper.AddKeyUpNotifier(EditControlKeyUp);
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);

{$IFDEF DELPHI104_SYDNEY_UP}
  EditControlWrapper.AddEditorMouseUpNotifier(EditorMouseUp);
{$ENDIF}
end;

destructor TCnSrcEditorKey.Destroy;
begin
{$IFDEF DELPHI104_SYDNEY_UP}
  EditControlWrapper.RemoveEditorMouseUpNotifier(EditorMouseUp);
{$ENDIF}

  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  EditControlWrapper.RemoveKeyUpNotifier(EditControlKeyUp);
  EditControlWrapper.RemoveSysKeyDownNotifier(EditControlSysKeyDown);
  EditControlWrapper.RemoveKeyDownNotifier(EditControlKeyDown);

{$IFDEF IDE_HAS_EDITOR_SEARCHPANEL}
  FEditWindowSearchDnClickMethodHook.Free;
  FEditWindowSearchUpClickMethodHook.Free;
  FEditWindowDoSearchMethodHook.Free;
{$ENDIF}

  FSearchDialogMethodHook.Free;
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);

  FAutoIndentList.Free;
  inherited;
end;

function CanIgnoreFromIME: Boolean;
var
  Imc: HIMC;
  EditControl: TWinControl;
  Conversion, Sentence: DWORD;
begin
  Result := False;
  if IMMIsActive then // 输入法打开了
  begin
    EditControl := CnOtaGetCurrentEditControl;
    if EditControl <> nil then
    begin
      Imc := ImmGetContext(EditControl.Handle);
      if ImmGetConversionStatus(Imc, Conversion, Sentence) then
      begin
        if (((Conversion and IME_CMODE_NATIVE) <> 0) = ((Conversion and  IME_CMODE_SYMBOL) <> 0))
          and ((Conversion and IME_CMODE_NATIVE) <> 0) then
        begin
          Result := True;
          Exit; // 输入法英文输入不开启并且不是英文标点的就不处理, 两者能且只能开启一个
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 扩展功能方法
//------------------------------------------------------------------------------

function TCnSrcEditorKey.DoAutoMatchEnter(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  AChar, Char1, Char2: Char;
  Line: string;
  AnsiLine: AnsiString;
  LineNo, CharIndex, ACount, LeftBracketIndex, MaxLen: Integer;
  NeedAutoMatch: Boolean;
  EditControl: TControl;
  I, Element, LineFlag, C: Integer;
  KeyIsLeft: Boolean;
  ACharSet: TAnsiCharSet;
begin
  if CnNtaGetCurrLineText(Line, LineNo, CharIndex) then
  begin
    AChar := Char(VK_ScanCodeToAscii(Key, ScanCode));

    // UNICODE 环境下 CharIndex 和 string 不一致，需要转换成 AnsiString 来处理
    AnsiLine := AnsiString(Line);

    // 引号无法直接区分是否当前输入字符是左括号一类，需要根据光标当前附近内容判断
    KeyIsLeft := False;
    if CharInSet(AChar, ['(', '[', '{']) then
      KeyIsLeft := True
    else if CharInSet(AChar, ['''', '"']) then
    begin
      if (AnsiLine <> '') and (CharIndex <= Length(AnsiLine)) then
      begin
        // 如果光标前一字符不是引号，就算左
        Char1 := Char(AnsiLine[CharIndex]);
        if ((AChar = '''') and (Char1 = '''')) or
          ((AChar = '"') and (Char1 = '"')) then
          KeyIsLeft := False
        else // 判断本行的单引号数是否 0 或偶数个，是则 KeyIsLeft 为 True
        begin
          C := 0;
          for I := 1 to CharIndex do
          begin
            if Char(AnsiLine[I]) = '''' then
              Inc(C);
          end;
          KeyIsLeft := (C and 1) = 0;
{$IFDEF DEBUG}
          CnDebugger.LogFmt('DoAutoMatch Quota Count %d. IsLeft %d', [C, Integer(KeyIsLeft)]);
{$ENDIF}
        end;
      end
      else
        KeyIsLeft := True;
    end;

    if KeyIsLeft then
    begin
      if CanIgnoreFromIME then
      begin
        Result := False;
        Exit;
      end;

      NeedAutoMatch := False;
      if Length(AnsiLine) > CharIndex then
      begin
        // 当前位置后是标识符以及左右括号引号时不自动输入括号
        ACharSet := ['_', 'A'..'Z', 'a'..'z', '0'..'9', '(', ')', '''', '[', ']'];
        if CharInSet(AChar, ['''', '"', '(', '[']) then // 但引号，左括号在右括号前，是需要自动输入的
          ACharSet := ACharSet - [')', ']'];

        NeedAutoMatch := not CharInSet(Char(AnsiLine[CharIndex + 1]), ACharSet);
      end
      else if Length(AnsiLine) = CharIndex then
        NeedAutoMatch := True; // 行尾

      if AChar = '''' then
      begin
        // 字符串内部不自动输入单引号
        EditControl := CnOtaGetCurrentEditControl;
        if EditControl = nil then
        begin
          Result := False;
          Exit;
        end;
        EditControlWrapper.GetAttributeAtPos(EditControl, View.CursorPos,
          False, Element, LineFlag);
        if Element in [atString] then
          NeedAutoMatch := False;
      end;

      // 自动输入括号配对
      if NeedAutoMatch then
      begin
        case AChar of
          '(': FAutoMatchType := btBracket;
          '[': FAutoMatchType := btSquare;
          '{': FAutoMatchType := btCurly;
          '''':FAutoMatchType := btQuote;
          '"': FAutoMatchType := btDitto;
        else
          FAutoMatchType := btNone;
        end;

        FAutoMatchEntered := True;

        FRepaintView := TCnNativeUInt(View);
        CnWizNotifierServices.ExecuteOnApplicationIdle(ExecuteInsertCharOnIdle);
      end;
    end
    else if FAutoMatchEntered and CharInSet(AChar, [')', ']', '}', '''', '"', #9]) then
    begin
      if CanIgnoreFromIME then
      begin
        Result := False;
        Exit;
      end;

      // 刚输入了左括号，此右括号可能要省掉 ，或者按 Tab 时跳到右括号后
      if ((FAutoMatchType = btBracket) and (AChar = ')')) or
        ((FAutoMatchType = btSquare) and (AChar = ']')) or
        ((FAutoMatchType = btCurly) and (AChar = '}')) or
        ((FAutoMatchType = btQuote) and (AChar = '''')) or
        ((FAutoMatchType = btDitto) and (AChar = '"')) or (AChar = #9) then
      begin
        // 判断当前光标右边是否是相应的右括号
        NeedAutoMatch := False;
        if Length(AnsiLine) > CharIndex then
        begin
          AChar := Char(AnsiLine[CharIndex + 1]); // 重新使用 AChar
          case FAutoMatchType of
            btBracket: NeedAutoMatch := AChar = ')';
            btSquare:  NeedAutoMatch := AChar = ']';
            btCurly:   NeedAutoMatch := AChar = '}';
            btQuote:   NeedAutoMatch := AChar = '''';
            btDitto:   NeedAutoMatch := AChar = '"';
          end;
        end;

        if NeedAutoMatch then // 有匹配的东西
        begin
          CnOtaMovePosInCurSource(ipCur, 0, 1);
          View.Paint;
          FAutoMatchEntered := False;
          Handled := True;
        end;
      end;
    end
    else if FAutoMatchEntered and (AChar = #08) and (CharIndex < Length(AnsiLine)) then
    begin
      // 如果是退格键，并且光标左边是左括号右边是右括号，则把右括号也删掉
      Char1 := Char(AnsiLine[CharIndex]);
      Char2 := Char(AnsiLine[CharIndex + 1]);
      if ( (Char1 = '(') and (Char2 = ')') ) or
        ((Char1 = '[') and (Char2 = ']')) or
        ((Char1 = '{') and (Char2 = '}')) or
        ((Char1 = '''') and (Char2 = '''')) or
        ((Char1 = '"') and (Char2 = '"')) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Should Delete AutoMatched Chars.');
{$ENDIF}
        CnOtaEditDelete(1);
        Handled := False;
      end;
    end;

    if not Handled and (AChar = ')') then
    begin
      if CanIgnoreFromIME then // 输入法下的括号不算
      begin
        Result := False;
        Exit;
      end;

      // if / else if / until / while 这种，表达式出现单个右括号时，前补左小括号
      // 先数 AnsiLine 最前面几个空格
      ACount := 0;
      for I := 1 to Length(AnsiLine) do
      begin
        if AnsiLine[I] = ' ' then
          Inc(ACount)
        else
          Break;
      end;

      LeftBracketIndex := -1;
      if Pos('if ', AnsiLine) = ACount + 1 then
        LeftBracketIndex := ACount + Length('if ')
      else if Pos('else if ', AnsiLine) = ACount + 1 then
        LeftBracketIndex := ACount + Length('else if ')
      else if Pos('while ', AnsiLine) = ACount + 1 then
        LeftBracketIndex := ACount + Length('while ')
      else if Pos('until ', AnsiLine) = ACount + 1 then
        LeftBracketIndex := ACount + Length('until ');

      if LeftBracketIndex >= 0 then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Possible Should Add LeftBracket for if/else if/while/until Line at Ansi ' + IntToStr(LeftBracketIndex));
{$ENDIF}
        // 是符合要求的行，查左边到光标位置的小括号配对数是否相同，不考虑字符串内有小括号的情况
        ACount := 0;
        MaxLen := CharIndex + 1;
        if MaxLen > Length(AnsiLine) then
          MaxLen := Length(AnsiLine);

        for I := 1 to MaxLen do
        begin
          if (AnsiLine[I] = '(') or (AnsiLine[I] = ')') then
            Inc(ACount)
        end;

{$IFDEF DEBUG}
        CnDebugger.LogMsg('Bracket Count is ' + IntToStr(ACount));
{$ENDIF}
        if (ACount = 0) and (CharIndex > LeftBracketIndex) then
        begin
          // 当前右括号尚未输入，并且左边没左右括号，光标移动过去输入左括号再移动过来
{$IFDEF UNICODE}
          // Left 和 CharIndex 都是 Ansi/Utf8Ansi/Ansi 位置，能相减。
          // 但 Move 的则要求 Ansi/Utf8/Utf8，在 Unicode 环境下不一致，需要转换
          // LeftBracket 之前没有双字节字符，只要转 CharIndex 就行
          ACount := -CalcUtf8LengthFromWideString(PWideChar(string(Copy(AnsiLine,
            LeftBracketIndex + 1, CharIndex - LeftBracketIndex))));
{$ELSE}
          ACount := LeftBracketIndex - CharIndex;
{$ENDIF}

{$IFDEF DEBUG}
          CnDebugger.LogMsg('Should Move Back and Forward: ' + IntToStr(ACount));
{$ENDIF}

          CnOtaMovePosInCurSource(ipCur, 0, ACount);
          CnOtaInsertTextToCurSource('(');
          CnOtaMovePosInCurSource(ipCur, 0, -ACount);
          View.Paint;
        end;
      end;
    end;
  end;
  Result := Handled;
end;

function TCnSrcEditorKey.ProcessSmartPaste(View: IOTAEditView): Boolean;
const
  CppNoIndentTokens: array[0..3] of string = ('private:', 'protected:', 'public:',
    '__published:');
var
  Text, Tmp, Prev, FirstLine, LastToken: string;
  EditControl: TControl;
  I, LineNo, CharIndex, PasteCol, Indent: Integer;
  List: TStrings;
  EndIsCRLF, IsSingleLine, IsCppFile: Boolean;
  FirstLineSpaceCount, LineSpaceCount, MinLineSpaceCount: Integer;
  EditPos: TOTAEditPos;
  CharPos: TOTACharPos;
  LinePos: LongInt;

  function FirstLineInCppNoIndentList(const AFirstLine: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := Low(CppNoIndentTokens) to High(CppNoIndentTokens) do
    begin
      if Pos(CppNoIndentTokens[I], AFirstLine) = 1 then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  function GetHeadSpaceCount(const S: string): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    if S <> '' then
      for I := 1 to Length(S) do
        if S[I] = ' ' then
          Inc(Result)
        else
          Break;
  end;

  function GetLastTokenFromLine(const ALine: string): string;
  var
    Idx, J: Integer;
    Str: string;
  begin
    Idx := 0;
    Str := Trim(ALine);
    for J := Length(Str) downto 1 do
    begin
      if not IsValidIdentChar(Str[J]) and (not IsCppFile or (Str[J] <> '{')) then // C/C++ 文件上一行要判断大括号
      begin
        Idx := J;
        Break;
      end;
    end;

    Result := Copy(Str, Idx + 1, MaxInt);
  end;

begin
  Result := False;
  if View.Block.IsValid then  // 有选择区则不处理，交给 IDE 处理
    Exit;

  // 剪贴板无文本不处理
  if not Clipboard.HasFormat(CF_TEXT) or not Clipboard.HasFormat(CF_UNICODETEXT) then
    Exit;

  // 如果拿不到当前行，或当前行不是空，则退出
  if not CnNtaGetCurrLineText(Text, LineNo, CharIndex, True) then
    Exit;
  if Trim(Text) <> '' then
    Exit;

  // 剪贴板文本内容为空格则不处理
  Text := Clipboard.AsText;
  if Trim(Text) = '' then
    Exit;

  // 剪贴板文本末尾是否以回车换行结尾
  EndIsCRLF := False;
  if (Length(Text) > 2) and (Text[Length(Text)] = #10) and (Text[Length(Text) - 1] = #13) then
    EndIsCRLF := True;

  EditControl := EditControlWrapper.GetEditControl(View);
  if EditControl = nil then
    Exit;

  IsCppFile := IsCppSourceModule(View.Buffer.FileName);
  List := TStringList.Create;
  try
    List.Text := Clipboard.AsText;
    if List.Count = 0 then
      Exit;

    Indent := CnOtaGetBlockIndent;
    IsSingleLine := List.Count = 1;
    if IsSingleLine then
    begin
      // 被粘贴文本是单行，简单地跟上一行对齐
      FirstLine := Trim(List.Text);
      PasteCol := View.CursorPos.Col - 1;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('SmartPaste: Paste Single Line. Indent %d. Origin Col (0 Based) %d.', [Indent, PasteCol]);
{$ENDIF}

      // 判断当前空行的上一行是啥，是否会影响本次缩进，和下文多行的逻辑相同
      if LineNo > 1 then
      begin
        Dec(LineNo);
        Prev := EditControlWrapper.GetTextAtLine(EditControl, LineNo);

        if Trim(Prev) <> '' then
        begin
          PasteCol := GetHeadSpaceCount(Prev);  // 粘贴的起始列默认和上一行的非空字符对齐
          LastToken := GetLastTokenFromLine(Prev);

{$IFDEF DEBUG}
          CnDebugger.LogFmt('SmartPaste: Single Line. Previous is %s with Space %d.', [LastToken, PasteCol]);
{$ENDIF}

          if IsCppFile then
          begin
            // C/C++ 文件中，private 等无需缩进，其余在 { 下一行需要缩进
            if (LastToken = '{') and not FirstLineInCppNoIndentList(Trim(FirstLine)) then
              Inc(PasteCol, Indent);
          end
          else if FAutoIndentList.IndexOf(LastToken) >= 0 then // Pascal 文件如果属于自动缩进列表则再进一层
          begin
            Inc(PasteCol, Indent);
          end
          else
          begin
            // 如果待粘贴内容只有一行[]且不是 begin 开头](暂不做)，且 Text 是 then/do 等，或是冒号结尾，也需要缩进
            LastToken := LowerCase(LastToken);
            if IsSingleLine and (LastToken = 'then') or (LastToken = 'do') then
              Inc(PasteCol, Indent)
            else if (Length(LastToken) >= 1) and (LastToken[Length(LastToken)] = ':') then
              Inc(PasteCol, Indent);
          end;
        end;
      end;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('SmartPaste: Single Line To Add %d Spaces to Text.', [PasteCol]);
{$ENDIF}

      // PasteCol 处插入文字就行了
      View.Buffer.EditPosition.MoveBOL;
      View.Buffer.EditPosition.InsertText(Spc(PasteCol) + FirstLine);
      View.Paint;
      Result := True;
      Exit;
    end;

    // 剪贴板文本先判断是否其他行的行首空格数比首行少，如果少则不处理。
    // 另外除首行外其他行的空格在都比首行多的情况下，找出最少的，也都删

    FirstLineSpaceCount := 0;
    MinLineSpaceCount := MaxInt;
    FirstLine := '';

    if List.Count > 1 then
    begin
      for I := 0 to List.Count - 1 do
      begin
        // 找出第一非空行作为首行并计算其头部空格数，要算首行
        if FirstLine = '' then
        begin
          FirstLine := List[I];
          if FirstLine <> '' then
          begin
            FirstLineSpaceCount := GetHeadSpaceCount(FirstLine);
{$IFDEF DEBUG}
            CnDebugger.LogFmt('SmartPaste: Got Non-Empty FirstLine %s at %d Line. Space %d',
              [FirstLine, I, FirstLineSpaceCount]);
{$ENDIF}
          end;
        end;

        if (I = 0) or (Trim(List[I]) = '') then // 空行不参与行首空格计算
          Continue;

        LineSpaceCount := GetHeadSpaceCount(List[I]);
        if LineSpaceCount < FirstLineSpaceCount then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogFmt('SmartPaste: Do NOT Smart Paste for FirstLine Space %d > Line Space %d at Line %d.',
            [FirstLineSpaceCount, LineSpaceCount, I]);
{$ENDIF}
          Exit;
        end;
        if MinLineSpaceCount > LineSpaceCount then
          MinLineSpaceCount := LineSpaceCount;
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('SmartPaste: All Clipbard Lines Checked. MinLineSpaceCount(without 1st) %d. IDE Indent %d',
      [MinLineSpaceCount, Indent]);
{$ENDIF}

    // 以上逻辑将首行与其他行分开删头部空格，用于处理选择时首行未完整选择的情况
    // 目的是将首行头部全删，其余的按其余的最少空格删头部，但带来的副作用就是
    // var
    //   I: Integer; 这种会将 I 的缩进错误地去掉，所以加个逻辑：
    // 首行尾是该缩进标识符时（var/then/do）等，包括是编译指令的时候
    // 且其他行要缩进的字符已经计算出来的是大于等于IDE缩进时，将 MinLineSpaceCount 减掉一次缩进
    if FirstLine <> '' then
    begin
      Text := GetLastTokenFromLine(FirstLine);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('SmartPaste: First Line Last Token is %s', [Text]);
{$ENDIF}

      if MinLineSpaceCount >= Indent then
      begin
        if IsCppFile and (Text = '{') then
        begin
          Dec(MinLineSpaceCount, Indent);  // Cpp 的大括号后有缩进
{$IFDEF DEBUG}
          CnDebugger.LogMsg('SmartPaste: Clipboard Content Contains Indent for {');
{$ENDIF}
        end
        else if FAutoIndentList.IndexOf(Text) >= 0 then
        begin
          Dec(MinLineSpaceCount, Indent);  // Delphi 部分关键字后有缩进
{$IFDEF DEBUG}
          CnDebugger.LogMsg('SmartPaste: Clipboard Content Contains Indent for some Pascal Keywords.');
{$ENDIF}
        end
        else if not IsCppFile and (Length(FirstLine) > 3) then
        begin
          if (FirstLine[1] = '{') and (FirstLine[2] = '$')
            and (FirstLine[Length(FirstLine)] = '}') then
          begin
            Dec(MinLineSpaceCount, Indent); // Delphi 编译指令后有缩进
{$IFDEF DEBUG}
            CnDebugger.LogMsg('SmartPaste: Clipboard Content Contains Indent for Compiler Directives.');
{$ENDIF}
          end;
        end;
      end;
    end;

    // 如果非首行内容们的最小行首空格比行首空格多，则每行左边都删去"首行空格数"个空格
    for I := 0 to List.Count - 1 do
    begin
      Tmp := List[I];
      if I = 0 then
        Delete(Tmp, 1, FirstLineSpaceCount)
      else
        Delete(Tmp, 1, MinLineSpaceCount);
      List[I] := Tmp;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('SmartPaste: Clipboard Delete %d Spaces in 1st Line and %d Spaces in Other Lines.',
      [FirstLineSpaceCount, MinLineSpaceCount]);
{$ENDIF}

    PasteCol := View.CursorPos.Col - 1;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('SmartPaste: Indent %d. Origin Col (0 Based) %d.', [Indent, PasteCol]);
{$ENDIF}

    // 判断当前空行的上一行是啥，是否会影响本次缩进
    if LineNo > 1 then
    begin
      Dec(LineNo);
      Prev := EditControlWrapper.GetTextAtLine(EditControl, LineNo);

      if Trim(Prev) <> '' then
      begin
        PasteCol := GetHeadSpaceCount(Prev);  // 粘贴的起始列默认和上一行的非空字符对齐
        LastToken := GetLastTokenFromLine(Prev);

{$IFDEF DEBUG}
        CnDebugger.LogFmt('SmartPaste: Previous Line is %s with Space %d.', [LastToken, PasteCol]);
{$ENDIF}

        if IsCppFile then
        begin
          // C/C++ 文件中，private 等无需缩进，其余在 { 下一行需要缩进
          if (LastToken = '{') and not FirstLineInCppNoIndentList(Trim(FirstLine)) then
            Inc(PasteCol, Indent);
        end
        else if FAutoIndentList.IndexOf(LastToken) >= 0 then // Pascal 文件如果属于自动缩进列表则再进一层
        begin
          Inc(PasteCol, Indent);
        end
        else
        begin
          // 如果待粘贴内容只有一行[]且不是 begin 开头](暂不做)，且 Text 是 then/do 等，或是冒号结尾，也需要缩进
          LastToken := LowerCase(LastToken);
          if IsSingleLine and (LastToken = 'then') or (LastToken = 'do') then
            Inc(PasteCol, Indent)
          else if (Length(LastToken) >= 1) and (LastToken[Length(LastToken)] = ':') then
            Inc(PasteCol, Indent);
        end;
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('SmartPaste: To Add %d Spaces to Every Line.', [PasteCol]);
{$ENDIF}

    // 将每行都增加缩进空格
    for I := 0 to List.Count - 1 do
      List[I] := Spc(PasteCol) + List[I];

    // 如果多行，要记录之前的文本是否是换行结尾，避免 List.Text 转换后多出个换行
    Text := List.Text;
    if not EndIsCRLF and (Length(Text) > 2) and (Text[Length(Text)] = #10)
      and (Text[Length(Text) - 1] = #13)then
      Delete(Text, Length(Text) - 1, 2);

    // 然后在行首进行插入
    View.Buffer.EditPosition.MoveBOL;
    EditPos := View.CursorPos;
    View.ConvertPos(True, EditPos, CharPos);
    LinePos := View.CharPosToPos(CharPos);

    // EditPosition 插入会产生莫名其妙的缩进，得改用 Writer 来写入
{$IFDEF UNICODE}
    CnOtaInsertTextIntoEditorAtPosW(Text, LinePos);
{$ELSE}
    CnOtaInsertTextIntoEditorAtPos(Text, LinePos);
{$ENDIF}
    View.MoveViewToCursor;
    View.Paint;
    Result := True;
  finally
    List.Free;
  end;
end;

function TCnSrcEditorKey.DoSmartCopy(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Token: TCnIdeTokenString;
  Text: string;
  Idx, LineNo, CharIdx: Integer;
  IsToken: Boolean;
  IsTextLine: Boolean;
begin
  if (Key in [Ord('C'), Ord('V'), Ord('X')]) and (Shift = [ssCtrl]) then
  begin
    if not View.Block.IsValid then
    begin
      if FSmartCopy and (Key in [Ord('C'), Ord('X')]) then
      begin
        LineNo := 0;
        IsToken := CnOtaGeneralGetCurrPosToken(Token, Idx, True);
        CnNtaGetCurrLineText(Text, LineNo, CharIdx);
        IsTextLine := Trim(Text) <> '';
        if not IsToken and not IsTextLine then
        begin
          Handled := False;
          Result := Handled;
          Exit;
        end;

        if not IsToken and IsTextLine then
          Token := Text;  // 只复制时复制整行

{$IFDEF IDE_STRING_ANSI_UTF8}
        // 把 WideString 内容设给剪贴板
        if IsClipboardFormatAvailable(CF_UNICODETEXT) then
          SetClipboardContent(CF_UNICODETEXT, PWideChar(Token)^, (Length(Token) * SizeOf(WideChar)) + 1)
        else
          Clipboard.AsText := Token;
{$ELSE}
        // D567/2009可以直接设置剪贴板字符串，Ansi/UnicodeString
        Clipboard.AsText := Token;
{$ENDIF}

        if Key = Ord('X') then
        begin
          if IsToken then
            CnOtaDeleteCurrToken
          else if IsTextLine and (LineNo > 0) then
          begin
            View.CursorPos := CnOtaLinePosToEditPos(CnOtaEditPosToLinePos(
              OTAEditPos(1, LineNo), View));
            View.Block.BeginBlock;
            View.CursorPos := CnOtaLinePosToEditPos(CnOtaEditPosToLinePos(
              OTAEditPos(1, LineNo + 1), View));
            View.Block.EndBlock;
            CnOtaDeleteCurrentSelection;
            View.MoveViewToCursor;
          end;
          View.Paint;
        end;
        Handled := True;
      end
      else if FSmartPaste then
      begin
        if FPasteReplace then
          CnOtaDeleteCurrToken;
        Handled := ProcessSmartPaste(View);
      end;
    end;
  end;
  Result := Handled;
end;

function TCnSrcEditorKey.DoShiftEnter(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
begin
  Result := False;
  if (Key = VK_RETURN) and (Shift = [ssShift]) and not View.Block.IsValid then
  begin
    View.Buffer.EditPosition.MoveEOL;
    Handled := False;
    Result := True;
  end;
end;

{$IFNDEF DELPHI10_UP}

procedure TCnSrcEditorKey.IdleDoAutoIndent(Sender: TObject);
var
  View: IOTAEditView;
begin
  View := CnOtaGetTopMostEditView;
  if Assigned(View) then
  begin
    if View.CursorPos.Line = FSaveLineNo + 1 then
    begin
      View.Buffer.EditPosition.MoveRelative(0, CnOtaGetBlockIndent);
      View.Paint;
    end;
  end;
end;

procedure TCnSrcEditorKey.IdleDoCBracketIndent(Sender: TObject);
var
  View: IOTAEditView;
begin
  View := CnOtaGetTopMostEditView;
  if Assigned(View) then
  begin
    if View.CursorPos.Line = FSaveLineNo + 1 then
    begin
      CnOtaInsertTextToCurSource(#13#10);
      CnOtaMovePosInCurSource(ipCur, -1, 0);
      View.Buffer.EditPosition.MoveRelative(0, CnOtaGetBlockIndent);
      View.Paint;
    end;
  end;
end;

procedure TCnSrcEditorKey.IdleDoAutoInput(Sender: TObject);
var
  View: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  Parser: TCnPasStructureParser;
  NeedInsert: Boolean;
  Text: string;
  ACol: Integer;

  function IsDotAfterTokenEnd(AToken: TCnPasToken): Boolean;
  var
    SavePos, APos: TOTAEditPos;
    Text: string;
    Line, Col: Integer;
  begin
    Result := False;
    if AToken = nil then Exit;

    SavePos := View.CursorPos;
    APos := SavePos;
    APos.Line := AToken.LineNumber + 1; // 必须加一
    View.CursorPos := APos;
    CnNtaGetCurrLineText(Text, Line, Col);

    Col := AToken.EditCol + Length(AToken.Token);
    if Length(Text) >= Col then
      Result := (Text[Col] = '.');

    View.CursorPos := SavePos;
  end;

begin
  View := CnOtaGetTopMostEditView;
  if Assigned(View) then
  begin
    if View.CursorPos.Line = FSaveLineNo + 1 then
    begin
      // DONE: 加入一些限制，避免每个都加 end
      // 光标所在的内层块一个是begin一个是end，并且俩的Col不等时，才需要加end
      // 光标所在无内层块时也加 end。其余情况则无需加。
      // 另外，如果已经配对了，则这个 end 不能是 end. 这样的单元结尾符
      Stream := TMemoryStream.Create;
      Parser := TCnPasStructureParser.Create;
      try
        CnOtaSaveEditorToStream(View.Buffer, Stream);
        Parser.ParseSource(PAnsiChar(Stream.Memory),
          IsDpr(View.Buffer.FileName), True);

        EditPos := View.CursorPos;
        View.ConvertPos(True, EditPos, CharPos);
        Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

        NeedInsert := False;
        if (Parser.InnerBlockStartToken <> nil) and (Parser.InnerBlockCloseToken <> nil) then
        begin
          if (Parser.InnerBlockStartToken.TokenID = tkBegin) and
            (Parser.InnerBlockCloseToken.TokenID = tkEnd) then
          begin
            // 转换成 Col 与 Line，把 0 开始的 CharIndex，转换为 1 开始的 Col
            CharPos := OTACharPos(Parser.InnerBlockStartToken.CharIndex,
              Parser.InnerBlockStartToken.LineNumber);
            View.ConvertPos(False, EditPos, CharPos);
            Parser.InnerBlockStartToken.EditCol := EditPos.Col;
            Parser.InnerBlockStartToken.EditLine := EditPos.Line;

            CharPos := OTACharPos(Parser.InnerBlockCloseToken.CharIndex,
              Parser.InnerBlockCloseToken.LineNumber);
            View.ConvertPos(False, EditPos, CharPos);
            Parser.InnerBlockCloseToken.EditCol := EditPos.Col;
            Parser.InnerBlockCloseToken.EditLine := EditPos.Line;

            // 如只判断 begin/end 列是否匹配，则在 if then begin \n end 时会增加不必要的 end
            // 应改为判断 end 列位置与 begin 所在的行的第一个非空字符是否对的上号
            Text := CnOtaGetLineText(Parser.InnerBlockStartToken.EditLine + 1, View.Buffer);
            ACol := 0;
            while (ACol < Length(Text)) and CharInSet(Text[ACol + 1], [' ', #9]) do
              Inc(ACol);
            NeedInsert := ACol + 1 <> Parser.InnerBlockCloseToken.EditCol;
            // 一个 0 开始，一个 1 开始，因此需要加一比较

            // 如果不要加也就是配对了，还得判断这个 end 不能是 end. 点则还是要加
            if not NeedInsert then
              if not IsDpr(View.Buffer.FileName) and
                IsDotAfterTokenEnd(Parser.InnerBlockCloseToken) then
                NeedInsert := True;

            // 如果仍然不要加，则还得判断一下最外层块的层次是否配对正确，不配对还是要加
            if not NeedInsert then
            begin
              if (Parser.BlockStartToken <> nil) and (Parser.BlockCloseToken <> nil) then
              begin
                if Parser.BlockStartToken.ItemLayer < Parser.BlockCloseToken.ItemLayer then
                  NeedInsert := True
                else if Parser.BlockStartToken.ItemLayer = Parser.BlockCloseToken.ItemLayer then
                begin
                  // 最外层如果配对的话，还得判断一下最后是不是 end. 是点则还是要加
                  if not IsDpr(View.Buffer.FileName) and
                    IsDotAfterTokenEnd(Parser.BlockCloseToken) then
                    NeedInsert := True;
                end;
              end;
            end;
          end;
        end
        else // 无配对时，也加
          NeedInsert := True;
      finally
        Stream.Free;
        Parser.Free;
      end;

      if not NeedInsert then Exit;

      CnOtaInsertTextToCurSource(#13#10'end;');
      View.Buffer.EditPosition.MoveRelative(-1, CnOtaGetBlockIndent - 4 );
      // 插入状态下才插入，减4是减去end; 的长度
      View.Paint;

      if FNeedChangeInsert then // 如果原来是改写状态，恢复改写状态
      begin
        FNeedChangeInsert := False;
        View.Buffer.BufferOptions.InsertMode := False;
      end;
    end;
  end;
end;

function TCnSrcEditorKey.DoAutoIndent(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Text: string;
  LineNo: Integer;
  CharIdx: Integer;
  i, Idx: Integer;
  NeedIndent: Boolean;
begin
  Result := False;
  Handled := False;
  if (Key = VK_RETURN) and not (ssCtrl in Shift) and not View.Block.IsValid
    and CurrentIsSource then
  begin
    if CnNtaGetCurrLineText(Text, LineNo, CharIdx) then
    begin
      if CharIdx >= Length(Text) then  // 在行末尾
      begin
        Text := Trim(Text);
        if Text <> '' then
        begin
          NeedIndent := False;
          if CurrentIsDelphiSource then
          begin
            if FAutoIndent then
            begin
              Idx := 0;
              for i := Length(Text) downto 1 do
              begin
                if not IsValidIdentChar(Text[i]) then
                begin
                  Idx := i;
                  Break;
                end;
              end;

              Text := Copy(Text, Idx + 1, MaxInt);
              if FAutoIndentList.IndexOf(Text) >= 0 then
                NeedIndent := True;
            end;

            // 加入一个小功能，在插入状态时，begin 后自动 end 输入并缩进
            if FAutoEnterEnd and (LowerCase(Text) = 'begin') then
            begin
              FSaveLineNo := LineNo;
              FNeedChangeInsert := not View.Buffer.BufferOptions.InsertMode;
              if FNeedChangeInsert then // 是插入则改成改写
                View.Buffer.BufferOptions.InsertMode := True;
              CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoAutoInput);
            end;
          end
          else if IsCppSourceModule(CnOtaGetCurrentSourceFile) then
          begin
            if Text[Length(Text)] = '{' then
              NeedIndent := True
          end;

          if NeedIndent then
          begin
            FSaveLineNo := LineNo;
            CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoAutoIndent);
          end;
        end;
      end
      else // 不在行末尾
      begin
        if (CharIdx = Length(Text) - 1) and IsCppSourceModule(CnOtaGetCurrentSourceFile) then
        begin
          if (Text[CharIdx] = '{') and (Text[CharIdx + 1] = '}') then
          begin
            FSaveLineNo := LineNo;
            CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoCBracketIndent);
          end;
        end;
      end;
    end;
  end;
end;

{$ENDIF}

function TCnSrcEditorKey.DoHomeExtend(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Text: string;
  LineNo: Integer;
  CharIdx: Integer;
  Idx: Integer;
begin
  Result := False;

  // 录制回放键盘宏时不启用此选项避免引发副作用，
  // 注意回放键盘宏时不是真正的键盘消息，不会到这儿来
  if (Key = VK_HOME) and (Shift = []) and not IsKeyMacroRunning then
  begin
    if CnNtaGetCurrLineText(Text, LineNo, CharIdx) and (Trim(Text) <> '') then
    begin
      Idx := 0;
      while Idx < Length(Text) do
      begin
        if Text[Idx + 1] <> ' ' then
          Break
        else
          Inc(Idx);
      end;

      if Idx > 0 then
      begin
        if CharIdx = 0 then
        begin
          View.Buffer.EditPosition.MoveRelative(0, Idx);
        end
        else
        begin
          if FHomeFirstChar and (CharIdx <> Idx) then
            View.Buffer.EditPosition.Move(View.CursorPos.Line, Idx + 1)
          else
            View.Buffer.EditPosition.MoveBOL
        end;
        Handled := True;
        Result := True;
        View.Paint;
      end;
    end;
  end;
end;

function TCnSrcEditorKey.DoLeftRightLineWrap(View: IOTAEditView; Key,
  ScanCode: Word; Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Text: string;
  LineNo: Integer;
  CharIdx: Integer;
  Len: Integer;
begin
  Result := False;
  Handled := False;
  if ((Key = VK_LEFT) or (Key = VK_RIGHT)) and not (ssCtrl in Shift)
    and not View.Block.IsValid then
  begin
    if CnNtaGetCurrLineText(Text, LineNo, CharIdx, True) then
    begin
      if FLeftLineWrap and (CharIdx = 0) and (Key = VK_LEFT) then // 行首左移至上一行尾
      begin
        Result := View.Buffer.EditPosition.MoveRelative(-1, 0)
          and View.Buffer.EditPosition.MoveEOL;
        Handled := Result;
      end
      else if FRightLineWrap and (Key = VK_RIGHT) then  // 行尾右移至下一行头
      begin
{$IFDEF UNICODE}
        CharIdx := View.CursorPos.Col - 1;
        Len := Length(AnsiString(Text));
{$ELSE}
        Len := Length(Text);
{$ENDIF}
        if CharIdx >= Len then
        begin
          View.Buffer.EditPosition.MoveRelative(1, 0);
          View.Buffer.EditPosition.MoveBOL;
          Result := True;
          Handled := Result;
        end;
      end;
      if Result then
        View.Paint;
    end;
  end;
end;

function TCnSrcEditorKey.DoSemicolonLastChar(View: IOTAEditView; Key,
  ScanCode: Word; Shift: TShiftState; var Handled: Boolean): Boolean;
var
  EditControl: TControl;
  Element, LineFlag: Integer;
  Text: string;
  EditPos: TOTAEditPos;
  AChar: Char;
  Lex: TmwPasLex;
  CParser: TBCBTokenList;
  CanMove: Boolean;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  Stack: TStack;
  IsInProcDeclare: Boolean;
  RoundCount: Integer;
  IsInFor: Boolean;

  procedure MoveToLineEnd;
  begin
{$IFDEF UNICODE}
    // GetAttributeAtPos 需要的是 UTF8 的Pos，因此 UNICODE 下进行 Col 的 UTF8 转换
    EditPos.Col := Length(CnAnsiToUtf8({$IFDEF UNICODE}AnsiString{$ENDIF}(Text)));
{$ELSE}
    EditPos.Col := Length(Text);
{$ENDIF}
    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
    if not (Element in [atComment]) then // 如果行尾是注释，就不能直接移动到行尾
    begin
      View.Buffer.EditPosition.MoveEOL;
      Result := True;
      View.Paint;
    end
    else // 找最后一个不是注释且不是空白的地方
    begin
      while (Element in [atComment, atWhiteSpace]) and (EditPos.Col > 0) do
      begin
        Dec(EditPos.Col);
        EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
      end;

      if EditPos.Col > 0 then
      begin
        // 找到了最后一个不是注释的地方
        Inc(EditPos.Col);
{$IFDEF UNICODE}
        // 从 UTF8 的 Pos，转换回 Ansi 的
        EditPos.Col := Length(CnUtf8ToAnsi({$IFDEF UNICODE}AnsiString{$ENDIF}(Copy(Text, 1, EditPos.Col))));
{$ENDIF}
        View.Buffer.EditPosition.Move(EditPos.Line, EditPos.Col);
        View.Paint;
        Result := True;
      end;
    end;
  end;

begin
  Result := False;
  Handled := False;

  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;

  Text := GetStrProp(EditControl, 'LineText');
  if Trim(Text) = '' then
    Exit;

  if CanIgnoreFromIME then
    Exit;

  AChar := Char(VK_ScanCodeToAscii(Key, ScanCode));

  if (AChar = ';') and (Shift = []) then
  begin
    if (View.Block <> nil) and (View.Block.IsValid) then // 有选择区则不动
      Exit;

    EditPos := View.CursorPos;
{$IFDEF UNICODE}
    // GetAttributeAtPos 需要的是 UTF8 的Pos，因此 D2009 下进行 Col 的 UTF8 转换
    EditPos.Col := Length(CnAnsiToUtf8({$IFDEF UNICODE}AnsiString{$ENDIF}(Copy(Text, 1, EditPos.Col))));
{$ENDIF}

    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
    if not (Element in [atString, atComment, atAssembler]) then
    begin
      CanMove := True;
      Stream := TMemoryStream.Create;
      CnOtaSaveEditorToStream(View.Buffer, Stream);
      EditPos := View.CursorPos;
      View.ConvertPos(True, EditPos, CharPos);
      Stack := TStack.Create;
      RoundCount := 0;

      try
        if IsDprOrPas(View.Buffer.FileName) or IsInc(View.Buffer.FileName) then
        begin
          // 用语法解析的方式，判断当前位置是否应该移动
          // procedure/function 后未到 begin/asm 间，不该移动。
          // class/interface end之间，不该移动。
          Lex := TmwPasLex.Create;
          try
            Lex.Origin := PAnsiChar(Stream.Memory);
            IsInProcDeclare := False;

            // 往后搜到光标位置即可，不用再搜后面
            while (Lex.TokenID <> tkNull) and ((Lex.LineNumber < CharPos.Line - 1)
              or ((Lex.LineNumber = CharPos.Line - 1) and (Lex.TokenPos - Lex.LinePos < CharPos.CharIndex))) do
            begin
              case Lex.TokenID of
                tkRoundOpen:
                  if IsInProcDeclare then
                    Inc(RoundCount);
                tkRoundClose:
                  if IsInProcDeclare then
                    Dec(RoundCount);
                tkProcedure, tkFunction, tkConstructor, tkDestructor: // 函数过程未到 begin 处不可移
                  begin
                    Stack.Push(Pointer(CanMove));
                    IsInProcDeclare := True;
                    RoundCount := 0;
                    CanMove := False;
                  end;
                tkBegin, tkAsm: // begin/asm 间的语句块可移
                  begin
                    if RoundCount = 0 then
                      IsInProcDeclare := False;
                    Stack.Push(Pointer(CanMove));
                    CanMove := True;
                  end;
                tkClass, tkInterface, tkDispinterface, tkRecord, tkObject:
                  begin
                    Stack.Push(Pointer(CanMove));
                    CanMove := False;
                  end;
                tkEnd:
                  begin
                    if Stack.Count > 0 then
                      CanMove := Boolean(Stack.Pop);
                    if RoundCount = 0 then
                      IsInProcDeclare := False;
                  end;
                tkUses: // 暂不考虑过程内部的const/var情况，都认为可移
                  CanMove := True;
                tkVar, tkConst: // 区分过程声明参数的 var 和 const
                  CanMove := RoundCount = 0;
              end;

              Lex.NextNoJunk;
            end;
          finally
            Lex.Free;
          end;
        end
        else if IsCppSourceModule(View.Buffer.FileName) then
        begin
          CParser := TBCBTokenList.Create;
          try
            // C 文件中目前只想起 for 中的分号不需要移动，其它情况暂未想起来
            CParser.SetOrigin(PAnsiChar(Stream.Memory), Stream.Size);
            IsInFor := False;
            while (CParser.RunID <> ctknull) and ((CParser.RunLineNumber < CharPos.Line)
              or ((CParser.RunLineNumber = CharPos.Line) and (CParser.RunColNumber < CharPos.CharIndex))) do
            begin
              case CParser.RunID of
                ctkfor:
                  begin
                    IsInFor := True;
                    RoundCount := 0;
                  end;
                ctkroundopen:
                  begin
                    if IsInFor then
                      Inc(RoundCount);
                  end;
                ctkroundclose:
                  begin
                    if IsInFor then
                    begin
                      Dec(RoundCount);
                      if RoundCount = 0 then
                        IsInFor := False;
                    end;
                  end;
              end;
              CParser.NextNonJunk;
            end;

            CanMove := not IsInFor or (RoundCount <> 1);
          finally
            CParser.Free;
          end;
        end;
      finally
        Stream.Free;
        Stack.Free;
      end;

      if CanMove then
        MoveToLineEnd;
    end
    else if EditPos.Col > 0 then // 如果不是，也有可能光标在单引号或大括号前一格，此时也应该移动
    begin
      // 光标列减一，继续检测
      Dec(EditPos.Col);
      EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
      // 如果减一后仍然不是注释或字符串，就移
      if not (Element in [atString, atComment, atAssembler]) then
        MoveToLineEnd;

      // 但目前对于光标在两个连续的大括号注释之间也就是 {}|{} 的情况，还是无法处理
    end;
  end;
end;

{$HINTS OFF}

function TCnSrcEditorKey.DoRename(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Cur, UpperCur, UpperHeadCur, NewName: string;
  CurIndex: Integer;
  EditControl: TControl;
  EditView: IOTAEditView;
  Parser: TCnPasStructureParser;
  CParser: TCnCppStructureParser;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I, iMaxCursorOffset: Integer;
  Rit: TCnRenameIdentifierType;
  iStart, iOldTokenLen: Integer;
  NewCode: string;
  EditWriter: IOTAEditWriter;
  CurToken, LastToken, StartToken, EndToken, StartCurToken, EndCurToken: TCnPasToken;
  CurFuncStartToken, CurFuncEndToken: TCnCppToken;
  FirstEnter: Boolean;
  LastTokenPos: Integer;
  FrmModalResult: Boolean;
  BookMarkList: TObjectList;
  Element, LineFlag: Integer;
  CurTokens: TList;
  F: string;
  FSrcEditor: IOTASourceEditor;
begin
  Result := False;
  if (Key <> FRenameKey) or (Shift <> FRenameShift) then
    Exit;

  if (GetIDEActionFromShortCut(ShortCut(VK_F2, [])) <> nil) and
    GetIDEActionFromShortCut(ShortCut(VK_F2, [])).Visible then
    Exit; // 如果已经有了 F2 的快捷键的 Action，则不处理

  if not CnOtaGetCurrPosToken(Cur, CurIndex) then
    Exit;
  if Cur = '' then Exit;

  // 做 F2 更改当前变量名的动作
  BookMarkList := nil;
  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;
  try
    EditView := EditControlWrapper.GetEditView(EditControl);
  except
    Exit;
  end;

  if EditView = nil then
    Exit;

  // 如果是编译指令内部，则退出，因为现在即使弹出也不会更改。
  EditControlWrapper.GetAttributeAtPos(EditControl, EditView.CursorPos,
    False, Element, LineFlag);
  if Element in [atComment, atPreproc] then
    Exit;

  // 处理 Pascal 文件
  if IsDprOrPas(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName) then
  begin
    Parser := TCnPasStructureParser.Create;
    Stream := TMemoryStream.Create;
    try
      CnOtaSaveEditorToStream(EditView.Buffer, Stream);

      // 解析当前显示的源文件
      Parser.ParseSource(PAnsiChar(Stream.Memory),
        IsDpr(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName), False);
    finally
      Stream.Free;
    end;

    // 解析后再查找当前光标所在的块
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);
    Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

    try
      CurToken := nil;
      CurTokens := TList.Create;
      UpperCur := UpperCase(Cur);

      // 先转换并加入所有与光标下标识符相同的 Token
      for I := 0 to Parser.Count - 1 do
      begin
        CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);

        Parser.Tokens[I].EditCol := EditPos.Col;
        Parser.Tokens[I].EditLine := EditPos.Line;

        if (Parser.Tokens[I].TokenID = tkIdentifier) and (UpperCase(string(Parser.Tokens[I].Token)) = UpperCur) then
        begin
          CurTokens.Add(Parser.Tokens[I]);
          if (CurToken = nil) and
            IsCurrentToken(Pointer(EditView), EditControl, Parser.Tokens[I]) then
            CurToken := Parser.Tokens[I];
        end;
      end;
      if CurTokens.Count = 0 then Exit;

      // 如果当前光标下的 Token 在 InnerMethod 之间，并且所有的 Token 都在
      // InnerMethod 之间，则 RIT 为 InnerProc
      // else 如果当前光标下的 Token 在 CurrentMethod 之间，并且所有的 Token 都在
      // CurrentMethod 之间，则 RIT 为 CurrentProc
      // else RIT 为 Unit

      Rit := ritInvalid;
      if Assigned(Parser.ChildMethodStartToken) and
        Assigned(Parser.ChildMethodCloseToken) then
      begin
        if (TCnPasToken(CurTokens[0]).ItemIndex >= Parser.ChildMethodStartToken.ItemIndex)
          and (TCnPasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= Parser.ChildMethodCloseToken.ItemIndex) then
          Rit := ritInnerProc;
      end;
      if Rit = ritInvalid then
      begin
        if Assigned(Parser.MethodStartToken) and
          Assigned(Parser.MethodCloseToken) then
        begin
          if (TCnPasToken(CurTokens[0]).ItemIndex >= Parser.MethodStartToken.ItemIndex)
            and (TCnPasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
            <= Parser.MethodCloseToken.ItemIndex) then
            Rit := ritCurrentProc;
        end;
      end;
      if Rit = ritInvalid then
      begin
        if Assigned(Parser.InnerBlockStartToken) and
          Assigned(Parser.InnerBlockCloseToken) then
        begin
          if (TCnPasToken(CurTokens[0]).ItemIndex >= Parser.InnerBlockStartToken.ItemIndex)
            and (TCnPasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
            <= Parser.InnerBlockCloseToken.ItemIndex) then
            Rit := ritCurrentBlock;
        end;
      end;
      if Rit = ritInvalid then
        Rit := ritUnit;

      // 弹出对话框，设置其替换范围，并根据是否有当前 Method/Child 等控制界面使能
      with TCnIdentRenameForm.Create(nil) do
      begin
        try
          lblReplacePromt.Caption := Format(SCnRenameVarHintFmt, [Cur]);
          UpperHeadCur := Cur;
          if FUpperFirstLetter and (Length(UpperHeadCur) >= 1) and
            CharInSet(UpperHeadCur[1], ['a'..'z']) then
            UpperHeadCur[1] := Chr(Ord(UpperHeadCur[1]) - 32);
          edtRename.Text := UpperHeadCur;

          rbCurrentProc.Enabled := Assigned(Parser.MethodStartToken) and
            Assigned(Parser.MethodCloseToken);
          rbCurrentInnerProc.Enabled := Assigned(Parser.ChildMethodStartToken) and
            Assigned(Parser.ChildMethodCloseToken);

          if rbCurrentProc.Enabled then
            rbCurrentProc.Checked := True;
          if rbCurrentInnerProc.Enabled then
            rbCurrentInnerProc.Checked := True;
          if (not rbCurrentProc.Checked) and (not rbCurrentInnerProc.Checked) then
            rbUnit.Checked := True;

          rbCppHPair.Enabled := False;
          rbCppHPair.Checked := False;

          rbCurrentBlock.Enabled := Assigned(Parser.InnerBlockStartToken) and
            Assigned(Parser.InnerBlockCloseToken);

          FrmModalResult := ShowModal = mrOk;
          NewName := Trim(edtRename.Text);

          if rbCurrentProc.Checked then
            Rit := ritCurrentProc
          else if rbCurrentInnerProc.Checked then
            Rit := ritInnerProc
          else if rbCurrentBlock.Checked then
            Rit := ritCurrentBlock
          else
            Rit := ritUnit;
        finally
          Free;
        end;
      end;

      if FrmModalResult then
      begin
        if not IsValidRenameIdent(NewName) then
        begin
          if not QueryDlg(SCnRenameErrorValid) then
            Exit;
        end;

        StartToken := nil;
        EndToken := nil;

        // 注意 StartToken 和 EndToken 未必是属于 CurTokens 中的。
        // StartCurToken 和 EndCurToken 才是 CurTokens 列表中的头尾俩
        if Rit = ritUnit then
        begin
          // 替换范围为整个 unit 时，起始和终结 Token 为列表中头尾俩
          StartToken := TCnPasToken(CurTokens[0]);
          EndToken := TCnPasToken(CurTokens[CurTokens.Count - 1]);
        end
        else if Rit = ritCurrentProc then
        begin
          StartToken := Parser.MethodStartToken;
          EndToken := Parser. MethodCloseToken;
        end
        else if Rit = ritInnerProc then
        begin
          StartToken := Parser.ChildMethodStartToken;
          EndToken := Parser.ChildMethodCloseToken;
        end
        else if Rit = ritCurrentBlock then
        begin
          StartToken := Parser.InnerBlockStartToken;
          EndToken := Parser.InnerBlockCloseToken;
        end;

        if (StartToken = nil) or (EndToken = nil) then Exit;

        // 记录此 View 的 Bookmarks
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;
        iMaxCursorOffset := EditView.CursorPos.Col - CurToken.EditCol;
        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor;

        // 执行完循环后，NewCode 应该为覆盖了需要替换的所有 Token 的替换后内容
        for I := 0 to CurTokens.Count - 1 do
        begin
          if (TCnPasToken(CurTokens[I]).ItemIndex >= StartToken.ItemIndex) and
            (TCnPasToken(CurTokens[I]).ItemIndex <= EndToken.ItemIndex) then
          begin
            // 属于要处理之列。第一回，处理头，最后循环后处理尾
            if FirstEnter then
            begin
              StartCurToken := TCnPasToken(CurTokens[I]); // 记录第一个 CurToken
              FirstEnter := False;
            end;

            if LastToken = nil then
              NewCode := NewName
            else
            begin
              // 从上一 Token 的尾巴，到现任 Token 的头，再加替换后的文字，都用 AnsiString 来计算
              LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
              NewCode := NewCode + string(Copy(AnsiString(Parser.Source), LastTokenPos + 1,
                TCnPasToken(CurTokens[I]).TokenPos - LastTokenPos)) + NewName;
            end;
  {$IFDEF DEBUG}
            CnDebugger.LogMsg('Pas NewCode: ' + NewCode);
  {$ENDIF}
            // 同一行前面的会影响光标位置
            if (TCnPasToken(CurTokens[I]).EditLine = CurToken.EditLine) and
              (TCnPasToken(CurTokens[I]).EditCol < CurToken.EditCol) then
              Inc(iStart);

            LastToken := TCnPasToken(CurTokens[I]);   // 记录上一个处理过的 CurToken
            EndCurToken := TCnPasToken(CurTokens[I]); // 记录最后一个 CurToken
          end;
        end;

        if StartCurToken <> nil then
          EditWriter.CopyTo(StartCurToken.TokenPos);

        if EndCurToken <> nil then
          EditWriter.DeleteTo(EndCurToken.TokenPos + Length(EndCurToken.Token));

        EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));

        // 调整光标位置
        iOldTokenLen := Length(Cur);
        if iStart > 0 then
          CnOtaMovePosInCurSource(ipCur, 0, iStart * (Length(NewName) - iOldTokenLen))
        else if iStart = 0 then
          CnOtaMovePosInCurSource(ipCur, 0, Max(-iMaxCursorOffset, Length(NewName) - iOldTokenLen));
        EditView.Paint;

        // 恢复此 View 的 Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);
      end;
    finally
      FreeAndNil(CurTokens);
      FreeAndNil(Parser);
      FreeAndNil(BookMarkList);
    end;
  end
  else if IsCppSourceModule(EditView.Buffer.FileName) then // C/C++ 文件
  begin
    // 判断位置，根据需要弹出改名窗体。
    CParser := TCnCppStructureParser.Create;
    Stream := TMemoryStream.Create;
    try
      CnOtaSaveEditorToStream(EditView.Buffer, Stream);
      // 解析当前显示的源文件
      CParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
        EditView.CursorPos.Line, EditView.CursorPos.Col, True);
    finally
      Stream.Free;
    end;

    try
      CurToken := nil;
      CurTokens := TList.Create;

      // 先转换并加入所有与光标下标识符相同的 Token，区分大小写
      for I := 0 to CParser.Count - 1 do
      begin
        CharPos := OTACharPos(CParser.Tokens[I].CharIndex, CParser.Tokens[I].LineNumber + 1);
        try
          EditView.ConvertPos(False, EditPos, CharPos);
        except
          Continue; // D5/6 下 ConvertPos 在只有一个大于号时会出错，只能屏蔽
        end;

        CParser.Tokens[I].EditCol := EditPos.Col;
        CParser.Tokens[I].EditLine := EditPos.Line;

        if (CParser.Tokens[I].CppTokenKind = ctkidentifier) and (string(CParser.Tokens[I].Token) = Cur) then
        begin
          CurTokens.Add(CParser.Tokens[I]);
          if (CurToken = nil) and
            IsCurrentToken(Pointer(EditView), EditControl, CParser.Tokens[I]) then
            CurToken := CParser.Tokens[I];
        end;
      end;
      if CurTokens.Count = 0 then
        Exit;

      CurFuncStartToken := nil;
      CurFuncEndToken := nil;

      // 首先，找出正确的 CurrentFunc：解析器解出的最外层的非 namespace 优先，再手工最外层的非 namespace，
      // 最后才用非正规的次外层（当最外层是 namespace，多层 namespace 嵌套时不准确）
      if (CParser.NonNamespaceStartToken <> nil) and (CParser.NonNamespaceCloseToken <> nil) then
      begin
        CurFuncStartToken := CParser.NonNamespaceStartToken;
        CurFuncEndToken := CParser.NonNamespaceCloseToken;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp F2 Rename. Prepare Cpp Range: NonNamespace');
{$ENDIF}
      end
      else if not CParser.BlockIsNamespace and (CParser.BlockStartToken <> nil) and
        (CParser.BlockCloseToken <> nil) then
      begin
        CurFuncStartToken := CParser.BlockStartToken;
        CurFuncEndToken := CParser.BlockCloseToken;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp F2 Rename. Prepare Cpp Range: Block');
{$ENDIF}
      end
      else if CParser.BlockIsNamespace and (CParser.ChildStartToken <> nil) and
        (CParser.ChildCloseToken <> nil) then
      begin
        CurFuncStartToken := CParser.ChildStartToken;
        CurFuncEndToken := CParser.ChildCloseToken;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp F2 Rename. Prepare Cpp Range: Child');
{$ENDIF}
      end;

      // 如果当前光标下的 Token 在 InnerBlock 之间，并且所有的 Token 都在
      // InnerBlock 之间，并且 InnerBlock 不是 CurFunc，则 RIT 为 CurrentBlock
      // 如果当前光标下的 Token 在 CurFunc 之间，并且所有的 Token 都在
      // CurFun 之间，则 RIT 为 CurrentProc
      // 俩都不是时，RIT 为 Unit
      Rit := ritInvalid;
      if (CParser.InnerBlockStartToken <> nil) and (CParser.InnerBlockCloseToken <> nil)
        and (CParser.InnerBlockStartToken <> CurFuncStartToken) and
            (CParser.InnerBlockCloseToken <> CurFuncEndToken) then
      begin
        if (TCnPasToken(CurTokens[0]).ItemIndex >= CParser.InnerBlockStartToken.ItemIndex)
          and (TCnPasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= CParser.InnerBlockCloseToken.ItemIndex) then
          Rit := ritCurrentBlock;
      end;
      if (Rit = ritInvalid) and (CurFuncStartToken <> nil) and (CurFuncEndToken <> nil) then
      begin
        if (TCnPasToken(CurTokens[0]).ItemIndex >= CurFuncStartToken.ItemIndex)
          and (TCnPasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= CurFuncEndToken.ItemIndex) then
          Rit := ritCurrentProc;
      end;
      if Rit = ritInvalid then
        Rit := ritUnit;

{$IFDEF DEBUG}
      CnDebugger.LogMsg('Cpp F2 Rename. Calc Rit to ' + IntToStr(Ord(Rit)));
{$ENDIF}

      // 弹出对话框
      with TCnIdentRenameForm.Create(nil) do
      begin
        try
          lblReplacePromt.Caption := Format(SCnRenameVarHintFmt, [Cur]);
          UpperHeadCur := Cur;
          if FUpperFirstLetter and (Length(UpperHeadCur) >= 1) and
            CharInSet(UpperHeadCur[1], ['a'..'z']) then
            UpperHeadCur[1] := Chr(Ord(UpperHeadCur[1]) - 32);
          edtRename.Text := UpperHeadCur;

          rbCurrentProc.Enabled := Assigned(CurFuncStartToken) and
            Assigned(CurFuncEndToken);
          rbCurrentInnerProc.Enabled := False;

          rbCurrentBlock.Enabled := Assigned(CParser.InnerBlockStartToken) and
            Assigned(CParser.InnerBlockCloseToken) and
            (CParser.InnerBlockStartToken <> CurFuncStartToken) and
            (CParser.InnerBlockCloseToken <> CurFuncEndToken);

          if rbCurrentProc.Enabled and (Rit <> ritUnit) then // 标识符范围超出 CurFunc 时，默认不选中外层函数这项
            rbCurrentProc.Checked := True;
          if rbCurrentBlock.Enabled and (Rit = ritCurrentBlock) then // 标识符只在最内层内时，选中最内层选项
            rbCurrentBlock.Checked := True;
          if (not rbCurrentProc.Checked) and (not rbCurrentBlock.Checked) then
            rbUnit.Checked := True;

          F := EditView.Buffer.FileName;
          // Cpp/H 文件均在打开状态则此选项使能
          rbCppHPair.Enabled := (IsCpp(F) and CnOtaIsFileOpen(_CnChangeFileExt(F, '.h')))
            or (IsH(F) and CnOtaIsFileOpen(_CnChangeFileExt(F, '.cpp')));

          FrmModalResult := ShowModal = mrOk;
          NewName := Trim(edtRename.Text);

          if rbCurrentProc.Checked then
            Rit := ritCurrentProc
          else if rbCurrentInnerProc.Checked then
            Rit := ritInnerProc                   // 这里进不来，因为 C/C++ 没有函数内嵌
          else if rbUnit.Checked then
            Rit := ritUnit
          else if rbCurrentBlock.Checked then
            Rit := ritCurrentBlock
          else
            Rit := ritCppHPair;
        finally
          Free;
        end;
      end;

      if FrmModalResult then
      begin
        if not IsValidRenameIdent(NewName) then
        begin
          if not QueryDlg(SCnRenameErrorValid) then
            Exit;
        end;

        StartToken := nil;
        EndToken := nil;
        if Rit in [ritUnit, ritCppHPair] then
        begin
          // 替换范围为整个 C 时，起始和终结 Token 为列表中头尾俩
          StartToken := TCnPasToken(CurTokens[0]);
          EndToken := TCnPasToken(CurTokens[CurTokens.Count - 1]);
        end
        else if Rit = ritCurrentProc then
        begin
          StartToken := CurFuncStartToken;
          EndToken := CurFuncEndToken;
        end
        else if Rit = ritCurrentBlock then
        begin
          StartToken := CParser.InnerBlockStartToken;
          EndToken := CParser.InnerBlockCloseToken;
        end;

        if (StartToken = nil) or (EndToken = nil) then Exit;

        // 记录此 View 的 Bookmarks
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;
        iMaxCursorOffset := EditView.CursorPos.Col - CurToken.EditCol;

        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor;

        // 执行完循环后，NewCode 应该为覆盖了需要替换的所有 Token 的替换后内容
        for I := 0 to CurTokens.Count - 1 do
        begin
          if (TCnPasToken(CurTokens[I]).ItemIndex >= StartToken.ItemIndex) and
            (TCnPasToken(CurTokens[I]).ItemIndex <= EndToken.ItemIndex) then
          begin
            // 属于要处理之列。第一回，处理头，最后循环后处理尾
            if FirstEnter then
            begin
              StartCurToken := TCnPasToken(CurTokens[I]); // 记录第一个 CurToken
              FirstEnter := False;
            end;

            if LastToken = nil then
              NewCode := NewName
            else
            begin
              // 从上一 Token 的尾巴，到现任 Token 的头，再加替换后的文字，都用 AnsiString 来计算
              LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
              NewCode := NewCode + string(Copy(AnsiString(CParser.Source), LastTokenPos + 1,
                TCnPasToken(CurTokens[I]).TokenPos - LastTokenPos)) + NewName;
            end;
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Cpp NewCode: ' + NewCode);
{$ENDIF}
            // 同一行前面的会影响光标位置
            if (TCnPasToken(CurTokens[I]).EditLine = CurToken.EditLine) and
              (TCnPasToken(CurTokens[I]).EditCol < CurToken.EditCol) then
              Inc(iStart);

            LastToken := TCnPasToken(CurTokens[I]);   // 记录上一个处理过的 CurToken
            EndCurToken := TCnPasToken(CurTokens[I]); // 记录最后一个 CurToken
          end;
        end;

        if StartCurToken <> nil then
          EditWriter.CopyTo(StartCurToken.TokenPos);

        if EndCurToken <> nil then
          EditWriter.DeleteTo(EndCurToken.TokenPos + Length(EndCurToken.Token));

        EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));

        // 调整光标位置
        iOldTokenLen := Length(Cur);
        if iStart > 0 then
          CnOtaMovePosInCurSource(ipCur, 0, iStart * (Length(NewName) - iOldTokenLen))
        else if iStart = 0 then
          CnOtaMovePosInCurSource(ipCur, 0, Max(-iMaxCursorOffset, Length(NewName) - iOldTokenLen));
        EditView.Paint;

        // 恢复此 View 的 Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);

        // 改另一个文件
        if Rit <> ritCppHPair then
          Exit;

        if IsCpp(F) then
          F := _CnChangeFileExt(F, '.h')
        else if IsH(F) then
          F := _CnChangeFileExt(F, '.cpp');
        if not CnOtaIsFileOpen(F) then
          Exit;

        // 从头解析另一个文件并查找替换
        FreeAndNil(CParser);
        FreeAndNil(CurTokens);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp Another Starting: ' + F);
{$ENDIF}

        EditView := CnOtaGetTopOpenedEditViewFromFileName(F);
        if EditView = nil then
          Exit;

{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp Another SourceEditor and EditView Got.');
{$ENDIF}
        CurToken := nil;
        CurTokens := TList.Create;

        CParser := TCnCppStructureParser.Create;
        Stream := TMemoryStream.Create;
        try
          CnOtaSaveEditorToStream(FSrcEditor, Stream);
          // 解析当前显示的源文件
          CParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
            1, 1, True);
        finally
          Stream.Free;
        end;

        // 先转换并加入所有与光标下标识符相同的 Token，区分大小写
        for I := 0 to CParser.Count - 1 do
        begin
          CharPos := OTACharPos(CParser.Tokens[I].CharIndex, CParser.Tokens[I].LineNumber + 1);
          try
            EditView.ConvertPos(False, EditPos, CharPos);
          except
            Continue; // D5/6 下 ConvertPos 在只有一个大于号时会出错，只能屏蔽
          end;

          CParser.Tokens[I].EditCol := EditPos.Col;
          CParser.Tokens[I].EditLine := EditPos.Line;

          if (CParser.Tokens[I].CppTokenKind = ctkidentifier) and (string(CParser.Tokens[I].Token) = Cur) then
            CurTokens.Add(CParser.Tokens[I]);
        end;
        if CurTokens.Count = 0 then Exit;

        // 另一个文件，无需判断范围，全部处理，并且不处理光标
        // 记录此 View 的 Bookmarks
        FreeAndNil(BookMarkList);
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;

        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor(FSrcEditor);

        // 执行完循环后，NewCode 应该为覆盖了需要替换的所有 Token 的替换后内容
        for I := 0 to CurTokens.Count - 1 do
        begin
          // 属于要处理之列。第一回，处理头，最后循环后处理尾
          if FirstEnter then
          begin
            StartCurToken := TCnPasToken(CurTokens[I]); // 记录第一个 CurToken
            FirstEnter := False;
          end;

          if LastToken = nil then
            NewCode := NewName
          else
          begin
            // 从上一 Token 的尾巴，到现任 Token 的头，再加替换后的文字，都用 AnsiString 来计算
            LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
            NewCode := NewCode + string(Copy(AnsiString(CParser.Source), LastTokenPos + 1,
              TCnPasToken(CurTokens[I]).TokenPos - LastTokenPos)) + NewName;
          end;
{$IFDEF DEBUG}
          CnDebugger.LogMsg('Cpp Another NewCode: ' + NewCode);
{$ENDIF}
          LastToken := TCnPasToken(CurTokens[I]);   // 记录上一个处理过的 CurToken
          EndCurToken := TCnPasToken(CurTokens[I]); // 记录最后一个 CurToken
        end;

        if StartCurToken <> nil then
          EditWriter.CopyTo(StartCurToken.TokenPos);

        if EndCurToken <> nil then
          EditWriter.DeleteTo(EndCurToken.TokenPos + Length(EndCurToken.Token));

        EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));
        // 恢复此 View 的 Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);
      end;
    finally
      FreeAndNil(CurTokens);
      FreeAndNil(CParser);
      FreeAndNil(BookMarkList);
    end;
  end;

  Handled := True;
end;

{$IFDEF IDE_WIDECONTROL}

procedure TCnSrcEditorKey.ConvertToUtf8Stream(Stream: TStream);
var
  S: AnsiString;
  Res: WideString;
begin
  if Stream = nil then
    Exit;
  SetLength(S, Stream.Size);
  Stream.Position := 0;

  Stream.Read(PAnsiChar(S)^, Stream.Size);
  Res := Utf8Decode(S);
  Stream.Size := 0;
  Stream.Position := 0;

  Stream.Write(PWideChar(Res)^, (Length(Res) + 1) * SizeOf(WideChar));
  Stream.Position := 0;
end;

// 绝大部分复制自 DoRename，但处理代码部分是 Unicode/Utf8，用于 D2007 或以上版本
function TCnSrcEditorKey.DoRenameW(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  TmpCur: TCnIdeTokenString;
  Cur, UpperCur, UpperHeadCur, NewName: WideString;
  CurIndex: Integer;
  EditControl: TControl;
  EditView: IOTAEditView;
  Parser: TCnWidePasStructParser;
  CParser: TCnWideCppStructParser;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I, iMaxCursorOffset: Integer;
  Rit: TCnRenameIdentifierType;
  iStart, iOldTokenLen: Integer;
  NewCode: WideString;
  EditWriter: IOTAEditWriter;
  CurToken, LastToken, StartToken, EndToken, StartCurToken, EndCurToken: TCnWidePasToken;
  CurFuncStartToken, CurFuncEndToken: TCnWideCppToken;
  FirstEnter: Boolean;
  LastTokenPos: Integer;
  FrmModalResult: Boolean;
  BookMarkList: TObjectList;
  Element, LineFlag: Integer;
  CurTokens: TList;
  F: string;
  FEditor: IOTAEditor;
  FSrcEditor: IOTASourceEditor;
begin
  Result := False;
  if (Key <> FRenameKey) or (Shift <> FRenameShift) then Exit;

  if (GetIDEActionFromShortCut(ShortCut(VK_F2, [])) <> nil) and
    GetIDEActionFromShortCut(ShortCut(VK_F2, [])).Visible then
    Exit; // 如果已经有了 F2 的快捷键的 Action，则不处理

  if not CnOtaGeneralGetCurrPosToken(TmpCur, CurIndex) then
    Exit;

  if TmpCur = '' then
    Exit;

  Cur := TmpCur;

  // 做 F2 更改当前变量名的动作
  BookMarkList := nil;
  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;
  try
    EditView := EditControlWrapper.GetEditView(EditControl);
  except
    Exit;
  end;

  if EditView = nil then
    Exit;

  // 如果是编译指令内部，则退出，因为现在即使弹出也不会更改。
  EditControlWrapper.GetAttributeAtPos(EditControl, EditView.CursorPos,
    False, Element, LineFlag);
  if Element in [atComment, atPreproc] then
    Exit;

  // 处理 Pascal 文件
  if IsDprOrPas(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName) then
  begin
    Parser := TCnWidePasStructParser.Create;
{$IFDEF BDS}
    Parser.UseTabKey := True;
    Parser.TabWidth := EditControlWrapper.GetTabWidth;
{$ENDIF}
    Stream := TMemoryStream.Create;
    try
{$IFDEF UNICODE}
      CnOtaSaveEditorToStreamW(EditView.Buffer, Stream);
{$ELSE}
      CnOtaSaveEditorToStream(EditView.Buffer, Stream, False, False); // 读出 Utf8 流
      // D2005~2007 下转成 WideString 重新写入 Stream
      ConvertToUtf8Stream(Stream);
{$ENDIF}
      // 解析当前显示的源文件
      Parser.ParseSource(PWideChar(Stream.Memory),
        IsDpr(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName), False);
    finally
      Stream.Free;
    end;

    // 解析后再查找当前光标所在的块
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);
    Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

    try
      CurToken := nil;
      CurTokens := TList.Create;
      UpperCur := UpperCase(Cur);

      // 先转换并加入所有与光标下标识符相同的 Token
      for I := 0 to Parser.Count - 1 do
      begin
        CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);
        // 以上这句在 D2009 中带汉字时结果会有偏差，暂无办法，
        // 因此直接采用下面 CharIndex + 1 的方式，Parser 本身已对 Tab 键展开。
        EditPos.Col := Parser.Tokens[I].CharIndex + 1;
        Parser.Tokens[I].EditCol := EditPos.Col;
        Parser.Tokens[I].EditLine := EditPos.Line;

        if (Parser.Tokens[I].TokenID = tkIdentifier) and (UpperCase(string(Parser.Tokens[I].Token)) = UpperCur) then
        begin
          CurTokens.Add(Parser.Tokens[I]);
          if (CurToken = nil) and
            IsCurrentTokenW(Pointer(EditView), EditControl, Parser.Tokens[I]) then
            CurToken := Parser.Tokens[I];
        end;
      end;
      if CurTokens.Count = 0 then Exit;

      // 如果当前光标下的 Token 在 InnerMethod 之间，并且所有的 Token 都在
      // InnerMethod 之间，则 RIT 为 InnerProc
      // else 如果当前光标下的 Token 在 CurrentMethod 之间，并且所有的 Token 都在
      // CurrentMethod 之间，则 RIT 为 CurrentProc
      // else RIT 为 Unit

      Rit := ritInvalid;
      if Assigned(Parser.ChildMethodStartToken) and
        Assigned(Parser.ChildMethodCloseToken) then
      begin
        if (TCnWidePasToken(CurTokens[0]).ItemIndex >= Parser.ChildMethodStartToken.ItemIndex)
          and (TCnWidePasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= Parser.ChildMethodCloseToken.ItemIndex) then
          Rit := ritInnerProc;
      end;
      if Rit = ritInvalid then
      begin
        if Assigned(Parser.MethodStartToken) and
          Assigned(Parser.MethodCloseToken) then
        begin
          if (TCnWidePasToken(CurTokens[0]).ItemIndex >= Parser.MethodStartToken.ItemIndex)
            and (TCnWidePasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
            <= Parser.MethodCloseToken.ItemIndex) then
            Rit := ritCurrentProc;
        end;
      end;
      if Rit = ritInvalid then
      begin
        if Assigned(Parser.InnerBlockStartToken) and
          Assigned(Parser.InnerBlockCloseToken) then
        begin
          if (TCnWidePasToken(CurTokens[0]).ItemIndex >= Parser.InnerBlockStartToken.ItemIndex)
            and (TCnWidePasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
            <= Parser.InnerBlockCloseToken.ItemIndex) then
            Rit := ritCurrentBlock;
        end;
      end;
      if Rit = ritInvalid then
        Rit := ritUnit;

      // 弹出对话框，设置其替换范围，并根据是否有当前 Method/Child 等控制界面使能
      with TCnIdentRenameForm.Create(nil) do
      begin
        try
          lblReplacePromt.Caption := Format(SCnRenameVarHintFmt, [Cur]);
          UpperHeadCur := Cur;
          if FUpperFirstLetter and (Length(UpperHeadCur) >= 1) and (CharInSet(Char(UpperHeadCur[1]), ['a'..'z'])) then
            UpperHeadCur[1] := WideChar(Chr(Ord(UpperHeadCur[1]) - 32));
          edtRename.Text := UpperHeadCur;

          rbCurrentProc.Enabled := Assigned(Parser.MethodStartToken) and
            Assigned(Parser.MethodCloseToken);
          rbCurrentInnerProc.Enabled := Assigned(Parser.ChildMethodStartToken) and
            Assigned(Parser.ChildMethodCloseToken);

          if rbCurrentProc.Enabled then
            rbCurrentProc.Checked := True;
          if rbCurrentInnerProc.Enabled then
            rbCurrentInnerProc.Checked := True;
          if (not rbCurrentProc.Checked) and (not rbCurrentInnerProc.Checked) then
            rbUnit.Checked := True;

          rbCppHPair.Enabled := False;
          rbCppHPair.Checked := False;

          rbCurrentBlock.Enabled := Assigned(Parser.InnerBlockStartToken) and
            Assigned(Parser.InnerBlockCloseToken);

          FrmModalResult := ShowModal = mrOk;
          NewName := Trim(edtRename.Text);

          if rbCurrentProc.Checked then
            Rit := ritCurrentProc
          else if rbCurrentInnerProc.Checked then
            Rit := ritInnerProc
          else if rbCurrentBlock.Checked then
            Rit := ritCurrentBlock
          else
            Rit := ritUnit;
        finally
          Free;
        end;
      end;

      if FrmModalResult then
      begin
        if not IsValidRenameIdent(NewName) then
        begin
          if not QueryDlg(SCnRenameErrorValid) then
            Exit;
        end;

        StartToken := nil;
        EndToken := nil;

        // 注意 StartToken 和 EndToken 未必是属于 CurTokens 中的。
        // StartCurToken 和 EndCurToken 才是 CurTokens 列表中的头尾俩
        if Rit = ritUnit then
        begin
          // 替换范围为整个 unit 时，起始和终结 Token 为列表中头尾俩
          StartToken := TCnWidePasToken(CurTokens[0]);
          EndToken := TCnWidePasToken(CurTokens[CurTokens.Count - 1]);
        end
        else if Rit = ritCurrentProc then
        begin
          StartToken := Parser.MethodStartToken;
          EndToken := Parser. MethodCloseToken;
        end
        else if Rit = ritInnerProc then
        begin
          StartToken := Parser.ChildMethodStartToken;
          EndToken := Parser.ChildMethodCloseToken;
        end
        else if Rit = ritCurrentBlock then
        begin
          StartToken := Parser.InnerBlockStartToken;
          EndToken := Parser.InnerBlockCloseToken;
        end;

        if (StartToken = nil) or (EndToken = nil) then Exit;

        // 记录此 View 的 Bookmarks
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;
        iMaxCursorOffset := EditView.CursorPos.Col - CurToken.EditCol;
        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor;

        // 执行完循环后，NewCode 应该为覆盖了需要替换的所有 Token 的替换后内容
        for I := 0 to CurTokens.Count - 1 do
        begin
          if (TCnWidePasToken(CurTokens[I]).ItemIndex >= StartToken.ItemIndex) and
            (TCnWidePasToken(CurTokens[I]).ItemIndex <= EndToken.ItemIndex) then
          begin
            // 属于要处理之列。第一回，处理头，最后循环后处理尾
            if FirstEnter then
            begin
              StartCurToken := TCnWidePasToken(CurTokens[I]); // 记录第一个 CurToken
              FirstEnter := False;
            end;

            if LastToken = nil then
              NewCode := NewName
            else
            begin
              // 从上一 Token 的尾巴，到现任 Token 的头，再加替换后的文字
              LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
              NewCode := NewCode + Copy(Parser.Source, LastTokenPos + 1,
                TCnWidePasToken(CurTokens[I]).TokenPos - LastTokenPos) + NewName;
            end;
  {$IFDEF DEBUG}
            CnDebugger.LogMsg('Pas NewCode: ' + NewCode);
  {$ENDIF}
            // 同一行前面的会影响光标位置
            if (TCnWidePasToken(CurTokens[I]).EditLine = CurToken.EditLine) and
              (TCnWidePasToken(CurTokens[I]).EditCol < CurToken.EditCol) then
              Inc(iStart);

            LastToken := TCnWidePasToken(CurTokens[I]);   // 记录上一个处理过的 CurToken
            EndCurToken := TCnWidePasToken(CurTokens[I]); // 记录最后一个 CurToken
          end;
        end;

        if StartCurToken <> nil then
        begin
          // 要处理的是 UTF8 的长度，而 Paser 算出的 TokenPos 是 Unicode 的因此需要转换
          EditWriter.CopyTo(Length(UTF8Encode(Copy(Parser.Source, 1, StartCurToken.TokenPos))));
        end;

        if EndCurToken <> nil then
        begin
          // 要处理的是 UTF8 的长度，而 Paser 算出的 TokenPos 是 Unicode 的因此需要转换
          EditWriter.DeleteTo(Length(UTF8Encode(Copy(Parser.Source, 1,
            EndCurToken.TokenPos + Length(EndCurToken.Token)))));
        end;
{$IFDEF UNICODE}
        EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(NewCode)));
{$ELSE}
        EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(NewCode)));
{$ENDIF}
        // 调整光标位置
        iOldTokenLen := Length(Cur);
        if iStart > 0 then
          CnOtaMovePosInCurSource(ipCur, 0, iStart * (Length(NewName) - iOldTokenLen))
        else if iStart = 0 then
          CnOtaMovePosInCurSource(ipCur, 0, Max(-iMaxCursorOffset, Length(NewName) - iOldTokenLen));
        EditView.Paint;

        // 恢复此 View 的 Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);
      end;
    finally
      FreeAndNil(CurTokens);
      FreeAndNil(Parser);
      FreeAndNil(BookMarkList);
    end;
  end
  else if IsCppSourceModule(EditView.Buffer.FileName) then // C/C++ 文件
  begin
    // 判断位置，根据需要弹出改名窗体。
    CParser := TCnWideCppStructParser.Create;
{$IFDEF BDS}
    CParser.UseTabKey := True;
    CParser.TabWidth := EditControlWrapper.GetTabWidth;
{$ENDIF}
    Stream := TMemoryStream.Create;
    try
{$IFDEF UNICODE}
      CnOtaSaveEditorToStreamW(EditView.Buffer, Stream);
{$ELSE}
      CnOtaSaveEditorToStream(EditView.Buffer, Stream, False, False); // 读出 Utf8 流
      // D2005~2007 下转成 WideString 重新写入 Stream
      ConvertToUtf8Stream(Stream);
{$ENDIF}
      // 解析当前显示的源文件
      CParser.ParseSource(PWideChar(Stream.Memory), Stream.Size div SizeOf(WideChar),
        EditView.CursorPos.Line, EditView.CursorPos.Col, True);
    finally
      Stream.Free;
    end;

    try
      CurToken := nil;
      CurTokens := TList.Create;

      // 先转换并加入所有与光标下标识符相同的 Token，区分大小写
      for I := 0 to CParser.Count - 1 do
      begin
        CnOtaConvertEditViewCharPosToEditPos(Pointer(EditView),
          CParser.Tokens[I].LineNumber + 1, CParser.Tokens[I].CharIndex, EditPos);

        CParser.Tokens[I].EditCol := EditPos.Col;
        CParser.Tokens[I].EditLine := EditPos.Line;

        if (CParser.Tokens[I].CppTokenKind = ctkidentifier) and (string(CParser.Tokens[I].Token) = Cur) then
        begin
          CurTokens.Add(CParser.Tokens[I]);
          if (CurToken = nil) and
            IsCurrentTokenW(Pointer(EditView), EditControl, CParser.Tokens[I]) then
            CurToken := CParser.Tokens[I];
        end;
      end;
      if CurTokens.Count = 0 then
        Exit;

      CurFuncStartToken := nil;
      CurFuncEndToken := nil;

      // 首先，找出正确的 CurrentFunc：解析器解出的最外层的非 namespace，再是手工最外层的非 namespace，
      // 最后才用非正规的次外层（当最外层是 namespace，多层 namespace 嵌套时不准确）
      if (CParser.NonNamespaceStartToken <> nil) and (CParser.NonNamespaceCloseToken <> nil) then
      begin
        CurFuncStartToken := CParser.NonNamespaceStartToken;
        CurFuncEndToken := CParser.NonNamespaceCloseToken;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp F2 RenameW. Prepare Cpp Range: NonNamespace');
{$ENDIF}
      end
      else if not CParser.BlockIsNamespace and (CParser.BlockStartToken <> nil) and
        (CParser.BlockCloseToken <> nil) then
      begin
        CurFuncStartToken := CParser.BlockStartToken;
        CurFuncEndToken := CParser.BlockCloseToken;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp F2 RenameW. Prepare Cpp Range: Block');
{$ENDIF}
      end
      else if CParser.BlockIsNamespace and (CParser.ChildStartToken <> nil) and
        (CParser.ChildCloseToken <> nil) then
      begin
        CurFuncStartToken := CParser.ChildStartToken;
        CurFuncEndToken := CParser.ChildCloseToken;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp F2 RenameW. Prepare Cpp Range: Child');
{$ENDIF}
      end;

      // 如果当前光标下的 Token 在 InnerBlock 之间，并且所有的 Token 都在
      // InnerBlock 之间，并且 InnerBlock 不是 CurFunc，则 RIT 为 CurrentBlock
      // 如果当前光标下的 Token 在 CurFunc 之间，并且所有的 Token 都在
      // CurFun 之间，则 RIT 为 CurrentProc
      // 俩都不是时，RIT 为 Unit
      Rit := ritInvalid;
      if (CParser.InnerBlockStartToken <> nil) and (CParser.InnerBlockCloseToken <> nil)
        and (CParser.InnerBlockStartToken <> CurFuncStartToken) and
            (CParser.InnerBlockCloseToken <> CurFuncEndToken) then
      begin
        if (TCnWideCppToken(CurTokens[0]).ItemIndex >= CParser.InnerBlockStartToken.ItemIndex)
          and (TCnWideCppToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= CParser.InnerBlockCloseToken.ItemIndex) then
          Rit := ritCurrentBlock;
      end;

      if (Rit = ritInvalid) and (CurFuncStartToken <> nil) and (CurFuncEndToken <> nil) then
      begin
        if (TCnWideCppToken(CurTokens[0]).ItemIndex >= CurFuncStartToken.ItemIndex)
          and (TCnWideCppToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= CurFuncEndToken.ItemIndex) then
          Rit := ritCurrentProc;
      end;

      if Rit = ritInvalid then
        Rit := ritUnit;

{$IFDEF DEBUG}
      CnDebugger.LogMsg('Cpp F2 RenameW. Calc Rit to ' + IntToStr(Ord(Rit)));
{$ENDIF}

      // 弹出对话框
      with TCnIdentRenameForm.Create(nil) do
      begin
        try
          lblReplacePromt.Caption := Format(SCnRenameVarHintFmt, [Cur]);
          UpperHeadCur := Cur;
          if FUpperFirstLetter and (Length(UpperHeadCur) >= 1) and (CharInSet(Char(UpperHeadCur[1]), ['a'..'z'])) then
            UpperHeadCur[1] := WideChar(Chr(Ord(UpperHeadCur[1]) - 32));
          edtRename.Text := UpperHeadCur;

          rbCurrentInnerProc.Enabled := False;
          rbCurrentProc.Enabled := Assigned(CurFuncStartToken) and
            Assigned(CurFuncEndToken);
          rbCurrentBlock.Enabled := Assigned(CParser.InnerBlockStartToken) and
            Assigned(CParser.InnerBlockCloseToken) and
            (CParser.InnerBlockStartToken <> CurFuncStartToken) and
            (CParser.InnerBlockCloseToken <> CurFuncEndToken);

          if rbCurrentBlock.Enabled and (Rit <> ritUnit) then // 标识符范围超出 CurFunc 时，默认不选中外层函数这项
            rbCurrentBlock.Checked := True;
          if rbCurrentBlock.Enabled and (Rit = ritCurrentBlock) then // 标识符只在最内层内时，选中最内层选项
            rbCurrentBlock.Checked := True;
          if (not rbCurrentProc.Checked) and (not rbCurrentBlock.Checked) then
            rbUnit.Checked := True;

          F := EditView.Buffer.FileName;
          // Cpp/H 文件均在打开状态则此选项使能
          rbCppHPair.Enabled := (IsCpp(F) and CnOtaIsFileOpen(_CnChangeFileExt(F, '.h')))
            or (IsH(F) and CnOtaIsFileOpen(_CnChangeFileExt(F, '.cpp')));

          FrmModalResult := ShowModal = mrOk;
          NewName := Trim(edtRename.Text);

          if rbCurrentProc.Checked then
            Rit := ritCurrentProc
          else if rbCurrentInnerProc.Checked then
            Rit := ritInnerProc                   // 这里不会进
          else if rbUnit.Checked then
            Rit := ritUnit
          else if rbCurrentBlock.Checked then
            Rit := ritCurrentBlock
          else
            Rit := ritCppHPair;
        finally
          Free;
        end;
      end;

      if FrmModalResult then
      begin
        if not IsValidRenameIdent(NewName) then
        begin
          if not QueryDlg(SCnRenameErrorValid) then
            Exit;
        end;

        StartToken := nil;
        EndToken := nil;

        if Rit in [ritUnit, ritCppHPair] then
        begin
          // 替换范围为整个 C 时，起始和终结 Token 为列表中头尾俩
          StartToken := TCnWideCppToken(CurTokens[0]);
          EndToken := TCnWideCppToken(CurTokens[CurTokens.Count - 1]);
        end
        else if Rit = ritCurrentProc then
        begin
          StartToken := CurFuncStartToken;
          EndToken := CurFuncEndToken;
        end
        else if Rit = ritCurrentBlock then
        begin
          StartToken := CParser.InnerBlockStartToken;
          EndToken := CParser.InnerBlockCloseToken;
        end;

        if (StartToken = nil) or (EndToken = nil) then Exit;

        // 记录此 View 的 Bookmarks
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;

        iMaxCursorOffset := EditView.CursorPos.Col - CurToken.EditCol;
        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor;

        // 执行完循环后，NewCode 应该为覆盖了需要替换的所有 Token 的替换后内容
        for I := 0 to CurTokens.Count - 1 do
        begin
          if (TCnWideCppToken(CurTokens[I]).ItemIndex >= StartToken.ItemIndex) and
            (TCnWideCppToken(CurTokens[I]).ItemIndex <= EndToken.ItemIndex) then
          begin
            // 属于要处理之列。第一回，处理头，最后循环后处理尾
            if FirstEnter then
            begin
              StartCurToken := TCnWideCppToken(CurTokens[I]); // 记录第一个 CurToken
              FirstEnter := False;
            end;

            if LastToken = nil then
              NewCode := NewName
            else
            begin
              // 从上一 Token 的尾巴，到现任 Token 的头，再加替换后的文字
              LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
              NewCode := NewCode + Copy(CParser.Source, LastTokenPos + 1,
                TCnWideCppToken(CurTokens[I]).TokenPos - LastTokenPos) + NewName;
            end;
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Cpp NewCode: ' + NewCode);
{$ENDIF}
            // 同一行前面的会影响光标位置
            if (TCnWideCppToken(CurTokens[I]).EditLine = CurToken.EditLine) and
              (TCnWideCppToken(CurTokens[I]).EditCol < CurToken.EditCol) then
              Inc(iStart);

            LastToken := TCnWideCppToken(CurTokens[I]);   // 记录上一个处理过的 CurToken
            EndCurToken := TCnWideCppToken(CurTokens[I]); // 记录最后一个 CurToken
          end;
        end;

        if StartCurToken <> nil then
        begin
          // 要处理的是 UTF8 的长度，而 Paser 算出的 TokenPos 是 Unicode 的因此需要转换
          EditWriter.CopyTo(Length(UTF8Encode(Copy(CParser.Source, 1, StartCurToken.TokenPos))));
        end;

        if EndCurToken <> nil then
        begin
          // 要处理的是 UTF8 的长度，而 Paser 算出的 TokenPos 是 Unicode 的因此需要转换
          EditWriter.DeleteTo(Length(UTF8Encode(Copy(CParser.Source, 1,
            EndCurToken.TokenPos + Length(EndCurToken.Token)))));
        end;
{$IFDEF UNICODE}
        EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(NewCode)));
{$ELSE}
        EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(NewCode)));
{$ENDIF}
        // 调整光标位置
        iOldTokenLen := Length(Cur);
        if iStart > 0 then
          CnOtaMovePosInCurSource(ipCur, 0, iStart * (Length(NewName) - iOldTokenLen))
        else if iStart = 0 then
          CnOtaMovePosInCurSource(ipCur, 0, Max(-iMaxCursorOffset, Length(NewName) - iOldTokenLen));
        EditView.Paint;

        // 恢复此 View 的 Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);

        // 改另一个文件
        if Rit <> ritCppHPair then
          Exit;

        if IsCpp(F) then
          F := _CnChangeFileExt(F, '.h')
        else if IsH(F) then
          F := _CnChangeFileExt(F, '.cpp');

        if not CnOtaIsFileOpen(F) then
          Exit;

        // 从头解析另一个文件并查找替换
        FreeAndNil(CParser);
        FreeAndNil(CurTokens);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp Another Starting: ' + F);
{$ENDIF}

        EditView := CnOtaGetTopOpenedEditViewFromFileName(F);
        if EditView = nil then
          Exit;

{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp Another SourceEditor and EditView Got.');
{$ENDIF}
        CurToken := nil;
        CurTokens := TList.Create;

        CParser := TCnWideCppStructParser.Create;
        Stream := TMemoryStream.Create;
        try
{$IFDEF UNICODE}
          CnOtaSaveEditorToStreamW(FSrcEditor, Stream);
{$ELSE}
          CnOtaSaveEditorToStream(FSrcEditor, Stream, False, False); // 读出 Utf8 流
          // D2005~2007 下转成 WideString 重新写入 Stream
          ConvertToUtf8Stream(Stream);
{$ENDIF}
          // 解析当前显示的源文件
          CParser.ParseSource(PWideChar(Stream.Memory), Stream.Size div SizeOf(WideChar),
            1, 1, True);
        finally
          Stream.Free;
        end;

        // 先转换并加入所有与光标下标识符相同的 Token，区分大小写
        for I := 0 to CParser.Count - 1 do
        begin
          CnOtaConvertEditViewCharPosToEditPos(Pointer(EditView),
            CParser.Tokens[I].LineNumber + 1, CParser.Tokens[I].CharIndex, EditPos);

          CParser.Tokens[I].EditCol := EditPos.Col;
          CParser.Tokens[I].EditLine := EditPos.Line;

          if (CParser.Tokens[I].CppTokenKind = ctkidentifier) and (string(CParser.Tokens[I].Token) = Cur) then
            CurTokens.Add(CParser.Tokens[I]);
        end;
        if CurTokens.Count = 0 then Exit;

        // 另一个文件，无需判断范围，全部处理，并且不处理光标
        // 记录此 View 的 Bookmarks
        FreeAndNil(BookMarkList);
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;

        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor(FSrcEditor);

        // 执行完循环后，NewCode 应该为覆盖了需要替换的所有 Token 的替换后内容
        for I := 0 to CurTokens.Count - 1 do
        begin
          // 属于要处理之列。第一回，处理头，最后循环后处理尾
          if FirstEnter then
          begin
            StartCurToken := TCnWideCppToken(CurTokens[I]); // 记录第一个 CurToken
            FirstEnter := False;
          end;

          if LastToken = nil then
            NewCode := NewName
          else
          begin
            // 从上一 Token 的尾巴，到现任 Token 的头，再加替换后的文字
            LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
            NewCode := NewCode + Copy(CParser.Source, LastTokenPos + 1,
              TCnWideCppToken(CurTokens[I]).TokenPos - LastTokenPos) + NewName;
          end;
  {$IFDEF DEBUG}
          CnDebugger.LogMsg('Cpp Another NewCode: ' + NewCode);
  {$ENDIF}
          LastToken := TCnWideCppToken(CurTokens[I]);   // 记录上一个处理过的 CurToken
          EndCurToken := TCnWideCppToken(CurTokens[I]); // 记录最后一个 CurToken
        end;

        if StartCurToken <> nil then
        begin
          // 要处理的是 UTF8 的长度，而 Paser 算出的 TokenPos 是 Unicode 的因此需要转换
          EditWriter.CopyTo(Length(UTF8Encode(Copy(CParser.Source, 1, StartCurToken.TokenPos))));
        end;

        if EndCurToken <> nil then
        begin
          // 要处理的是 UTF8 的长度，而 Paser 算出的 TokenPos 是 Unicode 的因此需要转换
          EditWriter.DeleteTo(Length(UTF8Encode(Copy(CParser.Source, 1,
            EndCurToken.TokenPos + Length(EndCurToken.Token)))));
        end;

{$IFDEF UNICODE}
        EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(NewCode)));
{$ELSE}
        EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(NewCode)));
{$ENDIF}

        // 恢复此 View 的 Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);
      end;
    finally
      FreeAndNil(CurTokens);
      FreeAndNil(CParser);
      FreeAndNil(BookMarkList);
    end;
  end;

  Handled := True;
end;

{$ENDIF}

{$HINTS ON}

function TCnSrcEditorKey.DoSearchAgain(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Block: IOTAEditBlock;
  Position: IOTAEditPosition;
  Len: Integer;
  Found: Boolean;
  SearchString: string;
  Bar: TStatusBar;
  ARow, ACol: Integer;
  EditPos: TOTAEditPos;
  EditControl: TControl;
  LineFlag, Element: Integer;
begin
  Result := False;
  if Key <> VK_F3 then Exit;
  if View.Buffer = nil then Exit;

  Position := View.Buffer.EditPosition;
  if Position = nil then Exit;

  Bar := GetStatusBarFromEditor(GetCurrentEditControl);
  if Bar <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogBoolean(Bar.SimplePanel, 'F3 Search: Found Editor StatusBar. Check its SimplePanel.');
{$ENDIF}
    // 状态栏的 SimplePanel 为 True 时表明在进行 Ctrl + E 操作，应该回避
    if Bar.SimplePanel then
      Exit;
  end;

  Block := View.Block;

  // 无论是未选中、选中还是查找匹配时选中，Block 都不为 nil
  // 而只有选中时 IsValid 为 True，其余未选中、查找匹配选中两情况 IsValid 都是 False
  // 因此光判断 Block 及其属性无法区分当前是未选中还是查找匹配选中，需要通过
  // EditorAttribute 来处理区分
  if (Block = nil) or not Block.IsValid then
  begin
    // 无查找或查找匹配选中，需要区分
    EditControl := CnOtaGetCurrentEditControl;
    EditPos := View.CursorPos;
    if EditPos.Col > 1 then
      Dec(EditPos.Col);
    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

    // 如果是 IDE 在查找中（已匹配），则退出让 IDE 自行处理
    if Element = SearchMatch then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Do NOT Search for Element already in SearchMatch');
{$ENDIF}
      Exit;
    end;

    // 开始进行未选择时的查找处理。
    // 当 KeepSearch 为 True 时，需要进行查找上一次 F3 查找的内容，而不是 IDE 中查找的内容

    // 无块时，如不记忆 IDE 的查找，则退出，让 IDE 去执行查找下一个
    if not FKeepSearch then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Do NOT Search for not KeepSearch');
{$ENDIF}
      Exit;
    end;

    // 无选择块并且在 KeepSearch 情况下，使用上次 F3 查找的内容。
    // 已通过挂接实现了记录 IDE 查找对话框中的字符串到 FOldSearchText 中

    // 先使用 FOldSearchText，是因为 Position.SearchOptions.SearchText 可能还是旧值
    SearchString := '';
    if FOldSearchText <> '' then
      SearchString := FOldSearchText;

    if Trim(SearchString) = '' then
      SearchString := Position.SearchOptions.SearchText;

    if Trim(SearchString) = '' then
    begin
      {$IFDEF DEBUG}
         CnDebugger.LogMsg('F3 Pressed, SearchString is Empty, Exit.');
      {$ENDIF}
      Exit;
    end;
  end
  else if Block.StartingRow <> Block.EndingRow then // 选多行时不查找
    Exit
  else // 有单行块时查选中的块内容
    SearchString := Block.Text;

{$IFDEF UNICODE}
  // Unicode 环境下，位移是 Utf8 的长度
  Len := CalcUtf8LengthFromWideString(PChar(SearchString));
{$ELSE}
  Len := Length(SearchString);
{$ENDIF}
  if Len = 0 then Exit;

  ARow := Position.GetRow;
  ACol := Position.GetColumn;
  Position.SearchOptions.SearchText := SearchString;

  Position.SearchOptions.CaseSensitive := FCaseSense;
  Position.SearchOptions.WordBoundary := FWholeWords;
  Position.SearchOptions.RegularExpression := FRegExp;
  Position.SearchOptions.WholeFile := True;
  Position.SearchOptions.FromCursor := True; // 补上这两句以弥补 SearchAgain 失败的问题
{$IFDEF DEBUG}
  CnDebugger.LogFmt('F3 Search: Set Options: Case %d, Word %d, Reg %d.',
    [Integer(FCaseSense), Integer(FWholeWords), Integer(FRegExp)]);
  CnDebugger.LogMsg('F3 Search: ' + SearchString);
{$ENDIF}

  Found := False;
  FOldSearchText := Position.SearchOptions.SearchText;

  if Shift = [] then
  begin
    Position.SearchOptions.Direction := sdForward;
    Found := Position.SearchAgain; // 这句经常返回 False，原因未知
{$IFDEF DEBUG}
    CnDebugger.LogBoolean(Found, 'F3 Search Forward. Found Value?');
{$ENDIF}

    if not Found and FSearchWrap then // 是否回绕查找
    begin
      Found := Position.Move(1, 1); // 复用 Found 变量
      if not Found then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogBoolean(Found, 'F3 Search Forward. Move to BOF?');
{$ENDIF}
        Exit;
      end;

      Found := Position.SearchAgain; // 这句经常返回 False，原因未知
{$IFDEF DEBUG}
      CnDebugger.LogBoolean(Found, 'F3 Search Forward Found Value after Move to BOF?');
{$ENDIF}

      if not Found then
      begin
        Position.Move(ARow, ACol);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('F3 Search Forward NOT Found Anything. Return to Old Place.');
{$ENDIF}
      end;
    end;
  end
  else if Shift = [ssShift] then
  begin
    Position.SearchOptions.Direction := sdBackward;
    Found := Position.SearchAgain; // 这句经常返回 False，原因未知
{$IFDEF DEBUG}
    CnDebugger.LogBoolean(Found, 'F3 Search Backward. Found Value?');
{$ENDIF}
    if not Found and FSearchWrap then // 是否回绕查找
    begin
      Found := Position.MoveEOF;
      if not Found then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogBoolean(Found, 'F3 Search Backward. Move to EOF?');
{$ENDIF}
        Exit;
      end;

      Found := Position.SearchAgain; // 这句经常返回 False，原因未知
{$IFDEF DEBUG}
      CnDebugger.LogBoolean(Found, 'F3 Search Backword Found Value after Move to EOF?');
{$ENDIF}
      if not Found then
      begin
        Position.Move(ARow, ACol);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('F3 Search Backward NOT Found Anything. Return to Old Place.');
{$ENDIF}
      end;
    end;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogBoolean(Found, 'F3 Search Found Value at Last?');
{$ENDIF}

  if Found then
  begin
    if Position.SearchOptions.Direction = sdForward then
    begin
      Position.MoveRelative(0, - Len);
      Block.ExtendRelative(0, Len);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('F3 Search Move Left %d and Select to Right %d.', [Len, Len]);
{$ENDIF}
    end
    else
    begin
      Position.MoveRelative(0, Len);
      Block.ExtendRelative(0, - Len);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('F3 Search Move Right %d and Select to Left %d.', [Len, Len]);
{$ENDIF}
    end;
  end;

  View.Paint;

  Result := True;
  Handled := True;
end;

procedure TCnSrcEditorKey.EditControlSysKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
var
  Nav: TCnSrcEditorNav;
  B: Boolean;
begin
  if Active and (FNavMgrRef <> nil) and FNavMgrRef.Active and (CnOtaGetTopMostEditView <> nil)
    and (Shift = []) and ((Key = VK_LEFT) or (Key = VK_RIGHT)) then // Alt won't in Shift
  begin
    Nav := FNavMgrRef.GetMainNavigatorOrFromEditControl(GetCurrentEditControl);
    if Nav <> nil then
    begin
      Nav.AllowAlt := True;
      try
        if Key = VK_LEFT then
          B := Nav.BackAction.Execute
        else
          B := Nav.ForwardAction.Execute;
      finally
        Nav.AllowAlt := False;
      end;

      if B then
        Handled := True;
    end;
  end;
end;

procedure TCnSrcEditorKey.EditControlKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
var
  View: IOTAEditView;
begin
  if Active then
  begin
    View := CnOtaGetTopMostEditView;
    if not Assigned(View) then
      Exit;

    if FAutoBracket and DoAutoMatchEnter(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FSmartCopy or FSmartPaste then
      if DoSmartCopy(View, Key, ScanCode, Shift, Handled) then
        Exit;

  {$IFNDEF DELPHI10_UP} // 2006 已经有了自动缩进和 end 自动输入
    // 判断自动缩进要在 ShiftEnter 之前
    if (FAutoIndent or FAutoEnterEnd) and DoAutoIndent(View, Key, ScanCode, Shift, Handled) then
      Exit;
  {$ENDIF}

    if FShiftEnter and DoShiftEnter(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FF3Search and DoSearchAgain(View, Key, ScanCode, Shift, Handled) then
      Exit;

{$IFDEF IDE_WIDECONTROL}
    if FF2Rename and DoRenameW(View, Key, ScanCode, Shift, Handled) then
      Exit;
{$ELSE}
    if FF2Rename and DoRename(View, Key, ScanCode, Shift, Handled) then
      Exit;
{$ENDIF}

    if FHomeExt and DoHomeExtend(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if (FLeftLineWrap or FRightLineWrap) and DoLeftRightLineWrap(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FSemicolonLastChar and DoSemicolonLastChar(View, Key, ScanCode, Shift, Handled) then
      Exit;
  end;
end;

procedure TCnSrcEditorKey.EditControlKeyUp(Key, ScanCode: Word; Shift: TShiftState;
  var Handled: Boolean);
begin
  if Active and FAutoBracket then
  begin
    // TODO: 如果有事干的话
  end;
end;

procedure TCnSrcEditorKey.ExecuteInsertCharOnIdle(Sender: TObject);
begin
  if (FAutoMatchType = btNone) or (FRepaintView = 0) then
    Exit;

  case FAutoMatchType of
    btBracket: CnOtaInsertTextToCurSource(')');
    btSquare:  CnOtaInsertTextToCurSource(']');
    btCurly:   CnOtaInsertTextToCurSource('}');
    btQuote:   CnOtaInsertTextToCurSource('''');
    btDitto:   CnOtaInsertTextToCurSource('"');
  end;

  CnOtaMovePosInCurSource(ipCur, 0, -1);
  IOTAEditView(FRepaintView).Paint;
end;

//------------------------------------------------------------------------------
// 参数设置
//------------------------------------------------------------------------------

const
  csEditorKey = 'EditorKey';
  csSmartCopy = 'SmartCopy';
  csSmartPaste = 'SmartPaste';
  csPasteReplace = 'PasteReplace';
  csShiftEnter = 'ShiftEnter';
  csF3Search = 'F3Search';
  csF2Rename = 'F2Rename';
  csRenameShortCut = 'RenameShortCut';
  csKeepSearch = 'KeepSearch';
  csSearchWrap = 'SearchWrap';
  csAutoIndent = 'AutoIndent';
  csHomeExt = 'HomeExt';
  csHomeFirstChar = 'HomeFirstChar';
  csCursorBeforeEOL = 'CursorBeforeEOL';
  csLeftLineWrap = 'LeftLineWrap';
  csRightLineWrap = 'RightLineWrap';
  csAutoBracket = 'AutoBracket';
  csSemicolonLastChar = 'SemicolonLastChar';
  csAutoEnterEnd = 'AutoEnterEnd';

procedure TCnSrcEditorKey.LoadSettings(Ini: TCustomIniFile);
var
  Wizard: TCnSrcEditorEnhance;
begin
  // 不能在 Create 的时候找，TCnSrcEditorEnhance 刚创建还没赋值
  Wizard := TCnSrcEditorEnhance(CnWizardMgr.WizardByClass(TCnSrcEditorEnhance));
  if Wizard <> nil then
    FNavMgrRef := Wizard.NavMgr;

  FSmartCopy := Ini.ReadBool(csEditorKey, csSmartCopy, True);
  FSmartPaste := Ini.ReadBool(csEditorKey, csSmartPaste, False); // 粘贴时自动对齐默认不启用
  FPasteReplace := Ini.ReadBool(csEditorKey, csPasteReplace, False);
  FShiftEnter := Ini.ReadBool(csEditorKey, csShiftEnter, True);
  FAutoIndent := Ini.ReadBool(csEditorKey, csAutoIndent, True);
  FF3Search := Ini.ReadBool(csEditorKey, csF3Search, True);
  FF2Rename := Ini.ReadBool(csEditorKey, csF2Rename, True);
  RenameShortCut := Ini.ReadInteger(csEditorKey, csRenameShortCut, TextToShortCut('F2'));
  KeepSearch := Ini.ReadBool(csEditorKey, csKeepSearch, True);
  SearchWrap := Ini.ReadBool(csEditorKey, csSearchWrap, True);
  FHomeExt := Ini.ReadBool(csEditorKey, csHomeExt, True);
  FHomeFirstChar := Ini.ReadBool(csEditorKey, csHomeFirstChar, False);
  FCursorBeforeEOL := Ini.ReadBool(csEditorKey, csCursorBeforeEOL, False);
  FLeftLineWrap := Ini.ReadBool(csEditorKey, csLeftLineWrap, False);
  FRightLineWrap := Ini.ReadBool(csEditorKey, csRightLineWrap, False);
  FAutoBracket := Ini.ReadBool(csEditorKey, csAutoBracket, False);
  FSemicolonLastChar := Ini.ReadBool(csEditorKey, csSemicolonLastChar, False);
  FAutoEnterEnd := Ini.ReadBool(csEditorKey, csAutoEnterEnd, True);
  WizOptions.LoadUserFile(FAutoIndentList, SCnAutoIndentFile);
end;

procedure TCnSrcEditorKey.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csEditorKey, csSmartCopy, FSmartCopy);
  Ini.WriteBool(csEditorKey, csSmartPaste, FSmartPaste);
  Ini.WriteBool(csEditorKey, csPasteReplace, FPasteReplace);
  Ini.WriteBool(csEditorKey, csShiftEnter, FShiftEnter);
  Ini.WriteBool(csEditorKey, csF3Search, FF3Search);
  Ini.WriteBool(csEditorKey, csF2Rename, FF2Rename);
  Ini.WriteInteger(csEditorKey, csRenameShortCut, FRenameShortCut);
  Ini.WriteBool(csEditorKey, csKeepSearch, FKeepSearch);
  Ini.WriteBool(csEditorKey, csSearchWrap, FSearchWrap);
  Ini.WriteBool(csEditorKey, csAutoIndent, FAutoIndent);
  Ini.WriteBool(csEditorKey, csHomeExt, FHomeExt);
  Ini.WriteBool(csEditorKey, csHomeFirstChar, FHomeFirstChar);
  Ini.WriteBool(csEditorKey, csCursorBeforeEOL, FCursorBeforeEOL);
  Ini.WriteBool(csEditorKey, csLeftLineWrap, FLeftLineWrap);
  Ini.WriteBool(csEditorKey, csRightLineWrap, FRightLineWrap);
  Ini.WriteBool(csEditorKey, csAutoBracket, FAutoBracket);
  Ini.WriteBool(csEditorKey, csSemicolonLastChar, FSemicolonLastChar);
  Ini.WriteBool(csEditorKey, csAutoEnterEnd, FAutoEnterEnd);
  WizOptions.SaveUserFile(FAutoIndentList, SCnAutoIndentFile);
end;

procedure TCnSrcEditorKey.ResetSettings(Ini: TCustomIniFile);
begin
  WizOptions.CleanUserFile(SCnAutoIndentFile);
end;

procedure TCnSrcEditorKey.DoEnhConfig;
begin
  if Assigned(FOnEnhConfig) then
    FOnEnhConfig(Self);
end;

procedure TCnSrcEditorKey.LanguageChanged(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
// 属性读写
//------------------------------------------------------------------------------

procedure TCnSrcEditorKey.SetActive(Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
  end;
end;

procedure TCnSrcEditorKey.SetRenameShortCut(const Value: TShortCut);
begin
  FRenameShortCut := Value;
  ShortCutToKey(Value, FRenameKey, FRenameShift);
end;

procedure TCnSrcEditorKey.SetKeepSearch(const Value: Boolean);
begin
  FKeepSearch := Value;
end;

procedure TCnSrcEditorKey.EditorChanged(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
begin
  if not Active or not FCursorBeforeEOL then
    Exit;

  if ((ctCurrLine in ChangeType) or (ctCurrCol in ChangeType)) then
    SnapCursorToEol;
end;

{$IFDEF DELPHI104_SYDNEY_UP}

procedure TCnSrcEditorKey.EditorMouseUp(Editor: TCnEditorObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
begin
  if not Active or not FCursorBeforeEOL then
    Exit;

  SnapCursorToEol;
end;

{$ENDIF}

procedure TCnSrcEditorKey.SnapCursorToEol;
var
  Line: string;
  EditView: IOTAEditView;
  LineNo, CharIndex, Len: Integer;
begin
  if FCursorMoving then
    Exit;

  // 获得当前编辑器光标位置，并判断是否超出行尾
  if CnNtaGetCurrLineText(Line, LineNo, CharIndex) then
  begin
    // 空行也强迫到行首
//    if Trim(Line) = '' then
//      Exit;

    // Line 分别是 Ansi/Utf8/Utf16
{$IFDEF UNICODE}
    Len := CalcAnsiDisplayLengthFromWideString(PWideChar(Line));
{$ELSE}
    Len := Length(Line);
{$ENDIF}

    EditView := CnOtaGetTopMostEditView;
    CharIndex := EditView.CursorPos.Col - 1;  // 分别是 Ansi/Utf8/Ansi
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Cursor Before EOL: Col %d, Len %d.', [CharIndex, Len]);
{$ENDIF}
    if CharIndex > Len then
    begin
      try
        FCursorMoving := True;
        EditView.Buffer.EditPosition.MoveEOL;
        EditView.Paint;
      finally
        FCursorMoving := False;
      end;
    end;
  end;
end;

function TCnSrcEditorKey.IsValidRenameIdent(const Ident: string): Boolean;
const
  Alpha = ['A'..'Z', 'a'..'z', '_'];
  AlphaNumeric = Alpha + ['0'..'9', '.'];
var
  I: Integer;
begin
  Result := False;
{$IFDEF UNICODE} // Unicode Identifier Supports
  if (Length(Ident) = 0) or not (CharInSet(Ident[1], Alpha) or (Ord(Ident[1]) > 127)) then
    Exit;
  for I := 2 to Length(Ident) do
  begin
    if not (CharInSet(Ident[I], AlphaNumeric) or (Ord(Ident[I]) > 127)) then
      Exit;
  end;
{$ELSE}
  if (Length(Ident) = 0) or not CharInSet(Ident[1], Alpha) then
    Exit;
  for I := 2 to Length(Ident) do
  begin
    if not CharInSet(Ident[I], AlphaNumeric) then
      Exit;
  end;
{$ENDIF}
  Result := True;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.

