inherited CnSrcTemplateEditForm: TCnSrcTemplateEditForm
  Left = 189
  Top = 97
  AutoScroll = False
  Caption = 'Source Template Editor'
  ClientHeight = 452
  ClientWidth = 618
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000040010000000000000000000000000000000000000000
    0000800080008000000080800000008000000080800000008000BBBBBB00C0DC
    C000F0CAA60080808000FF00FF00FF000000FFFF000000FF000000FFFF000000
    FF00FFFFFF00F0FBFF00A4A0A000D4F0FF00B1E2FF0099CCFF006699CC0048B8
    FF0025AAFF000099FF000092DC000066CC0033669900004A730000325000D4E3
    FF00B1C7FF008EABFF006699FF004873FF003366CC000055FF000049DC00003D
    B900003399000025730000195000D4D4FF00B1B1FF008E8EFF006B6BFF004848
    FF002525FF000000FF000000DC000000B900000096000000770000005000E3D4
    FF00C7B1FF00AB8EFF008F6BFF007348FF005725FF005500FF004900DC003D00
    B900310096002500730019005000F0D4FF00E2B1FF00D48EFF00C66BFF00B848
    FF00AA25FF00AA00FF009200DC007A00B900620096004A00730032005000FFD4
    FF00FFB1FF00FF8EFF00FF6BFF00FF48FF00FF25FF00FF00FF00DC00DC00B900
    B900960096007300730050005000FFD4F000FFB1E200FF8ED400FF6BC600FF48
    B800FF25AA00FF00AA00DC009200B9007A009600620073004A0050003200FFD4
    E300FFB1C700FF8EAB00FF6B8F00FF487300FF255700FF005500DC004900B900
    3D00960031007300250050001900FFD4D400FFB1B100FF8E8E00FF6B6B00FF48
    4800FF252500FF000000DC000000B9000000960000007300000050000000FFE3
    D400FFC7B100FFAB8E00FF8F6B00FF734800FF572500FF550000DC490000B93D
    0000963100007325000050190000FFF0D400FFE2B100FFD48E00FFC66B00FFB8
    4800FFAA2500FFAA0000DC920000B97A000096620000734A000050320000FFFF
    D400FFFFB100FFFF8E00FFFF6B00FFFF4800FFFF2500FFFF0000DCDC0000B9B9
    0000969600007373000050500000F0FFD400E2FFB100D4FF8E00C6FF6B00B8FF
    4800AAFF2500AAFF000092DC00007AB90000629600004A73000032500000E3FF
    D400C7FFB100ABFF8E008FFF6B0073FF480057FF250055FF000049DC00003DB9
    0000319600002573000019500000D4FFD400B1FFB1008EFF8E006BFF6B0048FF
    480025FF250000FF000000DC000000B90000009600000073000000500000D4FF
    E300B1FFC7008EFFAB006BFF8F0048FF730025FF570000FF550000DC490000B9
    3D00009631000073250000501900D4FFF000B1FFE2008EFFD4006BFFC60048FF
    B80025FFAA0000FFAA0000DC920000B97A000096620000734A0000503200CCFF
    FF00B1FFFF008EFFFF0066FFFF0048FFFF0025FFFF0000CCFF0000DCDC0000B9
    B900009696000073730000505000F2F2F200E6E6E600DCDCDC00CDCDCD00D0D0
    D000B6B6B600AAAAAA009E9E9E0092929200888888007A7A7A006E6E6E006262
    620055555500444444003E3E3E0032323200262626001A1A1A000E0E0E000000
    000000000000000000000000000000F9F0131313131313131313F20000EE00F9
    110F0F0F0F0F0F0F0F0F130000EE00F9110FF6F9F9F9F9F9F60F1300000000F9
    110F0F0F0F0F0F0F0F0F1300000000F911EEF6F900FC3636F60F1300000000F9
    110FEEEEFC1D1D1D36131300000000F911EEF6F92516171A1C36F600000000F9
    110FEEEE1A1616E61A1C3600000000F911EEF6F9F91AE0E3E61A1C36000000F9
    110FEE0FEEEE1AE0E3E61AFA360000F911EEF6F9F913EE1AE0E3F5F5253600F9
    11EE0FEEEE0FEEEE1A11EF23252900F911EEEEEE0FEEEE0FEE1C1616232900F9
    071111111111111111111C1C1C000000F9F9F9F9F9F9F9F9F9F9F9000000C007
    0000800200008002000080030000800300008003000080030000800300008003
    0000800300008001000080000000800000008000000080010000C0070000}
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnHelp: TButton
    Left = 534
    Top = 420
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 374
    Top = 420
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 454
    Top = 420
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 601
    Height = 121
    Anchors = [akLeft, akTop, akRight]
    Caption = '&Options'
    TabOrder = 3
    object lbl2: TLabel
      Left = 8
      Top = 47
      Width = 27
      Height = 13
      Caption = 'Desc:'
    end
    object lbl3: TLabel
      Left = 384
      Top = 19
      Width = 45
      Height = 13
      Caption = 'Shortcut:'
    end
    object lbl4: TLabel
      Left = 384
      Top = 47
      Width = 44
      Height = 13
      Caption = 'Location:'
    end
    object lbl5: TLabel
      Left = 176
      Top = 19
      Width = 25
      Height = 13
      Caption = 'Icon:'
    end
    object lbl7: TLabel
      Left = 8
      Top = 19
      Width = 24
      Height = 13
      Caption = 'Title:'
    end
    object btnOpen: TSpeedButton
      Left = 348
      Top = 16
      Width = 20
      Height = 20
      Glyph.Data = {
        DE000000424DDE0000000000000076000000280000000D0000000D0000000100
        0400000000006800000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
        F000F000000000FFF00000888888880FF000080FBFBFBF0FFA5F080BFBFBFBF0
        F0000880BFBFBFB0F0000880FBFBFBFB0000088800000000000008888888880F
        F0000888800000FFF000F0000FFFFFFFF000FFFFFFFFFFFFF000FFFFFFFFFFFF
        F000}
      OnClick = btnOpenClick
    end
    object edtHint: TEdit
      Left = 42
      Top = 44
      Width = 327
      Height = 21
      TabOrder = 3
    end
    object HotKey: THotKey
      Left = 438
      Top = 16
      Width = 155
      Height = 19
      Anchors = [akLeft, akTop, akRight]
      HotKey = 0
      InvalidKeys = [hcNone]
      Modifiers = []
      TabOrder = 2
    end
    object cbbInsertPos: TComboBox
      Left = 438
      Top = 44
      Width = 155
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 4
    end
    object edtIcon: TEdit
      Left = 216
      Top = 16
      Width = 129
      Height = 21
      TabOrder = 1
    end
    object chkDisabled: TCheckBox
      Left = 40
      Top = 72
      Width = 153
      Height = 17
      Caption = 'Disable this Template'
      TabOrder = 5
    end
    object edtCaption: TEdit
      Left = 42
      Top = 16
      Width = 119
      Height = 21
      TabOrder = 0
    end
    object chkSavePos: TCheckBox
      Left = 216
      Top = 72
      Width = 313
      Height = 17
      Caption = 'Restore Cursor Position after Insert'
      TabOrder = 6
    end
    object chkForDelphi: TCheckBox
      Left = 40
      Top = 96
      Width = 169
      Height = 17
      Caption = 'For Pascal File'
      TabOrder = 7
    end
    object chkForBcb: TCheckBox
      Left = 216
      Top = 96
      Width = 153
      Height = 17
      Caption = 'For C/C++ File'
      TabOrder = 8
    end
  end
  object grp2: TGroupBox
    Left = 8
    Top = 136
    Width = 601
    Height = 273
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Conte&nt'
    TabOrder = 4
    object lbl6: TLabel
      Left = 8
      Top = 18
      Width = 65
      Height = 13
      Caption = 'Insert Macro:'
    end
    object mmoContent: TMemo
      Left = 8
      Top = 44
      Width = 585
      Height = 217
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 2
      WantTabs = True
      WordWrap = False
    end
    object cbbMacro: TComboBox
      Left = 72
      Top = 16
      Width = 433
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 0
    end
    object btnInsert: TButton
      Left = 517
      Top = 16
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Insert'
      TabOrder = 1
      OnClick = btnInsertClick
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'ico'
    Filter = 'Icon Files(*.ico)|*.ico'
    Left = 8
    Top = 416
  end
end
