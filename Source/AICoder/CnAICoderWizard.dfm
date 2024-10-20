object CnAICoderConfigForm: TCnAICoderConfigForm
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'AI Coder Settings'
  ClientHeight = 481
  ClientWidth = 786
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
    Width = 257
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
    Width = 766
    Height = 381
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 538
    Top = 449
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 618
    Top = 449
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 698
    Top = 449
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object chkProxy: TCheckBox
    Left = 485
    Top = 16
    Width = 140
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Use Proxy:'
    TabOrder = 5
  end
  object edtProxy: TEdit
    Left = 632
    Top = 14
    Width = 142
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 6
  end
end
