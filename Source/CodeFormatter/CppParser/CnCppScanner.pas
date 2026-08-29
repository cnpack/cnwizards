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

unit CnCppScanner;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：C/C++ 词法扫描器
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
  Classes, SysUtils, CnCppToken;

type
  TCnCppScanner = class
  private
    FSource: string;
    FIndex: Integer;
    FLine: Integer;
    FColumn: Integer;
    FAtLineStart: Boolean;
    function Peek(Offset: Integer = 0): Char;
    function Take: Char;
    function MakeToken(Kind: TCnCppTokenKind; Start, Line, Col: Integer): TCnCppToken;
    function IsIdentStart(C: Char): Boolean;
    function IsIdentChar(C: Char): Boolean;
    function ReadQuoted(Quote: Char; Kind: TCnCppTokenKind): TCnCppToken;
    function ReadPrefixedQuoted(const Prefix: string; Quote: Char;
      Kind: TCnCppTokenKind): TCnCppToken;
    function ReadRawString(PrefixLength: Integer): TCnCppToken;
    function ReadOperator: TCnCppToken;
  public
    constructor Create(Stream: TStream); virtual;
    function NextToken: TCnCppToken; virtual;
    property Source: string read FSource;
  end;

implementation

constructor TCnCppScanner.Create(Stream: TStream);
var
  N: Integer;
begin
  inherited Create;
  FSource := '';
  if Stream <> nil then
  begin
    N := (Stream.Size - Stream.Position) div SizeOf(Char);
    if N > 0 then
    begin
      SetLength(FSource, N);
      Stream.Read(FSource[1], N * SizeOf(Char));
    end;
  end;
  FIndex := 1;
  FLine := 1;
  FColumn := 1;
  FAtLineStart := True;
end;

function TCnCppScanner.Peek(Offset: Integer): Char;
var
  P: Integer;
begin
  P := FIndex + Offset;
  if (P < 1) or (P > Length(FSource)) then Result := #0
  else Result := FSource[P];
end;

