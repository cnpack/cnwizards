program NetPool;

uses
  Forms,
  UnitPool in 'UnitPool.pas' {FormPool};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormPool, FormPool);
  Application.Run;
end.
