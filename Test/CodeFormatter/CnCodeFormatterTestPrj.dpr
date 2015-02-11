program CnCodeFormaterTestPrj;

uses
  Forms,
  CnCodeFormatterTest in 'CnCodeFormatterTest.pas' {MainForm},
  CnScaners in '..\..\Source\CodeFormatter\CnParser\CnScaners.pas',
  CnTokens in '..\..\Source\CodeFormatter\CnParser\CnTokens.pas',
  CnCodeFormatter in '..\..\Source\CodeFormatter\CnCodeFormatter.pas',
  CnParseConsts in '..\..\Source\CodeFormatter\CnParser\CnParseConsts.pas',
  CnCodeGenerators in '..\..\Source\CodeFormatter\CnParser\CnCodeGenerators.pas',
  CnCodeFormatRules in '..\..\Source\CodeFormatter\CnCodeFormatRules.pas',
  CnPascalGrammar in '..\..\Source\CodeFormatter\CnParser\CnPascalGrammar.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
