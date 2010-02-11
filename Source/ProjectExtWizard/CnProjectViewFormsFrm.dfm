inherited CnProjectViewFormsForm: TCnProjectViewFormsForm
  Top = 200
  Caption = 'Form List of Project Group'
  PixelsPerInch = 96
  TextHeight = 13
  inherited lvList: TListView
    Columns = <
      item
        Caption = 'Form'
        Width = 140
      end
      item
        Caption = 'Caption'
        Width = 130
      end
      item
        Caption = 'Type'
        Width = 90
      end
      item
        Caption = 'Project'
        Width = 100
      end
      item
        Alignment = taRightJustify
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
  inherited StatusBar: TStatusBar
    OnDrawPanel = StatusBarDrawPanel
  end
  inherited ToolBar: TToolBar
    object tbnSep2: TToolButton
      Left = 355
      Top = 0
      Width = 8
      Caption = 'tbnSep2'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object tbnConvertToText: TToolButton
      Left = 363
      Top = 0
      Hint = 'Convert Selected Binary Form to Text Form'
      Caption = 'Convert to &Text'
      ImageIndex = 46
      OnClick = tbnConvertToTextClick
    end
    object tbnConvertToBinary: TToolButton
      Left = 386
      Top = 0
      Hint = 'Convert Selected Text Form to Binary Form'
      Caption = 'Convert to &Binary'
      ImageIndex = 64
      OnClick = tbnConvertToBinaryClick
    end
  end
end
