{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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
*                              D7 或以下、  D2009 以下的BDS、 D2009：
*           LineText 属性：    AnsiString、 UTF8、            UncodeString
*           EditView.CusorPos：Ansi 字节、  UTF8 的字节 Col、 转成 Ansi 的字符 Col
*           GetAttributeAtPos：Ansi 字节、  UTF8 的字节 Col、 UTF8 的字节 Col
*               因此 D2009 下处理时，需要额外将获得的 UnicodeString 的 LineText
*               转成 UTF8 来适应相关的 CursorPos 和 GetAttributeAtPos
*
*           如果绘制错位，多半是 EditorGetTextRect 中的判断字符宽度的行为和 IDE 不一致
*           如果光标判断标识符错位，多半是 CnOtaGeneralGetCurrPosToken 里判断宽度和 IDE 不一致
*           如果部分字符绘制宽度在不同版本的 IDE 里有变化导致光标高亮与绘制错位，则需在
*           CnIDEStrings.pas 里的 IDEWideCharIsWideLength 函数里，照 IDE 的行为进行补充
*           注：本专家在测量编辑器中的字符的位置、光标列、绘制宽度时已经抽象出了处理核心
*           IDEWideCharIsWideLength 函数。
*
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2024.08.03
*               Unicode 下多处调用 DisplayLength 系列函数的场景指定 IDE 相关的宽度计算。
*           2024.07.02
*               增加 ControlHook 拦截窗口位置变化消息重新计算左侧栏位宽度的机制避免绘制错位然而似乎无效。
*           2022.02.26
*               光标下的高亮关键字块，其配对使用实线绘制。
*           2021.09.03
*               加入对区域折叠标记的高亮配对显示。
*           2016.05.22
*               修正纯英文环境下 Unicode IDE 内的宽字节字符转换成 Ansi 有误的问题
*               全文解析时允许将普通宽字节字符替换成单个或两个空格，从而避免直接
*               转换时被半角问号代替导致计算偏差。
*           2016.02.05
*               修正 Unicode IDE 下括号配对功能对于包含汉字的行可能出现位置偏差的问题
*           2014.12.25
*               增加高亮光标下配对的条件编译指令功能
*           2014.09.17
*               优化高亮当前标识符的绘制性能，感谢 vitaliyg2
*           2013.07.08
*               加入绘制流程控制标识符背景的功能
*           2012.12.24
*               修复 jtdd 报告的绘制空行分隔线在折叠状态下可能出错的问题
*           2011.09.04
*               加入 white_nigger 的修补以针对修复 CloseAll 时出错的问题
*           2010.10.04
*               2009 以上 Unicode 环境下，各个 Token 的 Col 采用 ConvertPos 进行
*               转换时，对汉字以及单位置双字节字符等的判断会有错误，因此采用
*               CharIndex + 1 时，又不能处理好 Tab 键。
*               速度快的 GetTextAtLine 取得的文本是将 Tab 扩展成空格的，导致无法
*               区分是否存在 Tab 键，只能在 UseTabChar 选项为 True 时，使用传统的
*               D2009 以上会错位的计算方法。
*           2009.03.28
*               加入控制大小写匹配的机制，对 Pascal 文件，不区分大小写
*           2009.01.06
*               加入高亮当前行背景的功能。
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
*               修正 EditControl 关闭时通知器内部未释放高亮对象的问题
*           2005.07.25
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  Windows, Messages, Classes, Graphics, SysUtils, Controls, Menus, Forms,
  ToolsAPI, IniFiles, Contnrs, ExtCtrls, TypInfo, Math,
  {$IFDEF COMPILER6_UP} Variants, {$ENDIF} CnWideStrings, CnControlHook,
  CnWizClasses, CnEditControlWrapper, CnWizNotifier, CnIni, CnWizUtils, CnCommon,
  CnConsts, CnWizConsts, CnWizIdeUtils, CnWizShortCut, mPasLex, CnPasWideLex,
  mwBCBTokenList, CnBCBWideTokenList, CnPasCodeParser, CnWidePasParser,
  CnCppCodeParser, CnWideCppParser, CnGraphUtils, CnFastList, CnIDEStrings;

const
  HighLightDefColors: array[-1..5] of TColor = ($00000099, $000000FF, $000099FF,
    $0033CC00, $00CCCC00, $00FF6600, $00CC00CC);
  csDefCurTokenColorBg = $0080DDFF;
  csDefCurTokenColorFg = clBlack;
  csDefCurTokenColorBd = $00226DA8;
  csDefFlowControlBg = $FFCCCC;
  csDefaultHighlightBackgroundColor = $0066FFFF;

  csDefaultCustomIdentifierBackground = $00E3EBEE;
  csDefaultCustomIdentifierForeground = clNavy;

  CN_LINE_STYLE_SMALL_DOT_STEP = 2;

  CN_LINE_STYLE_TINY_DOT_STEP = 1;
  // 每几个像素空几个像素

  CN_LINE_SEPARATE_FLAG = 1;

  csKeyTokens: set of TTokenKind = [
    tkIf, tkThen, tkElse,
    tkRecord, tkObject, tkClass, tkInterface, tkDispInterface,
    tkFor, tkWith, tkOn, tkWhile, tkDo,
    tkAsm, tkBegin, tkEnd,
    tkTry, tkExcept, tkFinally,
    tkCase, tkOf,
    tkRepeat, tkUntil];

  csPasFlowTokenStr: array[0..3] of TCnIdeTokenString =
    ('exit', 'continue', 'break', 'abort');

  csPasFlowTokenKinds: set of TTokenKind = [tkGoto, tkRaise];

  csCppFlowTokenStr: array[0..1] of TCnIdeTokenString =
    ('abort', 'exit');

  csCppFlowTokenKinds: TIdentDirect = [ctkgoto, ctkreturn, ctkcontinue, ctkbreak];
  // If change here, CppCodeParser also need change.

  csPasCompDirectiveTokenStr: array[0..8] of TCnIdeTokenString = // 并非全匹配而是开头匹配
    ('{$IF ', '{$IFOPT ', '{$IFDEF ', '{$IFNDEF ', '{$ELSE', '{$ENDIF', '{$IFEND', '{$REGION', '{$ENDREGION');

  csPasCompDirectiveTypes: array[0..8] of TCnCompDirectiveType =
    (ctIf, ctIfOpt, ctIfDef, ctIfNDef, ctElse, ctEndIf, ctIfEnd, ctRegion, ctEndRegion);

  csCppCompDirectiveKinds: TIdentDirect = [ctkdirif, ctkdirifdef, ctkdirifndef,
    ctkdirelif, ctkdirelse, ctkdirendif];
  // 还有 pragma 后的 region 与 end_region 要额外判断

  csCppCompDirectiveRegionTokenStr: array[0..1] of TCnIdeTokenString =
    ('region', 'end_region');

  CPP_PAS_REGION_TYPE_OFFSET = 7; // 对应 ctRegion 的位置

type
  TCnLineStyle = (lsSolid, lsDot, lsSmallDot, lsTinyDot);

  TCnBracketInfo = class
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

    // 光标下，或主括号的括号字符串、行内容、位置信息
    property TokenStr: AnsiString read FTokenStr write FTokenStr;
    property TokenLine: AnsiString read FTokenLine write FTokenLine;
    property TokenPos: TOTAEditPos read FTokenPos write FTokenPos;

    // 和上面配对的括号字符串、行内容、位置信息
    property TokenMatchStr: AnsiString read FTokenMatchStr write FTokenMatchStr;
    property TokenMatchLine: AnsiString read FTokenMatchLine write FTokenMatchLine;
    property TokenMatchPos: TOTAEditPos read FTokenMatchPos write FTokenMatchPos;
  end;

  TBlockHighlightRange = (brAll, brMethod, brWholeBlock, brInnerBlock);

  TBlockHighlightStyle = (bsNow, bsDelay, bsHotkey);

  TCnBlockLineInfo = class;

  TCnCompDirectiveInfo = class;

  TCnBlockMatchInfo = class(TObject)
  {* 每个 EditControl 对应一个，解析并管理本编辑器中所有的结构高亮信息，注意 Tokens 均是引用}
  private
    FControl: TControl;
    // FHook: TCnControlHook;
    FModified: Boolean;
    FChanged: Boolean;
    FIsCppSource: Boolean;
    FPasParser: TCnGeneralPasStructParser;
    FCppParser: TCnGeneralCppStructParser;

    // *TokenList 容纳初步解析结果
    FKeyTokenList: TCnList;           // 容纳解析出来的关键字 Tokens 的引用
    FCurTokenList: TCnList;           // 容纳解析出来的与光标当前词相同的 Tokens 的引用
    FCurTokenListEditLine: TCnList;   // 容纳解析出来的光标当前词相同的词的行数
    FCurTokenListEditCol: TCnList;    // 容纳解析出来的光标当前词相同的词的列数
    FFlowTokenList: TCnList;          // 容纳解析出来的流程控制标识符的 Tokens 的引用
    FCompDirectiveTokenList: TCnList; // 容纳解析出来的编译指令 Tokens 的引用
    FCustomIdentifierTokenList: TCnList;   // 容纳解析出来的自定义高亮标识符的引用

    // *LineList 容纳快速访问结果
    FKeyLineList: TCnFastObjectList;      // 容纳按行方式存储的快速访问的关键字内容
    FIdLineList: TCnFastObjectList;       // 容纳按行方式存储的快速访问的标识符内容
    FFlowLineList: TCnFastObjectList;     // 容纳按行方式存储的快速访问的流程控制符内容
    FSeparateLineList: TCnList;           // 容纳行方式存储的快速访问的分界空行信息
    FCompDirectiveLineList: TCnFastObjectList;       // 容纳行方式存储的快速访问的编译指令内容
    FCustomIdentifierLineList: TCnFastObjectList;    // 容纳按行方式存储的自定义高亮标识符的内容

    FLineInfo: TCnBlockLineInfo;              // 容纳解析出来的 Tokens 配对信息
    FCompDirectiveInfo: TCnCompDirectiveInfo; // 容纳解析出来的编译指令配对信息

    FStack: TStack;  // 解析关键字配对时以及解析 C 括号配对时以及 C 编译指令配对时以及 Pascal 编译指令配对时使用，存储 Pair 对象的栈
    FIfThenStack: TStack; // 为了 if then 而存储 Pair 的引用的栈
    FRegionStack: TStack; // 为了 $REGION 和 $ENDREGION 配对而存储 Pair 的引用的栈
    FCurrentToken: TCnGeneralPasToken;
    FCurMethodStartToken, FCurMethodCloseToken: TCnGeneralPasToken;
    FCurrentTokenName: TCnIdeTokenString; // D567/2005~2007/2009 分别是 AnsiString/WideString/UnicodeString
    FCurrentBlockSearched: Boolean;
    FCaseSensitive: Boolean;

    function GetKeyCount: Integer;
    function GetKeyTokens(Index: Integer): TCnGeneralPasToken;
    function GetCurTokens(Index: Integer): TCnGeneralPasToken;
    function GetLineCount: Integer;
    function GetIdLineCount: Integer;
    function GetLines(LineNum: Integer): TCnList;
    function GetCurTokenCount: Integer;
    function GetIdLines(LineNum: Integer): TCnList;
    function GetFlowTokenCount: Integer;
    function GetFlowTokens(Index: Integer): TCnGeneralPasToken;
    function GetFlowLineCount: Integer;
    function GetFlowLines(LineNum: Integer): TCnList;
    function GetCompDirectiveTokenCount: Integer;
    function GetCompDirectiveTokens(Index: Integer): TCnGeneralPasToken;
    function GetCompDirectiveLineCount: Integer;
    function GetCompDirectiveLines(LineNum: Integer): TCnList;
    function GetCustomIdentifierTokenCount: Integer;
    function GetCustomIdentifierTokens(Index: Integer): TCnGeneralPasToken;
    function GetCustomIdentifierLineCount: Integer;
    function GetCustomIdentifierLines(LineNum: Integer): TCnList;
  protected
    function CheckIsFlowToken(AToken: TCnGeneralPasToken; IsCpp: Boolean): Boolean;
    function CheckIsCustomIdentifier(AToken: TCnGeneralPasToken; IsCpp: Boolean; out Bold: Boolean): Boolean;
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;

    function CheckBlockMatch(BlockHighlightRange: TBlockHighlightRange): Boolean; // 找出关键字，并调用下面五个函数
    procedure UpdateSeparateLineList;  // 找出空行
    procedure UpdateFlowTokenList;     // 找出流程控制标识符
    procedure UpdateCurTokenList;      // 找出和光标下相同的标识符
    procedure UpdateCompDirectiveList; // 找出编译指令
    procedure UpdateCustomIdentifierList;   // 找出自定义标识符

    procedure CheckLineMatch(View: IOTAEditView; IgnoreClass, IgnoreNamespace: Boolean);
    procedure CheckCompDirectiveMatch(View: IOTAEditView);
    procedure ConvertLineList;          // 将解析出的关键字与当前标识符转换成按行方式快速访问的
    procedure ConvertIdLineList;        // 将解析出的标识符转换成按行方式快速访问的
    procedure ConvertFlowLineList;      // 将解析出的流程控制标识符转换成按行方式快速访问的
    procedure ConvertCompDirectiveLineList; // 将解析出的编译指令转换成按行方式快速访问的
    procedure ConvertCustomIdentifierLineList;   // 将解析出的自定义标识符转换成按行方式快速访问的

    procedure Clear;
    procedure AddToKeyList(AToken: TCnGeneralPasToken);
    procedure AddToCurrList(AToken: TCnGeneralPasToken);
    procedure AddToFlowList(AToken: TCnGeneralPasToken);
    procedure AddToCompDirectiveList(AToken: TCnGeneralPasToken);
    procedure AddToCustomIdentifierList(AToken: TCnGeneralPasToken);

    property KeyTokens[Index: Integer]: TCnGeneralPasToken read GetKeyTokens;
    {* 高亮关键字列表}
    property KeyCount: Integer read GetKeyCount;
    {* 高亮关键字列表数目}
    property CurTokens[Index: Integer]: TCnGeneralPasToken read GetCurTokens;
    {* 和当前标识符相同的标识符列表}
    property CurTokenCount: Integer read GetCurTokenCount;
    {* 和当前标识符相同的标识符列表数目}
    property FlowTokens[Index: Integer]: TCnGeneralPasToken read GetFlowTokens;
    {* 流程控制的标识符列表}
    property FlowTokenCount: Integer read GetFlowTokenCount;
    {* 流程控制的标识符列表数目}
    property CompDirectiveTokens[Index: Integer]: TCnGeneralPasToken read GetCompDirectiveTokens;
    {* 编译指令的标识符列表}
    property CompDirectiveTokenCount: Integer read GetCompDirectiveTokenCount;
    {* 编译指令的标识符列表数目}
    property CustomIdentifierTokens[Index: Integer]: TCnGeneralPasToken read GetCustomIdentifierTokens;
    {* 自定义标识符的列表}
    property CustomIdentifierTokenCount: Integer read GetCustomIdentifierTokenCount;
    {* 自定义标识符的列表数目}

    property LineCount: Integer read GetLineCount;
    property IdLineCount: Integer read GetIdLineCount;
    property FlowLineCount: Integer read GetFlowLineCount;
    property CompDirectiveLineCount: Integer read GetCompDirectiveLineCount;
    property CustomIdentifierLineCount: Integer read GetCustomIdentifierLineCount;

    property Lines[LineNum: Integer]: TCnList read GetLines;
    {* 每行一个 CnList，后者容纳 Token}
    property IdLines[LineNum: Integer]: TCnList read GetIdLines;
    {* 也是按 Lines 的方式来，每行一个 CnList，后者容纳 CurToken}
    property FlowLines[LineNum: Integer]: TCnList read GetFlowLines;
    {* 也是按 Lines 的方式来，每行一个 CnList，后者容纳 FlowToken}
    property CompDirectiveLines[LineNum: Integer]: TCnList read GetCompDirectiveLines;
    {* 也是按 Lines 的方式来，每行一个 CnList，后者容纳 CompDirectiveToken}
    property CustomIdentifierLines[LineNum: Integer]: TCnList read GetCustomIdentifierLines;
    {* 也是按 Lines 的方式来，每行一个 CnList，后者容纳 CustomIdentifier}

    property Control: TControl read FControl;
    property Modified: Boolean read FModified write FModified;
    property Changed: Boolean read FChanged write FChanged;
    property CurrentTokenName: TCnIdeTokenString read FCurrentTokenName write FCurrentTokenName;
    property CurrentToken: TCnGeneralPasToken read FCurrentToken write FCurrentToken;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
    {* 当前匹配时是否大小写敏感，由外部设定}
    property IsCppSource: Boolean read FIsCppSource write FIsCppSource;
    {* 是否是 C/C++ 文件，默认是 False，也就是 Pascal}
    property PasParser: TCnGeneralPasStructParser read FPasParser;
    property CppParser: TCnGeneralCppStructParser read FCppParser;

    property LineInfo: TCnBlockLineInfo read FLineInfo write FLineInfo;
    {* 画线高亮的配对信息，解析关键字高亮时顺便也解析，由外界设置与释放}
    property CompDirectiveInfo: TCnCompDirectiveInfo read FCompDirectiveInfo write FCompDirectiveInfo;
    {* 编译指令的配对信息，解析关键字高亮时顺便也解析，由外界设置与释放}
  end;

  TCnBlockLinePair = class(TObject)
  {* 描述一根配对的线所对应的多个 Token 标记，Token 均为引用}
  private
    FTop: Integer;
    FLeft: Integer;
    FBottom: Integer;
    FStartToken: TCnGeneralPasToken;
    FEndToken: TCnGeneralPasToken;
    FLayer: Integer;
    FEndLeft: Integer;
    FStartLeft: Integer;
    FMiddleTokens: TList;
    FDontDrawVert: Boolean;
    function GetMiddleCount: Integer;
    function GetMiddleToken(Index: Integer): TCnGeneralPasToken;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;
    procedure AddMidToken(const Token: TCnGeneralPasToken; const LineLeft: Integer);
    function IsInMiddle(const LineNum: Integer): Boolean;
    function IndexOfMiddleToken(const Token: TCnGeneralPasToken): Integer;

    property StartToken: TCnGeneralPasToken read FStartToken write FStartToken;
    property EndToken: TCnGeneralPasToken read FEndToken write FEndToken;
    //property EndIsFirstTokenInLine: Boolean read FEndIsFirstTokenInLine write FEndIsFirstTokenInLine;
    //{* 末尾是否是第一个 Token}

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
    property MiddleToken[Index: Integer]: TCnGeneralPasToken read GetMiddleToken;
    {* 一对画线配对的 Token 的中间的 Token }

    property Layer: Integer read FLayer write FLayer;
    {* 一对画线的配对层次}

    property DontDrawVert: Boolean read FDontDrawVert write FDontDrawVert;
    {* 控制是否需要画竖线}
  end;

  TCnCompDirectivePair = class(TCnBlockLinePair)
  {* 描述一组配对的编译指令所对应的多个 Token 标记，复用 TBlockLinePair}
  end;

  TCnBlockLineInfo = class(TObject)
  {* 每个 EditControl 对应一个，由对应的 BlockMatchInfo 转换而来，包括多个
     TCnBlockLinePair.}
  private
    FControl: TControl;
    FPairList: TCnFastObjectList;        // 容纳解析出来的 Pair 对象并管理
    FKeyLineList: TCnFastObjectList;     // 容纳按行方式存储的快速访问的 Pair 对象并管理
    FCurrentPair: TCnBlockLinePair;
    FCurrentToken: TCnGeneralPasToken;
    function GetCount: Integer;
    function GetPairs(Index: Integer): TCnBlockLinePair;
    function GetLineCount: Integer;
    function GetLines(LineNum: Integer): TCnList;
    procedure ConvertLineList; // 转换成按行快速访问的
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;
    procedure Clear;
    procedure AddPair(Pair: TCnBlockLinePair);
    procedure FindCurrentPair(View: IOTAEditView; IsCppModule: Boolean = False); virtual;
    {* 寻找其中一个标识符在光标下的一组关键字对，使用 Ansi 模式，直接拿当前光标值
       与当前行文字计算而来，不涉及到语法解析，输出为 FCurrentPair 与 FCurrentToken。
       注意对 Unicode 标识符可能有问题。}
    property Control: TControl read FControl;
    property Count: Integer read GetCount;
    property Pairs[Index: Integer]: TCnBlockLinePair read GetPairs;
    property LineCount: Integer read GetLineCount;
    property Lines[LineNum: Integer]: TCnList read GetLines;
    property CurrentPair: TCnBlockLinePair read FCurrentPair;
    {* 代表光标下的标识符是块分界标识符，并非光标在块的内部}
    property CurrentToken: TCnGeneralPasToken read FCurrentToken;
  end;

  TCnCompDirectiveInfo = class(TCnBlockLineInfo)
  {* 每个 EditControl 对应一个，由对应的 BlockMatchInfo 转换而来，包括多个
     TCompDirectivePair. 实现上沿用 TBlockLineInfo，但输出的 TBlockLinePair
     实际上是 TCompDirectivePair}
    procedure FindCurrentPair(View: IOTAEditView; IsCppModule: Boolean = False); override;
    {* 寻找其中一个编译指令在光标下的一组编译指令对，使用 Ansi 模式}
  end;

  TCnCurLineInfo = class(TObject)
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
    FBlockMatchList: TObjectList;      // 存放 TCnBlockMatchInfo 实例的
    FBlockLineList: TObjectList;
    FCompDirectiveList: TObjectList;
    FLineMapList: TObjectList;   // 容纳行映射信息
{$IFNDEF BDS}
    FCorIdeModule: HMODULE;
    FCurLineList: TObjectList;   // 容纳当前行背景高亮重画的信息
{$ENDIF}
    FBlockShortCut: TCnWizShortCut;
    FBlockMatchMaxLines: Integer;
    FStructureTimer: TTimer;
    FCurrentTokenValidateTimer: TTimer;
    FIsChecking: Boolean;
    CharSize: TSize;
    FBlockMatchLineLimit: Boolean;
    FBlockMatchLineWidth: Integer;
    FBlockMatchLineClass: Boolean;
    FBlockMatchLineNamespace: Boolean;
    FBlockMatchHighlight: Boolean;
    FBlockMatchBackground: TColor;
    FCurrentTokenHighlight: Boolean;
    FCurrentTokenDelay: Integer;
    FCurrentTokenInvalid: Boolean;
    FHilightSeparateLine: Boolean;
    FCurrentTokenBackground: TColor;
    FCurrentTokenForeground: TColor;
    FCurrentTokenBorderColor: TColor;
    FShowTokenPosAtGutter: Boolean;
    FBlockMatchLineEnd: Boolean;
    FBlockMatchLineHori: Boolean;
    FBlockMatchLineHoriDot: Boolean;
    FBlockExtendLeft: Boolean;
    FBlockMatchLineSolidCurrent: Boolean;
    FBlockMatchLineStyle: TCnLineStyle;
    FKeywordHighlight: TCnHighlightItem;
    FIdentifierHighlight: TCnHighlightItem;
    FCompDirectiveHighlight: TCnHighlightItem; // 注意 Pascal 和 C++ 的都用这同一个，在D56/BCB56 里会有不一致的问题所以还需要一个
{$IFNDEF COMPILER7_UP}
    FCompDirectiveOtherHighlight: TCnHighlightItem; // D56/BCB56 下需要另一个，用来分别指示 C++/Pascal 的内容
{$ENDIF}
    FDirtyList: TList;
    FViewChangedList: TList;
    FViewFileNameIsPascalList: TList;
{$IFDEF BDS}
    FRawLineText: string; // Ansi/Utf8/Utf16
    FUseTabKey: Boolean;
    FTabWidth: Integer;
{$ELSE}
    FHighLightCurrentLine: Boolean;
    FHighLightLineColor: TColor;
    FDefaultHighLightLineColor: TColor;
{$ENDIF}
    FSeparateLineColor: TColor;
    FSeparateLineStyle: TCnLineStyle;
    FSeparateLineWidth: Integer;
    FHighlightFlowStatement: Boolean;
    FFlowStatementBackground: TColor;
    FFlowStatementForeground: TColor;
    FHighlightCompDirective: Boolean;
    FCompDirectiveBackground: TColor;
    FHighlightCustomIdentifier: Boolean;
    FCustomIdentifierBackground: TColor;
    FCustomIdentifierForeground: TColor;
    FCustomIdentifiers: TStringList;
{$IFDEF IDE_STRING_ANSI_UTF8}
    FCustomWideIdentfiers: TCnWideStringList;
{$ENDIF}
    function GetColorFg(ALayer: Integer): TColor;
    function EditorGetTextRect(Editor: TCnEditorObject; AnsiPos: TOTAEditPos;
      {$IFDEF BDS}const LineText: string; {$ENDIF} const AText: TCnIdeTokenString;
      var ARect: TRect): Boolean;
    {* 计算某 EditPos 位置的指定字符串在所在的行中的 Rect，注意绘制所用的 Rect
      视觉上是 Ansi 效果，因此 D2005~2007 的 Utf8 的 EditPos 不能直接用。
      LineText 是 Ansi/Utf8/Utf16，AText 是解析的 Token，是 Ansi/Utf16/Utf16}
    procedure EditorPaintText(EditControl: TControl; ARect: TRect; AText: AnsiString;
      AColor, AColorBk, AColorBd: TColor; ABold, AItalic, AUnderline: Boolean);
    function IndexOfBracket(EditControl: TControl): Integer;
    function GetBracketMatch(EditView: IOTAEditView; EditBuffer: IOTAEditBuffer;
      EditControl: TControl; AInfo: TCnBracketInfo): Boolean;
    procedure CheckBracketMatch(Editor: TCnEditorObject);

    function IndexOfBlockMatch(EditControl: TControl): Integer;
    function IndexOfBlockLine(EditControl: TControl): Integer;
    function IndexOfCompDirectiveLine(EditControl: TControl): Integer;
{$IFNDEF BDS}
    function IndexOfCurLine(EditControl: TControl): Integer;
{$ENDIF}
{$IFDEF BDS}
    procedure UpdateTabWidth;
{$ENDIF}
    procedure OnHighlightTimer(Sender: TObject);
    procedure OnHighlightExec(Sender: TObject);
    procedure OnCurrentTokenValidateTimer(Sender: TObject);
    procedure BeginUpdateEditor(Editor: TCnEditorObject);
    procedure EndUpdateEditor(Editor: TCnEditorObject);
    // 标记一行代码需要重画，只有在 BeginUpdateEditor 和 EndUpdateEditor 之间调用有效
    procedure EditorMarkLineDirty(LineNum: Integer);
    procedure RefreshCurrentTokens(Info: TCnBlockMatchInfo);
    procedure UpdateHighlight(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);
    procedure ActiveFormChanged(Sender: TObject);
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean);
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
    procedure SourceEditorNotify(SourceEditor: IOTASourceEditor;
      NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
    procedure EditorChanged(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);
    procedure EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState; var Handled: Boolean);
    procedure ClearHighlight(Editor: TCnEditorObject);
    procedure PaintBracketMatch(Editor: TCnEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintBlockMatchKeyword(Editor: TCnEditorObject; // 其他非匹配的高亮都在里头画
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintBlockMatchLine(Editor: TCnEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintLine(Editor: TCnEditorObject; LineNum, LogicLineNum: Integer);
    function GetBlockMatchHotkey: TShortCut;
    procedure SetBlockMatchHotkey(const Value: TShortCut);
    procedure SetBlockMatchLineClass(const Value: Boolean);
    procedure ReloadIDEFonts;
    procedure SetHilightSeparateLine(const Value: Boolean);
{$IFNDEF BDS}
    procedure BeforePaintLine(Editor: TCnEditorObject; LineNum, LogicLineNum: Integer);
    procedure SetHighLightCurrentLine(const Value: Boolean);
    procedure SetHighLightLineColor(const Value: TColor);
{$ENDIF}
    procedure SetFlowStatementBackground(const Value: TColor);
    procedure SetHighlightFlowStatement(const Value: Boolean);
    procedure SetFlowStatementForeground(const Value: TColor);
    procedure SetCompDirectiveBackground(const Value: TColor);
    procedure SetHighlightCompDirective(const Value: Boolean);
    procedure SetBlockMatchLineNamespace(const Value: Boolean);
    procedure SetCustomIdentifierBackground(const Value: TColor);
    procedure SetCustomIdentifierForeground(const Value: TColor);
  protected
{$IFDEF IDE_EDITOR_CUSTOM_COLUMN}
    procedure GutterChangeRepaint(Sender: TObject);
{$ENDIF}
    function CanSolidCurrentLineBlock: Boolean;
    procedure DoEnhConfig;
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
  public
    // 放出来让设置窗口读写
    FHighLightColors: array[-1..5] of TColor;

    constructor Create; override;
    destructor Destroy; override;

{$IFDEF IDE_STRING_ANSI_UTF8}
    procedure SyncCustomWide; // 2005/2006/2007 下使用宽字符串进行对比
{$ENDIF}

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;

    procedure RepaintEditors;
    {* 让设置窗口调用，强迫重画}
{$IFDEF BDS}
    property UseTabKey: Boolean read FUseTabKey;
    {* 当前编辑器环境是否使用 Tab 键，从 IDE 选项获得，供外界使用}
    property TabWidth: Integer read FTabWidth;
    {* 当前编辑器环境的 Tab 宽度，从 IDE 选项获得，供外界使用}
{$ENDIF}

    property MatchedBracket: Boolean read FMatchedBracket write FMatchedBracket;
    {* 是否括号配对高亮}
    property BracketColor: TColor read FBracketColor write FBracketColor;
    {* 括号配对高亮的前景色}
    property BracketBold: Boolean read FBracketBold write FBracketBold;
    {* 括号配对高亮时的括号是否加粗绘制}
    property BracketColorBk: TColor read FBracketColorBk write FBracketColorBk;
    {* 括号配对高亮的背景色}
    property BracketColorBd: TColor read FBracketColorBd write FBracketColorBd;
    {* 括号配对高亮的边框色}
    property BracketMiddle: Boolean read FBracketMiddle write FBracketMiddle;
    {* 光标在括号配对间时是否高亮}
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
    property ShowTokenPosAtGutter: Boolean read FShowTokenPosAtGutter write FShowTokenPosAtGutter;
    {* 是否把光标下当前标识符们的位置显示在行号栏上}
    property BlockHighlightRange: TBlockHighlightRange read FBlockHighlightRange write FBlockHighlightRange;
    {* 高亮范围，默认改成了 brAll}
    property BlockHighlightStyle: TBlockHighlightStyle read FBlockHighlightStyle write FBlockHighlightStyle;
    {* 高亮延时模式，默认改成了 bsNow}
    property BlockMatchDelay: Cardinal read FBlockMatchDelay write FBlockMatchDelay;
    {* 高亮为延时模式时的延时，单位是毫秒}
    property BlockMatchHotkey: TShortCut read GetBlockMatchHotkey write SetBlockMatchHotkey;
    {* 高亮为热键模式时按什么热键显示高亮}
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
    property BlockMatchLineSolidCurrent: Boolean read FBlockMatchLineSolidCurrent write FBlockMatchLineSolidCurrent;
    {* 是否对于光标下的标识符所对应的配对画线，强制使用实线绘制以突出当前块}
    property BlockMatchLineClass: Boolean read FBlockMatchLineClass write SetBlockMatchLineClass;
    {* Pascal 中是否画线匹配 class/record/interface 等的声明}
    property BlockMatchLineNamespace: Boolean read FBlockMatchLineNamespace write SetBlockMatchLineNamespace;
    {* C/C++ 中是否画线匹配 namespace 的大括号}
{$IFNDEF BDS}
    property HighLightCurrentLine: Boolean read FHighLightCurrentLine write SetHighLightCurrentLine;
    {* 是否高亮当前行的背景}
    property HighLightLineColor: TColor read FHighLightLineColor write SetHighLightLineColor;
    {* 高亮当前行的背景色}
{$ENDIF}
    property HilightSeparateLine: Boolean read FHilightSeparateLine write SetHilightSeparateLine;
    {* 是否绘制空行分隔线}
    property SeparateLineColor: TColor read FSeparateLineColor write FSeparateLineColor;
    {* 空行分隔线的颜色}
    property SeparateLineStyle: TCnLineStyle read FSeparateLineStyle write FSeparateLineStyle;
    {* 空行分隔线的线型}
    property SeparateLineWidth: Integer read FSeparateLineWidth write FSeparateLineWidth;
    {* 空行分隔线的线宽，默认为 1}
    property BlockMatchLineLimit: Boolean read FBlockMatchLineLimit write FBlockMatchLineLimit;
    {* 是否单元超出指定行数后禁用高亮功能，为性能考虑而设置}
    property BlockMatchMaxLines: Integer read FBlockMatchMaxLines write FBlockMatchMaxLines;
    {* 达到禁用高亮功能的行数阈值}
    property HighlightFlowStatement: Boolean read FHighlightFlowStatement write SetHighlightFlowStatement;
    {* 是否高亮流程控制语句}
    property FlowStatementBackground: TColor read FFlowStatementBackground write SetFlowStatementBackground;
    {* 高亮流程控制语句的背景色}
    property FlowStatementForeground: TColor read FFlowStatementForeground write SetFlowStatementForeground;
    {* 高亮流程控制语句的前景色}

    property HighlightCompDirective: Boolean read FHighlightCompDirective write SetHighlightCompDirective;
    {* 高亮当前条件编译指令}
    property CompDirectiveBackground: TColor read FCompDirectiveBackground write SetCompDirectiveBackground;
    {* 高亮当前条件编译指令的背景色}

    property HighlightCustomIdentifier: Boolean read FHighlightCustomIdentifier write FHighlightCustomIdentifier;
    {* 是否高亮自定义内容}
    property CustomIdentifierBackground: TColor read FCustomIdentifierBackground write SetCustomIdentifierBackground;
    {* 高亮自定义内容的背景色}
    property CustomIdentifierForeground: TColor read FCustomIdentifierForeground write SetCustomIdentifierForeground;
    {* 高亮自定义内容的前景色}
    property CustomIdentifiers: TStringList read FCustomIdentifiers;
    {* 需要高亮的自定义标识符列表}

    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

function LoadIDEDefaultCurrentColor: TColor;
{* 根据 IDE 配色方案自动调整的初始化高亮背景色}

procedure HighlightCanvasLine(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer;
  AStyle: TCnLineStyle);
{* 高亮专用的画线函数，TinyDot 时不画斜线}

function CheckTokenMatch(const T1, T2: PCnIdeTokenChar; CaseSensitive: Boolean): Boolean;
{* 判断是否俩 Identifer 相等}

function CheckIsCompDirectiveToken(AToken: TCnGeneralPasToken; IsCpp: Boolean;
  NextToken: TCnGeneralPasToken = nil): Boolean;
{* 判断是否是条件编译指令，NextToken 用于 #pragma region/end_region 的情形}

{$IFNDEF BDS}
procedure MyEditorsCustomEditControlSetForeAndBackColor(ASelf: TObject;
  Param1, Param2, Param3, Param4: Cardinal);
{$ENDIF}

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

implementation

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizMethodHook, CnSourceHighlightFrm, CnWizCompilerConst, CnEventBus;

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

  csReservedWord = 'Reserved word'; // RegName of IDE Font for Reserved word
  csIdentifier = 'Identifier';      // RegName of IDE Font for Identifier
{$IFDEF DELPHI5}
  csCompDirective = 'Comment';      // Delphi 5/6 Compiler Directive = Comment
{$ELSE}
  {$IFDEF DELPHI6}
  csCompDirective = 'Comment';
  {$ELSE}
  csCompDirective = 'Preprocessor'; // RegName of IDE Font for Compiler Directive
  {$ENDIF}
{$ENDIF}

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
  csBlockMatchLineNamespace = 'BlockMatchLineNamespace';
  csBlockMatchLineEnd = 'BlockMatchLineEnd';
  csBlockMatchLineHori = 'BlockMatchLineHori';
  csBlockMatchLineHoriDot = 'BlockMatchLineHoriDot';
  csBlockMatchLineSolidCurrent = 'BlockMatchLineSolidCurrent';
  csBlockMatchHighlight = 'BlockMatchHighlight';
  csBlockMatchBackground = 'BlockMatchBackground';

  csCurrentTokenHighlight = 'CurrentTokenHighlight';
  csCurrentTokenColor = 'CurrentTokenColor';
  csCurrentTokenColorBk = 'CurrentTokenColorBk';
  csCurrentTokenColorBd = 'CurrentTokenColorBd';
  csShowTokenPosAtGutter = 'ShowTokenPosAtGutter';
  csLineGutterColor = 'LineGutterColor';

  csHilightSeparateLine = 'HilightSeparateLine';
  csSeparateLineColor = 'SeparateLineColor';
  csSeparateLineStyle = 'SeparateLineStyle';
  csSeparateLineWidth = 'SeparateLineWidth';
  csBlockMatchHighlightColor = 'BlockMatchHighlightColor';
  csHighlightCurrentLine = 'HighLightCurrentLine';
  csHighLightLineColor = 'HighLightLineColor';
  csHighlightFlowStatement = 'HighlightFlowStatement';
  csFlowStatementBackground = 'FlowStatementBackground';
  csFlowStatementForeground = 'FlowStatementForeground';
  csHighlightCompDirective = 'HighlightCompDirective';
  csCompDirectiveBackground = 'CompDirectiveBackground';
  csHighlightCustomIdentifier = 'HighlightCustomIdentifier';
  csCustomIdentifierBackground = 'CustomIdentifierBackground';
  csCustomIdentifierForeground = 'CustomIdentifierForeground';
  csCustomIdentifiers = 'CustomIdentifiers';

var
  FHighlight: TCnSourceHighlight = nil;
  GlobalIgnoreClass: Boolean = False;
  GlobalIgnoreNamespace: Boolean = False;
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

  PairPool: TCnList = nil;

// 用池方式来管理 TCnBlockLinePair 以提高性能
function CreateLinePair: TCnBlockLinePair;
begin
  if PairPool.Count > 0 then
  begin
    Result := TCnBlockLinePair(PairPool.Last);
    PairPool.Delete(PairPool.Count - 1);
  end
  else
    Result := TCnBlockLinePair.Create;
end;

procedure FreeLinePair(Pair: TCnBlockLinePair);
begin
  if Pair <> nil then
  begin
    Pair.Clear;
    PairPool.Add(Pair);
  end;
end;

procedure ClearPairPool;
var
  I: Integer;
begin
  for I := 0 to PairPool.Count - 1 do
    TObject(PairPool[I]).Free;
end;

function EqualIdeToken(S1, S2: PCnIdeTokenChar; CaseSensitive: Boolean = False): Boolean;
  {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
  if CaseSensitive then
  begin
{$IFDEF BDS}
    Result := lstrcmpW(S1, S2) = 0;
{$ELSE}
    Result := lstrcmpA(S1, S2) = 0;
{$ENDIF}
  end
  else
  begin
{$IFDEF BDS}
    Result := lstrcmpiW(S1, S2) = 0;
{$ELSE}
    Result := lstrcmpiA(S1, S2) = 0;
{$ENDIF}
  end;
end;

function TCnBlockMatchInfo.CheckIsFlowToken(AToken: TCnGeneralPasToken; IsCpp: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AToken = nil then
    Exit;

  if IsCpp then // 区分大小写
  begin
    if AToken.CppTokenKind in csCppFlowTokenKinds then // 先比关键字
    begin
      Result := True;
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Cpp TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
      Exit;
    end
    else
    begin
      for I := Low(csCppFlowTokenStr) to High(csCppFlowTokenStr) do
      begin
        if EqualIdeToken(AToken.Token, @((csCppFlowTokenStr[I])[1]), True) then
        begin
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Cpp is Flow. TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
          Result := True;
          Exit;
        end;
      end;
    end;
  end
  else // 不区分大小写
  begin
    if AToken.TokenID in csPasFlowTokenKinds then // 也先比关键字
    begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Pascal TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
      Result := True;
      Exit;
    end
    else
    begin
      for I := Low(csPasFlowTokenStr) to High(csPasFlowTokenStr) do
      begin
        Result := EqualIdeToken(AToken.Token, @((csPasFlowTokenStr[I])[1]));

        if Result then
        begin
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Pascal is Flow. TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  end;
end;

// 此函数非 Unicode IDE 下不应该被调用
function ConvertAnsiPositionToUtf8OnUnicodeText(const Text: string;
  AnsiCol: Integer): Integer;
{$IFDEF UNICODE}
var
  ULine: string;
  UniCol: Integer;
//  ALine: AnsiString;
{$ENDIF}
begin
  Result := AnsiCol;
  if Result <= 0 then
    Exit;

{$IFDEF UNICODE}
  // 括号匹配时，光标可能在行尾之外，也就是说 AnsiCol 超出字符串长度，所以必须指定
  // AllowExceedEnd 为 True 才能获得正确的匹配位置，否则就会被截断，产生匹配查找错误的问题
  UniCol := CalcWideStringDisplayLengthFromAnsiOffset(PWideChar(Text), AnsiCol,
    True, @IDEWideCharIsWideLength);
  ULine := Copy(Text, 1, UniCol - 1);
  Result := CalcUtf8LengthFromWideString(PWideChar(ULine)) + 1;

//  end
//  else // Ansi模式会出现 Accent Char 错位的问题
//  begin
//    ALine := AnsiString(Text);
//    ALine := Copy(ALine, 1, AnsiCol - 1);         // 按 Ansi 的 Col 截断
//    UniCol := Length(string(ALine)) + 1;          // 转回 Unicode 的 Col
//    ULine := Copy(Text, 1, UniCol - 1);           // 重新截断
//    ALine := CnAnsiToUtf8(AnsiString(ULine));     // 转成 Ansi-Utf8
//    Result := Length(ALine) + 1;                  // 取 UTF8 的长度
//  end;
{$ENDIF}
end;

function StartWithIdeToken(Pattern, Content: PCnIdeTokenChar; CaseSensitive: Boolean = False): Boolean;
  {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
var
  PP, PC: PCnIdeTokenChar;

  function IdeCharEqualIgnoreCase(P, C: TCnIdeTokenChar): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  var
    CI: TCnIdeTokenInt;
  begin
    Result := P = C;
    if not Result then
    begin
      // Assume Pattern already uppercase.
      CI := TCnIdeTokenInt(C);
      if (CI >= 97) and (CI <= 122) then  // if a..z to A..Z
      begin
        Dec(CI, 32);
        Result := P = TCnIdeTokenChar(CI);
      end;
    end;
  end;

begin
  PP := Pattern;
  PC := Content;

  if CaseSensitive then
  begin
    while (PP^ <> #0) and (PC^ <> #0) do
    begin
      Result := PP^ = PC^;
      if not Result then
        Exit;
      Inc(PP);
      Inc(PC);
    end;
    Result := PP^ = #0;
  end
  else
  begin
    while (PP^ <> #0) and (PC^ <> #0) do
    begin
      Result := IdeCharEqualIgnoreCase(PP^, PC^);
      if not Result then
        Exit;
      Inc(PP);
      Inc(PC);
    end;
    Result := PP^ = #0;
  end;
end;

{$IFDEF UNICODE}

// 此函数非 Unicode 环境下不应该被调用
function ConvertUtf8PositionToAnsi(const Utf8Text: AnsiString; Utf8Col: Integer): Integer;
var
  ALine: AnsiString;
  ULine: string;
begin
  Result := Utf8Col;
  if Result < 0 then
    Exit;

  ALine := Copy(Utf8Text, 1, Utf8Col - 1);
  ULine := string(Utf8Encode(ALine));
  Result := CalcAnsiDisplayLengthFromWideString(PWideChar(ULine), @IDEWideCharIsWideLength) + 1;
end;

{$ENDIF}

function CheckIsCompDirectiveToken(AToken: TCnGeneralPasToken; IsCpp: Boolean;
  NextToken: TCnGeneralPasToken): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AToken = nil then
    Exit;

  if IsCpp then
  begin
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('Cpp check. TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
    if AToken.CppTokenKind in csCppCompDirectiveKinds then // 比关键字
    begin
      Result := True;
      Exit;
    end
    else if (NextToken <> nil) and (AToken.CppTokenKind = ctkdirpragma) then
    begin
      // 检查 NextToken 是否是 region 与 end_region
      for I := Low(csCppCompDirectiveRegionTokenStr) to High(csCppCompDirectiveRegionTokenStr) do
      begin
        Result := EqualIdeToken(@(csCppCompDirectiveRegionTokenStr[I][1]), NextToken.Token, True);

        if Result then
        begin
          AToken.CompDirectiveType := csPasCompDirectiveTypes[I + CPP_PAS_REGION_TYPE_OFFSET];
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Cpp is CompDirective. TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  end
  else // 不区分大小写
  begin
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('Pascal check. TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
    if AToken.TokenID = tkCompDirect then // 也先比关键字
    begin
      for I := Low(csPasCompDirectiveTokenStr) to High(csPasCompDirectiveTokenStr) do
      begin
        Result := StartWithIdeToken(@(csPasCompDirectiveTokenStr[I][1]), AToken.Token);

        if Result then
        begin
          AToken.CompDirectiveType := csPasCompDirectiveTypes[I];
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Pascal is CompDirective. TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  end;
  Result := False;
end;

function CheckTokenMatch(const T1, T2: PCnIdeTokenChar; CaseSensitive: Boolean): Boolean;
begin
  if CaseSensitive then
  begin
{$IFDEF BDS}
    Result := lstrcmpW(T1, T2) = 0;
{$ELSE}
    Result := lstrcmpA(T1, T2) = 0;
{$ENDIF}
  end
  else
  begin
{$IFDEF BDS}
    Result := lstrcmpiW(T1, T2) = 0;
{$ELSE}
    Result := lstrcmpiA(T1, T2) = 0;
{$ENDIF}
  end;
end;

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
                YStep := Abs(Y2 - Y1) div (Step * 2); // Y 方向总步数，正值
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
                XStep := Abs(X2 - X1) div (Step * 2); // X 方向总步数
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

function TokenIsMethodOrClassName(const Token, Name: string): Boolean;
var
  I: Integer;
  S, sName: string;
begin
  Result := False;
  sName := Name;
  I := LastDelimiter('.', sName);
  if I > 0 then
    S := Copy(sName, I + 1, MaxInt)
  else
    S := sName;

  if AnsiSameText(Token, S) then
    Result := True;

  while (not Result) and (I > 0) do
  begin
    sName := Copy(sName, 1, I - 1);
    I := LastDelimiter('.', sName);
    if I > 0 then
      S := Copy(sName, I + 1, MaxInt)
    else
      S := sName;
    if AnsiSameText(Token, S) then
      Result := True;
  end;
end;

{ TCnBracketInfo }

constructor TCnBracketInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
end;

{ TCnBlockMatchInfo }

// 分析检查本 EditControl 中的结构高亮信息
function TCnBlockMatchInfo.CheckBlockMatch(
  BlockHighlightRange: TBlockHighlightRange): Boolean;
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  I: Integer;
  StartIndex, EndIndex: Integer;

  function IsHighlightKeywords(Parser: TCnGeneralPasStructParser; Idx: Integer): Boolean;
  var
    AToken, Prev: TCnGeneralPasToken;
  begin
    AToken := Parser.Tokens[Idx];
    Result := AToken.TokenID in csKeyTokens;
    if not Result then
      Exit;

    if AToken.TokenID = tkOf then
    begin
      // 对于 of 前一个关键字必须是 case 才配对
      // 注意不能用 Parser.Tokens，因为 case 和 of 间可能有其他标识符
      if FKeyTokenList.Count > 0 then
      begin
        Prev := TCnGeneralPasToken(FKeyTokenList[FKeyTokenList.Count - 1]);
        if (Prev = nil) or (Prev.TokenID <> tkCase) then
          Result := False;
      end
      else
        Result := False; // 第一个 of 也不算配对
    end
    else if AToken.TokenID = tkObject then
    begin
      // 对于 object，如果原始列表前面是 of，则不配对
      // 注意不能用 FKeyTokenList，因为 of 因为上面的原因可能没加进来
      if Idx > 0 then
      begin
        Prev := Parser.Tokens[Idx - 1];
        if (Prev <> nil) and (Prev.TokenID = tkOf) then
          Result := False;
      end;
    end;
  end;

begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TBlockMatchInfo.CheckBlockMatch');
{$ENDIF}

  Result := False;

  // 不能调用 Clear 来简单清除所有内容，必须保留 FCurTokenList，避免重画时不能刷新
  FKeyTokenList.Clear;
  FKeyLineList.Clear;
  FIdLineList.Clear;
  FFlowLineList.Clear;
  FSeparateLineList.Clear;
  FCompDirectiveLineList.Clear;
  if LineInfo <> nil then
    LineInfo.Clear;
  if CompDirectiveInfo <> nil then
    CompDirectiveInfo.Clear;

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
    CnDebugger.LogMsg('GetEditView Error');
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

        {$IFDEF BDS}
        CppParser.UseTabKey := True; // FHighlight.FUseTabKey;
        CppParser.TabWidth := FHighlight.FTabWidth;
        {$ENDIF}

        CnGeneralSaveEditorToStream(EditView.Buffer, Stream);
        CnCppParserParseSource(CppParser, Stream, EditView.CursorPos.Line, EditView.CursorPos.Col);
      finally
        Stream.Free;
      end;

      // 在 FKeyTokenList 中记录各个大括号的位置，
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
          FKeyTokenList.Add(CppParser.Tokens[I]);

      for I := 0 to KeyCount - 1 do
        ConvertGeneralTokenPos(Pointer(EditView), KeyTokens[I]);

      // 记录大括号的层次
      UpdateCurTokenList;
      UpdateFlowTokenList;
      UpdateCompDirectiveList;
      UpdateCustomIdentifierList;

      ConvertLineList;
      if LineInfo <> nil then
      begin
        CheckLineMatch(EditView, GlobalIgnoreClass, GlobalIgnoreNamespace);
    {$IFDEF DEBUG}
        CnDebugger.LogInteger(LineInfo.Count, 'HighLight Cpp LinePairs Count.');
    {$ENDIF}
      end;
      if CompDirectiveInfo <> nil then
      begin
        CheckCompDirectiveMatch(EditView);
    {$IFDEF DEBUG}
        CnDebugger.LogInteger(CompDirectiveInfo.Count, 'HighLight Cpp CompDirectivePairs Count.');
    {$ENDIF}
      end;
    end;
  end
  else  // 处理解析 Pascal 中的配对关键字
  begin
    if Modified or (PasParser.Source = '') then
    begin
      FIsCppSource := False;
      CaseSensitive := False;
      Stream := TMemoryStream.Create;
      try
  {$IFDEF DEBUG}
        CnDebugger.LogMsg('Parse Pascal Source file: ' + EditView.Buffer.FileName);
  {$ENDIF}

        {$IFDEF BDS}
        PasParser.UseTabKey := True; // FHighlight.FUseTabKey;
        PasParser.TabWidth := FHighlight.FTabWidth;
        {$ENDIF}

        CnGeneralSaveEditorToStream(EditView.Buffer, Stream);

        // 解析当前显示的源文件，需要高亮当前标识符时不设置 KeyOnly
        CnPasParserParseSource(PasParser, Stream, IsDpr(EditView.Buffer.FileName),
          not (FHighlight.CurrentTokenHighlight or FHighlight.HighlightFlowStatement));
      finally
        Stream.Free;
      end;
    end;

    // 解析后再查找当前光标所在的块，不直接使用 CursorPos，因为 Parser 所需偏移可能不同
    CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
    PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
    FCurrentBlockSearched := True;

    if BlockHighlightRange = brAll then
    begin
      // 处理本单元中的所有需要的匹配
      for I := 0 to PasParser.Count - 1 do
      begin
        if IsHighlightKeywords(PasParser, I) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
      end;
    end
    else if (BlockHighlightRange = brMethod) and Assigned(PasParser.MethodStartToken)
      and Assigned(PasParser.MethodCloseToken) then
    begin
      // 只把本过程中需要的 Token 加进来
      for I := PasParser.MethodStartToken.ItemIndex to
        PasParser.MethodCloseToken.ItemIndex do
        if IsHighlightKeywords(PasParser, I) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
    end
    else if (BlockHighlightRange = brWholeBlock) and Assigned(PasParser.BlockStartToken)
      and Assigned(PasParser.BlockCloseToken) then
    begin
      for I := PasParser.BlockStartToken.ItemIndex to
        PasParser.BlockCloseToken.ItemIndex do
        if IsHighlightKeywords(PasParser, I) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
    end
    else if (BlockHighlightRange = brInnerBlock) and Assigned(PasParser.InnerBlockStartToken)
      and Assigned(PasParser.InnerBlockCloseToken) then
    begin
      for I := PasParser.InnerBlockStartToken.ItemIndex to
        PasParser.InnerBlockCloseToken.ItemIndex do
        if IsHighlightKeywords(PasParser, I) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
    end;

    UpdateCurTokenList;
    UpdateFlowTokenList;
    UpdateCompDirectiveList;
    UpdateCustomIdentifierList;

    FCurrentBlockSearched := False;

  {$IFDEF DEBUG}
    CnDebugger.LogInteger(FKeyTokenList.Count, 'HighLight Pas KeyList Count.');
  {$ENDIF}
    Result := (FKeyTokenList.Count > 0) or (FCompDirectiveTokenList.Count > 0);

    if Result then
    begin
      for I := 0 to KeyCount - 1 do
        ConvertGeneralTokenPos(Pointer(EditView), KeyTokens[I]);

      ConvertLineList;
    end;

    if FHighlight.FHilightSeparateLine then
    begin
      UpdateSeparateLineList;
{$IFDEF DEBUG}
      CnDebugger.LogInteger(FSeparateLineList.Count, 'FSeparateLineList.Count');
{$ENDIF}
    end;

    if LineInfo <> nil then
    begin
      CheckLineMatch(EditView, GlobalIgnoreClass, GlobalIgnoreNamespace);
    {$IFDEF DEBUG}
      CnDebugger.LogInteger(LineInfo.Count, 'HighLight Pas LinePairs Count.');
    {$ENDIF}
    end;

    if CompDirectiveInfo <> nil then
    begin
      CheckCompDirectiveMatch(EditView);
    {$IFDEF DEBUG}
      CnDebugger.LogInteger(CompDirectiveInfo.Count, 'HighLight Pas CompDirectivePairs Count.');
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

procedure TCnBlockMatchInfo.UpdateSeparateLineList;
var
  MaxLine, I, J, LastSepLine, LastMethodCloseIdx: Integer;
  StateInMethodCloseStart: Boolean;
  Line: string;
begin
  MaxLine := 0;
  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    if KeyTokens[I].EditLine > MaxLine then
      MaxLine := KeyTokens[I].EditLine;
  end;
  FSeparateLineList.Count := MaxLine + 1;

  LastSepLine := 1;
  LastMethodCloseIdx := 0;
  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    if KeyTokens[I].IsMethodStart then
    begin
      // 遇到函数起始部分时，从上次的 LastSepLine 往后搜索到这个起始部分，找第一个空行标记
      // 即使这函数是匿名函数（实现在 begin 内的），也得参与此次搜索
      if LastSepLine > 1 then
      begin
        // 但如果在这之间先碰到了其他 KeyTokens，表示是语句，要忽略
        StateInMethodCloseStart := False;
        if LastMethodCloseIdx > 0 then
        begin
          for J := LastMethodCloseIdx + 1 to I - 1 do
          begin
            if KeyTokens[J].TokenID in csKeyTokens then
            begin
              StateInMethodCloseStart := True;
              Break;
            end;
          end;
        end;

        if StateInMethodCloseStart then
           Continue;

        // 本 MethodClose 与上面的 MethodStart 之间没有其他语句，判断空行
        for J := LastSepLine to KeyTokens[I].EditLine do
        begin
          Line := Trim(EditControlWrapper.GetTextAtLine(Control, J));
          if Line = '' then
          begin
            FSeparateLineList[J] := Pointer(CN_LINE_SEPARATE_FLAG);
            Break;
          end;
        end;
      end;
    end
    else if KeyTokens[I].IsMethodClose and not KeyTokens[I].MethodStartAfterParentBegin then
    begin
      // 只有正式定义的函数（可嵌套，但非匿名），它后面才需要出现分割线
      // 从 LastLine 到此 Token 前一个，均不是分隔线所在区域。记录其行号与 Token 索引
      LastSepLine := KeyTokens[I].EditLine + 1;
      LastMethodCloseIdx := I;
    end;
  end;
end;

procedure TCnBlockMatchInfo.UpdateFlowTokenList;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  I: Integer;
begin
  FCurMethodStartToken := nil;
  FCurMethodCloseToken := nil;

  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView Error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  FFlowTokenList.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
      if not FCurrentBlockSearched then   // 找当前块，供转换 Token 位置
      begin
        // 解析后再查找当前光标所在的块，不直接使用 CursorPos，因为 Parser 所需偏移可能不同
        CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
        PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
      end;

{$IFDEF DEBUG}
      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
        CnDebugger.LogFmt('CurrentMethod: %s, MethodStartToken: %d, MethodCloseToken: %d',
          [PasParser.CurrentMethod, PasParser.MethodStartToken.ItemIndex, PasParser.MethodCloseToken.ItemIndex]);
{$ENDIF}

      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
      begin
        FCurMethodStartToken := PasParser.MethodStartToken;
        FCurMethodCloseToken := PasParser.MethodCloseToken;
      end;

      // 无当前过程或高亮所有内容时搜索当前所有标识符，避免只高亮光标出于当前过程内的问题
      for I := 0 to PasParser.Count - 1 do
        ConvertGeneralTokenPos(Pointer(EditView), PasParser.Tokens[I]);

      // 高亮整个单元时，或当前无块时，高亮整个单元
      if (FCurMethodStartToken = nil) or (FCurMethodCloseToken = nil) or
        (FHighlight.BlockHighlightRange = brAll) then
      begin
        for I := 0 to PasParser.Count - 1 do
        begin
          if CheckIsFlowToken(PasParser.Tokens[I], FIsCppSource) then
            FFlowTokenList.Add(PasParser.Tokens[I]);
        end;
      end
      else if (FCurMethodStartToken <> nil) or (FCurMethodCloseToken <> nil) then // 其它范围便默认改为高亮本过程的
      begin
        for I := FCurMethodStartToken.ItemIndex to FCurMethodCloseToken.ItemIndex do
        begin
          if CheckIsFlowToken(PasParser.Tokens[I], FIsCppSource) then
            FFlowTokenList.Add(PasParser.Tokens[I]);
        end;
      end;
    end;

    FFlowLineList.Clear;
    ConvertFlowLineList;
  end
  else // 做 C/C++ 中的当前解析，将控制流程的标识符解析出来
  begin
    // 为了减少代码重构的工作量，此处 C/C++ 中当前解析出的标识符，仍旧用
    // TCnPasToken 来表示并加入 FFlowTokenList 中，但和 Pascal 语言相关的属性
    // 均无效，只有 Token 名和位置等有效。因此 C/C++ 的高亮流程控制不支持范围设置

    // 将解析出的流程控制的 Token 按范围规定加入 FFlowTokenList
    for I := 0 to CppParser.Count - 1 do
      ConvertGeneralTokenPos(Pointer(EditView), CppParser.Tokens[I]);

{$IFDEF DEBUG}
    CnDebugger.LogFmt('CppParser.Count: %d', [CppParser.Count]);
{$ENDIF}
    if (FHighlight.BlockHighlightRange in [brMethod, brWholeBlock])
      and Assigned(CppParser.BlockStartToken) and Assigned(CppParser.BlockCloseToken) then
    begin
      for I := CppParser.BlockStartToken.ItemIndex to CppParser.BlockCloseToken.ItemIndex do
      begin
        if CheckIsFlowToken(CppParser.Tokens[I], FIsCppSource) then
          FFlowTokenList.Add(CppParser.Tokens[I]);
      end;
    end
    else if (FHighlight.BlockHighlightRange in [brInnerBlock])
      and Assigned(CppParser.InnerBlockStartToken) and Assigned(CppParser.InnerBlockCloseToken) then
    begin
      for I := CppParser.InnerBlockStartToken.ItemIndex to CppParser.InnerBlockCloseToken.ItemIndex do
      begin
        if CheckIsFlowToken(CppParser.Tokens[I], FIsCppSource) then
          FFlowTokenList.Add(CppParser.Tokens[I]);
      end;
    end
    else // 整个范围
    begin
      for I := 0 to CppParser.Count - 1 do
      begin
        if CheckIsFlowToken(CppParser.Tokens[I], FIsCppSource) then
          FFlowTokenList.Add(CppParser.Tokens[I]);
      end;
    end;

    FFlowLineList.Clear;
    ConvertFlowLineList;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FFlowTokenList.Count: %d', [FFlowTokenList.Count]);
{$ENDIF}

  for I := 0 to FFlowTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnGeneralPasToken(FFlowTokenList[I]).EditLine);
end;

procedure TCnBlockMatchInfo.UpdateCurTokenList;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  I, TokenCursorIndex, StartIndex, EndIndex: Integer;
  AToken: TCnGeneralPasToken;
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
    CnDebugger.LogMsg('GetEditView Error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  for I := 0 to FCurTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(Integer(FCurTokenListEditLine[I]));

  FCurTokenList.Clear;
  FCurTokenListEditLine.Clear;
  FCurTokenListEditCol.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
      if not FCurrentBlockSearched then
      begin
        // 解析后再查找当前光标所在的块，不直接使用 CursorPos，因为 Parser 所需偏移可能不同
        CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
        PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
      end;

{$IFDEF DEBUG}
      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
        CnDebugger.LogFmt('CurrentMethod: %s, MethodStartToken: %d, MethodCloseToken: %d',
          [PasParser.CurrentMethod, PasParser.MethodStartToken.ItemIndex, PasParser.MethodCloseToken.ItemIndex]);
{$ENDIF}

      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
      begin
        FCurMethodStartToken := PasParser.MethodStartToken;
        FCurMethodCloseToken := PasParser.MethodCloseToken;
      end;

      CnOtaGeneralGetCurrPosToken(FCurrentTokenName, TokenCursorIndex, True, [], [], EditView);

      if FCurrentTokenName <> '' then
      begin
        StartIndex := 0;
        EndIndex := PasParser.Count - 1;

        // 高亮整个单元时，或当前是过程名与类名时，或无当前 Method 时，高亮整个单元
        if (FHighlight.BlockHighlightRange = brAll)
          or TokenIsMethodOrClassName(string(FCurrentTokenName), string(PasParser.CurrentMethod))
          or ((FCurMethodStartToken = nil) or (FCurMethodCloseToken = nil)) then
        begin
//          StartIndex := 0;
//          EndIndex := Parser.Count - 1;
        end
        else if (FCurMethodStartToken <> nil) or (FCurMethodCloseToken <> nil) then // 其它范围便默认改为高亮本过程的
        begin
          StartIndex := FCurMethodStartToken.ItemIndex;
          EndIndex := FCurMethodCloseToken.ItemIndex;
        end;

        // 必须搜索当前所有标识符，避免只高亮光标出于当前过程内的问题
        for I := StartIndex to EndIndex do
        begin
          AToken := PasParser.Tokens[I];
          if (AToken.TokenID = tkIdentifier) and // 此处判断支持双字节字符
            CheckTokenMatch(AToken.Token, PCnIdeTokenChar(FCurrentTokenName), CaseSensitive) then
          begin
            ConvertGeneralTokenPos(Pointer(EditView), AToken);

            FCurTokenList.Add(AToken);
            FCurTokenListEditLine.Add(Pointer(AToken.EditLine));
            if FHighlight.ShowTokenPosAtGutter then
              FCurTokenListEditCol.Add(Pointer(AToken.EditCol));
          end;
        end;

        if FCurTokenList.Count > 0 then
          FCurrentToken := FCurTokenList.Items[0];
      end;
    end;

    FIdLineList.Clear;
    ConvertIdLineList;
  end
  else // 做 C/C++ 中的当前解析，将相同的标识符解析出来
  begin
    // 为了减少代码重构的工作量，此处 C/C++ 中当前解析出的标识符，仍旧用
    // TCnPasToken 来表示并加入 FCurTokenList 中，但和 Pascal 语言相关的属性
    // 均无效，只有 Token 名和位置等有效。因此 C/C++ 的高亮标识符不支持范围设置

    CnOtaGeneralGetCurrPosToken(FCurrentTokenName, TokenCursorIndex, True, [], [], EditView);

    if FCurrentTokenName <> '' then
    begin
      StartIndex := 0;
      EndIndex := CppParser.Count - 1;

      if (FHighlight.BlockHighlightRange in [brMethod, brWholeBlock])
        and Assigned(CppParser.BlockStartToken) and Assigned(CppParser.BlockCloseToken) then
      begin
        StartIndex := CppParser.BlockStartToken.ItemIndex;
        EndIndex := CppParser.BlockCloseToken.ItemIndex;
      end
      else if (FHighlight.BlockHighlightRange in [brInnerBlock])
        and Assigned(CppParser.InnerBlockStartToken) and Assigned(CppParser.InnerBlockCloseToken) then
      begin
        StartIndex := CppParser.InnerBlockStartToken.ItemIndex;
        EndIndex := CppParser.InnerBlockCloseToken.ItemIndex;
      end;

      // 将解析出的同名 Token 按范围规定加入 FCurTokenList
      for I := StartIndex to EndIndex do
      begin
        AToken := CppParser.Tokens[I];
        if (AToken.CppTokenKind = ctkIdentifier) and
          CheckTokenMatch(AToken.Token, PCnIdeTokenChar(FCurrentTokenName), CaseSensitive) then
        begin
          ConvertGeneralTokenPos(Pointer(EditView), AToken);

//          CharPos := OTACharPos(AToken.CharIndex, AToken.LineNumber + 1);
//          EditView.ConvertPos(False, EditPos, CharPos);
//
//          // DONE: 以上这句本应在 D2009 时按以下修复，
//          // 但对于C/C++文件有Tab键存在时会出错导致高亮无法显示，故此先禁用
//      {$IFDEF BDS2009_UP}
//          // if not FHighlight.FUseTabKey then
//          // EditPos.Col := AToken.CharIndex;
//      {$ENDIF}
//          AToken.EditCol := EditPos.Col;
//          AToken.EditLine := EditPos.Line;

          FCurTokenList.Add(AToken);
          FCurTokenListEditLine.Add(Pointer(AToken.EditLine));
          if FHighlight.ShowTokenPosAtGutter then
              FCurTokenListEditCol.Add(Pointer(AToken.EditCol));
        end;
      end;
    end;

    FIdLineList.Clear;
    ConvertIdLineList;
  end;

  // 朝外界发送标识符所在行信息的更新通知
  if FHighlight.ShowTokenPosAtGutter then
  begin
    EventBus.PostEvent(EVENT_HIGHLIGHT_IDENT_POSITION, FCurTokenListEditLine,
      FCurTokenListEditCol);
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FCurTokenList.Count: %d; FCurrentTokenName: %s',
    [FCurTokenList.Count, FCurrentTokenName]);
{$ENDIF}

  for I := 0 to FCurTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnGeneralPasToken(FCurTokenList[I]).EditLine);
end;

procedure TCnBlockMatchInfo.UpdateCompDirectiveList;
var
  EditView: IOTAEditView;
  I: Integer;
  NextToken: TCnGeneralPasToken;
begin
  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView Error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  FCompDirectiveTokenList.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('UpdateCompDirectiveList.Count: %d', [Parser.Count]);
{$ENDIF}
      for I := 0 to PasParser.Count - 1 do // 编译指令直接针对整个单元
      begin
        if not CheckIsCompDirectiveToken(PasParser.Tokens[I], FIsCppSource) then
          Continue;

        ConvertGeneralTokenPos(Pointer(EditView), PasParser.Tokens[I]);
        FCompDirectiveTokenList.Add(PasParser.Tokens[I]);
      end;
    end;
  end
  else // 做 C/C++ 中的当前解析，将编译指令解析出来
  begin
    // 为了减少代码重构的工作量，此处 C/C++ 中当前解析出的标识符，仍旧用
    // TCnPasToken 来表示并加入 FCompDirectiveTokenList 中，但和 Pascal 语言相关的属性
    // 均无效，只有 Token 名和位置等有效。

    // 将解析出的条件编译的 Token 按范围规定加入 FCompDirectiveTokenList
    for I := 0 to CppParser.Count - 1 do
    begin
      if I = CppParser.Count - 1 then
        NextToken := nil
      else
        NextToken := CppParser.Tokens[I + 1];

      if not CheckIsCompDirectiveToken(CppParser.Tokens[I], FIsCppSource, NextToken) then
        Continue;

      ConvertGeneralTokenPos(Pointer(EditView), CppParser.Tokens[I]);
      FCompDirectiveTokenList.Add(CppParser.Tokens[I]);
    end;
  end;

  FCompDirectiveLineList.Clear;
  ConvertCompDirectiveLineList;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FCompDirectiveTokenList.Count: %d', [FCompDirectiveTokenList.Count]);
{$ENDIF}

  for I := 0 to FCompDirectiveTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnGeneralPasToken(FCompDirectiveTokenList[I]).EditLine);
end;

procedure TCnBlockMatchInfo.CheckLineMatch(View: IOTAEditView; IgnoreClass,
  IgnoreNamespace: Boolean);
var
  I: Integer;
  Pair, PrevPair, IfThenPair: TCnBlockLinePair;
  Token: TCnGeneralPasToken;
  CToken: TCnGeneralCppToken;
  IfThenSameLine, Added: Boolean;
begin
  if (LineInfo <> nil) and (FKeyTokenList.Count > 1) then
  begin
    // 遍历 KeyList 中的内容并将配对信息写入 LineInfo 中
    LineInfo.Clear;
    if FIsCppSource then // C/C++ 的大括号配对，比较简单
    begin
      try
        for I := 0 to FKeyTokenList.Count - 1 do
        begin
          CToken := TCnGeneralCppToken(FKeyTokenList[I]);
          if CToken.CppTokenKind = ctkbraceopen then
          begin
            Pair := CreateLinePair;
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

            Pair := TCnBlockLinePair(FStack.Pop);

            // 解析器里把 namespace 的左括号设成了 Tag = CN_CPP_BRACKET_NAMESPACE
            if IgnoreNamespace and (Pair.StartToken.Tag = CN_CPP_BRACKET_NAMESPACE) then
            begin
              Pair.Free;
            end
            else
            begin
              Pair.EndToken := CToken;
              Pair.EndLeft := CToken.EditCol;
              if Pair.Left > CToken.EditCol then // Left 取两者间较小的
                Pair.Left := CToken.EditCol;
              Pair.Bottom := CToken.EditLine;

              LineInfo.AddPair(Pair);
            end;
          end;
        end;
        LineInfo.ConvertLineList;
        LineInfo.FindCurrentPair(View, FIsCppSource);
      finally
        for I := 0 to FStack.Count - 1 do
          FreeLinePair(FStack.Pop);
      end;
    end
    else // Pascal 的语法配对处理，复杂得多
    begin
      try
        for I := 0 to FKeyTokenList.Count - 1 do
        begin
          Token := TCnGeneralPasToken(FKeyTokenList[I]);
          if Token.IsBlockStart then
          begin
            Pair := CreateLinePair;
            Pair.StartToken := Token;
            Pair.Top := Token.EditLine;
            Pair.StartLeft := Token.EditCol;
            Pair.Left := Token.EditCol;
            Pair.Layer := Token.ItemLayer - 1;

            FStack.Push(Pair);
          end
          else if Token.IsBlockClose then
          begin
            if FStack.Count = 0 then
              Continue;

            Pair := TCnBlockLinePair(FStack.Pop);

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

            if Pair.StartToken.TokenID in [tkClass, tkObject, tkRecord,
              tkInterface, tkDispInterface] then
            begin
              if not IgnoreClass then // 碰到 class record interface 时，需要画才添加进去
                LineInfo.AddPair(Pair)
              else
                FreeLinePair(Pair);
            end
            else
            begin
              LineInfo.AddPair(Pair);

              // 判断已经有的 if then 块，如本层次比其底，说明 if then 块已经结束，需要剔除
              while FIfThenStack.Count > 0 do
              begin
                IfThenPair := TCnBlockLinePair(FIfThenStack.Peek);
                if IfThenPair.Layer > Pair.Layer then
                  FIfThenStack.Pop
                else
                  Break;
              end;

              if (Pair.StartToken.TokenID = tkIf) and (Pair.EndToken.TokenID = tkThen) then
                FIfThenStack.Push(Pair);
              if (Pair.StartToken.TokenID = tkOn) and (Pair.EndToken.TokenID = tkDo) then
                FIfThenStack.Push(Pair);
              // 记下 if then 块，让后面的 else 来配。注意同时也处理 on Exception do 块
            end;
          end
          else
          begin
            Added := False;
            if Token.TokenID in [tkElse, tkExcept, tkFinally, tkOf] then
            begin
              // 处理几个中间带高亮语句的情形
              if FStack.Count > 0 then
              begin
                Pair := TCnBlockLinePair(FStack.Peek);
                if Pair <> nil then
                begin
                  if Pair.Layer = Token.ItemLayer - 1 then
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
              Pair := TCnBlockLinePair(FIfThenStack.Pop);
              while (FIfThenStack.Count > 0) and (Pair <> nil) and
                (Pair.Layer > Token.ItemLayer - 1) do
              begin
                Pair := TCnBlockLinePair(FIfThenStack.Pop);
              end;

              if (Pair <> nil) and (Pair.Layer = Token.ItemLayer - 1) then
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
        LineInfo.ConvertLineList;
        LineInfo.FindCurrentPair(View, FIsCppSource);
      finally
        for I := 0 to FIfThenStack.Count - 1 do
          FIfThenStack.Pop;
        for I := 0 to FStack.Count - 1 do
          FreeLinePair(FStack.Pop);
      end;
    end;
  end;
end;

procedure TCnBlockMatchInfo.CheckCompDirectiveMatch(View: IOTAEditView);
var
  I: Integer;
  PToken: TCnGeneralPasToken;
  CToken: TCnGeneralCppToken;
  Pair: TCnCompDirectivePair;
begin
  if (CompDirectiveInfo = nil) or (FCompDirectiveTokenList.Count <= 1) then
    Exit;

  CompDirectiveInfo.Clear;
  if FIsCppSource then
  begin
    // C 代码，if/ifdef/ifndef 与 endif 配对，else/elif 在中间
    try
      for I := 0 to FCompDirectiveTokenList.Count - 1 do
      begin
        CToken := TCnGeneralCppToken(FCompDirectiveTokenList[I]);
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('CompDirectiveInfo Check CompDirectivtType: %d', [Ord(CToken.CppTokenKind)]);
{$ENDIF}
        if (CToken.CppTokenKind in [ctkdirif, ctkdirifdef, ctkdirifndef])
          or (CToken.CompDirectiveType = ctRegion) then
        begin
          Pair := TCnCompDirectivePair.Create;
          Pair.StartToken := CToken;
          Pair.Top := CToken.EditLine;
          Pair.StartLeft := CToken.EditCol;
          Pair.Left := CToken.EditCol;
          Pair.Layer := CToken.ItemLayer - 1;

          if CToken.CompDirectiveType <> ctRegion then
            FStack.Push(Pair)
          else
            FRegionStack.Push(Pair);
        end
        else if CToken.CppTokenKind in [ctkdirelse, ctkdirelif] then
        begin
          if FStack.Count > 0 then
          begin
            Pair := TCnCompDirectivePair(FStack.Peek);
            if Pair <> nil then
              Pair.AddMidToken(CToken, CToken.EditCol);
          end;
        end
        else if (CToken.CppTokenKind = ctkdirendif) or (CToken.CompDirectiveType = ctEndRegion) then
        begin
          Pair := nil;
          if CToken.CompDirectiveType = ctEndRegion then
          begin
            if FRegionStack.Count = 0 then
              Continue;
            Pair := TCnCompDirectivePair(FRegionStack.Pop);
          end
          else
          begin
            if FStack.Count = 0 then
              Continue;
            Pair := TCnCompDirectivePair(FStack.Pop);
          end;

          if Pair <> nil then
          begin
            Pair.EndToken := CToken;
            Pair.EndLeft := CToken.EditCol;
            if Pair.Left > CToken.EditCol then // Left 取两者间较小的
              Pair.Left := CToken.EditCol;
            Pair.Bottom := CToken.EditLine;

            CompDirectiveInfo.AddPair(Pair);
          end;
        end;
      end;
      CompDirectiveInfo.ConvertLineList;
      CompDirectiveInfo.FindCurrentPair(View, FIsCppSource);
    finally
      for I := 0 to FStack.Count - 1 do
        TCnCompDirectivePair(FStack.Pop).Free;
    end;
  end
  else
  begin
    // Pascal 代码，IF/IFOPT/IFDEF/IFNDEF 与 ENDIF/IFEND 配对，ELSE 在中间
    try
      for I := 0 to FCompDirectiveTokenList.Count - 1 do
      begin
        PToken := TCnGeneralPasToken(FCompDirectiveTokenList[I]);
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('CompDirectiveInfo Check CompDirectivtType: %d', [Ord(PToken.CompDirectivtType)]);
{$ENDIF}
        if PToken.CompDirectiveType in [ctIf, ctIfOpt, ctIfDef, ctIfNDef, ctRegion] then
        begin
          Pair := TCnCompDirectivePair.Create;
          Pair.StartToken := PToken;
          Pair.Top := PToken.EditLine;
          Pair.StartLeft := PToken.EditCol;
          Pair.Left := PToken.EditCol;
          Pair.Layer := PToken.ItemLayer - 1;

          if PToken.CompDirectiveType <> ctRegion then
            FStack.Push(Pair)
          else
            FRegionStack.Push(Pair);
        end
        else if PToken.CompDirectiveType = ctElse then
        begin
          if FStack.Count > 0 then
          begin
            Pair := TCnCompDirectivePair(FStack.Peek);
            if Pair <> nil then
              Pair.AddMidToken(PToken, PToken.EditCol);
          end;
        end
        else if PToken.CompDirectiveType in [ctEndIf, ctIfEnd, ctEndRegion] then
        begin
          Pair := nil;
          if PToken.CompDirectiveType = ctEndRegion then
          begin
            if FRegionStack.Count = 0 then
              Continue;
            Pair := TCnCompDirectivePair(FRegionStack.Pop);
          end
          else
          begin
            if FStack.Count = 0 then
              Continue;
            Pair := TCnCompDirectivePair(FStack.Pop);
          end;

          if Pair <> nil then
          begin
            Pair.EndToken := PToken;
            Pair.EndLeft := PToken.EditCol;
            if Pair.Left > PToken.EditCol then // Left 取两者间较小的
              Pair.Left := PToken.EditCol;
            Pair.Bottom := PToken.EditLine;

            CompDirectiveInfo.AddPair(Pair);
          end;
        end;
      end;
      CompDirectiveInfo.ConvertLineList;
      CompDirectiveInfo.FindCurrentPair(View, FIsCppSource);
    finally
      for I := 0 to FStack.Count - 1 do
        TCnCompDirectivePair(FStack.Pop).Free;
      for I := 0 to FRegionStack.Count - 1 do
        TCnCompDirectivePair(FRegionStack.Pop).Free;
    end;
  end;
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CompDirectiveInfo Pair Count: %d', [CompDirectiveInfo.Count]);
{$ENDIF}
end;

procedure TCnBlockMatchInfo.Clear;
begin
  FKeyTokenList.Clear;
  FCurTokenList.Clear;
  FCurTokenListEditLine.Clear;
  FCurTokenListEditCol.Clear;
  FFlowTokenList.Clear;
  FCompDirectiveTokenList.Clear;
  FCustomIdentifierTokenList.Clear;

  FKeyLineList.Clear;
  FIdLineList.Clear;
  FFlowLineList.Clear;
  FSeparateLineList.Clear;
  FCompDirectiveLineList.Clear;
  FCustomIdentifierLineList.Clear;

  if LineInfo <> nil then
    LineInfo.Clear;
  if CompDirectiveInfo <> nil then
    CompDirectiveInfo.Clear;
end;

procedure TCnBlockMatchInfo.AddToKeyList(AToken: TCnGeneralPasToken);
begin
  FKeyTokenList.Add(AToken);
end;

procedure TCnBlockMatchInfo.AddToCurrList(AToken: TCnGeneralPasToken);
begin
  FCurTokenList.Add(AToken);
end;

procedure TCnBlockMatchInfo.AddToFlowList(AToken: TCnGeneralPasToken);
begin
  FFlowTokenList.Add(AToken);
end;

procedure TCnBlockMatchInfo.AddToCompDirectiveList(AToken: TCnGeneralPasToken);
begin
  FCompDirectiveTokenList.Add(AToken);
end;

constructor TCnBlockMatchInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FPasParser := TCnGeneralPasStructParser.Create;
  FCppParser := TCnGeneralCppStructParser.Create;

  FKeyTokenList := TCnList.Create;
  FCurTokenList := TCnList.Create;
  FCurTokenListEditLine := TCnList.Create;
  FCurTokenListEditCol := TCnList.Create;
  FFlowTokenList := TCnList.Create;
  FCompDirectiveTokenList := TCnList.Create;
  FCustomIdentifierTokenList := TCnList.Create;

  FKeyLineList := TCnFastObjectList.Create;
  FIdLineList := TCnFastObjectList.Create;
  FFlowLineList := TCnFastObjectList.Create;
  FSeparateLineList := TCnList.Create;
  FCompDirectiveLineList := TCnFastObjectList.Create;
  FCustomIdentifierLineList := TCnFastObjectList.Create;

  FStack := TStack.Create;
  FIfThenStack := TStack.Create;
  FRegionStack := TStack.Create;

  FModified := True;
  FChanged := True;

//  FHook := TCnControlHook.Create(nil);
//  FHook.AfterMessage := EditControlAfterMessage;
//  FHook.Hook(FControl);
//  FHook.Active := True;
end;

destructor TCnBlockMatchInfo.Destroy;
begin
//  FHook.Free;

  Clear;
  FStack.Free;
  FIfThenStack.Free;
  FRegionStack.Free;

  FKeyLineList.Free;
  FIdLineList.Free;
  FFlowLineList.Free;
  FCompDirectiveLineList.Free;
  FCustomIdentifierLineList.Free;
  FSeparateLineList.Free;

  FCustomIdentifierTokenList.Free;
  FCompDirectiveTokenList.Free;
  FFlowTokenList.Free;
  FCurTokenListEditLine.Free;
  FCurTokenListEditCol.Free;
  FCurTokenList.Free;
  FKeyTokenList.Free;

  FCppParser.Free;
  FPasParser.Free;
  inherited;
end;

//procedure TCnBlockMatchInfo.EditControlAfterMessage(Sender: TObject;
//  Control: TControl; var Msg: TMessage; var Handled: Boolean);
//var
//  Obj: TEditorObject;
//begin
//  // 尝试修补第一次打开时绘制偏差的问题，不确定是否生效
//  if Msg.Msg = WM_WINDOWPOSCHANGED then
//  begin
//{$IFDEF DEBUG}
//    CnDebugger.LogMsg('EditControl Got WindowPosChanged Message.');
//{$ENDIF}
//    Obj := EditControlWrapper.GetEditorObject(Control);
//    if Obj <> nil then
//    begin
//      Obj.NotifyIDEGutterChanged;
//      Control.Invalidate;
//    end;
//  end;
//end;

function TCnBlockMatchInfo.GetKeyCount: Integer;
begin
  Result := FKeyTokenList.Count;
end;

function TCnBlockMatchInfo.GetKeyTokens(Index: Integer): TCnGeneralPasToken;
begin
  Result := TCnGeneralPasToken(FKeyTokenList[Index]);
end;

function TCnBlockMatchInfo.GetCurTokens(Index: Integer): TCnGeneralPasToken;
begin
  Result := TCnGeneralPasToken(FCurTokenList[Index]);
end;

function TCnBlockMatchInfo.GetCurTokenCount: Integer;
begin
  Result := FCurTokenList.Count;
end;

function TCnBlockMatchInfo.GetFlowTokenCount: Integer;
begin
  Result := FFlowTokenList.Count;
end;

function TCnBlockMatchInfo.GetCompDirectiveTokenCount: Integer;
begin
  Result := FCompDirectiveTokenList.Count;
end;

function TCnBlockMatchInfo.GetFlowTokens(Index: Integer): TCnGeneralPasToken;
begin
  Result := TCnGeneralPasToken(FFlowTokenList[Index]);
end;

function TCnBlockMatchInfo.GetCompDirectiveTokens(Index: Integer): TCnGeneralPasToken;
begin
  Result := TCnGeneralPasToken(FCompDirectiveTokenList[Index]);
end;

function TCnBlockMatchInfo.GetLineCount: Integer;
begin
  Result := FKeyLineList.Count;
end;

function TCnBlockMatchInfo.GetIdLineCount: Integer;
begin
  Result := FIdLineList.Count;
end;

function TCnBlockMatchInfo.GetFlowLineCount: Integer;
begin
  Result := FFlowLineList.Count;
end;

function TCnBlockMatchInfo.GetCompDirectiveLineCount: Integer;
begin
  Result := FCompDirectiveLineList.Count;
end;

function TCnBlockMatchInfo.GetLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FKeyLineList[LineNum]);
end;

function TCnBlockMatchInfo.GetIdLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FIdLineList[LineNum]);
end;

function TCnBlockMatchInfo.GetFlowLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FFlowLineList[LineNum]);
end;

function TCnBlockMatchInfo.GetCompDirectiveLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FCompDirectiveLineList[LineNum]);
end;

procedure TCnBlockMatchInfo.ConvertLineList;
var
  I: Integer;
  Token: TCnGeneralPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    if KeyTokens[I].EditLine > MaxLine then
      MaxLine := KeyTokens[I].EditLine;
  end;
  FKeyLineList.Count := MaxLine + 1;

  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    Token := KeyTokens[I];
    if FKeyLineList[Token.EditLine] = nil then
      FKeyLineList[Token.EditLine] := TCnList.Create;
    TCnList(FKeyLineList[Token.EditLine]).Add(Token);
  end;

  ConvertIdLineList;
end;

procedure TCnBlockMatchInfo.ConvertIdLineList;
var
  I: Integer;
  Token: TCnGeneralPasToken;
  MaxLine: Integer;
begin
  if FHighlight.CurrentTokenHighlight then
  begin
    MaxLine := 0;
    for I := 0 to FCurTokenList.Count - 1 do
      if CurTokens[I].EditLine > MaxLine then
        MaxLine := CurTokens[I].EditLine;
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

procedure TCnBlockMatchInfo.ConvertFlowLineList;
var
  I: Integer;
  Token: TCnGeneralPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FFlowTokenList.Count - 1 do
    if FlowTokens[I].EditLine > MaxLine then
      MaxLine := FlowTokens[I].EditLine;
  FFlowLineList.Count := MaxLine + 1;

  if FHighlight.HighlightFlowStatement then
  begin
    for I := 0 to FFLowTokenList.Count - 1 do
    begin
      Token := FlowTokens[I];
      if FFlowLineList[Token.EditLine] = nil then
        FFlowLineList[Token.EditLine] := TCnList.Create;
      TCnList(FFlowLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

procedure TCnBlockMatchInfo.ConvertCompDirectiveLineList;
var
  I: Integer;
  Token: TCnGeneralPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FCompDirectiveTokenList.Count - 1 do
    if CompDirectiveTokens[I].EditLine > MaxLine then
      MaxLine := CompDirectiveTokens[I].EditLine;
  FCompDirectiveLineList.Count := MaxLine + 1;

  if FHighlight.HighlightCompDirective then
  begin
    for I := 0 to FCompDirectiveTokenList.Count - 1 do
    begin
      Token := CompDirectiveTokens[I];
      if FCompDirectiveLineList[Token.EditLine] = nil then
        FCompDirectiveLineList[Token.EditLine] := TCnList.Create;
      TCnList(FCompDirectiveLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

{ TCnSourceHighlight }

constructor TCnSourceHighlight.Create;
begin
  inherited;
  FHighlight := Self;

  // 以下初始化均无多大意义，会被 LoadSettings 里的默认值覆盖。
  FMatchedBracket := True;
  FBracketColor := clBlack;
  FBracketColorBk := clAqua;
  FBracketColorBd := $CCCCD6;
  FBracketBold := False;
  FBracketMiddle := True;
  FBracketList := TObjectList.Create;

  FStructureHighlight := True;
  FBlockMatchHighlight := True;     // 默认打开光标下配对的关键字高亮
  FBlockMatchBackground := clYellow;
{$IFNDEF BDS}
  FHighLightCurrentLine := True;     // 默认打开当前行高亮
  // FHighLightLineColor := LoadIDEDefaultCurrentColor; // 根据当前不同的色彩设置来设置不同色彩

  FDefaultHighLightLineColor := FHighLightLineColor; // 用来判断与保存
{$ENDIF}
  FCurrentTokenHighlight := True;    // 默认打开标识符高亮
  FCurrentTokenDelay := csShortDelay;
  FCurrentTokenBackground := csDefCurTokenColorBg;
  FCurrentTokenForeground := csDefCurTokenColorFg;
  FCurrentTokenBorderColor := csDefCurTokenColorBd;

  FShowTokenPosAtGutter := False; // 默认把标识符的位置显示在行号栏上

  FBlockHighlightRange := brAll;
  FBlockMatchDelay := 600;  // 默认延时 600 毫秒
  FBlockHighlightStyle := bsNow;

  FBlockMatchDrawLine := True; // 默认画线
  FBlockMatchLineWidth := 1;
  FBlockMatchLineClass := False;
  FBlockMatchLineNamespace := True;
  FBlockMatchLineHori := True;
  FBlockExtendLeft := True;
  FBlockMatchLineSolidCurrent := True;
  // FBlockMatchLineStyle := lsTinyDot;
  FBlockMatchLineHoriDot := True;

  FKeywordHighlight := TCnHighlightItem.Create;
  FIdentifierHighlight := TCnHighlightItem.Create;
  FCompDirectiveHighlight := TCnHighlightItem.Create;
{$IFNDEF COMPILER7_UP}
  FCompDirectiveOtherHighlight := TCnHighlightItem.Create;
{$ENDIF}
  FKeywordHighlight.Bold := True;

  FHilightSeparateLine := True;  // 默认画函数间的空行分隔线
  FSeparateLineColor := clGray;
  FSeparateLineStyle := lsSmallDot;
  FSeparateLineWidth := 1;

  FHighlightFlowStatement := True; // 默认画流程语句背景
  FFlowStatementBackground := csDefFlowControlBg;
  FFlowStatementForeground := clBlack;

  FHighlightCustomIdentifier := True; // 默认画自定义标识符
  FCustomIdentifierBackground := csDefaultCustomIdentifierBackground;
  FCustomIdentifierForeground := csDefaultCustomIdentifierForeground;
  FCustomIdentifiers := TStringList.Create;
{$IFDEF IDE_STRING_ANSI_UTF8}
  FCustomWideIdentfiers := TCnWideStringList.Create;
{$ENDIF}

  FHighlightCompDirective := True;    // 默认打开光标下的编译指令背景高亮
  FCompDirectiveBackground := csDefaultHighlightBackgroundColor;

  FBlockMatchLineLimit := True;
  FBlockMatchMaxLines := 60000; // 大于此行数的 unit，不解析
  FBlockMatchList := TObjectList.Create;
  FBlockLineList := TObjectList.Create;
  FCompDirectiveList := TObjectList.Create;
  FLineMapList := TObjectList.Create;
  FViewChangedList := TList.Create;
  FViewFileNameIsPascalList := TList.Create;
{$IFNDEF BDS}
  FCurLineList := TObjectList.Create;
{$ENDIF}
{$IFDEF BDS}
  UpdateTabWidth;
{$ENDIF}
  FBlockShortCut := WizShortCutMgr.Add(SCnSourceHighlightBlock, ShortCut(Ord('H'), [ssCtrl, ssShift]),
    OnHighlightExec);
  FStructureTimer := TTimer.Create(nil);
  FStructureTimer.Enabled := False;
  FStructureTimer.Interval := FBlockMatchDelay;
  FStructureTimer.OnTimer := OnHighlightTimer;

  FCurrentTokenValidateTimer := TTimer.Create(nil);
  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenValidateTimer.Interval := FCurrentTokenDelay;
  FCurrentTokenValidateTimer.OnTimer := OnCurrentTokenValidateTimer;

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
  EditControlWrapper.AddKeyDownNotifier(EditorKeyDown);
{$IFNDEF BDS}
  EditControlWrapper.AddBeforePaintLineNotifier(BeforePaintLine);
{$ENDIF}
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
  CnWizNotifierServices.AddAfterCompileNotifier(AfterCompile);
  CnWizNotifierServices.AddSourceEditorNotifier(SourceEditorNotify);
end;

destructor TCnSourceHighlight.Destroy;
begin
  FStructureTimer.Free;
  FCurrentTokenValidateTimer.Free;
  FBracketList.Free;
  FCompDirectiveList.Free;
  FBlockLineList.Free;
  FBlockMatchList.Free;
  FLineMapList.Free;
  FKeywordHighlight.Free;
  FIdentifierHighlight.Free;
{$IFNDEF COMPILER7_UP}
  FCompDirectiveOtherHighlight.Free;
{$ENDIF}
  FCompDirectiveHighlight.Free;
  FDirtyList.Free;
  FCustomIdentifiers.Free;
{$IFDEF IDE_STRING_ANSI_UTF8}
  FCustomWideIdentfiers.Free;
{$ENDIF}
  FViewFileNameIsPascalList.Free;
  FViewChangedList.Free;
{$IFNDEF BDS}
  FCurLineList.Free;
  SetForeAndBackColorHook.Free;
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);
{$ENDIF}

  WizShortCutMgr.DeleteShortCut(FBlockShortCut);
  CnWizNotifierServices.RemoveSourceEditorNotifier(SourceEditorNotify);
  CnWizNotifierServices.RemoveAfterCompileNotifier(AfterCompile);
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  EditControlWrapper.RemoveKeyDownNotifier(EditorKeyDown);
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

function TCnSourceHighlight.EditorGetTextRect(Editor: TCnEditorObject; AnsiPos: TOTAEditPos;
  {$IFDEF BDS}const LineText: string; {$ENDIF} const AText: TCnIdeTokenString;
  var ARect: TRect): Boolean;
{$IFDEF BDS}
var
  I, TotalLeftWidth: Integer;
{$IFNDEF IDE_STRING_ANSI_UTF8}
  TotalLen: Integer;
{$ELSE}
  Size: TSize;
{$ENDIF}
{$IFDEF UNICODE}
  UCol: Integer;
  U: string;
{$ELSE}
  U: WideString;
{$ENDIF}
  EditCanvas: TCanvas;

  function GetWideCharWidth(AChar: WideChar): Integer;
  begin
    if Integer(AChar) < $80  then
      Result := CharSize.cx
    else
    begin
{$IFDEF DELPHI110_ALEXANDRIA_UP}
      if IDEWideCharIsWideLength(AChar) then // D11 以上似乎固定画了
        Result := CharSize.cx * 2
      else
        Result := CharSize.cx;
{$ELSE}
      Result := Round(EditCanvas.TextWidth(AChar) / CharSize.cx) * CharSize.cx;
      // 这里怕是也有错，TextWidth 可能因为字体不存在等原因返回单个字符长，
      // 但 IDE 有可能会刻意让此字符保持两个字符宽度，无法确定其逻辑
{$ENDIF}
    end;
  end;
{$ENDIF}

begin
  with Editor do
  begin
    if InBound(AnsiPos.Line, EditView.TopRow, EditView.BottomRow) and
      InBound(AnsiPos.Col, EditView.LeftColumn, EditView.RightColumn) then
    begin
{$IFDEF BDS}
      EditCanvas := EditControlWrapper.GetEditControlCanvas(Editor.EditControl);
      TotalLeftWidth := 0;

  {$IFDEF UNICODE}
      // 遇到窄的双字节字符时转 AnsiString 会导致列计算错误，此处换一种方法
      UCol := CalcWideStringDisplayLengthFromAnsiOffset(PWideChar(LineText),
        AnsiPos.Col, False, @IDEWideCharIsWideLength);
      if UCol > 1 then
        U := Copy(LineText, 1, UCol - 1)
      else
        U := '';
  {$ELSE}
      if AnsiPos.Col > 1 then
        U := WideString(Copy(ConvertNtaEditorStringToAnsi(LineText, True), 1, AnsiPos.Col - 1))
      else
        U := '';
  {$ENDIF}

      // U 是 AText 左边的字符串，累计 U 的宽度用来计算左边的偏移
      if U <> '' then
      begin
        // 挨个记录每个字符（双字节）的宽度并累加
        for I := 1 to Length(U) do
          Inc(TotalLeftWidth, GetWideCharWidth(U[I]));

        // 然后减去横向滚动时左边隐藏的宽度
        if EditView.LeftColumn > 1 then
        begin
          TotalLeftWidth := TotalLeftWidth - (EditView.LeftColumn - 1) * CharSize.cx;
          if TotalLeftWidth < 0 then // 如果左边隐藏太多，则不显示
          begin
            Result := False;
            Exit;
          end;
        end;
      end;

  {$IFDEF IDE_STRING_ANSI_UTF8}
      // Canvas 在 2005～2007 下不能直接用 TextWidth 获得 WideString 宽度，得换 API
      Size.cX := 0;
      Size.cY := 0;

      GetTextExtentPoint32W(EditCanvas.Handle, PWideChar(AText), Length(AText), Size);
      ARect := Bounds(GutterWidth + TotalLeftWidth,
        (AnsiPos.Line - EditView.TopRow) * CharSize.cy, Size.cx,
        CharSize.cy);
  {$ELSE}
      // Unicode 环境下 EditCanvas.TextWidth(AText) 在 AText 中有汉字等场合有偏差，
      // 必须挨个计算字符宽度后累加，D2005 ~2007 暂不详
      TotalLen := 0;
      for I := 1 to Length(AText) do
        Inc(TotalLen, GetWideCharWidth(AText[I]));

      ARect := Bounds(GutterWidth + TotalLeftWidth,
        (AnsiPos.Line - EditView.TopRow) * CharSize.cy, TotalLen, CharSize.cy);
  {$ENDIF}
{$ELSE}
      ARect := Bounds(GutterWidth + (AnsiPos.Col - EditView.LeftColumn) * CharSize.cx,
        (AnsiPos.Line - EditView.TopRow) * CharSize.cy, CharSize.cx * Length(AText),
        CharSize.cy);
{$ENDIF}
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
  I: Integer;
begin
  for I := 0 to FBracketList.Count - 1 do
  begin
    if TCnBracketInfo(FBracketList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

// 以下代码使用 EditControlWrapper.GetTextAtLine 来取得某一行的代码，
// 因为使用 EditView.CharPosToPos 转换线性位置在大文件时很慢
// 由于 GetTextAtLine 取得的文本是将 Tab 扩展成空格的，故不再使用 ConvertPos 来转换
function TCnSourceHighlight.GetBracketMatch(EditView: IOTAEditView;
  EditBuffer: IOTAEditBuffer; EditControl: TControl; AInfo: TCnBracketInfo):
  Boolean;
var
  I: Integer;
  CL, CR: AnsiChar;
  LText: AnsiString;
  PL, PR: TOTAEditPos;
  CharPos: TOTACharPos;
  BracketCount: Integer;
  BracketChars: PBracketArray;
  AttributePos: TOTAEditPos;
  RawLine: string;
{$IFDEF IDE_STRING_ANSI_UTF8}
  W: WideString;
{$ENDIF}

  function InCommentOrString(APos: TOTAEditPos): Boolean;
  var
    Element, LineFlag: Integer;
  begin
    // IOTAEditView.GetAttributeAtPos 会导致选择区域失效、Undo 区混乱，故此处
    // 直接使用底层调用。注意，Unicode 环境下这个 APos 的 Col 必须是 UTF8 的。
    EditControlWrapper.GetAttributeAtPos(EditControl, APos, False, Element, LineFlag);
    Result := (Element = atComment) or (Element = atString) or
      (Element = atCharacter);
  end;

  // 历史原因，BDS 以上均使用 UTF8 搜索
  function ForwardFindMatchToken(const FindToken, MatchToken: AnsiString;
    out ALine: AnsiString): TOTAEditPos;
  var
    I, J, L, Layer: Integer;
    TopLine, BottomLine: Integer;
  {$IFDEF UNICODE}
    ULine: string;
  {$ENDIF}
    LineText: AnsiString;
  begin
    Result.Col := 0;
    Result.Line := 0;

    TopLine := CharPos.Line;
    BottomLine := Min(EditBuffer.GetLinesInBuffer, EditView.BottomRow);
    if TopLine <= BottomLine then
    begin
      Layer := 1;
      for I := TopLine to BottomLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode 环境下必须把返回的 UnicodeString 内容转成 UTF8，因为 InCommentOrString 所使用的底层调用要求必须 UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 直接转换成 Ansi 的 Utf8，中间不经过 AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = TopLine then
        begin
          L := CharPos.CharIndex + 1;  // 从光标后一个字符开始
{$IFDEF UNICODE}
          // L 是 0 开始，L + 1 是 CursorPos.Col，Unicode 环境下是 Ansi 的，需要转成 UTF8 以符合 LineText 的计算
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := 0;

        for J := L to Length(LineText) - 1 do
        begin
          if (LineText[J + 1] = FindToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Inc(Layer);
          end
          else if (LineText[J + 1] = MatchToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Dec(Layer);
            if Layer = 0 then
            begin
              ALine := LineText;
              Result := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
              // LineText 是 Utf8 的，转回 Ansi，Result 是 Utf8 的，转回 Ansi
              Result.Col := ConvertUtf8PositionToAnsi(LineText, Result.Col);
{$ENDIF}
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  // 历史原因，BDS 以上均使用 UTF8 搜索
  function BackFindMatchToken(const FindToken, MatchToken: AnsiString;
    out ALine: AnsiString): TOTAEditPos;
  var
    I, J, L, Layer: Integer;
    TopLine, BottomLine: Integer;
  {$IFDEF UNICODE}
    ULine: string;
  {$ENDIF}
    LineText: AnsiString;
  begin
    Result.Col := 0;
    Result.Line := 0;

    TopLine := EditView.GetTopRow;
    BottomLine := CharPos.Line;
    if TopLine <= BottomLine then
    begin
      Layer := 1;
      for I := BottomLine downto TopLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode 环境下必须把返回的 UnicodeString 内容转成 UTF8，因为 InCommentOrString 所使用的底层调用要求必须 UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 直接转换成 Ansi 的 Utf8，中间不经过 AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = BottomLine then
        begin
          L := CharPos.CharIndex - 1; // 从光标前一个字符开始
{$IFDEF UNICODE}
          // L 是 0 开始，L + 1 是 CursorPos.Col，Unicode 环境下是 Ansi 的，需要转成 UTF8 以符合 LineText 的计算
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := Length(LineText) - 1;

        for J := L downto 0 do
        begin
          if (LineText[J + 1] = FindToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Inc(Layer);
          end
          else if (LineText[J + 1] = MatchToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Dec(Layer);
            if Layer = 0 then
            begin
              ALine := LineText;
              Result := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
              // LineText 是 Utf8 的，转回 Ansi，Result 是 Utf8 的，转回 Ansi
              Result.Col := ConvertUtf8PositionToAnsi(LineText, Result.Col);
{$ENDIF}
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  // 历史原因，BDS 以上均使用 UTF8 搜索
  function FindMatchTokenFromMiddle: Boolean;
  var
    I, J, K, L: Integer;
    ML, MR: Integer;
    TopLine, BottomLine, Cnt: Integer;
    LineText: AnsiString;
    Layers: array of Integer;
  {$IFDEF UNICODE}
    ULine: string;
  {$ENDIF}
  begin
    Result := False;
    SetLength(Layers, BracketCount);
    CharPos.CharIndex := EditView.CursorPos.Col - 1;
    CharPos.Line := EditView.CursorPos.Line;
    TopLine := Min(CharPos.Line, EditView.TopRow);
    BottomLine := Min(EditBuffer.GetLinesInBuffer, Max(CharPos.Line, EditView.BottomRow));
    if TopLine <= BottomLine then
    begin
      ML := 0;
      MR := BracketCount - 1;
      for I := 0 to BracketCount - 1 do
        Layers[I] := 0;

      // 向前查找左括号
      Cnt := 0;
      for I := CharPos.Line downto TopLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode 环境下必须把返回的 UnicodeString 内容转成 UTF8，因为 InCommentOrString 所使用的底层调用要求必须 UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 直接转换成 Ansi 的 Utf8，中间不经过 AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = CharPos.Line then
        begin
          L := Min(CharPos.CharIndex, Length(LineText)) - 1;  // 从光标处或行尾（看哪个更小）往前找
{$IFDEF UNICODE}
          // L 是 0 开始，L + 1 是 CursorPos.Col，Unicode 环境下是 Ansi 的，需要转成 UTF8 以符合 LineText 的计算
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := Length(LineText) - 1;

        for J := L downto 0 do
        begin
          for K := 0 to BracketCount - 1 do
          begin
            if (LineText[J + 1] = BracketChars^[K][0]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              if Layers[K] = 0 then
              begin
                AInfo.TokenStr := BracketChars^[K][0];
                AInfo.TokenLine := LineText;
                AInfo.TokenPos := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
                // LineText 是 Utf8 的，转回 Ansi，Result 是 Utf8 的，转回 Ansi
                AInfo.TokenLine := CnUtf8ToAnsi(AInfo.TokenLine);
                AInfo.TokenPos := OTAEditPos(ConvertUtf8PositionToAnsi(LineText, AInfo.TokenPos.Col), I);
{$ENDIF}
                ML := K;
                MR := K;
                Break;
              end
              else
                Dec(Layers[K]);
            end
            else if (LineText[J + 1] = BracketChars^[K][1]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              Inc(Layers[K]);
            end;
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

      for I := 0 to BracketCount - 1 do
        Layers[I] := 0;

      // 向后查找右括号
      Cnt := 0;
      for I := CharPos.Line to BottomLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode 环境下必须把返回的 UnicodeString 内容转成 UTF8，因为 InCommentOrString 所使用的底层调用要求必须 UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 直接转换成 Ansi 的 Utf8，中间不经过 AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = CharPos.Line then
        begin
          L := CharPos.CharIndex;  // 从光标处往后找
{$IFDEF UNICODE}
          // L 是 0 开始，L + 1 是 CursorPos.Col，Unicode 环境下是 Ansi 的，需要转成 UTF8 以符合 LineText 的计算
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := 0;

        for J := L to Length(LineText) - 1 do
        begin
          for K := ML to MR do
          begin
            if (LineText[J + 1] = BracketChars^[K][1]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              if Layers[K] = 0 then
              begin
                AInfo.TokenMatchStr := BracketChars^[K][1];
                AInfo.TokenMatchLine := LineText;
                AInfo.TokenMatchPos := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
                // LineText 是 Utf8 的，转回 Ansi，Result 是 Utf8 的，转回 Ansi
                AInfo.TokenMatchLine := CnUtf8ToAnsi(AInfo.TokenMatchLine);
                AInfo.TokenMatchPos := OTAEditPos(ConvertUtf8PositionToAnsi(LineText, AInfo.TokenMatchPos.Col), I);
{$ENDIF}
                Break;
              end
              else
                Dec(Layers[K]);
            end
            else if (LineText[J + 1] = BracketChars^[K][0]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              Inc(Layers[K]);
            end;
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

    CharPos.CharIndex := EditView.CursorPos.Col - 1;
    CharPos.Line := EditView.CursorPos.Line;
    RawLine := EditControlWrapper.GetTextAtLine(EditControl, CharPos.Line);
{$IFDEF UNICODE}
    // 在 D2009 下是 UnicodeString，CursorPos 是 Ansi 位置，因此需要转成 Ansi。
    LText := ConvertUtf16ToAlterDisplayAnsi(PWideChar(RawLine), 'C');
{$ELSE}
    LText := AnsiString(RawLine);
    // BDS 下 CursorPos 是 utf8 的位置，LText 在 BDS 下是 UTF8，一致。
{$ENDIF}

    AttributePos := EditView.CursorPos;
{$IFDEF UNICODE}
    // 把 Ansi 的 TmpPos 的 Col 转成 UTF8 的
    AttributePos.Col := ConvertAnsiPositionToUtf8OnUnicodeText(RawLine, AttributePos.Col);
{$ENDIF}

    if not CnOtaIsEditPosOutOfLine(EditView.CursorPos, EditView) and
      not InCommentOrString(AttributePos) then
    begin
      // 使用 CursorPos.Col 在 LText 里搜索，偏移量与字符串都要求对应为 Ansi/Utf8/Ansi
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
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('GetBracketMatch Chars Left and Right to Cursor: ''%s'', ''%s''', [CL, CR]);
{$ENDIF}
        PR := EditView.CursorPos;
        for I := 0 to BracketCount - 1 do
        begin
          if CL = BracketChars^[I][0] then
          begin
            AInfo.TokenStr := CL;
            AInfo.TokenLine := LText;
            AInfo.TokenPos := PL;
            CharPos := OTACharPos(PL.Col - 1, PL.Line);
            AInfo.TokenMatchStr := BracketChars^[I][1];
            AInfo.TokenMatchPos := ForwardFindMatchToken(AInfo.TokenStr,
              AInfo.TokenMatchStr, AInfo.FTokenMatchLine);
            Result := True;
            Break;
          end
          else if CR = BracketChars^[I][1] then
          begin
            AInfo.TokenStr := CR;
            AInfo.TokenLine := LText;
            AInfo.TokenPos := PR;
            CharPos := OTACharPos(PR.Col - 1, PR.Line);
            AInfo.TokenMatchStr := BracketChars^[I][0];
            AInfo.TokenMatchPos := BackFindMatchToken(AInfo.TokenStr,
              AInfo.TokenMatchStr, AInfo.FTokenMatchLine);
            Result := True;
            Break;
          end;
        end;
      end;
    end;

    // 查找在括号中间的情形
    if not Result and FBracketMiddle then
      Result := FindMatchTokenFromMiddle;

{$IFDEF IDE_STRING_ANSI_UTF8}
    // BDS 下 LineText 是 Utf8，EditView.CursorPos.Col 也是 Utf8 字符串中的位置
    // 此处转换为 AnsiString 位置。D2009 中 LineText 不是 Utf8，因此这儿不需要转回。
    if Result then
    begin
      // 不做 Ansi 转换，免得出错
      W := Utf8Decode(Copy(AInfo.TokenLine, 1, AInfo.TokenPos.Col));
      AInfo.FTokenPos.Col := CalcAnsiDisplayLengthFromWideString(PWideChar(W));

      W := Utf8Decode(Copy(AInfo.TokenMatchLine, 1, AInfo.TokenMatchPos.Col));
      AInfo.FTokenMatchPos.Col := CalcAnsiDisplayLengthFromWideString(PWideChar(W));

//      AInfo.FTokenPos.Col := Length(CnUtf8ToAnsi(AnsiString(Copy(AInfo.TokenLine, 1,
//        AInfo.TokenPos.Col))));
//      AInfo.FTokenMatchPos.Col := Length(CnUtf8ToAnsi(AnsiString(Copy(AInfo.TokenMatchLine, 1,
//        AInfo.TokenMatchPos.Col))));
    end;
{$ENDIF}

{$IFDEF DEBUG}
    if Result then
    begin
      CnDebugger.LogFmt('TCnSourceHighlight.GetBracketMatch Matched! %s at %d:%d and %s at %d:%d.',
        [AInfo.TokenStr, AInfo.TokenPos.Line, AInfo.TokenPos.Col,
        AInfo.TokenMatchStr, AInfo.TokenMatchPos.Line, AInfo.TokenMatchPos.Col]);
    end;
{$ENDIF}
  finally
    AInfo.IsMatch := Result;
  end;
end;

procedure TCnSourceHighlight.CheckBracketMatch(Editor: TCnEditorObject);
var
  IsMatch: Boolean;
  Info: TCnBracketInfo;
begin
  if FIsChecking then Exit;
  FIsChecking := True;

  with Editor do
  try
    if IndexOfBracket(EditControl) >= 0 then
      Info := TCnBracketInfo(FBracketList[IndexOfBracket(EditControl)])
    else
    begin
      Info := TCnBracketInfo.Create(EditControl);
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

procedure TCnSourceHighlight.PaintBracketMatch(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  R: TRect;
  Info: TCnBracketInfo;
begin
  with Editor do
  begin
    if IndexOfBracket(EditControl) >= 0 then
    begin
      Info := TCnBracketInfo(FBracketList[IndexOfBracket(EditControl)]);
      if Info.IsMatch then
      begin
        if (LogicLineNum = Info.TokenPos.Line) and EditorGetTextRect(Editor,
          OTAEditPos(Info.TokenPos.Col, LineNum), {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Info.TokenStr), R) then
          EditorPaintText(EditControl, R, Info.TokenStr, BracketColor,
            BracketColorBk, BracketColorBd, BracketBold, False, False);

        if (LogicLineNum = Info.TokenMatchPos.Line) and EditorGetTextRect(Editor,
          OTAEditPos(Info.TokenMatchPos.Col, LineNum), {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Info.TokenMatchStr), R) then
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
  I: Integer;
begin
  for I := 0 to FBlockMatchList.Count - 1 do
  begin
    if TCnBlockMatchInfo(FBlockMatchList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function TCnSourceHighlight.IndexOfBlockLine(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FBlockLineList.Count - 1 do
    if TCnBlockLineInfo(FBlockLineList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

function TCnSourceHighlight.IndexOfCompDirectiveLine(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FCompDirectiveList.Count - 1 do
  begin
    if TCnCompDirectiveInfo(FCompDirectiveList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TCnSourceHighlight.ClearHighlight(Editor: TCnEditorObject);
var
  Index: Integer;
begin
  Index := IndexOfBlockMatch(Editor.EditControl);
  if Index >= 0 then
  begin
    with TCnBlockMatchInfo(FBlockMatchList[Index]) do
    begin
      FKeyTokenList.Clear;
      FKeyLineList.Clear;
      FIdLineList.Clear;
      FSeparateLineList.Clear;
      FFlowLineList.Clear;
      if LineInfo <> nil then
        LineInfo.Clear;
    end;
  end;

  Index := IndexOfBlockLine(Editor.EditControl);
  if Index >= 0 then
    with TCnBlockLineInfo(FBlockLineList[Index]) do
    begin
      Clear;
    end;

  Index := IndexOfCompDirectiveLine(Editor.EditControl);
  if Index >= 0 then
  begin
    with TCnCompDirectiveInfo(FCompDirectiveList[Index]) do
    begin
      Clear;
    end;
  end;

  Index := IndexOfBracket(Editor.EditControl);
  if Index >= 0 then
  begin
    with TCnBracketInfo(FBracketList[Index]) do
    begin
      IsMatch := False;
    end;
  end;
end;

// Editor 情况发生变化时被调用，如果内容改变，则重新进行语法分析
procedure TCnSourceHighlight.UpdateHighlight(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
var
  OldPair, NewPair: TCnBlockLinePair;
  Info: TCnBlockMatchInfo;
  Line: TCnBlockLineInfo;
  CompDirective: TCnCompDirectiveInfo;
{$IFNDEF BDS}
  CurLine: TCnCurLineInfo;
{$ENDIF}
  I: Integer;
  CurTokenRefreshed: Boolean;
begin
  with Editor do
  begin
    // 一个 EditControl 对应一个 TBlockMatchInfo，都放 FBlockMatchList 中
    if IndexOfBlockMatch(EditControl) >= 0 then
      Info := TCnBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)])
    else
    begin
      Info := TCnBlockMatchInfo.Create(EditControl);
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
        Line := TCnBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)])
      else
      begin
        Line := TCnBlockLineInfo.Create(EditControl);
        FBlockLineList.Add(Line);
      end;
    end;

    CompDirective := nil;
    if FHighlightCompDirective then
    begin
      // 生成编译指令配对对象
      if IndexOfCompDirectiveLine(EditControl) >= 0 then
        CompDirective := TCnCompDirectiveInfo(FCompDirectiveList[IndexOfCompDirectiveLine(EditControl)])
      else
      begin
        CompDirective := TCnCompDirectiveInfo.Create(EditControl);
        FCompDirectiveList.Add(CompDirective);
      end;
    end;

{$IFNDEF BDS}
    CurLine := nil;
    if FHighLightCurrentLine then
    begin
      // 如果高亮当前行的背景，则同时生成高亮背景的对象
      if IndexOfCurLine(EditControl) >= 0 then
        CurLine := TCnCurLineInfo(FCurLineList[IndexOfCurLine(EditControl)])
      else
      begin
        CurLine := TCnCurLineInfo.Create(EditControl);
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

{$IFDEF IDE_EDITOR_ELIDE}
    // C/C++ 代码折叠时原始划线会莫名消失，此处强行重新解析并绘制
    if Info.IsCppSource and (ChangeType = [ctElided, ctUnElided]) then
      Include(ChangeType, ctModified);
{$ENDIF}

    if (ChangeType * [ctView, ctModified {$IFDEF IDE_EDITOR_ELIDE}, ctElided, ctUnElided {$ENDIF}] <> []) or
      ((FBlockHighlightRange <> brAll) and (ChangeType * [ctCurrLine, ctCurrCol] <> [])) then
    begin
      FStructureTimer.Enabled := False;

      // 展开以及变动的情况，或者局部高亮时位置改动的情况，重新解析
      Info.FKeyTokenList.Clear;
      Info.FKeyLineList.Clear;
      Info.FIdLineList.Clear;
      Info.FSeparateLineList.Clear;
      Info.FFlowLineList.Clear;
      Info.FCompDirectiveLineList.Clear;

      if Info.LineInfo <> nil then
        Info.LineInfo.Clear;
      if Info.CompDirectiveInfo <> nil then
        Info.CompDirectiveInfo.Clear;
      // 以上不能调用 Info.Clear 来简单清除所有内容，必须不清 FCurTokenList
      // 避免重画时不能刷新

      if Line <> nil then
        Line.Clear;

      Info.LineInfo := Line;
      Info.CompDirectiveInfo := CompDirective;
      Info.FChanged := True;
      Info.FModified := ChangeType * [ctView, ctModified] <> [];

      if (EditView <> nil) then
      begin
        if not FBlockMatchLineLimit or (EditView.Buffer.GetLinesInBuffer <= FBlockMatchMaxLines) then
        begin
          // 正常情况下，延时一段时间再解析以避免重复
          case BlockHighlightStyle of
            bsNow: FStructureTimer.Interval := csShortDelay;
            bsDelay: FStructureTimer.Interval := BlockMatchDelay;
            bsHotkey: Exit;
          end;
          FStructureTimer.Enabled := True;
        end
        else // 大小超过了限制
        begin
          FStructureTimer.Enabled := False;
        end;
      end;
    end
    else if not FStructureTimer.Enabled then // 如果定时器已经开启，则不再处理
    begin
      CurTokenRefreshed := False;
      if ChangeType * [ctCurrLine, ctCurrCol] <> [] then
      begin
        if FCurrentTokenHighlight and not CurTokenRefreshed then
        begin
          if FBlockMatchLineLimit and (EditView.Buffer.GetLinesInBuffer > FBlockMatchMaxLines) then
          begin
            Info.Clear;
            if FShowTokenPosAtGutter then
              EventBus.PostEvent(EVENT_HIGHLIGHT_IDENT_POSITION);
          end
          else
            Info.UpdateCurTokenList;

          CurTokenRefreshed := True;
        end;

        // 只位置变动的话，只更新高亮显示关键字，以及编译指令
        if (Line <> nil) and (EditView <> nil) then
        begin
          OldPair := Line.CurrentPair;
          Line.FindCurrentPair(EditView); // 暂时不处理 C/C++ 的情况
          NewPair := Line.CurrentPair;
          if OldPair <> NewPair then
          begin
            if OldPair <> nil then
            begin
              if CanSolidCurrentLineBlock then // 高亮当前光标下的配对关键字块时，需要重画所影响的块
                for I := OldPair.Top to OldPair.Bottom do
                  EditorMarkLineDirty(I)
              else
              begin
                EditorMarkLineDirty(OldPair.Top);
                EditorMarkLineDirty(OldPair.Bottom);
                for I := 0 to OldPair.MiddleCount - 1 do
                  EditorMarkLineDirty(OldPair.MiddleToken[I].EditLine);
              end;
            end;

            if NewPair <> nil then
            begin
              if CanSolidCurrentLineBlock then // 高亮当前光标下的配对关键字块时，需要重画所影响的块
              for I := NewPair.Top to NewPair.Bottom do
                EditorMarkLineDirty(I)
              else
              begin
                EditorMarkLineDirty(NewPair.Top);
                EditorMarkLineDirty(NewPair.Bottom);
                for I := 0 to NewPair.MiddleCount - 1 do
                  EditorMarkLineDirty(NewPair.MiddleToken[I].EditLine);
              end;
            end;
          end;
        end;

        if (CompDirective <> nil) and (EditView <> nil) then
        begin
          OldPair := CompDirective.CurrentPair;
          CompDirective.FindCurrentPair(EditView); // 暂时不处理 C/C++ 的情况
          NewPair := CompDirective.CurrentPair;
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
  I: Integer;
  Info: TCnBlockMatchInfo;
begin
  FStructureTimer.Enabled := False;

  if FIsChecking then
    Exit;
  GlobalIgnoreClass := not FBlockMatchLineClass;
  GlobalIgnoreNamespace := not FBlockMatchLineNamespace;

  FIsChecking := True;
  try
    for I := 0 to FBlockMatchList.Count - 1 do
    begin
      Info := TCnBlockMatchInfo(FBlockMatchList[I]);

      // CheckBlockMatch 时会设置 FChanged
      if Info.FChanged then
      begin
        try
          Info.CheckBlockMatch(BlockHighlightRange);
        except
          ; // Hide an Unknown exception.
        end;
      end;
    end;
  finally
    FIsChecking := False;
  end;
end;

procedure TCnSourceHighlight.OnHighlightExec(Sender: TObject);
var
  I: Integer;
  Info: TCnBlockMatchInfo;
  Line: TCnBlockLineInfo;
  CompDirective: TCnCompDirectiveInfo;
begin
  if FIsChecking then
    Exit;
  FIsChecking := True;
  GlobalIgnoreClass := not FBlockMatchLineClass;
  GlobalIgnoreNamespace := not FBlockMatchLineNamespace;

  try
    begin
      for I := 0 to FBlockMatchList.Count - 1 do
      begin
        try
          Info := TCnBlockMatchInfo(FBlockMatchList[I]);
          if (FBlockMatchDrawLine or FBlockMatchHighlight) and (Info.LineInfo = nil) then
          begin
            // 如果画线结构高亮但之前无画线对象，则同时生成画线结构高亮的对象
            Line := TCnBlockLineInfo.Create(Info.Control);
            FBlockLineList.Add(Line);
            Info.LineInfo := Line;
          end;
          if FHighlightCompDirective and (Info.CompDirectiveInfo = nil) then
          begin
            // 如果画线结构高亮但之前无编译指令配对对象，则同时生成编译指令配对的对象
            CompDirective := TCnCompDirectiveInfo.Create(Info.Control);
            FCompDirectiveList.Add(CompDirective);
            Info.CompDirectiveInfo := CompDirective;
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
  if ALayer < 0 then
    ALayer := -1;
  Result := FHighLightColors[ ALayer mod 6 ];
   // HSLToRGB(ALayer / 7, 1, 0.5);
end;

procedure TCnSourceHighlight.PaintBlockMatchKeyword(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  R, R1: TRect;
  I, J, Layer: Integer;
  Info: TCnBlockMatchInfo;
  LineInfo: TCnBlockLineInfo;
  CompDirectiveInfo: TCnCompDirectiveInfo;
  Token: TCnGeneralPasToken;
  EditPos: TOTAEditPos;
  EditPosColBaseForAttribute: Integer;
  ColorFg, ColorBk: TColor;
  Element, LineFlag: Integer;
  KeyPair: TCnBlockLinePair;
  CompDirectivePair: TCnCompDirectivePair;
  SavePenColor, SaveBrushColor, SaveFontColor: TColor;
  SavePenStyle: TPenStyle;
  SaveBrushStyle: TBrushStyle;
  SaveFontStyles: TFontStyles;
  EditCanvas: TCanvas;
  TokenLen: Integer;
  CanDrawToken: Boolean;
  RectGot: Boolean;
  CanvasSaved: Boolean;
  CompDirectiveHighlightRef: TCnHighlightItem;
{$IFDEF BDS}
  WidePaintBuf: array[0..1] of WideChar;
  AnsiCharWidthLimit: Integer;

  function WideCharIsWideLengthOnCanvas(AChar: WideChar): Boolean;
  {$IFNDEF DELPHI110_ALEXANDRIA_UP}
  var
    CW: Integer;
  {$ENDIF}
  begin
    if (Ord(AChar) < $FF) then
      Result := False
    else if AnsiCharWidthLimit <= 2 then
      Result := IDEWideCharIsWideLength(AChar)
    else
    begin
  {$IFDEF DELPHI110_ALEXANDRIA_UP} // 高版本的绘制似乎改成固定宽度了
      Result := IDEWideCharIsWideLength(AChar);
  {$ELSE}
      CW := EditCanvas.TextWidth(AChar);
      Result := CW > AnsiCharWidthLimit; // 双字节字符绘制出的宽度大于 1.5 倍的窄字符宽度就认为宽
  {$ENDIF}
    end;
  end;
{$ENDIF}

  // 根据 Token 的 EditPos 的 Col（Ansi/Utf8/Ansi）返回给 GetAttributeAtPos 使用的 Col（Ansi/Utf8/Utf8）
  function CalcTokenEditColForAttribute(AToken: TCnGeneralPasToken): Integer;
  begin
    Result := Token.EditCol;
    // D567 与 D2005~2007 下分别是 Ansi/Utf8，符合 GetAttributeAtPos 的要求
{$IFDEF UNICODE}
    // D2009 或以上 GetAttributeAtPos 需要的是 UTF8 的Pos，因此进行 Col 的 UTF8 转换
    if FRawLineText <> '' then
      Result := ConvertAnsiPositionToUtf8OnUnicodeText(FRawLineText, Token.EditCol);
{$ENDIF}
  end;

begin
  with Editor do
  begin
    if IndexOfBlockMatch(EditControl) >= 0 then
    begin
      // 找到该 EditControl 对应的 BlockMatch 列表
      Info := TCnBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)]);

      CanvasSaved := False;
      SavePenColor := clNone;
      SavePenStyle := psSolid;
      SaveBrushColor := clNone;
      SaveBrushStyle := bsSolid;
      SaveFontColor := clNone;
      SaveFontStyles := [];
      EditCanvas := EditControlWrapper.GetEditControlCanvas(EditControl);

      if FHilightSeparateLine and (LogicLineNum <= Info.FSeparateLineList.Count - 1)
        and (Integer(Info.FSeparateLineList[LogicLineNum]) = CN_LINE_SEPARATE_FLAG)
        and (Trim(EditControlWrapper.GetTextAtLine(EditControl, LogicLineNum)) = '') then
      begin
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
        CanvasSaved := True;

        // 先画上分隔线再说
        EditPos := OTAEditPos(Editor.EditView.LeftColumn, LineNum);
        if EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} ' ', R) then
        begin
          EditCanvas.Pen.Color := FSeparateLineColor;
          EditCanvas.Pen.Width := FSeparateLineWidth;
          HighlightCanvasLine(EditCanvas, R.Left, (R.Top + R.Bottom) div 2,
            R.Left + 2048, (R.Top + R.Bottom) div 2, FSeparateLineStyle);
        end;
      end;

      if (Info.KeyCount > 0) or (Info.CurTokenCount > 0) or (Info.CompDirectiveTokenCount > 0)
        or (Info.FlowTokenCount > 0) or (Info.CustomIdentifierTokenCount > 0) then
      begin
        // 同时做关键字背景匹配高亮，可能由 MarkLinesDirty 调用
        KeyPair := nil;
        if FBlockMatchHighlight then
        begin
          if IndexOfBlockLine(EditControl) >= 0 then
          begin
            LineInfo := TCnBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)]);
            if (LineInfo <> nil) and (LineInfo.CurrentPair <> nil) and ((LineInfo.CurrentPair.Top = LogicLineNum)
              or (LineInfo.CurrentPair.Bottom = LogicLineNum)
              or (LineInfo.CurrentPair.IsInMiddle(LogicLineNum))) then
            begin
              // 寻找当前行已经配对的 Pair
              KeyPair := LineInfo.CurrentPair;
            end;
          end;
        end;

        CompDirectivePair := nil;
        if FHighlightCompDirective then
        begin
          if IndexOfCompDirectiveLine(EditControl) >= 0 then
          begin
            CompDirectiveInfo := TCnCompDirectiveInfo(FCompDirectiveList[IndexOfCompDirectiveLine(EditControl)]);
            if (CompDirectiveInfo <> nil) and (CompDirectiveInfo.CurrentPair <> nil) and ((CompDirectiveInfo.CurrentPair.Top = LogicLineNum)
              or (CompDirectiveInfo.CurrentPair.Bottom = LogicLineNum)
              or (CompDirectiveInfo.CurrentPair.IsInMiddle(LogicLineNum))) then
            begin
              // 寻找当前行已经配对的条件编译指令 Pair
              CompDirectivePair := TCnCompDirectivePair(CompDirectiveInfo.CurrentPair);
            end;
          end;
        end;

        if not CanvasSaved then
        begin
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
          CanvasSaved := True;
        end;

        // BlockMatch 里有多个 TCnGeneralPasToken
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
            Token := TCnGeneralPasToken(Info.Lines[LogicLineNum][I]);

            Layer := Token.ItemLayer - 1;
            if FStructureHighlight then
              ColorFg := GetColorFg(Layer)
            else
              ColorFg := FKeywordHighlight.ColorFg;

            ColorBk := clNone; // 只有当前 Token 在当前 KeyPair 内才高亮背景
            if KeyPair <> nil then
            begin
              if (KeyPair.StartToken = Token) or (KeyPair.EndToken = Token) or
                (KeyPair.IndexOfMiddleToken(Token) >= 0) then
                ColorBk := FBlockMatchBackground;
            end;

            if not FStructureHighlight and (ColorBk = clNone) then
              Continue; // 不层次高亮时，如无当前背景高亮，则不画

            EditCanvas.Font.Color := ColorFg;
            EditPosColBaseForAttribute := CalcTokenEditColForAttribute(Token);

            // 挨个字符重画以免影响选择效果，如果是高亮，ColorBk已设置好
            RectGot := False;
            for J := 0 to Length(Token.Token) - 1 do
            begin
              EditPos := OTAEditPos(GetTokenAnsiEditCol(Token) + J, LineNum);
              if not RectGot then
              begin
                if EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Token.Token[J]), R) then
                  RectGot := True
                else
                  Continue;
              end
              else // 关键字不包括双字节字符，因此此处无须根据宽字符选择步进宽度
              begin
                Inc(R.Left, CharSize.cx);
                Inc(R.Right, CharSize.cx);
              end;

              // 关键字不含双字节字符，因此可以直接用 EditPosColBase + J 的方式去获取 Attribute
              EditPos.Col := EditPosColBaseForAttribute + J;
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
        if FCurrentTokenHighlight and not FCurrentTokenInvalid and
          (LogicLineNum < Info.IdLineCount) and (Info.IdLines[LogicLineNum] <> nil) then
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
            Token := TCnGeneralPasToken(Info.IdLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(GetTokenAnsiEditCol(Token), LineNum);
            if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Token.Token), R) then
              Continue;

            // Token 初始 EditCol 在 Unicode 环境下是 Ansi，需要转换成 UTF8 供 GetAttributeAtPos 使用
            EditPos.Col := CalcTokenEditColForAttribute(Token);
            EditPos.Line := Token.EditLine;

            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier, atAssembler
                {$IFDEF IDE_STRING_ANSI_UTF8} , atIllegal {$ENDIF}]);
              // 2005~2007 下 Cpp 文件的 Unicode 标识符是 atIllegal，据说 Pascal 中不会出现

              if not CanDrawToken then // 如果中间有选择区，则不画
                Break;
{$IFDEF BDS}
              // 此处循环内 BDS 以上需要一个 UTF8 的位置转换。
              Inc(EditPos.Col, CalcUtf8LengthFromWideChar(Token.Token[J]));
{$ELSE}
              Inc(EditPos.Col);
{$ENDIF}
            end;

            if CanDrawToken then
            begin
              // 在位置上画背景高亮的标识符
              with EditCanvas do
              begin
                R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
{$IFDEF BDS}
                // BDS 下字符宽度是黑体的宽度，和 EditorGetTextRect 计算出来的不一致，
                // 得如此弥补一下。CharSize.cx 是黑体宽度
                if (R1.Right - R1.Left) < Length(Token.Token) * CharSize.cx then
                  R1.Right := R1.Left + Length(Token.Token) * CharSize.cx;
{$ENDIF}
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
{$IFDEF BDS}
                // BDS 下需要挨个绘制字符，因为 BDS 自身采用的是加粗的字符间距绘制
                EditPosColBaseForAttribute := CalcTokenEditColForAttribute(Token);
                EditPos.Col := EditPosColBaseForAttribute;
                EditPos.Line := Token.EditLine;
                WidePaintBuf[1] := #0;

                AnsiCharWidthLimit := TextWidth('a'); // 先准备一个窄字符的宽度的 1.5 倍备用
                AnsiCharWidthLimit := AnsiCharWidthLimit + AnsiCharWidthLimit shr 1;

                for J := 0 to Length(Token.Token) - 1 do
                begin
                  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                    Element, LineFlag);

                  // 2005~2007 下 Cpp 文件的 Unicode 标识符是 atIllegal，据说 Pascal 中不会出现
                  if (Element in [atIdentifier, atAssembler {$IFDEF IDE_STRING_ANSI_UTF8} , atIllegal {$ENDIF}]) and (LineFlag = 0) then
                  begin
                    // 在位置上画字，颜色已先设置好
                    {$IFDEF UNICODE}
                    TextOut(R.Left, R.Top, string(Token.Token[J]));
                    {$ELSE}
                    // D2005~2007 下使用 Unicode API 来直接绘制，以避免 Ansi 转换而乱码
                    WidePaintBuf[0] := Token.Token[J];
                    Windows.ExtTextOutW(Handle, R.Left, R.Top, TextFlags, nil, PWideChar(@(WidePaintBuf[0])), 1, nil);
                    {$ENDIF}
                  end;

                  // 标识符支持 Unicode，直接用 WideCharIsWideLength 的判断可能不准，需要画出宽度来衡量
                  if WideCharIsWideLengthOnCanvas(Token.Token[J]) then
                  begin
                    Inc(R.Left, CharSize.cx * SizeOf(WideChar));
                    Inc(R.Right, CharSize.cx * SizeOf(WideChar));
                  end
                  else
                  begin
                    Inc(R.Left, CharSize.cx);
                    Inc(R.Right, CharSize.cx);
                  end;

                  Inc(EditPos.Col);
                end;
{$ELSE}
                // 低版本可直接绘制
                TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
              end;
            end;
          end;
        end;

        // 如果有需要高亮绘制的流程控制标识符的内容
        if FHighlightFlowStatement and (LogicLineNum < Info.FlowLineCount) and
          (Info.FlowLines[LogicLineNum] <> nil) then
        begin
          for I := 0 to Info.FlowLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnGeneralPasToken(Info.FlowLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(GetTokenAnsiEditCol(Token), LineNum);
            if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Token.Token), R) then
              Continue;

            // Token 初始 EditCol 在 Unicode 环境下是 Ansi，需要转换成 UTF8 供 GetAttributeAtPos 使用
            EditPos.Col := CalcTokenEditColForAttribute(Token);
            EditPos.Line := Token.EditLine;

            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier, atReservedWord]);

              if not CanDrawToken then // 如果中间有选择区，则不画
                Break;
{$IFDEF BDS}
              // 此处循环内 BDS 以上需要一个 UTF8 的位置转换。
              Inc(EditPos.Col, CalcUtf8LengthFromWideChar(Token.Token[J]));
{$ELSE}
              Inc(EditPos.Col);
{$ENDIF}
            end;

            if CanDrawToken then
            begin
              // 在位置上画背景高亮的流程控制标识符
              with EditCanvas do
              begin
                R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
                if FFlowStatementBackground <> clNone then
                begin
                  Brush.Color := FFlowStatementBackground;
                  Brush.Style := bsSolid;
                  FillRect(R1);
                end;

                if Element = atIdentifier then
                begin
                  Font.Style := [];
                  Font.Color := FIdentifierHighlight.ColorFg;
                  if FIdentifierHighlight.Bold then
                    Font.Style := Font.Style + [fsBold];
                  if FIdentifierHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FIdentifierHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
                end
                else if Element = atReservedWord then
                begin
                  Font.Style := [];
                  Font.Color := FKeywordHighlight.ColorFg;
                  if FKeywordHighlight.Bold then
                    Font.Style := Font.Style + [fsBold];
                  if FKeywordHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FKeywordHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
                end;
                Font.Color := FFlowStatementForeground;
{$IFDEF BDS}
                // BDS 下需要挨个绘制字符，因为 BDS 自身采用的是加粗的字符间距绘制
                EditPosColBaseForAttribute := CalcTokenEditColForAttribute(Token);
                for J := 0 to Length(Token.Token) - 1 do
                begin
                  EditPos.Col := EditPosColBaseForAttribute + J;
                  EditPos.Line := Token.EditLine;
                  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                    Element, LineFlag);

                  if ((Element = atReservedWord) or (Element = atIdentifier)) and (LineFlag = 0) then
                  begin
                    // 在位置上画字，是否粗体已先设置好
                    TextOut(R.Left, R.Top, string(Token.Token[J]));
                  end;

                  if IDEWideCharIsWideLength(Token.Token[J]) then
                  begin
                    Inc(R.Left, CharSize.cx * SizeOf(WideChar));
                    Inc(R.Right, CharSize.cx * SizeOf(WideChar));
                  end
                  else
                  begin
                    Inc(R.Left, CharSize.cx);
                    Inc(R.Right, CharSize.cx);
                  end;
                end;
{$ELSE}
                // 低版本可直接绘制
                TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
              end;
            end;
          end;
        end;

        // 如果有需要高亮的条件编译指令
        if FHighlightCompDirective and (LogicLineNum < Info.CompDirectiveLineCount) and
          (Info.CompDirectiveLines[LogicLineNum] <> nil) and
          (FCompDirectiveBackground <> clNone) and (CompDirectivePair <> nil) then
        begin
          for I := 0 to Info.CompDirectiveLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnGeneralPasToken(Info.CompDirectiveLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            if (CompDirectivePair.StartToken = Token) or (CompDirectivePair.EndToken = Token) or
              (CompDirectivePair.IndexOfMiddleToken(Token) >= 0) then
            begin
              EditPos := OTAEditPos(GetTokenAnsiEditCol(Token), LineNum);
              if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Token.Token), R) then
                Continue;

              // Token 初始 EditCol 在 Unicode 环境下是 Ansi，需要转换成 UTF8 供 GetAttributeAtPos 使用
              EditPos.Col := CalcTokenEditColForAttribute(Token);
              EditPos.Line := Token.EditLine;

              CanDrawToken := True;
              for J := 0 to TokenLen - 1 do
              begin
                EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                  Element, LineFlag);
                CanDrawToken := (LineFlag = 0) and (Element in [atPreproc, atComment]);

                if not CanDrawToken then // 如果中间有选择区，则不画
                  Break;
{$IFDEF BDS}
                // 此处循环内 BDS 以上需要一个 UTF8 的位置转换。
                Inc(EditPos.Col, CalcUtf8LengthFromWideChar(Token.Token[J]));
{$ELSE}
                Inc(EditPos.Col);
{$ENDIF}
              end;

              if CanDrawToken then
              begin
                CompDirectiveHighlightRef := FCompDirectiveHighlight;
{$IFNDEF COMPILER7_UP}
  {$IFDEF DELPHI5OR6}
                if Info.IsCppSource then // D5/6 下的 C++ 文件编译指令换格式
                  CompDirectiveHighlightRef := FCompDirectiveOtherHighlight;
  {$ENDIF}

  {$IFDEF BCB5OR6}
                if not Info.IsCppSource then // BCB5/6 下的 Pascal 文件编译指令换格式
                  CompDirectiveHighlightRef := FCompDirectiveOtherHighlight;
  {$ENDIF}
{$ENDIF}
                // 在位置上根据条件画背景高亮的编译指令
                with EditCanvas do
                begin
                  R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
                  Brush.Color := FCompDirectiveBackground;
                  Brush.Style := bsSolid;
                  FillRect(R1);

                  Font.Style := [];
                  Font.Color := CompDirectiveHighlightRef.ColorFg;
                  if CompDirectiveHighlightRef.Bold then
                    Font.Style := Font.Style + [fsBold];
                  if CompDirectiveHighlightRef.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if CompDirectiveHighlightRef.Underline then
                    Font.Style := Font.Style + [fsUnderline];
{$IFDEF BDS}
                  // BDS 下需要挨个绘制字符，因为 BDS 自身采用的是加粗的字符间距绘制
                  Brush.Style := bsClear;
                  EditPosColBaseForAttribute := CalcTokenEditColForAttribute(Token);

                  for J := 0 to Length(Token.Token) - 1 do
                  begin
                    EditPos.Col := EditPosColBaseForAttribute + J;
                    EditPos.Line := Token.EditLine;
                    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                      Element, LineFlag);

                    if (Element in [atPreproc, atComment]) and (LineFlag = 0) then
                    begin
                      // 在位置上画字
                      TextOut(R.Left, R.Top, string(Token.Token[J]));
                    end;

                    if IDEWideCharIsWideLength(Token.Token[J]) then
                    begin
                      Inc(R.Left, CharSize.cx * SizeOf(WideChar));
                      Inc(R.Right, CharSize.cx * SizeOf(WideChar));
                    end
                    else
                    begin
                      Inc(R.Left, CharSize.cx);
                      Inc(R.Right, CharSize.cx);
                    end;
                  end;
{$ELSE}
                  // 低版本可直接绘制
                  TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
                end;
              end;
            end;
          end;
        end;

        // 如果有需要高亮绘制的自定义标识符的内容
        if FHighlightCustomIdentifier and (LogicLineNum < Info.CustomIdentifierLineCount) and
          (Info.CustomIdentifierLines[LogicLineNum] <> nil) then
        begin
          for I := 0 to Info.CustomIdentifierLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnGeneralPasToken(Info.CustomIdentifierLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(GetTokenAnsiEditCol(Token), LineNum);
            if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Token.Token), R) then
              Continue;

            // Token 初始 EditCol 在 Unicode 环境下是 Ansi，需要转换成 UTF8 供 GetAttributeAtPos 使用
            EditPos.Col := CalcTokenEditColForAttribute(Token);
            EditPos.Line := Token.EditLine;

            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier, atReservedWord]);

              if not CanDrawToken then // 如果中间有选择区，则不画
                Break;
{$IFDEF BDS}
              // 此处循环内 BDS 以上需要一个 UTF8 的位置转换。
              Inc(EditPos.Col, CalcUtf8LengthFromWideChar(Token.Token[J]));
{$ELSE}
              Inc(EditPos.Col);
{$ENDIF}
            end;

            if CanDrawToken then
            begin
              // 在位置上画背景高亮的自定义标识符
              with EditCanvas do
              begin
                R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
                if FCustomIdentifierBackground <> clNone then
                  Brush.Color := FCustomIdentifierBackground
                else
                  Brush.Color := EditControlWrapper.BackgroundColor; // 透明意味着使用编辑器原来的背景色

                Brush.Style := bsSolid;
                FillRect(R1);

                if Element = atIdentifier then
                begin
                  Font.Style := [];
                  Font.Color := FIdentifierHighlight.ColorFg;
                  if FIdentifierHighlight.Bold or (Token.Tag <> 0) then // 自定义的标识符如果设置了加粗则加粗
                    Font.Style := Font.Style + [fsBold];
                  if FIdentifierHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FIdentifierHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
                end
                else if Element = atReservedWord then
                begin
                  Font.Style := [];
                  Font.Color := FKeywordHighlight.ColorFg;
                  if FKeywordHighlight.Bold then                        // 关键字本身会加粗
                    Font.Style := Font.Style + [fsBold];
                  if FKeywordHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FKeywordHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
                end;
                Font.Color := FCustomIdentifierForeground;
{$IFDEF BDS}
                // BDS 下需要挨个绘制字符，因为 BDS 自身采用的是加粗的字符间距绘制
                EditPosColBaseForAttribute := CalcTokenEditColForAttribute(Token);
                for J := 0 to Length(Token.Token) - 1 do
                begin
                  EditPos.Col := EditPosColBaseForAttribute + J;
                  EditPos.Line := Token.EditLine;
                  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                    Element, LineFlag);

                  if ((Element = atReservedWord) or (Element = atIdentifier)) and (LineFlag = 0) then
                  begin
                    // 在位置上画字，是否粗体已先设置好
                    TextOut(R.Left, R.Top, string(Token.Token[J]));
                  end;

                  if IDEWideCharIsWideLength(Token.Token[J]) then
                  begin
                    Inc(R.Left, CharSize.cx * SizeOf(WideChar));
                    Inc(R.Right, CharSize.cx * SizeOf(WideChar));
                  end
                  else
                  begin
                    Inc(R.Left, CharSize.cx);
                    Inc(R.Right, CharSize.cx);
                  end;
                end;
{$ELSE}
                // 低版本可直接绘制
                TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
              end;
            end;
          end;
        end;
      end;

      if CanvasSaved then
      begin
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

