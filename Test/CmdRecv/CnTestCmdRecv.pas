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
    { Private declarations }
    procedure OnCmdRecv(const Command: Cardinal; const SourceID: PChar;
      const DestID: PChar; const IDESets: TCnCompilers; const Params: TStrings);
  public
    { Public declarations }
  end;

var
  CnCmdRecvForm: TCnCmdRecvForm;

implementation

uses
  CnWizCmdNotify, CnWizCmdSend, CnWizCmdMsg;

{$R *.DFM}

procedure TCnCmdRecvForm.FormCreate(Sender: TObject);
begin
  Application.Title := Caption;
  CnWizCmdNotifier.AddCmdNotifier(OnCmdRecv);
end;

procedure TCnCmdRecvForm.OnCmdRecv(const Command: Cardinal; const SourceID,
  DestID: PChar; const IDESets: TCnCompilers; const Params: TStrings);
begin
  pnlDisp.Caption := Format('收到命令！消息号 $%s' + #13#10 + '来源：%s',
    [InttoHex(Command, 2), SourceID]);
  mmo1.Lines.Text := Params.Text;
  
  if chkAutoReply.Checked then
    CnWizReplyCommand(CN_WIZ_CMD_USER_TEST);
end;

end.
