inherited CnExploreFilterEditorForm: TCnExploreFilterEditorForm
  Left = 307
  Top = 279
  BorderStyle = bsDialog
  Caption = 'Add a Filter'
  ClientHeight = 96
  ClientWidth = 299
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 12
    Top = 12
    Width = 28
    Height = 13
    Caption = 'Type:'
  end
  object lbl2: TLabel
    Left = 12
    Top = 36
    Width = 20
    Height = 13
    Caption = 'Ext.'
  end
  object OKBtn: TButton
    Left = 135
    Top = 66
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object CancelBtn: TButton
    Left = 215
    Top = 66
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object edtType: TEdit
    Left = 64
    Top = 10
    Width = 225
    Height = 21
    TabOrder = 0
    Text = 'All Types'
  end
  object edtExtName: TEdit
    Left = 64
    Top = 34
    Width = 225
    Height = 21
    TabOrder = 1
    Text = '*.*'
  end
end
