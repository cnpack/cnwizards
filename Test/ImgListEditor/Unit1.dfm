object ImgListEdtTestForm: TImgListEdtTestForm
  Left = 576
  Top = 270
  Width = 423
  Height = 223
  Caption = 'ImageList Editor Test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 8
    Top = 48
    Width = 16
    Height = 13
    Caption = 'lbl1'
  end
  object btnTest: TButton
    Left = 160
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Test'
    TabOrder = 0
    OnClick = btnTestClick
  end
  object il1: TImageList
    Height = 32
    Width = 32
    Left = 16
    Top = 16
  end
end
