inherited CnDUnitSetForm: TCnDUnitSetForm
  Left = 349
  Top = 263
  BorderStyle = bsDialog
  Caption = 'DUnit Wizard'
  ClientHeight = 168
  ClientWidth = 268
  PixelsPerInch = 96
  TextHeight = 13
  object gbxSetup: TGroupBox
    Left = 12
    Top = 12
    Width = 246
    Height = 117
    Caption = 'Options'
    TabOrder = 0
    object chbxUnitHead: TCheckBox
      Left = 16
      Top = 81
      Width = 161
      Height = 17
      Caption = 'Add Comment Head'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object chbxInitClass: TCheckBox
      Left = 16
      Top = 60
      Width = 161
      Height = 17
      Caption = 'Initialize Test Class'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object rbCreateApplication: TRadioButton
      Left = 16
      Top = 16
      Width = 169
      Height = 17
      Caption = 'New DUnit Test Application'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbCreateUnit: TRadioButton
      Left = 16
      Top = 38
      Width = 169
      Height = 17
      Caption = 'New DUnit Test Unit'
      TabOrder = 1
    end
  end
  object btnOK: TButton
    Left = 11
    Top = 138
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 97
    Top = 138
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 182
    Top = 138
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
