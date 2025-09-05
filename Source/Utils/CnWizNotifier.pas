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

unit CnWizNotifier;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE 通知服务单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元提供了 IDE 通知事件服务。
* 开发平台：PWin2000Pro + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2025.04.09
*               GetMsgHook 允许拦截消息
*           2018.03.20
*               增加 IDE 主题切换通知机制
*           2008.05.05
*               增加 StopExecuteOnApplicationIdle 机制
*           2006.10.06
*               增加 Debug 进程和断点的事件通知服务
*           2005.05.06
*               hubdog 增加编译事件通知服务
*           2004.01.09
*               LiuXiao 修正 BCB 5 下打开单个 Unit 时的错误。
*           2003.09.29
*               增加 Application OnIdle、OnMessage 通知
*           2003.05.04
*               修正少量错误
*           2003.04.28
*               增加了窗体编辑器通知服务，增强代码编辑器通知功能
*           2002.11.22
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, ExtCtrls, Contnrs,
  {$IFNDEF FPC} AppEvnts, {$ENDIF} {$IFDEF LAZARUS} SrcEditorIntf, {$ENDIF}
  {$IFDEF DELPHI_OTA} Consts, ToolsAPI, {$ENDIF} CnWizUtils, CnClasses
  {$IFNDEF STAND_ALONE} {$IFNDEF CNWIZARDS_MINIMUM}, CnIDEVersion, CnIDEMirrorIntf {$ENDIF} {$ENDIF};
  
type
{$IFDEF FPC}
  TMessageEvent = procedure (var Msg: TMsg; var Handled: Boolean) of object;
{$ENDIF}

  PCnWizNotifierRecord = ^TCnWizNotifierRecord;
  TCnWizNotifierRecord = record
    Notifier: TMethod;
  end;

  NoRefCount = Pointer; // 使用指针类型来强制为接口变量赋值，不增加引用计数

  TCnWizSourceEditorNotifyType = (setOpened, setClosing, setModified,
    setEditViewInsert, setEditViewRemove, setEditViewActivated);
  {* SourceEditor 通知类型，Lazarus 下有改变与封装以映射保持一致}

  TCnWizSourceEditorNotifier = procedure (SourceEditor: TCnSourceEditorInterface;
    NotifyType: TCnWizSourceEditorNotifyType {$IFDEF DELPHI_OTA}; EditView: IOTAEditView {$ENDIF}) of object;
  {* SourceEditor 通知事件，SourceEditor 为源码编辑器接口，NotifyType 为类型}

{$IFDEF DELPHI_OTA}

  TCnWizFileNotifier = procedure (NotifyCode: TOTAFileNotification;
    const FileName: string) of object;
  {* IDE 文件通知事件，NotifyCode 为通知类型，FileName 为文件名}

  TCnWizFormEditorNotifyType = (fetOpened, fetClosing, fetModified,
    fetActivated, fetSaving, fetComponentCreating, fetComponentCreated,
    fetComponentDestorying, fetComponentRenamed, fetComponentSelectionChanged);

  TCnWizFormEditorNotifier = procedure (FormEditor: IOTAFormEditor;
    NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
    Component: TComponent; const OldName, NewName: string) of object;

  TCnWizBeforeCompileNotifier = procedure (const Project: IOTAProject;
    IsCodeInsight: Boolean; var Cancel: Boolean) of object;

  TCnWizAfterCompileNotifier = procedure (Succeeded: Boolean; IsCodeInsight:
    Boolean) of object;

  TCnWizProcessNotifier = procedure (Process: IOTAProcess) of object;

  TCnWizBreakpointNotifier = procedure (Breakpoint: IOTABreakpoint) of object;

{$ENDIF}

  TCnWizAppEventType = (aeActivate, aeDeactivate, aeMinimize, aeRestore, aeHint, aeShowHint);

  TCnWizAppEventNotifier = procedure (EventType: TCnWizAppEventType; Data: Pointer) of object;

  TCnWizMsgHookNotifier = procedure (hwnd: HWND; Control: TWinControl;
    Msg: TMessage) of object;

  TCnWizGetMsgHookNotifier = function (hwnd: HWND; Control: TWinControl;
    Msg: TMessage): Boolean of object;
  {* 针对 GetMsg 的 Hook 的处理通知，返回 True 表示吞掉此消息}

  ICnWizNotifierServices = interface(IUnknown)
  {* IDE 通知服务接口}
    ['{18C4DD6A-802A-48D7-AC93-A2487411CA79}']

{$IFDEF DELPHI_OTA}

    procedure AddFileNotifier(Notifier: TCnWizFileNotifier);
    {* 增加一个文件通知事件}
    procedure RemoveFileNotifier(Notifier: TCnWizFileNotifier);
    {* 删除一个文件通知事件}
    
    procedure AddBeforeCompileNotifier(Notifier:TCnWizBeforeCompileNotifier);
    {* 增加一个编译前通知事件}
    procedure RemoveBeforeCompileNotifier(Notifier:TCnWizBeforeCompileNotifier);
    {* 删除一个编译前通知事件}

    procedure AddAfterCompileNotifier(Notifier:TCnWizAfterCompileNotifier);
    {* 增加一个编译后通知事件}
    procedure RemoveAfterCompileNotifier(Notifier:TCnWizAfterCompileNotifier);
    {* 删除一个编译后通知事件}

    procedure AddFormEditorNotifier(Notifier: TCnWizFormEditorNotifier);
    {* 增加一个窗体编辑器通知事件}
    procedure RemoveFormEditorNotifier(Notifier: TCnWizFormEditorNotifier);
    {* 删除一个窗体编辑器通知事件}

    procedure AddProcessCreatedNotifier(Notifier: TCnWizProcessNotifier);
    {* 增加一个被调试进程启动的通知事件}
    procedure RemoveProcessCreatedNotifier(Notifier: TCnWizProcessNotifier);
    {* 删除一个被调试进程启动的通知事件}
    procedure AddProcessDestroyedNotifier(Notifier: TCnWizProcessNotifier);
    {* 增加一个被调试进程终止的通知事件}
    procedure RemoveProcessDestroyedNotifier(Notifier: TCnWizProcessNotifier);
    {* 删除一个被调试进程终止的通知事件}

    procedure AddBreakpointAddedNotifier(Notifier: TCnWizBreakpointNotifier);
    {* 增加一个增加断点的通知事件}
    procedure RemoveBreakpointAddedNotifier(Notifier: TCnWizBreakpointNotifier);
    {* 删除一个增加断点的通知事件}
    procedure AddBreakpointDeletedNotifier(Notifier: TCnWizBreakpointNotifier);
    {* 增加一个删除断点的通知事件}
    procedure RemoveBreakpointDeletedNotifier(Notifier: TCnWizBreakpointNotifier);
    {* 删除一个删除断点的通知事件}

    function GetCurrentCompilingProject: IOTAProject;
    {* 获取当前正在编译的工程、不是当前工程，使用通知内记录而来}

{$ENDIF}

    procedure AddSourceEditorNotifier(Notifier: TCnWizSourceEditorNotifier);
    {* 增加一个源代码编辑器通知事件}
    procedure RemoveSourceEditorNotifier(Notifier: TCnWizSourceEditorNotifier);
    {* 删除一个源代码编辑器通知事件}

    procedure AddActiveFormNotifier(Notifier: TNotifyEvent);
    {* 增加一个窗体活跃通知事件}
    procedure RemoveActiveFormNotifier(Notifier: TNotifyEvent);
    {* 删除一个窗体活跃通知事件}

    procedure AddActiveControlNotifier(Notifier: TNotifyEvent);
    {* 增加一个控件活跃通知事件}
    procedure RemoveActiveControlNotifier(Notifier: TNotifyEvent);
    {* 删除一个控件活跃通知事件}

    procedure AddApplicationIdleNotifier(Notifier: TNotifyEvent);
    {* 增加一个应用程序空闲通知事件}
    procedure RemoveApplicationIdleNotifier(Notifier: TNotifyEvent);
    {* 删除一个应用程序空闲通知事件}

    procedure AddApplicationMessageNotifier(Notifier: TMessageEvent);
    {* 增加一个应用程序消息通知事件，Lazarus 下暂时无效}
    procedure RemoveApplicationMessageNotifier(Notifier: TMessageEvent);
    {* 删除一个应用程序消息通知事件，Lazarus 下暂时无效}

    procedure AddAppEventNotifier(Notifier: TCnWizAppEventNotifier);
    {* 增加一个应用程序事件通知事件}
    procedure RemoveAppEventNotifier(Notifier: TCnWizAppEventNotifier);
    {* 删除一个应用程序事件通知事件}

    procedure AddCallWndProcNotifier(Notifier: TCnWizMsgHookNotifier; MsgIDs: array of Cardinal);
    {* 增加一个 CallWndProc HOOK 通知事件}
    procedure RemoveCallWndProcNotifier(Notifier: TCnWizMsgHookNotifier);
    {* 删除一个 CallWndProc HOOK 通知事件}

    procedure AddCallWndProcRetNotifier(Notifier: TCnWizMsgHookNotifier; MsgIDs: array of Cardinal);
    {* 增加一个 CallWndProcRet HOOK 通知事件}
    procedure RemoveCallWndProcRetNotifier(Notifier: TCnWizMsgHookNotifier);
    {* 删除一个 CallWndProcRet HOOK 通知事件}

    procedure AddGetMsgNotifier(Notifier: TCnWizGetMsgHookNotifier; MsgIDs: array of Cardinal);
    {* 增加一个 GetMessage HOOK 通知事件}
    procedure RemoveGetMsgNotifier(Notifier: TCnWizGetMsgHookNotifier);
    {* 删除一个 GetMessage HOOK 通知事件}

    procedure AddBeforeThemeChangeNotifier(Notifier: TNotifyEvent);
    {* 增加一个 IDE 主题变化前的通知事件}
    procedure RemoveBeforeThemeChangeNotifier(Notifier: TNotifyEvent);
    {* 删除一个 IDE 主题变化前的通知事件}
    procedure AddAfterThemeChangeNotifier(Notifier: TNotifyEvent);
    {* 增加一个 IDE 主题变化后的通知事件}
    procedure RemoveAfterThemeChangeNotifier(Notifier: TNotifyEvent);
    {* 删除一个 IDE 主题变化后的通知事件}

    procedure ExecuteOnApplicationIdle(Method: TNotifyEvent);
    {* 将一个方法在应用程序空闲时执行}
    procedure StopExecuteOnApplicationIdle(Method: TNotifyEvent);
    {* 将一个已经设置为空闲时执行的方法在它执行前通知停止执行，如已执行则此调用无效}
  end;

function CnWizNotifierServices: ICnWizNotifierServices;
{* 获取 IDE 通知服务接口}

procedure CnWizClearAndFreeList(var List: TList);
{* 全部释放通知器的公用函数}

procedure CnWizAddNotifier(List: TList; Notifier: TMethod);
{* 增加通知器公用函数}

procedure CnWizRemoveNotifier(List: TList; Notifier: TMethod);
{* 删除通知器公用函数}

function CnWizIndexOfNotifier(List: TList; Notifier: TMethod): Integer;
{* 查找通知器公用函数}

implementation

{$IFDEF DEBUG}
uses
  CnDebug, TypInfo;
{$ENDIF}

const
  csIdleMinInterval = 50;

type

{$IFDEF DELPHI_OTA}

//==============================================================================
// IDE 通知器类（私有类）
//==============================================================================

{ TCnWizIdeNotifier }

  TCnWizNotifierServices = class;

  TCnWizIdeNotifier = class(TNotifierObject, IOTAIdeNotifier, IOTAIDENotifier50)
  private
    FNotifierServices: TCnWizNotifierServices;
  protected
    // IOTAIdeNotifier
    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string; var Cancel: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean); overload;
  protected
    // IOTAIDENotifier50
    procedure BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean;
      var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean); overload;
  public
    constructor Create(ANotifierServices: TCnWizNotifierServices);
  end;

