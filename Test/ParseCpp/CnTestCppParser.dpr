program CnTestCppParser;

uses
  Forms,
  CnTestCppParserFrm in 'CnTestCppParserFrm.pas' {Form1},
  CnCppCodeParser in '..\..\Source\Utils\CnCppCodeParser.pas',
  mwBCBTokenList in '..\..\Source\ThirdParty\mwBCBTokenList.pas',
  CnFastList in '..\..\Source\Utils\CnFastList.pas',
  CnPasCodeParser in '..\..\Source\Utils\CnPasCodeParser.pas',
  mPasLex in '..\..\Source\ThirdParty\mPasLex.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
