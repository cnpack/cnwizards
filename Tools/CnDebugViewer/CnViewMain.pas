{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

unit CnViewMain;
{ |<PRE>
================================================================================
* 软件名称：CnDebugViewer
* 单元名称：主窗体单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2005.01.01
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Menus, ComCtrls, ActnList, ImgList, ToolWin, StdCtrls, IniFiles,
  Clipbrd, Registry, Tabs,
  VirtualTrees, CnMdiView, CnLangTranslator, CnLangMgr, CnWizLangID, CnTabSet,
  CnLangStorage, CnHashLangStorage, CnClasses, CnMsgClasses, CnTrayIcon,
  CnWizCfgUtils;

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
    btn5: TToolButton;
    btn6: TToolButton;
    btn7: TToolButton;
    btn8: TToolButton;
    ToolButton6: TToolButton;
    btn10: TToolButton;
    btn9: TToolButton;
    ToolButton9: TToolButton;
    btn11: TToolButton;
    btn12: TToolButton;
    btn13: TToolButton;
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
    btn14: TToolButton;
    btn15: TToolButton;
    btn16: TToolButton;
    btn17: TToolButton;
    btn18: TToolButton;
    btn19: TToolButton;
    ToolButton19: TToolButton;
    btn20: TToolButton;
    btn21: TToolButton;
    ToolButton22: TToolButton;
    btn22: TToolButton;
    btn23: TToolButton;
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
    btn1: TToolButton;
    btn2: TToolButton;
    btn3: TToolButton;
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
  private
    FUpdatingSwitch: Boolean;
    FClickingSwitch: Boolean;
    FRunningState: TCnRunningState;
    FThread, FDbgThread: TThread;
    FCloseFromMenu: Boolean;
    procedure ThreadOnTerminate(Sender: TObject);
    procedure DbgThreadOnTerminate(Sender: TObject);
    function GetCurrentChild: TCnMsgChild;
    function RegisterViewerHotKey: Boolean;

    procedure GotoNode(Tree: TVirtualStringTree; Node: PVirtualNode);
    procedure InitializeLang;
    procedure UpdateStatusBar;
    procedure LogSelfPath;
    procedure LanguageClick(Sender: TObject);
    procedure LanguageChanged(Sender: TObject);
    procedure ActiveFormChanged(Sender: TObject);
    procedure OnUpdateStore(var Msg: TMessage); message WM_USER_UPDATE_STORE;
    procedure OnNewChildForm(var Msg: TMessage); message WM_USER_NEW_FORM;
    procedure OnHotKey(var Message: TMessage); message WM_HOTKEY;
  protected
    procedure DoCreate; override;
  public
    { Public declarations }
    procedure LaunchThread;
    procedure PauseThread;  
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
  CnViewCore, CnGetThread, CnFilterFrm, CnViewOption;

{$R *.DFM}

const
  CnMaxProcessCount = 16;

type
  TCnToolBarHack = class(TToolBar);

procedure TCnMainViewer.actNewExecute(Sender: TObject);
begin
  if MDIChildCount >= CnMaxProcessCount then Exit;
  TCnMsgChild.Create(Application).Show;
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
              SwitchName := (AForm as TCnMsgChild).ProcName;

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
              SwitchName := (AForm as TCnMsgChild).ProcName;

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
begin
  InitializeCore;
  if GetCWUseCustomUserDir then
    LoadOptions(GetCWUserPath + SCnOptionFileName)
  else
    LoadOptions(ExtractFilePath(Application.ExeName) + SCnOptionFileName);
  UpdateFilterToMap;
  InitializeLang;

  CnLangManager.AddChangeNotifier(LanguageChanged);
      Left := 0; Width := Screen.Width;
      Top := 0; Height := Screen.Height - 25;
  Application.Title := Caption;
  statMain.Panels[1].Text := Format(SCnCPUSpeedFmt, [CPUClock]);

  Screen.OnActiveFormChange := ActiveFormChanged;
  if SysDebugExists then
    statMain.Panels[3].Text := SCnDebuggerExists
  else
    statMain.Panels[3].Text := '';

  // 创建托盘栏图标
  tryIcon.Hint := Caption;
  tryicon.Active := CnViewerOptions.ShowTrayIcon;
  tryIcon.AutoHide := CnViewerOptions.MinToTrayIcon;

  //Add Sesame 2008-1-18 还原窗口位置
  if CnViewerOptions.SaveFormPosition then
  begin
    case CnViewerOptions.WinState of
      0:
        begin
          Self.Top := CnViewerOptions.Top;
          Self.Left := CnViewerOptions.Left;
          Self.Height := CnViewerOptions.Height;
          Self.Width := CnViewerOptions.Width;
        end;
      1: PostMessage(Self.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
      2: PostMessage(Self.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    end;
  end
  else//默认位置及大小
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
  //Add Sesame 2008.01.18 记录窗口位置
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
    SaveOptions(ExtractFilePath(Application.ExeName) + SCnOptionFileName);
  CnLangManager.RemoveChangeNotifier(LanguageChanged);

  // 注销热键
  UnregisterHotKey(Handle, SCnHotKeyId);
end;

procedure TCnMainViewer.DestroyThread;
begin
  if FThread <> nil then
  begin
    FThread.Terminate;
    try
      FThread.WaitFor;
    except
      ;
    end;
    FThread := nil;
  end;

  if FDbgThread <> nil then
  begin
    FDbgThread.Terminate;
    try
      FDbgThread.WaitFor;
    except
      ;
    end;
    FDbgThread := nil;
  end;

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
    (FThread as TGetDebugThread).FreeOnTerminate := True;
    FThread.OnTerminate := ThreadOnTerminate;
    FThread.Resume;
  end
  else
    (FThread as TGetDebugThread).Paused := False;

  if CnViewerOptions.IgnoreODString then Exit;

  if FDbgThread = nil then
  begin
    FDbgThread := TDbgGetDebugThread.Create(True);
    (FDbgThread as TDbgGetDebugThread).FreeOnTerminate := True;
    FDbgThread.OnTerminate := DbgThreadOnTerminate;
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

procedure TCnMainViewer.ThreadOnTerminate(Sender: TObject);
var
  Res: Cardinal;
  Count: Integer;
begin
  if HMutex <> 0 then
  begin
    Count := 0;
    repeat
      Res := WaitForSingleObject(HMutex, CnWaitMutexTime);
      Sleep(0);
      Inc(Count);
    until (Res = WAIT_OBJECT_0) or (Count = 10);

    CloseHandle(HMutex);
    HMutex := 0;
  end;
  FThread := nil;
end;

procedure TCnMainViewer.DbgThreadOnTerminate(Sender: TObject);
begin
  FDbgThread := nil;
end;

procedure TCnMainViewer.actSwtCloseExecute(Sender: TObject);
begin
  if tsSwitch.Tabs.Objects[tsSwitch.TabIndex] <> nil then
    TCustomForm(tsSwitch.Tabs.Objects[tsSwitch.TabIndex]).Close;
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
  else if (Action = actSwtClose) or (Action = actSwtCloseOther) or (Action = actSwtCloseAll) then
    (Action as TCustomAction).Enabled := tsSwitch.Tabs.Count > 0
  else if (Action = actViewTime) then
  begin
    (Action as TCustomAction).Enabled := CurrentChild <> nil;
    (Action as TCustomAction).Checked := (Action as TCustomAction).Enabled and CurrentChild.lvTime.Visible;
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
  else if (Action = actCopy) then
    (Action as TCustomAction).Enabled := (CurrentChild <> nil) and (CurrentChild.mmoDetail.Text <> '')
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
    (((Sender as TTabSet).Tabs.Objects[NewTab]) as TForm).BringToFront;
end;

function TCnMainViewer.GetCurrentChild: TCnMsgChild;
begin
  Result := TCnMsgChild(ActiveMDIChild);
end;

procedure TCnMainViewer.actExpandAllExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.MsgTree.FullExpand;
end;

procedure TCnMainViewer.actCloseExecute(Sender: TObject);
begin
  if CurrentChild <> nil then
    CurrentChild.Close;
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
end;

procedure TCnMainViewer.actViewTimeExecute(Sender: TObject);
var
  Column, W: Integer;
begin
  if CurrentChild <> nil then
  begin
    CurrentChild.IsResizing := True;
    try
      CurrentChild.lvTime.Visible := not CurrentChild.lvTime.Visible;
      CurrentChild.splTime.Visible := not CurrentChild.splTime.Visible;
      (Sender as TCustomAction).Checked := CurrentChild.lvTime.Visible;
      Column := CurrentChild.MsgTree.Header.MainColumn;
      if CurrentChild.lvTime.Visible then W := 0 - CurrentChild.lvTime.Width
      else W := CurrentChild.lvTime.Width;

      CurrentChild.MsgTree.Header.Columns[Column].Width :=
        CurrentChild.MsgTree.Header.Columns[Column].Width + W;
      if CurrentChild.lvTime.Visible then
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
    Tree.Selected[Node] := True;
    Tree.FocusedNode := Node;
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
begin
  if FThread <> nil then
  begin
    if QueryDlg(SCnStopFirst) then
    begin
      actStop.Execute;
      Application.ProcessMessages;
    end
    else
      Exit;
  end;

  if dlgOpen.Execute then
  begin
    if CurrentChild = nil then
      actNew.Execute;

    if (CurrentChild <> nil) and (FThread = nil) then
    begin
      CurrentChild.LoadFromFile(dlgOpen.FileName);
      CurrentChild.Store.ProcessID := CnInvalidFileProcId;
      CurrentChild.ProcessID := CnInvalidFileProcId;
      CurrentChild.ProcName := ExtractFileName(dlgOpen.FileName);

      UpdateFormInSwitch(CurrentChild, fsUpdate);
    end;
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
      if ExtractFileExt(FileName) = '' then
        FileName := ChangeFileExt(FileName, '.xml');
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
    Clipboard.AsText := CurrentChild.mmoDetail.Text;
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
  MessageBox(Application.Handle, PChar(SCnDebugViewerAbout),
    PChar(SCnDebugViewerAboutCaption), MB_OK or MB_ICONINFORMATION);
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
    CnHashLangFileStorage.LanguagePath := ExtractFilePath(ParamStr(0)) + csLangDir;
    LangID := GetWizardsLanguageID;

    for I := 0 to CnLanguageManager.LanguageStorage.LanguageCount - 1 do
    begin
      if CnLanguageManager.LanguageStorage.Languages[I].LanguageID = LangID then
      begin
        CnLanguageManager.CurrentLanguageIndex := I;
        TranslateStrings;
        CnLanguageManager.TranslateForm(Self);
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

        if AChild.lvTime.Focused and Assigned(AChild.lvTime.OnClick) then
          AChild.lvTime.OnClick(AChild.lvTime);
      end;
    end;
  end;
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
var
  Url, HelpPath, FileName: string;
  si: TStartupInfo;
  pi: TProcessInformation;
begin
  HelpPath := ExtractFilePath(ParamStr(0)) + csHelpDir;
  FileName := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)) + csLangDir
    + CnLanguageManager.LanguageStorage.CurrentLanguage.LanguageDirName) + SCnDbgHelpIniFile;

  if not FileExists(FileName) then
  begin
    HelpPath := ExtractFilePath(ParamStr(0));
    FileName := HelpPath + SCnDbgHelpIniFile;
    if not FileExists(FileName) then
      Exit;
  end;

  with TIniFile.Create(FileName) do
  try
    Url := ReadString(SCnDbgHelpIniSecion, SCnDbgHelpIniTopic, '');
  finally
    Free;
  end;

  if Url <> '' then
  begin
    Url := 'mk:@MSITStore:' + IncludeTrailingBackslash(HelpPath) + Url;
    ZeroMemory(@si, SizeOf(si));
    si.cb := SizeOf(si);
    ZeroMemory(@pi, SizeOf(pi));
    CreateProcess(nil, PChar('hh ' + Url), nil, nil, False, 0, nil, nil, si, pi);
    if pi.hProcess <> 0 then CloseHandle(pi.hProcess);
    if pi.hThread <> 0 then CloseHandle(pi.hThread);
  end
  else
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
begin
  if not (csDestroying in ComponentState) then
    with TCnMsgChild.Create(Application) do
    begin
      Show;
      Store := TCnMsgStore(Msg.WParam);
    end;
end;

procedure TCnMainViewer.actExportExecute(Sender: TObject);
var
  S: TFileName;
  FileStrs: TStringList;

  procedure ExportToTextFile(AStore: TCnMsgStore; AFileName: string);
  var
    I: Integer;
  begin
    FileStrs.Clear;
    for I := 0 to AStore.MsgCount - 1 do
    begin
      FileStrs.Add('--------------------------------------------------------------------------------');
      FileStrs.Add(CurrentChild.DescriptionOfMsg(I, AStore.Msgs[I]));
      FileStrs.Add('');
    end;
    FileStrs.SaveToFile(AFileName);
  end;

  procedure ExportToCSVFile(AStore: TCnMsgStore; AFileName: string);
  var
    I: Integer;
    Msg: string;
    AMsgItem: TCnMsgItem;
  begin
    FileStrs.Clear;
    FileStrs.Add(SCnCSVFormatHeader);
    for I := 0 to AStore.MsgCount - 1 do
    begin
      AMsgItem := AStore.Msgs[I];
      // 替换掉回车和逗号
      Msg := StringReplace(AMsgItem.Msg, #13#10, ' ', [rfIgnoreCase, rfReplaceAll]);
      Msg := StringReplace(Msg, ',', ' ', [rfIgnoreCase, rfReplaceAll]);

      FileStrs.Add(Format('%d,%d,%s,$%x,$%x,%s,%s,%s', [I + 1, AMsgItem.Level,
        SCnMsgTypeDescArray[AMsgItem.MsgType]^, AMsgItem.ThreadId, AMsgItem.ProcessId, AMsgItem.Tag, GetTimeDesc(AMsgItem), Msg]));
    end;
    FileStrs.SaveToFile(AFileName);
  end;

  procedure ExportToHTMFile(AStore: TCnMsgStore; AFileName: string);
  var
    I: Integer;
    Msg: string;
    AMsgItem: TCnMsgItem;
  begin
    FileStrs.Clear;
    FileStrs.Add(Format(SCnHTMFormatHeader, [SCnHTMFormatStyle, AFileName, SCnHTMFormatCharset]));
    FileStrs.Add(SCnHTMFormatTableHead);
    for I := 0 to AStore.MsgCount - 1 do
    begin
      AMsgItem := AStore.Msgs[I];

      // 替换掉尖括号和回车
      Msg := StringReplace(AMsgItem.Msg, '<', '&lt;', [rfIgnoreCase, rfReplaceAll]);
      Msg := StringReplace(AMsgItem.Msg, '>', '&gt;', [rfIgnoreCase, rfReplaceAll]);
      Msg := StringReplace(AMsgItem.Msg, #13#10, '<BR>', [rfIgnoreCase, rfReplaceAll]);

      FileStrs.Add(Format(SCnHTMFormatLine, [I + 1, AMsgItem.Level,
        SCnMsgTypeDescArray[AMsgItem.MsgType]^, AMsgItem.ThreadId, AMsgItem.ProcessId, AMsgItem.Tag, GetTimeDesc(AMsgItem), Msg]));
    end;
    FileStrs.Add(SCnHTMFormatEnd);
    FileStrs.SaveToFile(AFileName);
  end;
begin
  if CurrentChild = nil then Exit;

  if dlgSaveExport.Execute then
  begin
    S := dlgSaveExport.FileName;

    try
      FileStrs := TStringList.Create;
      case dlgSaveExport.FilterIndex of
        1: // TXT
          begin
            S := ChangeFileExt(S, '.txt');
            ExportToTextFile(CurrentChild.Store, S);
          end;
        2: // CSV
          begin
            S := ChangeFileExt(S, '.csv');
            ExportToCSVFile(CurrentChild.Store, S);
          end;
        3: // HTML
          begin
            S := ChangeFileExt(S, '.htm');
            ExportToHTMFile(CurrentChild.Store, S);
          end;
        4: // RTF
          begin
            S := ChangeFileExt(S, '.rtf');
            ErrorDlg('Sorry. NOT Implemented.');
          end;
      end;
    finally
      FileStrs.Free;
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
    end;
    Free;
  end;
end;

procedure TCnMainViewer.OnHotKey(var Message: TMessage);
begin
  inherited;
  if Message.WParam = SCnHotKeyId then
    tryIcon.ShowApplication;
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
    actSwtClose.Execute;
end;

procedure TCnMainViewer.actAutoScrollExecute(Sender: TObject);
begin
  actAutoScroll.Checked := not actAutoScroll.Checked;
  CnViewerOptions.AutoScroll := actAutoScroll.Checked;
end;

procedure TCnMainViewer.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  actStop.Execute;
  DestroyThread;
end;

end.
