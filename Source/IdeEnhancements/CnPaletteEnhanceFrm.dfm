object CnPalEnhanceForm: TCnPalEnhanceForm
  Left = 340
  Top = 195
  BorderStyle = bsDialog
  Caption = 'IDE 主窗体扩展专家设置'
  ClientHeight = 435
  ClientWidth = 448
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grpPalEnh: TGroupBox
    Left = 8
    Top = 8
    Width = 433
    Height = 145
    Caption = '组件面板扩展设置(&P)'
    TabOrder = 0
    object chkAddTabs: TCheckBox
      Left = 8
      Top = 16
      Width = 409
      Height = 17
      Caption = 
        '在组件面板的弹出菜单上添加 Tabs 项（仅适用于 Delphi 5 与 BCB 5）' +
        '。'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkMultiLine: TCheckBox
      Left = 8
      Top = 36
      Width = 337
      Height = 17
      Caption = '设置组件面板页面为多行方式。'
      TabOrder = 1
    end
    object chkDivTabMenu: TCheckBox
      Left = 8
      Top = 76
      Width = 409
      Height = 17
      Caption = '屏幕空间不足时折叠 Tabs 子菜单（仅适用于 Delphi 7 及以下版本）。'
      TabOrder = 3
    end
    object chkCompFilter: TCheckBox
      Left = 8
      Top = 96
      Width = 409
      Height = 17
      Caption = '在组件面板上添加"组件查找"按钮（仅适用于 Delphi 7 及以下版本）。'
      TabOrder = 4
    end
    object chkButtonStyle: TCheckBox
      Left = 8
      Top = 56
      Width = 337
      Height = 17
      Caption = '设置组件面板页面为平面按钮风格。'
      TabOrder = 2
    end
    object chkLockToolbar: TCheckBox
      Left = 8
      Top = 116
      Width = 409
      Height = 17
      Caption = '锁定 IDE 主窗口的工具栏以禁止拖动。'
      TabOrder = 5
    end
  end
  object btnHelp: TButton
    Left = 366
    Top = 404
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 5
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 206
    Top = 404
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 286
    Top = 404
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 4
  end
  object grpMisc: TGroupBox
    Left = 8
    Top = 156
    Width = 433
    Height = 41
    Caption = '其他扩展设置(&T)'
    TabOrder = 1
    object chkMenuLine: TCheckBox
      Left = 8
      Top = 16
      Width = 409
      Height = 17
      Caption = '自动显示 IDE 主菜单的快捷键下划线（仅适用于 Delphi 7）。'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 0
    end
  end
  object grpMenu: TGroupBox
    Left = 8
    Top = 204
    Width = 433
    Height = 193
    Caption = '主菜单设置(&W)'
    TabOrder = 2
    object lbl1: TLabel
      Left = 24
      Top = 72
      Width = 64
      Height = 13
      Caption = '可用菜单项:'
    end
    object lbl2: TLabel
      Left = 24
      Top = 44
      Width = 52
      Height = 13
      Caption = '菜单标题:'
    end
    object lbl3: TLabel
      Left = 240
      Top = 72
      Width = 88
      Height = 13
      Caption = '要移动的菜单项:'
    end
    object chkMoveWizMenus: TCheckBox
      Left = 8
      Top = 16
      Width = 401
      Height = 17
      Caption = '移动主菜单上的菜单项到二级菜单下。'
      TabOrder = 0
      OnClick = UpdateControls
    end
    object edtMoveToUser: TEdit
      Left = 88
      Top = 40
      Width = 113
      Height = 21
      TabOrder = 1
      OnClick = UpdateControls
    end
    object tlb1: TToolBar
      Left = 205
      Top = 87
      Width = 23
      Height = 90
      Align = alNone
      AutoSize = True
      Caption = 'tlb1'
      EdgeBorders = []
      Images = dmCnSharedImages.Images
      TabOrder = 2
      object btnDelete: TToolButton
        Left = 0
        Top = 2
        ImageIndex = 15
        Wrap = True
        OnClick = btnDeleteClick
      end
      object btnUp: TToolButton
        Left = 0
        Top = 24
        ImageIndex = 44
        Wrap = True
        OnClick = btnUpClick
      end
      object btnDown: TToolButton
        Left = 0
        Top = 46
        ImageIndex = 45
        Wrap = True
        OnClick = btnDownClick
      end
      object btnAdd: TToolButton
        Left = 0
        Top = 68
        ImageIndex = 14
        OnClick = btnAddClick
      end
    end
    object lstSource: TListBox
      Left = 24
      Top = 88
      Width = 177
      Height = 89
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 3
      OnClick = UpdateControls
      OnDblClick = btnAddClick
    end
    object lstDest: TListBox
      Left = 232
      Top = 88
      Width = 185
      Height = 89
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 4
      OnClick = UpdateControls
      OnDblClick = btnDeleteClick
    end
  end
end
