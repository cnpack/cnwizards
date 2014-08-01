{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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

unit CnSrcEditorMisc;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器扩展其它工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2004.12.25
*               创建单元，从原 CnEditorEnhancements 移出
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

{$IFNDEF BDS}
  {$DEFINE NEED_MODIFIED_TAB}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, ToolsAPI,
  Contnrs, IniFiles, Forms, ExtCtrls, Menus, ComCtrls, TypInfo, Math, FileCtrl,
  Clipbrd, CnCommon, CnWizUtils, CnConsts, CnWizIdeUtils, CnWizConsts, CnWizManager,
  CnMenuHook, CnWizNotifier, CnEditControlWrapper, CnShellUtils, CnWizClasses;

type

//==============================================================================
// 代码编辑器扩展其它功能
//==============================================================================

{ TCnSrcEditorMisc }

  TCnSrcEditorMisc = class(TObject)
  private
    FTabControlList: TComponentList;
    FMenuHook: TCnMenuHook;
  {$IFDEF COMPILER6_UP}
    FMenuHook1: TCnMenuHook;
  {$ENDIF COMPILER6_UP}
    FExploreMenu: TCnMenuItemDef;
    FSelAllMenu: TCnMenuItemDef;
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
  {$IFDEF NEED_MODIFIED_TAB}
    FTimer: TTimer;
  {$ENDIF}
    FDblClickClosePage: Boolean;
    FRClickShellMenu: Boolean;
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
    function GetBoolean(const Index: Integer): Boolean;
    procedure SetBoolean(const Index: Integer; const Value: Boolean);

    procedure RegisterUserMenuItems;
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
  {$IFDEF NEED_MODIFIED_TAB}
    procedure DoUpdateTabControlCaption(ClearFlag: Boolean);
    procedure UpdateTabControlCaption(Sender: TObject);
  {$ENDIF}
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
    procedure LanguageChanged(Sender: TObject);
    
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
{$IFDEF DelphiXE2_UP}
  Rtti,
{$ENDIF}
  CnSrcEditorEnhance, CnWizOptions, CnWizShortCut;

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
// 代码编辑器扩展类
//==============================================================================

{ TCnSrcEditorMisc }

constructor TCnSrcEditorMisc.Create;
begin
  inherited;
  FTabControlList := TComponentList.Create;
  
  FMenuHook := TCnMenuHook.Create(nil);
{$IFDEF COMPILER6_UP}
  FMenuHook1 := TCnMenuHook.Create(nil);
{$ENDIF COMPILER6_UP}
  FReadOnlyDirs := TStringList.Create;
  FActualDirs := TStringList.Create;
  RegisterUserMenuItems;

{$IFDEF NEED_MODIFIED_TAB}
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 200;
  FTimer.OnTimer := UpdateTabControlCaption;
  FTimer.Enabled := True;
{$ENDIF}

  FAutoSaveTimer := TTimer.Create(nil);
  FAutoSaveTimer.OnTimer := AutoSaveOnTimer;

  CnWizNotifierServices.AddApplicationMessageNotifier(OnAppMessage);
  CnWizNotifierServices.AddSourceEditorNotifier(OnSourceEditorNotify);
  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  UpdateInstall;
end;

destructor TCnSrcEditorMisc.Destroy;
begin
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  CnWizNotifierServices.RemoveApplicationMessageNotifier(OnAppMessage);
  CnWizNotifierServices.RemoveSourceEditorNotifier(OnSourceEditorNotify);

{$IFDEF NEED_MODIFIED_TAB}
  FTimer.Free;
{$ENDIF}

  FAutoSaveTimer.Free;
  FActualDirs.Free;
  FReadOnlyDirs.Free;
  FMenuHook.Free;
{$IFDEF COMPILER6_UP}
  FMenuHook1.Free;
{$ENDIF COMPILER6_UP}
  FTabControlList.Free;

  inherited;
end;

//------------------------------------------------------------------------------
// 编辑器窗口控件挂接
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
  // 挂接编辑器右键菜单
  PopupMenu := TControlHack(EditControl).PopupMenu;
  if not FMenuHook.IsHooked(PopupMenu) then
  begin
    FMenuHook.HookMenu(PopupMenu);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Hooked a EditControl''s PopupMenu.');
  {$ENDIF}
  end;

  TabControl := TControl(FindComponentByClassName(EditWindow,
    XTabControlClassName, XTabControlName));
  if Assigned(TabControl) then
  begin
    if TabCtrlHeight = 0 then
    begin
      // 想法获得 TabCtrl 的原始高度
      TabCtrlPanelComp := EditWindow.FindComponent(TabControlPanelName);
      if (TabCtrlPanelComp <> nil) and (TabCtrlPanelComp is TPanel) then
      begin
        TabCtrlPanel := TabCtrlPanelComp as TPanel;
        TabCtrlHeight := TabCtrlPanel.Height;
        if TabCtrlPanel.Align <> alTop then
          TabCtrlPanel.Align := alTop;
      end;

{$IFDEF COMPILER6}
      // D6/BCB6 下，这个下方的Panel的Align不是alClient，只Anchors是四方，
      // 会导致TabControl为MultiLine时容器高度不会改变，从而下面的显示效果被挡住
      CodePanel := TPanel(EditWindow.FindComponent('CodePanel'));
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
    // 挂接标签页右键菜单
    PopupMenu := TControlHack(TabControl).PopupMenu;
    if not FMenuHook1.IsHooked(PopupMenu) then
    begin
      FMenuHook1.HookMenu(PopupMenu);
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
    UpdateInstall;
end;

//------------------------------------------------------------------------------
// 双击代码编辑器页面标签关闭当前页面
//------------------------------------------------------------------------------

{$IFNDEF BDS4_UP}
procedure TCnSrcEditorMisc.DoClosePage(Sender: TObject);
var
  i: Integer;
begin
  // 修正 D6、D7 下关闭最后一个页面后点击主菜单可能会 AV 的问题
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
{$IFDEF DelphiXE2_UP}
  Method: TRttiMethod;
{$ENDIF}
begin
  if not Active then
    Exit;

  if RClickShellMenu and (Msg.message = WM_RBUTTONUP) and (IsShiftDown or
    IsCtrlDown) or DblClickClosePage and (Msg.message = WM_LBUTTONDBLCLK) then
  begin
    XPos := Msg.lParam and $FFFF;
    YPos := (Msg.lParam shr 16) and $FFFF;
    Control := FindControl(Msg.hwnd);
    {$IFDEF DelphiXE2_UP}
    Method := TRttiContext.Create().GetType(Control.ClassType).GetMethod('ItemAtPos');
    if Assigned(Method) then
      Idx := Method.Invoke(Control, [TValue.From(Point(XPos, YPos))]).AsInteger;
    {$ENDIF}
    if (Control <> nil) and (Control is TXTabControl) then
    begin
      TabControl := Control as TXTabControl;
    {$IFDEF BDS}
      Idx := TabControl.ItemAtPos(Point(XPos, YPos));
    {$ELSE}
      Idx := TabControl.IndexOfTabAt(XPos, YPos);
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
        // 关闭当前最前面的页面
        if (Idx >= 0) and TabControl.ClassNameIs(XTabControlClassName) and
          ((TabControl.Owner = nil) or (TabControl.Owner.Name <> PropertyInspectorName)) then
          CnWizNotifierServices.ExecuteOnApplicationIdle(DoClosePage);
      end;
    {$ENDIF}
    end;

  {$IFDEF BDS4_UP}
    if (Msg.message = WM_LBUTTONDBLCLK) and (Control <> nil) and
      Control.ClassNameIs(XTabControlClassName) then
    begin
      PostMessage(Control.Handle, WM_MBUTTONUP, 16, Msg.lParam);
      {$IFDEF DelphiXE2_UP}
      if Idx >= 0 then Handled := True;
      {$ENDIF}
    end;
  {$ENDIF}
  end;
end;

//------------------------------------------------------------------------------
// 新增菜单项
//------------------------------------------------------------------------------

procedure TCnSrcEditorMisc.RegisterUserMenuItems;
begin
  FCloseOtherPagesMenu := TCnMenuItemDef.Create(SCnMenuCloseOtherPagesName,
    SCnMenuCloseOtherPagesCaption, OnCloseOtherPages, ipAfter, SMenuClosePageName);
  FMenuHook.AddMenuItemDef(FCloseOtherPagesMenu);

  FShellMenu := TCnMenuItemDef.Create(SCnShellMenuName,
    SCnMenuShellMenuCaption, OnShellMenu, ipAfter, SCnMenuCloseOtherPagesName);
  FMenuHook.AddMenuItemDef(FShellMenu);

  FBlockToolsMenu := TCnMenuItemDef.Create(SCnMenuBlockToolsName, SCnMenuBlockToolsCaption,
    nil, ipAfter, SMenuEditPasteItemName);
  FBlockToolsMenu.OnCreated := OnBlockToolsMenuCreated;
  FMenuHook.AddMenuItemDef(FBlockToolsMenu);

  FSelAllMenu := TCnMenuItemDef.Create(SCnMenuSelAllName, SCnMenuSelAllCaption,
    OnSelectAll, ipAfter, SMenuEditPasteItemName);
  FMenuHook.AddMenuItemDef(FSelAllMenu);

  FCopyFileNameMenu := TCnMenuItemDef.Create(SCnCopyFileNameMenuName,
    SCnMenuCopyFileNameMenuCaption, OnCopyFileName, ipAfter, SMenuOpenFileAtCursorName);
  FMenuHook.AddMenuItemDef(FCopyFileNameMenu);

  FExploreMenu := TCnMenuItemDef.Create(SCnMenuExploreName, SCnMenuExploreCaption,
    OnExplore, ipAfter, SMenuOpenFileAtCursorName);
  FExploreMenu.OnCreated := OnExploreMenuCreated;
  FMenuHook.AddMenuItemDef(FExploreMenu);

{$IFDEF COMPILER6_UP}
  {$IFNDEF BDS4_UP}
  FCloseOtherPagesMenu1 := TCnMenuItemDef.Create(SCnMenuCloseOtherPagesName + '1',
    SCnMenuCloseOtherPagesCaption, OnCloseOtherPages, ipAfter, SMenuClosePageIIName);
  FMenuHook1.AddMenuItemDef(FCloseOtherPagesMenu1);
  FShellMenu1 := TCnMenuItemDef.Create(SCnShellMenuName + '1',
    SCnMenuShellMenuCaption, OnShellMenu, ipAfter, SCnMenuCloseOtherPagesName + '1');
  {$ELSE}
  FShellMenu1 := TCnMenuItemDef.Create(SCnShellMenuName + '1',
    SCnMenuShellMenuCaption, OnShellMenu, ipAfter, SMenuClosePageIIName);
  {$ENDIF}
  FMenuHook1.AddMenuItemDef(FShellMenu1);

  FCopyFileNameMenu1 := TCnMenuItemDef.Create(SCnCopyFileNameMenuName + '1',
    SCnMenuCopyFileNameMenuCaption, OnCopyFileName, ipAfter, SCnShellMenuName + '1');
  FMenuHook1.AddMenuItemDef(FCopyFileNameMenu1);

  FExploreMenu1 := TCnMenuItemDef.Create(SCnMenuExploreName + '1', SCnMenuExploreCaption,
    OnExplore, ipAfter, SCnCopyFileNameMenuName + '1');
  FExploreMenu1.OnCreated := OnExploreMenuCreated;
  FMenuHook1.AddMenuItemDef(FExploreMenu1);
{$ENDIF COMPILER6_UP}
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
        {$IFNDEF BCB5}   { TODO : BCB5 下关闭工程页面出错 }
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
        IOTAModule(List[i]).Close // 有时候直接调用 Close 会出错，怀疑是 IDE 的 Bug，故检查是否被修改
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
  strExecute: AnsiString;
begin
  if FileExists(CnOtaGetCurrentSourceFile) then
  begin
    strExecute := AnsiString(Format(ExploreCmdLine, [CnOtaGetCurrentSourceFile]));
    WinExec(PAnsiChar(strExecute), SW_SHOWNORMAL);
  end
  else if DirectoryExists(_CnExtractFileDir(CnOtaGetCurrentSourceFile)) then
  begin
    strExecute := AnsiString(Format(ExploreCmdLine, [_CnExtractFileDir(CnOtaGetCurrentSourceFile)]));
    WinExec(PAnsiChar(strExecute), SW_SHOWNORMAL);
  end;
end;

procedure TCnSrcEditorMisc.OnSelectAll(Sender: TObject);
begin
  ExecuteIDEAction(SEditSelectAllCommand);
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
begin
  // 加入 BlockTools 的子菜单
  FBlockToolMenuItem := MenuItem;
  Wizard := (CnWizardMgr.WizardByClass(TCnSrcEditorEnhance)) as TCnSrcEditorEnhance;
  if Wizard <> nil then
  begin
    if Wizard.BlockTools <> nil then
    begin
      // 此处不能调用UpdateMenu来实行初始化，必须手工复制所有菜单项。
      // Wizard.BlockTools.UpdateMenu(MenuItem, False);
      CloneMenuItem(Wizard.BlockTools.PopupMenu.Items, MenuItem);
      
      // 不用 ImageIndex 因为 ImageList 不对头
      MenuItem.Visible := FAddMenuBlockTools;

      // 不能设置菜单的 ImageList，否则会影响其他菜单项
{     if (MenuItem.Owner <> nil) and (MenuItem.Owner is TMenu) then
      begin
        if (MenuItem.Owner as TMenu).Images = nil then
          (MenuItem.Owner as TMenu).Images := GetIDEImageList;
      end;  }
      
      Exit;
    end;
  end;
  MenuItem.Visible := False;
end;

//------------------------------------------------------------------------------
// 修改自动完成快捷键
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
// 系统文件打开只读保护
//------------------------------------------------------------------------------

procedure TCnSrcEditorMisc.SynchronizeDirs;
var
  I: Integer;
begin
  FActualDirs.Clear;
  for I := 0 to FReadOnlyDirs.Count - 1 do
    FActualDirs.Add(UpperCase(MakePath(ReplaceToActualPath(FReadOnlyDirs[I]))));
end;

procedure TCnSrcEditorMisc.OnSourceEditorNotify(
  SourceEditor: IOTASourceEditor; NotifyType: TCnWizSourceEditorNotifyType;
  EditView: IOTAEditView);
var
  I: Integer;
  EditBuff: IOTAEditBuffer;
begin
  if FActive then
  begin
    // 只读保护
    if FAutoReadOnly and (NotifyType = setOpened) and (SourceEditor <> nil) and
      Supports(SourceEditor, IOTAEditBuffer, EditBuff) then
    for I := 0 to FActualDirs.Count - 1 do
      if AnsiPos(FActualDirs[I], UpperCase(SourceEditor.FileName)) = 1 then
      begin
        EditBuff.IsReadOnly := True;
        Break;
      end;
  end;
end;

//------------------------------------------------------------------------------
// TabControl 标题扩展
//------------------------------------------------------------------------------

{$IFDEF NEED_MODIFIED_TAB}
procedure TCnSrcEditorMisc.DoUpdateTabControlCaption(ClearFlag: Boolean);
var
  I, J: Integer;
  TabControl: TXTabControl;
  EditView: IOTAEditView;
  NewCaption: string;

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

  function GetNewCaption(const ACaption: string; IsModified: Boolean): string;
  begin
    Result := Trim(ACaption);
    if IsModified and (StrRight(Result, 1) <> '*') then
      Result := Result + '*'
    else if not IsModified and (StrRight(Result, 1) = '*') then
      Delete(Result, Length(Result), 1);
  end;
begin
  try
    for I := 0 to FTabControlList.Count - 1 do
      if FTabControlList[I] is TXTabControl then
      begin
        TabControl := TXTabControl(FTabControlList[I]);
        for J := 0 to TabControl.Tabs.Count - 1 do
        begin
          if ClearFlag then
          begin
            // 如果不比较直接赋值，会导致CPU占用100%
            NewCaption := GetNewCaption(TabControl.Tabs[J], False);
            if not SameText(TabControl.Tabs[J], NewCaption) then
              TabControl.Tabs[J] := NewCaption;
          end
          else if TabControl.Tabs.Objects[J] <> nil then
          begin
            EditView := EditControlWrapper.GetEditViewFromTabs(TabControl, J);
            if Assigned(EditView) then
            begin
              NewCaption := GetNewCaption(TabControl.Tabs[J], IsModified(EditView));
              if not SameText(TabControl.Tabs[J], NewCaption) then
                TabControl.Tabs[J] := NewCaption;
            end;
          end;
        end;
      end;
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;
end;

procedure TCnSrcEditorMisc.UpdateTabControlCaption(Sender: TObject);
begin
  if Active and DispModifiedInTab then
    DoUpdateTabControlCaption(False);
end;
{$ENDIF}

//------------------------------------------------------------------------------
// 参数设置
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
  // 不用属性写方法，避免无用的 Update

  AutoReadOnly := Ini.ReadBool(csMisc, csAutoReadOnly, True);
  WizOptions.LoadUserFile(FReadOnlyDirs, SCnReadOnlyDirsFile);
  SynchronizeDirs;
  DispModifiedInTab := Ini.ReadBool(csMisc, csDispModifiedInTab, True);
  FEditorTabMultiLine := Ini.ReadBool(csMisc, csEditorTabMultiLine, False);
  FEditorTabFlatButtons := Ini.ReadBool(csMisc, csEditorTabFlatButtons, False);
  
  FAutoSave := Ini.ReadBool(csMisc, csAutoSave, False);
  FSaveInterval := Ini.ReadInteger(csMisc, csSaveInterval, 2);
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
end;

procedure TCnSrcEditorMisc.LanguageChanged(Sender: TObject);
begin
  inherited;
  FExploreMenu.SetCaption(SCnMenuExploreCaption);
  FCopyFileNameMenu.SetCaption(SCnMenuCopyFileNameMenuCaption);
  FSelAllMenu.SetCaption(SCnMenuSelAllCaption);
  FBlockToolsMenu.SetCaption(SCnMenuBlockToolsCaption);
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
// 属性读写
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
  FMenuHook1.Active := Value;
{$ENDIF COMPILER6_UP}
  UpdateCodeCompletionHotKey;
  UpdateAutoSaveTimer;
{$IFDEF NEED_MODIFIED_TAB}
  if not FActive or not DispModifiedInTab then
    DoUpdateTabControlCaption(True);
{$ENDIF}
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
  {$IFDEF NEED_MODIFIED_TAB}
    if not Value then
      DoUpdateTabControlCaption(True);
  {$ENDIF}
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
        XTabControlClassName, XTabControlName));
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

    TabCtrlPanel := AOwner.FindComponent(TabControlPanelName) as TPanel;

    if TabCtrlPanel = nil then
      Exit;
      
    if Tab.Style = tsFlatButtons then
      TabCtrlPanel.Height := (Tab.RowCount * TabCtrlHeight) - (3 * (Tab.RowCount - 1))
    else
      TabCtrlPanel.Height := (Tab.RowCount * TabCtrlHeight) - (6 * (Tab.RowCount - 1));

    Tab.Height := TabCtrlPanel.Height;
  end;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.
