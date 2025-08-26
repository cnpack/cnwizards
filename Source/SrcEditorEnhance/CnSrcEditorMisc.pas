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

unit CnSrcEditorMisc;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭����չ�������ߵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.10.25
*               �������� Delphi 10 Seattle �µı༭����������ѡ��
*           2004.12.25
*               ������Ԫ����ԭ CnEditorEnhancements �Ƴ�
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, ToolsAPI,
  Contnrs, IniFiles, Forms, ExtCtrls, Menus, ComCtrls, TypInfo, Math, FileCtrl,
  Clipbrd, CnCommon, CnWizUtils, CnConsts, CnWizIdeUtils, CnWizConsts, CnWizManager,
  CnMenuHook, CnWizNotifier, CnEditControlWrapper, CnShellUtils, CnWizClasses,
  CnEventBus;

type
  TCnSrcEditorMisc = class;

  TCnInputHelperShortCutReceiver = class(TInterfacedObject, ICnEventBusReceiver)
  private
    FMisc: TCnSrcEditorMisc;
  public
    constructor Create(AMisc: TCnSrcEditorMisc);
    destructor Destroy; override;

    procedure OnEvent(Event: TCnEvent);
  end;

//==============================================================================
// ����༭����չ��������
//==============================================================================

{ TCnSrcEditorMisc }

  TCnSrcEditorMisc = class(TObject)
  private
    FEditorMenuImageListIsMain: Boolean;
    FTabControlList: TComponentList;
    FMenuHook: TCnMenuHook;
  {$IFDEF COMPILER6_UP}
    FMenuHookTabPopup: TCnMenuHook;
  {$ENDIF COMPILER6_UP}
    FExploreMenu: TCnMenuItemDef;
    FSelAllMenu: TCnMenuItemDef;
    FThumbnailMenu: TCnMenuItemDef;
    FBlockToolsMenu: TCnMenuItemDef;
    FBlockToolMenuItem: TMenuItem;
    FCloseOtherPagesMenu: TCnMenuItemDef;
    FShellMenu: TCnMenuItemDef;
    FCopyFileNameMenu: TCnMenuItemDef;
  {$IFDEF COMPILER6_UP}
    {$IFNDEF BDS4_UP}
    FCloseOtherPagesMenu1: TCnMenuItemDef;
    {$ENDIF}
    FShellMenu1: TCnMenuItemDef;
    FCopyFileNameMenu1: TCnMenuItemDef;
    FExploreMenu1: TCnMenuItemDef;
  {$ENDIF COMPILER6_UP}

    FTabModifyTimer: TTimer;
    FDblClickClosePage: Boolean;
    FRClickShellMenu: Boolean;
    FInputHelperReceiver: ICnEventBusReceiver;
    FChangeCodeComKey: Boolean;
    FCodeCompletionKey: TShortCut;
    FAutoReadOnly: Boolean;
    FReadOnlyDirs: TStrings;
    FActualDirs: TStrings;
    FActive: Boolean;
    FDispModifiedInTab: Boolean;
    FAddMenuBlockTools: Boolean;
    FAutoSave: Boolean;
    FSaveInterval: Integer;
    FAutoSaveTimer: TTimer;
    FEditorTabMultiLine: Boolean;
    FEditorTabFlatButtons: Boolean;
    FExploreCmdLine: string;
    FHideOrigToolbar: Boolean;
    function GetBoolean(const Index: Integer): Boolean;
    procedure SetBoolean(const Index: Integer; const Value: Boolean);
    procedure RegisterUserMenuItems;
    procedure RegisterMenuExecutor(Sender: TObject);
    procedure OnSourceEditorNotify(SourceEditor: IOTASourceEditor;
      NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
{$IFNDEF BDS4_UP}
    procedure DoClosePage(Sender: TObject);
{$ENDIF}
    procedure OnExploreMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure DoCloseOtherPages(Sender: TObject);
    procedure OnCloseOtherPages(Sender: TObject);
    procedure OnShellMenu(Sender: TObject);
    procedure OnCopyFileName(Sender: TObject);
    procedure OnBlockToolsMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure OnSelectAll(Sender: TObject);
    procedure OnThumbnailClick(Sender: TObject);
    procedure OnThumbnailMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure OnExplore(Sender: TObject);
    procedure SetChangeCodeComKey(const Value: Boolean);
    procedure UpdateCodeCompletionHotKey;

    procedure SetCodeCompletionKey(const Value: TShortCut);
    procedure SetAutoReadOnly(const Value: Boolean);
    procedure SetReadOnlyDirs(const Value: TStrings);
    procedure SynchronizeDirs;
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
    procedure OnAppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure DoUpdateTabControlCaption(ClearFlag: Boolean);
    procedure UpdateTabControlCaption(Sender: TObject);
    procedure AutoSaveOnTimer(Sender: TObject);
    procedure SetDispModifiedInTab(const Value: Boolean);
    procedure SetAddMenuBlockTools(const Value: Boolean);
    procedure SetAutoSave(const Value: Boolean);
    procedure SetSaveInterval(const Value: Integer);
  protected
    procedure SetActive(Value: Boolean);
    procedure UpdateAutoSaveTimer;
    class procedure ResizeTabControl(Sender: TObject);
    procedure CodeCompletionKeyProc(Sender: TObject);
    procedure DoUpdateInstall(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure UpdateInstall;
    procedure UpdateTab(Tab: TTabControl);
    procedure UpdateEditorTabStyle;

    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    procedure ResetSettings(Ini: TCustomIniFile);
    procedure LanguageChanged(Sender: TObject);

{$IFDEF DELPHI10_SEATTLE_UP}
    procedure CheckAndHideOrigToolbar(Sender: TObject);
    procedure OrigToolbarClose(Sender: TObject);
{$ENDIF}

    // Called by Event Bus
    procedure CheckCodeCompDisabled(InputHelperKey: TShortCut);

    property DblClickClosePage: Boolean read FDblClickClosePage write FDblClickClosePage;
    property RClickShellMenu: Boolean read FRClickShellMenu write FRClickShellMenu;
    property EditorTabMultiLine: Boolean read FEditorTabMultiLine write FEditorTabMultiLine;
    property EditorTabFlatButton: Boolean read FEditorTabFlatButtons write FEditorTabFlatButtons;
    property AddMenuCloseOtherPages: Boolean index 0 read GetBoolean write SetBoolean;
    property AddMenuSelAll: Boolean index 1 read GetBoolean write SetBoolean;
    property AddMenuExplore: Boolean index 2 read GetBoolean write SetBoolean;
    property AddMenuShell: Boolean index 3 read GetBoolean write SetBoolean;
    property AddMenuCopyFileName: Boolean index 4 read GetBoolean write SetBoolean;
    property AddMenuBlockTools: Boolean read FAddMenuBlockTools write SetAddMenuBlockTools;
    property ChangeCodeComKey: Boolean read FChangeCodeComKey write SetChangeCodeComKey;
    property CodeCompletionKey: TShortCut read FCodeCompletionKey write SetCodeCompletionKey;
    property AutoReadOnly: Boolean read FAutoReadOnly write SetAutoReadOnly;
    property ReadOnlyDirs: TStrings read FReadOnlyDirs write SetReadOnlyDirs;
    property DispModifiedInTab: Boolean read FDispModifiedInTab write SetDispModifiedInTab;
    property AutoSave: Boolean read FAutoSave write SetAutoSave;
    property SaveInterval: Integer read FSaveInterval write SetSaveInterval;
    property ExploreCmdLine: string read FExploreCmdLine write FExploreCmdLine;
    property HideOrigToolbar: Boolean read FHideOrigToolbar write FHideOrigToolbar;

    property Active: Boolean read FActive write SetActive;
  end;

const
  csDefExploreCmdLine = 'EXPLORER.EXE /e, /select, "%s"';

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
{$IFDEF DELPHIXE2_UP}
  Rtti,
{$ENDIF}
  CnSrcEditorEnhance, {$IFDEF CNWIZARDS_CNPROCLISTWIZARD} CnProcListWizard, {$ENDIF}
  CnWizOptions, CnWizShortCut, CnNative;

const
  SCnCodeCompletion = 'CnCodeCompletion';
{$IFDEF DELPHI}
  SCnReadOnlyDirsFile = 'ReadOnlyDirs.dat';
{$ELSE}
  SCnReadOnlyDirsFile = 'ReadOnlyDirs_CB.dat';
{$ENDIF}

var
  TabCtrlHeight: Integer = 0;

//==============================================================================
// ����༭����չ��
//==============================================================================

{ TCnSrcEditorMisc }

constructor TCnSrcEditorMisc.Create;
begin
  inherited;
  FTabControlList := TComponentList.Create;
  
  FMenuHook := TCnMenuHook.Create(nil);
{$IFDEF COMPILER6_UP}
  FMenuHookTabPopup := TCnMenuHook.Create(nil);
{$ENDIF COMPILER6_UP}
  FReadOnlyDirs := TStringList.Create;
  FActualDirs := TStringList.Create;
  RegisterUserMenuItems;

  FTabModifyTimer := TTimer.Create(nil);
  FTabModifyTimer.Interval := 200;
  FTabModifyTimer.OnTimer := UpdateTabControlCaption;
  FTabModifyTimer.Enabled := True;

  FAutoSaveTimer := TTimer.Create(nil);
  FAutoSaveTimer.OnTimer := AutoSaveOnTimer;

  CnWizNotifierServices.AddApplicationMessageNotifier(OnAppMessage);
  CnWizNotifierServices.AddSourceEditorNotifier(OnSourceEditorNotify);
  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  UpdateInstall;

  FInputHelperReceiver := TCnInputHelperShortCutReceiver.Create(Self);
  EventBus.RegisterReceiver(FInputHelperReceiver, EVENT_INPUTHELPER_POPUP_SHORTCUT_CHANGED);

  CnWizNotifierServices.ExecuteOnApplicationIdle(RegisterMenuExecutor);
end;

destructor TCnSrcEditorMisc.Destroy;
begin
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  CnWizNotifierServices.RemoveApplicationMessageNotifier(OnAppMessage);
  CnWizNotifierServices.RemoveSourceEditorNotifier(OnSourceEditorNotify);

  EventBus.UnRegisterReceiver(FInputHelperReceiver);
  FTabModifyTimer.Free;
  FAutoSaveTimer.Free;
  FActualDirs.Free;
  FReadOnlyDirs.Free;
  FMenuHook.Free;
{$IFDEF COMPILER6_UP}
  FMenuHookTabPopup.Free;
{$ENDIF COMPILER6_UP}
  FTabControlList.Free;

  inherited;
end;

//------------------------------------------------------------------------------
// �༭�����ڿؼ��ҽ�
//------------------------------------------------------------------------------

type
  TControlHack = class(TControl);

procedure TCnSrcEditorMisc.DoUpdateInstall(EditWindow: TCustomForm;
  EditControl: TControl; Context: Pointer);
var
  PopupMenu: TPopupMenu;
  TabControl: TControl;
  TabCtrlPanelComp: TComponent;
  TabCtrlPanel: TPanel;
{$IFDEF COMPILER6}
  CodePanel: TPanel;
{$ENDIF}
begin
  // �ҽӱ༭���Ҽ��˵�
  PopupMenu := TControlHack(EditControl).PopupMenu;
  if not FMenuHook.IsHooked(PopupMenu) then
  begin
    FMenuHook.HookMenu(PopupMenu);
    if PopupMenu.Images = nil then
    begin
      PopupMenu.Images := GetIDEImageList;
      FEditorMenuImageListIsMain := True;
    end
    else
      FEditorMenuImageListIsMain := (PopupMenu.Images = GetIDEImageList);

  {$IFDEF DEBUG}
    CnDebugger.LogFmt('Hooked a EditControl''s PopupMenu. ImageList is IDE? %d',
      [Integer(FEditorMenuImageListIsMain)]);
  {$ENDIF}
  end;

  TabControl := TControl(FindComponentByClassName(EditWindow,
    SCnXTabControlClassName, SCnXTabControlName));
  if Assigned(TabControl) then
  begin
    if TabCtrlHeight = 0 then
    begin
      // �뷨��� TabCtrl ��ԭʼ�߶�
      TabCtrlPanelComp := EditWindow.FindComponent(SCnTabControlPanelName);
      if (TabCtrlPanelComp <> nil) and (TabCtrlPanelComp is TPanel) then
      begin
        TabCtrlPanel := TabCtrlPanelComp as TPanel;
        TabCtrlHeight := TabCtrlPanel.Height;
        if TabCtrlPanel.Align <> alTop then
          TabCtrlPanel.Align := alTop;
      end;

{$IFDEF COMPILER6}
      // D6/BCB6 �£�����·���Panel��Align����alClient��ֻAnchors���ķ���
      // �ᵼ��TabControlΪMultiLineʱ�����߶Ȳ���ı䣬�Ӷ��������ʾЧ������ס
      CodePanel := TPanel(EditWindow.FindComponent(SCnCodePanelName));
      if CodePanel <> nil then
      begin
        if CodePanel.Align <> alClient then
          CodePanel.Align := alClient;
      end;
{$ENDIF}
    end;

    if TabControl is TTabControl then
      UpdateTab(TabControl as TTabControl);

    if FTabControlList.IndexOf(TabControl) < 0 then
    begin
      FTabControlList.Add(TabControl);
    end;

  {$IFDEF COMPILER6_UP}
    // �ҽӱ�ǩҳ�Ҽ��˵�
    PopupMenu := TControlHack(TabControl).PopupMenu;
    if not FMenuHookTabPopup.IsHooked(PopupMenu) then
    begin
      FMenuHookTabPopup.HookMenu(PopupMenu);
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Hooked a XTabControl''s PopupMenu');
    {$ENDIF}
    end;
  {$ENDIF COMPILER6_UP}
  end;
end;

procedure TCnSrcEditorMisc.UpdateInstall;
begin
  EnumEditControl(DoUpdateInstall, nil);
end;

procedure TCnSrcEditorMisc.EditControlNotify(EditControl: TControl; EditWindow:
  TCustomForm; Operation: TOperation);
begin
  if Operation = opInsert then
  begin
    UpdateInstall;
{$IFDEF DELPHI10_SEATTLE_UP}
    if FActive then
      CheckAndHideOrigToolbar(nil);
{$ENDIF}
  end;
end;

//------------------------------------------------------------------------------
// ˫������༭��ҳ���ǩ�رյ�ǰҳ��
//------------------------------------------------------------------------------

{$IFNDEF BDS4_UP}
procedure TCnSrcEditorMisc.DoClosePage(Sender: TObject);
var
  i: Integer;
begin
  // ���� D6��D7 �¹ر����һ��ҳ��������˵����ܻ� AV ������
  for i := 0 to FTabControlList.Count - 1 do
    if FTabControlList[i] is TXTabControl then
      with TXTabControl(FTabControlList[i]) do
        if Dragging then
          EndDrag(False);

  CnOtaClosePage(CnOtaGetTopMostEditView);
end;
{$ENDIF}

procedure TCnSrcEditorMisc.OnAppMessage(var Msg: TMsg;
  var Handled: Boolean);
var
  TabControl: TXTabControl;
  Idx: Integer;
  View: IOTAEditView;
  Control: TWinControl;
  XPos, YPos: Integer;
{$IFDEF DELPHIXE2_UP}
  Method: TRttiMethod;
{$ENDIF}
begin
  if not Active then
    Exit;

{$IFDEF BDS}
  Idx := -1;
{$ENDIF}

  if RClickShellMenu and (Msg.message = WM_RBUTTONUP) and (IsShiftDown or
    IsCtrlDown) or DblClickClosePage and (Msg.message = WM_LBUTTONDBLCLK) then
  begin
    XPos := Msg.lParam and $FFFF;
    YPos := (Msg.lParam shr 16) and $FFFF;
    Control := FindControl(Msg.hwnd);
    {$IFDEF DELPHIXE2_UP}
    Method := TRttiContext.Create().GetType(Control.ClassType).GetMethod('ItemAtPos');
    if Assigned(Method) then
      Idx := Method.Invoke(Control, [TValue.From(Point(XPos, YPos))]).AsInteger
    else
      Idx := -1;
    {$ENDIF}
    if (Control <> nil) and (Control is TXTabControl) then
    begin
      TabControl := Control as TXTabControl;
{$IFNDEF EDITOR_TAB_ONLYFROM_WINCONTROL}
    {$IFDEF BDS}
      Idx := TabControl.ItemAtPos(Point(XPos, YPos));
    {$ELSE}
      Idx := TabControl.IndexOfTabAt(XPos, YPos);
    {$ENDIF}
{$ENDIF}
      if Msg.message = WM_RBUTTONUP then
      begin
        if Idx >= 0 then
        begin
          View := EditControlWrapper.GetEditViewFromTabs(TabControl, Idx);
          if Assigned(View) then
          begin
            DisplayContextMenu(TabControl.Handle, View.Buffer.FileName,
              Point(XPos, YPos));
            Handled := True;
          end;
        end;
      end;

    {$IFNDEF BDS4_UP}
      if Msg.message = WM_LBUTTONDBLCLK then
      begin
        // �رյ�ǰ��ǰ���ҳ��
        if (Idx >= 0) and TabControl.ClassNameIs(SCnXTabControlClassName) and
          ((TabControl.Owner = nil) or (TabControl.Owner.Name <> SCnPropertyInspectorName)) then
          CnWizNotifierServices.ExecuteOnApplicationIdle(DoClosePage);
      end;
    {$ENDIF}
    end;

  {$IFDEF BDS4_UP}
    if (Msg.message = WM_LBUTTONDBLCLK) and (Control <> nil) and
      Control.ClassNameIs(SCnXTabControlClassName) then
    begin
      PostMessage(Control.Handle, WM_MBUTTONUP, 16, Msg.lParam);
      {$IFDEF DELPHIXE2_UP}
      if Idx >= 0 then Handled := True;
      {$ENDIF}
    end;
  {$ENDIF}
  end;
end;

//------------------------------------------------------------------------------
// �����˵���
//------------------------------------------------------------------------------

procedure TCnSrcEditorMisc.RegisterUserMenuItems;
begin
  FCloseOtherPagesMenu := TCnMenuItemDef.Create(SCnMenuCloseOtherPagesName,
    SCnMenuCloseOtherPagesCaption, OnCloseOtherPages, ipAfter, SCnMenuClosePageName);
  FMenuHook.AddMenuItemDef(FCloseOtherPagesMenu);

  FShellMenu := TCnMenuItemDef.Create(SCnShellMenuName,
    SCnMenuShellMenuCaption, OnShellMenu, ipAfter, SCnMenuCloseOtherPagesName);
  FMenuHook.AddMenuItemDef(FShellMenu);

  FBlockToolsMenu := TCnMenuItemDef.Create(SCnMenuBlockToolsName, SCnMenuBlockToolsCaption,
    nil, ipAfter, SCnMenuEditPasteItemName);
  FBlockToolsMenu.OnCreated := OnBlockToolsMenuCreated;
  FMenuHook.AddMenuItemDef(FBlockToolsMenu);

  FThumbnailMenu := TCnMenuItemDef.Create(SCnMenuEnableThumbnailName, SCnMenuEnableThumbnailCaption,
    OnThumbnailClick, ipAfter, SCnMenuEditPasteItemName);
  FThumbnailMenu.OnCreated := OnThumbnailMenuCreated;
  FMenuHook.AddMenuItemDef(FThumbnailMenu);

  FSelAllMenu := TCnMenuItemDef.Create(SCnMenuSelAllName, SCnMenuSelAllCaption,
    OnSelectAll, ipAfter, SCnMenuEditPasteItemName {$IFDEF COMPILER5} , '', nil, -1, TextToShortCut('Ctrl+A') {$ENDIF});
  FMenuHook.AddMenuItemDef(FSelAllMenu);

  FCopyFileNameMenu := TCnMenuItemDef.Create(SCnCopyFileNameMenuName,
    SCnMenuCopyFileNameMenuCaption, OnCopyFileName, ipAfter, SCnMenuOpenFileAtCursorName);
  FMenuHook.AddMenuItemDef(FCopyFileNameMenu);

  FExploreMenu := TCnMenuItemDef.Create(SCnMenuExploreName, SCnMenuExploreCaption,
    OnExplore, ipAfter, SCnMenuOpenFileAtCursorName);
  FExploreMenu.OnCreated := OnExploreMenuCreated;
  FMenuHook.AddMenuItemDef(FExploreMenu);

{$IFDEF COMPILER6_UP}
  {$IFNDEF BDS4_UP}
  FCloseOtherPagesMenu1 := TCnMenuItemDef.Create(SCnMenuCloseOtherPagesName + '1',
    SCnMenuCloseOtherPagesCaption, OnCloseOtherPages, ipAfter, SCnMenuClosePageIIName);
  FMenuHookTabPopup.AddMenuItemDef(FCloseOtherPagesMenu1);
  FShellMenu1 := TCnMenuItemDef.Create(SCnShellMenuName + '1',
    SCnMenuShellMenuCaption, OnShellMenu, ipAfter, SCnMenuCloseOtherPagesName + '1');
  {$ELSE}
  FShellMenu1 := TCnMenuItemDef.Create(SCnShellMenuName + '1',
    SCnMenuShellMenuCaption, OnShellMenu, ipAfter, SCnMenuClosePageIIName);
  {$ENDIF}
  FMenuHookTabPopup.AddMenuItemDef(FShellMenu1);

  FCopyFileNameMenu1 := TCnMenuItemDef.Create(SCnCopyFileNameMenuName + '1',
    SCnMenuCopyFileNameMenuCaption, OnCopyFileName, ipAfter, SCnShellMenuName + '1');
  FMenuHookTabPopup.AddMenuItemDef(FCopyFileNameMenu1);

  FExploreMenu1 := TCnMenuItemDef.Create(SCnMenuExploreName + '1', SCnMenuExploreCaption,
    OnExplore, ipAfter, SCnCopyFileNameMenuName + '1');
  FExploreMenu1.OnCreated := OnExploreMenuCreated;
  FMenuHookTabPopup.AddMenuItemDef(FExploreMenu1);
{$ENDIF COMPILER6_UP}
end;

procedure TCnSrcEditorMisc.RegisterMenuExecutor(Sender: TObject);
var
  I: Integer;
  Def: TCnMenuItemDef;
  Executor: TCnContextMenuExecutor;
begin
  // �������ⲿע��ı༭���Ҽ��˵����ű�ר�ң�
{$IFDEF DEBUG}
  CnDebugger.LogFmt('RegisterMenuExecutor Found Menu Executor %d.', [GetEditorMenuExecutorCount]);
{$ENDIF}

  for I := GetEditorMenuExecutorCount - 1 downto 0 do
  begin
    if GetEditorMenuExecutor(I) is TCnContextMenuExecutor then
    begin
      Executor := GetEditorMenuExecutor(I);
      Def := TCnMenuItemDef.Create(Executor.ClassName + IntToStr(I), Executor.Caption,
        Executor.OnExecute, ipAfter, SCnMenuBlockToolsName); // ���ڸ����༭�˵���
      FMenuHook.AddMenuItemDef(Def);
    end;
  end;
end;

procedure TCnSrcEditorMisc.DoCloseOtherPages(Sender: TObject);
var
  ModuleSvcs: IOTAModuleServices;
  i: Integer;
  CurrModule, Module: IOTAModule;
  Project: IOTAProject;
  Group: IOTAProjectGroup;
  List: TList;
  ProjectList: TList;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleSvcs);
  if ModuleSvcs = nil then Exit;

  List := nil;
  ProjectList := nil;
  BeginBatchOpenClose;
  try
    List := TList.Create;
    ProjectList := TList.Create;
    CurrModule := CnOtaGetCurrentModule;
    for i := ModuleSvcs.ModuleCount - 1 downto 0 do
    begin
      Module := ModuleSvcs.Modules[i];
      if Module <> CurrModule then
      begin
        if Supports(Module, IOTAProject, Project) then
        {$IFNDEF BCB5}   { TODO : BCB5 �¹رչ���ҳ����� }
          ProjectList.Add(Pointer(Module))
        {$ENDIF BCB5}
        else if Supports(Module, IOTAProjectGroup, Group) then
        {$IFNDEF BCB5}
          ProjectList.Add(Pointer(Module))
        {$ENDIF BCB5}
        else
          List.Add(Pointer(Module));
      end
    end;
    Module := nil;

    for i := 0 to List.Count - 1 do
      if CnOtaIsModuleModified(IOTAModule(List[i])) then
        IOTAModule(List[i]).Close // ��ʱ��ֱ�ӵ��� Close ����������� IDE �� Bug���ʼ���Ƿ��޸�
      else
        IOTAModule(List[i]).CloseModule(True);

    for i := 0 to ProjectList.Count - 1 do
      CnOtaCloseEditView(IOTAModule(ProjectList[i]));
  finally
    EndBatchOpenClose;
    if Assigned(List) then List.Free;
    if Assigned(ProjectList) then ProjectList.Free;
  end;
end;

procedure TCnSrcEditorMisc.OnCloseOtherPages(Sender: TObject);
begin
  CnWizNotifierServices.ExecuteOnApplicationIdle(DoCloseOtherPages);
end;

procedure TCnSrcEditorMisc.OnShellMenu(Sender: TObject);
var
  P: TPoint;
begin
  if Screen.ActiveCustomForm <> nil then
  begin
    GetCursorPos(P);
    with Screen.ActiveCustomForm do
    DisplayContextMenu(Handle, CnOtaGetCurrentSourceFile, ScreenToClient(P));
  end;
end;

procedure TCnSrcEditorMisc.OnCopyFileName(Sender: TObject);
var
  S: string;
begin
  S := CnOtaGetCurrentSourceFile;
  if S <> '' then
    Clipboard.AsText := S;
end;

procedure TCnSrcEditorMisc.OnExplore(Sender: TObject);
var
  strExecute: string;
begin
  if FileExists(CnOtaGetCurrentSourceFile) then
  begin
    strExecute := Format(ExploreCmdLine, [CnOtaGetCurrentSourceFile]);
{$IFDEF UNICODE}
    WinExecute(strExecute, SW_SHOWNORMAL);
{$ELSE}
    WinExec(PAnsiChar(strExecute), SW_SHOWNORMAL);
{$ENDIF}
  end
  else if DirectoryExists(_CnExtractFileDir(CnOtaGetCurrentSourceFile)) then
  begin
    strExecute := Format(ExploreCmdLine, [_CnExtractFileDir(CnOtaGetCurrentSourceFile)]);
{$IFDEF UNICODE}
    WinExecute(strExecute, SW_SHOWNORMAL);
{$ELSE}
    WinExec(PAnsiChar(strExecute), SW_SHOWNORMAL);
{$ENDIF}
  end;
end;

procedure TCnSrcEditorMisc.OnSelectAll(Sender: TObject);
begin
  ExecuteIDEAction(SCnEditSelectAllCommand);
end;

procedure TCnSrcEditorMisc.OnExploreMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
begin
  MenuItem.Caption := Format(SCnMenuExploreCaption,
    [_CnExtractFileName(CnOtaGetCurrentSourceFile)]);
end;

procedure TCnSrcEditorMisc.OnBlockToolsMenuCreated(Sender: TObject; MenuItem: TMenuItem);
var
  Wizard: TCnSrcEditorEnhance;
  Item: TMenuItem;

  procedure ClearMenuItemImageIndex(AMenuItem: TMenuItem);
  var
    I: Integer;
  begin
    AMenuItem.ImageIndex := -1;
    for I := 0 to AMenuItem.Count - 1 do
      ClearMenuItemImageIndex(AMenuItem.Items[I]);
  end;

begin
  // ���� BlockTools ���Ӳ˵�
  FBlockToolMenuItem := MenuItem;
  Wizard := (CnWizardMgr.WizardByClass(TCnSrcEditorEnhance)) as TCnSrcEditorEnhance;
  if Wizard <> nil then
  begin
    if Wizard.BlockTools <> nil then
    begin
      // �˴����ܵ��� UpdateMenu ��ʵ�г�ʼ���������ֹ��������в˵��
      // Wizard.BlockTools.UpdateMenu(MenuItem, False);
      CloneMenuItem(Wizard.BlockTools.PopupMenu.Items, MenuItem);

      if not Wizard.BlockTools.Active or not Wizard.BlockTools.ShowBlockTools then
      begin
        // ����ʾ������ť������£�����ʾ�������Ϊ��ݼ��ѽ�����
        if MenuItem.Count > 3 then
        begin
          Item := MenuItem.Items[MenuItem.Count - 3]; // ������
          if Item.Count > 3 then
          begin
            Item := Item.Items[Item.Count - 1];       // �������ڵ����һ��
            Item.Visible := False;
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Hide Setting Item when FlatButton Disabled: ' + Item.Caption);
{$ENDIF}
          end;
        end;
      end;

{$IFDEF COMPILER6_UP}
      // ��� ImageList ����ͷ���� ImageIndex���Ͼ�������ʹ�õ� IDE �� ImageList
      if not FEditorMenuImageListIsMain then
        ClearMenuItemImageIndex(MenuItem);
{$ENDIF}

      MenuItem.Visible := FAddMenuBlockTools;
      Exit;
    end;
  end;
  MenuItem.Visible := False;
end;

//------------------------------------------------------------------------------
// �޸��Զ���ɿ�ݼ�
//------------------------------------------------------------------------------

procedure TCnSrcEditorMisc.UpdateCodeCompletionHotKey;
var
  Index: Integer;
begin
  WizShortCutMgr.BeginUpdate;
  try
    Index := WizShortCutMgr.IndexOfName(SCnCodeCompletion);
    if Index >= 0 then
      WizShortCutMgr.Delete(Index);
    if Active and FChangeCodeComKey then
      WizShortCutMgr.Add(SCnCodeCompletion, FCodeCompletionKey, CodeCompletionKeyProc);
  finally
    WizShortCutMgr.EndUpdate;
  end;
end;

procedure TCnSrcEditorMisc.CodeCompletionKeyProc(Sender: TObject);
var
  EditView: IOTAEditView;
begin
  EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
    (EditView as IOTAEditActions).CodeCompletion(csCodeList or csManual);
end;

//------------------------------------------------------------------------------
// ϵͳ�ļ���ֻ������
//------------------------------------------------------------------------------

procedure TCnSrcEditorMisc.SynchronizeDirs;
var
  I: Integer;
begin
  FActualDirs.Clear;
  for I := 0 to FReadOnlyDirs.Count - 1 do
    FActualDirs.Add(UpperCase(MakePath(ReplaceToActualPath(FReadOnlyDirs[I]))));
end;

{$IFDEF DELPHI10_SEATTLE_UP}

procedure TCnSrcEditorMisc.CheckAndHideOrigToolbar(Sender: TObject);
var
  I: Integer;
  Control: TControl;
  Parent: TWinControl;
  Popup: TPopupMenu;
  CloseItem: TMenuItem;
{$IFDEF CNWIZARDS_CNPROCLISTWIZARD}
  ProcWizard: TCnProcListWizard;
{$ENDIF}
begin
  Control := CnOtaGetCurrentEditControl;
  if Control = nil then
    Exit;

  Parent := Control.Parent;  // EditorPanel
  if Parent = nil then
    Exit;

  Parent := Parent.Parent;   // CodePanel
  if Parent = nil then
    Exit;

  // ���༭�����������Ƿ��к����б��������ã�����о�ɶ������
{$IFDEF CNWIZARDS_CNPROCLISTWIZARD}
  ProcWizard := TCnProcListWizard(CnWizardMgr.WizardByName(SCnProcListWizardName));
  if (ProcWizard = nil) or not ProcWizard.Active or not ProcWizard.UseEditorToolBar then
    Exit;
{$ENDIF}

{$IFDEF DELPHI103_RIO_UP}
  // 10.3 �� EditorNavigationToolbar ���滹�и�û���ֵ� Panel
  for I := 0 to Parent.ControlCount - 1 do
  begin
    if (Parent.Controls[I].ClassNameIs('TPanel')) and (Parent.Controls[I].Name = '') then
    begin
      Parent := TWinControl(Parent.Controls[I]);
      Break;
    end;
  end;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogFmt('CheckAndHideOrigToolbar Hide: %d. Get a Parent: %s', [Integer(FHideOrigToolbar), Parent.ClassName]);
{$ENDIF}

  if FHideOrigToolbar then
  begin
    for I := 0 to Parent.ControlCount - 1 do
    begin
      if Parent.Controls[I].ClassNameIs('TEditorNavigationToolbar') then
      begin
{$IFDEF DELPHI103_RIO_UP}
        // 10.3 �� IDE ѡ���ʾ����������ʱ���ҵ��� Panel ���ܲ�����������ģ�
        // �����ڲ��� NativagtorToolbar ���ǡ�
        Parent.Visible := False;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('CheckAndHideOrigToolbar Hide Toolbar Panel.');
{$ENDIF}
{$ELSE}
        if Parent.Controls[I].Height > 0 then
        begin
          (Parent.Controls[I] as TToolbar).AutoSize := False;
          Parent.Controls[I].Height := 0;
          Parent.Controls[I].Visible := False;
{$IFDEF DEBUG}
          CnDebugger.LogMsg('CheckAndHideOrigToolbar Hide Toolbar.');
{$ENDIF}
        end;
{$ENDIF}
        Exit;
      end;
    end;
  end
  else
  begin
    for I := 0 to Parent.ControlCount - 1 do
    begin
      if Parent.Controls[I].ClassNameIs('TEditorNavigationToolbar') then
      begin
        if TControlHack(Parent.Controls[I]).PopupMenu = nil then
        begin
          Popup := TPopupMenu.Create(Parent.Controls[I]);
          CloseItem := TMenuItem.Create(Popup);
          CloseItem.Caption := '&Hide';
          CloseItem.OnClick := OrigToolbarClose;
          CloseItem.Tag := TCnNativeInt(Parent.Controls[I]);

          Popup.Items.Add(CloseItem);
          TControlHack(Parent.Controls[I]).PopupMenu := Popup;

{$IFDEF DEBUG}
          CnDebugger.LogMsg('CheckAndHideOrigToolbar Set a PopupMenu to Toolbar.');
{$ENDIF}
        end;
        Exit;
      end;
    end;
  end;
end;

procedure TCnSrcEditorMisc.OrigToolbarClose(Sender: TObject);
var
  Toolbar: TControl;
begin
  HideOrigToolbar := True;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Hide Toolbar Menu Item Clicked.');
{$ENDIF}

  Toolbar := TControl((Sender as TComponent).Tag);
{$IFDEF DELPHI103_RIO_UP}
  Toolbar := TControl(Toolbar.Parent); // Panel
  if ToolBar <> nil then
    Toolbar.Visible := False;
{$ELSE}
  if Toolbar.Height > 0 then
  begin
    (Toolbar as TToolbar).AutoSize := False;
    Toolbar.Height := 0;
    Toolbar.Visible := False;
  end;
{$ENDIF}
end;

{$ENDIF}

procedure TCnSrcEditorMisc.OnSourceEditorNotify(
  SourceEditor: IOTASourceEditor; NotifyType: TCnWizSourceEditorNotifyType;
  EditView: IOTAEditView);
var
  I: Integer;
  EditBuff: IOTAEditBuffer;
begin
  if FActive then
  begin
    // ֻ������
    if FAutoReadOnly and (NotifyType = setOpened) and (SourceEditor <> nil) and
      Supports(SourceEditor, IOTAEditBuffer, EditBuff) then
    begin
      for I := 0 to FActualDirs.Count - 1 do
      begin
        if AnsiPos(FActualDirs[I], UpperCase(SourceEditor.FileName)) = 1 then
        begin
          EditBuff.IsReadOnly := True;
          Break;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// TabControl ������չ
//------------------------------------------------------------------------------

procedure TCnSrcEditorMisc.DoUpdateTabControlCaption(ClearFlag: Boolean);
var
  I, J: Integer;
  TabControl: TXTabControl;
  EditView: IOTAEditView;
  NewCaption: string;
  Tabs: TStrings;

  function IsModified(AView: IOTAEditView): Boolean;
  var
    I: Integer;
  begin
    for I := 0 to EditView.Buffer.Module.GetModuleFileCount - 1 do
      if EditView.Buffer.Module.GetModuleFileEditor(I).Modified then
      begin
        Result := True;
        Exit;
      end;
    Result := False;
  end;

  function GetNewCaption(const ACaption: string; AIsModified: Boolean): string;
  begin
    Result := Trim(ACaption);
    if AIsModified and (StrRight(Result, 1) <> '*') then
      Result := Result + '*'
    else if not AIsModified and (StrRight(Result, 1) = '*') then
      Delete(Result, Length(Result), 1);
  end;

begin
  try
    for I := 0 to FTabControlList.Count - 1 do
    begin
      if FTabControlList[I] is TXTabControl then
      begin
        TabControl := TXTabControl(FTabControlList[I]);
        Tabs := GetEditorTabTabs(TabControl);

        for J := 0 to Tabs.Count - 1 do
        begin
          if ClearFlag then
          begin
            // ������Ƚ�ֱ�Ӹ�ֵ���ᵼ��CPUռ��100%
            NewCaption := GetNewCaption(Tabs[J], False);
            if not SameText(Tabs[J], NewCaption) then
              Tabs[J] := NewCaption;
          end
          else if Tabs.Objects[J] <> nil then
          begin
            EditView := EditControlWrapper.GetEditViewFromTabs(TabControl, J);
            if Assigned(EditView) then
            begin
              NewCaption := GetNewCaption(Tabs[J], IsModified(EditView));
              if not SameText(Tabs[J], NewCaption) then
                Tabs[J] := NewCaption;
            end;
          end;
        end;
      end;
    end;
  except
    on E: Exception do
      DoHandleException('UpdateTabControlCaption ' + E.Message);
  end;
end;

procedure TCnSrcEditorMisc.UpdateTabControlCaption(Sender: TObject);
begin
  if Active and DispModifiedInTab then
    DoUpdateTabControlCaption(False);
end;

//------------------------------------------------------------------------------
// ��������
//------------------------------------------------------------------------------

const
  csMisc = 'Misc';
  csDblClickClosePage = 'DblClickClosePage';
  csRClickShellMenu = 'RClickShellMenu';
  csAddMenuCloseOtherPages = 'AddMenuCloseOtherPages';
  csAddMenuSelAll = 'AddMenuSelAll';
  csAddMenuExplore = 'AddMenuExplore';
  csAddMenuCopyFileName = 'AddMenuCopyFileName';
  csAddMenuShell = 'AddMenuShell';
  csAddMenuBlockTools = 'AddMenuBlockTools';
  csExploreCmdLine = 'ExploreCmdLine';
  csChangeCodeComKey = 'ChangeCodeComKey';
  csCodeCompletionKey = 'CodeCompletionKey';
  csAutoReadOnly = 'AutoReadOnly';
  csDispModifiedInTab = 'DispModifiedInTab';
  csEditorTabMultiLine = 'EditorTabMultiLine';
  csEditorTabFlatButtons = 'EditorTabFlatButtons';
  csAutoSave = 'AutoSave';
  csSaveInterval = 'SaveInterval';
  csHideOrigToolbar = 'HideOrigToolbar';

procedure TCnSrcEditorMisc.LoadSettings(Ini: TCustomIniFile);
var
  IsEng: Boolean;
begin
  IsEng := GetSystemDefaultLangID = 1033;
  DblClickClosePage := Ini.ReadBool(csMisc, csDblClickClosePage, True);
  RClickShellMenu := Ini.ReadBool(csMisc, csRClickShellMenu, True);
  AddMenuCloseOtherPages := Ini.ReadBool(csMisc, csAddMenuCloseOtherPages, True);
  AddMenuSelAll := Ini.ReadBool(csMisc, csAddMenuSelAll, True);
  AddMenuExplore := Ini.ReadBool(csMisc, csAddMenuExplore, True);
  AddMenuCopyFileName := Ini.ReadBool(csMisc, csAddMenuCopyFileName, True);
  AddMenuShell := Ini.ReadBool(csMisc, csAddMenuShell, True);
  AddMenuBlockTools := Ini.ReadBool(csMisc, csAddMenuBlockTools, True);
  ExploreCmdLine := Ini.ReadString(csMisc, csExploreCmdLine, csDefExploreCmdLine);

  FChangeCodeComKey := Ini.ReadBool(csMisc, csChangeCodeComKey, not IsEng);
  FCodeCompletionKey := Ini.ReadInteger(csMisc, csCodeCompletionKey, ShortCut(VK_SPACE, [ssAlt]));
  // ��������д�������������õ� Update

  AutoReadOnly := Ini.ReadBool(csMisc, csAutoReadOnly, True);
  WizOptions.LoadUserFile(FReadOnlyDirs, SCnReadOnlyDirsFile);
  SynchronizeDirs;
  DispModifiedInTab := Ini.ReadBool(csMisc, csDispModifiedInTab, True);
  FEditorTabMultiLine := Ini.ReadBool(csMisc, csEditorTabMultiLine, False);
  FEditorTabFlatButtons := Ini.ReadBool(csMisc, csEditorTabFlatButtons, False);
  
  FAutoSave := Ini.ReadBool(csMisc, csAutoSave, False);
  FSaveInterval := Ini.ReadInteger(csMisc, csSaveInterval, 2);
  FHideOrigToolbar := Ini.ReadBool(csMisc, csHideOrigToolbar, False);
  UpdateAutoSaveTimer;

  UpdateCodeCompletionHotKey;
end;

procedure TCnSrcEditorMisc.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csMisc, csDblClickClosePage, DblClickClosePage);
  Ini.WriteBool(csMisc, csRClickShellMenu, RClickShellMenu);
  Ini.WriteBool(csMisc, csAddMenuCloseOtherPages, AddMenuCloseOtherPages);
  Ini.WriteBool(csMisc, csAddMenuSelAll, AddMenuSelAll);
  Ini.WriteBool(csMisc, csAddMenuExplore, AddMenuExplore);
  Ini.WriteBool(csMisc, csAddMenuCopyFileName, AddMenuCopyFileName);
  Ini.WriteBool(csMisc, csAddMenuShell, AddMenuShell);
  Ini.WriteBool(csMisc, csAddMenuBlockTools, AddMenuBlockTools);
  if SameText(ExploreCmdLine, csDefExploreCmdLine) then
    Ini.DeleteKey(csMisc, csExploreCmdLine)
  else
    Ini.WriteString(csMisc, csExploreCmdLine, ExploreCmdLine);
  Ini.WriteBool(csMisc, csChangeCodeComKey, ChangeCodeComKey);
  Ini.WriteInteger(csMisc, csCodeCompletionKey, CodeCompletionKey);
  Ini.WriteBool(csMisc, csAutoReadOnly, AutoReadOnly);
  WizOptions.SaveUserFile(FReadOnlyDirs, SCnReadOnlyDirsFile);
  Ini.WriteBool(csMisc, csDispModifiedInTab, DispModifiedInTab);
  Ini.WriteBool(csMisc, csEditorTabMultiLine, FEditorTabMultiLine);
  Ini.WriteBool(csMisc, csEditorTabFlatButtons, FEditorTabFlatButtons);
  Ini.WriteBool(csMisc, csAutoSave, AutoSave);
  Ini.WriteInteger(csMisc, csSaveInterval, SaveInterval);
  Ini.WriteBool(csMisc, csHideOrigToolbar, FHideOrigToolbar);
