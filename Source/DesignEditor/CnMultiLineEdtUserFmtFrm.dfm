inherited CnMultiLineEditorUserFmtForm: TCnMultiLineEditorUserFmtForm
  Left = 366
  Top = 237
  BorderStyle = bsDialog
  Caption = 'Customize String Format:'
  ClientHeight = 159
  ClientWidth = 318
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 16
    Top = 12
    Width = 32
    Height = 13
    Caption = 'Prefix:'
  end
  object lbl2: TLabel
    Left = 16
    Top = 40
    Width = 34
    Height = 13
    Caption = 'Subfix:'
  end
  object btnOK: TButton
    Left = 147
    Top = 124
    Width = 75
    Height = 21
    Anchors = [akTop, akRight]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 230
    Top = 124
    Width = 75
    Height = 21
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object edt1: TEdit
    Left = 56
    Top = 8
    Width = 245
    Height = 21
    TabOrder = 0
  end
  object edt2: TEdit
    Left = 56
    Top = 36
    Width = 245
    Height = 21
    TabOrder = 1
  end
  object chk1: TCheckBox
    Left = 40
    Top = 68
    Width = 261
    Height = 17
    Caption = 'Only Process Selected String.'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object chk2: TCheckBox
    Left = 40
    Top = 96
    Width = 261
    Height = 17
    Caption = 'Process Partly by Row.'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
end
