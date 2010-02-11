inherited CnReplaceWizardForm: TCnReplaceWizardForm
  Left = 306
  Top = 155
  BorderStyle = bsDialog
  Caption = 'File Batch Replace Tools'
  ClientHeight = 331
  ClientWidth = 400
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tbOptions: TGroupBox
    Left = 8
    Top = 88
    Width = 193
    Height = 113
    Caption = '&Options'
    TabOrder = 1
    object cbCaseSensitive: TCheckBox
      Left = 8
      Top = 16
      Width = 105
      Height = 17
      Caption = 'Case Sens&itive'
      TabOrder = 0
    end
    object cbWholeWord: TCheckBox
      Left = 8
      Top = 39
      Width = 129
      Height = 17
      Caption = '&Whole Word Only'
      TabOrder = 1
    end
    object cbRegEx: TCheckBox
      Left = 8
      Top = 63
      Width = 169
      Height = 17
      Caption = 'Reg&ular Expression'
      TabOrder = 2
    end
    object cbANSICompatible: TCheckBox
      Left = 8
      Top = 86
      Width = 169
      Height = 17
      Caption = 'A&NSI Compatible (Slow)'
      TabOrder = 3
    end
  end
  object gbText: TGroupBox
    Left = 8
    Top = 8
    Width = 385
    Height = 73
    Caption = '&Text'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 20
      Width = 56
      Height = 13
      Caption = 'Search &For:'
    end
    object Label2: TLabel
      Left = 8
      Top = 44
      Width = 67
      Height = 13
      Caption = 'Re&place With:'
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
    Caption = 'R&ange'
    ItemIndex = 0
    Items.Strings = (
      'Current Unit(&1)'
      'Files in Project Group(&2)'
      'Files in Project(&3)'
      'All Opened Files(&4)'
      'In Directories(&5)')
    TabOrder = 2
    OnClick = rgReplaceStyleClick
  end
  object gbDir: TGroupBox
    Left = 8
    Top = 208
    Width = 385
    Height = 89
    Caption = 'Search Directory'
    TabOrder = 3
    object Label3: TLabel
      Left = 8
      Top = 19
      Width = 48
      Height = 13
      Caption = '&Directory:'
      FocusControl = cbbDir
    end
    object Label4: TLabel
      Left = 8
      Top = 43
      Width = 47
      Height = 13
      Caption = 'Fil&e Mask:'
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
      Caption = '&Search Sub-folders'
      TabOrder = 3
    end
  end
  object btnReplace: TButton
    Left = 158
    Top = 304
    Width = 75
    Height = 21
    Caption = '&Replace'
    TabOrder = 4
    OnClick = btnReplaceClick
  end
  object btnClose: TButton
    Left = 238
    Top = 304
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 5
  end
  object btnHelp: TButton
    Left = 318
    Top = 304
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 6
    OnClick = btnHelpClick
  end
end
