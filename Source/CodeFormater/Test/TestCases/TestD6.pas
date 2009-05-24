unit TestD6;

{
 AFS 16 Sept 2001
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

  Test keywords & constructs new in Delphi 6
}

interface

function Foo: integer; deprecated;
function Bar: integer; //library;
function Baz: integer; platform;

type

// int subrange type
TFoo = 0..300;
TFoo2 = 1+1 .. (300 * 7);

TRThing1 = record
  foo: integer;
  bar: string;
end deprecated;

TRThing2 = record
  foo: integer;
  bar: string;
end platform;

TRThing3 = record
  foo: integer;
  bar: string;
end library;

TRThing4 = record
  foo: integer;
  bar: string;
end deprecated platform library;

TThing5 = record
  Bar: integer;
  case Spon: boolean of
    True: (Baz5: PChar);
    False: (Fred5: integer;);
end platform;

TMonkey = record
  Bar: integer;
  case TFoo of
    0,1,2,3: (Baz5: PChar);
    4, 42, 300: (Fred5: integer;);
end platform;


TThing6 = record
  Bar: integer;
  case boolean of
    True: (Baz6: PChar);
    False: (Fred6: integer;);
end platform;

TThing7 = record
  Bar: integer;
  Foo: integer deprecated;
  Bar2: integer;
  Foo2: integer library;
end;


TSomeOldClass = class
public
  function foo: integer;
end deprecated;

TSomeOtherClass = class(TSomeOldClass)
  function bar: integer;
end platform;


TSomeMoreClass = class(TSomeOldClass)
  function baz: integer;
end platform deprecated;

// enums with numbers
TCounters = (ni, spon, herring = 12, wibble, fish = 42);

TCounters2 = (soy = 1 + 1, monkey = ((3 * 2) - 1), Shatner);

implementation

var
 li2: integer = 3 deprecated;
 li_x: integer deprecated = 3;
 li_y: integer deprecated = 3 library;
 li_z: integer deprecated platform = 3 library;
 li_a: integer deprecated  = 3 platform library;
 li_b: integer deprecated platform library = 3 deprecated platform library;


function Foo: integer;
var
  li: integer library;
begin
  li := 3;
  Result := li;
end;

function Bar: integer;
var
  li: integer platform;
begin
  li := 4;
  Result := li;
end;

function Baz: integer;
var
  li: integer deprecated;
  li3: integer deprecated platform library;
begin
  li := 5;
  Result := li;
end;

function TSomeOldClass.foo: integer;
begin
  result := 3;
end;

function TSomeOtherClass.bar: integer;
begin
  result := 4;
end;

procedure HasObsoleteRecords;
type
  TFoo = record
    liBar: integer;
    liBaz: string;
  end deprecated;
  TFoo2 = record
    Bar: integer;
    case Spon: boolean of
      True: (Baz: PChar);
      False: (Fred: integer);
  end platform;
begin
end;

{ TSomeMoreClass }

function TSomeMoreClass.baz: integer;
begin
  Result := 5;
end;

end.

