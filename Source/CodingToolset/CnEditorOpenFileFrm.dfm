inherited CnEditorOpenFileForm: TCnEditorOpenFileForm
  Left = 283
  Top = 209
  Caption = 'File Search Result'
  PixelsPerInch = 96
  TextHeight = 13
  inherited StatusBar: TStatusBar
    Panels = <
      item
        Style = psOwnerDraw
        Width = 420
      end
      item
        Text = '0'
        Width = 110
      end>
    OnDrawPanel = StatusBarDrawPanel
  end
  inherited pnlMain: TPanel
    inherited lvList: TListView
      Columns = <
        item
          Caption = 'Unit'
          Width = 210
        end
        item
          AutoSize = True
          Caption = 'Path'
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
