{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnChatBox;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：聊天对话框实现类
* 单元作者：CnPack 开发组
* 备    注：该单元自开源代码 https://github.com/HemulGM/Components 改写而来
*           增加了 D5 的支持
*
* 开发平台：Win7 + Delphi 5.0
* 兼容测试：暂无
* 本 地 化：暂无
* 修改记录：2024.06.12 V0.1
*               移植单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Messages, Windows, SysUtils, Classes, Contnrs, Controls, Forms,
  Menus, Graphics, StdCtrls, ImgList, ShellAPI, Dialogs;

type
  TCnChatMessageType = (cmtYou, cmtMe);

  TCnChatItems = class;

  TCnCustomChatBox = class;

  TCnChatItem = class
  private
    FOwner: TCnChatItems;
    FNeedCalc: Boolean;
    FCalcedRect: TRect;
    FSelected: Boolean;
    FImageIndex: Integer;
    FCanSelected: Boolean;
    FDate: TDateTime;
    FText: string;
    FColor: TColor;
    procedure SetOwner(const Value: TCnChatItems);
    procedure SetSelected(const Value: Boolean);
    procedure SetImageIndex(const Value: Integer);
    procedure SetDate(const Value: TDateTime);
    procedure SetText(const Value: string);
    procedure SetColor(const Value: TColor);
  protected
    procedure NotifyRedraw; virtual;
  public
    constructor Create(AOwner: TCnChatItems); virtual;
    destructor Destroy; override;

    function DrawRect(Canvas: TCanvas; Rect: TRect): TRect; virtual;
    function DrawImage(Canvas: TCanvas; Rect: TRect): TRect; virtual;
    function CalcRect(Canvas: TCanvas; Rect: TRect): TRect; virtual;

    property Owner: TCnChatItems read FOwner write SetOwner;
    property Selected: Boolean read FSelected write SetSelected;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property Date: TDateTime read FDate write SetDate;
    property NeedCalc: Boolean read FNeedCalc write FNeedCalc;
    property CalcedRect: TRect read FCalcedRect write FCalcedRect;
    property Text: string read FText write SetText;
    property Color: TColor read FColor write SetColor;
    {* 每一条消息的颜色}
  end;

  TCnChatMessage = class(TCnChatItem)
  {* 聊天消息，分你的和我的两种样式}
  private
    FCalcedFromHeight: Integer;
    FShowFrom: Boolean;
    FFrom: string;
    FFromType: TCnChatMessageType;
    FFromColor: TColor;
    FFromColorSelect: TColor;
    procedure SetCalcedFromHeight(const Value: Integer);
    procedure SetFrom(const Value: string);
    procedure SetFromColor(const Value: TColor);
    procedure SetFromColorSelect(const Value: TColor);
    procedure SetFromType(const Value: TCnChatMessageType);
    procedure SetShowFrom(const Value: Boolean); virtual;
    function GetFromType: TCnChatMessageType;
  public
    constructor Create(AOwner: TCnChatItems); override;
    destructor Destroy; override;

    function CalcRect(Canvas: TCanvas; Rect: TRect): TRect; override;
    function DrawRect(Canvas: TCanvas; Rect: TRect): TRect; override;
    property ShowFrom: Boolean read FShowFrom write SetShowFrom;
    {* 是否绘制消息发送者}
    property From: string read FFrom write SetFrom;
    {* 消息发送者}
    property FromType: TCnChatMessageType read GetFromType write SetFromType;
    {* 消息发送者类型，你还是我}
    property FromColor: TColor read FFromColor write SetFromColor;
    {* 消息发送者的绘制颜色}
    property FromColorSelect: TColor read FFromColorSelect write SetFromColorSelect;
    {* 选中时的消息发送者颜色}
    property CalcedFromHeight: Integer read FCalcedFromHeight write SetCalcedFromHeight;
  end;

  TCnChatInfo = class(TCnChatItem)
  {* 居中的小块提示信息}
  private
    FFillColor: TColor;
  public
    procedure SetFillColor(const Value: TColor);
    function CalcRect(Canvas: TCanvas; Rect: TRect): TRect; override;
    function DrawRect(Canvas: TCanvas; Rect: TRect): TRect; override;
    constructor Create(AOwner: TCnChatItems); override;

    property FillColor: TColor read FFillColor write SetFillColor;
    {* 信息填充色}
  end;

  TCnChatItems = class(TObjectList)
  {* 聊天内容管理列表类}
  private
    FOwner: TCnCustomChatBox;
    procedure SetOwner(const Value: TCnCustomChatBox);
    function GetItem(Index: Integer): TCnChatItem;
    procedure SetItem(Index: Integer; const Value: TCnChatItem);
  public
    function AddMessage: TCnChatMessage;
    function AddInfo: TCnChatInfo;
    function Add(Value: TCnChatItem): Integer; overload;
    function Insert(Index: Integer; Value: TCnChatItem): Integer;
    function SelectCount: Integer;
    procedure Clear; override;

    procedure DoChanged(Item: TCnChatItem);
    procedure NeedResize;
    constructor Create(AOwner: TCnCustomChatBox);
    destructor Destroy; override;

    property Items[Index: Integer]: TCnChatItem read GetItem write SetItem; default;
    property Owner: TCnCustomChatBox read FOwner write SetOwner;
    {* 本聊天内容列表属于哪个聊天控件}
  end;

  TOnSelectionEvent = procedure(Sender: TObject; Count: Integer) of object;

  TCnCustomChatBox = class(TCustomControl)
  private
    FOffset: Integer;
    FMaxOffset: Integer;
    FItems: TCnChatItems;
    FMousePos: TPoint;
    FItemUnderMouse: Integer;
    FPreviousSelectedItem: Integer;
    FSelectionMode: Boolean;
    FScrollBarVisible: Boolean;
    FMouseIn: Boolean;
    FMouseInScroll: Boolean;
    FMouseInScrollButton: Boolean;
    FScrollPosStart: TPoint;
    FScrollLength: Integer;
    FScrollPos: Integer;
    FScrolling: Boolean;
    FPaintCounter: Integer;
    FImageList: TImageList;
    FDrawImages: Boolean;
    FDragItem: Boolean;
    FOnSelectionStart: TOnSelectionEvent;
    FOnSelectionEnd: TOnSelectionEvent;
    FOnSelectionChange: TOnSelectionEvent;
    FColorMe: TColor;
    FColorInfo: TColor;
    FColorSelection: TColor;
    FColorYou: TColor;
    FColorScrollActive: TColor;
    FColorScrollInactive: TColor;
    FColorScrollButton: TColor;
    FImageMargin: Integer;
    FPaddingSize: Integer;
    FBorderWidth: Integer;
    FRevertAdding: Boolean;
    FWasEventListEnd: Boolean;
    FShowingDownButton: Boolean;
    FDownButtonRect: TRect;
    FCalcOnly: Boolean;
    FOnPaint: TNotifyEvent;
    FUpdateCount: Integer;
    FOnListEnd: TNotifyEvent;
    FShowDownButton: Boolean;
    function GetItem(Index: Integer): TCnChatItem;
    procedure SetItem(Index: Integer; const Value: TCnChatItem);
    procedure SetItems(const Value: TCnChatItems);
    procedure FOnMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FOnMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FOnMouseMoveEvent(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FOnClick(Sender: TObject);
{$IFDEF TCONTROL_HAS_MOUSEENTERLEAVE}
    procedure FOnMouseEnter(Sender: TObject);
    procedure FOnMouseLeave(Sender: TObject);
{$ENDIF}
    procedure FOnDownButtonNeed;
    procedure FOnDownButtonHide;

    procedure FOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SetScrollBarVisible(const Value: Boolean);
    procedure CheckOffset;
    procedure SetImageList(const Value: TImageList);
    procedure NeedRepaint;
    procedure SetDrawImages(const Value: Boolean);
    procedure SelectionChange(Count: Integer);
    procedure SetOnSelectionChange(const Value: TOnSelectionEvent);
    procedure SetOnSelectionEnd(const Value: TOnSelectionEvent);
    procedure SetOnSelectionStart(const Value: TOnSelectionEvent);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure SetColorInfo(const Value: TColor);
    procedure SetColorMe(const Value: TColor);
    procedure SetColorYou(const Value: TColor);
    procedure SetColorSelection(const Value: TColor);
    procedure SetColorScrollActive(const Value: TColor);
    procedure SetColorScrollButton(const Value: TColor);
    procedure SetColorScrollInactive(const Value: TColor);
    procedure SetBorderWidth(const Value: Integer);
    procedure SetImageMargin(const Value: Integer);
    procedure SetPaddingSize(const Value: Integer);
    procedure SetRevertAdding(const Value: Boolean);
    procedure SetOnPaint(const Value: TNotifyEvent);
    procedure SetOnListEnd(const Value: TNotifyEvent);
    function NeedDrawDownButton: Boolean;
    function GetShowDownButton: Boolean;
    procedure SetShowDownButton(const Value: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    // procedure UpdateStyleElements; override;
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate(Force: Boolean = False);
    procedure Reset;

    property Item[Index: Integer]: TCnChatItem read GetItem write SetItem;
    property Items: TCnChatItems read FItems write SetItems;
    property DoubleBuffered default True;
    property ScrollBarVisible: Boolean read FScrollBarVisible write SetScrollBarVisible default True;
    property ImageList: TImageList read FImageList write SetImageList;
    property DrawImages: Boolean read FDrawImages write SetDrawImages default False;
    property OnSelectionStart: TOnSelectionEvent read FOnSelectionStart write SetOnSelectionStart;
    property OnSelectionChange: TOnSelectionEvent read FOnSelectionChange write SetOnSelectionChange;
    property OnSelectionEnd: TOnSelectionEvent read FOnSelectionEnd write SetOnSelectionEnd;
    property Color default $0020160F;
    property ColorInfo: TColor read FColorInfo write SetColorInfo default $003A2C1D;
    property ColorYou: TColor read FColorYou write SetColorYou default $00322519;
    property ColorMe: TColor read FColorMe write SetColorMe default $0078522B;
    property ColorSelection: TColor read FColorSelection write SetColorSelection default $00A5702E;
    property ColorScrollInactive: TColor read FColorScrollInactive write SetColorScrollInactive default $00332A24;
    property ColorScrollActive: TColor read FColorScrollActive write SetColorScrollActive default $003C342E;
    property ColorScrollButton: TColor read FColorScrollButton write SetColorScrollButton default $00605B56;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 4;
    property PaddingSize: Integer read FPaddingSize write SetPaddingSize default 10;
    property ImageMargin: Integer read FImageMargin write SetImageMargin default 36;
    property RevertAdding: Boolean read FRevertAdding write SetRevertAdding;

    property OnPaint: TNotifyEvent read FOnPaint write SetOnPaint;
    property OnListEnd: TNotifyEvent read FOnListEnd write SetOnListEnd;
    property ShowDownButton: Boolean read GetShowDownButton write SetShowDownButton;
  end;

  TCnChatBox = class(TCnCustomChatBox)
  public
    property Item;
    property Items;
  published
    property Align;
    property Color;
    property Canvas;
    property ScrollBarVisible;
    property DoubleBuffered;
    property Visible;
    property ImageList;
    property DrawImages;

    property OnSelectionStart;
    property OnSelectionChange;
    property OnSelectionEnd;
    property OnPaint;
    property OnListEnd;

    property ColorInfo;
    property ColorYou;
    property ColorMe;
    property ColorSelection;
    property ColorScrollInactive;
    property ColorScrollActive;
    property ColorScrollButton;
    property BorderWidth;
    property PaddingSize;
    property ImageMargin;
    property ShowDownButton default False;
  end;

implementation

uses
  Math, CnGraphUtils;

const
  FONT_DEF_SIZE = 10;
  FONT_SENDER_SIZE = 12;
  MOUSE_WHEEL_STEP = 50;
  DOWN_BUTTON_OFFSET = 300;

{ TCnCustomChatBox }

procedure TCnCustomChatBox.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TCnCustomChatBox.CheckOffset;
begin
  FOffset := Max(0, Min(FMaxOffset, FOffset));
  if not FShowingDownButton then
  begin
    if FOffset > DOWN_BUTTON_OFFSET then
      FOnDownButtonNeed;
  end
  else
  begin
    if FOffset < DOWN_BUTTON_OFFSET then
      FOnDownButtonHide;
  end;

  if FMaxOffset = FOffset then
  begin
    FWasEventListEnd := True;
    if Assigned(FOnListEnd) then
      FOnListEnd(Self);
  end
  else
    FWasEventListEnd := False;
end;

constructor TCnCustomChatBox.Create(AOwner: TComponent);
var
  I, J: Integer;
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csOpaque, csClickEvents, csDoubleClicks];
  Width := 200;
  Height := 400;
  Color := $0020160F;
  UseDockManager := True;
  // ParentBackground := False;
  DoubleBuffered := True;
  TabStop := True;

  OnMouseWheelDown := FOnMouseWheelDown;
  OnMouseWheelUp := FOnMouseWheelUp;
  OnMouseMove := FOnMouseMoveEvent;
  OnClick := FOnClick;
  OnMouseDown := FOnMouseDown;
  OnMouseUp := FOnMouseUp;

{$IFDEF TCONTROL_HAS_MOUSEENTERLEAVE}
  OnMouseEnter := FOnMouseEnter;
  OnMouseLeave := FOnMouseLeave;
{$ENDIF}

  FShowDownButton := False;

  FRevertAdding := False;
  FWasEventListEnd := False;
  FShowingDownButton := False;
  FCalcOnly := False;
  FColorYou := $00322519;
  FColorMe := $0078522B;
  FColorInfo := $003A2C1D;
  FColorSelection := $00A5702E;
  FColorScrollActive := $00BCB4AE;    // 滚动条活动颜色
  FColorScrollInactive := $00BCB4AE;  // 滚动条非活动颜色
  FColorScrollButton := $00605B56;

  FBorderWidth := 4;
  FPaddingSize := 10;
  FImageMargin := 36;

  FItemUnderMouse := -1;
  FDragItem := False;
  FSelectionMode := False;
  FPaintCounter := 0;
  FMouseIn := True; // 该变量控制鼠标进入时滚动条显示等，先强行设 True
  FMouseInScroll := False;
  FMouseInScrollButton := False;
  FScrollBarVisible := True;
  FPreviousSelectedItem := -100;
  FItems := TCnChatItems.Create(Self);

  if csDesigning in ComponentState then
  begin
    for I := 0 to 40 do
    begin
      with Items.AddMessage do
      begin
        From := 'UserName';
        if Random(40) in [20..30] then
          FromType := cmtMe;
        Text := 'Text body';
        for J := 1 to Random(10) do
          Text := Text + 'Text body';
        Text := DateTimeToStr(Now) + #13#10 + Text;
        FromColor := RGB(100, 180, 240);
      end;
      if I in [25..30] then
        with Items.AddInfo do
        begin
          Text := DateTimeToStr(Now);
        end;
    end;
  end;
end;

procedure TCnCustomChatBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
end;

destructor TCnCustomChatBox.Destroy;
begin
  FItems.Clear;
  FItems.Free;
  inherited;
end;

procedure TCnCustomChatBox.EndUpdate(Force: Boolean);
begin
  if Force then
    FUpdateCount := 0
  else
    Dec(FUpdateCount);

  if FUpdateCount = 0 then
    NeedRepaint;
end;

procedure TCnCustomChatBox.FOnClick(Sender: TObject);
begin
  if not Focused then
    SetFocus;

  if (not FDragItem) and (not FScrolling) and (FSelectionMode) then
  begin
    if FItemUnderMouse >= 0 then
      FItems[FItemUnderMouse].Selected := not FItems[FItemUnderMouse].Selected;
  end;
end;

procedure TCnCustomChatBox.FOnDownButtonHide;
begin
  FShowingDownButton := False;
  NeedRepaint;
end;

procedure TCnCustomChatBox.FOnDownButtonNeed;
begin
  FShowingDownButton := True;
  NeedRepaint;
end;

procedure TCnCustomChatBox.FOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if FScrollBarVisible then
    begin
      if FMouseInScroll and not FMouseInScrollButton then
      begin
        FScrollPos := FScrollLength - Y + 20;
        FOffset := Round((FScrollPos / (FScrollLength / 100)) / (100 / FMaxOffset));
        CheckOffset;
        FScrolling := True;
        FScrollPosStart.x := X;
        FScrollPosStart.y := Y;
        NeedRepaint;
        Exit;
      end;
      if FMouseInScrollButton then
      begin
        FScrolling := True;
        FScrollPosStart.x := X;
        FScrollPosStart.y := Y;
        NeedRepaint;
        Exit;
      end;
    end;
  end;
  NeedRepaint;
end;

{$IFDEF TCONTROL_HAS_MOUSEENTERLEAVE}

procedure TCnCustomChatBox.FOnMouseEnter(Sender: TObject);
begin
  FMouseIn := True;
  NeedRepaint;
end;

procedure TCnCustomChatBox.FOnMouseLeave(Sender: TObject);
begin
  FMouseIn := False;
  NeedRepaint;
end;

{$ENDIF}

procedure TCnCustomChatBox.FOnMouseMoveEvent(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  FMousePos.x := X;
  FMousePos.y := Y;
  if FScrolling then
  begin
    FScrollPos := FScrollPos + (FScrollPosStart.Y - FMousePos.Y);
    FOffset := Round((FScrollPos / (FScrollLength / 100)) / (100 / FMaxOffset));
    CheckOffset;
    FScrollPosStart := FMousePos;
  end
  else
  begin
    if not FDragItem then
    begin
      if ssLeft in Shift then
        if FItemUnderMouse >= 0 then
        begin
          FDragItem := True;
          FPreviousSelectedItem := -1;
        end;
    end;
    if FDragItem then
    begin
      if (FItemUnderMouse >= 0) and (FItemUnderMouse <> FPreviousSelectedItem) then
      begin
        FPreviousSelectedItem := FItemUnderMouse;
        FItems[FItemUnderMouse].Selected := not FItems[FItemUnderMouse].Selected;
      end
      else
        NeedRepaint;
    end;
  end;
  NeedRepaint;
end;

procedure TCnCustomChatBox.FOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if FScrollBarVisible then
      FScrolling := False;
    if FDragItem then
    begin
      FDragItem := False;
      FPreviousSelectedItem := -1;
    end;
  end;
end;

procedure TCnCustomChatBox.FOnMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  FOffset := FOffset - MOUSE_WHEEL_STEP;
  CheckOffset;
  NeedRepaint;
end;

procedure TCnCustomChatBox.FOnMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  FOffset := FOffset + MOUSE_WHEEL_STEP;
  CheckOffset;
  NeedRepaint;
end;

function TCnCustomChatBox.GetItem(Index: Integer): TCnChatItem;
begin
  Result := FItems[Index];
end;

function TCnCustomChatBox.GetShowDownButton: Boolean;
begin
  Result := FShowDownButton;
end;

procedure TCnCustomChatBox.NeedRepaint;
begin
  if FUpdateCount <= 0 then
    Invalidate;
end;

procedure TCnCustomChatBox.Paint;
const
  LimitWidth = 1000;
var
  Rect, ItemRect, LastRect, TxtRect, Limit, ImageRect: TRect;
  BaseColor: TColor;
  I, Radius: Integer;
  FStartDraw, FSkip, FNeedImage: Boolean;
  lpPaint: TPaintStruct;

  function NeedDraw(Item: TRect): Boolean;
  begin
    Result := False;
    if Item.Bottom < ClientRect.Top then
      Exit;
    if Item.Top > ClientRect.Bottom then
      Exit;
    Result := True;
  end;

begin
  Inc(FPaintCounter);
  Rect := ClientRect;

  CnRectInflate(Rect, -BorderWidth, -BorderWidth);
  // Rect.Inflate(-BorderWidth, -BorderWidth);
  Rect.Right := Rect.Right - 25; //scroll
  BaseColor := Color;
  FStartDraw := False;
  FSkip := False;
  BeginPaint(Handle, lpPaint);
  with Canvas do
  begin
    if not FCalcOnly then
    begin
      Brush.Color := BaseColor;
      FillRect(ClientRect);
    end;

    LastRect.Left := Rect.Left;
    LastRect.Top := Rect.Bottom;
    LastRect.Right := Rect.Right;
    LastRect.Bottom := Rect.Bottom;
    // LastRect := TRect.Create(Rect.Left, Rect.Bottom, Rect.Right, Rect.Bottom);

    FItemUnderMouse := -1;
    if FItems.Count > 0 then
    begin
      for I := FItems.Count - 1 downto 0 do
      begin
        Limit := Rect;
        CnRectInflate(Limit, -PaddingSize, -PaddingSize);
        // Limit.Inflate();
        FNeedImage := False;
        if FDrawImages then
          if (FItems[I] is TCnChatMessage) then
          begin
            FNeedImage := ((FItems[I] as TCnChatMessage).FromType = cmtYou) or (CnGetRectWidth(ClientRect) >
              LimitWidth);
            CnSetRectWidth(Limit, CnGetRectWidth(Limit) - FImageMargin);
          end;

        CnSetRectWidth(Limit, Min(500, CnGetRectWidth(Limit)));
        TxtRect := FItems[I].CalcRect(Canvas, Limit);

        Brush.Color := FColorYou;

        ItemRect := TxtRect;
        CnRectInflate(ItemRect, PaddingSize, PaddingSize);
        // ItemRect.Inflate();
        CnSetRectLocation(ItemRect, Rect.Left, LastRect.Top - CnGetRectHeight(ItemRect));
        // ItemRect.Location := TPoint.Create(Rect.Left, LastRect.Top - ItemRect.Height);
        LastRect := ItemRect;
        if (FItems[I] is TCnChatInfo) then
        begin
          CnRectOffset(LastRect, 0, -20);
          // LastRect.Offset(0, -20);
        end
        else
          CnRectOffset(LastRect, 0, -10);
        // LastRect.Offset(0, -10);

        if FSkip then
          Continue;

        Radius := 4;
        if (FItems[I] is TCnChatMessage) then
        begin
          if (FItems[I] as TCnChatMessage).FromType = cmtMe then
          begin
            if CnGetRectWidth(ClientRect) <= LimitWidth then
              CnSetRectLocation(ItemRect, Rect.Right - CnGetRectWidth(ItemRect), ItemRect.Top)
              // ItemRect.Location := TPoint.Create()
            else if FNeedImage then
              CnSetRectLocation(ItemRect, ItemRect.Left + FImageMargin, ItemRect.Top);
              // ItemRect.Location := TPoint.Create(ItemRect.Left + FImageMargin, ItemRect.Top);
            Brush.Color := FColorMe;
          end
          else if FNeedImage then
            CnSetRectLocation(ItemRect, ItemRect.Left + FImageMargin, ItemRect.Top);
          // ItemRect.Location := TPoint.Create(ItemRect.Left + FImageMargin, ItemRect.Top);
        end
        else if (FItems[I] is TCnChatInfo) then
        begin
          if CnGetRectWidth(ClientRect) <= LimitWidth then
            CnRectOffset(ItemRect, CnGetRectCenter(Rect).X - (CnGetRectWidth(ItemRect) div 2 + BorderWidth), 0)
          else
            CnRectOffset(ItemRect, (LimitWidth div 2) div 2 - (CnGetRectWidth(ItemRect) div 2 + BorderWidth), 0);
          if (FItems[I] as TCnChatInfo).FillColor = clNone then
            Brush.Color := FColorInfo
          else
            Brush.Color := (FItems[I] as TCnChatInfo).FillColor;
          Radius := CnGetRectHeight(ItemRect);
        end;
        CnRectOffset(ItemRect, PaddingSize, FOffset);

        if NeedDraw(ItemRect) then
        begin
          Limit := ItemRect;
          Limit.Left := 0;
          Limit.Right := ClientRect.Right;
          if CnRectContains(Limit, FMousePos) then
          begin
            FItemUnderMouse := I;
          end
          else
          begin
            //Brush.Color := clRed;
          end;
          FStartDraw := True;
          Brush.Style := bsSolid;
          if (FItems[I] is TCnChatMessage) and (FItems[I].Selected) then
            Brush.Color := FColorSelection;
          if not FCalcOnly then
          begin
            Pen.Color := Brush.Color; // ColorDarker(Brush.Color, 5);
            CnCanvasRoundRect(Canvas, ItemRect, Radius, Radius);
            // RoundRect(ItemRect, Radius, Radius);
            Brush.Style := bsClear;
          end;
          CnSetRectLocation(TxtRect, ItemRect.Left + PaddingSize, ItemRect.Top + PaddingSize);
          // TxtRect.Location := TPoint.Create();
          if not FCalcOnly then
          begin
            FItems[I].DrawRect(Canvas, TxtRect);
          end;

          if FNeedImage then
          begin
            ImageRect.Left := 0;
            ImageRect.Top := 0;
            ImageRect.Right := ImageMargin;
            ImageRect.Bottom := ImageMargin;
            // ImageRect := TRect.Create(0, 0, ImageMargin, ImageMargin);
            CnSetRectLocation(ImageRect, ItemRect.Left - CnGetRectWidth(ImageRect) - 3, ItemRect.Bottom
              - CnGetRectHeight(ImageRect) + 2);
            if not FCalcOnly then
            begin
              FItems[I].DrawImage(Canvas, ImageRect);
            end;
          end;
        end
        else if FStartDraw then
          FSkip := True;
      end;
    end;
    FMaxOffset := 0 - LastRect.Top;

    if (not FCalcOnly) and (Assigned(FOnPaint)) then
      FOnPaint(Self);

    if FScrollBarVisible or FCalcOnly then
    begin
      FMouseInScroll := False;
      FMouseInScrollButton := False;
      if FMouseIn or (csDesigning in ComponentState) then
      begin
        Rect := ClientRect;
        ItemRect := Rect;
        ItemRect.Left := ItemRect.Right - 12;  // 右侧宽 12 的区域作为滚动条
        ItemRect.Right := ItemRect.Right - 4;
        CnRectInflate(ItemRect, 0, -4);

        if CnRectContains(ItemRect, FMousePos) or FScrolling then
        begin
          FMouseInScroll := True;
          Brush.Color := FColorScrollActive;
        end
        else
          Brush.Color := FColorScrollInactive;

        if not FCalcOnly then
        begin
          Pen.Color := Brush.Color;
          CnCanvasRoundRect(Canvas, ItemRect, 6, 6);
          // RoundRect(ItemRect, 6, 6);
        end;

        LastRect := ItemRect; // ItemRect 现在是滚动条区域
        CnSetRectHeight(LastRect, 40);
        FScrollLength := CnGetRectHeight(ItemRect) - CnGetRectHeight(LastRect);

        FScrollPos := Round((FScrollLength / 100) * ((100 / FMaxOffset) * FOffset));
        CnSetRectLocation(LastRect, LastRect.Left, (ItemRect.Bottom - CnGetRectHeight(LastRect)) - FScrollPos);
        // LastRect.Location := TPoint.Create();

        if not FCalcOnly then
        begin
          if CnRectContains(LastRect, FMousePos) then // 鼠标光标仅仅在 LastRect 里才代表在滚动按钮里？
            FMouseInScrollButton := True;
          Brush.Color := FColorScrollButton;
          Pen.Color := Brush.Color;
          CnCanvasRoundRect(Canvas, LastRect, 6, 6);
          // RoundRect(LastRect, 6, 6);
        end;
      end;
    end;

    if NeedDrawDownButton then // 画下按钮的区域
    begin
      Rect := ClientRect;
      FDownButtonRect.Left := Rect.Right - 100;
      FDownButtonRect.Top := Rect.Bottom - 100;
      FDownButtonRect.Right := FDownButtonRect.Left + 40;
      FDownButtonRect.Bottom := FDownButtonRect.Top + 40;

      FillRect(FDownButtonRect);
    end;
  end;
  EndPaint(Handle, lpPaint);
end;

function TCnCustomChatBox.NeedDrawDownButton: Boolean;
begin
  Result := FShowDownButton and FShowingDownButton;
end;

procedure TCnCustomChatBox.Reset;
begin
  FOffset := 0;
  CheckOffset;
  NeedRepaint;
end;

procedure TCnCustomChatBox.WMNCPaint(var Message: TMessage);
begin
  NeedRepaint;
end;

procedure TCnCustomChatBox.WMSize(var Message: TWMSize);
begin
  FItems.NeedResize;
  FCalcOnly := True;
  try
    Paint;
  finally
    FCalcOnly := False;
  end;
  if FScrollLength > 0 then
    FOffset := Round((FScrollPos / (FScrollLength / 100)) / (100 / FMaxOffset))
  else
    FOffset := 0;
  CheckOffset;
  NeedRepaint;
  inherited;
end;

procedure TCnCustomChatBox.SelectionChange(Count: Integer);
begin
  if FSelectionMode and (Count = 0) then
  begin
    FSelectionMode := False;
    FPreviousSelectedItem := -1;
    if Assigned(FOnSelectionEnd) then
      FOnSelectionEnd(Self, 0);
  end
  else if FSelectionMode and (Count > 0) then
  begin
    if Assigned(FOnSelectionChange) then
      FOnSelectionChange(Self, Count);
  end
  else if (not FSelectionMode) and (Count > 0) then
  begin
    FSelectionMode := True;
    if Assigned(FOnSelectionStart) then
      FOnSelectionStart(Self, Count);
  end;
end;

procedure TCnCustomChatBox.SetBorderWidth(const Value: Integer);
begin
  FBorderWidth := Value;
  if not (csLoading in ComponentState) then
  begin
    FItems.NeedResize;
    NeedRepaint;
  end;
end;

procedure TCnCustomChatBox.SetColorInfo(const Value: TColor);
begin
  FColorInfo := Value;
end;

procedure TCnCustomChatBox.SetColorMe(const Value: TColor);
begin
  FColorMe := Value;
end;

procedure TCnCustomChatBox.SetColorYou(const Value: TColor);
begin
  FColorYou := Value;
end;

procedure TCnCustomChatBox.SetColorScrollActive(const Value: TColor);
begin
  FColorScrollActive := Value;
end;

procedure TCnCustomChatBox.SetColorScrollButton(const Value: TColor);
begin
  FColorScrollButton := Value;
end;

procedure TCnCustomChatBox.SetColorScrollInactive(const Value: TColor);
begin
  FColorScrollInactive := Value;
end;

procedure TCnCustomChatBox.SetColorSelection(const Value: TColor);
begin
  FColorSelection := Value;
end;

procedure TCnCustomChatBox.SetDrawImages(const Value: Boolean);
begin
  FDrawImages := Value;
  if not (csLoading in ComponentState) then
  begin
    FItems.NeedResize;
    NeedRepaint;
  end;
end;

procedure TCnCustomChatBox.SetImageList(const Value: TImageList);
begin
  FImageList := Value;
  NeedRepaint;
end;

procedure TCnCustomChatBox.SetImageMargin(const Value: Integer);
begin
  FImageMargin := Value;
  if not (csLoading in ComponentState) then
  begin
    FItems.NeedResize;
    NeedRepaint;
  end;
end;

procedure TCnCustomChatBox.SetItem(Index: Integer; const Value: TCnChatItem);
begin
  FItems[Index] := Value;
  NeedRepaint;
end;

procedure TCnCustomChatBox.SetItems(const Value: TCnChatItems);
begin
  if Assigned(FItems) then
    FItems.Free;
  FItems := Value;
end;

procedure TCnCustomChatBox.SetOnListEnd(const Value: TNotifyEvent);
begin
  FOnListEnd := Value;
end;

procedure TCnCustomChatBox.SetOnPaint(const Value: TNotifyEvent);
begin
  FOnPaint := Value;
end;

procedure TCnCustomChatBox.SetOnSelectionChange(const Value: TOnSelectionEvent);
begin
  FOnSelectionChange := Value;
end;

procedure TCnCustomChatBox.SetOnSelectionEnd(const Value: TOnSelectionEvent);
begin
  FOnSelectionEnd := Value;
end;

procedure TCnCustomChatBox.SetOnSelectionStart(const Value: TOnSelectionEvent);
begin
  FOnSelectionStart := Value;
end;

procedure TCnCustomChatBox.SetPaddingSize(const Value: Integer);
begin
  FPaddingSize := Value;
  if not (csLoading in ComponentState) then
  begin
    FItems.NeedResize;
    NeedRepaint;
  end;
end;

procedure TCnCustomChatBox.SetRevertAdding(const Value: Boolean);
begin
  FRevertAdding := Value;
end;

procedure TCnCustomChatBox.SetScrollBarVisible(const Value: Boolean);
begin
  FScrollBarVisible := Value;
  NeedRepaint;
end;

procedure TCnCustomChatBox.SetShowDownButton(const Value: Boolean);
begin
  FShowDownButton := Value;
  NeedRepaint;
end;

{ TChatItems }

function TCnChatItems.Add(Value: TCnChatItem): Integer;
begin
  if not FOwner.RevertAdding then
    Result := inherited Add(Value)
  else
  begin
    Insert(0, Value);
    Result := 0;
  end;
  FOwner.NeedRepaint;
end;

function TCnChatItems.AddInfo: TCnChatInfo;
begin
  Result := TCnChatInfo.Create(Self);
  Add(Result);
  FOwner.NeedRepaint;
end;

function TCnChatItems.AddMessage: TCnChatMessage;
begin
  Result := TCnChatMessage.Create(Self);
  Add(Result);
  FOwner.NeedRepaint;
end;

procedure TCnChatItems.Clear;
begin
  inherited;
  FOwner.Reset;
end;

constructor TCnChatItems.Create(AOwner: TCnCustomChatBox);
begin
  inherited Create;
  FOwner := AOwner;
end;

destructor TCnChatItems.Destroy;
begin
  Clear;
  inherited;
end;

procedure TCnChatItems.DoChanged(Item: TCnChatItem);
begin
  FOwner.SelectionChange(SelectCount);
  FOwner.NeedRepaint;
end;

function TCnChatItems.GetItem(Index: Integer): TCnChatItem;
begin
  Result := TCnChatItem(inherited GetItem(Index));
end;

function TCnChatItems.Insert(Index: Integer; Value: TCnChatItem): Integer;
begin
  inherited Insert(Index, Value);
  Result := Index;
  FOwner.NeedRepaint;
end;

procedure TCnChatItems.NeedResize;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].FNeedCalc := True;
end;

function TCnChatItems.SelectCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if Items[I].Selected then
      Inc(Result);
end;

procedure TCnChatItems.SetItem(Index: Integer; const Value: TCnChatItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TCnChatItems.SetOwner(const Value: TCnCustomChatBox);
begin
  FOwner := Value;
end;

{ TCnChatItem }

function TCnChatItem.CalcRect(Canvas: TCanvas; Rect: TRect): TRect;
var
  R: TRect;
  S: string;
begin
  if FNeedCalc then
  begin
    R := Rect;
    S := Text;
    Canvas.Font.Size := FONT_DEF_SIZE;
    Canvas.Font.Style := [];
    DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT or DT_CALCRECT
      or DT_WORDBREAK or DT_END_ELLIPSIS, nil);
    // Canvas.TextRect(R, S, [tfLeft, tfCalcRect, tfWordBreak, tfEndEllipsis]);
    FCalcedRect := R;
    Result := R;
    FNeedCalc := False;
  end
  else
    Result := FCalcedRect;
end;

function TCnChatItem.DrawImage(Canvas: TCanvas; Rect: TRect): TRect;
begin
  with Canvas do
  begin
    Brush.Color := (Self as TCnChatMessage).FromColor;
    Pen.Color := Brush.Color;
    Ellipse(Rect);
  end;
end;

function TCnChatItem.DrawRect(Canvas: TCanvas; Rect: TRect): TRect;
var
  R: TRect;
  S: string;
begin
  R := Rect;
  S := Text;
  Canvas.Font.Size := FONT_DEF_SIZE;
  Canvas.Font.Style := [];
  Canvas.Font.Color := Color;
  DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT
    or DT_WORDBREAK or DT_END_ELLIPSIS, nil);
  // Canvas.TextRect(R, S, [tfLeft, tfWordBreak, tfEndEllipsis]);
  Result := R;
end;

constructor TCnChatItem.Create(AOwner: TCnChatItems);
begin
  inherited Create;
  FCanSelected := True;
  FCalcedRect.Left := 0;
  FCalcedRect.Top := 0;
  FCalcedRect.Right := 0;
  FCalcedRect.Bottom := 0;
  FNeedCalc := True;
  FOwner := AOwner;
  Color := clBlack;
end;

destructor TCnChatItem.Destroy;
begin
  inherited;
end;

procedure TCnChatItem.SetColor(const Value: TColor);
begin
  FColor := Value;
end;

procedure TCnChatItem.SetDate(const Value: TDateTime);
begin
  FDate := Value;
end;

procedure TCnChatItem.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
end;

procedure TCnChatItem.SetOwner(const Value: TCnChatItems);
begin
  FOwner := Value;
end;

procedure TCnChatItem.SetSelected(const Value: Boolean);
begin
  if not FCanSelected then
    Exit;
  FSelected := Value;
  FOwner.DoChanged(Self);
end;

procedure TCnChatItem.SetText(const Value: string);
begin
  FText := Value;
  FNeedCalc := True;
  NotifyRedraw;
end;

procedure TCnChatItem.NotifyRedraw;
begin
  if FOwner <> nil then
    if FOwner.Owner <> nil then
      FOwner.Owner.NeedRepaint;
end;

{ TCnChatMessage }

function TCnChatMessage.CalcRect(Canvas: TCanvas; Rect: TRect): TRect;
var
  R: TRect;
  S: string;
begin
  if FNeedCalc then
  begin
    Result := Rect;
    R := Rect;
    S := Text;
    Canvas.Font.Size := FONT_DEF_SIZE;
    Canvas.Font.Style := [];
    DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT or DT_CALCRECT
      or DT_WORDBREAK or DT_END_ELLIPSIS, nil);
    // Canvas.TextRect(R, S, [tfLeft, tfCalcRect, tfWordBreak, tfEndEllipsis]);
    CnSetRectWidth(Result, CnGetRectWidth(R));
    CnSetRectHeight(Result, CnGetRectHeight(R));

    if (FromType = cmtYou) and FShowFrom then
    begin
      R := Rect;
      S := From;
      Canvas.Font.Size := FONT_SENDER_SIZE;
      Canvas.Font.Style := [fsBold];
      DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT or DT_CALCRECT
        or DT_SINGLELINE or DT_END_ELLIPSIS, nil);
      // Canvas.TextRect(R, S, [tfLeft, tfCalcRect, tfSingleLine, tfEndEllipsis]);
      CnSetRectWidth(Result, Max(CnGetRectWidth(Result), CnGetRectWidth(R)));
      CnSetRectHeight(Result, CnGetRectHeight(Result) + CnGetRectHeight(R));
      // Result.Height := Result.Height + R.Height;
      FCalcedFromHeight := CnGetRectHeight(R);
    end;

    FCalcedRect := Result;
    FNeedCalc := False;
  end
  else
    Result := FCalcedRect;
