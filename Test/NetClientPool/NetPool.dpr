program NetPool;

uses
  Forms,
  UnitPool in 'UnitPool.pas' {FormPool},
  CnAICoderConfig in '..\..\Source\AICoder\CnAICoderConfig.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormPool, FormPool);
  Application.Run;
end.
