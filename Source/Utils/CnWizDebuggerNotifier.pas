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

unit CnWizDebuggerNotifier;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE Debugger 通知服务单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：该单元提供了 IDE Debugger 通知事件服务。
*           Debugger 系列通知服务因为结构的复杂性，特写成独立单元中的独立服务接口
*           目标线程求值返回值说明：如果是对象，则其地址在 ResultAddr 中，([csInheritable]) 之类的放入 ResultStr
*           如果是字符串值或数值，则内容已被转换成字符串存放在传入的 ResultStr 缓冲区中
*           如果表达式出错，则 ResultAddr 会被赋值成 -1, ResultStr 赋值为 Inaccessable...
* 开发平台：PWin2000Pro + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2024.03.09
*               重构求值类
*           2024.01.09
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
  Contnrs, Consts, CnWizUtils, CnClasses, CnNative;

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

  TCnRemoteProcessEvaluator = class(TCnSingletonInterfacedObject, IOTAThreadNotifier
    {$IFDEF SUPPORT_32_AND_64}, IOTAThreadNotifier160 {$ENDIF})
  {* 被调试进程的远程求值类，可按需实例化使用，也可用本单元的全局函数 CnInProcessEvaluator
    因内部有消息循环，所以使用 TCnSingletonInterfacedObject 为基类以尽量避免接口释放问题}
  private
    FNotifierIndex: Integer;
    FCompleted: Boolean;
    FDeferredResult: string;
    FDeferredError: Boolean;
    FResultAddress: TCnOTAAddress;
  protected
    { IOTAThreadNotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    procedure ThreadNotify(Reason: TOTANotifyReason);
{$IFDEF DELPHI104_SYDNEY_UP}  // The typo is fixed in D104S
    procedure EvaluateComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer); overload;
{$ELSE}
    procedure EvaluteComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
{$ENDIF}
    procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);

{$IFDEF SUPPORT_32_AND_64}
    { IOTAThreadNotifier160 }
    // 因为 XE2 及以后版本支持 64 位目标进程，因而 ResultAddress 得是 64 位
    procedure EvaluateComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress: TOTAAddress; ResultSize: LongWord; ReturnCode: Integer); overload;
{$ENDIF}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function CurrentProcessIs32: Boolean;
    {* 返回被调试进程是否 Win32 或 OSX 的 32 位，如果否，是 Win64 或其他平台的 64 位或者是不支持的 32 位}

    function EvaluateExpression(const Expression: string;
      ObjectAddr: PCnOTAAddress = nil): string;
    {* 求表达式的值，返回字符串结果；如果出错，则返回空字符串
       如果结果是对象，则返回 ([csInheritable]) 这种字符串，
       如果同时传入了 ObjectAddr 地址，则额外在 ObjectAddr 所指处返回该对象的远程地址}

    function ReadProcessMemory(Address: TCnOTAAddress; ByteCount: Integer; var Buffer): Integer;
    {* 读目标进程的内存地址，Address 为目标进程地址空间内的虚拟地址，
       ByteCount 为待读取字节数，Buffer 为存放空间，返回读取成功的字节数}
  end;

function CnWizDebuggerObjectInheritsFrom(const Obj, BaseClassName: string;
  Eval: TCnRemoteProcessEvaluator = nil; IsCpp: Boolean = False): Boolean;
{* 通过远程求值判断父类名称的方式，判断某对象名是否继承自指定父类
  允许外部传入求值工具实例，如果不传则内部创建并释放
  IsCpp 表示外部要求求值环境是 C/C++ 语言，影响内部表达式，默认 False}

function CnWizDebuggerNotifierServices: ICnWizDebuggerNotifierServices;
{* 获取 IDE Debugger 通知服务接口}

function CnRemoteProcessEvaluator: TCnRemoteProcessEvaluator;
{* 全局求值实例}

function CnWizGetBreakpointsByFile(const FileName: string; Breakpoints: TObjectList): Boolean;
{* 获取某源文件的断点信息，并创建 TCnBreakpointDescriptor 实例加入 Breakpoints 列表，返回是否成功获取有效断点}

implementation

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF} CnWizNotifier;

