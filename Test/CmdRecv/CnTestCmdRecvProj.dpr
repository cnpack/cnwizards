program CnTestCmdRecvProj;

uses
  Forms,
  CnTestCmdRecv in 'CnTestCmdRecv.pas' {CnCmdRecvForm},
  CnWizCmdMsg in '..\..\Source\Command\CnWizCmdMsg.pas',
  CnWizCmdNotify in '..\..\Source\Command\CnWizCmdNotify.pas',
  CnWizCmdSend in '..\..\Source\Command\CnWizCmdSend.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TCnCmdRecvForm, CnCmdRecvForm);
  Application.Run;
end.
