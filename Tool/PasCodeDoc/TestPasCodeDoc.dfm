object FormPasDoc: TFormPasDoc
  Left = 198
  Top = 137
  BorderStyle = bsDialog
  Caption = 'Pascal Document'
  ClientHeight = 572
  ClientWidth = 986
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pgcMain: TPageControl
    Left = 8
    Top = 8
    Width = 961
    Height = 553
    ActivePage = tsParse
    TabOrder = 0
    object tsParse: TTabSheet
      Caption = 'Parse'
      object btnExtractFromFile: TButton
        Left = 16
        Top = 16
        Width = 305
        Height = 25
        Caption = 'Open a Pas to Extract'
        TabOrder = 0
        OnClick = btnExtractFromFileClick
      end
      object btnCheckParamList: TButton
        Left = 16
        Top = 56
        Width = 305
        Height = 25
        Caption = 'Check Params List'
        TabOrder = 1
        OnClick = btnCheckParamListClick
      end
      object btnGenParamList: TButton
        Left = 16
        Top = 96
        Width = 241
        Height = 25
        Caption = 'Generate Params List'
        TabOrder = 2
        OnClick = btnGenParamListClick
      end
      object chkModFile: TCheckBox
        Left = 264
        Top = 100
        Width = 57
        Height = 17
        Caption = 'Modify'
        TabOrder = 3
      end
      object tvPas: TTreeView
        Left = 16
        Top = 144
        Width = 305
        Height = 313
        Indent = 19
        TabOrder = 4
        OnDblClick = tvPasDblClick
      end
      object btnCombineInterface: TButton
        Left = 16
        Top = 480
        Width = 305
        Height = 25
        Caption = 'Combine Interface from Directory'
        TabOrder = 5
        OnClick = btnCombineInterfaceClick
      end
      object mmoResult: TMemo
        Left = 336
        Top = 24
        Width = 601
        Height = 481
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 6
      end
    end
    object tsGenerate: TTabSheet
      Caption = 'CnCrypto Generate'
      ImageIndex = 1
      object lblTemplateDir: TLabel
        Left = 16
        Top = 16
        Width = 92
        Height = 13
        Caption = 'Template Directory:'
      end
      object lblSourceDir: TLabel
        Left = 16
        Top = 48
        Width = 82
        Height = 13
        Caption = 'Source Directory:'
      end
      object lblDestDir: TLabel
        Left = 16
        Top = 80
        Width = 113
        Height = 13
        Caption = 'HTML Output Directory:'
      end
      object lbl1: TLabel
        Left = 656
        Top = 56
        Width = 112
        Height = 13
        Caption = 'Crypto Source Directory'
      end
      object lbl2: TLabel
        Left = 656
        Top = 88
        Width = 100
        Height = 13
        Caption = 'Crypto Help Directory'
      end
      object btnConvertDirectory: TButton
        Left = 16
        Top = 120
        Width = 97
        Height = 25
        Caption = 'Convert Directory'
        TabOrder = 0
        Visible = False
        OnClick = btnConvertDirectoryClick
      end
      object edtTemplateDir: TEdit
        Left = 152
        Top = 16
        Width = 385
        Height = 21
        TabOrder = 1
        Text = '..\..\..\cnvcl\Doc\Template'
      end
      object edtSourceDir: TEdit
        Left = 152
        Top = 48
        Width = 385
        Height = 21
        TabOrder = 2
        Text = '..\..\..\cnvcl\Source\Crypto'
      end
      object edtOutputDir: TEdit
        Left = 152
        Top = 80
        Width = 385
        Height = 21
        TabOrder = 3
        Text = '.'
      end
      object btnTemplateBrowse: TButton
        Left = 552
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Browse'
        TabOrder = 4
        OnClick = btnTemplateBrowseClick
      end
      object btnSourceBrowse: TButton
        Left = 552
        Top = 48
        Width = 75
        Height = 25
        Caption = 'Browse'
        TabOrder = 5
        OnClick = btnSourceBrowseClick
      end
      object btnOutputBrowse: TButton
        Left = 552
        Top = 80
        Width = 75
        Height = 25
        Caption = 'Browse'
        TabOrder = 6
        OnClick = btnOutputBrowseClick
      end
      object btnCryptoGen: TButton
        Left = 328
        Top = 120
        Width = 209
        Height = 25
        Caption = 'Crypto Generate'
        TabOrder = 7
        OnClick = btnCryptoGenClick
      end
      object btnCryptoGenAFile: TButton
        Left = 152
        Top = 120
        Width = 169
        Height = 25
        Caption = 'Crypto Generate One File'
        TabOrder = 8
        OnClick = btnCryptoGenAFileClick
      end
    end
  end
  object dlgOpen1: TOpenDialog
    Left = 216
    Top = 8
  end
  object dlgSave1: TSaveDialog
    Left = 184
    Top = 8
  end
end
