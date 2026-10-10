{******************************************************************************}
{                                                                              }
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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
* 备    注：该单元解决 Lazarus 下没有 THotKey 控件的问题。
* 开发平台：Win7 + Lazarus 4.0
* 兼容测试：暂无
* 本 地 化：暂无
* 修改记录：2025.07.26 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

{$IFDEF FPC}

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Windows, Messages, Menus;

type
  THKModifier = (hkShift, hkCtrl, hkAlt, hkExt);
  THKModifiers = set of THKModifier;
  THKInvalidKey = (hcNone, hcShift, hcCtrl, hcAlt, hcShiftCtrl,
    hcShiftAlt, hcCtrlAlt, hcShiftCtrlAlt);
  THKInvalidKeys = set of THKInvalidKey;

  THotKey = class(TCustomEdit)
  private
    FCapturing: Boolean;
    FVirtKey: Word;
    FModifiers: TShiftState;
    FOnChange: TNotifyEvent;
    FOriginalHotKey: TShortCut;
    FInvalidKeys: THKInvalidKeys;
    procedure UpdateDisplay;
    procedure StartCapture;
    procedure EndCapture(Cancel: Boolean);
    function GetHotKey: TShortCut;
    procedure SetHotKey(const Value: TShortCut);
    function ShiftStateToModifiers(Shift: TShiftState): TShiftState;
    function ModifiersToShiftState: TShiftState;
    function ShortCutToText(ShortCut: TShortCut): string;
    function VirtualKeyToString(VKey: Word): string;
    function GetModifiersText(Modifiers: TShiftState): string;
  protected
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure WndProc(var Message: TMessage); override;
    property VirtKey: Word read FVirtKey;
  published
    property HotKey: TShortCut read GetHotKey write SetHotKey;
    property InvalidKeys: THKInvalidKeys read FInvalidKeys write FInvalidKeys;
    property Modifiers: TShiftState read FModifiers write FModifiers;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnEnter;
    property OnExit;
    property Align;
    property Anchors;
    property BorderStyle;
    property Color;
    property Constraints;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

{$ENDIF FPC}

implementation

{$IFDEF FPC}

{ THotKey }

constructor THotKey.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ReadOnly := True;
  TabStop := True;
  Width := 120;
  Height := 21;
  FCapturing := False;
  FVirtKey := 0;
  FModifiers := [];
end;

procedure THotKey.DoEnter;
begin
  inherited DoEnter;
  if not FCapturing then
    StartCapture;
end;

procedure THotKey.DoExit;
begin
  inherited DoExit;
  if FCapturing then
    EndCapture(True); // Cancel on exit
end;

procedure THotKey.StartCapture;
begin
  FCapturing := True;
  FOriginalHotKey := GetHotKey;
  FVirtKey := 0;
  FModifiers := [];
  // Text := '';
  // Color := TColor($80FFFF);
end;

procedure THotKey.EndCapture(Cancel: Boolean);
begin
  if not FCapturing then Exit;

  FCapturing := False;
  // Color := clWindow;

  if Cancel then
    SetHotKey(FOriginalHotKey)
  else
  begin
    UpdateDisplay;
    // 确认热键后通知值已改变，供外部即时打印或保存
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

function THotKey.GetHotKey: TShortCut;
begin
  Result := Menus.ShortCut(FVirtKey, ModifiersToShiftState);
end;

procedure THotKey.SetHotKey(const Value: TShortCut);
var
  Key: Word;
  Shift: TShiftState;
begin
  Menus.ShortCutToKey(Value, Key, Shift);
  FVirtKey := Key;
  FModifiers := ShiftStateToModifiers(Shift);
  UpdateDisplay;

  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure THotKey.UpdateDisplay;
