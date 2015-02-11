unit TestExclusionFlags;


{ AFS 11 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit test the exclusion switches comments }

interface

implementation

procedure TestSpace;
var
  a  : integer;
begin
  a :=   3  ;
  //jcf:space=off
  a    :=   a    +   1  ;
  //jcf:space=on
end;

   procedure TestIndent;
//jcf:indent=off
    var
  a: integer;
  begin
a :=   3;

      if a  > 12 then
    begin
   a := 12;
  //jcf:indent=on
 end;

end;

procedure TestReturn;
var
  a, b: integer;
begin
  if a > 3 then b := 2 else b := -1;
  //jcf:return=off
  if b > 3 then a := 2 else a := -1;
  if b > 3
  then a := 2 else a := -1;
  //jcf:return=on
end;


procedure TestAlign;
var
  // these should align
  a: integer;
  b2: string;
  cthree: double;
begin
  // these won't
  //jcf:align=off
  a := 1;
  b2 := 'hello';
  cthree := 2.3;
  //jcf:align=on

  // these will 
  a := 2;
  b2 := 'world';
  cthree := 3.2;
end;

procedure TestCaps;
VAR
  a: integer;
  lb: boolean;
Begin
    lb := TrUe aNd FALSE;

  //jcf:caps=off

  // these caps will not be fixed
  IF a > 3 thEN
  BEGin
    a := 12;
    lb := FALSE oR TrUe;
  eND;
  //jcf:caps=on
eND;

procedure TestLinebreaking;
var
  LongVariable1, LongVariable2, LongVariable3: integer;
begin
  LongVariable1 := 0;
  LongVariable2 := 2;
  LongVariable3 := 5;

  if (LongVariable1 > LongVariable2) and (LongVariable2 > LongVariable3) and (LongVariable2 <>  LongVariable3) then
  begin
    LongVariable1 := LongVariable2;
  end;

  //jcf:linebreaking=off
  if (LongVariable1 > LongVariable2) and (LongVariable2 > LongVariable3) and (LongVariable2 <>  LongVariable3) then
  begin
    LongVariable1 := LongVariable2;
  end;
  //jcf:linebreaking=on
end;

procedure TestBlockStyles;
begin
  //jcf:blockstyle=off
  //jcf:blockstyle=on
end;


procedure GiveWarnings;
var
  li: integer;
  lr: real;
begin
  li := 3;

  case li of
    2:
    begin
    end;
  end;
end;

//jcf:warnings=off
procedure GiveNoWarnings;
var
  li: integer;
  lr: real;
begin
  li := 3;

  case li of
    2:
    begin
    end;
  end;
end;
//jcf:warnings=on



end.
