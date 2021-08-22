inherited CnUsesInitTreeForm: TCnUsesInitTreeForm
  Left = 296
  Top = 143
  Width = 791
  Height = 570
  Caption = 'Uses Initialization'
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
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
      ItemHeight = 13
      TabOrder = 0
      Text = 'cbbProject'
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
      object btnSearch: TToolButton
        Left = 31
        Top = 0
        Action = actSearch
      end
      object btnExport: TToolButton
        Left = 54
        Top = 0
        Action = actExport
      end
      object btn2: TToolButton
        Left = 77
        Top = 0
        Width = 8
        Caption = 'btn2'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object btnHelp: TToolButton
        Left = 85
        Top = 0
        Action = actHelp
      end
      object btnExit: TToolButton
        Left = 108
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
      Caption = '&Export Tree...'
      Hint = 'Export Uses Tree to File'
      ImageIndex = 6
    end
    object actSearch: TAction
      Caption = '&Search...'
      Hint = 'Search Unit in Tree'
      ImageIndex = 16
    end
  end
end
