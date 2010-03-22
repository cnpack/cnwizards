inherited CnSrcTemplateForm: TCnSrcTemplateForm
  Left = 364
  Top = 135
  BorderStyle = bsDialog
  Caption = 'Source Templates'
  ClientHeight = 428
  ClientWidth = 472
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 457
    Height = 385
    Caption = '&Template'
    TabOrder = 0
    object ListView: TListView
      Left = 8
      Top = 16
      Width = 353
      Height = 355
      Columns = <
        item
          Caption = 'Menu Title'
          Width = 140
        end
        item
          Caption = 'Status'
          Width = 60
        end
        item
          Caption = 'Shortcut'
          Width = 120
        end>
      ColumnClick = False
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = ListViewChange
      OnDblClick = btnEditClick
    end
    object btnAdd: TButton
      Left = 370
      Top = 24
      Width = 75
      Height = 21
      Caption = '&Add'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 370
      Top = 52
      Width = 75
      Height = 21
      Caption = '&Delete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnClear: TButton
      Left = 370
      Top = 80
      Width = 75
      Height = 21
      Caption = 'C&lear'
      TabOrder = 3
      OnClick = btnClearClick
    end
    object btnEdit: TButton
      Left = 370
      Top = 108
      Width = 75
      Height = 21
      Caption = '&Edit'
      TabOrder = 4
      OnClick = btnEditClick
    end
    object btnUp: TButton
      Left = 370
      Top = 136
      Width = 75
      Height = 21
      Caption = 'Move &Up'
      TabOrder = 5
      OnClick = btnUpClick
    end
    object btnDown: TButton
      Left = 370
      Top = 164
      Width = 75
      Height = 21
      Caption = 'Move Do&wn'
      TabOrder = 6
      OnClick = btnDownClick
    end
    object btnImport: TButton
      Left = 370
      Top = 192
      Width = 75
      Height = 21
      Caption = '&Import'
      TabOrder = 7
      OnClick = btnImportClick
    end
    object btnExport: TButton
      Left = 370
      Top = 220
      Width = 75
      Height = 21
      Caption = 'Ex&port'
      TabOrder = 8
      OnClick = btnExportClick
    end
  end
  object btnHelp: TButton
    Left = 390
    Top = 400
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 310
    Top = 400
    Width = 75
    Height = 21
    Cancel = True
    Caption = 'Cl&ose'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'cdt'
    Filter = 'Editor Templates Files(*.cdt)|*.cdt'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Title = 'Import Editor Templates'
    Left = 8
    Top = 392
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'cdt'
    Filter = 'Editor Templates Files(*.cdt)|*.cdt'
    Title = 'Export Editor Templates'
    Left = 40
    Top = 392
  end
end
