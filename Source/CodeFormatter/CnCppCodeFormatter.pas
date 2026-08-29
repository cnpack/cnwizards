unit CnCppCodeFormatter;

{$I CnPack.inc}

interface

uses
  Classes, SysUtils, CnCppToken, CnCppScanner, CnCppCodeGenerator,
  CnCodeFormatRules;

const
  CN_CPP_MATCHED_INVALID = -1;

type
  TCnCppCodeFormatter = class
  private
    FScanner: TCnCppScanner;
    FCodeGen: TCnCppCodeGenerator;
    FRule: TCnCppCodeFormatRule;
    FTokens: TList;
    FIgnore: Boolean;
    FAsmDepth: Integer;
    FParenDepth: Integer;
    FBracketDepth: Integer;
    FTemplateDepth: Integer;
    FPrevTemplateClose: Boolean;
    FBraceDepth: Integer;
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
    function IsTemplateOpen(TokenIndex: Integer): Boolean;
    function CurrentColumn: Integer;
    procedure WriteText(const S: string);
    procedure EnsureLine;
    procedure EnsureSpace;
    procedure WriteNewLine;
    procedure WriteComment(Token: TCnCppToken);
    procedure WriteOperator(Token: TCnCppToken);
    procedure WriteBrace(Token: TCnCppToken; IsOpen: Boolean);
    function IsDeclarationBrace(TokenIndex: Integer): Boolean;
    function IsTypeDeclarationBrace(TokenIndex: Integer): Boolean;
    procedure PushBrace(IsDeclaration, IsTypeDeclaration: Boolean);
    function PopBrace: Boolean;
    procedure FlushPendingBlankLine(Token: TCnCppToken);
    procedure FormatTokens;
    procedure CodeGenAfterWrite(Sender: TObject; IsWriteBlank,
      IsWriteln: Boolean; PrefixSpaces: Integer);
  public
    constructor Create(Stream: TStream; const Rule: TCnCppCodeFormatRule;
      AMatchedInStart: Integer = CN_CPP_MATCHED_INVALID;
      AMatchedInEnd: Integer = CN_CPP_MATCHED_INVALID);
    destructor Destroy; override;
    procedure FormatCode;
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

constructor TCnCppCodeFormatter.Create(Stream: TStream;
  const Rule: TCnCppCodeFormatRule; AMatchedInStart, AMatchedInEnd: Integer);
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
  FAtLineStart := True;
end;

procedure TCnCppCodeFormatter.CodeGenAfterWrite(Sender: TObject;
  IsWriteBlank, IsWriteln: Boolean; PrefixSpaces: Integer);
var
  StartPos, EndPos: Integer;
begin
  if not FSliceMode or (FCurrentToken = nil) or
    (FMatchedInStart = CN_CPP_MATCHED_INVALID) or
    (FMatchedInEnd = CN_CPP_MATCHED_INVALID) then Exit;

  StartPos := FCurrentToken.Position;
  EndPos := StartPos + Length(FCurrentToken.Text);

  if (StartPos >= FMatchedInStart) and not IsWriteln and
    not IsWriteBlank and not FFirstMatchStart then
  begin
    FMatchedOutStartRow := TCnCppCodeGenerator(Sender).PrevRow;
    FMatchedOutStartCol := TCnCppCodeGenerator(Sender).PrevColumn - PrefixSpaces;
    if FMatchedOutStartCol < 0 then
      FMatchedOutStartCol := 0;
    FFirstMatchStart := True;
  end
  else if (EndPos >= FMatchedInEnd) and IsWriteln and
    not FFirstMatchEnd then
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
  for I := 0 to FTokens.Count - 1 do TObject(FTokens[I]).Free;
  FTokens.Free;
  FCodeGen.Free;
  FScanner.Free;
  inherited Destroy;
end;

function TCnCppCodeFormatter.TokenAt(Index: Integer): TCnCppToken;
begin
  if (Index >= 0) and (Index < FTokens.Count) then Result := TCnCppToken(FTokens[Index])
  else Result := nil;
end;

function TCnCppCodeFormatter.IsWordLike(Token: TCnCppToken): Boolean;
begin
  Result := CnCppIsWordToken(Token);
end;

