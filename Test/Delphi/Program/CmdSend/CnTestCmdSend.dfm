object CnCmdSendForm: TCnCmdSendForm
  Left = 432
  Top = 143
  BorderStyle = bsDialog
  Caption = '测试 Command 的发送'
  ClientHeight = 574
  ClientWidth = 619
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
  object lblCommand: TLabel
    Left = 22
    Top = 22
    Width = 60
    Height = 12
    Caption = '命令数值：'
  end
  object lblCompilers: TLabel
    Left = 318
    Top = 22
    Width = 216
    Height = 12
    Caption = '目标 Delphi 版本（未选择表示全选）：'
  end
  object lblParam: TLabel
    Left = 22
    Top = 254
    Width = 48
    Height = 12
    Caption = '参数值：'
  end
  object lblDest: TLabel
    Left = 22
    Top = 406
    Width = 132
    Height = 12
    Caption = '目标名（空表示广播）：'
  end
  object btnSimpleSend: TButton
    Left = 22
    Top = 462
    Width = 280
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '发送命令！！！'
    TabOrder = 0
    OnClick = btnSimpleSendClick
  end
  object btnRegRecv: TButton
    Left = 320
    Top = 462
    Width = 280
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '注册通知以便接收回应'
    TabOrder = 1
    OnClick = btnRegRecvClick
  end
  object pnlDisp: TPanel
    Left = 22
    Top = 500
    Width = 280
    Height = 52
    Anchors = [akLeft, akRight, akBottom]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = '未注册通知'
    TabOrder = 2
  end
  object pnl2: TPanel
    Left = 320
    Top = 500
    Width = 280
    Height = 53
    Anchors = [akLeft, akBottom]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = '未收到内容'
    TabOrder = 3
  end
  object mmo1: TMemo
    Left = 22
    Top = 272
    Width = 280
    Height = 121
    Lines.Strings = (
      'param1=value1'
      'param2=value2')
    ScrollBars = ssBoth
    TabOrder = 4
    WantReturns = False
    WordWrap = False
  end
  object edtCommand: TEdit
    Left = 22
    Top = 44
    Width = 280
    Height = 20
    TabOrder = 5
    Text = '0'
  end
  object scbCompilers: TScrollBox
    Left = 320
    Top = 44
    Width = 281
    Height = 405
    VertScrollBar.Tracking = True
    Anchors = [akLeft, akTop, akBottom]
    Color = clWindow
    ParentColor = False
    TabOrder = 6
  end
  object edtDest: TEdit
    Left = 22
    Top = 428
    Width = 280
    Height = 20
    TabOrder = 7
    Text = '0'
  end
  object lstMsg: TListBox
    Left = 22
    Top = 80
    Width = 280
    Height = 161
    ItemHeight = 12
    Items.Strings = (
      '3534 查看当前活动窗体'
      '3535 生成当前窗体的语言条目'
      '3536 生成所有窗体的语言条目'
      '3537 翻译当前活动窗体'
      '3538 翻译所有窗体'
      '3539 通知多语插件在切换窗体时翻译'
      '3540 从剪贴板加载语言条目'
      '3541 通知多语插件根据参数语言条目进行翻译')
    TabOrder = 8
    OnClick = lstMsgClick
  end
end
