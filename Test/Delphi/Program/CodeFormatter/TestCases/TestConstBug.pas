unit TestConstBug;
{
  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  SF Bugs item #1152816 from Stefan Landauer
}

interface

implementation

procedure A(pb, pc: integer);
begin
end;

var
  b, c: integer;

const
  EffRandLinks = 28;
  EffRandOben = 15;
  EffRandUnten = EffRandOben + 102;
  EffRandRechts = EffRandLinks + 293;
  EffMax = 4;
  EffMin = 1;
  EffFaktor: Extended = (EffRandUnten - EffRandOben) / (EffMax - EffMin);

procedure test;
begin
  a(b, c);
end;

end.
