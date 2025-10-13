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

unit CnPasCodeParser;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Pas 源代码分析器
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：解析器解析过程中会从 Token 池里拿 PasToken 对象，释放时将它们返回到池中
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2022.02.06 V1.3
*               重构部分函数并增加对仅解析字符串 Token 的方法
*           2019.03.16 V1.2
*               优化对换行后的点号的支持以及点号后输入的内容恰好是关键字时的支持
*           2012.02.07
*               UTF8 的位置转换去除后仍有问题，恢复之
*           2011.11.29
*               XE/XE2 的位置解析无需 UTF8 的位置转换
*           2011.11.03
*               优化对带点的引用单元名的支持
*           2011.05.29
*               修正 BDS 下对汉字 UTF8 未处理而导致解析出错的问题
*           2004.11.07
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, mPasLex, mwBCBTokenList, Contnrs,
  CnCommon, {$IFDEF IDE_WIDECONTROL} CnWideStrings, {$ENDIF} CnFastList, CnContainers;

const
  CN_TOKEN_MAX_SIZE = 63;

type
  TCnCompDirectiveType = (ctNone, ctIf, ctIfOpt, ctIfDef, ctIfNDef, ctElse, ctEndIf,
    ctIfEnd, ctRegion, ctEndRegion);

  TCnUseToken = class(TObject)
  {* 描述一 uses 结构信息}
  private
    FIsImpl: Boolean;
    FTokenPos: Integer;
    FToken: string;
    FTokenID: TTokenKind;
  public
    property Token: string read FToken write FToken;
    property IsImpl: Boolean read FIsImpl write FIsImpl;
    property TokenPos: Integer read FTokenPos write FTokenPos;
    property TokenID: TTokenKind read FTokenID write FTokenID;
  end;

  TCnPasToken = class(TPersistent)
  {* 描述一 Token 的结构高亮信息}
  private
    FTag: Integer;
    FBracketLayer: Integer;
    FTokenLength: Integer;
    function GetToken: PAnsiChar;
    function GetEditEndCol: Integer;
  protected
    FCppTokenKind: TCTokenKind;
    FCompDirectiveType: TCnCompDirectiveType;
    FCharIndex: Integer;
    FEditCol: Integer;
    FEditLine: Integer;
    FItemIndex: Integer;
    FItemLayer: Integer;
    FLineNumber: Integer;
    FMethodLayer: Integer;
    FToken: array[0..CN_TOKEN_MAX_SIZE] of AnsiChar;
    FTokenID: TTokenKind;
    FTokenPos: Integer;
    FIsMethodStart: Boolean;
    FIsMethodClose: Boolean;
    FMethodStartAfterParentBegin: Boolean;
    FIsBlockStart: Boolean;
    FIsBlockClose: Boolean;
    FUseAsC: Boolean;
  public
    procedure Clear; virtual;

    property UseAsC: Boolean read FUseAsC;
    {* 是否是 C 方式的解析，默认不是}
    property LineNumber: Integer read FLineNumber; // Start 0
    {* 所在行号，从零开始，由 ParseSource 计算而来}
    property CharIndex: Integer read FCharIndex;   // Start 0
    {* 从本行开始数的字符位置，从零开始，由 ParseSource 计算而来}

    property EditCol: Integer read FEditCol write FEditCol;
    {* Token 起始位置所在列，从一开始，由外界转换而来，一般对应 EditPos}
    property EditLine: Integer read FEditLine write FEditLine;
    {* 所在行，从一开始，由外界转换而来，一般对应 EditPos}
    property EditEndCol: Integer read GetEditEndCol;
    {* Token 结束位置所在列，EditCol 转换成功后才有意义}

    property ItemIndex: Integer read FItemIndex;
    {* 在整个 Parser 中的序号}
    property ItemLayer: Integer read FItemLayer;
    {* 所在高亮的层次，包括过程、函数以及代码块，可直接用来绘制高亮层次，不在任何块内时（最外层）为 0}
    property MethodLayer: Integer read FMethodLayer;
    {* 所在函数的层次，最外层的函数内为 1，包括匿名函数，不在任何函数内时（最外层）为 0}
    property BracketLayer: Integer read FBracketLayer;
    {* 所在的圆括号的层次，最外层的为 0。圆括号本身应该算高一层（暂未实现）}
    property Token: PAnsiChar read GetToken;
    {* 该 Token 的字符串内容 }
    property TokenLength: Integer read FTokenLength write FTokenLength;
    {* 该 Token 的实际字符长度，注意它可能大于 Token 数组的内容长度}
    property TokenID: TTokenKind read FTokenID;
    {* Token 的语法类型}
    property CppTokenKind: TCTokenKind read FCppTokenKind;
    {* 作为 C 的 Token 使用时的 CToken 类型}
    property TokenPos: Integer read FTokenPos;
    {* Token 在整个文件中的线性位置}
    property IsBlockStart: Boolean read FIsBlockStart;
    {* 是否是一块可匹配代码区域的开始}
    property IsBlockClose: Boolean read FIsBlockClose;
    {* 是否是一块可匹配代码区域的结束}
    property IsMethodStart: Boolean read FIsMethodStart;
    {* 是否是函数过程的开始，包括 function/procedure 和 begin/asm 的情况}
    property IsMethodClose: Boolean read FIsMethodClose;
    {* 是否是函数过程的结束，只包括 end 的情况，因此和 MethodStart 数量不等}
    property MethodStartAfterParentBegin: Boolean read FMethodStartAfterParentBegin;
    {* 当 IsMethodStart 是 True 且是 function/procedure 或 begin/asm 时，
       是否位于上一层 function/procedure 的 begin 后的实现部分。
       无上一层，或在上一层的 begin 之前时为 False，表示是定义，
       而不是语句部分中的匿名函数。所以此属性为 True 可以代表是匿名函数。}
    property CompDirectiveType: TCnCompDirectiveType read FCompDirectiveType write FCompDirectiveType;
    {* 当其类型是 Pascal 编译指令时，此域代表其详细类型，但不解析，由外部按需解析}
    property Tag: Integer read FTag write FTag;
    {* Tag 标记，供外界特殊场合使用}
  end;

//==============================================================================
// Pascal 文件结构高亮解析器
//==============================================================================

  { TCnPasStructureParser }

  TCnPasStructureParser = class(TObject)
  {* 利用 Lex 进行语法解析得到各个 Token 和位置信息}
  private
    FSupportUnicodeIdent: Boolean;
    FBlockCloseToken: TCnPasToken;
    FBlockStartToken: TCnPasToken;
    FChildMethodCloseToken: TCnPasToken;
    FChildMethodStartToken: TCnPasToken;
    FCurrentChildMethod: AnsiString;
    FCurrentMethod: AnsiString;
    FKeyOnly: Boolean;
    FList: TCnList;
    FMethodCloseToken: TCnPasToken;
    FMethodStartToken: TCnPasToken;
    FSource: AnsiString;
    FInnerBlockCloseToken: TCnPasToken;
    FInnerBlockStartToken: TCnPasToken;
    FUseTabKey: Boolean;
    FTabWidth: Integer;
    FMethodStack: TCnObjectStack;
    FBlockStack: TCnObjectStack;
    FMidBlockStack: TCnObjectStack;
    FProcStack: TCnObjectStack;
    FIfStack: TCnObjectStack;
    function GetCount: Integer;
    function GetToken(Index: Integer): TCnPasToken; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  protected
    function CalcCharIndex(Lex: TmwPasLex; Source: PAnsiChar): Integer;
    function NewToken(Lex: TmwPasLex; Source: PAnsiChar; CurrBlock: TCnPasToken = nil;
      CurrMethod: TCnPasToken = nil; CurrBracketLevel: Integer = 0): TCnPasToken;
  public
    constructor Create(SupportUnicodeIdent: Boolean = False);
    destructor Destroy; override;
    procedure Clear;

    procedure ParseSource(ASource: PAnsiChar; AIsDpr, AKeyOnly: Boolean);
    {* 对代码进行常规解析，AKeyOnly 为 True 表示只生成关键字内容，否则还加上标识符及运算符、括号等内容}

    function FindCurrentDeclaration(LineNumber, CharIndex: Integer;
      out Visibility: TTokenKind): AnsiString;
    {* 查找指定光标位置所在的声明，LineNumber 1 开始，CharIndex 0 开始，类似于 CharPos
       要求是 Ansi 的偏移量。D567 下可以用 ConvertPos 得到的 CharPos 传入
       Visibility 参数返回为光标所在是 private/protected/public/published 还是 none}
    function FindCurrentBlock(LineNumber, CharIndex: Integer): TTokenKind;
    {* 根据当前光标位置查找当前块与当前嵌套/外层函数等，被 FindCurrentDeclaration 调用。
       LineNumber 1 开始，CharIndex 0 开始，类似于 CharPos
       要求是 Ansi 的偏移量。D567 下可以用 ConvertPos 得到的 CharPos 传入
       返回值为当前光标上部最近的是 private/protected/public/published 还是 none}

    procedure ParseString(ASource: PAnsiChar);
    {* 对代码进行针对字符串的解析，只生成字符串内容}

    function IndexOfToken(Token: TCnPasToken): Integer;
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TCnPasToken read GetToken;
    property MethodStartToken: TCnPasToken read FMethodStartToken;
    {* 当前最外层的过程或函数}
    property MethodCloseToken: TCnPasToken read FMethodCloseToken;
    {* 当前最外层的过程或函数}
    property ChildMethodStartToken: TCnPasToken read FChildMethodStartToken;
    {* 当前最内层的过程或函数，用于有嵌套过程或函数定义的情况}
    property ChildMethodCloseToken: TCnPasToken read FChildMethodCloseToken;
    {* 当前最内层的过程或函数，用于有嵌套过程或函数定义的情况}
    property BlockStartToken: TCnPasToken read FBlockStartToken;
    {* 当前最外层块}
    property BlockCloseToken: TCnPasToken read FBlockCloseToken;
    {* 当前最外层块}
    property InnerBlockStartToken: TCnPasToken read FInnerBlockStartToken;
    {* 当前最内层块}
    property InnerBlockCloseToken: TCnPasToken read FInnerBlockCloseToken;
    {* 当前最内层块}
    property CurrentMethod: AnsiString read FCurrentMethod;
    {* 当前最外层的过程或函数名}
    property CurrentChildMethod: AnsiString read FCurrentChildMethod;
    {* 当前最内层的过程或函数名，用于有嵌套过程或函数定义的情况}
    property Source: AnsiString read FSource;
    property KeyOnly: Boolean read FKeyOnly;
    {* 是否只处理出关键字}

    property UseTabKey: Boolean read FUseTabKey write FUseTabKey;
    {* 是否排版处理 Tab 键的宽度，如不处理，则将 Tab 键当作宽为 1 处理。
      注意不能把 IDE 编辑器设置里的 "Use Tab Character" 的值赋值过来。
      IDE 设置只控制代码中是否在按 Tab 时出现 Tab 字符还是用空格补全。}
    property TabWidth: Integer read FTabWidth write FTabWidth;
    {* Tab 键的宽度}
  end;

