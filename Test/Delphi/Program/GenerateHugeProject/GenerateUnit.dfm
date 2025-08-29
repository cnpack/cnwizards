object GenerateForm: TGenerateForm
  Left = 301
  Top = 239
  BorderStyle = bsDialog
  Caption = 'Generate a Huge Project with Units/Forms for Testing UsesCleaner'
  ClientHeight = 98
  ClientWidth = 537
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
  object lblUnitCount: TLabel
    Left = 16
    Top = 20
    Width = 53
    Height = 13
    Caption = 'Unit Count:'
  end
  object lblProject: TLabel
    Left = 176
    Top = 20
    Width = 89
    Height = 13
    Caption = 'Project Path&Name:'
  end
  object edtUnitCount: TEdit
    Left = 80
    Top = 16
    Width = 65
    Height = 21
    TabOrder = 0
    Text = '100'
  end
  object udUnitCount: TUpDown
    Left = 145
    Top = 16
    Width = 15
    Height = 21
    Associate = edtUnitCount
    Min = 1
    Max = 30000
    Position = 100
    TabOrder = 1
    Wrap = False
  end
  object btnGenerate: TButton
    Left = 16
    Top = 56
    Width = 505
    Height = 25
    Caption = 'Generate'
    TabOrder = 2
    OnClick = btnGenerateClick
  end
  object edtProject: TEdit
    Left = 272
    Top = 16
    Width = 161
    Height = 21
    TabOrder = 3
  end
  object btnBrowse: TButton
    Left = 448
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 4
    OnClick = btnBrowseClick
  end
  object dlgSave: TSaveDialog
    DefaultExt = '*.dpr'
    FileName = 'HugeProject.dpr'
    Left = 256
    Top = 32
  end
end
