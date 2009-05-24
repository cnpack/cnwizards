inherited CnSrcEditorGroupReplaceForm: TCnSrcEditorGroupReplaceForm
  Left = 218
  Top = 62
  BorderStyle = bsDialog
  Caption = '组替换设置'
  ClientHeight = 460
  ClientWidth = 473
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 457
    Height = 145
    Caption = '列表(&L)'
    TabOrder = 0
    object ListView: TListView
      Left = 8
      Top = 16
      Width = 361
      Height = 121
      Columns = <
        item
          Caption = '标题'
          Width = 150
        end
        item
          Caption = '快捷键'
          Width = 130
        end
        item
          Caption = '替换项'
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
      Left = 376
      Top = 16
      Width = 73
      Height = 21
      Caption = '增加(&A)'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 376
      Top = 42
      Width = 73
      Height = 21
      Caption = '删除(&R)'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnImport: TButton
      Left = 376
      Top = 91
      Width = 73
      Height = 21
      Caption = '导入(&I)'
      TabOrder = 5
      OnClick = btnImportClick
    end
    object btnExport: TButton
      Left = 376
      Top = 116
      Width = 73
      Height = 21
      Caption = '导出(&X)'
      TabOrder = 6
      OnClick = btnExportClick
    end
    object btnUp: TButton
      Left = 376
      Top = 66
      Width = 34
      Height = 21
      Caption = '上(&U)'
      TabOrder = 3
      OnClick = btnUpClick
    end
    object btnDown: TButton
      Left = 415
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
    Width = 457
    Height = 265
    Caption = '组替换项(&E)'
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
      Top = 188
      Width = 40
      Height = 13
      Caption = '源文本:'
    end
    object lbl3: TLabel
      Left = 8
      Top = 214
      Width = 40
      Height = 13
      Caption = '替换为:'
    end
    object lbl5: TLabel
      Left = 8
      Top = 69
      Width = 40
      Height = 13
      Caption = '替换项:'
    end
    object edtCaption: TEdit
      Left = 56
      Top = 16
      Width = 393
      Height = 21
      TabOrder = 0
      OnChange = ControlChanged
    end
    object HotKey: THotKey
      Left = 56
      Top = 41
      Width = 393
      Height = 19
      HotKey = 0
      InvalidKeys = [hcNone, hcShift]
      Modifiers = []
      TabOrder = 1
      OnExit = ControlChanged
    end
    object lvItems: TListView
      Left = 56
      Top = 65
      Width = 313
      Height = 113
      Columns = <
        item
          Caption = '源文本'
          Width = 95
        end
        item
          Caption = '替换为'
          Width = 95
        end
        item
          Caption = '忽略大小写'
        end
        item
          Caption = '整词匹配'
        end>
      HideSelection = False
      MultiSelect = True
      OwnerData = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 2
      ViewStyle = vsReport
      OnData = lvItemsData
      OnKeyUp = lvItemsKeyUp
      OnMouseUp = lvItemsMouseUp
      OnSelectItem = lvItemsSelectItem
    end
    object btnItemAdd: TButton
      Left = 376
      Top = 65
      Width = 73
      Height = 21
      Caption = '增加(&A)'
      TabOrder = 3
      OnClick = btnItemAddClick
    end
    object btnItemDelete: TButton
      Left = 376
      Top = 91
      Width = 73
      Height = 21
      Caption = '删除(&R)'
      TabOrder = 4
      OnClick = btnItemDeleteClick
    end
    object btnItemUp: TButton
      Left = 376
      Top = 115
      Width = 34
      Height = 21
      Caption = '上(&U)'
      TabOrder = 5
      OnClick = btnItemUpClick
    end
    object btnItemDown: TButton
      Left = 415
      Top = 115
      Width = 34
      Height = 21
      Caption = '下(&D)'
      TabOrder = 6
      OnClick = btnItemDownClick
    end
    object edtSource: TEdit
      Left = 56
      Top = 184
      Width = 393
      Height = 21
      TabOrder = 7
      OnChange = ItemControlChanged
    end
    object edtDest: TEdit
      Left = 56
      Top = 210
      Width = 393
      Height = 21
      TabOrder = 8
      OnChange = ItemControlChanged
    end
    object chkIgnoreCase: TCheckBox
      Left = 56
      Top = 237
      Width = 161
      Height = 17
      Caption = '忽略大小写。'
      TabOrder = 9
      OnClick = ItemControlChanged
    end
    object chkWholeWord: TCheckBox
      Left = 248
      Top = 237
      Width = 161
      Height = 17
      Caption = '整词匹配。'
      TabOrder = 10
      OnClick = ItemControlChanged
    end
  end
  object btnHelp: TButton
    Left = 392
    Top = 432
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 232
    Top = 432
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 312
    Top = 432
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'xml'
    Filter = '组替换设置文件(*.xml)|*.xml'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 424
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'xml'
    Filter = '组替换设置文件(*.xml)|*.xml'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 40
    Top = 424
  end
end
