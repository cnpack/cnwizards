object CnTestUnicodeParseForm: TCnTestUnicodeParseForm
  Left = 57
  Top = 114
  Width = 870
  Height = 490
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
    Width = 833
    Height = 433
    ActivePage = tsPasLex
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsPasLex: TTabSheet
      Caption = 'Pascal'
      object mmoPasSrc: TMemo
        Left = 16
        Top = 16
        Width = 241
        Height = 369
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
          '    procedure FormCreate(Sender: TObject);'
          '  private'
          '    { Private declarations }'
          '  public'
          '    { Public declarations }'
          '  end;'
          ''
          'var'
          '  Form2: TForm2;'
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
        TabOrder = 1
      end
      object btnWideParsePas: TButton
        Left = 268
        Top = 14
        Width = 61
        Height = 25
        Caption = 'Wide Parse'
        TabOrder = 0
        OnClick = btnWideParsePasClick
      end
      object mmoPasResult: TMemo
        Left = 344
        Top = 16
        Width = 457
        Height = 369
        ScrollBars = ssBoth
        TabOrder = 2
        WordWrap = False
      end
      object chkWideIdent: TCheckBox
        Left = 265
        Top = 104
        Width = 73
        Height = 17
        Caption = 'Wide Ident'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object btnAnsiParsePas: TButton
        Left = 268
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
        Width = 241
        Height = 369
        Lines.Strings = (
          '//-------------------------------------------------------'
          '#include <vcl.h>'
          '#pragma hdrstop'
          ''
          '#include <sysutils.hpp>'
          '#include <stdio.h>'
          '#include "imagewn.h"'
          '#include "ViewFrm.h"'
          '//-------------------------------------------------------'
          '#pragma resource "*.dfm"'
          'TImageForm *ImageForm;'
          '//-------------------------------------------------------'
          '__fastcall TImageForm::TImageForm'
          '(TComponent *Owner)'
          '  : TForm(Owner)'
          '{ "≥‘∑π"; '#39'ÀÆ'#39';'
          '}'
          '//-------------------------------------------------------'
          'void __fastcall TImageForm::FormCreate'
          '(TObject* /*Sender*/)'
          '{     FormCaption = Caption + " - ";'
          '}'
          ''
          '//-------------------------------------------------------'
          '')
        TabOrder = 1
      end
      object btnWideParseCpp: TButton
        Left = 268
        Top = 14
        Width = 61
        Height = 25
        Caption = 'Wide Parse'
        TabOrder = 0
        OnClick = btnWideParseCppClick
      end
      object mmoCppResult: TMemo
        Left = 344
        Top = 16
        Width = 465
        Height = 369
        ScrollBars = ssBoth
        TabOrder = 2
        WordWrap = False
      end
      object chkWideIdentC: TCheckBox
        Left = 265
        Top = 96
        Width = 73
        Height = 17
        Caption = 'Wide Ident'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object btnAnsiParseCpp: TButton
        Left = 268
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
