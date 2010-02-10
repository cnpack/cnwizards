inherited CnPrefixNewForm: TCnPrefixNewForm
  Left = 351
  Top = 291
  ActiveControl = edtPrefix
  BorderStyle = bsDialog
  Caption = 'Enter Component Prefix'
  ClientHeight = 179
  ClientWidth = 280
  PixelsPerInch = 96
  TextHeight = 13
  object gbNew: TGroupBox
    Left = 8
    Top = 8
    Width = 265
    Height = 137
    Caption = 'Enter &New Prefix'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 24
      Width = 195
      Height = 13
      Caption = 'Enter new Prefix for Current Component'
    end
    object lbl3: TLabel
      Left = 8
      Top = 72
      Width = 28
      Height = 13
      Caption = 'Prefix'
    end
    object Label1: TLabel
      Left = 8
      Top = 48
      Width = 55
      Height = 13
      Caption = 'Class Name'
    end
    object edtPrefix: TEdit
      Left = 72
      Top = 68
      Width = 177
      Height = 21
      TabOrder = 1
      OnKeyPress = edtPrefixKeyPress
    end
    object cbNeverDisp: TCheckBox
      Left = 8
      Top = 112
      Width = 240
      Height = 17
      Caption = 'Never Ask Again.'
      TabOrder = 3
    end
    object edtComponent: TEdit
      Left = 72
      Top = 44
      Width = 177
      Height = 21
      ParentColor = True
      ReadOnly = True
      TabOrder = 0
    end
    object cbIgnore: TCheckBox
      Left = 8
      Top = 93
      Width = 240
      Height = 17
      Caption = 'Ignore This Type of Component.'
      TabOrder = 2
    end
  end
  object btnOK: TButton
    Left = 38
    Top = 152
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 118
    Top = 152
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 198
    Top = 152
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
