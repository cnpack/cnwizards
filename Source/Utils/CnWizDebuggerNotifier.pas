{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnWizDebuggerNotifier;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE Debugger 通知服务单元
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：该单元提供了 IDE Debugger 通知事件服务。
*           Debugger 系列通知服务因为结构的复杂性，特写成独立单元中的独立服务接口
*           目标线程求值返回值说明：如果是对象，则其地址在 ResultAddr 中，([csInheritable]) 之类的放入 ResultStr
*           如果是字符串值或数值，则内容已被转换成字符串存放在传入的 ResultStr 缓冲区中
*           如果表达式出错，则 ResultAddr 会被赋值成 -1, ResultStr 赋值为 Inaccessable...
* 开发平台：PWin2000Pro + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2024.01.09
*               简化求值方法并封装在一个全局接口中
*           2013.06.03
*               增加获取当前断点信息的方法
*           2006.11.10
*               增加 Evaluate 的相关求值方法
*           2006.10.06
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, ToolsAPI, AppEvnts,
  Contnrs, Consts, CnWizUtils, CnClasses;

type
  TCnAvailableState = (asAvailable, asProcRunning, asOutOfScope, asNotAvailable);
  {* 求值时的目标状态}

  TCnProcessNotifyReason = (cprCreated, cprDestroyed);
  {* 进程通知的类型，自定义}

  TCnThreadNotifyReason = (ctrOther, ctrRunning, ctrStopped, ctrException,
    ctrFault, ctrCreated, ctrDestroyed);
  {* 线程通知的类型，较 TOTANotifyReason 多了自定义的后两项}

  TCnBreakpointNotifyReason = (cbrAdded, cbrDeleted);
  {* 断点通知的类型，自定义}

  TCnProcessNotifier = procedure (Process: IOTAProcess;
    Reason: TCnProcessNotifyReason) of object;
  {* 进程通知器事件原型}

  TCnThreadNotifier = procedure (Process: IOTAProcess; Thread: IOTAThread;
    Reason: TCnThreadNotifyReason) of object;
  {* 线程通知器事件原型}

  TCnBreakpointNotifier = procedure (Breakpoint: IOTABreakpoint;
    Reason: TCnBreakpointNotifyReason) of object;
  {* 断点通知器事件原型}

  ICnWizDebuggerNotifierServices = interface(IUnknown)
  {* IDE Debugger 通知服务接口}
    ['{DB7A86E5-71AB-4095-B34E-F4C1985F703C}']
    procedure AddProcessNotifier(Notify: TCnProcessNotifier);
    {* 增加一个被调试进程的通知事件}
    procedure RemoveProcessNotifier(Notify: TCnProcessNotifier);
    {* 删除一个被调试进程的通知事件}
    procedure AddThreadNotifier(Notify: TCnThreadNotifier);
    {* 增加一个被调试线程的通知事件}
    procedure RemoveThreadNotifier(Notify: TCnThreadNotifier);
    {* 删除一个被调试线程的通知事件}
    procedure AddBreakpointNotifier(Notify: TCnBreakpointNotifier);
    {* 增加一个断点的通知事件}
    procedure RemoveBreakpointNotifier(Notify: TCnBreakpointNotifier);
    {* 删除一个断点通知事件}

    procedure RetrieveBreakpoints(Results: TList; const FileName: string = '');
    {* 获取指定文件中的全部断点列表，如文件名未指定，则当前所有断点列表
       注意 List 中容纳的是 TCnBreakpointDescriptor 实例，内部管理，外部不可释放}
  end;

  TCnBreakpointDescriptor = class(TPersistent)
  {* 用于本 Service 中保存断点的基本信息}
  private
    FEnabled: Boolean;
    FLineNumber: Integer;
    FFileName: string;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}

    property FileName: string read FFileName write FFileName;
    property Enabled: Boolean read FEnabled write FEnabled;
    property LineNumber: Integer read FLineNumber write FLineNumber;
  end;

{$IFDEF SUPPORT_32_AND_64}
  TCnOTAAddress = UInt64;
{$ELSE}
  TCnOTAAddress = Cardinal;
{$ENDIF}
  PCnOTAAddress = ^TCnOTAAddress;

  ICnEvaluationManager = interface
  {* 负责当前被调试进程当前目标线程内求值的类}
    function EvaluateExpression(const Expr: string): string; overload;
    {* 直接求简单表达式的值，返回字符串结果}
    function EvaluateExpression(const Expr: string; ObjectAddr: PCnOTAAddress): string; overload;
    {* 直接求表达式的值，返回字符串结果；如果是对象，则在 ObjectAddr 中返回其地址}
  end;