procedure TCnSourceHighlight.PaintBlockMatchLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  LineInfo: TCnBlockLineInfo;
  Info: TCnBlockMatchInfo;
  I, J: Integer;
  R1, R2: TRect;
  Pair: TCnBlockLinePair;
  SavePenColor: TColor;
  SavePenWidth: Integer;
  SavePenStyle: TPenStyle;
  EditPos1, EditPos2: TOTAEditPos;
  EditorCanvas: TCanvas;
  LineFirstToken: TCnGeneralPasToken;
  EndLineStyle: TCnLineStyle;
  PairIsInKeyPair: Boolean;

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
      LineInfo := TCnBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)]);
      if IndexOfBlockMatch(EditControl) >= 0 then
        Info := TCnBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)])
      else
        Info := nil;

      if (LineInfo <> nil) and (LineInfo.Count > 0) then
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

            // 开始循环画当前行所涉及到的每个 Pair 在当前行里的线条
            for I := 0 to LineInfo.Lines[LogicLineNum].Count - 1 do
            begin
              // 一个 EditControl 的 LineInfo 中有多个配对画线的信息 LinePair
              Pair := TCnBlockLinePair(LineInfo.Lines[LogicLineNum][I]);
              EditorCanvas.Pen.Color := GetColorFg(Pair.Layer);

              // 判断当前要画的 Pair 是否受光标下的 KeyPair 影响，如果受影响，要改变画线风格
              PairIsInKeyPair := False;
              if (LineInfo.CurrentPair <> nil) and CanSolidCurrentLineBlock then
                PairIsInKeyPair := (Pair.Top >= LineInfo.CurrentPair.Top) and (Pair.Bottom <= LineInfo.CurrentPair.Bottom)
                  and (Pair.Left = LineInfo.CurrentPair.Left);

              if FBlockExtendLeft and (Info <> nil) and (LogicLineNum = Pair.Top)
                and (Pair.EndToken.EditLine > Pair.StartToken.EditLine) then
              begin
                // 处理前面还有 token 的情形，找 Start/End Token 所在行的第一个 Token
                if Info.Lines[LogicLineNum].Count > 0 then
                begin
                  LineFirstToken := TCnGeneralPasToken(Info.Lines[LogicLineNum][0]);
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
                    LineFirstToken := TCnGeneralPasToken(Info.Lines[Pair.EndToken.EditLine][0]);

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
                  else if PairIsInKeyPair then
                    EndLineStyle := lsSolid
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
                  else if PairIsInKeyPair then
                    EndLineStyle := lsSolid
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
                begin
                  if PairIsInKeyPair then // 光标下当前配对的，画实线
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Top, R1.Left,
                      R1.Bottom, lsSolid)
                  else
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Top, R1.Left,
                      R1.Bottom, FBlockMatchLineStyle);
                end;

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

    Idx := IndexOfCompDirectiveLine(EditControl);
    if Idx >= 0 then
    begin
      FCompDirectiveList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('CompDirectiveList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;
  end;
end;

procedure TCnSourceHighlight.SourceEditorNotify(SourceEditor: IOTASourceEditor;
  NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
begin
{$IFDEF UNICODE}
  if NotifyType = setClosing then
    FStructureTimer.OnTimer := nil
  else if (NotifyType = setOpened) or (NotifyType = setEditViewActivated) then
    FStructureTimer.OnTimer := OnHighlightTimer;
{$ENDIF}
end;

procedure TCnSourceHighlight.ActiveFormChanged(Sender: TObject);
begin
  if Active and (FStructureHighlight or FBlockMatchDrawLine or FHilightSeparateLine
    {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF} or FHighlightFlowStatement
    or FCurrentTokenHighlight or FHighlightCompDirective) and (BlockHighlightStyle <> bsHotkey)
    and IsIdeEditorForm(Screen.ActiveForm) then
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnHighlightExec);
end;

procedure TCnSourceHighlight.AfterCompile(Succeeded,
  IsCodeInsight: Boolean);
begin
  if Active and (not IsCodeInsight) and (FStructureHighlight or FBlockMatchDrawLine
    or FHilightSeparateLine {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF}
    or FHighlightFlowStatement or FCurrentTokenHighlight or FHighlightCompDirective)
    and (BlockHighlightStyle <> bsHotkey) and IsIdeEditorForm(Screen.ActiveForm) then
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnHighlightExec);
end;

