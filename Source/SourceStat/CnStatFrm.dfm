object CnStatForm: TCnStatForm
  Left = 233
  Top = 180
  BorderStyle = bsDialog
  Caption = '请选择统计目标'
  ClientHeight = 221
  ClientWidth = 376
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object rgStatStyle: TRadioGroup
    Left = 8
    Top = 8
    Width = 361
    Height = 73
    Caption = '统计目标(&A)'
    Columns = 2
    ItemIndex = 2
    Items.Strings = (
      '当前单元(&1)'
      '当前工程组所有文件(&2)'
      '当前工程所有文件(&3)'
      '当前打开的所有文件(&4)'
      '指定目录(&5)')
    TabOrder = 0
    OnClick = rgStatStyleClick
  end
  object gbDir: TGroupBox
    Left = 8
    Top = 88
    Width = 361
    Height = 97
    Caption = '指定目录(&L)'
    TabOrder = 1
    object Label3: TLabel
      Left = 8
      Top = 19
      Width = 61
      Height = 13
      Caption = '目 录 名(&D):'
      FocusControl = cbbDir
    end
    object Label4: TLabel
      Left = 8
      Top = 47
      Width = 66
      Height = 13
      Caption = '文件掩码(&E):'
      FocusControl = cbbMask
    end
    object btnSelectDir: TButton
      Left = 330
      Top = 16
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 3
      OnClick = btnSelectDirClick
    end
    object cbbDir: TComboBox
      Left = 88
      Top = 16
      Width = 235
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
    object cbbMask: TComboBox
      Left = 88
      Top = 44
      Width = 265
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
      Top = 70
      Width = 153
      Height = 17
      Caption = '包括子目录(&S)'
      TabOrder = 2
    end
  end
  object btnStat: TButton
    Left = 133
    Top = 192
    Width = 75
    Height = 21
    Caption = '统计(&R)'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 213
    Top = 192
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 293
    Top = 192
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 4
    OnClick = btnHelpClick
  end
end
