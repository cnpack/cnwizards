unit TestParams;

{ AFS 26 Dec 2002
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

procedure ArrayProc1(foo: array of const);
procedure ArrayProc2(var foo: array of const);

procedure fred2(var foo);
procedure fred3(var foo; const bar);
procedure fred4(var foo, bar);
procedure fred5(const foo);

implementation


procedure ArrayProc1(foo: array of const);
begin
end;

procedure ArrayProc2(var foo: array of const);
begin
end;

procedure fred2(var foo);
begin
end;

procedure fred3(var foo; const bar);
begin
end;

procedure fred4(var foo, bar);
begin
end;

procedure fred5(const foo);
begin
end;


end.
