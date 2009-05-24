object CnPrefixExecuteForm: TCnPrefixExecuteForm
  Left = 331
  Top = 202
  BorderStyle = bsDialog
  Caption = '组件前缀专家'
  ClientHeight = 260
  ClientWidth = 369
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 46
    Top = 232
    Width = 73
    Height = 21
    Caption = '处理(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 206
    Top = 232
    Width = 75
    Height = 21
    Cancel = True
    Caption = '关闭(&C)'
    ModalResult = 2
    TabOrder = 4
  end
  object btnHelp: TButton
    Left = 286
    Top = 232
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 5
    OnClick = btnHelpClick
  end
  object btnConfig: TButton
    Left = 126
    Top = 232
    Width = 75
    Height = 21
    Cancel = True
    Caption = '设置(&S)'
    TabOrder = 3
  end
  object gbKind: TGroupBox
    Left = 8
    Top = 8
    Width = 353
    Height = 129
    Caption = '请选择需要进行前缀处理的内容(&N)'
    TabOrder = 0
    object rbSelComp: TRadioButton
      Left = 8
      Top = 16
      Width = 310
      Height = 17
      Caption = '当前选择的组件。'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbCurrForm: TRadioButton
      Left = 8
      Top = 38
      Width = 310
      Height = 17
      Caption = '当前窗体上的所有组件。'
      TabOrder = 1
    end
    object rbOpenedForm: TRadioButton
      Left = 8
      Top = 60
      Width = 310
      Height = 17
      Caption = '当前打开的所有窗体上的组件。'
      TabOrder = 2
    end
    object rbCurrProject: TRadioButton
      Left = 8
      Top = 82
      Width = 310
      Height = 17
      Caption = '当前工程所有窗体上的组件。'
      TabOrder = 3
    end
    object rbProjectGroup: TRadioButton
      Left = 8
      Top = 104
      Width = 310
      Height = 17
      Caption = '当前工程组所有工程所有窗体上的组件。'
      TabOrder = 4
    end
  end
  object rgCompKind: TRadioGroup
    Left = 8
    Top = 144
    Width = 353
    Height = 81
    Caption = '组件列表内容(&L)'
    ItemIndex = 0
    Items.Strings = (
      '前缀不正确的组件。'
      '前缀不正确的组件及前缀加数字形式的组件。'
      '所有组件（包括被忽略的组件）。')
    TabOrder = 1
  end
end
