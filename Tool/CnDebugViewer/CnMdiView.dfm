object CnMsgChild: TCnMsgChild
  Left = 102
  Top = 203
  ActiveControl = cbbSearch
  Align = alClient
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsNone
  ClientHeight = 382
  ClientWidth = 768
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object splDetail: TSplitter
    Left = 0
    Top = 295
    Width = 768
    Height = 3
    Cursor = crVSplit
    Align = alBottom
  end
  object splTime: TSplitter
    Left = 590
    Top = 0
    Height = 295
    Align = alRight
  end
  object pnlTime: TPanel
    Left = 593
    Top = 0
    Width = 175
    Height = 295
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
  end
  object pnlTree: TPanel
    Left = 0
    Top = 0
    Width = 590
    Height = 295
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlFilter: TPanel
      Left = 0
      Top = 0
      Width = 590
      Height = 23
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Splitter3: TSplitter
        Left = 318
        Top = 0
        Height = 23
        Visible = False
      end
      object Splitter4: TSplitter
        Left = 374
        Top = 0
        Height = 23
        Visible = False
      end
      object Splitter5: TSplitter
        Left = 457
        Top = 0
        Height = 23
        Visible = False
      end
      object pnlLevel: TPanel
        Left = 321
        Top = 0
        Width = 53
        Height = 23
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 3
        OnResize = HeadPanelResize
        object cbbLevel: TComboBox
          Left = 0
          Top = 0
          Width = 49
          Height = 21
          Hint = 'Filter by Level'
          Style = csDropDownList
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = FilterChange
        end
      end
      object pnlThread: TPanel
        Left = 377
        Top = 0
        Width = 80
        Height = 23
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 4
        OnResize = HeadPanelResize
        object cbbThread: TComboBox
          Left = 0
          Top = 0
          Width = 81
          Height = 21
          Hint = 'Filter by Thread'
          Style = csDropDownList
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = FilterChange
        end
      end
      object pnlMsg: TPanel
        Left = 33
        Top = 0
        Width = 208
        Height = 23
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          208
          23)
        object btnSearch: TSpeedButton
          Left = 178
          Top = 0
          Width = 23
          Height = 22
          Hint = 'Search Text'
          Anchors = [akTop, akRight]
          Flat = True
          Glyph.Data = {
            36040000424D3604000000000000360000002800000010000000100000000100
            2000000000000004000000000000000000000000000000000000FF00FF004A63
            7B00BD949400FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF006B9CC600188C
            E7004A7BA500C6949400FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF004AB5FF0052B5
            FF00218CEF004A7BA500C6949400FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0052B5
            FF0052B5FF001884E7004A7BA500C6949400FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF0052B5FF004AB5FF00188CE7004A7BA500BD949400FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF0052B5FF004AB5FF002184DE005A6B7300FF00FF00AD7B7300C6A5
            9C00D6B5A500CEA59C00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF0052BDFF00B5D6EF00A5948C00B59C8C00F7E7CE00FFFF
            D600FFFFD600FFFFD600E7DEBD00CEADA500FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00CEB5B500D6B5A500FFEFC600FFFFD600FFFF
            D600FFFFD600FFFFDE00FFFFEF00F7F7EF00B58C8C00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00C6948C00F7DEB500F7D6A500FFF7CE00FFFF
            D600FFFFDE00FFFFEF00FFFFF700FFFFFF00DED6BD00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00DEBDA500FFE7AD00F7CE9400FFF7CE00FFFF
            DE00FFFFE700FFFFF700FFFFF700FFFFEF00F7EFD600C69C9400FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00E7C6AD00FFDEAD00EFBD8400F7E7B500FFFF
            D600FFFFDE00FFFFE700FFFFE700FFFFDE00F7F7D600C6AD9C00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00DEBDAD00FFE7B500EFBD8400F7CE9400FFEF
            C600FFFFDE00FFFFDE00FFFFDE00FFFFDE00F7EFD600C6A59C00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00C69C9400FFEFC600FFEFC600F7D6A500F7CE
            9C00F7E7B500FFF7CE00FFF7D600FFFFD600E7DEBD00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00DEC6AD00FFFFFF00FFF7EF00F7CE
            9400EFBD8400F7CE9C00FFE7B500FFF7C600BD9C8C00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00D6BDBD00F7EFD600FFEF
            C600FFE7AD00FFE7B500F7DEB500CEAD9C00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00CEAD9400CEAD
            9C00DEBDA500DEBDA500FF00FF00FF00FF00FF00FF00FF00FF00}
          ParentShowHint = False
          ShowHint = True
          OnClick = btnSearchClick
        end
        object cbbSearch: TComboBox
          Left = 8
          Top = 0
          Width = 169
          Height = 21
          Hint = 'Enter Words and Press Enter to Search'
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnKeyPress = cbbSearchKeyPress
        end
      end
      object pnlType: TPanel
        Left = 241
        Top = 0
        Width = 77
        Height = 23
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 2
        OnResize = HeadPanelResize
        object cbbType: TComboBox
          Left = 0
          Top = 0
          Width = 73
          Height = 21
          Hint = 'Filter by Type'
          Style = csDropDownList
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = FilterChange
        end
      end
      object pnlLabel: TPanel
        Left = 0
        Top = 0
        Width = 33
        Height = 23
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 6
          Top = 3
          Width = 20
          Height = 13
          Caption = 'Find'
        end
      end
      object pnlTag: TPanel
        Left = 460
        Top = 0
        Width = 80
        Height = 23
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 5
        OnResize = HeadPanelResize
        object cbbTag: TComboBox
          Left = 0
          Top = 0
          Width = 81
          Height = 21
          Hint = 'Filter by Tag'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = FilterChange
        end
      end
      object tlbBookmark: TToolBar
        Left = 554
        Top = 0
        Width = 36
        Height = 23
        Align = alRight
        Caption = 'tlbBookmark'
        Images = CnMainViewer.ilMain
        TabOrder = 6
        object btnBookmark: TToolButton
          Left = 0
          Top = 2
          ImageIndex = 82
          MenuItem = MenuDropBookmark
          ParentShowHint = False
          ShowHint = True
          Style = tbsDropDown
        end
      end
    end
  end
  object pnlDetail: TPanel
    Left = 0
    Top = 298
    Width = 768
    Height = 84
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object mmoDetail: TMemo
      Left = 0
      Top = 0
      Width = 768
      Height = 84
      Hint = 'Detailed Display'
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ReadOnly = True
      ScrollBars = ssVertical
      ShowHint = False
      TabOrder = 0
    end
  end
  object pmTree: TPopupMenu
    Images = CnMainViewer.ilMain
    OnPopup = pmTreePopup
    Left = 144
    Top = 136
    object C1: TMenuItem
      Action = CnMainViewer.actCopy
    end
    object CopyText1: TMenuItem
      Action = CnMainViewer.actCopyText
    end
    object SaveMemDump1: TMenuItem
      Action = CnMainViewer.actSaveMemDump
    end
    object A1: TMenuItem
      Action = CnMainViewer.actSelAll
    end
    object E1: TMenuItem
      Action = CnMainViewer.actExpandAll
    end
    object D1: TMenuItem
      Action = CnMainViewer.actClear
    end
    object B1: TMenuItem
      Action = CnMainViewer.actBookmark
    end
    object MenuDropBookmark: TMenuItem
      ImageIndex = 82
    end
    object S1: TMenuItem
      Action = CnMainViewer.actPrevBookmark
    end
    object X1: TMenuItem
      Action = CnMainViewer.actNextBookmark
    end
    object M1: TMenuItem
      Action = CnMainViewer.actClearBookmarks
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object F1: TMenuItem
      Action = CnMainViewer.actFind
    end
    object N2: TMenuItem
      Action = CnMainViewer.actFindNext
    end
  end
end
