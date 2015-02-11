unit TestNested;

{ AFS 11 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit uses nested procs
}
interface

implementation

uses SysUtils;

function Fred: string;
begin
  Result := IntToStr (Random (20));
end;

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

  begin
    Result := Random (GetLimit);
  end;

begin
  Result := IntToStr (GetARandomNumber);
end;


{ the same agian, with more complexity - parameters, local vars and constants }
procedure Jim1 (var ps1: string; const ps2: string);
const
  FRED = 'Jim1';
var
  ls3: string;
begin
  ls3 := FRED;
  ps1 := ls3 + ps2;
end;

procedure Jim2 (var ps1: string; const ps2: string);
const
  FRED = 'Jim2';
  function GetARandomNumber: integer;
  var
    liLimit: integer;
  begin
    liLimit :=  10 * 2;
    Result := Random (liLimit);
  end;
var
  ls3: string;
begin
  ls3 := FRED;
  ps1 := ls3 + IntToStr (GetARandomNumber) + ps2;
end;


procedure Jim3 (var ps1: string; const ps2: string);
const
  FRED = 'Jim3';
var
  ls3: string;
  
  function GetARandomNumber: integer;

    function GetLimit: integer;
    const
      HALF_LIMIT = 10;
    begin
      Result := HALF_LIMIT * 2;
    end;

  var
    liLimit: integer;
  begin
    liLimit := GetLimit;
    Result := Random (liLimit);
  end;

begin
  ls3 := FRED;
  ps1 := ls3 + IntToStr (GetARandomNumber) + ps2;
end;

function
MultiPass:
integer;
  function
  One:



  integer;
  begin
    Result := 1;
  end;
  function Two: integer;
  begin
    Result := 2;
  end;
  function Three: integer;
  begin
    Result := 3;
  end;

begin
  Result := One + Two + Three;
end;

end.
