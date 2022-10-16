object FormAST: TFormAST
  Left = 226
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
    Anchors = [akLeft, akTop, akBottom]
    Indent = 19
    ReadOnly = True
    TabOrder = 1
  end
  object grpTest: TGroupBox
    Left = 392
    Top = 8
    Width = 473
    Height = 625
    Anchors = [akLeft, akTop, akBottom]
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
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Uses Decl'
      TabOrder = 1
      OnClick = btnUsesDeclClick
    end
    object btnInitSeletion: TButton
      Left = 16
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Init Seletion'
      TabOrder = 2
      OnClick = btnInitSeletionClick
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
      Top = 264
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
      Height = 193
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
      Top = 292
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
      Height = 193
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
        Left = 96
        Top = 56
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
      object btnInterfaceType: TButton
        Left = 96
        Top = 88
        Width = 75
        Height = 25
        Caption = 'Interface'
        TabOrder = 7
        OnClick = btnInterfaceTypeClick
      end
      object btnClassType: TButton
        Left = 96
        Top = 120
        Width = 75
        Height = 25
        Caption = 'Class'
        TabOrder = 8
        OnClick = btnClassTypeClick
      end
      object btnTypeSection: TButton
        Left = 96
        Top = 152
        Width = 75
        Height = 25
        Caption = 'Type Section'
        TabOrder = 9
        OnClick = btnTypeSectionClick
      end
    end
    object grpClass: TGroupBox
      Left = 104
      Top = 232
      Width = 217
      Height = 105
      Caption = 'Class'
      TabOrder = 11
      object btnPropety: TButton
        Left = 16
        Top = 24
        Width = 75
        Height = 25
        Caption = 'Property'
        TabOrder = 0
        OnClick = btnPropetyClick
      end
      object btnVarSection: TButton
        Left = 112
        Top = 56
        Width = 75
        Height = 25
        Caption = 'Var Section'
        TabOrder = 1
        OnClick = btnVarSectionClick
      end
      object btnConstSection: TButton
        Left = 112
        Top = 24
        Width = 75
        Height = 25
        Caption = 'Const Section'
        TabOrder = 2
        OnClick = btnConstSectionClick
      end
    end
    object btnExports: TButton
      Left = 16
      Top = 344
      Width = 75
      Height = 25
      Caption = 'Exports'
      TabOrder = 12
      OnClick = btnExportsClick
    end
    object grpConst: TGroupBox
      Left = 336
      Top = 232
      Width = 113
      Height = 161
      Caption = 'Const'
      TabOrder = 13
      object btnConst: TButton
        Left = 16
        Top = 24
        Width = 75
        Height = 25
        Caption = 'Set Const'
        TabOrder = 0
        OnClick = btnConstClick
      end
      object btnArrayConst: TButton
        Left = 16
        Top = 56
        Width = 75
        Height = 25
        Caption = 'Array Const'
        TabOrder = 1
        OnClick = btnArrayConstClick
      end
      object btnRecordConst: TButton
        Left = 16
        Top = 88
        Width = 75
        Height = 25
        Caption = 'Record Const'
        TabOrder = 2
        OnClick = btnRecordConstClick
      end
      object btnConstExpression: TButton
        Left = 16
        Top = 120
        Width = 75
        Height = 25
        Caption = 'Expr Const'
        TabOrder = 3
        OnClick = btnConstExpressionClick
      end
    end
    object btnTerm: TButton
      Left = 16
      Top = 234
      Width = 75
      Height = 25
      Caption = 'Term'
      TabOrder = 14
      OnClick = btnTermClick
    end
    object grpStructStatement: TGroupBox
      Left = 104
      Top = 352
      Width = 217
      Height = 233
      Caption = 'Struct Statement'
      TabOrder = 15
      object btnExceptionHandler: TButton
        Left = 16
        Top = 24
        Width = 75
        Height = 25
        Caption = 'Except Handler'
        TabOrder = 0
        OnClick = btnExceptionHandlerClick
      end
      object btnIf: TButton
        Left = 112
        Top = 24
        Width = 75
        Height = 25
        Caption = 'If'
        TabOrder = 1
        OnClick = btnIfClick
      end
      object btnWith: TButton
        Left = 16
        Top = 56
        Width = 75
        Height = 25
        Caption = 'With Do'
        TabOrder = 2
      end
      object btnWhile: TButton
        Left = 112
        Top = 56
        Width = 75
        Height = 25
        Caption = 'While Do'
        TabOrder = 3
      end
      object btnRepeat: TButton
        Left = 16
        Top = 88
        Width = 75
        Height = 25
        Caption = 'Repeat Until'
        TabOrder = 4
      end
      object btnTry: TButton
        Left = 112
        Top = 88
        Width = 75
        Height = 25
        Caption = 'Try'
        TabOrder = 5
      end
      object btnFor: TButton
        Left = 16
        Top = 120
        Width = 75
        Height = 25
        Caption = 'For To/Downto'
        TabOrder = 6
      end
      object btnRaise: TButton
        Left = 112
        Top = 120
        Width = 75
        Height = 25
        Caption = 'Raise'
        TabOrder = 7
      end
      object btnCase: TButton
        Left = 16
        Top = 152
        Width = 75
        Height = 25
        Caption = 'Case'
        TabOrder = 8
      end
      object btnCaseSelector: TButton
        Left = 112
        Top = 152
        Width = 75
        Height = 25
        Caption = 'Case Selector'
        TabOrder = 9
      end
      object btnLabel: TButton
        Left = 16
        Top = 184
        Width = 75
        Height = 25
        Caption = 'Label'
        TabOrder = 10
      end
    end
    object btnInterface: TButton
      Left = 16
      Top = 368
      Width = 75
      Height = 25
      Caption = 'Interface'
      TabOrder = 16
    end
    object btnImplementation: TButton
      Left = 16
      Top = 392
      Width = 75
      Height = 25
      Caption = 'Implementation'
      TabOrder = 17
    end
  end
end