//==============================================================================
// 源码位置信息分析
//==============================================================================

  // 源代码区域类型
  TCodeAreaKind = (
    akUnknown,         // 未知无效区
    akHead,            // 单元声明之前
    akUnit,            // 单元声明区
    akProgram,         // 程序或库声明区
    akInterface,       // interface 区
    akIntfUses,        // interface 的 uses 区
    akImplementation,  // implementation 区
    akImplUses,        // implementation 的 uses 区
    akInitialization,  // initialization 区
    akFinalization,    // finalization 区
    akEnd);            // end. 之后的区域

  TCodeAreaKinds = set of TCodeAreaKind;

  // 源代码位置类型，同时支持 Pascal 和 C/C++
  TCodePosKind = (
    pkUnknown,         // 未知无效区，Pascal 和 C/C++ 都有效
    pkFlat,            // 单元空白区
    pkComment,         // 注释块内部，Pascal 和 C/C++ 都有效
    pkIntfUses,        // Pascal interface 的 uses 内部
    pkImplUses,        // Pascal implementation 的 uses 内部
    pkClass,           // Pascal class 声明内部，也包括 record 内部
    pkInterface,       // Pascal interface 声明内部
    pkType,            // Pascal type 定义区等号前的部分
    pkTypeDecl,        // Pascal type 定义区等号后的部分
    pkConst,           // Pascal const 定义区，冒号或 = 前的部分
    pkConstTypeValue,  // Pascal const 定义区，冒号或 = 后的部分
    pkResourceString,  // Pascal resourcestring 定义区
    pkVar,             // Pascal var 定义区，冒号前的部分
    pkVarType,         // Pascal var 定义区，冒号后的部分
    pkCompDirect,      // 编译指令内部 {$...}，C/C++ 则是指 #include 等内部
    pkString,          // 字符串内部，Pascal 和 C/C++ 都有效
    pkField,           // 标识符. 后面的域内部，属性、方法、事件、记录项等，Pascal 和 C/C++ 都有效
    pkProcedure,       // 过程内部
    pkFunction,        // 函数内部
    pkConstructor,     // 构造器内部
    pkDestructor,      // 析构器内部
    pkFieldDot,        // 连接域的点，包括 C/C++ 的 ->

    pkDeclaration);    // C中的变量声明区，指类型之后的变量名部分，一般无需弹出

  TCodePosKinds = set of TCodePosKind;

  // 当前代码位置信息，同时支持 Pascal 和 C/C++
  PCodePosInfo = ^TCodePosInfo;
  TCodePosInfo = record
    IsPascal: Boolean;         // 是否是 Pascal 文件
    LastIdentPos: Integer;     // 上一处标识符位置
    LastNoSpace: TTokenKind;   // 上一处非空记号类型
    LastNoSpacePos: Integer;   // 上一次非空记号的线性位置，0 开始，暂时没派上用场
    LineNumber: Integer;       // 行号，0 开始，暂时没派上用场
    LinePos: Integer;          // 所在行的行首的线性位置，0 开始，暂时没派上用场
    TokenPos: Integer;         // 当前记号的线性位置，0 开始，暂时没派上用场
    Token: AnsiString;         // 当前记号内容
    TokenID: TTokenKind;       // 当前 Pascal 记号类型
    CTokenID: TCTokenKind;     // 当前 C 记号类型
    AreaKind: TCodeAreaKind;   // 当前区域类型
    PosKind: TCodePosKind;     // 当前位置类型
  end;

const
  // 所有的位置集合
  csAllPosKinds = [Low(TCodePosKind)..High(TCodePosKind)];
  // 非代码区域位置集合
  csNonCodePosKinds = [pkUnknown, pkComment, pkIntfUses, pkImplUses,
    pkCompDirect, pkString];
  // 对象域位置集合
  csFieldPosKinds = [pkField, pkFieldDot];
  // 常规代码区域
  csNormalPosKinds = csAllPosKinds - csNonCodePosKinds - csFieldPosKinds;

procedure ParsePasCodePosInfo(const Source: AnsiString; CurrPos: Integer;
  var PosInfo: TCodePosInfo; FullSource: Boolean = True; SourceIsUtf8: Boolean = False);
{* 分析源代码中当前位置的信息，如果 SourceIsUtf8 为 True，内部会转为 Ansi
  CurrPos 应当是文件的线性位置（Ansi/Utf8/Utf8）
  但如果 Unicode 环境下取到的线性位置当有宽字符时有偏差的话此函数便不适用，
  需要使用 ParsePasCodePosInfoW
  另外注意 D567/BCB56 下 SourceIsUtf8 参数不起作用}

procedure ParseUnitUses(const Source: AnsiString; UsesList: TStrings);
{* 分析源代码中引用的单元，将已引用单元放入 UsesList，Source 是文件的 Ansi 内容。
  目前 Unicode 环境大部分情况下也是用的该方法，只有 Ansi 出问题时才需要换}

implementation

type
  TCnProcObj = class
  {* 描述一个完整的 procedure/function 定义，包括匿名函数}
  private
    FToken: TCnPasToken;
    FBeginToken: TCnPasToken;
    FNestCount: Integer;
    function GetIsNested: Boolean;
    function GetBeginMatched: Boolean;
    function GetLayer: Integer;
  public
    property Token: TCnPasToken read FToken write FToken;
    {* procedure/function 所在的 Token}
    property Layer: Integer read GetLayer;
    {* procedure/function 所在的 Token 的层次数}
    property BeginMatched: Boolean read GetBeginMatched;
    {* 该 procedure/function 是否已与找到了实现体的 begin}
    property BeginToken: TCnPasToken read FBeginToken write FBeginToken;
    {* 该 procedure/function 实现体的 begin}
    property IsNested: Boolean read GetIsNested;
    {* 该 procedure/function 是否是被嵌套定义的，也即是否在外一层
       procedure/function 的声明部分（实现体 begin 之前}
    property NestCount: Integer read FNestCount write FNestCount;
    {* 该 procedure/function 的嵌套定义层数，也即离最近一个非嵌套 procedure/function 的层距离}
  end;

  TCnIfStatement = class
  {* 描述一个完整的 If 语句，可能带多个 else if 以及一个或 0 个 else，各块内还可能有 begin end}
  private
    FLevel: Integer;
    FIfStart: TCnPasToken;         // 存储主 if 引用
    FIfBegin: TCnPasToken;         // 存储 if 对应的同级 begin
    FIfEnded: Boolean;             // 该 if 主块是否结束（不是整个 if 语句）
    FElseToken: TCnPasToken;       // 存储 else 引用
    FElseBegin: TCnPasToken;       // 存储 else 对应的同级 begin
    FElseEnded: Boolean;           // 该 else 块是否结束
    FElseList: TObjectList;        // 存储多个 else if 中的 else 引用
    FIfList: TObjectList;          // 存储多个 else if 中的 if 引用
    FElseIfBeginList: TObjectList; // 存储多个 else if 的对应 begin，可能为空
    FElseIfEnded: TList;           // 存储多个 else if 是否结束的标记，1 或 0
    FIfAllEnded: Boolean;          // 整个 if 是否结束
    function GetElseIfCount: Integer;
    function GetElseIfElse(Index: Integer): TCnPasToken;
    function GetElseIfIf(Index: Integer): TCnPasToken;
    function GetLastElseIfElse: TCnPasToken;
    function GetLastElseIfIf: TCnPasToken;
    procedure SetIfStart(const Value: TCnPasToken);
    function GetLastElseIfBegin: TCnPasToken;
    procedure SetFIfBegin(const Value: TCnPasToken);
    procedure SetElseBegin(const Value: TCnPasToken);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function HasElse: Boolean;
    {* 该 if 块是否有单独的 else}

    procedure ChangeElseToElseIf(AIf: TCnPasToken);
    {* 将最后一个 else 改为一个 else if，用于 else 后接受到 if 时}
    procedure AddBegin(ABegin: TCnPasToken);
    {* 外界判断后，将 begin 挂入此 If，根据实际情况挂 else if 下或 if 头下}

    // 以下三个结束当前子块的条件是：
    // 1. 该子块有紧接的 begin，且有对应层次的 end，或者
    // 2. 该子块无紧接的 begin，有同层次的分号（层次判断不易，改用当前块的前后判断规则），或
    // 3. 该子块无紧接的 begin，但有上一层次的 end（前面无分号）；如 if then begin if then Close end; 中的 Close 语句
    procedure EndLastElseIfBlock;
    {* 令最后一个 else if 块结束，来源是 end 或分号}
    procedure EndElseBlock;
    {* 令 else 块结束，来源是 end 或分号}
    procedure EndIfBlock;
    {* 令 if 块结束（不是整个 if 语句），来源是 end 或分号}
    procedure EndIfAll;
    {* 令整个 if 语句结束，来源是 end 或分号}

    property Level: Integer read FLevel write FLevel;
    {* if 语句的层次，主要是 if 的层次}
    property IfStart: TCnPasToken read FIfStart write SetIfStart;
    {* 获取 if 起始 Token 以及将一个 Token 设为 if 起始 Token}
    property IfBegin: TCnPasToken read FIfBegin write SetFIfBegin;
    {* 获取 if 自身对应的 begin 的 Token 以及将一个 begin 设为 if 对应的 begin}
    property ElseToken: TCnPasToken read FElseToken write FElseToken;
    {* 获取 if 里的 else 的 Token 以及将一个 Token 设为 if 里的 else 的 Token}
    property ElseBegin: TCnPasToken read FElseBegin write SetElseBegin;
    {* 获取 if 里的 else 所对应的 begin 以及将一个 Token 设为此 else 对应的 begin 的 Token}
    property ElseIfCount: Integer read GetElseIfCount;
    {* 返回该 if 块的 else if 数量}
    property ElseIfElse[Index: Integer]: TCnPasToken read GetElseIfElse;
    {* 返回该 if 块的 else if 的 else 的 Token，索引从 0 到 ElseIfCount - 1}
    property ElseIfIf[Index: Integer]: TCnPasToken read GetElseIfIf;
    {* 返回该 if 块的 else if 的  的 Token，索引从 0 到 ElseIfCount - 1}
    property LastElseIfElse: TCnPasToken read GetLastElseIfElse;
    {* 返回该 if 块的最后一个 else if 的 else}
    property LastElseIfIf: TCnPasToken read GetLastElseIfIf;
    {* 返回该 if 块的最后一个 else if 的 if}
    property LastElseIfBegin: TCnPasToken read GetLastElseIfBegin;
    {* 返回该 if 块的最后一个 else if 的 begin，如果有的话}
    property IfAllEnded: Boolean read FIfAllEnded;
    {* 返回该 if 语句是否全部结束，供判断并从堆栈中弹出}
  end;

