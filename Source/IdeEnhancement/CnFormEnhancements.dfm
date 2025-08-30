inherited CnFormEnhanceConfigForm: TCnFormEnhanceConfigForm
  Left = 304
  Top = 124
  BorderStyle = bsDialog
  Caption = 'Form Designer Enhancements Settings'
  ClientHeight = 381
  ClientWidth = 489
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpFlatPanel: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 337
    Caption = 'F&loat Toolbar Settings'
    TabOrder = 0
    object Label1: TLabel
      Left = 24
      Top = 254
      Width = 86
      Height = 13
      Caption = 'Horizontal Offset:'
    end
    object Label2: TLabel
      Left = 24
      Top = 279
      Width = 73
      Height = 13
      Caption = 'Vertical Offset:'
    end
    object Label3: TLabel
      Left = 24
      Top = 229
      Width = 41
      Height = 13
      Caption = 'Position:'
    end
    object Label4: TLabel
      Left = 8
      Top = 163
      Width = 70
      Height = 13
      Caption = 'Toolbar Name:'
    end
    object cbbSnapPos: TComboBox
      Left = 112
      Top = 225
      Width = 113
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 8
      OnChange = UpdateControls
    end
    object btnCustomize: TButton
      Left = 8
      Top = 304
      Width = 89
      Height = 21
      Caption = 'Cus&tomize...'
      TabOrder = 11
      OnClick = btnCustomizeClick
    end
    object btnExport: TButton
      Left = 104
      Top = 304
      Width = 57
      Height = 21
      Caption = 'E&xport'
      TabOrder = 12
      OnClick = btnExportClick
    end
    object btnImport: TButton
      Left = 170
      Top = 304
      Width = 55
      Height = 21
      Caption = 'I&mport'
      TabOrder = 13
      OnClick = btnImportClick
    end
    object ListView: TListView
      Left = 8
      Top = 16
      Width = 217
      Height = 89
      Columns = <
        item
          Caption = 'ID'
          Width = 38
        end
        item
          Caption = 'Toolbar Name'
          Width = 95
        end
        item
          Caption = 'Position'
          Width = 60
        end>
      ColumnClick = False
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = btnCustomizeClick
      OnSelectItem = ListViewSelectItem
    end
    object btnAdd: TButton
      Left = 8
      Top = 112
      Width = 65
      Height = 21
      Caption = '&Add'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 84
      Top = 112
      Width = 65
      Height = 21
      Caption = '&Delete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnDefault: TButton
      Left = 160
      Top = 112
      Width = 65
      Height = 21
      Caption = 'De&fault'
      TabOrder = 3
      OnClick = btnDefaultClick
    end
    object rbAllowDrag: TRadioButton
      Left = 8
      Top = 184
      Width = 217
      Height = 17
      Caption = 'Allow Dragging'
      TabOrder = 6
      OnClick = UpdateControls
    end
    object rbAutoSnap: TRadioButton
      Left = 8
      Top = 205
      Width = 217
      Height = 17
      Caption = 'Auto Snap To Form'
      Checked = True
      TabOrder = 7
      TabStop = True
      OnClick = UpdateControls
    end
    object seOffsetX: TCnSpinEdit
      Left = 112
      Top = 249
      Width = 113
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 9
      Value = 0
      OnChange = UpdateControls
    end
    object seOffsetY: TCnSpinEdit
      Left = 112
      Top = 274
      Width = 113
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 10
      Value = 0
      OnChange = UpdateControls
    end
    object edtName: TEdit
      Left = 112
      Top = 160
      Width = 113
      Height = 21
      TabOrder = 5
      OnChange = UpdateControls
    end
    object cbAllowShow: TCheckBox
      Left = 8
      Top = 136
      Width = 217
      Height = 17
      Caption = 'Show this Float Toolbar.'
      TabOrder = 4
      OnClick = UpdateControls
    end
  end
  object btnClose: TButton
    Left = 326
    Top = 352
    Width = 75
    Height = 21
    Cancel = True
    Caption = 'Cl&ose'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 406
    Top = 352
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object grp1: TGroupBox
    Left = 248
    Top = 8
    Width = 233
    Height = 337
    Caption = 'Float &Property Bar'
    TabOrder = 1
    object lbl3: TLabel
      Left = 24
      Top = 158
      Width = 86
      Height = 13
      Caption = 'Horizontal Offset:'
    end
    object lbl4: TLabel
      Left = 24
      Top = 183
      Width = 73
      Height = 13
      Caption = 'Vertical Offset:'
    end
    object lbl5: TLabel
      Left = 24
      Top = 133
      Width = 41
      Height = 13
      Caption = 'Position:'
    end
    object lbl6: TLabel
      Left = 8
      Top = 208
      Width = 195
      Height = 13
      Caption = 'Frequent Properties Ordered by priority:'
    end
    object lbl1: TLabel
      Left = 24
      Top = 41
      Width = 62
      Height = 13
      Caption = 'Name Width:'
    end
    object lbl2: TLabel
      Left = 24
      Top = 66
      Width = 61
      Height = 13
      Caption = 'Value Width:'
    end
    object cbbSnapPosPropBar: TComboBox
      Left = 112
      Top = 129
      Width = 113
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 5
      OnChange = UpdateControls
    end
    object rbAllowDragPropBar: TRadioButton
      Left = 8
      Top = 88
      Width = 217
      Height = 17
      Caption = 'Allow Dragging'
      TabOrder = 3
      OnClick = UpdateControls
    end
    object rbAutoSnapPropBar: TRadioButton
      Left = 8
      Top = 109
      Width = 217
      Height = 17
      Caption = 'Auto Snap To Form'
      Checked = True
      TabOrder = 4
      TabStop = True
      OnClick = UpdateControls
    end
    object sePropBarX: TCnSpinEdit
      Left = 112
      Top = 153
      Width = 113
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 6
      Value = 0
      OnChange = UpdateControls
    end
    object sePropBarY: TCnSpinEdit
      Left = 112
      Top = 178
      Width = 113
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 7
      Value = 0
      OnChange = UpdateControls
    end
    object chkShowPropBar: TCheckBox
      Left = 8
      Top = 16
      Width = 217
      Height = 17
      Caption = 'Show Float Property Bar.'
      TabOrder = 0
      OnClick = UpdateControls
    end
    object mmoFreq: TMemo
      Left = 8
      Top = 224
      Width = 217
      Height = 101
      ScrollBars = ssVertical
      TabOrder = 8
      OnExit = UpdateControls
    end
    object seNameWidth: TCnSpinEdit
      Left = 112
      Top = 36
      Width = 113
      Height = 22
      MaxValue = 300
      MinValue = 20
      TabOrder = 1
      Value = 20
      OnChange = UpdateControls
    end
    object seValueWidth: TCnSpinEdit
      Left = 112
      Top = 61
      Width = 113
      Height = 22
      MaxValue = 300
      MinValue = 20
      TabOrder = 2
      Value = 20
      OnChange = UpdateControls
    end
  end
end
