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
    Left = 32
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
  end
  object CheckBox1: TCheckBox
    Left = 192
    Top = 40
    Width = 97
    Height = 17
    Caption = 'CheckBox1'
    TabOrder = 1
  end
  object btnCompare: TButton
    Left = 32
    Top = 136
    Width = 337
    Height = 137
    Caption = 'Compare'
    TabOrder = 2
    OnClick = btnCompareClick
  end
end
