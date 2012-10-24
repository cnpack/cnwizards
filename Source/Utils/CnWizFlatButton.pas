{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2012 CnPack 开发组                       }
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
* 单元标识：$Id$
* 修改记录：2005.01.06 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Graphics, Classes, Controls, ExtCtrls, Forms,
  Menus, CnPopupMenu;

type
  TFlatButtonState = (bsHide, bsNormal, bsEnter, bsDropdown);

  TCnWizFlatButton = class(TCustomControl)
  private
    FDropdownMenu: TPopupMenu;
    FImage: TGraphic;
    FIsMouseEnter: Boolean;
    FIsDropdown: Boolean;
    FTimer: TTimer;
    procedure SetImage(Value: TGraphic);
    procedure ImageChange(Sender: TObject);
    procedure OnTimer(Sender: TObject);
    procedure SetIsDropdown(const Value: Boolean);
    procedure SetIsMouseEnter(const Value: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
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
    property Image: TGraphic read FImage write SetImage;
    {* 按钮图标，需要由用户自己创建及设置 }
    property IsDropdown: Boolean read FIsDropdown write SetIsDropdown;
    property IsMouseEnter: Boolean read FIsMouseEnter write SetIsMouseEnter;
  end;

implementation

{$IFDEF Debug}
uses
  CnDebug;
{$ENDIF}

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
var
  X, Y: Integer;
  State: TFlatButtonState;
begin
  State := GetState;
  with Canvas do
  begin
    Brush.Color := csBkColors[State];
    FillRect(ClientRect);
    Brush.Color := csBorderColors[State];
    FrameRect(ClientRect);
    if (FImage <> nil) and not FImage.Empty then
      Draw(csBorderWidths[State], csBorderWidths[State], FImage);

    if csArrowWidths[State] > 0 then
    begin
      Pen.Color := csArrowColor;
      X := Width - csBorderWidths[State] - csArrowWidths[State] div 2;
      Y := Height div 2;
      MoveTo(X - 2, Y - 1);
      LineTo(X + 3, Y - 1);
      MoveTo(X - 1, Y);
      LineTo(X + 2, Y);
      Pixels[X, Y + 1] := csArrowColor;
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
  Width := csBorderWidths[State] * 2 + csArrowWidths[State] + csImageWidth;
  Height := csBorderWidths[State] * 2 + csImageHeight;
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
    end;
  end;
end;

//------------------------------------------------------------------------------
// 属性读写
//------------------------------------------------------------------------------

procedure TCnWizFlatButton.SetImage(Value: TGraphic);
begin
  if FImage <> Value then
  begin
    FImage := Value;
    if FImage <> nil then
      FImage.OnChange := ImageChange;
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

end.
