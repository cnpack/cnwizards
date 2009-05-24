unit TestDeref;

interface

implementation

uses
  Classes;

type
  TAmoeba = class;
  PTAmoeba = ^TAmoeba;

  TAmoeba = class(TObject)
  private
    fsName: string;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetStuff(const psIndex: string): TAmoeba;
    procedure GetValueList(List: TStrings);

  public
    function GetBar(const piIndex: integer): TAmoeba;
    function MyFudgeFactor: TAmoeba;
    function Pointer: PTAmoeba;
    function MyIndex: integer;

    property Name: string read GetName write SetName;
    property Stuff[const psIndex: string]: TAmoeba read GetStuff;
  end;

procedure TestHatExpr(var Foo: TAmoeba);
begin
  { modeled on an expression in Delphi source }
  if ((Foo.Stuff['x'].Pointer)^.MyIndex = 0) then
    Foo := nil;
end;

procedure DoTestDeref(var Foo: TAmoeba);
var
  ls: string;
begin
  // the goal of this unit is to get the following silly line to compile
   foo.GetBar(1).Stuff['fish'].MyFudgeFactor.GetBar(2).Name := 'Jiim';

   // let's try this one
   ls := foo.Stuff['fish'].GetBar(1).MyFudgeFactor.GetBar(2).Name;
end;

{ TAmoeba }

function TAmoeba.getBar(const piIndex: integer): TAmoeba;
begin
  Result := self;
end;

function TAmoeba.GetName: string;
begin
  result := fsName;
end;

function TAmoeba.GetStuff(const psIndex: string): TAmoeba;
begin
  Result := self;
end;

function TAmoeba.MyFudgeFactor: TAmoeba;
begin
  Result := self;
end;

procedure TAmoeba.SetName(const Value: string);
begin
  fsName := Value;
end;

{ this line echoes the structure code in BDReg.pas that failed }
procedure TAmoeba.GetValueList(List: TStrings);
begin
  (GetStuff('0') as TAmoeba).MyFudgeFactor.GetValueList(List);
end;

function TAmoeba.Pointer: PTAmoeba;
begin
  Result := @self;
end;

function TAmoeba.MyIndex: integer;
begin
  Result := 1;
end;

end.
