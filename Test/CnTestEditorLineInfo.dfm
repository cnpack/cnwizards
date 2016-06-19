object TestEditorLineInfoForm: TTestEditorLineInfoForm
  Left = 281
  Top = 165
  BorderStyle = bsDialog
  Caption = 'Test Editor Line Info'
  ClientHeight = 336
  ClientWidth = 523
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
    Left = 16
    Top = 16
    Width = 489
    Height = 297
    ItemHeight = 13
    TabOrder = 0
  end
  object EditorTimer: TTimer
    Interval = 1500
    OnTimer = EditorTimerTimer
    Left = 152
    Top = 96
  end
end
