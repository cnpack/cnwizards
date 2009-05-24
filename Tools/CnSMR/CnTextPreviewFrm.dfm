object CnTextPreviewForm: TCnTextPreviewForm
  Left = 363
  Top = 196
  BorderStyle = bsDialog
  Caption = 'Preview'
  ClientHeight = 286
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 262
    Top = 253
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 343
    Top = 253
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object lsbPreview: TListBox
    Left = 8
    Top = 8
    Width = 410
    Height = 239
    ItemHeight = 13
    MultiSelect = True
    TabOrder = 0
    OnClick = lsbPreviewClick
    OnKeyDown = lsbPreviewKeyDown
    OnKeyUp = lsbPreviewKeyUp
  end
  object btnDelete: TButton
    Left = 8
    Top = 253
    Width = 75
    Height = 25
    Caption = '&Delete'
    Enabled = False
    TabOrder = 1
    Visible = False
    OnClick = btnDeleteClick
  end
  object sd: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text file(*.txt)|*.txt|All files(*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Selection As'
    Left = 204
    Top = 144
  end
end
