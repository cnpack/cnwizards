object CnPropSheetForm: TCnPropSheetForm
  Left = 492
  Top = 220
  Width = 370
  Height = 521
  BorderStyle = bsSizeToolWin
  Caption = 'CnDebug Inspector'
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 362
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblClassName: TLabel
      Left = 168
      Top = 8
      Width = 44
      Height = 13
      Caption = 'Unknown'
    end
    object btnRefresh: TSpeedButton
      Left = 138
      Top = 4
      Width = 23
      Height = 22
      Hint = 'Refresh'
      Flat = True
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000C8D0D4C8D0D4
        C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0
        D4C8D0D4C8D0D4C8D0D4C8D0D4A37875A37875A37875A37875A37875A37875A3
        7875A37875A37875A37875A37875A3787590615EC8D0D4C8D0D4C8D0D4A67C76
        F2E2D3F2E2D3FFE8D1EFDFBBFFE3C5FFDEBDFFDDBAFFD8B2FFD6AEFFD2A5FFD2
        A3936460C8D0D4C8D0D4C8D0D4AB8078F3E7DAF3E7DA019901AFD8A071C57041
        AA3081BB5EEFD4A6FFD6AEFFD2A3FFD2A3966763C8D0D4C8D0D4C8D0D4B0837A
        F4E9DDF4E9DD01990101990101990101990101990141AA2FFFD8B2FFD4A9FFD4
        A99A6A65C8D0D4C8D0D4C8D0D4B6897DF5EDE4F5EDE4019901019901119E0ECF
        D6A3FFE4C821A21AFFD8B2FFD7B0FFD7B09E6D67C8D0D4C8D0D4C8D0D4BC8E7F
        F7EFE8F7EFE8019901019901019901019901FFE4C8EFDEBAFFD8B2FFD7B0FFD9
        B4A27069C8D0D4C8D0D4C8D0D4C39581F8F3EFF8F3EFF8F3EFFFF4E8FFF4E8FF
        F4E8EFE3C4EFE3C4FFE4C8FFDEBDFFDDBBA5746BC8D0D4C8D0D4C8D0D4CA9B84
        F9F5F2FBFBFBFFF4E8FFF4E8FFF4E8019901019901019901FFE8D1FFE3C5FFE1
        C2A8776DC8D0D4C8D0D4C8D0D4D2A187F9F9F9FBFBFB119F10AFD8A0FFF4E8AF
        D8A0019901019901FFE8D1FFE4C8FFE3C6AC7A6FC8D0D4C8D0D4C8D0D4D9A88A
        FBFBFBFFFFFF71C570019901019901019901019901019901FFE8D1FFE8D1FFE6
        CEAE7C72C8D0D4C8D0D4C8D0D4DFAE8CFCFCFCFFFFFFFFFFFF71C57001990101
        9901AFD8A0019901FFE8D1FFC8C2FFB0B0B07E73C8D0D4C8D0D4C8D0D4E5B38F
        FDFDFDFDFDFDFFFFFFFFFFFFFFFFFEFFFAF6FFF9F3FFF5EAF4DECEB28074B280
        74B28074C8D0D4C8D0D4C8D0D4EAB891FEFEFEFEFEFEFFFFFFFFFFFFFFFFFFFF
        FFFEFFFAF6FFF9F3F5E1D2B28074EDA755CAA38FC8D0D4C8D0D4C8D0D4EFBC92
        FFFFFFFFFFFFFCFCFCFAFAFAF7F7F7F5F5F5F2F1F1F0EDEAE9DAD0B28074D1AA
        92C9CECFC8D0D4C8D0D4C8D0D4F2BF94DCA987DCA987DCA987DCA987DCA987DC
        A987DCA987DCA987DCA987B28074CACECFC8D0D4C8D0D4C8D0D4}
      ParentShowHint = False
      ShowHint = True
      OnClick = btnRefreshClick
    end
    object btnTop: TSpeedButton
      Left = 340
      Top = 5
      Width = 16
      Height = 21
      Hint = 'Always On Top'
      AllowAllUp = True
      Anchors = [akTop, akRight]
      GroupIndex = 1
      Caption = '^'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = btnTopClick
    end
    object lblDollar: TLabel
      Left = 4
      Top = 8
      Width = 6
      Height = 13
      Caption = '$'
    end
    object btnEvaluate: TSpeedButton
      Left = 114
      Top = 4
      Width = 23
      Height = 22
      Hint = 'Evaluate Address'
      Flat = True
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000C8D0D4C8D0D4
        C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0
        D4C8D0D4C8D0D4C8D0D4C8D0D484848400000000000000000000000000000000
        0000000000000000000000000000000000C8D0D4C8D0D4C8D0D4C8D0D4848484
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
        00C8D0D4C8D0D4C8D0D4C8D0D4848484FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFF000000C8D0D4C8D0D4C8D0D4C8D0D4848484
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC6C6C6000000000000FFFFFFFFFFFF0000
        00C8D0D4C8D0D4C8D0D4C8D0D4848484FFFFFFFFFFFFFFFFFFFFFFFF84848400
        0000000000000000FFFFFFFFFFFF000000C8D0D4C8D0D4C8D0D4C8D0D4848484
        FFFFFFFFFFFFFFFFFF848484000000000000000000000000000000FFFFFF0000
        00C8D0D4C8D0D4C8D0D4C8D0D4848484FFFFFFFFFFFFFFFFFF00000000000000
        0000FFFFFF000000000000FFFFFF848484C8D0D4C8D0D4C8D0D4C8D0D4848484
        FFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFFFF000000000000C8D0
        D4C8D0D4C8D0D4C8D0D4C8D0D4848484FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFF000000000000C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4848484
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
        00C8D0D4C8D0D4C8D0D4C8D0D4848484FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFF848484848484C6C6C6000000000000C8D0D4C8D0D4C8D0D4848484
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF848484FFFFFF848484C8D0
        D4000000000000C8D0D4C8D0D4848484FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFF848484848484C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4848484
        848484848484848484848484848484848484848484848484C8D0D4C8D0D4C8D0
        D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8
        D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4}
      ParentShowHint = False
      ShowHint = True
      OnClick = btnEvaluateClick
    end
    object edtObj: TEdit
      Left = 14
      Top = 5
      Width = 97
      Height = 21
      Hint = 'Object Address'
      TabOrder = 0
      Text = '00000000'
      OnKeyPress = edtObjKeyPress
    end
  end
  object tsSwitch: TTabSet
    Left = 0
    Top = 473
    Width = 362
    Height = 21
    Align = alBottom
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Tabs.Strings = (
      'Properties'
      'Events'
      'Strings'
      'CollectionItems'
      'Components'
      'Controls'
      'Hierarchy')
    TabIndex = 0
    OnChange = tsSwitchChange
  end
  object pnlMain: TPanel
    Left = 0
    Top = 30
    Width = 362
    Height = 443
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object lvProp: TListView
      Left = 8
      Top = 0
      Width = 321
      Height = 57
      Columns = <
        item
          Caption = 'Property Name'
          Width = 130
        end
        item
          Caption = 'Property Value'
          Width = 180
        end>
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      TabOrder = 0
      ViewStyle = vsReport
      OnCustomDrawItem = lvPropCustomDrawItem
      OnCustomDrawSubItem = lvPropCustomDrawSubItem
      OnSelectItem = lvPropSelectItem
    end
    object mmoText: TMemo
      Left = 96
      Top = 352
      Width = 185
      Height = 49
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
    end
    object lvEvent: TListView
      Left = 8
      Top = 64
      Width = 321
      Height = 57
      Columns = <
        item
          Caption = 'Event'
          Width = 130
        end
        item
          Caption = 'Handler'
          Width = 180
        end>
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      ShowWorkAreas = True
      TabOrder = 2
      ViewStyle = vsReport
      OnCustomDrawItem = lvPropCustomDrawItem
      OnCustomDrawSubItem = lvPropCustomDrawSubItem
      OnSelectItem = lvPropSelectItem
    end
    object pnlInspectBtn: TPanel
      Left = 10
      Top = 10
      Width = 22
      Height = 22
      AutoSize = True
      BevelOuter = bvNone
      TabOrder = 3
      object btnInspect: TSpeedButton
        Left = 0
        Top = 0
        Width = 22
        Height = 22
        Caption = '?'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -8
        Font.Name = 'Small Fonts'
        Font.Style = []
        ParentFont = False
        OnClick = btnInspectClick
      end
    end
    object lvCollectionItem: TListView
      Left = 8
      Top = 136
      Width = 321
      Height = 57
      Columns = <
        item
          Caption = 'Items[]'
          Width = 180
        end
        item
          Caption = 'Item Value'
          Width = 130
        end>
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      ShowWorkAreas = True
      TabOrder = 4
      ViewStyle = vsReport
      OnCustomDrawItem = lvPropCustomDrawItem
      OnCustomDrawSubItem = lvPropCustomDrawSubItem
      OnSelectItem = lvPropSelectItem
    end
    object lvComp: TListView
      Left = 8
      Top = 208
      Width = 321
      Height = 57
      Columns = <
        item
          Caption = 'Components[]'
          Width = 150
        end
        item
          Caption = 'Component'
          Width = 180
        end>
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      TabOrder = 5
      ViewStyle = vsReport
      OnCustomDrawItem = lvPropCustomDrawItem
      OnCustomDrawSubItem = lvPropCustomDrawSubItem
      OnSelectItem = lvPropSelectItem
    end
    object lvControl: TListView
      Left = 8
      Top = 280
      Width = 321
      Height = 57
      Columns = <
        item
          Caption = 'Controls[]'
          Width = 130
        end
        item
          Caption = 'Control'
          Width = 180
        end>
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      TabOrder = 6
      ViewStyle = vsReport
      OnCustomDrawItem = lvPropCustomDrawItem
      OnCustomDrawSubItem = lvPropCustomDrawSubItem
      OnSelectItem = lvPropSelectItem
    end
    object pnlHierarchy: TPanel
      Left = 0
      Top = 0
      Width = 362
      Height = 443
      Align = alClient
      BevelInner = bvLowered
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 7
      object bvlLine: TBevel
        Left = 96
        Top = 0
        Width = 17
        Height = 50
        Shape = bsLeftLine
      end
    end
  end
end
