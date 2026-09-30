program CnTestHotKey;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms,
  CnTestHotKeyFrm in 'CnTestHotKeyFrm.pas' {FormHotKeyTest},
  CnHotKey in '..\..\..\..\Source\Utils\CnHotKey.pas';

begin
  Application.Initialize;
  Application.CreateForm(TFormHotKeyTest, FormHotKeyTest);
  Application.Run;
end.
