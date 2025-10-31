object CnAICoderConfigForm: TCnAICoderConfigForm
  Left = 203
  Top = 108
  BorderStyle = bsDialog
  Caption = 'AI Coder Settings'
  ClientHeight = 561
  ClientWidth = 957
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
    Left = 392
    Top = 16
    Width = 86
    Height = 13
    Caption = 'Timeout Seconds:'
  end
  object lblHisCount: TLabel
    Left = 728
    Top = 16
    Width = 130
    Height = 13
    Caption = 'Send History Count in Chat:'
  end
  object lblMaxFav: TLabel
    Left = 728
    Top = 40
    Width = 95
    Height = 13
    Caption = 'Max Favorite Count:'
  end
  object cbbActiveEngine: TComboBox
    Left = 112
    Top = 14
    Width = 250
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbbActiveEngineChange
  end
  object pgcAI: TPageControl
    Left = 8
    Top = 72
    Width = 937
    Height = 445
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 10
  end
  object btnOK: TButton
    Left = 709
    Top = 529
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 12
  end
  object btnCancel: TButton
    Left = 789
    Top = 529
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 13
  end
  object btnHelp: TButton
    Left = 869
    Top = 529
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 14
    OnClick = btnHelpClick
  end
  object chkProxy: TCheckBox
    Left = 374
    Top = 40
    Width = 139
    Height = 17
    Caption = 'Use Proxy:'
    TabOrder = 8
  end
  object edtProxy: TEdit
    Left = 520
    Top = 38
    Width = 142
    Height = 21
    TabOrder = 5
  end
  object edtTimeout: TEdit
    Left = 520
    Top = 14
    Width = 33
    Height = 21
    TabOrder = 1
    Text = '0'
  end
  object udTimeout: TUpDown
    Left = 553
    Top = 14
    Width = 15
    Height = 21
    Associate = edtTimeout
    Min = 0
    Max = 60
    Position = 0
    TabOrder = 2
    Wrap = False
  end
  object edtHisCount: TEdit
    Left = 896
    Top = 14
    Width = 33
    Height = 21
    TabOrder = 3
    Text = '0'
  end
  object udHisCount: TUpDown
    Left = 929
    Top = 14
    Width = 15
    Height = 21
    Associate = edtHisCount
    Min = 0
    Max = 60
    Position = 0
    TabOrder = 4
    Wrap = False
  end
  object edtMaxFav: TEdit
    Left = 896
    Top = 38
    Width = 33
    Height = 21
    TabOrder = 6
    Text = '0'
  end
  object udMaxFav: TUpDown
    Left = 929
    Top = 38
    Width = 15
    Height = 21
    Associate = edtMaxFav
    Min = 0
    Max = 10
    Position = 0
    TabOrder = 7
    Wrap = False
  end
  object chkAltEnterContCode: TCheckBox
    Left = 8
    Top = 40
    Width = 345
    Height = 17
    Caption = '(Ctrl +) Alt + Enter to Continue Coding in Editor'
    TabOrder = 9
  end
  object btnShortCut: TButton
    Left = 8
    Top = 529
    Width = 75
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = '&Shortcut'
    TabOrder = 11
    OnClick = btnShortCutClick
  end
end
