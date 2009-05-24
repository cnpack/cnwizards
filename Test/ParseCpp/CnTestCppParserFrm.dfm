object Form1: TForm1
  Left = 192
  Top = 107
  Width = 665
  Height = 545
  Caption = 'Test C/C++ File Token Parsing'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 208
    Top = 24
    Width = 3
    Height = 13
  end
  object btnLoad: TButton
    Left = 16
    Top = 16
    Width = 97
    Height = 25
    Caption = 'Load C/C++ File'
    TabOrder = 0
    OnClick = btnLoadClick
  end
  object mmoC: TMemo
    Left = 16
    Top = 56
    Width = 625
    Height = 201
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      '#include <stdio.h>'
      'void do_some(int a)'
      '{'
      '    printf("Test.\n"); // Test'
      '#define XXXX \'
      '    yyyy'
      '        Move(); {   ;  \'
      '    }'
      '/*'
      'Test Comment'
      '*/ Test();'
      '}')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 2
    OnChange = mmoCChange
    OnClick = mmoCClick
  end
  object btnParse: TButton
    Left = 568
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Parse'
    TabOrder = 1
    OnClick = btnParseClick
  end
  object mmoParse: TMemo
    Left = 16
    Top = 272
    Width = 625
    Height = 225
    TabOrder = 3
  end
  object dlgOpen1: TOpenDialog
    Filter = 'C/C++ Files (*.c;*.cpp;*.h;*.hpp)|*.c;*.cpp;*.h;*.hpp'
    Left = 144
    Top = 16
  end
end
