inherited CnWideViewerFrame: TCnWideViewerFrame
  Width = 623
  Height = 231
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 623
    Height = 231
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pgcView: TPageControl
      Left = 0
      Top = 0
      Width = 623
      Height = 231
      ActivePage = tsHex
      Align = alClient
      TabOrder = 0
      object tsHex: TTabSheet
        Caption = '&Hex'
      end
      object tsWide: TTabSheet
        Caption = '&WideString'
        ImageIndex = 1
        object mmoWide: TMemo
          Left = 0
          Top = 0
          Width = 615
          Height = 203
          Align = alClient
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
    end
  end
end
