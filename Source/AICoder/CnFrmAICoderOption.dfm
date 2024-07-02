inherited CnAICoderOptionFrame: TCnAICoderOptionFrame
  Width = 497
  Height = 239
  object lblURL: TLabel
    Left = 16
    Top = 24
    Width = 68
    Height = 13
    Caption = 'Request URL:'
  end
  object lblAPIKey: TLabel
    Left = 16
    Top = 88
    Width = 41
    Height = 13
    Caption = 'API Key:'
  end
  object lblModel: TLabel
    Left = 16
    Top = 56
    Width = 63
    Height = 13
    Caption = 'Model Name:'
  end
  object lblApply: TLabel
    Left = 392
    Top = 112
    Width = 82
    Height = 33
    Cursor = crHandPoint
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    AutoSize = False
    BiDiMode = bdLeftToRight
    Caption = 'Apply'
    ParentBiDiMode = False
    OnClick = lblApplyClick
  end
  object edtURL: TEdit
    Left = 120
    Top = 20
    Width = 353
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object edtAPIKey: TEdit
    Left = 120
    Top = 84
    Width = 353
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object cbbModel: TComboBox
    Left = 120
    Top = 52
    Width = 353
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
  end
end
