object CnWatchForm: TCnWatchForm
  Left = 458
  Top = 286
  Width = 378
  Height = 303
  BorderStyle = bsSizeToolWin
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lvWatch: TListView
    Left = 0
    Top = 0
    Width = 370
    Height = 276
    Align = alClient
    Columns = <
      item
        Caption = 'Watch'
        Width = 100
      end
      item
        Caption = 'Value'
        Width = 250
      end>
    GridLines = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnData = lvWatchData
  end
end
