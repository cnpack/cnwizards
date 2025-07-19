{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit CnHotKey;
{* |<PRE>
================================================================================
* 软件名称：CnPack 专家包
* 单元名称：THotKey 移植实现类
* 单元作者：CnPack 开发组
* 备    注：该单元移植自 Delphi 5，替代解决Lazarus下没有THotKey控件的问题。
* 开发平台：Win7 + Lazarus 4.0
* 兼容测试：暂无
* 本 地 化：暂无
* 修改记录：2025.07.19 V1.0
*               移植单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Messages, Windows, SysUtils, Classes, Controls, Forms, LCLType,
  Menus, Graphics, StdCtrls, ToolWin, CommCtrl;

type
  THKModifier = (hkShift, hkCtrl, hkAlt, hkExt);
  THKModifiers = set of THKModifier;
  THKInvalidKey = (hcNone, hcShift, hcCtrl, hcAlt, hcShiftCtrl,
    hcShiftAlt, hcCtrlAlt, hcShiftCtrlAlt);
  THKInvalidKeys = set of THKInvalidKey;

  TCustomHotKey = class(TWinControl)
  private
    FAutoSize: Boolean;
    FModifiers: THKModifiers;
    FInvalidKeys: THKInvalidKeys;
    FHotKey: Word;
    procedure AdjustHeight;
    procedure SetAutoSize(Value: Boolean);
    procedure SetInvalidKeys(Value: THKInvalidKeys);
    procedure SetModifiers(Value: THKModifiers);
    procedure UpdateHeight;
    function GetHotKey: TShortCut;
    procedure SetHotKey(Value: TShortCut);
    procedure ShortCutToHotKey(Value: TShortCut);
    function HotKeyToShortCut(Value: Longint): TShortCut;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property InvalidKeys: THKInvalidKeys read FInvalidKeys write SetInvalidKeys;
    property Modifiers: THKModifiers read FModifiers write SetModifiers;
    property HotKey: TShortCut read GetHotKey write SetHotKey;
    property TabStop default True;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  THotKey = class(TCustomHotKey)
  published
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property Constraints;
    property Enabled;
    property Hint;
    property HotKey;
    property InvalidKeys;
    property Modifiers;
    property ParentBiDiMode;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;
  
implementation

function InitCommonControl(CC: Integer): Boolean;
var
  ICC: TInitCommonControlsEx;
begin
  ICC.dwSize := SizeOf(TInitCommonControlsEx);
  ICC.dwICC := CC;
  Result := InitCommonControlsEx(ICC);
  if not Result then InitCommonControls;
end;

constructor TCustomHotKey.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 121;
  Height := 25;
  TabStop := True;
  ParentColor := False;
  FAutoSize := True;
  FInvalidKeys := [hcNone, hcShift];
  FModifiers := [hkAlt];
  FHotKey := $0041;     // default - 'Alt+A'
  AdjustHeight;
end;

procedure TCustomHotKey.CreateParams(var Params: TCreateParams);
begin
  InitCommonControl(ICC_HOTKEY_CLASS);
  inherited CreateParams(Params);
  CreateSubClass(Params, HOTKEYCLASS);
  with Params.WindowClass do
    style := style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TCustomHotKey.CreateWnd;
begin
  inherited CreateWnd;
  SendMessage(Handle, HKM_SETRULES, Byte(FInvalidKeys), MakeLong(Byte(FModifiers), 0));
  SendMessage(Handle, HKM_SETHOTKEY, MakeWord(Byte(FHotKey), Byte(FModifiers)), 0);
end;

procedure TCustomHotKey.SetAutoSize(Value: Boolean);
begin
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    UpdateHeight;
  end;
end;

procedure TCustomHotKey.SetModifiers(Value: THKModifiers);
begin
  if Value <> FModifiers then
  begin
    FModifiers := Value;
    SendMessage(Handle, HKM_SETRULES, Byte(FInvalidKeys), MakeLong(Byte(Value), 0));
    SendMessage(Handle, HKM_SETHOTKEY, MakeWord(Byte(FHotKey), Byte(FModifiers)), 0);
  end;
end;

procedure TCustomHotKey.SetInvalidKeys(Value: THKInvalidKeys);
begin
  if Value <> FInvalidKeys then
  begin
    FInvalidKeys := Value;
    SendMessage(Handle, HKM_SETRULES, Byte(Value), MakeLong(Byte(FModifiers), 0));
    SendMessage(Handle, HKM_SETHOTKEY, MakeWord(Byte(FHotKey), Byte(FModifiers)), 0);
  end;
end;

function TCustomHotKey.GetHotKey: TShortCut;
var
  HK: Longint;
begin
  HK := SendMessage(Handle, HKM_GETHOTKEY, 0, 0);
  Result := HotKeyToShortCut(HK);
end;

procedure TCustomHotKey.SetHotKey(Value: TShortCut);
begin
  ShortCutToHotKey(Value);
  SendMessage(Handle, HKM_SETHOTKEY, MakeWord(Byte(FHotKey), Byte(FModifiers)), 0);
end;

procedure TCustomHotKey.UpdateHeight;
begin
  if AutoSize then
  begin
    ControlStyle := ControlStyle + [csFixedHeight];
    AdjustHeight;
  end else
    ControlStyle := ControlStyle - [csFixedHeight];
end;

procedure TCustomHotKey.AdjustHeight;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
{$IFDEF FPC}
  SysMetrics, Metrics: Windows.TTextMetric;
{$ELSE}
  SysMetrics, Metrics: TTextMetric;
{$ENDIF}
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  if NewStyleControls then
  begin
    // if Ctl3D then I := 8 else I := 6;
    I := GetSystemMetrics(SM_CYBORDER) * 8;
  end
  else
  begin
    I := SysMetrics.tmHeight;
    if I > Metrics.tmHeight then I := Metrics.tmHeight;
    I := I div 4 + GetSystemMetrics(SM_CYBORDER) * 4;
  end;
  Height := Metrics.tmHeight + I;
end;

procedure TCustomHotKey.ShortCutToHotKey(Value: TShortCut);
begin
  FHotKey := Value and not (scShift + scCtrl + scAlt);
  FModifiers := [];
  if Value and scShift <> 0 then Include(FModifiers, hkShift);
  if Value and scCtrl <> 0 then Include(FModifiers, hkCtrl);
  if Value and scAlt <> 0 then Include(FModifiers, hkAlt);
end;

function TCustomHotKey.HotKeyToShortCut(Value: Longint): TShortCut;
begin
  Byte(FModifiers) := LoWord(HiByte(Value));
  FHotKey := LoWord(LoByte(Value));
  Result := FHotKey;
  if hkShift in FModifiers then Inc(Result, scShift);
  if hkCtrl in FModifiers then Inc(Result, scCtrl);
  if hkAlt in FModifiers then Inc(Result, scAlt);
end;

end.
