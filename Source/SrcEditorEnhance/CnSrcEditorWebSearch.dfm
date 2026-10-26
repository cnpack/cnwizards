inherited CnSrcEditorWebSearchForm: TCnSrcEditorWebSearchForm
  Left = 256
  Top = 156
  BorderStyle = bsDialog
  Caption = 'Web Search Settings'
  ClientHeight = 370
  ClientWidth = 529
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 513
    Height = 326
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '&List'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 245
      Width = 109
      Height = 13
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Caption'
    end
    object lbl2: TLabel
      Left = 264
      Top = 245
      Width = 41
      Height = 13
      Anchors = [akRight, akBottom]
      Caption = 'Shortcut'
    end
    object lbl3: TLabel
      Left = 8
      Top = 272
      Width = 358
      Height = 13
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Search URL(Filename or http link. %s means selected text):'
    end
    object ListView: TListView
      Left = 8
      Top = 16
      Width = 433
      Height = 214
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'Caption'
          Width = 100
        end
        item
          Caption = 'Shortcut'
          Width = 90
        end
        item
          Caption = 'URL'
          Width = 220
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
      Left = 448
      Top = 16
      Width = 57
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Add'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 448
      Top = 41
      Width = 57
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&De&lete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnUp: TButton
      Left = 448
      Top = 66
      Width = 57
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Up'
      TabOrder = 3
      OnClick = btnUpClick
    end
    object btnDown: TButton
      Left = 447
      Top = 90
      Width = 57
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Down'
      TabOrder = 4
      OnClick = btnDownClick
    end
    object edtCaption: TEdit
      Left = 48
      Top = 241
      Width = 137
      Height = 21
      Anchors = [akLeft, akBottom]
      TabOrder = 7
      OnChange = ControlChanged
    end
    object HotKey: THotKey
      Left = 320
      Top = 242
      Width = 121
      Height = 19
      Anchors = [akRight, akBottom]
      HotKey = 0
      InvalidKeys = [hcNone]
      Modifiers = []
      TabOrder = 8
      OnExit = ControlChanged
    end
    object edtUrl: TEdit
      Left = 8
      Top = 293
      Width = 433
      Height = 21
      Anchors = [akLeft, akRight, akBottom]
      TabOrder = 9
      OnChange = ControlChanged
    end
    object btnImport: TButton
      Left = 448
      Top = 115
      Width = 57
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Import...'
      TabOrder = 5
      OnClick = btnImportClick
    end
    object btnExport: TButton
      Left = 448
      Top = 140
      Width = 57
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'E&xport...'
      TabOrder = 6
      OnClick = btnExportClick
    end
  end
  object btnOK: TButton
    Left = 288
    Top = 342
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 368
    Top = 342
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 448
    Top = 342
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
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
