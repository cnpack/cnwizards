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
end
