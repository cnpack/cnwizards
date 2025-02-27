inherited CnAICoderOptionFrame: TCnAICoderOptionFrame
  Width = 619
  Height = 268
  object lblURL: TLabel
    Left = 16
    Top = 24
    Width = 68
    Height = 13
    Caption = 'Request URL:'
  end
  object lblAPIKey: TLabel
    Left = 16
    Top = 120
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
    Left = 518
    Top = 144
    Width = 82
    Height = 33
    Cursor = crHandPoint
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    AutoSize = False
    BiDiMode = bdLeftToRight
    Caption = 'Apply'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentBiDiMode = False
    ParentFont = False
    OnClick = lblApplyClick
  end
  object lblTemperature: TLabel
    Left = 16
    Top = 88
    Width = 63
    Height = 13
    Caption = 'Temperature:'
  end
  object edtURL: TEdit
    Left = 120
    Top = 20
    Width = 480
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object edtAPIKey: TEdit
    Left = 120
    Top = 116
    Width = 480
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
  end
  object cbbModel: TComboBox
    Left = 120
    Top = 52
    Width = 480
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
  end
  object edtTemperature: TEdit
    Left = 120
    Top = 84
    Width = 480
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object chkStreamMode: TCheckBox
    Left = 120
    Top = 148
    Width = 97
    Height = 17
    Caption = 'Stream Mode'
    TabOrder = 4
  end
end