var
  TokenPool: TCnList = nil;

// 用池方式来管理 PasTokens 以提高性能
function CreatePasToken: TCnPasToken;
begin
  if TokenPool.Count > 0 then
  begin
    Result := TCnPasToken(TokenPool.Last);
    TokenPool.Delete(TokenPool.Count - 1);
  end
  else
    Result := TCnPasToken.Create;
end;

procedure FreePasToken(Token: TCnPasToken);
begin
  if Token <> nil then
  begin
    Token.Clear;
    TokenPool.Add(Token);
  end;
end;

procedure ClearTokenPool;
var
  I: Integer;
begin
  for I := 0 to TokenPool.Count - 1 do
    TObject(TokenPool[I]).Free;
end;

// NextNoJunk 仅仅只跳过注释，而没跳过编译指令的情况。加此函数可过编译指令
procedure LexNextNoJunkWithoutCompDirect(Lex: TmwPasLex);
begin
  repeat
    Lex.Next;
  until not (Lex.TokenID in [tkSlashesComment, tkAnsiComment, tkBorComment, tkCRLF,
    tkCRLFCo, tkSpace, tkCompDirect]);
end;

//==============================================================================
// 结构高亮解析器
//==============================================================================

{ TCnPasStructureParser }

constructor TCnPasStructureParser.Create(SupportUnicodeIdent: Boolean);
begin
  FList := TCnList.Create;
  FTabWidth := 2;
  FSupportUnicodeIdent := SupportUnicodeIdent;

  FMethodStack := TCnObjectStack.Create;
  FBlockStack := TCnObjectStack.Create;
  FMidBlockStack := TCnObjectStack.Create;
  FProcStack := TCnObjectStack.Create;
  FIfStack := TCnObjectStack.Create;
end;

destructor TCnPasStructureParser.Destroy;
begin
  Clear;
  FMethodStack.Free;
  FBlockStack.Free;
  FMidBlockStack.Free;
  FProcStack.Free;
  FIfStack.Free;
  FList.Free;
  inherited;
end;

procedure TCnPasStructureParser.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FreePasToken(TCnPasToken(FList[I]));
  FList.Clear;

  FMethodStartToken := nil;
  FMethodCloseToken := nil;
  FChildMethodStartToken := nil;
  FChildMethodCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';
  FSource := '';
end;

function TCnPasStructureParser.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnPasStructureParser.GetToken(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FList[Index]);
end;

