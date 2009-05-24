unit TestForIn;

interface

implementation

type
  TStringArray = array of String;

procedure Demo1(const List: TStringArray);
var
  S: String;
begin
  for S in List do
    writeln(S);
end;

end.
