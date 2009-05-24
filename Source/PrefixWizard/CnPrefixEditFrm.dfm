object CnPrefixEditForm: TCnPrefixEditForm
  Left = 351
  Top = 231
  ActiveControl = edtName
  BorderStyle = bsDialog
  Caption = '修改组件名称'
  ClientHeight = 228
  ClientWidth = 336
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gbEdit: TGroupBox
    Left = 8
    Top = 8
    Width = 321
    Height = 185
    Caption = '修改组件名称(&E)'
    TabOrder = 0
    object lblFormName: TLabel
      Left = 72
      Top = 20
      Width = 61
      Height = 13
      Caption = 'lblFormName'
    end
    object bvl1: TBevel
      Left = 8
      Top = 96
      Width = 305
      Height = 2
      Shape = bsBottomLine
    end
    object lbl1: TLabel
      Left = 8
      Top = 80
      Width = 48
      Height = 13
      Caption = '原组件名'
    end
    object lbl2: TLabel
      Left = 8
      Top = 20
      Width = 40
      Height = 13
      Caption = '窗体名:'
    end
    object lbl3: TLabel
      Left = 176
      Top = 80
      Width = 48
      Height = 13
      Caption = '新组件名'
    end
    object img1: TImage
      Left = 152
      Top = 110
      Width = 16
      Height = 16
      AutoSize = True
      Picture.Data = {
        07544269746D6170F6000000424DF60000000000000076000000280000001000
        000010000000010004000000000080000000C40E0000C40E0000100000000000
        0000000000000000800000800000008080008000000080008000808000007F7F
        7F00BFBFBF000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00333333333333333333333333333333333333333333333333333333333333
        3333333333003333333333333309003333333333330999003333000000099999
        0033099999999999990000000009999900333333330999003333333333090033
        3333333333003333333333333333333333333333333333333333333333333333
        3333}
      Transparent = True
    end
    object lbl4: TLabel
      Left = 8
      Top = 40
      Width = 40
      Height = 13
      Caption = '组件类:'
    end
    object lblClassName: TLabel
      Left = 72
      Top = 40
      Width = 217
      Height = 13
      AutoSize = False
      Caption = 'lblClassName'
    end
    object lbl5: TLabel
      Left = 8
      Top = 59
      Width = 28
      Height = 13
      Caption = '标题:'
    end
    object lblText: TLabel
      Left = 72
      Top = 59
      Width = 241
      Height = 13
      AutoSize = False
      Caption = 'lblText'
    end
    object btnClassName: TSpeedButton
      Left = 293
      Top = 36
      Width = 20
      Height = 20
      Flat = True
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
        333333333337F33333333333333033333333333333373F333333333333090333
        33333333337F7F33333333333309033333333333337373F33333333330999033
        3333333337F337F33333333330999033333333333733373F3333333309999903
        333333337F33337F33333333099999033333333373333373F333333099999990
        33333337FFFF3FF7F33333300009000033333337777F77773333333333090333
        33333333337F7F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333300033333333333337773333333}
      NumGlyphs = 2
      OnClick = btnClassNameClick
    end
    object edtName: TEdit
      Left = 176
      Top = 108
      Width = 137
      Height = 21
      TabOrder = 1
      OnKeyPress = edtNameKeyPress
    end
    object cbNeverDisp: TCheckBox
      Left = 8
      Top = 160
      Width = 217
      Height = 17
      Caption = '对所有组件不再询问。'
      TabOrder = 4
    end
    object cbIgnoreComp: TCheckBox
      Left = 8
      Top = 140
      Width = 217
      Height = 17
      Caption = '忽略该类型的组件。'
      TabOrder = 3
    end
    object btnPrefix: TButton
      Left = 224
      Top = 137
      Width = 89
      Height = 21
      Caption = '修改前缀(&P)'
      TabOrder = 2
      OnClick = btnPrefixClick
    end
    object edtOldName: TEdit
      Left = 8
      Top = 108
      Width = 137
      Height = 21
      ParentColor = True
      ReadOnly = True
      TabOrder = 0
      OnKeyPress = edtNameKeyPress
    end
  end
  object btnOK: TButton
    Left = 94
    Top = 200
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 174
    Top = 200
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 254
    Top = 200
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
