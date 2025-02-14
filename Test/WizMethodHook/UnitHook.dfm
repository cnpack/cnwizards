object FormHook: TFormHook
  Left = 0
  Top = 0
  Caption = 'Test Method Hook for Win32/Win64'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Button1: TButton
    Left = 72
    Top = 64
    Width = 185
    Height = 25
    Caption = 'Test ImageList.Change Hook'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 360
    Top = 64
    Width = 185
    Height = 25
    Caption = 'Test Method Call for ASM 64'
    TabOrder = 1
    OnClick = Button2Click
  end
  object ImageList1: TImageList
    Left = 384
    Top = 208
  end
  object VirtualImageList1: TVirtualImageList
    Images = <>
    Left = 208
    Top = 288
  end
end
