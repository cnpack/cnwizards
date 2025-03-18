program ScriptEngine;

uses
  Forms,
  UnitScript in 'UnitScript.pas' {FormScriptEngine},
  CnScriptClasses in '..\..\Source\ScriptWizard\CnScriptClasses.pas',
  CnScript_System in '..\..\Source\ScriptWizard\CnScript_System.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormScriptEngine, FormScriptEngine);
  Application.Run;
end.
