inherited CnUsesCleanerForm: TCnUsesCleanerForm
  Left = 295
  Top = 131
  BorderStyle = bsDialog
  Caption = 'Uses Units Cleaner'
  ClientHeight = 406
  ClientWidth = 392
  PixelsPerInch = 96
  TextHeight = 13
  object grpKind: TGroupBox
    Left = 8
    Top = 8
    Width = 377
    Height = 120
    Caption = '&Select Content to Process'
    TabOrder = 0
    object rbCurrUnit: TRadioButton
      Left = 8
      Top = 18
      Width = 281
      Height = 17
      Caption = 'Current Unit(&1).'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rbCurrUnitClick
    end
    object rbCurrProject: TRadioButton
      Left = 8
      Top = 54
      Width = 281
      Height = 17
      Caption = 'All Units in Current Project(&3).'
      TabOrder = 2
      TabStop = True
      OnClick = rbCurrUnitClick
    end
    object rbProjectGroup: TRadioButton
      Left = 8
      Top = 72
      Width = 281
      Height = 17
      Caption = 'All Units in Current ProjectGroup(&4).'
      TabOrder = 3
      TabStop = True
      OnClick = rbCurrUnitClick
    end
    object rbOpenedUnits: TRadioButton
      Left = 8
      Top = 36
      Width = 281
      Height = 17
      Caption = 'Opened Units in Current ProjectGroup(&2).'
      TabOrder = 1
      TabStop = True
      OnClick = rbCurrUnitClick
    end
    object chkProcessDependencies: TCheckBox
      Left = 24
      Top = 94
      Width = 340
      Height = 17
      Caption = 'Include Indirecty Used Units.'
      Enabled = False
      TabOrder = 4
    end
  end
  object btnOK: TButton
    Left = 150
    Top = 378
    Width = 75
    Height = 21
    Caption = '&Process'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 230
    Top = 378
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 310
    Top = 378
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object grpSettings: TGroupBox
    Left = 8
    Top = 132
    Width = 377
    Height = 239
    Caption = 'Clean &Settings'
    TabOrder = 1
    object lblIgnore: TLabel
      Left = 8
      Top = 126
      Width = 97
      Height = 13
      Caption = 'Clean Units Directly:'
    end
    object lbl1: TLabel
      Left = 192
      Top = 126
      Width = 89
      Height = 13
      Caption = 'Skip Units Directly:'
    end
    object chkIgnoreInit: TCheckBox
      Left = 8
      Top = 16
      Width = 361
      Height = 17
      Caption = 'Skip Used Units including Initialization Part.'
      TabOrder = 0
    end
    object chkIgnoreReg: TCheckBox
      Left = 8
      Top = 38
      Width = 361
      Height = 17
      Caption = 'Skip Used Units including Register Procedure.'
      TabOrder = 1
    end
    object mmoClean: TMemo
      Left = 8
      Top = 144
      Width = 177
      Height = 89
      ScrollBars = ssBoth
      TabOrder = 5
      WordWrap = False
    end
    object mmoIgnore: TMemo
      Left = 192
      Top = 144
      Width = 177
      Height = 89
      ScrollBars = ssBoth
      TabOrder = 6
      WordWrap = False
    end
    object chkIgnoreNoSrc: TCheckBox
      Left = 8
      Top = 82
      Width = 361
      Height = 17
      Caption = 'Skip Used Units without Source.'
      TabOrder = 3
    end
    object chkIgnoreCompRef: TCheckBox
      Left = 8
      Top = 60
      Width = 361
      Height = 17
      Caption = 'Skip Used Units Referred by Component Indirectly.'
      TabOrder = 2
    end
    object chkSaveAndClose: TCheckBox
      Left = 8
      Top = 104
      Width = 361
      Height = 17
      Caption = 'Auto Save/Close Unopened Files(For Huge Project but Can'#39't Undo).'
      TabOrder = 4
    end
  end
end
