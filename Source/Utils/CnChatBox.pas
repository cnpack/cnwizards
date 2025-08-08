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

unit CnChatBox;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ�����Ի���ʵ����
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�Կ�Դ���� https://github.com/HemulGM/Components ��д����
*           �����˵Ͱ汾������ D5 ��֧��
*
*           ע�⣺����ÿ����Ϣ��ռ�ݵľ�������ʱ������ ChatBox �����Լ��� ClientRect
*           ���һ������ȣ�Ȼ������һ������� Rect������λ�ò���Ҫ������ȥ����
*           ÿ�� ChatItem �� CalcRect ������������ DrawTextEx �����Ի���ģʽ���
*           �ı���ռ�ݵľ����߲����ĸ� Rect �Ŀ��Ҳ�������½�ֵ��ChatBox �õ���
*           ������Ϣ������λ��ȷ�����Ƶ����Ͻǵ㣬���˾������ݻ��Ƴ�����
*
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ�����
* �� �� ��������
* �޸ļ�¼��2025.03.25 V0.3
*               �� Memo �����Ի�������ѡ��������
*           2025.03.15 V0.2
*               �����ı��Զ������������¼�
*           2024.06.12 V0.1
*               ��ֲ��Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Messages, Windows, SysUtils, Classes, Contnrs, Controls, Forms, Menus,
  {$IFDEF FPC} LCLType, {$ENDIF} Graphics, StdCtrls, ImgList, ShellAPI, Dialogs;

