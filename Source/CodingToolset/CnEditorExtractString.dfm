inherited CnExtractStringForm: TCnExtractStringForm
  Left = 232
  Top = 124
  Width = 895
  Height = 621
  ActiveControl = btnReScan
  Caption = 'Extract Strings in Current Unit'
  Font.Charset = ANSI_CHARSET
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000040010000000000000000000000010000000000000000
    0000800080008000000080800000008000000080800000008000E5BFBF00C0DC
    C000E5BEBE00CB7F7F00FF00FF00FF000000FFFF000000FF000000FFFF000000
    FF00FFFFFF00F0FBFF00A4A0A000D4F0FF00B1E2FF008ED4FF006BC6FF0048B8
    FF0025AAFF0000AAFF000092DC00007AB90000629600004A730000325000D4E3
    FF00B1C7FF008EABFF006B8FFF004873FF002557FF000055FF000049DC00003D
    B900003196000025730000195000D4D4FF00B1B1FF008E8EFF006B6BFF004848
    FF002525FF000000FF000000DC000000B900000096000000730000005000E3D4
    FF00C7B1FF00AB8EFF008F6BFF007348FF005725FF005500FF004900DC003D00
    B900310096002500730019005000F0D4FF00E2B1FF00D48EFF00C66BFF00B848
    FF00AA25FF00AA00FF009200DC007A00B900620096004A00730032005000FFD4
    FF00FFB1FF00FF8EFF00FF6BFF00FF48FF00FF25FF00FF00FF00DC00DC00B900
    B900960096007300730050005000FFD4F000FFB1E200FF8ED400FF6BC600FF48
    B800FF25AA00FF00AA00DC009200B9007A009600620073004A0050003200F1DE
    DE00FFB1C700FF8EAB00FF6B8F00FF487300FF255700FF005500DC004900B13E
    3E009D0E0E007300250050001900FFD4D400FFB1B100CB7E7E00FF6B6B00B74E
    4E00FF252500FF000000DC000000B9000000970000007300000050000000FFE3
    D400FFC7B100FFAB8E00FF8F6B00FF734800FF572500FF550000DC490000B23F
    3F00963100007325000050190000FFF0D400FFE2B100FFD48E00FFC66B00FFB8
    4800FFAA2500FFAA0000DC920000B97A000096620000734A000050320000FFFF
    D400FFFFB100FFFF8E00FFFF6B00FFFF4800FFFF2500FFFF0000DCDC0000B9B9
    0000969600007373000050500000F0FFD400E2FFB100D4FF8E00C6FF6B00B8FF
    4800AAFF2500AAFF000092DC00007AB90000629600004A73000032500000E3FF
    D400C7FFB100ABFF8E008FFF6B0073FF480057FF250055FF000049DC00003DB9
    0000319600002573000019500000D4FFD400B1FFB1008EFF8E006BFF6B0048FF
    480025FF250000FF000000DC000000B90000009600000073000000500000D4FF
    E300B1FFC7008EFFAB006BFF8F0048FF730025FF570000FF550000DC490000B9
    3D00009631000073250000501900D4FFF000B1FFE2008EFFD4006BFFC60048FF
    B80025FFAA0000FFAA0000DC920000B97A000096620000734A0000503200D4FF
    FF00B1FFFF008EFFFF006BFFFF0048FFFF0025FFFF0000FFFF0000DCDC0000B9
    B900009696000073730000505000F8EEEE00F2DFDF00F0DDDD00CECECE00E4BE
    BE00B6B6B600AAAAAA009E9E9E00D08D8D00CA7E7E007A7A7A006E6E6E006262
    6200565656004A4A4A003E3E3E0032323200262626001A1A1A000E0E0E000000
    0000000000000000000000000000000000000000000000000000000000000000
    00760000000000000076000000000000007D000000000000007D000000000000
    0071700000000000007170000000000000787D070000000000787D0700000000
    00767D700000000000767D700000000000000AF50000000000000AF500000000
    000000000000000000000000000000002D282D00000000000000000000000000
    282828000000000000000000000000002D282D00002D282D0000000000000000
    000000000028282800002D282D00000000000000002D282D0000282828000000
    000000000000000000002D282D0000000000000000000000000000000000FFFF
    0000FFFF0000EFEF0000EFEF0000E7E70000E3E30000E3E30000F3F30000FFFF
    0000C7FF0000C7FF0000C63F0000FE310000FE310000FFF10000FFFF0000}
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblMake: TLabel
    Left = 8
    Top = 570
    Width = 32
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '&Make: '
    FocusControl = cbbMakeType
  end
  object lblToArea: TLabel
    Left = 200
    Top = 570
    Width = 19
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '&To: '
    FocusControl = cbbToArea
  end
  object btnCopy: TSpeedButton
    Left = 164
    Top = 566
    Width = 23
    Height = 22
    Action = actCopy
    Anchors = [akLeft, akBottom]
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000000000000000000000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FFB58C8C8C5A5A8C5A5A8C5A5A8C5A5A8C5A5A8C5A5A8C5A
      5A8C5A5A8C5A5AFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFB58C8CFFF7E7F7
      EFDEF7EFDEF7EFDEF7EFDEF7EFDEF7EFDEF7E7CE8C5A5AFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFB58C8CF7EFDEF7DECEF7DEC6F7DEC6F7DEC6F7DEC6EFDE
      CEEFDECE8C5A5AFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFB58C8CFFF7E7FF
      D6A5FFD6A5FFD6A5FFD6A5FFD6A5FFD6A5EFDECE8C5A5AFF00FFFF00FFB58C8C
      8C5A5A8C5A5A8C5A5AB58C8CFFF7EFF7DEC6F7DEC6F7DEC6F7DEC6F7DEBDF7E7
      CEEFDECE9C6B63FF00FFFF00FFB58C8CFFF7E7F7EFDEF7EFDEB58C8CFFF7EFF7
      E7CEF7DEC6F7DEC6F7DEC6F7DEC6F7E7D6EFDECE9C6B6BFF00FFFF00FFB58C8C
      F7EFDEF7DECEF7DEC6B58C8CFFFFF7FFD6A5FFD6A5FFD6A5FFD6A5FFD6A5FFD6
      A5EFE7D6A57B73FF00FFFF00FFB58C8CFFF7E7FFD6A5FFD6A5B58C8CFFFFF7FF
      E7D6FFE7D6F7E7D6F7E7CEFFE7D6FFF7E7EFDEDEA57B73FF00FFFF00FFB58C8C
      FFF7EFF7DEC6F7DEC6B58C8CFFFFFFFFFFFFFFFFFFFFFFF7FFFFF7EFDEDED6C6
      C6BDADADB58473FF00FFFF00FFB58C8CFFF7EFF7E7CEF7DEC6B58C8CFFFFFFFF
      FFFFFFFFFFFFFFF7FFFFF7B58C8CB58C8CB58C8CB58C8CFF00FFFF00FFB58C8C
      FFFFF7FFD6A5FFD6A5B58C8CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB58C8CEFB5
      6BC68C7BFF00FFFF00FFFF00FFB58C8CFFFFF7FFE7D6FFE7D6B58C8CB58C8CB5
      8C8CB58C8CB58C8CB58C8CB58C8CBD8484FF00FFFF00FFFF00FFFF00FFB58C8C
      FFFFFFFFFFFFFFFFFFFFFFF7FFFFF7EFDEDED6C6C6BDADADB58473FF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFB58C8CFFFFFFFFFFFFFFFFFFFFFFF7FFFFF7B5
      8C8CB58C8CB58C8CB58C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFB58C8C
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB58C8CEFB56BC68C7BFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFB58C8CB58C8CB58C8CB58C8CB58C8CB58C8CB5
      8C8CBD8484FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
    ParentShowHint = False
    ShowHint = True
  end
  object grpScanOption: TGroupBox
    Left = 512
    Top = 8
    Width = 249
    Height = 97
    Caption = 'Scan &Option'
    TabOrder = 1
    object chkIgnoreSingleChar: TCheckBox
      Left = 12
      Top = 20
      Width = 228
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Ignore Single Char Strings'
      TabOrder = 0
    end
    object chkIgnoreSimpleFormat: TCheckBox
      Left = 12
      Top = 44
      Width = 228
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Ignore Simple Format Strings'
      TabOrder = 1
    end
    object chkShowPreview: TCheckBox
      Left = 12
      Top = 68
      Width = 205
      Height = 17
      Caption = 'Show Preview'
      TabOrder = 2
      OnClick = chkShowPreviewClick
    end
  end
  object grpPinYinOption: TGroupBox
    Left = 8
    Top = 8
    Width = 497
    Height = 97
    Caption = '&Name Option'
    TabOrder = 0
    object lblPinYin: TLabel
      Left = 16
      Top = 68
      Width = 59
      Height = 13
      Caption = 'PinYin Rule: '
    end
    object lblPrefix: TLabel
      Left = 16
      Top = 20
      Width = 32
      Height = 13
      Caption = 'Prefix:'
    end
    object lblStyle: TLabel
      Left = 16
      Top = 44
      Width = 28
      Height = 13
      Caption = 'Style:'
    end
    object lblMaxWords: TLabel
      Left = 256
      Top = 20
      Width = 58
      Height = 13
      Caption = 'Max Words:'
    end
    object lblMaxPinYin: TLabel
      Left = 256
      Top = 44
      Width = 55
      Height = 13
      Caption = 'Max PinYin:'
    end
    object cbbPinYinRule: TComboBox
      Left = 88
      Top = 64
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 6
      Items.Strings = (
        'Initials'
        'Full PinYin')
    end
    object edtPrefix: TEdit
      Left = 88
      Top = 16
      Width = 145
      Height = 21
      TabOrder = 0
    end
    object cbbIdentWordStyle: TComboBox
      Left = 88
      Top = 40
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      Items.Strings = (
        'Upper Case'
        'Lower Case'
        'Upper First Letter')
    end
    object edtMaxWords: TEdit
      Left = 336
      Top = 16
      Width = 121
      Height = 21
      TabOrder = 1
      Text = '0'
    end
    object udMaxWords: TUpDown
      Left = 457
      Top = 16
      Width = 15
      Height = 21
      Associate = edtMaxWords
      Min = 0
      Position = 0
      TabOrder = 2
      Wrap = False
    end
    object edtMaxPinYin: TEdit
      Left = 336
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 4
      Text = '0'
    end
    object udMaxPinYin: TUpDown
      Left = 457
      Top = 40
      Width = 15
      Height = 21
      Associate = edtMaxPinYin
      Min = 0
      Position = 0
      TabOrder = 5
      Wrap = False
    end
    object chkUseUnderLine: TCheckBox
      Left = 256
      Top = 68
      Width = 233
      Height = 17
      Caption = 'Use UnderLine as Word Separator'
      TabOrder = 7
    end
  end
  object btnReScan: TButton
    Left = 769
    Top = 14
    Width = 108
    Height = 91
    Action = actRescan
    Anchors = [akTop, akRight]
    TabOrder = 2
  end
  object pnl1: TPanel
    Left = 8
    Top = 112
    Width = 870
    Height = 444
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    object spl1: TSplitter
      Left = 0
      Top = 317
      Width = 870
      Height = 4
      Cursor = crVSplit
      Align = alBottom
    end
    object lvStrings: TListView
      Left = 0
      Top = 0
      Width = 870
      Height = 317
      Align = alClient
      Columns = <
        item
          Caption = '#'
          Width = 30
        end
        item
          Caption = 'Name (Double Click to Edit)'
          Width = 340
        end
        item
          Caption = 'Value'
          Width = 415
        end>
      HideSelection = False
      OwnerData = True
      ReadOnly = True
      RowSelect = True
      PopupMenu = pmStrings
      ShowWorkAreas = True
      TabOrder = 0
      ViewStyle = vsReport
      OnData = lvStringsData
      OnDblClick = lvStringsDblClick
      OnSelectItem = lvStringsSelectItem
    end
    object mmoPreview: TMemo
      Left = 0
      Top = 321
      Width = 870
      Height = 123
      Align = alBottom
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object cbbMakeType: TComboBox
    Left = 64
    Top = 566
    Width = 97
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    TabOrder = 4
  end
  object cbbToArea: TComboBox
    Left = 232
    Top = 566
    Width = 137
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    TabOrder = 5
  end
  object btnHelp: TButton
    Left = 804
    Top = 566
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 8
    OnClick = btnHelpClick
  end
  object btnReplace: TButton
    Left = 644
    Top = 566
    Width = 75
    Height = 21
    Action = actReplace
    Anchors = [akRight, akBottom]
    Default = True
    TabOrder = 6
  end
  object btnClose: TButton
    Left = 724
    Top = 566
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 7
  end
  object actlstExtract: TActionList
    OnUpdate = actlstExtractUpdate
    Left = 384
    Top = 520
    object actRescan: TAction
      Caption = '&Scan'
      OnExecute = actRescanExecute
    end
    object actCopy: TAction
      Caption = '&Copy'
      Hint = 'Copy Declarations to Clipboard'
      OnExecute = actCopyExecute
    end
    object actReplace: TAction
      Caption = '&Replace'
      OnExecute = actReplaceExecute
    end
    object actEdit: TAction
      Caption = '&Edit'
      OnExecute = actEditExecute
    end
    object actDelete: TAction
      Caption = '&Delete'
      ShortCut = 46
      OnExecute = actDeleteExecute
    end
  end
  object pmStrings: TPopupMenu
    Left = 224
    Top = 232
    object Edit1: TMenuItem
      Action = actEdit
      Default = True
    end
    object Delete1: TMenuItem
      Action = actDelete
    end
  end
end
