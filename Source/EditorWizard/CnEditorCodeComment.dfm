object CnEditorCodeCommentForm: TCnEditorCodeCommentForm
  Left = 412
  Top = 266
  BorderStyle = bsDialog
  Caption = '切换注释工具设置'
  ClientHeight = 93
  ClientWidth = 250
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '宋体'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 49
    Caption = '设置(&S)'
    TabOrder = 0
    object chkMoveToNextLine: TCheckBox
      Left = 8
      Top = 18
      Width = 217
      Height = 17
      Caption = '切换注释后光标自动移至下一行'
      TabOrder = 0
    end
  end
  object btnOK: TButton
    Left = 86
    Top = 64
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 166
    Top = 64
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
end
