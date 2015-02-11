unit TestDefaultParams;

{ AFS 17 October 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This code tests default parameters }

interface

function Def1(const piVal: integer = 42): Boolean;
function Def2(bv: Boolean = False; const piVal: integer = 42): Boolean;
function Def3(bv: Boolean = False;
  const piAverryLongValVal: integer = 42;
  const short: integer = 42): Boolean;

type
  THasDefs =  class(TObject)
  public
    procedure Fred(const pi: integer = 3; px: double = 34.4);
virtual;
    procedure Jim(const pi: integer = 3; px: double = 34.4);
overload;
    procedure Jim(pb: Boolean = False);
overload;

    procedure Bob(const pi: integer = 3; px: double = 34.4); overload;
    procedure Bob(const pbLongVariableName: pointer = nil;
    const pi: integer = 3;
    px: double = 34.4); overload;
  end;

implementation

procedure THasDefs.Bob(const pi: integer; px: double);
begin
  if pi >  3 then
  begin
    px := pi;
  end;

end;

procedure THasDefs.Bob(const pbLongVariableName: pointer; const pi: integer;
  px: double);
begin

end;

procedure THasDefs.Fred(const pi: integer = 3; px: double = 34.4);
begin
  if pi >  3 then
  begin
    px := pi;
  end;
end;                                                   

function Def1(const piVal: integer = 42): Boolean;
begin
  Result := (piVal = 42);
end;

function Def2(bv: Boolean = False; const piVal: integer = 42): Boolean;
begin
  if bv then
    Result := Def1(piVal)
  else
  begin
    Result := Def1;
  end;
end;

function Def3(bv: Boolean = False;
  const piAverryLongValVal: integer = 42;
  const short: integer = 42): Boolean;
begin
  Def2(bv);
end;

procedure THasDefs.Jim(const pi: integer; px: double);
begin
  if pi >  3 then
  begin
    px := pi;
  end;
end;

procedure THasDefs.Jim(pb: Boolean);
begin
  if pb then
    Jim(pb);
end;

end.
