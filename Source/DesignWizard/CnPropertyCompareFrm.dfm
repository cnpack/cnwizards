inherited CnPropertyCompareForm: TCnPropertyCompareForm
  Left = 246
  Top = 70
  Width = 970
  Height = 665
  Caption = 'Compare Properties'
  Font.Name = 'MS Sans Serif'
  Menu = mmMain
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
      OnResize = pnlResize
      object gridLeft: TStringGrid
        Left = 0
        Top = 0
        Width = 465
        Height = 590
        Align = alClient
        ColCount = 2
        DefaultRowHeight = 18
        DefaultDrawing = False
        FixedRows = 0
        Options = [goColSizing, goRowSelect]
        ScrollBars = ssVertical
        TabOrder = 0
        OnDrawCell = gridDrawCell
        OnSelectCell = gridSelectCell
        OnTopLeftChanged = gridTopLeftChanged
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
      OnResize = pnlResize
      object gridRight: TStringGrid
        Left = 0
        Top = 0
        Width = 475
        Height = 590
        Align = alClient
        ColCount = 2
        DefaultRowHeight = 18
        DefaultDrawing = False
        FixedRows = 0
        Options = [goColSizing, goRowSelect]
        ScrollBars = ssVertical
        TabOrder = 0
        OnDrawCell = gridDrawCell
        OnSelectCell = gridSelectCell
        OnTopLeftChanged = gridTopLeftChanged
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
  object actlstPropertyCompare: TActionList
    Left = 32
    Top = 501
    object actExit: TAction
      Caption = 'actExit'
    end
    object actSelectLeft: TAction
      Caption = 'actSelectLeft'
      OnExecute = actSelectLeftExecute
    end
    object actSelectRight: TAction
      Caption = 'actSelectRight'
      OnExecute = actSelectRightExecute
    end
    object actPropertyToRight: TAction
      Caption = 'actPropertyToRight'
    end
    object actPropertyToLeft: TAction
      Caption = 'actPropertyToLeft'
    end
    object actRefresh: TAction
      Caption = 'actRefresh'
    end
    object actPrevDiff: TAction
      Caption = 'actPrevDiff'
    end
    object actNextDiff: TAction
      Caption = 'actNextDiff'
    end
  end
  object pmListView: TPopupMenu
    Left = 128
    Top = 501
  end
end
