{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

unit CnSourceHighlight;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器显示扩展单元
* 单元作者：周劲羽 (zjy@cnpack.org)
*           Dragon P.C. (dragonpc@21cn.com)
*           LiuXiao
*           Shenloqi
* 备    注：BDS 下 UTF8 的问题有三个地方需要标明：
*                              D7或以下、  D2009以下的BDS、D2009：
*           LineText 属性：    AnsiString、UTF8、          UncodeString
*           EditView.CusorPos：Ansi字节、  UTF8的字节Col、 UTF8的字节Col
*           GetAttributeAtPos：Ansi字节、  UTF8的字节Col、 UTF8的字节Col
*               因此 D2009 下处理时，需要额外将获得的 UnicodeString 的 LineText
*               转成 UTF8 来适应相关的 CursorPos 和 GetAttributeAtPos
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2009.03.28
*               加入控制大小写匹配的机制，对 Pascal 文件，不区分大小写
*           2009.01.06
*               加入高亮当前行背景的功能，尚未完善。
*               基本思想：挂接 Editor::TCustomEditorControl::SetForeAndBackColor
*                         判断并设置背景色。判断在 BeforePaint 以及 AfterPaint
*                         中结合 EditorChanged 的行位置来处理，要判断很多地方。
*               目前问题：有点慢
*           2008.09.09
*               加入高亮当前光标下的标识符的功能
*           2008.06.25
*               修正部分刷新问题，if then 加入对 else 的配对，修正部分汉字字符下
*               高亮等出现错位的问题
*           2008.06.22
*               增加对 BDS 的代码折叠的支持
*           2008.06.17
*               增加对 BDS 的支持
*           2008.06.08
*               增加画线匹配的功能
*           2008.03.11
*               修正EditControl关闭时通知器内部未释放高亮对象的问题
*           2005.07.25
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  Windows, Messages, Classes, Graphics, SysUtils, Controls, Menus, Forms,
  ToolsAPI, IniFiles, Contnrs, ExtCtrls, TypInfo, Math, mPasLex,
  CnWizClasses, CnEditControlWrapper, CnWizNotifier, CnIni, CnWizUtils, CnCommon,
  CnConsts, CnWizConsts, CnWizIdeUtils, CnWizShortCut, CnPasCodeParser,
  CnGraphUtils, CnFastList, CnCppCodeParser, mwBCBTokenList;

const
  HighLightDefColors: array[-1..5] of TColor = ($00000099, $000000FF, $000099FF,
    $0033CC00, $0099CC00, $00FF6600, $00CC00CC);
  csDefCurTokenColorBg = $0080DDFF;
  csDefCurTokenColorFg = clBlack;
  csDefCurTokenColorBd = $00226DA8;


  CN_LINE_STYLE_SMALL_DOT_STEP = 2;

  CN_LINE_STYLE_TINY_DOT_STEP = 1;
  // 每几个像素空几个像素

  csKeyTokens: set of TTokenKind = [
    tkIf, tkThen, tkElse,
    tkRecord, tkClass, tkInterface, tkDispInterface,
    tkFor, tkWith, tkOn, tkWhile, tkDo,
    tkAsm, tkBegin, tkEnd,
    tkTry, tkExcept, tkFinally,
    tkCase,
    tkRepeat, tkUntil];

type
  TCnLineStyle = (lsSolid, lsDot, lsSmallDot, lsTinyDot);

  TBracketInfo = class
  {* 每个 EditControl 对应一个，管理本编辑器中的一个括号配对高亮信息}
  private
    FTokenStr: AnsiString;
    FTokenLine: AnsiString;
    FTokenPos: TOTAEditPos;
    FTokenMatchStr: AnsiString;
    FTokenMatchLine: AnsiString;
    FTokenMatchPos: TOTAEditPos;
    FLastPos: TOTAEditPos;
    FLastMatchPos: TOTAEditPos;
    FIsMatch: Boolean;
    FControl: TControl;
  public
    constructor Create(AControl: TControl);
    property Control: TControl read FControl write FControl;
    property IsMatch: Boolean read FIsMatch write FIsMatch;
    property LastMatchPos: TOTAEditPos read FLastMatchPos write FLastMatchPos;
    property LastPos: TOTAEditPos read FLastPos write FLastPos;
    property TokenStr: AnsiString read FTokenStr write FTokenStr;
    property TokenLine: AnsiString read FTokenLine write FTokenLine;
    property TokenPos: TOTAEditPos read FTokenPos write FTokenPos;
    property TokenMatchStr: AnsiString read FTokenMatchStr write FTokenMatchStr;
    property TokenMatchLine: AnsiString read FTokenMatchLine write FTokenMatchLine;
    property TokenMatchPos: TOTAEditPos read FTokenMatchPos write FTokenMatchPos;
  end;

  TBlockHighlightRange = (brAll, brMethod, brWholeBlock, brInnerBlock);

  TBlockHighlightStyle = (bsNow, bsDelay, bsHotkey);

  TBlockLineInfo = class;

  TBlockMatchInfo = class(TObject)
  {* 每个 EditControl 对应一个，解析并管理本编辑器中所有的结构高亮信息}
  private
    FControl: TControl;
    FModified: Boolean;
    FChanged: Boolean;
    FParser: TCnPasStructureParser;
    FKeyList: TCnList;         // 容纳解析出来的 Tokens
    FCurTokenList: TCnList;    // 容纳解析出来的与光标当前词相同的 Tokens
    FCurTokenListEditLine: TCnList; // 容纳解析出来的光标当前词相同的词的行数
    FLineList: TCnObjectList;
    FIdLineList: TCnObjectList;// LineList/IdLineList 容纳按行方式存储的快速访问的内容
    FLineInfo: TBlockLineInfo; // 容纳解析出来的 Tokens 配对信息
    FStack: TStack;
    FIfThenStack: TStack;
    FCurrentToken: TCnPasToken;
    FCurMethodStartToken, FCurMethodCloseToken: TCnPasToken;
    FCurrentTokenName: AnsiString;
    FCurrentBlockSearched: Boolean;
    FCaseSensitive: Boolean;
    FIsCppSource: Boolean;
    FCppParser: TCnCppStructureParser;
    function GetCount: Integer;
    function GetTokens(Index: Integer): TCnPasToken;
    function GetCurTokens(Index: Integer): TCnPasToken;
    function GetLineCount: Integer;
    function GetIdLineCount: Integer;
    function GetLines(LineNum: Integer): TCnList;
    function GetCurTokenCount: Integer;
    function GetIdLines(LineNum: Integer): TCnList;
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;
    function CheckBlockMatch(BlockHighlightRange: TBlockHighlightRange): Boolean;
    procedure UpdateCurTokenList;
    procedure CheckLineMatch(View: IOTAEditView; IgnoreClass: Boolean);
    procedure UpdateLineList;
    procedure UpdateIdLineList;
    procedure Clear;
    procedure AddToKeyList(AToken: TCnPasToken);
    procedure AddToCurrList(AToken: TCnPasToken);
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TCnPasToken read GetTokens;
    property CurTokens[Index: Integer]: TCnPasToken read GetCurTokens;
    {* 和当前标识符相同的标识符列表}
    property CurTokenCount: Integer read GetCurTokenCount;
    {* 和当前标识符相同的标识符列表数目}
    property LineCount: Integer read GetLineCount;
    property IdLineCount: Integer read GetIdLineCount;
    property Lines[LineNum: Integer]: TCnList read GetLines;
    {* 每行一个CnList，后者容纳 Token}
    property IdLines[LineNum: Integer]: TCnList read GetIdLines;
    {* 也是按 Lines 的方式来，每行一个 CnList，后者容纳 CurToken}
    property Control: TControl read FControl;
    property Modified: Boolean read FModified write FModified;
    property Changed: Boolean read FChanged write FChanged;
    property CurrentTokenName: AnsiString read FCurrentTokenName write FCurrentTokenName;
    property CurrentToken: TCnPasToken read FCurrentToken write FCurrentToken;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
    {* 当前匹配时是否大小写敏感，由外部设定}
    property IsCppSource: Boolean read FIsCppSource write FIsCppSource;
    {* 是否是 C/C++ 文件，默认是 False，也就是 Pascal}
    property Parser: TCnPasStructureParser read FParser;
    property CppParser: TCnCppStructureParser read FCppParser;

    property LineInfo: TBlockLineInfo read FLineInfo write FLineInfo;
    {* 画线高亮的配对信息，解析关键字高亮时顺便也解析}
  end;

  TBlockLinePair = class(TObject)
  {* 描述一根配对的线所对应的多个 Token 标记}
  private
    FTop: Integer;
    FLeft: Integer;
    FBottom: Integer;
    FStartToken: TCnPasToken;
    FEndToken: TCnPasToken;
    FLayer: Integer;
    FEndLeft: Integer;
    FStartLeft: Integer;
    FMiddleTokens: TList;
    FDontDrawVert: Boolean;
    function GetMiddleCount: Integer;
    function GetMiddleToken(Index: Integer): TCnPasToken;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AddMidToken(const Token: TCnPasToken; const LineLeft: Integer);
    function IsInMiddle(const LineNum: Integer): Boolean;
    function IndexOfMiddleToken(const Token: TCnPasToken): Integer;

    property StartToken: TCnPasToken read FStartToken write FStartToken;
    property EndToken: TCnPasToken read FEndToken write FEndToken;
    //property EndIsFirstTokenInLine: Boolean read FEndIsFirstTokenInLine write FEndIsFirstTokenInLine;
    //{* 末尾是否是第一个Token}
    
    property StartLeft: Integer read FStartLeft write FStartLeft;
    {* 配对起始 Token 的 Column}
    property EndLeft: Integer read FEndLeft write FEndLeft;
    {* 配对中止的 Token 的 Column}

    property Left: Integer read FLeft write FLeft;
    {* 一对画线的配对 Token 对应的左面的 Column 值，必然为 StartLeft 与 EndLeft 之一}
    property Top: Integer read FTop write FTop;
    {* 一对画线的配对 Token 对应的上面的 Line 值，必然为 StartToken 的 Line 值}
    property Bottom: Integer read FBottom write FBottom;
    {* 一对画线的配对 Token 对应的下面的 Line 值，必然为 EndToken 的 Line 值}

    property MiddleCount: Integer read GetMiddleCount;
    {* 一对画线配对的 Token 的中间的 Token 的数量}
    property MiddleToken[Index: Integer]: TCnPasToken read GetMiddleToken;
    {* 一对画线配对的 Token 的中间的 Token }

    property Layer: Integer read FLayer write FLayer;
    {* 一对画线的配对层次}

    property DontDrawVert: Boolean read FDontDrawVert write FDontDrawVert;
    {* 控制是否需要画竖线}
  end;

  TBlockLineInfo = class(TObject)
  {* 每个 EditControl 对应一个，由对应的 BlockMatchInfo 转换而来，包括多个
     LinePair.}
  private
    FControl: TControl;
    FPairList: TCnObjectList;
    FLineList: TCnObjectList;
    FCurrentPair: TBlockLinePair;
    FCurrentToken: TCnPasToken;
    function GetCount: Integer;
    function GetPairs(Index: Integer): TBlockLinePair;
    function GetLineCount: Integer;
    function GetLines(LineNum: Integer): TCnList;
    procedure UpdateLineList;
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;
    procedure Clear;
    procedure AddPair(Pair: TBlockLinePair);
    procedure FindCurrentPair(View: IOTAEditView; IsCppModule: Boolean = False);
    property Control: TControl read FControl;
    property Count: Integer read GetCount;
    property Pairs[Index: Integer]: TBlockLinePair read GetPairs;
    property LineCount: Integer read GetLineCount;
    property Lines[LineNum: Integer]: TCnList read GetLines;
    property CurrentPair: TBlockLinePair read FCurrentPair;
    property CurrentToken: TCnPasToken read FCurrentToken;
  end;

  TCurLineInfo = class(TObject)
  {* 每个 EditControl 对应一个，记录高亮当前行的信息}
  private
    FCurrentLine: Integer;
    FControl: TControl;
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;

    property Control: TControl read FControl;
    property CurrentLine: Integer read FCurrentLine write FCurrentLine;
  end;

{ TCnSourceHighlight }

  TCnSourceHighlight = class(TCnIDEEnhanceWizard)
  private
    FOnEnhConfig: TNotifyEvent;

    FMatchedBracket: Boolean;
    FBracketColor: TColor;
    FBracketColorBk: TColor;
    FBracketColorBd: TColor;
    FBracketBold: Boolean;
    FBracketMiddle: Boolean;
    FBracketList: TObjectList;

    FStructureHighlight: Boolean;
    FBlockHighlightRange: TBlockHighlightRange;
    FBlockMatchDelay: Cardinal;
    FBlockHighlightStyle: TBlockHighlightStyle;
    FBlockMatchDrawLine: Boolean;
    FBlockMatchList: TObjectList;
    FBlockLineList: TObjectList;
    FLineMapList: TObjectList;   // 容纳行映射信息
{$IFNDEF BDS}
    FCorIdeModule: HMODULE;
    FCurLineList: TObjectList;   // 容纳当前行背景高亮重画的信息
{$ENDIF}
    FBlockShortCut: TCnWizShortCut;
    FBlockMatchMaxLines: Integer;
    FTimer: TTimer;
    FIsChecking: Boolean;
    CharSize: TSize;
    FBlockMatchLineLimit: Boolean;
    FBlockMatchLineWidth: Integer;
    FBlockMatchLineClass: Boolean;
    FBlockMatchHighlight: Boolean;
    FBlockMatchBackground: TColor;
    FCurrentTokenHighlight: Boolean;
    FCurrentTokenBackground: TColor;
    FCurrentTokenForeground: TColor;
    FCurrentTokenBorderColor: TColor;
    FBlockMatchLineEnd: Boolean;
    FBlockMatchLineHori: Boolean;
    FBlockMatchLineHoriDot: Boolean;
    FBlockExtendLeft: Boolean;
    FBlockMatchLineStyle: TCnLineStyle;
    FKeywordHighlight, FIdentifierHighlight: THighlightItem;
    FDirtyList: TList;
    FViewChangedList: TList;
    FViewFileNameIsPascalList: TList;
{$IFDEF BDS}
    FLineText: AnsiString;
{$ELSE}
    FHighLightCurrentLine: Boolean;
    FHighLightLineColor: TColor;
    FDefaultHighLightLineColor: TColor;
{$ENDIF}
    function GetColorFg(ALayer: Integer): TColor;
    function EditorGetTextRect(Editor: TEditorObject; APos: TOTAEditPos;
      AText: AnsiString; var ARect: TRect): Boolean;
    procedure EditorPaintText(EditControl: TControl; ARect: TRect; AText: AnsiString;
      AColor, AColorBk, AColorBd: TColor; ABold, AItalic, AUnderline: Boolean);
    function IndexOfBracket(EditControl: TControl): Integer;
    function GetBracketMatch(EditView: IOTAEditView; EditBuffer: IOTAEditBuffer;
      EditControl: TControl; AInfo: TBracketInfo): Boolean;
    procedure CheckBracketMatch(Editor: TEditorObject);

    function IndexOfBlockMatch(EditControl: TControl): Integer;
    function IndexOfBlockLine(EditControl: TControl): Integer;
{$IFNDEF BDS}
    function IndexOfCurLine(EditControl: TControl): Integer;
{$ENDIF}
    procedure OnHighlightTimer(Sender: TObject);
    procedure OnHighlightExec(Sender: TObject);
    procedure BeginUpdateEditor(Editor: TEditorObject);
    procedure EndUpdateEditor(Editor: TEditorObject);
    // 标记一行代码需要重画，只有在 BeginUpdateEditor 和 EndUpdateEditor 之间调用有效
    procedure EditorMarkLineDirty(LineNum: Integer);
    procedure RefreshCurrentTokens(Info: TBlockMatchInfo);
    procedure UpdateHighlight(Editor: TEditorObject; ChangeType: TEditorChangeTypes);
    procedure ActiveFormChanged(Sender: TObject);
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean);
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
    procedure EditorChanged(Editor: TEditorObject; ChangeType: TEditorChangeTypes);
    procedure ClearHighlight(Editor: TEditorObject);
    procedure PaintBracketMatch(Editor: TEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintBlockMatchKeyword(Editor: TEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintBlockMatchLine(Editor: TEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintLine(Editor: TEditorObject; LineNum, LogicLineNum: Integer);
    function GetBlockMatchHotkey: TShortCut;
    procedure SetBlockMatchHotkey(const Value: TShortCut);
    procedure SetBlockMatchLineClass(const Value: Boolean);
    procedure ReloadIDEFonts;
{$IFNDEF BDS}
    procedure BeforePaintLine(Editor: TEditorObject; LineNum, LogicLineNum: Integer);
    procedure SetHighLightCurrentLine(const Value: Boolean);
    procedure SetHighLightLineColor(const Value: TColor);
{$ENDIF}
  protected
    procedure DoEnhConfig;
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
  public
    // 放出来让设置窗口读写
    FHighLightColors: array[-1..5] of TColor;

    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;

    procedure RepaintEditors;
    {* 让设置窗口调用，强迫重画}
    property MatchedBracket: Boolean read FMatchedBracket write FMatchedBracket;
    property BracketColor: TColor read FBracketColor write FBracketColor;
    property BracketBold: Boolean read FBracketBold write FBracketBold;
    property BracketColorBk: TColor read FBracketColorBk write FBracketColorBk;
    property BracketColorBd: TColor read FBracketColorBd write FBracketColorBd;
    property BracketMiddle: Boolean read FBracketMiddle write FBracketMiddle;

    property StructureHighlight: Boolean read FStructureHighlight write FStructureHighlight;
    {* 是否代码关键字高亮}
    property BlockMatchHighlight: Boolean read FBlockMatchHighlight write FBlockMatchHighlight;
    {* 是否光标下关键字配对背景色高亮}
    property BlockMatchBackground: TColor read FBlockMatchBackground write FBlockMatchBackground;
    {* 光标下关键字配对高亮的背景色}
    property CurrentTokenHighlight: Boolean read FCurrentTokenHighlight write FCurrentTokenHighlight;
    {* 是否光标下当前标识符背景色高亮}
    property CurrentTokenForeground: TColor read FCurrentTokenForeground write FCurrentTokenForeground;
    {* 光标下当前标识符高亮的前景色}
    property CurrentTokenBackground: TColor read FCurrentTokenBackground write FCurrentTokenBackground;
    {* 光标下当前标识符高亮的背景色}
    property CurrentTokenBorderColor: TColor read FCurrentTokenBorderColor write FCurrentTokenBorderColor;
    {* 光标下当前标识符高亮的边框色}
    property BlockHighlightRange: TBlockHighlightRange read FBlockHighlightRange write FBlockHighlightRange;
    {* 高亮范围，默认改成了 brAll}
    property BlockHighlightStyle: TBlockHighlightStyle read FBlockHighlightStyle write FBlockHighlightStyle;
    {* 高亮延时模式，默认改成了 bsNow}
    property BlockMatchDelay: Cardinal read FBlockMatchDelay write FBlockMatchDelay;
    property BlockMatchHotkey: TShortCut read GetBlockMatchHotkey write SetBlockMatchHotkey;
    property BlockMatchDrawLine: Boolean read FBlockMatchDrawLine write FBlockMatchDrawLine;
    {* 是否简易地画线高亮}
    property BlockMatchLineWidth: Integer read FBlockMatchLineWidth write FBlockMatchLineWidth;
    {* 线宽，默认为 1}
    property BlockMatchLineEnd: Boolean read FBlockMatchLineEnd write FBlockMatchLineEnd;
    {* 是否绘制线的端点，也就是挨着关键字的部分，和横线使用同一线型，如横线不虚则使用竖线线型}
    property BlockMatchLineStyle: TCnLineStyle read FBlockMatchLineStyle write FBlockMatchLineStyle;
    {* 线型}
    property BlockMatchLineHori: Boolean read FBlockMatchLineHori write FBlockMatchLineHori;
    {* 是否绘制横线，也就是竖线到缩进的部分的横线}
    property BlockMatchLineHoriDot: Boolean read FBlockMatchLineHoriDot write FBlockMatchLineHoriDot;
    {* 画横线时是否使用虚线 TinyDot 的线型}
    property BlockExtendLeft: Boolean read FBlockExtendLeft write FBlockExtendLeft;
    {* 是否将行首第一个关键字作为画线起始点，以减少部分竖线可能从代码中穿过的情况}

    property BlockMatchLineClass: Boolean read FBlockMatchLineClass write SetBlockMatchLineClass;
    {* 是否画线匹配 class/record/interface 等的声明}
{$IFNDEF BDS}
    property HighLightCurrentLine: Boolean read FHighLightCurrentLine write SetHighLightCurrentLine;
    {* 是否高亮当前行的背景}
    property HighLightLineColor: TColor read FHighLightLineColor write SetHighLightLineColor;
    {* 高亮当前行的背景色}
{$ENDIF}
    property BlockMatchLineLimit: Boolean read FBlockMatchLineLimit write FBlockMatchLineLimit;
    property BlockMatchMaxLines: Integer read FBlockMatchMaxLines write FBlockMatchMaxLines;
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

function LoadIDEDefaultCurrentColor: TColor;
{* 根据 IDE 配色方案自动调整的初始化高亮背景色}

procedure HighlightCanvasLine(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer;
  AStyle: TCnLineStyle);
{* 高亮专用的画线函数，TinyDot 时不画斜线}

function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
{* 判断标识符是否在光标下，频繁调用，因此此处 View 用指针来避免引用计数从而优化速度 }

{$IFNDEF BDS}
procedure MyEditorsCustomEditControlSetForeAndBackColor(ASelf: TObject; Param1, Param2, Param3, Param4: Cardinal);
{$ENDIF}

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

implementation

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizMethodHook, CnSourceHighlightFrm, CnWizCompilerConst;

type
  TBracketChars = array[0..1] of AnsiChar;
  TBracketArray = array[0..255] of TBracketChars;
  PBracketArray = ^TBracketArray;
  // 加不加 register 没区别反正默认就是 register 方式
  TEVFillRectProc = procedure(Self: TObject; const Rect: TRect); register;
  TSetForeAndBackColorProc = procedure (Self: TObject;
    Param1, Param2, Param3, Param4: Cardinal); register;

  TCustomControlHack = class(TCustomControl);

const
  csBracketCountCpp = 3;
  csBracketsCpp: array[0..csBracketCountCpp - 1] of TBracketChars =
    (('(', ')'), ('[', ']'), ('{', '}'));

  csBracketCountPas = 2;
  csBracketsPas: array[0..csBracketCountPas - 1] of TBracketChars =
    (('(', ')'), ('[', ']'));

  csReservedWord = 'Reserved word'; // RegName of IDE Font
  csIdentifier = 'Identifier';      // RegName of IDE Font
  csWhiteSpace = 'Whitespace';

  csMaxBracketMatchLines = 50;

  csShortDelay = 20;

{$IFNDEF BDS}
  {$IFDEF COMPILER5}
  SEVFillRectName = '@Editors@TCustomEditControl@EVFillRect$qqrrx13Windows@TRect';
  {$ELSE}
  SEVFillRectName = '@Editors@TCustomEditControl@EVFillRect$qqrrx11Types@TRect';
  {$ENDIF}
  SSetForeAndBackColorName = '@Editors@TCustomEditControl@SetForeAndBackColor$qqriioo';
{$ENDIF}
  csMatchedBracket = 'MatchedBracket';
  csBracketColor = 'BracketColor';
  csBracketColorBk = 'BracketColorBk';
  csBracketColorBd = 'BracketColorBd';
  csBracketBold = 'BracketBold';
  csBracketMiddle = 'BracketMiddle';

  csStructureHighlight = 'StructureHighlight';
  csBlockHighlightRange = 'BlockHighlightRange';
  csBlockMatchDelay = 'BlockMatchDelay';
  csBlockMatchMaxLines = 'BlockMatchMaxLines';
  csBlockMatchLineLimit = 'BlockMatchLineLimit';
  csBlockHighlightStyle = 'BlockHighlightStyle';
  csBlockMatchDrawLine = 'BlockMatchDrawLine';
  csBlockMatchLineWidth = 'BlockMatchLineWidth';
  csBlockMatchLineStyle = 'BlockMatchLineStyle';
  csBlockMatchLineClass = 'BlockMatchLineClass';
  csBlockMatchLineEnd = 'BlockMatchLineEnd';
  csBlockMatchLineHori = 'BlockMatchLineHori';
  csBlockMatchLineHoriDot = 'BlockMatchLineHoriDot';
  csBlockMatchHighlight = 'BlockMatchHighlight';
  csBlockMatchBackground = 'BlockMatchBackground';
  csCurrentTokenHighlight = 'CurrentTokenHighlight';
  csCurrentTokenColor = 'CurrentTokenColor';
  csCurrentTokenColorBk = 'CurrentTokenColorBk';
  csCurrentTokenColorBd = 'CurrentTokenColorBd';
  csBlockMatchHighlightColor = 'BlockMatchHighlightColor';
  csHighlightCurrentLine = 'HighLightCurrentLine';
  csHighLightLineColor = 'HighLightLineColor';

var
  FHighlight: TCnSourceHighlight = nil;
  GlobalIgnoreClass: Boolean = False;
{$IFNDEF BDS}
  CanDrawCurrentLine: Boolean = False;
  PaintingControl: TControl = nil;
  ColorChanged: Boolean;
  OldBkColor: TColor = clWhite;
  EVFillRect: TEVFillRectProc = nil;
  EVFRHook: TCnMethodHook = nil;

  SetForeAndBackColor: TSetForeAndBackColorProc = nil;
  SetForeAndBackColorHook: TCnMethodHook = nil;
  {$IFDEF DEBUG}
  // CurrentLineNum: Integer = -1;
  {$ENDIF}
{$ENDIF}

procedure HighlightCanvasLine(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer;
  AStyle: TCnLineStyle);
var
  I, XStep, YStep, Step: Integer;
  OldStyle: TBrushStyle;
  OldColor: TColor;
begin
  if ACanvas <> nil then
  begin
    OldStyle := ACanvas.Brush.Style;
    OldColor := ACanvas.Brush.Color;
    ACanvas.Brush.Style := bsClear;

    try
      case AStyle of
        lsSolid:
          begin
            ACanvas.Pen.Style := psSolid;
            ACanvas.MoveTo(X1, Y1);
            ACanvas.LineTo(X2, Y2);
          end;
        lsDot:
          begin
            ACanvas.Pen.Style := psDot;
            ACanvas.MoveTo(X1, Y1);
            ACanvas.LineTo(X2, Y2);
          end;
        lsSmallDot, lsTinyDot:
          begin
            ACanvas.Pen.Style := psSolid;
            if AStyle = lsSmallDot then
              Step := CN_LINE_STYLE_SMALL_DOT_STEP
            else
              Step := CN_LINE_STYLE_TINY_DOT_STEP;

            with ACanvas do
            begin
              if X1 = X2 then
              begin
                YStep := Abs(Y2 - Y1) div (Step * 2); // Y方向总步数，正值
                if Y1 < Y2 then
                begin
                  for I := 0 to YStep - 1 do
                  begin
                    MoveTo(X1, Y1 + (2 * I + 1) * Step);
                    LineTo(X1, Y1 + (2 * I + 2) * Step);
                  end;
                end
                else
                begin
                  for I := 0 to YStep - 1 do
                  begin
                    MoveTo(X1, Y1 - (2 * I + 1) * Step);
                    LineTo(X1, Y1 - (2 * I + 2) * Step);
                  end;
                end;
              end
              else if Y1 = Y2 then
              begin
                XStep := Abs(X2 - X1) div (Step * 2); // X方向总步数
                if X1 < X2 then
                begin
                  for I := 0 to XStep - 1 do
                  begin
                    MoveTo(X1 + (2 * I + 1) * Step, Y1);
                    LineTo(X1 + (2 * I + 2) * Step, Y1);
                  end;
                end
                else
                begin
                  for I := 0 to XStep - 1 do
                  begin
                    MoveTo(X1 - (2 * I + 1) * Step, Y1);
                    LineTo(X1 - (2 * I + 2) * Step, Y1);
                  end;
                end;
              end;
            end;
          end;
      end;
    finally
      ACanvas.Brush.Style := OldStyle;
      ACanvas.Brush.Color := OldColor;
    end;
  end;
end;

// 判断标识符是否在光标下
function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
var
{$IFDEF BDS}
  Text: AnsiString;
{$ENDIF}
  LineNo, Col: Integer;
  View: IOTAEditView;
begin
  if not Assigned(AView) then
  begin
    Result := False;
    Exit;
  end;
  View := IOTAEditView(AView);
  LineNo := View.CursorPos.Line;
  Col := View.CursorPos.Col;
  
  if Token.EditLine <> LineNo then // 行号不等时直接退出
  begin
    Result := False;
    Exit;
  end;

  // 行相等才需要读出行内容进行比较
{$IFDEF BDS}
  Text := AnsiString(GetStrProp(AControl, 'LineText'));
  if Text <> '' then
  begin
    {$IFDEF DELPHI2009_UP}
    // Delphi 2009 下，LineText 不是 UTF8 需要转换为 UTF8 计算
    Col := Length(CnUtf8ToAnsi(Copy(CnAnsiToUtf8(Text), 1, Col)));
    {$ELSE}
    Col := Length(CnUtf8ToAnsi(Copy(Text, 1, Col)));
    {$ENDIF}
  end;
{$ENDIF}
  Result := (Col >= Token.EditCol) and (Col <= Token.EditCol + Length(Token.Token));
end;

function TokenIsMethodOrClassName(const Token, Name: string): Boolean;
var
  I: Integer;
  s, sName: string;
begin
  Result := False;
  sName := Name;
  I := LastDelimiter('.', sName);
  if I > 0 then
    s := Copy(sName, I + 1, MaxInt)
  else
    s := sName;

  if AnsiSameText(Token, s) then
    Result := True;
  while (not Result) and (I > 0) do
  begin
    sName := Copy(sName, 1, I - 1);
    I := LastDelimiter('.', sName);
    if I > 0 then
      s := Copy(sName, I + 1, MaxInt)
    else
      s := sName;
    if AnsiSameText(Token, s) then
      Result := True;
  end;
end;

{ TBracketInfo }

constructor TBracketInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
end;

{ TBlockMatchInfo }

// 分析检查本 EditControl 中的结构高亮信息
function TBlockMatchInfo.CheckBlockMatch(
  BlockHighlightRange: TBlockHighlightRange): Boolean;
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  i: Integer;
  StartIndex, EndIndex: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TBlockMatchInfo.CheckBlockMatch');
{$ENDIF}

  Result := False;

  // 不能调用 Clear 来简单清除所有内容，必须保留 FCurTokenList，避免重画时不能刷新
  FKeyList.Clear;
  FLineList.Clear;
  FIdLineList.Clear;
  if LineInfo <> nil then
    LineInfo.Clear;

  if Control = nil then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Control = nil');
  {$ENDIF}
    Exit;
  end;

  try
    EditView := EditControlWrapper.GetEditView(Control);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('EditView = nil');
  {$ENDIF}
    Exit;
  end;

  if not IsDprOrPas(EditView.Buffer.FileName) and not IsInc(EditView.Buffer.FileName) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Highlight. Not IsDprOrPas Or Inc: ' + EditView.Buffer.FileName);
  {$ENDIF}

    // 判断如果是 C/C++，则解析并保存各个 Tokens，供光标改变时更新 FCurTokenList
    // 如果只是光标位置变化，但高亮范围不是当前整个文件的话，仍需要重新解析，这点和 Pascal 解析器不同
    if IsCppSourceModule(EditView.Buffer.FileName) and (Modified or (CppParser.Source = '') or
      (FHighlight.BlockHighlightRange <> brAll)) then
    begin
      FIsCppSource := True;
      CaseSensitive := True;
      Stream := TMemoryStream.Create;
      try
  {$IFDEF DEBUG}
        CnDebugger.LogMsg('Parse Cpp Source file: ' + EditView.Buffer.FileName);
  {$ENDIF}
        CnOtaSaveEditorToStream(EditView.Buffer, Stream);
        // 解析当前显示的源文件
        CppParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
          EditView.CursorPos.Line, EditView.CursorPos.Col);
      finally
        Stream.Free;
      end;

      // 在 FKeyList 中记录各个大括号的位置，
      // 默认处理本单元中的所有需要的匹配
      StartIndex := 0;
      EndIndex := CppParser.Count - 1;
      if BlockHighlightRange = brAll then
      begin
        // 默认全处理
      end
      else if (BlockHighlightRange in [brMethod, brWholeBlock])
        and Assigned(CppParser.BlockStartToken)
        and Assigned(CppParser.BlockCloseToken) then
      begin
        // 只把本外块中需要的 Token 加进来
        StartIndex := CppParser.BlockStartToken.ItemIndex;
        EndIndex := CppParser.BlockCloseToken.ItemIndex;
      end
      else if (BlockHighlightRange = brInnerBlock)
        and Assigned(CppParser.InnerBlockStartToken)
        and Assigned(CppParser.InnerBlockCloseToken) then
      begin
        // 只把本内块中需要的 Token 加进来
        StartIndex := CppParser.InnerBlockStartToken.ItemIndex;
        EndIndex := CppParser.InnerBlockCloseToken.ItemIndex;
      end;

      for I := StartIndex to EndIndex do
        if CppParser.Tokens[I].CppTokenKind in [ctkbraceopen, ctkbraceclose] then
          FKeyList.Add(CppParser.Tokens[I]);

      for I := 0 to Count - 1 do
      begin
        // 转换成 Col 与 Line
        CharPos := OTACharPos(Tokens[I].CharIndex - 1, Tokens[I].LineNumber);
        EditView.ConvertPos(False, EditPos, CharPos);
        // TODO: 以上这句在 D2009 中的结果可能会有偏差，暂无办法
{$IFDEF BDS2009_UP}
        EditPos.Col := Tokens[I].CharIndex + 1;
{$ENDIF}        
        Tokens[I].EditCol := EditPos.Col;
        Tokens[I].EditLine := EditPos.Line;
      end;

      // 记录大括号的层次
      UpdateCurTokenList;
      UpdateLineList;
      if LineInfo <> nil then
        CheckLineMatch(EditView, GlobalIgnoreClass);
    end;
  end
  else  // 处理解析 Pascal 中的配对关键字
  begin
    if Modified or (Parser.Source = '') then
    begin
      FIsCppSource := False;
      CaseSensitive := False;
      Stream := TMemoryStream.Create;
      try
  {$IFDEF DEBUG}
        CnDebugger.LogMsg('Parse Pascal Source file: ' + EditView.Buffer.FileName);
  {$ENDIF}
        CnOtaSaveEditorToStream(EditView.Buffer, Stream);
        // 解析当前显示的源文件，需要高亮当前标识符时不设置KeyOnly
        Parser.ParseSource(PAnsiChar(Stream.Memory),
          IsDpr(EditView.Buffer.FileName), not FHighlight.CurrentTokenHighlight);
      finally
        Stream.Free;
      end;
    end;

    // 解析后再查找当前光标所在的块
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);
    Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
    FCurrentBlockSearched := True;

    if BlockHighlightRange = brAll then
    begin
      // 处理本单元中的所有需要的匹配
      for i := 0 to Parser.Count - 1 do
        if Parser.Tokens[i].TokenID in csKeyTokens then
          FKeyList.Add(Parser.Tokens[i]);
    end
    else if (BlockHighlightRange = brMethod) and Assigned(Parser.MethodStartToken)
      and Assigned(Parser.MethodCloseToken) then
    begin
      // 只把本过程中需要的 Token 加进来
      for I := Parser.MethodStartToken.ItemIndex to
        Parser.MethodCloseToken.ItemIndex do
        if Parser.Tokens[I].TokenID in csKeyTokens then
          FKeyList.Add(Parser.Tokens[I]);
    end
    else if (BlockHighlightRange = brWholeBlock) and Assigned(Parser.BlockStartToken)
      and Assigned(Parser.BlockCloseToken) then
    begin
      for I := Parser.BlockStartToken.ItemIndex to
        Parser.BlockCloseToken.ItemIndex do
        if Parser.Tokens[I].TokenID in csKeyTokens then
          FKeyList.Add(Parser.Tokens[I]);
    end
    else if (BlockHighlightRange = brInnerBlock) and Assigned(Parser.InnerBlockStartToken)
      and Assigned(Parser.InnerBlockCloseToken) then
    begin
      for I := Parser.InnerBlockStartToken.ItemIndex to
        Parser.InnerBlockCloseToken.ItemIndex do
        if Parser.Tokens[I].TokenID in csKeyTokens then
          FKeyList.Add(Parser.Tokens[I]);
    end;

    UpdateCurTokenList;
    FCurrentBlockSearched := False;

  {$IFDEF DEBUG}
    CnDebugger.LogInteger(FKeyList.Count, 'HighLight KeyList Count.');
  {$ENDIF}
    Result := FKeyList.Count > 0;

    if Result then
    begin
      for I := 0 to Count - 1 do
      begin
        // 转换成 Col 与 Line
        CharPos := OTACharPos(Tokens[I].CharIndex, Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);
        // TODO: 以上这句在 D2009 中带汉字时结果会有偏差，暂无办法，只能按如下修饰
{$IFDEF BDS2009_UP}
        EditPos.Col := Tokens[I].CharIndex + 1;
{$ENDIF}
        Tokens[I].EditCol := EditPos.Col;
        Tokens[I].EditLine := EditPos.Line;
      end;
      UpdateLineList;
    end;

    if LineInfo <> nil then
    begin
      CheckLineMatch(EditView, GlobalIgnoreClass);
    {$IFDEF DEBUG}
      CnDebugger.LogInteger(LineInfo.Count, 'HighLight LinePairs Count.');
    {$ENDIF}
    end;
  end;

  try
    Control.Invalidate;
  except
    ;
  end;

  Changed := False;
  Modified := False;
end;

procedure TBlockMatchInfo.UpdateCurTokenList;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I: Integer;

  function InternalTokenMatch(const T1: AnsiString; const T2: AnsiString): Boolean;
  begin
    if CaseSensitive then
      Result := T1 = T2
    else
    begin
    {$IFDEF UNICODE}
      // Unicode 时直接调用 API 比较以避免生成临时字符串而影响性能
      Result := lstrcmpiA(@T1[1], @T2[1]) = 0;
    {$ELSE}
      Result := UpperCase(T1) = UpperCase(T2);
    {$ENDIF}
    end;
  end;  
begin
  FCurrentTokenName := '';
  FCurrentToken := nil;
  FCurMethodStartToken := nil;
  FCurMethodCloseToken := nil;

  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  for I := 0 to FCurTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(Integer(FCurTokenListEditLine[I]));

  FCurTokenList.Clear;
  FCurTokenListEditLine.Clear;
  if not FIsCppSource then
  begin
    if Assigned(Parser) then
    begin
      if not FCurrentBlockSearched then
      begin
        EditPos := EditView.CursorPos;
        EditView.ConvertPos(True, EditPos, CharPos);
        Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
      end;

    {$IFDEF DEBUG}
      if Assigned(Parser.MethodStartToken) and
        Assigned(Parser.MethodCloseToken) then
        CnDebugger.LogFmt('CurrentMethod: %s, MethodStartToken: %d, MethodCloseToken: %d',
          [Parser.CurrentMethod, Parser.MethodStartToken.ItemIndex, Parser.MethodCloseToken.ItemIndex]);
    {$ENDIF}

      if Assigned(Parser.MethodStartToken) and
        Assigned(Parser.MethodCloseToken) then
      begin
        FCurMethodStartToken := Parser.MethodStartToken;
        FCurMethodCloseToken := Parser.MethodCloseToken;
        for I := FCurMethodStartToken.ItemIndex to
          FCurMethodCloseToken.ItemIndex do
        begin
          CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
          EditView.ConvertPos(False, EditPos, CharPos);
{$IFDEF BDS2009_UP}
          EditPos.Col := Parser.Tokens[I].CharIndex + 1;
{$ENDIF}
          Parser.Tokens[I].EditCol := EditPos.Col;
          Parser.Tokens[I].EditLine := EditPos.Line;

          if (Parser.Tokens[I].TokenID = tkIdentifier) and // 此处判断不支持双字节字符
            IsCurrentToken(Pointer(EditView), FControl, Parser.Tokens[I]) then
          begin
            if FCurrentToken = nil then
            begin
              // 不能 Break，否则 Tokens 就没 EditLine 的更新了，下面也一样
              FCurrentToken := Parser.Tokens[I];
              FCurrentTokenName := FCurrentToken.Token;
            end;
          end;
        end;
      end
      else if FHighlight.BlockHighlightRange = brAll then// 无当前过程并且高亮所有内容时搜索当前所有标识符，避免只高亮光标出于当前过程内的问题
      begin
        for I := 0 to Parser.Count - 1 do
        begin
          CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
          EditView.ConvertPos(False, EditPos, CharPos);
{$IFDEF BDS2009_UP}
          EditPos.Col := Parser.Tokens[I].CharIndex + 1;
{$ENDIF}
          Parser.Tokens[I].EditCol := EditPos.Col;
          Parser.Tokens[I].EditLine := EditPos.Line;

          if (Parser.Tokens[I].TokenID = tkIdentifier) and // 此处判断不支持双字节字符
            IsCurrentToken(Pointer(EditView), FControl, Parser.Tokens[I]) then
          begin
            if FCurrentToken = nil then
            begin
              FCurrentToken := Parser.Tokens[I];
              FCurrentTokenName := FCurrentToken.Token;
            end;
          end;
        end;
      end;

      // 高亮整个单元时，或当前是过程名与类名时，高亮整个单元
      if ((FCurrentTokenName <> '') and (FHighlight.BlockHighlightRange = brAll))
        or TokenIsMethodOrClassName(string(FCurrentTokenName), string(Parser.CurrentMethod)) then
      begin
        for I := 0 to Parser.Count - 1 do
          if (Parser.Tokens[I].TokenID = tkIdentifier) and
            InternalTokenMatch(Parser.Tokens[I].Token, FCurrentTokenName) then
          begin
            FCurTokenList.Add(Parser.Tokens[I]);
            FCurTokenListEditLine.Add(Pointer(Parser.Tokens[I].EditLine));
          end;
      end
      else // 其它范围便默认改为高亮本过程的
      begin
        for I := FCurMethodStartToken.ItemIndex to
          FCurMethodCloseToken.ItemIndex do
          if (Parser.Tokens[I].TokenID = tkIdentifier) and
            InternalTokenMatch(Parser.Tokens[I].Token, FCurrentTokenName) then
          begin
            FCurTokenList.Add(Parser.Tokens[I]);
            FCurTokenListEditLine.Add(Pointer(Parser.Tokens[I].EditLine));
          end;
      end;
    end;

    FIdLineList.Clear;
    UpdateIdLineList;
  end
  else // 做 C/C++ 中的当前解析，将相同的标识符解析出来
  begin
    // 为了减少代码重构的工作量，此处 C/C++ 中当前解析出的标识符，仍旧用
    // TCnPasToken 来表示并加入 FCurTokenList 中，但和 Pascal 语言相关的属性
    // 均无效，只有 Token 名和位置等有效。因此 C/C++ 的高亮标识符不支持范围设置

    // 将解析出的同名 Token 按范围规定加入 FCurTokenList
    for I := 0 to CppParser.Count - 1 do
    begin
      CharPos := OTACharPos(CppParser.Tokens[I].CharIndex - 1, CppParser.Tokens[I].LineNumber);
      // 此处 LineNumber 无需加一了，因为 mwBCBTokenList 中的此属性是从 1 开始的
      // 反倒 CharIndex 得减一
      EditView.ConvertPos(False, EditPos, CharPos);
      CppParser.Tokens[I].EditCol := EditPos.Col;
      CppParser.Tokens[I].EditLine := EditPos.Line;

      if (CppParser.Tokens[I].CppTokenKind = ctkidentifier) and
        IsCurrentToken(Pointer(EditView), FControl, CppParser.Tokens[I]) then
      begin
        if FCurrentToken = nil then
        begin
          FCurrentToken := CppParser.Tokens[I];
          FCurrentTokenName := FCurrentToken.Token;
        end;
      end;
    end;

    if (FHighlight.BlockHighlightRange in [brMethod, brWholeBlock])
      and Assigned(CppParser.BlockStartToken) and Assigned(CppParser.BlockCloseToken) then
    begin
      for I := CppParser.BlockStartToken.ItemIndex to CppParser.BlockCloseToken.ItemIndex do
      begin
        if (CppParser.Tokens[I].CppTokenKind = ctkIdentifier) and
          InternalTokenMatch(CppParser.Tokens[I].Token, FCurrentTokenName) then
        begin
          FCurTokenList.Add(CppParser.Tokens[I]);
          FCurTokenListEditLine.Add(Pointer(CppParser.Tokens[I].EditLine));
        end;
      end;
    end
    else if (FHighlight.BlockHighlightRange in [brInnerBlock])
      and Assigned(CppParser.InnerBlockStartToken) and Assigned(CppParser.InnerBlockCloseToken) then
    begin
      for I := CppParser.InnerBlockStartToken.ItemIndex to CppParser.InnerBlockCloseToken.ItemIndex do
      begin
        if (CppParser.Tokens[I].CppTokenKind = ctkIdentifier) and
          InternalTokenMatch(CppParser.Tokens[I].Token, FCurrentTokenName) then
        begin
          FCurTokenList.Add(CppParser.Tokens[I]);
          FCurTokenListEditLine.Add(Pointer(CppParser.Tokens[I].EditLine));
        end;
      end;
    end
    else // 整个范围
    begin
      for I := 0 to CppParser.Count - 1 do
      begin
        if (CppParser.Tokens[I].CppTokenKind = ctkIdentifier) and
          InternalTokenMatch(CppParser.Tokens[I].Token, FCurrentTokenName) then
        begin
          FCurTokenList.Add(CppParser.Tokens[I]);
          FCurTokenListEditLine.Add(Pointer(CppParser.Tokens[I].EditLine));
        end;
      end;
    end;

    FIdLineList.Clear;
    UpdateIdLineList;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FCurTokenList.Count: %d; FCurrentTokenName: %s',
    [FCurTokenList.Count, FCurrentTokenName]);
{$ENDIF}

  for I := 0 to FCurTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnPasToken(FCurTokenList[I]).EditLine);
