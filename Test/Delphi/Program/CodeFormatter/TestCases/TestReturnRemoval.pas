unit TestReturnRemoval;

{ AFS 6 June 2001
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests return removal
}


interface

implementation

procedure ParamsWithToManyReturns(a, b,
  c: integer;
  d: string;
  e, f, g: Double
  );
begin
end;

procedure VarsWithTooManyReturns;
var
  a,
  b,
  c: integer;
  d, e,
  f, g: string;
begin
  a := Random(10);
end;

procedure ExpessionWithReturns;
var
  a,b,c: integer;
begin
  a := Random(10) +
  Random(10) +
  Random(10);

  b := 3 * a +
   Random(10) *

   4;
end;

procedure BlankVarLines;


var

  a,b,c: integer;

  d,e,f: integer;

begin

end;

procedure NoVarsBlankLines;




begin

end;

end.
