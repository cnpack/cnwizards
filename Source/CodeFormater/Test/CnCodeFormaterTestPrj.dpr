program CnCodeFormaterTestPrj;

uses
  Forms,
  CnCodeFormaterTest in 'CnCodeFormaterTest.pas' {MainForm},
  CnScaners in '..\CnParser\CnScaners.pas',
  CnTokens in '..\CnParser\CnTokens.pas',
  CnCodeFormater in '..\CnCodeFormater.pas',
  CnParseConsts in '..\CnParser\CnParseConsts.pas',
  CnCodeGenerators in '..\CnParser\CnCodeGenerators.pas',
  CnCodeFormatRules in '..\CnCodeFormatRules.pas',
  CnPascalGrammar in '..\CnParser\CnPascalGrammar.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
