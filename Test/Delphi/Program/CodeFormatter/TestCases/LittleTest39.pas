unit LittleTest39;

{ AFS 23 August 2003
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

implementation

procedure foo(val: Longint; s: string);
begin
  // special syntax.
  Str(val:0, S);

  // variations on a theme
  Str(val:1 -1, S);
  Str(val: val div 3, S);
  Str(val: (val div 3) + 3 + Length(s), S);
  Str(val: (val div 3) + 3 + Length(s) div val, S);
end;

procedure Bar(val: Longint; s: string);
begin
  // extra special syntax. doesn't even compile
  //Str(Val:20:1,s);
end;

end.