end;

procedure TBlockMatchInfo.CheckLineMatch(View: IOTAEditView; IgnoreClass: Boolean);
var
  I: Integer;
  Pair, PrevPair, IfThenPair: TBlockLinePair;
  Token: TCnPasToken;
  CToken: TCnCppToken;
  IfThenSameLine, Added: Boolean;
begin
  if (LineInfo <> nil) and (FKeyList.Count > 1) then
  begin
    // 遍历 KeyList 中的内容并将配对信息写入 LineInfo 中
    LineInfo.Clear;
    if FIsCppSource then // C/C++ 的大括号配对，比较简单
    begin
      try
        for I := 0 to FKeyList.Count - 1 do
        begin
          CToken := TCnCppToken(FKeyList[I]);
          if CToken.CppTokenKind = ctkbraceopen then
          begin
            Pair := TBlockLinePair.Create;
            Pair.StartToken := CToken;
            Pair.Top := CToken.EditLine;
            Pair.StartLeft := CToken.EditCol;
            Pair.Left := CToken.EditCol;
            Pair.Layer := CToken.ItemLayer - 1;

            FStack.Push(Pair);
          end
          else if CToken.CppTokenKind = ctkbraceclose then
          begin
            if FStack.Count = 0 then
              Continue;

            Pair := TBlockLinePair(FStack.Pop);

            Pair.EndToken := CToken;
            Pair.EndLeft := CToken.EditCol;
            if Pair.Left > CToken.EditCol then // Left 取两者间较小的
              Pair.Left := CToken.EditCol;
            Pair.Bottom := CToken.EditLine;

            LineInfo.AddPair(Pair);
          end;
        end;
        LineInfo.UpdateLineList;
        LineInfo.FindCurrentPair(View, FIsCppSource);
      finally
        for I := 0 to FStack.Count - 1 do
          TBlockLinePair(FStack.Pop).Free;
      end;
    end
    else // Pascal 的语法配对处理，复杂得多
    begin
      try
        for I := 0 to FKeyList.Count - 1 do
        begin
          Token := TCnPasToken(FKeyList[I]);
          if Token.IsBlockStart then
          begin
            Pair := TBlockLinePair.Create;
            Pair.StartToken := Token;
            Pair.Top := Token.EditLine;
            Pair.StartLeft := Token.EditCol;
            Pair.Left := Token.EditCol;
            Pair.Layer := Token.MethodLayer + Token.ItemLayer - 2;

            FStack.Push(Pair);
          end
          else if Token.IsBlockClose then
          begin
            if FStack.Count = 0 then
              Continue;

            Pair := TBlockLinePair(FStack.Pop);

            Pair.EndToken := Token;
            Pair.EndLeft := Token.EditCol;
            if Pair.Left > Token.EditCol then // Left 取两者间较小的
              Pair.Left := Token.EditCol;
            Pair.Bottom := Token.EditLine;

  {$IFDEF DEBUG}
  //          CnDebugger.LogFmt('Highlight Pair start %d %s meet end %d %s. Ignore: %d',
  //            [Ord(Pair.StartToken.TokenID), Pair.StartToken.Token,
  //             Ord(Pair.EndToken.TokenID), Pair.EndToken.Token, Integer(IgnoreClass)]);
  {$ENDIF}

            if Pair.StartToken.TokenID in [tkClass, tkRecord, tkInterface, tkDispInterface] then
            begin
              if not IgnoreClass then // 碰到 class record interface 时，需要画才添加进去
                LineInfo.AddPair(Pair)
              else
                Pair.Free;
            end
            else
            begin
              LineInfo.AddPair(Pair);
            
              // 判断已经有的 if then 块，如本层次比其底，说明 if then 块已经结束，需要剔除
              while FIfThenStack.Count > 0 do
              begin
                IfThenPair := TBlockLinePair(FIfThenStack.Peek);
                if IfThenPair.Layer > Pair.Layer then
                  FIfThenStack.Pop
                else
                  Break;
              end;  

              if (Pair.StartToken.TokenID = tkIf) and (Pair.EndToken.TokenID = tkThen) then
                FIfThenStack.Push(Pair);
              // 记下if then 块，让后面的 else 来配。注意已无需处理 on Exception do 块
            end;
          end
          else
          begin
            Added := False;
            if Token.TokenID in [tkElse, tkExcept, tkFinally] then
            begin
              // 处理几个中间带高亮语句的情形
              if FStack.Count > 0 then
              begin
                Pair := TBlockLinePair(FStack.Peek);
                if Pair <> nil then
                begin
                  if Pair.Layer = Token.MethodLayer + Token.ItemLayer - 2 then
                  begin
                    // 同一层次的，加入 MidToken
                    Pair.AddMidToken(Token, Token.EditCol);
                    Added := Token.TokenID <> tkExcept;
                  end;
                end;
              end;
            end;

            if not Added and (Token.TokenID = tkElse) and (FIfThenStack.Count > 0) then
            begin
              // 有 Else 并且上面没处理掉的话，找最近的一个同层的 if then 并重新配对，无需更高层的
              Pair := TBlockLinePair(FIfThenStack.Pop);
              while (FIfThenStack.Count > 0) and (Pair <> nil) and
                (Pair.Layer > Token.MethodLayer + Token.ItemLayer - 2) do
              begin
                Pair := TBlockLinePair(FIfThenStack.Pop);
              end;

              if (Pair <> nil) and (Pair.Layer = Token.MethodLayer + Token.ItemLayer - 2) then
              begin
                IfThenSameLine := Pair.StartToken.EditLine = Pair.EndToken.EditLine;
                Pair.AddMidToken(Pair.EndToken, Pair.EndToken.EditCol);

                Pair.EndToken := Token;
                Pair.EndLeft := Token.EditCol;
                if Pair.Left > Token.EditCol then // Left 取两者间较小的
                  Pair.Left := Token.EditCol;
                Pair.Bottom := Token.EditLine;

                // 重新配对完毕后，检查 else 前的一个 begin end 块
                // 如果本块 if then 同行，并且和前一个 begin end 块列相同，
                // 那么本块的竖线就不需要画了
                if IfThenSameLine and (LineInfo.Count > 0) then
                begin
                  PrevPair := LineInfo.Pairs[LineInfo.Count - 1];
                  if (PrevPair <> Pair) and (PrevPair.Left = Pair.Left) and (PrevPair.Bottom - PrevPair.Top > 1)
                    and (PrevPair.Top >= Pair.Top) and (PrevPair.Bottom <= Pair.Bottom) then
                  begin
                    Pair.DontDrawVert := True;
                  end;
                end;
              end;
            end;
          end;
        end;
        LineInfo.UpdateLineList;
        LineInfo.FindCurrentPair(View, FIsCppSource);
      finally
        for I := 0 to FIfThenStack.Count - 1 do
          FIfThenStack.Pop;
        for I := 0 to FStack.Count - 1 do
          TBlockLinePair(FStack.Pop).Free;
      end;
    end;
  end;
