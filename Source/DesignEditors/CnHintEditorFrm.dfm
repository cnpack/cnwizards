inherited CnHintEditorForm: TCnHintEditorForm
  Left = 310
  Top = 253
  AutoScroll = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Hint Property Editor'
  ClientHeight = 270
  ClientWidth = 406
  Constraints.MinHeight = 297
  Constraints.MinWidth = 414
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000700
    000000000000078888888888800007FBBBBBBBBB800007BF6666666B800007FB
    BBBBBBBB800007BF6666666B800007FBFBFBFBBB800007FF6666666B800007FF
    FBFBFBBB800007FF666FBFBB800007FFFFFB0000000007FFFFFF0BB0000007FF
    FFFF0B00000007FFFFFF00000000077777770000000000000000000000008003
    0000800300008003000080030000800300008003000080030000800300008003
    00008003000080070000800F0000801F0000803F0000807F0000FFFF0000}
  KeyPreview = True
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShortCut = FormShortCut
  PixelsPerInch = 96
  TextHeight = 13
  object lblDesc: TLabel
    Left = 8
    Top = 249
    Width = 177
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Ctrl+Enter to Confirm, TAB to Switch'
  end
  object btnOK: TButton
    Left = 245
    Top = 243
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 2
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 325
    Top = 243
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
    OnClick = btnCancelClick
  end
  object tbrMain: TToolBar
    Left = 0
    Top = 0
    Width = 406
    Height = 26
    AutoSize = True
    Caption = 'tbrMain'
    DisabledImages = dmCnSharedImages.DisabledImages
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    Flat = True
    Images = dmCnSharedImages.Images
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object tbtUndo: TToolButton
      Left = 0
      Top = 0
      Action = EditUndo
      ImageIndex = 52
    end
    object tbtSep1: TToolButton
      Left = 23
      Top = 0
      Width = 8
      Caption = 'tbtSep1'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object tbtCut: TToolButton
      Left = 31
      Top = 0
      Action = EditCut
      ImageIndex = 9
    end
    object tbtCopy: TToolButton
      Left = 54
      Top = 0
      Action = EditCopy
      ImageIndex = 10
    end
    object tbtPaste: TToolButton
      Left = 77
      Top = 0
      Action = EditPaste
      ImageIndex = 11
    end
    object tbtSep2: TToolButton
      Left = 100
      Top = 0
      Width = 8
      Caption = 'tbtSep2'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object tbtDelete: TToolButton
      Left = 108
      Top = 0
      Action = EditDelete
      ImageIndex = 13
    end
    object tbtSep3: TToolButton
      Left = 131
      Top = 0
      Width = 8
      Caption = 'tbtSep3'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object tbtSelectAll: TToolButton
      Left = 139
      Top = 0
      Action = EditSelectAll
      ImageIndex = 53
    end
    object tbtSep7: TToolButton
      Left = 162
      Top = 0
      Width = 8
      Caption = 'tbtSep7'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object tbtFind: TToolButton
      Left = 170
      Top = 0
      Action = EditFind
      ImageIndex = 16
    end
    object tbtFindNext: TToolButton
      Left = 193
      Top = 0
      Action = EditFindNext
      ImageIndex = 17
    end
    object tbtReplace: TToolButton
      Left = 216
      Top = 0
      Action = EditReplace
      ImageIndex = 46
    end
    object tbtSep4: TToolButton
      Left = 239
      Top = 0
      Width = 8
      Caption = 'tbtSep4'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object tbtSetFont: TToolButton
      Left = 247
      Top = 0
      Action = SetFont
      ImageIndex = 29
    end
    object tbtSep5: TToolButton
      Left = 270
      Top = 0
      Width = 8
      Caption = 'tbtSep5'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object tbtSave: TToolButton
      Left = 278
      Top = 0
      Action = EditSave
      ImageIndex = 6
    end
    object tbtLoad: TToolButton
      Left = 301
      Top = 0
      Action = EditLoad
      ImageIndex = 3
    end
    object tbtSep6: TToolButton
      Left = 324
      Top = 0
      Width = 8
      Caption = 'tbtSep6'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object tbtAbout: TToolButton
      Left = 332
      Top = 0
      Action = HelpAbout
      ImageIndex = 1
    end
  end
  object pgcMain: TPageControl
    Left = 0
    Top = 26
    Width = 406
    Height = 211
    ActivePage = tshShort
    Anchors = [akLeft, akTop, akRight, akBottom]
    Style = tsFlatButtons
    TabOrder = 1
    object tshShort: TTabSheet
      Caption = 'Short Hint'
      object memShort: TMemo
        Left = 0
        Top = 0
        Width = 398
        Height = 180
        Align = alClient
        Ctl3D = True
        ParentCtl3D = False
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object tshLong: TTabSheet
      Caption = 'Long Hint'
      ImageIndex = 1
      object memLong: TMemo
        Left = 0
        Top = 0
        Width = 398
        Height = 180
        Align = alClient
        Ctl3D = True
        ParentCtl3D = False
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object tshImageIndex: TTabSheet
      Caption = 'Image Index'
      ImageIndex = 2
      TabVisible = False
      object lvImages: TListView
        Left = 0
        Top = 0
        Width = 398
        Height = 180
        Align = alClient
        Columns = <>
        TabOrder = 0
      end
    end
  end
  object alsEdit: TActionList
    Left = 80
    Top = 56
    object EditCopy: TEditCopy
      Category = 'Edit'
      Caption = 'Copy'
      Hint = 'Copy Selected Text'
      ImageIndex = 0
      ShortCut = 16451
    end
    object EditCut: TEditCut
      Category = 'Edit'
      Caption = 'Cut'
      Hint = 'Cut Selected Text'
      ImageIndex = 1
      ShortCut = 16472
    end
    object EditDelete: TEditDelete
      Category = 'Edit'
      Caption = 'Delete'
      Hint = 'Delete Selected Text'
      ImageIndex = 2
      ShortCut = 46
    end
    object EditPaste: TEditPaste
      Category = 'Edit'
      Caption = 'Paste'
      Hint = 'Paste From Clipboard'
      ImageIndex = 3
      ShortCut = 16470
    end
    object EditSelectAll: TEditSelectAll
      Category = 'Edit'
      Caption = 'Select All'
      Hint = 'Select All Text'
      ImageIndex = 5
      ShortCut = 16449
    end
    object EditUndo: TEditUndo
      Category = 'Edit'
      Caption = 'Undo'
      Hint = 'Undo Operation'
      ImageIndex = 4
      ShortCut = 32776
    end
    object EditSave: TAction
      Category = 'Edit'
      Caption = 'Save...'
      Hint = 'Save Current Text'
      ImageIndex = 7
      ShortCut = 16467
      OnExecute = EditSaveExecute
      OnUpdate = EditCheckNullUpdate
    end
    object EditLoad: TAction
      Category = 'Edit'
      Caption = 'Open...'
      Hint = 'Import From Text File'
      ImageIndex = 8
      ShortCut = 16460
      OnExecute = EditLoadExecute
    end
    object HelpAbout: TAction
      Category = 'Help'
      Caption = 'About'
      Hint = 'About the Editor'
      ImageIndex = 6
      ShortCut = 112
      OnExecute = HelpAboutExecute
    end
    object SetFont: TAction
      Category = 'Set'
      Caption = 'Font'
      Hint = 'Select Font'
      ImageIndex = 9
      OnExecute = SetFontExecute
    end
    object EditFind: TAction
      Category = 'Edit'
      Caption = 'Search...'
      Hint = 'Search for Text'
      ImageIndex = 10
      ShortCut = 16454
      OnExecute = EditFindExecute
      OnUpdate = EditCheckNullUpdate
    end
    object EditFindNext: TAction
      Category = 'Edit'
      Caption = 'Search Next'
      Hint = 'Search Next'
      ImageIndex = 12
      ShortCut = 114
      OnExecute = EditFindNextExecute
      OnUpdate = EditCheckNullUpdate
    end
    object EditReplace: TAction
      Category = 'Edit'
      Caption = 'Replace...'
      Hint = 'Replace Text'
      ImageIndex = 11
      ShortCut = 16466
      OnExecute = EditReplaceExecute
      OnUpdate = EditCheckNullUpdate
    end
  end
  object OD: TOpenDialog
    Filter = 'Text Files(*.txt)|*.txt|Any File(*.*)|*.*'
    Title = 'Open Text File'
    Left = 112
    Top = 56
  end
  object SD: TSaveDialog
    Filter = 'Text Files(*.txt)|*.txt|Any File(*.*)|*.*'
    Title = 'Save to Text File'
    Left = 144
    Top = 56
  end
  object FD: TFindDialog
    OnClose = FDClose
    OnShow = FDShow
    Options = [frDown, frDisableUpDown, frDisableWholeWord]
    OnFind = FDFind
    Left = 184
    Top = 56
  end
  object RD: TReplaceDialog
    OnClose = RDClose
    OnShow = RDShow
    Options = [frDown, frDisableUpDown, frDisableWholeWord]
    OnFind = RDFind
    OnReplace = RDReplace
    Left = 220
    Top = 56
  end
end
