object CnSenderFilterFrm: TCnSenderFilterFrm
  Left = 221
  Top = 144
  BorderStyle = bsDialog
  Caption = 'Sender Filter Settings'
  ClientHeight = 262
  ClientWidth = 187
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpSender: TGroupBox
    Left = 8
    Top = 8
    Width = 172
    Height = 215
    Caption = 'Filter Conditions at &Sender'
    TabOrder = 0
    object lblLevel: TLabel
      Left = 24
      Top = 40
      Width = 44
      Height = 13
      Caption = '&Level <='
      FocusControl = cbbLevel
    end
    object lblTag: TLabel
      Left = 24
      Top = 64
      Width = 29
      Height = 13
      Caption = '&Tag ='
      FocusControl = edtTag
    end
    object lblTypes: TLabel
      Left = 24
      Top = 90
      Width = 113
      Height = 13
      Caption = 'Allowed &Message Type:'
    end
    object chkEnable: TCheckBox
      Left = 8
      Top = 16
      Width = 153
      Height = 17
      Caption = '&Enable Sender Filter'
      TabOrder = 0
      OnClick = chkEnableClick
    end
    object cbbLevel: TComboBox
      Left = 80
      Top = 38
      Width = 81
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        '0'
        '1'
        '2'
        '3')
    end
    object edtTag: TEdit
      Left = 80
      Top = 62
      Width = 81
      Height = 21
      MaxLength = 8
      TabOrder = 2
    end
    object lstMsgTypes: TCheckListBox
      Left = 24
      Top = 107
      Width = 137
      Height = 97
      ItemHeight = 13
      TabOrder = 3
      OnKeyPress = lstMsgTypesKeyPress
    end
  end
  object btnOK: TButton
    Left = 23
    Top = 232
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 103
    Top = 232
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
