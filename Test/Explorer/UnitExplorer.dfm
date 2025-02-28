object Form5: TForm5
  Left = 337
  Top = 307
  Width = 682
  Height = 428
  Caption = 'Test Explorer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object CnShellTreeView1: TCnShellTreeView
    Left = 24
    Top = 24
    Width = 201
    Height = 353
    ObjectTypes = [otFolders]
    Root = 'rfDesktop'
    UseShellImages = True
    AutoRefresh = True
    Indent = 19
    ParentColor = False
    RightClickSelect = True
    ShowRoot = False
    TabOrder = 0
  end
  object CnShellListView1: TCnShellListView
    Left = 248
    Top = 24
    Width = 401
    Height = 353
    AutoRefresh = True
    ObjectTypes = [otFolders, otNonFolders]
    Root = 'rfDesktop'
    Sorted = True
    ReadOnly = False
    HideSelection = False
    TabOrder = 1
  end
end
