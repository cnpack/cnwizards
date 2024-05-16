object FormPasDoc: TFormPasDoc
  Left = 192
  Top = 107
  Width = 979
  Height = 563
  Caption = 'Pascal Document'
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
  object btnExtractFromFile: TButton
    Left = 32
    Top = 24
    Width = 153
    Height = 25
    Caption = 'Open a Pas to Extract'
    TabOrder = 0
    OnClick = btnExtractFromFileClick
  end
  object mmoResult: TMemo
    Left = 216
    Top = 24
    Width = 721
    Height = 481
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object btnCombineInterface: TButton
    Left = 24
    Top = 480
    Width = 177
    Height = 25
    Caption = 'Combine Interface from Directory'
    TabOrder = 2
    OnClick = btnCombineInterfaceClick
  end
  object dlgOpen1: TOpenDialog
    Left = 96
    Top = 80
  end
  object dlgSave1: TSaveDialog
    Left = 96
    Top = 128
  end
end
