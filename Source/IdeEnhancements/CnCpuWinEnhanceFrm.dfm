object CnCpuWinEnhanceForm: TCnCpuWinEnhanceForm
  Left = 347
  Top = 219
  BorderStyle = bsDialog
  Caption = 'CPU 窗口扩展设置'
  ClientHeight = 204
  ClientWidth = 249
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object CopyParam: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 72
    Caption = '参数设置'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 21
      Width = 72
      Height = 12
      AutoSize = False
      Caption = '复制行数:'
    end
    object rbTopAddr: TRadioButton
      Left = 8
      Top = 48
      Width = 105
      Height = 17
      Caption = '从第一行'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object rbSelectAddr: TRadioButton
      Left = 112
      Top = 48
      Width = 113
      Height = 17
      Caption = '从选择行'
      TabOrder = 2
    end
    object seCopyLineCount: TCnSpinEdit
      Left = 88
      Top = 16
      Width = 129
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 30
      OnKeyPress = seCopyLineCountKeyPress
    end
  end
  object cbSettingToAll: TCheckBox
    Left = 8
    Top = 152
    Width = 153
    Height = 17
    Caption = '应用设置为默认操作。'
    TabOrder = 2
  end
  object rgCopyToMode: TRadioGroup
    Left = 8
    Top = 88
    Width = 233
    Height = 57
    Caption = '复制结果'
    Items.Strings = (
      '复制到剪贴板'
      '复制到文件')
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 8
    Top = 176
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 88
    Top = 176
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 4
  end
  object btnHelp: TButton
    Left = 168
    Top = 176
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 5
    OnClick = btnHelpClick
  end
end
