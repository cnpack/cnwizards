inherited CnObjInspectorConfigForm: TCnObjInspectorConfigForm
  Left = 451
  Top = 160
  BorderStyle = bsDialog
  Caption = 'Object Inspector Enhancements Wizard Settings'
  ClientHeight = 157
  ClientWidth = 356
  PixelsPerInch = 96
  TextHeight = 13
  object grpSettings: TGroupBox
    Left = 8
    Top = 8
    Width = 337
    Height = 104
    Caption = '&Settings'
    TabOrder = 0
    object chkEnhancePaint: TCheckBox
      Left = 16
      Top = 24
      Width = 305
      Height = 17
      Caption = 'Enhance Property Editor Drawing (Delphi 5 Only)'
      TabOrder = 0
    end
    object chkCommentWindow: TCheckBox
      Left = 16
      Top = 72
      Width = 305
      Height = 17
      Caption = 'Add "Comment Window" in Object Inspector'#39's Popupmenu'
      TabOrder = 2
    end
    object chkHideGridLine: TCheckBox
      Left = 16
      Top = 48
      Width = 305
      Height = 17
      Caption = 'Hide Object Inspector Grid Lines'
      TabOrder = 1
    end
  end
  object btnOK: TButton
    Left = 107
    Top = 125
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 189
    Top = 125
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 270
    Top = 125
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
