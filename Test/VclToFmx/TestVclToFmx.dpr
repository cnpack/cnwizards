program TestVclToFmx;

uses
  Vcl.Forms,
  TestVclToFmxUnit in 'TestVclToFmxUnit.pas' {FormConvert},
  CnVclToFmxMap in '..\..\Source\Utils\CnVclToFmxMap.pas',
  CnVclToFmxConverter in '..\..\Source\Utils\CnVclToFmxConverter.pas',
  CnWizDfmParser in '..\..\Source\Utils\CnWizDfmParser.pas',
  CnTree in '..\..\..\cnvcl\Source\Common\CnTree.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormConvert, FormConvert);
  Application.Run;
end.
