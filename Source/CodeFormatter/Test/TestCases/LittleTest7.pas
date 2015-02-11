unit LittleTest7;

{ AFS 9 June 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

  test basics of operators without spacing
  x<-1 should parse as 'x' '<' '-1' }

interface

implementation

procedure Foo;
var
  liBar: integer;
begin
  liBar := -100;
  while liBar<-10 do
  begin
  end;
end;

procedure Foo2;
var
  liBar: integer;
begin
  liBar := 100;
  while liBar>=-1 do
  begin
  end;
end;

end.
