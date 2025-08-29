program EvaluateDemo;

uses
  Forms,
  UnitEvaluate in 'UnitEvaluate.pas' {FormEvaluate};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormEvaluate, FormEvaluate);
  Application.Run;
end.
