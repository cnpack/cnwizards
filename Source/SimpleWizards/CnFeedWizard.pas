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

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, IniFiles, Forms,
  Menus, CommCtrl, ComCtrls, CnWizClasses, CnWizNotifier, CnWizUtils, CnCommon;

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

  TCnFeedWizard = class(TCnIDEEnhanceWizard)
  private
    FList: TList;
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm; 
      Operation: TOperation);
    procedure DoUpdateStatusPanel(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
    function GetCount: Integer;
    function GetPanels(Index: Integer): TCnStatusPanel;
    procedure PanelClick(Sender: TObject);
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

    property Count: Integer read GetCount;
    property Panels[Index: Integer]: TCnStatusPanel read GetPanels;
  end;

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnEditControlWrapper, CnWizIdeUtils;

const
  SCnFeedStatusPanel = 'CnFeedStatusPanel';
  SCnEdtStatusBar = 'StatusBar';

{$IFDEF COMPILER6_UP}
  csBarKeepWidth = 140;
{$ELSE}
  csBarKeepWidth = 80;
{$ENDIF}

{ TCnStatusPanel }

procedure TCnStatusPanel.CalcTextRect(AText: string; var ARect: TRect);
begin
  Canvas.Font := Font;
  ARect := ClientRect;
  DrawText(Canvas.Handle, PChar(AText), Length(AText), ARect,
    DT_CALCRECT or DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX or DT_END_ELLIPSIS);
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
  Text := 'This is a sample text displayed in status bar. The RSS support is coming soon.';
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
  inherited;

end;

constructor TCnFeedWizard.Create;
begin
  inherited;
  FList := TList.Create;
  
  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  UpdateStatusPanels;
end;

destructor TCnFeedWizard.Destroy;
var
  i: Integer;
begin
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  for i := FList.Count - 1 downto 0 do
    TCnStatusPanel(FList[i]).Free;
  FList.Free;
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
          FList.Add(Panel);
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

function TCnFeedWizard.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnFeedWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnFeedWizard.GetPanels(Index: Integer): TCnStatusPanel;
begin
  Result := TCnStatusPanel(FList[Index]);
end;

class procedure TCnFeedWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := 'Feed Wizard';
end;

procedure TCnFeedWizard.LanguageChanged(Sender: TObject);
begin
  inherited;

end;

procedure TCnFeedWizard.Loaded;
begin
  inherited;

end;

procedure TCnFeedWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnFeedWizard.PanelClick(Sender: TObject);
begin
  InfoDlg('This is a sample text displayed in status bar. The RSS context is coming soon.');
end;

procedure TCnFeedWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnFeedWizard.SetActive(Value: Boolean);
begin
  inherited;

end;

procedure TCnFeedWizard.UpdateStatusPanels;
var
  i: Integer;
begin
  EnumEditControl(DoUpdateStatusPanel, nil);
  for i := 0 to Count - 1 do
    Panels[i].UpdateStatus;
end;

initialization
  RegisterCnWizard(TCnFeedWizard);

end.
