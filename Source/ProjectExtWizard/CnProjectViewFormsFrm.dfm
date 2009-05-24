inherited CnProjectViewFormsForm: TCnProjectViewFormsForm
  Top = 200
  Caption = '工程组窗体列表'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited lvList: TListView
    Columns = <
      item
        Caption = '窗体'
        Width = 140
      end
      item
        Caption = '标题'
        Width = 130
      end
      item
        Caption = '类型'
        Width = 90
      end
      item
        Caption = '工程'
        Width = 100
      end
      item
        Alignment = taRightJustify
        Caption = '大小(Byte)'
        Width = 80
      end
      item
        Caption = '格式'
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
      Hint = '将所选二进制窗体转换为文本窗体'
      Caption = '转换为文本(&T)'
      ImageIndex = 46
      OnClick = tbnConvertToTextClick
    end
    object tbnConvertToBinary: TToolButton
      Left = 386
      Top = 0
      Hint = '将所选文本窗体转换为二进制窗体'
      Caption = '转换为二进制(&B)'
      ImageIndex = 64
      OnClick = tbnConvertToBinaryClick
    end
  end
end