{$IFDEF IDE_EDITOR_CUSTOM_COLUMN}

procedure TCnSourceHighlight.GutterChangeRepaint(Sender: TObject);
var
  Control: TControl;
begin
  Control := GetCurrentEditControl;
  if Control <> nil then
  begin
    try
      Control.Invalidate;
    except
      ;
    end;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('SourceHighlight GutterChangeRepaint');
{$ENDIF}
  end;
end;

{$ENDIF}

// EditorChange 时调用此事件去检查括号和结构高亮
procedure TCnSourceHighlight.EditorChanged(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
var
  EditorIndex: Integer;
begin
  if Active then
  begin
    if ctModified in ChangeType then
    begin
      FCurrentTokenValidateTimer.Enabled := False;
      FCurrentTokenValidateTimer.Enabled := True;
      FCurrentTokenInvalid := True;
    end;

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

    if (ctFont in ChangeType) or (ctOptionChanged in ChangeType)
     {$IFDEF IDE_EDITOR_CUSTOM_COLUMN} or (ctGutterWidthChanged in ChangeType) {$ENDIF}
     then
    begin
      if ctFont in ChangeType then
      begin
        ReloadIDEFonts;
{$IFNDEF BDS}
        if FHighLightLineColor = FDefaultHighLightLineColor then
          FHighLightLineColor := LoadIDEDefaultCurrentColor;
{$ENDIF}
      end;
{$IFDEF BDS}
      if ctOptionChanged in ChangeType then
      begin
        // 记录当前是否使用 Tab 键以及 TabWidth
        UpdateTabWidth;
      end;
{$ENDIF}

{$IFDEF IDE_EDITOR_CUSTOM_COLUMN}
      if ctGutterWidthChanged in ChangeType then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Source Highlight Get Gutter Width Changed');
{$ENDIF}
        CnWizNotifierServices.ExecuteOnApplicationIdle(GutterChangeRepaint);
      end;
{$ENDIF}
      // 都重绘
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
        or FHighlightFlowStatement or FHilightSeparateLine
        {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF} then
      begin
        UpdateHighlight(Editor, ChangeType);
      end;
    finally
      EndUpdateEditor(Editor);
    end;
  end;
end;

procedure TCnSourceHighlight.PaintLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer);
var
  AElided: Boolean;
