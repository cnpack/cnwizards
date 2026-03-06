object CnCmdSendForm: TCnCmdSendForm
  Left = 378
  Top = 151
  BorderStyle = bsDialog
  Caption = '测试 Command 的发送'
  ClientHeight = 540
  ClientWidth = 545
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '宋体'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object bvl1: TBevel
    Left = 22
    Top = 330
    Width = 171
    Height = 15
    Anchors = [akLeft, akBottom]
    Shape = bsTopLine
  end
  object lblCommand: TLabel
    Left = 22
    Top = 22
    Width = 60
    Height = 12
    Caption = '命令数值：'
  end
  object lblCompilers: TLabel
    Left = 222
    Top = 22
    Width = 216
    Height = 12
    Caption = '目标 Delphi 版本（未选择表示全选）：'
  end
  object lblParam: TLabel
    Left = 22
    Top = 86
    Width = 48
    Height = 12
    Caption = '参数值：'
  end
  object lblDest: TLabel
    Left = 22
    Top = 190
    Width = 132
    Height = 12
    Caption = '目标名（空表示广播）：'
  end
  object btnSimpleSend: TButton
    Left = 22
    Top = 289
    Width = 171
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '简单发送广播测试命令'
    TabOrder = 0
    OnClick = btnSimpleSendClick
  end
  object btnRegRecv: TButton
    Left = 22
    Top = 348
    Width = 171
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '注册通知以便接收回应'
    TabOrder = 1
    OnClick = btnRegRecvClick
  end
  object pnlDisp: TPanel
    Left = 22
    Top = 383
    Width = 499
    Height = 52
    Anchors = [akLeft, akRight, akBottom]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = '未注册通知'
    TabOrder = 2
  end
  object pnl2: TPanel
    Left = 22
    Top = 456
    Width = 499
    Height = 53
    Anchors = [akLeft, akRight, akBottom]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = '未收到内容'
    TabOrder = 3
  end
  object mmo1: TMemo
    Left = 22
    Top = 111
    Width = 171
    Height = 60
    Lines.Strings = (
      'param1=value1'
      'param2=value2')
    TabOrder = 4
  end
  object edtCommand: TEdit
    Left = 22
    Top = 44
    Width = 171
    Height = 20
    TabOrder = 5
    Text = '0'
  end
  object scbCompilers: TScrollBox
    Left = 222
    Top = 44
    Width = 299
    Height = 325
    VertScrollBar.Tracking = True
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWindow
    ParentColor = False
    TabOrder = 6
  end
  object edtDest: TEdit
    Left = 22
    Top = 212
    Width = 171
    Height = 20
    TabOrder = 7
    Text = '0'
  end
end
