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

unit CnScript_Controls;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 Controls 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Graphics, Controls, ImgList, CommCtrl, Menus,
  uPSComponent, uPSRuntime, uPSCompiler;

type
  TPSImport_Controls = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TMouse(CL: TPSPascalCompiler);
procedure SIRegister_TImageList(CL: TPSPascalCompiler);
procedure SIRegister_TDragImageList(CL: TPSPascalCompiler);
procedure SIRegister_TCustomImageList(CL: TPSPascalCompiler);
procedure SIRegister_TCustomControl(CL: TPSPascalCompiler);
procedure SIRegister_TGraphicControl(CL: TPSPascalCompiler);
procedure SIRegister_TWinControl(CL: TPSPascalCompiler);
procedure SIRegister_TControl(CL: TPSPascalCompiler);
procedure SIRegister_TSizeConstraints(CL: TPSPascalCompiler);
procedure SIRegister_TDragObject(CL: TPSPascalCompiler);
procedure SIRegister_Controls(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_Controls_Routines(S: TPSExec);
procedure RIRegister_TMouse(CL: TPSRuntimeClassImporter);
procedure RIRegister_TImageList(CL: TPSRuntimeClassImporter);
procedure RIRegister_TDragImageList(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomImageList(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomControl(CL: TPSRuntimeClassImporter);
procedure RIRegister_TGraphicControl(CL: TPSRuntimeClassImporter);
procedure RIRegister_TWinControl(CL: TPSRuntimeClassImporter);
procedure RIRegister_TControl(CL: TPSRuntimeClassImporter);
procedure RIRegister_TSizeConstraints(CL: TPSRuntimeClassImporter);
procedure RIRegister_TDragObject(CL: TPSRuntimeClassImporter);
procedure RIRegister_Controls(CL: TPSRuntimeClassImporter);

implementation

type
  TControlAccess = class(TControl);

(* === compile-time registration functions === *)

procedure SIRegister_TMouse(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOBJECT', 'TMouse') do
  with CL.AddClass(CL.FindClass('TObject'), TMouse) do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure SettingChanged( Setting : Integer)');
    RegisterProperty('Capture', 'HWND', iptrw);
    RegisterProperty('CursorPos', 'TPoint', iptrw);
    RegisterProperty('DragImmediate', 'Boolean', iptrw);
    RegisterProperty('DragThreshold', 'Integer', iptrw);
    RegisterProperty('MousePresent', 'Boolean', iptr);
    RegisterProperty('RegWheelMessage', 'UINT', iptr);
    RegisterProperty('WheelPresent', 'Boolean', iptr);
    RegisterProperty('WheelScrollLines', 'Integer', iptr);
  end;
end;

procedure SIRegister_TImageList(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TDragImageList', 'TImageList') do
  with CL.AddClass(CL.FindClass('TDragImageList'), TImageList) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TDragImageList(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomImageList', 'TDragImageList') do
  with CL.AddClass(CL.FindClass('TCustomImageList'), TDragImageList) do
  begin
    RegisterMethod('Function BeginDrag( Window : HWND; X, Y : Integer) : Boolean');
    RegisterMethod('Function DragLock( Window : HWND; XPos, YPos : Integer) : Boolean');
    RegisterMethod('Function DragMove( X, Y : Integer) : Boolean');
    RegisterMethod('Procedure DragUnlock');
    RegisterMethod('Function EndDrag : Boolean');
    RegisterMethod('Procedure HideDragImage');
    RegisterMethod('Function SetDragImage( Index, HotSpotX, HotSpotY : Integer) : Boolean');
    RegisterMethod('Procedure ShowDragImage');
    RegisterProperty('DragCursor', 'TCursor', iptrw);
    RegisterProperty('Dragging', 'Boolean', iptr);
  end;
end;

procedure SIRegister_TCustomImageList(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TCustomImageList') do
  with CL.AddClass(CL.FindClass('TComponent'), TCustomImageList) do
  begin
    RegisterMethod('Constructor CreateSize( AWidth, AHeight : Integer)');
    RegisterMethod('Function Add( Image, Mask : TBitmap) : Integer');
    RegisterMethod('Function AddIcon( Image : TIcon) : Integer');
    RegisterMethod('Procedure AddImages( Value : TCustomImageList)');
    RegisterMethod('Function AddMasked( Image : TBitmap; MaskColor : TColor) : Integer');
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure Delete( Index : Integer)');
    RegisterMethod('Procedure Draw( Canvas : TCanvas; X, Y, Index : Integer; Enabled : Boolean);');
    RegisterMethod('Procedure DrawOverlay( Canvas : TCanvas; X, Y : Integer; ImageIndex : Integer; Overlay : TOverlay; Enabled : Boolean);');
    RegisterMethod('Function FileLoad( ResType : TResType; const Name : string; MaskColor : TColor) : Boolean');
    RegisterMethod('Function GetBitmap( Index : Integer; Image : TBitmap) : Boolean');
    RegisterMethod('Function GetHotSpot : TPoint');
    RegisterMethod('Procedure GetIcon( Index : Integer; Image : TIcon);');
    RegisterMethod('Function GetImageBitmap : HBITMAP');
    RegisterMethod('Function GetMaskBitmap : HBITMAP');
    RegisterMethod('Function HandleAllocated : Boolean');
    RegisterMethod('Procedure Insert( Index : Integer; Image, Mask : TBitmap)');
    RegisterMethod('Procedure InsertIcon( Index : Integer; Image : TIcon)');
    RegisterMethod('Procedure InsertMasked( Index : Integer; Image : TBitmap; MaskColor : TColor)');
    RegisterMethod('Procedure Move( CurIndex, NewIndex : Integer)');
    RegisterMethod('Function Overlay( ImageIndex : Integer; Overlay : TOverlay) : Boolean');
    RegisterMethod('Procedure Replace( Index : Integer; Image, Mask : TBitmap)');
    RegisterMethod('Procedure ReplaceIcon( Index : Integer; Image : TIcon)');
    RegisterMethod('Procedure ReplaceMasked( Index : Integer; NewImage : TBitmap; MaskColor : TColor)');
    RegisterProperty('Count', 'Integer', iptr);
    RegisterProperty('Handle', 'HImageList', iptrw);
    RegisterProperty('AllocBy', 'Integer', iptrw);
    RegisterProperty('BlendColor', 'TColor', iptrw);
    RegisterProperty('BkColor', 'TColor', iptrw);
    RegisterProperty('DrawingStyle', 'TDrawingStyle', iptrw);
    RegisterProperty('Height', 'Integer', iptrw);
    RegisterProperty('ImageType', 'TImageType', iptrw);
    RegisterProperty('Masked', 'Boolean', iptrw);
    RegisterProperty('ShareImages', 'Boolean', iptrw);
    RegisterProperty('Width', 'Integer', iptrw);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
  end;
end;

procedure SIRegister_TCustomControl(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCustomControl') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCustomControl) do
  begin
  end;
end;

procedure SIRegister_TGraphicControl(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TControl', 'TGraphicControl') do
  with CL.AddClass(CL.FindClass('TControl'), TGraphicControl) do
  begin
  end;
end;

procedure SIRegister_TWinControl(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TControl', 'TWinControl') do
  with CL.AddClass(CL.FindClass('TControl'), TWinControl) do
  begin
    RegisterMethod('Constructor CreateParented( ParentWindow : HWnd)');
    RegisterMethod('Procedure Broadcast( var Message : TMessage)');
    RegisterMethod('Function CanFocus : Boolean');
    RegisterMethod('Function ContainsControl( Control : TControl) : Boolean');
    RegisterMethod('Function ControlAtPos( const Pos : TPoint; AllowDisabled : Boolean; AllowWinControls : Boolean) : TControl');
    RegisterMethod('Procedure DisableAlign');
    RegisterProperty('DockClientCount', 'Integer', iptr);
    RegisterProperty('DockClients', 'TControl Integer', iptr);
    RegisterMethod('Procedure DockDrop( Source : TDragDockObject; X, Y : Integer)');
    RegisterProperty('DoubleBuffered', 'Boolean', iptrw);
    RegisterMethod('Procedure EnableAlign');
    RegisterMethod('Function FindChildControl( const ControlName : string) : TControl');
    RegisterMethod('Procedure FlipChildren( AllLevels : Boolean)');
    RegisterMethod('Function Focused : Boolean');
    RegisterMethod('Procedure GetTabOrderList( List : TList)');
    RegisterMethod('Function HandleAllocated : Boolean');
    RegisterMethod('Procedure HandleNeeded');
    RegisterMethod('Procedure InsertControl( AControl : TControl)');
    RegisterMethod('Procedure MouseWheelHandler( var Message : TMessage)');
    RegisterMethod('Procedure PaintTo( DC : HDC; X, Y : Integer)');
    RegisterMethod('Procedure RemoveControl( AControl : TControl)');
    RegisterMethod('Procedure Realign');
    RegisterMethod('Procedure ScaleBy( M, D : Integer)');
    RegisterMethod('Procedure ScrollBy( DeltaX, DeltaY : Integer)');
    RegisterMethod('Procedure SetFocus');
    RegisterMethod('Procedure UpdateControlState');
    RegisterProperty('VisibleDockClientCount', 'Integer', iptr);
    RegisterProperty('Brush', 'TBrush', iptr);
    RegisterProperty('Controls', 'TControl Integer', iptr);
    RegisterProperty('ControlCount', 'Integer', iptr);
    RegisterProperty('Handle', 'HWnd', iptr);
    RegisterProperty('ParentWindow', 'HWnd', iptrw);
    RegisterProperty('Showing', 'Boolean', iptr);
    RegisterProperty('TabOrder', 'TTabOrder', iptrw);
    RegisterProperty('TabStop', 'Boolean', iptrw);
    RegisterProperty('HelpContext', 'THelpContext', iptrw);
  end;
end;

procedure SIRegister_TControl(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TControl') do
  with CL.AddClass(CL.FindClass('TComponent'), TControl) do
  begin
    RegisterMethod('Procedure BeginDrag( Immediate : Boolean; Threshold : Integer)');
    RegisterMethod('Procedure BringToFront');
    RegisterMethod('Function ClientToScreen( const Point : TPoint) : TPoint');
    RegisterMethod('Procedure Dock( NewDockSite : TWinControl; ARect : TRect)');
    RegisterMethod('Function Dragging : Boolean');
    RegisterMethod('Procedure DragDrop( Source : TObject; X, Y : Integer)');
    RegisterMethod('Function DrawTextBiDiModeFlags( Flags : Longint) : Longint');
    RegisterMethod('Function DrawTextBiDiModeFlagsReadingOnly : Longint');
    RegisterProperty('Enabled', 'Boolean', iptrw);
    RegisterMethod('Procedure EndDrag( Drop : Boolean)');
    RegisterMethod('Function GetControlsAlignment : TAlignment');
    RegisterMethod('Function GetTextBuf( Buffer : PChar; BufSize : Integer) : Integer');
    RegisterMethod('Function GetTextLen : Integer');
    RegisterMethod('Procedure Hide');
    RegisterMethod('Procedure InitiateAction');
    RegisterMethod('Procedure Invalidate');
    RegisterMethod('Function IsRightToLeft : Boolean');
    RegisterMethod('Function ManualDock( NewDockSite : TWinControl; DropControl : TControl; ControlSide : TAlign) : Boolean');
    RegisterMethod('Function ManualFloat( ScreenPos : TRect) : Boolean');
    RegisterMethod('Function Perform( Msg : Cardinal; WParam, LParam : Longint) : Longint');
    RegisterMethod('Procedure Refresh');
    RegisterMethod('Procedure Repaint');
    RegisterMethod('Function ReplaceDockedControl( Control : TControl; NewDockSite : TWinControl; DropControl : TControl; ControlSide : TAlign) : Boolean');
    RegisterMethod('Function ScreenToClient( const Point : TPoint) : TPoint');
    RegisterMethod('Procedure SendToBack');
    RegisterMethod('Procedure SetBounds( ALeft, ATop, AWidth, AHeight : Integer)');
    RegisterMethod('Procedure SetTextBuf( Buffer : PChar)');
    RegisterMethod('Procedure Show');
    RegisterMethod('Procedure Update');
    RegisterMethod('Function UseRightToLeftAlignment : Boolean');
    RegisterMethod('Function UseRightToLeftReading : Boolean');
    RegisterMethod('Function UseRightToLeftScrollBar : Boolean');
    RegisterProperty('Action', 'TBasicAction', iptrw);
    RegisterProperty('Align', 'TAlign', iptrw);
    RegisterProperty('Anchors', 'TAnchors', iptrw);
    RegisterProperty('BiDiMode', 'TBiDiMode', iptrw);
    RegisterProperty('BoundsRect', 'TRect', iptrw);
{$IFDEF UNICODE}
    // D2009 下 Caption 不会自动注册
    RegisterProperty('Caption', 'TCaption', iptrw);
{$ENDIF}
    RegisterProperty('ClientHeight', 'Integer', iptrw);
    RegisterProperty('ClientOrigin', 'TPoint', iptr);
    RegisterProperty('ClientRect', 'TRect', iptr);
    RegisterProperty('ClientWidth', 'Integer', iptrw);
    RegisterProperty('Constraints', 'TSizeConstraints', iptrw);
    RegisterProperty('ControlState', 'TControlState', iptrw);
    RegisterProperty('ControlStyle', 'TControlStyle', iptrw);
    RegisterProperty('DockOrientation', 'TDockOrientation', iptrw);
    RegisterProperty('Floating', 'Boolean', iptr);
    RegisterProperty('FloatingDockSiteClass', 'TWinControlClass', iptrw);
    RegisterProperty('HostDockSite', 'TWinControl', iptrw);
    RegisterProperty('LRDockWidth', 'Integer', iptrw);
    RegisterProperty('Parent', 'TWinControl', iptrw);
    RegisterProperty('ShowHint', 'Boolean', iptrw);
    RegisterProperty('TBDockHeight', 'Integer', iptrw);
    RegisterProperty('UndockHeight', 'Integer', iptrw);
    RegisterProperty('UndockWidth', 'Integer', iptrw);
    RegisterProperty('Visible', 'Boolean', iptrw);
    RegisterProperty('WindowProc', 'TWndMethod', iptrw);
    RegisterProperty('Left', 'Integer', iptrw);
    RegisterProperty('Top', 'Integer', iptrw);
    RegisterProperty('Width', 'Integer', iptrw);
    RegisterProperty('Height', 'Integer', iptrw);
    RegisterProperty('Cursor', 'TCursor', iptrw);
    RegisterProperty('Hint', 'string', iptrw);
  end;
end;

procedure SIRegister_TSizeConstraints(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TSizeConstraints') do
  with CL.AddClass(CL.FindClass('TPersistent'), TSizeConstraints) do
  begin
    RegisterMethod('Constructor Create( Control : TControl)');
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
    RegisterProperty('MaxHeight', 'TConstraintSize', iptrw);
    RegisterProperty('MaxWidth', 'TConstraintSize', iptrw);
    RegisterProperty('MinHeight', 'TConstraintSize', iptrw);
    RegisterProperty('MinWidth', 'TConstraintSize', iptrw);
  end;
end;

procedure SIRegister_TDragObject(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TDragObject') do
  with CL.AddClass(CL.FindClass('TObject'), TDragObject) do
  begin
    RegisterMethod('Procedure Assign( Source : TDragObject)');
    RegisterMethod('Function GetName : string');
    RegisterMethod('Procedure HideDragImage');
    RegisterMethod('Function Instance : THandle');
    RegisterMethod('Procedure ShowDragImage');
    RegisterProperty('Cancelling', 'Boolean', iptrw);
    RegisterProperty('DragHandle', 'HWND', iptrw);
    RegisterProperty('DragPos', 'TPoint', iptrw);
    RegisterProperty('DragTargetPos', 'TPoint', iptrw);
    RegisterProperty('DragTarget', 'Pointer', iptrw);
    RegisterProperty('MouseDeltaX', 'Double', iptr);
    RegisterProperty('MouseDeltaY', 'Double', iptr);
  end;
end;

procedure SIRegister_Controls(CL: TPSPascalCompiler);
begin
  CL.AddConstantN('mrNone', 'LongInt').SetInt(0);
  CL.AddConstantN('mrOk', 'Integer').SetInt(idOk);
  CL.AddConstantN('mrCancel', 'Integer').SetInt(idCancel);
  CL.AddConstantN('mrAbort', 'Integer').SetInt(idAbort);
  CL.AddConstantN('mrRetry', 'Integer').SetInt(idRetry);
  CL.AddConstantN('mrIgnore', 'Integer').SetInt(idIgnore);
  CL.AddConstantN('mrYes', 'Integer').SetInt(idYes);
  CL.AddConstantN('mrNo', 'Integer').SetInt(idNo);
  CL.AddConstantN('mrAll', 'LongInt').SetInt(mrNo + 1);
  CL.AddConstantN('mrNoToAll', 'LongInt').SetInt(mrAll + 1);
  CL.AddConstantN('mrYesToAll', 'LongInt').SetInt(mrNoToAll + 1);
  CL.AddTypeS('TCursor', 'ShortInt');
  CL.AddConstantN('crDefault', 'LongInt').SetInt(TCursor(0));
  CL.AddConstantN('crNone', 'LongInt').SetInt(TCursor(-1));
  CL.AddConstantN('crArrow', 'LongInt').SetInt(TCursor(-2));
  CL.AddConstantN('crCross', 'LongInt').SetInt(TCursor(-3));
  CL.AddConstantN('crIBeam', 'LongInt').SetInt(TCursor(-4));
  CL.AddConstantN('crSize', 'LongInt').SetInt(TCursor(-22));
  CL.AddConstantN('crSizeNESW', 'LongInt').SetInt(TCursor(-6));
  CL.AddConstantN('crSizeNS', 'LongInt').SetInt(TCursor(-7));
  CL.AddConstantN('crSizeNWSE', 'LongInt').SetInt(TCursor(-8));
  CL.AddConstantN('crSizeWE', 'LongInt').SetInt(TCursor(-9));
  CL.AddConstantN('crUpArrow', 'LongInt').SetInt(TCursor(-10));
  CL.AddConstantN('crHourGlass', 'LongInt').SetInt(TCursor(-11));
  CL.AddConstantN('crDrag', 'LongInt').SetInt(TCursor(-12));
  CL.AddConstantN('crNoDrop', 'LongInt').SetInt(TCursor(-13));
  CL.AddConstantN('crHSplit', 'LongInt').SetInt(TCursor(-14));
  CL.AddConstantN('crVSplit', 'LongInt').SetInt(TCursor(-15));
  CL.AddConstantN('crMultiDrag', 'LongInt').SetInt(TCursor(-16));
  CL.AddConstantN('crSQLWait', 'LongInt').SetInt(TCursor(-17));
  CL.AddConstantN('crNo', 'LongInt').SetInt(TCursor(-18));
  CL.AddConstantN('crAppStart', 'LongInt').SetInt(TCursor(-19));
  CL.AddConstantN('crHelp', 'LongInt').SetInt(TCursor(-20));
  CL.AddConstantN('crHandPoint', 'LongInt').SetInt(TCursor(-21));
  CL.AddConstantN('crSizeAll', 'LongInt').SetInt(TCursor(-22));
  CL.AddClass(CL.FindClass('TObject'), TDragObject);
  CL.AddClass(CL.FindClass('TComponent'), TControl);
  CL.AddClass(CL.FindClass('TControl'), TWinControl);
  CL.AddClass(CL.FindClass('TComponent'), TCustomImageList);
  CL.AddClass(CL.FindClass('TCustomImageList'), TDragImageList);
  CL.AddTypeS('TAlign', '( alNone, alTop, alBottom, alLeft, alRight, alClient )');
  CL.AddTypeS('TAlignSet', 'set of TAlign');
  SIRegister_TDragObject(CL);
  CL.AddTypeS('TControlStateE', '( csLButtonDown, csClicked, csPalette, csReadi'
    + 'ngState, csAlignmentNeeded, csFocusing, csCreating, csPaintCopy, csCustomP'
    + 'aint, csDestroyingHandle, csDocking )');
  CL.AddTypeS('TControlState', 'set of TControlStateE');
  CL.AddTypeS('TControlStyleE', '( csAcceptsControls, csCaptureMouse, csDesignI'
    + 'nteractive, csClickEvents, csFramed, csSetCaption, csOpaque, csDoubleClick'
    + 's, csFixedWidth, csFixedHeight, csNoDesignVisible, csReplicatable, csNoStd'
    + 'Events, csDisplayDragImage, csReflector, csActionClient, csMenuEvents )');
  CL.AddTypeS('TControlStyle', 'set of TControlStyleE');
  CL.AddTypeS('TMouseButton', '( mbLeft, mbRight, mbMiddle )');
  CL.AddTypeS('TDragMode', '( dmManual, dmAutomatic )');
  CL.AddTypeS('TDragState', '( dsDragEnter, dsDragLeave, dsDragMove )');
  CL.AddTypeS('TDragKind', '( dkDrag, dkDock )');
  CL.AddTypeS('TTabOrder', 'Integer');
  CL.AddTypeS('TCaption', 'string');
  CL.AddTypeS('TDate', 'TDateTime');
  CL.AddTypeS('TTime', 'TDateTime');
  CL.AddTypeS('TScalingFlag', '( sfLeft, sfTop, sfWidth, sfHeight, sfFont )');
  CL.AddTypeS('TScalingFlags', 'set of TScalingFlag');
  CL.AddTypeS('TAnchorKind', '( akLeft, akTop, akRight, akBottom )');
  CL.AddTypeS('TAnchors', 'set of TAnchorKind');
  CL.AddTypeS('TConstraintSize', 'Integer');
  SIRegister_TSizeConstraints(CL);
  CL.AddTypeS('TMouseEvent', 'Procedure ( Sender : TObject; Button : TMouseButt'
    + 'on; Shift : TShiftState; X, Y : Integer)');
  CL.AddTypeS('TMouseMoveEvent', 'Procedure ( Sender : TObject; Shift : TShiftS'
    + 'tate; X, Y : Integer)');
  CL.AddTypeS('TKeyEvent', 'Procedure ( Sender : TObject; var Key : Word; Shift'
    + ' : TShiftState)');
  CL.AddTypeS('TKeyPressEvent', 'Procedure ( Sender : TObject; var Key : Char)');
  CL.AddTypeS('TCanResizeEvent', 'Procedure ( Sender : TObject; var NewWidth, N'
    + 'ewHeight : Integer; var Resize : Boolean)');
  CL.AddTypeS('TConstrainedResizeEvent', 'Procedure ( Sender : TObject; var Min'
    + 'Width, MinHeight, MaxWidth, MaxHeight : Integer)');
  CL.AddTypeS('TMouseWheelEvent', 'Procedure ( Sender : TObject; Shift : TShift'
    + 'State; WheelDelta : Integer; MousePos : TPoint; var Handled : Boolean)');
  CL.AddTypeS('TMouseWheelUpDownEvent', 'Procedure ( Sender : TObject; Shift : '
    + 'TShiftState; MousePos : TPoint; var Handled : Boolean)');
  CL.AddTypeS('TContextPopupEvent', 'Procedure ( Sender : TObject; MousePos : T'
    + 'Point; var Handled : Boolean)');
  CL.AddTypeS('TWndMethod', 'Procedure ( var Message : TMessage)');
  CL.AddTypeS('TDockOrientation', '( doNoOrient, doHorizontal, doVertical )');
  SIRegister_TControl(CL);
  CL.AddTypeS('TImeMode', '( imDisable, imClose, imOpen, imDontCare, imSAlpha, '
    + 'imAlpha, imHira, imSKata, imKata, imChinese, imSHanguel, imHanguel )');
  CL.AddTypeS('TImeName', 'string');
  CL.AddTypeS('TBorderWidth', 'Integer');
  CL.AddTypeS('TBevelCut', '( bvNone, bvLowered, bvRaised, bvSpace )');
  CL.AddTypeS('TBevelEdge', '( beLeft, beTop, beRight, beBottom )');
  CL.AddTypeS('TBevelEdges', 'set of TBevelEdge');
  CL.AddTypeS('TBevelKind', '( bkNone, bkTile, bkSoft, bkFlat )');
  CL.AddTypeS('TBevelWidth', 'Integer');
  SIRegister_TWinControl(CL);
  SIRegister_TGraphicControl(CL);
  SIRegister_TCustomControl(CL);
  CL.AddTypeS('HIMAGELIST', 'THandle');
  CL.AddTypeS('TDrawingStyle', '( dsFocus, dsSelected, dsNormal, dsTransparent '
    + ')');
  CL.AddTypeS('TImageType', '( itImage, itMask )');
  CL.AddTypeS('TResType', '( rtBitmap, rtCursor, rtIcon )');
  CL.AddTypeS('TOverlay', 'Integer');
  CL.AddTypeS('TLoadResource', '( lrDefaultColor, lrDefaultSize, lrFromFile, lr'
    + 'Map3DColors, lrTransparent, lrMonoChrome )');
  CL.AddTypeS('TLoadResources', 'set of TLoadResource');
  CL.AddTypeS('TImageIndex', 'Integer');
  SIRegister_TCustomImageList(CL);
  SIRegister_TDragImageList(CL);
  SIRegister_TImageList(CL);
  SIRegister_TMouse(CL);
  CL.AddDelphiFunction('Function Mouse : TMouse;');
  CL.AddDelphiFunction('Function CursorToString( Cursor : TCursor) : string');
  CL.AddDelphiFunction('Function StringToCursor( const S : string) : TCursor');
  CL.AddDelphiFunction('Procedure GetCursorValues( Proc : TGetStrProc)');
  CL.AddDelphiFunction('Function CursorToIdent( Cursor : Longint; var Ident : string) : Boolean');
  CL.AddDelphiFunction('Function IdentToCursor( const Ident : string; var Cursor : Longint) : Boolean');
  CL.AddDelphiFunction('Function GetShortHint( const Hint : string) : string');
  CL.AddDelphiFunction('Function GetLongHint( const Hint : string) : string');
  CL.AddDelphiFunction('Function SendAppMessage( Msg : Cardinal; WParam, LParam : Longint) : Longint');
  CL.AddDelphiFunction('Procedure MoveWindowOrg( DC : HDC; DX, DY : Integer)');
  CL.AddDelphiFunction('Procedure SetImeMode( hWnd : HWND; Mode : TImeMode)');
  CL.AddDelphiFunction('Procedure SetImeName( Name : TImeName)');
end;

(* === run-time registration functions === *)

function Mouse_P: TMouse;
begin
  Result := Controls.Mouse;
end;

procedure TMouseWheelScrollLines_R(Self: TMouse; var T: Integer);
begin
  T := Self.WheelScrollLines;
end;

procedure TMouseWheelPresent_R(Self: TMouse; var T: Boolean);
begin
  T := Self.WheelPresent;
end;

procedure TMouseRegWheelMessage_R(Self: TMouse; var T: UINT);
begin
  T := Self.RegWheelMessage;
end;

procedure TMouseMousePresent_R(Self: TMouse; var T: Boolean);
begin
  T := Self.MousePresent;
end;

procedure TMouseDragThreshold_W(Self: TMouse; const T: Integer);
begin
  Self.DragThreshold := T;
end;

procedure TMouseDragThreshold_R(Self: TMouse; var T: Integer);
begin
  T := Self.DragThreshold;
end;

procedure TMouseDragImmediate_W(Self: TMouse; const T: Boolean);
begin
  Self.DragImmediate := T;
end;

procedure TMouseDragImmediate_R(Self: TMouse; var T: Boolean);
begin
  T := Self.DragImmediate;
end;

procedure TMouseCursorPos_W(Self: TMouse; const T: TPoint);
begin
  Self.CursorPos := T;
end;

procedure TMouseCursorPos_R(Self: TMouse; var T: TPoint);
begin
  T := Self.CursorPos;
end;

procedure TMouseCapture_W(Self: TMouse; const T: HWND);
begin
  Self.Capture := T;
end;

procedure TMouseCapture_R(Self: TMouse; var T: HWND);
begin
  T := Self.Capture;
end;

procedure TDragImageListDragging_R(Self: TDragImageList; var T: Boolean);
begin
  T := Self.Dragging;
end;

procedure TDragImageListDragCursor_W(Self: TDragImageList; const T: TCursor);
begin
  Self.DragCursor := T;
end;

procedure TDragImageListDragCursor_R(Self: TDragImageList; var T: TCursor);
begin
  T := Self.DragCursor;
end;

procedure TCustomImageListOnChange_W(Self: TCustomImageList; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TCustomImageListOnChange_R(Self: TCustomImageList; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TCustomImageListWidth_W(Self: TCustomImageList; const T: Integer);
begin
  Self.Width := T;
end;

procedure TCustomImageListWidth_R(Self: TCustomImageList; var T: Integer);
begin
  T := Self.Width;
end;

procedure TCustomImageListShareImages_W(Self: TCustomImageList; const T: Boolean);
begin
  Self.ShareImages := T;
end;

procedure TCustomImageListShareImages_R(Self: TCustomImageList; var T: Boolean);
begin
  T := Self.ShareImages;
end;

procedure TCustomImageListMasked_W(Self: TCustomImageList; const T: Boolean);
begin
  Self.Masked := T;
end;

procedure TCustomImageListMasked_R(Self: TCustomImageList; var T: Boolean);
begin
  T := Self.Masked;
end;

procedure TCustomImageListImageType_W(Self: TCustomImageList; const T: TImageType);
begin
  Self.ImageType := T;
end;

procedure TCustomImageListImageType_R(Self: TCustomImageList; var T: TImageType);
begin
  T := Self.ImageType;
end;

procedure TCustomImageListHeight_W(Self: TCustomImageList; const T: Integer);
begin
  Self.Height := T;
end;

procedure TCustomImageListHeight_R(Self: TCustomImageList; var T: Integer);
begin
  T := Self.Height;
end;

procedure TCustomImageListDrawingStyle_W(Self: TCustomImageList; const T: TDrawingStyle);
begin
  Self.DrawingStyle := T;
end;

procedure TCustomImageListDrawingStyle_R(Self: TCustomImageList; var T: TDrawingStyle);
begin
  T := Self.DrawingStyle;
end;

procedure TCustomImageListBkColor_W(Self: TCustomImageList; const T: TColor);
begin
  Self.BkColor := T;
end;

procedure TCustomImageListBkColor_R(Self: TCustomImageList; var T: TColor);
begin
  T := Self.BkColor;
end;

procedure TCustomImageListBlendColor_W(Self: TCustomImageList; const T: TColor);
begin
  Self.BlendColor := T;
end;

procedure TCustomImageListBlendColor_R(Self: TCustomImageList; var T: TColor);
begin
  T := Self.BlendColor;
end;

procedure TCustomImageListAllocBy_W(Self: TCustomImageList; const T: Integer);
begin
  Self.AllocBy := T;
end;

procedure TCustomImageListAllocBy_R(Self: TCustomImageList; var T: Integer);
begin
  T := Self.AllocBy;
end;

procedure TCustomImageListHandle_W(Self: TCustomImageList; const T: HImageList);
begin
  Self.Handle := T;
end;

procedure TCustomImageListHandle_R(Self: TCustomImageList; var T: HImageList);
begin
  T := Self.Handle;
end;

procedure TCustomImageListCount_R(Self: TCustomImageList; var T: Integer);
begin
  T := Self.Count;
end;

procedure TCustomImageListGetIcon_P(Self: TCustomImageList; Index: Integer; Image: TIcon);
begin
  Self.GetIcon(Index, Image);
end;

procedure TCustomImageListDrawOverlay_P(Self: TCustomImageList; Canvas: TCanvas; X, Y: Integer; ImageIndex: Integer; Overlay: TOverlay; Enabled: Boolean);
begin
  Self.DrawOverlay(Canvas, X, Y, ImageIndex, Overlay, Enabled);
end;

procedure TCustomImageListDraw_P(Self: TCustomImageList; Canvas: TCanvas; X, Y, Index: Integer; Enabled: Boolean);
begin
  Self.Draw(Canvas, X, Y, Index, Enabled);
end;

procedure TWinControlHelpContext_W(Self: TWinControl; const T: THelpContext);
begin
  Self.HelpContext := T;
end;

procedure TWinControlHelpContext_R(Self: TWinControl; var T: THelpContext);
begin
  T := Self.HelpContext;
end;

procedure TWinControlTabStop_W(Self: TWinControl; const T: Boolean);
begin
  Self.TabStop := T;
end;

procedure TWinControlTabStop_R(Self: TWinControl; var T: Boolean);
begin
  T := Self.TabStop;
end;

procedure TWinControlTabOrder_W(Self: TWinControl; const T: TTabOrder);
begin
  Self.TabOrder := T;
end;

procedure TWinControlTabOrder_R(Self: TWinControl; var T: TTabOrder);
begin
  T := Self.TabOrder;
end;

procedure TWinControlShowing_R(Self: TWinControl; var T: Boolean);
begin
  T := Self.Showing;
end;

procedure TWinControlParentWindow_W(Self: TWinControl; const T: HWnd);
begin
  Self.ParentWindow := T;
end;

procedure TWinControlParentWindow_R(Self: TWinControl; var T: HWnd);
begin
  T := Self.ParentWindow;
end;

procedure TWinControlHandle_R(Self: TWinControl; var T: HWnd);
begin
  T := Self.Handle;
end;

procedure TWinControlControlCount_R(Self: TWinControl; var T: Integer);
begin
  T := Self.ControlCount;
end;

procedure TWinControlControls_R(Self: TWinControl; var T: TControl; const t1: Integer);
begin
  T := Self.Controls[t1];
end;

procedure TWinControlBrush_R(Self: TWinControl; var T: TBrush);
begin
  T := Self.Brush;
end;

procedure TWinControlVisibleDockClientCount_R(Self: TWinControl; var T: Integer);
begin
  T := Self.VisibleDockClientCount;
end;

procedure TWinControlDoubleBuffered_W(Self: TWinControl; const T: Boolean);
begin
  Self.DoubleBuffered := T;
end;

procedure TWinControlDoubleBuffered_R(Self: TWinControl; var T: Boolean);
begin
  T := Self.DoubleBuffered;
end;

procedure TWinControlDockClients_R(Self: TWinControl; var T: TControl; const t1: Integer);
begin
  T := Self.DockClients[t1];
end;

procedure TWinControlDockClientCount_R(Self: TWinControl; var T: Integer);
begin
  T := Self.DockClientCount;
end;

procedure TControlHint_W(Self: TControl; const T: string);
begin
  Self.Hint := T;
end;

procedure TControlHint_R(Self: TControl; var T: string);
begin
  T := Self.Hint;
end;

procedure TControlCursor_W(Self: TControl; const T: TCursor);
begin
  Self.Cursor := T;
end;

procedure TControlCursor_R(Self: TControl; var T: TCursor);
begin
  T := Self.Cursor;
end;

procedure TControlHeight_W(Self: TControl; const T: Integer);
begin
  Self.Height := T;
end;

procedure TControlHeight_R(Self: TControl; var T: Integer);
begin
  T := Self.Height;
end;

procedure TControlWidth_W(Self: TControl; const T: Integer);
begin
  Self.Width := T;
end;

procedure TControlWidth_R(Self: TControl; var T: Integer);
begin
  T := Self.Width;
end;

procedure TControlTop_W(Self: TControl; const T: Integer);
begin
  Self.Top := T;
end;

procedure TControlTop_R(Self: TControl; var T: Integer);
begin
  T := Self.Top;
end;

procedure TControlLeft_W(Self: TControl; const T: Integer);
begin
  Self.Left := T;
end;

procedure TControlLeft_R(Self: TControl; var T: Integer);
begin
  T := Self.Left;
end;

procedure TControlWindowProc_W(Self: TControl; const T: TWndMethod);
begin
  Self.WindowProc := T;
end;

procedure TControlWindowProc_R(Self: TControl; var T: TWndMethod);
begin
  T := Self.WindowProc;
end;

procedure TControlVisible_W(Self: TControl; const T: Boolean);
begin
  Self.Visible := T;
end;

procedure TControlVisible_R(Self: TControl; var T: Boolean);
begin
  T := Self.Visible;
end;

procedure TControlUndockWidth_W(Self: TControl; const T: Integer);
begin
  Self.UndockWidth := T;
end;

procedure TControlUndockWidth_R(Self: TControl; var T: Integer);
begin
  T := Self.UndockWidth;
end;

procedure TControlUndockHeight_W(Self: TControl; const T: Integer);
begin
  Self.UndockHeight := T;
end;

procedure TControlUndockHeight_R(Self: TControl; var T: Integer);
begin
  T := Self.UndockHeight;
end;

procedure TControlTBDockHeight_W(Self: TControl; const T: Integer);
begin
  Self.TBDockHeight := T;
end;

procedure TControlTBDockHeight_R(Self: TControl; var T: Integer);
begin
  T := Self.TBDockHeight;
end;

procedure TControlShowHint_W(Self: TControl; const T: Boolean);
begin
  Self.ShowHint := T;
end;

procedure TControlShowHint_R(Self: TControl; var T: Boolean);
begin
  T := Self.ShowHint;
end;

procedure TControlParent_W(Self: TControl; const T: TWinControl);
begin
  Self.Parent := T;
end;

procedure TControlParent_R(Self: TControl; var T: TWinControl);
begin
  T := Self.Parent;
end;

procedure TControlLRDockWidth_W(Self: TControl; const T: Integer);
begin
  Self.LRDockWidth := T;
end;

procedure TControlLRDockWidth_R(Self: TControl; var T: Integer);
begin
  T := Self.LRDockWidth;
end;

procedure TControlHostDockSite_W(Self: TControl; const T: TWinControl);
begin
  Self.HostDockSite := T;
end;

procedure TControlHostDockSite_R(Self: TControl; var T: TWinControl);
begin
  T := Self.HostDockSite;
end;

procedure TControlFloatingDockSiteClass_W(Self: TControl; const T: TWinControlClass);
begin
  Self.FloatingDockSiteClass := T;
end;

procedure TControlFloatingDockSiteClass_R(Self: TControl; var T: TWinControlClass);
begin
  T := Self.FloatingDockSiteClass;
end;

procedure TControlFloating_R(Self: TControl; var T: Boolean);
begin
  T := Self.Floating;
end;

procedure TControlDockOrientation_W(Self: TControl; const T: TDockOrientation);
begin
  Self.DockOrientation := T;
end;

procedure TControlDockOrientation_R(Self: TControl; var T: TDockOrientation);
begin
  T := Self.DockOrientation;
end;

procedure TControlControlStyle_W(Self: TControl; const T: TControlStyle);
begin
  Self.ControlStyle := T;
end;

procedure TControlControlStyle_R(Self: TControl; var T: TControlStyle);
begin
  T := Self.ControlStyle;
end;

procedure TControlControlState_W(Self: TControl; const T: TControlState);
begin
  Self.ControlState := T;
end;

procedure TControlControlState_R(Self: TControl; var T: TControlState);
begin
  T := Self.ControlState;
end;

procedure TControlConstraints_W(Self: TControl; const T: TSizeConstraints);
begin
  Self.Constraints := T;
end;

procedure TControlConstraints_R(Self: TControl; var T: TSizeConstraints);
begin
  T := Self.Constraints;
end;

procedure TControlClientWidth_W(Self: TControl; const T: Integer);
begin
  Self.ClientWidth := T;
end;

procedure TControlClientWidth_R(Self: TControl; var T: Integer);
begin
  T := Self.ClientWidth;
end;

procedure TControlClientRect_R(Self: TControl; var T: TRect);
begin
  T := Self.ClientRect;
end;

procedure TControlClientOrigin_R(Self: TControl; var T: TPoint);
begin
  T := Self.ClientOrigin;
end;

procedure TControlClientHeight_W(Self: TControl; const T: Integer);
begin
  Self.ClientHeight := T;
end;

procedure TControlClientHeight_R(Self: TControl; var T: Integer);
begin
  T := Self.ClientHeight;
end;

{$IFDEF UNICODE}
procedure TControlCaption_W(Self: TControl; const T: TCaption);
begin
  TControlAccess(Self).Caption := T;
end;

procedure TControlCaption_R(Self: TControl; var T: TCaption);
begin
  T := TControlAccess(Self).Caption;
end;
{$ENDIF}

procedure TControlBoundsRect_W(Self: TControl; const T: TRect);
begin
  Self.BoundsRect := T;
end;

procedure TControlBoundsRect_R(Self: TControl; var T: TRect);
begin
  T := Self.BoundsRect;
end;

procedure TControlBiDiMode_W(Self: TControl; const T: TBiDiMode);
begin
  Self.BiDiMode := T;
end;

procedure TControlBiDiMode_R(Self: TControl; var T: TBiDiMode);
begin
  T := Self.BiDiMode;
end;

procedure TControlAnchors_W(Self: TControl; const T: TAnchors);
begin
  Self.Anchors := T;
end;

procedure TControlAnchors_R(Self: TControl; var T: TAnchors);
begin
  T := Self.Anchors;
end;

procedure TControlAlign_W(Self: TControl; const T: TAlign);
begin
  Self.Align := T;
end;

procedure TControlAlign_R(Self: TControl; var T: TAlign);
begin
  T := Self.Align;
end;

procedure TControlAction_W(Self: TControl; const T: TBasicAction);
begin
  Self.Action := T;
end;

procedure TControlAction_R(Self: TControl; var T: TBasicAction);
begin
  T := Self.Action;
end;

procedure TControlEnabled_W(Self: TControl; const T: Boolean);
begin
  Self.Enabled := T;
end;

procedure TControlEnabled_R(Self: TControl; var T: Boolean);
begin
  T := Self.Enabled;
end;

procedure TSizeConstraintsMinWidth_W(Self: TSizeConstraints; const T: TConstraintSize);
begin
  Self.MinWidth := T;
end;

procedure TSizeConstraintsMinWidth_R(Self: TSizeConstraints; var T: TConstraintSize);
begin
  T := Self.MinWidth;
end;

procedure TSizeConstraintsMinHeight_W(Self: TSizeConstraints; const T: TConstraintSize);
begin
  Self.MinHeight := T;
end;

procedure TSizeConstraintsMinHeight_R(Self: TSizeConstraints; var T: TConstraintSize);
begin
  T := Self.MinHeight;
end;

procedure TSizeConstraintsMaxWidth_W(Self: TSizeConstraints; const T: TConstraintSize);
begin
  Self.MaxWidth := T;
end;

procedure TSizeConstraintsMaxWidth_R(Self: TSizeConstraints; var T: TConstraintSize);
begin
  T := Self.MaxWidth;
end;

procedure TSizeConstraintsMaxHeight_W(Self: TSizeConstraints; const T: TConstraintSize);
begin
  Self.MaxHeight := T;
end;

procedure TSizeConstraintsMaxHeight_R(Self: TSizeConstraints; var T: TConstraintSize);
begin
  T := Self.MaxHeight;
end;

procedure TSizeConstraintsOnChange_W(Self: TSizeConstraints; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TSizeConstraintsOnChange_R(Self: TSizeConstraints; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TDragObjectMouseDeltaY_R(Self: TDragObject; var T: Double);
begin
  T := Self.MouseDeltaY;
end;

procedure TDragObjectMouseDeltaX_R(Self: TDragObject; var T: Double);
begin
  T := Self.MouseDeltaX;
end;

procedure TDragObjectDragTarget_W(Self: TDragObject; const T: Pointer);
begin
  Self.DragTarget := T;
end;

procedure TDragObjectDragTarget_R(Self: TDragObject; var T: Pointer);
begin
  T := Self.DragTarget;
end;

procedure TDragObjectDragTargetPos_W(Self: TDragObject; const T: TPoint);
begin
  Self.DragTargetPos := T;
end;

procedure TDragObjectDragTargetPos_R(Self: TDragObject; var T: TPoint);
begin
  T := Self.DragTargetPos;
end;

procedure TDragObjectDragPos_W(Self: TDragObject; const T: TPoint);
begin
  Self.DragPos := T;
end;

procedure TDragObjectDragPos_R(Self: TDragObject; var T: TPoint);
begin
  T := Self.DragPos;
end;

procedure TDragObjectDragHandle_W(Self: TDragObject; const T: HWND);
begin
  Self.DragHandle := T;
end;

procedure TDragObjectDragHandle_R(Self: TDragObject; var T: HWND);
begin
  T := Self.DragHandle;
end;

procedure TDragObjectCancelling_W(Self: TDragObject; const T: Boolean);
begin
  Self.Cancelling := T;
end;

procedure TDragObjectCancelling_R(Self: TDragObject; var T: Boolean);
begin
  T := Self.Cancelling;
end;

procedure RIRegister_Controls_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@Mouse_P, 'Mouse', cdRegister);
  S.RegisterDelphiFunction(@CursorToString, 'CursorToString', cdRegister);
  S.RegisterDelphiFunction(@StringToCursor, 'StringToCursor', cdRegister);
  S.RegisterDelphiFunction(@GetCursorValues, 'GetCursorValues', cdRegister);
  S.RegisterDelphiFunction(@CursorToIdent, 'CursorToIdent', cdRegister);
  S.RegisterDelphiFunction(@IdentToCursor, 'IdentToCursor', cdRegister);
  S.RegisterDelphiFunction(@GetShortHint, 'GetShortHint', cdRegister);
  S.RegisterDelphiFunction(@GetLongHint, 'GetLongHint', cdRegister);
  S.RegisterDelphiFunction(@SendAppMessage, 'SendAppMessage', cdRegister);
  S.RegisterDelphiFunction(@MoveWindowOrg, 'MoveWindowOrg', cdRegister);
  S.RegisterDelphiFunction(@SetImeMode, 'SetImeMode', cdRegister);
  S.RegisterDelphiFunction(@SetImeName, 'SetImeName', cdRegister);
end;

procedure RIRegister_TMouse(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TMouse) do
  begin
    RegisterConstructor(@TMouse.Create, 'Create');
    RegisterMethod(@TMouse.SettingChanged, 'SettingChanged');
    RegisterPropertyHelper(@TMouseCapture_R, @TMouseCapture_W, 'Capture');
    RegisterPropertyHelper(@TMouseCursorPos_R, @TMouseCursorPos_W, 'CursorPos');
    RegisterPropertyHelper(@TMouseDragImmediate_R, @TMouseDragImmediate_W, 'DragImmediate');
    RegisterPropertyHelper(@TMouseDragThreshold_R, @TMouseDragThreshold_W, 'DragThreshold');
    RegisterPropertyHelper(@TMouseMousePresent_R, nil, 'MousePresent');
    RegisterPropertyHelper(@TMouseRegWheelMessage_R, nil, 'RegWheelMessage');
    RegisterPropertyHelper(@TMouseWheelPresent_R, nil, 'WheelPresent');
    RegisterPropertyHelper(@TMouseWheelScrollLines_R, nil, 'WheelScrollLines');
  end;
end;

procedure RIRegister_TImageList(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TImageList) do
  begin
  end;
end;

procedure RIRegister_TDragImageList(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TDragImageList) do
  begin
    RegisterMethod(@TDragImageList.BeginDrag, 'BeginDrag');
    RegisterMethod(@TDragImageList.DragLock, 'DragLock');
    RegisterMethod(@TDragImageList.DragMove, 'DragMove');
    RegisterMethod(@TDragImageList.DragUnlock, 'DragUnlock');
    RegisterMethod(@TDragImageList.EndDrag, 'EndDrag');
    RegisterMethod(@TDragImageList.HideDragImage, 'HideDragImage');
    RegisterMethod(@TDragImageList.SetDragImage, 'SetDragImage');
    RegisterMethod(@TDragImageList.ShowDragImage, 'ShowDragImage');
    RegisterPropertyHelper(@TDragImageListDragCursor_R, @TDragImageListDragCursor_W, 'DragCursor');
    RegisterPropertyHelper(@TDragImageListDragging_R, nil, 'Dragging');
  end;
end;

procedure RIRegister_TCustomImageList(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomImageList) do
  begin
    RegisterConstructor(@TCustomImageList.CreateSize, 'CreateSize');
    RegisterMethod(@TCustomImageList.Add, 'Add');
    RegisterMethod(@TCustomImageList.AddIcon, 'AddIcon');
    RegisterMethod(@TCustomImageList.AddImages, 'AddImages');
    RegisterMethod(@TCustomImageList.AddMasked, 'AddMasked');
    RegisterMethod(@TCustomImageList.Clear, 'Clear');
    RegisterMethod(@TCustomImageList.Delete, 'Delete');
    RegisterMethod(@TCustomImageListDraw_P, 'Draw');
    RegisterMethod(@TCustomImageListDrawOverlay_P, 'DrawOverlay');
    RegisterMethod(@TCustomImageList.FileLoad, 'FileLoad');
    RegisterMethod(@TCustomImageList.GetBitmap, 'GetBitmap');
    RegisterVirtualMethod(@TCustomImageList.GetHotSpot, 'GetHotSpot');
    RegisterMethod(@TCustomImageListGetIcon_P, 'GetIcon');
    RegisterMethod(@TCustomImageList.GetImageBitmap, 'GetImageBitmap');
    RegisterMethod(@TCustomImageList.GetMaskBitmap, 'GetMaskBitmap');
    RegisterMethod(@TCustomImageList.HandleAllocated, 'HandleAllocated');
    RegisterMethod(@TCustomImageList.Insert, 'Insert');
    RegisterMethod(@TCustomImageList.InsertIcon, 'InsertIcon');
    RegisterMethod(@TCustomImageList.InsertMasked, 'InsertMasked');
    RegisterMethod(@TCustomImageList.Move, 'Move');
    RegisterMethod(@TCustomImageList.Overlay, 'Overlay');
    RegisterMethod(@TCustomImageList.Replace, 'Replace');
    RegisterMethod(@TCustomImageList.ReplaceIcon, 'ReplaceIcon');
    RegisterMethod(@TCustomImageList.ReplaceMasked, 'ReplaceMasked');
    RegisterPropertyHelper(@TCustomImageListCount_R, nil, 'Count');
    RegisterPropertyHelper(@TCustomImageListHandle_R, @TCustomImageListHandle_W, 'Handle');
    RegisterPropertyHelper(@TCustomImageListAllocBy_R, @TCustomImageListAllocBy_W, 'AllocBy');
    RegisterPropertyHelper(@TCustomImageListBlendColor_R, @TCustomImageListBlendColor_W, 'BlendColor');
    RegisterPropertyHelper(@TCustomImageListBkColor_R, @TCustomImageListBkColor_W, 'BkColor');
    RegisterPropertyHelper(@TCustomImageListDrawingStyle_R, @TCustomImageListDrawingStyle_W, 'DrawingStyle');
    RegisterPropertyHelper(@TCustomImageListHeight_R, @TCustomImageListHeight_W, 'Height');
    RegisterPropertyHelper(@TCustomImageListImageType_R, @TCustomImageListImageType_W, 'ImageType');
    RegisterPropertyHelper(@TCustomImageListMasked_R, @TCustomImageListMasked_W, 'Masked');
    RegisterPropertyHelper(@TCustomImageListShareImages_R, @TCustomImageListShareImages_W, 'ShareImages');
    RegisterPropertyHelper(@TCustomImageListWidth_R, @TCustomImageListWidth_W, 'Width');
    RegisterPropertyHelper(@TCustomImageListOnChange_R, @TCustomImageListOnChange_W, 'OnChange');
  end;
end;

procedure RIRegister_TCustomControl(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomControl) do
  begin
  end;
end;

procedure RIRegister_TGraphicControl(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TGraphicControl) do
  begin
  end;
end;

procedure RIRegister_TWinControl(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TWinControl) do
  begin
    RegisterConstructor(@TWinControl.CreateParented, 'CreateParented');
    RegisterMethod(@TWinControl.Broadcast, 'Broadcast');
    RegisterVirtualMethod(@TWinControl.CanFocus, 'CanFocus');
    RegisterMethod(@TWinControl.ContainsControl, 'ContainsControl');
    RegisterMethod(@TWinControl.ControlAtPos, 'ControlAtPos');
    RegisterMethod(@TWinControl.DisableAlign, 'DisableAlign');
    RegisterPropertyHelper(@TWinControlDockClientCount_R, nil, 'DockClientCount');
    RegisterPropertyHelper(@TWinControlDockClients_R, nil, 'DockClients');
    RegisterVirtualMethod(@TWinControl.DockDrop, 'DockDrop');
    RegisterPropertyHelper(@TWinControlDoubleBuffered_R, @TWinControlDoubleBuffered_W, 'DoubleBuffered');
    RegisterMethod(@TWinControl.EnableAlign, 'EnableAlign');
    RegisterMethod(@TWinControl.FindChildControl, 'FindChildControl');
    RegisterVirtualMethod(@TWinControl.FlipChildren, 'FlipChildren');
    RegisterVirtualMethod(@TWinControl.Focused, 'Focused');
    RegisterVirtualMethod(@TWinControl.GetTabOrderList, 'GetTabOrderList');
    RegisterMethod(@TWinControl.HandleAllocated, 'HandleAllocated');
    RegisterMethod(@TWinControl.HandleNeeded, 'HandleNeeded');
    RegisterMethod(@TWinControl.InsertControl, 'InsertControl');
    RegisterVirtualMethod(@TWinControl.MouseWheelHandler, 'MouseWheelHandler');
    RegisterMethod(@TWinControl.PaintTo, 'PaintTo');
    RegisterMethod(@TWinControl.RemoveControl, 'RemoveControl');
    RegisterMethod(@TWinControl.Realign, 'Realign');
    RegisterMethod(@TWinControl.ScaleBy, 'ScaleBy');
    RegisterMethod(@TWinControl.ScrollBy, 'ScrollBy');
    RegisterVirtualMethod(@TWinControl.SetFocus, 'SetFocus');
    RegisterMethod(@TWinControl.UpdateControlState, 'UpdateControlState');
    RegisterPropertyHelper(@TWinControlVisibleDockClientCount_R, nil, 'VisibleDockClientCount');
    RegisterPropertyHelper(@TWinControlBrush_R, nil, 'Brush');
    RegisterPropertyHelper(@TWinControlControls_R, nil, 'Controls');
    RegisterPropertyHelper(@TWinControlControlCount_R, nil, 'ControlCount');
    RegisterPropertyHelper(@TWinControlHandle_R, nil, 'Handle');
    RegisterPropertyHelper(@TWinControlParentWindow_R, @TWinControlParentWindow_W, 'ParentWindow');
    RegisterPropertyHelper(@TWinControlShowing_R, nil, 'Showing');
    RegisterPropertyHelper(@TWinControlTabOrder_R, @TWinControlTabOrder_W, 'TabOrder');
    RegisterPropertyHelper(@TWinControlTabStop_R, @TWinControlTabStop_W, 'TabStop');
    RegisterPropertyHelper(@TWinControlHelpContext_R, @TWinControlHelpContext_W, 'HelpContext');
  end;
end;

procedure RIRegister_TControl(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TControl) do
  begin
    RegisterMethod(@TControl.BeginDrag, 'BeginDrag');
    RegisterMethod(@TControl.BringToFront, 'BringToFront');
    RegisterMethod(@TControl.ClientToScreen, 'ClientToScreen');
    RegisterVirtualMethod(@TControl.Dock, 'Dock');
    RegisterMethod(@TControl.Dragging, 'Dragging');
    RegisterVirtualMethod(@TControl.DragDrop, 'DragDrop');
    RegisterMethod(@TControl.DrawTextBiDiModeFlags, 'DrawTextBiDiModeFlags');
    RegisterMethod(@TControl.DrawTextBiDiModeFlagsReadingOnly, 'DrawTextBiDiModeFlagsReadingOnly');
    RegisterPropertyHelper(@TControlEnabled_R, @TControlEnabled_W, 'Enabled');
    RegisterMethod(@TControl.EndDrag, 'EndDrag');
    RegisterVirtualMethod(@TControl.GetControlsAlignment, 'GetControlsAlignment');
    RegisterMethod(@TControl.GetTextBuf, 'GetTextBuf');
    RegisterMethod(@TControl.GetTextLen, 'GetTextLen');
    RegisterMethod(@TControl.Hide, 'Hide');
    RegisterVirtualMethod(@TControl.InitiateAction, 'InitiateAction');
    RegisterVirtualMethod(@TControl.Invalidate, 'Invalidate');
    RegisterMethod(@TControl.IsRightToLeft, 'IsRightToLeft');
    RegisterMethod(@TControl.ManualDock, 'ManualDock');
    RegisterMethod(@TControl.ManualFloat, 'ManualFloat');
    RegisterMethod(@TControl.Perform, 'Perform');
    RegisterMethod(@TControl.Refresh, 'Refresh');
    RegisterVirtualMethod(@TControl.Repaint, 'Repaint');
    RegisterMethod(@TControl.ReplaceDockedControl, 'ReplaceDockedControl');
    RegisterMethod(@TControl.ScreenToClient, 'ScreenToClient');
    RegisterMethod(@TControl.SendToBack, 'SendToBack');
    RegisterVirtualMethod(@TControl.SetBounds, 'SetBounds');
    RegisterMethod(@TControl.SetTextBuf, 'SetTextBuf');
    RegisterMethod(@TControl.Show, 'Show');
    RegisterVirtualMethod(@TControl.Update, 'Update');
    RegisterVirtualMethod(@TControl.UseRightToLeftAlignment, 'UseRightToLeftAlignment');
    RegisterMethod(@TControl.UseRightToLeftReading, 'UseRightToLeftReading');
    RegisterMethod(@TControl.UseRightToLeftScrollBar, 'UseRightToLeftScrollBar');
    RegisterPropertyHelper(@TControlAction_R, @TControlAction_W, 'Action');
    RegisterPropertyHelper(@TControlAlign_R, @TControlAlign_W, 'Align');
    RegisterPropertyHelper(@TControlAnchors_R, @TControlAnchors_W, 'Anchors');
    RegisterPropertyHelper(@TControlBiDiMode_R, @TControlBiDiMode_W, 'BiDiMode');
    RegisterPropertyHelper(@TControlBoundsRect_R, @TControlBoundsRect_W, 'BoundsRect');
  {$IFDEF UNICODE}
    RegisterPropertyHelper(@TControlCaption_R, @TControlCaption_W, 'Caption');
  {$ENDIF}
    RegisterPropertyHelper(@TControlClientHeight_R, @TControlClientHeight_W, 'ClientHeight');
    RegisterPropertyHelper(@TControlClientOrigin_R, nil, 'ClientOrigin');
    RegisterPropertyHelper(@TControlClientRect_R, nil, 'ClientRect');
    RegisterPropertyHelper(@TControlClientWidth_R, @TControlClientWidth_W, 'ClientWidth');
    RegisterPropertyHelper(@TControlConstraints_R, @TControlConstraints_W, 'Constraints');
    RegisterPropertyHelper(@TControlControlState_R, @TControlControlState_W, 'ControlState');
    RegisterPropertyHelper(@TControlControlStyle_R, @TControlControlStyle_W, 'ControlStyle');
    RegisterPropertyHelper(@TControlDockOrientation_R, @TControlDockOrientation_W, 'DockOrientation');
    RegisterPropertyHelper(@TControlFloating_R, nil, 'Floating');
    RegisterPropertyHelper(@TControlFloatingDockSiteClass_R, @TControlFloatingDockSiteClass_W, 'FloatingDockSiteClass');
    RegisterPropertyHelper(@TControlHostDockSite_R, @TControlHostDockSite_W, 'HostDockSite');
    RegisterPropertyHelper(@TControlLRDockWidth_R, @TControlLRDockWidth_W, 'LRDockWidth');
    RegisterPropertyHelper(@TControlParent_R, @TControlParent_W, 'Parent');
    RegisterPropertyHelper(@TControlShowHint_R, @TControlShowHint_W, 'ShowHint');
    RegisterPropertyHelper(@TControlTBDockHeight_R, @TControlTBDockHeight_W, 'TBDockHeight');
    RegisterPropertyHelper(@TControlUndockHeight_R, @TControlUndockHeight_W, 'UndockHeight');
    RegisterPropertyHelper(@TControlUndockWidth_R, @TControlUndockWidth_W, 'UndockWidth');
    RegisterPropertyHelper(@TControlVisible_R, @TControlVisible_W, 'Visible');
    RegisterPropertyHelper(@TControlWindowProc_R, @TControlWindowProc_W, 'WindowProc');
    RegisterPropertyHelper(@TControlLeft_R, @TControlLeft_W, 'Left');
    RegisterPropertyHelper(@TControlTop_R, @TControlTop_W, 'Top');
    RegisterPropertyHelper(@TControlWidth_R, @TControlWidth_W, 'Width');
    RegisterPropertyHelper(@TControlHeight_R, @TControlHeight_W, 'Height');
    RegisterPropertyHelper(@TControlCursor_R, @TControlCursor_W, 'Cursor');
    RegisterPropertyHelper(@TControlHint_R, @TControlHint_W, 'Hint');
  end;
end;

procedure RIRegister_TSizeConstraints(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TSizeConstraints) do
  begin
    RegisterVirtualConstructor(@TSizeConstraints.Create, 'Create');
    RegisterPropertyHelper(@TSizeConstraintsOnChange_R, @TSizeConstraintsOnChange_W, 'OnChange');
    RegisterPropertyHelper(@TSizeConstraintsMaxHeight_R, @TSizeConstraintsMaxHeight_W, 'MaxHeight');
    RegisterPropertyHelper(@TSizeConstraintsMaxWidth_R, @TSizeConstraintsMaxWidth_W, 'MaxWidth');
    RegisterPropertyHelper(@TSizeConstraintsMinHeight_R, @TSizeConstraintsMinHeight_W, 'MinHeight');
    RegisterPropertyHelper(@TSizeConstraintsMinWidth_R, @TSizeConstraintsMinWidth_W, 'MinWidth');
  end;
end;

procedure RIRegister_TDragObject(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TDragObject) do
  begin
    RegisterVirtualMethod(@TDragObject.Assign, 'Assign');
    RegisterVirtualMethod(@TDragObject.GetName, 'GetName');
    RegisterVirtualMethod(@TDragObject.HideDragImage, 'HideDragImage');
    RegisterVirtualMethod(@TDragObject.Instance, 'Instance');
    RegisterVirtualMethod(@TDragObject.ShowDragImage, 'ShowDragImage');
    RegisterPropertyHelper(@TDragObjectCancelling_R, @TDragObjectCancelling_W, 'Cancelling');
    RegisterPropertyHelper(@TDragObjectDragHandle_R, @TDragObjectDragHandle_W, 'DragHandle');
    RegisterPropertyHelper(@TDragObjectDragPos_R, @TDragObjectDragPos_W, 'DragPos');
    RegisterPropertyHelper(@TDragObjectDragTargetPos_R, @TDragObjectDragTargetPos_W, 'DragTargetPos');
    RegisterPropertyHelper(@TDragObjectDragTarget_R, @TDragObjectDragTarget_W, 'DragTarget');
    RegisterPropertyHelper(@TDragObjectMouseDeltaX_R, nil, 'MouseDeltaX');
    RegisterPropertyHelper(@TDragObjectMouseDeltaY_R, nil, 'MouseDeltaY');
  end;
end;

procedure RIRegister_Controls(CL: TPSRuntimeClassImporter);
begin
  CL.Add(TDragObject);
  CL.Add(TControl);
  CL.Add(TWinControl);
  CL.Add(TDragImageList);
  RIRegister_TDragObject(CL);
  RIRegister_TSizeConstraints(CL);
  RIRegister_TControl(CL);
  RIRegister_TWinControl(CL);
  RIRegister_TGraphicControl(CL);
  RIRegister_TCustomControl(CL);
  RIRegister_TCustomImageList(CL);
  RIRegister_TDragImageList(CL);
  RIRegister_TImageList(CL);
  RIRegister_TMouse(CL);
end;

{ TPSImport_Controls }

procedure TPSImport_Controls.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Controls(CompExec.Comp);
end;

procedure TPSImport_Controls.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_Controls(ri);
  RIRegister_Controls_Routines(CompExec.Exec); // comment it if no routines
end;

end.

