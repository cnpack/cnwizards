object FormCheck: TFormCheck
  Left = 520
  Top = 260
  BorderStyle = bsDialog
  Caption = 'Load and Check CnWizards External Dlls'
  ClientHeight = 466
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblHint: TLabel
    Left = 24
    Top = 16
    Width = 452
    Height = 13
    Caption = 
      'Load and Check CnWizards External Dlls in WIn32 Non-Unicode/Unic' +
      'ode and Win64. Unicode'
  end
  object lblError: TLabel
    Left = 112
    Top = 56
    Width = 268
    Height = 13
    Caption = '126: Dll NOT Exists; 193: NOT Correct Win32/64 Format'
  end
  object btnLoad: TButton
    Left = 24
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Load Dlls'
    TabOrder = 0
    OnClick = btnLoadClick
  end
  object btnFree: TButton
    Left = 400
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Free Dlls'
    TabOrder = 1
    OnClick = btnFreeClick
  end
  object pgcCheck: TPageControl
    Left = 24
    Top = 96
    Width = 457
    Height = 353
    ActivePage = tsForamtLib
    TabOrder = 2
    object tsForamtLib: TTabSheet
      Caption = 'ForamtLib'
      object grpFormatLib: TGroupBox
        Left = 8
        Top = 0
        Width = 433
        Height = 313
        TabOrder = 0
        object btnFormatGetProvider: TButton
          Left = 16
          Top = 16
          Width = 75
          Height = 25
          Caption = 'Get Provider'
          TabOrder = 0
          OnClick = btnFormatGetProviderClick
        end
      end
    end
    object tsPngLib: TTabSheet
      Caption = 'PngLib'
      ImageIndex = 1
      object grpPngLib: TGroupBox
        Left = 8
        Top = 0
        Width = 433
        Height = 313
        TabOrder = 0
        object btnPngLibGetProc: TButton
          Left = 16
          Top = 16
          Width = 75
          Height = 25
          Caption = 'Get Functions'
          TabOrder = 0
          OnClick = btnPngLibGetProcClick
        end
      end
    end
    object tsVclToFmx: TTabSheet
      Caption = 'VclToFmx'
      ImageIndex = 2
      object grpVclToFmx: TGroupBox
        Left = 8
        Top = 0
        Width = 433
        Height = 313
        TabOrder = 0
        object btnVclToFmxGetIntf: TButton
          Left = 16
          Top = 16
          Width = 75
          Height = 25
          Caption = 'Get Intf'
          TabOrder = 0
          OnClick = btnVclToFmxGetIntfClick
        end
      end
    end
    object tsWizHelper: TTabSheet
      Caption = 'WizHelper'
      ImageIndex = 3
      object grpWizHelper: TGroupBox
        Left = 8
        Top = 0
        Width = 433
        Height = 313
        TabOrder = 0
        object btnWizHelperLibGetProc: TButton
          Left = 16
          Top = 16
          Width = 75
          Height = 25
          Caption = 'Get Functions'
          TabOrder = 0
          OnClick = btnWizHelperLibGetProcClick
        end
      end
    end
    object tsWizLoader: TTabSheet
      Caption = 'WizLoader'
      ImageIndex = 4
      object grpWizLoader: TGroupBox
        Left = 8
        Top = 0
        Width = 433
        Height = 313
        TabOrder = 0
      end
    end
    object tsWizRes: TTabSheet
      Caption = 'WizRes'
      ImageIndex = 5
      object grpWizRes: TGroupBox
        Left = 8
        Top = 0
        Width = 433
        Height = 313
        TabOrder = 0
        object imgWizRes: TImage
          Left = 112
          Top = 16
          Width = 105
          Height = 105
        end
        object btnWizResGet: TButton
          Left = 16
          Top = 16
          Width = 75
          Height = 25
          Caption = 'WizRes Get'
          TabOrder = 0
          OnClick = btnWizResGetClick
        end
      end
    end
    object tsZipUtils: TTabSheet
      Caption = 'ZipUtils'
      ImageIndex = 6
      object grpZipUtils: TGroupBox
        Left = 8
        Top = 0
        Width = 433
        Height = 313
        TabOrder = 0
        object btnZipUtilsLibGetProc: TButton
          Left = 16
          Top = 16
          Width = 75
          Height = 25
          Caption = 'Get Functions'
          TabOrder = 0
          OnClick = btnZipUtilsLibGetProcClick
        end
      end
    end
  end
end
