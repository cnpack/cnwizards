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
    { Public declarations }
  end;

var
  FormScriptEngine: TFormScriptEngine;

implementation

{$R *.DFM}

uses
  CnScript_System;

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

end.