end;

function TCnChatMessage.DrawRect(Canvas: TCanvas; Rect: TRect): TRect;
var
  R: TRect;
  S: string;
begin
  if (FromType = cmtYou) and FShowFrom then
  begin
    // 画对方名字，加粗
    S := From;
    R := Rect;
    Canvas.Font.Size := FONT_SENDER_SIZE;
    Canvas.Font.Style := [fsBold];
    if Selected then
      Canvas.Font.Color := FromColorSelect
    else
      Canvas.Font.Color := FromColor;

    DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT
      or DT_SINGLELINE or DT_END_ELLIPSIS, nil);
    // Canvas.TextRect(R, S, [tfLeft, tfSingleLine, tfEndEllipsis]);
    Canvas.Font.Style := [];
  end;

  R := Rect;
  if (FromType = cmtYou) and FShowFrom then
    CnRectOffset(R, 0, FCalcedFromHeight);
    // R.Offset(0, FCalcedFromHeight);

  // 画文字内容
  S := Text;
  Canvas.Font.Size := FONT_DEF_SIZE;
  Canvas.Font.Style := [];
  Canvas.Font.Color := Color;
  DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT
    or DT_WORDBREAK or DT_END_ELLIPSIS, nil);
  // Canvas.TextRect(R, S, [tfLeft, tfWordBreak, tfEndEllipsis]);
  CnSetRectWidth(Rect, Max(CnGetRectWidth(Rect), CnGetRectWidth(R)));
  CnSetRectHeight(Rect, CnGetRectHeight(Rect) + CnGetRectHeight(R));

  Result := Rect;
