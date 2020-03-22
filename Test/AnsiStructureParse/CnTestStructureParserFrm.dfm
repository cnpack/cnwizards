object CnTestStructureForm: TCnTestStructureForm
  Left = 156
  Top = 126
  Width = 973
  Height = 648
  Caption = 'Test Pascal/C++ Unit Structure and Token Parsing'
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
  object pgc1: TPageControl
    Left = 16
    Top = 16
    Width = 929
    Height = 585
    ActivePage = tsPascal
    TabOrder = 0
    object tsPascal: TTabSheet
      Caption = 'Pascal'
      object lblPasPos: TLabel
        Left = 136
        Top = 24
        Width = 3
        Height = 13
      end
      object bvl1: TBevel
        Left = 552
        Top = 16
        Width = 17
        Height = 25
        Shape = bsLeftLine
      end
      object btnLoadPas: TButton
        Left = 16
        Top = 16
        Width = 97
        Height = 25
        Caption = 'Load Pascal Unit'
        TabOrder = 0
        OnClick = btnLoadPasClick
      end
      object mmoPas: TMemo
        Left = 16
        Top = 56
        Width = 881
        Height = 201
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'unit a;'
          'interface'
          'implementation'
          ''
          'procedure TForm2;'
          'begin'
          '  try'
          '    C := procedure(const aStr : string)'
          '         begin'
          '           ;'
          '         end;'
          ''
          '    Conditions.ForEach(procedure(const C: ICondition)'
          '                       begin'
          ''
          '                       end);'
          '    Result := 0;'
          '  finally'
          '    Free;'
          '  end;'
          ''
          '  AddEvent('
          '    procedure'
          '    begin'
          '      CreateAnonymousThreadX('
          '        procedure(aData: Pointer)'
          '        begin'
          '          aSysOptionArr := TSystemInfoArr.Create;'
          '          try'
          '            aThread.SetSyncPro('
          '              procedure()'
          ''
          '                procedure'
          '                begin'
          ''
          '                end;'
          ''
          ''
          '              begin'
          ''
          '              end);'
          '          finally'
          '            aSysOptionArr.Free;'
          '          end;'
          '        end);'
          '    end);'
          'end;'
          'end.')
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 1
        OnChange = mmoPasChange
        OnClick = mmoPasChange
      end
      object btnParsePas: TButton
        Left = 480
        Top = 16
        Width = 67
        Height = 25
        Caption = 'Ansi Parse'
        TabOrder = 2
        OnClick = btnParsePasClick
      end
      object mmoParsePas: TMemo
        Left = 16
        Top = 272
        Width = 881
        Height = 268
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 3
        WordWrap = False
      end
      object btnUses: TButton
        Left = 408
        Top = 16
        Width = 67
        Height = 25
        Caption = 'Get Uses'
        TabOrder = 4
        OnClick = btnUsesClick
      end
      object btnWideParse: TButton
        Left = 632
        Top = 16
        Width = 67
        Height = 25
        Caption = 'Wide Lex'
        TabOrder = 5
        OnClick = btnWideParseClick
      end
      object btnAnsiLex: TButton
        Left = 560
        Top = 16
        Width = 67
        Height = 25
        Caption = 'Ansi Lex'
        TabOrder = 6
        OnClick = btnAnsiLexClick
      end
      object chkWideIdentPas: TCheckBox
        Left = 708
        Top = 20
        Width = 77
        Height = 17
        Caption = 'Wide Ident'
        TabOrder = 7
      end
      object btnPasPosInfo: TButton
        Left = 832
        Top = 16
        Width = 65
        Height = 25
        Caption = 'PosInfo'
        TabOrder = 8
        OnClick = btnPasPosInfoClick
      end
    end
    object tsCpp: TTabSheet
      Caption = 'C/C++'
      ImageIndex = 1
      object lblCppPos: TLabel
        Left = 124
        Top = 24
        Width = 3
        Height = 13
      end
      object Bevel1: TBevel
        Left = 616
        Top = 16
        Width = 25
        Height = 25
        Shape = bsLeftLine
      end
      object btnLoadCpp: TButton
        Left = 16
        Top = 16
        Width = 97
        Height = 25
        Caption = 'Load C/C++ File'
        TabOrder = 0
        OnClick = btnLoadCppClick
      end
      object mmoC: TMemo
        Left = 16
        Top = 56
        Width = 881
        Height = 201
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
        TabOrder = 1
        OnChange = mmoPasChange
        OnClick = mmoPasChange
      end
      object btnParseCpp: TButton
        Left = 440
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Ansi Parse'
        TabOrder = 2
        OnClick = btnParseCppClick
      end
      object mmoParseCpp: TMemo
        Left = 16
        Top = 272
        Width = 881
        Height = 265
        ScrollBars = ssVertical
        TabOrder = 3
      end
      object btnTokenList: TButton
        Left = 526
        Top = 16
        Width = 83
        Height = 25
        Caption = 'Ansi Tokenize'
        TabOrder = 4
        OnClick = btnTokenListClick
      end
      object btnWideTokenize: TButton
        Left = 622
        Top = 16
        Width = 83
        Height = 25
        Caption = 'Wide Tokenize'
        TabOrder = 5
        OnClick = btnWideTokenizeClick
      end
      object btnInc: TButton
        Left = 806
        Top = 16
        Width = 83
        Height = 25
        Caption = 'Get Includes'
        TabOrder = 6
        OnClick = btnIncClick
      end
      object chkWideIdentCpp: TCheckBox
        Left = 712
        Top = 20
        Width = 81
        Height = 17
        Caption = 'Wide Ident'
        TabOrder = 7
      end
    end
  end
  object dlgOpen1: TOpenDialog
    Filter = 
      'Pascal Files(*.pas)|*.pas|C/C++ Files(*.c;*.h;*.hpp;*.cpp)|*.c;*' +
      '.cpp;*.h;*.hpp|All Files(*.*)|*.*'
    Left = 144
    Top = 16
  end
  object OpenDialog1: TOpenDialog
    Filter = 'C/C++ Files (*.c;*.cpp;*.h;*.hpp)|*.c;*.cpp;*.h;*.hpp'
    Left = 144
    Top = 16
  end
end
