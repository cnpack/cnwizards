unit UnitExport;

interface

uses
  SysUtils;

type
  TWizTestClass = class
  public
    function TestFunc(A: Integer): string;
  end;

implementation

{ TWizTestClass }

function TWizTestClass.TestFunc(A: Integer): string;
begin
  Result := IntToStr(A);
end;

end.
