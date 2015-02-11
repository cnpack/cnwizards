unit LittleTest13;

{ This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 #13. pointers}

interface

implementation

type
  PInteger = ^integer;

procedure Foo;
var
  li: integer;
  lp: pointer;
begin
  li := 3;
  lp := @li;
  PInteger(lp)^ := 4;
end;

end.