end;

procedure TBlockMatchInfo.Clear;
begin
  FKeyList.Clear;
  FCurTokenList.Clear;
  FCurTokenListEditLine.Clear;
  FLineList.Clear;
  FIdLineList.Clear;
  if LineInfo <> nil then
    LineInfo.Clear;
end;

procedure TBlockMatchInfo.AddToKeyList(AToken: TCnPasToken);
begin
  FKeyList.Add(AToken);
end;

procedure TBlockMatchInfo.AddToCurrList(AToken: TCnPasToken);
begin
  FCurTokenList.Add(AToken);
end;

constructor TBlockMatchInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FParser := TCnPasStructureParser.Create;
  FCppParser := TCnCppStructureParser.Create;
  FKeyList := TCnList.Create;
  FCurTokenList := TCnList.Create;
  FCurTokenListEditLine := TCnList.Create;
  FLineList := TCnObjectList.Create;
  FIdLineList := TCnObjectList.Create;
  FStack := TStack.Create;
  FIfThenStack := TStack.Create;
  FModified := True;
  FChanged := True;
end;

destructor TBlockMatchInfo.Destroy;
begin
  Clear;
  FStack.Free;
  FIfThenStack.Free;
  FLineList.Free;
  FIdLineList.Free;
  FCurTokenListEditLine.Free;
  FCurTokenList.Free;
  FKeyList.Free;
  FCppParser.Free;
  FParser.Free;
  inherited;
