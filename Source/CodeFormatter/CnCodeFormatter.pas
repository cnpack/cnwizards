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

unit CnCodeFormatter;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：格式化专家核心类 CnCodeFormater
* 单元作者：CnPack 开发组
* 备    注：该单元实现了代码格式化的核心类
*
*           保留换行时如果某些语句没有注释但换行后顶格了没正确缩进，八成是少了一句
*           FCurrentTab := PreSpaceCount; 得加上以让换行时缩进正确的格数
*
*           保留换行时如果某些语句内部因为注释会多出空行来，八成是 IsInStatement
*           或 IsInOpStatement 对注释前的符号判断是否在语句内有误导致没删除回车换行
*
*           如果语句间不因注释等，单纯多出现了空行，跟到 DoBlankLinesWhenSkip 多输出了空行
*           则八成是外部应设 KeepOneBlankLine 为 False，而被嵌套的给盖掉了
*
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 修改记录：2003.12.16 V0.4
*               最初级的实现，巨大的工作量，使用递归下降分析法基本完整的实现了
*               Delphi 5 的 Object Pascal 语法解析。代码格式上包括代码缩进、关
*               键字大小写的设置。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Windows, Dialogs, Contnrs, CnHashMap,
  CnTokens, CnScanners, CnCodeGenerators, CnCodeFormatRules, CnFormatterIntf;

const
  CN_MATCHED_INVALID = -1;

