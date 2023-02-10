inherited CnProjectListUsedForm: TCnProjectListUsedForm
  Left = 289
  Top = 188
  Caption = 'Used Unit List'
  ClientHeight = 386
  ClientWidth = 527
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000070
    0000000000000078888888888800007FBBBBBBBBB800007BF6666666B800007F
    BBBBBBBBB800007BF6666666B800007FBFBFBFBBB800007FF6666666B800007F
    FFBFBFBBB800007FF666FBFBB800007FFFFFB0000000007FFFFFF0BB0000007F
    FFFFF0B00000007FFFFFF000000000777777700000000000000000000000C001
    0000C0010000C0010000C0010000C0010000C0010000C0010000C0010000C001
    0000C0010000C0030000C0070000C00F0000C01F0000C03F0000FFFF0000}
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlHeader: TPanel
    Width = 527
    inherited lblProject: TLabel
      Visible = False
    end
    inherited edtMatchSearch: TEdit
      Width = 401
      Anchors = [akLeft, akTop, akRight]
    end
    inherited cbbProjectList: TComboBox
      Visible = False
    end
  end
  inherited StatusBar: TStatusBar
    Top = 367
    Width = 527
    Panels = <
      item
        Style = psOwnerDraw
        Width = 310
      end
      item
        Text = 'Unit: 1'
        Width = 110
      end>
  end
  inherited ToolBar: TToolBar
    Width = 527
    inherited btnSep1: TToolButton
      Visible = False
    end
    inherited btnAttribute: TToolButton
      Visible = False
    end
    inherited btnSep3: TToolButton
      Visible = False
    end
    inherited btnHookIDE: TToolButton
      Visible = False
    end
  end
  inherited pnlMain: TPanel
    Width = 527
    Height = 301
    inherited lvList: TListView
      Width = 527
      Height = 301
      Columns = <
        item
          Caption = 'Unit Name'
          Width = 350
        end
        item
          Caption = 'Uses Type'
          Width = 150
        end>
      OwnerData = True
      OnData = lvListData
    end
  end
  inherited ActionList: TActionList
    inherited actOpen: TAction
      Hint = 'Search and Open Selected Unit'
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
      Hint = 'Match Frame Name &Start'
    end
    inherited actMatchAny: TAction
      Caption = 'Match &All Parts of Unit Name'
      Hint = 'Match &All Parts of Unit Name'
    end
    inherited actHookIDE: TAction
      Caption = ''
      Hint = ''
    end
    inherited actQuery: TAction
      Caption = ''
      Hint = 'Prompt when Open More than ONE Unit.'
    end
    inherited actClose: TAction
      Caption = '&Exit'
    end
  end
end
