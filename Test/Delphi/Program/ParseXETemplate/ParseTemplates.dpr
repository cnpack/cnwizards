program ParseTemplates;

uses
  Vcl.Forms,
  ParseTemplate in 'ParseTemplate.pas' {frmParse};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmParse, frmParse);
  Application.Run;
end.
