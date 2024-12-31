{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizCmdNotify;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家工具包
* 单元名称：CnWizards 命令机制的接收通知端
* 单元作者：CnPack开发组 CnPack 开发组 (master@cnpack.org)
* 备    注：该单元实现了 CnWizards 命令机制的接收通知端
*           外部程序进行命令消息接收时需要使用到本单元注册通知回调函数
* 开发平台：WinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2017.11.14 V1.1
*               适配 Unicode 编译器
*           2008.04.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Windows, Messages, Forms, CnWizCompilerConst, CnWizCmdMsg;

type
  TCnWizCmdNotifyEvent = procedure (const Command: Cardinal; const SourceID: PAnsiChar;
    const DestID: PAnsiChar; const IDESets: TCnCompilers; const Params: TStrings) of object;
  {* 命令通知的函数原型}

  ICnWizCmdNotifier = interface
    ['{E14E47D9-2D3A-4F5B-A036-400CB43C30E3}']

    procedure AddCmdNotifier(CmdNotifier: TCnWizCmdNotifyEvent; const MyID: AnsiString = '';
      AllowCommand: Cardinal = 0; AllowIDESet: TCnCompilers = []);
    {* 增加一通知器，可声明通知的附件条件，包括自身 ID，只接受的命令号，只接受的 IDE 版本}
    procedure RemoveCmdNotifier(CmdNotifier: TCnWizCmdNotifyEvent);
    {* 移除一通知器}

    function GetCurrentSourceId: AnsiString;
    {* 当前刚收到正在处理的命令的发送者，用于 Reply 回调}
  end;

  TCnWizCmdObj = class(TObject)
  {* 记录一个需要通知的客户信息，客户注册时生成}
  private
    FID: AnsiString;
    FIDESets: TCnCompilers;
    FMethod: TCnWizCmdNotifyEvent;
    FCommand: Cardinal;
    FFrom: HWND;
  public
    property From: HWND read FFrom write FFrom;
    {* 发送时发送端的 Handle，供内部 Reply 用}
    property ID: AnsiString read FID write FID;
    {* 客户的 ID，消息目标 ID 与此相同时才通知，空为通配}
    property IDESets: TCnCompilers read FIDESets write FIDESets;
    {* 客户要求的 IDE 版本号，消息目标版本号与此相同时才通知，空为通配}
    property Command: Cardinal read FCommand write FCommand;
    {* 客户要求的命令号，消息命令号与此相同时才通知，0 为所有}
    property Method: TCnWizCmdNotifyEvent read FMethod write FMethod;
    {* 客户注册的通知器函数供回调用}
  end;

  TCnWizCmdNotifier = class(TInterfacedObject, ICnWizCmdNotifier)
  {* 实现了 ICnWizCmdNotifier 接口的命令接收通知类}
  private
    FClients: TList;
    FHandle: HWnd;
    FObjectInstance: Pointer;
    FCurrentCmd: PCnWizMessage;
    procedure CnWizCmdWndProc(var Message: TMessage);
    {* 隐藏窗口的窗口过程}

    procedure CreateCmdWindow;
    {* 创建一隐藏窗口供接收 WM_COPYDATA 消息}

    procedure DestroyCmdWindow;
    {* 销毁此隐藏窗口}

    function Notify(Obj: TCnWizCmdObj; Cmd: PCnWizMessage; From: HWND): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    // ICnWizCmdNotifier
    procedure AddCmdNotifier(CmdNotifier: TCnWizCmdNotifyEvent; const MyID: AnsiString = '';
      AllowCommand: Cardinal = 0; AllowIDESet: TCnCompilers = []);
    {* 增加一通知器，可声明通知的附件条件}
    procedure RemoveCmdNotifier(CmdNotifier: TCnWizCmdNotifyEvent);
    {* 移除一通知器}
    function GetCurrentSourceId: AnsiString;
    {* 当前刚收到正在处理的命令的发送者，用于 Reply 回调}

    // property CurrentCmd: PCnWizMessage read FCurrentCmd;
    {* 当前刚收到正在处理的消息结构，用于 Reply 回调，当前可不公开}

    property CurrentSourceId: AnsiString read GetCurrentSourceId;
    {* 当前刚收到正在处理的命令的发送者，用于 Reply 回调}
  end;

function CnWizCmdNotifier: ICnWizCmdNotifier;

implementation

uses
  Consts {$IFDEF DEBUG}, CnDebug {$ENDIF};

var
  FCnWizCmdNotifier: ICnWizCmdNotifier = nil;

  CnWizCmdClass: TWndClass = (
    style: 0;
    lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: SCN_WIZ_CMD_WINDOW_NAME);

function CnWizCmdNotifier: ICnWizCmdNotifier;
begin
  if FCnWizCmdNotifier = nil then
    FCnWizCmdNotifier := TCnWizCmdNotifier.Create;

  Result := FCnWizCmdNotifier;
end;

{ TCnWizCmdNotifier }

procedure TCnWizCmdNotifier.AddCmdNotifier(CmdNotifier: TCnWizCmdNotifyEvent;
  const MyID: AnsiString; AllowCommand: Cardinal; AllowIDESet: TCnCompilers);
var
  Obj: TCnWizCmdObj;
begin
  if not Assigned(CmdNotifier) and (Length(MyID) > CN_WIZ_MAX_ID) then
    Exit;

  Obj := TCnWizCmdObj.Create;
  Obj.Command := AllowCommand;
  Obj.IDESets := AllowIDESet;
  Obj.ID := MyID;
  Obj.Method := CmdNotifier;

  FClients.Add(Obj);
end;

procedure TCnWizCmdNotifier.CnWizCmdWndProc(var Message: TMessage);
var
  I: Integer;
begin
  Message.Result := 0;
  case Message.Msg of
    WM_COPYDATA:
      begin
        FCurrentCmd := TWmCopyData(Message).CopyDataStruct^.lpData;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('WizCmdNotifier: Got Broadcast Message. Send to %d Clients.', [FClients.Count]);
{$ENDIF}
        for I := 0 to FClients.Count - 1 do
        begin
          Message.Result := Integer(Notify(TCnWizCmdObj(FClients[I]),
            FCurrentCmd, TWmCopyData(Message).From)); // 通知出去后Notify才返回 True
        end;
        FCurrentCmd := nil;
      end;
  else
    Message.Result := DefWindowProc(FHandle, Message.Msg, Message.WParam, Message.LParam);
  end;
end;

constructor TCnWizCmdNotifier.Create;
begin
  FClients := TList.Create;
  CreateCmdWindow;
end;

procedure TCnWizCmdNotifier.CreateCmdWindow;
var
  TempClass: TWndClass;
begin
  FObjectInstance := MakeObjectInstance(CnWizCmdWndProc);
  if not GetClassInfo(HInstance, CnWizCmdClass.lpszClassName, TempClass) then
  begin
    CnWizCmdClass.hInstance := HInstance;
    if Windows.RegisterClass(CnWizCmdClass) = 0 then
      raise EOutOfResources.Create(SWindowClass);
  end;

  FHandle := CreateWindow(CnWizCmdClass.lpszClassName, PChar(SCN_WIZ_CMD_WINDOW_NAME),
    WS_POPUP or WS_CAPTION or WS_CLIPSIBLINGS or WS_SYSMENU
    or WS_MINIMIZEBOX,
    GetSystemMetrics(SM_CXSCREEN) div 2,
    GetSystemMetrics(SM_CYSCREEN) div 2,
    0, 0, 0, 0, HInstance, nil);

  SetWindowLong(FHandle, GWL_WNDPROC, Longint(FObjectInstance));
{$IFDEF DEBUG}
  CnDebugger.LogFmt('WizCmdNotifier: Create Window %8.8x', [FHandle]);
{$ENDIF}
end;

destructor TCnWizCmdNotifier.Destroy;
var
  I: Integer;
begin
  DestroyCmdWindow;
  for I := FClients.Count - 1 downto 0 do
    TObject(FClients[I]).Free;

  FClients.Free;
  inherited;
end;

procedure TCnWizCmdNotifier.DestroyCmdWindow;
begin
  if FHandle <> 0 then
    DestroyWindow(FHandle);
  if FObjectInstance <> nil then
    FreeObjectInstance(FObjectInstance);
end;

function TCnWizCmdNotifier.GetCurrentSourceId: AnsiString;
begin
  Result := '';
  if FCurrentCmd <> nil then
    Result := FCurrentCmd^.SourceID;
end;

function TCnWizCmdNotifier.Notify(Obj: TCnWizCmdObj; Cmd: PCnWizMessage;
  From: HWND): Boolean;
var
  IDESets: TCnCompilers;
  Params: TStrings;
  S: AnsiString;
begin
  Result := False;
  if (Obj = nil) or (Cmd = nil) then
    Exit;

  // 过滤命令号
  if (Obj.Command <> 0) and (Cmd^.Command <> Obj.Command) then
    Exit;

  // 过滤版本
  PInteger(@IDESets)^ := Cmd^.IDESets;
  if (Obj.IDESets <> []) and ((Obj.IDESets * IDESets) <> []) then
    Exit;

  // 过滤目标地址，两地址都不为空时才需要对比过滤，只要有一个为空，就表示通配
  if (Obj.ID <> '') and (Cmd^.DestID <> '') and (StrComp(PAnsiChar(Obj.ID), Cmd^.DestID) <> 0) then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('WizCmdNotifier: Got Effective Notify. Cmd %d, DestID %s. IDESets %d.',
    [Cmd^.Command, Cmd^.DestID, Cmd^.IDESets]);
{$ENDIF}

  Params := TStringList.Create;
  try
    Obj.From := From;
    if Cmd^.DataLength > 0 then
    begin
      SetLength(S, Cmd^.DataLength);
      CopyMemory(@S[1], @(Cmd^.Data[0]), Cmd^.DataLength);
      Params.Text := string(S);
    end;
    Obj.Method(Cmd^.Command, Cmd^.SourceID, Cmd^.DestID, IDESets, Params);
  finally
    Params.Free;
  end;
  Result := True;
end;

procedure TCnWizCmdNotifier.RemoveCmdNotifier(
  CmdNotifier: TCnWizCmdNotifyEvent);
var
  I: Integer;
  Obj: TCnWizCmdObj;
begin
  for I := FClients.Count - 1 downto 0 do
  begin
    Obj := TCnWizCmdObj(FClients[I]);
    if Obj = nil then
      Continue;

    if CompareMem(@Obj.Method, @CmdNotifier, SizeOf(TMethod)) then
    begin
      FClients.Delete(I);
      Obj.Free;
      Exit;
    end;
  end;
end;

initialization
  // FCnWizCmdNotifier := TCnWizCmdNotifier.Create; 不预先创建，使用时才创建

finalization
  FCnWizCmdNotifier := nil;

end.
