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

unit CnWizNotifier;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE ֪ͨ����Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ�ṩ�� IDE ֪ͨ�¼�����
* ����ƽ̨��PWin2000Pro + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.04.09
*               GetMsgHook ����������Ϣ
*           2018.03.20
*               ���� IDE �����л�֪ͨ����
*           2008.05.05
*               ���� StopExecuteOnApplicationIdle ����
*           2006.10.06
*               ���� Debug ���̺Ͷϵ���¼�֪ͨ����
*           2005.05.06
*               hubdog ���ӱ����¼�֪ͨ����
*           2004.01.09
*               LiuXiao ���� BCB 5 �´򿪵��� Unit ʱ�Ĵ���
*           2003.09.29
*               ���� Application OnIdle��OnMessage ֪ͨ
*           2003.05.04
*               ������������
*           2003.04.28
*               �����˴���༭��֪ͨ������ǿ����༭��֪ͨ����
*           2002.11.22
*               ������Ԫ
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

  NoRefCount = Pointer; // ʹ��ָ��������ǿ��Ϊ�ӿڱ�����ֵ�����������ü���

  TCnWizSourceEditorNotifyType = (setOpened, setClosing, setModified,
    setEditViewInsert, setEditViewRemove, setEditViewActivated);
  {* SourceEditor ֪ͨ���ͣ�Lazarus ���иı����װ��ӳ�䱣��һ��}

  TCnWizSourceEditorNotifier = procedure (SourceEditor: TCnSourceEditorInterface;
    NotifyType: TCnWizSourceEditorNotifyType {$IFDEF DELPHI_OTA}; EditView: IOTAEditView {$ENDIF}) of object;
  {* SourceEditor ֪ͨ�¼���SourceEditor ΪԴ��༭���ӿڣ�NotifyType Ϊ����}

{$IFDEF DELPHI_OTA}

  TCnWizFileNotifier = procedure (NotifyCode: TOTAFileNotification;
    const FileName: string) of object;
  {* IDE �ļ�֪ͨ�¼���NotifyCode Ϊ֪ͨ���ͣ�FileName Ϊ�ļ���}

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
  {* ��� GetMsg �� Hook �Ĵ���֪ͨ������ True ��ʾ�̵�����Ϣ}

  ICnWizNotifierServices = interface(IUnknown)
  {* IDE ֪ͨ����ӿ�}
    ['{18C4DD6A-802A-48D7-AC93-A2487411CA79}']

{$IFDEF DELPHI_OTA}

    procedure AddFileNotifier(Notifier: TCnWizFileNotifier);
    {* ����һ���ļ�֪ͨ�¼�}
    procedure RemoveFileNotifier(Notifier: TCnWizFileNotifier);
    {* ɾ��һ���ļ�֪ͨ�¼�}
    
    procedure AddBeforeCompileNotifier(Notifier:TCnWizBeforeCompileNotifier);
    {* ����һ������ǰ֪ͨ�¼�}
    procedure RemoveBeforeCompileNotifier(Notifier:TCnWizBeforeCompileNotifier);
    {* ɾ��һ������ǰ֪ͨ�¼�}

    procedure AddAfterCompileNotifier(Notifier:TCnWizAfterCompileNotifier);
    {* ����һ�������֪ͨ�¼�}
    procedure RemoveAfterCompileNotifier(Notifier:TCnWizAfterCompileNotifier);
    {* ɾ��һ�������֪ͨ�¼�}

    procedure AddFormEditorNotifier(Notifier: TCnWizFormEditorNotifier);
    {* ����һ������༭��֪ͨ�¼�}
    procedure RemoveFormEditorNotifier(Notifier: TCnWizFormEditorNotifier);
    {* ɾ��һ������༭��֪ͨ�¼�}

    procedure AddProcessCreatedNotifier(Notifier: TCnWizProcessNotifier);
    {* ����һ�������Խ���������֪ͨ�¼�}
    procedure RemoveProcessCreatedNotifier(Notifier: TCnWizProcessNotifier);
    {* ɾ��һ�������Խ���������֪ͨ�¼�}
    procedure AddProcessDestroyedNotifier(Notifier: TCnWizProcessNotifier);
    {* ����һ�������Խ�����ֹ��֪ͨ�¼�}
    procedure RemoveProcessDestroyedNotifier(Notifier: TCnWizProcessNotifier);
    {* ɾ��һ�������Խ�����ֹ��֪ͨ�¼�}

    procedure AddBreakpointAddedNotifier(Notifier: TCnWizBreakpointNotifier);
    {* ����һ�����Ӷϵ��֪ͨ�¼�}
    procedure RemoveBreakpointAddedNotifier(Notifier: TCnWizBreakpointNotifier);
    {* ɾ��һ�����Ӷϵ��֪ͨ�¼�}
    procedure AddBreakpointDeletedNotifier(Notifier: TCnWizBreakpointNotifier);
    {* ����һ��ɾ���ϵ��֪ͨ�¼�}
    procedure RemoveBreakpointDeletedNotifier(Notifier: TCnWizBreakpointNotifier);
    {* ɾ��һ��ɾ���ϵ��֪ͨ�¼�}

    function GetCurrentCompilingProject: IOTAProject;
    {* ��ȡ��ǰ���ڱ���Ĺ��̡����ǵ�ǰ���̣�ʹ��֪ͨ�ڼ�¼����}