function CnWizDebuggerNotifierServices: ICnWizDebuggerNotifierServices;
{* 获取 IDE Debugger 通知服务接口}

function CnEvaluationManager: ICnEvaluationManager;
{* 获取当前被调试进程当前线程求值实例
  注：该实例求值时因内部处理消息，有可能造成调用者释放资源，返回后会出 IntfCopy 的访问冲突}

implementation

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF}CnWizNotifier;

type
  TCnEvaluationManager = class(TNotifierObject, ICnEvaluationManager, IOTAThreadNotifier
    {$IFDEF SUPPORT_32_AND_64}, IOTAThreadNotifier160 {$ENDIF})
  {* 能够在当前调试进程的当前调试线程中求表达式值的类}
  private
    FNotifierIndex: Integer;
    FEvalCompleted: Boolean;
    FDeferredResult: string;
    FDeferredError: Boolean;
    FResultAddress: TCnOTAAddress;
  public
    // IOTAThreadNotifier
    procedure ThreadNotify(Reason: TOTANotifyReason);
    procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);

{$IFDEF DELPHI104_SYDNEY_UP}  // The typo is fixed in D104S
    procedure EvaluateComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer); overload;
{$ELSE}
    procedure EvaluteComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
{$ENDIF}

{$IFDEF SUPPORT_32_AND_64}
    // IOTAThreadNotifier160，因为 XE2 及以后版本支持 64 位目标进程，因而 ResultAddress 得是 64 位
    procedure EvaluateComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress: TOTAAddress; ResultSize: LongWord; ReturnCode: Integer); {$IFDEF DELPHI104_SYDNEY_UP} overload; {$ENDIF}
{$ENDIF}

    function EvaluateExpression(const Expr: string): string; overload;
    function EvaluateExpression(const Expression: string; ObjectAddr: PCnOTAAddress): string; overload;
  end;

  TCnOTAProcess = class;
  TCnOTAThread = class;
  TCnWizDebuggerNotifierServices = class;

  TCnOTAProcessNotifier = class(TNotifierObject, IOTAProcessNotifier)
  {* 实现被调试进程通知器的私有类}
  private
    FDebuggerNotifierServices: TCnWizDebuggerNotifierServices;

    FProcess: TCnOTAProcess;
    FProcessIntf: IOTAProcess;
  public
    constructor Create(AProcess: TCnOTAProcess);
    destructor Destroy; override;

    procedure ThreadCreated({$IFDEF BDS} const {$ENDIF} Thread: IOTAThread);
    procedure ThreadDestroyed({$IFDEF BDS} const {$ENDIF}Thread: IOTAThread);
    procedure ProcessModuleCreated({$IFDEF BDS} const {$ENDIF}ProcessModule: IOTAProcessModule);
    procedure ProcessModuleDestroyed({$IFDEF BDS} const {$ENDIF}ProcessModule: IOTAProcessModule);
  end;

  TCnOTAThreadNotifier = class(TNotifierObject, IOTAThreadNotifier)
  {* 实现被调试线程通知器的私有类}
  private
    FDebuggerNotifierServices: TCnWizDebuggerNotifierServices;

    FThread: TCnOTAThread;
    FThreadIntf: IOTAThread;
    FProcess: TCnOTAProcess;
    FProcessIntf: IOTAProcess;
  public
    constructor Create(AThread: TCnOTAThread);
    destructor Destroy; override;

    procedure ThreadNotify(Reason: TOTANotifyReason);
{$IFDEF DELPHI104_SYDNEY_UP}  // The typo is fixed in D104S
    procedure EvaluateComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
{$ELSE}
    procedure EvaluteComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
{$ENDIF}
    procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);
  end;

  TCnOTAProcess = class(TObject)
  {* 描述一被调试进程的私有类，内可含多个线程}
  private
    FDebuggerNotifierServices: TCnWizDebuggerNotifierServices;

    FProcess: IOTAProcess;
    FProcessNotifierIndex: Integer;
    FProcessNotifier: TCnOTAProcessNotifier;
    FThreads: TList; // Contains TCnOTAThread
  public
    constructor Create(Process: IOTAProcess;
      ADebuggerNotifierServices: TCnWizDebuggerNotifierServices);
    destructor Destroy; override;

    procedure AddThread(Thread: IOTAThread);
    procedure RemoveThread(Thread: IOTAThread);

    property Process: IOTAProcess read FProcess write FProcess;
    property ProcessNotifierIndex: Integer read FProcessNotifierIndex;
  end;

  TCnOTAThread = class(TObject)
  {* 描述一被调试线程的私有类}
  private
    FDebuggerNotifierServices: TCnWizDebuggerNotifierServices;
    FProcess: TCnOTAProcess;

    FThread: IOTAThread;
    FThreadNotifierIndex: Integer;
    FThreadNotifier: TCnOTAThreadNotifier;

  public
    constructor Create(AProcess: TCnOTAProcess; Thread: IOTAThread;
      ADebuggerNotifierServices: TCnWizDebuggerNotifierServices);
    destructor Destroy; override;

    property Process: TCnOTAProcess read FProcess;
    property Thread: IOTAThread read FThread;
    property ThreadNotifierIndex: Integer read FThreadNotifierIndex;
  end;

  TCnWizDebuggerNotifierServices = class(TSingletonInterfacedObject,
    ICnWizDebuggerNotifierServices)
  {* 实现 IDE 的 Debugger 事件通知服务接口的私有类}
  private
    FProcesses: TList;         // Contains TCnOTAProcess
    FBreakpoints: TObjectList; // Contains Breakpoints
    FThreadNotifiers: TList;
    FProcessNotifiers: TList;
    FBreakpointNotifiers: TList;

    function IndexOf(List: TList; Notifier: TMethod): Integer;
    procedure AddNotifier(List: TList; Notifier: TMethod);
    procedure RemoveNotifier(List: TList; Notifier: TMethod);
    procedure ClearAndFreeList(var List: TList);

    procedure AddBreakpointDescriptor(const FileName: string; LineNumber: Integer;
      Enabled: Boolean);
    function FindBreakpointDescriptor(const FileName: string; LineNumber: Integer): TCnBreakpointDescriptor;
    procedure RemoveBreakpointDescriptor(const FileName: string; LineNumber: Integer);
  protected
    // 注册到 ICnWizNotifierService 的被通知器
    procedure ProcessCreated(Process: IOTAProcess);
    procedure ProcessDestroyed(Process: IOTAProcess);
    procedure BreakpointAdded(Breakpoint: IOTABreakpoint);
    procedure BreakpointDeleted(Breakpoint: IOTABreakpoint);

    // 被各个通知器汇总调用的线程事件通知
    procedure ThreadNotify(Process: IOTAProcess; Thread: IOTAThread;
      Reason: TCnThreadNotifyReason);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddThreadNotifier(Notify: TCnThreadNotifier);
    procedure RemoveThreadNotifier(Notify: TCnThreadNotifier);
    procedure AddProcessNotifier(Notify: TCnProcessNotifier);
    procedure RemoveProcessNotifier(Notify: TCnProcessNotifier);
    procedure AddBreakpointNotifier(Notify: TCnBreakpointNotifier);
    procedure RemoveBreakpointNotifier(Notify: TCnBreakpointNotifier);

    procedure RetrieveBreakpoints(Results: TList; const FileName: string = '');
  end;

