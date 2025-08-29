unit LittleTest36;

{ This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

{ the final semicolon is omitted in some cases
  Why? Just confuse use. }

procedure Foo; external 'foo.dll' name '__foo'
procedure Bar; external 'bar.dll' name '__bar'


implementation

procedure Foo2; external 'foo.dll' name '__foo'
procedure Bar2; external 'bar.dll' name '__bar'


end.