//==============================================================================
// SourceEditor 通知器类（私有类）
//==============================================================================

{ TCnSourceEditorNotifier }

  TCnSourceEditorNotifier = class(TNotifierObject, IOTANotifier, IOTAEditorNotifier)
  private
    FNotifierServices: TCnWizNotifierServices;
    NotifierIndex: Integer;
    OpenedNotified: Boolean;
    ClosingNotified: Boolean;
    SourceEditor: IOTASourceEditor;
  protected
    procedure ViewNotification(const View: IOTAEditView; Operation: TOperation);
    procedure ViewActivated(const View: IOTAEditView);
    procedure Destroyed;
    procedure Modified;
  public
    constructor Create(ANotifierServices: TCnWizNotifierServices);
    destructor Destroy; override;
  end;

//==============================================================================
// FormEditor 通知器类（私有类）
//==============================================================================

{ TCnFormEditorNotifier }

  TCnFormEditorNotifier = class(TNotifierObject, IOTANotifier, IOTAFormNotifier)
  private
    FNotifierServices: TCnWizNotifierServices;
    NotifierIndex: Integer;
    ClosingNotified: Boolean;
    FormEditor: IOTAFormEditor;
  protected
    procedure FormActivated;
    procedure FormSaving;
    procedure ComponentRenamed(ComponentHandle: TOTAHandle;
      const OldName, NewName: string);
    procedure Destroyed;
    procedure Modified;
  public
    constructor Create(ANotifierServices: TCnWizNotifierServices);
    destructor Destroy; override;
  end;

{$IFDEF IDE_SUPPORT_THEMING}

{$IFNDEF CNWIZARDS_MINIMUM} // Minimum 条件下不支持，也就是说针对 10.2，只能在 10.2.3 下加载

//==============================================================================
// IDE Theming Notifier 通知器类（私有类）
//==============================================================================

{ TCnIDEThemingServicesNotifier }

  TCnIDEThemingServicesNotifier = class(TNotifierObject, IOTANotifier,
    {$IFDEF DELPHI102_TOKYO}ICnNTAIDEThemingServicesNotifier {$ELSE} INTAIDEThemingServicesNotifier{$ENDIF})
  private
    FNotifierServices: TCnWizNotifierServices;
  protected
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;

    procedure ChangingTheme;
    procedure ChangedTheme;
  public
    constructor Create(ANotifierServices: TCnWizNotifierServices);
    destructor Destroy; override;
  end;

{$ENDIF}

{$ENDIF}

//==============================================================================
// DebuggerNotifier 通知器类（私有类）
//==============================================================================

{ TCnDebuggerNotifier }

  TCnWizDebuggerNotifier = class(TNotifierObject, IOTANotifier, IOTADebuggerNotifier)
  private
    FNotifierServices: TCnWizNotifierServices;
  protected
    procedure ProcessCreated({$IFDEF COMPILER9_UP}const {$ENDIF}Process: IOTAProcess);
    procedure ProcessDestroyed({$IFDEF COMPILER9_UP}const {$ENDIF}Process: IOTAProcess);
    procedure BreakpointAdded({$IFDEF COMPILER9_UP}const {$ENDIF}Breakpoint: IOTABreakpoint);
    procedure BreakpointDeleted({$IFDEF COMPILER9_UP}const {$ENDIF}Breakpoint: IOTABreakpoint);
  public
    constructor Create(ANotifierServices: TCnWizNotifierServices);
    destructor Destroy; override;
  end;

//==============================================================================
// 组件通知对象
//==============================================================================

{ TCnWizCompNotifyObj }

  TCnWizCompNotifyObj = class(TComponent)
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    FormEditor: IOTAFormEditor;
    NotifyType: TCnWizFormEditorNotifyType;
    ComponentHandle: TOTAHandle;
    Component: TComponent;
    OldName, NewName: string;
  end;

{$ENDIF}

//==============================================================================
// 通知器服务类（私有类）
//==============================================================================

{ TCnWizNotifierServices }

  TCnWizNotifierServices = class(TCnSingletonInterfacedObject, ICnWizNotifierServices)
  private
    FBeforeCompileNotifiers: TList;
    FAfterCompileNotifiers: TList;
    FProcessCreatedNotifiers: TList;
    FProcessDestroyedNotifiers: TList;
    FBreakpointAddedNotifiers: TList;
    FBreakpointDeletedNotifiers: TList;
    FFileNotifiers: TList;
    FSourceEditorNotifiers: TList;
    FSourceEditorIntfs: TList;
    FFormEditorNotifiers: TList;
    FFormEditorIntfs: TList;
    FActiveFormNotifiers: TList;
    FActiveControlNotifiers: TList;
    FApplicationIdleNotifiers: TList;
    FApplicationMessageNotifiers: TList;
    FAppEventNotifiers: TList;
    FCallWndProcNotifiers: TList;
    FCallWndProcMsgList: TList;
    FCallWndProcRetNotifiers: TList;
    FCallWndProcRetMsgList: TList;
    FGetMsgNotifiers: TList;
    FGetMsgMsgList: TList;
    FBeforeThemeChangeNotifiers: TList;
    FAfterThemeChangeNotifiers: TList;
    FIdleMethods: TList;
{$IFDEF FPC}
    FEvents: TApplicationProperties;
    FOldScreenActiveFormChange: TNotifyEvent;
    FOldScreenActiveControlChange: TNotifyEvent;
{$ELSE}
    FEvents: TApplicationEvents;
{$ENDIF}

{$IFDEF DELPHI_OTA}
    FIdeNotifierIndex: Integer;
    FDebuggerNotifierIndex: Integer;
    FCnWizIdeNotifier: TCnWizIdeNotifier;
    FCnWizDebuggerNotifier: TCnWizDebuggerNotifier;

{$IFDEF IDE_SUPPORT_THEMING}
{$IFNDEF CNWIZARDS_MINIMUM}
    FThemingNotifierIndex: Integer;
    {$IFDEF DELPHI102_TOKYO}
    FCnIDEThemingServicesNotifier:ICnNTAIDEThemingServicesNotifier;
    {$ELSE}
    FCnIDEThemingServicesNotifier: INTAIDEThemingServicesNotifier;
    {$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
    FLastControl: TWinControl;
    FLastForm: TForm;
    FDesignerSelection: TList;
    FLastDesignerSelection: TList;
    FCompNotifyList: TComponentList;
    FLastIdleTick: Cardinal;
    FIdleExecuting: Boolean;
{$IFDEF DELPHI_OTA}
    FCurrentCompilingProject: IOTAProject;
{$ENDIF}
    procedure AddNotifierEx(List, MsgList: TList; Notifier: TMethod; MsgIDs: array of Cardinal);
    procedure CheckActiveControl;
{$IFDEF DELPHI_OTA}
    procedure CheckDesignerSelection;
{$ENDIF}
    procedure DoIdleNotifiers;
  protected
    // ICnWizNotifierServices
{$IFDEF DELPHI_OTA}
    procedure AddFileNotifier(Notifier: TCnWizFileNotifier);
    procedure RemoveFileNotifier(Notifier: TCnWizFileNotifier);
    procedure AddBeforeCompileNotifier(Notifier: TCnWizBeforeCompileNotifier);
    procedure RemoveBeforeCompileNotifier(Notifier: TCnWizBeforeCompileNotifier);
    procedure AddAfterCompileNotifier(Notifier: TCnWizAfterCompileNotifier);
    procedure RemoveAfterCompileNotifier(Notifier: TCnWizAfterCompileNotifier);
    procedure AddFormEditorNotifier(Notifier: TCnWizFormEditorNotifier);
    procedure RemoveFormEditorNotifier(Notifier: TCnWizFormEditorNotifier);
    procedure AddProcessCreatedNotifier(Notifier: TCnWizProcessNotifier);
    procedure RemoveProcessCreatedNotifier(Notifier: TCnWizProcessNotifier);
    procedure AddProcessDestroyedNotifier(Notifier: TCnWizProcessNotifier);
    procedure RemoveProcessDestroyedNotifier(Notifier: TCnWizProcessNotifier);
    procedure AddBreakpointAddedNotifier(Notifier: TCnWizBreakpointNotifier);
    procedure RemoveBreakpointAddedNotifier(Notifier: TCnWizBreakpointNotifier);
    procedure AddBreakpointDeletedNotifier(Notifier: TCnWizBreakpointNotifier);
    procedure RemoveBreakpointDeletedNotifier(Notifier: TCnWizBreakpointNotifier);
    function GetCurrentCompilingProject: IOTAProject;
{$ENDIF}
    procedure AddSourceEditorNotifier(Notifier: TCnWizSourceEditorNotifier);
    procedure RemoveSourceEditorNotifier(Notifier: TCnWizSourceEditorNotifier);
    procedure AddActiveFormNotifier(Notifier: TNotifyEvent);
    procedure RemoveActiveFormNotifier(Notifier: TNotifyEvent);
    procedure AddActiveControlNotifier(Notifier: TNotifyEvent);
    procedure RemoveActiveControlNotifier(Notifier: TNotifyEvent);
    procedure AddApplicationIdleNotifier(Notifier: TNotifyEvent);
    procedure RemoveApplicationIdleNotifier(Notifier: TNotifyEvent);

    procedure AddApplicationMessageNotifier(Notifier: TMessageEvent);
    procedure RemoveApplicationMessageNotifier(Notifier: TMessageEvent);

    procedure AddAppEventNotifier(Notifier: TCnWizAppEventNotifier);
    procedure RemoveAppEventNotifier(Notifier: TCnWizAppEventNotifier);
    procedure AddCallWndProcNotifier(Notifier: TCnWizMsgHookNotifier; MsgIDs: array of Cardinal);
    procedure RemoveCallWndProcNotifier(Notifier: TCnWizMsgHookNotifier);
    procedure AddCallWndProcRetNotifier(Notifier: TCnWizMsgHookNotifier; MsgIDs: array of Cardinal);
    procedure RemoveCallWndProcRetNotifier(Notifier: TCnWizMsgHookNotifier);
    procedure AddGetMsgNotifier(Notifier: TCnWizGetMsgHookNotifier; MsgIDs: array of Cardinal);
    procedure RemoveGetMsgNotifier(Notifier: TCnWizGetMsgHookNotifier);
    procedure AddBeforeThemeChangeNotifier(Notifier: TNotifyEvent);
    procedure RemoveBeforeThemeChangeNotifier(Notifier: TNotifyEvent);
    procedure AddAfterThemeChangeNotifier(Notifier: TNotifyEvent);
    procedure RemoveAfterThemeChangeNotifier(Notifier: TNotifyEvent);
    procedure ExecuteOnApplicationIdle(Method: TNotifyEvent);
    procedure StopExecuteOnApplicationIdle(Method: TNotifyEvent);

    procedure SourceEditorNotify(SourceEditor: TCnSourceEditorInterface;
      NotifyType: TCnWizSourceEditorNotifyType {$IFDEF DELPHI_OTA}; EditView: IOTAEditView = nil {$ENDIF});
{$IFDEF DELPHI_OTA}
    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string);
    procedure BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean;
      var Cancel: Boolean);
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean);

    procedure ProcessCreated(Process: IOTAProcess);
    procedure ProcessDestroyed(Process: IOTAProcess);
    procedure BreakpointAdded(Breakpoint: IOTABreakpoint);
    procedure BreakpointDeleted(Breakpoint: IOTABreakpoint);

    procedure SourceEditorOpened(SourceEditor: IOTASourceEditor;
      CalledByNotifier: Boolean);
    procedure SourceEditorFileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string);

    procedure CheckNewFormEditor;
    procedure FormEditorOpened(FormEditor: IOTAFormEditor);
    procedure FormEditorNotify(FormEditor: IOTAFormEditor;
      NotifyType: TCnWizFormEditorNotifyType);
    procedure FormEditorComponentRenamed(FormEditor: IOTAFormEditor;
      ComponentHandle: TOTAHandle; const OldName, NewName: string);
    procedure CheckCompNotifyObj;
    procedure FormEditorFileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string);
{$ENDIF}

