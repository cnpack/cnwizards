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
  object Bevel1: TBevel
    Left = 72
    Top = 192
    Width = 473
    Height = 25
    Shape = bsBottomLine
  end
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
  object btnTestBplFunc: TButton
    Left = 72
    Top = 144
    Width = 185
    Height = 25
    Caption = 'Test Load Bpl call Func'
    TabOrder = 2
    OnClick = btnTestBplFuncClick
  end
  object Button3: TButton
    Left = 360
    Top = 144
    Width = 185
    Height = 25
    Caption = 'Test Bpl call Method'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 72
    Top = 248
    Width = 201
    Height = 25
    Caption = 'Direct Call an Object Method'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 328
    Top = 248
    Width = 217
    Height = 25
    Caption = 'Call an Object Method using Event'
    TabOrder = 5
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 72
    Top = 304
    Width = 201
    Height = 25
    Caption = 'Call an Object Method using Pointer'
    TabOrder = 6
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 328
    Top = 304
    Width = 217
    Height = 25
    Caption = 'Call an Object Method using Single Func'
    TabOrder = 7
    OnClick = Button7Click
  end
  object ImageList1: TImageList
    Left = 544
    Top = 376
  end
  object VirtualImageList1: TVirtualImageList
    Images = <>
    Left = 456
    Top = 376
  end
end
