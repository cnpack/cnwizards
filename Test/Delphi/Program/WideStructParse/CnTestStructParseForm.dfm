object TeststructParseForm: TTeststructParseForm
  Left = 197
  Top = 108
  Width = 910
  Height = 595
  Caption = 
    'Test Unicode Structure Parse - Should Run OK under Non-Unicode a' +
    'nd Unicode  Compiler. D7/2009.'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 884
    Height = 552
    ActivePage = tsPascal
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsPascal: TTabSheet
      Caption = 'Pascal'
      object lblPascal: TLabel
        Left = 139
        Top = 181
        Width = 181
        Height = 13
        AutoSize = False
        Caption = 'Line: Col:'
      end
      object mmoPasSrc: TMemo
        Left = 7
        Top = 7
        Width = 857
        Height = 158
        Anchors = [akLeft, akTop, akRight]
        Lines.Strings = (
          'unit Unit1;'
          ''
          'interface'
          ''
          'uses'
          
            '  Windows, Messages, SysUtils, Classes, Graphics, Controls, Form' +
            's, Dialogs;'
          ''
          'type'
          '  TForm1 = class(TForm)'
          '    procedure FormCreate(Sender: TObject);'
          '  private'
          '    { Private declarations }'
          '  public'
          '    { Public declarations }'
          '  end;'
          ''
          'var'
          '  Form1: TForm1;'
          ''
          'implementation'
          ''
          '{$R *.DFM}'
          ''
          'procedure TForm1.FormCreate(Sender: TObject);'
          'begin'
          ''
          'end;'
          ''
          'end.')
        ScrollBars = ssVertical
        TabOrder = 0
        OnChange = mmoPasSrcChange
        OnClick = mmoPasSrcClick
      end
      object btnParsePas: TButton
        Left = 56
        Top = 176
        Width = 73
        Height = 25
        Caption = 'Parse'
        TabOrder = 2
        OnClick = btnParsePasClick
      end
      object mmoPasResult: TMemo
        Left = 7
        Top = 210
        Width = 857
        Height = 302
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssVertical
        TabOrder = 7
      end
      object btnGetUses: TButton
        Left = 416
        Top = 176
        Width = 75
        Height = 25
        Caption = 'Get Uses'
        TabOrder = 4
        OnClick = btnGetUsesClick
      end
      object chkWidePas: TCheckBox
        Left = 536
        Top = 183
        Width = 97
        Height = 17
        Caption = 'Wide Identifier'
        Checked = True
        State = cbChecked
        TabOrder = 6
      end
      object btnPosInfoW: TButton
        Left = 664
        Top = 176
        Width = 75
        Height = 25
        Caption = 'PosInfoW'
        TabOrder = 5
        OnClick = btnPosInfoWClick
      end
      object btnOpenPas: TButton
        Left = 8
        Top = 176
        Width = 41
        Height = 25
        Caption = 'Open'
        TabOrder = 1
        OnClick = btnOpenPasClick
      end
      object btnPair: TButton
        Left = 328
        Top = 176
        Width = 73
        Height = 25
        Caption = 'Pair'
        TabOrder = 3
        OnClick = btnPairClick
      end
    end
    object tsCpp: TTabSheet
      Caption = 'C/C++'
      ImageIndex = 1
      object lblCpp: TLabel
        Left = 152
        Top = 184
        Width = 185
        Height = 13
        AutoSize = False
        Caption = 'Line: Col:'
      end
      object mmoCppSrc: TMemo
        Left = 7
        Top = 7
        Width = 857
        Height = 158
        Anchors = [akLeft, akTop, akRight]
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
        ScrollBars = ssVertical
        TabOrder = 0
        OnChange = mmoCppSrcChange
        OnClick = mmoCppSrcClick
      end
      object btnParseCpp: TButton
        Left = 56
        Top = 176
        Width = 73
        Height = 25
        Caption = 'Parse'
        TabOrder = 2
        OnClick = btnParseCppClick
      end
      object mmoCppResult: TMemo
        Left = 7
        Top = 210
        Width = 857
        Height = 302
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssVertical
        TabOrder = 5
      end
      object chkWideCpp: TCheckBox
        Left = 568
        Top = 183
        Width = 97
        Height = 17
        Caption = 'Wide Identifier'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object btnOpenC: TButton
        Left = 8
        Top = 176
        Width = 41
        Height = 25
        Caption = 'Open'
        TabOrder = 1
        OnClick = btnOpenCClick
      end
      object btnPairCpp: TButton
        Left = 448
        Top = 176
        Width = 73
        Height = 25
        Caption = 'Pair'
        TabOrder = 3
        OnClick = btnPairCppClick
      end
    end
  end
  object dlgOpen1: TOpenDialog
    Left = 300
    Top = 208
  end
end
