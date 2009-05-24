object CnTabOrderForm: TCnTabOrderForm
  Left = 324
  Top = 236
  BorderStyle = bsDialog
  Caption = 'Tab Order 专家设置'
  ClientHeight = 251
  ClientWidth = 350
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
  object btnHelp: TButton
    Left = 270
    Top = 224
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 6
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 110
    Top = 224
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 190
    Top = 224
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 5
  end
  object rgTabOrderStyle: TRadioGroup
    Left = 8
    Top = 8
    Width = 121
    Height = 53
    Caption = '排序方式(&R)'
    ItemIndex = 0
    Items.Strings = (
      '先水平再垂直。'
      '以先垂直再水平。')
    TabOrder = 0
  end
  object gbOther: TGroupBox
    Left = 8
    Top = 136
    Width = 337
    Height = 81
    Caption = '其它设置(&T)'
    TabOrder = 3
    object cbOrderByCenter: TCheckBox
      Left = 8
      Top = 53
      Width = 225
      Height = 17
      Caption = '计算位置时根据控件中心来判断。'
      TabOrder = 2
    end
    object cbIncludeChildren: TCheckBox
      Left = 8
      Top = 35
      Width = 225
      Height = 17
      Caption = '处理控件时包含所有子控件。'
      TabOrder = 1
    end
    object cbAutoReset: TCheckBox
      Left = 8
      Top = 16
      Width = 225
      Height = 17
      Caption = '移动控件时自动更新 Tab Order。'
      TabOrder = 0
    end
    object btnShortCut: TButton
      Left = 240
      Top = 50
      Width = 83
      Height = 21
      Caption = '设置快捷键(&K)'
      TabOrder = 3
      OnClick = btnShortCutClick
    end
  end
  object gbDispTabOrder: TGroupBox
    Left = 136
    Top = 8
    Width = 209
    Height = 121
    Caption = 'Tab Order 标签(&L)'
    TabOrder = 2
    object Label5: TLabel
      Left = 26
      Top = 40
      Width = 52
      Height = 13
      Caption = '显示位置:'
    end
    object Label7: TLabel
      Left = 26
      Top = 87
      Width = 52
      Height = 13
      Caption = '背景颜色:'
    end
    object spBkColor: TShape
      Left = 88
      Top = 84
      Width = 20
      Height = 20
      OnMouseDown = spBkColorMouseDown
    end
    object Label8: TLabel
      Left = 26
      Top = 63
      Width = 52
      Height = 13
      Caption = '标签字体:'
    end
    object spLabel: TShape
      Left = 88
      Top = 60
      Width = 20
      Height = 20
      OnMouseDown = spLabelMouseDown
    end
    object cbDispTabOrder: TCheckBox
      Left = 8
      Top = 16
      Width = 193
      Height = 17
      Caption = '在窗体上显示控件的 Tab Order。'
      TabOrder = 0
      OnClick = cbDispTabOrderClick
    end
    object cbbDispPos: TComboBox
      Left = 88
      Top = 36
      Width = 105
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        '左上角'
        '右上角'
        '左下角'
        '右下角'
        '左边'
        '右边'
        '上边'
        '下边'
        '中心')
    end
    object btnFont: TButton
      Left = 112
      Top = 60
      Width = 81
      Height = 21
      Caption = '字体(&F)'
      TabOrder = 2
      OnClick = btnFontClick
    end
  end
  object gbAddCheck: TGroupBox
    Left = 8
    Top = 68
    Width = 121
    Height = 61
    Caption = '附加处理(&A)'
    TabOrder = 1
    object cbInvert: TCheckBox
      Left = 8
      Top = 16
      Width = 110
      Height = 17
      Caption = '反向排序。'
      TabOrder = 0
    end
    object cbGroup: TCheckBox
      Left = 8
      Top = 35
      Width = 110
      Height = 17
      Caption = '控件分组处理。'
      TabOrder = 1
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 8
    Top = 216
  end
  object ColorDialog: TColorDialog
    Ctl3D = True
    Options = [cdAnyColor]
    Left = 40
    Top = 216
  end
end
