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

unit CnFeedWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：RSS 专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP3 + Delphi 7.1
* 兼容测试：
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: $
* 修改记录：2010.04.08
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFEEDREADERWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, IniFiles, Forms,
  Buttons, Menus, CommCtrl, ComCtrls, Contnrs, ExtCtrls, Math, Tabs,
  ActiveX, OmniXML, OmniXMLPersistent, CnConsts, CnCommon, CnClasses,
  CnWizClasses, CnWizNotifier, CnWizUtils, CnFeedParser, CnWizOptions,
  CnWizConsts, CnWizMultiLang, CnPopupMenu;

type

{ TCnStatusPanel }

  TCnFeedReaderWizard = class;

  TCnStatusPanel = class(TCustomControl)
  private
    FWizard: TCnFeedReaderWizard;
    FStatusBar: TStatusBar;
    FTabSet: TTabSet;
    FEditWindow: TCustomForm;
    FMenuItems: array[0..4] of TMenuItem;
    FMenu: TPopupMenu;
    FActive: Boolean;
    FIsHot: Boolean;
    FText: string;
    FBtnPrevFeed: TSpeedButton;
    FBtnNextFeed: TSpeedButton;
    FBtnConfig: TSpeedButton;
    procedure OnStatusBarResize(Sender: TObject);
    procedure OnTabSetChange(Sender: TObject);
    procedure CalcTextRect(AText: string; var ARect: TRect);
    procedure SetIsHot(const Value: Boolean);
    procedure SetText(const Value: string);
  protected
    procedure InitPopupMenu;
    procedure CreateButtons;
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Click; override;
    property IsHot: Boolean read FIsHot write SetIsHot;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LanguageChanged(Sender: TObject);
    procedure InitControls;
    procedure UpdateStatus;
    
    property StatusBar: TStatusBar read FStatusBar write FStatusBar;
    property TabSet: TTabSet read FTabSet write FTabSet;
    property EditWindow: TCustomForm read FEditWindow write FEditWindow;
    property Menu: TPopupMenu read FMenu;

    property Text: string read FText write SetText;
    property Active: Boolean read FActive write FActive;
  end;

{ TCnFeedCfgItem }

  TCnFeedCfgItem = class(TCnAssignableCollectionItem)
  private
    FLimit: Integer;
    FCheckPeriod: Integer;
    FIDStr: string;
    FUrl: string;
    FCaption: string;
  published
    property Caption: string read FCaption write FCaption;
    property IDStr: string read FIDStr write FIDStr;
    property Url: string read FUrl write FUrl;
    property CheckPeriod: Integer read FCheckPeriod write FCheckPeriod;
    property Limit: Integer read FLimit write FLimit;
  end;

{ TCnFeedCfg }

  TCnFeedCfg = class(TCnAssignableCollection)
  private
    function GetItems(Index: Integer): TCnFeedCfgItem;
    procedure SetItems(Index: Integer; const Value: TCnFeedCfgItem);
  public
    constructor Create;
    function Add: TCnFeedCfgItem;
    property Items[Index: Integer]: TCnFeedCfgItem read GetItems write SetItems; default;
  end;

{ TCnFeedThread }

  TCnFeedThread = class(TThread)
  private
    FActive: Boolean;
    FIni: TCustomIniFile;
    FFeedPath: string;
    FTick: Cardinal;
    FLock: TCnLockObject;
    FForceUpdate: Boolean;
    FFeeds: TObjectList;
    FFeedCfg: TCnFeedCfg;
    FOnFeedUpdate: TNotifyEvent;
    procedure DoFeedUpdate;
    function UpdateFeeds(ForceUpdate: Boolean): Boolean;
    function DoUpdateFeed(Def: TCnFeedCfgItem; ForceUpdate: Boolean): Boolean;
    function GetFeedCount: Integer;
    function GetFeeds(Index: Integer): TCnFeedChannel;
  protected
    procedure Execute; override;
  public
    constructor Create(AIni: TCustomIniFile; AFeedPath: string);
    destructor Destroy; override;
    procedure DoForceUpdate;
    procedure SetFeedCfg(ACfg: TCnFeedCfg);
    
    property OnFeedUpdate: TNotifyEvent read FOnFeedUpdate write FOnFeedUpdate;
    property FeedCount: Integer read GetFeedCount;
    property Feeds[Index: Integer]: TCnFeedChannel read GetFeeds;
  end;