end;

procedure TCnSrcEditorMisc.ResetSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnSrcEditorMisc.LanguageChanged(Sender: TObject);
begin
  inherited;
  FExploreMenu.SetCaption(SCnMenuExploreCaption);
  FCopyFileNameMenu.SetCaption(SCnMenuCopyFileNameMenuCaption);
  FSelAllMenu.SetCaption(SCnMenuSelAllCaption);
  FBlockToolsMenu.SetCaption(SCnMenuBlockToolsCaption);
  FThumbnailMenu.SetCaption(SCnMenuEnableThumbnailCaption);
  FCloseOtherPagesMenu.SetCaption(SCnMenuCloseOtherPagesCaption);
  FShellMenu.SetCaption(SCnMenuShellMenuCaption);
{$IFDEF COMPILER6_UP}
  {$IFNDEF BDS4_UP}
  FCloseOtherPagesMenu1.SetCaption(SCnMenuCloseOtherPagesCaption);
  {$ENDIF}
  FShellMenu1.SetCaption(SCnMenuShellMenuCaption);
  FCopyFileNameMenu1.SetCaption(SCnMenuCopyFileNameMenuCaption);
  FExploreMenu1.SetCaption(SCnMenuExploreCaption);
{$ENDIF COMPILER6_UP}
end;

