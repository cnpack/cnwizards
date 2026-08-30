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

unit CnCppCodeFormatter;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：C/C++ 代码格式化器
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Windows, CnCppToken, CnCppScanner, CnCppCodeGenerator,
  CnCodeFormatRules, CnParseConsts, CnFormatterIntf;

const
  CN_CPP_MATCHED_INVALID = -1;

type
  ECnCppFormatError = class(Exception);

  TCnCppCodeFormatter = class
  private
    FScanner: TCnCppScanner;
    FCodeGen: TCnCppCodeGenerator;
    FRule: TCnCppCodeFormatRule;
    FTokens: TList;
    FIgnore: Boolean;
    FIgnoreRawPos: Integer;
    FInputLineMarks: TList;
    FOutputLineMarks: TList;
    FAsmDepth: Integer;
    FAsmLineStart: Boolean;
    FAsmAfterKeyword: Boolean;
    FAsmKeywordLength: Integer;
    FParenDepth: Integer;
    FBracketDepth: Integer;
    FTemplateDepth: Integer;
    FPrevTemplateClose: Boolean;
    FBraceDepth: Integer;
    FParenOpenTokens: TList;
    FBracketOpenTokens: TList;
    FTemplateOpenTokens: TList;
    FBraceOpenTokens: TList;
    FStructureOpenTokens: TList;
    FAsmOpenToken: TCnCppToken;
    FBraceDeclStack: array of Boolean;
    FBraceTypeStack: array of Boolean;
    FBraceStackCount: Integer;
    FLastClosedBraceIsType: Boolean;
    FBlankLinePending: Boolean;
    FAtLineStart: Boolean;
    FPrev: TCnCppToken;
    FCurrentToken: TCnCppToken;
    FSliceMode: Boolean;
    FMatchedInStart: Integer;
    FMatchedInEnd: Integer;
    FMatchedOutStartRow: Integer;
    FMatchedOutStartCol: Integer;
    FMatchedOutEndRow: Integer;
    FMatchedOutEndCol: Integer;
    FFirstMatchStart: Boolean;
    FFirstMatchEnd: Boolean;
    function TokenAt(Index: Integer): TCnCppToken;
    function IsWordLike(Token: TCnCppToken): Boolean;
    function IsUnary(Token: TCnCppToken): Boolean;
    function IsPointerOperator(Token: TCnCppToken): Boolean;
    function IsAddressOperator(Token: TCnCppToken): Boolean;
    function IsAccessSpecifier(TokenIndex: Integer): Boolean;
    function IsTernaryColon(TokenIndex: Integer): Boolean;
    function IsTemplateOpen(TokenIndex: Integer): Boolean;
    procedure WriteText(const S: string);
    procedure WriteIgnoredSource(StartPos, EndPos: Integer);
    procedure EnsureLine;
    procedure EnsureSpace;
    procedure WriteNewLine;
    procedure WriteComment(Token: TCnCppToken);
    procedure WriteOperator(Token: TCnCppToken);
    procedure WriteBrace(Token: TCnCppToken; IsOpen: Boolean);
    procedure FormatAsmToken(Token: TCnCppToken);
    procedure TryAutoWrap;
    function IsDeclarationBrace(TokenIndex: Integer): Boolean;
    function IsTypeDeclarationBrace(TokenIndex: Integer): Boolean;
    procedure PushBrace(IsDeclaration, IsTypeDeclaration: Boolean);
    function PopBrace: Boolean;
    procedure FlushPendingBlankLine(Token: TCnCppToken);
    procedure RaiseMismatch(Code: Integer; Token: TCnCppToken);
    procedure CheckUnclosedStructures;
    procedure FormatTokens;
    procedure CodeGenAfterWrite(Sender: TObject; IsWriteBlank, IsWriteln:
      Boolean; PrefixSpaces: Integer);
  protected
    function CurrentColumn: Integer;
  public
    constructor Create(Stream: TStream; const Rule: TCnCppCodeFormatRule;
      AMatchedInStart: Integer = CN_CPP_MATCHED_INVALID;
      AMatchedInEnd: Integer = CN_CPP_MATCHED_INVALID);
    destructor Destroy; override;
    procedure FormatCode;
    procedure SpecifyLineMarks(Marks: PDWORD);
    procedure SaveOutputLineMarks(var Marks: PDWORD);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToStrings(Strings: TStrings);
    function ResultText: string;
    function HasSliceResult: Boolean;
    function CopyMatchedSliceResult: string;
    property Rule: TCnCppCodeFormatRule read FRule write FRule;
    property SliceMode: Boolean read FSliceMode write FSliceMode;
    property MatchedInStart: Integer read FMatchedInStart write FMatchedInStart;
    property MatchedInEnd: Integer read FMatchedInEnd write FMatchedInEnd;
    property MatchedOutStartRow: Integer read FMatchedOutStartRow;
    property MatchedOutStartCol: Integer read FMatchedOutStartCol;
    property MatchedOutEndRow: Integer read FMatchedOutEndRow;
    property MatchedOutEndCol: Integer read FMatchedOutEndCol;
  end;

function CnFormatCppText(const Source: string; const Rule: TCnCppCodeFormatRule): string;

implementation

procedure SetCppError(Code: Integer; Token: TCnCppToken);
begin
  CppErrorRec.ErrorCode := Code;
  if Token <> nil then
  begin
    CppErrorRec.SourceLine := Token.Line;
    CppErrorRec.SourceCol := Token.Column;
    CppErrorRec.SourcePos := Token.Position;
    CppErrorRec.CurrentToken := Token.Text;
  end;
end;

procedure SetCppScanError(Code: Integer; Error: ECnCppScannerError);
begin
  CppErrorRec.ErrorCode := Code;
  CppErrorRec.SourceLine := Error.SourceLine;
  CppErrorRec.SourceCol := Error.SourceCol;
  CppErrorRec.SourcePos := Error.SourcePos;
  CppErrorRec.CurrentToken := Error.CurrentToken;
end;

constructor TCnCppCodeFormatter.Create(Stream: TStream; const Rule:
  TCnCppCodeFormatRule; AMatchedInStart, AMatchedInEnd: Integer);
begin
  inherited Create;
  FRule := Rule;
  FMatchedInStart := AMatchedInStart;
  FMatchedInEnd := AMatchedInEnd;
  FMatchedOutStartRow := CN_CPP_MATCHED_INVALID;
  FMatchedOutStartCol := CN_CPP_MATCHED_INVALID;
  FMatchedOutEndRow := CN_CPP_MATCHED_INVALID;
  FMatchedOutEndCol := CN_CPP_MATCHED_INVALID;
  FScanner := TCnCppScanner.Create(Stream);
  FCodeGen := TCnCppCodeGenerator.Create;
  FCodeGen.TabWidth := Rule.TabSpaceCount;
  FCodeGen.OnAfterWrite := CodeGenAfterWrite;
  FTokens := TList.Create;
  FParenOpenTokens := TList.Create;
  FBracketOpenTokens := TList.Create;
  FTemplateOpenTokens := TList.Create;
  FBraceOpenTokens := TList.Create;
  FStructureOpenTokens := TList.Create;
  FInputLineMarks := nil;
  FOutputLineMarks := nil;
  FAtLineStart := True;
end;

