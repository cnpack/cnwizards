inherited CnWizSubActionShortCutForm: TCnWizSubActionShortCutForm
  Left = 410
  Top = 169
  BorderStyle = bsDialog
  Caption = 'Sub-menu Shortcut Settings'
  ClientHeight = 486
  ClientWidth = 428
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 414
    Height = 444
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Shortcut Settings'
    TabOrder = 0
    object lbl2: TLabel
      Left = 8
      Top = 415
      Width = 45
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Shortcut:'
    end
    object ListView: TListView
      Left = 8
      Top = 16
      Width = 398
      Height = 388
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'Sub-menu Item'
          Width = 240
        end
        item
          Caption = 'Shortcut'
          Width = 130
        end>
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = ListViewChange
    end
    object HotKey: THotKey
      Left = 64
      Top = 411
      Width = 342
      Height = 19
      Anchors = [akLeft, akRight, akBottom]
      HotKey = 0
      InvalidKeys = [hcNone]
      Modifiers = []
      TabOrder = 1
      OnExit = HotKeyExit
    end
  end
  object btnHelp: TButton
    Left = 347
    Top = 459
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 187
    Top = 459
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 267
    Top = 459
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