type
  TCnChatMessageType = (cmtYou, cmtMe);

  TCnChatMessageTypes = set of TCnChatMessageType;

  TCnChatItems = class;

  TCnCustomChatBox = class;

  TCnChatItem = class
  private
    FOwner: TCnChatItems;
    FNeedCalc: Boolean;
    FCalcedRect: TRect;    // ����ļ���õ����ݾ��Σ�ע�����Ͻǲ�����
    FSelected: Boolean;
    FImageIndex: Integer;
    FCanSelected: Boolean;
    FDate: TDateTime;
    FText: string;
    FColor: TColor;
    FWaiting: Boolean;
    FAbsolutePos: TPoint;  // ��¼��Ϣ���� ChatBox �е�ʵ������
    FAttachment: TObject;
    procedure SetOwner(const Value: TCnChatItems);
    procedure SetSelected(const Value: Boolean);
    procedure SetImageIndex(const Value: Integer);
    procedure SetDate(const Value: TDateTime);
    procedure SetText(const Value: string); virtual;
    procedure SetColor(const Value: TColor);
  protected
    procedure NotifyRedraw; virtual;
    procedure NotifyFontChanged; virtual;
    procedure NotifyHide; virtual;
  public
    constructor Create(AOwner: TCnChatItems); virtual;
    destructor Destroy; override;

    procedure DrawRect(Canvas: TCanvas; Rect: TRect); virtual;
    procedure DrawImage(Canvas: TCanvas; Rect: TRect); virtual;
    function CalcRect(Canvas: TCanvas; Rect: TRect): TRect; virtual;
    {* ����÷����� ChatBox ���ã������� Rect ���Ͻ��� 0��0 ����������ʵ�����
      ���಻Ӧ�޸����Ͻ����ֻ꣬�ܸ������Ͻ����궯̬�������½�����}
    property Owner: TCnChatItems read FOwner write SetOwner;
    property Selected: Boolean read FSelected write SetSelected;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property Date: TDateTime read FDate write SetDate;
    property NeedCalc: Boolean read FNeedCalc write FNeedCalc;
    property CalcedRect: TRect read FCalcedRect write FCalcedRect;
    property Text: string read FText write SetText;
    property Color: TColor read FColor write SetColor;
    {* ÿһ����Ϣ����ɫ}
    property Waiting: Boolean read FWaiting write FWaiting;

    property Attachment: TObject read FAttachment write FAttachment;
    {* ���ҵ��йܵĶ���}
  end;

  TCnChatMessage = class(TCnChatItem)
  {* ������Ϣ������ĺ��ҵ�������ʽ}
  private
    FCalcedFromHeight: Integer;
    FShowFrom: Boolean;
    FFrom: string;
    FFromType: TCnChatMessageType;
    FFromColor: TColor;
    FFromColorSelect: TColor;
    FTextPosition: TPoint; // ��Ϣ�ı������������Ϣ���ε�ƫ��
    FMemo: TMemo;
    procedure SetCalcedFromHeight(const Value: Integer);
    procedure SetFrom(const Value: string);
    procedure SetFromColor(const Value: TColor);
    procedure SetFromColorSelect(const Value: TColor);
    procedure SetFromType(const Value: TCnChatMessageType);
    procedure SetShowFrom(const Value: Boolean); virtual;
    function GetFromType: TCnChatMessageType;
    function GetSelText: string;
    procedure CheckMemo;
    function GetSelEnd: Integer;
    function GetSelStart: Integer;
  protected
    procedure NotifyFontChanged; override;
    procedure NotifyHide; override;
  public
    constructor Create(AOwner: TCnChatItems); override;
    destructor Destroy; override;

    function CalcRect(Canvas: TCanvas; Rect: TRect): TRect; override;
    {* ��ѷ����ߵ����Ƶ�����һ������������Ǵ�������ֿ�}

    procedure DrawRect(Canvas: TCanvas; Rect: TRect); override;

    procedure SelectNone;

    property ShowFrom: Boolean read FShowFrom write SetShowFrom;
    {* �Ƿ������Ϣ������}
    property From: string read FFrom write SetFrom;
    {* ��Ϣ������}
    property FromType: TCnChatMessageType read GetFromType write SetFromType;
    {* ��Ϣ���������ͣ��㻹����}
    property FromColor: TColor read FFromColor write SetFromColor;
    {* ��Ϣ�����ߵĻ�����ɫ}
    property FromColorSelect: TColor read FFromColorSelect write SetFromColorSelect;
    {* ѡ��ʱ����Ϣ��������ɫ}
    property CalcedFromHeight: Integer read FCalcedFromHeight write SetCalcedFromHeight;
    {* �����ߵĸ߶�}

    property SelStart: Integer read GetSelStart;
    {* ѡ����ʼƫ������0 ��ʾ�ӵ�һ���ַ���߿�ʼ������Ϊ�����ڵĵ� 0 ���ַ��ұ�}
    property SelEnd: Integer read GetSelEnd;
    {* ѡ����ʼƫ������1 ��ʾ��һ���ַ��ұ�}
    property SelText: string read GetSelText;
    {* ѡ�е��ı����� Text �ĵ� SelStart + 1 ���±��ַ���ʼ������ SelEnd ���±��ַ�Ϊֹ�ı�����}
  end;

  TCnChatInfo = class(TCnChatItem)
  {* ���е�С����ʾ��Ϣ}
  private
    FFillColor: TColor;
  public
    procedure SetFillColor(const Value: TColor);
    function CalcRect(Canvas: TCanvas; Rect: TRect): TRect; override;
    procedure DrawRect(Canvas: TCanvas; Rect: TRect); override;
    constructor Create(AOwner: TCnChatItems); override;

    property FillColor: TColor read FFillColor write SetFillColor;
    {* ��Ϣ���ɫ}
  end;

  TCnChatItems = class(TObjectList)
  {* �������ݹ����б���}
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
    procedure ClearNoWaiting;

    procedure NotifyFontChanged;

    procedure DoChanged(Item: TCnChatItem);
    procedure NeedResize;
    constructor Create(AOwner: TCnCustomChatBox);
    destructor Destroy; override;

    property Items[Index: Integer]: TCnChatItem read GetItem write SetItem; default;
    property Owner: TCnCustomChatBox read FOwner write SetOwner;
    {* �����������б������ĸ�����ؼ�}
  end;

  TCnOnSelectionEvent = procedure(Sender: TObject; Count: Integer) of object;

  TCnOnGetItemTextRect = procedure(Sender: TObject; Item: TCnChatItem; Canvas:
    TCanvas; var ItemTextRect: TRect; var DefaultCalc: Boolean) of object;

  TCnOnDrawItemText = procedure(Sender: TObject; Item: TCnChatItem; Canvas:
    TCanvas; var ItemTextRect: TRect; var DefaultDraw: Boolean) of object;

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
    FOnSelectionStart: TCnOnSelectionEvent;
    FOnSelectionEnd: TCnOnSelectionEvent;
    FOnSelectionChange: TCnOnSelectionEvent;
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
    FOnGetItemTextRect: TCnOnGetItemTextRect;
    FOnDrawItemText: TCnOnDrawItemText;
    function GetSelText: string;   // ������ȡѡ���ı�������
    function GetItem(Index: Integer): TCnChatItem;
    procedure SetItem(Index: Integer; const Value: TCnChatItem);
    procedure SetItems(const Value: TCnChatItems);
    procedure FOnMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos:
      TPoint; var Handled: Boolean);
    procedure FOnMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos:
      TPoint; var Handled: Boolean);
    procedure FOnMouseMoveEvent(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FOnClick(Sender: TObject);
    procedure FontChanged(var Message: TMessage); message CM_FONTCHANGED;

    procedure FOnMouseEnter(Sender: TObject);
    procedure FOnMouseLeave(Sender: TObject);
{$IFNDEF TCONTROL_HAS_MOUSEENTERLEAVE}
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
{$ENDIF}
    procedure FOnDownButtonNeed;
    procedure FOnDownButtonHide;

    procedure FOnMouseDown(Sender: TObject; Button: TMouseButton; Shift:
      TShiftState; X, Y: Integer);
    procedure FOnMouseUp(Sender: TObject; Button: TMouseButton; Shift:
      TShiftState; X, Y: Integer);
    procedure SetScrollBarVisible(const Value: Boolean);
    procedure CheckOffset;
    procedure SetImageList(const Value: TImageList);
    procedure NeedRepaint;
    procedure SetDrawImages(const Value: Boolean);
    procedure SelectionChange(Count: Integer);
    procedure SetOnSelectionChange(const Value: TCnOnSelectionEvent);
    procedure SetOnSelectionEnd(const Value: TCnOnSelectionEvent);
    procedure SetOnSelectionStart(const Value: TCnOnSelectionEvent);
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
    function GetScaledFactor: Single;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;

    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate(Force: Boolean = False);
    procedure Reset;

    function GetItemUnderMouse: TCnChatItem;
    function GetActualPadding: Integer;
    function GetFromDPI(OrigSize: Integer): Integer;

    procedure GetRecentMessages(OutList: TStrings; MsgCount: Integer;
      Types: TCnChatMessageTypes = [cmtMe]);
    {* ��ȡ�����б��������ָ����Ŀָ�����͵���Ϣ�� OutList �У����µ�����ͷ��}

    property Item[Index: Integer]: TCnChatItem read GetItem write SetItem;
    property Items: TCnChatItems read FItems write SetItems;
    property DoubleBuffered default True;
    property ScrollBarVisible: Boolean read FScrollBarVisible write
      SetScrollBarVisible default True;
    property ImageList: TImageList read FImageList write SetImageList;
    property DrawImages: Boolean read FDrawImages write SetDrawImages default False;
    property OnSelectionStart: TCnOnSelectionEvent read FOnSelectionStart write
      SetOnSelectionStart;
    property OnSelectionChange: TCnOnSelectionEvent read FOnSelectionChange
      write SetOnSelectionChange;
    property OnSelectionEnd: TCnOnSelectionEvent read FOnSelectionEnd write
      SetOnSelectionEnd;

    property OnGetItemTextRect: TCnOnGetItemTextRect read FOnGetItemTextRect
      write FOnGetItemTextRect;
    {* �ı���Ϣ�Ŀ�߼����¼���ע�� ItemRect ֵֻ�п�������ã������Ͻ�λ���޹�}
    property OnDrawItemText: TCnOnDrawItemText read FOnDrawItemText write
      FOnDrawItemText;
    {* �ı���Ϣ���Զ�������¼�}

    property Color default $0020160F;
    property ColorInfo: TColor read FColorInfo write SetColorInfo default $003A2C1D;
    property ColorYou: TColor read FColorYou write SetColorYou default $00322519;
    property ColorMe: TColor read FColorMe write SetColorMe default $0078522B;
    property ColorSelection: TColor read FColorSelection write SetColorSelection
      default $00A5702E;
    property ColorScrollInactive: TColor read FColorScrollInactive write
      SetColorScrollInactive default $00332A24;
    property ColorScrollActive: TColor read FColorScrollActive write
      SetColorScrollActive default $003C342E;
    property ColorScrollButton: TColor read FColorScrollButton write
      SetColorScrollButton default $00605B56;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 4;
    property PaddingSize: Integer read FPaddingSize write SetPaddingSize default 10;
    property ImageMargin: Integer read FImageMargin write SetImageMargin default 36;
    property RevertAdding: Boolean read FRevertAdding write SetRevertAdding;

    property SelText: string read GetSelText;
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
    property Font;
    property PopupMenu;
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
  ControlStyle := [csAcceptsControls, csCaptureMouse, csOpaque,
    csClickEvents, csDoubleClicks];

  Width := 200;
  Height := 400;
  Color := $0020160F;
  UseDockManager := True;

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
  FColorScrollActive := $00BCB4AE;    // ���������ɫ
  FColorScrollInactive := $00BCB4AE;  // �������ǻ��ɫ
  FColorScrollButton := $00605B56;

  FBorderWidth := 4;
  FPaddingSize := 10;
  FImageMargin := 36;

  FItemUnderMouse := -1;
  FDragItem := False;
  FSelectionMode := False;
  FPaintCounter := 0;
  FMouseIn := False; // �ñ�������������ʱ��������ʾ��
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

  if (not FDragItem) and (not FScrolling) and FSelectionMode then
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

procedure TCnCustomChatBox.FOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
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
end;

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

{$IFNDEF TCONTROL_HAS_MOUSEENTERLEAVE}

procedure TCnCustomChatBox.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FOnMouseEnter(Self);
end;

procedure TCnCustomChatBox.CMMouseLeave(var Message: TMessage);
begin
  FOnMouseLeave(Self);
end;

{$ENDIF}

procedure TCnCustomChatBox.FOnMouseMoveEvent(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
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
      begin
        if FItemUnderMouse >= 0 then
        begin
          FDragItem := True;
          FPreviousSelectedItem := -1;
        end;
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

procedure TCnCustomChatBox.FOnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
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

procedure TCnCustomChatBox.FOnMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  FOffset := FOffset - MOUSE_WHEEL_STEP;
  CheckOffset;
  NeedRepaint;
end;

procedure TCnCustomChatBox.FOnMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  FOffset := FOffset + MOUSE_WHEEL_STEP;
  CheckOffset;
  NeedRepaint;
end;

procedure TCnCustomChatBox.FontChanged(var Message: TMessage);
begin
  FItems.NotifyFontChanged;
  FItems.NeedResize;
  NeedRepaint;
end;

function TCnCustomChatBox.GetItem(Index: Integer): TCnChatItem;
begin
  Result := FItems[Index];
end;

function TCnCustomChatBox.GetScaledFactor: Single;
begin
{$IFDEF IDE_SUPPORT_HDPI}
  Result := Self.CurrentPPI / Windows.USER_DEFAULT_SCREEN_DPI;
{$ELSE}
  Result := 1.0; // IDE ��֧�� HDPI ʱԭ�ⲻ���ط��أ����� OS ����
{$ENDIF}
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
  MAX_MSG_WIDTH = 1200; // ��Ϣ����ȣ�����̫��һ�ж��ѿ�����������ʱ����
var
  Rect, ItemRect, LastRect, TxtRect, Limit, ImageRect: TRect;
  BaseColor: TColor;
  I, Radius, DX, DY: Integer;
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

  // �ڳ� Margin
  CnRectInflate(Rect, GetFromDPI(-BorderWidth), GetFromDPI(-BorderWidth));

  Rect.Right := Rect.Right - GetFromDPI(25); // scroll
  BaseColor := Color;
  FStartDraw := False;
  FSkip := False;
{$IFDEF FPC}
  BeginPaint(Handle, @lpPaint);
{$ELSE}
  BeginPaint(Handle, lpPaint);
{$ENDIF}
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

    FItemUnderMouse := -1;
    if FItems.Count > 0 then
    begin
      for I := FItems.Count - 1 downto 0 do
      begin
        Limit := Rect;

        // ��С Padding
        CnRectInflate(Limit, -GetActualPadding, -GetActualPadding);

        FNeedImage := False;
        if FDrawImages then
        begin
          if (FItems[I] is TCnChatMessage) then
          begin
            FNeedImage := ((FItems[I] as TCnChatMessage).FromType = cmtYou);
            CnSetRectWidth(Limit, CnGetRectWidth(Limit) - FImageMargin);
          end;
        end;

        // ��ʱȡ����Ϣ������ƿ�ȣ��õ�����Ϣ�����ݾ��γߴ��ȸ����Ͻ�ԭ�㣬ע������ᱻ����ƽ��
        DX := Limit.Left;
        DY := Limit.Top;
        CnRectOffset(Limit, -DX, -DY);
        TxtRect := FItems[I].CalcRect(Canvas, Limit); // ȷ������ CalcRect ʱ�ĳ�ʼ�������Ͻ�
        CnRectOffset(Limit, DX, DY);

        Brush.Color := FColorYou;

        ItemRect := TxtRect;
        // �����ݾ��α���Ŵ�һ�㣬���ƶ��������Ƶ�λ��
        CnRectInflate(ItemRect, PaddingSize, PaddingSize);
        CnSetRectLocation(ItemRect, Rect.Left, LastRect.Top - CnGetRectHeight(ItemRect) -  GetFromDPI(10));
        // �������� 10�������±߾�

        LastRect := ItemRect;
        if (FItems[I] is TCnChatInfo) then
          CnRectOffset(LastRect, 0, GetFromDPI(-20))
        else
          CnRectOffset(LastRect, 0, GetFromDPI(-10));  // �������������Ϣ�����¾���

        if FSkip then
          Continue;

        // ItemRect ��ʱ�� Top ��Ҫ���Ƶ�׼ȷλ�ã��������껹Ҫ������Ϣ�����Լ������Լ�����ͼ��ȷ��
        Radius := GetFromDPI(4);
        if (FItems[I] is TCnChatMessage) then
        begin
          if (FItems[I] as TCnChatMessage).FromType = cmtMe then
          begin
            // �ҵ���Ϣ�����ҿ�������ͷ�����ƶ�һ��
            CnSetRectLocation(ItemRect, Rect.Right - CnGetRectWidth(ItemRect),
              ItemRect.Top);
            if FNeedImage then
              CnSetRectLocation(ItemRect, ItemRect.Left + FImageMargin, ItemRect.Top);

            Brush.Color := FColorMe;
          end
          else if FNeedImage then // �����Ϣ���ѿ�������ͷ�����ƶ�һ��
            CnSetRectLocation(ItemRect, ItemRect.Left + FImageMargin, ItemRect.Top);
        end
        else if (FItems[I] is TCnChatInfo) then
        begin
          // ������Ϣֻ����ʾ������
          CnRectOffset(ItemRect, CnGetRectCenter(Rect).X - (CnGetRectWidth(ItemRect)
            div 2 + BorderWidth), 0);

          if (FItems[I] as TCnChatInfo).FillColor = clNone then
            Brush.Color := FColorInfo
          else
            Brush.Color := (FItems[I] as TCnChatInfo).FillColor;
          Radius := CnGetRectHeight(ItemRect);
        end;
        CnRectOffset(ItemRect, PaddingSize, FOffset);

        // ���������˸� Item ���ջ��Ƶľ��ε�λ�ô�С���ȼ�¼���Ͻ�λ��
        FItems[I].FAbsolutePos := Point(ItemRect.Left, ItemRect.Top);
        if FItems[I] is TCnChatMessage then
        begin
          // �ټ�¼��Ϣ�����ݾ��ε����ϽǺ͸�λ�õĲ�࣬��ʵ��һ������
          TCnChatMessage(FItems[I]).FTextPosition := FItems[I].FAbsolutePos;
          Inc(TCnChatMessage(FItems[I]).FTextPosition.x, PaddingSize);
          Inc(TCnChatMessage(FItems[I]).FTextPosition.y, PaddingSize);
        end;

        // �����Ƿ��ڿ��������ڣ��ڲŻ�
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
            // Brush.Color := clRed;
          end;
          FStartDraw := True;
          Brush.Style := bsSolid;
          if (FItems[I] is TCnChatMessage) and (FItems[I].Selected) then
            Brush.Color := FColorSelection;
          if not FCalcOnly then
          begin
            Pen.Color := Brush.Color;
            CnCanvasRoundRect(Canvas, ItemRect, Radius, Radius);

            Brush.Style := bsClear;
          end;
          CnSetRectLocation(TxtRect, ItemRect.Left + PaddingSize, ItemRect.Top +
            PaddingSize);

          // ���������ı����ݣ�ע�ⲻ���� TxtRect �ڲ��Ƿ����
          if not FCalcOnly then
            FItems[I].DrawRect(Canvas, TxtRect);

          if FNeedImage then
          begin
            ImageRect.Left := 0;
            ImageRect.Top := 0;
            ImageRect.Right := ImageMargin;
            ImageRect.Bottom := ImageMargin;

            CnSetRectLocation(ImageRect, ItemRect.Left - CnGetRectWidth(ImageRect)
              - 3, ItemRect.Bottom
              - CnGetRectHeight(ImageRect) + 2);

            if not FCalcOnly then
              FItems[I].DrawImage(Canvas, ImageRect);
          end;
        end
        else
        begin
          if FStartDraw then
          FSkip := True;
          FItems[I].NotifyHide;
        end;
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
        ItemRect.Left := ItemRect.Right - GetFromDPI(12);  // �Ҳ�� 12 ��������Ϊ������
        ItemRect.Right := ItemRect.Right - GetFromDPI(4);
        CnRectInflate(ItemRect, 0, GetFromDPI(-4));

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
          CnCanvasRoundRect(Canvas, ItemRect, GetFromDPI(6), GetFromDPI(6));
        end;

        LastRect := ItemRect; // ItemRect �����ǹ���������
        CnSetRectHeight(LastRect, 40);
        FScrollLength := CnGetRectHeight(ItemRect) - CnGetRectHeight(LastRect);

        FScrollPos := Round((FScrollLength / 100) * ((100 / FMaxOffset) * FOffset));
        CnSetRectLocation(LastRect, LastRect.Left,
          (ItemRect.Bottom - CnGetRectHeight(LastRect)) - FScrollPos);

        if not FCalcOnly then
        begin
          if CnRectContains(LastRect, FMousePos) then // ���������� LastRect ��Ŵ����ڹ�����ť�
            FMouseInScrollButton := True;
          Brush.Color := FColorScrollButton;
          Pen.Color := Brush.Color;
          CnCanvasRoundRect(Canvas, LastRect, GetFromDPI(6), GetFromDPI(6));
        end;
      end;
    end;

    if NeedDrawDownButton then // ���°�ť������
    begin
      Rect := ClientRect;
      FDownButtonRect.Left := Rect.Right - GetFromDPI(100);
      FDownButtonRect.Top := Rect.Bottom - GetFromDPI(100);
      FDownButtonRect.Right := FDownButtonRect.Left + GetFromDPI(40);
      FDownButtonRect.Bottom := FDownButtonRect.Top + GetFromDPI(40);

      FillRect(FDownButtonRect);
    end;
  end;
{$IFDEF FPC}
  EndPaint(Handle, @lpPaint);
{$ELSE}
  EndPaint(Handle, lpPaint);
{$ENDIF}
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

procedure TCnCustomChatBox.WMContextMenu(var Message: TWMContextMenu);
var
  Pt, Temp: TPoint;
begin
  if Message.Result <> 0 then
    Exit;
  if csDesigning in ComponentState then
    Exit;

  if (PopupMenu <> nil) and PopupMenu.AutoPopup then
  begin
    Pt := SmallPointToPoint(Message.Pos);
    if Pt.X < 0 then
      Temp := Pt
    else
    begin
      Temp := ScreenToClient(Pt);
      if not PtInRect(ClientRect, Temp) then
      begin
        inherited;
        Exit;
      end;
    end;

{$IFNDEF FPC}
    SendCancelMode(nil);
{$ENDIF}
    PopupMenu.PopupComponent := Self;
    if Pt.X < 0 then
      Pt := ClientToScreen(Point(0, 0));

    PopupMenu.Popup(Pt.X, Pt.Y);
    Message.Result := 1;
  end;
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

procedure TCnCustomChatBox.SetOnSelectionChange(const Value: TCnOnSelectionEvent);
begin
  FOnSelectionChange := Value;
end;

procedure TCnCustomChatBox.SetOnSelectionEnd(const Value: TCnOnSelectionEvent);
begin
  FOnSelectionEnd := Value;
end;

procedure TCnCustomChatBox.SetOnSelectionStart(const Value: TCnOnSelectionEvent);
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

procedure TCnChatItems.ClearNoWaiting;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if not Items[I].Waiting then
      Delete(I);
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

procedure TCnChatItems.NotifyFontChanged;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].NotifyFontChanged;
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

function TCnCustomChatBox.GetItemUnderMouse: TCnChatItem;
begin
  if FItemUnderMouse >= 0 then
    Result := FItems[FItemUnderMouse]
  else
    Result := nil;
end;

function TCnCustomChatBox.GetSelText: string;
var
  Item: TCnChatItem;
begin
  Result := '';
  Item := GetItemUnderMouse;
  if Item is TCnChatMessage then
    Result := TCnChatMessage(Item).GetSelText;
end;

function TCnCustomChatBox.GetActualPadding: Integer;
begin
  Result := Round(PaddingSize * GetScaledFactor);
end;

function TCnCustomChatBox.GetFromDPI(OrigSize: Integer): Integer;
begin
  Result := Round(OrigSize * GetScaledFactor);
end;

procedure TCnCustomChatBox.GetRecentMessages(OutList: TStrings;
  MsgCount: Integer; Types: TCnChatMessageTypes);
var
  I: Integer;
begin
  if (MsgCount <= 0) or (OutList = nil) then
    Exit;

  for I := Items.Count - 1 downto 0 do
  begin
    if Items[I] is TCnChatMessage then
    begin
      if TCnChatMessage(Items[I]).FromType in Types then
      begin
        OutList.Add(TCnChatMessage(Items[I]).Text);
        if OutList.Count >= MsgCount then
          Exit;
      end;
    end;
  end;
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
    if FOwner.Owner <> nil then
      Canvas.Font := FOwner.Owner.Font
    else
      Canvas.Font.Size := FONT_DEF_SIZE;

    Canvas.Font.Style := [];
    DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT or DT_CALCRECT
      or DT_WORDBREAK or DT_END_ELLIPSIS, nil);

    FCalcedRect := R;
    Result := R;
    FNeedCalc := False;
  end
  else
    Result := FCalcedRect;
