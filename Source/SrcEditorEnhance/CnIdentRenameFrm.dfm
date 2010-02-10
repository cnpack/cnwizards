inherited CnIdentRenameForm: TCnIdentRenameForm
  Left = 352
  Top = 202
  BorderStyle = bsDialog
  Caption = 'Rename Identifier'
  ClientHeight = 211
  ClientWidth = 242
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblReplacePromt: TLabel
    Left = 8
    Top = 16
    Width = 3
    Height = 13
  end
  object grpBrowse: TGroupBox
    Left = 8
    Top = 72
    Width = 225
    Height = 97
    Caption = 'Replace &Range'
    TabOrder = 1
    object rbCurrentProc: TRadioButton
      Left = 8
      Top = 20
      Width = 185
      Height = 17
      Caption = 'Current Procedure(&1)'
      TabOrder = 0
    end
    object rbCurrentInnerProc: TRadioButton
      Left = 8
      Top = 44
      Width = 185
      Height = 17
      Caption = 'Nested Inner Procedure(&2)'
      TabOrder = 1
    end
    object rbUnit: TRadioButton
      Left = 8
      Top = 68
      Width = 161
      Height = 17
      Caption = 'Whole Unit(&3)'
      TabOrder = 2
    end
  end
  object edtRename: TEdit
    Left = 8
    Top = 40
    Width = 225
    Height = 21
    TabOrder = 0
    OnKeyDown = edtRenameKeyDown
  end
  object btnOK: TButton
    Left = 78
    Top = 180
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 158
    Top = 180
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
