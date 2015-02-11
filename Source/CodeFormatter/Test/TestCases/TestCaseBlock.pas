unit TestCaseBlock;

{ AFS 5 Feb 2K

  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  this unit test the case statement indentation }

interface

implementation

uses SysUtils, Controls, Math;

procedure FromBorlandsStyleGuide;

// the defs are quite bogus, but they make the code compile
const
  csStart = 1;
  csBegin = 2;
  csTimeOut = 3;
  csFoo = 12;
  csBar = 20;
  UpdateValue = 200;

  SB_LINEUP = 1;
  SB_LINEDOWN = 2;
  SB_PAGEUP = 3;
  SB_PAGEDOWN = 4;
var
  Control: TControl;
  NewRange, Position, AlignMargin: integer;
  x, y, j, ScrollCode: integer;
  Incr, FIncrement, FLineDiv, FinalIncr, Count: integer;
  FPageIncrement, FPageDiv: integer;
begin
  NewRange := Max(NewRange, Position);

 // CORRECT
  case Control.Align of
    alLeft, alNone: NewRange := Max(NewRange, Position);
    alRight: Inc(AlignMargin, Control.Width);
  end;
  

  // CORRECT
  case x of

    csStart:
      begin
        j := UpdateValue;
      end;

    csBegin: x := j;
    csFoo:
    x := j;

    csTimeOut:
      begin
        j := x;
        x := UpdateValue;
      end;

  end;
      
  // CORRECT
  case ScrollCode of
    SB_LINEUP, SB_LINEDOWN:
      begin
        Incr := FIncrement div FLineDiv;
        FinalIncr := FIncrement mod FLineDiv;
        Count := FLineDiv;
      end;
    SB_PAGEUP, SB_PAGEDOWN:
      begin
        Incr := FPageIncrement;
        FinalIncr := Incr mod FPageDiv;
        Incr := Incr div FPageDiv;
        Count := FPageDiv;
      end;
  else
    Count := 0;
    Incr := 0;
    FinalIncr := 0;
  end;


  // anthony's additions to test differing styles:

  // naked cases, complex labels, no else
  case x of
  csStart, csBegin:
        j := UpdateValue;
  csFoo .. CsBar, 23:
        j := x + 1;
  csTimeOut:
        j := x;
  end;

   // naked cases, complex labels, an else
  case x of
  csStart, csBegin:
        j := UpdateValue;
  csFoo .. CsBar, 23:
        j := x + 1;
  csTimeOut: j := x;
  else
    inc(j);
  end;

   // block cases, complex labels, no else
  case x of
  csStart, csBegin:
  begin
        j := UpdateValue;
        j := x;
        x :=  x + UpdateValue;
  end;
  csFoo .. CsBar, 23:
  begin
        j := x + 1;
        j := x;
        x :=  x + UpdateValue;
  end;
  csTimeOut:
  begin
        j := x;
        j := j + 1;
  end;
  end;

   // block cases, complex labels, an else
  case x of
  csStart, csBegin:
  begin
        j := UpdateValue;
        j := x;
        x :=  x + UpdateValue;
  end;
  csFoo .. CsBar, 23:
  begin
        j := x + 1;
        j := x;
  end;
  csTimeOut:
  begin
        j := x;
        j := j + 1;
        x :=  x + UpdateValue;
  end;
  else
  begin
    inc(j);
    j := UpdateValue;
    x :=  x + UpdateValue;
  end;
  end;

  // naked else
  case x of
  csStart, csBegin:
        j := UpdateValue;
  else
    inc(j);
    j := UpdateValue;
    x :=  x + UpdateValue;
  end;

  // naked else with funky stuff therein
  case x of
  csStart, csBegin:
        j := UpdateValue;
  else
    if j > 3 then // last remaining indent anomaly - this is not an else..if
    inc(j);
    if x > 4 then
    j := UpdateValue;
    if x = 5 then
    x :=  x + UpdateValue;
  end;

   // naked else with funky stuff therein
  case x of
  csStart, csBegin:
        j := UpdateValue;
  else
    x := 3;
    if j > 3 then
    begin
      inc(j);
    end;
  end;

   case x of
  csStart, csBegin:
        j := UpdateValue;
  else
    x := 3;
    if j > 3 then
    begin
      inc(j);
    end;
  case y of
  csStart, csBegin:
        j := UpdateValue;
  else
    x := 3;
    if j > 3 then
    begin
      inc(j);
    end;
  end;
  end;




