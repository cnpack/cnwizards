unit TestInitFinal;

{ AFS 1 March 2K
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests layout of the code in the init and final section
}

interface

var SomeGlobalSeed: integer; Fred: TObject;

implementation

uses Classes, SysUtils;

function RandomInt: integer;
begin
  Result := Random (1000);
end;

initialization
   SomeGlobalSeed := RandomInt;

if SomeGlobalSeed > 20 then begin
while  SomeGlobalSeed > 20 do begin
SomeGlobalSeed := SomeGlobalSeed - RandomInt div 100; end; end;


fred := TList.Create;


finalization

while RandomInt < 20000 do
begin
FreeAndNil (Fred);
SomeGlobalSeed := 0;
end;

end.
