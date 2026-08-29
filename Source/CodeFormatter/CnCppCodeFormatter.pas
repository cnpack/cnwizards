unit CnCppCodeFormatter;

{$I CnPack.inc}

interface

uses
  Classes, SysUtils, CnCppToken, CnCppScanner, CnCppCodeGenerator,
  CnCodeFormatRules;

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
    FBraceDepth: Integer;
    FAtLineStart: Boolean;
    FPrev: TCnCppToken;
    function TokenAt(Index: Integer): TCnCppToken;
    function IsWordLike(Token: TCnCppToken): Boolean;
    function IsUnary(Token: TCnCppToken): Boolean;
    function CurrentColumn: Integer;
    procedure WriteText(const S: string);
    procedure EnsureLine;
    procedure EnsureSpace;
    procedure WriteNewLine;
    procedure WriteComment(Token: TCnCppToken);
    procedure WriteOperator(Token: TCnCppToken);
    procedure WriteBrace(Token: TCnCppToken; IsOpen: Boolean);
    procedure FormatTokens;
  public
    constructor Create(Stream: TStream; const Rule: TCnCppCodeFormatRule);
    destructor Destroy; override;
    procedure FormatCode;
    procedure SaveToStream(Stream: TStream);
    procedure SaveToStrings(Strings: TStrings);
    function ResultText: string;
    property Rule: TCnCppCodeFormatRule read FRule write FRule;
  end;

function CnFormatCppText(const Source: string; const Rule: TCnCppCodeFormatRule): string;

implementation

constructor TCnCppCodeFormatter.Create(Stream: TStream; const Rule: TCnCppCodeFormatRule);
begin
  inherited Create;
  FRule := Rule;
  FScanner := TCnCppScanner.Create(Stream);
  FCodeGen := TCnCppCodeGenerator.Create;
  FCodeGen.TabWidth := Rule.TabSpaceCount;
  FTokens := TList.Create;
  FAtLineStart := True;
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

function TCnCppCodeFormatter.CurrentColumn: Integer;
begin
  Result := FCodeGen.CurrentLineLength;
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
    if Pos('clang-format off', LowerCase(S)) > 0 then FIgnore := FRule.UseIgnoreArea;
    if Pos('clang-format on', LowerCase(S)) > 0 then FIgnore := False;
    EnsureSpace; WriteText(S);
    if Pos(#10, S) > 0 then WriteNewLine else EnsureSpace;
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
  NeedSpace: Boolean;
begin
  for I := 0 to FTokens.Count - 1 do
  begin
    T := TokenAt(I); N := TokenAt(I + 1);
    if T.Kind = ctkEOF then Break;
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
      WriteBrace(T, True); FPrev := T; Continue
    end;
    if T.Text = '}' then begin
      WriteBrace(T, False);
      if (FAsmDepth > 0) and (FBraceDepth < FAsmDepth) then FAsmDepth := 0;
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
    if (T.Text = '.') or (T.Text = '->') or (T.Text = '::') or (T.Text = '.*') then
    begin
      FCodeGen.TrimLine; WriteText(T.Text); FPrev := T; Continue
    end;
    if T.Kind = ctkOperator then begin WriteOperator(T); FPrev := T; Continue end;
    NeedSpace := IsWordLike(FPrev) or ((FPrev <> nil) and ((FPrev.Text = ')') or
      (FPrev.Text = ']') or (FPrev.Text = '}'))) or
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
  FPrev := nil; FIgnore := False;
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
