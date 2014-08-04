{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2014 CnPack ������                       }
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
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnInputHelper;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ���������ר�Ҵ���
* ��Ԫ���ߣ�Johnson Zhong zhongs@tom.com http://www.longator.com
*           �ܾ��� zjy@cnpack.org
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 7.1
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2004.11.05
*               ��ֲ����
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINPUTHELPER}

{$DEFINE SUPPORT_INPUTHELPER}

//{$IFDEF DELPHI}
  {$DEFINE SUPPORT_IDESymbolList}
//{$ENDIF}

{$IFDEF BDS}
  {$DEFINE ADJUST_CodeParamWindow}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, ImgList, Menus, ToolsApi, IniFiles, Math,
  Buttons, TypInfo, mPasLex, AppEvnts,
  CnConsts, CnCommon, CnWizClasses, CnWizConsts, CnWizUtils, CnWizIdeUtils,
  CnInputSymbolList, CnInputIdeSymbolList, CnIni, CnWizMultiLang, CnWizNotifier,
  CnPasCodeParser, CnWizShareImages, CnWizShortCut, CnWizOptions,
  CnEditControlWrapper, CnWizMethodHook, CnCppCodeParser, CnPopupMenu;

const
  csMinDispDelay = 50;
  csDefDispDelay = 250;
  csDefCompleteChars = '%&,;()[]<>=';
  csDefFilterSymbols = '//,{';
  csDefAutoSymbols = '" := "," <> "," = "," > "," >= "," < "," <= "';

type
  TCnInputHelper = class;

{ TCnInputExtraForm }

  TCnInputExtraForm = class(TCustomControl)
  private
    FOnPaint: TNotifyEvent;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Paint; override;
  public
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

