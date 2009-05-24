unit LittleTest9;

{ This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 unit that caused a parse failure in 2.0 b3 }

interface

procedure SomeThing;

implementation

uses
  db, dbtables;

procedure SomeThing;
var
  qry: TQuery;
begin
  qry.fieldbyname('line').AsInteger := 1;
end;

end.
