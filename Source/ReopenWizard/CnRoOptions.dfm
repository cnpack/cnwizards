inherited CnRoOptionsDlg: TCnRoOptionsDlg
  Left = 354
  Top = 181
  BorderStyle = bsDialog
  Caption = 'Historical Files Settings'
  ClientHeight = 288
  ClientWidth = 285
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pcOption: TPageControl
    Left = 8
    Top = 8
    Width = 270
    Height = 244
    ActivePage = tsSample
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsSample: TTabSheet
      Caption = '&General'
      ImageIndex = 1
      object Label6: TLabel
        Left = 8
        Top = 8
        Width = 66
        Height = 13
        Caption = 'Default Page:'
      end
      object chkIgnoreDefault: TCheckBox
        Left = 8
        Top = 64
        Width = 238
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Ignore Unit1 and Project1'
        TabOrder = 1
      end
      object cbDefaultPage: TComboBox
        Left = 8
        Top = 32
        Width = 238
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          'ProjectGroup'
          'Project'
          'Source File'
          'Package'
          'Others'
          'Favorites')
      end
      object chkSortPersistance: TCheckBox
        Left = 8
        Top = 88
        Width = 238
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Keep Sort'
        TabOrder = 2
      end
      object chkLocalDate: TCheckBox
        Left = 8
        Top = 112
        Width = 238
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Local Time Format'
        TabOrder = 3
      end
    end
    object tsCapacity: TTabSheet
      Caption = 'Files &Limit'
      object lblPjg: TLabel
        Left = 10
        Top = 15
        Width = 157
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 'ProjectGroup(*.%s):'
      end
      object lblPj: TLabel
        Left = 10
        Top = 44
        Width = 157
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Project(*.%s):'
      end
      object lblUnt: TLabel
        Left = 10
        Top = 73
        Width = 157
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Source File(*.%s):'
      end
      object lblPkg: TLabel
        Left = 10
        Top = 102
        Width = 157
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Package(*.%s):'
      end
      object lblOth: TLabel
        Left = 10
        Top = 131
        Width = 157
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Others(Other):'
      end
      object lblFav: TLabel
        Left = 10
        Top = 160
        Width = 157
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Favorites:'
      end
      object SpinEditBPG: TCnSpinEdit
        Left = 185
        Top = 11
        Width = 69
        Height = 22
        Anchors = [akTop, akRight]
        MaxValue = 0
        MinValue = 0
        TabOrder = 0
        Value = 40
        OnExit = SpinLimited
      end
      object SpinEditDPR: TCnSpinEdit
        Left = 185
        Top = 40
        Width = 69
        Height = 22
        Anchors = [akTop, akRight]
        MaxValue = 0
        MinValue = 0
        TabOrder = 1
        Value = 40
        OnExit = SpinLimited
      end
      object SpinEditPAS: TCnSpinEdit
        Left = 185
        Top = 69
        Width = 69
        Height = 22
        Anchors = [akTop, akRight]
        MaxValue = 0
        MinValue = 0
        TabOrder = 2
        Value = 40
        OnExit = SpinLimited
      end
      object SpinEditDPK: TCnSpinEdit
        Left = 185
        Top = 98
        Width = 69
        Height = 22
        Anchors = [akTop, akRight]
        MaxValue = 0
        MinValue = 0
        TabOrder = 3
        Value = 40
        OnExit = SpinLimited
      end
      object SpinEditOther: TCnSpinEdit
        Left = 185
        Top = 127
        Width = 69
        Height = 22
        Anchors = [akTop, akRight]
        MaxValue = 0
        MinValue = 0
        TabOrder = 4
        Value = 40
        OnExit = SpinLimited
      end
      object SpinEditFAV: TCnSpinEdit
        Left = 185
        Top = 155
        Width = 69
        Height = 22
        Anchors = [akTop, akRight]
        MaxValue = 0
        MinValue = 0
        TabOrder = 5
        Value = 40
        OnExit = SpinLimited
      end
    end
  end
  object btnOK: TButton
    Left = 123
    Top = 261
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 203
    Top = 261
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
