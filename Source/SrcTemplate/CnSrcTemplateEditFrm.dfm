inherited CnSrcTemplateEditForm: TCnSrcTemplateEditForm
  Left = 363
  Top = 135
  BorderStyle = bsDialog
  Caption = 'Source Template Editor'
  ClientHeight = 445
  ClientWidth = 616
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnHelp: TButton
    Left = 534
    Top = 416
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 374
    Top = 416
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 454
    Top = 416
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 601
    Height = 121
    Caption = '&Options'
    TabOrder = 3
    object lbl2: TLabel
      Left = 8
      Top = 47
      Width = 27
      Height = 13
      Caption = 'Desc:'
    end
    object lbl3: TLabel
      Left = 384
      Top = 19
      Width = 47
      Height = 13
      Caption = 'ShortCut:'
    end
    object lbl4: TLabel
      Left = 384
      Top = 47
      Width = 44
      Height = 13
      Caption = 'Location:'
    end
    object lbl5: TLabel
      Left = 176
      Top = 19
      Width = 25
      Height = 13
      Caption = 'Icon:'
    end
    object lbl7: TLabel
      Left = 8
      Top = 19
      Width = 24
      Height = 13
      Caption = 'Title:'
    end
    object btnOpen: TSpeedButton
      Left = 348
      Top = 16
      Width = 20
      Height = 20
      Glyph.Data = {
        DE000000424DDE0000000000000076000000280000000D0000000D0000000100
        0400000000006800000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
        F000F000000000FFF00000888888880FF000080FBFBFBF0FFA5F080BFBFBFBF0
        F0000880BFBFBFB0F0000880FBFBFBFB0000088800000000000008888888880F
        F0000888800000FFF000F0000FFFFFFFF000FFFFFFFFFFFFF000FFFFFFFFFFFF
        F000}
      OnClick = btnOpenClick
    end
    object edtHint: TEdit
      Left = 42
      Top = 44
      Width = 327
      Height = 21
      TabOrder = 3
    end
    object HotKey: THotKey
      Left = 438
      Top = 16
      Width = 155
      Height = 19
      HotKey = 0
      InvalidKeys = [hcNone, hcShift]
      Modifiers = []
      TabOrder = 2
    end
    object cbbInsertPos: TComboBox
      Left = 438
      Top = 44
      Width = 155
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 4
    end
    object edtIcon: TEdit
      Left = 216
      Top = 16
      Width = 129
      Height = 21
      TabOrder = 1
    end
    object chkDisabled: TCheckBox
      Left = 40
      Top = 72
      Width = 153
      Height = 17
      Caption = 'Disable this Template'
      TabOrder = 5
    end
    object edtCaption: TEdit
      Left = 42
      Top = 16
      Width = 119
      Height = 21
      TabOrder = 0
    end
    object chkSavePos: TCheckBox
      Left = 216
      Top = 72
      Width = 313
      Height = 17
      Caption = 'Restore Cursor Position after Insert'
      TabOrder = 6
    end
    object chkForDelphi: TCheckBox
      Left = 40
      Top = 96
      Width = 169
      Height = 17
      Caption = 'For Pascal File'
      TabOrder = 7
    end
    object chkForBcb: TCheckBox
      Left = 216
      Top = 96
      Width = 153
      Height = 17
      Caption = 'For C/C++ File'
      TabOrder = 8
    end
  end
  object grp2: TGroupBox
    Left = 8
    Top = 136
    Width = 601
    Height = 273
    Caption = 'Conte&nt'
    TabOrder = 4
    object lbl6: TLabel
      Left = 8
      Top = 18
      Width = 65
      Height = 13
      Caption = 'Insert Macro:'
    end
    object mmoContent: TMemo
      Left = 8
      Top = 44
      Width = 585
      Height = 217
      Anchors = [akLeft, akTop, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 2
      WantTabs = True
      WordWrap = False
    end
    object cbbMacro: TComboBox
      Left = 72
      Top = 15
      Width = 433
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object btnInsert: TButton
      Left = 517
      Top = 15
      Width = 75
      Height = 21
      Caption = '&Insert'
      TabOrder = 1
      OnClick = btnInsertClick
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'ico'
    Filter = 'Icon Files(*.ico)|*.ico'
    Left = 8
    Top = 416
  end
end
