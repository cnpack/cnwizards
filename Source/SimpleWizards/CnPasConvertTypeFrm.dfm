object CnPasConvertTypeForm: TCnPasConvertTypeForm
  Left = 425
  Top = 350
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = '导出选项'
  ClientHeight = 187
  ClientWidth = 209
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblEncode: TLabel
    Left = 10
    Top = 100
    Width = 65
    Height = 13
    Caption = 'HTML 编码：'
  end
  object btnOK: TButton
    Left = 46
    Top = 155
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object rgConvertType: TRadioGroup
    Left = 8
    Top = 8
    Width = 193
    Height = 73
    Caption = '请选择导出类型 '
    ItemIndex = 0
    Items.Strings = (
      '&HTML 文档'
      '&RTF 文档')
    TabOrder = 0
    OnClick = rgConvertTypeClick
  end
  object btnCancel: TButton
    Left = 126
    Top = 155
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 4
  end
  object chkOpenAfterConvert: TCheckBox
    Left = 8
    Top = 128
    Width = 193
    Height = 17
    Caption = '转换完毕后打开文档或目录'
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
