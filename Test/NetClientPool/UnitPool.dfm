object FormPool: TFormPool
  Left = 192
  Top = 108
  Width = 924
  Height = 550
  Caption = 'HTTPS Client Thread Pool'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnAddHttps: TButton
    Left = 16
    Top = 16
    Width = 97
    Height = 25
    Caption = 'Add Many HTTPS'
    TabOrder = 0
    OnClick = btnAddHttpsClick
  end
  object mmoHTTP: TMemo
    Left = 16
    Top = 56
    Width = 881
    Height = 449
    TabOrder = 1
  end
  object btnAIConfigSave: TButton
    Left = 144
    Top = 16
    Width = 97
    Height = 25
    Caption = 'AI Config Save'
    TabOrder = 2
    OnClick = btnAIConfigSaveClick
  end
  object btnAIConfigLoad: TButton
    Left = 264
    Top = 16
    Width = 97
    Height = 25
    Caption = 'AI Config Load'
    TabOrder = 3
    OnClick = btnAIConfigLoadClick
  end
  object dlgSave1: TSaveDialog
    Left = 384
    Top = 16
  end
  object dlgOpen1: TOpenDialog
    Left = 424
    Top = 16
  end
end