type
  TCnGoalType = (gtUnknown, gtProgram, gtLibrary, gtUnit, gtPackage);

  TCnElementStack = class(TStack)
  public
    function Contains(ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
  end;

  TCnIdentBackupObj = class(TObject)
  private
    FOldUpperIdent: string;
    FOldRealIdent: string;
  public
    property OldUpperIdent: string read FOldUpperIdent write FOldUpperIdent;
    property OldRealIdent: string read FOldRealIdent write FOldRealIdent;
  end;

  TCnAbstractCodeFormatter = class
  private
    FScanner: TAbstractScanner;
    FCodeGen: TCnCodeGenerator;
    FLastToken: TPascalToken;           // 上一个 Token，不包括注释
    FLastNonBlankToken: TPascalToken;   // 上一个非空 Token
    FInternalRaiseException: Boolean;
    FSliceMode: Boolean;
    FMatchedInStart: Integer;
    FMatchedOutStartRow: Integer;
    FMatchedOutStartCol: Integer;
    FMatchedOutEndCol: Integer;
    FMatchedInEnd: Integer;
    FMatchedOutEndRow: Integer;
    FFirstMatchStart: Boolean;
    FFirstMatchEnd: Boolean;
    // 用来粗略记录当前正在格式化的点，以备输出时根据场景判断是否使用关键字规则
    FOldElementTypes: TCnElementStack;
    FElementType: TCnPascalFormattingElementType;
    FLastElementType: TCnPascalFormattingElementType;
    FPrefixSpaces: Integer;
    FEnsureOneEmptyLine: Boolean;
    FTrimAfterSemicolon: Boolean;   // 用来控制本行分号后仍有其他内容的情形
    FNamesMap: TCnStrToStrHashMap;
    FDisableCorrectName: Boolean;
    FInputLineMarks: TList;         // 源与结果的行映射关系中的源行
    FOutputLineMarks: TList;        // 源与结果的行映射关系中的结果行
    FNeedKeepLineBreak: Boolean;    // 控制当前区域是否属于可保留换行的区域，为 True 时表示遇到换行事件时会照例写入换行，一般在分号后会切回 False
    FCurrentTab: Integer;           // 保留换行时记录当前语句应该的缩进
    FLineBreakKeepStack: TStack;    // 保留换行标记的栈
    function ErrorTokenString: string;
    procedure CodeGenAfterWrite(Sender: TObject; IsWriteBlank: Boolean;
      IsWriteln: Boolean; PrefixSpaces: Integer);
    function CodeGenGetInIgnore(Sender: TObject): Boolean;

    // 区分当前的位置，必须配对使用
    procedure SpecifyElementType(Element: TCnPascalFormattingElementType);
    procedure RestoreElementType;
    // 区分当前位置并恢复，必须配对使用
    function UpperContainElementType(ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
    // 上层是否包含指定的几个 ElementType 之一，不包括当前
    function CurrentContainElementType(ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
    // 上层与当前是否包含指定的几个 ElementType 之一

    procedure ResetElementType;
    function CalcNeedPadding: Boolean; // 判断是否因为碰到行注释导致额外换行时需要和上一行对齐
    function CalcNeedPaddingAndUnIndent: Boolean;
    procedure WriteOneSpace;
  protected
    FIsTypeID: Boolean;
    {* 错误处理函数 }
    procedure Error(const Ident: Integer);
    procedure ErrorFmt(const Ident: Integer; const Args: array of const);
    procedure ErrorStr(const Message: string);
    procedure ErrorToken(Token: TPascalToken);
    procedure ErrorTokens(Tokens: array of TPascalToken);
    procedure ErrorExpected(Str: string);
    procedure ErrorNotSurpport(FurtureStr: string);

    function CanKeepLineBreak: Boolean; // 返回当前能否保留用户的换行，受全局选项以及当前代码位置控制

    procedure CheckHeadComments;
    {* 处理代码开始之前的注释}
    function CanBeSymbol(Token: TPascalToken): Boolean;
    procedure Match(Token: TPascalToken; BeforeSpaceCount: Byte = 0;
      AfterSpaceCount: Byte = 0; IgnorePreSpace: Boolean = False;
      SemicolonIsLineStart: Boolean = False; NoSeparateSpace: Boolean = False);
    procedure MatchOperator(Token: TPascalToken); //操作符
    procedure WriteToken(Token: TPascalToken; BeforeSpaceCount: Byte = 0;
      AfterSpaceCount: Byte = 0; IgnorePreSpace: Boolean = False;
      SemicolonIsLineStart: Boolean = False; NoSeparateSpace: Boolean = False;
      const AlterativeStr: string = '');

    function CheckIdentifierName(const S: string): string;
    {* 检查给定字符串是否是一个外部指定的标识符，如果是则返回正确的格式 }
    function Tab(PreSpaceCount: Byte = 0; CareBeginBlock: Boolean = True): Byte;
    {* 根据代码格式风格设置返回缩进一次的前导空格数。
       CareBeginBlock 用于处理当后面是 begin 时，begin 是否需要缩进。如 if then
       后的 begin 无需缩进，而 try 后的 begin 则需要缩进。 }
    function BackTab(PreSpaceCount: Byte = 0; CareBeginBlock: Boolean = True): Integer;
    {* 根据代码格式风格设置返回上一次缩进的前导空格数 }
    function Space(Count: Word): string;
    {* 返回指定数目空格的字符串 }
    procedure Writeln;
    {* 格式结果换行，有各种复杂逻辑 }
    procedure EnsureWriteln;
    {* 不在忽略区里的话，根据格式结果上一行是否为空的内容，保证换且只换一行}
    procedure CheckKeepLineBreakWriteln;
    {* 根据是否保留换行的选项决定是硬换一行还是保证换且只换一行}
    procedure EnsureWriteLine;
    {* 不在忽略区里的话，根据格式结果上一行是否为空的内容，保证只生成一空行}
    procedure WriteLine;
    {* 格式结果加一空行，也就是连续两个换行}
    procedure EnsureOneEmptyLine;
    {* 格式结果保证当前出现一空行}
    procedure WriteBlankLineByPrevCondition;
    {* 根据上一次是否输出了批量空行来决定本次输出单个回车还是双回车的空行，某些场合用来取代 WriteLine}
    procedure WriteLineFeedByPrevCondition;
    {* 根据上一次是否输出了批量空行来决定本次输出不换行还是单个回车，某些场合用来取代 Writeln}
    function FormatString(const KeywordStr: string; KeywordStyle: TCnKeywordStyle): string;
    {* 返回指定关键字风格的字符串}
    function UpperFirst(const KeywordStr: string): string;
    {* 返回首字母大写的字符串}
    property CodeGen: TCnCodeGenerator read FCodeGen;
    {* 目标代码生成器}
    property Scanner: TAbstractScanner read FScanner;
    {* 词法扫描器}
    property ElementType: TCnPascalFormattingElementType read FElementType;
    {* 标识当前区域的一个辅助变量}
    property LastElementType: TCnPascalFormattingElementType read FLastElementType;
    {* 标识前一个当前区域的一个辅助变量}
  public
    constructor Create(AStream: TStream; AMatchedInStart: Integer = CN_MATCHED_INVALID;
      AMatchedInEnd: Integer = CN_MATCHED_INVALID;
      ACompDirectiveMode: TCnCompDirectiveMode = cdmAsComment); virtual;
    {* 构造函数，Stream 内部不需要字符串末尾的#0，这点不同于代码高亮解析等}
    destructor Destroy; override;

    procedure SpecifyIdentifiers(Names: PLPSTR); overload;
    {* 以 PPAnsiChar 方式传入的字符指针数组，用来指定特定符号的大小写}
    procedure SpecifyIdentifiers(Names: TStrings); overload;
    {* 以 TStrings 方式传入的字符串，用来指定特定符号的大小写}
    procedure SpecifyLineMarks(Marks: PDWORD);
    {* 以 PDWORD 指向数组的方式传入的源文件的行映射的行，内部复制数组内容保存，
      行号以 1 开始}

    procedure FormatCode(PreSpaceCount: Byte = 0); virtual; abstract;
    procedure SaveToFile(FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToStrings(AStrings: TStrings);
    procedure SaveOutputLineMarks(var Marks: PDWORD);
    {* 将格式化结果中的行映射结果复制到数组中，数组指针在过程内创建，
      须在外界释放，行号以 1 开始}

    property SliceMode: Boolean read FSliceMode write FSliceMode;
    {* 片段模式，供外界控制。为 True 时碰到 EOF 应该平常退出而不报错}
    property MatchedInStart: Integer read FMatchedInStart write FMatchedInStart;
    {* 当需要 Scaner 输出到此起始位置时触发事件时设置，用于片断模式}
    property MatchedInEnd: Integer read FMatchedInEnd write FMatchedInEnd;
    {* 当需要 Scaner 输出到此结束位置时触发事件时设置，用于片断模式}

    property MatchedOutStartRow: Integer read FMatchedOutStartRow write FMatchedOutStartRow;
    property MatchedOutStartCol: Integer read FMatchedOutStartCol write FMatchedOutStartCol;
    property MatchedOutEndRow: Integer read FMatchedOutEndRow write FMatchedOutEndRow;
    property MatchedOutEndCol: Integer read FMatchedOutEndCol write FMatchedOutEndCol;

    property InputLineMarks: TList read FInputLineMarks;
    property OutputLineMarks: TList read FOutputLineMarks;
  end;

  TCnBasePascalFormatter = class(TCnAbstractCodeFormatter)
  private
    FGoalType: TCnGoalType;
    FNextBeginShouldIndent: Boolean; // 控制是否本 begin 必须换行即使设置为 SameLine
    FStructStmtEmptyEnd: Boolean;    // 标记结构语句的结束语句是否是空语句，用来控制后面单个分号的位置
    FStoreIdent: Boolean;            // 控制是否把标识符存入大小写控制的 HashMap 中供后文使用
    FIdentBackupListRef: TObjectList; // 指向当前用来存储备份 HashMap 中的内容的 ObjectList，元素是 TCnIdentBackupObj
    FIsSingleStatement: Boolean;
    procedure CheckAddIdentBackup(List: TObjectList; const Ident: string);
    procedure RestoreIdentBackup(List: TObjectList);
    function IsTokenAfterAttributesInSet(InTokens: TPascalTokenSet): Boolean;
    procedure CheckWriteBeginln;
    function CheckSingleStatementBegin(PreSpaceCount: Byte = 0): Boolean;
    procedure CheckSingleStatementEnd(IsSingle: Boolean; PreSpaceCount: Byte = 0);
  protected
    function FormatPossibleAmpersand(PreSpaceCount: Byte = 0): Boolean;
    // 返回是否有&

    // IndentForAnonymous 参数用来控制内部可能出现的匿名函数的缩进
    procedure FormatExprList(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0; SupportColon: Boolean = False);
    procedure FormatExpression(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatSimpleExpression(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatTerm(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatFactor(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatDesignator(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatDesignatorList(PreSpaceCount: Byte = 0);
    procedure FormatQualID(PreSpaceCount: Byte = 0);
    procedure FormatTypeID(PreSpaceCount: Byte = 0);
    procedure FormatIdent(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True);
    procedure FormatIdentList(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True);
    procedure FormatConstExpr(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatConstExprInType(PreSpaceCount: Byte = 0);
    procedure FormatSetConstructor(PreSpaceCount: Byte = 0);

    // 泛型支持
    procedure FormatFormalTypeParamList(PreSpaceCount: Byte = 0);
    function FormatTypeParams(PreSpaceCount: Byte = 0; AllowFixEndGreateEqual: Boolean = False): Boolean;
    // AllowFixEndGreateEqual 用来处理泛型结尾 >= 的情况，返回 True 表示遇到了 >=
    procedure FormatTypeParamDeclList(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamDecl(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamList(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamIdentList(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamIdent(PreSpaceCount: Byte = 0);

    // Anonymouse function support moving
    procedure FormatProcedureDecl(PreSpaceCount: Byte = 0; IsAnonymous: Boolean = False);
    procedure FormatFunctionDecl(PreSpaceCount: Byte = 0; IsAnonymous: Boolean = False);
    {* 用 AllowEqual 区分 ProcType 和 ProcDecl 可否带等于号的情形}
    procedure FormatFunctionHeading(PreSpaceCount: Byte = 0; AllowEqual: Boolean = True);
    procedure FormatProcedureHeading(PreSpaceCount: Byte = 0; AllowEqual: Boolean = True);
    procedure FormatMethodName(PreSpaceCount: Byte = 0);
    procedure FormatFormalParameters(PreSpaceCount: Byte = 0);
    procedure FormatFormalParm(PreSpaceCount: Byte = 0);
    procedure FormatParameter(PreSpaceCount: Byte = 0);
    function FormatSimpleType(PreSpaceCount: Byte = 0): Boolean; // 返回是否泛型 >= 结尾
    procedure FormatSubrangeType(PreSpaceCount: Byte = 0);
    procedure FormatDirective(PreSpaceCount: Byte = 0; IgnoreFirst: Boolean = False);
    procedure FormatBlock(PreSpaceCount: Byte = 0; IsInternal: Boolean = False;
      MultiCompound: Boolean = False);
    // MultiCompound 控制可处理多个并列的 begin end，但易和 program/library 的主 begin end 混淆，
    // 并且容易和嵌套的过程函数混淆，所以目前暂时不用

    procedure FormatProgramInnerBlock(PreSpaceCount: Byte = 0; IsInternal: Boolean = False;
      IsLib: Boolean = False);
    // Program 中的主 begin end 之前的声明不同于嵌套 fucntion 这种声明，因此此处独立

    procedure FormatDeclSection(PreSpaceCount: Byte; IndentProcs: Boolean = True;
      IsInternal: Boolean = False);

    procedure FormatCompoundStmt(PreSpaceCount: Byte = 0);
    procedure FormatStmtList(PreSpaceCount: Byte = 0);
    procedure FormatAsmBlock(PreSpaceCount: Byte = 0);
    procedure FormatStatement(PreSpaceCount: Byte = 0);
    procedure FormatLabel(PreSpaceCount: Byte = 0);
    procedure FormatSimpleStatement(PreSpaceCount: Byte = 0);
    procedure FormatStructStmt(PreSpaceCount: Byte = 0);
    procedure FormatIfStmt(PreSpaceCount: Byte = 0; AfterElseIgnorePreSpace: Boolean = False);
    {* IgnorePreSpace 是为了控制 else if 的情形}
    procedure FormatCaseLabel(PreSpaceCount: Byte = 0);
    procedure FormatCaseSelector(PreSpaceCount: Byte = 0);
    procedure FormatCaseStmt(PreSpaceCount: Byte = 0);
    procedure FormatRepeatStmt(PreSpaceCount: Byte = 0);
    procedure FormatWhileStmt(PreSpaceCount: Byte = 0);
    procedure FormatForStmt(PreSpaceCount: Byte = 0);
    procedure FormatWithStmt(PreSpaceCount: Byte = 0);
    procedure FormatTryStmt(PreSpaceCount: Byte = 0);
    procedure FormatTryEnd(PreSpaceCount: Byte = 0);
    procedure FormatExceptionHandler(PreSpaceCount: Byte = 0);
    procedure FormatRaiseStmt(PreSpaceCount: Byte = 0);

    procedure FormatLabelDeclSection(PreSpaceCount: Byte = 0);
    procedure FormatConstSection(PreSpaceCount: Byte = 0);
    procedure FormatConstantDecl(PreSpaceCount: Byte = 0);
    procedure FormatVarSection(PreSpaceCount: Byte = 0; IsGlobal: Boolean = False);
    // IsGlobal 表示是全局的 interface 部分或 implementation 部分的 var，还是局部的 var
    procedure FormatVarDecl(PreSpaceCount: Byte = 0);
    procedure FormatInlineVarDecl(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatProcedureDeclSection(PreSpaceCount: Byte = 0);
    procedure FormatSingleAttribute(PreSpaceCount: Byte = 0; LineEndSpaceCount: Byte = 0);
    procedure FormatType(PreSpaceCount: Byte = 0; IgnoreDirective: Boolean = False);
    procedure FormatSetType(PreSpaceCount: Byte = 0);
    procedure FormatFileType(PreSpaceCount: Byte = 0);
    procedure FormatPointerType(PreSpaceCount: Byte = 0);
    procedure FormatProcedureType(PreSpaceCount: Byte = 0);

    procedure FormatRestrictedType(PreSpaceCount: Byte = 0);
    procedure FormatClassRefType(PreSpaceCount: Byte = 0);
    procedure FormatOrdinalType(PreSpaceCount: Byte = 0; FromSetOf: Boolean = False);
    procedure FormatEnumeratedType(PreSpaceCount: Byte = 0);
    procedure FormatEnumeratedList(PreSpaceCount: Byte = 0);
    procedure FormatEmumeratedIdent(PreSpaceCount: Byte = 0);
    procedure FormatStringType(PreSpaceCount: Byte = 0);
    procedure FormatStructType(PreSpaceCount: Byte = 0);
    procedure FormatArrayType(PreSpaceCount: Byte = 0);
    procedure FormatRecType(PreSpaceCount: Byte = 0);
    function FormatFieldList(PreSpaceCount: Byte = 0; IgnoreFirst: Boolean = False): Boolean; // 返回结构的内部是否包含 case 变体
    procedure FormatTypeSection(PreSpaceCount: Byte = 0);
    procedure FormatTypeDecl(PreSpaceCount: Byte = 0);
    procedure FormatTypedConstant(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);

    procedure FormatArrayConstant(PreSpaceCount: Byte = 0);
    procedure FormatRecordConstant(PreSpaceCount: Byte = 0);
    procedure FormatRecordFieldConstant(PreSpaceCount: Byte = 0);

    {* 处理 record 中 case 内部的首行无需缩进的问题}
    procedure FormatFieldDecl(PreSpaceCount: Byte = 0);
    procedure FormatVariantSection(PreSpaceCount: Byte = 0);
    procedure FormatRecVariant(PreSpaceCount: Byte = 0; IgnoreFirst: Boolean = False);

    procedure FormatObjectType(PreSpaceCount: Byte = 0);
    procedure FormatObjHeritage(PreSpaceCount: Byte = 0);
    procedure FormatMethodList(PreSpaceCount: Byte = 0);
    procedure FormatMethodHeading(PreSpaceCount: Byte = 0; HasClassPrefixForVar: Boolean = True);
    procedure FormatConstructorHeading(PreSpaceCount: Byte = 0);
    procedure FormatDestructorHeading(PreSpaceCount: Byte = 0);
    procedure FormatVarDeclHeading(PreSpaceCount: Byte = 0; IsClassVar: Boolean = True);
    procedure FormatClassVarIdentList(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True);
    procedure FormatClassVarIdent(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True);
    procedure FormatObjFieldList(PreSpaceCount: Byte = 0);
    procedure FormatClassType(PreSpaceCount: Byte = 0);
    procedure FormatClassHeritage(PreSpaceCount: Byte = 0);
    procedure FormatClassVisibility(PreSpaceCount: Byte = 0);

    // fixed grammer
    procedure FormatClassBody(PreSpaceCount: Byte = 0);
    procedure FormatClassMemberList(PreSpaceCount: Byte = 0);
    procedure FormatClassMember(PreSpaceCount: Byte = 0);
    procedure FormatClassField(PreSpaceCount: Byte = 0);
    procedure FormatClassMethod(PreSpaceCount: Byte = 0);
    procedure FormatClassProperty(PreSpaceCount: Byte = 0);
    procedure FormatClassTypeSection(PreSpaceCount: Byte = 0);
    procedure FormatClassConstSection(PreSpaceCount: Byte = 0);
    procedure FormatClassConstantDecl(PreSpaceCount: Byte = 0);

    // orgin grammer
    procedure FormatClassFieldList(PreSpaceCount: Byte = 0);
    procedure FormatClassMethodList(PreSpaceCount: Byte = 0);
    procedure FormatClassPropertyList(PreSpaceCount: Byte = 0);

    procedure FormatPropertyList(PreSpaceCount: Byte = 0);
    procedure FormatPropertyInterface(PreSpaceCount: Byte = 0);
    procedure FormatPropertyParameterList(PreSpaceCount: Byte = 0);
    procedure FormatPropertySpecifiers(PreSpaceCount: Byte = 0);
    procedure FormatInterfaceType(PreSpaceCount: Byte = 0);
    procedure FormatGuid(PreSpaceCount: Byte = 0);
    procedure FormatInterfaceHeritage(PreSpaceCount: Byte = 0);
    procedure FormatRequiresClause(PreSpaceCount: Byte = 0);
    procedure FormatContainsClause(PreSpaceCount: Byte = 0);

    procedure FormatLabelID(PreSpaceCount: Byte = 0);
    procedure FormatExportsSection(PreSpaceCount: Byte = 0);
    procedure FormatExportsList(PreSpaceCount: Byte = 0);
    procedure FormatExportsDecl(PreSpaceCount: Byte = 0);

    procedure ScanerLineBreak(Sender: TObject);
    {* Scaner 扫描到源文件中的换行时触发的事件，根据需要写回车到输出中}
    function ScanerGetCanLineBreak(Sender: TObject): Boolean;
    {* 向 Scaner 返回当前是否保持换行}
  public
    constructor Create(AStream: TStream; AMatchedInStart: Integer = CN_MATCHED_INVALID;
      AMatchedInEnd: Integer = CN_MATCHED_INVALID;
      ACompDirectiveMode: TCnCompDirectiveMode = cdmAsComment); override;

    procedure FormatCode(PreSpaceCount: Byte = 0); override;
  end;

  TCnStatementFormatter = class(TCnBasePascalFormatter)
  protected

  public
    procedure FormatCode(PreSpaceCount: Byte = 0); override;
  end;

  TCnTypeSectionFormater = class(TCnStatementFormatter)
  protected

    //procedure FormatTypeID(PreSpaceCount: Byte = 0);
  end;

  TCnProgramBlockFormatter = class(TCnTypeSectionFormater)
  protected
    procedure FormatProgramBlock(PreSpaceCount: Byte = 0; IsLib: Boolean = False);
    procedure FormatPackageBlock(PreSpaceCount: Byte = 0);
    procedure FormatUsesClause(PreSpaceCount: Byte = 0; const NeedCRLF: Boolean = False);
    procedure FormatUsesList(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True;
      const NeedCRLF: Boolean = False);
    procedure FormatUsesDecl(PreSpaceCount: Byte; const CanHaveUnitQual: Boolean = True);
  end;

  TCnGoalCodeFormatter = class(TCnProgramBlockFormatter)
  protected
    procedure FormatGoal(PreSpaceCount: Byte = 0);
    procedure FormatProgram(PreSpaceCount: Byte = 0);
    procedure FormatUnit(PreSpaceCount: Byte = 0);
    procedure FormatLibrary(PreSpaceCount: Byte = 0);
    procedure FormatPackage(PreSpaceCount: Byte = 0);
    procedure FormatInterfaceSection(PreSpaceCount: Byte = 0);
    procedure FormatInterfaceDecl(PreSpaceCount: Byte = 0);
    procedure FormatExportedHeading(PreSpaceCount: Byte = 0);
    procedure FormatImplementationSection(PreSpaceCount: Byte = 0);
    procedure FormatInitSection(PreSpaceCount: Byte = 0);
  public
    procedure FormatCode(PreSpaceCount: Byte = 0); override;
  end;

  TCnPascalCodeFormatter = class(TCnGoalCodeFormatter)
  public
    procedure FormatCode(PreSpaceCount: Byte = 0); override;
    function HasSliceResult: Boolean;
    function CopyMatchedSliceResult: string;
    property CodeGen;
  end;

implementation

uses
  CnParseConsts {$IFDEF DEBUG}, CnDebug {$ENDIF};

var
  FKeywordsValidArray: array[Low(TPascalToken)..High(TPascalToken)] of
    TCnPascalFormattingElementTypeSet;
  {* 容纳关键字与其作用域的一个快速访问的数组}

procedure MakeKeywordsValidAreas;
var
  I: TPascalToken;
begin
  for I := Low(TPascalToken) to High(TPascalToken) do
    FKeywordsValidArray[I] := [];

  FKeywordsValidArray[tokComplexIndex] := [pfetPropertyIndex, pfetDirective];
  FKeywordsValidArray[tokComplexRead] := [pfetPropertySpecifier];
  FKeywordsValidArray[tokComplexWrite] := [pfetPropertySpecifier];
  FKeywordsValidArray[tokComplexDefault] := [pfetPropertySpecifier];
  FKeywordsValidArray[tokComplexStored] := [pfetPropertySpecifier];
  FKeywordsValidArray[tokComplexReadonly] := [pfetPropertySpecifier];

  FKeywordsValidArray[tokDirectiveMESSAGE] := [pfetDirective];
  FKeywordsValidArray[tokDirectiveREGISTER] := [pfetDirective];
  FKeywordsValidArray[tokDirectiveEXPORT] := [pfetDirective];
  // TODO: 加入其他 Directive

  FKeywordsValidArray[tokComplexName] := [pfetDirective];
  FKeywordsValidArray[tokKeywordAlign] := [pfetRecordEnd];

  // requires/contains 只在 dpk 里算关键字
  FKeywordsValidArray[tokKeywordRequires] := [pfetPackageBlock];
  FKeywordsValidArray[tokKeywordContains] := [pfetPackageBlock];

  // at 只在 raise 后面才算关键字
  FKeywordsValidArray[tokKeywordAt] := [pfetRaiseAt];
  // 未列出的关键字，表示在哪都是关键字
end;

// 检查对应关键字是否在其作用域外面，返回 True 表示在外面，不该作为关键字处理
function CheckOutOfKeywordsValidArea(Key: TPascalToken; Element: TCnPascalFormattingElementType): Boolean;
begin
  Result := False;
  if FKeywordsValidArray[Key] = [] then // 未指定的，表示在哪都是关键字
    Exit;
  Result := not (Element in FKeywordsValidArray[Key]);
end;

{ TCnAbstractCodeFormater }

function TCnAbstractCodeFormatter.CheckIdentifierName(const S: string): string;
begin
  { Check the S with pre-specified names e.g. ShowMessage }
  if FDisableCorrectName or (FNamesMap = nil) or not FNamesMap.Find(UpperCase(S), Result) then
    Result := S;
end;

constructor TCnAbstractCodeFormatter.Create(AStream: TStream;
   AMatchedInStart, AMatchedInEnd: Integer;
   ACompDirectiveMode: TCnCompDirectiveMode);
begin
  FMatchedInStart := AMatchedInStart;
  FMatchedInEnd := AMatchedInEnd;

  FMatchedOutStartRow := CN_MATCHED_INVALID;
  FMatchedOutStartCol := CN_MATCHED_INVALID;
  FMatchedOutEndRow := CN_MATCHED_INVALID;
  FMatchedOutEndCol := CN_MATCHED_INVALID;

  // FNamesMap := TCnStrToStrHashMap.Create; // Lazy Create
  FCodeGen := TCnCodeGenerator.Create;
  FCodeGen.CodeWrapMode := CnPascalCodeForRule.CodeWrapMode;
  FCodeGen.OnAfterWrite := CodeGenAfterWrite;
  FCodeGen.OnGetInIgnore := CodeGenGetInIgnore;
  FScanner := TScanner.Create(AStream, FCodeGen, ACompDirectiveMode);

  FOldElementTypes := TCnElementStack.Create;
  FLineBreakKeepStack := TStack.Create;
  FScanner.NextToken;
end;

destructor TCnAbstractCodeFormatter.Destroy;
begin
  FLineBreakKeepStack.Free;
  FOldElementTypes.Free;
  FScanner.Free;
  FCodeGen.Free;
  FNamesMap.Free;
  FOutputLineMarks.Free;
  FInputLineMarks.Free;
  inherited;
end;

procedure TCnAbstractCodeFormatter.Error(const Ident: Integer);
begin
  // 出错入口
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FScanner.SourceLine;
  PascalErrorRec.SourceCol := FScanner.SourceCol;
  PascalErrorRec.SourcePos := FScanner.SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;

  ErrorStr(RetrieveFormatErrorString(Ident));
end;

procedure TCnAbstractCodeFormatter.ErrorFmt(const Ident: Integer;
  const Args: array of const);
begin
  // 出错入口
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FScanner.SourceLine;
  PascalErrorRec.SourceCol := FScanner.SourceCol;
  PascalErrorRec.SourcePos := FScanner.SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;

  ErrorStr(Format(RetrieveFormatErrorString(Ident), Args));
end;

procedure TCnAbstractCodeFormatter.ErrorNotSurpport(FurtureStr: string);
begin
  ErrorFmt(CN_ERRCODE_PASCAL_NOT_SUPPORT, [FurtureStr]);
end;

procedure TCnAbstractCodeFormatter.ErrorStr(const Message: string);
begin
  raise EParserError.CreateFmt(
        SParseError,
        [ Message, FScanner.SourceLine, FScanner.SourcePos ]
  );
end;

procedure TCnAbstractCodeFormatter.ErrorToken(Token: TPascalToken);
begin
  if TokenToString(Scanner.Token) = '' then
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [TokenToString(Token), Scanner.TokenString] )
  else
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [TokenToString(Token), TokenToString(Scanner.Token)]);
end;

procedure TCnAbstractCodeFormatter.ErrorTokens(Tokens: array of TPascalToken);
var
  S: string;
  I: Integer;
begin
  S := '';
  for I := Low(Tokens) to High(Tokens) do
    S := S + TokenToString(Tokens[I]) + ' ';

  ErrorExpected(S);
end;

procedure TCnAbstractCodeFormatter.ErrorExpected(Str: string);
begin
  ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [Str, TokenToString(Scanner.Token)]);
end;

function TCnAbstractCodeFormatter.FormatString(const KeywordStr: string;
  KeywordStyle: TCnKeywordStyle): string;
begin
  case KeywordStyle of
    ksPascalKeyword:    Result := UpperFirst(KeywordStr);
    ksUpperCaseKeyword: Result := UpperCase(KeywordStr);
    ksLowerCaseKeyword: Result := LowerCase(KeywordStr);
    ksNoChange:         Result := KeywordStr;
  else
    Result := KeywordStr;
  end;
end;

function TCnAbstractCodeFormatter.UpperFirst(const KeywordStr: string): string;
begin
  Result := LowerCase(KeywordStr);
  if Length(Result) >= 1 then
    Result[1] := Char(Ord(Result[1]) + Ord('A') - Ord('a'));
end;

function TCnAbstractCodeFormatter.CanBeSymbol(Token: TPascalToken): Boolean;
begin
  Result := Scanner.Token in ([tokSymbol, tokAmpersand, tokAtSign, tokKeywordFinal,
    tokKeywordIn, tokKeywordOut, tokKeywordString, tokKeywordAlign, tokKeywordAt]
    + ComplexTokens + DirectiveTokens);
end;

function TCnAbstractCodeFormatter.CanKeepLineBreak: Boolean;
begin
  Result := CnPascalCodeForRule.KeepUserLineBreak and FNeedKeepLineBreak;
end;

procedure TCnAbstractCodeFormatter.Match(Token: TPascalToken; BeforeSpaceCount,
  AfterSpaceCount: Byte; IgnorePreSpace: Boolean; SemicolonIsLineStart: Boolean;
  NoSeparateSpace: Boolean);
begin
  if (Scanner.Token = Token) or ( (Token = tokSymbol) and
    CanBeSymbol(Scanner.Token) ) then
  begin
    WriteToken(Token, BeforeSpaceCount, AfterSpaceCount,
      IgnorePreSpace, SemicolonIsLineStart, NoSeparateSpace);
    Scanner.NextToken;
  end
  else if FInternalRaiseException or not CnPascalCodeForRule.ContinueAfterError then
  begin
    if FSliceMode and (Scanner.Token = tokEOF) then
      raise EReadError.Create('Eof')
    else
      ErrorToken(Token);
  end
  else // 要继续的场合，写了再说
  begin
    WriteToken(Token, BeforeSpaceCount, AfterSpaceCount,
      IgnorePreSpace, SemicolonIsLineStart, NoSeparateSpace);
    Scanner.NextToken;
  end;
end;

procedure TCnAbstractCodeFormatter.MatchOperator(Token: TPascalToken);
var
  Before: Integer;
  After: Integer;
begin
  Before := CnPascalCodeForRule.SpaceBeforeOperator;
  After := CnPascalCodeForRule.SpaceAfterOperator;
  if Token in KeywordsOpTokens then // and xor 等双目运算符，前后必须至少空一格
  begin
    if Before <= 0 then
      Before := 1;
    if After <= 0 then
      After := 1;
  end;

  // 双目运算符前面如果是块注释且在本行，则要删除空格
  if not FCodeGen.IsLastLineSpaces and Scanner.JustWroteBlockComment
    and not Scanner.InIgnoreArea then
    FCodeGen.BackSpaceLastSpaces;

  Match(Token, Before, After);
end;

procedure TCnAbstractCodeFormatter.SaveToFile(FileName: string);
begin
  CodeGen.SaveToFile(FileName);
end;

procedure TCnAbstractCodeFormatter.SaveToStream(Stream: TStream);
begin
  CodeGen.SaveToStream(Stream);
end;

procedure TCnAbstractCodeFormatter.SaveToStrings(AStrings: TStrings);
begin
  CodeGen.SaveToStrings(AStrings);
end;

function TCnAbstractCodeFormatter.Space(Count: Word): string;
begin
  Result := 'a'#10'a'#13'sd'; // ???
  if SmallInt(Count) > 0 then
    Result := StringOfChar(' ', Count)
  else
    Result := '';
end;

function TCnAbstractCodeFormatter.Tab(PreSpaceCount: Byte;
  CareBeginBlock: Boolean): Byte;
begin
  if CareBeginBlock then
  begin
    // 处理了连续俩 begin 而需要缩进的情况，以及with do try 这种的 try 无需再次缩进
    // 但 repeat until 里的 begin 和 try 又得再次缩进
    if (not (Scanner.Token in [tokKeywordBegin, tokKeywordTry]))
      or (FLastNonBlankToken in [tokKeywordRepeat]) then
      Result := PreSpaceCount + CnPascalCodeForRule.TabSpaceCount
    else
      Result := PreSpaceCount;
  end
  else
  begin
    Result := PreSpaceCount + CnPascalCodeForRule.TabSpaceCount;
  end;
end;

procedure TCnAbstractCodeFormatter.WriteLine;
begin
  if CanKeepLineBreak then
    Exit;

  if CnPascalCodeForRule.UseIgnoreArea and Scanner.InIgnoreArea then  // 在忽略区，不主动写换行，让 SkipBlank 写。
  begin
    FLastToken := tokBlank;
    Exit;
  end;

  if (Scanner.BlankLinesBefore = 0) and (Scanner.BlankLinesAfter = 0) then
  begin
    FCodeGen.Writeln;
    FCodeGen.Writeln;
  end
  else // 有 Comment，已经输出了，但 Comment 后的空行未输出，并且前后各有换行
  begin
    if Scanner.BlankLinesBefore = 0 then
    begin
      // 注释块和上一行在一起，照常输出俩空行
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scanner.BlankLinesBefore > 1) and (Scanner.BlankLinesAfter = 1) then
    begin
      // 注释块空上不空下，那就让下面挨着下，不需要额外输出空行了
      ;
    end
    else if (Scanner.BlankLinesBefore > 1) and (Scanner.BlankLinesAfter > 1) then
    begin
      // 注释块上下都空，那下面保留一空行
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scanner.BlankLinesBefore = 1) and (Scanner.BlankLinesAfter = 1) then
    begin
      // 上下都不空，采取靠上策略
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scanner.BlankLinesBefore = 1) and (Scanner.BlankLinesAfter > 1) then
    begin
      // 上空下不空，那就靠上
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end;  
  end;
  FLastToken := tokBlank; // prevent 'Symbol'#13#10#13#10' Symbol'
end;

procedure TCnAbstractCodeFormatter.CheckKeepLineBreakWriteln;
begin
  if CnPascalCodeForRule.KeepUserLineBreak then
    EnsureWriteln
  else
    Writeln;
end;

procedure TCnAbstractCodeFormatter.EnsureWriteln;
begin
  if not FCodeGen.IsLastLineEmpty and not FScanner.InIgnoreArea then // 忽略区不主动写换行
    FCodeGen.Writeln;
end;

procedure TCnAbstractCodeFormatter.Writeln;
begin
  if CanKeepLineBreak then
    Exit;

  if CnPascalCodeForRule.UseIgnoreArea and Scanner.InIgnoreArea then  // 在忽略区，不主动写换行，让 SkipBlank 写。
  begin
    FLastToken := tokBlank;
    Exit;
  end;

  if FEnsureOneEmptyLine then // 如果外部要求本次保持一空行
  begin
    FCodeGen.CheckAndWriteOneEmptyLine;
  end
  else if (Scanner.BlankLinesBefore = 0) and (Scanner.BlankLinesAfter = 0) then
  begin
    FCodeGen.Writeln;
  end
  else // 有 Comment，已经输出了，但 Comment 后的空行未输出，并且前后各有换行
  begin
    if Scanner.BlankLinesBefore = 0 then
    begin
      // 注释块和上一行在一起，照常输出空行
      FCodeGen.Writeln;

      // 注释块后面有空行，则相应保持
      if Scanner.BlankLinesAfter > 1 then
        FCodeGen.Writeln;
    end
    else if (Scanner.BlankLinesBefore > 1) and (Scanner.BlankLinesAfter = 1) then
    begin
      // 注释块空上不空下，那就让下面挨着下，不需要额外输出空行了
      ;
    end
    else if (Scanner.BlankLinesBefore >= 1) and (Scanner.BlankLinesAfter > 1) then
    begin
      // 注释块上下都空或者上不空下空，那下面保留一空行
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scanner.BlankLinesBefore = 1) and (Scanner.BlankLinesAfter = 1) then
    begin
      // 上下都不空，采取靠上策略
      FCodeGen.Writeln;
    end;
  end;
  FLastToken := tokBlank; // prevent 'Symbol'#13#10' Symbol'
end;

procedure TCnAbstractCodeFormatter.WriteToken(Token: TPascalToken;
  BeforeSpaceCount, AfterSpaceCount: Byte; IgnorePreSpace: Boolean;
  SemicolonIsLineStart: Boolean; NoSeparateSpace: Boolean; const AlterativeStr: string);
var
  NeedPadding: Boolean;
  NeedUnIndent: Boolean;
  S: string;
  WrittingKeyWordTokens: TPascalTokenSet;
begin
  if CnPascalCodeForRule.UseIgnoreArea and Scanner.InIgnoreArea then
  begin
    // 在忽略块内部，将非注释非空白内容原始输出，其中空白与注释由 Scaner 内部处理
    CodeGen.Write(Scanner.TokenString);
    FLastToken := Token;
    if FLastToken <> tokBlank then
      FLastNonBlankToken := FLastToken;
    Exit;
  end;

  if not NoSeparateSpace then  // 如果不要插入分隔空格，则跳过此段
  begin
    // 两个标识符之间以空格分离，前提是本行未被注释等分行从而隔开 FLastToken
    if not FCodeGen.NextOutputWillbeLineHead and
      ((FLastToken in IdentTokens) and (Token in IdentTokens + [tokAtSign, tokAmpersand])) then
      WriteOneSpace
    else if ((BeforeSpaceCount = 0) and (FLastToken = tokGreat) and
      (CurrentContainElementType([pfetInGeneric]) or (FLastElementType = pfetInGeneric))
      and (Token in IdentTokens + [tokAtSign])) then
      WriteOneSpace // 泛型 property 后面加 read 时，需要用这种方式加空格分开，不是泛型时比如碰到普通大于号时则无须这样做
    else if (FLastToken in RightBracket + [tokHat]) and (Token in [tokKeywordThen, tokKeywordDo,
      tokKeywordOf, tokKeywordTo, tokKeywordDownto, tokKeywordAt]) then
      WriteOneSpace  // 强行分离右括号/指针符与关键字
    else if (FLastToken = tokKeywordOperator) and (Token in [tokKeywordIn]) then
      WriteOneSpace  // operator in 需要用空格分开
    else if (Token in LeftBracket + [tokPlus, tokMinus, tokHat]) and
      ((FLastToken in NeedSpaceAfterKeywordTokens)
      or ((FLastToken = tokKeywordAt) and UpperContainElementType([pfetRaiseAt]))) then
      WriteOneSpace; // 强行分离左括号/前置运算符号，与关键字以及 raise 语句中的 at，注意 at 后的表达式盖掉了pfetRaiseAt，所以需要获取上一层
  end;

  NeedPadding := CalcNeedPadding;
  NeedUnIndent := CalcNeedPaddingAndUnIndent;

  if AlterativeStr = '' then
    S := Scanner.TokenString
  else
    S := AlterativeStr;

  if FElementType in [pfetUnitName] then // 某些区域内某些标识符不能是关键字
    WrittingKeyWordTokens := KeywordTokens + DirectiveTokens
  else
    WrittingKeyWordTokens := KeywordTokens + ComplexTokens + DirectiveTokens; // 关键字范围扩大

  // 标点符号的设置
  case Token of
    tokComma:
      CodeGen.Write(S, 0, 1, NeedPadding);   // 1 也会导致行尾注释后退，现多出的空格已由 Generator 删除
    tokColon:
      begin
        if IgnorePreSpace then
          CodeGen.Write(S, 0, 0, NeedPadding)
        else
          CodeGen.Write(S, 0, 1, NeedPadding);  // 1 也会导致行尾注释后退，现多出的空格已由 Generator 删除
      end;
    tokSemiColon:
      begin
        if IgnorePreSpace then
          CodeGen.Write(S)
        else if SemicolonIsLineStart then
          CodeGen.Write(S, BeforeSpaceCount, 0, NeedPadding)
        else
        begin
          if FTrimAfterSemicolon then
            CodeGen.Write(S, 0, 0, NeedPadding)
          else
            CodeGen.Write(S, 0, 1, NeedPadding);
        end;
          // 1 也会导致行尾注释后退，现多出的空格已由 Generator 删除，
          // 但分号后如果本行又有其他内容则会出现多一个空格的问题，如 record 的可变部分
      end;
    tokAssign:
      CodeGen.Write(S, BeforeSpaceCount, AfterSpaceCount, NeedPadding);
  else
    if Token in WrittingKeyWordTokens then
    begin
      if FLastToken = tokAmpersand then // 关键字前是 & 表示非关键字，并且挨着，无须 Padding
      begin
        CodeGen.Write(CheckIdentifierName(S), BeforeSpaceCount, AfterSpaceCount);
      end
      else if CheckOutOfKeywordsValidArea(Token, ElementType) then
      begin
        // 关键字有效作用域外均在此原样输出
        CodeGen.Write(CheckIdentifierName(S),
          BeforeSpaceCount, AfterSpaceCount, NeedPadding);
      end
      else // 真正的关键字场合
      begin
        CodeGen.Write(FormatString(S,
          CnPascalCodeForRule.KeywordStyle), BeforeSpaceCount,
          AfterSpaceCount, NeedPadding);
      end;
    end
    else if FIsTypeID then // 如果是类型名，则按规则处理 Scaner.TokenString
    begin
      CodeGen.Write(CheckIdentifierName(S), BeforeSpaceCount,
        AfterSpaceCount, NeedPadding);
    end
    else // 目前只有右括号部分
    begin
      CodeGen.Write(CheckIdentifierName(S), BeforeSpaceCount,
        AfterSpaceCount, NeedPadding, NeedUnIndent);
    end;
  end;

  // 关键字如果之前有 &，则不算关键字
  if (FLastToken = tokAmpersand) and (Token in WrittingKeyWordTokens) then
    FLastToken := tokSymbol
  else
    FLastToken := Token;

  if FLastToken <> tokBlank then
    FLastNonBlankToken := FLastToken;
end;

procedure TCnAbstractCodeFormatter.CheckHeadComments;
var
  I: Integer;
begin
  if FCodeGen <> nil then
    for I := 1 to Scanner.BlankLinesAfter do
      FCodeGen.Writeln;
end;

function TCnAbstractCodeFormatter.BackTab(PreSpaceCount: Byte;
  CareBeginBlock: Boolean): Integer;
begin
  Result := 0;
  if CareBeginBlock then
  begin
    Result := PreSpaceCount - CnPascalCodeForRule.TabSpaceCount;
    if Result < 0 then
      Result := 0;
  end;
end;

{ TCnExpressionFormater }

procedure TCnBasePascalFormatter.FormatCode;
begin
  FormatExpression;
end;

{ ConstExpr -> <constant-expression> }
procedure TCnBasePascalFormatter.FormatConstExpr(PreSpaceCount, IndentForAnonymous: Byte);
begin
  SpecifyElementType(pfetConstExpr);
  try
    // 常量表达式允许保持内部换行
    FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
    FNeedKeepLineBreak := True;
    try
      // 从 FormatExpression 复制而来，为了区分来源
      FormatSimpleExpression(PreSpaceCount, IndentForAnonymous);
    finally
      FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
    end;

    while Scanner.Token in RelOpTokens + [tokHat, tokSLB, tokDot] do
    begin
      // 这块对泛型的处理已移动到内部以处理 function call 的情形

      if Scanner.Token in RelOpTokens then
      begin
        MatchOperator(Scanner.Token);
        FormatSimpleExpression;
      end;

      // 这几处额外的内容，不知道有啥副作用

      // pchar(ch)^
      if Scanner.Token = tokHat then
        Match(tokHat)
      else if Scanner.Token = tokSLB then  // PString(PStr)^[1]
      begin
        Match(tokSLB);
        FormatExprList(0, PreSpaceCount);
        Match(tokSRB);
      end
      else if Scanner.Token = tokDot then // typecase
      begin
        Match(tokDot);
        FormatExpression(0, PreSpaceCount);
      end;
    end;
  finally
    RestoreElementType;
  end;
end;

{ 新加的用于 type 中的 ConstExpr -> <constant-expression> ，
  其中后者不允许出现 = 以及泛型 <> 运算符}
procedure TCnBasePascalFormatter.FormatConstExprInType(PreSpaceCount: Byte);
var
  Old: Boolean;
begin
  // 处理类型名等的大小写问题
  Old := FIsTypeID;
  try
    FIsTypeID := True;
    FormatSimpleExpression(PreSpaceCount);
  finally
    FIsTypeID := Old;
  end;

  while Scanner.Token in (RelOpTokens - [tokEqual, tokLess, tokGreat])  do
  begin
    MatchOperator(Scanner.Token);
    FormatSimpleExpression;
  end;
end;

{
  Designator -> QualId ['.' Ident<ExprList> | '[' ExprList ']' | '^']...

  注：虽然有 Designator -> '(' Designator ')' 的情况，但已经包含在 QualId 的处理中了。
}
procedure TCnBasePascalFormatter.FormatDesignator(PreSpaceCount: Byte;
  IndentForAnonymous: Byte);
var
  IsB, IsGeneric: Boolean;
  GenericBookmark: TScannerBookmark;
  LessCount: Integer;
begin
  if Scanner.Token = tokAtSign then // 如果是 @ Designator 的形式则再次递归
  begin
    Match(tokAtSign, PreSpaceCount);
    FormatDesignator(0, IndentForAnonymous);
    Exit;
  end
  else if Scanner.Token = tokKeywordInherited then // 处理 (inherited a).a; 这种语法
    Match(tokKeywordInherited);

  FormatQualID(PreSpaceCount);
  while Scanner.Token in [tokDot, tokLB, tokSLB, tokHat, tokPlus, tokMinus] do
  begin
    case Scanner.Token of
      tokDot:
        begin
          Match(tokDot);
          FormatIdent;  // 点号后的调用不能简单地 FormatIdent，之后还要处理泛型

          // 这段泛型的判断等同于 FormatIdentWithBracket 里的
          IsGeneric := False;
          if Scanner.Token = tokLess then
          begin
            // 判断泛型，如果不是，恢复书签往下走；如果是，就恢复书签处理泛型
            Scanner.SaveBookmark(GenericBookmark);
            CodeGen.LockOutput;

            // 往后找，一直找到非类型的关键字或者分号或者文件尾。
            // 如果出现小于号和大于号一直不配对，则认为不是泛型。
            // TODO: 判断还是不太严密，待继续验证。
            Scanner.NextToken;
            LessCount := 1;
            while not (Scanner.Token in KeywordTokens + [tokSemicolon, tokEOF] - CanBeTypeKeywordTokens) do
            begin
              if Scanner.Token = tokLess then
                Inc(LessCount)
              else if Scanner.Token = tokGreat then
                Dec(LessCount);

              if LessCount = 0 then // Test<TObject><1 的情况，需要为 0 配对时就提前跳出
                Break;

              Scanner.NextToken;
            end;
            IsGeneric := (LessCount = 0);

            Scanner.LoadBookmark(GenericBookmark);
            CodeGen.UnLockOutput;
          end;

          if IsGeneric then
            FormatTypeParams;
        end;

      tokLB, tokSLB: // [ ] ()
        begin
          { DONE: deal with index visit and function/procedure call}
          IsB := (Scanner.Token = tokLB);
          Match(Scanner.Token);
          // Str 这种函数调用，参数列表要支持冒号分割，不知道副作用是否大不大
          FormatExprList(PreSpaceCount, IndentForAnonymous, IsB);

          IsB := Scanner.Token = tokRB;
          if IsB then
            SpecifyElementType(pfetExprListRightBracket);
          try
            Match(Scanner.Token);
          finally
            if IsB then
              RestoreElementType;
          end;
        end;
      tokHat: // ^ 这里支持多个指针连续指
        begin
          { DONE: deal with pointer derefrence }
          Match(tokHat);
        end;
      tokPlus, tokMinus: // 这里的加减号是啥目的？照理应该算 Term 之间的二元运算符才对
        begin
          MatchOperator(Scanner.Token);
          FormatExpression(0, PreSpaceCount);
        end;
    end; // case
  end; // while
end;

{ DesignatorList -> Designator/','... }
procedure TCnBasePascalFormatter.FormatDesignatorList(PreSpaceCount: Byte);
begin
  FormatDesignator;

  while Scanner.Token = tokComma do
  begin
    MatchOperator(tokComma);
    FormatDesignator;
  end;
end;

{ Expression -> SimpleExpression [RelOp SimpleExpression]... }
procedure TCnBasePascalFormatter.FormatExpression(PreSpaceCount: Byte;
  IndentForAnonymous: Byte);
begin
  SpecifyElementType(pfetExpression);
  try
    FormatSimpleExpression(PreSpaceCount, IndentForAnonymous);

    while Scanner.Token in RelOpTokens + [tokHat, tokSLB, tokDot] do
    begin
      // 这块对泛型的处理已移动到内部以处理 function call 的情形

      if Scanner.Token in RelOpTokens then
      begin
        MatchOperator(Scanner.Token);
        FormatSimpleExpression;
      end;

      // 虽然理论上一部分已经在 Designator 中处理掉了走不到这里，但仍有作用
      // 譬如在 Factor 里碰到小括号时

      // pchar(ch)^
      if Scanner.Token = tokHat then
        Match(tokHat)
      else if Scanner.Token = tokSLB then  // PString(PStr)^[1]  FunctionCall 返回的指针数组内容再下标时会走这里
      begin
        Match(tokSLB);
        FormatExprList(0, PreSpaceCount);  // 数组下标
        Match(tokSRB);
      end
      else if Scanner.Token = tokDot then // typecase
      begin
        Match(tokDot);
        FormatExpression(0, PreSpaceCount);
      end;
    end;
  finally
    RestoreElementType;
  end;
end;

{ ExprList -> Expression/','... }
procedure TCnBasePascalFormatter.FormatExprList(PreSpaceCount: Byte;
  IndentForAnonymous: Byte; SupportColon: Boolean);
var
  Sep: TPascalTokenSet;
begin
  FormatExpression(0, IndentForAnonymous);

  if Scanner.Token = tokAssign then // 匹配 OLE 调用的情形
  begin
    MatchOperator(tokAssign);
    FormatExpression(0, IndentForAnonymous);
  end;

  Sep := [tokComma];
  if SupportColon then
    Include(Sep, tokColon);

  while Scanner.Token in Sep do
  begin
    Match(Scanner.Token, 0, 1);

    if Scanner.Token in ([tokAmpersand, tokAtSign, tokLB] + ExprTokens + KeywordTokens +
      DirectiveTokens + ComplexTokens) then // 有关键字做变量名的情况也得考虑到
    begin
      FormatExpression(0, IndentForAnonymous);

      if Scanner.Token = tokAssign then // 匹配 OLE 调用的情形
      begin
        MatchOperator(tokAssign);
        FormatExpression(0, IndentForAnonymous);
      end;
    end;
  end;
end;

{
  Factor -> Designator ['(' ExprList ')']
         -> '@' Designator
         -> Number
         -> String
         -> NIL
         -> '(' Expression ')'['^'...]
         -> NOT Factor
         -> SetConstructor
         -> TypeId '(' Expression ')'
         -> INHERITED Expression

  这里同样有无法直接区分 '(' Expression ')' 和带括号的 Designator
  例子就是(str1+str2)[1] 等诸如此类的表达式，先姑且判断一下后续的方括号
}
procedure TCnBasePascalFormatter.FormatFactor(PreSpaceCount: Byte;
  IndentForAnonymous: Byte);
var
  NeedPadding: Boolean;
begin
  case Scanner.Token of
    tokSymbol, tokAtSign,
    tokKeyword_BEGIN..tokKeywordIn,  // 此三行表示部分关键字也可做 Factor
    tokAmpersand,                    // & 号也可作为 Identifier
    tokKeywordInitialization..tokKeywordNil,
    tokKeywordObject..tokKeyword_END,
    tokDirective_BEGIN..tokDirective_END,
    tokComplex_BEGIN..tokComplex_END:
      begin
        FormatDesignator(PreSpaceCount, IndentForAnonymous);

        if Scanner.Token = tokLB then
        begin
          { TODO: deal with function call node }
          Match(tokLB);
          FormatExprList;
          Match(tokRB);
        end;
      end;

    tokKeywordInherited:
      begin
        Match(tokKeywordInherited);
        // 处理 if True then Result := inherited else Result := False; 这种
        if Scanner.Token <> tokKeywordElse then
          FormatExpression(0, IndentForAnonymous); // 为啥这里要用 IndentForAnonymous 而不是其他的 PreSpaceCount？
      end;

    tokChar, tokWString, tokString, tokMString, tokInteger, tokFloat, tokTrue, tokFalse:
      begin
        NeedPadding := CalcNeedPadding;
        case Scanner.Token of
          tokInteger, tokFloat:
            WriteToken(Scanner.Token, PreSpaceCount);
          tokTrue, tokFalse:
            if CnPascalCodeForRule.UseIgnoreArea and Scanner.InIgnoreArea then
              CodeGen.Write(Scanner.TokenString)
            else
              CodeGen.Write(UpperFirst(Scanner.TokenString), PreSpaceCount, 0, NeedPadding);
            // CodeGen.Write(FormatString(Scaner.TokenString, CnCodeForRule.KeywordStyle), PreSpaceCount);
          tokChar, tokString, tokWString, tokMString:
            begin
              if CnPascalCodeForRule.UseIgnoreArea and Scanner.InIgnoreArea then
                CodeGen.Write(Scanner.TokenString)
              else
              begin
                if (FLastToken in NeedSpaceAfterKeywordTokens) // 字符串前面是这些关键字时，要以至少一个空格分隔
                  and (PreSpaceCount = 0) then
                  PreSpaceCount := 1;
                CodeGen.Write(Scanner.TokenString, PreSpaceCount, 0, NeedPadding);
              end;
            end;
        end;

        FLastToken := Scanner.Token;
        if FLastToken <> tokBlank then
          FLastNonBlankToken := FLastToken;
        Scanner.NextToken;
      end;

    tokKeywordNOT:
      begin
        if Scanner.ForwardToken in [tokLB] then // 无奈之举，避免少个空格
          Match(tokKeywordNot, 0, 1)
        else
          Match(tokKeywordNot);
        FormatFactor;
      end;

    tokLB: // (  需要判断是带括号嵌套的 Designator 还是 Expression.
      begin
        // 暂且修改了 Expression 内部，使其支持^和[]了。
        Match(tokLB, PreSpaceCount);
        FormatExpression;
        Match(tokRB);

        // 修补处理 (Expression)^^ 这种语法
        while Scanner.Token = tokHat do
          Match(Scanner.Token);
      end;

    tokSLB: // [
      begin
        FormatSetConstructor(PreSpaceCount);
      end;
  else
    { Doesn't do anything to implemenation rule: '' Designator }
  end;
end;

procedure TCnBasePascalFormatter.FormatIdent(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  while Scanner.Token = tokSLB do // Attribute
  begin
    if CurrentContainElementType([pfetInlineVar]) then // inline var 里的属性不换行，留个空格
      WriteOneSpace;

    FormatSingleAttribute(PreSpaceCount);
    if CurrentContainElementType([pfetInlineVar]) then // inline var 里的属性不换行，后面再来个空格
      WriteOneSpace
    else
      Writeln;
  end;

  if Scanner.Token = tokAmpersand then // & 表示后面的声明使用的关键字是转义的
  begin
    Match(Scanner.Token, PreSpaceCount); // 在此缩进
    if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scanner.Token); // & 后的标识符中允许使用部分关键字，但不允许新语法的数字等
  end
  else if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens + CanBeNewIdentifierTokens) then
  begin
    CheckAddIdentBackup(FIdentBackupListRef, Scanner.TokenString);
    Match(Scanner.Token, PreSpaceCount); // 标识符中允许使用部分关键字，在此缩进
  end;

  while CanHaveUnitQual and (Scanner.Token = tokDot) do
  begin
    Match(tokDot);
    FDisableCorrectName := True;        // 点号后的标识符暂时无法与同名的独立变量区分，只能先禁用大小写纠正
    try
      if Scanner.Token = tokAmpersand then // & 表示后面的声明使用的关键字是转义的
      begin
        Match(Scanner.Token); // 点号后无需缩进
        if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
          Match(Scanner.Token); // & 后的标识符中允许使用部分关键字，但不允许新语法的数字等
      end
      else if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens + CanBeNewIdentifierTokens) then
        Match(Scanner.Token); // 也继续允许使用部分关键字
    finally
      FDisableCorrectName := False;
    end;
  end;
end;

{ IdentList -> Ident/','... }
procedure TCnBasePascalFormatter.FormatIdentList(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  FormatIdent(PreSpaceCount, CanHaveUnitQual);

  while Scanner.Token = tokComma do
  begin
    Match(tokComma);
    FormatIdent(0, CanHaveUnitQual);
  end;
end;

{
  New Grammer:
  QualID -> '(' Designator [AS TypeId]')'
         -> [UnitId '.'] Ident<>
         -> '(' pointervar + expr ')'

  for typecast, e.g. "(x as Ty)" or just bracketed, as in (x).y();

  Old Grammer:
  QualId -> [UnitId '.'] Ident
}
procedure TCnBasePascalFormatter.FormatQualID(PreSpaceCount: Byte);

  procedure FormatIdentWithBracket(PreSpaceCount: Byte);
  var
    I, BracketCount, LessCount: Integer;
    IsGeneric: Boolean;
    GenericBookmark: TScannerBookmark;
  begin
    BracketCount := 0;
    while Scanner.Token = tokLB do
    begin
      Match(tokLB);
      Inc(BracketCount);
    end;

    FormatIdent(PreSpaceCount, True);

    // 这儿应该加入泛型判断
    IsGeneric := False;
    if Scanner.Token = tokLess then
    begin
      // 判断泛型，如果不是，恢复书签往下走；如果是，就恢复书签处理泛型
      Scanner.SaveBookmark(GenericBookmark);
      CodeGen.LockOutput;

      // 往后找，一直找到非类型的关键字或者分号或者文件尾。
      // 如果出现小于号和大于号一直不配对，则认为不是泛型。
      // TODO: 判断还是不太严密，待继续验证。
      Scanner.NextToken;
      LessCount := 1;
      while not (Scanner.Token in KeywordTokens + [tokSemicolon, tokEOF] - CanBeTypeKeywordTokens) do
      begin
        if Scanner.Token = tokLess then
          Inc(LessCount)
        else if Scanner.Token = tokGreat then
          Dec(LessCount);

        if LessCount = 0 then // Test<TObject><1 的情况，需要为 0 配对时就提前跳出
          Break;

        Scanner.NextToken;
      end;
      IsGeneric := (LessCount = 0);
      
      Scanner.LoadBookmark(GenericBookmark);
      CodeGen.UnLockOutput;
    end;

    if IsGeneric then
      FormatTypeParams;

    for I := 1 to BracketCount do
      Match(tokRB);
  end;

begin
  if Scanner.Token = tokLB then
  begin
    Match(tokLB, PreSpaceCount);
    FormatDesignator;

    if Scanner.Token = tokKeywordAs then
    begin
      Match(tokKeywordAs, 1, 1);
      FormatIdentWithBracket(0);
    end;
    Match(tokRB);
  end
  else
  begin
    FormatIdentWithBracket(PreSpaceCount);
    // 暂时不处理 UnitId 的情形
  end;
end;

{
  SetConstructor -> '[' [SetElement/','...] ']'
  SetElement -> Expression ['..' Expression]
}
procedure TCnBasePascalFormatter.FormatSetConstructor(PreSpaceCount: Byte);

  procedure FormatSetElement;
  begin
    FormatExpression;

    if Scanner.Token = tokRange then
    begin
      Match(tokRange);
      FormatExpression;
    end;
  end;
  
begin
  Match(tokSLB);
  SpecifyElementType(pfetSetConstructor);
  try
    if Scanner.Token <> tokSRB then
    begin
      FormatSetElement;
    end;

    while Scanner.Token = tokComma do
    begin
      MatchOperator(tokComma);
      FormatSetElement;
    end;

    Match(tokSRB);
  finally
    RestoreElementType;
  end;
end;

{ SimpleExpression -> ['+' | '-' | '^'] Term [AddOp Term]... }
procedure TCnBasePascalFormatter.FormatSimpleExpression(
  PreSpaceCount: Byte; IndentForAnonymous: Byte);
var
  OldTab: Integer;
begin
  if Scanner.Token in [tokPlus, tokMinus, tokHat] then // ^H also support
  begin
    Match(Scanner.Token, PreSpaceCount);
    FormatTerm(0, IndentForAnonymous);
  end
  else if Scanner.Token in [tokKeywordFunction, tokKeywordProcedure] then
  begin
    if CnPascalCodeForRule.KeepUserLineBreak then
      FCodeGen.TrimLastEmptyLine;  // 保留换行时，前面的内容可能多输出了空格，要删除

    EnsureWriteln; // 保留换行时，匿名函数前面可能有回车，不能直接 Writeln 以避免出现俩回车

    // 匿名函数内部改为不保留换行
    FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
    OldTab := FCurrentTab;
    FNeedKeepLineBreak := False;
    try
      // Anonymous function/procedure. 匿名函数的缩进使用 IndentForAnonymous 参数
      if Scanner.Token = tokKeywordProcedure then
        FormatProcedureDecl(Tab(IndentForAnonymous), True)
      else
        FormatFunctionDecl(Tab(IndentForAnonymous), True);
    finally
      FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);   // 恢复不保留换行的选项
      FCurrentTab := OldTab;
    end;
  end
  else
    FormatTerm(PreSpaceCount, IndentForAnonymous);

  while Scanner.Token in AddOpTokens do
  begin
    MatchOperator(Scanner.Token);
    FormatTerm(0, IndentForAnonymous);
  end;
end;

{ Term -> Factor [MulOp Factor]... }
procedure TCnBasePascalFormatter.FormatTerm(PreSpaceCount: Byte; IndentForAnonymous: Byte);
begin
  FormatFactor(PreSpaceCount, IndentForAnonymous);

  while Scanner.Token in (MulOPTokens + ShiftOpTokens) do
  begin
    MatchOperator(Scanner.Token);
    FormatFactor(0, IndentForAnonymous);
  end;
end;

// 泛型支持
procedure TCnBasePascalFormatter.FormatFormalTypeParamList(
  PreSpaceCount: Byte);
begin
  FormatTypeParams(PreSpaceCount); // 两者等同，直接调用
end;

{TypeParamDecl -> TypeParamList [ ':' ConstraintList ]}
procedure TCnBasePascalFormatter.FormatTypeParamDecl(PreSpaceCount: Byte);
begin
  FormatTypeParamList(PreSpaceCount);
  if Scanner.Token = tokColon then // ConstraintList
  begin
    Match(tokColon);
    FormatIdentList(PreSpaceCount, True);
  end;
end;

{ TypeParamDeclList -> TypeParamDecl/';'... }
procedure TCnBasePascalFormatter.FormatTypeParamDeclList(
  PreSpaceCount: Byte);
begin
  FormatTypeParamDecl(PreSpaceCount);
  while Scanner.Token = tokSemicolon do
  begin
    Match(tokSemicolon);
    FormatTypeParamDecl(PreSpaceCount);
  end;
end;

{TypeParamList -> ( [ CAttrs ] [ '+' | '-' [ CAttrs ] ] Ident )/','...}
procedure TCnBasePascalFormatter.FormatTypeParamList(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);
  // 泛型中可能又套泛型
  while Scanner.Token = tokLess do
    FormatTypeParams(PreSpaceCount);

  while Scanner.Token = tokComma do // 暂不处理 CAttr
  begin
    Match(tokComma);
    FormatIdent(PreSpaceCount);
    // 泛型中可能又套泛型
    while Scanner.Token = tokLess do
      FormatTypeParams(PreSpaceCount);
  end;
end;

{ TypeParams -> '<' TypeParamDeclList '>' }
function TCnBasePascalFormatter.FormatTypeParams(PreSpaceCount: Byte;
  AllowFixEndGreateEqual: Boolean): Boolean;
begin
  Result := False;
  SpecifyElementType(pfetInGeneric);
  try
    Match(tokLess);
    FormatTypeParamDeclList(PreSpaceCount);
    if AllowFixEndGreateEqual and (Scanner.Token = tokGreatOrEqu) then
    begin
      // Match(tokGreatOrEqu, 0, 1); // 拆开 > 与 =
      WriteToken(tokGreat, 0, 1, False, False, False, '>');
      WriteToken(tokEQUAL, 0, 1, False, False, False, '=');
      Scanner.NextToken;

      Result := True;
    end
    else
      Match(tokGreat);
  finally
    RestoreElementType;
  end;
end;

procedure TCnBasePascalFormatter.FormatTypeParamIdent(PreSpaceCount: Byte);
begin
  FormatPossibleAmpersand;
  if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
    Match(Scanner.Token, PreSpaceCount); // 标识符中允许使用部分关键字

  while Scanner.Token = tokDot do
  begin
    Match(tokDot);
    FormatPossibleAmpersand;
    if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scanner.Token); // 也继续允许使用部分关键字，且不和之前的点或 & 隔开
  end;

  if Scanner.Token = tokLess then
    FormatTypeParams;
end;

procedure TCnBasePascalFormatter.FormatTypeParamIdentList(
  PreSpaceCount: Byte);
begin
  FormatTypeParamIdent(PreSpaceCount);

  while Scanner.Token = tokComma do
  begin
    Match(tokComma);
    FormatTypeParamIdent;
  end;
end;

{ TCnStatementFormater }

{ CaseLabel -> ConstExpr ['..' ConstExpr] }
procedure TCnBasePascalFormatter.FormatCaseLabel(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetCaseLabel);
  try
    FormatConstExpr(PreSpaceCount);

    if Scanner.Token = tokRange then
    begin
      Match(tokRange);
      FormatConstExpr;
    end;
  finally
    RestoreElementType;
  end;
end;

{ CaseSelector -> CaseLabel/','... ':' Statement }
procedure TCnBasePascalFormatter.FormatCaseSelector(PreSpaceCount: Byte);
var
  FIsSingleStatement: Boolean;
begin
  SpecifyElementType(pfetCaseLabelList);
  try
    FormatCaseLabel(PreSpaceCount);

    while Scanner.Token = tokComma do
    begin
      Match(tokComma);
      FormatCaseLabel;
    end;
  finally
    RestoreElementType;
  end;

  Match(tokColon);
  // 每个 caselabel 后的 begin 都换行，不受 begin 风格的影响
  Writeln;
  if Scanner.Token = tokKeywordBegin then // 得有 begin 才这样设置，否则会影响后续语句
    FNextBeginShouldIndent := True;

  if Scanner.Token <> tokSemicolon then
  begin
    FIsSingleStatement := CheckSingleStatementBegin(PreSpaceCount);
    FormatStatement(Tab(PreSpaceCount, False));
    CheckSingleStatementEnd(FIsSingleStatement, PreSpaceCount);
  end
  else // 是空语句就手工写缩进
    CodeGen.Write('', Tab(PreSpaceCount));
end;

{ CaseStmt -> CASE Expression OF CaseSelector/';'... [ELSE StmtList] [';'] END }
procedure TCnBasePascalFormatter.FormatCaseStmt(PreSpaceCount: Byte);
var
  HasElse: Boolean;
begin
  Match(tokKeywordCase, PreSpaceCount);
  FormatExpression(0, PreSpaceCount);
  Match(tokKeywordOf);
  Writeln;
  FormatCaseSelector(Tab(PreSpaceCount));

  while Scanner.Token in [tokSemicolon, tokKeywordEnd] do
  begin
    if Scanner.Token = tokSemicolon then
      Match(tokSemicolon);

    // else 之前的语句可能没有分号，保留换行时会多写行尾回车，因此这里要保证不多写回车
    CheckKeepLineBreakWriteln;
    if Scanner.Token in [tokKeywordElse, tokKeywordEnd] then
      Break;
    FormatCaseSelector(Tab(PreSpaceCount));
  end;

  HasElse := False;
  if Scanner.Token = tokKeywordElse then
  begin
    HasElse := True;
    if FLastToken = tokKeywordEnd then
      Writeln;
    // else 前不需要空一行
    Match(tokKeywordElse, PreSpaceCount, 1);
    Writeln;

    // else 是空块的情况下，避免多出一个换行
    if Scanner.Token <> tokKeywordEnd then
    begin
      // 匹配多个语句
      FormatStmtList(Tab(PreSpaceCount, False));
      // end 之前的语句可能没有分号，保留换行时会多写行尾回车，因此这里要保证不多写回车
      CheckKeepLineBreakWriteln;
    end;
  end;

  if Scanner.Token = tokSemicolon then
    Match(tokSemicolon);

  if HasElse then
  begin
    // end 之前的语句可能没有分号，保留换行时会多写行尾回车，因此这里要保证不多写回车
    if CnPascalCodeForRule.KeepUserLineBreak then  // 非保留换行模式下这里无需多写一个回车，else 后的 Writeln 已写了
      CheckKeepLineBreakWriteln;
  end;
  Match(tokKeywordEnd, PreSpaceCount);
end;

procedure TCnStatementFormatter.FormatCode(PreSpaceCount: Byte);
begin
  FormatStmtList(PreSpaceCount);
end;

{ CompoundStmt -> BEGIN StmtList END
               -> ASM ... END
}
procedure TCnBasePascalFormatter.FormatCompoundStmt(PreSpaceCount: Byte);
var
  OldKeepOneBlankLine: Boolean;
begin
  OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
  Scanner.KeepOneBlankLine := True;
  try
    case Scanner.Token of
      tokKeywordBegin:
        begin
          if (CnPascalCodeForRule.BeginStyle = bsNextLine) or FNextBeginShouldIndent
            or FCodeGen.NextOutputWillbeLineHead // 如果已输出的最后一行还没有其他元素，说明本行的 begin 必须缩进
            or not (FLastToken in [tokKeywordDo, tokKeywordElse, tokKeywordThen]) then
            Match(tokKeywordBegin, PreSpaceCount)
          else
            Match(tokKeywordBegin); // begin 前是否换行由外面控制，begin 前缩进这儿控制
          FNextBeginShouldIndent := False;

          Writeln;

          // 空块但 begin 后有注释的情况下，避免多出一个换行
          if Scanner.Token <> tokKeywordEnd then
          begin
            FormatStmtList(Tab(PreSpaceCount, False));
            // end 之前的语句可能没有分号，保留换行时会多写行尾回车，因此这里要保证不多写回车
            CheckKeepLineBreakWriteln;
          end;

          // 组合语句的 end 是不需要 padding 的，需要特意指明
          SpecifyElementType(pfetCompoundEnd);
          try
            Match(tokKeywordEnd, PreSpaceCount);
          finally
            RestoreElementType;
          end;
        end;

      tokKeywordAsm:
        begin
          FormatAsmBlock(PreSpaceCount);
        end;
    else
      ErrorTokens([tokKeywordBegin, tokKeywordAsm]);
    end;
  finally
    Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
  end;
end;

{ ForStmt -> FOR QualId               ':=' Expression (TO | DOWNTO) Expression DO Statement }
{                var Ident [':' Type] }
{ ForStmt -> FOR QualId               in Expression DO Statement }
{                var Ident [':' Type] }
procedure TCnBasePascalFormatter.FormatForStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordFor, PreSpaceCount);
  if Scanner.Token = tokKeywordVar then
  begin
    Match(tokKeywordVar);
    FormatIdent;

    if Scanner.Token = tokColon then
    begin
      Match(tokColon);
      FormatType;
    end;
  end
  else
    FormatQualId;

  case Scanner.Token of
    tokAssign:
      begin
        MatchOperator(tokAssign);
        FormatExpression(0, PreSpaceCount);

        if Scanner.Token in [tokKeywordTo, tokKeywordDownTo] then
          Match(Scanner.Token)
        else
          ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, ['to/downto', TokenToString(Scanner.Token)]);

        FormatExpression(0, PreSpaceCount);
      end;
    tokKeywordIn:
      begin
        Match(tokKeywordIn, 1, 1);
        FormatExpression(0, PreSpaceCount);
        { DONE: surport "for .. in .. do .." statment parser }
      end;
  else
    ErrorExpected(':= or in');
  end;

  SpecifyElementType(pfetDo);
  try
    Match(tokKeywordDo);
  finally
    RestoreElementType;
  end;

  CheckWriteBeginln; // 检查 do begin 是否同行

  if Scanner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;

  FIsSingleStatement := CheckSingleStatementBegin(PreSpaceCount);
  FormatStatement(Tab(PreSpaceCount));
  CheckSingleStatementEnd(FIsSingleStatement, PreSpaceCount);
end;

{ IfStmt -> IF Expression THEN Statement [ELSE Statement] }
procedure TCnBasePascalFormatter.FormatIfStmt(PreSpaceCount: Byte; AfterElseIgnorePreSpace: Boolean);
var
  OldKeepOneBlankLine, ElseAfterThen: Boolean;
begin
  if AfterElseIgnorePreSpace then // 是 else if，这个 if 紧跟 else，无需额外缩进
  begin
    SpecifyElementType(pfetIfAfterElse); // 但要考虑行注释后造成额外换行时的缩进
    try
      Match(tokKeywordIf);
    finally
      RestoreElementType;
    end;
  end
  else
  begin
    Match(tokKeywordIf, PreSpaceCount);
    FCurrentTab := PreSpaceCount;
  end;

  FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
  FNeedKeepLineBreak := True;

  try
    { TODO: Apply more if stmt rule }
    FormatExpression(0, PreSpaceCount);
  finally
    FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
  end;

  SpecifyElementType(pfetThen);
  try
    OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
    Scanner.KeepOneBlankLine := False;
    Match(tokKeywordThen);  // To Avoid 2 Empty Line after then in 'if True then (CRLFCRLF) else Exit;'
    Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
  finally
    RestoreElementType;
  end;

  CheckWriteBeginln; // 检查 if then begin 是否同行
  if Scanner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;

  ElseAfterThen := Scanner.Token = tokKeywordElse;
  FIsSingleStatement := CheckSingleStatementBegin(PreSpaceCount);
  FormatStatement(Tab(PreSpaceCount));
  CheckSingleStatementEnd(FIsSingleStatement, PreSpaceCount);

  if Scanner.Token = tokKeywordElse then
  begin
    if ElseAfterThen then // 如果 then 后紧跟 else，则 then 和 else 间空一行。
      EnsureOneEmptyLine
    else
      EnsureWriteln;
    // 如果保留换行，则 then 后的语句因为无分号，可能会因为原始语句的 else 换行了从而多生成一个回车
    // 此处不能直接 Writeln，得保证有且只有一个回车

    Match(tokKeywordElse, PreSpaceCount);

    if Scanner.Token = tokKeywordIf then // 处理 else if
    begin
      FCurrentTab := PreSpaceCount;
      FormatIfStmt(PreSpaceCount, True);
      FormatStatement(Tab(PreSpaceCount));
    end
    else
    begin
      CheckWriteBeginln; // 检查 else begin 是否同行
      if Scanner.Token = tokSemicolon then
        FStructStmtEmptyEnd := True;

      FIsSingleStatement := CheckSingleStatementBegin(PreSpaceCount);
      FormatStatement(Tab(PreSpaceCount));
      CheckSingleStatementEnd(FIsSingleStatement, PreSpaceCount);
    end;
  end;
end;

{ RepeatStmt -> REPEAT StmtList UNTIL Expression }
procedure TCnBasePascalFormatter.FormatRepeatStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordRepeat, PreSpaceCount, 1);
  Writeln;
  FormatStmtList(Tab(PreSpaceCount));
  // until 之前的语句可能没有分号，保留换行时会多写行尾回车，因此这里要保证不多写回车
  CheckKeepLineBreakWriteln;
  
  Match(tokKeywordUntil, PreSpaceCount);

  // until 后面的表达式也需保留换行
  FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
  FNeedKeepLineBreak := True;

  try
    FormatExpression(0, PreSpaceCount);
  finally
    FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
  end;
end;

{
  SimpleStatement -> Designator<ExprList> ['(' ExprList ')']
                  -> Designator<ExprList> ':=' Expression
                  -> INHERITED [SimpleStatement]
                  -> GOTO LabelId
                  -> '(' Statement ')'

  argh this doesn't take brackets into account
  as far as I can tell, typecasts like "(lcFoo as TComponent)" is a designator

  so is "Pointer(lcFoo)" so that you can do
  " Pointer(lcFoo) := Pointer(lcFoo) + 1;

  Niether does it take into account using property on returned object, e.g.
  qry.fieldbyname('line').AsInteger := 1;

  These can be chained indefinitely, as in
  foo.GetBar(1).Stuff['fish'].MyFudgeFactor.Default(2).Name := 'Jiim';

  补充：
  1. Designator 如果是以 ( 开头，比如 (a)^ := 1; 的情况，
     则难以和 '(' Statement ')' 区分。而且 Designator 自身也可能是括号嵌套
     现在的处理方法是，先关闭输出，按 Designator 处理（FormatDesignator 内部加了
     括号嵌套的处理机制），扫描处理完毕后看后续的符号以决定是 Designator 还是
     Simplestatement，然后再次回到起点打开输出继续处理。
}
procedure TCnBasePascalFormatter.FormatSimpleStatement(PreSpaceCount: Byte);
var
  Bookmark: TScannerBookmark;
  OldLastToken: TPascalToken;
  IsDesignator, OldInternalRaiseException: Boolean;

  // 包括 := 和函数调用以及泛型的情形，函数调用后还有利用返回值进行 ^. 的
  procedure FormatDesignatorAndOthers(PreSpaceCount: Byte);
  begin
    FormatDesignator(PreSpaceCount, PreSpaceCount);

    while Scanner.Token in [tokAssign, tokLB, tokLess] do
    begin
      case Scanner.Token of
        tokAssign:
          begin
            MatchOperator(tokAssign);
            FormatExpression(0, PreSpaceCount);
          end;

        tokLB: // 这里似乎很难进来，FormatDesignator 里都搞定了左小括号
          begin
            { DONE: deal with function call, save to symboltable }
            Match(tokLB);
            FormatExprList(0, PreSpaceCount);
            Match(tokRB);

            if Scanner.Token = tokHat then // 也进不了这里的指针，所以未处理连续指针也没事
              Match(tokHat);

            if Scanner.Token = tokDot then
            begin
              Match(tokDot);
              FormatSimpleStatement;
            end;
          end;
        tokLess:
          begin
            FormatTypeParams;
          end;
      end;
    end;
  end;
begin
  FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
  FNeedKeepLineBreak := True;
  FCurrentTab := PreSpaceCount;

  try
    case Scanner.Token of
      tokSymbol, tokAmpersand, tokAtSign, tokKeywordFinal, tokKeywordIn, tokKeywordOut,
      tokKeywordString, tokKeywordAlign, tokKeywordAt, tokInteger, tokFloat,
      tokKeywordContains, tokKeywordRequires, tokKeywordOperator,
      tokDirective_BEGIN..tokDirective_END, // 允许语句以部分关键字以及数字开头，其余和 CanBeSymbol 函数内部实现类似
      tokComplex_BEGIN..tokComplex_END:
        begin
          FormatDesignatorAndOthers(PreSpaceCount);
        end;

      tokKeywordInherited:
        begin
          {
            inherited can be:
            inherited;
            inherited Foo;
            inherited Foo(bar);
            inherited FooProp := bar;
            inherited FooProp[Bar] := Fish;
            bar :=  inherited FooProp[Bar];
          }
          Match(Scanner.Token, PreSpaceCount);

          if CanBeSymbol(Scanner.Token) then
            FormatSimpleStatement;
        end;

      tokKeywordGoto:
        begin
          Match(Scanner.Token, PreSpaceCount);
          { DONE: FormatLabel }
          FormatLabel;
        end;

      tokLB: // 括号开头的未必是 (Statement)，还可能是 (a)^ := 1 这种 Designator
        begin
          // found in D9 support: if ... then (...)

          // can delete the LB & RB, code optimize ??
          // 先当做 Designator 来看，处理完毕看后续有无 := ( 来判断是否结束
          // 如果是结束了，则 Designator 的处理是对的，否则按 Statement 来。

          Scanner.SaveBookmark(Bookmark);
          OldLastToken := FLastToken;
          OldInternalRaiseException := FInternalRaiseException;
          FInternalRaiseException := True;
          // 需要 Exception 来判断后续内容

          try
            CodeGen.LockOutput;

            try
              FormatDesignator(PreSpaceCount);
              // 假设 Designator 处理完毕，判断后续是啥

              IsDesignator := Scanner.Token in [tokAssign, tokLB, tokSemicolon,
                tokKeywordElse, tokKeywordEnd, tokKeywordExcept, tokKeywordUntil,
                tokKeywordFinally];
              // TODO: 目前只想到这几个。Semicolon 是怕 Designator 已经作为语句处理完了，
              // else/end 等是怕语句结束没分号导致判断失误。
            except
              IsDesignator := False;
              // 如果后面碰到了 := 等情形，FormatDesignator 会出错，
              // 说明本句是带括号嵌套的 Simplestatement
            end;
          finally
            Scanner.LoadBookmark(Bookmark);
            FLastToken := OldLastToken;
            if FLastToken <> tokBlank then
              FLastNonBlankToken := FLastToken;
            CodeGen.UnLockOutput;
            FInternalRaiseException := OldInternalRaiseException;
          end;

          if not IsDesignator then
          begin
            // Match(tokLB);  优化不用的括号
            Scanner.NextToken;

            FormatStatement(PreSpaceCount);

            if Scanner.Token = tokRB then // 跳过且优化不用的括号
              Scanner.NextToken
            else
              ErrorToken(tokRB);
          end
          else
          begin
            FormatDesignatorAndOthers(PreSpaceCount);
          end;
        end;
      tokKeywordVar: // 新语法，inline var
        begin
          // var 语句允许保持内部换行
          FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
          FNeedKeepLineBreak := True;
          try
            Match(Scanner.Token, PreSpaceCount);
            FormatInlineVarDecl(0, PreSpaceCount); // var 语句后面无需缩进，但 var 里头的匿名函数需要缩进
          finally
            FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
          end;
        end;
      tokKeywordConst:
        begin
          Match(Scanner.Token, PreSpaceCount);
          FormatConstantDecl;
        end;
    else
      Error(CN_ERRCODE_PASCAL_INVALID_STATEMENT);
    end;
  finally
    FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
  end;

  // 单个语句结束后可能没有分号，导致保留换行选项时，没有分号的行末换行也会被写出，需要砍掉
  if CnPascalCodeForRule.KeepUserLineBreak then
    FCodeGen.TrimLastEmptyLine;
end;

procedure TCnBasePascalFormatter.FormatLabel(PreSpaceCount: Byte);
begin
  if Scanner.Token = tokInteger then
    Match(tokInteger, PreSpaceCount)
  else
    Match(tokSymbol, PreSpaceCount);
end;

{ Statement -> [LabelId ':']/.. [SimpleStatement | StructStmt] }
procedure TCnBasePascalFormatter.FormatStatement(PreSpaceCount: Byte);
begin
  while Scanner.ForwardToken() = tokColon do
  begin
    // WriteLineFeedByPrevCondition;  label 前面不刻意留一行，怕 begin 后空行显得难看
    FormatLabel;
    Match(tokColon);

    Writeln;
  end;

  // 允许语句以部分关键字开头，比如变量名等
  if Scanner.Token in SimpStmtTokens + DirectiveTokens + ComplexTokens +
    StmtKeywordTokens + CanBeNewIdentifierTokens then
    FormatSimpleStatement(PreSpaceCount)
  else if Scanner.Token in StructStmtTokens then
  begin
    FormatStructStmt(PreSpaceCount);
  end;
  { Do not raise error here, Statement maybe empty }
end;

{ StmtList -> Statement/';'... }
procedure TCnBasePascalFormatter.FormatStmtList(PreSpaceCount: Byte);
var
  OldKeepOneBlankLine: Boolean;
begin
  OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
  Scanner.KeepOneBlankLine := True;
  try
    // 处理空语句单独分行的问题
    while Scanner.Token = tokSemicolon do
    begin
      Match(tokSemicolon, PreSpaceCount, 0, False, True);
      if not (Scanner.Token in [tokKeywordEnd, tokKeywordUntil, tokKeywordExcept,
        tokKeywordFinally, tokKeywordFinalization]) then // 这些关键字自身会分行，所以无需此处分行
        Writeln;
    end;

    FormatStatement(PreSpaceCount);

    while Scanner.Token = tokSemicolon do
    begin
      if FStructStmtEmptyEnd then
      begin
        FStructStmtEmptyEnd := False;
        Match(tokSemicolon, Tab(PreSpaceCount), 0, False, True);
      end
      else
        Match(tokSemicolon);
      // 输出语句间的分割分号用，但如果前一句的子语句为空，如if True then ;
      // 则本句就可能顶行首去了，需要在 FormatStructStmt 里头标记并控制

      // 处理空语句单独分行的问题
      while Scanner.Token = tokSemicolon do
      begin
        Writeln;
        Match(tokSemicolon, PreSpaceCount, 0, False, True);
      end;

      if Scanner.Token in StmtTokens + DirectiveTokens + ComplexTokens
        + [tokInteger] + StmtKeywordTokens then // 部分关键字能做语句开头，Label 可能以数字开头
      begin
        { DONE: 建立语句列表 }
        Writeln;
        FormatStatement(PreSpaceCount);
      end;
    end;
  finally
    Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
  end;
end;

{
  StructStmt -> CompoundStmt
             -> ConditionalStmt
             -> LoopStmt
             -> WithStmt
             -> TryStmt
}
procedure TCnBasePascalFormatter.FormatStructStmt(PreSpaceCount: Byte);
begin
  FStructStmtEmptyEnd := False;
  case Scanner.Token of
    tokKeywordBegin,
    tokKeywordAsm:    FormatCompoundStmt(PreSpaceCount);
    tokKeywordIf:     FormatIfStmt(PreSpaceCount);
    tokKeywordCase:   FormatCaseStmt(PreSpaceCount);
    tokKeywordRepeat: FormatRepeatStmt(PreSpaceCount);
    tokKeywordWhile:  FormatWhileStmt(PreSpaceCount);
    tokKeywordFor:    FormatForStmt(PreSpaceCount);
    tokKeywordWith:   FormatWithStmt(PreSpaceCount);
    tokKeywordTry:    FormatTryStmt(PreSpaceCount);
    tokKeywordRaise:  FormatRaiseStmt(PreSpaceCount);
  else
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, ['Statement', TokenToString(Scanner.Token)]);
  end;
end;

{
  TryEnd -> FINALLY StmtList END
         -> EXCEPT [ StmtList | (ExceptionHandler/;... [ELSE Statement]) ] [';'] END
}
procedure TCnBasePascalFormatter.FormatTryEnd(PreSpaceCount: Byte);
var
  HasOn: Boolean;
begin
  case Scanner.Token of
    tokKeywordFinally:
      begin
        Match(Scanner.Token, PreSpaceCount);
        Writeln;
        if Scanner.Token <> tokKeywordEnd then
        begin
          FormatStmtList(Tab(PreSpaceCount, False));
          // end 语句可能没有分号，保留换行时会多写行尾回车，因此这里要保证不多写回车
          CheckKeepLineBreakWriteln;
        end;
        Match(tokKeywordEnd, PreSpaceCount);
      end;
    tokKeywordExcept:
      begin
        Match(Scanner.Token, PreSpaceCount);
        if Scanner.Token <> tokKeywordEnd then // 避免紧跟时多出空行
        begin
          if not (Scanner.Token in [tokKeywordOn, tokKeywordElse]) then
          begin
            Writeln;
            FormatStmtList(Tab(PreSpaceCount, False))
          end
          else
          begin
            HasOn := False;
            while Scanner.Token = tokKeywordOn do
            begin
              HasOn := True;
              Writeln;
              FormatExceptionHandler(Tab(PreSpaceCount, False));
            end;

            // Else 是属于 try except end 块的，这里做了个小处理，
            // 无 on 时和 except 对齐，有 on 时和缩进的 on 对齐
            if Scanner.Token = tokKeywordElse then
            begin
              Writeln;
              if HasOn then
                Match(tokKeywordElse, Tab(PreSpaceCount), 1)
              else
                Match(tokKeywordElse, PreSpaceCount, 1);

              Writeln;
              if HasOn then
                FormatStmtList(Tab(Tab(PreSpaceCount, False), False))
              else
                FormatStmtList(Tab(PreSpaceCount, False));
            end;

            if Scanner.Token = tokSemicolon then
              Match(tokSemicolon);
          end;
        end;

        // except 的 end 之前的语句可能没有分号，保留换行时会多写行尾回车，因此这里要保证不多写回车
        CheckKeepLineBreakWriteln;

        Match(tokKeywordEnd, PreSpaceCount);
      end;
  else
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, ['except/finally', Scanner.TokenString]);
  end;
end;

{
  ExceptionHandler -> ON [ident :] Type do Statement
}
procedure TCnBasePascalFormatter.FormatExceptionHandler(PreSpaceCount: Byte);
var
  OnlySemicolon: Boolean;
begin
  Match(tokKeywordOn, PreSpaceCount);

  // On Exception class name allow dot
  Match(tokSymbol);
  while Scanner.Token = tokDot do
  begin
    Match(Scanner.Token);
    Match(tokSymbol);
  end;

  if Scanner.Token = tokColon then
  begin
    Match(tokColon);
    Match(tokSymbol);

    // On Exception class name allow dot
    while Scanner.Token = tokDot do
    begin
      Match(Scanner.Token);
      Match(tokSymbol);
    end;
  end;

  SpecifyElementType(pfetDo);
  try
    Match(tokKeywordDo);
  finally
    RestoreElementType;
  end;

  CheckWriteBeginln; // 检查 do begin 是否同行;

  OnlySemicolon := Scanner.Token = tokSemicolon;
  FIsSingleStatement := CheckSingleStatementBegin(PreSpaceCount);
  FormatStatement(Tab(PreSpaceCount));
  CheckSingleStatementEnd(FIsSingleStatement, PreSpaceCount);

  if Scanner.Token = tokSemicolon then
  begin
    if OnlySemicolon then
      Match(tokSemicolon, Tab(PreSpaceCount), 0, False, True)
    else
      Match(tokSemicolon);
  end;
end;

{ TryStmt -> TRY StmtList TryEnd }
procedure TCnBasePascalFormatter.FormatTryStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordTry, PreSpaceCount);
  Writeln;
  if not (Scanner.Token in [tokKeywordExcept, tokKeywordFinally]) then // 避免空行
  begin
    FormatStmtList(Tab(PreSpaceCount, False));
    // Except/Finally 之前的语句可能没有分号，保留换行时会多写行尾回车，因此这里要保证不多写回车
    CheckKeepLineBreakWriteln; 
  end;
  FormatTryEnd(PreSpaceCount);
end;

{ WhileStmt -> WHILE Expression DO Statement }
procedure TCnBasePascalFormatter.FormatWhileStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordWhile, PreSpaceCount);

  // while 后的表达式要保留换行
  FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
  FNeedKeepLineBreak := True;

  try
    FormatExpression(0, PreSpaceCount);
  finally
    FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
  end;

  SpecifyElementType(pfetDo);
  try
    Match(tokKeywordDo);
  finally
    RestoreElementType;
  end;

  CheckWriteBeginln; // 检查 do begin 是否同行

  if Scanner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;
  FIsSingleStatement := CheckSingleStatementBegin(PreSpaceCount);
  FormatStatement(Tab(PreSpaceCount));
  CheckSingleStatementEnd(FIsSingleStatement, PreSpaceCount);
end;

{ WithStmt -> WITH IdentList DO Statement }
procedure TCnBasePascalFormatter.FormatWithStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordWith, PreSpaceCount);
  // FormatDesignatorList; // Grammer error.

  FormatExpression(0, PreSpaceCount);
  while Scanner.Token = tokComma do
  begin
    MatchOperator(tokComma);
    FormatExpression(0, PreSpaceCount);
  end;

  SpecifyElementType(pfetDo);
  try
    Match(tokKeywordDo);
  finally
    RestoreElementType;
  end;

  CheckWriteBeginln; // 检查 do begin 是否同行

  if Scanner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;
  FIsSingleStatement := CheckSingleStatementBegin(PreSpaceCount);
  FormatStatement(Tab(PreSpaceCount));
  CheckSingleStatementEnd(FIsSingleStatement, PreSpaceCount);
