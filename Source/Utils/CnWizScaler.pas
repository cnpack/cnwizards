{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2018 CnPack 开发组                       }
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

unit CnWizScaler;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：针对专家包窗体的运行期比例缩放实现单元，与屏幕 DPI 无关
* 单元作者：刘啸 liuxiao@cnpack.org
* 备    注：
* 开发平台：PWinXP SP3 + Delphi 7
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2018.07.16 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Windows, Controls, Forms;

procedure ScaleForm(AForm: TCustomForm; Factor: Single);

implementation

type
  TControlHack = class(TControl);

procedure ScaleControl(Control: TControl; Factor: Single; UseClient: Boolean = False);
var
  X, Y, W, H: Integer;
begin
  X := Round(Control.Left * Factor);
  Y := Round(Control.Top * Factor);

  if UseClient then
  begin
    if not (csFixedWidth in Control.ControlStyle) then
      W := Round(Control.ClientWidth * Factor)
    else
      W := Control.ClientWidth;

    if not (csFixedHeight in Control.ControlStyle) then
      H := Round(Control.ClientHeight * Factor)
    else
      H := Control.ClientHeight;
  end
  else
  begin
    if not (csFixedWidth in Control.ControlStyle) then
      W := Round(Control.Width * Factor)
    else
      W := Control.Width;

    if not (csFixedHeight in Control.ControlStyle) then
      H := Round(Control.Height * Factor)
    else
      H := Control.Height;
  end;

  // Scale Constraints
  if Control.Constraints.MinWidth > 0 then
    Control.Constraints.MinWidth := Round(Control.Constraints.MinWidth * Factor);
  if Control.Constraints.MaxWidth > 0 then
    Control.Constraints.MaxWidth := Round(Control.Constraints.MaxWidth * Factor);
  if Control.Constraints.MinHeight > 0 then
    Control.Constraints.MinHeight := Round(Control.Constraints.MinHeight * Factor);
  if Control.Constraints.MaxHeight > 0 then
    Control.Constraints.MaxHeight := Round(Control.Constraints.MaxHeight * Factor);

{$IFDEF TCONTROL_HAS_MARGINS}
  // Scale Margins
  if Margins.Left > 0 then
    Margins.Left := Round(Margins.Left * Factor);
  if Margins.Top > 0 then
    Margins.Top := Round(Margins.Top * Factor);
  if Margins.Right > 0 then
    Margins.Right := Round(Margins.Right * Factor);
  if Margins.Bottom > 0 then
    Margins.Bottom := Round(Margins.Bottom * Factor);
{$ENDIF}

  if UseClient then
  begin
    Control.Left := X;
    Control.Top := Y;
    Control.ClientHeight := H;
    Control.ClientWidth := W;
  end
  else
    Control.SetBounds(X, Y, W, H);

  // Scale Font
  if not TControlHack(Control).ParentFont then
    TControlHack(Control).Font.Size := Round(TControlHack(Control).Font.Size * Factor);
end;

procedure ScaleWinControl(WinControl: TWinControl; Factor: Single;
  UseClient: Boolean = False);
var
  I: Integer;
  AControl: TControlHack;
  BackupAnchors: array of TAnchors;
begin
  WinControl.DisableAlign;
  SetLength(BackupAnchors, WinControl.ControlCount);
  try
    for I := 0 to WinControl.ControlCount - 1 do
    begin
      // 保存每个控件的 Anchors
      AControl := TControlHack(WinControl.Controls[I]);
      BackupAnchors[I] := AControl.Anchors;
      if AControl.Anchors <> [akTop, akLeft] then
      begin
{$IFDEF TCONTROL_HAS_EXPLICIT_BOUNDS}
        AControl.UpdateExplicitBounds;
{$ENDIF}
        AControl.Anchors := [akTop, akLeft];
      end;

      // 改子控件大小
      if WinControl.Controls[I] is TWinControl then
        ScaleWinControl(WinControl.Controls[I] as TWinControl, Factor)
      else
        ScaleControl(WinControl.Controls[I], Factor);
    end;

    // 改自身大小
    ScaleControl(WinControl, Factor, UseClient);

    // 恢复每个子控件的 Anchors
    for I := 0 to WinControl.ControlCount - 1 do
    begin
      AControl := TControlHack(WinControl.Controls[I]);
      if AControl.Anchors <> BackupAnchors[I] then
      begin
        AControl.Anchors := BackupAnchors[I];
      end;
    end;
  finally
    SetLength(BackupAnchors, 0);
    WinControl.EnableAlign;
  end;
end;

procedure ScaleForm(AForm: TCustomForm; Factor: Single);
begin
  if Abs(Factor - 1.0) < 0.001 then
    Exit;

  ScaleWinControl(AForm, Factor, True);
end;

end.
