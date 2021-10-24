inherited CnSourceDiffForm: TCnSourceDiffForm
  Left = 244
  Top = 100
  AutoScroll = False
  Caption = 'Source Code Compare'
  ClientHeight = 480
  ClientWidth = 752
  Menu = MainMenu
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlDisplay: TPanel
    Left = 733
    Top = 30
    Width = 19
    Height = 431
    Align = alRight
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    Visible = False
    object pbFile: TPaintBox
      Left = 8
      Top = 2
      Width = 9
      Height = 427
      Align = alClient
      Color = clBtnFace
      ParentColor = False
      OnMouseDown = pbFileMouseDown
      OnPaint = pbFilePaint
    end
    object pbPos: TPaintBox
      Left = 2
      Top = 2
      Width = 6
      Height = 427
      Align = alLeft
      Color = clBtnFace
      ParentColor = False
      OnPaint = pbPosPaint
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 30
    Width = 733
    Height = 431
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 1
    object Splitter2: TSplitter
      Left = 0
      Top = 349
      Width = 733
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    object pnlMain: TPanel
      Left = 0
      Top = 0
      Width = 733
      Height = 349
      Align = alClient
      BevelOuter = bvNone
      Caption = 'pnlMain'
      TabOrder = 0
      object Splitter1: TSplitter
        Left = 361
        Top = 0
        Width = 3
        Height = 349
        Cursor = crHSplit
      end
      object pnlLeft: TPanel
        Left = 0
        Top = 0
        Width = 361
        Height = 349
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'pnlLeft'
        TabOrder = 0
        object pnlCaptionLeft: TPanel
          Left = 0
          Top = 0
          Width = 361
          Height = 22
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvLowered
          TabOrder = 0
          OnResize = pnlCaptionLeftResize
          object btnFileKind1: TBitBtn
            Left = 300
            Top = 1
            Width = 44
            Height = 20
            Hint = 'Set File 1 Content'
            Anchors = [akTop, akRight]
            Caption = 'File'
            TabOrder = 1
            OnClick = btnFileKind1Click
            Glyph.Data = {
              76010000424D760100000000000036000000280000000A0000000A0000000100
              1800000000004001000000000000000000000000000000000000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFF000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000FFFFFF000000
              000000000000000000000000000000000000FFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000}
            Layout = blGlyphRight
            Spacing = 0
          end
          object btnHistory1: TBitBtn
            Left = 344
            Top = 1
            Width = 16
            Height = 20
            Hint = 'Opened File History'
            Anchors = [akTop, akRight]
            TabOrder = 2
            OnClick = btnHistory1Click
            Glyph.Data = {
              76010000424D760100000000000036000000280000000A0000000A0000000100
              1800000000004001000000000000000000000000000000000000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFF000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000FFFFFF000000
              000000000000000000000000000000000000FFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000}
          end
          object btnOpenFile1: TBitBtn
            Left = 280
            Top = 1
            Width = 20
            Height = 20
            Action = actOpen1
            Anchors = [akTop, akRight]
            Caption = '...'
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 0
          end
          object btnPaste1: TBitBtn
            Left = 260
            Top = 1
            Width = 20
            Height = 20
            Action = actPaste1
            Anchors = [akTop, akRight]
            TabOrder = 3
            Glyph.Data = {
              36030000424D3603000000000000360000002800000010000000100000000100
              1800000000000003000000000000000000000000000000000000FF00FFFF00FF
              FF00FF299CDE299CDEA57B73A57B73A57B73A57B73A57B73A57B73A57B73A57B
              73A57B73A57B73FF00FFFF00FFFF00FF299CDE8CD6EF84D6F7CEC6BDFFEFDEF7
              EFE7F7EFDEF7EFDEF7EFDEF7EFDEF7EFDEF7EFDEA57B73FF00FFFF00FF299CDE
              A5E7FF94EFFF8CF7FFCEC6BDF7E7D6F7E7D6F7DEC6F7DEC6F7DEC6F7DEBDF7DE
              C6F7E7D6A57B73FF00FFFF00FF299CDEA5E7FF94EFFF84EFFFCEC6BDF7E7DEFF
              E7CEF7DEBDF7DEBDF7DEBDF7DEBDF7DEC6F7E7D6A57B73FF00FFFF00FF299CDE
              ADEFFFA5EFFF94EFFFCEC6BDF7E7E7F7E7D6F7DEC6F7DEC6F7DEBDF7DEBDF7DE
              C6F7E7D6A57B73FF00FFFF00FF299CDEB5EFFFADEFFFA5EFFFCEC6BDF7EFE7F7
              EFDEFFE7CEFFE7CEFFE7CEF7DEC6F7E7D6EFE7DEA57B73FF00FFFF00FF299CDE
              BDEFFFBDF7FFADF7FFCEC6BDFFF7EFFFE7CEFFDEBDF7DEBDF7DEBDFFDEB5F7DE
              C6F7EFE7A57B73FF00FFFF00FF299CDEC6EFFFCEF7FFBDF7FFCEC6BDFFF7F7FF
              F7EFF7EFE7F7EFE7F7EFDEF7EFDEF7EFE7EFE7DEA57B73FF00FFFF00FF299CDE
              CEEFFFDEF7FFCEF7FFCEC6BDFFF7F7FFFFFFFFFFFFFFF7F7F7F7F7EFE7DED6BD
              B5C6ADA5A57B73FF00FFFF00FF299CDECEEFFFE7FFFFDEF7FFCEC6BDFFF7F7FF
              FFFFFFFFFFFFFFFFFFFFFFDECEC6E7AD73C6AD8CFF00FFFF00FFFF00FF299CDE
              D6F7FFF7FFFFE7FFFFCEC6BDFFEFE7FFF7EFFFF7EFFFEFEFFFF7EFE7C6BDC6AD
              8C299CDEFF00FFFF00FFFF00FF299CDEDEF7FFFFFFFFF7FFFFCEC6BDCEC6BDCE
              C6BDCEC6BDCEC6BDCEC6BDCEC6BD84C6DE299CDEFF00FFFF00FFFF00FF299CDE
              DEF7FFF7F7F7ADC6CEA5C6CEA5C6CEA5C6CEA5C6CEA5C6CEB5D6D6DEFFFF84D6
              F7299CDEFF00FFFF00FFFF00FF299CDEDEF7FFDECEC6BDA59CA57B73A57B73A5
              7B73A57B73A57B73BD9C94E7EFE794DEF7299CDEFF00FFFF00FFFF00FFFF00FF
              299CDEB5D6E7949C9CE7DED6F7E7D6F7E7D6F7E7D6CEC6BD849CA58CCEE7299C
              DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF299CDE299CDE9C948C9C948C9C
              948C9C948C9C948C299CDE299CDEFF00FFFF00FFFF00FFFF00FF}
            Layout = blGlyphRight
          end
        end
      end
      object pnlRight: TPanel
        Left = 364
        Top = 0
        Width = 369
        Height = 349
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlRight'
        TabOrder = 1
        object pnlCaptionRight: TPanel
          Left = 0
          Top = 0
          Width = 369
          Height = 22
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvLowered
          TabOrder = 0
          OnResize = pnlCaptionRightResize
          object btnFileKind2: TBitBtn
            Left = 315
            Top = 1
            Width = 44
            Height = 20
            Hint = 'Set File 2 Content'
            Anchors = [akTop, akRight]
            Caption = 'File'
            TabOrder = 1
            OnClick = btnFileKind2Click
            Glyph.Data = {
              76010000424D760100000000000036000000280000000A0000000A0000000100
              1800000000004001000000000000000000000000000000000000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFF000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000FFFFFF000000
              000000000000000000000000000000000000FFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000}
            Layout = blGlyphRight
            Spacing = 0
          end
          object btnHistory2: TBitBtn
            Left = 359
            Top = 1
            Width = 16
            Height = 20
            Hint = 'Opened File History'
            Anchors = [akTop, akRight]
            TabOrder = 2
            OnClick = btnHistory2Click
            Glyph.Data = {
              76010000424D760100000000000036000000280000000A0000000A0000000100
              1800000000004001000000000000000000000000000000000000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFF000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000FFFFFF000000
              000000000000000000000000000000000000FFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000}
          end
          object btnOpenFile2: TBitBtn
            Left = 295
            Top = 1
            Width = 20
            Height = 20
            Action = actOpen2
            Anchors = [akTop, akRight]
            Caption = '...'
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 0
          end
          object btnPaste2: TBitBtn
            Left = 275
            Top = 1
            Width = 20
            Height = 20
            Action = actPaste2
            Anchors = [akTop, akRight]
            TabOrder = 3
            Glyph.Data = {
              36030000424D3603000000000000360000002800000010000000100000000100
              1800000000000003000000000000000000000000000000000000FF00FFFF00FF
              FF00FF299CDE299CDEA57B73A57B73A57B73A57B73A57B73A57B73A57B73A57B
              73A57B73A57B73FF00FFFF00FFFF00FF299CDE8CD6EF84D6F7CEC6BDFFEFDEF7
              EFE7F7EFDEF7EFDEF7EFDEF7EFDEF7EFDEF7EFDEA57B73FF00FFFF00FF299CDE
              A5E7FF94EFFF8CF7FFCEC6BDF7E7D6F7E7D6F7DEC6F7DEC6F7DEC6F7DEBDF7DE
              C6F7E7D6A57B73FF00FFFF00FF299CDEA5E7FF94EFFF84EFFFCEC6BDF7E7DEFF
              E7CEF7DEBDF7DEBDF7DEBDF7DEBDF7DEC6F7E7D6A57B73FF00FFFF00FF299CDE
              ADEFFFA5EFFF94EFFFCEC6BDF7E7E7F7E7D6F7DEC6F7DEC6F7DEBDF7DEBDF7DE
              C6F7E7D6A57B73FF00FFFF00FF299CDEB5EFFFADEFFFA5EFFFCEC6BDF7EFE7F7
              EFDEFFE7CEFFE7CEFFE7CEF7DEC6F7E7D6EFE7DEA57B73FF00FFFF00FF299CDE
              BDEFFFBDF7FFADF7FFCEC6BDFFF7EFFFE7CEFFDEBDF7DEBDF7DEBDFFDEB5F7DE
              C6F7EFE7A57B73FF00FFFF00FF299CDEC6EFFFCEF7FFBDF7FFCEC6BDFFF7F7FF
              F7EFF7EFE7F7EFE7F7EFDEF7EFDEF7EFE7EFE7DEA57B73FF00FFFF00FF299CDE
              CEEFFFDEF7FFCEF7FFCEC6BDFFF7F7FFFFFFFFFFFFFFF7F7F7F7F7EFE7DED6BD
              B5C6ADA5A57B73FF00FFFF00FF299CDECEEFFFE7FFFFDEF7FFCEC6BDFFF7F7FF
              FFFFFFFFFFFFFFFFFFFFFFDECEC6E7AD73C6AD8CFF00FFFF00FFFF00FF299CDE
              D6F7FFF7FFFFE7FFFFCEC6BDFFEFE7FFF7EFFFF7EFFFEFEFFFF7EFE7C6BDC6AD
              8C299CDEFF00FFFF00FFFF00FF299CDEDEF7FFFFFFFFF7FFFFCEC6BDCEC6BDCE
              C6BDCEC6BDCEC6BDCEC6BDCEC6BD84C6DE299CDEFF00FFFF00FFFF00FF299CDE
              DEF7FFF7F7F7ADC6CEA5C6CEA5C6CEA5C6CEA5C6CEA5C6CEB5D6D6DEFFFF84D6
              F7299CDEFF00FFFF00FFFF00FF299CDEDEF7FFDECEC6BDA59CA57B73A57B73A5
              7B73A57B73A57B73BD9C94E7EFE794DEF7299CDEFF00FFFF00FFFF00FFFF00FF
              299CDEB5D6E7949C9CE7DED6F7E7D6F7E7D6F7E7D6CEC6BD849CA58CCEE7299C
              DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF299CDE299CDE9C948C9C948C9C
              948C9C948C9C948C299CDE299CDEFF00FFFF00FFFF00FFFF00FF}
            Layout = blGlyphRight
          end
        end
      end
    end
    object pnlMerge: TPanel
      Left = 0
      Top = 352
      Width = 733
      Height = 79
      Align = alBottom
      BevelOuter = bvNone
      Caption = 'pnlMerge'
      TabOrder = 1
      Visible = False
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 461
    Width = 752
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Style = psOwnerDraw
        Text = '+'
        Width = 18
      end
      item
        Alignment = taCenter
        Style = psOwnerDraw
        Text = '!'
        Width = 18
      end
      item
        Alignment = taCenter
        Style = psOwnerDraw
        Text = '-'
        Width = 18
      end
      item
        Width = 50
      end>
    ParentFont = True
    SimplePanel = False
    UseSystemFont = False
    OnMouseUp = StatusBar1MouseUp
    OnDrawPanel = StatusBar1DrawPanel
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 752
    Height = 30
    BorderWidth = 1
    Caption = 'ToolBar'
    DisabledImages = dmCnSharedImages.DisabledImages
    Flat = True
    Images = dmCnSharedImages.Images
    Indent = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object tbSaveMerged: TToolButton
      Left = 2
      Top = 0
      Action = actSaveMerged
      AutoSize = True
    end
    object ToolButton8: TToolButton
      Left = 25
      Top = 0
      Width = 8
      Caption = 'ToolButton8'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object tbCompare: TToolButton
      Left = 33
      Top = 0
      Action = actCompare
      AutoSize = True
    end
    object tbCompareEx: TToolButton
      Left = 56
      Top = 0
      Action = actCompareEx
      AutoSize = True
    end
    object tbCancel: TToolButton
      Left = 79
      Top = 0
      Action = actCancel
      AutoSize = True
    end
    object ToolButton11: TToolButton
      Left = 102
      Top = 0
      Width = 8
      Caption = 'ToolButton11'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object tbNextDiff: TToolButton
      Left = 110
      Top = 0
      Action = actNextDiff
      AutoSize = True
    end
    object tbPrioDiff: TToolButton
      Left = 133
      Top = 0
      Action = actPrioDiff
      AutoSize = True
    end
    object tbGoto: TToolButton
      Left = 156
      Top = 0
      Action = actGoto
      AutoSize = True
    end
    object ToolButton4: TToolButton
      Left = 179
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 12
      Style = tbsSeparator
    end
    object tbMerge: TToolButton
      Left = 187
      Top = 0
      AutoSize = True
      Caption = '&Merge File'
      Enabled = False
      ImageIndex = 47
      MenuItem = mnuMergeOptions
      Style = tbsDropDown
      OnClick = tbMergeClick
    end
    object tbMergeFocusedText: TToolButton
      Left = 227
      Top = 0
      Action = actMergeFocusedText
      AutoSize = True
    end
    object tbEditFocusedText: TToolButton
      Left = 250
      Top = 0
      Action = actEditFocusedText
      AutoSize = True
    end
    object ToolButton9: TToolButton
      Left = 273
      Top = 0
      Width = 8
      Caption = 'ToolButton9'
      ImageIndex = 13
      Style = tbsSeparator
    end
    object tbSplitHorizontally: TToolButton
      Left = 281
      Top = 0
      Action = actSplitHorizontally
      AutoSize = True
    end
    object tbFont: TToolButton
      Left = 304
      Top = 0
      Action = actFont
      AutoSize = True
    end
    object ToolButton1: TToolButton
      Left = 327
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object tbHelp: TToolButton
      Left = 335
      Top = 0
      Action = actHelp
      AutoSize = True
    end
    object ToolButton13: TToolButton
      Left = 358
      Top = 0
      Width = 8
      Caption = 'ToolButton13'
      ImageIndex = 10
      Style = tbsSeparator
    end
    object tbClose: TToolButton
      Left = 366
      Top = 0
      Action = actClose
      AutoSize = True
    end
  end
  object MainMenu: TMainMenu
    Images = dmCnSharedImages.Images
    Left = 48
    Top = 64
    object File1: TMenuItem
      Caption = '&File'
      object mnuOpen1: TMenuItem
        Action = actOpen1
      end
      object mnuOpen2: TMenuItem
        Action = actOpen2
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuSaveMerged: TMenuItem
        Action = actSaveMerged
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object mnuExit: TMenuItem
        Action = actClose
      end
    end
    object Options1: TMenuItem
      Caption = '&Options'
      object mnuIgnoreBlanks: TMenuItem
        Action = actIgnoreBlanks
      end
      object mnuIgnoreCase: TMenuItem
        Action = actIgnoreCase
      end
      object mnuShowDiffsOnly: TMenuItem
        Action = actShowDiffOnly
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mnuSplitHorizontally: TMenuItem
        Action = actSplitHorizontally
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mnuHighlightColors: TMenuItem
        Caption = 'Highlight &Color'
        object Added1: TMenuItem
          Action = actAddColor
        end
        object Modified1: TMenuItem
          Action = actModColor
        end
        object Deleted1: TMenuItem
          Action = actDelColor
        end
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object mnuFont: TMenuItem
        Action = actFont
      end
    end
    object mnuActions: TMenuItem
      Caption = 'O&peration'
      object mnuCompare: TMenuItem
        Action = actCompare
      end
      object mnuCompareEx: TMenuItem
        Action = actCompareEx
      end
      object mnuCancel: TMenuItem
        Action = actCancel
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object mnuNextDiff: TMenuItem
        Action = actNextDiff
      end
      object mnuPrioDiff: TMenuItem
        Action = actPrioDiff
      end
      object mnuGoto: TMenuItem
        Action = actGoto
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuMergeOptions: TMenuItem
        Caption = '&Merge File'
        Enabled = False
        ImageIndex = 47
        object mnuMergeFromFile1: TMenuItem
          Action = actMergeFromFile1
        end
        object mnuMergeFromFile2: TMenuItem
          Action = actMergeFromFile2
        end
        object mnuMergeFromNeither: TMenuItem
          Action = actMergeFromNeither
        end
      end
      object mnuMergeFocusedText: TMenuItem
        Action = actMergeFocusedText
      end
      object mnuEditFocusedText: TMenuItem
        Action = actEditFocusedText
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object Contents1: TMenuItem
        Action = actHelp
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'Delphi Source Files(*.pas;*.dpr)|*.pas;*.dpr|C++Builder Source F' +
      'iles(*.c;*.cpp;*.h;*.hpp)|*.c;*.cpp;*.h;*.hpp|Form Files(*.dfm;*' +
      '.xfm)|*.dfm;*.xfm|Any File(*.*)|*.*'
    Options = [ofReadOnly, ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofFileMustExist]
    Left = 88
    Top = 64
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 8
    Top = 64
  end
  object ColorDialog: TColorDialog
    Ctl3D = True
    Options = [cdFullOpen]
    Left = 128
    Top = 64
  end
  object SaveDialog: TSaveDialog
    Filter = 
      'Delphi Source Files(*.pas;*.dpr)|*.pas;*.dpr|C++Builder Source F' +
      'iles(*.c;*.cpp;*.h;*.hpp)|*.c;*.cpp;*.h;*.hpp|Form Files(*.dfm;*' +
      '.xfm)|*.dfm;*.xfm|Any File(*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly]
    Left = 168
    Top = 64
  end
  object ActionList: TActionList
    Images = dmCnSharedImages.Images
    OnUpdate = ActionListUpdate
    Left = 208
    Top = 64
    object actOpen1: TAction
      Category = 'File'
      Caption = 'Open F&ile...'
      Hint = 'Open File 1'
      ShortCut = 16433
      OnExecute = actOpen1Execute
    end
    object actOpen2: TAction
      Category = 'File'
      Caption = 'Open Fi&le...'
      Hint = 'Open File 2'
      ShortCut = 16434
      OnExecute = actOpen2Execute
    end
    object actCompareEx: TAction
      Category = 'Actions'
      Caption = '&Refresh and Re-compare'
      Hint = 'Refresh and Re-compare'
      ImageIndex = 51
      ShortCut = 16504
      OnExecute = actCompareExExecute
    end
    object actGoto: TAction
      Category = 'Actions'
      Caption = 'Return &to Source Code Editor'
      Hint = 'Return to Source Code Editor'
      ImageIndex = 34
      ShortCut = 16458
      OnExecute = actGotoExecute
    end
    object actSaveMerged: TAction
      Category = 'File'
      Caption = '&Save Merged File...'
      Hint = 'Save Merged File'
      ImageIndex = 6
      ShortCut = 16467
      OnExecute = actSaveMergedExecute
    end
    object actClose: TAction
      Category = 'File'
      Caption = 'E&xit'
      Hint = 'Exit'
      ImageIndex = 0
      ShortCut = 16499
      OnExecute = actCloseExecute
    end
    object actIgnoreBlanks: TAction
      Category = 'Options'
      Caption = 'Ignore &Blank Space'
      Hint = 'Ignore Blank Space'
      ShortCut = 16450
      OnExecute = actIgnoreBlanksExecute
    end
    object actIgnoreCase: TAction
      Category = 'Options'
      Caption = '&Ignore Case'
      Hint = 'Ignore Case'
      ShortCut = 16457
      OnExecute = actIgnoreCaseExecute
    end
    object actShowDiffOnly: TAction
      Category = 'Options'
      Caption = 'Only &Difference'
      Hint = 'Only Difference'
      ShortCut = 16452
      OnExecute = actShowDiffOnlyExecute
    end
    object actSplitHorizontally: TAction
      Category = 'Options'
      Caption = '&Horizontal Split'
      Hint = 'Horizontal Split'
      ImageIndex = 30
      ShortCut = 16456
      OnExecute = actSplitHorizontallyExecute
    end
    object actAddColor: TAction
      Category = 'Options'
      Caption = '&Added Line'
      Hint = 'Set Color of Added Line'
      OnExecute = actAddColorExecute
    end
    object actModColor: TAction
      Category = 'Options'
      Caption = '&Modified Line'
      Hint = 'Set Color of Modified Line'
      OnExecute = actModColorExecute
    end
    object actDelColor: TAction
      Category = 'Options'
      Caption = 'Deleted Line'
      Hint = 'Set Color of Deleted Line'
      OnExecute = actDelColorExecute
    end
    object actFont: TAction
      Category = 'Options'
      Caption = '&Font...'
      Hint = 'Set Font'
      ImageIndex = 29
      ShortCut = 16454
      OnExecute = actFontExecute
    end
    object actCompare: TAction
      Category = 'Actions'
      Caption = 'Source Code &Compare'
      Hint = 'Source Code Compare'
      ImageIndex = 39
      ShortCut = 120
      OnExecute = actCompareExecute
    end
    object actCancel: TAction
      Category = 'Actions'
      Caption = 'Abort Compariso&n'
      Enabled = False
      Hint = 'Abort Comparison'
      ImageIndex = 50
      ShortCut = 16497
      OnExecute = actCancelExecute
    end
    object actMergeFromFile1: TAction
      Category = 'Actions'
      Caption = 'Top/&Left File is Primary'
      Hint = 'Merge primarily for top/left file'
      OnExecute = actMergeFromExecute
    end
    object actMergeFromFile2: TAction
      Category = 'Actions'
      Caption = 'Bottom/&Right File is Primary'
      Hint = 'Merge primarily for bottom/right file'
      OnExecute = actMergeFromExecute
    end
    object actMergeFromNeither: TAction
      Category = 'Actions'
      Caption = 'Inte&rsection of the Two Files'
      Hint = 'Intersection of the Two Files'
      OnExecute = actMergeFromExecute
    end
    object actMergeFocusedText: TAction
      Category = 'Actions'
      Caption = '&Merge Current Text'
      Hint = 'Merge Current Text'
      ImageIndex = 46
      ShortCut = 16461
      OnExecute = actMergeFocusedTextExecute
    end
    object actEditFocusedText: TAction
      Category = 'Actions'
      Caption = '&Edit Current Text'
      Hint = 'Edit Current Text'
      ImageIndex = 12
      ShortCut = 16453
      OnExecute = actEditFocusedTextExecute
    end
    object actHelp: TAction
      Category = 'Help'
      Caption = 'Display &Help'
      Hint = 'Display Help'
      ImageIndex = 1
      ShortCut = 112
      OnExecute = actHelpExecute
    end
    object actNextDiff: TAction
      Category = 'Actions'
      Caption = '&Next Difference'
      Hint = 'Next Difference'
      ImageIndex = 45
      ShortCut = 16424
      OnExecute = actNextDiffExecute
    end
    object actPrioDiff: TAction
      Category = 'Actions'
      Caption = '&Previous Difference'
      Hint = 'Previous Difference'
      ImageIndex = 44
      ShortCut = 16422
      OnExecute = actPrioDiffExecute
    end
    object actPaste1: TAction
      Category = 'File'
      Hint = 'Paste'
      OnExecute = actPaste1Execute
    end
    object actPaste2: TAction
      Category = 'File'
      Hint = 'Paste'
      OnExecute = actPaste2Execute
    end
  end
  object pmFileKind1: TPopupMenu
    Images = dmCnSharedImages.Images
    OnPopup = pmFileKind1Popup
    Left = 8
    Top = 112
    object pmiDiskFile1: TMenuItem
      Caption = '&Save File'
      Checked = True
      RadioItem = True
      OnClick = pmiDiskFile1Click
    end
    object pmiEditorBuff1: TMenuItem
      Tag = 1
      Caption = '&Editor Buffer'
      RadioItem = True
      OnClick = pmiDiskFile1Click
    end
    object pmiBackupFile1: TMenuItem
      Tag = 2
      Caption = '&Backup File'
      RadioItem = True
      OnClick = pmiDiskFile1Click
    end
  end
  object pmHistory1: TPopupMenu
    Images = dmCnSharedImages.Images
    OnPopup = pmHistory1Popup
    Left = 48
    Top = 112
  end
  object pmHistory2: TPopupMenu
    Images = dmCnSharedImages.Images
    OnPopup = pmHistory2Popup
    Left = 128
    Top = 112
  end
  object pmFileKind2: TPopupMenu
    Images = dmCnSharedImages.Images
    OnPopup = pmFileKind2Popup
    Left = 88
    Top = 112
    object pmiDiskFile2: TMenuItem
      Caption = '&Save File'
      Checked = True
      RadioItem = True
      OnClick = pmiDiskFile2Click
    end
    object pmiEditorBuff2: TMenuItem
      Tag = 1
      Caption = '&Editor Buffer'
      RadioItem = True
      OnClick = pmiDiskFile2Click
    end
    object pmiBackupFile2: TMenuItem
      Tag = 2
      Caption = '&Backup File'
      RadioItem = True
      OnClick = pmiDiskFile2Click
    end
  end
  object OpenDialog2: TOpenDialog
    Filter = 
      'Delphi Source Files(*.pas;*.dpr)|*.pas;*.dpr|C++Builder Source F' +
      'iles(*.c;*.cpp;*.h;*.hpp)|*.c;*.cpp;*.h;*.hpp|Form Files(*.dfm;*' +
      '.xfm)|*.dfm;*.xfm|Any File(*.*)|*.*'
    Options = [ofReadOnly, ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofFileMustExist]
    Left = 536
    Top = 72
  end
end
