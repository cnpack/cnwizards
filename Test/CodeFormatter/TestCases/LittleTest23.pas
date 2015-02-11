unit LittleTest23;

{ AFS August 2003
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

implementation

var
  Bar: Boolean;

function Foo(const Chr: Byte): Boolean;
begin
  Result := (Bar) and (Chr in [$B2..$EC]);
end;

end.
