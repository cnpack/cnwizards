unit TestEsotericKeywords;

{ AFS 11 March 2K test local types

  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  Test the threadvar, absolute, packed, etc

}


interface

var
Fred, Vodka: integer;
var
  Jim2: integer;

threadvar
Jim: real;

var
      ey:       integer;

threadvar
  I: integer;
  broom: boolean;

var Drink: real absolute Vodka;

type TCow = packed record i1: integer; s2: string;
b3: Boolean; end;

    TMoo = packed array [1..10] of TCow;


resourcestring Greeting  = 'Hello';

implementation

threadVar
  Herd: TMoo;

function JustSayNo: Boolean; assembler;
begin
  Result := False;
end;


{ the JCLDebug unit does this with the __FILE__ etc fns }
function _ThisFunctionStartsWithAnUnderscore: Boolean;
begin
  Result := True;
end;

function __ThisFunctionStartsWithAnUnderscore: Boolean;
begin
  Result := _ThisFunctionStartsWithAnUnderscore;
end;

function ___ThisFunctionStartsWithAnUnderscore: Boolean;
begin
  Result := __ThisFunctionStartsWithAnUnderscore;
end;


end.
