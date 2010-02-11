inherited CnProcListForm: TCnProcListForm
  Left = 211
  Top = 120
  Caption = 'Procedure List'
  ClientHeight = 501
  ClientWidth = 681
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
      Width = 40
      Caption = '&Classes:'
    end
    object lblFiles: TLabel [2]
      Left = 471
      Top = 12
      Width = 23
      Height = 13
      Caption = '&Unit:'
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
        Caption = 'Name'
        Width = 318
      end
      item
        Caption = 'Type'
        Width = 152
      end
      item
        Caption = 'Line'
        Width = 60
      end
      item
        Caption = 'Unit'
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
      Hint = 'Show / Hide Preview'
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
    Hint = 'Content Preview'
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
      Caption = '&Goto Implementation'
      Hint = 'Goto Implementation of Selected Procedure'
    end
    inherited actAttribute: TAction
      Visible = False
    end
    inherited actCopy: TAction
      Hint = 'Copy Selected Procedure Name to Clipboard'
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
      Caption = 'Match &Start'
      Hint = 'Match Procedure Name Start'
    end
    inherited actMatchAny: TAction
      Caption = 'Match &All Parts of Procedure Name'
      Hint = 'Match All Parts of Procedure Name'
    end
    inherited actHookIDE: TAction
      Caption = 'Show &ToolBar'
      Hint = 'Show Procedure List ToolBar in Editor'
    end
    inherited actQuery: TAction
      Visible = False
    end
  end
end
