inherited CnSrcEditorCodeWrapForm: TCnSrcEditorCodeWrapForm
  Left = 218
  Top = 62
  BorderStyle = bsDialog
  Caption = '代码嵌入设置'
  ClientHeight = 455
  ClientWidth = 440
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 425
    Height = 145
    Caption = '列表(&L)'
    TabOrder = 0
    object ListView: TListView
      Left = 8
      Top = 16
      Width = 329
      Height = 121
      Columns = <
        item
          Caption = '标题'
          Width = 125
        end
        item
          Caption = '快捷键'
          Width = 120
        end
        item
          Caption = '缩进'
          Width = 60
        end>
      HideSelection = False
      MultiSelect = True
      OwnerData = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnData = ListViewData
      OnKeyUp = ListViewKeyUp
      OnMouseUp = ListViewMouseUp
      OnSelectItem = ListViewSelectItem
    end
    object btnAdd: TButton
      Left = 344
      Top = 16
      Width = 73
      Height = 21
      Caption = '增加(&A)'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 344
      Top = 42
      Width = 73
      Height = 21
      Caption = '删除(&R)'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnImport: TButton
      Left = 344
      Top = 91
      Width = 73
      Height = 21
      Caption = '导入(&I)'
      TabOrder = 5
      OnClick = btnImportClick
    end
    object btnExport: TButton
      Left = 344
      Top = 116
      Width = 73
      Height = 21
      Caption = '导出(&X)'
      TabOrder = 6
      OnClick = btnExportClick
    end
    object btnUp: TButton
      Left = 344
      Top = 66
      Width = 34
      Height = 21
      Caption = '上(&U)'
      TabOrder = 3
      OnClick = btnUpClick
    end
    object btnDown: TButton
      Left = 383
      Top = 66
      Width = 34
      Height = 21
      Caption = '下(&D)'
      TabOrder = 4
      OnClick = btnDownClick
    end
  end
  object grp2: TGroupBox
    Left = 8
    Top = 160
    Width = 425
    Height = 257
    Caption = '代码嵌入项(&E)'
    TabOrder = 1
    object lbl1: TLabel
      Left = 8
      Top = 20
      Width = 28
      Height = 13
      Caption = '标题:'
    end
    object lbl4: TLabel
      Left = 8
      Top = 44
      Width = 40
      Height = 13
      Caption = '快捷键:'
    end
    object lbl2: TLabel
      Left = 8
      Top = 93
      Width = 28
      Height = 13
      Caption = '头部:'
    end
    object lbl5: TLabel
      Left = 8
      Top = 174
      Width = 28
      Height = 13
      Caption = '尾部:'
    end
    object lbl6: TLabel
      Left = 8
      Top = 70
      Width = 40
      Height = 13
      Caption = '代码块:'
    end
    object lbl7: TLabel
      Left = 216
      Top = 70
      Width = 100
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '块缩进级数:'
    end
    object lbl8: TLabel
      Left = 216
      Top = 150
      Width = 100
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '相对缩进级数:'
    end
    object lbl9: TLabel
      Left = 216
      Top = 231
      Width = 100
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '相对缩进级数:'
    end
    object edtCaption: TEdit
      Left = 56
      Top = 16
      Width = 361
      Height = 21
      TabOrder = 0
      OnChange = ControlChanged
    end
    object HotKey: THotKey
      Left = 56
      Top = 41
      Width = 361
      Height = 19
      HotKey = 0
      InvalidKeys = [hcNone, hcShift]
      Modifiers = []
      TabOrder = 1
      OnExit = ControlChanged
    end
    object chkLineBlock: TCheckBox
      Left = 56
      Top = 66
      Width = 153
      Height = 22
      Caption = '行块处理模式。'
      TabOrder = 2
      OnClick = ControlChanged
    end
    object mmoHead: TMemo
      Left = 56
      Top = 93
      Width = 361
      Height = 49
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 4
      OnExit = ControlChanged
    end
    object mmoTail: TMemo
      Left = 56
      Top = 174
      Width = 361
      Height = 49
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 7
      OnExit = ControlChanged
    end
    object seIndent: TCnSpinEdit
      Left = 320
      Top = 66
      Width = 97
      Height = 22
      MaxValue = 99
      MinValue = -99
      TabOrder = 3
      Value = 0
      OnChange = ControlChanged
    end
    object chkHeadIndent: TCheckBox
      Left = 56
      Top = 146
      Width = 153
      Height = 22
      Caption = '自动缩进。'
      TabOrder = 5
      OnClick = ControlChanged
    end
    object seHeadIndent: TCnSpinEdit
      Left = 320
      Top = 146
      Width = 97
      Height = 22
      MaxValue = 99
      MinValue = -99
      TabOrder = 6
      Value = 0
      OnChange = ControlChanged
    end
    object chkTailIndent: TCheckBox
      Left = 56
      Top = 227
      Width = 153
      Height = 22
      Caption = '自动缩进。'
      TabOrder = 8
      OnClick = ControlChanged
    end
    object seTailIndent: TCnSpinEdit
      Left = 320
      Top = 227
      Width = 97
      Height = 22
      MaxValue = 99
      MinValue = -99
      TabOrder = 9
      Value = 0
      OnChange = ControlChanged
    end
  end
  object btnHelp: TButton
    Left = 358
    Top = 426
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 198
    Top = 426
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 278
    Top = 426
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'xml'
    Filter = '代码嵌入设置文件(*.xml)|*.xml'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 408
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'xml'
    Filter = '代码嵌入设置文件(*.xml)|*.xml'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 40
    Top = 408
  end
end
