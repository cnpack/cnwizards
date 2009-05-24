object CnImportDirForm: TCnImportDirForm
  Left = 246
  Top = 187
  BorderStyle = bsDialog
  Caption = '导入目录结构'
  ClientHeight = 171
  ClientWidth = 371
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '宋体'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 12
  object btnHelp: TButton
    Left = 286
    Top = 140
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 127
    Top = 140
    Width = 75
    Height = 21
    Caption = '确定(&O)'
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
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 1
  end
  object grpImport: TGroupBox
    Left = 8
    Top = 8
    Width = 353
    Height = 121
    Caption = '导入目录结构'
    TabOrder = 3
    object lblDir: TLabel
      Left = 16
      Top = 23
      Width = 36
      Height = 12
      Caption = '目录：'
    end
    object edtDir: TEdit
      Left = 56
      Top = 19
      Width = 249
      Height = 20
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
      Caption = '忽略子目录名：'
      TabOrder = 2
      OnClick = chkIngoreDirClick
    end
    object cbbIgnoreDir: TComboBox
      Left = 120
      Top = 52
      Width = 217
      Height = 20
      ItemHeight = 12
      TabOrder = 3
      Items.Strings = (
        'CVS')
    end
    object chkNameIsDesc: TCheckBox
      Left = 16
      Top = 86
      Width = 289
      Height = 17
      Caption = '根据子目录名自动生成描述文件'
      TabOrder = 4
      OnClick = chkIngoreDirClick
    end
  end
end
