inherited CnReplaceWizardForm: TCnReplaceWizardForm
  Left = 306
  Top = 155
  BorderStyle = bsDialog
  Caption = 'File Batch Replace Tools'
  ClientHeight = 366
  ClientWidth = 410
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tbOptions: TGroupBox
    Left = 8
    Top = 88
    Width = 201
    Height = 145
    Caption = '&Options'
    TabOrder = 1
    object cbCaseSensitive: TCheckBox
      Left = 24
      Top = 32
      Width = 169
      Height = 17
      Caption = 'Case Sens&itive'
      TabOrder = 1
    end
    object cbWholeWord: TCheckBox
      Left = 24
      Top = 50
      Width = 169
      Height = 17
      Caption = '&Whole Word Only'
      TabOrder = 2
    end
    object cbRegEx: TCheckBox
      Left = 24
      Top = 68
      Width = 169
      Height = 17
      Caption = 'Reg&ular Expression'
      TabOrder = 3
    end
    object cbANSICompatible: TCheckBox
      Left = 24
      Top = 86
      Width = 169
      Height = 17
      Caption = 'A&NSI Compatible (Slow)'
      TabOrder = 4
    end
    object rbNormal: TRadioButton
      Left = 8
      Top = 16
      Width = 185
      Height = 17
      Caption = 'Nor&mal Mode'
      TabOrder = 0
      OnClick = rbNormalClick
    end
    object rbRegExpr: TRadioButton
      Left = 8
      Top = 104
      Width = 185
      Height = 17
      Caption = 'Use TRegExpr to Replace'
      TabOrder = 5
      OnClick = rbNormalClick
    end
    object chkUseSub: TCheckBox
      Left = 24
      Top = 120
      Width = 169
      Height = 17
      Caption = 'Use &Substitution'
      TabOrder = 6
    end
  end
  object gbText: TGroupBox
    Left = 8
    Top = 8
    Width = 393
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
      Width = 297
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
    object cbbDst: TComboBox
      Left = 88
      Top = 40
      Width = 297
      Height = 21
      ItemHeight = 13
      TabOrder = 1
    end
  end
  object rgReplaceStyle: TRadioGroup
    Left = 216
    Top = 88
    Width = 185
    Height = 145
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
    Top = 240
    Width = 393
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
      Left = 360
      Top = 16
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = btnSelectDirClick
    end
    object cbbDir: TComboBox
      Left = 88
      Top = 16
      Width = 265
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnDropDown = cbbDirDropDown
    end
    object cbbMask: TComboBox
      Left = 88
      Top = 40
      Width = 265
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      Items.Strings = (
        '.pas;.dpr'
        '.cpp;.c;.hpp;.h;.cxx;.cc;.hxx;.hh;.asm'
        '.pas;.dpr;cpp;.c;.hpp;.h;.cxx;.cc;.hxx;.hh;.asm')
    end
    object cbSubDirs: TCheckBox
      Left = 88
      Top = 64
      Width = 265
      Height = 17
      Caption = '&Search Sub-folders'
      TabOrder = 3
    end
  end
  object btnReplace: TButton
    Left = 166
    Top = 336
    Width = 75
    Height = 21
    Caption = '&Replace'
    TabOrder = 4
    OnClick = btnReplaceClick
  end
  object btnClose: TButton
    Left = 246
    Top = 336
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 5
  end
  object btnHelp: TButton
    Left = 326
    Top = 336
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 6
    OnClick = btnHelpClick
  end
end