{$ENDIF}

    procedure AddSourceEditorNotifier(Notifier: TCnWizSourceEditorNotifier);
    {* ����һ��Դ����༭��֪ͨ�¼�}
    procedure RemoveSourceEditorNotifier(Notifier: TCnWizSourceEditorNotifier);
    {* ɾ��һ��Դ����༭��֪ͨ�¼�}

    procedure AddActiveFormNotifier(Notifier: TNotifyEvent);
    {* ����һ�������Ծ֪ͨ�¼�}
    procedure RemoveActiveFormNotifier(Notifier: TNotifyEvent);
    {* ɾ��һ�������Ծ֪ͨ�¼�}

    procedure AddActiveControlNotifier(Notifier: TNotifyEvent);
    {* ����һ���ؼ���Ծ֪ͨ�¼�}
    procedure RemoveActiveControlNotifier(Notifier: TNotifyEvent);
    {* ɾ��һ���ؼ���Ծ֪ͨ�¼�}

    procedure AddApplicationIdleNotifier(Notifier: TNotifyEvent);
    {* ����һ��Ӧ�ó������֪ͨ�¼�}
    procedure RemoveApplicationIdleNotifier(Notifier: TNotifyEvent);
    {* ɾ��һ��Ӧ�ó������֪ͨ�¼�}

    procedure AddApplicationMessageNotifier(Notifier: TMessageEvent);
    {* ����һ��Ӧ�ó�����Ϣ֪ͨ�¼���Lazarus ����ʱ��Ч}
    procedure RemoveApplicationMessageNotifier(Notifier: TMessageEvent);
    {* ɾ��һ��Ӧ�ó�����Ϣ֪ͨ�¼���Lazarus ����ʱ��Ч}

    procedure AddAppEventNotifier(Notifier: TCnWizAppEventNotifier);
    {* ����һ��Ӧ�ó����¼�֪ͨ�¼�}
    procedure RemoveAppEventNotifier(Notifier: TCnWizAppEventNotifier);
    {* ɾ��һ��Ӧ�ó����¼�֪ͨ�¼�}

    procedure AddCallWndProcNotifier(Notifier: TCnWizMsgHookNotifier; MsgIDs: array of Cardinal);
    {* ����һ�� CallWndProc HOOK ֪ͨ�¼�}
    procedure RemoveCallWndProcNotifier(Notifier: TCnWizMsgHookNotifier);
    {* ɾ��һ�� CallWndProc HOOK ֪ͨ�¼�}

    procedure AddCallWndProcRetNotifier(Notifier: TCnWizMsgHookNotifier; MsgIDs: array of Cardinal);
    {* ����һ�� CallWndProcRet HOOK ֪ͨ�¼�}
    procedure RemoveCallWndProcRetNotifier(Notifier: TCnWizMsgHookNotifier);
    {* ɾ��һ�� CallWndProcRet HOOK ֪ͨ�¼�}

    procedure AddGetMsgNotifier(Notifier: TCnWizGetMsgHookNotifier; MsgIDs: array of Cardinal);
    {* ����һ�� GetMessage HOOK ֪ͨ�¼�}
    procedure RemoveGetMsgNotifier(Notifier: TCnWizGetMsgHookNotifier);
    {* ɾ��һ�� GetMessage HOOK ֪ͨ�¼�}

    procedure AddBeforeThemeChangeNotifier(Notifier: TNotifyEvent);
    {* ����һ�� IDE ����仯ǰ��֪ͨ�¼�}
    procedure RemoveBeforeThemeChangeNotifier(Notifier: TNotifyEvent);
    {* ɾ��һ�� IDE ����仯ǰ��֪ͨ�¼�}
    procedure AddAfterThemeChangeNotifier(Notifier: TNotifyEvent);
    {* ����һ�� IDE ����仯���֪ͨ�¼�}
    procedure RemoveAfterThemeChangeNotifier(Notifier: TNotifyEvent);
    {* ɾ��һ�� IDE ����仯���֪ͨ�¼�}

    procedure ExecuteOnApplicationIdle(Method: TNotifyEvent);
    {* ��һ��������Ӧ�ó������ʱִ��}
    procedure StopExecuteOnApplicationIdle(Method: TNotifyEvent);
    {* ��һ���Ѿ�����Ϊ����ʱִ�еķ�������ִ��ǰִֹ֪ͨͣ�У�����ִ����˵�����Ч}
  end;

