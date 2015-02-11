unit TestReg;

{ test capitalisation of procs named "Register" 
  Due to a known issue in Some versions of Delphi, case is significant
  in the names of these procs
 So it must not be changed by the caps settings
}

interface

procedure Register;

procedure FRED;
procedure HoopyFroog;

implementation

procedure Register;
var
  Data: boolean;
begin
  Data := False;
end;

procedure FRED;
begin
end;

procedure HoopyFroog;
begin
end;

end.
