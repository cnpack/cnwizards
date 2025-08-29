object FormExtract: TFormExtract
  Left = 424
  Top = 121
  Width = 830
  Height = 626
  Caption = 'Extract Strings from Source - Unicode/Non Unicode Compiler'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 801
    Height = 577
    ActivePage = tsPas
    TabOrder = 0
    object tsPas: TTabSheet
      Caption = 'Pascal'
      object btnAnsiStrings: TButton
        Left = 8
        Top = 8
        Width = 105
        Height = 25
        Caption = 'Ansi Parse Strings'
        TabOrder = 0
        OnClick = btnAnsiStringsClick
      end
      object mmoPas: TMemo
        Left = 8
        Top = 48
        Width = 769
        Height = 201
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'unit UnitForm;'
          ''
          'interface'
          ''
          'uses'
          
            '  Windows, Messages, SysUtils, Classes, Graphics, Controls, Form' +
            's, Dialogs,'
          '  StdCtrls, CnThreadingTCPServer, CnTCPForwarder;'
          ''
          'type'
          '  TFormForwarder = class(TForm)'
          '    lblIP: TLabel;'
          '    lblPort: TLabel;'
          '    edtLocalIP: TEdit;'
          '    edtLocalPort: TEdit;'
          '    btnOpen: TButton;'
          '    lblRemoteHost: TLabel;'
          '    lblRemotePort: TLabel;'
          '    edtRemoteHost: TEdit;'
          '    edtRemotePort: TEdit;'
          '    mmoResult: TMemo;'
          '    procedure FormCreate(Sender: TObject);'
          '    procedure btnOpenClick(Sender: TObject);'
          '  private'
          '    FForwarder: TCnTCPForwarder;'
          '    procedure Log(const Msg: string);'
          '  public'
          
            '    procedure TCPAccept(Sender: TObject; ClientSocket: TCnClient' +
            'Socket);'
          '    procedure TCPError(Sender: TObject; SocketError: Integer);'
          
            '    procedure ServerData(Sender: TObject; Buf: Pointer; var Data' +
            'Size: Integer;'
          '      var NewBuf: Pointer; var NewDataSize: Integer);'
          
            '    procedure ClientData(Sender: TObject; Buf: Pointer; var Data' +
            'Size: Integer;'
          '      var NewBuf: Pointer; var NewDataSize: Integer);'
          '    procedure RemoteConnectd(Sender: TObject);'
          '  end;'
          ''
          'var'
          '  FormForwarder: TFormForwarder;'
          '  S: string = '#39'Test Me'#39';'
          ''
          'implementation'
          ''
          '{$R *.DFM}'
          ''
          'const'
          ' AA = '#39'吃饭'#39';'
          ''
          'resourcestring'
          ' BB = '#39'DAK ME OK'#39';'
          ''
          'procedure TFormForwarder.FormCreate(Sender: TObject);'
          'begin'
          '  FForwarder := TCnTCPForwarder.Create(Self);'
          '  FForwarder.OnAccept := TCPAccept;'
          '  FForwarder.OnError := TCPError;'
          '  FForwarder.OnRemoteConnected := RemoteConnectd;'
          '  FForwarder.OnServerData := ServerData;'
          '  FForwarder.OnClientData := ClientData;'
          'end;'
          ''
          'procedure TFormForwarder.Log(const Msg: string);'
          'begin'
          '  mmoResult.Lines.Add(Msg);'
          'end;'
          ''
          'procedure TFormForwarder.TCPAccept(Sender: TObject;'
          '  ClientSocket: TCnClientSocket);'
          'begin'
          
            '  Log('#39'Client Connected: '#39' + ClientSocket.RemoteIP + '#39':'#39' + IntTo' +
            'Str(ClientSocket.RemotePort));'
          'end;'
          ''
          
            'procedure TFormForwarder.TCPError(Sender: TObject; SocketError: ' +
            'Integer);'
          'begin'
          '  Log('#39'*** Socket Error: '#39' + IntToStr(SocketError));'
          'end;'
          ''
          'procedure TFormForwarder.btnOpenClick(Sender: TObject);'
          'begin'
          '  if FForwarder.Active then'
          '  begin'
          '    FForwarder.Close;'
          '    btnOpen.Caption := '#39'Forward To:'#39';'
          '  end'
          '  else'
          '  begin'
          '    FForwarder.LocalIP := edtLocalIP.Text;'
          '    FForwarder.LocalPort := StrToInt(edtLocalPort.Text);'
          '    FForwarder.RemoteHost := edtRemoteHost.Text;'
          '    FForwarder.RemotePort := StrToInt(edtRemotePort.Text);'
          ''
          '    FForwarder.Active := True;'
          '    if FForwarder.Listening then'
          '      btnOpen.Caption := '#39'Close'#39';'
          '  end;'
          'end;'
          ''
          'procedure TFormForwarder.RemoteConnectd(Sender: TObject);'
          'begin'
          '  Log('#39'Remote Connected.'#39');'
          'end;'
          ''
          
            'procedure TFormForwarder.ClientData(Sender: TObject; Buf: Pointe' +
            'r;'
          
            '  var DataSize: Integer; var NewBuf: Pointer; var NewDataSize: I' +
            'nteger);'
          'begin'
          '  Log('#39'Get Client Bytes: '#39' + IntToStr(DataSize));'
          'end;'
          ''
          
            'procedure TFormForwarder.ServerData(Sender: TObject; Buf: Pointe' +
            'r;'
          
            '  var DataSize: Integer; var NewBuf: Pointer; var NewDataSize: I' +
            'nteger);'
          'begin'
          '  Log('#39'Get Server Bytes: '#39' + IntToStr(DataSize));'
          'end;'
          ''
          'end.')
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object mmoParsePas: TMemo
        Left = 8
        Top = 256
        Width = 769
        Height = 281
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 2
        WordWrap = False
      end
      object btnWideStrings: TButton
        Left = 128
        Top = 8
        Width = 105
        Height = 25
        Caption = 'Wide Parse Strings'
        TabOrder = 3
        OnClick = btnWideStringsClick
      end
    end
    object tsCpp: TTabSheet
      Caption = 'C/C++'
      ImageIndex = 1
    end
    object tsIdent: TTabSheet
      Caption = 'Ident Test'
      ImageIndex = 2
      object btnConvertIdent: TButton
        Left = 16
        Top = 16
        Width = 113
        Height = 25
        Caption = 'Convert to Ident'
        TabOrder = 0
        OnClick = btnConvertIdentClick
      end
      object mmoStrings: TMemo
        Left = 16
        Top = 64
        Width = 489
        Height = 185
        Lines.Strings = (
          'mmoStrings'
          'I am CnPack Team Member.'
          'OK! 吃饭了！有不少菜'
          '3.1415926'
          '纯文本，看看'
          #39'0123456789ABCDEF'#39)
        TabOrder = 1
      end
      object chkUnderLine: TCheckBox
        Left = 152
        Top = 24
        Width = 97
        Height = 17
        Caption = 'UnderLine'
        TabOrder = 2
      end
      object mmoIdent: TMemo
        Left = 16
        Top = 256
        Width = 489
        Height = 273
        TabOrder = 3
      end
      object cbbStyle: TComboBox
        Left = 336
        Top = 24
        Width = 81
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 4
        Items.Strings = (
          'UpperCase'
          'LowerCase'
          'UpperFirst')
      end
      object chkFullPinYin: TCheckBox
        Left = 232
        Top = 24
        Width = 89
        Height = 17
        Caption = 'Full PinYin'
        TabOrder = 5
      end
    end
  end
end
