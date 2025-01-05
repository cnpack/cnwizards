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

unit CnWizControlHook;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE 设计控件消息处理过程挂接单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元提供了 IDE 中设计期控件消息挂接服务。
* 开发平台：PWin2000Pro + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.05.04 V1.2
*               使用 CnWizNotifier 用正规的方法来挂接控件，去掉了 Listener 接口，
*               改用 Message Notifier 以简化编程。
*           2003.04.28 V1.1
*               修正控件在消息处理过程中释放导致挂接对象出错的问题
*           2002.11.22 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

// 因为容易与第三方控件冲突，决定取消这个单元了，暂时先保留着备份

{$IFNDEF USE_CONTROLHOOK}
implementation
{$ELSE}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, ToolsAPI,
  {$IFDEF COMPILER6_UP}
  DesignIntf,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  CnWizNotifier;

type

  TCnWizMessageNotifier = procedure (Control: TControl;
    var Msg: TMessage; var Handled: Boolean) of object;

  ICnWizControlServices = interface(IUnknown)
  {* 该接口提供了设计期控件消息挂接服务，通过注册消息通知器，就可以获得 IDE 中
     所有设计期控件的消息通知，另外它还提供了设计期窗体及窗体容器的其它服务。
     以下服务分为三类：设计期控件、设计对象（窗体、Frame、DataModule 及注册的
     其它第三方对象、设计对象的容器（存放设计期 Frame 的容器窗口等，如果设计对
     象是窗体则容器与设计窗体等效）}
    ['{416BB0D2-02EA-40A9-AA50-BBC81771E0AC}']
    function GetControlCount: Integer;
    function GetControls(Index: Integer): TControl;

    function GetDesignRootCount: Integer;
    function GetDesignRoots(Index: Integer): TComponent;
    function GetCurrentDesignRoot: TComponent;

    function GetDesignContainerCount: Integer;
    function GetDesignContainers(Index: Integer): TWinControl;
    function GetCurrentDesignContainer: TWinControl;

    function IndexOfControl(Control: TControl): Integer;
    {* 返回指定控件在列表中的索引号}
    
    function IndexOfDesignRoot(DesignRoot: TComponent): Integer;
    {* 返回指定设计对象在列表中的索引号}
    function IsDesignRoot(Component: TComponent): Boolean;
    {* 返回指定组件是否是设计对象（Form、Frame、Data Module等）}

    function IndexOfDesignContainer(DesignContainer: TWinControl): Integer;
    {* 返回指定设计对象容器在列表中的索引号}
    function IsDesignContainer(DesignContainer: TWinControl): Boolean;
    {* 返回指定组件是否是设计对象容器}

    procedure AddBeforeMessageNotifier(Notifier: TCnWizMessageNotifier);
    {* 增加一个控件前消息通知器}
    procedure RemoveBeforeMessageNotifier(Notifier: TCnWizMessageNotifier);
    {* 删除一个控件前消息通知器}
    procedure AddAfterMessageNotifier(Notifier: TCnWizMessageNotifier);
    {* 增加一个控件后消息通知器}
    procedure RemoveAfterMessageNotifier(Notifier: TCnWizMessageNotifier);
    {* 删除一个控件后消息通知器}

    property ControlCount: Integer read GetControlCount;
    {* 当前已挂接的控件总数}
    property Controls[Index: Integer]: TControl read GetControls;
    {* 当前已挂接的控件列表}
    
    property DesignRootCount: Integer read GetDesignRootCount;
    {* 当前有效的窗体、Frame、Data Module 及其它注册的第三方模块总数}
    property DesignRoots[Index: Integer]: TComponent read GetDesignRoots;
    {* 当前有效的窗体、Frame、Data Module 及其它注册的第三方模块列表}
    property CurrentDesignRoot: TComponent read GetCurrentDesignRoot;
    {* 当前正在设计的窗体、Frame、Data Module 及其它注册的第三方模块}

    property DesignContainerCount: Integer read GetDesignContainerCount;
    {* 当前有效的设计对象的容器窗口总数}
    property DesignContainers[Index: Integer]: TWinControl read GetDesignContainers;
    {* 当前有效的设计对象的容器窗口列表}
    property CurrentDesignContainer: TWinControl read GetCurrentDesignContainer;
    {* 当前正在设计对象的容器窗口}
  end;