//------------------------------------------------------------------------------
// ���Զ�д
//------------------------------------------------------------------------------

function TCnSrcEditorMisc.GetBoolean(const Index: Integer): Boolean;
begin
  Result := False;
  case Index of
    0: Result := FCloseOtherPagesMenu.Active;
    1: Result := FSelAllMenu.Active;
    2: Result := FExploreMenu.Active;
    3: Result := FShellMenu.Active;
    4: Result := FCopyFileNameMenu.Active;
  end;
end;

procedure TCnSrcEditorMisc.SetBoolean(const Index: Integer;
  const Value: Boolean);
begin
  case Index of
    0: begin
       FCloseOtherPagesMenu.Active := Value;
    {$IFDEF COMPILER6_UP}
      {$IFNDEF BDS4_UP}
       FCloseOtherPagesMenu1.Active := Value;
      {$ENDIF}
    {$ENDIF COMPILER6_UP}
       end;
    1: FSelAllMenu.Active := Value;
    2: begin
       FExploreMenu.Active := Value;
    {$IFDEF COMPILER6_UP}
       FExploreMenu1.Active := Value;
    {$ENDIF COMPILER6_UP}
       end;
    3: begin
       FShellMenu.Active := Value;
    {$IFDEF COMPILER6_UP}
       FShellMenu1.Active := Value;
    {$ENDIF COMPILER6_UP}
       end;
    4: begin
       FCopyFileNameMenu.Active := Value;
    {$IFDEF COMPILER6_UP}
       FCopyFileNameMenu1.Active := Value;
    {$ENDIF COMPILER6_UP}
       end;
  end;
