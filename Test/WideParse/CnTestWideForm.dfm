object CnTestUnicodeParseForm: TCnTestUnicodeParseForm
  Left = 0
  Top = 0
  Caption = 'Unicode Parsing Text'
  ClientHeight = 393
  ClientWidth = 790
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
    Width = 753
    Height = 363
    ActivePage = tsPasLex
    TabOrder = 0
    object tsPasLex: TTabSheet
      Caption = 'Pascal'
      object mmoPasSrc: TMemo
        Left = 16
        Top = 16
        Width = 241
        Height = 305
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
          'Caption :=  '#39#21507#39277#39';'
          ' {'#21512#36866'} Exit;'
          'end;')
        TabOrder = 0
      end
      object btnParsePas: TButton
        Left = 268
        Top = 14
        Width = 61
        Height = 25
        Caption = 'Parse'
        TabOrder = 1
        OnClick = btnParsePasClick
      end
      object mmoPasResult: TMemo
        Left = 344
        Top = 16
        Width = 385
        Height = 305
        TabOrder = 2
      end
      object chkWideIdent: TCheckBox
        Left = 265
        Top = 64
        Width = 73
        Height = 17
        Caption = 'Wide Ident'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
    end
    object tsBCB: TTabSheet
      Caption = 'C/C++'
      ImageIndex = 1
      object mmoCppSrc: TMemo
        Left = 16
        Top = 16
        Width = 241
        Height = 305
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
          '{ "'#21507#39277'"; '#39#27700#39';'
          '}'
          '//-------------------------------------------------------'
          'void __fastcall TImageForm::FormCreate'
          '(TObject* /*Sender*/)'
          '{     FormCaption = Caption + " - ";'
          '}'
          ''
          '//-------------------------------------------------------'
          '')
        TabOrder = 0
      end
      object btnParseCpp: TButton
        Left = 268
        Top = 14
        Width = 61
        Height = 25
        Caption = 'Parse'
        TabOrder = 1
        OnClick = btnParseCppClick
      end
      object mmoCppResult: TMemo
        Left = 344
        Top = 16
        Width = 385
        Height = 305
        TabOrder = 2
      end
    end
  end
end