{ TCnInputListBox }

  TCnInputButton = (ibAddSymbol, ibConfig, ibHelp);

  TCnItemHintEvent = procedure (Sender: TObject; Index: Integer;
    var HintStr: string) of object;

  TBtnClickEvent = procedure (Sender: TObject; Button: TCnInputButton) of object;

  TCnInputListBox = class(TCustomListBox)
  private
    FLastItem: Integer;
    FOnItemHint: TCnItemHintEvent;
    FOnButtonClick: TBtnClickEvent;
    FBtnForm: TCnInputExtraForm;
    FHintForm: TCnInputExtraForm;
    FHintCnt: Integer;
    FHintTimer: TTimer;
    FDispButtons: Boolean;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
    procedure CNCancelMode(var Message: TMessage); message CM_CANCELMODE;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure WMSize(var Message: TMessage); message WM_SIZE;
    procedure WMMove(var Message: TMessage); message WM_MOVE;
    function AdjustHeight(AHeight: Integer): Integer;
    procedure CreateExtraForm;
    procedure UpdateExtraForm;
    procedure UpdateExtraFormLang;
    procedure OnBtnClick(Sender: TObject);
    procedure OnHintPaint(Sender: TObject);
    procedure OnHintTimer(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetCount(const Value: Integer);
    procedure SetPos(X, Y: Integer);
    procedure CloseUp;
    procedure Popup;
    property DispButtons: Boolean read FDispButtons write FDispButtons;
    property BtnForm: TCnInputExtraForm read FBtnForm;
    property HintForm: TCnInputExtraForm read FHintForm;
    property OnItemHint: TCnItemHintEvent read FOnItemHint write FOnItemHint;
    property OnButtonClick: TBtnClickEvent read FOnButtonClick write FOnButtonClick;
  end;

{ TCnSymbolScopeMgr }

  PSymbolHitCountItem = ^TSymbolHitCountItem;
  TSymbolHitCountItem = packed record
    HashCode: Cardinal;
    TimeStamp: TDateTime;
    HitCount: Integer;
  end;

  TCnSymbolHitCountMgr = class(TObject)
  private
    FList: TList;
    FFileName: string;
    function GetCount: Integer;
    function GetItems(Index: Integer): PSymbolHitCountItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function GetHitCount(AHashCode: Cardinal): Integer;
    procedure IncHitCount(AHashCode: Cardinal);
    procedure DecAllHitCount(TimeStamp: TDateTime);
    procedure LoadFromFile(FileName: string = '');
    procedure SaveToFile(FileName: string = '');
    property Count: Integer read GetCount;
    property Items[Index: Integer]: PSymbolHitCountItem read GetItems; default;
  end;

{ TCnSymbolHashList }

  PSymbolItemArray = ^TSymbolItemArray;
  TSymbolItemArray = array[0..65535] of TSymbolItem;
  
  TCnSymbolHashList = class(TObject)
  private
    FCount: Integer;
    FList: PSymbolItemArray;
  public
    constructor Create(ACount: Integer);
    destructor Destroy; override;
    function CheckExist(AItem: TSymbolItem): Boolean;
  end;

{ TCnInputHelper }

  // �б�����ʽ
  TCnSortKind = (skByScope, skByText, skByLength, skByKind);
  // �����ʶ��ʱ���������м�λ�õĴ�����
  TCnOutputStyle = (osAuto, osReplaceLeft, osReplaceAll, osEnterAll);

  TCnInputHelper = class(TCnActionWizard)
  private
    List: TCnInputListBox;
    Timer: TTimer;
    AppEvents: TApplicationEvents;
    Menu: TPopupMenu;
    AutoMenuItem: TMenuItem;
    DispBtnMenuItem: TMenuItem;
    SortMenuItem: TMenuItem;
    IconMenuItem: TMenuItem;
    FHitCountMgr: TCnSymbolHitCountMgr;
    FSymbolListMgr: TSymbolListMgr;
    FirstSet: TAnsiCharSet;
    CharSet: TAnsiCharSet;

    FAutoPopup: Boolean;
    FToken: string;
    FMatchStr: string;
    FLastStr: string;
    FSymbols: TStringList;
    FItems: TStringList;
    FKeyCount: Integer;
    FKeyQueue: string;
    FCurrLineText: string;
    FCurrLineNo: Integer;
    FCurrIndex: Integer;
    FCurrLineLen: Integer;
    FKeyDownTick: Cardinal;
    FKeyDownValid: Boolean;
    FNeedUpdate: Boolean;
    FPosInfo: TCodePosInfo;
    FSavePos: TOTAEditPos;
    FBracketText: string;
    FNoActualParaminCpp: Boolean;
    FPopupShortCut: TCnWizShortCut;
    FListOnlyAtLeastLetter: Integer;
    FDispOnlyAtLeastKey: Integer;
    FSortKind: TCnSortKind;
    FDispDelay: Cardinal;
    FMatchAnyWhere: Boolean;
    FCompleteChars: string;
    FFilterSymbols: TStrings;
    FAutoSymbols: TStrings;
    FEnableAutoSymbols: Boolean;
    FAutoInsertEnter: Boolean;
    FAutoCompParam: Boolean;
    FSmartDisplay: Boolean;
    FSelMidMatchByEnterOnly: Boolean;
    FCheckImmRun: Boolean;
    FOutputStyle: TCnOutputStyle;
    FDispOnIDECompDisabled: Boolean;
    FSpcComplete: Boolean;
    FIgnoreSpc: Boolean;
    FAutoAdjustScope: Boolean;
    FDispKindSet: TSymbolKindSet;
    FRemoveSame: Boolean;
    FKeywordStyle: TCnKeywordStyle;
{$IFNDEF SUPPORT_IDESymbolList}
    // �����֧�� IDE �����б���Ҫ�ҵ� Cppcodcmplt::TCppKibitzManager::CCError
    FCCErrorHook: TCnMethodHook;
{$ENDIF}
{$IFDEF ADJUST_CodeParamWindow}
    FCodeWndProc: TWndMethod;
{$ENDIF}
    function AcceptDisplay: Boolean;
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure ActiveControlChanged(Sender: TObject);
    procedure OnTimer(Sender: TObject);
    procedure OnAppDeactivate(Sender: TObject);
    function GetIsShowing: Boolean;
    function ParsePosInfo: Boolean;
    procedure ShowList(ForcePopup: Boolean);
    procedure HideList;
    procedure ClearList;
    procedure HideAndClearList;
{$IFDEF ADJUST_CodeParamWindow}
    procedure CodeParamWndProc(var Message: TMessage);
    procedure HookCodeParamWindow(Wnd: TWinControl);
    procedure AdjustCodeParamWindowPos;
{$ENDIF}
    function HandleKeyDown(var Msg: TMsg): Boolean;
    function HandleKeyUp(var Msg: TMsg): Boolean;
    function HandleKeyPress(Key: AnsiChar): Boolean;
    procedure SortSymbolList;
    procedure SortCurrSymbolList;
    function UpdateCurrList(ForcePopup: Boolean): Boolean;
    function UpdateListBox(ForcePopup, InitPopup: Boolean): Boolean;
    procedure UpdateSymbolList;
    procedure ListDblClick(Sender: TObject);
    procedure ListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure ListItemHint(Sender: TObject; Index: Integer; var HintStr: string);
    procedure PopupKeyProc(Sender: TObject);
    procedure OnPopupMenu(Sender: TObject);
    procedure CreateMenuItem;
    procedure SetAutoPopup(Value: Boolean);
    procedure OnDispBtnMenu(Sender: TObject);
    procedure OnConfigMenu(Sender: TObject);
    procedure OnAddSymbolMenu(Sender: TObject);
    procedure OnSortKindMenu(Sender: TObject);
    procedure OnIconMenu(Sender: TObject);
    procedure OnBtnClick(Sender: TObject; Button: TCnInputButton);
    function CurrBlockIsEmpty: Boolean;
    function IsValidSymbolChar(C: Char; First: Boolean): Boolean; 
    function IsValidSymbol(Symbol: string): Boolean;
    function IsValidCharKey(VKey: Word; ScanCode: Word): Boolean;
    function IsValidDelelteKey(Key: Word): Boolean;
    function IsValidDotKey(Key: Word): Boolean;
    function IsValidCppArrowKey(VKey: Word; Code: Word): Boolean;
    function IsValidKeyQueue: Boolean;
    function CalcFirstSet(IsPascal: Boolean): TAnsiCharSet;
    procedure AutoCompFunc(Sender: TObject);
    function GetListFont: TFont;
    procedure ConfigChanged;
    function GetPopupKey: TShortCut;
    procedure SetPopupKey(const Value: TShortCut);
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
    procedure Click(Sender: TObject); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure OnActionUpdate(Sender: TObject); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    procedure Loaded; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure LanguageChanged(Sender: TObject); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure SendSymbolToIDE(MatchFirstOnly, AutoEnter, RepFullToken: Boolean;
      Key: AnsiChar; var Handled: Boolean);
    procedure ShowIDECodeCompletion;
    procedure DebugComand(Cmds: TStrings; Results: TStrings); override;

    property IsShowing: Boolean read GetIsShowing;
    property ListFont: TFont read GetListFont;
    property HitCountMgr: TCnSymbolHitCountMgr read FHitCountMgr;
    property SymbolListMgr: TSymbolListMgr read FSymbolListMgr;
  
    property AutoPopup: Boolean read FAutoPopup write SetAutoPopup default True;
    {* �Ƿ��Զ�������������}
    property PopupKey: TShortCut read GetPopupKey write SetPopupKey;
    {* �Զ�������ݼ�}
    property ListOnlyAtLeastLetter: Integer read FListOnlyAtLeastLetter write
      FListOnlyAtLeastLetter default 1;
    {* ��ʾ�ڷ����б��е���С���ų���}
    property DispOnlyAtLeastKey: Integer read FDispOnlyAtLeastKey write
      FDispOnlyAtLeastKey default 2;
    {* �����б�ʱ��Ҫ�����������Ч������}
    property DispKindSet: TSymbolKindSet read FDispKindSet write FDispKindSet;
    {* ������ʾ�ķ�������}
    property SortKind: TCnSortKind read FSortKind write FSortKind default skByScope;
    {* �б���������}
    property MatchAnyWhere: Boolean read FMatchAnyWhere write FMatchAnyWhere
      default True;
    {* ƥ���ʶ���м䲿��}
    property DispDelay: Cardinal read FDispDelay write FDispDelay default csDefDispDelay;
    {* �б�����ʱms��}
    property DispOnIDECompDisabled: Boolean read FDispOnIDECompDisabled write
      FDispOnIDECompDisabled default True;
    {* ������ IDE ���Զ����ʱ���Զ������� .�ź󵯳�}
    property AutoAdjustScope: Boolean read FAutoAdjustScope write FAutoAdjustScope
      default True;
    {* �Զ�������ʾ���ȼ� }
    property RemoveSame: Boolean read FRemoveSame write FRemoveSame;
    {* ֻ��ʾΨһ�ķ��ţ������ظ����ֵ���Ŀ }
    property CompleteChars: string read FCompleteChars write FCompleteChars;
    {* ��������ɵ�ǰ��ѡ����ַ��б�}
    property FilterSymbols: TStrings read FFilterSymbols;
    {* ��ֹ�Զ������б�ķ���}
    property EnableAutoSymbols: Boolean read FEnableAutoSymbols write FEnableAutoSymbols default False;
    property AutoSymbols: TStrings read FAutoSymbols;
    {* �Զ������б�ķ��� }
    property SpcComplete: Boolean read FSpcComplete write FSpcComplete default True;
    {* �ո��Ƿ���������ѡ�� }
    property IgnoreSpc: Boolean read FIgnoreSpc write FIgnoreSpc default False;
    {* �ո����ѡ��ʱ���ո������Ƿ���ԣ�Ĭ�ϲ�����}
    property AutoInsertEnter: Boolean read FAutoInsertEnter write FAutoInsertEnter
      default True;
    {* ����ؼ��ֺ󰴻س��Ƿ��Զ����� }
    property AutoCompParam: Boolean read FAutoCompParam write FAutoCompParam;
    {* �Ƿ��Զ���ɺ������� }
    property SmartDisplay: Boolean read FSmartDisplay write FSmartDisplay default
      True;
    {* ������ʾ�б������ǰ��ʶ�����б��е�����ȫƥ������ʾ}
    property KeywordStyle: TCnKeywordStyle read FKeywordStyle write FKeywordStyle
      default ksDefault;
    {* �ؼ�����ʾ��� }
    property OutputStyle: TCnOutputStyle read FOutputStyle write FOutputStyle
      default osAuto;
    {* ���������ʶ���������ǰ����ڱ�ʶ���м䣬�����ж����滻���֮ǰ�����ݻ���������ʶ��}
    property SelMidMatchByEnterOnly: Boolean read FSelMidMatchByEnterOnly
      write FSelMidMatchByEnterOnly default True;
    {* ֻʹ�ûس�����ѡ���Ǵ�ͷ��ʼƥ����ı�}
    property CheckImmRun: Boolean read FCheckImmRun write FCheckImmRun default False;
    {* ���ϵͳ���뷨����ʱ���Զ�����ר��}
  end;

const
  csSortKindTexts: array[TCnSortKind] of PString = (
    @SCnInputHelperSortByScope, @SCnInputHelperSortByText,
    @SCnInputHelperSortByLength, @SCnInputHelperSortByKind);

{$ENDIF CNWIZARDS_CNINPUTHELPER}

implementation

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnInputHelperFrm, CnWizCompilerConst, mwBCBTokenList;

const
  // BCB �³����ĵ�ַ
  SCppKibitzManagerCCError = '@Cppcodcmplt@TCppKibitzManager@CCError$qqrp20System@TResStringRec';

  csLineHeight = 16;
  csMinDispItems = 5;
  csDefDispItems = 6;
  csMinDispWidth = 150;
  csDefDispWidth = 300;

  csMaxProcessLines = 1000;

  csMatchColor = clRed;
  csKeywordColor = clBlue;
  csTypeColor = clNavy;

  csDataFile = 'SymbolHitCount.dat';
  csMaxHitCount = 8;
  csDecHitCountDays = 1;
  csFileFlag = $44332211;
  csVersion = $1000;

  csHashListCount = 32768;
  csHashListInc = 4;

  csKeyQueueLen = 8;

  csWidth = 'Width';
  csHeight = 'Height';
  csFont = 'Font';
  csDispButtons = 'DispButtons';
  csAutoPopup = 'AutoPopup';
  csListOnlyAtLeastLetter = 'ListOnlyAtLeastLetter';
  csDispOnlyAtLeastKey = 'DispOnlyAtLeastKey';
  csDispKindSet = 'DispKindSet';
  csDispDelay = 'DispDelay';
  csSortKind = 'SortKind';
  csMatchAnyWhere = 'MatchAnyWhere';
  csCompleteChars = 'CompleteCharSet';
  csFilterSymbols = 'FilterSymbols';
  csEnableAutoSymbols = 'EnableAutoSymbols';
  csAutoSymbols = 'AutoSymbols';
  csSpcComplete = 'SpcComplete';
  csIgnoreSpc = 'IgnoreSpc';
  csAutoInsertEnter = 'AutoInsertEnter';
  csAutoCompParam = 'AutoCompParam';
  csSmartDisplay = 'SmartDisplay';
  csOutputStyle = 'OutputStyle';
  csKeywordStyle = 'KeywordStyle';
  csSelMidMatchByEnterOnly = 'SelMidMatchByEnterOnly';
  csCheckImmRun = 'CheckImmRun';
  csDispOnIDECompDisabled = 'DispOnIDECompDisabled';
  csUseCodeInsightMgr = 'UseCodeInsightMgr';
  csUseKibitzCompileThread = 'UseKibitzThread';
  csAutoAdjustScope = 'AutoAdjustScope';
  csRemoveSame = 'RemoveSame';
  csListActive = 'ListActive';

{$IFDEF COMPILER6_UP}
  csKibitzWindowClass = 'TCodeCompleteListView';
{$ELSE}
  csKibitzWindowClass = 'TPopupListBox';
{$ENDIF COMPILER6_UP}
  csKibitzWindowName = 'KibitzWindow';

  csKeyCodeCompletion = 'CodeCompletion';

  // ͼ�꼯������
  csAllSymbolKind = [Low(TSymbolKind)..High(TSymbolKind)];
  csNoneSymbolKind = [];
  csCompDirectSymbolKind = [skCompDirect];
  csCommentSymbolKind = [skComment];
  csUnitSymbolKind = [skUnit];
  csDeclearSymbolKind = csAllSymbolKind - [skUnknown, skLabel];
  csDefineSymbolKind = csAllSymbolKind - [skUnknown, skUnit, skLabel];
  csCodeSymbolKind = csAllSymbolKind;
  csFieldSymbolKind = csAllSymbolKind - [skUnknown, skConstant, skType,
    skUnit, skLabel, skInterface, skKeyword, skClass, skUser];

  // BCB �в������� Field���ɴ�͵�ͬ��Code��
  csCppFieldSymbolKind = csAllSymbolKind;

  csPascalSymbolKindTable: array[TCodePosKind] of TSymbolKindSet = (
    csNoneSymbolKind,          // δ֪��Ч��
    csAllSymbolKind,           // ��Ԫ�հ���
    csCommentSymbolKind,       // ע�Ϳ��ڲ�
    csUnitSymbolKind,          // interface �� uses �ڲ�
    csUnitSymbolKind,          // implementation �� uses �ڲ�
    csDeclearSymbolKind,       // class �����ڲ�
    csDeclearSymbolKind,       // interface �����ڲ�
    csDefineSymbolKind,        // type ������
    csDefineSymbolKind,        // const ������
    csDefineSymbolKind,        // resourcestring ������
    csDefineSymbolKind,        // var ������
    csCompDirectSymbolKind,    // ����ָ���ڲ�
    csNoneSymbolKind,          // �ַ����ڲ�
    csFieldSymbolKind,         // ��ʶ��. ��������ڲ������ԡ��������¼�����¼��ȣ�C/C++Դ�ļ��󲿷ֶ��ڴ�
    csCodeSymbolKind,          // �����ڲ�
    csCodeSymbolKind,          // �����ڲ�
    csCodeSymbolKind,          // �������ڲ�
    csCodeSymbolKind,          // �������ڲ�
    csFieldSymbolKind,         // ������ĵ�

    csNoneSymbolKind);         // C ����������

  csCppSymbolKindTable: array[TCodePosKind] of TSymbolKindSet = (
    csNoneSymbolKind,          // δ֪��Ч��
    csAllSymbolKind,           // ��Ԫ�հ���
    csCommentSymbolKind,       // ע�Ϳ��ڲ�
    csUnitSymbolKind,          // interface �� uses �ڲ�
    csUnitSymbolKind,          // implementation �� uses �ڲ�
    csDeclearSymbolKind,       // class �����ڲ�
    csDeclearSymbolKind,       // interface �����ڲ�
    csDefineSymbolKind,        // type ������
    csDefineSymbolKind,        // const ������
    csDefineSymbolKind,        // resourcestring ������
    csDefineSymbolKind,        // var ������
    csCompDirectSymbolKind,    // ����ָ���ڲ�
    csNoneSymbolKind,          // �ַ����ڲ�
    csCppFieldSymbolKind,      // ��ʶ��. ��������ڲ������ԡ��������¼�����¼��ȣ�C/C++Դ�ļ��󲿷ֶ��ڴ�
    csCodeSymbolKind,          // �����ڲ�
    csCodeSymbolKind,          // �����ڲ�
    csCodeSymbolKind,          // �������ڲ�
    csCodeSymbolKind,          // �������ڲ�
    csCppFieldSymbolKind,      // ������ĵ�

    csNoneSymbolKind);         // C ����������

  SCnInputButtonHints: array[TCnInputButton] of PString = (
    @SCnInputHelperAddSymbol, @SCnInputHelperConfig, @SCnInputHelperHelp);

  csExceptKeywords = 'not,and,or,xor,nil,shl,shr,as,is,in,to,mod,div,var,const,' +
    'type,class,string,begin,end';

  csBtnWidth = 16;
  csBtnHeight = 16;
  csHintHeight = 16;

  CS_DROPSHADOW = $20000;

{$IFDEF SUPPORT_UNITNAME_DOT}
  csUnitDotPrefixes: array[0..9] of string = (
    'Vcl', 'Xml', 'System', 'Winapi', 'Soap', 'FMX', 'Data', 'Posix', 'Macapi',
    'DataSnap'
  );
{$ENDIF}

{$IFNDEF SUPPORT_IDESymbolList}

type
  TSCppKibitzManagerCCError = procedure (Rec: PResStringRec); // TResStringRec

procedure MyCCError(Rec: PResStringRec);
begin
  // ɶ������
  Rec := Rec;
end;

{$ENDIF}

//==============================================================================
// �����б��ť����
//==============================================================================

{ TCnInputExtraForm }

procedure TCnInputExtraForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CHILDWINDOW or WS_MAXIMIZEBOX;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;
  if CheckWinXP then
    Params.WindowClass.style := CS_DBLCLKS or CS_DROPSHADOW
  else
    Params.WindowClass.style := CS_DBLCLKS;
end;

procedure TCnInputExtraForm.CreateWnd;
begin
  inherited;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
end;

procedure TCnInputExtraForm.Paint;
begin
  if Assigned(FOnPaint) then
    FOnPaint(Self);
end;

//==============================================================================
// �����б��
//==============================================================================

{ TCnInputListBox }

function TCnInputListBox.AdjustHeight(AHeight: Integer): Integer;
var
  BorderSize: Integer;
begin
  BorderSize := Height - ClientHeight;
  Result := Max((AHeight - BorderSize) div ItemHeight, 4) * ItemHeight + BorderSize;
end;

function TCnInputListBox.CanResize(var NewWidth,
  NewHeight: Integer): Boolean;
begin
  NewHeight := AdjustHeight(NewHeight);
  Result := True;
end;

procedure TCnInputListBox.CloseUp;
begin
  Visible := False;
  UpdateExtraForm;
end;

procedure TCnInputListBox.CMHintShow(var Message: TMessage);
var
  Index: Integer;
  P: TPoint;
  S: string;
begin
  Message.Result := 1;
  if Assigned(FOnItemHint) and GetCursorPos(P) then
  begin
    P := ScreenToClient(P);
    Index := ItemAtPos(P, True);
    if Index >= 0 then
    begin
      FOnItemHint(Self, Index, S);
      if S <> '' then
      begin
        TCMHintShow(Message).HintInfo^.HintStr := S;
        Message.Result := 0;
      end;
    end;
  end;
end;

procedure TCnInputListBox.CNCancelMode(var Message: TMessage);
begin
  CloseUp;
end;

procedure TCnInputListBox.CNDrawItem(var Message: TWMDrawItem);
var
  State: TOwnerDrawState;
begin
  with Message.DrawItemStruct^ do
  begin
    State := TOwnerDrawState(LongRec(itemState).Lo);
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    Canvas.Brush := Brush;
    if (Integer(itemID) >= 0) and (odSelected in State) then
    begin
      Canvas.Brush.Color := clHighlight;
      Canvas.Font.Color := clHighlightText
    end;
    if Integer(itemID) >= 0 then
    begin
      if Assigned(OnDrawItem) then
        OnDrawItem(Self, itemID, rcItem, State);
    end
    else
      Canvas.FillRect(rcItem);
    Canvas.Handle := 0;
  end;
end;

procedure TCnInputListBox.CNMeasureItem(var Message: TWMMeasureItem);
begin
  with Message.MeasureItemStruct^ do
  begin
    itemHeight := Self.ItemHeight;
  end;
end;

constructor TCnInputListBox.Create(AOwner: TComponent);
begin
  inherited;
  Visible := False;
  Style := lbOwnerDrawFixed;
  DoubleBuffered := True;
  Constraints.MinHeight := ItemHeight * csMinDispItems + 4;
  Constraints.MinWidth := csMinDispWidth;
  Height := ItemHeight * csDefDispItems + 8;
  Width := csDefDispWidth;
  ShowHint := True;
  Font.Name := 'Tahoma';
  Font.Size := 8;
  FLastItem := -1;
  CreateExtraForm;
end;

procedure TCnInputListBox.CreateExtraForm;
var
  Btn: TCnInputButton;
  SpeedBtn: TSpeedButton;
begin
  FBtnForm := TCnInputExtraForm.Create(Self);
  BtnForm.Parent := Application.MainForm;
  BtnForm.Visible := False;
  BtnForm.Width := csBtnWidth;
  BtnForm.Height := csBtnHeight * (Ord(High(TCnInputButton)) + 1);
  for Btn := Low(Btn) to High(Btn) do
  begin
    SpeedBtn := TSpeedButton.Create(BtnForm);
    SpeedBtn.Parent := BtnForm;
    SpeedBtn.SetBounds(0, Ord(Btn) * csBtnHeight, csBtnWidth, csBtnHeight);
    SpeedBtn.Tag := Ord(Btn);
    SpeedBtn.ShowHint := True;
    SpeedBtn.Hint := StripHotkey(SCnInputButtonHints[Btn]^);
    SpeedBtn.OnClick := OnBtnClick;
    dmCnSharedImages.ilInputHelper.GetBitmap(Ord(Btn), SpeedBtn.Glyph);
  end;

  FHintForm := TCnInputExtraForm.Create(Self);
  HintForm.Parent := Application.MainForm;
  HintForm.Visible := False;
  HintForm.Width := Width;
  HintForm.Height := csHintHeight;
  HintForm.OnPaint := OnHintPaint;
  
  FHintTimer := TTimer.Create(Self);
  FHintTimer.Enabled := False;
  FHintTimer.Interval := 600;
  FHintTimer.OnTimer := OnHintTimer;
end;

procedure TCnInputListBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := (Params.Style or WS_CHILDWINDOW or WS_SIZEBOX or WS_MAXIMIZEBOX
    or LBS_NODATA or LBS_OWNERDRAWFIXED) and not (LBS_SORT or LBS_HASSTRINGS);
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;
  if CheckWinXP then
    Params.WindowClass.style := CS_DBLCLKS or CS_DROPSHADOW
  else
    Params.WindowClass.style := CS_DBLCLKS;
end;

procedure TCnInputListBox.CreateWnd;
begin
  inherited;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
  Height := AdjustHeight(Height);
end;

destructor TCnInputListBox.Destroy;
begin
  inherited;
end;

procedure TCnInputListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin
  inherited;
  if Shift = [] then
  begin
    Index := ItemAtPos(Point(X, Y), True);
    if Index <> FLastItem then
    begin
      FLastItem := Index;
      Application.CancelHint;
      if Index >= 0 then
        Application.ActivateHint(ClientToScreen(Point(X, Y)));
    end;
  end;
end;

procedure TCnInputListBox.OnBtnClick(Sender: TObject);
begin
  if (Sender is TSpeedButton) and Assigned(FOnButtonClick) then
  begin
    FOnButtonClick(Sender, TCnInputButton(TSpeedButton(Sender).Tag));
  end;
end;

procedure TCnInputListBox.OnHintPaint(Sender: TObject);
var
  i: Integer;
  S: string;
begin
  with HintForm do
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Font := Self.Font;
    Canvas.Font.Color := clInfoText;
    S := '';
    for i := 0 to FHintCnt do
      S := S + '.';
    Canvas.TextOut(2, 2, SCnInputHelperKibitzCompileRunning + S);
  end;
end;

procedure TCnInputListBox.OnHintTimer(Sender: TObject);
begin
  FHintCnt := (FHintCnt + 1) mod 5;
  HintForm.Invalidate;
end;

procedure TCnInputListBox.Popup;
begin
  Visible := True;
  UpdateExtraFormLang;
  UpdateExtraForm;
end;

procedure TCnInputListBox.SetCount(const Value: Integer);
var
  Error: Integer;
begin
{$IFDEF DEBUG}
  if Value <> 0 then
    CnDebugger.LogInteger(Value, 'TCnInputListBox.SetCount');
{$ENDIF}
  // Limited to 32767 on Win95/98 as per Win32 SDK
  Error := SendMessage(Handle, LB_SETCOUNT, Min(Value, 32767), 0);
  if (Error = LB_ERR) or (Error = LB_ERRSPACE) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsgWithType('TCnInputListBox.SetCount Error: ' + IntToStr(Error), cmtError);
  {$ENDIF}
  end;
end;

procedure TCnInputListBox.SetPos(X, Y: Integer);
begin
  SetWindowPos(Handle, HWND_TOPMOST, X, Y, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE);
  UpdateExtraForm;
end;

procedure TCnInputListBox.UpdateExtraForm;
begin
  if DispButtons then
  begin
    BtnForm.Visible := Visible;
    if Visible then
      SetWindowPos(BtnForm.Handle, HWND_TOPMOST, Left + Width, Top, 0, 0,
        SWP_NOACTIVATE or SWP_NOSIZE);
  end
  else
    BtnForm.Visible := False;
    
  if KibitzCompileThreadRunning then
  begin
    HintForm.Visible := Visible;
    if Visible then
      SetWindowPos(HintForm.Handle, HWND_TOPMOST, Left, Top + Height,
        Width, csHintHeight, SWP_NOACTIVATE);
  end
  else
    HintForm.Visible := False;
  FHintTimer.Enabled := HintForm.Visible;
end;

procedure TCnInputListBox.UpdateExtraFormLang;
var
  i: Integer;
begin
  if DispButtons then
    for i := 0 to BtnForm.ComponentCount - 1 do
      if BtnForm.Components[i] is TSpeedButton then
        with TSpeedButton(BtnForm.Components[i]) do
          Hint := StripHotkey(SCnInputButtonHints[TCnInputButton(Tag)]^);
end;

procedure TCnInputListBox.WMMove(var Message: TMessage);
begin
  UpdateExtraForm;
end;

procedure TCnInputListBox.WMSize(var Message: TMessage);
begin
  UpdateExtraForm;
end;

//==============================================================================
// �������Զ���Ƶ������
//==============================================================================

{ TCnSymbolHitCountMgr }

procedure TCnSymbolHitCountMgr.Clear;
var
  i: Integer;
  P: PSymbolHitCountItem;
begin
  for i := 0 to FList.Count - 1 do
  begin
    P := PSymbolHitCountItem(FList[i]);
    Dispose(P);
  end;
  FList.Clear;
end;

constructor TCnSymbolHitCountMgr.Create;
begin
  FList := TList.Create;
  FFileName := WizOptions.UserPath + csDataFile;
  LoadFromFile;
end;

procedure TCnSymbolHitCountMgr.DecAllHitCount(TimeStamp: TDateTime);
var
  i: Integer;
  P: PSymbolHitCountItem;
begin
  for i := FList.Count - 1 downto 0 do
  begin
    P := PSymbolHitCountItem(FList[i]);
    if P.TimeStamp < TimeStamp then
    begin
      if P.HitCount > 1 then
      begin
        Dec(P.HitCount);
        P.TimeStamp := Now;
      end
      else
      begin
        Dispose(P);
        FList.Delete(i);
      end;
    end;
  end;
end;

destructor TCnSymbolHitCountMgr.Destroy;
begin
  // ����δʹ�õı�ʶ���Զ����ٵ����
  DecAllHitCount(Now - csDecHitCountDays);
  SaveToFile;
  Clear;
  FList.Free;
  inherited;
end;

function TCnSymbolHitCountMgr.GetCount: Integer;
begin
  Result := FList.Count;
end;

function DoHashCodeFind(Item1, Item2: Pointer): Integer;
var
  H1, H2: Cardinal;
begin
  H1 := Cardinal(Item1);
  H2 := PSymbolHitCountItem(Item2).HashCode;
  if H1 > H2 then
    Result := 1
  else if H1 < H2 then
    Result := -1
  else
    Result := 0;
end;

function DoHashCodeSort(Item1, Item2: Pointer): Integer;
var
  H1, H2: Cardinal;
begin
  H1 := PSymbolHitCountItem(Item1).HashCode;
  H2 := PSymbolHitCountItem(Item2).HashCode;
  if H1 > H2 then
    Result := 1
  else if H1 < H2 then
    Result := -1
  else
    Result := 0;
end;

function TCnSymbolHitCountMgr.GetHitCount(AHashCode: Cardinal): Integer;
var
  Idx: Integer;
begin
  Idx := HalfFind(FList, Pointer(AHashCode), DoHashCodeFind);
  if Idx >= 0 then
    Result := TrimInt(Items[Idx].HitCount, 0, csMaxHitCount)
  else
    Result := 0;
end;

function TCnSymbolHitCountMgr.GetItems(Index: Integer): PSymbolHitCountItem;
begin
  Result := PSymbolHitCountItem(FList[Index]);
end;

procedure TCnSymbolHitCountMgr.IncHitCount(AHashCode: Cardinal);
var
  Idx: Integer;
  Item: PSymbolHitCountItem;
begin
  Idx := HalfFind(FList, Pointer(AHashCode), DoHashCodeFind);
  if (Idx >= 0) and (Items[Idx].HitCount < csMaxHitCount) then
  begin
    Inc(Items[Idx].HitCount);
    Items[Idx].TimeStamp := Now;
  end
  else
  begin
    New(Item);
    Item.HashCode := AHashCode;
    Item.TimeStamp := Now;
    Item.HitCount := 1;
    FList.Add(Item);
    FList.Sort(DoHashCodeSort);
  end;
end;

procedure TCnSymbolHitCountMgr.LoadFromFile(FileName: string = '');
var
  Stream: TMemoryStream;
  Flag, Version: Cardinal;
  Item: PSymbolHitCountItem;
  i: Integer;
begin
  if FileName = '' then
    FileName := FFileName;
  Clear;
  if FileExists(FileName) then
  begin
    try
      Stream := TMemoryStream.Create;
      try
        Stream.LoadFromFile(FileName);
        Stream.Position := 0;

        if Stream.Read(Flag, SizeOf(Flag)) <> SizeOf(Flag) then
          Exit;
        if Flag <> csFileFlag then
          Exit;

        if Stream.Read(Version, SizeOf(Version)) <> SizeOf(Version) then
          Exit;
        if Version <> csVersion then
          Exit;

        for i := 0 to (Stream.Size - Stream.Position) div
          SizeOf(TSymbolHitCountItem) - 1 do
        begin
          New(Item);
          Stream.Read(Item^, SizeOf(TSymbolHitCountItem));
          FList.Add(Item);
        end;

        // �����������ڰ汾��������б�
        FList.Sort(DoHashCodeSort);
        for i := FList.Count - 1 downto 1 do
          if PSymbolHitCountItem(FList[i]).HashCode =
            PSymbolHitCountItem(FList[i - 1]).HashCode then
            FList.Delete(i);
      finally
        Stream.Free;
      end;
    except
      on E: Exception do
        DoHandleException(E.Message);
    end;
  end;
end;

procedure TCnSymbolHitCountMgr.SaveToFile(FileName: string = '');
var
  Stream: TMemoryStream;
  Flag, Version: Cardinal;
  i: Integer;
begin
  if FileName = '' then
    FileName := FFileName;
  try
    Stream := TMemoryStream.Create;
    try
      Flag := csFileFlag;
      if Stream.Write(Flag, SizeOf(Flag)) <> SizeOf(Flag) then
        Exit;
        
      Version := csVersion;
      if Stream.Write(Version, SizeOf(Version)) <> SizeOf(Version) then
        Exit;

      for i := 0 to FList.Count - 1 do
      begin
        if Stream.Write(Items[i]^, SizeOf(TSymbolHitCountItem)) <>
          SizeOf(TSymbolHitCountItem) then
          Exit;
      end;

      Stream.SaveToFile(FileName);
    finally
      Stream.Free;
    end;
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;
end;

//------------------------------------------------------------------------------
// ������Hash�б���
//------------------------------------------------------------------------------

{ TCnSymbolHashList }

function TCnSymbolHashList.CheckExist(AItem: TSymbolItem): Boolean;
var
  i, Idx: Integer;
  Hash: Cardinal;
begin
  Result := False;
  Hash := AItem.HashCode;
  for i := 0 to FCount - 1 do
  begin
    Idx := (Integer(Hash) + i) mod FCount;
    if Idx < 0 then
      Idx := Idx + FCount;
    if FList[Idx] = nil then
    begin
      FList[Idx] := AItem;
      Exit;
    end
    else if FList[Idx].HashCode = AItem.HashCode then
    begin
      if (FList[Idx].Kind = AItem.Kind) and (FList[Idx].Name = AItem.Name) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

constructor TCnSymbolHashList.Create(ACount: Integer);
var
  Size: Integer;
begin
  FCount := ACount * csHashListInc + 13;
  Size := FCount * SizeOf(TSymbolItem);
  GetMem(FList, Size);
  ZeroMemory(FList, Size);
end;

destructor TCnSymbolHashList.Destroy;
begin
  FreeMem(FList);
  inherited;
end;

//==============================================================================
// ��������ר����
//==============================================================================

{ TCnInputHelper }

constructor TCnInputHelper.Create;
{$IFNDEF SUPPORT_IDESymbolList}
var
  DphIdeModule: HMODULE;
{$ENDIF}
begin
  inherited;
  List := TCnInputListBox.Create(nil);
  List.Parent := Application.MainForm;
  List.OnDrawItem := ListDrawItem;
  List.OnDblClick := ListDblClick;
  List.OnItemHint := ListItemHint;
  List.OnButtonClick := OnBtnClick;
  Menu := TPopupMenu.Create(nil);
  Menu.OnPopup := OnPopupMenu;
  CreateMenuItem;
  List.PopupMenu := Menu;
  Timer := TTimer.Create(nil);
  Timer.OnTimer := OnTimer;
  Timer.Enabled := False;
  FFilterSymbols := TStringList.Create;
  FAutoSymbols := TStringList.Create;
  AppEvents := TApplicationEvents.Create(nil);
  AppEvents.OnDeactivate := OnAppDeactivate;
  FHitCountMgr := TCnSymbolHitCountMgr.Create;
  FSymbolListMgr := TSymbolListMgr.Create;

  FSymbols := TStringList.Create;
  FItems := TStringList.Create;
  FPopupShortCut := WizShortCutMgr.Add(SCnInputHelperPopup,
    ShortCut(VK_DOWN, [ssAlt]), PopupKeyProc);

  FDispKindSet := csAllSymbolKind;
  AutoPopup := True;

{$IFNDEF SUPPORT_IDESymbolList}
  // �����֧�� IDE �����б���Ҫ�ҵ� Cppcodcmplt::TCppKibitzManager::CCError
  DphIdeModule := LoadLibrary(DphIdeLibName);
  if DphIdeModule <> 0 then
  begin
    if GetProcAddress(DphIdeModule, SCppKibitzManagerCCError) <> nil then
      FCCErrorHook := TCnMethodHook.Create(GetBplMethodAddress(GetProcAddress
        (DphIdeModule, SCppKibitzManagerCCError)), @MyCCError);
  end;
{$ENDIF}

  CnWizNotifierServices.AddApplicationMessageNotifier(ApplicationMessage);
  CnWizNotifierServices.AddActiveControlNotifier(ActiveControlChanged);
end;

destructor TCnInputHelper.Destroy;
begin
  CnWizNotifierServices.RemoveActiveControlNotifier(ActiveControlChanged);
  CnWizNotifierServices.RemoveApplicationMessageNotifier(ApplicationMessage);

{$IFNDEF SUPPORT_IDESymbolList}
  FCCErrorHook.Free;
{$ENDIF}

  WizShortCutMgr.DeleteShortCut(FPopupShortCut);
  FItems.Free;
  FSymbols.Free;
  SymbolListMgr.Free;
  HitCountMgr.Free;
  AppEvents.Free;
  FFilterSymbols.Free;
  FAutoSymbols.Free;
  Timer.Free;
  Menu.Free;
  List.Free;
  inherited;
end;

procedure TCnInputHelper.Loaded;
var
  i: Integer;
begin
  inherited;
  // ��ʼ�������б������
  SymbolListMgr.InitList;

  // װ�ػ����
  with CreateIniFile do
  try
    for i := 0 to SymbolListMgr.Count - 1 do
      SymbolListMgr.List[i].Active := ReadBool(csListActive,
        SymbolListMgr.List[i].ClassName, True);
  finally
    Free;
  end;
  
  SymbolListMgr.GetValidCharSet(FirstSet, CharSet, FPosInfo);
end;

//------------------------------------------------------------------------------
// ��������
//------------------------------------------------------------------------------

function TCnInputHelper.AcceptDisplay: Boolean;

  function IsAutoCompleteActive: Boolean;
  var
    hWin: THandle;
  begin
    hWin := FindWindow(csKibitzWindowClass, csKibitzWindowName);
    Result := (hWin <> 0) and IsWindowVisible(hWin);
  end;

  function IsReadOnly: Boolean;
  var
    Buffer: IOTAEditBuffer;
  begin
    Buffer := CnOtaGetEditBuffer;
    if Assigned(Buffer) then
      Result := Buffer.IsReadOnly
    else
      Result := True;
  end;

  function IsInIncreSearch: Boolean;
  begin
    // todo: �������������״̬
    Result := False;
  end;

  function IsInMacroOp: Boolean;
  var
    KeySvcs: IOTAKeyboardServices;
  begin
    Result := False;
    KeySvcs := BorlandIDEServices as IOTAKeyboardServices;
    if Assigned(KeySvcs) then
    begin
      if Assigned(KeySvcs.CurrentPlayback) and KeySvcs.CurrentPlayback.IsPlaying or
        Assigned(KeySvcs.CurrentRecord) and KeySvcs.CurrentRecord.IsRecording then
        Result := True;
    end;
  end;

  function CanPopupInCurrentSourceType: Boolean;
  begin
    {$IFDEF BDS}
      {$IFDEF BDS2009_UP}
      Result := CurrentIsSource; // �� 2009 ������ǿ֧�� C++Builder������
      {$ELSE}
      Result := CurrentIsDelphiSource; // 2007 �����°汾 OTA �� Bug���޷�֧�� C++Builder
      {$ENDIF}
    {$ELSE} // D7 �����£�����BCB5/6
    Result := CurrentIsSource;
    {$ENDIF}
  end;
begin
  Result := Active and IsEditControl(Screen.ActiveControl) and
    (not CheckImmRun or not IMMIsActive) and CanPopupInCurrentSourceType and
    not IsAutoCompleteActive and not IsReadOnly and not CnOtaIsDebugging and
    not IsInIncreSearch and not IsInMacroOp;
end;

procedure TCnInputHelper.ApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
begin
  if ((Msg.message >= WM_KEYFIRST) and (Msg.message <= WM_KEYLAST) or
    (Msg.message = WM_MOUSEWHEEL)) then
  begin
    if AcceptDisplay then
    begin
      case Msg.message of
        WM_KEYDOWN:
          Handled := HandleKeyDown(Msg);
        WM_KEYUP:
          Handled := HandleKeyUp(Msg);
        WM_MOUSEWHEEL:
          if IsShowing then
          begin
            SendMessage(List.Handle, WM_MOUSEWHEEL, Msg.wParam, Msg.lParam);
            Handled := True;
          end;
      end;
      if Handled then
      begin
        Msg.message := 0;
        Msg.wParam := 0;
        Msg.lParam := 0;
      end;
    end
    else
    begin
      HideAndClearList;
    end;  
  end
  else
  begin
    case Msg.message of
      WM_SYSKEYDOWN, WM_SETFOCUS:
        if IsShowing then
          HideAndClearList;
      WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN:
        if ((Msg.hwnd <> List.Handle) and (Msg.hwnd <> List.BtnForm.Handle))
          and IsShowing then
          HideAndClearList;
    end;
  end;
end;

procedure TCnInputHelper.ActiveControlChanged(Sender: TObject);
begin
  if not AcceptDisplay then
    HideAndClearList;
end;

procedure TCnInputHelper.OnAppDeactivate(Sender: TObject);
begin
  HideAndClearList;
end;

function TCnInputHelper.IsValidSymbolChar(C: Char;
  First: Boolean): Boolean;
begin
  if First then  // C/C++ ��Ҫ����ָ��Ҳ���ʶ��
    Result := CharInSet(C, CalcFirstSet(FPosInfo.IsPascal))
  else
    Result := CharInSet(C, CharSet);
end;

function TCnInputHelper.IsValidSymbol(Symbol: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  if Symbol <> '' then
  begin
    for i := 1 to Length(Symbol) do
      if not IsValidSymbolChar(Symbol[i], i = 1) then
        Exit;
    Result := True;
  end;
end;

function TCnInputHelper.IsValidCharKey(VKey: Word; ScanCode: Word): Boolean;
var
  C: AnsiChar;
begin
  C := VK_ScanCodeToAscii(VKey, ScanCode);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('IsValidCharKey VK_ScanCodeToAscii: %d %d => %d ("%s")', [VKey, ScanCode, Ord(C), C]);
{$ENDIF}
  if FPosInfo.IsPascal then
    Result := C in ( FirstSet + CharSet)
  else // C/C++ ���� -> ��
    Result := C in ( FirstSet + ['>'] + CharSet);
end;

function TCnInputHelper.CurrBlockIsEmpty: Boolean;
begin
  Result := CnOtaIsPersistentBlocks or (CnOtaGetCurrentSelection = '');
end;

function TCnInputHelper.IsValidDelelteKey(Key: Word): Boolean;
begin
  Result := False;
  if Key = VK_DELETE then
  begin
    // ɾ����ʱ��߶�Ӧ������Ч�ַ�
    if IsValidSymbolChar(CnOtaGetCurrChar(-1), True) and
      IsValidSymbolChar(CnOtaGetCurrChar(0), True) then
      Result := True;
  end
  else if Key = VK_BACK then
  begin
    // �˸�ʱҪ���������Ч�ַ�
    if IsValidSymbolChar(CnOtaGetCurrChar(-1), True) and
      IsValidSymbolChar(CnOtaGetCurrChar(-2), True) then
      Result := True;
  end;
end;

function TCnInputHelper.IsValidDotKey(Key: Word): Boolean;
var
  Option: IOTAEnvironmentOptions;
begin
  Result := False;
  if DispOnIDECompDisabled and ((Key = VK_DECIMAL) or (Key = 190)) then
  begin
    Option := CnOtaGetEnvironmentOptions;
    if not Option.GetOptionValue(csKeyCodeCompletion) then
      Result := True;
  end;
end;

function TCnInputHelper.IsValidKeyQueue: Boolean;
var
  i: Integer;
begin
  Result := False;
  if FEnableAutoSymbols then
  begin
    for i := 0 to FAutoSymbols.Count - 1 do
    begin
      if SameText(FAutoSymbols[i], StrRight(FKeyQueue, Length(FAutoSymbols[i]))) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;    
end;

function TCnInputHelper.HandleKeyDown(var Msg: TMsg): Boolean;
var
  Shift: TShiftState;
  ScanCode: Word;
  Key: Word;
  KeyDownChar: AnsiChar;
  IgnoreOfDot: Boolean;
begin
  Result := False;

  Key := Msg.wParam;
  Shift := KeyDataToShiftState(Msg.lParam);
  ScanCode := (Msg.lParam and $00FF0000) shr 16;

  // ����������뷨����ʱҲ���룬��ʹ��ɨ�������������
  if not CheckImmRun and (Key = VK_PROCESSKEY) then
    Key := MapVirtualKey(ScanCode, 1);

{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnInputHelper.HandleKeyDown, Key: %d, ScanCode: %d', [Key, ScanCode]);
{$ENDIF}

  // ���� Alt �� Ctrl ʱ�ر�
  if Shift * [ssAlt, ssCtrl] <> [] then
  begin
    HideAndClearList;
    Exit;
  end;

  // Shift ������Ҫ����
  if Key = VK_SHIFT then
    Exit;

  // ���水������
  KeyDownChar := VK_ScanCodeToAscii(Key, ScanCode);
  FKeyQueue := FKeyQueue + string(KeyDownChar);
  if Length(FKeyQueue) > csKeyQueueLen then
    FKeyQueue := StrRight(FKeyQueue, csKeyQueueLen);

  if IsShowing then
  begin
    case Key of
      VK_RETURN:
        begin
          SendSymbolToIDE(False, True, False, #0, Result);
          Result := True;
        end;
      VK_TAB, VK_DECIMAL, 190: // '.'
        begin
          IgnoreOfDot := False;
{$IFDEF SUPPORT_UNITNAME_DOT}
          if Key = 190 then
          begin
            if IndexStr(FToken, csUnitDotPrefixes, CurrentIsDelphiSource) >= 0 then
            begin
              IgnoreOfDot := True;
{$IFDEF DEBUG}
              CnDebugger.LogMsg('Dot Got. Unit Prefix Detected. Ignore ' + FToken);
{$ENDIF}
            end;
          end;
{$ENDIF}
          if not IgnoreOfDot then
          begin
            SendSymbolToIDE(SelMidMatchByEnterOnly, False, False, #0, Result);
            if IsValidDotKey(Key) or IsValidCppArrowKey(Key, ScanCode) then
            begin
              Timer.Interval := Max(csDefDispDelay, FDispDelay);
              Timer.Enabled := True;
            end;
          end;
        end;
      VK_ESCAPE:
        begin
          HideAndClearList;
          Result := True;
        end;
      VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT:
        begin
          SendMessage(List.Handle, Msg.message, Msg.wParam, Msg.lParam);
          Result := True;
        end;
      VK_END, VK_HOME:
        begin
          // Shift + Home/End ��ҳ������ر�
          if Shift = [ssShift] then
          begin
            SendMessage(List.Handle, Msg.message, Msg.wParam, Msg.lParam);
            Result := True;
          end
          else
          begin
            HideAndClearList;
          end;
        end;
    end;

    if not Result then
    begin
      Result := HandleKeyPress(KeyDownChar);
    end;
  end
  else
  begin
    Timer.Enabled := False;
    FKeyDownValid := False;
    if AutoPopup and ((FKeyCount < DispOnlyAtLeastKey - 1) or CurrBlockIsEmpty) and
      (IsValidCharKey(Key, ScanCode) or IsValidDelelteKey(Key) or IsValidDotKey(Key)
       or IsValidCppArrowKey(Key, ScanCode)) then
    begin
      // Ϊ�˽���������Ҽ������������⣬�˴����浱ǰ���ı�����Ϣ
      CnNtaGetCurrLineText(FCurrLineText, FCurrLineNo, FCurrIndex);
      FCurrLineLen := Length(FCurrLineText);
{$IFDEF DEBUG}
//    CnDebugger.LogMsg('Handle Key Down. Got Line Len: ' + IntToStr(FCurrLineLen));
{$ENDIF}
      FKeyDownTick := GetTickCount;
      FKeyDownValid := True;
    end
    else
      FKeyCount := 0;
  end;
end;

function TCnInputHelper.HandleKeyPress(Key: AnsiChar): Boolean;
var
  Item: TSymbolItem;
  Idx: Integer;
begin
  Result := False;
{$IFDEF DEBUG}
  CnDebugger.LogInteger(Ord(Key), 'TCnInputHelper.HandleKeyPress');
{$ENDIF}

  FNeedUpdate := False;
  if (Key >= #32) and (Key < #127) and IsShowing then
  begin
    Item := TSymbolItem(FItems.Objects[List.ItemIndex]);
    Idx := Pos(UpperCase(FMatchStr + Char(Key)), UpperCase(Item.Name));
    if (Idx = 1) or MatchAnyWhere and (Idx > 1) and not Item.MatchFirstOnly then
    begin
      FNeedUpdate := True;
    end
    else if IsValidSymbolChar(Char(Key), False) then
    begin
      FNeedUpdate := True;
    end
    else if (FSpcComplete and (Key = ' ')) or (Pos(Char(Key), FCompleteChars) > 0) then
    begin
      SendSymbolToIDE(SelMidMatchByEnterOnly, False, False, Key, Result);

      // �ո������������ԣ���ո���������༭������ IDE �Զ���������
      if FSpcComplete and FIgnoreSpc and (Key = ' ') then
        Result := True;
    end
    else
    begin
      HideAndClearList;
    end;
  end;
end;

function TCnInputHelper.HandleKeyUp(var Msg: TMsg): Boolean;
var
  Key: Word;
  NewToken, LineText: string;
  CurrPos: Integer;
  LineNo, Index, Len: Integer;
  ScanCode: Word;
begin
  Result := False;
  Key := Msg.wParam;
  ScanCode := (Msg.lParam and $00FF0000) shr 16;
  
{$IFDEF DEBUG}
  CnDebugger.LogInteger(Msg.wParam, 'TCnInputHelper.HandleKeyUp');
{$ENDIF}

  if (FKeyDownValid or IsValidKeyQueue) and not IsShowing then
  begin
    CnNtaGetCurrLineText(LineText, LineNo, Index);
    Len := Length(LineText);
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('Input Helper. Line: %d, Len %d. CurLine %d, CurLen %d', [LineNo, Len, FCurrLineNo, FCurrLineLen]);
{$ENDIF}
    // ����˴ΰ����Ե�ǰ�������޸Ĳ���Ϊ����Ч�������Դ����������ҵ�����
    // XE4��BCB�����У�����Ĭ�ϳ��ȶ���4�����Կո���䣬��˲��ܼ򵥱Ƚϳ��ȣ��ñ�����
    if (LineNo = FCurrLineNo) and ((Len <> FCurrLineLen) or (LineText <> FCurrLineText)) then
    begin
      Inc(FKeyCount);
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Input Helper. Inc FKeyCount to ' + IntToStr(FKeyCount));
{$ENDIF}
      if IsValidDotKey(Key) or IsValidCppArrowKey(Key, ScanCode) or (FKeyCount >= DispOnlyAtLeastKey) or
        IsValidKeyQueue then
      begin
        if FDispDelay > GetTickCount - FKeyDownTick then
          Timer.Interval := Max(csMinDispDelay, FDispDelay - (GetTickCount -
            FKeyDownTick))
        else
          Timer.Interval := csMinDispDelay;
        Timer.Enabled := True;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Input Helper. Key Count Reached or Popup Key Meet. Enable Timer.');
{$ENDIF}
      end;
    end;
  end
  else if ((Key = VK_DELETE) or (Key = VK_BACK) or (Key = VK_LEFT) or
    (Key = VK_RIGHT) or FNeedUpdate) and IsShowing then
  begin
    FNeedUpdate := False;
    if (Key = VK_LEFT) or (Key = VK_RIGHT) then
    begin
      CnOtaGetCurrPosToken(NewToken, CurrPos, True, CalcFirstSet(FPosInfo.IsPascal), CharSet);
      if not SameText(NewToken, FToken) then
      begin
        HideAndClearList;
        Exit;
      end;
    end;
    UpdateListBox(False, False);
  end;
  
  FKeyDownValid := False;
end;

function TCnInputHelper.ParsePosInfo: Boolean;
const
  csParseBlockSize = 40 * 1024;
  csParseBlockAdd = 80;
var
  Stream: TMemoryStream;
  View: IOTAEditView;
  StartPos, CurrPos: Integer;
  Element, LineFlag: Integer;
  P: PAnsiChar;
  IsPascalFile, IsCppFile: Boolean;
begin
  Result := False;
  View := CnOtaGetTopMostEditView;
  if not Assigned(View) then Exit;

  IsPascalFile := IsDelphiSourceModule(View.Buffer.FileName) or IsInc(View.Buffer.FileName);
  if not IsPascalFile then
    IsCppFile := IsCppSourceModule(View.Buffer.FileName)
  else
    IsCppFile := False;

  Stream := TMemoryStream.Create;
  try
    CurrPos := CnOtaGetCurrPos(View.Buffer);
    if View.CursorPos.Line > csMaxProcessLines then
    begin
      // CnOtaEditPosToLinePos �ڴ��ļ�ʱ��������˴�ֱ��ʹ������λ��������
      StartPos := Max(0, CurrPos - csParseBlockSize);
      CnOtaSaveEditorToStreamEx(View.Buffer, Stream, StartPos, CurrPos +
        csParseBlockAdd, 0, False); // BDS �²��� Utf8->Ansi ת�������λ

      // �����׿�ʼ
      P := PAnsiChar(Stream.Memory);
      while not (P^ in [#0, #13, #10]) do
      begin
        Inc(StartPos);
        Inc(P);
      end;

      // BDS �µ���ȡ�������ݱ����� Utf8->Ansiת������ע�ͽ�����������⣬
      // �� ParsePasCodePosInfo/ParseCppCodePosInfo �ڲ�����
      if IsPascalFile then
      begin
        FPosInfo := ParsePasCodePosInfo(P, CurrPos - StartPos, False, True);
        EditControlWrapper.GetAttributeAtPos(CnOtaGetCurrentEditControl,
          View.CursorPos, False, Element, LineFlag);
        case Element of
          atComment:
            if not (FPosInfo.PosKind in [pkComment, pkCompDirect]) then
              FPosInfo.PosKind := pkComment;
          atString:
            FPosInfo.PosKind := pkString;
        end;
      end
      else if IsCppFile then
      begin
        // ���� C++ �ļ����жϹ��������λ������
        FPosInfo := ParseCppCodePosInfo(P, CurrPos - StartPos, False, True);
        EditControlWrapper.GetAttributeAtPos(CnOtaGetCurrentEditControl,
          View.CursorPos, False, Element, LineFlag);
        case Element of
          atComment:
            if not (FPosInfo.PosKind in [pkComment]) then
              FPosInfo.PosKind := pkComment;
          atString:
            FPosInfo.PosKind := pkString;
        end;
      end;
    end
    else
    begin
      CnOtaSaveCurrentEditorToStream(Stream, False, False);
      // BDS �������Ѿ��� UTF8 �ˣ�������Ansiת���Ա���ע���жϴ���
      if IsPascalFile then
      begin
        FPosInfo := ParsePasCodePosInfo(PAnsiChar(Stream.Memory), CurrPos, True, True)
      end
      else if IsCppFile then
      begin
        // ���� C++ �ļ����жϹ��������λ������
        FPosInfo := ParseCppCodePosInfo(PAnsiChar(Stream.Memory), CurrPos, True, True);
      end;
    end;
  finally
    Stream.Free;
  end;
{$IFDEF DEBUG}
  with FPosInfo do
    if FPosInfo.IsPascal then
      CnDebugger.LogMsg(
        'TokenID: ' + GetEnumName(TypeInfo(TTokenKind), Ord(TokenID)) + #13#10 +
        ' AreaKind: ' + GetEnumName(TypeInfo(TCodeAreaKind), Ord(AreaKind)) + #13#10 +
        ' PosKind: ' + GetEnumName(TypeInfo(TCodePosKind), Ord(PosKind)) + #13#10 +
        ' LineNumber: ' + IntToStr(LineNumber) + #13#10 +
        ' LinePos: ' + IntToStr(LinePos) + #13#10 +
        ' LastToken: ' + GetEnumName(TypeInfo(TTokenKind), Ord(LastNoSpace)) + #13#10 +
        ' Token: ' + string(Token))
    else
      CnDebugger.LogMsg(
        'CTokenID: ' + GetEnumName(TypeInfo(TCTokenKind), Ord(CTokenID)) + #13#10 +
        ' AreaKind: ' + GetEnumName(TypeInfo(TCodeAreaKind), Ord(AreaKind)) + #13#10 +
        ' PosKind: ' + GetEnumName(TypeInfo(TCodePosKind), Ord(PosKind)) + #13#10 +
        ' LineNumber: ' + IntToStr(LineNumber) + #13#10 +
        ' LinePos: ' + IntToStr(LinePos) + #13#10 +
        ' LastToken: ' + GetEnumName(TypeInfo(TTokenKind), Ord(LastNoSpace)) + #13#10 +
        ' Token: ' + string(Token));
{$ENDIF}
  SymbolListMgr.GetValidCharSet(FirstSet, CharSet, FPosInfo);
  if IsPascalFile then
    Result := not (FPosInfo.AreaKind in [akUnknown, akEnd]) and
      not (FPosInfo.PosKind in [pkUnknown, pkString]) and
      not (FPosInfo.TokenID in [tkFloat])
  else if IsCppFile then
    Result := not (FPosInfo.PosKind in [pkUnknown, pkString, pkDeclaration]) and
      not (FPosInfo.CTokenID in [ctknumber, ctkfloat]); // ��Щ�����ʹ�ܿ���
end;

procedure TCnInputHelper.OnTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  FKeyCount := 0;
  if AcceptDisplay and ParsePosInfo then
  begin
    ShowList(IsValidKeyQueue);
  end
  else
    HideAndClearList;
end;

//------------------------------------------------------------------------------
// ����������
//------------------------------------------------------------------------------

function MyMessageDlgPosHelp(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string): Integer;
begin
  Result := mrOk;
end;

procedure TCnInputHelper.ShowIDECodeCompletion;
var
  Hook: TCnMethodHook;
  EditView: IOTAEditView;
begin
  EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    // IDE ���޷����� CodeInsight ʱ�ᵯ��һ������򣨲����쳣��
    // �˴���ʱ�滻����ʾ�����ĺ��� MessageDlgPosHelp��ʹ֮����ʾ����
    // ��������ɺ��ٻָ���
    Hook := TCnMethodHook.Create(@MessageDlgPosHelp, @MyMessageDlgPosHelp);
    try
      (EditView as IOTAEditActions).CodeCompletion(csCodeList or csManual);
    finally
      Hook.Free;
    end;
  end;
end;

procedure TCnInputHelper.ShowList(ForcePopup: Boolean);
var
  Pt: TPoint;
  i: Integer;
  Left, Top: Integer;
  CurrPos: Integer;
  AForm: TCustomForm;
  WorkRect: TRect;
{$IFNDEF SUPPORT_IDESymbolList}
  AToken: string;
{$ENDIF}
begin
  if AcceptDisplay and GetCaretPosition(Pt) then
  begin
    // ȡ�õ�ǰ��ʶ���������ߵĲ��֣�C/C++����£��������ָ���#Ҳ��Ϊ��ʶ����ͷ
    CnOtaGetCurrPosToken(FToken, CurrPos, True, CalcFirstSet(FPosInfo.IsPascal), CharSet);
    FMatchStr := Copy(FToken, 1, CurrPos);
{$IFDEF DEBUG}
    CnDebugger.TraceFmt('Token %s, Match %s', [FToken, FMatchStr]);
{$ENDIF}
    if ForcePopup or IsValidSymbol(FToken) or (FPosInfo.PosKind = pkFieldDot) then
    begin
      // �ڹ����б���ʱ���Զ�����
      if not ForcePopup and (FFilterSymbols.IndexOf(FMatchStr) >= 0) then
      begin
        FKeyCount := DispOnlyAtLeastKey - 1;
        Exit;
      end;

      UpdateSymbolList;
      SortSymbolList;
      if UpdateListBox(ForcePopup, True) then
      begin
        // �ж��Ƿ���Ҫ��ʾ
        if not ForcePopup and SmartDisplay then
        begin
          for i := 0 to FItems.Count - 1 do
            with TSymbolItem(FItems.Objects[i]) do
            if not AlwaysDisp and ((Kind = skKeyword) and
              (CompareStr(GetKeywordText(KeywordStyle), FToken) = 0) or
              (Kind <> skKeyword) and (CompareStr(Name, Text) = 0) and
              (CompareStr(FToken, Name) = 0)) then
            begin
              FKeyCount := DispOnlyAtLeastKey - 1;
              Exit;
            end;
        end;

        AForm := CnOtaGetCurrentEditWindow;
        if Assigned(AForm) and Assigned(AForm.Monitor) then
          with AForm.Monitor do
            WorkRect := Bounds(Left, Top, Width, Height)
        else
          WorkRect := Bounds(0, 0, Screen.Width, Screen.Height);
        if Pt.x + List.Width <= WorkRect.Right then
          Left := Pt.x
        else
          Left := Max(Pt.x - List.Width, WorkRect.Left);
        if Pt.y + csLineHeight + List.Height <= WorkRect.Bottom then
          Top := Pt.y + csLineHeight
        else
          Top := Max(Pt.y - List.Height - csLineHeight div 2, WorkRect.Top);
        List.SetPos(Left, Top);
        List.Popup;
      {$IFDEF ADJUST_CodeParamWindow}
        AdjustCodeParamWindowPos;
      {$ENDIF}
      end
      else if not (FPosInfo.PosKind in [pkUnknown, pkFlat, pkComment, pkIntfUses,
        pkImplUses, pkResourceString, pkCompDirect, pkString]) then // ����жϣ�Pascal �� C++ ͨ��
      begin
      {$IFNDEF SUPPORT_IDESymbolList}
        // �����֧�� IDE �����б�ֻ�ڷǱ�ʶ�ĵط���ʾ����б�
        if not FPosInfo.IsPascal then
        begin
          // BCB ������£�Ҳ����ʲô���Ŷ�����
          if ForcePopup then
            ShowIDECodeCompletion
          else
          begin
            CnOtaGetCurrPosToken(AToken, CurrPos, True, CalcFirstSet(FPosInfo.IsPascal), CharSet);
            if (AToken <> '') and (CurrPos > 0) and  not (AToken[CurrPos] in ['+', '-', '*', '/']) then
              ShowIDECodeCompletion;
          end;
        end;
      {$ENDIF}
      end;
    end;
  end;
end;

procedure TCnInputHelper.HideAndClearList;
begin
  HideList;
  ClearList;
end;

procedure TCnInputHelper.HideList;
begin
  FKeyCount := 0;
  FLastStr := '';
  if IsShowing then
    List.CloseUp;
end;

procedure TCnInputHelper.ClearList;
begin
  FSymbols.Clear;
  FItems.Clear;
  List.SetCount(0);
end;

function TCnInputHelper.GetIsShowing: Boolean;
begin
  Result := List.Visible;
end;

{$IFDEF ADJUST_CodeParamWindow}
procedure TCnInputHelper.CodeParamWndProc(var Message: TMessage);
var
  Msg: TWMWindowPosChanging;
  ParaComp: TComponent;
  ParaWnd: TWinControl;
  R1, R2, R3: TRect;
begin
  if (Message.Msg = WM_WINDOWPOSCHANGING) and IsShowing then
  begin
    // ������ʾʱ����ֹ������ʾ���ڻָ����ص�λ��
    Msg := TWMWindowPosChanging(Message);
    if Msg.WindowPos.flags and SWP_NOMOVE = 0 then
    begin
      ParaComp := Application.FindComponent('CodeParamWindow');
      if (ParaComp <> nil) and ParaComp.ClassNameIs('TTokenWindow') and
        (ParaComp is TWinControl) then
      begin
        ParaWnd := TWinControl(ParaComp);
        GetWindowRect(ParaWnd.Handle, R1);
        with Msg.WindowPos^ do
          R1 := Bounds(x, y, RectWidth(R1), RectHeight(R1) + EditControlWrapper.GetCharHeight);
        GetWindowRect(List.Handle, R2);
        if IntersectRect(R3, R1, R2) and not IsRectEmpty(R3) then
        begin
          Msg.WindowPos.flags := Msg.WindowPos.flags + SWP_NOMOVE;
        end;
      end;
    end;
  end;
  
  if Assigned(FCodeWndProc) then
    FCodeWndProc(Message);
end;

procedure TCnInputHelper.HookCodeParamWindow(Wnd: TWinControl);
var
  Med: TWndMethod;
begin
  Med := CodeParamWndProc;
  if not SameMethod(TMethod(Wnd.WindowProc), TMethod(Med)) then
  begin
    FCodeWndProc := Wnd.WindowProc;
    Wnd.WindowProc := CodeParamWndProc;
  end;  
end;

procedure TCnInputHelper.AdjustCodeParamWindowPos;
var
  ParaComp: TComponent;
  ParaWnd: TWinControl;
  R1, R2, R3: TRect;
begin
  // BDS �º���������ʾ�����ڵ�ǰ�е��·�����ס�����ִ��ڣ���Ҫ�Ƶ���ǰ���Ϸ�ȥ
  if IsShowing then
  begin
    ParaComp := Application.FindComponent('CodeParamWindow');
    if (ParaComp <> nil) and ParaComp.ClassNameIs('TTokenWindow') and
      (ParaComp is TWinControl) then
    begin
      ParaWnd := TWinControl(ParaComp);
      // Hook�������ڣ���ֹ���Զ��ָ�λ��
      HookCodeParamWindow(ParaWnd);
      // �жϲ������������ڵ�λ��
      GetWindowRect(ParaWnd.Handle, R1);
      GetWindowRect(List.Handle, R2);
      if IntersectRect(R3, R1, R2) and not IsRectEmpty(R3) then
      begin
        ParaWnd.Top := List.Top - ParaWnd.Height - EditControlWrapper.GetCharHeight;
        OffsetRect(R1, 0, - EditControlWrapper.GetCharHeight * 2);
        SetWindowPos(ParaWnd.Handle, 0, R1.Left, R1.Top, 0, 0,
          SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
      end;
    end;
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------
// ���ݸ��¼�����
//------------------------------------------------------------------------------

function SymbolSortByScope(List: TStringList; Index1, Index2: Integer): Integer;
var
  L1, L2: Integer;
begin
  L1 := TSymbolItem(List.Objects[Index1]).ScopeAdjust;
  L2 := TSymbolItem(List.Objects[Index2]).ScopeAdjust;
  if L2 < L1 then
    Result := 1
  else if L2 > L1 then
    Result := -1
  else
    Result := 0;
end;

function SymbolSortByScopePos(List: TStringList; Index1, Index2: Integer): Integer;
var
  N1, N2, L1, L2: Integer;
begin
  with TSymbolItem(List.Objects[Index1]) do
  begin
    N1 := Tag;
    L1 := ScopeAdjust;
  end;

  with TSymbolItem(List.Objects[Index2]) do
  begin
    N2 := Tag;
    L2 := ScopeAdjust;
  end;

  // N2 = N1 ���ֵļ��ʸߣ���ǰ��
  if N2 = N1 then
  begin
    if L2 < L1 then
      Result := 1
    else if L2 > L1 then
      Result := -1
    else
      Result := 0;
  end
  else if N2 < N1 then
    Result := 1
  else
    Result := -1;
end;

function SymbolSortByLen(List: TStringList; Index1, Index2: Integer): Integer;
var
  S1, S2, L1, L2: Integer;
begin
  S1 := TSymbolItem(List.Objects[Index1]).ScopeHit;
  S2 := TSymbolItem(List.Objects[Index2]).ScopeHit;
  if S2 > S1 then
    Result := 1
  else if S2 < S1 then
    Result := -1
  else
  begin
    L1 := Length(List[Index1]);
    L2 := Length(List[Index2]);
    if L2 < L1 then
      Result := 1
    else if L2 > L1 then
      Result := -1
    else
      Result := CompareText(List[Index1], List[Index2]);
  end;
end;

function SymbolSortByKind(List: TStringList; Index1, Index2: Integer): Integer;
var
  S1, S2, L1, L2: Integer;
begin
  S1 := TSymbolItem(List.Objects[Index1]).ScopeHit;
  S2 := TSymbolItem(List.Objects[Index2]).ScopeHit;
  if S2 > S1 then
    Result := 1
  else if S2 < S1 then
    Result := -1
  else
  begin
    L1 := Ord(TSymbolItem(List.Objects[Index1]).Kind);
    L2 := Ord(TSymbolItem(List.Objects[Index2]).Kind);
    if L2 < L1 then
      Result := 1
    else if L2 > L1 then
      Result := -1
    else
      Result := CompareText(List[Index1], List[Index2]);
  end;
end;

function SymbolSortByText(List: TStringList; Index1, Index2: Integer): Integer;
var
  S1, S2: Integer;
begin
  S1 := TSymbolItem(List.Objects[Index1]).ScopeHit;
  S2 := TSymbolItem(List.Objects[Index2]).ScopeHit;
  if S2 > S1 then
    Result := 1
  else if S2 < S1 then
    Result := -1
  else
    Result := CompareText(List[Index1], List[Index2]);
end;

procedure TCnInputHelper.SortSymbolList;
begin
  case SortKind of
    skByScope:
      FSymbols.CustomSort(SymbolSortByScope);
    skByLength:
      FSymbols.CustomSort(SymbolSortByLen);
    skByKind:
      FSymbols.CustomSort(SymbolSortByKind);
    skByText:
      FSymbols.CustomSort(SymbolSortByText);
  end;
end;

procedure TCnInputHelper.SortCurrSymbolList;
begin
  if (SortKind = skByScope) and FMatchAnyWhere then
    FItems.CustomSort(SymbolSortByScopePos);
end;

procedure TCnInputHelper.UpdateSymbolList;
var
  i, j: Integer;
  S: string;
  Kinds: TSymbolKindSet;
  Item: TSymbolItem;
  SymbolList: TSymbolList;
  Editor: IOTAEditBuffer;
  HashList: TCnSymbolHashList;
begin
  HashList := nil;
  FSymbols.Clear;
  FItems.Clear;
  Editor := CnOtaGetEditBuffer;
  try
    if FRemoveSame then
      HashList := TCnSymbolHashList.Create(csHashListCount);
    
    for i := 0 to SymbolListMgr.Count - 1 do
    begin
      SymbolList := SymbolListMgr.List[i];
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Input Helper To Reload %s. PosKind %s', [SymbolList.ClassName,
        GetEnumName(TypeInfo(TCodePosKind), Ord(FPosInfo.PosKind))]);
{$ENDIF}
      if SymbolList.Active and SymbolList.Reload(Editor, FMatchStr, FPosInfo) then
      begin
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('Input Helper Reload %s Success: %d', [SymbolList.ClassName, SymbolList.Count]);
{$ENDIF}
        // �����������͵õ����õ� KindSet
        if FPosInfo.IsPascal then
          Kinds := csPascalSymbolKindTable[FPosInfo.PosKind] * DispKindSet
        else
          Kinds := csCppSymbolKindTable[FPosInfo.PosKind] * DispKindSet;

        for j := 0 to SymbolList.Count - 1 do
        begin
          Item := SymbolList.Items[j];
          if FPosInfo.IsPascal and not Item.ForPascal then  // Pascal �У������� Pascal��
            Continue;
          if not FPosInfo.IsPascal and not Item.ForCpp then // C/C++ �У������� C/C++��
            Continue;

          S := Item.Name;
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('Input Helper Check Name %s, %s', [S, GetEnumName(TypeInfo(TSymbolKind), Ord(Item.Kind))]);
{$ENDIF}

          if (Item.Kind in Kinds) and (Length(S) >= ListOnlyAtLeastLetter) then
          begin
{$IFDEF DEBUG}
//      CnDebugger.LogMsg('Input Helper is in Kinds. ' + IntToStr(ListOnlyAtLeastLetter));
{$ENDIF}
            if (HashList = nil) or not HashList.CheckExist(Item) then
            begin
              if FAutoAdjustScope and (Item.HashCode <> 0) then
              begin
                Item.ScopeHit := MaxInt div csMaxHitCount *
                  HitCountMgr.GetHitCount(Item.HashCode);
                Item.ScopeAdjust := Item.Scope - Item.ScopeHit;
              end
              else
              begin
                Item.ScopeHit := 0;
                Item.ScopeAdjust := Item.Scope;
              end;
{$IFDEF DEBUG}
//          CnDebugger.LogFmt('Input Helper Add %s with Kind %s', [S, GetEnumName(TypeInfo(TSymbolKind), Ord(Item.Kind))]);
{$ENDIF}
              FSymbols.AddObject(S, Item);
            end;
          end;
        end;
      end;
    end;
  finally
    if HashList <> nil then
      HashList.Free;
  end;
end;

function TCnInputHelper.UpdateCurrList(ForcePopup: Boolean): Boolean;
var
  i, Idx: Integer;
  Symbol: string;
begin
{$IFDEF ADJUST_CodeParamWindow}
  AdjustCodeParamWindowPos;
{$ENDIF}

  List.Items.BeginUpdate;
  try
    Symbol := UpperCase(FMatchStr);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('FMatchStr %s. Symbol %s. FLastStr %s.', [FMatchStr, Symbol, FLastStr]);
{$ENDIF}
    if (Length(Symbol) > 1) and (Length(Symbol) - Length(FLastStr) = 1) and
      (Pos(UpperCase(FLastStr), Symbol) = 1) then
    begin
      for i := FItems.Count - 1 downto 0 do
      begin
        Idx := Pos(Symbol, UpperCase(FItems[i]));
        if (Idx <= 0) or not MatchAnyWhere and (Idx <> 1) then
          FItems.Delete(i)
        else
          TSymbolItem(FItems.Objects[i]).Tag := Idx;
      end;
    end
    else
    begin
      FItems.Clear;
      for i := 0 to FSymbols.Count - 1 do
      begin
        if Symbol <> '' then
          Idx := Pos(Symbol, UpperCase(FSymbols[i]))
        else
          Idx := 1;
        if (Idx = 1) or MatchAnyWhere and (Idx > 0) and
          not TSymbolItem(FSymbols.Objects[i]).MatchFirstOnly then
        begin
          TSymbolItem(FSymbols.Objects[i]).Tag := Idx;
          FItems.AddObject(FSymbols[i], FSymbols.Objects[i]);
        end;
      end;
    end;
    
    SortCurrSymbolList;
    List.SetCount(FItems.Count);

    Result := FItems.Count > 0;
    if Result then
    begin
      Idx := FItems.IndexOf(FToken);
      if (Idx < 0) and (FMatchStr <> '') then
        Idx := FItems.IndexOf(FMatchStr);
      if Idx >= 0 then
        List.ItemIndex := Idx
      else
        List.ItemIndex := 0;
    end;

    FLastStr := FMatchStr;
  finally
    List.Items.EndUpdate;
  end;
end;

function TCnInputHelper.UpdateListBox(ForcePopup, InitPopup: Boolean): Boolean;
var
  CurrPos: Integer;
{$IFNDEF SUPPORT_IDESymbolList}
  AToken: string;
{$ENDIF}
begin
  if CnOtaGetCurrPosToken(FToken, CurrPos, True, CalcFirstSet(FPosInfo.IsPascal), CharSet) or ForcePopup
    or ParsePosInfo and (FPosInfo.PosKind in [pkFieldDot, pkField]) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('InputHelper UpdateListBox. CurrToken: %s, CurrPos: %d', [FToken, CurrPos]);
  {$ENDIF}
    FMatchStr := Copy(FToken, 1, CurrPos);
    Result := UpdateCurrList(ForcePopup);

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('InputHelper UpdateCurrList Returns %d', [Integer(Result)]);
{$ENDIF}

  {$IFNDEF SUPPORT_IDESymbolList}
    // �����֧�� IDE �����б�ֻ�д�ǰ��ƥ��Ĳ���Ч
    if Result then
    begin
      if AnsiPos(UpperCase(FMatchStr), UpperCase(FItems[List.ItemIndex])) <> 1 then
        Result := False;
    end;      
  {$ENDIF}
  end
  else
    Result := False;

  if not Result then
  begin
    HideAndClearList;
  {$IFNDEF SUPPORT_IDESymbolList}
    // �����֧�� IDE �����б�������ƥ����ʱ�л��� IDE ���Զ����
    if not InitPopup and not (FPosInfo.PosKind in [pkUnknown, pkFlat, pkComment,
      pkIntfUses, pkImplUses, pkResourceString, pkCompDirect, pkString]) then
    begin
      if not FPosInfo.IsPascal then
      begin
        // BCB ������£�Ҳ����ʲô���ź󶼵�����Ҫ����һ����
        if ForcePopup then
          ShowIDECodeCompletion
        else
        begin
          CnOtaGetCurrPosToken(AToken, CurrPos, True, CalcFirstSet(FPosInfo.IsPascal), CharSet);
          if (AToken <> '') and (CurrPos > 0) and  not (AToken[CurrPos] in ['+', '-', '*', '/']) then
            ShowIDECodeCompletion;
        end;
      end;
    end;
  {$ENDIF}
  end;
end;

//------------------------------------------------------------------------------
// IDE ��ش���
//------------------------------------------------------------------------------

procedure TCnInputHelper.SendSymbolToIDE(MatchFirstOnly, AutoEnter,
  RepFullToken: Boolean; Key: AnsiChar; var Handled: Boolean);
var
  S: string;
  Len, RL: Integer;
  Item: TSymbolItem;
  DelLeft: Boolean;
  Buffer: IOTAEditBuffer;
  C: Char;
  EditPos: IOTAEditPosition;

  function ItemHasParam(AItem: TSymbolItem): Boolean;
  var
    Desc: string;
  begin
    Result := False;
    if (AItem.Kind in [skFunction, skProcedure, skConstructor, skDestructor])
      and not AItem.AllowMultiLine then
    begin
      Desc := Trim(AItem.Description);
      if FPosInfo.IsPascal then
      begin
        FNoActualParaminCpp := False;
        if (Length(Desc) > 2) and (Desc[1] = '(') and (AnsiPos(')', Desc) > 0) and
          not SameText(Desc, '(...)') then
        Result := True;
      end
      else // C/C++ �ĺ�������Ҫ����
      begin
        Result := True;
        FNoActualParaminCpp := Pos('()', Desc) >= 1; // Desc ����()����Ϊ�޲���
      end;
    end;
  end;

  function CursorIsEOL: Boolean;
  var
    Text: string;
    LineNo, CIndex: Integer;
  begin
    Result := CnNtaGetCurrLineText(Text, LineNo, CIndex) and (CIndex >= Length(Text));
  end;

  function InternalCalcCharSet(IsCpp: Boolean): TAnsiCharSet;
  begin
    if IsCpp then
      Result := CharSet
    else
      Result := CharSet + ['}']; // Pascal �ı���ָ��ĩβ��}Ҳһ���滻��
  end;

begin
  HideList;
  if List.ItemIndex >= 0 then
  begin
    Item := TSymbolItem(FItems.Objects[List.ItemIndex]);
    S := Item.Name;
    if not MatchFirstOnly or (FMatchStr = '') or (Pos(UpperCase(FMatchStr),
      UpperCase(S)) = 1) then
    begin
      DelLeft := True;
      if (FItems.IndexOf(FToken) >= 0) or RepFullToken then
        DelLeft := False
      else
      begin
        // �ж����滻���֮ǰ�����ݻ���������ʶ��
        case OutputStyle of
          osReplaceLeft: DelLeft := True;
          osReplaceAll: DelLeft := False;
          osEnterAll: DelLeft := not AutoEnter;
        else
          // ���������������滻ȫ��
          // 1. ƥ�䳤�Ȳ�С�� 2/3 �ҵ�ǰ�������б���Ȳ�С�� 1/4
          // 2. ƥ�䳤�Ȳ�С�� 1/2 ���ұ� 1/2 ��������ͬ
          Len := Max(Length(S), Length(FToken));
          RL := Max(Len div 2, 2);
          if (Length(FMatchStr) >= Length(FToken) * 2 div 3) and
            (Abs(Length(S) - Length(FToken)) < Len div 4) or
            (Length(FMatchStr) >= Length(FToken) div 2) and
            SameText(StrRight(S, RL), StrRight(FToken, RL)) then
            DelLeft := False;
        end;
      end;

      if DelLeft then
        CnOtaDeleteCurrTokenLeft(CalcFirstSet(FPosInfo.IsPascal), CharSet)
      else
        CnOtaDeleteCurrToken(CalcFirstSet(FPosInfo.IsPascal), CharSet);

      // DONE: �����Pascal����ָ��ҹ����и�}��Ҫ��}ɾ��
      // ���ܼ򵥵��������Charset�м�}����Ϊ�����������ж�
      if FPosInfo.IsPascal and (Item.Kind = skCompDirect) then
      begin
        C := CnOtaGetCurrChar();
{$IFDEF DEBUG}
        CnDebugger.LogChar(C, 'Input Helper Char Under Cursor');
{$ENDIF}
        if C = '}' then
        begin
          EditPos := CnOtaGetEditPosition;
          if Assigned(EditPos) then
          begin
            EditPos.MoveRelative(0, 1);  // �˸�ɾ�����}
            EditPos.BackspaceDelete(1);
          end;
        end;
      end;

      // ����ı�
      Buffer := CnOtaGetEditBuffer;
      if Assigned(Buffer) and Assigned(Buffer.TopView) and
        Assigned(Buffer.EditPosition) then
      begin
        Item.Output(Buffer, Icon, KeywordStyle);
        // �Զ�Ϊ�����������ż����������ʾ
        if AutoCompParam and ItemHasParam(Item) and
          (Buffer.EditPosition.Character <> '(') then
        begin
          Handled := Key in [' ', #13, '(', ';'];
          FSavePos := Buffer.TopView.CursorPos;
          if ((Item.Kind in [skFunction]) or not CursorIsEOL) and (Key <> ';') then
            FBracketText := '()'
          else
            FBracketText := '();';
          CnWizNotifierServices.ExecuteOnApplicationIdle(AutoCompFunc);
        end;
      end;

      // �����ȫƥ����Ϊ�ؼ�������ϻس�
      if AutoEnter and AutoInsertEnter and (CompareStr(FToken, S) = 0) and
        (Item.Kind = skKeyword) then
        SendKey(VK_RETURN);

      // ���ӵ����
      if FAutoAdjustScope and (Item.HashCode <> 0) then
        HitCountMgr.IncHitCount(Item.HashCode);
    end;
  end;
  ClearList;
end;

procedure TCnInputHelper.AutoCompFunc(Sender: TObject);
var
  Buffer: IOTAEditBuffer;
begin
  Buffer := CnOtaGetEditBuffer;
  if Assigned(Buffer) and Assigned(Buffer.TopView) and
    Assigned(Buffer.EditPosition) then
  begin
    Buffer.TopView.CursorPos := FSavePos;
    Buffer.EditPosition.InsertText(FBracketText);
    if not FNoActualParaminCpp then // C/C++ �����������ţ������޲��������㲻���ƶ�����
      Buffer.EditPosition.MoveRelative(0, -(Length(FBracketText) - 1));
    Buffer.TopView.Paint;
    (Buffer.TopView as IOTAEditActions).CodeCompletion(csParamList or csManual);
  end;
end;

//------------------------------------------------------------------------------
// �б���ʾ����
//------------------------------------------------------------------------------

procedure TCnInputHelper.ListDblClick(Sender: TObject);
var
  Handled: Boolean;
begin
  // �����ѡ�񵥴�
  SendSymbolToIDE(False, False, True, #0, Handled);
end;

procedure TCnInputHelper.ListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  AText: string;
  SymbolItem: TSymbolItem;
  TextWith: Integer;
  Kind: Integer;
  Idx, X: Integer;
  S: string;
  SaveColor: TColor;

  function GetHighlightColor(Kind: TSymbolKind): TColor;
  begin
    case Kind of
      skKeyword: Result := csKeywordColor;
      skType: Result := csTypeColor;
    else
      Result := clWindowText;
    end;
  end;
begin
  // �Ի�ListBox�е�SymbolList
  with List do
  begin
    SymbolItem := TSymbolItem(FItems.Objects[Index]);
    Canvas.Font := Font;
    if odSelected in State then
    begin
      Canvas.Font.Color := clHighlightText;
      Canvas.Brush.Color := clHighlight;
    end
    else
    begin
      Canvas.Brush.Color := clWindow;
      Canvas.Font.Color := GetHighlightColor(SymbolItem.Kind);
    end;

    if Ord(SymbolItem.Kind) < dmCnSharedImages.SymbolImages.Count then
      Kind := Ord(SymbolItem.Kind)
    else
      Kind := dmCnSharedImages.SymbolImages.Count - 1;

    Canvas.FillRect(Rect);
    dmCnSharedImages.SymbolImages.Draw(Canvas, Rect.Left + 2, Rect.Top, Kind);
    Canvas.Brush.Style := bsClear;
    Canvas.Font.Style := [fsBold];

    AText := SymbolItem.GetKeywordText(KeywordStyle);
    if MatchAnyWhere and (FMatchStr <> '') then
    begin
      // ������ʾƥ�������
      Idx := Pos(UpperCase(FMatchStr), UpperCase(AText));
      if Idx > 0 then
      begin
        SaveColor := Canvas.Font.Color;
        X := Rect.Left + 22;
        S := Copy(AText, 1, Idx - 1);
        Canvas.TextOut(X, Rect.Top, S);
        Inc(X, Canvas.TextWidth(S));
        Canvas.Font.Color := csMatchColor;
        S := Copy(AText, Idx, Length(FMatchStr));
        Canvas.TextOut(X, Rect.Top, S);
        Inc(X, Canvas.TextWidth(S));
        Canvas.Font.Color := SaveColor;
        S := Copy(AText, Idx + Length(FMatchStr), MaxInt);
        Canvas.TextOut(X, Rect.Top, S);
      end
      else
        Canvas.TextOut(Rect.Left + 22, Rect.Top, AText);
    end
    else
      Canvas.TextOut(Rect.Left + 22, Rect.Top, AText);
    TextWith := Canvas.TextWidth(AText);
    Canvas.Font.Style := [];
    Canvas.TextOut(Rect.Left + 28 + TextWith, Rect.Top, SymbolItem.Description);
  end;
end;

procedure TCnInputHelper.ListItemHint(Sender: TObject; Index: Integer; var
  HintStr: string);
var
  Item: TSymbolItem;
  TextWidth: Integer;
begin
  with List do
  begin
    if ItemIndex >= 0 then
    begin
      Item := TSymbolItem(FItems.Objects[Index]);
      TextWidth := 28;
      Canvas.Font.Style := [fsBold];
      TextWidth := TextWidth + Canvas.TextWidth(Item.Name);
      Canvas.Font.Style := [];
      TextWidth := TextWidth + Canvas.TextWidth(Item.Description);
      if TextWidth > ClientWidth then
        HintStr := Item.Name + Item.Description
      else
        HintStr := '';
    end;
  end;
end;

//------------------------------------------------------------------------------
// �˵����ȼ�����
//------------------------------------------------------------------------------

procedure TCnInputHelper.PopupKeyProc(Sender: TObject);
begin
  if AcceptDisplay and ParsePosInfo then
    ShowList(True);
end;

procedure TCnInputHelper.CreateMenuItem;
var
  Kind: TSymbolKind;
  SortKind: TCnSortKind;

  function NewMenuItem(const ACaption: string; AOnClick: TNotifyEvent;
    ATag: Integer = 0; AImageIndex: Integer = -1;
    ARadioItem: Boolean = False): TMenuItem;
  begin
    Result := TMenuItem.Create(Menu);
    Result.Caption := ACaption;
    Result.OnClick := AOnClick;
    Result.Tag := ATag;
    Result.RadioItem := ARadioItem;
    Result.ImageIndex := AImageIndex;
  end;
begin
  Menu.Images := dmCnSharedImages.SymbolImages;
  Menu.Items.Clear;

  AutoMenuItem := NewMenuItem(SCnInputHelperAutoPopup, Click);
  AutoMenuItem.ShortCut := Action.ShortCut;
  Menu.Items.Add(AutoMenuItem);

  DispBtnMenuItem := NewMenuItem(SCnInputHelperDispButtons, OnDispBtnMenu);
  Menu.Items.Add(DispBtnMenuItem);

  Menu.Items.Add(NewMenuItem('-', nil));

  SortMenuItem := NewMenuItem(SCnInputHelperSortKind, nil);
  for SortKind := Low(TCnSortKind) to High(TCnSortKind) do
    SortMenuItem.Add(NewMenuItem(csSortKindTexts[SortKind]^, OnSortKindMenu,
      Ord(SortKind), -1, True));
  Menu.Items.Add(SortMenuItem);

  IconMenuItem := NewMenuItem(SCnInputHelperIcon, nil);
  for Kind := Low(TSymbolKind) to High(TSymbolKind) do
    IconMenuItem.Add(NewMenuItem(GetSymbolKindName(Kind), OnIconMenu,
      Ord(Kind), Ord(Kind)));
  Menu.Items.Add(IconMenuItem);
  
  Menu.Items.Add(NewMenuItem('-', nil));
  Menu.Items.Add(NewMenuItem(SCnInputHelperAddSymbol, OnAddSymbolMenu));
  Menu.Items.Add(NewMenuItem(SCnInputHelperConfig, OnConfigMenu));
end;

procedure TCnInputHelper.OnPopupMenu(Sender: TObject);
var
  i: Integer;
begin
  AutoMenuItem.Checked := FAutoPopup;
  DispBtnMenuItem.Checked := List.DispButtons;
  SortMenuItem.Items[Ord(FSortKind)].Checked := True;
  for i := 0 to IconMenuItem.Count - 1 do
    IconMenuItem.Items[i].Checked := TSymbolKind(IconMenuItem.Items[i].Tag) in FDispKindSet;
end;

procedure TCnInputHelper.OnDispBtnMenu(Sender: TObject);
begin
  List.DispButtons := not List.DispButtons;
  List.UpdateExtraForm;
end;

procedure TCnInputHelper.OnConfigMenu(Sender: TObject);
begin
  Config;
end;

procedure TCnInputHelper.OnAddSymbolMenu(Sender: TObject);
begin
  HideAndClearList;
  if CnInputHelperAddSymbol(Self, FToken) then
    ConfigChanged;
end;

procedure TCnInputHelper.OnSortKindMenu(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    TMenuItem(Sender).Checked := True;
    FSortKind := TCnSortKind(TMenuItem(Sender).Tag);
    SortSymbolList;
    UpdateCurrList(False);
  end;
end;

procedure TCnInputHelper.OnIconMenu(Sender: TObject);
var
  Kind: TSymbolKind;
begin
  if Sender is TMenuItem then
  begin
    Kind := TSymbolKind(TMenuItem(Sender).Tag);
    if Kind in FDispKindSet then
      Exclude(FDispKindSet, Kind)
    else
      Include(FDispKindSet, Kind);
    UpdateSymbolList;
    UpdateCurrList(False);
  end;
end;

procedure TCnInputHelper.OnBtnClick(Sender: TObject; Button: TCnInputButton);
begin
  case Button of
    ibAddSymbol: OnAddSymbolMenu(nil);
    ibConfig: Config;
    ibHelp: ShowHelp(SCnInputHelperHelpStr);
  end;
end;

//------------------------------------------------------------------------------
// ר�ҷ���
//------------------------------------------------------------------------------

function TCnInputHelper.GetPopupKey: TShortCut;
begin
  Result := FPopupShortCut.ShortCut;
end;

procedure TCnInputHelper.SetPopupKey(const Value: TShortCut);
begin
  FPopupShortCut.ShortCut := Value;
end;

procedure TCnInputHelper.SetAutoPopup(Value: Boolean);
begin
  FAutoPopup := Value;
  Action.Checked := Value;
  AutoMenuItem.Checked := Value;
  if not FAutoPopup and IsShowing then
    HideAndClearList;
{$IFNDEF SUPPORT_IDESymbolList}
  if FCCErrorHook <> nil then
  begin
    if Value and Active then
      FCCErrorHook.HookMethod
    else
      FCCErrorHook.UnHookMethod;
  end;
{$ENDIF}
end;

procedure TCnInputHelper.OnActionUpdate(Sender: TObject);
begin
  Action.Checked := AutoPopup;
end;

procedure TCnInputHelper.Click(Sender: TObject);
begin
  AutoPopup := not AutoPopup;
end;

function TCnInputHelper.GetListFont: TFont;
begin
  Result := List.Font;
end;

function TCnInputHelper.GetCaption: string;
begin
  Result := SCnInputHelperName;
end;

function TCnInputHelper.GetHint: string;
begin
  Result := SCnInputHelperComment;
end;

function TCnInputHelper.GetDefShortCut: TShortCut;
begin
  Result := ShortCut(VK_F2, [ssShift]);
end;

procedure TCnInputHelper.LanguageChanged(Sender: TObject);
begin
  CreateMenuItem;
end;

procedure TCnInputHelper.ConfigChanged;
begin
  SortSymbolList;
  UpdateCurrList(False);
  CreateMenuItem;
  
  DoSaveSettings;
end;

procedure TCnInputHelper.Config;
begin
  HideAndClearList;
  if CnInputHelperConfig(Self{$IFNDEF SUPPORT_IDESymbolList}, True{$ENDIF}) then
    ConfigChanged;
end;

function TCnInputHelper.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnInputHelper.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnInputHelperName;
  Author := SCnPack_JohnsonZhong + ';' + SCnPack_Zjy;
  Email := SCnPack_JohnsonZhongEmail + ';' + SCnPack_ZjyEmail;
  Comment := SCnInputHelperComment;
end;

procedure TCnInputHelper.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    List.Width := ReadInteger('', csWidth, List.Width);
    List.Height := ReadInteger('', csHeight, List.Height);
    List.Font := ReadFont('', csFont, List.Font);
    List.DispButtons := ReadBool('', csDispButtons, True);

    AutoPopup := ReadBool('', csAutoPopup, True);
    FListOnlyAtLeastLetter := ReadInteger('', csListOnlyAtLeastLetter, 1);
    FDispOnlyAtLeastKey := ReadInteger('', csDispOnlyAtLeastKey, 2);
    FDispKindSet := TSymbolKindSet(ReadInteger('', csDispKindSet, Integer(FDispKindSet)));
    FSortKind := TCnSortKind(ReadInteger('', csSortKind, 0));
    FMatchAnyWhere := ReadBool('', csMatchAnyWhere, True);
    FAutoAdjustScope := ReadBool('', csAutoAdjustScope, True);
    FRemoveSame := ReadBool('', csRemoveSame, True);
    FDispDelay := ReadInteger('', csDispDelay, csDefDispDelay);
    FCompleteChars := ReadString('', csCompleteChars, csDefCompleteChars);
    FFilterSymbols.CommaText := ReadString('', csFilterSymbols, csDefFilterSymbols);
    FEnableAutoSymbols := ReadBool('', csEnableAutoSymbols, False);
    FAutoSymbols.CommaText := ReadString('', csAutoSymbols, csDefAutoSymbols);
  {$IFDEF DEBUG}
    CnDebugger.LogStrings(FAutoSymbols, 'FAutoSymbols');
  {$ENDIF}
    FSpcComplete := ReadBool('', csSpcComplete, True);
    FIgnoreSpc := ReadBool('', csIgnoreSpc, False);
    FAutoInsertEnter := ReadBool('', csAutoInsertEnter, True);
    FAutoCompParam := ReadBool('', csAutoCompParam, True);
    FSmartDisplay := ReadBool('', csSmartDisplay, True);
    FOutputStyle := TCnOutputStyle(ReadInteger('', csOutputStyle, Ord(osAuto)));
    FKeywordStyle := TCnKeywordStyle(ReadInteger('', csKeywordStyle, Ord(ksDefault)));
    FSelMidMatchByEnterOnly := ReadBool('', csSelMidMatchByEnterOnly, True);
    FCheckImmRun := ReadBool('', csCheckImmRun, False);
    FDispOnIDECompDisabled := ReadBool('', csDispOnIDECompDisabled, True);

    CreateMenuItem;
  finally
    Free;
  end;

  with CreateIniFile(True) do
  try
    if SupportMultiIDESymbolList then
      UseCodeInsightMgr := ReadBool('', csUseCodeInsightMgr, False);
    if SupportKibitzCompileThread then
      UseKibitzCompileThread := ReadBool('', csUseKibitzCompileThread, False);
  finally
    Free;
  end;
end;

procedure TCnInputHelper.SaveSettings(Ini: TCustomIniFile);
var
  i: Integer;
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    WriteInteger('', csWidth, List.Width);
    WriteInteger('', csHeight, List.Height);
    WriteFont('', csFont, List.Font);
    WriteBool('', csDispButtons, List.DispButtons);

    WriteBool('', csAutoPopup, FAutoPopup);
    WriteInteger('', csListOnlyAtLeastLetter, FListOnlyAtLeastLetter);
    WriteInteger('', csDispOnlyAtLeastKey, FDispOnlyAtLeastKey);
    WriteInteger('', csDispKindSet, Integer(FDispKindSet));
    WriteInteger('', csSortKind, Ord(FSortKind));
    WriteBool('', csMatchAnyWhere, FMatchAnyWhere);
    WriteBool('', csAutoAdjustScope, FAutoAdjustScope);
    WriteBool('', csRemoveSame, FRemoveSame);
    WriteInteger('', csDispDelay, FDispDelay);
    if FCompleteChars = csDefCompleteChars then
      DeleteKey('', csCompleteChars)
    else
      WriteString('', csCompleteChars, FCompleteChars);
    if FFilterSymbols.CommaText = csDefFilterSymbols then
      DeleteKey('', csFilterSymbols)
    else
      WriteString('', csFilterSymbols, FFilterSymbols.CommaText);
    WriteBool('', csEnableAutoSymbols, FEnableAutoSymbols);
    if FAutoSymbols.CommaText = csDefAutoSymbols then
      DeleteKey('', csAutoSymbols)
    else
      WriteString('', csAutoSymbols, FAutoSymbols.CommaText);
    WriteBool('', csSpcComplete, FSpcComplete);
    WriteBool('', csIgnoreSpc, FIgnoreSpc);
    WriteBool('', csAutoInsertEnter, FAutoInsertEnter);
    WriteBool('', csAutoCompParam, FAutoCompParam);

    WriteBool('', csSmartDisplay, FSmartDisplay);
    WriteInteger('', csOutputStyle, Ord(FOutputStyle));
    WriteInteger('', csKeywordStyle, Ord(FKeywordStyle));
    WriteBool('', csSelMidMatchByEnterOnly, FSelMidMatchByEnterOnly);
    WriteBool('', csCheckImmRun, FCheckImmRun);
    WriteBool('', csDispOnIDECompDisabled, FDispOnIDECompDisabled);

    for i := 0 to SymbolListMgr.Count - 1 do
      WriteBool(csListActive, SymbolListMgr.List[i].ClassName,
        SymbolListMgr.List[i].Active);
  finally
    Free;
  end;
  
  with CreateIniFile(True) do
  try
    if SupportMultiIDESymbolList then
      WriteBool('', csUseCodeInsightMgr, UseCodeInsightMgr);
    if SupportKibitzCompileThread then
      WriteBool('', csUseKibitzCompileThread, UseKibitzCompileThread);
  finally
    Free;
  end;
end;

procedure TCnInputHelper.SetActive(Value: Boolean);
begin
  inherited;
{$IFNDEF SUPPORT_IDESymbolList}
  if FCCErrorHook <> nil then
  begin
    if Value and FAutoPopup then
      FCCErrorHook.HookMethod
    else
      FCCErrorHook.UnHookMethod;
  end;
{$ENDIF}
end;

function TCnInputHelper.CalcFirstSet(IsPascal: Boolean): TAnsiCharSet;
begin
  if IsPascal then
    Result := FirstSet
  else
    Result := FirstSet + ['#']; // C/C++�ı�ʶ����Ҫ��#Ҳ����
end;

function TCnInputHelper.IsValidCppArrowKey(VKey: Word; Code: Word): Boolean;
var
  C: AnsiChar;
  AToken: string;
  CurrPos: Integer;
  Option: IOTAEnvironmentOptions;
begin
  Result := False;
  if not FPosInfo.IsPascal and DispOnIDECompDisabled then
  begin
    C := VK_ScanCodeToAscii(VKey, Code);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('IsValidCppArrowKey VK_ScanCodeToAscii: %d %d => %d ("%s")', [VKey, Code, Ord(C), C]);
{$ENDIF}
    if C = '>' then
    begin
      // ��>��if ����µ�ǰһ����ʶ�������һλ��-
      CnOtaGetCurrPosToken(AToken, CurrPos, True, CalcFirstSet(FPosInfo.IsPascal), CharSet);
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Is Valid Cpp Arrow Key: Token: ' + AToken);
{$ENDIF}
      if (Length(AToken) >= 1) and (AToken[Length(AToken)] = '-') then
      begin
        Option := CnOtaGetEnvironmentOptions;
        if not Option.GetOptionValue(csKeyCodeCompletion) then
          Result := True;
      end;
    end;
  end;

end;

procedure TCnInputHelper.DebugComand(Cmds, Results: TStrings);
var
  I, J: Integer;
  List: TSymbolList;
begin
  for I := 0 to FSymbolListMgr.Count - 1 do
  begin
    List := FSymbolListMgr.List[I];
    if List <> nil then
    begin
      Results.Add(IntToStr(I) + '. ' + List.ClassName + ' : Count ' + IntToStr(List.Count));
      for J := 0 to List.Count - 1 do
        Results.Add('  ' + List.Items[J].Name);

      Results.Add('------');
    end;
  end;
end;

initialization
{$IFDEF SUPPORT_INPUTHELPER}
  RegisterCnWizard(TCnInputHelper);
{$ENDIF}

{$ENDIF CNWIZARDS_CNINPUTHELPER}
end.