function TCnCppCodeFormatter.IsUnary(Token: TCnCppToken): Boolean;
begin
  Result := (Token <> nil) and ((Token.Text = '!') or (Token.Text = '~') or
    (Token.Text = '++') or (Token.Text = '--') or
    (((Token.Text = '+') or (Token.Text = '-')) and ((FPrev = nil) or
      (FPrev.Kind in [ctkOperator, ctkSymbol]))));
end;

function TCnCppCodeFormatter.IsTemplateOpen(TokenIndex: Integer): Boolean;
var
  Prev, BeforePrev, T: TCnCppToken;
  J, Depth: Integer;
  Name: string;
begin
  Result := False;
  Prev := TokenAt(TokenIndex - 1);
  if Prev = nil then Exit;

  { A template argument list follows a name (often qualified with ::), or
    another template's closing angle.  The common type names below also cover
    unqualified STL declarations such as vector<int>. }
  if (Prev.Text = '>') or (FTemplateDepth > 0) then
    Result := True
  else if Prev.Kind = ctkIdentifier then
  begin
    Name := Prev.Text;
    if SameText(Name, 'operator') then Exit;
    if SameText(Name, 'template') then
      Result := True;
    BeforePrev := TokenAt(TokenIndex - 2);
    if not Result then
      Result := (BeforePrev <> nil) and (BeforePrev.Text = '::');
    if not Result then
      Result := (Name = 'vector') or (Name = 'map') or (Name = 'set') or
        (Name = 'list') or (Name = 'deque') or (Name = 'array') or
        (Name = 'tuple') or (Name = 'pair') or (Name = 'optional') or
        (Name = 'variant') or (Name = 'string') or (Name = 'wstring') or
        (Name = 'unique_ptr') or (Name = 'shared_ptr') or
        (Name = 'weak_ptr') or (Name = 'make_shared') or
        (Name = 'make_unique') or (Name = 'enable_if') or
      (Name = 'conditional') or (Name = 'remove_reference') or
        (Name = 'RemoveReferenceT') or (Name = 'FixedArray') or
        (Name = 'Traits') or (Name = 'Factorial') or (Name = 'MaxValue') or
        (Name = 'decltype') or (Name = 'static_cast') or
        (Name = 'dynamic_cast') or (Name = 'reinterpret_cast') or
        (Name = 'const_cast');
  end;
  if not Result then Exit;

  { Require a matching closing angle before a statement boundary.  This keeps
    ordinary expressions such as a < b from being treated as templates. }
  Depth := 1;
  J := TokenIndex + 1;
  while True do
  begin
    T := TokenAt(J);
    if T = nil then begin Result := False; Exit end;
    if T.Kind = ctkEOF then begin Result := False; Exit end;
    if T.Text = '<' then Inc(Depth)
    else if T.Text = '>' then Dec(Depth)
    else if T.Text = '>>' then Dec(Depth, 2);
    if Depth <= 0 then Exit;
    if (Depth = 1) and ((T.Text = ';') or (T.Text = '{') or
      (T.Text = '}') or (T.Text = ':')) then
    begin
      Result := False;
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
  if TokenIndex <= 0 then Exit;

  { A brace following a parenthesized declarator is normally a function body.
    Control statements are explicitly excluded.  This also covers trailing
    return types and noexcept clauses, where the token immediately preceding
    the brace is not the closing parenthesis. }
  ParenDepth := 0;
  SawParen := False;
  J := TokenIndex - 1;
  while J >= 0 do
  begin
    T := TokenAt(J);
    if T = nil then Break;
    if (ParenDepth = 0) and ((T.Text = '{') or (T.Text = '}')) then
      Break;
    if T.Text = ')' then Inc(ParenDepth)
    else if T.Text = '(' then
    begin
      if ParenDepth > 0 then Dec(ParenDepth)
      else Break;
      if ParenDepth = 0 then SawParen := True;
    end;
    if (ParenDepth = 0) and (T.Text = ';') then Break;
    if (ParenDepth = 0) and (T.Text = '=') then Break;
    if (ParenDepth = 0) and (T.Text = ':') then Break;
    if SawParen and (ParenDepth = 0) and
      (T.Kind = ctkIdentifier) and
      ((T.Text = 'if') or (T.Text = 'for') or (T.Text = 'while') or
       (T.Text = 'switch') or (T.Text = 'catch') or (T.Text = 'with')) then
      Exit;
    if SawParen and (ParenDepth = 0) and (T.Text = ']') then
      Exit; { lambda body }
    Dec(J);
  end;
  if SawParen then
  begin
    Result := True;
    Exit;
  end;

  { Class/struct/union/enum/namespace bodies.  Stop at a declaration
    boundary so a braced initializer is not mistaken for a declaration body. }
  J := TokenIndex - 1;
  while J >= 0 do
  begin
    T := TokenAt(J);
    if T = nil then Break;
    if T.Text = '=' then Exit;
    if T.Text = ';' then Break;
    if T.Text = '}' then Break;
    if T.Text = '{' then Break;
    if (T.Kind = ctkIdentifier) and
      ((T.Text = 'class') or (T.Text = 'struct') or (T.Text = 'union') or
       (T.Text = 'namespace') or (T.Text = 'enum')) then
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
    if T = nil then Break;
    if (T.Text = '=') or (T.Text = ';') or (T.Text = '{') or
      (T.Text = '}') then Break;
    if (T.Kind = ctkIdentifier) and
      ((T.Text = 'class') or (T.Text = 'struct') or (T.Text = 'union') or
       (T.Text = 'namespace') or (T.Text = 'enum')) then
    begin
      Result := True;
      Exit;
    end;
    Dec(J);
  end;
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
  if not FBlankLinePending then Exit;
  if (Token <> nil) and (Token.Kind = ctkPreprocessor) then
  begin
    FBlankLinePending := False;
    Exit;
  end;
  { Keep punctuation and structural continuations attached to the closing
    brace (semicolon, else, while, and an enclosing closing brace). }
  if (Token = nil) or (Token.Kind in [ctkEOF, ctkNewLine, ctkPreprocessor]) or
    (Token.Text = ';') or (Token.Text = ',') or (Token.Text = ')') or
    (Token.Text = ']') or (Token.Text = '}') or (Token.Text = 'else') or
    (Token.Text = 'catch') or (Token.Text = 'while') then Exit;
  if not FAtLineStart then WriteNewLine;
  { This is a synthetic line, not output belonging to the current source
    token; keep slice-coordinate tracking from observing it. }
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

