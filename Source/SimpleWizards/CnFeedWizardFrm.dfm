inherited CnFeedWizardForm: TCnFeedWizardForm
  Left = 434
  Top = 191
  BorderStyle = bsDialog
  Caption = 'FeedReader Wizard Settings'
  ClientHeight = 412
  ClientWidth = 480
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 238
    Top = 384
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    TabOrder = 2
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 318
    Top = 384
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 398
    Top = 384
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object grpFeeds: TGroupBox
    Left = 8
    Top = 120
    Width = 465
    Height = 257
    Caption = 'Feed &List'
    TabOrder = 1
    object lbl1: TLabel
      Left = 8
      Top = 136
      Width = 41
      Height = 13
      Caption = 'Caption:'
    end
    object lbl2: TLabel
      Left = 8
      Top = 166
      Width = 17
      Height = 13
      Caption = 'Url:'
    end
    object lbl3: TLabel
      Left = 8
      Top = 195
      Width = 34
      Height = 13
      Caption = 'Period:'
    end
    object lbl4: TLabel
      Left = 152
      Top = 195
      Width = 41
      Height = 13
      Caption = 'minutes.'
    end
    object lbl5: TLabel
      Left = 8
      Top = 225
      Width = 25
      Height = 13
      Caption = 'Limit:'
    end
    object lbl6: TLabel
      Left = 152
      Top = 225
      Width = 98
      Height = 13
      Caption = 'items.(0 is unlimited)'
    end
    object lvList: TListView
      Left = 8
      Top = 16
      Width = 441
      Height = 81
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
      Left = 64
      Top = 132
      Width = 385
      Height = 21
      TabOrder = 3
      OnChange = edtCaptionChange
    end
    object edtUrl: TEdit
      Left = 64
      Top = 161
      Width = 385
      Height = 21
      TabOrder = 4
      OnChange = edtCaptionChange
    end
    object sePeriod: TCnSpinEdit
      Left = 64
      Top = 190
      Width = 81
      Height = 22
      MaxValue = 99999
      MinValue = 1
      TabOrder = 5
      Value = 1
      OnExit = edtCaptionChange
    end
    object seLimit: TCnSpinEdit
      Left = 64
      Top = 220
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
      Left = 64
      Top = 104
      Width = 75
      Height = 21
      Caption = '&Add'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 144
      Top = 104
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
    Height = 105
    Caption = '&Feed Settings'
    TabOrder = 0
    object lbl7: TLabel
      Left = 8
      Top = 80
      Width = 74
      Height = 13
      Caption = 'Change Period:'
    end
    object lbl8: TLabel
      Left = 176
      Top = 80
      Width = 43
      Height = 13
      Caption = 'seconds.'
    end
    object lbl9: TLabel
      Left = 256
      Top = 16
      Width = 94
      Height = 13
      Caption = 'Spam Keyword List:'
    end
    object seChangePeriod: TCnSpinEdit
      Left = 88
      Top = 75
      Width = 81
      Height = 22
      MaxValue = 99999
      MinValue = 1
      TabOrder = 4
      Value = 1
      OnExit = edtCaptionChange
    end
    object chkSubCnPackChannels: TCheckBox
      Left = 8
      Top = 16
      Width = 241
      Height = 17
      Caption = '&Subscribe CnPack channels.'
      TabOrder = 0
    end
    object chkRandomDisplay: TCheckBox
      Left = 8
      Top = 52
      Width = 241
      Height = 17
      Caption = '&Random display.'
      TabOrder = 3
    end
    object mmoFilter: TMemo
      Left = 256
      Top = 32
      Width = 193
      Height = 65
      ScrollBars = ssVertical
      TabOrder = 1
    end
    object chkSubPartnerChannels: TCheckBox
      Left = 8
      Top = 34
      Width = 241
      Height = 17
      Caption = 'Subscribe CnPack &Partner channels.'
      TabOrder = 2
    end
  end
end
