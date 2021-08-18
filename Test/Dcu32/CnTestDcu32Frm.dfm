object FormDcu32: TFormDcu32
  Left = 240
  Top = 201
  BorderStyle = bsDialog
  Caption = 'Test Dcu32 Intf Parsing'
  ClientHeight = 442
  ClientWidth = 496
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
  object lbl1: TLabel
    Left = 24
    Top = 28
    Width = 39
    Height = 13
    Caption = 'Dcu File'
  end
  object lblNote: TLabel
    Left = 24
    Top = 64
    Width = 467
    Height = 13
    Caption = 
      'Note: This Test Should Run OK from Delphi 5 ~ Above all. Parse O' +
      'K for Delphi 5 ~ Above all Units.'
  end
  object edtDcuFile: TEdit
    Left = 80
    Top = 24
    Width = 305
    Height = 21
    TabOrder = 0
  end
  object btnOpen: TButton
    Left = 400
    Top = 24
    Width = 75
    Height = 21
    Caption = 'Open Dcu'
    TabOrder = 1
    OnClick = btnOpenClick
  end
  object Button1: TButton
    Left = 24
    Top = 96
    Width = 257
    Height = 25
    Caption = 'Parse Dcu!'
    TabOrder = 2
    OnClick = Button1Click
  end
  object btnCnDcu32: TButton
    Left = 328
    Top = 96
    Width = 145
    Height = 25
    Caption = 'CnDcu32'
    TabOrder = 3
    OnClick = btnCnDcu32Click
  end
  object mmoDcu: TMemo
    Left = 24
    Top = 144
    Width = 449
    Height = 281
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.DCU|*.dcu'
    Left = 424
    Top = 64
  end
end