function CnWizControlServices: ICnWizControlServices;

implementation

uses
{$IFDEF Debug}
  CnDebug,
{$ENDIF Debug}
  CnWizUtils;

type

  PCnWizNotifierRecord = ^TCnWizNotifierRecord;
  TCnWizNotifierRecord = record
    Notifier: TMethod;
  end;

  TControlHack = class(TControl);

//==============================================================================
// 控件消息处理过程挂接对象（私有类）
//==============================================================================

{ TCnWizHookObject }

  TCnWizControlServices = class;

  TCnWizHookObject = class
  private
    FControlServices: TCnWizControlServices;
    FControl: TControl;
    FOldWndProc: TWndMethod;
    FUpdateCount: Integer;
    FAutoFree: Boolean;
  protected
    procedure WndProc(var Message: TMessage);
    property Control: TControl read FControl;
    property ControlServices: TCnWizControlServices read FControlServices;
  public
    constructor Create(AControlServices: TCnWizControlServices; AControl: TControl);
    destructor Destroy; override;
    procedure DoFree;
    function Updating: Boolean;
  end;

//==============================================================================
// 控件消息处理过程挂接服务类（私有类）
//==============================================================================

{ TCnWizControlServices }

  TCnWizControlServices = class(TComponent, IUnknown, ICnWizControlServices)
  private
    FHookObjs: TList;
    FDesignRoots: TList;
    FDesignContainers: TList;
    FBeforeNotifiers: TList;
    FAfterNotifiers: TList;
    NotifierServices: ICnWizNotifierServices;
    procedure FormNotify(FormEditor: IOTAFormEditor;
      NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
      Component: TComponent; const OldName, NewName: string);
    procedure GetChildProc(Child: TComponent);
    procedure ClearList(List: TList);
    function IndexOf(List: TList; Notifier: TMethod): Integer;
    procedure AddNotifier(List: TList; Notifier: TMethod);
    procedure RemoveNotifier(List: TList; Notifier: TMethod);
    function GetDesignContainerFromEditor(FormEditor: IOTAFormEditor): TWinControl;
  protected
    // Overriden IUnknown implementations for singleton life-time management
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    // ICnWizControlServices
    function GetControlCount: Integer;
    function GetControls(Index: Integer): TControl;

    function GetDesignRootCount: Integer;
    function GetDesignRoots(Index: Integer): TComponent;
    function GetCurrentDesignRoot: TComponent;

    function GetDesignContainerCount: Integer;
    function GetDesignContainers(Index: Integer): TWinControl;
    function GetCurrentDesignContainer: TWinControl;

    function IndexOfControl(Control: TControl): Integer;

    function IndexOfDesignRoot(DesignRoot: TComponent): Integer;
    function IsDesignRoot(Component: TComponent): Boolean;

    function IndexOfDesignContainer(DesignContainer: TWinControl): Integer;
    function IsDesignContainer(DesignContainer: TWinControl): Boolean;

    procedure AddBeforeMessageNotifier(Notifier: TCnWizMessageNotifier);
    procedure RemoveBeforeMessageNotifier(Notifier: TCnWizMessageNotifier);
    procedure AddAfterMessageNotifier(Notifier: TCnWizMessageNotifier);
    procedure RemoveAfterMessageNotifier(Notifier: TCnWizMessageNotifier);

    // 挂接相关过程
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure HookEditor(Editor: IOTAFormEditor);
    procedure UnhookEditor(Editor: IOTAFormEditor);
    procedure HookControl(Control: TControl; IncludeChild: Boolean = True);
    procedure UnhookControl(Control: TControl); overload;
    procedure UnhookAll;
    procedure HookDesignRoot(DesignRoot: TComponent);

    function DoAfterMessage(Control: TControl; var Msg: TMessage): Boolean; dynamic;
    function DoBeforeMessage(Control: TControl; var Msg: TMessage): Boolean; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  FCnWizControlServices: TCnWizControlServices;