end;

procedure TCnChatItem.DrawImage(Canvas: TCanvas; Rect: TRect);
begin
  with Canvas do
  begin
    Brush.Color := (Self as TCnChatMessage).FromColor;
    Pen.Color := Brush.Color;
    Ellipse(Rect);
  end;
end;

procedure TCnChatItem.DrawRect(Canvas: TCanvas; Rect: TRect);
var
  R: TRect;
  S: string;
begin
  R := Rect;
  S := Text;
  if FOwner.Owner <> nil then
    Canvas.Font := FOwner.Owner.Font
  else
    Canvas.Font.Size := FONT_DEF_SIZE;

  Canvas.Font.Style := [];
  Canvas.Font.Color := Color;
  DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT
    or DT_WORDBREAK or DT_END_ELLIPSIS, nil);
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
  FAttachment.Free;
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

procedure TCnChatItem.NotifyFontChanged;
begin

end;

procedure TCnChatItem.NotifyHide;
begin

end;

{ TCnChatMessage }

function TCnChatMessage.CalcRect(Canvas: TCanvas; Rect: TRect): TRect;
var
  R: TRect;
  S: string;
  DefaultCalc: Boolean;
begin
  if FNeedCalc then
  begin
    Result := Rect;
    R := Rect;
    S := Text;

    if FOwner.Owner <> nil then
      Canvas.Font := FOwner.Owner.Font
    else
      Canvas.Font.Size := FONT_DEF_SIZE;

    // �����һ������ Rect ��ߵĻ���
    DefaultCalc := True;
    if (FOwner.Owner <> nil) and Assigned(FOwner.Owner.OnGetItemTextRect) then
      FOwner.Owner.OnGetItemTextRect(FOwner.Owner, Self, Canvas, R, DefaultCalc);

    // ������Ҫ��Ĭ�ϼ������Լ���
    if DefaultCalc then
    begin
      // ������ʼ���Σ���ͨ��ģ����ƣ�������������ֵ��Ű��߸�ؾ�����
      Canvas.Font.Style := [];
      DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT or DT_CALCRECT
        or DT_WORDBREAK or DT_END_ELLIPSIS, nil);
    end;

    // ��Ľ���ȷ� Result���ճ� R
    // ע������������ȣ����� Memo ����ʱ��������δ֪ Padding ��ɹ�խ������
    CnSetRectWidth(Result, CnGetRectWidth(R) + 10);
    CnSetRectHeight(Result, CnGetRectHeight(R));

    // ���Ҫ��ʾ��������֣���ѼӴֵ����������ٻ�һ���򣬸ߺ�����Ŀ�ƴ����������ѡ��ġ�
    if (FromType = cmtYou) and FShowFrom then
    begin
      R := Rect;
      S := From;
      if FOwner.Owner <> nil then
        Canvas.Font.Name := FOwner.Owner.Font.Name;
      Canvas.Font.Size := FONT_SENDER_SIZE;
      Canvas.Font.Style := [fsBold];
      DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT or DT_CALCRECT
        or DT_SINGLELINE or DT_END_ELLIPSIS, nil);

      CnSetRectWidth(Result, Max(CnGetRectWidth(Result), CnGetRectWidth(R)));
      CnSetRectHeight(Result, CnGetRectHeight(Result) + CnGetRectHeight(R));

      FCalcedFromHeight := CnGetRectHeight(R);
      // ������¼�����ߵĸ߶�
    end
    else
      FCalcedFromHeight := 0;

    FCalcedRect := Result;
    FNeedCalc := False;
  end
  else
    Result := FCalcedRect;