end;

function TBlockMatchInfo.GetCount: Integer;
begin
  Result := FKeyList.Count;
end;

function TBlockMatchInfo.GetTokens(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FKeyList[Index]);
end;

function TBlockMatchInfo.GetCurTokens(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FCurTokenList[Index]);
end;

function TBlockMatchInfo.GetCurTokenCount: Integer;
begin
  Result := FCurTokenList.Count;
end;

function TBlockMatchInfo.GetLineCount: Integer;
begin
  Result := FLineList.Count;
end;

function TBlockMatchInfo.GetIdLineCount: Integer;
begin
  Result := FIdLineList.Count;
end;

function TBlockMatchInfo.GetLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FLineList[LineNum]);
end;

function TBlockMatchInfo.GetIdLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FIdLineList[LineNum]);
end;

procedure TBlockMatchInfo.UpdateLineList;
var
  i: Integer;
  Token: TCnPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for i := 0 to FKeyList.Count - 1 do
  begin
    if Tokens[i].EditLine > MaxLine then
      MaxLine := Tokens[i].EditLine;
  end;
  FLineList.Count := MaxLine + 1;

  for i := 0 to FKeyList.Count - 1 do
  begin
    Token := Tokens[i];
    if FLineList[Token.EditLine] = nil then
      FLineList[Token.EditLine] := TCnList.Create;
    TCnList(FLineList[Token.EditLine]).Add(Token);
  end;

  if FHighlight.CurrentTokenHighlight then
  begin
    MaxLine := 0;
    for i := 0 to FCurTokenList.Count - 1 do
    begin
      if CurTokens[i].EditLine > MaxLine then
        MaxLine := CurTokens[i].EditLine;
    end;
    FIdLineList.Count := MaxLine + 1;

    for I := 0 to FCurTokenList.Count - 1 do
    begin
      Token := CurTokens[I];
      if FIdLineList[Token.EditLine] = nil then
        FIdLineList[Token.EditLine] := TCnList.Create;
      TCnList(FIdLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

procedure TBlockMatchInfo.UpdateIdLineList;
var
  I: Integer;
  Token: TCnPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FCurTokenList.Count - 1 do
    if CurTokens[I].EditLine > MaxLine then
      MaxLine := CurTokens[I].EditLine;
  FIdLineList.Count := MaxLine + 1;

  if FHighlight.CurrentTokenHighlight then
  begin
    for I := 0 to FCurTokenList.Count - 1 do
    begin
      Token := CurTokens[I];
      if FIdLineList[Token.EditLine] = nil then
        FIdLineList[Token.EditLine] := TCnList.Create;
      TCnList(FIdLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

{ TCnSourceHighlight }

constructor TCnSourceHighlight.Create;
begin
  inherited;
  FHighlight := Self;

  FMatchedBracket := True;
  FBracketColor := clBlack;
  FBracketColorBk := clAqua;
  FBracketColorBd := $CCCCD6;
  FBracketBold := False;
  FBracketMiddle := True;
  FBracketList := TObjectList.Create;

  FStructureHighlight := True;
  FBlockMatchHighlight := True;
  FBlockMatchBackground := clYellow; // 默认为黄色
{$IFNDEF BDS}
  FHighLightCurrentLine := True;     // 默认打开当前行高亮
  FHighLightLineColor := LoadIDEDefaultCurrentColor; // 根据当前不同的色彩设置来设置不同色彩

  FDefaultHighLightLineColor := FHighLightLineColor; // 用来判断与保存
{$ENDIF}
  FCurrentTokenHighlight := False;    // 默认改为 False
  FCurrentTokenBackground := csDefCurTokenColorBg;
  FCurrentTokenForeground := csDEfCurTokenColorFg;
  FCurrentTokenBorderColor := csDefCurTokenColorBd;

  FBlockHighlightRange := brAll;
  FBlockMatchDelay := 600;  // 默认延时 600 毫秒
  FBlockHighlightStyle := bsNow;

  FBlockMatchDrawLine := True; // 默认画线
  FBlockMatchLineWidth := 1;
  FBlockMatchLineClass := False;
  FBlockMatchLineHori := True;
  FBlockExtendLeft := True;
  // FBlockMatchLineStyle := lsTinyDot;
  FBlockMatchLineHoriDot := True;

  FKeywordHighlight := THighlightItem.Create;
  FIdentifierHighlight := THighlightItem.Create;
  FKeywordHighlight.Bold := True;

  FBlockMatchLineLimit := True;
  FBlockMatchMaxLines := 40000; // 大于此行数的 unit，不解析
  FBlockMatchList := TObjectList.Create;
  FBlockLineList := TObjectList.Create;
  FLineMapList := TObjectList.Create;
  FViewChangedList := TList.Create;
  FViewFileNameIsPascalList := TList.Create;
{$IFNDEF BDS}
  FCurLineList := TObjectList.Create;
{$ENDIF}
  FBlockShortCut := WizShortCutMgr.Add('', ShortCut(Ord('H'), [ssCtrl, ssShift]),
    OnHighlightExec);
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := FBlockMatchDelay;
  FTimer.OnTimer := OnHighlightTimer;

{$IFNDEF BDS}
  FCorIdeModule := LoadLibrary(CorIdeLibName);
  if GetProcAddress(FCorIdeModule, SSetForeAndBackColorName) <> nil then
    SetForeAndBackColor := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SSetForeAndBackColorName));
  Assert(Assigned(SetForeAndBackColor), 'Failed to load SetForeAndBackColor from CorIdeModule');

  SetForeAndBackColorHook := TCnMethodHook.Create(@SetForeAndBackColor,
    @MyEditorsCustomEditControlSetForeAndBackColor);
{$ENDIF}

  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
  EditControlWrapper.AddAfterPaintLineNotifier(PaintLine);
{$IFNDEF BDS}
  EditControlWrapper.AddBeforePaintLineNotifier(BeforePaintLine);
{$ENDIF}
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
  CnWizNotifierServices.AddAfterCompileNotifier(AfterCompile);
end;

destructor TCnSourceHighlight.Destroy;
begin
  FTimer.Free;
  FBracketList.Free;
  FBlockLineList.Free;
  FBlockMatchList.Free;
  FLineMapList.Free;
  FKeywordHighlight.Free;
  FIdentifierHighlight.Free;
  FDirtyList.Free;
  FViewFileNameIsPascalList.Free;
  FViewChangedList.Free;
{$IFNDEF BDS}
  FCurLineList.Free;
  SetForeAndBackColorHook.Free;
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);
{$ENDIF}

  WizShortCutMgr.DeleteShortCut(FBlockShortCut);
  CnWizNotifierServices.RemoveAfterCompileNotifier(AfterCompile);
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
{$IFNDEF BDS}
  EditControlWrapper.RemoveBeforePaintLineNotifier(BeforePaintLine);
{$ENDIF}
  EditControlWrapper.RemoveAfterPaintLineNotifier(PaintLine);
  FHighlight := nil;
  inherited;
end;

procedure TCnSourceHighlight.DoEnhConfig;
begin
  if Assigned(FOnEnhConfig) then
    FOnEnhConfig(Self);
end;

function TCnSourceHighlight.EditorGetTextRect(Editor: TEditorObject;
  APos: TOTAEditPos; AText: AnsiString; var ARect: TRect): Boolean;
begin
  with Editor do
  begin
    if InBound(APos.Line, EditView.TopRow, EditView.BottomRow) and
      InBound(APos.Col, EditView.LeftColumn, EditView.RightColumn) then
    begin
      ARect := Bounds(GutterWidth + (APos.Col - EditView.LeftColumn) * CharSize.cx,
        (APos.Line - EditView.TopRow) * CharSize.cy, CharSize.cx * Length(AText),
        CharSize.cy);
      Result := True;
    end
    else
      Result := False;
  end;
end;

procedure TCnSourceHighlight.EditorPaintText(EditControl: TControl; ARect:
  TRect; AText: AnsiString; AColor, AColorBk, AColorBd: TColor; ABold, AItalic,
  AUnderline: Boolean);
var
  SavePenColor, SaveBrushColor, SaveFontColor: TColor;
  SavePenStyle: TPenStyle;
  SaveBrushStyle: TBrushStyle;
  SaveFontStyles: TFontStyles;
  ACanvas: TCanvas;
begin
  ACanvas := EditControlWrapper.GetEditControlCanvas(EditControl);
  if ACanvas = nil then Exit;

  with ACanvas do
  begin
    SavePenColor := Pen.Color;
    SavePenStyle := Pen.Style;
    SaveBrushColor := Brush.Color;
    SaveBrushStyle := Brush.Style;
    SaveFontColor := Font.Color;
    SaveFontStyles := Font.Style;

    // Fill Background
    if AColorBk <> clNone then
    begin
      Brush.Color := AColorBk;
      Brush.Style := bsSolid;
      FillRect(ARect);
    end;

    // Draw Border
    if AColorBd <> clNone then
    begin
      Pen.Color := AColorBd;
      Brush.Style := bsClear;
      Rectangle(ARect);
    end;

    // Draw Text
    Font.Color := AColor;
    Font.Style := [];
    if ABold then
      Font.Style := Font.Style + [fsBold];
    if AItalic then
      Font.Style := Font.Style + [fsItalic];
    if AUnderline then
      Font.Style := Font.Style + [fsUnderline];
    Brush.Style := bsClear;
    TextOut(ARect.Left, ARect.Top, string(AText));

    Pen.Color := SavePenColor;
    Pen.Style := SavePenStyle;
    Brush.Color := SaveBrushColor;
    Brush.Style := SaveBrushStyle;
    Font.Color := SaveFontColor;
    Font.Style := SaveFontStyles;
  end;
end;

//------------------------------------------------------------------------------
// 括号匹配高亮
//------------------------------------------------------------------------------

function TCnSourceHighlight.IndexOfBracket(EditControl: TControl): Integer;
var
  i: Integer;
begin
  for i := 0 to FBracketList.Count - 1 do
    if TBracketInfo(FBracketList[i]).Control = EditControl then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

// 以下代码使用 EditControlWrapper.GetTextAtLine 来取得某一行的代码，
// 因为使用 EditView.CharPosToPos 转换线性位置在大文件时很慢
// 由于 GetTextAtLine 取得的文本是将 Tab 扩展成空格的，故不再使用 ConvertPos 来转换
function TCnSourceHighlight.GetBracketMatch(EditView: IOTAEditView;
  EditBuffer: IOTAEditBuffer; EditControl: TControl; AInfo: TBracketInfo):
  Boolean;
