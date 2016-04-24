object CnTestWizardForm: TCnTestWizardForm
  Left = 297
  Top = 270
  BorderStyle = bsDialog
  Caption = 'Test Wizard for CnPack IDE Wizards'
  ClientHeight = 163
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object grpTestWizard: TGroupBox
    Left = 8
    Top = 8
    Width = 305
    Height = 113
    Caption = 'Generate a &Test Wizard'
    TabOrder = 0
    object lblClassName: TLabel
      Left = 16
      Top = 24
      Width = 59
      Height = 13
      Caption = 'Class &Name:'
      FocusControl = edtClassName
    end
    object lblMenuCaption: TLabel
      Left = 16
      Top = 52
      Width = 70
      Height = 13
      Caption = 'Menu &Caption:'
      FocusControl = edtMenuCaption
    end
    object lblComment: TLabel
      Left = 16
      Top = 78
      Width = 49
      Height = 13
      Caption = 'Co&mment:'
      FocusControl = edtComment
    end
    object lblCnTest: TLabel
      Left = 112
      Top = 24
      Width = 40
      Height = 13
      Caption = 'TCnTest'
    end
    object lblWizard: TLabel
      Left = 256
      Top = 24
      Width = 33
      Height = 13
      Caption = 'Wizard'
    end
    object lblTest: TLabel
      Left = 112
      Top = 52
      Width = 24
      Height = 13
      Caption = 'Test '
    end
    object edtMenuCaption: TEdit
      Left = 144
      Top = 50
      Width = 145
      Height = 21
      TabOrder = 1
      Text = 'A Feature'
    end
    object edtClassName: TEdit
      Left = 160
      Top = 22
      Width = 89
      Height = 21
      TabOrder = 0
      Text = 'AFeature'
    end
    object edtComment: TEdit
      Left = 112
      Top = 76
      Width = 177
      Height = 21
      TabOrder = 2
    end
  end
  object btnOK: TButton
    Left = 151
    Top = 131
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 237
    Top = 131
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object dlgSave: TSaveDialog
    Filter = 'Pascal File (*.pas)|*.pas'
    Left = 96
    Top = 120
  end
end
