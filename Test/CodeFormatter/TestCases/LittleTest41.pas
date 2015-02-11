unit LittleTest41;

{ AFS 29 August 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }


interface

implementation

{ "-delimited string in asm }
procedure Foo;
begin
  asm
   CMP AL, "'"
  end;
end;

end.
