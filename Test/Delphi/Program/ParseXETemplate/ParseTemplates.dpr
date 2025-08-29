program ParseTemplates;

uses
  Vcl.Forms,
  ParseTemplate in 'ParseTemplate.pas' {frmParse},
  OmniXML in '..\..\..\..\Source\ThirdParty\OmniXML.pas',
  OmniXML_LookupTables in '..\..\..\..\Source\ThirdParty\OmniXML_LookupTables.pas',
  OmniXMLPersistent in '..\..\..\..\Source\ThirdParty\OmniXMLPersistent.pas',
  OmniXMLProperties in '..\..\..\..\Source\ThirdParty\OmniXMLProperties.pas',
  OmniXMLUtils in '..\..\..\..\Source\ThirdParty\OmniXMLUtils.pas',
  GpTextStream in '..\..\..\..\Source\ThirdParty\GpTextStream.pas',
  GpStreamWrapper in '..\..\..\..\Source\ThirdParty\GpStreamWrapper.pas',
  GpMemStr in '..\..\..\..\Source\ThirdParty\GpMemStr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmParse, frmParse);
  Application.Run;
end.
