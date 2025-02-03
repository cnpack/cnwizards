object FormCheck: TFormCheck
  Left = 399
  Top = 252
  Width = 495
  Height = 256
  Caption = 'Load and Check CnWizards External Dlls'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblHint: TLabel
    Left = 24
    Top = 16
    Width = 409
    Height = 13
    Caption = 
      'Load and Check CnWizards External Dlls in WIn32 Non-Unicode/Unic' +
      'ode and Win64.'
  end
  object lblError: TLabel
    Left = 128
    Top = 56
    Width = 206
    Height = 13
    Caption = '126: Dll NOT Exists; 193: not Win32 Format'
  end
  object btnLoad: TButton
    Left = 24
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Load Dlls'
    TabOrder = 0
    OnClick = btnLoadClick
  end
  object btnFree: TButton
    Left = 360
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Free Dlls'
    TabOrder = 1
    OnClick = btnFreeClick
  end
end
