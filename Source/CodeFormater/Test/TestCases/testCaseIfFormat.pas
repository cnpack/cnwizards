unit testCaseIfFormat;

interface

type
  TRecord = Record
    bar1: integer;
    bar2: integer;
  end;

implementation

uses SysUtils;

function foo1(const pi: integer): boolean;
begin
  Result := (pi mod 2) = 0;
end;

function Foo(Bar: TRecord): Word;
begin
case bar.bar1 of
1: if not foo1(bar.bar2) then
Result := 31
else
Result := 32;
2: if not foo1(bar.bar2) then
Result := 28
else
Result := 29;
3: Result := 7;
4: Result := 4;
5: Result := 9;
6: Result := 6;
7: Result := 11;
8: Result := 8;
9: Result := 5;
10: Result := 10;
11: Result := 7;
12: Result := 12;
else
raise Exception.Create('message');
end;
end;

end.
