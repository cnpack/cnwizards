inherited CnStatResultForm: TCnStatResultForm
  Top = 85
  Width = 791
  Height = 513
  Caption = 'Source Code Statistic Wizard'
  Constraints.MinHeight = 450
  Constraints.MinWidth = 600
  Menu = MainMenu
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
      Caption = 'Single File Statistic'
      TabOrder = 0
      object Label1: TLabel
        Left = 16
        Top = 22
        Width = 20
        Height = 13
        Caption = 'File:'
      end
      object Label2: TLabel
        Left = 16
        Top = 42
        Width = 48
        Height = 13
        Caption = 'Directory:'
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
      Caption = 'Files or Project Statistic Result'
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
      Caption = 'Project Group Statistic Result'
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
      Caption = '&File'
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
      Caption = ' O&peration'
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
      Caption = '&Help'
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
      Caption = 'Source Code Calculation...'
      Hint = 'Calculate the Source Code'
      ImageIndex = 49
      OnExecute = StatActionExecute
    end
    object StatUnitAction: TAction
      Caption = 'Calculate Current &Unit'
      Hint = 'Calculate Current Unit'
      ImageIndex = 59
      OnExecute = StatUnitActionExecute
    end
    object StatProjectGroupAction: TAction
      Caption = 'Calculate All Files in Current Project &Group'
      Hint = 'Calculate All Files in Current Project Group'
      ImageIndex = 57
      OnExecute = StatProjectGroupActionExecute
    end
    object StatProjectAction: TAction
      Caption = 'Calculate All Files in Current &Project'
      Hint = 'Calculate All Files in Current Project'
      ImageIndex = 58
      OnExecute = StatProjectActionExecute
    end
    object StatOpenUnitsAction: TAction
      Caption = 'Calculate All &Opened Files'
      Hint = 'Calculate All Opened Files'
      ImageIndex = 60
      OnExecute = StatOpenUnitsActionExecute
    end
    object SaveCurResultAction: TAction
      Caption = '&Save Result'
      Hint = 'Save Result of Current File'
      ImageIndex = 6
      OnExecute = SaveCurResultActionExecute
    end
    object SaveAllResultAction: TAction
      Caption = 'Save &All Results'
      Hint = 'Save All Results'
      ImageIndex = 48
      OnExecute = SaveAllResultActionExecute
    end
    object OpenSelFileAction: TAction
      Caption = '&Open Selected File'
      Hint = 'Open Selected File in IDE'
      ImageIndex = 34
      OnExecute = OpenSelFileActionExecute
    end
    object ClearResultAction: TAction
      Caption = 'Clea&r Results'
      Hint = 'Clear All Results'
      ImageIndex = 13
      OnExecute = ClearResultActionExecute
    end
    object HelpAction: TAction
      Caption = 'Using Help...'
      Hint = 'Display Help'
      ImageIndex = 1
      ShortCut = 112
      OnExecute = HelpActionExecute
    end
    object CloseAction: TAction
      Caption = 'E&xit'
      Hint = 'Exit Source Code Statistic Wizard'
      ImageIndex = 0
      OnExecute = CloseActionExecute
    end
    object CopyResultAction: TAction
      Caption = '&Copy Current Result'
      Hint = 'Copy Result of Selected Files'
      ImageIndex = 10
      OnExecute = CopyResultActionExecute
    end
    object SearchFileAction: TAction
      Caption = 'Search &File...'
      Hint = 'Search File in File List'
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
      'Text Files(*.txt)|*.txt|Comma Separated Files(*.csv)|*.csv|TAB S' +
      'eparated Files(*.tsv)|*.tsv'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Result'
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