begin
  if Active then
  begin
{$IFDEF BDS}
    // 预先获得当前行，供重画时重新进行 UTF8 位置计算
  {$IFDEF UNICODE}
    FRawLineText := EditControlWrapper.GetTextAtLine(Editor.EditControl,
      LogicLineNum);
  {$ELSE}
    FRawLineText := EditControlWrapper.GetTextAtLine(Editor.EditControl, LogicLineNum);
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
    if FStructureHighlight or FBlockMatchHighlight or FCurrentTokenHighlight
      or FHilightSeparateLine or FHighlightFlowStatement or FHighlightCompDirective
      or FHighlightCustomIdentifier then // 里头顺便做背景匹配高亮
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
    FMatchedBracket := ReadBool('', csMatchedBracket, True);
    FBracketColor := ReadColor('', csBracketColor, clBlack);
    FBracketColorBk := ReadColor('', csBracketColorBk, clAqua);
    FBracketColorBd := ReadColor('', csBracketColorBd, $CCCCD6);
    FBracketBold := ReadBool('', csBracketBold, False);
    FBracketMiddle := ReadBool('', csBracketMiddle, True);

    FStructureHighlight := ReadBool('', csStructureHighlight, True);
    FBlockMatchHighlight := ReadBool('', csBlockMatchHighlight, True);
    FBlockMatchBackground := ReadColor('', csBlockMatchBackground, clYellow);
    FCurrentTokenHighlight := ReadBool('', csCurrentTokenHighlight, True);
    FCurrentTokenForeground := ReadColor('', csCurrentTokenColor, csDefCurTokenColorFg);
    FCurrentTokenBackground := ReadColor('', csCurrentTokenColorBk, csDefCurTokenColorBg);
    FCurrentTokenBorderColor := ReadColor('', csCurrentTokenColorBd, csDefCurTokenColorBd);
    FShowTokenPosAtGutter := ReadBool('', csShowTokenPosAtGutter, False);

    FHilightSeparateLine := ReadBool('', csHilightSeparateLine, True);
    FSeparateLineColor := ReadColor('', csSeparateLineColor, clGray);
    FSeparateLineStyle := TCnLineStyle(ReadInteger('', csSeparateLineStyle, Ord(lsSmallDot)));
    FSeparateLineWidth := ReadInteger('', csSeparateLineWidth, 1);
{$IFNDEF BDS}
    FHighLightLineColor := ReadColor('', csHighLightLineColor, LoadIDEDefaultCurrentColor);
    FHighLightCurrentLine := ReadBool('', csHighLightCurrentLine, True);
{$ENDIF}
    FHighlightFlowStatement := ReadBool('', csHighlightFlowStatement, True);
    FFlowStatementBackground := ReadColor('', csFlowStatementBackground, csDefFlowControlBg);
    FFlowStatementForeground := ReadColor('', csFlowStatementForeground, clBlack);

    FHighlightCompDirective := ReadBool('', csHighlightCompDirective, True);
    FCompDirectiveBackground := ReadColor('', csCompDirectiveBackground, csDefaultHighlightBackgroundColor);

    FHighlightCustomIdentifier := ReadBool('', csHighlightCustomIdentifier, True);
    FCustomIdentifierBackground := ReadColor('', csCustomIdentifierBackground, csDefaultCustomIdentifierBackground);
    FCustomIdentifierForeground := ReadColor('', csCustomIdentifierForeground, csDefaultCustomIdentifierForeground);
    ReadStringsBoolean('', csCustomIdentifiers, FCustomIdentifiers);
{$IFDEF IDE_STRING_ANSI_UTF8}
    SyncCustomWide;
{$ENDIF}
    FBlockHighlightRange := TBlockHighlightRange(ReadInteger('', csBlockHighlightRange,
      Ord(brAll)));
    FBlockMatchDelay := ReadInteger('', csBlockMatchDelay, 600);
    FBlockMatchLineLimit := ReadBool('', csBlockMatchLineLimit, True);
    FBlockMatchMaxLines := ReadInteger('', csBlockMatchMaxLines, 60000);
    FBlockHighlightStyle := TBlockHighlightStyle(ReadInteger('', csBlockHighlightStyle,
      Ord(bsNow)));
    FBlockMatchDrawLine := ReadBool('', csBlockMatchDrawLine, True);
    FBlockMatchLineClass := ReadBool('', csBlockMatchLineClass, False);
    FBlockMatchLineNamespace := ReadBool('', csBlockMatchLineNamespace, True);
    FBlockMatchLineStyle := TCnLineStyle(ReadInteger('', csBlockMatchLineStyle,
      Ord(lsSolid)));
    FBlockMatchLineEnd := ReadBool('', csBlockMatchLineEnd, False);
    FBlockMatchLineWidth := ReadInteger('', csBlockMatchLineWidth, 1);
    FBlockMatchLineHori := ReadBool('', csBlockMatchLineHori, True);
    FBlockMatchLineHoriDot := ReadBool('', csBlockMatchLineHoriDot, True);
    FBlockMatchLineSolidCurrent := ReadBool('', csBlockMatchLineSolidCurrent, True);

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
    WriteBool('', csShowTokenPosAtGutter, FShowTokenPosAtGutter);

    WriteBool('', csHilightSeparateLine, FHilightSeparateLine);
    WriteColor('', csSeparateLineColor, FSeparateLineColor);
    WriteInteger('', csSeparateLineStyle, Ord(FSeparateLineStyle));
    WriteInteger('', csSeparateLineWidth, FSeparateLineWidth);
{$IFNDEF BDS}
    WriteBool('', csHighLightCurrentLine, FHighLightCurrentLine);
    if FDefaultHighLightLineColor <> FHighLightLineColor then
      WriteColor('', csHighLightLineColor, FHighLightLineColor);
{$ENDIF}
    WriteBool('', csHighlightFlowStatement, FHighlightFlowStatement);
    WriteColor('', csFlowStatementBackground, FFlowStatementBackground);
    WriteColor('', csFlowStatementForeground, FFlowStatementForeground);
    WriteBool('', csHighlightCompDirective, FHighlightCompDirective);
    WriteColor('', csCompDirectiveBackground, FCompDirectiveBackground);

    WriteBool('', csHighlightCustomIdentifier, FHighlightCustomIdentifier);
    WriteColor('', csCustomIdentifierBackground, FCustomIdentifierBackground);
    WriteColor('', csCustomIdentifierForeground, FCustomIdentifierForeground);
    WriteStringsBoolean('', csCustomIdentifiers, FCustomIdentifiers);

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
    WriteBool('', csBlockMatchLineNamespace, FBlockMatchLineNamespace);
    WriteBool('', csBlockMatchLineEnd, FBlockMatchLineEnd);
    WriteBool('', csBlockMatchLineHori, FBlockMatchLineHori);
    WriteBool('', csBlockMatchLineHoriDot, FBlockMatchLineHoriDot);
    WriteBool('', csBlockMatchLineSolidCurrent, FBlockMatchLineSolidCurrent);
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
  I: Integer;
  EditControl: TControl;
  Info: TCnBlockMatchInfo;
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
    // 检查编辑器，可能编辑器的 Info 未创建
    ReloadIDEFonts;
    for I := 0 to EditControlWrapper.EditorCount - 1 do
    begin
      EditControl := EditControlWrapper.Editors[I].EditControl;
      if IndexOfBlockMatch(EditControl) < 0 then
      begin
        Info := TCnBlockMatchInfo.Create(EditControl);
        FBlockMatchList.Add(Info);
      end;
    end;
    OnHighlightExec(nil);
  end;

  if not FShowTokenPosAtGutter then
    EventBus.PostEvent(EVENT_HIGHLIGHT_IDENT_POSITION);
