object FormTestPng: TFormTestPng
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Test PNG Conversion under D2010 or above'
  ClientHeight = 324
  ClientWidth = 657
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
    Width = 625
    Height = 126
    Caption = 'Png To Bmp using DLL'
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
  object grpPng: TGroupBox
    Left = 16
    Top = 152
    Width = 625
    Height = 145
    Caption = 'Png to Bmp using PngImage Unit'
    TabOrder = 1
    object lblPng1: TLabel
      Left = 24
      Top = 27
      Width = 22
      Height = 13
      Caption = 'Png:'
    end
    object lblPngInfo: TLabel
      Left = 64
      Top = 64
      Width = 536
      Height = 13
      AutoSize = False
    end
    object edtPng1: TEdit
      Left = 64
      Top = 24
      Width = 257
      Height = 21
      TabOrder = 0
      OnChange = edtPng1Change
    end
    object btnBrowsePng1: TButton
      Left = 336
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 1
      OnClick = btnBrowsePng1Click
    end
    object btnToBmp1: TButton
      Left = 432
      Top = 22
      Width = 75
      Height = 25
      Caption = 'To Bmp Assign'
      TabOrder = 2
      OnClick = btnToBmp1Click
    end
    object btnToBmp2: TButton
      Left = 528
      Top = 22
      Width = 75
      Height = 25
      Caption = 'To Bmp Draw'
      TabOrder = 3
      OnClick = btnToBmp2Click
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