end;

procedure TCnSrcEditorMisc.SetActive(Value: Boolean);
begin
  FActive := Value;
  FMenuHook.Active := Value;
{$IFDEF COMPILER6_UP}
  FMenuHookTabPopup.Active := Value;
{$ENDIF COMPILER6_UP}
  UpdateCodeCompletionHotKey;
  UpdateAutoSaveTimer;
  if not FActive or not DispModifiedInTab then
    DoUpdateTabControlCaption(True);
end;

procedure TCnSrcEditorMisc.SetAddMenuBlockTools(const Value: Boolean);
begin
  if Value <> FAddMenuBlockTools then
  begin
    FAddMenuBlockTools := Value;
    if FBlockToolMenuItem <> nil then
      FBlockToolMenuItem.Visible := Value;
  end;
end;

procedure TCnSrcEditorMisc.SetChangeCodeComKey(const Value: Boolean);
begin
  FChangeCodeComKey := Value;
  UpdateCodeCompletionHotKey;
end;

procedure TCnSrcEditorMisc.SetCodeCompletionKey(
  const Value: TShortCut);
begin
  FCodeCompletionKey := Value;
  UpdateCodeCompletionHotKey;
end;

procedure TCnSrcEditorMisc.SetAutoReadOnly(const Value: Boolean);
begin
  FAutoReadOnly := Value;
