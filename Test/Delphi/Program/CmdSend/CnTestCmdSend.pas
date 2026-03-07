unit CnTestCmdSend;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, CnWizCompilerConst, TypInfo;

type
  TCnCmdSendForm = class(TForm)
    btnSimpleSend: TButton;
    btnRegRecv: TButton;
    bvl1: TBevel;
    pnlDisp: TPanel;
    pnl2: TPanel;
    mmo1: TMemo;
    lblCommand: TLabel;
    edtCommand: TEdit;
    lblCompilers: TLabel;
    scbCompilers: TScrollBox;
    lblParam: TLabel;
    edtDest: TEdit;
    lblDest: TLabel;
    lstMsg: TListBox;
    procedure btnSimpleSendClick(Sender: TObject);
    procedure btnRegRecvClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstMsgClick(Sender: TObject);
  private
    FCheckBoxList: TList;
    procedure CreateCompilerCheckBoxes;
    function GetSelectedCompilers: TCnCompilers;
    procedure OnCmdRecv(const Command: Cardinal; const SourceID: PAnsiChar;
      const DestID: PAnsiChar; const IDESets: TCnCompilers; const Params: TStrings);
  public

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

procedure TCnCmdSendForm.CreateCompilerCheckBoxes;
var
  TypeInfo: PTypeInfo;
  TypeData: PTypeData;
  I: Integer;
  CheckBox: TCheckBox;
  EnumName: string;
  TopPos: Integer;
begin
  TypeInfo := System.TypeInfo(TCnCompiler);
  if TypeInfo = nil then
    Exit;

  TypeData := GetTypeData(TypeInfo);
  if TypeData = nil then
    Exit;

  TopPos := 8;
  for I := TypeData^.MinValue to TypeData^.MaxValue do
  begin
    EnumName := GetEnumName(TypeInfo, I);
    CheckBox := TCheckBox.Create(Self);
    CheckBox.Width := 200;
    CheckBox.Parent := scbCompilers;
    CheckBox.Left := 8;
    CheckBox.Top := TopPos;
    CheckBox.Caption := SCnCompilerNames[TCnCompiler(I)];
    CheckBox.Tag := I;
    FCheckBoxList.Add(CheckBox);
    TopPos := TopPos + 20;
  end;
end;

function TCnCmdSendForm.GetSelectedCompilers: TCnCompilers;
var
  I: Integer;
  CheckBox: TCheckBox;
begin
  Result := [];
  for I := 0 to FCheckBoxList.Count - 1 do
  begin
    CheckBox := TCheckBox(FCheckBoxList[I]);
    if CheckBox.Checked then
      Include(Result, TCnCompiler(CheckBox.Tag));
  end;
end;

procedure TCnCmdSendForm.btnSimpleSendClick(Sender: TObject);
var
  Cmd: Cardinal;
  DestSet: TCnCompilers;
begin
  if edtCommand.Text = '' then
  begin
    pnlDisp.Caption := '请输入命令数值';
    Exit;
  end;

  try
    Cmd := StrToInt(edtCommand.Text);
  except
    pnlDisp.Caption := '命令数值非法';
    Exit;
  end;

  DestSet := GetSelectedCompilers;
  if CnWizSendCommand(Cmd, DestSet, edtDest.Text, SCnCmdTestSendID, mmo1.Lines) then
    pnlDisp.Caption := '发送成功！'
  else
    pnlDisp.Caption := '发送失败！';
end;

procedure TCnCmdSendForm.btnRegRecvClick(Sender: TObject);
begin
  if Tag = 0 then // 用 Tag 表示是否注册
  begin
    CnWizCmdNotifier.AddCmdNotifier(OnCmdRecv, SCnCmdTestSendID);
    Tag := 1;
    pnlDisp.Caption := '注册通知器成功！';
  end;
end;

procedure TCnCmdSendForm.OnCmdRecv(const Command: Cardinal; const SourceID,
  DestID: PAnsiChar; const IDESets: TCnCompilers; const Params: TStrings);
begin
  pnl2.Caption := Format('收到回应！消息号 $%s' + #13#10 + '来源：%s',
    [InttoHex(Command, 2), SourceID]);
end;

procedure TCnCmdSendForm.FormCreate(Sender: TObject);
begin
  Application.Title := Caption;
  FCheckBoxList := TList.Create;
  CreateCompilerCheckBoxes;
  edtCommand.Text := IntToStr(CN_WIZ_CMD_TEST);
  edtDest.Text := SCnCmdTestRecvID;
end;

procedure TCnCmdSendForm.FormDestroy(Sender: TObject);
begin
  FCheckBoxList.Free;
end;

procedure TCnCmdSendForm.lstMsgClick(Sender: TObject);
var
  S: string;
begin
  if lstMsg.ItemIndex >= 0 then
  begin
    S := lstMsg.Items[lstMsg.ItemIndex];
    if Pos(' ', S) > 0 then
      Delete(S, Pos(' ', S), MaxInt);
    edtCommand.Text := S;
  end;
end;

end.
