object FormConvert: TFormConvert
  Left = 0
  Top = 0
  Caption = 'Convert VCL DFM to FMX -- XE4 or above'
  ClientHeight = 480
  ClientWidth = 809
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Touch.ParentTabletOptions = False
  Touch.TabletOptions = [toPressAndHold]
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 24
    Top = 32
    Width = 44
    Height = 13
    Caption = 'DFM File:'
  end
  object btnConvert: TSpeedButton
    Left = 384
    Top = 64
    Width = 23
    Height = 22
    Visible = False
  end
  object btnConvertTree: TSpeedButton
    Left = 384
    Top = 152
    Width = 23
    Height = 22
    Caption = '->'
    OnClick = btnConvertTreeClick
  end
  object btnSaveCloneTree: TSpeedButton
    Left = 384
    Top = 215
    Width = 23
    Height = 22
    Caption = 'S'
    OnClick = btnSaveCloneTreeClick
  end
  object edtDfmFile: TEdit
    Left = 74
    Top = 29
    Width = 623
    Height = 21
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 712
    Top = 27
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object mmoDfm: TMemo
    Left = 24
    Top = 64
    Width = 354
    Height = 145
    TabOrder = 2
  end
  object mmoEventIntf: TMemo
    Left = 413
    Top = 64
    Width = 374
    Height = 249
    TabOrder = 3
  end
  object mmoEventImpl: TMemo
    Left = 413
    Top = 328
    Width = 374
    Height = 105
    TabOrder = 4
  end
  object tvDfm: TTreeView
    Left = 24
    Top = 240
    Width = 354
    Height = 193
    Indent = 19
    TabOrder = 5
    OnDblClick = tvDfmDblClick
  end
  object dlgOpen: TOpenDialog
    Left = 312
    Top = 16
  end
  object dlgSave: TSaveDialog
    Left = 384
    Top = 184
  end
end
