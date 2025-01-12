object CnObjInspectorCommentForm: TCnObjInspectorCommentForm
  Left = 427
  Top = 226
  Width = 347
  Height = 498
  Caption = 'Object Inspector Comment'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Visible = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlComment: TPanel
    Left = 0
    Top = 30
    Width = 339
    Height = 441
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 0
    object mmoComment: TMemo
      Left = 1
      Top = 51
      Width = 337
      Height = 370
      Align = alClient
      TabOrder = 0
    end
    object pnlType: TPanel
      Left = 1
      Top = 1
      Width = 337
      Height = 25
      Align = alTop
      AutoSize = True
      BevelOuter = bvNone
      BorderWidth = 1
      Color = clInfoBk
      TabOrder = 1
      object edtType: TEdit
        Left = 4
        Top = 3
        Width = 120
        Height = 21
        BorderStyle = bsNone
        ParentColor = True
        ReadOnly = True
        TabOrder = 0
      end
      object edtTypeComment: TEdit
        Left = 124
        Top = 1
        Width = 210
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
    end
    object pnlProp: TPanel
      Left = 1
      Top = 26
      Width = 337
      Height = 25
      Align = alTop
      AutoSize = True
      BevelOuter = bvNone
      BorderWidth = 1
      Color = clInfoBk
      TabOrder = 2
      object edtProp: TEdit
        Left = 4
        Top = 3
        Width = 120
        Height = 21
        BorderStyle = bsNone
        ParentColor = True
        ReadOnly = True
        TabOrder = 0
      end
      object edtPropComment: TEdit
        Left = 124
        Top = 1
        Width = 210
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
    end
    object statHie: TStatusBar
      Left = 1
      Top = 421
      Width = 337
      Height = 19
      Panels = <>
      SimplePanel = True
    end
  end
  object tlbObjComment: TToolBar
    Left = 0
    Top = 0
    Width = 339
    Height = 30
    BorderWidth = 1
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    Flat = True
    Images = dmCnSharedImages.Images
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object btnClear: TToolButton
      Left = 0
      Top = 0
      Action = actClear
    end
    object btn1: TToolButton
      Left = 23
      Top = 0
      Width = 8
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnFont: TToolButton
      Left = 31
      Top = 0
      Action = actFont
    end
    object btnHelp: TToolButton
      Left = 54
      Top = 0
      Action = actHelp
    end
    object btn2: TToolButton
      Left = 77
      Top = 0
      Width = 8
      Caption = 'btn2'
      ImageIndex = 2
      Style = tbsSeparator
    end
  end
  object dlgFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 40
    Top = 586
  end
  object actlstComment: TActionList
    Images = dmCnSharedImages.Images
    Left = 24
    Top = 414
    object actClear: TAction
      Caption = 'C&lear'
      Hint = 'Clear Comment'
      ImageIndex = 13
      OnExecute = actClearExecute
    end
    object actFont: TAction
      Caption = '&Font'
      Hint = 'Change Font'
      ImageIndex = 29
      OnExecute = actFontExecute
    end
    object actHelp: TAction
      Caption = '&Help'
      Hint = 'Display Help'
      ImageIndex = 1
      OnExecute = actHelpExecute
    end
  end
end
