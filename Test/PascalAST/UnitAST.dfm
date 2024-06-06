object FormAST: TFormAST
  Left = 37
  Top = 92
  Width = 1328
  Height = 716
  Caption = 'Pascal AST 32/64 Unicode/Non-Unicode'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 1305
    Height = 673
    ActivePage = tsPascalAst
    TabOrder = 0
    object tsPascalAst: TTabSheet
      Caption = 'Pascal Ast'
      object mmoPas: TMemo
        Left = 8
        Top = 8
        Width = 377
        Height = 113
        Lines.Strings = (
          'unit a;'
          ''
          'interface'
          ''
          'implementation'
          ''
          'end.')
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
        PopupMenu = pm1
        ReadOnly = True
        TabOrder = 1
        OnChange = tvPasChange
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
          Top = 178
          Width = 75
          Height = 25
          Caption = 'Type Decl'
          TabOrder = 3
          OnClick = btnTypeDeclClick
        end
        object btnSetElement: TButton
          Left = 16
          Top = 202
          Width = 75
          Height = 25
          Caption = 'Set Element'
          TabOrder = 4
          OnClick = btnSetElementClick
        end
        object btnSetConstructor: TButton
          Left = 16
          Top = 226
          Width = 75
          Height = 25
          Caption = 'Set Constructor'
          TabOrder = 5
          OnClick = btnSetConstructorClick
        end
        object btnFactor: TButton
          Left = 16
          Top = 250
          Width = 75
          Height = 25
          Caption = 'Factor'
          TabOrder = 6
          OnClick = btnFactorClick
        end
        object grpSimpleStatement: TGroupBox
          Left = 104
          Top = 24
          Width = 105
          Height = 185
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
            Top = 48
            Width = 75
            Height = 25
            Caption = 'Function Call'
            TabOrder = 1
            OnClick = btnFunctionCallClick
          end
          object btnGoto: TButton
            Left = 16
            Top = 72
            Width = 75
            Height = 25
            Caption = 'Goto'
            TabOrder = 2
            OnClick = btnGotoClick
          end
          object btnInherited: TButton
            Left = 16
            Top = 96
            Width = 75
            Height = 25
            Caption = 'inherited'
            TabOrder = 3
            OnClick = btnInheritedClick
          end
          object btnStringConvert: TButton
            Left = 16
            Top = 120
            Width = 75
            Height = 25
            Caption = 'String Convert'
            TabOrder = 4
            OnClick = btnStringConvertClick
          end
          object btnMessage: TButton
            Left = 16
            Top = 144
            Width = 75
            Height = 25
            Caption = 'Use Message'
            TabOrder = 5
            OnClick = btnMessageClick
          end
        end
        object grpType: TGroupBox
          Left = 232
          Top = 24
          Width = 185
          Height = 185
          Caption = 'Type'
          TabOrder = 10
          object btnRecordType: TButton
            Left = 96
            Top = 24
            Width = 75
            Height = 25
            Caption = 'Record'
            TabOrder = 6
            OnClick = btnRecordTypeClick
          end
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
            Top = 48
            Width = 75
            Height = 25
            Caption = 'Set'
            TabOrder = 1
            OnClick = btnSetTypeClick
          end
          object btnFileType: TButton
            Left = 16
            Top = 72
            Width = 75
            Height = 25
            Caption = 'File'
            TabOrder = 2
            OnClick = btnFileTypeClick
          end
          object btnPointerType: TButton
            Left = 16
            Top = 96
            Width = 75
            Height = 25
            Caption = 'Pointer'
            TabOrder = 3
            OnClick = btnPointerTypeClick
          end
          object btnStringType: TButton
            Left = 16
            Top = 120
            Width = 75
            Height = 25
            Caption = 'String'
            TabOrder = 4
            OnClick = btnStringTypeClick
          end
          object btnSubrangeType: TButton
            Left = 96
            Top = 48
            Width = 75
            Height = 25
            Caption = 'Subrange'
            TabOrder = 5
            OnClick = btnSubrangeTypeClick
          end
          object btnInterfaceType: TButton
            Left = 96
            Top = 72
            Width = 75
            Height = 25
            Caption = 'Interface'
            TabOrder = 7
            OnClick = btnInterfaceTypeClick
          end
          object btnClassType: TButton
            Left = 96
            Top = 96
            Width = 75
            Height = 25
            Caption = 'Class'
            TabOrder = 8
            OnClick = btnClassTypeClick
          end
          object btnTypeSection: TButton
            Left = 96
            Top = 120
            Width = 75
            Height = 25
            Caption = 'Type Section'
            TabOrder = 9
            OnClick = btnTypeSectionClick
          end
          object btnProcedureType: TButton
            Left = 16
            Top = 144
            Width = 75
            Height = 25
            Caption = 'Procedure'
            TabOrder = 10
            OnClick = btnProcedureTypeClick
          end
          object btnForward: TButton
            Left = 96
            Top = 144
            Width = 75
            Height = 25
            Caption = 'Forward'
            TabOrder = 11
            OnClick = btnForwardClick
          end
        end
        object grpClass: TGroupBox
          Left = 104
          Top = 216
          Width = 185
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
          object btnConstSection: TButton
            Left = 96
            Top = 24
            Width = 75
            Height = 25
            Caption = 'Const Section'
            TabOrder = 2
            OnClick = btnConstSectionClick
          end
          object btnVarSection: TButton
            Left = 96
            Top = 48
            Width = 75
            Height = 25
            Caption = 'Var Section'
            TabOrder = 1
            OnClick = btnVarSectionClick
          end
          object btnStrings: TButton
            Left = 16
            Top = 48
            Width = 75
            Height = 25
            Caption = 'Strings'
            TabOrder = 3
            OnClick = btnStringsClick
          end
        end
        object btnExports: TButton
          Left = 16
          Top = 96
          Width = 75
          Height = 25
          Caption = 'Exports'
          TabOrder = 12
          OnClick = btnExportsClick
        end
        object grpConst: TGroupBox
          Left = 304
          Top = 216
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
            Top = 48
            Width = 75
            Height = 25
            Caption = 'Array Const'
            TabOrder = 1
            OnClick = btnArrayConstClick
          end
          object btnRecordConst: TButton
            Left = 16
            Top = 72
            Width = 75
            Height = 25
            Caption = 'Record Const'
            TabOrder = 2
            OnClick = btnRecordConstClick
          end
          object btnConstExpression: TButton
            Left = 16
            Top = 96
            Width = 75
            Height = 25
            Caption = 'Expr Const'
            TabOrder = 3
            OnClick = btnConstExpressionClick
          end
          object btnRecordConst1: TButton
            Left = 16
            Top = 120
            Width = 75
            Height = 25
            Caption = 'Record Const2'
            TabOrder = 4
            OnClick = btnRecordConst1Click
          end
        end
        object btnTerm: TButton
          Left = 16
          Top = 274
          Width = 75
          Height = 25
          Caption = 'Term'
          TabOrder = 14
          OnClick = btnTermClick
        end
        object grpStructStatement: TGroupBox
          Left = 104
          Top = 328
          Width = 185
          Height = 185
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
            Left = 96
            Top = 24
            Width = 75
            Height = 25
            Caption = 'If'
            TabOrder = 1
            OnClick = btnIfClick
          end
          object btnWith: TButton
            Left = 16
            Top = 48
            Width = 75
            Height = 25
            Caption = 'With Do'
            TabOrder = 2
            OnClick = btnWithClick
          end
          object btnWhile: TButton
            Left = 96
            Top = 48
            Width = 75
            Height = 25
            Caption = 'While Do'
            TabOrder = 3
            OnClick = btnWhileClick
          end
          object btnRepeat: TButton
            Left = 16
            Top = 72
            Width = 75
            Height = 25
            Caption = 'Repeat Until'
            TabOrder = 4
            OnClick = btnRepeatClick
          end
          object btnTry: TButton
            Left = 96
            Top = 72
            Width = 75
            Height = 25
            Caption = 'Try'
            TabOrder = 5
            OnClick = btnTryClick
          end
          object btnFor: TButton
            Left = 16
            Top = 96
            Width = 75
            Height = 25
            Caption = 'For To/Downto'
            TabOrder = 6
            OnClick = btnForClick
          end
          object btnRaise: TButton
            Left = 96
            Top = 96
            Width = 75
            Height = 25
            Caption = 'Raise'
            TabOrder = 7
            OnClick = btnRaiseClick
          end
          object btnCase: TButton
            Left = 16
            Top = 120
            Width = 75
            Height = 25
            Caption = 'Case'
            TabOrder = 8
            OnClick = btnCaseClick
          end
          object btnCaseSelector: TButton
            Left = 96
            Top = 120
            Width = 75
            Height = 25
            Caption = 'Case Selector'
            TabOrder = 9
            OnClick = btnCaseSelectorClick
          end
          object btnLabel: TButton
            Left = 16
            Top = 144
            Width = 75
            Height = 25
            Caption = 'Label'
            TabOrder = 10
            OnClick = btnLabelClick
          end
          object btnAsm: TButton
            Left = 96
            Top = 144
            Width = 75
            Height = 25
            Caption = 'Asm'
            TabOrder = 11
            OnClick = btnAsmClick
          end
        end
        object btnInterface: TButton
          Left = 16
          Top = 120
          Width = 75
          Height = 25
          Caption = 'Interface'
          TabOrder = 16
          OnClick = btnInterfaceClick
        end
        object btnImplementation: TButton
          Left = 16
          Top = 144
          Width = 75
          Height = 25
          Caption = 'Implementation'
          TabOrder = 17
          OnClick = btnImplementationClick
        end
        object btnProgram: TButton
          Left = 16
          Top = 360
          Width = 75
          Height = 25
          Caption = 'Program'
          TabOrder = 18
          OnClick = btnProgramClick
        end
        object btnUnit: TButton
          Left = 16
          Top = 384
          Width = 75
          Height = 25
          Caption = 'Unit'
          TabOrder = 19
          OnClick = btnUnitClick
        end
        object btnOpen: TButton
          Left = 16
          Top = 560
          Width = 75
          Height = 25
          Caption = 'Open'
          TabOrder = 20
          OnClick = btnOpenClick
        end
        object grpDecls: TGroupBox
          Left = 304
          Top = 384
          Width = 113
          Height = 129
          Caption = 'Decls'
          TabOrder = 21
          object btnProcedure: TButton
            Left = 16
            Top = 24
            Width = 75
            Height = 25
            Caption = 'Procedure'
            TabOrder = 0
            OnClick = btnProcedureClick
          end
          object btnFunction: TButton
            Left = 16
            Top = 48
            Width = 75
            Height = 25
            Caption = 'Function'
            TabOrder = 1
            OnClick = btnFunctionClick
          end
          object btnAsmBlock: TButton
            Left = 16
            Top = 72
            Width = 75
            Height = 25
            Caption = 'Asm Block'
            TabOrder = 2
            OnClick = btnAsmBlockClick
          end
          object btnExternalFunction: TButton
            Left = 16
            Top = 96
            Width = 75
            Height = 25
            Caption = 'External Func'
            TabOrder = 3
            OnClick = btnExternalFunctionClick
          end
        end
        object btnDesignator: TButton
          Left = 16
          Top = 298
          Width = 75
          Height = 25
          Caption = 'Designator'
          TabOrder = 7
          OnClick = btnDesignatorClick
        end
        object btnExpressionList: TButton
          Left = 16
          Top = 322
          Width = 75
          Height = 25
          Caption = 'Expression List'
          TabOrder = 9
          OnClick = btnExpressionListClick
        end
        object btnParse: TButton
          Left = 16
          Top = 528
          Width = 75
          Height = 25
          Caption = 'Parse Memo'
          TabOrder = 22
          OnClick = btnParseClick
        end
        object stat1: TStatusBar
          Left = 2
          Top = 604
          Width = 469
          Height = 19
          Panels = <
            item
              Width = 100
            end
            item
              Width = 50
            end>
          SimplePanel = False
        end
        object mmoCppText: TMemo
          Left = 120
          Top = 528
          Width = 297
          Height = 57
          TabOrder = 24
        end
      end
      object pgcRes: TPageControl
        Left = 880
        Top = 8
        Width = 401
        Height = 625
        ActivePage = tsPascal
        Anchors = [akTop, akRight, akBottom]
        TabOrder = 3
        object tsPascal: TTabSheet
          Caption = 'Pascal'
          object mmoPasRes: TMemo
            Left = 0
            Top = 0
            Width = 393
            Height = 597
            Align = alClient
            ScrollBars = ssBoth
            TabOrder = 0
          end
        end
        object tsCpp: TTabSheet
          Caption = 'C++'
          ImageIndex = 1
          object mmoCppRes: TMemo
            Left = 0
            Top = 0
            Width = 393
            Height = 597
            Align = alClient
            ScrollBars = ssBoth
            TabOrder = 0
          end
        end
      end
    end
    object tsCppConvert: TTabSheet
      Caption = 'C/C++ Convert'
      ImageIndex = 1
      object grpElement: TGroupBox
        Left = 8
        Top = 8
        Width = 297
        Height = 393
        Caption = 'Element'
        TabOrder = 0
        object btnString: TButton
          Left = 16
          Top = 24
          Width = 75
          Height = 25
          Caption = 'String'
          TabOrder = 0
          OnClick = btnStringClick
        end
      end
    end
  end
  object dlgOpen1: TOpenDialog
    Filter = 'Pascal File|*.pas'
    Left = 536
    Top = 336
  end
  object pm1: TPopupMenu
    Left = 316
    Top = 464
    object ShowString1: TMenuItem
      Caption = 'Show String'
      OnClick = ShowString1Click
    end
  end
end
