object CnLoadElementForm: TCnLoadElementForm
  Left = 342
  Top = 106
  Width = 874
  Height = 652
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
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 845
    Height = 604
    ActivePage = tsPascal
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsPascal: TTabSheet
      Caption = 'Pascal'
      object mmoPas: TMemo
        Left = 16
        Top = 16
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
        Top = 16
        Width = 129
        Height = 25
        Caption = 'Load Pascal Elements'
        TabOrder = 1
        OnClick = btnLoadPasElementsClick
      end
      object mmoPasRes: TMemo
        Left = 16
        Top = 216
        Width = 809
        Height = 345
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 2
      end
    end
    object tsCPP: TTabSheet
      Caption = 'C/C++'
      ImageIndex = 1
      object mmoCpp: TMemo
        Left = 16
        Top = 16
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
        TabOrder = 0
      end
      object btnLoadCppElement: TButton
        Left = 696
        Top = 16
        Width = 129
        Height = 25
        Caption = 'Load C/C++ Elements'
        TabOrder = 1
        OnClick = btnLoadCppElementClick
      end
      object mmoCppRes: TMemo
        Left = 16
        Top = 216
        Width = 809
        Height = 345
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 2
      end
    end
  end
end
