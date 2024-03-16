inherited CnDataSetViewerFrame: TCnDataSetViewerFrame
  Width = 598
  Height = 318
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 598
    Height = 318
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pcViews: TPageControl
      Left = 0
      Top = 0
      Width = 598
      Height = 318
      ActivePage = tsProp
      Align = alClient
      TabHeight = 24
      TabOrder = 0
      OnChange = pcViewsChange
      object tsProp: TTabSheet
        Caption = '&Property'
        ImageIndex = 1
        object mmoProp: TMemo
          Left = 0
          Top = 0
          Width = 590
          Height = 284
          Align = alClient
          BorderStyle = bsNone
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
          WantReturns = False
        end
      end
      object tsField: TTabSheet
        Caption = '&Field'
        ImageIndex = 2
        object grdField: TStringGrid
          Left = 0
          Top = 0
          Width = 590
          Height = 284
          Align = alClient
          BorderStyle = bsNone
          ColCount = 18
          FixedRows = 0
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
          ParentFont = False
          TabOrder = 0
        end
      end
      object tsData: TTabSheet
        Caption = '&Data'
        ImageIndex = 3
        object grdData: TStringGrid
          Left = 0
          Top = 0
          Width = 590
          Height = 284
          Align = alClient
          BorderStyle = bsNone
          ColCount = 18
          FixedRows = 0
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
          ParentFont = False
          TabOrder = 0
        end
      end
    end
  end
end
