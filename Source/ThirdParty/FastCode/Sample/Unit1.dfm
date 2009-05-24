object Form1: TForm1
  Left = 192
  Top = 58
  BorderStyle = bsDialog
  Caption = 'FastCode RTL Replacement Test - '
  ClientHeight = 324
  ClientWidth = 438
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid: TStringGrid
    Left = 0
    Top = 0
    Width = 438
    Height = 303
    TabStop = False
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    ColCount = 3
    DefaultColWidth = 144
    FixedColor = 15921130
    FixedCols = 0
    RowCount = 12
    FixedRows = 0
    Font.Charset = GREEK_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    ParentFont = False
    TabOrder = 0
    OnDrawCell = StringGridDrawCell
  end
  object Panel1: TPanel
    Left = 0
    Top = 303
    Width = 438
    Height = 21
    Align = alBottom
    BevelOuter = bvLowered
    Caption = 
      'If you see red then the routine failed to give the correct resul' +
      't!'
    TabOrder = 1
  end
end
