inherited CnTabOrderForm: TCnTabOrderForm
  Left = 324
  Top = 236
  BorderStyle = bsDialog
  Caption = 'Tab Order Wizard Settings'
  ClientHeight = 251
  ClientWidth = 350
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnHelp: TButton
    Left = 270
    Top = 224
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 6
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 110
    Top = 224
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 190
    Top = 224
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object rgTabOrderStyle: TRadioGroup
    Left = 8
    Top = 8
    Width = 121
    Height = 53
    Caption = 'So&rt Mode'
    ItemIndex = 0
    Items.Strings = (
      'Vertical First.'
      'Horizontal First.')
    TabOrder = 0
  end
  object gbOther: TGroupBox
    Left = 8
    Top = 136
    Width = 337
    Height = 81
    Caption = 'O&ther Settings'
    TabOrder = 3
    object cbOrderByCenter: TCheckBox
      Left = 8
      Top = 53
      Width = 225
      Height = 17
      Caption = 'Calculate Using Component'#39's Center.'
      TabOrder = 2
    end
    object cbIncludeChildren: TCheckBox
      Left = 8
      Top = 35
      Width = 225
      Height = 17
      Caption = 'Process All Sub-components.'
      TabOrder = 1
    end
    object cbAutoReset: TCheckBox
      Left = 8
      Top = 16
      Width = 225
      Height = 17
      Caption = 'Auto Update Tab Orders when Moved.'
      TabOrder = 0
    end
    object btnShortCut: TButton
      Left = 240
      Top = 50
      Width = 83
      Height = 21
      Caption = 'Hot&key'
      TabOrder = 3
      OnClick = btnShortCutClick
    end
  end
  object gbDispTabOrder: TGroupBox
    Left = 136
    Top = 8
    Width = 209
    Height = 121
    Caption = 'Tab Order &Label'
    TabOrder = 2
    object Label5: TLabel
      Left = 26
      Top = 40
      Width = 41
      Height = 13
      Caption = 'Position:'
    end
    object Label7: TLabel
      Left = 26
      Top = 87
      Width = 44
      Height = 13
      Caption = 'BK Color:'
    end
    object spBkColor: TShape
      Left = 88
      Top = 84
      Width = 20
      Height = 20
      OnMouseDown = spBkColorMouseDown
    end
    object Label8: TLabel
      Left = 26
      Top = 63
      Width = 57
      Height = 13
      Caption = 'Label Color:'
    end
    object spLabel: TShape
      Left = 88
      Top = 60
      Width = 20
      Height = 20
      OnMouseDown = spLabelMouseDown
    end
    object cbDispTabOrder: TCheckBox
      Left = 8
      Top = 16
      Width = 193
      Height = 17
      Caption = 'Show Tab Order on the Form.'
      TabOrder = 0
      OnClick = cbDispTabOrderClick
    end
    object cbbDispPos: TComboBox
      Left = 88
      Top = 36
      Width = 105
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        'Top Left'
        'Top Right'
        'Bottom Left'
        'Bottom Right'
        'Left'
        'Right'
        'Top'
        'Bottom'
        'Center')
    end
    object btnFont: TButton
      Left = 112
      Top = 60
      Width = 81
      Height = 21
      Caption = '&Font'
      TabOrder = 2
      OnClick = btnFontClick
    end
  end
  object gbAddCheck: TGroupBox
    Left = 8
    Top = 68
    Width = 121
    Height = 61
    Caption = '&Add-on Process'
    TabOrder = 1
    object cbInvert: TCheckBox
      Left = 8
      Top = 16
      Width = 110
      Height = 17
      Caption = 'Inverse Sort.'
      TabOrder = 0
    end
    object cbGroup: TCheckBox
      Left = 8
      Top = 35
      Width = 110
      Height = 17
      Caption = 'By Groups.'
      TabOrder = 1
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 8
    Top = 216
  end
  object ColorDialog: TColorDialog
    Ctl3D = True
    Options = [cdAnyColor]
    Left = 40
    Top = 216
  end
end
