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

unit CnWideCtrls;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�ʹ�� WideString ����ʾ Unicode �� Labelʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��ʹ�� WideString ����ʾ Unicode �� Labelʵ�ֵ�Ԫ
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2017.05.16 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils,  Classes, Graphics, Controls, Forms,
  StdCtrls {$IFDEF COMPILER7_UP}, Themes{$ENDIF};

type
  TCnWideControl = class(TControl)
  private
    FHint: WideString;
    FText: PWideChar;
    function GetText: WideString;
    procedure SetText(const Value: WideString);
    function IsCaptionStored: Boolean;
  protected
    property Text: WideString read GetText write SetText;
    property Caption: WideString read GetText write SetText stored IsCaptionStored;
  public
    procedure DefaultHandler(var Message); override;
    procedure SetTextBuf(Buffer: PWideChar);
    function GetTextBuf(Buffer: PWideChar; BufSize: Integer): Integer;
    function GetTextLen: Integer;
    {* �����ַ���}

    property WindowText: PWideChar read FText write FText;
    property Hint: WideString read FHint write FHint;
  end;

  TCnWideGraphicControl = class(TCnWideControl)
  private
    FCanvas: TCanvas;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  protected
    procedure Paint; virtual;
    property Canvas: TCanvas read FCanvas;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TCnWideLabel = class(TCnWideGraphicControl)
  private
    FFocusControl: TWinControl;
    FAlignment: TAlignment;
    FAutoSize: Boolean;
    FLayout: TTextLayout;
    FWordWrap: Boolean;
    FShowAccelChar: Boolean;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FTransparentSet: Boolean;
    function GetTransparent: Boolean;
    procedure SetAlignment(Value: TAlignment);
    procedure SetFocusControl(Value: TWinControl);
    procedure SetShowAccelChar(Value: Boolean);
    procedure SetTransparent(Value: Boolean);
    procedure SetLayout(Value: TTextLayout);
    procedure SetWordWrap(Value: Boolean);
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure AdjustBounds; dynamic;
    procedure DoDrawText(var Rect: TRect; Flags: Longint); dynamic;
    function GetLabelText: WideString; virtual;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Paint; override;
    procedure SetAutoSize(Value: Boolean);{$IFDEF COMPILER6_UP} override {$ELSE} virtual {$ENDIF};
  public
    constructor Create(AOwner: TComponent); override;
    property Canvas;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment
      default taLeftJustify;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property FocusControl: TWinControl read FFocusControl write SetFocusControl;
    property ShowAccelChar: Boolean read FShowAccelChar write SetShowAccelChar default True;
    property Transparent: Boolean read GetTransparent write SetTransparent stored FTransparentSet;
    property Layout: TTextLayout read FLayout write SetLayout default tlTop;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;

    property Align;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Color nodefault;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

type
  THackControlActionLink = class(TControlActionLink);

{ TCnWideControl }

procedure TCnWideControl.DefaultHandler(var Message);
var
  P: PWideChar;
  L: Integer;
begin
  with TMessage(Message) do
    case Msg of
      WM_GETTEXT:
        begin
          if FText <> nil then
            P := FText
          else
            P := '';
          Result := lstrlenW(lstrcpynW(PWideChar(LParam), P, WParam));
        end;
      WM_GETTEXTLENGTH:
        if FText = nil then Result := 0 else Result := lstrlenW(FText);
      WM_SETTEXT:
        begin
          FreeMem(FText);
          L := lstrlenW(PWideChar(LParam));
          if L > 0 then
          begin
            GetMem(P, (L + 1) * SizeOf(WideChar));
            lstrcpynW(P, PWideChar(LParam), L + 1);
          end
          else
            P := nil;
          FText := P;
{$IFNDEF FPC}
          SendDockNotification(Msg, WParam, LParam);
{$ENDIF}
        end;
    end;
end;

function TCnWideControl.GetText: WideString;
var
  Len: Integer;
begin
  Len := GetTextLen;
  SetLength(Result, Len);

  if Len <> 0 then
  begin
    Len := Len - GetTextBuf(PWideChar(Result), Len + 1);
    if Len > 0 then
      SetLength(Result, Length(Result) - Len);
  end;
end;

function TCnWideControl.GetTextBuf(Buffer: PWideChar;
  BufSize: Integer): Integer;
begin
{$IFDEF WIN64}
  Result := Perform(WM_GETTEXT, BufSize, NativeInt(Buffer));
{$ELSE}
  Result := Perform(WM_GETTEXT, BufSize, Longint(Buffer));
{$ENDIF}
end;

function TCnWideControl.GetTextLen: Integer;
begin
  Result := Perform(WM_GETTEXTLENGTH, 0, 0);
end;

function TCnWideControl.IsCaptionStored: Boolean;
begin
  Result := (ActionLink = nil) or not
    THackControlActionLink(ActionLink).IsCaptionLinked;
end;

procedure TCnWideControl.SetText(const Value: WideString);
begin
  if GetText <> Value then
    SetTextBuf(PWideChar(Value));
end;

procedure TCnWideControl.SetTextBuf(Buffer: PWideChar);
begin
{$IFDEF WIN64}
  Perform(WM_SETTEXT, 0, NativeInt(Buffer));
{$ELSE}
  Perform(WM_SETTEXT, 0, Longint(Buffer));
{$ENDIF}
  Perform(CM_TEXTCHANGED, 0, 0);
end;

{ TCnWideGraphicControl }

constructor TCnWideGraphicControl.Create(AOwner: TComponent);
begin
  inherited;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
end;

destructor TCnWideGraphicControl.Destroy;
begin
  if GetCaptureControl = Self then
    SetCaptureControl(nil);
  FCanvas.Free;
  inherited;
end;

