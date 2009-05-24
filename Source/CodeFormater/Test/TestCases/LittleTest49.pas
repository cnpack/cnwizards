unit LittleTest49;

{ AFS 7 October 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

implementation

Function Foo: integer;
begin
  Result := Random(10);
end;

procedure Bar;
label
  gTarget;
begin
  try
    if Foo > 3 then
      goto gTarget;

      // label just before finally
      gTarget:
  finally
    Foo;
  end;
end;


procedure Fish;
label
  gTarget;
begin
  Bar;

  try
    if Foo > 3 then
      goto gTarget;

      // label just before except
      gTarget:
  except
    Bar;
  end;
end;

end.
