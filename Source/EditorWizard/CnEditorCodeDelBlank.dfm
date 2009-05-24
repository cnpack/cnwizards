object CnDelBlankForm: TCnDelBlankForm
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = '删除空行'
  ClientHeight = 170
  ClientWidth = 281
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
  object btnOK: TButton
    Left = 34
    Top = 140
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 116
    Top = 140
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 198
    Top = 140
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 265
    Height = 57
    Caption = '请选择处理内容(&N)'
    TabOrder = 0
    object rbSel: TRadioButton
      Left = 8
      Top = 16
      Width = 249
      Height = 17
      Caption = '当前编辑的选择区(&1)。'
      TabOrder = 0
    end
    object rbAll: TRadioButton
      Left = 8
      Top = 32
      Width = 249
      Height = 17
      Caption = '当前编辑的单元(&2)。'
      TabOrder = 1
    end
  end
  object grp2: TGroupBox
    Left = 8
    Top = 72
    Width = 265
    Height = 57
    Caption = '处理选项(&O)'
    TabOrder = 1
    object rbAllLine: TRadioButton
      Left = 8
      Top = 32
      Width = 249
      Height = 17
      Caption = '删除所有空行(&D)。'
      TabOrder = 1
    end
    object rbMulti: TRadioButton
      Left = 8
      Top = 16
      Width = 249
      Height = 17
      Caption = '将多行连续空行合并为一行(&M)。'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
  end
end