function CnWizNotifierServices: ICnWizNotifierServices;
{* ��ȡ IDE ֪ͨ����ӿ�}

procedure CnWizClearAndFreeList(var List: TList);
{* ȫ���ͷ�֪ͨ���Ĺ��ú���}

procedure CnWizAddNotifier(List: TList; Notifier: TMethod);
{* ����֪ͨ�����ú���}

procedure CnWizRemoveNotifier(List: TList; Notifier: TMethod);
{* ɾ��֪ͨ�����ú���}

function CnWizIndexOfNotifier(List: TList; Notifier: TMethod): Integer;
{* ����֪ͨ�����ú���}

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
// IDE ֪ͨ���ࣨ˽���ࣩ
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
// SourceEditor ֪ͨ���ࣨ˽���ࣩ
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
// FormEditor ֪ͨ���ࣨ˽���ࣩ
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

{$IFNDEF CNWIZARDS_MINIMUM} // Minimum �����²�֧�֣�Ҳ����˵��� 10.2��ֻ���� 10.2.3 �¼���

//==============================================================================
// IDE Theming Notifier ֪ͨ���ࣨ˽���ࣩ
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
// DebuggerNotifier ֪ͨ���ࣨ˽���ࣩ
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
// ���֪ͨ����
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
// ֪ͨ�������ࣨ˽���ࣩ
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

    // EditorWindow ϵ�У�Sender �� TSourceNoteBook
    procedure SourceEditorWindowCreate(Sender: TObject);
    procedure SourceEditorWindowDestroy(Sender: TObject);
    procedure SourceEditorWindowActivate(Sender: TObject);
    procedure SourceEditorWindowFocused(Sender: TObject);
    procedure SourceEditorWindowShow(Sender: TObject);
    procedure SourceEditorWindowHide(Sender: TObject);
    // Editor ϵ�У�Sender �� TSourceEditor �� nil��Ŀǰ����ȥ�� Activate �п��� nil��
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
  IdeClosing: Boolean = False; // ��������ʱ�޴˱�����ð��һ��


// ��������ʱ�޴˷�����Ҳð��һ��������һЩִ�з����е��쳣
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
// IDE ֪ͨ���ࣨ˽���ࣩ
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
// SourceEditor ֪ͨ���ࣨ˽���ࣩ
//==============================================================================

