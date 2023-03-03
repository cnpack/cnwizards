object CnExtractStringForm: TCnExtractStringForm
  Left = 274
  Top = 124
  Width = 853
  Height = 580
  ActiveControl = btnReScan
  Caption = 'Extract String'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblMake: TLabel
    Left = 8
    Top = 529
    Width = 33
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '&Make: '
  end
  object lblToArea: TLabel
    Left = 200
    Top = 529
    Width = 19
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '&To: '
  end
  object btnCopy: TSpeedButton
    Left = 164
    Top = 524
    Width = 23
    Height = 22
    Action = actCopy
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
  end
  object grpScanOption: TGroupBox
    Left = 480
    Top = 8
    Width = 225
    Height = 97
    Caption = 'Scan &Option'
    TabOrder = 1
    object chkIgnoreSingleChar: TCheckBox
      Left = 12
      Top = 20
      Width = 204
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Ignore Single Char Strings'
      TabOrder = 0
    end
    object chkIgnoreSimpleFormat: TCheckBox
      Left = 12
      Top = 44
      Width = 204
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
    Width = 463
    Height = 97
    Caption = '&Name Option'
    TabOrder = 0
    object lblPinYin: TLabel
      Left = 16
      Top = 68
      Width = 61
      Height = 13
      Caption = 'PinYin Rule: '
    end
    object lblPrefix: TLabel
      Left = 16
      Top = 20
      Width = 29
      Height = 13
      Caption = 'Prefix:'
    end
    object lblStyle: TLabel
      Left = 16
      Top = 44
      Width = 26
      Height = 13
      Caption = 'Style:'
    end
    object lblMaxWords: TLabel
      Left = 248
      Top = 20
      Width = 57
      Height = 13
      Caption = 'Max Words:'
    end
    object lblMaxPinYin: TLabel
      Left = 248
      Top = 44
      Width = 56
      Height = 13
      Caption = 'Max PinYin:'
    end
    object cbbPinYinRule: TComboBox
      Left = 80
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
      Left = 80
      Top = 16
      Width = 145
      Height = 21
      TabOrder = 0
    end
    object cbbIdentWordStyle: TComboBox
      Left = 80
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
      Left = 312
      Top = 16
      Width = 121
      Height = 21
      TabOrder = 1
      Text = '0'
    end
    object udMaxWords: TUpDown
      Left = 433
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
      Left = 312
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 4
      Text = '0'
    end
    object udMaxPinYin: TUpDown
      Left = 433
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
      Left = 248
      Top = 68
      Width = 201
      Height = 17
      Caption = 'Use UnderLine as Word Separator'
      TabOrder = 7
    end
  end
  object btnReScan: TButton
    Left = 714
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
    Width = 815
    Height = 403
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    object spl1: TSplitter
      Left = 0
      Top = 276
      Width = 815
      Height = 4
      Cursor = crVSplit
      Align = alBottom
    end
    object lvStrings: TListView
      Left = 0
      Top = 0
      Width = 815
      Height = 276
      Align = alClient
      Columns = <
        item
          Caption = '#'
          Width = 30
        end
        item
          Caption = 'Name'
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
      ShowWorkAreas = True
      TabOrder = 0
      ViewStyle = vsReport
      OnData = lvStringsData
      OnDblClick = lvStringsDblClick
      OnSelectItem = lvStringsSelectItem
    end
    object mmoPreview: TMemo
      Left = 0
      Top = 280
      Width = 815
      Height = 123
      Align = alBottom
      TabOrder = 1
    end
  end
  object cbbMakeType: TComboBox
    Left = 64
    Top = 525
    Width = 97
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    TabOrder = 4
  end
  object cbbToArea: TComboBox
    Left = 232
    Top = 525
    Width = 137
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    TabOrder = 5
  end
  object btnHelp: TButton
    Left = 749
    Top = 525
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 8
  end
  object btnReplace: TButton
    Left = 589
    Top = 525
    Width = 75
    Height = 21
    Action = actReplace
    Anchors = [akRight, akBottom]
    Default = True
    TabOrder = 6
  end
  object btnClose: TButton
    Left = 669
    Top = 525
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
      Caption = 'Re&scan'
      OnExecute = actRescanExecute
    end
    object actCopy: TAction
      Caption = '&Copy'
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
  end
end
