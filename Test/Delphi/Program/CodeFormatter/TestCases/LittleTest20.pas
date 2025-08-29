unit LittleTest20;

{ This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
 to test a dangling else keyword }

interface

implementation

procedure DangingElse(i: integer);
begin
  begin
    if 1 > 3 then
    begin
    end
    else
  end;
end;

end.
