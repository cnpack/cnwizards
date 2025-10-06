inherited CnCodeFormatterForm: TCnCodeFormatterForm
  Left = 359
  Top = 77
  BorderStyle = bsDialog
  Caption = 'Code Formatter Settings'
  ClientHeight = 548
  ClientWidth = 452
  Font.Charset = ANSI_CHARSET
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pgcFormatter: TPageControl
    Left = 8
    Top = 8
    Width = 434
    Height = 499
    ActivePage = tsPascal
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsPascal: TTabSheet
      Caption = 'Pascal'
      object grpCommon: TGroupBox
        Left = 8
        Top = 8
        Width = 410
        Height = 336
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Common Settings'
        TabOrder = 0
        object lblKeyword: TLabel
          Left = 16
          Top = 24
          Width = 46
          Height = 13
          Caption = 'Keyword:'
        end
        object lblBegin: TLabel
          Left = 16
          Top = 52
          Width = 57
          Height = 13
          Caption = 'Begin Style:'
        end
        object lblTab: TLabel
          Left = 16
          Top = 108
          Width = 57
          Height = 13
          Caption = 'Tab Indent:'
        end
        object lblSpaceBefore: TLabel
          Left = 16
          Top = 136
          Width = 115
          Height = 13
          Caption = 'Space Before Operator:'
        end
        object lblSpaceAfter: TLabel
          Left = 16
          Top = 164
          Width = 108
          Height = 13
          Caption = 'Space After Operator:'
        end
        object lblNewLine: TLabel
          Left = 232
          Top = 194
          Width = 68
          Height = 13
          Caption = 'when Exceed:'
        end
        object lblDirectiveMode: TLabel
          Left = 16
          Top = 302
          Width = 90
          Height = 13
          Caption = 'Compiler Directive:'
        end
        object lblElseAfterEnd: TLabel
          Left = 16
          Top = 80
          Width = 99
          Height = 13
          Caption = 'Else After End Style:'
        end
        object cbbKeywordStyle: TComboBox
          Left = 136
          Top = 22
          Width = 257
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            'Lower Case'
            'Upper Case'
            'Upper First Letter'
            'No Change')
        end
        object cbbBeginStyle: TComboBox
          Left = 136
          Top = 50
          Width = 257
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          Items.Strings = (
            'Next Line'
            'This Line')
        end
        object seTab: TCnSpinEdit
          Left = 296
          Top = 106
          Width = 97
          Height = 22
          MaxValue = 32
          MinValue = 0
          TabOrder = 3
          Value = 1
        end
        object seWrapLine: TCnSpinEdit
          Left = 144
          Top = 190
          Width = 81
          Height = 22
          MaxValue = 256
          MinValue = 16
          TabOrder = 6
          Value = 16
          OnChange = seWrapLineChange
        end
        object seSpaceBefore: TCnSpinEdit
          Left = 296
          Top = 134
          Width = 97
          Height = 22
          MaxValue = 32
          MinValue = 0
          TabOrder = 4
          Value = 1
        end
        object seSpaceAfter: TCnSpinEdit
          Left = 296
          Top = 162
          Width = 97
          Height = 22
          MaxValue = 32
          MinValue = 0
          TabOrder = 5
          Value = 1
        end
        object chkUsesSinglieLine: TCheckBox
          Left = 16
          Top = 220
          Width = 377
          Height = 17
          Caption = 'Single Line Mode for Every Uses Unit.'
          TabOrder = 9
        end
        object chkAutoWrap: TCheckBox
          Left = 16
          Top = 192
          Width = 121
          Height = 17
          Caption = 'Auto Wrap Line at:'
          TabOrder = 8
          OnClick = chkAutoWrapClick
        end
        object seNewLine: TCnSpinEdit
          Left = 312
          Top = 190
          Width = 81
          Height = 22
          MaxValue = 256
          MinValue = 16
          TabOrder = 7
          Value = 16
        end
        object chkUseIDESymbols: TCheckBox
          Left = 16
          Top = 272
          Width = 377
          Height = 17
          Caption = 'Use IDE Internal Symbols to Correct Identifiers.'
          TabOrder = 11
        end
        object cbbDirectiveMode: TComboBox
          Left = 136
          Top = 300
          Width = 257
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 12
          Items.Strings = (
            'Treat as Comment'
            'Only Processing First Branch')
        end
        object chkKeepUserLineBreak: TCheckBox
          Left = 16
          Top = 246
          Width = 377
          Height = 17
          Caption = 'Keep User Line Break in Statement.'
          TabOrder = 10
        end
        object cbbElseAfterEndStyle: TComboBox
          Left = 136
          Top = 78
          Width = 257
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 2
          Items.Strings = (
            'Next Line'
            'This Line')
        end
      end
      object grpAsm: TGroupBox
        Left = 8
        Top = 350
        Width = 410
        Height = 83
        Anchors = [akLeft, akTop, akRight]
        Caption = 'ASM Settings'
        TabOrder = 1
        object lblAsmHeadIndent: TLabel
          Left = 16
          Top = 24
          Width = 86
          Height = 13
          Caption = 'Line Head Indent:'
        end
        object lblASMTab: TLabel
          Left = 16
          Top = 48
          Width = 53
          Height = 13
          Caption = 'Tab Width:'
        end
        object seASMHeadIndent: TCnSpinEdit
          Left = 296
          Top = 19
          Width = 97
          Height = 22
          MaxValue = 32
          MinValue = 1
          TabOrder = 0
          Value = 1
        end
        object seAsmTab: TCnSpinEdit
          Left = 296
          Top = 47
          Width = 97
          Height = 22
          MaxValue = 32
          MinValue = 1
          TabOrder = 1
          Value = 16
        end
      end
      object chkIgnoreArea: TCheckBox
        Left = 8
        Top = 444
        Width = 281
        Height = 17
        Caption = 'Do NOT Format Contents between {(*} and {*)}'
        TabOrder = 2
      end
    end
  end
  object btnOK: TButton
    Left = 207
    Top = 517
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 287
    Top = 517
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 367
    Top = 517
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object btnShortCut: TButton
    Left = 8
    Top = 517
    Width = 75
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = '&Shortcut'
    TabOrder = 1
    OnClick = btnShortCutClick
  end
end
