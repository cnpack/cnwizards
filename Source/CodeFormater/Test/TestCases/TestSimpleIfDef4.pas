Unit TestSimpleIfDef4;

interface

implementation

procedure Foo; cdecl; export;
{$IFDEF LINUX}
var
  I: Integer;
begin
  I := 3;
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
var
  K: integer;
begin
  K := 4;
end;
{$ENDIF}

procedure Bar;
begin
end;

end.

