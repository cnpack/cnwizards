object TestRegExprForm: TTestRegExprForm
  Left = 192
  Top = 130
  Caption = 'Test RegExpr'
  ClientHeight = 210
  ClientWidth = 431
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblPattern: TLabel
    Left = 24
    Top = 32
    Width = 37
    Height = 13
    Caption = 'Pattern:'
  end
  object lblContent: TLabel
    Left = 24
    Top = 64
    Width = 40
    Height = 13
    Caption = 'Content:'
  end
  object edtPattern: TEdit
    Left = 80
    Top = 30
    Width = 289
    Height = 21
    TabOrder = 0
    Text = 'Vcl.*'
  end
  object edtContent: TEdit
    Left = 80
    Top = 62
    Width = 289
    Height = 21
    TabOrder = 1
    Text = 'Vcl.Dialog'
  end
  object btnCheck: TButton
    Left = 80
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Check'
    TabOrder = 2
    OnClick = btnCheckClick
  end
  object chkCase: TCheckBox
    Left = 232
    Top = 102
    Width = 97
    Height = 17
    Caption = 'Case Sensitive'
    TabOrder = 3
  end
  object btnCheckUpperW: TButton
    Left = 80
    Top = 160
    Width = 249
    Height = 25
    Caption = 'Check CharUpperW'
    TabOrder = 4
    OnClick = btnCheckUpperWClick
  end
end
