// ****************************************************************************
// * Form Caption Bar Buttons component for Delphi.
// ****************************************************************************
// * Copyright 2002, Bitvad醩z Kft. All Rights Reserved.
// ****************************************************************************
// * This component can be freely used and distributed in commercial and
// * private environments, provied this notice is not modified in any way.
// ****************************************************************************
// * Feel free to contact me if you have any questions, comments or suggestions
// * at support@maxcomponents.net
// ****************************************************************************
// * Web page: www.maxcomponents.net
// ****************************************************************************
// * Date last modified: 02.01.2003
// ****************************************************************************
// * TmxCaptionBarButtons v1.11
// ****************************************************************************
// * Description:
// *
// * The TmxCaptionBarButtons is a VCL component to add custom buttons to
// * caption bar of form.
// *
// ****************************************************************************

// ****************************************************************************
// * Modified by JingYu Zhou, 07.20.2004
// * zjy@cnpack.org http://www.cnpack.org
// * Modified by Liu Xiao, 08.20.2006
// * liuxiao@cnpack.org http://www.cnpack.org
// ****************************************************************************
// ** 修改记录：
// *   + 增加了置顶按钮或整个按钮被禁用后，由置顶按钮点击导致的置顶被取消的机制
// *   + 增加了 OnRolled 事件
// *   + 增加了定时隐藏 Hint 窗口的功能
// *   + 增加了对 bsToolWindow、bsSizeToolWin 风格的支持，并自动适应
// *   + 增加 Enabled、CaptionPacked、APIStayOnTop 属性
// *   * 修正在 bsDialog、dsSingle 风格下按钮垂直方向与系统按钮未对齐的问题
// *   * 修正窗体失去焦点等情况下按钮未刷新显示的问题
// *   * 默认按钮图标显示位置改为置中，按钮太小时自动缩小图标尽寸
// *   * 当控件释放时恢复挂接的窗体事件
// *   * 当窗体 Dock 时禁用按钮
// *   * 修正窗体上有主菜单时按钮点击不能弹起的问题
// *   * 修正由于错误释放鼠标捕获引起的分割条失效等问题
// *   * 修正窗体折叠后失去焦点时按钮不显示的问题
// *   * 修正按钮显示时重复出现Palette句柄泄漏的问题
// ****************************************************************************

unit mxCaptionBarButtons;

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Menus,
  Dialogs, ExtCtrls;

const
  mxCaptionBarButtonsVersion = $010B;
  MX_BUTTONUP = WM_USER + $80A0;
  MX_REFRESH = WM_USER + $80A1;

type
  TmxCaptionButton = class;
  TmxCaptionButtons = class;

{ TmxCaptionBarButtons }

  TmxButtonProperty = (bpDown, bpUp, bpGroup);
  TmxButtonGlyph = (bgCaption, bgClose, bgHelp, bgMaximize, bgMinimize, bgRestore,
    bgOwnerDraw, bgGlyph, bgRollUp, bgRollDown, bgStayOn, bgStayOff);
  TmxButtonTypes = (btCustom, btRoller, btStayOnTop);

  TmxDrawButtonEvent = procedure(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
    State: TOwnerDrawState) of object;

  TmxCaptionBarButtons = class(TComponent)
  private
    FParent: TForm;
    FCaptionButtons: TmxCaptionButtons;
    FVersion: Integer;
    FWindowProc: TWndMethod;
    MethodPaint: TNotifyevent;
    MethodCanResize: Controls.TCanResizeEvent;
    FNeedRefresh: Boolean;
    FOldHeight: Integer;
    FEnabled: Boolean;
    FCaptionPacked: Boolean;
    FCapturing: Boolean;
    LastLeft: Integer;
    FAPIStayOnTop: Boolean;

    procedure SetVersion(AValue: string);
    function GetVersion: string;
    procedure SetItems(Value: TmxCaptionButtons);
    function GetItems: TmxCaptionButtons;
    function GetItem(Index: Integer): TmxCaptionButton;
    procedure SetEnabled(const Value: Boolean);
    procedure SetCaptionPacked(const Value: Boolean);

    function EdgeSize: TSize;
    function FrameSize: TSize;
    function ButtonSize: TSize;
    function CaptionHeight: Integer;
  protected
    procedure MyWindowProc(var Msg: TMessage);
    procedure RepaintCaption(Sender: TObject);
    procedure ParentCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure DisplaySettingChange(var Msg: TMessage);
    procedure DoStayOnTop(OnTop: Boolean);
    function IsActive: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;

    function ButtonByIndex(Index: Integer): TmxCaptionButton;
    procedure Refresh; virtual;

    property NeedRefresh: Boolean read FNeedRefresh write FNeedRefresh;
    property Parent: TForm read FParent; 
  published
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property CaptionPacked: Boolean read FCaptionPacked write SetCaptionPacked
      default True;
    property APIStayOnTop: Boolean read FAPIStayOnTop write FAPIStayOnTop
      default False;
    property Buttons: TmxCaptionButtons read GetItems write SetItems;
    property OldHeight: Integer read FOldHeight write FOldHeight;
    property Version: string read GetVersion write SetVersion stored False;
  end;

