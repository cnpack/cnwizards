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

unit CnFmxTabOrderUtils;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Tab Order 专家支持 FMX 设计器的实现单元
* 单元作者：Liu Xiao (master@cnpack.org)
* 备    注：FMX 由于引用问题，不可集成在原有的 CnTabOrderWizard 单元中
* 开发平台：Win7 + Delphi XE6
* 兼容测试：暂无
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2014.10.05 V1.0
*               创建单元
================================================================================
|</PRE>}
interface

{$I CnWizards.inc}

uses
  System.Types, System.Classes, System.SysUtils, System.Contnrs, System.UITypes,
  System.Math, FMX.Controls, FMX.Objects, FMX.Types,  FMX.Forms, WinApi.Windows,
  {$IFDEF COMPILER19_UP}FMX.Graphics, {$ENDIF}
  CnWizMethodHook;

// TabOrder 专家创建时调用一次，用来初始化 FMX 的 Hook
procedure CreateFMXPaintHook(Wizard: TObject);

// TabOrder 专家销毁时调用一次，用来释放 FMX 的 Hook
procedure FreeNotificationFMXPaintHook;

// 设计器更改通知，Root nil means closing
procedure NotifyFormDesignerChanged(Root: TComponent);

// 处理一 FMX Form 或 Control 上的所有组件
procedure DoSetFmxTabOrder(Root: TComponent; AInludeChildren: Boolean);

// 用于通知 FMX 组件重绘
procedure UpdateFMXDraw(Root: TComponent);

implementation

