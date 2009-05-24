object Form1: TForm1
  Left = 161
  Top = 150
  BorderStyle = bsDialog
  Caption = 'Pas2Html Test'
  ClientHeight = 308
  ClientWidth = 317
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 48
    Top = 200
    Width = 218
    Height = 13
    Caption = 'Should Run OK both in Delphi 5 ~ Delphi 2009'
  end
  object Button1: TButton
    Left = 40
    Top = 32
    Width = 233
    Height = 25
    Caption = 'Open PAS and Convert to HTML'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 40
    Top = 88
    Width = 233
    Height = 25
    Caption = 'Open PAS and Convert to RTF'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 40
    Top = 144
    Width = 233
    Height = 25
    Caption = 'Construct HTML Clipboard String'
    TabOrder = 2
    OnClick = Button3Click
  end
  object btn1: TButton
    Left = 40
    Top = 240
    Width = 233
    Height = 25
    Caption = 'Test WideString to UTF8'
    TabOrder = 3
    OnClick = btn1Click
  end
  object dlgOpen1: TOpenDialog
    DefaultExt = '*.pas'
    Filter = '*.pas|*.pas'
    Left = 184
    Top = 32
  end
end
