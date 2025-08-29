object TestResizeForm: TTestResizeForm
  Left = 192
  Top = 107
  Width = 696
  Height = 480
  Caption = 'Test ComboBox Resizing using Splitter in  Toolbar'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 136
    Top = 144
    Width = 423
    Height = 13
    Caption = 
      'ComboBox can Resize using Splitter under Delphi 5 ~ XE3, but NOT' +
      ' under XE4 or above.'
  end
  object btnCreate: TButton
    Left = 192
    Top = 232
    Width = 297
    Height = 25
    Caption = 'Create ToolBar and its Controls'
    TabOrder = 0
    OnClick = btnCreateClick
  end
end