function TCnPasStructureParser.CalcCharIndex(Lex: TmwPasLex; Source: PAnsiChar): Integer;
{$IFDEF BDS2009_UP}
var
  I, Len: Integer;
{$ENDIF}
begin
{$IFDEF BDS2009_UP}
  if FUseTabKey and (FTabWidth >= 2) then
  begin
    // 遍历当前行内容进行 Tab 键展开
    I := Lex.LinePos;
    Len := 0;
    while ( I < Lex.TokenPos ) do
    begin
      if (Source[I] = #09) then
        Len := ((Len div FTabWidth) + 1) * FTabWidth
      else
        Inc(Len);
      Inc(I);
    end;
    Result := Len;
  end
  else
{$ENDIF}
    Result := Lex.TokenPos - Lex.LinePos;
end;

function TCnPasStructureParser.NewToken(Lex: TmwPasLex; Source: PAnsiChar;
  CurrBlock, CurrMethod: TCnPasToken; CurrBracketLevel: Integer): TCnPasToken;
var
  Len: Integer;
begin
  Result := CreatePasToken;
  Result.FTokenPos := Lex.TokenPos;

  Len := Lex.TokenLength;
  Result.FTokenLength := Len;
  if Len > CN_TOKEN_MAX_SIZE then
    Len := CN_TOKEN_MAX_SIZE;

  Move(Lex.TokenAddr^, Result.FToken[0], Len);
  Result.FToken[Len] := #0;

  Result.FLineNumber := Lex.LineNumber;
  Result.FCharIndex := CalcCharIndex(Lex, Source);
  Result.FTokenID := Lex.TokenID;
  Result.FItemIndex := FList.Count;
  Result.Tag := 0;
  if CurrBlock <> nil then
    Result.FItemLayer := CurrBlock.FItemLayer;

  // CurrBlock 的 ItemLayer 包含了 MethodLayer，但如果没有 CurrBlock，
  // 就得考虑用 CurrMethod 的 MethodLayer 来初始化 Token 的 ItemLayer。
  if CurrMethod <> nil then
  begin
    Result.FMethodLayer := CurrMethod.FMethodLayer;
    if CurrBlock = nil then
      Result.FItemLayer := CurrMethod.FMethodLayer;
  end;
  Result.FBracketLayer := CurrBracketLevel;
  FList.Add(Result);
end;

procedure TCnPasStructureParser.ParseSource(ASource: PAnsiChar; AIsDpr, AKeyOnly:
  Boolean);
var
  Lex: TmwPasLex;
  Token, CurrMethod, CurrBlock, CurrMidBlock, CurrIfStart: TCnPasToken;
  Bookmark: TmwPasLexBookmark;
  IsClassOpen, IsClassDef, IsImpl, IsHelper, IsElseIf, ExpectElse: Boolean;
  IsRecordHelper, IsSealed, IsAbstract, IsRecord, IsObjectRecord, IsForFunc: Boolean;
  SameBlockMethod, CanEndBlock, CanEndMethod: Boolean;
  DeclareWithEndLevel, CurrBracketLevel: Integer;
  PrevTokenID: TTokenKind;
  PrevTokenStr: AnsiString;
  AProcObj, PrevProcObj: TCnProcObj;
  AIfObj: TCnIfStatement;

  procedure DiscardToken(Forced: Boolean = False);
  begin
    if (AKeyOnly or Forced) and (FList.Count > 0) then
    begin
      FreePasToken(FList[FList.Count - 1]);
      FList.Delete(FList.Count - 1);
    end;
  end;

  procedure ClearStackAndFreeObject(AStack: TCnObjectStack);
  begin
    if AStack = nil then
      Exit;

    while AStack.Count > 0 do
      AStack.Pop.Free;
  end;

begin
  Clear;
  Lex := nil;
  PrevTokenID := tkProgram;

  try
    FSource := ASource;
    FKeyOnly := AKeyOnly;

    FMethodStack.Clear;
    FBlockStack.Clear;
    FMidBlockStack.Clear;
    FProcStack.Clear;  // 存储 procedure/function 实现的关键字以及其嵌套层次
    FIfStack.Clear;    // 存储 if 的嵌套信息

    Lex := TmwPasLex.Create(FSupportUnicodeIdent);
    Lex.Origin := PAnsiChar(ASource);

    DeclareWithEndLevel := 0; // 嵌套的需要 end 的定义层数
    CurrMethod := nil;        // 当前 Token 所在的方法 procedure/function，包括匿名函数的情形
    CurrBlock := nil;         // 当前 Token 所在的块。
    CurrMidBlock := nil;
    CurrBracketLevel := 0;
    IsImpl := AIsDpr;
    IsHelper := False;
    IsRecordHelper := False;
    ExpectElse := False;

    while Lex.TokenID <> tkNull do
    begin
      // 根据上一轮的结束条件判断是否能结束整个 if 语句，注意编译指令不能算
      if ExpectElse and not (Lex.TokenID in [tkElse, tkCompDirect]) and not FIfStack.IsEmpty then
        FIfStack.Pop.Free;
      ExpectElse := False;

      if (Lex.TokenID in [tkCompDirect]) // Allow CompDirect
        or ((not (PrevTokenID in [tkAmpersand, tkAddressOp])) and (Lex.TokenID in
        [tkProcedure, tkFunction, tkConstructor, tkDestructor, tkOperator,
        tkInitialization, tkFinalization,
        tkBegin, tkAsm, tkVar, tkConst,
        tkCase, tkTry, tkRepeat, tkIf, tkFor, tkWith, tkOn, tkWhile,
        tkRecord, tkObject, tkOf, tkEqual,
        tkClass, tkInterface, tkDispinterface,
        tkExcept, tkFinally, tkElse,
        tkPrivate, tkProtected, tkPublic, tkPublished,
        tkEnd, tkUntil, tkThen, tkDo])) then
      begin
        Token := NewToken(Lex, ASource, CurrBlock, CurrMethod, CurrBracketLevel);
        case Lex.TokenID of
          tkProcedure, tkFunction, tkConstructor, tkDestructor, tkOperator:
            begin
              // 不处理 procedure/function 类型定义，前面是 = 号
              // 也不处理 procedure/function 变量声明，前面是 : 号
              // 也不处理匿名方法声明，前面是 to
              // 但一定要处理匿名方法实现！前面是 := 赋值或 ( , 做参数，但可能不完全
              if IsImpl and ((not (Lex.TokenID in [tkProcedure, tkFunction]))
                or (not (PrevTokenID in [tkEqual, tkColon, tkTo{, tkAssign, tkRoundOpen, tkComma}])))
                and (DeclareWithEndLevel <= 0) then
              begin
                // DeclareWithEndLevel <= 0 表示只处理 class/record 外的声明，内部不管
                if CurrBlock = nil then
                  Token.FItemLayer := 0
                else
                  Token.FItemLayer := CurrBlock.ItemLayer;
                Token.FIsMethodStart := True;

                if CurrMethod <> nil then
                begin
                  Token.FMethodLayer := CurrMethod.FMethodLayer + 1;
                  FMethodStack.Push(CurrMethod);
                end
                else
                  Token.FMethodLayer := 1;
                CurrMethod := Token;

                // 碰到 procedure/function 实现时，推入堆栈并记录其层次，暂无 Layer 可记录。
                if FProcStack.IsEmpty then
                  PrevProcObj := nil
                else
                  PrevProcObj := TCnProcObj(FProcStack.Peek);

                AProcObj := TCnProcObj.Create;
                AProcObj.Token := Token;
                FProcStack.Push(AProcObj);

                // 如果当前 procedure 在外面的 procedure 的 begin 后，则算匿名函数，不加嵌套数
                // 如果外面没有 procedure，则更不算嵌套，默认是 0
                if PrevProcObj <> nil then
                begin
                  if PrevProcObj.BeginMatched then
                    Token.FMethodStartAfterParentBegin := True
                  else
                    AProcObj.NestCount := PrevProcObj.NestCount + 1;
                end;
              end;
            end;
          tkInitialization, tkFinalization:
            begin
              while FBlockStack.Count > 0 do
                FBlockStack.Pop;
              CurrBlock := nil;
              while FMethodStack.Count > 0 do
                FMethodStack.Pop;
              CurrMethod := nil;
            end;
          tkBegin, tkAsm:
            begin
              Token.FIsBlockStart := True;
              // 匿名函数会导致 CurrBlock 与 CurrMethod 都存在且内外关系不确定，
              // 因此如 CurrBlock 存在，需要确定其远于 CurrMethod，这个 begin 才是 MethodStart。
              if (CurrMethod <> nil) and ((CurrBlock = nil) or
                (CurrBlock.ItemIndex < CurrMethod.ItemIndex)) then
                Token.FIsMethodStart := True;

              // 而且得 CurrBlock 比 CurrMethod 近，才能根据 CurrBlock 进一
              // 否则要根据下面的 Method 来进一
              if (CurrBlock <> nil) and ((CurrMethod = nil) or (CurrMethod.ItemIndex < CurrBlock.ItemIndex)) then
                Token.FItemLayer := CurrBlock.FItemLayer + 1
              else if CurrMethod <> nil then // 无 Block 或 Block 在 Method 外，是匿名函数，先进一层
                Token.FItemLayer := CurrMethod.FItemLayer + 1
              else // 下面会根据是否在函数过程内来进层
                Token.FItemLayer := 0;

              FBlockStack.Push(CurrBlock);
              CurrBlock := Token; // begin/asm 既可以是 CurrBlock，也可以是 CurrMethod 的对应 begin/asm

              // 处理本 begin/asm 和 procedure/function 同级时的进层
              if FProcStack.Count > 0 then
              begin
                AProcObj := TCnProcObj(FProcStack.Peek);
                if (AProcObj.Token <> nil) and Token.FIsMethodStart then
                begin
                  // 如果本 Proc 是匿名（出现在外层的 begin 后），则 begin 也要记录
                  Token.FMethodStartAfterParentBegin := AProcObj.Token.FMethodStartAfterParentBegin;
                end;

                if not AProcObj.BeginMatched then
                begin
                  // 当前 Proc 是嵌套函数时，begin 要进 procedure/function 的直接嵌套层数
                  if AProcObj.IsNested then
                    Inc(Token.FItemLayer, AProcObj.NestCount);

                  // 记录配套的 begin/asm 及其层次
                  AProcObj.BeginToken := Token;
                end;
              end;

              // 判断 begin 是否属于之前的 if 或 else if
              if (Lex.TokenID = tkBegin) and (PrevTokenID in [tkThen, tkElse]) and not FIfStack.IsEmpty then
              begin
                AIfObj := TCnIfStatement(FIfStack.Peek);
                if AIfObj.Level = Token.ItemLayer then
                  AIfObj.AddBegin(Token);
              end;
            end;
          tkCase:
            begin
              if (CurrBlock = nil) or (CurrBlock.TokenID <> tkRecord) then
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  FBlockStack.Push(CurrBlock);
                end
                else
                  Token.FItemLayer := 0;

                CurrBlock := Token;
              end
              else
                DiscardToken(True);
            end;
          tkTry, tkRepeat, tkIf, tkFor, tkWith, tkOn, tkWhile,
          tkRecord, tkObject:
            begin
              IsRecord := Lex.TokenID = tkRecord;
              IsObjectRecord := Lex.TokenID = tkObject;
              IsForFunc := (PrevTokenID in [tkPoint]) or
                ((PrevTokenID = tkSymbol) and (PrevTokenStr = '&'));
              if IsRecord then
              begin
                // 处理 record helper for 的情形，但在 implementation 部分其 end 会被
                // record 内部的 function/procedure 给干掉，暂无解决方案。
                Lex.SaveToBookmark(Bookmark);

                LexNextNoJunkWithoutCompDirect(Lex);
                IsRecordHelper := Lex.TokenID = tkHelper;

                Lex.LoadFromBookmark(Bookmark);
              end;

              // of object 的 object 不应该高亮，但不在此处剔除

              // 不处理 of object 的字样；不处理前面是 @@ 型的label的情形
              // 额外用 IsRecord 变量因为 Lex.RunPos 恢复后，TokenID 可能会变
              if ((Lex.TokenID <> tkObject) or (PrevTokenID <> tkOf))
                and not (PrevTokenID in [tkAt, tkDoubleAddressOp])
                and not IsForFunc        // 不处理 TParalle.For 以及 .&For 这种函数
                and not ((Lex.TokenID = tkFor) and (IsHelper or IsRecordHelper)) then
                // 不处理 helper 中的 for
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  FBlockStack.Push(CurrBlock);
                  if (CurrBlock.TokenID = tkTry) and (Token.TokenID = tkTry)
                    and (CurrMidBlock <> nil) then
                  begin
                    FMidBlockStack.Push(CurrMidBlock);
                    CurrMidBlock := nil;
                  end;
                end
                else
                  Token.FItemLayer := 0;

                CurrBlock := Token;

                if IsRecord or IsObjectRecord then
                begin
                  // 独立记录 record，因为 record 可以在函数体的 begin end 之外配 end
                  // IsInDeclareWithEnd := True;
                  Inc(DeclareWithEndLevel);
                end;
              end;

              if Lex.TokenID = tkFor then
              begin
                if IsHelper then
                  IsHelper := False;
                if IsRecordHelper then
                  IsRecordHelper := False;
              end;

              // 处理 if 或 else if 的情形
              if Lex.TokenID = tkIf then
              begin
                IsElseIf := False;
                if PrevTokenID = tkElse then
                begin
                  // 是 else if，找到最近的 AIfObj，把 else 改成 else if
                  if not FIfStack.IsEmpty then
                  begin
                    AIfObj := TCnIfStatement(FIfStack.Peek);
                    // 这个 if 和所在 if 块必须同级，以预防类似于 case else if then end 的情况
                    if AIfObj.Level = Token.ItemLayer then
                    begin
                      AIfObj.ChangeElseToElseIf(Token);
                      IsElseIf := True;
                    end;
                  end;
                end;

                if not IsElseIf then // 是单纯的 if，记录 if 块与其起始位置并推入堆栈
                begin
                  AIfObj := TCnIfStatement.Create;
                  AIfObj.IfStart := Token;
                  FIfStack.Push(AIfObj);
                end;
              end;
            end;
          tkClass, tkInterface, tkDispInterface:
            begin
              IsHelper := False;
              IsSealed := False;
              IsAbstract := False;
              IsClassDef := ((Lex.TokenID = tkClass) and Lex.IsClass)
                or ((Lex.TokenID = tkInterface) and Lex.IsInterface) or
                (Lex.TokenID = tkDispInterface);

              // 处理不是 classdef 但是 class helper for TObject 的情形
              if not IsClassDef and (Lex.TokenID = tkClass) and not Lex.IsClass then
              begin
                Lex.SaveToBookmark(Bookmark);

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID in [tkHelper, tkSealed, tkAbstract] then
                begin
                  IsClassDef := True;
                  IsHelper := Lex.TokenID = tkHelper;
                  IsSealed := Lex.TokenID = tkSealed;
                  IsAbstract := Lex.TokenID = tkAbstract;
                end;

                Lex.LoadFromBookmark(Bookmark);
              end;

              IsClassOpen := False;
              if IsClassDef then
              begin
                IsClassOpen := True;
                Lex.SaveToBookmark(Bookmark);

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID = tkSemiColon then // 是个 class; 不需要 end;
                  IsClassOpen := False
                else if IsHelper or IsSealed or IsAbstract then
                  LexNextNoJunkWithoutCompDirect(Lex);

                if Lex.TokenID = tkRoundOpen then // 有括号，看是不是();
                begin
                  while not (Lex.TokenID in [tkNull, tkRoundClose]) do
                    LexNextNoJunkWithoutCompDirect(Lex);
                  if Lex.TokenID = tkRoundClose then
                    LexNextNoJunkWithoutCompDirect(Lex);
                end;

                if Lex.TokenID = tkSemiColon then
                  IsClassOpen := False
                else if Lex.TokenID = tkFor then
                  IsClassOpen := True;

                Lex.LoadFromBookmark(Bookmark);
              end;

              if IsClassOpen then // 有后续内容，需要一个 end
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  FBlockStack.Push(CurrBlock);
                end
                else
                  Token.FItemLayer := 0;

                CurrBlock := Token;
                // 局部声明，需要 end 来结尾
                // IsInDeclareWithEnd := True;
                Inc(DeclareWithEndLevel);
              end
              else // 硬修补，免得 unit 的 interface 以及 class procedure 等被高亮
                DiscardToken(Token.TokenID in [tkClass, tkInterface, tkDispinterface]);
            end;
          tkExcept, tkFinally:
            begin
              if (CurrBlock = nil) or (CurrBlock.TokenID <> tkTry) then
                DiscardToken
              else if CurrMidBlock = nil then
              begin
                CurrMidBlock := Token;
              end
              else
                DiscardToken;
            end;
          tkPrivate, tkProtected, tkPublic, tkPublished:
            begin
              if (CurrBlock = nil) or not (CurrBlock.TokenID in [tkClass, tkRecord, tkInterface, tkDispinterface]) then
                DiscardToken
              else if CurrMidBlock = nil then
              begin
                CurrMidBlock := Token;
              end
              else
                DiscardToken;
            end;
          tkElse:
            begin
              // 判断 else 是属于较近的 if 块还是较外层的 case 等块是个难题。
              // 遇到 else 时 if then 块已经结束，CurrBlock不会等于 if，所以得额外整一个 CurrIfStart
              CurrIfStart := nil;
              if not FIfStack.IsEmpty then
              begin
                AIfObj := TCnIfStatement(FIfStack.Peek);
                if AIfObj.IfStart <> nil then
                  CurrIfStart := AIfObj.IfStart;
              end;

              // else 前面可以不是分号，无须判断 PrevToken 是否分号
              if (CurrBlock = nil) or (PrevTokenID in [tkAt, tkDoubleAddressOp]) then
                DiscardToken
              else if (CurrBlock.TokenID = tkTry) and (CurrMidBlock <> nil) and
                (CurrMidBlock.TokenID = tkExcept) and
                ((CurrIfStart = nil) or (CurrIfStart.ItemIndex <= CurrBlock.ItemIndex)) then
                Token.FItemLayer := CurrBlock.FItemLayer    // try except else end 比最近的 if 块近，是一块的
              else if (CurrBlock.TokenID = tkCase) and
                ((CurrIfStart = nil) or (CurrIfStart.ItemIndex <= CurrBlock.ItemIndex))then
                Token.FItemLayer := CurrBlock.FItemLayer    // case of 中的 else 比最近的 if 块近，是一块的
              else if not FIfStack.IsEmpty then // 以上情况均不对，则 else 应该属于当前 if 块
              begin
                AIfObj := TCnIfStatement(FIfStack.Peek);
                Token.FItemLayer := AIfObj.Level;
                if not AIfObj.HasElse then
                  AIfObj.ElseToken := Token;
              end;
            end;
          tkEnd, tkUntil, tkThen, tkDo:
            begin
              if (CurrBlock <> nil) and not (PrevTokenID in [tkPoint, tkAt, tkDoubleAddressOp]) then
              begin
                if ((Lex.TokenID = tkUntil) and (CurrBlock.TokenID <> tkRepeat))
                  or ((Lex.TokenID = tkThen) and (CurrBlock.TokenID <> tkIf))
                  or ((Lex.TokenID = tkDo) and not (CurrBlock.TokenID in
                  [tkOn, tkWhile, tkWith, tkFor])) then
                begin
                  DiscardToken;
                end
                else
                begin
                  // 避免部分关键字做变量名的情形，但只是一个小 patch，处理并不完善
                  Token.FItemLayer := CurrBlock.FItemLayer;
                  Token.FIsBlockClose := True;
                  if (CurrBlock.TokenID = tkTry) and (CurrMidBlock <> nil) then
                  begin
                    if FMidBlockStack.Count > 0 then
                      CurrMidBlock := TCnPasToken(FMidBlockStack.Pop)
                    else
                      CurrMidBlock := nil;
                  end;

                  // End 既可以结束 Block 也可以结束 procedure，没有必然的先后顺序，要看哪个近
                  // 而且，倘若 CurrBlock 是 CurrMethod 的 begin/asm，则 End 要同时结束俩
                  CanEndBlock := False;
                  CanEndMethod := False;
                  if (CurrBlock = nil) and (CurrMethod = nil) then
                  begin
                    CanEndBlock := False;
                    CanEndMethod := False;
                  end
                  else if (CurrBlock = nil) and (CurrMethod <> nil) then
                  begin
                    CanEndBlock := False;
                    CanEndMethod := True;
                  end
                  else if (CurrBlock <> nil) and (CurrMethod = nil) then
                  begin
                    CanEndBlock := True;
                    CanEndMethod := False;
                  end
                  else if (CurrBlock <> nil) and (CurrMethod <> nil) then
                  begin
                    // 判断 CurrBlock 是不是 CurrMethod 对应的 begin，是则都能结束
                    SameBlockMethod := False;
                    if not FProcStack.IsEmpty then
                    begin
                      AProcObj := TCnProcObj(FProcStack.Peek);
                      if (AProcObj.Token = CurrMethod) and (AProcObj.BeginToken = CurrBlock) then
                        SameBlockMethod := True;
                    end;

                    if SameBlockMethod then
                    begin
                      CanEndMethod := True;
                      CanEndBlock := True;
                    end
                    else
                    begin
                      CanEndBlock := CurrBlock.ItemIndex >= CurrMethod.ItemIndex;
                      CanEndMethod := CurrMethod.ItemIndex >= CurrBlock.ItemIndex;
                    end;
                  end;

                  if CanEndBlock or (Lex.TokenID <> tkEnd) then // 其他直接结束 CurrBlock，End 要结束的也是 CurrBlock
                  begin
                    if FBlockStack.Count > 0 then
                    begin
                      CurrBlock := TCnPasToken(FBlockStack.Pop);
                    end
                    else
                    begin
                      CurrBlock := nil;
                    end;
                  end;

                  if CanEndMethod and (Lex.TokenID = tkEnd) then  // 是 End 且要结束的是 CurrMethod
                  begin
                    if (CurrMethod <> nil) and (DeclareWithEndLevel <= 0) then
                    begin
                      Token.FIsMethodClose := True;
                      Token.FMethodStartAfterParentBegin := CurrMethod.MethodStartAfterParentBegin;
                      if FMethodStack.Count > 0 then
                        CurrMethod := TCnPasToken(FMethodStack.Pop)
                      else
                        CurrMethod := nil;
                    end;
                  end;
                end;
              end
              else // 硬修补，免得 unit 的 End 也高亮
                DiscardToken(Token.TokenID = tkEnd);

              if (DeclareWithEndLevel > 0) and (Lex.TokenID = tkEnd) then // 跳出了局部声明
                Dec(DeclareWithEndLevel);

              if Lex.TokenID = tkEnd then
              begin
                // 如果 end 与 procedure/function 最新元素同级
                if FProcStack.Count > 0 then
                begin
                  AProcObj := TCnProcObj(FProcStack.Peek);
                  if AProcObj.BeginMatched and (AProcObj.Layer = Token.ItemLayer) then
                    FProcStack.Pop.Free;
                end;

                // 处理 if 对应的系列 begin end 的关系
                if not FIfStack.IsEmpty then
                begin
                  AIfObj := TCnIfStatement(FIfStack.Peek);
                  if (AIfObj.LastElseIfBegin <> nil) and
                    (AIfObj.LastElseIfBegin.ItemLayer = Token.ItemLayer) then
                  begin
                    // 此 end 与最近的 if 块中最后一个 else if 里的 begin 配对，表示此 else if 块结束
                    AIfObj.EndLastElseIfBlock;
                    ExpectElse := True;
                    // 下一个如果不是 else，则整个 if 结束
                  end
                  else if (AIfObj.ElseBegin <> nil) and (AIfObj.ElseBegin.ItemLayer = Token.ItemLayer) then
                  begin
                    // 此 end 与最近的 if 块中的独立 else 中的 begin 配对，表示此 else 块结束，同时整个 if 语句结束
                    AIfObj.EndElseBlock;
                    AIfObj.EndIfAll;
                  end
                  else if (AIfObj.IfBegin <> nil) and (AIfObj.IfBegin.ItemLayer = Token.ItemLayer) then
                  begin
                    // 此 end 与最近的 if 块中的 begin 配对，表示此 if 块结束（不是整个 if 语句）
                    AIfObj.EndIfBlock;
                    ExpectElse := True;
                    // 下一个如果不是 else，则整个 if 结束
                  end
                  else if (AIfObj.LastElseIfBegin = nil) and (AIfObj.LastElseIfIf <> nil) and
                    (AIfObj.LastElseIfIf.ItemLayer > Token.ItemLayer) then
                  begin
                    // 此 end 结束掉最近的 if 块中最后一个无 begin 的 else if （end之前允许无分号），同时结束整个 if
                    AIfObj.EndLastElseIfBlock;
                    AIfObj.EndIfAll;
                  end
                  else if (AIfObj.ElseBegin = nil) and (AIfObj.ElseToken <> nil) and
                    (AIfObj.ElseToken.ItemLayer > Token.ItemLayer) then
                  begin
                    // 此 end 结束掉最近的 if 块中无 begin 的 else （end之前允许无分号），同时结束整个 if
                    AIfObj.EndElseBlock;
                    AIfObj.EndIfAll;
                  end
                  else if (AIfObj.IfBegin = nil) and (AIfObj.IfStart.ItemLayer > Token.ItemLayer) then
                  begin
                    // 此 end 结束掉最近的 if 块中无 begin 的 if （end之前允许无分号），同时结束整个 if
                    AIfObj.EndIfBlock;
                    AIfObj.EndIfAll;
                  end;

                  if AIfObj.FIfAllEnded then
                    FIfStack.Pop.Free;
                end;
              end;
            end;
        end;
      end
      else
      begin
        if not IsImpl and (Lex.TokenID = tkImplementation) then
          IsImpl := True;

        if (Lex.TokenID = tkSemicolon) and not FIfStack.IsEmpty then
        begin
          repeat
            if FIfStack.Count <= 0 then
               Break;
            AIfObj := TCnIfStatement(FIfStack.Peek);
            if AIfObj = nil then
              Break;

            // 碰到分号，查查它结束了谁，注意不能用 Token，因为没针对分号创建 Token
            // 分号的 ItemLayer 目前没有靠谱值，因此不能依赖 ItemLayer 和 if 的 Level 比较。
            // 分号如果在额外的圆括号里头，说明不能作为结束用，因此加入了 CurrBracketLevel 的判断
            // FList.Count 为分号假想的 ItemIndex
            // 情况一，如果 CurrBlock 存在，且没有后于 if 的 else 且 else 无 begin，说明分号紧接 else 同级
            // 情况二，如果 CurrBlock 存在，且没有后于最后一个 else if 的 if，且无 begin，说明分号紧接最后一个 else if 同级
            // 情况三，如果 CurrBlock 存在，且没有后于 if，且 if 没 begin，说明分号紧接 if 同级
            if CurrBlock <> nil then
            begin
              if AIfObj.HasElse and (AIfObj.ElseBegin = nil) and
                (CurrBlock.ItemIndex <= AIfObj.ElseToken.ItemIndex) and
                (CurrBracketLevel = AIfObj.ElseToken.BracketLayer) then  // 分号结束不带 begin 的 else
              begin
                AIfObj.EndElseBlock;
                AIfObj.EndIfAll;
              end
              else if (AIfObj.ElseIfCount > 0) and (AIfObj.LastElseIfBegin = nil)
                and (AIfObj.LastElseIfIf <> nil) and
                (CurrBlock.ItemIndex <= AIfObj.LastElseIfIf.ItemIndex) and
                (CurrBracketLevel = AIfObj.LastElseIfIf.BracketLayer) then
              begin
                AIfObj.EndLastElseIfBlock;       // 分号结束不带 begin 的最后一个 else if
                AIfObj.EndIfAll;
              end
              else if (AIfObj.IfBegin = nil) and
                (CurrBlock.ItemIndex <= AIfObj.IfStart.ItemIndex) and
                (CurrBracketLevel = AIfObj.IfStart.BracketLayer) then  // 分号结束不带 begin 的 if 本身
              begin
                AIfObj.EndIfBlock;
                AIfObj.EndIfAll;
              end;

              // 分号结束了整个 if 语句，可以从堆栈中弹出了
              if AIfObj.IfAllEnded then
                FIfStack.Pop.Free
              else // 分号未能结束当前 if 语句，说明不是结束的，跳出循环
                Break;

              // 注意，分号结束的整个 if 语句如果又是上一个 if 语句的尾巴，则也结束了上一个 if 语句
              // 典型的例子就是 if True then if True then Test; 最后的分号实际上结束了两个 if
              // 暂时用这种循环的方式处理，不确定副作用多大
            end
            else
              Break;
          until False;
        end;

        if (CurrMethod <> nil) and // forward, external 无实现部分，前面必须是分号
          (Lex.TokenID in [tkForward, tkExternal]) and (PrevTokenID = tkSemicolon) then
        begin
          CurrMethod.FIsMethodStart := False;
          if AKeyOnly and (CurrMethod.FItemIndex = FList.Count - 1) then
          begin
            FreePasToken(FList[FList.Count - 1]);
            FList.Delete(FList.Count - 1);
          end;
          if FMethodStack.Count > 0 then
            CurrMethod := TCnPasToken(FMethodStack.Pop)
          else
            CurrMethod := nil;

          if FProcStack.Count > 0 then
          begin
            AProcObj := TCnProcObj(FProcStack.Pop);
            AProcObj.Free;
          end;
        end;

        // 需要时，普通标识符加，& 后的标识符也加
        if not AKeyOnly and ((PrevTokenID <> tkAmpersand) or (Lex.TokenID = tkIdentifier)) then
          NewToken(Lex, ASource, CurrBlock, CurrMethod, CurrBracketLevel);
      end;

      if Lex.TokenID = tkRoundOpen then
        Inc(CurrBracketLevel)
      else if Lex.TokenID = tkRoundClose then
        Dec(CurrBracketLevel);

      if Lex.TokenID <> tkCompDirect then // 会遍历到编译指令，不应该由编译指令影响这里的解析结果
      begin
        PrevTokenID := Lex.TokenID;
        PrevTokenStr := Lex.Token;
      end;

      Lex.NextNoJunk;
    end;
  finally
    Lex.Free;
    FMethodStack.Clear;
    FBlockStack.Clear;
    FMidBlockStack.Clear;
    ClearStackAndFreeObject(FProcStack);
    ClearStackAndFreeObject(FIfStack);
  end;
end;

function TCnPasStructureParser.FindCurrentBlock(LineNumber, CharIndex:
  Integer): TTokenKind;
var
  Token: TCnPasToken;
  CurrIndex: Integer;
  Res: TTokenKind;

  procedure _BackwardFindDeclarePos;
  var
    Level: Integer;
    I, NestedProcs: Integer;
    StartInner: Boolean;
  begin
    Level := 0;
    StartInner := True;
    NestedProcs := 1;
    for I := CurrIndex - 1 downto 0 do
    begin
      Token := Tokens[I];

      // 回溯过程中碰到第一个范围，记录
      if (Res = tkNone) and (Token.TokenID in
        [tkPrivate, tkProtected, tkPublic, tkPublished]) then
        Res := Token.TokenID;

      if Token.IsBlockStart then
      begin
        if StartInner and (Level = 0) then
        begin
          FInnerBlockStartToken := Token;
          StartInner := False;
        end;

        if Level = 0 then
          FBlockStartToken := Token
        else
          Dec(Level);
      end
      else if Token.IsBlockClose then
      begin
        Inc(Level);
      end;

      if Token.IsMethodStart then
      begin
        if Token.TokenID in [tkProcedure, tkFunction, tkConstructor, tkDestructor] then
        begin
          // 由于 procedure 与其对应的 begin 都可能是 MethodStart，因此需要这样处理
          Dec(NestedProcs);
          if (NestedProcs = 0) and (FChildMethodStartToken = nil) then
            FChildMethodStartToken := Token;
          if Token.MethodLayer = 1 then
          begin
            FMethodStartToken := Token;
            Exit;
          end;
        end
        else if Token.TokenID in [tkBegin, tkAsm] then
        begin
          // 在可嵌套声明函数过程的地区，暂时无需其他处理
        end;
      end
      else if Token.IsMethodClose then
        Inc(NestedProcs);

      if Token.TokenID in [tkImplementation] then
      begin
        Exit;
      end;
    end;
  end;

  procedure _ForwardFindDeclarePos;
  var
    Level: Integer;
    I, NestedProcs: Integer;
    EndInner: Boolean;
  begin
    Level := 0;
    EndInner := True;
    NestedProcs := 1;
    for I := CurrIndex to Count - 1 do
    begin
      Token := Tokens[I];
      if Token.IsBlockClose then
      begin
        if EndInner and (Level = 0) then
        begin
          FInnerBlockCloseToken := Token;
          EndInner := False;
        end;

        if Level = 0 then
          FBlockCloseToken := Token
        else
          Dec(Level);
      end
      else if Token.IsBlockStart then
      begin
        Inc(Level);
      end;

      if Token.IsMethodClose then
      begin
        Dec(NestedProcs);
        if Token.MethodLayer = 1 then // 碰到的最近的 Layer 为 1 的，必然是最外层
        begin
          FMethodCloseToken := Token;
          Exit;
        end
        else if (NestedProcs = 0) and (FChildMethodCloseToken = nil) then
          FChildMethodCloseToken := Token;
          // 最近的同层次的，才是 ChildMethodClose  
      end
      else if Token.IsMethodStart and (Token.TokenID in [tkProcedure, tkFunction,
        tkConstructor, tkDestructor]) then
      begin
        Inc(NestedProcs);
      end;

      if Token.TokenID in [tkInitialization, tkFinalization] then
      begin
        Exit;
      end;
    end;
  end;

  procedure _FindInnerBlockPos;
  var
    I, Level: Integer;
  begin
    // 此函数在 _ForwardFindDeclarePos 和 _BackwardFindDeclarePos 后调用
    if (FInnerBlockStartToken <> nil) and (FInnerBlockCloseToken <> nil) then
    begin
      // 层次一样则退出
      if FInnerBlockStartToken.ItemLayer = FInnerBlockCloseToken.ItemLayer then
        Exit;
      // 上下方临近的 Block 可能层次不一样，需要找个一样层次的，以最外层为准

      if FInnerBlockStartToken.ItemLayer > FInnerBlockCloseToken.ItemLayer then
        Level := FInnerBlockCloseToken.ItemLayer
      else
        Level := FInnerBlockStartToken.ItemLayer;

      for I := CurrIndex - 1 downto 0 do
      begin
        Token := Tokens[I];
        if Token.IsBlockStart and (Token.ItemLayer = Level) then
          FInnerBlockStartToken := Token;
      end;
      for i := CurrIndex to Count - 1 do
      begin
        Token := Tokens[i];
        if Token.IsBlockClose and (Token.ItemLayer = Level) then
          FInnerBlockCloseToken := Token;
      end;
    end;
  end;

  function _GetMethodName(StartToken, CloseToken: TCnPasToken): AnsiString;
  var
    I: Integer;
  begin
    Result := '';
    if Assigned(StartToken) and Assigned(CloseToken) then
      for I := StartToken.ItemIndex + 1 to CloseToken.ItemIndex do
      begin
        Token := Tokens[I];
        if I = StartToken.ItemIndex + 1 then
        begin
          // 判断 procedure/function 后第一个是否是 ( var begin asm ;之类的，如果是，说明是匿名函数
          if Token.TokenID in [tkVar, tkBegin, tkAsm, tkRoundOpen, tkSemiColon] then
          begin
            Result := '<anonymous>';
            Exit;
          end;
        end;

        if (Token.Token = '(') or (Token.Token = ':') or (Token.Token = ';') then
          Break;
        Result := Result + AnsiTrim(Token.Token);
      end;
  end;

begin
  FMethodStartToken := nil;
  FMethodCloseToken := nil;
  FChildMethodStartToken := nil;
  FChildMethodCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FInnerBlockCloseToken := nil;
  FInnerBlockStartToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';
  Res := tkNone;

  CurrIndex := 0;
  while CurrIndex < Count do
  begin
    // 前者从 0 开始，后者从 1 开始，因此需要减 1
    if (Tokens[CurrIndex].LineNumber > LineNumber - 1) then
      Break;

    // 根据不同的起始 Token，判断条件也有所不同
    if Tokens[CurrIndex].LineNumber = LineNumber - 1 then
    begin
      if (Tokens[CurrIndex].TokenID in [tkBegin, tkAsm, tkTry, tkRepeat, tkIf,
        tkFor, tkWith, tkOn, tkWhile, tkCase, tkRecord, tkObject, tkClass,
        tkInterface, tkDispInterface]) and
        (Tokens[CurrIndex].CharIndex > CharIndex ) then // 起始的这样判断
        Break
      else if (Tokens[CurrIndex].TokenID in [tkEnd, tkUntil, tkThen, tkDo]) and
        (Tokens[CurrIndex].CharIndex + Length(Tokens[CurrIndex].Token) > CharIndex ) then
        Break;  //结束的这样判断
    end;

    Inc(CurrIndex);
  end;

  if (CurrIndex > 0) and (CurrIndex < Count) then
  begin
    _BackwardFindDeclarePos;
    _ForwardFindDeclarePos;

    _FindInnerBlockPos;
    if not FKeyOnly then
    begin
      FCurrentMethod := _GetMethodName(FMethodStartToken, FMethodCloseToken);
      FCurrentChildMethod := _GetMethodName(FChildMethodStartToken, FChildMethodCloseToken);
    end;
  end;

  Result := Res;
end;

function TCnPasStructureParser.IndexOfToken(Token: TCnPasToken): Integer;
begin
  Result := FList.IndexOf(Token);
end;

function TCnPasStructureParser.FindCurrentDeclaration(LineNumber, CharIndex: Integer;
  out Visibility: TTokenKind): AnsiString;
var
  Idx: Integer;
begin
  Result := '';
  Visibility := FindCurrentBlock(LineNumber, CharIndex);
  
  if InnerBlockStartToken <> nil then
  begin
    if InnerBlockStartToken.TokenID in [tkClass, tkInterface, tkRecord,
      tkDispInterface, tkObject] then
    begin
      // 往前找等号以前的标识符
      Idx := IndexOfToken(InnerBlockStartToken);
      if Idx > 3 then
      begin
        if (InnerBlockStartToken.TokenID = tkRecord)
          and (Tokens[Idx - 1].TokenID = tkPacked) then
          Dec(Idx);
        if Tokens[Idx - 1].TokenID = tkEqual then
          Dec(Idx);
        if Tokens[Idx - 1].TokenID = tkIdentifier then
          Result := Tokens[Idx - 1].Token;
      end;
    end;
  end;
end;

procedure TCnPasStructureParser.ParseString(ASource: PAnsiChar);
var
  Lex: TmwPasLex;
begin
  Clear;
  Lex := nil;

  try
    FSource := ASource;

    Lex := TmwPasLex.Create(FSupportUnicodeIdent);
    Lex.Origin := PAnsiChar(ASource);

    while Lex.TokenID <> tkNull do
    begin
      if Lex.TokenID in [tkString] then
        NewToken(Lex, ASource);

      Lex.NextNoJunk;
    end;
  finally
    Lex.Free;
  end;
end;

//==============================================================================
// Pascal 源码位置信息分析
//==============================================================================

procedure ParsePasCodePosInfo(const Source: AnsiString; CurrPos: Integer;
  var PosInfo: TCodePosInfo; FullSource: Boolean; SourceIsUtf8: Boolean);
var
  IsProgram: Boolean;
  InClass: Boolean;
  IsAfterProcBegin: Boolean;
  ProcStack: TStack;
  ProcIndent: Integer;
  SavePos: TCodePosKind;
  Lex: TmwPasLex;
  Text: AnsiString;
  MyTokenID: TTokenKind;
  Bookmark: TmwPasLexBookmark;

  procedure DoNext(NoJunk: Boolean = False);
  begin
    PosInfo.LastIdentPos := Lex.LastIdentPos;
    PosInfo.LastNoSpace := Lex.LastNoSpace;
    PosInfo.LastNoSpacePos := Lex.LastNoSpacePos;
    PosInfo.LineNumber := Lex.LineNumber;
    PosInfo.LinePos := Lex.LinePos;
    PosInfo.TokenPos := Lex.TokenPos;
    PosInfo.Token := Lex.Token;
    PosInfo.TokenID := Lex.TokenID;
    if NoJunk then
    begin
      // 不能直接调用 Lex.NextNoJunk，会错误地越过注释而忽略了光标判断
      repeat
        Lex.Next;
        if (Lex.TokenID in [tkSlashesComment, tkAnsiComment, tkBorComment]) and (Lex.TokenPos < CurrPos) then
        begin
          // 重复上面的
          PosInfo.LastIdentPos := Lex.LastIdentPos;
          PosInfo.LastNoSpace := Lex.LastNoSpace;
          PosInfo.LastNoSpacePos := Lex.LastNoSpacePos;
          PosInfo.LineNumber := Lex.LineNumber;
          PosInfo.LinePos := Lex.LinePos;
          PosInfo.TokenPos := Lex.TokenPos;
          PosInfo.Token := Lex.Token;
          PosInfo.TokenID := Lex.TokenID;

          // 设置注释区域
          if PosInfo.PosKind <> pkComment then
          begin
            SavePos := PosInfo.PosKind;
            PosInfo.PosKind := pkComment;
          end;
        end;
      until not (Lex.TokenID in [tkSlashesComment, tkAnsiComment, tkBorComment, tkCRLF, tkCRLFCo, tkSpace]);
    end
    else
      Lex.Next;
  end;

begin
  if CurrPos <= 0 then
    CurrPos := MaxInt;
  Lex := nil;
  ProcStack := nil;
  PosInfo.IsPascal := True;

  // BDS 下 CurrPos 与 Text 都必须转成 Ansi 才能比较
  try
    Lex := TmwPasLex.Create;
    ProcStack := TStack.Create;

{$IFDEF IDE_WIDECONTROL}
    if SourceIsUtf8 then
    begin
      Text := CnUtf8ToAnsi(PAnsiChar(Source));
      CurrPos := Length(CnUtf8ToAnsi(Copy(Source, 1, CurrPos)));
    end
    else
      Text := Source;
{$ELSE}
    Text := Source;
{$ENDIF}
    Lex.Origin := PAnsiChar(Text);

    if FullSource then
    begin
      PosInfo.AreaKind := akHead;
      PosInfo.PosKind := pkUnknown;
    end
    else
    begin
      PosInfo.AreaKind := akImplementation;
      PosInfo.PosKind := pkUnknown;
    end;
    SavePos := pkUnknown;
    IsProgram := False;
    InClass := False;
    IsAfterProcBegin := False;
    ProcIndent := 0;

    while (Lex.TokenPos < CurrPos) and (Lex.TokenID <> tkNull) do
    begin
      // 注意：循环里调用 DoNext(True) 时，原来的实现是直接 Lex.NextNoJunk 容易越过注释
      // 导致光标在注释中时位置判断错误落在前一个了，现在 DoNext 里改成模拟调用并判断

      // CnDebugger.LogFmt('Token ID %d, Pos %d, %s',[Integer(Lex.TokenID), Lex.TokenPos, Lex.Token]);
      MyTokenID := Lex.TokenID;

      // 小修补，点号后的短关键字要当成普通标识符，才能保持 pkField
      if (Lex.LastNoSpace = tkPoint) and (Lex.TokenID in [tkTo, tkIn, tkOf, tkOn, tkIs, tkDo]) then
        MyTokenID := tkIdentifier;

      // 小修补 (. 和 .) 会被语法当成左右中括号，后者对弹出有影响
      if (Lex.TokenID = tkSquareClose) and (Lex.Token = '.)') then
        MyTokenID := tkPoint;

      case MyTokenID of
        tkUnit:
          begin
            IsProgram := False;
            PosInfo.AreaKind := akUnit;
            PosInfo.PosKind := pkFlat;
          end;
        tkProgram, tkLibrary:
          begin
            IsProgram := True;
            PosInfo.AreaKind := akProgram;
            PosInfo.PosKind := pkFlat;
          end;
        tkInterface:
          begin
            if (PosInfo.AreaKind in [akUnit, akProgram]) and not IsProgram then
            begin
              PosInfo.AreaKind := akInterface;
              PosInfo.PosKind := pkFlat;
            end
            else if Lex.IsInterface then  // 和 class/record 判断类似
            begin
              PosInfo.PosKind := pkInterface;
              DoNext(True);
              if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
                PosInfo.PosKind := pkTypeDecl
              else if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkRoundOpen) then
              begin
                while (Lex.TokenPos < CurrPos) and not (Lex.TokenID in
                  [tkNull, tkRoundClose]) do
                  DoNext;
                if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkRoundClose) then
                begin
                  DoNext(True);
                  if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
                    PosInfo.PosKind := pkTypeDecl;
                end;
              end;
              if PosInfo.PosKind = pkInterface then
                InClass := True;
            end;
          end;
        tkUses:
          begin
            if PosInfo.AreaKind in [akProgram, akInterface] then
            begin
              PosInfo.AreaKind := akIntfUses;
              PosInfo.PosKind := pkIntfUses;
            end
            else if PosInfo.AreaKind = akImplementation then
            begin
              PosInfo.AreaKind := akImplUses;
              PosInfo.PosKind := pkIntfUses;
            end;
            if PosInfo.AreaKind in [akIntfUses, akImplUses] then
            begin
              while (Lex.TokenPos < CurrPos) and not (Lex.TokenID in [tkNull, tkSemiColon]) do
              begin
                if IsProgram and (Lex.TokenID = tkString) then
                begin
                  if PosInfo.PosKind <> pkString then
                  begin
                    SavePos := PosInfo.PosKind;
                    PosInfo.PosKind := pkString;
                  end;
                end;
                DoNext;
              end;
              if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
              begin
                if PosInfo.AreaKind = akIntfUses then
                  PosInfo.AreaKind := akInterface
                else
                  PosInfo.AreaKind := akImplementation;
                PosInfo.PosKind := pkFlat;
              end;
            end;
          end;
        tkImplementation:
          if not IsProgram then
          begin
            PosInfo.AreaKind := akImplementation;
            PosInfo.PosKind := pkFlat;
          end;
        tkInitialization:
          begin
            PosInfo.AreaKind := akInitialization;
            PosInfo.PosKind := pkFlat;
          end;
        tkFinalization:
          begin
            PosInfo.AreaKind := akFinalization;
            PosInfo.PosKind := pkFlat;
          end;
