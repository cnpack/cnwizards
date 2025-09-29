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

unit CnInputHelper;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ���������ר�Ҵ���
* ��Ԫ���ߣ�Johnson Zhong zhongs@tom.com http://www.longator.com
*           �ܾ��� zjy@cnpack.org
* ��    ע��LSP �첽ģʽ�£���������Ƚ��ռ������룬���� IDE ���ű��첽�ȴ������
*           Ȼ���û��������뵽��ţ����� IDE �����б�ʱ���ǳ����׳��쳣��������
*           �ص�����벢 Cancel �첽�ȴ�����Ҳû�á�
*           ����ĳ����ص�Ų� Application.ProcessMessages �Եȴ����ű��������أ�
* ����ƽ̨��PWin2000Pro + Delphi 7.1
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2018.04.21
*                ֮ǰ֧��ģ��ƥ�䣬���ڽ�ģ��ƥ����ƹ��̳�ȡΪ��������
*           2004.11.05
*               ��ֲ����
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINPUTHELPER}

{$DEFINE SUPPORT_INPUTHELPER}

{$DEFINE SUPPORT_IDESYMBOLLIST}

{$IFDEF BDS}
  {$DEFINE ADJUST_CODEPARAMWINDOW}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, ImgList, Menus, ToolsApi, IniFiles, Math,
  Buttons, TypInfo, mPasLex, AppEvnts, Contnrs, Clipbrd,
  {$IFDEF OTA_CODE_TEMPLATE_API} CodeTemplateAPI, {$ENDIF}
  CnConsts, CnCommon, CnWizClasses, CnWizConsts, CnWizUtils, CnWizIdeUtils,
  CnInputSymbolList, CnInputIdeSymbolList, CnIni, CnWizMultiLang, CnWizNotifier,
  CnPasCodeParser, CnCppCodeParser, CnEventBus,
  {$IFDEF UNICODE} CnWidePasParser, CnWideCppParser, {$ENDIF}
  CnWizShareImages, CnWizShortCut, CnWizOptions, CnFloatWindow,
  CnEditControlWrapper, CnWizMethodHook, CnPopupMenu, CnStrings, CnWideStrings;

const
  csMinDispDelay = 50;
  csDefDispDelay = 250;
  csDefCompleteChars = '%&,;()[]<>=';
  csDefFilterSymbols = '//,{';
  csDefAutoSymbols = '" := "," <> "," = "," > "," >= "," < "," <= "';

type
  TCnInputHelper = class;

  TCnInputButton = (ibAddSymbol, ibConfig, ibHelp);

  TCnItemHintEvent = procedure (Sender: TObject; Index: Integer;
    var HintStr: string) of object;

  TBtnClickEvent = procedure (Sender: TObject; Button: TCnInputButton) of object;

{ TCnInputListBox }

  TCnInputListBox = class(TCnFloatListBox)
  private
    FLastItem: Integer;
    FOnItemHint: TCnItemHintEvent;
    FOnButtonClick: TBtnClickEvent;
    FBtnForm: TCnFloatWindow;
    FHintForm: TCnFloatWindow;
    FHintCnt: Integer;
    FHintTimer: TTimer;
    FDispButtons: Boolean;
{$IFDEF IDE_MAINFORM_EAT_MOUSEWHEEL}
    FMethodHook: TCnMethodHook;
{$ENDIF}
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure WMSize(var Message: TMessage); message WM_SIZE;
    procedure WMMove(var Message: TMessage); message WM_MOVE;
    procedure CreateExtraForm;
    procedure UpdateExtraForm;
    procedure UpdateExtraFormLang;
    procedure OnBtnClick(Sender: TObject);
    procedure OnHintPaint(Sender: TObject);
    procedure OnHintTimer(Sender: TObject);
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetPos(X, Y: Integer); override;
    procedure CloseUp; override;
    procedure Popup; override;

{$IFDEF IDE_MAINFORM_EAT_MOUSEWHEEL}
    procedure MouseWheelHandler(var Message: TMessage); override;
{$ENDIF}
    property DispButtons: Boolean read FDispButtons write FDispButtons;
    property BtnForm: TCnFloatWindow read FBtnForm;
    property HintForm: TCnFloatWindow read FHintForm;
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

  PCnSymbolItemArray = ^TCnSymbolItemArray;
  TCnSymbolItemArray = array[0..65535] of TCnSymbolItem;

  TCnSymbolHashList = class(TObject)
  private
    FCount: Integer;
    FList: PCnSymbolItemArray;
  public
    constructor Create(ACount: Integer);
    destructor Destroy; override;
    function CheckExist(AItem: TCnSymbolItem): Boolean;
  end;

{ TCnInputHelper }

  // �б�����ʽ���Զ����ı�˳�򡢳��ȡ�����
  TCnSortKind = (skByScope, skByText, skByLength, skByKind);

  // �����ʶ��ʱ���������м�λ�õĴ�����
  TCnOutputStyle = (osAuto, osReplaceLeft, osReplaceAll, osEnterAll);

  TCnInputHelper = class(TCnActionWizard)
  private
    List: TCnInputListBox;
    FListFont: TFont;      // �������õ�����
    Timer: TTimer;
    AppEvents: TApplicationEvents;
    Menu: TPopupMenu;
    AutoMenuItem: TMenuItem;
    DispBtnMenuItem: TMenuItem;
    SortMenuItem: TMenuItem;
    IconMenuItem: TMenuItem;
    FHitCountMgr: TCnSymbolHitCountMgr;
    FSymbolListMgr: TCnSymbolListMgr;
    FirstSet: TAnsiCharSet;  // ���� Symbol ����ʼ�ַ��ĺϷ� CharSet �Ĳ���
    CharSet: TAnsiCharSet;   // ���� Symbol �ĺϷ� CharSet �Ĳ���
{$IFDEF IDE_SUPPORT_LSP}
    FAutoPopupLSP: Boolean;
{$ELSE}
    FAutoPopup: Boolean;
{$ENDIF}
    FToken: string;
    FMatchStr: string;     // ��ǰ����ƥ��� Pattern���ӱ༭������»�ȡ����
    FLastStr: string;      // ��һ��ƥ��� FMatchStr
    FSymbols: TStringList; // ��ǰ����ʱ���з�����������Ŀ���� Symbol
    FItems: TStringList;   // ��ǰ����������ʾ����Ŀ�� Symbol
    FKeyCount: Integer;
    FKeyQueue: string;
    FCurrLineText: string;
    FCurrLineNo: Integer;
    FCurrIndex: Integer;
    FCurrLineLen: Integer;
    FKeyDownTick: Cardinal;
    FKeyDownValidStack: TStack;
    FNeedUpdate: Boolean;
    FKeyBackSpaceADot: Boolean;
    FPosInfo: TCodePosInfo;
    FSavePos: TOTAEditPos;
    FBracketText: string;
    FNoActualParaminCpp: Boolean;
    FPopupShortCut: TCnWizShortCut;
    FListOnlyAtLeastLetter: Integer;
    FDispOnlyAtLeastKey: Integer;
    FSortKind: TCnSortKind;
    FDispDelay: Cardinal;
    FMatchMode: TCnMatchMode;
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
    FTabComplete: Boolean;
    FIgnoreDot: Boolean;
    FIgnoreSpc: Boolean;
    FAutoAdjustScope: Boolean;
    FDispKindSet: TCnSymbolKindSet;
    FRemoveSame: Boolean;
    FKeywordStyle: TCnKeywordStyle;
    FUseEditorColor: Boolean;
    FSymbolReloading: Boolean;
{$IFNDEF SUPPORT_IDESYMBOLLIST}
    // �����֧�� IDE �����б���Ҫ�ҵ� Cppcodcmplt::TCppKibitzManager::CCError
    FCCErrorHook: TCnMethodHook;
{$ENDIF}
{$IFDEF ADJUST_CODEPARAMWINDOW}
    FCodeWndProc: TWndMethod;
{$ENDIF}
    function AcceptDisplay: Boolean;
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure ActiveControlChanged(Sender: TObject);
    procedure OnTimer(Sender: TObject);
    procedure OnAppDeactivate(Sender: TObject);
    function GetIsShowing: Boolean;
    function ParsePosInfo: Boolean;
    procedure ShowList(ForcePopup: Boolean);  // �����б�
    procedure HideList;                       // �����б�
    procedure ClearList;                      // ����б�����
    procedure HideAndClearList;
{$IFDEF ADJUST_CODEPARAMWINDOW}
    procedure CodeParamWndProc(var Message: TMessage);
    procedure HookCodeParamWindow(Wnd: TWinControl);
    procedure AdjustCodeParamWindowPos;
{$ENDIF}
    function HandleKeyDown(var Msg: TMsg): Boolean;  // ͨ�� Application.OnMessage ���� WM_KEYDOWN ��Ϣ
    function HandleKeyUp(var Msg: TMsg): Boolean;    // ͨ�� Application.OnMessage ���� WM_KEYUP ��Ϣ
    function HandleKeyPress(Key: AnsiChar): Boolean; // ���ǿؼ��¼����أ����� HandleKeyDown ת������
    procedure SortSymbolList;
    procedure SortCurrSymbolList;
    function UpdateCurrList(ForcePopup: Boolean): Boolean;
    // �� FSymbols ��������ƥ��ķ����б����� FItems��FSymbols �����»�ȡ
    function UpdateListBox(ForcePopup, InitPopup: Boolean): Boolean;
    // �����Ѿ������Ĵ����������ֿ�������ݣ����������� UpdateCurrList
    procedure UpdateSymbolList;  // ȡ��������Ҫ�ķ����б����� FSymbols
    procedure ListDblClick(Sender: TObject);
    procedure ListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure ListItemHint(Sender: TObject; Index: Integer; var HintStr: string);
    procedure PopupKeyProc(Sender: TObject);
    procedure OnPopupMenu(Sender: TObject);
    procedure CreateMenuItem;
{$IFDEF IDE_SUPPORT_LSP}
    procedure SetAutoPopupLSP(Value: Boolean);
{$ELSE}
    procedure SetAutoPopup(Value: Boolean);
{$ENDIF}
    procedure OnDispBtnMenu(Sender: TObject);
    procedure OnConfigMenu(Sender: TObject);
    procedure OnCopyMenu(Sender: TObject);
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
    // ��ǰ�����ǵ��� IDE �����˵㵯������ȡ���㵯�ŷ��� True
    function IsValidCppPopupKey(VKey: Word; Code: Word): Boolean;
    function IsValidKeyQueue: Boolean;
    function CalcFirstSet(Orig: TAnsiCharSet; IsPascal: Boolean): TAnsiCharSet;
    function CalcCharSet(Orig: TAnsiCharSet; PosInfo: PCodePosInfo): TAnsiCharSet;
    procedure AutoCompFunc(Sender: TObject);
    procedure ConfigChanged;
    // ���º����ö�ջ������ʵ�� FKeyDownValid �Ļ����Ա����û��ÿ��˵���
    // ������ KeyDown ������ Up �Ӷ��ڶ��� Up �������õ�����
    function GetKeyDownValid: Boolean;
    procedure SetKeyDownValid(Value: Boolean);

    function GetPopupKey: TShortCut;
    procedure SetPopupKey(const Value: TShortCut);
    procedure SetListFont(const Value: TFont);
    procedure SetUseEditorColor(const Value: Boolean);
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
    procedure Click(Sender: TObject); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure OnActionUpdate(Sender: TObject); override;
    procedure BroadcastShortCut;
    procedure UpdateListFont;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    procedure Loaded; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    procedure LanguageChanged(Sender: TObject); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;
    function GetGeneralAutoPopup: Boolean;
    procedure SendSymbolToIDE(MatchFirstOnly, AutoEnter, RepFullToken: Boolean;
      Key: AnsiChar; var Handled: Boolean);
    procedure ShowIDECodeCompletion;
    procedure DebugComand(Cmds: TStrings; Results: TStrings); override;

    property IsShowing: Boolean read GetIsShowing;
    property ListFont: TFont read FListFont write SetListFont;
    property HitCountMgr: TCnSymbolHitCountMgr read FHitCountMgr;
    property SymbolListMgr: TCnSymbolListMgr read FSymbolListMgr;

