inherited CnEditorToolsForm: TCnEditorToolsForm
  Left = 359
  Top = 144
  ClientWidth = 586
  ClientHeight = 517
  BorderIcons = [biSystemMenu]
  Caption = 'Coding Toolset Settings'
  Constraints.MinHeight = 537
  Constraints.MinWidth = 586
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000040010000000000000000000000000000000000000000
    0000800080008000000080800000008000001AA3A300005A8E00C0C0C00072E2
    E200F4D7A200158F8F00FF00FF00FF000000FFFF000000FF000000FFFF00001E
    F600FFFFFF00F7FDFD00169D9D00D4F0FF006DE4E40092E8E80059DDDD0036B0
    B00025B0B0001BA8A8001DB7B7001EABAB00189797001786860000598F00D4E3
    FF0098E9E90075E6E60065E3E3004CC7FF0021AFAF000055FF00169D9E00189A
    9A001692920000598D0000345700D4D4FF00B1B1FF008E8EFF006B6BFF004848
    FF000F35C900000FC500000DBF00052CC9000010C2000000730000345800E3D4
    FF00C7B1FF00AB8EFF008F6BFF007348FF005725FF005500FF004900DC003D00
    B900310096002500730019005000F0D4FF00E2B1FF00D48EFF00C66BFF00B848
    FF00AA25FF00AA00FF009200DC007A00B900620096004A00730032005000FFCC
    FF00FFB1FF00FF8EFF00FF6BFF00FF48FF00FF25FF00FF00FF00DC00DC00B900
    B900960096007300730050005000FFD4F000FFB1E200FF8ED400FF6BC600FF48
    B800FF25AA00FF00AA00DC009200B9007A009600620073004A0050003200FFD4
    E300FFB1C700FF8EAB00FF6B8F00FF487300FF255700FF005500DC004900B900
    3D00960031007300250050001900FFD4D400FFB1B100FF8E8E00FF6B6B00FF48
    4800FF252500FF000000DC000000B9000000960000007300000050000000FFE3
    D400FFC7B100FFAB8E00FF8F6B00FF734800FF572500FF550000CB6606009C2E
    00009E2F00009F2E000050190000FFF0D400F4D7A500FFD48E00FFC66B00FFB8
    4800E2922B00FF980000E2942B00CC660600CA630200734A000050320000FFFA
    D100FFFFB100FFFF8E00FFFF6B00FFFF4800FFFF2500FFFF0000DCDC0000B9B9
    0000969600007373000050500000F0FFD400E2FFB100D4FF8E00C6FF6B00B8FF
    4800AAFF2500AAFF000092DC00007AB90000629600004A73000032500000E3FF
    D400C7FFB100ABFF8E008FFF6B0073FF480057FF250055FF000049DC00003DB9
    0000319600002573000019500000D4FFD400B1FFB1008EFF8E006BFF6B0048FF
    480025FF250000FF000000DC000000B90000009600000073000000500000D4FF
    E3007FE7E70077E3E30059DEDE0048FF730025FF570000FF550000DC49001691
    9000169999000073250000501900D4FFF00078E6E60093E8E80054DCDC001DB4
    B40033AFAF001DB6B6001CB3B30023ACAC00168D8D001784840000599000E7FA
    FF0079E4E4006EE4E40066E3E30061E2E2001DB8B80000FFFF001EBFBF0021AE
    AE00189898001690900017979900F5FDFD007AE6E6006FE2E200CECECE00C2C2
    C2001DB5B5001EACAB00199E9E0016959500148D8D0016818100179798006262
    6200565656004A4A4A003E3E3E003C2D2200262626001A1A1A000E0E0E000000
    000000002511FC062B37000000000000001800001C11DFE091248A0000000000
    1A29E521EA111F0998939288000000D91D0FF1F6230F112A8D98939289000000
    DBE70F0FC9132711958D989310320000D6DE0F0A2808EEF711870911103519DC
    EA15D5F3121111ECEB1194105031E9D7E40FF4E111111111EE2711343311E9CB
    E30FD1CA1111111108130F1111E8E81CDDE2EDF31211111228C923D0F2E80000
    161E0FF5F3CAE1F30A0FF621000000001BDA0F0FD5D1F4220F0FD8E5000000D9
    1D0F1B1EE20F0F15DEE70F2918000000051D1B16DDE3E4EAD6DB1D1A00000000
    00D900001C17D7DC0000D9000000000000000000E8E9E919000000000000FC0F
    0000EC070000C003000080010000C0000000C000000000000000000000000000
    000000000000C0030000C003000080010000C0030000EC370000FC3F0000}
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnHelp: TButton
    Left = 494
    Top = 484
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 414
    Top = 484
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cl&ose'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 561
    Height = 469
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Editor &Tools'
    TabOrder = 0
    object lbl1: TLabel
      Left = 384
      Top = 132
      Width = 52
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Shortcut:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbl2: TLabel
      Left = 384
      Top = 187
      Width = 50
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Settings:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblToolName: TLabel
      Left = 424
      Top = 14
      Width = 129
      Height = 40
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'lblToolName'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
    end
    object imgIcon: TImage
      Left = 384
      Top = 16
      Width = 32
      Height = 32
      Anchors = [akTop, akRight]
    end
    object bvlWizard: TBevel
      Left = 384
      Top = 48
      Width = 169
      Height = 10
      Anchors = [akTop, akRight]
      Shape = bsBottomLine
    end
    object lbl3: TLabel
      Left = 384
      Top = 64
      Width = 42
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Author:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblToolAuthor: TLabel
      Left = 384
      Top = 80
      Width = 169
      Height = 49
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'lblToolAuthor'
      WordWrap = True
    end
    object lvTools: TListView
      Left = 8
      Top = 16
      Width = 369
      Height = 333
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'Tool Name'
          Width = 150
        end
        item
          Caption = 'Status'
          Width = 70
        end
        item
          Caption = 'Shortcut'
          Width = 120
        end>
      ColumnClick = False
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = lvToolsChange
      OnDblClick = lvToolsDblClick
    end
    object mmoComment: TMemo
      Left = 8
      Top = 356
      Width = 545
      Height = 97
      Anchors = [akLeft, akRight, akBottom]
      Color = 14745599
      ReadOnly = True
      TabOrder = 4
    end
    object chkEnabled: TCheckBox
      Left = 384
      Top = 203
      Width = 129
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Enable this Tool'
      TabOrder = 2
      OnClick = chkEnabledClick
    end
    object HotKey: THotKey
      Left = 384
      Top = 148
      Width = 169
      Height = 19
      Anchors = [akTop, akRight]
      HotKey = 0
      InvalidKeys = [hcNone]
      Modifiers = []
      TabOrder = 1
      OnExit = HotKeyExit
    end
    object btnConfig: TButton
      Left = 406
      Top = 225
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Settings'
      TabOrder = 3
      OnClick = btnConfigClick
    end
  end
end
