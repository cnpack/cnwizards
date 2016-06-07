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

unit CnCodeFormatter;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：格式化专家核心类 CnCodeFormater
* 单元作者：CnPack开发组
* 备    注：该单元实现了代码格式化的核心类
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 单元标识：$Id$
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
  CnTokens, CnScaners, CnCodeGenerators, CnCodeFormatRules, CnFormatterIntf;

const
  CN_MATCHED_INVALID = -1;

type
  TCnGoalType = (gtUnknown, gtProgram, gtLibrary, gtUnit, gtPackage);

  TCnElementStack = class(TStack)
  public
    function Contains(ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
  end;

  TCnAbstractCodeFormatter = class
  private
    FScaner: TAbstractScaner;
    FCodeGen: TCnCodeGenerator;
    FLastToken: TPascalToken;
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
    FPrefixSpaces: Integer;
    FEnsureOneEmptyLine: Boolean;

    FNamesMap: TCnStrToStrHashMap;
    FInputLineMarks: TList;         // 源与结果的行映射关系中的源行
    FOutputLineMarks: TList;        // 源与结果的行映射关系中的结果行
    function ErrorTokenString: string;
    procedure CodeGenAfterWrite(Sender: TObject; IsWriteBlank: Boolean;
      IsWriteln: Boolean; PrefixSpaces: Integer);

    // 区分当前的位置，必须配对使用
    procedure SpecifyElementType(Element: TCnPascalFormattingElementType);
    procedure RestoreElementType;
    // 区分当前位置并恢复，必须配对使用
    function UpperContainElementType(ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
    // 上层是否包含指定的几个 ElementType 之一，不包括当前
    function CurrentContainElementType(ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
    // 上层与当前是否包含指定的几个 ElementType 之一

    procedure ResetElementType;
    function CalcNeedPadding: Boolean;
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

    procedure CheckHeadComments;
    {* 处理代码开始之前的注释}
    function CanBeSymbol(Token: TPascalToken): Boolean;
    procedure Match(Token: TPascalToken; BeforeSpaceCount: Byte = 0;
      AfterSpaceCount: Byte = 0; IgnorePreSpace: Boolean = False;
      SemicolonIsLineStart: Boolean = False; NoSeparateSpace: Boolean = False);
    procedure MatchOperator(Token: TPascalToken); //操作符
    procedure WriteToken(Token: TPascalToken; BeforeSpaceCount: Byte = 0;
      AfterSpaceCount: Byte = 0; IgnorePreSpace: Boolean = False;
      SemicolonIsLineStart: Boolean = False; NoSeparateSpace: Boolean = False);

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
    {* 格式结果换行 }
    procedure WriteLine; 
    {* 格式结果加一空行 }
    procedure EnsureOneEmptyLine;
    {* 格式结果保证当前出现一空行}
    procedure WriteBlankLineByPrevCondition;
    {* 根据上一次是否输出了批量空行来决定本次输出单个回车还是双回车的空行，某些场合用来取代 WriteLine}
    procedure WriteLineFeedByPrevCondition;
    {* 根据上一次是否输出了批量空行来决定本次输出不换行还是单个回车，某些场合用来取代 Writeln}
    function FormatString(const KeywordStr: string; KeywordStyle: TKeywordStyle): string;
    {* 返回指定关键字风格的字符串}
    function UpperFirst(const KeywordStr: string): string;
    {* 返回首字母大写的字符串}
    property CodeGen: TCnCodeGenerator read FCodeGen;
    {* 目标代码生成器}
    property Scaner: TAbstractScaner read FScaner;
    {* 词法扫描器}
    property ElementType: TCnPascalFormattingElementType read FElementType;
    {* 标识当前区域的一个辅助变量}
  public
    constructor Create(AStream: TStream; AMatchedInStart: Integer = CN_MATCHED_INVALID;
      AMatchedInEnd: Integer = CN_MATCHED_INVALID;
      ACompDirectiveMode: TCompDirectiveMode = cdmAsComment);
    destructor Destroy; override;

    procedure SpecifyIdentifiers(Names: PLPSTR); overload;
    {* 以 PPAnsiChar 方式传入的字符指针数组，用来指定特定符号的大小写}
    procedure SpecifyIdentifiers(Names: TStrings); overload;
    {* 以 TStrings 方式传入的字符串，用来指定特定符号的大小写}
    procedure SpecifyLineMarks(Marks: PDWORD);
    {* 以 PDWORD 指向数组的方式传入的源文件的行映射的行}

    procedure FormatCode(PreSpaceCount: Byte = 0); virtual; abstract;
    procedure SaveToFile(FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToStrings(AStrings: TStrings);
    procedure SaveOutputLineMarks(var Marks: PDWORD);
    {* 将格式化结果中的行映射结果复制到数组中，数组指针须在外界释放}

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
    function IsTokenAfterAttributesInSet(InTokens: TPascalTokenSet): Boolean;
    procedure CheckWriteBeginln;
  protected
    // IndentForAnonymous 参数用来控制内部可能出现的匿名函数的缩进
    procedure FormatExprList(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
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
    procedure FormatConstExpr(PreSpaceCount: Byte = 0);
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
    procedure FormatSimpleType(PreSpaceCount: Byte = 0);
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
    procedure FormatIfStmt(PreSpaceCount: Byte = 0; IgnorePreSpace: Boolean = False);
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
    procedure FormatVarSection(PreSpaceCount: Byte = 0);
    procedure FormatVarDecl(PreSpaceCount: Byte = 0);
    procedure FormatProcedureDeclSection(PreSpaceCount: Byte = 0);
    procedure FormatSingleAttribute(PreSpaceCount: Byte = 0);
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
    procedure FormatFieldList(PreSpaceCount: Byte = 0; IgnoreFirst: Boolean = False);
    procedure FormatTypeSection(PreSpaceCount: Byte = 0);
    procedure FormatTypeDecl(PreSpaceCount: Byte = 0);
    procedure FormatTypedConstant(PreSpaceCount: Byte = 0);

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
    procedure FormatOperatorHeading(PreSpaceCount: Byte = 0);
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
  public
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
  if (FNamesMap = nil) or not FNamesMap.Find(UpperCase(S), Result) then
    Result := S;
end;

constructor TCnAbstractCodeFormatter.Create(AStream: TStream;
   AMatchedInStart, AMatchedInEnd: Integer;
   ACompDirectiveMode: TCompDirectiveMode);
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
  FScaner := TScaner.Create(AStream, FCodeGen, ACompDirectiveMode);

  FOldElementTypes := TCnElementStack.Create;
  FScaner.NextToken;
end;

destructor TCnAbstractCodeFormatter.Destroy;
begin
  FOldElementTypes.Free;
  FScaner.Free;
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
  PascalErrorRec.SourceLine := FScaner.SourceLine;
  PascalErrorRec.SourceCol := FScaner.SourceCol;
  PascalErrorRec.SourcePos := FScaner.SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;

  ErrorStr(RetrieveFormatErrorString(Ident));
end;

procedure TCnAbstractCodeFormatter.ErrorFmt(const Ident: Integer;
  const Args: array of const);
begin
  // 出错入口
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FScaner.SourceLine;
  PascalErrorRec.SourceCol := FScaner.SourceCol;
  PascalErrorRec.SourcePos := FScaner.SourcePos;
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
        [ Message, FScaner.SourceLine, FScaner.SourcePos ]
  );
end;

procedure TCnAbstractCodeFormatter.ErrorToken(Token: TPascalToken);
begin
  if TokenToString(Scaner.Token) = '' then
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [TokenToString(Token), Scaner.TokenString] )
  else
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [TokenToString(Token), TokenToString(Scaner.Token)]);
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
  ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [Str, TokenToString(Scaner.Token)]);
end;

function TCnAbstractCodeFormatter.FormatString(const KeywordStr: string;
  KeywordStyle: TKeywordStyle): string;
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
  Result := Scaner.Token in ([tokSymbol] + ComplexTokens); //KeywordTokens + DirectiveTokens);
end;

procedure TCnAbstractCodeFormatter.Match(Token: TPascalToken; BeforeSpaceCount,
  AfterSpaceCount: Byte; IgnorePreSpace: Boolean; SemicolonIsLineStart: Boolean;
  NoSeparateSpace: Boolean);
begin
  if (Scaner.Token = Token) or ( (Token = tokSymbol) and
    CanBeSymbol(Scaner.Token) ) then
  begin
    WriteToken(Token, BeforeSpaceCount, AfterSpaceCount,
      IgnorePreSpace, SemicolonIsLineStart, NoSeparateSpace);
    Scaner.NextToken;
  end
  else if FInternalRaiseException or not CnPascalCodeForRule.ContinueAfterError then
  begin
    if FSliceMode and (Scaner.Token = tokEOF) then
      raise EReadError.Create('Eof')
    else
      ErrorToken(Token);
  end
  else // 要继续的场合，写了再说
  begin
    WriteToken(Token, BeforeSpaceCount, AfterSpaceCount,
      IgnorePreSpace, SemicolonIsLineStart, NoSeparateSpace);
    Scaner.NextToken;
  end;
end;

procedure TCnAbstractCodeFormatter.MatchOperator(Token: TPascalToken);
begin
  Match(Token, CnPascalCodeForRule.SpaceBeforeOperator,
        CnPascalCodeForRule.SpaceAfterOperator);
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
    if not (Scaner.Token in [tokKeywordBegin, tokKeywordTry]) then
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
  if CnPascalCodeForRule.UseIgnoreArea and Scaner.InIgnoreArea then  // 在忽略区，不主动写换行，让 SkipBlank 写。
  begin
    FLastToken := tokBlank;
    Exit;
  end;

  if (Scaner.BlankLinesBefore = 0) and (Scaner.BlankLinesAfter = 0) then
  begin
    FCodeGen.Writeln;
    FCodeGen.Writeln;
  end
  else // 有 Comment，已经输出了，但 Comment 后的空行未输出，并且前后各有换行
  begin
    if Scaner.BlankLinesBefore = 0 then
    begin
      // 注释块和上一行在一起，照常输出俩空行
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scaner.BlankLinesBefore > 1) and (Scaner.BlankLinesAfter = 1) then
    begin
      // 注释块空上不空下，那就让下面挨着下，不需要额外输出空行了
      ;
    end
    else if (Scaner.BlankLinesBefore > 1) and (Scaner.BlankLinesAfter > 1) then
    begin
      // 注释块上下都空，那下面保留一空行
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scaner.BlankLinesBefore = 1) and (Scaner.BlankLinesAfter = 1) then
    begin
      // 上下都不空，采取靠上策略
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scaner.BlankLinesBefore = 1) and (Scaner.BlankLinesAfter > 1) then
    begin
      // 上空下不空，那就靠上
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end;  
  end;
  FLastToken := tokBlank; // prevent 'Symbol'#13#10#13#10' Symbol'
end;

procedure TCnAbstractCodeFormatter.Writeln;
begin
  if CnPascalCodeForRule.UseIgnoreArea and Scaner.InIgnoreArea then  // 在忽略区，不主动写换行，让 SkipBlank 写。
  begin
    FLastToken := tokBlank;
    Exit;
  end;

  if FEnsureOneEmptyLine then // 如果外部要求本次保持一空行
  begin
    FCodeGen.CheckAndWriteOneEmptyLine;
  end
  else if (Scaner.BlankLinesBefore = 0) and (Scaner.BlankLinesAfter = 0) then
  begin
    FCodeGen.Writeln;
  end
  else // 有 Comment，已经输出了，但 Comment 后的空行未输出，并且前后各有换行
  begin
    if Scaner.BlankLinesBefore = 0 then
    begin
      // 注释块和上一行在一起，照常输出空行
      FCodeGen.Writeln;

      // 注释块后面有空行，则相应保持
      if Scaner.BlankLinesAfter > 1 then
        FCodeGen.Writeln;
    end
    else if (Scaner.BlankLinesBefore > 1) and (Scaner.BlankLinesAfter = 1) then
    begin
      // 注释块空上不空下，那就让下面挨着下，不需要额外输出空行了
      ;
    end
    else if (Scaner.BlankLinesBefore >= 1) and (Scaner.BlankLinesAfter > 1) then
    begin
      // 注释块上下都空或者上不空下空，那下面保留一空行
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scaner.BlankLinesBefore = 1) and (Scaner.BlankLinesAfter = 1) then
    begin
      // 上下都不空，采取靠上策略
      FCodeGen.Writeln;
    end;
  end;
  FLastToken := tokBlank; // prevent 'Symbol'#13#10' Symbol'
end;

procedure TCnAbstractCodeFormatter.WriteToken(Token: TPascalToken;
  BeforeSpaceCount, AfterSpaceCount: Byte; IgnorePreSpace: Boolean;
  SemicolonIsLineStart: Boolean; NoSeparateSpace: Boolean);
var
  NeedPadding: Boolean;
  NeedUnIndent: Boolean;
