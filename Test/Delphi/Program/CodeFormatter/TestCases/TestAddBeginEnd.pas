unit TestAddBeginEnd;

interface

implementation

procedure TestIf;
var
  Str1: string;
  bFoo: Boolean;
  iFish: integer;
begin
  if bFoo then
  Str1 := '';

  if bFoo then
  begin
    Str1 := '';
  end;

    if bFoo then
  Str1 := 'troo'
    else
  Str1 := 'fals';

    if bFoo then
    begin
  Str1 := 'troo';
    end
    else
  Str1 := 'fals';

    if bFoo then
    begin
  Str1 := 'troo';
    end
    else
    begin
  Str1 := 'fals';
  end;

    if bFoo then
  Str1 := 'troo'
    else
    begin
  Str1 := 'fals';
  end;
end;

procedure TestCases;
var
  Str1: string;
  bFoo: Boolean;
  iFish: integer;
begin

  case iFish of
  1:
    bFoo := True;
  2:
  begin
    bFoo := False;
  end;
  else
    bFoo := False;
  end;


  case iFish of
  1:
    bFoo := True;
  else
    begin
    bFoo := False;
  end
  end;

  case iFish of
  1:
    bFoo := True;
  else
    bFoo := False;
    Str1 := 'troo';
  end;

end;

procedure TestLoop;
var
  lbTest: boolean;
  sFoo: string;
  liLoop: integer;
begin
  while lbTest do
    lbTest := not lbTest;

  for liLoop := 0 to 10 do
    sFoo := sFoo + '-';
end;

end.
 