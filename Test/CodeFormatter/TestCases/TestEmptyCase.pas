unit TestEmptyCase;

interface

implementation

{ empty case with no semicolon allowed just before the 'else' }
procedure Monkey(const pi: integer);
const
  krukolibidinous = 12;
begin

  case pi of
    1: ;
    2:  ;
    3:  ;
    krukolibidinous:
    else
    begin
    end;
  end;

end;

procedure Soy(const pi: integer);
begin

  case pi of
    1: 
  end;

end;

end.