begin
  if CnPascalCodeForRule.UseIgnoreArea and Scaner.InIgnoreArea then
  begin
    // 在忽略块内部，将非注释非空白内容原始输出，其中空白与注释由 Scaner 内部处理
    CodeGen.Write(Scaner.TokenString);
    FLastToken := Token;
    Exit;
  end;

  if not NoSeparateSpace then  // 如果不要插入分隔空格，则跳过此段
  begin
    // 两个标识符之间以空格分离，前提是本行未被注释等分行从而隔开 FLastToken
    if not FCodeGen.NextOutputWillbeLineHead and
      ((FLastToken in IdentTokens) and (Token in IdentTokens + [tokAtSign])) then
      WriteOneSpace
    else if ((BeforeSpaceCount = 0) and (FLastToken = tokGreat) and (Token in IdentTokens + [tokAtSign])) then
      WriteOneSpace // 泛型 property 后面加 read 时，需要用这种方式加空格分开
    else if (FLastToken in RightBracket + [tokHat]) and (Token in [tokKeywordThen, tokKeywordDo,
      tokKeywordOf, tokKeywordTo, tokKeywordDownto]) then
      WriteOneSpace  // 强行分离右括号/指针符与关键字
    else if (Token in LeftBracket + [tokPlus, tokMinus, tokHat]) and
      ((FLastToken in NeedSpaceAfterKeywordTokens)
      or ((FLastToken = tokKeywordAt) and UpperContainElementType([pfetRaiseAt]))) then
      WriteOneSpace; // 强行分离左括号/前置运算符号，与关键字以及 raise 语句中的 at，注意 at 后的表达式盖掉了pfetRaiseAt，所以需要获取上一层
  end;

  NeedPadding := CalcNeedPadding;
  NeedUnIndent := CalcNeedPaddingAndUnIndent;

  //标点符号的设置
  case Token of
    tokComma:
      CodeGen.Write(Scaner.TokenString, 0, 1, NeedPadding);   // 1 也会导致行尾注释后退，现多出的空格已由 Generator 删除
    tokColon:
      begin
        if IgnorePreSpace then
          CodeGen.Write(Scaner.TokenString, 0, 0, NeedPadding)
        else
          CodeGen.Write(Scaner.TokenString, 0, 1, NeedPadding);  // 1 也会导致行尾注释后退，现多出的空格已由 Generator 删除
      end;
    tokSemiColon:
      begin
        if IgnorePreSpace then
          CodeGen.Write(Scaner.TokenString)
        else if SemicolonIsLineStart then
          CodeGen.Write(Scaner.TokenString, BeforeSpaceCount, 0, NeedPadding)
        else
          CodeGen.Write(Scaner.TokenString, 0, 1, NeedPadding);
          // 1 也会导致行尾注释后退，现多出的空格已由 Generator 删除
      end;
    tokAssign:
      CodeGen.Write(Scaner.TokenString, 1, 1, NeedPadding);
  else
    if (Token in KeywordTokens + ComplexTokens + DirectiveTokens) then // 关键字范围扩大
    begin
      if FLastToken = tokAmpersand then // 关键字前是 & 表示非关键字
      begin
        CodeGen.Write(CheckIdentifierName(Scaner.TokenString), BeforeSpaceCount, AfterSpaceCount);
      end
      else if CheckOutOfKeywordsValidArea(Token, ElementType) then
      begin
        // 关键字有效作用域外均在此原样输出
        CodeGen.Write(CheckIdentifierName(Scaner.TokenString),
          BeforeSpaceCount, AfterSpaceCount, NeedPadding);
      end
      else
      begin
        if (Token <> tokKeywordEnd) and (Token <> tokKeywordString) then
        begin
            CodeGen.Write(
              FormatString(CheckIdentifierName(Scaner.TokenString),
                CnPascalCodeForRule.KeywordStyle),
              BeforeSpaceCount, AfterSpaceCount, NeedPadding);
        end
        else
        begin
          CodeGen.Write(
            FormatString(CheckIdentifierName(Scaner.TokenString),
            CnPascalCodeForRule.KeywordStyle), BeforeSpaceCount,
            AfterSpaceCount, NeedPadding);
        end;
      end;
    end
    else if FIsTypeID then // 如果是类型名，则按规则处理 Scaner.TokenString
    begin
      CodeGen.Write(CheckIdentifierName(Scaner.TokenString), BeforeSpaceCount,
        AfterSpaceCount, NeedPadding);
    end
    else // 目前只有右括号部分
    begin
      CodeGen.Write(CheckIdentifierName(Scaner.TokenString), BeforeSpaceCount,
        AfterSpaceCount, NeedPadding, NeedUnIndent);
    end;
  end;

  FLastToken := Token;
end;

procedure TCnAbstractCodeFormatter.CheckHeadComments;
var
  I: Integer;
begin
  if FCodeGen <> nil then
    for I := 1 to Scaner.BlankLinesAfter do
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
procedure TCnBasePascalFormatter.FormatConstExpr(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetConstExpr);
  try
    // 从 FormatExpression 复制而来，为了区分来源
    FormatSimpleExpression(PreSpaceCount, PreSpaceCount);

    while Scaner.Token in RelOpTokens + [tokHat, tokSLB, tokDot] do
    begin
      // 这块对泛型的处理已移动到内部以处理 function call 的情形

      if Scaner.Token in RelOpTokens then
      begin
        MatchOperator(Scaner.Token);
        FormatSimpleExpression;
      end;

      // 这几处额外的内容，不知道有啥副作用

      // pchar(ch)^
      if Scaner.Token = tokHat then
        Match(tokHat)
      else if Scaner.Token = tokSLB then  // PString(PStr)^[1]
      begin
        Match(tokSLB);
        FormatExprList(0, PreSpaceCount);
        Match(tokSRB);
      end
      else if Scaner.Token = tokDot then // typecase
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

  while Scaner.Token in (RelOpTokens - [tokEqual, tokLess, tokGreat])  do
  begin
    MatchOperator(Scaner.Token);
    FormatSimpleExpression;
  end;
end;

{
  Designator -> QualId ['.' Ident | '[' ExprList ']' | '^']...

  注：虽然有 Designator -> '(' Designator ')' 的情况，但已经包含在 QualId 的处理中了。
}
procedure TCnBasePascalFormatter.FormatDesignator(PreSpaceCount: Byte;
  IndentForAnonymous: Byte);
var
  IsRB: Boolean;
begin
  if Scaner.Token = tokAtSign then // 如果是 @ Designator 的形式则再次递归
  begin
    Match(tokAtSign, PreSpaceCount);
    FormatDesignator(0, IndentForAnonymous);
    Exit;
  end
  else if Scaner.Token = tokKeywordInherited then // 处理 (inherited a).a; 这种语法
    Match(tokKeywordInherited);

  FormatQualID(PreSpaceCount);
  while Scaner.Token in [tokDot, tokLB, tokSLB, tokHat, tokPlus, tokMinus] do
  begin
    case Scaner.Token of
      tokDot:
        begin
          Match(tokDot);
          FormatIdent;
        end;

      tokLB, tokSLB: // [ ] ()
        begin
          { DONE: deal with index visit and function/procedure call}
          Match(Scaner.Token);
          FormatExprList(PreSpaceCount, IndentForAnonymous);

          IsRB := Scaner.Token = tokRB;
          if IsRB then
            SpecifyElementType(pfetExprListRightBracket);
          try
            Match(Scaner.Token);
          finally
            if IsRB then
              RestoreElementType;
          end;
        end;

      tokHat: // ^
        begin
          { DONE: deal with pointer derefrence }
          Match(tokHat);
        end;

      tokPlus, tokMinus:
        begin
          MatchOperator(Scaner.Token);
          FormatExpression(0, PreSpaceCount);
        end;
    end; // case
  end; // while
end;

{ DesignatorList -> Designator/','... }
procedure TCnBasePascalFormatter.FormatDesignatorList(PreSpaceCount: Byte);
begin
  FormatDesignator;

  while Scaner.Token = tokComma do
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

    while Scaner.Token in RelOpTokens + [tokHat, tokSLB, tokDot] do
    begin
      // 这块对泛型的处理已移动到内部以处理 function call 的情形

      if Scaner.Token in RelOpTokens then
      begin
        MatchOperator(Scaner.Token);
        FormatSimpleExpression;
      end;

      // 这几处额外的内容，不知道有啥副作用

      // pchar(ch)^
      if Scaner.Token = tokHat then
        Match(tokHat)
      else if Scaner.Token = tokSLB then  // PString(PStr)^[1]
      begin
        Match(tokSLB);
        FormatExprList(0, PreSpaceCount);
        Match(tokSRB);
      end
      else if Scaner.Token = tokDot then // typecase
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
  IndentForAnonymous: Byte);
begin
  FormatExpression(0, IndentForAnonymous);

  if Scaner.Token = tokAssign then // 匹配 OLE 调用的情形
  begin
    Match(tokAssign);
    FormatExpression(0, IndentForAnonymous);
  end;

  while Scaner.Token = tokComma do
  begin
    Match(tokComma, 0, 1);

    if Scaner.Token in ([tokAtSign, tokLB] + ExprTokens + KeywordTokens +
      DirectiveTokens + ComplexTokens) then // 有关键字做变量名的情况也得考虑到
    begin
      FormatExpression(0, IndentForAnonymous);

      if Scaner.Token = tokAssign then // 匹配 OLE 调用的情形
      begin
        Match(tokAssign);
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
         -> '(' Expression ')'
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
  case Scaner.Token of
    tokSymbol, tokAtSign,
    tokKeyword_BEGIN..tokKeywordIn,  // 此三行表示部分关键字也可做 Factor
    tokAmpersand,                    // & 号也可作为 Identifier
    tokKeywordInitialization..tokKeywordNil,
    tokKeywordObject..tokKeyword_END,
    tokDirective_BEGIN..tokDirective_END,
    tokComplex_BEGIN..tokComplex_END:
      begin
        FormatDesignator(PreSpaceCount, IndentForAnonymous);

        if Scaner.Token = tokLB then
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
        FormatExpression;
      end;

    tokChar, tokWString, tokString, tokInteger, tokFloat, tokTrue, tokFalse:
      begin
        NeedPadding := CalcNeedPadding;
        case Scaner.Token of
          tokInteger, tokFloat:
            WriteToken(Scaner.Token, PreSpaceCount);
          tokTrue, tokFalse:
            if CnPascalCodeForRule.UseIgnoreArea and Scaner.InIgnoreArea then
              CodeGen.Write(Scaner.TokenString)
            else
              CodeGen.Write(UpperFirst(Scaner.TokenString), PreSpaceCount, 0, NeedPadding);
            // CodeGen.Write(FormatString(Scaner.TokenString, CnCodeForRule.KeywordStyle), PreSpaceCount);
          tokChar, tokString, tokWString:
            begin
              if CnPascalCodeForRule.UseIgnoreArea and Scaner.InIgnoreArea then
                CodeGen.Write(Scaner.TokenString)
              else
              begin
                if (FLastToken in NeedSpaceAfterKeywordTokens) // 字符串前面是这些关键字时，要以至少一个空格分隔
                  and (PreSpaceCount = 0) then
                  PreSpaceCount := 1;
                CodeGen.Write(Scaner.TokenString, PreSpaceCount, 0, NeedPadding);
              end;
            end;
        end;

        FLastToken := Scaner.Token;
        Scaner.NextToken;
      end;

    tokKeywordNOT:
      begin
        if Scaner.ForwardToken in [tokLB] then // 无奈之举，避免少个空格
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
  while Scaner.Token = tokSLB do // Attribute
  begin
    FormatSingleAttribute(PreSpaceCount);
    // if not CurrentContainElementType([pfetFormalParameters]) then // 参数列表里的属性不换行
    Writeln;
  end;

  if Scaner.Token = tokAmpersand then // & 表示后面的声明使用的关键字是转义的
  begin
    Match(Scaner.Token, PreSpaceCount); // 在此缩进
    if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scaner.Token); // & 后的标识符中允许使用部分关键字，但不允许新语法的数字等
  end
  else if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens + CanBeNewIdentifierTokens) then
    Match(Scaner.Token, PreSpaceCount); // 标识符中允许使用部分关键字，在此缩进

  while CanHaveUnitQual and (Scaner.Token = tokDot) do
  begin
    Match(tokDot);
    if Scaner.Token = tokAmpersand then // & 表示后面的声明使用的关键字是转义的
    begin
      Match(Scaner.Token); // 点号后无需缩进
      if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
        Match(Scaner.Token); // & 后的标识符中允许使用部分关键字，但不允许新语法的数字等
    end
    else if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens + CanBeNewIdentifierTokens) then
      Match(Scaner.Token); // 也继续允许使用部分关键字
  end;
end;

{ IdentList -> Ident/','... }
procedure TCnBasePascalFormatter.FormatIdentList(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  FormatIdent(PreSpaceCount, CanHaveUnitQual);

  while Scaner.Token = tokComma do
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
    while Scaner.Token = tokLB do
    begin
      Match(tokLB);
      Inc(BracketCount);
    end;

    FormatIdent(PreSpaceCount, True);

    // 这儿应该加入泛型判断
    IsGeneric := False;
    if Scaner.Token = tokLess then
    begin
      // 判断泛型，如果不是，恢复书签往下走；如果是，就恢复书签处理泛型
      Scaner.SaveBookmark(GenericBookmark);
      CodeGen.LockOutput;

      // 往后找，一直找到非类型的关键字或者分号或者文件尾。
      // 如果出现小于号和大于号一直不配对，则认为不是泛型。
      // TODO: 判断还是不太严密，待继续验证。
      Scaner.NextToken;
      LessCount := 1;
      while not (Scaner.Token in KeywordTokens + [tokSemicolon, tokEOF] - CanBeTypeKeywordTokens) do
      begin
        if Scaner.Token = tokLess then
          Inc(LessCount)
        else if Scaner.Token = tokGreat then
          Dec(LessCount);

        if LessCount = 0 then // Test<TObject><1 的情况，需要为 0 配对时就提前跳出
          Break;

        Scaner.NextToken;
      end;
      IsGeneric := (LessCount = 0);
      
      Scaner.LoadBookmark(GenericBookmark);
      CodeGen.UnLockOutput;
    end;

    if IsGeneric then
      FormatTypeParams;
      
    for I := 1 to BracketCount do
      Match(tokRB);
  end;

begin
  if(Scaner.Token = tokLB) then
  begin
    Match(tokLB, PreSpaceCount);
    FormatDesignator;

    if(Scaner.Token = tokKeywordAs) then
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

    if Scaner.Token = tokRange then
    begin
      Match(tokRange);
      FormatExpression;
    end;
  end;
  
begin
  Match(tokSLB);
  SpecifyElementType(pfetSetConstructor);
  try
    if Scaner.Token <> tokSRB then
    begin
      FormatSetElement;
    end;

    while Scaner.Token = tokComma do
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
begin
  if Scaner.Token in [tokPlus, tokMinus, tokHat] then // ^H also support
  begin
    Match(Scaner.Token, PreSpaceCount);
    FormatTerm(0, IndentForAnonymous);
  end
  else if Scaner.Token in [tokKeywordFunction, tokKeywordProcedure] then
  begin
    // Anonymous function/procedure. 匿名函数的缩进使用 IndentForAnonymous 参数
    Writeln;
    if Scaner.Token = tokKeywordProcedure then
      FormatProcedureDecl(Tab(IndentForAnonymous), True)
    else
      FormatFunctionDecl(Tab(IndentForAnonymous), True);
  end
  else
    FormatTerm(PreSpaceCount, IndentForAnonymous);

  while Scaner.Token in AddOpTokens do
  begin
    MatchOperator(Scaner.Token);
    FormatTerm(0, IndentForAnonymous);
  end;
end;

{ Term -> Factor [MulOp Factor]... }
procedure TCnBasePascalFormatter.FormatTerm(PreSpaceCount: Byte; IndentForAnonymous: Byte);
begin
  FormatFactor(PreSpaceCount, IndentForAnonymous);

  while Scaner.Token in (MulOPTokens + ShiftOpTokens) do
  begin
    MatchOperator(Scaner.Token);
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
  if Scaner.Token = tokColon then // ConstraintList
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
  while Scaner.Token = tokSemicolon do
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
  while Scaner.Token = tokLess do
    FormatTypeParams(PreSpaceCount);

  while Scaner.Token = tokComma do // 暂不处理 CAttr
  begin
    Match(tokComma);
    FormatIdent(PreSpaceCount);
    // 泛型中可能又套泛型
    while Scaner.Token = tokLess do
      FormatTypeParams(PreSpaceCount);
  end;
end;

{ TypeParams -> '<' TypeParamDeclList '>' }
function TCnBasePascalFormatter.FormatTypeParams(PreSpaceCount: Byte;
  AllowFixEndGreateEqual: Boolean): Boolean;
begin
  Result := False;
  Match(tokLess);
  FormatTypeParamDeclList(PreSpaceCount);
  if AllowFixEndGreateEqual and (Scaner.Token = tokGreatOrEqu) then
  begin
    Match(tokGreatOrEqu, 0, 1); // TODO: 拆开 > 与 =
    Result := True;
  end
  else
    Match(tokGreat);
end;

procedure TCnBasePascalFormatter.FormatTypeParamIdent(PreSpaceCount: Byte);
begin
  if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
    Match(Scaner.Token, PreSpaceCount); // 标识符中允许使用部分关键字

  while Scaner.Token = tokDot do
  begin
    Match(tokDot);
    if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scaner.Token); // 也继续允许使用部分关键字
  end;

  if Scaner.Token = tokLess then
    FormatTypeParams;
