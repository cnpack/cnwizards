inherited CnScriptForm: TCnScriptForm
  Left = 325
  Top = 169
  Width = 574
  Height = 447
  Caption = '脚本窗口'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tlb1: TToolBar
    Left = 0
    Top = 0
    Width = 566
    Height = 22
    AutoSize = True
    EdgeBorders = []
    Flat = True
    Images = dmCnSharedImages.Images
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object btnNew: TToolButton
      Left = 0
      Top = 0
      Hint = '新的脚本'
      ImageIndex = 12
      OnClick = btnNewClick
    end
    object btnLoad: TToolButton
      Left = 23
      Top = 0
      Hint = '从文件中装入'
      DropdownMenu = pmOpen
      ImageIndex = 3
      Style = tbsDropDown
      OnClick = btnLoadClick
    end
    object btn1: TToolButton
      Left = 59
      Top = 0
      Width = 8
      Caption = 'btn1'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object btnAddToList: TToolButton
      Left = 67
      Top = 0
      Hint = '增加到脚本列表'
      ImageIndex = 37
      OnClick = btnAddToListClick
    end
    object btnOption: TToolButton
      Left = 90
      Top = 0
      Hint = '设置...'
      ImageIndex = 2
      OnClick = btnOptionClick
    end
    object btn5: TToolButton
      Left = 113
      Top = 0
      Width = 8
      ImageIndex = 4
      Style = tbsSeparator
    end
    object btnCompile: TToolButton
      Left = 121
      Top = 0
      Hint = '编译脚本'
      ImageIndex = 34
      OnClick = btnCompileClick
    end
    object btnRun: TToolButton
      Left = 144
      Top = 0
      Hint = '运行脚本'
      DropdownMenu = pmRun
      ImageIndex = 39
      Style = tbsDropDown
      OnClick = btnRunClick
    end
    object btnClear: TToolButton
      Left = 180
      Top = 0
      Hint = '清空消息'
      ImageIndex = 13
      OnClick = btnClearClick
    end
    object btn7: TToolButton
      Left = 203
      Top = 0
      Width = 8
      ImageIndex = 40
      Style = tbsSeparator
    end
    object btnHelp: TToolButton
      Left = 211
      Top = 0
      Hint = '帮助'
      DropdownMenu = pmHelp
      ImageIndex = 1
      Style = tbsDropDown
      OnClick = mniHelpClick
    end
    object btnClose: TToolButton
      Left = 247
      Top = 0
      Hint = '关闭'
      ImageIndex = 0
      OnClick = btnCloseClick
    end
  end
  object mmoOut: TMemo
    Left = 0
    Top = 22
    Width = 566
    Height = 398
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object pmHelp: TPopupMenu
    Left = 79
    Top = 377
    object mniHelp: TMenuItem
      Caption = '帮助(&H)'
      OnClick = mniHelpClick
    end
    object mniN1: TMenuItem
      Caption = '-'
    end
    object mniDeclDir: TMenuItem
      Caption = '脚本接口文件目录(&D)'
      OnClick = mniDeclDirClick
    end
    object mniDemoDir: TMenuItem
      Caption = '例子脚本目录(&S)'
      OnClick = mniDemoDirClick
    end
  end
  object pmRun: TPopupMenu
    OnPopup = pmRunPopup
    Left = 111
    Top = 377
    object mniRun: TMenuItem
      Caption = '执行当前脚本(&R)'
      OnClick = btnRunClick
    end
    object mniN2: TMenuItem
      Caption = '-'
    end
  end
  object pmOpen: TPopupMenu
    OnPopup = pmOpenPopup
    Left = 47
    Top = 377
  end
  object dlgOpenFile: TOpenDialog
    DefaultExt = 'pas'
    Filter = 'Pascal 脚本文件(*.pas)|*.pas|所有文件(*.*)|*.*'
    Left = 15
    Top = 377
  end
end
