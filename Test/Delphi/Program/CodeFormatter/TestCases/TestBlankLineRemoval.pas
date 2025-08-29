unit TestBlankLineRemoval;

{ AFS 7 August 2001
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests blank line removal }

interface

implementation

uses SysUtils;

procedure TestBlankLines1;
var

  a: integer;


  b: string;

c,  d  ,e,f: double;
begin
end;

procedure TestBlankLines2;
var


  a: integer;


  function GetA: integer;
  begin
    Result := a + 1;
  end;

var

  b: string;


c,  d  ,e,f: double;

begin
end;


procedure TestBlankLines3;
var


  a: integer;

  function GetA: integer;
  begin
    Result := a + 1;
  end;

var

  b: string;

  function GetB: string;
  begin
    Result := b + IntToStr(a);
  end;


var


c,  d  ,e,f: double;

begin
end;



procedure TestBlankLines4;
var

  a: integer;

  function GetA: integer;
  var

    x,y, z: currency;

    q: string;
  begin
    Result := a + 1;
  end;

var

  b: string;



c,  d  ,e,f: double;

begin
end;



end.
 