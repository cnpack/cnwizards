inherited CnFeedWizardForm: TCnFeedWizardForm
  Left = 424
  Top = 278
  BorderStyle = bsDialog
  Caption = 'Feed Wizard Settings'
  ClientHeight = 358
  ClientWidth = 481
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 238
    Top = 328
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 318
    Top = 328
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 398
    Top = 328
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object grpFeeds: TGroupBox
    Left = 8
    Top = 8
    Width = 465
    Height = 313
    Caption = 'Feed &List'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 188
      Width = 41
      Height = 13
      Caption = 'Caption:'
    end
    object lbl2: TLabel
      Left = 8
      Top = 220
      Width = 17
      Height = 13
      Caption = 'Url:'
    end
    object lbl3: TLabel
      Left = 8
      Top = 252
      Width = 34
      Height = 13
      Caption = 'Period:'
    end
    object lbl4: TLabel
      Left = 144
      Top = 252
      Width = 41
      Height = 13
      Caption = 'minutes.'
    end
    object lbl5: TLabel
      Left = 8
      Top = 285
      Width = 25
      Height = 13
      Caption = 'Limit:'
    end
    object lbl6: TLabel
      Left = 144
      Top = 284
      Width = 98
      Height = 13
      Caption = 'items.(0 is unlimited)'
    end
    object lvList: TListView
      Left = 8
      Top = 16
      Width = 441
      Height = 129
      Columns = <
        item
          Caption = 'Caption'
          Width = 90
        end
        item
          Caption = 'Url'
          Width = 200
        end
        item
          Caption = 'Period(min)'
          Width = 72
        end
        item
          Caption = 'Limit'
        end>
      ColumnClick = False
      HideSelection = False
      OwnerData = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = lvListChange
      OnClick = lvListClick
      OnData = lvListData
    end
    object edtCaption: TEdit
      Left = 56
      Top = 184
      Width = 393
      Height = 21
      TabOrder = 3
      OnChange = edtCaptionChange
    end
    object edtUrl: TEdit
      Left = 56
      Top = 216
      Width = 393
      Height = 21
      TabOrder = 4
      OnChange = edtCaptionChange
    end
    object sePeriod: TCnSpinEdit
      Left = 56
      Top = 248
      Width = 81
      Height = 22
      MaxValue = 99999
      MinValue = 1
      TabOrder = 5
      Value = 1
      OnExit = edtCaptionChange
    end
    object seLimit: TCnSpinEdit
      Left = 56
      Top = 280
      Width = 81
      Height = 22
      MaxLength = 999
      MaxValue = 0
      MinValue = 0
      TabOrder = 6
      Value = 0
      OnExit = edtCaptionChange
    end
    object btnAdd: TButton
      Left = 56
      Top = 152
      Width = 75
      Height = 21
      Caption = '&Add'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 136
      Top = 152
      Width = 75
      Height = 21
      Caption = '&Delete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
  end
end
