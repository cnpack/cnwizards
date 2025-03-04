inherited CnAICoderOptionFrame: TCnAICoderOptionFrame
  Width = 619
  Height = 268
  object lblURL: TLabel
    Left = 16
    Top = 24
    Width = 68
    Height = 13
    Caption = 'Request URL:'
  end
  object lblAPIKey: TLabel
    Left = 16
    Top = 120
    Width = 41
    Height = 13
    Caption = 'API Key:'
  end
  object lblModel: TLabel
    Left = 16
    Top = 56
    Width = 63
    Height = 13
    Caption = 'Model Name:'
  end
  object lblApply: TLabel
    Left = 518
    Top = 144
    Width = 82
    Height = 33
    Cursor = crHandPoint
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    AutoSize = False
    BiDiMode = bdLeftToRight
    Caption = 'Apply'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentBiDiMode = False
    ParentFont = False
    OnClick = lblApplyClick
  end
  object lblTemperature: TLabel
    Left = 16
    Top = 88
    Width = 63
    Height = 13
    Caption = 'Temperature:'
  end
  object btnReset: TSpeedButton
    Left = 8
    Top = 240
    Width = 23
    Height = 22
    Hint = 'Reset'
    Anchors = [akLeft, akBottom]
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000000000000000000000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF5A6BEF
      1029A500109C00109C00109C00109C00109C00109C00109C00109C08219C5A6B
      EFFF00FFFF00FFFF00FFFF00FF1029C60018C60821C61029C61029C60829CE10
      29CE1029CE0021CE0018CE0010AD10219CFF00FFFF00FFFF00FFFF00FF0018CE
      1031D61831D62139E72942E72142E71842E71039E70831E70029E70018CE0010
      9CFF00FFFF00FFFF00FFFF00FF0021D61831D62942E7314AE7294AE7294AE718
      42E71042E71039E70831E70021CE00109CFF00FFFF00FFFF00FFFF00FF1031D6
      2142E73952E73152E7314AE7294AE71842E71839E71039E70831E71031CE0010
      9CFF00FFFF00FFFF00FFFF00FF2139E7314AE73952E73152E7314AE7294AE718
      42E71039E71031E70831E71031CE00109CFF00FFFF00FFFF00FFFF00FF314AE7
      425AE74252E73152E7314AE72942E71839DE1031DE1031DE1031DE1031CE0010
      9CFF00FFFF00FFFF00FFFF00FF3952E74A63E7425AE73952E73142E72942DE18
      39DE1031D61031DE1031DE1031CE00109CFF00FFFF00FFFF00FFFF00FF4252E7
      526BEF4A63E74252DE314AE72942DE2139DE1839D61831DE1031DE1031CE0010
      9CFF00FFFF00FFFF00FFFF00FF4A63E76B84EF5A73EF4A63E74252E73152E731
      4ADE2942DE2142DE2139D61031CE08189CFF00FFFF00FFFF00FFFF00FF5A73EF
      8C94EF6B7BEF5273EF5263E74A63E74A5AE7425AE73952E7294AE71031CE1831
      A5FF00FFFF00FFFF00FFFF00FF5A73EF5A73EF4A5AE73952E7314AE7314AE729
      42E72939E72139D61839D61831C65A6BEFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
    ParentShowHint = False
    ShowHint = True
    OnClick = btnResetClick
  end
  object edtURL: TEdit
    Left = 120
    Top = 20
    Width = 480
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object edtAPIKey: TEdit
    Left = 120
    Top = 116
    Width = 480
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
  end
  object cbbModel: TComboBox
    Left = 120
    Top = 52
    Width = 480
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
  end
  object edtTemperature: TEdit
    Left = 120
    Top = 84
    Width = 480
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object chkStreamMode: TCheckBox
    Left = 120
    Top = 148
    Width = 97
    Height = 17
    Caption = 'Stream Mode'
    TabOrder = 4
  end
end
