inherited CnPalEnhanceForm: TCnPalEnhanceForm
  Left = 341
  Top = 101
  BorderStyle = bsDialog
  Caption = 'IDE Main Form Enhancements Wizard Settings'
  ClientHeight = 483
  ClientWidth = 488
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grpPalEnh: TGroupBox
    Left = 8
    Top = 8
    Width = 470
    Height = 192
    Caption = 'Component &Palette Extension Settings'
    TabOrder = 0
    object lblShortcut: TLabel
      Left = 24
      Top = 139
      Width = 45
      Height = 13
      Caption = 'Shortcut:'
      FocusControl = hkCompFilter
    end
    object chkAddTabs: TCheckBox
      Left = 8
      Top = 16
      Width = 457
      Height = 17
      Caption = 'Add "Tabs" to Popup Menu(Delphi 5/BCB 5 only).'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkMultiLine: TCheckBox
      Left = 8
      Top = 36
      Width = 457
      Height = 17
      Caption = 'Set Component Palette to Multi-line.'
      TabOrder = 1
    end
    object chkDivTabMenu: TCheckBox
      Left = 8
      Top = 76
      Width = 457
      Height = 17
      Caption = 'Wrap Tabs Menu when too Long(Delphi 7 Below Only).'
      TabOrder = 3
    end
    object chkCompFilter: TCheckBox
      Left = 8
      Top = 116
      Width = 457
      Height = 17
      Caption = 
        'Add "Search Component" Button in Palette(Delphi 7 Below or 2010 ' +
        'Above Only).'
      TabOrder = 5
      OnClick = UpdateControls
    end
    object chkButtonStyle: TCheckBox
      Left = 8
      Top = 56
      Width = 457
      Height = 17
      Caption = 'Set Component Palette'#39's Style to Flat Button.'
      TabOrder = 2
    end
    object chkLockToolbar: TCheckBox
      Left = 8
      Top = 164
      Width = 457
      Height = 17
      Caption = 'Lock IDE Toolbars to Disable Drag.'
      TabOrder = 7
    end
    object hkCompFilter: THotKey
      Left = 120
      Top = 136
      Width = 121
      Height = 19
      HotKey = 32833
      InvalidKeys = [hcNone]
      Modifiers = [hkAlt]
      TabOrder = 6
    end
    object chkClearRegSessionProject: TCheckBox
      Left = 8
      Top = 96
      Width = 457
      Height = 17
      Caption = 'Clear Session Project  in Registry when Exiting.'
      TabOrder = 4
      OnClick = UpdateControls
    end
  end
  object btnHelp: TButton
    Left = 404
    Top = 452
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 5
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 244
    Top = 452
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 324
    Top = 452
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object grpMisc: TGroupBox
    Left = 8
    Top = 204
    Width = 470
    Height = 41
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'O&ther Settings'
    TabOrder = 1
    object chkMenuLine: TCheckBox
      Left = 8
      Top = 16
      Width = 449
      Height = 17
      Caption = 'Auto Display Shortcut of IDE Main Menu.(Delphi 7 only).'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 0
    end
  end
  object grpMenu: TGroupBox
    Left = 8
    Top = 252
    Width = 470
    Height = 193
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'M&ain Form Settings'
    TabOrder = 2
    object lbl1: TLabel
      Left = 24
      Top = 72
      Width = 77
      Height = 13
      Caption = 'Available Items:'
    end
    object lbl2: TLabel
      Left = 24
      Top = 44
      Width = 41
      Height = 13
      Caption = 'Caption:'
    end
    object lbl3: TLabel
      Left = 240
      Top = 72
      Width = 75
      Height = 13
      Caption = 'Selected Items:'
    end
    object chkMoveWizMenus: TCheckBox
      Left = 8
      Top = 16
      Width = 401
      Height = 17
      Caption = 'Move Following Menu Items into New Sub Menu.'
      TabOrder = 0
      OnClick = UpdateControls
    end
    object edtMoveToUser: TEdit
      Left = 88
      Top = 40
      Width = 113
      Height = 21
      TabOrder = 1
      OnClick = UpdateControls
    end
    object tlb1: TToolBar
      Left = 225
      Top = 87
      Width = 23
      Height = 90
      Align = alNone
      AutoSize = True
      Caption = 'tlb1'
      EdgeBorders = []
      Images = dmCnSharedImages.Images
      TabOrder = 2
      object btnDelete: TToolButton
        Left = 0
        Top = 2
        ImageIndex = 15
        Wrap = True
        OnClick = btnDeleteClick
      end
      object btnUp: TToolButton
        Left = 0
        Top = 24
        ImageIndex = 44
        Wrap = True
        OnClick = btnUpClick
      end
      object btnDown: TToolButton
        Left = 0
        Top = 46
        ImageIndex = 45
        Wrap = True
        OnClick = btnDownClick
      end
      object btnAdd: TToolButton
        Left = 0
        Top = 68
        ImageIndex = 14
        OnClick = btnAddClick
      end
    end
    object lstSource: TListBox
      Left = 24
      Top = 88
      Width = 197
      Height = 89
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 3
      OnClick = UpdateControls
      OnDblClick = btnAddClick
    end
    object lstDest: TListBox
      Left = 252
      Top = 88
      Width = 195
      Height = 89
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 4
      OnClick = UpdateControls
      OnDblClick = btnDeleteClick
    end
  end
end
