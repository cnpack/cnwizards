inherited CnEditorCodeToStringForm: TCnEditorCodeToStringForm
  Left = 418
  Top = 235
  BorderStyle = bsDialog
  Caption = 'Code to String Tool Settings'
  ClientHeight = 141
  ClientWidth = 248
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 86
    Top = 112
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 166
    Top = 112
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 97
    Caption = '&Settings'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 20
      Width = 84
      Height = 13
      Caption = 'Delphi Line Wrap:'
    end
    object Label2: TLabel
      Left = 8
      Top = 44
      Width = 62
      Height = 13
      Caption = 'C Line Wrap:'
    end
    object edtDelphiReturn: TEdit
      Left = 104
      Top = 16
      Width = 121
      Height = 21
      TabOrder = 1
    end
    object edtCReturn: TEdit
      Left = 104
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 2
    end
    object cbSkipSpace: TCheckBox
      Left = 8
      Top = 72
      Width = 217
      Height = 17
      Caption = 'Ignore Spaces in Line Head.'
      TabOrder = 0
    end
  end
end