end;

procedure TCnSrcEditorMisc.SetReadOnlyDirs(const Value: TStrings);
begin
  if Value <> nil then
  begin
    FReadOnlyDirs.Assign(Value);
    SynchronizeDirs;
  end;
end;

procedure TCnSrcEditorMisc.SetDispModifiedInTab(const Value: Boolean);
begin
  if FDispModifiedInTab <> Value then
  begin
    FDispModifiedInTab := Value;
    if not Value then
      DoUpdateTabControlCaption(True);
  end;
end;

procedure TCnSrcEditorMisc.SetAutoSave(const Value: Boolean);
begin
  if Value <> FAutoSave then
  begin
    FAutoSave := Value;
    UpdateAutoSaveTimer;
  end;
end;

procedure TCnSrcEditorMisc.SetSaveInterval(const Value: Integer);
begin
  if Value <> FSaveInterval then
  begin
    FSaveInterval := Value;
    UpdateAutoSaveTimer;
  end;
end;

procedure TCnSrcEditorMisc.UpdateAutoSaveTimer;
begin
  FAutoSaveTimer.Interval := FSaveInterval * 60 * 1000;
  FAutoSaveTimer.Enabled := Active and FAutoSave;
end;

procedure TCnSrcEditorMisc.AutoSaveOnTimer(Sender: TObject);
var
  I: Integer;
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
  S: string;

  function IsModuleModified(AModule: IOTAModule): Boolean;
  var
    J: Integer;
  begin
    Result := False;
    if AModule <> nil then
      for J := 0 to Module.GetModuleFileCount - 1 do
        if Module.GetModuleFileEditor(J).Modified then
        begin
          Result := True;
          Exit;
        end;
  end;