procedure TCnWideGraphicControl.WMPaint(var Message: TWMPaint);
begin
  if Message.DC <> 0 then
  begin
    Canvas.Lock;
    try
      Canvas.Handle := Message.DC;
      try
        Paint;
      finally
        Canvas.Handle := 0;
      end;
    finally
      Canvas.Unlock;
    end;
  end;
end;

procedure TCnWideGraphicControl.Paint;
begin

end;

constructor TCnWideLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 80;
  Height := 21;
  FAutoSize := True;
  FShowAccelChar := True;

{$IFDEF COMPILER7_UP}
  if ThemeServices.ThemesEnabled then
    ControlStyle := ControlStyle - [csOpaque]
  else
    ControlStyle := ControlStyle + [csOpaque];
{$ENDIF}
end;

function TCnWideLabel.GetLabelText: WideString;
begin
  Result := Caption;
end;

procedure TCnWideLabel.DoDrawText(var Rect: TRect; Flags: Longint);
var
  Text: WideString;
begin
  Text := GetLabelText;
  if (Flags and DT_CALCRECT <> 0) and ((Text = '') or FShowAccelChar and
    (Text[1] = '&') and (Text[2] = #0)) then Text := Text + ' ';
  if not FShowAccelChar then Flags := Flags or DT_NOPREFIX;
{$IFNDEF FPC}
  Flags := DrawTextBiDiModeFlags(Flags);
{$ENDIF}
  Canvas.Font := Font;
  if not Enabled then
  begin
    OffsetRect(Rect, 1, 1);
    Canvas.Font.Color := clBtnHighlight;
    DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text), Rect, Flags);
    OffsetRect(Rect, -1, -1);
    Canvas.Font.Color := clBtnShadow;
    DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text), Rect, Flags);
  end
  else
    DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text), Rect, Flags);
end;

procedure TCnWideLabel.Paint;
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
  WordWraps: array[Boolean] of Word = (0, DT_WORDBREAK);
var
  Rect, CalcRect: TRect;
  DrawStyle: Longint;
begin
  with Canvas do
  begin
    if not Transparent then
    begin
      Brush.Color := Self.Color;
      Brush.Style := bsSolid;
      FillRect(ClientRect);
    end;
    Brush.Style := bsClear;
    Rect := ClientRect;
    { DoDrawText takes care of BiDi alignments }
    DrawStyle := DT_EXPANDTABS or WordWraps[FWordWrap] or Alignments[FAlignment];
    { Calculate vertical layout }
    if FLayout <> tlTop then
    begin
      CalcRect := Rect;
      DoDrawText(CalcRect, DrawStyle or DT_CALCRECT);
      if FLayout = tlBottom then OffsetRect(Rect, 0, Height - CalcRect.Bottom)
      else OffsetRect(Rect, 0, (Height - CalcRect.Bottom) div 2);
    end;
    DoDrawText(Rect, DrawStyle);
  end;
end;

procedure TCnWideLabel.Loaded;
begin
  inherited Loaded;
  AdjustBounds;
end;

procedure TCnWideLabel.AdjustBounds;
const
  WordWraps: array[Boolean] of Word = (0, DT_WORDBREAK);
var
  DC: HDC;
  X: Integer;
  Rect: TRect;
  AAlignment: TAlignment;
begin
  if not (csReading in ComponentState) and FAutoSize then
  begin
    Rect := ClientRect;
    DC := GetDC(0);
    Canvas.Handle := DC;
    DoDrawText(Rect, (DT_EXPANDTABS or DT_CALCRECT) or WordWraps[FWordWrap]);
    Canvas.Handle := 0;
    ReleaseDC(0, DC);
    X := Left;
    AAlignment := FAlignment;
    if UseRightToLeftAlignment then ChangeBiDiModeAlignment(AAlignment);
    if AAlignment = taRightJustify then Inc(X, Width - Rect.Right);
    SetBounds(X, Top, Rect.Right, Rect.Bottom);
  end;
end;

procedure TCnWideLabel.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Invalidate;
  end;
end;

procedure TCnWideLabel.SetAutoSize(Value: Boolean);
begin
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    AdjustBounds;
  end;
end;

function TCnWideLabel.GetTransparent: Boolean;
begin
  Result := not (csOpaque in ControlStyle);
end;

procedure TCnWideLabel.SetFocusControl(Value: TWinControl);
begin
  FFocusControl := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

procedure TCnWideLabel.SetShowAccelChar(Value: Boolean);
begin
  if FShowAccelChar <> Value then
  begin
    FShowAccelChar := Value;
    Invalidate;
  end;
end;

procedure TCnWideLabel.SetTransparent(Value: Boolean);
begin
  if Transparent <> Value then
  begin
    if Value then
      ControlStyle := ControlStyle - [csOpaque] 
    else
      ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
  FTransparentSet := True;
end;

procedure TCnWideLabel.SetLayout(Value: TTextLayout);
begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Invalidate;
  end;
end;

procedure TCnWideLabel.SetWordWrap(Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    AdjustBounds;
    Invalidate;
  end;
end;

procedure TCnWideLabel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFocusControl) then
    FFocusControl := nil;
end;

procedure TCnWideLabel.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
  AdjustBounds;
end;

procedure TCnWideLabel.CMFontChanged(var Message: TMessage);
begin
  inherited;
  AdjustBounds;
end;

procedure TCnWideLabel.CMDialogChar(var Message: TCMDialogChar);
begin
  if (FFocusControl <> nil) and Enabled and ShowAccelChar and
    IsAccel(Message.CharCode, Caption) then
    with FFocusControl do
      if CanFocus then
      begin
        SetFocus;
        Message.Result := 1;
      end;
end;

procedure TCnWideLabel.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TCnWideLabel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

end.
