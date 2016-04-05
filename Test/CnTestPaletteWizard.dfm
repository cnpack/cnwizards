object TestPaletteForm: TTestPaletteForm
  Left = 349
  Top = 287
  Width = 513
  Height = 331
  Caption = 'Test Palette Wrapper'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object bvl1: TBevel
    Left = 216
    Top = 16
    Width = 17
    Height = 265
    Shape = bsLeftLine
  end
  object btnShowTabs: TButton
    Left = 16
    Top = 16
    Width = 81
    Height = 25
    Caption = 'Show Tabs'
    TabOrder = 0
    OnClick = btnShowTabsClick
  end
  object btnSetTab: TButton
    Left = 112
    Top = 16
    Width = 81
    Height = 25
    Caption = 'Set Active Tab'
    TabOrder = 1
    OnClick = btnSetTabClick
  end
  object lstTabs: TListBox
    Left = 16
    Top = 56
    Width = 177
    Height = 225
    ItemHeight = 13
    TabOrder = 2
  end
end
