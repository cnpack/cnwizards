unit TestLayout;

{ AFS 9 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests layout functionality
}

interface

implementation

uses SysUtils, Classes;

{ layout vars }
procedure TestSimpleVarLayout;
var
  iFred: integer;
  bB: Boolean;
  begin
    end;

procedure TestSimpleVarLayout2;
var
  v1: integer;
  var2: integer;
  begin end;

{ simple block layout }
procedure AllNeatlyLaidOut;
var
  iA, iB1, iCC2: integer;
  bA: Boolean;
begin

  iA := Random (10);
  iB1 := 0;
  iCC2 := 0;

  if Random (10) > 5 then begin iA := Random (10);
  iB1 := 0;
  iCC2 := 0;

    { this comment is indented }
    if Random (10) > 5 then
    begin iA := Random (10);
      iB1 := 0;
    iCC2 := 0;

      // a run on line
      bA := (AnsiCompareText ('fred', 'jim') > 0) and (random (10) > 5) or
        (random (20) > 15) or (random (20) > 15) or (random (20) > 15) or
        (random (20) > 15) or (random (20) > 15) or (random (20) > 15);

    end; end else
    iA := 0; end;

procedure AlignTheEqualsSigns;
var
  v1: integer;
  var2: integer;
  variable3: integer;
  variable4WithALongName: integer;
begin
  { first set }
  v1 := 0;
  var2 := v1 + 1;
  v1 := var2 + v1;

  { second set }
  v1 := 0;
  var2 := v1 + 1;
  variable3 := var2 + 1;
  var2 := v1 + 1;
  v1 := var2 + v1;

  { third set }
  var2 := v1 + 1;
  variable3 := var2 + 1;
  variable4WithALongName := 12;
  var2 := v1 + 1;
  v1 := var2 + v1;

  { set with long at start}
  variable4WithALongName := 12;
  var2 := v1 + 1;
  v1 := 0;


end;

procedure AlignLongLine;
var
  v1: integer;
  var2: integer;
  variable3: integer;
  VariableWithAnExceedinglyLongNameIndeed: integer;
begin
  v1 := 0;
  var2 := v1 + 1;
  variable3 := var2 + 1;
  VariableWithAnExceedinglyLongNameIndeed := 42;
  v1 := 0;
  var2 := v1 + 1;
end;

{ demonstrating that the last semicolon in a block does not need a semicolon
 and a semicolon must be absent before the else
 also note indentation of the single statement under the else
}
procedure NoSemicolonsNeeded;
var
  la: integer;
begin
  la := 0;

  if Random (10) > 2 then
  begin if Random (20) > 5 then
    begin
    la := 12
    end
    else
    la := 10
  end
  else
  la := 20
end;

procedure TheReverse;
var
  v1: integer;
  var2: integer;
  variable3: integer;
  variable43: integer;
  VariableWithAnExceedinglyLongNameIndeed: integer;
  lcThisIsALongNameForAStringList: TStringList;
begin
  lcThisIsALongNameForAStringList := TStringList.Create;

  VariableWithAnExceedinglyLongNameIndeed := 42;
  v1 := 0;
  var2 := v1 + 1;
  variable3 := var2 + 1;

  VariableWithAnExceedinglyLongNameIndeed := 42;
  variable3 := var2 + 1;
  variable43 := 12;
  v1 := 0;
  var2 := v1 + 1;

  VariableWithAnExceedinglyLongNameIndeed := 42;
  variable43 := 12;
  variable3 := var2 + 1;
  var2 := v1 + 1;
  v1 := 0;

  // just no fricking way that the second line should align to the first
  lcThisIsALongNameForAStringList[VariableWithAnExceedinglyLongNameIndeed] := 'Hello';
  v1 := 0;

  lcThisIsALongNameForAStringList.Free;
end;

procedure TestRepeat;
var
  li: integer;
begin
  li := 0;
  repeat
    inc(li);
  until li > 10;

  li := 0;
  repeat
  begin
    inc(li);
  end
  until li > 10;

  li := 0;
  repeat
    inc(li);
    dec(li);
    inc(li);
  until li > 100;

  li := 0;
  repeat
    inc(li);
    begin
      dec(li);
    end;
    inc(li);
  until li > 100;
end;


end.
