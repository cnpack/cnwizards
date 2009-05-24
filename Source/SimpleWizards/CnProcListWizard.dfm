inherited CnProcListForm: TCnProcListForm
  Left = 211
  Top = 120
  Caption = '函数过程列表'
  ClientHeight = 501
  ClientWidth = 681
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter [0]
    Left = 0
    Top = 400
    Width = 681
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    MinSize = 60
    OnMoved = SplitterMoved
  end
  inherited pnlHeader: TPanel
    Width = 681
    inherited lblSearch: TLabel
      FocusControl = cbbMatchSearch
    end
    inherited lblProject: TLabel
      Left = 243
      Width = 43
      Caption = '分类(&C):'
    end
    object lblFiles: TLabel [2]
      Left = 471
      Top = 12
      Width = 43
      Height = 13
      Caption = '单元(&U):'
      FocusControl = cbbFiles
    end
    inherited edtMatchSearch: TEdit
      Left = 67
      Width = 162
      Visible = False
    end
    inherited cbbProjectList: TComboBox
      Left = 295
      Width = 162
      DropDownCount = 16
      TabOrder = 2
    end
    object cbbMatchSearch: TComboBox
      Left = 67
      Top = 8
      Width = 162
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbbMatchSearchChange
      OnKeyDown = cbbMatchSearchKeyDown
    end
    object cbbFiles: TComboBox
      Left = 520
      Top = 8
      Width = 150
      Height = 21
      Style = csDropDownList
      DropDownCount = 16
      ItemHeight = 13
      TabOrder = 3
      OnChange = cbbFilesChange
      OnDropDown = cbbFilesDropDown
    end
  end
  inherited lvList: TListView
    Width = 681
    Height = 334
    Columns = <
      item
        Caption = '名称'
        Width = 318
      end
      item
        Caption = '类型'
        Width = 152
      end
      item
        Caption = '行号'
        Width = 60
      end
      item
        Caption = '所在单元'
        Width = 130
      end>
    MultiSelect = False
    OwnerData = True
    OnData = lvListData
  end
  inherited StatusBar: TStatusBar
    Top = 482
    Width = 681
    AutoHint = False
    Panels = <
      item
        Width = 420
      end
      item
        Width = 90
      end
      item
        Width = 50
      end>
  end
  inherited ToolBar: TToolBar
    Width = 681
    inherited btnSep1: TToolButton
      Visible = False
    end
    inherited btnSep4: TToolButton
      Visible = False
    end
    object btnSep9: TToolButton
      Left = 355
      Top = 0
      Width = 8
      ImageIndex = 31
      Style = tbsSeparator
    end
    object btnShowPreview: TToolButton
      Left = 363
      Top = 0
      Hint = '切换预览窗口的显示'
      ImageIndex = 30
      Style = tbsCheck
      OnClick = btnShowPreviewClick
    end
  end
  object mmoContent: TMemo [5]
    Left = 0
    Top = 403
    Width = 681
    Height = 79
    Hint = '函数过程内容预览'
    Align = alBottom
    Constraints.MinHeight = 30
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    HideSelection = False
    ParentFont = False
    ParentShowHint = False
    ReadOnly = True
    ScrollBars = ssVertical
    ShowHint = True
    TabOrder = 4
    WordWrap = False
  end
  inherited ActionList: TActionList
    inherited actOpen: TAction
      Hint = '跳转至选定的过程'
    end
    inherited actAttribute: TAction
      Visible = False
    end
    inherited actCopy: TAction
      Hint = '复制所选函数或过程名到剪贴板'
    end
    inherited actSelectAll: TAction
      Visible = False
    end
    inherited actSelectNone: TAction
      Visible = False
    end
    inherited actSelectInvert: TAction
      Visible = False
    end
    inherited actMatchStart: TAction
      Hint = '匹配函数过程名开头'
    end
    inherited actMatchAny: TAction
      Hint = '匹配函数过程名所有位置'
    end
    inherited actHookIDE: TAction
      Caption = '显示工具栏(&I)'
      Hint = '在编辑器窗口内显示函数过程列表工具栏'
    end
    inherited actQuery: TAction
      Visible = False
    end
  end
end
