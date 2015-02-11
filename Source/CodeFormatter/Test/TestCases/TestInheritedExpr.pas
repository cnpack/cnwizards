unit TestInheritedExpr;

{ AFS 28 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 test call to inherited method 
}

interface

type
  TCityCounter = class(Tobject)

  public
    function CountRats(const psCity: String): integer; virtual;
    function CountCheapTaxis: integer; virtual;
    procedure Foo; virtual;
  end;

  TLondonCounter = class(TCityCounter)
  public
    function CountRats(const psCity: String): integer; override;
    function CountCheapTaxis: integer; override;
    procedure Foo; override;
  end;


implementation

{ TRatCounter }

function TCityCounter.CountCheapTaxis: integer;
begin
  Result := -1;
end;

function TCityCounter.CountRats(const psCity: String): integer;
begin
  Result := 1000;
end;

procedure TCityCounter.Foo;
begin

end;

{ TLondonCounter }

function TLondonCounter.CountCheapTaxis: integer;
begin
  Result := inherited CountCheapTaxis;
end;

function TLondonCounter.CountRats(const psCity: String): integer;
begin
  Result := inherited CountRats('London') * 42;
end;

procedure TLondonCounter.Foo;
begin
  inherited;
end;

end.
