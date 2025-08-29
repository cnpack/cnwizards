unit TestLayoutBare2;

{ AFS 28 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 a 'bare' block is one that does not have begin..end around it
 This unit tests layout for statments with bare blocks

 Use of bare blocks nested within bare blocks is not recommended in real-world code
 for purely human aethetic & readabilty reasons

}

interface

implementation


procedure Test;
var
  iA, IB: integer;
  BA: boolean;
begin

  if ia > 3  then
    if ia > 4 then
    begin
      ib := 10;
    end;
  if ia > 4 then
    if ia > 4 then
    begin
      ib := 10;
    end;
  if ia > 4 then
    if ia > 4 then
    begin
      ib := 10;
    end;
end;

{ same with spaces }
procedure Test2;
var
  iA, IB: integer;
  BA: boolean;
begin

  if ia > 3  then
    if ia > 4 then
    begin
      ib := 10;
    end;

  if ia > 4 then
    if ia > 4 then
    begin
      ib := 10;
    end;



  if ia > 4 then
    if ia > 4 then
    begin
      ib := 10;
    end;
    
end;

{ next 2 tests exhibited layout bugs found in testing 0.3beta }

procedure Test3;
var
  iA, IB: integer;
  BA:     boolean;
begin
  if ia > 3 then
    if ia > 4 then
      ib := 10;
  if ia > 4 then
    ib := 10;
  if ia > 4 then
    ib := 0;
end;

procedure Test4;
var
  iA, IB: integer;
  BA:     boolean;
begin
  if ia > 3 then
    if ia > 4 then
    begin
      ib := 10;
    end;
  if ia > 4 then
  begin
    ib := 10;
  end;
end;

procedure TestEnd1;
var
  sA, sb: string;
begin
  sA := 'Fred ';
  sB := sA + 'Jim';
  sA := sA + #40;

if SA = '' then
begin
        sA := sA + 'narf';
end;
end;

procedure TestEnd2;
var
  sA, sb: string;
begin
  sA := 'Fred ';
  sB := sA + 'Jim';
  sA := sA + #40;

if SA   =   '' then
if SA='x' then
begin
        sA := sA + 'narf';
end;
end;

procedure TestEnd3;
var
  sA, sb: string;
begin
  sA := 'Fred ';
  sB := sA + 'Jim';
  sA := sA + #40;

if SA   =   '' then
if Sb='x' then
if SA <> 'foo' then
begin
        sA := sA + 'narf';
end;
end;

procedure TestEnd4;
var
  sA, sb: string;
begin
  sA := 'Fred ';
  sB := sA + 'Jim';
  sA := sA + #40;

if SA   =   '' then
if Sb='x' then
if SA <> 'foo' then
if SA   =   'groo' then
begin
        sA := sA + 'narf';
end;
end;

procedure TestEnd5;
var
  sA, sb: string;
begin
  sA := 'Fred ';
  sB := sA + 'Jim';
begin
  sA := sA + #40;

if SA   =   '' then
if Sb='x' then
if SA <> 'foo' then
if SA   =   'groo' then
begin
        sA := sA + 'narf';
end;
end;
end;


end.
