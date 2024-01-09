object CnDataSetViewerFrame: TCnDataSetViewerFrame
  Left = 0
  Top = 0
  Width = 547
  Height = 249
  TabOrder = 0
  object PCViews: TPageControl
    Left = 0
    Top = 0
    Width = 547
    Height = 249
    ActivePage = TabList
    Align = alClient
    TabOrder = 0
    OnChange = PCViewsChange
    object TabText: TTabSheet
      Caption = '&Properties'
      ImageIndex = 1
      object mmoDataSetProp: TMemo
        Left = 0
        Top = 0
        Width = 539
        Height = 221
        Align = alClient
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WantReturns = False
        WordWrap = False
        ExplicitLeft = -80
        ExplicitTop = 40
      end
    end
    object TabList: TTabSheet
      Caption = '&Data'
      object gridDataSet: TStringGrid
        Left = 0
        Top = 0
        Width = 539
        Height = 221
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 136
        ExplicitTop = 48
        ExplicitWidth = 320
        ExplicitHeight = 120
      end
    end
  end
end
