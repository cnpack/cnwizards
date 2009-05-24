inherited CnSrcEditorWebSearchForm: TCnSrcEditorWebSearchForm
  Left = 256
  Top = 156
  BorderStyle = bsDialog
  Caption = '搜索设置'
  ClientHeight = 301
  ClientWidth = 457
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 441
    Height = 257
    Caption = '列表(&L)'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 176
      Width = 28
      Height = 13
      Caption = '标题:'
    end
    object lbl2: TLabel
      Left = 192
      Top = 176
      Width = 40
      Height = 13
      Caption = '快捷键:'
    end
    object lbl3: TLabel
      Left = 8
      Top = 203
      Width = 309
      Height = 13
      Caption = '搜索链接(可执行文件或 http 链接，%s 表示当前选择内容):'
    end
    object ListView: TListView
      Left = 8
      Top = 16
      Width = 361
      Height = 145
      Columns = <
        item
          Caption = '标题'
          Width = 80
        end
        item
          Caption = '快捷键'
          Width = 80
        end
        item
          Caption = '搜索链接'
          Width = 180
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
      Width = 57
      Height = 21
      Caption = '增加(&A)'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 376
      Top = 41
      Width = 57
      Height = 21
      Caption = '删除(&R)'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnUp: TButton
      Left = 376
      Top = 66
      Width = 57
      Height = 21
      Caption = '上移(&U)'
      TabOrder = 3
      OnClick = btnUpClick
    end
    object btnDown: TButton
      Left = 375
      Top = 90
      Width = 57
      Height = 21
      Caption = '下移(&D)'
      TabOrder = 4
      OnClick = btnDownClick
    end
    object edtCaption: TEdit
      Left = 48
      Top = 172
      Width = 137
      Height = 21
      TabOrder = 7
      OnChange = ControlChanged
    end
    object HotKey: THotKey
      Left = 248
      Top = 173
      Width = 121
      Height = 19
      HotKey = 0
      InvalidKeys = [hcNone, hcShift]
      Modifiers = []
      TabOrder = 8
      OnExit = ControlChanged
    end
    object edtUrl: TEdit
      Left = 8
      Top = 224
      Width = 361
      Height = 21
      TabOrder = 9
      OnChange = ControlChanged
    end
    object btnImport: TButton
      Left = 376
      Top = 115
      Width = 57
      Height = 21
      Caption = '导入(&I)'
      TabOrder = 5
      OnClick = btnImportClick
    end
    object btnExport: TButton
      Left = 376
      Top = 140
      Width = 57
      Height = 21
      Caption = '导出(&X)'
      TabOrder = 6
      OnClick = btnExportClick
    end
  end
  object btnOK: TButton
    Left = 216
    Top = 273
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 296
    Top = 273
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 376
    Top = 273
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'xml'
    Filter = 'Web 搜索设置文件(*.xml)|*.xml'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 272
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'xml'
    Filter = 'Web 搜索设置文件(*.xml)|*.xml'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 40
    Top = 272
  end
end
