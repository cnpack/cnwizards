unit TestVarParam;

{ AFS 5 Feb 2K

  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  this unit tests untyped var params
}

interface

implementation

procedure MangleData(var Data);
begin

end;

procedure CallMangleData;
var
  foo: String;
  bar: pchar;
begin
  foo := 'hello';
  MangleData(foo);

  bar := pchar(foo);
  MangleData(bar);
  MangleData(bar^);

  MangleData(pchar(foo)^);
end;

end.
