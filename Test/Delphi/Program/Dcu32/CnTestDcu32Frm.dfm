object FormDcu32: TFormDcu32
  Left = 240
  Top = 201
  BorderStyle = bsDialog
  Caption = 'Test Dcu32 Intf/Impl Parsing in D5~10.4 Unicode/Non-Unicode'
  ClientHeight = 512
  ClientWidth = 622
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
    Top = 60
    Width = 434
    Height = 13
    Caption =
      'Note: This Test Should Run OK from Delphi 5 ~ 10.4. Parse OK for' +
      ' Delphi 5 ~ 10.4 all Units.'
  end
  object edtDcuFile: TEdit
    Left = 80
    Top = 24
    Width = 441
    Height = 21
    TabOrder = 0
  end
  object btnOpen: TButton
    Left = 528
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
    Width = 129
    Height = 25
    Caption = 'Parse Dcu!'
    TabOrder = 2
    OnClick = Button1Click
  end
  object btnCnDcu32: TButton
    Left = 168
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
    Width = 577
    Height = 345
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
    WantReturns = False
    WordWrap = False
  end
  object btnScanDir: TButton
    Left = 328
    Top = 96
    Width = 129
    Height = 25
    Caption = 'Scan Dir'
    TabOrder = 5
    OnClick = btnScanDirClick
  end
  object btnExtract: TButton
    Left = 472
    Top = 96
    Width = 129
    Height = 25
    Caption = 'Test Extract'
    TabOrder = 6
    OnClick = btnExtractClick
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.DCU|*.dcu'
    Left = 424
    Top = 64
  end
end
