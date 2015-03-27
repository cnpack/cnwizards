inherited CnCodeFormatterForm: TCnCodeFormatterForm
  Left = 307
  Top = 98
  BorderStyle = bsDialog
  Caption = 'Code Formatter Settings'
  ClientHeight = 464
  ClientWidth = 379
  Font.Charset = ANSI_CHARSET
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pgcFormatter: TPageControl
    Left = 8
    Top = 8
    Width = 361
    Height = 409
    ActivePage = tsPascal
    TabOrder = 0
    object tsPascal: TTabSheet
      Caption = 'Pascal'
      object grpCommon: TGroupBox
        Left = 8
        Top = 8
        Width = 337
        Height = 235
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
          Top = 54
          Width = 57
          Height = 13
          Caption = 'Begin Style:'
        end
        object lblTab: TLabel
          Left = 16
          Top = 84
          Width = 57
          Height = 13
          Caption = 'Tab Indent:'
        end
        object lblSpaceBefore: TLabel
          Left = 16
          Top = 114
          Width = 115
          Height = 13
          Caption = 'Space Before Operator:'
        end
        object lblSpaceAfter: TLabel
          Left = 16
          Top = 144
          Width = 108
          Height = 13
          Caption = 'Space After Operator:'
        end
        object cbbKeywordStyle: TComboBox
          Left = 136
          Top = 22
          Width = 185
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
          Top = 52
          Width = 185
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          Items.Strings = (
            'Next Line'
            'This Line')
        end
        object seTab: TCnSpinEdit
          Left = 224
          Top = 82
          Width = 97
          Height = 22
          MaxValue = 32
          MinValue = 1
          TabOrder = 2
          Value = 1
        end
        object seWrapLine: TCnSpinEdit
          Left = 224
          Top = 172
          Width = 97
          Height = 22
          MaxValue = 256
          MinValue = 16
          TabOrder = 5
          Value = 16
        end
        object seSpaceBefore: TCnSpinEdit
          Left = 224
          Top = 112
          Width = 97
          Height = 22
          MaxValue = 32
          MinValue = 1
          TabOrder = 3
          Value = 1
        end
        object seSpaceAfter: TCnSpinEdit
          Left = 224
          Top = 142
          Width = 97
          Height = 22
          MaxValue = 32
          MinValue = 1
          TabOrder = 4
          Value = 1
        end
        object chkUsesSinglieLine: TCheckBox
          Left = 16
          Top = 204
          Width = 249
          Height = 17
          Caption = 'Single Line Mode for Every Uses Unit.'
          TabOrder = 7
        end
        object chkAutoWrap: TCheckBox
          Left = 16
          Top = 174
          Width = 177
          Height = 17
          Caption = 'Auto Wrap Line Width:'
          TabOrder = 6
          OnClick = chkAutoWrapClick
        end
      end
      object grpAsm: TGroupBox
        Left = 8
        Top = 256
        Width = 337
        Height = 85
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
          Top = 50
          Width = 53
          Height = 13
          Caption = 'Tab Width:'
        end
        object seASMHeadIndent: TCnSpinEdit
          Left = 224
          Top = 19
          Width = 97
          Height = 22
          MaxValue = 32
          MinValue = 1
          TabOrder = 0
          Value = 1
        end
        object seAsmTab: TCnSpinEdit
          Left = 224
          Top = 49
          Width = 97
          Height = 22
          MaxValue = 32
          MinValue = 6
          TabOrder = 1
          Value = 16
        end
      end
      object chkIgnoreArea: TCheckBox
        Left = 8
        Top = 352
        Width = 281
        Height = 17
        Caption = 'Do NOT Format Contents between {(*} and {*)}'
        TabOrder = 2
      end
    end
  end
  object btnOK: TButton
    Left = 134
    Top = 429
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 214
    Top = 429
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 294
    Top = 429
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
  end
end
