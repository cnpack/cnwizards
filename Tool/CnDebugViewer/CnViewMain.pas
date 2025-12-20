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

unit CnViewMain;
{ |<PRE>
================================================================================
* 软件名称：CnDebugViewer
* 单元名称：主窗体单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2005.01.01
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Menus, ComCtrls, ActnList, ImgList, ToolWin, Clipbrd, Registry, 
  Tabs, VirtualTrees, CnMdiView, CnLangMgr, CnWizLangID, CnTabSet,
  CnLangStorage, CnHashLangStorage, CnClasses, CnMsgClasses, CnTrayIcon,
  CnWizCfgUtils, CnUDP, CnDebugIntf, CnCRC32 {$IFDEF CAPTURE_STACK}, CnPE, CnRTL {$ENDIF}
  {$IFDEF WIN64}, System.ImageList, System.Actions {$ENDIF};

const
  WM_TAB_MAKE_VISIBLE = WM_USER + $108;

type
  TCnFormSwitch = (fsAdd, fsUpdate, fsDelete, fsActiveChange);
  TCnRunningState = (rsStopped, rsRunning, rsPaused);

  TCnMainViewer = class(TForm)
    statMain: TStatusBar;
    mmMain: TMainMenu;
    F1: TMenuItem;
    actlstMain: TActionList;
    actNew: TAction;
    N1: TMenuItem;
    O1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    actClose: TAction;
    actExit: TAction;
    actSave: TAction;
    N4: TMenuItem;
    D1: TMenuItem;
    S1: TMenuItem;
    N5: TMenuItem;
    X1: TMenuItem;
    actClear: TAction;
    actSelAll: TAction;
    D2: TMenuItem;
    A1: TMenuItem;
    actCopy: TAction;
    C1: TMenuItem;
    actStart: TAction;
    actPause: TAction;
    actStop: TAction;
    S2: TMenuItem;
    P1: TMenuItem;
    T1: TMenuItem;
    actOpen: TAction;
    O2: TMenuItem;
    tlbMain: TToolBar;
    actSwtClose: TAction;
    actSwtCloseAll: TAction;
    actSwtCloseOther: TAction;
    pmSwitch: TPopupMenu;
    C2: TMenuItem;
    A2: TMenuItem;
    O3: TMenuItem;
    ilMain: TImageList;
    btnNew: TToolButton;
    btnOpen: TToolButton;
    btnClose: TToolButton;
    btnSave: TToolButton;
    ToolButton6: TToolButton;
    btnFind: TToolButton;
    btnCopy: TToolButton;
    ToolButton9: TToolButton;
    btnStart: TToolButton;
    btnPause: TToolButton;
    btnStop: TToolButton;
    actExpandAll: TAction;
    N6: TMenuItem;
    E1: TMenuItem;
    actFind: TAction;
    F2: TMenuItem;
    actHelp: TAction;
    actAbout: TAction;
    H1: TMenuItem;
    A3: TMenuItem;
    pnlSwitch: TPanel;
    tsSwitch: TCnTabSet;
    E2: TMenuItem;
    N7: TMenuItem;
    actViewTime: TAction;
    actViewDetail: TAction;
    T2: TMenuItem;
    D3: TMenuItem;
    actGotoFirst: TAction;
    actGotoPrev: TAction;
    actGotoNext: TAction;
    actGotoLast: TAction;
    actGotoPrevLine: TAction;
    actGotoNextLine: TAction;
    N8: TMenuItem;
    F3: TMenuItem;
    N9: TMenuItem;
    P2: TMenuItem;
    L1: TMenuItem;
    N10: TMenuItem;
    L2: TMenuItem;
    actOptions: TAction;
    actFilter: TAction;
    S3: TMenuItem;
    F4: TMenuItem;
    actClearTime: TAction;
    T3: TMenuItem;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    dlgFind: TFindDialog;
    ToolButton2: TToolButton;
    btnGotoFirst: TToolButton;
    btnGotoLast: TToolButton;
    btnGotoPrev: TToolButton;
    btnGotoNext: TToolButton;
    btnGotoPrevLine: TToolButton;
    btnGotoNextLine: TToolButton;
    ToolButton19: TToolButton;
    btnOptions: TToolButton;
    btnFilter: TToolButton;
    ToolButton22: TToolButton;
    btnHelp: TToolButton;
    btnAbout: TToolButton;
    N11: TMenuItem;
    S4: TMenuItem;
    actFindNext: TAction;
    N12: TMenuItem;
    N13: TMenuItem;
    LanguageItem: TMenuItem;
    CnHashLangFileStorage: TCnHashLangFileStorage;
    CnLangManager: TCnLangManager;
    actBookmark: TAction;
    B1: TMenuItem;
    MenuJump: TMenuItem;
    actPrevBookmark: TAction;
    actNextBookmark: TAction;
    N14: TMenuItem;
    X2: TMenuItem;
    X3: TMenuItem;
    btnBookmark: TToolButton;
    btnPrevBookmark: TToolButton;
    btnNextBookmark: TToolButton;
    btn4: TToolButton;
    actClearBookmarks: TAction;
    M1: TMenuItem;
    actExport: TAction;
    dlgSaveExport: TSaveDialog;
    tryIcon: TCnTrayIcon;
    pmTrayIcon: TPopupMenu;
    mniShowMainForm: TMenuItem;
    mniLine1: TMenuItem;
    mniStart: TMenuItem;
    mniPause: TMenuItem;
    mniStop: TMenuItem;
    mniLine2: TMenuItem;
    mniExit: TMenuItem;
    actShowMainForm: TAction;
    btnAutoScroll: TToolButton;
    actAutoScroll: TAction;
    CnUDP: TCnUDP;
    btnClear: TToolButton;
    actViewWatch: TAction;
    Watch1: TMenuItem;
    actSaveMemDump: TAction;
    SaveMemDump1: TMenuItem;
    dlgSaveMemDump: TSaveDialog;
    pnlChildContainer: TPanel;
    actCopyText: TAction;
    actSwtAddToBlack: TAction;
    actSwtAddToWhite: TAction;
    N15: TMenuItem;
    AddToBlackList1: TMenuItem;
    AddtoWhiteList1: TMenuItem;
    mniWindow: TMenuItem;
    mniNone: TMenuItem;
    procedure actNewExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure actStartExecute(Sender: TObject);
    procedure actPauseExecute(Sender: TObject);
    procedure actSwtCloseExecute(Sender: TObject);
    procedure actlstMainUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure tsSwitchChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure actExpandAllExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actSwtCloseAllExecute(Sender: TObject);
    procedure actSwtCloseOtherExecute(Sender: TObject);
    procedure actViewTimeExecute(Sender: TObject);
    procedure actViewDetailExecute(Sender: TObject);
    procedure actGotoFirstExecute(Sender: TObject);
    procedure actGotoLastExecute(Sender: TObject);
    procedure actGotoPrevExecute(Sender: TObject);
    procedure actGotoNextExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure dlgFindFind(Sender: TObject);
    procedure actFindNextExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actGotoPrevLineExecute(Sender: TObject);
    procedure actGotoNextLineExecute(Sender: TObject);
    procedure actBookmarkExecute(Sender: TObject);
    procedure actPrevBookmarkExecute(Sender: TObject);
    procedure actNextBookmarkExecute(Sender: TObject);
    procedure actClearBookmarksExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actClearTimeExecute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure actShowMainFormExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actOptionsExecute(Sender: TObject);
    procedure tsSwitchDblClick(Sender: TObject);
    procedure actAutoScrollExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CnUDPDataReceived(Sender: TComponent; Buffer: Pointer;
      Len: Integer; FromIP: String; Port: Integer);
    procedure actViewWatchExecute(Sender: TObject);
    procedure actSaveMemDumpExecute(Sender: TObject);
    procedure actCopyTextExecute(Sender: TObject);
    procedure actSwtAddToBlackExecute(Sender: TObject);
    procedure actSwtAddToWhiteExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pnlChildContainerDblClick(Sender: TObject);
    procedure mniWindowClick(Sender: TObject);
  private
    FUpdatingSwitch: Boolean;
    FClickingSwitch: Boolean;
    FRunningState: TCnRunningState;
    FThread, FDbgThread: TThread;
    FCloseFromMenu: Boolean;
    FActiveChild: TCnMsgChild;
    function GetCurrentChild: TCnMsgChild;
    function RegisterViewerHotKey: Boolean;

    procedure GotoNode(Tree: TVirtualStringTree; Node: PVirtualNode);
    procedure InitializeLang;
    procedure UpdateStatusBar;
    procedure LogSelfPath;
    function AddToCommaText(const CommaText, ProcessName: string): string;
    procedure ShowAndHideOtherChildren(ExceptChild: TForm);
    procedure ChooseAChildToDisplay(OldTabIndex: Integer);
    procedure LanguageClick(Sender: TObject);
    procedure LanguageChanged(Sender: TObject);
    procedure ActiveFormChanged(Sender: TObject);
    procedure WindowMenuItemClick(Sender: TObject);
    procedure SwitchTabHint(Sender: TObject; Index: Integer; var HintStr: string);
    procedure OnUpdateStore(var Msg: TMessage); message WM_USER_UPDATE_STORE;
    procedure OnNewChildForm(var Msg: TMessage); message WM_USER_NEW_FORM;
    procedure OnHotKey(var Message: TMessage); message WM_HOTKEY;
    procedure OnTabMakeVisible(var Message: TMessage); message WM_TAB_MAKE_VISIBLE;
    procedure OnSetCaptionGlobalLocal(var Message: TMessage); message WM_USER_SET_CAPTION;
    procedure OnShowChild(var Message: TMessage); message WM_USER_SHOW_CHILD;
  protected
    procedure DoCreate; override;
    procedure ThreadTerminated(Sender: TObject);
{$IFDEF CAPTURE_STACK}
    class procedure ExceptionRecorder(ExceptObj: Exception; ExceptAddr: Pointer;
      IsOSException: Boolean; StackList: TCnStackInfoList);
{$ENDIF}
  public
    procedure LaunchThread;
    procedure PauseThread;
    procedure TerminateThread;  
    procedure DestroyThread;

    procedure UpdateFormInSwitch(AForm: TCustomForm; Switch: TCnFormSwitch);
    property UpdatingSwitch: Boolean read FUpdatingSwitch;
    property ClickingSwitch: Boolean read FClickingSwitch;
    property CurrentChild: TCnMsgChild read GetCurrentChild;
  end;

var
  CnMainViewer: TCnMainViewer;

implementation

uses
  CnCommon, CnViewCore, CnGetThread, CnFilterFrm, CnViewOption, CnWizHelp, CnWatchFrm;

{$R *.DFM}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

const
  CnMaxProcessCount = 16;

type
  TCnToolBarHack = class(TToolBar);

procedure TCnMainViewer.actNewExecute(Sender: TObject);
var
  Child: TCnMsgChild;
begin
  if MDIChildCount >= CnMaxProcessCount then
    Exit;
  Child := TCnMsgChild.Create(Application);
  Child.Parent := pnlChildContainer;

  ShowAndHideOtherChildren(Child);
end;

procedure TCnMainViewer.UpdateFormInSwitch(AForm: TCustomForm;
  Switch: TCnFormSwitch);
var
  Index: Integer;
  SwitchName: string;
  ProcIdStr: string;
begin
  if (AForm <> nil) and (AForm is TCnMsgChild) then
  begin
    Index := tsSwitch.Tabs.IndexOfObject(AForm);
    case Switch of
      fsAdd:
        begin
          if Index < 0 then
          begin
            if (AForm as TCnMsgChild).ProcName = '' then
              SwitchName := SCnNoneProcName
            else
              SwitchName := ExtractFileName((AForm as TCnMsgChild).ProcName);

            if (AForm as TCnMsgChild).ProcessID <> 0 then
              tsSwitch.Tabs.AddObject(' ' + SwitchName + ' $' +
                IntToHex((AForm as TCnMsgChild).ProcessID, 2) + ' ', AForm)
            else
              tsSwitch.Tabs.AddObject(' ' + SwitchName + ' ', AForm);
          end;
        end;
      fsUpdate:
        begin
          if Index >= 0 then
          begin
            if (AForm as TCnMsgChild).ProcName = '' then
              SwitchName := SCnNoneProcName
            else
              SwitchName := ExtractFileName((AForm as TCnMsgChild).ProcName);

            if (AForm as TCnMsgChild).ProcessID <> CnInvalidFileProcId then
              ProcIdStr := IntToHex((AForm as TCnMsgChild).ProcessID, 2)
            else
              ProcIdStr := '';

            if ProcIdStr <> '' then
              tsSwitch.Tabs.Strings[Index] := ' ' + SwitchName +
              ' $' + ProcIdStr + ' '
            else
              tsSwitch.Tabs.Strings[Index] := ' ' + SwitchName + ' ';
          end;
        end;
      fsDelete:
        begin
          if Index >= 0 then
            tsSwitch.Tabs.Delete(Index);
        end;
      fsActiveChange:
        begin
          if Index >= 0 then
            tsSwitch.TabIndex := Index;
        end;
    else
      ;
    end;
  end;
end;

procedure TCnMainViewer.FormCreate(Sender: TObject);
var
  Res: TCnCoreInitResults;
  S: string;
begin
{$IFDEF WIN64}
  Caption := Caption + '64';
{$ENDIF}
{$IFDEF DEBUGDEBUGGER}
  Caption := Caption + ' Debug ';
{$ENDIF}

{$IFDEF CAPTURE_STACK}
   Caption := Caption + ' Stack ';
{$ENDIF}

  if not IsLocalMode then
    Caption := Caption + '- (Global)' // 显示为全局模式
  else
    Caption := Caption + '- (Local)'; // 显示为本地模式

  Res := InitializeCore;
  if Res <> ciOK then
  begin
    S := '';
    case Res of
      ciCreateEventFail:
        S := 'Create Event Fail: ' + IntToStr(GetLastError);
      ciCreateMutexFail:
        S := 'Create Mutex Fail: ' + IntToStr(GetLastError);
      ciCreateMapFail:
        S := 'Create FileMapping Fail: ' + IntToStr(GetLastError);
      ciMapViewFail:
        S := 'MapView of File Fail: ' + IntToStr(GetLastError);
    end;
    statMain.Panels[3].Text := S;
  end;

  UpdateFilterToMap;
  InitializeLang;

  CnLangManager.AddChangeNotifier(LanguageChanged);
  Left := 0;
  Width := Screen.Width;
  Top := 0;
  Height := Screen.Height - 25;
  Application.Title := Caption;
  statMain.Panels[1].Text := Format(SCnCPUSpeedFmt, [CPUClock]);

  Screen.OnActiveFormChange := ActiveFormChanged;
  if SysDebugExists then
    statMain.Panels[3].Text := SCnDebuggerExists;

  tsSwitch.ShowTabHint := True;
  tsSwitch.OnTabHint := SwitchTabHint;

  // 创建托盘栏图标
  tryIcon.Hint := Caption;
  tryicon.Active := CnViewerOptions.ShowTrayIcon;
  tryIcon.AutoHide := CnViewerOptions.MinToTrayIcon;

  CnUDP.LocalPort := CnViewerOptions.UDPPort;

  // Add Sesame 2008-1-18 还原窗口位置
  if CnViewerOptions.SaveFormPosition then
  begin
    case CnViewerOptions.WinState of
      0:
        begin
          Self.Top := CnViewerOptions.Top;
          Self.Left := CnViewerOptions.Left;
          Self.Height := CnViewerOptions.Height;
          Self.Width := CnViewerOptions.Width;

          if Screen.MonitorCount = 1 then // 单显示器下限定位置免得找不到
          begin
            if Self.Top > Screen.Height - 25 then // 太下面
              Self.Top := 0;
            if Self.Left > Screen.Width then      // 太右边
              Self.Left := 0;
            if Self.Top + Self.Height < 0 then    // 太上面
              Self.Top := 0;
            if Self.Left + Self.Width < 0 then    // 太左边
              Self.Left := 0;
          end;
        end;
      1: PostMessage(Self.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
      2: PostMessage(Self.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    end;
  end
  else // 默认位置及大小
  begin
    Left := 0; Width := Screen.Width;
    Top := 0; Height := Screen.Height - 25;
  end;

  // 处理启动时最小化选项
  if CnViewerOptions.StartMin then
    PostMessage(Self.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);

  // 写注册表记录 CnDebugViewer 的所在路径
  LogSelfPath;
  actAutoScroll.Checked := CnViewerOptions.AutoScroll;

  // 注册显示窗体热键
  if not RegisterViewerHotKey then
    ErrorDlg(SCnRegisterHotKeyError);
end;

procedure TCnMainViewer.actExitExecute(Sender: TObject);
begin
  FCloseFromMenu := True;
  Application.Terminate;
end;

procedure TCnMainViewer.FormDestroy(Sender: TObject);
begin
  // Add Sesame 2008.01.18 记录窗口位置
  with CnViewerOptions do
  begin
    if SaveFormPosition then
    begin
      WinState := Ord(Self.WindowState);
      case WinState of
        0:
          begin
            Top := Self.Top;
            Left := Self.Left;
            Height := Self.Height;
            Width := Self.Width;
          end;
        1: ;
        2: ;
      end;
    end;
  end;

  if GetCWUseCustomUserDir then
    SaveOptions(GetCWUserPath + SCnOptionFileName)
  else
    SaveOptions(_CnExtractFilePath(Application.ExeName) + SCnOptionFileName);
  CnLangManager.RemoveChangeNotifier(LanguageChanged);

  // 注销热键
  UnregisterHotKey(Handle, SCnHotKeyId);
end;

procedure TCnMainViewer.DestroyThread;
begin
  TerminateThread;

  FRunningState := rsStopped;
  UpdateStatusBar;
end;

procedure TCnMainViewer.actStopExecute(Sender: TObject);
begin
  DestroyThread;
end;

procedure TCnMainViewer.LaunchThread;
begin
  if FThread = nil then
  begin
    FThread := TGetDebugThread.Create(True);
    FThread.FreeOnTerminate := True;
    FThread.OnTerminate := ThreadTerminated;
    FThread.Resume;
  end
  else
    (FThread as TGetDebugThread).Paused := False;

  if CnViewerOptions.IgnoreODString then
    Exit;

  if FDbgThread = nil then
  begin
    FDbgThread := TDbgGetDebugThread.Create(True);
    FDbgThread.FreeOnTerminate := True;
    FDbgThread.OnTerminate := ThreadTerminated;
    FDbgThread.Resume;
  end
  else
    (FDbgThread as TGetDebugThread).Paused := False;

  FRunningState := rsRunning;
  UpdateStatusBar;
end;

procedure TCnMainViewer.PauseThread;
begin
  if FThread <> nil then
    (FThread as TGetDebugThread).Paused := True;
  if FDbgThread <> nil then
    (FDbgThread as TDbgGetDebugThread).Paused := True;

  FRunningState := rsPaused;
  UpdateStatusBar;
end;

procedure TCnMainViewer.actStartExecute(Sender: TObject);
begin
  LaunchThread;
end;

procedure TCnMainViewer.actPauseExecute(Sender: TObject);
begin
  PauseThread;
end;

procedure TCnMainViewer.actSwtCloseExecute(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := tsSwitch.TabIndex;
  if tsSwitch.Tabs.Objects[tsSwitch.TabIndex] <> nil then
  begin
    TCustomForm(tsSwitch.Tabs.Objects[tsSwitch.TabIndex]).Close;
    ChooseAChildToDisplay(Idx);
  end;
end;

procedure TCnMainViewer.actlstMainUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if (Action = actStart) then
    (Action as TCustomAction).Enabled := (FThread = nil) or (FThread as TGetDebugThread).Paused
  else if (Action = actPause) then
    (Action as TCustomAction).Enabled := (FThread <> nil) and not (FThread as TGetDebugThread).Paused
  else if (Action = actStop) then
    (Action as TCustomAction).Enabled := (FThread <> nil)
  else if (Action = actSwtClose) or (Action = actSwtCloseOther) or (Action = actSwtCloseAll) or
    (Action = actSwtAddToBlack) or (Action = actSwtAddToWhite) then
    (Action as TCustomAction).Enabled := tsSwitch.Tabs.Count > 0
  else if (Action = actSave) or (Action = actClose) then
    (Action as TCustomAction).Enabled := CurrentChild <> nil
  else if (Action = actViewTime) then
  begin
    (Action as TCustomAction).Enabled := CurrentChild <> nil;
    (Action as TCustomAction).Checked := (Action as TCustomAction).Enabled and CurrentChild.pnlTime.Visible;
  end
  else if (Action = actViewDetail) then
  begin
    (Action as TCustomAction).Enabled := CurrentChild <> nil;
    (Action as TCustomAction).Checked := (Action as TCustomAction).Enabled and CurrentChild.pnlDetail.Visible;
  end
  else if (Action = actClear) or (Action = actClearTime) then
    (Action as TCustomAction).Enabled := CurrentChild <> nil
  else if (Action = actGotoFirst) or (Action = actGotoPrev) or
    (Action = actGotoNext) or (Action = actGotoLast) or (Action = actGotoPrevLine)
    or (Action = actGotoNextLine) then
  begin
    (Action as TCustomAction).Enabled := (CurrentChild <> nil) and (CurrentChild.MsgTree.TotalCount > 0);
  end
  else if (Action = actCopy) or (Action = actCopyText) then
    (Action as TCustomAction).Enabled := (CurrentChild <> nil) and (CurrentChild.mmoDetail.Text <> '')
  else if (Action = actSaveMemDump) then
  begin
    (Action as TCustomAction).Enabled := (CurrentChild <> nil) and (CurrentChild.MsgTree.SelectedCount = 1)
      and (CurrentChild.SelectedItem <> nil) and (CurrentChild.SelectedItem.MsgType = cmtMemoryDump);
  end
  else if (Action = actBookmark) then
  begin
    (Action as TCustomAction).Enabled := (CurrentChild <> nil) and (CurrentChild.MsgTree.SelectedCount = 1);
  end
  else if (Action = actPrevBookmark) or (Action = actNextBookmark) or (Action = actClearBookmarks) then
    (Action as TCustomAction).Enabled := (CurrentChild <> nil) and (CurrentChild.MsgTree.TotalCount > 0) and CurrentChild.HasBookmarks
  else
    (Action as TCustomAction).Enabled := True;

  Handled := True;
end;

procedure TCnMainViewer.tsSwitchChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  if (Sender as TTabSet).Tabs.Objects[NewTab] <> nil then
  begin
    FActiveChild := ((Sender as TTabSet).Tabs.Objects[NewTab]) as TCnMsgChild;
    ShowAndHideOtherChildren(FActiveChild);
  end;
end;

function TCnMainViewer.GetCurrentChild: TCnMsgChild;
begin
  Result := TCnMsgChild(FActiveChild);
end;

procedure TCnMainViewer.actExpandAllExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.MsgTree.FullExpand;
end;

procedure TCnMainViewer.actCloseExecute(Sender: TObject);
var
  Idx: Integer;
begin
  if CurrentChild <> nil then
  begin
    Idx := tsSwitch.TabIndex;
    CurrentChild.Close;
    // 更新 FActiveChild 与 Tab
    ChooseAChildToDisplay(Idx);
  end;
end;

procedure TCnMainViewer.actClearExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.ClearStores;
end;

procedure TCnMainViewer.actClearTimeExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.ClearTimes;  
end;

procedure TCnMainViewer.actSwtCloseAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := tsSwitch.Tabs.Count - 1 downto 0 do
    if tsSwitch.Tabs.Objects[I] <> nil then
      TCustomForm(tsSwitch.Tabs.Objects[I]).Close;

  FActiveChild := nil;
end;

procedure TCnMainViewer.actSwtCloseOtherExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := tsSwitch.Tabs.Count - 1 downto tsSwitch.TabIndex + 1 do
    if tsSwitch.Tabs.Objects[I] <> nil then
      TCustomForm(tsSwitch.Tabs.Objects[I]).Close;

  for I := tsSwitch.TabIndex - 1 downto 0 do
    if tsSwitch.Tabs.Objects[I] <> nil then
      TCustomForm(tsSwitch.Tabs.Objects[I]).Close;

  ChooseAChildToDisplay(0);
end;

procedure TCnMainViewer.actViewTimeExecute(Sender: TObject);
var
  Column, W: Integer;
begin
  if CurrentChild <> nil then
  begin
    CurrentChild.IsResizing := True;
    try
      CurrentChild.pnlTime.Visible := not CurrentChild.pnlTime.Visible;
      CurrentChild.splTime.Visible := not CurrentChild.splTime.Visible;
      (Sender as TCustomAction).Checked := CurrentChild.pnlTime.Visible;
      Column := CurrentChild.MsgTree.Header.MainColumn;
      if CurrentChild.pnlTime.Visible then W := 0 - CurrentChild.pnlTime.Width
      else W := CurrentChild.pnlTime.Width;

      CurrentChild.MsgTree.Header.Columns[Column].Width :=
        CurrentChild.MsgTree.Header.Columns[Column].Width + W;
      if CurrentChild.pnlTime.Visible then
        CurrentChild.splTime.Left := CurrentChild.MsgTree.Width;

      CurrentChild.pnlTree.OnResize(CurrentChild.pnlTree);
    finally
      CurrentChild.IsResizing := False;
    end;            
  end;
end;

procedure TCnMainViewer.actViewDetailExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
  begin
    CurrentChild.IsResizing := True;
    try
      CurrentChild.pnlDetail.Visible := not CurrentChild.pnlDetail.Visible;
      CurrentChild.splDetail.Visible := not CurrentChild.splDetail.Visible;
      if CurrentChild.pnlDetail.Visible then
        CurrentChild.splDetail.Top := CurrentChild.Height - CurrentChild.pnlDetail.Height;
      (Sender as TCustomAction).Checked := CurrentChild.pnlDetail.Visible;
    finally
      CurrentChild.IsResizing := False;
    end;                
  end;
end;

procedure TCnMainViewer.actGotoFirstExecute(Sender: TObject);
begin
  if (CurrentChild <> nil) then
    GotoNode(CurrentChild.MsgTree, CurrentChild.MsgTree.GetFirst);
end;

procedure TCnMainViewer.actGotoLastExecute(Sender: TObject);
begin
  if (CurrentChild <> nil) then
    GotoNode(CurrentChild.MsgTree, CurrentChild.MsgTree.GetLast);
end;

procedure TCnMainViewer.GotoNode(Tree: TVirtualStringTree;
  Node: PVirtualNode);
begin
  if (Tree <> nil) and (Node <> nil) and (Tree.TotalCount > 0) then
  begin
    if Tree.FocusedNode <> nil then
      Tree.Selected[Tree.FocusedNode] := False;
    Tree.Selected[Node] := True;
    Tree.FocusedNode := Node;
{$IFDEF WIN64}
    Tree.ScrollIntoView(Node, False);
{$ENDIF}
  end;
end;

procedure TCnMainViewer.actGotoPrevExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    GotoNode(CurrentChild.MsgTree,
      CurrentChild.MsgTree.GetPrevious(CurrentChild.MsgTree.FocusedNode));
end;

procedure TCnMainViewer.actGotoNextExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    GotoNode(CurrentChild.MsgTree,
      CurrentChild.MsgTree.GetNext(CurrentChild.MsgTree.FocusedNode));
end;

procedure TCnMainViewer.actOpenExecute(Sender: TObject);
var
  Child: TCnMsgChild;
begin
  if dlgOpen.Execute then
  begin
    Child := TCnMsgChild.Create(Application);
    Child.Parent := pnlChildContainer;
    ShowAndHideOtherChildren(Child);

    Child.LoadFromFile(dlgOpen.FileName);
    Child.Store.ProcessID := CnInvalidFileProcId;
    Child.ProcessID := CnInvalidFileProcId;
    Child.ProcName := _CnExtractFileName(dlgOpen.FileName);

    UpdateFormInSwitch(Child, fsAdd);
  end;
end;

procedure TCnMainViewer.actSaveExecute(Sender: TObject);
var
  FileName: string;
begin
  if CurrentChild <> nil then
  begin
    if dlgSave.Execute then
    begin
      FileName := dlgSave.FileName;
      if _CnExtractFileExt(FileName) = '' then
        FileName := _CnChangeFileExt(FileName, '.xml');
      CurrentChild.SaveToFile(FileName);
    end;
  end;
end;

procedure TCnMainViewer.actFilterExecute(Sender: TObject);
begin
  // 过滤设置
  with TCnSenderFilterFrm.Create(nil) do
  begin
    LoadFromOptions;
    if ShowModal = mrOK then
    begin
      SaveToOptions;
      // 更新 Map 中的过滤条件
      UpdateFilterToMap;
    end;
    Free;
  end;
end;

procedure TCnMainViewer.actFindExecute(Sender: TObject);
begin
  dlgFind.Execute;
end;

procedure TCnMainViewer.actCopyExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    Clipboard.AsText := CurrentChild.SelectedContent;
end;

procedure TCnMainViewer.dlgFindFind(Sender: TObject);
begin
  if (CurrentChild <> nil) and (Trim(dlgFind.FindText) <> '') then
  begin
    CurrentChild.FindNode(dlgFind.FindText, frDown in dlgFind.Options);
    CurrentChild.cbbSearch.Text := dlgFind.FindText;
  end;
end;

procedure TCnMainViewer.actFindNextExecute(Sender: TObject);
begin
  if (CurrentChild <> nil) and (Trim(dlgFind.FindText) <> '') then
    CurrentChild.FindNode(dlgFind.FindText, frDown in dlgFind.Options);
end;

procedure TCnMainViewer.actAboutExecute(Sender: TObject);
begin
{$IFDEF WIN64}
  MessageBox(Application.Handle, PChar(StringReplace(SCnDebugViewerAbout,
    'CnDebugViewer', 'CnDebugViewer 64-Bit', [rfReplaceAll])),
    PChar(SCnDebugViewerAboutCaption), MB_OK or MB_ICONINFORMATION);
{$ELSE}
  MessageBox(Application.Handle, PChar(SCnDebugViewerAbout),
    PChar(SCnDebugViewerAboutCaption), MB_OK or MB_ICONINFORMATION);
{$ENDIF}
end;

procedure TCnMainViewer.actGotoPrevLineExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.FindNode('-', False, True);
end;

procedure TCnMainViewer.actGotoNextLineExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.FindNode('-', True, True);
end;

procedure TCnMainViewer.DoCreate;
var
  LangID: DWORD;
  I: Integer;
begin
  if CnLanguageManager <> nil then
  begin
    CnHashLangFileStorage.LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangDir;
    LangID := GetWizardsLanguageID;

    for I := 0 to CnLanguageManager.LanguageStorage.LanguageCount - 1 do
    begin
      if CnLanguageManager.LanguageStorage.Languages[I].LanguageID = LangID then
      begin
        CnLanguageManager.CurrentLanguageIndex := I;
        TranslateStrings;
        Break;
      end;
    end;
  end;
  inherited;
end;

procedure TCnMainViewer.InitializeLang;
var
  I: Integer;
  MenuItem: TMenuItem;
begin
  if CnHashLangFileStorage.LanguageCount > 0 then
  begin
    LanguageItem.Visible := True;
    for I := 0 to CnHashLangFileStorage.LanguageCount - 1 do
    begin
      MenuItem := TMenuItem.Create(Self);
      MenuItem.Caption := CnHashLangFileStorage.Languages[I].LanguageName;
      MenuItem.Tag := I;
      
      if I = CnLangManager.CurrentLanguageIndex then
        MenuItem.Checked := True;
      MenuItem.OnClick := LanguageClick;
      LanguageItem.Add(MenuItem);
    end;
  end
  else
    LanguageItem.Visible := False;
end;

procedure TCnMainViewer.LanguageClick(Sender: TObject);
var
  I: Integer;
begin
  CnLangManager.CurrentLanguageIndex := (Sender as TMenuItem).Tag;
  for I := 0 to CnHashLangFileStorage.LanguageCount - 1 do
    LanguageItem.Items[I].Checked := I = CnLangManager.CurrentLanguageIndex;
end;

procedure TCnMainViewer.LanguageChanged(Sender: TObject);
var
  AChild: TCnMsgChild;
  I: Integer;
begin
  TranslateStrings;
  UpdateStatusBar;
  statMain.Panels[1].Text := Format(SCnCPUSpeedFmt, [CPUClock]);
  if SysDebugExists then
    statMain.Panels[3].Text := SCnDebuggerExists
  else
    statMain.Panels[3].Text := '';

  for I := 0 to Self.MDIChildCount - 1 do
  begin
    if Self.MDIChildren[I] is TCnMsgChild then
    begin
      AChild := Self.MDIChildren[I] as TCnMsgChild;
      if AChild <> nil then
      begin
        AChild.UpdateBookmarkMenu;

        if (AChild.MsgTree <> nil)
          and Assigned(AChild.MsgTree.OnChange)
          and (AChild.MsgTree.FocusedNode <> nil)
          and (AChild.MsgTree.Selected[AChild.MsgTree.FocusedNode]) then
          AChild.MsgTree.OnChange(AChild.MsgTree, AChild.MsgTree.FocusedNode);

        if AChild.TimeTree.Focused and Assigned(AChild.TimeTree.OnChange) then
          AChild.TimeTree.OnChange(AChild.TimeTree, nil);
      end;
    end;
  end;

  PostMessage(Handle, WM_USER_SET_CAPTION, 0, 0);
end;

procedure TCnMainViewer.UpdateStatusBar;
begin
  case FRunningState of
    rsRunning: statMain.Panels[2].Text := SCnThreadRunning;
    rsStopped: statMain.Panels[2].Text := SCnThreadStopped;
    rsPaused:  statMain.Panels[2].Text := SCnThreadPaused;
  end;
end;

procedure TCnMainViewer.actBookmarkExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.ToggleBookmark;
end;

procedure TCnMainViewer.ActiveFormChanged(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.UpdateBookmarkToMainMenu;
end;

procedure TCnMainViewer.actPrevBookmarkExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.GotoPrevBookmark;
end;

procedure TCnMainViewer.actNextBookmarkExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.GotoNextBookmark;
end;

procedure TCnMainViewer.actClearBookmarksExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.ClearAllBookmarks;
end;

procedure TCnMainViewer.actHelpExecute(Sender: TObject);
begin
  if not ShowHelp(SCnDbgHelpIniTopic, SCnDbgHelpIniSecion) then
    ErrorDlg(SCnNoHelpofThisLang);
end;

procedure TCnMainViewer.OnUpdateStore(var Msg: TMessage);
var
  I: Integer;
begin
  for I := 0 to CnMsgManager.Count - 1 do
    if CnMsgManager.Store[I].Updating then
      CnMsgManager.Store[I].EndUpdate;
end;

procedure TCnMainViewer.OnNewChildForm(var Msg: TMessage);
var
  AChild: TCnMsgChild;
begin
  if not (csDestroying in ComponentState) then
  begin
    AChild := TCnMsgChild.Create(Application);
    AChild.Parent := pnlChildContainer;
    ShowAndHideOtherChildren(AChild);

    AChild.Store := TCnMsgStore(Msg.WParam);
    UpdateFormInSwitch(AChild, fsUpdate);
    AChild.RequireRefreshTime;
  end;
end;

procedure TCnMainViewer.actExportExecute(Sender: TObject);
const
  CRLF = #13#10;
var
  S: TFileName;
  FS: TFileStream;

  procedure WriteStrToFileStream(const FSMsg: string);
  begin
    if FSMsg <> '' then
      FS.Write(FSMsg[1], Length(FSMsg) * SizeOf(Char));
    FS.Write(CRLF, 2);
  end;

  procedure ExportToTextFile(AStore: TCnMsgStore; AFileName: string);
  var
    I: Integer;
  begin
    for I := 0 to AStore.MsgCount - 1 do
    begin
      WriteStrToFileStream('--------------------------------------------------------------------------------');
      WriteStrToFileStream(CurrentChild.DescriptionOfMsg(I, AStore.Msgs[I]));
      WriteStrToFileStream('');
    end;
  end;

  procedure ExportToCSVFile(AStore: TCnMsgStore; AFileName: string);
  var
    I: Integer;
    Msg: string;
    AMsgItem: TCnMsgItem;
  begin
    WriteStrToFileStream(SCnCSVFormatHeader);
    for I := 0 to AStore.MsgCount - 1 do
    begin
      AMsgItem := AStore.Msgs[I];
      // 替换掉回车和逗号
      Msg := StringReplace(AMsgItem.Msg, #13#10, ' ', [rfIgnoreCase, rfReplaceAll]);
      Msg := StringReplace(Msg, ',', ' ', [rfIgnoreCase, rfReplaceAll]);

      WriteStrToFileStream(Format('%d,%d,%s,$%x,$%x,%s,%s,%s', [I + 1, AMsgItem.Level,
        SCnMsgTypeDescArray[AMsgItem.MsgType]^, AMsgItem.ThreadId, AMsgItem.ProcessId,
        AMsgItem.Tag, GetLongTimeDesc(AMsgItem), Msg]));
    end;
  end;

  procedure ExportToHTMFile(AStore: TCnMsgStore; AFileName: string);
  var
    I: Integer;
    Msg: string;
    AMsgItem: TCnMsgItem;
  begin
    WriteStrToFileStream(Format(SCnHTMFormatHeader, [SCnHTMFormatStyle, AFileName, SCnHTMFormatCharset]));
    WriteStrToFileStream(SCnHTMFormatTableHead);
    for I := 0 to AStore.MsgCount - 1 do
    begin
      AMsgItem := AStore.Msgs[I];

      // 替换掉尖括号和回车
      Msg := StringReplace(AMsgItem.Msg, '<', '&lt;', [rfIgnoreCase, rfReplaceAll]);
      Msg := StringReplace(AMsgItem.Msg, '>', '&gt;', [rfIgnoreCase, rfReplaceAll]);
      Msg := StringReplace(AMsgItem.Msg, #13#10, '<BR>', [rfIgnoreCase, rfReplaceAll]);

      WriteStrToFileStream(Format(SCnHTMFormatLine, [I + 1, AMsgItem.Level,
        SCnMsgTypeDescArray[AMsgItem.MsgType]^, AMsgItem.ThreadId, AMsgItem.ProcessId, AMsgItem.Tag,
        GetLongTimeDesc(AMsgItem), Msg]));
    end;
    WriteStrToFileStream(SCnHTMFormatEnd);
  end;
begin
  if CurrentChild = nil then Exit;

  if dlgSaveExport.Execute then
  begin
    S := dlgSaveExport.FileName;

    try
      FS := TFileStream.Create(S, fmCreate or fmOpenWrite);
      case dlgSaveExport.FilterIndex of
        1: // TXT
          begin
            S := _CnChangeFileExt(S, '.txt');
            ExportToTextFile(CurrentChild.Store, S);
          end;
        2: // CSV
          begin
            S := _CnChangeFileExt(S, '.csv');
            ExportToCSVFile(CurrentChild.Store, S);
          end;
        3: // HTML
          begin
            S := _CnChangeFileExt(S, '.htm');
            ExportToHTMFile(CurrentChild.Store, S);
          end;
        4: // RTF
          begin
            S := _CnChangeFileExt(S, '.rtf');
            ErrorDlg('Sorry. NOT Implemented.');
          end;
      end;
    finally
      FS.Free;
    end;
  end;
end;

procedure TCnMainViewer.actShowMainFormExecute(Sender: TObject);
begin
  tryIcon.ShowApplication;
end;

procedure TCnMainViewer.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;
  if tryIcon.Active then
  begin
    CanClose := FCloseFromMenu or not CnViewerOptions.CloseToTrayIcon;
    if not CanClose then
      tryIcon.HideApplication;
  end;
end;

procedure TCnMainViewer.actOptionsExecute(Sender: TObject);
var
  I: Integer;
begin
  // 过滤设置
  with TCnViewerOptionsFrm.Create(nil) do
  begin
    LoadFromOptions;
    if ShowModal = mrOK then
    begin
      SaveToOptions;

      tryIcon.Active := CnViewerOptions.ShowTrayIcon;
      tryIcon.AutoHide := CnViewerOptions.MinToTrayIcon;
      if not RegisterViewerHotKey then
        ErrorDlg(SCnRegisterHotKeyError);

      CnUDP.LocalPort := CnViewerOptions.UDPPort;
      if FontChanged then
      begin
        for I := 0 to Self.MDIChildCount - 1 do
        begin
          if Self.MDIChildren[I] is TCnMsgChild then
            (Self.MDIChildren[I] as TCnMsgChild).InitFont;
        end;
      end;
    end;
    Free;
  end;
end;

procedure TCnMainViewer.OnHotKey(var Message: TMessage);
begin
  inherited;
  if (Message.WParam = SCnHotKeyId) and (Message.LParamHi <> $FF) then
  begin
    // Ignore some 255 reversed VK.
    tryIcon.ShowApplication;
  end;
end;

function TCnMainViewer.RegisterViewerHotKey: Boolean;
var
  HotKey: Cardinal;
  Modifiers: Cardinal;
begin
  UnregisterHotKey(Handle, SCnHotKeyId);
  if CnViewerOptions.MainShortCut = 0 then
  begin
    Result := True;
    Exit;
  end;

  HotKey := CnViewerOptions.MainShortCut and not (scShift + scCtrl + scAlt);
  Modifiers := 0;
  if CnViewerOptions.MainShortCut and scShift <> 0 then
    Modifiers := Modifiers + MOD_SHIFT;
  if CnViewerOptions.MainShortCut and scCtrl <> 0 then
    Modifiers := Modifiers + MOD_CONTROL;
  if CnViewerOptions.MainShortCut and scAlt <> 0 then
    Modifiers := Modifiers + MOD_ALT;
  Result := RegisterHotKey(Handle, SCnHotKeyId, Modifiers, HotKey);
end;

procedure TCnMainViewer.LogSelfPath;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\CnPack\CnDebug', True) then
      Reg.WriteString('CnDebugViewer', '"' + ParamStr(0) + '"');
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
end;

procedure TCnMainViewer.tsSwitchDblClick(Sender: TObject);
var
  P: TPoint;
begin
  P := tsSwitch.ScreenToClient(Mouse.CursorPos);
  if tsSwitch.ItemAtPos(P) >= 0 then
  begin
    actSwtClose.Execute;
    PostMessage(Handle, WM_TAB_MAKE_VISIBLE, 0, 0);
  end;
end;

procedure TCnMainViewer.actAutoScrollExecute(Sender: TObject);
begin
  actAutoScroll.Checked := not actAutoScroll.Checked;
  CnViewerOptions.AutoScroll := actAutoScroll.Checked;
end;

procedure TCnMainViewer.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  DestroyThread;
  actClose.Execute;
end;

procedure TCnMainViewer.CnUDPDataReceived(Sender: TComponent;
  Buffer: Pointer; Len: Integer; FromIP: String; Port: Integer);
var
  ProcName: string;
  ProcId: Cardinal;
  AStore: TCnMsgStore;
  ADesc: TCnMsgDesc;
begin
  if (FRunningState = rsPaused) or not CnViewerOptions.EnableUDPMsg then
    Exit;
    
  ProcName := Format('%s:%d', [FromIP, Port]);
  ProcId := StrCRC32(0, ProcName);

  AStore := CnMsgManager.FindByProcName(ProcName);
  if AStore = nil then
  begin
    if Application.MainForm <> nil then
      if not (csDestroying in Application.MainForm.ComponentState) then
      begin
        AStore := CnMsgManager.AddStore(ProcId, ProcName);
{$IFDEF WIN64}
        PostMessage(Application.MainForm.Handle, WM_USER_NEW_FORM, NativeInt(AStore), 0);
{$ELSE}
        PostMessage(Application.MainForm.Handle, WM_USER_NEW_FORM, Integer(AStore), 0);
{$ENDIF}
      end;
  end;

  // 如无空余的或对应的 Store，则不输出
  if AStore <> nil then
  begin
    FillChar(ADesc, SizeOf(ADesc), 0);

    // 无对应信息，因此需要手工填写
    ADesc.Annex.Level := CnDefLevel;
    ADesc.Annex.MsgType := Ord(cmtUDPMsg);
    
    // 无 ThreadId、无 Tag
    Move(Buffer^, ADesc.Msg, Len);

    // 无发送端时间戳，近似采用接收端时间戳
    ADesc.Annex.TimeStampType := Ord(ttDateTime);
    ADesc.Annex.MsgDateTime := Date + Time;
    ADesc.Length := Len + SizeOf(TCnMsgAnnex) + SizeOf(Integer) + 1;
    AStore.AddMsgDesc(@ADesc);
  end;
end;

procedure TCnMainViewer.OnTabMakeVisible(var Message: TMessage);
begin
  tsSwitch.MakeTabVisible;
end;

procedure TCnMainViewer.OnSetCaptionGlobalLocal(var Message: TMessage);
begin
{$IFDEF WIN64}
  Caption := Caption + '64';
{$ENDIF}
  if not IsLocalMode then
    Caption := Caption + '- (Global)' // 显示为全局模式
  else
    Caption := Caption + '- (Local)'; // 显示为本地模式
end;

procedure TCnMainViewer.SwitchTabHint(Sender: TObject; Index: Integer;
  var HintStr: string);
begin
  if tsSwitch.Tabs.Objects[Index] <> nil then
  begin
    HintStr := TCnMsgChild(tsSwitch.Tabs.Objects[Index]).ProcName;
  end;
end;

procedure TCnMainViewer.actViewWatchExecute(Sender: TObject);
begin
  if CnWatchForm = nil then
    CreateWatchForm;

  if not CnWatchForm.Visible then
    CnWatchForm.Show;

  CnWatchForm.BringToFront;
end;

procedure TCnMainViewer.actSaveMemDumpExecute(Sender: TObject);
var
  Item: TCnMsgItem;
  Stream: TMemoryStream;
  S: string;
begin
  if CurrentChild <> nil then
  begin
    Item := CurrentChild.SelectedItem;
    if (Item <> nil) and (Item.MsgType = cmtMemoryDump) and
      (Item.MemDumpAddr <> nil) and (Item.MemDumpLength > 0) then
    begin
      if dlgSaveMemDump.Execute then
      begin
        Stream := TMemoryStream.Create;
        try
          Stream.Write(Item.MemDumpAddr^, Item.MemDumpLength);
          S := dlgSaveMemDump.FileName;
          if dlgSaveMemDump.FilterIndex = 1 then
            S := _CnChangeFileExt(S, '.bin');
          Stream.SaveToFile(S);
        finally
          Stream.Free;
        end;
      end;
    end
  end;
end;

procedure TCnMainViewer.ChooseAChildToDisplay(OldTabIndex: Integer);
var
  I: Integer;
begin
  // 关闭窗口后更新 FActiveChild 与 Tab。注意此时 Tabs.Count 已经减少
  // 拿当前 Tab 的前一个作为显示内容，如果当前 Tab 是首个（0），则用 0
  if OldTabIndex > 0 then
    Dec(OldTabIndex)
  else if (OldTabIndex < 0) or (tsSwitch.Tabs.Count = 0) then
  begin
    FActiveChild := nil;
    Exit;
  end;

  FActiveChild := TCnMsgChild(tsSwitch.Tabs.Objects[OldTabIndex]);
  FActiveChild.Visible := True;
  FActiveChild.BringToFront;

  for I := 0 to pnlChildContainer.ControlCount - 1 do
  begin
    if pnlChildContainer.Controls[I] <> FActiveChild then
    begin
      pnlChildContainer.Controls[I].SendToBack;
      pnlChildContainer.Controls[I].Visible := False;
    end;
  end;
end;

procedure TCnMainViewer.actCopyTextExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    Clipboard.AsText := CurrentChild.SelectedText;
end;

procedure TCnMainViewer.actSwtAddToBlackExecute(Sender: TObject);
begin
  if (CurrentChild <> nil) and (CurrentChild.ProcName <> '') then
    CnViewerOptions.BlackList := AddToCommaText(CnViewerOptions.BlackList, ExtractFileName(CurrentChild.ProcName));
end;

function TCnMainViewer.AddToCommaText(const CommaText,
  ProcessName: string): string;
var
  List: TStrings;
begin
  Result := CommaText;
  List := TStringList.Create;
  try
    List.CommaText := CommaText;
    if List.IndexOf(ProcessName) >= 0 then
      Exit;

    List.Add(ProcessName);
    Result := List.CommaText;
  finally
    List.Free;
  end;
end;

procedure TCnMainViewer.actSwtAddToWhiteExecute(Sender: TObject);
begin
  if (CurrentChild <> nil) and (CurrentChild.ProcName <> '') then
    CnViewerOptions.WhiteList := AddToCommaText(CnViewerOptions.WhiteList, ExtractFileName(CurrentChild.ProcName));
end;

procedure TCnMainViewer.TerminateThread;
begin
  DebugDebuggerLog('MainViewer Before TerminateThread');
  if FThread <> nil then
  begin
    FThread.Terminate;
    try
      FThread.WaitFor;
    except
      DebugDebuggerLog('MainViewer FThread WaitFor Exception');
    end;
    // FThread := nil;
  end;

  if FDbgThread <> nil then
  begin
    FDbgThread.Terminate;
    try
      FDbgThread.WaitFor;
    except
      DebugDebuggerLog('MainViewer FDbgThread WaitFor Exception');
    end;
    // FDbgThread := nil;
  end;
  DebugDebuggerLog('MainViewer After TerminateThread');
end;

procedure TCnMainViewer.ShowAndHideOtherChildren(ExceptChild: TForm);
var
  I: Integer;
begin
  ExceptChild.Show;
  ExceptChild.BringToFront;
{$IFDEF WIN64}
  ExceptChild.Realign;
{$ENDIF}

  for I := 0 to pnlChildContainer.ControlCount - 1 do
  begin
    if pnlChildContainer.Controls[I] <> ExceptChild then
    begin
      pnlChildContainer.Controls[I].SendToBack;
      pnlChildContainer.Controls[I].Visible := False;
    end;
  end;
end;

procedure TCnMainViewer.ThreadTerminated(Sender: TObject);
begin
  if Sender = FThread then
  begin
    FThread := nil;
    DebugDebuggerLog('MainViewer OnThreadTerminated FThread Set to nil');
  end
  else if Sender = FDbgThread then
  begin
    FDbgThread := nil;
    DebugDebuggerLog('MainViewer OnThreadTerminated FDbgThread Set to nil');
  end;
end;

procedure TCnMainViewer.FormShow(Sender: TObject);
begin
  if CurrentChild <> nil then
    PostMessage(Handle, WM_USER_SHOW_CHILD, 0, 0);
end;

procedure TCnMainViewer.OnShowChild(var Message: TMessage);
begin
  if CurrentChild <> nil then
    CurrentChild.pnlTree.OnResize(CurrentChild.pnlTree);
end;

procedure TCnMainViewer.pnlChildContainerDblClick(Sender: TObject);
begin
  actOpen.Execute;
end;

procedure TCnMainViewer.mniWindowClick(Sender: TObject);
var
  I: Integer;
  Item: TMenuItem;
begin
  // 全删会出弹不出来的问题，要保留一个
  for I := mniWindow.Count - 1 downto 1 do
    mniWindow.Delete(0);

  if tsSwitch.Tabs.Count > 0 then
  begin

  for I := 0 to tsSwitch.Tabs.Count - 1 do
  begin
    if (tsSwitch.Tabs.Objects[I] <> nil) and (tsSwitch.Tabs.Objects[I] is TForm) then
    begin
      if I = 0 then
        Item := mniWindow.Items[0]
      else
        Item := TMenuItem.Create(Self);
      Item.Caption := tsSwitch.Tabs[I];
{$IFDEF WIN64}
      Item.Tag := NativeInt(tsSwitch.Tabs.Objects[I]);
{$ELSE}
      Item.Tag := Integer(tsSwitch.Tabs.Objects[I]);
{$ENDIF}
      Item.Checked := TForm(tsSwitch.Tabs.Objects[I]).Visible;
      Item.OnClick := WindowMenuItemClick;

      if I > 0 then
        mniWindow.Add(Item);
    end;
  end;
  end
  else
  begin
    mniWindow.Items[0].Caption := SCnNoneMenuItemCaption;
    mniWindow.Items[0].Tag := 0;
    mniWindow.Items[0].Checked := False;
    mniWindow.Items[0].Enabled := False;
  end;
end;

procedure TCnMainViewer.WindowMenuItemClick(Sender: TObject);
var
  I: Integer;
begin
  if Sender is TMenuItem then
  begin
    if (TMenuItem(Sender).Tag <> 0) and (TObject(TMenuItem(Sender).Tag) is TForm) then
    begin
      ShowAndHideOtherChildren(TForm(TMenuItem(Sender).Tag));
      I := tsSwitch.Tabs.IndexOfObject(TObject(TMenuItem(Sender).Tag));
      if I >= 0 then
        tsSwitch.TabIndex := I;
    end;
  end;
end;

{$IFDEF CAPTURE_STACK}

const
{$IFDEF CPUX64}
  SCnLocationInfoFmt = '(%16.16x) [%-14s | $%16.16x] ';
{$ELSE}
  SCnLocationInfoFmt = '(%8.8x) [%-14s | $%8.8x] ';
{$ENDIF}

type
{$IFDEF CPUX64}
  TCnNativeInt = NativeInt;
{$ELSE}
  TCnNativeInt = Integer;
{$ENDIF}

{$IFDEF CAPTURE_STACK}
var
  FInProcessCriticalSection: TRTLCriticalSection;
  FInProcessModuleList: TCnInProcessModuleList = nil;
{$ENDIF}

{$IFDEF CAPTURE_STACK}
threadvar
  FIsInExcption: Boolean;
{$ENDIF}

function GetLocationInfoStr(const Address: Pointer): string;
var
  Info: TCnModuleDebugInfo;
  MN, UN, PN: string;
  LN, OL, OP: Integer;
begin
  Result := '';
  if FInProcessModuleList = nil then
  begin
    EnterCriticalSection(FInProcessCriticalSection);
    try
      if FInProcessModuleList = nil then
        FInProcessModuleList := CreateInProcessAllModulesList;
    finally
      LeaveCriticalSection(FInProcessCriticalSection);
    end;
  end;

  Info := FInProcessModuleList.CreateDebugInfoFromAddress(Address);
  if Info = nil then
    Exit;

  // (地址) [模块名| 基址]
  Result := Format(SCnLocationInfoFmt, [TCnNativeInt(Address),
    ExtractFileName(Info.ModuleFile), Info.ModuleHandle]);

  if Info.GetDebugInfoFromAddr(Address, MN, UN, PN, LN, OL, OP) then
  begin
    if PN <> '' then
    begin
      Result := Result + PN;
      if OP > 0 then
        Result := Result + Format(' + $%x', [OP]);
    end;

    if UN <> '' then
    begin
      Result := Result + ' ("' + UN + '"';
      if LN > 0 then
        Result := Result + Format(' #%d', [LN]);
      if OL > 0 then
        Result := Result + Format(' + $%x', [OL]);
      Result := Result + ')';
    end;
  end;
end;

class procedure TCnMainViewer.ExceptionRecorder(ExceptObj: Exception; ExceptAddr: Pointer;
  IsOSException: Boolean; StackList: TCnStackInfoList);
var
  I: Integer;
  SL: TStrings;
begin
  SL := TStrings.Create;
  try
    if IsOSException then
      SL.Add('OS Exception: ' + ExceptObj.ClassName + ': ' + ExceptObj.Message)
    else
      SL.Add(ExceptObj.ClassName + ': ' + ExceptObj.Message);

    if FIsInExcption then
    begin
      SL.Add('!!! Exception Reraised in CnDebugViewer Handler !!!');
      MessageBox(0, PChar(SL.Text), '', MB_OK);
      Exit;
    end;

    FIsInExcption := True;
    try
      SL.Add('Exception call stack:');
      for I := 0 to StackList.Count - 1 do
        SL.Add(GetLocationInfoStr(StackList.Items[I].CallerAddr));

      MessageBox(0, PChar(SL.Text), '', MB_OK);
    finally
      FIsInExcption := False;
    end;
  finally
    SL.Free;
  end;
end;

initialization
  InitializeCriticalSection(FInProcessCriticalSection);
  CnSetAdditionalExceptionRecorder(TCnMainViewer.ExceptionRecorder);
  CnHookException;

finalization
  CnUnHookException;
  DeleteCriticalSection(FInProcessCriticalSection);

{$ENDIF}

end.