begin
  FAutoSaveTimer.Enabled := False;
  try
    try
      QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);

      for I := 0 to ModuleServices.GetModuleCount - 1 do
      begin
        Module := ModuleServices.GetModule(I);
        if IsModuleModified(Module) then
        begin
          S := CnOtaGetFileNameOfModule(Module);
          if IsSourceModule(S) and FileExists(S) then
            Module.Save(False, True);
        end;
      end;
    except
      ;
    end;
  finally
    FAutoSaveTimer.Enabled := Active and FAutoSave;
  end;
end;

procedure TCnSrcEditorMisc.UpdateEditorTabStyle;
{$IFNDEF BDS}
var
  I: Integer;
  Tab: TTabControl;
{$ENDIF}
begin
{$IFNDEF BDS}
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if IsIdeEditorForm(Screen.CustomForms[I]) then
    begin
      Tab := TTabControl(FindComponentByClassName(Screen.CustomForms[I],
        SCnXTabControlClassName, SCnXTabControlName));
      if Tab <> nil then
        UpdateTab(Tab);
    end;
  end;
{$ENDIF}  
end;

procedure TCnSrcEditorMisc.UpdateTab(Tab: TTabControl);
begin
{$IFNDEF BDS}
  if Tab <> nil then
  begin
    if (Tab.Style = tsFlatButtons) <> FEditorTabFlatButtons then
    begin
      if FEditorTabFlatButtons then
        Tab.Style := tsFlatButtons
      else
        Tab.Style := tsTabs;
    end;

    if Tab.MultiLine <> FEditorTabMultiLine then
      Tab.MultiLine := FEditorTabMultiLine;

    if FEditorTabMultiLine then
    begin
      Tab.OnResize := ResizeTabControl;
      Tab.OnResize(Tab);
    end
    else
      Tab.OnResize := nil;
  end;
{$ENDIF}
end;

