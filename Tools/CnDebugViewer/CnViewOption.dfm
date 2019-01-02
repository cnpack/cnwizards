object CnViewerOptionsFrm: TCnViewerOptionsFrm
  Left = 395
  Top = 170
  BorderStyle = bsDialog
  Caption = 'General Settings'
  ClientHeight = 405
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 353
    Top = 370
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 433
    Top = 370
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object grpCapture: TGroupBox
    Left = 8
    Top = 209
    Width = 233
    Height = 154
    Caption = 'Ca&pture Settings'
    TabOrder = 1
    object lblCapOD: TLabel
      Left = 32
      Top = 40
      Width = 156
      Height = 13
      Caption = 'Need to Restart CnDebugViewer'
    end
    object lblPort: TLabel
      Left = 32
      Top = 117
      Width = 47
      Height = 13
      Caption = 'UDP Port:'
    end
    object lblRestart: TLabel
      Left = 32
      Top = 78
      Width = 156
      Height = 13
      Caption = 'Need to Restart CnDebugViewer'
    end
    object chkCapDebug: TCheckBox
      Left = 14
      Top = 21
      Width = 211
      Height = 13
      Caption = 'Capture "Output&DebugString" API'
      TabOrder = 0
      OnClick = chkShowTrayIconClick
    end
    object chkUDPMsg: TCheckBox
      Left = 14
      Top = 96
      Width = 211
      Height = 13
      Caption = 'Capture UD&P Messages'
      TabOrder = 2
      OnClick = chkUDPMsgClick
    end
    object seUDPPort: TSpinEdit
      Left = 128
      Top = 115
      Width = 91
      Height = 22
      MaxValue = 65535
      MinValue = 1
      TabOrder = 3
      Value = 9099
    end
    object chkLocalSession: TCheckBox
      Left = 14
      Top = 59
      Width = 211
      Height = 13
      Caption = 'Use Local S&ession Mode'
      TabOrder = 1
      OnClick = chkShowTrayIconClick
    end
  end
  object grpTrayIcon: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 193
    Caption = '&User Interface Settings'
    TabOrder = 0
    object lblHotKey: TLabel
      Left = 16
      Top = 26
      Width = 81
      Height = 13
      Caption = '&HotKey to Show:'
      FocusControl = hkShowFormHotKey
    end
    object chkCloseToTrayIcon: TCheckBox
      Left = 32
      Top = 108
      Width = 177
      Height = 17
      Caption = 'C&lose to Tray Icon'
      TabOrder = 4
    end
    object chkMinToTrayIcon: TCheckBox
      Left = 32
      Top = 88
      Width = 137
      Height = 17
      Caption = '&Minimize to Tray Icon'
      TabOrder = 3
    end
    object hkShowFormHotKey: THotKey
      Left = 128
      Top = 24
      Width = 91
      Height = 19
      HotKey = 0
      Modifiers = []
      TabOrder = 0
    end
    object chkShowTrayIcon: TCheckBox
      Left = 14
      Top = 68
      Width = 155
      Height = 13
      Caption = 'Show &Tray Icon'
      TabOrder = 2
      OnClick = chkShowTrayIconClick
    end
    object chkMinStart: TCheckBox
      Left = 14
      Top = 48
      Width = 155
      Height = 13
      Caption = 'M&inimize when Startup.'
      TabOrder = 1
      OnClick = chkShowTrayIconClick
    end
    object chkSaveFormPosition: TCheckBox
      Left = 14
      Top = 132
      Width = 155
      Height = 13
      Caption = '&Save Window State/Position'
      TabOrder = 5
      OnClick = chkShowTrayIconClick
    end
    object btnFont: TButton
      Left = 16
      Top = 158
      Width = 201
      Height = 21
      Caption = '&Font'
      TabOrder = 6
      OnClick = btnFontClick
    end
  end
  object grp1: TGroupBox
    Left = 252
    Top = 8
    Width = 256
    Height = 355
    Caption = 'Process Filte&r Settings'
    TabOrder = 4
    object mmoWhiteList: TMemo
      Left = 32
      Top = 216
      Width = 209
      Height = 122
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object mmoBlackList: TMemo
      Left = 32
      Top = 52
      Width = 209
      Height = 122
      ScrollBars = ssBoth
      TabOrder = 1
    end
    object rbWhiteList: TRadioButton
      Left = 16
      Top = 186
      Width = 233
      Height = 17
      Caption = 'Only Show Processes in &White List:'
      TabOrder = 2
    end
    object rbBlackList: TRadioButton
      Left = 16
      Top = 24
      Width = 233
      Height = 17
      Caption = 'Show All Processes Except in &Black List:'
      Checked = True
      TabOrder = 3
      TabStop = True
    end
  end
  object dlgFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 112
    Top = 96
  end
end
