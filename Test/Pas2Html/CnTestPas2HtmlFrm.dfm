object FormPasConvert: TFormPasConvert
  Left = 161
  Top = 150
  BorderStyle = bsDialog
  Caption = 'Source Pas/Cpp to Html Test'
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
    Left = 24
    Top = 200
    Width = 272
    Height = 13
    Caption = 'Should Run OK both in Delphi 5 ~ Delphi 2009 and above'
  end
  object btnPas2Html: TButton
    Left = 40
    Top = 32
    Width = 233
    Height = 25
    Caption = 'Open PAS/CPP and Convert to HTML'
    TabOrder = 0
    OnClick = btnPas2HtmlClick
  end
  object btnPas2Rtf: TButton
    Left = 40
    Top = 88
    Width = 233
    Height = 25
    Caption = 'Open PAS/CPP and Convert to RTF'
    TabOrder = 1
    OnClick = btnPas2RtfClick
  end
  object btnHtmlClipboard: TButton
    Left = 40
    Top = 144
    Width = 233
    Height = 25
    Caption = 'Construct HTML Clipboard String'
    TabOrder = 2
    OnClick = btnHtmlClipboardClick
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
    Filter = '*.pas|*.pas|*.cpp|*.cpp|*.c|*.c|*.*|*.*'
    Left = 184
    Top = 32
  end
end
