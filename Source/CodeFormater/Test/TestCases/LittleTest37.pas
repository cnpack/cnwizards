unit LittleTest37;

{
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

implementation

const
  MONKEY = Integer($80000000);
  SOY    = Integer($40000000);


procedure Foo;
begin

  asm
    MOV     EAX, MONKEY OR SOY
  end;

end;

end.