end;

procedure TCnBasePascalFormatter.FormatTypeParamIdentList(
  PreSpaceCount: Byte);
begin
  FormatTypeParamIdent(PreSpaceCount);

  while Scaner.Token = tokComma do
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

    if Scaner.Token = tokRange then
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
begin
  FormatCaseLabel(PreSpaceCount);

  while Scaner.Token = tokComma do
  begin
    Match(tokComma);
    FormatCaseLabel; 
  end;

  Match(tokColon);
  // 每个 caselabel 后的 begin 都换行，不受 begin 风格的影响
  Writeln;
  if Scaner.Token = tokKeywordBegin then // 得有 begin 才这样设置，否则会影响后续语句
    FNextBeginShouldIndent := True;

  if Scaner.Token <> tokSemicolon then
    FormatStatement(Tab(PreSpaceCount, False))
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

  while Scaner.Token in [tokSemicolon, tokKeywordEnd] do
  begin
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon);

    Writeln;
    if Scaner.Token in [tokKeywordElse, tokKeywordEnd] then
      Break;   
    FormatCaseSelector(Tab(PreSpaceCount));
  end;

  HasElse := False;
  if Scaner.Token = tokKeywordElse then
  begin
    HasElse := True;
    if FLastToken = tokKeywordEnd then
      Writeln;
    // else 前可不需要空一行
    Match(tokKeywordElse, PreSpaceCount, 1);
    Writeln;
    // FormatStatement(Tab(PreSpaceCount, False)); 
    // 此处修改成匹配多个语句
    FormatStmtList(Tab(PreSpaceCount, False));
  end;

  if Scaner.Token = tokSemicolon then
    Match(tokSemicolon);

  if HasElse then
    Writeln;
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
  OldKeepOneBlankLine := Scaner.KeepOneBlankLine;
  Scaner.KeepOneBlankLine := True;
  try
    case Scaner.Token of
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
          if Scaner.Token <> tokKeywordEnd then
          begin
            FormatStmtList(Tab(PreSpaceCount, False));
            Writeln;
          end;
          Match(tokKeywordEnd, PreSpaceCount);
        end;

      tokKeywordAsm:
        begin
          FormatAsmBlock(PreSpaceCount);
        end;
    else
      ErrorTokens([tokKeywordBegin, tokKeywordAsm]);
    end;
  finally
    Scaner.KeepOneBlankLine := OldKeepOneBlankLine;
  end;
end;

{ ForStmt -> FOR QualId ':=' Expression (TO | DOWNTO) Expression DO Statement }
{ ForStmt -> FOR QualId in Expression DO Statement }

procedure TCnBasePascalFormatter.FormatForStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordFor, PreSpaceCount);
  FormatQualId;

  case Scaner.Token of
    tokAssign:
      begin
        Match(tokAssign);
        FormatExpression;

        if Scaner.Token in [tokKeywordTo, tokKeywordDownTo] then
          Match(Scaner.Token)
        else
          ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, ['to/downto', TokenToString(Scaner.Token)]);

        FormatExpression;
      end;

    tokKeywordIn:
      begin
        Match(tokKeywordIn, 1, 1);
        FormatExpression;
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

  if Scaner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;
  FormatStatement(Tab(PreSpaceCount));
end;

{ IfStmt -> IF Expression THEN Statement [ELSE Statement] }
procedure TCnBasePascalFormatter.FormatIfStmt(PreSpaceCount: Byte; IgnorePreSpace: Boolean);
var
  OldKeepOneBlankLine, ElseAfterThen: Boolean;
begin
  if IgnorePreSpace then
    Match(tokKeywordIF)
  else
    Match(tokKeywordIF, PreSpaceCount);

  { TODO: Apply more if stmt rule }
  FormatExpression(0, PreSpaceCount);
  SpecifyElementType(pfetThen);
  try
    OldKeepOneBlankLine := Scaner.KeepOneBlankLine;
    Scaner.KeepOneBlankLine := False;
    Match(tokKeywordThen);  // To Avoid 2 Empty Line after then in 'if True then (CRLFCRLF) else Exit;'
    Scaner.KeepOneBlankLine := OldKeepOneBlankLine;
  finally
    RestoreElementType;
  end;
  CheckWriteBeginln; // 检查 if then begin 是否同行

  if Scaner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;

  ElseAfterThen := Scaner.Token = tokKeywordElse;
  FormatStatement(Tab(PreSpaceCount));

  if Scaner.Token = tokKeywordElse then
  begin
    if ElseAfterThen then // 如果 then 后紧跟 else，则 then 和 else 间空一行。
      EnsureOneEmptyLine
    else
      Writeln;
    Match(tokKeywordElse, PreSpaceCount);
    if Scaner.Token = tokKeywordIf then // 处理 else if
    begin
      FormatIfStmt(PreSpaceCount, True);
      FormatStatement(Tab(PreSpaceCount));
    end
    else
    begin
      CheckWriteBeginln; // 检查 else begin 是否同行
      if Scaner.Token = tokSemicolon then
        FStructStmtEmptyEnd := True;
      FormatStatement(Tab(PreSpaceCount));
    end;
  end;
end;

{ RepeatStmt -> REPEAT StmtList UNTIL Expression }
procedure TCnBasePascalFormatter.FormatRepeatStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordRepeat, PreSpaceCount, 1);
  Writeln;
  FormatStmtList(Tab(PreSpaceCount));
  Writeln;
  
  Match(tokKeywordUntil, PreSpaceCount);
  FormatExpression(0, PreSpaceCount);
end;

{
  SimpleStatement -> Designator ['(' ExprList ')']
                  -> Designator ':=' Expression
                  -> INHERITED
                  -> GOTO LabelId
                  -> '(' SimpleStatement ')'

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
     则难以和 '(' SimpleStatement ')' 区分。而且 Designator 自身也可能是括号嵌套
     现在的处理方法是，先关闭输出，按 Designator 处理（FormatDesignator内部加了
     括号嵌套的处理机制），扫描处理完毕后看后续的符号以决定是 Designator 还是
     Simplestatement，然后再次回到起点打开输出继续处理。
}
procedure TCnBasePascalFormatter.FormatSimpleStatement(PreSpaceCount: Byte);
var
  Bookmark: TScannerBookmark;
  OldLastToken: TPascalToken;
  IsDesignator, OldInternalRaiseException: Boolean;

  procedure FormatDesignatorAndOthers(PreSpaceCount: Byte);
  begin
    FormatDesignator(PreSpaceCount, PreSpaceCount);

    while Scaner.Token in [tokAssign, tokLB, tokLess] do
    begin
      case Scaner.Token of
        tokAssign:
          begin
            Match(tokAssign);
            FormatExpression(0, PreSpaceCount);
          end;

        tokLB:
          begin
            { DONE: deal with function call, save to symboltable }
            Match(tokLB);
            FormatExprList(0, PreSpaceCount);
            Match(tokRB);

            if Scaner.Token = tokHat then
              Match(tokHat);

            if Scaner.Token = tokDot then
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
  case Scaner.Token of
    tokSymbol, tokAtSign, tokKeywordFinal, tokKeywordIn, tokKeywordOut,
    tokKeywordString, tokKeywordAlign, tokInteger, tokFloat,
    tokDirective_BEGIN..tokDirective_END, // 允许语句以部分关键字以及数字开头
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
        Match(Scaner.Token, PreSpaceCount);

        if CanBeSymbol(Scaner.Token) then
          FormatSimpleStatement;
      end;

    tokKeywordGoto:
      begin
        Match(Scaner.Token, PreSpaceCount);
        { DONE: FormatLabel }
        FormatLabel;
      end;

    tokLB: // 括号开头的未必是 (SimpleStatement)，还可能是 (a)^ := 1 这种 Designator
      begin
        // found in D9 surpport: if ... then (...)

        // can delete the LB & RB, code optimize ??
        // 先当做 Designator 来看，处理完毕看后续有无 := ( 来判断是否结束
        // 如果是结束了，则 Designator 的处理是对的，否则按 Simplestatement 来。

        Scaner.SaveBookmark(Bookmark);
        OldLastToken := FLastToken;
        OldInternalRaiseException := FInternalRaiseException;
        FInternalRaiseException := True;
        // 需要 Exception 来判断后续内容

        try
          CodeGen.LockOutput;

          try
            FormatDesignator(PreSpaceCount);
            // 假设 Designator 处理完毕，判断后续是啥

            IsDesignator := Scaner.Token in [tokAssign, tokLB, tokSemicolon,
              tokKeywordElse, tokKeywordEnd];
            // TODO: 目前只想到这几个。Semicolon 是怕 Designator 已经作为语句处理完了，
            // else/end 是怕语句结束没分号导致判断失误。
          except
            IsDesignator := False;
            // 如果后面碰到了 := 等情形，FormatDesignator 会出错，
            // 说明本句是带括号嵌套的 Simplestatement
          end;
        finally
          Scaner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;
          CodeGen.UnLockOutput;
          FInternalRaiseException := OldInternalRaiseException;
        end;

        if not IsDesignator then
        begin
          //Match(tokLB);  优化不用的括号
          Scaner.NextToken;

          FormatSimpleStatement(PreSpaceCount);

          if Scaner.Token = tokRB then
            Scaner.NextToken
          else
            ErrorToken(tokRB);

          //Match(tokRB);
          end
        else
        begin
          FormatDesignatorAndOthers(PreSpaceCount);
        end;
      end;
  else
    Error(CN_ERRCODE_PASCAL_INVALID_STATEMENT);
  end;
end;

procedure TCnBasePascalFormatter.FormatLabel(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokInteger then
    Match(tokInteger, PreSpaceCount)
  else
    Match(tokSymbol, PreSpaceCount);
end;

{ Statement -> [LabelId ':']/.. [SimpleStatement | StructStmt] }
procedure TCnBasePascalFormatter.FormatStatement(PreSpaceCount: Byte);
begin
  while Scaner.ForwardToken() = tokColon do
  begin
    // WriteLineFeedByPrevCondition;  label 前面不刻意留一行，怕 begin 后空行显得难看
    FormatLabel;
    Match(tokColon);

    Writeln;
  end;

  // 允许语句以部分关键字开头，比如变量名等
  if Scaner.Token in SimpStmtTokens + DirectiveTokens + ComplexTokens +
    StmtKeywordTokens + CanBeNewIdentifierTokens then
    FormatSimpleStatement(PreSpaceCount)
  else if Scaner.Token in StructStmtTokens then
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
  OldKeepOneBlankLine := Scaner.KeepOneBlankLine;
  Scaner.KeepOneBlankLine := True;
  try
    // 处理空语句单独分行的问题
    while Scaner.Token = tokSemicolon do
    begin
      Match(tokSemicolon, PreSpaceCount, 0, False, True);
      if not (Scaner.Token in [tokKeywordEnd, tokKeywordUntil, tokKeywordExcept,
        tokKeywordFinally, tokKeywordFinalization]) then // 这些关键字自身会分行，所以无需此处分行
        Writeln;
    end;

    FormatStatement(PreSpaceCount);

    while Scaner.Token = tokSemicolon do
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
      while Scaner.Token = tokSemicolon do
      begin
        Writeln;
        Match(tokSemicolon, PreSpaceCount, 0, False, True);
      end;

      if Scaner.Token in StmtTokens + DirectiveTokens + ComplexTokens
        + [tokInteger] + StmtKeywordTokens then // 部分关键字能做语句开头，Label 可能以数字开头
      begin
        { DONE: 建立语句列表 }
        Writeln;
        FormatStatement(PreSpaceCount);
      end;
    end;
  finally
    Scaner.KeepOneBlankLine := OldKeepOneBlankLine;
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
  case Scaner.Token of
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
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, ['Statement', TokenToString(Scaner.Token)]);
  end;
end;