end;

procedure TCnChatMessage.DrawRect(Canvas: TCanvas; Rect: TRect);
var
  R: TRect;
  S: string;
  DefaultDraw: Boolean;
begin
  if (FromType = cmtYou) and FShowFrom then
  begin
    // ���Է����֣��Ӵ�
    S := From;
    R := Rect;

    if FOwner.Owner <> nil then
      Canvas.Font := FOwner.Owner.Font;
    Canvas.Font.Size := FONT_SENDER_SIZE;
    Canvas.Font.Style := [fsBold];

    if Selected then
      Canvas.Font.Color := FromColorSelect
    else
      Canvas.Font.Color := FromColor;

    DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT
      or DT_SINGLELINE or DT_END_ELLIPSIS, nil);

    Canvas.Font.Style := [];
  end;

  R := Rect;
  if (FromType = cmtYou) and FShowFrom then
    Inc(R.Top, FCalcedFromHeight);

  // �����������ݲ���ʾ
  if FOwner.Owner <> nil then
    Canvas.Font := FOwner.Owner.Font
  else
    Canvas.Font.Size := FONT_DEF_SIZE;

  Canvas.Font.Style := [];
  Canvas.Font.Color := Color;

  // �����һ�����ƵĻ���
  DefaultDraw := True;
  if (FOwner.Owner <> nil) and Assigned(FOwner.Owner.OnDrawItemText) then
    FOwner.Owner.OnDrawItemText(FOwner.Owner, Self, Canvas, R, DefaultDraw);

  // ������Ҫ��Ĭ�ϻ������Լ�����
  if DefaultDraw then
  begin
    CheckMemo;
    FMemo.Lines.Text := Text;
    if (FMemo.Left <> R.Left) or (FMemo.Top <> R.Top) or (FMemo.Width <> R.Right - R.Left)
      or (FMemo.Height <> R.Bottom - R.Top) then
      FMemo.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
    HideCaret(FMemo.Handle);

    if FromType = cmtYou then
      FMemo.Color := FOwner.Owner.ColorYou
    else
      FMemo.Color := FOwner.Owner.ColorMe;

    if not FMemo.Visible then
      FMemo.Visible := True;
  end
  else
  begin
    if FMemo <> nil then
      FMemo.Visible := False;
  end;
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
  FromColorSelect := clNavy;
