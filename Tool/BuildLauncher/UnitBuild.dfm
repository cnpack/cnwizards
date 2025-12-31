object AppBuillder: TAppBuillder
  Left = 369
  Top = 259
  Width = 538
  Height = 503
  Caption = 'Build Launcher for CnPack IDE Wizards'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    530
    476)
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 16
    Top = 48
    Width = 141
    Height = 65
    Caption = 
      'Must Run want.exe from Here'#13#10#13#10'to Avoid C++Builder 5'#13#10#13#10'Compiler' +
      ' Bug.'
  end
  object lblCmdPreview: TLabel
    Left = 16
    Top = 148
    Width = 3
    Height = 13
  end
  object bvl1: TBevel
    Left = 16
    Top = 136
    Width = 497
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  object btnRunWant: TButton
    Left = 352
    Top = 16
    Width = 161
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Run Want To Build'
    TabOrder = 0
    OnClick = btnRunWantClick
  end
  object cbbTarget: TComboBox
    Left = 16
    Top = 16
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    Text = 'publish'
    OnChange = cbbTargetChange
    Items.Strings = (
      'publish'
      'allgit'
      'all'
      'cb5'
      'd5'
      'd7')
  end
  object rgDef: TRadioGroup
    Left = 184
    Top = 16
    Width = 145
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Build Type'
    ItemIndex = 0
    Items.Strings = (
      'Nightly'
      'Debug'
      'Preview'
      'Release')
    TabOrder = 2
    OnClick = rgDefClick
  end
  object btnShowCmd: TButton
    Left = 352
    Top = 96
    Width = 161
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Show Cmd Window'
    TabOrder = 3
    OnClick = btnShowCmdClick
  end
  object lvTargets: TListView
    Left = 16
    Top = 176
    Width = 497
    Height = 281
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Target'
        Width = 120
      end
      item
        Caption = 'Description'
        Width = 350
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 4
    ViewStyle = vsReport
    OnDblClick = lvTargetsDblClick
  end
end
