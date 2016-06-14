object CppParseForm: TCppParseForm
  Left = 203
  Top = 70
  Width = 754
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
    Left = 124
    Top = 24
    Width = 3
    Height = 13
  end
  object bvl1: TBevel
    Left = 448
    Top = 16
    Width = 25
    Height = 25
    Shape = bsLeftLine
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
    Width = 713
    Height = 201
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      '#include <stdio.h>'
      '#include "io.h"'
      ''
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
    TabOrder = 4
    OnChange = mmoCChange
    OnClick = mmoCClick
  end
  object btnParse: TButton
    Left = 256
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Ansi Parse'
    TabOrder = 2
    OnClick = btnParseClick
  end
  object mmoParse: TMemo
    Left = 16
    Top = 272
    Width = 713
    Height = 225
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 5
  end
  object btnTokenList: TButton
    Left = 350
    Top = 16
    Width = 83
    Height = 25
    Caption = 'Ansi Tokenize'
    TabOrder = 1
    OnClick = btnTokenListClick
  end
  object btnWideTokenize: TButton
    Left = 462
    Top = 16
    Width = 83
    Height = 25
    Caption = 'Wide Tokenize'
    TabOrder = 3
    OnClick = btnWideTokenizeClick
  end
  object btnInc: TButton
    Left = 646
    Top = 16
    Width = 83
    Height = 25
    Caption = 'Get Includes'
    TabOrder = 6
    OnClick = btnIncClick
  end
  object chkWideIdent: TCheckBox
    Left = 552
    Top = 20
    Width = 81
    Height = 17
    Caption = 'Wide Ident'
    TabOrder = 7
  end
  object dlgOpen1: TOpenDialog
    Filter = 'C/C++ Files (*.c;*.cpp;*.h;*.hpp)|*.c;*.cpp;*.h;*.hpp'
    Left = 144
    Top = 16
  end
end
