inherited CnVerEnhanceForm: TCnVerEnhanceForm
  Left = 437
  Top = 200
  BorderStyle = bsDialog
  Caption = 'Version Enhancements Settings'
  ClientHeight = 182
  ClientWidth = 403
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpVerEnh: TGroupBox
    Left = 8
    Top = 8
    Width = 387
    Height = 135
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '&Version Enhancements Settings'
    TabOrder = 0
    object lblNote: TLabel
      Left = 24
      Top = 106
      Width = 321
      Height = 13
      Caption = 
        '(Note: Options Only Enabled when Include Version Info in Project' +
        '.)'
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
      OnClick = chkIncBuildClick
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
    object chkDateAsVersion: TCheckBox
      Left = 24
      Top = 84
      Width = 321
      Height = 17
      Caption = 'Set Current Year.Month.Day as Major.Minor.Release Version.'
      TabOrder = 3
    end
  end
  object btnOK: TButton
    Left = 157
    Top = 153
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
    Top = 153
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
    Top = 153
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
