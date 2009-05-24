object CnViewerOptionsFrm: TCnViewerOptionsFrm
  Left = 370
  Top = 239
  BorderStyle = bsDialog
  Caption = '常规选项设置'
  ClientHeight = 295
  ClientWidth = 249
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '宋体'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object btnOK: TButton
    Left = 85
    Top = 263
    Width = 75
    Height = 21
    Caption = '确定(&O)'
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
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object grpTrayIcon: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 160
    Caption = '界面设置(&U)'
    TabOrder = 0
    object lblHotKey: TLabel
      Left = 16
      Top = 26
      Width = 114
      Height = 12
      Caption = '主窗口显示热键(&H)：'
      FocusControl = hkShowFormHotKey
    end
    object chkCloseToTrayIcon: TCheckBox
      Left = 32
      Top = 108
      Width = 177
      Height = 17
      Caption = '关闭时最小化到系统托盘(&L)'
      TabOrder = 4
    end
    object chkMinToTrayIcon: TCheckBox
      Left = 32
      Top = 88
      Width = 137
      Height = 17
      Caption = '最小化到系统托盘(&M)'
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
      Caption = '显示系统托盘图标(&T)'
      TabOrder = 2
      OnClick = chkShowTrayIconClick
    end
    object chkMinStart: TCheckBox
      Left = 14
      Top = 48
      Width = 155
      Height = 13
      Caption = '启动时最小化(&I)'
      TabOrder = 1
      OnClick = chkShowTrayIconClick
    end
    object chkSaveFormPosition: TCheckBox
      Left = 14
      Top = 132
      Width = 155
      Height = 13
      Caption = '保存窗口状态及位置(&S)'
      TabOrder = 5
      OnClick = chkShowTrayIconClick
    end
  end
  object grpCapture: TGroupBox
    Left = 8
    Top = 181
    Width = 233
    Height = 73
    Caption = '捕获设置(&P)'
    TabOrder = 1
    object lblCapOD: TLabel
      Left = 32
      Top = 40
      Width = 180
      Height = 12
      Caption = '（需要重新启动 CnDebugViewer）'
    end
    object chkCapDebug: TCheckBox
      Left = 14
      Top = 23
      Width = 211
      Height = 13
      Caption = '捕获 OutputDebugString 的输出(&D)'
      TabOrder = 0
      OnClick = chkShowTrayIconClick
    end
  end
end
