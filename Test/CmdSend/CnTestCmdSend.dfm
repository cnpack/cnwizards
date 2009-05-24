object CnCmdSendForm: TCnCmdSendForm
  Left = 282
  Top = 119
  BorderStyle = bsDialog
  Caption = '测试 Command 的发送'
  ClientHeight = 366
  ClientWidth = 249
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '宋体'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object bvl1: TBevel
    Left = 24
    Top = 136
    Width = 201
    Height = 17
    Shape = bsTopLine
  end
  object btnSimpleSend: TButton
    Left = 24
    Top = 24
    Width = 201
    Height = 25
    Caption = '简单发送广播测试命令'
    TabOrder = 0
    OnClick = btnSimpleSendClick
  end
  object btnRegRecv: TButton
    Left = 24
    Top = 156
    Width = 201
    Height = 25
    Caption = '注册通知以便接收回应'
    TabOrder = 1
    OnClick = btnRegRecvClick
  end
  object pnlDisp: TPanel
    Left = 24
    Top = 200
    Width = 201
    Height = 57
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = '未注册通知'
    TabOrder = 2
  end
  object pnl2: TPanel
    Left = 24
    Top = 280
    Width = 201
    Height = 57
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = '未收到内容'
    TabOrder = 3
  end
  object mmo1: TMemo
    Left = 24
    Top = 72
    Width = 201
    Height = 41
    Lines.Strings = (
      'param1=value1'
      'param2=value2')
    TabOrder = 4
  end
end