type
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

  TCnWizDebuggerNotifierServices = class(TCnSingletonInterfacedObject,
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
  FRemoteProcessEvaluator: TCnRemoteProcessEvaluator = nil;

function CnRemoteProcessEvaluator: TCnRemoteProcessEvaluator;
begin
  if FRemoteProcessEvaluator = nil then
    FRemoteProcessEvaluator := TCnRemoteProcessEvaluator.Create;
  Result := FRemoteProcessEvaluator;
end;

// 去掉字符串中两头的单引号引用
function CropDebugQuotaStr(const Str: string): string;
var
  L: Integer;
begin
  Result := Str;
  if Length(Str) <= 1 then
    Exit;

  L := Length(Result);
  if (Result[1] = '''') and (Result[L] = '''') then // 得两头都是引号才行
    Result := Copy(Result, 2, L - 2); // 去掉头尾的单引号

  // 无需找俩连续的单引号再移动以挤掉一个，因为 IDE 不会将单个引号换成两个
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
  begin
    if FProcesses[I] <> nil then
      TCnOTAProcess(FProcesses[I]).Free;
  end;

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
{$ENDIF}
  FProcesses.Add(AProcess);

  if FProcessNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices ProcessNotified, Reason Created.');
{$ENDIF}
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
{$ENDIF}
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
{$ENDIF}
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
{$ENDIF}
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
{$ENDIF}
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
  begin
    if CompareMem(List[I], @Notifier, SizeOf(TMethod)) then
    begin
      Result := I;
      Exit;
    end;
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
{$ENDIF}
end;

destructor TCnOTAProcess.Destroy;
var
  I: Integer;
begin
  if FProcessNotifierIndex >= 0 then
    FProcess.RemoveNotifier(FProcessNotifierIndex);

  for I := FThreads.Count - 1 downto 0 do
  begin
    if FThreads[I] <> nil then
      TCnOTAThread(FThreads[I]).Free;
  end;

  FThreads.Free;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAProcess.Destroyed.');
{$ENDIF}
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
{$ENDIF}
      Thread.RemoveNotifier(TCnOTAThread(FThreads[I]).FThreadNotifierIndex);
      // RemoveNotifier 会由于引用计数导致 FThreads[I] 的 ThreadNotifier 被释放
      TCnOTAThread(FThreads[I]).FThreadNotifierIndex := -1;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnOTAProcess.RemoveThread. To Free FThreads ' + InttoStr(I));
{$ENDIF}
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
  CnDebugger.LogMsg('TCnOTAProcessNotifier Created. Process Intf '+ InttoStr(TCnNativeInt(FProcessIntf)));
{$ENDIF}
  // 保证 Notifier 拿到层层下放的接口实例
end;

destructor TCnOTAProcessNotifier.Destroy;
begin
  FProcess := nil;
  FProcessIntf := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAProcessNotifier Destroyed.');
{$ENDIF}
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
{$ENDIF}
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
{$ENDIF}
end;

destructor TCnOTAThread.Destroy;
begin
  if FThreadNotifierIndex >= 0 then
    FThread.RemoveNotifier(FThreadNotifierIndex);

  FThread := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAThread Destroyed.');
{$ENDIF}
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
{$ENDIF}
end;

destructor TCnOTAThreadNotifier.Destroy;
begin
  NoRefCount(FThreadIntf) := nil;
  NoRefCount(FProcessIntf) := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAThreadNotifier Destroyed.');
{$ENDIF}
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
{$ENDIF}
  FDebuggerNotifierServices.ThreadNotify(FProcessIntf, FThreadIntf,
    TCnThreadNotifyReason(Ord(Reason)));
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
  Result := Format('Enabled %d. Line: %d. File: %s',
    [Integer(FEnabled), FLineNumber, FFileName]);
end;

{ TCnRemoteProcessEvaluator }

procedure TCnRemoteProcessEvaluator.AfterSave;
begin

end;

procedure TCnRemoteProcessEvaluator.BeforeSave;
begin

end;

constructor TCnRemoteProcessEvaluator.Create;
begin
  inherited;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnRemoteProcessEvaluator.Create');
{$ENDIF}
end;

destructor TCnRemoteProcessEvaluator.Destroy;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnRemoteProcessEvaluator.Destroy: ');
{$ENDIF}
  inherited;
end;

procedure TCnRemoteProcessEvaluator.Destroyed;
begin

end;

function TCnRemoteProcessEvaluator.EvaluateExpression(const Expression: string;
  ObjectAddr: PCnOTAAddress): string;
var
  CurProcess: IOTAProcess;
  CurThread: IOTAThread;
  ResultStr: array[0..4095] of Char;
  CanModify: Boolean;
  Done: Boolean;
  ResultAddr, ResultSize, ResultVal: LongWord;
  EvalRes: TOTAEvaluateResult;
  DebugSvcs: IOTADebuggerServices;

  function EvalResultToString(ER: TOTAEvaluateResult): string;
  begin
    case ER of
      erOK: Result := 'OK';
      erError: Result := 'Error';
      erDeferred: Result := 'Deferred';
{$IFDEF OTA_DEBUG_HAS_ERBUSY}
      erBusy: Result := 'Busy';
{$ENDIF}
    else
      Result := 'Error Result';
    end;
  end;

begin
  Result := '';
  if Supports(BorlandIDEServices, IOTADebuggerServices, DebugSvcs) then
    CurProcess := DebugSvcs.CurrentProcess;

  if CurProcess = nil then
    Exit;
  CurThread := CurProcess.CurrentThread;
  if CurThread = nil then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnRemoteProcessEvaluator.EvaluateExpression: ' + Expression);
{$ENDIF}

  repeat
    Done := True; // 按需调 64 位版本，且 2005 后参数有新改动
    EvalRes := CurThread.Evaluate(Expression, @ResultStr, Length(ResultStr),
      CanModify, {$IFDEF BDS} eseAll, {$ELSE} True, {$ENDIF} '', ResultAddr,
      ResultSize, ResultVal {$IFDEF BDS} , '', 0 {$ENDIF});

{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnRemoteProcessEvaluator.EvaluateExpression Res ' + EvalResultToString(EvalRes));
{$ENDIF}

    case EvalRes of
      erOK: Result := ResultStr;
      erError:
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('TCnRemoteProcessEvaluator.EvaluateExpression Error: ' + ResultStr);
{$ENDIF}
        end;
      erDeferred:
        begin
          FCompleted := False;
          FDeferredResult := '';
          FDeferredError := False;
          FResultAddress := 0;

          FNotifierIndex := CurThread.AddNotifier(Self);
          while not FCompleted do
          begin
{$IFDEF OTA_DEBUG_HAS_EVENTS}
            DebugSvcs.ProcessDebugEvents;
{$ELSE}
            Application.ProcessMessages;
{$ENDIF}
          end;
          CurThread.RemoveNotifier(FNotifierIndex);
          FNotifierIndex := -1;
          if not FDeferredError then
          begin
            if FDeferredResult <> '' then
              Result := FDeferredResult
            else
              Result := ResultStr;

            if ObjectAddr <> nil then
              ObjectAddr^ := FResultAddress;
          end;
        end;
{$IFDEF OTA_DEBUG_HAS_ERBUSY}
      erBusy:
        begin
{$IFDEF OTA_DEBUG_HAS_EVENTS}
          DebugSvcs.ProcessDebugEvents;
{$ELSE}
          Application.ProcessMessages;
{$ENDIF}
          Done := False;
        end;
{$ENDIF}
    end;
  until Done;
  Result := CropDebugQuotaStr(Result);
end;

{$IFDEF SUPPORT_32_AND_64}

procedure TCnRemoteProcessEvaluator.EvaluateComplete(const ExprStr, ResultStr: string;
  CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord;
  ReturnCode: Integer);
begin
  // 高版本的拼写正确的 32/64 位回调，手动结束
  FCompleted := True;
  FDeferredResult := ResultStr;
  FDeferredError := ReturnCode <> 0;
  FResultAddress := ResultAddress;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('High32/64 EvaluateComplete: ' + ResultStr);
{$ENDIF}
end;

{$ENDIF}

{$IFDEF DELPHI104_SYDNEY_UP}

procedure TCnRemoteProcessEvaluator.EvaluateComplete(const ExprStr, ResultStr: string;
  CanModify: Boolean; ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
begin
  // 高一点的版本的拼写正确的 32 位回调，调用拼写正确的 32/64 位版本
  EvaluateComplete(ExprStr, ResultStr, CanModify, TOTAAddress(ResultAddress), ResultSize, ReturnCode);
end;

{$ELSE}

procedure TCnRemoteProcessEvaluator.EvaluteComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress, ResultSize: LongWord;
  ReturnCode: Integer);
begin
{$IFDEF SUPPORT_32_AND_64}
  // 高一点的版本的拼写错误的 32 位回调，调用拼写正确的 32/64 位版本
  EvaluateComplete(ExprStr, ResultStr, CanModify, TOTAAddress(ResultAddress), ResultSize, ReturnCode);
{$ELSE}
  // 低版本的拼写错误的调用 32 位的回调，手动结束
  FCompleted := True;
  FDeferredResult := ResultStr;
  FDeferredError := ReturnCode <> 0;
  FResultAddress := ResultAddress;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Low32 Typo EvaluateComplete: ' + ResultStr);
{$ENDIF}
{$ENDIF}
end;

{$ENDIF}

procedure TCnRemoteProcessEvaluator.Modified;
begin

end;

procedure TCnRemoteProcessEvaluator.ModifyComplete(const ExprStr, ResultStr: string;
  ReturnCode: Integer);
begin

end;

procedure TCnRemoteProcessEvaluator.ThreadNotify(Reason: TOTANotifyReason);
begin

end;

function CnWizDebuggerObjectInheritsFrom(const Obj, BaseClassName: string;
  Eval: TCnRemoteProcessEvaluator; IsCpp: Boolean): Boolean;
var
  S: string;
begin
  Result := False;
  if (Obj = '') or (BaseClassName = '') then
    Exit;

  if Eval = nil then
    Eval := CnRemoteProcessEvaluator;

  if IsCpp then
    S := Eval.EvaluateExpression(Format('(%s)->InheritsFrom(__classid(%s))', [Obj, BaseClassName]))
  else
    S := Eval.EvaluateExpression(Format('(%s).InheritsFrom(%s)', [Obj, BaseClassName]));

  Result := LowerCase(S) = 'true';
end;

function TCnRemoteProcessEvaluator.ReadProcessMemory(Address: TCnOTAAddress;
  ByteCount: Integer; var Buffer): Integer;
var
  CurProcess: IOTAProcess;
  CurThread: IOTAThread;
  DebugSvcs: IOTADebuggerServices;
begin
  Result := 0;
  if ByteCount <= 0 then
    Exit;

  if Supports(BorlandIDEServices, IOTADebuggerServices, DebugSvcs) then
    CurProcess := DebugSvcs.CurrentProcess;

  if CurProcess = nil then
    Exit;
  CurThread := CurProcess.CurrentThread;
  if CurThread = nil then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogPointer(Pointer(Address), 'TCnRemoteProcessEvaluator.ReadProcessMemory: ');
{$ENDIF}

  Result := CurProcess.ReadProcessMemory(Address, ByteCount, Buffer);
end;

function TCnRemoteProcessEvaluator.CurrentProcessIs32: Boolean;
var
  CurProcess: IOTAProcess;
  DebugSvcs: IOTADebuggerServices;
begin
  Result := True;

  if Supports(BorlandIDEServices, IOTADebuggerServices, DebugSvcs) then
    CurProcess := DebugSvcs.CurrentProcess;

  if CurProcess = nil then
    Exit;

{$IFDEF SUPPORT_32_AND_64}
  Result := CurProcess.GetProcessType in [optWin32, optOSX32];
{$ELSE}
  Result := True;
{$ENDIF}
end;

function CnWizGetBreakpointsByFile(const FileName: string; Breakpoints: TObjectList): Boolean;
var
  DS: IOTADebuggerServices;
  SB: IOTASourceBreakpoint;
  BD: TCnBreakpointDescriptor;
  I: Integer;

  function CheckDuplicated(const AFileName: string; ALineNumber: Integer):
    TCnBreakpointDescriptor;
  var
    I: Integer;
    B: TCnBreakpointDescriptor;
  begin
    Result := nil;
    for I := 0 to Breakpoints.Count - 1 do
    begin
      B := TCnBreakpointDescriptor(Breakpoints[I]);
      if (B.FileName = AFileName) and (B.LineNumber = ALineNumber) then
      begin
        Result := B;
        Exit;
      end;
    end;
  end;

begin
  Result := False;
  Breakpoints.Clear;
  if BorlandIDEServices.QueryInterface(IOTADebuggerServices, DS) <> S_OK then
    Exit;

  for I := 0 to DS.SourceBkptCount - 1 do
  begin
    SB := DS.SourceBkpts[I];
    if (FileName = '') or (SB.FileName = FileName) then
    begin
      BD := CheckDuplicated(SB.FileName, SB.LineNumber);
      if BD <> nil then
        BD.Enabled := SB.Enabled
      else
      begin
        BD := TCnBreakpointDescriptor.Create;
        BD.FileName := SB.FileName;
        BD.LineNumber := SB.LineNumber;
        BD.Enabled := SB.Enabled;
        Breakpoints.Add(BD);
      end;
    end;
  end;
  Result := Breakpoints.Count > 0;
end;

initialization

finalization
  if FCnWizDebuggerNotifierServices <> nil then
    FreeAndNil(FCnWizDebuggerNotifierServices);
  if FRemoteProcessEvaluator <> nil then
    FreeAndNil(FRemoteProcessEvaluator);

end.
