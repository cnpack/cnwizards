object TestEditorLineInfoForm: TTestEditorLineInfoForm
  Left = 200
  Top = 280
  BorderIcons = [biSystemMenu]
  Caption = 'Test Editor Line Info'
  ClientHeight = 478
  ClientWidth = 482
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lstInfo: TListBox
    Left = 0
    Top = 0
    Width = 482
    Height = 478
    Align = alClient
    ItemHeight = 13
    TabOrder = 0
  end
  object EditorTimer: TTimer
    Enabled = False
    Interval = 1500
    OnTimer = EditorTimerTimer
    Left = 152
    Top = 96
  end
end