procedure TCnCppCodeFormatter.CodeGenAfterWrite(Sender: TObject; IsWriteBlank,
  IsWriteln: Boolean; PrefixSpaces: Integer);
var
  StartPos, EndPos, I: Integer;
begin
  if not IsWriteBlank and not IsWriteln and (FInputLineMarks <> nil) and (FCurrentToken
    <> nil) then
  begin
    for I := 0 to FInputLineMarks.Count - 1 do
      if (FCurrentToken.Line >= Integer(FInputLineMarks[I])) and (Integer(FOutputLineMarks
        [I]) = 0) then
        FOutputLineMarks[I] := Pointer(TCnCppCodeGenerator(Sender).CurrRow + 1);
  end;

  if not FSliceMode or (FCurrentToken = nil) or (FMatchedInStart =
    CN_CPP_MATCHED_INVALID) or (FMatchedInEnd = CN_CPP_MATCHED_INVALID) then
    Exit;

  StartPos := FCurrentToken.Position;
  EndPos := StartPos + Length(FCurrentToken.Text);

  if (StartPos >= FMatchedInStart) and not IsWriteln and not IsWriteBlank and
    not FFirstMatchStart then
  begin
    FMatchedOutStartRow := TCnCppCodeGenerator(Sender).PrevRow;
    FMatchedOutStartCol := TCnCppCodeGenerator(Sender).PrevColumn - PrefixSpaces;
    if FMatchedOutStartCol < 0 then
      FMatchedOutStartCol := 0;
    FFirstMatchStart := True;
  end
  else if (EndPos >= FMatchedInEnd) and IsWriteln and not FFirstMatchEnd then
  begin
    FMatchedOutEndRow := TCnCppCodeGenerator(Sender).CurrRow;
    FMatchedOutEndCol := TCnCppCodeGenerator(Sender).CurrColumn;
    FFirstMatchEnd := True;
  end;
end;

destructor TCnCppCodeFormatter.Destroy;
var
  I: Integer;
begin
  for I := 0 to FTokens.Count - 1 do
    TObject(FTokens[I]).Free;

  FTokens.Free;
  FParenOpenTokens.Free;
  FBracketOpenTokens.Free;
  FTemplateOpenTokens.Free;
  FBraceOpenTokens.Free;
  FStructureOpenTokens.Free;
  FCodeGen.Free;
  FScanner.Free;
  FOutputLineMarks.Free;
  FInputLineMarks.Free;
  inherited;
end;

procedure TCnCppCodeFormatter.SpecifyLineMarks(Marks: PDWORD);
var
  M: PDWORD;
begin
  FreeAndNil(FInputLineMarks);
  FreeAndNil(FOutputLineMarks);
  if (Marks = nil) or (Marks^ = 0) then
    Exit;

  FInputLineMarks := TList.Create;
  FOutputLineMarks := TList.Create;
  M := Marks;
  while M^ <> 0 do
  begin
    FInputLineMarks.Add(Pointer(M^));
    FOutputLineMarks.Add(nil);
    Inc(M);
  end;
end;

procedure TCnCppCodeFormatter.SaveOutputLineMarks(var Marks: PDWORD);
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

function TCnCppCodeFormatter.TokenAt(Index: Integer): TCnCppToken;
begin
  if (Index >= 0) and (Index < FTokens.Count) then
    Result := TCnCppToken(FTokens[Index])
  else
    Result := nil;
end;

function TCnCppCodeFormatter.IsWordLike(Token: TCnCppToken): Boolean;
begin
  Result := CnCppIsWordToken(Token);
end;

function TCnCppCodeFormatter.IsUnary(Token: TCnCppToken): Boolean;
begin
  Result := (Token <> nil) and ((Token.Text = '!') or (Token.Text = '~') or (Token.Text
    = '++') or (Token.Text = '--') or (((Token.Text = '+') or (Token.Text = '-'))
    and ((FPrev = nil) or (FPrev.Kind in [ctkOperator, ctkSymbol]))));
end;

function TCnCppCodeFormatter.IsPointerOperator(Token: TCnCppToken): Boolean;
var
  I, J, RunStart, RunEnd, WordCount: Integer;
  Prev, Next, AfterNext, T: TCnCppToken;
  HasDeclarationKeyword, AtStatementStart: Boolean;

  function IsDeclarationKeyword(const S: string): Boolean;
  begin
    { 这些是语法关键字，而不是用户自定义类型名称列表。 }
    Result := SameText(S, 'const') or SameText(S, 'volatile') or SameText(S,
      'static') or SameText(S, 'extern') or SameText(S, 'register') or SameText(S,
      'mutable') or SameText(S, 'constexpr') or SameText(S, 'inline') or
      SameText(S, 'virtual') or SameText(S, 'friend') or SameText(S, 'typedef')
      or SameText(S, 'using') or SameText(S, 'typename') or SameText(S, 'class')
      or SameText(S, 'struct') or SameText(S, 'union') or SameText(S, 'enum');
  end;

  function IsExpressionBoundary(const S: string): Boolean;
  begin
    Result := (S = ';') or (S = '{') or (S = '}') or (S = '=') or (S = '(') or (S
      = ')') or (S = '[') or (S = '+') or (S = '-') or (S = '/') or (S = '%') or
      (S = '&') or (S = '|') or (S = '!') or (S = '?') or (S = ':') or SameText(S,
      'return') or SameText(S, 'if') or SameText(S, 'for') or SameText(S,
      'while') or SameText(S, 'case');
  end;

