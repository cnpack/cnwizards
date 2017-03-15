object FormTestPng: TFormTestPng
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Test PNG Conversion under D2010 or above'
  ClientHeight = 160
  ClientWidth = 568
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpPng2Bmp: TGroupBox
    Left = 16
    Top = 11
    Width = 529
    Height = 126
    Caption = 'Png To Bmp'
    TabOrder = 0
    object lblPng: TLabel
      Left = 24
      Top = 27
      Width = 22
      Height = 13
      Caption = 'Png:'
    end
    object lblBmp: TLabel
      Left = 24
      Top = 80
      Width = 24
      Height = 13
      Caption = 'Bmp:'
    end
    object edtPng: TEdit
      Left = 64
      Top = 24
      Width = 257
      Height = 21
      TabOrder = 0
    end
    object edtBmp: TEdit
      Left = 64
      Top = 77
      Width = 257
      Height = 21
      TabOrder = 1
    end
    object btnToBmp: TButton
      Left = 432
      Top = 22
      Width = 75
      Height = 25
      Caption = 'To Bmp'
      TabOrder = 2
      OnClick = btnToBmpClick
    end
    object btnBrowsePng: TButton
      Left = 336
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 3
      OnClick = btnBrowsePngClick
    end
    object btnBrowseBmp: TButton
      Left = 336
      Top = 75
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 4
      OnClick = btnBrowseBmpClick
    end
    object btnToPng: TButton
      Left = 432
      Top = 75
      Width = 75
      Height = 25
      Caption = 'To Png'
      TabOrder = 5
      OnClick = btnToPngClick
    end
  end
  object dlgOpen: TOpenDialog
    Left = 152
    Top = 56
  end
  object dlgSave: TSaveDialog
    Left = 216
    Top = 56
  end
end