// 以下代码会造成 F[''].All; 这种语句分号后位置错误地变成 pkString，因此注释掉，副作用未知
//        tkSquareClose:
//          if (Lex.Token = '.)') and (Lex.LastNoSpace in [tkIdentifier,
//            tkPointerSymbol, tkSquareClose, tkRoundClose]) then
//          begin
//            if not (Result.PosKind in [pkFieldDot, pkField, pkString]) then
//              SavePos := Result.PosKind;
//            Result.PosKind := pkFieldDot;
//          end;
        tkPoint:
          if Lex.LastNoSpace = tkEnd then
          begin
            PosInfo.AreaKind := akEnd;
            PosInfo.PosKind := pkUnknown;
          end
          else if Lex.LastNoSpaceCRLF in [tkIdentifier, tkPointerSymbol, {$IFDEF DelphiXE3_UP} tkString, {$ENDIF} // Delphi XE3 Supports function invoke on string
            tkSquareClose, tkRoundClose] then
          begin
            // 这里用 LastNoSpaceCRLF 来判断，是为了避免级联换行的那种语句后的点被误判为 pkProcedure，保证 pkField
            // 如 GetObject()
            //      .Hide()
            //      .Show() 这种
            if not (PosInfo.PosKind in [pkFieldDot, pkField]) then
              SavePos := PosInfo.PosKind;
            PosInfo.PosKind := pkFieldDot;
          end;
        tkAnsiComment, tkBorComment, tkSlashesComment:
          begin
            if PosInfo.PosKind <> pkComment then
            begin
              SavePos := PosInfo.PosKind;
              PosInfo.PosKind := pkComment;
            end;
          end;
        tkClass:
          begin
            if Lex.IsClass then
            begin
              PosInfo.PosKind := pkClass;
              DoNext(True);
              if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
                PosInfo.PosKind := pkTypeDecl
              else if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkRoundOpen) then
              begin
                while (Lex.TokenPos < CurrPos) and not (Lex.TokenID in
                  [tkNull, tkRoundClose]) do
                  DoNext;
                if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkRoundClose) then
                begin
                  DoNext(True);
                  if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
                    PosInfo.PosKind := pkTypeDecl
                  else
                  begin
                    InClass := True;
                    Continue;
                  end;
                end;
              end
              else
              begin
                InClass := True;
                Continue;
              end;
            end
            else // Lex 的 IsClass 在 class 关键字后是以下内容时判断错误，需如此弥补
            begin
              Lex.SaveToBookmark(Bookmark);
              DoNext(True);
              if (Lex.TokenPos < CurrPos) and (Lex.TokenID in [tkSealed, tkStrict,
                tkPrivate, tkProtected, tkPublic, tkPublished, tkHelper, tkClass,
                tkVar, tkConst, tkType, tkProperty]) then
              begin
                PosInfo.PosKind := pkClass;
                InClass := True;
                Continue;
              end
              else
              begin
                // 不是，则要恢复，免得多 DoNext 一次
                Lex.LoadFromBookmark(Bookmark);
              end;
            end;
          end;
        tkType:
          PosInfo.PosKind := pkType;
        tkConst:
          if not InClass then
            PosInfo.PosKind := pkConst;
        tkResourceString:
          PosInfo.PosKind := pkResourceString;
        tkVar:
          if not InClass then
            PosInfo.PosKind := pkVar;
        tkCompDirect:
          begin
            if PosInfo.PosKind <> pkCompDirect then
            begin
              SavePos := PosInfo.PosKind;
              PosInfo.PosKind := pkCompDirect;
            end;
          end;
        tkString, tkMultiLineString:
          begin
            if PosInfo.PosKind <> pkString then
            begin
              SavePos := PosInfo.PosKind;
              PosInfo.PosKind := pkString;
            end;
          end;
        tkIdentifier, tkMessage, tkRead, tkWrite, tkDefault, tkIndex:
          if (Lex.LastNoSpace = tkPoint) and (PosInfo.PosKind = pkFieldDot) then
          begin
            PosInfo.PosKind := pkField;
          end;
        tkProcedure, tkFunction, tkConstructor, tkDestructor:
          begin
            if not InClass and (PosInfo.AreaKind in [akProgram, akImplementation]) then
            begin
              ProcIndent := 0;
              if Lex.TokenID = tkProcedure then
                PosInfo.PosKind := pkProcedure
              else if Lex.TokenID = tkFunction then
                PosInfo.PosKind := pkFunction
              else if Lex.TokenID = tkConstructor then
                PosInfo.PosKind := pkConstructor
              else
                PosInfo.PosKind := pkDestructor;
              ProcStack.Push(Pointer(PosInfo.PosKind));
              IsAfterProcBegin := False;
            end;
            // todo: 处理单独声明的函数
          end;
        tkBegin, tkTry, tkCase, tkAsm, tkRecord:
          begin
            if (ProcStack.Count > 0) or ((ProcStack.Count = 0) and IsProgram and (MyTokenID = tkBegin)) then
            begin
              Inc(ProcIndent);
              if ProcStack.Count = 0 then // 表示是 program 或 library 里的主 begin
                PosInfo.PosKind := pkProcedure
              else
                PosInfo.PosKind := TCodePosKind(ProcStack.Peek);
              IsAfterProcBegin := True;
            end;

            if MyTokenID = tkRecord then
            begin
              PosInfo.PosKind := pkClass; // Record 也复用 class 标记，后续的判断类似于 class
              DoNext(True);
              if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
                PosInfo.PosKind := pkTypeDecl
              else if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkRoundOpen) then
              begin
                while (Lex.TokenPos < CurrPos) and not (Lex.TokenID in
                  [tkNull, tkRoundClose]) do
                  DoNext;
                if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkRoundClose) then
                begin
                  DoNext(True);
                  if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
                    PosInfo.PosKind := pkTypeDecl
                  else
                  begin
                    InClass := True;
                    Continue;
                  end;
                end;
              end
              else
              begin
                InClass := True;
                Continue;
              end;
            end;
          end;
        tkEnd:
          begin
            if InClass then
            begin
              PosInfo.PosKind := pkType;
              InClass := False;
            end
            else if ProcStack.Count > 0 then
            begin
              Dec(ProcIndent);
              if ProcIndent <= 0 then
              begin
                ProcStack.Pop;
                PosInfo.PosKind := pkFlat;
                IsAfterProcBegin := False;
              end;
            end;
          end;
        tkColon:
          begin
            if PosInfo.PosKind = pkVar then  // 判断是否就地 var Str: string 这种类型声明
              PosInfo.PosKind := pkVarType
            else if PosInfo.PosKind = pkConst then
              PosInfo.PosKind := pkConstTypeValue;
          end;
        tkEqual:
          begin
            if PosInfo.PosKind = pkConst then
              PosInfo.PosKind := pkConstTypeValue
            else if PosInfo.PosKind = pkType then
              PosInfo.PosKind := pkTypeDecl
            else if PosInfo.PosKind = pkField then // 等号结束 Field
              PosInfo.PosKind := SavePos;
          end;
        tkAssign:
          begin
            if PosInfo.PosKind = pkVar then  // 判断是否就地 var K := 1 这种推断声明
              PosInfo.PosKind := pkVarType;

            // Field 等内容如果碰到赋值，也要结束掉
            if PosInfo.PosKind in [pkCompDirect, pkComment, pkField] then
              PosInfo.PosKind := SavePos;
          end;
        tkSemiColon:
          begin
            if PosInfo.PosKind in [pkString, pkCompDirect, pkComment] then // 先还原
              PosInfo.PosKind := SavePos;

            if PosInfo.PosKind = pkVarType then
            begin
              // 判断是否是 procedure 对应的 begin 后，是则恢复成 pkProcedure 等
              if IsAfterProcBegin and (ProcStack.Count > 0) then
                PosInfo.PosKind := TCodePosKind(ProcStack.Peek)
              else
                PosInfo.PosKind := pkVar;
            end
            else if PosInfo.PosKind = pkConstTypeValue then
              PosInfo.PosKind := pkConst
            else if PosInfo.PosKind = pkTypeDecl then
              PosInfo.PosKind := pkType;
          end;
      else
        if PosInfo.PosKind in [pkCompDirect, pkComment, pkString, pkField,
          pkFieldDot] then
          PosInfo.PosKind := SavePos;
      end;

      DoNext;
    end;
  finally
    if Lex <> nil then
      Lex.Free;
    if ProcStack <> nil then
      ProcStack.Free;
  end;
