program StandAloneFramework;

uses
  Forms,
  StandAloneFrameworkUnit in 'StandAloneFrameworkUnit.pas' {FormFramework},
  CnMessageBoxWizard in '..\..\Source\SimpleWizards\CnMessageBoxWizard.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormFramework, FormFramework);
  Application.Run;
end.