procedure TCnCppCodeFormatter.EnsureLine;
begin
  if not FAtLineStart then WriteNewLine;
end;

procedure TCnCppCodeFormatter.EnsureSpace;
begin
  if not FAtLineStart then FCodeGen.Space(1);
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
    if Pos('clang-format off', LowerCase(Token.Text)) > 0 then FIgnore := FRule.UseIgnoreArea;
    if Pos('clang-format on', LowerCase(Token.Text)) > 0 then FIgnore := False;
    EnsureSpace; WriteText(TrimRight(Token.Text)); WriteNewLine;
  end
  else
  begin
    S := Token.Text;
    WasLineStart := FAtLineStart;
    if Pos('clang-format off', LowerCase(S)) > 0 then FIgnore := FRule.UseIgnoreArea;
    if Pos('clang-format on', LowerCase(S)) > 0 then FIgnore := False;
    EnsureSpace; WriteText(S);
    if (Pos(#10, S) > 0) or WasLineStart then WriteNewLine else EnsureSpace;
  end;
end;

procedure TCnCppCodeFormatter.WriteOperator(Token: TCnCppToken);
var
  S: string;
begin
  S := Token.Text;
  if IsUnary(Token) then
  begin
    if (S = '++') or (S = '--') then
      WriteText(S)
    else if (S = '+') or (S = '-') then
      WriteText(S)
    else begin EnsureSpace; WriteText(S) end;
  end
  else if CnCppIsBinaryOperator(S) then
  begin
    if not FAtLineStart then FCodeGen.Space(FRule.SpaceBeforeBinaryOperator);
    WriteText(S);
    FCodeGen.Space(FRule.SpaceAfterBinaryOperator);
  end
  else begin
    if (S = '::') or (S = '->') or (S = '.') then FCodeGen.TrimLine;
    WriteText(S);
  end;
end;

procedure TCnCppCodeFormatter.WriteBrace(Token: TCnCppToken; IsOpen: Boolean);
var
  NextToken: TCnCppToken;
begin
  if IsOpen then
  begin
    if FRule.BraceStyle = cbsNextLine then EnsureLine else EnsureSpace;
    WriteText('{'); Inc(FBraceDepth); FCodeGen.IncIndent; WriteNewLine;
  end
  else
  begin
    FCodeGen.DecIndent; Dec(FBraceDepth); EnsureLine; WriteText('}');
    NextToken := TokenAt(FTokens.IndexOf(Token) + 1);
    if (NextToken = nil) or
      not ((NextToken.Text = ';') or (NextToken.Text = ',') or
      (NextToken.Text = ')') or (NextToken.Text = ']') or
      (NextToken.Text = 'else') or (NextToken.Text = 'catch') or
      (NextToken.Text = 'while')) then
      WriteNewLine
    else if not ((NextToken.Text = ';') or (NextToken.Text = ',') or
      (NextToken.Text = ')') or (NextToken.Text = ']') or
      (NextToken.Text = 'else') or (NextToken.Text = 'catch') or
      (NextToken.Text = 'while')) then EnsureSpace;
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
  J: Integer;
begin
  for I := 0 to FTokens.Count - 1 do
  begin
    T := TokenAt(I); N := TokenAt(I + 1);
    FCurrentToken := T;
    PrevTemplateClose := FPrevTemplateClose;
    FPrevTemplateClose := False;
    if T.Kind = ctkEOF then Break;
    FlushPendingBlankLine(T);
    if (T.Kind = ctkNewLine) then
    begin
      if (FIgnore or FRule.KeepUserLineBreak) and not FAtLineStart then WriteNewLine;
      Continue;
    end;
    if T.Kind = ctkPreprocessor then begin EnsureLine; WriteText(T.Text); WriteNewLine; Continue end;
    if T.Kind in [ctkLineComment, ctkBlockComment] then begin WriteComment(T); Continue end;
    if FIgnore then begin EnsureSpace; WriteText(T.Text); Continue end;
    if (T.Kind = ctkIdentifier) and SameText(T.Text, 'asm') then FAsmDepth := -1;
    if T.Text = '{' then begin
      if FAsmDepth = -1 then FAsmDepth := FBraceDepth + 1;
      IsDeclBrace := IsDeclarationBrace(I);
      IsTypeBrace := IsTypeDeclarationBrace(I);
      PushBrace(IsDeclBrace, IsTypeBrace);
      WriteBrace(T, True); FPrev := T; Continue
    end;
    if T.Text = '}' then begin
      ClosedDeclBrace := PopBrace;
      WriteBrace(T, False);
      if (FAsmDepth > 0) and (FBraceDepth < FAsmDepth) then FAsmDepth := 0;
      J := I + 1;
      AfterClose := TokenAt(J);
      while (AfterClose <> nil) and (AfterClose.Kind = ctkNewLine) do
      begin
        Inc(J);
        AfterClose := TokenAt(J);
      end;
      if ClosedDeclBrace and not (FLastClosedBraceIsType and
        (AfterClose <> nil) and (AfterClose.Kind = ctkIdentifier)) then
        FBlankLinePending := True;
      FPrev := T; Continue
    end;
    if (FAsmDepth > 0) and not FRule.FormatAsm then begin
      EnsureSpace; WriteText(T.Text); if T.Text = ';' then WriteNewLine; Continue
    end;
    if T.Text = '(' then begin
      if (FPrev <> nil) and ((FPrev.Text = 'if') or (FPrev.Text = 'for') or
        (FPrev.Text = 'while') or (FPrev.Text = 'switch') or
        (FPrev.Text = 'catch')) then EnsureSpace;
      WriteText('('); Inc(FParenDepth); FPrev := T; Continue
    end;
    if T.Text = ')' then begin FCodeGen.TrimLine; WriteText(')'); if FParenDepth > 0 then Dec(FParenDepth); FPrev := T; Continue end;
    if T.Text = '[' then begin WriteText('['); Inc(FBracketDepth); FPrev := T; Continue end;
    if T.Text = ']' then begin FCodeGen.TrimLine; WriteText(']'); if FBracketDepth > 0 then Dec(FBracketDepth); FPrev := T; Continue end;
    if T.Text = ';' then begin FCodeGen.TrimLine; WriteText(';'); if FParenDepth = 0 then WriteNewLine else EnsureSpace; FPrev := T; Continue end;
    if T.Text = ',' then begin FCodeGen.TrimLine; WriteText(','); EnsureSpace; FPrev := T; Continue end;
    if T.Text = ':' then begin FCodeGen.TrimLine; WriteText(':'); if (N <> nil) and (N.Text <> ':') then EnsureSpace; FPrev := T; Continue end;
    if (T.Text = '<') and IsTemplateOpen(I) then
    begin
      FCodeGen.TrimLine;
      WriteText('<');
      Inc(FTemplateDepth);
      FPrev := T;
      Continue;
    end;
    if (FTemplateDepth > 0) and ((T.Text = '>') or (T.Text = '>>')) then
    begin
      FCodeGen.TrimLine;
      WriteText(T.Text);
      if T.Text = '>>' then Dec(FTemplateDepth, 2)
      else Dec(FTemplateDepth);
      if FTemplateDepth < 0 then FTemplateDepth := 0;
      FPrevTemplateClose := True;
      FPrev := T;
      Continue;
    end;
    if (T.Text = '.') or (T.Text = '->') or (T.Text = '::') or (T.Text = '.*') then
    begin
      FCodeGen.TrimLine; WriteText(T.Text); FPrev := T; Continue
    end;
    if T.Kind = ctkOperator then begin WriteOperator(T); FPrev := T; Continue end;
    NeedSpace := IsWordLike(FPrev) or ((FPrev <> nil) and ((FPrev.Text = ')') or
      (FPrev.Text = ']') or (FPrev.Text = '}'))) or
      (PrevTemplateClose and IsWordLike(T)) or
      ((T.Kind = ctkIdentifier) and (FPrev <> nil) and (FPrev.Text = '*'));
    if NeedSpace then EnsureSpace;
    WriteText(T.Text);
    if (Rule.WrapWidth > 0) and (FCodeGen.CurrentLineLength > Rule.WrapWidth) and (FParenDepth > 0) then WriteNewLine;
    FPrev := T;
  end;
  if not FAtLineStart then WriteNewLine;
end;

procedure TCnCppCodeFormatter.FormatCode;
var
  T: TCnCppToken;
  I: Integer;
begin
  FCodeGen.Reset;
  for I := 0 to FTokens.Count - 1 do TObject(FTokens[I]).Free;
  FTokens.Clear;
  FPrev := nil; FCurrentToken := nil; FIgnore := False;
  FAsmDepth := 0; FParenDepth := 0; FBracketDepth := 0; FTemplateDepth := 0;
  FPrevTemplateClose := False;
  FBraceDepth := 0;
  FAtLineStart := True;
  FBraceStackCount := 0; SetLength(FBraceDeclStack, 0); SetLength(FBraceTypeStack, 0);
  FLastClosedBraceIsType := False;
  FBlankLinePending := False;
  FFirstMatchStart := False; FFirstMatchEnd := False;
  FMatchedOutStartRow := CN_CPP_MATCHED_INVALID;
  FMatchedOutStartCol := CN_CPP_MATCHED_INVALID;
  FMatchedOutEndRow := CN_CPP_MATCHED_INVALID;
  FMatchedOutEndCol := CN_CPP_MATCHED_INVALID;
  repeat
    T := FScanner.NextToken; FTokens.Add(T);
  until T.Kind = ctkEOF;
  FormatTokens;
end;

procedure TCnCppCodeFormatter.SaveToStream(Stream: TStream);
var
  S: string;
begin
  S := ResultText;
  if S <> '' then Stream.Write(S[1], Length(S) * SizeOf(Char));
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
  Result := (FMatchedOutStartRow <> CN_CPP_MATCHED_INVALID) and
    (FMatchedOutStartCol <> CN_CPP_MATCHED_INVALID) and
    (FMatchedOutEndRow <> CN_CPP_MATCHED_INVALID) and
    (FMatchedOutEndCol <> CN_CPP_MATCHED_INVALID);
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
    if Source <> '' then InStream.Write(Source[1], Length(Source) * SizeOf(Char));
    InStream.Position := 0;
    F := TCnCppCodeFormatter.Create(InStream, Rule);
    try F.FormatCode; Result := F.ResultText finally F.Free end;
  finally InStream.Free end;
end;

end.
