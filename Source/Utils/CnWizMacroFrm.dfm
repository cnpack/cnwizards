inherited CnWizMacroForm: TCnWizMacroForm
  Left = 331
  Top = 266
  ActiveControl = cbbValue0
  BorderStyle = bsDialog
  Caption = 'Macro Replacement'
  ClientHeight = 127
  ClientWidth = 391
  PixelsPerInch = 96
  TextHeight = 13
  object lblMacro0: TLabel
    Left = 48
    Top = 27
    Width = 33
    Height = 13
    Caption = 'Macro:'
  end
  object lblValue0: TLabel
    Left = 192
    Top = 27
    Width = 30
    Height = 13
    Caption = 'Value:'
  end
  object imgIcon: TImage
    Left = 8
    Top = 24
    Width = 32
    Height = 32
    Picture.Data = {
      055449636F6E0000010001002020100000000000E80200001600000028000000
      2000000040000000010004000000000080020000000000000000000000000000
      0000000000000000000080000080000000808000800000008000800080800000
      80808000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
      FFFFFF0000000000000000000000000000000000000000000000007777770000
      0000000000000000000000000007000000000000000000000000000000070000
      0000000000000000000000777007000000000000000000077070007770070000
      7000000000000077000700787000000007000000000007708000077877000070
      00700000000007088807777777770777000700000000008F88877FFFFF077887
      70070000000000088888F88888FF08870070000000000000880888877778F070
      00700000000777088888880007778F770077777000700008F088007777077F07
      000000700700008F08880800077778F7700000700708888F0880F08F807078F7
      777700700708F88F0780F070F07078F7887700700708888F0780F077807088F7
      777700700700008F0788FF00080888F77000007000000008F0780FFFF0088F77
      0070000000000008F07788000888887700700000000000008F07788888880870
      00700000000000088FF0077788088887000700000000008F888FF00000F87887
      7007000000000708F8088FFFFF88078700700000000007708000088888000070
      0700000000000077007000888007000070000000000000077700008F80070007
      0000000000000000000000888007000000000000000000000000000000070000
      0000000000000000000007777777000000000000000000000000000000000000
      00000000FFFFFFFFFFFC0FFFFFFC0FFFFFF80FFFFFF80FFFFE180E7FFC00043F
      F800001FF800000FF800000FFC00001FFE00001FE0000001C000000180000001
      80000001800000018000000180000001FC00001FFC00001FFE00001FFC00000F
      F800000FF800001FF800003FFC180C7FFE380EFFFFF80FFFFFF80FFFFFF80FFF
      FFFFFFFF}
  end
  object Label3: TLabel
    Left = 8
    Top = 7
    Width = 48
    Height = 13
    Caption = 'Replace:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 72
    Top = 4
    Width = 315
    Height = 10
    Shape = bsBottomLine
  end
  object lblMacro1: TLabel
    Left = 48
    Top = 52
    Width = 33
    Height = 13
    Caption = 'Macro:'
  end
  object lblValue1: TLabel
    Left = 192
    Top = 52
    Width = 30
    Height = 13
    Caption = 'Value:'
  end
  object edtMacro0: TEdit
    Left = 88
    Top = 24
    Width = 97
    Height = 21
    TabStop = False
    ParentColor = True
    ReadOnly = True
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 84
    Width = 391
    Height = 43
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel2: TBevel
      Left = 5
      Top = -4
      Width = 382
      Height = 10
      Shape = bsBottomLine
    end
    object btnHelp: TButton
      Left = 310
      Top = 16
      Width = 75
      Height = 21
      Caption = '&Help'
      TabOrder = 2
      OnClick = btnHelpClick
    end
    object btnOK: TButton
      Left = 150
      Top = 16
      Width = 75
      Height = 21
      Caption = '&OK'
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 230
      Top = 16
      Width = 75
      Height = 21
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object edtMacro1: TEdit
    Left = 88
    Top = 49
    Width = 97
    Height = 21
    TabStop = False
    ParentColor = True
    ReadOnly = True
    TabOrder = 3
  end
  object cbbValue0: TComboBox
    Left = 232
    Top = 24
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    OnKeyPress = cbbValue0KeyPress
  end
  object cbbValue1: TComboBox
    Left = 232
    Top = 49
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 4
    OnKeyPress = cbbValue0KeyPress
  end
end
