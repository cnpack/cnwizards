object FormAITest: TFormAITest
  Left = 128
  Top = 84
  Width = 1064
  Height = 680
  Caption = 'AI Coder Test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pgcAICoder: TPageControl
    Left = 8
    Top = 8
    Width = 1034
    Height = 620
    ActivePage = tsHTTP
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsHTTP: TTabSheet
      Caption = 'HTTP Pool Test'
      object lblTestProxy: TLabel
        Left = 128
        Top = 20
        Width = 29
        Height = 13
        Caption = 'Proxy:'
      end
      object mmoHTTP: TMemo
        Left = 16
        Top = 56
        Width = 982
        Height = 503
        Anchors = [akLeft, akTop, akRight, akBottom]
        ReadOnly = True
        TabOrder = 0
      end
      object btnAddHttps: TButton
        Left = 16
        Top = 16
        Width = 97
        Height = 25
        Caption = 'Add Many HTTPS'
        TabOrder = 1
        OnClick = btnAddHttpsClick
      end
      object edtTestProxy: TEdit
        Left = 168
        Top = 16
        Width = 121
        Height = 21
        TabOrder = 2
      end
    end
    object tsAIConfig: TTabSheet
      Caption = 'AI Config Test'
      ImageIndex = 1
      object btnAIConfigSave: TButton
        Left = 16
        Top = 16
        Width = 97
        Height = 25
        Caption = 'AI Config Save'
        TabOrder = 0
        OnClick = btnAIConfigSaveClick
      end
      object btnAIConfigLoad: TButton
        Left = 136
        Top = 16
        Width = 97
        Height = 25
        Caption = 'AI Config Load'
        TabOrder = 1
        OnClick = btnAIConfigLoadClick
      end
      object mmoConfig: TMemo
        Left = 16
        Top = 56
        Width = 982
        Height = 503
        Anchors = [akLeft, akTop, akRight, akBottom]
        ReadOnly = True
        TabOrder = 2
      end
    end
    object tsEngine: TTabSheet
      Caption = 'AI Engine Test'
      ImageIndex = 2
      object lblAIName: TLabel
        Left = 136
        Top = 20
        Width = 44
        Height = 13
        Caption = 'AI Name:'
      end
      object lblProxy: TLabel
        Left = 464
        Top = 20
        Width = 29
        Height = 13
        Caption = 'Proxy:'
      end
      object lblMe: TLabel
        Left = 432
        Top = 56
        Width = 18
        Height = 13
        Caption = 'Me:'
      end
      object btnLoadAIConfig: TButton
        Left = 16
        Top = 16
        Width = 105
        Height = 25
        Caption = 'Load AI Config'
        TabOrder = 0
        OnClick = btnLoadAIConfigClick
      end
      object cbbAIEngines: TComboBox
        Left = 184
        Top = 16
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = cbbAIEnginesChange
      end
      object btnSaveAIConfig: TButton
        Left = 344
        Top = 16
        Width = 105
        Height = 25
        Caption = 'Save AI Config'
        TabOrder = 2
        OnClick = btnSaveAIConfigClick
      end
      object btnExplainCode: TButton
        Left = 632
        Top = 16
        Width = 73
        Height = 25
        Caption = 'Explain Code'
        TabOrder = 3
        OnClick = btnExplainCodeClick
      end
      object mmoAI: TMemo
        Left = 16
        Top = 56
        Width = 393
        Height = 503
        Anchors = [akLeft, akTop, akBottom]
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 4
      end
      object edtProxy: TEdit
        Left = 504
        Top = 16
        Width = 121
        Height = 21
        TabOrder = 5
      end
      object pnlAIChat: TPanel
        Left = 424
        Top = 88
        Width = 574
        Height = 471
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 6
      end
      object btnReviewCode: TButton
        Left = 712
        Top = 16
        Width = 73
        Height = 25
        Caption = 'Review Code'
        TabOrder = 7
        OnClick = btnReviewCodeClick
      end
      object btnFuncCall: TButton
        Left = 872
        Top = 16
        Width = 73
        Height = 25
        Caption = 'Function Call'
        TabOrder = 10
        OnClick = btnFuncCallClick
      end
      object chkMarkDown: TCheckBox
        Left = 952
        Top = 20
        Width = 73
        Height = 17
        Caption = 'MarkDown'
        TabOrder = 8
        OnClick = chkMarkDownClick
      end
      object btnModelList: TButton
        Left = 792
        Top = 16
        Width = 73
        Height = 25
        Caption = 'Model List'
        TabOrder = 9
        OnClick = btnModelListClick
      end
      object edtChatMessage: TEdit
        Left = 456
        Top = 56
        Width = 545
        Height = 21
        TabOrder = 11
        OnKeyPress = edtChatMessageKeyPress
      end
    end
    object tsChat: TTabSheet
      Caption = 'Chat'
      ImageIndex = 3
      object pnlChat: TPanel
        Left = 16
        Top = 56
        Width = 982
        Height = 503
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 0
      end
      object btnAddInfo: TButton
        Left = 16
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Add Info'
        TabOrder = 1
        OnClick = btnAddInfoClick
      end
      object btnAddMyMsg: TButton
        Left = 112
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Add My Msg'
        TabOrder = 2
        OnClick = btnAddMyMsgClick
      end
      object btnAddYouMsg: TButton
        Left = 208
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Add Your Msg'
        TabOrder = 3
        OnClick = btnAddYouMsgClick
      end
      object btnAddYouLongMsg: TButton
        Left = 304
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Your Long Msg'
        TabOrder = 4
        OnClick = btnAddYouLongMsgClick
      end
      object btnAddMyLongMsg: TButton
        Left = 400
        Top = 16
        Width = 75
        Height = 25
        Caption = 'My Long Msg'
        TabOrder = 5
        OnClick = btnAddMyLongMsgClick
      end
      object btnAddYourStream: TButton
        Left = 496
        Top = 16
        Width = 97
        Height = 25
        Caption = 'Your Stream Msg'
        TabOrder = 6
        OnClick = btnAddYourStreamClick
      end
      object btnChatFont: TButton
        Left = 936
        Top = 16
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Font'
        TabOrder = 7
        OnClick = btnChatFontClick
      end
    end
  end
  object dlgSave1: TSaveDialog
    Left = 384
    Top = 16
  end
  object dlgOpen1: TOpenDialog
    Left = 424
    Top = 16
  end
  object pmChat: TPopupMenu
    OnPopup = pmChatPopup
    Left = 468
    Top = 16
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
  end
  object pmAIChat: TPopupMenu
    OnPopup = pmAIChatPopup
    Left = 512
    Top = 16
    object CopyCode1: TMenuItem
      Caption = 'Copy Code'
      OnClick = CopyCode1Click
    end
    object CopyAll1: TMenuItem
      Caption = 'Copy Text'
      OnClick = CopyAll1Click
    end
  end
  object tmrSteam: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrSteamTimer
    Left = 420
    Top = 72
  end
  object dlgFont1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 900
    Top = 48
  end
end
