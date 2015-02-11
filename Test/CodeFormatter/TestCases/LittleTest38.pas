unit LittleTest38;

{ AFS 23 August 2003
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

implementation

procedure Foo;
begin
  asm
    MOV     [ESI].TTextRec.BufSize, TYPE TTextRec.Buffer
  end
end;

end.
