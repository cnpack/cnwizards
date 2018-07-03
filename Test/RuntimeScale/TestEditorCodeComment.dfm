object EditorCodeCommentForm: TEditorCodeCommentForm
  Left = 469
  Top = 194
  BorderStyle = bsDialog
  Caption = 'Toggle Code Comment'
  ClientHeight = 209
  ClientWidth = 250
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 52
    Anchors = [akLeft, akTop, akRight, akBottom]
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
    Top = 180
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 166
    Top = 180
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object rgIndentMode: TRadioGroup
    Left = 8
    Top = 72
    Width = 233
    Height = 97
    Caption = 'Comment &Mode'
    Items.Strings = (
      'Insert // to Line &Head'
      'Insert // to &Non-Space Line Head'
      '&Replace Space at Line Head using //')
    TabOrder = 3
  end
end
