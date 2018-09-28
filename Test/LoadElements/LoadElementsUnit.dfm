object CnLoadElementForm: TCnLoadElementForm
  Left = 192
  Top = 107
  Width = 775
  Height = 403
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
    Width = 601
    Height = 321
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
  object btnLoadElements: TButton
    Left = 640
    Top = 24
    Width = 113
    Height = 25
    Caption = 'Load Elements'
    TabOrder = 1
    OnClick = btnLoadElementsClick
  end
end
