inherited CnPasConvertTypeForm: TCnPasConvertTypeForm
  Left = 425
  Top = 350
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Export Format Type'
  ClientHeight = 187
  ClientWidth = 209
  PixelsPerInch = 96
  TextHeight = 13
  object lblEncode: TLabel
    Left = 10
    Top = 100
    Width = 68
    Height = 13
    Caption = 'HTML Encode:'
  end
  object btnOK: TButton
    Left = 46
    Top = 155
    Width = 75
    Height = 21
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object rgConvertType: TRadioGroup
    Left = 8
    Top = 8
    Width = 193
    Height = 73
    Caption = 'Please Select Convert Option'
    ItemIndex = 0
    Items.Strings = (
      '&HTML Format'
      '&RTF Format')
    TabOrder = 0
    OnClick = rgConvertTypeClick
  end
  object btnCancel: TButton
    Left = 126
    Top = 155
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object chkOpenAfterConvert: TCheckBox
    Left = 8
    Top = 128
    Width = 193
    Height = 17
    Caption = 'Open File/Dir after Converting.'
    TabOrder = 2
  end
  object cbbEncoding: TComboBox
    Left = 80
    Top = 96
    Width = 121
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    Items.Strings = (
      'gb2312'
      'big5'
      'iso-8859-1')
  end
end
