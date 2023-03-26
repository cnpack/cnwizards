object CnDirListForm: TCnDirListForm
  Left = 365
  Top = 118
  Width = 560
  Height = 432
  Caption = 'Directory enumerator'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 552
    Height = 85
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 10
      Width = 48
      Height = 13
      Caption = 'Directory:'
      FocusControl = edtDir
    end
    object btnDir: TSpeedButton
      Left = 522
      Top = 5
      Width = 23
      Height = 22
      Anchors = [akTop, akRight]
      Caption = '...'
      OnClick = btnDirClick
    end
    object Label3: TLabel
      Left = 8
      Top = 59
      Width = 164
      Height = 13
      Caption = 'File Masks (such as *.dfm;*.pas) :'
      FocusControl = edtMasks
    end
    object edtDir: TEdit
      Left = 62
      Top = 6
      Width = 458
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = edtDirChange
      OnKeyUp = edtDirKeyUp
    end
    object chbSubDir: TCheckBox
      Left = 8
      Top = 33
      Width = 129
      Height = 17
      Caption = 'Include Subdirectories'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = chbSubDirClick
    end
    object chbRelative: TCheckBox
      Left = 144
      Top = 33
      Width = 145
      Height = 17
      Caption = 'Relative Path'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = chbSubDirClick
    end
    object chbGroup: TCheckBox
      Left = 299
      Top = 33
      Width = 110
      Height = 17
      Caption = 'Group By Directory'
      TabOrder = 3
      Visible = False
      OnClick = chbSubDirClick
    end
    object chbPrefix: TCheckBox
      Left = 391
      Top = 33
      Width = 90
      Height = 17
      Caption = 'Include Prefix '#39'.\'#39' or '#39'\'#39
      Enabled = False
      TabOrder = 4
      Visible = False
      OnClick = chbSubDirClick
    end
    object edtMasks: TEdit
      Left = 178
      Top = 56
      Width = 263
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 5
      Text = '*.dfm;*.pas'
      OnContextPopup = edtMasksContextPopup
    end
    object chbCaseSensitive: TCheckBox
      Left = 448
      Top = 58
      Width = 97
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Case &sensitive'
      TabOrder = 6
    end
  end
  object GridPanel1: TPanel
    Left = 0
    Top = 85
    Width = 552
    Height = 279
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 289
      Top = 0
      Width = 3
      Height = 279
      Cursor = crHSplit
    end
    object tvResult: TTreeView
      Left = 0
      Top = 0
      Width = 289
      Height = 279
      Align = alLeft
      Indent = 19
      PopupMenu = pmTV
      ReadOnly = True
      RightClickSelect = True
      TabOrder = 0
      OnDeletion = tvResultDeletion
      OnKeyDown = tvResultKeyDown
    end
    object mmoResult: TMemo
      Left = 292
      Top = 0
      Width = 260
      Height = 279
      Align = alClient
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 364
    Width = 552
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnAbortSearch: TButton
      Left = 7
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Abort'
      Default = True
      Enabled = False
      TabOrder = 1
      Visible = False
      OnClick = btnAbortSearchClick
    end
    object btnSaveTXT: TButton
      Left = 470
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Save...'
      Enabled = False
      TabOrder = 6
      OnClick = btnSaveTXTClick
    end
    object btnList: TButton
      Left = 7
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Enumerate'
      Default = True
      Enabled = False
      TabOrder = 0
      OnClick = btnListClick
    end
    object chbAutoSync: TCheckBox
      Left = 394
      Top = 12
      Width = 127
      Height = 17
      Caption = 'Auto generate'
      Checked = True
      State = cbChecked
      TabOrder = 5
      OnClick = chbAutoSyncClick
    end
    object btnSynchronize: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Generate text'
      TabOrder = 2
      OnClick = btnSynchronizeClick
    end
    object chbSyncDirs: TCheckBox
      Left = 204
      Top = 12
      Width = 85
      Height = 17
      Caption = 'Directories'
      TabOrder = 3
      OnClick = chbAutoSyncClick
    end
    object chbSyncFiles: TCheckBox
      Left = 298
      Top = 12
      Width = 87
      Height = 17
      Caption = 'Files'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = chbAutoSyncClick
    end
  end
  object SDText: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'TXT Files(*.txt)|*.txt|CSV Files(*.csv)|*.csv'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Result As'
    Left = 320
    Top = 248
  end
  object pmTV: TPopupMenu
    OnPopup = pmTVPopup
    Left = 332
    Top = 260
    object miSaveTree: TMenuItem
      Caption = 'Save...'
      OnClick = miSaveTreeClick
    end
    object miLoadTree: TMenuItem
      Tag = -1
      Caption = 'Load...'
      OnClick = miLoadTreeClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object ExpandAll1: TMenuItem
      Caption = 'Expand all directories'
      OnClick = ExpandAll1Click
    end
    object CollaspeAll1: TMenuItem
      Caption = 'Collapse all directories'
      OnClick = CollaspeAll1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miDeleteSelected: TMenuItem
      Caption = 'Delete selected directory/file from tree'
      OnClick = miDeleteSelectedClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miDelByMasks: TMenuItem
      Caption = 'Delete directories/files from tree by mask...'
      OnClick = miDelByMasksClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Deleteemptydirectoriesfromtree1: TMenuItem
      Caption = 'Delete empty directories from tree'
      OnClick = Deleteemptydirectoriesfromtree1Click
    end
  end
  object tmPerformUpdateText: TTimer
    Enabled = False
    Interval = 250
    OnTimer = tmPerformUpdateTextTimer
    Left = 344
    Top = 268
  end
  object pmMasks: TPopupMenu
    AutoHotkeys = maManual
    Left = 224
    Top = 56
  end
  object ODTree: TOpenDialog
    DefaultExt = 'tvf'
    Filter = 'TreeView file(*.tvf)|*.tvf'
    Title = 'Open tree file'
    Left = 284
    Top = 204
  end
  object SDTree: TSaveDialog
    DefaultExt = 'tvf'
    Filter = 'TreeView file(*.tvf)|*.tvf'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save tree file'
    Left = 280
    Top = 232
  end
end
