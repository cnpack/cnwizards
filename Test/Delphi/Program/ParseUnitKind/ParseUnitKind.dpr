program ParseUnitKind;

uses
  Forms,
  TestUnit in 'TestUnit.pas' {FormParse},
  mPasLex in '..\..\..\..\Source\ThirdParty\mPasLex.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormParse, FormParse);
  Application.Run;
end.
