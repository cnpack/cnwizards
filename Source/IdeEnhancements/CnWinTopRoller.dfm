inherited CnTopRollerForm: TCnTopRollerForm
  Left = 231
  Top = 73
  BorderStyle = bsDialog
  Caption = 'Caption Button Enhancements Settings'
  ClientWidth = 344
  PixelsPerInch = 96
  TextHeight = 13
  object grpMain: TGroupBox
    Left = 8
    Top = 8
    Width = 329
    Height = 99
    Caption = '&Buttons Settings'
    TabOrder = 0
    object lblButtons: TLabel
      Left = 8
      Top = 16
      Width = 203
      Height = 13
      Caption = 'Add Those Buttons to Non-Modal Window:'
    end
    object chkCaptionPacked: TCheckBox
      Left = 8
      Top = 54
      Width = 313
      Height = 17
      Caption = 'Ignore Caption Text Width (Always Show Buttons)'
      TabOrder = 3
    end
    object chkAnimate: TCheckBox
      Left = 8
      Top = 74
      Width = 313
      Height = 17
      Caption = 'Animated Rolling'
      TabOrder = 4
    end
    object chkShowTop: TCheckBox
      Left = 24
      Top = 34
      Width = 89
      Height = 17
      Caption = 'Stay On Top'
      TabOrder = 0
    end
    object chkShowRoller: TCheckBox
      Left = 120
      Top = 34
      Width = 89
      Height = 17
      Caption = 'Roll'
      TabOrder = 1
    end
    object chkShowOptions: TCheckBox
      Left = 216
      Top = 34
      Width = 105
      Height = 17
      Caption = 'Options'
      TabOrder = 2
    end
  end
  object grpFilter: TGroupBox
    Left = 8
    Top = 112
    Width = 329
    Height = 307
    Caption = '&Filters Settings'
    TabOrder = 1
    object chkFilter: TCheckBox
      Left = 8
      Top = 16
      Width = 313
      Height = 17
      Caption = 'Enable Window ClassName Filters to Disable Caption Buttons'
      TabOrder = 0
    end
    object ListView: TListView
      Left = 8
      Top = 40
      Width = 313
      Height = 201
      Checkboxes = True
      Columns = <
        item
          Caption = 'Window ClassName'
          Width = 140
        end
        item
          Caption = 'Comment'
          Width = 152
        end>
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      ViewStyle = vsReport
      OnClick = ListViewClick
      OnKeyDown = ListViewKeyDown
    end
    object cbbClassName: TComboBox
      Left = 8
      Top = 248
      Width = 137
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbbClassNameChange
      Items.Strings = (
        'TAppBuilder'
        'TObjectTreeView'
        'TPropertyInspector'
        'TEditWindow'
        'TPasModExpForm'
        'TProjectManagerForm'
        'TToDoListWindow'
        'TAlignPalette'
        'TSynbolExplorer'
        'TCompListForm'
        'TMessageHintFrm'
        'TBPWindow'
        'TCallStackWindow'
        'TWatchWindow'
        'TLocalVarsWindow'
        'TThreadStatus'
        'TModulesView'
        'TDebugLogView'
        'TDisassemblyView'
        'TFPUWindow'
        'TCustomizeDlg'
        'TEvalDialog'
        'TDbExplorerForm'
        'TMenuBuilder'
        'TActionListDesigner'
        'TFieldsEditor'
        'TCollectionEditor'
        'TCustomizeActnEditDesigner')
    end
    object cbbComment: TComboBox
      Left = 152
      Top = 248
      Width = 169
      Height = 21
      ItemHeight = 13
      TabOrder = 3
      OnChange = cbbCommentChange
      Items.Strings = (
        'IDE Main Window'
        'Object TreeView'
        'Object Inspector'
        'Source Editor'
        'Code Explorer'
        'Project Manager'
        'ToDo List'
        'Align Palette'
        'Browse Synbol'
        'Component List'
        'Message Hint'
        'Break Points'
        'Call Stack'
        'Watches'
        'Local Variables'
        'Threads'
        'Modules'
        'Event Log'
        'CPU Window'
        'FPU Window'
        'Toolbar Customize'
        'Evaluate/Modify'
        'DataBase Explorer'
        'Menu Designer'
        'ActionList Designer'
        'Fields Editor'
        'Collection Editor'
        'ActionManager Editor')
    end
    object btnReplace: TButton
      Left = 9
      Top = 276
      Width = 75
      Height = 21
      Action = actReplace
      TabOrder = 4
    end
    object btnAdd: TButton
      Left = 89
      Top = 276
      Width = 75
      Height = 21
      Action = actAdd
      TabOrder = 5
    end
    object btnDel: TButton
      Left = 169
      Top = 276
      Width = 75
      Height = 21
      Action = actDelete
      TabOrder = 6
    end
  end
  object btnOK: TButton
    Left = 98
    Top = 425
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 184
    Top = 425
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 262
    Top = 425
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object ActionList: TActionList
    OnUpdate = ActionListUpdate
    Left = 264
    Top = 376
    object actReplace: TAction
      Caption = '&Replace'
      OnExecute = actReplaceExecute
    end
    object actAdd: TAction
      Caption = '&Add'
      OnExecute = actAddExecute
    end
    object actDelete: TAction
      Caption = '&Delete'
      OnExecute = actDeleteExecute
    end
  end
end
