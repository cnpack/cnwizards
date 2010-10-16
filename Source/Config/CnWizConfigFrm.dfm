inherited CnWizConfigForm: TCnWizConfigForm
  Left = 237
  Top = 119
  Width = 528
  Height = 475
  BorderIcons = [biSystemMenu]
  BorderWidth = 6
  Caption = 'CnPack IDE Wizards Settings'
  Constraints.MinHeight = 471
  Constraints.MinWidth = 528
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 508
    Height = 407
    ActivePage = tsWizards
    Align = alClient
    TabOrder = 0
    object tsWizards: TTabSheet
      BorderWidth = 1
      Caption = '&Wizard Settings'
      object lbWizards: TListBox
        Left = 0
        Top = 0
        Width = 317
        Height = 377
        Align = alClient
        ItemHeight = 45
        Style = lbOwnerDrawFixed
        TabOrder = 0
        OnClick = lbWizardsClick
        OnDblClick = lbWizardsDblClick
        OnDrawItem = lbWizardsDrawItem
      end
      object pnlWizard: TPanel
        Left = 317
        Top = 0
        Width = 181
        Height = 377
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object lblWizardName: TLabel
          Left = 48
          Top = 8
          Width = 129
          Height = 36
          AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
          WordWrap = True
        end
        object bvlWizard: TBevel
          Left = 8
          Top = 40
          Width = 169
          Height = 10
          Shape = bsBottomLine
        end
        object Label1: TLabel
          Left = 8
          Top = 56
          Width = 42
          Height = 13
          Caption = 'Author:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblWizardAuthor: TLabel
          Left = 8
          Top = 72
          Width = 169
          Height = 53
          AutoSize = False
          WordWrap = True
        end
        object lblWizardComment: TLabel
          Left = 8
          Top = 184
          Width = 169
          Height = 68
          AutoSize = False
          WordWrap = True
        end
        object Label3: TLabel
          Left = 8
          Top = 168
          Width = 64
          Height = 13
          Caption = 'Comments:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label4: TLabel
          Left = 8
          Top = 256
          Width = 53
          Height = 13
          Caption = 'ShortCut:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label5: TLabel
          Left = 8
          Top = 304
          Width = 50
          Height = 13
          Caption = 'Settings:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblWizardKind: TLabel
          Left = 8
          Top = 144
          Width = 3
          Height = 13
        end
        object Label7: TLabel
          Left = 8
          Top = 128
          Width = 31
          Height = 13
          Caption = 'Type:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object imgIcon: TImage
          Left = 8
          Top = 8
          Width = 32
          Height = 32
        end
        object HotKeyWizard: THotKey
          Left = 8
          Top = 272
          Width = 169
          Height = 19
          HotKey = 0
          InvalidKeys = [hcNone, hcShift]
          Modifiers = []
          TabOrder = 0
          OnExit = HotKeyWizardExit
        end
        object cbWizardActive: TCheckBox
          Left = 8
          Top = 320
          Width = 169
          Height = 17
          Caption = 'Enabled'
          TabOrder = 1
          OnClick = cbWizardActiveClick
        end
        object btnConfig: TButton
          Left = 7
          Top = 344
          Width = 75
          Height = 21
          Caption = '&Settings'
          TabOrder = 2
          OnClick = btnConfigClick
        end
        object btnSort: TButton
          Left = 99
          Top = 344
          Width = 75
          Height = 21
          Caption = '&Advanced'
          TabOrder = 3
          OnClick = btnSortClick
        end
      end
    end
    object tsPropEditor: TTabSheet
      BorderWidth = 1
      Caption = 'Property E&ditor'
      ImageIndex = 2
      object Panel1: TPanel
        Left = 317
        Top = 0
        Width = 181
        Height = 377
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object lblDesignEditorName: TLabel
          Left = 48
          Top = 8
          Width = 129
          Height = 31
          AutoSize = False
          Caption = 'lblDesignEditorName'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
          WordWrap = True
        end
        object Bevel1: TBevel
          Left = 8
          Top = 40
          Width = 169
          Height = 10
          Shape = bsBottomLine
        end
        object Label11: TLabel
          Left = 8
          Top = 56
          Width = 42
          Height = 13
          Caption = 'Author:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblDesignEditorAuthor: TLabel
          Left = 8
          Top = 72
          Width = 169
          Height = 49
          AutoSize = False
          Caption = 'lblDesignEditorAuthor'
          WordWrap = True
        end
        object lblDesignEditorComment: TLabel
          Left = 8
          Top = 184
          Width = 169
          Height = 89
          AutoSize = False
          Caption = 'lblDesignEditorComment'
          WordWrap = True
        end
        object Label14: TLabel
          Left = 8
          Top = 168
          Width = 64
          Height = 13
          Caption = 'Comments:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label16: TLabel
          Left = 8
          Top = 304
          Width = 50
          Height = 13
          Caption = 'Settings:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblDesignEditorKind: TLabel
          Left = 8
          Top = 144
          Width = 90
          Height = 13
          Caption = 'lblDesignEditorKind'
        end
        object Label18: TLabel
          Left = 8
          Top = 128
          Width = 31
          Height = 13
          Caption = 'Type:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Image1: TImage
          Left = 8
          Top = 8
          Width = 32
          Height = 32
          Picture.Data = {
            055449636F6E0000010001002020100000000000E80200001600000028000000
            2000000040000000010004000000000080020000000000000000000000000000
            0000000000000000000080000080000000808000800000008000800080800000
            C0C0C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
            FFFFFF0000088888888888888888888888880000000000000000000000000000
            00080000000FFFFFFF8FFFFFFF8FFFFFFF080000000FFFFFFF8FFFFFFF8FFFFF
            FF080000000FFFFFFF8FFFFFFF8FFFFFFF080000000888888888888088888888
            88080000000FFFFFFF8FFFFF008FFFFFFF080000000FFFFFFF8FFFFF0B007FFF
            FF080000000FFFFFFF8FFFFFF08807FFFF080000000888888888888880BB8088
            88080000000FFFFFFF8FFFFFFF0FB807FF0800000007777777877777FF80FB80
            7F08000000000000000000077F8F0FB8070000000066666666666660888880FB
            8008000000E00600600600607F8FFF0F0708000000EE06E06E06E0607F8FFFF0
            FB80000000E66666666666607F8FFFFF0FB8000000E006006006006088888888
            80FB800000EE06E06E06E0607F8FFFFFFF0FB80000E66666666666607F8FFFFF
            FF00F00000E00600600600607F8FFFFFFF0800F000EE06E06E06E06088888888
            8808000000E66666666666607F8FFFFFFF08000000E00600600600607F8FFFFF
            FF08000000EE06E06E06E0607F8FFFFFFF08000000E666666666666000000000
            0000000000E6666666666660800000000000000000E07FFFFFFFF06080000000
            0000000000E0777777777060800000000000000000E000000000006080000000
            0000000000EEEEEEEEEEEE600000000000000000000000000000000000000000
            00000000E000000FC000000FC000000FC000000FC000000FC000000FC000000F
            C000000FC000000FC000000FC000000FC000000FC000000F800000078000000B
            8000000D80000005800000018000000180000001800000008000000C8000000F
            8000000F8000000F8000001F80007FFF80007FFF80007FFF80007FFF8000FFFF
            C001FFFF}
        end
        object cbDesignEditorActive: TCheckBox
          Left = 8
          Top = 320
          Width = 169
          Height = 17
          Caption = 'Enabled'
          TabOrder = 0
          OnClick = cbDesignEditorActiveClick
        end
        object btnDesignEditorConfig: TButton
          Left = 7
          Top = 344
          Width = 75
          Height = 21
          Caption = '&Settings'
          TabOrder = 1
          OnClick = btnDesignEditorConfigClick
        end
        object btnDesignEditorCustomize: TButton
          Left = 99
          Top = 344
          Width = 75
          Height = 21
          Caption = 'Custo&mize'
          TabOrder = 2
          OnClick = btnDesignEditorCustomizeClick
        end
      end
      object lbDesignEditors: TListBox
        Left = 0
        Top = 0
        Width = 317
        Height = 377
        Align = alClient
        ItemHeight = 32
        Style = lbOwnerDrawFixed
        TabOrder = 0
        OnClick = lbDesignEditorsClick
        OnDblClick = lbDesignEditorsDblClick
        OnDrawItem = lbDesignEditorsDrawItem
      end
    end
    object tsEnvOption: TTabSheet
      Caption = '&Environment Settings'
      ImageIndex = 1
      object grpOthers: TGroupBox
        Left = 8
        Top = 230
        Width = 481
        Height = 139
        Caption = 'Othe&rs'
        TabOrder = 3
        object Label2: TLabel
          Left = 8
          Top = 16
          Width = 3
          Height = 13
        end
        object btnUserDir: TSpeedButton
          Left = 450
          Top = 101
          Width = 23
          Height = 22
          Flat = True
          Glyph.Data = {
            36040000424D3604000000000000360000002800000010000000100000000100
            2000000000000004000000000000000000000000000000000000FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00187B9C00187B9C00187B9C00187B9C00187B9C00187B9C00187B9C00187B
            9C00187B9C00187B9C00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF001894
            C6001894C6001894C6001894C6001894C6001894C6001894C6001894C6001894
            C6001894C6001894C600187B9C00FF00FF00FF00FF00FF00FF00189CC600189C
            C6009CFFFF006BD6FF006BD6FF006BD6FF006BD6FF006BD6FF006BD6FF006BD6
            FF006BD6FF006BD6FF00299CBD000873A500FF00FF00FF00FF00189CC600189C
            C6007BE7F7009CFFFF007BE7FF007BE7FF007BE7FF007BE7FF007BE7FF007BE7
            FF007BE7FF007BDEFF0042B5DE000873A500FF00FF00FF00FF00189CC60021A5
            CE0039BDD6009CFFFF0084EFFF0084EFFF0084EFFF0084EFFF0084EFFF0084EF
            FF0084EFFF0084E7FF0042BDEF000873A500FF00FF00FF00FF00189CC60042B5
            E70021A5CE00A5FFFF0094F7FF0094F7FF0094F7FF0094F7FF0094F7FF0094F7
            FF0094F7FF0094F7FF0052BDE7005ABDCE000873A500FF00FF00189CC6006BD6
            FF00189CC6008CF7F7009CFFFF009CFFFF009CFFFF009CFFFF009CFFFF009CFF
            FF009CFFFF009CFFFF005AC6FF0094FFFF000873A500FF00FF00189CC60084D6
            FF00189CC6006BBDDE00FFFFFF00FFFFFF00F7FFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF0084E7FF00FFFFFF000873A500FF00FF00189CC60084EF
            FF004AC6E700189CC600189CC600189CC600189CC600189CC600189CC600189C
            C600189CC600189CC600189CC600189CC6000873A500FF00FF00189CC6009CF7
            FF008CF7FF008CF7FF008CF7FF008CF7FF008CF7FF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00189CC600187B9C00FF00FF00FF00FF00189CC600FFFF
            FF009CFFFF009CFFFF009CFFFF009CFFFF00FFFFFF00189CC600189CC600189C
            C600189CC600189CC600189CC600FF00FF00FF00FF00FF00FF00FF00FF0021A5
            CE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00189CC600FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF0021A5CE0021A5CE0021A5CE0021A5CE00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
          OnClick = btnUserDirClick
        end
        object chkUseToolsMenu: TCheckBox
          Left = 8
          Top = 16
          Width = 273
          Height = 17
          Caption = 'Integrate CnPack Menu into Tools Menu.'
          TabOrder = 0
        end
        object chkUserDir: TCheckBox
          Left = 8
          Top = 79
          Width = 273
          Height = 17
          Caption = 'Customize User Data Folder(Need Restart):'
          TabOrder = 3
          OnClick = UpdateControls
        end
        object edtUserDir: TEdit
          Left = 24
          Top = 102
          Width = 422
          Height = 21
          TabOrder = 4
        end
        object chkFixThreadLocale: TCheckBox
          Left = 8
          Top = 58
          Width = 457
          Height = 17
          Caption = 'Use SetThreadLocale to fix encode problem under Vista / Win7.'
          TabOrder = 2
        end
        object chkUseOneCPUCore: TCheckBox
          Left = 8
          Top = 37
          Width = 273
          Height = 17
          Caption = 'Set IDE to run in CPU 0 single core.'
          TabOrder = 1
        end
      end
      object gbHintWnd: TGroupBox
        Left = 8
        Top = 8
        Width = 481
        Height = 65
        Caption = 'Hi&nt'
        TabOrder = 0
        object cbShowWizComment: TCheckBox
          Left = 8
          Top = 18
          Width = 281
          Height = 17
          Caption = 'Show Hint Form for the First Time'
          TabOrder = 0
        end
        object btnResetWizComment: TButton
          Left = 296
          Top = 18
          Width = 177
          Height = 21
          Anchors = [akTop, akRight]
          Caption = 'Reo&pen All Hint Forms'
          TabOrder = 1
          OnClick = btnResetWizCommentClick
        end
        object cbShowHint: TCheckBox
          Left = 8
          Top = 40
          Width = 281
          Height = 17
          Caption = 'Show ToolTips'
          TabOrder = 2
          OnClick = cbShowHintClick
        end
      end
      object gbUpdate: TGroupBox
        Left = 8
        Top = 79
        Width = 481
        Height = 90
        Caption = 'Up&grade Settings'
        TabOrder = 1
        object rbUpgradeDisabled: TRadioButton
          Left = 8
          Top = 16
          Width = 280
          Height = 17
          Caption = 'Disable Upgrade Prompt'
          TabOrder = 0
          OnClick = UpdateControls
        end
        object rbUpgradeAll: TRadioButton
          Left = 8
          Top = 38
          Width = 280
          Height = 17
          Caption = 'Prompt when New Version Available'
          Checked = True
          TabOrder = 2
          TabStop = True
          OnClick = UpdateControls
        end
        object cbUpgradeReleaseOnly: TCheckBox
          Left = 24
          Top = 61
          Width = 280
          Height = 17
          Caption = 'Ignore Beta Version'
          TabOrder = 3
        end
        object btnCheckUpgrade: TButton
          Left = 296
          Top = 16
          Width = 177
          Height = 21
          Anchors = [akTop, akRight]
          Caption = 'Check for New &Upgrade Now'
          TabOrder = 1
          OnClick = btnCheckUpgradeClick
        end
      end
      object grpTools: TGroupBox
        Left = 8
        Top = 175
        Width = 481
        Height = 49
        Caption = 'Auxiliary &Tools'
        TabOrder = 2
        object btnExportImagelist: TButton
          Left = 8
          Top = 16
          Width = 137
          Height = 21
          Anchors = [akTop, akRight]
          Caption = 'Export IDE I&mage List'
          TabOrder = 0
          OnClick = btnExportImagelistClick
        end
        object btnExportActionList: TButton
          Left = 156
          Top = 16
          Width = 153
          Height = 21
          Anchors = [akTop, akRight]
          Caption = 'Export IDE &Action Names'
          TabOrder = 1
          OnClick = btnExportActionListClick
        end
        object btnExportComponents: TButton
          Left = 320
          Top = 16
          Width = 153
          Height = 21
          Anchors = [akTop, akRight]
          Caption = 'Export Controls &List'
          TabOrder = 2
          OnClick = btnExportComponentsClick
        end
      end
    end
  end
  object pnlButton: TPanel
    Left = 0
    Top = 407
    Width = 508
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnHelp: TButton
      Left = 433
      Top = 8
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Help'
      TabOrder = 2
      OnClick = btnHelpClick
    end
    object btnOK: TButton
      Left = 273
      Top = 8
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 353
      Top = 8
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object dlgSaveActionList: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text Files(*.txt)|*.txt|Any File(*.*)|*.*'
    Left = 8
    Top = 403
  end
  object ilEnable: TImageList
    Left = 456
    Top = 367
    Bitmap = {
      494C010102000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000008000000080000080000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      8000000080008080800000000000000000000000000000000000000000000000
      FF00808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000000080
      0000008000000080000000800000800000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      80000000800000008000808080000000000000000000000000000000FF000000
      8000000080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000008000000080
      0000008000000080000000800000008000008000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      800000008000000080000000800080808000000000000000FF00000080000000
      8000000080000000800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008000000000800000008000000080
      000000FF00000080000000800000008000000080000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF00000080000000800000008000000080008080800000008000000080000000
      8000000080000000800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000800000008000000080000000FF
      00000000000000FF000000800000008000000080000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000800000008000000080000000800000008000000080000000
      8000000080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FF00000080000000FF00000000
      0000000000000000000000FF0000008000000080000000800000800000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000008000000080000000800000008000000080000000
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FF0000000000000000
      000000000000000000000000000000FF00000080000000800000008000008000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000008000000080000000800000008000000080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FF000000800000008000000080
      0000800000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF00000080000000800000008000000080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FF0000008000000080
      0000008000008000000000000000000000000000000000000000000000000000
      0000000000000000FF0000008000000080000000800000008000000080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FF00000080
      0000008000000080000080000000000000000000000000000000000000000000
      00000000FF000000800000008000000080008080800000008000000080000000
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      0000008000000080000000800000800000000000000000000000000000000000
      FF0000008000000080000000800080808000000000000000FF00000080000000
      8000000080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FF00000080000000800000800000000000000000000000000000000000
      FF000000800000008000808080000000000000000000000000000000FF000000
      8000000080000000800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000800000008000000000000000000000000000000000
      00000000FF000000800000000000000000000000000000000000000000000000
      FF00000080000000800000008000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FF0000C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF00000080000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF00000000F3FFE7FF00000000
      E1FFC3E700000000C0FFC1C300000000807FC08100000000003FE00100000000
      083FF003000000001C1FF80700000000BE0FFC0F00000000FF07FC0F00000000
      FF83F80F00000000FFC1F00700000000FFE0E08300000000FFF0E1C100000000
      FFF8F3E100000000FFFCFFF10000000000000000000000000000000000000000
      000000000000}
  end
end
