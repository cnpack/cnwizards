unit LittleTest42;

{ AFS 9 Sept 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

implementation

uses Dialogs;

{ numeric labels }
procedure Foo(pi: integer);
label
  10, 20, bar, 42;
begin
  if pi > 12 then
    goto 10;

  ShowMessage('foo');

  goto bar;

 10: ShowMessage('10');

 bar:

 20:

end;

end.