end;

// 分析源代码中引用的单元，Source 是文件内容
procedure ParseUnitUses(const Source: AnsiString; UsesList: TStrings);
var
  Lex: TmwPasLex;
  Flag: Integer;
  S: string;
begin
  UsesList.Clear;
  Lex := TmwPasLex.Create;

  Flag := 0;
  S := '';
  try
    Lex.Origin := PAnsiChar(Source);
    while Lex.TokenID <> tkNull do
    begin
      if Lex.TokenID in [tkUses, tkContains] then
      begin
        while not (Lex.TokenID in [tkNull, tkSemiColon]) do
        begin
          Lex.Next;
          if Lex.TokenID = tkIdentifier then
          begin
            S := S + string(Lex.Token);
          end
          else if Lex.TokenID = tkPoint then
          begin
            S := S + '.';
          end
          else if Trim(S) <> '' then
          begin
            UsesList.AddObject(S, TObject(Flag));
            S := '';
          end;
        end;
      end
      else if Lex.TokenID = tkImplementation then
      begin
        Flag := 1;
        // 用 Flag 来表示 interface 还是 implementation
      end;
      Lex.Next;
    end;
  finally
    Lex.Free;
  end;
end;

{ TCnPasToken }

procedure TCnPasToken.Clear;
begin
  FCppTokenKind := TCTokenKind(0);
  FCompDirectiveType := TCnCompDirectiveType(0);
  FCharIndex := 0;
  FEditCol := 0;
  FEditLine := 0;
  FItemIndex := 0;
  FItemLayer := 0;
  FLineNumber := 0;
  FMethodLayer := 0;
  FToken[0] := #0;
  FTokenID := TTokenKind(0);
  FTokenPos := 0;
  FIsMethodStart := False;
  FIsMethodClose := False;
  FIsBlockStart := False;
  FIsBlockClose := False;
  FTag := 0;
