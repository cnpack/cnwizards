unit TestDeclarations;

{ AFS 9 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit contains simple var, const & procedure declarations
   also uses a few of the more complex features of the language ie
  - use of var and const in declarations & param lists,
  - use of the procedure and function keywords in type defs
}

interface

  { untyped consts }
  const FRED_CONST_1 = 34;
    FRED_CONST_TWO = 'Fred';
GIMP = 'Glump';
MO_MONEY = 123.45;
PIGS_CAN_FLY = False;

{ typed constants }
FRED_NAME: string = 'Fred!';
FRED_COUNT: integer = 2;
FRED_MONEY: currency = 234.4;

MaxAmount1 = 9.9E+10;      { plus 99 billion      }
MaxAmount2 = +9.9E+10;
MinAmount = -9.9E+10;

TinyAmount1 = 9.9E-10;
TinyAmount2 = +9.9E-10;
TinyAmount = -9.9E-10;


  { resourcestring consts }
resourcestring
  CreateError = 'Cannot create fred %s';        {  for explanations of format specifiers, }
  OpenError = 'Cannot open fool %s';            { see 'Format strings' in the online Help }
  LineTooLong = 'Line too silly';
  ProductName = 'CodeFormat\000\000';
  SomeResourceString = GIMP;


{ from kylix docs but compiles in D5:
  different kinds of type renaming }

Type T1 = integer;
Type T2 = type integer;
Type TIntSubrange = -12 .. 23;

const

{ funny chars }
BIT_TWIDDLED: integer = $F00F;
HEX_VALUE: integer = $0BADBEEF;
MY_FAVORITE_LETTER: char = #96;

{ sets }
type
TStuff = (eThis, eThat, eTheOther, eSomethingElse, Fish, Wibble, Spon);
TStuffSet = set of  TStuff;
{ subrange on an enumerated type }
TSillyStuff = Fish .. Spon;

const
  MyStuff = [eThis, eTheOther];
  OtherStuff = [eThat, eSomethingElse];

  // found this as  a code e.g. in the kylix docs, doesn't compile in D5
  {
type
  TSizeEnumWithAssignedOrds =
    (Small = 5, Medium = 10, Large = Small + Medium);
  }
  
var Fred1: integer;
FredTwo: string;
    F3: Boolean;

MyFile: File;
MyIntFile: File of integer;


type TFredProc = procedure(var psFred: INTeger) of Object;
  TFredFunction = function (const psFred: String): string;
TMultiParamFn = function   (a: integer; b: string; c: currency): TObject;

TBadlySpacedFn = function (a:integer;b:string   ;  c   :   currency    ;   d   : string)  : TObject;

TMultiLineFn=function(a:integer;
b:string;
c:currency;d:string):
TObject of object;

TMultiLineFn2=function(a:integer;
const b:string;
   var c:currency;d:string):
TObject of object;


TFluggle = array [1..10] of boolean;
    TFlig = array [1..12] of INTEGER;

{ initialised vars }
var
  Fred3: integer = 42;
  MyFluggle: TFluggle =  (True, False, True, True, False,
    True, False, True, True, False);
  MyFlig: TFlig = (1,2,3,4,5,6,7,8,9,10,11,12);

 function FnFred (var piFred: integer): integer;
    function FnFredConst (const psFred: string): string;

implementation


function FnFred (var piFred :integer) : integer;
var liFr: integer;
 lGlimmer: array [4..12] of Double;
begin



  liFr := piFred;
 Result := 3 + liFr;

 if liFr > 12 then begin
  Result := Result * 2; end;

 { array dereference }
 MyFluggle [Result] := MyFlig[piFred + 1] + MyFlig [MyFlig [piFred + 1]] > 10;
end;

function Beeg: double;
begin
  Result := 1;
  Result := Result + 9.9E+10;
end;

function FnFredConst (const psFred: string): string;
const
  FRED_PREFIX = 'Fred ';
resourcestring FOO = 'Foooo';
var
lsFredOne: string;
begin



lsFredOne := psFred;
          Result := FRED_PREFIX + lsFredOne;



    end;


end.
