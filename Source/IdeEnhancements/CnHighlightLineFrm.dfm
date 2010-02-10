inherited CnHighlightLineForm: TCnHighlightLineForm
  Left = 289
  Top = 249
  BorderStyle = bsDialog
  Caption = 'Line Settings'
  ClientHeight = 200
  ClientWidth = 363
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 345
    Height = 152
    Caption = 'Highlight &Line Settings'
    TabOrder = 0
    object lblLineWidth: TLabel
      Left = 240
      Top = 28
      Width = 32
      Height = 13
      Caption = 'Width:'
    end
    object lblLineType: TLabel
      Left = 16
      Top = 28
      Width = 50
      Height = 13
      Caption = 'Line Type:'
    end
    object seLineWidth: TCnSpinEdit
      Left = 288
      Top = 24
      Width = 41
      Height = 22
      MaxValue = 5
      MinValue = 1
      TabOrder = 1
      Value = 1
    end
    object cbbLineType: TComboBox
      Left = 80
      Top = 24
      Width = 129
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 0
      OnDrawItem = cbbLineTypeDrawItem
      Items.Strings = (
        '0'
        '1'
        '2'
        '3')
    end
    object chkLineEnd: TCheckBox
      Left = 16
      Top = 56
      Width = 313
      Height = 17
      Caption = 'Draw "[" at Line Ends'
      TabOrder = 2
    end
    object chkLineClass: TCheckBox
      Left = 16
      Top = 116
      Width = 321
      Height = 17
      Caption = 'Ignore class/interface/record Declaration in Lines'
      TabOrder = 5
    end
    object chkLineHori: TCheckBox
      Left = 16
      Top = 76
      Width = 313
      Height = 17
      Caption = 'Draw Horizontal Line when in Different Columns'
      TabOrder = 3
      OnClick = chkLineHoriClick
    end
    object chkLineHoriDot: TCheckBox
      Left = 32
      Top = 96
      Width = 305
      Height = 17
      Caption = 'Use Tiny Dot to Draw the Horizontal Lines'
      TabOrder = 4
    end
  end
  object btnOK: TButton
    Left = 118
    Top = 168
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 198
    Top = 168
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 278
    Top = 168
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
