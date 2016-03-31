inherited CnProjectUseUnitsForm: TCnProjectUseUnitsForm
  Left = 282
  Top = 87
  Caption = 'Use Unit'
  ClientHeight = 446
  ClientWidth = 651
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlHeader: TPanel
    Width = 651
    inherited lblProject: TLabel
      Left = 319
      Width = 36
      Caption = '&Add to:'
      FocusControl = nil
    end
    inherited cbbProjectList: TComboBox
      Left = 591
      Visible = False
    end
    object rbIntf: TRadioButton
      Left = 388
      Top = 12
      Width = 97
      Height = 17
      Caption = 'Interface'
      Checked = True
      TabOrder = 2
      TabStop = True
      OnDblClick = rbIntfDblClick
      OnKeyDown = rbIntfKeyDown
    end
    object rbImpl: TRadioButton
      Left = 476
      Top = 11
      Width = 97
      Height = 17
      Caption = 'Implementation'
      TabOrder = 3
      OnDblClick = rbIntfDblClick
      OnKeyDown = rbImplKeyDown
    end
  end
  inherited lvList: TListView
    Width = 651
    Height = 361
    Columns = <
      item
        Caption = 'Unit'
        Width = 200
      end
      item
        Caption = 'Location'
        Width = 300
      end
      item
        Caption = 'Project'
        Width = 60
      end
      item
        Caption = 'File State'
        Width = 66
      end>
    MultiSelect = False
    OwnerData = True
    OnData = lvListData
  end
  inherited StatusBar: TStatusBar
    Top = 427
    Width = 651
    OnDrawPanel = StatusBarDrawPanel
  end
  inherited ToolBar: TToolBar
    Width = 651
  end
  inherited ActionList: TActionList
    inherited actOpen: TAction
      Caption = '&Use Unit'
      Hint = 'Use Selected Unit'
    end
    inherited actAttribute: TAction
      Hint = 'Show Property of Selected Unit File'
    end
    inherited actCopy: TAction
      Hint = 'Copy Selected Unit Name to Clipboard'
    end
    inherited actSelectAll: TAction
      Caption = 'Select A&ll Units'
      Hint = 'Select All Units'
    end
    inherited actMatchStart: TAction
      Caption = 'Match Unit Name &Start'
      Hint = 'Match Unit Name Start'
    end
    inherited actMatchAny: TAction
      Caption = 'Match &All Parts of Unit Name'
      Hint = 'Match All Parts of Unit Name'
    end
    inherited actHookIDE: TAction
      Hint = 'Hook Project Unit List to IDE'
    end
    inherited actQuery: TAction
      Enabled = False
      Hint = '&Prompt when Open More than ONE Unit'
    end
  end
end
