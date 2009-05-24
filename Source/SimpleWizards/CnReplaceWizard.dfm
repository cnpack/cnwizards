object CnReplaceWizardForm: TCnReplaceWizardForm
  Left = 306
  Top = 155
  BorderStyle = bsDialog
  Caption = '批量文件替换工具'
  ClientHeight = 331
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tbOptions: TGroupBox
    Left = 8
    Top = 88
    Width = 193
    Height = 113
    Caption = '选项(&O)'
    TabOrder = 1
    object cbCaseSensitive: TCheckBox
      Left = 8
      Top = 16
      Width = 105
      Height = 17
      Caption = '区分大小写(&I)'
      TabOrder = 0
    end
    object cbWholeWord: TCheckBox
      Left = 8
      Top = 39
      Width = 129
      Height = 17
      Caption = '只匹配整个单词(&W)'
      TabOrder = 1
    end
    object cbRegEx: TCheckBox
      Left = 8
      Top = 63
      Width = 169
      Height = 17
      Caption = '查找内容支持正则表达式(&U)'
      TabOrder = 2
    end
    object cbANSICompatible: TCheckBox
      Left = 8
      Top = 86
      Width = 169
      Height = 17
      Caption = 'Ansi兼容方式查找(慢速)(&N)'
      TabOrder = 3
    end
  end
  object gbText: TGroupBox
    Left = 8
    Top = 8
    Width = 385
    Height = 73
    Caption = '文本(&T)'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 20
      Width = 66
      Height = 13
      Caption = '查找文本(&F):'
    end
    object Label2: TLabel
      Left = 8
      Top = 44
      Width = 54
      Height = 13
      Caption = '替换为(&P):'
    end
    object cbbSrc: TComboBox
      Left = 88
      Top = 16
      Width = 289
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
    object cbbDst: TComboBox
      Left = 88
      Top = 40
      Width = 289
      Height = 21
      ItemHeight = 13
      TabOrder = 1
    end
  end
  object rgReplaceStyle: TRadioGroup
    Left = 208
    Top = 88
    Width = 185
    Height = 113
    Caption = '范围(&A)'
    ItemIndex = 0
    Items.Strings = (
      '当前单元(&1)'
      '当前工程组所有文件(&2)'
      '当前工程所有文件(&3)'
      '当前打开的所有文件(&4)'
      '指定目录(&5)')
    TabOrder = 2
    OnClick = rgReplaceStyleClick
  end
  object gbDir: TGroupBox
    Left = 8
    Top = 208
    Width = 385
    Height = 89
    Caption = '指定目录(&L)'
    TabOrder = 3
    object Label3: TLabel
      Left = 8
      Top = 19
      Width = 55
      Height = 13
      Caption = '目录名(&D):'
      FocusControl = cbbDir
    end
    object Label4: TLabel
      Left = 8
      Top = 43
      Width = 66
      Height = 13
      Caption = '文件掩码(&E):'
      FocusControl = cbbMask
    end
    object btnSelectDir: TButton
      Left = 352
      Top = 16
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 2
      OnClick = btnSelectDirClick
    end
    object cbbDir: TComboBox
      Left = 88
      Top = 16
      Width = 257
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnDropDown = cbbDirDropDown
    end
    object cbbMask: TComboBox
      Left = 88
      Top = 40
      Width = 257
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        '.pas;.dpr'
        '.cpp;.c;.hpp;.h;.cxx;.cc;.hxx;.hh;.asm'
        '.pas;.dpr;cpp;.c;.hpp;.h;.cxx;.cc;.hxx;.hh;.asm')
    end
    object cbSubDirs: TCheckBox
      Left = 88
      Top = 64
      Width = 105
      Height = 17
      Caption = '查找子目录(&S)'
      TabOrder = 3
    end
  end
  object btnReplace: TButton
    Left = 158
    Top = 304
    Width = 75
    Height = 21
    Caption = '开始替换(&R)'
    TabOrder = 4
    OnClick = btnReplaceClick
  end
  object btnClose: TButton
    Left = 238
    Top = 304
    Width = 75
    Height = 21
    Cancel = True
    Caption = '关闭(&C)'
    ModalResult = 2
    TabOrder = 5
  end
  object btnHelp: TButton
    Left = 318
    Top = 304
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 6
    OnClick = btnHelpClick
  end
end
