inherited CnUsesInitTreeForm: TCnUsesInitTreeForm
  Left = 296
  Top = 143
  Width = 791
  Height = 570
  Caption = 'Uses Initialization Tree'
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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object grpFilter: TGroupBox
    Left = 432
    Top = 40
    Width = 342
    Height = 81
    Anchors = [akTop, akRight]
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
  object grpTree: TGroupBox
    Left = 8
    Top = 40
    Width = 417
    Height = 492
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Initialization Tree'
    TabOrder = 1
    object tvTree: TTreeView
      Left = 8
      Top = 16
      Width = 401
      Height = 468
      Anchors = [akLeft, akTop, akRight, akBottom]
      Indent = 19
      ReadOnly = True
      RightClickSelect = True
      TabOrder = 0
      OnChange = tvTreeChange
    end
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 783
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object lblProject: TLabel
      Left = 12
      Top = 12
      Width = 38
      Height = 13
      Caption = 'Project:'
    end
    object cbbProject: TComboBox
      Left = 64
      Top = 8
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object tlbUses: TToolBar
      Left = 224
      Top = 8
      Width = 521
      Height = 29
      Align = alNone
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
      object btnOpen: TToolButton
        Left = 31
        Top = 0
        Action = actOpen
      end
      object btnSearch: TToolButton
        Left = 54
        Top = 0
        Action = actSearch
      end
      object btnExport: TToolButton
        Left = 77
        Top = 0
        Action = actExport
      end
      object btnLocateSource: TToolButton
        Left = 100
        Top = 0
        Action = actLocateSource
      end
      object btn2: TToolButton
        Left = 123
        Top = 0
        Width = 8
        Caption = 'btn2'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object btnHelp: TToolButton
        Left = 131
        Top = 0
        Action = actHelp
      end
      object btnExit: TToolButton
        Left = 154
        Top = 0
        Action = actExit
      end
    end
  end
  object grpInfo: TGroupBox
    Left = 432
    Top = 128
    Width = 342
    Height = 404
    Anchors = [akTop, akRight, akBottom]
    Caption = 'Unit &Info'
    TabOrder = 3
    object lblSourceFile: TLabel
      Left = 16
      Top = 24
      Width = 56
      Height = 13
      Caption = 'Source File:'
    end
    object lblDcuFile: TLabel
      Left = 16
      Top = 128
      Width = 41
      Height = 13
      Caption = 'Dcu File:'
    end
    object lblSearchType: TLabel
      Left = 16
      Top = 224
      Width = 71
      Height = 13
      Caption = 'Location Type:'
    end
    object lblUsesType: TLabel
      Left = 16
      Top = 304
      Width = 54
      Height = 13
      Caption = 'Uses Type:'
    end
    object lblSourceFileText: TLabel
      Left = 16
      Top = 40
      Width = 318
      Height = 73
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      ShowAccelChar = False
      WordWrap = True
    end
    object lblDcuFileText: TLabel
      Left = 16
      Top = 144
      Width = 318
      Height = 73
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      ShowAccelChar = False
      WordWrap = True
    end
    object lblSearchTypeText: TLabel
      Left = 16
      Top = 240
      Width = 318
      Height = 49
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      ShowAccelChar = False
    end
    object lblUsesTypeText: TLabel
      Left = 16
      Top = 320
      Width = 318
      Height = 49
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      ShowAccelChar = False
    end
  end
  object actlstUses: TActionList
    Images = dmCnSharedImages.Images
    OnUpdate = actlstUsesUpdate
    Left = 32
    Top = 480
    object actGenerateUsesTree: TAction
      Caption = 'Analyse Project'
      Hint = 'Analyse Uses Initialization Tree for Selected Project'
      ImageIndex = 34
      OnExecute = actGenerateUsesTreeExecute
    end
    object actHelp: TAction
      Caption = '&Help'
      Hint = 'Display Help'
      ImageIndex = 1
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
    end
  end
  object pmTree: TPopupMenu
    Images = dmCnSharedImages.Images
    Left = 72
    Top = 480
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
  end
  object dlgSave: TSaveDialog
    Filter = 'Text File(*.txt)|*.txt|All Files(*.*)|*.*'
    Left = 112
    Top = 480
  end
end