{ TmxCaptionButton }

  TmxCaptionButton = class(TCollectionItem)
  private
    FName: string;
    FTag: Integer;
    FCaption: string;
    FAllowAllUp: Boolean;
    FGroupIndex: Integer;
    FDown: Boolean;
    FFont: TFont;
    FHint: string;
    FHintWindow: THintWindow;
    FVisible: Boolean;
    FPressed: Boolean;
    FFocused: Boolean;
    FHintShow: Boolean;
    FWidth: Integer;
    FSeparator: Integer;
    FEnabled: Boolean;
    FButtonGlyph: TmxButtonGlyph;
    FPopupMenu: TPopupMenu;
    FDropDownMenu: TPopupMenu;
    FHintTimer: TTimer;
    FOnDrawButton: TmxDrawButtonEvent;

    FButtonRect: TRect;

    FButtonDown: TNotifyEvent;
    FMouseMove: TMouseMoveEvent;
    FButtonUp: TNotifyEvent;
    TempBoolean_1: Boolean;
    TempBoolean_2: Boolean;
    TempBoolean_3: Boolean;
    FButtonType: TmxButtonTypes;
    FRolledUp: Boolean;
    FStayOnTop: Boolean;
    FAnimate: Boolean;
    FSpeed: Integer;
    FGlyph: TBitmap;
    FOnRolled: TNotifyEvent;
    FDisableConstraint: Boolean;
    FConstraintMinHeight: Integer;
    // 是点击 Button 引起的置顶
    FIsClickTop: Boolean;

    procedure SetCaption(AValue: string);
    procedure SetAllowAllUp(AValue: Boolean);
    procedure SetDown(AValue: Boolean);
    procedure SetGroupIndex(AValue: Integer);
    procedure SetFont(AValue: TFont);
    procedure SetVisible(AValue: Boolean);
    procedure SetWidth(AValue: Integer);
    procedure SetSeparator(AValue: Integer);
    procedure SetEnabled(AValue: Boolean);
    procedure SetButtonGlyph(AValue: TmxButtonGlyph);
    procedure SetButtonType(AValue: TmxButtonTypes);
    procedure SetRolledUp(AValue: Boolean);
    procedure SetStayOnTop(AValue: Boolean);
    procedure SetPopupMenu(AValue: TPopupMenu);
    procedure SetDropDownMenu(AValue: TPopupMenu);
    procedure SetSpeed(AValue: Integer);
    procedure SetGlyph(const Value: TBitmap);

    procedure HintOnTimer(Sender: TObject);
  protected
    function GetDisplayName: string; override;
    procedure SetDisplayName(const Value: string); override;
    procedure ButtonUp(var Msg: TMessage; var Handled: Boolean);
    procedure TitlePaint(var Msg: TMessage; var Handled: Boolean);
    procedure MouseDown(var Msg: TMessage; var Handled: Boolean);
    procedure MouseUp(var Msg: TMessage; var Handled: Boolean);
    procedure Activate(var Msg: TMessage; var Handled: Boolean);
    procedure HitTest(var Msg: TMessage; var Handled: Boolean);
    procedure ParentMouseMove(var Msg: TMessage; var Handled: Boolean);
    procedure ParentMouseUp(var Msg: TMessage; var Handled: Boolean);
    procedure MouseMove(var Msg: TMessage; var Handled: Boolean);
    procedure RightMouseDown(var Msg: TMessage; var Handled: Boolean);
    procedure DoubleClick(var Msg: TMessage; var Handled: Boolean);
    procedure CaptionChange(var Msg: TMessage; var Handled: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure AssignTo(Dest: TPersistent); override;
    function BarButtons: TmxCaptionBarButtons;    
  published
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Animate: Boolean read FAnimate write FAnimate default False;
    property ButtonGlyph: TmxButtonGlyph read FButtonGlyph write SetButtonGlyph
      default bgCaption;
    property ButtonType: TmxButtonTypes read FButtonType write SetButtonType default
      btCustom;
    property Caption: string read FCaption write SetCaption;
    property DisableConstraint: Boolean read FDisableConstraint write FDisableConstraint;
    property DropDownMenu: TPopupMenu read FDropDownMenu write SetDropDownMenu;
    property Down: Boolean read FDown write SetDown;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Font: TFont read FFont write SetFont;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property Hint: string read FHint write FHint;
    property Name: string read GetDisplayName write SetDisplayName;
    property PopupMenu: TPopupMenu read FPopupMenu write SetPopupMenu;
    property RolledUp: Boolean read FRolledUp write SetRolledUp default False;
    property Separator: Integer read FSeparator write SetSeparator default 0;
    property StayOnTop: Boolean read FStayOnTop write SetStayOnTop default False;
    property Speed: Integer read FSpeed write SetSpeed default 30;
    property Tag: Integer read FTag write FTag default 0;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Width: Integer read FWidth write SetWidth;

    property OnClick: TNotifyEvent read FButtonUp write FButtonUp;
    property OnRolled: TNotifyEvent read FOnRolled write FOnRolled;
    property OnDrawButton: TmxDrawButtonEvent read FOnDrawButton write
      FOnDrawButton;
  end;

{ TmxCaptionButtons }

  TmxCaptionButtons = class(TCollection)
  private
    FCaptionBarButtons: TmxCaptionBarButtons;

    function GetButton(Index: Integer): TmxCaptionButton;
    procedure SetButton(Index: Integer; Value: TmxCaptionButton);
  protected
    function GetAttrCount: Integer; override;
    function GetAttr(Index: Integer): string; override;
    function GetItemAttr(Index, ItemIndex: Integer): string; override;
    procedure SetItemName(Item: TCollectionItem); override;
    procedure Update(Item: TCollectionItem); override;
    function GetOwner: TPersistent; override;
  public
    constructor Create(ACaptionBarButtons: TmxCaptionBarButtons; ItemClass:
      TCollectionItemClass);
    destructor Destroy; override;

    function Add: TmxCaptionButton;
    property CaptionBarButtons: TmxCaptionBarButtons read FCaptionBarButtons;
    property Buttons[Index: Integer]: TmxCaptionButton read GetButton write
      SetButton; default;

    procedure RefreshButton(Button: TmxCaptionButton; AValue: TmxButtonProperty);
  end;

implementation

{$R *.res}

var
  CtrlList: TThreadList;

resourcestring
  sDuplicatedItemName = 'Duplicated button name';

{ TmxCaptionButton }

constructor TmxCaptionButton.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  FAllowAllUp := False;
  FCaption := '';
  FTag := 0;
  FFont := TFont.Create;
  FHintWindow := THintWindow.Create(BarButtons);
  FHintWindow.Color := clInfoBk;
  FHintTimer := TTimer.Create(BarButtons);
  FHintTimer.Interval := Application.HintHidePause;
  FHintTimer.Enabled := False;
  FHintTimer.OnTimer := HintOnTimer;
  FPressed := False;
  FFocused := False;
  FHintShow := False;
  FEnabled := True;
  FVisible := True;
  FWidth := 0;
  FSeparator := 0;
  FButtonGlyph := bgCaption;
  FButtonType := btCustom;
  FSpeed := 30;
  FAnimate := False;
  FDisableConstraint := True;
  FGlyph := TBitmap.Create;
end;

destructor TmxCaptionButton.Destroy;
begin
  FGlyph.Free;
  FHintTimer.Free;
  FHintWindow.Free;
  FFont.Free;
  inherited Destroy;
end;

procedure TmxCaptionButton.AssignTo(Dest: TPersistent);
begin
  if Dest is TmxCaptionButton then
  begin
    if Assigned(Collection) then Collection.BeginUpdate;
    try
      with TmxCaptionButton(Dest) do
      begin
        FTag := Self.Tag;
        FCaption := Self.Caption;
      end;
    finally
      if Assigned(Collection) then Collection.EndUpdate;
    end;
  end
  else inherited AssignTo(Dest);
end;

function TmxCaptionButton.GetDisplayName: string;
begin
  Result := FName;
end;

procedure TmxCaptionButton.SetDisplayName(const Value: string);
var
  I: Integer;
  Item: TmxCaptionButton;
begin
  if AnsiCompareText(Value, FName) <> 0 then
  begin
    if Collection <> nil then
      for I := 0 to Collection.Count - 1 do
      begin
        Item := TmxCaptionButtons(Collection).Buttons[I];
        if (Item <> Self) and (Item is TmxCaptionButton) and
          (AnsiCompareText(Value, Item.Name) = 0) then
          raise Exception.Create(sDuplicatedItemName);
      end;
    FName := Value;
    Changed(False);
  end;
end;

procedure TmxCaptionButton.SetCaption(AValue: string);
begin
  FCaption := AValue;
  Changed(False);
  BarButtons.Refresh;
end;

procedure TmxCaptionButton.SetAllowAllUp(AValue: Boolean);
var
  CanAllowUp: Boolean;
begin
  BarButtons.NeedRefresh := True;
  CanAllowUp := FAllowAllUp;
  if FGroupIndex <> 0 then FAllowAllUp := AValue;

  if CanAllowUp <> FAllowAllUp then
    TmxCaptionButtons(Collection).RefreshButton(Self, bpUp);
end;

procedure TmxCaptionButton.SetDown(AValue: Boolean);
var
  CanDown: Boolean;
begin
  CanDown := FDown;
  if FDown <> AValue then
  begin
    if FGroupIndex = 0 then FDown := False else
    begin
      if FAllowAllUp = True then
        FDown := AValue else
        FDown := True;
    end;
  end;

  if CanDown <> FDown then
    TmxCaptionButtons(Collection).RefreshButton(Self, bpDown);
end;

procedure TmxCaptionButton.SetGroupIndex(AValue: integer);
var
  GroupCode: integer;
begin
  GroupCode := FGroupIndex;
  FGroupIndex := AValue;
  if FGroupIndex = 0 then
  begin
    FAllowAllUp := False;
    FDown := False;
  end;
  if GroupCode <> FGroupIndex then
    TmxCaptionButtons(Collection).RefreshButton(Self, bpGroup);
end;

procedure TmxCaptionButton.SetFont(AValue: TFont);
begin
  FFont.Assign(AValue);
  BarButtons.Refresh;
end;

procedure TmxCaptionButton.SetVisible(AValue: Boolean);
begin
  if FVisible <> AValue then
  begin
    FVisible := AValue;
    BarButtons.FParent.Perform(WM_NCACTIVATE, Integer(True), 0);
  end;
end;

procedure TmxCaptionButton.SetWidth(AValue: Integer);
begin
  if FWidth <> AValue then
  begin
    FWidth := AValue;
    BarButtons.Refresh;
  end;
end;

procedure TmxCaptionButton.SetSeparator(AValue: Integer);
begin
  if FSeparator <> AValue then
  begin
    FSeparator := AValue;
    BarButtons.Refresh;
  end;
end;

procedure TmxCaptionButton.SetButtonGlyph(AValue: TmxButtonGlyph);
begin
  if FButtonGlyph <> AValue then
  begin
    FButtonGlyph := AValue;
    BarButtons.Refresh;
  end;
end;

procedure TmxCaptionButton.SetEnabled(AValue: Boolean);
begin
  if FEnabled <> AValue then
  begin
    FEnabled := AValue;
    BarButtons.Refresh;

    // 置顶的按钮被禁用后，应该恢复由点击此按钮引发的置顶
    if not FEnabled and (FButtonType = btStayOnTop) then
    begin
      if StayOnTop and FIsClickTop then
      begin
        if BarButtons.FAPIStayOnTop then
          BarButtons.DoStayOnTop(False)
        else
          BarButtons.FParent.FormStyle := fsNormal;
      end;
    end;
  end;
end;

procedure TmxCaptionButton.ButtonUp(var Msg: TMessage; var Handled: Boolean);
var
  Button: TmxCaptionButton;
  CanDown: Boolean;
begin
  CanDown := FDown;

  BarButtons.FNeedRefresh := True;
  Button := (TCollectionItem(Msg.WParam) as TmxCaptionButton);

  if (Button <> Self) and (Msg.LParamLo = FGroupIndex) then
  begin
    if TmxButtonProperty(Msg.lparamhi) = bpDown then FDown := False;
    FAllowAllUp := Button.FAllowAllUp;

    if CanDown <> FDown then
      PostMessage(BarButtons.FParent.Handle, MX_REFRESH, 0, 0);
  end;
end;

procedure TmxCaptionButton.TitlePaint(var Msg: TMessage; var Handled: Boolean);
begin
  BarButtons.FNeedRefresh := True;
  if FVisible then
    PostMessage(BarButtons.FParent.Handle, MX_REFRESH, 0, 0);
end;

procedure TmxCaptionButton.MouseDown(var Msg: TMessage; var Handled: Boolean);
var
  Point: TPoint;
  IsPressed: Boolean;
  FParent: TForm;
  CanDown: Boolean;
begin
  CanDown := false;
  BarButtons.FNeedRefresh := True;
  if FVisible then
  begin
    FHintShow := False;
    FHintWindow.ReleaseHandle;
    FHintTimer.Enabled := False;
    FParent := BarButtons.FParent;
    SetForeGroundWindow(FParent.Handle);

    IsPressed := FPressed;

    Point.X := Msg.LParamLo - FParent.Left;
    Point.Y := Msg.LParamhi - FParent.Top;

    if ptInRect(FButtonRect, Point) then
    begin
      Handled := True;
      TempBoolean_3 := True;
      if FGroupIndex = 0 then CanDown := True else
      begin
        if not (FDown) then
          if Assigned(FButtonDown) then FButtonDown(FParent);
      end;
      FPressed := True;
      FFocused := True;
      SetCapture(FParent.Handle);
      BarButtons.FCapturing := True;
    end
    else
    begin
      FPressed := False;
      FFocused := False;
    end;

    if (IsPressed <> FPressed) then
      BarButtons.FNeedRefresh := False;

    TempBoolean_1 := FPressed;
    TempBoolean_2 := FFocused;
    BarButtons.RepaintCaption(FParent);

    if (CanDown) and Assigned(FButtonDown) then FButtonDown(FParent);
  end;
end;

procedure TmxCaptionButton.MouseUp(var Msg: TMessage; var Handled: Boolean);
var
  Point: TPoint;
  IsFocused: Boolean;
  IsPressed: Boolean;
  FParent: TForm;
begin
  BarButtons.FNeedRefresh := True;

  if FVisible then
  begin
    IsPressed := FPressed;
    IsFocused := FFocused;

    FParent := BarButtons.FParent;

    if (GetCapture = FParent.Handle) and BarButtons.FCapturing then
    begin
      ReleaseCapture;
      BarButtons.FCapturing := False;
    end;

    Point.X := Msg.LParamLo - FParent.Left;
    Point.Y := Msg.LParamhi - FParent.Top;

    if (ptInRect(FButtonRect, Point)) and (FFocused) then
      FPressed := False
    else
      FFocused := False;

    if ((IsPressed <> FPressed) or (IsFocused <> FFocused)) and (FAllowAllUp and
      FDown) then
      PostMessage(BarButtons.FParent.Handle, MX_REFRESH, 0, 0);
  end;
end;

procedure TmxCaptionButton.Activate(var Msg: TMessage; var Handled: Boolean);
begin
  BarButtons.FNeedRefresh := True;
  if FVisible then
    PostMessage(BarButtons.FParent.Handle, MX_REFRESH, 0, 0);
end;

procedure TmxCaptionButton.HitTest(var Msg: TMessage; var Handled: Boolean);
var
  IsFocused: Boolean;
  Point: TPoint;
  FParent: TForm;
begin
  BarButtons.FNeedRefresh := True;

  if FVisible then
  begin
    if FPressed then
    begin
      IsFocused := FFocused;
      FParent := BarButtons.FParent;
      Point.X := Msg.LParamlo - FParent.Left;
      Point.Y := Msg.LParamhi - FParent.Top;
      FFocused := ptInRect(FButtonrect, Point);
      if FFocused <> IsFocused then
        PostMessage(BarButtons.FParent.Handle, MX_REFRESH, 0, 0);
    end;

    if not FFocused then
    begin
      FHintWindow.ReleaseHandle;
      FHintTimer.Enabled := False;
    end;
    TempBoolean_1 := FPressed;
    TempBoolean_2 := FFocused;
  end;
end;

procedure TmxCaptionButton.ParentMouseMove(var Msg: TMessage; var Handled:
  Boolean);
var
  Point: TPoint;
  FParent: TForm;
  _Point: TPoint;
  _ButtonRect: TRect;
  ShiftState: TShiftstate;
begin
  BarButtons.FNeedRefresh := True;

  if FVisible then
  begin
    FFocused := False;

    FParent := BarButtons.FParent;

    Point.X := Msg.lparamlo;
    Point.Y := Msg.lparamhi - FParent.Top;
    _Point := Point;
    _Point.X := _Point.X + 4;
    _Point.Y := 65536 - _Point.Y - FParent.Top;
    _ButtonRect := FButtonRect;

    InflateRect(_ButtonRect, 1, 1);
    if ptInRect(_ButtonRect, _Point) then
    begin
      Handled := True;
      FFocused := True;
      if Assigned(FMouseMove) then
        FMouseMove(FParent, ShiftState, _Point.X, _Point.Y);
      if (TempBoolean_1 <> FPressed) or (TempBoolean_2 <> FFocused) then
      begin
        PostMessage(BarButtons.FParent.Handle, MX_REFRESH, 0, 0);
        TempBoolean_1 := FPressed;
        TempBoolean_2 := FFocused;
      end;
    end;

    if (TempBoolean_1 <> FPressed) or (TempBoolean_2 <> FFocused) then
    begin
      PostMessage(BarButtons.FParent.Handle, MX_REFRESH, 0, 0);
      TempBoolean_1 := FPressed;
      TempBoolean_2 := FFocused;
    end;

    FHintShow := False;
    FHintWindow.ReleaseHandle;
    FHintTimer.Enabled := False;
  end;
end;

procedure TmxCaptionButton.ParentMouseUp(var Msg: TMessage; var Handled:
  Boolean);
var
  Point: TPoint;
  FParent: TForm;
  NCHeight: Integer;
  _Point: TPoint;
  _ButtonRect: TRect;
  _Refresh: Boolean;
begin
  BarButtons.FNeedRefresh := True;

  if FVisible then
  begin
    _Refresh := False;
    FHintWindow.ReleaseHandle;
    FHintTimer.Enabled := False;
    FHintShow := True;
    FParent := BarButtons.FParent;
    if (GetCapture = FParent.Handle) and BarButtons.FCapturing then
    begin
      ReleaseCapture;
      BarButtons.FCapturing := False;
    end;
    FPressed := False;
    Point.X := Msg.lParamlo;
    Point.Y := Msg.lParamhi - FParent.Top;

    NCHeight := BarButtons.CaptionHeight + BarButtons.FrameSize.cy;
    if (FParent.BorderStyle <> bsDialog) and (FParent.Menu <> nil) then
      NCHeight := NCHeight + GetSystemMetrics(SM_CYMENU);
    _Point := Point;
    _Point.X := _Point.X + BarButtons.FrameSize.cx;
    _Point.Y := 65536 - _Point.Y;
    _Point.Y := NCHeight - (_Point.Y - FParent.Top);
    _ButtonRect := FButtonRect;

    InflateRect(_ButtonRect, 2, 2);
    if _Point.Y < (FParent.Top + FParent.Height) then Point := _Point;
    if (ptInRect(_ButtonRect, Point)) and (FFocused) and (TempBoolean_3) then
    begin
      if fgroupindex <> 0 then
      begin
        if FAllowAllUp = true then
          FDown := not (FDown) else
          FDown := True;

        TempBoolean_3 := False;
        TmxCaptionButtons(Collection).RefreshButton(Self, bpDown);
        if not (FDown) then _Refresh := True;
      end
      else _Refresh := true;

      BarButtons.RepaintCaption(FParent);

      if (_Refresh) then
      begin
        Handled := True;
        case ButtonType of
          btCustom:
            begin
              if Assigned(FDropDownMenu) then
                FDropDownMenu.Popup(FParent.Left + FButtonRect.Left, FParent.Top +
                  FButtonRect.Bottom + 1);
              if Assigned(FButtonUp) then FButtonUp(FParent);
            end;
          btRoller: RolledUp := not RolledUp;
          btStayOnTop:
            begin
              StayOnTop := not StayOnTop;
              FIsClickTop := StayOnTop;
            end;
        end;
      end;
    end
    else TempBoolean_3 := False;
  end;
end;

procedure TmxCaptionButton.MouseMove(var Msg: TMessage; var Handled: Boolean);
var
  Point: TPoint;
  ShiftState: TShiftState;
  FHintWidth: integer;
  FParent: TForm;
begin
  BarButtons.FNeedRefresh := True;

  if FVisible then
  begin
    FParent := BarButtons.FParent;

    TempBoolean_1 := FPressed;
    TempBoolean_2 := FFocused;

    Point.X := Msg.LParamLo - FParent.Left;
    Point.Y := Msg.LParamHi - FParent.Top;

    if PtInRect(FButtonRect, Point) then
    begin
      Handled := True;
      FFocused := True;
      FHintWidth := FHintWindow.Canvas.TextWidth(FHint);
      if (not FHintShow) and (Length(Trim(FHint)) <> 0) then
      begin
        FHintWindow.ActivateHint(Rect(Mouse.CursorPos.X, Mouse.CursorPos.Y + 10,
          Mouse.Cursorpos.X + FHintWidth + 7, Mouse.CursorPos.Y + 25), FHint);
        FHintTimer.Enabled := True; // 启动定时关闭 Hint 的 Timer
      end;

      FHintShow := True;
      if Assigned(FMouseMove) then
        FMouseMove(FParent, ShiftState, Point.X, Point.Y);
    end
    else
    begin
      FFocused := False;
      FHintWindow.ReleaseHandle;
      FHintShow := False;
      FHintTimer.Enabled := False;
    end;
  end;
end;

procedure TmxCaptionButton.RightMouseDown(var Msg: TMessage; var Handled:
  Boolean);
var
  Point: TPoint;
  FParent: TForm;
begin
  if FVisible then
  begin
    FParent := BarButtons.FParent;
    FHintWindow.ReleaseHandle;
    Point.X := Msg.LParamlo - FParent.Left;
    Point.Y := Msg.LParamHi - FParent.Top;

    if ptInRect(FButtonRect, Point) then
    begin
      Handled := True;
      if Assigned(FPopupMenu) then
      begin
        PopupMenu.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
      end;
      BarButtons.FNeedRefresh := True;
    end
    else BarButtons.FNeedRefresh := False;
  end;
end;

procedure TmxCaptionButton.CaptionChange(var Msg: TMessage; var Handled:
  Boolean);
begin
  BarButtons.FNeedRefresh := True;
  if FVisible then
    PostMessage(BarButtons.FParent.Handle, MX_REFRESH, 0, 0);
end;

procedure TmxCaptionButton.DoubleClick(var Msg: TMessage; var Handled: Boolean);
var
  Point: TPoint;
  FParent: TForm;
begin
  BarButtons.FNeedRefresh := True;

  if FVisible then
  begin
    FParent := BarButtons.FParent;
    Point.X := Msg.LParamlo - FParent.left;
    Point.Y := Msg.LParamhi - FParent.top;

    if ptInRect(FButtonrect, Point) then
    begin
      Handled := True;
      BarButtons.FNeedRefresh := False;
      FParent.Perform(WM_NCLBUTTONDOWN, Msg.wparam, Msg.LParam);
    end;
  end;
end;

function TmxCaptionButton.BarButtons: TmxCaptionBarButtons;
begin
  Result := TmxCaptionButtons(Collection).FCaptionBarButtons;
end;

procedure TmxCaptionButton.SetGlyph(const Value: TBitmap);
begin
  FGlyph.Assign(Value);
  BarButtons.Refresh;
end;

procedure TmxCaptionButton.SetPopupMenu(AValue: TPopupMenu);
begin
  if FPopupMenu <> AValue then
  begin
    FPopupMenu := AValue;
    Changed(False);
  end;
end;

procedure TmxCaptionButton.SetDropDownMenu(AValue: TPopupMenu);
begin
  if FDropDownMenu <> AValue then
  begin
    FDropDownMenu := AValue;
    Changed(False);
  end;
end;

procedure TmxCaptionButton.SetSpeed(AValue: Integer);
begin
  if FSpeed <> AValue then
  begin
    FSpeed := AValue;
    if FSpeed > 50 then FSpeed := 50;
    if FSpeed < 1 then FSpeed := 1;
  end;
end;

// *************************************************************************************
// ** Special predefinied buttons
// *************************************************************************************

procedure TmxCaptionButton.SetButtonType(AValue: TmxButtonTypes);
begin
  if FButtonType <> AValue then
  begin
    FButtonType := AValue;
    BarButtons.Refresh;
    case AValue of
      btRoller: RolledUp := False;
      btStayOnTop: StayOnTop := False;
    end;
  end;
end;

procedure TmxCaptionButton.SetStayOnTop(AValue: Boolean);
begin
  if (FStayOnTop <> AValue) and (FButtonType = btStayOnTop) then
  begin
    FStayOnTop := AValue;

    if BarButtons.IsActive then
    begin
      if BarButtons.FAPIStayOnTop then
      begin
        BarButtons.DoStayOnTop(AValue);
      end
      else
      begin
        if FStayOnTop then
          BarButtons.FParent.FormStyle := fsStayOnTop
        else
          BarButtons.FParent.FormStyle := fsNormal;
      end;
      BarButtons.Refresh;
    end;
  end;
end;

procedure TmxCaptionButton.SetRolledUp(AValue: Boolean);
var
  I: Integer;
  Steps: Integer;
  NCHeight: Integer;
begin
  if (FRolledUp <> AValue) and (FButtonType = btRoller) then
  begin
    FRolledUp := AValue;

    if BarButtons.IsActive then
    begin
      BarButtons.Refresh;
      if FRolledUp then
      begin
        FConstraintMinHeight := BarButtons.FParent.Constraints.MinHeight;      
        if FDisableConstraint then
          BarButtons.FParent.Constraints.MinHeight := 0;

        NCHeight := BarButtons.CaptionHeight + BarButtons.FrameSize.cy * 2;
        BarButtons.FOldHeight := BarButtons.FParent.Height;
        if FAnimate then
        begin
          Steps := (BarButtons.FParent.Height - NCHeight) div FSpeed;
          for I := 1 to Steps - 1 do
          begin
            BarButtons.FParent.Height := BarButtons.FParent.Height - FSpeed;
            BarButtons.FParent.Refresh;
          end;
        end;

        BarButtons.FParent.Height := NCHeight;
      end
      else
      begin
        if FAnimate then
        begin
          Steps := (BarButtons.FOldHeight - BarButtons.FParent.Height)
            div FSpeed;
          for I := 1 to Steps - 1 do
          begin
            BarButtons.FParent.Height := BarButtons.FParent.Height + FSpeed;
            BarButtons.FParent.Refresh;
          end;
        end;

        if FDisableConstraint and (FConstraintMinHeight > 0) then
          BarButtons.FParent.Constraints.MinHeight := FConstraintMinHeight;
        BarButtons.FParent.Height := BarButtons.FOldHeight;
      end;
      if Assigned(FOnRolled) then FOnRolled(Self);
      BarButtons.Refresh;
    end;
  end;
end;

procedure TmxCaptionButton.HintOnTimer(Sender: TObject);
begin
  FHintWindow.ReleaseHandle;
  FHintShow := False;
  FHintTimer.Enabled := False;
end;

{ TmxCaptionButtons }

constructor TmxCaptionButtons.Create(ACaptionBarButtons: TmxCaptionBarButtons;
  ItemClass: TCollectionItemClass);
begin
  inherited Create(ItemClass);
  FCaptionBarButtons := ACaptionBarButtons;
end;

destructor TmxCaptionButtons.Destroy;
begin
  inherited Destroy;
end;

function TmxCaptionButtons.GetOwner: TPersistent;
begin
  Result := FCaptionBarButtons;
end;

function TmxCaptionButtons.Add: TmxCaptionButton;
begin
  Result := TmxCaptionButton(inherited Add);
end;

function TmxCaptionButtons.GetButton(Index: Integer): TmxCaptionButton;
begin
  Result := TmxCaptionButton(inherited Items[Index]);
end;

function TmxCaptionButtons.GetAttrCount: Integer;
begin
  Result := 1;
end;

function TmxCaptionButtons.GetAttr(Index: Integer): string;
begin
  case Index of
    0: Result := 'Name';
  else
    Result := '';
  end;
end;

function TmxCaptionButtons.GetItemAttr(Index, ItemIndex: Integer): string;
begin
  case Index of
    0: Result := Buttons[ItemIndex].Name;
  else
    Result := '';
  end;
end;

procedure TmxCaptionButtons.SetButton(Index: Integer; Value: TmxCaptionButton);
begin
  Items[Index].Assign(Value);
end;

procedure TmxCaptionButtons.SetItemName(Item: TCollectionItem);
var
  I, J: Integer;
  ItemName: string;
  CurItem: TmxCaptionButton;
begin
  J := 1;
  while True do
  begin
    ItemName := Format('mxCaptionButton%d', [J]);
    I := 0;
    while I < Count do
    begin
      CurItem := Items[I] as TmxCaptionButton;
      if (CurItem <> Item) and (CompareText(CurItem.Name, ItemName) = 0) then
      begin
        Inc(J);
        Break;
      end;
      Inc(I);
    end;
    if I >= Count then
    begin
      (Item as TmxCaptionButton).Name := ItemName;
      Break;
    end;
  end;
end;

procedure TmxCaptionButtons.Update(Item: TCollectionItem);
begin
end;

procedure TmxCaptionButtons.RefreshButton(Button: TmxCaptionButton; AValue:
  TmxButtonProperty);
var
  AMessage: TMessage;
begin
  AMessage.Msg := MX_BUTTONUP;
  AMessage.WParam := Integer(Button);
  AMessage.LParamlo := Button.fgroupindex;
  AMessage.LParamHi := Word(AValue);
  AMessage.Result := 0;
  FCaptionBarButtons.FParent.Perform(AMessage.Msg, AMessage.WParam,
    AMessage.LParam);
end;

{ TmxCaptionBarButtons }

constructor TmxCaptionBarButtons.Create(AOwner: TComponent);
begin
  if not (AOwner is TCustomForm) then Exit;

  inherited Create(AOwner);

  FParent := TForm(Owner);
  FCaptionButtons := TmxCaptionButtons.Create(Self, TmxCaptionButton);
  FVersion := mxCaptionBarButtonsVersion;
  FNeedRefresh := False;
  FEnabled := True;
  FCaptionPacked := True;
  FAPIStayOnTop := False;

  CtrlList.Add(Self);
end;

destructor TmxCaptionBarButtons.Destroy;
begin
  CtrlList.Remove(Self);

  if not (csDesigning in ComponentState) then
  begin
    FParent.WindowProc := FWindowProc;
    FParent.OnPaint := MethodPaint;
  end;
  FCaptionButtons.Free;
  inherited Destroy;
end;

function TmxCaptionBarButtons.ButtonSize: TSize;
begin
  if FParent.BorderStyle in [bsSizeToolWin, bsToolWindow] then
  begin
    Result.cx := GetSystemMetrics(SM_CXSMSIZE);
    Result.cy := GetSystemMetrics(SM_CYSMSIZE) - GetSystemMetrics(SM_CYFRAME);
  end
  else
  begin
    Result.cx := GetSystemMetrics(SM_CXSIZE);
    Result.cy := GetSystemMetrics(SM_CYSIZE) - GetSystemMetrics(SM_CYFRAME);
  end;
end;

function TmxCaptionBarButtons.CaptionHeight: Integer;
begin
  if FParent.BorderStyle in [bsSizeToolWin, bsToolWindow] then
    Result := GetSystemMetrics(SM_CYSMCAPTION)
  else
    Result := GetSystemMetrics(SM_CYCAPTION);
end;

function TmxCaptionBarButtons.EdgeSize: TSize;
begin
  Result.cx := GetSystemMetrics(SM_CXEDGE);
  Result.cy := GetSystemMetrics(SM_CYEDGE);
end;

function TmxCaptionBarButtons.FrameSize: TSize;
begin
  if FParent.BorderStyle in [bsSizeToolWin, bsSizeable] then
  begin
    Result.cx := GetSystemMetrics(SM_CXSIZEFRAME);
    Result.cy := GetSystemMetrics(SM_CYSIZEFRAME);
  end
  else
  begin
    Result.cx := GetSystemMetrics(SM_CXDLGFRAME);
    Result.cy := GetSystemMetrics(SM_CYDLGFRAME);
  end;
end;

procedure TmxCaptionBarButtons.SetVersion(AValue: string);
begin
        // *** Does nothing ***
end;

procedure TmxCaptionBarButtons.SetEnabled(const Value: Boolean);
var
  I: Integer;
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    FParent.Perform(WM_NCACTIVATE, Integer(True), 0);

    // 整个按钮被禁用后，应该恢复由点击置顶按钮引发的置顶
    if not FEnabled then
    begin
      for I := 0 to Buttons.Count - 1 do
      begin
        if Buttons[I].ButtonType = btStayOnTop then
        begin
          if Buttons[I].StayOnTop and Buttons[I].FIsClickTop then
          begin
            if FAPIStayOnTop then
              DoStayOnTop(False)
            else
              FParent.FormStyle := fsNormal;
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

procedure TmxCaptionBarButtons.SetCaptionPacked(const Value: Boolean);
begin
  if FCaptionPacked <> Value then
  begin
    FCaptionPacked := Value;
    Refresh;
  end;
end;

function TmxCaptionBarButtons.GetVersion: string;
begin
  Result := Format('%d.%d', [Hi(FVersion), Lo(FVersion)]);
end;

function TmxCaptionBarButtons.GetItems: TmxCaptionButtons;
begin
  Result := FCaptionButtons;
end;

procedure TmxCaptionBarButtons.SetItems(Value: TmxCaptionButtons);
begin
  FCaptionButtons.Assign(Value);
end;

function TmxCaptionBarButtons.GetItem(Index: Integer): TmxCaptionButton;
begin
  Result := nil;
  if Index > FCaptionButtons.Count then Exit;
  Result := FCaptionButtons[Index];
end;

function TmxCaptionBarButtons.ButtonByIndex(Index: Integer): TmxCaptionButton;
begin
  Result := GetItem(Index);
end;

function TmxCaptionBarButtons.IsActive: Boolean;
begin
  Result := Enabled and Assigned(FParent) and
    ([csDesigning, csDestroying] * FParent.ComponentState = []) and
    (FParent.FormStyle in [fsNormal, fsStayOnTop]) and
    (FParent.BorderStyle <> bsNone) and (FParent.Parent = nil);
end;

procedure TmxCaptionBarButtons.DoStayOnTop(OnTop: Boolean);
const
  csOnTop: array[Boolean] of HWND = (HWND_NOTOPMOST, HWND_TOPMOST);
begin
  SetWindowPos(FParent.Handle, csOnTop[OnTop], 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TmxCaptionBarButtons.Loaded;
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    FWindowProc := FParent.WindowProc;
    FParent.WindowProc := MyWindowProc;

    MethodPaint := FParent.OnPaint;
    MethodCanResize := FParent.OnCanResize;
    FParent.OnPaint := RepaintCaption;
    FParent.OnCanResize := ParentCanResize;
  end;
end;

procedure TmxCaptionBarButtons.MyWindowProc(var Msg: TMessage);
var
  I: Integer;
  Handled: Boolean;
  Button: TmxCaptionButton;
begin
  Handled := False;

  if IsActive then
  begin
    for I := 0 to Buttons.Count - 1 do
    begin
      Button := Buttons[I];

      case Msg.Msg of
        WM_NCPAINT:
          Button.TitlePaint(Msg, Handled);
        WM_MOUSELEAVE:
          if Button.Enabled then
          begin
            Button.FHintWindow.ReleaseHandle;
            Button.FHintTimer.Enabled := False;
          end;
        WM_NCLBUTTONDOWN:
          if Button.Enabled then
            Button.MouseDown(Msg, Handled);
        WM_NCMOUSEMOVE:
          if Button.Enabled then
            Button.MouseMove(Msg, Handled);
        WM_NCLBUTTONUP:
          if Button.Enabled then
            Button.MouseUp(Msg, Handled);
        WM_NCACTIVATE:
          if Button.Enabled then
            Button.Activate(Msg, Handled);
        WM_NCHITTEST:
          if Button.Enabled then
            Button.HitTest(Msg, Handled);
        WM_LBUTTONUP:
          if Button.Enabled then
            Button.ParentMouseUp(Msg, Handled);
        WM_MOUSEMOVE:
          if Button.Enabled then
            Button.ParentMouseMove(Msg, Handled);
        WM_NCRBUTTONDOWN:
          if Button.Enabled then
            Button.RightMouseDown(Msg, Handled);
        WM_NCLBUTTONDBLCLK:
          if Button.Enabled then
            Button.DoubleClick(Msg, Handled);
        WM_SETTEXT:
          Button.CaptionChange(Msg, Handled);
        MX_BUTTONUP:
          Button.ButtonUp(Msg, Handled);
      end;
    end;

    if Msg.Msg = MX_REFRESH then
      Refresh;

    if Msg.Msg = WM_SETTINGCHANGE then
      DisplaySettingChange(Msg);
  end;

  if not Handled then
    FWindowProc(Msg);
end;

procedure TmxCaptionBarButtons.RepaintCaption(Sender: TObject);
var
  Glyph: TBitmap;
  ButtonCanvas: TCanvas;
  TextRect: TRect;
  I: Integer;
  Button: TmxCaptionButton;
  FWidth: Integer;
  FLeft: Integer;
  AddOn: Byte;
  Style: Integer;
  ButtonGlyph: TmxButtonGlyph;
  PushedFlag: Integer;
  Enabled: Integer;
  State: TOwnerDrawState;
  CaptionWidth: Integer;
  Rate: Double;
begin
  if IsActive then
  begin
    if GetWindowLong(FParent.Handle, GWL_STYLE) and WS_CAPTION <> WS_CAPTION then
      Exit;
      
    AddOn := 0;
    case FParent.BorderStyle of
      bsNone: Exit;
      bsSizeToolWin, bsToolWindow:
        begin
          if biSystemMenu in FParent.BorderIcons then
          begin
            Inc(AddOn, ButtonSize.cx);
          end;
        end;
      bsSingle, bsSizeable:
        begin
          if biSystemMenu in FParent.BorderIcons then
          begin
            Inc(AddOn, ButtonSize.cx);
            if (biMinimize in FParent.BorderIcons) or
              (biMaximize in FParent.BorderIcons) then
              Inc(AddOn, 2 * ButtonSize.cx);

            if biHelp in FParent.BorderIcons then
            begin
              if not ((biMinimize in FParent.BorderIcons) and (biMaximize in
                FParent.BorderIcons)) then
                Inc(AddOn, ButtonSize.cx);
            end;
          end;
        end;
      bsDialog:
        begin
          if biSystemMenu in FParent.BorderIcons then
          begin
            Inc(AddOn, ButtonSize.cx);
            if biHelp in FParent.BorderIcons then
              Inc(AddOn, ButtonSize.cx);
          end;
        end;
    end;

    for I := 0 to Buttons.Count - 1 do
    begin
      Glyph := TBitmap.Create;
      try
        Glyph.Transparent := True;
        Button := Buttons[I];

        if Button.Visible then
        begin
          if Button.Width = 0 then
            FWidth := ButtonSize.cx else
            FWidth := Button.Width;

          FLeft := FWidth + 1;
          AddOn := AddOn + Button.Separator;

          Button.FButtonRect.Left := FParent.Width - FLeft -
            (EdgeSize.cx + FrameSize.cx) - AddOn;
          Button.FButtonRect.Right := Button.FButtonRect.Left + ButtonSize.cx;
          Button.FButtonRect.Top := EdgeSize.cy + FrameSize.cy;
          Button.FButtonRect.Bottom := Button.FButtonRect.Top + ButtonSize.cy;

          ButtonCanvas := TCanvas.Create;
          ButtonCanvas.Handle := GetWindowDC(FParent.Handle);

          CaptionWidth := EdgeSize.cx + FrameSize.cx;
          if not CaptionPacked then
            CaptionWidth := CaptionWidth + ButtonCanvas.TextWidth(FParent.Caption);
          if (FParent.BorderStyle in [bsSingle, bsSizeable]) and
            (biSystemMenu in FParent.BorderIcons) then
            CaptionWidth := CaptionWidth + ButtonSize.cx;

          if Button.FButtonRect.Left < CaptionWidth then
          begin
            Button.FButtonRect.Left := 0;
            Button.FButtonRect.Right := 0;
            Button.FButtonRect.Top := 0;
            Button.FButtonRect.Bottom := 0;
            ReleaseDC(FParent.Handle, ButtonCanvas.Handle);
            ButtonCanvas.Handle := 0; // probably not necessary
            ButtonCanvas.Free;
            Break;
          end;

          ButtonGlyph := Button.ButtonGlyph;

          case Button.ButtonType of
            btRoller:
              begin
                if Button.RolledUp then
                begin
                  ButtonGlyph := bgRollDown;
                  Glyph.LoadFromResourceName(HInstance, 'ROLL_DOWN');
                end
                else
                begin
                  ButtonGlyph := bgRollUp;
                  Glyph.LoadFromResourceName(HInstance, 'ROLL_UP');
                end;
              end;
            btStayOnTop:
              begin
                if not FAPIStayOnTop then
                  Button.FStayOnTop := FParent.FormStyle = fsStayOnTop;

                if Button.StayOnTop then
                begin
                  ButtonGlyph := bgStayOff;
                  Glyph.LoadFromResourceName(HInstance, 'STAY_OFF');
                end
                else
                begin
                  ButtonGlyph := bgStayOn;
                  Glyph.LoadFromResourceName(HInstance, 'STAY_ON');
                end;
              end;
          end;

          case ButtonGlyph of

            bgCaption:
              begin
                FillRect(ButtonCanvas.Handle, Button.FButtonRect, HBRUSH(COLOR_BTNFACE
                  + 1));

                TextRect := Button.FButtonRect;

                if (Button.FFocused and Button.FPressed) or Button.FDown then
                begin
                  Drawedge(ButtonCanvas.Handle, Button.FButtonRect, EDGE_SUNKEN,
                    BF_SOFT or BF_RECT);
                  TextRect.Left := TextRect.Left + 2;
                  TextRect.Top := TextRect.Top + 1;
                  TextRect.Right := TextRect.Right - 1;
                end;

                if (not (Button.FPressed) or not (Button.FFocused)) and not
                  (Button.FDown) then
                begin
                  Drawedge(ButtonCanvas.Handle, Button.FButtonRect, EDGE_RAISED,
                    BF_SOFT or BF_RECT);
                  TextRect.Left := TextRect.Left + 1;
                  TextRect.Right := TextRect.Right - 1;
                end;

                ButtonCanvas.Brush.Style := bsclear;
                ButtonCanvas.Font.Assign(Button.Font);

                if Button.Enabled then
                begin
                  DrawText(ButtonCanvas.Handle, PChar(Button.Caption),
                    Length(Button.Caption), TextRect, DT_SINGLELINE or DT_VCENTER or
                    DT_CENTER or DT_END_ELLIPSIS or DT_PATH_ELLIPSIS);
                end
                else
                begin
                  OffsetRect(TextRect, 1, 1);
                  ButtonCanvas.Font.Color := clBtnHighlight;
                  DrawText(ButtonCanvas.Handle, PChar(Button.Caption),
                    Length(Button.Caption), TextRect, DT_SINGLELINE or DT_VCENTER or
                    DT_CENTER or DT_END_ELLIPSIS or DT_PATH_ELLIPSIS);
                  OffsetRect(TextRect, -1, -1);
                  ButtonCanvas.Font.Color := clBtnShadow;
                  DrawText(ButtonCanvas.Handle, PChar(Button.Caption),
                    Length(Button.Caption), TextRect, DT_SINGLELINE or DT_VCENTER or
                    DT_CENTER or DT_END_ELLIPSIS or DT_PATH_ELLIPSIS);
                end;
              end;

            bgOwnerDraw:
              begin
                if Assigned(Button.OnDrawButton) then
                begin
                  State := [];
                  if Button.FFocused then State := State + [odFocused];
                  if not Button.Enabled then State := State + [odDisabled];
                  if Button.FPressed then State := State + [odSelected];

                  Button.OnDrawButton(Self, ButtonCanvas, Button.FButtonRect, State);
                end;
              end;

            bgGlyph, bgStayOn, bgStayOff, bgRollUp, bgRollDown:
              begin
                if ButtonGlyph = bgGlyph then
                  Glyph.Assign(Button.Glyph);

                FillRect(ButtonCanvas.Handle, Button.FButtonRect, HBRUSH(COLOR_BTNFACE
                  + 1));

                TextRect := Button.FButtonRect;

                if (Button.FFocused and Button.FPressed) or Button.FDown then
                begin
                  Drawedge(ButtonCanvas.Handle, Button.FButtonRect, EDGE_SUNKEN,
                    BF_SOFT or BF_RECT);
                  TextRect.Left := TextRect.Left + 2;
                  TextRect.Top := TextRect.Top + 1;
                  TextRect.Right := TextRect.Right - 1;
                end;

                if (not (Button.FPressed) or not (Button.FFocused)) and not
                  (Button.FDown) then
                begin
                  Drawedge(ButtonCanvas.Handle, Button.FButtonRect, EDGE_RAISED,
                    BF_SOFT or BF_RECT);
                  TextRect.Left := TextRect.Left + 1;
                  TextRect.Right := TextRect.Right - 1;
                end;

                InflateRect(TextRect, -1, -1);
                Glyph.Transparent := True;
                Glyph.TransParentColor := Glyph.Canvas.Pixels[0, 0];
                with TextRect do
                begin
                  if Right - Left >= Glyph.Width then
                    ButtonCanvas.Draw(Left + (Right - Left - Glyph.Width) div 2,
                      Top + (Bottom - Top - Glyph.Height) div 2, Glyph)
                  else
                  begin
                    if (Right - Left) / Glyph.Width > (Bottom - Top) / Glyph.Height
                      then
                      Rate := (Bottom - Top) / Glyph.Height
                    else
                      Rate := (Right - Left) / Glyph.Width;
                    ButtonCanvas.StretchDraw(Bounds(Round(Left + (Right - Left -
                      Glyph.Width * Rate) / 2), Round(Top + (Bottom - Top -
                      Glyph.Height * Rate) / 2), Round(Glyph.Width * Rate),
                      Round(Glyph.Height * Rate)), Glyph);
                  end;
                end;
              end;
          else
            begin
              Style := 0;
              case Button.ButtonGlyph of
                bgClose: Style := DFCS_CAPTIONCLOSE;
                bgHelp: Style := DFCS_CAPTIONHELP;
                bgMaximize: Style := DFCS_CAPTIONMAX;
                bgMinimize: Style := DFCS_CAPTIONMIN;
                bgRestore: Style := DFCS_CAPTIONRESTORE;
              end;

              if Button.Enabled then
              begin
                if (Button.FPressed) and (Button.FFocused) then
                  PushedFlag := DFCS_PUSHED else PushedFlag := 0;
                Enabled := 0;
              end
              else
              begin
                PushedFlag := 0;
                Enabled := DFCS_INACTIVE;
              end;

              DrawFrameControl(ButtonCanvas.Handle, Button.FButtonRect, DFC_CAPTION,
                Style or PushedFlag or Enabled);
            end;
          end;

          ReleaseDC(FParent.Handle, ButtonCanvas.Handle);
          ButtonCanvas.Handle := 0;
          ButtonCanvas.Free;

          AddOn := AddOn + FWidth;
          LastLeft := Button.FButtonRect.Left;
        end;
      finally
        Glyph.Free;
      end;
    end;

    if Assigned(MethodPaint) then MethodPaint(Sender);
  end;
end;

procedure TmxCaptionBarButtons.ParentCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if not (csDesigning in ComponentState) then
  begin
    FNeedRefresh := True;
    RepaintCaption(Sender);
    if Assigned(MethodCanResize) then
      MethodCanResize(Self, NewWidth, NewHeight, Resize);
  end;
end;

procedure TmxCaptionBarButtons.DisplaySettingChange(var Msg: TMessage);
begin
  RepaintCaption(FParent);
  Msg.Result := 0;
  RepaintCaption(Self);
end;

procedure TmxCaptionBarButtons.Refresh;
begin
  RepaintCaption(Self);
end;

procedure InitList;
begin
  CtrlList := TThreadList.Create;
  CtrlList.Duplicates := dupIgnore;
end;

procedure FreeList;
var
  i: Integer;
begin
  with CtrlList.LockList do
  try
    for i := Count - 1 downto 0 do
      TmxCaptionBarButtons(Items[i]).Free;
  finally
    CtrlList.UnlockList;
  end;
  CtrlList.Clear;
  FreeAndNil(CtrlList);
end;

initialization
  InitList;

finalization
  FreeList;

end.