// 返回挂接管理器
function CnWizControlServices: ICnWizControlServices;
begin
  if not Assigned(FCnWizControlServices) then
    FCnWizControlServices := TCnWizControlServices.Create(nil);
  Result := FCnWizControlServices as ICnWizControlServices;
end;

procedure FreeCnWizControlServices;
begin
  if Assigned(FCnWizControlServices) then
    FreeAndNil(FCnWizControlServices);
end;

//==============================================================================
// 控件消息处理过程挂接对象（私有类）
//==============================================================================

{ TCnWizHookObject }

// 构造器
constructor TCnWizHookObject.Create(AControlServices: TCnWizControlServices;
  AControl: TControl);
begin
  inherited Create;
  Assert(Assigned(AControlServices) and Assigned(AControl));
  FControlServices := AControlServices;
  FControl := AControl;
  FOldWndProc := FControl.WindowProc;
  FControl.WindowProc := WndProc;
  FControl.FreeNotification(FControlServices);
  FUpdateCount := 0;
  FAutoFree := False;
{$IFDEF DEBUG}
  CnDebugger.LogFmt('Hook Control: %s: %s (%x, %x)', [AControl.Name, AControl.ClassName,
    Integer(TMethod(FOldWndProc).Code), Integer(TMethod(AControl.WindowProc).Code)]);
{$ENDIF}    
end;

// 析构器
destructor TCnWizHookObject.Destroy;
begin
  try                                  // 异常保护
    if Assigned(FControl) then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogFmt('Unhook Control: %s: %s (%x)', [FControl.Name,
        FControl.ClassName, Integer(TMethod(FControl.WindowProc).Code)]);
    {$ENDIF}
      FControl.RemoveFreeNotification(FControlServices);
      FControl.WindowProc := FOldWndProc;
      FControl := nil;
    end;
  except
    on E: Exception do
      DoHandleException('TCnWizHookObject.Destroy', E);
  end;
  inherited;
end;

// 当窗体用 Alt+F12 关闭时，窗体会在 WndProc 中完成释放操作，故此时供作一个标记
// 由 WndProc 来释放自身
procedure TCnWizHookObject.DoFree;
begin
  if Updating then
  begin
  {$IFDEF Debug}
    CnDebugger.LogMsg('Free hook object delay');
  {$ENDIF Debug}
    FAutoFree := True;
    try
    {$IFDEF DEBUG}
      CnDebugger.LogFmt('UnhookEx Control: %s: %s (%x)', [FControl.Name,
        FControl.ClassName, Integer(TMethod(FControl.WindowProc).Code)]);
    {$ENDIF}
      FControl.RemoveFreeNotification(FControlServices);
      FControl.WindowProc := FOldWndProc;
      FControl := nil;
    except
      on E: Exception do
        DoHandleException('TCnWizHookObject.DoFree', E);
    end;
  end
  else
    Free;
end;

function TCnWizHookObject.Updating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

// 新的消息处理过程
procedure TCnWizHookObject.WndProc(var Message: TMessage);
begin
  try
    Inc(FUpdateCount);
    try
      if FControlServices.DoBeforeMessage(FControl, Message) then Exit;
      if Assigned(FOldWndProc) then FOldWndProc(Message);
      // 在处理完原消息后，控件可能已经被释放掉了，在此处判断
      if not FAutoFree then
        FControlServices.DoAfterMessage(FControl, Message);
    finally
      Dec(FUpdateCount);
    end;

    // 此处进行释放
    if FAutoFree then
      Free;
  except
    on E: Exception do
      DoHandleException('TCnWizHookObject.WndProc', E);
  end;
end;

//==============================================================================
// 控件消息处理过程挂接组件（私有类）
//==============================================================================

