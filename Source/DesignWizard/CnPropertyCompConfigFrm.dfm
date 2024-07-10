inherited CnPropertyCompConfigForm: TCnPropertyCompConfigForm
  Left = 500
  Top = 205
  BorderStyle = bsDialog
  Caption = 'Property Compare Settings'
  ClientHeight = 337
  ClientWidth = 322
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 79
    Top = 308
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 159
    Top = 308
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 239
    Top = 308
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 306
    Height = 291
    ActivePage = tsProperty
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    object tsProperty: TTabSheet
      Caption = '&Property'
      object lblAll: TLabel
        Left = 8
        Top = 32
        Width = 165
        Height = 13
        Caption = 'Ignore Properties when Assign All:'
      end
      object chkSameType: TCheckBox
        Left = 8
        Top = 8
        Width = 281
        Height = 17
        Caption = 'Only Check Property Names'
        TabOrder = 0
      end
      object mmoIgnoreProperties: TMemo
        Left = 8
        Top = 56
        Width = 281
        Height = 137
        TabOrder = 1
      end
      object chkShowMenu: TCheckBox
        Left = 8
        Top = 208
        Width = 281
        Height = 17
        Caption = 'Show Context Menu in Designer'
        TabOrder = 2
      end
    end
    object tsFont: TTabSheet
      Caption = '&Font'
      ImageIndex = 1
      object pnlFont: TPanel
        Left = 8
        Top = 8
        Width = 281
        Height = 73
        BevelInner = bvLowered
        BevelOuter = bvNone
        Caption = 'Property Font'
        Color = clWhite
        TabOrder = 0
        OnDblClick = btnFontClick
      end
      object btnFont: TButton
        Left = 8
        Top = 96
        Width = 113
        Height = 21
        Caption = '&Change Font'
        TabOrder = 1
        OnClick = btnFontClick
      end
      object btnReset: TButton
        Left = 176
        Top = 96
        Width = 113
        Height = 21
        Caption = '&Reset'
        TabOrder = 2
        OnClick = btnResetClick
      end
    end
  end
  object dlgFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 180
    Top = 144
  end
end
