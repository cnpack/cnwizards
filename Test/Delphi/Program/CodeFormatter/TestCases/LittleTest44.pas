unit LittleTest44;


{ AFS 10 Sept 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 code from Adem baba
 }

interface

implementation

uses SysUtils;

procedure Foo(Value: double; Bufferlo: PChar);
var
bar: array [0..13] of Byte absolute Value;
I: Byte;
begin
 I := Round(value);

if (Value < 0) then
begin
for I:=0 to 12 do
(Bufferlo+(7-I))^:=Chr(bar[I - 2] xor $FE);
end
else
begin
Bufferlo^:=Chr((bar[6 + I] or $F0));
for I:=0 to 12 do
(Bufferlo+(7-I))^:=Chr(bar[I]);
end;
end;

Procedure Bar;
const
  MAX_KEYLEN = 43;
  FLDCHG_DATA = 12;
  TEXT_FLDNUM_SIZE = 3;
var
   FirstIndexKeyBuffer: array [0..MAX_KEYLEN-1] of Char;
begin
 (StrEnd(@FirstIndexKeyBuffer[FLDCHG_DATA+TEXT_FLDNUM_SIZE])-1)^:=#0; {<--HERE}
end;

end.
