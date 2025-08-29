unit TestProperties;


{ AFS 9 July 2K
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

  Test bug reported by  Michael Hieke in properties
  and some other property permutations
}

interface

uses Types;

type TFoo = class(TObject)
private fiBar, fiBaz, fiWibble, fiFish, fiQuux: integer;

  function GetArray(piIndex: integer): integer;
  procedure SetArray(piIndex: integer; piValue: integer);

    function GetConstArray(const piIndex: integer): integer;
  procedure SetConstArray(const piIndex: integer; piValue: integer);
    function GetComplexArrayProp(
      const piIndex: integer; var pcString: string): boolean;


public

  property ArrayVal[piIndex: integer]: integer read GetArray  write SetArray; default;
  property ConstArrayVal[
  const
  piIndex
  :
  integer
  ]: integer read GetConstArray  write SetConstArray;

  property ComplexArrayProp[const piIndex: integer; var pcsString: string]: boolean read GetComplexArrayProp ;

published
  { properties, plain to complex}
property Bar: integer read fiBar write fiBar;
property Baz: integer index 3 read fiBaz write fiBaz;
property Wibble: integer read fiWibble write fiWibble stored False;
property Fish: integer index 5 read fiFish write fiFish default 6;
property Quux: integer index 5 read fiQuux write fiQuux nodefault;

end;

type TBar = class(TObject)

function GetArray(piIndex: integer): integer; procedure SetArray(piIndex: integer; piValue: integer);

public
property ArrayVal[piIndex: integer]: integer
read GetArray
write SetArray;
default;

end;

type

  THasAPoint = class (TObject)
    private
      FPoint: TPoint;
    public
      property X: integer read FPoint.x;
      property Y: integer read FPoint.y write FPoint.y;
  end;


implementation

{ TFoo }

function TFoo.GetArray(piIndex: integer): integer;
begin
  Result := piIndex * 3;
end;

function TFoo.GetComplexArrayProp(const piIndex: integer;
  var pcString: string): boolean;
begin
  result := false;
  pcString := pcString + 'aa';
end;

function TFoo.GetConstArray(const piIndex: integer): integer;
begin
  Result := piIndex * 3;
end;

procedure TFoo.SetArray(piIndex, piValue: integer);
begin
  // do nothing
end;

procedure TFoo.SetConstArray(const piIndex: integer; piValue: integer);
begin
  // do nothing
end;

{ TBar }

function TBar.GetArray(piIndex: integer): integer;
begin
  Result := piIndex * 4;
end;

procedure TBar.SetArray(piIndex, piValue: integer);
begin
  // do nothing
end;

end.
