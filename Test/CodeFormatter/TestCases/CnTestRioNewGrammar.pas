unit CnTestRioNewGrammar;

interface

implementation

procedure Test;
begin
  var I: Integer := 22;
  var I, J: Integer;
  I := 22;
  j := I + 20;
  var K: Integer := I + J;
  ShowMessage (J.ToString);

  if I > 10 then
  begin
    var J: Integer := 3;
    ShowMessage (J.ToString);
  end
  else
  begin
    var K: Integer := 3;
    ShowMessage (J.ToString);
  end;

  const M: Integer = (L + H) div 2;
  const M = (L + H) div 2; 

  for var I: Integer := 1 to 10 do
  begin
  for var I := 1 to 10 do begin end;
  for var Item in Collection do begin end;
  end;

  for var Item: TItemType in Collection do
  begin
  
  end;
end;

end.