end;

{ RaiseStmt -> RAISE [ Expression | Expression AT Expression ] }
procedure TCnBasePascalFormatter.FormatRaiseStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordRaise, PreSpaceCount);

  if not (Scanner.Token in [tokSemicolon, tokKeywordEnd, tokKeywordElse]) then
    FormatExpression(0, PreSpaceCount);

  if Scanner.Token = tokKeywordAt then
  begin
    SpecifyElementType(pfetRaiseAt);
    try
      Match(Scanner.Token);
      FormatExpression(0, PreSpaceCount);
    finally
      RestoreElementType;
    end;
  end;
end;

{ AsmBlock -> AsmStmtList 按自定义规矩格式化}
procedure TCnBasePascalFormatter.FormatAsmBlock(PreSpaceCount: Byte);
var
  NewLine, AfterKeyword, IsLabel, HasAtSign: Boolean;
  T: TPascalToken;
  Bookmark: TScannerBookmark;
  OldLastToken: TPascalToken;
  LabelLen, InstrucLen: Integer;
  ALabel: string;
  OldKeywordStyle: TCnKeywordStyle;
begin
  Match(tokKeywordAsm, PreSpaceCount);
  Writeln;
  Scanner.ASMMode := True;
  SpecifyElementType(pfetAsm);

  OldKeywordStyle := CnPascalCodeForRule.KeywordStyle;
  CnPascalCodeForRule.KeywordStyle := ksUpperCaseKeyword; // 临时替换

  try
    NewLine := True;
    AfterKeyword := False;
    InstrucLen := 0;
    IsLabel := False;

    while (Scanner.Token <> tokKeywordEnd) or
      ((Scanner.Token = tokKeywordEnd) and (FLastToken = tokAtSign)) do
    begin
      T := Scanner.Token;
      Scanner.SaveBookmark(Bookmark);
      OldLastToken := FLastToken;
      CodeGen.LockOutput;

      if NewLine then // 行首，要检测label
      begin
        LabelLen := 0;
        ALabel := '';
        HasAtSign := False;
        AfterKeyword := False;
        InstrucLen := Length(Scanner.TokenString); // 记住可能是的汇编指令关键字的长度

        while Scanner.Token in [tokAtSign, tokSymbol, tokInteger, tokAsmHex] + KeywordTokens +
          DirectiveTokens + ComplexTokens do
        begin
          if Scanner.Token = tokAtSign then
          begin
            HasAtSign := True;
            ALabel := ALabel + '@';
            Inc(LabelLen);
            Scanner.NextToken;
          end
          else if Scanner.Token in [tokSymbol, tokInteger, tokAsmHex] + KeywordTokens +
            DirectiveTokens + ComplexTokens then // 关键字可以做 label 名
          begin
            ALabel := ALabel + Scanner.TokenString;
            Inc(LabelLen, Length(Scanner.TokenString));

            Scanner.NextToken;
          end;
        end;
        // 跳过了一个可能是 label 的，首以 @ 开头的才是 label
        IsLabel := HasAtSign and (Scanner.Token = tokColon);
        if IsLabel then
        begin
          Inc(LabelLen);
          ALabel := ALabel + ':';
        end;

        // 如果是 label，那么 ALabel 里头已经放入 label 了，所以不需要 LoadBookmark 了
        if IsLabel then
        begin
          // Match(Scaner.Token);
          CodeGen.UnLockOutput;
          Writeln;
          CodeGen.Write(ALabel); // 写入 label，再写剩下的关键字前的空格
          if CnPascalCodeForRule.SpaceBeforeASM - LabelLen <= 0 then // Label 太长就换行
          begin
            // Writeln;
            CodeGen.Write(Space(CnPascalCodeForRule.SpaceBeforeASM));
          end
          else
            CodeGen.Write(Space(CnPascalCodeForRule.SpaceBeforeASM - LabelLen));
          Scanner.NextToken; // 跳过 label 的冒号
          InstrucLen := Length(Scanner.TokenString); // 记住应该是的汇编指令关键字的长度
        end
        else // 不是 Label 的话，回到开头
        begin
          Scanner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;
          if FLastToken <> tokBlank then
            FLastNonBlankToken := FLastToken;
          CodeGen.UnLockOutput;
          
          Match(Scanner.Token, CnPascalCodeForRule.SpaceBeforeASM);
          AfterKeyword := True;
        end;
      end
      else
      begin
        CodeGen.ClearOutputLock;

        if AfterKeyword and not (Scanner.Token in [tokCRLF, tokSemicolon]) then // 第一字后面必须有空格
        begin
          if InstrucLen >= CnPascalCodeForRule.SpaceTabASMKeyword then
            WriteOneSpace
          else
            CodeGen.Write(Space(CnPascalCodeForRule.SpaceTabASMKeyword - InstrucLen));
        end;

        if Scanner.Token <> tokCRLF then
        begin
          if AfterKeyword then // 手工写入 ASM 关键字后面的内容，不用 Pascal 的空格规则
          begin
            CodeGen.Write(Scanner.TokenString);
            FLastToken := Scanner.Token;
            if FLastToken <> tokBlank then
              FLastNonBlankToken := FLastToken;
            Scanner.NextToken;
            AfterKeyword := False;
          end
          else if IsLabel then // 如果前一个是 label，则这个是第一个 Keyword
          begin
            CodeGen.Write(Scanner.TokenString);
            FLastToken := Scanner.Token;
            if FLastToken <> tokBlank then
              FLastNonBlankToken := FLastToken;
            Scanner.NextToken;
            IsLabel := False;
            AfterKeyword := True;
          end
          else
          begin
            if Scanner.Token = tokColon then
              Match(Scanner.Token, 0, 0, True)
            else if Scanner.Token in (AddOPTokens + MulOPTokens + [tokKeywordNot]) then
              Match(Scanner.Token, 1, 1) // 二元运算符前后各空一格
            else if (FLastToken in CanBeNewIdentifierTokens) and
              (UpperCase(Scanner.TokenString) = 'H') then
              Match(Scanner.Token, 0, 0, False, False, True) // 修补数字开头的十六进制与 H 间的空格，但不完善
            else
              Match(Scanner.Token);
            AfterKeyword := False;
          end;
        end;
      end;

      // if not OnlyKeyword then
      NewLine := False;

      if (T = tokSemicolon) or (Scanner.Token = tokCRLF) or
        ((Scanner.Token = tokKeywordEnd) and (FLastToken <> tokAtSign)) then
      begin
        Writeln;
        NewLine := True;
        while Scanner.Token in [tokBlank, tokCRLF] do
          Scanner.NextToken;
      end;
    end;
  finally
    Scanner.ASMMode := False;
    RestoreElementType;
    if Scanner.Token in [tokBlank, tokCRLF] then
      Scanner.NextToken;
    CnPascalCodeForRule.KeywordStyle := OldKeywordStyle; // 恢复 KeywordStyle
    Match(tokKeywordEnd, PreSpaceCount);
  end;