end;

function TCnChatMessage.GetFromType: TCnChatMessageType;
begin
  Result := FFromType;
end;

procedure TCnChatMessage.SetCalcedFromHeight(const Value: Integer);
begin
  FCalcedFromHeight := Value;
end;

procedure TCnChatMessage.SetFrom(const Value: string);
begin
  FFrom := Value;
end;

procedure TCnChatMessage.SetFromColor(const Value: TColor);
begin
  FFromColor := Value;
end;

procedure TCnChatMessage.SetFromColorSelect(const Value: TColor);
begin
  FFromColorSelect := Value;
end;

procedure TCnChatMessage.SetFromType(const Value: TCnChatMessageType);
begin
  FFromType := Value;
end;

procedure TCnChatMessage.SetShowFrom(const Value: Boolean);
begin
  FShowFrom := Value;
end;

constructor TCnChatMessage.Create(AOwner: TCnChatItems);
begin
  inherited;
  FShowFrom := True;
  FromColor := clNavy;
  FromColorSelect := clWhite;
end;

destructor TCnChatMessage.Destroy;
begin
  inherited;
end;

{ TCnChatInfo }

function TCnChatInfo.CalcRect(Canvas: TCanvas; Rect: TRect): TRect;
var
  R: TRect;
  S: string;
