program FormParse;

uses
  Forms,
  UnitParse in 'UnitParse.pas' {ParseForm},
  CnWizDfmParser in '..\..\..\..\Source\Utils\CnWizDfmParser.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TParseForm, ParseForm);
  Application.Run;
end.
