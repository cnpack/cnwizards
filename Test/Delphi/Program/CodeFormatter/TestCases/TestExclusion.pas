unit TestExclusion;

{ AFS 11 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit test the exclusions comments }
 {(*}  {*)}

{ between these two comments, no code formatting is done }


interface

implementation

uses SysUtils;

function Fred: string;
begin
  Result := IntToStr (Random (20));
end;

{ do not format }
{(*}
function Fred2: string;
function GetARandomNumber: integer;
begin
Result := Random (20);
end;
begin
Result := IntToStr (GetARandomNumber);
end;

function Fred3: string;

function GetARandomNumber: integer;

function GetLimit: integer;
begin
Result := 20;
end;
{ can format again } {*)}
  begin
    Result := Random (GetLimit);
  end;

begin
  Result := IntToStr (GetARandomNumber);
end;


procedure Jim3 (var ps1: string; const ps2: string);
var
  ls3: string;
begin
  ls3 := FRED;
  { unformatted line coming up }
  {(*} if ps1 = '' then ls3 := 'Fred' else ls3 := 'NotFred'; {*)}
end;

procedure Jim4 (var ps1: string; const ps2: string);
var ls3: string; begin ls3 := FRED;
  { unformatted line coming up }
  //jcf:format=off
  if ps1 = '' then ls3 := 'Fred' else ls3 := 'NotFred';
  //jcf:all=on
end;

procedure Jim5 (var ps1: string; const ps2: string);
var ls3: string; begin ls3 := FRED;
  { unformatted line coming up }
  //jcf:format=off
  if ps1 = '' then ls3 := 'Fred' else ls3 := 'NotFred';
  //jcf:format=on
end;

end.
