inherited CnInputHelperForm: TCnInputHelperForm
  Left = 233
  Top = 101
  BorderStyle = bsDialog
  Caption = 'Input Helper Settings'
  ClientHeight = 522
  ClientWidth = 592
  KeyPreview = True
  OnActivate = FormActivate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnHelp: TButton
    Left = 510
    Top = 493
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 351
    Top = 493
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 431
    Top = 493
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 577
    Height = 478
    ActivePage = ts1
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object ts1: TTabSheet
      Caption = 'In&put Helper'
      object grp1: TGroupBox
        Left = 8
        Top = 8
        Width = 553
        Height = 225
        Caption = '&Auto-Settings'
        TabOrder = 0
        object lbl1: TLabel
          Left = 26
          Top = 35
          Width = 199
          Height = 13
          Caption = 'Popup after How Many Characters Input:'
        end
        object lbl2: TLabel
          Left = 250
          Top = 16
          Width = 99
          Height = 13
          Caption = 'Delay before Popup:'
        end
        object lbl3: TLabel
          Left = 232
          Top = 66
          Width = 40
          Height = 12
          Alignment = taCenter
          AutoSize = False
          Caption = '0.1 Sec'
        end
        object lbl4: TLabel
          Left = 504
          Top = 66
          Width = 38
          Height = 12
          Alignment = taCenter
          AutoSize = False
          Caption = '2 Sec'
        end
        object lbl5: TLabel
          Left = 8
          Top = 151
          Width = 153
          Height = 13
          Caption = 'Shortcut to Toggle Auto-Popup:'
        end
        object lbl6: TLabel
          Left = 8
          Top = 175
          Width = 155
          Height = 13
          Caption = 'Shortcut to Popup List Manually:'
        end
        object chkAutoPopup: TCheckBox
          Left = 8
          Top = 16
          Width = 169
          Height = 17
          Caption = 'Auto Popup Input Helper.'
          TabOrder = 0
          OnClick = UpdateControls
        end
        object seDispOnlyAtLeastKey: TCnSpinEdit
          Left = 24
          Top = 52
          Width = 145
          Height = 22
          MaxValue = 5
          MinValue = 1
          TabOrder = 2
          Value = 1
        end
        object tbDispDelay: TTrackBar
          Left = 240
          Top = 32
          Width = 305
          Height = 33
          Max = 2000
          Min = 100
          Orientation = trHorizontal
          PageSize = 500
          Frequency = 100
          Position = 100
          SelEnd = 0
          SelStart = 0
          TabOrder = 1
          TickMarks = tmBottomRight
          TickStyle = tsAuto
        end
        object chkSmartDisp: TCheckBox
          Left = 24
          Top = 78
          Width = 409
          Height = 17
          Caption = 'Intelligent Popup.'
          TabOrder = 3
        end
        object hkEnabled: THotKey
          Left = 248
          Top = 148
          Width = 289
          Height = 19
          HotKey = 32833
          InvalidKeys = [hcNone, hcShift]
          Modifiers = [hkAlt]
          TabOrder = 6
        end
        object hkPopup: THotKey
          Left = 248
          Top = 172
          Width = 289
          Height = 19
          HotKey = 32833
          InvalidKeys = [hcNone, hcShift]
          Modifiers = [hkAlt]
          TabOrder = 7
        end
        object chkCheckImmRun: TCheckBox
          Left = 8
          Top = 199
          Width = 401
          Height = 17
          Caption = 'Disable Input Helper when IME Opened.'
          TabOrder = 8
        end
        object chkDispOnIDECompDisabled: TCheckBox
          Left = 24
          Top = 99
          Width = 409
          Height = 17
          Caption = 'Replace Code Insight when Later is Disabled.'
          TabOrder = 4
        end
        object edtAutoSymbols: TEdit
          Left = 248
          Top = 121
          Width = 289
          Height = 21
          TabOrder = 5
        end
        object chkKeySeq: TCheckBox
          Left = 24
          Top = 125
          Width = 209
          Height = 13
          Caption = 'Auto Popup after Key Sequences:'
          TabOrder = 9
          OnClick = UpdateControls
        end
      end
      object grp3: TGroupBox
        Left = 8
        Top = 240
        Width = 553
        Height = 198
        Caption = 'O&utput Settings'
        TabOrder = 1
        object lbl9: TLabel
          Left = 8
          Top = 20
          Width = 167
          Height = 13
          Caption = 'Input Current Item when Pressing:'
        end
        object lbl10: TLabel
          Left = 8
          Top = 74
          Width = 102
          Height = 13
          Caption = 'Symbol Output Style:'
        end
        object lbl16: TLabel
          Left = 8
          Top = 47
          Width = 189
          Height = 13
          Caption = 'DO NOT Popup after these Characters:'
        end
        object edtCompleteChars: TEdit
          Left = 248
          Top = 16
          Width = 289
          Height = 21
          TabOrder = 0
        end
        object cbbOutputStyle: TComboBox
          Left = 248
          Top = 70
          Width = 289
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 2
          Items.Strings = (
            'Automatic'
            'Replace Left Side of Symbol'
            'Replace the Whole Symbol'
            'Replace the Whole Symbol Only when Pressing Enter')
        end
        object chkSelMidMatchByEnterOnly: TCheckBox
          Left = 8
          Top = 132
          Width = 529
          Height = 17
          Caption = 'Select and Input Middle-Matched Symbol Only when Pressing Enter.'
          TabOrder = 5
        end
        object chkAutoInsertEnter: TCheckBox
          Left = 8
          Top = 150
          Width = 529
          Height = 17
          Caption = 'Auto Line Feed after Keyword when Pressing Enter.'
          TabOrder = 6
        end
        object chkSpcComplete: TCheckBox
          Left = 8
          Top = 96
          Width = 529
          Height = 17
          Caption = 'Allow Inputting Current Item by Pressing Space.'
          TabOrder = 3
          OnClick = chkSpcCompleteClick
        end
        object chkAutoCompParam: TCheckBox
          Left = 8
          Top = 168
          Width = 529
          Height = 17
          Caption = 'Auto Insert Brackets for Function Having Parameters.'
          TabOrder = 7
        end
        object edtFilterSymbols: TEdit
          Left = 248
          Top = 43
          Width = 289
          Height = 21
          TabOrder = 1
        end
        object chkIgnoreSpace: TCheckBox
          Left = 24
          Top = 114
          Width = 521
          Height = 17
          Caption = 'Ignore Space Char after Inputting Current Item.'
          TabOrder = 4
        end
      end
    end
    object ts2: TTabSheet
      Caption = '&List Settings'
      ImageIndex = 1
      object grp2: TGroupBox
        Left = 8
        Top = 8
        Width = 553
        Height = 193
        Caption = '&Display Settings'
        TabOrder = 0
        object lbl7: TLabel
          Left = 8
          Top = 47
          Width = 106
          Height = 13
          Caption = 'Min Length of Symbol:'
        end
        object lbl8: TLabel
          Left = 8
          Top = 20
          Width = 70
          Height = 13
          Caption = 'List Sorted by:'
        end
        object PaintBox: TPaintBox
          Left = 432
          Top = 45
          Width = 113
          Height = 25
          OnPaint = PaintBoxPaint
        end
        object lbl15: TLabel
          Left = 8
          Top = 76
          Width = 84
          Height = 13
          Caption = 'Reserved Words:'
        end
        object seListOnlyAtLeastLetter: TCnSpinEdit
          Left = 120
          Top = 43
          Width = 249
          Height = 22
          MaxValue = 5
          MinValue = 1
          TabOrder = 2
          Value = 1
        end
        object chkMatchAnyWhere: TCheckBox
          Left = 8
          Top = 98
          Width = 505
          Height = 17
          Caption = 'Display Middle-Matched Symbols.'
          TabOrder = 4
        end
        object cbbSortKind: TComboBox
          Left = 120
          Top = 16
          Width = 249
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
        end
        object btnFont: TButton
          Left = 432
          Top = 16
          Width = 113
          Height = 21
          Caption = 'List Font...'
          TabOrder = 1
          OnClick = btnFontClick
        end
        object chkAutoAdjustScope: TCheckBox
          Left = 8
          Top = 116
          Width = 505
          Height = 17
          Caption = 'Adjust Priority Automatically according to the Frequency.'
          TabOrder = 5
        end
        object chkUseCodeInsightMgr: TCheckBox
          Left = 8
          Top = 152
          Width = 505
          Height = 17
          Caption = 'Use the Compatible Way to Obtain Symbols.(slower)'
          TabOrder = 7
        end
        object chkRemoveSame: TCheckBox
          Left = 8
          Top = 134
          Width = 505
          Height = 17
          Caption = 'Remove Duplicate Symbols.'
          TabOrder = 6
        end
        object cbbKeyword: TComboBox
          Left = 120
          Top = 72
          Width = 249
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 3
        end
        object chkUseKibitzCompileThread: TCheckBox
          Left = 8
          Top = 170
          Width = 505
          Height = 17
          Caption = 'Prefetch Symbols List when Opening Project.'
          TabOrder = 8
        end
      end
      object grp4: TGroupBox
        Left = 8
        Top = 210
        Width = 553
        Height = 228
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'Conten&t Settings'
        TabOrder = 1
        object lbl11: TLabel
          Left = 8
          Top = 20
          Width = 100
          Height = 13
          Caption = 'Symbol Provider List:'
        end
        object lbl14: TLabel
          Left = 384
          Top = 20
          Width = 70
          Height = 13
          Caption = 'Symbol Types:'
        end
        object chklstSymbol: TCheckListBox
          Left = 8
          Top = 40
          Width = 369
          Height = 177
          Anchors = [akLeft, akTop, akBottom]
          ItemHeight = 13
          TabOrder = 0
        end
        object chklstKind: TCheckListBox
          Left = 384
          Top = 40
          Width = 161
          Height = 177
          Anchors = [akLeft, akTop, akBottom]
          ItemHeight = 13
          TabOrder = 1
        end
      end
    end
    object ts3: TTabSheet
      Caption = 'Customize &Symbols'
      ImageIndex = 2
      object grp5: TGroupBox
        Left = 8
        Top = 8
        Width = 553
        Height = 430
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'Cus&tomize Symbols'
        TabOrder = 0
        object lbl12: TLabel
          Left = 8
          Top = 20
          Width = 57
          Height = 13
          Caption = 'Symbol List:'
        end
        object lbl13: TLabel
          Left = 8
          Top = 224
          Width = 306
          Height = 13
          Caption = 'Code Template: (Only Used in "Template" and "Comment" Type)'
        end
        object lvList: TListView
          Left = 8
          Top = 48
          Width = 465
          Height = 169
          Columns = <
            item
              Caption = 'Name'
              Width = 100
            end
            item
              Caption = 'Type'
              Width = 70
            end
            item
              Caption = 'Scope'
              Width = 48
            end
            item
              Caption = 'Description'
              Width = 225
            end>
          HideSelection = False
          MultiSelect = True
          ReadOnly = True
          RowSelect = True
          TabOrder = 1
          ViewStyle = vsReport
          OnChange = lvListChange
          OnClick = UpdateListControls
          OnColumnClick = lvListColumnClick
          OnCompare = lvListCompare
          OnDblClick = btnEditClick
        end
        object btnAdd: TButton
          Left = 480
          Top = 48
          Width = 65
          Height = 21
          Caption = '&Add'
          TabOrder = 2
          OnClick = btnAddClick
        end
        object mmoTemplate: TMemo
          Left = 8
          Top = 240
          Width = 465
          Height = 182
          Anchors = [akLeft, akTop, akRight, akBottom]
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 9
          OnExit = mmoTemplateExit
        end
        object btnDelete: TButton
          Left = 480
          Top = 97
          Width = 65
          Height = 21
          Caption = '&Delete'
          TabOrder = 4
          OnClick = btnDeleteClick
        end
        object btnEdit: TButton
          Left = 480
          Top = 122
          Width = 65
          Height = 21
          Caption = '&Edit'
          TabOrder = 5
          OnClick = btnEditClick
        end
        object btnImport: TButton
          Left = 480
          Top = 171
          Width = 65
          Height = 21
          Caption = '&Import'
          TabOrder = 7
          OnClick = btnImportClick
        end
        object btnExport: TButton
          Left = 480
          Top = 196
          Width = 65
          Height = 21
          Caption = 'E&xport'
          TabOrder = 8
          OnClick = btnExportClick
        end
        object btnInsertMacro: TButton
          Left = 480
          Top = 241
          Width = 65
          Height = 21
          Caption = 'Insert &Macro'
          TabOrder = 10
          OnClick = btnInsertMacroClick
        end
        object btnCursor: TButton
          Left = 480
          Top = 296
          Width = 65
          Height = 21
          Caption = 'Curso&r'
          TabOrder = 12
          OnClick = btnCursorClick
        end
        object btnClear: TButton
          Left = 480
          Top = 324
          Width = 65
          Height = 21
          Caption = 'C&lear'
          TabOrder = 13
          OnClick = btnClearClick
        end
        object btnDup: TButton
          Left = 480
          Top = 73
          Width = 65
          Height = 21
          Caption = 'D&uplicate'
          TabOrder = 3
          OnClick = btnDupClick
        end
        object btnUserMacro: TButton
          Left = 480
          Top = 268
          Width = 65
          Height = 21
          Caption = 'U&ser Macro'
          TabOrder = 11
          OnClick = btnUserMacroClick
        end
        object btnDefault: TButton
          Left = 480
          Top = 147
          Width = 65
          Height = 21
          Caption = 'Defaul&t'
          TabOrder = 6
          OnClick = btnDefaultClick
        end
        object cbbList: TComboBox
          Left = 72
          Top = 16
          Width = 401
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
          OnChange = cbbListChange
        end
      end
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Options = []
    Left = 15
    Top = 456
  end
  object pmMacro: TPopupMenu
    Left = 79
    Top = 456
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'xml'
    Filter = 'Symbol List File(*.xml)|*.xml'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 47
    Top = 456
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'xml'
    Filter = 'Symbol List File(*.xml)|*.xml'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 111
    Top = 456
  end
end
