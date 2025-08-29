object CnTestUnicodeParseForm: TCnTestUnicodeParseForm
  Left = 57
  Top = 114
  Width = 1053
  Height = 573
  Caption = 'Unicode Parsing Text - For Unicode & Non-Unicode Compiler'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pgc1: TPageControl
    Left = 16
    Top = 16
    Width = 1016
    Height = 516
    ActivePage = tsPasLex
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsPasLex: TTabSheet
      Caption = 'Pascal'
      object mmoPasSrc: TMemo
        Left = 16
        Top = 16
        Width = 337
        Height = 457
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'unit CnTestPasLexW;'
          ''
          'interface'
          ''
          'uses'
          '  Windows, Messages, SysUtils, Variants, '
          'Classes, Graphics, Controls, Forms,'
          '  Dialogs;'
          ''
          'type'
          '  TForm2 = class(TForm)'
          '    mmoSrc: TMemo;'
          '    procedure FormCreate(Sender: '
          'TObject);'
          '  private'
          '    { Private declarations }'
          '  public'
          '    { Public declarations }'
          '  end;'
          ''
          'var'
          '  Form2: TForm2;'
          ''
          'S := '#39#39#39
          '  Test for MultiLineString'
          'and some New strings.'
          #39#39#39';'
          ''
          'implementation'
          ''
          '{$R *.dfm}'
          ''
          'procedure TForm2.FormCreate(Sender: '
          'TObject);'
          'begin'
          'Caption :=  '#39'≥‘∑π'#39';'
          ' {∫œ  } Exit;'
          'end;')
        ParentFont = False
        TabOrder = 1
      end
      object btnWideParsePas: TButton
        Left = 364
        Top = 14
        Width = 61
        Height = 25
        Caption = 'Wide Parse'
        TabOrder = 0
        OnClick = btnWideParsePasClick
      end
      object mmoPasResult: TMemo
        Left = 440
        Top = 16
        Width = 553
        Height = 457
        ScrollBars = ssBoth
        TabOrder = 2
        WordWrap = False
      end
      object chkWideIdent: TCheckBox
        Left = 361
        Top = 104
        Width = 73
        Height = 17
        Caption = 'Wide Ident'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object btnAnsiParsePas: TButton
        Left = 364
        Top = 54
        Width = 61
        Height = 25
        Caption = 'Ansi Parse'
        TabOrder = 3
        OnClick = btnAnsiParsePasClick
      end
    end
    object tsBCB: TTabSheet
      Caption = 'C/C++'
      ImageIndex = 1
      object mmoCppSrc: TMemo
        Left = 16
        Top = 16
        Width = 337
        Height = 457
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          '//---------------------------------------'
          '----------------'
          '#include <vcl.h>'
          '#pragma hdrstop'
          ''
          '#include <sysutils.hpp>'
          '#include <stdio.h>'
          '#include "imagewn.h"'
          '#include "ViewFrm.h"'
          '//---------------------------------------'
          '----------------'
          '#pragma resource "*.dfm"'
          'TImageForm *ImageForm;'
          '//---------------------------------------'
          '----------------'
          '__fastcall TImageForm::TImageForm'
          '(TComponent *Owner)'
          '  : TForm(Owner)'
          '{ "≥‘∑π"; '#39'ÀÆ'#39';'
          '}'
          '//---------------------------------------'
          '----------------'
          'void __fastcall TImageForm::FormCreate'
          '(TObject* /*Sender*/)'
          '{     FormCaption = Caption + " - ";'
          '}'
          ''
          '//---------------------------------------'
          '----------------'
          '')
        ParentFont = False
        TabOrder = 1
      end
      object btnWideParseCpp: TButton
        Left = 364
        Top = 14
        Width = 61
        Height = 25
        Caption = 'Wide Parse'
        TabOrder = 0
        OnClick = btnWideParseCppClick
      end
      object mmoCppResult: TMemo
        Left = 440
        Top = 16
        Width = 553
        Height = 457
        ScrollBars = ssBoth
        TabOrder = 2
        WordWrap = False
      end
      object chkWideIdentC: TCheckBox
        Left = 361
        Top = 104
        Width = 73
        Height = 17
        Caption = 'Wide Ident'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object btnAnsiParseCpp: TButton
        Left = 364
        Top = 54
        Width = 61
        Height = 25
        Caption = 'Ansi Parse'
        TabOrder = 3
        OnClick = btnAnsiParseCppClick
      end
    end
  end
end
