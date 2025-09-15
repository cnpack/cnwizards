{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizCmdNotify;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�ҹ��߰�
* ��Ԫ���ƣ�CnWizards ������ƵĽ���֪ͨ��
* ��Ԫ���ߣ�CnPack������ CnPack ������ (master@cnpack.org)
* ��    ע���õ�Ԫʵ���� CnWizards ������ƵĽ���֪ͨ��
*           �ⲿ�������������Ϣ����ʱ��Ҫʹ�õ�����Ԫע��֪ͨ�ص�����
* ����ƽ̨��WinXP + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2017.11.14 V1.1
*               ���� Unicode ������
*           2008.04.29 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Windows, Messages, Forms, CnWizCompilerConst, CnWizCmdMsg;

type
  TCnWizCmdNotifyEvent = procedure (const Command: Cardinal; const SourceID: PAnsiChar;
    const DestID: PAnsiChar; const IDESets: TCnCompilers; const Params: TStrings) of object;
  {* ����֪ͨ�ĺ���ԭ��}

  ICnWizCmdNotifier = interface
    ['{E14E47D9-2D3A-4F5B-A036-400CB43C30E3}']

    procedure AddCmdNotifier(CmdNotifier: TCnWizCmdNotifyEvent; const MyID: AnsiString = '';
      AllowCommand: Cardinal = 0; AllowIDESet: TCnCompilers = []);
    {* ����һ֪ͨ����������֪ͨ�ĸ����������������� ID��ֻ���ܵ�����ţ�ֻ���ܵ� IDE �汾}
    procedure RemoveCmdNotifier(CmdNotifier: TCnWizCmdNotifyEvent);
    {* �Ƴ�һ֪ͨ��}

    function GetCurrentSourceId: AnsiString;
    {* ��ǰ���յ����ڴ��������ķ����ߣ����� Reply �ص�}
  end;

  TCnWizCmdObj = class(TObject)
  {* ��¼һ����Ҫ֪ͨ�Ŀͻ���Ϣ���ͻ�ע��ʱ����}
  private
    FID: AnsiString;
    FIDESets: TCnCompilers;
    FMethod: TCnWizCmdNotifyEvent;
    FCommand: Cardinal;
    FFrom: HWND;
  public
    property From: HWND read FFrom write FFrom;
    {* ����ʱ���Ͷ˵� Handle�����ڲ� Reply ��}
    property ID: AnsiString read FID write FID;
    {* �ͻ��� ID����ϢĿ�� ID �����ͬʱ��֪ͨ����Ϊͨ��}
    property IDESets: TCnCompilers read FIDESets write FIDESets;
    {* �ͻ�Ҫ��� IDE �汾�ţ���ϢĿ��汾�������ͬʱ��֪ͨ����Ϊͨ��}
    property Command: Cardinal read FCommand write FCommand;
    {* �ͻ�Ҫ�������ţ���Ϣ����������ͬʱ��֪ͨ��0 Ϊ����}
    property Method: TCnWizCmdNotifyEvent read FMethod write FMethod;
    {* �ͻ�ע���֪ͨ���������ص���}
  end;

  TCnWizCmdNotifier = class(TInterfacedObject, ICnWizCmdNotifier)
  {* ʵ���� ICnWizCmdNotifier �ӿڵ��������֪ͨ��}
  private
    FClients: TList;
    FHandle: HWnd;
    FObjectInstance: Pointer;
    FCurrentCmd: PCnWizMessage;
    procedure CnWizCmdWndProc(var Message: TMessage);
    {* ���ش��ڵĴ��ڹ���}

    procedure CreateCmdWindow;
    {* ����һ���ش��ڹ����� WM_COPYDATA ��Ϣ}

    procedure DestroyCmdWindow;
    {* ���ٴ����ش���}

    function Notify(Obj: TCnWizCmdObj; Cmd: PCnWizMessage; From: HWND): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    // ICnWizCmdNotifier
    procedure AddCmdNotifier(CmdNotifier: TCnWizCmdNotifyEvent; const MyID: AnsiString = '';
      AllowCommand: Cardinal = 0; AllowIDESet: TCnCompilers = []);
    {* ����һ֪ͨ����������֪ͨ�ĸ�������}
    procedure RemoveCmdNotifier(CmdNotifier: TCnWizCmdNotifyEvent);
    {* �Ƴ�һ֪ͨ��}
    function GetCurrentSourceId: AnsiString;
    {* ��ǰ���յ����ڴ��������ķ����ߣ����� Reply �ص�}

    // property CurrentCmd: PCnWizMessage read FCurrentCmd;
    {* ��ǰ���յ����ڴ������Ϣ�ṹ������ Reply �ص�����ǰ�ɲ�����}

    property CurrentSourceId: AnsiString read GetCurrentSourceId;
    {* ��ǰ���յ����ڴ��������ķ����ߣ����� Reply �ص�}
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
            FCurrentCmd, TWmCopyData(Message).From)); // ֪ͨ��ȥ��Notify�ŷ��� True
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

{$IFDEF WIN64}
  SetWindowLong(FHandle, GWL_WNDPROC, NativeInt(FObjectInstance));
{$ELSE}
  SetWindowLong(FHandle, GWL_WNDPROC, Longint(FObjectInstance));
{$ENDIF}

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

  // ���������
  if (Obj.Command <> 0) and (Cmd^.Command <> Obj.Command) then
    Exit;

  // ���˰汾
  PInteger(@IDESets)^ := Cmd^.IDESets;
  if (Obj.IDESets <> []) and ((Obj.IDESets * IDESets) <> []) then
    Exit;

  // ����Ŀ���ַ������ַ����Ϊ��ʱ����Ҫ�Աȹ��ˣ�ֻҪ��һ��Ϊ�գ��ͱ�ʾͨ��
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
  // FCnWizCmdNotifier := TCnWizCmdNotifier.Create; ��Ԥ�ȴ�����ʹ��ʱ�Ŵ���

finalization
  FCnWizCmdNotifier := nil;

end.