var
  i: Integer;
  CL, CR: AnsiChar;
  LText: AnsiString;
  PL, PR: TOTAEditPos;
  CharPos: TOTACharPos;
  BracketCount: Integer;
  BracketChars: PBracketArray;

  function InCommentOrString(APos: TOTAEditPos): Boolean;
  var
    Element, LineFlag: Integer;
  begin
    // IOTAEditView.GetAttributeAtPos 会导致选择区域失效、Undo 区混乱，故此处
    // 直接使用底层调用
    EditControlWrapper.GetAttributeAtPos(EditControl, APos, False, Element, LineFlag);
    Result := (Element = atComment) or (Element = atString) or
      (Element = atCharacter);
  end;

  function _FindMatchTokenDown(const FindToken, MatchToken: AnsiString;
    var ALine: AnsiString): TOTAEditPos;
  var
    i, j, l, Layer: Integer;
    TopLine, BottomLine: Integer;
    LineText: AnsiString;
  begin
    Result.Col := 0;
    Result.Line := 0;

    TopLine := CharPos.Line;
    BottomLine := Min(EditBuffer.GetLinesInBuffer, EditView.BottomRow);
    if TopLine <= BottomLine then
    begin
      Layer := 1;
      for i := TopLine to BottomLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, i) then
          Continue;
      {$ENDIF}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, i));
      {$IFDEF DELPHI2009_UP}
        LineText := CnAnsiToUtf8(LineText);
      {$ENDIF}
        if i = TopLine then
          l := CharPos.CharIndex + 1
        else
          l := 0;
        for j := l to Length(LineText) - 1 do
        begin
          if (LineText[j + 1] = FindToken) and
            not InCommentOrString(OTAEditPos(j + 1, i)) then
            Inc(Layer)
          else if (LineText[j + 1] = MatchToken) and
            not InCommentOrString(OTAEditPos(j + 1, i)) then
          begin
            Dec(Layer);
            if Layer = 0 then
            begin
              ALine := LineText;
              Result := OTAEditPos(j + 1, i);
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  function _FindMatchTokenUp(const FindToken, MatchToken: AnsiString;
    var ALine: AnsiString): TOTAEditPos;
  var
    i, j, l, Layer: Integer;
    TopLine, BottomLine: Integer;
    LineText: AnsiString;
  begin
    Result.Col := 0;
    Result.Line := 0;

    TopLine := EditView.GetTopRow;
    BottomLine := CharPos.Line;
    if TopLine <= BottomLine then
    begin
      Layer := 1;
      for i := BottomLine downto TopLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, i) then
          Continue;
      {$ENDIF}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, i));
      {$IFDEF DELPHI2009_UP}
        LineText := CnAnsiToUtf8(LineText);
      {$ENDIF}
        if i = BottomLine then
          l := CharPos.CharIndex - 1
        else
          l := Length(LineText) - 1;
        for j := l downto 0 do
        begin
          if (LineText[j + 1] = FindToken) and
            not InCommentOrString(OTAEditPos(j + 1, i)) then
            Inc(Layer)
          else if (LineText[j + 1] = MatchToken) and
            not InCommentOrString(OTAEditPos(j + 1, i)) then
          begin
            Dec(Layer);
            if Layer = 0 then
            begin
              ALine := LineText;
              Result := OTAEditPos(j + 1, i);
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  function _FindMatchTokenMiddle: Boolean;
  var
    i, j, k, l: Integer;
    ml, mr: Integer;
    TopLine, BottomLine, Cnt: Integer;
    LineText: AnsiString;
    Layers: array of Integer;
  begin
    Result := False;
    SetLength(Layers, BracketCount);
    CharPos.CharIndex := EditView.CursorPos.Col - 1;
    CharPos.Line := EditView.CursorPos.Line;
    TopLine := Min(CharPos.Line, EditView.TopRow);
    BottomLine := Min(EditBuffer.GetLinesInBuffer, Max(CharPos.Line, EditView.BottomRow));
    if TopLine <= BottomLine then
    begin
      ml := 0;
      mr := BracketCount - 1;
      for i := 0 to BracketCount - 1 do
        Layers[i] := 0;

      // 向前查找左括号
      Cnt := 0;
      for i := CharPos.Line downto TopLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, i) then
          Continue;
      {$ENDIF}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, i));
      {$IFDEF DELPHI2009_UP}
        LineText := CnAnsiToUtf8(LineText);
      {$ENDIF}
        if i = CharPos.Line then
          l := Min(CharPos.CharIndex, Length(LineText)) - 1
        else
          l := Length(LineText) - 1;
        for j := l downto 0 do
        begin
          for k := 0 to BracketCount - 1 do
            if (LineText[j + 1] = BracketChars^[k][0]) and
              not InCommentOrString(OTAEditPos(j + 1, i)) then
            begin
              if Layers[k] = 0 then
              begin
                AInfo.TokenStr := BracketChars^[k][0];
                AInfo.TokenLine := LineText;
                AInfo.TokenPos := OTAEditPos(j + 1, i);
                ml := k;
                mr := k;
                Break;
              end
              else
                Dec(Layers[k]);
            end
            else if (LineText[j + 1] = BracketChars^[k][1]) and
              not InCommentOrString(OTAEditPos(j + 1, i)) then
            begin
              Inc(Layers[k]);
            end;
          if AInfo.TokenStr <> '' then
            Break;
        end;
        if AInfo.TokenStr <> '' then
          Break;

        Inc(Cnt);
        if Cnt > csMaxBracketMatchLines then
          Break;
      end;

      for i := 0 to BracketCount - 1 do
        Layers[i] := 0;

      // 向后查找右括号
      Cnt := 0;
      for i := CharPos.Line to BottomLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, i) then
          Continue;
      {$ENDIF}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, i));
      {$IFDEF DELPHI2009_UP}
        LineText := CnAnsiToUtf8(LineText);
      {$ENDIF}
        if i = CharPos.Line then
          l := CharPos.CharIndex
        else
          l := 0;
        for j := l to Length(LineText) - 1 do
        begin
          for k := ml to mr do
            if (LineText[j + 1] = BracketChars^[k][1]) and
              not InCommentOrString(OTAEditPos(j + 1, i)) then
            begin
              if Layers[k] = 0 then
              begin
                AInfo.TokenMatchStr := BracketChars^[k][1];
                AInfo.TokenMatchLine := LineText;
                AInfo.TokenMatchPos := OTAEditPos(j + 1, i);
                Break;
              end
              else
                Dec(Layers[k]);
            end
            else if (LineText[j + 1] = BracketChars^[k][0]) and
              not InCommentOrString(OTAEditPos(j + 1, i)) then
            begin
              Inc(Layers[k]);
            end;
          if AInfo.TokenMatchStr <> '' then
            Break;
        end;
        if AInfo.TokenMatchStr <> '' then
          Break;

        Inc(Cnt);
        if Cnt > csMaxBracketMatchLines then
          Break;
      end;

      Layers := nil;
      Result := (AInfo.TokenStr <> '') or (AInfo.TokenMatchStr <> '');
    end;
  end;
begin
  Result := False;
  Assert(Assigned(EditView), 'EditView is nil.');
  Assert(Assigned(EditBuffer), 'EditBuffer is nil.');

  try
    AInfo.TokenStr := '';
    AInfo.TokenLine := '';
    AInfo.TokenPos := OTAEditPos(0, 0);
    AInfo.TokenMatchStr := '';
    AInfo.TokenMatchLine := '';
    AInfo.TokenMatchPos := OTAEditPos(0, 0);

    if IsDprOrPas(EditView.Buffer.FileName) then
    begin
      BracketCount := csBracketCountPas;
      BracketChars := @csBracketsPas;
    end
    else if IsCppSourceModule(EditView.Buffer.FileName) then
    begin
      BracketCount := csBracketCountCpp;
      BracketChars := @csBracketsCpp;
    end
    else
      Exit;

    if not CnOtaIsEditPosOutOfLine(EditView.CursorPos, EditView) and
      not InCommentOrString(EditView.CursorPos) then
    begin
      CharPos.CharIndex := EditView.CursorPos.Col - 1;
      CharPos.Line := EditView.CursorPos.Line;
      LText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, CharPos.Line));

      // 此处 CursorPos 是 utf8 的位置，LText 在 BDS 下是 UTF8，但在 D2009 下是
      // UnicodeString，因此下面的取下标等会出问题，所以全转成 UTF8 来处理。
      {$IFDEF DELPHI2009_UP}
      LText := CnAnsiToUtf8(LText);
      {$ENDIF}
      if LText <> '' then
      begin
        if CharPos.CharIndex > 0 then
        begin
          CL := LText[CharPos.CharIndex];
          PL := EditView.CursorPos;
          Dec(PL.Col);
        end
        else
        begin
          CL := #0;
          PL := OTAEditPos(0, 0);
        end;
        CR := LText[CharPos.CharIndex + 1];
        PR := EditView.CursorPos;
        for i := 0 to BracketCount - 1 do
          if CL = BracketChars^[i][0] then
          begin
            AInfo.TokenStr := CL;
            AInfo.TokenLine := LText;
            AInfo.TokenPos := PL;
            CharPos := OTACharPos(PL.Col - 1, PL.Line);
            AInfo.TokenMatchStr := BracketChars^[i][1];
            AInfo.TokenMatchPos := _FindMatchTokenDown(AInfo.TokenStr,
              AInfo.TokenMatchStr, AInfo.FTokenMatchLine);
            Result := True;
            Break;
          end
          else if CR = BracketChars^[i][1] then
          begin
            AInfo.TokenStr := CR;
            AInfo.TokenLine := LText;
            AInfo.TokenPos := PR;
            CharPos := OTACharPos(PR.Col - 1, PR.Line);
            AInfo.TokenMatchStr := BracketChars^[i][0];
            AInfo.TokenMatchPos := _FindMatchTokenUp(AInfo.TokenStr,
              AInfo.TokenMatchStr, AInfo.FTokenMatchLine);
            Result := True;
            Break;
          end;
      end;
    end;

    // 查找在括号中间的情形
    if not Result and FBracketMiddle then
      Result := _FindMatchTokenMiddle;

{$IFDEF BDS}
    // BDS 下 LineText 是 Utf8，EditView.CursorPos.Col 也是 Utf8 字符串中的位置
    // 此处转换为 AnsiString 位置。D2009 中 LineText 虽不是 Utf8，但已经在上面转
    // 成了 UTF8 来参与计算，因此这儿仍然需要转回。
    if Result then
    begin
      AInfo.FTokenPos.Col := Length(CnUtf8ToAnsi(AnsiString(Copy(AInfo.TokenLine, 1,
        AInfo.TokenPos.Col))));
      AInfo.FTokenMatchPos.Col := Length(CnUtf8ToAnsi(AnsiString(Copy(AInfo.TokenMatchLine, 1,
        AInfo.TokenMatchPos.Col))));
    end;
{$ENDIF}
  finally
    AInfo.IsMatch := Result;
  end;
end;

procedure TCnSourceHighlight.CheckBracketMatch(Editor: TEditorObject);
var
  IsMatch: Boolean;
  Info: TBracketInfo;
begin
  if FIsChecking then Exit;
  FIsChecking := True;
  
  with Editor do
  try
    if IndexOfBracket(EditControl) >= 0 then
      Info := TBracketInfo(FBracketList[IndexOfBracket(EditControl)])
    else
    begin
      Info := TBracketInfo.Create(EditControl);
      FBracketList.Add(Info);
    end;

    // 取匹配括号
    Info.TokenPos := OTAEditPos(0, 0);
    Info.TokenMatchPos := OTAEditPos(0, 0);
    IsMatch := FMatchedBracket and (EditView <> nil) and (EditView.Buffer <> nil)
      and (EditControl <> nil) and (EditControl is TWinControl) and // BDS is WinControl
      GetBracketMatch(EditView, EditView.Buffer, EditControl, Info);

    // 恢复上一次的高亮内容
    if not SameEditPos(Info.LastPos, Info.TokenPos) and
      not SameEditPos(Info.LastPos, Info.TokenMatchPos) then
    begin
      EditorMarkLineDirty(Info.LastPos.Line);
    end;

    if not SameEditPos(Info.LastMatchPos, Info.TokenMatchPos) and
      not SameEditPos(Info.LastMatchPos, Info.TokenPos) then
    begin
      EditorMarkLineDirty(Info.LastMatchPos.Line);
    end;

    Info.LastPos := Info.TokenPos;
    Info.LastMatchPos := Info.TokenMatchPos;

    // 显示当前内容
    if IsMatch then
    begin
      EditorMarkLineDirty(Info.TokenPos.Line);
      EditorMarkLineDirty(Info.TokenMatchPos.Line);
    end;
  finally
    FIsChecking := False;
  end;
end;

procedure TCnSourceHighlight.PaintBracketMatch(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  R: TRect;
  Info: TBracketInfo;
begin
  with Editor do
  begin
    if IndexOfBracket(EditControl) >= 0 then
    begin
      Info := TBracketInfo(FBracketList[IndexOfBracket(EditControl)]);
      if Info.IsMatch then
      begin
        if (LogicLineNum = Info.TokenPos.Line) and EditorGetTextRect(Editor,
          OTAEditPos(Info.TokenPos.Col, LineNum), Info.TokenStr, R) then
          EditorPaintText(EditControl, R, Info.TokenStr, BracketColor,
            BracketColorBk, BracketColorBd, BracketBold, False, False);

        if (LogicLineNum = Info.TokenMatchPos.Line) and EditorGetTextRect(Editor,
          OTAEditPos(Info.TokenMatchPos.Col, LineNum), Info.TokenMatchStr, R) then
          EditorPaintText(EditControl, R, Info.TokenMatchStr, BracketColor,
            BracketColorBk, BracketColorBd, BracketBold, False, False);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 结构高亮显示
//------------------------------------------------------------------------------

function TCnSourceHighlight.IndexOfBlockMatch(EditControl: TControl): Integer;
var
  i: Integer;
begin
  for i := 0 to FBlockMatchList.Count - 1 do
    if TBlockMatchInfo(FBlockMatchList[i]).Control = EditControl then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

function TCnSourceHighlight.IndexOfBlockLine(EditControl: TControl): Integer;
var
  i: Integer;
begin
  for i := 0 to FBlockLineList.Count - 1 do
    if TBlockLineInfo(FBlockLineList[i]).Control = EditControl then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

procedure TCnSourceHighlight.ClearHighlight(Editor: TEditorObject);
begin
  if IndexOfBlockMatch(Editor.EditControl) >= 0 then
    with TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(Editor.EditControl)]) do
    begin
      FKeyList.Clear;
      FLineList.Clear;
      FIdLineList.Clear;
      if LineInfo <> nil then
        LineInfo.Clear;
    end;

  if IndexOfBlockLine(Editor.EditControl) >= 0 then
    with TBlockLineInfo(FBlockLineList[IndexOfBlockLine(Editor.EditControl)]) do
    begin
      Clear;
    end;

  if IndexOfBracket(Editor.EditControl) >= 0 then
    with TBracketInfo(FBracketList[IndexOfBracket(Editor.EditControl)]) do
    begin
      IsMatch := False;
    end;
end;

// Editor 内容改变时被调用，进行语法分析
procedure TCnSourceHighlight.UpdateHighlight(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
var
  OldPair, NewPair: TBlockLinePair;
  Info: TBlockMatchInfo;
  Line: TBlockLineInfo;
{$IFNDEF BDS}
  CurLine: TCurLineInfo;
{$ENDIF}
  I: Integer;
  CurTokenRefreshed: Boolean;
begin
  with Editor do
  begin
    // 一个 EditControl 对应一个 TBlockMatchInfo，都放 FBlockMatchList 中
    if IndexOfBlockMatch(EditControl) >= 0 then
      Info := TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)])
    else
    begin
      Info := TBlockMatchInfo.Create(EditControl);
      FBlockMatchList.Add(Info);
    end;

    // 设定是否大小写，用于当前标识符比较
    I := FViewChangedList.IndexOf(Editor);
    if I >= 0 then
    begin
      Info.CaseSensitive := not Boolean(FViewFileNameIsPascalList[I]);
      Info.IsCppSource := not Boolean(FViewFileNameIsPascalList[I]);
    end;

    Line := nil;
    if FBlockMatchDrawLine or FBlockMatchHighlight then
    begin
      // 如果画线结构高亮，则同时生成画线结构高亮的对象
      if IndexOfBlockLine(EditControl) >= 0 then
        Line := TBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)])
      else
      begin
        Line := TBlockLineInfo.Create(EditControl);
        FBlockLineList.Add(Line);
      end;
    end;

