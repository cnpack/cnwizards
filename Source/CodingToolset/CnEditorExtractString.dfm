object CnExtractStringForm: TCnExtractStringForm
  Left = 274
  Top = 124
  Width = 837
  Height = 580
  Caption = 'Extract String'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
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
    Left = 184
    Top = 529
    Width = 19
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '&To: '
  end
  object grpScanOption: TGroupBox
    Left = 480
    Top = 8
    Width = 225
    Height = 97
    Caption = 'Scan &Option'
    TabOrder = 0
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
    TabOrder = 1
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
      TabOrder = 0
      Items.Strings = (
        'Initials'
        'Full PinYin')
    end
    object edtPrefix: TEdit
      Left = 80
      Top = 16
      Width = 145
      Height = 21
      TabOrder = 1
    end
    object cbbIdentWordStyle: TComboBox
      Left = 80
      Top = 40
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
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
      TabOrder = 3
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
      TabOrder = 4
      Wrap = False
    end
    object edtMaxPinYin: TEdit
      Left = 312
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 5
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
      TabOrder = 6
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
    Anchors = [akTop, akRight]
    Caption = 'Re&scan'
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
          Caption = 'Name'
          Width = 340
        end
        item
          Caption = 'Value'
          Width = 440
        end>
      TabOrder = 0
      ViewStyle = vsReport
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
    Items.Strings = (
      'const'
      'var')
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
    Items.Strings = (
      'interface'
      'implementation')
  end
  object btnHelp: TButton
    Left = 749
    Top = 525
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 6
  end
  object btnReplace: TButton
    Left = 589
    Top = 525
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Replace'
    Default = True
    ModalResult = 1
    TabOrder = 7
  end
  object btnClose: TButton
    Left = 669
    Top = 525
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 8
  end
end
