unit TestLayoutBare;

{ AFS 1 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 a 'bare' block is one that does not have begin..end around it
 This unit tests layout for statments with bare blocks

 IMHO doing things this way in real code is not cool, 
 use begin-end blocks to make things clear
}

interface

implementation

{ block layout }

function NastyElse(var foo, bar: boolean): integer;
begin
if Foo then
Result := -1
else
end;

function NastyElse2(var foo, bar: boolean): integer;
begin
if Foo then
if bar then
Result := -1
else
else
Result := 2;
end;


{ these lttle tests have one statement block per procedure
  and omit the semicolon after the final statement, which is legal but ugly }
procedure LittleTest1;
var
  iA, iB: integer;
  liLoop: integer;
begin
  if iA > 5 then for liLoop := 1 to 10 do iA := iA + Random (2) else while IA < 50 do iA := iA + Random (5)
end;

procedure LittleTest2;
var
  iA, iB: integer;
  bA: Boolean;
begin
  if iA > 20 then
    bA := False
  else if IB > 6 then
    BA := True
  else
    BA := False
end;


procedure LittleTest3;
var
  iA, iB: integer;
  liLoop: integer;
begin
if IB < 15 then
while iA < 10 do
for liLoop := 0 to 3 do
begin iA := iA + Random (10); end

end;


procedure LittleTest4;
var iA: integer;
begin repeat  iA := iA + Random (10)  until IA > 100; end;

procedure IfElseTest;
var
  iA, IB: integer;
  BA: boolean;
begin

  if iA > 20 then
    bA := False
  else if IB > 6 then
    BA := True
  else if IA < 6 then
    BA := False;

  if iA > 20 then
    if IB > 5 then
      bA := False
    else if IB > 6 then
      BA := True
    else
      BA := False;

end;

procedure LittleTest5_1;
var
  iA, iB: integer;
  bA:     boolean;
begin
if iA > 5 then
if iA > 20 then
BA := True
else
BA := False
end;


procedure LittleTest5_2;
var
  iA, iB: integer;
  bA:     boolean;
begin
if iA > 5 then
if iA > 20 then
BA := True
else
BA := False
else
ba := True
end;

procedure LittleTest5_3;
var
  iA, iB: integer;
  bA: Boolean;
begin
  if iA > 20 then if IB > 6 then BA := True
  else BA := False else ba := True
end;


procedure LittleTest6;
var
  iA, iB: integer;
  bA:     boolean;
begin
  if iA > 5 then
  if iA > 20 then
  if IB > 6 then
  BA := True
  else
  BA := False
  else
  ba := True
  else
  ba := False
end;


procedure Mixem;
var
  iA, IB: integer;
begin
  iA := Random (10);
  iB := Random (10);

  { alternate blocked and naked }
  if IA > 3 then
  if IA > 4 then
  begin
  ib := 10;
  end;

  if IA > 4 then
  begin
  if IA > 5 then
  if IA > 6 then
  begin
  if IA > 7 then
  if IA > 8 then
  begin
  if IA > 9 then
  ib := 10;
  end;
  end;
  end;

  if IA > 3 then
  if IA > 4 then
  begin
  if IA > 5 then
  if IA > 6 then
  begin
  if IA > 7 then
  if IA > 8 then
  begin
  if IA > 9 then
  ib := 10;
  end;
  end;
  end;

end;

procedure LayoutBare;
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

for liLoop := 0 to 10 do
iA := iA + Random (10);

for liLoop := 0 to 10 do
if iB < 15 then
iA := iA - Random (10);

if iB < 15 then
while iA < 10 do
iA := iA + Random (10);

for liLoop := 0 to 3 do
for liLoop2 := 0 to 3 do
iA := iA - Random (10);

if IB < 15 then
while iA < 10 do
for liLoop := 0 to 3 do
begin iA := iA + Random (10); end;

if iA > 20 then
if IB > 5 then
bA := False
else
if IB > 6 then
BA := True
else
BA := False;

repeat iA := iA + Random (10) until IA > 100;


end;

end.
