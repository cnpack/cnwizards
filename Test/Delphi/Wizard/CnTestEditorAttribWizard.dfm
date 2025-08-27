object CnTestEditorFontColorsForm: TCnTestEditorFontColorsForm
  Left = 701
  Top = 198
  BorderStyle = bsDialog
  Caption = 'CnTestEditorFontColorsForm'
  ClientHeight = 417
  ClientWidth = 486
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
  object shpFore: TShape
    Left = 168
    Top = 360
    Width = 25
    Height = 25
  end
  object shpBack: TShape
    Left = 384
    Top = 360
    Width = 25
    Height = 25
  end
  object lblFore: TLabel
    Left = 64
    Top = 364
    Width = 84
    Height = 13
    Caption = 'Foreground Color:'
  end
  object lblBack: TLabel
    Left = 272
    Top = 364
    Width = 88
    Height = 13
    Caption = 'Background Color:'
  end
  object btnRefresh: TSpeedButton
    Left = 456
    Top = 384
    Width = 23
    Height = 22
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000000000000000000000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FF3184ADADCEE7FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF84BDFF107BADADD6E7FF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FF7BCEFF7B7BEF1073A5ADCEE7FF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF63CEEF73DEFF7B7BEF10
      6B9CADCED6FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FF5ACEEF73DEFF7B7BEF186394ADC6D6FF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF4A8CAD427B94426B7B4A7B8C73
      DEFF7B7BEF215273ADCEDEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FF4AC6EF7BEFFF7BEFFF8CCEFF84BDFF739CF77B7BEF294263FF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF4AC6EFDEF7FF63C6FF7B
      7BEF39849CB5CED6FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FF31BDE79CEFFF73D6FF73ADF77B7BEF39738CADC6D6FF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF4AC6EFC6F7FF73
      D6FF73A5F77B7BEF39636BADCEDEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FF4AC6EF9CEFFF7BEFFF7BC6FF73A5F77B7BEF42525AADC6
      D6FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7BC6DE73
      CEE773C6E773BDDE6BADCE5A94B5ADCED6FF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
    OnClick = btnRefreshClick
  end
  object mmo0: TMemo
    Left = 24
    Top = 24
    Width = 201
    Height = 49
    BorderStyle = bsNone
    Lines.Strings = (
      '字体：Basic')
    ReadOnly = True
    TabOrder = 0
  end
  object mmo1: TMemo
    Left = 24
    Top = 88
    Width = 201
    Height = 49
    BorderStyle = bsNone
    Lines.Strings = (
      '字体：Assembler')
    ReadOnly = True
    TabOrder = 1
  end
  object mmo2: TMemo
    Left = 24
    Top = 152
    Width = 201
    Height = 49
    BorderStyle = bsNone
    Lines.Strings = (
      '字体：Comment')
    ReadOnly = True
    TabOrder = 2
  end
  object mmo3: TMemo
    Left = 24
    Top = 216
    Width = 201
    Height = 49
    BorderStyle = bsNone
    Lines.Strings = (
      '字体：Directive')
    ReadOnly = True
    TabOrder = 3
  end
  object mmo4: TMemo
    Left = 24
    Top = 280
    Width = 201
    Height = 49
    BorderStyle = bsNone
    Lines.Strings = (
      '字体：Identifier')
    ReadOnly = True
    TabOrder = 4
  end
  object mmo5: TMemo
    Left = 256
    Top = 24
    Width = 201
    Height = 49
    BorderStyle = bsNone
    Lines.Strings = (
      '字体：Keyword')
    ReadOnly = True
    TabOrder = 5
  end
  object mmo6: TMemo
    Left = 256
    Top = 88
    Width = 201
    Height = 49
    BorderStyle = bsNone
    Lines.Strings = (
      '字体：Number')
    ReadOnly = True
    TabOrder = 6
  end
  object mmo7: TMemo
    Left = 256
    Top = 152
    Width = 201
    Height = 49
    BorderStyle = bsNone
    Lines.Strings = (
      '字体：Space')
    ReadOnly = True
    TabOrder = 7
  end
  object mmo8: TMemo
    Left = 256
    Top = 216
    Width = 201
    Height = 49
    BorderStyle = bsNone
    Lines.Strings = (
      '字体：String')
    ReadOnly = True
    TabOrder = 8
  end
  object mmo9: TMemo
    Left = 256
    Top = 280
    Width = 201
    Height = 49
    BorderStyle = bsNone
    Lines.Strings = (
      '字体：Symbol')
    ReadOnly = True
    TabOrder = 9
  end
end
