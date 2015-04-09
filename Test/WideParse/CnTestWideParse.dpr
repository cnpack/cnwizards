program CnTestWideParse;

uses
  Forms,
  CnTestWideForm in 'CnTestWideForm.pas' {CnTestUnicodeParseForm},
  CnPasWideLex in '..\..\Source\Utils\CnPasWideLex.pas',
  mPasLex in '..\..\Source\ThirdParty\mPasLex.pas',
  CnBCBWideTokenList in '..\..\Source\Utils\CnBCBWideTokenList.pas',
  mwBCBTokenList in '..\..\Source\ThirdParty\mwBCBTokenList.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TCnTestUnicodeParseForm, CnTestUnicodeParseForm);
  Application.Run;
end.