end;

destructor TCnChatMessage.Destroy;
begin
  FMemo.Free;
  inherited;
end;

procedure TCnChatMessage.SelectNone;
begin
  CheckMemo;
  FMemo.SelLength := 0;
end;

function TCnChatMessage.GetSelText: string;
begin
  CheckMemo;
  Result := FMemo.SelText;
end;

procedure TCnChatMessage.CheckMemo;
begin
  if FMemo = nil then
  begin
    FMemo := TMemo.Create(nil);
    FMemo.Visible := False;
    FMemo.BorderStyle := bsNone;
    FMemo.WordWrap := True;
    FMemo.ReadOnly := True;

{$IFDEF IDE_SUPPORT_THEMING}
    FMemo.StyleElements := [];
{$ENDIF}
  end;

  if FOwner.Owner <> nil then
  begin
    if FMemo.Parent <> FOwner.Owner then
    begin
      FMemo.Parent := FOwner.Owner;
      FMemo.Font := FOwner.Owner.Font;
    end;

    if FOwner.Owner.PopupMenu <> nil then
      FMemo.PopupMenu := FOwner.Owner.PopupMenu;
  end;
end;

function TCnChatMessage.GetSelEnd: Integer;
begin
  CheckMemo;
  Result := FMemo.SelStart + FMemo.SelLength;