{$IFDEF LAZARUS}
    procedure ScreenActiveFormChange(Sender: TObject);
    procedure ScreenActiveControlChange(Sender: TObject);

    // EditorWindow 系列，Sender 是 TSourceNoteBook
    procedure SourceEditorWindowCreate(Sender: TObject);
    procedure SourceEditorWindowDestroy(Sender: TObject);
    procedure SourceEditorWindowActivate(Sender: TObject);
    procedure SourceEditorWindowFocused(Sender: TObject);
    procedure SourceEditorWindowShow(Sender: TObject);
    procedure SourceEditorWindowHide(Sender: TObject);
    // Editor 系列，Sender 是 TSourceEditor 或 nil（目前看上去在 Activate 中可能 nil）
    procedure SourceEditorCreate(Sender: TObject);
    procedure SourceEditorDestroy(Sender: TObject);
    procedure SourceEditorOptsChanged(Sender: TObject);
    procedure SourceEditorActivate(Sender: TObject);
    procedure SourceEditorStatus(Sender: TObject);
    procedure SourceEditorMouseDown(Sender: TObject);
    procedure SourceEditorMouseUp(Sender: TObject);
    procedure SourceEditorMoved(Sender: TObject);
    procedure SourceEditorCloned(Sender: TObject);
    procedure SourceEditorReConfigured(Sender: TObject);
{$ENDIF}
    procedure AppEventNotify(EventType: TCnWizAppEventType; Data: Pointer = nil);

    procedure DoBeforeThemeChange;
    procedure DoAfterThemeChange;

    procedure DoApplicationIdle(Sender: TObject; var Done: Boolean);
    procedure DoApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure DoMsgHook(AList, MsgList: TList; Handle: HWND; Msg: TMessage);
    function DoGetMsgHook(AList, MsgList: TList; Handle: HWND; Msg: TMessage): Boolean;
    procedure DoCallWndProc(Handle: HWND; Msg: TMessage);
    procedure DoCallWndProcRet(Handle: HWND; Msg: TMessage);
    function DoGetMsg(Handle: HWND; Msg: TMessage): Boolean;
    procedure DoActiveFormChange;
    procedure DoApplicationActivate(Sender: TObject);
    procedure DoApplicationDeactivate(Sender: TObject);
    procedure DoApplicationMinimize(Sender: TObject);
    procedure DoApplicationRestore(Sender: TObject);
    procedure DoApplicationHint(Sender: TObject);
    procedure DoApplicationShowHint(var HintStr: string; var CanShow: Boolean;
      var HintInfo: THintInfo);

    procedure DoActiveControlChange;
    procedure DoIdleExecute;
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  FIsReleased: Boolean = False;
  FCnWizNotifierServices: TCnWizNotifierServices = nil;

{$IFNDEF DELPHI_OTA}
  IdeClosing: Boolean = False; // 独立运行时无此变量，冒充一个


// 独立运行时无此方法，也冒充一个，处理一些执行方法中的异常
procedure DoHandleException(const ErrorMsg: string; E: Exception = nil);
begin
{$IFDEF DEBUG}
  if E = nil then
    CnDebugger.LogMsgWithType('Error: ' + ErrorMsg, cmtError)
  else
  begin
    CnDebugger.LogMsgWithType('Error ' + ErrorMsg + ' : ' + E.Message, cmtError);
    CnDebugger.LogStackFromAddress(ExceptAddr, 'Call Stack');
  end;
{$ENDIF}
end;

{$ENDIF}

function CnWizNotifierServices: ICnWizNotifierServices;
begin
  Assert(not FIsReleased, 'Access CnWizNotifierServices After Released.');
  if not Assigned(FCnWizNotifierServices) then
    FCnWizNotifierServices := TCnWizNotifierServices.Create;
  Result := FCnWizNotifierServices as ICnWizNotifierServices;
end;

procedure FreeCnWizNotifierServices;
begin
  if Assigned(FCnWizNotifierServices) then
  begin
    FCnWizNotifierServices.Free;
    FCnWizNotifierServices := nil;
    FIsReleased := True;
  end;
end;

procedure CnWizClearAndFreeList(var List: TList);
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

procedure CnWizAddNotifier(List: TList; Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
begin
  if List = nil then
    Exit;

  if CnWizIndexOfNotifier(List, Notifier) < 0 then
  begin
    New(Rec);
    Rec^.Notifier := TMethod(Notifier);
    List.Add(Rec);
  end;
end;

procedure CnWizRemoveNotifier(List: TList; Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
  Idx: Integer;
begin
  Idx := CnWizIndexOfNotifier(List, Notifier);
  if Idx >= 0 then
  begin
    Rec := List[Idx];
    Dispose(Rec);
    List.Delete(Idx);
  end;
end;

function CnWizIndexOfNotifier(List: TList; Notifier: TMethod): Integer;
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

{$IFDEF DELPHI_OTA}

//==============================================================================
// IDE 通知器类（私有类）
//==============================================================================

{ TCnWizIdeNotifier }

constructor TCnWizIdeNotifier.Create(ANotifierServices: TCnWizNotifierServices);
begin
  inherited Create;
  FNotifierServices := ANotifierServices;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnWizIdeNotifier.Create succeed');
{$ENDIF}
end;

procedure TCnWizIdeNotifier.AfterCompile(Succeeded,
  IsCodeInsight: Boolean);
begin
  FNotifierServices.AfterCompile(Succeeded, IsCodeInsight);
end;

procedure TCnWizIdeNotifier.AfterCompile(Succeeded: Boolean);
begin

end;

procedure TCnWizIdeNotifier.BeforeCompile(const Project: IOTAProject;
  var Cancel: Boolean);
begin

end;

procedure TCnWizIdeNotifier.BeforeCompile(const Project: IOTAProject;
  IsCodeInsight: Boolean; var Cancel: Boolean);
begin
  Cancel := False;
  FNotifierServices.BeforeCompile(Project, IsCodeInsight, Cancel);
end;

procedure TCnWizIdeNotifier.FileNotification(
  NotifyCode: TOTAFileNotification; const FileName: string;
  var Cancel: Boolean);
begin
  Cancel := False;
  FNotifierServices.FileNotification(NotifyCode, FileName);
end;

//==============================================================================
// SourceEditor 通知器类（私有类）
//==============================================================================

// 在 IDE 中直接打开或关闭单个单元时，通过 IDE 文件通知可以获得 SourceEditor，
// 并且 EditViewCount 为 1。
// 但是在打开工程时，IDE 文件通知获得的 SourceEditor 的 EditViewCount 为 0，并且
// 在关闭工程时，并不会产生 IDE 文件通知。
// 故对每一个 SourceEditor 注册一个 Notifier，如果文件打开时，EditViewCount 为 0，
// 则在 Notifier 中检查 EditView 创建并产生 SourceEditor Opened 通知。
// 如果文件正常关闭，在 IDE 文件通知中产生 SourceEditor Closing 通知，反之通过
// Notifier 在 SourceEditor Destroyed 时产生 Closing 通知。

{ TCnSourceEditorNotifier }

constructor TCnSourceEditorNotifier.Create(ANotifierServices: TCnWizNotifierServices);
begin
  Assert(Assigned(ANotifierServices));
  inherited Create;
  FNotifierServices := ANotifierServices;
  OpenedNotified := False;
  ClosingNotified := False;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnSourceEditorNotifier.Create succeed');
{$ENDIF}
end;

destructor TCnSourceEditorNotifier.Destroy;
var
  Idx: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnSourceEditorNotifier.Destroy');
{$ENDIF}
  NoRefCount(SourceEditor) := nil;
  with FNotifierServices.FSourceEditorIntfs do
  begin
    Idx := IndexOf(Self);
  {$IFDEF DEBUG}
    CnDebugger.LogInteger(Idx, 'IndexOf TCnSourceEditorNotifier');
  {$ENDIF}
    if Idx >= 0 then
      Delete(Idx);
  end;
  inherited;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnSourceEditorNotifier.Destroy');
{$ENDIF}
end;

procedure TCnSourceEditorNotifier.Destroyed;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnSourceEditorNotifier.Destroyed: ' + SourceEditor.FileName);
  CnDebugger.LogInteger(SourceEditor.EditViewCount, 'TCnSourceEditorNotifier ViewCount');
{$ENDIF}
  if not ClosingNotified then
  begin
    ClosingNotified := True;
    FNotifierServices.SourceEditorNotify(SourceEditor, setClosing);
  end;
  NoRefCount(SourceEditor) := nil;
end;

procedure TCnSourceEditorNotifier.Modified;
begin
  FNotifierServices.SourceEditorNotify(SourceEditor, setModified);
end;

procedure TCnSourceEditorNotifier.ViewActivated(const View: IOTAEditView);
begin
  FNotifierServices.SourceEditorNotify(SourceEditor, setEditViewActivated, View)
end;

procedure TCnSourceEditorNotifier.ViewNotification(const View: IOTAEditView;
  Operation: TOperation);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ViewNotification: %s, %s', [SourceEditor.FileName,
    GetEnumName(TypeInfo(TOperation), Ord(Operation))]);
{$ENDIF}
  if not OpenedNotified and (Operation = opInsert) then
  begin
    OpenedNotified := True;
    FNotifierServices.SourceEditorOpened(SourceEditor, True);
  end;

  if Operation = opInsert then
    FNotifierServices.SourceEditorNotify(SourceEditor, setEditViewInsert, View)
  else if Operation = opRemove then
    FNotifierServices.SourceEditorNotify(SourceEditor, setEditViewRemove, View)
end;

//==============================================================================
// FormEditor 通知器类（私有类）
//==============================================================================

{ TCnFormEditorNotifier }

constructor TCnFormEditorNotifier.Create(
  ANotifierServices: TCnWizNotifierServices);
begin
  Assert(Assigned(ANotifierServices));
  inherited Create;
  FNotifierServices := ANotifierServices;
  ClosingNotified := False;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnFormEditorNotifier.Create succeed');
{$ENDIF}
end;

destructor TCnFormEditorNotifier.Destroy;
var
  Idx: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnFormEditorNotifier.Destroy');
{$ENDIF}
  NoRefCount(FormEditor) := nil;
  with FNotifierServices.FFormEditorIntfs do
  begin
    Idx := IndexOf(Self);
  {$IFDEF DEBUG}
    CnDebugger.LogInteger(Idx, 'Index');
  {$ENDIF}
    if Idx >= 0 then
      Delete(Idx);
  end;
  inherited;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnFormEditorNotifier.Destroy');
{$ENDIF}
end;

procedure TCnFormEditorNotifier.Destroyed;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnFormEditorNotifier.Destroyed: ' + FormEditor.FileName);
{$ENDIF}
  if not ClosingNotified then
  begin
    ClosingNotified := True;
    FNotifierServices.FormEditorNotify(FormEditor, fetClosing);
  end;
  FormEditor.RemoveNotifier(NotifierIndex);
  NoRefCount(FormEditor) := nil;
end;

procedure TCnFormEditorNotifier.ComponentRenamed(
  ComponentHandle: TOTAHandle; const OldName, NewName: string);
begin
  FNotifierServices.FormEditorComponentRenamed(FormEditor, ComponentHandle,
    Trim(OldName), Trim(NewName));
end;

procedure TCnFormEditorNotifier.FormActivated;
begin
  FNotifierServices.FormEditorNotify(FormEditor, fetActivated);
end;

procedure TCnFormEditorNotifier.FormSaving;
begin
  FNotifierServices.FormEditorNotify(FormEditor, fetSaving);
end;

procedure TCnFormEditorNotifier.Modified;
begin
  FNotifierServices.FormEditorNotify(FormEditor, fetModified);
