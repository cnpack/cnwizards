unit CnCppToken;

{$I CnPack.inc}

interface

type
  TCnCppTokenKind = (ctkUnknown, ctkEOF, ctkIdentifier, ctkNumber,
    ctkString, ctkChar, ctkLineComment, ctkBlockComment, ctkPreprocessor,
    ctkNewLine, ctkSymbol, ctkOperator);

  TCnCppToken = class
  private
    FKind: TCnCppTokenKind;
    FText: string;
    FLine: Integer;
    FColumn: Integer;
    FPosition: Integer;
    FHadLineBreak: Boolean;
  public
    constructor Create(AKind: TCnCppTokenKind; const AText: string;
      ALine, AColumn, APosition: Integer);
    property Kind: TCnCppTokenKind read FKind write FKind;
    property Text: string read FText;
    property Line: Integer read FLine;
    property Column: Integer read FColumn;
    property Position: Integer read FPosition;
    property HadLineBreak: Boolean read FHadLineBreak write FHadLineBreak;
  end;

function CnCppIsWordToken(Token: TCnCppToken): Boolean;
function CnCppIsBinaryOperator(const S: string): Boolean;
function CnCppIsUnaryOperator(const S: string): Boolean;

implementation

constructor TCnCppToken.Create(AKind: TCnCppTokenKind; const AText: string;
  ALine, AColumn, APosition: Integer);
begin
  inherited Create;
  FKind := AKind;
  FText := AText;
  FLine := ALine;
  FColumn := AColumn;
  FPosition := APosition;
end;

function CnCppIsWordToken(Token: TCnCppToken): Boolean;
begin
  Result := (Token <> nil) and (Token.Kind in [ctkIdentifier, ctkNumber,
    ctkString, ctkChar]);
end;

function CnCppIsBinaryOperator(const S: string): Boolean;
begin
  Result := (S = '=') or (S = '+') or (S = '-') or (S = '*') or (S = '/') or
    (S = '%') or (S = '==') or (S = '!=') or (S = '<') or (S = '>') or
    (S = '<=') or (S = '>=') or (S = '&&') or (S = '||') or (S = '&') or
    (S = '|') or (S = '^') or (S = '<<') or (S = '>>') or (S = '+=') or
    (S = '-=') or (S = '*=') or (S = '/=') or (S = '%=') or (S = '&=') or
    (S = '|=') or (S = '^=') or (S = '<<=') or (S = '>>=') or
    (S = '->*') or (S = '.*');
end;

function CnCppIsUnaryOperator(const S: string): Boolean;
begin
  Result := (S = '!') or (S = '~') or (S = '++') or (S = '--');
end;

end.