{$IFDEF IDE_SUPPORT_LSP}
    property AutoPopupLSP: Boolean read FAutoPopupLSP write SetAutoPopupLSP default True;
    {* LSP ģʽ���Ƿ��Զ�������������}
{$ELSE}
    property AutoPopup: Boolean read FAutoPopup write SetAutoPopup default True;
    {* ��ͨģʽ���Ƿ��Զ�������������}
{$ENDIF}
    property PopupKey: TShortCut read GetPopupKey write SetPopupKey;
    {* �Զ�������ݼ�}
    property ListOnlyAtLeastLetter: Integer read FListOnlyAtLeastLetter write
      FListOnlyAtLeastLetter default 1;
    {* ��ʾ�ڷ����б��е���С���ų���}
    property DispOnlyAtLeastKey: Integer read FDispOnlyAtLeastKey write
      FDispOnlyAtLeastKey default 2;
    {* �����б�ʱ��Ҫ�����������Ч������}
    property DispKindSet: TCnSymbolKindSet read FDispKindSet write FDispKindSet;
    {* ������ʾ�ķ�������}
    property SortKind: TCnSortKind read FSortKind write FSortKind default skByScope;
    {* �б���������}
    property MatchMode: TCnMatchMode read FMatchMode write FMatchMode;
    {* ��ʶ��ƥ��ģʽ}
    property DispDelay: Cardinal read FDispDelay write FDispDelay default csDefDispDelay;
    {* �б�����ʱ ms ��}
    property DispOnIDECompDisabled: Boolean read FDispOnIDECompDisabled write
      FDispOnIDECompDisabled default True;
    {* ������ IDE ���Զ����ʱ���Զ������� . �ź󵯳�}
    property AutoAdjustScope: Boolean read FAutoAdjustScope write FAutoAdjustScope
      default True;
    {* �Զ�������ʾ���ȼ� }
    property RemoveSame: Boolean read FRemoveSame write FRemoveSame;
    {* ֻ��ʾΨһ�ķ��ţ������ظ����ֵ���Ŀ }
    property CompleteChars: string read FCompleteChars write FCompleteChars;
    {* ��������ɵ�ǰ��ѡ����ַ��б�ע�����ﲻ���� . �ţ���Ϊ����漰 IDE ���Զ������Ҫ���⴦��}
    property FilterSymbols: TStrings read FFilterSymbols;
    {* ��ֹ�Զ������б�ķ���}
    property EnableAutoSymbols: Boolean read FEnableAutoSymbols write FEnableAutoSymbols default False;
    property AutoSymbols: TStrings read FAutoSymbols;
    {* �Զ������б�ķ��� }
    property SpcComplete: Boolean read FSpcComplete write FSpcComplete default True;
    {* �ո��Ƿ���������ѡ�� }
    property TabComplete: Boolean read FTabComplete write FTabComplete default True;
    {* Tab �Ƿ���������ѡ�� }
    property IgnoreDot: Boolean read FIgnoreDot write FIgnoreDot default False;
    {* �Ƿ���õ�ŵ����뵱ǰ��Ŀ�Ĺ��ܣ�������������������û�к�ѡ�б�ʱ��Ĭ�ϵ�Ȼ������}
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
    property UseEditorColor: Boolean read FUseEditorColor write SetUseEditorColor;
    {* �Ƿ��Զ�ʹ�ñ༭����ɫ}
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
  MY_VK_DOT_KEY = 190;

