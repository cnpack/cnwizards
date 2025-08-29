program GenerateHugeProject;

uses
  Forms,
  GenerateUnit in 'GenerateUnit.pas' {GenerateForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TGenerateForm, GenerateForm);
  Application.Run;
end.
