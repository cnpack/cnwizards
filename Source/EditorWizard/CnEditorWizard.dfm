object CnEditorToolsForm: TCnEditorToolsForm
  Left = 359
  Top = 144
  BorderStyle = bsDialog
  Caption = '编辑器工具设置'
  ClientHeight = 413
  ClientWidth = 464
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
  PixelsPerInch = 96
  TextHeight = 13
  object btnHelp: TButton
    Left = 382
    Top = 384
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 302
    Top = 384
    Width = 75
    Height = 21
    Cancel = True
    Caption = '关闭(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 449
    Height = 369
    Caption = '编辑器工具(&T)'
    TabOrder = 0
    object lbl1: TLabel
      Left = 312
      Top = 132
      Width = 42
      Height = 13
      Caption = '快捷键:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbl2: TLabel
      Left = 312
      Top = 187
      Width = 29
      Height = 13
      Caption = '设置:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblToolName: TLabel
      Left = 352
      Top = 14
      Width = 89
      Height = 40
      AutoSize = False
      Caption = 'lblToolName'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
    end
    object imgIcon: TImage
      Left = 312
      Top = 16
      Width = 32
      Height = 32
    end
    object bvlWizard: TBevel
      Left = 312
      Top = 48
      Width = 129
      Height = 10
      Shape = bsBottomLine
    end
    object lbl3: TLabel
      Left = 312
      Top = 64
      Width = 29
      Height = 13
      Caption = '作者:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblToolAuthor: TLabel
      Left = 312
      Top = 80
      Width = 129
      Height = 33
      AutoSize = False
      Caption = 'lblToolAuthor'
      WordWrap = True
    end
    object lvTools: TListView
      Left = 8
      Top = 16
      Width = 297
      Height = 233
      Columns = <
        item
          Caption = '工具名称'
          Width = 127
        end
        item
          Caption = '状态'
        end
        item
          Caption = '快捷键'
          Width = 100
        end>
      ColumnClick = False
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = lvToolsChange
      OnDblClick = lvToolsDblClick
    end
    object mmoComment: TMemo
      Left = 8
      Top = 256
      Width = 433
      Height = 97
      Color = 14745599
      ReadOnly = True
      TabOrder = 4
    end
    object chkEnabled: TCheckBox
      Left = 312
      Top = 203
      Width = 129
      Height = 17
      Caption = '允许该工具启用'
      TabOrder = 2
      OnClick = chkEnabledClick
    end
    object HotKey: THotKey
      Left = 312
      Top = 148
      Width = 129
      Height = 19
      HotKey = 0
      InvalidKeys = [hcNone, hcShift]
      Modifiers = []
      TabOrder = 1
      OnExit = HotKeyExit
    end
    object btnConfig: TButton
      Left = 342
      Top = 225
      Width = 75
      Height = 21
      Caption = '设置(&S)'
      TabOrder = 3
      OnClick = btnConfigClick
    end
  end
end
