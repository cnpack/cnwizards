inherited CnVerEnhanceForm: TCnVerEnhanceForm
  Left = 437
  Top = 200
  BorderStyle = bsDialog
  Caption = 'Version Enhancements Settings'
  ClientHeight = 162
  ClientWidth = 403
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpVerEnh: TGroupBox
    Left = 8
    Top = 8
    Width = 387
    Height = 115
    Caption = '&Version Enhancements Settings'
    TabOrder = 0
    object lblNote: TLabel
      Left = 24
      Top = 86
      Width = 306
      Height = 15
      Caption = '(Note: Options Only Enabled when Include Version Info in Project.)'
    end
    object lblFormat: TLabel
      Left = 24
      Top = 42
      Width = 63
      Height = 13
      Caption = 'Time Format:'
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
      OnClick = chkLastCompiledClick
    end
    object chkIncBuild: TCheckBox
      Left = 8
      Top = 64
      Width = 377
      Height = 19
      Caption = 'Auto-increment Build Number when Compiling(Delphi 6 Above Only).'
      TabOrder = 1
    end
    object cbbFormat: TComboBox
      Left = 112
      Top = 40
      Width = 201
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      Items.Strings = (
        'yyyy/mm/dd hh:mm:ss'
        'yyyy-mm-dd hh:mm:ss'
        'yyyy-mm-dd_hh-mm-ss')
    end
  end
  object btnOK: TButton
    Left = 157
    Top = 133
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
    Top = 133
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
    Top = 133
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
