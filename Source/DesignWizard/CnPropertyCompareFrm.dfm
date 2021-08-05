inherited CnPropertyCompareForm: TCnPropertyCompareForm
  Left = 227
  Top = 150
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
    BorderWidth = 1
    Caption = 'tlbMain'
    EdgeBorders = [ebLeft, ebTop, ebRight]
    Flat = True
    Images = dmCnSharedImages.Images
    TabOrder = 1
    object btnNewCompare: TToolButton
      Left = 0
      Top = 0
      Action = actNewCompare
    end
    object btnRefresh: TToolButton
      Left = 23
      Top = 0
      Action = actRefresh
    end
    object btn1: TToolButton
      Left = 46
      Top = 0
      Width = 8
      Caption = 'btn1'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object btnSelectLeft: TToolButton
      Left = 54
      Top = 0
      Action = actSelectLeft
    end
    object btnSelectRight: TToolButton
      Left = 77
      Top = 0
      Action = actSelectRight
    end
    object btn2: TToolButton
      Left = 100
      Top = 0
      Width = 8
      Caption = 'btn2'
      ImageIndex = 99
      Style = tbsSeparator
    end
    object btnPropertyToLeft: TToolButton
      Left = 108
      Top = 0
      Action = actPropertyToLeft
    end
    object btnPropertyToRight: TToolButton
      Left = 131
      Top = 0
      Action = actPropertyToRight
    end
    object btnAllToLeft: TToolButton
      Left = 154
      Top = 0
      Action = actAllToLeft
    end
    object btnAllToRight: TToolButton
      Left = 177
      Top = 0
      Action = actAllToRight
    end
    object btn7: TToolButton
      Left = 200
      Top = 0
      Width = 8
      Caption = 'btn7'
      ImageIndex = 103
      Style = tbsSeparator
    end
    object btnPrevDiff: TToolButton
      Left = 208
      Top = 0
      Action = actPrevDiff
    end
    object btnNextDiff: TToolButton
      Left = 231
      Top = 0
      Action = actNextDiff
    end
    object btn3: TToolButton
      Left = 254
      Top = 0
      Width = 8
      Caption = 'btn3'
      ImageIndex = 46
      Style = tbsSeparator
    end
    object btnHelp: TToolButton
      Left = 262
      Top = 0
      Action = actHelp
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
        PopupMenu = pmGrid
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
        PopupMenu = pmGrid
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
    Images = dmCnSharedImages.Images
    Left = 56
    Top = 56
    object File1: TMenuItem
      Caption = '&File'
      object actNewCompare1: TMenuItem
        Action = actNewCompare
      end
      object Refresh1: TMenuItem
        Action = actRefresh
      end
      object Exit1: TMenuItem
        Action = actExit
      end
    end
    object Select1: TMenuItem
      Caption = '&Select'
      object SelectLeftComponent1: TMenuItem
        Action = actSelectLeft
      end
      object SelectRight1: TMenuItem
        Action = actSelectRight
      end
    end
    object Assign1: TMenuItem
      Caption = '&Property'
      object actPropertyToLeft1: TMenuItem
        Action = actPropertyToLeft
      end
      object actPropertyToRight1: TMenuItem
        Action = actPropertyToRight
      end
      object AllToLeft1: TMenuItem
        Action = actAllToLeft
      end
      object AllToRight1: TMenuItem
        Action = actAllToRight
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object PreviousDifferent1: TMenuItem
        Action = actPrevDiff
      end
      object NextDifferent1: TMenuItem
        Action = actNextDiff
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object Help2: TMenuItem
        Action = actHelp
      end
    end
  end
  object actlstPropertyCompare: TActionList
    Images = dmCnSharedImages.Images
    Left = 32
    Top = 501
    object actExit: TAction
      Caption = 'E&xit'
      Hint = 'Exit'
      ImageIndex = 0
      OnExecute = actExitExecute
    end
    object actSelectLeft: TAction
      Caption = 'Select &Left Component...'
      Hint = 'Select Left Component from Current Designer to Compare'
      ImageIndex = 97
      OnExecute = actSelectLeftExecute
    end
    object actSelectRight: TAction
      Caption = 'Select &Right Component...'
      Hint = 'Select Right Component from Current Designer to Compare'
      ImageIndex = 98
      OnExecute = actSelectRightExecute
    end
    object actPropertyToLeft: TAction
      Caption = 'To Left'
      Hint = 'Assign Selected Right Property to Left'
      ImageIndex = 99
      OnExecute = actPropertyToLeftExecute
    end
    object actPropertyToRight: TAction
      Caption = 'To Right'
      Hint = 'Assign Selected Left Property to Right'
      ImageIndex = 100
      OnExecute = actPropertyToRightExecute
    end
    object actRefresh: TAction
      Caption = '&Refresh'
      Hint = 'Refresh Properties'
      ImageIndex = 64
      OnExecute = actRefreshExecute
    end
    object actPrevDiff: TAction
      Caption = '&Previous Different'
      Hint = 'Go to Previous Different Property'
      ImageIndex = 44
    end
    object actNextDiff: TAction
      Caption = '&Next Different'
      Hint = 'Go to Next Different Property'
      ImageIndex = 45
    end
    object actNewCompare: TAction
      Caption = '&New Compare...'
      Hint = 'Open an Empty Compare Window'
      ImageIndex = 12
      OnExecute = actNewCompareExecute
    end
    object actCompareObjProp: TAction
      Caption = 'actCompareObjProp'
      ImageIndex = 43
    end
    object actAllToLeft: TAction
      Caption = 'All To Left'
      Hint = 'Assign All Right Properties to Left'
      ImageIndex = 101
    end
    object actAllToRight: TAction
      Caption = 'All To Right'
      Hint = 'Assign All Left Properties to Right'
      ImageIndex = 102
    end
    object actHelp: TAction
      Caption = '&Help'
      Hint = 'Display Help'
      ImageIndex = 1
    end
  end
  object pmGrid: TPopupMenu
    Left = 128
    Top = 501
    object ToLeft1: TMenuItem
      Action = actPropertyToLeft
    end
    object ToRight1: TMenuItem
      Action = actPropertyToRight
    end
    object AllToLeft2: TMenuItem
      Action = actAllToLeft
    end
    object AllToRight2: TMenuItem
      Action = actAllToRight
    end
    object AllToLeft3: TMenuItem
      Action = actAllToLeft
      Caption = '-'
    end
    object PreviousDifferent2: TMenuItem
      Action = actPrevDiff
    end
    object NextDifferent2: TMenuItem
      Action = actNextDiff
    end
  end
end
