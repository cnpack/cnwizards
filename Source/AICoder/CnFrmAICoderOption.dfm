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
    Left = 424
    Top = 112
    Width = 50
    Height = 13
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
    Left = 96
    Top = 20
    Width = 377
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object edtAPIKey: TEdit
    Left = 96
    Top = 84
    Width = 377
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object edtModel: TEdit
    Left = 96
    Top = 52
    Width = 377
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
end