{ TCnWizControlServices }

constructor TCnWizControlServices.Create(AOwner: TComponent);
begin
  inherited;
{$IFDEF Debug}
  CnDebugger.LogEnter('TCnWizControlServices.Create');
{$ENDIF Debug}
  FHookObjs := TList.Create;
  FDesignRoots := TList.Create;
  FDesignContainers := TList.Create;
  FBeforeNotifiers := TList.Create;
  FAfterNotifiers := TList.Create;
  NotifierServices := CnWizNotifierServices;
  NotifierServices.AddFormEditorNotifier(FormNotify);
{$IFDEF Debug}
  CnDebugger.LogLeave('TCnWizControlServices.Create');
{$ENDIF Debug}
end;

destructor TCnWizControlServices.Destroy;
begin
{$IFDEF Debug}
  CnDebugger.LogEnter('TCnWizControlServices.Destroy');
{$ENDIF Debug}
  NotifierServices.RemoveFormEditorNotifier(FormNotify);
  UnhookAll;
  ClearList(FBeforeNotifiers);
  ClearList(FAfterNotifiers);
  FBeforeNotifiers.Free;
  FAfterNotifiers.Free;
  FDesignContainers.Free;
  FDesignRoots.Free;
  FHookObjs.Free;
{$IFDEF Debug}
  CnDebugger.LogLeave('TCnWizControlServices.Destroy');
{$ENDIF Debug}
  inherited;
end;

//------------------------------------------------------------------------------
// 挂接相关方法
//------------------------------------------------------------------------------

procedure TCnWizControlServices.FormNotify(FormEditor: IOTAFormEditor;
  NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
  Component: TComponent; const OldName, NewName: string);
begin
  case NotifyType of
    fetOpened: HookEditor(FormEditor);
    fetClosing: UnhookEditor(FormEditor);
    fetComponentCreated:
      if Component is TControl then
        HookControl(TControl(Component));
  end;
end;

procedure TCnWizControlServices.HookDesignRoot(DesignRoot: TComponent);
var
  I: Integer;
begin
  if not Assigned(DesignRoot) then Exit;

  // 挂接设计期 Root 组件
  if DesignRoot is TControl then
    HookControl(TControl(DesignRoot), False);

  // 挂接其子组件
  for I := 0 to DesignRoot.ComponentCount - 1 do
    if DesignRoot.Components[I] is TControl then
      HookControl(TControl(DesignRoot.Components[I]));
end;

procedure TCnWizControlServices.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (AComponent is TControl) and (Operation = opRemove) then
    UnhookControl(TControl(AComponent)); // 控件释放时反挂接
end;

procedure TCnWizControlServices.GetChildProc(Child: TComponent);
begin
  if Child is TControl then
    HookControl(TControl(Child));
end;

procedure TCnWizControlServices.HookControl(Control: TControl; IncludeChild: Boolean);
var
  Obj: TCnWizHookObject;
begin
  if not Assigned(Control) then Exit;

  if IndexOfControl(Control) < 0 then
  begin
    Obj := TCnWizHookObject.Create(Self, Control);
    FHookObjs.Add(Obj);

    // 处理窗体上的 TFrame 或类似的第三方注册类
    if IncludeChild then
      TControlHack(Control).GetChildren(GetChildProc, Control);
  end;
end;

procedure TCnWizControlServices.UnhookControl(Control: TControl);
var
  Idx: Integer;
begin
  // 如果控件在 Hook 之后再次被其它代码 Hook，二次 Hook 的代码可能会保存
  // TCnWizHookObject 的 WndProc 方法。 如果在控件释放前先释放了 TCnWizHookObject
  // 对象，则可能导致二次 Hook 的代码调用到无效的 TCnWizHookObject 对象，导致异常。
  // 例如：TNT 系列控件与 CnWizards 的冲突。
  // 故只有在控件释放时才进行 Unhook，以避免前面的问题。
  if not Assigned(Control) or not (csDestroying in Control.ComponentState) then Exit;

  Idx := IndexOfControl(Control);
  if Idx >= 0 then
  begin
    TCnWizHookObject(FHookObjs[Idx]).DoFree;
    FHookObjs.Delete(Idx);
  end;
