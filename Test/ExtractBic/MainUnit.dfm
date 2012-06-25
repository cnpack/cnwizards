object FormExtract: TFormExtract
  Left = 245
  Top = 163
  BorderStyle = bsDialog
  Caption = 'Extract Backup File (*.bic) to Directory'
  ClientHeight = 298
  ClientWidth = 520
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
  object lblFile: TLabel
    Left = 16
    Top = 18
    Width = 72
    Height = 13
    Caption = 'Select BIC File:'
  end
  object lblSelectDir: TLabel
    Left = 16
    Top = 50
    Width = 80
    Height = 13
    Caption = 'Select Directory:'
  end
  object edtFile: TEdit
    Left = 112
    Top = 16
    Width = 305
    Height = 21
    TabOrder = 0
  end
  object edtDir: TEdit
    Left = 112
    Top = 48
    Width = 305
    Height = 21
    TabOrder = 1
  end
  object btnOpen: TButton
    Left = 432
    Top = 16
    Width = 75
    Height = 21
    Caption = 'Open'
    TabOrder = 2
    OnClick = btnOpenClick
  end
  object btnSelectDir: TButton
    Left = 432
    Top = 48
    Width = 75
    Height = 21
    Caption = 'Select'
    TabOrder = 3
    OnClick = btnSelectDirClick
  end
  object btnExtract: TButton
    Left = 16
    Top = 88
    Width = 491
    Height = 25
    Caption = 'Extract!'
    TabOrder = 4
    OnClick = btnExtractClick
  end
  object mmoResult: TMemo
    Left = 16
    Top = 128
    Width = 489
    Height = 153
    ScrollBars = ssVertical
    TabOrder = 5
  end
  object dlgOpen: TOpenDialog
    Filter = 'CnWizards IDE Backup File(*.bic)|*.bic|All Files(*.*)|*.*'
    Left = 208
    Top = 8
  end
end
