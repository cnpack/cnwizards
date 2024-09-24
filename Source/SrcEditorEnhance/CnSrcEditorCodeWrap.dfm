inherited CnSrcEditorCodeWrapForm: TCnSrcEditorCodeWrapForm
  Left = 314
  Top = 125
  BorderStyle = bsDialog
  Caption = 'Code Surround Setting'
  ClientHeight = 528
  ClientWidth = 538
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 523
    Height = 170
    Anchors = [akLeft, akTop, akRight]
    Caption = '&List'
    TabOrder = 0
    object ListView: TListView
      Left = 8
      Top = 16
      Width = 427
      Height = 146
      Anchors = [akLeft, akTop, akRight]
      Columns = <
        item
          Caption = 'Caption'
          Width = 200
        end
        item
          Caption = 'Shortcut'
          Width = 130
        end
        item
          Caption = 'Indent'
          Width = 60
        end>
      HideSelection = False
      MultiSelect = True
      OwnerData = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnData = ListViewData
      OnKeyUp = ListViewKeyUp
      OnMouseUp = ListViewMouseUp
      OnSelectItem = ListViewSelectItem
    end
    object btnAdd: TButton
      Left = 442
      Top = 16
      Width = 73
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Add'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 442
      Top = 42
      Width = 73
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Remove'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnImport: TButton
      Left = 442
      Top = 91
      Width = 73
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Import'
      TabOrder = 5
      OnClick = btnImportClick
    end
    object btnExport: TButton
      Left = 442
      Top = 116
      Width = 73
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'E&xport'
      TabOrder = 6
      OnClick = btnExportClick
    end
    object btnUp: TButton
      Left = 442
      Top = 66
      Width = 34
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Up'
      TabOrder = 3
      OnClick = btnUpClick
    end
    object btnDown: TButton
      Left = 481
      Top = 66
      Width = 34
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Down'
      TabOrder = 4
      OnClick = btnDownClick
    end
    object btnReset: TButton
      Left = 442
      Top = 141
      Width = 73
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Re&set'
      TabOrder = 7
      OnClick = btnResetClick
    end
  end
  object grp2: TGroupBox
    Left = 8
    Top = 185
    Width = 523
    Height = 303
    Anchors = [akLeft, akTop, akRight]
    Caption = '&Surround Item'
    TabOrder = 1
    object lbl1: TLabel
      Left = 8
      Top = 20
      Width = 41
      Height = 13
      Caption = 'Caption:'
    end
    object lbl4: TLabel
      Left = 8
      Top = 44
      Width = 45
      Height = 13
      Caption = 'Shortcut:'
    end
    object lbl2: TLabel
      Left = 8
      Top = 93
      Width = 29
      Height = 13
      Caption = 'Head:'
    end
    object lbl5: TLabel
      Left = 8
      Top = 185
      Width = 20
      Height = 13
      Caption = 'Tail:'
    end
    object lbl6: TLabel
      Left = 8
      Top = 70
      Width = 28
      Height = 13
      Caption = 'Block:'
    end
    object lbl7: TLabel
      Left = 314
      Top = 70
      Width = 100
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'Indent Count:'
    end
    object lbl8: TLabel
      Left = 314
      Top = 161
      Width = 100
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'Relative Indent:'
    end
    object lbl9: TLabel
      Left = 314
      Top = 252
      Width = 100
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'Relative Indent:'
    end
    object edtCaption: TEdit
      Left = 56
      Top = 16
      Width = 459
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = ControlChanged
    end
    object HotKey: THotKey
      Left = 56
      Top = 41
      Width = 459
      Height = 19
      Anchors = [akLeft, akTop, akRight]
      HotKey = 0
      InvalidKeys = [hcNone]
      Modifiers = []
      TabOrder = 1
      OnExit = ControlChanged
    end
    object chkLineBlock: TCheckBox
      Left = 56
      Top = 66
      Width = 153
      Height = 22
      Caption = 'Line Block Mode'
      TabOrder = 2
      OnClick = ControlChanged
    end
    object mmoHead: TMemo
      Left = 56
      Top = 93
      Width = 459
      Height = 60
      Anchors = [akLeft, akTop, akRight]
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 4
      OnExit = ControlChanged
    end
    object mmoTail: TMemo
      Left = 56
      Top = 185
      Width = 459
      Height = 60
      Anchors = [akLeft, akTop, akRight]
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 7
      OnExit = ControlChanged
    end
    object seIndent: TCnSpinEdit
      Left = 418
      Top = 66
      Width = 97
      Height = 22
      Anchors = [akTop, akRight]
      MaxValue = 99
      MinValue = -99
      TabOrder = 3
      Value = 0
      OnChange = ControlChanged
    end
    object chkHeadIndent: TCheckBox
      Left = 56
      Top = 157
      Width = 153
      Height = 22
      Caption = 'Auto Indent'
      TabOrder = 5
      OnClick = ControlChanged
    end
    object seHeadIndent: TCnSpinEdit
      Left = 418
      Top = 157
      Width = 97
      Height = 22
      Anchors = [akTop, akRight]
      MaxValue = 99
      MinValue = -99
      TabOrder = 6
      Value = 0
      OnChange = ControlChanged
    end
    object chkTailIndent: TCheckBox
      Left = 56
      Top = 249
      Width = 153
      Height = 22
      Caption = 'Auto Indent'
      TabOrder = 8
      OnClick = ControlChanged
    end
    object seTailIndent: TCnSpinEdit
      Left = 418
      Top = 249
      Width = 97
      Height = 22
      Anchors = [akTop, akRight]
      MaxValue = 99
      MinValue = -99
      TabOrder = 9
      Value = 0
      OnChange = ControlChanged
    end
    object chkForPas: TCheckBox
      Left = 56
      Top = 273
      Width = 153
      Height = 22
      Caption = 'Pascal'
      TabOrder = 10
      OnClick = ControlChanged
    end
    object chkForCpp: TCheckBox
      Left = 192
      Top = 273
      Width = 153
      Height = 22
      Caption = 'C/C++'
      TabOrder = 11
      OnClick = ControlChanged
    end
  end
  object btnHelp: TButton
    Left = 456
    Top = 499
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 296
    Top = 499
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 376
    Top = 499
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'xml'
    Filter = 'Code Surround Setting File(*.xml)|*.xml'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 408
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'xml'
    Filter = 'Code Surround Setting File(*.xml)|*.xml'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 40
    Top = 408
  end
end
