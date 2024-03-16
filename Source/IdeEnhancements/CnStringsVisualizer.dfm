inherited CnStringsViewerFrame: TCnStringsViewerFrame
  Width = 447
  Height = 231
  OnResize = FormResize
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 447
    Height = 231
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lvStrings: TListView
      Left = 0
      Top = 0
      Width = 447
      Height = 231
      Align = alClient
      Columns = <
        item
          Caption = '#'
          Width = 30
        end
        item
          Caption = 'Items'
          Width = 300
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
end