{$IFNDEF BDS}
    CurLine := nil;
    if FHighLightCurrentLine then
    begin
      // 如果高亮当前行的背景，则同时生成高亮背景的对象
      if IndexOfCurLine(EditControl) >= 0 then
        CurLine := TCurLineInfo(FCurLineList[IndexOfCurLine(EditControl)])
      else
      begin
        CurLine := TCurLineInfo.Create(EditControl);
        FCurLineList.Add(CurLine);
      end;
    end;

    if FHighLightCurrentLine and (ChangeType * [ctView, ctCurrLine] <> []) then
    begin
      if CurLine.CurrentLine > 0 then
        EditorMarkLineDirty(CurLine.CurrentLine);
      CurLine.CurrentLine := Editor.EditView.CursorPos.Line;
      EditorMarkLineDirty(CurLine.CurrentLine);
    end;
{$ENDIF}

    if (ChangeType * [ctView, ctModified, ctElided, ctUnElided] <> []) or
      ((FBlockHighlightRange <> brAll) and (ChangeType * [ctCurrLine, ctCurrCol] <> [])) then
    begin
      FTimer.Enabled := False;

      // 展开以及变动的情况，或者局部高亮时位置改动的情况，重新解析
      Info.FKeyList.Clear;
      Info.FLineList.Clear;
      Info.FIdLineList.Clear;
      if Info.LineInfo <> nil then
        Info.LineInfo.Clear;
      // 以上不能调用 Info.Clear 来简单清除所有内容，必须不清 FCurTokenList
      // 避免重画时不能刷新

      if Line <> nil then
        Line.Clear;

      Info.LineInfo := Line;
      Info.FChanged := True;
      Info.FModified := ChangeType * [ctView, ctModified] <> [];

      if (EditView <> nil) then
      begin
        if not FBlockMatchLineLimit or
          (EditView.Buffer.GetLinesInBuffer <= FBlockMatchMaxLines) then
        begin
          // 正常情况下，延时一段时间再解析以避免重复
          case BlockHighlightStyle of
            bsNow: FTimer.Interval := csShortDelay;
            bsDelay: FTimer.Interval := BlockMatchDelay;
            bsHotkey: Exit;
          end;
          FTimer.Enabled := True;
        end
        else // 大小超过了限制
        begin
          FTimer.Enabled := False;
        end;
      end;
    end
    else if not FTimer.Enabled then // 如果定时器已经开启，则不再处理
    begin
      CurTokenRefreshed := False;
      if ChangeType * [ctCurrLine, ctCurrCol] <> [] then
      begin
        if FCurrentTokenHighlight and not CurTokenRefreshed then
        begin
          Info.UpdateCurTokenList;
          CurTokenRefreshed := True;
        end;

        // 只位置变动的话，只更新高亮显示关键字
        if (Line <> nil) and (EditView <> nil) then
        begin
          OldPair := Line.CurrentPair;
          Line.FindCurrentPair(EditView); // 暂时不处理C/C++的情况
          NewPair := Line.CurrentPair;
          if OldPair <> NewPair then
          begin
            if OldPair <> nil then
            begin
              EditorMarkLineDirty(OldPair.Top);
              EditorMarkLineDirty(OldPair.Bottom);
              for I := 0 to OldPair.MiddleCount - 1 do
                EditorMarkLineDirty(OldPair.MiddleToken[I].EditLine);
            end;
            if NewPair <> nil then
            begin
              EditorMarkLineDirty(NewPair.Top);
              EditorMarkLineDirty(NewPair.Bottom);
              for I := 0 to NewPair.MiddleCount - 1 do
                EditorMarkLineDirty(NewPair.MiddleToken[I].EditLine);
            end;
          end;
        end;
      end;

      if FCurrentTokenHighlight and not CurTokenRefreshed then
      begin
        if ctHScroll in ChangeType then
        begin
          Info.UpdateCurTokenList;
        end
        else if ctVScroll in ChangeType then
          RefreshCurrentTokens(Info);
      end;
    end;
  end;
end;

// 上面的延时到时间了，开始解析
procedure TCnSourceHighlight.OnHighlightTimer(Sender: TObject);
var
  i: Integer;
  Info: TBlockMatchInfo;
begin
  FTimer.Enabled := False;

  if FIsChecking then Exit;
  GlobalIgnoreClass := not FBlockMatchLineClass;

  FIsChecking := True;
  try
    for i := 0 to FBlockMatchList.Count - 1 do
    begin
      Info := TBlockMatchInfo(FBlockMatchList[i]);

      // CheckBlockMatch 时会设置 FChanged
      if Info.FChanged then
        Info.CheckBlockMatch(BlockHighlightRange);
    end;
  finally
    FIsChecking := False;
  end;
end;

procedure TCnSourceHighlight.OnHighlightExec(Sender: TObject);
var
  i: Integer;
  Info: TBlockMatchInfo;
  Line: TBlockLineInfo;
begin
  if FIsChecking then Exit;
  FIsChecking := True;
  GlobalIgnoreClass := not FBlockMatchLineClass;
  try
    begin
      for i := 0 to FBlockMatchList.Count - 1 do
      begin
        try
          Info := TBlockMatchInfo(FBlockMatchList[i]);
          if (FBlockMatchDrawLine or FBlockMatchHighlight) and (Info.LineInfo = nil) then
          begin
            // 如果画线结构高亮但之前无画线对象，则同时生成画线结构高亮的对象
            Line := TBlockLineInfo.Create(Info.Control);
            FBlockLineList.Add(Line);
            Info.LineInfo := Line;
          end;
          Info.FChanged := True;
          Info.FModified := True;
          Info.CheckBlockMatch(BlockHighlightRange);
        except
          ;
        end;
      end;
    end;
  finally
    FIsChecking := False;
  end;
end;

procedure TCnSourceHighlight.SetBlockMatchLineClass(const Value: Boolean);
begin
  FBlockMatchLineClass := Value;
  GlobalIgnoreClass := not Value;
end;

function TCnSourceHighlight.GetColorFg(ALayer: Integer): TColor;
begin
  if ALayer < 0 then ALayer := -1;
  Result := FHighLightColors[ ALayer mod 6 ];
   // HSLToRGB(ALayer / 7, 1, 0.5);
end;

procedure TCnSourceHighlight.PaintBlockMatchKeyword(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  R, R1: TRect;
  I, J, Layer: Integer;
  Info: TBlockMatchInfo;
  LineInfo: TBlockLineInfo;
  Token: TCnPasToken;
  EditPos: TOTAEditPos;
  EditPosColBase: Integer;
  ColorFg, ColorBk: TColor;
  Element, LineFlag: Integer;
  Pair: TBlockLinePair;
  SavePenColor, SaveBrushColor, SaveFontColor: TColor;
  SavePenStyle: TPenStyle;
  SaveBrushStyle: TBrushStyle;
  SaveFontStyles: TFontStyles;
  EditCanvas: TCanvas;
  TokenLen: Integer;
  CanDrawToken: Boolean;
begin
  with Editor do
  begin
    if IndexOfBlockMatch(EditControl) >= 0 then
    begin
      // 找到该 EditControl对应的BlockMatch列表
      Info := TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)]);
      if (Info.Count > 0) or (Info.CurTokenCount > 0) then
      begin
        EditCanvas := EditControlWrapper.GetEditControlCanvas(EditControl);

        // 同时做关键字背景匹配高亮，可能由 MarkLinesDirty 调用
        Pair := nil;
        if FBlockMatchHighlight then
        begin
          if IndexOfBlockLine(EditControl) >= 0 then
          begin
            LineInfo := TBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)]);
            if (LineInfo.CurrentPair <> nil) and ((LineInfo.CurrentPair.Top = LogicLineNum)
              or (LineInfo.CurrentPair.Bottom = LogicLineNum)
              or (LineInfo.CurrentPair.IsInMiddle(LogicLineNum))) then
            begin
              // 寻找当前行已经配对的 Pair
              Pair := LineInfo.CurrentPair;
            end;
          end;
        end;

        // 保存 EditCanvas 的旧内容
        with EditCanvas do
        begin
          SavePenColor := Pen.Color;
          SavePenStyle := Pen.Style;
          SaveBrushColor := Brush.Color;
          SaveBrushStyle := Brush.Style;
          SaveFontColor := Font.Color;
          SaveFontStyles := Font.Style;
        end;

        // BlockMatch 里有多个TCnPasToken
        if (LogicLineNum < Info.LineCount) and (Info.Lines[LogicLineNum] <> nil) then
        begin
          with EditCanvas do
          begin
            Font.Style := [];
            if FKeywordHighlight.Bold then
              Font.Style := Font.Style + [fsBold];
            if FKeywordHighlight.Italic then
              Font.Style := Font.Style + [fsItalic];
            if FKeywordHighlight.Underline then
              Font.Style := Font.Style + [fsUnderline];
          end;

          for I := 0 to Info.Lines[LogicLineNum].Count - 1 do
          begin
            Token := TCnPasToken(Info.Lines[LogicLineNum][I]);

            Layer := Token.MethodLayer + Token.ItemLayer - 2;
            if FStructureHighlight then
              ColorFg := GetColorFg(Layer)
            else
              ColorFg := FKeywordHighlight.ColorFg;

            ColorBk := clNone; // 只有当前Token在当前Pair内才高亮背景
            if Pair <> nil then
            begin
              if (Pair.StartToken = Token) or (Pair.EndToken = Token) or
                (Pair.IndexOfMiddleToken(Token) >= 0) then
                ColorBk := FBlockMatchBackground;
            end;

            if not FStructureHighlight and (ColorBk = clNone) then
              Continue; // 不层次高亮时，如无当前背景高亮，则不画

            EditCanvas.Font.Color := ColorFg;

            // 因为关键字的 Token 中不会出现双字节字符，因此只需计算一次 EditPosColBase 即可
            EditPosColBase := Token.EditCol;
            {$IFDEF BDS}
              // GetAttributeAtPos 需要的是 UTF8 的Pos，因此进行 Col 的 UTF8 转换
              // 但实际上并非如此转换的简单，因为有部分双字节字符如 Accent Char
              // 等自身只占一个字符的位置，并非如汉字字符一样占两个字符位置，因此
              // 代码中有此等字符时会出现错位的情况，BDS 都有这个问题。
              if FLineText <> '' then
                EditPosColBase := Length(CnAnsiToUtf8(Copy(FLineText, 1, Token.EditCol)));
            {$ENDIF}

            // 挨个字符重画以免影响选择效果，如果是高亮，ColorBk已设置好
            for J := 0 to Length(Token.Token) - 1 do
            begin
              EditPos := OTAEditPos(Token.EditCol + J, LineNum);
              if not EditorGetTextRect(Editor, EditPos, Token.Token[J], R) then
                Continue;

              EditPos.Col := EditPosColBase + J;
              EditPos.Line := Token.EditLine;
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);

              if (Element = atReservedWord) and (LineFlag = 0) then
              begin
                // 在位置上画加粗的关键字，背景色已设置好
                with EditCanvas do
                begin
                  if ColorBk <> clNone then
                  begin
                    Brush.Color := ColorBk;
                    Brush.Style := bsSolid;
                    FillRect(R);
                  end;

                  Brush.Style := bsClear;
                  TextOut(R.Left, R.Top, string(Token.Token[J]));
                  // 注意下标，Token 是 string 和 PAnsiChar 时起点不同
                end;
              end;
            end;
          end;
        end;

        // 如果有需要高亮绘制的标识符内容
        if FCurrentTokenHighlight and (LogicLineNum < Info.IdLineCount) and
          (Info.IdLines[LogicLineNum] <> nil) then
        begin
          with EditCanvas do
          begin
            Font.Style := [];
            Font.Color := FIdentifierHighlight.ColorFg;
            if FIdentifierHighlight.Bold then
              Font.Style := Font.Style + [fsBold];
            if FIdentifierHighlight.Italic then
              Font.Style := Font.Style + [fsItalic];
            if FIdentifierHighlight.Underline then
              Font.Style := Font.Style + [fsUnderline];
          end;

          for I := 0 to Info.IdLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnPasToken(Info.IdLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(Token.EditCol, LineNum);
            if not EditorGetTextRect(Editor, EditPos, Token.Token, R) then
              Continue;

            EditPos.Col := Token.EditCol;
            EditPos.Line := Token.EditLine;

            // Token 前也就是初始 EditCol 需要 UTF8 转换
{$IFDEF BDS}
            if FLineText <> '' then
              EditPos.Col := Length(CnAnsiToUtf8(Copy(FLineText, 1, Token.EditCol)));
{$ENDIF}
            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              // 此处循环内本来需要一个 UTF8 的位置转换，但目前解析出来的 Token 不包含
              // 双字节字符，因此 Token 内暂不需要转换。
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier]);

              if not CanDrawToken then // 如果中间有选择区，则不画
                Break;
              Inc(EditPos.Col);
            end;

            if CanDrawToken then
            begin
              // 在位置上画背景高亮的标识符
              with EditCanvas do
              begin
                R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
                if FCurrentTokenBackground <> clNone then
                begin
                  Brush.Color := FCurrentTokenBackground;
                  Brush.Style := bsSolid;
                  FillRect(R1);
                end;                  

                Brush.Style := bsClear;
                if (FCurrentTokenBorderColor <> clNone) and
                  (FCurrentTokenBorderColor <> FCurrentTokenBackground) then
                begin
                  Pen.Color := FCurrentTokenBorderColor;
                  Rectangle(R1);
                end;
                
                Font.Color := FCurrentTokenForeground;
                TextOut(R.Left, R.Top, string(Token.Token));
              end;
            end;
          end;
        end;

        // 恢复旧的
        with EditCanvas do
        begin
          Pen.Color := SavePenColor;
          Pen.Style := SavePenStyle;
          Brush.Color := SaveBrushColor;
          Brush.Style := SaveBrushStyle;
          Font.Color := SaveFontColor;
          Font.Style := SaveFontStyles;
        end;
      end;
    end;
  end;
end;

procedure TCnSourceHighlight.PaintBlockMatchLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  LineInfo: TBlockLineInfo;
  Info: TBlockMatchInfo;
  I, J: Integer;
  R1, R2: TRect;
  Pair: TBlockLinePair;
  SavePenColor: TColor;
  SavePenWidth: Integer;
  SavePenStyle: TPenStyle;
  EditPos1, EditPos2: TOTAEditPos;
  EditorCanvas: TCanvas;
  LineFirstToken: TCnPasToken;
  EndLineStyle: TCnLineStyle;

  function EditorGetEditPoint(APos: TOTAEditPos; var ARect: TRect): Boolean;
  begin
    with Editor, Editor.EditView do
    begin
      if InBound(APos.Line, TopRow, BottomRow) and
        InBound(APos.Col, LeftColumn, RightColumn) then
      begin
        ARect := Bounds(GutterWidth + (APos.Col - LeftColumn) * CharSize.cx,
          (APos.Line - TopRow) * CharSize.cy, CharSize.cx * 1,
          CharSize.cy); // 得到 EditPos 处一个字符所在的绘制框框
        Result := True;
      end
      else
        Result := False;
    end;        
  end;
