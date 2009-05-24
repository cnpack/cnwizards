object CnViewSMRForm: TCnViewSMRForm
  Left = 186
  Top = 128
  Width = 730
  Height = 510
  Caption = 'View Source-Module Relations'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblOpenedFile: TLabel
    Left = 0
    Top = 470
    Width = 722
    Height = 13
    Align = alBottom
  end
  object gpAnalyse: TPanel
    Left = 0
    Top = 0
    Width = 722
    Height = 470
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlSourceFiles: TPanel
      Left = 145
      Top = 0
      Width = 280
      Height = 470
      Align = alLeft
      BevelOuter = bvNone
      BorderWidth = 3
      TabOrder = 1
      object Label3: TLabel
        Left = 3
        Top = 16
        Width = 274
        Height = 42
        Align = alTop
        AutoSize = False
        Caption = '&Source files:'
        FocusControl = lsbFiles
        Layout = tlBottom
      end
      object Label9: TLabel
        Left = 3
        Top = 3
        Width = 274
        Height = 13
        Align = alTop
        Caption = '&Find source file:'
        FocusControl = edtSearchFile
      end
      object lsbFiles: TListBox
        Left = 3
        Top = 58
        Width = 274
        Height = 409
        Align = alClient
        ItemHeight = 13
        TabOrder = 1
        OnClick = DoUpdateViews
      end
      object edtSearchFile: TEdit
        Left = 4
        Top = 19
        Width = 272
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        TabOrder = 0
        OnChange = DoSearchByMask
        OnKeyDown = DoProcessKeyDown
      end
    end
    object sbButtons: TScrollBox
      Left = 0
      Top = 0
      Width = 145
      Height = 470
      Align = alLeft
      BorderStyle = bsNone
      TabOrder = 0
      object gpAnalyseBtns: TPanel
        Left = 0
        Top = 0
        Width = 145
        Height = 470
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object btnOpenFiles: TBitBtn
          Left = 12
          Top = 12
          Width = 120
          Height = 58
          Caption = '&Open SMR Files'
          PopupMenu = pmOpenFiles
          TabOrder = 0
          OnClick = btnOpenFilesClick
        end
        object btnClear: TBitBtn
          Left = 12
          Top = 82
          Width = 120
          Height = 58
          Caption = '&Clear'
          Enabled = False
          TabOrder = 1
          OnClick = btnClearClick
        end
        object btnPrevView: TBitBtn
          Left = 12
          Top = 152
          Width = 120
          Height = 58
          Caption = 'P&revious View'
          Enabled = False
          TabOrder = 2
          OnClick = btnPrevViewClick
        end
        object btnNextView: TBitBtn
          Left = 12
          Top = 222
          Width = 120
          Height = 58
          Caption = '&Next View'
          Enabled = False
          TabOrder = 3
          OnClick = btnNextViewClick
        end
      end
    end
    object pnlAffectModules: TPanel
      Left = 425
      Top = 0
      Width = 297
      Height = 470
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 3
      TabOrder = 2
      object pnlImpAffectModules: TPanel
        Left = 3
        Top = 3
        Width = 291
        Height = 210
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 0
          Top = 0
          Width = 291
          Height = 15
          Align = alTop
          AutoSize = False
          Caption = 'Affected modules if no interface changed:'
          FocusControl = mmoAffects
        end
        object mmoAffects: TMemo
          Left = 0
          Top = 15
          Width = 291
          Height = 195
          Align = alClient
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
      object Panel3: TPanel
        Left = 3
        Top = 213
        Width = 291
        Height = 254
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object Label2: TLabel
          Left = 0
          Top = 0
          Width = 291
          Height = 22
          Align = alTop
          AutoSize = False
          Caption = 'Affected modules if interface changed:'
          FocusControl = mmoAllAffects
          Layout = tlCenter
        end
        object mmoAllAffects: TMemo
          Left = 0
          Top = 22
          Width = 291
          Height = 232
          Align = alClient
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
    end
  end
  object odOpenFiles: TOpenDialog
    Filter = 
      'Executable files(*.exe;*.dll;*.bpl;*.xex;*.cpl)|*.exe;*.dll;*.bp' +
      'l;*.xex;*.cpl|All files(*.*)|*.*'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Title = 'Open Files'
    Left = 156
    Top = 236
  end
  object sdAnalyseResults: TSaveDialog
    DefaultExt = 'arf'
    Filter = 'Analyze Results File(*.arf)|*.arf|All Files(*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Analyze Results'
    Left = 156
    Top = 268
  end
  object pmOpenFiles: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = pmOpenFilesPopup
    Left = 40
    Top = 20
    object miOpenFileManually: TMenuItem
      Caption = 'Open a file manually...'
      OnClick = miOpenFileManuallyClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
  end
  object odOpenSavedResults: TOpenDialog
    DefaultExt = 'smr'
    Filter = 'Source-Module Relations File(*.smr)|*.smr|All Files(*.*)|*.*'
    Title = 'Open source-module relations file'
    Left = 48
    Top = 28
  end
end
