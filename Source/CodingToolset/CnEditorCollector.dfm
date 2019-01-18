inherited CnEditorCollectorForm: TCnEditorCollectorForm
  Left = 300
  Top = 229
  Width = 419
  Height = 292
  Caption = 'Collector'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object tlbMain: TToolBar
    Left = 0
    Top = 0
    Width = 411
    Height = 22
    AutoSize = True
    Caption = 'tlbMain'
    DisabledImages = dmCnSharedImages.DisabledImages
    EdgeBorders = []
    Flat = True
    Images = dmCnSharedImages.Images
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object btnNew: TToolButton
      Left = 0
      Top = 0
      Action = actPageNew
    end
    object btnPageDelete: TToolButton
      Left = 23
      Top = 0
      Action = actPageDelete
    end
    object btnPageRename: TToolButton
      Left = 46
      Top = 0
      Action = actPageRename
    end
    object btn1: TToolButton
      Left = 69
      Top = 0
      Width = 8
      Caption = 'btn1'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnLoad: TToolButton
      Left = 77
      Top = 0
      Action = actEditLoad
    end
    object btnSave: TToolButton
      Left = 100
      Top = 0
      Action = actEditSave
    end
    object btn2: TToolButton
      Left = 123
      Top = 0
      Width = 8
      Caption = 'btn2'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnEditClear: TToolButton
      Left = 131
      Top = 0
      Action = actEditClear
    end
    object btnSep4: TToolButton
      Left = 154
      Top = 0
      Width = 8
      Caption = 'btnSep4'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object btnFind: TToolButton
      Left = 162
      Top = 0
      Action = actEditFind
    end
    object btnFindNext: TToolButton
      Left = 185
      Top = 0
      Action = actEditFindNext
    end
    object btn4: TToolButton
      Left = 208
      Top = 0
      Width = 8
      Caption = 'btn4'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnReplace: TToolButton
      Left = 216
      Top = 0
      Action = actEditReplace
    end
    object btnSep6: TToolButton
      Left = 239
      Top = 0
      Width = 8
      Caption = 'btnSep6'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object btnAutoPaste: TToolButton
      Left = 247
      Top = 0
      Hint = 'Auto Paste'
      Caption = 'btnAutoPaste'
      ImageIndex = 47
      Style = tbsCheck
      OnClick = btnAutoPasteClick
    end
    object btn3: TToolButton
      Left = 270
      Top = 0
      Width = 8
      Caption = 'btn3'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnImport: TToolButton
      Left = 278
      Top = 0
      Hint = 'Copy from IDE'
      Caption = 'btnImport'
      ImageIndex = 64
      OnClick = btnImportClick
    end
    object btnExport: TToolButton
      Left = 301
      Top = 0
      Hint = 'Export Selection to IDE'
      Caption = 'btnExport'
      ImageIndex = 46
      OnClick = btnExportClick
    end
    object btnSep8: TToolButton
      Left = 324
      Top = 0
      Width = 8
      Caption = 'btnSep8'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnSetFont: TToolButton
      Left = 332
      Top = 0
      Hint = 'Select Font'
      ImageIndex = 29
      OnClick = btnSetFontClick
    end
    object btnWordWrap: TToolButton
      Left = 355
      Top = 0
      Action = actEditWordWrap
    end
    object btnSep7: TToolButton
      Left = 378
      Top = 0
      Width = 8
      Caption = 'btnSep7'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object btnAbout: TToolButton
      Left = 386
      Top = 0
      Hint = 'Help'
      ImageIndex = 1
      OnClick = btnAboutClick
    end
  end
  object mmoEdit: TMemo
    Left = 0
    Top = 22
    Width = 411
    Height = 225
    Align = alClient
    Ctl3D = True
    HideSelection = False
    ParentCtl3D = False
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
    OnExit = FormDeactivate
  end
  object TabSet: TTabSet
    Left = 0
    Top = 247
    Width = 411
    Height = 18
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Tabs.Strings = (
      'Text1')
    TabIndex = 0
    OnChange = TabSetChange
  end
  object actlstEdit: TActionList
    Images = dmCnSharedImages.Images
    OnUpdate = actlstEditUpdate
    Left = 15
    Top = 194
    object actEditSave: TAction
      Category = 'Edit'
      Hint = 'Save To File'
      ImageIndex = 6
      ShortCut = 16467
      OnExecute = actEditSaveExecute
    end
    object actEditLoad: TAction
      Category = 'Edit'
      Hint = 'Load From File'
      ImageIndex = 3
      ShortCut = 16460
      OnExecute = actEditLoadExecute
    end
    object actEditFind: TAction
      Category = 'Edit'
      Hint = 'Find...'
      ImageIndex = 16
      ShortCut = 16454
      OnExecute = actEditFindExecute
    end
    object actEditFindNext: TAction
      Category = 'Edit'
      Hint = 'Find Next'
      ImageIndex = 17
      ShortCut = 114
      OnExecute = actEditFindNextExecute
    end
    object actEditReplace: TAction
      Category = 'Edit'
      Hint = 'Replace...'
      ImageIndex = 33
      ShortCut = 16466
      OnExecute = actEditReplaceExecute
    end
    object actEditWordWrap: TAction
      Category = 'Edit'
      Hint = 'Word Wrap'
      ImageIndex = 21
      OnExecute = actEditWordWrapExecute
    end
    object actPageNew: TAction
      Category = 'Page'
      Hint = 'New Page'
      ImageIndex = 12
      ShortCut = 16462
      OnExecute = actPageNewExecute
    end
    object actPageDelete: TAction
      Category = 'Page'
      Hint = 'Delete Page'
      ImageIndex = 31
      ShortCut = 16430
      OnExecute = actPageDeleteExecute
    end
    object actPageRename: TAction
      Category = 'Page'
      Hint = 'Rename Page'
      ImageIndex = 86
      ShortCut = 113
      OnExecute = actPageRenameExecute
    end
    object actEditClear: TAction
      Category = 'Edit'
      Hint = 'Clear'
      ImageIndex = 13
      OnExecute = actEditClearExecute
    end
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'txt'
    Filter = 'Text Files(*.txt)|*.txt|All Files(*.*)|*.*'
    Title = 'Open Text File'
    Left = 79
    Top = 194
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text Files(*.txt)|*.txt|All Files(*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Text File'
    Left = 143
    Top = 194
  end
  object dlgFind: TFindDialog
    OnClose = dlgFindClose
    OnShow = dlgFindShow
    Options = [frDown, frHideWholeWord, frHideUpDown]
    OnFind = dlgFindFind
    Left = 47
    Top = 194
  end
  object dlgReplace: TReplaceDialog
    OnClose = dlgReplaceClose
    OnShow = dlgReplaceShow
    Options = [frDown, frHideWholeWord, frHideUpDown]
    OnFind = dlgReplaceFind
    OnReplace = dlgReplaceReplace
    Left = 111
    Top = 194
  end
end
