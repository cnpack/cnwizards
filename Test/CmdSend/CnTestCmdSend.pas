unit CnTestCmdSend;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, CnWizCompilerConst;

type
  TCnCmdSendForm = class(TForm)
    btnSimpleSend: TButton;
    btnRegRecv: TButton;
    bvl1: TBevel;
    pnlDisp: TPanel;
    pnl2: TPanel;
    mmo1: TMemo;
    procedure btnSimpleSendClick(Sender: TObject);
    procedure btnRegRecvClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure OnCmdRecv(const Command: Cardinal; const SourceID: PChar;
      const DestID: PChar; const IDESets: TCnCompilers; const Params: TStrings);
  public
    { Public declarations }
  end;

var
  CnCmdSendForm: TCnCmdSendForm;

implementation

uses
  CnWizCmdSend, CnWizCmdMsg, CnWizCmdNotify;

{$R *.DFM}

const
  SCnCmdTestSendID = 'CnCmdTestSend';
  SCnCmdTestRecvID = 'CnCmdTestRecv';

procedure TCnCmdSendForm.btnSimpleSendClick(Sender: TObject);
begin
  if CnWizSendCommand(CN_WIZ_CMD_TEST, [], SCnCmdTestRecvID, SCnCmdTestSendID, mmo1.Lines) then
    pnlDisp.Caption := '发送成功！'
  else
    pnlDisp.Caption := '发送失败！';
end;

procedure TCnCmdSendForm.btnRegRecvClick(Sender: TObject);
begin
  if Tag = 0 then // 用 Tag 表示是否注册
  begin
    CnWizCmdNotifier.AddCmdNotifier(OnCmdRecv, [], SCnCmdTestSendID);
    Tag := 1;
    pnlDisp.Caption := '注册通知器成功！';
  end;
end;

procedure TCnCmdSendForm.OnCmdRecv(const Command: Cardinal; const SourceID,
  DestID: PChar; const IDESets: TCnCompilers; const Params: TStrings);
begin
  pnl2.Caption := Format('收到回应！消息号 $%s' + #13#10 + '来源：%s',
    [InttoHex(Command, 2), SourceID]);
end;

procedure TCnCmdSendForm.FormCreate(Sender: TObject);
begin
  Application.Title := Caption;
end;

end.
