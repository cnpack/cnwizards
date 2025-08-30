inherited CnMultiLineEditorToolsOptionForm: TCnMultiLineEditorToolsOptionForm
  Left = 364
  Top = 337
  BorderStyle = bsDialog
  Caption = 'String Editor Tools Option'
  ClientHeight = 218
  ClientWidth = 354
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 337
    Height = 174
    ActivePage = tsQuoted
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsQuoted: TTabSheet
      Caption = 'Quoted Convert'
      object lbl1: TLabel
        Left = 16
        Top = 16
        Width = 187
        Height = 13
        Caption = 'Quoted Char for Add or Remove Block:'
      end
      object lbl2: TLabel
        Left = 16
        Top = 72
        Width = 179
        Height = 13
        Caption = 'Separator for MultiLine to Single Line:'
      end
      object lbl9: TLabel
        Left = 16
        Top = 44
        Width = 168
        Height = 13
        Caption = 'Separator of Extract Quoted Char:'
      end
      object edtQuotedChar: TEdit
        Left = 204
        Top = 12
        Width = 105
        Height = 21
        MaxLength = 1
        TabOrder = 0
        OnExit = edtQuotedCharExit
      end
      object edtLineSep: TEdit
        Left = 204
        Top = 68
        Width = 105
        Height = 21
        TabOrder = 2
      end
      object edtUnQuotedSep: TEdit
        Left = 204
        Top = 40
        Width = 105
        Height = 21
        MaxLength = 1
        TabOrder = 1
        OnExit = edtQuotedCharExit
      end
    end
    object tsLineMove: TTabSheet
      Caption = 'Block Move'
      ImageIndex = 3
      object lbl3: TLabel
        Left = 16
        Top = 16
        Width = 213
        Height = 13
        Caption = 'Spaces to Add or Remove when Move Block:'
      end
      object lbl4: TLabel
        Left = 34
        Top = 64
        Width = 63
        Height = 13
        Caption = 'Tab to Space'
      end
      object chkMoveReplaceTab: TCheckBox
        Left = 16
        Top = 40
        Width = 297
        Height = 17
        Caption = 'Replace Tab to Space before Move.'
        TabOrder = 1
        OnClick = chkMoveReplaceTabClick
      end
      object seMoveSpaces: TCnSpinEdit
        Left = 264
        Top = 11
        Width = 49
        Height = 21
        MaxLength = 2
        MaxValue = 64
        MinValue = 1
        TabOrder = 0
        Value = 2
      end
      object seTabAsSpaces: TCnSpinEdit
        Left = 264
        Top = 59
        Width = 49
        Height = 21
        MaxLength = 2
        MaxValue = 64
        MinValue = 1
        TabOrder = 2
        Value = 2
      end
    end
    object tsSQLFormatter: TTabSheet
      Caption = 'SQL Formatter'
      ImageIndex = 2
      object grpSQLIndent: TGroupBox
        Left = 8
        Top = 68
        Width = 313
        Height = 73
        Caption = 'Indent and Line Break'
        TabOrder = 1
      end
      object grpSQLCase: TGroupBox
        Left = 8
        Top = 4
        Width = 313
        Height = 61
        Caption = ' Case'
        TabOrder = 0
        object lbl5: TLabel
          Left = 16
          Top = 16
          Width = 46
          Height = 13
          Caption = 'Keyword:'
        end
        object lbl6: TLabel
          Left = 164
          Top = 16
          Width = 45
          Height = 13
          Caption = 'Function:'
        end
        object lbl7: TLabel
          Left = 16
          Top = 40
          Width = 60
          Height = 13
          Caption = 'Table Name:'
        end
        object lbl8: TLabel
          Left = 164
          Top = 40
          Width = 69
          Height = 13
          Caption = 'Column Name:'
        end
        object cbb1: TComboBox
          Left = 68
          Top = 12
          Width = 85
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            'Upper'
            'Lower'
            'First Upper'
            'Do Nothing')
        end
        object cbb2: TComboBox
          Left = 216
          Top = 12
          Width = 85
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          Items.Strings = (
            'Upper'
            'Lower'
            'First Upper'
            'Do Nothing')
        end
        object cbb3: TComboBox
          Left = 68
          Top = 36
          Width = 85
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 2
          Items.Strings = (
            'Upper'
            'Lower'
            'First Upper'
            'Do Nothing')
        end
        object cbb4: TComboBox
          Left = 216
          Top = 36
          Width = 85
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 3
          Items.Strings = (
            'Upper'
            'Lower'
            'First Upper'
            'Do Nothing')
        end
      end
    end
  end
  object btnOK: TButton
    Left = 187
    Top = 189
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 270
    Top = 189
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
