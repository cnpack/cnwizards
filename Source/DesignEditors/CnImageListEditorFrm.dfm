inherited CnImageListEditorForm: TCnImageListEditorForm
  Left = 499
  Top = 240
  Width = 788
  Height = 432
  BorderIcons = [biSystemMenu]
  Caption = 'ImageList Editor Online'
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 433
    Top = 0
    Width = 5
    Height = 394
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 433
    Height = 394
    Align = alLeft
    BevelOuter = bvNone
    Constraints.MinHeight = 394
    Constraints.MinWidth = 433
    TabOrder = 0
    DesignSize = (
      433
      394)
    object grp1: TGroupBox
      Left = 8
      Top = 8
      Width = 417
      Height = 105
      Anchors = [akLeft, akTop, akRight]
      Caption = '&Selected Image'
      TabOrder = 0
      DesignSize = (
        417
        105)
      object lbl2: TLabel
        Left = 96
        Top = 16
        Width = 91
        Height = 13
        Caption = '&Transparent Color:'
      end
      object lbl3: TLabel
        Left = 96
        Top = 56
        Width = 44
        Height = 13
        Caption = '&Fill Color:'
      end
      object pnl3: TPanel
        Left = 8
        Top = 16
        Width = 81
        Height = 81
        BevelOuter = bvLowered
        TabOrder = 0
        object imgSelected: TImage
          Left = 1
          Top = 1
          Width = 79
          Height = 79
          Align = alClient
        end
      end
      object cbbTransparentColor: TComboBox
        Left = 96
        Top = 32
        Width = 217
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 2
      end
      object cbbFillColor: TComboBox
        Left = 96
        Top = 72
        Width = 217
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 3
      end
      object rgOptions: TRadioGroup
        Left = 320
        Top = 16
        Width = 89
        Height = 81
        Anchors = [akTop, akRight]
        Caption = 'Options'
        Items.Strings = (
          'Cro&p'
          'St&retch'
          'C&enter')
        TabOrder = 1
      end
    end
    object grp2: TGroupBox
      Left = 8
      Top = 120
      Width = 417
      Height = 238
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Images'
      TabOrder = 1
      DesignSize = (
        417
        238)
      object btnAdd: TButton
        Left = 8
        Top = 205
        Width = 57
        Height = 21
        Anchors = [akLeft, akBottom]
        Caption = '&Add...'
        TabOrder = 1
      end
      object btnReplace: TButton
        Left = 72
        Top = 205
        Width = 57
        Height = 21
        Anchors = [akLeft, akBottom]
        Caption = '&Replace'
        TabOrder = 2
      end
      object btnDelete: TButton
        Left = 136
        Top = 205
        Width = 57
        Height = 21
        Anchors = [akLeft, akBottom]
        Caption = '&Delete'
        TabOrder = 3
      end
      object btnClear: TButton
        Left = 200
        Top = 205
        Width = 57
        Height = 21
        Anchors = [akLeft, akBottom]
        Caption = '&Clear'
        TabOrder = 4
      end
      object btnExport: TButton
        Left = 264
        Top = 205
        Width = 57
        Height = 21
        Anchors = [akLeft, akBottom]
        Caption = 'E&xport...'
        TabOrder = 5
      end
      object lvList: TListView
        Left = 8
        Top = 16
        Width = 401
        Height = 182
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <>
        TabOrder = 0
      end
      object cbbSize: TComboBox
        Left = 328
        Top = 205
        Width = 81
        Height = 21
        Style = csDropDownList
        Anchors = [akRight, akBottom]
        ItemHeight = 13
        TabOrder = 6
        Items.Strings = (
          '12x12'
          '16x16'
          '24x24'
          '32x32'
          '48x48'
          '64x64'
          '128x128')
      end
    end
    object btnOK: TButton
      Left = 88
      Top = 365
      Width = 57
      Height = 21
      Anchors = [akLeft, akBottom]
      Caption = '&OK'
      TabOrder = 2
    end
    object btnCancel: TButton
      Left = 152
      Top = 365
      Width = 57
      Height = 21
      Anchors = [akLeft, akBottom]
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 3
    end
    object btnApply: TButton
      Left = 216
      Top = 365
      Width = 57
      Height = 21
      Anchors = [akLeft, akBottom]
      Caption = '&Apply'
      TabOrder = 4
    end
    object btnHelp: TButton
      Left = 280
      Top = 365
      Width = 57
      Height = 21
      Anchors = [akLeft, akBottom]
      Caption = '&Help'
      TabOrder = 5
    end
    object btnShowSearch: TButton
      Left = 344
      Top = 365
      Width = 81
      Height = 21
      Anchors = [akLeft, akBottom]
      Caption = 'Searc&h >>'
      TabOrder = 6
    end
  end
  object pnlSearch: TPanel
    Left = 438
    Top = 0
    Width = 334
    Height = 394
    Align = alClient
    BevelOuter = bvNone
    Constraints.MinHeight = 394
    Constraints.MinWidth = 334
    TabOrder = 1
    DesignSize = (
      334
      394)
    object grp3: TGroupBox
      Left = 8
      Top = 8
      Width = 319
      Height = 350
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Online Search'
      TabOrder = 0
      DesignSize = (
        319
        350)
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
      object btnSearch: TButton
        Left = 246
        Top = 16
        Width = 65
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '&Search'
        TabOrder = 1
      end
      object lv2: TListView
        Left = 8
        Top = 80
        Width = 303
        Height = 230
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <>
        TabOrder = 4
      end
      object btnSearchAdd: TButton
        Left = 8
        Top = 317
        Width = 57
        Height = 21
        Anchors = [akLeft, akBottom]
        Caption = 'Add'
        TabOrder = 5
      end
      object btnPrev: TButton
        Left = 192
        Top = 317
        Width = 35
        Height = 21
        Anchors = [akRight, akBottom]
        Caption = '<<'
        TabOrder = 8
      end
      object btnNext: TButton
        Left = 233
        Top = 317
        Width = 35
        Height = 21
        Anchors = [akRight, akBottom]
        Caption = '>>'
        TabOrder = 9
      end
      object btnFirst: TButton
        Left = 150
        Top = 317
        Width = 35
        Height = 21
        Anchors = [akRight, akBottom]
        Caption = '|<'
        TabOrder = 7
      end
      object btnLast: TButton
        Left = 275
        Top = 317
        Width = 35
        Height = 21
        Anchors = [akRight, akBottom]
        Caption = '>|'
        TabOrder = 10
      end
      object btnSearchReplace: TButton
        Left = 72
        Top = 317
        Width = 57
        Height = 21
        Anchors = [akLeft, akBottom]
        Caption = 'Rep&lace'
        TabOrder = 6
      end
      object cbbKeyword: TComboBox
        Left = 64
        Top = 16
        Width = 175
        Height = 21
        AutoComplete = False
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
      end
      object cbb1: TComboBox
        Left = 64
        Top = 48
        Width = 175
        Height = 21
        AutoComplete = False
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 2
      end
      object btnGoto: TButton
        Left = 246
        Top = 48
        Width = 65
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '&Goto'
        TabOrder = 3
      end
    end
  end
  object il1: TImageList
    Left = 304
    Top = 232
  end
end
