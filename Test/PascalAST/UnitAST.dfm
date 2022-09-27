object FormAST: TFormAST
  Left = 192
  Top = 107
  Width = 887
  Height = 672
  Caption = 'Pascal AST'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object mmoPas: TMemo
    Left = 8
    Top = 8
    Width = 377
    Height = 113
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object tvPas: TTreeView
    Left = 8
    Top = 128
    Width = 377
    Height = 505
    Indent = 19
    ReadOnly = True
    TabOrder = 1
  end
  object grpTest: TGroupBox
    Left = 392
    Top = 8
    Width = 473
    Height = 625
    Caption = 'Test Part'
    TabOrder = 2
    object btnUsesClause: TButton
      Left = 16
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Uses Clause'
      TabOrder = 0
      OnClick = btnUsesClauseClick
    end
    object btnUsesDecl: TButton
      Left = 16
      Top = 54
      Width = 75
      Height = 25
      Caption = 'Uses Decl'
      TabOrder = 1
      OnClick = btnUsesDeclClick
    end
    object btnTypeSeletion: TButton
      Left = 16
      Top = 84
      Width = 75
      Height = 25
      Caption = 'Type Seletion'
      TabOrder = 2
    end
    object btnTypeDecl: TButton
      Left = 16
      Top = 114
      Width = 75
      Height = 25
      Caption = 'Type Decl'
      TabOrder = 3
      OnClick = btnTypeDeclClick
    end
    object btnSetElement: TButton
      Left = 16
      Top = 144
      Width = 75
      Height = 25
      Caption = 'Set Element'
      TabOrder = 4
      OnClick = btnSetElementClick
    end
    object btnSetConstructor: TButton
      Left = 16
      Top = 174
      Width = 75
      Height = 25
      Caption = 'Set Constructor'
      TabOrder = 5
      OnClick = btnSetConstructorClick
    end
    object btnFactor: TButton
      Left = 16
      Top = 204
      Width = 75
      Height = 25
      Caption = 'Factor'
      TabOrder = 6
      OnClick = btnFactorClick
    end
    object btnDesignator: TButton
      Left = 16
      Top = 232
      Width = 75
      Height = 25
      Caption = 'Designator'
      TabOrder = 7
      OnClick = btnDesignatorClick
    end
    object grpSimpleStatement: TGroupBox
      Left = 104
      Top = 24
      Width = 113
      Height = 209
      Caption = 'Simple Statement'
      TabOrder = 8
      object btnAssign: TButton
        Left = 16
        Top = 24
        Width = 75
        Height = 25
        Caption = 'Assign'
        TabOrder = 0
        OnClick = btnAssignClick
      end
      object btnFunctionCall: TButton
        Left = 16
        Top = 56
        Width = 75
        Height = 25
        Caption = 'Function Call'
        TabOrder = 1
        OnClick = btnFunctionCallClick
      end
      object btnGoto: TButton
        Left = 16
        Top = 88
        Width = 75
        Height = 25
        Caption = 'Goto'
        TabOrder = 2
      end
      object btnInherited: TButton
        Left = 16
        Top = 120
        Width = 75
        Height = 25
        Caption = 'inherited'
        TabOrder = 3
      end
    end
    object btnExpressionList: TButton
      Left = 16
      Top = 260
      Width = 75
      Height = 25
      Caption = 'Expression List'
      TabOrder = 9
      OnClick = btnExpressionListClick
    end
    object grpType: TGroupBox
      Left = 232
      Top = 24
      Width = 185
      Height = 225
      Caption = 'Type'
      TabOrder = 10
      object btnArrayType: TButton
        Left = 16
        Top = 24
        Width = 75
        Height = 25
        Caption = 'Array'
        TabOrder = 0
        OnClick = btnArrayTypeClick
      end
      object btnSetType: TButton
        Left = 16
        Top = 56
        Width = 75
        Height = 25
        Caption = 'Set'
        TabOrder = 1
        OnClick = btnSetTypeClick
      end
      object btnFileType: TButton
        Left = 16
        Top = 88
        Width = 75
        Height = 25
        Caption = 'File'
        TabOrder = 2
        OnClick = btnFileTypeClick
      end
      object btnPointerType: TButton
        Left = 16
        Top = 120
        Width = 75
        Height = 25
        Caption = 'Pointer'
        TabOrder = 3
        OnClick = btnPointerTypeClick
      end
      object btnStringType: TButton
        Left = 16
        Top = 152
        Width = 75
        Height = 25
        Caption = 'String'
        TabOrder = 4
        OnClick = btnStringTypeClick
      end
      object btnSubrangeType: TButton
        Left = 16
        Top = 184
        Width = 75
        Height = 25
        Caption = 'Subrange'
        TabOrder = 5
        OnClick = btnSubrangeTypeClick
      end
      object btnRecordType: TButton
        Left = 96
        Top = 24
        Width = 75
        Height = 25
        Caption = 'Record'
        TabOrder = 6
        OnClick = btnRecordTypeClick
      end
      object btnPropety: TButton
        Left = 96
        Top = 56
        Width = 75
        Height = 25
        Caption = 'Property'
        TabOrder = 7
        OnClick = btnPropetyClick
      end
    end
  end
end
