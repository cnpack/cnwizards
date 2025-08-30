inherited CnComponentSelectorForm: TCnComponentSelectorForm
  Left = 235
  Top = 111
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Component Selection Tools'
  ClientHeight = 489
  ClientWidth = 704
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object gbFilter: TGroupBox
    Left = 8
    Top = 8
    Width = 241
    Height = 137
    Caption = 'Container &Filter'
    TabOrder = 0
    object rbCurrForm: TRadioButton
      Left = 8
      Top = 16
      Width = 223
      Height = 17
      Caption = 'All Components in Form'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = DoUpdateListControls
    end
    object rbCurrControl: TRadioButton
      Left = 8
      Top = 38
      Width = 223
      Height = 17
      Caption = 'All Subs of Selected'
      TabOrder = 1
      OnClick = DoUpdateListControls
    end
    object rbSpecControl: TRadioButton
      Left = 8
      Top = 60
      Width = 223
      Height = 17
      Caption = 'All Subs of Specified'
      TabOrder = 2
      OnClick = DoUpdateListControls
    end
    object cbbFilterControl: TComboBox
      Left = 24
      Top = 84
      Width = 209
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      Sorted = True
      TabOrder = 3
      OnChange = DoUpdateList
    end
    object cbIncludeChildren: TCheckBox
      Left = 8
      Top = 112
      Width = 223
      Height = 17
      Caption = 'Contains Multi-level Sub-components'
      TabOrder = 4
      OnClick = DoUpdateList
    end
  end
  object gbByName: TGroupBox
    Left = 256
    Top = 8
    Width = 233
    Height = 137
    Caption = 'Component &Name Filter'
    TabOrder = 1
    object edtByName: TEdit
      Left = 24
      Top = 40
      Width = 201
      Height = 21
      TabOrder = 1
      OnChange = DoUpdateList
    end
    object cbByName: TCheckBox
      Left = 8
      Top = 16
      Width = 217
      Height = 17
      Caption = 'Enable Component Name Filter'
      TabOrder = 0
      OnClick = DoUpdateListControls
    end
    object cbByClass: TCheckBox
      Left = 8
      Top = 64
      Width = 217
      Height = 17
      Caption = 'Enable Component Type Filter'
      TabOrder = 2
      OnClick = DoUpdateListControls
    end
    object cbbByClass: TComboBox
      Left = 24
      Top = 84
      Width = 201
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      Sorted = True
      TabOrder = 3
      OnChange = DoUpdateList
    end
    object cbSubClass: TCheckBox
      Left = 24
      Top = 112
      Width = 201
      Height = 17
      Caption = 'Contains Descendent Class'
      TabOrder = 4
      OnClick = DoUpdateList
    end
  end
  object gbComponentList: TGroupBox
    Left = 8
    Top = 152
    Width = 689
    Height = 301
    Caption = 'Co&mponents'#39' List'
    TabOrder = 3
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 110
      Height = 13
      Caption = 'Available Components:'
    end
    object Label2: TLabel
      Left = 384
      Top = 16
      Width = 108
      Height = 13
      Caption = 'Selected Components:'
    end
    object Label4: TLabel
      Left = 8
      Top = 273
      Width = 53
      Height = 13
      Caption = 'Sort Mode:'
    end
    object lbSource: TListBox
      Left = 8
      Top = 32
      Width = 297
      Height = 233
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
      OnDblClick = actAddExecute
    end
    object btnAdd: TButton
      Left = 312
      Top = 40
      Width = 65
      Height = 21
      Action = actAdd
      TabOrder = 2
    end
    object btnAddAll: TButton
      Left = 312
      Top = 64
      Width = 65
      Height = 21
      Action = actAddAll
      TabOrder = 3
    end
    object btnDelete: TButton
      Left = 312
      Top = 88
      Width = 65
      Height = 21
      Action = actDelete
      TabOrder = 4
    end
    object btnDeleteAll: TButton
      Left = 312
      Top = 112
      Width = 65
      Height = 21
      Action = actDeleteAll
      TabOrder = 5
    end
    object btnSelAll: TButton
      Left = 312
      Top = 192
      Width = 65
      Height = 21
      Action = actSelAll
      TabOrder = 6
    end
    object btnSelNone: TButton
      Left = 312
      Top = 216
      Width = 65
      Height = 21
      Action = actSelNone
      TabOrder = 7
    end
    object btnSelInvert: TButton
      Left = 312
      Top = 240
      Width = 65
      Height = 21
      Action = actSelInvert
      TabOrder = 8
    end
    object lbDest: TListBox
      Left = 384
      Top = 32
      Width = 297
      Height = 233
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 1
      OnDblClick = actDeleteExecute
    end
    object cbbSourceOrderStyle: TComboBox
      Left = 64
      Top = 270
      Width = 137
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 9
      OnChange = DoUpdateSourceOrder
      Items.Strings = (
        'Default Order'
        'Sort By Name'
        'Sort By Type')
    end
    object cbbSourceOrderDir: TComboBox
      Left = 208
      Top = 270
      Width = 97
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 10
      OnChange = DoUpdateSourceOrder
      Items.Strings = (
        'Ascending'
        'Descending')
    end
    object btnMoveToTop: TButton
      Left = 384
      Top = 270
      Width = 79
      Height = 21
      Action = actMoveToTop
      TabOrder = 11
    end
    object btnMoveToBottom: TButton
      Left = 467
      Top = 270
      Width = 79
      Height = 21
      Action = actMoveToBottom
      TabOrder = 12
    end
    object btnMoveUp: TButton
      Left = 551
      Top = 270
      Width = 63
      Height = 21
      Action = actMoveUp
      TabOrder = 13
    end
    object btnMoveDown: TButton
      Left = 618
      Top = 270
      Width = 63
      Height = 21
      Action = actMoveDown
      TabOrder = 14
    end
  end
  object btnHelp: TButton
    Left = 622
    Top = 462
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 6
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 462
    Top = 462
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    TabOrder = 4
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 542
    Top = 462
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object gbTag: TGroupBox
    Left = 496
    Top = 8
    Width = 201
    Height = 137
    Caption = 'Event and &Tag Filter'
    TabOrder = 2
    object lblTag: TLabel
      Left = 106
      Top = 110
      Width = 4
      Height = 13
      Caption = '-'
    end
    object cbByTag: TCheckBox
      Left = 8
      Top = 60
      Width = 185
      Height = 17
      Caption = 'Enable Tag Filter'
      TabOrder = 2
      OnClick = DoUpdateListControls
    end
    object cbbByTag: TComboBox
      Left = 24
      Top = 80
      Width = 169
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      OnChange = DoUpdateListControls
      Items.Strings = (
        'Tag ='
        'Tag <'
        'Tag >'
        'Tag Betweens')
    end
    object seTagStart: TCnSpinEdit
      Left = 24
      Top = 107
      Width = 73
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 0
      OnChange = DoUpdateList
    end
    object seTagEnd: TCnSpinEdit
      Left = 120
      Top = 107
      Width = 73
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 5
      Value = 0
      OnChange = DoUpdateList
    end
    object chkByEvent: TCheckBox
      Left = 8
      Top = 16
      Width = 185
      Height = 17
      Caption = 'Enable Event Filter'
      TabOrder = 0
      OnClick = DoUpdateListControls
    end
    object cbbByEvent: TComboBox
      Left = 24
      Top = 36
      Width = 169
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      Sorted = True
      TabOrder = 1
      OnChange = DoUpdateList
    end
  end
  object cbDefaultSelAll: TCheckBox
    Left = 8
    Top = 461
    Width = 305
    Height = 17
    Caption = 'Select All when Nothing Selected.'
    Checked = True
    State = cbChecked
    TabOrder = 7
  end
  object ActionList: TActionList
    Left = 528
    Top = 8
    object actAdd: TAction
      Category = 'AddDelete'
      Caption = '>'
      OnExecute = actAddExecute
    end
    object actAddAll: TAction
      Category = 'AddDelete'
      Caption = '>>'
      OnExecute = actAddAllExecute
    end
    object actDelete: TAction
      Category = 'AddDelete'
      Caption = '<'
      OnExecute = actDeleteExecute
    end
    object actDeleteAll: TAction
      Category = 'AddDelete'
      Caption = '<<'
      OnExecute = actDeleteAllExecute
    end
    object actSelAll: TAction
      Category = 'Selection'
      Caption = 'Select &All'
      OnExecute = actSelAllExecute
    end
    object actSelNone: TAction
      Category = 'Selection'
      Caption = '&Deselect All'
      OnExecute = actSelNoneExecute
    end
    object actSelInvert: TAction
      Category = 'Selection'
      Caption = '&Inverse'
      OnExecute = actSelInvertExecute
      OnUpdate = DoActionListUpdate
    end
    object actMoveToTop: TAction
      Category = 'Move'
      Caption = 'Move to Top'
      OnExecute = actMoveToTopExecute
    end
    object actMoveToBottom: TAction
      Category = 'Move'
      Caption = 'Move to Bottom'
      OnExecute = actMoveToBottomExecute
    end
    object actMoveUp: TAction
      Category = 'Move'
      Caption = 'Move Up'
      OnExecute = actMoveUpExecute
    end
    object actMoveDown: TAction
      Category = 'Move'
      Caption = 'Move Down'
      OnExecute = actMoveDownExecute
    end
  end
end
