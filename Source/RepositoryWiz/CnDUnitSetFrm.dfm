object CnDUnitSetForm: TCnDUnitSetForm
  Left = 349
  Top = 263
  BorderStyle = bsDialog
  Caption = 'DUnit 专家'
  ClientHeight = 170
  ClientWidth = 268
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object gbxSetup: TGroupBox
    Left = 12
    Top = 12
    Width = 246
    Height = 113
    Caption = '选项'
    TabOrder = 0
    object chbxUnitHead: TCheckBox
      Left = 16
      Top = 81
      Width = 161
      Height = 17
      Caption = '加入单元头注释'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object chbxInitClass: TCheckBox
      Left = 16
      Top = 60
      Width = 161
      Height = 17
      Caption = '初始化测试类'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object rbCreateApplication: TRadioButton
      Left = 16
      Top = 16
      Width = 169
      Height = 17
      Caption = '新建 DUnit 测试工程'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbCreateUnit: TRadioButton
      Left = 16
      Top = 38
      Width = 169
      Height = 17
      Caption = '新建 DUnit 测试单元'
      TabOrder = 1
    end
  end
  object btnOK: TButton
    Left = 11
    Top = 137
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 97
    Top = 137
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 182
    Top = 137
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
