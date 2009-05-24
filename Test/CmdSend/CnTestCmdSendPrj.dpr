program CnTestCmdSendPrj;

uses
  Forms,
  CnTestCmdSend in 'CnTestCmdSend.pas' {CnCmdSendForm},
  CnWizCmdMsg in '..\..\Source\Command\CnWizCmdMsg.pas',
  CnWizCmdSend in '..\..\Source\Command\CnWizCmdSend.pas',
  CnWizCmdNotify in '..\..\Source\Command\CnWizCmdNotify.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TCnCmdSendForm, CnCmdSendForm);
  Application.Run;
end.