begin
  Result := False;
  if (Token = nil) or (Token.Text <> '*') then
    Exit;

  I := FTokens.IndexOf(Token);
  Prev := TokenAt(I - 1);
  Next := TokenAt(I + 1);
  AfterNext := TokenAt(I + 2);

  { 类型转换或声明符中的星号后面通常紧跟闭合分隔符、声明符分隔符或赋值号。 }
  if (Next <> nil) and ((Next.Text = ')') or (Next.Text = ']') or (Next.Text =
    ';') or (Next.Text = ',') or (Next.Text = '=')) then
  begin
    Result := True;
    Exit;
  end;

  { 前缀运算符、解引用以及重载的 operator* 都不是二元乘法运算。 }
  if (Prev = nil) or (Prev.Text = '(') or (Prev.Text = '[') or (Prev.Text = ',')
    or (Prev.Text = ':') or (Prev.Text = '=') or (Prev.Text = '{') or (Prev.Text
    = '}') or (Prev.Text = ';') or SameText(Prev.Text, 'return') or SameText(Prev.Text,
    'operator') then
  begin
    Result := True;
    Exit;
  end;

  { 多级指针声明符包含连续的星号。检查整个星号序列，并对最后的名称应用声明形式判断。 }
  if ((Prev <> nil) and (Prev.Text = '*')) or ((Next <> nil) and (Next.Text = '*')) then
  begin
    RunStart := I;
    while (TokenAt(RunStart - 1) <> nil) and (TokenAt(RunStart - 1).Text = '*') do
      Dec(RunStart);
    RunEnd := I + 1;
    while (TokenAt(RunEnd) <> nil) and (TokenAt(RunEnd).Text = '*') do
      Inc(RunEnd);
    T := TokenAt(RunEnd);
    AfterNext := TokenAt(RunEnd + 1);
    if (T <> nil) and (T.Kind = ctkIdentifier) and (AfterNext <> nil) and ((AfterNext.Text
      = ';') or (AfterNext.Text = ',') or (AfterNext.Text = '=') or (AfterNext.Text
      = ')') or (AfterNext.Text = ']') or (AfterNext.Text = '(') or (AfterNext.Text
      = '[')) then
    begin
      { 指针序列前紧邻的类型或名称，使用与单星号判断相同的声明上下文。 }
      if (TokenAt(RunStart - 1) <> nil) and IsWordLike(TokenAt(RunStart - 1)) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  WordCount := 0;
  HasDeclarationKeyword := False;
  AtStatementStart := True;
  J := I - 1;
  while J >= 0 do
  begin
    T := TokenAt(J);
    if T = nil then
      Break;
    if IsExpressionBoundary(T.Text) then
    begin
      AtStatementStart := (T.Text = ';') or (T.Text = '{') or (T.Text = '}');
      Break;
    end;
    if (T.Kind = ctkIdentifier) then
    begin
      Inc(WordCount);
      if IsDeclarationKeyword(T.Text) then
        HasDeclarationKeyword := True;
    end;
    if (T.Text = '>') or (T.Text = ']') or (T.Text = '::') then
      HasDeclarationKeyword := True;
    Dec(J);
  end;

  { 多个连续的声明符单词（例如 "const T" 或 "unsigned char16_t"）
    可以在不识别具体 T 类型名称的情况下确定这是声明。 }
  if HasDeclarationKeyword or (WordCount >= 2) then
  begin
    Result := True;
    Exit;
  end;

  { 对于单个用户自定义类型，C++ 的词法本身存在歧义（"T *p" 与 "a *b"
    具有相同的记号语法）。只有当它位于语句开头且后续记号形态类似声明符时，
    才将其视为声明；赋值号或运算符后的表达式已经在上面的边界扫描中排除。 }
  if (WordCount = 1) and AtStatementStart and (Next <> nil) and (Next.Kind =
    ctkIdentifier) and (AfterNext <> nil) and ((AfterNext.Text = ';') or (AfterNext.Text
    = '=') or (AfterNext.Text = ',') or (AfterNext.Text = '(') or (AfterNext.Text
    = '[')) then
    Result := True;
end;

function TCnCppCodeFormatter.IsAddressOperator(Token: TCnCppToken): Boolean;
var
  I, J, WordCount: Integer;
  Prev, Next, AfterNext, T: TCnCppToken;
  HasDeclarationKeyword, AtStatementStart: Boolean;

  function IsDeclarationKeyword(const S: string): Boolean;
  begin
    Result := SameText(S, 'const') or SameText(S, 'volatile') or SameText(S,
      'static') or SameText(S, 'extern') or SameText(S, 'register') or SameText(S,
      'mutable') or SameText(S, 'constexpr') or SameText(S, 'inline') or
      SameText(S, 'virtual') or SameText(S, 'friend') or SameText(S, 'typedef')
      or SameText(S, 'using') or SameText(S, 'typename') or SameText(S, 'class')
      or SameText(S, 'struct') or SameText(S, 'union') or SameText(S, 'enum') or
      SameText(S, 'auto');
  end;

  function IsExpressionBoundary(const S: string): Boolean;
  begin
    Result := (S = ';') or (S = '{') or (S = '}') or (S = '=') or (S = '(') or (S
      = ')') or (S = '[') or (S = '+') or (S = '-') or (S = '/') or (S = '%') or
      (S = '|') or (S = '!') or (S = '?') or (S = ':') or SameText(S, 'return')
      or SameText(S, 'if') or SameText(S, 'for') or SameText(S, 'while') or
      SameText(S, 'case');
  end;

begin
  Result := False;
  if (Token = nil) or (Token.Text <> '&') then
    Exit;

  I := FTokens.IndexOf(Token);
  Prev := TokenAt(I - 1);
  Next := TokenAt(I + 1);
  AfterNext := TokenAt(I + 2);

  { 前缀取地址运算，包括 "= &value" 和 "return &value" 等表达式。 }
  if (Prev = nil) or (Prev.Text = '(') or (Prev.Text = '[') or (Prev.Text = ',')
    or (Prev.Text = ':') or (Prev.Text = '=') or SameText(Prev.Text, 'return') then
  begin
    Result := True;
    Exit;
  end;

  { 引用声明符的 '&' 前存在声明说明符上下文。这里特意不依赖用户自定义类型名称列表。 }
  WordCount := 0;
  HasDeclarationKeyword := False;
  AtStatementStart := True;
  J := I - 1;
  while J >= 0 do
  begin
    T := TokenAt(J);
    if T = nil then
      Break;
    if IsExpressionBoundary(T.Text) then
    begin
      AtStatementStart := (T.Text = ';') or (T.Text = '{') or (T.Text = '}');
      Break;
    end;

    if T.Kind = ctkIdentifier then
    begin
      Inc(WordCount);
      if IsDeclarationKeyword(T.Text) then
        HasDeclarationKeyword := True;
    end;
    if (T.Text = '>') or (T.Text = ']') or (T.Text = '::') then
      HasDeclarationKeyword := True;
    Dec(J);
  end;

  Result := HasDeclarationKeyword or (WordCount >= 2);
  { 单个用户自定义类型后跟引用名称和初始化表达式时，可以明确判断为声明；
    避免把 "a & b;" 这样的普通表达式误判为引用声明符。 }
  if not Result and (WordCount = 1) and AtStatementStart and (Next <> nil) and (Next.Kind
    = ctkIdentifier) and (AfterNext <> nil) and (AfterNext.Text = '=') then
    Result := True;
end;

function TCnCppCodeFormatter.IsTernaryColon(TokenIndex: Integer): Boolean;
var
  J, Depth: Integer;
  T: TCnCppToken;
begin
  Result := False;
  Depth := 0;
  J := TokenIndex - 1;
  while J >= 0 do
  begin
    T := TokenAt(J);
    if T = nil then
      Break;

    if (T.Text = ')') or (T.Text = ']') then
      Inc(Depth)
    else if (T.Text = '(') or (T.Text = '[') then
    begin
      if Depth > 0 then
        Dec(Depth)
      else
        Break;
    end
    else if Depth = 0 then
    begin
      if T.Text = '?' then
      begin
        Result := True;
        Exit;
      end;

      if (T.Text = ';') or (T.Text = '{') or (T.Text = '}') or (T.Text = '=') or
        (T.Text = ',') then
        Break;
    end;
    Dec(J);
  end;
end;

function TCnCppCodeFormatter.IsTemplateOpen(TokenIndex: Integer): Boolean;
var
  Prev, BeforePrev, T: TCnCppToken;
  J, Depth: Integer;
  Name: string;
  StrongCandidate: Boolean;
