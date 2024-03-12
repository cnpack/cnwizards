inherited CnProcListForm: TCnProcListForm
  Left = 310
  Top = 129
  Caption = 'Procedure List'
  ClientHeight = 501
  ClientWidth = 681
  PixelsPerInch = 96
  TextHeight = 13
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
      Left = 378
      Top = 0
      Width = 8
      Style = tbsSeparator
    end
    object btnShowPreview: TToolButton
      Left = 386
      Top = 0
      Hint = 'Show / Hide Preview'
      ImageIndex = 30
      Style = tbsCheck
      OnClick = btnShowPreviewClick
    end
    object btn2: TToolButton
      Left = 409
      Top = 0
      Width = 8
      Caption = 'btn2'
      ImageIndex = 47
      Style = tbsSeparator
    end
    object btnPreviewRight: TToolButton
      Left = 417
      Top = 0
      Hint = 'Preview at Right'
      Grouped = True
      ImageIndex = 100
      Style = tbsCheck
      OnClick = btnPreviewRightClick
    end
    object btnPreviewDown: TToolButton
      Left = 440
      Top = 0
      Hint = 'Preview at Bottom'
      Grouped = True
      ImageIndex = 108
      Style = tbsCheck
      OnClick = btnPreviewDownClick
    end
  end
  inherited pnlMain: TPanel
    Width = 681
    Height = 416
    object Splitter: TSplitter [0]
      Left = 0
      Top = 334
      Width = 681
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      AutoSnap = False
      MinSize = 60
      OnMoved = SplitterMoved
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
      OwnerData = True
      OnData = lvListData
    end
    object mmoContent: TMemo
      Left = 0
      Top = 337
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
      TabOrder = 1
      WordWrap = False
    end
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
