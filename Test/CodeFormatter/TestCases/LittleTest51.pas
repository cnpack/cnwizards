unit LittleTest51;

{ AFS October 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

implementation

function Foo: string;
begin
  Result := 'foo';
end;

procedure Bar;
var
  ch: char;
  li: integer;
begin
  li := 3;

  ch := #32;
  { string subscripting where the string is the result of an expr }
  ch := Foo[1];
  ch := Foo[li + 3];
  ch := (Foo + Foo)[1];
  ch := (Foo + #32)[li + 3];
  ch := (#32 + #32)[2];
end;

end.
