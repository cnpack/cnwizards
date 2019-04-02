object ParseForm: TParseForm
  Left = 385
  Top = 147
  BorderStyle = bsDialog
  Caption = 'DFM Parser Test'
  ClientHeight = 590
  ClientWidth = 424
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblForm: TLabel
    Left = 24
    Top = 24
    Width = 181
    Height = 13
    Caption = 'Form File (dfm/xfm/fmx Binary or Text):'
  end
  object Bevel1: TBevel
    Left = 24
    Top = 136
    Width = 377
    Height = 18
    Shape = bsBottomLine
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
    Width = 217
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
  object tvDfm: TTreeView
    Left = 24
    Top = 176
    Width = 377
    Height = 385
    Indent = 19
    TabOrder = 3
    OnDblClick = tvDfmDblClick
  end
  object btnClone: TButton
    Left = 248
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Clone'
    TabOrder = 4
    OnClick = btnCloneClick
  end
  object btnSave: TButton
    Left = 328
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 5
    OnClick = btnSaveClick
  end
  object dlgOpen: TOpenDialog
    Left = 256
    Top = 24
  end
  object dlgSave1: TSaveDialog
    Left = 328
    Top = 24
  end
end
