inherited CnStatForm: TCnStatForm
  Left = 233
  Top = 180
  BorderStyle = bsDialog
  Caption = 'Select Target for Statistic'
  ClientHeight = 221
  ClientWidth = 376
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object rgStatStyle: TRadioGroup
    Left = 8
    Top = 8
    Width = 361
    Height = 73
    Caption = 'T&arget'
    Columns = 2
    ItemIndex = 2
    Items.Strings = (
      'Current Unit(&1)'
      'Files in ProjectGroup(&2)'
      'Files in Project(&3)'
      'All Opened Files(&4)'
      'Specified Folder(&5)')
    TabOrder = 0
    OnClick = rgStatStyleClick
  end
  object gbDir: TGroupBox
    Left = 8
    Top = 88
    Width = 361
    Height = 97
    Caption = 'Specify Fo&lder'
    TabOrder = 1
    object Label3: TLabel
      Left = 8
      Top = 19
      Width = 64
      Height = 13
      Caption = 'Fol&der Name:'
      FocusControl = cbbDir
    end
    object Label4: TLabel
      Left = 8
      Top = 47
      Width = 47
      Height = 13
      Caption = 'Fil&e Mask:'
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
      Caption = 'Include &Sub-folders'
      TabOrder = 2
    end
  end
  object btnStat: TButton
    Left = 133
    Top = 192
    Width = 75
    Height = 21
    Caption = 'Ca&lculate'
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
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 293
    Top = 192
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
end
