inherited CnObjInspectorConfigForm: TCnObjInspectorConfigForm
  Left = 451
  Top = 160
  BorderStyle = bsDialog
  Caption = 'Object Inspector Enhancements Wizard Settings'
  ClientHeight = 205
  ClientWidth = 372
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grpSettings: TGroupBox
    Left = 8
    Top = 8
    Width = 354
    Height = 152
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '&Settings'
    TabOrder = 0
    object chkEnhancePaint: TCheckBox
      Left = 16
      Top = 24
      Width = 329
      Height = 17
      Caption = 'Enhance Property Editor Drawing (Delphi 5 Only).'
      TabOrder = 0
    end
    object chkCommentWindow: TCheckBox
      Left = 16
      Top = 96
      Width = 329
      Height = 17
      Caption = 'Add "Comment Window" in Object Inspector'#39's Popupmenu.'
      TabOrder = 3
    end
    object chkShowGridLine: TCheckBox
      Left = 16
      Top = 48
      Width = 329
      Height = 17
      Caption = 'Show Object Inspector Grid Lines (Delphi 6/7 Only).'
      TabOrder = 1
    end
    object chkShowGridLineBDS: TCheckBox
      Left = 16
      Top = 72
      Width = 329
      Height = 17
      Caption = 'Show Object Inspector Grid Lines (BDS 2005 Above Only).'
      TabOrder = 2
    end
    object chkChangeFontSize: TCheckBox
      Left = 16
      Top = 120
      Width = 241
      Height = 17
      Caption = 'Change Object Inspector Font Size to'
      TabOrder = 4
      OnClick = chkChangeFontSizeClick
    end
    object seFontSize: TCnSpinEdit
      Left = 280
      Top = 120
      Width = 65
      Height = 22
      MaxValue = 120
      MinValue = 8
      TabOrder = 5
      Value = 8
    end
  end
  object btnOK: TButton
    Left = 123
    Top = 173
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 205
    Top = 173
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 286
    Top = 173
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