end;

procedure TCnSourceHighlight.BeginUpdateEditor(Editor: TCnEditorObject);
begin
  if FDirtyList = nil then
    FDirtyList := TList.Create
  else
    FDirtyList.Clear;
end;

procedure TCnSourceHighlight.EndUpdateEditor(Editor: TCnEditorObject);
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
  AHighlight: TCnHighlightItem;
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

  if EditControlWrapper.IndexOfHighlight(csCompDirective) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csCompDirective)];
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Load IDE Font from Registry: ' + csCompDirective);
{$ENDIF}
    FCompDirectiveHighlight.ColorFg := AHighlight.ColorFg;
    FCompDirectiveHighlight.ColorBk := AHighlight.ColorBk;
    FCompDirectiveHighlight.Bold := AHighlight.Bold;
    FCompDirectiveHighlight.Italic := AHighlight.Italic;
    FCompDirectiveHighlight.Underline := AHighlight.Underline;
  end
  else // If no default settings saved in Registry, using default.
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('No IDE Font Found in Registry: ' + csCompDirective + '. Use Default.');
{$ENDIF}
{$IFDEF DELPHI5OR6}
    // Delphi 5/6 编译指令格式与注释一样
    FCompDirectiveHighlight.ColorFg := clNavy;
    FCompDirectiveHighlight.Italic := True;
{$ELSE}
    // D7 及以上及 C/C++ 代码的均是不斜的绿色
    FCompDirectiveHighlight.ColorFg := clGreen;
{$ENDIF}
  end;

