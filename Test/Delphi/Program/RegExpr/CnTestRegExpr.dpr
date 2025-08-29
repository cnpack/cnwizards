program CnTestRegExpr;

uses
  Forms,
  CnTestRegExprUnit in 'CnTestRegExprUnit.pas' {TestRegExprForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTestRegExprForm, TestRegExprForm);
  Application.Run;
end.
