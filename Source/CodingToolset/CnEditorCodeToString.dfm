inherited CnEditorCodeToStringForm: TCnEditorCodeToStringForm
  Left = 418
  Top = 235
  BorderStyle = bsDialog
  Caption = 'Code to String Tool Settings'
  ClientHeight = 165
  ClientWidth = 264
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 102
    Top = 136
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 182
    Top = 136
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 249
    Height = 121
    Anchors = [akLeft, akTop, akRight, akBottom]
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
      Width = 137
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object edtCReturn: TEdit
      Left = 104
      Top = 40
      Width = 137
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object cbSkipSpace: TCheckBox
      Left = 8
      Top = 72
      Width = 233
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Ignore Spaces in Line Head.'
      TabOrder = 2
    end
    object chkAddAtHead: TCheckBox
      Left = 8
      Top = 96
      Width = 233
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Put + to Next Line Head in Delphi.'
      TabOrder = 3
    end
  end
end
