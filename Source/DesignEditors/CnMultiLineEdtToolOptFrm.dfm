inherited CnMultiLineEditorToolsOptionForm: TCnMultiLineEditorToolsOptionForm
  Left = 364
  Top = 337
  BorderStyle = bsDialog
  Caption = '字符串编辑器辅助工具设置'
  ClientHeight = 218
  ClientWidth = 354
  OldCreateOrder = True
  Position = poScreenCenter
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
      Caption = '引用转换'
      object lbl1: TLabel
        Left = 16
        Top = 16
        Width = 132
        Height = 13
        Caption = '添加或删除引用的字符：'
      end
      object lbl2: TLabel
        Left = 16
        Top = 72
        Width = 144
        Height = 13
        Caption = '多行到单行的分隔字符串：'
      end
      object lbl9: TLabel
        Left = 16
        Top = 44
        Width = 144
        Height = 13
        Caption = '去除引用间的分隔字符串：'
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
      Caption = '块移动'
      ImageIndex = 3
      object lbl3: TLabel
        Left = 16
        Top = 16
        Width = 168
        Height = 13
        Caption = '移动块添加或删除的空格数目：'
      end
      object lbl4: TLabel
        Left = 34
        Top = 64
        Width = 144
        Height = 13
        Caption = '制表符替换为空格的数目：'
      end
      object chkMoveReplaceTab: TCheckBox
        Left = 16
        Top = 40
        Width = 297
        Height = 17
        Caption = '移动前替换制表符为空格'
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
      Caption = 'SQL语句格式化'
      ImageIndex = 2
      object grpSQLIndent: TGroupBox
        Left = 8
        Top = 68
        Width = 313
        Height = 73
        Caption = ' 缩进与换行 '
        TabOrder = 1
      end
      object grpSQLCase: TGroupBox
        Left = 8
        Top = 4
        Width = 313
        Height = 61
        Caption = ' 大小写 '
        TabOrder = 0
        object lbl5: TLabel
          Left = 16
          Top = 16
          Width = 48
          Height = 13
          Caption = '关键字：'
        end
        object lbl6: TLabel
          Left = 164
          Top = 16
          Width = 36
          Height = 13
          Caption = '函数：'
        end
        object lbl7: TLabel
          Left = 16
          Top = 40
          Width = 36
          Height = 13
          Caption = '表名：'
        end
        object lbl8: TLabel
          Left = 164
          Top = 40
          Width = 36
          Height = 13
          Caption = '列名：'
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
            '大写'
            '小写'
            '首字母大写'
            '不处理')
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
            '大写'
            '小写'
            '首字母大写'
            '不处理')
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
            '大写'
            '小写'
            '首字母大写'
            '不处理')
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
            '大写'
            '小写'
            '首字母大写'
            '不处理')
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
    Caption = '确定(&O)'
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
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
end
