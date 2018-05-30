object ParseForm: TParseForm
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'DFM Parser Test'
  ClientHeight = 157
  ClientWidth = 424
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
  object lblForm: TLabel
    Left = 24
    Top = 24
    Width = 181
    Height = 13
    Caption = 'Form File (dfm/xfm/fmx Binary or Text):'
  end
  object edtFile: TEdit
    Left = 24
    Top = 64
    Width = 281
    Height = 21
    TabOrder = 0
  end
  object btnParse: TButton
    Left = 24
    Top = 104
    Width = 377
    Height = 25
    Caption = 'Parse'
    TabOrder = 1
    OnClick = btnParseClick
  end
  object btnBrowse: TButton
    Left = 328
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 2
    OnClick = btnBrowseClick
  end
  object dlgOpen: TOpenDialog
    Left = 256
    Top = 24
  end
end
