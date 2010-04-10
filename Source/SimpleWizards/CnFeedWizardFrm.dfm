inherited CnFeedWizardForm: TCnFeedWizardForm
  Left = 434
  Top = 191
  BorderStyle = bsDialog
  Caption = 'Feed Wizard Settings'
  ClientHeight = 390
  ClientWidth = 480
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 238
    Top = 360
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    TabOrder = 2
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 318
    Top = 360
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 398
    Top = 360
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object grpFeeds: TGroupBox
    Left = 8
    Top = 72
    Width = 465
    Height = 281
    Caption = 'Feed &List'
    TabOrder = 1
    object lbl1: TLabel
      Left = 8
      Top = 164
      Width = 41
      Height = 13
      Caption = 'Caption:'
    end
    object lbl2: TLabel
      Left = 8
      Top = 194
      Width = 17
      Height = 13
      Caption = 'Url:'
    end
    object lbl3: TLabel
      Left = 8
      Top = 223
      Width = 34
      Height = 13
      Caption = 'Period:'
    end
    object lbl4: TLabel
      Left = 144
      Top = 223
      Width = 41
      Height = 13
      Caption = 'minutes.'
    end
    object lbl5: TLabel
      Left = 8
      Top = 253
      Width = 25
      Height = 13
      Caption = 'Limit:'
    end
    object lbl6: TLabel
      Left = 144
      Top = 253
      Width = 98
      Height = 13
      Caption = 'items.(0 is unlimited)'
    end
    object lvList: TListView
      Left = 8
      Top = 16
      Width = 441
      Height = 105
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
      Top = 160
      Width = 393
      Height = 21
      TabOrder = 3
      OnChange = edtCaptionChange
    end
    object edtUrl: TEdit
      Left = 56
      Top = 189
      Width = 393
      Height = 21
      TabOrder = 4
      OnChange = edtCaptionChange
    end
    object sePeriod: TCnSpinEdit
      Left = 56
      Top = 218
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
      Top = 248
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
      Top = 128
      Width = 75
      Height = 21
      Caption = '&Add'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 136
      Top = 128
      Width = 75
      Height = 21
      Caption = '&Delete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
  end
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 465
    Height = 57
    Caption = '&Feed Settings'
    TabOrder = 0
    object lbl7: TLabel
      Left = 8
      Top = 24
      Width = 74
      Height = 13
      Caption = 'Change Period:'
    end
    object lbl8: TLabel
      Left = 176
      Top = 24
      Width = 43
      Height = 13
      Caption = 'seconds.'
    end
    object seChangePeriod: TCnSpinEdit
      Left = 88
      Top = 19
      Width = 81
      Height = 22
      MaxValue = 99999
      MinValue = 1
      TabOrder = 0
      Value = 1
      OnExit = edtCaptionChange
    end
  end
end
