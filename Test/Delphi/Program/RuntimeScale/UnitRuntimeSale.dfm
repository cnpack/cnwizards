object FormRuntimeTest: TFormRuntimeTest
  Left = 398
  Top = 151
  Width = 535
  Height = 413
  Caption = 'Runtime Scale Test - This Form Not Included'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblScale: TLabel
    Left = 24
    Top = 24
    Width = 45
    Height = 13
    Caption = 'Scale By:'
  end
  object cbbScale: TComboBox
    Left = 80
    Top = 20
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    Text = '1.5'
    OnChange = cbbScaleChange
    Items.Strings = (
      '1.25'
      '1.5'
      '2'
      '3')
  end
  object btn1: TButton
    Left = 256
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Show Form1'
    TabOrder = 1
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 344
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Show Form2'
    TabOrder = 2
    OnClick = btn2Click
  end
  object btn3: TButton
    Left = 432
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Show Form3'
    TabOrder = 3
    OnClick = btn3Click
  end
end