end;

{ TCnTypeSectionFormater }

{ ArrayConstant -> '(' TypedConstant/','... ')' }
procedure TCnBasePascalFormatter.FormatArrayConstant(PreSpaceCount: Byte);
var
  OldKeepOneBlankLine: Boolean;
begin
  Match(tokLB);
  OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
  Scanner.KeepOneBlankLine := False; // 嵌套数组声明中无需保留原有内部的至少一行换行的模式
                                    // 不等于保留换行的选项
  SpecifyElementType(pfetArrayConstant);

  try
    FormatTypedConstant(PreSpaceCount);

    while Scanner.Token = tokComma do
    begin
      Match(Scanner.Token);
      FormatTypedConstant(PreSpaceCount);
    end;

    Match(tokRB);
  finally
    Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
    RestoreElementType;
  end;
end;

{ ArrayType -> ARRAY ['[' OrdinalType/','... ']'] OF Type }
procedure TCnBasePascalFormatter.FormatArrayType(PreSpaceCount: Byte);
begin
  Match(tokKeywordArray);

  if Scanner.Token = tokSLB then
  begin
    Match(tokSLB);
    FormatOrdinalType;

    while Scanner.Token = tokComma do
    begin
      Match(Scanner.Token);
      FormatOrdinalType;
    end;

    Match(tokSRB);
  end;

  Match(tokkeywordOf);
  FormatType(PreSpaceCount);
end;

{ ClassFieldList -> (ClassVisibility ObjFieldList)/';'... }
procedure TCnBasePascalFormatter.FormatClassFieldList(PreSpaceCount: Byte);
begin
  FormatClassVisibility(PreSpaceCount);
  FormatObjFieldList(PreSpaceCount);
  Match(tokSemicolon);

  while (Scanner.Token in ClassVisibilityTokens) or (Scanner.Token = tokSymbol) do
  begin
    if Scanner.Token in ClassVisibilityTokens then
      FormatClassVisibility(PreSpaceCount);

    FormatObjFieldList(PreSpaceCount);
    Match(tokSemicolon);
  end;
end;

{ ClassHeritage -> '(' IdentList ')' }
procedure TCnBasePascalFormatter.FormatClassHeritage(PreSpaceCount: Byte);
begin
  Match(tokLB);
  FormatTypeParamIdentList(); // 加入泛型的支持
  Match(tokRB);
end;

{ ClassMethodList -> (ClassVisibility MethodList)/';'... }
procedure TCnBasePascalFormatter.FormatClassMethodList(PreSpaceCount: Byte);
begin
  FormatClassVisibility(PreSpaceCount);
  FormatMethodList(PreSpaceCount);

  while Scanner.Token = tokSemicolon do
  begin
    FormatClassVisibility(PreSpaceCount);
    FormatMethodList(PreSpaceCount);
  end;
end;

{ ClassPropertyList -> (ClassVisibility PropertyList ';')... }
procedure TCnBasePascalFormatter.FormatClassPropertyList(PreSpaceCount: Byte);
begin
  FormatClassVisibility(PreSpaceCount);
  FormatPropertyList(PreSpaceCount);
  if Scanner.Token = tokSemicolon then
    Match(tokSemicolon);

  { TODO: Need Scaner forward look future }
  while (Scanner.Token in ClassVisibilityTokens) or (Scanner.Token = tokKeywordProperty) do
  begin
    if Scanner.Token in ClassVisibilityTokens then
      FormatClassVisibility(PreSpaceCount);
    Writeln;
    FormatPropertyList(PreSpaceCount);
    if Scanner.Token = tokSemicolon then
      Match(tokSemicolon);
  end;
end;

{ ClassRefType -> CLASS OF TypeId }
procedure TCnBasePascalFormatter.FormatClassRefType(PreSpaceCount: Byte);
begin
  Match(tokkeywordClass);
  Match(tokKeywordOf);

  { TypeId -> [UnitId '.'] <type-identifier> }
  Match(tokSymbol);
  while Scanner.Token = tokDot do
  begin
    Match(Scanner.Token);
    Match(tokSymbol);
  end;
end;

{
  ClassType -> CLASS [ClassHeritage]
               [ClassFieldList]
               [ClassMethodList]
               [ClassPropertyList]
               END
}
{
  TODO:  This grammer has something wrong...need to be fixed.

  My current FIXED grammer:

  ClassType -> CLASS (OF Ident) | ClassBody
  ClassBody -> [ClassHeritage] [ClassMemberList END]
  ClassMemberList -> ([ClassVisibility] [ClassMember ';']) ...
  ClassMember -> ClassField | ClassMethod | ClassProperty

  
  Here is some note in JCF:
  =============Cut Here=============
  ClassType -> CLASS [ClassHeritage]
       [ClassFieldList]
       [ClassMethodList]
       [ClassPropertyList]
       END

  This is not right - these can repeat

  My own take on this is as follows:

  class -> ident '=' 'class' [Classheritage] classbody 'end'
  classbody -> clasdeclarations (ClassVisibility clasdeclarations) ...
  ClassVisibility -> 'private' | 'protected' | 'public' | 'published' | 'automated'
  classdeclarations -> (procheader|fnheader|constructor|destructor|vars|property|) [';'] ...

  can also be a forward declaration, e.g.
    TFred = class;

  or a class ref type
    TFoo = class of TBar;

  or a class helper
    TFoo = class helper for TBar
  =============Cut End==============
}
procedure TCnBasePascalFormatter.FormatClassType(PreSpaceCount: Byte);
begin
  Match(tokKeywordClass);
  if Scanner.Token = tokSemiColon then // class declare forward, like TFoo = class;
    Exit;

  if Scanner.Token = tokKeywordOF then  // like TFoo = class of TBar;
  begin
    Match(tokKeywordOF);
    FormatIdent;
    Exit;
  end
  else if (Scanner.Token = tokSymbol) and (Scanner.ForwardToken = tokKeywordFor)
    and (LowerCase(Scanner.TokenString) = 'helper') then
  begin
    // class helper for Ident
    Match(Scanner.Token);
    Match(tokKeywordFor);
    FormatIdent(0);
  end;

  if Scanner.Token in [tokKeywordSealed, tokDirectiveABSTRACT] then // TFoo = class sealed
    Match(Scanner.Token);

  FormatClassBody(PreSpaceCount);
end;

{ ClassVisibility -> [PUBLIC | PROTECTED | PRIVATE | PUBLISHED] }
procedure TCnBasePascalFormatter.FormatClassVisibility(PreSpaceCount: Byte);
begin
  if Scanner.Token = tokKeywordStrict then
  begin
    Match(Scanner.Token, PreSpaceCount);
    if Scanner.Token in ClassVisibilityTokens then
    begin
      Match(Scanner.Token);
      Writeln;
    end;
  end
  else if Scanner.Token in ClassVisibilityTokens then
  begin
    Match(Scanner.Token, PreSpaceCount);
    Writeln;
  end;
end;

