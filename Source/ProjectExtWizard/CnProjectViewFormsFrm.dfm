inherited CnProjectViewFormsForm: TCnProjectViewFormsForm
  Top = 200
  Caption = 'Form List of Project Group'
  ClientHeight = 478
  ClientWidth = 711
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlHeader: TPanel
    Width = 711
  end
  inherited StatusBar: TStatusBar
    Top = 459
    Width = 711
    OnDrawPanel = StatusBarDrawPanel
  end
  inherited ToolBar: TToolBar
    Width = 711
    object tbnSep2: TToolButton
      Left = 378
      Top = 0
      Width = 8
      Caption = 'tbnSep2'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object tbnConvertToText: TToolButton
      Left = 386
      Top = 0
      Hint = 'Convert Selected Binary Form to Text Form'
      Caption = 'Convert to &Text'
      ImageIndex = 46
      OnClick = tbnConvertToTextClick
    end
    object tbnConvertToBinary: TToolButton
      Left = 409
      Top = 0
      Hint = 'Convert Selected Text Form to Binary Form'
      Caption = 'Convert to &Binary'
      ImageIndex = 64
      OnClick = tbnConvertToBinaryClick
    end
  end
  inherited pnlMain: TPanel
    Width = 711
    Height = 393
    inherited lvList: TListView
      Width = 711
      Height = 393
      Columns = <
        item
          Caption = 'Form'
          Width = 160
        end
        item
          Caption = 'Caption'
          Width = 150
        end
        item
          Caption = 'Type'
          Width = 110
        end
        item
          Caption = 'Project'
          Width = 120
        end
        item
          Caption = 'Size(Byte)'
          Width = 80
        end
        item
          Caption = 'Format'
          Width = 62
        end>
      OwnerData = True
      OnData = lvListData
    end
  end
end
