unit CnUnitTest;

interface

uses
  SysUtils, Classes;

type
  TTestEnum = (teTest1, teTest2, teTest3);

  TTestRecord = packed record

  end;

  TTestObject = class
  private
    FField1: Boolean;
  public
    procedure TestObject;

    property Field1: Boolean read FField1 write FField1;
  end;

function TestFunction(var A: Integer; const B: string): Boolean;

procedure TestProcedure(C: TObject);

implementation

function TestFunction(var A: Integer; const B: string): Boolean;
begin
  Result := False;
end;

procedure TestProcedure(C: TObject);
begin

end;

procedure TTestObject.TestObject;
begin

end;

end.
