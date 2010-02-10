inherited CnPrefixExecuteForm: TCnPrefixExecuteForm
  Left = 331
  Top = 202
  BorderStyle = bsDialog
  Caption = 'Component Prefix Wizard'
  ClientHeight = 260
  ClientWidth = 369
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 46
    Top = 232
    Width = 73
    Height = 21
    Caption = '&Process'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 206
    Top = 232
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 4
  end
  object btnHelp: TButton
    Left = 286
    Top = 232
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 5
    OnClick = btnHelpClick
  end
  object btnConfig: TButton
    Left = 126
    Top = 232
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Settings'
    TabOrder = 3
  end
  object gbKind: TGroupBox
    Left = 8
    Top = 8
    Width = 353
    Height = 129
    Caption = 'Please &Select which to be Processed'
    TabOrder = 0
    object rbSelComp: TRadioButton
      Left = 8
      Top = 16
      Width = 310
      Height = 17
      Caption = 'Selected Components.'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbCurrForm: TRadioButton
      Left = 8
      Top = 38
      Width = 310
      Height = 17
      Caption = 'All Components in Current Form.'
      TabOrder = 1
    end
    object rbOpenedForm: TRadioButton
      Left = 8
      Top = 60
      Width = 310
      Height = 17
      Caption = 'All Components in All Opened Forms.'
      TabOrder = 2
    end
    object rbCurrProject: TRadioButton
      Left = 8
      Top = 82
      Width = 310
      Height = 17
      Caption = 'All Components in All Forms of Project.'
      TabOrder = 3
    end
    object rbProjectGroup: TRadioButton
      Left = 8
      Top = 104
      Width = 310
      Height = 17
      Caption = 'All Components in All Forms of ProjectGroup.'
      TabOrder = 4
    end
  end
  object rgCompKind: TRadioGroup
    Left = 8
    Top = 144
    Width = 353
    Height = 81
    Caption = 'Process Those in the &List'
    ItemIndex = 0
    Items.Strings = (
      'Components with Unproper Prefix'
      'Components with Unproper Prefix or Name + Digital'
      'All Components including Those Ignored.')
    TabOrder = 1
  end
end
