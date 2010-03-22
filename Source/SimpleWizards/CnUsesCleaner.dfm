inherited CnUsesCleanerForm: TCnUsesCleanerForm
  Left = 335
  Top = 163
  BorderStyle = bsDialog
  Caption = 'Uses Units Cleaner'
  ClientHeight = 365
  ClientWidth = 392
  PixelsPerInch = 96
  TextHeight = 13
  object grpKind: TGroupBox
    Left = 8
    Top = 8
    Width = 377
    Height = 97
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
    end
    object rbCurrProject: TRadioButton
      Left = 8
      Top = 54
      Width = 281
      Height = 17
      Caption = 'All Units in Current Project(&3).'
      TabOrder = 2
      TabStop = True
    end
    object rbProjectGroup: TRadioButton
      Left = 8
      Top = 72
      Width = 281
      Height = 17
      Caption = 'All Units in Current ProjectGroup(&4).'
      TabOrder = 3
      TabStop = True
    end
    object rbOpenedUnits: TRadioButton
      Left = 8
      Top = 36
      Width = 281
      Height = 17
      Caption = 'Opened Units in Current ProjectGroup(&2).'
      TabOrder = 1
      TabStop = True
    end
  end
  object btnOK: TButton
    Left = 150
    Top = 336
    Width = 75
    Height = 21
    Caption = '&Process'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 230
    Top = 336
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 310
    Top = 336
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object grpSettings: TGroupBox
    Left = 8
    Top = 112
    Width = 377
    Height = 217
    Caption = 'Clean &Settings'
    TabOrder = 1
    object lblIgnore: TLabel
      Left = 8
      Top = 104
      Width = 97
      Height = 13
      Caption = 'Clean Units Directly:'
    end
    object lbl1: TLabel
      Left = 192
      Top = 104
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
      Top = 120
      Width = 177
      Height = 89
      ScrollBars = ssVertical
      TabOrder = 4
    end
    object mmoIgnore: TMemo
      Left = 192
      Top = 120
      Width = 177
      Height = 89
      ScrollBars = ssVertical
      TabOrder = 5
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
  end
end