begin
  Result := False;
  StrongCandidate := False;
  Prev := TokenAt(TokenIndex - 1);
  if Prev = nil then
    Exit;

  { 模板参数列表跟在名称（通常带有 :: 限定）或另一个模板的右尖括号之后。
    下面列出的常见类型名称也覆盖 vector<int> 这样的非限定 STL 声明。 }
  if (Prev.Text = '>') or (FTemplateDepth > 0) then
  begin
    Result := True;
    StrongCandidate := True;
  end
  else if Prev.Kind = ctkIdentifier then
  begin
    Name := Prev.Text;
    if SameText(Name, 'operator') then
      Exit;
    if SameText(Name, 'template') then
    begin
      Result := True;
      StrongCandidate := True;
    end;

    BeforePrev := TokenAt(TokenIndex - 2);
    if not Result then
      Result := (BeforePrev <> nil) and (BeforePrev.Text = '::');

    if not Result then
      Result := (Name = 'vector') or (Name = 'map') or (Name = 'set') or (Name =
        'list') or (Name = 'deque') or (Name = 'array') or (Name = 'tuple') or (Name
        = 'pair') or (Name = 'optional') or (Name = 'variant') or (Name =
        'string') or (Name = 'wstring') or (Name = 'unique_ptr') or (Name =
        'shared_ptr') or (Name = 'weak_ptr') or (Name = 'make_shared') or (Name
        = 'make_unique') or (Name = 'enable_if') or (Name = 'conditional') or (Name
        = 'remove_reference') or (Name = 'RemoveReferenceT') or (Name =
        'FixedArray') or (Name = 'Traits') or (Name = 'Factorial') or (Name =
        'MaxValue') or (Name = 'decltype') or (Name = 'static_cast') or (Name =
        'dynamic_cast') or (Name = 'reinterpret_cast') or (Name = 'const_cast');

    if Result and ((BeforePrev = nil) or (BeforePrev.Text <> '::')) then
      StrongCandidate := True;

    { std::vector 这样的已知限定模板也属于可靠的模板候选。 }
    if Result and ((Name = 'vector') or (Name = 'map') or (Name = 'set') or (Name
      = 'list') or (Name = 'deque') or (Name = 'array') or (Name = 'tuple') or (Name
      = 'pair') or (Name = 'optional') or (Name = 'variant') or (Name =
      'unique_ptr') or (Name = 'shared_ptr') or (Name = 'weak_ptr')) then
      StrongCandidate := True;
  end;
  if not Result then
    Exit;

  { 要求在语句边界前找到匹配的右尖括号，避免把 a < b 这样的普通表达式当作模板。 }
  Depth := 1;
  J := TokenIndex + 1;
  while True do
  begin
    T := TokenAt(J);
    if T = nil then
    begin
      Result := StrongCandidate;
      Exit
    end;

    if T.Kind = ctkEOF then
    begin
      Result := StrongCandidate;
      Exit
    end;

    if T.Text = '<' then
      Inc(Depth)
    else if T.Text = '>' then
      Dec(Depth)
    else if T.Text = '>>' then
      Dec(Depth, 2);
    if Depth <= 0 then
      Exit;

    if (Depth = 1) and ((T.Text = ';') or (T.Text = '{') or (T.Text = '}') or (T.Text
      = ':')) then
    begin
      Result := StrongCandidate;
      Exit;
    end;
    Inc(J);
  end;
end;

function TCnCppCodeFormatter.CurrentColumn: Integer;
begin
  Result := FCodeGen.CurrentLineLength;
end;

function TCnCppCodeFormatter.IsDeclarationBrace(TokenIndex: Integer): Boolean;
var
  J, ParenDepth: Integer;
  T: TCnCppToken;
  SawParen: Boolean;
begin
  Result := False;
  if TokenIndex <= 0 then
    Exit;

  { 括号声明符后的大括号通常是函数体。这里明确排除控制语句；
    这也覆盖尾置返回类型和 noexcept 子句，因为大括号前的记号不一定是右括号。 }
  ParenDepth := 0;
  SawParen := False;
  J := TokenIndex - 1;
  while J >= 0 do
  begin
    T := TokenAt(J);
    if T = nil then
      Break;
    if (ParenDepth = 0) and ((T.Text = '{') or (T.Text = '}')) then
      Break;

    if T.Text = ')' then
      Inc(ParenDepth)
    else if T.Text = '(' then
    begin
      if ParenDepth > 0 then
        Dec(ParenDepth)
      else
        Break;
      if ParenDepth = 0 then
        SawParen := True;
    end;

    if (ParenDepth = 0) and (T.Text = ';') then
      Break;
    if (ParenDepth = 0) and (T.Text = '=') then
      Break;
    if (ParenDepth = 0) and (T.Text = ':') then
      Break;

    if SawParen and (ParenDepth = 0) and (T.Kind = ctkIdentifier) and ((T.Text =
      'if') or (T.Text = 'for') or (T.Text = 'while') or (T.Text = 'switch') or
      (T.Text = 'catch') or (T.Text = 'with')) then
      Exit;

    if SawParen and (ParenDepth = 0) and (T.Text = ']') then
      Exit; { Lambda 表达式的函数体 }
    Dec(J);
  end;

  if SawParen then
  begin
    Result := True;
    Exit;
  end;

  { class、struct、union、enum、namespace 的主体。遇到声明边界时停止，
    避免把带大括号的初始化器误认为声明主体。 }
  J := TokenIndex - 1;
  while J >= 0 do
  begin
    T := TokenAt(J);
    if T = nil then
      Break;
    if T.Text = '=' then
      Exit;
    if T.Text = ';' then
      Break;
    if T.Text = '}' then
      Break;
    if T.Text = '{' then
      Break;

    if (T.Kind = ctkIdentifier) and ((T.Text = 'class') or (T.Text = 'struct')
      or (T.Text = 'union') or (T.Text = 'namespace') or (T.Text = 'enum') or (T.Text
      = '__interface') or (T.Text = '__dispinterface')) then
    begin
      Result := True;
      Exit;
    end;
    Dec(J);
  end;
end;

function TCnCppCodeFormatter.IsTypeDeclarationBrace(TokenIndex: Integer): Boolean;
var
  J: Integer;
  T: TCnCppToken;
begin
  Result := False;
  J := TokenIndex - 1;
  while J >= 0 do
  begin
    T := TokenAt(J);
    if T = nil then
      Break;

    if (T.Text = '=') or (T.Text = ';') or (T.Text = '{') or (T.Text = '}') then
      Break;
    if (T.Kind = ctkIdentifier) and ((T.Text = 'class') or (T.Text = 'struct')
      or (T.Text = 'union') or (T.Text = 'namespace') or (T.Text = 'enum') or (T.Text
      = '__interface') or (T.Text = '__dispinterface')) then
    begin
      Result := True;
      Exit;
    end;
    Dec(J);
  end;
end;

function TCnCppCodeFormatter.IsAccessSpecifier(TokenIndex: Integer): Boolean;
var
  T, N: TCnCppToken;
begin
  Result := False;
  { 访问标签只有在类式主体内部才有此含义。这样可以避免把类型外部的普通
    C/C++ 标签（例如 "public:"）误减小缩进。 }
  if (FBraceStackCount = 0) or not FBraceTypeStack[FBraceStackCount - 1] then
    Exit;

  T := TokenAt(TokenIndex);
  if (T = nil) or (T.Kind <> ctkIdentifier) then
    Exit;

  if not ((T.Text = 'private') or (T.Text = 'protected') or (T.Text = 'public')
    or (T.Text = '__published') or (T.Text = '__automated') or (T.Text =
    '_automated')) then
    Exit;

  N := TokenAt(TokenIndex + 1);
  Result := (N <> nil) and (N.Text = ':');
