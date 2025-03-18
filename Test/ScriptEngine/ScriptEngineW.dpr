program ScriptEngineW;

{$IFNDEF UNICODE}
  Error: Must be Unicode Compiler!
{$ENDIF}

uses
  Forms,
  UnitScript in 'UnitScript.pas' {FormScriptEngine},
  CnScriptClasses in '..\..\Source\ScriptWizard\CnScriptClasses.pas',
  CnScript_System in '..\..\Source\ScriptWizard\CnScript_System.pas',
  CnScript_SysUtils in '..\..\Source\ScriptWizard\CnScript_SysUtils.pas',
  CnScript_Classes in '..\..\Source\ScriptWizard\CnScript_Classes.pas',
  CnScript_ActnList in '..\..\Source\ScriptWizard\CnScript_ActnList.pas',
  CnScript_Buttons in '..\..\Source\ScriptWizard\CnScript_Buttons.pas',
  CnScript_Clipbrd in '..\..\Source\ScriptWizard\CnScript_Clipbrd.pas',
  CnScript_ComCtrls in '..\..\Source\ScriptWizard\CnScript_ComCtrls.pas',
  CnScript_ComObj in '..\..\Source\ScriptWizard\CnScript_ComObj.pas',
  CnScript_Controls in '..\..\Source\ScriptWizard\CnScript_Controls.pas',
  CnScript_Dialogs in '..\..\Source\ScriptWizard\CnScript_Dialogs.pas',
  CnScript_ExtCtrls in '..\..\Source\ScriptWizard\CnScript_ExtCtrls.pas',
  CnScript_ExtDlgs in '..\..\Source\ScriptWizard\CnScript_ExtDlgs.pas',
  CnScript_Forms in '..\..\Source\ScriptWizard\CnScript_Forms.pas',
  CnScript_Graphics in '..\..\Source\ScriptWizard\CnScript_Graphics.pas',
  CnScript_IniFiles in '..\..\Source\ScriptWizard\CnScript_IniFiles.pas',
  CnScript_Menus in '..\..\Source\ScriptWizard\CnScript_Menus.pas',
  CnScript_Messages in '..\..\Source\ScriptWizard\CnScript_Messages.pas',
  CnScript_Printers in '..\..\Source\ScriptWizard\CnScript_Printers.pas',
  CnScript_Registry in '..\..\Source\ScriptWizard\CnScript_Registry.pas',
  CnScript_StdCtrls in '..\..\Source\ScriptWizard\CnScript_StdCtrls.pas',
  CnScript_TypInfo in '..\..\Source\ScriptWizard\CnScript_TypInfo.pas',
  CnScript_Windows in '..\..\Source\ScriptWizard\CnScript_Windows.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormScriptEngine, FormScriptEngine);
  Application.Run;
end.
