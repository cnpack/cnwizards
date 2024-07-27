object CnAICoderConfigForm: TCnAICoderConfigForm
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'AI Coder Settings'
  ClientHeight = 452
  ClientWidth = 715
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblActiveEngine: TLabel
    Left = 8
    Top = 16
    Width = 82
    Height = 13
    Caption = 'Active AI Engine:'
  end
  object cbbActiveEngine: TComboBox
    Left = 128
    Top = 14
    Width = 249
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbbActiveEngineChange
  end
  object pgcAI: TPageControl
    Left = 8
    Top = 56
    Width = 695
    Height = 352
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 467
    Top = 420
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 547
    Top = 420
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 627
    Top = 420
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object chkProxy: TCheckBox
    Left = 422
    Top = 16
    Width = 139
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Use Proxy:'
    TabOrder = 5
  end
  object edtProxy: TEdit
    Left = 566
    Top = 14
    Width = 137
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 6
  end
end