{$IFNDEF COMPILER7_UP}
{$IFDEF DELPHI5OR6}
    // Delphi 5/6 下 C++ 的编译指令
    FCompDirectiveOtherHighlight.ColorFg := clGreen;
{$ELSE}
  {$IFDEF BCB5OR6}
    // BCB5/6 下的 Pascal 编译指令
    FCompDirectiveOtherHighlight.ColorFg := clNavy;
    FCompDirectiveOtherHighlight.Italic := True;
  {$ENDIF}
{$ENDIF}
{$ENDIF}
end;

procedure TCnSourceHighlight.RefreshCurrentTokens(Info: TCnBlockMatchInfo);
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

procedure TCnSourceHighlight.BeforePaintLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer);
var
  CurLine: TCnCurLineInfo;
  EditPos: TOTAEditPos;
  Element, LineFlag: Integer;
  StartRow, EndRow: Integer;
begin
  // 只有在调 PaintLine 前，才允许设置 CanDrawCurrentLine 为 True
  // PaintLine 结束后必须立刻将 CanDrawCurrentLine 设为 False
  // 避免 PaintLine 之外的地方调用 SetForeAndBackColor 导致额外副作用
  CanDrawCurrentLine := False;
  if IndexOfCurLine(Editor.EditControl) >= 0 then
    CurLine := TCnCurLineInfo(FCurLineList[IndexOfCurLine(Editor.EditControl)])
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
    if TCnCurLineInfo(FCurLineList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

{$ENDIF}

{$IFDEF IDE_STRING_ANSI_UTF8}

procedure TCnSourceHighlight.SyncCustomWide;
var
  I: Integer;
  S: WideString;
begin
  FCustomWideIdentfiers.Clear;
  for I := 0 to FCustomIdentifiers.Count - 1 do
  begin
    S := WideString(FCustomIdentifiers[I]);
    FCustomWideIdentfiers.AddObject(S, FCustomIdentifiers.Objects[I]);
  end;
end;

{$ENDIF}

{$IFDEF BDS}

procedure TCnSourceHighlight.UpdateTabWidth;
begin
  FUseTabKey := EditControlWrapper.GetUseTabKey;
  FTabWidth := EditControlWrapper.GetTabWidth;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('SourceHighlight: Editor Option Changed. Get UseTabKey is '
      + BoolToStr(FUseTabKey));
{$ENDIF}
end;

{$ENDIF}

function LoadIDEDefaultCurrentColor: TColor;
var
  AHighlight: TCnHighlightItem;
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

procedure TCnSourceHighlight.SetHilightSeparateLine(const Value: Boolean);
begin
  FHilightSeparateLine := Value;
end;

procedure TCnSourceHighlight.SetFlowStatementBackground(
  const Value: TColor);
begin
  FFlowStatementBackground := Value;
end;

procedure TCnSourceHighlight.SetHighlightFlowStatement(
  const Value: Boolean);
begin
  FHighlightFlowStatement := Value;
end;

procedure TCnSourceHighlight.SetFlowStatementForeground(
  const Value: TColor);
begin
  FFlowStatementForeground := Value;
end;


procedure TCnSourceHighlight.SetCompDirectiveBackground(
  const Value: TColor);
begin
  FCompDirectiveBackground := Value;
end;

procedure TCnSourceHighlight.SetHighlightCompDirective(
  const Value: Boolean);
begin
  FHighlightCompDirective := Value;
end;

procedure TCnSourceHighlight.EditorKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
begin
  if (Shift = []) and ((Key = VK_LEFT) or (Key = VK_UP) or
    (Key = VK_RIGHT) or (Key = VK_DOWN) or (Key = VK_PRIOR) or
    (Key = VK_NEXT))
  then
    Exit;

  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenValidateTimer.Enabled := True;
  FCurrentTokenInvalid := True;
end;

procedure TCnSourceHighlight.OnCurrentTokenValidateTimer(Sender: TObject);
var
  I: Integer;
  Info: TCnBlockMatchInfo;
begin
  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenInvalid := False;
  for I := 0 to FBlockMatchList.Count - 1 do
  begin
    Info := TCnBlockMatchInfo(FBlockMatchList[I]);
    if (Info <> nil) and (Info.Control <> nil) then
      Info.Control.Invalidate;
  end;
end;

procedure TCnSourceHighlight.SetBlockMatchLineNamespace(const Value: Boolean);
begin
  FBlockMatchLineNamespace := Value;
  GlobalIgnoreNamespace := not Value;
end;

function TCnSourceHighlight.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '括号,匹配,标识符,关键字,划线,画线,空行,分隔,结构,编译指令,行号,'
    + 'bracket,match,identifier,keyword,line,draw,structure,blank,compiler,directive,';
end;

{ TCnBlockLinePair }

procedure TCnBlockLinePair.AddMidToken(const Token: TCnGeneralPasToken;
  const LineLeft: Integer);
begin
  if Token <> nil then
  begin
    FMiddleTokens.Add(Token);
    if Left > LineLeft then
      Left := LineLeft;
  end;
end;

procedure TCnBlockLinePair.Clear;
begin
  FMiddleTokens.Clear;
  FStartToken := nil;
  FEndToken := nil;
  FStartLeft := 0;
  FEndLeft := 0;
  FTop := 0;
  FBottom := 0;
  FLeft := 0;
  FLayer := 0;
end;

constructor TCnBlockLinePair.Create;
begin
  FMiddleTokens := TList.Create;
end;

destructor TCnBlockLinePair.Destroy;
begin
  FMiddleTokens.Free;
  inherited;
end;

function TCnBlockLinePair.GetMiddleCount: Integer;
begin
  Result := FMiddleTokens.Count;
end;

function TCnBlockLinePair.GetMiddleToken(Index: Integer): TCnGeneralPasToken;
begin
  if (Index >= 0) and (Index < FMiddleTokens.Count) then
    Result := TCnGeneralPasToken(FMiddleTokens[Index])
  else
    Result := nil;
end;

function TCnBlockLinePair.IndexOfMiddleToken(
  const Token: TCnGeneralPasToken): Integer;
begin
  Result := FMiddleTokens.IndexOf(Token);
end;

function TCnBlockLinePair.IsInMiddle(const LineNum: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FMiddleTokens.Count - 1 do
  begin
    if (MiddleToken[I] <> nil) and (MiddleToken[I].EditLine = LineNum) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

{ TCnBlockLineInfo }

procedure TCnBlockLineInfo.AddPair(Pair: TCnBlockLinePair);
begin
  FPairList.Add(Pair);
end;

procedure TCnBlockLineInfo.Clear;
begin
  FCurrentPair := nil;
  FCurrentToken := nil;

  FPairList.Clear;
  FKeyLineList.Clear;
end;

constructor TCnBlockLineInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FPairList := TCnFastObjectList.Create;
  FKeyLineList := TCnFastObjectList.Create;
end;

destructor TCnBlockLineInfo.Destroy;
begin
  Clear;
  FPairList.Free;
  FKeyLineList.Free;
  inherited;
end;

procedure TCnBlockLineInfo.FindCurrentPair(View: IOTAEditView;
  IsCppModule: Boolean);
var
  I: Integer;
  Col: SmallInt;
  Line: TCnList;
  Pair: TCnBlockLinePair;
  Text: AnsiString;
  LineNo, CharIndex, Len: Integer;
  StartIndex, EndIndex: Integer;
  PairIndex: Integer;
{$IFDEF IDE_STRING_ANSI_UTF8}
  WideText: WideString;
{$ENDIF}

  // 判断标识符是否在光标下
  function InternalIsCurrentToken(Token: TCnGeneralPasToken): Boolean;
  var
    AnsiCol: Integer;
  begin
    AnsiCol := GetTokenAnsiEditCol(Token);
{
    Error: Delphi 5 Compiler Bug Occur. Result will be true even if Token.EditLine 25 and LineNo is 26
    ASM shows Token.EditLine = LineNo are ignored! So change a style.

    Result := (Token <> nil) and // (Token.IsBlockStart or Token.IsBlockClose) and
      (Token.EditLine = LineNo) and (AnsiCol <= EndIndex) and
      (AnsiCol >= StartIndex);
}

    Result := (Token.EditLine = LineNo) and (AnsiCol <= EndIndex) and
      (AnsiCol >= StartIndex);
  end;

  // 判断一个 Pair 是否有 Middle 的 Token 在光标下
  function IndexOfCurrentMiddleToken(Pair: TCnBlockLinePair): Integer;
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

{$IFDEF UNICODE}
  // Unicode 环境下转成替换过的字符串供搜索标识符用，不直接转 Ansi 以免无法处理宽字符的变宽度的情形
  Text := ConvertUtf16ToAlterDisplayAnsi(PWideChar(GetStrProp(FControl, 'LineText')), 'C');
{$ELSE}
  Text := GetStrProp(FControl, 'LineText');
{$ENDIF}

  Col := View.CursorPos.Col;

{$IFDEF IDE_STRING_ANSI_UTF8}
  // D2005~2007 与以下版本获得的是 UTF8 字符串与 Pos，都需要转换成 Ansi 的
  if (Text <> '') and (Col > 0) then
  begin
    WideText := Utf8Decode(Copy(Text, 1, Col - 1));
    Col := CalcAnsiDisplayLengthFromWideString(PWideChar(WideText)) + 1;

    WideText := Utf8Decode(Text);
    Text := ConvertUtf16ToAlterDisplayAnsi(PWideChar(WideText), 'C');
  end;
{$ENDIF}

  LineNo := View.CursorPos.Line;

  // 不知为何需如此处理但有效
  if IsCppModule then
    CharIndex := Min(Col, Length(Text))
  else
    CharIndex := Min(Col - 1, Length(Text));

  // 拿到当前行 AnsiString 内容（可能有替换字符但没有丢字符），
  // LineNo 和 CharIndex 是对应的 Ansi 偏移
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
      Pair := TCnBlockLinePair(Line[I]);
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

function TCnBlockLineInfo.GetCount: Integer;
begin
  Result := FPairList.Count;
end;

function TCnBlockLineInfo.GetLineCount: Integer;
begin
  Result := FKeyLineList.Count;
end;

function TCnBlockLineInfo.GetLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FKeyLineList[LineNum]);
end;

function TCnBlockLineInfo.GetPairs(Index: Integer): TCnBlockLinePair;
begin
  Result := TCnBlockLinePair(FPairList[Index]);
end;

procedure TCnBlockLineInfo.ConvertLineList;
var
  I, J: Integer;
  Pair: TCnBlockLinePair;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FPairList.Count - 1 do
  begin
    if Pairs[I].FBottom > MaxLine then
      MaxLine := Pairs[I].FBottom;
  end;
  FKeyLineList.Count := MaxLine + 1;

  for I := 0 to FPairList.Count - 1 do
  begin
    Pair := Pairs[I];
    for J := Pair.FTop to Pair.FBottom do
    begin
      if FKeyLineList[J] = nil then
        FKeyLineList[J] := TCnList.Create;
      TCnList(FKeyLineList[J]).Add(Pair);
    end;
  end;
end;

{ TCnCurLineInfo }

constructor TCnCurLineInfo.Create(AControl: TControl);
begin
  FControl := AControl;
end;

destructor TCnCurLineInfo.Destroy;
begin
  inherited;

end;

{ TCnCompDirectiveInfo }

procedure TCnCompDirectiveInfo.FindCurrentPair(View: IOTAEditView;
  IsCppModule: Boolean);
var
  I: Integer;
  Col: SmallInt;
  Line: TCnList;
  Pair: TCnBlockLinePair;
  Text: AnsiString;
  LineNo, CharIndex: Integer;
  PairIndex: Integer;
{$IFDEF IDE_STRING_ANSI_UTF8}
  WideText: WideString;
{$ENDIF}

  function _GeneralStrLen(const Text: PCnIdeTokenChar): Integer; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  begin
{$IFDEF IDE_STRING_ANSI_UTF8}
    Result := lstrlenW(Text);
{$ELSE}
    Result := StrLen(Text);
{$ENDIF}
  end;

  // 判断标识符两端是否在光标两端，和 BlockInfo 的搜索规则不同
  function InternalIsCurrentToken(Token: TCnGeneralPasToken): Boolean;
  var
    AnsiCol: Integer;
  begin
    AnsiCol := GetTokenAnsiEditCol(Token);
    Result := (Token.EditLine = LineNo) and (AnsiCol <= CharIndex + 1) and
      ((AnsiCol + Integer(_GeneralStrLen(Token.Token)) >= CharIndex + 1));
  end;

  // 判断一个 Pair 是否有 Middle 的 Token 在光标下
  function IndexOfCurrentMiddleToken(Pair: TCnBlockLinePair): Integer;
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

{$IFDEF UNICODE}
  // Unicode 环境下转成替换过的字符串供搜索标识符用，不直接转 Ansi 以免无法处理宽字符的变宽度的情形
  Text := ConvertUtf16ToAlterDisplayAnsi(PWideChar(GetStrProp(FControl, 'LineText')), 'C');
{$ELSE}
  Text := AnsiString(GetStrProp(FControl, 'LineText'));
{$ENDIF}

  Col := View.CursorPos.Col;

{$IFDEF IDE_STRING_ANSI_UTF8}
  // D2005~2007 与以下版本获得的是 UTF8 字符串与 Pos，都需要转换成 Ansi 的
  if (Text <> '') and (Col > 0) then
  begin
    WideText := Utf8Decode(Copy(Text, 1, Col - 1));
    Col := CalcAnsiDisplayLengthFromWideString(PWideChar(WideText)) + 1;

    WideText := Utf8Decode(Text);
    Text := ConvertUtf16ToAlterDisplayAnsi(PWideChar(WideText), 'C');
  end;
{$ENDIF}

  LineNo := View.CursorPos.Line;

  // 不知为何需如此处理但有效
  if IsCppModule then
    CharIndex := Min(Col, Length(Text))
  else
    CharIndex := Min(Col - 1, Length(Text));

  // 拿到当前行 AnsiString 内容（可能有替换字符但没有丢字符），
  // LineNo 和 CharIndex 是对应的 Ansi 偏移
  if (LineNo < LineCount) and (Lines[LineNo] <> nil) then
  begin
    Line := Lines[LineNo];
    for I := 0 to Line.Count - 1 do
    begin
      Pair := TCnBlockLinePair(Line[I]);
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

function TCnSourceHighlight.CanSolidCurrentLineBlock: Boolean;
begin
  Result := FBlockMatchLineSolidCurrent and (FBlockMatchLineStyle <> lsSolid); // 其他画线风格时，允许当前块画线用实线
end;

procedure TCnBlockMatchInfo.AddToCustomIdentifierList(AToken: TCnGeneralPasToken);
begin
  FCustomIdentifierTokenList.Add(AToken);
end;

procedure TCnBlockMatchInfo.ConvertCustomIdentifierLineList;
var
  I: Integer;
  Token: TCnGeneralPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FCustomIdentifierTokenList.Count - 1 do
    if CustomIdentifierTokens[I].EditLine > MaxLine then
      MaxLine := CustomIdentifierTokens[I].EditLine;
  FCustomIdentifierLineList.Count := MaxLine + 1;

  if FHighlight.HighlightCustomIdentifier then
  begin
    for I := 0 to FCustomIdentifierTokenList.Count - 1 do
    begin
      Token := CustomIdentifierTokens[I];
      if FCustomIdentifierLineList[Token.EditLine] = nil then
        FCustomIdentifierLineList[Token.EditLine] := TCnList.Create;
      TCnList(FCustomIdentifierLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

function TCnBlockMatchInfo.GetCustomIdentifierTokenCount: Integer;
begin
  Result := FCustomIdentifierTokenList.Count;
end;

function TCnBlockMatchInfo.GetCustomIdentifierLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FCustomIdentifierLineList[LineNum]);
end;

function TCnBlockMatchInfo.GetCustomIdentifierTokens(Index: Integer): TCnGeneralPasToken;
begin
  Result := TCnGeneralPasToken(FCustomIdentifierTokenList[Index]);
end;

procedure TCnBlockMatchInfo.UpdateCustomIdentifierList;
var
  EditView: IOTAEditView;
  Bold: Boolean;
  I: Integer;
begin
  FCurMethodStartToken := nil;
  FCurMethodCloseToken := nil;

  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView Error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  FCustomIdentifierTokenList.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
      // 搜索当前所有标识符，不受高亮范围控制
      for I := 0 to PasParser.Count - 1 do
        ConvertGeneralTokenPos(Pointer(EditView), PasParser.Tokens[I]);

      for I := 0 to PasParser.Count - 1 do
      begin
        Bold := False;
        if CheckIsCustomIdentifier(PasParser.Tokens[I], FIsCppSource, Bold) then
        begin
          FCustomIdentifierTokenList.Add(PasParser.Tokens[I]);
          if Bold then
            PasParser.Tokens[I].Tag := 1  // 如果设置要求加粗，用 Tag 存储加粗标志
          else
            PasParser.Tokens[I].Tag := 0;
        end;
      end;
    end;

    FCustomIdentifierLineList.Clear;
    ConvertCustomIdentifierLineList;
  end
  else // 做 C/C++ 中的当前解析，将所需高亮的自定义标识符解析出来
  begin
    for I := 0 to CppParser.Count - 1 do
      ConvertGeneralTokenPos(Pointer(EditView), CppParser.Tokens[I]);

    for I := 0 to CppParser.Count - 1 do
    begin
      if CheckIsCustomIdentifier(CppParser.Tokens[I], FIsCppSource, Bold) then
      begin
        FCustomIdentifierTokenList.Add(CppParser.Tokens[I]);
        if Bold then
          CppParser.Tokens[I].Tag := 1
        else
          CppParser.Tokens[I].Tag := 0;
      end;
    end;

    FCustomIdentifierLineList.Clear;
    ConvertCustomIdentifierLineList;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FCustomIdentifierTokenList.Count: %d', [FCustomIdentifierTokenList.Count]);
{$ENDIF}

  for I := 0 to FCustomIdentifierTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnGeneralPasToken(FCustomIdentifierTokenList[I]).EditLine);
