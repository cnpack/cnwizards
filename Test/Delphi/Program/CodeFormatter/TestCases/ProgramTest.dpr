program ProgramTest;
{$APPTYPE CONSOLE}
uses
  SysUtils, Classes;

type
  TSampleClass = class of TSampleObject;

  TSampleObject = class
  private
    FPrivateByte: Byte;
    FPrivateInteger: Integer;
    FPrivateString: String;
    FPrivatePByte: ^Byte;
    FPrivateArray: array [1..3] of Char;
    FPrivateRecord: record x: Integer; c: cHar; end;

    function GetIntegerProperty: Integer;
    procedure SetIntegerProperty(const Value: Integer);
    function GetIndexProperty(Index: Integer): string;
    procedure SetIndexProperty(Index: Integer; const Value: string);
  protected
    FProtectedByte: Byte;
    FProtectedInteger: Integer;
    FProtectedString: String;
    FProtectedPByte: ^Byte;
    FProtectedArray: array[1..3] of char;

    procedure ProtectedProc1(Param1: integer);
    procedure ProtectedProc2(Param1: Integer; Param2: String = '');
    procedure ProtectedProc3(Param1: array of Byte);
  public
    constructor Create;
    destructor Destroy; override;

    property IndexProperty[Index: Integer]: string read GetIndexProperty write SetIndexProperty; default;
  published
    property IntegerProperty: Integer read GetIntegerProperty write SetIntegerProperty;
  end;

{ TSampleObject }

constructor TSampleObject.Create;
begin

end;

destructor TSampleObject.Destroy;
begin
  inherited;

end;

function TSampleObject.GetIndexProperty(Index: Integer): string;
begin

end;

function TSampleObject.GetIntegerProperty: Integer;
begin

end;

procedure TSampleObject.ProtectedProc1(Param1: integer);
begin

end;

procedure TSampleObject.ProtectedProc2(Param1: Integer; Param2: String);
begin

end;

procedure TSampleObject.ProtectedProc3(Param1: array of Byte);
begin

end;

procedure TSampleObject.SetIndexProperty(Index: Integer;
  const Value: string);
begin

end;

procedure TSampleObject.SetIntegerProperty(const Value: Integer);
begin

end;


var
  SampleObject: TSampleObject;
  I: Integer;
begin
  SampleObject := TSampleClass.Create;
  for I := 0 to 10 do
  with SampleObject do
  begin
    IndexProperty[I] := IntToStr(I);

    if I > 5 then Break;
  end;

  I := 0;
  while I < 5 do
  with SampleObject do
  begin
    IndexProperty[I] := IntToStr(I+1);

    if I > 5 then Break;
    Inc(I);
  end;

  Readln;
end.
