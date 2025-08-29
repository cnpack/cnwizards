unit TestForward;

{ AFS 7 Feb 2K

  this is legal, if somewhat obscure code
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests the somewhat obscure "forward" keyword

since the only legitimate use of the forward keyword is to enable mutual recursion
  This example will do that
}

interface

implementation


procedure Haggis; forward; function Fred (b1, b2: Boolean): Boolean; Forward;

var
  liWonk: integer;

procedure Jim;
var
  b: Boolean;
begin
  b := False;
  b := Fred (True, b);
  Fred (b,b);
end;

function Joe: integer; forward;
function Fred;
begin
  // function body need not have the parameters specified again, or the return type. Yuk.
  Result := b1 or b2;
  Haggis;
end;

const
  NARF = 'So, what are we going to do tonight, brain?';

function Joe: integer;
begin
  Result := 3;
  liWonk := 12;
end;

procedure Haggis;
begin
  Fred (True, Joe > 4);
end;


procedure Bob1; forward;

procedure Bob2;
begin
  Bob1;
end;

Function Fugu1: integer; safecall; forward;

procedure Bob1;
begin
  Bob2;
end;

function Fugu2: integer; safecall;
begin
  Result :=  Fugu1 * 2;
end;


function Fugu1: integer;
begin
  Result := Fugu2 div 2;
end;


end.
