program TestPasDoc;

uses
  Forms,
  TestPasCodeDoc in 'TestPasCodeDoc.pas' {FormPasDoc},
  CnPasCodeDoc in 'CnPasCodeDoc.pas',
  CnPascalAST in '..\..\Source\Utils\CnPascalAST.pas',
  CnPasCodeSample in 'CnPasCodeSample.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormPasDoc, FormPasDoc);
  Application.Run;
end.