end;

procedure TCnWizControlServices.UnhookAll;
begin
  while FHookObjs.Count > 0 do
  begin
    TCnWizHookObject(FHookObjs[0]).DoFree;
    FHookObjs.Delete(0);
  end;
end;

procedure TCnWizControlServices.HookEditor(Editor: IOTAFormEditor);
var
  Component: TComponent;
  Container: TWinControl;
begin
  Component := CnOtaGetRootComponentFromEditor(Editor);
  if Assigned(Component) then
  begin
    FDesignRoots.Add(Component);

    Container := GetDesignContainerFromEditor(Editor);
    if Assigned(Container) then
    begin
      FDesignContainers.Add(Container);
      if Container <> Component then // Component 为 TFrame 时
        HookControl(Container, False);
    end;

    // 只挂接正在设计的窗体、Frame、及注册的第三方模块，不考虑 Data Module
    if Component is TWinControl then
    begin
    {$IFDEF Debug}
      CnDebugger.LogMsg('Hook Editor: ' + Editor.GetFileName);
    {$ENDIF Debug}
      HookDesignRoot(Component);
    end;
  end;
end;

procedure TCnWizControlServices.UnhookEditor(Editor: IOTAFormEditor);
var
  Component: TComponent;
  Container: TWinControl;
begin
  Component := CnOtaGetRootComponentFromEditor(Editor);
  if Assigned(Component) then
  begin
    FDesignRoots.Remove(Component);
    
    Container := GetDesignContainerFromEditor(Editor);
    if Assigned(Container) then
    begin
      FDesignContainers.Remove(Container);
    end;
  end;
end;

//------------------------------------------------------------------------------
// 列表操作
//------------------------------------------------------------------------------

