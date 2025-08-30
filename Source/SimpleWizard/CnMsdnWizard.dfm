inherited CnMsdnConfigForm: TCnMsdnConfigForm
  Left = 330
  Top = 250
  BorderStyle = bsDialog
  Caption = 'MSDN Wizard Settings'
  ClientHeight = 329
  ClientWidth = 401
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 156
    Top = 300
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 236
    Top = 300
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object grpToolbar: TGroupBox
    Left = 8
    Top = 8
    Width = 385
    Height = 65
    Caption = '&Toolbar'
    TabOrder = 0
    object lblMaxHistory: TLabel
      Left = 8
      Top = 40
      Width = 115
      Height = 13
      Caption = 'Maximum History Items:'
    end
    object lblHistoryUnit: TLabel
      Left = 240
      Top = 40
      Width = 27
      Height = 13
      Caption = 'Items'
    end
    object cbShowToolbar: TCheckBox
      Left = 8
      Top = 16
      Width = 145
      Height = 17
      Caption = 'Show MSDN toolbar.'
      TabOrder = 0
    end
    object seMaxHistory: TCnSpinEdit
      Left = 152
      Top = 36
      Width = 81
      Height = 22
      MaxLength = 2
      MaxValue = 99
      MinValue = 1
      TabOrder = 1
      Value = 10
      OnKeyPress = seMaxHistoryKeyPress
    end
    object btnSetShortCut: TButton
      Left = 292
      Top = 36
      Width = 85
      Height = 21
      Caption = 'Hot&key'
      TabOrder = 2
      OnClick = btnSetShortCutClick
    end
  end
  object grpSetMsdn: TGroupBox
    Left = 8
    Top = 80
    Width = 385
    Height = 212
    Caption = '&Set MSDN'
    TabOrder = 1
    object rbDefault: TRadioButton
      Left = 8
      Top = 16
      Width = 220
      Height = 17
      Caption = '&Default'
      TabOrder = 0
    end
    object rbFollow: TRadioButton
      Left = 8
      Top = 40
      Width = 220
      Height = 17
      Caption = '&Use the following MSDN.'
      TabOrder = 1
      OnClick = rbFollowClick
    end
    object lstMsdn: TListBox
      Left = 8
      Top = 64
      Width = 368
      Height = 89
      ItemHeight = 13
      TabOrder = 2
      OnClick = lstMsdnClick
    end
    object rbWeb: TRadioButton
      Left = 8
      Top = 160
      Width = 273
      Height = 17
      Caption = 'U&se MSDN online (%s represents the Keyword).'
      TabOrder = 4
    end
    object edtWeb: TEdit
      Left = 8
      Top = 181
      Width = 368
      Height = 21
      TabOrder = 5
      OnChange = edtWebChange
    end
    object btnDefaultURL: TButton
      Left = 292
      Top = 156
      Width = 85
      Height = 21
      Caption = '&Default URL'
      TabOrder = 3
      OnClick = btnDefaultURLClick
    end
  end
  object btnHelp: TButton
    Left = 318
    Top = 300
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
end
