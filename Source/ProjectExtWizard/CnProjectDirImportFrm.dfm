inherited CnImportDirForm: TCnImportDirForm
  Left = 246
  Top = 187
  BorderStyle = bsDialog
  Caption = 'Import Directories'
  ClientHeight = 171
  ClientWidth = 371
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object btnHelp: TButton
    Left = 286
    Top = 140
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 127
    Top = 140
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 207
    Top = 140
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object grpImport: TGroupBox
    Left = 8
    Top = 8
    Width = 353
    Height = 121
    Caption = 'Import Directories'
    TabOrder = 3
    object lblDir: TLabel
      Left = 16
      Top = 23
      Width = 17
      Height = 13
      Caption = 'Dir:'
    end
    object edtDir: TEdit
      Left = 56
      Top = 19
      Width = 249
      Height = 21
      TabOrder = 0
    end
    object btnSelectDir: TButton
      Left = 316
      Top = 19
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = btnSelectDirClick
    end
    object chkIngoreDir: TCheckBox
      Left = 16
      Top = 54
      Width = 97
      Height = 17
      Caption = 'Ignore this Dir:'
      TabOrder = 2
      OnClick = chkIngoreDirClick
    end
    object cbbIgnoreDir: TComboBox
      Left = 120
      Top = 52
      Width = 217
      Height = 21
      ItemHeight = 13
      TabOrder = 3
      Items.Strings = (
        'CVS')
    end
    object chkNameIsDesc: TCheckBox
      Left = 16
      Top = 86
      Width = 289
      Height = 17
      Caption = 'Auto Generate Readme File by Directory Name'
      TabOrder = 4
      OnClick = chkIngoreDirClick
    end
  end
end
