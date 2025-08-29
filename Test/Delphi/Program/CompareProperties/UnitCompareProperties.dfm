object FormTestCompare: TFormTestCompare
  Left = 365
  Top = 164
  Width = 581
  Height = 341
  Caption = 'Test Compare Properties 32/64 Unicode/Non-Unicode'
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
  object bvl1: TBevel
    Left = 16
    Top = 80
    Width = 545
    Height = 9
    Shape = bsTopLine
  end
  object Button1: TButton
    Left = 16
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object CheckBox1: TCheckBox
    Left = 104
    Top = 8
    Width = 97
    Height = 17
    Caption = 'CheckBox1'
    TabOrder = 1
  end
  object btnCompare: TButton
    Left = 392
    Top = 8
    Width = 169
    Height = 57
    Caption = 'Compare'
    TabOrder = 2
    OnClick = btnCompareClick
  end
  object btnCompare2: TButton
    Left = 16
    Top = 40
    Width = 369
    Height = 25
    Caption = 'Compare 2'
    TabOrder = 3
    OnClick = btnCompare2Click
  end
  object RadioButton1: TRadioButton
    Left = 224
    Top = 8
    Width = 113
    Height = 17
    Caption = 'RadioButton1'
    TabOrder = 4
    OnClick = RadioButton1Click
  end
  object Memo1: TMemo
    Left = 320
    Top = 8
    Width = 65
    Height = 25
    Lines.Strings = (
      'Memo1')
    TabOrder = 5
  end
  object mmoLeft: TMemo
    Left = 16
    Top = 104
    Width = 257
    Height = 145
    Lines.Strings = (
      'Align'
      'Width'
      'WantTab'
      'OnChange'
      'OnClick'
      'OnStartDrag')
    TabOrder = 6
  end
  object mmoRight: TMemo
    Left = 288
    Top = 104
    Width = 257
    Height = 145
    Lines.Strings = (
      'Align'
      'Width'
      'WantTab'
      'WantReturn'
      'OnClick'
      'OnStartDrag')
    TabOrder = 7
  end
  object btnMerge: TButton
    Left = 248
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Merge'
    TabOrder = 8
    OnClick = btnMergeClick
  end
end
