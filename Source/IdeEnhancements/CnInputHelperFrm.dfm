inherited CnInputHelperForm: TCnInputHelperForm
  Left = 233
  Top = 101
  BorderStyle = bsDialog
  Caption = '输入助手设置'
  ClientHeight = 522
  ClientWidth = 592
  KeyPreview = True
  OldCreateOrder = True
  OnActivate = FormActivate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnHelp: TButton
    Left = 510
    Top = 493
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '帮助(&H)'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 351
    Top = 493
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '确定(&O)'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 431
    Top = 493
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 577
    Height = 478
    ActivePage = ts1
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object ts1: TTabSheet
      Caption = '助手设置(&P)'
      object grp1: TGroupBox
        Left = 8
        Top = 8
        Width = 553
        Height = 225
        Caption = '自动选项(&B)'
        TabOrder = 0
        object lbl1: TLabel
          Left = 26
          Top = 35
          Width = 124
          Height = 13
          Caption = '连续输入的有效字符数:'
        end
        object lbl2: TLabel
          Left = 250
          Top = 16
          Width = 76
          Height = 13
          Caption = '自动弹出延时:'
        end
        object lbl3: TLabel
          Left = 232
          Top = 66
          Width = 40
          Height = 12
          Alignment = taCenter
          AutoSize = False
          Caption = '0.1秒'
        end
        object lbl4: TLabel
          Left = 504
          Top = 66
          Width = 38
          Height = 12
          Alignment = taCenter
          AutoSize = False
          Caption = '2秒'
        end
        object lbl5: TLabel
          Left = 8
          Top = 151
          Width = 148
          Height = 13
          Caption = '用来切换自动显示的快捷键:'
        end
        object lbl6: TLabel
          Left = 8
          Top = 175
          Width = 148
          Height = 13
          Caption = '用来手工弹出显示的快捷键:'
        end
        object chkAutoPopup: TCheckBox
          Left = 8
          Top = 16
          Width = 169
          Height = 17
          Caption = '自动弹出输入助手。'
          TabOrder = 0
          OnClick = UpdateControls
        end
        object seDispOnlyAtLeastKey: TCnSpinEdit
          Left = 24
          Top = 52
          Width = 145
          Height = 22
          MaxValue = 5
          MinValue = 1
          TabOrder = 2
          Value = 1
        end
        object tbDispDelay: TTrackBar
          Left = 240
          Top = 32
          Width = 305
          Height = 33
          Max = 2000
          Min = 100
          Orientation = trHorizontal
          PageSize = 500
          Frequency = 100
          Position = 100
          SelEnd = 0
          SelStart = 0
          TabOrder = 1
          TickMarks = tmBottomRight
          TickStyle = tsAuto
        end
        object chkSmartDisp: TCheckBox
          Left = 24
          Top = 78
          Width = 409
          Height = 17
          Caption = '智能判断是否需要弹出助手。'
          TabOrder = 3
        end
        object hkEnabled: THotKey
          Left = 248
          Top = 148
          Width = 289
          Height = 19
          HotKey = 32833
          InvalidKeys = [hcNone, hcShift]
          Modifiers = [hkAlt]
          TabOrder = 6
        end
        object hkPopup: THotKey
          Left = 248
          Top = 172
          Width = 289
          Height = 19
          HotKey = 32833
          InvalidKeys = [hcNone, hcShift]
          Modifiers = [hkAlt]
          TabOrder = 7
        end
        object chkCheckImmRun: TCheckBox
          Left = 8
          Top = 199
          Width = 401
          Height = 17
          Caption = '输入法开启时不弹出输入助手。'
          TabOrder = 8
        end
        object chkDispOnIDECompDisabled: TCheckBox
          Left = 24
          Top = 99
          Width = 409
          Height = 17
          Caption = '如果禁用 IDE 的代码完成，则自动取代。'
          TabOrder = 4
        end
        object edtAutoSymbols: TEdit
          Left = 248
          Top = 121
          Width = 289
          Height = 21
          TabOrder = 5
        end
        object chkKeySeq: TCheckBox
          Left = 24
          Top = 125
          Width = 209
          Height = 13
          Caption = '自动弹出列表的按键序列(逗号分隔):'
          TabOrder = 9
          OnClick = UpdateControls
        end
      end
      object grp3: TGroupBox
        Left = 8
        Top = 240
        Width = 553
        Height = 198
        Caption = '输出设置(&W)'
        TabOrder = 1
        object lbl9: TLabel
          Left = 8
          Top = 20
          Width = 160
          Height = 13
          Caption = '可用于选择当前项的字符列表:'
        end
        object lbl10: TLabel
          Left = 8
          Top = 74
          Width = 88
          Height = 13
          Caption = '标识符输出方式:'
        end
        object lbl16: TLabel
          Left = 8
          Top = 47
          Width = 192
          Height = 13
          Caption = '禁止自动弹出列表的符号(逗号分隔):'
        end
        object edtCompleteChars: TEdit
          Left = 248
          Top = 16
          Width = 289
          Height = 21
          TabOrder = 0
        end
        object cbbOutputStyle: TComboBox
          Left = 248
          Top = 70
          Width = 289
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 2
          Items.Strings = (
            '自动识别'
            '替换标识符左边部分'
            '替换整个标识符'
            '回车时替换整个标识符')
        end
        object chkSelMidMatchByEnterOnly: TCheckBox
          Left = 8
          Top = 132
          Width = 529
          Height = 17
          Caption = '只使用回车键来选择中间匹配的标识符。'
          TabOrder = 5
        end
        object chkAutoInsertEnter: TCheckBox
          Left = 8
          Top = 150
          Width = 529
          Height = 17
          Caption = '对关键字回车自动换行。'
          TabOrder = 6
        end
        object chkSpcComplete: TCheckBox
          Left = 8
          Top = 96
          Width = 529
          Height = 17
          Caption = '允许使用空格键来选择当前项。'
          TabOrder = 3
          OnClick = chkSpcCompleteClick
        end
        object chkAutoCompParam: TCheckBox
          Left = 8
          Top = 168
          Width = 529
          Height = 17
          Caption = '对带参数的函数自动完成括号。'
          TabOrder = 7
        end
        object edtFilterSymbols: TEdit
          Left = 248
          Top = 43
          Width = 289
          Height = 21
          TabOrder = 1
        end
        object chkIgnoreSpace: TCheckBox
          Left = 24
          Top = 114
          Width = 521
          Height = 17
          Caption = '使用空格键选择当前项后忽略空格本身。'
          TabOrder = 4
        end
      end
    end
    object ts2: TTabSheet
      Caption = '列表设置(&J)'
      ImageIndex = 1
      object grp2: TGroupBox
        Left = 8
        Top = 8
        Width = 553
        Height = 193
        Caption = '列表显示(&N)'
        TabOrder = 0
        object lbl7: TLabel
          Left = 8
          Top = 47
          Width = 100
          Height = 13
          Caption = '标识符的最小长度:'
        end
        object lbl8: TLabel
          Left = 8
          Top = 20
          Width = 76
          Height = 13
          Caption = '列表排序方式:'
        end
        object PaintBox: TPaintBox
          Left = 432
          Top = 45
          Width = 113
          Height = 25
          OnPaint = PaintBoxPaint
        end
        object lbl15: TLabel
          Left = 8
          Top = 76
          Width = 40
          Height = 13
          Caption = '保留字:'
        end
        object seListOnlyAtLeastLetter: TCnSpinEdit
          Left = 120
          Top = 43
          Width = 249
          Height = 22
          MaxValue = 5
          MinValue = 1
          TabOrder = 2
          Value = 1
        end
        object chkMatchAnyWhere: TCheckBox
          Left = 8
          Top = 98
          Width = 505
          Height = 17
          Caption = '显示中间匹配的标识符。'
          TabOrder = 4
        end
        object cbbSortKind: TComboBox
          Left = 120
          Top = 16
          Width = 249
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
        end
        object btnFont: TButton
          Left = 432
          Top = 16
          Width = 113
          Height = 21
          Caption = '列表字体...'
          TabOrder = 1
          OnClick = btnFontClick
        end
        object chkAutoAdjustScope: TCheckBox
          Left = 8
          Top = 116
          Width = 505
          Height = 17
          Caption = '根据使用频率自动调整列表项显示优先级。'
          TabOrder = 5
        end
        object chkUseCodeInsightMgr: TCheckBox
          Left = 8
          Top = 152
          Width = 505
          Height = 17
          Caption = '使用兼容方式取得当前标识符列表（较慢）。'
          TabOrder = 7
        end
        object chkRemoveSame: TCheckBox
          Left = 8
          Top = 134
          Width = 505
          Height = 17
          Caption = '过滤重复的列表项。'
          TabOrder = 6
        end
        object cbbKeyword: TComboBox
          Left = 120
          Top = 72
          Width = 249
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 3
        end
        object chkUseKibitzCompileThread: TCheckBox
          Left = 8
          Top = 170
          Width = 505
          Height = 17
          Caption = '打开工程时后台预获取标识符列表。'
          TabOrder = 8
        end
      end
      object grp4: TGroupBox
        Left = 8
        Top = 210
        Width = 553
        Height = 228
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = '内容设置(&S)'
        TabOrder = 1
        object lbl11: TLabel
          Left = 8
          Top = 20
          Width = 88
          Height = 13
          Caption = '符号提供者列表:'
        end
        object lbl14: TLabel
          Left = 384
          Top = 20
          Width = 76
          Height = 13
          Caption = '符号类型设置:'
        end
        object chklstSymbol: TCheckListBox
          Left = 8
          Top = 40
          Width = 369
          Height = 177
          Anchors = [akLeft, akTop, akBottom]
          ItemHeight = 13
          TabOrder = 0
        end
        object chklstKind: TCheckListBox
          Left = 384
          Top = 40
          Width = 161
          Height = 177
          Anchors = [akLeft, akTop, akBottom]
          ItemHeight = 13
          TabOrder = 1
        end
      end
    end
    object ts3: TTabSheet
      Caption = '自定义符号(&F)'
      ImageIndex = 2
      object grp5: TGroupBox
        Left = 8
        Top = 8
        Width = 553
        Height = 430
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = '自定义符号(&T)'
        TabOrder = 0
        object lbl12: TLabel
          Left = 8
          Top = 20
          Width = 52
          Height = 13
          Caption = '符号列表:'
        end
        object lbl13: TLabel
          Left = 8
          Top = 224
          Width = 285
          Height = 13
          Caption = '代码模板:(仅用于 "Template" 和 "Comment" 类型的符号)'
        end
        object lvList: TListView
          Left = 8
          Top = 48
          Width = 465
          Height = 169
          Columns = <
            item
              Caption = '名称'
              Width = 100
            end
            item
              Caption = '类型'
              Width = 70
            end
            item
              Caption = '优先级'
              Width = 48
            end
            item
              Caption = '描述'
              Width = 225
            end>
          HideSelection = False
          MultiSelect = True
          ReadOnly = True
          RowSelect = True
          TabOrder = 1
          ViewStyle = vsReport
          OnChange = lvListChange
          OnClick = UpdateListControls
          OnColumnClick = lvListColumnClick
          OnCompare = lvListCompare
          OnDblClick = btnEditClick
        end
        object btnAdd: TButton
          Left = 480
          Top = 48
          Width = 65
          Height = 21
          Caption = '增加(&A)'
          TabOrder = 2
          OnClick = btnAddClick
        end
        object mmoTemplate: TMemo
          Left = 8
          Top = 240
          Width = 465
          Height = 182
          Anchors = [akLeft, akTop, akRight, akBottom]
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 9
          OnExit = mmoTemplateExit
        end
        object btnDelete: TButton
          Left = 480
          Top = 97
          Width = 65
          Height = 21
          Caption = '删除(&D)'
          TabOrder = 4
          OnClick = btnDeleteClick
        end
        object btnEdit: TButton
          Left = 480
          Top = 122
          Width = 65
          Height = 21
          Caption = '编辑(&E)'
          TabOrder = 5
          OnClick = btnEditClick
        end
        object btnImport: TButton
          Left = 480
          Top = 171
          Width = 65
          Height = 21
          Caption = '导入(&I)'
          TabOrder = 7
          OnClick = btnImportClick
        end
        object btnExport: TButton
          Left = 480
          Top = 196
          Width = 65
          Height = 21
          Caption = '导出(&X)'
          TabOrder = 8
          OnClick = btnExportClick
        end
        object btnInsertMacro: TButton
          Left = 480
          Top = 241
          Width = 65
          Height = 21
          Caption = '插入宏(&M)'
          TabOrder = 10
          OnClick = btnInsertMacroClick
        end
        object btnCursor: TButton
          Left = 480
          Top = 296
          Width = 65
          Height = 21
          Caption = '光标(&R)'
          TabOrder = 12
          OnClick = btnCursorClick
        end
        object btnClear: TButton
          Left = 480
          Top = 324
          Width = 65
          Height = 21
          Caption = '清空(&L)'
          TabOrder = 13
          OnClick = btnClearClick
        end
        object btnDup: TButton
          Left = 480
          Top = 73
          Width = 65
          Height = 21
          Caption = '副本(&U)'
          TabOrder = 3
          OnClick = btnDupClick
        end
        object btnUserMacro: TButton
          Left = 480
          Top = 268
          Width = 65
          Height = 21
          Caption = '用户宏(&V)'
          TabOrder = 11
          OnClick = btnUserMacroClick
        end
        object btnDefault: TButton
          Left = 480
          Top = 147
          Width = 65
          Height = 21
          Caption = '默认(&K)'
          TabOrder = 6
          OnClick = btnDefaultClick
        end
        object cbbList: TComboBox
          Left = 72
          Top = 16
          Width = 401
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbbListChange
        end
      end
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Options = []
    Left = 15
    Top = 456
  end
  object pmMacro: TPopupMenu
    Left = 79
    Top = 456
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'xml'
    Filter = '自定义符号文件(*.xml)|*.xml'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 47
    Top = 456
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'xml'
    Filter = '自定义符号文件(*.xml)|*.xml'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 111
    Top = 456
  end
end
