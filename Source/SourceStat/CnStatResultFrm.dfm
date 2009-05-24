object CnStatResultForm: TCnStatResultForm
  Left = 192
  Top = 85
  Width = 791
  Height = 513
  Caption = '源代码统计专家'
  Color = clBtnFace
  Constraints.MinHeight = 450
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 241
    Top = 30
    Width = 3
    Height = 418
    Cursor = crHSplit
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 783
    Height = 30
    BorderWidth = 1
    Caption = 'ToolBar'
    DisabledImages = dmCnSharedImages.DisabledImages
    EdgeBorders = [ebTop, ebBottom]
    Flat = True
    Images = dmCnSharedImages.Images
    Indent = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 2
      Top = 0
      Action = StatAction
    end
    object ToolButton2: TToolButton
      Left = 25
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object ToolButton3: TToolButton
      Left = 33
      Top = 0
      Action = StatUnitAction
    end
    object ToolButton4: TToolButton
      Left = 56
      Top = 0
      Action = StatProjectGroupAction
    end
    object ToolButton5: TToolButton
      Left = 79
      Top = 0
      Action = StatProjectAction
    end
    object ToolButton6: TToolButton
      Left = 102
      Top = 0
      Action = StatOpenUnitsAction
    end
    object ToolButton9: TToolButton
      Left = 125
      Top = 0
      Width = 8
      Caption = 'ToolButton9'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object ToolButton17: TToolButton
      Left = 133
      Top = 0
      Action = CopyResultAction
    end
    object ToolButton7: TToolButton
      Left = 156
      Top = 0
      Action = SaveCurResultAction
    end
    object ToolButton8: TToolButton
      Left = 179
      Top = 0
      Action = SaveAllResultAction
    end
    object ToolButton10: TToolButton
      Left = 202
      Top = 0
      Action = OpenSelFileAction
    end
    object ToolButton13: TToolButton
      Left = 225
      Top = 0
      Width = 8
      Caption = 'ToolButton13'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object ToolButton15: TToolButton
      Left = 233
      Top = 0
      Action = ClearResultAction
    end
    object ToolButton16: TToolButton
      Left = 256
      Top = 0
      Action = SearchFileAction
    end
    object ToolButton11: TToolButton
      Left = 279
      Top = 0
      Width = 8
      Caption = 'ToolButton11'
      ImageIndex = 8
      Style = tbsSeparator
    end
    object ToolButton12: TToolButton
      Left = 287
      Top = 0
      Action = HelpAction
    end
    object ToolButton14: TToolButton
      Left = 310
      Top = 0
      Action = CloseAction
    end
  end
  object TreeView: TCnCheckTreeView
    Left = 0
    Top = 30
    Width = 241
    Height = 418
    Align = alLeft
    HideSelection = False
    Images = ImageListTree
    Indent = 19
    PopupMenu = PopupMenu
    ReadOnly = True
    RightClickSelect = True
    RowSelect = True
    TabOrder = 1
    OnChange = TreeViewChange
    OnDblClick = TreeViewDblClick
    OnDeletion = TreeViewDeletion
    CanDisableNode = False
  end
  object PanelResult: TPanel
    Left = 244
    Top = 30
    Width = 539
    Height = 418
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    OnResize = PanelResultResize
    object GroupBoxResult: TGroupBox
      Left = 16
      Top = 16
      Width = 506
      Height = 185
      Anchors = [akLeft, akTop, akRight]
      Caption = '单个文件统计信息'
      TabOrder = 0
      object Label1: TLabel
        Left = 16
        Top = 22
        Width = 48
        Height = 13
        Caption = '文件名：'
      end
      object Label2: TLabel
        Left = 16
        Top = 42
        Width = 60
        Height = 13
        Caption = '所在目录：'
      end
      object LabelFileName: TLabel
        Left = 72
        Top = 22
        Width = 3
        Height = 13
      end
      object LabelBytes: TLabel
        Left = 16
        Top = 66
        Width = 3
        Height = 13
      end
      object LabelLines: TLabel
        Left = 16
        Top = 86
        Width = 3
        Height = 13
      end
      object EditDir: TEdit
        Left = 80
        Top = 42
        Width = 406
        Height = 15
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        ParentColor = True
        ReadOnly = True
        TabOrder = 0
      end
    end
    object GroupBoxDPR: TGroupBox
      Left = 16
      Top = 219
      Width = 161
      Height = 180
      Anchors = [akLeft, akBottom]
      Caption = '工程统计信息或文件汇总信息'
      TabOrder = 1
      object LabelProjectName: TLabel
        Left = 16
        Top = 24
        Width = 3
        Height = 13
      end
      object LabelProjectFiles: TLabel
        Left = 16
        Top = 44
        Width = 3
        Height = 13
      end
      object LabelProjectBytes: TLabel
        Left = 16
        Top = 64
        Width = 3
        Height = 13
      end
      object LabelProjectLines2: TLabel
        Left = 16
        Top = 104
        Width = 3
        Height = 13
      end
      object LabelProjectLines1: TLabel
        Left = 16
        Top = 84
        Width = 3
        Height = 13
      end
    end
    object GroupBoxBPG: TGroupBox
      Left = 256
      Top = 216
      Width = 173
      Height = 179
      Caption = '工程组统计信息'
      TabOrder = 2
      object LabelProjectGroupName: TLabel
        Left = 16
        Top = 24
        Width = 3
        Height = 13
      end
      object LabelProjectGroupFiles: TLabel
        Left = 16
        Top = 44
        Width = 3
        Height = 13
      end
      object LabelProjectGroupBytes: TLabel
        Left = 16
        Top = 64
        Width = 3
        Height = 13
      end
      object LabelProjectGroupLines2: TLabel
        Left = 16
        Top = 104
        Width = 3
        Height = 13
      end
      object LabelProjectGroupLines1: TLabel
        Left = 16
        Top = 84
        Width = 3
        Height = 13
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 448
    Width = 783
    Height = 19
    Panels = <>
    ParentFont = True
    SimplePanel = True
    UseSystemFont = False
  end
  object MainMenu: TMainMenu
    AutoHotkeys = maManual
    Images = dmCnSharedImages.Images
    Left = 56
    Top = 80
    object N1: TMenuItem
      Caption = '文件(&F)'
      OnClick = CloseActionExecute
      object T1: TMenuItem
        Action = StatAction
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object N5: TMenuItem
        Action = StatUnitAction
      end
      object N6: TMenuItem
        Action = StatProjectGroupAction
      end
      object N7: TMenuItem
        Action = StatProjectAction
      end
      object N8: TMenuItem
        Action = StatOpenUnitsAction
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object N10: TMenuItem
        Action = CloseAction
      end
    end
    object N2: TMenuItem
      Caption = ' 操作(&P)'
      object N11: TMenuItem
        Action = OpenSelFileAction
      end
      object N17: TMenuItem
        Action = CopyResultAction
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object S1: TMenuItem
        Action = SaveCurResultAction
      end
      object A1: TMenuItem
        Action = SaveAllResultAction
      end
      object N18: TMenuItem
        Action = ClearResultAction
      end
      object N20: TMenuItem
        Caption = '-'
      end
      object N19: TMenuItem
        Action = SearchFileAction
      end
    end
    object H1: TMenuItem
      Caption = '帮助(&H)'
      object N3: TMenuItem
        Action = HelpAction
      end
    end
  end
  object ImageListTree: TImageList
    Left = 24
    Top = 80
    Bitmap = {
      494C010103000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000FFFFFF008000000080000000800000008000
      0000C0C0C000000000000000000000000000000000000000000080808000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000080808000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000C0C0C000C0C0C00080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C0C0C000000000000000000000000000000000000000000080808000FFFF
      FF0080000000800000008000000080000000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000080808000FFFFFF00C0C0
      C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000FFFFFF008000000080808000FFFFFF008000000080000000800000008000
      0000C0C0C0000000000000000000000000008080800000FFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000080808000FFFFFF00FFFF
      FF0080800000808000008080000080800000808000008080000080800000FFFF
      FF00C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000C0C0C000C0C0C0008080
      8000FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C0C0C00000000000808080000000000080808000FFFFFF0080808000FFFF
      FF0080000000800000008000000080000000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000000000000000000080808000FFFFFF00C0C0
      C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00800000008080
      8000FFFFFF008000000080808000FFFFFF008000000080000000FFFFFF000000
      0000000000000000000080808000000000008080800000FFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C000FFFFFF00C0C0C000FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000080808000FFFFFF00FFFF
      FF00C0C0C000FFFFFF008080000080800000808000008080000080800000FFFF
      FF00C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      80008080800080808000808080000000000080808000FFFFFF0080808000FFFF
      FF0080000000800000008000000080000000C0C0C000C0C0C000FFFFFF00C0C0
      C000FFFFFF00C0C0C000C0C0C00000000000000000008080800080000000C0C0
      C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00800000008080
      8000FFFFFF008000000080808000808080008080800080808000808080008080
      8000000000000000000080808000000000008080800000FFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C000FFFFFF00C0C0C000FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000080808000808080008000
      00000000FF000000FF000000FF000000FF000000FF000000FF000000FF00FFFF
      FF00C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800080808000C0C0C000C0C0
      C000C0C0C000C0C0C000000000000000000080808000FFFFFF00808080008080
      80008080800080808000808080008080800080808000C0C0C000FFFFFF00C0C0
      C000FFFFFF00C0C0C000C0C0C00000000000000000008080800080000000C0C0
      C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00800000008080
      8000808080008080800080808000808080008080800080800000808000008080
      000080800000C0C0C00000000000000000008080800000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0080808000C0C0C000FFFFFF00C0C0C000FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000080808000FFFFFF00FFFF
      FF00C0C0C000FFFFFF008080000080800000808000008080000080800000FFFF
      FF00C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008080800080808000FFFFFF0080000000FFFF0000808000008080
      000080800000C0C0C00000000000000000008080800080808000808080008080
      800080808000808080008080800080808000FFFFFF00C0C0C000FFFFFF00C0C0
      C000FFFFFF00C0C0C000C0C0C000000000000000000080808000FFFFFF00C0C0
      C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000FFFFFF0080000000FFFF0000FFFF00008080
      000080800000C0C0C0000000000000000000000000000000000080808000FFFF
      FF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000080808000FFFFFF00FFFF
      FF008080000080800000808000008080000080800000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000FFFFFF008000000080000000800000008000
      000080000000C0C0C00000000000000000000000000000000000808080008000
      0000800000008000000080000000800000008000000080000000800000008000
      00008000000080000000C0C0C000000000000000000080808000FFFFFF00C0C0
      C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0C000C0C0C000FFFF
      FF00808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000808080008000
      0000800000008000000080000000800000008000000080000000800000008000
      00008000000080000000C0C0C000000000000000000080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C0008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000808080008080800080808000808080008080
      8000808080008080800000000000000000000000000000000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000000000000000000080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FC03FFFFFFFF0000FC03C03F80030000
      E003C03F80030000E003003F8003000000010000800300000000000080030000
      0000000080030000000000008003000000010000800300000001000080030000
      000100008003000000010000800300000001C00080030000FC01C00080070000
      FC01C000800F0000FE03C000801F000000000000000000000000000000000000
      000000000000}
  end
  object ActionList: TActionList
    Images = dmCnSharedImages.Images
    OnUpdate = ActionListUpdate
    Left = 368
    Top = 56
    object StatAction: TAction
      Caption = '源代码统计(&J)...'
      Hint = '进行源码统计'
      ImageIndex = 49
      OnExecute = StatActionExecute
    end
    object StatUnitAction: TAction
      Caption = '统计当前单元(&U)'
      Hint = '统计当前单元'
      ImageIndex = 59
      OnExecute = StatUnitActionExecute
    end
    object StatProjectGroupAction: TAction
      Caption = '统计当前工程组所有文件(&G)'
      Hint = '统计当前工程组所有文件'
      ImageIndex = 57
      OnExecute = StatProjectGroupActionExecute
    end
    object StatProjectAction: TAction
      Caption = '统计当前工程所有文件(&P)'
      Hint = '统计当前工程所有文件'
      ImageIndex = 58
      OnExecute = StatProjectActionExecute
    end
    object StatOpenUnitsAction: TAction
      Caption = '统计当前打开的所有文件(&O)'
      Hint = '统计当前打开的所有文件'
      ImageIndex = 60
      OnExecute = StatOpenUnitsActionExecute
    end
    object SaveCurResultAction: TAction
      Caption = '保存当前统计结果(&S)'
      Hint = '保存当前文件的统计结果'
      ImageIndex = 6
      OnExecute = SaveCurResultActionExecute
    end
    object SaveAllResultAction: TAction
      Caption = '保存所有统计结果(&A)'
      Hint = '保存所有统计结果'
      ImageIndex = 48
      OnExecute = SaveAllResultActionExecute
    end
    object OpenSelFileAction: TAction
      Caption = '打开选中的文件(&O)'
      Hint = '在IDE编辑器中打开选中的文件'
      ImageIndex = 34
      OnExecute = OpenSelFileActionExecute
    end
    object ClearResultAction: TAction
      Caption = '清空统计结果(&X)'
      Hint = '清空所有统计结果'
      ImageIndex = 13
      OnExecute = ClearResultActionExecute
    end
    object HelpAction: TAction
      Caption = '使用帮助...'
      Hint = '显示帮助信息'
      ImageIndex = 1
      ShortCut = 112
      OnExecute = HelpActionExecute
    end
    object CloseAction: TAction
      Caption = '退出(&X)'
      Hint = '退出源代码统计专家'
      ImageIndex = 0
      OnExecute = CloseActionExecute
    end
    object CopyResultAction: TAction
      Caption = '复制当前统计结果(&C)'
      Hint = '复制当前选中文件的统计结果'
      ImageIndex = 10
      OnExecute = CopyResultActionExecute
    end
    object SearchFileAction: TAction
      Caption = '查找文件(&F)...'
      Hint = '在文件列表中查找文件'
      ImageIndex = 16
      OnExecute = SearchFileActionExecute
    end
  end
  object PopupMenu: TPopupMenu
    Images = dmCnSharedImages.Images
    Left = 88
    Top = 80
    object S2: TMenuItem
      Action = OpenSelFileAction
      Default = True
    end
    object N13: TMenuItem
      Action = CopyResultAction
    end
    object N21: TMenuItem
      Caption = '-'
    end
    object S3: TMenuItem
      Action = SaveCurResultAction
    end
    object SaveAllResultAction1: TMenuItem
      Action = SaveAllResultAction
    end
    object N15: TMenuItem
      Action = ClearResultAction
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object N14: TMenuItem
      Action = SearchFileAction
    end
  end
  object SaveDialog: TSaveDialog
    Filter = 
      '文本文件(*.txt)|*.txt|逗号分隔值文件(*.csv)|*.csv|制表符分隔值文' +
      '件(*.tsv)|*.tsv'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = '保存统计结果'
    Left = 408
    Top = 56
  end
  object FindDialog: TFindDialog
    Options = [frDown, frFindNext, frHideWholeWord, frDisableWholeWord]
    OnFind = FindDialogFind
    Left = 120
    Top = 80
  end
end
