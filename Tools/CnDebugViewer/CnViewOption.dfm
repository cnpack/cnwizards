object CnViewerOptionsFrm: TCnViewerOptionsFrm
  Left = 370
  Top = 239
  BorderStyle = bsDialog
  Caption = 'General Settings'
  ClientHeight = 295
  ClientWidth = 249
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
    Left = 85
    Top = 263
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 165
    Top = 263
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object grpTrayIcon: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 160
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
      InvalidKeys = [hcNone, hcShift]
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
  end
  object grpCapture: TGroupBox
    Left = 8
    Top = 181
    Width = 233
    Height = 73
    Caption = 'Ca&pture Settings'
    TabOrder = 1
    object lblCapOD: TLabel
      Left = 32
      Top = 40
      Width = 156
      Height = 13
      Caption = 'Need to Restart CnDebugViewer'
    end
    object chkCapDebug: TCheckBox
      Left = 14
      Top = 23
      Width = 211
      Height = 13
      Caption = 'Capture "Output&DebugString" API'
      TabOrder = 0
      OnClick = chkShowTrayIconClick
    end
  end
end
