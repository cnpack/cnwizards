unit TestCondReturns;

interface

implementation

function DoTestCondReturns: Boolean;
var
  foo, bar: boolean;
begin
if foo then
begin
  {$IFDEF DEBUG}
  MessageDlg('Foo!',
  mtInformation, [mbOK], 0);
  {$ENDIF}
  Result := True;
  bar := False;
end;
end;

end.