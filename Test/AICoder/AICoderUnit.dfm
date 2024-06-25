object FormAITest: TFormAITest
  Left = 192
  Top = 109
  BorderStyle = bsDialog
  Caption = 'AI Coder Test'
  ClientHeight = 592
  ClientWidth = 956
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
    Left = 16
    Top = 16
    Width = 921
    Height = 553
    ActivePage = tsHTTP
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
        Width = 881
        Height = 449
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
        Width = 881
        Height = 449
        ReadOnly = True
        TabOrder = 2
      end
    end
    object tsEngine: TTabSheet
      Caption = 'AI Engine Test'
      ImageIndex = 2
      object lblAIName: TLabel
        Left = 144
        Top = 20
        Width = 44
        Height = 13
        Caption = 'AI Name:'
      end
      object lblProxy: TLabel
        Left = 504
        Top = 20
        Width = 29
        Height = 13
        Caption = 'Proxy:'
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
        Left = 200
        Top = 16
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = cbbAIEnginesChange
      end
      object btnSaveAIConfig: TButton
        Left = 376
        Top = 16
        Width = 105
        Height = 25
        Caption = 'Save AI Config'
        TabOrder = 2
        OnClick = btnSaveAIConfigClick
      end
      object btnExplainCode: TButton
        Left = 776
        Top = 16
        Width = 121
        Height = 25
        Caption = 'Explain Code'
        TabOrder = 3
        OnClick = btnExplainCodeClick
      end
      object mmoAI: TMemo
        Left = 16
        Top = 56
        Width = 393
        Height = 457
        ReadOnly = True
        TabOrder = 4
      end
      object edtProxy: TEdit
        Left = 544
        Top = 16
        Width = 121
        Height = 21
        TabOrder = 5
      end
      object pnlAIChat: TPanel
        Left = 424
        Top = 56
        Width = 473
        Height = 457
        BevelOuter = bvNone
        TabOrder = 6
      end
    end
    object tsChat: TTabSheet
      Caption = 'Chat'
      ImageIndex = 3
      object pnlChat: TPanel
        Left = 16
        Top = 56
        Width = 881
        Height = 457
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
end
