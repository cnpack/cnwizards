inherited CnProjectUseUnitsForm: TCnProjectUseUnitsForm
  Left = 266
  Top = 79
  Caption = 'Use Unit'
  ClientHeight = 453
  ClientWidth = 732
  Constraints.MinHeight = 480
  Constraints.MinWidth = 740
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlHeader: TPanel
    Width = 732
    inherited lblProject: TLabel
      Left = 289
      Width = 36
      Caption = '&Add to:'
      FocusControl = nil
    end
    inherited edtMatchSearch: TEdit
      Width = 202
    end
    object rbIntf: TRadioButton [3]
      Left = 348
      Top = 12
      Width = 85
      Height = 17
      Caption = 'Interface'
      Checked = True
      TabOrder = 2
      TabStop = True
      OnDblClick = rbIntfDblClick
      OnKeyDown = rbIntfKeyDown
    end
    object rbImpl: TRadioButton [4]
      Left = 436
      Top = 11
      Width = 109
      Height = 17
      Caption = 'Implementation'
      TabOrder = 3
      OnDblClick = rbIntfDblClick
      OnKeyDown = rbImplKeyDown
    end
    inherited cbbProjectList: TComboBox
      Left = 544
      Width = 171
    end
  end
  inherited StatusBar: TStatusBar
    Top = 434
    Width = 732
    Panels = <
      item
        Style = psOwnerDraw
        Width = 400
      end
      item
        Text = 'Project Count: 1'
        Width = 110
      end
      item
        Text = 'Form Count: 1'
        Width = 110
      end>
    OnDrawPanel = StatusBarDrawPanel
  end
  inherited ToolBar: TToolBar
    Width = 732
  end
  inherited pnlMain: TPanel
    Width = 732
    Height = 368
    inherited lvList: TListView
      Width = 732
      Height = 368
      Columns = <
        item
          Caption = 'Unit'
          Width = 240
        end
        item
          Caption = 'Location'
          Width = 340
        end
        item
          Caption = 'Project'
          Width = 60
        end
        item
          Caption = 'File State'
          Width = 66
        end>
      OwnerData = True
      OnData = lvListData
    end
  end
  inherited ActionList: TActionList
    inherited actOpen: TAction
      Caption = '&Use Unit'
      Hint = 'Use Selected Unit'
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
      Enabled = False
      Hint = '&Prompt when Open More than ONE Unit'
      Visible = False
    end
  end
end
