program TestExtract;

uses
  Forms,
  UnitExtract in 'UnitExtract.pas' {FormExtract};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormExtract, FormExtract);
  Application.Run;
end.
