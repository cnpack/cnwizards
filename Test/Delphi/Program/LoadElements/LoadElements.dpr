program LoadElements;

uses
  Forms,
  LoadElementsUnit in 'LoadElementsUnit.pas' {CnLoadElementForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TCnLoadElementForm, CnLoadElementForm);
  Application.Run;
end.