// �� IDE ��ֱ�Ӵ򿪻�رյ�����Ԫʱ��ͨ�� IDE �ļ�֪ͨ���Ի�� SourceEditor��
// ���� EditViewCount Ϊ 1��
// �����ڴ򿪹���ʱ��IDE �ļ�֪ͨ��õ� SourceEditor �� EditViewCount Ϊ 0������
// �ڹرչ���ʱ����������� IDE �ļ�֪ͨ��
// �ʶ�ÿһ�� SourceEditor ע��һ�� Notifier������ļ���ʱ��EditViewCount Ϊ 0��
// ���� Notifier �м�� EditView ���������� SourceEditor Opened ֪ͨ��
// ����ļ������رգ��� IDE �ļ�֪ͨ�в��� SourceEditor Closing ֪ͨ����֮ͨ��
// Notifier �� SourceEditor Destroyed ʱ���� Closing ֪ͨ��

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
// FormEditor ֪ͨ���ࣨ˽���ࣩ
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
// ���֪ͨ����
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

      // ����д����������� True�����̵�����Ϣ
      if FCnWizNotifierServices.DoGetMsg(PMsg(lParam)^.hwnd, Msg) then
        PMsg(lParam)^.message := WM_NULL;
    end;
  end;

  Result := CallNextHookEx(GetMsgHook, nCode, wParam, lParam);
end;

//==============================================================================
// ֪ͨ�������ࣨ˽���ࣩ
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
  if Supports(BorlandIDEServices, StringToGUID(GUID_IOTAIDETHEMINGSERVICES), ThemingService) then // ò�� 10.2.2 ������֧�֣�10.2.1 δ֪
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
// �б����
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
// IDE �ļ�֪ͨ
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
    Exit; // BCB ���������ļ���������

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
// ����֪ͨ
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
// SourceEditor ֪ͨ
//------------------------------------------------------------------------------

procedure TCnWizNotifierServices.SourceEditorOpened(
  SourceEditor: IOTASourceEditor; CalledByNotifier: Boolean);
var
  Notifier: TCnSourceEditorNotifier;
begin
{$IFDEF COMPILER5}
  // D5 �����Ϊ���ļ�ע��֪ͨ�������ͷ�ʱ���ܻ���쳣
  if IsPackage(SourceEditor.FileName) then
    Exit;
{$ENDIF COMPILER5}

  if SourceEditor.GetEditViewCount > 0 then
  begin
    SourceEditorNotify(SourceEditor, setOpened);

    // ���������֪ͨ�����õģ�����һ��֪ͨ������ñ༭���ر�ʱ��֪ͨ
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
    // ��һ������ʱ��SourceEditor ��û�� View �ģ��ʴ���һ��֪ͨ����
    // SourceEditor ������һ�� View ʱ���֪ͨ
    Notifier := TCnSourceEditorNotifier.Create(Self);
    Notifier.OpenedNotified := False;
    // ���������ü����±���ӿڣ�����ر�ʱ�����
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
        // BCB 5 �е��ô˺������ܻ�����ʳ�ͻ�����Դ������Σ��������ơ�
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
// FormEditor ֪ͨ
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
    
    // ����������ʱ�¾������ǿգ���ʼ����ɺ������ḳ����ֵ
    if (OldName = '') and (NewName = '') then
      NotifyType := fetComponentCreating
    else if (OldName = '') and (NewName <> '') then
    begin
      // ����մ���ʱ Name �����Ի�û�и�ֵ����ʱ���������¼�
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
    // ֪ͨ���ѡ��ı�
    FormEditorNotify(CnOtaGetCurrentFormEditor, fetComponentSelectionChanged);
  end
  else
  begin
    for I := 0 to FDesignerSelection.Count - 1 do
    begin
      if FDesignerSelection[I] <> FLastDesignerSelection[I] then
      begin
        // ֪ͨ���ѡ��ı�
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
// ActiveControl��ActiveForm ֪ͨ
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
  // ���ڴ��� View as Text �ٴ򿪺�ԭ֪ͨ����û���ˣ�����ÿ������ڴ����Ծʱ
  // ����Ƿ����µ� FormEditor ���֡�
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
// Application Events ֪ͨ
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
  // FEvents.OnActivate �п��ܱ����������滻���ˣ��ڴ˴����д���
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

  // ӳ��� setOpened
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

  // ӳ��� setClosing
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

  // ӳ��� EditViewActivated��ע��һ���л����� Lazarus �ж���ظ�����
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
  if (EventType <> aeHint) and (EventType <> aeShowHint) then // �����ӡ̫��
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
// ����ִ��
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
// HOOK ֪ͨ
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
      // ÿ����֪ͨ����ֻҪ��һ������ True�����̵�����Ϣ
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

