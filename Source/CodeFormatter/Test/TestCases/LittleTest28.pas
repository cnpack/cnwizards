unit LittleTest28;


{ This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

implementation

function Bar: Pointer;
begin
  Result := nil
end;

procedure Foo;   asm  mov eax,  1; call Bar; jmp eax; end;


end.
 