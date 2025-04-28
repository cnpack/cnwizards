inherited CnUsesInitTreeForm: TCnUsesInitTreeForm
  Left = 201
  Top = 102
  AutoScroll = False
  Caption = 'Uses Initialization Tree'
  ClientHeight = 571
  ClientWidth = 1025
  Font.Charset = ANSI_CHARSET
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000CCC0000000000000CFC0000000000000CCC0000000000
    000000000000000000000000066600000000000006F600000000000006660000
    000000000000000000011100000000000001F100000000000001110000000000
    000000000000044400000000000004F40000000000000444000000000000FFFF
    0000FE3F0000C23F0000DE3F0000DFFF0000DFF80000DF080000DF780000DFFF
    0000DE3F0000C23F0000DE3F0000FFFF00008FFF00008FFF00008FFF0000}
  Menu = mmInit
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1025
    Height = 28
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblProject: TLabel
      Left = 12
      Top = 8
      Width = 38
      Height = 13
      Caption = '&Project:'
      FocusControl = cbbProject
    end
    object cbbProject: TComboBox
      Left = 64
      Top = 4
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object tlbUses: TToolBar
      Left = 230
      Top = 0
      Width = 521
      Height = 28
      Align = alNone
      BorderWidth = 1
      EdgeBorders = []
      Flat = True
      Images = dmCnSharedImages.Images
      TabOrder = 1
      object btnGenerateUsesTree: TToolButton
        Left = 0
        Top = 0
        Action = actGenerateUsesTree
      end
      object btn1: TToolButton
        Left = 23
        Top = 0
        Width = 8
        Caption = 'btn1'
        ImageIndex = 35
        Style = tbsSeparator
      end
      object btnSearch: TToolButton
        Left = 31
        Top = 0
        Action = actSearch
      end
      object btnSearchNext: TToolButton
        Left = 54
        Top = 0
        Action = actSearchNext
      end
      object btn4: TToolButton
        Left = 77
        Top = 0
        Width = 8
        Caption = 'btn4'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object btnOpen: TToolButton
        Left = 85
        Top = 0
        Action = actOpen
      end
      object btnLocateSource: TToolButton
        Left = 108
        Top = 0
        Action = actLocateSource
      end
      object btnExport: TToolButton
        Left = 131
        Top = 0
        Action = actExport
      end
      object btn2: TToolButton
        Left = 154
        Top = 0
        Width = 8
        Caption = 'btn2'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object btnHelp: TToolButton
        Left = 162
        Top = 0
        Action = actHelp
      end
      object btnExit: TToolButton
        Left = 185
        Top = 0
        Action = actExit
      end
    end
  end
  object statUses: TStatusBar
    Left = 0
    Top = 552
    Width = 1025
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object pnlMain: TPanel
    Left = 0
    Top = 28
    Width = 1025
    Height = 524
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 8
    TabOrder = 2
    object spl1: TSplitter
      Left = 425
      Top = 8
      Width = 5
      Height = 508
      Cursor = crHSplit
    end
    object spl2: TSplitter
      Left = 636
      Top = 8
      Width = 5
      Height = 508
      Cursor = crHSplit
    end
    object grpTree: TGroupBox
      Left = 8
      Top = 8
      Width = 417
      Height = 508
      Align = alLeft
      Caption = 'Initialization &Tree'
      TabOrder = 0
      object tvTree: TTreeView
        Left = 8
        Top = 16
        Width = 401
        Height = 484
        Anchors = [akLeft, akTop, akRight, akBottom]
        HideSelection = False
        Indent = 19
        PopupMenu = pmTree
        ReadOnly = True
        RightClickSelect = True
        TabOrder = 0
        OnChange = tvTreeChange
      end
    end
    object grpOrder: TGroupBox
      Left = 430
      Top = 8
      Width = 206
      Height = 508
      Align = alLeft
      Caption = 'Initialization &Order'
      TabOrder = 1
      object mmoOrder: TMemo
        Left = 8
        Top = 16
        Width = 190
        Height = 484
        Anchors = [akLeft, akTop, akRight, akBottom]
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object pnlRight: TPanel
      Left = 641
      Top = 8
      Width = 376
      Height = 508
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      object grpFilter: TGroupBox
        Left = 0
        Top = 0
        Width = 376
        Height = 81
        Align = alTop
        Caption = 'Display &Filter'
        TabOrder = 0
        object chkProjectPath: TCheckBox
          Left = 16
          Top = 24
          Width = 193
          Height = 17
          Caption = 'Units in Project Search Path'
          Checked = True
          State = cbChecked
          TabOrder = 0
          OnClick = chkSystemPathClick
        end
        object chkSystemPath: TCheckBox
          Left = 16
          Top = 48
          Width = 193
          Height = 17
          Caption = 'Units in System Search Path'
          TabOrder = 1
          OnClick = chkSystemPathClick
        end
      end
      object grpInfo: TGroupBox
        Left = 0
        Top = 90
        Width = 376
        Height = 418
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'Unit &Info'
        TabOrder = 1
        object lblSourceFile: TLabel
          Left = 16
          Top = 24
          Width = 64
          Height = 13
          Caption = 'Source File:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblDcuFile: TLabel
          Left = 16
          Top = 128
          Width = 46
          Height = 13
          Caption = 'Dcu File:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSearchType: TLabel
          Left = 16
          Top = 224
          Width = 82
          Height = 13
          Caption = 'Location Type:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblUsesType: TLabel
          Left = 16
          Top = 304
          Width = 61
          Height = 13
          Caption = 'Uses Type:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSearchTypeText: TLabel
          Left = 16
          Top = 240
          Width = 352
          Height = 49
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          ShowAccelChar = False
        end
        object lblUsesTypeText: TLabel
          Left = 16
          Top = 320
          Width = 352
          Height = 49
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          ShowAccelChar = False
        end
        object mmoSourceFileText: TMemo
          Left = 16
          Top = 48
          Width = 313
          Height = 65
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object mmoDcuFileText: TMemo
          Left = 16
          Top = 152
          Width = 313
          Height = 65
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
      end
    end
  end
  object actlstUses: TActionList
    Images = dmCnSharedImages.Images
    OnUpdate = actlstUsesUpdate
    Left = 32
    Top = 472
    object actGenerateUsesTree: TAction
      Caption = '&Analyse Project'
      Hint = 'Analyse Uses Initialization Tree for Selected Project'
      ImageIndex = 34
      OnExecute = actGenerateUsesTreeExecute
    end
    object actHelp: TAction
      Caption = '&Help'
      Hint = 'Display Help'
      ImageIndex = 1
      ShortCut = 112
      OnExecute = actHelpExecute
    end
    object actExit: TAction
      Caption = 'E&xit'
      Hint = 'Close Window'
      ImageIndex = 0
      OnExecute = actExitExecute
    end
    object actExport: TAction
      Caption = 'Export &Tree...'
      Hint = 'Export Uses Tree to File'
      ImageIndex = 6
      OnExecute = actExportExecute
    end
    object actSearch: TAction
      Caption = '&Search...'
      Hint = 'Search Unit in Tree'
      ImageIndex = 16
      ShortCut = 16454
      OnExecute = actSearchExecute
    end
    object actOpen: TAction
      Caption = '&Open'
      Hint = 'Open Source File'
      ImageIndex = 3
      OnExecute = actOpenExecute
    end
    object actLocateSource: TAction
      Caption = 'Open in &Explorer'
      Hint = 'Open Selected Source File in Windows Explorer'
      ImageIndex = 24
      OnExecute = actLocateSourceExecute
    end
    object actSearchNext: TAction
      Caption = 'Search &Next...'
      Hint = 'Search Next Unit'
      ImageIndex = 17
      ShortCut = 114
      OnExecute = actSearchNextExecute
    end
  end
  object pmTree: TPopupMenu
    Images = dmCnSharedImages.Images
    Left = 72
    Top = 472
    object Open1: TMenuItem
      Action = actOpen
    end
    object OpeninExplorer1: TMenuItem
      Action = actLocateSource
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ExportTree1: TMenuItem
      Action = actExport
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Search1: TMenuItem
      Action = actSearch
    end
    object SearchNext2: TMenuItem
      Action = actSearchNext
    end
  end
  object dlgSave: TSaveDialog
    Filter = 'Text File(*.txt)|*.txt'
    Left = 112
    Top = 472
  end
  object dlgFind: TFindDialog
    OnClose = dlgFindClose
    OnFind = dlgFindFind
    Left = 152
    Top = 472
  end
  object mmInit: TMainMenu
    Images = dmCnSharedImages.Images
    Left = 192
    Top = 472
    object File1: TMenuItem
      Caption = '&File'
      object Exit1: TMenuItem
        Action = actExit
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
      object AnalyseProject1: TMenuItem
        Action = actGenerateUsesTree
      end
      object ExportTree2: TMenuItem
        Action = actExport
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Open2: TMenuItem
        Action = actOpen
      end
      object OpeninExplorer2: TMenuItem
        Action = actLocateSource
      end
    end
    object Search2: TMenuItem
      Caption = '&Search'
      object Search3: TMenuItem
        Action = actSearch
      end
      object SearchNext1: TMenuItem
        Action = actSearchNext
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object Help2: TMenuItem
        Action = actHelp
      end
    end
  end
end