end;

function TCnPasToken.GetEditEndCol: Integer;
begin
  Result := EditCol + Integer(StrLen(Token)); // Ansi 基本符合 EditPos 所需
end;

function TCnPasToken.GetToken: PAnsiChar;
begin
  Result := @FToken[0];
end;

{ TCnIfStatement }

procedure TCnIfStatement.AddBegin(ABegin: TCnPasToken);
begin
  if ABegin = nil then
    Exit;

  if HasElse then                         // 有 else 说明是 else 对应的 begin
    FElseBegin := ABegin
  else if FElseIfBeginList.Count > 0 then // 有 else if 说明是最后一个 else if 对应的 begin
    FElseIfBeginList[FElseIfBeginList.Count - 1] := ABegin
  else
    FIfBegin := ABegin;                   // 否则是 if 对应的 begin
end;

procedure TCnIfStatement.ChangeElseToElseIf(AIf: TCnPasToken);
begin
  if (FElseToken = nil) or (AIf = nil) then
    Exit;

  FElseList.Add(FElseToken);
  FIfList.Add(AIf);
  FElseIfBeginList.Add(nil);
  FElseIfEnded.Add(nil);
  FElseToken := nil;
end;

constructor TCnIfStatement.Create;
begin
  inherited;
  FLevel := -1;
  FElseList := TObjectList.Create(False);
  FIfList := TObjectList.Create(False);
  FElseIfBeginList := TObjectList.Create(False);
  FElseIfEnded := TList.Create;
