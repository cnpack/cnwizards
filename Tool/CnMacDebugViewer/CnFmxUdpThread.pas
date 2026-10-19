unit CnFmxUdpThread;
{ CnMacDebugViewer 的 UDP 调试消息接收线程。
  对应原版 CnViewMain 中基于 TCnUDP（WinSock 消息驱动）的接收逻辑，
  Mac 上改用 POSIX socket 的阻塞式 recvfrom 循环实现，收包后 Synchronize 回主线程处理。
  收到的裸缓冲内容与 Windows 版一致：直接包装为 cmtUDPMsg 类型消息入库。 }
{$IFDEF POSIX}

interface

uses
  System.Classes, System.SysUtils, System.Types,
  Posix.NetinetIn, Posix.Unistd,
  CnMsgClasses;

type
  TCnUdpMsgEvent = procedure(Sender: TObject; const FromIP: string;
    Port: Integer; Buffer: Pointer; Len: Integer) of object;

  TCnUdpGetThread = class(TThread)
  {* 接收 UDP 调试消息的线程}
  private
    FPort: Integer;
    FSocket: Integer;
    FBuffer: array[0..8191] of Byte;
    FFromIP: string;
    FFromPort: Integer;
    FLatestLen: Integer;
    FOnUdpMsg: TCnUdpMsgEvent;
    procedure DoUdpMsg;
  protected
    procedure Execute; override;
  public
    constructor Create(APort: Integer);
    destructor Destroy; override;
    // 主线程调用：Terminate 并 shutdown 套接字，促使阻塞的 recvfrom 立即返回
    procedure Stop;
    property OnUdpMsg: TCnUdpMsgEvent read FOnUdpMsg write FOnUdpMsg;
  end;

implementation

{ libc 直声明，签名与 macOS 一致；类型取自官方 Posix 单元 }

const
  libc = '/usr/lib/libc.dylib';

  AF_INET     = 2;
  SOCK_DGRAM  = 2;
  SOL_SOCKET  = $FFFF;      // macOS
  SO_REUSEADDR = $0004;     // macOS
  SHUT_RDWR   = 2;

function posix_socket(domain, tp, protocol: Integer): Integer; cdecl; external libc name 'socket';
function posix_bind(fd: Integer; addr: Pointer; len: Cardinal): Integer; cdecl; external libc name 'bind';
function posix_recvfrom(fd: Integer; buf: Pointer; len: Cardinal; flags: Integer;
  from: Pointer; fromlen: Pointer): Integer; cdecl; external libc name 'recvfrom';
function posix_shutdown(fd, how: Integer): Integer; cdecl; external libc name 'shutdown';
function posix_setsockopt(fd, level, optname: Integer; optval: Pointer; optlen: Cardinal): Integer; cdecl; external libc name 'setsockopt';
function posix_htons(Value: Word): Word; cdecl; external libc name 'htons';

{ TCnUdpGetThread }

constructor TCnUdpGetThread.Create(APort: Integer);
begin
  FPort := APort;
  FSocket := -1;
  FreeOnTerminate := False;
  inherited Create(False);
end;

destructor TCnUdpGetThread.Destroy;
begin
  Terminate;
  if FSocket > 0 then
    posix_shutdown(FSocket, SHUT_RDWR); // 确保阻塞的 recvfrom 立即返回
  inherited Destroy; // TThread.Destroy 内部会 WaitFor
  if FSocket > 0 then
  begin
    __close(FSocket);
    FSocket := -1;
  end;
end;

procedure TCnUdpGetThread.DoUdpMsg;
begin
  if Assigned(FOnUdpMsg) then
    FOnUdpMsg(Self, FFromIP, FFromPort, @FBuffer[0], FLatestLen);
end;

procedure TCnUdpGetThread.Execute;
var
  Addr: sockaddr_in;
  FromAddr: sockaddr_in;
  FromLen: Integer;
  Len: Integer;
  Reuse: Integer;
begin
  FSocket := posix_socket(AF_INET, SOCK_DGRAM, 0);
  if FSocket < 0 then
    Exit;

  Reuse := 1;
  posix_setsockopt(FSocket, SOL_SOCKET, SO_REUSEADDR, @Reuse, SizeOf(Reuse));

  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sin_family := AF_INET;
  Addr.sin_port := posix_htons(Word(FPort));
  Addr.sin_addr.s_addr := INADDR_ANY;

  if posix_bind(FSocket, @Addr, SizeOf(Addr)) < 0 then
  begin
    Posix.Unistd.__close(FSocket);
    FSocket := -1;
    Exit;
  end;

  while not Terminated do
  begin
    FromLen := SizeOf(FromAddr);
    FillChar(FromAddr, SizeOf(FromAddr), 0);
    Len := posix_recvfrom(FSocket, @FBuffer[0], SizeOf(FBuffer), 0,
      @FromAddr, @FromLen);
    if Len <= 0 then
    begin
      if Terminated then
        Break;
      Sleep(50);
      Continue;
    end;

    FLatestLen := Len;
    FFromPort := FromAddr.sin_port;  // 网络字节序，展示时换算
    FFromPort := ((FFromPort and $FF) shl 8) or ((FFromPort shr 8) and $FF);
    // s_addr 为网络字节序（大端），首八位组在低字节
    FFromIP := Format('%d.%d.%d.%d', [FromAddr.sin_addr.s_addr and $FF,
      (FromAddr.sin_addr.s_addr shr 8) and $FF,
      (FromAddr.sin_addr.s_addr shr 16) and $FF,
      (FromAddr.sin_addr.s_addr shr 24) and $FF]);

    // 复制数据后同步到主线程处理
    Synchronize(DoUdpMsg);
  end;
end;

procedure TCnUdpGetThread.Stop;
begin
  Terminate;
  if FSocket > 0 then
    posix_shutdown(FSocket, SHUT_RDWR);
end;

{$ENDIF}
end.

