object CnLoadElementForm: TCnLoadElementForm
  Left = 192
  Top = 107
  Width = 844
  Height = 474
  Caption = 
    'Load Elements Test for Procedure List in Unicode/NonUnicode Comp' +
    'iler'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object mmoPas: TMemo
    Left = 24
    Top = 24
    Width = 657
    Height = 185
    Lines.Strings = (
      'unit a;'
      'interface'
      'implementation'
      ''
      
        'class function TCollections.CreateDictionary<TKey, TValue>: IDic' +
        'tionary<TKey, TValue>;'
      'begin'
      
        '  Result := TCollections.CreateDictionary<TKey,TValue>(0, TEqual' +
        'ityComparer<TKey>.Default);'
      'end;'
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
      '                procedure TestInner;'
      '                begin'
      ''
      '                end;'
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
    TabOrder = 0
  end
  object btnLoadPasElements: TButton
    Left = 696
    Top = 24
    Width = 129
    Height = 25
    Caption = 'Load Pascal Elements'
    TabOrder = 1
    OnClick = btnLoadPasElementsClick
  end
  object mmoCpp: TMemo
    Left = 24
    Top = 232
    Width = 657
    Height = 185
    Lines.Strings = (
      
        '//--------------------------------------------------------------' +
        '-------------'
      ''
      '#include <vcl.h>'
      '#pragma hdrstop'
      ''
      '#include "Unit1.h"'
      
        '//--------------------------------------------------------------' +
        '-------------'
      '#pragma package(smart_init)'
      '#pragma resource "*.dfm"'
      'TForm1 *Form1;'
      
        '//--------------------------------------------------------------' +
        '-------------'
      '__fastcall TForm1::TForm1(TComponent* Owner)'
      '        : TForm(Owner)'
      '{'
      '}'
      ''
      '__fastcall TForm1::~TForm1()'
      '{'
      '}'
      
        '//--------------------------------------------------------------' +
        '-------------'
      '')
    TabOrder = 2
  end
  object btnLoadCppElement: TButton
    Left = 696
    Top = 232
    Width = 129
    Height = 25
    Caption = 'Load C/C++ Elements'
    TabOrder = 3
    OnClick = btnLoadCppElementClick
  end
end
