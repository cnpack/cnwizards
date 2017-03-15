program CnTestPngConvert;

uses
  Forms,
  CnPngConvert in 'CnPngConvert.pas' {FormTestPng},
  CnPngUtils in '..\..\Tools\CnPngLib\CnPngUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormTestPng, FormTestPng);
  Application.Run;
end.
