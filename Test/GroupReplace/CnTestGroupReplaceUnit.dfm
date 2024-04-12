object GroupReplaceForm: TGroupReplaceForm
  Left = 192
  Top = 130
  BorderStyle = bsDialog
  Caption = 'Test Group Replace 32/64 Unicode/Non-Unicode'
  ClientHeight = 331
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblExchange1: TLabel
    Left = 24
    Top = 24
    Width = 76
    Height = 13
    Caption = 'To Exchange 1:'
  end
  object lblExchange2: TLabel
    Left = 288
    Top = 24
    Width = 76
    Height = 13
    Caption = 'To Exchange 2:'
  end
  object lblNote: TLabel
    Left = 24
    Top = 296
    Width = 480
    Height = 13
    Caption = 
      'This case should run OK under  IDE Ansi/Utf8/Unicode. (Such as D' +
      '5~7, D2005~2007, D2009~Now)'
  end
  object edtExchange1: TEdit
    Left = 120
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'X'
  end
  object edtExchange2: TEdit
    Left = 384
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Y'
  end
  object mmoText: TMemo
    Left = 24
    Top = 72
    Width = 481
    Height = 169
    Lines.Strings = (
      'begin'
      '  {³ÔµÄ} X := 1; X :=0;'
      ' {ºÈµÄ}Y := 2; Y := 3;'
      'end;')
    TabOrder = 2
  end
  object btnReplace: TButton
    Left = 24
    Top = 256
    Width = 481
    Height = 25
    Caption = 'Replace'
    TabOrder = 3
    OnClick = btnReplaceClick
  end
end
