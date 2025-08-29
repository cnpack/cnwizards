unit TestLayoutBare3;

{ AFS 25 Dec 2000

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 a 'bare' block is one that does not have begin..end around it
 This unit tests layout for statments with bare blocks

  As you may have noticed by this stage, bare block layout is a tricky subject
  Use of bare blocks nested within bare blocks is not recommended in real-world code
  for purely human aethetic & readabilty reasons
  ie coding like this is not cool.
}

interface

implementation

procedure Test1;
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

procedure Test2;
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


procedure Test3_1;
var
  iA, IB: integer;
begin
  iA := Random(10);
  iB := Random(10);


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

procedure Test3_2;
var
  iA, IB: integer;
begin
  iA := Random(10);
  iB := Random(10);


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

procedure Test3_3;
var
iA, IB: integer;
begin
iA := Random(10);
iB := Random(10);


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


procedure Test3_4;
var
iA, IB: integer;
begin
iA := Random(10);
iB := Random(10);


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

{
 some stuff from Ray Malone
 that formats wrong in v0.52
}
procedure TestRayMalone;
 // these defs are dummies to get the code sample to compile
const
  cFwdSlash: char = '/';
  cpVendorToken = 1;
  aVendorToken = 2;
var
  aPath: string;
  Fields: array[1..4] of integer;
  aProduct: integer;
  aProductInfoItem: integer;
begin
 //The Delete statement gets indented  4 spaces instead of two.
  while (Length(aPath) > 1) and (Pos(cFwdSlash, aPath) = 1) do
   Delete(aPath, 1, 1);

  while (Length(aPath) > 1) or (Pos(cFwdSlash, aPath) = 1) do
   Delete(aPath, 1, 1);

  while (Length(aPath) > 1) do
   Delete(aPath, 1, 1);

   while Length(aPath) > 1 do
   Delete(aPath, 1, 1);

 //The following has a While statement, an And statement, and a Begin statement. It allso indents what appears to be two caracters too many. But it corrects iteself on the third line:
  while not EOF and (Fields[cpVendorToken] = aVendorToken) do
  begin
    aProduct       := 3;
    aProductInfoItem := 3;
  end;

  // the same with bracketing
  while ((Length(aPath) > 1) and (Pos(cFwdSlash, aPath) = 1)) do
   Delete(aPath, 1, 1);

  while (not EOF and (Fields[cpVendorToken] = aVendorToken)) do
  begin
    aProduct       := 3;
    aProductInfoItem := 3;
  end;

  // and these will not be munged
  //jcf:indent=off
  while (Length(aPath) > 1) and (Pos(cFwdSlash, aPath) = 1) do
   Delete(aPath, 1, 1);

  while not EOF and (Fields[cpVendorToken] = aVendorToken) do
  begin
    aProduct       := 3;
    aProductInfoItem := 3;
  end;
  //jcf:indent=on

end;


end.
