object CnSrcEditorEnhanceForm: TCnSrcEditorEnhanceForm
  Left = 300
  Top = 126
  BorderStyle = bsDialog
  Caption = '代码编辑器扩展专家设置'
  ClientHeight = 453
  ClientWidth = 401
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 158
    Top = 422
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 238
    Top = 422
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 318
    Top = 422
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 385
    Height = 406
    ActivePage = ts1
    TabOrder = 0
    object ts1: TTabSheet
      Caption = '编辑器增强(&E)'
      object grpEditorEnh: TGroupBox
        Left = 8
        Top = 8
        Width = 361
        Height = 169
        Caption = '代码编辑器菜单扩展(&F)'
        TabOrder = 0
        object lbl4: TLabel
          Left = 26
          Top = 60
          Width = 64
          Height = 13
          Caption = '执行命令行:'
        end
        object chkAddMenuCloseOtherPages: TCheckBox
          Left = 8
          Top = 16
          Width = 350
          Height = 17
          Caption = '在编辑器右键菜单中增加“关闭其它页面”菜单项。'
          TabOrder = 0
        end
        object chkAddMenuSelAll: TCheckBox
          Left = 8
          Top = 100
          Width = 350
          Height = 17
          Caption = '在编辑器右键菜单中增加“选择全部”菜单项。'
          TabOrder = 4
        end
        object chkAddMenuExplore: TCheckBox
          Left = 8
          Top = 36
          Width = 350
          Height = 17
          Caption = '在编辑器右键菜单中增加“在资源管理器中打开”菜单项。'
          TabOrder = 1
          OnClick = UpdateContent
        end
        object chkCodeCompletion: TCheckBox
          Left = 8
          Top = 140
          Width = 193
          Height = 17
          Caption = '增加代码自动完成的热键：'
          TabOrder = 6
          OnClick = UpdateContent
        end
        object hkCodeCompletion: THotKey
          Left = 208
          Top = 140
          Width = 137
          Height = 19
          HotKey = 32833
          InvalidKeys = [hcNone, hcShift]
          Modifiers = [hkAlt]
          TabOrder = 7
        end
        object chkAddMenuShellMenu: TCheckBox
          Left = 8
          Top = 120
          Width = 350
          Height = 17
          Caption = '在编辑器右键菜单中增加“外壳关联菜单”菜单项。'
          TabOrder = 5
        end
        object chkAddMenuCopyFileName: TCheckBox
          Left = 8
          Top = 80
          Width = 350
          Height = 17
          Caption = '在编辑器右键菜单中增加“复制完整的路径名/文件名”菜单项'
          TabOrder = 3
        end
        object edtExploreCmdLine: TEdit
          Left = 104
          Top = 56
          Width = 241
          Height = 21
          TabOrder = 2
        end
      end
      object grpAutoReadOnly: TGroupBox
        Left = 8
        Top = 180
        Width = 361
        Height = 189
        Caption = '源代码只读保护(&R)'
        TabOrder = 1
        object lblDir: TLabel
          Left = 8
          Top = 137
          Width = 36
          Height = 13
          Caption = '目录：'
        end
        object chkAutoReadOnly: TCheckBox
          Left = 8
          Top = 17
          Width = 345
          Height = 17
          Caption = '打开下列目录中的源文件时自动只读保护：'
          TabOrder = 0
          OnClick = UpdateContent
        end
        object lbReadOnlyDirs: TListBox
          Left = 8
          Top = 40
          Width = 337
          Height = 85
          ItemHeight = 13
          TabOrder = 1
          OnClick = lbReadOnlyDirsClick
        end
        object edtDir: TEdit
          Left = 48
          Top = 133
          Width = 273
          Height = 21
          TabOrder = 2
        end
        object btnSelectDir: TButton
          Left = 325
          Top = 133
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 3
          OnClick = btnSelectDirClick
        end
        object btnReplace: TButton
          Left = 63
          Top = 159
          Width = 75
          Height = 21
          Action = actReplace
          TabOrder = 4
        end
        object btnAdd: TButton
          Left = 143
          Top = 159
          Width = 75
          Height = 21
          Action = actAdd
          TabOrder = 5
        end
        object btnDel: TButton
          Left = 223
          Top = 159
          Width = 75
          Height = 21
          Action = actDelete
          Cancel = True
          TabOrder = 6
        end
      end
    end
    object ts2: TTabSheet
      Caption = '行号及工具栏(&V)'
      ImageIndex = 1
      object grpLineNumber: TGroupBox
        Left = 8
        Top = 110
        Width = 361
        Height = 145
        Caption = '行号显示(&L)'
        TabOrder = 1
        object lbl1: TLabel
          Left = 42
          Top = 120
          Width = 84
          Height = 13
          Caption = '固定显示位数：'
        end
        object lbl2: TLabel
          Left = 42
          Top = 80
          Width = 84
          Height = 13
          Caption = '最少显示位数：'
        end
        object chkShowLineNumber: TCheckBox
          Left = 8
          Top = 14
          Width = 350
          Height = 17
          Caption = '在编辑器中增加显示行号的功能。'
          TabOrder = 0
          OnClick = UpdateContent
        end
        object rbLinePanelAutoWidth: TRadioButton
          Left = 24
          Top = 53
          Width = 321
          Height = 17
          Caption = '行号面板宽度自动调整。'
          Checked = True
          TabOrder = 4
          TabStop = True
          OnClick = UpdateContent
        end
        object rbLinePanelFixedWidth: TRadioButton
          Left = 24
          Top = 99
          Width = 321
          Height = 17
          Caption = '行号面板固定宽度。'
          TabOrder = 6
          OnClick = UpdateContent
        end
        object seLinePanelFixWidth: TCnSpinEdit
          Left = 184
          Top = 115
          Width = 49
          Height = 22
          MaxValue = 10
          MinValue = 1
          TabOrder = 7
          Value = 3
        end
        object chkShowLineCount: TCheckBox
          Left = 24
          Top = 32
          Width = 321
          Height = 17
          Caption = '显示文件总行数。'
          TabOrder = 2
        end
        object seLinePanelMinWidth: TCnSpinEdit
          Left = 184
          Top = 75
          Width = 49
          Height = 22
          MaxValue = 10
          MinValue = 1
          TabOrder = 5
          Value = 3
        end
        object btnLineFont: TButton
          Left = 224
          Top = 16
          Width = 129
          Height = 21
          Caption = '行号字体(&F)...'
          TabOrder = 1
          OnClick = btnLineFontClick
        end
        object btnCurrLineFont: TButton
          Left = 224
          Top = 48
          Width = 129
          Height = 21
          Caption = '当前行行号字体(&U)...'
          TabOrder = 3
          OnClick = btnCurrLineFontClick
        end
      end
      object grpToolBar: TGroupBox
        Left = 8
        Top = 8
        Width = 361
        Height = 94
        Caption = '编辑器工具栏(&T)'
        TabOrder = 0
        object chkShowToolBar: TCheckBox
          Left = 8
          Top = 16
          Width = 225
          Height = 17
          Caption = '在编辑器中增加工具栏。'
          TabOrder = 0
          OnClick = UpdateContent
        end
        object btnToolBar: TButton
          Left = 224
          Top = 16
          Width = 129
          Height = 21
          Caption = '定制按钮(&B)...'
          TabOrder = 1
          OnClick = btnToolBarClick
        end
        object chkToolBarWrap: TCheckBox
          Left = 24
          Top = 66
          Width = 201
          Height = 17
          Caption = '按钮自动换行。'
          TabOrder = 4
        end
        object chkShowInDesign: TCheckBox
          Left = 8
          Top = 42
          Width = 209
          Height = 17
          Caption = '在 BDS 窗体设计界面显示工具栏。'
          TabOrder = 2
          OnClick = UpdateContent
        end
        object btnDesignToolBar: TButton
          Left = 224
          Top = 42
          Width = 129
          Height = 21
          Caption = '定制按钮(&F)...'
          TabOrder = 3
          OnClick = btnDesignToolBarClick
        end
      end
      object grpEditorNav: TGroupBox
        Left = 8
        Top = 262
        Width = 361
        Height = 106
        Caption = '前进后退扩展(&J)'
        TabOrder = 2
        object Label1: TLabel
          Left = 26
          Top = 44
          Width = 120
          Height = 13
          Caption = '新记录的最小行间隔：'
        end
        object Label2: TLabel
          Left = 26
          Top = 72
          Width = 84
          Height = 13
          Caption = '最大列表项数：'
        end
        object chkExtendForwardBack: TCheckBox
          Left = 8
          Top = 16
          Width = 345
          Height = 17
          Caption = '扩展代码编辑器的前进、后退按钮功能。'
          TabOrder = 0
          OnClick = UpdateContent
        end
        object seNavMinLineDiff: TCnSpinEdit
          Left = 184
          Top = 39
          Width = 49
          Height = 22
          MaxValue = 99
          MinValue = 1
          TabOrder = 1
          Value = 5
        end
        object seNavMaxItems: TCnSpinEdit
          Left = 184
          Top = 67
          Width = 49
          Height = 22
          MaxLength = 2
          MaxValue = 99
          MinValue = 1
          TabOrder = 2
          Value = 20
        end
      end
    end
    object ts3: TTabSheet
      Caption = '标签及浮动按钮(&T)'
      ImageIndex = 2
      object gbTab: TGroupBox
        Left = 8
        Top = 8
        Width = 361
        Height = 123
        Caption = '源码标签扩展(&B)'
        TabOrder = 0
        object chkDispModifiedInTab: TCheckBox
          Left = 8
          Top = 16
          Width = 350
          Height = 17
          Caption = '在源代码标签中为已修改的文件添加 * 号。'
          TabOrder = 0
        end
        object chkDblClkClosePage: TCheckBox
          Left = 8
          Top = 36
          Width = 350
          Height = 17
          Caption = '通过双击编辑器标签关闭指定页面。'
          TabOrder = 1
        end
        object chkRClickShellMenu: TCheckBox
          Left = 8
          Top = 56
          Width = 350
          Height = 17
          Caption = '使用 Shift 或 Ctrl 加鼠标右键点击标签显示外壳菜单。'
          TabOrder = 2
        end
        object chkEditorMultiLine: TCheckBox
          Left = 8
          Top = 76
          Width = 350
          Height = 17
          Caption = '设置代码编辑器标签为多行方式（不适用于BDS）。'
          TabOrder = 3
        end
        object chkEditorFlatButtons: TCheckBox
          Left = 8
          Top = 96
          Width = 350
          Height = 17
          Caption = '设置代码编辑器标签为平面按钮风格（不适用于BDS）。'
          TabOrder = 4
        end
      end
      object gbFlatButton: TGroupBox
        Left = 8
        Top = 139
        Width = 361
        Height = 64
        Caption = '选择块浮动按钮(&F)'
        TabOrder = 1
        object chkShowFlatButton: TCheckBox
          Left = 8
          Top = 16
          Width = 350
          Height = 17
          Caption = '块选择时显示浮动工具按钮。'
          TabOrder = 0
        end
        object chkAddMenuBlockTools: TCheckBox
          Left = 8
          Top = 38
          Width = 326
          Height = 17
          Caption = '在编辑器右键菜单中显示浮动工具按钮下拉菜单。'
          TabOrder = 1
        end
      end
      object grpAutoSave: TGroupBox
        Left = 8
        Top = 281
        Width = 361
        Height = 87
        Caption = '自动保存(&S)'
        TabOrder = 3
        object lblSaveInterval: TLabel
          Left = 26
          Top = 40
          Width = 36
          Height = 13
          Caption = '每隔：'
        end
        object lblMinutes: TLabel
          Left = 200
          Top = 40
          Width = 108
          Height = 13
          Caption = '分钟全部保存一次。'
        end
        object chkAutoSave: TCheckBox
          Left = 8
          Top = 16
          Width = 350
          Height = 17
          Caption = '启用自动保存功能。'
          TabOrder = 0
          OnClick = UpdateContent
        end
        object seSaveInterval: TCnSpinEdit
          Left = 136
          Top = 38
          Width = 49
          Height = 22
          MaxValue = 30
          MinValue = 1
          TabOrder = 1
          Value = 3
        end
      end
      object grpSmart: TGroupBox
        Left = 8
        Top = 211
        Width = 361
        Height = 62
        Caption = '剪贴板操作(&P)'
        TabOrder = 2
        object chkSmartCopy: TCheckBox
          Left = 8
          Top = 16
          Width = 350
          Height = 17
          Caption = '未选择时剪切复制当前光标下的标识符。'
          TabOrder = 0
        end
        object chkSmartPaste: TCheckBox
          Left = 8
          Top = 36
          Width = 350
          Height = 17
          Caption = '粘贴时自动替换当前光标下的标识符。'
          TabOrder = 1
        end
      end
    end
    object ts4: TTabSheet
      Caption = '其它(&R)'
      ImageIndex = 3
      object grpKeyExtend: TGroupBox
        Left = 8
        Top = 8
        Width = 361
        Height = 224
        Caption = '功能键扩展(&K)'
        TabOrder = 0
        object chkShiftEnter: TCheckBox
          Left = 8
          Top = 40
          Width = 350
          Height = 17
          Caption = 'Shift+Enter 键移到行尾再换行。'
          TabOrder = 1
        end
        object chkHomeExtend: TCheckBox
          Left = 8
          Top = 140
          Width = 350
          Height = 17
          Caption = '使用 Home 键移动到行首或第一个非空字符。'
          TabOrder = 7
          OnClick = UpdateContent
        end
        object chkHomeFirstChar: TCheckBox
          Left = 24
          Top = 160
          Width = 329
          Height = 17
          Caption = '不在行首时按 Home 键首先移到第一个非空字符。'
          TabOrder = 8
        end
        object chkSearchAgain: TCheckBox
          Left = 8
          Top = 80
          Width = 350
          Height = 17
          Caption = 'F3/Shift+F3 查找选中的文字。'
          TabOrder = 4
          OnClick = UpdateContent
        end
        object chkTabIndent: TCheckBox
          Left = 8
          Top = 20
          Width = 350
          Height = 17
          Caption = 'Tab/Shift+Tab 缩进/反缩进选中代码块。'
          TabOrder = 0
        end
        object chkAutoBracket: TCheckBox
          Left = 8
          Top = 120
          Width = 350
          Height = 17
          Caption = '自动括号匹配输入 (), [], {} 。'
          TabOrder = 6
        end
        object chkKeepSearch: TCheckBox
          Left = 24
          Top = 100
          Width = 330
          Height = 17
          Caption = 'F3/Shift+F3 查找时记忆查找的内容。'
          TabOrder = 5
        end
        object chkF2Rename: TCheckBox
          Left = 8
          Top = 60
          Width = 350
          Height = 17
          Caption = '使用此热键输入并替换光标下的标识符：'
          TabOrder = 3
          OnClick = UpdateContent
        end
        object hkRename: THotKey
          Left = 272
          Top = 58
          Width = 73
          Height = 19
          HotKey = 32833
          InvalidKeys = [hcNone, hcShift]
          Modifiers = [hkAlt]
          TabOrder = 2
        end
        object chkSemicolon: TCheckBox
          Left = 8
          Top = 180
          Width = 350
          Height = 17
          Caption = '有效代码语句中输入分号时自动移动到行尾。'
          TabOrder = 9
          OnClick = UpdateContent
        end
        object chkAutoEnterEnd: TCheckBox
          Left = 8
          Top = 200
          Width = 350
          Height = 17
          Caption = 'begin 后按回车时自动输入匹配的 end 并缩进。'
          TabOrder = 10
          OnClick = UpdateContent
        end
      end
      object grpAutoIndent: TGroupBox
        Left = 8
        Top = 237
        Width = 361
        Height = 132
        Caption = '自动缩进(&I)'
        TabOrder = 1
        object lbl3: TLabel
          Left = 24
          Top = 37
          Width = 159
          Height = 13
          Caption = '需要缩进的 Delphi 关键字列表:'
        end
        object chkAutoIndent: TCheckBox
          Left = 8
          Top = 16
          Width = 345
          Height = 17
          Caption = '在 Delphi 的指定关键字或 C 的 '#39'{'#39' 后回车时自动缩进。'
          TabOrder = 0
          OnClick = UpdateContent
        end
        object mmoAutoIndent: TMemo
          Left = 24
          Top = 56
          Width = 325
          Height = 64
          ScrollBars = ssVertical
          TabOrder = 1
          WordWrap = False
        end
      end
    end
  end
  object ActionList: TActionList
    OnUpdate = ActionListUpdate
    Left = 8
    Top = 416
    object actReplace: TAction
      Caption = '替换(&R)'
      OnExecute = actReplaceExecute
    end
    object actAdd: TAction
      Caption = '添加(&A)'
      OnExecute = actAddExecute
    end
    object actDelete: TAction
      Caption = '删除(&D)'
      OnExecute = actDeleteExecute
    end
  end
  object dlgFontCurrLine: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 72
    Top = 416
  end
  object dlgFontLine: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 40
    Top = 416
  end
end