begin
  if FNeedCalc then
  begin
    R := Rect;
    S := Text;
    Canvas.Font.Size := FONT_DEF_SIZE;
    Canvas.Font.Style := [fsBold];
    DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT or DT_CALCRECT
      or DT_WORDBREAK or DT_END_ELLIPSIS, nil);
    // Canvas.TextRect(R, S, [tfLeft, tfCalcRect, tfWordBreak, tfEndEllipsis]);
    FCalcedRect := R;
    Result := R;
    FNeedCalc := False;
  end
  else
    Result := FCalcedRect;
end;

constructor TCnChatInfo.Create(AOwner: TCnChatItems);
begin
  inherited;
  FCanSelected := False;
  FFillColor := clNone;
end;

function TCnChatInfo.DrawRect(Canvas: TCanvas; Rect: TRect): TRect;
var
  R: TRect;
  S: string;
begin
  R := Rect;
  S := Text;
  Canvas.Font.Size := FONT_DEF_SIZE;
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := Color;
  DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT
    or DT_WORDBREAK or DT_END_ELLIPSIS, nil);
  // Canvas.TextRect(R, S, [tfLeft, tfWordBreak, tfEndEllipsis]);
  Result := R;
end;

procedure TCnChatInfo.SetFillColor(const Value: TColor);
begin
  FFillColor := Value;
end;

end.
