object CnPrefixConfigForm: TCnPrefixConfigForm
  Left = 303
  Top = 149
  BorderStyle = bsDialog
  Caption = '组件前缀专家设置'
  ClientHeight = 485
  ClientWidth = 416
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp_Config: TGroupBox
    Left = 8
    Top = 8
    Width = 401
    Height = 217
    Caption = '显示设置(&D)'
    TabOrder = 0
    object cbAutoPopSuggestDlg: TCheckBox
      Left = 24
      Top = 34
      Width = 370
      Height = 17
      Caption = '新增组件或修改组件名称时弹出对话框。'
      TabOrder = 1
    end
    object cbPopPrefixDefine: TCheckBox
      Left = 24
      Top = 51
      Width = 370
      Height = 17
      Caption = '提示输入未定义前缀的组件前缀名。'
      TabOrder = 2
    end
    object cbAllowClassName: TCheckBox
      Left = 24
      Top = 68
      Width = 370
      Height = 17
      Caption = '忽略使用组件类名命名的组件。'
      TabOrder = 3
    end
    object cbAutoPrefix: TCheckBox
      Left = 8
      Top = 16
      Width = 385
      Height = 17
      Caption = '允许自动修改组件前缀'
      TabOrder = 0
      OnClick = cbAutoPrefixClick
    end
    object cbDelOldPrefix: TCheckBox
      Left = 24
      Top = 86
      Width = 370
      Height = 17
      Caption = '自动更名时替换原组件前缀。'
      TabOrder = 4
    end
    object cbUseUnderLine: TCheckBox
      Left = 24
      Top = 104
      Width = 370
      Height = 17
      Caption = '初次更名时在组件名称前缀后添加下划线。'
      TabOrder = 5
    end
    object cbPrefixCaseSens: TCheckBox
      Left = 24
      Top = 121
      Width = 370
      Height = 17
      Caption = '前缀区分大小写。'
      TabOrder = 6
    end
    object chkUseActionName: TCheckBox
      Left = 24
      Top = 138
      Width = 370
      Height = 17
      Caption = '重命名组件时允许参照关联的 Action 的名称。'
      TabOrder = 7
      OnClick = cbAutoPrefixClick
    end
    object chkWatchActionLink: TCheckBox
      Left = 40
      Top = 156
      Width = 353
      Height = 17
      Caption = '当组件关联 Action 时自动重命名。'
      TabOrder = 8
    end
    object chkUseFieldName: TCheckBox
      Left = 23
      Top = 174
      Width = 370
      Height = 17
      Caption = '重命名组件时允许参照 DataField 属性的内容。'
      TabOrder = 9
      OnClick = cbAutoPrefixClick
    end
    object chkWatchFieldLink: TCheckBox
      Left = 40
      Top = 191
      Width = 353
      Height = 17
      Caption = '当组件的 DataField 属性变更时自动重命名。'
      TabOrder = 10
    end
  end
  object gbList: TGroupBox
    Left = 8
    Top = 232
    Width = 401
    Height = 217
    Caption = '组件前缀设置(&P)'
    TabOrder = 1
    object lbl1: TLabel
      Left = 8
      Top = 24
      Width = 28
      Height = 13
      Caption = '前缀:'
    end
    object lbl2: TLabel
      Left = 8
      Top = 198
      Width = 184
      Height = 13
      Caption = '注:未选中检查框的组件将被忽略。'
    end
    object ListView: TListView
      Left = 8
      Top = 48
      Width = 385
      Height = 145
      Checkboxes = True
      Columns = <
        item
          Caption = '组件类名'
          Width = 240
        end
        item
          Caption = '组件前缀'
          Width = 120
        end>
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 4
      ViewStyle = vsReport
      OnChange = ListViewChange
      OnClick = ListViewClick
      OnColumnClick = ListViewColumnClick
      OnCompare = ListViewCompare
    end
    object edtPrefix: TEdit
      Left = 56
      Top = 20
      Width = 105
      Height = 21
      TabOrder = 0
      OnKeyPress = edtPrefixKeyPress
    end
    object btnModify: TButton
      Left = 168
      Top = 20
      Width = 49
      Height = 21
      Caption = '修改(&M)'
      TabOrder = 1
      OnClick = btnModifyClick
    end
    object btnImport: TButton
      Left = 232
      Top = 20
      Width = 75
      Height = 21
      Caption = '导入(&C)'
      TabOrder = 2
      OnClick = btnImportClick
    end
    object btnExport: TButton
      Left = 312
      Top = 20
      Width = 75
      Height = 21
      Caption = '导出(&H)'
      TabOrder = 3
      OnClick = btnExportClick
    end
  end
  object btnOK: TButton
    Left = 174
    Top = 456
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    TabOrder = 2
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 254
    Top = 456
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 334
    Top = 456
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'ini'
    Filter = '组件前缀数据文件(*.ini)|*.ini'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 336
    Top = 24
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'ini'
    Filter = '组件前缀数据文件(*.ini)|*.ini'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 368
    Top = 24
  end
end
