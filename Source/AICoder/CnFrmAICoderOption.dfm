object CnAICoderOptionFrame: TCnAICoderOptionFrame
  Left = 0
  Top = 0
  Width = 497
  Height = 239
  TabOrder = 0
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
    Left = 448
    Top = 112
    Width = 26
    Height = 13
    Cursor = crHandPoint
    Anchors = [akTop, akRight]
    Caption = 'Apply'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
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
