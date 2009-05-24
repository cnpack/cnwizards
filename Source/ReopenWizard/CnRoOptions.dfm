object CnRoOptionsDlg: TCnRoOptionsDlg
  Left = 354
  Top = 181
  BorderStyle = bsDialog
  Caption = '打开历史文件选项'
  ClientHeight = 261
  ClientWidth = 248
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
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
      Caption = '普通选项(&N)'
      ImageIndex = 1
      object Label6: TLabel
        Left = 8
        Top = 8
        Width = 72
        Height = 13
        Caption = '默认打开页：'
      end
      object chkIgnoreDefault: TCheckBox
        Left = 8
        Top = 64
        Width = 156
        Height = 17
        Caption = '忽略 Unit1, Project1。'
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
          '工程组文件'
          '工程文件'
          '源码文件'
          '包文件'
          '其他文件'
          '收藏夹')
      end
      object chkSortPersistance: TCheckBox
        Left = 8
        Top = 88
        Width = 138
        Height = 17
        Caption = '保留标题排序方法。'
        TabOrder = 2
      end
      object chkLocalDate: TCheckBox
        Left = 8
        Top = 112
        Width = 138
        Height = 17
        Caption = '本地日期格式。'
        TabOrder = 3
      end
    end
    object tsCapacity: TTabSheet
      Caption = '设置保存文件数(&M)'
      object lblPjg: TLabel
        Left = 13
        Top = 15
        Width = 98
        Height = 13
        Caption = '工程组文件(*.%s):'
      end
      object lblPj: TLabel
        Left = 13
        Top = 44
        Width = 86
        Height = 13
        Caption = '工程文件(*.%s):'
      end
      object lblUnt: TLabel
        Left = 13
        Top = 73
        Width = 86
        Height = 13
        Caption = '源码文件(*.%s):'
      end
      object lblPkg: TLabel
        Left = 13
        Top = 102
        Width = 74
        Height = 13
        Caption = '包文件(*.%s):'
      end
      object lblOth: TLabel
        Left = 13
        Top = 131
        Width = 88
        Height = 13
        Caption = '其他文件(Other):'
      end
      object lblFav: TLabel
        Left = 15
        Top = 160
        Width = 40
        Height = 13
        Caption = '收藏夹:'
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
    Caption = '确定(&O)'
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
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
end