end;

destructor TCnIfStatement.Destroy;
begin
  FElseIfEnded.Free;
  FElseIfBeginList.Free;
  FIfList.Free;
  FElseList.Free;
  inherited;
end;

procedure TCnIfStatement.EndElseBlock;
begin
  if FElseToken <> nil then
    FElseEnded := True;
end;

procedure TCnIfStatement.EndIfAll;
begin
  if FIfStart <> nil then
    FIfAllEnded := True;
end;

procedure TCnIfStatement.EndIfBlock;
begin
  if FIfStart <> nil then
    FIfEnded := True;
end;

procedure TCnIfStatement.EndLastElseIfBlock;
begin
  if ElseIfCount > 0 then
    FElseIfEnded[FElseIfEnded.Count - 1] := Pointer(Ord(True));
end;

function TCnIfStatement.GetElseIfCount: Integer;
begin
  Result := FElseList.Count;
end;

function TCnIfStatement.GetElseIfElse(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FElseList[Index]);
end;

function TCnIfStatement.GetElseIfIf(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FIfList[Index]);
end;

function TCnIfStatement.GetLastElseIfBegin: TCnPasToken;
begin
  Result := nil;
  if FElseIfBeginList.Count > 0 then
    Result := TCnPasToken(FElseIfBeginList[FElseIfBeginList.Count - 1]);
end;

function TCnIfStatement.GetLastElseIfElse: TCnPasToken;
begin
  Result := nil;
  if FElseList.Count > 0 then
    Result := TCnPasToken(FElseList[FElseList.Count - 1]);
end;

function TCnIfStatement.GetLastElseIfIf: TCnPasToken;
begin
  Result := nil;
  if FIfList.Count > 0 then
    Result := TCnPasToken(FIfList[FIfList.Count - 1]);
end;

function TCnIfStatement.HasElse: Boolean;
begin
  Result := FElseToken <> nil;
end;

procedure TCnIfStatement.SetElseBegin(const Value: TCnPasToken);
begin
  FElseBegin := Value;
end;

procedure TCnIfStatement.SetFIfBegin(const Value: TCnPasToken);
begin
  FIfBegin := Value;
end;

procedure TCnIfStatement.SetIfStart(const Value: TCnPasToken);
begin
  FIfStart := Value;
  if Value <> nil then
    FLevel := Value.ItemLayer
  else
    FLevel := -1;
end;

{ TCnProcObj }

function TCnProcObj.GetIsNested: Boolean;
begin
  Result := FNestCount > 0;
end;

function TCnProcObj.GetBeginMatched: Boolean;
begin
  Result := FBeginToken <> nil;
end;

function TCnProcObj.GetLayer: Integer;
begin
  if FBeginToken <> nil then
    Result := FBeginToken.ItemLayer
  else
    Result := -1;
end;

initialization
  TokenPool := TCnList.Create;

finalization
  ClearTokenPool;
  FreeAndNil(TokenPool);

end.
