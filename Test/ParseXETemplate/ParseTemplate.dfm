object frmParse: TfrmParse
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Parse XE/XE2 Code Template Test'
  ClientHeight = 365
  ClientWidth = 630
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
    Left = 16
    Top = 16
    Width = 17
    Height = 13
    Caption = 'Dir:'
  end
  object lbl2: TLabel
    Left = 16
    Top = 48
    Width = 412
    Height = 26
    Caption = 
      'Select X/XE2 Code Templates store directory. E.g: '#13#10'C:\Program F' +
      'iles\Embarcadero\RAD Studio\9.0\ObjRepos\en\Code_Templates\Delph' +
      'i\'
  end
  object edtDir: TEdit
    Left = 39
    Top = 13
    Width = 482
    Height = 21
    TabOrder = 1
    Text = 
      'C:\Program Files\Embarcadero\RAD Studio\9.0\ObjRepos\en\Code_Tem' +
      'plates\Delphi\'
  end
  object btnSelect: TButton
    Left = 536
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Select'
    TabOrder = 0
    Visible = False
  end
  object mmoTemplates: TMemo
    Left = 16
    Top = 96
    Width = 593
    Height = 249
    ReadOnly = True
    TabOrder = 3
  end
  object btnParse: TButton
    Left = 536
    Top = 49
    Width = 75
    Height = 25
    Caption = 'Parse'
    TabOrder = 2
    OnClick = btnParseClick
  end
end
