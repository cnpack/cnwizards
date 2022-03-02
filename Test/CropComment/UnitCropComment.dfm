object FormCrop: TFormCrop
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'Test Crop Comment'
  ClientHeight = 536
  ClientWidth = 971
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 953
    Height = 521
    ActivePage = tsPas
    TabOrder = 0
    object tsPas: TTabSheet
      Caption = 'Pascal'
      object btnPasCrop: TSpeedButton
        Left = 462
        Top = 16
        Width = 23
        Height = 22
        Caption = 'C'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = btnPasCropClick
      end
      object mmoPas: TMemo
        Left = 8
        Top = 16
        Width = 449
        Height = 457
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'program TestCropComment;'
          ''
          'uses'
          '  Forms,'
          '  UnitCropComment{bbb}in '#39'UnitCropComment.pas'#39' {Form1};'
          ''
          '{$R *.RES}  // kkk'
          ''
          'begin'
          '  Applic{aaa}ation.Initialize;//'
          '  Application.CreateForm(TForm1, Form1); //mmmmm'
          '  Application.Run;'
          'end.')
        ParentFont = False
        TabOrder = 0
      end
      object mmoPasRes: TMemo
        Left = 488
        Top = 16
        Width = 449
        Height = 457
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
    end
    object tsCpp: TTabSheet
      Caption = 'C/C++'
      ImageIndex = 1
      object btnCppCrop: TSpeedButton
        Left = 462
        Top = 16
        Width = 23
        Height = 22
        Caption = 'C'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object mmoCpp: TMemo
        Left = 8
        Top = 16
        Width = 449
        Height = 457
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object mmoCppRes: TMemo
        Left = 488
        Top = 16
        Width = 449
        Height = 457
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
    end
  end
end