end;

function TCnChatMessage.GetSelStart: Integer;
begin
  CheckMemo;
  Result := FMemo.SelStart;
end;

procedure TCnChatMessage.NotifyFontChanged;
begin
  if (FMemo <> nil) and (FOwner.Owner <> nil) then
    FMemo.Font := FOwner.Owner.Font;
end;

procedure TCnChatMessage.NotifyHide;
begin
  if FMemo <> nil then
    FMemo.Visible := False;
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
    if FOwner.Owner <> nil then
      Canvas.Font := FOwner.Owner.Font
    else
      Canvas.Font.Size := FONT_DEF_SIZE;

    Canvas.Font.Style := [fsBold];
    DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT or DT_CALCRECT
      or DT_WORDBREAK or DT_END_ELLIPSIS, nil);

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

procedure TCnChatInfo.DrawRect(Canvas: TCanvas; Rect: TRect);
var
  R: TRect;
  S: string;
begin
  R := Rect;
  S := Text;
  if FOwner.Owner <> nil then
    Canvas.Font := FOwner.Owner.Font
  else
    Canvas.Font.Size := FONT_DEF_SIZE;

  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := Color;
  DrawTextEx(Canvas.Handle, PChar(S), Length(S), R, DT_LEFT
    or DT_WORDBREAK or DT_END_ELLIPSIS, nil);
end;

procedure TCnChatInfo.SetFillColor(const Value: TColor);
begin
  FFillColor := Value;
end;

end.

