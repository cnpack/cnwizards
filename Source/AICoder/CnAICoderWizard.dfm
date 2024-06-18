object CnAICoderConfigForm: TCnAICoderConfigForm
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'AI Coder Settings'
  ClientHeight = 413
  ClientWidth = 621
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
    Left = 104
    Top = 14
    Width = 241
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbbActiveEngineChange
  end
  object pgcAI: TPageControl
    Left = 8
    Top = 56
    Width = 601
    Height = 313
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 373
    Top = 381
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 453
    Top = 381
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 533
    Top = 381
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 4
  end
  object chkProxy: TCheckBox
    Left = 384
    Top = 16
    Width = 89
    Height = 17
    Caption = 'Use Proxy:'
    TabOrder = 5
  end
  object edtProxy: TEdit
    Left = 472
    Top = 14
    Width = 137
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 6
  end
end
