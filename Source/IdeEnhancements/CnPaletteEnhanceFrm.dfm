inherited CnPalEnhanceForm: TCnPalEnhanceForm
  Left = 340
  Top = 195
  BorderStyle = bsDialog
  Caption = 'IDE Main Form Enhancements Wizard Settings'
  ClientHeight = 435
  ClientWidth = 448
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grpPalEnh: TGroupBox
    Left = 8
    Top = 8
    Width = 433
    Height = 145
    Caption = 'Component &Palette Extension Settings'
    TabOrder = 0
    object chkAddTabs: TCheckBox
      Left = 8
      Top = 16
      Width = 409
      Height = 17
      Caption = 'Add "Tabs" to Popup Menu(Delphi 5/BCB 5 only).'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkMultiLine: TCheckBox
      Left = 8
      Top = 36
      Width = 337
      Height = 17
      Caption = 'Set Component Palette to Multi-line.'
      TabOrder = 1
    end
    object chkDivTabMenu: TCheckBox
      Left = 8
      Top = 76
      Width = 409
      Height = 17
      Caption = 'Wrap Tabs Menu when too Long(Delphi 7 Below Only).'
      TabOrder = 3
    end
    object chkCompFilter: TCheckBox
      Left = 8
      Top = 96
      Width = 409
      Height = 17
      Caption = 'Add "Search Component" Button in Pallete(Delphi 7 Below Only).'
      TabOrder = 4
    end
    object chkButtonStyle: TCheckBox
      Left = 8
      Top = 56
      Width = 337
      Height = 17
      Caption = 'Set Component Palette'#39's Style to Flat Button.'
      TabOrder = 2
    end
    object chkLockToolbar: TCheckBox
      Left = 8
      Top = 116
      Width = 409
      Height = 17
      Caption = 'Lock IDE Toolbar to Disable Drag.'
      TabOrder = 5
    end
  end
  object btnHelp: TButton
    Left = 366
    Top = 404
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 5
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 206
    Top = 404
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 286
    Top = 404
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object grpMisc: TGroupBox
    Left = 8
    Top = 156
    Width = 433
    Height = 41
    Caption = 'O&ther Settings'
    TabOrder = 1
    object chkMenuLine: TCheckBox
      Left = 8
      Top = 16
      Width = 409
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
    Top = 204
    Width = 433
    Height = 193
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
      Caption = 'Move Following Menu Items into Sub Menu.'
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
      Left = 205
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
      Width = 177
      Height = 89
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 3
      OnClick = UpdateControls
      OnDblClick = btnAddClick
    end
    object lstDest: TListBox
      Left = 232
      Top = 88
      Width = 185
      Height = 89
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 4
      OnClick = UpdateControls
      OnDblClick = btnDeleteClick
    end
  end
end