var
  FCnWizDebuggerNotifierServices: TCnWizDebuggerNotifierServices = nil;
  FEvaluationManager: ICnEvaluationManager = nil;

function CnEvaluationManager: ICnEvaluationManager;
begin
  if FEvaluationManager = nil then
    FEvaluationManager := TCnEvaluationManager.Create;
  Result := FEvaluationManager;
end;

// 去掉 PChar 字符串中两头的单引号引用
procedure CropQuota(Str: PChar);
var
  Len, I: Integer;
  // Idx: PChar;
begin
  if Str <> nil then
  begin
    // PChar 的下标从 0 开始，不同于 string 的从 1 开始
    Len := StrLen(Str);
    if (Str[0] = '''') and (Str[Len - 1] = '''') then // 得两头都是引号才行
    begin
      Str[Len - 1] := #0; // 去掉末尾的单引号
      Dec(Len);

      if Str[0] = '''' then  // 移动，去掉头的单引号
      begin
        Dec(Len);
        for I := 0 to Len - 1 do
          Str[I] := Str[I + 1];
        Str[Len] := #0;
      end;
    end;

{   Idx := StrPos(Str, '''''');
    while Idx <> nil do
    begin
      Len := StrLen(Idx);
      for I := 0 to Len - 1 do
        Idx[I] := Idx[I + 1];
      Idx[Len] := #0;

      Idx := StrPos(Str, '''''');

    end; }
    // 无需找俩连续的单引号再移动以挤掉一个，因为 IDE 不会将单个引号换成两个
  end;
end;

// 获取 IDE Debugger 通知服务接口
function CnWizDebuggerNotifierServices: ICnWizDebuggerNotifierServices;
begin
  if not Assigned(FCnWizDebuggerNotifierServices) then
    FCnWizDebuggerNotifierServices := TCnWizDebuggerNotifierServices.Create;
  Result := FCnWizDebuggerNotifierServices as ICnWizDebuggerNotifierServices;
end;

{ TCnWizDebuggerNotifierServices }

constructor TCnWizDebuggerNotifierServices.Create;
begin
  inherited;
  FProcesses := TList.Create;
  FProcessNotifiers := TList.Create;
  FThreadNotifiers := TList.Create;
  FBreakpointNotifiers := TList.Create;

  FBreakpoints := TObjectList.Create(True);

  CnWizNotifierServices.AddProcessCreatedNotifier(ProcessCreated);
  CnWizNotifierServices.AddProcessDestroyedNotifier(ProcessDestroyed);
  CnWizNotifierServices.AddBreakpointAddedNotifier(BreakpointAdded);
  CnWizNotifierServices.AddBreakpointDeletedNotifier(BreakpointDeleted);
end;

destructor TCnWizDebuggerNotifierServices.Destroy;
var
  I: Integer;
begin
  for I := FProcesses.Count - 1 downto 0 do
    if FProcesses[I] <> nil then
      TCnOTAProcess(FProcesses[I]).Free;

  FProcesses.Free;
  FBreakpoints.Free;
  ClearAndFreeList(FThreadNotifiers);
  ClearAndFreeList(FProcessNotifiers);
  ClearAndFreeList(FBreakpointNotifiers);

  CnWizNotifierServices.RemoveProcessCreatedNotifier(ProcessCreated);
  CnWizNotifierServices.RemoveProcessDestroyedNotifier(ProcessDestroyed);
  CnWizNotifierServices.RemoveBreakpointAddedNotifier(BreakpointAdded);
  CnWizNotifierServices.RemoveBreakpointDeletedNotifier(BreakpointDeleted);
  inherited;
end;

procedure TCnWizDebuggerNotifierServices.ProcessCreated(
  Process: IOTAProcess);
var
  AProcess: TCnOTAProcess;
  I: Integer;
begin
  AProcess := TCnOTAProcess.Create(Process, Self);
  AProcess.FProcess := Process;
  AProcess.FProcessNotifier.FProcessIntf := Process;
  AProcess.FProcessNotifierIndex := Process.AddNotifier(AProcess.FProcessNotifier as IOTAProcessNotifier);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnWizDebuggerNotifierServices ProcessCreated Called %d %d', [Integer(AProcess.FProcessNotifier), AProcess.FProcessNotifierIndex ]);
{$ENDIF DEBUG}
  FProcesses.Add(AProcess);

  if FProcessNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices ProcessNotified, Reason Created.');
{$ENDIF DEBUG}
    for I := FProcessNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FProcessNotifiers[I])^ do
        TCnProcessNotifier(Notifier)(Process, cprCreated);
    except
      DoHandleException('TCnWizDebuggerNotifierServices.ProcessNotified[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.ProcessDestroyed(
  Process: IOTAProcess);
var
  I: Integer;
begin
  for I := FProcesses.Count - 1 downto 0 do
  begin
    if TCnOTAProcess(FProcesses[I]).FProcess = Process then
    begin
      Process.RemoveNotifier(TCnOTAProcess(FProcesses[I]).FProcessNotifierIndex);
      TCnOTAProcess(FProcesses[I]).FProcessNotifierIndex := -1;
      TCnOTAProcess(FProcesses[I]).Free;
      FProcesses.Delete(I);
      Break;
    end;
  end;

  if FProcessNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices ProcessNotified, Reason Destroyed.');
{$ENDIF DEBUG}
    for I := FProcessNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FProcessNotifiers[I])^ do
        TCnProcessNotifier(Notifier)(Process, cprDestroyed);
    except
      DoHandleException('TCnWizDebuggerNotifierServices.ProcessNotified[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.BreakpointAdded(
  Breakpoint: IOTABreakpoint);
var
  I: Integer;
begin
  if FBreakpointNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices BreakpointNotified, Reason Added.');
{$ENDIF DEBUG}
    AddBreakpointDescriptor(Breakpoint.FileName, Breakpoint.LineNumber, Breakpoint.Enabled);

    for I := FBreakpointNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FBreakpointNotifiers[I])^ do
        TCnBreakpointNotifier(Notifier)(Breakpoint, cbrAdded);
    except
      DoHandleException('TCnWizDebuggerNotifierServices.BreakpointNotified[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.BreakpointDeleted(
  Breakpoint: IOTABreakpoint);
var
  I: Integer;
begin
  if FBreakpointNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices BreakpointNotified, Reason Deleted.');
{$ENDIF DEBUG}
    RemoveBreakpointDescriptor(Breakpoint.FileName, Breakpoint.LineNumber);

    for I := FBreakpointNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FBreakpointNotifiers[I])^ do
        TCnBreakpointNotifier(Notifier)(Breakpoint, cbrDeleted);
    except
      DoHandleException('TCnWizDebuggerNotifierServices.BreakpointNotified[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.AddNotifier(List: TList;
  Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
begin
  if IndexOf(List, Notifier) < 0 then
  begin
    New(Rec);
    Rec^.Notifier := TMethod(Notifier);
    List.Add(Rec);
  end;
end;

procedure TCnWizDebuggerNotifierServices.RemoveNotifier(List: TList;
  Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
  Idx: Integer;
begin
  Idx := IndexOf(List, Notifier);
  if Idx >= 0 then
  begin
    Rec := List[Idx];
    Dispose(Rec);
    List.Delete(Idx);
  end;
end;

procedure TCnWizDebuggerNotifierServices.ThreadNotify(Process: IOTAProcess;
  Thread: IOTAThread; Reason: TCnThreadNotifyReason);
var
  I: Integer;
begin
  if FThreadNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices ThreadNotified, Reason ' + IntToStr(Ord(Reason)));
{$ENDIF DEBUG}
    for I := FThreadNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FThreadNotifiers[I])^ do
        TCnThreadNotifier(Notifier)(Process, Thread, Reason);
    except
      DoHandleException('TCnWizDebuggerNotifierServices.ThreadNotify[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.ClearAndFreeList(var List: TList);
var
  Rec: PCnWizNotifierRecord;
begin
  while List.Count > 0 do
  begin
    Rec := List[0];
    Dispose(Rec);
    List.Delete(0);
  end;
  FreeAndNil(List);
end;

function TCnWizDebuggerNotifierServices.IndexOf(List: TList;
  Notifier: TMethod): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to List.Count - 1 do
    if CompareMem(List[I], @Notifier, SizeOf(TMethod)) then
    begin
      Result := I;
      Exit;
    end;
end;

procedure TCnWizDebuggerNotifierServices.AddProcessNotifier(
  Notify: TCnProcessNotifier);
begin
  AddNotifier(FProcessNotifiers, TMethod(Notify));
end;

procedure TCnWizDebuggerNotifierServices.RemoveProcessNotifier(
  Notify: TCnProcessNotifier);
begin
  RemoveNotifier(FProcessNotifiers, TMethod(Notify));
end;

procedure TCnWizDebuggerNotifierServices.AddThreadNotifier(
  Notify: TCnThreadNotifier);
begin
  AddNotifier(FThreadNotifiers, TMethod(Notify));
end;

procedure TCnWizDebuggerNotifierServices.RemoveThreadNotifier(
  Notify: TCnThreadNotifier);
begin
  RemoveNotifier(FThreadNotifiers, TMethod(Notify));
end;

procedure TCnWizDebuggerNotifierServices.AddBreakpointNotifier(
  Notify: TCnBreakpointNotifier);
begin
  AddNotifier(FBreakpointNotifiers, TMethod(Notify));
end;

procedure TCnWizDebuggerNotifierServices.RemoveBreakpointNotifier(
  Notify: TCnBreakpointNotifier);
begin
  RemoveNotifier(FBreakpointNotifiers, TMethod(Notify));
end;

function TCnWizDebuggerNotifierServices.FindBreakpointDescriptor(
  const FileName: string; LineNumber: Integer): TCnBreakpointDescriptor;
var
  I: Integer;
  B: TCnBreakpointDescriptor;
begin
  Result := nil;
  for I := 0 to FBreakpoints.Count - 1 do
  begin
    B := TCnBreakpointDescriptor(FBreakpoints[I]);
    if (B <> nil) and (B.FileName = FileName) and (B.LineNumber = LineNumber) then
    begin
      Result := B;
      Exit;
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.RemoveBreakpointDescriptor(
  const FileName: string; LineNumber: Integer);
var
  I: Integer;
  B: TCnBreakpointDescriptor;
begin
  for I := FBreakpoints.Count - 1 downto 0 do
  begin
    B := TCnBreakpointDescriptor(FBreakpoints[I]);
    if (B <> nil) and (B.FileName = FileName) and (B.LineNumber = LineNumber) then
    begin
      FBreakpoints.Delete(I);
      Exit;
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.AddBreakpointDescriptor(
  const FileName: string; LineNumber: Integer; Enabled: Boolean);
var
  B: TCnBreakpointDescriptor;
begin
  B := FindBreakpointDescriptor(FileName, LineNumber);
  if B <> nil then
    B.Enabled := Enabled
  else
  begin
    B := TCnBreakpointDescriptor.Create;
    B.Enabled := Enabled;
    B.FileName := FileName;
    B.LineNumber := LineNumber;
    FBreakpoints.Add(B);
  end;
end;

procedure TCnWizDebuggerNotifierServices.RetrieveBreakpoints(
  Results: TList; const FileName: string);
var
  I: Integer;
begin
  if Results = nil then
    Exit;

  Results.Clear;
  for I := 0 to FBreakpoints.Count - 1 do
  begin
    if (FileName = '') or (TCnBreakpointDescriptor(FBreakpoints[I]).FileName = FileName) then
      Results.Add(FBreakpoints[I]);
  end;
end;

{ TCnOTAProcess }

procedure TCnOTAProcess.AddThread(Thread: IOTAThread);
var
  AThread: TCnOTAThread;
begin
  AThread := TCnOTAThread.Create(Self, Thread, FDebuggerNotifierServices);
  AThread.FThreadNotifierIndex := Thread.AddNotifier(AThread.FThreadNotifier as IOTAThreadNotifier);
  FThreads.Add(AThread);
end;

constructor TCnOTAProcess.Create(Process: IOTAProcess;
  ADebuggerNotifierServices: TCnWizDebuggerNotifierServices);
begin
  inherited Create;
  FDebuggerNotifierServices := ADebuggerNotifierServices;
  FThreads := TList.Create;
  FProcess := Process;
  FProcessNotifier := TCnOTAProcessNotifier.Create(Self);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAProcess.Created.');
{$ENDIF DEBUG}
end;

destructor TCnOTAProcess.Destroy;
var
  I: Integer;
begin
  if FProcessNotifierIndex >= 0 then
    FProcess.RemoveNotifier(FProcessNotifierIndex);

  for I := FThreads.Count - 1 downto 0 do
    if FThreads[I] <> nil then
      TCnOTAThread(FThreads[I]).Free;

  FThreads.Free;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAProcess.Destroyed.');
{$ENDIF DEBUG}
  inherited;
end;

procedure TCnOTAProcess.RemoveThread(Thread: IOTAThread);
var
  I: Integer;
begin
  for I := FThreads.Count - 1 downto 0 do
  begin
    if TCnOTAThread(FThreads[I]).Thread = Thread then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnOTAProcess.RemoveThread. ThreadNotifierIndex = '+ InttoStr(TCnOTAThread(FThreads[I]).FThreadNotifierIndex));
{$ENDIF DEBUG}
      Thread.RemoveNotifier(TCnOTAThread(FThreads[I]).FThreadNotifierIndex);
      // RemoveNotifier 会由于引用计数导致 FThreads[I] 的 ThreadNotifier 被释放
      TCnOTAThread(FThreads[I]).FThreadNotifierIndex := -1;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnOTAProcess.RemoveThread. To Free FThreads ' + InttoStr(I));
{$ENDIF DEBUG}
      TCnOTAThread(FThreads[I]).Free;
      FThreads.Delete(I);
      Break;
    end;
  end;
end;

{ TCnOTAProcessNotifier }

constructor TCnOTAProcessNotifier.Create(AProcess: TCnOTAProcess);
begin
  inherited Create;
  FProcess := AProcess;
  FProcessIntf := AProcess.Process;
  FDebuggerNotifierServices := AProcess.FDebuggerNotifierServices;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAProcessNotifier Created. Process Intf '+ InttoStr(Integer(FProcessIntf)));
{$ENDIF DEBUG}
  // 保证 Notifier 拿到层层下放的接口实例
end;

destructor TCnOTAProcessNotifier.Destroy;
begin
  FProcess := nil;
  FProcessIntf := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAProcessNotifier Destroyed.');
{$ENDIF DEBUG}
  inherited;
end;

procedure TCnOTAProcessNotifier.ProcessModuleCreated({$IFDEF BDS} const {$ENDIF}
  ProcessModule: IOTAProcessModule);
begin

end;

procedure TCnOTAProcessNotifier.ProcessModuleDestroyed({$IFDEF BDS} const {$ENDIF}
  ProcessModule: IOTAProcessModule);
begin

end;

procedure TCnOTAProcessNotifier.ThreadCreated({$IFDEF BDS} const {$ENDIF}Thread: IOTAThread);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnOTAProcessNotifier ThreadCreated. FProcess = %d', [Integer(FProcess)]);
{$ENDIF DEBUG}
  FProcess.AddThread(Thread);
  FDebuggerNotifierServices.ThreadNotify(FProcessIntf, Thread, ctrCreated);
end;

procedure TCnOTAProcessNotifier.ThreadDestroyed({$IFDEF BDS} const {$ENDIF}Thread: IOTAThread);
begin
  FDebuggerNotifierServices.ThreadNotify(FProcessIntf, Thread, ctrDestroyed);
  FProcess.RemoveThread(Thread);
end;

{ TCnOTAThread }

constructor TCnOTAThread.Create(AProcess: TCnOTAProcess; Thread: IOTAThread;
  ADebuggerNotifierServices: TCnWizDebuggerNotifierServices);
begin
  inherited Create;
  FProcess := AProcess;
  FDebuggerNotifierServices := ADebuggerNotifierServices;
  FThread := Thread;
  FThreadNotifier := TCnOTAThreadNotifier.Create(Self);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAThread Created.');
{$ENDIF DEBUG}
end;

destructor TCnOTAThread.Destroy;
begin
  if FThreadNotifierIndex >= 0 then
    FThread.RemoveNotifier(FThreadNotifierIndex);

  FThread := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAThread Destroyed.');
{$ENDIF DEBUG}
  inherited;
end;

{ TCnOTAThreadNotifier }

constructor TCnOTAThreadNotifier.Create(AThread: TCnOTAThread);
begin
  inherited Create;
  FThread := AThread;
  NoRefCount(FThreadIntf) := NoRefCount(AThread.Thread);
  FProcess := AThread.Process;
  NoRefCount(FProcessIntf) := NoRefCount(FProcess.Process);
  FDebuggerNotifierServices := AThread.FDebuggerNotifierServices;
  // 保证 Notifier 拿到层层下放的接口实例
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAThreadNotifier Created.');
{$ENDIF DEBUG}
end;

destructor TCnOTAThreadNotifier.Destroy;
begin
  NoRefCount(FThreadIntf) := nil;
  NoRefCount(FProcessIntf) := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAThreadNotifier Destroyed.');
{$ENDIF DEBUG}
  inherited;
end;

{$IFDEF DELPHI104_SYDNEY_UP}

procedure TCnOTAThreadNotifier.EvaluateComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress,
  ResultSize: LongWord; ReturnCode: Integer);
begin

end;

{$ELSE}

procedure TCnOTAThreadNotifier.EvaluteComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress,
  ResultSize: LongWord; ReturnCode: Integer);
begin

end;

{$ENDIF}

procedure TCnOTAThreadNotifier.ModifyComplete(const ExprStr,
  ResultStr: string; ReturnCode: Integer);
begin

end;

procedure TCnOTAThreadNotifier.ThreadNotify(Reason: TOTANotifyReason);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('Thread Notified. Reason. %d.', [Ord(Reason)]);
{$ENDIF DEBUG}
  FDebuggerNotifierServices.ThreadNotify(FProcessIntf, FThreadIntf, TCnThreadNotifyReason(Ord(Reason)));
end;

{ TCnBreakpointDescriptor }

procedure TCnBreakpointDescriptor.AssignTo(Dest: TPersistent);
begin
  if Dest is TCnBreakpointDescriptor then
  begin
    TCnBreakpointDescriptor(Dest).Enabled := FEnabled;
    TCnBreakpointDescriptor(Dest).FileName := FFileName;
    TCnBreakpointDescriptor(Dest).LineNumber := FLineNumber;
  end;
end;

function TCnBreakpointDescriptor.ToString: string;
begin
  Result := Format('Enabled %d. Line: %d. File: %s', [Integer(FEnabled), FLineNumber, FFileName]);
end;

{ TCnEvaluationManager }

function TCnEvaluationManager.EvaluateExpression(const Expr: string): string;
begin
  Result := EvaluateExpression(Expr, nil);
end;

function TCnEvaluationManager.EvaluateExpression(const Expression: string;
  ObjectAddr: PCnOTAAddress): string;
var
  CurProcess: IOTAProcess;
  CurThread: IOTAThread;
  ResultStr: array[0..4095] of Char;
  CanModify: Boolean;
  Done: Boolean;
  ResultAddr: TCnOTAAddress;
  ResultSize, ResultVal: LongWord;
  EvalRes: TOTAEvaluateResult;
  ID: IOTADebuggerServices;
begin
  begin
    Result := '';
    if Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
      CurProcess := ID.CurrentProcess;
    if CurProcess = nil then
      Exit;

    CurThread := CurProcess.CurrentThread;
    if CurThread = nil then
      Exit;

    repeat
      Done := True; // 按需调 64 位版本，且 2005 后参数有新改动
      EvalRes := CurThread.Evaluate(Expression, @ResultStr, Length(ResultStr),
        CanModify, {$IFDEF BDS} eseAll, {$ELSE} True, {$ENDIF} '', ResultAddr,
        ResultSize, ResultVal {$IFDEF BDS} , '', 0 {$ENDIF});

      case EvalRes of
        erOK: Result := ResultStr;
        erDeferred:
          begin
            FEvalCompleted := False;
            FDeferredResult := '';
            FDeferredError := False;
            FResultAddress := 0;

            FNotifierIndex := CurThread.AddNotifier(Self);

            while not FEvalCompleted do
            begin
{$IFDEF OTA_DEBUG_EVENTS}
              ID.ProcessDebugEvents;
{$ELSE}
              Application.ProcessMessages;
{$ENDIF}
            end;

            CurThread.RemoveNotifier(FNotifierIndex);
            FNotifierIndex := -1;

            if not FDeferredError then
            begin
              if FDeferredResult <> '' then
              begin
                Result := FDeferredResult;
                if ObjectAddr <> nil then
                  ObjectAddr^ := FResultAddress;
              end
              else
              begin
                Result := ResultStr;
                if ObjectAddr <> nil then
                  ObjectAddr^ := FResultAddress;
              end;
            end;
          end;
{$IFDEF OTA_DEBUG_ERBUSY}
        erBusy:
          begin
  {$IFDEF OTA_DEBUG_EVENTS}
              ID.ProcessDebugEvents;
  {$ELSE}
              Application.ProcessMessages;
  {$ENDIF}
            Done := False;
          end;
{$ENDIF}
      end;
    until Done;
  end;
end;

{$IFDEF DELPHI104_SYDNEY_UP}

procedure TCnEvaluationManager.EvaluateComplete(const ExprStr, ResultStr: string;
  CanModify: Boolean; ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
begin
  // 三块实现一样
  FEvalCompleted := True;
  FDeferredResult := ResultStr;
  FDeferredError := ReturnCode <> 0;
  FResultAddress := ResultAddress;
end;

{$ELSE}

procedure TCnEvaluationManager.EvaluteComplete(const ExprStr, ResultStr: string;
  CanModify: Boolean; ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
begin
  // 三块实现一样
  FEvalCompleted := True;
  FDeferredResult := ResultStr;
  FDeferredError := ReturnCode <> 0;
  FResultAddress := ResultAddress;
end;

{$ENDIF}

{$IFDEF SUPPORT_32_AND_64}

procedure TCnEvaluationManager.EvaluateComplete(const ExprStr, ResultStr: string;
  CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord; ReturnCode: Integer);
begin
  // 三块实现一样
  FEvalCompleted := True;
  FDeferredResult := ResultStr;
  FDeferredError := ReturnCode <> 0;
  FResultAddress := ResultAddress;
end;

{$ENDIF}

procedure TCnEvaluationManager.ModifyComplete(const ExprStr, ResultStr: string;
  ReturnCode: Integer);
begin

end;

procedure TCnEvaluationManager.ThreadNotify(Reason: TOTANotifyReason);
begin

end;

initialization

finalization
  if FCnWizDebuggerNotifierServices <> nil then
    FreeAndNil(FCnWizDebuggerNotifierServices);

  FEvaluationManager := nil;

end.
