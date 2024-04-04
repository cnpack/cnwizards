object FormEvaluate: TFormEvaluate
  Left = 192
  Top = 107
  Caption = 'Evaluate Demo for Debugging'
  ClientHeight = 536
  ClientWidth = 971
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnDataSet: TButton
    Left = 32
    Top = 32
    Width = 75
    Height = 25
    Caption = 'TDataSet'
    TabOrder = 0
    OnClick = btnDataSetClick
  end
  object btnStrings: TButton
    Left = 152
    Top = 32
    Width = 75
    Height = 25
    Caption = 'TStrings'
    TabOrder = 1
    OnClick = btnStringsClick
  end
  object btnArrayOfByte: TButton
    Left = 280
    Top = 32
    Width = 75
    Height = 25
    Caption = 'array of Byte'
    TabOrder = 2
    OnClick = btnArrayOfByteClick
  end
  object btnTBytes: TButton
    Left = 416
    Top = 32
    Width = 193
    Height = 25
    Caption = 'TBytes (2007: array of Byte)'
    TabOrder = 3
    OnClick = btnTBytesClick
  end
  object btnTArrayByte: TButton
    Left = 648
    Top = 32
    Width = 193
    Height = 25
    Caption = 'TBytes (XE: TArray <Byte>)'
    TabOrder = 4
    OnClick = btnTArrayByteClick
  end
  object btnRawByteString: TButton
    Left = 152
    Top = 96
    Width = 137
    Height = 25
    Caption = 'RawByteString'
    TabOrder = 5
    OnClick = btnRawByteStringClick
  end
  object btnAnsiString: TButton
    Left = 376
    Top = 96
    Width = 137
    Height = 25
    Caption = 'AnsiString'
    TabOrder = 6
    OnClick = btnAnsiStringClick
  end
  object btnUnicodeString: TButton
    Left = 32
    Top = 160
    Width = 137
    Height = 25
    Caption = 'UnicodeString'
    TabOrder = 7
    OnClick = btnUnicodeStringClick
  end
  object btnWideString: TButton
    Left = 218
    Top = 160
    Width = 137
    Height = 25
    Caption = 'WideString'
    TabOrder = 8
    OnClick = btnWideStringClick
  end
  object btnString: TButton
    Left = 408
    Top = 160
    Width = 137
    Height = 25
    Caption = 'string in Unicode Compiler'
    TabOrder = 9
    OnClick = btnStringClick
  end
  object ADODataSet1: TADODataSet
    Parameters = <>
    Left = 48
    Top = 80
  end
end
