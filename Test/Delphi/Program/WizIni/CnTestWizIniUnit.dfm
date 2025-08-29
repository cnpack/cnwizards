object TestWizIniForm: TTestWizIniForm
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'Test CnWizIni'
  ClientHeight = 414
  ClientWidth = 614
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnLoadSetting: TButton
    Left = 32
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Load Setting'
    TabOrder = 0
    OnClick = btnLoadSettingClick
  end
  object grpSettings: TGroupBox
    Left = 32
    Top = 88
    Width = 545
    Height = 289
    Caption = 'Settings'
    TabOrder = 1
    object lblSetting2: TLabel
      Left = 184
      Top = 32
      Width = 78
      Height = 13
      Caption = 'Setting 2 Integer'
    end
    object lblSetting3: TLabel
      Left = 376
      Top = 32
      Width = 72
      Height = 13
      Caption = 'Setting 3 String'
    end
    object lblSetting4: TLabel
      Left = 24
      Top = 112
      Width = 87
      Height = 13
      Caption = 'Setting 4 Datetime'
    end
    object edtSetting2: TEdit
      Left = 184
      Top = 56
      Width = 129
      Height = 21
      TabOrder = 0
      Text = '0'
      OnChange = SyncValues
    end
    object udSetting2: TUpDown
      Left = 313
      Top = 56
      Width = 15
      Height = 21
      Associate = edtSetting2
      Min = -100
      Position = 0
      TabOrder = 1
      Wrap = False
    end
    object edtSetting3: TEdit
      Left = 376
      Top = 56
      Width = 145
      Height = 21
      TabOrder = 2
      OnChange = SyncValues
    end
    object dtpSetting4Date: TDateTimePicker
      Left = 144
      Top = 112
      Width = 153
      Height = 21
      CalAlignment = dtaLeft
      Date = 42425.4240267014
      Time = 42425.4240267014
      DateFormat = dfLong
      DateMode = dmComboBox
      Kind = dtkDate
      ParseInput = False
      TabOrder = 3
      OnChange = SyncValues
    end
    object dtpSetting4Time: TDateTimePicker
      Left = 304
      Top = 112
      Width = 153
      Height = 21
      CalAlignment = dtaLeft
      Date = 42425.4240267014
      Time = 42425.4240267014
      DateFormat = dfShort
      DateMode = dmComboBox
      Kind = dtkTime
      ParseInput = False
      TabOrder = 4
      OnChange = SyncValues
    end
    object chkSetting1: TCheckBox
      Left = 24
      Top = 48
      Width = 113
      Height = 17
      Caption = 'Setting 1 Boolean'
      TabOrder = 5
      OnClick = SyncValues
    end
  end
  object btnSaveSetting: TButton
    Left = 504
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Save Setting'
    TabOrder = 2
    OnClick = btnSaveSettingClick
  end
  object btnDump: TButton
    Left = 256
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Dump Defaults'
    TabOrder = 3
    OnClick = btnDumpClick
  end
end
