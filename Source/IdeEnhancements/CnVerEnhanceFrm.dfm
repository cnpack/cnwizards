inherited CnVerEnhanceForm: TCnVerEnhanceForm
  Left = 427
  Top = 392
  BorderStyle = bsDialog
  Caption = '版本信息扩展专家设置'
  ClientHeight = 125
  ClientWidth = 403
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpVerEnh: TGroupBox
    Left = 8
    Top = 8
    Width = 387
    Height = 81
    Caption = '版本信息扩展专家设置(&V)'
    TabOrder = 0
    object lblNote: TLabel
      Left = 24
      Top = 56
      Width = 312
      Height = 13
      Caption = '（注：以上两选项只在工程选项中包含版本信息时有效。）'
    end
    object chkLastCompiled: TCheckBox
      Left = 8
      Top = 16
      Width = 377
      Height = 17
      Caption = '版本信息中插入编译时刻 （仅适用于 Delphi 6 及以上版本）。'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkIncBuild: TCheckBox
      Left = 8
      Top = 36
      Width = 377
      Height = 17
      Caption = '编译时自动增加 Build 号 （仅适用于 Delphi 6 及以上版本）。'
      TabOrder = 1
    end
  end
  object btnOK: TButton
    Left = 157
    Top = 96
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 239
    Top = 96
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 320
    Top = 96
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '帮助(&H)'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
