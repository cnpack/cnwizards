object CnDTMainForm: TCnDTMainForm
  Left = 223
  Top = 108
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'DFM/Source Convert Tool'
  ClientHeight = 600
  ClientWidth = 925
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
    Top = 571
    Width = 124
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'CnPack IDE Wizards Tools'
  end
  object lblURL: TLabel
    Left = 168
    Top = 571
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
  object btnStart: TButton
    Left = 366
    Top = 568
    Width = 102
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Con&vert'
    TabOrder = 0
    OnClick = btnStartClick
  end
  object btnClose: TButton
    Left = 836
    Top = 568
    Width = 75
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = '&Close'
    TabOrder = 4
    OnClick = btnCloseClick
  end
  object btnAbout: TButton
    Left = 748
    Top = 568
    Width = 75
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = '&About'
    TabOrder = 3
    OnClick = btnAboutClick
  end
  object btnBinToTxt: TButton
    Left = 480
    Top = 568
    Width = 102
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Bin To &Text'
    TabOrder = 1
    OnClick = btnBinToTxtClick
  end
  object btnTxtToBin: TButton
    Left = 593
    Top = 568
    Width = 102
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Text To &Bin'
    TabOrder = 2
    OnClick = btnTxtToBinClick
  end
  object pgcMain: TPageControl
    Left = 8
    Top = 8
    Width = 902
    Height = 545
    ActivePage = tsDFM
    TabOrder = 5
    OnChange = pgcMainChange
    object tsDFM: TTabSheet
      Caption = 'DF&M Conversion'
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
        Width = 875
        Height = 153
        Caption = 'T&o Convert'
        TabOrder = 0
        object sbFile: TSpeedButton
          Left = 844
          Top = 36
          Width = 20
          Height = 20
          Anchors = [akTop, akRight]
          Caption = '...'
          OnClick = sbFileClick
        end
        object sbDir: TSpeedButton
          Left = 844
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
          Width = 811
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
          Width = 811
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
        Width = 875
        Height = 339
        Caption = 'Convert R&esult'
        TabOrder = 1
        object ListView: TListView
          Left = 10
          Top = 20
          Width = 854
          Height = 307
          Anchors = [akLeft, akTop, akRight, akBottom]
          Columns = <
            item
              Caption = 'FileName'
              Width = 720
            end
            item
              Caption = 'Result'
              Width = 100
            end>
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
      end
    end
    object tsSource: TTabSheet
      Caption = '&Source Conversion'
      ImageIndex = 1
      object grpSource: TGroupBox
        Left = 8
        Top = 8
        Width = 875
        Height = 153
        Caption = '&To Convert'
        TabOrder = 0
        object btnSrcOpen: TSpeedButton
          Left = 844
          Top = 36
          Width = 20
          Height = 20
          Anchors = [akTop, akRight]
          Caption = '...'
          OnClick = btnSrcOpenClick
        end
        object btnSrcBrowse: TSpeedButton
          Left = 844
          Top = 76
          Width = 20
          Height = 20
          Anchors = [akTop, akRight]
          Caption = '...'
          OnClick = btnSrcBrowseClick
        end
        object lblSrcConvertType: TLabel
          Left = 616
          Top = 122
          Width = 70
          Height = 13
          Caption = 'Convert T&ype:'
          FocusControl = cbbSrcConv
        end
        object lblSrcExt: TLabel
          Left = 256
          Top = 122
          Width = 95
          Height = 13
          Caption = 'Source File &Pattern:'
          FocusControl = cbbSrcFileType
        end
        object rbSrcFile: TRadioButton
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
        object edtSrcFile: TEdit
          Left = 26
          Top = 36
          Width = 811
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
        end
        object rbSrcDir: TRadioButton
          Left = 10
          Top = 58
          Width = 153
          Height = 17
          Caption = 'Convert in &Dir'
          TabOrder = 3
          OnClick = rbFileClick
        end
        object edtSrcDir: TEdit
          Left = 26
          Top = 76
          Width = 811
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
        end
        object chkSrcSubDirs: TCheckBox
          Left = 26
          Top = 100
          Width = 169
          Height = 17
          Caption = '&Include Sub-folders'
          TabOrder = 4
        end
        object chkSrcReadOnly: TCheckBox
          Left = 10
          Top = 122
          Width = 225
          Height = 17
          Caption = 'Process &Read-only Files'
          TabOrder = 5
        end
        object cbbSrcConv: TComboBox
          Left = 694
          Top = 118
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 6
          Items.Strings = (
            'To UTF-8'
            'To UTF-16'
            'To ANSI'
            'To CRLF (Windows)'
            'To LF (Unix/Mac)')
        end
        object cbbSrcFileType: TComboBox
          Left = 368
          Top = 118
          Width = 209
          Height = 21
          ItemHeight = 13
          TabOrder = 7
          Text = '.pas;.dpr;.dpk;.lpr;.inc'
          Items.Strings = (
            '.pas;.dpr;.dpk;.lpr;.inc'
            '.cpp;.c;.hpp;.h;.cxx;.cc;.hxx;.hh;.asm'
            '.dfm;.xfm;.lfm;.fmx'
            '.txt;.ini')
        end
      end
      object grpSrcResult: TGroupBox
        Left = 8
        Top = 168
        Width = 875
        Height = 339
        Caption = 'Convert R&esult'
        TabOrder = 1
        object lvSrcResult: TListView
          Left = 10
          Top = 20
          Width = 854
          Height = 307
          Anchors = [akLeft, akTop, akRight, akBottom]
          Columns = <
            item
              Caption = 'FileName'
              Width = 720
            end
            item
              Caption = 'Result'
              Width = 100
            end>
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
      end
    end
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
  object dlgOpen: TOpenDialog
    Filter = 
      'Pascal Source|*.pas;*.dpr;*.dpk;*.inc|C/C++ Source|*.cpp;*.c;*.c' +
      'c;*.hpp;*.h;*.hh|Text File|*.txt;*.ini|*.*|*.*'
    Left = 708
    Top = 80
  end
end
