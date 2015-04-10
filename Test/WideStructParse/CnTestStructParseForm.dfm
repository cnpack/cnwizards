object TeststructParseForm: TTeststructParseForm
  Left = 0
  Top = 0
  Caption = 'Test Unicode Structure Parse '
  ClientHeight = 476
  ClientWidth = 773
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
    Left = 8
    Top = 8
    Width = 757
    Height = 460
    ActivePage = tsPascal
    TabOrder = 0
    object tsPascal: TTabSheet
      Caption = 'Pascal'
      object lblPascal: TLabel
        Left = 152
        Top = 184
        Width = 3
        Height = 13
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
        TabOrder = 0
        OnChange = mmoPasSrcChange
      end
      object btnParsePas: TButton
        Left = 8
        Top = 176
        Width = 75
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
    end
    object tsCpp: TTabSheet
      Caption = 'C/C++'
      ImageIndex = 1
      object mmoCppSrc: TMemo
        Left = 7
        Top = 7
        Width = 734
        Height = 158
        TabOrder = 0
      end
      object btnParseCpp: TButton
        Left = 8
        Top = 176
        Width = 75
        Height = 25
        Caption = 'Parse'
        TabOrder = 1
      end
      object mmoCppResult: TMemo
        Left = 7
        Top = 210
        Width = 734
        Height = 210
        TabOrder = 2
      end
    end
  end
end
