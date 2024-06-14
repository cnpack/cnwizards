object TeststructParseForm: TTeststructParseForm
  Left = 197
  Top = 108
  Width = 787
  Height = 503
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
    Width = 761
    Height = 460
    ActivePage = tsPascal
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
        Width = 734
        Height = 158
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
        TabOrder = 1
        OnClick = btnParsePasClick
      end
      object mmoPasResult: TMemo
        Left = 7
        Top = 210
        Width = 734
        Height = 210
        TabOrder = 2
      end
      object btnGetUses: TButton
        Left = 416
        Top = 176
        Width = 75
        Height = 25
        Caption = 'Get Uses'
        TabOrder = 3
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
        TabOrder = 4
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
        TabOrder = 6
        OnClick = btnOpenPasClick
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
        Width = 734
        Height = 158
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
        TabOrder = 1
        OnClick = btnParseCppClick
      end
      object mmoCppResult: TMemo
        Left = 7
        Top = 210
        Width = 734
        Height = 210
        TabOrder = 2
      end
      object chkWideCpp: TCheckBox
        Left = 568
        Top = 183
        Width = 97
        Height = 17
        Caption = 'Wide Identifier'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object btnOpenC: TButton
        Left = 8
        Top = 176
        Width = 41
        Height = 25
        Caption = 'Open'
        TabOrder = 4
        OnClick = btnOpenCClick
      end
    end
  end
  object dlgOpen1: TOpenDialog
    Left = 204
    Top = 208
  end
end
