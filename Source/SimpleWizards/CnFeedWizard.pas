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

{$IFDEF CNWIZARDS_CNFEEDWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, IniFiles, Forms,
  Menus, CommCtrl, ComCtrls, CnWizClasses, CnWizNotifier, CnWizUtils, CnCommon,
  CnFeedParser, Contnrs, ExtCtrls, Math, CnWizOptions, CnConsts, CnWizConsts,
  CnWizMultiLang;

type

{ TCnStatusPanel }

  TCnStatusPanel = class(TCustomControl)
  private
    FStatusBar: TStatusBar;
    FEditWindow: TCustomForm;
    FMenu: TPopupMenu;
    FActive: Boolean;
    FIsHot: Boolean;
    FText: string;
    procedure MenuPopup(Sender: TObject);
    procedure OnStatusBarResize(Sender: TObject);
    procedure CalcTextRect(AText: string; var ARect: TRect);
    procedure SetIsHot(const Value: Boolean);
    procedure SetText(const Value: string);
  protected
    procedure InitPopupMenu;
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Click; override;
    property IsHot: Boolean read FIsHot write SetIsHot;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LanguageChanged(Sender: TObject);
    procedure UpdateStatus;
    
    property StatusBar: TStatusBar read FStatusBar write FStatusBar;
    property EditWindow: TCustomForm read FEditWindow write FEditWindow;
    property Menu: TPopupMenu read FMenu;

    property Text: string read FText write SetText;
    property Active: Boolean read FActive write FActive;
  end;

  TCnFeedDefine = record
    IDStr: string;
    Url: string;
    CheckPeriod: Integer;
    Recent: Integer;
  end;

  TCnFeedWizard = class(TCnIDEEnhanceWizard)
  private
    FIni: TCustomIniFile;
    FFeedPath: string;
    FFeedDef: array of TCnFeedDefine;
    FLastUpdateTick: Cardinal;
    FLastCheckTick: Cardinal;
    FTimer: TTimer;
    FPanels: TList;
    FFeeds: TObjectList;
    FSortedFeeds: TList;
    FCurFeed: TCnFeedItem;
    FUpdatePeriod: Integer;
    FExludeCategories: string;
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
    procedure DoUpdateStatusPanel(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
    function GetPanelCount: Integer;
    function GetPanels(Index: Integer): TCnStatusPanel;
    procedure PanelClick(Sender: TObject);
    function GetFeedCount: Integer;
    function GetFeeds(Index: Integer): TCnFeedChannel;
    procedure OnTimer(Sender: TObject);
    function DoUpdateFeed(Def: TCnFeedDefine; ForceUpdate: Boolean): Boolean;
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

    procedure NextFeed;
    function UpdateFeeds(ForceUpdate: Boolean = False): Boolean;

    property PanelCount: Integer read GetPanelCount;
    property Panels[Index: Integer]: TCnStatusPanel read GetPanels;
    property FeedCount: Integer read GetFeedCount;
    property Feeds[Index: Integer]: TCnFeedChannel read GetFeeds;
    property CurFeed: TCnFeedItem read FCurFeed;
  published
    property UpdatePeriod: Integer read FUpdatePeriod write FUpdatePeriod default 30;
    property ExludeCategories: string read FExludeCategories write FExludeCategories;
  end;

{$ENDIF CNWIZARDS_CNCOMPONENTSELECTOR}

implementation

{$IFDEF CNWIZARDS_CNCOMPONENTSELECTOR}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnEditControlWrapper, CnWizIdeUtils, CnInetUtils, CnFeedWizardFrm;

const
  SCnFeedStatusPanel = 'CnFeedStatusPanel';
  SCnEdtStatusBar = 'StatusBar';
  SCnFeedCache = 'FeedCache\';
  SCnUpdateFeedMutex = 'CnUpdateFeedMutex';

  SCnOfficalFeedIDStr = 'CnPackOfficalFeed';
  SCnOfficalFeedUrl = 'http://www.cnpack.org/rssbuild.php?lang=en';
  SCnOfficalFeedPeriod = 24 * 60;
  SCnOfficalFeedRecent = 10;

{$IFDEF BCB6}
  csBarKeepWidth = 200;
{$ELSE}
{$IFDEF COMPILER6_UP}
  csBarKeepWidth = 140;
{$ELSE}
  csBarKeepWidth = 80;
{$ENDIF}
{$ENDIF}

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

procedure TCnStatusPanel.CMMouseLeave(var Message: TMessage);
begin
  IsHot := False;
end;

constructor TCnStatusPanel.Create(AOwner: TComponent);
begin
  inherited;
  InitPopupMenu;
end;

destructor TCnStatusPanel.Destroy;
begin
  if StatusBar <> nil then
    StatusBar.OnResize := nil;
  FMenu.Free;
  inherited;
end;

procedure TCnStatusPanel.InitPopupMenu;
begin
  FMenu := TPopupMenu.Create(Self);
  FMenu.OnPopup := MenuPopup;
  PopupMenu := FMenu;
end;

procedure TCnStatusPanel.LanguageChanged(Sender: TObject);
begin

end;

procedure TCnStatusPanel.MenuPopup(Sender: TObject);
begin

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
begin
  StatusBar.Perform(SB_GETRECT, StatusBar.Panels.Count - 1, Integer(@R));
  Inc(R.Left, csBarKeepWidth);
  SetBounds(R.Left + 1, R.Top + 1, R.Right - R.Left - 2, R.Bottom - R.Top - 2);
  Invalidate;
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
  Hint := Value;
  Invalidate;
end;

procedure TCnStatusPanel.UpdateStatus;
begin
  if Parent = nil then
  begin
    Parent := StatusBar;
    StatusBar.OnResize := OnStatusBarResize;
  end;
  OnStatusBarResize(StatusBar);
end;

{ TCnFeedWizard }

function TCnFeedWizard.CanShowPanels: Boolean;
begin
  Result := Active;
end;

procedure TCnFeedWizard.Config;
begin
  if ShowCnFeedWizardForm(Self) then
    DoSaveSettings;
end;

constructor TCnFeedWizard.Create;
begin
  inherited;
  FLastUpdateTick := GetTickCount;
  FLastCheckTick := GetTickCount;
  FPanels := TList.Create;
  FFeeds := TObjectList.Create;
  FSortedFeeds := TList.Create;
  FTimer := TTimer.Create(nil);
  FTimer.OnTimer := OnTimer;
  FTimer.Interval := 1000;
  FTimer.Enabled := True;
  FUpdatePeriod := 30;
  FIni := CreateIniFile;
  FFeedPath := WizOptions.UserPath + SCnFeedCache;
  ForceDirectories(FFeedPath);
  
  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  UpdateStatusPanels;
end;

destructor TCnFeedWizard.Destroy;
var
  i: Integer;
begin
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  for i := FPanels.Count - 1 downto 0 do
    TCnStatusPanel(FPanels[i]).Free;
  FPanels.Free;
  FFeeds.Free;
  FSortedFeeds.Free;
  FTimer.Free;
  FIni.Free;
  inherited;
end;

procedure TCnFeedWizard.DoUpdateStatusPanel(EditWindow: TCustomForm;
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
          Panel.EditWindow := EditWindow;
          Panel.StatusBar := StatusBar;
          Panel.OnClick := PanelClick;
          Panel.UpdateStatus;
          FPanels.Add(Panel);
        {$IFDEF DEBUG}
          CnDebugger.LogMsgWarning('CnStatusPanel installed');
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

procedure TCnFeedWizard.EditControlNotify(EditControl: TControl;
  EditWindow: TCustomForm; Operation: TOperation);
begin
  UpdateStatusPanels;
end;

function TCnFeedWizard.GetPanelCount: Integer;
begin
  Result := FPanels.Count;
end;

function TCnFeedWizard.GetFeedCount: Integer;
begin
  Result := FFeeds.Count;
end;

function TCnFeedWizard.GetFeeds(Index: Integer): TCnFeedChannel;
begin
  Result := TCnFeedChannel(FFeeds[Index]);
end;

function TCnFeedWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnFeedWizard.GetPanels(Index: Integer): TCnStatusPanel;
begin
  Result := TCnStatusPanel(FPanels[Index]);
end;

class procedure TCnFeedWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := 'Feed Wizard';
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := 'Feed Wizard';
end;

procedure TCnFeedWizard.LanguageChanged(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  for i := 0 to PanelCount - 1 do
    Panels[i].LanguageChanged(Sender);
end;

procedure TCnFeedWizard.Loaded;
begin
  inherited;
  UpdateFeeds;
end;

procedure TCnFeedWizard.LoadSettings(Ini: TCustomIniFile);
var
  AName, AIDStr: string;
  Cnt, i: Integer;
begin
  inherited;
  FFeedDef := nil;
  Cnt := Ini.ReadInteger('', 'DefCount', 0);
  for i := 0 to Cnt - 1 do
  begin
    AName := 'Item' + IntToStr(i);
    AIDStr := Ini.ReadString(AName, 'IDStr', '');
    if AIDStr <> '' then
    begin
      SetLength(FFeedDef, Length(FFeedDef) + 1);
      with FFeedDef[High(FFeedDef)] do
      begin
        IDStr := AIDStr;
        Url := Ini.ReadString(AName, 'Url', '');
        CheckPeriod := Ini.ReadInteger(AName, 'CheckPeriod', 24 * 60);
        Recent := Ini.ReadInteger(AName, 'Recent', 0);
      end;
    end;
  end;
end;

procedure TCnFeedWizard.SaveSettings(Ini: TCustomIniFile);
var
  AName: string;
  i: Integer;
begin
  inherited;
  Ini.WriteInteger('', 'DefCount', High(FFeedDef) + 1);
  for i := 0 to High(FFeedDef) do
  begin
    AName := 'Item' + IntToStr(i);
    with FFeedDef[High(i)] do
    begin
      Ini.WriteString(AName, 'IDStr', IDStr);
      Ini.WriteString(AName, 'Url', Url);
      Ini.WriteInteger(AName, 'CheckPeriod', CheckPeriod);
      Ini.WriteInteger(AName, 'Recent', Recent);
    end;
  end;
end;

procedure TCnFeedWizard.PanelClick(Sender: TObject);
begin
  if (FCurFeed <> nil) and (FCurFeed.Link <> '') then
    OpenUrl(FCurFeed.Link);
end;

procedure TCnFeedWizard.SetActive(Value: Boolean);
begin
  inherited;
  UpdateStatusPanels;
end;

procedure TCnFeedWizard.UpdateStatusPanels;
var
  i: Integer;
begin
  EnumEditControl(DoUpdateStatusPanel, nil);
  for i := 0 to PanelCount - 1 do
  begin
    if FCurFeed <> nil then
      Panels[i].Text := FCurFeed.Title
    else
      Panels[i].Text := '';
    Panels[i].UpdateStatus;
  end;
end;

procedure TCnFeedWizard.NextFeed;
var
  Rnd: Double;
  i: Integer;
begin
  FCurFeed := nil;
  if FSortedFeeds.Count > 0 then
  begin
    Rnd := Power(Random, 2.5);
    FCurFeed := TCnFeedItem(FSortedFeeds[TrimInt(Round(Rnd * FSortedFeeds.Count),
      0, FSortedFeeds.Count - 1)]);
    for i := 0 to PanelCount - 1 do
      Panels[i].Text := FCurFeed.Title;
  end;
  FLastUpdateTick := GetTickCount;
end;

procedure TCnFeedWizard.OnTimer(Sender: TObject);
begin
  if not Active then
    Exit;

  if Abs(GetTickCount - FLastUpdateTick) >= FUpdatePeriod * 1000 then
  begin
    NextFeed;
  end;

  if Abs(GetTickCount - FLastCheckTick) >= 60 * 1000 then
  begin
    if UpdateFeeds then
      NextFeed;
  end;
end;

function TCnFeedWizard.DoUpdateFeed(Def: TCnFeedDefine; ForceUpdate: Boolean): Boolean;
var
  FileName, TmpName: string;
  Feed: TCnFeedChannel;
  i: Integer;
  List: TList;
begin
  Result := False;
  
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
    FIni.WriteDateTime('LastCheck', Def.IDStr, Now);
    with TCnHTTP.Create do
    try
      if GetFile(Def.Url, TmpName) and (GetFileSize(TmpName) > 0) then
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

    if (Def.Recent > 0) and (Feed.Count > Def.Recent) then
    begin
      List := TList.Create;
      try
        for i := 0 to Feed.Count - 1 do
          List.Add(Feed[i]);
        List.Sort(DoSortFeed);
        for i := Def.Recent to List.Count - 1 do
          TCnFeedItem(List[i]).Free;
      finally
        List.Free;
      end;   
    end;  
  end;
end;

function TCnFeedWizard.UpdateFeeds(ForceUpdate: Boolean): Boolean;
var
  i, j: Integer;
  Offcial: TCnFeedDefine;
  hMutex: THandle;
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

    Offcial.IDStr := SCnOfficalFeedIDStr;
    Offcial.Url := SCnOfficalFeedUrl;
    Offcial.CheckPeriod := SCnOfficalFeedPeriod;
    Offcial.Recent := SCnOfficalFeedRecent;
    if DoUpdateFeed(Offcial, ForceUpdate) then
      Result := True;

    for i := Low(FFeedDef) to High(FFeedDef) do
      if DoUpdateFeed(FFeedDef[i], ForceUpdate) then
        Result := True;

    if Result then
    begin
      FCurFeed := nil;
      FSortedFeeds.Clear;
      for i := 0 to FeedCount - 1 do
        for j := 0 to Feeds[i].Count - 1 do
          FSortedFeeds.Add(Feeds[i][j]);
      FSortedFeeds.Sort(DoSortFeed);
    end;
  finally
    if hMutex <> 0 then
    begin
      ReleaseMutex(hMutex);
      CloseHandle(hMutex);
    end;
  end;
end;

initialization
  RegisterCnWizard(TCnFeedWizard);

{$ENDIF CNWIZARDS_CNCOMPONENTSELECTOR}

end.