class procedure TCnSrcEditorMisc.ResizeTabControl(Sender: TObject);
var
  AOwner: TComponent;
  Tab: TTabControl;
  TabCtrlPanel: TPanel;
begin
  if Sender is TTabControl then
  begin
    Tab := Sender as TTabControl;
    if Tab.Owner <> nil then
      AOwner := Tab.Owner
    else
      AOwner := nil;

    if (AOwner = nil) or (TabCtrlHeight = 0) then
      Exit;

    TabCtrlPanel := AOwner.FindComponent(SCnTabControlPanelName) as TPanel;

    if TabCtrlPanel = nil then
      Exit;
      
    if Tab.Style = tsFlatButtons then
      TabCtrlPanel.Height := (Tab.RowCount * TabCtrlHeight) - (3 * (Tab.RowCount - 1))
    else
      TabCtrlPanel.Height := (Tab.RowCount * TabCtrlHeight) - (6 * (Tab.RowCount - 1));

    Tab.Height := TabCtrlPanel.Height;
  end;
end;

procedure TCnSrcEditorMisc.OnThumbnailClick(Sender: TObject);
var
  Wizard: TCnSrcEditorEnhance;
begin
  Wizard := (CnWizardMgr.WizardByClass(TCnSrcEditorEnhance)) as TCnSrcEditorEnhance;
  if Wizard <> nil then
    Wizard.Thumbnail.ShowThumbnail := not Wizard.Thumbnail.ShowThumbnail;
