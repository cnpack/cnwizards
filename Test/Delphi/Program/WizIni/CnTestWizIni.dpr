program CnTestWizIni;

uses
  Forms,
  CnTestWizIniUnit in 'CnTestWizIniUnit.pas' {TestWizIniForm},
  CnWizIni in '..\..\..\..\Source\Utils\CnWizIni.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTestWizIniForm, TestWizIniForm);
  Application.Run;
end.
