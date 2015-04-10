program CnTestWideStructParse;

uses
  Forms,
  CnTestStructParseForm in 'CnTestStructParseForm.pas' {TeststructParseForm},
  CnWidePasParser in '..\..\Source\Utils\CnWidePasParser.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTeststructParseForm, TeststructParseForm);
  Application.Run;
end.