{ ConstructorHeading -> CONSTRUCTOR Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatConstructorHeading(PreSpaceCount: Byte);
begin
  Match(tokKeywordConstructor, PreSpaceCount);
  FormatMethodName;

  if Scanner.Token = tokLB then
    FormatFormalParameters;
end;

{ ContainsClause -> CONTAINS IdentList... ';' }
procedure TCnBasePascalFormatter.FormatContainsClause(PreSpaceCount: Byte);
begin
  if Scanner.TokenSymbolIs('CONTAINS') then
  begin
    Match(Scanner.Token, 0, 1);
    FormatIdentList;
    Match(tokSemicolon);
  end;
end;

{ DestructorHeading -> DESTRUCTOR Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatDestructorHeading(PreSpaceCount: Byte);
begin
  Match(tokKeywordDestructor, PreSpaceCount);
  FormatMethodName;

  if Scanner.Token = tokLB then
    FormatFormalParameters;
end;

{ VarDecl -> IdentList ':' Type [(ABSOLUTE (Ident | ConstExpr)) | '=' TypedConstant] }
procedure TCnBasePascalFormatter.FormatVarDeclHeading(PreSpaceCount: Byte;
  IsClassVar: Boolean);
begin
  if Scanner.Token in [tokKeywordVar, tokKeywordThreadVar] then
  begin
    if IsClassVar then
      Match(Scanner.Token)
    else
      Match(Scanner.Token, BackTab(PreSpaceCount));
  end;
  
  repeat
    Writeln;
    
    FormatClassVarIdentList(PreSpaceCount);
    if Scanner.Token = tokColon then // 放宽语法限制
    begin
      Match(tokColon);
      FormatType(PreSpaceCount); // 长 Type 可能换行，必须传入
    end;

    if Scanner.Token = tokEQUAL then
    begin
      Match(Scanner.Token, 1, 1);
      FormatTypedConstant;
    end
    else if Scanner.TokenSymbolIs('ABSOLUTE') then
    begin
      Match(Scanner.Token);
      FormatConstExpr; // include indent
    end;

    while Scanner.Token in DirectiveTokens do
      FormatDirective;

    if Scanner.Token = tokSemicolon then
      Match(tokSemicolon);
  until Scanner.Token in ClassMethodTokens + ClassVisibilityTokens + [tokKeywordEnd,
    tokEOF, tokKeywordCase, tokKeywordConst, tokKeywordProperty];
    // 出现这些，认为 class var 区结束，包括 record 可能出现的 case
end;

{ IdentList -> [Attribute] Ident/','... }
procedure TCnBasePascalFormatter.FormatClassVarIdentList(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  FormatClassVarIdent(PreSpaceCount, CanHaveUnitQual);

  while Scanner.Token = tokComma do
  begin
    Match(tokComma);
    FormatClassVarIdent(0, CanHaveUnitQual);
  end;
end;

procedure TCnBasePascalFormatter.FormatClassVarIdent(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
var
  HasAmpersand: Boolean;
begin
  while Scanner.Token = tokSLB do // Attribute
  begin
    FormatSingleAttribute(PreSpaceCount);
    Writeln;
  end;

  HasAmpersand := FormatPossibleAmpersand(PreSpaceCount);
  if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
  begin
    if HasAmpersand then
      Match(Scanner.Token)                 // 前面有 & 时不能将自己缩进
    else
      Match(Scanner.Token, PreSpaceCount); // 标识符中允许使用部分关键字
  end;

  while CanHaveUnitQual and (Scanner.Token = tokDot) do
  begin
    Match(tokDot);
    FormatPossibleAmpersand;
    if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scanner.Token); // 也继续允许使用部分关键字，且不和之前的点或&隔开
  end;
end;

{
  Directive -> CDECL
            -> REGISTER
            -> DYNAMIC
            -> VIRTUAL
            -> EXPORT
            -> EXTERNAL
            -> FAR
            -> FORWARD
            -> MESSAGE
            -> OVERRIDE
            -> OVERLOAD
            -> PASCAL
            -> REINTRODUCE
            -> SAFECALL
            -> STDCALL

  注：Directive 分两种，一是上面说的大多在函数过程声明后的，可能需要分号分隔
  一种是类型或其他声明后的，platform library 等，无需分号分隔的。
}
procedure TCnBasePascalFormatter.FormatDirective(PreSpaceCount: Byte;
  IgnoreFirst: Boolean);
begin
  try
    SpecifyElementType(pfetDirective);
    if Scanner.Token in DirectiveTokens + ComplexTokens then
    begin
      // deal with the Directive use like this
      // function MessageBox(...): Integer; stdcall; external 'user32.dll' name 'MessageBoxA';
  {
      while not (Scaner.Token in [tokSemicolon] + KeywordTokens) do
      begin
        CodeGen.Write(FormatString(Scaner.TokenString, CnCodeForRule.KeywordStyle), 1);
        FLastToken := Scaner.Token;
        Scaner.NextToken;
      end;
  }
      if Scanner.Token in [   // 这些是后面可以加参数的
        tokDirectiveDispID,
        tokDirectiveExternal,
        tokDirectiveMESSAGE,
        tokDirectiveDEPRECATED,
        tokComplexName,
        tokComplexImplements,
        tokComplexStored,
        tokComplexRead,
        tokComplexWrite,
        tokComplexIndex
      ] then
      begin
        if not IgnoreFirst then
          WriteOneSpace; // 非第一个 Directive，和之前的内容空格分隔
        WriteToken(Scanner.Token, 0, 0, False, False, True);
        Scanner.NextToken;

        if not (Scanner.Token in DirectiveTokens) then // 加个后续的表达式
        begin
          if Scanner.Token in [tokString, tokWString, tokMString, tokLB, tokPlus, tokMinus] then
            WriteOneSpace; // 后续表达式空格分隔
          FormatConstExpr;
        end;
        //  Match(Scaner.Token);
      end
      else
      begin
        if not IgnoreFirst then
          WriteOneSpace; // 非第一个 Directive，和之前的内容空格分隔
        WriteToken(Scanner.Token, 0, 0, False, False, True);
        Scanner.NextToken;
      end;
    end
    else
      Error(CN_ERRCODE_PASCAL_ERROR_DIRECTIVE);
  finally
    RestoreElementType;
  end;
end;

{ EnumeratedType -> '(' EnumeratedList ')' }
procedure TCnBasePascalFormatter.FormatEnumeratedType(PreSpaceCount: Byte);
begin
  // 枚举类型允许保持内部换行
  FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
  FNeedKeepLineBreak := True;
  try
    Match(tokLB, PreSpaceCount);
    FormatEnumeratedList;
    Match(tokRB);
  finally
    FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
  end;
end;

{ EnumeratedList -> EmumeratedIdent/','... }
procedure TCnBasePascalFormatter.FormatEnumeratedList(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetEnumList);
  try
    FormatEmumeratedIdent(PreSpaceCount);
    while Scanner.Token = tokComma do
    begin
      Match(tokComma);
      FormatEmumeratedIdent;
    end;
  finally
    RestoreElementType;
  end;
end;

{ EmumeratedIdent -> [&] Ident ['=' ConstExpr] }
procedure TCnBasePascalFormatter.FormatEmumeratedIdent(PreSpaceCount: Byte);
begin
//  if Scaner.Token = tokAndSign then // e.g. TAnimationType = (&In, Out, InOut);
//    Match(tokAndSign);              // Moved to FormatIdent
    
  FormatIdent(PreSpaceCount);
  if Scanner.Token = tokEQUAL then
  begin
    Match(tokEQUAL, 1, 1);
    FormatConstExpr;
  end;
end;

{ FieldDecl -> IdentList ':' Type }
procedure TCnBasePascalFormatter.FormatFieldDecl(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetFieldDecl);
  try
    FormatIdentList(PreSpaceCount);
    Match(tokColon);
    FormatType(PreSpaceCount);
  finally
    RestoreElementType;
  end;
end;

{ FieldList ->  FieldDecl/';'... [VariantSection] [';'] }
function TCnBasePascalFormatter.FormatFieldList(PreSpaceCount: Byte;
  IgnoreFirst: Boolean): Boolean;
var
  First, AfterIsRB, OldKeepOneBlankLine: Boolean;
begin
  First := True;

  OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
  Scanner.KeepOneBlankLine := True;
  try
    while not (Scanner.Token in [tokKeywordEnd, tokKeywordCase, tokRB]) do
    begin
      while Scanner.Token in ClassVisibilityTokens do // 可能出现 private public 这种连续的
        FormatClassVisibility(BackTab(PreSpaceCount));

      // 可能先出现属性，不能错误地留到 FormatFieldDecl 里去处理
      if Scanner.Token = tokSLB then
      begin
        FormatSingleAttribute(PreSpaceCount);
        Writeln;
      end;

      if Scanner.Token = tokKeywordCase then // 如果出现 public case 的场合，要跳出处理 case
        Break;

      if Scanner.Token in [tokKeywordProcedure, tokKeywordFunction,
        tokKeywordConstructor, tokKeywordDestructor, tokKeywordClass] then
      begin
        FormatClassMethod(PreSpaceCount);
        Writeln;
        First := False;
      end
      else if Scanner.Token = tokKeywordProperty then
      begin
        FormatClassProperty(PreSpaceCount);
        Writeln;
        First := False;
      end
      else if Scanner.Token = tokKeywordType then
      begin
        FormatClassTypeSection(PreSpaceCount);
        Writeln;
        First := False;
      end
      else if Scanner.Token in [tokKeywordVar, tokKeywordThreadVar] then
      begin
        FormatVarSection(PreSpaceCount);
        Writeln;
        First := False;
      end
      else if Scanner.Token = tokKeywordConst then
      begin
        FormatClassConstSection(PreSpaceCount);
        Writeln;
        First := False;
      end
      else if Scanner.Token <> tokKeywordEnd then
      begin
        if First and IgnoreFirst then
          FormatFieldDecl
        else
          FormatFieldDecl(PreSpaceCount);
        First := False;

        if Scanner.Token = tokSemicolon then
        begin
          AfterIsRB := Scanner.ForwardToken in [tokRB];
          FTrimAfterSemicolon := AfterIsRB; // 后面没内容了，本分号后面不需要输出空格
          Match(Scanner.Token);
          FTrimAfterSemicolon := False;
          if not AfterIsRB then // 后面还有别的内容才写换行并准备再开一个 Field
            Writeln;
        end
        else if Scanner.Token = tokKeywordEnd then // 最后一项无分号时也可以
        begin
          Writeln;
          Break;
        end;
      end;
    end;

    if First and not (Scanner.Token = tokKeywordCase) then // 没有声明则先换行，case 除外
      Writeln;

    Result := False;
    if Scanner.Token = tokKeywordCase then
    begin
      FormatVariantSection(PreSpaceCount);
      Writeln;
      Result := True;
    end;

    if Scanner.Token = tokSemicolon then
      Match(Scanner.Token);
  finally
    Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
  end;
end;

{ FileType -> FILE [OF TypeId] }
procedure TCnBasePascalFormatter.FormatFileType(PreSpaceCount: Byte);
begin
  Match(tokKeywordFile);
  if Scanner.Token = tokKeywordOf then // 可以是单独的 file
  begin
    Match(tokKeywordOf);
    FormatTypeID;
  end;
end;

{ FormalParameters -> ['(' FormalParm/';'... ')'] }
procedure TCnBasePascalFormatter.FormatFormalParameters(PreSpaceCount: Byte);
begin
  Match(tokLB);

  SpecifyElementType(pfetFormalParameters);
  try
    if Scanner.Token <> tokRB then
      FormatFormalParm;

    while Scanner.Token = tokSemicolon do
    begin
      Match(Scanner.Token);
      FormatFormalParm;
    end;
  finally
    RestoreElementType;
  end;

  SpecifyElementType(pfetFormalParametersRightBracket);
  try
    Match(tokRB);
  finally
    RestoreElementType;
  end;
end;

{ FormalParm -> [Attribute] [VAR | CONST | OUT] [Attribute] Parameter }
procedure TCnBasePascalFormatter.FormatFormalParm(PreSpaceCount: Byte);
begin
  if Scanner.Token = tokSLB then
    FormatSingleAttribute(0, 1);

  if (Scanner.Token in [tokKeywordVar, tokKeywordConst, tokKeywordOut]) and
     not (Scanner.ForwardToken in [tokColon, tokComma])
  then
  begin
    Match(Scanner.Token);

    if Scanner.Token = tokSLB then
      FormatSingleAttribute(1, 1);
  end;

  FormatParameter;
end;

{ TypeId -> [UnitId '.'] <type-identifier>
procedure TCnTypeSectionFormater.FormatTypeID(PreSpaceCount: Byte);
begin
  Match(tokSymbol);

  if Scaner.Token = tokDot then
  begin
    Match(Scaner.Token);
    Match(tokSymbol);
  end;
end;
}

{ FunctionHeading -> FUNCTION Ident [FormalParameters] ':' (SimpleType | STRING) }
{ FunctionHeading -> OPERATOR Ident [FormalParameters] [':' (SimpleType | STRING)] }
procedure TCnBasePascalFormatter.FormatFunctionHeading(PreSpaceCount: Byte;
  AllowEqual: Boolean);
var
  IsOperator, IsClass: Boolean;
begin
  IsClass := Scanner.Token = tokKeywordClass;
  if IsClass then
    Match(tokKeywordClass, PreSpaceCount); // class 后无需再手工加空格

  IsOperator := Scanner.Token = tokKeywordOperator;
  if Scanner.Token in [tokKeywordFunction, tokKeywordOperator] then
  begin
    if IsClass then
      Match(Scanner.Token)
    else
      Match(Scanner.Token, PreSpaceCount); // 没有 class，这个要缩进
  end;

  FormatPossibleAmpersand(CnPascalCodeForRule.SpaceBeforeOperator);

  {!! Fixed. e.g. "const proc: procedure = nil;" }
  if Scanner.Token in [tokSymbol, tokAmpersand] + ComplexTokens + DirectiveTokens
    + KeywordTokens then // 函数名允许出现关键字
  begin
    // 处理 of，虽然无 function of object 的语法
    if (Scanner.Token <> tokKeywordOf) or (Scanner.ForwardToken = tokLB) then
      FormatMethodName;
  end;

  if Scanner.Token = tokSemicolon then // 处理 Forward 的函数的真正声明可省略参数的情形
    Exit;

  if AllowEqual and (Scanner.Token = tokEQUAL) then  // procedure Intf.Ident = Ident
  begin
    Match(tokEQUAL, 1, 1);
    FormatIdent;
    Exit;
  end;

  if Scanner.Token = tokLB then
    FormatFormalParameters;

  if IsOperator then // Operator 未必有返回值
  begin
    if Scanner.Token = tokColon then // 有冒号时才处理返回值
    begin
      Match(tokColon);

      if Scanner.Token = tokKeywordString then
        Match(Scanner.Token)
      else
        FormatSimpleType;
    end;
  end
  else
  begin
    Match(tokColon);

    if Scanner.Token = tokKeywordString then
      Match(Scanner.Token)
    else
      FormatSimpleType;
  end;
end;

{ InterfaceHeritage -> '(' IdentList ')' }
procedure TCnBasePascalFormatter.FormatInterfaceHeritage(PreSpaceCount: Byte);
begin
  Match(tokLB);
  FormatTypeParamIdentList(); // 加入泛型的支持
  Match(tokRB);
end;

{ // Change to below:
  InterfaceType -> INTERFACE [InterfaceHeritage] | DISPINTERFACE
                   [GUID]
                   [InterfaceMemberList]
                   END

  InterfaceMemberList -> ([InterfaceMember ';']) ...
  InterfaceMember -> InterfaceMethod | InterfaceProperty

  然后 InterfaceMethod 和 InterfaceProperty 沿用了 ClassMethod 和 ClassProperty
}
procedure TCnBasePascalFormatter.FormatInterfaceType(PreSpaceCount: Byte);
begin
  if Scanner.Token = tokKeywordInterface then
  begin
    Match(tokKeywordInterface);

    if Scanner.Token = tokSemicolon then // 有 ITest = interface; 的情况
      Exit;

    if Scanner.Token = tokLB then
      FormatInterfaceHeritage;
  end
  else if Scanner.Token = tokKeywordDispinterface then // 处理 dispinterface 的情况
  begin
    Match(tokKeywordDispinterface);
    if Scanner.Token = tokSemicolon then // 有 ITest = dispinterface; 的情况
      Exit;
  end;

  if Scanner.Token = tokSLB then // 有 GUID
     FormatGuid(PreSpaceCount);

  if Scanner.Token in ClassVisibilityTokens then
    FormatClassVisibility;
  // 放宽规则，允许出现 public 等内容

  // 循环放内部，因此内部需要 Writeln，这点和 Class 的 Property 处理不一样
  while Scanner.Token in [tokKeywordProperty] + ClassMethodTokens + [tokSLB] do
  begin
    if Scanner.Token = tokSLB then // interface 声明支持属性
    begin
      Writeln;
      FormatSingleAttribute(Tab(PreSpaceCount));
    end
    else if Scanner.Token = tokKeywordProperty then
    begin
      Writeln;
      FormatClassPropertyList(PreSpaceCount + CnPascalCodeForRule.TabSpaceCount);
    end
    else
    begin
      Writeln;
      FormatMethodList(PreSpaceCount + CnPascalCodeForRule.TabSpaceCount);
    end;
  end;
  
  Writeln;
  Match(tokKeywordEnd, PreSpaceCount);
end;

procedure TCnBasePascalFormatter.FormatGuid(PreSpaceCount: Byte = 0);
begin
  Writeln;
  Match(tokSLB, PreSpaceCount + CnPascalCodeForRule.TabSpaceCount);
  FormatConstExpr;
  Match(tokSRB);
end;

{
  MethodHeading -> ProcedureHeading
                -> FunctionHeading
                -> ConstructorHeading
                -> DestructorHeading
                -> PROCEDURE | FUNCTION InterfaceId.Ident '=' Ident

                class var / class property also processed here
}
procedure TCnBasePascalFormatter.FormatMethodHeading(PreSpaceCount: Byte;
  HasClassPrefixForVar: Boolean);
begin
  case Scanner.Token of
    tokKeywordProcedure: FormatProcedureHeading(PreSpaceCount);
    tokKeywordFunction, tokKeywordOperator: FormatFunctionHeading(PreSpaceCount); // class operator
    tokKeywordConstructor: FormatConstructorHeading(PreSpaceCount);
    tokKeywordDestructor: FormatDestructorHeading(PreSpaceCount);
    tokKeywordProperty: FormatClassProperty(PreSpaceCount); // class property

    tokKeywordVar, tokKeywordThreadVar: FormatVarDeclHeading(Tab(PreSpaceCount), HasClassPrefixForVar);  // class var/threadvar
  else
    Error(CN_ERRCODE_PASCAL_NO_METHODHEADING);
  end;
end;

{ MethodList -> (MethodHeading [';' VIRTUAL])/';'... }
procedure TCnBasePascalFormatter.FormatMethodList(PreSpaceCount: Byte);
var
  IsFirst: Boolean;
begin
  // Writeln;

  // Class Method List maybe hava Class Visibility Token
  FormatClassVisibility(PreSpaceCount);
  FormatMethodHeading(PreSpaceCount);
  Match(tokSemicolon);

  IsFirst := True;
  while Scanner.Token in DirectiveTokens do
  begin
    FormatDirective(PreSpaceCount, IsFirst);
    IsFirst := False;
    if Scanner.Token = tokSemicolon then
     Match(tokSemicolon, 0, 0, True);
  end;

  while (Scanner.Token in ClassVisibilityTokens) or
        (Scanner.Token in ClassMethodTokens) do
  begin
    Writeln;

    if Scanner.Token in ClassVisibilityTokens then
      FormatClassVisibility(PreSpaceCount);

    FormatMethodHeading(PreSpaceCount);
    Match(tokSemicolon);

    IsFirst := True;
    while Scanner.Token in DirectiveTokens do
    begin
      FormatDirective(PreSpaceCount, IsFirst);
      IsFirst := False;
      if Scanner.Token = tokSemicolon then
        Match(tokSemicolon, 0, 0, True);
    end;
  end;
end;

{ ObjectType -> OBJECT [ObjHeritage] [ObjFieldList] [MethodList] END }
procedure TCnBasePascalFormatter.FormatObjectType(PreSpaceCount: Byte);
begin
  Match(tokKeywordObject);
  if Scanner.Token = tokSemicolon then
    Exit;

  if Scanner.Token = tokLB then
  begin
    FormatObjHeritage // ObjHeritage -> '(' QualId ')'
  end;

  Writeln;

  // 用 class 的处理方式应该兼容，无须限制 object 里的声明不能出现
  // published 以及 constructor 或 destructor
  while Scanner.Token in ClassVisibilityTokens + ClassMemberSymbolTokens do
  begin
    if Scanner.Token in ClassVisibilityTokens then
      FormatClassVisibility(PreSpaceCount);

    if Scanner.Token in ClassMemberSymbolTokens then
      FormatClassMember(Tab(PreSpaceCount));
  end;

  Match(tokKeywordEnd, PreSpaceCount);
end;

{ ObjFieldList -> (IdentList ':' Type)/';'... }
procedure TCnBasePascalFormatter.FormatObjFieldList(PreSpaceCount: Byte);
begin
  FormatIdentList(PreSpaceCount);
  Match(tokColon);
  FormatType(PreSpaceCount);

  while Scanner.Token = tokSemicolon do
  begin
    Match(Scanner.Token);

    if Scanner.Token <> tokSymbol then Exit;

    Writeln;

    FormatIdentList(PreSpaceCount);
    Match(tokColon);
    FormatType(PreSpaceCount);
  end;
end;

{ ObjHeritage -> '(' QualId ')' }
procedure TCnBasePascalFormatter.FormatObjHeritage(PreSpaceCount: Byte);
begin
  Match(tokLB);
  FormatQualID;
  Match(tokRB);
end;

{ OrdinalType -> (SubrangeType | EnumeratedType | OrdIdent) }
procedure TCnBasePascalFormatter.FormatOrdinalType(PreSpaceCount: Byte;
  FromSetOf: Boolean);
var
  Bookmark: TScannerBookmark;

  procedure NextTokenWithDot;
  begin
    repeat
      Scanner.NextToken;
    until not (Scanner.Token in [tokSymbol, tokDot, tokInteger,
      tokString, tokWString, tokMString, tokLB, tokRB,
      tokPlus, tokMinus, tokStar, tokDiv, tokKeywordDiv, tokKeywordMod]);
    // 包括 () 是因为可能有类似于 Low(Integer)..High(Integer) 的情况
    // 还得包括四则运算符与字符串等，以备有其他常量运算的情形
  end;

  procedure MatchTokenWithDot;
  begin
    while Scanner.Token in [tokSymbol, tokDot] do
      Match(Scanner.Token);
  end;

begin
  if Scanner.Token = tokLB then  // EnumeratedType
  begin
    if FromSetOf then // 如果前面是 set of 括号前需要空一格
      FormatEnumeratedType(1)
    else
      FormatEnumeratedType(PreSpaceCount);
  end
  else
  begin
    Scanner.SaveBookmark(Bookmark);
    CodeGen.LockOutput;

    if Scanner.Token = tokMinus then // 考虑到负号的情况
      Scanner.NextToken;

    NextTokenWithDot;
    
    if Scanner.Token = tokRange then
    begin
      Scanner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      // SubrangeType
      FormatSubrangeType(PreSpaceCount);
    end
    else
    begin
      Scanner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      // OrdIdent
      if Scanner.Token = tokMinus then
        Match(Scanner.Token);

      MatchTokenWithDot;
    end;
    {
    // OrdIdent
    if Scaner.TokenSymbolIs('SHORTINT') or
       Scaner.TokenSymbolIs('SMALLINT') or
       Scaner.TokenSymbolIs('INTEGER')  or
       Scaner.TokenSymbolIs('BYTE')     or
       Scaner.TokenSymbolIs('LONGINT')  or
       Scaner.TokenSymbolIs('INT64')    or
       Scaner.TokenSymbolIs('WORD')     or
       Scaner.TokenSymbolIs('BOOLEAN')  or
       Scaner.TokenSymbolIs('CHAR')     or
       Scaner.TokenSymbolIs('WIDECHAR') or
       Scaner.TokenSymbolIs('LONGWORD') or
       Scaner.TokenSymbolIs('PCHAR')
    then
      Match(Scaner.Token);
    }
  end;
end;

{
  Parameter -> [CONST] IdentList  [':' ([ARRAY OF] SimpleType | STRING | FILE)]
            -> [CONST] Ident  [':' ([ARRAY OF] SimpleType | STRING | FILE | CONST)] ['=' ConstExpr]]
            // -> Ident ':=' Expression

  note: [ARRAY OF] and ['=' ConstExpr] can not exists at same time
        old grammer is -> Ident ':' SimpleType ['=' ConstExpr]
        // Ident ':=' Expression 是为了支持 OLE 的格式的调用
}
procedure TCnBasePascalFormatter.FormatParameter(PreSpaceCount: Byte);
var
  OldStoreIdent, GreatEqual: Boolean;
begin
  if Scanner.Token = tokKeywordConst then
    Match(Scanner.Token);

  if Scanner.Token = tokAmpersand then
    Match(Scanner.Token);

  if Scanner.ForwardToken = tokComma then //IdentList
  begin
    OldStoreIdent := FStoreIdent;
    try
      FStoreIdent := True;
      FormatIdentList(PreSpaceCount);
    finally
      FStoreIdent := OldStoreIdent;
    end;

    if Scanner.Token = tokColon then
    begin
      Match(Scanner.Token);

      if Scanner.Token = tokKeywordArray then
      begin
        Match(Scanner.Token);
        Match(tokKeywordOf);
      end;

      if Scanner.Token in [tokKeywordString, tokKeywordFile] then
        Match(Scanner.Token)
      else
        FormatSimpleType;
    end;
  end
  else // Ident
  begin
    OldStoreIdent := FStoreIdent;
    try
      FStoreIdent := True;
      FormatIdent(PreSpaceCount);
    finally
      FStoreIdent := OldStoreIdent;
    end;

    if Scanner.Token = tokColon then
    begin
      Match(tokColon);

      if Scanner.Token = tokKeywordArray then
      begin
        //CanHaveDefaultValue := False;
        Match(Scanner.Token);
        Match(tokKeywordOf);
      end;

      GreatEqual := False;
      if Scanner.Token in [tokKeywordString, tokKeywordFile, tokKeywordConst] then
        Match(Scanner.Token)
      else
        GreatEqual := FormatSimpleType;

      if Scanner.Token = tokEQUAL then
      begin
        //if not CanHaveDefaultValue then
        //  Error('Can not have default value');

        Match(tokEQUAL, 1, 1);
        FormatConstExpr;
      end
      else if GreatEqual then
      begin
        // 上面 GreatEqual := FormatSimpleType 这句已经处理好了泛型的 >= 拆成 > = 了
        FormatConstExpr;
      end;
    end
    else if Scanner.Token = tokAssign then // 匹配 OLE 调用的情形
    begin
      MatchOperator(tokAssign);
      FormatExpression(0, PreSpaceCount);
    end;
  end;

  {
  // IdentList
  if Scaner.Token = tokComma then
  begin
    Match(tokComma);
    FormatIdentList;
    if Scaner.Token = tokColon then
    begin
      Match(Scaner.Token);

      if Scaner.Token = tokKeywordArray then
      begin
        Match(Scaner.Token);
        Match(tokKeywordOf);
      end;

      if Scaner.Token in [tokKeywordString, tokKeywordFile] then
        Match(Scaner.Token)
      else
        FormatSimpleType;
    end;
  end else
  // Ident
  begin
    Match(tokColon);

    if Scaner.Token = tokKeywordString then
    begin
      Match(Scaner.Token);
    end else
      FormatSimpleType;

    if Scaner.Token = tokEQUAL then
    begin
      Match(tokEQUAL);
      FormatConstExpr;
    end;
  end;
}
end;

{ PointerType -> '^' TypeId }
procedure TCnBasePascalFormatter.FormatPointerType(PreSpaceCount: Byte);
begin
  if Scanner.Token = tokHat then  // ^T 这种会被认成 string、需要额外处理一下
  begin
    Match(tokHat);
    FormatTypeID;
  end
  else if (Scanner.Token = tokString) and (Length(Scanner.TokenString) = 2) and (Scanner.TokenString[1] = '^') then
    Match(Scanner.Token);
end;

{ ProcedureHeading -> [CLASS] PROCEDURE Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatProcedureHeading(PreSpaceCount: Byte;
  AllowEqual: Boolean);
begin
  if Scanner.Token = tokKeywordClass then
  begin
    Match(tokKeywordClass, PreSpaceCount); // class 后无需再手工加空格
    Match(Scanner.Token);
  end
  else
    Match(Scanner.Token, PreSpaceCount);

  FormatPossibleAmpersand;

  { !! Fixed. e.g. "const proc: procedure = nil;" }
  if Scanner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens
    + KeywordTokens - [tokKeywordBegin, tokKeywordVar, tokKeywordConst, tokKeywordType,
    tokKeywordProcedure, tokKeywordFunction] then
  begin // 函数名允许出现关键字，但匿名函数无参而碰见 begin/var/const/type 以及嵌套 function/procedure 等除外
    // 处理 of
    if (Scanner.Token <> tokKeywordOf) or (Scanner.ForwardToken = tokLB) then
      FormatMethodName;
  end;

  if Scanner.Token = tokLB then
    FormatFormalParameters;

  if AllowEqual and (Scanner.Token = tokEQUAL) then  // procedure Intf.Ident = Ident
  begin
    Match(tokEQUAL, 1, 1);
    FormatIdent;
  end;
end;

{ ProcedureType -> (ProcedureHeading | FunctionHeading) [OF OBJECT] [(DIRECTIVE [';'])...] }
procedure TCnBasePascalFormatter.FormatProcedureType(PreSpaceCount: Byte);
var
  IsSemicolon: Boolean;
begin
  case Scanner.Token of
    tokKeywordProcedure:
      begin
        FormatProcedureHeading(PreSpaceCount, False); // Proc 的 Type 允许出现等号
        if Scanner.Token = tokKeywordOf then
        begin
          Match(tokKeywordOf); // 如果是 procedure，前面没空格要插个空格
          Match(tokKeywordObject);
        end;
      end;
    tokKeywordFunction:
      begin
        FormatFunctionHeading(PreSpaceCount, False);
        if Scanner.Token = tokKeywordOf then
        begin
          Match(tokKeywordOf); // 如果是 function，前面已经有空格了就不用空格了
          Match(tokKeywordObject);
        end;
      end;
  end;

  // deal with the Directive after OF OBJECT
  // if Scaner.Token in DirectiveTokens then WriteOneSpace;

  IsSemicolon := False;
  if (Scanner.Token = tokSemicolon) and (Scanner.ForwardToken in DirectiveTokens) then
  begin
    Match(tokSemicolon);
    IsSemicolon := True;
  end;  // 处理 stdcall 之前的分号

  while Scanner.Token in DirectiveTokens do
  begin
    FormatDirective(0, IsSemicolon);

    if (Scanner.Token = tokSemicolon) and
      (Scanner.ForwardToken() in DirectiveTokens) then
    begin
      Match(tokSemicolon);
      IsSemicolon := True;
    end
    else
      IsSemicolon := False;

    // leave one semicolon for procedure type define at last.
  end;
end;

{ PropertyInterface -> [PropertyParameterList] ':' Ident }
procedure TCnBasePascalFormatter.FormatPropertyInterface(PreSpaceCount: Byte);
begin
  if Scanner.Token <> tokColon then
    FormatPropertyParameterList;

  Match(tokColon);

  FormatType(PreSpaceCount, True);
end;

{ PropertyList -> PROPERTY Ident [PropertyInterface]  PropertySpecifiers }
procedure TCnBasePascalFormatter.FormatPropertyList(PreSpaceCount: Byte);
begin
  Match(tokKeywordProperty, PreSpaceCount);
  FormatPossibleAmpersand;
  FormatIdent;

  if Scanner.Token in [tokSLB, tokColon] then
    FormatPropertyInterface;

  FormatPropertySpecifiers;

  if Scanner.Token = tokSemicolon then
    Match(tokSemicolon);
  
  if Scanner.TokenSymbolIs('DEFAULT') then
  begin
    Match(Scanner.Token);
    Match(tokSemicolon);
  end;
end;

{ PropertyParameterList -> '[' (IdentList ':' TypeId)/';'... ']' }
procedure TCnBasePascalFormatter.FormatPropertyParameterList(PreSpaceCount: Byte);
begin
  Match(tokSLB);

  if Scanner.Token in [tokKeywordVar, tokKeywordConst, tokKeywordOut] then
    Match(Scanner.Token);
  FormatIdentList;
  Match(tokColon);
  FormatTypeID;

  while Scanner.Token = tokSemicolon do
  begin
    Match(tokSemicolon);
    if Scanner.Token in [tokKeywordVar, tokKeywordConst, tokKeywordOut] then
      Match(Scanner.Token);
    FormatIdentList;
    Match(tokColon);
    FormatTypeID;
  end;

  Match(tokSRB);
end;

{
  PropertySpecifiers -> [INDEX ConstExpr]
                        [READ Ident]
                        [WRITE Ident]
                        [STORED (Ident | Constant)]
                        [(DEFAULT ConstExpr) | NODEFAULT]
                        [IMPLEMENTS TypeId]
}
{
  TODO: Here has something wrong. The keyword can be repeat.
}
procedure TCnBasePascalFormatter.FormatPropertySpecifiers(PreSpaceCount: Byte);

  procedure ProcessBlank;
  begin
    if Scanner.Token in [tokString, tokWString, tokMString, tokLB, tokPlus, tokMinus] then
      WriteOneSpace; // 后续表达式空格分隔
  end;

begin
  try
    SpecifyElementType(pfetPropertySpecifier);
    while Scanner.Token in PropertySpecifiersTokens do
    begin
      case Scanner.Token of
        tokComplexIndex:
        begin
          try
            SpecifyElementType(pfetPropertyIndex);
            Match(Scanner.Token);
          finally
            RestoreElementType;
          end;
          ProcessBlank;
          FormatConstExpr;
        end;

        tokComplexRead:
        begin
          Match(Scanner.Token);
          ProcessBlank;
          FormatDesignator(0);
          //FormatIdent(0, True);
        end;

        tokComplexWrite:
        begin
          Match(Scanner.Token);
          ProcessBlank;
          FormatDesignator(0);
          //FormatIdent(0, True);
        end;

        tokComplexStored:
        begin
          Match(Scanner.Token);
          ProcessBlank;
          FormatConstExpr; // Constrant is an Expression
        end;

        tokComplexImplements:
        begin
          Match(Scanner.Token);
          ProcessBlank;
          FormatTypeID;
        end;

        tokComplexDefault:
        begin
          Match(Scanner.Token);
          ProcessBlank;
          FormatConstExpr;
        end;

        tokDirectiveDispID:
        begin
          Match(Scanner.Token);
          ProcessBlank;
          FormatExpression;
        end;

        tokComplexNodefault, tokComplexReadonly, tokComplexWriteonly:
          Match(Scanner.Token);
      end;
    end;
  finally
    RestoreElementType;
  end;
end;

{ RecordConstant -> '(' RecordFieldConstant/';'... ')' }
procedure TCnBasePascalFormatter.FormatRecordConstant(PreSpaceCount: Byte);
begin
  Match(tokLB);

  // 保留换行时，右括号之前的上一行如果因为保留换行而多输出了空格缩进，此处要删除，以让下面的换行正确处理，避免多出来一行
  if CnPascalCodeForRule.KeepUserLineBreak then
    FCodeGen.TrimLastEmptyLine;
  CheckKeepLineBreakWriteln;

  FormatRecordFieldConstant(Tab(PreSpaceCount));
  if Scanner.Token = tokSemicolon then Match(Scanner.Token);

  while Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens) do // 标识符允许此等名字
  begin
    Writeln;
    if CnPascalCodeForRule.KeepUserLineBreak then // 保留换行时后续排版的缩进在同一行内得是 1
      FormatRecordFieldConstant()
    else
      FormatRecordFieldConstant(Tab(PreSpaceCount));
    if Scanner.Token = tokSemicolon then Match(Scanner.Token);
  end;

  // 保留换行时，右括号之前的上一行如果因为保留换行而多输出了空格缩进，此处要删除，以让下面的换行正确处理，避免多出来一行
  if CnPascalCodeForRule.KeepUserLineBreak then
  begin
    FCodeGen.TrimLastEmptyLine;

    // 右括号前源文件里如果有回车符，保留换行时会同样输出，此处不能用 Writeln 多换一行
    CheckKeepLineBreakWriteln;
  end
  else
    Writeln; // 不保留换行时，最后的右括号之前要换行

  Match(tokRB, PreSpaceCount);
end;

{ RecordFieldConstant -> Ident ':' TypedConstant }
procedure TCnBasePascalFormatter.FormatRecordFieldConstant(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);
  Match(tokColon);
  FormatTypedConstant;
end;

{ RecType -> RECORD [FieldList] END }
procedure TCnBasePascalFormatter.FormatRecType(PreSpaceCount: Byte);
begin
  Match(tokKeywordRecord);

  // record helper for Ident
  if (Scanner.Token = tokSymbol) and (Scanner.ForwardToken = tokKeywordFor)
    and (LowerCase(Scanner.TokenString) = 'helper') then
  begin
    Match(Scanner.Token);
    Match(tokKeywordFor);
    FormatIdent(0);
  end;
  Writeln;

  if Scanner.Token <> tokKeywordEnd then
    FormatFieldList(Tab(PreSpaceCount));

//  FormatClassMemberList(PreSpaceCount); Classmember do not know 'case'

  Match(tokKeywordEnd, PreSpaceCount);
  if Scanner.Token = tokKeywordAlign then  // 支持 record end align 16 这种新语法
  begin
    SpecifyElementType(pfetRecordEnd);
    try
      Match(tokKeywordAlign);
      FormatConstExpr;
    finally
      RestoreElementType;
    end;
  end;
end;

{ RecVariant -> ConstExpr/','...  ':' '(' [FieldList] ')' }
procedure TCnBasePascalFormatter.FormatRecVariant(PreSpaceCount: Byte;
  IgnoreFirst: Boolean);
var
  NestedCase: Boolean;
begin
  FormatConstExpr(PreSpaceCount);

  while Scanner.Token = tokComma do
  begin
    Match(Scanner.Token);
    FormatConstExpr;
  end;

  Match(tokColon); // case 后换行写分类标志，分类标志后换行缩进写()
  Writeln;
  Match(tokLB, Tab(PreSpaceCount));

  NestedCase := False;
  if Scanner.Token <> tokRB then
    NestedCase := FormatFieldList(Tab(PreSpaceCount), IgnoreFirst);

  // 如果嵌套了记录，此括号必须缩进。没好办法，姑且判断上一个是不是左括号或空白，
  // 或者 FormatFieldList 返回 True，表示遇到了 case
  SpecifyElementType(pfetRecVarFieldListRightBracket);
  try
    if (FLastToken in [tokLB, tokBlank]) or NestedCase then
      Match(tokRB, Tab(PreSpaceCount))
    else
      Match(tokRB);
  finally
    RestoreElementType;
  end;
end;

{ RequiresClause -> REQUIRES IdentList... ';' }
procedure TCnBasePascalFormatter.FormatRequiresClause(PreSpaceCount: Byte);
begin
  if Scanner.TokenSymbolIs('REQUIRES') then
  begin
    Match(Scanner.Token, 0, 1);
    FormatIdentList;
    Match(tokSemicolon);
  end;
end;

{
  RestrictedType -> ObjectType
                 -> ClassType
                 -> InterfaceType
}
procedure TCnBasePascalFormatter.FormatRestrictedType(PreSpaceCount: Byte);
begin
  case Scanner.Token of
    tokKeywordObject: FormatObjectType(PreSpaceCount);
    tokKeywordClass: FormatClassType(PreSpaceCount);
    tokKeywordInterface, tokKeywordDispinterface: FormatInterfaceType(PreSpaceCount);
  end;
end;

{ SetType -> SET OF OrdinalType }
procedure TCnBasePascalFormatter.FormatSetType(PreSpaceCount: Byte);
begin
  // Set 内部不换行因此无需使用 PreSpaceCount
  Match(tokKeywordSet);
  Match(tokKeywordOf);
  FormatOrdinalType(0, True);
end;

{ SimpleType -> (SubrangeType | EnumeratedType | OrdIdent | RealType) }
function TCnBasePascalFormatter.FormatSimpleType(PreSpaceCount: Byte): Boolean;
begin
  Result := False;
  if Scanner.Token = tokLB then
    FormatSubrangeType
  else
  begin
    FormatConstExprInType;
    if Scanner.Token = tokRange then
    begin
      Match(tokRange);
      FormatConstExprInType;
    end;
  end;

  // 加入对 <> 泛型的支持
  if Scanner.Token = tokLess then
    Result := FormatTypeParams(0, True);
end;

{
  StringType -> STRING
             -> ANSISTRING
             -> WIDESTRING
             -> STRING '[' ConstExpr ']'
}
procedure TCnBasePascalFormatter.FormatStringType(PreSpaceCount: Byte);
begin
  Match(Scanner.Token);
  if Scanner.Token = tokSLB then
  begin
    Match(Scanner.Token);
    FormatConstExpr;
    Match(tokSRB);
  end
  else if Scanner.Token = tokLB then   // 处理 _UTF8String = type AnsiString(65001); 这种
  begin
    Match(tokLB);
    FormatExpression;
    Match(tokRB);
  end;
end;

{ StrucType -> [PACKED] (ArrayType | SetType | FileType | RecType) }
procedure TCnBasePascalFormatter.FormatStructType(PreSpaceCount: Byte);
begin
  if Scanner.Token = tokkeywordPacked then
    Match(Scanner.Token);

  case Scanner.Token of
    tokKeywordArray: FormatArrayType(PreSpaceCount);
    tokKeywordSet: FormatSetType(PreSpaceCount);
    tokKeywordFile: FormatFileType(PreSpaceCount);
    tokKeywordRecord: FormatRecType(PreSpaceCount);
  else
    Error(CN_ERRCODE_PASCAL_NO_STRUCTTYPE);
  end;
end;

{ SubrangeType -> ConstExpr '..' ConstExpr }
procedure TCnBasePascalFormatter.FormatSubrangeType(PreSpaceCount: Byte);
begin
  FormatConstExpr(PreSpaceCount);
  Match(tokRange);
  FormatConstExpr(PreSpaceCount);
end;

{
  Type -> TypeId
       -> SimpleType
       -> StrucType
       -> PointerType
       -> StringType
       -> ProcedureType
       -> VariantType
       -> ClassRefType

       -> reference to ProcedureType
}
procedure TCnBasePascalFormatter.FormatType(PreSpaceCount: Byte;
  IgnoreDirective: Boolean);
var
  Bookmark: TScannerBookmark;
  AToken, OldLastToken: TPascalToken;
begin
  if (Scanner.Token = tokSymbol) and (Scanner.ForwardToken = tokKeywordTo) and
    (LowerCase(Scanner.TokenString) = 'reference') then
  begin
    // Anonymous Declaration
    Match(Scanner.Token);
    Match(tokKeywordTo);
  end;

  // 此三类无需换行，因此无需传入 PreSpaceCount
  if Scanner.Token in [tokKeywordProcedure, tokKeywordFunction] then
    FormatProcedureType
  else if Scanner.Token = tokKeywordClass then
    FormatClassRefType
  else if (Scanner.Token = tokHat) or  // ^T 这种会被认成 string、需要额外处理一下
   ( (Scanner.Token = tokString) and (Length(Scanner.TokenString) = 2) and (Scanner.TokenString[1] = '^')) then
    FormatPointerType
  else
  begin
    // StructType
    if Scanner.Token in StructTypeTokens then
    begin
      FormatStructType(PreSpaceCount);
    end
    else
    // StringType
    if (Scanner.Token = tokKeywordString) or
      Scanner.TokenSymbolIs('String')     or
      Scanner.TokenSymbolIs('AnsiString') or
      Scanner.TokenSymbolIs('WideString') or
      Scanner.TokenSymbolIs('UnicodeString') then
    begin
      FormatStringType; // 无需换行
    end
    else // EnumeratedType
    if Scanner.Token = tokLB then
    begin
      FCurrentTab := PreSpaceCount;
      FormatEnumeratedType; // 内部按保留用户换行的设置来按需换行，因而要提前记录 FCurrentTab
    end
    else
    begin
      // TypeID, SimpleType, VariantType
      { SubrangeType -> ConstExpr '..' ConstExpr }
      { TypeId -> [UnitId '.'] <type-identifier> }

      Scanner.SaveBookmark(Bookmark);
      OldLastToken := FLastToken;

      // 先测一下，跳过一个表达式，看看后面的是什么
      CodeGen.LockOutput;
      try
        FormatConstExprInType;
      finally
        CodeGen.UnLockOutput;
      end;

      // LoadBookmark 后，必须把当时的 FLastToken 也恢复过来，否则会影响空格的输出
      AToken := Scanner.Token;
      Scanner.LoadBookmark(Bookmark);
      FLastToken := OldLastToken;
      if FLastToken <> tokBlank then
        FLastNonBlankToken := FLastToken;

      { TypeId }
      if AToken = tokDot then
      begin
        FormatConstExpr;
        Match(Scanner.Token);
        Match(tokSymbol);
      end
      else if AToken = tokRange then { SubrangeType }
      begin
        FormatConstExpr;
        Match(tokRange);
        FormatConstExpr;
      end
      else if AToken = tokLess then // 加入对<>泛型的支持
      begin
        FormatIdent;
        FormatTypeParams;
        if Scanner.Token = tokDot then
        begin
          Match(tokDot);
          FormatIdent;
        end;
      end
      else
      begin
        FormatTypeID;
      end;
    end;
  end;

  // 加入对 <> 泛型的支持
  if Scanner.Token = tokLess then
  begin
    FormatTypeParams;
    if Scanner.Token = tokDot then
    begin
      Match(tokDot);
      FormatIdent;
    end;
  end;

  if not IgnoreDirective then
    while Scanner.Token in DirectiveTokens do
      FormatDirective;
end;

{ TypedConstant -> (ConstExpr | SetConstructor | ArrayConstant | RecordConstant) }
procedure TCnBasePascalFormatter.FormatTypedConstant(PreSpaceCount: Byte;
  IndentForAnonymous: Byte);
type
  TCnTypedConstantType = (tcConst, tcArray, tcRecord);
var
  TypedConstantType: TCnTypedConstantType;
  Bookmark: TScannerBookmark;
  OldLastToken: TPascalToken;
begin
  // DONE: 碰到括号就该判断一下，后面的大类是 symbol: 还是常量，
  // 然后分别调用 FormatArrayConstant 和 FormatRecordConstant
  TypedConstantType := tcConst;
  case Scanner.Token of
    // tokKeywordArray: FormatArrayConstant(PreSpaceCount); // 没这种语法
    tokSLB:
      begin
        FormatSetConstructor;
        while Scanner.Token in (AddOPTokens + MulOpTokens) do // Set 之间的运算
        begin
          MatchOperator(Scanner.Token);
          FormatSetConstructor;
        end;
      end;
    tokLB:
      begin // 是括号的，表示是组合的 Type
        if Scanner.ForwardToken = tokLB then // 如果后面还是括号，则说明本大类是常量或 array
        begin
          Scanner.SaveBookmark(Bookmark);
          OldLastToken := FLastToken;
          try
            try
              CodeGen.LockOutput;
              FormatConstExpr;

              if Scanner.Token = tokComma then // ((1, 1) 的情形
                TypedConstantType := tcArray
              else if Scanner.Token = tokSemicolon then // ((1) 的情形
                TypedConstantType := tcConst;
            except
              // 当做常量出错则是数组
              TypedConstantType := tcArray;
            end;
          finally
            CodeGen.UnLockOutput;
          end;

          Scanner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;
          if FLastToken <> tokBlank then
            FLastNonBlankToken := FLastToken;

          if TypedConstantType = tcArray then
          begin
            // 数组常量表达式允许保持内部换行
            FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
            FNeedKeepLineBreak := True;
            try
              FormatArrayConstant(PreSpaceCount);
            finally
              FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
            end;
          end
          else if Scanner.Token in ConstTokens
            + [tokAtSign, tokPlus, tokMinus, tokLB, tokRB] then // 有可能初始化的值以这些开头
            FormatConstExpr(PreSpaceCount)
        end
        else // 如果只是本括号，则拿后续的判断是否 a: 0 这样的形式来设置 TypedConstantType
        begin
          Scanner.SaveBookmark(Bookmark);
          OldLastToken := FLastToken;

          if (Scanner.ForwardToken in ([tokSymbol] + KeywordTokens + ComplexTokens))
            and (Scanner.ForwardToken(2) = tokColon) then
          begin
            // 括号后有常量后有冒号表示是 recordfield
            TypedConstantType := tcRecord;
          end
          else // 匹配一下 ( ConstExpr ) 然后看后续是否是;结束，来判断是否是数组
          begin
            try
              try
                CodeGen.LockOutput;
                Match(tokLB);
                FormatConstExpr;

                if Scanner.Token = tokComma then // (1, 1) 的情形
                  TypedConstantType := tcArray;
                if Scanner.Token = tokRB then
                  Match(tokRB);

                if Scanner.Token = tokSemicolon then // (1) 的情形
                  TypedConstantType := tcArray;
              except
                ;
              end;
            finally
              CodeGen.UnLockOutput;
            end;
          end;

          Scanner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;
          if FLastToken <> tokBlank then
            FLastNonBlankToken := FLastToken;

          if TypedConstantType = tcArray then
          begin
            // 数组常量表达式允许保持内部换行
            FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
            FNeedKeepLineBreak := True;
            try
              FormatArrayConstant(PreSpaceCount);
            finally
              FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
            end;
          end
          else if TypedConstantType = tcRecord then
          begin
            // 记录常量表达式允许保持内部换行
            FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
            FNeedKeepLineBreak := True;
            try
              FormatRecordConstant(Tab(PreSpaceCount));
            finally
              FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
            end;
          end
          else if Scanner.Token in ConstTokens
            + [tokAtSign, tokPlus, tokMinus, tokLB, tokRB] then // 有可能初始化的值以这些开头
            FormatConstExpr(PreSpaceCount)
        end;
      end;
  else // 不是括号开头，说明是简单的常量，直接处理
    if Scanner.Token in ConstTokens + [tokAtSign, tokPlus, tokMinus, tokHat] then // 有可能初始化的值以这些开头
      FormatConstExpr(PreSpaceCount, IndentForAnonymous)
    else if Scanner.Token <> tokRB then
      Error(CN_ERRCODE_PASCAL_NO_TYPEDCONSTANT);
  end;
end;

{
  TypeDecl -> Ident '=' Type
           -> Ident '=' RestrictedType
}
procedure TCnBasePascalFormatter.FormatTypeDecl(PreSpaceCount: Byte);
var
  Old, GreatEqual: Boolean;
  Pre: Byte;
begin
  while Scanner.Token = tokSLB do
  begin
    FormatSingleAttribute(PreSpaceCount);
    Writeln;
  end;

  Pre := PreSpaceCount;
  if FormatPossibleAmpersand(PreSpaceCount) then // 类型名可能是带 & 的关键字或标识符
    Pre := 0;

  Old := FIsTypeID;
  try
    FIsTypeID := True;
    FormatIdent(Pre);
  finally
    FIsTypeID := Old;
  end;

  // 加入对 <> 泛型的支持
  GreatEqual := False;
  if Scanner.Token = tokLess then
  begin
    GreatEqual := FormatTypeParams(0, True);
  end;

  if not GreatEqual then
    MatchOperator(tokEQUAL);

  if Scanner.Token = tokKeywordType then // 处理 TInt = type Integer; 的情形
    Match(tokKeywordType);

  if Scanner.Token in RestrictedTypeTokens then
    FormatRestrictedType(PreSpaceCount)
  else
    FormatType(PreSpaceCount);
end;

{ TypeSection -> TYPE (TypeDecl ';')... }
procedure TCnBasePascalFormatter.FormatTypeSection(PreSpaceCount: Byte);
const
  IsTypeStartTokens = [tokSymbol, tokSLB, tokAmpersand] + ComplexTokens + DirectiveTokens
    + KeywordTokens - NOTExpressionTokens;
var
  FirstType: Boolean;
begin
  Match(tokKeywordType, PreSpaceCount); // type 区不需要 Scaner.KeepOneBlankLine := True; 因为自己已经用空行隔开了
  Writeln;

  FirstType := True;
  while Scanner.Token in IsTypeStartTokens do // Attribute will use [
  begin
    // 如果是 [，就要越过其属性，找到 ] 后的第一个，确定它是否还是 type，如果不是，就跳出
    if (Scanner.Token = tokSLB) and not IsTokenAfterAttributesInSet(IsTypeStartTokens) then
      Exit;

    if not FirstType then
      WriteLine;

    FormatTypeDecl(Tab(PreSpaceCount));
    while Scanner.Token in DirectiveTokens do
      FormatDirective;
    Match(tokSemicolon);
    FirstType := False;
  end;
end;

{ VariantSection -> CASE [Ident ':'] TypeId OF RecVariant/';'... }
procedure TCnBasePascalFormatter.FormatVariantSection(PreSpaceCount: Byte);
begin
  Match(tokKeywordCase, PreSpaceCount);
  if Scanner.Token = tokAmpersand then // 可能有 &
    Match(Scanner.Token);
  if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens) then // case 后允许此等名字
    Match(Scanner.Token);

  // Ident
  if Scanner.Token = tokColon then
  begin
    Match(tokColon);
    FormatTypeID;
  end
  else
  // TypeID 中有 Dot，前面的为 UnitId，这个为 TypeId
  while Scanner.Token = tokDot do
  begin
    Match(tokDot);
    FormatTypeID;
  end;

  Match(tokKeywordOf);
  Writeln;
  FormatRecVariant(Tab(PreSpaceCount), True);

  while Scanner.Token = tokSemicolon do
  begin
    Match(Scanner.Token);
    if not (Scanner.Token in [tokKeywordEnd, tokRB]) then // end 或 ) 表示就要退出了
    begin
      Writeln;
      FormatRecVariant(Tab(PreSpaceCount), True);
    end;
  end;
end;

{ TCnProgramBlockFormater }

{
  Block -> [DeclSection]
           CompoundStmt
}
procedure TCnBasePascalFormatter.FormatBlock(PreSpaceCount: Byte;
  IsInternal: Boolean; MultiCompound: Boolean);
begin
  while Scanner.Token in DeclSectionTokens do
  begin
    FormatDeclSection(PreSpaceCount, True, IsInternal);
    Writeln;
  end;

  if MultiCompound and not (FGoalType in [gtProgram, gtLibrary]) then
  begin
    while Scanner.Token in BlockStmtTokens do
    begin
      FormatCompoundStmt(PreSpaceCount);
      if Scanner.Token = tokSemicolon then
      begin
        Match(Scanner.Token);
        if Scanner.Token in BlockStmtTokens then // 后面还有则换行
          Writeln;
      end;
    end;
  end
  else
  begin
    FormatCompoundStmt(PreSpaceCount);
  end;
end;

procedure TCnBasePascalFormatter.FormatProgramInnerBlock(PreSpaceCount: Byte;
  IsInternal: Boolean; IsLib: Boolean);
var
  HasDeclSection: Boolean;
begin
  HasDeclSection := False;
  while Scanner.Token in DeclSectionTokens do
  begin
    FormatDeclSection(PreSpaceCount, False, IsInternal);
    Writeln;
    HasDeclSection := True;
  end;

  if HasDeclSection then // 有声明才多换行，避免多出连续空行
    Writeln;

  if IsLib and (Scanner.Token = tokKeywordEnd) then // Library 允许直接 end
    Match(Scanner.Token)
  else
    FormatCompoundStmt(PreSpaceCount);
end;

{
  ConstantDecl -> Ident '=' ConstExpr [DIRECTIVE/..]

               -> Ident ':' TypeId '=' TypedConstant
  FIXED:       -> Ident ':' Type '=' TypedConstant [DIRECTIVE/..]
}
procedure TCnBasePascalFormatter.FormatConstantDecl(PreSpaceCount: Byte);
var
  OldKeepOneBlankLine: Boolean;
begin
  FormatIdent(PreSpaceCount);

  OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
  Scanner.KeepOneBlankLine := True;

  try
    case Scanner.Token of
      tokEQUAL:
        begin
          // 常量表达式从等号起就允许保持内部换行
          FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
          FNeedKeepLineBreak := True;
          try
            Match(Scanner.Token, 1); // 等号前空一格
            FCurrentTab := PreSpaceCount; // 记录当前缩进供常量表达式内部保留换行处理
            FormatConstExpr(1); // 等号后只空一格
          finally
            FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
          end;
        end;
      tokColon: // 无法直接区分 record/array/普通常量方式的初始化，需要内部解析
        begin
          Match(Scanner.Token);
          FormatType;

          // 类型表达式从冒号起就允许保持内部换行
          FLineBreakKeepStack.Push(Pointer(FNeedKeepLineBreak));
          FNeedKeepLineBreak := True;
          try
            FCurrentTab := PreSpaceCount;
            Match(tokEQUAL, 1, 1); // 等号前后空一格
            FormatTypedConstant; // 等号后空一格
          finally
            FNeedKeepLineBreak := Boolean(FLineBreakKeepStack.Pop);
          end;
        end;
    else
      Error(CN_ERRCODE_PASCAL_NO_EQUALCOLON);
    end;
  finally
    Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
  end;

  while Scanner.Token in DirectiveTokens do
    FormatDirective;
end;

{
  ConstSection -> CONST (ConstantDecl ';')...
                  RESOURCESTRING (ConstantDecl ';')...

  Note: resourcestring 只支持字符型常量，但格式化时可不考虑而当做普通常量对待
}
procedure TCnBasePascalFormatter.FormatConstSection(PreSpaceCount: Byte);
const
  IsConstStartTokens = [tokSymbol, tokSLB] + ComplexTokens + DirectiveTokens
    + KeywordTokens - NOTExpressionTokens;
var
  OldKeepOneBlankLine: Boolean;
begin
  if Scanner.Token in [tokKeywordConst, tokKeywordResourcestring] then
    Match(Scanner.Token, PreSpaceCount);

  while Scanner.Token in IsConstStartTokens do // 这些关键字不宜做变量名但也不好处理，只有先写上
  begin
    // 如果是 [，就要越过其属性，找到 ] 后的第一个，确定它是否还是 const，如果不是，就跳出
    if (Scanner.Token = tokSLB) and not IsTokenAfterAttributesInSet(IsConstStartTokens) then
      Exit;

    Writeln;
    OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
    Scanner.KeepOneBlankLine := True;
    try
      FormatConstantDecl(Tab(PreSpaceCount));
    finally
      Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
    end;
    Match(tokSemicolon);
  end;
end;

{
  DeclSection -> LabelDeclSection
              -> ConstSection
              -> TypeSection
              -> VarSection
              -> ProcedureDeclSection
              -> ExportsSelection
}
procedure TCnBasePascalFormatter.FormatDeclSection(PreSpaceCount: Byte;
  IndentProcs: Boolean; IsInternal: Boolean);
var
  MakeLine, LastIsInternalProc: Boolean;
begin
  MakeLine := False;
  LastIsInternalProc := False;

  while Scanner.Token in DeclSectionTokens do
  begin
    if MakeLine then // Attribute 后无须空行分隔所以 MakeLine 会被设为 False
    begin
      if IsInternal then  // 内部的定义只需要空一行
        EnsureOneEmptyLine
      else
        WriteLine;
    end;

    MakeLine := True;
    case Scanner.Token of
      tokKeywordLabel:
        begin
          FormatLabelDeclSection(PreSpaceCount);
          LastIsInternalProc := False;
        end;
      tokKeywordConst, tokKeywordResourcestring:
        begin
          FormatConstSection(PreSpaceCount);
          LastIsInternalProc := False;
        end;
      tokKeywordType:
        begin
          FormatTypeSection(PreSpaceCount);
          LastIsInternalProc := False;
        end;
      tokKeywordVar, tokKeywordThreadvar:
        begin
          FormatVarSection(PreSpaceCount, True);
          LastIsInternalProc := False;
        end;
      tokKeywordExports:
        begin
          FormatExportsSection(PreSpaceCount);
          LastIsInternalProc := False;
        end;
      tokKeywordClass, tokKeywordProcedure, tokKeywordFunction,
      tokKeywordConstructor, tokKeywordDestructor:
        begin
          if IndentProcs then
          begin
            if not LastIsInternalProc then // 上一个也是 proc，只空一行
              EnsureOneEmptyLine;
            FormatProcedureDeclSection(Tab(PreSpaceCount));
          end
          else
            FormatProcedureDeclSection(PreSpaceCount);
          if IsInternal then
            Writeln;
          LastIsInternalProc := True;
        end;
      tokSLB:
        begin
          // Attributes for procedure in implementation
          if IsInternal then
          begin
            EnsureOneEmptyLine; // 与上一个 local procedure 空一行
            FormatSingleAttribute(Tab(PreSpaceCount));
          end
          else
          begin
            FormatSingleAttribute(PreSpaceCount);
            Writeln;
          end;
          MakeLine := False;
        end;
    else
      Error(CN_ERRCODE_PASCAL_NO_DECLSECTION);
    end;
  end;
end;

{
 ExportsDecl -> Ident [FormalParameters] [':' (SimpleType | STRING)] [Directive]
}
procedure TCnBasePascalFormatter.FormatExportsDecl(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);

  if Scanner.Token = tokLB then
    FormatFormalParameters;

  if Scanner.Token = tokColon then
  begin
    Match(tokColon);

    if Scanner.Token = tokKeywordString then
      Match(Scanner.Token)
    else
      FormatSimpleType;
  end;

  while Scanner.Token in DirectiveTokens do  // 注意此处不用处理分号，免得吃掉尾部的分号
    FormatDirective;
end;

{ ExportsList -> ( ExportsDecl ',')... }
procedure TCnBasePascalFormatter.FormatExportsList(PreSpaceCount: Byte);
begin
  FormatExportsDecl(PreSpaceCount);
  while Scanner.Token = tokComma do
  begin
    Match(tokComma);
    Writeln;
    FormatExportsDecl(PreSpaceCount);
  end;
end;

{ ExportsSection -> EXPORTS ExportsList ';' }
procedure TCnBasePascalFormatter.FormatExportsSection(PreSpaceCount: Byte);
begin
  Match(tokKeywordExports);
  Writeln;
  FormatExportsList(Tab(PreSpaceCount));
  Match(tokSemicolon);
end;

{
  FunctionDecl -> FunctionHeading ';' [(DIRECTIVE ';')...]
                  Block ';'
}

procedure TCnBasePascalFormatter.FormatFunctionDecl(PreSpaceCount: Byte;
  IsAnonymous: Boolean);
var
  IsExternal: Boolean;
  IsForward: Boolean;
  OldIdentBackupListRef: TObjectList;
  IdentBackupList: TObjectList;
begin
  OldIdentBackupListRef := FIdentBackupListRef;
  IdentBackupList := TObjectList.Create(True);
  FIdentBackupListRef := IdentBackupList;

  try
    FormatFunctionHeading(PreSpaceCount);

    if Scanner.Token = tokSemicolon then // 可能有省略分号的情况
      Match(tokSemicolon, 0, 0, True); // 不让分号后写空格，免得影响 Directive 的空格

    IsExternal := False;
    IsForward := False;
    while Scanner.Token in DirectiveTokens + ComplexTokens do
    begin
      if Scanner.Token = tokDirectiveExternal then
        IsExternal := True;
      if Scanner.Token = tokDirectiveForward then
        IsForward := True;
      FormatDirective;
      {
       FIX A BUG: semicolon can missing after directive like this:

       procedure Foo; external 'foo.dll' name '__foo'
       procedure Bar; external 'bar.dll' name '__bar'
      }
      if Scanner.Token = tokSemicolon then
        Match(tokSemicolon, 0, 0, True);
    end;

    if (not IsExternal) and (not IsForward) then
    begin
      FNextBeginShouldIndent := True; // 过程声明后 begin 必须换行
      Writeln;
    end;

    if ((not IsExternal)  and (not IsForward)) and
       (Scanner.Token in BlockStmtTokens + DeclSectionTokens) then
    begin
      FormatBlock(PreSpaceCount, True);
      if not IsAnonymous and (Scanner.Token = tokSemicolon) then // 匿名函数不包括 end 后的分号
        Match(tokSemicolon);
    end;
  finally
    // Remove IdentBackupList from NamesMap
    RestoreIdentBackup(IdentBackupList);
    IdentBackupList.Free;
    FIdentBackupListRef := OldIdentBackupListRef;
  end;
end;

{ LabelDeclSection -> LABEL LabelId/ ',' .. ';'}
procedure TCnBasePascalFormatter.FormatLabelDeclSection(
  PreSpaceCount: Byte);
begin
  Match(tokKeywordLabel, PreSpaceCount);
  Writeln;
  FormatLabelID(Tab(PreSpaceCount));

  while Scanner.Token = tokComma do
  begin
    Match(Scanner.Token);
    FormatLabelID;
  end;

  Match(tokSemicolon);
end;

{ LabelID can be symbol or number }
procedure TCnBasePascalFormatter.FormatLabelID(PreSpaceCount: Byte);
begin
  Match(Scanner.Token, PreSpaceCount);
end;

{
  ProcedureDecl -> ProcedureHeading ';' [(DIRECTIVE ';')...]
                   Block ';'
}
procedure TCnBasePascalFormatter.FormatProcedureDecl(PreSpaceCount: Byte;
  IsAnonymous: Boolean);
var
  IsExternal: Boolean;
  IsForward: Boolean;
  OldIdentBackupListRef: TObjectList;
  IdentBackupList: TObjectList;
begin
  OldIdentBackupListRef := FIdentBackupListRef;
  IdentBackupList := TObjectList.Create(True);
  FIdentBackupListRef := IdentBackupList;

  try
    FormatProcedureHeading(PreSpaceCount);

    if Scanner.Token = tokSemicolon then // 可能有省略分号的情况
      Match(tokSemicolon, 0, 0, True); // 不让分号后写空格，免得影响 Directive 的空格

    IsExternal := False;
    IsForward := False;
    while Scanner.Token in DirectiveTokens + ComplexTokens do  // Use ComplexTokens for "local;"
    begin
      if Scanner.Token = tokDirectiveExternal then
        IsExternal := True;
      if Scanner.Token = tokDirectiveForward then
        IsForward := True;

      FormatDirective;
      {
        FIX A BUG: semicolon can missing after directive like this:

         procedure Foo; external 'foo.dll' name '__foo'
         procedure Bar; external 'bar.dll' name '__bar'
      }
      if Scanner.Token = tokSemicolon then
        Match(tokSemicolon, 0, 0, True);
    end;

    if (not IsExternal) and (not IsForward) then
    begin
      FNextBeginShouldIndent := True; // 函数声明后 begin 必须换行
      Writeln;
    end;

    if ((not IsExternal) and (not IsForward)) and
      (Scanner.Token in BlockStmtTokens + DeclSectionTokens) then // Local procedure also supports Attribute
    begin
      FormatBlock(PreSpaceCount, True);
      if not IsAnonymous and (Scanner.Token = tokSemicolon) then // 匿名函数不包括 end 后的分号
        Match(tokSemicolon);
    end;
  finally
    // Remove IdentBackupList from NamesMap
    RestoreIdentBackup(IdentBackupList);
    IdentBackupList.Free;
    FIdentBackupListRef := OldIdentBackupListRef;
  end;
end;

{
  ProcedureDeclSection -> ProcedureDecl
                       -> FunctionDecl
}
procedure TCnBasePascalFormatter.FormatProcedureDeclSection(
  PreSpaceCount: Byte);
var
  Bookmark: TScannerBookmark;
begin
  Scanner.SaveBookmark(Bookmark);
  CodeGen.LockOutput;

  if Scanner.Token = tokKeywordClass then
  begin
    Scanner.NextToken;
  end;

  case Scanner.Token of
    tokKeywordProcedure, tokKeywordConstructor, tokKeywordDestructor:
    begin
      Scanner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      FormatProcedureDecl(PreSpaceCount);
    end;

    tokKeywordFunction, tokKeywordOperator:
    begin
      Scanner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      FormatFunctionDecl(PreSpaceCount);
    end;
  else
    Error(CN_ERRCODE_PASCAL_NO_PROCFUNC);
  end;
end;

{
  ProgramBlock -> [UsesClause]
                  Block
}
procedure TCnProgramBlockFormatter.FormatProgramBlock(PreSpaceCount: Byte; IsLib: Boolean);
begin
  if Scanner.Token = tokKeywordUses then
  begin
    FormatUsesClause(PreSpaceCount, True); // 带 IN 的，需要分行
    WriteLine;
  end;
  FormatProgramInnerBlock(PreSpaceCount, False, IsLib);
end;

procedure TCnProgramBlockFormatter.FormatPackageBlock(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetPackageBlock);
  try
    if Scanner.Token = tokKeywordRequires then
    begin
      FormatUsesClause(PreSpaceCount, True); // 不带 IN 的 requires，需要分行
      WriteLine;
    end;

    if Scanner.Token = tokKeywordContains then
    begin
      FormatUsesClause(PreSpaceCount, True); // 带 IN 的，需要分行
      WriteLine;
    end;
  finally
    RestoreElementType;
  end;
end;

{ UsesClause -> USES UsesList ';' }
procedure TCnProgramBlockFormatter.FormatUsesClause(PreSpaceCount: Byte;
  const NeedCRLF: Boolean);
begin
  if Scanner.Token in [tokKeywordUses, tokKeywordRequires, tokKeywordContains] then
    Match(Scanner.Token);

  Writeln;
  SpecifyElementType(pfetUsesList);
  Scanner.IdentContainsDot := True;
  try
    FormatUsesList(Tab(PreSpaceCount), True, NeedCRLF);
  finally
    RestoreElementType;
    Scanner.IdentContainsDot := False;
  end;

  Match(tokSemicolon);
end;

{ UsesList -> (UsesDecl ',') ... }
procedure TCnProgramBlockFormatter.FormatUsesList(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean; const NeedCRLF: Boolean);
var
  OldWrapMode: TCnCodeWrapMode;
  OldAuto: Boolean;
begin
  FormatUsesDecl(PreSpaceCount, CanHaveUnitQual);

  while Scanner.Token = tokComma do
  begin
    Match(tokComma);
    if NeedCRLF then
    begin
      Writeln;
      FormatUsesDecl(PreSpaceCount, CanHaveUnitQual);
    end
    else // 无需手工换行时也无需缩进
    begin
      OldWrapMode := CodeGen.CodeWrapMode;
      OldAuto := CodeGen.AutoWrapButNoIndent;
      try
        CodeGen.CodeWrapMode := cwmSimple; // uses 要求简单换行
        CodeGen.AutoWrapButNoIndent := True; // uses 单元换行后无需缩进
        FormatUsesDecl(0, CanHaveUnitQual);
      finally
        CodeGen.CodeWrapMode := OldWrapMode;
        CodeGen.AutoWrapButNoIndent := OldAuto;
      end;
    end;
  end;
end;

{ UseDecl -> Ident [IN String]}
procedure TCnProgramBlockFormatter.FormatUsesDecl(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
var
  Pre: Byte;
begin
  Pre := PreSpaceCount;
  if FormatPossibleAmpersand(PreSpaceCount) then // 单元名可能是带 & 的关键字或标识符
    Pre := 0;

  if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
    Match(Scanner.Token, Pre); // 标识符中允许使用部分关键字

  while CanHaveUnitQual and (Scanner.Token = tokDot) do
  begin
    Match(tokDot);
    if Scanner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scanner.Token);
  end;

  if Scanner.Token = tokKeywordIn then // 处理 in
  begin
    Match(tokKeywordIn, 1, 1);
    if Scanner.Token in [tokString, tokWString] then // uses 的单元路径照理不应该允许仨单引号
      Match(Scanner.Token)
    else
      ErrorToken(tokString);
  end;
end;

{ VarDecl -> IdentList ':' Type [(ABSOLUTE (Ident | ConstExpr)) | '=' TypedConstant] }
procedure TCnBasePascalFormatter.FormatVarDecl(PreSpaceCount: Byte);
var
  OldStoreIdent: Boolean;
  OldKeepOneBlankLine: Boolean;
begin
  OldStoreIdent := FStoreIdent;
  try
    // 把 var 区的内容存入标识符 Map 用来纠正大小写
    FStoreIdent := True;
    FormatIdentList(PreSpaceCount);
  finally
    FStoreIdent := OldStoreIdent;
  end;

  if Scanner.Token = tokColon then // 放宽语法限制
  begin
    Match(tokColon);
    FormatType(PreSpaceCount); // 长 Type 可能换行，必须传入
  end;

  if Scanner.Token = tokEQUAL then
  begin
    FCurrentTab := PreSpaceCount;
    OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
    Scanner.KeepOneBlankLine := True;  // var 的赋值语句也要求保持换行
    try
      Match(Scanner.Token, 1, 1);
      FormatTypedConstant;
    finally
      Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
    end;
  end
  else if Scanner.TokenSymbolIs('ABSOLUTE') then
  begin
    Match(Scanner.Token);
    FormatConstExpr; // include indent
  end;

  while Scanner.Token in DirectiveTokens do
    FormatDirective;
end;

{ InlineVarDecl -> IdentList ':' Type [(ABSOLUTE (Ident | ConstExpr)) | ':=' TypedConstant] }
procedure TCnBasePascalFormatter.FormatInlineVarDecl(PreSpaceCount, IndentForAnonymous: Byte);
var
  OldStoreIdent: Boolean;
begin
  SpecifyElementType(pfetInlineVar);

  try
    OldStoreIdent := FStoreIdent;
    try
      // 把 var 区的内容存入标识符 Map 用来纠正大小写
      FStoreIdent := True;
      FormatIdentList(PreSpaceCount);
    finally
      FStoreIdent := OldStoreIdent;
    end;

    if Scanner.Token = tokColon then // 放宽语法限制
    begin
      Match(tokColon);
      FormatType(PreSpaceCount); // 长 Type 可能换行，必须传入
    end;

    if Scanner.Token = tokAssign then  // 注意 InlineVar 此处与 var 不同
    begin
      Match(Scanner.Token, 1, 1);
      // var F := not A 这种，走不了 TypedConstant，得走 ConstExpr
      if Scanner.Token in ConstTokens + [tokAtSign, tokPlus, tokMinus, tokHat, tokSLB, tokLB] then
        FormatTypedConstant(0, IndentForAnonymous)
      else
        FormatConstExpr(0, IndentForAnonymous);
    end
    else if Scanner.TokenSymbolIs('ABSOLUTE') then
    begin
      Match(Scanner.Token);
      FormatConstExpr; // include indent
    end;

    while Scanner.Token in DirectiveTokens do
      FormatDirective;

  finally
    RestoreElementType;
  end;
end;

{ VarSection -> VAR | THREADVAR (VarDecl ';')... }
procedure TCnBasePascalFormatter.FormatVarSection(PreSpaceCount: Byte; IsGlobal: Boolean);
const
  IsVarStartTokens = [tokSymbol, tokSLB, tokAmpersand] + ComplexTokens + DirectiveTokens
    + KeywordTokens - NOTExpressionTokens;
var
  OldKeepOneBlankLine: Boolean;
begin
  if Scanner.Token in [tokKeywordVar, tokKeywordThreadvar] then
    Match(Scanner.Token, PreSpaceCount);

  while Scanner.Token in IsVarStartTokens do // 这些关键字不宜做变量名但也不好处理，只有先写上
  begin
    // 如果是[，就要越过其属性，找到 ] 后的第一个，确定它是否还是 var，如果不是，就跳出
    if (Scanner.Token = tokSLB) and not IsTokenAfterAttributesInSet(IsVarStartTokens) then
      Exit;

    Writeln;
    OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
    Scanner.KeepOneBlankLine := True;
    try
      FormatVarDecl(Tab(PreSpaceCount));
    finally
      Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
    end;
    Match(tokSemicolon); // 分号放在 KeepOneBlankLine 设为 True 之外，避免分号后的空一行导致输出空两行
  end;
end;

procedure TCnBasePascalFormatter.FormatTypeID(PreSpaceCount: Byte);
var
  Old: Boolean;
begin
  if Scanner.Token in BuiltInTypeTokens then
    Match(Scanner.Token)
  else if Scanner.Token = tokKeywordFile then
    Match(tokKeywordFile)
  else
  begin
    // 处理类型名等的大小写问题
    Old := FIsTypeID;
    try
      FIsTypeID := True;
      FormatIdent(0, True);
    finally
      FIsTypeID := Old;
    end;
    
    // 处理 _UTF8String = type _AnsiString(65001); 这种
    if Scanner.Token = tokLB then
    begin
      Match(tokLB);
      FormatExpression;
      Match(tokRB);
    end;
  end;
end;

{ TCnGoalCodeFormater }

procedure TCnGoalCodeFormatter.FormatCode(PreSpaceCount: Byte);
begin
  ResetElementType;
  FPrefixSpaces := 0;
  CheckHeadComments;
  FormatGoal(PreSpaceCount);
end;

{
  ExportedHeading -> ProcedureHeading ';' [(DIRECTIVE ';')...]
                  -> FunctionHeading ';' [(DIRECTIVE ';')...]
}
procedure TCnGoalCodeFormatter.FormatExportedHeading(PreSpaceCount: Byte);
begin
  case Scanner.Token of
    tokKeywordProcedure: FormatProcedureHeading(PreSpaceCount);
    tokKeywordFunction: FormatFunctionHeading(PreSpaceCount);
  else
    Error(CN_ERRCODE_PASCAL_NO_PROCFUNC);
  end;

  if Scanner.Token = tokSemicolon then
    Match(tokSemicolon, 0, 0, True); // 不让分号后写空格，免得影响 Directive 的空格

  while Scanner.Token in DirectiveTokens do
  begin
    FormatDirective;
    {
     FIX A BUG: semicolon can missing after directive like this:

     procedure Foo; external 'foo.dll' name '__foo'
     procedure Bar; external 'bar.dll' name '__bar'
    }
    if Scanner.Token = tokSemicolon then
      Match(tokSemicolon, 0, 0, True);
  end;
end;

{ Goal -> (Program | Package  | Library  | Unit) }
procedure TCnGoalCodeFormatter.FormatGoal(PreSpaceCount: Byte);
begin
  case Scanner.Token of
    tokKeywordProgram:
      begin
        FGoalType := gtProgram;
        FormatProgram(PreSpaceCount);
      end;
    tokKeywordLibrary:
      begin
        FGoalType := gtLibrary;
        FormatLibrary(PreSpaceCount);
      end;
    tokKeywordUnit:
      begin
        FGoalType := gtUnit;
        FormatUnit(PreSpaceCount);
      end;
    tokKeywordPackage:
      begin
        FGoalType := gtPackage;
        FormatPackage(PreSpaceCount);
      end;
  else
    FGoalType := gtUnknown;
    Error(CN_ERRCODE_PASCAL_UNKNOWN_GOAL);
  end;
end;

{
  ImplementationSection -> IMPLEMENTATION
                           [UsesClause]
                           [DeclSection]...
}
procedure TCnGoalCodeFormatter.FormatImplementationSection(
  PreSpaceCount: Byte);
begin
  Match(tokKeywordImplementation);

  while Scanner.Token = tokKeywordUses do
  begin
    WriteLine;
    FormatUsesClause(PreSpaceCount, CnPascalCodeForRule.UsesUnitSingleLine);
  end;

  if Scanner.Token in DeclSectionTokens then
  begin
    WriteLine;
    FormatDeclSection(PreSpaceCount, False);
  end;
end;

{
  InitSection -> INITIALIZATION StmtList [FINALIZATION StmtList]
              -> BEGIN StmtList END
}
procedure TCnGoalCodeFormatter.FormatInitSection(PreSpaceCount: Byte);
begin
  if Scanner.Token = tokKeywordInitialization then
    Match(tokKeywordInitialization)
  else if Scanner.Token = tokKeywordBegin then
    Match(tokKeywordBegin);

  Writeln;
  if Scanner.Token = tokKeywordFinalization then // Empty initialization
  begin
    Writeln;
    Match(Scanner.Token);

    if Scanner.Token <> tokKeywordEnd then // Do not New a Line when Empty finalization
      Writeln;
    FormatStmtList(Tab);
    Exit;
  end
  else
  begin
    FormatStmtList(Tab);
  end;

  if Scanner.Token = tokKeywordFinalization then
  begin
    // 语句结尾可能没有分号，保留换行时会多写行尾回车，因此这里要保证不多写回车
    CheckKeepLineBreakWriteln;
    Writeln;

    Match(Scanner.Token);

    if Scanner.Token <> tokKeywordEnd then // Do not New a Line when Empty finalization
      Writeln;
    FormatStmtList(Tab);
  end;
end;

{
  InterfaceDecl -> ConstSection
                -> TypeSection
                -> VarSection
                -> ExportedHeading
                -> ExportsSection
}
procedure TCnGoalCodeFormatter.FormatInterfaceDecl(PreSpaceCount: Byte);
var
  MakeLine: Boolean;
begin
  MakeLine := False;
  
  while Scanner.Token in InterfaceDeclTokens do
  begin
    if MakeLine then WriteLine;

    case Scanner.Token of
      tokKeywordUses: FormatUsesClause(PreSpaceCount, CnPascalCodeForRule.UsesUnitSingleLine); // 加入 uses 的处理以提高容错性
      tokKeywordConst, tokKeywordResourcestring: FormatConstSection(PreSpaceCount);
      tokKeywordType: FormatTypeSection(PreSpaceCount);
      tokKeywordVar, tokKeywordThreadvar: FormatVarSection(PreSpaceCount, True);
      tokKeywordProcedure, tokKeywordFunction: FormatExportedHeading(PreSpaceCount);
      tokKeywordExports: FormatExportsSection(PreSpaceCount);
      tokSLB: FormatSingleAttribute(PreSpaceCount);
    else
      if not CnPascalCodeForRule.ContinueAfterError then
        Error(CN_ERRCODE_PASCAL_ERROR_INTERFACE)
      else
      begin
        Match(Scanner.Token);
        Continue;
      end;
    end;

    MakeLine := True;
  end;
end;

{
  InterfaceSection -> INTERFACE
                      [UsesClause]
                      [InterfaceDecl]...
}
procedure TCnGoalCodeFormatter.FormatInterfaceSection(PreSpaceCount: Byte);
begin
  Match(tokKeywordInterface, PreSpaceCount);

  while Scanner.Token = tokKeywordUses do
  begin
    WriteLine;
    FormatUsesClause(PreSpaceCount, CnPascalCodeForRule.UsesUnitSingleLine);
  end;

  if Scanner.Token in InterfaceDeclTokens then
  begin
    WriteLine;
    FormatInterfaceDecl(PreSpaceCount);
  end;
end;

{
  Library -> LIBRARY Ident ';'
             ProgramBlock '.'
}
procedure TCnGoalCodeFormatter.FormatLibrary(PreSpaceCount: Byte);
begin
  Match(tokKeywordLibrary);

  SpecifyElementType(pfetUnitName);
  try
    FormatIdent(PreSpaceCount);
  finally
    RestoreElementType;
  end;

  while Scanner.Token in DirectiveTokens do
    Match(Scanner.Token);

  Match(tokSemicolon);
  WriteLine;

  FormatProgramBlock(PreSpaceCount, True);
  Match(tokDot);
  Writeln;
end;

{
  Program -> [PROGRAM Ident ['(' IdentList ')'] ';']
             ProgramBlock '.'
}
procedure TCnGoalCodeFormatter.FormatPackage(PreSpaceCount: Byte);
begin
  Match(tokKeywordPackage, PreSpaceCount);
  SpecifyElementType(pfetUnitName);
  try
    FormatIdent;
  finally
    RestoreElementType;
  end;

  if Scanner.Token = tokSemicolon then
    Match(Scanner.Token, PreSpaceCount);

  WriteLine;
  FormatPackageBlock(PreSpaceCount);
  Match(tokKeywordEnd);
  Match(tokDot);
  Writeln;
end;

procedure TCnGoalCodeFormatter.FormatProgram(PreSpaceCount: Byte);
begin
  Match(tokKeywordProgram, PreSpaceCount);
  SpecifyElementType(pfetUnitName);
  try
    FormatIdent;
  finally
    RestoreElementType;
  end;

  if Scanner.Token = tokLB then
  begin
    Match(Scanner.Token);
    FormatIdentList;
    Match(tokRB);
  end;

  if Scanner.Token = tokSemicolon then // 难道可以不要分号？
    Match(Scanner.Token, PreSpaceCount);

  WriteLine;
  FormatProgramBlock(PreSpaceCount);
  Match(tokDot);
  Writeln;
end;

{
  Unit -> UNIT Ident [ DIRECTIVE ...] ';'
          InterfaceSection
          ImplementationSection
          [ InitSection ]
          END '.'
}
procedure TCnGoalCodeFormatter.FormatUnit(PreSpaceCount: Byte);
begin
  Match(tokKeywordUnit, PreSpaceCount);
  SpecifyElementType(pfetUnitName);
  try
    FormatIdent;
  finally
    RestoreElementType;
  end;

  while Scanner.Token in DirectiveTokens do
  begin
    Match(Scanner.Token);
  end;

  Match(tokSemicolon, PreSpaceCount);
  WriteLine;

  FormatInterfaceSection(PreSpaceCount);
  WriteLine;

  FormatImplementationSection(PreSpaceCount);
  WriteLine;

  if Scanner.Token in [tokKeywordInitialization, tokKeywordBegin] then // begin 也行
  begin
    FormatInitSection(PreSpaceCount);
    // 语句结尾可能没有分号，保留换行时会多写行尾回车，因此这里要保证不多写回车
    CheckKeepLineBreakWriteln;
    EnsureWriteLine;
  end;

  Match(tokKeywordEnd, PreSpaceCount);
  Match(tokDot);
  Writeln;
end;

{ ClassBody -> [ClassHeritage] [ClassMemberList END] }
procedure TCnBasePascalFormatter.FormatClassBody(PreSpaceCount: Byte);
begin
  if Scanner.Token = tokLB then
  begin
    FormatClassHeritage;
  end;

  if Scanner.Token <> tokSemiColon then
  begin
    Writeln;
    FormatClassMemberList(PreSpaceCount);
    Match(tokKeywordEnd, PreSpaceCount);
  end;
end;

procedure TCnBasePascalFormatter.FormatClassField(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetClassField);
  try
    FormatClassVarIdentList(PreSpaceCount);
    Match(tokColon);
    FormatType(PreSpaceCount);

    while Scanner.Token = tokSemicolon do
    begin
      Match(Scanner.Token);

      if Scanner.Token <> tokSymbol then
        Exit;

      Writeln;

      FormatClassVarIdentList(PreSpaceCount);
      Match(tokColon);
      FormatType(PreSpaceCount);
    end;
  finally
    RestoreElementType;
  end;
end;

{ ClassMember -> ClassField | ClassMethod | ClassProperty }
procedure TCnBasePascalFormatter.FormatClassMember(PreSpaceCount: Byte);
begin
  // no need loop here, we have one loop outter
  if Scanner.Token in ClassMemberSymbolTokens then // 部分关键字此处可以当做 Symbol
  begin
    case Scanner.Token of
      tokKeywordProcedure, tokKeywordFunction, tokKeywordConstructor,
      tokKeywordDestructor, tokKeywordOperator, tokKeywordClass:
        FormatClassMethod(PreSpaceCount);

      tokKeywordProperty:
        FormatClassProperty(PreSpaceCount);
      tokKeywordType:
        FormatClassTypeSection(PreSpaceCount);
      tokKeywordConst:
        FormatClassConstSection(PreSpaceCount);
        
      // 类里出现的var/threadvar等同于 class var/threadvar 的处理，都写在 FormatClassMethod 中
      tokKeywordVar, tokKeywordThreadvar:
        FormatClassMethod(PreSpaceCount);
      tokSLB:
        FormatSingleAttribute(PreSpaceCount); // 属性，包括 [Weak] 前缀
    else // 其他的都算 symbol
      FormatClassField(PreSpaceCount);
    end;

    Writeln;
  end;
end;

{ ClassMemberList -> ([ClassVisibility] [ClassMember]) ... }
procedure TCnBasePascalFormatter.FormatClassMemberList(
  PreSpaceCount: Byte);
var
  OldKeepOneBlankLine: Boolean;
begin
  while Scanner.Token in ClassVisibilityTokens + ClassMemberSymbolTokens do
  begin
    if Scanner.Token in ClassVisibilityTokens then
    begin
      FormatClassVisibility(PreSpaceCount);
      // 应该：如果下一个还是，就空一行
      // if Scaner.Token in ClassVisibilityTokens + [tokKeywordEnd] then
      //  Writeln;
    end;

    if Scanner.Token in ClassMemberSymbolTokens then
    begin
      OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
      Scanner.KeepOneBlankLine := True;
      try
        FormatClassMember(Tab(PreSpaceCount));
      finally
        Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
      end;
    end;
  end;
end;

{ ClassMethod -> [CLASS] MethodHeading ';' [(DIRECTIVE ';')...] }
procedure TCnBasePascalFormatter.FormatClassMethod(PreSpaceCount: Byte);
begin
  if Scanner.Token = tokKeywordClass then
  begin
    Match(tokKeywordClass, PreSpaceCount);
    if Scanner.Token in [tokKeywordProcedure, tokKeywordFunction,
      tokKeywordConstructor, tokKeywordDestructor, tokKeywordProperty,
      tokKeywordOperator] then // Single line heading
      FormatMethodHeading
    else
      FormatMethodHeading(PreSpaceCount, True);
  end
  else if Scanner.Token in [tokKeywordVar, tokKeywordThreadVar] then
  begin
    FormatMethodHeading(PreSpaceCount, False);
  end
  else
    FormatMethodHeading(PreSpaceCount);

  if Scanner.Token = tokSemicolon then // class property already processed ;
    Match(tokSemicolon, 0, 0, True);

  while Scanner.Token in DirectiveTokens do
  begin
    FormatDirective;
    if Scanner.Token = tokSemicolon then
      Match(tokSemicolon, 0, 0, True);
  end;
end;

{ ClassProperty -> PROPERTY Ident [PropertyInterface]  PropertySpecifiers ';' [DEFAULT ';']}
procedure TCnBasePascalFormatter.FormatClassProperty(PreSpaceCount: Byte);
begin
  Match(tokKeywordProperty, PreSpaceCount);
  FormatPossibleAmpersand;
  FormatIdent;

  if Scanner.Token in [tokSLB, tokColon] then
    FormatPropertyInterface;

  FormatPropertySpecifiers;
  Match(tokSemiColon);

  if Scanner.TokenSymbolIs('DEFAULT') then
  begin
    Match(Scanner.Token);
    Match(tokSemiColon);
  end;
end;

// class/record 内的 type 声明，对结束判断不一样。
procedure TCnBasePascalFormatter.FormatClassTypeSection(
  PreSpaceCount: Byte);
var
  FirstType, OldKeepOneBlankLine: Boolean;
begin
  Match(tokKeywordType, PreSpaceCount);
  Writeln;

  OldKeepOneBlankLine := Scanner.KeepOneBlankLine;
  Scanner.KeepOneBlankLine := False;

  try
    FirstType := True;
    while Scanner.Token in [tokSymbol, tokSLB, tokAmpersand] + ComplexTokens + DirectiveTokens
     + KeywordTokens - NOTExpressionTokens - NOTClassTypeConstTokens do  // 和普通 Type 类似但有一个差异
    begin
      if not FirstType then
        WriteLine;

      FormatTypeDecl(Tab(PreSpaceCount));
      while Scanner.Token in DirectiveTokens do
        FormatDirective;
      Match(tokSemicolon);
      FirstType := False;
    end;
  finally
    Scanner.KeepOneBlankLine := OldKeepOneBlankLine;
  end;
end;

{ procedure/function/constructor/destructor Name, can be classname.name}
procedure TCnBasePascalFormatter.FormatMethodName(PreSpaceCount: Byte);
begin
  FormatTypeParamIdent;
  // 加入对泛型的支持
  if Scanner.Token = tokDot then
  begin
    Match(tokDot);
    FormatTypeParamIdent;
  end;
end;

procedure TCnBasePascalFormatter.FormatClassConstSection(
  PreSpaceCount: Byte);
begin
  Match(tokKeywordConst, PreSpaceCount);

  while Scanner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens + KeywordTokens
   - NOTExpressionTokens - NOTClassTypeConstTokens do // 这些关键字不宜做变量名但也不好处理，只有先写上
  begin
    Writeln;
    FormatClassConstantDecl(Tab(PreSpaceCount));
    Match(tokSemicolon);
  end;
end;

procedure TCnBasePascalFormatter.FormatClassConstantDecl(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);

  case Scanner.Token of
    tokEQUAL:
      begin
        Match(Scanner.Token, 1); // 等号前空一格
        FCurrentTab := PreSpaceCount; // 记录当前缩进供常量表达式内部保留换行处理
        FormatConstExpr(1); // 等号后只空一格
      end;

    tokColon: // 无法直接区分 record/array/普通常量方式的初始化，需要内部解析
      begin
        Match(Scanner.Token);

        FormatType;
        Match(tokEQUAL, 1, 1); // 等号前后空一格

        FormatTypedConstant; // 等号后空一格
      end;
  else
    Error(CN_ERRCODE_PASCAL_NO_EQUALCOLON); 
  end;

  while Scanner.Token in DirectiveTokens do
    FormatDirective;
end;

{
 [ Ident : Ident | ( Expression, Expression ),
   Ident = Ident | ( Expression, Expression )... ]
}
procedure TCnBasePascalFormatter.FormatSingleAttribute(
  PreSpaceCount: Byte; LineEndSpaceCount: Byte);
var
  IsFirst, JustLn: Boolean;
begin
  Match(tokSLB, PreSpaceCount);
  FormatPossibleAmpersand(PreSpaceCount);

  IsFirst := True;
  repeat
    JustLn := False;
    if IsFirst then
      FormatIdent
    else
      FormatIdent(PreSpaceCount);
      
    if Scanner.Token = tokLB then
    begin
      Match(tokLB);
      FormatExprList;
      Match(tokRB);
    end
    else if Scanner.Token = tokColon then
    begin
      Match(tokColon);
      FormatIdent;
    end;

    if Scanner.Token = tokComma then // Multi-Attribute, use new line.
    begin
      Match(tokComma);
      IsFirst := False;
      Writeln;
      JustLn := True;
    end;

    // If not Attribute, maybe infinite loop here, jump and fix.
    if not (Scanner.Token in [tokSRB, tokUnknown, tokEOF]) then
    begin
      if JustLn then
        Match(Scanner.Token, PreSpaceCount)
      else
        Match(Scanner.Token);
    end;

  until Scanner.Token in [tokSRB, tokUnknown, tokEOF];
  Match(tokSRB, 0, LineEndSpaceCount);
end;

function TCnBasePascalFormatter.IsTokenAfterAttributesInSet(
  InTokens: TPascalTokenSet): Boolean;
var
  Bookmark: TScannerBookmark;
begin
  Scanner.SaveBookmark(Bookmark);
  CodeGen.LockOutput;

  try
    Result := False;
    if Scanner.Token <> tokSLB then
      Exit;

    // 要跳过多个可能紧邻的属性，而不止一个
    while Scanner.Token = tokSLB do
    begin
      while not (Scanner.Token in [tokEOF, tokUnknown, tokSRB]) do
        Scanner.NextToken;

      if Scanner.Token <> tokSRB then
        Exit;

      Scanner.NextToken;
    end;
    Result := (Scanner.Token in InTokens);
  finally
    Scanner.LoadBookmark(Bookmark);
    CodeGen.UnLockOutput;
  end;
end;

function TCnAbstractCodeFormatter.ErrorTokenString: string;
begin
  Result := TokenToString(Scanner.Token);
  if Result = '' then
    Result := Scanner.TokenString;
end;

procedure TCnAbstractCodeFormatter.WriteBlankLineByPrevCondition;
begin
  if Scanner.PrevBlankLines then
    Writeln
  else
    WriteLine;
end;

procedure TCnAbstractCodeFormatter.WriteLineFeedByPrevCondition;
begin
  if not Scanner.PrevBlankLines then
    Writeln;
end;

procedure TCnBasePascalFormatter.CheckWriteBeginln;
begin
  if (Scanner.Token <> tokKeywordBegin) or
    (CnPascalCodeForRule.BeginStyle <> bsSameLine) then
    Writeln;
end;

constructor TCnBasePascalFormatter.Create(AStream: TStream; AMatchedInStart,
  AMatchedInEnd: Integer; ACompDirectiveMode: TCnCompDirectiveMode);
begin
  inherited;
  FScanner.OnLineBreak := ScanerLineBreak;
  FScanner.OnGetCanLineBreak := ScanerGetCanLineBreak;
end;

{ TCnPascalCodeFormatter }

function TCnPascalCodeFormatter.CopyMatchedSliceResult: string;
begin
  Result := '';
  if FSliceMode and HasSliceResult then
  begin
    // 有匹配结果
    Result := CodeGen.CopyPartOut(MatchedOutStartRow, MatchedOutStartCol,
      MatchedOutEndRow, MatchedOutEndCol);
  end;
end;

procedure TCnPascalCodeFormatter.FormatCode(PreSpaceCount: Byte);
begin
  if FSliceMode then
    try
      inherited FormatCode(PreSpaceCount);
    except
      on E: EReadError do
      begin
        ; // Catch Eof Exception and give the result
      end;
    end
  else
    inherited FormatCode(PreSpaceCount);
end;

function TCnAbstractCodeFormatter.CodeGenGetInIgnore(Sender: TObject): Boolean;
begin
  Result := CnPascalCodeForRule.UseIgnoreArea and FScanner.InIgnoreArea;
end;

procedure TCnAbstractCodeFormatter.CodeGenAfterWrite(Sender: TObject;
  IsWriteBlank: Boolean; IsWriteln: Boolean; PrefixSpaces: Integer);
var
  StartPos, EndPos, I: Integer;
begin
  // CodeGen 写完一段字符串但 Scaner 还没 NextToken 时调用
  // 用来判断 Scaner 的位置是否是指定 Offset
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('OnAfter Write. From %d %d to %d %d. Scaner Offset is %d.',
//    [TCnCodeGenerator(Sender).PrevRow, TCnCodeGenerator(Sender).PrevColumn,
//    TCnCodeGenerator(Sender).CurrRow, TCnCodeGenerator(Sender).CurrColumn,
//    FScanner.SourcePos]);
{$ENDIF}

  // 记录目的与源的行映射
  if not IsWriteBlank and not IsWriteln and (FInputLineMarks <> nil) then
  begin
    for I := 0 to FInputLineMarks.Count - 1 do
    begin
      if Scanner.SourceLine >= Integer(FInputLineMarks[I]) then
        if Integer(FOutputLineMarks[I]) = 0 then // 第一回匹配
          FOutputLineMarks[I] := Pointer(TCnCodeGenerator(Sender).ActualRow);
    end;
  end;

  if IsWriteBlank then
  begin
    StartPos := FScanner.BlankStringPos;
    EndPos := FScanner.BlankStringPos + FScanner.BlankStringLength;
  end
  else
  begin
    StartPos := FScanner.SourcePos;
    EndPos := FScanner.SourcePos + FScanner.TokenStringLength;
  end;

  // 写出不属于代码本身的空行时超出标记的话不算，且在写注释前的空白时也不算
  if (StartPos >= FMatchedInStart) and not IsWriteln and not IsWriteBlank and not FFirstMatchStart then
  begin
    FMatchedOutStartRow := TCnCodeGenerator(Sender).PrevRow;
    FMatchedOutStartCol := TCnCodeGenerator(Sender).PrevColumn - FPrefixSpaces;
    // 碰上注释时还得补上上回输出空白时留下来的空白
    if FMatchedOutStartCol < 0 then
      FMatchedOutStartCol := 0;
    FFirstMatchStart := True;
{$IFDEF DEBUG}
//    CnDebugger.LogMsg('OnAfter Write. Got MatchStart.');
{$ENDIF}
  end
  else if (EndPos >= FMatchedInEnd) and IsWriteln and not FFirstMatchEnd then
  begin
    // 要写出代码外的空行时才算，以保证输出结果尾处有回车
    FMatchedOutEndRow := TCnCodeGenerator(Sender).CurrRow;
    FMatchedOutEndCol := TCnCodeGenerator(Sender).CurrColumn;
    FFirstMatchEnd := True;
{$IFDEF DEBUG}
//    CnDebugger.LogMsg('OnAfter Write. Got MatchEnd.');
{$ENDIF}
  end;
  FPrefixSpaces := PrefixSpaces;
end;

function TCnPascalCodeFormatter.HasSliceResult: Boolean;
begin
  Result := (MatchedOutStartRow <> CN_MATCHED_INVALID)
    and (MatchedOutStartCol <> CN_MATCHED_INVALID)
    and (MatchedOutEndRow <> CN_MATCHED_INVALID)
    and (MatchedOutEndCol <> CN_MATCHED_INVALID);
end;

procedure TCnAbstractCodeFormatter.RestoreElementType;
begin
  FLastElementType := FElementType;
  if FOldElementTypes <> nil then
    FElementType := TCnPascalFormattingElementType(FOldElementTypes.Pop)
  else
    FElementType := pfetUnknown;
end;

procedure TCnAbstractCodeFormatter.SpecifyElementType(
  Element: TCnPascalFormattingElementType);
begin
  if FOldElementTypes <> nil then
    FOldElementTypes.Push(Pointer(FElementType));
  FElementType := Element;
end;

procedure TCnAbstractCodeFormatter.ResetElementType;
begin
  FOldElementTypes.Free;
  FOldElementTypes := TCnElementStack.Create;

  FElementType := pfetUnknown;
  FLastElementType := pfetUnknown;
end;

procedure TCnAbstractCodeFormatter.SpecifyIdentifiers(Names: PLPSTR);
var
  P: LPSTR;
  S: string;
begin
  if FNamesMap <> nil then
    FreeAndNil(FNamesMap);
  FNamesMap := TCnStrToStrHashMap.Create;

  if Names = nil then
    Exit;

  while Names^ <> nil do
  begin
    P := Names^;
    S := string(StrPas(P));
    FNamesMap.Add(UpperCase(S), S);
    Inc(Names);
  end;
end;

procedure TCnAbstractCodeFormatter.SpecifyIdentifiers(Names: TStrings);
var
  I: Integer;
begin
  if FNamesMap <> nil then
    FreeAndNil(FNamesMap);
  FNamesMap := TCnStrToStrHashMap.Create;

  if Names = nil then
    Exit;

  for I := 0 to Names.Count - 1 do
    FNamesMap.Add(UpperCase(Names[I]), Names[I]);
end;

procedure TCnAbstractCodeFormatter.SpecifyLineMarks(Marks: PDWORD);
begin
  if FInputLineMarks <> nil then
    FreeAndNil(FInputLineMarks);
  if FOutputLineMarks <> nil then
    FreeAndNil(FOutputLineMarks);

  if Marks = nil then
    Exit;
  if Marks^ = 0 then
    Exit;

  FInputLineMarks := TList.Create;
  FOutputLineMarks := TList.Create;

  while Marks^ <> 0 do
  begin
    FInputLineMarks.Add(Pointer(Marks^));
    FOutputLineMarks.Add(nil);
    Inc(Marks);
  end;
end;

procedure TCnAbstractCodeFormatter.SaveOutputLineMarks(var Marks: PDWORD);
var
  I: Integer;
  M: PDWORD;
begin
  if (FOutputLineMarks = nil) or (FOutputLineMarks.Count = 0) or (Marks <> nil) then
    Exit;

  Marks := GetMemory((FOutputLineMarks.Count + 1) * SizeOf(DWORD));
  M := Marks;
  for I := 0 to FOutputLineMarks.Count - 1 do
  begin
    M^ := DWORD(FOutputLineMarks[I]);
    Inc(M);
  end;
  M^ := 0;
end;

function TCnAbstractCodeFormatter.CalcNeedPadding: Boolean;
begin
  Result := (FElementType in [pfetExpression, pfetEnumList,pfetArrayConstant,
    pfetSetConstructor, pfetFormalParameters, pfetUsesList, pfetFieldDecl, pfetClassField,
    pfetThen, pfetDo, pfetExprListRightBracket, pfetFormalParametersRightBracket,
    pfetRecVarFieldListRightBracket, pfetIfAfterElse])
    or ((FElementType in [pfetConstExpr]) and not UpperContainElementType([pfetCaseLabel])) // Case Label 的无需跟随上面一行注释缩进
    or UpperContainElementType([pfetFormalParameters, pfetArrayConstant, pfetCaseLabelList]);
  // 暂且表达式内部与枚举定义内部等一系列元素内部，或者在参数列表、uses 中
  // 碰到注释导致的换行时，才要求自动和上一行对齐，并进一步缩进
  // 还要求在本来不换行的组合语句里，比如 if then ，while do 里，for do 里
  // 严格来讲 then/do 这种还不同，不需要进一步缩进，不过暂时当作进一步缩进处理。
end;

function TCnAbstractCodeFormatter.CalcNeedPaddingAndUnIndent: Boolean;
begin
  Result := (FElementType in [pfetExprListRightBracket, pfetFormalParametersRightBracket,
    pfetFieldDecl, pfetClassField, pfetRecVarFieldListRightBracket])
    or UpperContainElementType([pfetCaseLabelList]);
  // 在 CalcNeedPadding 为 True 的前提下，以上要反缩进
end;

function TCnAbstractCodeFormatter.UpperContainElementType(ElementTypes:
  TCnPascalFormattingElementTypeSet): Boolean;
begin
  if FOldElementTypes = nil then
    Result := False
  else
    Result := FOldElementTypes.Contains(ElementTypes);
end;

{ TCnElementStack }

function TCnElementStack.Contains(
  ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to Count - 1 do
    if TCnPascalFormattingElementType(List[I]) in ElementTypes then
      Exit;
  Result := False;
end;

procedure TCnAbstractCodeFormatter.WriteOneSpace;
begin
  CodeGen.WriteOneSpace;
end;

procedure TCnAbstractCodeFormatter.EnsureOneEmptyLine;
begin
  FEnsureOneEmptyLine := True;
  Writeln;
  FEnsureOneEmptyLine := False;
end;

function TCnAbstractCodeFormatter.CurrentContainElementType(
  ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
begin
  Result := (FElementType in ElementTypes) or UpperContainElementType(ElementTypes);
end;

function TCnBasePascalFormatter.FormatPossibleAmpersand(PreSpaceCount: Byte): Boolean;
begin
  Result := False;
  if Scanner.Token = tokAmpersand then
  begin
    Match(tokAmpersand, PreSpaceCount);
    Result := True;
  end;
end;

procedure TCnBasePascalFormatter.CheckAddIdentBackup(List: TObjectList;
  const Ident: string);
var
  S, U: string;
  Obj: TCnIdentBackupObj;
begin
  if FStoreIdent and (List <> nil) and (FNamesMap <> nil) and (Ident <> '') then
  begin
    U := UpperCase(Ident);
    if FNamesMap.Find(U, S) then
    begin
      Obj := TCnIdentBackupObj.Create;
      Obj.OldUpperIdent := U;
      Obj.OldRealIdent := S;
      List.Add(Obj);

      FNamesMap.Delete(U);
    end;
    FNamesMap.Add(U, Ident);
  end;
end;

procedure TCnBasePascalFormatter.RestoreIdentBackup(List: TObjectList);
var
  I: Integer;
  Obj: TCnIdentBackupObj;
begin
  if (List <> nil) and (FNamesMap <> nil) then
  begin
    for I := List.Count - 1 downto 0 do
    begin
      Obj := TCnIdentBackupObj(List[I]);
      FNamesMap.Delete(Obj.OldUpperIdent);
      FNamesMap.Add(Obj.OldUpperIdent, Obj.OldRealIdent);
    end;
    List.Clear;
  end;
end;

procedure TCnBasePascalFormatter.ScanerLineBreak(Sender: TObject);
var
  LineBreak: Boolean;
begin
  if FScanner.IsForwarding or FScanner.InIgnoreArea then
    Exit;

  LineBreak := CanKeepLineBreak;
  FCodeGen.KeepLineBreak := LineBreak;

  // 注意不能调用 FScanner.ForwardToken 因为事件是在 SkipBlanks 里触发的
  // 另外，Lock 住时表示在往前回溯，是要回来的，无需做下面的事

  if LineBreak and (FCodeGen.LockedCount <= 0) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('On Scaner Line Break, to Write a CRLF.');
{$ENDIF}
    FCodeGen.Writeln;
    // 在原有缩进上前进 Tab 后回车
    if FCurrentTab > 0 then
    begin
      FCodeGen.Write(StringOfChar(' ', Tab(FCurrentTab)));
      FCodeGen.KeepLineBreakIndentWritten := True;
    end;
  end;
end;

procedure TCnAbstractCodeFormatter.EnsureWriteLine;
begin
  if FScanner.InIgnoreArea then
    Exit;

  // 如果已经连续俩空行了就不写
  if FCodeGen.IsLast2LineEmpty then
    // 啥都不做
  else if FCodeGen.IsLastLineEmpty then // 有一个空行了就写一个
    Writeln
  else // 啥都没有就写俩
    WriteLine;
end;

function TCnBasePascalFormatter.ScanerGetCanLineBreak(
  Sender: TObject): Boolean;
begin
  Result := CanKeepLineBreak;
end;

function TCnBasePascalFormatter.CheckSingleStatementBegin(PreSpaceCount: Byte): Boolean;
begin
  Result := CnPascalCodeForRule.SingleStatementToBlock and (Scanner.Token <> tokKeywordBegin);
  if Result then
  begin
    CodeGen.Write(FormatString('begin', CnPascalCodeForRule.KeywordStyle), PreSpaceCount);
    Writeln;
  end;
end;

procedure TCnBasePascalFormatter.CheckSingleStatementEnd(IsSingle: Boolean; PreSpaceCount: Byte);
begin
  if IsSingle then
  begin
    Writeln;
    CodeGen.Write(FormatString('end', CnPascalCodeForRule.KeywordStyle), PreSpaceCount);
  end;
end;

initialization
  MakeKeywordsValidAreas;

end.
