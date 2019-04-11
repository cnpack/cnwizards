object FormConvert: TFormConvert
  Left = 0
  Top = 0
  Caption = 'Convert VCL DFM to FMX XFM'
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
    OnClick = btnConvertClick
  end
  object btnConvertTree: TSpeedButton
    Left = 384
    Top = 240
    Width = 23
    Height = 22
    OnClick = btnConvertTreeClick
  end
  object btnSaveCloneTree: TSpeedButton
    Left = 384
    Top = 280
    Width = 23
    Height = 22
    OnClick = btnSaveCloneTreeClick
  end
  object edtDfmFile: TEdit
    Left = 74
    Top = 29
    Width = 543
    Height = 21
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 640
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
    Lines.Strings = (
      'object Form1: TForm1'
      '  Left = 34'
      '  Top = 100'
      '  HelpContext = 34234'
      '  VertScrollBar.Color = 10667716'
      '  VertScrollBar.ParentColor = False'
      '  Caption = #21507#39277#21917#27700'
      '  ClientHeight = 377'
      '  ClientWidth = 663'
      '  Color = clInfoBk'
      '  Font.Charset = DEFAULT_CHARSET'
      '  Font.Color = clWindowText'
      '  Font.Height = -11'
      '  Font.Name = '#39'Tahoma'#39
      '  Font.Style = []'
      '  FormStyle = fsMDIChild'
      '  KeyPreview = True'
      '  OldCreateOrder = False'
      '  Position = poDefault'
      '  Visible = True'
      '  StyleElements = [seFont, seBorder]'
      '  OnCreate = FormCreate'
      '  PixelsPerInch = 96'
      '  TextHeight = 13'
      'end')
    TabOrder = 2
  end
  object mmoEventIntf: TMemo
    Left = 413
    Top = 240
    Width = 374
    Height = 89
    TabOrder = 3
  end
  object mmoEventImpl: TMemo
    Left = 413
    Top = 344
    Width = 374
    Height = 89
    TabOrder = 4
  end
  object mmoFMX: TMemo
    Left = 413
    Top = 64
    Width = 374
    Height = 145
    TabOrder = 5
  end
  object tvDfm: TTreeView
    Left = 24
    Top = 240
    Width = 354
    Height = 193
    Indent = 19
    TabOrder = 6
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
