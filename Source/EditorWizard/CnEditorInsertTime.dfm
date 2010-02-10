inherited CnEditorInsertTimeForm: TCnEditorInsertTimeForm
  Left = 509
  Top = 415
  BorderStyle = bsDialog
  Caption = 'Insert Date Time'
  ClientHeight = 117
  ClientWidth = 284
  PixelsPerInch = 96
  TextHeight = 13
  object lblFmt: TLabel
    Left = 16
    Top = 18
    Width = 34
    Height = 13
    Caption = 'Format'
  end
  object lblPreview: TLabel
    Left = 16
    Top = 50
    Width = 42
    Height = 13
    Caption = 'Preview:'
  end
  object cbbDateTimeFmt: TComboBox
    Left = 72
    Top = 16
    Width = 193
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbbDateTimeFmtChange
    Items.Strings = (
      'yyyy-mm-dd hh:mm:ss'
      'yyyy-mm-dd hh:mm'
      'yyyy-mm-dd hh'
      'yyyy-mm-dd')
  end
  object edtPreview: TEdit
    Left = 72
    Top = 48
    Width = 193
    Height = 21
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 70
    Top = 82
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 150
    Top = 82
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
