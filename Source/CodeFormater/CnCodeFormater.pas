{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2012 CnPack 开发组                       }    
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

unit CnCodeFormater;
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

uses
  Classes, SysUtils, Dialogs, CnTokens, CnScaners, CnCodeGenerators,
  CnCodeFormatRules;

type
  TCnAbstractCodeFormater = class
  private
    FScaner: TAbstractScaner;
    FCodeGen: TCnCodeGenerator;
    FLastToken: TPascalToken;
    FInternalRaiseException: Boolean;
  protected
    {* 错误处理函数 }
    procedure Error(const Ident: string);
    procedure ErrorFmt(const Ident: string; const Args: array of const);
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
      SemicolonIsLineStart: Boolean = False);
    procedure MatchOperator(Token: TPascalToken); //操作符
    procedure WriteToken(Token: TPascalToken; BeforeSpaceCount: Byte = 0;
      AfterSpaceCount: Byte = 0; IgnorePreSpace: Boolean = False;
      SemicolonIsLineStart: Boolean = False);

    function CheckFunctionName(S: string): string;
    {* 检查给定字符串是否是一个常用函数名，如果是则返回正确的格式 }
    function Tab(PreSpaceCount: Byte = 0; CareBeginBlock: Boolean = True): Byte;
    {* 根据代码格式风格设置返回缩进一次的前导空格数 }
    function BackTab(PreSpaceCount: Byte = 0; CareBeginBlock: Boolean = True): Integer;
    {* 根据代码格式风格设置返回上一次缩进的前导空格数 }
    function Space(Count: Word): string;
    {* 返回指定数目空格的字符串 }
    procedure Writeln;
    {* 格式结果换行 }
    procedure WriteLine; 
    {* 格式结果加一空行 }
    function FormatString(const KeywordStr: string; KeywordStyle: TKeywordStyle): string;
    {* 返回指定关键字风格的字符串}
    function UpperFirst(const KeywordStr: string): string;
    {* 返回首字母大写的字符串}
    property CodeGen: TCnCodeGenerator read FCodeGen;
    {* 目标代码生成器}
    property Scaner: TAbstractScaner read FScaner;
    {* 词法扫描器}
  public
    constructor Create(AStream: TStream);
    destructor Destroy; override;

    procedure FormatCode(PreSpaceCount: Byte = 0); virtual; abstract;
    procedure SaveToFile(FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToStrings(AStrings: TStrings);
  end;

  TCnExpressionFormater = class(TCnAbstractCodeFormater)
  protected
    procedure FormatExprList(PreSpaceCount: Byte = 0);
    procedure FormatExpression(PreSpaceCount: Byte = 0);
    procedure FormatSimpleExpression(PreSpaceCount: Byte = 0);
    procedure FormatTerm(PreSpaceCount: Byte = 0);
    procedure FormatFactor(PreSpaceCount: Byte = 0);
    procedure FormatDesignator(PreSpaceCount: Byte = 0);
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
    procedure FormatTypeParams(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamDeclList(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamDecl(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamList(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamIdentList(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamIdent(PreSpaceCount: Byte = 0);
  public
    procedure FormatCode(PreSpaceCount: Byte = 0); override;
  end;

  TCnStatementFormater = class(TCnExpressionFormater)
  protected
    procedure FormatCompoundStmt(PreSpaceCount: Byte = 0);
    procedure FormatStmtList(PreSpaceCount: Byte = 0);
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
    procedure FormatAsmBlock(PreSpaceCount: Byte = 0);
  public
    procedure FormatCode(PreSpaceCount: Byte = 0); override;
  end;

  TCnTypeSectionFormater = class(TCnStatementFormater)
  protected
    procedure FormatTypeSection(PreSpaceCount: Byte = 0);
    procedure FormatTypeDecl(PreSpaceCount: Byte = 0);
    procedure FormatTypedConstant(PreSpaceCount: Byte = 0);

    procedure FormatArrayConstant(PreSpaceCount: Byte = 0);
    procedure FormatRecordConstant(PreSpaceCount: Byte = 0);
    procedure FormatRecordFieldConstant(PreSpaceCount: Byte = 0);
    procedure FormatType(PreSpaceCount: Byte = 0; IgnoreDirective: Boolean = False);
    procedure FormatRestrictedType(PreSpaceCount: Byte = 0);
    procedure FormatClassRefType(PreSpaceCount: Byte = 0);
    procedure FormatSimpleType(PreSpaceCount: Byte = 0);
    procedure FormatOrdinalType(PreSpaceCount: Byte = 0);
    procedure FormatSubrangeType(PreSpaceCount: Byte = 0);
    procedure FormatEnumeratedType(PreSpaceCount: Byte = 0);
    procedure FormatEnumeratedList(PreSpaceCount: Byte = 0);
    procedure FormatEmumeratedIdent(PreSpaceCount: Byte = 0);
    procedure FormatStringType(PreSpaceCount: Byte = 0);
    procedure FormatStructType(PreSpaceCount: Byte = 0);
    procedure FormatArrayType(PreSpaceCount: Byte = 0);
    procedure FormatRecType(PreSpaceCount: Byte = 0);
    procedure FormatFieldList(PreSpaceCount: Byte = 0; IgnoreFirst: Boolean = False);
    {* 处理 record 中 case 内部的首行无需缩进的问题}
    procedure FormatFieldDecl(PreSpaceCount: Byte = 0);
    procedure FormatVariantSection(PreSpaceCount: Byte = 0);
    procedure FormatRecVariant(PreSpaceCount: Byte = 0; IgnoreFirst: Boolean = False);
    {* 处理 record 中 case 内部的首行无需缩进的问题}
    procedure FormatSetType(PreSpaceCount: Byte = 0);
    procedure FormatFileType(PreSpaceCount: Byte = 0);
    procedure FormatPointerType(PreSpaceCount: Byte = 0);
    procedure FormatProcedureType(PreSpaceCount: Byte = 0);
    procedure FormatFunctionHeading(PreSpaceCount: Byte = 0; AllowEqual: Boolean = True);
    procedure FormatProcedureHeading(PreSpaceCount: Byte = 0; AllowEqual: Boolean = True);
    {* 用 AllowEqual 区分 ProcType 和 ProcDecl 可否带等于号的情形}
    procedure FormatMethodName(PreSpaceCount: Byte = 0);
    procedure FormatFormalParameters(PreSpaceCount: Byte = 0);
    procedure FormatFormalParm(PreSpaceCount: Byte = 0);
    procedure FormatParameter(PreSpaceCount: Byte = 0);
    procedure FormatDirective(PreSpaceCount: Byte = 0; IgnoreFirst: Boolean = False);
    procedure FormatObjectType(PreSpaceCount: Byte = 0);
    procedure FormatObjHeritage(PreSpaceCount: Byte = 0);
    procedure FormatMethodList(PreSpaceCount: Byte = 0);
    procedure FormatMethodHeading(PreSpaceCount: Byte = 0);
    procedure FormatConstructorHeading(PreSpaceCount: Byte = 0);
    procedure FormatDestructorHeading(PreSpaceCount: Byte = 0);
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
    //procedure FormatTypeID(PreSpaceCount: Byte = 0);
  end;

  TCnProgramBlockFormater = class(TCnTypeSectionFormater)
  protected
    procedure FormatProgramBlock(PreSpaceCount: Byte = 0);
    procedure FormatUsesClause(PreSpaceCount: Byte = 0; const NeedCRLF: Boolean = False);
    procedure FormatUsesList(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True;
      const NeedCRLF: Boolean = False);
    procedure FormatUsesDecl(PreSpaceCount: Byte; const CanHaveUnitQual: Boolean = True);
    procedure FormatBlock(PreSpaceCount: Byte = 0; IsInternal: Boolean = False);
    procedure FormatDeclSection(PreSpaceCount: Byte; IndentProcs: Boolean = True;
      IsInternal: Boolean = False);
    procedure FormatLabelDeclSection(PreSpaceCount: Byte = 0);
    procedure FormatConstSection(PreSpaceCount: Byte = 0);
    procedure FormatConstantDecl(PreSpaceCount: Byte = 0);
    procedure FormatVarSection(PreSpaceCount: Byte = 0);
    procedure FormatVarDecl(PreSpaceCount: Byte = 0);
    procedure FormatProcedureDeclSection(PreSpaceCount: Byte = 0);
    procedure FormatProcedureDecl(PreSpaceCount: Byte = 0);
    procedure FormatFunctionDecl(PreSpaceCount: Byte = 0);
    procedure FormatLabelID(PreSpaceCount: Byte = 0);
    procedure FormatExportsSection(PreSpaceCount: Byte = 0);
    procedure FormatExportsList(PreSpaceCount: Byte = 0);
    procedure FormatExportsDecl(PreSpaceCount: Byte = 0);
  end;

  TCnGoalCodeFormater = class(TCnProgramBlockFormater)
  protected
    procedure FormatGoal(PreSpaceCount: Byte = 0);
    procedure FormatProgram(PreSpaceCount: Byte = 0);
    procedure FormatUnit(PreSpaceCount: Byte = 0);
    procedure FormatLibrary(PreSpaceCount: Byte = 0);
    procedure FormatInterfaceSection(PreSpaceCount: Byte = 0);
    procedure FormatInterfaceDecl(PreSpaceCount: Byte = 0);
    procedure FormatExportedHeading(PreSpaceCount: Byte = 0);
    procedure FormatImplementationSection(PreSpaceCount: Byte = 0);
    procedure FormatInitSection(PreSpaceCount: Byte = 0);
  public
    procedure FormatCode(PreSpaceCount: Byte = 0); override;
  end;

  TCnPascalCodeFormater = class(TCnGoalCodeFormater);

implementation

uses
  CnParseConsts;

{ TCnAbstractCodeFormater }

function TCnAbstractCodeFormater.CheckFunctionName(S: string): string;
begin
  { TODO: Check the S with functon name e.g. ShowMessage }
  Result := S;
end;

constructor TCnAbstractCodeFormater.Create(AStream: TStream);
begin
  FCodeGen := TCnCodeGenerator.Create;
  FScaner := TScaner.Create(AStream, FCodeGen);
end;

destructor TCnAbstractCodeFormater.Destroy;
begin
  FScaner.Free;
  inherited;
end;

procedure TCnAbstractCodeFormater.Error(const Ident: string);
begin
  ErrorStr(Ident);
end;

procedure TCnAbstractCodeFormater.ErrorFmt(const Ident: string;
  const Args: array of const);
begin
  ErrorStr(Format(Ident, Args));
end;

procedure TCnAbstractCodeFormater.ErrorNotSurpport(FurtureStr: string);
begin
  ErrorFmt(SNotSurpport, [FurtureStr]);
end;

procedure TCnAbstractCodeFormater.ErrorStr(const Message: string);
begin
  raise EParserError.CreateResFmt(
        @SParseError,
        [ Message, FScaner.SourceLine, FScaner.SourcePos ]
  );
end;

procedure TCnAbstractCodeFormater.ErrorToken(Token: TPascalToken);
begin
  if TokenToString(Scaner.Token) = '' then
    ErrorFmt(SSymbolExpected, [TokenToString(Token), Scaner.TokenString] )
  else
    ErrorFmt(SSymbolExpected, [TokenToString(Token), TokenToString(Scaner.Token)]);
end;

procedure TCnAbstractCodeFormater.ErrorTokens(Tokens: array of TPascalToken);
var
  S: string;
  I: Integer;
begin
  S := '';
  for I := Low(Tokens) to High(Tokens) do
    S := S + TokenToString(Tokens[I]) + ' ';

  ErrorExpected(S);
end;

procedure TCnAbstractCodeFormater.ErrorExpected(Str: string);
begin
  ErrorFmt(SSymbolExpected, [Str, TokenToString(Scaner.Token)]);
end;

function TCnAbstractCodeFormater.FormatString(const KeywordStr: string;
  KeywordStyle: TKeywordStyle): string;
begin
  case KeywordStyle of
    ksPascalKeyword:    Result := UpperFirst(KeywordStr);
    ksUpperCaseKeyword: Result := UpperCase(KeywordStr);
    ksLowerCaseKeyword: Result := LowerCase(KeywordStr);
  else
    Result := KeywordStr;
  end;
end;

function TCnAbstractCodeFormater.UpperFirst(const KeywordStr: string): string;
begin
  Result := LowerCase(KeywordStr);
  if Length(Result) >= 1 then
    Result[1] := Char(Ord(Result[1]) + Ord('A') - Ord('a'));
end;

function TCnAbstractCodeFormater.CanBeSymbol(Token: TPascalToken): Boolean;
begin
  Result := Scaner.Token in ([tokSymbol] + ComplexTokens); //KeywordTokens + DirectiveTokens);
end;

procedure TCnAbstractCodeFormater.Match(Token: TPascalToken; BeforeSpaceCount,
  AfterSpaceCount: Byte; IgnorePreSpace: Boolean; SemicolonIsLineStart: Boolean);
begin
  if (Scaner.Token = Token) or ( (Token = tokSymbol) and
    CanBeSymbol(Scaner.Token) ) then
  begin
    WriteToken(Token, BeforeSpaceCount, AfterSpaceCount,
      IgnorePreSpace, SemicolonIsLineStart);
    Scaner.NextToken;
  end
  else if FInternalRaiseException or not CnPascalCodeForRule.ContinueAfterError then
    ErrorToken(Token)
  else // 要继续的场合，写了再说
  begin
    WriteToken(Token, BeforeSpaceCount, AfterSpaceCount,
      IgnorePreSpace, SemicolonIsLineStart);
    Scaner.NextToken;
  end;
end;

procedure TCnAbstractCodeFormater.MatchOperator(Token: TPascalToken);
begin
  Match(Token, CnPascalCodeForRule.SpaceBeforeOperator,
        CnPascalCodeForRule.SpaceAfterOperator);
end;

procedure TCnAbstractCodeFormater.SaveToFile(FileName: string);
begin
  CodeGen.SaveToFile(FileName);
end;

procedure TCnAbstractCodeFormater.SaveToStream(Stream: TStream);
begin
  CodeGen.SaveToStream(Stream);
end;

procedure TCnAbstractCodeFormater.SaveToStrings(AStrings: TStrings);
begin
  CodeGen.SaveToStrings(AStrings);
end;

function TCnAbstractCodeFormater.Space(Count: Word): string;
begin
  Result := 'a'#10'a'#13'sd'; // ???
  if SmallInt(Count) > 0 then
    Result := StringOfChar(' ', Count)
  else
    Result := '';
end;

function TCnAbstractCodeFormater.Tab(PreSpaceCount: Byte;
  CareBeginBlock: Boolean): Byte;
begin
  if CareBeginBlock then
  begin
    { TODO: customize Begin..End Block style }
    if Scaner.Token <> tokKeywordBegin then // 处理了连续俩 begin 而需要缩进的情况
      Result := PreSpaceCount + CnPascalCodeForRule.TabSpaceCount
    else
      Result := PreSpaceCount;
  end
  else
  begin
    Result := PreSpaceCount + CnPascalCodeForRule.TabSpaceCount;
  end;
end;

procedure TCnAbstractCodeFormater.WriteLine;
begin
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

procedure TCnAbstractCodeFormater.Writeln;
begin
  if (Scaner.BlankLinesBefore = 0) and (Scaner.BlankLinesAfter = 0) then
  begin
    FCodeGen.Writeln;
  end
  else // 有 Comment，已经输出了，但 Comment 后的空行未输出，并且前后各有换行
  begin
    if Scaner.BlankLinesBefore = 0 then
    begin
      // 注释块和上一行在一起，照常输出空行
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
    end;
  end;
  FLastToken := tokBlank; // prevent 'Symbol'#13#10' Symbol'
end;

procedure TCnAbstractCodeFormater.WriteToken(Token: TPascalToken;
  BeforeSpaceCount, AfterSpaceCount: Byte; IgnorePreSpace: Boolean;
  SemicolonIsLineStart: Boolean);
begin
  // 两个标识符之间以空格分离
  if ( (FLastToken in IdentTokens) and (Token in IdentTokens + [tokAtSign]) ) then
    CodeGen.Write(' ')
  else if (FLastToken in RightBracket) and (Token in [tokKeywordThen, tokKeywordDo, tokKeywordOf]) then
    CodeGen.Write(' ')
  else if (Token in LeftBracket) and (FLastToken in [tokKeywordIf, tokKeywordWhile,
    tokKeywordFor, tokKeywordWith, tokKeywordCase]) then
    CodeGen.Write(' ');
    // 强行分离括号与关键字

  //标点符号的设置
  case Token of
    tokComma:     CodeGen.Write(Scaner.TokenString, 0, 1);
    tokColon:
      begin
        if IgnorePreSpace then
          CodeGen.Write(Scaner.TokenString)
        else
          CodeGen.Write(Scaner.TokenString, 0, 1);
      end;
    tokSemiColon:
      begin
        if IgnorePreSpace then
          CodeGen.Write(Scaner.TokenString)
        else if SemicolonIsLineStart then
          CodeGen.Write(Scaner.TokenString, BeforeSpaceCount, 1)
        else
          CodeGen.Write(Scaner.TokenString, 0, 1);
      end;
    tokAssign:    CodeGen.Write(Scaner.TokenString, 1, 1);
  else

    if (Token in KeywordTokens + ComplexTokens + DirectiveTokens) then // 关键字范围扩大
    begin
      if (Token <> tokKeywordEnd) and (Token <> tokKeywordString) then
      begin
          CodeGen.Write(
            FormatString(Scaner.TokenString, CnPascalCodeForRule.KeywordStyle),
            BeforeSpaceCount, AfterSpaceCount);
      end
      else
      begin
        CodeGen.Write(
          FormatString(Scaner.TokenString, CnPascalCodeForRule.KeywordStyle),
          BeforeSpaceCount, AfterSpaceCount);
      end;
    end
    else
      CodeGen.Write(Scaner.TokenString, BeforeSpaceCount, AfterSpaceCount);
  end;

  FLastToken := Token;
end;

procedure TCnAbstractCodeFormater.CheckHeadComments;
var
  I: Integer;
begin
  if FCodeGen <> nil then
    for I := 1 to Scaner.BlankLinesAfter do
      FCodeGen.Writeln;
end;

function TCnAbstractCodeFormater.BackTab(PreSpaceCount: Byte;
  CareBeginBlock: Boolean): Integer;
begin
  if CareBeginBlock then
  begin
    Result := PreSpaceCount - CnPascalCodeForRule.TabSpaceCount;
    if Result < 0 then
      Result := 0;
  end;
end;

{ TCnExpressionFormater }

procedure TCnExpressionFormater.FormatCode;
begin
  FormatExpression;
end;

{ ConstExpr -> <constant-expression> }
procedure TCnExpressionFormater.FormatConstExpr(PreSpaceCount: Byte);
begin
  FormatExpression(PreSpaceCount);
end;

{ 新加的用于 type 中的 ConstExpr -> <constant-expression> ，
  其中后者不允许出现 = 以及泛型 <> 运算符}
procedure TCnExpressionFormater.FormatConstExprInType(PreSpaceCount: Byte);
begin
  FormatSimpleExpression(PreSpaceCount);

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
procedure TCnExpressionFormater.FormatDesignator(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokAtSign then // 如果是 @ Designator 的形式则再次递归
  begin
    Match(tokAtSign, PreSpaceCount);
    FormatDesignator;
    Exit;
  end;

  FormatQualID(PreSpaceCount);
  while Scaner.Token in [tokDot, tokLB, tokSLB, tokHat, tokPlus, tokMinus] do
  begin
    case Scaner.Token of
      tokDot:
        begin
          Match(tokDot);
          FormatIdent;
        end;

      tokLB, tokSLB: // [ ]
        begin
          { DONE: deal with index visit }
          Match(Scaner.Token);
          FormatExprList;
          Match(Scaner.Token);
        end;

      tokHat: // ^
        begin
          { DONE: deal with pointer derefrence }
          Match(tokHat);
        end;

      tokPlus, tokMinus:
        begin
          MatchOperator(Scaner.Token);
          FormatExpression;
        end;
    end; // case
  end; // while
end;

{ DesignatorList -> Designator/','... }
procedure TCnExpressionFormater.FormatDesignatorList(PreSpaceCount: Byte);
begin
  FormatDesignator;

  while Scaner.Token = tokComma do
  begin
    MatchOperator(tokComma);
    FormatDesignator;
  end;
end;

{ Expression -> SimpleExpression [RelOp SimpleExpression]... }
procedure TCnExpressionFormater.FormatExpression(PreSpaceCount: Byte);
begin
  FormatSimpleExpression(PreSpaceCount);

  while Scaner.Token in RelOpTokens + [tokHat, tokSLB, tokDot] do
  begin
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
      FormatExprList;
      Match(tokSRB);
    end
    else if Scaner.Token = tokDot then // typecase
    begin
      Match(tokDot);
      FormatExpression;
    end;
  end;
end;

{ ExprList -> Expression/','... }
procedure TCnExpressionFormater.FormatExprList(PreSpaceCount: Byte);
begin
  FormatExpression;

  if Scaner.Token = tokAssign then // 匹配 OLE 调用的情形
  begin
    Match(tokAssign);
    FormatExpression;
  end;

  while Scaner.Token = tokComma do
  begin
    Match(tokComma, 0, 1);

    if Scaner.Token in ([tokAtSign, tokLB] + ExprTokens + KeywordTokens +
      DirectiveTokens + ComplexTokens) then // 有关键字做变量名的情况也得考虑到
    begin
      FormatExpression;

      if Scaner.Token = tokAssign then // 匹配 OLE 调用的情形
      begin
        Match(tokAssign);
        FormatExpression;
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
procedure TCnExpressionFormater.FormatFactor(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokSymbol, tokAtSign,
    tokKeyword_BEGIN..tokKeywordIn,  // 此三行表示部分关键字也可做 Factor
    tokKeywordInitialization..tokKeywordNil,
    tokKeywordObject..tokKeyword_END,
    tokDirective_BEGIN..tokDirective_END,
    tokComplex_BEGIN..tokComplex_END:
      begin
        FormatDesignator(PreSpaceCount);

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
        case Scaner.Token of
          tokInteger, tokFloat:
            WriteToken(Scaner.Token, PreSpaceCount);
          tokTrue, tokFalse:
            CodeGen.Write(UpperFirst(Scaner.TokenString), PreSpaceCount);
            // CodeGen.Write(FormatString(Scaner.TokenString, CnCodeForRule.KeywordStyle), PreSpaceCount);
          tokChar, tokString:
            CodeGen.Write(Scaner.TokenString, PreSpaceCount); //QuotedStr
          tokWString:
            CodeGen.Write(Scaner.TokenString, PreSpaceCount);
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

procedure TCnExpressionFormater.FormatIdent(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
    Match(Scaner.Token, PreSpaceCount); // 标识符中允许使用部分关键字

  while CanHaveUnitQual and (Scaner.Token = tokDot) do
  begin
    Match(tokDot);
    if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scaner.Token); // 也继续允许使用部分关键字
  end;
end;

{ IdentList -> Ident/','... }
procedure TCnExpressionFormater.FormatIdentList(PreSpaceCount: Byte;
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
         -> [UnitId '.'] Ident
         -> '(' pointervar + expr ')'

  for typecast, e.g. "(x as Ty)" or just bracketed, as in (x).y();

  Old Grammer:
  QualId -> [UnitId '.'] Ident 
}
procedure TCnExpressionFormater.FormatQualID(PreSpaceCount: Byte);

  procedure FormatIdentWithBracket(PreSpaceCount: Byte);
  var
    I, BracketCount: Integer;
  begin
    BracketCount := 0;
    while Scaner.Token = tokLB do
    begin
      Match(tokLB);
      Inc(BracketCount);
    end;

    FormatIdent(PreSpaceCount, True);

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
procedure TCnExpressionFormater.FormatSetConstructor(PreSpaceCount: Byte);

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
end;

{ SimpleExpression -> ['+' | '-'] Term [AddOp Term]... }
procedure TCnExpressionFormater.FormatSimpleExpression(
  PreSpaceCount: Byte);
begin
  if Scaner.Token in [tokPlus, tokMinus] then
  begin
    Match(Scaner.Token, PreSpaceCount);
    FormatTerm;
  end
  else
    FormatTerm(PreSpaceCount);

  while Scaner.Token in AddOpTokens do
  begin
    MatchOperator(Scaner.Token);
    FormatTerm;
  end;
end;

{ Term -> Factor [MulOp Factor]... }
procedure TCnExpressionFormater.FormatTerm(PreSpaceCount: Byte);
begin
  FormatFactor(PreSpaceCount);

  while Scaner.Token in (MulOPTokens + ShiftOpTokens) do
  begin
    MatchOperator(Scaner.Token);
    FormatFactor;
  end;
end;

// 泛型支持
procedure TCnExpressionFormater.FormatFormalTypeParamList(
  PreSpaceCount: Byte);
begin
  FormatTypeParams(PreSpaceCount); // 两者等同，直接调用
end;

{TypeParamDecl -> TypeParamList [ ':' ConstraintList ]}
procedure TCnExpressionFormater.FormatTypeParamDecl(PreSpaceCount: Byte);
begin
  FormatTypeParamList(PreSpaceCount);
  if Scaner.Token = tokColon then // ConstraintList
  begin
    Match(tokColon);
    FormatIdentList(PreSpaceCount, True);
  end;
end;

{ TypeParamDeclList -> TypeParamDecl/';'... }
procedure TCnExpressionFormater.FormatTypeParamDeclList(
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
procedure TCnExpressionFormater.FormatTypeParamList(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);
  while Scaner.Token = tokComma do // 暂不处理 CAttr
  begin
    Match(tokComma);
    FormatIdent(PreSpaceCount);
  end;
end;

{ TypeParams -> '<' TypeParamDeclList '>' }
procedure TCnExpressionFormater.FormatTypeParams(PreSpaceCount: Byte);
begin
  Match(tokLess);
  FormatTypeParamDeclList(PreSpaceCount);
  Match(tokGreat);
end;

procedure TCnExpressionFormater.FormatTypeParamIdent(PreSpaceCount: Byte);
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

procedure TCnExpressionFormater.FormatTypeParamIdentList(
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
procedure TCnStatementFormater.FormatCaseLabel(PreSpaceCount: Byte);
begin
  FormatConstExpr(PreSpaceCount);

  if Scaner.Token = tokRange then
  begin
    Match(tokRange);
    FormatConstExpr;
  end;
end;

{ CaseSelector -> CaseLabel/','... ':' Statement }
procedure TCnStatementFormater.FormatCaseSelector(PreSpaceCount: Byte);
begin
  FormatCaseLabel(PreSpaceCount);

  while Scaner.Token = tokComma do
  begin
    Match(tokComma);
    FormatCaseLabel; 
  end;

  Match(tokColon);
  // TODO: 此处控制每个 caselabel 后是否换行，但如不换，碰上 begin end 就乱了
  Writeln;
  if Scaner.Token <> tokSemicolon then
    FormatStatement(Tab(PreSpaceCount, False))
  else // 是空语句就手工写缩进
    CodeGen.Write('', Tab(PreSpaceCount));
end;

{ CaseStmt -> CASE Expression OF CaseSelector/';'... [ELSE StmtList] [';'] END }
procedure TCnStatementFormater.FormatCaseStmt(PreSpaceCount: Byte);
var
  HasElse: Boolean;
begin
  Match(tokKeywordCase, PreSpaceCount);
  FormatExpression;
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

procedure TCnStatementFormater.FormatCode(PreSpaceCount: Byte);
begin
  FormatStmtList(PreSpaceCount);
end;

{ CompoundStmt -> BEGIN StmtList END
               -> ASM ... END
}
procedure TCnStatementFormater.FormatCompoundStmt(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordBegin:
      begin
        Match(tokKeywordBegin, PreSpaceCount);
        Writeln;
        FormatStmtList(Tab(PreSpaceCount, False));
        Writeln;
        Match(tokKeywordEnd, PreSpaceCount);
      end;

    tokKeywordAsm:
      begin
        FormatAsmBlock(PreSpaceCount);
      end;
  else
    ErrorTokens([tokKeywordBegin, tokKeywordAsm]);
  end;
end;

{ ForStmt -> FOR QualId ':=' Expression (TO | DOWNTO) Expression DO Statement }
{ ForStmt -> FOR QualId in Expression DO Statement }

procedure TCnStatementFormater.FormatForStmt(PreSpaceCount: Byte);
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
          ErrorFmt(SSymbolExpected, ['to/downto', TokenToString(Scaner.Token)]);

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

  Match(tokKeywordDo);
  Writeln;
  FormatStatement(Tab(PreSpaceCount));
end;

{ IfStmt -> IF Expression THEN Statement [ELSE Statement] }
procedure TCnStatementFormater.FormatIfStmt(PreSpaceCount: Byte; IgnorePreSpace: Boolean);
begin
  if IgnorePreSpace then
    Match(tokKeywordIF)
  else
    Match(tokKeywordIF, PreSpaceCount);

  { TODO: Apply more if stmt rule }
  FormatExpression;
  Match(tokKeywordThen);
  Writeln;
  FormatStatement(Tab(PreSpaceCount));

  if Scaner.Token = tokKeywordElse then
  begin
    Writeln;
    Match(tokKeywordElse, PreSpaceCount);
    if Scaner.Token = tokKeywordIf then // 处理 else if
    begin
      FormatIfStmt(PreSpaceCount, True);
      FormatStatement(Tab(PreSpaceCount));
    end
    else
    begin
      Writeln;
      FormatStatement(Tab(PreSpaceCount));
    end;
  end;
end;

{ RepeatStmt -> REPEAT StmtList UNTIL Expression }
procedure TCnStatementFormater.FormatRepeatStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordRepeat, PreSpaceCount, 1);
  Writeln;
  FormatStmtList(Tab(PreSpaceCount));
  Writeln;
  
  if Scaner.Token = tokLB then // 处理后面的空格
    Match(tokKeywordUntil, PreSpaceCount, 1)
  else
    Match(tokKeywordUntil, PreSpaceCount);
    
  FormatExpression;
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
procedure TCnStatementFormater.FormatSimpleStatement(PreSpaceCount: Byte);
var
  Bookmark: TScannerBookmark;
  OldLastToken: TPascalToken;
  IsDesignator, OldInternalRaiseException: Boolean;

  procedure FormatDesignatorAndOthers(PreSpaceCount: Byte);
  begin
    FormatDesignator(PreSpaceCount);

    while Scaner.Token in [tokAssign, tokLB, tokLess] do
    begin
      case Scaner.Token of
        tokAssign:
          begin
            Match(tokAssign);
            FormatExpression;
          end;

        tokLB:
          begin
            { DONE: deal with function call, save to symboltable }
            Match(tokLB);
            FormatExprList;
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
    tokSymbol, tokAtSign,
    tokDirective_BEGIN..tokDirective_END, // 允许语句以部分关键字开头
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

            IsDesignator := Scaner.Token in [tokAssign, tokLB, tokSemicolon];
            // 目前只想到这几个。Semicolon 是怕 Designator 已经作为语句处理完了
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
    Error('Identifier or Goto or Inherited expected.');
  end;
end;

procedure TCnStatementFormater.FormatLabel(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokInteger then
    Match(tokInteger, PreSpaceCount)
  else
    Match(tokSymbol, PreSpaceCount);
end;

{ Statement -> [LabelId ':']/.. [SimpleStatement | StructStmt] }
procedure TCnStatementFormater.FormatStatement(PreSpaceCount: Byte);
begin
  while Scaner.ForwardToken() = tokColon do
  begin
    Writeln;
    FormatLabel;
    Match(tokColon);

    Writeln;
  end;

  // 允许语句以部分关键字开头，比如变量名等
  if Scaner.Token in SimpStmtTokens + DirectiveTokens + ComplexTokens then
    FormatSimpleStatement(PreSpaceCount)
  else if Scaner.Token in StructStmtTokens then
  begin
    FormatStructStmt(PreSpaceCount);
  end;
  { Do not raise error here, Statement maybe empty }
end;

{ StmtList -> Statement/';'... }
procedure TCnStatementFormater.FormatStmtList(PreSpaceCount: Byte);
begin
  // 处理空语句单独分行的问题
  while Scaner.Token = tokSemicolon do
  begin
    Match(tokSemicolon, PreSpaceCount, 0, False, True);
    if Scaner.Token <> tokKeywordEnd then
      Writeln;
  end;
  
  FormatStatement(PreSpaceCount);

  while Scaner.Token = tokSemicolon do
  begin
    Match(tokSemicolon);

    // 处理空语句单独分行的问题
    while Scaner.Token = tokSemicolon do
    begin
      Writeln;
      Match(tokSemicolon, PreSpaceCount, 0, False, True);
    end;

    if Scaner.Token in StmtTokens + DirectiveTokens + ComplexTokens
      + [tokInteger] then // 部分关键字能做语句开头，Label 可能以数字开头
    begin
      { DONE: 建立语句列表 }
      Writeln;
      FormatStatement(PreSpaceCount);
    end;
  end;
end;

{
  StructStmt -> CompoundStmt
             -> ConditionalStmt
             -> LoopStmt
             -> WithStmt
             -> TryStmt
}
procedure TCnStatementFormater.FormatStructStmt(PreSpaceCount: Byte);
begin
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
    ErrorFmt(SSymbolExpected, ['Statement', TokenToString(Scaner.Token)]);
  end;
end;

{
  TryEnd -> FINALLY StmtList END
         -> EXCEPT [ StmtList | (ExceptionHandler/;... [ELSE Statement]) ] [';'] END
}
procedure TCnStatementFormater.FormatTryEnd(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordFinally:
      begin
        Match(Scaner.Token, PreSpaceCount);
        Writeln;
        FormatStmtList(Tab(PreSpaceCount));
        Writeln;
        Match(tokKeywordEnd, PreSpaceCount);
      end;

    tokKeywordExcept:
      begin
        Match(Scaner.Token, PreSpaceCount);

        if Scaner.Token <> tokKeywordOn then
        begin
          Writeln;
          FormatStmtList(Tab(PreSpaceCount))
        end
        else
        begin
          while Scaner.Token = tokKeywordOn do
          begin
            Writeln;
            FormatExceptionHandler(Tab(PreSpaceCount));
          end;

          if Scaner.Token = tokKeywordElse then
          begin
            Writeln;
            Match(tokKeywordElse, PreSpaceCount, 1);
            Writeln;
            FormatStmtList(Tab(PreSpaceCount, False));
          end;

          if Scaner.Token = tokSemicolon then
            Match(tokSemicolon);
        end;

        Writeln;
        Match(tokKeywordEnd, PreSpaceCount);
      end;
  else
    ErrorFmt(SSymbolExpected, ['except/finally']);
  end;
end;

{
  ExceptionHandler -> ON [ident :] Type do Statement
}
procedure TCnStatementFormater.FormatExceptionHandler(PreSpaceCount: Byte);
var
  OnlySemicolon: Boolean;
begin
  Match(tokKeywordOn, PreSpaceCount);
  Match(tokSymbol);
  if Scaner.Token = tokColon then
  begin
    Match(tokColon);
    Match(tokSymbol);
  end;
  Match(tokKeywordDo);
  Writeln;

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
procedure TCnStatementFormater.FormatTryStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordTry, PreSpaceCount);
  Writeln;
  FormatStmtList(Tab(PreSpaceCount));
  Writeln;
  FormatTryEnd(PreSpaceCount);
end;

{ WhileStmt -> WHILE Expression DO Statement }
procedure TCnStatementFormater.FormatWhileStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordWhile, PreSpaceCount);
  FormatExpression;
  Match(tokKeywordDo);
  Writeln;
  FormatStatement(Tab(PreSpaceCount));
end;

{ WithStmt -> WITH IdentList DO Statement }
procedure TCnStatementFormater.FormatWithStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordWith, PreSpaceCount);
  // FormatDesignatorList; // Grammer error.

  FormatExpression;
  while Scaner.Token = tokComma do
  begin
    MatchOperator(tokComma);
    FormatExpression;
  end;

  Match(tokKeywordDo);
  Writeln;
  FormatStatement(Tab(PreSpaceCount));
end;

{ RaiseStmt -> RAISE [ Expression | Expression AT Expression ] }
procedure TCnStatementFormater.FormatRaiseStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordRaise, PreSpaceCount);

  if not (Scaner.Token in [tokSemicolon, tokKeywordEnd, tokKeywordElse]) then
    FormatExpression;

  if Scaner.TokenSymbolIs('AT') then
  begin
    Match(Scaner.Token, 1, 1);
    FormatExpression;
  end;
end;

{ AsmBlock -> AsmStmtList 按自定义规矩格式化}
procedure TCnStatementFormater.FormatAsmBlock(PreSpaceCount: Byte);
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

        while Scaner.Token in [tokAtSign, tokSymbol, tokInteger] + KeywordTokens +
          DirectiveTokens + ComplexTokens do
        begin
          if Scaner.Token = tokAtSign then
          begin
            HasAtSign := True;
            ALabel := ALabel + '@';
            Inc(LabelLen);
            Scaner.NextToken;
          end
          else if Scaner.Token in [tokSymbol, tokInteger] + KeywordTokens +
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
        else
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
            CodeGen.Write(' ')
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
    if Scaner.Token in [tokBlank, tokCRLF] then
      Scaner.NextToken;
    CnPascalCodeForRule.KeywordStyle := OldKeywordStyle; // 恢复 KeywordStyle
    Match(tokKeywordEnd, PreSpaceCount);
  end;
end;

{ TCnTypeSectionFormater }

{ ArrayConstant -> '(' TypedConstant/','... ')' }
procedure TCnTypeSectionFormater.FormatArrayConstant(PreSpaceCount: Byte);
begin
  Match(tokLB);
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
end;

{ ArrayType -> ARRAY ['[' OrdinalType/','... ']'] OF Type }
procedure TCnTypeSectionFormater.FormatArrayType(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatClassFieldList(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatClassHeritage(PreSpaceCount: Byte);
begin
  Match(tokLB);
  FormatTypeParamIdentList(); // 加入泛型的支持
  Match(tokRB);
end;

{ ClassMethodList -> (ClassVisibility MethodList)/';'... }
procedure TCnTypeSectionFormater.FormatClassMethodList(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatClassPropertyList(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatClassRefType(PreSpaceCount: Byte);
begin
  Match(tokkeywordClass);
  Match(tokKeywordOf);

  { TypeId -> [UnitId '.'] <type-identifier> }
  Match(tokSymbol);
  if Scaner.Token = tokDot then
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
  =============Cut End==============
}
procedure TCnTypeSectionFormater.FormatClassType(PreSpaceCount: Byte);
begin
  Match(tokKeywordClass);
  
  case Scaner.Token of
    tokKeywordOF:  // like TFoo = class of TBar;
      begin
        Match(tokKeywordOF);
        FormatIdent;
        Exit;
      end;
      
    tokSemiColon: Exit; // class declare forward, like TFoo = class;
  else
    FormatClassBody(PreSpaceCount);
  end;

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
procedure TCnTypeSectionFormater.FormatClassVisibility(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatConstructorHeading(PreSpaceCount: Byte);
begin
  Match(tokKeywordConstructor, PreSpaceCount);
  FormatMethodName;

  if Scaner.Token = tokLB then
    FormatFormalParameters;
end;

{ ContainsClause -> CONTAINS IdentList... ';' }
procedure TCnTypeSectionFormater.FormatContainsClause(PreSpaceCount: Byte);
begin
  if Scaner.TokenSymbolIs('CONTAINS') then
  begin
    Match(Scaner.Token, 0, 1);
    FormatIdentList;
    Match(tokSemicolon);
  end;
end;

{ DestructorHeading -> DESTRUCTOR Ident [FormalParameters] }
procedure TCnTypeSectionFormater.FormatDestructorHeading(PreSpaceCount: Byte);
begin
  Match(tokKeywordDestructor, PreSpaceCount);
  FormatMethodName;

  if Scaner.Token = tokLB then
    FormatFormalParameters;
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
procedure TCnTypeSectionFormater.FormatDirective(PreSpaceCount: Byte;
  IgnoreFirst: Boolean);
begin
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
        CodeGen.Write(' '); // 关键字空格分隔
      CodeGen.Write(FormatString(Scaner.TokenString, CnPascalCodeForRule.KeywordStyle));
      FLastToken := Scaner.Token;
      Scaner.NextToken;
      
      if not (Scaner.Token in DirectiveTokens) then // 加个后续的表达式
      begin
        if Scaner.Token in [tokString, tokWString, tokLB, tokPlus, tokMinus] then
          CodeGen.Write(' '); // 后续表达式空格分隔
        FormatConstExpr;
      end;
      //  Match(Scaner.Token);
    end
    else
    begin
      if not IgnoreFirst then
        CodeGen.Write(' '); // 关键字空格分隔
      CodeGen.Write(FormatString(Scaner.TokenString, CnPascalCodeForRule.KeywordStyle));
      FLastToken := Scaner.Token;
      Scaner.NextToken;
    end;
  end
  else
    Error('error Directive ' + Scaner.TokenString);
end;

{ EnumeratedType -> '(' EnumeratedList ')' }
procedure TCnTypeSectionFormater.FormatEnumeratedType(PreSpaceCount: Byte);
begin
  Match(tokLB);
  FormatEnumeratedList;
  Match(tokRB);
end;

{ EnumeratedList -> EmumeratedIdent/','... }
procedure TCnTypeSectionFormater.FormatEnumeratedList(PreSpaceCount: Byte);
begin
  FormatEmumeratedIdent(PreSpaceCount);
  while Scaner.Token = tokComma do
  begin
    Match(tokComma);
    FormatEmumeratedIdent;
  end;
end;

{ EmumeratedIdent -> Ident ['=' ConstExpr] }
procedure TCnTypeSectionFormater.FormatEmumeratedIdent(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);
  if Scaner.Token = tokEQUAL then
  begin
    Match(tokEQUAL, 1, 1);
    FormatConstExpr;
  end;
end;

{ FieldDecl -> IdentList ':' Type }
procedure TCnTypeSectionFormater.FormatFieldDecl(PreSpaceCount: Byte);
begin
  FormatIdentList(PreSpaceCount);
  Match(tokColon);
  FormatType(PreSpaceCount);
end;

{ FieldList ->  FieldDecl/';'... [VariantSection] [';'] }
procedure TCnTypeSectionFormater.FormatFieldList(PreSpaceCount: Byte;
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
    end
    else if Scaner.Token = tokKeywordProperty then
    begin
      FormatClassProperty(PreSpaceCount);
      Writeln;
    end
    else
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

  if First then // 没有声明则先换行
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
procedure TCnTypeSectionFormater.FormatFileType(PreSpaceCount: Byte);
begin
  Match(tokKeywordFile);
  if Scaner.Token = tokKeywordOf then // 可以是单独的 file
  begin
    Match(tokKeywordOf);
    FormatTypeID;
  end;
end;

{ FormalParameters -> ['(' FormalParm/';'... ')'] }
procedure TCnTypeSectionFormater.FormatFormalParameters(PreSpaceCount: Byte);
begin
  Match(tokLB);
  
  if Scaner.Token <> tokRB then
    FormatFormalParm;
  
  while Scaner.Token = tokSemicolon do
  begin
    Match(Scaner.Token);
    FormatFormalParm;
  end;

  Match(tokRB);
end;

{ FormalParm -> [VAR | CONST | OUT] Parameter }
procedure TCnTypeSectionFormater.FormatFormalParm(PreSpaceCount: Byte);
begin
  if (Scaner.Token in [tokKeywordVar, tokKeywordConst, tokKeywordOut]) and
     not (Scaner.ForwardToken in [tokColon, tokComma])
  then
    Match(Scaner.Token);

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
procedure TCnTypeSectionFormater.FormatFunctionHeading(PreSpaceCount: Byte;
  AllowEqual: Boolean);
begin
  if Scaner.Token = tokKeywordClass then
  begin
    Match(tokKeywordClass, PreSpaceCount); // class 后无需再手工加空格
    Match(tokKeywordFunction);
  end else
    Match(tokKeywordFunction, PreSpaceCount);

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
procedure TCnTypeSectionFormater.FormatInterfaceHeritage(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatInterfaceType(PreSpaceCount: Byte);
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
  while Scaner.Token in [tokKeywordProperty] + ClassMethodTokens do
  begin
    if Scaner.Token = tokKeywordProperty then
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

procedure TCnTypeSectionFormater.FormatGuid(PreSpaceCount: Byte = 0);
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
}
procedure TCnTypeSectionFormater.FormatMethodHeading(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordProcedure: FormatProcedureHeading(PreSpaceCount);
    tokKeywordFunction: FormatFunctionHeading(PreSpaceCount);
    tokKeywordConstructor: FormatConstructorHeading(PreSpaceCount);
    tokKeywordDestructor: FormatDestructorHeading(PreSpaceCount);
  else
    Error('MethodHeading is needed.');
  end;
end;

{ MethodList -> (MethodHeading [';' VIRTUAL])/';'... }
procedure TCnTypeSectionFormater.FormatMethodList(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatObjectType(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatObjFieldList(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatObjHeritage(PreSpaceCount: Byte);
begin
  Match(tokLB);
  FormatQualID;
  Match(tokRB);
end;

{ OrdinalType -> (SubrangeType | EnumeratedType | OrdIdent) }
procedure TCnTypeSectionFormater.FormatOrdinalType(PreSpaceCount: Byte);
var
  Bookmark: TScannerBookmark;
begin
  if Scaner.Token = tokLB then  // EnumeratedType
    FormatEnumeratedType(PreSpaceCount)
  else
  begin
    Scaner.SaveBookmark(Bookmark);
    if Scaner.Token = tokMinus then // 考虑到负号的情况
      Scaner.NextToken;
    Scaner.NextToken;
    
    if Scaner.Token = tokRange then
    begin
      Scaner.LoadBookmark(Bookmark);
      // SubrangeType
      FormatSubrangeType(PreSpaceCount);
    end
    else
    begin
      Scaner.LoadBookmark(Bookmark);
      // OrdIdent
      if Scaner.Token = tokMinus then
        Match(Scaner.Token);
      Match(Scaner.Token);
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
procedure TCnTypeSectionFormater.FormatParameter(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatPointerType(PreSpaceCount: Byte);
begin
  Match(tokHat);
  FormatTypeID;
end;

{ ProcedureHeading -> [CLASS] PROCEDURE Ident [FormalParameters] }
procedure TCnTypeSectionFormater.FormatProcedureHeading(PreSpaceCount: Byte;
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
    + KeywordTokens then // 函数名允许出现关键字
  begin
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
procedure TCnTypeSectionFormater.FormatProcedureType(PreSpaceCount: Byte);
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
  // if Scaner.Token in DirectiveTokens then CodeGen.Write(' ');

  IsSemicolon := False;
  if (Scaner.Token = tokSemicolon) and (Scaner.ForwardToken in DirectiveTokens) then
  begin
    Match(tokSemicolon);
    IsSemicolon := True;
  end;  // 处理 stdcall 之前的分号

  while Scaner.Token in DirectiveTokens do
  begin
    FormatDirective(0, IsSemicolon);

    // leave one semicolon for procedure type define
    // if Scaner.Token = tokSemicolon then
    //  Match(tokSemicolon);
  end;
end;

{ PropertyInterface -> [PropertyParameterList] ':' Ident }
procedure TCnTypeSectionFormater.FormatPropertyInterface(PreSpaceCount: Byte);
begin
  if Scaner.Token <> tokColon then
    FormatPropertyParameterList;

  Match(tokColon);

  FormatType(PreSpaceCount, True);
end;

{ PropertyList -> PROPERTY  Ident [PropertyInterface]  PropertySpecifiers }
procedure TCnTypeSectionFormater.FormatPropertyList(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatPropertyParameterList(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatPropertySpecifiers(PreSpaceCount: Byte);

  procedure ProcessBlank;
  begin
    if Scaner.Token in [tokString, tokWString, tokLB, tokPlus, tokMinus] then
      CodeGen.Write(' '); // 后续表达式空格分隔
  end;
begin
  while Scaner.Token in PropertySpecifiersTokens do
  begin
    case Scaner.Token of
      tokComplexIndex:
      begin
        Match(Scaner.Token);
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

      tokComplexDEFAULT:
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

      tokComplexNODEFAULT, tokComplexREADONLY, tokComplexWRITEONLY:
        Match(Scaner.Token);
    end;
  end;
end;

{ RecordConstant -> '(' RecordFieldConstant/';'... ')' }
procedure TCnTypeSectionFormater.FormatRecordConstant(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatRecordFieldConstant(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);
  Match(tokColon);
  FormatTypedConstant;
end;

{ RecType -> RECORD [FieldList] END }
procedure TCnTypeSectionFormater.FormatRecType(PreSpaceCount: Byte);
begin
  Match(tokKeywordRecord);
  Writeln;

  if Scaner.Token <> tokKeywordEnd then
    FormatFieldList(Tab(PreSpaceCount));

  Match(tokKeywordEnd, PreSpaceCount);
end;

{ RecVariant -> ConstExpr/','...  ':' '(' [FieldList] ')' }
procedure TCnTypeSectionFormater.FormatRecVariant(PreSpaceCount: Byte;
  IgnoreFirst: Boolean);
begin
  FormatConstExpr(PreSpaceCount);

  while Scaner.Token = tokComma do
  begin
    Match(Scaner.Token);
    FormatConstExpr;
  end;

  Match(tokColon);
  Match(tokLB);
  if Scaner.Token <> tokRB then
    FormatFieldList(Tab(PreSpaceCount), IgnoreFirst);

  // 如果嵌套了记录，此括号必须缩进。没好办法，姑且判断上一个是不是分号和左括号
  if FLastToken in [tokSemicolon, tokLB, tokBlank] then
    Match(tokRB, PreSpaceCount)
  else
    Match(tokRB);
end;

{ RequiresClause -> REQUIRES IdentList... ';' }
procedure TCnTypeSectionFormater.FormatRequiresClause(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatRestrictedType(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordObject: FormatObjectType(PreSpaceCount);
    tokKeywordClass: FormatClassType(PreSpaceCount);
    tokKeywordInterface, tokKeywordDispinterface: FormatInterfaceType(PreSpaceCount);
  end;
end;

{ SetType -> SET OF OrdinalType }
procedure TCnTypeSectionFormater.FormatSetType(PreSpaceCount: Byte);
begin
  // Set 内部不换行因此无需使用 PreSpaceCount
  Match(tokKeywordSet);
  Match(tokKeywordOf);
  FormatOrdinalType;
end;

{ SimpleType -> (SubrangeType | EnumeratedType | OrdIdent | RealType) }
procedure TCnTypeSectionFormater.FormatSimpleType(PreSpaceCount: Byte);
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
procedure TCnTypeSectionFormater.FormatStringType(PreSpaceCount: Byte);
begin
  Match(Scaner.Token);
  if Scaner.Token = tokSLB then
  begin
    Match(Scaner.Token);
    FormatConstExpr;
    Match(tokSRB);
  end;
end;

{ StrucType -> [PACKED] (ArrayType | SetType | FileType | RecType) }
procedure TCnTypeSectionFormater.FormatStructType(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokkeywordPacked then
    Match(Scaner.Token);

  case Scaner.Token of
    tokKeywordArray: FormatArrayType(PreSpaceCount);
    tokKeywordSet: FormatSetType(PreSpaceCount);
    tokKeywordFile: FormatFileType(PreSpaceCount);
    tokKeywordRecord: FormatRecType(PreSpaceCount);
  else
    Error('StructType is needed.');
  end;
end;

{ SubrangeType -> ConstExpr '..' ConstExpr }
procedure TCnTypeSectionFormater.FormatSubrangeType(PreSpaceCount: Byte);
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
}
procedure TCnTypeSectionFormater.FormatType(PreSpaceCount: Byte;
  IgnoreDirective: Boolean);
var
  Bookmark: TScannerBookmark;
  AToken, OldLastToken: TPascalToken;
begin
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
procedure TCnTypeSectionFormater.FormatTypedConstant(PreSpaceCount: Byte);
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
    if Scaner.Token in ConstTokens + [tokAtSign, tokPlus, tokMinus] then // 有可能初始化的值以这些开头
      FormatConstExpr(PreSpaceCount)
    else if Scaner.Token <> tokRB then
      Error('TypeConstant is needed.');
  end;
end;

{
  TypeDecl -> Ident '=' Type
           -> Ident '=' RestrictedType
}
procedure TCnTypeSectionFormater.FormatTypeDecl(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);

  // 加入对<>泛型的支持
  if Scaner.Token = tokLess then
  begin
    FormatTypeParams;
//    if Scaner.Token = tokDot then
//      FormatIdent;
  end;

  MatchOperator(tokEQUAL);

  if Scaner.Token = tokKeywordType then // 处理 TInt = type Integer; 的情形
    Match(tokKeywordType);

  if Scaner.Token in RestrictedTypeTokens then
    FormatRestrictedType(PreSpaceCount)
  else
    FormatType(PreSpaceCount);
end;

{ TypeSection -> TYPE (TypeDecl ';')... }
procedure TCnTypeSectionFormater.FormatTypeSection(PreSpaceCount: Byte);
var
  FirstType: Boolean;
begin
  Match(tokKeywordType, PreSpaceCount);
  Writeln;

  FirstType := True;
  while Scaner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens
   + KeywordTokens - NOTExpressionTokens do
  begin
    if not FirstType then WriteLine;
    FormatTypeDecl(Tab(PreSpaceCount));
    while Scaner.Token in DirectiveTokens do
      FormatDirective;
    Match(tokSemicolon);
    FirstType := False;
  end;
end;

{ VariantSection -> CASE [Ident ':'] TypeId OF RecVariant/';'... }
procedure TCnTypeSectionFormater.FormatVariantSection(PreSpaceCount: Byte);
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
  if Scaner.Token = tokDot then
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
procedure TCnProgramBlockFormater.FormatBlock(PreSpaceCount: Byte;
  IsInternal: Boolean);
begin
  while Scaner.Token in DeclSectionTokens do
  begin
    FormatDeclSection(PreSpaceCount, True, IsInternal);
    Writeln;
  end;

  FormatCompoundStmt(PreSpaceCount);
end;

{
  ConstantDecl -> Ident '=' ConstExpr [DIRECTIVE/..]

               -> Ident ':' TypeId '=' TypedConstant
  FIXED:       -> Ident ':' Type '=' TypedConstant [DIRECTIVE/..]
}
procedure TCnProgramBlockFormater.FormatConstantDecl(PreSpaceCount: Byte);
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
    Error(' = or : is needed'); 
  end;

  while Scaner.Token in DirectiveTokens do
    FormatDirective;
end;

{
  ConstSection -> CONST (ConstantDecl ';')...
                  RESOURCESTRING (ConstantDecl ';')...

  Note: resourcestring 只支持字符型常量，但格式化时可不考虑而当做普通常量对待
}
procedure TCnProgramBlockFormater.FormatConstSection(PreSpaceCount: Byte);
begin
  if Scaner.Token in [tokKeywordConst, tokKeywordResourcestring] then
    Match(Scaner.Token, PreSpaceCount);

  while Scaner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens + KeywordTokens
   - NOTExpressionTokens do // 这些关键字不宜做变量名但也不好处理，只有先写上
  begin
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
procedure TCnProgramBlockFormater.FormatDeclSection(PreSpaceCount: Byte;
  IndentProcs: Boolean; IsInternal: Boolean);
var
  MakeLine, LastIsInternalProc: Boolean;
begin
  MakeLine := False;
  LastIsInternalProc := False;
  while Scaner.Token in DeclSectionTokens do
  begin
    if MakeLine then
    begin
      if IsInternal then  // 内部的定义只需要空一行
        Writeln
      else
        WriteLine;
    end;

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
              Writeln;
            FormatProcedureDeclSection(Tab(PreSpaceCount));
          end
          else
            FormatProcedureDeclSection(PreSpaceCount);
          if IsInternal then
            Writeln;
          LastIsInternalProc := True;
        end;
    else
      Error('DeclSection is needed.');
    end;
    MakeLine := True;
  end;
end;

{
 ExportsDecl -> Ident [FormalParameters] [':' (SimpleType | STRING)] [Directive]
}
procedure TCnProgramBlockFormater.FormatExportsDecl(PreSpaceCount: Byte);
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
procedure TCnProgramBlockFormater.FormatExportsList(PreSpaceCount: Byte);
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
procedure TCnProgramBlockFormater.FormatExportsSection(PreSpaceCount: Byte);
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

procedure TCnProgramBlockFormater.FormatFunctionDecl(PreSpaceCount: Byte);
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
    Writeln;

  if ((not IsExternal)  and (not IsForward))and
     (Scaner.Token in BlockStmtTokens + DeclSectionTokens) then
  begin
    FormatBlock(PreSpaceCount, True);
    Match(tokSemicolon);
  end;
end;

{ LabelDeclSection -> LABEL LabelId/ ',' .. ';'}
procedure TCnProgramBlockFormater.FormatLabelDeclSection(
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
procedure TCnProgramBlockFormater.FormatLabelID(PreSpaceCount: Byte);
begin
  Match(Scaner.Token, PreSpaceCount);
end;

{
  ProcedureDecl -> ProcedureHeading ';' [(DIRECTIVE ';')...]
                   Block ';'
}
procedure TCnProgramBlockFormater.FormatProcedureDecl(PreSpaceCount: Byte);
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
    Writeln;

  if ((not IsExternal) and (not IsForward)) and
    (Scaner.Token in BlockStmtTokens + DeclSectionTokens) then
  begin
    FormatBlock(PreSpaceCount, True);
    Match(tokSemicolon);
  end;
end;

{
  ProcedureDeclSection -> ProcedureDecl
                       -> FunctionDecl
}
procedure TCnProgramBlockFormater.FormatProcedureDeclSection(
  PreSpaceCount: Byte);
var
  Bookmark: TScannerBookmark;
begin
  Scaner.SaveBookmark(Bookmark);
  if Scaner.Token = tokKeywordClass then
  begin
    Scaner.NextToken;
  end;

  case Scaner.Token of
    tokKeywordProcedure, tokKeywordConstructor, tokKeywordDestructor:
    begin
      Scaner.LoadBookmark(Bookmark);
      FormatProcedureDecl(PreSpaceCount);
    end;

    tokKeywordFunction:
    begin
      Scaner.LoadBookmark(Bookmark);
      FormatFunctionDecl(PreSpaceCount);
    end;
  else
    Error('procedure or function is needed.');
  end;
end;

{
  ProgramBlock -> [UsesClause]
                  Block
}
procedure TCnProgramBlockFormater.FormatProgramBlock(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokKeywordUses then
  begin
    FormatUsesClause(PreSpaceCount, True); // 带 IN 的，需要分行
    WriteLine;
  end;
  FormatBlock(PreSpaceCount);
end;

{ UsesClause -> USES UsesList ';' }
procedure TCnProgramBlockFormater.FormatUsesClause(PreSpaceCount: Byte;
  const NeedCRLF: Boolean);
begin
  Match(tokKeywordUses);

  Writeln;
  FormatUsesList(Tab(PreSpaceCount), True, NeedCRLF);
  Match(tokSemicolon);
end;

{ UsesList -> (UsesDecl ',') ... }
procedure TCnProgramBlockFormater.FormatUsesList(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean; const NeedCRLF: Boolean);
var
  OldWrapMode: TCnCodeWrapMode;
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
      try
        CodeGen.CodeWrapMode := cwmSimple; // uses 要求简单换行
        FormatUsesDecl(0, CanHaveUnitQual);
      finally
        CodeGen.CodeWrapMode := OldWrapMode;
      end;
    end;
  end;
end;

{ UseDecl -> Ident [IN String]}
procedure TCnProgramBlockFormater.FormatUsesDecl(PreSpaceCount: Byte;
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
procedure TCnProgramBlockFormater.FormatVarDecl(PreSpaceCount: Byte);
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
procedure TCnProgramBlockFormater.FormatVarSection(PreSpaceCount: Byte);
begin
  if Scaner.Token in [tokKeywordVar, tokKeywordThreadvar] then
    Match(Scaner.Token, PreSpaceCount);

  while Scaner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens + KeywordTokens
   - NOTExpressionTokens do // 这些关键字不宜做变量名但也不好处理，只有先写上
  begin
    Writeln;
    FormatVarDecl(Tab(PreSpaceCount));
    Match(tokSemicolon);
  end;
end;

procedure TCnExpressionFormater.FormatTypeID(PreSpaceCount: Byte);
begin
  if Scaner.Token in BuiltInTypeTokens then
    Match(Scaner.Token)
  else if Scaner.Token = tokKeywordFile then
    Match(tokKeywordFile)
  else
  begin
    // TODO: 处理 Integer 等的大小写问题
    FormatIdent(0, True);
  end;
end;

{ TCnGoalCodeFormater }

procedure TCnGoalCodeFormater.FormatCode(PreSpaceCount: Byte);
begin
  CheckHeadComments;
  FormatGoal(PreSpaceCount);
end;

{
  ExportedHeading -> ProcedureHeading ';' [(DIRECTIVE ';')...]
                  -> FunctionHeading ';' [(DIRECTIVE ';')...]
}
procedure TCnGoalCodeFormater.FormatExportedHeading(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordProcedure: FormatProcedureHeading(PreSpaceCount);
    tokKeywordFunction: FormatFunctionHeading(PreSpaceCount);
  else
    Error('procedure/function is needed.');
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
procedure TCnGoalCodeFormater.FormatGoal(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordProgram: FormatProgram(PreSpaceCount);
    tokKeywordLibrary: FormatLibrary(PreSpaceCount);
    tokKeywordUnit:    FormatUnit(PreSpaceCount);
  else
    Error('Unknown Goal Ident');
  end;
end;

{
  ImplementationSection -> IMPLEMENTATION
                           [UsesClause]
                           [DeclSection]...
}
procedure TCnGoalCodeFormater.FormatImplementationSection(
  PreSpaceCount: Byte);
begin
  Match(tokKeywordImplementation);

  if Scaner.Token = tokKeywordUses then
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
procedure TCnGoalCodeFormater.FormatInitSection(PreSpaceCount: Byte);
begin
  Match(tokKeywordInitialization);
  Writeln;
  FormatStmtList(Tab);

  if Scaner.Token = tokKeywordFinalization then
  begin
    WriteLine;
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
procedure TCnGoalCodeFormater.FormatInterfaceDecl(PreSpaceCount: Byte);
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
    else
      if not CnPascalCodeForRule.ContinueAfterError then
        Error('Interface declare const, type, var or export keyword exptected.')
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
procedure TCnGoalCodeFormater.FormatInterfaceSection(PreSpaceCount: Byte);
begin
  Match(tokKeywordInterface, PreSpaceCount);

  if Scaner.Token = tokKeywordUses then
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
procedure TCnGoalCodeFormater.FormatLibrary(PreSpaceCount: Byte);
begin
  Match(tokKeywordLibrary);
  FormatIdent(PreSpaceCount);
  while Scaner.Token in DirectiveTokens do
    Match(Scaner.Token);

  Match(tokSemicolon);
  Writeln;

  FormatProgramBlock(PreSpaceCount);
  Match(tokDot);
end;

{
  Program -> [PROGRAM Ident ['(' IdentList ')'] ';']
             ProgramBlock '.'
}
procedure TCnGoalCodeFormater.FormatProgram(PreSpaceCount: Byte);
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
procedure TCnGoalCodeFormater.FormatUnit(PreSpaceCount: Byte);
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
    WriteLine;
  end;

  Match(tokKeywordEnd, PreSpaceCount);
  Match(tokDot);
end;

{ ClassBody -> [ClassHeritage] [ClassMemberList END] }
procedure TCnTypeSectionFormater.FormatClassBody(PreSpaceCount: Byte);
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

procedure TCnTypeSectionFormater.FormatClassField(PreSpaceCount: Byte);
begin
  FormatObjFieldList(PreSpaceCount);
end;

{ ClassMember -> ClassField | ClassMethod | ClassProperty }
procedure TCnTypeSectionFormater.FormatClassMember(PreSpaceCount: Byte);
begin
  // no need loop here, we have one loop outter
  if Scaner.Token in ClassMemberSymbolTokens then // 部分关键字此处可以当做 Symbol
  begin
    case Scaner.Token of
      tokKeywordProcedure, tokKeywordFunction, tokKeywordConstructor,
      tokKeywordDestructor, tokKeywordClass:
        FormatClassMethod(PreSpaceCount);

      tokKeywordProperty:
        FormatClassProperty(PreSpaceCount);
    else // 其他的都算 symbol
      FormatClassField(PreSpaceCount);
    end;

    Writeln;
  end;
end;

{ ClassMemberList -> ([ClassVisibility] [ClassMember]) ... }
procedure TCnTypeSectionFormater.FormatClassMemberList(
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
procedure TCnTypeSectionFormater.FormatClassMethod(PreSpaceCount: Byte);
var
  IsFirst: Boolean;
begin
  if Scaner.Token = tokKeywordClass then
  begin
    Match(tokKeywordClass, PreSpaceCount);
    FormatMethodHeading;
  end else
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
procedure TCnTypeSectionFormater.FormatClassProperty(PreSpaceCount: Byte);
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

{ procedure/function/constructor/destructor Name, can be classname.name}
procedure TCnTypeSectionFormater.FormatMethodName(PreSpaceCount: Byte);
begin
  FormatTypeParamIdent;
  // 加入对泛型的支持
  if Scaner.Token = tokDot then
  begin
    Match(tokDot);
    FormatTypeParamIdent;
  end;  
end;

end.
