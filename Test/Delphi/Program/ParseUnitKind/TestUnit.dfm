object FormParse: TFormParse
  Left = 401
  Top = 237
  BorderStyle = bsDialog
  Caption = 'Test for TCnUsesCleaner.ParseUnitKind'
  ClientHeight = 133
  ClientWidth = 448
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
  object lblFileName: TLabel
    Left = 16
    Top = 24
    Width = 22
    Height = 13
    Caption = 'File: '
  end
  object edtFile: TEdit
    Left = 56
    Top = 24
    Width = 265
    Height = 21
    TabOrder = 0
  end
  object btnOpen: TButton
    Left = 344
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 1
    OnClick = btnOpenClick
  end
  object btnParse: TButton
    Left = 56
    Top = 72
    Width = 265
    Height = 25
    Caption = 'Parse Unit'
    TabOrder = 2
    OnClick = btnParseClick
  end
  object dlgOpen: TOpenDialog
    Filter = 'Pascal File|*.pas|All Files|*.*'
    Left = 256
    Top = 24
  end
end
