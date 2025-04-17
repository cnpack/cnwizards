object CnDTMainForm: TCnDTMainForm
  Left = 365
  Top = 194
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'DFM Convert Tool'
  ClientHeight = 493
  ClientWidth = 785
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
  object Label1: TLabel
    Left = 8
    Top = 464
    Width = 124
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'CnPack IDE Wizards Tools'
  end
  object lblURL: TLabel
    Left = 168
    Top = 464
    Width = 81
    Height = 13
    Cursor = crHandPoint
    Anchors = [akLeft, akBottom]
    Caption = 'www.cnpack.org'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lblURLClick
  end
  object bvl1: TBevel
    Left = 570
    Top = 456
    Width = 17
    Height = 25
    Shape = bsLeftLine
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 767
    Height = 153
    Anchors = [akLeft, akTop, akRight]
    Caption = '&To Convert'
    TabOrder = 0
    object sbFile: TSpeedButton
      Left = 736
      Top = 36
      Width = 20
      Height = 20
      Anchors = [akTop, akRight]
      Caption = '...'
      OnClick = sbFileClick
    end
    object sbDir: TSpeedButton
      Left = 736
      Top = 76
      Width = 20
      Height = 20
      Anchors = [akTop, akRight]
      Caption = '...'
      OnClick = sbDirClick
    end
    object rbFile: TRadioButton
      Left = 10
      Top = 18
      Width = 145
      Height = 17
      Caption = 'Convert a &File'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rbFileClick
    end
    object edtFile: TEdit
      Left = 26
      Top = 36
      Width = 703
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object rbDir: TRadioButton
      Left = 10
      Top = 58
      Width = 153
      Height = 17
      Caption = 'Convert in &Dir'
      TabOrder = 3
      OnClick = rbFileClick
    end
    object edtDir: TEdit
      Left = 26
      Top = 76
      Width = 703
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
    object cbSubDirs: TCheckBox
      Left = 26
      Top = 100
      Width = 169
      Height = 17
      Caption = '&Include Sub-folders'
      TabOrder = 4
    end
    object cbReadOnly: TCheckBox
      Left = 10
      Top = 122
      Width = 225
      Height = 17
      Caption = 'Process &Read-only Files'
      TabOrder = 5
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 168
    Width = 767
    Height = 282
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Convert R&esult'
    TabOrder = 1
    object ListView: TListView
      Left = 10
      Top = 20
      Width = 746
      Height = 250
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'FileName'
          Width = 600
        end
        item
          Caption = 'Result'
          Width = 90
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object btnStart: TButton
    Left = 290
    Top = 461
    Width = 90
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Con&vert'
    TabOrder = 2
    OnClick = btnStartClick
  end
  object btnClose: TButton
    Left = 700
    Top = 461
    Width = 75
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = '&Close'
    TabOrder = 6
    OnClick = btnCloseClick
  end
  object btnAbout: TButton
    Left = 612
    Top = 461
    Width = 75
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = '&About'
    TabOrder = 5
    OnClick = btnAboutClick
  end
  object btnBinToTxt: TButton
    Left = 392
    Top = 461
    Width = 90
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Bin To &Text'
    TabOrder = 3
    OnClick = btnBinToTxtClick
  end
  object btnTxtToBin: TButton
    Left = 493
    Top = 461
    Width = 90
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Text To &Bin'
    TabOrder = 4
    OnClick = btnTxtToBinClick
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '*.DFM'
    Filter = 'Delphi/C++Builder Forms (*.DFM)|*.DFM'
    Left = 144
    Top = 112
  end
  object CnLangManager: TCnLangManager
    LanguageStorage = CnHashLangFileStorage
    TranslationMode = tmByComponents
    AutoTransOptions = [atApplication, atForms, atDataModules]
    Left = 328
    Top = 112
  end
  object CnHashLangFileStorage: TCnHashLangFileStorage
    StorageMode = smByDirectory
    LanguagePath = '\'
    FileName = 'Dfm6To5.txt'
    Languages = <>
    ListLength = 1024
    IncSize = 2
    Left = 368
    Top = 112
  end
  object CnLangTranslator1: TCnLangTranslator
    Left = 408
    Top = 112
  end
end
