inherited CnTabOrderForm: TCnTabOrderForm
  Left = 324
  Top = 236
  BorderStyle = bsDialog
  Caption = 'Tab Order Wizard Settings'
  ClientHeight = 262
  ClientWidth = 417
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object imgVF: TImage
    Left = 176
    Top = 22
    Width = 16
    Height = 16
    AutoSize = True
    Picture.Data = {
      07544269746D6170F6000000424DF60000000000000076000000280000001000
      0000100000000100040000000000800000000000000000000000100000000000
      0000000000000000800000800000008080008000000080008000808000008080
      8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
      FF00888888888888888888888888888488888888888888844888884444444444
      4488888888888884488888884448888488888888448888888888888848488888
      8888888888848888888888888888488888888888888884848888888888888884
      4888884444444444448888888888888448888888888888848888888888888888
      8888}
    Transparent = True
  end
  object imgHF: TImage
    Left = 176
    Top = 46
    Width = 16
    Height = 16
    AutoSize = True
    Picture.Data = {
      07544269746D6170F6000000424DF60000000000000076000000280000001000
      0000100000000100040000000000800000000000000000000000100000000000
      0000000000000000800000800000008080008000000080008000808000008080
      8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
      FF00888888888888888888888888888888888884888888884888884448888884
      4488844444888844444888848888888848888884848888884888888488488888
      4888888488848888488888848888484848888884888884484888888488884448
      4888888488888888488888848888888848888888888888888888888888888888
      8888}
    Transparent = True
  end
  object btnHelp: TButton
    Left = 334
    Top = 232
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 6
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 174
    Top = 232
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 254
    Top = 232
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
    Width = 161
    Height = 61
    Caption = 'So&rt Mode'
    ItemIndex = 0
    Items.Strings = (
      'Vertical First.'
      'Horizontal First.')
    TabOrder = 0
  end
  object gbOther: TGroupBox
    Left = 8
    Top = 144
    Width = 401
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
      Left = 304
      Top = 50
      Width = 83
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = 'Hot&key'
      TabOrder = 3
      OnClick = btnShortCutClick
    end
  end
  object gbDispTabOrder: TGroupBox
    Left = 200
    Top = 8
    Width = 209
    Height = 129
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
      Top = 97
      Width = 44
      Height = 13
      Caption = 'BK Color:'
    end
    object spBkColor: TShape
      Left = 88
      Top = 94
      Width = 20
      Height = 20
      OnMouseDown = spBkColorMouseDown
    end
    object Label8: TLabel
      Left = 26
      Top = 69
      Width = 57
      Height = 13
      Caption = 'Label Color:'
    end
    object spLabel: TShape
      Left = 88
      Top = 66
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
      Top = 66
      Width = 81
      Height = 21
      Caption = '&Font'
      TabOrder = 2
      OnClick = btnFontClick
    end
  end
  object gbAddCheck: TGroupBox
    Left = 8
    Top = 76
    Width = 185
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
