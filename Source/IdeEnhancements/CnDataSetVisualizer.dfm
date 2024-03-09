object CnDataSetViewerFrame: TCnDataSetViewerFrame
  Left = 0
  Top = 0
  Width = 598
  Height = 318
  TabOrder = 0
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 582
    Height = 302
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object pcViews: TPageControl
      AlignWithMargins = True
      Left = 1
      Top = 1
      Width = 580
      Height = 300
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      ActivePage = tsProp
      Align = alClient
      TabHeight = 24
      TabOrder = 0
      OnChange = pcViewsChange
      object tsProp: TTabSheet
        Caption = '&Property'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object mmoProp: TMemo
          Left = 0
          Top = 0
          Width = 572
          Height = 266
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
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object grdField: TStringGrid
          Left = 0
          Top = 0
          Width = 572
          Height = 266
          Align = alClient
          BorderStyle = bsNone
          ColCount = 18
          FixedRows = 0
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
      end
      object tsData: TTabSheet
        Caption = '&Data'
        ImageIndex = 3
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object grdData: TStringGrid
          Left = 0
          Top = 0
          Width = 572
          Height = 266
          Align = alClient
          BorderStyle = bsNone
          ColCount = 18
          FixedRows = 0
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
      end
    end
  end
end
