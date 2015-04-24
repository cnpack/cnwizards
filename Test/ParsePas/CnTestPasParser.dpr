program CnTestPasParser;

uses
  Forms,
  CnTestPasParserFrm in 'CnTestPasParserFrm.pas' {CnTestPasForm},
  CnFastList in '..\..\Source\Utils\CnFastList.pas',
  CnPasCodeParser in '..\..\Source\Utils\CnPasCodeParser.pas',
  mPasLex in '..\..\Source\ThirdParty\mPasLex.pas',
  CnPasWideLex in '..\..\Source\Utils\CnPasWideLex.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TCnTestPasForm, CnTestPasForm);
  Application.Run;
end.