end;

//==============================================================================
// 组件通知对象
//==============================================================================

{ TCnWizCompNotifyObj }

procedure TCnWizCompNotifyObj.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = Component) and (Operation = opRemove) then
    Free;
end;

{$ENDIF}

//==============================================================================
// Windows HOOK
//==============================================================================

var
  CallWndProcHook: HHOOK;
  CallWndProcRetHook: HHOOK;
  GetMsgHook: HHOOK;

function CallWndProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  Msg: TMessage;
begin
  if nCode < 0 then
  begin
    Result := CallNextHookEx(CallWndProcHook, nCode, wParam, lParam);
    Exit;
  end;

  if nCode = HC_ACTION then
  begin
    FillChar(Msg, SizeOf(Msg), 0);
    Msg.Msg := PCWPStruct(lParam)^.message;
    Msg.LParam := PCWPStruct(lParam)^.lParam;
    Msg.WParam := PCWPStruct(lParam)^.wParam;
    FCnWizNotifierServices.DoCallWndProc(PCWPStruct(lParam)^.hwnd, Msg);
  end;

  Result := CallNextHookEx(CallWndProcHook, nCode, wParam, lParam);
end;

function CallWndProcRet(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  Msg: TMessage;
begin
  if nCode < 0 then
  begin
    Result := CallNextHookEx(CallWndProcRetHook, nCode, wParam, lParam);
    Exit;
  end;

  if nCode = HC_ACTION then
  begin
    FillChar(Msg, SizeOf(Msg), 0);
    Msg.Msg := PCWPRetStruct(lParam)^.message;
    Msg.LParam := PCWPRetStruct(lParam)^.lParam;
    Msg.WParam := PCWPRetStruct(lParam)^.wParam;
    Msg.Result := PCWPRetStruct(lParam)^.lResult;
    FCnWizNotifierServices.DoCallWndProcRet(PCWPRetStruct(lParam)^.hwnd, Msg);
  end;

  Result := CallNextHookEx(CallWndProcRetHook, nCode, wParam, lParam);
end;

function GetMsgProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  Msg: TMessage;
begin
  if nCode < 0 then
  begin
    Result := CallNextHookEx(GetMsgHook, nCode, wParam, lParam);
    Exit;
  end;

  if nCode = HC_ACTION then
  begin
    if wParam = PM_REMOVE then
    begin
      FillChar(Msg, SizeOf(Msg), 0);
      Msg.Msg := PMsg(lParam)^.message;
      Msg.LParam := PMsg(lParam)^.lParam;
      Msg.WParam := PMsg(lParam)^.wParam;

      // 如果有处理函数返回了 True，则吞掉该消息
      if FCnWizNotifierServices.DoGetMsg(PMsg(lParam)^.hwnd, Msg) then
        PMsg(lParam)^.message := WM_NULL;
    end;
  end;

  Result := CallNextHookEx(GetMsgHook, nCode, wParam, lParam);
end;

//==============================================================================
// 通知器服务类（私有类）
//==============================================================================

{ TCnWizNotifierServices }

constructor TCnWizNotifierServices.Create;
{$IFDEF DELPHI_OTA}
var
  IServices: IOTAServices;
  IDebuggerService: IOTADebuggerServices;
{$IFDEF IDE_SUPPORT_THEMING}
{$IFNDEF CNWIZARDS_MINIMUM}
  {$IFDEF DELPHI102_TOKYO}
  ThemingService: ICnOTAIDEThemingServices;
  {$ELSE}
  ThemingService: IOTAIDEThemingServices;
  {$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
begin
  inherited;
{$IFDEF DELPHI_OTA}
  IServices := BorlandIDEServices as IOTAServices;
  IDebuggerService := BorlandIDEServices as IOTADebuggerServices;
  Assert(Assigned(IServices) and Assigned(IDebuggerService));
{$ENDIF}

  FBeforeCompileNotifiers := TList.Create;
  FAfterCompileNotifiers := TList.Create;
  FProcessCreatedNotifiers := TList.Create;
  FProcessDestroyedNotifiers := TList.Create;
  FBreakpointAddedNotifiers := TList.Create;
  FBreakpointDeletedNotifiers := TList.Create;

  FFileNotifiers := TList.Create;
{$IFDEF FPC}
  FEvents := TApplicationProperties.Create(nil);
  FEvents.OnIdle := DoApplicationIdle;
  FEvents.OnMinimize := DoApplicationMinimize;
  FEvents.OnRestore := DoApplicationRestore;
  FEvents.OnHint := DoApplicationHint;
  FEvents.OnShowHint := DoApplicationShowHint;
{$ELSE}
  FEvents := TApplicationEvents.Create(nil);
  FEvents.OnIdle := DoApplicationIdle;
  FEvents.OnMessage := DoApplicationMessage;
  // FEvents.OnActivate := DoApplicationActivate;
  // FEvents.OnDeactivate := DoApplicationDeactivate;
  FEvents.OnMinimize := DoApplicationMinimize;
  FEvents.OnRestore := DoApplicationRestore;
  FEvents.OnHint := DoApplicationHint;
  FEvents.OnShowHint := DoApplicationShowHint;
{$ENDIF}
  FSourceEditorNotifiers := TList.Create;
  FSourceEditorIntfs := TList.Create;
  FFormEditorNotifiers := TList.Create;
  FFormEditorIntfs := TList.Create;
  FActiveFormNotifiers := TList.Create;
  FActiveControlNotifiers := TList.Create;
  FApplicationIdleNotifiers := TList.Create;
  FApplicationMessageNotifiers := TList.Create;
  FAppEventNotifiers := TList.Create;
  FCallWndProcNotifiers := TList.Create;
  FCallWndProcMsgList := TList.Create;
  FCallWndProcRetNotifiers := TList.Create;
  FCallWndProcRetMsgList := TList.Create;
  FGetMsgNotifiers := TList.Create;
  FGetMsgMsgList := TList.Create;
  FBeforeThemeChangeNotifiers := TList.Create;
  FAfterThemeChangeNotifiers := TList.Create;
  FIdleMethods := TList.Create;
  FDesignerSelection := TList.Create;
  FLastDesignerSelection := TList.Create;
  FCompNotifyList := TComponentList.Create(True);

{$IFDEF LAZARUS}
  FOldScreenActiveFormChange := Screen.OnActiveFormChange;
  Screen.OnActiveFormChange := ScreenActiveFormChange;
  FOldScreenActiveControlChange := Screen.OnActiveControlChange;
  Screen.OnActiveControlChange := ScreenActiveControlChange;

  if SourceEditorManagerIntf <> nil then
  begin
    SourceEditorManagerIntf.RegisterChangeEvent(semWindowCreate, SourceEditorWindowCreate);
    SourceEditorManagerIntf.RegisterChangeEvent(semWindowDestroy, SourceEditorWindowDestroy);
    SourceEditorManagerIntf.RegisterChangeEvent(semWindowActivate, SourceEditorWindowActivate);
    SourceEditorManagerIntf.RegisterChangeEvent(semWindowFocused, SourceEditorWindowFocused);
    SourceEditorManagerIntf.RegisterChangeEvent(semWindowShow, SourceEditorWindowShow);
    SourceEditorManagerIntf.RegisterChangeEvent(semWindowHide, SourceEditorWindowHide);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorCreate, SourceEditorCreate);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorDestroy, SourceEditorDestroy);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorOptsChanged, SourceEditorOptsChanged);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorActivate, SourceEditorActivate);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorStatus, SourceEditorStatus);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorMouseDown, SourceEditorMouseDown);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorMouseUp, SourceEditorMouseUp);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorMoved, SourceEditorMoved);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorCloned, SourceEditorCloned);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorReConfigured, SourceEditorReConfigured);
  end;
{$ENDIF}

{$IFDEF DELPHI_OTA}
  FCnWizIdeNotifier := TCnWizIdeNotifier.Create(Self);
  FIdeNotifierIndex := IServices.AddNotifier(FCnWizIdeNotifier as IOTAIDENotifier);
  FCnWizDebuggerNotifier := TCnWizDebuggerNotifier.Create(Self);
  FDebuggerNotifierIndex := IDebuggerService.AddNotifier(FCnWizDebuggerNotifier as IOTADebuggerNotifier);
{$IFDEF IDE_SUPPORT_THEMING}
{$IFNDEF CNWIZARDS_MINIMUM}
  if Supports(BorlandIDEServices, StringToGUID(GUID_IOTAIDETHEMINGSERVICES), ThemingService) then // 貌似 10.2.2 或以上支持，10.2.1 未知
  begin
    FCnIDEThemingServicesNotifier := TCnIDEThemingServicesNotifier.Create(Self);
    FThemingNotifierIndex := ThemingService.AddNotifier(FCnIDEThemingServicesNotifier);
  end;
{$ENDIF}
{$ENDIF}
{$ENDIF}

  CallWndProcHook := SetWindowsHookEx(WH_CALLWNDPROC, CallWndProc, 0, GetCurrentThreadId);
  CallWndProcRetHook := SetWindowsHookEx(WH_CALLWNDPROCRET, CallWndProcRet, 0, GetCurrentThreadId);
  GetMsgHook := SetWindowsHookEx(WH_GETMESSAGE, GetMsgProc, 0, GetCurrentThreadId);
  FLastControl := nil;
  FLastForm := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnWizNotifierServices.Create succeed');
{$ENDIF}
end;

destructor TCnWizNotifierServices.Destroy;
{$IFDEF DELPHI_OTA}
var
  IServices: IOTAServices;
  IDebuggerService: IOTADebuggerServices;
  I: Integer;
{$IFDEF IDE_SUPPORT_THEMING}
{$IFNDEF CNWIZARDS_MINIMUM}
  {$IFDEF DELPHI102_TOKYO}
  ThemingService: ICnOTAIDEThemingServices;
  {$ELSE}
  ThemingService: IOTAIDEThemingServices;
  {$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizNotifierServices.Destroy');
{$ENDIF}
  UnhookWindowsHookEx(CallWndProcHook);
  CallWndProcHook := 0;
  UnhookWindowsHookEx(CallWndProcRetHook);
  CallWndProcRetHook := 0;
  UnhookWindowsHookEx(GetMsgHook);
  GetMsgHook := 0;

{$IFDEF LAZARUS}
  if SourceEditorManagerIntf <> nil then
  begin
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorReConfigured, SourceEditorReConfigured);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorCloned, SourceEditorCloned);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorMoved, SourceEditorMoved);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorMouseUp, SourceEditorMouseUp);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorMouseDown, SourceEditorMouseDown);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorStatus, SourceEditorStatus);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorActivate, SourceEditorActivate);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorOptsChanged, SourceEditorOptsChanged);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorDestroy, SourceEditorDestroy);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorCreate, SourceEditorCreate);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semWindowHide, SourceEditorWindowHide);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semWindowShow, SourceEditorWindowShow);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semWindowFocused, SourceEditorWindowFocused);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semWindowActivate, SourceEditorWindowActivate);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semWindowDestroy, SourceEditorWindowDestroy);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semWindowCreate, SourceEditorWindowCreate);
  end;

  Screen.OnActiveFormChange := FOldScreenActiveFormChange;
  Screen.OnActiveControlChange := FOldScreenActiveControlChange;
{$ENDIF}

{$IFDEF DELPHI_OTA}
  IServices := BorlandIDEServices as IOTAServices;
  if Assigned(IServices) then
    IServices.RemoveNotifier(FIdeNotifierIndex);
  IDebuggerService := BorlandIDEServices as IOTADebuggerServices;
  if Assigned(IDebuggerService) then
    IDebuggerService.RemoveNotifier(FDebuggerNotifierIndex);

