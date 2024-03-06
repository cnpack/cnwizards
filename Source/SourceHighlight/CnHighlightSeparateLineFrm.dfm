inherited CnHighlightSeparateLineForm: TCnHighlightSeparateLineForm
  Left = 532
  Top = 314
  BorderStyle = bsDialog
  Caption = 'Separate Line Settings'
  ClientHeight = 151
  ClientWidth = 362
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 345
    Height = 97
    Caption = 'Highlight &Separate Line Settings'
    TabOrder = 0
    object lblLineColor: TLabel
      Left = 16
      Top = 60
      Width = 29
      Height = 13
      Caption = 'Color:'
    end
    object lblLineType: TLabel
      Left = 16
      Top = 28
      Width = 50
      Height = 13
      Caption = 'Line Type:'
    end
    object shpSeparateLine: TShape
      Left = 81
      Top = 58
      Width = 20
      Height = 20
      OnMouseDown = shpSeparateLineMouseDown
    end
    object lblLineWidth: TLabel
      Left = 240
      Top = 28
      Width = 32
      Height = 13
      Caption = 'Width:'
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
  end
  object btnOK: TButton
    Left = 118
    Top = 120
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 198
    Top = 120
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 278
    Top = 120
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object dlgColor: TColorDialog
    Ctl3D = True
    Left = 152
    Top = 64
  end
end
