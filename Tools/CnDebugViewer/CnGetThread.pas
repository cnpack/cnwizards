{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2012 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnGetThread;
{ |<PRE>
================================================================================
* 软件名称：CnDebugViewer
* 单元名称：读取线程单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2006.10.15
*               加入读取 OutputDebugString 内容的功能
*           2005.01.01
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

uses
  Classes, SysUtils, Windows, Forms, Contnrs,
  CnViewCore, CnDebugIntf, CnMsgClasses;

type
  TGetDebugThread = class(TThread)
  {* 读取 CnDebugger 内容的线程}
  private
    FPaused: Boolean;
  protected
    procedure AddADescToStore(var ADesc: TCnMsgDesc);
    procedure Execute; override;
  public
    property Paused: Boolean read FPaused write FPaused;
  end;

  TDbgGetDebugThread = class(TGetDebugThread)
  {* 读取 OutputDebugString 内容的线程}
  protected
    procedure Execute; override;
  end;

implementation

uses
  CnMdiView;

{ GetDebug }

procedure TGetDebugThread.AddADescToStore(var ADesc: TCnMsgDesc);
var
  AStore: TCnMsgStore;
  StoreInited: Boolean;
begin
  AStore := CnMsgManager.IndexOf(ADesc.Annex.ProcessId);
  StoreInited := False;
  if AStore = nil then
  begin
    AStore := CnMsgManager.IndexOf(0);
    if AStore = nil then
    begin
      if Application.MainForm <> nil then
        if not (csDestroying in Application.MainForm.ComponentState) then
        begin
          AStore := CnMsgManager.AddStore(0, SCnNoneProcName);
          AStore.ProcessID := ADesc.Annex.ProcessId;
          AStore.ProcName := GetProcNameFromProcessID(AStore.ProcessID);
          PostMessage(Application.MainForm.Handle, WM_USER_NEW_FORM, Integer(AStore), 0);
        end;
    end;

    if not StoreInited and (AStore <> nil) then
    begin
      AStore.ProcessID := ADesc.Annex.ProcessId;
      AStore.ProcName := GetProcNameFromProcessID(AStore.ProcessID);
    end;
  end;

  // 如无空余的或对应的 Store，则不输出
  if AStore <> nil then
  begin
    // 有输出内容时先开始批量读取，等待内容读完时再更新界面
    AStore.BeginUpdate;
    AStore.AddMsgDesc(@ADesc);
  end;
end;

procedure TGetDebugThread.Execute;
var
  Len, RestLen, QueueSize: Integer;
  Desc: PCnMsgDesc;
  ADesc: TCnMsgDesc;
  Front, Tail: Integer;
  Res: DWORD;
begin
  PostStartEvent;
  QueueSize := CnMapSize - CnHeadSize;
  if HMutex = 0 then
    HMutex := CreateMutex(nil, False, SCnDebugQueueMutexName);

  while not Terminated do
  begin
    Res := WaitForSingleObject(HEvent, CnWaitEventTime);
    if Res = WAIT_FAILED then // 即使超时也可判断一下队列状态
    begin
      Sleep(0);
      Continue;
    end;

    if PHeader^.QueueFront = PHeader^.QueueTail then
    begin
      // 队列空，可开始更新界面
      if (Application.MainForm <> nil) and not (csDestroying in Application.MainForm.ComponentState) then
        PostMessage(Application.MainForm.Handle, WM_USER_UPDATE_STORE, 0, 0);
      Sleep(0);
      Continue;
    end;

    Res := WaitForSingleObject(HMutex, CnWaitMutexTime);
    if (Res = WAIT_FAILED) or (Res = WAIT_TIMEOUT) then
    begin
      //Sleep(0);
      Continue;
    end;

    Front := PHeader^.QueueFront;
    Tail := PHeader^.QueueTail;
    if Front = Tail then
    begin
      if Terminated then
      begin
        CloseHandle(HMutex);
        HMutex := 0;
        Exit;
      end;
      ReleaseMutex(HMutex);
      Continue;
    end;

    Desc := PCnMsgDesc(Front + PHeader^.DataOffset + Integer(PBase));
    if not Paused then
    begin
      FillChar(ADesc, SizeOf(ADesc), 0);
      Len := Desc^.Length;

      if Len = 0 then // 避免发送端出错导致死循环
      begin
        PHeader^.QueueFront := 0;
        PHeader^.QueueTail := 0;
        if Terminated then
        begin
          CloseHandle(HMutex);
          HMutex := 0;
          Exit;
        end;
        ReleaseMutex(HMutex);
        Continue;
      end;
      
      if Front + Len < QueueSize then
        CopyMemory(@ADesc, Desc ,Len)
      else
      begin
        RestLen := QueueSize - Front;
        CopyMemory(@ADesc, Desc ,RestLen);
        CopyMemory(Pointer(Integer(@ADesc) + RestLen), Pointer(PHeader^.DataOffset + Integer(PBase)), Len - RestLen);
      end;

      EnterCriticalSection(CSMsgStore);
      try
        AddADescToStore(ADesc);
      finally
        LeaveCriticalSection(CSMsgStore);
      end;
    end; // 暂停时会读指针然后加指针，不取出内容

    Inc(PHeader^.QueueFront, Desc^.Length);
    if PHeader^.QueueFront >= QueueSize then
      PHeader^.QueueFront := PHeader^.QueueFront mod QueueSize;

    if Terminated then
    begin
      CloseHandle(HMutex);
      HMutex := 0;
      Exit;
    end;
    ReleaseMutex(HMutex);
    if HFlush = 0 then
      HFlush := OpenEvent(EVENT_MODIFY_STATE, False, SCnDebugFlushEventName);
    if HFlush <> 0 then
      SetEvent(hFlush);
  end;
end;

{ TDbgGetDebugThread }

procedure TDbgGetDebugThread.Execute;
var
  Res: DWORD;
  ADesc: TCnMsgDesc;
  PPid: PDWORD;
  PStr: PChar;
  Len: Integer;
begin
  if not SysDebugReady then
    InitSysDebug;

  while not Terminated do
  begin
    if not SysDebugReady then
    begin
      Sleep(0);
      Continue;
    end;

    if not SetEvent(HSysBufferReady) then
    begin
      Sleep(0);
      Continue;
    end;

    Res := WaitForSingleObject(HSysDataReady, CnWaitEventTime);
    if Res <> WAIT_OBJECT_0 then
    begin
      Sleep(0);
      Continue;
    end;

    if Paused then
    begin
      Sleep(0);
      Continue;
    end;

    FillChar(ADesc, SizeOf(ADesc), 0);
    PPid := PDWORD(PSysDbgBase);
    PStr := PChar(Integer(PSysDbgBase) + SizeOf(DWORD));

    ADesc.Annex.ProcessId := PPid^;
    
    // OutputDebugString 无对应信息，因此需要手工填写
    ADesc.Annex.Level := CnDefLevel;
    ADesc.Annex.MsgType := Ord(cmtSystem);
    // 无 ThreadId、无 Tag

    // 无发送端时间戳，近似采用接收端时间戳
    ADesc.Annex.TimeStampType := Ord(ttDateTime);
    ADesc.Annex.MsgDateTime := Date + Time;
    Len := StrLen(PStr);
    if Len >= DbWinBufferSize - SizeOf(DWORD) then
      Len := DbWinBufferSize - SizeOf(DWORD);
    CopyMemory(@(ADesc.Msg[0]), PStr, Len);
    ADesc.Length := Len + SizeOf(TCnMsgAnnex) + SizeOf(Integer) + 1;

    EnterCriticalSection(CSMsgStore);
    try
      AddADescToStore(ADesc);
    finally
      LeaveCriticalSection(CSMsgStore);
    end;

    // 更新界面
    if (Application.MainForm <> nil) and not (csDestroying in Application.MainForm.ComponentState) then
      PostMessage(Application.MainForm.Handle, WM_USER_UPDATE_STORE, 0, 0);
  end;
end;

end.
