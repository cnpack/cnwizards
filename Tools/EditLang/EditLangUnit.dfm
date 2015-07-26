object EditLangForm: TEditLangForm
  Left = 252
  Top = 152
  Caption = 'CnWizards Language Editor'
  ClientHeight = 442
  ClientWidth = 892
  Color = clBtnFace
  Constraints.MinHeight = 469
  Constraints.MinWidth = 900
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 441
    Top = 0
    Width = 5
    Height = 423
    ExplicitHeight = 442
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 441
    Height = 423
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object pnlLeftTop: TPanel
      Left = 0
      Top = 0
      Width = 441
      Height = 33
      Align = alTop
      BevelInner = bvRaised
      BevelOuter = bvLowered
      TabOrder = 0
      object cbbLeftDir: TComboBox
        Left = 8
        Top = 6
        Width = 209
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbbLeftDirChange
      end
      object cbbLeftFile: TComboBox
        Left = 224
        Top = 6
        Width = 209
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = cbbLeftFileChange
      end
    end
  end
  object pnlRight: TPanel
    Left = 446
    Top = 0
    Width = 446
    Height = 423
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object pnlRightTop: TPanel
      Left = 0
      Top = 0
      Width = 446
      Height = 33
      Align = alTop
      BevelInner = bvRaised
      BevelOuter = bvLowered
      TabOrder = 0
      object cbbRightDir: TComboBox
        Left = 8
        Top = 6
        Width = 209
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbbRightDirChange
      end
      object cbbRightFile: TComboBox
        Left = 224
        Top = 6
        Width = 209
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = cbbRightFileChange
      end
    end
  end
  object statMain: TStatusBar
    Left = 0
    Top = 423
    Width = 892
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
end