{$IFDEF IDE_SUPPORT_THEMING}
{$IFNDEF CNWIZARDS_MINIMUM}
  if FThemingNotifierIndex <> 0 then
  begin
    if Supports(BorlandIDEServices, StringToGUID(GUID_IOTAIDETHEMINGSERVICES), ThemingService) then
      ThemingService.RemoveNotifier(FThemingNotifierIndex);
  end;
  FCnIDEThemingServicesNotifier := nil;
{$ENDIF}
{$ENDIF}
{$ENDIF}

  FreeAndNil(FCompNotifyList);
{$IFNDEF LAZARUS}
  FreeAndNil(FEvents);
{$ENDIF}
  FDesignerSelection.Free;
  FLastDesignerSelection.Free;

  CnWizClearAndFreeList(FBeforeCompileNotifiers);
  CnWizClearAndFreeList(FAfterCompileNotifiers);
  CnWizClearAndFreeList(FProcessCreatedNotifiers);
  CnWizClearAndFreeList(FProcessDestroyedNotifiers);
  CnWizClearAndFreeList(FBreakpointAddedNotifiers);
  CnWizClearAndFreeList(FBreakpointDeletedNotifiers);
  CnWizClearAndFreeList(FFileNotifiers);
  CnWizClearAndFreeList(FSourceEditorNotifiers);
  CnWizClearAndFreeList(FFormEditorNotifiers);
  CnWizClearAndFreeList(FActiveFormNotifiers);
  CnWizClearAndFreeList(FActiveControlNotifiers);
  CnWizClearAndFreeList(FApplicationIdleNotifiers);
  CnWizClearAndFreeList(FApplicationMessageNotifiers);
  CnWizClearAndFreeList(FAppEventNotifiers);
  CnWizClearAndFreeList(FCallWndProcNotifiers);
  FreeAndNil(FCallWndProcMsgList);
  CnWizClearAndFreeList(FCallWndProcRetNotifiers);
  FreeAndNil(FCallWndProcRetMsgList);
  CnWizClearAndFreeList(FGetMsgNotifiers);
  FreeAndNil(FGetMsgMsgList);
  CnWizClearAndFreeList(FBeforeThemeChangeNotifiers);
  CnWizClearAndFreeList(FAfterThemeChangeNotifiers);
  CnWizClearAndFreeList(FIdleMethods);

{$IFDEF DELPHI_OTA}
{$IFDEF DEBUG}
  CnDebugger.LogInteger(FFormEditorIntfs.Count, 'Remove FormEditorNotifiers');
{$ENDIF}
  for I := FFormEditorIntfs.Count - 1 downto 0 do
  begin
    with TCnFormEditorNotifier(FFormEditorIntfs[I]) do
    begin
      if Assigned(FormEditor) then
      begin
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('Form: ' + FormEditor.FileName);
        {$ENDIF}
          FormEditor.RemoveNotifier(NotifierIndex);
      end;
    end;
  end;
  FreeAndNil(FFormEditorIntfs);

{$IFDEF DEBUG}
  CnDebugger.LogInteger(FSourceEditorIntfs.Count, 'Remove SourceEditorNotifiers');
{$ENDIF}
  for I := FSourceEditorIntfs.Count - 1 downto 0 do
  begin
    with TCnSourceEditorNotifier(FSourceEditorIntfs[I]) do
    begin
      if Assigned(SourceEditor) then
      begin
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('Source: ' + SourceEditor.FileName);
        {$ENDIF}
          SourceEditor.RemoveNotifier(NotifierIndex);
      end;
    end;
  end;
  FreeAndNil(FSourceEditorIntfs);
{$ENDIF}

  inherited;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizNotifierServices.Destroy');
{$ENDIF}
end;

//------------------------------------------------------------------------------
// 列表操作
//------------------------------------------------------------------------------

procedure TCnWizNotifierServices.AddNotifierEx(List, MsgList: TList;
  Notifier: TMethod; MsgIDs: array of Cardinal);
var
  I: Integer;
begin
  CnWizAddNotifier(List, Notifier);
  for I := Low(MsgIDs) to High(MsgIDs) do
  begin
    if MsgList.IndexOf(Pointer(MsgIDs[I])) < 0 then
      MsgList.Add(Pointer(MsgIDs[I]));
  end;
end;

procedure TCnWizNotifierServices.AddSourceEditorNotifier(
  Notifier: TCnWizSourceEditorNotifier);
