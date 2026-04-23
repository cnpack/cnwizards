inherited CnVerEnhanceForm: TCnVerEnhanceForm
  Left = 437
  Top = 220
  BorderStyle = bsDialog
  Caption = 'Version Enhancements Settings'
  ClientHeight = 250
  ClientWidth = 403
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grpVerEnh: TGroupBox
    Left = 8
    Top = 8
    Width = 387
    Height = 203
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '&Version Enhancements Settings'
    TabOrder = 0
    object lblNote: TLabel
      Left = 24
      Top = 168
      Width = 353
      Height = 13
      AutoSize = False
      Caption = 
        '(Note: Options Only Enabled when Include Version Info in Project' +
        '.)'
    end
    object lblFormat: TLabel
      Left = 24
      Top = 46
      Width = 63
      Height = 13
      Caption = 'Time Format:'
    end
    object lblRadix: TLabel
      Left = 24
      Top = 118
      Width = 81
      Height = 13
      AutoSize = False
      Caption = 'Radix:'
    end
    object chkLastCompiled: TCheckBox
      Left = 8
      Top = 20
      Width = 377
      Height = 17
      Caption = 'Insert Compiling Time into Version Info(Delphi 6 Above Only).'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = UpdateControl
    end
    object chkIncBuild: TCheckBox
      Left = 8
      Top = 68
      Width = 377
      Height = 19
      Caption = 'Auto-increment Build Number when Compiling(Delphi 6 Above Only).'
      TabOrder = 2
      OnClick = UpdateControl
    end
    object cbbFormat: TComboBox
      Left = 112
      Top = 44
      Width = 201
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        'yyyy/mm/dd hh:mm:ss'
        'yyyy-mm-dd hh:mm:ss'
        'yyyy-mm-dd_hh-mm-ss')
    end
    object chkDateAsVersion: TCheckBox
      Left = 24
      Top = 144
      Width = 353
      Height = 17
      Caption = 'Set Current Year.Month.Day as Major.Minor.Release Version.'
      TabOrder = 5
    end
    object chkBuildCarry: TCheckBox
      Left = 24
      Top = 92
      Width = 353
      Height = 17
      Caption = 'Build Number increments can Carry Over to the Release Number.'
      TabOrder = 3
      OnClick = UpdateControl
    end
    object cbbBuildCarryType: TComboBox
      Left = 112
      Top = 116
      Width = 201
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 4
      Items.Strings = (
        'Carry when 10'
        'Carry when 100'
        'Carry when 1000'
        'Carry when 10000')
    end
  end
  object btnOK: TButton
    Left = 157
    Top = 221
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
    Top = 221
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
    Top = 221
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
