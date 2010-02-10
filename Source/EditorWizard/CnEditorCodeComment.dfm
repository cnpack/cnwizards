inherited CnEditorCodeCommentForm: TCnEditorCodeCommentForm
  Left = 412
  Top = 266
  BorderStyle = bsDialog
  Caption = 'Toggle Code Comment'
  ClientHeight = 93
  ClientWidth = 250
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 49
    Caption = '&Settings'
    TabOrder = 0
    object chkMoveToNextLine: TCheckBox
      Left = 8
      Top = 18
      Width = 217
      Height = 17
      Caption = 'Move to Next Line after Toggle'
      TabOrder = 0
    end
  end
  object btnOK: TButton
    Left = 86
    Top = 64
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 166
    Top = 64
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
