object ParseForm: TParseForm
  Left = 385
  Top = 147
  BorderStyle = bsDialog
  Caption = 'DFM Parser Test'
  ClientHeight = 726
  ClientWidth = 522
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object lblForm: TLabel
    Left = 30
    Top = 30
    Width = 225
    Height = 16
    Caption = 'Form File (dfm/xfm/fmx Binary or Text):'
  end
  object Bevel1: TBevel
    Left = 30
    Top = 167
    Width = 464
    Height = 23
    Shape = bsBottomLine
  end
  object edtFile: TEdit
    Left = 30
    Top = 79
    Width = 345
    Height = 24
    TabOrder = 0
  end
  object btnParse: TButton
    Left = 30
    Top = 128
    Width = 464
    Height = 31
    Caption = 'Parse'
    TabOrder = 1
    OnClick = btnParseClick
  end
  object btnBrowse: TButton
    Left = 404
    Top = 79
    Width = 92
    Height = 31
    Caption = 'Browse'
    TabOrder = 2
    OnClick = btnBrowseClick
  end
  object tvDfm: TTreeView
    Left = 30
    Top = 217
    Width = 464
    Height = 473
    Indent = 19
    TabOrder = 3
    OnDblClick = tvDfmDblClick
  end
  object dlgOpen: TOpenDialog
    Left = 256
    Top = 24
  end
end
