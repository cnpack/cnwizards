unit CnTestCmdRecv;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, CnWizCompilerConst, StdCtrls;

type
  TCnCmdRecvForm = class(TForm)
    pnlDisp: TPanel;
    chkAutoReply: TCheckBox;
    mmo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    procedure OnCmdRecv(const Command: Cardinal; const SourceID: PAnsiChar;
      const DestID: PAnsiChar; const IDESets: TCnCompilers; const Params: TStrings);
  public

  end;

var
  CnCmdRecvForm: TCnCmdRecvForm;

implementation

uses
  CnWizCmdNotify, CnWizCmdSend, CnWizCmdMsg;

{$R *.DFM}

const
  SCnCmdTestSendID = 'CnCmdTestSend';
  SCnCmdTestRecvID = 'CnCmdTestRecv';

procedure TCnCmdRecvForm.FormCreate(Sender: TObject);
begin
  Application.Title := Caption;
  CnWizCmdNotifier.AddCmdNotifier(OnCmdRecv, SCnCmdTestRecvID); // �������� ID��ֻ�շ����� ID �ġ�
end;

procedure TCnCmdRecvForm.OnCmdRecv(const Command: Cardinal; const SourceID,
  DestID: PAnsiChar; const IDESets: TCnCompilers; const Params: TStrings);
begin
  pnlDisp.Caption := Format('�յ������Ϣ�� $%s' + #13#10 + '��Դ��%s',
    [InttoHex(Command, 2), SourceID]);
  mmo1.Lines.Text := Params.Text;
  
  if chkAutoReply.Checked then
    CnWizReplyCommand(CN_WIZ_CMD_USER_TEST);
end;

end.
