unit UnitScript;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnScriptClasses;

type
  TFormScriptEngine = class(TForm)
    lblScript: TLabel;
    mmoScript: TMemo;
    btnExec: TButton;
    mmoResult: TMemo;
    procedure btnExecClick(Sender: TObject);
  private
    procedure MyWriteln(const Text: string);
  public

  end;

var
  FormScriptEngine: TFormScriptEngine;

implementation

{$R *.DFM}

uses
  CnScript_System, CnScript_Windows,
  CnScript_Messages, CnScript_SysUtils, CnScript_Classes, CnScript_TypInfo,
  CnScript_Graphics, CnScript_Controls, CnScript_Clipbrd, CnScript_Printers,
  CnScript_IniFiles, CnScript_Registry, CnScript_Menus, CnScript_ActnList,
  CnScript_Forms, CnScript_StdCtrls, CnScript_ExtCtrls, CnScript_ComCtrls,
  CnScript_Buttons, CnScript_Dialogs, CnScript_ExtDlgs, CnScript_ComObj;

procedure TFormScriptEngine.btnExecClick(Sender: TObject);
var
  Eng: TCnScriptExec;
  S: string;
begin
  Eng := TCnScriptExec.Create;
  Eng.OnWriteln := MyWriteln;
  try
    Eng.ExecScript(mmoScript.Lines.Text, S);

    if S <> '' then
      mmoResult.Lines.Add(S);
  finally
    Eng.Free;
  end;
end;

procedure TFormScriptEngine.MyWriteln(const Text: string);
begin
  mmoResult.Lines.Add(Text);
end;

initialization
  RegisterCnScriptPlugin(TPSImport_System);
  RegisterCnScriptPlugin(TPSImport_Windows);
  RegisterCnScriptPlugin(TPSImport_Messages);
  RegisterCnScriptPlugin(TPSImport_SysUtils);
  RegisterCnScriptPlugin(TPSImport_Classes);
  RegisterCnScriptPlugin(TPSImport_TypInfo);
  RegisterCnScriptPlugin(TPSImport_Graphics);
  RegisterCnScriptPlugin(TPSImport_Controls);
  RegisterCnScriptPlugin(TPSImport_Clipbrd);
  RegisterCnScriptPlugin(TPSImport_Printers);
  RegisterCnScriptPlugin(TPSImport_IniFiles);
  RegisterCnScriptPlugin(TPSImport_Registry);
  RegisterCnScriptPlugin(TPSImport_Menus);
  RegisterCnScriptPlugin(TPSImport_ActnList);
  RegisterCnScriptPlugin(TPSImport_Forms);
  RegisterCnScriptPlugin(TPSImport_StdCtrls);
  RegisterCnScriptPlugin(TPSImport_ExtCtrls);
  RegisterCnScriptPlugin(TPSImport_ComCtrls);
  RegisterCnScriptPlugin(TPSImport_Buttons);
  RegisterCnScriptPlugin(TPSImport_Dialogs);
  RegisterCnScriptPlugin(TPSImport_ExtDlgs);
  RegisterCnScriptPlugin(TPSImport_ComObj);

end.
