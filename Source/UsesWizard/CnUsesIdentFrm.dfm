inherited CnUsesIdentForm: TCnUsesIdentForm
  Caption = 'Search Identifier in Units to Use'
  ClientHeight = 491
  ClientWidth = 730
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlHeader: TPanel
    Width = 730
    inherited lblProject: TLabel
      Left = 631
      Visible = False
    end
    object lblAddTo: TLabel [2]
      Left = 329
      Top = 12
      Width = 36
      Height = 13
      Caption = '&Add to:'
    end
    inherited edtMatchSearch: TEdit
      AutoSelect = False
    end
    inherited cbbProjectList: TComboBox
      Left = 672
      Width = 51
      Visible = False
    end
    object rbImpl: TRadioButton
      Left = 476
      Top = 11
      Width = 109
      Height = 17
      Caption = 'Implementation'
      TabOrder = 3
      OnDblClick = rbIntfDblClick
    end
    object rbIntf: TRadioButton
      Left = 388
      Top = 12
      Width = 85
      Height = 17
      Caption = 'Interface'
      Checked = True
      TabOrder = 2
      TabStop = True
      OnDblClick = rbIntfDblClick
    end
  end
  inherited StatusBar: TStatusBar
    Top = 472
    Width = 730
    Panels = <
      item
        Style = psOwnerDraw
        Width = 340
      end
      item
        Width = 110
      end>
  end
  inherited ToolBar: TToolBar
    Width = 730
    inherited btnSep3: TToolButton
      Visible = False
    end
    inherited btnSep4: TToolButton
      Visible = False
    end
  end
  inherited pnlMain: TPanel
    Width = 730
    Height = 406
    inherited lvList: TListView
      Width = 730
      Height = 406
      Columns = <
        item
          Caption = 'Identifier'
          Width = 220
        end
        item
          Caption = 'Unit'
          Width = 160
        end
        item
          Caption = 'Path'
          Width = 320
        end>
      MultiSelect = False
      OwnerData = True
      OnData = lvListData
    end
  end
  inherited ActionList: TActionList
    inherited actOpen: TAction
      Caption = '&Use'
      Hint = 'Use Selected Unit'
    end
    inherited actAttribute: TAction
      Visible = False
    end
    inherited actCopy: TAction
      Hint = 'Copy Selected Unit Name to Clipboard'
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
      Caption = 'Match Identifier &Start'
      Hint = 'Match Identifier Start'
    end
    inherited actMatchAny: TAction
      Caption = 'Match &All Parts of Identifier'
      Hint = 'Match All Parts of Identifier'
    end
    inherited actMatchFuzzy: TAction
      Hint = 'Fuzzy Match of Identifier'
    end
    inherited actHookIDE: TAction
      Visible = False
    end
    inherited actQuery: TAction
      Visible = False
    end
  end
end
