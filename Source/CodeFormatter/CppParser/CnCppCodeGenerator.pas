unit CnCppCodeGenerator;

{$I CnPack.inc}

interface

uses
  Classes, SysUtils;

type
  TCnCppCodeGenerator = class
  private
    FLines: TStringList;
    FCurrent: string;
    FIndent: Integer;
    FTabWidth: Integer;
    procedure EnsureIndent;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Reset;
    procedure Write(const S: string);
    procedure Space(Count: Integer);
    procedure NewLine;
    procedure TrimLine;
    procedure IncIndent;
    procedure DecIndent;
    procedure SaveToStrings(Strings: TStrings);
    function Text: string;
    function CurrentLineLength: Integer;
    property Indent: Integer read FIndent write FIndent;
    property TabWidth: Integer read FTabWidth write FTabWidth;
  end;

implementation

constructor TCnCppCodeGenerator.Create;
begin
  inherited Create;
  FLines := TStringList.Create;
  FTabWidth := 2;
  Reset;
end;

destructor TCnCppCodeGenerator.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TCnCppCodeGenerator.Reset;
begin
  FLines.Clear; FCurrent := ''; FIndent := 0;
end;

procedure TCnCppCodeGenerator.EnsureIndent;
begin
  if FCurrent = '' then FCurrent := StringOfChar(' ', FIndent * FTabWidth);
end;

procedure TCnCppCodeGenerator.Write(const S: string);
begin
  EnsureIndent; FCurrent := FCurrent + S;
end;

procedure TCnCppCodeGenerator.Space(Count: Integer);
begin
  if Count > 0 then Write(StringOfChar(' ', Count));
end;

procedure TCnCppCodeGenerator.NewLine;
begin
  FLines.Add(FCurrent); FCurrent := '';
end;

procedure TCnCppCodeGenerator.TrimLine;
begin
  FCurrent := TrimRight(FCurrent);
end;

procedure TCnCppCodeGenerator.IncIndent;
begin
  Inc(FIndent);
end;

procedure TCnCppCodeGenerator.DecIndent;
begin
  if FIndent > 0 then Dec(FIndent);
end;

procedure TCnCppCodeGenerator.SaveToStrings(Strings: TStrings);
begin
  if FCurrent <> '' then NewLine;
  Strings.Assign(FLines);
end;

function TCnCppCodeGenerator.Text: string;
var
  I: Integer;
begin
  if FCurrent <> '' then NewLine;
  Result := '';
  for I := 0 to FLines.Count - 1 do
  begin
    if I > 0 then Result := Result + #13#10;
    Result := Result + FLines[I];
  end;
end;

function TCnCppCodeGenerator.CurrentLineLength: Integer;
begin
  Result := Length(FCurrent);
end;

end.
