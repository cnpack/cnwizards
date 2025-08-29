unit TestOperators;

{ AFS 11 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests operators }


interface

implementation

function __SomeNumber: integer;
begin
  Result := Random(30);
end;

procedure IntegerArithmetic;
var
  liA, liB, liC: integer;
begin
  { arithmetic }
  liA := 1;
  liB := liA + 5;
  liC := liB - 3;
  liA := liA * liA;

  liA := LiA div 3;
  liB := liA mod 3;

  { unary operators }
  liA := -12;
  liB := - liA;
  liC := + liA;
  liC := not liA;

  { long expressions }
  liA := ((liA + 2) * (liB - 3) div 3) + (liA mod liB);
  liA := liA + 2 * liB - 3 div 3 + liA mod liB;


  { bitwise operators }
  liC := liC shl 2;
  liA := liA shr 2;
  liB := liB xor 42;
  liA := 255 and 127;
  liB := 12 or 42;
  liA := not liA;

  { long expresions }
  liA := not ((liA and ((liB or liC) xor liA)) shl 2);
  liA := not liA and liB or liC xor liA shl 2;


  { hex, octal & binary }
  liA := liA + $BADBEEF;

  liA :=__SomeNumber+__SomeNumber-__SomeNumber*__SomeNumber div __SomeNumber;

end;

procedure FloatArithmetic;
var
  fa, fb, fc: Double;
begin
  fa := 1.23456;
  fb := fa * 2.345;
  fc := fb / 1.56789;

  fa := fb + fc;

  { unary operators }
  fA := -12.12345;
  fB := - fA;
  fC := + fA;

  fc:=__SomeNumber/__SomeNumber;
end;


procedure BooleanLogic;
var
  ba, bb, bc: Boolean;
begin
  ba := True;
  bb := False;
  bc := ba or bb;
  ba := bb and bc;
  ba := not ba;
  bc := ba xor bb;
end;

procedure StringLogic;
var
  sA, sb: string;
  Name:string;
begin
  sA := 'Fred ';
  sB := sA + 'Jim';
  sA := sA + #40;

if SA   =   '' then
if SA='' then
if SA='foo' then
if SA   =   'foo' then
if sB=sA then
if sb    =sB then
if sA=   sB then
if Name='' then
if Name   =   '' then
if Name   =   'foo' then
if Name   =   sb then
if sB   =   Name then
begin
end;
end;



procedure Floats;
const
  BIGNUM = 456.789e34;
  LITTLENUM = 12e-9;
var
  f1, f2: Extended;
begin
  f1 := 123.4E-2;
  f2 := f1 + 12.e12;
  f1 := f1 + BIGNUM + LITTLENUM * 1E-2;
end;


procedure TestEqualsMinus;
var
  a,b,c: integer;
begin
  a:=-1;
  b:= -2;
  c:=   -3;

  if a=-1then b:=-2;
  if a=+3then b:=-12;
  if b= -1then b:=-3;
  if c=  -1then b:=-4;
end;

procedure TestNoSpace;
var
  a,b,c: integer;
  f: double;
begin
  a:=-1;
  b:=2;
  c:=3;

  b:=b*-2;
  a:=a+2;
  b:=-3;
  c:=+4;
  // nasty negative nos!
  c:=c+-4;
  c:=c--4;
  f:=3.0;
  f:=f/-3;

  // more complex unary ops
  c := - (c * c);
  f := 1 - (-1 * c);
  f := - 1 + (-1 * c);
  f := - 1 + (1 * -c);
  f := - -1 + (1 * --c);

end;

end.
