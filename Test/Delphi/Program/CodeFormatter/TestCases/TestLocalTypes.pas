unit TestLocalTypes;

{ AFS 9 March 2K test local types

  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  procedure-local types are an obscure piece of legacy syntax
  that I would not reccomend to anyone
}

interface

implementation

uses Dialogs;

procedure Fred;
type
  TFred = integer;
const
  FRED = 'hello wold';
var
  li: TFred;
begin
  ShowMessage ('Fred was here');
end;

procedure Jim;
type
  TGoon = (NedSeagoon, Eccles, Bluebottle, HenryCrun, Bloodnok);
  TGoons = set of TGoon;
  pTGoon = ^TGoon;
  pGoonProc = function: TGoon of object;
const
  Protagonist: TGoon = NedSeagoon;
begin
  ShowMessage ('Allo Jiim');
end;

procedure ClasslessSociety;
type
  //TThing = class;
 { this does not compile - it gives
  "error 62. Local class or object types not allowed
  The solution is to move out the declaration of the class or object type to the global scope."

  Thanks for *some* sanity. One could apply that comment to all procedure-local types
 }
  Tbub = Boolean;
  TFredsNumbers = 42..122;
 var
  liWhatFredHas: TFredsNumbers;
begin
end;

procedure HasRecords;
type
  TFoo = record
    liBar: integer;
    liBaz: string;
  end;
  TFoo2 = record Bar: integer;
case Spon: Boolean of True: (Baz: pChar); False: (Fred: integer);
end;

begin
end;

end.
