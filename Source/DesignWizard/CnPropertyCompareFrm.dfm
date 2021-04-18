inherited CnPropertyCompareForm: TCnPropertyCompareForm
  Left = 246
  Top = 112
  Width = 970
  Height = 665
  Caption = 'Compare Properties'
  Font.Name = 'MS Sans Serif'
  Menu = mmMain
  OldCreateOrder = True
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object tlbMain: TToolBar
    Left = 0
    Top = 0
    Width = 962
    Height = 29
    Caption = 'tlbMain'
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Caption = 'ToolButton1'
      ImageIndex = 0
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 29
    Width = 962
    Height = 590
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlMain'
    TabOrder = 0
    object spl2: TSplitter
      Left = 465
      Top = 0
      Width = 3
      Height = 590
      Cursor = crHSplit
    end
    object pnlLeft: TPanel
      Left = 0
      Top = 0
      Width = 465
      Height = 590
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object lvLeft: TListView
        Left = 0
        Top = 0
        Width = 465
        Height = 590
        Align = alClient
        Columns = <
          item
            Caption = 'Properties'
            Width = 120
          end
          item
            AutoSize = True
            Caption = 'Values'
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnChange = ListViewChange
      end
    end
    object pnlRight: TPanel
      Left = 468
      Top = 0
      Width = 475
      Height = 590
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object lvRight: TListView
        Left = 0
        Top = 0
        Width = 475
        Height = 590
        Align = alClient
        Columns = <
          item
            Caption = 'Properties'
            Width = 120
          end
          item
            AutoSize = True
            Caption = 'Values'
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnChange = ListViewChange
      end
    end
    object pnlDisplay: TPanel
      Left = 943
      Top = 0
      Width = 19
      Height = 590
      Align = alRight
      BevelInner = bvRaised
      BevelOuter = bvLowered
      TabOrder = 2
      Visible = False
      object pbFile: TPaintBox
        Left = 8
        Top = 2
        Width = 9
        Height = 586
        Align = alClient
        Color = clBtnFace
        ParentColor = False
      end
      object pbPos: TPaintBox
        Left = 2
        Top = 2
        Width = 6
        Height = 586
        Align = alLeft
        Color = clBtnFace
        ParentColor = False
      end
    end
  end
  object mmMain: TMainMenu
    Left = 56
    Top = 56
    object File1: TMenuItem
      Caption = '&File'
      object Exit1: TMenuItem
        Caption = '&Exit'
      end
    end
  end
end
