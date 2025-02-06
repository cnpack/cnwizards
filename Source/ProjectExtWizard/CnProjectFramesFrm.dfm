inherited CnProjectFramesForm: TCnProjectFramesForm
  Left = 336
  Top = 119
  Caption = 'Select Frame to Insert'
  ClientWidth = 606
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    00000000000070000000000000007BBBBBBBBBBBBB007F07777777777B007F0B
    FBFBBBBB7B007F0FBF44444B7B007F0BFFFBFBBB7B007F0FF44444BB7B007F0F
    FBFFFBFB7B007F0F44444FBF7B007F0FFFFBFBFB7B007F00000000000B007FFF
    FFFFFFFFFB0074444444444444007F444444444F4F007777777777777770FFFF
    0000000100000001000000010000000100000001000000010000000100000001
    000000010000000100000001000000010000000100000001000000010000}
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlHeader: TPanel
    Width = 606
  end
  inherited StatusBar: TStatusBar
    Width = 606
  end
  inherited ToolBar: TToolBar
    Width = 606
    inherited btnSep5: TToolButton
      Visible = False
    end
    inherited tbnSep2: TToolButton
      Visible = False
    end
    inherited tbnConvertToText: TToolButton
      Visible = False
    end
    inherited tbnConvertToBinary: TToolButton
      Visible = False
    end
  end
  inherited pnlMain: TPanel
    Width = 606
    inherited lvList: TListView
      Width = 606
      Columns = <
        item
          Caption = 'Frame Name'
          Width = 210
        end
        item
          Caption = 'Type'
          Width = 90
        end
        item
          Caption = 'Project'
          Width = 130
        end
        item
          Alignment = taRightJustify
          Caption = 'Size(Byte)'
          Width = 100
        end
        item
          Caption = 'Format'
          Width = 72
        end>
      MultiSelect = False
    end
  end
  inherited ActionList: TActionList
    inherited actOpen: TAction
      Hint = 'Add Selected Frame to Form'
    end
    inherited actAttribute: TAction
      Hint = 'Show Attribute of Selected Frame File'
    end
    inherited actCopy: TAction
      Hint = 'Copy Selected Frame Name to Clipboard'
    end
    inherited actSelectAll: TAction
      Caption = ''
      Hint = 'Select All Units'
      Visible = False
    end
    inherited actSelectNone: TAction
      Visible = False
    end
    inherited actSelectInvert: TAction
      Visible = False
    end
    inherited actMatchStart: TAction
      Caption = 'Match Frame Name &Start'
      Hint = 'Match Frame Name &Start'
    end
    inherited actMatchAny: TAction
      Hint = 'Match All Parts of Frame Name'
    end
    inherited actHookIDE: TAction
      Visible = False
    end
    inherited actQuery: TAction
      Visible = False
    end
    inherited actClose: TAction
      Caption = '&Exit'
    end
  end
end
