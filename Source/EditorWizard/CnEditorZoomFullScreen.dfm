object CnEditorZoomFullScreenForm: TCnEditorZoomFullScreenForm
  Left = 464
  Top = 252
  BorderStyle = bsDialog
  Caption = '代码窗口全屏幕切换工具'
  ClientHeight = 131
  ClientWidth = 248
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 89
    Caption = '设置(&S)'
    TabOrder = 0
    object cbAutoZoom: TCheckBox
      Left = 8
      Top = 16
      Width = 217
      Height = 17
      Caption = 'IDE 启动后自动将代码窗口最大化。'
      TabOrder = 0
    end
    object chkAutoHideMainForm: TCheckBox
      Left = 8
      Top = 40
      Width = 217
      Height = 17
      Caption = '代码窗口最大化时自动隐藏主窗口。'
      TabOrder = 1
    end
    object chkRestoreNormal: TCheckBox
      Left = 8
      Top = 64
      Width = 217
      Height = 17
      Caption = '取消全屏时恢复到常规状态。'
      TabOrder = 2
    end
  end
  object btnOK: TButton
    Left = 86
    Top = 104
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 166
    Top = 104
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
end
