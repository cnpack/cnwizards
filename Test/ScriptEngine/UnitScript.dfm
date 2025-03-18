object FormScriptEngine: TFormScriptEngine
  Left = 192
  Top = 107
  Width = 976
  Height = 563
  Caption = 'Test Script Engine'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblScript: TLabel
    Left = 16
    Top = 16
    Width = 30
    Height = 13
    Caption = 'Script:'
  end
  object mmoScript: TMemo
    Left = 16
    Top = 40
    Width = 409
    Height = 473
    Anchors = [akLeft, akTop, akBottom]
    Lines.Strings = (
      'program ScriptTest;'
      ''
      'var'
      '  Obj: TObject;'
      'begin'
      '  Writeln('#39'Test OK'#39');'
      '  Obj := TObject.Create;'
      '  Obj.Free;'
      'end.')
    TabOrder = 0
  end
  object btnExec: TButton
    Left = 400
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Execute'
    TabOrder = 1
    OnClick = btnExecClick
  end
  object mmoResult: TMemo
    Left = 448
    Top = 40
    Width = 502
    Height = 473
    Anchors = [akTop, akRight, akBottom]
    TabOrder = 2
  end
end
