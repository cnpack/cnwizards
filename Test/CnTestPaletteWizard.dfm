object TestPaletteForm: TTestPaletteForm
  Left = 412
  Top = 223
  BorderStyle = bsDialog
  Caption = 'Test Palette Wrapper'
  ClientHeight = 336
  ClientWidth = 523
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
  object bvl1: TBevel
    Left = 216
    Top = 16
    Width = 17
    Height = 305
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
  object edtFind: TEdit
    Left = 16
    Top = 296
    Width = 89
    Height = 21
    TabOrder = 3
    Text = 'Win32'
  end
  object btnFindTab: TButton
    Left = 120
    Top = 296
    Width = 75
    Height = 25
    Caption = 'Find Tab'
    TabOrder = 4
    OnClick = btnFindTabClick
  end
  object btnShowComp: TButton
    Left = 360
    Top = 16
    Width = 145
    Height = 25
    Caption = 'Show Selected Component'
    TabOrder = 5
    OnClick = btnShowCompClick
  end
  object btnShowComps: TButton
    Left = 240
    Top = 16
    Width = 105
    Height = 25
    Caption = 'Show Components'
    TabOrder = 6
    OnClick = btnShowCompsClick
  end
  object lstComps: TListBox
    Left = 240
    Top = 56
    Width = 177
    Height = 225
    ItemHeight = 13
    TabOrder = 7
  end
  object edtSelComp: TEdit
    Left = 240
    Top = 296
    Width = 121
    Height = 21
    TabOrder = 8
    Text = 'TActionList'
  end
  object btnSelectComp: TButton
    Left = 376
    Top = 296
    Width = 105
    Height = 25
    Caption = 'Select Component'
    TabOrder = 9
    OnClick = btnSelectCompClick
  end
end
