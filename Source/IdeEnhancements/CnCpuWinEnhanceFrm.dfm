inherited CnCpuWinEnhanceForm: TCnCpuWinEnhanceForm
  Left = 347
  Top = 219
  BorderStyle = bsDialog
  Caption = 'CPU Window Enhancements Settings'
  ClientHeight = 204
  ClientWidth = 249
  FormStyle = fsStayOnTop
  PixelsPerInch = 96
  TextHeight = 13
  object CopyParam: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 73
    Caption = 'Settings'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 21
      Width = 72
      Height = 12
      AutoSize = False
      Caption = 'Copy Lines:'
    end
    object rbTopAddr: TRadioButton
      Left = 8
      Top = 48
      Width = 105
      Height = 17
      Caption = 'From Beginning'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object rbSelectAddr: TRadioButton
      Left = 112
      Top = 48
      Width = 113
      Height = 17
      Caption = 'From Selected Line'
      TabOrder = 2
    end
    object seCopyLineCount: TCnSpinEdit
      Left = 88
      Top = 16
      Width = 129
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 30
      OnKeyPress = seCopyLineCountKeyPress
    end
  end
  object cbSettingToAll: TCheckBox
    Left = 8
    Top = 152
    Width = 153
    Height = 17
    Caption = 'Set As Default.'
    TabOrder = 2
  end
  object rgCopyToMode: TRadioGroup
    Left = 8
    Top = 88
    Width = 233
    Height = 57
    Caption = 'Copy Result'
    Items.Strings = (
      'Copy To Clipboard'
      'Copy To File')
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 8
    Top = 176
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 88
    Top = 176
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object btnHelp: TButton
    Left = 168
    Top = 176
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 5
    OnClick = btnHelpClick
  end
end
