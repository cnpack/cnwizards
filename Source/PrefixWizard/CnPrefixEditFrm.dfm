inherited CnPrefixEditForm: TCnPrefixEditForm
  Left = 351
  Top = 231
  Width = 344
  Height = 255
  ActiveControl = edtName
  BorderIcons = [biSystemMenu]
  Caption = 'Edit Component'#39's Name'
  Constraints.MinHeight = 255
  Constraints.MinWidth = 344
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gbEdit: TGroupBox
    Left = 8
    Top = 8
    Width = 318
    Height = 182
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '&Edit Component Name'
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
      Width = 302
      Height = 2
      Anchors = [akLeft, akTop, akRight]
      Shape = bsBottomLine
    end
    object lbl1: TLabel
      Left = 8
      Top = 80
      Width = 66
      Height = 13
      Caption = 'Original Name'
    end
    object lbl2: TLabel
      Left = 8
      Top = 20
      Width = 58
      Height = 13
      Caption = 'Form Name:'
    end
    object lbl3: TLabel
      Left = 176
      Top = 80
      Width = 51
      Height = 13
      Caption = 'New Name'
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
      Width = 59
      Height = 13
      Caption = 'Class Name:'
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
      Width = 41
      Height = 13
      Caption = 'Caption:'
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
      Left = 290
      Top = 36
      Width = 20
      Height = 20
      Anchors = [akTop, akRight]
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
      Width = 134
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      OnKeyPress = edtNameKeyPress
    end
    object cbNeverDisp: TCheckBox
      Left = 8
      Top = 157
      Width = 217
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Never Ask Again.'
      TabOrder = 4
    end
    object cbIgnoreComp: TCheckBox
      Left = 8
      Top = 137
      Width = 217
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Ignore This Type of Component.'
      TabOrder = 3
    end
    object btnPrefix: TButton
      Left = 221
      Top = 134
      Width = 89
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = 'Modify &Prefix'
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
    Left = 90
    Top = 198
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 170
    Top = 198
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 250
    Top = 198
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
