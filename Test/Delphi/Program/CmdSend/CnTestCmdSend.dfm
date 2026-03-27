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
    Left = 366
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
    Width = 331
    Height = 121
    ScrollBars = ssBoth
    TabOrder = 4
    WantReturns = False
    WordWrap = False
  end
  object edtCommand: TEdit
    Left = 22
    Top = 44
    Width = 331
    Height = 20
    TabOrder = 5
    Text = '0'
  end
  object scbCompilers: TScrollBox
    Left = 368
    Top = 44
    Width = 233
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
    Width = 331
    Height = 20
    TabOrder = 7
  end
  object lstMsg: TListBox
    Left = 22
    Top = 80
    Width = 331
    Height = 161
    ItemHeight = 12
    Items.Strings = (
      '3534 查看当前活动窗体'
      '3535 生成当前窗体的语言条目'
      '3536 生成所有窗体的语言条目'
      '3537 翻译当前活动窗体'
      '3538 翻译所有窗体'
      '3539 启用在切换窗体时翻译'
      '3540 从剪贴板加载语言条目'
      '3541 根据参数语言条目进行翻译'
      
        '3542 初始化生成条目功能并准备捕获生成，参数 FileName 表示加载旧' +
        '有文本'
      '3543 停止生成条目功能并保存文件'
      '3544 将拦截到的 TextRect 的参数字符串放到剪贴板'
      '3545 清空拦截到的 TextRect 的字符串并继续拦截'
      '3546 将当前语言存储条目放至剪贴板，参数为前缀过滤'
      '3547 翻译当前活动窗体的目录树组件')
    TabOrder = 8
    OnClick = lstMsgClick
  end
end
