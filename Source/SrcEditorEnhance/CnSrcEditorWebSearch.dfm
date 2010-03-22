inherited CnSrcEditorWebSearchForm: TCnSrcEditorWebSearchForm
  Left = 256
  Top = 156
  BorderStyle = bsDialog
  Caption = 'Web Search Settings'
  ClientHeight = 301
  ClientWidth = 457
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 441
    Height = 257
    Caption = '&List'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 176
      Width = 37
      Height = 13
      Caption = 'Caption'
    end
    object lbl2: TLabel
      Left = 192
      Top = 176
      Width = 43
      Height = 13
      Caption = 'ShortCut'
    end
    object lbl3: TLabel
      Left = 8
      Top = 203
      Width = 281
      Height = 13
      Caption = 'Search URL(Filename or http link. %s mean selected text):'
    end
    object ListView: TListView
      Left = 8
      Top = 16
      Width = 361
      Height = 145
      Columns = <
        item
          Caption = 'Caption'
          Width = 80
        end
        item
          Caption = 'ShortCut'
          Width = 80
        end
        item
          Caption = 'URL'
          Width = 180
        end>
      HideSelection = False
      MultiSelect = True
      OwnerData = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnData = ListViewData
      OnKeyUp = ListViewKeyUp
      OnMouseUp = ListViewMouseUp
      OnSelectItem = ListViewSelectItem
    end
    object btnAdd: TButton
      Left = 376
      Top = 16
      Width = 57
      Height = 21
      Caption = '&Add'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 376
      Top = 41
      Width = 57
      Height = 21
      Caption = '&De&lete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnUp: TButton
      Left = 376
      Top = 66
      Width = 57
      Height = 21
      Caption = '&Up'
      TabOrder = 3
      OnClick = btnUpClick
    end
    object btnDown: TButton
      Left = 375
      Top = 90
      Width = 57
      Height = 21
      Caption = '&Down'
      TabOrder = 4
      OnClick = btnDownClick
    end
    object edtCaption: TEdit
      Left = 48
      Top = 172
      Width = 137
      Height = 21
      TabOrder = 7
      OnChange = ControlChanged
    end
    object HotKey: THotKey
      Left = 248
      Top = 173
      Width = 121
      Height = 19
      HotKey = 0
      InvalidKeys = [hcNone, hcShift]
      Modifiers = []
      TabOrder = 8
      OnExit = ControlChanged
    end
    object edtUrl: TEdit
      Left = 8
      Top = 224
      Width = 361
      Height = 21
      TabOrder = 9
      OnChange = ControlChanged
    end
    object btnImport: TButton
      Left = 376
      Top = 115
      Width = 57
      Height = 21
      Caption = '&Import...'
      TabOrder = 5
      OnClick = btnImportClick
    end
    object btnExport: TButton
      Left = 376
      Top = 140
      Width = 57
      Height = 21
      Caption = 'E&xport...'
      TabOrder = 6
      OnClick = btnExportClick
    end
  end
  object btnOK: TButton
    Left = 216
    Top = 273
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 296
    Top = 273
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 376
    Top = 273
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'xml'
    Filter = 'Web Search Settings File(*.xml)|*.xml'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 272
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'xml'
    Filter = 'Web Search Settings File(*.xml)|*.xml'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 40
    Top = 272
  end
end
