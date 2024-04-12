object TestCaptionButtonForm: TTestCaptionButtonForm
  Left = 346
  Top = 260
  Width = 577
  Height = 246
  Caption = 'Test Caption Button for 32/64 Unicode/Non-Unicode'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  ShowHint = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 96
    Top = 88
    Width = 362
    Height = 13
    Hint = 'Test Hint'
    Caption = 
      'The Caption Buttons should Display Correctly under Windows 7 Aer' +
      'o Theme.'
  end
end