begin
  if FCapturing then
  begin
    // 捕获模式下的特殊显示
    if FVirtKey = 0 then
    begin
      // 只有修饰键没有主键时
      if FModifiers <> [] then
        Text := GetModifiersText(FModifiers) + '+'
      else
        Text := '';
    end
    else
      Text := ShortCutToText(GetHotKey);
  end
  else
  begin
    // 非捕获模式下的显示
    if FVirtKey = 0 then
      Text := ''
    else
      Text := ShortCutToText(GetHotKey);
  end;
end;

function THotKey.ModifiersToShiftState: TShiftState;
begin
  Result := [];
  if ssCtrl in FModifiers then Include(Result, ssCtrl);
  if ssAlt in FModifiers then Include(Result, ssAlt);
  if ssShift in FModifiers then Include(Result, ssShift);
end;

function THotKey.ShiftStateToModifiers(Shift: TShiftState): TShiftState;
begin
  Result := [];
  if ssCtrl in Shift then Include(Result, ssCtrl);
  if ssAlt in Shift then Include(Result, ssAlt);
  if ssShift in Shift then Include(Result, ssShift);
end;

function THotKey.GetModifiersText(Modifiers: TShiftState): string;
begin
  Result := '';
  if ssCtrl in Modifiers then Result := Result + 'Ctrl+';
  if ssAlt in Modifiers then Result := Result + 'Alt+';
  if ssShift in Modifiers then Result := Result + 'Shift+';

  // 移除末尾多余的加号
  if (Result <> '') and (Result[Length(Result)] = '+') then
    Delete(Result, Length(Result), 1);
end;

function THotKey.ShortCutToText(ShortCut: TShortCut): string;
var
  Key: Word;
  Shift: TShiftState;
  S: string;
begin
  Menus.ShortCutToKey(ShortCut, Key, Shift);
  S := GetModifiersText(Shift);
  if S = '' then
    Result := VirtualKeyToString(Key)
  else
    Result := S + '+' + VirtualKeyToString(Key);
end;

