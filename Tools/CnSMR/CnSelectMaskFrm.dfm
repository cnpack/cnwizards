object CnSelectMaskForm: TCnSelectMaskForm
  Left = 319
  Top = 396
  BorderStyle = bsDialog
  Caption = 'Delete directories/files mask'
  ClientHeight = 122
  ClientWidth = 382
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 12
    Top = 16
    Width = 314
    Height = 13
    Caption = 
      'Please input &mask for directories and files (such as: *.bak;*.~' +
      '*) :'
    FocusControl = edtMasks
  end
  object btnOK: TButton
    Left = 204
    Top = 85
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 296
    Top = 85
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object edtMasks: TEdit
    Left = 12
    Top = 35
    Width = 359
    Height = 21
    TabOrder = 0
    OnChange = edtMasksChange
    OnContextPopup = edtMasksContextPopup
  end
  object chbDelDirs: TCheckBox
    Left = 12
    Top = 62
    Width = 105
    Height = 17
    Caption = 'Delete &directories'
    Checked = True
    State = cbChecked
    TabOrder = 1
    OnClick = chbDelDirsClick
  end
  object chbDelFiles: TCheckBox
    Left = 123
    Top = 62
    Width = 105
    Height = 17
    Caption = 'Delete &files'
    Checked = True
    State = cbChecked
    TabOrder = 2
    OnClick = chbDelDirsClick
  end
  object chbCaseSensitive: TCheckBox
    Left = 234
    Top = 62
    Width = 105
    Height = 17
    Caption = 'Case &sensitive'
    TabOrder = 3
  end
  object pmMasks: TPopupMenu
    AutoHotkeys = maManual
    Left = 184
    Top = 64
  end
end