{ TCnFeedReaderWizard }

  TCnFeedReaderWizard = class(TCnIDEEnhanceWizard)
  private
    FThread: TCnFeedThread;
    FIni: TCustomIniFile;
    FFeedPath: string;
    FFeedCfg: TCnFeedCfg;
    FLastUpdateTick: Cardinal;
    FTimer: TTimer;
    FPanels: TList;
    FFeeds: TObjectList;
    FSortedFeeds: TList;
    FRandomFeeds: TList;
    FCurFeed: TCnFeedItem;
    FChangePeriod: Integer;
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
    procedure DoUpdateStatusPanel(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
    function GetPanelCount: Integer;
    function GetPanels(Index: Integer): TCnStatusPanel;
    procedure OnPanelClick(Sender: TObject);
    function GetFeedCount: Integer;
    function GetFeeds(Index: Integer): TCnFeedChannel;
    procedure OnTimer(Sender: TObject);
    procedure RandomFeed;
    function FeedHTMLToTxt(const Text: WideString): WideString;
    procedure SetFeedCfgToThread;
    procedure SetFeedToPanels;
    procedure OnFeedUpdate(Sender: TObject);
    procedure OnForceUpdateFeed(Sender: TObject);
    procedure OnPrevFeed(Sender: TObject);
    procedure OnNextFeed(Sender: TObject);
    procedure OnConfig(Sender: TObject);
    procedure OnCloseFeed(Sender: TObject);
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;

    function CanShowPanels: Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    procedure Loaded; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure LanguageChanged(Sender: TObject); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;

    procedure UpdateStatusPanels;

    procedure FeedStep(Step: Integer);

    property PanelCount: Integer read GetPanelCount;
    property Panels[Index: Integer]: TCnStatusPanel read GetPanels;
    property FeedCount: Integer read GetFeedCount;
    property Feeds[Index: Integer]: TCnFeedChannel read GetFeeds;
    property CurFeed: TCnFeedItem read FCurFeed;
    property FeedCfg: TCnFeedCfg read FFeedCfg;
  published
    property ChangePeriod: Integer read FChangePeriod write FChangePeriod default 30;
  end;

{$ENDIF CNWIZARDS_CNFEEDREADERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFEEDREADERWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  RegExpr, CnEditControlWrapper, CnWizIdeUtils, CnInetUtils, CnFeedWizardFrm;

const
  SCnFeedStatusPanel = 'CnFeedStatusPanel';
  SCnEdtStatusBar = 'StatusBar';
  SCnEdtTabSet = 'ViewBar';
  SCnFeedCache = 'FeedCache\';
  SCnUpdateFeedMutex = 'CnUpdateFeedMutex';
  SCnFeedCfgFile = 'FeedCfg.xml';
  SCnFeedLangID = '$landid$';

{$IFDEF BCB6}
  csBarKeepWidth = 200;
{$ELSE}
{$IFDEF COMPILER6_UP}
  csBarKeepWidth = 140;
{$ELSE}
  csBarKeepWidth = 80;
{$ENDIF}
{$ENDIF}
  csPnlBtnWidth = 18;
  csMaxHintLength = 250;

function DoSortFeed(Item1, Item2: Pointer): Integer;
begin
  if TCnFeedItem(Item1).PubDate > TCnFeedItem(Item2).PubDate then
    Result := -1
  else if TCnFeedItem(Item1).PubDate < TCnFeedItem(Item2).PubDate then
    Result := 1
  else
    Result := 0;
end;

{ TCnStatusPanel }

procedure TCnStatusPanel.CalcTextRect(AText: string; var ARect: TRect);
begin
  Canvas.Font := Font;
  if AText <> '' then
  begin
    ARect := ClientRect;
    if FBtnPrevFeed.Visible then
      ARect.Right := FBtnPrevFeed.Left - 2;
    if ARect.Right < ARect.Left then
    begin
      ARect := Bounds(0, 0, 0, 0);
      Exit;
    end;
    DrawText(Canvas.Handle, PChar(AText), Length(AText), ARect,
      DT_CALCRECT or DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX or DT_END_ELLIPSIS);
  end
  else
    ARect := Bounds(0, 0, 0, 0);
end;

procedure TCnStatusPanel.Click;
begin
  if Cursor = crHandPoint then
    inherited;
end;

procedure TCnStatusPanel.CMMouseEnter(var Message: TMessage);
begin
  FBtnPrevFeed.Visible := True;
  FBtnNextFeed.Visible := True;
  FBtnConfig.Visible := True;
  Invalidate;
end;

procedure TCnStatusPanel.CMMouseLeave(var Message: TMessage);
begin
  FBtnPrevFeed.Visible := False;
  FBtnNextFeed.Visible := False;
  FBtnConfig.Visible := False;
  IsHot := False;
  Invalidate;
end;

constructor TCnStatusPanel.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TCnStatusPanel.CreateButtons;

  function CreateButton(ACaption: string): TSpeedButton;
  begin
    Result := TSpeedButton.Create(Self);
    Result.Caption := ACaption;
    Result.Flat := True;
    Result.Visible := False;
    Result.Parent := Self;
  end;
begin
  FBtnPrevFeed := CreateButton('<<');
  FBtnNextFeed := CreateButton('>>');
  FBtnConfig := CreateButton('...');
  FBtnPrevFeed.OnClick := FWizard.OnPrevFeed;
  FBtnNextFeed.OnClick := FWizard.OnNextFeed;
  FBtnConfig.OnClick := FWizard.OnConfig;
end;

destructor TCnStatusPanel.Destroy;
begin
  if StatusBar <> nil then
    StatusBar.OnResize := nil;
  if TabSet <> nil then
    TTabList(TabSet.Tabs).OnChange := nil;
  FMenu.Free;
  FWizard.FPanels.Remove(Self);
  inherited;
end;

procedure TCnStatusPanel.InitPopupMenu;
begin
  FMenu := TPopupMenu.Create(Self);
  PopupMenu := FMenu;
  FMenuItems[0] := AddMenuItem(FMenu.Items, SCnFeedPrevFeedCaption, FWizard.OnPrevFeed);
  FMenuItems[1] := AddMenuItem(FMenu.Items, SCnFeedNextFeedCaption, FWizard.OnNextFeed);
  AddMenuItem(FMenu.Items, '-');
  FMenuItems[2] := AddMenuItem(FMenu.Items, SCnFeedForceUpdateCaption, FWizard.OnForceUpdateFeed);
  FMenuItems[3] := AddMenuItem(FMenu.Items, SCnFeedCloseCaption, FWizard.OnCloseFeed);
  AddMenuItem(FMenu.Items, '-');
  FMenuItems[4] := AddMenuItem(FMenu.Items, SCnFeedConfigCaption, FWizard.OnConfig);
end;

procedure TCnStatusPanel.InitControls;
begin
  OnClick := FWizard.OnPanelClick;
  InitPopupMenu;
  CreateButtons;
  UpdateStatus;
end;

procedure TCnStatusPanel.LanguageChanged(Sender: TObject);
begin
  FMenuItems[0].Caption := SCnFeedPrevFeedCaption;
  FMenuItems[1].Caption := SCnFeedNextFeedCaption;
  FMenuItems[2].Caption := SCnFeedForceUpdateCaption;
  FMenuItems[3].Caption := SCnFeedCloseCaption;
  FMenuItems[4].Caption := SCnFeedConfigCaption;
end;

procedure TCnStatusPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  ARect: TRect;
begin
  inherited;
  CalcTextRect(Text, ARect);
  IsHot := PtInRect(ARect, Point(X, Y))
end;

procedure TCnStatusPanel.OnStatusBarResize(Sender: TObject);
var
  R: TRect;
  W: Integer;
begin
  StatusBar.Perform(SB_GETRECT, StatusBar.Panels.Count - 1, Integer(@R));
  W := 0;
  if TabSet <> nil then
  begin
    TabSet.Repaint;
    if TabSet.VisibleTabs < TabSet.Tabs.Count then
    begin
      SetBounds(0, 0, 0, 0);
      Exit;
    end;  
    W := TabSet.ItemRect(TabSet.VisibleTabs - 1).Right;
  end;

  if W > 0 then
    Inc(R.Left, W + 20)
  else
    Inc(R.Left, csBarKeepWidth);
  SetBounds(R.Left + 1, R.Top + 1, R.Right - R.Left - 2, R.Bottom - R.Top - 2);
  FBtnNextFeed.SetBounds(ClientWidth - csPnlBtnWidth - 1, 0, csPnlBtnWidth, ClientHeight);
  FBtnConfig.SetBounds(ClientWidth - 2 * csPnlBtnWidth - 1, 0, csPnlBtnWidth, ClientHeight);
  FBtnPrevFeed.SetBounds(ClientWidth - 3 * csPnlBtnWidth - 1, 0, csPnlBtnWidth, ClientHeight);
  Invalidate;
end;

procedure TCnStatusPanel.OnTabSetChange(Sender: TObject);
begin
  CnWizNotifierServices.ExecuteOnApplicationIdle(OnStatusBarResize);
end;

procedure TCnStatusPanel.Paint;
var
  ARect: TRect;
begin
  CalcTextRect(Text, ARect);

  Canvas.Brush.Style := bsClear;
  Canvas.Font := Font;
  Canvas.Font.Style := [fsUnderline];
  if FIsHot then
    Canvas.Font.Color := clBlue
  else
    Canvas.Font.Color := clBlack;
  DrawText(Canvas.Handle, PChar(Text), Length(Text), ARect,
    DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX or DT_END_ELLIPSIS);
end;

procedure TCnStatusPanel.SetIsHot(const Value: Boolean);
begin
  if FIsHot <> Value then
  begin
    FIsHot := Value;
    if FIsHot then
    begin
      Cursor := crHandPoint;
      ShowHint := True;
    end
    else
    begin
      Cursor := crDefault;
      ShowHint := False;
    end;
    Invalidate;
  end;
end;

procedure TCnStatusPanel.SetText(const Value: string);
begin
  FText := Value;
  Invalidate;
end;

procedure TCnStatusPanel.UpdateStatus;
begin
  if Parent = nil then
  begin
    Parent := StatusBar;
    StatusBar.OnResize := OnStatusBarResize;
    if TabSet <> nil then
      TTabList(TabSet.Tabs).OnChange := OnTabSetChange;
  end;
  OnTabSetChange(TabSet);
end;

{ TCnFeedCfg }

function TCnFeedCfg.Add: TCnFeedCfgItem;
begin
  Result := TCnFeedCfgItem(inherited Add);
end;

constructor TCnFeedCfg.Create;
begin
  inherited Create(TCnFeedCfgItem);
end;

function TCnFeedCfg.GetItems(Index: Integer): TCnFeedCfgItem;
begin
  Result := TCnFeedCfgItem(inherited Items[Index]);
end;

procedure TCnFeedCfg.SetItems(Index: Integer; const Value: TCnFeedCfgItem);
begin
  inherited Items[Index] := Value;
end;

{ TCnFeedThread }

constructor TCnFeedThread.Create(AIni: TCustomIniFile; AFeedPath: string);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FIni := AIni;
  FFeedPath := AFeedPath;
  FLock := TCnLockObject.Create;
  FFeeds := TObjectList.Create;
  FFeedCfg := TCnFeedCfg.Create;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnFeedThread.Create');
{$ENDIF}
end;

destructor TCnFeedThread.Destroy;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnFeedThread.Destroy');
{$ENDIF}
  FLock.Free;
  FFeeds.Free;
  FFeedCfg.Free;
  inherited;
end;

procedure TCnFeedThread.DoFeedUpdate;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnFeedThread.DoFeedUpdate');
{$ENDIF}
  if Assigned(FOnFeedUpdate) then
    FOnFeedUpdate(Self);
end;

procedure TCnFeedThread.DoForceUpdate;
begin
  FForceUpdate := True;
end;

function TCnFeedThread.DoUpdateFeed(Def: TCnFeedCfgItem; ForceUpdate: Boolean): Boolean;
var
  FileName, TmpName, Url: string;
  Feed: TCnFeedChannel;
  i: Integer;
  List: TList;
begin
  Result := False;
  if (Def.IDStr = '') or (Trim(Def.Url) = '') then
    Exit;
  
  Feed := nil;
  for i := 0 to FeedCount - 1 do
    if SameText(Feeds[i].IDStr, Def.IDStr) then
    begin
      Feed := Feeds[i];
      Break;
    end;
  if Feed = nil then
  begin
    Feed := TCnFeedChannel.Create;
    Feed.IDStr := Def.IDStr;
    FFeeds.Add(Feed);
    Result := True;
  end;

  FileName := FFeedPath + Def.IDStr + '.xml';
  TmpName := ChangeFileExt(FileName, '.tmp');
  if ForceUpdate or (Abs(Now - FIni.ReadDateTime('LastCheck', Def.IDStr, 0)) > Def.CheckPeriod / 24 / 60) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Update Feed: ' + Def.IDStr + ' -> ' + Def.Url);
  {$ENDIF}
    FIni.WriteDateTime('LastCheck', Def.IDStr, Now);
    with TCnHTTP.Create do
    try
      Url := StringReplace(Trim(Def.Url), SCnFeedLangID, IntToStr(WizOptions.CurrentLangID),
        [rfReplaceAll, rfIgnoreCase]);
      if GetFile(Url, TmpName) and (GetFileSize(TmpName) > 0) then
      begin
        DeleteFile(FileName);
        CopyFile(PChar(TmpName), PChar(FileName), False);
        DeleteFile(TmpName);
      end;
    finally
      Free;
    end;
    Result := True;
  end;

  if Result then
  begin
    Feed.LoadFromFile(FileName);

    if (Def.Limit > 0) and (Feed.Count > Def.Limit) then
    begin
      List := TList.Create;
      try
        for i := 0 to Feed.Count - 1 do
          List.Add(Feed[i]);
        List.Sort(DoSortFeed);
        for i := Def.Limit to List.Count - 1 do
          TCnFeedItem(List[i]).Free;
      finally
        List.Free;
      end;   
    end;  

  {$IFDEF DEBUG}
    CnDebugger.LogCollection(Feed);
  {$ENDIF}
  end;
end;

function TCnFeedThread.UpdateFeeds(ForceUpdate: Boolean): Boolean;
var
  i: Integer;
  hMutex: THandle;
  ACfg: TCnFeedCfg;
begin
  Result := False;
  hMutex := CreateMutex(nil, False, SCnUpdateFeedMutex);
  if GetLastError = ERROR_ALREADY_EXISTS then
    Exit;

  try
    if ForceUpdate then
    begin
      FFeeds.Clear;
    end;

    ACfg := TCnFeedCfg.Create;
    try
      FLock.Lock;
      try
        ACfg.Assign(FFeedCfg);
      finally
        FLock.Unlock;
      end;

      for i := 0 to ACfg.Count - 1 do
      begin
        if Terminated then Exit;
        if DoUpdateFeed(ACfg[i], ForceUpdate) then
          Result := True;
      end;
    finally
      ACfg.Free;
    end;
  finally
    if hMutex <> 0 then
    begin
      ReleaseMutex(hMutex);
      CloseHandle(hMutex);
    end;
  end;
end;

procedure TCnFeedThread.Execute;
var
  IsForce: Boolean;
  InitSucc: Boolean;
begin
  InitSucc := Succeeded(CoInitializeEx(nil, COINIT_MULTITHREADED));
  while not Terminated do
  begin
    if FActive and ((Abs(GetTickCount - FTick) > 60 * 1000) or FForceUpdate) then
    begin
      FTick := GetTickCount;
      IsForce := FForceUpdate;
      FForceUpdate := False;
      if UpdateFeeds(IsForce) then
        Synchronize(DoFeedUpdate);
    end
    else
      Sleep(100);  
  end;
  if InitSucc then
    CoUninitialize;
end;

function TCnFeedThread.GetFeedCount: Integer;
begin
  Result := FFeeds.Count;
end;

function TCnFeedThread.GetFeeds(Index: Integer): TCnFeedChannel;
begin
  Result := TCnFeedChannel(FFeeds[Index]);
end;

procedure TCnFeedThread.SetFeedCfg(ACfg: TCnFeedCfg);
begin
  FLock.Lock;
  try
    FFeedCfg.Assign(ACfg);
  finally
    FLock.Unlock;
  end;   
end;

{ TCnFeedReaderWizard }

function TCnFeedReaderWizard.CanShowPanels: Boolean;
begin
  Result := Active;
end;

procedure TCnFeedReaderWizard.Config;
begin
  if ShowCnFeedWizardForm(Self) then
  begin
    SetFeedCfgToThread;
    OnForceUpdateFeed(Self);
    DoSaveSettings;
  end;
end;

constructor TCnFeedReaderWizard.Create;
begin
  inherited;
  FLastUpdateTick := GetTickCount;
  FPanels := TList.Create;
  FFeeds := TObjectList.Create;
  FSortedFeeds := TList.Create;
  FRandomFeeds := TList.Create;
  FFeedCfg := TCnFeedCfg.Create;
  FTimer := TTimer.Create(nil);
  FTimer.OnTimer := OnTimer;
  FTimer.Interval := 1000;
  FTimer.Enabled := True;
  FChangePeriod := 30;
  FIni := CreateIniFile;
  FFeedPath := WizOptions.UserPath + SCnFeedCache;
  ForceDirectories(FFeedPath);
  
  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  UpdateStatusPanels;
end;

destructor TCnFeedReaderWizard.Destroy;
var
  i: Integer;
begin
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  for i := FPanels.Count - 1 downto 0 do
    TCnStatusPanel(FPanels[i]).Free;
  FPanels.Free;
  FFeeds.Free;
  FSortedFeeds.Free;
  FRandomFeeds.Free;
  FFeedCfg.Free;
  FTimer.Free;
  FIni.Free;
  if FThread <> nil then
  begin
    FThread.Terminate;
    TerminateThread(FThread.Handle, 0);
    FThread := nil;
  end;
  inherited;
end;

procedure TCnFeedReaderWizard.DoUpdateStatusPanel(EditWindow: TCustomForm;
  EditControl: TControl; Context: Pointer);
var
  Panel: TCnStatusPanel;
  StatusBar: TStatusBar;
begin
  if EditWindow <> nil then
  begin
    Panel := TCnStatusPanel(EditWindow.FindComponent(SCnFeedStatusPanel));
    if CanShowPanels then
    begin
      if Panel = nil then
      begin
        StatusBar := TStatusBar(FindComponentByClass(EditWindow,
          TStatusBar, SCnEdtStatusBar));
        if StatusBar <> nil then
        begin
          Panel := TCnStatusPanel.Create(EditWindow);
          Panel.Name := SCnFeedStatusPanel;
          Panel.FWizard := Self;
          Panel.EditWindow := EditWindow;
          Panel.StatusBar := StatusBar;
          Panel.TabSet := TTabSet(FindComponentByClass(EditWindow,
            TTabSet, SCnEdtTabSet));
          Panel.InitControls;
          Panel.UpdateStatus;
          FPanels.Add(Panel);
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('CnStatusPanel installed');
        {$ENDIF}
        end
        else
        begin
        {$IFDEF DEBUG}
          CnDebugger.LogMsgWarning('Can not find StatusBar in EditWindow!');
        {$ENDIF}
        end;
      end;
      if Panel <> nil then
      begin
        Panel.Active := True;
        Panel.Visible := True;
      end;        
    end
    else if Panel <> nil then
    begin
      Panel.Active := False;
      Panel.Visible := False;
    end;
  end;
end;

procedure TCnFeedReaderWizard.EditControlNotify(EditControl: TControl;
  EditWindow: TCustomForm; Operation: TOperation);
begin
  UpdateStatusPanels;
end;

function TCnFeedReaderWizard.GetPanelCount: Integer;
begin
  Result := FPanels.Count;
end;

function TCnFeedReaderWizard.GetFeedCount: Integer;
begin
  Result := FFeeds.Count;
end;

function TCnFeedReaderWizard.GetFeeds(Index: Integer): TCnFeedChannel;
begin
  Result := TCnFeedChannel(FFeeds[Index]);
end;

function TCnFeedReaderWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnFeedReaderWizard.GetPanels(Index: Integer): TCnStatusPanel;
begin
  Result := TCnStatusPanel(FPanels[Index]);
end;

class procedure TCnFeedReaderWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnFeedWizardName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnFeedWizardComment;
end;

procedure TCnFeedReaderWizard.LanguageChanged(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  for i := 0 to PanelCount - 1 do
    Panels[i].LanguageChanged(Sender);
end;

procedure TCnFeedReaderWizard.Loaded;
begin
  inherited;
  FThread := TCnFeedThread.Create(FIni, FFeedPath);
  FThread.OnFeedUpdate := OnFeedUpdate;
  FThread.FActive := Active;
  SetFeedCfgToThread;
  FThread.Resume;
end;

procedure TCnFeedReaderWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  try
    FFeedCfg.Clear;
    TOmniXMLReader.LoadFromFile(FFeedCfg, WizOptions.UserPath + SCnFeedCfgFile);
  except
    ;
  end;
  SetFeedCfgToThread;
end;

procedure TCnFeedReaderWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  TOmniXMLWriter.SaveToFile(FFeedCfg, WizOptions.UserPath + SCnFeedCfgFile, pfAuto, ofIndent);
end;

procedure TCnFeedReaderWizard.OnPanelClick(Sender: TObject);
begin
  if (FCurFeed <> nil) and (FCurFeed.Link <> '') then
    OpenUrl(FCurFeed.Link);
end;

procedure TCnFeedReaderWizard.SetActive(Value: Boolean);
begin
  inherited;
  UpdateStatusPanels;
  if FThread <> nil then
    FThread.FActive := Value;
end;

procedure TCnFeedReaderWizard.UpdateStatusPanels;
begin
  EnumEditControl(DoUpdateStatusPanel, nil);
  SetFeedToPanels;
end;

procedure TCnFeedReaderWizard.SetFeedCfgToThread;
var
  i: Integer;
  Cfg: TCnFeedCfg;
begin
  if FThread <> nil then
  begin
    Cfg := TCnFeedCfg.Create;
    try
      try
        TOmniXMLReader.LoadFromFile(Cfg, WizOptions.DataPath + SCnFeedCfgFile);
      except
        ;
      end;
      for i := 0 to FFeedCfg.Count - 1 do
        Cfg.Add.Assign(FFeedCfg[i]);
    {$IFDEF DEBUG}
      CnDebugger.LogCollection(Cfg);
    {$ENDIF}
      FThread.SetFeedCfg(Cfg);
    finally
      Cfg.Free;
    end;
  end;
end;

function TCnFeedReaderWizard.FeedHTMLToTxt(const Text: WideString): WideString;
var
  Exp: TRegExpr;
begin
  Result := Text;
  Exp := TRegExpr.Create;
  try
    // Delete HTML tags
    Exp.Expression := '<[^>]*>';
    Result := Exp.Replace(Result, '');
  finally
    Exp.Free;
  end;
end;

procedure TCnFeedReaderWizard.SetFeedToPanels;
var
  i: Integer;
  Title, Desc, Hint: WideString;
begin
  for i := 0 to PanelCount - 1 do
  begin
    if FCurFeed <> nil then
    begin
      Title := FeedHTMLToTxt(FCurFeed.Title);
      Desc := FeedHTMLToTxt(FCurFeed.Description);
      
      Panels[i].Text := Title;
      if Pos(Title, Desc) > 0 then
        Hint := Desc
      else
        Hint := Title + #13#10 + Desc;
      if Length(Hint) > csMaxHintLength then
        Panels[i].Hint := Copy(Hint, 1, csMaxHintLength) + '...'
      else
        Panels[i].Hint := Hint;
    end
    else
    begin
      Panels[i].Text := '';
      Panels[i].Hint := '';
    end;
    Panels[i].UpdateStatus;
  end;
end;

procedure TCnFeedReaderWizard.FeedStep(Step: Integer);
var
  Idx: Integer;
begin
  if FCurFeed <> nil then
    Idx := FRandomFeeds.IndexOf(FCurFeed)
  else
    Idx := 0;
    
  FCurFeed := nil;
  if FRandomFeeds.Count > 0 then
  begin
    Idx := (Idx + Step) mod FRandomFeeds.Count;
    if Idx < 0 then
      Idx := Idx + FRandomFeeds.Count;
    FCurFeed := TCnFeedItem(FRandomFeeds[TrimInt(Idx, 0, FRandomFeeds.Count - 1)]);
    SetFeedToPanels;
  end;
  FLastUpdateTick := GetTickCount;
end;

procedure TCnFeedReaderWizard.OnConfig(Sender: TObject);
begin
  Config;
end;

procedure TCnFeedReaderWizard.OnNextFeed(Sender: TObject);
begin
  FeedStep(1);
end;

procedure TCnFeedReaderWizard.OnPrevFeed(Sender: TObject);
begin
  FeedStep(-1);
end;

procedure TCnFeedReaderWizard.OnCloseFeed(Sender: TObject);
begin
  if QueryDlg(SCnFeedCloseQuery) then
    Active := False;
end;

procedure TCnFeedReaderWizard.OnForceUpdateFeed(Sender: TObject);
begin
  if FThread <> nil then
    FThread.DoForceUpdate;
end;

procedure TCnFeedReaderWizard.OnTimer(Sender: TObject);
begin
  if not Active then
    Exit;

  if Abs(GetTickCount - FLastUpdateTick) >= FChangePeriod * 1000 then
  begin
    FeedStep(1);
    FLastUpdateTick := GetTickCount;
  end;
end;

procedure TCnFeedReaderWizard.RandomFeed;
var
  i, Idx: Integer;
  List: TList;
begin
  FRandomFeeds.Clear;

  List := TList.Create;
  try
    List.Capacity := FSortedFeeds.Capacity;
    for i := 0 to FSortedFeeds.Count - 1 do
      List.Add(FSortedFeeds[i]);

    FRandomFeeds.Clear;
    FRandomFeeds.Capacity := List.Capacity;
    while List.Count > 0 do
    begin
      Idx := TrimInt(Round(Power(Random, 5) * List.Count), 0, List.Count - 1);
      FRandomFeeds.Add(List[Idx]);
      List.Delete(Idx);
    end;
  finally
    List.Free;
  end;
end;

procedure TCnFeedReaderWizard.OnFeedUpdate(Sender: TObject);
var
  i, j: Integer;
  Channel: TCnFeedChannel;
begin
  FFeeds.Clear;
  FSortedFeeds.Clear;
  FRandomFeeds.Clear;
  FCurFeed := nil;

  for i := 0 to FThread.FeedCount - 1 do
  begin
    Channel := TCnFeedChannel.Create;
    Channel.Assign(TCnFeedChannel(FThread.Feeds[i]));
    FFeeds.Add(Channel);
  end;

  FSortedFeeds.Clear;
  for i := 0 to FeedCount - 1 do
    for j := 0 to Feeds[i].Count - 1 do
      FSortedFeeds.Add(Feeds[i][j]);
  FSortedFeeds.Sort(DoSortFeed);

  RandomFeed;

  FeedStep(0);
end;

initialization
  RegisterCnWizard(TCnFeedReaderWizard);

{$ENDIF CNWIZARDS_CNFEEDREADERWIZARD}

end.
