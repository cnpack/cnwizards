object CnCmdRecvForm: TCnCmdRecvForm
  Left = 431
  Top = 267
  BorderStyle = bsDialog
  Caption = '���� Command �Ľ���'
  ClientHeight = 223
  ClientWidth = 251
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '����'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object pnlDisp: TPanel
    Left = 32
    Top = 32
    Width = 185
    Height = 49
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = '��ע�������'
    TabOrder = 0
  end
  object chkAutoReply: TCheckBox
    Left = 32
    Top = 176
    Width = 185
    Height = 17
    Caption = '�յ�ʱ�Զ� Reply ����'
    TabOrder = 1
  end
  object mmo1: TMemo
    Left = 32
    Top = 104
    Width = 185
    Height = 49
    TabOrder = 2
  end
end
