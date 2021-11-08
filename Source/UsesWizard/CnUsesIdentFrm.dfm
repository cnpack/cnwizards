inherited CnUsesIdentForm: TCnUsesIdentForm
  Caption = 'Search Identifier in Units to Uses'
  ClientHeight = 491
  ClientWidth = 730
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlHeader: TPanel
    Width = 730
  end
  inherited lvList: TListView
    Width = 730
    Height = 406
    Columns = <
      item
        Caption = 'Identifier'
        Width = 210
      end
      item
        Caption = 'Unit'
        Width = 140
      end
      item
        Caption = 'Path'
        Width = 260
      end
      item
        Caption = 'Project'
        Width = 90
      end>
    OwnerData = True
    OnData = lvListData
  end
  inherited StatusBar: TStatusBar
    Top = 472
    Width = 730
  end
  inherited ToolBar: TToolBar
    Width = 730
  end
end
