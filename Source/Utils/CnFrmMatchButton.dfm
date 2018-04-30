object CnMatchButtonFrame: TCnMatchButtonFrame
  Left = 0
  Top = 0
  Width = 40
  Height = 25
  Hint = 'Match Middle'
  AutoScroll = False
  AutoSize = True
  TabOrder = 0
  object tlb1: TToolBar
    Left = 0
    Top = 0
    Width = 40
    Height = 25
    Align = alNone
    EdgeBorders = []
    Flat = True
    Images = dmCnSharedImages.Images
    TabOrder = 0
    object btnMatchMode: TToolButton
      Left = 0
      Top = 0
      DropdownMenu = pmMatchMode
      Grouped = True
      ImageIndex = 28
      Style = tbsDropDown
      OnClick = btnMatchModeClick
    end
  end
  object pmMatchMode: TPopupMenu
    Images = dmCnSharedImages.Images
    Left = 40
    Top = 2
    object mniMatchStart: TMenuItem
      Caption = 'Match From &Start'
      Hint = 'Match From Start'
      ImageIndex = 27
      OnClick = mniMatchClick
    end
    object mniMatchAny: TMenuItem
      Caption = 'Match &All Parts'
      Checked = True
      Hint = 'Match All Parts'
      ImageIndex = 28
      OnClick = mniMatchClick
    end
    object mniMatchFuzzy: TMenuItem
      Caption = '&Fuzzy Match'
      Hint = 'Fuzzy Match'
      ImageIndex = 94
      OnClick = mniMatchClick
    end
  end
end