uses
  CnTabOrderWizard, CnGraphUtils {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  csDrawBorder = 2;
  csMaxLevel = 6;
  csDrawOpacity = 100;

type
  TFMXControlHook = class(TControl);

{$IFDEF COMPILER18_UP}
  TPaintInternalMethod = procedure (Self: TObject);
{$ELSE}
  // XE3 do not have PaintInternal, use DoPaint
  TDoPaintMethod = procedure (Self: TObject);
{$ENDIF}

var
  TabOrderPaintHook: TCnMethodHook = nil; // Reference

  TabOrderWizard: TCnTabOrderWizard = nil; // Reference

  FMXUpdateDrawForms: TComponentList = nil;

function IsChildOfFMXDesigners(Control: TControl): Boolean;
var
  I: Integer;
begin
  Result := False;
  // 设计期的八个控制点不画
{$IFDEF COMPILER18_UP}  // XE4 or above
  if Control.ClassNameIs('TGrabHandle.TGrabHandleEllipse') then
    Exit;
{$ELSE}                 // XE3
  if Control.ClassNameIs('TEllipse') then
    Exit;
{$ENDIF}

  if FMXUpdateDrawForms <> nil then
  begin
    for I := 0 to FMXUpdateDrawForms.Count - 1 do
    begin
      if Control.Owner = FMXUpdateDrawForms[I] then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function VclColorToAlphaColor(Color: TColor): TAlphaColor;
var
  R, G, B: Byte;
  ACR: TAlphaColorRec;
begin
  DeRGB(Color, R, G, B);
  ACR.R := R;
  ACR.G := G;
  ACR.B := B;
  ACR.A := $FF;
  Result := TAlphaColor(ACR);
end;

// 根据控件嵌套级数计算背景颜色值
function GetBkColor(Control: TControl): TAlphaColor;
var
  I: Integer;
  H, S, L: Double;
begin
  I := 0;
  while (Control <> nil) and not (Control.Parent is TCustomForm) do
  begin
    Inc(I);
{$IFDEF COMPILER18_UP} // XE3 do not have ControlParent
    Control := Control.ParentControl;
{$ELSE}
    if (Control.Parent <> nil) and (Control.Parent is TControl) then
      Control := TControl(Control.Parent)
    else
      Control := nil;
{$ENDIF}
  end;
  RGBToHSL(TabOrderWizard.BkColor, H, S, L);
  Result := VclColorToAlphaColor(HSLToRGB(H + I / csMaxLevel, 0.7, 0.7));
end;

procedure DrawControlTabOrder(Control: TControl);
var
  OrderStr: string;
  Canvas: TCanvas;
  SaveState: TCanvasSaveState;
  Rect, ShadowTextRect: TRectF;
  TH, TW: Single;
  TabStop: Boolean;
begin
  if Control = nil then
    Exit;
  Canvas := Control.Canvas;
  if Canvas = nil then
    Exit;
  if Control.TabOrder < 0 then
    Exit;

  OrderStr := IntToStr(Control.TabOrder);
{$IFDEF DEBUG}
//  CnDebugger.LogMsg('TPaintInternalMethod OrderStr: ' + OrderStr);
{$ENDIF}
  SaveState := Canvas.SaveState;
  try
    // Calc Rect and Draw Rectagle and Text.
    Canvas.BeginScene;

    Canvas.Font.Family := TabOrderWizard.DispFont.Name;
    Canvas.Font.Size := TabOrderWizard.DispFont.Size;
    Canvas.Font.Style := TabOrderWizard.DispFont.Style;

    TW := Canvas.TextWidth(OrderStr) + csDrawBorder * 2;
    TH := Canvas.TextHeight(OrderStr) + csDrawBorder * 2;

    // FIXME: FMX Canvas TextHeight/TextWidth Sometimes Return Huge Value,
    // No way to fix it. just Limit it.
    if TW > 10 * Canvas.Font.Size then
      TW := 5 * Canvas.Font.Size + csDrawBorder * 2;
    if TH > 6 * Canvas.Font.Size then
      TH := 2 * Canvas.Font.Size + csDrawBorder * 2;

    case TabOrderWizard.DispPos of
      dpLeftTop:
        Rect := TRectF.Create(0, 0, TW, TH);
      dpRightTop:
        Rect := TRectF.Create(Control.Width - TW, 0, Control.Width, TH);
      dpLeftBottom:
        Rect := TRectF.Create(0, Control.Height - TH, TW, Control.Height);
      dpRightBottom:
        Rect := TRectF.Create(Control.Width - TW, Control.Height - TH,
          Control.Width, Control.Height);
      dpLeft:
        Rect := TRectF.Create(0, (Control.Height - TH) / 2, TW, (Control.Height + TH) / 2);
      dpRight:
        Rect := TRectF.Create(Control.Width - TW, (Control.Height - TH) / 2,
          Control.Width, (Control.Height + TH) / 2);
      dpTop:
        Rect := TRectF.Create((Control.Width - TW) / 2, 0, (Control.Width + TW) / 2, TH);
      dpBottom:
        Rect := TRectF.Create((Control.Width - TW) / 2,
          Control.Height - TH, (Control.Width + TW) / 2, Control.Height);
    else
      Rect := TRectF.Create((Control.Width - TW) / 2,
        (Control.Height - TH) / 2, (Control.Width + TW) / 2, (Control.Height + TH) / 2);
    end;

{$IFDEF COMPILER20_UP}
    TabStop := Control.TabStop;
{$ELSE}
    TabStop := True; // XE5 or prev do not have TabStop property.
{$ENDIF}

    if TabStop then
    begin
      Canvas.Fill.Color := GetBkColor(Control);
{$IFDEF COMPILER20_UP} // XE6 Stroke Enum name changed without prefix
      Canvas.Stroke.Dash := TStrokeDash.Solid;
{$ELSE}
  {$IFDEF COMPILER17_UP}
      Canvas.Stroke.Dash := TStrokeDash.sdSolid;
  {$ELSE} // XE2 do not have Stroke.Dash, but StrokeDash
      Canvas.StrokeDash := TStrokeDash.sdSolid;
  {$ENDIF}
{$ENDIF}
    end
    else
    begin
      Canvas.Fill.Color := VclColorToAlphaColor(TColor(COLOR_BTNSHADOW or $80000000));
{$IFDEF COMPILER20_UP}
      Canvas.Stroke.Dash := TStrokeDash.Dash;
{$ELSE}
  {$IFDEF COMPILER17_UP}
      Canvas.Stroke.Dash := TStrokeDash.sdDash;
  {$ELSE} // XE2 do not have Stroke.Dash, but StrokeDash
      Canvas.StrokeDash := TStrokeDash.sdDash;
  {$ENDIF}
{$ENDIF}
    end;

    Canvas.FillRect(Rect, 0, 0, AllCorners, csDrawOpacity);

    Canvas.Stroke.Color := TAlphaColors.Black;
    Canvas.DrawRect(Rect, 0, 0, AllCorners, csDrawOpacity);

    Canvas.Fill.Color := TAlphaColors.White;
    ShadowTextRect := TRectF.Create(Rect);
    ShadowTextRect.Offset(1, 1);
{$IFDEF COMPILER20_UP}
    Canvas.FillText(ShadowTextRect, OrderStr, False, csDrawOpacity, [],
      TTextAlign.Center, TTextAlign.Center);
{$ELSE}
    Canvas.FillText(ShadowTextRect, OrderStr, False, csDrawOpacity, [],
      TTextAlign.taCenter, TTextAlign.taCenter);
{$ENDIF}

    Canvas.Fill.Color := VclColorToAlphaColor(TabOrderWizard.DispFont.Color);
{$IFDEF COMPILER20_UP}
    Canvas.FillText(Rect, OrderStr, False, csDrawOpacity, [],
      TTextAlign.Center, TTextAlign.Center);
{$ELSE}
    Canvas.FillText(Rect, OrderStr, False, csDrawOpacity, [],
      TTextAlign.taCenter, TTextAlign.taCenter);
{$ENDIF}

    Canvas.EndScene;
  finally
    Canvas.RestoreState(SaveState);
  end;
end;

{$IFDEF COMPILER18_UP}

procedure TabOrderControlPaintInternal(Self: TObject);
var
  Control: TControl;
begin
  if Self = nil then
    Exit;

  if TabOrderPaintHook.UseDDteours then
    TPaintInternalMethod(TabOrderPaintHook.Trampoline)(Self)
  else
  begin
    TabOrderPaintHook.UnhookMethod;
    TFMXControlHook(Self).AfterPaint;
    TabOrderPaintHook.HookMethod;
  end;

  if Self is TControl then
  begin
    if (TabOrderWizard <> nil) and TabOrderWizard.Active
      and TabOrderWizard.DispTabOrder then
    begin
      Control := Self as TControl;
      if (csDesigning in Control.ComponentState) and IsChildOfFMXDesigners(Control) then
      begin
        // Draw TabOrder Mark
{$IFDEF DEBUG}
//      CnDebugger.LogMsg('TabOrderControlPaintInternal Should Draw Mark: ' + Self.ClassName);
{$ENDIF}
        DrawControlTabOrder(Control);
      end;
    end;
  end;
end;

{$ELSE}

procedure TabOrderControlDoPaint(Self: TObject);
var
  Control: TControl;
begin
  if Self = nil then
    Exit;

  if TabOrderPaintHook.UseDDteours then
    TDoPaintMethod(TabOrderPaintHook.Trampoline)(Self)
  else
  begin
    TabOrderPaintHook.UnhookMethod;
    TFMXControlHook(Self).DoPaint;
    TabOrderPaintHook.HookMethod;
  end;

  if Self is TControl then
  begin
    if (TabOrderWizard <> nil) and TabOrderWizard.Active
      and TabOrderWizard.DispTabOrder then
    begin
      Control := Self as TControl;
      if (csDesigning in Control.ComponentState) and IsChildOfFMXDesigners(Control) then
      begin
        // Draw TabOrder Mark
{$IFDEF DEBUG}
//      CnDebugger.LogMsg('TabOrderControlDoPaint Should Draw Mark: ' + Self.ClassName);
{$ENDIF}
        DrawControlTabOrder(Control);
      end;
    end;
  end;
end;

{$ENDIF}

procedure CreateFMXPaintHook(Wizard: TObject);
begin
  TabOrderWizard := TCnTabOrderWizard(Wizard);
  FMXUpdateDrawForms := TComponentList.Create(False);

  if TabOrderPaintHook = nil then
  begin
{$IFDEF COMPILER18_UP}
    TabOrderPaintHook := TCnMethodHook.Create(@TFMXControlHook.PaintInternal,
      @TabOrderControlPaintInternal, True);
{$ELSE}
    TabOrderPaintHook := TCnMethodHook.Create(@TFMXControlHook.DoPaint,
      @TabOrderControlDoPaint, True);
{$ENDIF}
  end;
end;

procedure FreeNotificationFMXPaintHook;
begin
  FreeAndNil(TabOrderPaintHook);
  FMXUpdateDrawForms.Clear;
  FreeAndNil(FMXUpdateDrawForms);
end;

procedure NotifyFormDesignerChanged(Root: TComponent);
begin
  if FMXUpdateDrawForms = nil then
    Exit;

  if Root = nil then
  begin
    FMXUpdateDrawForms.Clear;
  end
  else if Root is TFmxObject then
  begin
    FMXUpdateDrawForms.Add(Root);

    // TODO: Start Timer to Auto Adjust
  end;
end;

procedure UpdateFMXDraw(Root: TComponent);
var
  I: Integer;
begin
  for I := 0 to Root.ComponentCount - 1 do
    if Root.Components[I] is TControl then
      TControl(Root.Components[I]).Repaint;
end;

var
  ATabOrderStyle: TTabOrderStyle;
  AOrderByCenter: Boolean;
  AInvert: Boolean;
  InvertBidiMode: Boolean;

// 排序过程
function TabOrderSort(Item1, Item2: Pointer): Integer;
var
  R1, R2: TRect;
  X1, X2: Integer;
  Y1, Y2: Integer;
begin
  R1 := PCnRectRec(Item1)^.Rect;
  R2 := PCnRectRec(Item2)^.Rect;

  if AOrderByCenter then               // 按中心位置排序
  begin
    X1 := (R1.Left + R1.Right) div 2;
    X2 := (R2.Left + R2.Right) div 2;
    Y1 := (R1.Top + R1.Bottom) div 2;
    Y2 := (R2.Top + R2.Bottom) div 2;
  end
  else if not AInvert then  // 反向按左上角位置排序
  begin
    // 如果 BidiMode 是从右到左，则排序规则是右到左，上到下
    if InvertBidiMode then
    begin
      // 按右上角位置排序
      X1 := R1.Right;
      X2 := R2.Right;
      Y1 := R1.Top;
      Y2 := R2.Top;
    end
    else
    begin
      // 按左上角位置排序
      X1 := R1.Left;
      X2 := R2.Left;
      Y1 := R1.Top;
      Y2 := R2.Top;
    end;
  end
  else // 反向时
  begin
    if InvertBidiMode then // 如果 BidiMode 是从右到左，则反成左到右，下到上
    begin
      // 按左下角位置排序
      X1 := R1.Left;
      X2 := R2.Left;
      Y1 := R1.Bottom;
      Y2 := R2.Bottom;
    end
    else
    begin
      // 按右下角位置排序
      X1 := R1.Right;
      X2 := R2.Right;
      Y1 := R1.Bottom;
      Y2 := R2.Bottom;
    end;
  end;

  if ATabOrderStyle = tsHorz then
  begin                                // 先水平方向，考虑BidiMode的情况
    if X1 > X2 then
    begin
      Result := 1;
      if InvertBidiMode then
        Result := -Result;
    end
    else if X1 < X2 then
    begin
      Result := -1;
      if InvertBidiMode then
        Result := -Result;
    end
    else
    begin                              // 再按垂直方向
      if Y1 > Y2 then
        Result := 1
      else if Y1 < Y2 then
        Result := -1
      else
        Result := 0;
    end;
  end
  else
  begin
    if Y1 > Y2 then                    // 先垂直方向
      Result := 1
    else if Y1 < Y2 then
      Result := -1
    else
    begin                              // 再按水平方向，考虑BidiMode的情况
      if X1 > X2 then
      begin
        Result := 1;
        if InvertBidiMode then
          Result := -Result;
      end
      else if X1 < X2 then
      begin
        Result := -1;
        if InvertBidiMode then
          Result := -Result;
      end
      else
        Result := 0;
    end;
  end;

  if AInvert then                      // 反向排序
    Result := -Result;
end;

procedure DoSetFmxTabOrder(Root: TComponent; AInludeChildren: Boolean);
var
  Control: TControl;
  Form: TCustomForm;
  TempList, List: TList;
  Rects: TList;
  NewRect: PCnRectRec;
  I, J, Idx: Integer;
  L, R, T, B: Integer;
  Match: Boolean;

  // 取控件的边界位置
  procedure GetControlPos(AControl: TControl; var AL, AT, AR, AB: Integer);
  begin
    AL := Trunc(AControl.Position.X);
    AT := Trunc(AControl.Position.Y);
    AR := Trunc(AControl.Position.X + AControl.Width);
    AB := Trunc(AControl.Position.Y + AControl.Height);
  end;

  // 增加一个控件到列表
  procedure AddList(AList: TList; AControl: TControl);
  var
    ARect: PCnRectRec;
    AL, AT, AR, AB: Integer;
  begin
    New(ARect);
    ARect.Context := AControl;
    GetControlPos(AControl, AL, AT, AR, AB);
    ARect.Rect := Rect(AL, AT, AR, AB);
    AList.Add(ARect);
  end;
begin
  if (TabOrderWizard = nil) or not TabOrderWizard.Active then Exit;
  if not Assigned(Root) or
    (not (Root is TControl) and not (Root is TCustomForm)) then Exit;

  Control := nil; Form := nil;
  if Root is TControl then
  begin
    Control := TControl(Root);
{$IFDEF COMPILER17_UP}
    if Control.ControlsCount = 0 then Exit;
{$ELSE} // XE2 Do not have ControlsCount
    if Control.ChildrenCount = 0 then Exit;
{$ENDIF}
  end
  else if Root is TCustomForm then
  begin
    Form := TCustomForm(Root);
    if Form.ComponentCount = 0 then Exit;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogEnter('DoSetFmxTabOrder: ' + Root.Name);
{$ENDIF}

  ATabOrderStyle := TabOrderWizard.TabOrderStyle;
  AOrderByCenter := TabOrderWizard.OrderByCenter;
  AInvert := TabOrderWizard.Invert;
  InvertBidiMode := False; // (Control.BiDiMode <> bdLeftToRight); // 左右自动处理

  TempList := TList.Create;
  if Control <> nil then
  begin
{$IFDEF COMPILER17_UP}
    for I := 0 to Control.ControlsCount - 1 do // 将控件放到临时列表中
      if Control.Controls[I] is TControl then
        TempList.Add(Control.Controls[I]);
{$ELSE} // XE2 Do not have controls but children
    for I := 0 to Control.ChildrenCount - 1 do // 将控件放到临时列表中
      if Control.Children[I] is TControl then
        TempList.Add(Control.Children[I]);
{$ENDIF}
  end;

  if Form <> nil then
    for I := 0 to Form.ComponentCount - 1 do // 将控件放到临时列表中
      if Form.Components[I] is TControl then
        TempList.Add(Form.Components[I]);

{$IFDEF DEBUG}
  CnDebugger.LogMsg('DoSetFmxTabOrder: Will Process ' + IntToStr(TempList.Count));
{$ENDIF}

  List := TList.Create;
  try
    List.Clear;
    for I := 0 to TempList.Count - 1 do
    begin
      New(NewRect);
      NewRect.Context := TControl(TempList[I]);
      GetControlPos(TControl(TempList[I]), L, T, R, B);
      NewRect.Rect := Rect(L, T, R, B);
      List.Add(NewRect);
    end;

    if List.Count > 0 then
    begin
      List.Sort(TabOrderSort);
      if not TabOrderWizard.Group then                // 不分组进行排序
      begin
        for I := 0 to List.Count - 1 do
        begin
  {$IFDEF DEBUG}
          CnDebugger.LogMsg('SetFmxTabOrder Result ' +
            TControl(PCnRectRec(List[I]).Context).Name + ' ' + IntToStr(I));
  {$ENDIF}
          TControl(PCnRectRec(List[I]).Context).TabOrder := I;
          TControl(PCnRectRec(List[I]).Context).Repaint;
        end;
      end
      else                              // 分组排序
      begin
        Rects := TList.Create;
        try
          for I := 0 to List.Count - 1 do
          begin
            GetControlPos(TControl(PCnRectRec(List[I]).Context), L, T, R, B);
            Match := False;
            // 将控件分组，左右相同或上下相同的控件归为一组
            for J := 0 to Rects.Count - 1 do
              with PCnRectRec(Rects[J])^.Rect do
              begin
                if TabOrderWizard.TabOrderStyle = tsHorz then
                begin                   // 水平优先时先判断垂直位置
                  if (L = Left) and (R = Right) and (Min(Abs(T - Bottom),
                    Abs(B - Top)) <= (B - T)) then
                  begin
                    AddList(TList(PCnRectRec(Rects[J])^.Context),
                      TControl(PCnRectRec(List[I]).Context));
                    Match := True;
                    Top := Min(T, Top);
                    Bottom := Max(B, Bottom);
                    Break;
                  end
                  else if (T = Top) and (B = Bottom) and (Min(Abs(L - Right),
                    Abs(R - Left)) <= (R - L)) then
                  begin
                    AddList(TList(PCnRectRec(Rects[J])^.Context),
                      TControl(PCnRectRec(List[I]).Context));
                    Match := True;
                    Left := Min(L, Left);
                    Right := Max(R, Right);
                    Break;
                  end;
                end
                else
                begin                   // 垂直优先时先判断水平位置
                  if (T = Top) and (B = Bottom) and (Min(Abs(L - Right),
                    Abs(R - Left)) <= (R - L)) then
                  begin
                    AddList(TList(PCnRectRec(Rects[J])^.Context),
                      TControl(PCnRectRec(List[I]).Context));
                    Match := True;
                    Left := Min(L, Left);
                    Right := Max(R, Right);
                    Break;
                  end
                  else if (L = Left) and (R = Right) and (Min(Abs(T - Bottom),
                    Abs(B - Top)) <= (B - T)) then
                  begin
                    AddList(TList(PCnRectRec(Rects[J])^.Context),
                      TControl(PCnRectRec(List[I]).Context));
                    Match := True;
                    Top := Min(T, Top);
                    Bottom := Max(B, Bottom);
                    Break;
                  end;
                end;
              end;

            if not Match then
            begin
              New(NewRect);
              NewRect.Context := TList.Create;
              AddList(TList(PCnRectRec(NewRect.Context)),
                TControl(PCnRectRec(List[I]).Context));
              NewRect.Rect := Rect(L, T, R, B);
              Rects.Add(NewRect);
            end;
          end;

          Rects.Sort(TabOrderSort);       // 对控件组排序
          Idx := 0;
          for I := 0 to Rects.Count - 1 do
            with TList(PCnRectRec(Rects[I]).Context) do
            begin
              Sort(TabOrderSort);         // 对同一组内的控件排序
              for J := 0 to Count - 1 do
              begin                       // 设置控件 Tab Order
  {$IFDEF DEBUG}
                CnDebugger.LogMsg('SetFmxTabOrder Result ' +
                  TControl(PCnRectRec(Items[J]).Context).Name + ' ' + IntToStr(Idx));
  {$ENDIF}
                TControl(PCnRectRec(Items[J]).Context).TabOrder := Idx;
                TControl(PCnRectRec(List[I]).Context).Repaint;
                Inc(Idx);
              end;
            end;
        finally
          for I := 0 to Rects.Count - 1 do
          begin
            with TList(PCnRectRec(Rects[I]).Context) do
            begin
              for J := 0 to Count - 1 do
                Dispose(Items[J]);
              Free;
            end;
            Dispose(Rects[I]);
          end;
          Rects.Free;
        end;
      end;

      if AInludeChildren then          // 递归设置子控件
        for I := 0 to List.Count - 1 do
          DoSetFmxTabOrder(TControl(PCnRectRec(List[I]).Context), AInludeChildren);
    end;
  finally
    for I := 0 to List.Count - 1 do
      Dispose(List[I]);
    List.Free;
    TempList.Free;
  {$IFDEF DEBUG}
    CnDebugger.LogLeave('DoSetFmxTabOrder');
  {$ENDIF}
  end;
end;

end.
