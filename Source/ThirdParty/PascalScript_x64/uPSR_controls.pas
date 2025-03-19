
unit uPSR_controls;

{$I PascalScript.inc}
interface
uses
  uPSRuntime, uPSUtils;

procedure RIRegisterTControl(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTWinControl(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTGraphicControl(cl: TPSRuntimeClassImporter);
procedure RIRegisterTCustomControl(cl: TPSRuntimeClassImporter);
procedure RIRegister_TDragObject(CL: TPSRuntimeClassImporter);
{$IFDEF DELPHI4UP}
procedure RIRegisterTSizeConstraints(cl: TPSRuntimeClassImporter);
{$ENDIF}

procedure RIRegister_Controls(Cl: TPSRuntimeClassImporter);

implementation
{$IFNDEF FPC}
uses
  Classes{$IFDEF CLX}, QControls, QGraphics{$ELSE}, Controls, Graphics, Windows{$ENDIF};
{$ELSE}
uses
  Classes, Controls, Graphics;
{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TControl'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TControl_PSHelper = class helper for TControl
  public
    procedure AlignR( var T: Byte);
    procedure AlignW( T: Byte);
    procedure ClientHeightR( var T: Longint);
    procedure ClientHeightW( T: Longint);
    procedure ClientWidthR( var T: Longint);
    procedure ClientWidthW( T: Longint);
    procedure ShowHintR( var T: Boolean);
    procedure ShowHintW( T: Boolean);
    procedure VisibleR( var T: Boolean);
    procedure VisibleW( T: Boolean);
    procedure ParentR( var T: TWinControl);
    procedure ParentW( T: TWinControl);
    procedure SHOWHINT_W( T: BOOLEAN);
    procedure SHOWHINT_R( var T: BOOLEAN);
    procedure ENABLED_W( T: BOOLEAN);
    procedure ENABLED_R( var T: BOOLEAN);
  end;

procedure TControl_PSHelper.AlignR( var T: Byte); begin T := Byte(Self.Align); end;
procedure TControl_PSHelper.AlignW( T: Byte); begin Self.Align:= TAlign(T); end;

procedure TControl_PSHelper.ClientHeightR( var T: Longint); begin T := Self.ClientHeight; end;
procedure TControl_PSHelper.ClientHeightW( T: Longint); begin Self.ClientHeight := T; end;

procedure TControl_PSHelper.ClientWidthR( var T: Longint); begin T := Self.ClientWidth; end;
procedure TControl_PSHelper.ClientWidthW( T: Longint); begin Self.ClientWidth:= T; end;

procedure TControl_PSHelper.ShowHintR( var T: Boolean); begin T := Self.ShowHint; end;
procedure TControl_PSHelper.ShowHintW( T: Boolean); begin Self.ShowHint:= T; end;

procedure TControl_PSHelper.VisibleR( var T: Boolean); begin T := Self.Visible; end;
procedure TControl_PSHelper.VisibleW( T: Boolean); begin Self.Visible:= T; end;

procedure TControl_PSHelper.ParentR( var T: TWinControl); begin T := Self.Parent; end;
procedure TControl_PSHelper.ParentW( T: TWinControl); begin Self.Parent:= T; end;


procedure TControl_PSHelper.SHOWHINT_W( T: BOOLEAN); begin Self.SHOWHINT := T; end;
procedure TControl_PSHelper.SHOWHINT_R( var T: BOOLEAN); begin T := Self.SHOWHINT; end;
procedure TControl_PSHelper.ENABLED_W( T: BOOLEAN); begin Self.ENABLED := T; end;
procedure TControl_PSHelper.ENABLED_R( var T: BOOLEAN); begin T := Self.ENABLED; end;

procedure RIRegisterTControl(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TControl) do
  begin
    RegisterVirtualConstructor(@TControl.Create, 'Create');
    RegisterMethod(@TControl.BRingToFront, 'BringToFront');
    RegisterMethod(@TControl.Hide, 'Hide');
    RegisterVirtualMethod(@TControl.Invalidate, 'Invalidate');
    RegisterMethod(@TControl.Refresh, 'Refresh');
    RegisterVirtualMethod(@TControl.Repaint, 'Repaint');
    RegisterMethod(@TControl.SendToBack, 'SendToBack');
    RegisterMethod(@TControl.Show, 'Show');
    RegisterVirtualMethod(@TControl.Update, 'Update');
    RegisterVirtualMethod(@TControl.SetBounds, 'SetBounds');

    RegisterPropertyHelper(@TControl.ShowHintR, @TControl.ShowHintW, 'ShowHint');
    RegisterPropertyHelper(@TControl.AlignR, @TControl.AlignW, 'Align');
    RegisterPropertyHelper(@TControl.ClientHeightR, @TControl.ClientHeightW, 'ClientHeight');
    RegisterPropertyHelper(@TControl.ClientWidthR, @TControl.ClientWidthW, 'ClientWidth');
    RegisterPropertyHelper(@TControl.VisibleR, @TControl.VisibleW, 'Visible');
    RegisterPropertyHelper(@TControl.ENABLED_R, @TControl.ENABLED_W, 'Enabled');

    RegisterPropertyHelper(@TControl.ParentR, @TControl.ParentW, 'Parent');

    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TControl.Dragging, 'Dragging');
    RegisterMethod(@TControl.HasParent, 'HasParent');
    RegisterMethod(@TCONTROL.CLIENTTOSCREEN, 'ClientToScreen');
    RegisterMethod(@TCONTROL.DRAGGING, 'Dragging');
   {$IFNDEF FPC}
    RegisterMethod(@TCONTROL.BEGINDRAG, 'BeginDrag');
    RegisterMethod(@TCONTROL.ENDDRAG, 'EndDrag');
   {$ENDIF}
    {$IFNDEF CLX}
    RegisterMethod(@TCONTROL.GETTEXTBUF, 'GetTextBuf');
    RegisterMethod(@TCONTROL.GETTEXTLEN, 'GetTextLen');
    RegisterMethod(@TCONTROL.PERFORM, 'Perform');
    RegisterMethod(@TCONTROL.SETTEXTBUF, 'SetTextBuf');
    {$ENDIF}
    RegisterMethod(@TCONTROL.SCREENTOCLIENT, 'ScreenToClient');
    {$ENDIF}
  end;
end;

{$ELSE}
procedure TControlAlignR(Self: TControl; var T: Byte); begin T := Byte(Self.Align); end;
procedure TControlAlignW(Self: TControl; T: Byte); begin Self.Align:= TAlign(T); end;

procedure TControlClientHeightR(Self: TControl; var T: Longint); begin T := Self.ClientHeight; end;
procedure TControlClientHeightW(Self: TControl; T: Longint); begin Self.ClientHeight := T; end;

procedure TControlClientWidthR(Self: TControl; var T: Longint); begin T := Self.ClientWidth; end;
procedure TControlClientWidthW(Self: TControl; T: Longint); begin Self.ClientWidth:= T; end;

procedure TControlShowHintR(Self: TControl; var T: Boolean); begin T := Self.ShowHint; end;
procedure TControlShowHintW(Self: TControl; T: Boolean); begin Self.ShowHint:= T; end;

procedure TControlVisibleR(Self: TControl; var T: Boolean); begin T := Self.Visible; end;
procedure TControlVisibleW(Self: TControl; T: Boolean); begin Self.Visible:= T; end;

procedure TControlParentR(Self: TControl; var T: TWinControl); begin T := Self.Parent; end;
procedure TControlParentW(Self: TControl; T: TWinControl); begin Self.Parent:= T; end;


procedure TCONTROLSHOWHINT_W(Self: TCONTROL; T: BOOLEAN); begin Self.SHOWHINT := T; end;
procedure TCONTROLSHOWHINT_R(Self: TCONTROL; var T: BOOLEAN); begin T := Self.SHOWHINT; end;
procedure TCONTROLENABLED_W(Self: TCONTROL; T: BOOLEAN); begin Self.ENABLED := T; end;
procedure TCONTROLENABLED_R(Self: TCONTROL; var T: BOOLEAN); begin T := Self.ENABLED; end;

procedure RIRegisterTControl(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TControl) do
  begin
    RegisterVirtualConstructor(@TControl.Create, 'Create');
    RegisterMethod(@TControl.BRingToFront, 'BringToFront');
    RegisterMethod(@TControl.Hide, 'Hide');
    RegisterVirtualMethod(@TControl.Invalidate, 'Invalidate');
    RegisterMethod(@TControl.Refresh, 'Refresh');
    RegisterVirtualMethod(@TControl.Repaint, 'Repaint');
    RegisterMethod(@TControl.SendToBack, 'SendToBack');
    RegisterMethod(@TControl.Show, 'Show');
    RegisterVirtualMethod(@TControl.Update, 'Update');
    RegisterVirtualMethod(@TControl.SetBounds, 'SetBounds');

    RegisterPropertyHelper(@TControlShowHintR, @TControlShowHintW, 'ShowHint');
    RegisterPropertyHelper(@TControlAlignR, @TControlAlignW, 'Align');
    RegisterPropertyHelper(@TControlClientHeightR, @TControlClientHeightW, 'ClientHeight');
    RegisterPropertyHelper(@TControlClientWidthR, @TControlClientWidthW, 'ClientWidth');
    RegisterPropertyHelper(@TControlVisibleR, @TControlVisibleW, 'Visible');
    RegisterPropertyHelper(@TCONTROLENABLED_R, @TCONTROLENABLED_W, 'Enabled');

    RegisterPropertyHelper(@TControlParentR, @TControlParentW, 'Parent');

    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TControl.Dragging, 'Dragging');
    RegisterMethod(@TControl.HasParent, 'HasParent');
    RegisterMethod(@TCONTROL.CLIENTTOSCREEN, 'ClientToScreen');
    RegisterMethod(@TCONTROL.DRAGGING, 'Dragging');
   {$IFNDEF FPC}
    RegisterMethod(@TCONTROL.BEGINDRAG, 'BeginDrag');
    RegisterMethod(@TCONTROL.ENDDRAG, 'EndDrag');
   {$ENDIF}
    {$IFNDEF CLX}
    RegisterMethod(@TCONTROL.GETTEXTBUF, 'GetTextBuf');
    RegisterMethod(@TCONTROL.GETTEXTLEN, 'GetTextLen');
    RegisterMethod(@TCONTROL.PERFORM, 'Perform');
    RegisterMethod(@TCONTROL.SETTEXTBUF, 'SetTextBuf');
    {$ENDIF}
    RegisterMethod(@TCONTROL.SCREENTOCLIENT, 'ScreenToClient');
    {$ENDIF}
  end;
end;

{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TWinControl'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TWinControl_PSHelper = class helper for TWinControl
  public
    {$IFNDEF CLX}
    procedure HandleR(var T: Longint);
    {$ENDIF}
    procedure ShowingR(var T: Boolean);
    procedure TabOrderR(var T: Longint);
    procedure TabOrderW(T: Longint);
    procedure TabStopR(var T: Boolean);
    procedure TabStopW(T: Boolean);
    procedure BRUSH_R(var T: TBRUSH);
    procedure CONTROLS_R(var T: TCONTROL; t1: INTEGER);
    procedure CONTROLCOUNT_R(var T: INTEGER);
  end;

{$IFNDEF CLX}
procedure TWinControl_PSHelper.HandleR(var T: Longint); begin T := Self.Handle; end;
{$ENDIF}
procedure TWinControl_PSHelper.ShowingR(var T: Boolean); begin T := Self.Showing; end;


procedure TWinControl_PSHelper.TabOrderR(var T: Longint); begin T := Self.TabOrder; end;
procedure TWinControl_PSHelper.TabOrderW(T: Longint); begin Self.TabOrder:= T; end;

procedure TWinControl_PSHelper.TabStopR(var T: Boolean); begin T := Self.TabStop; end;
procedure TWinControl_PSHelper.TabStopW(T: Boolean); begin Self.TabStop:= T; end;
procedure TWinControl_PSHelper.BRUSH_R(var T: TBRUSH); begin T := Self.BRUSH; end;
procedure TWinControl_PSHelper.CONTROLS_R(var T: TCONTROL; t1: INTEGER); begin t := Self.CONTROLS[t1]; end;
procedure TWinControl_PSHelper.CONTROLCOUNT_R(var T: INTEGER); begin t := Self.CONTROLCOUNT; end;

procedure RIRegisterTWinControl(Cl: TPSRuntimeClassImporter); // requires TControl
begin
  with Cl.Add(TWinControl) do
  begin
    {$IFNDEF CLX}
    RegisterPropertyHelper(@TWinControl.HandleR, nil, 'Handle');
    {$ENDIF}
    RegisterPropertyHelper(@TWinControl.ShowingR, nil, 'Showing');
    RegisterPropertyHelper(@TWinControl.TabOrderR, @TWinControl.TabOrderW, 'TabOrder');
    RegisterPropertyHelper(@TWinControl.TabStopR, @TWinControl.TabStopW, 'TabStop');
    RegisterMethod(@TWinControl.CANFOCUS, 'CanFocus');
    RegisterMethod(@TWinControl.FOCUSED, 'Focused');
    RegisterPropertyHelper(@TWinControl.CONTROLS_R, nil, 'Controls');
    RegisterPropertyHelper(@TWinControl.CONTROLCOUNT_R, nil, 'ControlCount');
    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TWinControl.HandleAllocated, 'HandleAllocated');
    RegisterMethod(@TWinControl.HandleNeeded, 'HandleNeeded');
    RegisterMethod(@TWinControl.EnableAlign, 'EnableAlign');
		RegisterMethod(@TWinControl.RemoveControl, 'RemoveControl');
		{$IFNDEF FPC}
		RegisterMethod(@TWinControl.InsertControl, 'InsertControl');
		RegisterMethod(@TWinControl.ScaleBy, 'ScaleBy');
		RegisterMethod(@TWinControl.ScrollBy, 'ScrollBy');
		{$IFNDEF CLX}
		 RegisterMethod(@TWinControl.PAINTTO, 'PaintTo');
		{$ENDIF}
		{$ENDIF}{FPC}
		RegisterMethod(@TWinControl.Realign, 'Realign');
		RegisterVirtualMethod(@TWinControl.SetFocus, 'SetFocus');
		RegisterMethod(@TWinControl.CONTAINSCONTROL, 'ContainsControl');
		RegisterMethod(@TWinControl.DISABLEALIGN, 'DisableAlign');
		RegisterMethod(@TWinControl.UPDATECONTROLSTATE, 'UpdateControlState');
    RegisterPropertyHelper(@TWinControl.BRUSH_R, nil, 'Brush');
    {$ENDIF}
  end;
end;

{$ELSE}
{$IFNDEF CLX}
procedure TWinControlHandleR(Self: TWinControl; var T: Longint); begin T := Self.Handle; end;
{$ENDIF}
procedure TWinControlShowingR(Self: TWinControl; var T: Boolean); begin T := Self.Showing; end;


procedure TWinControlTabOrderR(Self: TWinControl; var T: Longint); begin T := Self.TabOrder; end;
procedure TWinControlTabOrderW(Self: TWinControl; T: Longint); begin Self.TabOrder:= T; end;

procedure TWinControlTabStopR(Self: TWinControl; var T: Boolean); begin T := Self.TabStop; end;
procedure TWinControlTabStopW(Self: TWinControl; T: Boolean); begin Self.TabStop:= T; end;
procedure TWINCONTROLBRUSH_R(Self: TWINCONTROL; var T: TBRUSH); begin T := Self.BRUSH; end;
procedure TWINCONTROLCONTROLS_R(Self: TWINCONTROL; var T: TCONTROL; t1: INTEGER); begin t := Self.CONTROLS[t1]; end;
procedure TWINCONTROLCONTROLCOUNT_R(Self: TWINCONTROL; var T: INTEGER); begin t := Self.CONTROLCOUNT; end;

procedure RIRegisterTWinControl(Cl: TPSRuntimeClassImporter); // requires TControl
begin
  with Cl.Add(TWinControl) do
  begin
    {$IFNDEF CLX}
    RegisterPropertyHelper(@TWinControlHandleR, nil, 'Handle');
    {$ENDIF}
    RegisterPropertyHelper(@TWinControlShowingR, nil, 'Showing');
    RegisterPropertyHelper(@TWinControlTabOrderR, @TWinControlTabOrderW, 'TabOrder');
    RegisterPropertyHelper(@TWinControlTabStopR, @TWinControlTabStopW, 'TabStop');
    RegisterMethod(@TWINCONTROL.CANFOCUS, 'CanFocus');
    RegisterMethod(@TWINCONTROL.FOCUSED, 'Focused');
    RegisterPropertyHelper(@TWINCONTROLCONTROLS_R, nil, 'Controls');
    RegisterPropertyHelper(@TWINCONTROLCONTROLCOUNT_R, nil, 'ControlCount');
    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TWinControl.HandleAllocated, 'HandleAllocated');
    RegisterMethod(@TWinControl.HandleNeeded, 'HandleNeeded');
    RegisterMethod(@TWinControl.EnableAlign, 'EnableAlign');
		RegisterMethod(@TWinControl.RemoveControl, 'RemoveControl');
		{$IFNDEF FPC}
		RegisterMethod(@TWinControl.InsertControl, 'InsertControl');
		RegisterMethod(@TWinControl.ScaleBy, 'ScaleBy');
		RegisterMethod(@TWinControl.ScrollBy, 'ScrollBy');
		{$IFNDEF CLX}
		 RegisterMethod(@TWINCONTROL.PAINTTO, 'PaintTo');
		{$ENDIF}
		{$ENDIF}{FPC}
		RegisterMethod(@TWinControl.Realign, 'Realign');
		RegisterVirtualMethod(@TWinControl.SetFocus, 'SetFocus');
		RegisterMethod(@TWINCONTROL.CONTAINSCONTROL, 'ContainsControl');
		RegisterMethod(@TWINCONTROL.DISABLEALIGN, 'DisableAlign');
		RegisterMethod(@TWINCONTROL.UPDATECONTROLSTATE, 'UpdateControlState');
    RegisterPropertyHelper(@TWINCONTROLBRUSH_R, nil, 'Brush');
    {$ENDIF}
  end;
