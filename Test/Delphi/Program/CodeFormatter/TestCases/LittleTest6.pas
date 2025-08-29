unit LittleTest6;

{
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 a minimal unit }


interface

function Bar: integer;

implementation

function Foo: integer;
begin
  Result := 3;
end;

function Bar: integer;
begin
  Result := Foo() + 3;
end;

end.