end;

function TCnBlockMatchInfo.GetCustomIdentifierLineCount: Integer;
begin
  Result := FCustomIdentifierLineList.Count;
end;

procedure TCnSourceHighlight.SetCustomIdentifierBackground(const Value: TColor);
begin
  FCustomIdentifierBackground := Value;
end;

procedure TCnSourceHighlight.SetCustomIdentifierForeground(const Value: TColor);
begin
  FCustomIdentifierForeground := Value;
end;

function TCnBlockMatchInfo.CheckIsCustomIdentifier(AToken: TCnGeneralPasToken;
  IsCpp: Boolean; out Bold: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AToken = nil then
    Exit;
{$IFDEF IDE_STRING_ANSI_UTF8}
  // BDS 2005 2006 2007 下使用宽字符串列表进行比对
  if IsCpp then // 区分大小写
  begin
    for I := 0 to FHighlight.FCustomWideIdentfiers.Count - 1 do
    begin
      if EqualIdeToken(AToken.Token, @((FHighlight.FCustomWideIdentfiers[I])[1]), True) then
      begin
        Bold := FHighlight.FCustomWideIdentfiers.Objects[I] <> nil;
        Result := True;
        Exit;
      end;
    end;
  end
  else // 不区分大小写
  begin
    for I := 0 to FHighlight.FCustomWideIdentfiers.Count - 1 do
    begin
      if EqualIdeToken(AToken.Token,@((FHighlight.FCustomWideIdentfiers[I])[1])) then
      begin
        Bold := FHighlight.FCustomWideIdentfiers.Objects[I] <> nil;
        Result := True;
        Exit;
      end;
    end;
  end;
{$ELSE}
  if IsCpp then // 区分大小写
  begin
    for I := 0 to FHighlight.FCustomIdentifiers.Count - 1 do
    begin
      if EqualIdeToken(AToken.Token, @((FHighlight.FCustomIdentifiers[I])[1]), True) then
      begin
        Bold := FHighlight.FCustomIdentifiers.Objects[I] <> nil;
        Result := True;
        Exit;
      end;
    end;
  end
  else // 不区分大小写
  begin
    for I := 0 to FHighlight.FCustomIdentifiers.Count - 1 do
    begin
      if EqualIdeToken(AToken.Token,@((FHighlight.FCustomIdentifiers[I])[1])) then
      begin
        Bold := FHighlight.FCustomIdentifiers.Objects[I] <> nil;
        Result := True;
        Exit;
      end;
    end;
  end;
{$ENDIF}
end;

initialization
  RegisterCnWizard(TCnSourceHighlight);
  PairPool := TCnList.Create;

finalization
  ClearPairPool;
  FreeAndNil(PairPool);

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}
end.

