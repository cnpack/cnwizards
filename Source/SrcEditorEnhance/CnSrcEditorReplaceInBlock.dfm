inherited CnSrcEditorReplaceInBlockForm: TCnSrcEditorReplaceInBlockForm
  Left = 552
  Top = 434
  ActiveControl = edtFrom
  BorderStyle = bsDialog
  Caption = 'Replace in Selection'
  ClientHeight = 173
  ClientWidth = 423
  Font.Charset = ANSI_CHARSET
  PixelsPerInch = 96
  TextHeight = 13
  object lblReplace: TLabel
    Left = 16
    Top = 20
    Width = 42
    Height = 13
    Caption = 'Replace:'
  end
  object lblTo: TLabel
    Left = 16
    Top = 52
    Width = 16
    Height = 13
    Caption = 'To:'
  end
  object btnHelp: TButton
    Left = 339
    Top = 143
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 0
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 179
    Top = 143
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 259
    Top = 143
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edtFrom: TEdit
    Left = 80
    Top = 16
    Width = 332
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
  end
  object edtTo: TEdit
    Left = 80
    Top = 48
    Width = 332
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
  end
  object chkInverse: TCheckBox
    Left = 80
    Top = 80
    Width = 217
    Height = 17
    Caption = 'Also Replace Inverse'
    TabOrder = 5
  end
  object chkSaveToItem: TCheckBox
    Left = 80
    Top = 104
    Width = 217
    Height = 17
    Caption = 'Save To Group Replace Item'
    TabOrder = 6
  end
end
