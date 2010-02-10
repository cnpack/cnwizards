inherited CnEditorZoomFullScreenForm: TCnEditorZoomFullScreenForm
  Left = 464
  Top = 252
  BorderStyle = bsDialog
  Caption = 'Editor Fullscreen Switch'
  ClientHeight = 131
  ClientWidth = 248
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 89
    Caption = '&Settings'
    TabOrder = 0
    object cbAutoZoom: TCheckBox
      Left = 8
      Top = 16
      Width = 217
      Height = 17
      Caption = 'Maximized when IDE Start.'
      TabOrder = 0
    end
    object chkAutoHideMainForm: TCheckBox
      Left = 8
      Top = 40
      Width = 217
      Height = 17
      Caption = 'Auto Hide/Show Main Form.'
      TabOrder = 1
    end
    object chkRestoreNormal: TCheckBox
      Left = 8
      Top = 64
      Width = 217
      Height = 17
      Caption = 'Restore to Normal when Close Fullscreen.'
      TabOrder = 2
    end
  end
  object btnOK: TButton
    Left = 86
    Top = 104
    Width = 75
    Height = 21
    Caption = '&OK'
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
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
