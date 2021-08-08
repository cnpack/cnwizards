object FormTestCompare: TFormTestCompare
  Left = 365
  Top = 164
  Width = 418
  Height = 341
  Caption = 'Test Compare Properties'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 0
    Top = 0
    Width = 3
    Height = 314
    Cursor = crHSplit
  end
  object Button1: TButton
    Left = 16
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
  end
  object CheckBox1: TCheckBox
    Left = 104
    Top = 16
    Width = 97
    Height = 17
    Caption = 'CheckBox1'
    TabOrder = 1
  end
  object btnCompare: TButton
    Left = 16
    Top = 56
    Width = 169
    Height = 57
    Caption = 'Compare'
    TabOrder = 2
    OnClick = btnCompareClick
  end
  object btnCompare2: TButton
    Left = 240
    Top = 56
    Width = 113
    Height = 33
    Caption = 'Compare 2'
    TabOrder = 3
    OnClick = btnCompare2Click
  end
end
