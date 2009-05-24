inherited CnUsesCleanerForm: TCnUsesCleanerForm
  Left = 335
  Top = 163
  BorderStyle = bsDialog
  Caption = '引用单元清理'
  ClientHeight = 365
  ClientWidth = 392
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object grpKind: TGroupBox
    Left = 8
    Top = 8
    Width = 377
    Height = 97
    Caption = '请选择处理内容(&N)'
    TabOrder = 0
    object rbCurrUnit: TRadioButton
      Left = 8
      Top = 18
      Width = 281
      Height = 17
      Caption = '当前编辑的单元(&1)。'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbCurrProject: TRadioButton
      Left = 8
      Top = 54
      Width = 281
      Height = 17
      Caption = '当前工程中的所有单元(&3)。'
      TabOrder = 2
      TabStop = True
    end
    object rbProjectGroup: TRadioButton
      Left = 8
      Top = 72
      Width = 281
      Height = 17
      Caption = '当前工程组中的所有单元(&4)。'
      TabOrder = 3
      TabStop = True
    end
    object rbOpenedUnits: TRadioButton
      Left = 8
      Top = 36
      Width = 281
      Height = 17
      Caption = '当前工程组中打开的单元(&2)。'
      TabOrder = 1
      TabStop = True
    end
  end
  object btnOK: TButton
    Left = 150
    Top = 336
    Width = 75
    Height = 21
    Caption = '处理(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 230
    Top = 336
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 310
    Top = 336
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object grpSettings: TGroupBox
    Left = 8
    Top = 112
    Width = 377
    Height = 217
    Caption = '清理设置(&S)'
    TabOrder = 1
    object lblIgnore: TLabel
      Left = 8
      Top = 104
      Width = 124
      Height = 13
      Caption = '强行清理以下引用单元:'
    end
    object lbl1: TLabel
      Left = 192
      Top = 104
      Width = 124
      Height = 13
      Caption = '强行忽略以下引用单元:'
    end
    object chkIgnoreInit: TCheckBox
      Left = 8
      Top = 16
      Width = 361
      Height = 17
      Caption = '忽略包含初始化节的引用单元。'
      TabOrder = 0
    end
    object chkIgnoreReg: TCheckBox
      Left = 8
      Top = 38
      Width = 361
      Height = 17
      Caption = '忽略包含 Register 过程的引用单元。'
      TabOrder = 1
    end
    object mmoClean: TMemo
      Left = 8
      Top = 120
      Width = 177
      Height = 89
      ScrollBars = ssVertical
      TabOrder = 4
    end
    object mmoIgnore: TMemo
      Left = 192
      Top = 120
      Width = 177
      Height = 89
      ScrollBars = ssVertical
      TabOrder = 5
    end
    object chkIgnoreNoSrc: TCheckBox
      Left = 8
      Top = 82
      Width = 361
      Height = 17
      Caption = '忽略无源码的引用单元。'
      TabOrder = 3
    end
    object chkIgnoreCompRef: TCheckBox
      Left = 8
      Top = 60
      Width = 361
      Height = 17
      Caption = '忽略窗体组件间接引用的单元。'
      TabOrder = 2
    end
  end
end
