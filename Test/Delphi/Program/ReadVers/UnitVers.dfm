object FormVers: TFormVers
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'Read Versions of All IDEs'
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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object mmoFiles: TMemo
    Left = 16
    Top = 32
    Width = 441
    Height = 481
    Lines.Strings = (
      'C:\Program Files (x86)\Borland\CBuilder5\Bin\coride50.bpl'
      'C:\Program Files (x86)\Borland\CBuilder6\Bin\coreide60.bpl'
      'C:\Program Files (x86)\Borland\Delphi5\Bin\coride50.bpl'
      'C:\Program Files (x86)\Borland\Delphi6\Bin\coreide60.bpl'
      'C:\Program Files (x86)\Borland\Delphi7\Bin\coreide70.bpl'
      'C:\Program Files (x86)\Borland\BDS\3.0\Bin\coreide90.bpl'
      'C:\Program Files (x86)\Borland\BDS\4.0\Bin\coreide100.bpl'
      
        'C:\Program Files (x86)\CodeGear\RAD Studio\5.0\bin\coreide100.bp' +
        'l'
      
        'C:\Program Files (x86)\CodeGear\RAD Studio\6.0\bin\coreide120.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\RAD Studio\7.0\bin\coreide140' +
        '.bpl'
      
        'C:\Program Files (x86)\Embarcadero\RAD Studio\8.0\bin\coreide150' +
        '.bpl'
      
        'C:\Program Files (x86)\Embarcadero\RAD Studio\9.0\bin\coreide160' +
        '.bpl'
      
        'C:\Program Files (x86)\Embarcadero\RAD Studio\10.0\bin\coreide17' +
        '0.bpl'
      
        'C:\Program Files (x86)\Embarcadero\RAD Studio\11.0\bin\coreide18' +
        '0.bpl'
      
        'C:\Program Files (x86)\Embarcadero\RAD Studio\12.0\bin\coreide19' +
        '0.bpl'
      
        'C:\Program Files (x86)\Embarcadero\Studio\14.0\bin\coreide200.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\Studio\15.0\bin\coreide210.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\Studio\16.0\bin\coreide220.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\Studio\17.0\bin\coreide230.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\coreide240.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\coreide250.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\coreide260.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\coreide270.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\Studio\22.0\bin\coreide280.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\coreide290.bp' +
        'l'
      
        'C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\coreide370.bp' +
        'l')
    TabOrder = 0
  end
  object mmoVers: TMemo
    Left = 472
    Top = 32
    Width = 473
    Height = 481
    TabOrder = 1
  end
  object btnRead: TButton
    Left = 424
    Top = 5
    Width = 75
    Height = 21
    Caption = 'Read'
    TabOrder = 2
    OnClick = btnReadClick
  end
  object btnAdd: TButton
    Left = 16
    Top = 5
    Width = 75
    Height = 21
    Caption = 'Add a File'
    TabOrder = 3
    OnClick = btnAddClick
  end
  object dlgOpen1: TOpenDialog
    Left = 120
  end
end
