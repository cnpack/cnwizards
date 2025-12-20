object AppBuillder: TAppBuillder
  Left = 389
  Top = 283
  BorderStyle = bsDialog
  Caption = 'Build Launcher for CnPack IDE Wizards'
  ClientHeight = 187
  ClientWidth = 357
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 16
    Top = 56
    Width = 141
    Height = 65
    Caption = 
      'Must Run want.exe from Here'#13#10#13#10'to Avoid C++Builder 5'#13#10#13#10'Compiler' +
      ' Bug.'
  end
  object btnRunWant: TButton
    Left = 16
    Top = 16
    Width = 161
    Height = 25
    Caption = 'Run Want To Build'
    TabOrder = 0
    OnClick = btnRunWantClick
  end
  object cbbTarget: TComboBox
    Left = 192
    Top = 16
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    Text = 'publish'
    Items.Strings = (
      'publish'
      'allgit'
      'all'
      'cb5'
      'd5'
      'd7')
  end
  object rgDef: TRadioGroup
    Left = 192
    Top = 56
    Width = 145
    Height = 105
    Caption = 'Build Type'
    ItemIndex = 0
    Items.Strings = (
      'Nightly'
      'Debug'
      'Preview'
      'Release')
    TabOrder = 2
  end
end