end;

procedure TCnCppCodeFormatter.PushBrace(IsDeclaration, IsTypeDeclaration: Boolean);
begin
  if FBraceStackCount >= Length(FBraceDeclStack) then
  begin
    SetLength(FBraceDeclStack, FBraceStackCount + 16);
    SetLength(FBraceTypeStack, FBraceStackCount + 16);
  end;

  FBraceDeclStack[FBraceStackCount] := IsDeclaration;
  FBraceTypeStack[FBraceStackCount] := IsTypeDeclaration;
  Inc(FBraceStackCount);
end;

function TCnCppCodeFormatter.PopBrace: Boolean;
begin
  Result := False;
  FLastClosedBraceIsType := False;

  if FBraceStackCount > 0 then
  begin
    Dec(FBraceStackCount);
    Result := FBraceDeclStack[FBraceStackCount];
    FLastClosedBraceIsType := FBraceTypeStack[FBraceStackCount];
  end;
end;

procedure TCnCppCodeFormatter.FlushPendingBlankLine(Token: TCnCppToken);
var
  SavedToken: TCnCppToken;
begin
  if not FBlankLinePending then
    Exit;

  if (Token <> nil) and (Token.Kind = ctkPreprocessor) then
  begin
    FBlankLinePending := False;
    Exit;
  end;

  { 让标点和结构性延续内容紧跟右大括号（分号、else、while 以及外层右大括号）。 }
  if (Token = nil) or (Token.Kind in [ctkEOF, ctkNewLine, ctkPreprocessor]) or (Token.Text
    = ';') or (Token.Text = ',') or (Token.Text = ')') or (Token.Text = ']') or
    (Token.Text = '}') or (Token.Text = 'else') or (Token.Text = 'catch') or (Token.Text
    = 'while') then
    Exit;

  if not FAtLineStart then
    WriteNewLine;

  { 这是格式化器生成的行，并不属于当前源代码记号；不要让代码片段坐标跟踪记录它。 }
  SavedToken := FCurrentToken;
  FCurrentToken := nil;
  FCodeGen.NewLine;
  FCurrentToken := SavedToken;
  FAtLineStart := True;
  FBlankLinePending := False;
end;

procedure TCnCppCodeFormatter.WriteText(const S: string);
begin
  FCodeGen.Write(S);
  if S <> '' then
    FAtLineStart := False;
end;

procedure TCnCppCodeFormatter.WriteIgnoredSource(StartPos, EndPos: Integer);
var
  S: string;
  SavedToken: TCnCppToken;
  I, SourceStartLine, SourceEndLine, OutputStartLine: Integer;
