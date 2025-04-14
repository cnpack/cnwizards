object InsertItemsForm: TInsertItemsForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Insert Items to Language Files'
  ClientHeight = 609
  ClientWidth = 773
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 8
    Top = 56
    Width = 753
    Height = 537
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      753
      537)
    object lbl2052: TLabel
      Left = 16
      Top = 12
      Width = 60
      Height = 13
      Caption = #31616#20307#20013#25991#65306
    end
    object lbl1028: TLabel
      Left = 16
      Top = 86
      Width = 60
      Height = 13
      Caption = #32321#20307#20013#25991#65306
    end
    object lbl1033: TLabel
      Left = 16
      Top = 160
      Width = 36
      Height = 13
      Caption = #33521#35821#65306
    end
    object lbl1031: TLabel
      Left = 16
      Top = 234
      Width = 36
      Height = 13
      Caption = #24503#35821#65306
    end
    object lbl1036: TLabel
      Left = 16
      Top = 308
      Width = 36
      Height = 13
      Caption = #27861#35821#65306
    end
    object lbl1046: TLabel
      Left = 16
      Top = 382
      Width = 72
      Height = 13
      Caption = #24052#35199#33889#33796#29273#65306
    end
    object lbl1049: TLabel
      Left = 16
      Top = 456
      Width = 36
      Height = 13
      Caption = #20420#35821#65306
    end
    object mmo2052: TMemo
      Tag = 2052
      Left = 82
      Top = 12
      Width = 655
      Height = 68
      Anchors = [akLeft, akTop, akRight]
      Lines.Strings = (
        'TCnListCompForm.btnAttribute.Hint='#26174#31034#21517#31216#20026#31354#30340#32452#20214)
      ScrollBars = ssVertical
      TabOrder = 0
      WordWrap = False
    end
    object mmo1028: TMemo
      Tag = 1028
      Left = 82
      Top = 86
      Width = 655
      Height = 68
      Anchors = [akLeft, akTop, akRight]
      Lines.Strings = (
        'TCnListCompForm.btnAttribute.Hint='#39023#31034#21517#31281#28858#31354#30340#32068#20214)
      ScrollBars = ssVertical
      TabOrder = 1
      WordWrap = False
    end
    object mmo1033: TMemo
      Tag = 1033
      Left = 82
      Top = 160
      Width = 655
      Height = 68
      Anchors = [akLeft, akTop, akRight]
      Lines.Strings = (
        'TCnListCompForm.btnAttribute.Hint=Show Empty Names')
      ScrollBars = ssVertical
      TabOrder = 2
      WordWrap = False
    end
    object mmo1031: TMemo
      Tag = 1031
      Left = 82
      Top = 234
      Width = 655
      Height = 68
      Anchors = [akLeft, akTop, akRight]
      Lines.Strings = (
        'TCnListCompForm.btnAttribute.Hint=Leere Namen anzeigen')
      ScrollBars = ssVertical
      TabOrder = 3
      WordWrap = False
    end
    object mmo10281: TMemo
      Tag = 1036
      Left = 82
      Top = 308
      Width = 655
      Height = 68
      Anchors = [akLeft, akTop, akRight]
      Lines.Strings = (
        'TCnListCompForm.btnAttribute.Hint=Afficher les noms vides')
      ScrollBars = ssVertical
      TabOrder = 4
      WordWrap = False
    end
    object mmo1046: TMemo
      Tag = 1046
      Left = 82
      Top = 382
      Width = 655
      Height = 68
      Anchors = [akLeft, akTop, akRight]
      Lines.Strings = (
        'TCnListCompForm.btnAttribute.Hint=Mostrar nomes vazios')
      ScrollBars = ssVertical
      TabOrder = 5
      WordWrap = False
    end
    object mmo1049: TMemo
      Tag = 1049
      Left = 82
      Top = 456
      Width = 655
      Height = 68
      Anchors = [akLeft, akTop, akRight]
      Lines.Strings = (
        'TCnListCompForm.btnAttribute.Hint='#1055#1086#1082#1072#1079#1072#1090#1100' '#1087#1091#1089#1090#1099#1077' '#1080#1084#1077#1085#1072)
      ScrollBars = ssVertical
      TabOrder = 6
      WordWrap = False
    end
  end
  object cbbFiles: TComboBox
    Left = 8
    Top = 16
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 1
  end
  object btnInsert: TButton
    Left = 159
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Insert && Save'
    TabOrder = 2
    OnClick = btnInsertClick
  end
end
