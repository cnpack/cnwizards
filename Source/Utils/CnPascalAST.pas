{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnPascalAST;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Pascal 代码抽象语法树生成单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org; https://www.cnpack.org
* 备    注：同时支持 Unicode 和非 Unicode 编译器
*           不支持 Attribute，不支持匿名函数，不支持 class 内的 var/const/type 等
*           不支持泛型、不支持内联 var
*           不支持 asm（仅跳过），注释还原度较低
* 开发平台：2023.07.29 V1.3
*               加入对多行字符串的支持
*           2023.04.01 V1.2
*               调整部分对外声明以有利使用
*           2022.10.16 V1.1
*               基本完成解析
*           2022.09.24 V1.0
*               创建单元，离完整实现功能还早
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, TypInfo, mPasLex, CnPasWideLex, CnTree, CnContainers, CnStrings;

type
  ECnPascalAstException = class(Exception);

{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}  // 2005 以上
  TCnGeneralPasLex = TCnPasWideLex;
  TCnGeneralLexBookmark = TCnPasWideBookmark;
{$ELSE}                               // 5 6 7
  TCnGeneralPasLex = TmwPasLex;
  TCnGeneralLexBookmark = TmwPasLexBookmark;
{$ENDIF}

  TCnPasNodeType = (
    cntInvalid,

    cntSpace,
    cntLineComment,
    cntBlockComment,
    cntCompDirective,

    cntAsm,

    cntComma,
    cntSemiColon,
    cntColon,
    cntSingleOps,
    cntRelOps,
    cntAddOps,
    cntMulOps,
    cntRange,
    cntHat,
    cntDot,

    cntSquareOpen,
    cntSquareClose,
    cntRoundOpen,
    cntRoundClose,

    cntAssign,
    cntAddress,

    cntInt,
    cntFloat,
    cntString,
    cntIdent,
    cntGuid,
    cntInherited,

    cntConst,
    cntIndex,
    cntRead,
    cntWrite,
    cntImplements,
    cntDefault,
    cntStored,
    cntNodefault,
    cntReadonly,
    cntWriteonly,

    cntProgram,
    cntLibrary,
    cntUnit,
    cntInterfaceSection,
    cntImplementationSection,
    cntInitializationSection,
    cntFinalizationSection,
    cntAsmBlock,

    cntIf,
    cntCase,
    cntRepeat,
    cntWhile,
    cntFor,
    cntWith,
    cntTry,
    cntRaise,
    cntGoto,

    cntElse,
    cntTo,
    cntDo,
    cntExcept,
    cntFinally,
    cntOn,
    cntThen,
    cntUntil,
    cntAt,
    cntCaseSelector,
    cntCaseLabel,
    cntOut,
    cntObject,

    cntUsesClause,
    cntUsesDecl,
    cntTypeSection,
    cntTypeDecl,
    cntTypeKeyword,
    cntTypeID,
    cntRestrictedType,
    cntCommonType,

    cntEnumeratedList,
    cntEmumeratedIdent,
    cntVariantSection,

    cntArrayType,
    cntOrdinalType,
    cntSubrangeType,
    cntSetType,
    cntFileType,
    cntOf,
    cntStringType,
    cntProcedureType,
    cntClassType,
    cntClassBody,
    cntClassHeritage,
    cntClassField,
    cntClassConstantDecl,
    cntObjectType,
    cntInterfaceType,
    cntInterfaceHeritage,

    cntRecord,
    cntFieldList,
    cntFieldDecl,
    cntRecVariant,
    cntIdentList,

    cntConstSection,
    cntConstDecl,
    cntExportsSection,
    cntExportDecl,

    cntSetConstructor,
    cntSetElement,

    cntVisibility,
    cntProcedureHeading,
    cntFunctionHeading,
    cntProperty,
    cntPropertyInterface,
    cntPropertySpecifiers,
    cntPropertyParameterList,
    cntVarSection,
    cntVarDecl,
    cntTypedConstant,
    cntFormalParameters,
    cntFormalParam,

    cntProcedureFunctionDecl,
    cntProcedure,
    cntFunction,
//    cntConstructor,
//    cntDestructor,
    cntDirective,

    cntLabel,
    cntLabelId,
    cntStatememt,
    cntSimpleStatement,
    cntCompoundStatement,

    cntExpressionList,
    cntConstExpression,
    cntConstExpressionInType,
    cntArrayConstant,
    cntRecordConstant,
    cntRecordFieldConstant,

    cntExpression,
    cntSimpleExpression,
    cntDesignator,
    cntQualId,
    cntTerm,
    cntFactor,

    cntBegin,
    cntEnd
  );
  TCnPasNodeTypes = set of TCnPasNodeType;

  TCnPasAstLeaf = class(TCnLeaf)
  {* Text 属性存对应的字符串}
  private
    FNodeType: TCnPasNodeType;
    FTokenKind: TTokenKind;
    FReturn: Boolean;
    FNoSpaceBehind: Boolean;
    FNoSpaceBefore: Boolean;
    function GetItems(AIndex: Integer): TCnPasAstLeaf;
    procedure SetItems(AIndex: Integer; const Value: TCnPasAstLeaf);
    function GetParent: TCnPasAstLeaf;
  public
    property Parent: TCnPasAstLeaf read GetParent;
    property Items[AIndex: Integer]: TCnPasAstLeaf read GetItems write SetItems; default;

    function GetPascalCode: string;
    function GetCppCode: string;

    function ConvertString: string;
    function ConvertNumber: string;

    function ConvertQualId: string;

    property NodeType: TCnPasNodeType read FNodeType write FNodeType;
    {* 语法树节点类型}
    property TokenKind: TTokenKind read FTokenKind write FTokenKind;
    {* Pascal Token 类型，注意有的节点本身没有实际对应的 Token，用 tkNone 代替}
    property Return: Boolean read FReturn write FReturn;
    {* 该 Token 后是否应换行，默认不换}
    property NoSpaceBehind: Boolean read FNoSpaceBehind write FNoSpaceBehind;
    {* 该 Token 后是否无空格，默认有}
    property NoSpaceBefore: Boolean read FNoSpaceBefore write FNoSpaceBefore;
    {* 该 Token 前是否无空格，默认有}
  end;

  TCnPasAstTree = class(TCnTree)
  private
    function GetItems(AbsoluteIndex: Integer): TCnPasAstLeaf;
    function GetRoot: TCnPasAstLeaf;
  public
    function ReConstructPascalCode: string;

    function ConvertToHppCode: string;
    function ConvertToCppCode: string;

    property Root: TCnPasAstLeaf read GetRoot;
    property Items[AbsoluteIndex: Integer]: TCnPasAstLeaf read GetItems;
  end;

  TCnPasAstGenerator = class
  private
    FLex: TCnGeneralPasLex;
    FTree: TCnPasAstTree;
    FStack: TCnObjectStack;
    FCurrentRef: TCnPasAstLeaf;
    FReturnRef: TCnPasAstLeaf;
    FLocked: Integer;
    procedure Lock;
    procedure Unlock;
    function MatchCreateLeaf(AToken: TTokenKind; NodeType: TCnPasNodeType = cntInvalid): TCnPasAstLeaf;
    procedure MatchLeafStep(AToken: TTokenKind);
  protected
    procedure MarkReturnFlag(ALeaf: TCnPasAstLeaf);
    procedure MarkNoSpaceBehindFlag(ALeaf: TCnPasAstLeaf);
    procedure MarkNoSpaceBeforeFlag(ALeaf: TCnPasAstLeaf);

    procedure PushLeaf(ALeaf: TCnPasAstLeaf);
    procedure PopLeaf;

    function MatchCreateLeafAndPush(AToken: TTokenKind; NodeType: TCnPasNodeType = cntInvalid): TCnPasAstLeaf;
    // 将当前 Token 创建一个节点，作为 FCurrentRef 的最后一个子节点，再把 FCurrentRef 推入堆栈，自身取代 FCurrentRef
    function MatchCreateLeafAndStep(AToken: TTokenKind; NodeType: TCnPasNodeType = cntInvalid): TCnPasAstLeaf;
    // 将当前 Token 创建一个节点，作为 FCurrentRef 的最后一个子节点，解析器步进至下一个有效节点
    procedure NextToken;
    // Lex 往前行进到下一个有效 Token，如果有注释，自行跳过（先不处理条件编译指令）
    procedure SkipComments;
    // 开始时调用，跳过注释到达有效 Token

    function ForwardToken(Step: Integer = 1): TTokenKind;
    // 取下 Step 个有效 Token 但不往前行进，内部使用书签进行恢复
  public
    constructor Create(const Source: string); virtual;
    destructor Destroy; override;

    property Tree: TCnPasAstTree read FTree;
    {* Build 完毕后的语法树}

    // 有些语法部件是关键字开头，之后整一批子节点就行

    // 但有些比如二元运算，理论上是运算符要是父节点，元素是子节点，但是否真需要这样做？
    procedure Build;
    procedure BuildProgram;
    procedure BuildLibrary;
    procedure BuildUnit;

    procedure BuildProgramBlock;

    procedure BuildBlock;

    procedure BuildInterfaceSection;

    procedure BuildInterfaceDecl;

    procedure BuildImplementationSection;

    procedure BuildInitSection;

    procedure BuildDeclSection;
    procedure BuildLabelDeclSection;

    procedure BuildExportedHeading;
    {* 组装过程与函数的声明部分}

    procedure BuildExportsSection;
    procedure BuildExportsList;
    procedure BuildExportsDecl;

    procedure BuildProcedureDeclSection;
    {* 组装过程与函数实现区，可能包括 class 和函数声明有所不同}
    procedure BuildProcedureFunctionDecl;
    {* 组装函数与过程实现体，和函数声明有所不同}

    // Build 系列函数执行完后，FLex 均应 Next 到尾部之外的下一个 Token
    procedure BuildTypeSection;
    {* 碰上 type 关键字时被调用，新建 type 节点，其下是多个 typedecl 加分号，每个 typedecl 是新节点}
    procedure BuildTypeDecl;
    {* 被 BuildTypeSection 循环调用，每次新增一个节点并在下面增加 typedecl 内部各元素的子节点，不包括分号}
    procedure BulidRestrictedType;
    {* 受限类型}
    procedure BuildCommonType;
    {* 其他普通类型，对应 Type}

    procedure BuildSimpleType;
    {* 更简单的类型，Subrange/Enum/Ident，一定程度上能被 CommonType 覆盖}
    
    procedure BuildEnumeratedType;
    {* 组装一个枚举类型，(a, b) 这种}
    procedure BuildEnumeratedList;
    {* 组装一个枚举类型中的列表，(a, b) 这种中的 a, b}
    procedure BuildEmumeratedIdent;
    {* 组装一个枚举类型中的单项}

    procedure BuildStructType;
    procedure BuildArrayType;
    procedure BuildSetType;
    procedure BuildFileType;
    procedure BuildRecordType;
    procedure BuildProcedureType;
    procedure BuildPointerType;
    procedure BuildStringType;
    procedure BuildOrdinalType;
    procedure BuildSubrangeType;
    procedure BuildOrdIdentType;
    procedure BuildTypeID;
    procedure BuildGuid;

    procedure BuildClassType;
    procedure BuildClassBody;
    procedure BuildClassHeritage;
    procedure BuildClassMemberList;
    procedure BuildClassMembers;
    procedure BuildObjectType;
    procedure BuildInterfaceType;
    procedure BuildInterfaceHeritage;

    procedure BuildFieldList;
    procedure BuildClassVisibility;
    procedure BuildClassMethod;
    procedure BuildMethod;
    procedure BuildClassProperty;
    procedure BuildProperty;
    procedure BuildClassField;
    procedure BuildClassTypeSection;
    procedure BuildClassConstSection;
    procedure BuildClassConstantDecl;
    procedure BuildVarSection;
    procedure BuildVarDecl;
    procedure BuildTypedConstant;
    procedure BuildRecVariant;
    procedure BuildFieldDecl;
    procedure BuildVariantSection;

    procedure BuildPropertyInterface;
    procedure BuildPropertyParameterList;
    procedure BuildPropertySpecifiers;

    procedure BuildFunctionHeading;
    procedure BuildProcedureHeading;
    procedure BuildConstructorHeading;
    procedure BuildDestructorHeading;

    procedure BuildFormalParameters;
    {* 组装函数过程的参数列表，包括两端的小括号}
    procedure BuildFormalParam;
    {* 组装函数过程的单个参数}

    procedure BuildConstSection;
    {* 组装常量声明块}
    procedure BuildConstDecl;
    {* 组装一个常量声明，不包括分号}

    procedure BuildDirectives(NeedSemicolon: Boolean = True);
    {* 循环组装完 Diretives，NeedSemicolon 表示内部是否处理分号}

    procedure BuildDirective;
    {* 组装一个 Directive，后面可能跟一个表达式}

    procedure BuildUsesClause;
    {* 碰上 uses 关键字时被调用，新建 uses 节点，其下是多个 usesdecl 加逗号，每个 uses 是新节点}
    procedure BuildUsesDecl;
    {* 被 BuildUsesClause 循环调用，每次新增一个节点并在下面增加 usesdecl 内部各元素的子节点}
    
    procedure BuildSetConstructor;
    {* 组装一个集合表达式，有抽象节点}
    procedure BuildSetElement;
    {* 组装一个集合元素}

    procedure BulidAsmBlock;
    {* 组装汇编语句}

    procedure BuildCompoundStatement;
    {* 组装一个复合语句，也就是 begin、end 括起来的语句}
    procedure BuildStatementList;
    {* 组装一批语句组成的语句列表，以分号分隔，但不包括尾部的分号}
    procedure BuildStatement;
    {* 组装一个语句，允许为空。语句由可能的 Label 与后面的 Simple 或 Struct 语句组成}

    procedure BuildLabelId;
    {* 组装一个 LabelId}

    procedure BuildStructStatement;
    {* 组装结构语句，包括以下：}
    procedure BuildIfStatement;
    procedure BuildCaseStatement;
    procedure BuildRepeatStatement;
    procedure BuildWhileStatement;
    procedure BuildForStatement;
    procedure BuildWithStatement;
    procedure BuildTryStatement;
    procedure BuildRaiseStatement;

    procedure BuildCaseSelector;
    {* 组装 case 语句中的选择区}
    procedure BuildCaseLabel;
    {* 组装 case 语句中的选择区单个 Label}
    procedure BuildExceptionHandler;
    {* 组装 try except 块中的 on 语句}

    procedure BuildSimpleStatement;
    {* 组装一个简单语句，包括 Designator、Designator 及后面的赋值、inherited、Goto 等
      注意，语句开头如果是左小括号，无法直接判断是 Designator 类似于 (a)[0] := 1 这种、
            还是 SimpleStatement/Factor 类似于 (Caption := '') 这种}
    procedure BuildExpressionList;
    {* 组装一个表达式列表，由逗号分隔}
    procedure BuildExpression;
    {* 组装一个表达式，该表达式由 SimpleExpression 与比较、语法等性质的二元运算符连接}
    procedure BuildConstExpression;
    {* 组装一常量表达式，类似于表达式}
    procedure BuildConstExpressionInType;
    {* 组装一类型声明中的常量表达式，类似于表达式，但不能出现等号等}
    procedure BuildArrayConstant;
    procedure BuildRecordConstant;
    procedure BuildRecordFieldConstant;

    procedure BuildSimpleExpression;
    {* 组装一个简单表达式，主要由 Term 组成，Term 之间用 AddOp 连接}
    procedure BuildTerm;
    {* 组装一个 Term，主要由 Factor 组成，Factor 之间用 MulOp 连接}
    procedure BuildFactor;
    {* 组装一个 Factor，虽然可以理解成语法树中除了简单标识符外的最简单部分，有抽象节点
      但其内部却有 Designator 这种单逻辑标识符，地位和简单标识符等同，@ 则另算}
    procedure BuildDesignator;
    {* 组装一个 Designator 标识符，主要是中括号的多维数组下标、以及小括号的 FunctionCall，以及指针的指^ 以及点 . 和后面的域标识符，不包括 @
      大概是指能够通过这几个运算符级联下去的单逻辑标识符，可以出现在 := 的左方，这和出现在 := 右方的 Expression 是不同的}
    procedure BuildQualId;
    {* 组装一个 QualId，主要是 Ident 以及 (Designator as Type)，作为 Designator 的起始部分}

    procedure BuildIdentList;
    procedure BuildIdent;
    {* 组装一个标识符，可以带点号}

  end;

function PascalAstNodeTypeToString(AType: TCnPasNodeType): string;

implementation

resourcestring
  SCnInvalidFileType = 'Invalid File Type!';
  SCnNotImplemented = 'NOT Implemented';
  SCnErrorStack = 'Stack Empty';
  SCnErrorNoMatchNodeType = 'No Matched Node Type';
  SCnErrorTokenNotMatchFmt = 'Token NOT Matched. Should %s, but meet %s: %s  Line %d Column %d';

const
  SpaceTokens = [tkCRLF, tkCRLFCo, tkSpace];

  CommentTokens = [tkSlashesComment, tkAnsiComment, tkBorComment];

  RelOpTokens = [tkGreater, tkLower, tkGreaterEqual, tkLowerEqual, tkNotEqual,
    tkEqual, tkIn, tkAs, tkIs];

  AddOPTokens = [tkPlus, tkMinus, tkOr, tkXor];

  MulOpTokens = [tkStar, tkDiv, tkSlash, tkMod, tkAnd, tkShl, tkShr];

  VisibilityTokens = [tkPublic, tkPublished, tkProtected, tkPrivate];

  ProcedureTokens = [tkProcedure, tkFunction, tkConstructor, tkDestructor];

  PropertySpecifiersTokens = [tkDispid, tkRead, tkIndex, tkWrite, tkStored,
    tkImplements, tkDefault, tkNodefault, tkReadonly, tkWriteonly];

  ClassMethodTokens = [tkClass] + ProcedureTokens;

  ClassMemberTokens = [tkIdentifier, tkClass, tkProperty, tkType, tkConst]
     + ProcedureTokens;  // 不支持 class var/threadvar

  DirectiveTokens = [tkVirtual, tkOverride, tkAbstract, tkReintroduce, tkStdcall,
    tkCdecl, tkInline, tkName, tkIndex, tkLibrary, tkDefault, tkNoDefault,
    tkRead, tkReadonly, tkWrite, tkWriteonly, tkStored, tkImplements, tkOverload,
    tkPascal, tkRegister, tkExternal, tkAssembler, tkDynamic, tkAutomated,
    tkDispid, tkExport, tkFar, tkForward, tkNear, tkMessage, tkResident, tkSafecall,
    tkPlatform, tkDeprecated];
    // 还有 platform, deprecated, unsafe, varargs 等一堆

  DirectiveTokensWithExpressions = [tkDispID, tkExternal, tkMessage, tkName,
    tkImplements, tkStored, tkRead, tkWrite, tkIndex];

  DeclSectionTokens = [tkClass, tkLabel, tkConst, tkResourcestring, tkType, tkVar,
    tkThreadvar, tkExports] + ProcedureTokens;

  InterfaceDeclTokens = [tkConst, tkResourcestring, tkThreadvar, tkType, tkVar,
    tkProcedure, tkFunction, tkExports];

  SimpleStatementTokens = [tkIdentifier, tkGoto, tkInherited,
    tkAddressOp, tkRoundOpen, tkVar, tkConst];
                              // 10.3 新语法允许 inline var/const

  StructStatementTokens = [tkAsm, tkBegin, tkIf, tkCase, tkFor, tkWhile, tkRepeat,
    tkWith, tkTry, tkRaise];

  StatementTokens = [tkLabel] + SimpleStatementTokens + StructStatementTokens;

  CanBeIdentifierTokens = DirectiveTokens + [tkIdentifier]; // 部分关键字可以做变量名，待补充

function PascalAstNodeTypeToString(AType: TCnPasNodeType): string;
begin
  Result := GetEnumName(TypeInfo(TCnPasNodeType), Ord(AType));

  if Length(Result) > 3 then
  begin
    Delete(Result, 1, 3);
    Result := UpperCase(Result);
  end;
end;

function NodeTypeFromToken(AToken: TTokenKind): TCnPasNodeType;
begin
  case AToken of
    // Goal
    tkProgram: Result := cntProgram;
    tkLibrary: Result := cntLibrary;
    tkUnit: Result := cntUnit;

    // Section
    tkUses: Result := cntUsesClause;
    tkType: Result := cntTypeSection;
    tkExports: Result := cntExportsSection;
    tkVar, tkThreadvar: Result := cntVarSection;
    tkImplementation: Result := cntImplementationSection;
    tkInitialization: Result := cntInitializationSection;
    tkFinalization: Result := cntFinalizationSection;

    // 语句块
    tkAsm: Result := cntAsm;
    tkBegin: Result := cntBegin;
    tkEnd: Result := cntEnd;
    tkProcedure, tkConstructor, tkDestructor: Result := cntProcedure;
    tkFunction: Result := cntFunction;

    // 结构化语句
    tkIf: Result := cntIf;
    tkCase: Result := cntCase;
    tkRepeat: Result := cntRepeat;
    tkWhile: Result := cntWhile;
    tkFor: Result := cntFor;
    tkWith: Result := cntWith;
    tkTry: Result := cntTry;
    tkRaise: Result := cntRaise;
    tkGoto: Result := cntGoto;

    // 结构化语句内部
    tkLabel: Result := cntLabel;
    tkElse: Result := cntElse;
    tkTo, tkDownto: Result := cntTo;
    tkDo: Result := cntDo;
    tkExcept: Result := cntExcept;
    tkFinally: Result := cntFinally;
    tkOn: Result := cntOn;
    tkThen: Result := cntThen;
    tkUntil: Result := cntUntil;
    tkAt: Result := cntAt;

    tkOut: Result := cntOut;
    tkObject: Result := cntObject;

    // 元素：注释、编译指令
    tkBorComment, tkAnsiComment: Result := cntBlockComment;
    tkSlashesComment: Result := cntLineComment;
    tkCompDirect: Result := cntCompDirective;

    // 元素：标识符和数字、字符串等
    tkIdentifier, tkNil: Result := cntIdent;
    tkInteger, tkNumber: Result := cntInt; // 十六进制整数和普通整数
    tkFloat: Result := cntFloat;
    tkAsciiChar, tkString, tkMultiLineString: Result := cntString;
    tkInherited: Result := cntInherited;

    // 元素：符号与运算符等
    tkComma: Result := cntComma;
    tkSemiColon: Result := cntSemiColon;
    tkColon: Result := cntColon;
    tkDotDot: Result := cntRange;
    tkPoint: Result := cntDot;
    tkPointerSymbol: Result := cntHat;
    tkAssign: Result := cntAssign;
    tkAddressOp: Result := cntAddress;

    tkPlus, tkMinus, tkOr, tkXor: Result := cntAddOps;
    tkStar, tkDiv, tkSlash, tkMod, tkAnd, tkShl, tkShr: Result := cntMulOps;
    tkGreater, tkLower, tkGreaterEqual, tkLowerEqual, tkNotEqual, tkEqual, tkIn, tkAs, tkIs:
      Result := cntRelOps;
    tkNot: Result := cntSingleOps;

    tkSquareOpen: Result := cntSquareOpen;
    tkSquareClose: Result := cntSquareClose;
    tkRoundOpen: Result := cntRoundOpen;
    tkRoundClose: Result := cntRoundClose;

    // 类型
    tkArray: Result := cntArrayType;
    tkSet: Result := cntSetType;
    tkFile: Result := cntFileType;
    tkKeyString: Result := cntStringType;
    tkOf: Result := cntOf;
    tkRecord, tkPacked: Result := cntRecord;
    tkInterface, tkDispinterface: Result := cntInterfaceType; // interface section 由外界指定
    tkClass: Result := cntClassType;

    // 属性
    tkProperty: Result := cntProperty;
    tkConst, tkResourcestring: Result := cntConstSection;
    tkIndex: Result := cntIndex;  // TODO: 属性的 Index 要与 Directives 的 index 区分
    tkRead: Result := cntRead;
    tkWrite: Result := cntWrite;
    tkImplements: Result := cntImplements;
    tkDefault: Result := cntDefault;
    tkStored: Result := cntStored;
    tkNodefault: Result := cntNodefault;
    tkReadonly: Result := cntReadonly;
    tkWriteonly: Result := cntWriteonly;

    tkPrivate, tkProtected, tkPublic, tkPublished: Result := cntVisibility;
    tkVirtual, tkOverride, tkAbstract, tkReintroduce, tkStdcall, tkCdecl, tkInline, tkName,
    tkOverload, tkPascal, tkRegister, tkExternal, tkAssembler, tkDynamic, tkAutomated,
    tkDispid, tkExport, tkFar, tkForward, tkNear, tkMessage, tkResident, tkSafecall,
    tkPlatform, tkDeprecated:
      Result := cntDirective;
  else
    raise ECnPascalAstException.Create(SCnErrorNoMatchNodeType + ' '
      + GetEnumName(TypeInfo(TTokenKind), Ord(AToken)));
  end;
end;

{ TCnPasASTGenerator }

procedure TCnPasAstGenerator.Build;
begin
  SkipComments;

  case FLex.TokenID of
    tkProgram:
      BuildProgram;
    tkLibrary:
      BuildLibrary;
    tkUnit:
      BuildUnit;
  else
    raise ECnPascalAstException.Create(SCnInvalidFileType);
  end;
end;

procedure TCnPasAstGenerator.BuildArrayType;
begin
  MatchCreateLeafAndPush(tkArray);

  try
    if FLex.TokenID = tkSquareOpen then
    begin
      MatchCreateLeafAndPush(tkSquareOpen);
      try
        repeat
          BuildOrdinalType;
          if FLex.TokenID = tkComma then
            MatchCreateLeafAndStep(tkComma)
          else
            Break;
        until False;
      finally
        PopLeaf;
      end;
      MatchCreateLeafAndStep(tkSquareClose);
    end;

    MatchCreateLeafAndStep(tkOf);
    BuildCommonType; // Array 后的类型只能是 Common Type，不支持 class 等
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildClassType;
begin
  MatchCreateLeafAndPush(FLex.TokenID);

  try
    if FLex.TokenID = tkSemiColon then // 前向声明结束
      Exit;

    if FLex.TokenID = tkOf then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildIdent;
      Exit;
    end;

    if FLex.TokenID in [tkAbstract, tkSealed] then
      MatchCreateLeafAndStep(FLex.TokenID);

    BuildClassBody; // 分号在 TypeDecl 中处理
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildConstExpression;
begin
  // 和 BuildExpression 相同只是节点类型不同
  MatchCreateLeafAndPush(tkNone, cntConstExpression);
  // Pop 之前，内部添加的节点均为抽象的 ConstExpression 节点之子

  try
    BuildSimpleExpression;
    while FLex.TokenID in RelOpTokens + [tkPoint, tkPointerSymbol, tkSquareOpen] do
    begin
      if FLex.TokenID in RelOpTokens then
      begin
        MatchCreateLeafAndStep(FLex.TokenID);
        BuildSimpleExpression;
      end
      else if FLex.TokenID = tkPointerSymbol then // 注意，这 . ^ [] 是扩展而来，原始语法里没有
        MatchCreateLeafAndStep(FLex.TokenID)
      else if FLex.TokenID = tkPoint then
      begin
        MarkReturnFlag(MatchCreateLeafAndStep(FLex.TokenID));
        BuildIdent;
      end
      else if FLex.TokenID = tkSquareOpen then
      begin
        MatchCreateLeafAndPush(FLex.TokenID);
        try
          BuildExpressionList;
        finally
          PopLeaf;
        end;
        MatchCreateLeafAndStep(tkSquareClose);
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildDesignator;
begin
  MatchCreateLeafAndPush(tkNone, cntDesignator);
  // Pop 之前，内部添加的节点均为抽象的 Expression 节点之子

  try
    BuildQualId;
    while FLex.TokenID in [tkSquareOpen, tkRoundOpen, tkPoint, tkPointerSymbol] do
    begin
      case FLex.TokenID of
        tkSquareOpen: // 数组下标
          begin
            MatchCreateLeafAndPush(tkSquareOpen);
            // Pop 之前，内部添加的节点均为左中括号节点之子

            try
              BuildExpressionList;
            finally
              PopLeaf;
            end;
            MatchCreateLeafAndStep(tkSquareClose); // 子节点整完后回退一层，再放上配套的右中括号
          end;
        tkRoundOpen: // Function Call
          begin
            MatchCreateLeafAndPush(tkRoundOpen);
            // Pop 之前，内部添加的节点均为左中括号节点之子

            try
              BuildExpressionList;
            finally
              PopLeaf;
            end;
            MatchCreateLeafAndStep(tkRoundClose); // 子节点整完后回退一层，再放上配套的右中括号
          end;
        tkPointerSymbol:
          begin
            MatchCreateLeafAndStep(FLex.TokenID);
          end;
        tkPoint:
          begin
            MarkNoSpaceBehindFlag(MatchCreateLeafAndStep(FLex.TokenID));
            BuildIdent;
          end;
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildEmumeratedIdent;
begin
  MatchCreateLeafAndPush(tkNone, cntEmumeratedIdent);

  try
    BuildIdent;
    if FLex.TokenID = tkEqual then
    begin
      MatchCreateLeafAndStep(tkEqual);
      BuildConstExpression;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildEnumeratedList;
begin
  MatchCreateLeafAndPush(tkNone, cntEnumeratedList);

  try
    repeat
      BuildEmumeratedIdent;
      if FLex.TokenID = tkComma then
        MatchCreateLeafAndStep(tkComma)
      else
        Break;
    until False;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildEnumeratedType;
begin
  MatchCreateLeafAndPush(tkRoundOpen);

  try
    BuildEnumeratedList;
  finally
    PopLeaf;
  end;
  MatchCreateLeafAndStep(tkRoundClose);
end;

procedure TCnPasAstGenerator.BuildExpression;
begin
  MatchCreateLeafAndPush(tkNone, cntExpression);
  // Pop 之前，内部添加的节点均为抽象的 Expression 节点之子

  try
    BuildSimpleExpression;
    while FLex.TokenID in RelOpTokens + [tkPoint, tkPointerSymbol, tkSquareOpen] do
    begin
      if FLex.TokenID in RelOpTokens then
      begin
        MatchCreateLeafAndStep(FLex.TokenID);
        BuildSimpleExpression;
      end
      else if FLex.TokenID = tkPointerSymbol then // 注意，这 . ^ [] 是扩展而来，原始语法里没有
        MatchCreateLeafAndStep(FLex.TokenID)
      else if FLex.TokenID = tkPoint then
      begin
        MatchCreateLeafAndStep(FLex.TokenID);
        BuildExpression;
      end
      else if FLex.TokenID = tkSquareOpen then
      begin
        MatchCreateLeafAndPush(FLex.TokenID);
        try
          BuildExpressionList;
        finally
          PopLeaf;
        end;
        MatchCreateLeafAndStep(tkSquareClose);
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildExpressionList;
begin
  MatchCreateLeafAndPush(tkNone, cntExpressionList);
  // Pop 之前，内部添加的节点均为抽象的 ExpressionList 节点之子

  try
    repeat
      BuildExpression;
      if FLex.TokenID = tkComma then
        MatchCreateLeafAndStep(tkComma)
      else
        Break;
    until False;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFactor;
var
  T: TCnPasAstLeaf;
begin
  MatchCreateLeafAndPush(tkNone, cntFactor);
  // Pop 之前，内部添加的节点均为抽象的 Factor 节点之子

  try
    case FLex.TokenID of
      tkAddressOp:
        begin
          MarkNoSpaceBehindFlag(MatchCreateLeafAndPush(FLex.TokenID));
          // Pop 之前，内部添加的节点均为 @ 节点之子

          try
            BuildDesignator;
          finally
            PopLeaf;
          end;
        end;
      tkIdentifier, tkNil, tkKeyString, tkIndex: // TODO: 还有部分关键字可以做变量名
        begin
          BuildDesignator;
          if FLex.TokenID = tkRoundOpen then
          begin
            MatchCreateLeafAndStep(tkRoundOpen);
            BuildExpressionList;
            MatchCreateLeafAndStep(tkRoundClose)
          end;
        end;
      tkAsciiChar, tkString: // AsciiChar 是 #12 这种，可以和 string 组合，因而需要拼凑成一个
        begin
          T := MatchCreateLeafAndStep(FLex.TokenID);
          while FLex.TokenID in [tkAsciiChar, tkString] do
          begin
            if T <> nil then
              T.Text := T.Text + FLex.Token;
            NextToken;
          end;
        end;
      tkNumber, tkInteger, tkFloat, tkMultiLineString:
        MatchCreateLeafAndStep(FLex.TokenID);
      tkNot:
        begin
          MatchCreateLeafAndStep(FLex.TokenID);
          BuildFactor;
        end;
      tkSquareOpen:
        begin
          BuildSetConstructor;
        end;
      tkInherited:
        begin
          MatchCreateLeafAndPush(FLex.TokenID);
          // Pop 之前，内部添加的节点均为 inherited 节点之子

          try
            BuildExpression;
          finally
            PopLeaf;
          end;
        end;
      tkRoundOpen:
        begin
          MatchCreateLeafAndPush(FLex.TokenID);
          // Pop 之前，内部添加的节点均为左小括号节点之子

          try
            BuildExpression;
          finally
            PopLeaf;
          end;
          MatchCreateLeafAndStep(tkRoundClose); // 子节点整完后回退一层，再放上配套的右小括号

          while FLex.TokenID = tkPointerSymbol do
            MatchCreateLeafAndStep(tkPointerSymbol)
        end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFileType;
begin
  MatchCreateLeafAndPush(tkFile);

  try
    if FLex.TokenID = tkOf then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildTypeID;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildIdent;
var
  T: TCnPasAstLeaf;
begin
  if FLex.TokenID = tkNil then // nil 单独处理
  begin
    MatchCreateLeafAndStep(FLex.TokenID);
    Exit;
  end;

  if FLex.TokenID in CanBeIdentifierTokens then  // 其他可以做变量名的关键字
  begin
    T := MatchCreateLeafAndStep(FLex.TokenID);
    if FLex.TokenID <> tkPoint then              // 后面没点就退出
      Exit;

    if T <> nil then                             // 有点就加点并步进
      T.Text := T.Text + FLex.Token;
    NextToken;

    while FLex.TokenID in CanBeIdentifierTokens do
    begin
      if T <> nil then                           // 又有变量名
        T.Text := T.Text + FLex.Token;
      NextToken;

      if FLex.TokenID <> tkPoint then            // 后面没点就退出
        Exit;

      if T <> nil then                           // 有点就加点并步进
        T.Text := T.Text + FLex.Token;
      NextToken;
    end;
  end;
end;

procedure TCnPasAstGenerator.BuildLabelId;
begin
  if FLex.TokenID = tkInteger then
    MatchCreateLeafAndStep(tkInteger)
  else
    MatchCreateLeafAndStep(tkIdentifier);
end;

procedure TCnPasAstGenerator.BuildOrdinalType;
var
  Bookmark: TCnGeneralLexBookmark;
  IsRange: Boolean;

  procedure SkipOrdinalPrefix;
  begin
    repeat
      FLex.NextNoJunk;
    until not (FLex.TokenID in [tkIdentifier, tkPoint, tkInteger, tkString, tkRoundOpen, tkRoundClose,
      tkPlus, tkMinus, tkStar, tkSlash, tkDiv, tkMod]);
  end;

begin
  MatchCreateLeafAndPush(tkNone, cntOrdinalType);

  try
    if FLex.TokenID = tkRoundOpen then  // (a, b) 这种
      BuildEnumeratedType
    else
    begin
      Lock;
      FLex.SaveToBookmark(Bookmark);

      try
        SkipOrdinalPrefix;
        IsRange := FLex.TokenID = tkDotDot;
      finally
        FLex.LoadFromBookmark(Bookmark);
        Unlock;
      end;

      if IsRange then
        BuildSubrangeType
      else
        BuildOrdIdentType;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildProcedureType;
begin
  MatchCreateLeafAndPush(tkNone, cntProcedureType);

  try
    if FLex.TokenID = tkProcedure then
    begin
      BuildProcedureHeading;
    end
    else if FLex.TokenID = tkFunction then
    begin
      BuildFunctionHeading;
    end;
    if FLex.TokenID = tkOf then
    begin
      MatchCreateLeafAndStep(tkOf);
      MatchCreateLeafAndStep(tkObject);
    end;

    BuildDirectives;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildQualId;
begin
  MatchCreateLeafAndPush(tkNone, cntQualId);
  // Pop 之前，内部添加的节点均为抽象的 QualId 节点之子

  try
    case FLex.TokenID of
      tkKeyString:
        MatchCreateLeafAndStep(FLex.TokenID); // TODO: 还有一些关键字可以做强制类型转换或函数调用名
      tkNil, tkIdentifier, tkIndex:           // TODO: 还有一些关键字可以做变量名
        BuildIdent;
      tkRoundOpen:
        begin
          MatchCreateLeafAndPush(FLex.TokenID);
          // Pop 之前，内部添加的节点均为左小括号节点之子

          try
            BuildDesignator;
            if FLex.TokenID = tkAs then
            begin
              MatchCreateLeafAndStep(tkAs);
              BuildIdent; // TypeId 沿用 Ident
            end;
          finally
            PopLeaf;
          end;
          MatchCreateLeafAndStep(tkRoundClose); // 子节点整完后回退一层，再放上配套的右小括号
        end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildRecordType;
begin
  MatchCreateLeafAndPush(tkRecord);

  try
    if FLex.TokenID <> tkEnd then
      BuildFieldList;
    MatchCreateLeafAndStep(tkEnd);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSetConstructor;
begin
  MatchCreateLeafAndPush(tkNone, cntSetConstructor);
  // Pop 之前，内部添加的节点均为抽象的 SetConstructor 节点之子

  try
    MatchCreateLeafAndPush(tkSquareOpen);
   // Pop 之前，内部添加的节点均为左中括号节点之子

    try
      while True do
      begin
        BuildSetElement;
        if FLex.TokenID = tkComma then
          MatchCreateLeafAndStep(tkComma)
        else
          Break;
      end;
    finally
      PopLeaf;
    end;
    MatchCreateLeafAndStep(tkSquareClose); // 子节点整完后回退一层，再放上配套的右中括号
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSetElement;
begin
  MatchCreateLeafAndPush(tkNone, cntSetElement);
  // Pop 之前，内部添加的节点均为抽象的 SetElement 节点之子

  try
    BuildExpression;
    if FLex.TokenID = tkDotDot then
    begin
      MatchCreateLeafAndStep(tkDotDot);
      BuildExpression;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSetType;
begin
  MatchCreateLeafAndPush(tkNone, cntSetType);
  // Pop 之前，内部添加的节点均为抽象的 SetType 节点之子

  try
    MatchCreateLeafAndStep(tkSet);
    MatchCreateLeafAndStep(tkOf);
    BuildOrdinalType;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSimpleExpression;
begin
  MatchCreateLeafAndPush(tkNone, cntSimpleExpression);
  // Pop 之前，内部添加的节点均为抽象的 SimpleExpression 节点之子

  try
    if FLex.TokenID in [tkPlus, tkMinus, tkPointerSymbol] then
      MatchCreateLeafAndStep(FLex.TokenID);

    BuildTerm;
    while FLex.TokenID in AddOpTokens do
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildTerm;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSimpleStatement;
var
  Bookmark: TCnGeneralLexBookmark;
  IsDesignator: Boolean;
begin
  MatchCreateLeafAndPush(tkNone, cntSimpleStatement);
  // Pop 之前，内部添加的节点均为抽象的 SimpleStatement 节点之子

  try
    if FLex.TokenID = tkGoto then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildLabelId;
    end
    else if FLex.TokenID = tkInherited then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      // 后面可能没了，也可能是另一个 SimpleStatement
      if not (FLex.TokenID in [tkSemicolon, tkEnd, tkElse]) then
        BuildSimpleStatement;
    end
    else if FLex.TokenID = tkRoundOpen then
    begin
      // ( Statement ) 这种，但不易与 Designator 区分开来，需要另想办法区分
      FLex.SaveToBookmark(Bookmark);
      Lock;
      try
        // 向前判断是否 Designator
        try
          BuildDesignator;
          // 假设 Designator 处理完毕，判断后续是啥

          IsDesignator := FLex.TokenID in [tkAssign, tkRoundOpen, tkSemicolon,
            tkElse, tkEnd];
          // TODO: 目前只想到这几个。Semicolon 是怕 Designator 已经作为语句处理完了，
          // else/end 是怕语句结束没分号导致判断失误。
        except
          IsDesignator := False;
          // 如果后面碰到了 := 等情形，BuildDesignator 会出错，
          // 说明本句是带括号嵌套的 Simplestatement
        end;
      finally
        Unlock;
        FLex.LoadFromBookmark(Bookmark);
      end;

      if IsDesignator then // 是 Designator，处理后面可能有的赋值
      begin
        BuildDesignator;
        if FLex.TokenID = tkAssign then
        begin
          MatchCreateLeafAndStep(FLex.TokenID);
          BuildExpression;
        end;
      end
      else // 是 ( Statement )
      begin
        MatchCreateLeafAndPush(tkRoundOpen);
        // Pop 之前，内部添加的节点均为左小括号节点之子

        try
          BuildSimpleStatement; // TODO: 改为 Statement
        finally
          PopLeaf;
        end;
        MatchCreateLeafAndStep(tkRoundClose);
      end;
    end
    else // 非 ( 开头，也是 Designator，处理后面可能有的赋值
    begin
      BuildDesignator;
      if FLex.TokenID = tkAssign then
      begin
        MatchCreateLeafAndStep(FLex.TokenID);
        BuildExpression;
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildStringType;
begin
  MatchCreateLeafAndPush(tkNone, cntStringType);

  try
    if FLex.TokenID = tkKeyString then
      MatchCreateLeafAndStep(FLex.TokenID)
    else
      BuildIdent;

    if FLex.TokenID = tkRoundOpen then
    begin
      MatchCreateLeafAndPush(FLex.TokenID);
      try
        BuildExpression;
      finally
        PopLeaf;
      end;
      MatchCreateLeafAndStep(tkRoundClose);
    end
    else if FLex.TokenID = tkSquareOpen then
    begin
      MatchCreateLeafAndPush(FLex.TokenID);
      try
        BuildConstExpression;
      finally
        PopLeaf;
      end;
      MatchCreateLeafAndStep(tkSquareClose);
    end
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildStructType;
begin
  if FLex.TokenID = tkPacked then
    MatchCreateLeafAndStep(tkPacked);

  case FLex.TokenID of
    tkArray:
      BuildArrayType;
    tkSet:
      BuildSetType;
    tkFile:
      BuildFileType;
    tkRecord:
      BuildRecordType;
  end;
end;

procedure TCnPasAstGenerator.BuildTerm;
begin
  MatchCreateLeafAndPush(tkNone, cntTerm);
  // Pop 之前，内部添加的节点均为抽象的 Term 节点之子

  try
    BuildFactor;
    while FLex.TokenID in MulOpTokens do
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildFactor;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildCommonType;
var
  Bookmark: TCnGeneralLexBookmark;
  IsRange: Boolean;
begin
  MatchCreateLeafAndPush(tkNone, cntCommonType);

  try
    case FLex.TokenID of
      tkRoundOpen:
        begin
          BuildEnumeratedType;
        end;
      tkPacked, tkArray, tkSet, tkFile, tkRecord:
        begin
          BuildStructType;
        end;
      tkProcedure, tkFunction:
        begin
          BuildProcedureType;
        end;
      tkPointerSymbol:
        begin
          BuildPointerType;
        end;
    else
      if (FLex.TokenID = tkKeyString) or SameText(FLex.Token, 'String')
        or SameText(FLex.Token, 'AnsiString') or SameText(FLex.Token, 'WideString')
        or SameText(FLex.Token, 'UnicodeString') then
        BuildStringType
      else
      begin
        // TypeID? 越过一个 ConstExpressionInType 后看是否是 ..
        Lock;
        FLex.SaveToBookmark(Bookmark);

        try
          BuildConstExpressionInType;
          IsRange := FLex.TokenID = tkDotDot;
        finally
          FLex.LoadFromBookmark(Bookmark);
          UnLock;
        end;

        if IsRange then
          BuildSubrangeType
        else
          BuildTypeID;
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildTypeDecl;
begin
  MatchCreateLeafAndPush(tkNone, cntTypeDecl);
  // Pop 之前，内部添加的节点均为 TypeDecl 节点之子

  try
    BuildIdent;
    MatchCreateLeafAndStep(tkEqual);
    if FLex.TokenID = tkType then
      MatchCreateLeafAndStep(tkType, cntTypeKeyword);

    // 要分开 RestrictType 和普通 Type，前者包括 class/object/interface，部分场合不允许出现
    if FLex.TokenID in [tkClass, tkObject, tkInterface, tkDispInterface] then
      BulidRestrictedType
    else
      BuildCommonType;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildTypeSection;
begin
  MarkReturnFlag(MatchCreateLeafAndPush(tkType));
  // Pop 之前，内部添加的节点均为 type 节点之子

  try
    while FLex.TokenID = tkIdentifier do
    begin
      BuildTypeDecl;
      MarkReturnFlag(MatchCreateLeafAndStep(tkSemiColon));
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildUsesClause;
begin
  if FLex.TokenID in [tkUses, tkRequires, tkContains] then
    MarkReturnFlag(MatchCreateLeafAndPush(FLex.TokenID));

  // Pop 之前，内部添加的节点均为 Uses 节点之子

  try
    while True do
    begin
      BuildUsesDecl;
      if FLex.TokenID = tkComma then
        MatchCreateLeafAndStep(tkComma)
      else
        Break;
    end;

    MarkReturnFlag(MatchCreateLeafAndStep(tkSemiColon));
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildUsesDecl;
begin
  BuildIdent;
  if FLex.TokenID = tkIn then
  begin
    MatchCreateLeafAndStep(tkIn);
    MatchCreateLeafAndStep(tkString);
  end;
end;

procedure TCnPasAstGenerator.BulidRestrictedType;
begin
  MatchCreateLeafAndPush(tkNone, cntRestrictedType);

  try
    case FLex.TokenID of
      tkClass:
        BuildClassType;
      tkObject:
        BuildObjectType;
      tkInterface, tkDispinterface:
        BuildInterfaceType;
    end;
  finally
    PopLeaf;
  end;
end;

constructor TCnPasASTGenerator.Create(const Source: string);
begin
  inherited Create;
  FLex := TCnGeneralPasLex.Create;
  FStack := TCnObjectStack.Create;
  FTree := TCnPasAstTree.Create(TCnPasAstLeaf);
  FCurrentRef := FTree.Root as TCnPasAstLeaf;

  FLex.Origin := PChar(Source);
end;

destructor TCnPasASTGenerator.Destroy;
begin
  FTree.Free;
  FStack.Free;
  FLex.Free;
  inherited;
end;

procedure TCnPasAstGenerator.Lock;
begin
  Inc(FLocked);
end;

function TCnPasAstGenerator.MatchCreateLeafAndStep(AToken: TTokenKind;
  NodeType: TCnPasNodeType): TCnPasAstLeaf;
begin
  Result := MatchCreateLeaf(AToken, NodeType);
  MatchLeafStep(AToken);
end;

function TCnPasAstGenerator.MatchCreateLeaf(AToken: TTokenKind;
  NodeType: TCnPasNodeType): TCnPasAstLeaf;
begin
  Result := nil;
  if (AToken <> tkNone) and (AToken <> FLex.TokenID) then
  begin
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
    raise ECnPascalAstException.CreateFmt(SCnErrorTokenNotMatchFmt,
      [GetEnumName(TypeInfo(TTokenKind), Ord(AToken)),
       GetEnumName(TypeInfo(TTokenKind), Ord(FLex.TokenID)),
       FLex.Token, FLex.LineNumber + 1, FLex.TokenPos - FLex.LineStartOffset]);
{$ELSE}
    raise ECnPascalAstException.CreateFmt(SCnErrorTokenNotMatchFmt,
      [GetEnumName(TypeInfo(TTokenKind), Ord(AToken)),
       GetEnumName(TypeInfo(TTokenKind), Ord(FLex.TokenID)),
       FLex.Token, FLex.LineNumber + 1, FLex.TokenPos - FLex.LinePos]);
{$ENDIF}
  end;

  if NodeType = cntInvalid then
    NodeType := NodeTypeFromToken(AToken);

  if FLocked = 0 then // 未锁才创建节点
  begin
    if (FCurrentRef <> nil) and (FTree.Root <> FCurrentRef) then
      Result := FTree.AddChild(FCurrentRef) as TCnPasAstLeaf
    else
      Result := FTree.AddChild(FTree.Root) as TCnPasAstLeaf;

    Result.TokenKind := AToken;
    Result.NodeType := NodeType;

    if AToken <> tkNone then      // 未锁才赋值
      Result.Text := FLex.Token;
  end;
end;

procedure TCnPasAstGenerator.MatchLeafStep(AToken: TTokenKind);
begin
  if AToken <> tkNone then // 有内容的实际节点，才步进一下，且锁不锁都要前进
    NextToken;
end;

function TCnPasAstGenerator.MatchCreateLeafAndPush(AToken: TTokenKind;
  NodeType: TCnPasNodeType): TCnPasAstLeaf;
begin
  Result := MatchCreateLeaf(AToken, NodeType);
  if Result <> nil then
  begin
    PushLeaf(FCurrentRef);
    FCurrentRef := Result;  // Pop 之前，内部添加的节点均为该节点之子
  end;
  MatchLeafStep(AToken);    // 设 FCurrent 后再步进，避免 Step 里的注释挂错节点
end;

procedure TCnPasAstGenerator.NextToken;
begin
  repeat
    FLex.Next;

    if FLex.TokenID in CommentTokens + [tkCompDirect] then
      MatchCreateLeaf(FLex.TokenID); // 不步进，由本循环步进

  until not (FLex.TokenID in SpaceTokens + CommentTokens + [tkCompDirect]);
end;

function TCnPasAstGenerator.ForwardToken(Step: Integer): TTokenKind;
var
  Cnt: Integer;
  Bookmark: TCnGeneralLexBookmark;
begin
  FLex.SaveToBookmark(Bookmark);

  Cnt := 0;
  try
    while True do
    begin
      NextToken;
      Inc(Cnt);
      Result := FLex.TokenID;

      if Cnt >= Step then
        Exit;
    end;
  finally
    FLex.LoadFromBookmark(Bookmark);
  end;
end;

procedure TCnPasAstGenerator.PopLeaf;
begin
  if FLocked > 0 then // 锁着时不 Pop，因为 Push 也锁了
    Exit;

  if FStack.Count <= 0 then
    raise ECnPascalAstException.Create(SCnErrorStack);

  FCurrentRef := TCnPasAstLeaf(FStack.Pop);
end;

procedure TCnPasAstGenerator.PushLeaf(ALeaf: TCnPasAstLeaf);
begin
  if ALeaf <> nil then
    FStack.Push(ALeaf);
end;

procedure TCnPasAstGenerator.Unlock;
begin
  Dec(FLocked);
end;

procedure TCnPasAstGenerator.BuildInterfaceType;
begin
  MatchCreateLeafAndPush(FLex.TokenID);

  try
    if FLex.TokenID = tkSemiColon then // 前向声明结束，分号让外部处理
      Exit;

    if FLex.TokenID = tkRoundOpen then
      BuildInterfaceHeritage;

    if FLex.TokenID = tkSquareOpen then
      BuildGuid;

    while FLex.TokenID in VisibilityTokens + ProcedureTokens + [tkProperty] do
    begin
      if FLex.TokenID in VisibilityTokens then
        BuildClassVisibility
      else if FLex.TokenID in ProcedureTokens then
        BuildMethod  // 注意不是 ClassMethod，因为接口不支持 class function 这种
      else if Flex.TokenID = tkProperty then
        BuildProperty;
    end;
    MatchCreateLeafAndStep(tkEnd);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildObjectType;
begin
  raise ECnPascalAstException.Create(SCnNotImplemented);
end;

procedure TCnPasAstGenerator.BuildOrdIdentType;
begin
  BuildIdent;
end;

procedure TCnPasAstGenerator.BuildSubrangeType;
begin
  MatchCreateLeafAndPush(tkNone, cntSubrangeType);

  try
    BuildConstExpression;
    MatchCreateLeafAndStep(tkDotDot);
    BuildConstExpression;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildPointerType;
begin
  MatchCreateLeafAndPush(tkPointerSymbol, cntHat);

  try
    BuildTypeID;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildTypeID;
begin
  MatchCreateLeafAndPush(tkNone, cntTypeID);

  try
    if FLex.TokenID in [tkKeyString, tkFile, tkConst, tkProcedure, tkFunction] then // BuildIdent 内部不认关键字 string、File
      MatchCreateLeafAndStep(FLex.TokenID)
    else
      BuildIdent;

    if FLex.TokenID = tkRoundOpen then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildExpression;
      MatchCreateLeafAndStep(tkRoundClose)
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFieldList;
begin
  MatchCreateLeafAndPush(tkNone, cntFieldList);

  try
    while not (FLex.TokenID in [tkEnd, tkCase, tkRoundClose]) do
    begin
      if FLex.TokenID in VisibilityTokens then
        BuildClassVisibility;

      if FLex.TokenID = tkCase then
        Break
      else if FLex.TokenID in ProcedureTokens then
        BuildMethod
      else if FLex.TokenID = tkProperty then
        BuildProperty
      else if FLex.TokenID = tkType then
        BuildClassTypeSection
      else if FLex.TokenID = tkConst then
        BuildClassConstSection
      else if FLex.TokenID in [tkVar, tkThreadVar] then
        BuildVarSection
      else if FLex.TokenID <> tkEnd then
      begin
        BuildFieldDecl;
        if FLex.TokenID = tkSemiColon then
          MatchCreateLeafAndStep(tkSemiColon);
      end;
    end;

    // 处理 case 可变体
    if FLex.TokenID = tkCase then
      BuildVariantSection;

    if FLex.TokenID = tkSemiColon then
      MatchCreateLeafAndStep(tkSemiColon);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildIdentList;
begin
  MatchCreateLeafAndPush(tkNone, cntIdentList);

  try
    repeat
      BuildIdent;
      if FLex.TokenID = tkComma then
        MatchCreateLeafAndStep(tkComma)
      else
        Break;
    until False;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFunctionHeading;
begin
  MatchCreateLeafAndPush(tkFunction);

  try
    if FLex.TokenID = tkIdentifier then
      BuildIdent;

    if FLex.TokenID = tkRoundOpen then
      BuildFormalParameters;

    MatchCreateLeafAndStep(tkColon);
    BuildCommonType;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildProcedureHeading;
begin
  if FLex.TokenID in [tkProcedure, tkConstructor, tkDestructor] then
    MatchCreateLeafAndPush(FLex.TokenID);

  try
    if FLex.TokenID = tkIdentifier then
      BuildIdent;

    if FLex.TokenID = tkRoundOpen then
      BuildFormalParameters;

    if FLex.TokenID = tkEqual then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildIdent;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildClassConstSection;
begin
  MatchCreateLeafAndPush(tkConst);

  try
    while FLex.TokenID = tkIdentifier do
      BuildClassConstantDecl;

    MatchCreateLeafAndStep(tkSemiColon);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildMethod;
begin
  case FLex.TokenID of
    tkProcedure:
      BuildProcedureHeading;
    tkFunction:
      BuildFunctionHeading;
    tkConstructor:
      BuildConstructorHeading;
    tkDestructor:
      BuildDestructorHeading;
  end;

  if FLex.TokenID = tkSemiColon then
    MarkReturnFlag(MatchCreateLeafAndStep(tkSemiColon)); // 声明后的分号

  BuildDirectives; // 这里要求把分号也吃掉
end;

procedure TCnPasAstGenerator.BuildClassTypeSection;
begin
  MarkReturnFlag(MatchCreateLeafAndPush(tkType));

  try
    while FLex.TokenID = tkIdentifier do
    begin
      BuildTypeDecl; // 类似于 BuildTypeSection，复用之
      MarkReturnFlag(MatchCreateLeafAndStep(tkSemiColon));
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildClassVisibility;
begin
  MatchCreateLeafAndStep(FLex.TokenID);
end;

procedure TCnPasAstGenerator.BuildVariantSection;
var
  Bookmark: TCnGeneralLexBookmark;
  HasColon: Boolean;
begin
  MatchCreateLeafAndPush(tkCase, cntVariantSection);

  try
    Lock;
    FLex.SaveToBookmark(Bookmark);

    try
      BuildIdent;
      HasColon := FLex.TokenID = tkColon;
    finally
      FLex.LoadFromBookmark(Bookmark);
      Unlock;
    end;

    if HasColon then
    begin
      BuildIdent;
      MatchCreateLeafAndStep(tkColon);
      BuildTypeID;
    end
    else
      BuildTypeID;

    MatchCreateLeafAndStep(tkOf);
    repeat
      BuildRecVariant;
      if FLex.TokenID = tkSemiColon then
      begin
        MatchCreateLeafAndStep(FLex.TokenID);
        if FLex.TokenID in [tkEnd, tkRoundClose] then
          Break;
      end
      else
        Break;
    until False;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildVarSection;
begin
  if FLex.TokenID in [tkVar, tkThreadvar] then
    MarkReturnFlag(MatchCreateLeafAndPush(FLex.TokenID));

  try
    while FLex.TokenID in [tkIdentifier] do
    begin
      BuildVarDecl;
      MarkReturnFlag(MatchCreateLeafAndStep(tkSemiColon));
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFieldDecl;
begin
  MatchCreateLeafAndPush(tkNone, cntFieldDecl);

  try
    BuildIdentList;
    MatchCreateLeafAndStep(tkColon);
    BuildCommonType;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildProperty;
begin
  MatchCreateLeafAndPush(tkProperty);

  try
    BuildIdent;
    if FLex.TokenID in [tkSquareOpen, tkColon] then
      BuildPropertyInterface;
    BuildPropertySpecifiers;
  finally
    PopLeaf;
  end;

  FReturnRef := MatchCreateLeafAndStep(tkSemiColon);

  if FLex.TokenID = tkDefault then
  begin
    MatchCreateLeafAndStep(FLex.TokenID);
    FReturnRef := MatchCreateLeafAndStep(tkSemiColon);
  end;
  FReturnRef.Return := True;
end;

procedure TCnPasAstGenerator.BuildRecVariant;
begin
  MatchCreateLeafAndPush(tkNone, cntRecVariant);

  try
    repeat
      BuildConstExpression;
      if FLex.TokenID = tkComma then
        MatchCreateLeafAndStep(tkComma)
      else
        Break;
    until False;

    MatchCreateLeafAndStep(tkColon);
    if FLex.TokenID = tkRoundOpen then
    begin
      MatchCreateLeafAndPush(tkRoundOpen);

      try
        BuildFieldList;
      finally
        PopLeaf;
      end;
      MatchCreateLeafAndStep(tkRoundClose);
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildPropertyInterface;
begin
  MatchCreateLeafAndPush(tkNone, cntPropertyInterface);

  try
    if FLex.TokenID <> tkColon then
      BuildPropertyParameterList;
    MatchCreateLeafAndStep(tkColon);
    BuildCommonType;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildPropertySpecifiers;
var
  ID: TTokenKind;
begin
  MatchCreateLeafAndPush(tkNone, cntPropertySpecifiers);

  try
    while FLex.TokenID in PropertySpecifiersTokens do
    begin
      ID := FLex.TokenID;
      MatchCreateLeafAndStep(FLex.TokenID);
      case ID of
        tkDispid:
          begin
            BuildExpression;
          end;
        tkIndex, tkStored, tkDefault:
          begin
            BuildConstExpression;
          end;
        tkRead, tkWrite:
          begin
            BuildDesignator;
          end;
        tkImplements:
          begin
            BuildTypeID;
          end;
        // tkNodefault, tkReadonly, tkWriteonly 直接 Match 掉
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildPropertyParameterList;
begin
  MatchCreateLeafAndPush(tkNone, cntPropertyParameterList);

  try
    MatchCreateLeafAndPush(tkSquareOpen);

    try
      repeat
        if FLex.TokenID in [tkVar, tkConst, tkOut] then
          MatchCreateLeafAndStep(FLex.TokenID); // TODO: 区分 var/const 修饰的内容与 VarSection、ConstSection

        BuildIdentList;
        MatchCreateLeafAndStep(tkColon);
        BuildTypeID;

        if FLex.TokenID <> tkSemiColon then
          Break;
      until False;
    finally
      PopLeaf;
    end;

    MatchCreateLeafAndStep(tkSquareClose);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildVarDecl;
begin
  MatchCreateLeafAndPush(tkNone, cntVarDecl);

  try
    BuildIdentList;
    if FLex.TokenID = tkColon then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildCommonType;
    end;

    if FLex.TokenID = tkEqual then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildTypedConstant;
    end
    else if FLex.TokenID = tkAbsolute then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildConstExpression; // 包括 Ident 的情形
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildTypedConstant;
type
  TCnTypedConstantType = (tcConst, tcArray, tcRecord);
var
  TypedConstantType: TCnTypedConstantType;
  Bookmark: TCnGeneralLexBookmark;
begin
  MatchCreateLeafAndPush(tkNone, cntTypedConstant);

  try
    if FLex.TokenID = tkSquareOpen then
    begin
      BuildSetConstructor;
      while FLex.TokenID in (AddOPTokens + MulOPTokens) do
      begin
        MatchCreateLeafAndStep(FLex.TokenID);
        BuildSetConstructor;
      end;
    end
    else if FLex.TokenID = tkRoundOpen then
    begin
      // TODO: 判断是数组常量还是结构常量
      TypedConstantType := tcConst;
      if ForwardToken = tkRoundOpen then 
      begin
        // 如果后面还是括号，则说明本大类是常量或 array，继续判断
        Lock;
        FLex.SaveToBookmark(Bookmark);

        try
          try
            BuildConstExpression;

            if FLex.TokenID = tkComma then
              TypedConstantType := tcArray
            else if FLex.TokenID = tkSemiColon then
              TypedConstantType := tcConst;
          except
            // 当做常量出错则是数组
            TypedConstantType := tcArray;
          end;
        finally
          FLex.LoadFromBookmark(Bookmark);
          Unlock;
        end;
      end
      else // 如果就一个括号
      begin
        // 判断括号后是否 a: 0 这种形式，括号后常量后冒号表示是结构
        if (ForwardToken() = tkIdentifier) and (ForwardToken(2) = tkColon) then
          TypedConstantType := tcRecord
        else
        begin
          // 否则再判断 ( ConstExpr[, ConstExpr] ); 这种，有逗号、或没逗号但有右括号和分号，都算数组
          Lock;
          FLex.SaveToBookmark(Bookmark);

          try
            MatchCreateLeafAndStep(tkRoundOpen);
            try
              BuildConstExpression;
              if FLex.TokenID = tkComma then // (1, 1) 的情形
                TypedConstantType := tcArray;
              if FLex.TokenID = tkRoundClose then
                MatchCreateLeafAndStep(FLex.TokenID);

              if FLex.TokenID = tkSemicolon then // (1) 的情形
                TypedConstantType := tcArray;
            except
              ;
            end;
          finally
            FLex.LoadFromBookmark(Bookmark);
            Unlock;
          end;
        end;
      end;

      if TypedConstantType = tcArray then
        BuildArrayConstant
      else if TypedConstantType = tcRecord then
        BuildRecordConstant
      else
        BuildConstExpression;
    end
    else
      BuildConstExpression;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildInterfaceHeritage;
begin
  MatchCreateLeafAndPush(tkNone, cntInterfaceHeritage);

  try
    MatchCreateLeafAndPush(tkRoundOpen);
    try
      BuildIdentList;
    finally
      PopLeaf;
    end;
    MarkReturnFlag(MatchCreateLeafAndStep(tkRoundClose));
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildGuid;
begin
  MatchCreateLeafAndPush(tkNone, cntGuid);

  try
    MatchCreateLeafAndPush(tkSquareOpen);
    try
      MatchCreateLeafAndStep(tkString); // 内容是一个字符串
    finally
      PopLeaf;
    end;
    MatchCreateLeafAndStep(tkSquareClose);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildClassMethod;
begin
  if FLex.TokenID = tkClass then
    MatchCreateLeafAndStep(FLex.TokenID);
  BuildMethod;
end;

procedure TCnPasAstGenerator.BuildClassProperty;
begin
  if FLex.TokenID = tkClass then
    MatchCreateLeafAndStep(FLex.TokenID);
  BuildProperty;
end;

procedure TCnPasAstGenerator.BuildConstructorHeading;
begin
  MatchCreateLeafAndPush(tkConstructor);

  try
    BuildIdent;
    if FLex.TokenID = tkRoundOpen then
      BuildFormalParameters;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildDestructorHeading;
begin
  MatchCreateLeafAndPush(tkDestructor);

  try
    BuildIdent;
    if FLex.TokenID = tkRoundOpen then
      BuildFormalParameters;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFormalParameters;
begin
  MatchCreateLeafAndPush(tkNone, cntFormalParameters);

  try
    MatchCreateLeafAndPush(tkRoundOpen);

    try
      if FLex.TokenID <> tkRoundClose then
      begin
        repeat
          BuildFormalParam;
          if FLex.TokenID = tkSemiColon then
            MatchCreateLeafAndStep(FLex.TokenID)
          else
            Break;
        until False;
      end;
    finally
      PopLeaf;
    end;
    MatchCreateLeafAndStep(tkRoundClose);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildFormalParam;
begin
  MatchCreateLeafAndPush(tkNone, cntFormalParam);

  try
    if FLex.TokenID in [tkVar, tkConst, tkOut] then
      MatchCreateLeafAndStep(FLex.TokenID);
    BuildIdentList;

    if FLex.TokenID = tkColon then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      if FLex.TokenID = tkArray then
      begin
        MatchCreateLeafAndStep(tkArray); // 参数的类型中不允许出现 array[0..1] 这种
        MatchCreateLeafAndStep(tkOf);

        if FLex.TokenID in [tkKeyString, tkFile, tkConst] then // array of const 这种
          MatchCreateLeafAndStep(FLex.TokenID);

        if FLex.TokenID = tkRoundOpen then
        begin
          MatchCreateLeafAndPush(FLex.TokenID);
          try
            BuildSubrangeType;
          finally
            PopLeaf;
          end;
          MatchCreateLeafAndStep(tkRoundClose);
        end
        else
        begin
          BuildConstExpression;
          if FLex.TokenID = tkDotDot then
          begin
            MatchCreateLeafAndStep(Flex.TokenID);
            BuildConstExpression;
          end;
        end;
      end
      else if FLex.TokenID in [tkIdentifier, tkKeyString, tkFile] then
        BuildCommonType;

      if FLex.TokenID = tkEqual then
      begin
        MatchCreateLeafAndStep(FLex.TokenID);
        BuildConstExpression;
      end;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildClassHeritage;
begin
  MatchCreateLeafAndPush(tkNone, cntClassHeritage);

  try
    MarkNoSpaceBeforeFlag(MatchCreateLeafAndPush(tkRoundOpen));
    try
      BuildIdentList;
    finally
      PopLeaf;
    end;
    MarkReturnFlag(MatchCreateLeafAndStep(tkRoundClose));
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildClassBody;
begin
  MatchCreateLeafAndPush(tkNone, cntClassBody);

  try
    if FLex.TokenID = tkRoundOpen then
      BuildClassHeritage;

    if FLex.TokenID <> tkSemiColon then
    begin
      BuildClassMemberList;
      MatchCreateLeafAndStep(tkEnd);
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildClassMemberList;
var
  HasVis: Boolean;
begin
  while FLex.TokenID in VisibilityTokens + ClassMemberTokens do
  begin
    HasVis := False;
    if FLex.TokenID in VisibilityTokens then
    begin
      MatchCreateLeafAndPush(FLex.TokenID);
      HasVis := True;
    end;

    try
      BuildClassMembers; // 本 Visibility 里循环 Build 多个
    finally
      if HasVis then
        PopLeaf;
    end;
  end;
end;

procedure TCnPasAstGenerator.BuildClassMembers;
begin
  while FLex.TokenID in ClassMemberTokens do
  begin
    case FLex.TokenID of
      tkProperty:
        BuildClassProperty;
      tkProcedure, tkFunction, tkConstructor, tkDestructor, tkClass:
        BuildClassMethod;
      tkType:
        BuildClassTypeSection;
      tkConst:
        BuildClassConstSection;
    else
      BuildClassField;
    end;
  end;
end;

procedure TCnPasAstGenerator.BuildClassField;
begin
  repeat
    MatchCreateLeafAndPush(tkNone, cntClassField);

    try
      BuildIdentList;
      MatchCreateLeafAndStep(tkColon);
      BuildCommonType;
    finally
      PopLeaf;
    end;

    if FLex.TokenID = tkSemiColon then
      MarkReturnFlag(MatchCreateLeafAndStep(FLex.TokenID));

    if FLex.TokenID <> tkIdentifier then
      Break;
  until False;
end;

procedure TCnPasAstGenerator.BuildConstSection;
begin
  if FLex.TokenID = tkConst then
    MarkReturnFlag(MatchCreateLeafAndPush(tkConst))
  else if FLex.TokenID = tkResourcestring then
    MarkReturnFlag(MatchCreateLeafAndPush(tkResourcestring));

  try
    while FLex.TokenID = tkIdentifier do
    begin
      BuildConstDecl;
      MarkReturnFlag(MatchCreateLeafAndStep(tkSemiColon));
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildConstDecl;
begin
  MatchCreateLeafAndPush(tkNone, cntConstDecl);

  try
    BuildIdent;
    if FLex.TokenID = tkEqual then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildConstExpression;
    end
    else if FLex.TokenID = tkColon then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildCommonType;

      MatchCreateLeafAndStep(tkEqual);
      BuildTypedConstant;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildDirectives(NeedSemicolon: Boolean);
begin
  FReturnRef := nil;
  while FLex.TokenID in DirectiveTokens do
  begin
    BuildDirective;

    if NeedSemicolon and (FLex.TokenID = tkSemiColon) then
      FReturnRef := MatchCreateLeafAndStep(FLex.TokenID);
  end;

  if FReturnRef <> nil then
    FReturnRef.Return := True;
end;

procedure TCnPasAstGenerator.BuildConstExpressionInType;
begin
  MatchCreateLeafAndPush(tkNone, cntConstExpressionInType);

  try
    BuildSimpleExpression;
    while FLex.TokenID in RelOpTokens - [tkEqual, tkGreater, tkLower] do
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildSimpleExpression;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildLibrary;
begin

end;

procedure TCnPasAstGenerator.BuildProgram;
begin
  MatchCreateLeafAndPush(tkProgram);

  try
    BuildIdent;

    if FLex.TokenID = tkRoundOpen then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildIdentList;
      MatchCreateLeafAndStep(tkRoundClose);
    end;

    MarkReturnFlag(MatchCreateLeafAndStep(tkSemiColon));
    BuildProgramBlock;

    MatchCreateLeafAndStep(tkPoint);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildUnit;
begin
  MatchCreateLeafAndPush(tkUnit);

  try
    BuildIdent; // 不支持单元名后 platform 这种

    MarkReturnFlag(MatchCreateLeafAndStep(tkSemiColon));

    BuildInterfaceSection;

    BuildImplementationSection;

    if FLex.TokenID in [tkInitialization, tkBegin] then
      BuildInitSection;

    MatchCreateLeafAndStep(tkEnd);
    MarkReturnFlag(MatchCreateLeafAndStep(tkPoint));
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildProgramBlock;
begin
  while FLex.TokenID = tkUses do
    BuildUsesClause;

  while FLex.TokenID in DeclSectionTokens do
    BuildDeclSection;

  BuildCompoundStatement;
end;

procedure TCnPasAstGenerator.BuildImplementationSection;
begin
  MatchCreateLeafAndPush(tkImplementation);

  try
    while FLex.TokenID = tkUses do
      BuildUsesClause;

    while FLex.TokenID in DeclSectionTokens do
      BuildDeclSection;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildInterfaceSection;
begin
  MarkReturnFlag(MatchCreateLeafAndPush(tkInterface, cntInterfaceSection));

  try
    while FLex.TokenID = tkUses do
      BuildUsesClause;

    while FLex.TokenID in InterfaceDeclTokens do
      BuildInterfaceDecl;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildInitSection;
begin
  MatchCreateLeafAndPush(tkInitialization);

  try
    if FLex.TokenID <> tkFinalization then
      BuildStatementList;
  finally
    PopLeaf;
  end;

  if FLex.TokenID = tkFinalization then
  begin
    MatchCreateLeafAndPush(tkFinalization);

    try
      if FLex.TokenID <> tkEnd then
        BuildStatementList;
    finally
      PopLeaf;
    end;
  end;
end;

procedure TCnPasAstGenerator.BuildDeclSection;
begin
  while FLex.TokenID in DeclSectionTokens do
  begin
    case FLex.TokenID of
      tkLabel:
        BuildLabelDeclSection;
      tkConst, tkResourcestring:
        BuildConstSection;
      tkType:
        BuildTypeSection;
      tkVar, tkThreadvar:
        BuildVarSection;
      tkExports:
        BuildExportsSection;
      tkClass, tkProcedure, tkFunction, tkConstructor, tkDestructor:
        BuildProcedureDeclSection;
    end;
  end;
end;

procedure TCnPasAstGenerator.BuildInterfaceDecl;
begin
  while FLex.TokenID in InterfaceDeclTokens do
  begin
    case FLex.TokenID of
      tkConst, tkResourcestring:
        BuildConstSection;
      tkType:
        BuildTypeSection;
      tkVar, tkThreadvar:
        BuildVarSection;
      tkProcedure, tkFunction:
        BuildExportedHeading;
      tkExports:
        BuildExportsSection;
    end;
  end;
end;

procedure TCnPasAstGenerator.BuildCompoundStatement;
begin
  MatchCreateLeafAndPush(tkNone, cntCompoundStatement);

  try
    if FLex.TokenID = tkBegin then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildStatementList;
      MatchCreateLeafAndStep(tkEnd);
    end
    else if FLex.TokenID = tkAsm then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BulidAsmBlock;
      MatchCreateLeafAndStep(tkEnd);
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildStatementList;
begin
  while FLex.TokenID = tkSemiColon do
    MatchCreateLeafAndStep(FLex.TokenID);

  repeat
    while FLex.TokenID = tkSemiColon do
      MarkReturnFlag(MatchCreateLeafAndStep(FLex.TokenID));

    BuildStatement;

    while FLex.TokenID = tkSemiColon do
      MarkReturnFlag(MatchCreateLeafAndStep(FLex.TokenID));

    if not (FLex.TokenID in StatementTokens) then
      Break;
  until False;
end;

procedure TCnPasAstGenerator.BuildExportsList;
begin
  repeat
    BuildexportsDecl;
    if FLex.TokenID = tkComma then
      MatchCreateLeafAndStep(FLex.TokenID)
    else
      Break;
  until False;
end;

procedure TCnPasAstGenerator.BuildExportsSection;
begin
  MatchCreateLeafAndPush(tkExports);

  try
    BuildExportsList;
    MatchCreateLeafAndStep(tkSemiColon);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildExportsDecl;
begin
  MatchCreateLeafAndPush(tkNone, cntExportDecl);

  try
    BuildIdent;
    if FLex.TokenID = tkRoundOpen then
      BuildFormalParameters;

    if FLex.TokenID = tkColon then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildSimpleType;
    end;

    BuildDirectives(False); // Export 声明里不要处理分号，原因不太明确
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildSimpleType;
begin
  if FLex.TokenID = tkRoundOpen then
    BuildSubrangeType
  else
  begin
    BuildConstExpressionInType;
    if FLex.TokenID = tkDotdot then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildConstExpressionInType;
    end;
  end;
end;

procedure TCnPasAstGenerator.BuildExportedHeading;
begin
  if FLex.TokenID = tkProcedure then
    BuildProcedureHeading
  else if FLex.TokenID = tkFunction then
    BuildFunctionHeading;

  if FLex.TokenID = tkSemiColon then
    MarkReturnFlag(MatchCreateLeafAndStep(FLex.TokenID));

  BuildDirectives;
end;

procedure TCnPasAstGenerator.BuildDirective;
var
  CanExpr: Boolean;
begin
  if FLex.TokenID in DirectiveTokens then
  begin
    CanExpr := FLex.TokenID in DirectiveTokensWithExpressions;
    MatchCreateLeafAndStep(FLex.TokenID);

    if CanExpr and not (FLex.TokenID in DirectiveTokens + [tkSemiColon]) then
      BuildConstExpression;
  end;
end;

procedure TCnPasAstGenerator.BuildRecordConstant;
begin
  MatchCreateLeafAndPush(tkRoundOpen, cntRecordConstant);

  try
    repeat
      BuildRecordFieldConstant;
      if FLex.TokenID = tkSemiColon then  // 末尾的分号可要可不要，不能把没分号作为结束的标记，只能用右括号
        MatchCreateLeafAndStep(FLex.TokenID);

      if FLex.TokenID = tkRoundClose then
        Break;
    until False;
  finally
    PopLeaf;
  end;
  MatchCreateLeafAndStep(tkRoundClose);
end;

procedure TCnPasAstGenerator.BuildArrayConstant;
begin
  MatchCreateLeafAndPush(tkRoundOpen, cntArrayConstant);

  try
    repeat
      BuildTypedConstant;
      if FLex.TokenID = tkComma then
        MatchCreateLeafAndStep(FLex.TokenID)
      else
        Break;
    until False;
  finally
    PopLeaf;
  end;
  MatchCreateLeafAndStep(tkRoundClose);
end;

procedure TCnPasAstGenerator.BuildRecordFieldConstant;
begin
  MatchCreateLeafAndPush(tkNone, cntRecordFieldConstant);

  try
    BuildIdent;
    MatchCreateLeafAndStep(tkColon);
    BuildTypedConstant;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildStatement;
begin
  MatchCreateLeafAndPush(tkNone, cntStatememt);

  try
    if ForwardToken() = tkColon then
    begin
      BuildLabelId;
      MatchCreateLeafAndStep(tkColon);
    end;

    if FLex.TokenID in SimpleStatementTokens then
      BuildSimpleStatement
    else if FLex.TokenID in StructStatementTokens then
      BuildStructStatement;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildStructStatement;
begin
  case FLex.TokenID of
    tkBegin, tkAsm:  BuildCompoundStatement;
    tkIf:     BuildIfStatement;
    tkCase:   BuildCaseStatement;
    tkRepeat: BuildRepeatStatement;
    tkWhile:  BuildWhileStatement;
    tkFor:    BuildForStatement;
    tkWith:   BuildWithStatement;
    tkTry:    BuildTryStatement;
    tkRaise:  BuildRaiseStatement;
  end;
end;

procedure TCnPasAstGenerator.BuildCaseStatement;
begin
  MatchCreateLeafAndPush(tkCase);

  try
    BuildExpression;
    MatchCreateLeafAndStep(tkOf);

    repeat
      BuildCaseSelector;

      if FLex.TokenID = tkSemiColon then
        MarkReturnFlag(MatchCreateLeafAndStep(FLex.TokenID));

      if FLex.TokenID in [tkElse, tkEnd] then
        Break;
    until False;

    if FLex.TokenID = tkElse then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      if FLex.TokenID <> tkEnd then
        BuildStatementList;
    end;

    if FLex.TokenID = tkSemiColon then
      MarkReturnFlag(MatchCreateLeafAndStep(FLex.TokenID));

    MatchCreateLeafAndStep(tkEnd);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildForStatement;
begin
  MatchCreateLeafAndPush(tkFor);

  try
    BuildQualId; // 不支持现场申明 var

    if FLex.TokenID = tkAssign then
    begin
      MatchCreateLeafAndStep(tkAssign);
      BuildExpression;

      if FLex.TokenID in [tkTo, tkDownto] then
      begin
        MatchCreateLeafAndStep(FLex.TokenID);
        BuildExpression;
        MatchCreateLeafAndStep(tkDo);
        BuildStatement;
      end;
    end
    else if FLex.TokenID = tkIn then
    begin
      BuildExpression;
      MatchCreateLeafAndStep(tkDo);
      BuildStatement;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildIfStatement;
begin
  MatchCreateLeafAndPush(tkIf);

  try
    BuildExpression;
    MatchCreateLeafAndStep(tkThen);
    BuildStatement;

    if FLex.TokenID = tkElse then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      if FLex.TokenID = tkIf then
        BuildIfStatement
      else
        BuildStatement;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildRaiseStatement;
begin
  MatchCreateLeafAndPush(tkRaise);

  try
    BuildExpression;

    if FLex.TokenID = tkAt then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildExpression;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildRepeatStatement;
begin
  MatchCreateLeafAndPush(tkRepeat);

  try
    BuildStatementList;
    MatchCreateLeafAndStep(tkUntil);
    BuildExpression;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildTryStatement;
begin
  MatchCreateLeafAndPush(tkTry);

  try
    BuildStatementList;
    if not (FLex.TokenID in [tkExcept, tkFinally]) then
      BuildStatementList;

    if FLex.TokenID = tkFinally then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildStatementList;
      MatchCreateLeafAndStep(tkEnd);
    end
    else if FLex.TokenID = tkExcept then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      if FLex.TokenID <> tkEnd then
      begin
        if FLex.TokenID in [tkOn, tkElse] then
        begin
          while FLex.TokenID = tkOn do
            BuildExceptionHandler;

          if FLex.TokenID = tkElse then
            BuildStatementList;

          if FLex.TokenID = tkSemiColon then
            MarkReturnFlag(MatchCreateLeafAndStep(tkSemiColon));
        end
        else
          BuildStatementList;
      end;

      MatchCreateLeafAndStep(tkEnd);
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildWhileStatement;
begin
  MatchCreateLeafAndPush(tkWhile);

  try
    BuildExpression;
    MatchCreateLeafAndStep(tkDo);
    BuildStatement;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildWithStatement;
begin
  MatchCreateLeafAndPush(tkWith);

  try
    BuildExpressionList;
    MatchCreateLeafAndStep(tkDo);
    BuildStatement;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildExceptionHandler;
begin
  MatchCreateLeafAndPush(tkOn);

  try
    BuildIdent;
    if FLex.TokenID = tkColon then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildIdent;
    end;

    MatchCreateLeafAndStep(tkDo);
    BuildStatement;

    if FLex.TokenID = tkSemiColon then
      MarkReturnFlag(MatchCreateLeafAndStep(FLex.TokenID));
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildCaseSelector;
begin
  MatchCreateLeafAndPush(tkNone, cntCaseSelector);

  try
    repeat
      BuildCaseLabel;
      if FLex.TokenID = tkComma then
        MatchCreateLeafAndStep(FLex.TokenID)
      else
        Break;
    until False;

    MarkReturnFlag(MatchCreateLeafAndStep(tkColon));
    BuildStatement;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildCaseLabel;
begin
  MatchCreateLeafAndPush(tkNone, cntCaseLabel);

  try
    BuildConstExpression;
    if FLex.TokenID = tkDotdot then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildConstExpression;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildLabelDeclSection;
begin
  MatchCreateLeafAndPush(tkLabel);

  try
    repeat
      BuildLabelId;
      if FLex.TokenID <> tkComma then
        Break;
    until False;

    MarkReturnFlag(MatchCreateLeafAndStep(tkSemiColon));
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildProcedureDeclSection;
begin
  if FLex.TokenID = tkClass then
    MatchCreateLeafAndStep(FLex.TokenID);

  case FLex.TokenID of
    tkProcedure, tkConstructor, tkDestructor, tkFunction:
      BuildProcedureFunctionDecl;
  end;
end;

procedure TCnPasAstGenerator.BuildProcedureFunctionDecl;
var
  IsExternal: Boolean;
  IsForward: Boolean;
begin
  MatchCreateLeafAndPush(tkNone, cntProcedureFunctionDecl);

  try
    if FLex.TokenID = tkFunction then
      BuildFunctionHeading
    else
      BuildProcedureHeading;

    if FLex.TokenID = tkSemiColon then
      MarkReturnFlag(MatchCreateLeafAndStep(FLex.TokenID));

    IsExternal := False;
    IsForward := False;

    while FLex.TokenID in DirectiveTokens do
    begin
      if FLex.TokenID = tkExternal then
        IsExternal := True
      else if FLex.TokenID = tkForward then
        IsForward := True;

      BuildDirective;
      if FLex.TokenID = tkSemiColon then
        MatchCreateLeafAndStep(FLex.TokenID);
    end;

    if ((not IsExternal)  and (not IsForward)) and
       (FLex.TokenID in [tkBegin, tkAsm] + DeclSectionTokens) then
    begin
      BuildBlock;
      if FLex.TokenID = tkSemicolon then
        MarkReturnFlag(MatchCreateLeafAndStep(FLex.TokenID));
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.BuildBlock;
begin
  while FLex.TokenID in DeclSectionTokens do
    BuildDeclSection;

  BuildCompoundStatement;
end;

procedure TCnPasAstGenerator.BuildClassConstantDecl;
begin
  MatchCreateLeafAndPush(tkNone, cntClassConstantDecl);

  try
    BuildIdent;

    if FLex.TokenID = tkEqual then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildConstExpression;
    end
    else if FLex.TokenID = tkColon then
    begin
      MatchCreateLeafAndStep(FLex.TokenID);
      BuildCommonType;

      MatchCreateLeafAndStep(tkEqual);
      BuildTypedConstant;
    end;

    BuildDirectives(False);
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.SkipComments;
begin
  while FLex.TokenID in SpaceTokens + CommentTokens do
  begin
    if FLex.TokenID in CommentTokens then
      MatchCreateLeaf(FLex.TokenID); // 里头没有 NextToken

    FLex.Next;
  end;
end;

procedure TCnPasAstGenerator.BulidAsmBlock;
var
  T: TCnPasAstLeaf;
begin
  if FLex.TokenID = tkEnd then
    Exit;

  T := MatchCreateLeafAndPush(tkNone, cntAsmBlock);
  try
    while FLex.TokenID <> tkEnd do
    begin
      if T <> nil then
        T.Text := T.Text + FLex.Token;
      FLex.Next;
    end;
  finally
    PopLeaf;
  end;
end;

procedure TCnPasAstGenerator.MarkReturnFlag(ALeaf: TCnPasAstLeaf);
begin
  if ALeaf <> nil then
    ALeaf.Return := True;
end;

procedure TCnPasAstGenerator.MarkNoSpaceBehindFlag(ALeaf: TCnPasAstLeaf);
begin
  if ALeaf <> nil then
    ALeaf.NoSpaceBehind := True;
end;

procedure TCnPasAstGenerator.MarkNoSpaceBeforeFlag(ALeaf: TCnPasAstLeaf);
begin
  if ALeaf <> nil then
    ALeaf.NoSpaceBefore := True;
end;

{ TCnPasAstTree }

function TCnPasAstTree.ConvertToCppCode: string;
begin
  // 把 implementation 部分整成 cpp 文件
end;

function TCnPasAstTree.ConvertToHppCode: string;
begin
  // 把 interface 部分整成 h 文件
end;

function TCnPasAstTree.GetItems(AbsoluteIndex: Integer): TCnPasAstLeaf;
begin
  Result := TCnPasAstLeaf(inherited GetItems(AbsoluteIndex));
end;

function TCnPasAstTree.GetRoot: TCnPasAstLeaf;
begin
  Result := TCnPasAstLeaf(inherited GetRoot);
end;

function TCnPasAstTree.ReConstructPascalCode: string;
begin
  Result := (FRoot as TCnPasAstLeaf).GetPascalCode;
end;

{ TCnPasAstLeaf }

function TCnPasAstLeaf.ConvertNumber: string;
begin
  Result := Text;
end;

function TCnPasAstLeaf.ConvertQualId: string;
begin

end;

function TCnPasAstLeaf.ConvertString: string;
var
  P: PChar;
  I: Integer;
  SB: TCnStringBuilder;
begin
  // 扫描内部单引号和#等，转换成 C 风格的字符串输出
  P := @Text[1];
  I := 0;
  SB := TCnStringBuilder.Create;

  try
    while P[I] <> #0 do
    begin
      case P[I] of
        '''':
          begin
            // 单引号
            if P[I + 1] = '''' then // 连续两个单引号代表一个单引号
            begin
              SB.Append('''');
              Inc(I);
            end;
          end;
        '#':
          begin
            // # 号
            SB.Append('\');
            if P[I + 1] = '$' then
            begin
              SB.Append('0x');
              Inc(I);
            end;
          end;
        '"':  // 双引号，C 字符串中要转义
          begin
            SB.Append('\');
            SB.Append('"');
          end;
      else
        SB.Append(P[I]);
      end;
      Inc(I);
    end;

    SB.Append('"');
    Result := '"' + SB.ToString;
  finally
    SB.Free;
  end;
end;

function TCnPasAstLeaf.GetCppCode: string;
begin
  case FTokenKind of // 基础数据类型和基础关键字
    tkString, tkAsciiChar:
      begin
        Result := ConvertString;
      end;
    tkNumber, tkFloat:
      begin
        Result := ConvertNumber;
      end;
    tkPlus, tkMinus, tkStar, tkSlash, tkRoundOpen, tkRoundClose, tkSquareOpen, tkSquareClose, tkPoint:
      Result := Text; // 四则运算符号，小括号、中括号不变
    tkGreater, tkGreaterEqual, tkLower, tkLowerEqual:
      Result := Text; // 这四个比较符号不变
    tkNotEqual:
      Result := '!=';  // 不等于
    tkEqual:
      Result := '==';
    tkDiv:
      Result := '\';
    tkMod:
      Result := '%';
    tkShl:
      Result := '<<';
    tkShr:
      Result := '>>';
    tkAssign:
      Result := '=';
    tkAnd:
      begin

      end;
    tkOr:
      begin

      end;
    tkNot:
      begin

      end;
    tkXor:
      Result := '^';
    tkNil:
      Result := 'NULL';
  end;

  if Result <> '' then
    Exit;

  case FNodeType of
    cntQualId:
      begin
        Result := ConvertQualId;
      end;
  end;
end;

function TCnPasAstLeaf.GetItems(AIndex: Integer): TCnPasAstLeaf;
begin
  Result := TCnPasAstLeaf(inherited GetItems(AIndex));
end;

function TCnPasAstLeaf.GetParent: TCnPasAstLeaf;
begin
  Result := TCnPasAstLeaf(inherited GetParent);
end;

function TCnPasAstLeaf.GetPascalCode: string;
var
  I: Integer;
  S: string;
  Prev, Son: TTokenKind;
  NSP: Boolean;
begin
  if FReturn or (FTokenKind in [tkBorComment, tkAnsiComment, tkSlashesComment, // 注释都暂且先换行
    tkBegin, tkThen, tkDo, tkRepeat,                                           // 这些后面都换行
    tkExcept, tkExports, tkFinally, tkInitialization, tkFinalization, tkAsm,
    tkImplementation, tkRecord, tkPrivate, tkProtected, tkPublic, tkPublished]) then
    Result := Text + #13#10
  else
    Result := Text;

  for I := 0 to Count - 1 do
  begin
    Son := Items[I].TokenKind;
    S := Items[I].GetPascalCode;
    if Result = '' then
      Result := S
    else if S <> '' then
    begin
      if I = 0 then
        Prev := FTokenKind
      else
        Prev := Items[I - 1].TokenKind;

      NSP := FNoSpaceBehind or Items[I].NoSpaceBefore or    // 如果本节点后面不要空格，或当前子节点前面不要空格
        (Prev in [tkRoundOpen, tkSquareOpen, tkPoint, tkDotDot]) or            // 前一个节点如果是这些，则前一个节点后面不要空格
        (Son in [tkPoint, tkDotdot, tkPointerSymbol, tkSemiColon, tkColon, // 当前子节点如果是这些，则当前子节点前面不要空格
        tkRoundClose, tkSquareClose, tkComma]);

      if not NSP then
      begin
        // 还有些 FuncCall(  class(  array[ 的不要空格，没法单独处理，这里额外处理
        if ((Prev in [tkClass, tkIdentifier]) and (Son in [tkRoundOpen]))
          or ((Prev in [tkArray]) and (Son in [tkSquareOpen])) then
          NSP := True;
      end;

      if NSP then
        Result := Result + S
      else
        Result := Result + ' ' + S;
    end;
  end;
end;

procedure TCnPasAstLeaf.SetItems(AIndex: Integer;
  const Value: TCnPasAstLeaf);
begin
  inherited SetItems(AIndex, Value);
end;

end.