procedure TCnWizControlServices.AddNotifier(List: TList;
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

procedure TCnWizControlServices.RemoveNotifier(List: TList;
  Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
  idx: Integer;
begin
  idx := IndexOf(List, Notifier);
  if idx >= 0 then
  begin
    Rec := List[idx];
    Dispose(Rec);
    List.Delete(idx);
  end;
end;

procedure TCnWizControlServices.ClearList(List: TList);
var
  Rec: PCnWizNotifierRecord;
begin
  while List.Count > 0 do
  begin
    Rec := List[0];
    Dispose(Rec);
    List.Delete(0);
  end;
end;

function TCnWizControlServices.IndexOf(List: TList;
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

procedure TCnWizControlServices.AddAfterMessageNotifier(
  Notifier: TCnWizMessageNotifier);
begin
  AddNotifier(FAfterNotifiers, TMethod(Notifier));
end;

procedure TCnWizControlServices.RemoveAfterMessageNotifier(
  Notifier: TCnWizMessageNotifier);
begin
  RemoveNotifier(FAfterNotifiers, TMethod(Notifier));
end;

procedure TCnWizControlServices.AddBeforeMessageNotifier(
  Notifier: TCnWizMessageNotifier);
begin
  AddNotifier(FBeforeNotifiers, TMethod(Notifier));
end;

procedure TCnWizControlServices.RemoveBeforeMessageNotifier(
  Notifier: TCnWizMessageNotifier);
begin
  RemoveNotifier(FBeforeNotifiers, TMethod(Notifier));
end;

//------------------------------------------------------------------------------
// 消息通知相关方法
//------------------------------------------------------------------------------

function TCnWizControlServices.DoAfterMessage(Control: TControl;
  var Msg: TMessage): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FAfterNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FAfterNotifiers[I])^ do
        TCnWizMessageNotifier(Notifier)(Control, Msg, Result);
    except
      on E: Exception do
        DoHandleException('TCnWizControlServices.DoAfterMessage[' + IntToStr(I) + ']', E);
    end;

    if Result then Exit;
  end;
end;

function TCnWizControlServices.DoBeforeMessage(Control: TControl;
  var Msg: TMessage): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FBeforeNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FBeforeNotifiers[I])^ do
        TCnWizMessageNotifier(Notifier)(Control, Msg, Result);
    except
      on E: Exception do
        DoHandleException('TCnWizControlServices.DoBeforeMessage[' + IntToStr(I) + ']', E);
    end;

    if Result then Exit;
  end;
end;

//------------------------------------------------------------------------------
// 辅助方法
//------------------------------------------------------------------------------

function TCnWizControlServices._AddRef: Integer;
begin
  Result := 1;
end;

function TCnWizControlServices._Release: Integer;
begin
  Result := 1;
end;

function TCnWizControlServices.GetDesignContainerFromEditor(
  FormEditor: IOTAFormEditor): TWinControl;
var
  Root: TComponent;
begin
  { TODO : 支持为 Root 非 TWinControl 的设计对象取其 Container }
  Result := nil;
  Root := CnOtaGetRootComponentFromEditor(FormEditor);
  if Root is TWinControl then
  begin
    Result := Root as TWinControl;
    while Assigned(Result) and Assigned(Result.Parent) do
      Result := Result.Parent;
  end;
end;

function TCnWizControlServices.IsDesignRoot(Component: TComponent): Boolean;
begin
  Result := FDesignRoots.IndexOf(Component) >= 0;
end;

function TCnWizControlServices.IsDesignContainer(
  DesignContainer: TWinControl): Boolean;
begin
  Result := FDesignContainers.IndexOf(DesignContainer) >= 0;
end;

function TCnWizControlServices.IndexOfControl(Control: TControl): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to GetControlCount - 1 do
    if Control = GetControls(I) then
    begin
      Result := I;
      Exit;
    end;
end;

function TCnWizControlServices.IndexOfDesignRoot(
  DesignRoot: TComponent): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to GetDesignRootCount - 1 do
    if DesignRoot = GetDesignRoots(I) then
    begin
      Result := I;
      Exit;
    end;
end;

function TCnWizControlServices.IndexOfDesignContainer(
  DesignContainer: TWinControl): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to GetDesignContainerCount - 1 do
    if DesignContainer = GetDesignContainers(I) then
    begin
      Result := I;
      Exit;
    end;
end;

function TCnWizControlServices.GetControlCount: Integer;
begin
  Result := FHookObjs.Count;
end;

function TCnWizControlServices.GetDesignRootCount: Integer;
begin
  Result := FDesignRoots.Count;
end;

function TCnWizControlServices.GetDesignContainerCount: Integer;
begin
  Result := FDesignContainers.Count;
end;

function TCnWizControlServices.GetControls(Index: Integer): TControl;
begin
  Result := TCnWizHookObject(FHookObjs[Index]).Control;
end;

function TCnWizControlServices.GetDesignRoots(Index: Integer): TComponent;
begin
  Result := TComponent(FDesignRoots[Index]);
end;

function TCnWizControlServices.GetDesignContainers(
  Index: Integer): TWinControl;
begin
   Result := TWinControl(FDesignContainers[Index]);
end;

function TCnWizControlServices.GetCurrentDesignRoot: TComponent;
begin
  Result := CnOtaGetRootComponentFromEditor(CnOtaGetCurrentFormEditor);
end;

function TCnWizControlServices.GetCurrentDesignContainer: TWinControl;
begin
  if CurrentIsForm then
    Result := GetDesignContainerFromEditor(CnOtaGetCurrentFormEditor)
  else
    Result := nil;
end;

initialization

finalization
{$IFDEF Debug}
  CnDebugger.LogEnter('CnWizControlHook finalization.');
{$ENDIF Debug}

  FreeCnWizControlServices;

{$IFDEF Debug}
  CnDebugger.LogLeave('CnWizControlHook finalization.');
{$ENDIF Debug}

{$ENDIF USE_CONTROLHOOK}
end.