begin
  if StartPos < 1 then
    StartPos := 1;
  if EndPos < StartPos then
    Exit;
  S := Copy(FScanner.Source, StartPos, EndPos - StartPos + 1);
  if S = '' then
    Exit;

  { 通过保留源代码与输出代码的行偏移，为忽略区域分配行标记。
    原样输出时，普通回调没有当前记号可供使用。 }
  if FInputLineMarks <> nil then
  begin
    SourceStartLine := 1;
    for I := 1 to StartPos - 1 do
      if FScanner.Source[I] = #10 then
        Inc(SourceStartLine);
    SourceEndLine := SourceStartLine;
    for I := StartPos to EndPos do
      if FScanner.Source[I] = #10 then
        Inc(SourceEndLine);
    OutputStartLine := FCodeGen.CurrRow + 1;
    for I := 0 to FInputLineMarks.Count - 1 do
      if (Integer(FOutputLineMarks[I]) = 0) and (Integer(FInputLineMarks[I]) >=
        SourceStartLine) and (Integer(FInputLineMarks[I]) <= SourceEndLine) then
        FOutputLineMarks[I] := Pointer(OutputStartLine + Integer(FInputLineMarks
          [I]) - SourceStartLine);
  end;

  { 忽略区域的原始文本不能影响匹配代码片段的坐标。 }
  SavedToken := FCurrentToken;
  FCurrentToken := nil;
  FCodeGen.Write(S);
  FCurrentToken := SavedToken;

  FAtLineStart := S[Length(S)] in [#10, #13];
end;

procedure TCnCppCodeFormatter.EnsureLine;
begin
  if not FAtLineStart then
    WriteNewLine;
end;

procedure TCnCppCodeFormatter.EnsureSpace;
begin
  if not FAtLineStart then
    FCodeGen.Space(1);
end;

procedure TCnCppCodeFormatter.WriteNewLine;
begin
  FCodeGen.TrimLine;
  FCodeGen.NewLine;
  FAtLineStart := True;
end;

procedure TCnCppCodeFormatter.WriteComment(Token: TCnCppToken);
var
  S: string;
  WasLineStart: Boolean;
begin
  if Token.Kind = ctkLineComment then
  begin
    if Pos('clang-format off', LowerCase(Token.Text)) > 0 then
    begin
      FIgnore := FRule.UseIgnoreArea;
      if FIgnore then
        FIgnoreRawPos := Token.Position + Length(Token.Text) + 1;
    end;
    if Pos('clang-format on', LowerCase(Token.Text)) > 0 then
      FIgnore := False;

    EnsureSpace;
    if FIgnore then
      WriteText(Token.Text)
    else
    begin
      WriteText(TrimRight(Token.Text));
      WriteNewLine;
    end;
  end
  else
  begin
    S := Token.Text;
    WasLineStart := FAtLineStart;
    if Pos('clang-format off', LowerCase(S)) > 0 then
    begin
      FIgnore := FRule.UseIgnoreArea;
      if FIgnore then
        FIgnoreRawPos := Token.Position + Length(Token.Text) + 1;
    end;

    if Pos('clang-format on', LowerCase(S)) > 0 then
      FIgnore := False;
    EnsureSpace;

    WriteText(S);
    if not (FIgnore and (Pos('clang-format off', LowerCase(S)) > 0)) then
    begin
      if (Pos(#10, S) > 0) or WasLineStart then
        WriteNewLine
      else
        EnsureSpace;
    end;
  end;
end;

procedure TCnCppCodeFormatter.WriteOperator(Token: TCnCppToken);
var
  S: string;
begin
  S := Token.Text;
  if IsPointerOperator(Token) or IsAddressOperator(Token) then
  begin
    if (FPrev <> nil) and IsWordLike(FPrev) and not SameText(FPrev.Text, 'operator') then
      EnsureSpace;
    WriteText(S);
  end
  else if IsUnary(Token) then
  begin
    if (S = '++') or (S = '--') then
      WriteText(S)
    else if (S = '+') or (S = '-') then
      WriteText(S)
    else
    begin
      EnsureSpace;
      WriteText(S);
    end;
  end
  else if S = '?' then
  begin
    if not FAtLineStart then
      FCodeGen.Space(1);
    WriteText(S);
    FCodeGen.Space(1);
  end
  else if CnCppIsBinaryOperator(S) then
  begin
    if not FAtLineStart then
      FCodeGen.Space(FRule.SpaceBeforeBinaryOperator);
    WriteText(S);
    FCodeGen.Space(FRule.SpaceAfterBinaryOperator);
  end
  else
  begin
    if (S = '::') or (S = '->') or (S = '.') then
      FCodeGen.TrimLine;
    WriteText(S);
  end;
end;

procedure TCnCppCodeFormatter.WriteBrace(Token: TCnCppToken; IsOpen: Boolean);
var
  NextToken: TCnCppToken;
begin
  if IsOpen then
  begin
    if FRule.BraceStyle = cbsNextLine then
      EnsureLine
    else
      EnsureSpace;
    WriteText('{');
    Inc(FBraceDepth);
    FCodeGen.IncIndent;
    WriteNewLine;
  end
  else
  begin
    FCodeGen.DecIndent;
    Dec(FBraceDepth);
    EnsureLine;
    WriteText('}');

    NextToken := TokenAt(FTokens.IndexOf(Token) + 1);
    if (NextToken = nil) or not ((NextToken.Text = ';') or (NextToken.Text = ',')
      or (NextToken.Text = ')') or (NextToken.Text = ']') or (NextToken.Text =
      'else') or (NextToken.Text = 'catch') or (NextToken.Text = 'while')) then
      WriteNewLine
    else if not ((NextToken.Text = ';') or (NextToken.Text = ',') or (NextToken.Text
      = ')') or (NextToken.Text = ']') or (NextToken.Text = 'else') or (NextToken.Text
      = 'catch') or (NextToken.Text = 'while')) then
      EnsureSpace;
  end;
end;

procedure TCnCppCodeFormatter.FormatAsmToken(Token: TCnCppToken);
var
  PrefixSpaces, OperandSpaces: Integer;
begin
  if Token.Kind = ctkNewLine then
  begin
    if not FAtLineStart then
      WriteNewLine;
    FAsmLineStart := True;
    FAsmAfterKeyword := False;
    Exit;
  end;

  if FAsmLineStart then
  begin
    PrefixSpaces := FRule.SpaceBeforeASM - FCodeGen.Indent * FCodeGen.TabWidth;
    if PrefixSpaces < 0 then
      PrefixSpaces := 0;
    if PrefixSpaces > 0 then
      FCodeGen.Space(PrefixSpaces);
    WriteText(Token.Text);
    FAsmKeywordLength := Length(Token.Text);
    FAsmAfterKeyword := Token.Text <> '@';
    FAsmLineStart := False;
    Exit;
  end;

  if FAsmAfterKeyword then
  begin
    OperandSpaces := FRule.SpaceTabASMKeyword - FAsmKeywordLength;
    if OperandSpaces < 1 then
      OperandSpaces := 1;
    FCodeGen.Space(OperandSpaces);
    WriteText(Token.Text);
    FAsmAfterKeyword := False;
  end
  else if Token.Text = ';' then
  begin
    FCodeGen.TrimLine;
    WriteText(';');
    WriteNewLine;
    FAsmLineStart := True;
  end
  else
  begin
    if (Token.Text = ',') or (Token.Text = ';') or (Token.Text = ')') or (Token.Text
      = ']') or (Token.Text = ':') then
      FCodeGen.TrimLine
    else
      EnsureSpace;
    WriteText(Token.Text);
  end;
end;

procedure TCnCppCodeFormatter.TryAutoWrap;
var
  WrapWidth, NewLineWidth: Integer;
begin
  if (FRule.CodeWrapMode = cwmNone) or FRule.KeepUserLineBreak or FIgnore or (FRule.WrapWidth
    <= 0) or (FParenDepth <= 0) then
    Exit;

  WrapWidth := FRule.WrapWidth;
  NewLineWidth := FRule.WrapNewLineWidth;
  if NewLineWidth <= 0 then
    NewLineWidth := WrapWidth;

  if (FRule.CodeWrapMode = cwmSimple) or ((FRule.CodeWrapMode = cwmAdvanced) and
    (WrapWidth >= NewLineWidth)) then
  begin
    if FCodeGen.CurrentLineLength > WrapWidth then
      WriteNewLine;
  end
  else if FCodeGen.CurrentLineLength > NewLineWidth then
  begin
    if not FCodeGen.BreakLineAtLastSpace(WrapWidth, FCodeGen.Indent * FCodeGen.TabWidth)
      then
      WriteNewLine;
  end;
end;

procedure TCnCppCodeFormatter.RaiseMismatch(Code: Integer; Token: TCnCppToken);
begin
  SetCppError(Code, Token);
  raise ECnCppFormatError.Create('Mismatched C/C++ structure');
end;

procedure TCnCppCodeFormatter.CheckUnclosedStructures;
begin
  { 先检查 ASM，再检查通用大括号栈，使未闭合的 ASM 块能够得到更具体的错误码。 }
  if (FAsmDepth > 0) and (FAsmOpenToken <> nil) then
    RaiseMismatch(CnFormatterIntf.CN_ERRCODE_CPP_ASM_MISMATCH, FAsmOpenToken);

  if FStructureOpenTokens.Count > 0 then
  begin
    with TCnCppToken(FStructureOpenTokens[FStructureOpenTokens.Count - 1]) do
    begin
      if Text = '(' then
        RaiseMismatch(CnFormatterIntf.CN_ERRCODE_CPP_PAREN_MISMATCH, TCnCppToken
          (FStructureOpenTokens[FStructureOpenTokens.Count - 1]))
      else if Text = '[' then
        RaiseMismatch(CnFormatterIntf.CN_ERRCODE_CPP_BRACKET_MISMATCH,
          TCnCppToken(FStructureOpenTokens[FStructureOpenTokens.Count - 1]))
      else if Text = '{' then
        RaiseMismatch(CnFormatterIntf.CN_ERRCODE_CPP_BRACE_MISMATCH, TCnCppToken
          (FStructureOpenTokens[FStructureOpenTokens.Count - 1]))
      else
        RaiseMismatch(CnFormatterIntf.CN_ERRCODE_CPP_TEMPLATE_MISMATCH,
          TCnCppToken(FStructureOpenTokens[FStructureOpenTokens.Count - 1]));
    end;
  end;
end;

procedure TCnCppCodeFormatter.FormatTokens;
var
  I: Integer;
  T, N: TCnCppToken;
  AfterClose: TCnCppToken;
  NeedSpace: Boolean;
  IsDeclBrace: Boolean;
  IsTypeBrace: Boolean;
  ClosedDeclBrace: Boolean;
  PrevTemplateClose: Boolean;
  J, RawEndPos: Integer;
begin
  for I := 0 to FTokens.Count - 1 do
  begin
    T := TokenAt(I);
    N := TokenAt(I + 1);
    FCurrentToken := T;
    PrevTemplateClose := FPrevTemplateClose;
    FPrevTemplateClose := False;
    if T.Kind = ctkEOF then
    begin
      if FIgnore and (FIgnoreRawPos > 0) then
      begin
        WriteIgnoredSource(FIgnoreRawPos, Length(FScanner.Source));
        FIgnore := False;
        FIgnoreRawPos := 0;
      end;
      CheckUnclosedStructures;
      Break;
    end;

    { 忽略期间暂存所有记号，找到匹配标记后复制完整的源代码范围。
      这样可以保留原始空白和换行，而不是逐个记号重新构造。 }
    if FIgnore then
    begin
      if (T.Kind in [ctkLineComment, ctkBlockComment]) and (Pos('clang-format on',
        LowerCase(T.Text)) > 0) then
      begin
        RawEndPos := T.Position + Length(T.Text);
        if N <> nil then
        begin
          if N.Kind = ctkNewLine then
            RawEndPos := N.Position + Length(N.Text)
          else
            { 保留行内结束标记之后的源代码间隔。 }
            RawEndPos := N.Position;
        end;
        WriteIgnoredSource(FIgnoreRawPos, RawEndPos);
        FIgnore := False;
        FIgnoreRawPos := 0;
        FBlankLinePending := False;
        FPrev := nil;
      end;
      if FIgnore then
        Continue;
      Continue;
    end;

    FlushPendingBlankLine(T);
    if (T.Kind = ctkNewLine) then
    begin
      if FAsmDepth > 0 then
      begin
        FormatAsmToken(T);
        Continue;
      end;
      if (FIgnore or FRule.KeepUserLineBreak) and not FAtLineStart then
        WriteNewLine;
      Continue;
    end;

    if T.Kind = ctkPreprocessor then
    begin
      EnsureLine;
      WriteText(T.Text);
      WriteNewLine;
      { 保持 include/预处理指令组的连续性；只有下一个非标点声明开始时，
        才输出待处理的空行。 }
      FBlankLinePending := True;
      Continue;
    end;

    if T.Kind in [ctkLineComment, ctkBlockComment] then
    begin
      WriteComment(T);
      Continue
    end;

    if (T.Kind = ctkIdentifier) and SameText(T.Text, 'asm') then
    begin
      J := I + 1;
      while (TokenAt(J) <> nil) and (TokenAt(J).Kind = ctkNewLine) do
        Inc(J);
      if (TokenAt(J) <> nil) and (TokenAt(J).Text = '{') then
      begin
        FAsmDepth := -1;
        FAsmOpenToken := T;
      end;
    end;

    if T.Text = '{' then
    begin
      FBraceOpenTokens.Add(T);
      FStructureOpenTokens.Add(T);
      if FAsmDepth = -1 then
        FAsmDepth := FBraceDepth + 1;
      IsDeclBrace := IsDeclarationBrace(I);
      IsTypeBrace := IsTypeDeclarationBrace(I);
      PushBrace(IsDeclBrace, IsTypeBrace);
      WriteBrace(T, True);
      if FAsmDepth > 0 then
      begin
        FAsmLineStart := True;
        FAsmAfterKeyword := False;
        FAsmKeywordLength := 0;
      end;
      FPrev := T;
      Continue
    end;

    if T.Text = '}' then
    begin
      if (FBraceOpenTokens.Count = 0) or (FStructureOpenTokens.Count = 0) or (TCnCppToken
        (FStructureOpenTokens[FStructureOpenTokens.Count - 1]).Text <> '{') then
        RaiseMismatch(CnFormatterIntf.CN_ERRCODE_CPP_BRACE_MISMATCH, T);
      FBraceOpenTokens.Delete(FBraceOpenTokens.Count - 1);
      FStructureOpenTokens.Delete(FStructureOpenTokens.Count - 1);
      ClosedDeclBrace := PopBrace;
      WriteBrace(T, False);
      if (FAsmDepth > 0) and (FBraceDepth < FAsmDepth) then
      begin
        FAsmDepth := 0;
        FAsmOpenToken := nil;
      end;
      J := I + 1;
      AfterClose := TokenAt(J);
      while (AfterClose <> nil) and (AfterClose.Kind = ctkNewLine) do
      begin
        Inc(J);
        AfterClose := TokenAt(J);
      end;
      if ClosedDeclBrace and not (FLastClosedBraceIsType and (AfterClose <> nil)
        and (AfterClose.Kind = ctkIdentifier)) then
        FBlankLinePending := True;
      FPrev := T;
      Continue
    end;

    if FAsmDepth > 0 then
    begin
      FormatAsmToken(T);
      FPrev := T;
      Continue;
    end;

    if T.Text = '(' then
    begin
      if (FPrev <> nil) and ((FPrev.Text = 'if') or (FPrev.Text = 'for') or (FPrev.Text
        = 'while') or (FPrev.Text = 'switch') or (FPrev.Text = 'catch')) then
        EnsureSpace;
      WriteText('(');
      Inc(FParenDepth);
      FParenOpenTokens.Add(T);
      FStructureOpenTokens.Add(T);
      FPrev := T;
      Continue
    end;

    if T.Text = ')' then
    begin
      if (FParenOpenTokens.Count = 0) or (FStructureOpenTokens.Count = 0) or (TCnCppToken
        (FStructureOpenTokens[FStructureOpenTokens.Count - 1]).Text <> '(') then
        RaiseMismatch(CnFormatterIntf.CN_ERRCODE_CPP_PAREN_MISMATCH, T);
      FParenOpenTokens.Delete(FParenOpenTokens.Count - 1);
      FStructureOpenTokens.Delete(FStructureOpenTokens.Count - 1);
      FCodeGen.TrimLine;
      WriteText(')');
      Dec(FParenDepth);
      FPrev := T;
      Continue
    end;

    if T.Text = '[' then
    begin
      WriteText('[');
      Inc(FBracketDepth);
      FBracketOpenTokens.Add(T);
      FStructureOpenTokens.Add(T);
      FPrev := T;
      Continue
    end;

    if T.Text = ']' then
    begin
      if (FBracketOpenTokens.Count = 0) or (FStructureOpenTokens.Count = 0) or (TCnCppToken
        (FStructureOpenTokens[FStructureOpenTokens.Count - 1]).Text <> '[') then
        RaiseMismatch(CnFormatterIntf.CN_ERRCODE_CPP_BRACKET_MISMATCH, T);
      FBracketOpenTokens.Delete(FBracketOpenTokens.Count - 1);
      FStructureOpenTokens.Delete(FStructureOpenTokens.Count - 1);
      FCodeGen.TrimLine;
      WriteText(']');
      Dec(FBracketDepth);
      FPrev := T;
      Continue
    end;

    if T.Text = ';' then
    begin
      FCodeGen.TrimLine;
      WriteText(';');
      if FParenDepth = 0 then
        WriteNewLine
      else
        EnsureSpace;
      FPrev := T;
      Continue
    end;

    if T.Text = ',' then
    begin
      FCodeGen.TrimLine;
      WriteText(',');
      EnsureSpace;
      FPrev := T;
      Continue
    end;

    if T.Text = ':' then
    begin
      if IsAccessSpecifier(I - 1) then
      begin
        { 成员访问标签会开始新的声明区段。标签本身保持在类大括号层级，
          后续成员则保持正常的下一层缩进。 }
        FCodeGen.TrimLine;
        WriteText(':');
        WriteNewLine;
      end
      else if IsTernaryColon(I) then
      begin
        FCodeGen.TrimLine;
        EnsureSpace;
        WriteText(':');
        EnsureSpace;
      end
      else
      begin
        FCodeGen.TrimLine;
        WriteText(':');
        if (N <> nil) and (N.Text <> ':') then
          EnsureSpace;
      end;
      FPrev := T;
      Continue
    end;

    if (T.Text = '<') and IsTemplateOpen(I) then
    begin
      FCodeGen.TrimLine;
      WriteText('<');
      Inc(FTemplateDepth);
      FTemplateOpenTokens.Add(T);
      FStructureOpenTokens.Add(T);
      FPrev := T;
      Continue;
    end;

    if (FTemplateDepth > 0) and ((T.Text = '>') or (T.Text = '>>')) then
    begin
      if (FTemplateOpenTokens.Count = 0) or (FStructureOpenTokens.Count = 0) or
        (TCnCppToken(FStructureOpenTokens[FStructureOpenTokens.Count - 1]).Text
        <> '<') or ((T.Text = '>>') and ((FTemplateOpenTokens.Count < 2) or (FStructureOpenTokens.Count
        < 2) or (TCnCppToken(FStructureOpenTokens[FStructureOpenTokens.Count - 2]).Text
        <> '<'))) then
        RaiseMismatch(CnFormatterIntf.CN_ERRCODE_CPP_TEMPLATE_MISMATCH, T);
      FCodeGen.TrimLine;
      WriteText(T.Text);
      FTemplateOpenTokens.Delete(FTemplateOpenTokens.Count - 1);
      FStructureOpenTokens.Delete(FStructureOpenTokens.Count - 1);
      Dec(FTemplateDepth);
      if T.Text = '>>' then
      begin
        FTemplateOpenTokens.Delete(FTemplateOpenTokens.Count - 1);
        FStructureOpenTokens.Delete(FStructureOpenTokens.Count - 1);
        Dec(FTemplateDepth);
      end;
      FPrevTemplateClose := True;
      FPrev := T;
      Continue;
    end;

    if (T.Text = '.') or (T.Text = '->') or (T.Text = '::') or (T.Text = '.*') then
    begin
      FCodeGen.TrimLine;
      WriteText(T.Text);
      FPrev := T;
      Continue
    end;

    if T.Text = '?' then
    begin
      EnsureSpace;
      WriteText('?');
      EnsureSpace;
      FPrev := T;
      Continue
    end;

    if T.Kind = ctkOperator then
    begin
      WriteOperator(T);
      FPrev := T;
      Continue
    end;

    if IsAccessSpecifier(I) then
    begin
      { 标签属于类声明层级，而其后的声明仍保持下一层缩进。
        仅在写出标签时临时降低代码生成器的缩进。 }
      if not FAtLineStart then
        WriteNewLine;
      if FCodeGen.Indent > 0 then
      begin
        FCodeGen.DecIndent;
        WriteText(T.Text);
        FCodeGen.IncIndent;
      end
      else
        WriteText(T.Text);
      FPrev := T;
      Continue;
    end;

    NeedSpace := IsWordLike(FPrev) or ((FPrev <> nil) and ((FPrev.Text = ')') or
      (FPrev.Text = ']') or (FPrev.Text = '}'))) or (PrevTemplateClose and IsWordLike(T));
    if NeedSpace then
      EnsureSpace;
    WriteText(T.Text);
    TryAutoWrap;
    FPrev := T;
  end;

  if not FAtLineStart then
    WriteNewLine;
end;

procedure TCnCppCodeFormatter.FormatCode;
var
  T: TCnCppToken;
  I: Integer;
begin
  ClearCppError;
  FCodeGen.Reset;
  for I := 0 to FTokens.Count - 1 do
    TObject(FTokens[I]).Free;

  FTokens.Clear;
  FPrev := nil;
  FCurrentToken := nil;
  FIgnore := False;
  FIgnoreRawPos := 0;
  FAsmDepth := 0;
  FAsmLineStart := False;
  FAsmAfterKeyword := False;
  FAsmKeywordLength := 0;
  FParenDepth := 0;
  FBracketDepth := 0;
  FTemplateDepth := 0;
  FPrevTemplateClose := False;
  FBraceDepth := 0;
  FParenOpenTokens.Clear;
  FBracketOpenTokens.Clear;
  FTemplateOpenTokens.Clear;
  FBraceOpenTokens.Clear;
  FStructureOpenTokens.Clear;
  FAsmOpenToken := nil;
  FAtLineStart := True;
  FBraceStackCount := 0;
  SetLength(FBraceDeclStack, 0);
  SetLength(FBraceTypeStack, 0);
  FLastClosedBraceIsType := False;
  FBlankLinePending := False;
  FFirstMatchStart := False;
  FFirstMatchEnd := False;
  FMatchedOutStartRow := CN_CPP_MATCHED_INVALID;
  FMatchedOutStartCol := CN_CPP_MATCHED_INVALID;
  FMatchedOutEndRow := CN_CPP_MATCHED_INVALID;
  FMatchedOutEndCol := CN_CPP_MATCHED_INVALID;

  try
    repeat
      T := FScanner.NextToken;
      FTokens.Add(T);
    until T.Kind = ctkEOF;
    FormatTokens;
  except
    on E: ECnCppFormatError do
      raise;
    on E: ECnCppScannerError do
    begin
      case E.ErrorKind of
        csekUnclosedString:
          SetCppScanError(CnFormatterIntf.CN_ERRCODE_CPP_UNCLOSED_STRING, E);
        csekUnclosedBlockComment:
          SetCppScanError(CnFormatterIntf.CN_ERRCODE_CPP_UNCLOSED_COMMENT, E);
        csekUnclosedRawString:
          SetCppScanError(CnFormatterIntf.CN_ERRCODE_CPP_UNCLOSED_RAW_STRING, E);
      end;
      raise;
    end;
    on E: Exception do
    begin
      SetCppError(CnFormatterIntf.CN_ERRCODE_CPP_FORMAT, FCurrentToken);
      raise;
    end;
  end;
end;

procedure TCnCppCodeFormatter.SaveToStream(Stream: TStream);
var
  S: string;
begin
  S := ResultText;
  if S <> '' then
    Stream.Write(S[1], Length(S) * SizeOf(Char));
end;

procedure TCnCppCodeFormatter.SaveToStrings(Strings: TStrings);
begin
  Strings.Text := ResultText;
end;

function TCnCppCodeFormatter.ResultText: string;
begin
  Result := FCodeGen.Text;
end;

function TCnCppCodeFormatter.HasSliceResult: Boolean;
begin
  Result := (FMatchedOutStartRow <> CN_CPP_MATCHED_INVALID) and (FMatchedOutStartCol
    <> CN_CPP_MATCHED_INVALID) and (FMatchedOutEndRow <> CN_CPP_MATCHED_INVALID)
    and (FMatchedOutEndCol <> CN_CPP_MATCHED_INVALID);
end;

function TCnCppCodeFormatter.CopyMatchedSliceResult: string;
begin
  Result := '';
  if FSliceMode and HasSliceResult then
    Result := FCodeGen.CopyPartOut(FMatchedOutStartRow, FMatchedOutStartCol,
      FMatchedOutEndRow, FMatchedOutEndCol);
end;

function CnFormatCppText(const Source: string; const Rule: TCnCppCodeFormatRule): string;
var
  InStream: TMemoryStream;
  F: TCnCppCodeFormatter;
begin
  InStream := TMemoryStream.Create;
  try
    if Source <> '' then
      InStream.Write(Source[1], Length(Source) * SizeOf(Char));

    InStream.Position := 0;
    F := TCnCppCodeFormatter.Create(InStream, Rule);
    try
      try
        F.FormatCode;
        Result := F.ResultText;
      except
        Result := '';
      end;
    finally
      F.Free;
    end;
  finally
    InStream.Free
  end;
end;

initialization
  ClearCppError;

end.

