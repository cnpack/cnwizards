inherited CnSizeConstraintsEditorForm: TCnSizeConstraintsEditorForm
  Left = 362
  Top = 257
  BorderStyle = bsDialog
  Caption = 'SizeConstraints Editor'
  ClientHeight = 195
  ClientWidth = 336
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object lblMXH: TLabel
    Left = 7
    Top = 31
    Width = 79
    Height = 13
    Alignment = taRightJustify
    Caption = 'MaxHeight:%4D'
  end
  object lblMXW: TLabel
    Left = 10
    Top = 65
    Width = 76
    Height = 13
    Alignment = taRightJustify
    Caption = 'MaxWidth:%4D'
  end
  object lblMNH: TLabel
    Left = 11
    Top = 100
    Width = 75
    Height = 13
    Alignment = taRightJustify
    Caption = 'MinHeight:%4D'
  end
  object lblMNW: TLabel
    Left = 14
    Top = 134
    Width = 72
    Height = 13
    Alignment = taRightJustify
    Caption = 'MinWidth:%4D'
  end
  object lblNowHeight: TLabel
    Left = 217
    Top = 23
    Width = 59
    Height = 13
    Alignment = taRightJustify
    Caption = 'Height:%4D'
  end
  object lblNowWidth: TLabel
    Left = 220
    Top = 38
    Width = 56
    Height = 13
    Alignment = taRightJustify
    Caption = 'Width:%4D'
  end
  object lblOld: TLabel
    Left = 23
    Top = 8
    Width = 65
    Height = 13
    Alignment = taRightJustify
    Caption = 'Original Value'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblNew: TLabel
    Left = 128
    Top = 8
    Width = 50
    Height = 13
    Caption = 'New Value'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblNow: TLabel
    Left = 212
    Top = 8
    Width = 66
    Height = 13
    Alignment = taCenter
    Caption = 'Current Value'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object btnMXH: TSpeedButton
    Left = 99
    Top = 27
    Width = 21
    Height = 21
    Caption = '->'
    OnClick = CopyValue
  end
  object btnMXW: TSpeedButton
    Tag = 1
    Left = 99
    Top = 61
    Width = 21
    Height = 21
    Caption = '->'
    OnClick = CopyValue
  end
  object btnMNH: TSpeedButton
    Tag = 2
    Left = 99
    Top = 96
    Width = 21
    Height = 21
    Caption = '->'
    OnClick = CopyValue
  end
  object btnMNW: TSpeedButton
    Tag = 3
    Left = 99
    Top = 130
    Width = 21
    Height = 21
    Caption = '->'
    OnClick = CopyValue
  end
  object btnasMax: TSpeedButton
    Tag = 4
    Left = 168
    Top = 106
    Width = 160
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Current Value as Max Value'
    OnClick = CopyValue
  end
  object btnasMin: TSpeedButton
    Tag = 5
    Left = 168
    Top = 130
    Width = 160
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Current Value as Min Value'
    OnClick = CopyValue
  end
  object btnClear: TSpeedButton
    Tag = 6
    Left = 168
    Top = 58
    Width = 76
    Height = 21
    Caption = 'Reset'
    OnClick = CopyValue
  end
  object btnFixed: TSpeedButton
    Tag = 7
    Left = 252
    Top = 58
    Width = 76
    Height = 21
    Caption = 'Fixed Size'
    OnClick = CopyValue
  end
  object SpeedButton1: TSpeedButton
    Tag = 8
    Left = 168
    Top = 82
    Width = 76
    Height = 21
    Caption = 'Fixed Width'
    OnClick = CopyValue
  end
  object SpeedButton2: TSpeedButton
    Tag = 9
    Left = 252
    Top = 82
    Width = 76
    Height = 21
    Caption = 'Fixed Height'
    OnClick = CopyValue
  end
  object lbl1: TLabel
    Left = 11
    Top = 31
    Width = 51
    Height = 13
    Alignment = taRightJustify
    Caption = 'MaxHeight'
  end
  object lbl2: TLabel
    Left = 14
    Top = 65
    Width = 48
    Height = 13
    Alignment = taRightJustify
    Caption = 'MaxWidth'
  end
  object lbl3: TLabel
    Left = 15
    Top = 100
    Width = 47
    Height = 13
    Alignment = taRightJustify
    Caption = 'MinHeight'
  end
  object lbl4: TLabel
    Left = 18
    Top = 134
    Width = 44
    Height = 13
    Alignment = taRightJustify
    Caption = 'MinWidth'
  end
  object lbl5: TLabel
    Left = 221
    Top = 23
    Width = 31
    Height = 13
    Alignment = taRightJustify
    Caption = 'Height'
  end
  object lbl6: TLabel
    Left = 224
    Top = 38
    Width = 28
    Height = 13
    Alignment = taRightJustify
    Caption = 'Width'
  end
  object btnOK: TButton
    Left = 172
    Top = 168
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&OK'
    TabOrder = 6
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 253
    Top = 168
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    TabOrder = 7
    OnClick = btnCancelClick
  end
  object edtMXH: TEdit
    Left = 128
    Top = 28
    Width = 33
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    Text = '0'
    OnExit = editExit
  end
  object edtMXW: TEdit
    Tag = 1
    Left = 128
    Top = 62
    Width = 33
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
    Text = '0'
    OnExit = editExit
  end
  object edtMNH: TEdit
    Tag = 2
    Left = 128
    Top = 97
    Width = 33
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    Text = '0'
    OnExit = editExit
  end
  object edtMNW: TEdit
    Tag = 3
    Left = 128
    Top = 131
    Width = 33
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 3
    Text = '0'
    OnExit = editExit
  end
  object Panel1: TPanel
    Left = 8
    Top = 160
    Width = 320
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 4
  end
  object btnAbout: TButton
    Left = 8
    Top = 168
    Width = 21
    Height = 21
    Caption = '?'
    TabOrder = 5
    TabStop = False
    OnClick = btnAboutClick
  end
end
