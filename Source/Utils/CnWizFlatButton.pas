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

unit CnWizFlatButton;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE 相关公共单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：浮动工具按钮窗体单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2021.07.26 V1.2
*               增加半透明的支持，但不太有效
*           2018.07.30 V1.1
*               增加显示色块的功能
*           2005.01.06 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Graphics, Classes, Controls, ExtCtrls, Forms,
  Menus, CnPopupMenu, CnGraphics, CnWizIdeUtils;

type
  TFlatButtonState = (bsHide, bsNormal, bsEnter, bsDropdown);
                   // 不显示、显示、鼠标移入、点击下拉

  TCnWizFlatButton = class(TCustomControl)
  private
    FDropdownMenu: TPopupMenu;
    FIcon: TIcon;
    FIsMouseEnter: Boolean;
    FIsDropdown: Boolean;
    FTimer: TTimer;
    FAutoDropdown: Boolean;
    FShowColor: Boolean;
    FDisplayColor: TColor;
    FAlpha: Boolean;
    procedure SetIcon(Value: TIcon);
    procedure ImageChange(Sender: TObject);
    procedure OnTimer(Sender: TObject);
    procedure SetIsDropdown(const Value: Boolean);
    procedure SetIsMouseEnter(const Value: Boolean);
    procedure SetDisplayColor(const Value: TColor);
    procedure SetShowColor(const Value: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure Click; override;
    procedure Paint; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure UpdateSize;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetState: TFlatButtonState;
    {* 返回当前按钮的状态 }
    procedure Dropdown;
    {* 下拉出菜单 }

    property DropdownMenu: TPopupMenu read FDropdownMenu write FDropdownMenu;
    {* 下拉菜单，需要由用户自己创建及设置 }
    property Icon: TIcon read FIcon write SetIcon;
    {* 按钮图标，需要由用户自己创建及设置，此处只是引用 }
    property AutoDropdown: Boolean read FAutoDropdown write FAutoDropdown;
    {* 是否鼠标移入后自动下拉}
    property ShowColor: Boolean read FShowColor write SetShowColor;
    {* 是否显示颜色区域}
    property DisplayColor: TColor read FDisplayColor write SetDisplayColor;
    {* 颜色区域的显示颜色}
    property Alpha: Boolean read FAlpha write FAlpha;
    {* 是否半透明绘制}

    property IsDropdown: Boolean read FIsDropdown write SetIsDropdown;
    property IsMouseEnter: Boolean read FIsMouseEnter write SetIsMouseEnter;
  end;

implementation

const
  csImageWidth = 16;
  csImageHeight = 16;
  csBorderWidths: array[TFlatButtonState] of Integer = (2, 2, 3, 3);
  csArrowWidths: array[TFlatButtonState] of Integer = (0, 0, 8, 8);
  csBkColors: array[TFlatButtonState] of TColor =
    (clWhite, clWhite, $00D2BDB6, $00D1D8DB);
  csBorderColors: array[TFlatButtonState] of TColor =
    ($006A240A, $006A240A, $006A240A, $666666);
  csArrowColor = clBlack;
  csColorWidth = 10;
  csColorUpdownMargin = 5;
  csColorRightMargin = 4;
  csColorLeftMargin = 2;

{ TCnWizFlatButton }

constructor TCnWizFlatButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Visible := False;
  ShowHint := True;
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := 500;
  FTimer.OnTimer := OnTimer;

  UpdateSize;
end;

destructor TCnWizFlatButton.Destroy;
begin

  inherited;
end;

procedure TCnWizFlatButton.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_TOPMOST;
end;

function TCnWizFlatButton.GetState: TFlatButtonState;
begin
  if not Visible then
    Result := bsHide
  else if IsDropdown then
    Result := bsDropdown
  else if IsMouseEnter then
    Result := bsEnter
  else
    Result := bsNormal;
end;

//------------------------------------------------------------------------------
// 消息及事件处理
//------------------------------------------------------------------------------

procedure TCnWizFlatButton.Click;
begin
  inherited;
  Dropdown;
end;

procedure TCnWizFlatButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    Dropdown;
end;

procedure TCnWizFlatButton.CMMouseEnter(var Message: TMessage);
begin
  IsMouseEnter := True;
end;

procedure TCnWizFlatButton.CMMouseLeave(var Message: TMessage);
begin
  IsMouseEnter := False;
end;

procedure TCnWizFlatButton.Paint;
const
  csAlphaValue = 160;
type
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array [Byte] of TRGBTriple;
var
  Rc: TRect;
  OldColor: TColor;
  X, Y: Integer;
  State: TFlatButtonState;
  Bmp: TBitmap;
  R, B, G: Byte;
  AAlpha: DWORD;
  PRGB: PRGBTripleArray;
begin
  State := GetState;
  with Canvas do
  begin
    if FAlpha then
    begin
      // 画半透明的复制来的背景并与前景色混合
      Bmp := TBitmap.Create;
      try
        Bmp.PixelFormat := pf24bit;
        Bmp.Width := Width;
        Bmp.Height := Height;

        CopyControlParentImageToCanvas(Self, Bmp.Canvas);

        // 半透明混合色
        R := GetRValue(csBkColors[State]);                // 色彩分量
        G := GetGValue(csBkColors[State]);
        B := GetBValue(csBkColors[State]);
        AAlpha := csAlphaValue;       // 规定一个前景透明度运算系数（0 到 256 范围）

        for Y := 0 to Bmp.Height - 1 do
        begin
          PRGB := Bmp.ScanLine[Y];
          for X := 0 to Bmp.Width - 1 do
          begin
            // 混合
            Inc(PRGB^[X].rgbtBlue, AAlpha * (B - PRGB^[X].rgbtBlue) shr 8);
            Inc(PRGB^[X].rgbtGreen, AAlpha * (G - PRGB^[X].rgbtGreen) shr 8);
            Inc(PRGB^[X].rgbtRed, AAlpha * (R - PRGB^[X].rgbtRed) shr 8);
          end;
        end;

        // Bmp 上画边框与图标
        Bmp.Canvas.Brush.Color := csBorderColors[State];
        Bmp.Canvas.FrameRect(ClientRect);
        Bmp.Canvas.Brush.Style := bsClear;
        if (FIcon <> nil) and not FIcon.Empty then
        begin
{$IFDEF IDE_SUPPORT_HDPI}
          DrawIconEx(Bmp.Canvas.Handle, csBorderWidths[State], csBorderWidths[State],
            FIcon.Handle, IdeGetScaledPixelsFromOrigin(FIcon.Width, Self),
            IdeGetScaledPixelsFromOrigin(FIcon.Height, Self), 0, 0, DI_NORMAL);
{$ELSE}
          Bmp.Canvas.Draw(csBorderWidths[State], csBorderWidths[State], FIcon);
{$ENDIF}
        end;
        BitBlt(Handle, 0, 0, Width, Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
      finally
        Bmp.Free;
      end;
    end
    else
    begin
      // 先自己画个不透明背景
      Brush.Color := csBkColors[State];
      FillRect(ClientRect);

      // 自己画边框与图标
      Brush.Color := csBorderColors[State];
      FrameRect(ClientRect);
      if (FIcon <> nil) and not FIcon.Empty then
      begin
{$IFDEF IDE_SUPPORT_HDPI}
        DrawIconEx(Handle, csBorderWidths[State], csBorderWidths[State],
          FIcon.Handle, IdeGetScaledPixelsFromOrigin(FIcon.Width, Self),
          IdeGetScaledPixelsFromOrigin(FIcon.Height, Self), 0, 0, DI_NORMAL);
{$ELSE}
        Draw(csBorderWidths[State], csBorderWidths[State], FIcon);
{$ENDIF}
      end;
    end;

    // 画小色块
    if FShowColor and (State in [bsHide, bsNormal]) then
    begin
      Rc.Left := Width - csBorderWidths[State] - (csArrowWidths[State] div 2) -
        IdeGetScaledPixelsFromOrigin(csColorWidth, Self) +
        IdeGetScaledPixelsFromOrigin(csColorLeftMargin, Self);
      Rc.Top := IdeGetScaledPixelsFromOrigin(csColorUpdownMargin, Self);
      Rc.Bottom := ClientRect.Bottom - IdeGetScaledPixelsFromOrigin(csColorUpdownMargin, Self);
      Rc.Right := Rc.Left + IdeGetScaledPixelsFromOrigin(csColorWidth, Self) -
        IdeGetScaledPixelsFromOrigin(csColorRightMargin, Self);

      OldColor := Brush.Color;
      Brush.Color := FDisplayColor;
      FillRect(Rc);
      Brush.Color := OldColor;
    end;

    // 画下拉箭头
    if csArrowWidths[State] > 0 then
    begin
      Pen.Color := csArrowColor;
      X := Width - IdeGetScaledPixelsFromOrigin(csBorderWidths[State] + csArrowWidths[State] div 2, Self);
      Y := Height div 2;
      MoveTo(X - IdeGetScaledPixelsFromOrigin(2, Self), Y - IdeGetScaledPixelsFromOrigin(1, Self));
      LineTo(X + IdeGetScaledPixelsFromOrigin(3, Self), Y - IdeGetScaledPixelsFromOrigin(1, Self));
      MoveTo(X - IdeGetScaledPixelsFromOrigin(1, Self), Y);
      LineTo(X + IdeGetScaledPixelsFromOrigin(2, Self), Y);
      Pixels[X, Y + IdeGetScaledPixelsFromOrigin(1, Self)] := csArrowColor;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 控件操作
//------------------------------------------------------------------------------

procedure TCnWizFlatButton.Dropdown;
var
  P: TPoint;
begin
  if not IsDropdown and Assigned(FDropdownMenu) then
  begin
    P := ClientToScreen(Point(0, Height));
    IsDropdown := True;
    FDropdownMenu.Popup(P.x, P.y);
    IsDropdown := False;
  end;
end;

//------------------------------------------------------------------------------
// 状态更新
//------------------------------------------------------------------------------

procedure TCnWizFlatButton.UpdateSize;
var
  State: TFlatButtonState;
begin
  State := GetState;
  Width := IdeGetScaledPixelsFromOrigin(csBorderWidths[State] * 2 + csArrowWidths[State], Self)
    + IdeGetScaledPixelsFromOrigin(csImageWidth, Self);
  if FShowColor and (State in [bsHide, bsNormal]) then
    Width := Width + IdeGetScaledPixelsFromOrigin(csColorWidth, Self);
  Height := IdeGetScaledPixelsFromOrigin(csBorderWidths[State] * 2, Self)
    + IdeGetScaledPixelsFromOrigin(csImageHeight, Self);

  if Visible then
    Repaint;
end;

procedure TCnWizFlatButton.ImageChange(Sender: TObject);
begin
  UpdateSize;
end;

procedure TCnWizFlatButton.OnTimer(Sender: TObject);
var
  P: TPoint;
begin
  if IsMouseEnter and GetCursorPos(P) then
  begin
    if not PtInRect(ClientRect, ScreenToClient(P)) then
    begin
      IsMouseEnter := False;
    end
    else if FAutoDropdown then
      Dropdown;
  end;
end;

//------------------------------------------------------------------------------
// 属性读写
//------------------------------------------------------------------------------

procedure TCnWizFlatButton.SetIcon(Value: TIcon);
begin
  if FIcon <> Value then
  begin
    FIcon := Value;
    if FIcon <> nil then
      FIcon.OnChange := ImageChange;
    UpdateSize;
  end;
end;

procedure TCnWizFlatButton.SetIsDropdown(const Value: Boolean);
begin
  if FIsDropdown <> Value then
  begin
    FIsDropdown := Value;
    UpdateSize;
  end;
end;

procedure TCnWizFlatButton.SetIsMouseEnter(const Value: Boolean);
begin
  if FIsMouseEnter <> Value then
  begin
    FIsMouseEnter := Value;
    UpdateSize;
    FTimer.Enabled := IsMouseEnter;
  end;
end;

procedure TCnWizFlatButton.CMHintShow(var Message: TMessage);
begin
  if FAutoDropdown then // 自动下拉时，移动 Hint 防止遮住窗口
    Dec(TCMHintShow(Message).HintInfo^.HintPos.y, Height * 2 + 10);

  Message.Result := 0; // 不处理
end;

procedure TCnWizFlatButton.SetDisplayColor(const Value: TColor);
begin
  if FDisplayColor <> Value then
  begin
    FDisplayColor := Value;
    UpdateSize;
    if Visible then
      Repaint;
  end;
end;

procedure TCnWizFlatButton.SetShowColor(const Value: Boolean);
begin
  if FShowColor <> Value then
  begin
    FShowColor := Value;
    UpdateSize;
    if Visible then
      Repaint;
  end;
end;

end.
