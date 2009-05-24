object CorPropRuleForm: TCorPropRuleForm
  Left = 203
  Top = 252
  BorderStyle = bsDialog
  Caption = '属性修改规则'
  ClientHeight = 85
  ClientWidth = 658
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 48
    Height = 13
    Caption = '组件类：'
  end
  object Label2: TLabel
    Left = 144
    Top = 8
    Width = 36
    Height = 13
    Caption = '属性：'
  end
  object Label3: TLabel
    Left = 328
    Top = 8
    Width = 48
    Height = 13
    Caption = '属性值：'
  end
  object Label4: TLabel
    Left = 256
    Top = 8
    Width = 36
    Height = 13
    Caption = '条件：'
  end
  object Label5: TLabel
    Left = 448
    Top = 8
    Width = 36
    Height = 13
    Caption = '动作：'
  end
  object Label6: TLabel
    Left = 528
    Top = 8
    Width = 48
    Height = 13
    Caption = '修改为：'
  end
  object btnOK: TButton
    Left = 416
    Top = 56
    Width = 75
    Height = 21
    Anchors = [akTop, akRight]
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 7
  end
  object btnCancel: TButton
    Left = 496
    Top = 56
    Width = 75
    Height = 21
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 8
  end
  object btnHelp: TButton
    Left = 576
    Top = 56
    Width = 75
    Height = 21
    Anchors = [akTop, akRight]
    Caption = '帮助(&H)'
    TabOrder = 9
    OnClick = btnHelpClick
  end
  object cbbComponent: TComboBox
    Left = 8
    Top = 24
    Width = 129
    Height = 21
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
  end
  object cbbProperty: TComboBox
    Left = 144
    Top = 24
    Width = 105
    Height = 21
    ItemHeight = 13
    Sorted = True
    TabOrder = 1
  end
  object cbbCondition: TComboBox
    Left = 256
    Top = 24
    Width = 65
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
  end
  object cbbValue: TComboBox
    Left = 328
    Top = 24
    Width = 113
    Height = 21
    ItemHeight = 13
    TabOrder = 3
  end
  object cbbAction: TComboBox
    Left = 448
    Top = 24
    Width = 73
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 4
  end
  object cbbDestValue: TComboBox
    Left = 528
    Top = 24
    Width = 124
    Height = 21
    ItemHeight = 13
    TabOrder = 5
  end
  object chkActive: TCheckBox
    Left = 8
    Top = 56
    Width = 169
    Height = 17
    Caption = '规则有效'
    Checked = True
    State = cbChecked
    TabOrder = 6
  end
end
