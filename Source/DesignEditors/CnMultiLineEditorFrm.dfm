object CnMultiLineEditorForm: TCnMultiLineEditorForm
  Left = 335
  Top = 292
  AutoScroll = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = '多行属性编辑器'
  ClientHeight = 273
  ClientWidth = 472
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 450
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
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
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tbrMain: TToolBar
    Left = 0
    Top = 0
    Width = 472
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
    object btn2: TToolButton
      Left = 0
      Top = 0
      Action = EditReload
      ImageIndex = 35
    end
    object btn1: TToolButton
      Left = 23
      Top = 0
      Width = 8
      Caption = 'btn1'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object tbtUndo: TToolButton
      Left = 31
      Top = 0
      Action = EditUndo
      ImageIndex = 52
    end
    object tbtSep1: TToolButton
      Left = 54
      Top = 0
      Width = 8
      Caption = 'tbtSep1'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object tbtCut: TToolButton
      Left = 62
      Top = 0
      Action = EditCut
      ImageIndex = 9
    end
    object tbtCopy: TToolButton
      Left = 85
      Top = 0
      Action = EditCopy
      ImageIndex = 10
    end
    object tbtPaste: TToolButton
      Left = 108
      Top = 0
      Action = EditPaste
      ImageIndex = 11
    end
    object tbtSep2: TToolButton
      Left = 131
      Top = 0
      Width = 8
      Caption = 'tbtSep2'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object tbtDelete: TToolButton
      Left = 139
      Top = 0
      Action = EditDelete
      ImageIndex = 13
    end
    object tbtSep3: TToolButton
      Left = 162
      Top = 0
      Width = 8
      Caption = 'tbtSep3'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object tbtSelectAll: TToolButton
      Left = 170
      Top = 0
      Action = EditSelectAll
      ImageIndex = 53
    end
    object tbtSep7: TToolButton
      Left = 193
      Top = 0
      Width = 8
      Caption = 'tbtSep7'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object tbtFind: TToolButton
      Left = 201
      Top = 0
      Action = EditFind
      ImageIndex = 16
    end
    object tbtFindNext: TToolButton
      Left = 224
      Top = 0
      Action = EditFindNext
      ImageIndex = 17
    end
    object tbtReplace: TToolButton
      Left = 247
      Top = 0
      Action = EditReplace
      ImageIndex = 46
    end
    object tbtSep4: TToolButton
      Left = 270
      Top = 0
      Width = 8
      Caption = 'tbtSep4'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object tbtSetFont: TToolButton
      Left = 278
      Top = 0
      Action = SetFont
      ImageIndex = 29
    end
    object tbtSep5: TToolButton
      Left = 301
      Top = 0
      Width = 8
      Caption = 'tbtSep5'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object tbtToggleHorizontal: TToolButton
      Left = 309
      Top = 0
      Action = EditToggleHorizontal
      ImageIndex = 21
    end
    object tbtSep8: TToolButton
      Left = 332
      Top = 0
      Width = 8
      Caption = 'tbtSep8'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object tbtSave: TToolButton
      Left = 340
      Top = 0
      Action = EditSave
      ImageIndex = 6
    end
    object tbtLoad: TToolButton
      Left = 363
      Top = 0
      Action = EditLoad
      ImageIndex = 3
    end
    object tbtSep9: TToolButton
      Left = 386
      Top = 0
      Width = 8
      Caption = 'tbtSep9'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object tbtCodeEditor: TToolButton
      Left = 394
      Top = 0
      Hint = 'Code Editor'
      Caption = 'tbtCodeEditor'
      ImageIndex = 12
      OnClick = tbtCodeEditorClick
    end
    object tbtSep6: TToolButton
      Left = 417
      Top = 0
      Width = 8
      Caption = 'tbtSep6'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object tbtAbout: TToolButton
      Left = 425
      Top = 0
      Action = HelpAbout
      ImageIndex = 1
    end
  end
  object memEdit: TMemo
    Left = 0
    Top = 26
    Width = 472
    Height = 206
    Align = alClient
    Ctl3D = True
    HideSelection = False
    ParentCtl3D = False
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 232
    Width = 472
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object lblDesc: TLabel
      Left = 52
      Top = 17
      Width = 111
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Ctrl+Enter为快速确认'
    end
    object lblPos: TLabel
      Left = 188
      Top = 17
      Width = 58
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Line,Column'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object btnTools: TSpeedButton
      Left = 8
      Top = 11
      Width = 37
      Height = 22
      Caption = '工具'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlight
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      PopupMenu = pmTools
      OnClick = btnToolsClick
    end
    object btnOK: TButton
      Left = 310
      Top = 12
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = '确定(&O)'
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 390
      Top = 12
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = '取消(&C)'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object alsEdit: TActionList
    Left = 80
    Top = 56
    object EditCopy: TEditCopy
      Category = 'Edit'
      Caption = '复制'
      Hint = '复制所选文字'
      ImageIndex = 0
      ShortCut = 16451
    end
    object EditCut: TEditCut
      Category = 'Edit'
      Caption = '剪切'
      Hint = '剪切所选文字'
      ImageIndex = 1
      ShortCut = 16472
    end
    object EditDelete: TEditDelete
      Category = 'Edit'
      Caption = '删除'
      Hint = '删除选中文字'
      ImageIndex = 2
      ShortCut = 46
    end
    object EditPaste: TEditPaste
      Category = 'Edit'
      Caption = '粘贴'
      Hint = '从剪切板粘贴'
      ImageIndex = 3
      ShortCut = 16470
    end
    object EditSelectAll: TEditSelectAll
      Category = 'Edit'
      Caption = '全部选择'
      Hint = '选择全部文本'
      ImageIndex = 5
      ShortCut = 16449
    end
    object EditUndo: TEditUndo
      Category = 'Edit'
      Caption = '撤销'
      Hint = '撤销所做操作'
      ImageIndex = 4
      ShortCut = 32776
    end
    object EditSave: TAction
      Category = 'Edit'
      Caption = '保存...'
      Hint = '保存当前文本'
      ImageIndex = 7
      ShortCut = 16467
      OnExecute = EditSaveExecute
      OnUpdate = EditCheckNullUpdate
    end
    object EditLoad: TAction
      Category = 'Edit'
      Caption = '打开...'
      Hint = '从文本文件中导入'
      ImageIndex = 8
      ShortCut = 16460
      OnExecute = EditLoadExecute
    end
    object HelpAbout: TAction
      Category = 'Help'
      Caption = '关于'
      Hint = '关于本编辑器'
      ImageIndex = 6
      ShortCut = 112
      OnExecute = HelpAboutExecute
    end
    object SetFont: TAction
      Category = 'Set'
      Caption = '字体'
      Hint = '选择字体'
      ImageIndex = 9
      OnExecute = SetFontExecute
    end
    object EditFind: TAction
      Category = 'Edit'
      Caption = '查找...'
      Hint = '查找文字'
      ImageIndex = 10
      ShortCut = 16454
      OnExecute = EditFindExecute
      OnUpdate = EditCheckNullUpdate
    end
    object EditFindNext: TAction
      Category = 'Edit'
      Caption = '查找下一个'
      Hint = '查找下一个'
      ImageIndex = 12
      ShortCut = 114
      OnExecute = EditFindNextExecute
      OnUpdate = EditCheckNullUpdate
    end
    object EditReplace: TAction
      Category = 'Edit'
      Caption = '替换...'
      Hint = '替换文字'
      ImageIndex = 11
      ShortCut = 16466
      OnExecute = EditReplaceExecute
      OnUpdate = EditCheckNullUpdate
    end
    object EditToggleHorizontal: TAction
      Category = 'Edit'
      Caption = '换行'
      Hint = '隐藏/显示水平滚动条'
      ImageIndex = 13
      OnExecute = EditToggleHorizontalExecute
      OnUpdate = EditToggleHorizontalUpdate
    end
    object EditReload: TAction
      Category = 'Edit'
      Caption = '原始值'
      Hint = '恢复原始值'
      OnExecute = EditReloadExecute
      OnUpdate = EditReloadUpdate
    end
  end
  object OD: TOpenDialog
    DefaultExt = 'txt'
    Filter = '文本文件(*.txt)|*.txt|所有文件(*.*)|*.*'
    Title = '打开文本文件'
    Left = 112
    Top = 56
  end
  object SD: TSaveDialog
    DefaultExt = 'txt'
    Filter = '文本文件(*.txt)|*.txt|所有文件(*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = '保存文本文件'
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
  object pmTools: TPopupMenu
    OnPopup = pmToolsPopup
    Left = 256
    Top = 56
    object miToolOpt: TMenuItem
      Caption = '辅助工具设置...'
      OnClick = miToolOptClick
    end
    object mitsep1: TMenuItem
      Caption = '-'
    end
    object miQuoted: TMenuItem
      Caption = '引用字符串'
      OnClick = miQuotedClick
    end
    object miUnQuoted: TMenuItem
      Caption = '字符串去除引用'
      OnClick = miUnQuotedClick
    end
    object mitsep2: TMenuItem
      Caption = '-'
    end
    object miLeftMove: TMenuItem
      Caption = '向左移动'
      OnClick = miLeftMoveClick
    end
    object miRightMove: TMenuItem
      Caption = '向右移动'
      OnClick = miRightMoveClick
    end
    object miDelEoLnSpace: TMenuItem
      Caption = '删除行末空格'
      OnClick = miDelEoLnSpaceClick
    end
    object mitsep3: TMenuItem
      Caption = '-'
    end
    object miSingleLine: TMenuItem
      Caption = '多行转单行'
      OnClick = miSingleLineClick
    end
    object mitsep4: TMenuItem
      Caption = '-'
    end
    object miUpper: TMenuItem
      Caption = '转换为大写'
      OnClick = miUpperClick
    end
    object miLower: TMenuItem
      Caption = '转换为小写'
      OnClick = miLowerClick
    end
    object miCaptain: TMenuItem
      Caption = '首字母大写'
      OnClick = miCaptainClick
    end
    object mitsep5: TMenuItem
      Caption = '-'
    end
    object miUserFormmat: TMenuItem
      Caption = '自定义格式化...'
      OnClick = miUserFormmatClick
    end
    object mitsep6: TMenuItem
      Caption = '-'
    end
    object misqlformatter: TMenuItem
      Caption = 'SQL语句格式化'
      OnClick = misqlformatterClick
    end
  end
end