begin
  CnWizAddNotifier(FSourceEditorNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveSourceEditorNotifier(
  Notifier: TCnWizSourceEditorNotifier);
begin
  CnWizRemoveNotifier(FSourceEditorNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.SourceEditorNotify(SourceEditor: TCnSourceEditorInterface;
  NotifyType: TCnWizSourceEditorNotifyType {$IFDEF DELPHI_OTA}; EditView: IOTAEditView {$ENDIF});
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('SourceEditorNotifier: %s (%s)',
    [GetEnumName(TypeInfo(TCnWizSourceEditorNotifyType), Ord(NotifyType)),
    {$IFDEF STAND_ALONE} '' {$ELSE} SourceEditor.FileName {$ENDIF}]);
{$ENDIF}
  if FSourceEditorNotifiers <> nil then
  begin
    for I := FSourceEditorNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FSourceEditorNotifiers[I])^ do
        TCnWizSourceEditorNotifier(Notifier)(SourceEditor, NotifyType {$IFDEF DELPHI_OTA}, EditView {$ENDIF});
    except
      DoHandleException('TCnWizNotifierServices.SourceEditorNotify[' + IntToStr(I) + ']');
    end;
  end;
end;

{$IFDEF DELPHI_OTA}

//------------------------------------------------------------------------------
// IDE 文件通知
//------------------------------------------------------------------------------

procedure TCnWizNotifierServices.AddFileNotifier(
  Notifier: TCnWizFileNotifier);
begin
  CnWizAddNotifier(FFileNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveFileNotifier(
  Notifier: TCnWizFileNotifier);
begin
  CnWizRemoveNotifier(FFileNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.FileNotification(
  NotifyCode: TOTAFileNotification; const FileName: string);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('FileNotification: %s (%s)',
    [GetEnumName(TypeInfo(TOTAFileNotification), Ord(NotifyCode)), FileName]);
{$ENDIF}

  if Trim(FileName) = '' then
    Exit; // BCB 会碰到无文件名的问题

  SourceEditorFileNotification(NotifyCode, FileName);
  FormEditorFileNotification(NotifyCode, FileName);
  if FFileNotifiers <> nil then
  begin
    for I := FFileNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FFileNotifiers[I])^ do
        TCnWizFileNotifier(Notifier)(NotifyCode, FileName);
    except
      DoHandleException('TCnWizNotifierServices.FileNotification[' + IntToStr(I) + ']');
    end;
  end;

  if NotifyCode = ofnPackageUninstalled then
  begin
    if (Application = nil) or (Application.FindComponent('AppBuilder') = nil) then
    begin
    {$IFDEF DEBUG}
      if not IdeClosing then
      begin
        CnDebugger.LogSeparator;
        CnDebugger.LogMsg('Ide is closing');
      end;
    {$ENDIF}
      IdeClosing := True;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 编译通知
//------------------------------------------------------------------------------

procedure TCnWizNotifierServices.AddAfterCompileNotifier(
  Notifier: TCnWizAfterCompileNotifier);
begin
  CnWizAddNotifier(FAfterCompileNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.AddBeforeCompileNotifier(
  Notifier: TCnWizBeforeCompileNotifier);
begin
  CnWizAddNotifier(FBeforeCompileNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveAfterCompileNotifier(
  Notifier: TCnWizAfterCompileNotifier);
begin
  CnWizRemoveNotifier(FAfterCompileNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveBeforeCompileNotifier(
  Notifier: TCnWizBeforeCompileNotifier);
begin
  CnWizRemoveNotifier(FBeforeCompileNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.AfterCompile(Succeeded,
  IsCodeInsight: Boolean);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('AfterCompile: Succedded: %d IsCodeInsight: %d',
    [Integer(Succeeded), Integer(IsCodeInsight)]);
{$ENDIF}
  if GetCurrentThreadId <> MainThreadID then
    Exit;

  if FAfterCompileNotifiers <> nil then
  begin
    for I := FAfterCompileNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FAfterCompileNotifiers[I])^ do
        TCnWizAfterCompileNotifier(Notifier)(Succeeded, IsCodeInsight);
    except
      DoHandleException('TCnWizNotifierServices.AfterCompile[' + IntToStr(I) + ']');
    end;
  end;

  if not IsCodeInsight then
    FCurrentCompilingProject := nil;
end;

procedure TCnWizNotifierServices.BeforeCompile(const Project: IOTAProject;
  IsCodeInsight: Boolean; var Cancel: Boolean);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  if Project = nil then
    CnDebugger.LogFmt('BeforeCompile: Project is nil. IsCodeInsight: %d',
      [Integer(IsCodeInsight)])
  else
    CnDebugger.LogFmt('BeforeCompile: %s IsCodeInsight: %d',
      [Project.FileName, Integer(IsCodeInsight)]);
{$ENDIF}
  if not IsCodeInsight then
    FCurrentCompilingProject := Project;

  if GetCurrentThreadId <> MainThreadID then
    Exit;

  if FBeforeCompileNotifiers <> nil then
  begin
    for I := FBeforeCompileNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FBeforeCompileNotifiers[I])^ do
        TCnWizBeforeCompileNotifier(Notifier)(Project, IsCodeInsight, Cancel);
    except
      DoHandleException('TCnWizNotifierServices.BeforeCompile[' + IntToStr(I) + ']');
    end;
  end;
end;

//------------------------------------------------------------------------------
// SourceEditor 通知
//------------------------------------------------------------------------------

procedure TCnWizNotifierServices.SourceEditorOpened(
  SourceEditor: IOTASourceEditor; CalledByNotifier: Boolean);
var
  Notifier: TCnSourceEditorNotifier;
begin
{$IFDEF COMPILER5}
  // D5 下如果为包文件注册通知器，在释放时可能会出异常
  if IsPackage(SourceEditor.FileName) then
    Exit;
{$ENDIF COMPILER5}

  if SourceEditor.GetEditViewCount > 0 then
  begin
    SourceEditorNotify(SourceEditor, setOpened);

    // 如果不是由通知器调用的，创建一个通知器来获得编辑器关闭时的通知
    if not CalledByNotifier then
    begin
      Notifier := TCnSourceEditorNotifier.Create(Self);
      Notifier.OpenedNotified := True;

      NoRefCount(Notifier.SourceEditor) := NoRefCount(SourceEditor);
      Notifier.NotifierIndex := SourceEditor.AddNotifier(Notifier as IOTAEditorNotifier);
      FSourceEditorIntfs.Add(Notifier);
    end
  end
  else
  begin
    // 打开一个工程时，SourceEditor 是没有 View 的，故创建一个通知器在
    // SourceEditor 创建第一个 View 时获得通知
    Notifier := TCnSourceEditorNotifier.Create(Self);
    Notifier.OpenedNotified := False;
    // 不增加引用计数下保存接口，否则关闭时会出错
    NoRefCount(Notifier.SourceEditor) := NoRefCount(SourceEditor);
    Notifier.NotifierIndex := SourceEditor.AddNotifier(Notifier as IOTAEditorNotifier);
    FSourceEditorIntfs.Add(Notifier);
  end;
end;

procedure TCnWizNotifierServices.SourceEditorFileNotification(
  NotifyCode: TOTAFileNotification; const FileName: string);
var
  I, J: Integer;
  Module: IOTAModule;
  Editor: IOTAEditor;
  SourceEditor: IOTASourceEditor;
begin
  if (NotifyCode = ofnFileOpened) or (NotifyCode = ofnFileClosing) then
  begin
    Module := CnOtaGetModule(FileName);
    if not Assigned(Module) then
      Exit;

    for I := 0 to Module.GetModuleFileCount - 1 do
    begin
      Editor := nil;
      try
        Editor := Module.GetModuleFileEditor(I);
        // BCB 5 中调用此函数可能会出访问冲突，故以此来屏蔽，以下类似。
      except
        ;
      end;

      if Assigned(Editor) and Supports(Editor, IOTASourceEditor, SourceEditor) then
      begin
        if NotifyCode = ofnFileOpened then
        begin
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('SourceEditorOpened');
        {$ENDIF}
          SourceEditorOpened(SourceEditor, False);
        end
        else
        begin
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('SourceEditorClosing');
        {$ENDIF}
          SourceEditorNotify(SourceEditor, setClosing);
          for J := 0 to FSourceEditorIntfs.Count - 1 do
            if TCnSourceEditorNotifier(FSourceEditorIntfs[J]).SourceEditor =
              SourceEditor then
            begin
            {$IFDEF DEBUG}
              CnDebugger.LogMsg('Remove SourceEditorNotifier in FileNotification');
            {$ENDIF}
              TCnSourceEditorNotifier(FSourceEditorIntfs[J]).ClosingNotified := True;
              Break;
            end;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// FormEditor 通知
//------------------------------------------------------------------------------

procedure TCnWizNotifierServices.AddFormEditorNotifier(
  Notifier: TCnWizFormEditorNotifier);
begin
  CnWizAddNotifier(FFormEditorNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveFormEditorNotifier(
  Notifier: TCnWizFormEditorNotifier);
begin
  CnWizRemoveNotifier(FFormEditorNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.FormEditorNotify(FormEditor: IOTAFormEditor;
  NotifyType: TCnWizFormEditorNotifyType);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  if FormEditor <> nil then
    CnDebugger.LogFmt('FormEditorNotify: %s (%s)',
      [GetEnumName(TypeInfo(TCnWizFormEditorNotifyType),
      Ord(NotifyType)), FormEditor.FileName])
  else
    CnDebugger.LogFmt('FormEditorNotify: %s',
      [GetEnumName(TypeInfo(TCnWizFormEditorNotifyType), Ord(NotifyType))]);
{$ENDIF}

  if FFormEditorNotifiers <> nil then
  begin
    for I := FFormEditorNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FFormEditorNotifiers[I])^ do
        TCnWizFormEditorNotifier(Notifier)(FormEditor, NotifyType, nil, nil, '', '');
    except
      DoHandleException('TCnWizNotifierServices.FormEditorNotify[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizNotifierServices.FormEditorComponentRenamed(
  FormEditor: IOTAFormEditor; ComponentHandle: TOTAHandle; const OldName,
  NewName: string);
var
  I: Integer;
  NotifyType: TCnWizFormEditorNotifyType;
  Comp: TComponent;
  NotifyObj: TCnWizCompNotifyObj;

  function GetComponent: TComponent;
  var
    OTAComponent: IOTAComponent;
    NTAComponent: INTAComponent;
  begin
    Result := nil;
    OTAComponent := FormEditor.GetComponentFromHandle(ComponentHandle);
    QuerySvcs(OTAComponent, INTAComponent, NTAComponent);
    if Assigned(NTAComponent) then
      Result := NTAComponent.GetComponent;
  end;
begin
  if (FFormEditorNotifiers <> nil) and IsVCLFormEditor(FormEditor) then
  begin
    Comp := GetComponent;
    
    // 最初创建组件时新旧名都是空，初始化完成后新名会赋最终值
    if (OldName = '') and (NewName = '') then
      NotifyType := fetComponentCreating
    else if (OldName = '') and (NewName <> '') then
    begin
      // 组件刚创建时 Name 等属性还没有赋值，延时产生创建事件
      NotifyObj := TCnWizCompNotifyObj.Create(nil);
      NotifyObj.FormEditor := FormEditor;
      NotifyObj.NotifyType := fetComponentCreated;
      NotifyObj.ComponentHandle := ComponentHandle;
      NotifyObj.Component := Comp;
      Comp.FreeNotification(NotifyObj);
      NotifyObj.OldName := OldName;
      NotifyObj.NewName := NewName;
      FCompNotifyList.Add(NotifyObj);
  {$IFDEF DEBUG}
      CnDebugger.LogFmt('Component DelayCreated: %s --> %s.', [OldName, NewName]);
  {$ENDIF}
      Exit;
    end
    else if (OldName <> '') and (NewName = '') then
      NotifyType := fetComponentDestorying
    else
      NotifyType := fetComponentRenamed;
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('Component renamed: %s --> %s. NotifyType %d', [OldName, NewName, Integer(NotifyType)]);
  {$ENDIF}

    for I := FFormEditorNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FFormEditorNotifiers[I])^ do
        TCnWizFormEditorNotifier(Notifier)(FormEditor, NotifyType,
          ComponentHandle, Comp, OldName, NewName);
    except
      DoHandleException('TCnWizNotifierServices.FormEditorComponentRenamed[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizNotifierServices.CheckCompNotifyObj;
var
  I: Integer;
  NotifyObj: TCnWizCompNotifyObj;
begin
  if FFormEditorNotifiers <> nil then
  begin
    while FCompNotifyList.Count > 0 do
    begin
      NotifyObj := TCnWizCompNotifyObj(FCompNotifyList.Extract(FCompNotifyList.First));
      for I := FFormEditorNotifiers.Count - 1 downto 0 do
      try
        with PCnWizNotifierRecord(FFormEditorNotifiers[I])^, NotifyObj do
          TCnWizFormEditorNotifier(Notifier)(FormEditor, NotifyType,
            ComponentHandle, Component, OldName, NewName);
      except
        DoHandleException('TCnWizNotifierServices.FormEditorComponentRenamed[' + IntToStr(I) + '] at Idle.');
      end;
    end;      
  end;
end;

procedure TCnWizNotifierServices.FormEditorOpened(
  FormEditor: IOTAFormEditor);
var
  Notifier: TCnFormEditorNotifier;
begin
  FormEditorNotify(FormEditor, fetOpened);

  Notifier := TCnFormEditorNotifier.Create(Self);
  NoRefCount(Notifier.FormEditor) := NoRefCount(FormEditor);
  Notifier.NotifierIndex := FormEditor.AddNotifier(Notifier as IOTAFormNotifier);
  FFormEditorIntfs.Add(Notifier);
end;

procedure TCnWizNotifierServices.CheckNewFormEditor;
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
  Editor: IOTAEditor;
  FormEditor: IOTAFormEditor;
  I, J, K: Integer;
  Exists: Boolean;
begin
  Assert(Assigned(BorlandIDEServices));

  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  Assert(Assigned(ModuleServices));

  for I := 0 to ModuleServices.ModuleCount - 1 do
  begin
    Module := ModuleServices.Modules[I];
    for J := 0 to Module.GetModuleFileCount - 1 do
    begin
      Editor := nil;
      try
        Editor := Module.GetModuleFileEditor(J);
      except
        ;
      end;
      if Assigned(Editor) and Supports(Editor, IOTAFormEditor, FormEditor) then
      begin
        Exists := False;
        for K := 0 to FFormEditorIntfs.Count - 1 do
          if TCnFormEditorNotifier(FFormEditorIntfs[K]).FormEditor =
            FormEditor then
          begin
            Exists := True;
            Break;
          end;
          
        if not Exists then
        begin
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('New FormEditor found: ' + FormEditor.FileName);
        {$ENDIF}
          FormEditorOpened(FormEditor);
        end;
      end;
    end;
  end;
end;

procedure TCnWizNotifierServices.FormEditorFileNotification(
  NotifyCode: TOTAFileNotification; const FileName: string);
var
  I, J: Integer;
  Module: IOTAModule;
  Editor: IOTAEditor;
  FormEditor: IOTAFormEditor;
begin
  if (NotifyCode = ofnFileOpened) or (NotifyCode = ofnFileClosing) then
  begin
    Module := CnOtaGetModule(FileName);
    if not Assigned(Module) then Exit;
    for I := 0 to Module.GetModuleFileCount - 1 do
    begin
      Editor := nil;
      try
        Editor := Module.GetModuleFileEditor(I);
      except
        ;
      end;
      if Assigned(Editor) and Supports(Editor, IOTAFormEditor, FormEditor) then
        if NotifyCode = ofnFileOpened then
        begin
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('FormEditorOpened');
        {$ENDIF}
          FormEditorOpened(FormEditor);
        end
        else
        begin
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('FormEditorClosing');
        {$ENDIF}
          FormEditorNotify(FormEditor, fetClosing);
          for J := 0 to FFormEditorIntfs.Count - 1 do
          begin
            if TCnFormEditorNotifier(FFormEditorIntfs[J]).FormEditor =
              FormEditor then
            begin
            {$IFDEF DEBUG}
              CnDebugger.LogMsg('Remove FormEditorNotifier in FileNotification');
            {$ENDIF}
              TCnFormEditorNotifier(FFormEditorIntfs[J]).ClosingNotified := True;
              Break;
            end;
          end;
        end;
    end;
  end;
end;

procedure TCnWizNotifierServices.CheckDesignerSelection;
var
  I: Integer;
begin
  CnOtaGetSelectedComponentFromCurrentForm(FDesignerSelection);
  if FDesignerSelection.Count <> FLastDesignerSelection.Count then
  begin
    // 通知组件选择改变
    FormEditorNotify(CnOtaGetCurrentFormEditor, fetComponentSelectionChanged);
  end
  else
  begin
    for I := 0 to FDesignerSelection.Count - 1 do
    begin
      if FDesignerSelection[I] <> FLastDesignerSelection[I] then
      begin
        // 通知组件选择改变
        FormEditorNotify(CnOtaGetCurrentFormEditor, fetComponentSelectionChanged);
        Break;
      end;
    end;
  end;

  FLastDesignerSelection.Clear;
  for I := 0 to FDesignerSelection.Count - 1 do
    FLastDesignerSelection.Add(FDesignerSelection[I]);
end;

{$ENDIF}

//------------------------------------------------------------------------------
// ActiveControl、ActiveForm 通知
//------------------------------------------------------------------------------

procedure TCnWizNotifierServices.AddActiveControlNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizAddNotifier(FActiveControlNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.AddActiveFormNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizAddNotifier(FActiveFormNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveActiveControlNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizRemoveNotifier(FActiveControlNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveActiveFormNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizRemoveNotifier(FActiveFormNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.CheckActiveControl;
begin
  if Screen.ActiveControl <> FLastControl then
  begin
    DoActiveControlChange;
    FLastControl := Screen.ActiveControl;
  end;

  if Screen.ActiveForm <> FLastForm then
  begin
    DoActiveFormChange;
    FLastForm := Screen.ActiveForm;
  end;
end;

procedure TCnWizNotifierServices.DoActiveControlChange;
var
  I: Integer;
begin
  if not IdeClosing and (FActiveControlNotifiers <> nil) then
  begin
    for I := FActiveControlNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FActiveControlNotifiers[I])^ do
        TNotifyEvent(Notifier)(Screen.ActiveControl);
    except
      DoHandleException('TCnWizNotifierServices.DoActiveControlChange[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizNotifierServices.DoActiveFormChange;
var
  I: Integer;
begin
{$IFDEF DELPHI_OTA}
  // 由于窗体 View as Text 再打开后，原通知器就没有了，故在每次设计期窗体活跃时
  // 检查是否有新的 FormEditor 出现。
  if Assigned(Screen.ActiveCustomForm) and (csDesigning in
    Screen.ActiveCustomForm.ComponentState) then
    CheckNewFormEditor;
{$ENDIF}

  if not IdeClosing and (FActiveFormNotifiers <> nil) then
  begin
    for I := FActiveFormNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FActiveFormNotifiers[I])^ do
        TNotifyEvent(Notifier)(Screen.ActiveForm);
    except
      DoHandleException('TCnWizNotifierServices.DoActiveFormChange[' + IntToStr(I) + ']');
    end;
  end;
end;

//------------------------------------------------------------------------------
// Application Events 通知
//------------------------------------------------------------------------------

procedure TCnWizNotifierServices.AddApplicationIdleNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizAddNotifier(FApplicationIdleNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveApplicationIdleNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizRemoveNotifier(FApplicationIdleNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.AddApplicationMessageNotifier(
  Notifier: TMessageEvent);
begin
  CnWizAddNotifier(FApplicationMessageNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveApplicationMessageNotifier(
  Notifier: TMessageEvent);
begin
  CnWizRemoveNotifier(FApplicationMessageNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.AddAppEventNotifier(
  Notifier: TCnWizAppEventNotifier);
begin
  CnWizAddNotifier(FAppEventNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveAppEventNotifier(
  Notifier: TCnWizAppEventNotifier);
begin
  CnWizRemoveNotifier(FAppEventNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.DoIdleNotifiers;
var
  I: Integer;
begin
  if FIdleExecuting then Exit;
  FIdleExecuting := True;
  try
    if not IdeClosing and (FApplicationIdleNotifiers <> nil) then
    begin
      for I := FApplicationIdleNotifiers.Count - 1 downto 0 do
      try
        with PCnWizNotifierRecord(FApplicationIdleNotifiers[I])^ do
          TNotifyEvent(Notifier)(Self);
      except
        DoHandleException('TCnWizNotifierServices.DoApplicationIdle[' + IntToStr(I) + ']');
      end;
    end;
  finally
    FIdleExecuting := False;
  end;
end;

procedure TCnWizNotifierServices.DoApplicationIdle(Sender: TObject;
  var Done: Boolean);
begin
{$IFDEF DELPHI_OTA}
  CheckCompNotifyObj;
  CheckDesignerSelection;
{$ENDIF}
  DoIdleExecute;

  if Abs(GetTickCount - FLastIdleTick) > csIdleMinInterval then
  begin
    FLastIdleTick := GetTickCount;
    DoIdleNotifiers;
  end;
end;

procedure TCnWizNotifierServices.DoApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
var
  I: Integer;
begin
  CheckActiveControl;

{$IFNDEF LAZARUS}
  // FEvents.OnActivate 有可能被其它程序替换掉了，在此处进行处理
  if Msg.hwnd = Application.Handle then
  begin
    if Msg.message = CM_ACTIVATE then
      DoApplicationActivate(nil)
    else if Msg.message = CM_DEACTIVATE then
      DoApplicationDeactivate(nil);
  end;

  if not IdeClosing and (FApplicationMessageNotifiers <> nil) then
  begin
    for I := FApplicationMessageNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FApplicationMessageNotifiers[I])^ do
        TMessageEvent(Notifier)(Msg, Handled);
      if Handled then
        Break;
    except
      DoHandleException('TCnWizNotifierServices.DoApplicationMessage[' + IntToStr(I) + ']');
    end;
  end;
{$ENDIF}
end;

{$IFDEF LAZARUS}

procedure TCnWizNotifierServices.ScreenActiveFormChange(Sender: TObject);
begin
  if Screen.ActiveForm <> FLastForm then
  begin
    DoActiveFormChange;
    FLastForm := Screen.ActiveForm;
  end;

  if Assigned(FOldScreenActiveFormChange) then
    FOldScreenActiveFormChange(Sender);
end;

procedure TCnWizNotifierServices.ScreenActiveControlChange(Sender: TObject);
begin
  if Screen.ActiveControl <> FLastControl then
  begin
    DoActiveControlChange;
    FLastControl := Screen.ActiveControl;
  end;

  if Assigned(FOldScreenActiveControlChange) then
    FOldScreenActiveControlChange(Sender);
end;

procedure TCnWizNotifierServices.SourceEditorWindowCreate(Sender: TObject);
begin
  if Sender <> nil then
    CnDebugger.TraceMsg('SourceEditorWindowCreate: ' + Sender.ClassName)
  else
    CnDebugger.TraceMsg('SourceEditorWindowCreate: ');
end;

procedure TCnWizNotifierServices.SourceEditorWindowDestroy(Sender: TObject);
begin
  if Sender <> nil then
    CnDebugger.TraceMsg('SourceEditorWindowDestroy: ' + Sender.ClassName)
  else
    CnDebugger.TraceMsg('SourceEditorWindowDestroy: ');
end;

procedure TCnWizNotifierServices.SourceEditorWindowActivate(Sender: TObject);
begin
  if Sender <> nil then
    CnDebugger.TraceMsg('SourceEditorWindowActivate: ' + Sender.ClassName)
  else
    CnDebugger.TraceMsg('SourceEditorWindowActivate: ');
end;

procedure TCnWizNotifierServices.SourceEditorWindowFocused(Sender: TObject);
begin
  if Sender <> nil then
    CnDebugger.TraceMsg('SourceEditorWindowFocused: ' + Sender.ClassName)
  else
    CnDebugger.TraceMsg('SourceEditorWindowFocused: ');
end;

procedure TCnWizNotifierServices.SourceEditorWindowShow(Sender: TObject);
begin
  if Sender <> nil then
    CnDebugger.TraceMsg('SourceEditorWindowShow: ' + Sender.ClassName)
  else
    CnDebugger.TraceMsg('SourceEditorWindowShow: ');
end;

procedure TCnWizNotifierServices.SourceEditorWindowHide(Sender: TObject);
begin
  if Sender <> nil then
    CnDebugger.TraceMsg('SourceEditorWindowHide: ' + Sender.ClassName)
  else
    CnDebugger.TraceMsg('SourceEditorWindowHide: ');
end;

procedure TCnWizNotifierServices.SourceEditorCreate(Sender: TObject);
begin
{$IFDEF DEBUG}
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    CnDebugger.logMsg('SourceEditorCreate: ' + TSourceEditorInterface(Sender).FileName)
  else
    CnDebugger.LogMsg('SourceEditorCreate: ');
{$ENDIF}

  // 映射成 setOpened
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    SourceEditorNotify(TSourceEditorInterface(Sender), setOpened);
end;

procedure TCnWizNotifierServices.SourceEditorDestroy(Sender: TObject);
begin
{$IFDEF DEBUG}
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    CnDebugger.TraceMsg('SourceEditorDestroy: ' + TSourceEditorInterface(Sender).FileName)
  else
    CnDebugger.TraceMsg('SourceEditorDestroy: ');
{$ENDIF}

  // 映射成 setClosing
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    SourceEditorNotify(TSourceEditorInterface(Sender), setClosing);
end;

procedure TCnWizNotifierServices.SourceEditorOptsChanged(Sender: TObject);
begin
{$IFDEF DEBUG}
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    CnDebugger.TraceMsg('SourceEditorOptsChanged: ' + TSourceEditorInterface(Sender).FileName)
  else
    CnDebugger.TraceMsg('SourceEditorOptsChanged: ');
{$ENDIF}
end;

procedure TCnWizNotifierServices.SourceEditorActivate(Sender: TObject);
begin
{$IFDEF DEBUG}
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    CnDebugger.LogMsg('SourceEditorActivate: ' + TSourceEditorInterface(Sender).FileName)
  else
    CnDebugger.LogMsg('SourceEditorActivate: ');
{$ENDIF}

  // 映射成 EditViewActivated，注意一次切换可能 Lazarus 有多次重复调用
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    SourceEditorNotify(TSourceEditorInterface(Sender), setEditViewActivated);
end;

procedure TCnWizNotifierServices.SourceEditorStatus(Sender: TObject);
begin
{$IFDEF DEBUG}
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    CnDebugger.TraceMsg('SourceEditorStatus: ' + TSourceEditorInterface(Sender).FileName)
  else
    CnDebugger.TraceMsg('SourceEditorStatus: ');
{$ENDIF}
end;

procedure TCnWizNotifierServices.SourceEditorMouseDown(Sender: TObject);
begin
{$IFDEF DEBUG}
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    CnDebugger.TraceMsg('SourceEditorMouseDown: ' + TSourceEditorInterface(Sender).FileName)
  else
    CnDebugger.TraceMsg('SourceEditorMouseDown: ');
{$ENDIF}
end;

procedure TCnWizNotifierServices.SourceEditorMouseUp(Sender: TObject);
begin
{$IFDEF DEBUG}
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    CnDebugger.TraceMsg('SourceEditorMouseUp: ' + TSourceEditorInterface(Sender).FileName)
  else
    CnDebugger.TraceMsg('SourceEditorMouseUp: ');
{$ENDIF}
end;

procedure TCnWizNotifierServices.SourceEditorMoved(Sender: TObject);
begin
{$IFDEF DEBUG}
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    CnDebugger.TraceMsg('SourceEditorMoved: ' + TSourceEditorInterface(Sender).FileName)
  else
    CnDebugger.TraceMsg('SourceEditorMoved: ');
{$ENDIF}
end;

procedure TCnWizNotifierServices.SourceEditorCloned(Sender: TObject);
begin
{$IFDEF DEBUG}
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    CnDebugger.TraceMsg('SourceEditorCloned: ' + TSourceEditorInterface(Sender).FileName)
  else
    CnDebugger.TraceMsg('SourceEditorCloned: ');
{$ENDIF}
end;

procedure TCnWizNotifierServices.SourceEditorReConfigured(Sender: TObject);
begin
{$IFDEF DEBUG}
  if (Sender <> nil) and (Sender is TSourceEditorInterface) then
    CnDebugger.TraceMsg('SourceEditorReConfigured: ' + TSourceEditorInterface(Sender).FileName)
  else
    CnDebugger.TraceMsg('SourceEditorReConfigured: ');
{$ENDIF}
end;

{$ENDIF}

procedure TCnWizNotifierServices.AppEventNotify(EventType: TCnWizAppEventType; Data: Pointer);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  if (EventType <> aeHint) and (EventType <> aeShowHint) then // 避免打印太多
    CnDebugger.LogFmt('AppEventNotify: %s',
      [GetEnumName(TypeInfo(TCnWizAppEventType), Ord(EventType))]);
{$ENDIF}
  if not IdeClosing and (FAppEventNotifiers <> nil) then
  begin
    for I := FAppEventNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FAppEventNotifiers[I])^ do
        TCnWizAppEventNotifier(Notifier)(EventType, Data);
    except
      DoHandleException('TCnWizNotifierServices.AppEventNotify[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizNotifierServices.DoApplicationActivate(Sender: TObject);
begin
  AppEventNotify(aeActivate);
end;

procedure TCnWizNotifierServices.DoApplicationDeactivate(Sender: TObject);
begin
  AppEventNotify(aeDeactivate);
end;

procedure TCnWizNotifierServices.DoApplicationHint(Sender: TObject);
begin
  AppEventNotify(aeHint);
end;

procedure TCnWizNotifierServices.DoApplicationShowHint(var HintStr: string;
  var CanShow: Boolean; var HintInfo: THintInfo);
begin
  AppEventNotify(aeShowHint, @HintInfo);
end;

procedure TCnWizNotifierServices.DoApplicationMinimize(Sender: TObject);
begin
  AppEventNotify(aeMinimize);
end;

procedure TCnWizNotifierServices.DoApplicationRestore(Sender: TObject);
begin
  AppEventNotify(aeRestore);
end;

//------------------------------------------------------------------------------
// 空闲执行
//------------------------------------------------------------------------------

procedure TCnWizNotifierServices.ExecuteOnApplicationIdle(
  Method: TNotifyEvent);
begin
  CnWizAddNotifier(FIdleMethods, TMethod(Method));
end;

procedure TCnWizNotifierServices.StopExecuteOnApplicationIdle(Method: TNotifyEvent);
begin
  CnWizRemoveNotifier(FIdleMethods, TMethod(Method));
end;

procedure TCnWizNotifierServices.DoIdleExecute;
var
  Rec: PCnWizNotifierRecord;
  Event: TNotifyEvent;
begin
  while FIdleMethods.Count > 0 do
  begin
    Rec := FIdleMethods.Extract(FIdleMethods.Last);
    Event := TNotifyEvent(Rec^.Notifier);
    Dispose(Rec);
    try
      Event(Application);
    except
      DoHandleException('TCnWizNotifierServices.DoIdleExecute');
    end;
  end;
end;

//------------------------------------------------------------------------------
// HOOK 通知
//------------------------------------------------------------------------------

function IsMsgRegistered(MsgList: TList; Msg: Cardinal): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
var
  I: Integer;
begin
  Result := False;
  for I := 0 to MsgList.Count - 1 do
  begin
    if Msg = Cardinal(MsgList[I]) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TCnWizNotifierServices.DoMsgHook(AList, MsgList: TList; Handle: HWND;
  Msg: TMessage);
var
  I: Integer;
  Control: TWinControl;
begin
  if not IdeClosing and (AList <> nil) and IsMsgRegistered(MsgList, Msg.Msg) then
  begin
    Control := FindControl(Handle);
    for I := AList.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(AList[I])^ do
        TCnWizMsgHookNotifier(Notifier)(Handle, Control, Msg);
    except
      DoHandleException('TCnWizNotifierServices.DoMsgHook[' + IntToStr(I) + ']');
    end;
  end;
end;

function TCnWizNotifierServices.DoGetMsgHook(AList, MsgList: TList; Handle: HWND;
  Msg: TMessage): Boolean;
var
  I: Integer;
  Control: TWinControl;
begin
  Result := False;
  if not IdeClosing and (AList <> nil) and IsMsgRegistered(MsgList, Msg.Msg) then
  begin
    Control := FindControl(Handle);
    for I := AList.Count - 1 downto 0 do
    try
      // 每个都通知，但只要有一个返回 True，就吞掉此消息
      with PCnWizNotifierRecord(AList[I])^ do
        Result := Result or TCnWizGetMsgHookNotifier(Notifier)(Handle, Control, Msg);
    except
      DoHandleException('TCnWizNotifierServices.DoGetMsgHook[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizNotifierServices.AddCallWndProcNotifier(
  Notifier: TCnWizMsgHookNotifier; MsgIDs: array of Cardinal);
begin
  AddNotifierEx(FCallWndProcNotifiers, FCallWndProcMsgList, TMethod(Notifier), MsgIDs);
end;

procedure TCnWizNotifierServices.RemoveCallWndProcNotifier(
  Notifier: TCnWizMsgHookNotifier);
begin
  CnWizRemoveNotifier(FCallWndProcNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.DoCallWndProc(Handle: HWND; Msg: TMessage);
begin
  DoMsgHook(FCallWndProcNotifiers, FCallWndProcMsgList, Handle, Msg);
end;

procedure TCnWizNotifierServices.AddCallWndProcRetNotifier(
  Notifier: TCnWizMsgHookNotifier; MsgIDs: array of Cardinal);
begin
  AddNotifierEx(FCallWndProcRetNotifiers, FCallWndProcRetMsgList, TMethod(Notifier), MsgIDs);
end;

procedure TCnWizNotifierServices.RemoveCallWndProcRetNotifier(
  Notifier: TCnWizMsgHookNotifier);
begin
  CnWizRemoveNotifier(FCallWndProcRetNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.DoCallWndProcRet(Handle: HWND;
  Msg: TMessage);
begin
  DoMsgHook(FCallWndProcRetNotifiers, FCallWndProcRetMsgList, Handle, Msg);
end;

procedure TCnWizNotifierServices.AddGetMsgNotifier(
  Notifier: TCnWizGetMsgHookNotifier; MsgIDs: array of Cardinal);
begin
  AddNotifierEx(FGetMsgNotifiers, FGetMsgMsgList, TMethod(Notifier), MsgIDs);
end;

procedure TCnWizNotifierServices.RemoveGetMsgNotifier(
  Notifier: TCnWizGetMsgHookNotifier);
begin
  CnWizRemoveNotifier(FGetMsgNotifiers, TMethod(Notifier));
end;

function TCnWizNotifierServices.DoGetMsg(Handle: HWND; Msg: TMessage): Boolean;
begin
  Result := DoGetMsgHook(FGetMsgNotifiers, FGetMsgMsgList, Handle, Msg);
end;

procedure TCnWizNotifierServices.AddAfterThemeChangeNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizAddNotifier(FAfterThemeChangeNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.AddBeforeThemeChangeNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizAddNotifier(FBeforeThemeChangeNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveAfterThemeChangeNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizRemoveNotifier(FAfterThemeChangeNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveBeforeThemeChangeNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizRemoveNotifier(FBeforeThemeChangeNotifiers, TMethod(Notifier));
end;

{$IFDEF DELPHI_OTA}

procedure TCnWizNotifierServices.BreakpointAdded(
  Breakpoint: IOTABreakpoint);
var
  I: Integer;
begin
  if FBreakpointAddedNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifier.Breakpoint Added');
{$ENDIF}
    for I := FBreakpointAddedNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FBreakpointAddedNotifiers[I])^ do
        TCnWizBreakpointNotifier(Notifier)(Breakpoint);
    except
      DoHandleException('TCnWizNotifierServices.BreakpointAdded[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizNotifierServices.BreakpointDeleted(
  Breakpoint: IOTABreakpoint);
var
  I: Integer;
begin
  if FBreakpointDeletedNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifier.Breakpoint Deleted');
{$ENDIF}
    for I := FBreakpointDeletedNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FBreakpointDeletedNotifiers[I])^ do
        TCnWizBreakpointNotifier(Notifier)(Breakpoint);
    except
      DoHandleException('TCnWizNotifierServices.BreakpointDeleted[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizNotifierServices.ProcessCreated(Process: IOTAProcess);
var
  I: Integer;
begin
  if FProcessCreatedNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifier.Process Created');
{$ENDIF}
    for I := FProcessCreatedNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FProcessCreatedNotifiers[I])^ do
        TCnWizProcessNotifier(Notifier)(Process);
    except
      DoHandleException('TCnWizNotifierServices.ProcessCreated[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizNotifierServices.ProcessDestroyed(Process: IOTAProcess);
var
  I: Integer;
begin
  if FProcessDestroyedNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifier.Process Destroyed');
{$ENDIF}
    for I := FProcessDestroyedNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FProcessDestroyedNotifiers[I])^ do
        TCnWizProcessNotifier(Notifier)(Process);
    except
      DoHandleException('TCnWizNotifierServices.ProcessDestroyed[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizNotifierServices.AddBreakpointAddedNotifier(
  Notifier: TCnWizBreakpointNotifier);
begin
  CnWizAddNotifier(FBreakpointAddedNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.AddBreakpointDeletedNotifier(
  Notifier: TCnWizBreakpointNotifier);
begin
  CnWizAddNotifier(FBreakpointDeletedNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.AddProcessCreatedNotifier(
  Notifier: TCnWizProcessNotifier);
begin
  CnWizAddNotifier(FProcessCreatedNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.AddProcessDestroyedNotifier(
  Notifier: TCnWizProcessNotifier);
begin
  CnWizAddNotifier(FProcessDestroyedNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveBreakpointAddedNotifier(
  Notifier: TCnWizBreakpointNotifier);
begin
  CnWizRemoveNotifier(FBreakpointAddedNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveBreakpointDeletedNotifier(
  Notifier: TCnWizBreakpointNotifier);
begin
  CnWizRemoveNotifier(FBreakpointDeletedNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveProcessCreatedNotifier(
  Notifier: TCnWizProcessNotifier);
begin
  CnWizRemoveNotifier(FProcessCreatedNotifiers, TMethod(Notifier));
end;

procedure TCnWizNotifierServices.RemoveProcessDestroyedNotifier(
  Notifier: TCnWizProcessNotifier);
begin
  CnWizRemoveNotifier(FProcessDestroyedNotifiers, TMethod(Notifier));
end;

function TCnWizNotifierServices.GetCurrentCompilingProject: IOTAProject;
begin
  Result := FCurrentCompilingProject;
end;

{$ENDIF}

procedure TCnWizNotifierServices.DoAfterThemeChange;
var
  I: Integer;
begin
  if FAfterThemeChangeNotifiers <> nil then
  begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnWizNotifierServices.DoAfterThemeChange');
{$ENDIF}
    for I := FAfterThemeChangeNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FAfterThemeChangeNotifiers[I])^ do
        TNotifyEvent(Notifier)(Self);
    except
      DoHandleException('TCnWizNotifierServices.DAfterThemeChange[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizNotifierServices.DoBeforeThemeChange;
var
  I: Integer;
begin
  if FBeforeThemeChangeNotifiers <> nil then
  begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnWizNotifierServices.DoBeforeThemeChange');
{$ENDIF}
    for I := FBeforeThemeChangeNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FBeforeThemeChangeNotifiers[I])^ do
        TNotifyEvent(Notifier)(Self);
    except
      DoHandleException('TCnWizNotifierServices.DoBeforeThemeChange[' + IntToStr(I) + ']');
    end;
  end;
end;

{$IFDEF DELPHI_OTA}

{ TCnWizDebuggerNotifier }

constructor TCnWizDebuggerNotifier.Create(ANotifierServices: TCnWizNotifierServices);
begin
  inherited Create;
  FNotifierServices := ANotifierServices;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnWizDebuggerNotifier.Create succeed');
{$ENDIF}
end;

destructor TCnWizDebuggerNotifier.Destroy;
begin

  inherited;
end;

procedure TCnWizDebuggerNotifier.BreakpointAdded({$IFDEF COMPILER9_UP}const {$ENDIF}Breakpoint: IOTABreakpoint);
begin
  FNotifierServices.BreakpointAdded(Breakpoint);
end;

procedure TCnWizDebuggerNotifier.BreakpointDeleted({$IFDEF COMPILER9_UP}const {$ENDIF}Breakpoint: IOTABreakpoint);
begin
  FNotifierServices.BreakpointDeleted(Breakpoint);
end;

procedure TCnWizDebuggerNotifier.ProcessCreated({$IFDEF COMPILER9_UP}const {$ENDIF}Process: IOTAProcess);
begin
  FNotifierServices.ProcessCreated(Process);
end;

procedure TCnWizDebuggerNotifier.ProcessDestroyed({$IFDEF COMPILER9_UP}const {$ENDIF}Process: IOTAProcess);
begin
  FNotifierServices.ProcessDestroyed(Process);
end;

{$IFDEF IDE_SUPPORT_THEMING}
{$IFNDEF CNWIZARDS_MINIMUM}

{ TCnIDEThemingServicesNotifier }

procedure TCnIDEThemingServicesNotifier.AfterSave;
begin

end;

procedure TCnIDEThemingServicesNotifier.BeforeSave;
begin

end;

procedure TCnIDEThemingServicesNotifier.ChangedTheme;
begin
  FNotifierServices.DoAfterThemeChange;
end;

procedure TCnIDEThemingServicesNotifier.ChangingTheme;
begin
  FNotifierServices.DoBeforeThemeChange;
end;

constructor TCnIDEThemingServicesNotifier.Create(
  ANotifierServices: TCnWizNotifierServices);
begin
  inherited Create;
  FNotifierServices := ANotifierServices;
end;

destructor TCnIDEThemingServicesNotifier.Destroy;
begin

  inherited;
end;

procedure TCnIDEThemingServicesNotifier.Destroyed;
begin

end;

procedure TCnIDEThemingServicesNotifier.Modified;
begin

end;

{$ENDIF}
{$ENDIF}
{$ENDIF}

initialization
{$IFDEF DELPHI102_TOKYO}
{$IFNDEF CNWIZARDS_MINIMUM}
  if IsDelphi10Dot2GEDot2 then
    ChangeIntfGUID(TCnIDEThemingServicesNotifier, ICnNTAIDEThemingServicesNotifier,
      StringToGUID(GUID_INTAIDETHEMINGSERVICESNOTIFIER));
{$ENDIF}
{$ENDIF}

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnWizNotifier finalization.');
{$ENDIF}

  FreeCnWizNotifierServices;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnWizNotifier finalization.');
{$ENDIF}
end.