end;

{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TGraphicControl'}{$ENDIF}
procedure RIRegisterTGraphicControl(cl: TPSRuntimeClassImporter); // requires TControl
begin
  Cl.Add(TGraphicControl);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCustomControl'}{$ENDIF}
procedure RIRegisterTCustomControl(cl: TPSRuntimeClassImporter); // requires TControl
begin
  Cl.Add(TCustomControl);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TDragObject'}{$ENDIF}
{$IFDEF class_helper_present}
{$IFDEF DELPHI4UP}
type
  TDragObject_PSHelper = class helper for TDragObject
  public
    procedure MouseDeltaY_R(var T: Double);
    procedure MouseDeltaX_R(var T: Double);
    procedure DragTarget_W(const T: Pointer);
    procedure DragTarget_R(var T: Pointer);
    procedure DragTargetPos_W(const T: TPoint);
    procedure DragTargetPos_R(var T: TPoint);
    procedure DragPos_W(const T: TPoint);
    procedure DragPos_R(var T: TPoint);
    procedure DragHandle_W(const T: HWND);
    procedure DragHandle_R(var T: HWND);
    procedure Cancelling_W(const T: Boolean);
    procedure Cancelling_R(var T: Boolean);
  end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.MouseDeltaY_R(var T: Double);
begin T := Self.MouseDeltaY; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.MouseDeltaX_R(var T: Double);
begin T := Self.MouseDeltaX; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.DragTarget_W(const T: Pointer);
begin Self.DragTarget := T; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.DragTarget_R(var T: Pointer);
begin T := Self.DragTarget; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.DragTargetPos_W(const T: TPoint);
begin Self.DragTargetPos := T; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.DragTargetPos_R(var T: TPoint);
begin T := Self.DragTargetPos; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.DragPos_W(const T: TPoint);
begin Self.DragPos := T; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.DragPos_R(var T: TPoint);
begin T := Self.DragPos; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.DragHandle_W(const T: HWND);
begin Self.DragHandle := T; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.DragHandle_R(var T: HWND);
begin T := Self.DragHandle; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.Cancelling_W(const T: Boolean);
begin Self.Cancelling := T; end;

(*----------------------------------------------------------------------------*)
procedure TDragObject_PSHelper.Cancelling_R(var T: Boolean);
begin T := Self.Cancelling; end;
{$ENDIF}
(*----------------------------------------------------------------------------*)
procedure RIRegister_TDragObject(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TDragObject) do
  begin
{$IFNDEF PS_MINIVCL}
{$IFDEF DELPHI4UP}
    RegisterVirtualMethod(@TDragObject.Assign, 'Assign');
{$ENDIF}
{$IFNDEF FPC}
    RegisterVirtualMethod(@TDragObject.GetName, 'GetName');
    RegisterVirtualMethod(@TDragObject.Instance, 'Instance');
{$ENDIF}
    RegisterVirtualMethod(@TDragObject.HideDragImage, 'HideDragImage');
    RegisterVirtualMethod(@TDragObject.ShowDragImage, 'ShowDragImage');
{$IFDEF DELPHI4UP}
    RegisterPropertyHelper(@TDragObject.Cancelling_R,@TDragObject.Cancelling_W,'Cancelling');
    RegisterPropertyHelper(@TDragObject.DragHandle_R,@TDragObject.DragHandle_W,'DragHandle');
    RegisterPropertyHelper(@TDragObject.DragPos_R,@TDragObject.DragPos_W,'DragPos');
    RegisterPropertyHelper(@TDragObject.DragTargetPos_R,@TDragObject.DragTargetPos_W,'DragTargetPos');
    RegisterPropertyHelper(@TDragObject.DragTarget_R,@TDragObject.DragTarget_W,'DragTarget');
    RegisterPropertyHelper(@TDragObject.MouseDeltaX_R,nil,'MouseDeltaX');
    RegisterPropertyHelper(@TDragObject.MouseDeltaY_R,nil,'MouseDeltaY');
{$ENDIF}
{$ENDIF}
  end;
end;

{$ELSE}
{$IFDEF DELPHI4UP}
(*----------------------------------------------------------------------------*)
procedure TDragObjectMouseDeltaY_R(Self: TDragObject; var T: Double);
begin T := Self.MouseDeltaY; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectMouseDeltaX_R(Self: TDragObject; var T: Double);
begin T := Self.MouseDeltaX; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectDragTarget_W(Self: TDragObject; const T: Pointer);
begin Self.DragTarget := T; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectDragTarget_R(Self: TDragObject; var T: Pointer);
begin T := Self.DragTarget; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectDragTargetPos_W(Self: TDragObject; const T: TPoint);
begin Self.DragTargetPos := T; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectDragTargetPos_R(Self: TDragObject; var T: TPoint);
begin T := Self.DragTargetPos; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectDragPos_W(Self: TDragObject; const T: TPoint);
begin Self.DragPos := T; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectDragPos_R(Self: TDragObject; var T: TPoint);
begin T := Self.DragPos; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectDragHandle_W(Self: TDragObject; const T: HWND);
begin Self.DragHandle := T; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectDragHandle_R(Self: TDragObject; var T: HWND);
begin T := Self.DragHandle; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectCancelling_W(Self: TDragObject; const T: Boolean);
begin Self.Cancelling := T; end;

(*----------------------------------------------------------------------------*)
procedure TDragObjectCancelling_R(Self: TDragObject; var T: Boolean);
begin T := Self.Cancelling; end;
{$ENDIF}
(*----------------------------------------------------------------------------*)
procedure RIRegister_TDragObject(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TDragObject) do
  begin
{$IFNDEF PS_MINIVCL}
{$IFDEF DELPHI4UP}
    RegisterVirtualMethod(@TDragObject.Assign, 'Assign');
{$ENDIF}
{$IFNDEF FPC}
    RegisterVirtualMethod(@TDragObject.GetName, 'GetName');
    RegisterVirtualMethod(@TDragObject.Instance, 'Instance');
{$ENDIF}
    RegisterVirtualMethod(@TDragObject.HideDragImage, 'HideDragImage');
    RegisterVirtualMethod(@TDragObject.ShowDragImage, 'ShowDragImage');
{$IFDEF DELPHI4UP}
    RegisterPropertyHelper(@TDragObjectCancelling_R,@TDragObjectCancelling_W,'Cancelling');
    RegisterPropertyHelper(@TDragObjectDragHandle_R,@TDragObjectDragHandle_W,'DragHandle');
    RegisterPropertyHelper(@TDragObjectDragPos_R,@TDragObjectDragPos_W,'DragPos');
    RegisterPropertyHelper(@TDragObjectDragTargetPos_R,@TDragObjectDragTargetPos_W,'DragTargetPos');
    RegisterPropertyHelper(@TDragObjectDragTarget_R,@TDragObjectDragTarget_W,'DragTarget');
    RegisterPropertyHelper(@TDragObjectMouseDeltaX_R,nil,'MouseDeltaX');
    RegisterPropertyHelper(@TDragObjectMouseDeltaY_R,nil,'MouseDeltaY');
{$ENDIF}
{$ENDIF}
  end;
end;

{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TSizeConstraints'}{$ENDIF}
procedure RIRegisterTSizeConstraints(cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TSizeConstraints);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'Controls'}{$ENDIF}
procedure RIRegister_Controls(Cl: TPSRuntimeClassImporter);
begin
  RIRegisterTControl(Cl);
  RIRegisterTWinControl(Cl);
  RIRegisterTGraphicControl(cl);
  RIRegisterTCustomControl(cl);
  RIRegister_TDragObject(cl);
  RIRegisterTSizeConstraints(cl);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

// PS_MINIVCL changes by Martijn Laan


end.
