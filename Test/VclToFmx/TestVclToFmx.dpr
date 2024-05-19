program TestVclToFmx;

uses
  Vcl.Forms,
  TestVclToFmxUnit in 'TestVclToFmxUnit.pas' {FormConvert},
  CnVclToFmxMap in '..\..\Source\VclToFmx\CnVclToFmxMap.pas',
  CnVclToFmxConverter in '..\..\Source\VclToFmx\CnVclToFmxConverter.pas',
  CnWizDfmParser in '..\..\Source\Utils\CnWizDfmParser.pas',
  CnTree in '..\..\..\cnvcl\Source\Common\CnTree.pas',
  CnVclToFmxIntf in '..\..\Source\VclToFmx\CnVclToFmxIntf.pas',
  CnVclToFmxImpl in '..\..\Tool\CnVclToFmx\CnVclToFmxImpl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormConvert, FormConvert);
  Application.Run;
end.
