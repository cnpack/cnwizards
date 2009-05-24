object CnSourceDiffForm: TCnSourceDiffForm
  Left = 272
  Top = 153
  Width = 661
  Height = 485
  Caption = '源代码比较器'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlDisplay: TPanel
    Left = 634
    Top = 30
    Width = 19
    Height = 390
    Align = alRight
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    Visible = False
    object pbFile: TPaintBox
      Left = 8
      Top = 2
      Width = 9
      Height = 386
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
      Height = 386
      Align = alLeft
      Color = clBtnFace
      ParentColor = False
      OnPaint = pbPosPaint
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 30
    Width = 634
    Height = 390
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 1
    object Splitter2: TSplitter
      Left = 0
      Top = 308
      Width = 634
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    object pnlMain: TPanel
      Left = 0
      Top = 0
      Width = 634
      Height = 308
      Align = alClient
      BevelOuter = bvNone
      Caption = 'pnlMain'
      TabOrder = 0
      object Splitter1: TSplitter
        Left = 315
        Top = 0
        Width = 3
        Height = 308
        Cursor = crHSplit
      end
      object pnlLeft: TPanel
        Left = 0
        Top = 0
        Width = 315
        Height = 308
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'pnlLeft'
        TabOrder = 0
        object pnlCaptionLeft: TPanel
          Left = 0
          Top = 0
          Width = 315
          Height = 20
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvLowered
          TabOrder = 0
          OnResize = pnlCaptionLeftResize
          object btnFileKind1: TBitBtn
            Left = 258
            Top = 1
            Width = 42
            Height = 18
            Hint = '设置文件1内容'
            Anchors = [akTop, akRight]
            Caption = '文件'
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
            Left = 300
            Top = 1
            Width = 14
            Height = 18
            Hint = '打开文件历史记录'
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
            Left = 240
            Top = 1
            Width = 18
            Height = 18
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
        end
      end
      object pnlRight: TPanel
        Left = 318
        Top = 0
        Width = 316
        Height = 308
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlRight'
        TabOrder = 1
        object pnlCaptionRight: TPanel
          Left = 0
          Top = 0
          Width = 316
          Height = 20
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvLowered
          TabOrder = 0
          OnResize = pnlCaptionRightResize
          object btnFileKind2: TBitBtn
            Left = 258
            Top = 1
            Width = 42
            Height = 18
            Hint = '设置文件2内容'
            Anchors = [akTop, akRight]
            Caption = '文件'
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
            Left = 300
            Top = 1
            Width = 14
            Height = 18
            Hint = '打开文件历史记录'
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
            Left = 240
            Top = 1
            Width = 18
            Height = 18
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
        end
      end
    end
    object pnlMerge: TPanel
      Left = 0
      Top = 311
      Width = 634
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
    Top = 420
    Width = 653
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
    Width = 653
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
      Caption = '拼合文件(&M)'
      Enabled = False
      ImageIndex = 47
      MenuItem = mnuMergeOptions
      Style = tbsDropDown
      OnClick = tbMergeClick
    end
    object tbMergeFocusedText: TToolButton
      Left = 223
      Top = 0
      Action = actMergeFocusedText
      AutoSize = True
    end
    object tbEditFocusedText: TToolButton
      Left = 246
      Top = 0
      Action = actEditFocusedText
      AutoSize = True
    end
    object ToolButton9: TToolButton
      Left = 269
      Top = 0
      Width = 8
      Caption = 'ToolButton9'
      ImageIndex = 13
      Style = tbsSeparator
    end
    object tbSplitHorizontally: TToolButton
      Left = 277
      Top = 0
      Action = actSplitHorizontally
      AutoSize = True
    end
    object tbFont: TToolButton
      Left = 300
      Top = 0
      Action = actFont
      AutoSize = True
    end
    object ToolButton1: TToolButton
      Left = 323
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object tbHelp: TToolButton
      Left = 331
      Top = 0
      Action = actHelp
      AutoSize = True
    end
    object ToolButton13: TToolButton
      Left = 354
      Top = 0
      Width = 8
      Caption = 'ToolButton13'
      ImageIndex = 10
      Style = tbsSeparator
    end
    object tbClose: TToolButton
      Left = 362
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
      Caption = '文件(&F)'
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
      Caption = '设置(&O)'
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
        Caption = '高亮显示颜色(&C)'
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
      Caption = '操作(&P)'
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
        Caption = '拼合文件(&M)'
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
      Caption = '帮助(&H)'
      object Contents1: TMenuItem
        Action = actHelp
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'Delphi源文件(*.pas;*.dpr)|*.pas;*.dpr|C++Builder源文件(*.c;*.cpp' +
      ';*.h;*.hpp)|*.c;*.cpp;*.h;*.hpp|窗体文件(*.dfm;*.xfm)|*.dfm;*.xf' +
      'm|所有文件(*.*)|*.*'
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
      'Delphi源文件(*.pas;*.dpr)|*.pas;*.dpr|C++Builder源文件(*.c;*.cpp' +
      ';*.h;*.hpp)|*.c;*.cpp;*.h;*.hpp|窗体文件(*.dfm;*.xfm)|*.dfm;*.xf' +
      'm|所有文件(*.*)|*.*'
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
      Caption = '打开文件(&1)...'
      Hint = '打开文件1'
      ShortCut = 16433
      OnExecute = actOpen1Execute
    end
    object actOpen2: TAction
      Category = 'File'
      Caption = '打开文件(&2)...'
      Hint = '打开文件2'
      ShortCut = 16434
      OnExecute = actOpen2Execute
    end
    object actCompareEx: TAction
      Category = 'Actions'
      Caption = '刷新文件并重新比较(&R)'
      Hint = '刷新文件并重新比较'
      ImageIndex = 51
      ShortCut = 16504
      OnExecute = actCompareExExecute
    end
    object actGoto: TAction
      Category = 'Actions'
      Caption = '转到源代码编辑器中(&J)'
      Hint = '转到源代码编辑器中'
      ImageIndex = 34
      ShortCut = 16458
      OnExecute = actGotoExecute
    end
    object actSaveMerged: TAction
      Category = 'File'
      Caption = '保存拼合后的文件(&S)...'
      Hint = '保存拼合后的文件'
      ImageIndex = 6
      ShortCut = 16467
      OnExecute = actSaveMergedExecute
    end
    object actClose: TAction
      Category = 'File'
      Caption = '关闭(&X)'
      Hint = '关闭'
      ImageIndex = 0
      ShortCut = 16499
      OnExecute = actCloseExecute
    end
    object actIgnoreBlanks: TAction
      Category = 'Options'
      Caption = '忽略空白字符(&B)'
      Hint = '忽略空白字符'
      ShortCut = 16450
      OnExecute = actIgnoreBlanksExecute
    end
    object actIgnoreCase: TAction
      Category = 'Options'
      Caption = '忽略大小写(&I)'
      Hint = '忽略大小写'
      ShortCut = 16457
      OnExecute = actIgnoreCaseExecute
    end
    object actShowDiffOnly: TAction
      Category = 'Options'
      Caption = '只显示不同之处(&D)'
      Hint = '只显示不同之处'
      ShortCut = 16452
      OnExecute = actShowDiffOnlyExecute
    end
    object actSplitHorizontally: TAction
      Category = 'Options'
      Caption = '水平分割(&H)'
      Hint = '水平分割'
      ImageIndex = 30
      ShortCut = 16456
      OnExecute = actSplitHorizontallyExecute
    end
    object actAddColor: TAction
      Category = 'Options'
      Caption = '新增的行(&A)...'
      Hint = '设置新增的行颜色'
      OnExecute = actAddColorExecute
    end
    object actModColor: TAction
      Category = 'Options'
      Caption = '修改的行(&M)...'
      Hint = '设置修改的行颜色'
      OnExecute = actModColorExecute
    end
    object actDelColor: TAction
      Category = 'Options'
      Caption = '删除的行(&D)...'
      Hint = '设置删除的行颜色'
      OnExecute = actDelColorExecute
    end
    object actFont: TAction
      Category = 'Options'
      Caption = '字体(&F)...'
      Hint = '设置字体'
      ImageIndex = 29
      ShortCut = 16454
      OnExecute = actFontExecute
    end
    object actCompare: TAction
      Category = 'Actions'
      Caption = '源代码比较(&C)'
      Hint = '源代码比较'
      ImageIndex = 39
      ShortCut = 120
      OnExecute = actCompareExecute
    end
    object actCancel: TAction
      Category = 'Actions'
      Caption = '中断比较(&N)'
      Enabled = False
      Hint = '中断比较'
      ImageIndex = 50
      ShortCut = 16497
      OnExecute = actCancelExecute
    end
    object actMergeFromFile1: TAction
      Category = 'Actions'
      Caption = '以左/上文件为主(&L)'
      Hint = '以左/上文件为主进行拼合'
      OnExecute = actMergeFromExecute
    end
    object actMergeFromFile2: TAction
      Category = 'Actions'
      Caption = '以右/下文件为主(&R)'
      Hint = '以右/下文件为主进行拼合'
      OnExecute = actMergeFromExecute
    end
    object actMergeFromNeither: TAction
      Category = 'Actions'
      Caption = '两个文件的交集(&R)'
      Hint = '两个文件的交集'
      OnExecute = actMergeFromExecute
    end
    object actMergeFocusedText: TAction
      Category = 'Actions'
      Caption = '拼合当前文本(&M)'
      Hint = '拼合当前文本'
      ImageIndex = 46
      ShortCut = 16461
      OnExecute = actMergeFocusedTextExecute
    end
    object actEditFocusedText: TAction
      Category = 'Actions'
      Caption = '编辑当前文本(&E)'
      Hint = '编辑当前文本'
      ImageIndex = 12
      ShortCut = 16453
      OnExecute = actEditFocusedTextExecute
    end
    object actHelp: TAction
      Category = 'Help'
      Caption = '显示帮助(&H)'
      Hint = '显示帮助'
      ImageIndex = 1
      ShortCut = 112
      OnExecute = actHelpExecute
    end
    object actNextDiff: TAction
      Category = 'Actions'
      Caption = '下一处不同(&N)'
      Hint = '下一处不同'
      ImageIndex = 45
      ShortCut = 16424
      OnExecute = actNextDiffExecute
    end
    object actPrioDiff: TAction
      Category = 'Actions'
      Caption = '上一处不同(&P)'
      Hint = '上一处不同'
      ImageIndex = 44
      ShortCut = 16422
      OnExecute = actPrioDiffExecute
    end
  end
  object pmFileKind1: TPopupMenu
    Images = dmCnSharedImages.Images
    OnPopup = pmFileKind1Popup
    Left = 8
    Top = 112
    object pmiDiskFile1: TMenuItem
      Caption = '存盘文件(&S)'
      Checked = True
      RadioItem = True
      OnClick = pmiDiskFile1Click
    end
    object pmiEditorBuff1: TMenuItem
      Tag = 1
      Caption = '编辑器内存缓冲区(&E)'
      RadioItem = True
      OnClick = pmiDiskFile1Click
    end
    object pmiBakFile1: TMenuItem
      Tag = 2
      Caption = '备份文件(&B)'
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
      Caption = '存盘文件(&S)'
      Checked = True
      RadioItem = True
      OnClick = pmiDiskFile2Click
    end
    object pmiEditorBuff2: TMenuItem
      Tag = 1
      Caption = '编辑器内存缓冲区(&E)'
      RadioItem = True
      OnClick = pmiDiskFile2Click
    end
    object pmiBakFile2: TMenuItem
      Tag = 2
      Caption = '备份文件(&B)'
      RadioItem = True
      OnClick = pmiDiskFile2Click
    end
  end
  object OpenDialog2: TOpenDialog
    Filter = 
      'Delphi源文件(*.pas;*.dpr)|*.pas;*.dpr|C++Builder源文件(*.c;*.cpp' +
      ';*.h;*.hpp)|*.c;*.cpp;*.h;*.hpp|窗体文件(*.dfm;*.xfm)|*.dfm;*.xf' +
      'm|所有文件(*.*)|*.*'
    Options = [ofReadOnly, ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofFileMustExist]
    Left = 536
    Top = 72
  end
end
