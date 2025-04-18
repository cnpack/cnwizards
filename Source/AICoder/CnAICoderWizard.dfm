object CnAICoderConfigForm: TCnAICoderConfigForm
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'AI Coder Settings'
  ClientHeight = 503
  ClientWidth = 857
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
  object lblTimeout: TLabel
    Left = 320
    Top = 16
    Width = 86
    Height = 13
    Caption = 'Timeout Seconds:'
  end
  object cbbActiveEngine: TComboBox
    Left = 128
    Top = 14
    Width = 177
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
    Width = 837
    Height = 403
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 4
  end
  object btnOK: TButton
    Left = 609
    Top = 471
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object btnCancel: TButton
    Left = 689
    Top = 471
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object btnHelp: TButton
    Left = 769
    Top = 471
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 7
    OnClick = btnHelpClick
  end
  object chkProxy: TCheckBox
    Left = 572
    Top = 16
    Width = 124
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Use Proxy:'
    TabOrder = 2
  end
  object edtProxy: TEdit
    Left = 703
    Top = 14
    Width = 142
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 3
  end
  object edtTimeout: TEdit
    Left = 424
    Top = 14
    Width = 33
    Height = 21
    TabOrder = 1
    Text = '0'
  end
  object udTimeout: TUpDown
    Left = 457
    Top = 14
    Width = 15
    Height = 21
    Associate = edtTimeout
    Min = 0
    Max = 60
    Position = 0
    TabOrder = 8
    Wrap = False
  end
end