begin
  with Editor do
  begin
    if IndexOfBlockLine(EditControl) >= 0 then
    begin
      LineInfo := TBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)]);
      if IndexOfBlockMatch(EditControl) >= 0 then
        Info := TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)])
      else
        Info := nil;

      if LineInfo.Count > 0 then
      begin
        EditorCanvas := EditControlWrapper.GetEditControlCanvas(EditControl);
        SavePenColor := EditorCanvas.Pen.Color;
        SavePenWidth := EditorCanvas.Pen.Width;
        SavePenStyle := EditorCanvas.Pen.Style;

        if FBlockMatchDrawLine then
        begin
          if (LogicLineNum < LineInfo.LineCount) and (LineInfo.Lines[LogicLineNum] <> nil) then
          begin
            EditorCanvas.Pen.Width := FBlockMatchLineWidth; // 线宽

            for I := 0 to LineInfo.Lines[LogicLineNum].Count - 1 do
            begin
              // 一个 EditControl 的 LineInfo 中有多个配对画线的信息 LinePair
              Pair := TBlockLinePair(LineInfo.Lines[LogicLineNum][I]);
              EditorCanvas.Pen.Color := GetColorFg(Pair.Layer);

              if FBlockExtendLeft and (Info <> nil) and (LogicLineNum = Pair.Top)
                and (Pair.EndToken.EditLine > Pair.StartToken.EditLine) then
              begin
                // 处理前面还有 token 的情形，找 Start/End Token 所在行的第一个 Token
                if Info.Lines[LogicLineNum].Count > 0 then
                begin
                  LineFirstToken := TCnPasToken(Info.Lines[LogicLineNum][0]);
                  if LineFirstToken <> Pair.StartToken then
                  begin
                    if Pair.Left > LineFirstToken.EditCol then
                    begin
                      Pair.Left := LineFirstToken.EditCol;
                    end;
                  end;
                end;

                if Pair.EndToken.EditLine < Info.LineCount then
                begin
                  if Info.Lines[Pair.EndToken.EditLine].Count > 0 then
                  begin
                    LineFirstToken := TCnPasToken(Info.Lines[Pair.EndToken.EditLine][0]);

                    if LineFirstToken <> Pair.EndToken then
                    begin
                      if Pair.Left > LineFirstToken.EditCol then
                      begin
                        Pair.Left := LineFirstToken.EditCol;
                      end;
                    end;
                  end;
                end;
              end;

              EditPos1 := OTAEditPos(Pair.Left, LineNum); // 用实际行去计算座标
              // 得到 R1，是 Left 需要绘制的位置
              if not EditorGetEditPoint(EditPos1, R1) then
                Continue;

              // 画配对头尾
              if LogicLineNum = Pair.Top then
              begin
                // 画配对头，横向从 Left 到 StartLeft
                EditPos2 := OTAEditPos(Pair.StartLeft, LineNum);
                if not EditorGetEditPoint(EditPos2, R2) then
                  Continue;

                if FBlockMatchLineEnd and (Pair.Top <> Pair.Bottom) then // 在文字头上画方框
                begin
                  if FBlockMatchLineHoriDot and (Pair.StartLeft <> Pair.Left) then
                    EndLineStyle := lsTinyDot // 和主竖线不同列时，用虚线画框
                  else
                    EndLineStyle := FBlockMatchLineStyle;

                  // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Bottom - 1,
                  //  R2.Right, R2.Bottom - 1, EndLineStyle); 头不画底
                  HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                    R2.Right, R2.Top, EndLineStyle);
                  HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                    R2.Left, R2.Bottom, EndLineStyle);
                end;

                if FBlockMatchLineHori and (Pair.Top <> Pair.Bottom) then  // 往右端画底
                begin
                  if FBlockMatchLineHoriDot then // 右端底用虚线
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, lsTinyDot)
                  else
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);
                end;
              end
              else if LogicLineNum = Pair.Bottom then
              begin
                // 画配对尾，横向从 Left 到 EndLeft
                EditPos2 := OTAEditPos(Pair.EndLeft, LineNum);
                if not EditorGetEditPoint(EditPos2, R2) then
                  Continue;

                if FBlockMatchLineEnd  and (Pair.Top <> Pair.Bottom) then // 在文字头上画方框
                begin
                  if FBlockMatchLineHoriDot and (Pair.EndLeft <> Pair.Left) then
                    EndLineStyle := lsTinyDot // 和主竖线不同列时，用虚线画框
                  else
                    EndLineStyle := FBlockMatchLineStyle;

                  HighlightCanvasLine(EditorCanvas, R2.Left, R2.Bottom - 1,
                    R2.Right, R2.Bottom - 1, EndLineStyle);
                  // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                  //   R2.Right, R2.Top, EndLineStyle); 尾不画顶

                  if Pair.EndLeft = Pair.Left then
                    HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                      R2.Left, R2.Bottom - 1, EndLineStyle); // 左不同列时尾不画竖
                end;

                if Pair.Left <> Pair.EndLeft then
                  HighlightCanvasLine(EditorCanvas, R1.Left, R1.Top, R1.Left,
                    R1.Bottom, FBlockMatchLineStyle);

                if FBlockMatchLineHori and (Pair.Top <> Pair.Bottom) and (Pair.Left <> Pair.EndLeft) then  // 往右端画底，已经包括了竖线上画底的情况
                begin
                  if FBlockMatchLineHoriDot then // 右端底用虚线
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, lsTinyDot)
                  else
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);
                end;
              end
              else if (LogicLineNum < Pair.Bottom) and (LogicLineNum > Pair.Top) then
              begin
                // 在不画 [ 时，有时候不需要画配对中的竖线，竖向画 Left 线
                if not Pair.DontDrawVert or FBlockMatchLineEnd then
                  HighlightCanvasLine(EditorCanvas, R1.Left, R1.Top, R1.Left,
                    R1.Bottom, FBlockMatchLineStyle);

                if FBlockMatchLineHori and (Pair.MiddleCount > 0) then
                begin
                  for J := 0 to Pair.MiddleCount - 1 do
                  begin
                    if LogicLineNum = Pair.MiddleToken[J].EditLine then
                    begin
                      EditPos2 := OTAEditPos(Pair.MiddleToken[J].EditCol, LineNum);
                      if not EditorGetEditPoint(EditPos2, R2) then
                        Continue;

                      // 画中央的横线
                      if FBlockMatchLineHoriDot then
                        HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                          R2.Left, R2.Bottom - 1, lsTinyDot)
                      else
                        HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                          R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);

                      if FBlockMatchLineEnd then // 在文字头上画方框
                      begin
                        if FBlockMatchLineHoriDot and (Pair.MiddleToken[J].EditCol <> Pair.Left) then
                          EndLineStyle := lsTinyDot // 和主竖线不同列时，用虚线画框
                        else
                          EndLineStyle := FBlockMatchLineStyle;

                        HighlightCanvasLine(EditorCanvas, R2.Left, R2.Bottom - 1,
                          R2.Right, R2.Bottom - 1, EndLineStyle);
                        // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                        //   R2.Right, R2.Top, EndLineStyle);
                        // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                        //   R2.Left, R2.Bottom - 1, EndLineStyle);
                        // 中只画底
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;

        EditorCanvas.Pen.Color := SavePenColor;
        EditorCanvas.Pen.Width := SavePenWidth;
        EditorCanvas.Pen.Style := SavePenStyle;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 通知事件
//------------------------------------------------------------------------------

procedure TCnSourceHighlight.EditControlNotify(
  EditControl: TControl; EditWindow: TCustomForm; Operation: TOperation);
var
  Idx: Integer;
begin
  if Operation = opRemove then
  begin
    Idx := IndexOfBracket(EditControl);
    if Idx >= 0 then
    begin
      FBracketList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('BracketList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;

    Idx := IndexOfBlockMatch(EditControl);
    if Idx >= 0 then
    begin
      FBlockMatchList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('BlockMatchList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;

    Idx := IndexOfBlockLine(EditControl);
    if Idx >= 0 then
    begin
      FBlockLineList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('BlockLineList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;
  end;
end;

procedure TCnSourceHighlight.ActiveFormChanged(Sender: TObject);
begin
  if Active and (FStructureHighlight or FBlockMatchDrawLine) and (BlockHighlightStyle <> bsHotkey)
    and IsIdeEditorForm(Screen.ActiveForm) then
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnHighlightExec);
end;

procedure TCnSourceHighlight.AfterCompile(Succeeded,
  IsCodeInsight: Boolean);
begin
  if Active and (not IsCodeInsight) and (FStructureHighlight or FBlockMatchDrawLine) and
    (BlockHighlightStyle <> bsHotkey) and IsIdeEditorForm(Screen.ActiveForm) then
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnHighlightExec);
end;

// EditorChange 时调用此事件去检查括号和结构高亮
procedure TCnSourceHighlight.EditorChanged(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
var
  EditorIndex: Integer;
begin
  if Active then
  begin
    // 仅 View 切换时调用底层函数可能是不安全的，所有高亮需要重新刷新
    if ChangeType = [ctView] then
    begin
      ClearHighlight(Editor);
      if FViewChangedList.IndexOf(Editor) < 0 then
      begin
        FViewChangedList.Add(Editor);
        if IsDelphiSourceModule(Editor.EditView.Buffer.FileName)
          or IsInc(Editor.EditView.Buffer.FileName) then
          FViewFileNameIsPascalList.Add(Pointer(True))
        else
          FViewFileNameIsPascalList.Add(Pointer(False));
      end;
      Exit;
    end;  

    CharSize := EditControlWrapper.GetCharSize;

    if ctFont in ChangeType then
    begin
      ReloadIDEFonts;
{$IFNDEF BDS}
      if FHighLightLineColor = FDefaultHighLightLineColor then
        FHighLightLineColor := LoadIDEDefaultCurrentColor;
{$ENDIF}
      RepaintEditors;
    end;

    BeginUpdateEditor(Editor);
    try
      if FViewChangedList.IndexOf(Editor) >= 0 then
      begin
        EditorIndex := FViewChangedList.Remove(Editor);
        FViewFileNameIsPascalList.Delete(EditorIndex);
        ChangeType := ChangeType + [ctView];
      end;

      CheckBracketMatch(Editor);

      if FStructureHighlight or FBlockMatchDrawLine or FBlockMatchHighlight
        {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF} then
      begin
        UpdateHighlight(Editor, ChangeType);
      end;
    finally
      EndUpdateEditor(Editor);
    end;
  end;
end;

procedure TCnSourceHighlight.PaintLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer);
var
  AElided: Boolean;
begin
  if Active then
  begin
{$IFDEF BDS}
    // 预先获得当前行，供重画时重新进行 UTF8 位置计算
  {$IFDEF DELPHI2009_UP}
    // Delphi 2009 下不用进行额外的 UTF8 转换
    FLineText := AnsiString(EditControlWrapper.GetTextAtLine(Editor.EditControl,
      LogicLineNum));
  {$ELSE}
    FLineText := Utf8ToAnsi(EditControlWrapper.GetTextAtLine(Editor.EditControl,
      LogicLineNum));
  {$ENDIF}
{$ELSE}
    CanDrawCurrentLine := False;
  {$IFDEF DEBUG}
//  CnDebugger.LogFmt('Source Highlight after PaintLine %8.8x', [Integer(Editor.EditControl)]);
  {$ENDIF}
    if FHighLightCurrentLine and ColorChanged and (PaintingControl = Editor.EditControl) then
    begin
      SetForeAndBackColorHook.UnhookMethod;
      TCustomControlHack(Editor.EditControl).Canvas.Brush.Color := OldBkColor;
      PaintingControl := nil;
      ColorChanged := False;
  {$IFDEF DEBUG}
//    CnDebugger.LogFmt('Source Highlight: Restore Old Back Color after PaintLine %d.', [LineNum]);
//    CnDebugger.LogColor(TCustomControlHack(Editor.EditControl).Canvas.Brush.Color, 'Source Highlight: Restore to Color.');
  {$ENDIF}
    end;
{$ENDIF}
    AElided := LineNum <> LogicLineNum;
    if FMatchedBracket then
      PaintBracketMatch(Editor, LineNum, LogicLineNum, AElided);
    if FStructureHighlight or FBlockMatchHighlight or FCurrentTokenHighlight then // 里头顺便做背景匹配高亮
      PaintBlockMatchKeyword(Editor, LineNum, LogicLineNum, AElided);
    if FBlockMatchDrawLine then
      PaintBlockMatchLine(Editor, LineNum, LogicLineNum, AElided);
  end;
end;

//------------------------------------------------------------------------------
// 多语及设置
//------------------------------------------------------------------------------

function TCnSourceHighlight.GetBlockMatchHotkey: TShortCut;
begin
  Result := FBlockShortCut.ShortCut;
end;

procedure TCnSourceHighlight.SetBlockMatchHotkey(const Value: TShortCut);
begin
  FBlockShortCut.ShortCut := Value;
end;

procedure TCnSourceHighlight.SetActive(Value: Boolean);
begin
  inherited;
  RepaintEditors;
end;

procedure TCnSourceHighlight.Config;
begin
  ShowSourceHighlightForm(Self);
end;

procedure TCnSourceHighlight.LoadSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  with TCnIniFile.Create(Ini) do
  try
    FMatchedBracket := ReadBool('', csMatchedBracket, FMatchedBracket);
    FBracketColor := ReadColor('', csBracketColor, FBracketColor);
    FBracketColorBk := ReadColor('', csBracketColorBk, FBracketColorBk);
    FBracketColorBd := ReadColor('', csBracketColorBd, FBracketColorBd);
    FBracketBold := ReadBool('', csBracketBold, FBracketBold);
    FBracketMiddle := ReadBool('', csBracketMiddle, FBracketMiddle);

    FStructureHighlight := ReadBool('', csStructureHighlight, FStructureHighlight);
    FBlockMatchHighlight := ReadBool('', csBlockMatchHighlight, FBlockMatchHighlight);
    FBlockMatchBackground := ReadColor('', csBlockMatchBackground, FBlockMatchBackground);
    FCurrentTokenHighlight := ReadBool('', csCurrentTokenHighlight, FCurrentTokenHighlight);
    FCurrentTokenForeground := ReadColor('', csCurrentTokenColor, FCurrentTokenForeground);
    FCurrentTokenBackground := ReadColor('', csCurrentTokenColorBk, FCurrentTokenBackground);
    FCurrentTokenBorderColor := ReadColor('', csCurrentTokenColorBd, FCurrentTokenBorderColor);
{$IFNDEF BDS}
    FHighLightLineColor := ReadColor('', csHighLightLineColor, FHighLightLineColor);
    FHighLightCurrentLine := ReadBool('', csHighLightCurrentLine, FHighLightCurrentLine);
{$ENDIF}
    FBlockHighlightRange := TBlockHighlightRange(ReadInteger('', csBlockHighlightRange,
      Ord(FBlockHighlightRange)));
    FBlockMatchDelay := ReadInteger('', csBlockMatchDelay, FBlockMatchDelay);
    FBlockMatchLineLimit := ReadBool('', csBlockMatchLineLimit, FBlockMatchLineLimit);
    FBlockMatchMaxLines := ReadInteger('', csBlockMatchMaxLines, FBlockMatchMaxLines);
    FBlockHighlightStyle := TBlockHighlightStyle(ReadInteger('', csBlockHighlightStyle,
      Ord(FBlockHighlightStyle)));
    FBlockMatchDrawLine := ReadBool('', csBlockMatchDrawLine, FBlockMatchDrawLine);
    FBlockMatchLineClass := ReadBool('', csBlockMatchLineClass, FBlockMatchLineClass);
    FBlockMatchLineStyle := TCnLineStyle(ReadInteger('', csBlockMatchLineStyle,
      Ord(FBlockMatchLineStyle)));
    FBlockMatchLineEnd := ReadBool('', csBlockMatchLineEnd, FBlockMatchLineEnd);
    FBlockMatchLineWidth := ReadInteger('', csBlockMatchLineWidth, FBlockMatchLineWidth);
    FBlockMatchLineHori := ReadBool('', csBlockMatchLineHori, FBlockMatchLineHori);
    FBlockMatchLineHoriDot := ReadBool('', csBlockMatchLineHoriDot, FBlockMatchLineHoriDot);

    for I := Low(FHighLightColors) to High(FHighLightColors) do
      FHighLightColors[I] := ReadColor('', csBlockMatchHighlightColor + IntToStr(I),
        HighLightDefColors[I]);
  finally
    Free;
  end;
end;

procedure TCnSourceHighlight.SaveSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteBool('', csMatchedBracket, FMatchedBracket);
    WriteColor('', csBracketColor, FBracketColor);
    WriteColor('', csBracketColorBk, FBracketColorBk);
    WriteColor('', csBracketColorBd, FBracketColorBd);
    WriteBool('', csBracketBold, FBracketBold);
    WriteBool('', csBracketMiddle, FBracketMiddle);

    WriteBool('', csStructureHighlight, FStructureHighlight);
    WriteBool('', csBlockMatchHighlight, FBlockMatchHighlight);
    WriteColor('', csBlockMatchBackground, FBlockMatchBackground);
    WriteBool('', csCurrentTokenHighlight, FCurrentTokenHighlight);
    WriteColor('', csCurrentTokenColor, FCurrentTokenForeground);
    WriteColor('', csCurrentTokenColorBk, FCurrentTokenBackground);
    WriteColor('', csCurrentTokenColorBd, FCurrentTokenBorderColor);
{$IFNDEF BDS}
    WriteBool('', csHighLightCurrentLine, FHighLightCurrentLine);
    if FDefaultHighLightLineColor <> FHighLightLineColor then
      WriteColor('', csHighLightLineColor, FHighLightLineColor);
{$ENDIF}

    WriteInteger('', csBlockHighlightRange, Ord(FBlockHighlightRange));
    WriteInteger('', csBlockMatchDelay, FBlockMatchDelay);
    WriteBool('', csBlockMatchLineLimit, FBlockMatchLineLimit);
    WriteInteger('', csBlockMatchMaxLines, FBlockMatchMaxLines);
    WriteInteger('', csBlockHighlightStyle, Ord(FBlockHighlightStyle));

    for I := Low(FHighLightColors) to High(FHighLightColors) do
      WriteColor('', csBlockMatchHighlightColor + IntToStr(I), FHighLightColors[I]);

    WriteBool('', csBlockMatchDrawLine, FBlockMatchDrawLine);
    WriteInteger('', csBlockMatchLineWidth, FBlockMatchLineWidth);
    WriteInteger('', csBlockMatchLineStyle, Ord(FBlockMatchLineStyle));
    WriteBool('', csBlockMatchLineClass, FBlockMatchLineClass);
    WriteBool('', csBlockMatchLineEnd, FBlockMatchLineEnd);
    WriteBool('', csBlockMatchLineHori, FBlockMatchLineHori);
    WriteBool('', csBlockMatchLineHoriDot, FBlockMatchLineHoriDot);
  finally
    Free;
  end;
end;

function TCnSourceHighlight.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnSourceHighlight.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnSourceHighlightWizardName;
  Author := SCnPack_Zjy + ';' + SCnPack_LiuXiao + ';' + SCnPack_Shenloqi;
  Email := SCnPack_ZjyEmail + ';' + SCnPack_LiuXiaoEmail + ';' + SCnPack_ShenloqiEmail;
  Comment := SCnSourceHighlightWizardComment;
end;

procedure TCnSourceHighlight.RepaintEditors;
var
  i: Integer;
  EditControl: TControl;
  Info: TBlockMatchInfo;
begin
  if not Active then
  begin
    FBracketList.Clear;
    FBlockMatchList.Clear;
    FBlockLineList.Clear;
    EditControlWrapper.RepaintEditControls;
  end
  else
  begin
    // 检查编辑器，可能编辑器的Info未创建
    ReloadIDEFonts;
    for i := 0 to EditControlWrapper.EditorCount - 1 do
    begin
      EditControl := EditControlWrapper.Editors[i].EditControl;
      if IndexOfBlockMatch(EditControl) < 0 then
      begin
        Info := TBlockMatchInfo.Create(EditControl);
        FBlockMatchList.Add(Info);
      end;
    end;
    OnHighlightExec(nil);
  end;
end;

procedure TCnSourceHighlight.BeginUpdateEditor(Editor: TEditorObject);
begin
  if FDirtyList = nil then
    FDirtyList := TList.Create
  else
    FDirtyList.Clear;
end;

procedure TCnSourceHighlight.EndUpdateEditor(Editor: TEditorObject);
var
  I: Integer;
  NeedRefresh: Boolean;
{$IFDEF BDS}
  ALine, LLine, BottomLine: Integer;
{$ENDIF}
begin
  with Editor do
  begin
  {$IFDEF BDS}
    // 去掉被折叠的行
    for I := FDirtyList.Count - 1 downto 0 do
      if EditControlWrapper.GetLineIsElided(EditControl, Integer(FDirtyList[I])) then
        FDirtyList.Delete(I);

    // 检查代码折叠
    NeedRefresh := False;
    if FDirtyList.Count > 0 then
    begin
      ALine := EditView.TopRow;
      LLine := ALine; // 初始相同
      BottomLine := EditView.BottomRow;

      while ALine <= BottomLine + 1 do // 多搞一行，保险点儿
      begin
        if EditControlWrapper.GetLineIsElided(EditControl, LLine) then
        begin
          Inc(LLine);
          Continue;
        end;
        if FDirtyList.IndexOf(Pointer(LLine)) >= 0 then
        begin
          EditControlWrapper.MarkLinesDirty(EditControl, ALine - EditView.TopRow, 1);
          NeedRefresh := True;
          FDirtyList.Remove(Pointer(LLine));
          if FDirtyList.Count = 0 then
            Break;
        end;
        Inc(LLine);
        Inc(ALine);
      end;
    end;
  {$ELSE}
    NeedRefresh := FDirtyList.Count > 0;
    for I := 0 to FDirtyList.Count - 1 do
      EditControlWrapper.MarkLinesDirty(EditControl, Integer(FDirtyList[I])
        - EditView.TopRow, 1);
  {$ENDIF}

    if NeedRefresh then
      EditControlWrapper.EditorRefresh(EditControl, True);

    FreeAndNil(FDirtyList);
  end;
end;

procedure TCnSourceHighlight.EditorMarkLineDirty(LineNum: Integer);
begin
  if (FDirtyList <> nil) and (FDirtyList.IndexOf(Pointer(LineNum)) < 0) then
    FDirtyList.Add(Pointer(LineNum));
end;

procedure TCnSourceHighlight.ReloadIDEFonts;
var
  AHighlight: THighlightItem;
begin
  if EditControlWrapper.IndexOfHighlight(csReservedWord) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csReservedWord)];

    FKeywordHighlight.ColorFg := AHighlight.ColorFg;
    FKeywordHighlight.ColorBk := AHighlight.ColorBk;
    FKeywordHighlight.Bold := AHighlight.Bold;
    FKeywordHighlight.Italic := AHighlight.Italic;
    FKeywordHighlight.Underline := AHighlight.Underline;
  end;

  if EditControlWrapper.IndexOfHighlight(csIdentifier) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csIdentifier)];

    FIdentifierHighlight.ColorFg := AHighlight.ColorFg;
    FIdentifierHighlight.ColorBk := AHighlight.ColorBk;
    FIdentifierHighlight.Bold := AHighlight.Bold;
    FIdentifierHighlight.Italic := AHighlight.Italic;
    FIdentifierHighlight.Underline := AHighlight.Underline;
  end;
