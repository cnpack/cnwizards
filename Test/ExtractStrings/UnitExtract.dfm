object FormExtract: TFormExtract
  Left = 192
  Top = 107
  Width = 979
  Height = 563
  Caption = 'Extract Strings from Source'
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
  object btnConvertIdent: TButton
    Left = 16
    Top = 24
    Width = 113
    Height = 25
    Caption = 'Convert to Ident'
    TabOrder = 0
    OnClick = btnConvertIdentClick
  end
  object mmoStrings: TMemo
    Left = 16
    Top = 72
    Width = 385
    Height = 185
    Lines.Strings = (
      'mmoStrings'
      'I am CnPack Team Member.'
      'OK! 吃饭了！有不少菜'
      '3.1415926'
      '纯文本，看看')
    TabOrder = 1
  end
  object chkUnderLine: TCheckBox
    Left = 152
    Top = 32
    Width = 97
    Height = 17
    Caption = 'UnderLine'
    TabOrder = 2
  end
  object mmoIdent: TMemo
    Left = 16
    Top = 272
    Width = 385
    Height = 233
    TabOrder = 3
  end
  object cbbStyle: TComboBox
    Left = 256
    Top = 32
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 4
    Items.Strings = (
      'UpperCase'
      'LowerCase'
      'UpperFirst')
  end
end
