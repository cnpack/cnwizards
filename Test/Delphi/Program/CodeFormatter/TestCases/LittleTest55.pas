unit LittleTest55;

{ AFS 28 Oct 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

implementation

procedure Foo;
var
  i: integer;
begin
{$IF Defined(LINUX)}
   i := 42;
{$ELSEIF Defined(MSWINDOWS)}
  i := 23;
{$ELSE}
   {$MESSAGE ERROR 'foo not implemented'}
{$IFEND}
end;


end.
