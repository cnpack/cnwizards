object TestAnsiUniForm: TTestAnsiUniForm
  Left = 216
  Top = 204
  BorderStyle = bsDialog
  Caption = 'Test Ansi / Unicode String Length Conversion'
  ClientHeight = 230
  ClientWidth = 646
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
  object lblFrom: TLabel
    Left = 400
    Top = 96
    Width = 57
    Height = 13
    Caption = 'From Offset:'
  end
  object bvl1: TBevel
    Left = 400
    Top = 72
    Width = 217
    Height = 9
    Shape = bsTopLine
  end
  object mmoStr: TMemo
    Left = 24
    Top = 24
    Width = 345
    Height = 177
    Lines.Strings = (
      '1234567890'
      '吃饭睡觉打豆豆'
      'abcd看不见了efgh')
    TabOrder = 0
  end
  object btnLength: TButton
    Left = 400
    Top = 24
    Width = 217
    Height = 25
    Caption = 'Ansi Length'
    TabOrder = 1
    OnClick = btnLengthClick
  end
  object edtOffset: TEdit
    Left = 480
    Top = 92
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '5'
  end
  object udOffset: TUpDown
    Left = 601
    Top = 92
    Width = 15
    Height = 21
    Associate = edtOffset
    Min = 0
    Position = 5
    TabOrder = 3
    Wrap = False
  end
  object btnCalcAnsi: TButton
    Left = 400
    Top = 128
    Width = 217
    Height = 25
    Caption = 'Calc Ansi Offset from  Wide'
    TabOrder = 4
    OnClick = btnCalcAnsiClick
  end
  object btnCalcWide: TButton
    Left = 400
    Top = 176
    Width = 217
    Height = 25
    Caption = 'Calc Wide Offset from  Ansi'
    TabOrder = 5
    OnClick = btnCalcWideClick
  end
end
