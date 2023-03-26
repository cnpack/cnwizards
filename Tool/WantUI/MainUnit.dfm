object MainForm: TMainForm
  Left = 192
  Top = 107
  Width = 716
  Height = 551
  ActiveControl = lvProjects
  Caption = 'Want UI'
  Color = clBtnFace
  Constraints.MinHeight = 483
  Constraints.MinWidth = 653
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object lvProjects: TListView
    Left = 8
    Top = 65
    Width = 692
    Height = 176
    Anchors = [akLeft, akTop, akRight]
    Color = 3815994
    Columns = <
      item
        Caption = 'Projects'
        Width = 170
      end
      item
        Caption = 'Discription'
        Width = 490
      end>
    ColumnClick = False
    Font.Charset = ANSI_CHARSET
    Font.Color = 15132390
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 7
    ViewStyle = vsReport
    OnDblClick = lvProjectsDblClick
    OnKeyPress = lvProjectsKeyPress
    OnResize = lvProjectsResize
  end
  object edtFileName: TEdit
    Left = 8
    Top = 8
    Width = 692
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    Color = 3815994
    Font.Charset = ANSI_CHARSET
    Font.Color = 15132390
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object btnBrowseXML: TButton
    Left = 104
    Top = 36
    Width = 89
    Height = 23
    Caption = '&XML File...'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = btnBrowseXMLClick
  end
  object btnBrowseWant: TButton
    Left = 8
    Top = 36
    Width = 89
    Height = 23
    Caption = '&Want File...'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btnBrowseWantClick
  end
  object btnLoadXML: TButton
    Left = 200
    Top = 36
    Width = 89
    Height = 23
    Caption = '&Load XML'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = btnLoadXMLClick
  end
  object btnBuild: TButton
    Left = 610
    Top = 36
    Width = 89
    Height = 23
    Anchors = [akTop, akRight]
    Caption = '&Build'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnClick = btnBuildClick
  end
  object statInfo: TStatusBar
    Left = 0
    Top = 503
    Width = 708
    Height = 21
    Panels = <
      item
        Width = 520
      end
      item
        Width = 50
      end>
    ParentFont = True
    SimplePanel = False
    UseSystemFont = False
  end
  object mmoInfo: TMemo
    Left = 8
    Top = 248
    Width = 692
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 3815994
    Font.Charset = ANSI_CHARSET
    Font.Color = 15132390
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 8
    WordWrap = False
  end
  object btnAbout: TButton
    Left = 514
    Top = 36
    Width = 89
    Height = 23
    Anchors = [akTop, akRight]
    Caption = '&About...'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = btnAboutClick
  end
  object cbbProperties: TComboBox
    Left = 296
    Top = 36
    Width = 145
    Height = 23
    ItemHeight = 15
    TabOrder = 4
  end
  object tmrBuild: TTimer
    OnTimer = tmrBuildTimer
    Left = 16
    Top = 96
  end
end
