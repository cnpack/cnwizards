program StandAloneFramework;

uses
  Forms,
  StandAloneFrameworkUnit in 'StandAloneFrameworkUnit.pas' {FormFramework};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormFramework, FormFramework);
  Application.Run;
end.
