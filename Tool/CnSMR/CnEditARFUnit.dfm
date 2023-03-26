object CnEditARFForm: TCnEditARFForm
  Left = 140
  Top = 156
  Width = 725
  Height = 519
  Caption = 'Analyze Executable Files'
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gpAnalyse: TPanel
    Left = 0
    Top = 0
    Width = 717
    Height = 492
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Panel2: TPanel
      Left = 562
      Top = 0
      Width = 155
      Height = 492
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 3
      TabOrder = 3
      object Label1: TLabel
        Left = 3
        Top = 3
        Width = 149
        Height = 15
        Align = alTop
        AutoSize = False
        Caption = 'Contained &units:'
        FocusControl = mmoUnits
      end
      object mmoUnits: TMemo
        Left = 3
        Top = 18
        Width = 149
        Height = 471
        Align = alClient
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object pnlRequiredPackages: TPanel
      Left = 382
      Top = 0
      Width = 180
      Height = 492
      Align = alLeft
      BevelOuter = bvNone
      BorderWidth = 3
      TabOrder = 2
      object Label2: TLabel
        Left = 3
        Top = 3
        Width = 174
        Height = 15
        Align = alTop
        AutoSize = False
        Caption = 'Required &packages:'
        FocusControl = mmoRequirePackages
      end
      object mmoRequirePackages: TMemo
        Left = 3
        Top = 18
        Width = 174
        Height = 471
        Align = alClient
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object pnlExeFiles: TPanel
      Left = 146
      Top = 0
      Width = 236
      Height = 492
      Align = alLeft
      BevelOuter = bvNone
      BorderWidth = 3
      TabOrder = 1
      object Label3: TLabel
        Left = 3
        Top = 18
        Width = 230
        Height = 39
        Align = alTop
        AutoSize = False
        Caption = '&Files to analyze:'
        Layout = tlBottom
      end
      object Label5: TLabel
        Left = 3
        Top = 3
        Width = 230
        Height = 15
        Align = alTop
        AutoSize = False
        Caption = 'Fi&nd file:'
        FocusControl = edtSearchFile
      end
      object lsbFiles: TListBox
        Left = 3
        Top = 57
        Width = 230
        Height = 432
        Align = alClient
        ItemHeight = 13
        TabOrder = 1
        OnClick = lsbFilesClick
        OnDblClick = lsbFilesDblClick
        OnKeyDown = lsbFilesKeyDown
        OnKeyUp = lsbFilesKeyUp
      end
      object edtSearchFile: TEdit
        Left = 4
        Top = 19
        Width = 228
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        TabOrder = 0
        OnChange = edtSearchFileChange
        OnKeyDown = edtSearchFileKeyDown
      end
    end
    object sbButtons: TScrollBox
      Left = 0
      Top = 0
      Width = 146
      Height = 492
      Align = alLeft
      BorderStyle = bsNone
      TabOrder = 0
      object gpAnalyseBtns: TPanel
        Left = 0
        Top = 0
        Width = 146
        Height = 492
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object btnOpenFiles: TBitBtn
          Left = 12
          Top = 12
          Width = 120
          Height = 58
          Caption = '&Add Executable Files'
          PopupMenu = pmAddFiles
          TabOrder = 0
          OnClick = btnOpenFilesClick
        end
        object btnAnalyse: TBitBtn
          Left = 12
          Top = 82
          Width = 120
          Height = 58
          Caption = 'A&nalyze Selected File'
          Enabled = False
          TabOrder = 1
          OnClick = btnAnalyseClick
        end
        object btnAnalyseAll: TBitBtn
          Left = 12
          Top = 152
          Width = 120
          Height = 58
          Caption = '&Analyze All Files'
          Enabled = False
          TabOrder = 2
          OnClick = btnAnalyseAllClick
        end
        object btnClearFiles: TBitBtn
          Left = 12
          Top = 222
          Width = 120
          Height = 58
          Caption = 'Clear All Files'
          Enabled = False
          TabOrder = 3
          OnClick = btnClearFilesClick
        end
        object btnSaveResults: TBitBtn
          Left = 12
          Top = 292
          Width = 120
          Height = 58
          Caption = '&Save Analyzed Results'
          Enabled = False
          TabOrder = 4
          OnClick = btnSaveResultsClick
        end
        object btnAppendResults: TBitBtn
          Left = 12
          Top = 362
          Width = 120
          Height = 58
          Caption = '&Append Analyzed Results'
          Enabled = False
          TabOrder = 5
          OnClick = btnAppendResultsClick
        end
      end
    end
  end
  object odOpenFiles: TOpenDialog
    Filter = 
      'Executable files(*.exe;*.dll;*.bpl;*.xex;*.cpl)|*.exe;*.dll;*.bp' +
      'l;*.xex;*.cpl|All files(*.*)|*.*'
    Options = [ofAllowMultiSelect, ofEnableSizing]
    Title = 'Open Files'
    Left = 132
    Top = 260
  end
  object sdAnalyseResults: TSaveDialog
    DefaultExt = 'arf'
    Filter = 'Analyze Results File(*.arf)|*.arf|All Files(*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Analyze Results'
    Left = 132
    Top = 292
  end
  object pmAddFiles: TPopupMenu
    Left = 60
    Top = 32
    object miSelectFiles: TMenuItem
      Caption = 'Add files manually...'
      OnClick = miSelectFilesClick
    end
    object miSelectFilesFromFileList: TMenuItem
      Caption = 'Add files from file list...'
      OnClick = miSelectFilesFromFileListClick
    end
  end
  object odOpenFilesFrom: TOpenDialog
    DefaultExt = 'txt'
    Filter = 'File list(*.txt)|*.txt|All Files(*.*)|*.*'
    Title = 'Open Files from list'
    Left = 132
    Top = 228
  end
end
