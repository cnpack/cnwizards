object CnAICoderConfigForm: TCnAICoderConfigForm
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'AI Coder Settings'
  ClientHeight = 541
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
    Left = 328
    Top = 16
    Width = 113
    Height = 13
    Caption = 'Timeout Seconds:'
  end
  object lblHisCount: TLabel
    Left = 624
    Top = 16
    Width = 161
    Height = 13
    Caption = 'Send History Count in Chat:'
  end
  object lblMaxFav: TLabel
    Left = 624
    Top = 40
    Width = 161
    Height = 13
    Caption = 'Max Favorite Count:'
  end
  object cbbActiveEngine: TComboBox
    Left = 112
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
    Top = 72
    Width = 837
    Height = 425
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 9
  end
  object btnOK: TButton
    Left = 609
    Top = 509
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 10
  end
  object btnCancel: TButton
    Left = 689
    Top = 509
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 11
  end
  object btnHelp: TButton
    Left = 769
    Top = 509
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 12
    OnClick = btnHelpClick
  end
  object chkProxy: TCheckBox
    Left = 310
    Top = 40
    Width = 139
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Use Proxy:'
    TabOrder = 8
  end
  object edtProxy: TEdit
    Left = 455
    Top = 38
    Width = 142
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 5
  end
  object edtTimeout: TEdit
    Left = 456
    Top = 14
    Width = 33
    Height = 21
    TabOrder = 1
    Text = '0'
  end
  object udTimeout: TUpDown
    Left = 489
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
    Left = 792
    Top = 14
    Width = 33
    Height = 21
    TabOrder = 3
    Text = '0'
  end
  object udHisCount: TUpDown
    Left = 825
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
    Left = 792
    Top = 38
    Width = 33
    Height = 21
    TabOrder = 6
    Text = '0'
  end
  object udMaxFav: TUpDown
    Left = 825
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
end
