inherited CommentCropForm: TCommentCropForm
  Left = 235
  Top = 155
  BorderStyle = bsDialog
  Caption = 'Delete Comments'
  ClientHeight = 354
  ClientWidth = 545
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object gbKind: TGroupBox
    Left = 320
    Top = 8
    Width = 217
    Height = 209
    Caption = '&Select Content to Crop'
    TabOrder = 1
    object rbSelEdit: TRadioButton
      Left = 8
      Top = 24
      Width = 200
      Height = 17
      Caption = 'Current Selection(&1).'
      TabOrder = 0
      TabStop = True
      OnClick = UpdateClick
    end
    object rbCurrUnit: TRadioButton
      Left = 8
      Top = 54
      Width = 200
      Height = 17
      Caption = 'Current Unit(&2).'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = UpdateClick
    end
    object rbOpenedUnits: TRadioButton
      Left = 8
      Top = 85
      Width = 200
      Height = 17
      Caption = 'All Opened Units(&3).'
      TabOrder = 2
      TabStop = True
      OnClick = UpdateClick
    end
    object rbCurrProject: TRadioButton
      Left = 8
      Top = 115
      Width = 200
      Height = 17
      Caption = 'All Units in Current Project(&4).'
      TabOrder = 3
      TabStop = True
      OnClick = UpdateClick
    end
    object rbProjectGroup: TRadioButton
      Left = 8
      Top = 146
      Width = 200
      Height = 17
      Caption = 'All Units in Current ProjectGroup(&5).'
      TabOrder = 4
      TabStop = True
      OnClick = UpdateClick
    end
    object rbDirectory: TRadioButton
      Left = 8
      Top = 176
      Width = 200
      Height = 17
      Caption = 'In Directories(&6).'
      TabOrder = 5
      TabStop = True
      OnClick = UpdateClick
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 305
    Height = 209
    Caption = '&Crop Settings'
    TabOrder = 0
    object Label1: TLabel
      Left = 24
      Top = 136
      Width = 154
      Height = 13
      Caption = '(Separate Strings using Comma)'
    end
    object rbCropComment: TRadioButton
      Left = 8
      Top = 18
      Width = 293
      Height = 17
      Caption = 'Delete All Comment Block.'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbExAscii: TRadioButton
      Left = 8
      Top = 38
      Width = 293
      Height = 17
      Caption = 'Only Delete Extended ASCII Chars.'
      TabOrder = 1
    end
    object chkCropDirective: TCheckBox
      Left = 8
      Top = 58
      Width = 293
      Height = 17
      Caption = 'Crop Delphi Compiler Directive(Not Recommended).'
      Enabled = False
      TabOrder = 2
    end
    object chkCropTodo: TCheckBox
      Left = 8
      Top = 78
      Width = 293
      Height = 17
      Caption = 'Crop Todo List Items.'
      TabOrder = 3
    end
    object chkReserve: TCheckBox
      Left = 8
      Top = 118
      Width = 293
      Height = 17
      Caption = 'Reserve Block Comment {...} and /*...*/ Beginning with:'
      TabOrder = 5
      OnClick = chkReserveClick
    end
    object edReserveStr: TEdit
      Left = 24
      Top = 154
      Width = 273
      Height = 21
      TabOrder = 6
    end
    object chkCropProjectSrc: TCheckBox
      Left = 8
      Top = 98
      Width = 293
      Height = 17
      Caption = 'Crop Project Source.'
      TabOrder = 4
    end
    object chkMergeBlank: TCheckBox
      Left = 8
      Top = 181
      Width = 286
      Height = 17
      Caption = 'Merge Continuous Blank Lines to One.'
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = chkReserveClick
    end
  end
  object btnOK: TButton
    Left = 302
    Top = 323
    Width = 75
    Height = 21
    Caption = 'Pr&ocess'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 382
    Top = 323
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object btnHelp: TButton
    Left = 462
    Top = 323
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 5
    OnClick = btnHelpClick
  end
  object grpDir: TGroupBox
    Left = 8
    Top = 224
    Width = 529
    Height = 89
    Caption = 'Search Directory'
    TabOrder = 2
    object lbl1: TLabel
      Left = 8
      Top = 19
      Width = 48
      Height = 13
      Caption = '&Directory:'
      FocusControl = cbbDir
    end
    object lbl2: TLabel
      Left = 8
      Top = 43
      Width = 47
      Height = 13
      Caption = 'Fil&e Mask:'
      FocusControl = cbbMask
    end
    object btnSelectDir: TButton
      Left = 496
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
      Width = 401
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
    object cbbMask: TComboBox
      Left = 88
      Top = 40
      Width = 401
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      Items.Strings = (
        '.pas;.dpr'
        '.cpp;.c;.hpp;.h;.cxx;.cc;.hxx;.hh;.asm'
        '.pas;.dpr;cpp;.c;.hpp;.h;.cxx;.cc;.hxx;.hh;.asm')
    end
    object chkSubDirs: TCheckBox
      Left = 88
      Top = 64
      Width = 105
      Height = 17
      Caption = '&Search Sub-folders'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
  end
end
