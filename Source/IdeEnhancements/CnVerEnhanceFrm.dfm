inherited CnVerEnhanceForm: TCnVerEnhanceForm
  Left = 427
  Top = 392
  BorderStyle = bsDialog
  Caption = 'Version Enhancements Settings'
  ClientHeight = 125
  ClientWidth = 403
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpVerEnh: TGroupBox
    Left = 8
    Top = 8
    Width = 387
    Height = 81
    Caption = '&Version Enhancements Settings'
    TabOrder = 0
    object lblNote: TLabel
      Left = 24
      Top = 56
      Width = 306
      Height = 13
      Caption = '(Note: Both Only Enabled when Include Version Info in Project.)'
    end
    object chkLastCompiled: TCheckBox
      Left = 8
      Top = 16
      Width = 377
      Height = 17
      Caption = 'Insert Compiling Time into Version Info(Delphi 6 Above Only).'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkIncBuild: TCheckBox
      Left = 8
      Top = 36
      Width = 377
      Height = 17
      Caption = 'Auto-increment Build Number when Compiling(Delphi 6 Above Only).'
      TabOrder = 1
    end
  end
  object btnOK: TButton
    Left = 157
    Top = 96
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 239
    Top = 96
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 320
    Top = 96
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
