object CnEditSMRForm: TCnEditSMRForm
  Left = 151
  Top = 153
  Width = 736
  Height = 545
  Caption = 'Edit Source-Module Relations'
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
  PixelsPerInch = 96
  TextHeight = 13
  object lblOpenedFile: TLabel
    Left = 0
    Top = 505
    Width = 728
    Height = 13
    Align = alBottom
  end
  object gpAnalyse: TPanel
    Left = 0
    Top = 0
    Width = 728
    Height = 505
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlSourceFiles: TPanel
      Left = 145
      Top = 0
      Width = 280
      Height = 505
      Align = alLeft
      BevelOuter = bvNone
      BorderWidth = 3
      TabOrder = 1
      OnResize = pnlSourceFilesResize
      object Label3: TLabel
        Left = 3
        Top = 18
        Width = 274
        Height = 40
        Align = alTop
        AutoSize = False
        Caption = '&Source files:'
        FocusControl = gdFiles
        Layout = tlBottom
      end
      object Label9: TLabel
        Left = 3
        Top = 3
        Width = 274
        Height = 15
        Align = alTop
        AutoSize = False
        Caption = '&Find source file:'
        FocusControl = edtSearchFile
      end
      object edtSearchFile: TEdit
        Left = 4
        Top = 19
        Width = 273
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        TabOrder = 0
        OnChange = edtSearchFileChange
        OnKeyDown = edtSearchFileKeyDown
      end
      object gdFiles: TDBGrid
        Left = 3
        Top = 58
        Width = 274
        Height = 444
        Align = alClient
        DataSource = dsMain
        Options = [dgEditing, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgCancelOnExit]
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnKeyDown = DoProcessKeyDown
      end
    end
    object sbButtons: TScrollBox
      Left = 0
      Top = 0
      Width = 145
      Height = 505
      Align = alLeft
      BorderStyle = bsNone
      TabOrder = 0
      object gpAnalyseBtns: TPanel
        Left = 0
        Top = 0
        Width = 145
        Height = 288
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object btnOpenSMR: TBitBtn
          Left = 12
          Top = 12
          Width = 120
          Height = 58
          Caption = '&New/Open SMR File'
          PopupMenu = pmOpenSMR
          TabOrder = 0
          OnClick = DoPopupPopupMenu
        end
        object btnLoadARF: TBitBtn
          Left = 12
          Top = 82
          Width = 120
          Height = 58
          Caption = '&Load ARF Helper'
          PopupMenu = pmOpenARF
          TabOrder = 1
          OnClick = DoPopupPopupMenu
        end
        object btnFillSelected: TBitBtn
          Left = 12
          Top = 152
          Width = 120
          Height = 58
          Caption = '&Auto Fill Data'
          PopupMenu = pmFillCDS
          TabOrder = 2
          OnClick = DoPopupPopupMenu
        end
        object btnSaveSMR: TBitBtn
          Left = 12
          Top = 222
          Width = 120
          Height = 58
          Caption = '&Save SMR File'
          Enabled = False
          TabOrder = 3
          OnClick = btnSaveSMRClick
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 288
        Width = 145
        Height = 117
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object DBNavigator1: TDBNavigator
          Left = 31
          Top = 6
          Width = 84
          Height = 25
          DataSource = dsMain
          VisibleButtons = [nbFirst, nbLast]
          Anchors = []
          TabOrder = 0
          TabStop = True
        end
        object DBNavigator2: TDBNavigator
          Left = 31
          Top = 33
          Width = 84
          Height = 25
          DataSource = dsMain
          VisibleButtons = [nbPrior, nbNext]
          Anchors = []
          TabOrder = 1
          TabStop = True
        end
        object DBNavigator4: TDBNavigator
          Left = 31
          Top = 60
          Width = 84
          Height = 25
          DataSource = dsMain
          VisibleButtons = [nbInsert, nbDelete]
          Anchors = []
          TabOrder = 2
          TabStop = True
        end
        object DBNavigator5: TDBNavigator
          Left = 31
          Top = 87
          Width = 84
          Height = 25
          DataSource = dsMain
          VisibleButtons = [nbEdit, nbPost, nbCancel]
          Anchors = []
          TabOrder = 3
          TabStop = True
        end
      end
    end
    object pnlAffectedModules: TPanel
      Left = 425
      Top = 0
      Width = 303
      Height = 505
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 3
      TabOrder = 2
      object pnlAffectModules: TPanel
        Left = 3
        Top = 3
        Width = 297
        Height = 210
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        OnResize = pnlAffectModulesResize
        object Label1: TLabel
          Left = 0
          Top = 0
          Width = 297
          Height = 15
          Align = alTop
          AutoSize = False
          Caption = 'Affected modules if no interface changed:'
          FocusControl = gdAffects
        end
        object gdAffects: TStringGrid
          Left = 0
          Top = 15
          Width = 297
          Height = 195
          Align = alClient
          ColCount = 1
          DefaultRowHeight = 18
          FixedCols = 0
          RowCount = 256
          FixedRows = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
          TabOrder = 0
          OnKeyDown = DoProcessKeyDown
          OnSelectCell = DoSelectCell
          OnTopLeftChanged = gdAffectsTopLeftChanged
        end
        object cmbPickList: TComboBox
          Left = 92
          Top = 92
          Width = 145
          Height = 21
          TabStop = False
          ItemHeight = 13
          TabOrder = 1
          Visible = False
          OnExit = cmbSetCellText
          OnKeyDown = cmbPickListKeyDown
        end
      end
      object pnlAllAffectModules: TPanel
        Left = 3
        Top = 213
        Width = 297
        Height = 289
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        OnResize = pnlAllAffectModulesResize
        object Label2: TLabel
          Left = 0
          Top = 0
          Width = 297
          Height = 22
          Align = alTop
          AutoSize = False
          Caption = 'Affected modules if interface changed:'
          FocusControl = gdAllAffects
          Layout = tlCenter
        end
        object gdAllAffects: TStringGrid
          Left = 0
          Top = 22
          Width = 297
          Height = 267
          Align = alClient
          ColCount = 1
          DefaultRowHeight = 18
          FixedCols = 0
          RowCount = 256
          FixedRows = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
          TabOrder = 0
          OnKeyDown = DoProcessKeyDown
          OnSelectCell = DoSelectCell
          OnTopLeftChanged = gdAffectsTopLeftChanged
        end
      end
    end
  end
  object sdSaveSMR: TSaveDialog
    DefaultExt = 'smr'
    Filter = 'Source-Module Relations File(*.smr)|*.smr|All Files(*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Source-Module Relations'
    Left = 48
    Top = 236
  end
  object pmOpenSMR: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = DoPopupMenuPopup
    Left = 40
    Top = 20
    object miOpenSMR: TMenuItem
      Caption = 'Continue edit a SMR file...'
      OnClick = miOpenSMRClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miCloseSMR: TMenuItem
      Caption = 'Close SMR file'
      OnClick = miCloseSMRClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miNewSMR: TMenuItem
      Caption = 'New SMR file'
      OnClick = miNewSMRClick
    end
    object miNewSMRFromDirList: TMenuItem
      Caption = 'New SMR file from DirList file...'
      OnClick = miNewSMRFromDirListClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
  end
  object odOpenSMF: TOpenDialog
    DefaultExt = 'smr'
    Filter = 'Source-Module Relations File(*.smr)|*.smr|All Files(*.*)|*.*'
    Title = 'Open source-module relations file'
    Left = 48
    Top = 28
  end
  object dsMain: TDataSource
    DataSet = cdsMain
    Left = 128
    Top = 92
  end
  object cdsMain: TADODataSet
    BeforePost = cdsMainBeforePost
    AfterPost = cdsMainAfterPost
    AfterCancel = cdsMainAfterCancel
    BeforeScroll = cdsMainBeforeScroll
    AfterScroll = cdsMainAfterScroll
    Parameters = <>
    Left = 128
    Top = 124
  end
  object pmOpenARF: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = DoPopupMenuPopup
    Left = 44
    Top = 96
    object miLoadARF: TMenuItem
      Caption = 'Select ARF file manually...'
      OnClick = miLoadARFClick
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object miClearARF: TMenuItem
      Caption = 'Close ARF helper'
      OnClick = miClearARFClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object odOpenARF: TOpenDialog
    DefaultExt = 'arf'
    Filter = 'Analyze Results File(*.arf)|*.arf|All Files(*.*)|*.*'
    Title = 'Open analyzed results'
    Left = 52
    Top = 104
  end
  object odOpenDirListFile: TOpenDialog
    DefaultExt = 'txt'
    Filter = 'DirList file(*.txt)|*.txt|All Files(*.*)|*.*'
    Title = 'Open DirList.exe saved file'
    Left = 80
    Top = 28
  end
  object pmFillCDS: TPopupMenu
    OnPopup = pmFillCDSPopup
    Left = 44
    Top = 164
    object miFillSelectedSMR: TMenuItem
      Caption = 'Fill selected source-module relation'
      OnClick = miFillSelectedSMRClick
    end
    object miFillAllSMR: TMenuItem
      Caption = 'Fill all source-module relations'
      OnClick = miFillAllSMRClick
    end
  end
  object appEventsFixMouseWheelMsg: TApplicationEvents
    OnMessage = appEventsFixMouseWheelMsgMessage
    Left = 128
    Top = 156
  end
end
