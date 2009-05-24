unit TestPropertyLines;

{ AFS 7 May 2001
  test property-on-one-line code
  This sample code is pathological
}
interface

type

TTerse = class(TObject)
  private
    fiX1: integer; FiX6: integer; FiX5: integer; FiX8: integer;
    FiX2: integer; FiX3: integer; FiX9: integer; FiX12: integer;
  public
property X1: integer read fiX1; property X2: integer read FiX2;
property X3: integer read FiX3; procedure X4;  property X5: integer read FiX5;
property X6: integer read FiX6; function X7: Boolean;  property X8: integer read FiX8;
property X9: integer read FiX9 write FiX9; function X10: Boolean;
function X11: Boolean; property X12: integer read FiX12 write FiX12;
end;

TVerbose = class(TObject)
  private
    fiX1: integer;
    FiX6: integer;
    FiX5: integer;
    FiX8: integer;
    FiX2: integer;
    FiX3: integer;
    FiX9: integer;
    FiX12: integer;
  public
    property X1: integer
    read fiX1
    write FiX1;

    property X2: integer
    read FiX2; property X3:
    integer read FiX3;

    procedure X4;  property X5: integer read
    FiX5; property
    X6: integer read FiX6; function
    X7: Boolean;  property X8: integer read FiX8;
    property X9: integer read
    FiX9
    write
    FiX9;

    function X10: Boolean;
    function X11: Boolean; property
    X12

    :

    integer

    read

    FiX12 write

    FiX12;
end;

THasComments = class(TObject)
  private
    FFred1: integer;
    FFred3: integer;
    FFred2: integer;
    FFred4: integer;
    procedure SetFred1(const Value: integer);
    procedure SetFred2(const Value: integer);
    procedure SetFred3(const Value: integer);
    procedure SetFred4(const Value: integer);
  protected
  public
    property Fred1: integer read FFred1 write SetFred1;

    property Fred2: integer
      // a comment that my cause trouble
    read FFred2
      // a comment that my cause trouble
    write SetFred2;

    property Fred3
      { a comment that my cause trouble }
    :
      (* a comment that my cause trouble *)
    integer
    read FFred3 write SetFred3;

    property Fred4: integer read

    // a comment that my cause trouble

    FFred4 write SetFred4;
end;


{ the propertyononeline process will put these on one line
  then the linebreaker will rebreak them }
TLongProperties = class(TObject)
  private
    fiThisIsAVeryLongProperyNameIndeedy: integer;
    fiThisIsAVeryLongProperyNameIndeedyNumberTwo: integer;

    function GetAnArrayPropertywithAnAbsurdlyLongName(const piThisIsAnIndexToTheArrayProperty: integer): integer;
    procedure SetAnArrayPropertywithAnAbsurdlyLongName(const piThisIsAnIndexToTheArrayProperty: integer; const piThisIsAValue: integer);
  public

    property
    ThisIsAVeryLongProperyNameIndeedy
    :
    integer read
    fiThisIsAVeryLongProperyNameIndeedy write
    fiThisIsAVeryLongProperyNameIndeedy;


    property AnArrayPropertywithAnAbsurdlyLongName[ const piThisIsAnIndexToTheArrayProperty: integer]: integer read GetAnArrayPropertywithAnAbsurdlyLongName write SetAnArrayPropertywithAnAbsurdlyLongName;

    default; property
    ThisIsAVeryLongProperyNameIndeedyNumberTwo
    :
    integer read
    fiThisIsAVeryLongProperyNameIndeedyNumberTwo write
    fiThisIsAVeryLongProperyNameIndeedyNumberTwo;
end;

implementation

{ TTerse }

function TTerse.X10: Boolean;
begin
  Result := False;
end;

function TTerse.X11: Boolean;
begin
  Result := False;
end;

procedure TTerse.X4;
begin
  // do something
end;

function TTerse.X7: Boolean;
begin
  Result := False;
end;

{ TVerbose }

function TVerbose.X10: Boolean;
begin
  Result := False;
end;

function TVerbose.X11: Boolean;
begin
  Result := False;
end;

procedure TVerbose.X4;
begin
  // do something
end;

function TVerbose.X7: Boolean;
begin
  Result := False;
end;

{ TLongProperties }

function TLongProperties.GetAnArrayPropertywithAnAbsurdlyLongName(
  const piThisIsAnIndexToTheArrayProperty: integer): integer;
begin
  Result := 3;
end;

procedure TLongProperties.SetAnArrayPropertywithAnAbsurdlyLongName(
  const piThisIsAnIndexToTheArrayProperty, piThisIsAValue: integer);
begin

end;

{ THasComments }

procedure THasComments.SetFred1(const Value: integer);
begin
  FFred1 := Value;
end;

procedure THasComments.SetFred2(const Value: integer);
begin
  FFred2 := Value;
end;

procedure THasComments.SetFred3(const Value: integer);
begin
  FFred3 := Value;
end;

procedure THasComments.SetFred4(const Value: integer);
begin
  FFred4 := Value;
end;

end.
