program CnTestPPUInfo;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms,
  CnTestPPUInfoFrm in 'CnTestPPUInfoFrm.pas' {FormPPUInfo},
  CnPPUInfo in '..\..\..\..\Source\Utils\CnPPUInfo.pas';

{$R *.res}

begin
  Application.Initialize;
  //Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPPUInfo, FormPPUInfo);
  Application.Run;
end.
