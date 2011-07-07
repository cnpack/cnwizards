inherited CnImageListEditorForm: TCnImageListEditorForm
  Left = 374
  Top = 193
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'CnWizards ImageList Editor'
  ClientHeight = 398
  ClientWidth = 803
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 457
    Top = 0
    Width = 8
    Height = 398
    AutoSnap = False
    Beveled = True
    ResizeStyle = rsUpdate
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 457
    Height = 398
    Align = alLeft
    BevelOuter = bvNone
    Constraints.MinHeight = 398
    Constraints.MinWidth = 457
    TabOrder = 0
    DesignSize = (
      457
      398)
    object grp1: TGroupBox
      Left = 8
      Top = 8
      Width = 441
      Height = 121
      Anchors = [akLeft, akTop, akRight]
      Caption = '&Selected Image'
      TabOrder = 0
      DesignSize = (
        441
        121)
      object lbl2: TLabel
        Left = 112
        Top = 16
        Width = 91
        Height = 13
        Caption = '&Transparent Color:'
      end
      object lblAlpha: TLabel
        Left = 112
        Top = 72
        Width = 225
        Height = 41
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 
          'Warning: If you use XP Style Image, your application must be bui' +
          'lt with XPManifest and run under XP or higher OS.'
        WordWrap = True
      end
      object pnl3: TPanel
        Left = 8
        Top = 16
        Width = 97
        Height = 97
        BevelOuter = bvLowered
        TabOrder = 0
        object imgSelected: TImage
          Left = 1
          Top = 1
          Width = 95
          Height = 95
          Align = alClient
        end
      end
      object cbbTransparentColor: TComboBox
        Left = 112
        Top = 32
        Width = 225
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 2
        OnClick = rgOptionsClick
        OnExit = rgOptionsClick
      end
      object rgOptions: TRadioGroup
        Left = 344
        Top = 16
        Width = 89
        Height = 97
        Anchors = [akTop, akRight]
        Caption = 'Options'
        Items.Strings = (
          'Cro&p'
          'St&retch'
          'C&enter')
        TabOrder = 1
        OnClick = rgOptionsClick
      end
      object chkXPStyle: TCheckBox
        Left = 112
        Top = 56
        Width = 225
        Height = 17
        Caption = 'Use XP Style Image with Alpha channel.'
        TabOrder = 3
        OnClick = chkXPStyleClick
      end
    end
    object grp2: TGroupBox
      Left = 8
      Top = 134
      Width = 441
      Height = 229
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Images'
      TabOrder = 1
      DesignSize = (
        441
        229)
      object btnAdd: TButton
        Left = 8
        Top = 196
        Width = 57
        Height = 21
        Action = actAdd
        Anchors = [akLeft, akBottom]
        TabOrder = 1
      end
      object btnReplace: TButton
        Left = 72
        Top = 196
        Width = 57
        Height = 21
        Action = actReplace
        Anchors = [akLeft, akBottom]
        TabOrder = 2
      end
      object btnDelete: TButton
        Left = 136
        Top = 196
        Width = 57
        Height = 21
        Action = actDelete
        Anchors = [akLeft, akBottom]
        TabOrder = 3
      end
      object btnClear: TButton
        Left = 200
        Top = 196
        Width = 57
        Height = 21
        Action = actClear
        Anchors = [akLeft, akBottom]
        TabOrder = 4
      end
      object btnExport: TButton
        Left = 264
        Top = 196
        Width = 57
        Height = 21
        Action = actExport
        Anchors = [akLeft, akBottom]
        TabOrder = 5
      end
      object lvList: TListView
        Left = 8
        Top = 16
        Width = 425
        Height = 173
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <>
        HideSelection = False
        IconOptions.AutoArrange = True
        LargeImages = ilList
        MultiSelect = True
        ReadOnly = True
        TabOrder = 0
        OnSelectItem = lvListSelectItem
      end
      object cbbSize: TComboBox
        Left = 344
        Top = 196
        Width = 89
        Height = 21
        Style = csDropDownList
        Anchors = [akRight, akBottom]
        ItemHeight = 13
        TabOrder = 6
        OnChange = cbbSizeChange
        Items.Strings = (
          '')
      end
    end
    object btnOK: TButton
      Left = 160
      Top = 369
      Width = 57
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      TabOrder = 2
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 224
      Top = 369
      Width = 57
      Height = 21
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 3
    end
    object btnApply: TButton
      Left = 288
      Top = 369
      Width = 57
      Height = 21
      Action = actApply
      Anchors = [akRight, akBottom]
      TabOrder = 4
    end
    object btnHelp: TButton
      Left = 352
      Top = 369
      Width = 57
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = '&Help'
      TabOrder = 5
      OnClick = btnHelpClick
    end
    object btnShowSearch: TButton
      Left = 416
      Top = 369
      Width = 33
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = '<<'
      TabOrder = 6
      OnClick = btnShowSearchClick
    end
  end
  object pnlSearch: TPanel
    Left = 465
    Top = 0
    Width = 338
    Height = 398
    Align = alClient
    BevelOuter = bvNone
    Constraints.MinHeight = 398
    Constraints.MinWidth = 338
    TabOrder = 1
    DesignSize = (
      338
      398)
    object grp3: TGroupBox
      Left = 8
      Top = 8
      Width = 323
      Height = 354
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Online Search'
      TabOrder = 0
      DesignSize = (
        323
        354)
      object lbl1: TLabel
        Left = 8
        Top = 20
        Width = 46
        Height = 13
        Caption = 'Key&word:'
      end
      object lbl4: TLabel
        Left = 8
        Top = 52
        Width = 44
        Height = 13
        Caption = 'Provider:'
      end
      object lblPage: TLabel
        Left = 132
        Top = 325
        Width = 41
        Height = 13
        Alignment = taRightJustify
        Anchors = [akRight, akBottom]
        AutoSize = False
        Caption = '0/0'
      end
      object btnSearch: TButton
        Left = 250
        Top = 16
        Width = 65
        Height = 21
        Action = actSearch
        Anchors = [akTop, akRight]
        TabOrder = 1
      end
      object lvSearch: TListView
        Left = 8
        Top = 94
        Width = 307
        Height = 221
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <>
        HideSelection = False
        IconOptions.AutoArrange = True
        LargeImages = ilSearch
        MultiSelect = True
        ReadOnly = True
        TabOrder = 5
      end
      object btnSearchAdd: TButton
        Left = 8
        Top = 321
        Width = 57
        Height = 21
        Action = actSearchAdd
        Anchors = [akLeft, akBottom]
        TabOrder = 6
      end
      object btnPrev: TButton
        Left = 213
        Top = 321
        Width = 30
        Height = 21
        Action = actPrev
        Anchors = [akRight, akBottom]
        TabOrder = 9
      end
      object btnNext: TButton
        Left = 249
        Top = 321
        Width = 30
        Height = 21
        Action = actNext
        Anchors = [akRight, akBottom]
        TabOrder = 10
      end
      object btnFirst: TButton
        Left = 178
        Top = 321
        Width = 30
        Height = 21
        Action = actFirst
        Anchors = [akRight, akBottom]
        TabOrder = 8
      end
      object btnLast: TButton
        Left = 284
        Top = 321
        Width = 30
        Height = 21
        Action = actLast
        Anchors = [akRight, akBottom]
        TabOrder = 11
      end
      object btnSearchReplace: TButton
        Left = 72
        Top = 321
        Width = 57
        Height = 21
        Action = actSearchReplace
        Anchors = [akLeft, akBottom]
        TabOrder = 7
      end
      object cbbKeyword: TComboBox
        Left = 64
        Top = 16
        Width = 179
        Height = 21
        AutoComplete = False
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        OnKeyPress = cbbKeywordKeyPress
      end
      object cbbProvider: TComboBox
        Left = 64
        Top = 48
        Width = 179
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 2
      end
      object btnGoto: TButton
        Left = 250
        Top = 48
        Width = 65
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '&Goto'
        TabOrder = 3
        OnClick = btnGotoClick
      end
      object chkCommercialLicenses: TCheckBox
        Left = 64
        Top = 72
        Width = 249
        Height = 17
        Caption = 'Include only icons with commercial licenses'
        TabOrder = 4
      end
    end
    object pbSearch: TProgressBar
      Left = 8
      Top = 372
      Width = 322
      Height = 17
      Anchors = [akLeft, akRight, akBottom]
      TabOrder = 1
    end
  end
  object ilSearch: TImageList
    Left = 304
    Top = 232
  end
  object ilList: TImageList
    Left = 336
    Top = 232
  end
  object ActionList: TActionList
    OnUpdate = ActionListUpdate
    Left = 368
    Top = 232
    object actAdd: TAction
      Category = 'List'
      Caption = '&Add...'
      OnExecute = actAddExecute
    end
    object actReplace: TAction
      Category = 'List'
      Caption = '&Replace'
      OnExecute = actReplaceExecute
    end
    object actDelete: TAction
      Category = 'List'
      Caption = '&Delete'
      OnExecute = actDeleteExecute
    end
    object actClear: TAction
      Category = 'List'
      Caption = '&Clear'
      OnExecute = actClearExecute
    end
    object actExport: TAction
      Category = 'List'
      Caption = 'E&xport...'
      OnExecute = actExportExecute
    end
    object actSearchAdd: TAction
      Category = 'Search'
      Caption = 'Add'
      OnExecute = actSearchAddExecute
    end
    object actSearchReplace: TAction
      Category = 'Search'
      Caption = 'Rep&lace'
      OnExecute = actSearchReplaceExecute
    end
    object actFirst: TAction
      Category = 'Search'
      Caption = '|<'
      OnExecute = actFirstExecute
    end
    object actPrev: TAction
      Category = 'Search'
      Caption = '<<'
      OnExecute = actPrevExecute
    end
    object actNext: TAction
      Category = 'Search'
      Caption = '>>'
      OnExecute = actNextExecute
    end
    object actLast: TAction
      Category = 'Search'
      Caption = '>|'
      OnExecute = actLastExecute
    end
    object actApply: TAction
      Caption = '&Apply'
      OnExecute = actApplyExecute
    end
    object actSearch: TAction
      Category = 'Search'
      Caption = '&Search'
      OnExecute = actSearchExecute
    end
  end
  object dlgOpen: TOpenDialog
    Filter = 
      'All (*.bmp;*.ico;*.png)|*.bmp;*.ico;*.png|Bitmaps (*.bmp)|*.bmp|' +
      'Icons (*.ico)|*.ico|Png files (*.png)|*.png'
    Options = [ofAllowMultiSelect, ofFileMustExist, ofEnableSizing]
    Left = 272
    Top = 232
  end
end
