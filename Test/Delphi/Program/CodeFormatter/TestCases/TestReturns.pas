unit TestReturns;

{afs 20 May 2K
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

  I saw some sample code this week where the programmer put a return before
  the 'then' keyword. Otherwise the code was good so we may employ that person
  better stop the rot before it begins at test for it
}


interface

implementation

uses Dialogs;

procedure ReturnBeforeThen;
var
  i
  : integer;
begin
  i := Random(20);

  if i < 5
  then begin
    ShowMessage('Fred');
  end;

  if 1 < 5
  // this is a dangerous comment
  then
    dec(i);

  while i < 10
do Dec(i);

 i
  := i
  + 1;

end;

end.
