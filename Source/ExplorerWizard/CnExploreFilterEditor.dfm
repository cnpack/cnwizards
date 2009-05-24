object CnExploreFilterEditorForm: TCnExploreFilterEditorForm
  Left = 307
  Top = 279
  BorderStyle = bsDialog
  Caption = '添加过滤类型'
  ClientHeight = 96
  ClientWidth = 299
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 12
    Top = 12
    Width = 36
    Height = 13
    Caption = '类型：'
  end
  object lbl2: TLabel
    Left = 12
    Top = 36
    Width = 48
    Height = 13
    Caption = '扩展名：'
  end
  object OKBtn: TButton
    Left = 135
    Top = 66
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object CancelBtn: TButton
    Left = 215
    Top = 66
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object edtType: TEdit
    Left = 64
    Top = 10
    Width = 225
    Height = 21
    TabOrder = 0
    Text = '全部类型'
  end
  object edtExtName: TEdit
    Left = 64
    Top = 34
    Width = 225
    Height = 21
    TabOrder = 1
    Text = '*.*'
  end
end