end;

procedure TCnSrcEditorMisc.OnThumbnailMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
var
  Wizard: TCnSrcEditorEnhance;
begin
  Wizard := (CnWizardMgr.WizardByClass(TCnSrcEditorEnhance)) as TCnSrcEditorEnhance;
  if Wizard <> nil then
    MenuItem.Checked := Wizard.Thumbnail.ShowThumbnail;
end;

procedure TCnSrcEditorMisc.CheckCodeCompDisabled(InputHelperKey: TShortCut);
begin
{$IFDEF DEBUG}
  Cndebugger.LogBoolean(InputHelperKey = FCodeCompletionKey, 'Get Input Helper ShortCut. Equal?');
{$ENDIF}
  if InputHelperKey = FCodeCompletionKey then
    ChangeCodeComKey := False;
end;

{ TCnInputHelperShortcutReceiver }

constructor TCnInputHelperShortCutReceiver.Create(AMisc: TCnSrcEditorMisc);
begin
  inherited Create;
  FMisc := AMisc;
end;

destructor TCnInputHelperShortCutReceiver.Destroy;
begin
  inherited;

end;

procedure TCnInputHelperShortCutReceiver.OnEvent(Event: TCnEvent);
begin
  FMisc.CheckCodeCompDisabled(TShortCut(Event.EventData));
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.