end;

procedure SimpleCase;
var
li: integer;
begin
li := Random(5);

case li of
0: li := 1;
1:
li := li + 1;
2:
begin
  li := li + 1;
end;
else li := 0;
end;
end;

procedure CharCase;
var
ch, ch2: char;
li: integer;
begin
li := Random(5);

ch :=
'a';
ch := Char(Ord(ch) + li);

case ch of
'a': li := 1;
'b':
li := li + 1;
'c':
begin
  li := li + 1;
end;
'd': ch2 :=
  'e';
else li := 0;
end;

ch :=
'a';

end;


procedure ComplexCase;
var
  iA, IB: integer;
  bA: Boolean;
  liLoop, liLoop2: integer;
begin
  iA := Random (10);
  iB := Random (10);

if iA > 5 then
bA :=True
else
bA := False;

  { the case for 4 is something else, huh?
   unreadable as it gets wehn on one line,
   but it compiles fine
   note that the last 'else' in the proc is the default case,
   not part of the if in case 5:
   so it should be lined up with the 5:}
 case Random (7) of
  1: iA := 0;
  2: for liLoop := 1 to 10 do iA := iA + Random (2);
  3: if iA > 5 then ba := False else ba := True;
  14: if iA > 5 then for liLoop := 1 to 10 do iA := iA + Random (2) else while IA < 50 do iA := iA + Random (5);
  5:
     if iA > 6 then for liLoop := 1 to 10 do iA := iA + Random (2);
  else while IA < 50 do iA := iA + Random (5);
 end;

end;

procedure LayOutMyCaseStatement;
var
  iA, iB1, iCC2: integer;
begin

  // empty statement
  ; ; ; ; ;

  if Random (10) > 4 then
  begin
    iA := Random (20);
    case iA of
      1:  iA := 10;
      2:
        iA := Random (1000);
      3:
      begin
        iA := Random (1000);
        iB1 := iA + 10;
      end;
      34: ; // do nothing
      5:
        case Random (2) of
          0:
            iA := 1;
          1:
            iA := 0;
          else
            iA := 4;
        end;

      else
      begin
        Raise Exception.Create ('this sucks');


      end;


    end; { case }

  end; { if }


   end;



{ test nested cases }

procedure TestNested; var
  iA: integer; begin

Case Random(7) of
0: iA := 0;
1: case Random (2) of 0: iA := 1; 2:iA := 2; end;
2: case Random (2) of 0: iA := 1; 2: case Random (2) of 0: iA := 1; 2:iA := 2; end; end;
3: case Random (2) of 0: iA := 1; 2: case Random (2) of 0: iA := 1; 2: case Random (2) of 0: iA := 1; 2:iA := 2; end; end; end;
4: case Random (2) of 0: case Random (2) of 0: iA := 1; 2:iA := 2; end; 2: case Random (2) of 0: iA := 1; 2: case Random (2) of 0: iA := 1; 2:iA := 2; end; end; end;
5: case Random (2) of 0: case Random (2) of 0: iA := 1; 2:iA := 2; end; 2: case Random (2) of 0: case Random (2) of 0: iA := 1; 2:iA := 2; end; 2: case Random (2) of 0: iA := 1; 2:iA := 2; end; end; end;
6: case Random (2) of 0: case Random (2) of 0: iA := 1; 2:iA := 2; end; 2: case Random (2) of 0: case Random (2) of 0: iA := 1; 2:iA := 2; end; 2: case Random (2) of 0: iA := 1; 2: case Random (2) of 0: iA := 1; 2:iA := 2; end; end; end; end;
end;
end;

procedure TestElse;
var
  li: integer;
begin

  case Random(7) of
    0:
      li := 1;
    else
      li := 0;
  end;

  case Random(7) of
    0:
      li := 1;
    else
    begin
      li := 0;
    end;
  end;

  case Random(7) of
    0:
      li := 1;
    else
    begin
      case Random(7) of
        0:
          li := 1;
        else
          li := 0;
      end;
    end;
  end;

  case Random(7) of
    0:
      li := 1;
    else
    begin
      case Random(7) of
        0:
          li := 1;
        else
        begin
          case Random(7) of
            0:
              li := 1;
            else
              li := 0;
          end;
        end;
      end;
    end;
  end;


end;


end.