{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
  CN_PINYIN_DELTA = 12;
{$ELSE}
  CN_PINYIN_DELTA = 0;
{$ENDIF}

  // BCB �³����ĵ�ַ
  SCppKibitzManagerCCError = '@Cppcodcmplt@TCppKibitzManager@CCError$qqrp20System@TResStringRec';

  csLineHeight = 16;
  csMinDispItems = 5;
  csDefDispItems = 6;
  csMinDispWidth = 150;
  csDefDispWidth = 300;

  csMaxProcessLines = 1000;

  csTypeColor = clNavy;
  csDarkKeywordColor = $0000C0FF; // ǳ��
  csDarkTypeColor = clAqua;       // ǳ��

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
{$IFDEF IDE_SUPPORT_LSP}
  csAutoPopupLSP = 'AutoPopupLSP';
{$ELSE}
  csAutoPopup = 'AutoPopup';
{$ENDIF}
  csListOnlyAtLeastLetter = 'ListOnlyAtLeastLetter';
  csDispOnlyAtLeastKey = 'DispOnlyAtLeastKey';
  csDispKindSet = 'DispKindSet';
  csDispDelay = 'DispDelay';
  csSortKind = 'SortKind';
  csMatchMode = 'MatchMode';
  csCompleteChars = 'CompleteCharSet';
  csFilterSymbols = 'FilterSymbols';
  csEnableAutoSymbols = 'EnableAutoSymbols';
  csAutoSymbols = 'AutoSymbols';
  csSpcComplete = 'SpcComplete';
  csTabComplete = 'TabComplete';
  csIgnoreDot = 'IgnoreDot';
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
  csUseEditorColor = 'UseEditorColor';

{$IFDEF COMPILER6_UP}
  csKibitzWindowClass = 'TCodeCompleteListView';
{$ELSE}
  csKibitzWindowClass = 'TPopupListBox';
{$ENDIF COMPILER6_UP}
  csKibitzWindowName = 'KibitzWindow';

  // ���������ʾС�ƿ�������������
  csCodeParamWindowClassName = 'TTokenWindow';
{$IFDEF DELPHI104_SYDNEY_UP}
  csCodeParamWindowName = 'TokenWindow';
{$ELSE}
  csCodeParamWindowName = 'CodeParamWindow';
{$ENDIF}

  csKeyCodeCompletion = 'CodeCompletion';

  // ͼ�꼯������
  csAllSymbolKind = [Low(TCnSymbolKind)..High(TCnSymbolKind)];
  csNoneSymbolKind = [];
  csCompDirectSymbolKind = [skCompDirect];
  csCommentSymbolKind = [skComment];
  csUnitSymbolKind = [skUnit, skCompDirect];
  csDeclareSymbolKind = csAllSymbolKind - [skUnknown, skLabel];
  csDefineSymbolKind = csAllSymbolKind - [skUnknown, {skUnit,} skLabel]; // ������Ҳ�������뵥Ԫ��
  csCodeSymbolKind = csAllSymbolKind;
  csFieldSymbolKind = csAllSymbolKind - [skUnknown,
    {skUnit,} skLabel, skInterface, skKeyword, skClass, skUser];
  // 2005 ��֧�� class constant �� class type�����Բ���ȥ�� skConstant, skType,

  // BCB �в������� Field���ɴ�͵�ͬ�� Code��
  csCppFieldSymbolKind = csAllSymbolKind;

  csPascalSymbolKindTable: array[TCodePosKind] of TCnSymbolKindSet = (
    csNoneSymbolKind,          // δ֪��Ч��
    csAllSymbolKind,           // ��Ԫ�հ���
    csCommentSymbolKind,       // ע�Ϳ��ڲ�
    csUnitSymbolKind,          // interface �� uses �ڲ�
    csUnitSymbolKind,          // implementation �� uses �ڲ�
    csDeclareSymbolKind,       // class �����ڲ�
    csDeclareSymbolKind,       // interface �����ڲ�
    [],                        // type �������Ⱥ�ǰ����
    csDefineSymbolKind,        // type �������Ⱥź󲿷�
    [],                        // const ������ð�ŵȺ�ǰ����
    csDefineSymbolKind,        // const ������ð�ŵȺź󲿷�
    csDefineSymbolKind,        // resourcestring ������
    [],                        // var ������ð��ǰ����
    csDefineSymbolKind,        // var ������ð�ź󲿷�
    csCompDirectSymbolKind,    // ����ָ���ڲ�
    csNoneSymbolKind,          // �ַ����ڲ�
    csFieldSymbolKind,         // ��ʶ��. ��������ڲ������ԡ��������¼�����¼��ȣ�C/C++Դ�ļ��󲿷ֶ��ڴ�
    csCodeSymbolKind,          // �����ڲ�
    csCodeSymbolKind,          // �����ڲ�
    csCodeSymbolKind,          // �������ڲ�
    csCodeSymbolKind,          // �������ڲ�
    csFieldSymbolKind,         // ������ĵ�

    csNoneSymbolKind);         // C ����������

  csCppSymbolKindTable: array[TCodePosKind] of TCnSymbolKindSet = (
    csNoneSymbolKind,          // δ֪��Ч��
    csAllSymbolKind,           // ��Ԫ�հ���
    csCommentSymbolKind,       // ע�Ϳ��ڲ�
    csUnitSymbolKind,          // interface �� uses �ڲ�
    csUnitSymbolKind,          // implementation �� uses �ڲ�
    csDeclareSymbolKind,       // class �����ڲ�
    csDeclareSymbolKind,       // interface �����ڲ�
    csDefineSymbolKind,        // type ������
    csDefineSymbolKind,        // type ������
    csDefineSymbolKind,        // const ������
    csDefineSymbolKind,        // const ������
    csDefineSymbolKind,        // resourcestring ������
    csDefineSymbolKind,        // var ������
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

//{$IFDEF SUPPORT_UNITNAME_DOT}
//  csUnitDotPrefixes: array[0..14] of string = (
//    'Vcl', 'Xml', 'System', 'Winapi', 'Soap', 'FMX', 'Data', 'Posix', 'Macapi',
//    'DataSnap', 'FireDAC', 'REST', 'VCLTee', 'Web', 'IBX'
//  );
//{$ENDIF}

{$IFNDEF SUPPORT_IDESYMBOLLIST}

  TSCppKibitzManagerCCError = procedure (Rec: PResStringRec); // TResStringRec

procedure MyCCError(Rec: PResStringRec);
begin
  // ɶ������
  Rec := Rec;
end;

{$ENDIF}

{$IFDEF IDE_MAINFORM_EAT_MOUSEWHEEL}

function MyGetParentForm(Control: TControl; TopForm: Boolean): TCustomForm;
begin
  Result := nil;
end;

{$ENDIF}

//==============================================================================
// �����б��
//==============================================================================

{ TCnInputListBox }

procedure TCnInputListBox.CloseUp;
begin
  inherited;
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

constructor TCnInputListBox.Create(AOwner: TComponent);
begin
  inherited;
  FLastItem := -1;

  Constraints.MinHeight := IdeGetScaledPixelsFromOrigin(WizOptions.CalcIntEnlargedValue(WizOptions.SizeEnlarge, ItemHeight * csMinDispItems + 4));
  Constraints.MinWidth := IdeGetScaledPixelsFromOrigin(WizOptions.CalcIntEnlargedValue(WizOptions.SizeEnlarge, csMinDispWidth));
  Height := IdeGetScaledPixelsFromOrigin(WizOptions.CalcIntEnlargedValue(WizOptions.SizeEnlarge, ItemHeight * csDefDispItems + 8));
  Width := IdeGetScaledPixelsFromOrigin(WizOptions.CalcIntEnlargedValue(WizOptions.SizeEnlarge, csDefDispWidth));

  CreateExtraForm;
{$IFDEF IDE_MAINFORM_EAT_MOUSEWHEEL}
  FMethodHook := TCnMethodHook.Create(GetBplMethodAddress(@GetParentForm), @MyGetParentForm);
  FMethodHook.UnhookMethod;
{$ENDIF}
end;

procedure TCnInputListBox.CreateExtraForm;
var
  Btn: TCnInputButton;
  SpeedBtn: TSpeedButton;
begin
  FBtnForm := TCnFloatWindow.Create(Self);
  BtnForm.Parent := Application.MainForm;
  BtnForm.Visible := False;
  BtnForm.Width := IdeGetScaledPixelsFromOrigin(csBtnWidth);
  BtnForm.Height := IdeGetScaledPixelsFromOrigin(csBtnHeight * (Ord(High(TCnInputButton)) + 1));
  for Btn := Low(Btn) to High(Btn) do
  begin
    SpeedBtn := TSpeedButton.Create(BtnForm);
    SpeedBtn.Parent := BtnForm;
    SpeedBtn.SetBounds(0, IdeGetScaledPixelsFromOrigin(Ord(Btn) * csBtnHeight),
      IdeGetScaledPixelsFromOrigin(csBtnWidth), IdeGetScaledPixelsFromOrigin(csBtnHeight));
    SpeedBtn.Tag := Ord(Btn);
    SpeedBtn.ShowHint := True;
    SpeedBtn.Hint := StripHotkey(SCnInputButtonHints[Btn]^);
    SpeedBtn.OnClick := OnBtnClick;
    dmCnSharedImages.ilInputHelper.GetBitmap(Ord(Btn), SpeedBtn.Glyph);
    CnEnlargeButtonGlyphForHDPI(SpeedBtn);
  end;

  FHintForm := TCnFloatWindow.Create(Self);
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

destructor TCnInputListBox.Destroy;
begin
  try
{$IFDEF IDE_MAINFORM_EAT_MOUSEWHEEL}
    FMethodHook.Free;
{$ENDIF}
    inherited;
  except
    ;  // ��ͼץס No Parent Window �� Exception��������
  end;
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

{$IFDEF IDE_MAINFORM_EAT_MOUSEWHEEL}

procedure TCnInputListBox.MouseWheelHandler(var Message: TMessage);
begin
  FMethodHook.HookMethod;
  inherited;
  FMethodHook.UnHookMethod;
end;

{$ENDIF}

procedure TCnInputListBox.OnBtnClick(Sender: TObject);
begin
  if (Sender is TSpeedButton) and Assigned(FOnButtonClick) then
  begin
    FOnButtonClick(Sender, TCnInputButton(TSpeedButton(Sender).Tag));
  end;
end;

procedure TCnInputListBox.OnHintPaint(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  with HintForm do
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Font := Self.Font;
    Canvas.Font.Color := clInfoText;
    S := '';
    for I := 0 to FHintCnt do
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
  inherited;
  UpdateExtraFormLang;
  UpdateExtraForm;
end;

procedure TCnInputListBox.SetPos(X, Y: Integer);
begin
  inherited;
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
  I: Integer;
begin
  if DispButtons then
    for I := 0 to BtnForm.ComponentCount - 1 do
      if BtnForm.Components[I] is TSpeedButton then
        with TSpeedButton(BtnForm.Components[I]) do
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
  I: Integer;
  P: PSymbolHitCountItem;
begin
  for I := 0 to FList.Count - 1 do
  begin
    P := PSymbolHitCountItem(FList[I]);
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
  I: Integer;
  P: PSymbolHitCountItem;
begin
  for I := FList.Count - 1 downto 0 do
  begin
    P := PSymbolHitCountItem(FList[I]);
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
        FList.Delete(I);
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
  I: Integer;
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

        for I := 0 to (Stream.Size - Stream.Position) div
          SizeOf(TSymbolHitCountItem) - 1 do
        begin
          New(Item);
          Stream.Read(Item^, SizeOf(TSymbolHitCountItem));
          FList.Add(Item);
        end;

        // �����������ڰ汾��������б�
        FList.Sort(DoHashCodeSort);
        for I := FList.Count - 1 downto 1 do
          if PSymbolHitCountItem(FList[I]).HashCode =
            PSymbolHitCountItem(FList[I - 1]).HashCode then
            FList.Delete(I);
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
  I: Integer;
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

      for I := 0 to FList.Count - 1 do
      begin
        if Stream.Write(Items[I]^, SizeOf(TSymbolHitCountItem)) <>
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

function TCnSymbolHashList.CheckExist(AItem: TCnSymbolItem): Boolean;
var
  I, Idx: Integer;
  Hash: Cardinal;
begin
  Result := False;
  Hash := AItem.HashCode;
  for I := 0 to FCount - 1 do
  begin
    Idx := (Integer(Hash) + I) mod FCount;
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
  Size := FCount * SizeOf(TCnSymbolItem);
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
{$IFNDEF SUPPORT_IDESYMBOLLIST}
var
  DphIdeModule: HMODULE;
{$ENDIF}
begin
  inherited;
  FUseEditorColor := True;

  FListFont := TFont.Create;
  List := TCnInputListBox.Create(nil);
  List.Name := 'CnInputListBox';
  List.Parent := Application.MainForm;
  List.OnDrawItem := ListDrawItem;
  List.OnDblClick := ListDblClick;
  List.OnItemHint := ListItemHint;
  List.OnButtonClick := OnBtnClick;
  List.UseEditorColor := FUseEditorColor;

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
  FSymbolListMgr := TCnSymbolListMgr.Create;
  FKeyDownValidStack := TStack.Create;

  FSymbols := TStringList.Create;
  FItems := TStringList.Create;
  FPopupShortCut := WizShortCutMgr.Add(SCnInputHelperPopup,
    ShortCut(VK_DOWN, [ssAlt]), PopupKeyProc);

  FDispKindSet := csAllSymbolKind;

{$IFDEF IDE_SUPPORT_LSP}
  AutoPopupLSP := True;
{$ELSE}
  AutoPopup := True;
{$ENDIF}

{$IFNDEF SUPPORT_IDESYMBOLLIST}
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

{$IFNDEF SUPPORT_IDESYMBOLLIST}
  FCCErrorHook.Free;
{$ENDIF}

  WizShortCutMgr.DeleteShortCut(FPopupShortCut);
  FKeyDownValidStack.Free;
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
  FListFont.Free;
  inherited;
end;

procedure TCnInputHelper.Loaded;
var
  I: Integer;
begin
  inherited;
  // ��ʼ�������б������
  SymbolListMgr.InitList;

  // װ�ػ����
  with CreateIniFile do
  try
    for I := 0 to SymbolListMgr.Count - 1 do
      SymbolListMgr.List[I].Active := ReadBool(csListActive,
        SymbolListMgr.List[I].ClassName, True);
  finally
    Free;
  end;

  SymbolListMgr.GetValidCharSet(FirstSet, CharSet, FPosInfo);
  BroadcastShortCut;
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
    {$ELSE} // D7 �����£����� BCB5/6
    Result := CurrentIsSource;
    {$ENDIF}
  end;

begin
  Result := Active and IsEditControl(Screen.ActiveControl) and
    (not CheckImmRun or not IMMIsActive) and CanPopupInCurrentSourceType and
    not IsAutoCompleteActive and not IsReadOnly and not CnOtaIsDebugging and
    not IsInIncreSearch and not IsInMacroOp and not GetCodeTemplateListBoxVisible;
end;

procedure TCnInputHelper.ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
begin
  if ((Msg.message >= WM_KEYFIRST) and (Msg.message <= WM_KEYLAST)) or
    (Msg.message = WM_MOUSEWHEEL) then
  begin
//{$IFDEF IDE_SUPPORT_LSP}
//    if FSymbolReloading then
//    begin
//      // ������첽���ط��ű���Ӧ�ý���ؼ�����Ϣ�ͺ����Ա���©��Ϣ
//      // ��������Ϊ��Ϣ���пն�������ѭ��������洢��Ϣ�� Reloading �������ٴ���
//      // �ֻ����������Ϣ���̫�����¶���������ַ������⣬
//      �������ջ��ǵ�ע�͵�������
//      PostMessage(Msg.hwnd, Msg.message, Msg.wParam, Msg.lParam);
//      Handled := True;
//      Exit;
//    end;
//{$ENDIF}
    if AcceptDisplay then
    begin
      case Msg.message of
        WM_KEYDOWN:
          if not Handled then // ������Ϊ�˱�������ר���Ѿ�ͨ�� OnMessage �¼��������
            Handled := HandleKeyDown(Msg);
        WM_KEYUP:
          if not Handled then // ������Ϊ�˱�������ר���Ѿ�ͨ�� OnMessage �¼��������
            Handled := HandleKeyUp(Msg);
        WM_MOUSEWHEEL:
          if IsShowing then
          begin
            SendMessage(List.Handle, Msg.message, Msg.wParam, Msg.lParam);
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
    Result := CharInSet(C, CalcFirstSet(FirstSet, FPosInfo.IsPascal))
  else
    Result := CharInSet(C, CharSet);
end;

function TCnInputHelper.IsValidSymbol(Symbol: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Symbol <> '' then
  begin
    for I := 1 to Length(Symbol) do
      if not IsValidSymbolChar(Symbol[I], I = 1) then
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
    Result := C in (FirstSet + CharSet)
  else // C/C++ ���� -> ���� # ��
    Result := C in (FirstSet + ['>', '#'] + CharSet);
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
  if DispOnIDECompDisabled and ((Key = VK_DECIMAL) or (Key = MY_VK_DOT_KEY)) then
  begin
    Option := CnOtaGetEnvironmentOptions;
    if not Option.GetOptionValue(csKeyCodeCompletion) then
      Result := True;
  end;
end;

function TCnInputHelper.IsValidKeyQueue: Boolean;
var
  I: Integer;
begin
  Result := False;
  if FEnableAutoSymbols then
  begin
    for I := 0 to FAutoSymbols.Count - 1 do
    begin
      if SameText(FAutoSymbols[I], StrRight(FKeyQueue, Length(FAutoSymbols[I]))) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

// ���� KeyDown �¼�����������б���ʾ���жϲ����룬��δ������ת���� KeyPress �����б�ʱ����
// ���б�δ��ʾ�����¼����״̬׼��������ʾ
function TCnInputHelper.HandleKeyDown(var Msg: TMsg): Boolean;
var
  Shift: TShiftState;
  ScanCode: Word;
  Key: Word;
  KeyDownChar: AnsiChar;
  ShouldIgnore: Boolean;
{$IFDEF IDE_SUPPORT_LSP}
  Option: IOTAEnvironmentOptions;
{$ENDIF}
{$IFDEF IDE_SYNC_EDIT_BLOCK}
  ShouldEatTab: Boolean;
{$ENDIF}
begin
  Result := False;
{$IFDEF IDE_SUPPORT_LSP}
  if FSymbolReloading then // ��ֹ�����첽�ȴ����ű�ʱ����
  begin
    // ��ǰ����Ƿ��ǵ��
    Key := Msg.wParam;
    if not CheckImmRun and (Key = VK_PROCESSKEY) then
    begin
      ScanCode := (Msg.lParam and $00FF0000) shr 16;
      Key := MapVirtualKey(ScanCode, 1);
    end;

    if (Key = VK_DECIMAL) or (Key = MY_VK_DOT_KEY) then
    begin
      Option := CnOtaGetEnvironmentOptions;
      if Option.GetOptionValue(csKeyCodeCompletion) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnInputHelper.HandleKeyDown. SymbolReloading and DotKey Should IDE CodeInsight. Cancel Ours.');
        SymbolListMgr.Cancel;
        HideAndClearList;
{$ENDIF}
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnInputHelper.HandleKeyDown. SymbolReloading Exit.');
{$ENDIF}
    Exit;
  end;
{$ENDIF}

  Key := Msg.wParam;
  Shift := KeyDataToShiftState(Msg.lParam);
  ScanCode := (Msg.lParam and $00FF0000) shr 16;
  FKeyBackSpaceADot := False;

  // ����������뷨����ʱҲ���룬��ʹ��ɨ�������������
  if not CheckImmRun and (Key = VK_PROCESSKEY) then
    Key := MapVirtualKey(ScanCode, 1);

{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnInputHelper.HandleKeyDown, Key: %d, ScanCode: %d', [Key, ScanCode]);
{$ENDIF}

  // ���� Alt ʱ�رգ������� Ctrl �� Shift �򲻹�
  if Shift * [ssAlt] <> [] then
  begin
    HideAndClearList;
    Exit;
  end;

  // Shift ������Ҫ����
  if Key in [VK_SHIFT, 255] then  // Some case 255 VK (Reserved) comes, Ignore.
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
      VK_TAB, VK_DECIMAL, MY_VK_DOT_KEY: // '.'
        begin
          ShouldIgnore := ((Key = VK_TAB) and not FTabComplete) or
            ((Key = MY_VK_DOT_KEY) and FIgnoreDot);
{$IFDEF IDE_SYNC_EDIT_BLOCK}
          // ��༭ģʽʱ��Tab ���������Ӧ�óԵ��������ɶ�����ת
          ShouldEatTab := (Key = VK_TAB) and IsCurrentEditorInSyncMode;
{$ENDIF}

{$IFDEF SUPPORT_UNITNAME_DOT}
          if (Key = MY_VK_DOT_KEY) and CurrentIsDelphiSource then
          begin
            // if IndexStr(FToken, csUnitDotPrefixes, CurrentIsDelphiSource) >= 0 then
            // ֧�� Unit ���� IDE �£�uses ���ĵ��Ӧ�ú��ԣ�������֮ǰ���ҹ̶�ǰ׺
            if FPosInfo.PosKind in [pkIntfUses, pkImplUses] then
            begin
              ShouldIgnore := True;
{$IFDEF DEBUG}
              CnDebugger.LogMsg('Dot Got. In Uses Area. Ignore ' + FToken);
{$ENDIF}
            end;
          end;
{$ENDIF}
          if not ShouldIgnore then
          begin
            SendSymbolToIDE(SelMidMatchByEnterOnly, False, False, #0, Result);
            if IsValidDotKey(Key) or IsValidCppPopupKey(Key, ScanCode) then
            begin
              Timer.Interval := Max(csDefDispDelay, FDispDelay);
              Timer.Enabled := True;
            end;
          end
          else if (Key = VK_TAB) and not FTabComplete then
          begin
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Ignore Tab Key Input Item But Hide List.');
{$ENDIF}
            HideAndClearList;
          end;

{$IFDEF IDE_SYNC_EDIT_BLOCK}
          if not ShouldIgnore and ShouldEatTab then
          begin
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Tab To Enter when in Sync Mode. Eat it to Avoid Jump.');
{$ENDIF}
            Result := True;
          end;
{$ENDIF}
        end;
      VK_ESCAPE:
        begin
          HideAndClearList;
          Result := True;
        end;
      86, 90:  // V Z
        begin
          if ssCtrl in Shift then // ճ������ǰȡ������
          begin
            HideAndClearList;
            Result := False;
          end;
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

    if not Result then // �����ʾ�б�״̬û�м������뵱ǰ��Ŀ����ȡ����Ŀ������� HandleKeyPress ���������ַ������
    begin
      Result := HandleKeyPress(KeyDownChar);
    end;
  end
  else // ���δ��ʾ�б����¼����׼����������
  begin
    Timer.Enabled := False;
    if GetGeneralAutoPopup and ((FKeyCount < DispOnlyAtLeastKey - 1) or CurrBlockIsEmpty) and
      (IsValidCharKey(Key, ScanCode) or IsValidDelelteKey(Key) or IsValidDotKey(Key)
       or IsValidCppPopupKey(Key, ScanCode)) then // �ж��Ƿ����㵯����������
    begin
      // Ϊ�˽���������Ҽ������������⣬�˴����浱ǰ���ı�����Ϣ
      CnNtaGetCurrLineText(FCurrLineText, FCurrLineNo, FCurrIndex);
      FCurrLineLen := Length(FCurrLineText);
{$IFDEF DEBUG}
//    CnDebugger.LogMsg('Handle Key Down. Got Line Len: ' + IntToStr(FCurrLineLen));
{$ENDIF}
      FKeyDownTick := GetTickCount;
      SetKeyDownValid(True);
    end
    else // ���õ�������
    begin
      SetKeyDownValid(False);
      FKeyCount := 0;
    end;
  end;
end;

// �� KeyDown ת���� Char �����ã��������ص�ϵͳ KeyPress �¼�
function TCnInputHelper.HandleKeyPress(Key: AnsiChar): Boolean;
var
  Item: TCnSymbolItem;
  Idx, LineNo, CharIdx: Integer;
  NewMatchStr, Text: string;
begin
  Result := False;
{$IFDEF DEBUG}
  CnDebugger.LogInteger(Ord(Key), 'TCnInputHelper.HandleKeyPress');
{$ENDIF}

  FNeedUpdate := False;
  if (((Key >= #32) and (Key < #127)) or (Key = #8)) and IsShowing then
  begin
    // �Ѿ����������ݰ����ж��Ƿ���Ҫ�����б����ݣ��������� FNeedUpdate���� KeyUp �¼�ʹ��
    Item := TCnSymbolItem(FItems.Objects[List.ItemIndex]);

    // ��һ������˸���ǲ��Եģ����˸�ʱ NewMatchStr ���������ж�
    NewMatchStr := UpperCase(FMatchStr + Char(Key));

    Idx := Pos(NewMatchStr, UpperCase(Item.Name));

    if Key = #8 then  // �˸���Ҫ���£������������б�����˸�ɾ�����ǵ㣬�ڴ˴��жϣ��� KeyUp ������
    begin
      CnNtaGetCurrLineText(Text, LineNo, CharIdx); // �õ� Ansi/Utf8/Utf16��CharIdx Ҳ��Ӧ
      if (CharIdx > 0) and (Text <> '') then
      begin
        if Length(Text) >= CharIdx then
          CharIdx := Length(Text);

        if Text[CharIdx] = '.' then
          FKeyBackSpaceADot := True;
      end;

      if not FKeyBackSpaceADot then
        FNeedUpdate := True;
    end
    else if ((FMatchMode = mmStart) and (Idx = 1)) or // ��ͬģʽ����ƥ���
      ((FMatchMode = mmAnywhere) and (Idx > 1) and not Item.MatchFirstOnly) or
      ((FMatchMode = mmFuzzy) and not Item.MatchFirstOnly and FuzzyMatchStr(NewMatchStr, Item.Name)) then
    begin
      FNeedUpdate := True;
    end
    else if (FSpcComplete and (Key = ' ')) or  // ���ж������õļ�����Ҫ�޳� Pascal �б���ָ�������� +- �������
      ((Pos(Char(Key), FCompleteChars) > 0) and not  // Ҳ���Ǳ�֤ Pascal ����ָ���� +- ���������뵱ǰ��Ŀ����ʹ FCompleteChars ����Ҳ����
      (FPosInfo.IsPascal and (FPosInfo.PosKind = pkCompDirect) and (Char(Key) in ['+', '-']))) then
    begin
      SendSymbolToIDE(SelMidMatchByEnterOnly, False, False, Key, Result);

      // �ո������������ԣ���ո���������༭������ IDE �Զ���������
      if FSpcComplete and FIgnoreSpc and (Key = ' ') then
        Result := True;
    end
    else if IsValidSymbolChar(Char(Key), False) or ((FMatchStr = '') and (Key = '{')) then
    begin
      FNeedUpdate := True;  // ����Ǵ˴θ������ͷһ�� {��ҲҪ�����б��ǵ���״̬���������ָ�����������
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
{$IFDEF IDE_SUPPORT_LSP}
  if FSymbolReloading then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnInputHelper.HandleKeyUp. SymbolReloading Exit.');
{$ENDIF}
    Exit;
  end;
{$ENDIF}
  Key := Msg.wParam;
  ScanCode := (Msg.lParam and $00FF0000) shr 16;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnInputHelper.HandleKeyUp %d when KeyDownValid %d, ValidKeyQueue %d, IsShowing %d',
    [Msg.wParam, Integer(GetKeyDownValid), Integer(IsValidKeyQueue), Integer(IsShowing)]);
{$ENDIF}

  if (GetKeyDownValid or IsValidKeyQueue) and not IsShowing then
  begin
    CnNtaGetCurrLineText(LineText, LineNo, Index);
    Len := Length(LineText);
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Input Helper. Line: %d, Len %d. CurLine %d, CurLen %d', [LineNo, Len, FCurrLineNo, FCurrLineLen]);
{$ENDIF}
    // ����˴ΰ����Ե�ǰ�������޸Ĳ���Ϊ����Ч�������Դ����������ҵ�����
    // XE4 �� BCB �����У�����Ĭ�ϳ��ȶ��� 4�����Կո���䣬��˲��ܼ򵥱Ƚϳ��ȣ��ñ�����
    if (LineNo = FCurrLineNo) and ((Len <> FCurrLineLen) or (LineText <> FCurrLineText)) then
    begin
      Inc(FKeyCount);
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Input Helper. Inc FKeyCount to ' + IntToStr(FKeyCount));
{$ENDIF}
      if IsValidDotKey(Key) or IsValidCppPopupKey(Key, ScanCode) or (FKeyCount >= DispOnlyAtLeastKey) or
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
      // �����������¹���µı�ʶ���ı䣬������
      CnOtaGetCurrPosToken(NewToken, CurrPos, True, CalcFirstSet(FirstSet, FPosInfo.IsPascal), CharSet);
      if not SameText(NewToken, FToken) then
      begin
        HideAndClearList;
        Exit;
      end;
    end
    else if Key = VK_BACK then
    begin
      // ����˸�ɾ�˸��㣬������
      if FKeyBackSpaceADot then
      begin
        FKeyBackSpaceADot := False;
        HideAndClearList;
        Exit;
      end;
    end;
    // �����Ѿ������Ĵ����������ֿ��������
    UpdateListBox(False, False);
  end;

  SetKeyDownValid(False);
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
    CurrPos := CnOtaGetCurrLinearPos(View.Buffer); // �õ���Ϊ׼ȷ������ƫ�� Ansi/Utf8/Utf8
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

      // ע�� ParsePasCodePosInfo/ParseCppCodePosInfo �ڲ�ֻ֧�� Ansi��
      // BDS ��ȡ�������������� Utf8->Ansi ת������ע�ͽ�����������⣬�ݲ������ Wide �汾
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
{$IFDEF UNICODE}
      CnOtaSaveCurrentEditorToStreamW(Stream, False);
      if IsPascalFile then  // Stream ������ Utf16
        ParsePasCodePosInfoW(PChar(Stream.Memory), View.CursorPos.Line,
          View.CursorPos.Col, FPosInfo, EditControlWrapper.GetTabWidth, True)
      else if IsCppFile then // ���� C++ �ļ����жϹ��������λ������
        ParseCppCodePosInfoW(PChar(Stream.Memory), View.CursorPos.Line,
          View.CursorPos.Col, FPosInfo, EditControlWrapper.GetTabWidth, True);
{$ELSE}
      CnOtaSaveCurrentEditorToStream(Stream, False, False);
      if IsPascalFile then
        FPosInfo := ParsePasCodePosInfo(PAnsiChar(Stream.Memory), CurrPos, True, True)
      else if IsCppFile then // ���� C++ �ļ����жϹ��������λ������
        FPosInfo := ParseCppCodePosInfo(PAnsiChar(Stream.Memory), CurrPos, True, True);
{$ENDIF}
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
      not (FPosInfo.TokenID in [tkFloat, tkInteger]) // $ef �������� tkInteger Ҳ���ܵ�
  else if IsCppFile then
    Result := not (FPosInfo.PosKind in [pkUnknown, pkString, pkDeclaration]) and
      not (FPosInfo.CTokenID in [ctknumber, ctkfloat]); // ��Щ�����ʹ�ܿ���
end;

procedure TCnInputHelper.OnTimer(Sender: TObject);
var
  AControl: TControl;
  AForm: TCustomForm;
begin
  Timer.Enabled := False;
  FKeyCount := 0;
  if AcceptDisplay and ParsePosInfo then
  begin
    AControl := CnOtaGetCurrentEditControl;
    if AControl <> nil then
    begin
      AForm := GetParentForm(AControl);
      if (AForm <> nil) and (GetForegroundWindow = AForm.Handle) then
      begin
        ShowList(IsValidKeyQueue);
        Exit;
      end;
    end;
  end;
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
    Hook := TCnMethodHook.Create(GetBplMethodAddress(@MessageDlgPosHelp),
      @MyMessageDlgPosHelp);
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
  I: Integer;
  ALeft, ATop: Integer;
  CurrPos: Integer;
  AForm: TCustomForm;
  WorkRect: TRect;
{$IFNDEF SUPPORT_IDESYMBOLLIST}
  AToken: string;
{$ENDIF}
begin
  if AcceptDisplay and GetCaretPosition(Pt) then
  begin
    // ȡ�õ�ǰ��ʶ���������ߵĲ��֣�C/C++����£��������ָ��� # Ҳ��Ϊ��ʶ����ͷ
    if not CnOtaGetCurrPosToken(FToken, CurrPos, True, CalcFirstSet(FirstSet, FPosInfo.IsPascal),
      CalcCharSet(CharSet, @FPosInfo)) then
    begin
{$IFDEF DEBUG}
      // ��¼һ�¹�����ޱ�ʶ�������Σ������ܼ���������
      CnDebugger.TraceMsg('Input Helper CnOtaGetCurrPosToken Get No Token');
{$ENDIF}
    end;

    FMatchStr := Copy(FToken, 1, CurrPos);
{$IFDEF DEBUG}
    CnDebugger.TraceFmt('Token %s, Match %s', [FToken, FMatchStr]);
{$ENDIF}

    if ForcePopup or IsValidSymbol(FToken) or (FPosInfo.PosKind in [pkFieldDot
      {$IFDEF SUPPORT_UNITNAME_DOT}, pkIntfUses, pkImplUses{$ENDIF} ]) then
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
          for I := 0 to FItems.Count - 1 do
          begin
            with TCnSymbolItem(FItems.Objects[I]) do
            begin
              if not AlwaysDisp and ((Kind = skKeyword) and
                (CompareStr(GetKeywordText(KeywordStyle), FToken) = 0) or
                (Kind <> skKeyword) and (CompareStr(Name, Text) = 0) and
                (CompareStr(FToken, Name) = 0)) then
              begin
{$IFDEF DEBUG}
                CnDebugger.LogMsg('Do NOT ShowList for Full Match: ' + Name);
{$ENDIF}
                FKeyCount := DispOnlyAtLeastKey - 1;
                Exit;
              end;
            end;
          end;
        end;

        AForm := CnOtaGetCurrentEditWindow;
        if Assigned(AForm) and Assigned(AForm.Monitor) then
        begin
          with AForm.Monitor do
            WorkRect := Bounds(Left, Top, Width, Height);
        end
        else
          WorkRect := Bounds(0, 0, Screen.Width, Screen.Height);

        if Pt.x + List.Width <= WorkRect.Right then
          ALeft := Pt.x
        else
          ALeft := Max(Pt.x - List.Width, WorkRect.Left);

        if Pt.y + csLineHeight + List.Height <= WorkRect.Bottom then
        begin
          ATop := Pt.y + csLineHeight;
{$IFDEF IDE_SUPPORT_HDPI}
          // �ӱ߿�߶ȣ���ñ߿�ռλ��
          if (List.Height - List.ClientHeight > 8) and (List.Height - List.ClientHeight < 64) then
            ATop := ATop + (List.Height - List.ClientHeight) div 2;
{$ENDIF}
        end
        else
          ATop := Max(Pt.y - List.Height - csLineHeight div 2, WorkRect.Top);
        List.SetPos(ALeft, ATop);

        // �ж��Ƿ���Ҫ���ݷŴ���������ʾ�ֺ�
        UpdateListFont;
        List.Popup;   // ������ʾ

{$IFDEF ADJUST_CODEPARAMWINDOW}
        AdjustCodeParamWindowPos;
{$ENDIF}
      end
      else if not (FPosInfo.PosKind in [pkUnknown, pkFlat, pkComment, pkIntfUses,
        pkImplUses, pkResourceString, pkCompDirect, pkString]) then // ����жϣ�Pascal �� C++ ͨ��
      begin
{$IFNDEF SUPPORT_IDESYMBOLLIST}
        // �����֧�� IDE �����б�ֻ�ڷǱ�ʶ�ĵط���ʾ����б�
        if not FPosInfo.IsPascal then
        begin
          // BCB ������£�Ҳ����ʲô���Ŷ�����
          if ForcePopup then
            ShowIDECodeCompletion
          else
          begin
            CnOtaGetCurrPosToken(AToken, CurrPos, True, CalcFirstSet(FirstSet, FPosInfo.IsPascal), CharSet);
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
  try
    List.SetCount(0); // �˳�ʱ�п��ܳ� No Parent ������
  except
    ;
  end;
end;

function TCnInputHelper.GetIsShowing: Boolean;
begin
  Result := List.Visible;
end;

{$IFDEF ADJUST_CODEPARAMWINDOW}

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
      ParaComp := Application.FindComponent(csCodeParamWindowName);
      if (ParaComp <> nil) and ParaComp.ClassNameIs(csCodeParamWindowClassName) and
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
  RectPara, RectList, RectInter: TRect;
  D, OldTop: Integer;
begin
  // BDS �º���������ʾ�����ڵ�ǰ�е��·�����ס�����ִ��ڣ���Ҫ�Ƶ���ǰ���Ϸ�ȥ
  if IsShowing then
  begin
    ParaComp := Application.FindComponent(csCodeParamWindowName);
    if (ParaComp <> nil) and ParaComp.ClassNameIs(csCodeParamWindowClassName) and
      (ParaComp is TWinControl) then
    begin
      ParaWnd := TWinControl(ParaComp);
      // Hook �������ڣ���ֹ���Զ��ָ�λ��
      HookCodeParamWindow(ParaWnd);

      // �жϲ������������ڵ�λ��
      GetWindowRect(ParaWnd.Handle, RectPara);
      GetWindowRect(List.Handle, RectList);
      if IntersectRect(RectInter, RectPara, RectList) and not IsRectEmpty(RectInter) then
      begin
        D := EditControlWrapper.GetCharHeight;
{$IFDEF IDE_SUPPORT_HDPI}
        // �ӱ߿�߶ȣ���ñ߿�ռλ�ã�ע��˴��� ShowList �е���λ�ö�Ӧ
        if (List.Height - List.ClientHeight > 8) and (List.Height - List.ClientHeight < 64) then
          D := D + (List.Height - List.ClientHeight) div 2;
        if D < 25 then
          D := 25; // ̫С������һ���
{$ENDIF}
{$IFDEF DEBUG}
        CnDebugger.LogRect(ParaWnd.BoundsRect, 'Code Param Window Rect');
        CnDebugger.LogInteger(EditControlWrapper.GetCharHeight, 'Code Param Window CharHeight');
        CnDebugger.LogInteger(D, 'Code Param Window Top Offset');
{$ENDIF}
        OldTop := ParaWnd.Top;
        ParaWnd.Top := List.Top - ParaWnd.Height - D;
        OffsetRect(RectPara, 0, ParaWnd.Top - OldTop);

        SetWindowPos(ParaWnd.Handle, 0, RectPara.Left, RectPara.Top, 0, 0,
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
  L1 := TCnSymbolItem(List.Objects[Index1]).ScopeAdjust;
  L2 := TCnSymbolItem(List.Objects[Index2]).ScopeAdjust;
  if L2 < L1 then
    Result := 1
  else if L2 > L1 then
    Result := -1
  else
    Result := 0;
end;

function SymbolSortByFuzzyScope(List: TStringList; Index1, Index2: Integer): Integer;
var
  N1, N2, L1, L2: Integer;
begin
  // FuzzyScope Compare��ע��� Pos �Ĳ�ͬ��Pos �� Index С��ǰ�棬ģ��ƥ���� Score ����ǰ��
  with TCnSymbolItem(List.Objects[Index1]) do
  begin
    N1 := Tag;
    L1 := ScopeAdjust;
  end;

  with TCnSymbolItem(List.Objects[Index2]) do
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
    Result := -1
  else
    Result := 1;
end;

function SymbolSortByScopePos(List: TStringList; Index1, Index2: Integer): Integer;
var
  N1, N2, L1, L2: Integer;
begin
  with TCnSymbolItem(List.Objects[Index1]) do
  begin
    N1 := Tag;
    L1 := ScopeAdjust;
  end;

  with TCnSymbolItem(List.Objects[Index2]) do
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
  S1 := TCnSymbolItem(List.Objects[Index1]).ScopeHit;
  S2 := TCnSymbolItem(List.Objects[Index2]).ScopeHit;
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
  S1 := TCnSymbolItem(List.Objects[Index1]).ScopeHit;
  S2 := TCnSymbolItem(List.Objects[Index2]).ScopeHit;
  if S2 > S1 then
    Result := 1
  else if S2 < S1 then
    Result := -1
  else
  begin
    L1 := Ord(TCnSymbolItem(List.Objects[Index1]).Kind);
    L2 := Ord(TCnSymbolItem(List.Objects[Index2]).Kind);
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
  S1 := TCnSymbolItem(List.Objects[Index1]).ScopeHit;
  S2 := TCnSymbolItem(List.Objects[Index2]).ScopeHit;
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
  if SortKind = skByScope then
  begin
    if FMatchMode = mmAnywhere then
      FItems.CustomSort(SymbolSortByScopePos)
    else if FMatchMode = mmFuzzy then
      FItems.CustomSort(SymbolSortByFuzzyScope)
  end;
end;

procedure TCnInputHelper.UpdateSymbolList;
var
  I, J: Integer;
  S: string;
  Kinds: TCnSymbolKindSet;
  Item: TCnSymbolItem;
  SymbolList: TCnSymbolList;
  Editor: IOTAEditBuffer;
  HashList: TCnSymbolHashList;
begin
  HashList := nil;
  FSymbols.Clear;
  FItems.Clear;
  Editor := CnOtaGetEditBuffer;
  if Editor = nil then
    Exit;

  try
    if FRemoveSame then
      HashList := TCnSymbolHashList.Create(csHashListCount);

    for I := 0 to SymbolListMgr.Count - 1 do
    begin
      SymbolList := SymbolListMgr.List[I];
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Input Helper To Reload %s. PosKind %s', [SymbolList.ClassName,
//      GetEnumName(TypeInfo(TCodePosKind), Ord(FPosInfo.PosKind))]);
{$ENDIF}

      // ע�⣺LSP ģʽ�µ� IDESymbolList ���� Reload ʱ�ڲ����첽�ȴ���Ҳ�������߳̿���
      // ��ȥ������������������ KeyDown/KeyPress/KeyUp �ȣ��Ӷ�����˳����ɻ��ң���Ҫ��Ǵ���
      FSymbolReloading := True;  // ��¼��ǣ������޷���ֹ IDE ����ŵ�������Ĵ����Զ����
      if SymbolList.Active and SymbolList.Reload(Editor, FMatchStr, FPosInfo) then
      begin
        FSymbolReloading := False; // ��ʱ�ָ����
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Input Helper Reload %s Success: %d', [SymbolList.ClassName, SymbolList.Count]);
{$ENDIF}
        // �����������͵õ����õ� KindSet
        if FPosInfo.IsPascal then
          Kinds := csPascalSymbolKindTable[FPosInfo.PosKind] * DispKindSet
        else
          Kinds := csCppSymbolKindTable[FPosInfo.PosKind] * DispKindSet;

        for J := 0 to SymbolList.Count - 1 do
        begin
          Item := SymbolList.Items[J];
          if FPosInfo.IsPascal and not Item.ForPascal then  // Pascal �У������� Pascal��
            Continue;
          if not FPosInfo.IsPascal and not Item.ForCpp then // C/C++ �У������� C/C++��
            Continue;

          S := Item.Name;
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Input Helper Check Name %s, %s', [S + Item.PinYin, GetEnumName(TypeInfo(TCnSymbolKind), Ord(Item.Kind))]);
{$ENDIF}
                                      // ���⴦������û�Ѹ������ uses����ôӦ���� uses ��������ֹؼ�������
          if ((Item.Kind in Kinds) or ((Item.Kind = skKeyword) and (FPosInfo.LastNoSpace = tkUses)))
            and (Length(S) >= ListOnlyAtLeastLetter) then
          begin
{$IFDEF DEBUG}
//          CnDebugger.LogMsg('Input Helper is in Kinds. ' + IntToStr(ListOnlyAtLeastLetter));
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
//            CnDebugger.LogFmt('Input Helper Add %s with Kind %s', [S, GetEnumName(TypeInfo(TSymbolKind), Ord(Item.Kind))]);
{$ENDIF}
              if Item.FuzzyMatchIndexes.Count > 0 then
                Item.FuzzyMatchIndexes.Clear;
              FSymbols.AddObject(S, Item);
            end;
          end;
        end;
      end;
      FSymbolReloading := False; // Ҳ�ָ����
    end;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('UpdateSymbolList. Get All Symbols %d.', [FSymbols.Count]);
{$ENDIF}
  finally
    if HashList <> nil then
      HashList.Free;
  end;
end;

function TCnInputHelper.UpdateCurrList(ForcePopup: Boolean): Boolean;
var
  I, Idx: Integer;
  Symbol: string;
  CanDel: Boolean;
begin
{$IFDEF ADJUST_CODEPARAMWINDOW}
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
{$IFDEF DEBUG}
      CnDebugger.LogFmt('UpdateCurrList Only Delete from Item List Count %d with Mode %d',
        [FItems.Count, Ord(FMatchMode)]);
{$ENDIF}
      // ������ƥ�������ֻ���ϴ�ƥ�������β���϶��˸��ַ�������ֻҪ���ϴ�ƥ��Ľ����ɾ����������
      if FMatchMode = mmStart then
      begin
        for I := FItems.Count - 1 downto 0 do
        begin
          Idx := Pos(Symbol, UpperCase(FItems[I]));
          CanDel := Idx <> 1;

{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
          // ������ƥ�䣬���ò�ƥ��ƴ����ͷ
          if CanDel and (FItems.Objects[I] <> nil) and (TCnSymbolItem(FItems.Objects[I]).PinYin <> '')then
          begin
            Idx := Pos(Symbol, UpperCase(TCnSymbolItem(FItems.Objects[I]).PinYin));
            CanDel := Idx <> 1;
          end;
{$ENDIF}

          if CanDel then
          begin
            FItems.Delete(I);
          end
          else
            TCnSymbolItem(FItems.Objects[I]).Tag := Idx;
        end;
      end
      else if FMatchMode = mmAnywhere then
      begin
        for I := FItems.Count - 1 downto 0 do
        begin
          Idx := Pos(Symbol, UpperCase(FItems[I]));
          CanDel := Idx <= 0;

{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
          // ������ƥ�䣬�����ڲ���ƥ��ƴ��
          if CanDel and (FItems.Objects[I] <> nil) and (TCnSymbolItem(FItems.Objects[I]).PinYin <> '')then
          begin
            Idx := Pos(Symbol, UpperCase(TCnSymbolItem(FItems.Objects[I]).PinYin));
            CanDel := Idx <= 0;
          end;
{$ENDIF}
          if CanDel then
            FItems.Delete(I)
          else
            TCnSymbolItem(FItems.Objects[I]).Tag := Idx;
        end;
      end
      else if FMatchMode = mmFuzzy then
      begin
        for I := FItems.Count - 1 downto 0 do
        begin
          CanDel := not FuzzyMatchStrWithScore(Symbol, FItems[I], Idx,
            TCnSymbolItem(FItems.Objects[I]).FuzzyMatchIndexes);

{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
          // ������ƥ�䣬�����ڲ���ģ��ƥ��ƴ��
          if CanDel and (FItems.Objects[I] <> nil) and (TCnSymbolItem(FItems.Objects[I]).PinYin <> '')then
            CanDel := not FuzzyMatchStrWithScore(Symbol, TCnSymbolItem(FItems.Objects[I]).PinYin, Idx, nil);
{$ENDIF}
          if CanDel then
            FItems.Delete(I)
          else
            TCnSymbolItem(FItems.Objects[I]).Tag := Idx + CN_PINYIN_DELTA;
        end;
      end;
    end
    else  // ���ǣ�����Ҫ���´��ܵ� FSymbols ��ƥ�䲢���� FItems
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('UpdateCurrList Clear and Match from Symbol List Count %d with Mode %d',
        [FSymbols.Count, Ord(FMatchMode)]);
{$ENDIF}
      FItems.Clear;
      case FMatchMode of
        mmStart:
          begin
            for I := 0 to FSymbols.Count - 1 do
            begin
              if Symbol <> '' then
                Idx := Pos(Symbol, UpperCase(FSymbols[I]))
              else
                Idx := 1;

              if Idx = 1 then
              begin
                TCnSymbolItem(FSymbols.Objects[I]).Tag := Idx;
                FItems.AddObject(FSymbols[I], FSymbols.Objects[I]);
              end
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
              else
              begin
                // ƴ��ƥ���
                if (Symbol <> '') and (FSymbols.Objects[I] <> nil) and (TCnSymbolItem(FSymbols.Objects[I]).PinYin <> '') then
                  Idx := Pos(Symbol, UpperCase(TCnSymbolItem(FSymbols.Objects[I]).PinYin))
                else
                  Idx := 1;

                if Idx = 1 then
                begin
                  TCnSymbolItem(FSymbols.Objects[I]).Tag := Idx;
                  FItems.AddObject(FSymbols[I], FSymbols.Objects[I]);
                end;
              end;
{$ENDIF}
            end;
          end;
        mmAnywhere:
          begin
            for I := 0 to FSymbols.Count - 1 do
            begin
              if Symbol <> '' then
                Idx := Pos(Symbol, UpperCase(FSymbols[I]))
              else
                Idx := 1;

              // ͷƥ��ģ�ƥ��Ϊ 1�����ͷƥ��ģ�����ƥ��
              if ((Idx > 0) and not TCnSymbolItem(FSymbols.Objects[I]).MatchFirstOnly)
                or ((Idx = 1) and TCnSymbolItem(FSymbols.Objects[I]).MatchFirstOnly) then
              begin
                TCnSymbolItem(FSymbols.Objects[I]).Tag := Idx;
                FItems.AddObject(FSymbols[I], FSymbols.Objects[I]);
              end
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
              else
              begin
                // ƴ��ƥ���
                if (Symbol <> '') and (FSymbols.Objects[I] <> nil) and (TCnSymbolItem(FSymbols.Objects[I]).PinYin <> '') then
                  Idx := Pos(Symbol, UpperCase(TCnSymbolItem(FSymbols.Objects[I]).PinYin))
                else
                  Idx := 1;

                if Idx > 0 then
                begin
                  TCnSymbolItem(FSymbols.Objects[I]).Tag := Idx;
                  FItems.AddObject(FSymbols[I], FSymbols.Objects[I]);
                end;
              end;
{$ENDIF}
            end;
          end;
        mmFuzzy:
          begin
            for I := 0 to FSymbols.Count - 1 do
            begin
              if Symbol = '' then
              begin
                TCnSymbolItem(FSymbols.Objects[I]).Tag := 1;
                FItems.AddObject(FSymbols[I], FSymbols.Objects[I]);
              end
              else if TCnSymbolItem(FSymbols.Objects[I]).MatchFirstOnly then
              begin
                Idx := Pos(Symbol, UpperCase(FSymbols[I]));
                if Idx = 1 then
                begin
                  TCnSymbolItem(FSymbols.Objects[I]).Tag := Idx;
                  FItems.AddObject(FSymbols[I], FSymbols.Objects[I]);
                end;
              end
              else if FuzzyMatchStrWithScore(Symbol, FSymbols[I], Idx,
                TCnSymbolItem(FSymbols.Objects[I]).FuzzyMatchIndexes) then
              begin
                TCnSymbolItem(FSymbols.Objects[I]).Tag := Idx;
                FItems.AddObject(FSymbols[I], FSymbols.Objects[I]);
              end
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
              // ��ƴ����Ҳģ��ƥ�䣬������ Indexes ��
              else if ((FSymbols.Objects[I] <> nil) and (TCnSymbolItem(FSymbols.Objects[I]).PinYin <> '')
                and FuzzyMatchStrWithScore(Symbol, TCnSymbolItem(FSymbols.Objects[I]).PinYin, Idx, nil)) then
              begin
                TCnSymbolItem(FSymbols.Objects[I]).FuzzyMatchIndexes.Clear;
                TCnSymbolItem(FSymbols.Objects[I]).Tag := Idx + CN_PINYIN_DELTA;
                FItems.AddObject(FSymbols[I], FSymbols.Objects[I]);
              end;
{$ENDIF}
            end;
          end;
      end;
    end;

    SortCurrSymbolList;
    List.SetCount(FItems.Count);

    Result := FItems.Count > 0;
    if Result then
    begin
      Idx := FItems.IndexOf(FToken);
      // ȫƥ�������ѡ��
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
{$IFNDEF SUPPORT_IDESYMBOLLIST}
  AToken: string;
{$ENDIF}
begin
  if CnOtaGetCurrPosToken(FToken, CurrPos, True, CalcFirstSet(FirstSet, FPosInfo.IsPascal),
    CalcCharSet(CharSet, @FPosInfo)) or ForcePopup
    or ParsePosInfo and (FPosInfo.PosKind in [pkFieldDot, pkField]) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('InputHelper UpdateListBox. CurrToken: %s, CurrPos: %d', [FToken, CurrPos]);
  {$ENDIF}
    FMatchStr := Copy(FToken, 1, CurrPos);
    Result := UpdateCurrList(ForcePopup);

{$IFDEF DEBUG}
//    CnDebugger.LogFmt('InputHelper UpdateCurrList Returns %d', [Integer(Result)]);
{$ENDIF}

  {$IFNDEF SUPPORT_IDESYMBOLLIST}
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
  {$IFNDEF SUPPORT_IDESYMBOLLIST}
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
          CnOtaGetCurrPosToken(AToken, CurrPos, True, CalcFirstSet(FirstSet, FPosInfo.IsPascal), CharSet);
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
  Item: TCnSymbolItem;
  DelLeft: Boolean;
  Buffer: IOTAEditBuffer;
  C: Char;
  EditPos: IOTAEditPosition;
{$IFDEF OTA_CODE_TEMPLATE_API}
  View: IOTAEditView;
  CTS: IOTACodeTemplateServices;
{$ENDIF}

  function ItemHasParam(AItem: TCnSymbolItem): Boolean;
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
    Item := TCnSymbolItem(FItems.Objects[List.ItemIndex]);

{$IFDEF OTA_CODE_TEMPLATE_API}
    if Item.CodeTemplateIndex > CN_CODE_TEMPLATE_INDEX_INVALID then
    begin
      CTS := BorlandIDEServices as IOTACodeTemplateServices;
      if CTS <> nil then
      begin
        View := CnOtaGetTopMostEditView;
        if (View <> nil) and (Item.CodeTemplateIndex < CTS.CodeObjectCount) then
        begin
          // ģ������ʱ��ȻҪ���滻֮ǰ�����������ƥ������
          CnOtaDeleteCurrTokenLeft(CalcFirstSet(FirstSet, FPosInfo.IsPascal), CalcCharSet(CharSet, @FPosInfo));
          CTS.InsertCode(Item.CodeTemplateIndex, View, False);
        end;

        // ���ӵ����
        if FAutoAdjustScope and (Item.HashCode <> 0) then
          HitCountMgr.IncHitCount(Item.HashCode);
        Exit;
      end;
    end;
{$ENDIF}

    S := Item.Name;
    if not MatchFirstOnly or (FMatchStr = '') or (Pos(UpperCase(FMatchStr),
      UpperCase(S)) = 1) or (FuzzyMatchStr(FMatchStr, S)) then // ����ƥ����ͷƥ���ģ��ƥ��
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

      // ����������ͨ��ʶ��ʱ�����ܸ��ݲ����� CharSet ��ɾ���������ݣ�
      // ������ɾ��ĳЩ�����ʶ�������ָ������ƵĺϷ��ַ���Ӻŵȣ�
      // ����ֻ�ܸ�������д��Ϊ��ĸ�����»��ߵȣ��Ѵ�����C/C++����#����Ԫ����������Σ�
      if Item.Kind in [skConstant..skClass] then
      begin
        if DelLeft then
          CnOtaDeleteCurrTokenLeft(CalcFirstSet(CN_ALPHA_CHARS, FPosInfo.IsPascal), CalcCharSet(CN_ALPHANUMERIC, @FPosInfo))
        else
          CnOtaDeleteCurrToken(CalcFirstSet(CN_ALPHA_CHARS, FPosInfo.IsPascal), CalcCharSet(CN_ALPHANUMERIC, @FPosInfo));
      end
      else
      begin
        if DelLeft then
          CnOtaDeleteCurrTokenLeft(CalcFirstSet(FirstSet, FPosInfo.IsPascal), CalcCharSet(CharSet, @FPosInfo))
        else
          CnOtaDeleteCurrToken(CalcFirstSet(FirstSet, FPosInfo.IsPascal), CalcCharSet(CharSet, @FPosInfo));
      end;

      // ����� Pascal ����ָ��ҹ����и�}��Ҫ��}ɾ��
      // ���ܼ򵥵�������� Charset �м� }����Ϊ�����������ж�
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
            EditPos.MoveRelative(0, 1);  // �˸�ɾ����� }
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
{$IFDEF EDITVIEW_SETCURSORPOS_BUG}
  EditControl: TControl;
  Text: string;
  Utf8Text: AnsiString;
  Utf8Len, AnsiLen: Integer;
{$ENDIF}
begin
  Buffer := CnOtaGetEditBuffer;
  if Assigned(Buffer) and Assigned(Buffer.TopView) and
    Assigned(Buffer.EditPosition) then
  begin
{$IFDEF EDITVIEW_SETCURSORPOS_BUG}
    // D2009/2010 �£����� CursorPos ���� InsertText ������ƫ�Ҫ���ݵ�ǰ�е�˫�ֽ��ַ����������ҵ���
    EditControl := CnOtaGetCurrentEditControl;
    if EditControl <> nil then
    begin
      Text := EditControlWrapper.GetTextAtLine(EditControl, FSavePos.Line);
      Utf8Text := UTF8Encode(Text);
      Utf8Text := Copy(Utf8Text, 1, FSavePos.Col);
      Utf8Len := Length(Utf8Text);  // �õ��� Bug ʱ�� Utf8 ����λ��
      Text := UTF8Decode(Utf8Text); // ת�� Utf16����λ�ò�
      AnsiLen := CalcAnsiDisplayLengthFromWideString(PWideChar(Text)); // �õ� Utf16 ת Ansi ��ĳ���

      // ���ϲ�ֵ
      if Utf8Len > AnsiLen then
        FSavePos.Col := FSavePos.Col + (Utf8Len - AnsiLen);
    end;
{$ENDIF}

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
const
  LEFT_ICON = 22;
  DESC_INTERVAL = 28;
var
  AText: string;
  SymbolItem: TCnSymbolItem;
  TextWith: Integer;
  Kind: Integer;
  ColorFont, ColorBrush: TColor;

  function GetHighlightColor(Kind: TCnSymbolKind): TColor;
  begin
    Result := List.FontColor;
    if Kind = skKeyword then
      Result := List.KeywordColor
    else if Kind = skType then // Type ������ɫ
    begin
{$IFDEF IDE_SUPPORT_THEMING}
      // ʹ�ñ༭����ɫʱ��ר�ŵ� Type ɫ���������߼�����
      // Light Ĭ��ģʽʱ�������Ƿ�ʹ�ñ༭��ɫ����������ǳ���� Type ɫ
      // ��ʹ�ñ༭����ɫʱ��Ҳ�ö���ǳ������ɫ
      // ʹ�ñ༭����ɫ���Ǻ�ɫģʽʱ���ð��� Type ��ɫ
      if CnThemeWrapper.IsUnderLightTheme or not FUseEditorColor then
        Result := csTypeColor;
      if FUseEditorColor and CnThemeWrapper.IsUnderDarkTheme then
        Result := csDarkTypeColor;
      // �������� List.FontColor
{$ELSE}
      Result := csTypeColor; // ��֧������� IDE���ù̶�����ɫ
{$ENDIF}
    end;
  end;

begin
  // �Ի� ListBox �е� SymbolList
  with List do
  begin
    SymbolItem := TCnSymbolItem(FItems.Objects[Index]);
    Canvas.Font := Font;

    if odSelected in State then  // �������⣬ָ��ѡ��/��ѡ��״̬�µ�����ɫ
    begin
      ColorBrush := SelectBackColor;
      ColorFont := SelectFontColor;
    end
    else
    begin
      ColorBrush := BackColor;
      ColorFont := GetHighlightColor(SymbolItem.Kind);
    end;

    Canvas.Brush.Color := ColorBrush;
    Canvas.Font.Color := ColorFont;

    if Ord(SymbolItem.Kind) < dmCnSharedImages.SymbolImages.Count then
      Kind := Ord(SymbolItem.Kind)
    else
      Kind := dmCnSharedImages.SymbolImages.Count - 1;

    Canvas.FillRect(Rect);
{$IFDEF IDE_SUPPORT_HDPI}
    Menu.Images.Draw(Canvas, Rect.Left + 2, Rect.Top, Kind);
{$ELSE}
    dmCnSharedImages.SymbolImages.Draw(Canvas, Rect.Left + 2, Rect.Top, Kind);
{$ENDIF}
    Canvas.Brush.Style := bsClear;
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];

    AText := SymbolItem.GetKeywordText(KeywordStyle);
    if FMatchMode in [mmStart, mmAnywhere] then
      DrawMatchText(Canvas, FMatchStr, AText, Rect.Left +
        IdeGetScaledPixelsFromOrigin(LEFT_ICON, Control), Rect.Top, MatchColor)
    else
      DrawMatchText(Canvas, FMatchStr, AText, Rect.Left +
        IdeGetScaledPixelsFromOrigin(LEFT_ICON, Control), Rect.Top,
        MatchColor, SymbolItem.FuzzyMatchIndexes);

    TextWith := Canvas.TextWidth(AText);
    Canvas.Font.Style := Canvas.Font.Style - [fsBold];

    Canvas.Brush.Color := ColorBrush;
    if not (odSelected in State) then // ��ͨ�����������֣�ע��δѡ��ʱ�� ColorFont �в�ͬ����ֱ������
    begin
      if CnThemeWrapper.IsUnderDarkTheme then
        Canvas.Font.Color := csDarkFontColor
      else
        Canvas.Font.Color := List.FontColor;
    end;

    Canvas.TextOut(Rect.Left + IdeGetScaledPixelsFromOrigin(DESC_INTERVAL, Control)
      + TextWith, Rect.Top, SymbolItem.Description);
  end;
end;

procedure TCnInputHelper.ListItemHint(Sender: TObject; Index: Integer; var
  HintStr: string);
var
  Item: TCnSymbolItem;
  TextWidth: Integer;
begin
  with List do
  begin
    if ItemIndex >= 0 then
    begin
      Item := TCnSymbolItem(FItems.Objects[Index]);
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
  Kind: TCnSymbolKind;
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
{$IFDEF IDE_SUPPORT_HDPI}
  Menu.Images := IdeGetVirtualImageListFromOrigin(dmCnSharedImages.SymbolImages, nil, True);
{$ELSE}
  Menu.Images := dmCnSharedImages.SymbolImages;
{$ENDIF}
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
  for Kind := Low(TCnSymbolKind) to High(TCnSymbolKind) do
    IconMenuItem.Add(NewMenuItem(GetSymbolKindName(Kind), OnIconMenu,
      Ord(Kind), Ord(Kind)));
  Menu.Items.Add(IconMenuItem);

  Menu.Items.Add(NewMenuItem('-', nil));
  Menu.Items.Add(NewMenuItem(SCnInputHelperCopy, OnCopyMenu));
  Menu.Items.Add(NewMenuItem(SCnInputHelperAddSymbol, OnAddSymbolMenu));
  Menu.Items.Add(NewMenuItem(SCnInputHelperConfig, OnConfigMenu));
end;

procedure TCnInputHelper.OnPopupMenu(Sender: TObject);
var
  I: Integer;
begin
  AutoMenuItem.Checked := GetGeneralAutoPopup;
  DispBtnMenuItem.Checked := List.DispButtons;
  SortMenuItem.Items[Ord(FSortKind)].Checked := True;
  for I := 0 to IconMenuItem.Count - 1 do
    IconMenuItem.Items[I].Checked := TCnSymbolKind(IconMenuItem.Items[I].Tag) in FDispKindSet;
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

procedure TCnInputHelper.OnCopyMenu(Sender: TObject);
var
  SymbolItem: TCnSymbolItem;
begin
  if List.ItemIndex >= 0 then
  begin
    SymbolItem := TCnSymbolItem(FItems.Objects[List.ItemIndex]);
    if SymbolItem <> nil then
      Clipboard.AsText := SymbolItem.Name + ' ' + SymbolItem.Description;
  end;
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
  Kind: TCnSymbolKind;
begin
  if Sender is TMenuItem then
  begin
    Kind := TCnSymbolKind(TMenuItem(Sender).Tag);
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

function TCnInputHelper.GetGeneralAutoPopup: Boolean;
begin
{$IFDEF IDE_SUPPORT_LSP}
  Result := FAutoPopupLSP;
{$ELSE}
  Result := FAutoPopup;
{$ENDIF}
end;

{$IFDEF IDE_SUPPORT_LSP}

procedure TCnInputHelper.SetAutoPopupLSP(Value: Boolean);
begin
  FAutoPopupLSP := Value;
  Action.Checked := Value;
  AutoMenuItem.Checked := Value;
  if not FAutoPopupLSP and IsShowing then
    HideAndClearList;
{$IFNDEF SUPPORT_IDESYMBOLLIST}
  if FCCErrorHook <> nil then
  begin
    if Value and Active then
      FCCErrorHook.HookMethod
    else
      FCCErrorHook.UnHookMethod;
  end;
{$ENDIF}
end;

{$ELSE}

procedure TCnInputHelper.SetAutoPopup(Value: Boolean);
begin
  FAutoPopup := Value;
  Action.Checked := Value;
  AutoMenuItem.Checked := Value;
  if not FAutoPopup and IsShowing then
    HideAndClearList;
{$IFNDEF SUPPORT_IDESYMBOLLIST}
  if FCCErrorHook <> nil then
  begin
    if Value and Active then
      FCCErrorHook.HookMethod
    else
      FCCErrorHook.UnHookMethod;
  end;
{$ENDIF}
end;

{$ENDIF}

procedure TCnInputHelper.OnActionUpdate(Sender: TObject);
begin
  Action.Checked := GetGeneralAutoPopup;
end;

procedure TCnInputHelper.Click(Sender: TObject);
begin
{$IFDEF IDE_SUPPORT_LSP}
  AutoPopupLSP := not AutoPopupLSP;
{$ELSE}
  AutoPopup := not AutoPopup;
{$ENDIF}
end;

procedure TCnInputHelper.SetListFont(const Value: TFont);
begin
  if Value <> nil then
  begin
    FListFont.Assign(Value);

    List.Font.Assign(FListFont);
    // UpdateListFont �������� Popup ǰҲ������ʾǰ����
  end;
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
  BroadcastShortCut;
end;

procedure TCnInputHelper.Config;
begin
  HideAndClearList;
  if CnInputHelperConfig(Self{$IFNDEF SUPPORT_IDESYMBOLLIST}, True{$ENDIF}) then
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
    ListFont := ReadFont('', csFont, FListFont);
    // ��ȡ���ú� SetListFont �л������Ҫ�Ŵ��ֺ���ʾ

    List.DispButtons := ReadBool('', csDispButtons, True);
    UseEditorColor := ReadBool('', csUseEditorColor, FUseEditorColor);

{$IFDEF IDE_SUPPORT_LSP}
    AutoPopupLSP := ReadBool('', csAutoPopupLSP, True);
{$ELSE}
    AutoPopup := ReadBool('', csAutoPopup, True);
{$ENDIF}
    FListOnlyAtLeastLetter := ReadInteger('', csListOnlyAtLeastLetter, 1);
    FDispOnlyAtLeastKey := ReadInteger('', csDispOnlyAtLeastKey, 2);
    FDispKindSet := TCnSymbolKindSet(ReadInteger('', csDispKindSet, Integer(FDispKindSet)));
    FSortKind := TCnSortKind(ReadInteger('', csSortKind, 0));
    FMatchMode := TCnMatchMode(ReadInteger('', csMatchMode, Ord(mmFuzzy)));
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
    FTabComplete := ReadBool('', csTabComplete, True);
    FIgnoreDot := ReadBool('', csIgnoreDot, False);
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
  I: Integer;
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    WriteInteger('', csWidth, List.Width);
    WriteInteger('', csHeight, List.Height);
    WriteFont('', csFont, FListFont);
    WriteBool('', csDispButtons, List.DispButtons);
    WriteBool('', csUseEditorColor, FUseEditorColor);

 {$IFDEF IDE_SUPPORT_LSP}
    WriteBool('', csAutoPopupLSP, FAutoPopupLSP);
 {$ELSE}
    WriteBool('', csAutoPopup, FAutoPopup);
 {$ENDIF}
    WriteInteger('', csListOnlyAtLeastLetter, FListOnlyAtLeastLetter);
    WriteInteger('', csDispOnlyAtLeastKey, FDispOnlyAtLeastKey);
    WriteInteger('', csDispKindSet, Integer(FDispKindSet));
    WriteInteger('', csSortKind, Ord(FSortKind));
    WriteInteger('', csMatchMode, Ord(FMatchMode));
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
    WriteBool('', csTabComplete, FTabComplete);
    WriteBool('', csIgnoreDot, FIgnoreDot);
    WriteBool('', csIgnoreSpc, FIgnoreSpc);
    WriteBool('', csAutoInsertEnter, FAutoInsertEnter);
    WriteBool('', csAutoCompParam, FAutoCompParam);

    WriteBool('', csSmartDisplay, FSmartDisplay);
    WriteInteger('', csOutputStyle, Ord(FOutputStyle));
    WriteInteger('', csKeywordStyle, Ord(FKeywordStyle));
    WriteBool('', csSelMidMatchByEnterOnly, FSelMidMatchByEnterOnly);
    WriteBool('', csCheckImmRun, FCheckImmRun);
    WriteBool('', csDispOnIDECompDisabled, FDispOnIDECompDisabled);

    for I := 0 to SymbolListMgr.Count - 1 do
      WriteBool(csListActive, SymbolListMgr.List[I].ClassName,
        SymbolListMgr.List[I].Active);
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

procedure TCnInputHelper.ResetSettings(Ini: TCustomIniFile);
begin
  SymbolListMgr.Reset;
end;

procedure TCnInputHelper.SetActive(Value: Boolean);
begin
  inherited;
{$IFNDEF SUPPORT_IDESYMBOLLIST}
  if FCCErrorHook <> nil then
  begin
    if Value and GetGeneralAutoPopup then
      FCCErrorHook.HookMethod
    else
      FCCErrorHook.UnHookMethod;
  end;
{$ENDIF}
end;

function TCnInputHelper.CalcFirstSet(Orig: TAnsiCharSet; IsPascal: Boolean): TAnsiCharSet;
begin
  if IsPascal then
    Result := Orig
  else
    Result := Orig + ['#']; // C/C++ �ı�ʶ����Ҫ�� # Ҳ����
end;

function TCnInputHelper.IsValidCppPopupKey(VKey: Word; Code: Word): Boolean;
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
    CnDebugger.LogFmt('IsValidCppPopupKey VK_ScanCodeToAscii: %d %d => %d ("%s")', [VKey, Code, Ord(C), C]);
{$ENDIF}
    if C = '>' then
    begin
      // �� >��if ����µ�ǰһ����ʶ�������һλ�� -
      CnOtaGetCurrPosToken(AToken, CurrPos, True, CalcFirstSet(FirstSet, FPosInfo.IsPascal), CharSet);
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Is Valid Cpp Popup Key: Token: ' + AToken);
{$ENDIF}
      if (Length(AToken) >= 1) and (AToken[Length(AToken)] = '-') then
      begin
        Option := CnOtaGetEnvironmentOptions;
        if not Option.GetOptionValue(csKeyCodeCompletion) then
          Result := True;
      end;
    end
    else if C = '#' then
      Result := True;
  end;
end;

procedure TCnInputHelper.DebugComand(Cmds, Results: TStrings);
var
  I, J: Integer;
  List: TCnSymbolList;
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

function TCnInputHelper.CalcCharSet(Orig: TAnsiCharSet; PosInfo: PCodePosInfo): TAnsiCharSet;
begin
  Result := Orig - ['+']; // ò���в��ֱ�ʶ���� + ���ӽ����ˣ�����Ҫǿ��ȥ��
{$IFDEF SUPPORT_UNITNAME_DOT}
  // ֧�ֵ�ŵ�������ͷ���������Ǳ�ʶ����һ����
  if PosInfo^.IsPascal and (PosInfo^.AreaKind in [akIntfUses, akImplUses]) and
    (PosInfo^.PosKind in [pkIntfUses, pkImplUses]) then
    Result := Orig + ['.'];
{$ENDIF}
end;

function TCnInputHelper.GetKeyDownValid: Boolean;
begin
  Result := False;
  if FKeyDownValidStack.Count > 0 then
    Result := Boolean(FKeyDownValidStack.Peek);
end;

procedure TCnInputHelper.SetKeyDownValid(Value: Boolean);
begin
  if Value then
  begin
    FKeyDownValidStack.Push(Pointer(True));
  end
  else
  begin
    if FKeyDownValidStack.Count > 0 then
      FKeyDownValidStack.Pop;
  end;
end;

procedure TCnInputHelper.BroadcastShortCut;
begin
  EventBus.PostEvent(EVENT_INPUTHELPER_POPUP_SHORTCUT_CHANGED, Pointer(GetPopupKey));
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InputHelper Broadcast ShortCut: ' + ShortCutToText(GetPopupKey));
{$ENDIF}
end;

procedure TCnInputHelper.UpdateListFont;
var
  S: Integer;

  procedure AdjustListItemHeight;
  var
    O: Integer;
  begin
    try
      // �����ֺű仯��̬���� ItemHeight
      O := List.Canvas.Font.Size;
      List.Canvas.Font.Size := List.Font.Size;
      S := List.Canvas.TextHeight('Aj');
      List.Canvas.Font.Size := O;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('Input Helper AdjustListItemHeight. Calc Font Size %d', [S]);
{$ENDIF}

      if S > 16 then
        S := S + 2
      else
        S := 16; // ��С 16

{$IFDEF IDE_SUPPORT_HDPI}
      Inc(S, 2);
{$ENDIF}

      if S <> List.ItemHeight then
      begin
        List.ItemHeight := S;

{$IFDEF DEBUG}
        CnDebugger.LogFmt('Input Helper List ItemHeight Changed to %d', [List.ItemHeight]);
{$ENDIF}
      end;
    except
      ;
    end;
  end;

begin
  if WizOptions.SizeEnlarge <> wseOrigin then
  begin
    S := WizOptions.CalcIntEnlargedValue(WizOptions.SizeEnlarge, FListFont.Size);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Input Helper Enlarge Mode. Should Set Font Size to %d', [S]);
{$ENDIF}
    if List.Font.Size <> S then
    begin
      List.Font.Size := S;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Input Helper List Font Change Size to %d', [List.Font.Size]);
{$ENDIF}
    end;
  end
  else if List.Font.Size <> FListFont.Size then
  begin
    List.Font.Size := FListFont.Size;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Input Helper List Font Size Restored to %d', [List.Font.Size]);
{$ENDIF}
  end;
  AdjustListItemHeight;
end;

procedure TCnInputHelper.SetUseEditorColor(const Value: Boolean);
begin
  FUseEditorColor := Value;
  List.UseEditorColor := Value;
end;

function TCnInputHelper.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '�Զ�����,��ʶ��,�б�,symbol,list,pascal,c++,';
end;

initialization
{$IFDEF SUPPORT_INPUTHELPER}
  RegisterCnWizard(TCnInputHelper);
{$ENDIF}

{$ENDIF CNWIZARDS_CNINPUTHELPER}
end.

