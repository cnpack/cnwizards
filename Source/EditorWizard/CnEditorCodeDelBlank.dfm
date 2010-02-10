inherited CnDelBlankForm: TCnDelBlankForm
  BorderStyle = bsDialog
  Caption = 'Delete Blank Lines'
  ClientHeight = 170
  ClientWidth = 281
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 34
    Top = 140
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 116
    Top = 140
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 198
    Top = 140
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 265
    Height = 57
    Caption = '&Select Content to Process'
    TabOrder = 0
    object rbSel: TRadioButton
      Left = 8
      Top = 16
      Width = 249
      Height = 17
      Caption = 'Current Selection(&1).'
      TabOrder = 0
    end
    object rbAll: TRadioButton
      Left = 8
      Top = 32
      Width = 249
      Height = 17
      Caption = 'Current Unit(&2).'
      TabOrder = 1
    end
  end
  object grp2: TGroupBox
    Left = 8
    Top = 72
    Width = 265
    Height = 57
    Caption = '&Options'
    TabOrder = 1
    object rbAllLine: TRadioButton
      Left = 8
      Top = 32
      Width = 249
      Height = 17
      Caption = '&Delete All Blank Lines.'
      TabOrder = 1
    end
    object rbMulti: TRadioButton
      Left = 8
      Top = 16
      Width = 249
      Height = 17
      Caption = '&Compact Continuous Blank Lines to One.'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
  end
end
