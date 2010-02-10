inherited CnIniFilerForm: TCnIniFilerForm
  Left = 309
  Top = 173
  BorderStyle = bsDialog
  Caption = 'INI Reader and Writer Settings'
  ClientHeight = 223
  ClientWidth = 269
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 11
    Top = 189
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 97
    Top = 189
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 182
    Top = 189
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object grp1: TGroupBox
    Left = 12
    Top = 8
    Width = 245
    Height = 169
    Caption = 'INI Reader and Writer Settings'
    TabOrder = 0
    object lblIni: TLabel
      Left = 16
      Top = 24
      Width = 38
      Height = 13
      Caption = 'INI File:'
    end
    object lblConstPrefix: TLabel
      Left = 16
      Top = 56
      Width = 63
      Height = 13
      Caption = 'Const Prefix:'
    end
    object lblIniClassName: TLabel
      Left = 16
      Top = 88
      Width = 56
      Height = 13
      Caption = 'ClassName:'
    end
    object lblT: TLabel
      Left = 80
      Top = 88
      Width = 6
      Height = 13
      Caption = 'T'
      Color = clBtnFace
      ParentColor = False
    end
    object btnOpen: TSpeedButton
      Left = 212
      Top = 20
      Width = 20
      Height = 20
      Flat = True
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        88888888888888888888000000000008888800333333333088880B0333333333
        08880FB03333333330880BFB0333333333080FBFB000000000000BFBFBFBFB08
        88880FBFBFBFBF0888880BFB0000000888888000888888880008888888888888
        8008888888880888080888888888800088888888888888888888}
      OnClick = btnOpenClick
    end
    object edtIniFile: TEdit
      Left = 80
      Top = 20
      Width = 129
      Height = 21
      TabOrder = 0
    end
    object edtPrefix: TEdit
      Left = 80
      Top = 52
      Width = 153
      Height = 21
      TabOrder = 1
    end
    object edtClassName: TEdit
      Left = 88
      Top = 84
      Width = 145
      Height = 21
      TabOrder = 2
    end
    object chkIsAllStr: TCheckBox
      Left = 16
      Top = 114
      Width = 225
      Height = 17
      Caption = 'Auto Detect the Type of Items in INI File.'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = chkIsAllStrClick
    end
    object chkBool: TCheckBox
      Left = 36
      Top = 138
      Width = 205
      Height = 17
      Caption = 'Treat 0 and 1 as Boolean Type.'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
  end
  object dlgOpen: TOpenDialog
    Filter = 'INI Files(*.ini)|*.ini'
    Left = 224
    Top = 96
  end
  object dlgSave: TSaveDialog
    Left = 220
    Top = 128
  end
end