{
  TryEnd -> FINALLY StmtList END
         -> EXCEPT [ StmtList | (ExceptionHandler/;... [ELSE Statement]) ] [';'] END
}
procedure TCnBasePascalFormatter.FormatTryEnd(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordFinally:
      begin
        Match(Scaner.Token, PreSpaceCount);
        Writeln;
        if Scaner.Token <> tokKeywordEnd then
        begin
          FormatStmtList(Tab(PreSpaceCount, False));
          Writeln;
        end;
        Match(tokKeywordEnd, PreSpaceCount);
      end;

    tokKeywordExcept:
      begin
        Match(Scaner.Token, PreSpaceCount);
        if Scaner.Token <> tokKeywordEnd then // 避免紧跟时多出空行
        begin
          if Scaner.Token <> tokKeywordOn then
          begin
            Writeln;
            FormatStmtList(Tab(PreSpaceCount, False))
          end
          else
          begin
            while Scaner.Token = tokKeywordOn do
            begin
              Writeln;
              FormatExceptionHandler(Tab(PreSpaceCount, False));
            end;

            if Scaner.Token = tokKeywordElse then
            begin
              Writeln;
              Match(tokKeywordElse, Tab(PreSpaceCount), 1);
              Writeln;
              FormatStmtList(Tab(Tab(PreSpaceCount, False), False));
            end;

            if Scaner.Token = tokSemicolon then
              Match(tokSemicolon);
          end;
        end;
        Writeln;

        Match(tokKeywordEnd, PreSpaceCount);
      end;
  else
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, ['except/finally', Scaner.TokenString]);
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
  while Scaner.Token = tokDot do
  begin
    Match(Scaner.Token);
    Match(tokSymbol);
  end;

  if Scaner.Token = tokColon then
  begin
    Match(tokColon);
    Match(tokSymbol);

    // On Exception class name allow dot
    while Scaner.Token = tokDot do
    begin
      Match(Scaner.Token);
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

  OnlySemicolon := Scaner.Token = tokSemicolon;
  FormatStatement(Tab(PreSpaceCount));
  
  if Scaner.Token = tokSemicolon then
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
  if not (Scaner.Token in [tokKeywordExcept, tokKeywordFinally]) then // 避免空行
  begin
    FormatStmtList(Tab(PreSpaceCount, False));
    Writeln;
  end;
  FormatTryEnd(PreSpaceCount);
end;

{ WhileStmt -> WHILE Expression DO Statement }
procedure TCnBasePascalFormatter.FormatWhileStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordWhile, PreSpaceCount);
  FormatExpression(0, PreSpaceCount);

  SpecifyElementType(pfetDo);
  try
    Match(tokKeywordDo);
  finally
    RestoreElementType;
  end;

  CheckWriteBeginln; // 检查 do begin 是否同行

  if Scaner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;
  FormatStatement(Tab(PreSpaceCount));
end;

{ WithStmt -> WITH IdentList DO Statement }
procedure TCnBasePascalFormatter.FormatWithStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordWith, PreSpaceCount);
  // FormatDesignatorList; // Grammer error.

  FormatExpression(0, PreSpaceCount);
  while Scaner.Token = tokComma do
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

  if Scaner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;
  FormatStatement(Tab(PreSpaceCount));
end;

{ RaiseStmt -> RAISE [ Expression | Expression AT Expression ] }
procedure TCnBasePascalFormatter.FormatRaiseStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordRaise, PreSpaceCount);

  if not (Scaner.Token in [tokSemicolon, tokKeywordEnd, tokKeywordElse]) then
    FormatExpression(0, PreSpaceCount);

  if Scaner.Token = tokKeywordAt then
  begin
    SpecifyElementType(pfetRaiseAt);
    try
      Match(Scaner.Token);
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
  OldKeywordStyle: TKeywordStyle;
begin
  Match(tokKeywordAsm, PreSpaceCount);
  Writeln;
  Scaner.ASMMode := True;
  SpecifyElementType(pfetAsm);

  OldKeywordStyle := CnPascalCodeForRule.KeywordStyle;
  CnPascalCodeForRule.KeywordStyle := ksUpperCaseKeyword; // 临时替换

  try
    NewLine := True;
    AfterKeyword := False;
    InstrucLen := 0;
    IsLabel := False;

    while (Scaner.Token <> tokKeywordEnd) or
      ((Scaner.Token = tokKeywordEnd) and (FLastToken = tokAtSign)) do
    begin
      T := Scaner.Token;
      Scaner.SaveBookmark(Bookmark);
      OldLastToken := FLastToken;
      CodeGen.LockOutput;

      if NewLine then // 行首，要检测label
      begin
        LabelLen := 0;
        ALabel := '';
        HasAtSign := False;
        AfterKeyword := False;
        InstrucLen := Length(Scaner.TokenString); // 记住可能是的汇编指令关键字的长度

        while Scaner.Token in [tokAtSign, tokSymbol, tokInteger, tokAsmHex] + KeywordTokens +
          DirectiveTokens + ComplexTokens do
        begin
          if Scaner.Token = tokAtSign then
          begin
            HasAtSign := True;
            ALabel := ALabel + '@';
            Inc(LabelLen);
            Scaner.NextToken;
          end
          else if Scaner.Token in [tokSymbol, tokInteger, tokAsmHex] + KeywordTokens +
            DirectiveTokens + ComplexTokens then // 关键字可以做 label 名
          begin
            ALabel := ALabel + Scaner.TokenString;
            Inc(LabelLen, Length(Scaner.TokenString));

            Scaner.NextToken;
          end;
        end;
        // 跳过了一个可能是 label 的，首以 @ 开头的才是 label
        IsLabel := HasAtSign and (Scaner.Token = tokColon);
        if IsLabel then
        begin
          Inc(LabelLen);
          ALabel := ALabel + ':';
        end;

        // 如果是label，那么ALabel里头已经放入label了，所以不需要LoadBookmark了
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
          Scaner.NextToken; // 跳过 label 的冒号
          InstrucLen := Length(Scaner.TokenString); // 记住应该是的汇编指令关键字的长度
        end
        else // 不是 Label 的话，回到开头
        begin
          Scaner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;
          CodeGen.UnLockOutput;
          
          Match(Scaner.Token, CnPascalCodeForRule.SpaceBeforeASM);
          AfterKeyword := True;
        end;
      end
      else
      begin
        CodeGen.ClearOutputLock;

        if AfterKeyword and not (Scaner.Token in [tokCRLF, tokSemicolon]) then // 第一字后面必须有空格
        begin
          if InstrucLen >= CnPascalCodeForRule.SpaceTabASMKeyword then
            WriteOneSpace
          else
            CodeGen.Write(Space(CnPascalCodeForRule.SpaceTabASMKeyword - InstrucLen));
        end;

        if Scaner.Token <> tokCRLF then
        begin
          if AfterKeyword then // 手工写入ASM关键字后面的内容，不用 Pascal 的空格规则
          begin
            CodeGen.Write(Scaner.TokenString);
            FLastToken := Scaner.Token;
            Scaner.NextToken;
            AfterKeyword := False;
          end
          else if IsLabel then // 如果前一个是 label，则这个是第一个 Keyword
          begin
            CodeGen.Write(Scaner.TokenString);
            FLastToken := Scaner.Token;
            Scaner.NextToken;
            IsLabel := False;
            AfterKeyword := True;
          end
          else
          begin
            if Scaner.Token = tokColon then
              Match(Scaner.Token, 0, 0, True)
            else if Scaner.Token in (AddOPTokens + MulOPTokens) then
              Match(Scaner.Token, 1, 1) // 二元运算符前后各空一格
            else if (FLastToken in CanBeNewIdentifierTokens) and
              (UpperCase(Scaner.TokenString) = 'H') then
              Match(Scaner.Token, 0, 0, False, False, True) // 修补数字开头的十六进制与 H 间的空格，但不完善
            else
              Match(Scaner.Token);
            AfterKeyword := False;
          end;
        end;
      end;

      //if not OnlyKeyword then
      NewLine := False;

      if (T = tokSemicolon) or (Scaner.Token = tokCRLF) or
        ((Scaner.Token = tokKeywordEnd) and (FLastToken <> tokAtSign)) then
      begin
        Writeln;
        NewLine := True;
        while Scaner.Token in [tokBlank, tokCRLF] do
          Scaner.NextToken;
      end;
    end;
  finally
    Scaner.ASMMode := False;
    RestoreElementType;
    if Scaner.Token in [tokBlank, tokCRLF] then
      Scaner.NextToken;
    CnPascalCodeForRule.KeywordStyle := OldKeywordStyle; // 恢复 KeywordStyle
    Match(tokKeywordEnd, PreSpaceCount);
  end;
end;

{ TCnTypeSectionFormater }

{ ArrayConstant -> '(' TypedConstant/','... ')' }
procedure TCnBasePascalFormatter.FormatArrayConstant(PreSpaceCount: Byte);
begin
  Match(tokLB);

  SpecifyElementType(pfetArrayConstant);
  try
    FormatTypedConstant(PreSpaceCount);

  //  if Scaner.Token = tokLB then // 数组的括号可能嵌套
  //    FormatArrayConstant(PreSpaceCount)
  //  else

    while Scaner.Token = tokComma do
    begin
      Match(Scaner.Token);
      FormatTypedConstant(PreSpaceCount);
  //    if Scaner.Token = tokLB then // 数组的括号可能嵌套
  //      FormatArrayConstant(PreSpaceCount)
  //    else
    end;

    Match(tokRB);
  finally
    RestoreElementType;
  end;
end;

{ ArrayType -> ARRAY ['[' OrdinalType/','... ']'] OF Type }
procedure TCnBasePascalFormatter.FormatArrayType(PreSpaceCount: Byte);
begin
  Match(tokKeywordArray);

  if Scaner.Token = tokSLB then
  begin
    Match(tokSLB);
    FormatOrdinalType;

    while Scaner.Token = tokComma do
    begin
      Match(Scaner.Token);
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

  while (Scaner.Token in ClassVisibilityTokens) or (Scaner.Token = tokSymbol) do
  begin
    if Scaner.Token in ClassVisibilityTokens then
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

  while Scaner.Token = tokSemicolon do
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
  if Scaner.Token = tokSemicolon then
    Match(tokSemicolon);

  { TODO: Need Scaner forward look future }
  while (Scaner.Token in ClassVisibilityTokens) or (Scaner.Token = tokKeywordProperty) do
  begin
    if Scaner.Token in ClassVisibilityTokens then
      FormatClassVisibility(PreSpaceCount);
    Writeln;
    FormatPropertyList(PreSpaceCount);
    if Scaner.Token = tokSemicolon then
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
  while Scaner.Token = tokDot do
  begin
    Match(Scaner.Token);
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
  if Scaner.Token = tokSemiColon then // class declare forward, like TFoo = class;
    Exit;

  if Scaner.Token = tokKeywordOF then  // like TFoo = class of TBar;
  begin
    Match(tokKeywordOF);
    FormatIdent;
    Exit;
  end
  else if (Scaner.Token = tokSymbol) and (Scaner.ForwardToken = tokKeywordFor)
    and (LowerCase(Scaner.TokenString) = 'helper') then
  begin
    // class helper for Ident
    Match(Scaner.Token);
    Match(tokKeywordFor);
    FormatIdent(0);
  end;

  if Scaner.Token in [tokKeywordSealed, tokDirectiveABSTRACT] then // TFoo = class sealed
    Match(Scaner.Token);

  FormatClassBody(PreSpaceCount);

{
  while Scaner.Token <> tokKeywordEnd do
  begin
    // skip ClassVisibilityTokens ( private public ... )
    Scaner.SaveBookmark;
    while (Scaner.Token in ClassVisibilityTokens + [tokKeywordEnd, tokEOF]) do
    begin
      Scaner.NextToken;
    end;
    Token := Scaner.Token;
    Scaner.LoadBookmark;

    if Token = tokKeywordProperty then
      FormatClassPropertyList(Tab(PreSpaceCount))
    else if Token in MethodListTokens then
      FormatMethodList(Tab(PreSpaceCount))
    else
      FormatClassFieldList(Tab(PreSpaceCount));
  end;

  Match(tokKeywordEnd);
}
end;

