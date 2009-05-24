object CnHighlightLineForm: TCnHighlightLineForm
  Left = 289
  Top = 249
  BorderStyle = bsDialog
  Caption = '高亮画线设置'
  ClientHeight = 200
  ClientWidth = 363
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '宋体'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 345
    Height = 152
    Caption = '高亮画线设置(&L)'
    TabOrder = 0
    object lblLineWidth: TLabel
      Left = 240
      Top = 28
      Width = 36
      Height = 12
      Caption = '线宽：'
    end
    object lblLineType: TLabel
      Left = 16
      Top = 28
      Width = 36
      Height = 12
      Caption = '线型：'
    end
    object seLineWidth: TCnSpinEdit
      Left = 288
      Top = 24
      Width = 41
      Height = 21
      MaxValue = 5
      MinValue = 1
      TabOrder = 1
      Value = 1
    end
    object cbbLineType: TComboBox
      Left = 80
      Top = 24
      Width = 129
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 0
      OnDrawItem = cbbLineTypeDrawItem
      Items.Strings = (
        '0'
        '1'
        '2'
        '3')
    end
    object chkLineEnd: TCheckBox
      Left = 16
      Top = 56
      Width = 313
      Height = 17
      Caption = '在关键字配对端绘制“[”型端点'
      TabOrder = 2
    end
    object chkLineClass: TCheckBox
      Left = 16
      Top = 116
      Width = 321
      Height = 17
      Caption = '高亮连线时忽略 class/interface/record 等声明结构'
      TabOrder = 5
    end
    object chkLineHori: TCheckBox
      Left = 16
      Top = 76
      Width = 313
      Height = 17
      Caption = '关键字列未对齐时绘制横线'
      TabOrder = 3
      OnClick = chkLineHoriClick
    end
    object chkLineHoriDot: TCheckBox
      Left = 32
      Top = 96
      Width = 305
      Height = 17
      Caption = '横线使用细虚线绘制'
      TabOrder = 4
    end
  end
  object btnOK: TButton
    Left = 118
    Top = 168
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 198
    Top = 168
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 278
    Top = 168
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
