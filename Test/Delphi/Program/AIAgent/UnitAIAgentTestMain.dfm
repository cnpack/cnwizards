object AIAgentTestForm: TAIAgentTestForm
  Left = 0
  Top = 0
  Width = 868
  Height = 652
  Caption = 'AIAgent ACP Client - GUI Test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlSplitter: TSplitter
    Left = 0
    Top = 366
    Width = 860
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ResizeStyle = rsLine
  end
  object pnlConnection: TPanel
    Left = 0
    Top = 0
    Width = 860
    Height = 49
    Align = alTop
    TabOrder = 0
    object lblAgentPath: TLabel
      Left = 12
      Top = 7
      Width = 54
      Height = 13
      Caption = 'Agent Path'
    end
    object lblAgentArgs: TLabel
      Left = 316
      Top = 7
      Width = 54
      Height = 13
      Caption = 'Agent Args'
    end
    object lblProtocol: TLabel
      Left = 664
      Top = 7
      Width = 39
      Height = 13
      Caption = 'Protocol'
    end
    object lblState: TLabel
      Left = 728
      Top = 25
      Width = 51
      Height = 13
      Caption = 'State: Idle'
    end
    object edtAgentPath: TEdit
      Left = 12
      Top = 22
      Width = 289
      Height = 21
      TabOrder = 0
    end
    object edtAgentArgs: TEdit
      Left = 316
      Top = 22
      Width = 153
      Height = 21
      TabOrder = 1
    end
    object btnStart: TButton
      Left = 484
      Top = 20
      Width = 75
      Height = 25
      Caption = 'Start'
      TabOrder = 2
      OnClick = btnStartClick
    end
    object btnStop: TButton
      Left = 565
      Top = 20
      Width = 75
      Height = 25
      Caption = 'Stop'
      TabOrder = 3
      OnClick = btnStopClick
    end
    object edtProtocol: TEdit
      Left = 664
      Top = 22
      Width = 49
      Height = 21
      ReadOnly = True
      TabOrder = 4
    end
  end
  object pnlSession: TPanel
    Left = 0
    Top = 49
    Width = 860
    Height = 49
    Align = alTop
    TabOrder = 1
    object lblCwd: TLabel
      Left = 12
      Top = 6
      Width = 21
      Height = 13
      Caption = 'Cwd'
    end
    object lblSessionId: TLabel
      Left = 316
      Top = 6
      Width = 50
      Height = 13
      Caption = 'Session ID'
    end
    object edtCwd: TEdit
      Left = 12
      Top = 22
      Width = 289
      Height = 21
      TabOrder = 0
    end
    object btnNewSession: TButton
      Left = 484
      Top = 20
      Width = 75
      Height = 25
      Caption = 'New Session'
      TabOrder = 2
      OnClick = btnNewSessionClick
    end
    object btnCloseSession: TButton
      Left = 565
      Top = 20
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 3
      OnClick = btnCloseSessionClick
    end
    object edtSessionId: TEdit
      Left = 316
      Top = 22
      Width = 153
      Height = 21
      ReadOnly = True
      TabOrder = 1
    end
  end
  object pnlPrompt: TPanel
    Left = 0
    Top = 98
    Width = 860
    Height = 81
    Align = alTop
    TabOrder = 2
    object lblPrompt: TLabel
      Left = 12
      Top = 6
      Width = 34
      Height = 13
      Caption = 'Prompt'
    end
    object memPrompt: TMemo
      Left = 12
      Top = 22
      Width = 649
      Height = 49
      Lines.Strings = (
        'List files in current directory')
      TabOrder = 0
    end
    object btnSendPrompt: TButton
      Left = 676
      Top = 34
      Width = 75
      Height = 25
      Caption = 'Send'
      TabOrder = 1
      OnClick = btnSendPromptClick
    end
  end
  object pnlToolStatus: TPanel
    Left = 0
    Top = 179
    Width = 860
    Height = 187
    Align = alClient
    Caption = 'pnlToolStatus'
    TabOrder = 3
    object tvTools: TTreeView
      Left = 1
      Top = 1
      Width = 858
      Height = 185
      Align = alClient
      Indent = 19
      TabOrder = 0
    end
  end
  object pnlLog: TPanel
    Left = 0
    Top = 369
    Width = 860
    Height = 232
    Align = alBottom
    Caption = 'pnlLog'
    TabOrder = 4
    object memLog: TMemo
      Left = 1
      Top = 1
      Width = 858
      Height = 230
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object stsBar: TStatusBar
    Left = 0
    Top = 601
    Width = 860
    Height = 19
    Panels = <
      item
        Text = 'State: Idle'
        Width = 120
      end
      item
        Text = 'Ready'
        Width = 50
      end>
    SimplePanel = False
  end
end
