unit TestAtExpr;

{ AFS 9 June 2003
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
  code based on a line in Delphi Com source

  Basically an assignment that starts with an '@'
}

interface

implementation
                                  
uses Windows;

type
  TFooProc = procedure stdcall;

procedure FindTheFoo(FooHandle: THandle);
var
  FooProc: TFooProc;
begin
  @FooProc := GetProcAddress(FooHandle, 'Foo');
end;

end.