function TCnCppScanner.Take: Char;
begin
  Result := Peek;
  if Result = #0 then Exit;
  Inc(FIndex);
  if Result = #10 then
  begin
    Inc(FLine);
    FColumn := 1;
    FAtLineStart := True;
  end
  else
  begin
    Inc(FColumn);
    if not (Result in [#13, ' ', #9]) then FAtLineStart := False;
  end;
end;

function TCnCppScanner.MakeToken(Kind: TCnCppTokenKind; Start, Line,
  Col: Integer): TCnCppToken;
begin
  Result := TCnCppToken.Create(Kind, Copy(FSource, Start, FIndex - Start),
    Line, Col, Start - 1);
end;

function TCnCppScanner.IsIdentStart(C: Char): Boolean;
begin
  Result := (C in ['A'..'Z', 'a'..'z', '_']) or (Ord(C) >= 128);
end;

function TCnCppScanner.IsIdentChar(C: Char): Boolean;
begin
  Result := IsIdentStart(C) or (C in ['0'..'9']);
end;

function TCnCppScanner.ReadQuoted(Quote: Char; Kind: TCnCppTokenKind): TCnCppToken;
var
  S, L, C: Integer;
  Escaped: Boolean;
begin
  S := FIndex; L := FLine; C := FColumn;
  Take; Escaped := False;
  while Peek <> #0 do
  begin
    if (Peek = #10) and not Escaped then Break;
    if (Peek = Quote) and not Escaped then begin Take; Break end;
    if Peek = '\' then Escaped := not Escaped else Escaped := False;
    Take;
  end;
  Result := MakeToken(Kind, S, L, C);
end;

function TCnCppScanner.ReadPrefixedQuoted(const Prefix: string; Quote: Char;
  Kind: TCnCppTokenKind): TCnCppToken;
var
  S, L, C, I: Integer;
begin
  S := FIndex; L := FLine; C := FColumn;
  for I := 1 to Length(Prefix) do Take;
  while (Peek <> #0) and (Peek <> Quote) do Take;
  if Peek = Quote then
  begin
    Take;
    while Peek <> #0 do
    begin
      if Peek = Quote then begin Take; Break end;
      if Peek = '\\' then begin Take; if Peek <> #0 then Take end
      else Take;
    end;
  end;
  Result := MakeToken(Kind, S, L, C);
end;

function TCnCppScanner.ReadRawString(PrefixLength: Integer): TCnCppToken;
var
  S, L, C, I: Integer;
  Delimiter, EndMarker: string;
begin
  S := FIndex; L := FLine; C := FColumn;
  for I := 1 to PrefixLength do Take;
  if Peek = '"' then Take;

  Delimiter := '';
  while (Peek <> #0) and (Peek <> '(') and not (Peek in [#13, #10]) do
    Delimiter := Delimiter + Take;
  if Peek = '(' then Take;

  EndMarker := ')' + Delimiter + '"';
  while Peek <> #0 do
  begin
    if Copy(FSource, FIndex, Length(EndMarker)) = EndMarker then
    begin
      for I := 1 to Length(EndMarker) do Take;
      Break;
    end;
    Take;
  end;
  Result := MakeToken(ctkString, S, L, C);
end;

function TCnCppScanner.ReadOperator: TCnCppToken;
var
  S, L, C, Best: Integer;
  Candidate: string;
begin
  S := FIndex; L := FLine; C := FColumn; Best := 0;
  Candidate := Copy(FSource, FIndex, 3);
  if (Candidate = '>>=') or (Candidate = '<<=') or (Candidate = '->*') then Best := 3;
  if Best = 0 then
  begin
    Candidate := Copy(FSource, FIndex, 2);
    if (Candidate = '++') or (Candidate = '--') or (Candidate = '==') or
      (Candidate = '!=') or (Candidate = '<=') or (Candidate = '>=') or
      (Candidate = '&&') or (Candidate = '||') or (Candidate = '+=') or
      (Candidate = '-=') or (Candidate = '*=') or (Candidate = '/=') or
      (Candidate = '%=') or (Candidate = '&=') or (Candidate = '|=') or
      (Candidate = '^=') or (Candidate = '<<') or (Candidate = '>>') or
      (Candidate = '->') or (Candidate = '::') or (Candidate = '.*') or
      (Candidate = '##') then Best := 2;
  end;
  if Best = 0 then Best := 1;
  while Best > 0 do begin Take; Dec(Best) end;
  Result := MakeToken(ctkOperator, S, L, C);
  if not CnCppIsBinaryOperator(Result.Text) then Result.Kind := ctkSymbol;
end;

function TCnCppScanner.NextToken: TCnCppToken;
var
  S, L, C: Integer;
  Ch: Char;
begin
  while Peek in [' ', #9, #13] do Take;
  if Peek = #0 then
  begin
    Result := TCnCppToken.Create(ctkEOF, '', FLine, FColumn, FIndex - 1);
    Exit;
  end;
  S := FIndex; L := FLine; C := FColumn; Ch := Peek;
  if Ch = #10 then
  begin
    Take;
    Result := MakeToken(ctkNewLine, S, L, C);
    Exit;
  end;
  if FAtLineStart and (Ch = '#') then
  begin
    while (Peek <> #0) and not (Peek in [#13, #10]) do Take;
    Result := MakeToken(ctkPreprocessor, S, L, C);
    Exit;
  end;
  if (Ch = '/') and (Peek(1) = '/') then
  begin
    Take; Take;
    while (Peek <> #0) and not (Peek in [#13, #10]) do Take;
    Result := MakeToken(ctkLineComment, S, L, C);
    Exit;
  end;
  if (Ch = '/') and (Peek(1) = '*') then
  begin
    Take; Take;
    while Peek <> #0 do
    begin
      if (Peek = '*') and (Peek(1) = '/') then begin Take; Take; Break end;
      Take;
    end;
    Result := MakeToken(ctkBlockComment, S, L, C);
    Exit;
  end;
  if Ch = '"' then begin Result := ReadQuoted('"', ctkString); Exit end;
  if Ch = '''' then begin Result := ReadQuoted('''', ctkChar); Exit end;
  if (Ch = 'R') and (Peek(1) = '"') then
  begin
    Result := ReadRawString(1); Exit
  end;
  if (Ch = 'u') and (Peek(1) = '8') and (Peek(2) = 'R') and
    (Peek(3) = '"') then
  begin
    Result := ReadRawString(3); Exit
  end;
  if ((Ch = 'u') or (Ch = 'U') or (Ch = 'L')) and (Peek(1) = 'R') and
    (Peek(2) = '"') then
  begin
    Result := ReadRawString(2); Exit
  end;
  if ((Ch = 'u') or (Ch = 'U') or (Ch = 'L')) and
    ((Peek(1) = '"') or ((Ch = 'u') and (Peek(1) = '8') and (Peek(2) = '"'))) then
  begin
    if (Ch = 'u') and (Peek(1) = '8') then
      Result := ReadPrefixedQuoted('u8', '"', ctkString)
    else
      Result := ReadPrefixedQuoted(Ch, '"', ctkString);
    Exit;
  end;
  if IsIdentStart(Ch) then
  begin
    Take;
    while IsIdentChar(Peek) do Take;
    Result := MakeToken(ctkIdentifier, S, L, C);
    Exit;
  end;
  if Ch in ['0'..'9'] then
  begin
    Take;
    while Peek in ['A'..'Z', 'a'..'z', '0'..'9', '.', '_'] do Take;
    Result := MakeToken(ctkNumber, S, L, C);
    Exit;
  end;
  Result := ReadOperator;
end;

end.