end;

procedure TCnSourceHighlight.RefreshCurrentTokens(Info: TBlockMatchInfo);
var
  I: Integer;
begin
  for I := 0 to Info.CurTokenCount - 1 do
    EditorMarkLineDirty(Info.CurTokens[I].EditLine);
end;

{$IFNDEF BDS}

procedure MyEditorsCustomEditControlSetForeAndBackColor(ASelf: TObject; Param1,
  Param2, Param3, Param4: Cardinal);
begin
  SetForeAndBackColorHook.UnhookMethod;
  try
    try
      // 不管咋样都要调用旧的
      SetForeAndBackColor(ASelf, Param1, Param2, Param3, Param4);
    except
      on E: Exception do
        DoHandleException(E.Message);
    end;
  finally
    SetForeAndBackColorHook.HookMethod;
  end;

  // 旧的调用完毕后根据需要设置背景填充色
  if CanDrawCurrentLine and (ASelf = PaintingControl) and FHighlight.Active
    and FHighlight.HighLightCurrentLine then
  begin
    // 如果是当前被画的编辑器的当前行
    if TCustomControlHack(ASelf).Canvas.Brush.Color <> FHighlight.HighLightLineColor then
    begin
      OldBkColor := TCustomControlHack(ASelf).Canvas.Brush.Color;
      TCustomControlHack(ASelf).Canvas.Brush.Color := FHighlight.HighLightLineColor;
      ColorChanged := True;

{$IFDEF DEBUG}
//    Cndebugger.LogFmt('Source Highlight: Set Current Line %d Back Color to Control %8.8x.',
//      [CurrentLineNum, Integer(PaintingControl)]);
{$ENDIF}
    end;
  end;
end;

procedure TCnSourceHighlight.SetHighLightCurrentLine(const Value: Boolean);
begin
  if FHighLightCurrentLine <> Value then
  begin
    FHighLightCurrentLine := Value;
    // 这段基本没用了因为 Create 时就已经 Hook 了
    if Value and (SetForeAndBackColorHook = nil) then
      SetForeAndBackColorHook := TCnMethodHook.Create(@SetForeAndBackColor,
        @MyEditorsCustomEditControlSetForeAndBackColor);

    if SetForeAndBackColorHook <> nil then
    begin
      if Value then
        SetForeAndBackColorHook.HookMethod
      else
        SetForeAndBackColorHook.UnhookMethod;
    end;
  end;
end;

procedure TCnSourceHighlight.SetHighLightLineColor(const Value: TColor);
begin
  if FHighLightLineColor <> Value then
  begin
    FHighLightLineColor := Value;
    // RepaintEditors;
  end;
end;

procedure TCnSourceHighlight.BeforePaintLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer);
var
  CurLine: TCurLineInfo;
  EditPos: TOTAEditPos;
  Element, LineFlag: Integer;
  StartRow, EndRow: Integer;
begin
  // 只有在调 PaintLine 前，才允许设置 CanDrawCurrentLine 为 True
  // PaintLine 结束后必须立刻将 CanDrawCurrentLine 设为 False
  // 避免 PaintLine 之外的地方调用 SetForeAndBackColor 导致额外副作用
  CanDrawCurrentLine := False;
  if IndexOfCurLine(Editor.EditControl) >= 0 then
    CurLine := TCurLineInfo(FCurLineList[IndexOfCurLine(Editor.EditControl)])
  else
    Exit;

  CanDrawCurrentLine := LineNum = CurLine.CurrentLine;
  PaintingControl := Editor.EditControl;
  if CanDrawCurrentLine then
  begin
    EditPos.Line := LineNum;
    EditPos.Col := Editor.EditView.CursorPos.Col;
    EditControlWrapper.GetAttributeAtPos(Editor.EditControl, EditPos, False,
      Element, LineFlag);
    CanDrawCurrentLine := (LineFlag = 0) and not (Element in [MarkedBlock, SearchMatch]);

    if CanDrawCurrentLine and (EditPos.Col > 1) then
    begin
      Dec(EditPos.Col);
      EditControlWrapper.GetAttributeAtPos(Editor.EditControl, EditPos, False,
        Element, LineFlag);
      CanDrawCurrentLine := not (Element in [MarkedBlock, SearchMatch]);
    end;

    if CanDrawCurrentLine then
    begin
      // DONE: 加入当前行是否有选择区的判断
      if Editor.EditView <> nil then
      begin
        if Editor.EditView.Block <> nil then
        begin
          if Editor.EditView.Block.IsValid then
          begin
            StartRow := Editor.EditView.Block.StartingRow;
            EndRow := Editor.EditView.Block.EndingRow;
            if (LineNum >= StartRow) and (LineNum <= EndRow) then
              CanDrawCurrentLine := False;
          end;
        end;
      end;
    end;
  end;
{$IFDEF DEBUG}
//  CurrentLineNum := LineNum;
//  CnDebugger.LogFmt('Source Highlight Line %d, CanDraw? %d. PaintControl %8.8x',
//    [LineNum, Integer(CanDrawCurrentLine), Integer(PaintingControl)]);
{$ENDIF}

  SetForeAndBackColorHook.HookMethod;
end;

function TCnSourceHighlight.IndexOfCurLine(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FCurLineList.Count - 1 do
    if TCurLineInfo(FCurLineList[i]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

{$ENDIF}

function LoadIDEDefaultCurrentColor: TColor;
var
  AHighlight: THighlightItem;
begin
  Result := $00E6FFFA;  // 默认
  if EditControlWrapper.IndexOfHighlight(csWhiteSpace) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csWhiteSpace)];

    case AHighlight.ColorBk of
      clWhite: Result := $00E6FFFA;
      clNavy:  Result := $009999CC;
      clBlack: Result := $00505050;
      clAqua:  Result := $00CCFFCC;
    end;
  end;
end;



{ TBlockLinePair }

procedure TBlockLinePair.AddMidToken(const Token: TCnPasToken;
  const LineLeft: Integer);
begin
  if Token <> nil then
  begin
    FMiddleTokens.Add(Token);
    if Left > LineLeft then
      Left := LineLeft;
  end;
end;

constructor TBlockLinePair.Create;
begin
  FMiddleTokens := TList.Create;
end;

destructor TBlockLinePair.Destroy;
begin
  FMiddleTokens.Free;
  inherited;
end;

function TBlockLinePair.GetMiddleCount: Integer;
begin
  Result := FMiddleTokens.Count;
end;

function TBlockLinePair.GetMiddleToken(Index: Integer): TCnPasToken;
begin
  if (Index >= 0) and (Index < FMiddleTokens.Count) then
    Result := TCnPasToken(FMiddleTokens[Index])
  else
    Result := nil;
end;

function TBlockLinePair.IndexOfMiddleToken(
  const Token: TCnPasToken): Integer;
begin
  Result := FMiddleTokens.IndexOf(Token);
end;

function TBlockLinePair.IsInMiddle(const LineNum: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FMiddleTokens.Count - 1 do
    if MiddleToken[I].EditLine = LineNum then
    begin
      Result := True;
      Exit;
    end;
end;

{ TBlockLineInfo }

procedure TBlockLineInfo.AddPair(Pair: TBlockLinePair);
begin
  FPairList.Add(Pair);
end;

procedure TBlockLineInfo.Clear;
begin
  FPairList.Clear;
  FLineList.Clear;
end;

constructor TBlockLineInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FPairList := TCnObjectList.Create;
  FLineList := TCnObjectList.Create;
end;

destructor TBlockLineInfo.Destroy;
begin
  Clear;
  FPairList.Free;
  FLineList.Free;
  inherited;
end;

procedure TBlockLineInfo.FindCurrentPair(View: IOTAEditView;
  IsCppModule: Boolean);
var
  I: Integer;
  Col: SmallInt;
  Line: TCnList;
  Pair: TBlockLinePair;
  Text: AnsiString;
  LineNo, CharIndex, Len: Integer;
  StartIndex, EndIndex: Integer;
  PairIndex: Integer;

  // 判断标识符是否在光标下
  function InternalIsCurrentToken(Token: TCnPasToken): Boolean;
  begin
    Result := (Token <> nil) and // (Token.IsBlockStart or Token.IsBlockClose) and
      (Token.EditLine = LineNo) and (Token.EditCol <= EndIndex) and
      (Token.EditCol >= StartIndex);
  end;

  // 判断一个 Pair 是否有 Middle 的 Token 在光标下
  function IndexOfCurrentMiddleToken(Pair: TBlockLinePair): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to Pair.MiddleCount - 1 do
      if InternalIsCurrentToken(Pair.MiddleToken[I]) then
      begin
        Result := I;
        Exit;
      end;
  end;
begin
  FCurrentPair := nil;
  FCurrentToken := nil;
  Text := AnsiString(GetStrProp(FControl, 'LineText'));
  Col := View.CursorPos.Col;
{$IFDEF BDS}
  // 获得的是 UTF8 字符串与 Pos，需要转换成 Ansi 的，但 D2009 无需转换
  if Text <> '' then
  begin
    {$IFDEF DELPHI2009_UP}
    Col := Length(CnUtf8ToAnsi(Copy(CnAnsiToUtf8(Text), 1, Col)));
    {$ELSE}
    Col := Length(CnUtf8ToAnsi(Copy(Text, 1, Col)));
    Text := CnUtf8ToAnsi(Text);
    {$ENDIF}
  end;
{$ENDIF}
  LineNo := View.CursorPos.Line;

  // 不知为何需如此处理但有效
  if IsCppModule then
    CharIndex := Min(Col, Length(Text))
  else
    CharIndex := Min(Col - 1, Length(Text));

  Len := Length(Text);

  // 找到起始 StartIndex
  StartIndex := CharIndex;
  if not IsCppModule then
  begin
    while (StartIndex > 0) and (Text[StartIndex] in AlphaNumeric) do
      Dec(StartIndex);
  end
  else
  begin
    while (StartIndex > 0) and (Text[StartIndex] in AlphaNumeric + ['{', '}']) do
      Dec(StartIndex);
  end;

  EndIndex := CharIndex;
  while EndIndex < Len do
  begin
    // 本来是找到非字母数字就跳出，但变成非字母数字，并且不是在首字母之前的
    if (not (Text[EndIndex] in AlphaNumeric)) and not
     ((EndIndex = CharIndex) and (Text[EndIndex + 1] in AlphaNumeric)) then
      Break;
    Inc(EndIndex);
  end;

  if (LineNo < LineCount) and (Lines[LineNo] <> nil) then
  begin
    Line := Lines[LineNo];
    for I := 0 to Line.Count - 1 do
    begin
      Pair := TBlockLinePair(Line[I]);
      if InternalIsCurrentToken(Pair.StartToken) then
      begin
        FCurrentPair := Pair;
        FCurrentToken := Pair.StartToken;
        Exit;
      end
      else if InternalIsCurrentToken(Pair.EndToken) then
      begin
        FCurrentPair := Pair;
        FCurrentToken := Pair.EndToken;
        Exit;
      end
      else
      begin
        PairIndex := IndexOfCurrentMiddleToken(Pair);
        if PairIndex >= 0 then
        begin
          FCurrentPair := Pair;
          FCurrentToken := Pair.MiddleToken[PairIndex];
          Exit;
        end;
      end;
    end;
  end;
end;

function TBlockLineInfo.GetCount: Integer;
begin
  Result := FPairList.Count;
end;

function TBlockLineInfo.GetLineCount: Integer;
begin
  Result := FLineList.Count;
end;

function TBlockLineInfo.GetLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FLineList[LineNum]);
end;

function TBlockLineInfo.GetPairs(Index: Integer): TBlockLinePair;
begin
  Result := TBlockLinePair(FPairList[Index]);
end;

procedure TBlockLineInfo.UpdateLineList;
var
  i, j: Integer;
  Pair: TBlockLinePair;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for i := 0 to FPairList.Count - 1 do
  begin
    if Pairs[i].FBottom > MaxLine then
      MaxLine := Pairs[i].FBottom;
  end;
  FLineList.Count := MaxLine + 1;
  
  for i := 0 to FPairList.Count - 1 do
  begin
    Pair := Pairs[i];
    for j := Pair.FTop to Pair.FBottom do
    begin
      if FLineList[j] = nil then
        FLineList[j] := TCnList.Create;
      TCnList(FLineList[j]).Add(Pair);
    end;
  end;
end;

{ TCurLineInfo }

constructor TCurLineInfo.Create(AControl: TControl);
begin
  FControl := AControl;
end;

destructor TCurLineInfo.Destroy;
begin
  inherited;

end;

initialization
  RegisterCnWizard(TCnSourceHighlight);

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}
end.