{ ClassVisibility -> [PUBLIC | PROTECTED | PRIVATE | PUBLISHED] }
procedure TCnBasePascalFormatter.FormatClassVisibility(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokKeywordStrict then
  begin
    Match(Scaner.Token, PreSpaceCount);
    if Scaner.Token in ClassVisibilityTokens then
    begin
      Match(Scaner.Token);
      Writeln;
    end;
  end
  else if Scaner.Token in ClassVisibilityTokens then
  begin
    Match(Scaner.Token, PreSpaceCount);
    Writeln;
  end;
end;

{ ConstructorHeading -> CONSTRUCTOR Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatConstructorHeading(PreSpaceCount: Byte);
begin
  Match(tokKeywordConstructor, PreSpaceCount);
  FormatMethodName;

  if Scaner.Token = tokLB then
    FormatFormalParameters;
end;

{ ContainsClause -> CONTAINS IdentList... ';' }
procedure TCnBasePascalFormatter.FormatContainsClause(PreSpaceCount: Byte);
begin
  if Scaner.TokenSymbolIs('CONTAINS') then
  begin
    Match(Scaner.Token, 0, 1);
    FormatIdentList;
    Match(tokSemicolon);
  end;
end;

{ DestructorHeading -> DESTRUCTOR Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatDestructorHeading(PreSpaceCount: Byte);
begin
  Match(tokKeywordDestructor, PreSpaceCount);
  FormatMethodName;

  if Scaner.Token = tokLB then
    FormatFormalParameters;
end;

{ OperatorHeading -> OPERATOR Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatOperatorHeading(PreSpaceCount: Byte);
begin
  Match(tokKeywordOperator, PreSpaceCount);
  FormatMethodName;

  if Scaner.Token = tokLB then
    FormatFormalParameters;
end;

{ VarDecl -> IdentList ':' Type [(ABSOLUTE (Ident | ConstExpr)) | '=' TypedConstant] }
procedure TCnBasePascalFormatter.FormatVarDeclHeading(PreSpaceCount: Byte;
  IsClassVar: Boolean);
begin
  if Scaner.Token in [tokKeywordVar, tokKeywordThreadVar] then
  begin
    if IsClassVar then
      Match(Scaner.Token)
    else
      Match(Scaner.Token, BackTab(PreSpaceCount));
  end;
  
  repeat
    Writeln;
    
    FormatClassVarIdentList(PreSpaceCount);
    if Scaner.Token = tokColon then // 放宽语法限制
    begin
      Match(tokColon);
      FormatType(PreSpaceCount); // 长 Type 可能换行，必须传入
    end;

    if Scaner.Token = tokEQUAL then
    begin
      Match(Scaner.Token, 1, 1);
      FormatTypedConstant;
    end
    else if Scaner.TokenSymbolIs('ABSOLUTE') then
    begin
      Match(Scaner.Token);
      FormatConstExpr; // include indent
    end;

    while Scaner.Token in DirectiveTokens do
      FormatDirective;

    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon);
  until Scaner.Token in ClassMethodTokens + ClassVisibilityTokens + [tokKeywordEnd,
    tokEOF, tokKeywordCase];
    // 出现这些，认为 class var 区结束，包括 record 可能出现的 case
end;

{ IdentList -> [Attribute] Ident/','... }
procedure TCnBasePascalFormatter.FormatClassVarIdentList(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  FormatClassVarIdent(PreSpaceCount, CanHaveUnitQual);

  while Scaner.Token = tokComma do
  begin
    Match(tokComma);
    FormatClassVarIdent(0, CanHaveUnitQual);
  end;
end;

procedure TCnBasePascalFormatter.FormatClassVarIdent(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  while Scaner.Token = tokSLB do // Attribute
  begin
    FormatSingleAttribute(PreSpaceCount);
    Writeln;
  end;
  if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
    Match(Scaner.Token, PreSpaceCount); // 标识符中允许使用部分关键字

  while CanHaveUnitQual and (Scaner.Token = tokDot) do
  begin
    Match(tokDot);
    if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scaner.Token); // 也继续允许使用部分关键字
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
    if Scaner.Token in DirectiveTokens + ComplexTokens then
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
      if Scaner.Token in [   // 这些是后面可以加参数的
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
        WriteToken(Scaner.Token, 0, 0, False, False, True);
        Scaner.NextToken;

        if not (Scaner.Token in DirectiveTokens) then // 加个后续的表达式
        begin
          if Scaner.Token in [tokString, tokWString, tokLB, tokPlus, tokMinus] then
            WriteOneSpace; // 后续表达式空格分隔
          FormatConstExpr;
        end;
        //  Match(Scaner.Token);
      end
      else
      begin
        if not IgnoreFirst then
          WriteOneSpace; // 非第一个 Directive，和之前的内容空格分隔
        WriteToken(Scaner.Token, 0, 0, False, False, True);
        Scaner.NextToken;
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
  Match(tokLB, PreSpaceCount);
  FormatEnumeratedList;
  Match(tokRB);
end;

{ EnumeratedList -> EmumeratedIdent/','... }
procedure TCnBasePascalFormatter.FormatEnumeratedList(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetEnumList);
  try
    FormatEmumeratedIdent(PreSpaceCount);
    while Scaner.Token = tokComma do
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
  if Scaner.Token = tokEQUAL then
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
procedure TCnBasePascalFormatter.FormatFieldList(PreSpaceCount: Byte;
  IgnoreFirst: Boolean);
var
  First, AfterIsRB: Boolean;
begin
  First := True;
  while not (Scaner.Token in [tokKeywordEnd, tokKeywordCase, tokRB]) do
  begin
    if Scaner.Token in ClassVisibilityTokens then
      FormatClassVisibility(BackTab(PreSpaceCount));

    if Scaner.Token in [tokKeywordProcedure, tokKeywordFunction,
      tokKeywordConstructor, tokKeywordDestructor, tokKeywordClass] then
    begin
      FormatClassMethod(PreSpaceCount);
      Writeln;
      First := False;
    end
    else if Scaner.Token = tokKeywordProperty then
    begin
      FormatClassProperty(PreSpaceCount);
      Writeln;
      First := False;
    end
    else if Scaner.Token = tokKeywordType then
    begin
      FormatClassTypeSection(PreSpaceCount);
      Writeln;
      First := False;
    end
    else if Scaner.Token in [tokKeywordVar, tokKeywordThreadVar] then
    begin
      FormatVarSection(PreSpaceCount);
      Writeln;
      First := False;
    end
    else if Scaner.Token = tokKeywordConst then
    begin
      FormatClassConstSection(PreSpaceCount);
      Writeln;
      First := False;
    end
    else if Scaner.Token <> tokKeywordEnd then
    begin
      if First and IgnoreFirst then
        FormatFieldDecl
      else
        FormatFieldDecl(PreSpaceCount);
      First := False;

      if Scaner.Token = tokSemicolon then
      begin
        AfterIsRB := Scaner.ForwardToken in [tokRB];
        if not AfterIsRB then // 后面还有才写分号和换行
        begin
          Match(Scaner.Token);
          Writeln;
        end
        else
          Scaner.NextToken;
      end
      else if Scaner.Token = tokKeywordEnd then // 最后一项无分号时也可以
      begin
        Writeln;
        Break;
      end;
    end;
  end;

  if First and not (Scaner.Token = tokKeywordCase) then // 没有声明则先换行，case 除外
    Writeln;

  if Scaner.Token = tokKeywordCase then
  begin
    FormatVariantSection(PreSpaceCount);
    Writeln;
  end;

  if Scaner.Token = tokSemicolon then
    Match(Scaner.Token);
end;

{ FileType -> FILE [OF TypeId] }
procedure TCnBasePascalFormatter.FormatFileType(PreSpaceCount: Byte);
begin
  Match(tokKeywordFile);
  if Scaner.Token = tokKeywordOf then // 可以是单独的 file
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
    if Scaner.Token <> tokRB then
      FormatFormalParm;

    while Scaner.Token = tokSemicolon do
    begin
      Match(Scaner.Token);
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

{ FormalParm -> [Ref] [VAR | CONST | OUT] [Ref] Parameter }
procedure TCnBasePascalFormatter.FormatFormalParm(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokSLB then
  begin
    Match(tokSLB);
    if Scaner.Token in KeywordTokens + [tokSymbol] then
      Match(Scaner.Token);
    Match(tokSRB, 0, 1); // ] 后有个空格
  end;

  if (Scaner.Token in [tokKeywordVar, tokKeywordConst, tokKeywordOut]) and
     not (Scaner.ForwardToken in [tokColon, tokComma])
  then
  begin
    Match(Scaner.Token);

    if Scaner.Token = tokSLB then
    begin
      Match(tokSLB, 1, 0); // [ 前有个空格
      if Scaner.Token in KeywordTokens + [tokSymbol] then
        Match(Scaner.Token);
      Match(tokSRB, 0, 1); // ] 后有个空格
    end;
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
procedure TCnBasePascalFormatter.FormatFunctionHeading(PreSpaceCount: Byte;
  AllowEqual: Boolean);
begin
  if Scaner.Token = tokKeywordClass then
  begin
    Match(tokKeywordClass, PreSpaceCount); // class 后无需再手工加空格
    if Scaner.Token in [tokKeywordFunction, tokKeywordOperator] then
      Match(Scaner.Token);
  end
  else
  begin
    if Scaner.Token in [tokKeywordFunction, tokKeywordOperator] then
      Match(Scaner.Token, PreSpaceCount);
  end;
  
  {!! Fixed. e.g. "const proc: procedure = nil;" }
  if Scaner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens
    + KeywordTokens then // 函数名允许出现关键字
  begin
    // 处理 of，虽然无 function of object 的语法
    if (Scaner.Token <> tokKeywordOf) or (Scaner.ForwardToken = tokLB) then
      FormatMethodName;
  end;

  if Scaner.Token = tokSemicolon then // 处理 Forward 的函数的真正声明可省略参数的情形
    Exit;

  if AllowEqual and (Scaner.Token = tokEQUAL) then  // procedure Intf.Ident = Ident
  begin
    Match(tokEQUAL, 1, 1);
    FormatIdent;
    Exit;
  end;

  if Scaner.Token = tokLB then
    FormatFormalParameters;

  Match(tokColon);

  if Scaner.Token = tokKeywordString then
    Match(Scaner.Token)
  else
    FormatSimpleType;
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
  if Scaner.Token = tokKeywordInterface then
  begin
    Match(tokKeywordInterface);

    if Scaner.Token = tokSemicolon then // 有 ITest = interface; 的情况
      Exit;

    if Scaner.Token = tokLB then
      FormatInterfaceHeritage;
  end
  else if Scaner.Token = tokKeywordDispinterface then // 处理 dispinterface 的情况
  begin
    Match(tokKeywordDispinterface);
    if Scaner.Token = tokSemicolon then // 有 ITest = dispinterface; 的情况
      Exit;
  end;

  if Scaner.Token = tokSLB then // 有 GUID
     FormatGuid(PreSpaceCount);

  if Scaner.Token in ClassVisibilityTokens then
    FormatClassVisibility;
  // 放宽规则，允许出现 public 等内容

  // 循环放内部，因此内部需要 Writeln，这点和 Class 的 Property 处理不一样
  while Scaner.Token in [tokKeywordProperty] + ClassMethodTokens + [tokSLB] do
  begin
    if Scaner.Token = tokSLB then // interface 声明支持属性
    begin
      Writeln;
      FormatSingleAttribute(Tab(PreSpaceCount));
    end
    else if Scaner.Token = tokKeywordProperty then
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
  case Scaner.Token of
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
  while Scaner.Token in DirectiveTokens do
  begin
    FormatDirective(PreSpaceCount, IsFirst);
    IsFirst := False;
    if Scaner.Token = tokSemicolon then
     Match(tokSemicolon, 0, 0, True);
  end;

  while (Scaner.Token in ClassVisibilityTokens) or
        (Scaner.Token in ClassMethodTokens) do
  begin
    Writeln;

    if Scaner.Token in ClassVisibilityTokens then
      FormatClassVisibility(PreSpaceCount);

    FormatMethodHeading(PreSpaceCount);
    Match(tokSemicolon);

    IsFirst := True;
    while Scaner.Token in DirectiveTokens do
    begin
      FormatDirective(PreSpaceCount, IsFirst);
      IsFirst := False;
      if Scaner.Token = tokSemicolon then
        Match(tokSemicolon, 0, 0, True);
    end;
  end;
end;

{ ObjectType -> OBJECT [ObjHeritage] [ObjFieldList] [MethodList] END }
procedure TCnBasePascalFormatter.FormatObjectType(PreSpaceCount: Byte);
begin
  Match(tokKeywordObject);
  if Scaner.Token = tokSemicolon then
    Exit;

  if Scaner.Token = tokLB then
  begin
    FormatObjHeritage // ObjHeritage -> '(' QualId ')'
  end;

  Writeln;

  // 用 class 的处理方式应该兼容
  while Scaner.Token in ClassVisibilityTokens + ClassMemberSymbolTokens
    - [tokKeywordPublished, tokKeywordConstructor, tokKeywordDestructor] do
  begin
    if Scaner.Token in ClassVisibilityTokens - [tokKeywordPublished] then
      FormatClassVisibility(PreSpaceCount);

    if Scaner.Token in ClassMemberSymbolTokens
      - [tokKeywordConstructor, tokKeywordDestructor] then
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

  while Scaner.Token = tokSemicolon do
  begin
    Match(Scaner.Token);

    if Scaner.Token <> tokSymbol then Exit;

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
      Scaner.NextToken;
    until not (Scaner.Token in [tokSymbol, tokDot, tokInteger, tokLB, tokRB,
      tokPlus, tokMinus, tokStar, tokDiv, tokKeywordDiv, tokKeywordMod]);
    // 包括 () 是因为可能有类似于 Low(Integer)..High(Integer) 的情况
    // 还得包括四则运算符等，以备有其他常量运算的情形
  end;

  procedure MatchTokenWithDot;
  begin
    while Scaner.Token in [tokSymbol, tokDot] do
      Match(Scaner.Token);
  end;

begin
  if Scaner.Token = tokLB then  // EnumeratedType
  begin
    if FromSetOf then // 如果前面是 set of 括号前需要空一格
      FormatEnumeratedType(1)
    else
      FormatEnumeratedType(PreSpaceCount);
  end
  else
  begin
    Scaner.SaveBookmark(Bookmark);
    CodeGen.LockOutput;

    if Scaner.Token = tokMinus then // 考虑到负号的情况
      Scaner.NextToken;

    NextTokenWithDot;
    
    if Scaner.Token = tokRange then
    begin
      Scaner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      // SubrangeType
      FormatSubrangeType(PreSpaceCount);
    end
    else
    begin
      Scaner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      // OrdIdent
      if Scaner.Token = tokMinus then
        Match(Scaner.Token);

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
begin
  if Scaner.Token = tokKeywordConst then
    Match(Scaner.Token);
  
  if Scaner.ForwardToken = tokComma then //IdentList
  begin
    FormatIdentList(PreSpaceCount);
    
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
  end
  else // Ident
  begin
    FormatIdent(PreSpaceCount);

    if Scaner.Token = tokColon then
    begin
      Match(tokColon);

      if Scaner.Token = tokKeywordArray then
      begin
        //CanHaveDefaultValue := False;
        Match(Scaner.Token);
        Match(tokKeywordOf);
      end;

      if Scaner.Token in [tokKeywordString, tokKeywordFile, tokKeywordConst] then
        Match(Scaner.Token)
      else
        FormatSimpleType;

      if Scaner.Token = tokEQUAL then
      begin
        //if not CanHaveDefaultValue then
        //  Error('Can not have default value');

        Match(tokEQUAL, 1, 1);
        FormatConstExpr;
      end;
    end
    else if Scaner.Token = tokAssign then // 匹配 OLE 调用的情形
    begin
      Match(tokAssign);
      FormatExpression;
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
  Match(tokHat);
  FormatTypeID;
end;

{ ProcedureHeading -> [CLASS] PROCEDURE Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatProcedureHeading(PreSpaceCount: Byte;
  AllowEqual: Boolean);
begin
  if Scaner.Token = tokKeywordClass then
  begin
    Match(tokKeywordClass, PreSpaceCount); // class 后无需再手工加空格
    Match(Scaner.Token);
  end
  else
    Match(Scaner.Token, PreSpaceCount);

  { !! Fixed. e.g. "const proc: procedure = nil;" }
  if Scaner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens
    + KeywordTokens - [tokKeywordBegin, tokKeywordVar, tokKeywordConst, tokKeywordType] then
  begin // 函数名允许出现关键字，但匿名函数无参而碰见 begin/var/const/type 等除外
    // 处理 of
    if (Scaner.Token <> tokKeywordOf) or (Scaner.ForwardToken = tokLB) then
      FormatMethodName;
  end;

  if Scaner.Token = tokLB then
    FormatFormalParameters;

  if AllowEqual and (Scaner.Token = tokEQUAL) then  // procedure Intf.Ident = Ident
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
  case Scaner.Token of
    tokKeywordProcedure:
      begin
        FormatProcedureHeading(PreSpaceCount, False); // Proc 的 Type 允许出现等号
        if Scaner.Token = tokKeywordOf then
        begin
          Match(tokKeywordOf); // 如果是 procedure，前面没空格要插个空格
          Match(tokKeywordObject);
        end;
      end;
    tokKeywordFunction:
      begin
        FormatFunctionHeading(PreSpaceCount, False);
        if Scaner.Token = tokKeywordOf then
        begin
          Match(tokKeywordOf); // 如果是 function，前面已经有空格了就不用空格了
          Match(tokKeywordObject);
        end;
      end;
  end;

  // deal with the Directive after OF OBJECT
  // if Scaner.Token in DirectiveTokens then WriteOneSpace;

  IsSemicolon := False;
  if (Scaner.Token = tokSemicolon) and (Scaner.ForwardToken in DirectiveTokens) then
  begin
    Match(tokSemicolon);
    IsSemicolon := True;
  end;  // 处理 stdcall 之前的分号

  while Scaner.Token in DirectiveTokens do
  begin
    FormatDirective(0, IsSemicolon);

    if (Scaner.Token = tokSemicolon) and
      (Scaner.ForwardToken() in DirectiveTokens) then
      Match(tokSemicolon);

    // leave one semicolon for procedure type define at last.
  end;
end;

{ PropertyInterface -> [PropertyParameterList] ':' Ident }
procedure TCnBasePascalFormatter.FormatPropertyInterface(PreSpaceCount: Byte);
begin
  if Scaner.Token <> tokColon then
    FormatPropertyParameterList;

  Match(tokColon);

  FormatType(PreSpaceCount, True);
end;

{ PropertyList -> PROPERTY  Ident [PropertyInterface]  PropertySpecifiers }
procedure TCnBasePascalFormatter.FormatPropertyList(PreSpaceCount: Byte);
begin
  Match(tokKeywordProperty, PreSpaceCount);
  FormatIdent;

  if Scaner.Token in [tokSLB, tokColon] then
    FormatPropertyInterface;

  FormatPropertySpecifiers;

  if Scaner.Token = tokSemicolon then
    Match(tokSemicolon);
  
  if Scaner.TokenSymbolIs('DEFAULT') then
  begin
    Match(Scaner.Token);
    Match(tokSemicolon);
  end;
end;

{ PropertyParameterList -> '[' (IdentList ':' TypeId)/';'... ']' }
procedure TCnBasePascalFormatter.FormatPropertyParameterList(PreSpaceCount: Byte);
begin
  Match(tokSLB);

  if Scaner.Token in [tokKeywordVar, tokKeywordConst, tokKeywordOut] then
    Match(Scaner.Token);
  FormatIdentList;
  Match(tokColon);
  FormatTypeID;

  while Scaner.Token = tokSemicolon do
  begin
    Match(tokSemicolon);
    if Scaner.Token in [tokKeywordVar, tokKeywordConst, tokKeywordOut] then
      Match(Scaner.Token);
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
    if Scaner.Token in [tokString, tokWString, tokLB, tokPlus, tokMinus] then
      WriteOneSpace; // 后续表达式空格分隔
  end;

begin
  try
    SpecifyElementType(pfetPropertySpecifier);
    while Scaner.Token in PropertySpecifiersTokens do
    begin
      case Scaner.Token of
        tokComplexIndex:
        begin
          try
            SpecifyElementType(pfetPropertyIndex);
            Match(Scaner.Token);
          finally
            RestoreElementType;
          end;
          ProcessBlank;
          FormatConstExpr;
        end;

        tokComplexRead:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatDesignator(0);
          //FormatIdent(0, True);
        end;

        tokComplexWrite:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatDesignator(0);
          //FormatIdent(0, True);
        end;

        tokComplexStored:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatConstExpr; // Constrant is an Expression
        end;

        tokComplexImplements:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatTypeID;
        end;

        tokComplexDefault:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatConstExpr;
        end;

        tokDirectiveDispID:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatExpression;
        end;

        tokComplexNodefault, tokComplexReadonly, tokComplexWriteonly:
          Match(Scaner.Token);
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

  Writeln;
  FormatRecordFieldConstant(Tab(PreSpaceCount));
  if Scaner.Token = tokSemicolon then Match(Scaner.Token);

  while Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens) do // 标识符允许此等名字
  begin
    Writeln;
    FormatRecordFieldConstant(Tab(PreSpaceCount));
    if Scaner.Token = tokSemicolon then Match(Scaner.Token);
  end;

  Writeln;
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
  if (Scaner.Token = tokSymbol) and (Scaner.ForwardToken = tokKeywordFor)
    and (LowerCase(Scaner.TokenString) = 'helper') then
  begin
    Match(Scaner.Token);
    Match(tokKeywordFor);
    FormatIdent(0);
  end;
  Writeln;

  if Scaner.Token <> tokKeywordEnd then
    FormatFieldList(Tab(PreSpaceCount));

//  FormatClassMemberList(PreSpaceCount); Classmember do not know 'case'

  Match(tokKeywordEnd, PreSpaceCount);
  if Scaner.Token = tokKeywordAlign then  // 支持 record end align 16 这种新语法
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
begin
  FormatConstExpr(PreSpaceCount);

  while Scaner.Token = tokComma do
  begin
    Match(Scaner.Token);
    FormatConstExpr;
  end;

  Match(tokColon); // case 后换行写分类标志，分类标志后换行缩进写()
  Writeln;
  Match(tokLB, Tab(PreSpaceCount));
  if Scaner.Token <> tokRB then
    FormatFieldList(Tab(PreSpaceCount), IgnoreFirst);

  // 如果嵌套了记录，此括号必须缩进。没好办法，姑且判断上一个是不是分号和左括号
  if FLastToken in [tokSemicolon, tokLB, tokBlank] then
    Match(tokRB, PreSpaceCount)
  else
    Match(tokRB);
end;

{ RequiresClause -> REQUIRES IdentList... ';' }
procedure TCnBasePascalFormatter.FormatRequiresClause(PreSpaceCount: Byte);
begin
  if Scaner.TokenSymbolIs('REQUIRES') then
  begin
    Match(Scaner.Token, 0, 1);
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
  case Scaner.Token of
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
procedure TCnBasePascalFormatter.FormatSimpleType(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokLB then
    FormatSubrangeType
  else
  begin
    FormatConstExprInType;
    if Scaner.Token = tokRange then
    begin
      Match(tokRange);
      FormatConstExprInType;
    end;
  end;

  // 加入对<>泛型的支持
  if Scaner.Token = tokLess then
  begin
    FormatTypeParams;
  end;
end;

{
  StringType -> STRING
             -> ANSISTRING
             -> WIDESTRING
             -> STRING '[' ConstExpr ']'
}
procedure TCnBasePascalFormatter.FormatStringType(PreSpaceCount: Byte);
begin
  Match(Scaner.Token);
  if Scaner.Token = tokSLB then
  begin
    Match(Scaner.Token);
    FormatConstExpr;
    Match(tokSRB);
  end
  else if Scaner.Token = tokLB then   // 处理 _UTF8String = type AnsiString(65001); 这种
  begin
    Match(tokLB);
    FormatExpression;
    Match(tokRB);
  end;
end;

{ StrucType -> [PACKED] (ArrayType | SetType | FileType | RecType) }
procedure TCnBasePascalFormatter.FormatStructType(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokkeywordPacked then
    Match(Scaner.Token);

  case Scaner.Token of
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
  if (Scaner.Token = tokSymbol) and (Scaner.ForwardToken = tokKeywordTo) and
    (LowerCase(Scaner.TokenString) = 'reference') then
  begin
    // Anonymous Declaration
    Match(Scaner.Token);
    Match(tokKeywordTo);
  end;

  case Scaner.Token of // 此三类无需换行，因此无需传入 PreSpaceCount
    tokKeywordProcedure, tokKeywordFunction: FormatProcedureType();
    tokHat: FormatPointerType();
    tokKeywordClass: FormatClassRefType();
  else
    // StructType
    if Scaner.Token in StructTypeTokens then
    begin
      FormatStructType(PreSpaceCount);
    end
    else
    // StringType
    if (Scaner.Token = tokKeywordString) or
      Scaner.TokenSymbolIs('String')  or
      Scaner.TokenSymbolIs('AnsiString') or
      Scaner.TokenSymbolIs('WideString') then
    begin
      FormatStringType; // 无需换行
    end
    else // EnumeratedType
    if Scaner.Token = tokLB then
    begin
      FormatEnumeratedType; // 无需换行
    end
    else
    begin
      //TypeID, SimpleType, VariantType
      { SubrangeType -> ConstExpr '..' ConstExpr }
      { TypeId -> [UnitId '.'] <type-identifier> }

      Scaner.SaveBookmark(Bookmark);
      OldLastToken := FLastToken;

      // 先测一下，跳过一个表达式，看看后面的是什么
      CodeGen.LockOutput;
      try
        FormatConstExprInType;
      finally
        CodeGen.UnLockOutput;
      end;

      // LoadBookmark 后，必须把当时的 FLastToken 也恢复过来，否则会影响空格的输出
      AToken := Scaner.Token;
      Scaner.LoadBookmark(Bookmark);
      FLastToken := OldLastToken;

      { TypeId }
      if AToken = tokDot then
      begin
        FormatConstExpr;
        Match(Scaner.Token);
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
        if Scaner.Token = tokDot then
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

  // 加入对<>泛型的支持
  if Scaner.Token = tokLess then
  begin
    FormatTypeParams;
    if Scaner.Token = tokDot then
    begin
      Match(tokDot);
      FormatIdent;
    end;
  end;

  if not IgnoreDirective then
    while Scaner.Token in DirectiveTokens do
      FormatDirective;
end;

{ TypedConstant -> (ConstExpr | SetConstructor | ArrayConstant | RecordConstant) }
procedure TCnBasePascalFormatter.FormatTypedConstant(PreSpaceCount: Byte);
type
  TCnTypedConstantType = (tcConst, tcArray, tcRecord);
var
  TypedConstantType: TCnTypedConstantType;
  Bookmark: TScannerBookmark;
  OldLastToken: TPascalToken;
begin
  // DONE: 碰到括号就该判断一下，后面的大类是 symbol: 还是常量，
  // 然后分别调用FormatArrayConstant和FormatRecordConstant
  TypedConstantType := tcConst;
  case Scaner.Token of
    // tokKeywordArray: FormatArrayConstant(PreSpaceCount); // 没这种语法
    tokSLB:
      begin
        FormatSetConstructor;
        while Scaner.Token in (AddOPTokens + MulOpTokens) do // Set 之间的运算
        begin
          MatchOperator(Scaner.Token);
          FormatSetConstructor;
        end;
      end;  
    tokLB:
      begin // 是括号的，表示是组合的Type
        if Scaner.ForwardToken = tokLB then // 如果后面还是括号，则说明本大类是常量或array
        begin
          Scaner.SaveBookmark(Bookmark);
          OldLastToken := FLastToken;
          try
            try
              CodeGen.LockOutput;
              FormatConstExpr;

              if Scaner.Token = tokComma then // ((1, 1) 的情形
                TypedConstantType := tcArray
              else if Scaner.Token = tokSemicolon then // ((1) 的情形
                TypedConstantType := tcConst;
            except
              // 当做常量出错则是数组
              TypedConstantType := tcArray;
            end;
          finally
            CodeGen.UnLockOutput;
          end;

          Scaner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;

          if TypedConstantType = tcArray then
            FormatArrayConstant(PreSpaceCount)
          else if Scaner.Token in ConstTokens
            + [tokAtSign, tokPlus, tokMinus, tokLB, tokRB] then // 有可能初始化的值以这些开头
            FormatConstExpr(PreSpaceCount)
        end
        else // 如果只是本括号，则拿后续的判断是否 a: 0 这样的形式来设置 TypedConstantType
        begin
          Scaner.SaveBookmark(Bookmark);
          OldLastToken := FLastToken;

          if (Scaner.ForwardToken in ([tokSymbol] + KeywordTokens + ComplexTokens))
            and (Scaner.ForwardToken(2) = tokColon) then
          begin
            // 括号后有常量后有冒号表示是 recordfield
            TypedConstantType := tcRecord;
          end
          else // 匹配一下 ( ConstExpr)  然后看后续是否是;结束，来判断是否是数组
          begin
            try
              try
                CodeGen.LockOutput;
                Match(tokLB);
                FormatConstExpr;

                if Scaner.Token = tokComma then // (1, 1) 的情形
                  TypedConstantType := tcArray;
                if Scaner.Token = tokRB then
                  Match(tokRB);

                if Scaner.Token = tokSemicolon then // (1) 的情形
                  TypedConstantType := tcArray;
              except
                ;
              end;
            finally
              CodeGen.UnLockOutput;
            end;
          end;

          Scaner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;

          if TypedConstantType = tcArray then
            FormatArrayConstant(PreSpaceCount)
          else if TypedConstantType = tcRecord then
            FormatRecordConstant(PreSpaceCount + CnPascalCodeForRule.TabSpaceCount)
          else if Scaner.Token in ConstTokens
            + [tokAtSign, tokPlus, tokMinus, tokLB, tokRB] then // 有可能初始化的值以这些开头
            FormatConstExpr(PreSpaceCount)
        end;
      end;
  else // 不是括号开头，说明是简单的常量，直接处理
    if Scaner.Token in ConstTokens + [tokAtSign, tokPlus, tokMinus, tokHat] then // 有可能初始化的值以这些开头
      FormatConstExpr(PreSpaceCount)
    else if Scaner.Token <> tokRB then
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
begin
  while Scaner.Token = tokSLB do
  begin
    FormatSingleAttribute(PreSpaceCount);
    Writeln;
  end;

  Old := FIsTypeID;
  try
    FIsTypeID := True;
    FormatIdent(PreSpaceCount);
  finally
    FIsTypeID := Old;
  end;

  // 加入对<>泛型的支持
  GreatEqual := False;
  if Scaner.Token = tokLess then
  begin
    GreatEqual := FormatTypeParams(0, True);
  end;

  if not GreatEqual then
    MatchOperator(tokEQUAL);

  if Scaner.Token = tokKeywordType then // 处理 TInt = type Integer; 的情形
    Match(tokKeywordType);

  if Scaner.Token in RestrictedTypeTokens then
    FormatRestrictedType(PreSpaceCount)
  else
    FormatType(PreSpaceCount);
end;

{ TypeSection -> TYPE (TypeDecl ';')... }
procedure TCnBasePascalFormatter.FormatTypeSection(PreSpaceCount: Byte);
const
  IsTypeStartTokens = [tokSymbol, tokSLB] + ComplexTokens + DirectiveTokens
    + KeywordTokens - NOTExpressionTokens;
var
  FirstType: Boolean;
begin
  Match(tokKeywordType, PreSpaceCount);
  Writeln;

  FirstType := True;
  while Scaner.Token in IsTypeStartTokens do // Attribute will use [
  begin
    // 如果是[，就要越过其属性，找到]后的第一个，确定它是否还是 type，如果不是，就跳出
    if (Scaner.Token = tokSLB) and not IsTokenAfterAttributesInSet(IsTypeStartTokens) then
      Exit;

    if not FirstType then WriteLine;

    FormatTypeDecl(Tab(PreSpaceCount));
    while Scaner.Token in DirectiveTokens do
      FormatDirective;
    Match(tokSemicolon);
    FirstType := False;
  end;
end;

{ VariantSection -> CASE [Ident ':'] TypeId OF RecVariant/';'... }
procedure TCnBasePascalFormatter.FormatVariantSection(PreSpaceCount: Byte);
begin
  Match(tokKeywordCase, PreSpaceCount);
  if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens) then // case 后允许此等名字
    Match(Scaner.Token);

  // Ident
  if Scaner.Token = tokColon then
  begin
    Match(tokColon);
    FormatTypeID;
  end
  else
  // TypeID 中有 Dot，前面的为 UnitId，这个为 TypeId
  while Scaner.Token = tokDot do
  begin
    Match(tokDot);
    FormatTypeID;
  end;

  Match(tokKeywordOf);
  Writeln;
  FormatRecVariant(Tab(PreSpaceCount), True);

  while Scaner.Token = tokSemicolon do
  begin
    Match(Scaner.Token);
    if not (Scaner.Token in [tokKeywordEnd, tokRB]) then // end 或 ) 表示就要退出了
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
  while Scaner.Token in DeclSectionTokens do
  begin
    FormatDeclSection(PreSpaceCount, True, IsInternal);
    Writeln;
  end;

  if MultiCompound and not (FGoalType in [gtProgram, gtLibrary]) then
  begin
    while Scaner.Token in BlockStmtTokens do
    begin
      FormatCompoundStmt(PreSpaceCount);
      if Scaner.Token = tokSemicolon then
      begin
        Match(Scaner.Token);
        if Scaner.Token in BlockStmtTokens then // 后面还有则换行
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
  while Scaner.Token in DeclSectionTokens do
  begin
    FormatDeclSection(PreSpaceCount, False, IsInternal);
    Writeln;
    HasDeclSection := True;
  end;

  if HasDeclSection then // 有声明才多换行，避免多出连续空行
    Writeln;

  if IsLib and (Scaner.Token = tokKeywordEnd) then // Library 允许直接 end
    Match(Scaner.Token)
  else
    FormatCompoundStmt(PreSpaceCount);
end;

{
  ConstantDecl -> Ident '=' ConstExpr [DIRECTIVE/..]

               -> Ident ':' TypeId '=' TypedConstant
  FIXED:       -> Ident ':' Type '=' TypedConstant [DIRECTIVE/..]
}
procedure TCnBasePascalFormatter.FormatConstantDecl(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);

  case Scaner.Token of
    tokEQUAL:
      begin
        Match(Scaner.Token, 1); // 等号前空一格
        FormatConstExpr(1); // 等号后只空一格
      end;

    tokColon: // 无法直接区分 record/array/普通常量方式的初始化，需要内部解析
      begin
        Match(Scaner.Token);

        FormatType;
        Match(tokEQUAL, 1, 1); // 等号前后空一格

        FormatTypedConstant; // 等号后空一格
      end;
  else
    Error(CN_ERRCODE_PASCAL_NO_EQUALCOLON);
  end;

  while Scaner.Token in DirectiveTokens do
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
begin
  if Scaner.Token in [tokKeywordConst, tokKeywordResourcestring] then
    Match(Scaner.Token, PreSpaceCount);

  while Scaner.Token in IsConstStartTokens do // 这些关键字不宜做变量名但也不好处理，只有先写上
  begin
    // 如果是[，就要越过其属性，找到]后的第一个，确定它是否还是 const，如果不是，就跳出
    if (Scaner.Token = tokSLB) and not IsTokenAfterAttributesInSet(IsConstStartTokens) then
      Exit;

    Writeln;
    FormatConstantDecl(Tab(PreSpaceCount));
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

  while Scaner.Token in DeclSectionTokens do
  begin
    if MakeLine then // Attribute 后无须空行分隔所以 MakeLine 会被设为 False
    begin
      if IsInternal then  // 内部的定义只需要空一行
        EnsureOneEmptyLine
      else
        WriteLine;
    end;

    MakeLine := True;
    case Scaner.Token of
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
          FormatVarSection(PreSpaceCount);
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

  if Scaner.Token = tokLB then
    FormatFormalParameters;

  if Scaner.Token = tokColon then
  begin
      Match(tokColon);

    if Scaner.Token = tokKeywordString then
      Match(Scaner.Token)
    else
      FormatSimpleType;
  end;

  while Scaner.Token in DirectiveTokens do
    FormatDirective;
end;

{ ExportsList -> ( ExportsDecl ',')... }
procedure TCnBasePascalFormatter.FormatExportsList(PreSpaceCount: Byte);
begin
  FormatExportsDecl(PreSpaceCount);
  while Scaner.Token = tokComma do
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
begin
  FormatFunctionHeading(PreSpaceCount);

  if Scaner.Token = tokSemicolon then // 可能有省略分号的情况
    Match(tokSemicolon, 0, 0, True); // 不让分号后写空格，免得影响 Directive 的空格

  IsExternal := False;
  IsForward := False;
  while Scaner.Token in DirectiveTokens + ComplexTokens do
  begin
    if Scaner.Token = tokDirectiveExternal then
      IsExternal := True;
    if Scaner.Token = tokDirectiveForward then
      IsForward := True;
    FormatDirective;
    {
     FIX A BUG: semicolon can missing after directive like this:
     
     procedure Foo; external 'foo.dll' name '__foo'
     procedure Bar; external 'bar.dll' name '__bar'
    }
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon, 0, 0, True);
  end;

  if (not IsExternal) and (not IsForward) then
  begin
    FNextBeginShouldIndent := True; // 过程声明后 begin 必须换行
    Writeln;
  end;

  if ((not IsExternal)  and (not IsForward))and
     (Scaner.Token in BlockStmtTokens + DeclSectionTokens) then
  begin
    FormatBlock(PreSpaceCount, True);
    if not IsAnonymous and (Scaner.Token = tokSemicolon) then // 匿名函数不包括 end 后的分号
      Match(tokSemicolon);
  end;
end;

{ LabelDeclSection -> LABEL LabelId/ ',' .. ';'}
procedure TCnBasePascalFormatter.FormatLabelDeclSection(
  PreSpaceCount: Byte);
begin
  Match(tokKeywordLabel, PreSpaceCount);
  Writeln;
  FormatLabelID(Tab(PreSpaceCount));

  while Scaner.Token = tokComma do
  begin
    Match(Scaner.Token);
    FormatLabelID;
  end;

  Match(tokSemicolon);
end;

{ LabelID can be symbol or number }
procedure TCnBasePascalFormatter.FormatLabelID(PreSpaceCount: Byte);
begin
  Match(Scaner.Token, PreSpaceCount);
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
begin
  FormatProcedureHeading(PreSpaceCount);

  if Scaner.Token = tokSemicolon then // 可能有省略分号的情况
    Match(tokSemicolon, 0, 0, True); // 不让分号后写空格，免得影响 Directive 的空格

  IsExternal := False;
  IsForward := False;
  while Scaner.Token in DirectiveTokens + ComplexTokens do  // Use ComplexTokens for "local;"
  begin
    if Scaner.Token = tokDirectiveExternal then
      IsExternal := True;
    if Scaner.Token = tokDirectiveForward then
      IsForward := True;

    FormatDirective;
    {
      FIX A BUG: semicolon can missing after directive like this:

       procedure Foo; external 'foo.dll' name '__foo'
       procedure Bar; external 'bar.dll' name '__bar'
    }
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon, 0, 0, True);
  end;

  if (not IsExternal) and (not IsForward) then
  begin
    FNextBeginShouldIndent := True; // 函数声明后 begin 必须换行
    Writeln;
  end;

  if ((not IsExternal) and (not IsForward)) and
    (Scaner.Token in BlockStmtTokens + DeclSectionTokens) then // Local procedure also supports Attribute
  begin
    FormatBlock(PreSpaceCount, True);
    if not IsAnonymous and (Scaner.Token = tokSemicolon) then // 匿名函数不包括 end 后的分号
      Match(tokSemicolon);
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
  Scaner.SaveBookmark(Bookmark);
  CodeGen.LockOutput;

  if Scaner.Token = tokKeywordClass then
  begin
    Scaner.NextToken;
  end;

  case Scaner.Token of
    tokKeywordProcedure, tokKeywordConstructor, tokKeywordDestructor:
    begin
      Scaner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      FormatProcedureDecl(PreSpaceCount);
    end;

    tokKeywordFunction, tokKeywordOperator:
    begin
      Scaner.LoadBookmark(Bookmark);
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
  if Scaner.Token = tokKeywordUses then
  begin
    FormatUsesClause(PreSpaceCount, True); // 带 IN 的，需要分行
    WriteLine;
  end;
  FormatProgramInnerBlock(PreSpaceCount, False, IsLib);
end;

procedure TCnProgramBlockFormatter.FormatPackageBlock(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokKeywordRequires then
  begin
    FormatUsesClause(PreSpaceCount, True); // 不带 IN 的 requires，需要分行
    WriteLine;
  end;

  if Scaner.Token = tokKeywordContains then
  begin
    FormatUsesClause(PreSpaceCount, True); // 带 IN 的，需要分行
    WriteLine;
  end;
end;

{ UsesClause -> USES UsesList ';' }
procedure TCnProgramBlockFormatter.FormatUsesClause(PreSpaceCount: Byte;
  const NeedCRLF: Boolean);
begin
  if Scaner.Token in [tokKeywordUses, tokKeywordRequires, tokKeywordContains] then
    Match(Scaner.Token);

  Writeln;
  SpecifyElementType(pfetUsesList);
  try
    FormatUsesList(Tab(PreSpaceCount), True, NeedCRLF);
  finally
    RestoreElementType;
  end;

  Match(tokSemicolon);
end;

{ UsesList -> (UsesDecl ',') ... }
procedure TCnProgramBlockFormatter.FormatUsesList(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean; const NeedCRLF: Boolean);
var
  OldWrapMode: TCodeWrapMode;
  OldAuto: Boolean;
begin
  FormatUsesDecl(PreSpaceCount, CanHaveUnitQual);

  while Scaner.Token = tokComma do
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
begin
  if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
    Match(Scaner.Token, PreSpaceCount); // 标识符中允许使用部分关键字

  while CanHaveUnitQual and (Scaner.Token = tokDot) do
  begin
    Match(tokDot);
    if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scaner.Token);
  end;

  if Scaner.Token = tokKeywordIn then // 处理 in
  begin
    Match(tokKeywordIn, 1, 1);
    if Scaner.Token in [tokString, tokWString] then
      Match(Scaner.Token)
    else
      ErrorToken(tokString);
  end;
end;

{ VarDecl -> IdentList ':' Type [(ABSOLUTE (Ident | ConstExpr)) | '=' TypedConstant] }
procedure TCnBasePascalFormatter.FormatVarDecl(PreSpaceCount: Byte);
begin
  FormatIdentList(PreSpaceCount);
  if Scaner.Token = tokColon then // 放宽语法限制
  begin
    Match(tokColon);
    FormatType(PreSpaceCount); // 长 Type 可能换行，必须传入
  end;

  if Scaner.Token = tokEQUAL then
  begin
    Match(Scaner.Token, 1, 1);
    FormatTypedConstant;
  end
  else if Scaner.TokenSymbolIs('ABSOLUTE') then
  begin
    Match(Scaner.Token);
    FormatConstExpr; // include indent
  end;

  while Scaner.Token in DirectiveTokens do
    FormatDirective;
end;

{ VarSection -> VAR | THREADVAR (VarDecl ';')... }
procedure TCnBasePascalFormatter.FormatVarSection(PreSpaceCount: Byte);
const
  IsVarStartTokens = [tokSymbol, tokSLB] + ComplexTokens + DirectiveTokens
    + KeywordTokens - NOTExpressionTokens;
begin
  if Scaner.Token in [tokKeywordVar, tokKeywordThreadvar] then
    Match(Scaner.Token, PreSpaceCount);

  while Scaner.Token in IsVarStartTokens do // 这些关键字不宜做变量名但也不好处理，只有先写上
  begin
    // 如果是[，就要越过其属性，找到]后的第一个，确定它是否还是 var，如果不是，就跳出
    if (Scaner.Token = tokSLB) and not IsTokenAfterAttributesInSet(IsVarStartTokens) then
      Exit;

    Writeln;
    FormatVarDecl(Tab(PreSpaceCount));
    Match(tokSemicolon);
  end;
end;

procedure TCnBasePascalFormatter.FormatTypeID(PreSpaceCount: Byte);
var
  Old: Boolean;
begin
  if Scaner.Token in BuiltInTypeTokens then
    Match(Scaner.Token)
  else if Scaner.Token = tokKeywordFile then
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
    if Scaner.Token = tokLB then
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
  case Scaner.Token of
    tokKeywordProcedure: FormatProcedureHeading(PreSpaceCount);
    tokKeywordFunction: FormatFunctionHeading(PreSpaceCount);
  else
    Error(CN_ERRCODE_PASCAL_NO_PROCFUNC);
  end;

  if Scaner.Token = tokSemicolon then
    Match(tokSemicolon, 0, 0, True); // 不让分号后写空格，免得影响 Directive 的空格

  while Scaner.Token in DirectiveTokens do
  begin
    FormatDirective;
    {
     FIX A BUG: semicolon can missing after directive like this:

     procedure Foo; external 'foo.dll' name '__foo'
     procedure Bar; external 'bar.dll' name '__bar'
    }
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon, 0, 0, True);
  end;
end;

{ Goal -> (Program | Package  | Library  | Unit) }
procedure TCnGoalCodeFormatter.FormatGoal(PreSpaceCount: Byte);
begin
  case Scaner.Token of
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

  while Scaner.Token = tokKeywordUses do
  begin
    WriteLine;
    FormatUsesClause(PreSpaceCount, CnPascalCodeForRule.UsesUnitSingleLine);
  end;

  if Scaner.Token in DeclSectionTokens then
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
  Match(tokKeywordInitialization);
  Writeln;
  if Scaner.Token = tokKeywordFinalization then // Empty initialization
  begin
    Writeln;
    Match(Scaner.Token);
    Writeln;
    FormatStmtList(Tab);
    Exit;
  end
  else
    FormatStmtList(Tab);

  if Scaner.Token = tokKeywordFinalization then
  begin
    WriteBlankLineByPrevCondition;
    Match(Scaner.Token);
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
  
  while Scaner.Token in InterfaceDeclTokens do
  begin
    if MakeLine then WriteLine;

    case Scaner.Token of
      tokKeywordUses: FormatUsesClause(PreSpaceCount, CnPascalCodeForRule.UsesUnitSingleLine); // 加入 uses 的处理以提高容错性
      tokKeywordConst, tokKeywordResourcestring: FormatConstSection(PreSpaceCount);
      tokKeywordType: FormatTypeSection(PreSpaceCount);
      tokKeywordVar, tokKeywordThreadvar: FormatVarSection(PreSpaceCount);
      tokKeywordProcedure, tokKeywordFunction: FormatExportedHeading(PreSpaceCount);
      tokKeywordExports: FormatExportsSection(PreSpaceCount);
      tokSLB: FormatSingleAttribute(PreSpaceCount);
    else
      if not CnPascalCodeForRule.ContinueAfterError then
        Error(CN_ERRCODE_PASCAL_ERROR_INTERFACE)
      else
      begin
        Match(Scaner.Token);
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

  while Scaner.Token = tokKeywordUses do
  begin
    WriteLine;
    FormatUsesClause(PreSpaceCount, CnPascalCodeForRule.UsesUnitSingleLine);
  end;

  if Scaner.Token in InterfaceDeclTokens then
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
  FormatIdent(PreSpaceCount);
  while Scaner.Token in DirectiveTokens do
    Match(Scaner.Token);

  Match(tokSemicolon);
  WriteLine;

  FormatProgramBlock(PreSpaceCount, True);
  Match(tokDot);
end;

{
  Program -> [PROGRAM Ident ['(' IdentList ')'] ';']
             ProgramBlock '.'
}
procedure TCnGoalCodeFormatter.FormatPackage(PreSpaceCount: Byte);
begin
  Match(tokKeywordPackage, PreSpaceCount);
  FormatIdent;

  if Scaner.Token = tokSemicolon then
    Match(Scaner.Token, PreSpaceCount);

  WriteLine;
  FormatPackageBlock(PreSpaceCount);
  Match(tokKeywordEnd);
  Match(tokDot);
end;

procedure TCnGoalCodeFormatter.FormatProgram(PreSpaceCount: Byte);
begin
  Match(tokKeywordProgram, PreSpaceCount);
  FormatIdent;

  if Scaner.Token = tokLB then
  begin
    Match(Scaner.Token);
    FormatIdentList;
    Match(tokRB);
  end;

  if Scaner.Token = tokSemicolon then // 难道可以不要分号？
    Match(Scaner.Token, PreSpaceCount);

  WriteLine;
  FormatProgramBlock(PreSpaceCount);
  Match(tokDot);
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
  FormatIdent;

  while Scaner.Token in DirectiveTokens do
  begin
    Match(Scaner.Token);
  end;

  Match(tokSemicolon, PreSpaceCount);
  WriteLine;

  FormatInterfaceSection(PreSpaceCount);
  WriteLine;

  FormatImplementationSection(PreSpaceCount);
  WriteLine;

  if Scaner.Token = tokKeywordInitialization then
  begin
    FormatInitSection(PreSpaceCount);
    WriteBlankLineByPrevCondition;
  end;

  Match(tokKeywordEnd, PreSpaceCount);
  Match(tokDot);
end;

{ ClassBody -> [ClassHeritage] [ClassMemberList END] }
procedure TCnBasePascalFormatter.FormatClassBody(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokLB then
  begin
    FormatClassHeritage;
  end;

  if Scaner.Token <> tokSemiColon then
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

    while Scaner.Token = tokSemicolon do
    begin
      Match(Scaner.Token);

      if Scaner.Token <> tokSymbol then Exit;

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
  if Scaner.Token in ClassMemberSymbolTokens then // 部分关键字此处可以当做 Symbol
  begin
    case Scaner.Token of
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
begin
  while Scaner.Token in ClassVisibilityTokens + ClassMemberSymbolTokens do
  begin
    if Scaner.Token in ClassVisibilityTokens then
    begin
      FormatClassVisibility(PreSpaceCount);
      // 应该：如果下一个还是，就空一行
      // if Scaner.Token in ClassVisibilityTokens + [tokKeywordEnd] then
      //  Writeln;
    end;

    if Scaner.Token in ClassMemberSymbolTokens then
      FormatClassMember(Tab(PreSpaceCount));
  end;
end;

{ ClassMethod -> [CLASS] MethodHeading ';' [(DIRECTIVE ';')...] }
procedure TCnBasePascalFormatter.FormatClassMethod(PreSpaceCount: Byte);
var
  IsFirst: Boolean;
begin
  if Scaner.Token = tokKeywordClass then
  begin
    Match(tokKeywordClass, PreSpaceCount);
    if Scaner.Token in [tokKeywordProcedure, tokKeywordFunction,
      tokKeywordConstructor, tokKeywordDestructor, tokKeywordProperty,
      tokKeywordOperator] then // Single line heading
      FormatMethodHeading
    else
      FormatMethodHeading(PreSpaceCount, True);
  end else if Scaner.Token in [tokKeywordVar, tokKeywordThreadVar] then
  begin
    FormatMethodHeading(PreSpaceCount, False);
  end
  else
    FormatMethodHeading(PreSpaceCount);

  if Scaner.Token = tokSemicolon then // class property already processed ;
    Match(tokSemicolon);

  IsFirst := True;
  while Scaner.Token in DirectiveTokens do
  begin
    FormatDirective(PreSpaceCount, IsFirst);
    IsFirst := False;
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon, 0, 0, True);
  end;

//  begin
//    if Scaner.Token = tokDirectiveMESSAGE then
//    begin
//      Match(Scaner.Token); // message MESSAGE_ID;
//      FormatConstExpr;
//    end
//    else
//      Match(Scaner.Token);
//    Match(tokSemicolon);
//  end;
end;

{ ClassProperty -> PROPERTY Ident [PropertyInterface]  PropertySpecifiers ';' [DEFAULT ';']}
procedure TCnBasePascalFormatter.FormatClassProperty(PreSpaceCount: Byte);
begin
  Match(tokKeywordProperty, PreSpaceCount);
  FormatIdent;

  if Scaner.Token in [tokSLB, tokColon] then
    FormatPropertyInterface;

  FormatPropertySpecifiers;
  Match(tokSemiColon);

  if Scaner.TokenSymbolIs('DEFAULT') then
  begin
    Match(Scaner.Token);
    Match(tokSemiColon);
  end;
end;

// class/record 内的 type 声明，对结束判断不一样。
procedure TCnBasePascalFormatter.FormatClassTypeSection(
  PreSpaceCount: Byte);
var
  FirstType: Boolean;
begin
  Match(tokKeywordType, PreSpaceCount);
  Writeln;

  FirstType := True;
  while Scaner.Token in [tokSymbol, tokSLB] + ComplexTokens + DirectiveTokens
   + KeywordTokens - NOTExpressionTokens - NOTClassTypeConstTokens do
  begin
    if not FirstType then WriteLine;
    FormatTypeDecl(Tab(PreSpaceCount));
    while Scaner.Token in DirectiveTokens do
      FormatDirective;
    Match(tokSemicolon);
    FirstType := False;
  end;
end;

{ procedure/function/constructor/destructor Name, can be classname.name}
procedure TCnBasePascalFormatter.FormatMethodName(PreSpaceCount: Byte);
begin
  FormatTypeParamIdent;
  // 加入对泛型的支持
  if Scaner.Token = tokDot then
  begin
    Match(tokDot);
    FormatTypeParamIdent;
  end;
end;

procedure TCnBasePascalFormatter.FormatClassConstSection(
  PreSpaceCount: Byte);
begin
  Match(tokKeywordConst, PreSpaceCount);

  while Scaner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens + KeywordTokens
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

  case Scaner.Token of
    tokEQUAL:
      begin
        Match(Scaner.Token, 1); // 等号前空一格
        FormatConstExpr(1); // 等号后只空一格
      end;

    tokColon: // 无法直接区分 record/array/普通常量方式的初始化，需要内部解析
      begin
        Match(Scaner.Token);

        FormatType;
        Match(tokEQUAL, 1, 1); // 等号前后空一格

        FormatTypedConstant; // 等号后空一格
      end;
  else
    Error(CN_ERRCODE_PASCAL_NO_EQUALCOLON); 
  end;

  while Scaner.Token in DirectiveTokens do
    FormatDirective;
end;

procedure TCnBasePascalFormatter.FormatSingleAttribute(
  PreSpaceCount: Byte);
var
  IsFirst, JustLn: Boolean;
begin
  Match(tokSLB, PreSpaceCount);
  IsFirst := True;
  repeat
    JustLn := False;
    if IsFirst then
      FormatIdent
    else
      FormatIdent(PreSpaceCount);
      
    if Scaner.Token = tokLB then
    begin
      Match(tokLB);
      FormatExprList;
      Match(tokRB);
    end
    else if Scaner.Token = tokColon then
    begin
      Match(tokColon);
      FormatIdent;
    end;

    if Scaner.Token = tokComma then // Multi-Attribute, use new line.
    begin
      Match(tokComma);
      IsFirst := False;
      Writeln;
      JustLn := True;
    end;

    // If not Attribute, maybe infinite loop here, jump and fix.
    if not (Scaner.Token in [tokSRB, tokUnknown, tokEOF]) then
    begin
      if JustLn then
        Match(Scaner.Token, PreSpaceCount)
      else
        Match(Scaner.Token);
    end;

  until Scaner.Token in [tokSRB, tokUnknown, tokEOF];
  Match(tokSRB);
end;

function TCnBasePascalFormatter.IsTokenAfterAttributesInSet(
  InTokens: TPascalTokenSet): Boolean;
var
  Bookmark: TScannerBookmark;
begin
  Scaner.SaveBookmark(Bookmark);
  CodeGen.LockOutput;

  try
    Result := False;
    if Scaner.Token <> tokSLB then
      Exit;

    // 要跳过多个可能紧邻的属性，而不止一个
    while Scaner.Token = tokSLB do
    begin
      while not (Scaner.Token in [tokEOF, tokUnknown, tokSRB]) do
        Scaner.NextToken;

      if Scaner.Token <> tokSRB then
        Exit;

      Scaner.NextToken;
    end;
    Result := (Scaner.Token in InTokens);
  finally
    Scaner.LoadBookmark(Bookmark);
    CodeGen.UnLockOutput;
  end;
end;

function TCnAbstractCodeFormatter.ErrorTokenString: string;
begin
  Result := TokenToString(Scaner.Token);
  if Result = '' then
    Result := Scaner.TokenString;
end;

procedure TCnAbstractCodeFormatter.WriteBlankLineByPrevCondition;
begin
  if Scaner.PrevBlankLines then
    Writeln
  else
    WriteLine;
end;

procedure TCnAbstractCodeFormatter.WriteLineFeedByPrevCondition;
begin
  if not Scaner.PrevBlankLines then
    Writeln;
end;

procedure TCnBasePascalFormatter.CheckWriteBeginln;
begin
  if (Scaner.Token <> tokKeywordBegin) or
    (CnPascalCodeForRule.BeginStyle <> bsSameLine) then
    Writeln;
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
//    FScaner.SourcePos]);
{$ENDIF}

  // 记录目的与源的行映射
  if not IsWriteBlank and not IsWriteln and (FInputLineMarks <> nil) then
  begin
    for I := 0 to FInputLineMarks.Count - 1 do
    begin
      if Scaner.SourceLine = Integer(FInputLineMarks[I]) then
        if Integer(FOutputLineMarks[I]) = 0 then // 第一回匹配
          FOutputLineMarks[I] := Pointer(TCnCodeGenerator(Sender).ActualRow);
    end;
  end;

  if IsWriteBlank then
  begin
    StartPos := FScaner.BlankStringPos;
    EndPos := FScaner.BlankStringPos + FScaner.BlankStringLength;
  end
  else
  begin
    StartPos := FScaner.SourcePos;
    EndPos := FScaner.SourcePos + FScaner.TokenStringLength;
  end;

  // 写出不属于代码本身的空行时超出标记的话，不算
  if (StartPos >= FMatchedInStart) and not IsWriteln and not FFirstMatchStart then
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
    pfetThen, pfetDo, pfetExprListRightBracket, pfetFormalParametersRightBracket])
    or ((FElementType in [pfetConstExpr]) and not UpperContainElementType([pfetCaseLabel])) // Case Label 的无需跟随上面一行注释缩进
    or UpperContainElementType([pfetFormalParameters, pfetArrayConstant]);
  // 暂且表达式内部与枚举定义内部等一系列元素内部，或者在参数列表、uses 中
  // 碰到注释导致的换行时，才要求自动和上一行对齐
  // 还要求在本来不换行的组合语句里，比如 if then ，while do 里，for do 里
  // 严格来讲 then/do 这种还不同，不需要进一步缩进，不过暂时当作进一步缩进处理。
end;

function TCnAbstractCodeFormatter.CalcNeedPaddingAndUnIndent: Boolean;
begin
  Result := FElementType in [pfetExprListRightBracket, pfetFormalParametersRightBracket,
    pfetFieldDecl, pfetClassField];
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

initialization
  MakeKeywordsValidAreas;

end.
