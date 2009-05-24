unit TestWarnings;

interface

{ AFS 27 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This code test constructs that are warned against
 So expect to see things that are dodgy
}


type
  TWhatever = class
  public
    function MemberFoo: integer;
    function memberBar: integer;

    procedure EmptyMember;
  end;


implementation

uses Classes, TestDeclarations;

var
  Fred: real;

var
  fi, fifi, fo, fun: real48;

procedure BadDestructor;
var
  lc: TObject;
begin
  { note that the instance var is the wrong class
    This is Legal and OK if you destroy the right way
  }
  lc := TStringList.Create;
  try
    // do some stuff
  finally
    lc.Destroy; // this is not the right way
  end;

end;

procedure BadCases;
var
  li, li2: integer;
begin
  li  := Random(10);
  li2 := Random(10);

  case li of
    1: Inc(li);
    else
      case li of
        1: BadDestructor;
      end;
  end;
end;

procedure EmptyBlock;
begin

end;

procedure EmptyBlocks;
begin

  begin
    { no comment }
  end;
  begin
    begin
    end;
  end;

  try
    EmptyBlock;
  except
    // do nothing
  end;

  try

  finally
    EmptyBlock;
  end;

end;


// assignement to the fn name is obsolete, use the Result var
function SelfFn: integer;
begin
  SelfFn := 3;
end;

function Spon: integer;

  function Jim: integer;
  begin
    Jim := 4;
  end;

begin
  Spon := Jim + 3;
end;


// again, asignment to the fn name, but this time with an object type
function TWhatever.MemberFoo: integer;
begin
  MemberFoo := 3;
end;

function Twhatever.MemberBar: integer;

  function fish: integer;
  begin
    fish := 3;
    fish := fish + 1;
  end;

begin
  MemberBar := fish + 3;
end;


procedure TWhatever.EmptyMember;
var
  foo: real;
begin

end;

function Fred1: integer;
begin
  TestDeclarations.Fred1 := 3;  // this is not an assign to the function name
  Result := 3;
end;

function Fred2: integer;
begin
  TestWarnings.Fred2 := 3;  // this *is* an assign to the function name
  Result := 3;
end;


{ assing to function name,
  interesting in that you can't do this with 'Result'
  but pathological case }
function Level1: integer;

  function Level2: integer;

    function Level3: integer;
    begin
      Level1 := 5;
      Level2 := 6;
      Level3 := 7;
    end;

  begin
    Level1 := 3;
    Level2 := Level3;
  end;

begin
  Level1 := 0;
  Level1 := Level2 + Level1;
end;

end.

