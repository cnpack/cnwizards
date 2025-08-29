object FormDcu32: TFormDcu32
  Left = 240
  Top = 201
  BorderStyle = bsDialog
  Caption = 'Test Dcu32 Intf/Impl Parsing for D110A Unicode 32/64'
  ClientHeight = 568
  ClientWidth = 660
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  ShowHint = True
  OnDestroy = FormDestroy
  DesignSize = (
    660
    568)
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
    Width = 505
    Height = 13
    Caption = 
      'Note: This Test Should Run OK from Delphi 110A ~ Above all. Pars' +
      'e OK for Delphi 110A ~ Above all Units.'
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
    Top = 168
    Width = 615
    Height = 377
    Anchors = [akLeft, akTop, akRight, akBottom]
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
  object btnScanSysLib: TButton
    Left = 24
    Top = 127
    Width = 129
    Height = 25
    Caption = 'Scan SysLib'
    TabOrder = 7
    OnClick = btnScanSysLibClick
  end
  object btnGenSysLib: TButton
    Left = 170
    Top = 127
    Width = 143
    Height = 25
    Hint = 
      'Select a Directory like C:\Program Files (x86)\Embarcadero\Studi' +
      'o\23.0\lib'
    Caption = 'Gen SysLib'
    TabOrder = 8
    OnClick = btnGenSysLibClick
  end
  object btnLoadGenTxt: TButton
    Left = 328
    Top = 127
    Width = 129
    Height = 25
    Caption = 'Load Generated Text'
    TabOrder = 9
    OnClick = btnLoadGenTxtClick
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.DCU|*.dcu|*.TXT|*.txt'
    Left = 568
    Top = 56
  end
  object dlgSave1: TSaveDialog
    Left = 488
    Top = 248
  end
end
