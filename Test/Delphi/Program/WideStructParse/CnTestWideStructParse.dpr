program CnTestWideStructParse;

uses
  Forms,
  CnTestStructParseForm in 'CnTestStructParseForm.pas' {TeststructParseForm},
  CnWidePasParser in '..\..\..\..\Source\Utils\CnWidePasParser.pas',
  CnWideCppParser in '..\..\..\..\Source\Utils\CnWideCppParser.pas',
  CnSourceHighlight in '..\..\..\..\Source\SourceHighlight\CnSourceHighlight.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTeststructParseForm, TeststructParseForm);
  Application.Run;
end.
