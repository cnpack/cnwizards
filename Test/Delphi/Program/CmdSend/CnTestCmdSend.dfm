object CnCmdSendForm: TCnCmdSendForm
  Left = 282
  Top = 119
  BorderStyle = bsDialog
  Caption = '���� Command �ķ���'
  ClientHeight = 366
  ClientWidth = 249
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '����'
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
    Caption = '�򵥷��͹㲥��������'
    TabOrder = 0
    OnClick = btnSimpleSendClick
  end
  object btnRegRecv: TButton
    Left = 24
    Top = 156
    Width = 201
    Height = 25
    Caption = 'ע��֪ͨ�Ա���ջ�Ӧ'
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
    Caption = 'δע��֪ͨ'
    TabOrder = 2
  end
  object pnl2: TPanel
    Left = 24
    Top = 280
    Width = 201
    Height = 57
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = 'δ�յ�����'
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