function THotKey.VirtualKeyToString(VKey: Word): string;
begin
  case VKey of
    VK_F1: Result := 'F1';
    VK_F2: Result := 'F2';
    VK_F3: Result := 'F3';
    VK_F4: Result := 'F4';
    VK_F5: Result := 'F5';
    VK_F6: Result := 'F6';
    VK_F7: Result := 'F7';
    VK_F8: Result := 'F8';
    VK_F9: Result := 'F9';
    VK_F10: Result := 'F10';
    VK_F11: Result := 'F11';
    VK_F12: Result := 'F12';
    VK_F13: Result := 'F13';
    VK_F14: Result := 'F14';
    VK_F15: Result := 'F15';
    VK_F16: Result := 'F16';
    VK_F17: Result := 'F17';
    VK_F18: Result := 'F18';
    VK_F19: Result := 'F19';
    VK_F20: Result := 'F20';
    VK_F21: Result := 'F21';
    VK_F22: Result := 'F22';
    VK_F23: Result := 'F23';
    VK_F24: Result := 'F24';

    VK_INSERT:     Result := 'Ins';
    VK_DELETE:     Result := 'Del';
    VK_HOME:       Result := 'Home';
    VK_END:        Result := 'End';
    VK_PRIOR:      Result := 'PgUp';
    VK_NEXT:       Result := 'PgDn';
    VK_UP:         Result := 'Up';
    VK_DOWN:       Result := 'Down';
    VK_LEFT:       Result := 'Left';
    VK_RIGHT:      Result := 'Right';
    VK_RETURN:     Result := 'Enter';
    VK_ESCAPE:     Result := 'Esc';
    VK_BACK:       Result := 'Back';
    VK_SPACE:      Result := 'Space';
    VK_TAB:        Result := 'Tab';
    VK_CAPITAL:    Result := 'Caps';
    VK_NUMLOCK:    Result := 'Num';
    VK_SCROLL:     Result := 'Scroll';
    VK_PAUSE:      Result := 'Pause';
    VK_SNAPSHOT:   Result := 'PrtSc';
    VK_APPS:       Result := 'Menu';

    VK_NUMPAD0:    Result := 'Num0';
    VK_NUMPAD1:    Result := 'Num1';
    VK_NUMPAD2:    Result := 'Num2';
    VK_NUMPAD3:    Result := 'Num3';
    VK_NUMPAD4:    Result := 'Num4';
    VK_NUMPAD5:    Result := 'Num5';
    VK_NUMPAD6:    Result := 'Num6';
    VK_NUMPAD7:    Result := 'Num7';
    VK_NUMPAD8:    Result := 'Num8';
    VK_NUMPAD9:    Result := 'Num9';
    VK_DECIMAL:    Result := 'Num.';
    VK_DIVIDE:     Result := 'Num/';
    VK_MULTIPLY:   Result := 'Num*';
    VK_SUBTRACT:   Result := 'Num-';
    VK_ADD:        Result := 'Num+';

    VK_OEM_COMMA:  Result := ',';
    VK_OEM_PERIOD: Result := '.';
    VK_OEM_MINUS:  Result := '-';
    VK_OEM_PLUS:   Result := '+';
    VK_OEM_1:      Result := ';';
    VK_OEM_2:      Result := '/';
    VK_OEM_3:      Result := '`';
    VK_OEM_4:      Result := '[';
    VK_OEM_5:      Result := '\';
    VK_OEM_6:      Result := ']';
    VK_OEM_7:      Result := '''';

    0:             Result := '';

  else
    // 处理字母和数字键
    if (VKey >= Ord('A')) and (VKey <= Ord('Z')) then
      Result := Chr(VKey)
    else if (VKey >= Ord('0')) and (VKey <= Ord('9')) then
      Result := Chr(VKey)
    else
      Result := '[' + IntToStr(VKey) + ']'; // 未知键显示键码
  end;
end;

procedure THotKey.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  // 未在捕获状态时重新进入捕获（保留当前热键值），使后续按键仍可继续录入
  if not FCapturing then
  begin
    FCapturing := True;
    FOriginalHotKey := GetHotKey;
  end;

  // 处理特殊键
  case Key of
    VK_SHIFT, VK_CONTROL, VK_MENU: // Shift, Ctrl, Alt
    begin
      FModifiers := ShiftStateToModifiers(Shift);
      UpdateDisplay; // 实时更新修饰键显示
    end;

    VK_ESCAPE:
      EndCapture(True); // Cancel

    VK_TAB:
    begin
      // 允许Tab切换控件
      EndCapture(False);
      inherited;
    end;

    else
    begin
      // 忽略无效键
      if Key in [VK_CAPITAL, VK_NUMLOCK, VK_SCROLL] then
        Exit;

      // 保存按键
      FVirtKey := Key;
      FModifiers := ShiftStateToModifiers(Shift);
      EndCapture(False); // Confirm
    end;
  end;

  Key := 0; // 阻止默认处理
end;

procedure THotKey.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);

  if not FCapturing then Exit;

  // 更新修饰键状态
  if Key in [VK_SHIFT, VK_CONTROL, VK_MENU] then
  begin
    FModifiers := ShiftStateToModifiers(Shift);
    if FModifiers = [] then
      FVirtKey := 0; // 修饰键全部松开，清除未确认的键值，全清空显示
    UpdateDisplay; // 实时更新修饰键显示
  end;

  Key := 0; // 阻止默认处理
end;

procedure THotKey.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if not FCapturing and Focused then
    StartCapture;
end;

procedure THotKey.WndProc(var Message: TMessage);
var
  Key: Word;
begin
  // 在消息层拦截按键，防止原生编辑框先行处理（如方向键移动光标），
  // 确保方向键等所有按键都能作为热键捕获
  if Message.Msg = WM_KEYDOWN then
  begin
    Key := TWMKey(Message).CharCode;
    KeyDown(Key, KeyDataToShiftState(TWMKey(Message).KeyData));
    if Key = 0 then // 已消费，直接吞掉消息
      Exit;
  end;
  inherited WndProc(Message);
end;

{$ENDIF FPC}
end.
