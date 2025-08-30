inherited CnPropEditorCustomizeForm: TCnPropEditorCustomizeForm
  Left = 384
  Top = 202
  BorderStyle = bsDialog
  Caption = 'Customize Property Editor'
  ClientHeight = 269
  ClientWidth = 361
  KeyPreview = True
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 345
    Height = 225
    Caption = 'Customize &Property'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 16
      Width = 282
      Height = 13
      Caption = 'Property List to Register, (Format "ClassName.PropName")'
    end
    object mmoProp: TMemo
      Left = 8
      Top = 32
      Width = 329
      Height = 185
      TabOrder = 0
    end
  end
  object btnOK: TButton
    Left = 118
    Top = 240
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 198
    Top = 240
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 279
    Top = 240
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
