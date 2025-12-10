inherited CnProjectViewUnitsForm: TCnProjectViewUnitsForm
  Left = 288
  Top = 219
  Caption = 'Unit List of Project Group'
  ClientHeight = 471
  ClientWidth = 705
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlHeader: TPanel
    Width = 705
  end
  inherited StatusBar: TStatusBar
    Top = 452
    Width = 705
    OnDrawPanel = StatusBarDrawPanel
  end
  inherited ToolBar: TToolBar
    Width = 705
  end
  inherited pnlMain: TPanel
    Width = 705
    Height = 386
    inherited lvList: TListView
      Width = 705
      Height = 386
      Columns = <
        item
          Caption = 'Unit'
          Width = 225
        end
        item
          Caption = 'Type'
          Width = 100
        end
        item
          Caption = 'Project'
          Width = 145
        end
        item
          Caption = 'Size(Byte)'
          Width = 80
        end
        item
          Caption = 'File State'
          Width = 125
        end>
      OwnerData = True
      OnData = lvListData
    end
  end
  inherited ActionList: TActionList
    inherited actOpen: TAction
      Hint = 'Open Selected Unit'
    end
    inherited actAttribute: TAction
      Hint = 'Show Attribute of Selected Unit File'
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
      Caption = '&Prompt when Open More than ONE Unit'
      Hint = 'Prompt when Open More than ONE Unit'
    end
  end
end
