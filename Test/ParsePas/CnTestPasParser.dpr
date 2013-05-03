program CnTestPasParser;

uses
  Forms,
  CnTestPasParserFrm in 'CnTestPasParserFrm.pas' {Form1},
  CnFastList in '..\..\Source\Utils\CnFastList.pas',
  CnPasCodeParser in '..\..\Source\Utils\CnPasCodeParser.pas',
  mPasLex in '..\..\Source\ThirdParty\mPasLex.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
