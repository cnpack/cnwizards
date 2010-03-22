inherited CnRoOptionsDlg: TCnRoOptionsDlg
  Left = 354
  Top = 181
  BorderStyle = bsDialog
  Caption = 'Historical Files Settings'
  ClientHeight = 261
  ClientWidth = 248
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pcOption: TPageControl
    Left = 8
    Top = 8
    Width = 233
    Height = 217
    ActivePage = tsSample
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
        Width = 156
        Height = 17
        Caption = 'Ignore Unit1 and Project1'
        TabOrder = 1
      end
      object cbDefaultPage: TComboBox
        Left = 8
        Top = 32
        Width = 201
        Height = 21
        Style = csDropDownList
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
        Width = 138
        Height = 17
        Caption = 'Keep Sort'
        TabOrder = 2
      end
      object chkLocalDate: TCheckBox
        Left = 8
        Top = 112
        Width = 138
        Height = 17
        Caption = 'Local Time Format'
        TabOrder = 3
      end
    end
    object tsCapacity: TTabSheet
      Caption = 'Files &Limit'
      object lblPjg: TLabel
        Left = 13
        Top = 15
        Width = 101
        Height = 13
        Caption = 'ProjectGroup(*.%s):'
      end
      object lblPj: TLabel
        Left = 13
        Top = 44
        Width = 72
        Height = 13
        Caption = 'Project(*.%s):'
      end
      object lblUnt: TLabel
        Left = 13
        Top = 73
        Width = 90
        Height = 13
        Caption = 'Source File(*.%s):'
      end
      object lblPkg: TLabel
        Left = 13
        Top = 102
        Width = 78
        Height = 13
        Caption = 'Package(*.%s):'
      end
      object lblOth: TLabel
        Left = 13
        Top = 131
        Width = 73
        Height = 13
        Caption = 'Others(Other):'
      end
      object lblFav: TLabel
        Left = 15
        Top = 160
        Width = 49
        Height = 13
        Caption = 'Favorites:'
      end
      object SpinEditBPG: TCnSpinEdit
        Left = 148
        Top = 11
        Width = 69
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 0
        Value = 40
        OnExit = SpinLimited
      end
      object SpinEditDPR: TCnSpinEdit
        Left = 148
        Top = 40
        Width = 69
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 1
        Value = 40
        OnExit = SpinLimited
      end
      object SpinEditPAS: TCnSpinEdit
        Left = 148
        Top = 69
        Width = 69
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 2
        Value = 40
        OnExit = SpinLimited
      end
      object SpinEditDPK: TCnSpinEdit
        Left = 148
        Top = 98
        Width = 69
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 3
        Value = 40
        OnExit = SpinLimited
      end
      object SpinEditOther: TCnSpinEdit
        Left = 148
        Top = 127
        Width = 69
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 4
        Value = 40
        OnExit = SpinLimited
      end
      object SpinEditFAV: TCnSpinEdit
        Left = 148
        Top = 155
        Width = 69
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 5
        Value = 40
        OnExit = SpinLimited
      end
    end
  end
  object btnOK: TButton
    Left = 86
    Top = 234
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 166
    Top = 234
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
