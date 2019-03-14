program CnTestPasParser;

uses
  Forms,
  CnTestPasParserFrm in 'CnTestPasParserFrm.pas' {CnTestStructureForm},
  CnFastList in '..\..\Source\Utils\CnFastList.pas',
  CnPasCodeParser in '..\..\Source\Utils\CnPasCodeParser.pas',
  CnCppCodeParser in '..\..\Source\Utils\CnCppCodeParser.pas',
  mPasLex in '..\..\Source\ThirdParty\mPasLex.pas',
  CnPasWideLex in '..\..\Source\Utils\CnPasWideLex.pas',
  mwBCBTokenList in '..\..\Source\ThirdParty\mwBCBTokenList.pas',
  CnBCBWideTokenList in '..\..\Source\Utils\CnBCBWideTokenList.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TCnTestStructureForm, CnTestStructureForm);
  Application.Run;
end.
