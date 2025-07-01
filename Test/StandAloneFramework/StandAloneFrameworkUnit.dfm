object FormFramework: TFormFramework
  Left = 192
  Top = 112
  Width = 979
  Height = 563
  Caption = 'Stand Alone Framework Test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mmStub
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object actlstStub: TActionList
    Images = ilStub
    Left = 144
    Top = 80
  end
  object mmStub: TMainMenu
    Images = ilStub
    Left = 104
    Top = 80
    object File1: TMenuItem
      Caption = 'File'
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
    end
    object Search1: TMenuItem
      Caption = 'Search'
    end
    object View1: TMenuItem
      Caption = 'View'
    end
    object Project1: TMenuItem
      Caption = 'Project'
    end
    object Run1: TMenuItem
      Caption = 'Run'
    end
    object Component1: TMenuItem
      Caption = 'Component'
    end
    object Database1: TMenuItem
      Caption = 'Database'
    end
    object ToolsMenu: TMenuItem
      Caption = 'Tools'
    end
    object Window1: TMenuItem
      Caption = 'Window'
    end
    object Help1: TMenuItem
      Caption = 'Help'
    end
  end
  object ilStub: TImageList
    Left = 184
    Top = 80
  end
end
