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

unit CnScript_Graphics;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 Graphics 注册类
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
  Windows, SysUtils, Classes, Graphics, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_Graphics = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TIcon(CL: TPSPascalCompiler);
procedure SIRegister_TBitmap(CL: TPSPascalCompiler);
procedure SIRegister_TPicture(CL: TPSPascalCompiler);
procedure SIRegister_TGraphic(CL: TPSPascalCompiler);
procedure SIRegister_TCanvas(CL: TPSPascalCompiler);
procedure SIRegister_TBrush(CL: TPSPascalCompiler);
procedure SIRegister_TPen(CL: TPSPascalCompiler);
procedure SIRegister_TFont(CL: TPSPascalCompiler);
procedure SIRegister_TGraphicsObject(CL: TPSPascalCompiler);
procedure SIRegister_Graphics(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_Graphics_Routines(S: TPSExec);
procedure RIRegister_TIcon(CL: TPSRuntimeClassImporter);
procedure RIRegister_TBitmap(CL: TPSRuntimeClassImporter);
procedure RIRegister_TPicture(CL: TPSRuntimeClassImporter);
procedure RIRegister_TGraphic(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCanvas(CL: TPSRuntimeClassImporter);
procedure RIRegister_TBrush(CL: TPSRuntimeClassImporter);
procedure RIRegister_TPen(CL: TPSRuntimeClassImporter);
procedure RIRegister_TFont(CL: TPSRuntimeClassImporter);
procedure RIRegister_TGraphicsObject(CL: TPSRuntimeClassImporter);
procedure RIRegister_Graphics(CL: TPSRuntimeClassImporter);

implementation

type
  TGraphicAssess = class(TGraphic);

(* === compile-time registration functions === *)

procedure SIRegister_TIcon(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphic', 'TIcon') do
  with CL.AddClass(CL.FindClass('TGraphic'), TIcon) do
  begin
    RegisterMethod('Function ReleaseHandle : HICON');
    RegisterProperty('Handle', 'HICON', iptrw);
  end;
end;

procedure SIRegister_TBitmap(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphic', 'TBitmap') do
  with CL.AddClass(CL.FindClass('TGraphic'), TBitmap) do
  begin
    RegisterMethod('Procedure FreeImage');
    RegisterMethod('Procedure LoadFromResourceName( Instance : THandle; const ResName : String)');
    RegisterMethod('Procedure LoadFromResourceID( Instance : THandle; ResID : Integer)');
    RegisterMethod('Procedure Mask( TransparentColor : TColor)');
    RegisterMethod('Function ReleaseHandle : HBITMAP');
    RegisterMethod('Function ReleaseMaskHandle : HBITMAP');
    RegisterMethod('Function ReleasePalette : HPALETTE');
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('Handle', 'HBITMAP', iptrw);
    RegisterProperty('HandleType', 'TBitmapHandleType', iptrw);
    RegisterProperty('IgnorePalette', 'Boolean', iptrw);
    RegisterProperty('MaskHandle', 'HBITMAP', iptrw);
    RegisterProperty('Monochrome', 'Boolean', iptrw);
    RegisterProperty('PixelFormat', 'TPixelFormat', iptrw);
    RegisterProperty('ScanLine', 'Pointer Integer', iptr);
    RegisterProperty('TransparentColor', 'TColor', iptrw);
    RegisterProperty('TransparentMode', 'TTransparentMode', iptrw);
  end;
end;

procedure SIRegister_TPicture(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TPicture') do
  with CL.AddClass(CL.FindClass('TPersistent'), TPicture) do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure LoadFromFile( const Filename : string)');
    RegisterMethod('Procedure SaveToFile( const Filename : string)');
    RegisterMethod('Procedure LoadFromClipboardFormat( AFormat : Word; AData : THandle; APalette : HPALETTE)');
    RegisterMethod('Procedure SaveToClipboardFormat( var AFormat : Word; var AData : THandle; var APalette : HPALETTE)');
    RegisterProperty('Bitmap', 'TBitmap', iptrw);
    RegisterProperty('Graphic', 'TGraphic', iptrw);
    RegisterProperty('Height', 'Integer', iptr);
    RegisterProperty('Icon', 'TIcon', iptrw);
    RegisterProperty('Metafile', 'TMetafile', iptrw);
    RegisterProperty('Width', 'Integer', iptr);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
  end;
end;

procedure SIRegister_TGraphic(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TGraphic') do
  with CL.AddClass(CL.FindClass('TPersistent'), TGraphic) do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure LoadFromFile( const Filename : string)');
    RegisterMethod('Procedure SaveToFile( const Filename : string)');
    RegisterMethod('Procedure LoadFromStream( Stream : TStream)');
    RegisterMethod('Procedure SaveToStream( Stream : TStream)');
    RegisterMethod('Procedure LoadFromClipboardFormat( AFormat : Word; AData : THandle; APalette : HPALETTE)');
    RegisterMethod('Procedure SaveToClipboardFormat( var AFormat : Word; var AData : THandle; var APalette : HPALETTE)');
    RegisterProperty('Empty', 'Boolean', iptr);
    RegisterProperty('Height', 'Integer', iptrw);
    RegisterProperty('Modified', 'Boolean', iptrw);
    RegisterProperty('Palette', 'HPALETTE', iptrw);
    RegisterProperty('PaletteModified', 'Boolean', iptrw);
    RegisterProperty('Transparent', 'Boolean', iptrw);
    RegisterProperty('Width', 'Integer', iptrw);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
  end;
end;

procedure SIRegister_TCanvas(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TCanvas') do
  with CL.AddClass(CL.FindClass('TPersistent'), TCanvas) do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure Arc( X1, Y1, X2, Y2, X3, Y3, X4, Y4 : Integer)');
    RegisterMethod('Procedure BrushCopy( const Dest : TRect; Bitmap : TBitmap; const Source : TRect; Color : TColor)');
    RegisterMethod('Procedure Chord( X1, Y1, X2, Y2, X3, Y3, X4, Y4 : Integer)');
    RegisterMethod('Procedure CopyRect( const Dest : TRect; Canvas : TCanvas; const Source : TRect)');
    RegisterMethod('Procedure Draw( X, Y : Integer; Graphic : TGraphic)');
    RegisterMethod('Procedure DrawFocusRect( const Rect : TRect)');
    RegisterMethod('Procedure Ellipse( X1, Y1, X2, Y2 : Integer);');
    RegisterMethod('Procedure FillRect( const Rect : TRect)');
    RegisterMethod('Procedure FloodFill( X, Y : Integer; Color : TColor; FillStyle : TFillStyle)');
    RegisterMethod('Procedure FrameRect( const Rect : TRect)');
    RegisterMethod('Procedure LineTo( X, Y : Integer)');
    RegisterMethod('Procedure Lock');
    RegisterMethod('Procedure MoveTo( X, Y : Integer)');
    RegisterMethod('Procedure Pie( X1, Y1, X2, Y2, X3, Y3, X4, Y4 : Integer)');
    RegisterMethod('Procedure Polygon( const Points : array of TPoint)');
    RegisterMethod('Procedure Polyline( const Points : array of TPoint)');
    RegisterMethod('Procedure PolyBezier( const Points : array of TPoint)');
    RegisterMethod('Procedure PolyBezierTo( const Points : array of TPoint)');
    RegisterMethod('Procedure Rectangle( X1, Y1, X2, Y2 : Integer);');
    RegisterMethod('Procedure Refresh');
    RegisterMethod('Procedure RoundRect( X1, Y1, X2, Y2, X3, Y3 : Integer)');
    RegisterMethod('Procedure StretchDraw( const Rect : TRect; Graphic : TGraphic)');
    RegisterMethod('Function TextExtent( const Text : string) : TSize');
    RegisterMethod('Function TextHeight( const Text : string) : Integer');
    RegisterMethod('Procedure TextOut( X, Y : Integer; const Text : string)');
    RegisterMethod('Procedure TextRect( Rect : TRect; X, Y : Integer; const Text : string)');
    RegisterMethod('Function TextWidth( const Text : string) : Integer');
    RegisterMethod('Function TryLock : Boolean');
    RegisterMethod('Procedure Unlock');
    RegisterProperty('ClipRect', 'TRect', iptr);
    RegisterProperty('Handle', 'HDC', iptrw);
    RegisterProperty('LockCount', 'Integer', iptr);
    RegisterProperty('CanvasOrientation', 'TCanvasOrientation', iptr);
    RegisterProperty('PenPos', 'TPoint', iptrw);
    RegisterProperty('Pixels', 'TColor Integer Integer', iptrw);
    RegisterProperty('TextFlags', 'Longint', iptrw);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
    RegisterProperty('OnChanging', 'TNotifyEvent', iptrw);
    RegisterProperty('Brush', 'TBrush', iptrw);
    RegisterProperty('CopyMode', 'TCopyMode', iptrw);
    RegisterProperty('Font', 'TFont', iptrw);
    RegisterProperty('Pen', 'TPen', iptrw);
  end;
end;

procedure SIRegister_TBrush(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicsObject', 'TBrush') do
  with CL.AddClass(CL.FindClass('TGraphicsObject'), TBrush) do
  begin
    RegisterMethod('Constructor Create');
    RegisterProperty('Bitmap', 'TBitmap', iptrw);
    RegisterProperty('Handle', 'HBrush', iptrw);
    RegisterProperty('Color', 'TColor', iptrw);
    RegisterProperty('Style', 'TBrushStyle', iptrw);
  end;
end;

procedure SIRegister_TPen(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicsObject', 'TPen') do
  with CL.AddClass(CL.FindClass('TGraphicsObject'), TPen) do
  begin
    RegisterMethod('Constructor Create');
    RegisterProperty('Handle', 'HPen', iptrw);
    RegisterProperty('Color', 'TColor', iptrw);
    RegisterProperty('Mode', 'TPenMode', iptrw);
    RegisterProperty('Style', 'TPenStyle', iptrw);
    RegisterProperty('Width', 'Integer', iptrw);
  end;
end;

procedure SIRegister_TFont(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicsObject', 'TFont') do
  with CL.AddClass(CL.FindClass('TGraphicsObject'), TFont) do
  begin
    RegisterMethod('Constructor Create');
    RegisterProperty('Handle', 'HFont', iptrw);
    RegisterProperty('PixelsPerInch', 'Integer', iptrw);
    RegisterProperty('Charset', 'TFontCharset', iptrw);
    RegisterProperty('Color', 'TColor', iptrw);
    RegisterProperty('Height', 'Integer', iptrw);
    RegisterProperty('Name', 'TFontName', iptrw);
    RegisterProperty('Pitch', 'TFontPitch', iptrw);
    RegisterProperty('Size', 'Integer', iptrw);
    RegisterProperty('Style', 'TFontStyles', iptrw);
  end;
end;

procedure SIRegister_TGraphicsObject(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TGraphicsObject') do
  with CL.AddClass(CL.FindClass('TPersistent'), TGraphicsObject) do
  begin
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
  end;
end;

procedure SIRegister_Graphics(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('PColor', 'Pointer');
  CL.AddTypeS('TColor', 'Integer');
  CL.AddConstantN('clScrollBar', 'Integer').SetInt(clScrollBar);
  CL.AddConstantN('clBackground', 'Integer').SetInt(clBackground);
  CL.AddConstantN('clActiveCaption', 'Integer').SetInt(clActiveCaption);
  CL.AddConstantN('clInactiveCaption', 'Integer').SetInt(clInactiveCaption);
  CL.AddConstantN('clMenu', 'Integer').SetInt(clMenu);
  CL.AddConstantN('clWindow', 'Integer').SetInt(clWindow);
  CL.AddConstantN('clWindowFrame', 'Integer').SetInt(clWindowFrame);
  CL.AddConstantN('clMenuText', 'Integer').SetInt(clMenuText);
  CL.AddConstantN('clWindowText', 'Integer').SetInt(clWindowText);
  CL.AddConstantN('clCaptionText', 'Integer').SetInt(clCaptionText);
  CL.AddConstantN('clActiveBorder', 'Integer').SetInt(clActiveBorder);
  CL.AddConstantN('clInactiveBorder', 'Integer').SetInt(clInactiveBorder);
  CL.AddConstantN('clAppWorkSpace', 'Integer').SetInt(clAppWorkSpace);
  CL.AddConstantN('clHighlight', 'Integer').SetInt(clHighlight);
  CL.AddConstantN('clHighlightText', 'Integer').SetInt(clHighlightText);
  CL.AddConstantN('clBtnFace', 'Integer').SetInt(clBtnFace);
  CL.AddConstantN('clBtnShadow', 'Integer').SetInt(clBtnShadow);
  CL.AddConstantN('clGrayText', 'Integer').SetInt(clGrayText);
  CL.AddConstantN('clBtnText', 'Integer').SetInt(clBtnText);
  CL.AddConstantN('clInactiveCaptionText', 'Integer').SetInt(clInactiveCaptionText);
  CL.AddConstantN('clBtnHighlight', 'Integer').SetInt(clBtnHighlight);
  CL.AddConstantN('cl3DDkShadow', 'Integer').SetInt(cl3DDkShadow);
  CL.AddConstantN('cl3DLight', 'Integer').SetInt(cl3DLight);
  CL.AddConstantN('clInfoText', 'Integer').SetInt(clInfoText);
  CL.AddConstantN('clInfoBk', 'Integer').SetInt(clInfoBk);
  CL.AddConstantN('clBlack', 'Integer').SetInt(TColor($000000));
  CL.AddConstantN('clMaroon', 'Integer').SetInt(TColor($000080));
  CL.AddConstantN('clGreen', 'Integer').SetInt(TColor($008000));
  CL.AddConstantN('clOlive', 'Integer').SetInt(TColor($008080));
  CL.AddConstantN('clNavy', 'Integer').SetInt(TColor($800000));
  CL.AddConstantN('clPurple', 'Integer').SetInt(TColor($800080));
  CL.AddConstantN('clTeal', 'Integer').SetInt(TColor($808000));
  CL.AddConstantN('clGray', 'Integer').SetInt(TColor($808080));
  CL.AddConstantN('clSilver', 'Integer').SetInt(TColor($C0C0C0));
  CL.AddConstantN('clRed', 'Integer').SetInt(TColor($0000FF));
  CL.AddConstantN('clLime', 'Integer').SetInt(TColor($00FF00));
  CL.AddConstantN('clYellow', 'Integer').SetInt(TColor($00FFFF));
  CL.AddConstantN('clBlue', 'Integer').SetInt(TColor($FF0000));
  CL.AddConstantN('clFuchsia', 'Integer').SetInt(TColor($FF00FF));
  CL.AddConstantN('clAqua', 'Integer').SetInt(TColor($FFFF00));
  CL.AddConstantN('clLtGray', 'Integer').SetInt(TColor($C0C0C0));
  CL.AddConstantN('clDkGray', 'Integer').SetInt(TColor($808080));
  CL.AddConstantN('clWhite', 'Integer').SetInt(TColor($FFFFFF));
  CL.AddConstantN('clNone', 'Integer').SetInt(TColor($1FFFFFFF));
  CL.AddConstantN('clDefault', 'Integer').SetInt(TColor($20000000));
  CL.AddClass(CL.FindClass('TPersistent'), TGraphic);
  CL.AddClass(CL.FindClass('TGraphic'), TBitmap);
  CL.AddClass(CL.FindClass('TGraphic'), TIcon);
  CL.AddClass(CL.FindClass('TMetafile'), TMetafile);
  CL.AddTypeS('TFontPitch', '( fpDefault, fpVariable, fpFixed )');
  CL.AddTypeS('TFontName', 'string');
  CL.AddTypeS('TFontCharset', 'Byte');
  CL.AddTypeS('TFontStyle', '( fsBold, fsItalic, fsUnderline, fsStrikeOut )');
  CL.AddTypeS('TFontStyles', 'set of TFontStyle');
  CL.AddTypeS('TFontStylesBase', 'set of TFontStyle');
  CL.AddTypeS('TPenStyle', '( psSolid, psDash, psDot, psDashDot, psDashDotDot, '
    + 'psClear, psInsideFrame )');
  CL.AddTypeS('TPenMode', '( pmBlack, pmWhite, pmNop, pmNot, pmCopy, pmNotCopy,'
    + ' pmMergePenNot, pmMaskPenNot, pmMergeNotPen, pmMaskNotPen, pmMerge, pmNotM'
    + 'erge, pmMask, pmNotMask, pmXor, pmNotXor )');
  CL.AddTypeS('TBrushStyle', '( bsSolid, bsClear, bsHorizontal, bsVertical, bsF'
    + 'Diagonal, bsBDiagonal, bsCross, bsDiagCross )');
  SIRegister_TGraphicsObject(CL);
  SIRegister_TFont(CL);
  SIRegister_TPen(CL);
  SIRegister_TBrush(CL);
  CL.AddTypeS('TFillStyle', '( fsSurface, fsBorder )');
  CL.AddTypeS('TFillMode', '( fmAlternate, fmWinding )');
  CL.AddTypeS('TCopyMode', 'Longint');
  CL.AddTypeS('TCanvasStates', '( csHandleValid, csFontValid, csPenValid, csBru'
    + 'shValid )');
  CL.AddTypeS('TCanvasState', 'set of TCanvasStates');
  CL.AddTypeS('TCanvasOrientation', '( coLeftToRight, coRightToLeft )');
  SIRegister_TCanvas(CL);
  SIRegister_TGraphic(CL);
  SIRegister_TPicture(CL);
  CL.AddTypeS('TBitmapHandleType', '( bmDIB, bmDDB )');
  CL.AddTypeS('TPixelFormat', '( pfDevice, pf1bit, pf4bit, pf8bit, pf15bit, pf1'
    + '6bit, pf24bit, pf32bit, pfCustom )');
  CL.AddTypeS('TTransparentMode', '( tmAuto, tmFixed )');
  SIRegister_TBitmap(CL);
  SIRegister_TIcon(CL);
  CL.AddDelphiFunction('Function ColorToRGB( Color : TColor) : Longint');
  CL.AddDelphiFunction('Function ColorToString( Color : TColor) : string');
  CL.AddDelphiFunction('Function StringToColor( const S : string) : TColor');
  CL.AddDelphiFunction('Function ColorToIdent( Color : Longint; var Ident : string) : Boolean');
  CL.AddDelphiFunction('Function IdentToColor( const Ident : string; var Color : Longint) : Boolean');
  CL.AddDelphiFunction('Function CharsetToIdent( Charset : Longint; var Ident : string) : Boolean');
  CL.AddDelphiFunction('Function IdentToCharset( const Ident : string; var Charset : Longint) : Boolean');
end;

(* === run-time registration functions === *)

procedure TIconHandle_W(Self: TIcon; const T: HICON);
begin
  Self.Handle := T;
end;

procedure TIconHandle_R(Self: TIcon; var T: HICON);
begin
  T := Self.Handle;
end;

procedure TBitmapTransparentMode_W(Self: TBitmap; const T: TTransparentMode);
begin
  Self.TransparentMode := T;
end;

procedure TBitmapTransparentMode_R(Self: TBitmap; var T: TTransparentMode);
begin
  T := Self.TransparentMode;
end;

procedure TBitmapTransparentColor_W(Self: TBitmap; const T: TColor);
begin
  Self.TransparentColor := T;
end;

procedure TBitmapTransparentColor_R(Self: TBitmap; var T: TColor);
begin
  T := Self.TransparentColor;
end;

procedure TBitmapScanLine_R(Self: TBitmap; var T: Pointer; const t1: Integer);
begin
  T := Self.ScanLine[t1];
end;

procedure TBitmapPixelFormat_W(Self: TBitmap; const T: TPixelFormat);
begin
  Self.PixelFormat := T;
end;

procedure TBitmapPixelFormat_R(Self: TBitmap; var T: TPixelFormat);
begin
  T := Self.PixelFormat;
end;

procedure TBitmapMonochrome_W(Self: TBitmap; const T: Boolean);
begin
  Self.Monochrome := T;
end;

procedure TBitmapMonochrome_R(Self: TBitmap; var T: Boolean);
begin
  T := Self.Monochrome;
end;

procedure TBitmapMaskHandle_W(Self: TBitmap; const T: HBITMAP);
begin
  Self.MaskHandle := T;
end;

procedure TBitmapMaskHandle_R(Self: TBitmap; var T: HBITMAP);
begin
  T := Self.MaskHandle;
end;

procedure TBitmapIgnorePalette_W(Self: TBitmap; const T: Boolean);
begin
  Self.IgnorePalette := T;
end;

procedure TBitmapIgnorePalette_R(Self: TBitmap; var T: Boolean);
begin
  T := Self.IgnorePalette;
end;

procedure TBitmapHandleType_W(Self: TBitmap; const T: TBitmapHandleType);
begin
  Self.HandleType := T;
end;

procedure TBitmapHandleType_R(Self: TBitmap; var T: TBitmapHandleType);
begin
  T := Self.HandleType;
end;

procedure TBitmapHandle_W(Self: TBitmap; const T: HBITMAP);
begin
  Self.Handle := T;
end;

procedure TBitmapHandle_R(Self: TBitmap; var T: HBITMAP);
begin
  T := Self.Handle;
end;

procedure TBitmapCanvas_R(Self: TBitmap; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure TPictureOnChange_W(Self: TPicture; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TPictureOnChange_R(Self: TPicture; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TPictureWidth_R(Self: TPicture; var T: Integer);
begin
  T := Self.Width;
end;

procedure TPictureMetafile_W(Self: TPicture; const T: TMetafile);
begin
  Self.Metafile := T;
end;

procedure TPictureMetafile_R(Self: TPicture; var T: TMetafile);
begin
  T := Self.Metafile;
end;

procedure TPictureIcon_W(Self: TPicture; const T: TIcon);
begin
  Self.Icon := T;
end;

procedure TPictureIcon_R(Self: TPicture; var T: TIcon);
begin
  T := Self.Icon;
end;

procedure TPictureHeight_R(Self: TPicture; var T: Integer);
begin
  T := Self.Height;
end;

procedure TPictureGraphic_W(Self: TPicture; const T: TGraphic);
begin
  Self.Graphic := T;
end;

procedure TPictureGraphic_R(Self: TPicture; var T: TGraphic);
begin
  T := Self.Graphic;
end;

procedure TPictureBitmap_W(Self: TPicture; const T: TBitmap);
begin
  Self.Bitmap := T;
end;

procedure TPictureBitmap_R(Self: TPicture; var T: TBitmap);
begin
  T := Self.Bitmap;
end;

procedure TGraphicOnChange_W(Self: TGraphic; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TGraphicOnChange_R(Self: TGraphic; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TGraphicWidth_W(Self: TGraphic; const T: Integer);
begin
  Self.Width := T;
end;

procedure TGraphicWidth_R(Self: TGraphic; var T: Integer);
begin
  T := Self.Width;
end;

procedure TGraphicTransparent_W(Self: TGraphic; const T: Boolean);
begin
  Self.Transparent := T;
end;

procedure TGraphicTransparent_R(Self: TGraphic; var T: Boolean);
begin
  T := Self.Transparent;
end;

procedure TGraphicPaletteModified_W(Self: TGraphic; const T: Boolean);
begin
  Self.PaletteModified := T;
end;

procedure TGraphicPaletteModified_R(Self: TGraphic; var T: Boolean);
begin
  T := Self.PaletteModified;
end;

procedure TGraphicPalette_W(Self: TGraphic; const T: HPALETTE);
begin
  Self.Palette := T;
end;

procedure TGraphicPalette_R(Self: TGraphic; var T: HPALETTE);
begin
  T := Self.Palette;
end;

procedure TGraphicModified_W(Self: TGraphic; const T: Boolean);
begin
  Self.Modified := T;
end;

procedure TGraphicModified_R(Self: TGraphic; var T: Boolean);
begin
  T := Self.Modified;
end;

procedure TGraphicHeight_W(Self: TGraphic; const T: Integer);
begin
  Self.Height := T;
end;

procedure TGraphicHeight_R(Self: TGraphic; var T: Integer);
begin
  T := Self.Height;
end;

procedure TGraphicEmpty_R(Self: TGraphic; var T: Boolean);
begin
  T := Self.Empty;
end;

procedure TCanvasPen_W(Self: TCanvas; const T: TPen);
begin
  Self.Pen := T;
end;

procedure TCanvasPen_R(Self: TCanvas; var T: TPen);
begin
  T := Self.Pen;
end;

procedure TCanvasFont_W(Self: TCanvas; const T: TFont);
begin
  Self.Font := T;
end;

procedure TCanvasFont_R(Self: TCanvas; var T: TFont);
begin
  T := Self.Font;
end;

procedure TCanvasCopyMode_W(Self: TCanvas; const T: TCopyMode);
begin
  Self.CopyMode := T;
end;

procedure TCanvasCopyMode_R(Self: TCanvas; var T: TCopyMode);
begin
  T := Self.CopyMode;
end;

procedure TCanvasBrush_W(Self: TCanvas; const T: TBrush);
begin
  Self.Brush := T;
end;

procedure TCanvasBrush_R(Self: TCanvas; var T: TBrush);
begin
  T := Self.Brush;
end;

procedure TCanvasOnChanging_W(Self: TCanvas; const T: TNotifyEvent);
begin
  Self.OnChanging := T;
end;

procedure TCanvasOnChanging_R(Self: TCanvas; var T: TNotifyEvent);
begin
  T := Self.OnChanging;
end;

procedure TCanvasOnChange_W(Self: TCanvas; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TCanvasOnChange_R(Self: TCanvas; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TCanvasTextFlags_W(Self: TCanvas; const T: Longint);
begin
  Self.TextFlags := T;
end;

procedure TCanvasTextFlags_R(Self: TCanvas; var T: Longint);
begin
  T := Self.TextFlags;
end;

procedure TCanvasPixels_W(Self: TCanvas; const T: TColor; const t1: Integer; const t2: Integer);
begin
  Self.Pixels[t1, t2] := T;
end;

procedure TCanvasPixels_R(Self: TCanvas; var T: TColor; const t1: Integer; const t2: Integer);
begin
  T := Self.Pixels[t1, t2];
end;

procedure TCanvasPenPos_W(Self: TCanvas; const T: TPoint);
begin
  Self.PenPos := T;
end;

procedure TCanvasPenPos_R(Self: TCanvas; var T: TPoint);
begin
  T := Self.PenPos;
end;

procedure TCanvasCanvasOrientation_R(Self: TCanvas; var T: TCanvasOrientation);
begin
  T := Self.CanvasOrientation;
end;

procedure TCanvasLockCount_R(Self: TCanvas; var T: Integer);
begin
  T := Self.LockCount;
end;

procedure TCanvasHandle_W(Self: TCanvas; const T: HDC);
begin
  Self.Handle := T;
end;

procedure TCanvasHandle_R(Self: TCanvas; var T: HDC);
begin
  T := Self.Handle;
end;

procedure TCanvasClipRect_R(Self: TCanvas; var T: TRect);
begin
  T := Self.ClipRect;
end;

procedure TCanvasRectangle_P(Self: TCanvas; X1, Y1, X2, Y2: Integer);
begin
  Self.Rectangle(X1, Y1, X2, Y2);
end;

procedure TCanvasEllipse_P(Self: TCanvas; X1, Y1, X2, Y2: Integer);
begin
  Self.Ellipse(X1, Y1, X2, Y2);
end;

procedure TBrushStyle_W(Self: TBrush; const T: TBrushStyle);
begin
  Self.Style := T;
end;

procedure TBrushStyle_R(Self: TBrush; var T: TBrushStyle);
begin
  T := Self.Style;
end;

procedure TBrushColor_W(Self: TBrush; const T: TColor);
begin
  Self.Color := T;
end;

procedure TBrushColor_R(Self: TBrush; var T: TColor);
begin
  T := Self.Color;
end;

procedure TBrushHandle_W(Self: TBrush; const T: HBrush);
begin
  Self.Handle := T;
end;

procedure TBrushHandle_R(Self: TBrush; var T: HBrush);
begin
  T := Self.Handle;
end;

procedure TBrushBitmap_W(Self: TBrush; const T: TBitmap);
begin
  Self.Bitmap := T;
end;

procedure TBrushBitmap_R(Self: TBrush; var T: TBitmap);
begin
  T := Self.Bitmap;
end;

procedure TPenWidth_W(Self: TPen; const T: Integer);
begin
  Self.Width := T;
end;

procedure TPenWidth_R(Self: TPen; var T: Integer);
begin
  T := Self.Width;
end;

procedure TPenStyle_W(Self: TPen; const T: TPenStyle);
begin
  Self.Style := T;
end;

procedure TPenStyle_R(Self: TPen; var T: TPenStyle);
begin
  T := Self.Style;
end;

procedure TPenMode_W(Self: TPen; const T: TPenMode);
begin
  Self.Mode := T;
end;

procedure TPenMode_R(Self: TPen; var T: TPenMode);
begin
  T := Self.Mode;
end;

procedure TPenColor_W(Self: TPen; const T: TColor);
begin
  Self.Color := T;
end;

procedure TPenColor_R(Self: TPen; var T: TColor);
begin
  T := Self.Color;
end;

procedure TPenHandle_W(Self: TPen; const T: HPen);
begin
  Self.Handle := T;
end;

procedure TPenHandle_R(Self: TPen; var T: HPen);
begin
  T := Self.Handle;
end;

procedure TFontStyle_W(Self: TFont; const T: TFontStyles);
begin
  Self.Style := T;
end;

procedure TFontStyle_R(Self: TFont; var T: TFontStyles);
begin
  T := Self.Style;
end;

procedure TFontSize_W(Self: TFont; const T: Integer);
begin
  Self.Size := T;
end;

procedure TFontSize_R(Self: TFont; var T: Integer);
begin
  T := Self.Size;
end;

procedure TFontPitch_W(Self: TFont; const T: TFontPitch);
begin
  Self.Pitch := T;
end;

procedure TFontPitch_R(Self: TFont; var T: TFontPitch);
begin
  T := Self.Pitch;
end;

procedure TFontName_W(Self: TFont; const T: TFontName);
begin
  Self.Name := T;
end;

procedure TFontName_R(Self: TFont; var T: TFontName);
begin
  T := Self.Name;
end;

procedure TFontHeight_W(Self: TFont; const T: Integer);
begin
  Self.Height := T;
end;

procedure TFontHeight_R(Self: TFont; var T: Integer);
begin
  T := Self.Height;
end;

procedure TFontColor_W(Self: TFont; const T: TColor);
begin
  Self.Color := T;
end;

procedure TFontColor_R(Self: TFont; var T: TColor);
begin
  T := Self.Color;
end;

procedure TFontCharset_W(Self: TFont; const T: TFontCharset);
begin
  Self.Charset := T;
end;

procedure TFontCharset_R(Self: TFont; var T: TFontCharset);
begin
  T := Self.Charset;
end;

procedure TFontPixelsPerInch_W(Self: TFont; const T: Integer);
begin
  Self.PixelsPerInch := T;
end;

procedure TFontPixelsPerInch_R(Self: TFont; var T: Integer);
begin
  T := Self.PixelsPerInch;
end;

procedure TFontHandle_W(Self: TFont; const T: HFont);
begin
  Self.Handle := T;
end;

procedure TFontHandle_R(Self: TFont; var T: HFont);
begin
  T := Self.Handle;
end;

procedure TGraphicsObjectOnChange_W(Self: TGraphicsObject; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TGraphicsObjectOnChange_R(Self: TGraphicsObject; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure RIRegister_Graphics_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@ColorToRGB, 'ColorToRGB', cdRegister);
  S.RegisterDelphiFunction(@ColorToString, 'ColorToString', cdRegister);
  S.RegisterDelphiFunction(@StringToColor, 'StringToColor', cdRegister);
  S.RegisterDelphiFunction(@ColorToIdent, 'ColorToIdent', cdRegister);
  S.RegisterDelphiFunction(@IdentToColor, 'IdentToColor', cdRegister);
  S.RegisterDelphiFunction(@CharsetToIdent, 'CharsetToIdent', cdRegister);
  S.RegisterDelphiFunction(@IdentToCharset, 'IdentToCharset', cdRegister);
end;

procedure RIRegister_TIcon(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TIcon) do
  begin
    RegisterMethod(@TIcon.ReleaseHandle, 'ReleaseHandle');
    RegisterPropertyHelper(@TIconHandle_R, @TIconHandle_W, 'Handle');
  end;
end;

procedure RIRegister_TBitmap(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TBitmap) do
  begin
    RegisterMethod(@TBitmap.FreeImage, 'FreeImage');
    RegisterMethod(@TBitmap.LoadFromResourceName, 'LoadFromResourceName');
    RegisterMethod(@TBitmap.LoadFromResourceID, 'LoadFromResourceID');
    RegisterMethod(@TBitmap.Mask, 'Mask');
    RegisterMethod(@TBitmap.ReleaseHandle, 'ReleaseHandle');
    RegisterMethod(@TBitmap.ReleaseMaskHandle, 'ReleaseMaskHandle');
    RegisterMethod(@TBitmap.ReleasePalette, 'ReleasePalette');
    RegisterPropertyHelper(@TBitmapCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@TBitmapHandle_R, @TBitmapHandle_W, 'Handle');
    RegisterPropertyHelper(@TBitmapHandleType_R, @TBitmapHandleType_W, 'HandleType');
    RegisterPropertyHelper(@TBitmapIgnorePalette_R, @TBitmapIgnorePalette_W, 'IgnorePalette');
    RegisterPropertyHelper(@TBitmapMaskHandle_R, @TBitmapMaskHandle_W, 'MaskHandle');
    RegisterPropertyHelper(@TBitmapMonochrome_R, @TBitmapMonochrome_W, 'Monochrome');
    RegisterPropertyHelper(@TBitmapPixelFormat_R, @TBitmapPixelFormat_W, 'PixelFormat');
    RegisterPropertyHelper(@TBitmapScanLine_R, nil, 'ScanLine');
    RegisterPropertyHelper(@TBitmapTransparentColor_R, @TBitmapTransparentColor_W, 'TransparentColor');
    RegisterPropertyHelper(@TBitmapTransparentMode_R, @TBitmapTransparentMode_W, 'TransparentMode');
  end;
end;

procedure RIRegister_TPicture(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TPicture) do
  begin
    RegisterConstructor(@TPicture.Create, 'Create');
    RegisterMethod(@TPicture.LoadFromFile, 'LoadFromFile');
    RegisterMethod(@TPicture.SaveToFile, 'SaveToFile');
    RegisterMethod(@TPicture.LoadFromClipboardFormat, 'LoadFromClipboardFormat');
    RegisterMethod(@TPicture.SaveToClipboardFormat, 'SaveToClipboardFormat');
    RegisterPropertyHelper(@TPictureBitmap_R, @TPictureBitmap_W, 'Bitmap');
    RegisterPropertyHelper(@TPictureGraphic_R, @TPictureGraphic_W, 'Graphic');
    RegisterPropertyHelper(@TPictureHeight_R, nil, 'Height');
    RegisterPropertyHelper(@TPictureIcon_R, @TPictureIcon_W, 'Icon');
    RegisterPropertyHelper(@TPictureMetafile_R, @TPictureMetafile_W, 'Metafile');
    RegisterPropertyHelper(@TPictureWidth_R, nil, 'Width');
    RegisterPropertyHelper(@TPictureOnChange_R, @TPictureOnChange_W, 'OnChange');
  end;
end;

procedure RIRegister_TGraphic(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TGraphic) do
  begin
    // TGraphic.Create is protected method in D5
    RegisterVirtualConstructor(@TGraphicAssess.Create, 'Create');
    RegisterVirtualMethod(@TGraphic.LoadFromFile, 'LoadFromFile');
    RegisterVirtualMethod(@TGraphic.SaveToFile, 'SaveToFile');
    RegisterVirtualAbstractMethod(TBitmap, @TBitmap.LoadFromStream, 'LoadFromStream');
    RegisterVirtualAbstractMethod(TBitmap, @TBitmap.SaveToStream, 'SaveToStream');
    RegisterVirtualAbstractMethod(TBitmap, @TBitmap.LoadFromClipboardFormat, 'LoadFromClipboardFormat');
    RegisterVirtualAbstractMethod(TBitmap, @TBitmap.SaveToClipboardFormat, 'SaveToClipboardFormat');
    RegisterPropertyHelper(@TGraphicEmpty_R, nil, 'Empty');
    RegisterPropertyHelper(@TGraphicHeight_R, @TGraphicHeight_W, 'Height');
    RegisterPropertyHelper(@TGraphicModified_R, @TGraphicModified_W, 'Modified');
    RegisterPropertyHelper(@TGraphicPalette_R, @TGraphicPalette_W, 'Palette');
    RegisterPropertyHelper(@TGraphicPaletteModified_R, @TGraphicPaletteModified_W, 'PaletteModified');
    RegisterPropertyHelper(@TGraphicTransparent_R, @TGraphicTransparent_W, 'Transparent');
    RegisterPropertyHelper(@TGraphicWidth_R, @TGraphicWidth_W, 'Width');
    RegisterPropertyHelper(@TGraphicOnChange_R, @TGraphicOnChange_W, 'OnChange');
  end;
end;

procedure RIRegister_TCanvas(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCanvas) do
  begin
    RegisterConstructor(@TCanvas.Create, 'Create');
    RegisterMethod(@TCanvas.Arc, 'Arc');
    RegisterMethod(@TCanvas.BrushCopy, 'BrushCopy');
    RegisterMethod(@TCanvas.Chord, 'Chord');
    RegisterMethod(@TCanvas.CopyRect, 'CopyRect');
    RegisterMethod(@TCanvas.Draw, 'Draw');
    RegisterMethod(@TCanvas.DrawFocusRect, 'DrawFocusRect');
    RegisterMethod(@TCanvasEllipse_P, 'Ellipse');
    RegisterMethod(@TCanvas.FillRect, 'FillRect');
    RegisterMethod(@TCanvas.FloodFill, 'FloodFill');
    RegisterMethod(@TCanvas.FrameRect, 'FrameRect');
    RegisterMethod(@TCanvas.LineTo, 'LineTo');
    RegisterMethod(@TCanvas.Lock, 'Lock');
    RegisterMethod(@TCanvas.MoveTo, 'MoveTo');
    RegisterMethod(@TCanvas.Pie, 'Pie');
    RegisterMethod(@TCanvas.Polygon, 'Polygon');
    RegisterMethod(@TCanvas.Polyline, 'Polyline');
    RegisterMethod(@TCanvas.PolyBezier, 'PolyBezier');
    RegisterMethod(@TCanvas.PolyBezierTo, 'PolyBezierTo');
    RegisterMethod(@TCanvasRectangle_P, 'Rectangle');
    RegisterMethod(@TCanvas.Refresh, 'Refresh');
    RegisterMethod(@TCanvas.RoundRect, 'RoundRect');
    RegisterMethod(@TCanvas.StretchDraw, 'StretchDraw');
    RegisterMethod(@TCanvas.TextExtent, 'TextExtent');
    RegisterMethod(@TCanvas.TextHeight, 'TextHeight');
    RegisterMethod(@TCanvas.TextOut, 'TextOut');
    RegisterMethod(@TCanvas.TextRect, 'TextRect');
    RegisterMethod(@TCanvas.TextWidth, 'TextWidth');
    RegisterMethod(@TCanvas.TryLock, 'TryLock');
    RegisterMethod(@TCanvas.Unlock, 'Unlock');
    RegisterPropertyHelper(@TCanvasClipRect_R, nil, 'ClipRect');
    RegisterPropertyHelper(@TCanvasHandle_R, @TCanvasHandle_W, 'Handle');
    RegisterPropertyHelper(@TCanvasLockCount_R, nil, 'LockCount');
    RegisterPropertyHelper(@TCanvasCanvasOrientation_R, nil, 'CanvasOrientation');
    RegisterPropertyHelper(@TCanvasPenPos_R, @TCanvasPenPos_W, 'PenPos');
    RegisterPropertyHelper(@TCanvasPixels_R, @TCanvasPixels_W, 'Pixels');
    RegisterPropertyHelper(@TCanvasTextFlags_R, @TCanvasTextFlags_W, 'TextFlags');
    RegisterPropertyHelper(@TCanvasOnChange_R, @TCanvasOnChange_W, 'OnChange');
    RegisterPropertyHelper(@TCanvasOnChanging_R, @TCanvasOnChanging_W, 'OnChanging');
    RegisterPropertyHelper(@TCanvasBrush_R, @TCanvasBrush_W, 'Brush');
    RegisterPropertyHelper(@TCanvasCopyMode_R, @TCanvasCopyMode_W, 'CopyMode');
    RegisterPropertyHelper(@TCanvasFont_R, @TCanvasFont_W, 'Font');
    RegisterPropertyHelper(@TCanvasPen_R, @TCanvasPen_W, 'Pen');
  end;
end;

procedure RIRegister_TBrush(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TBrush) do
  begin
    RegisterConstructor(@TBrush.Create, 'Create');
    RegisterPropertyHelper(@TBrushBitmap_R, @TBrushBitmap_W, 'Bitmap');
    RegisterPropertyHelper(@TBrushHandle_R, @TBrushHandle_W, 'Handle');
    RegisterPropertyHelper(@TBrushColor_R, @TBrushColor_W, 'Color');
    RegisterPropertyHelper(@TBrushStyle_R, @TBrushStyle_W, 'Style');
  end;
end;

procedure RIRegister_TPen(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TPen) do
  begin
    RegisterConstructor(@TPen.Create, 'Create');
    RegisterPropertyHelper(@TPenHandle_R, @TPenHandle_W, 'Handle');
    RegisterPropertyHelper(@TPenColor_R, @TPenColor_W, 'Color');
    RegisterPropertyHelper(@TPenMode_R, @TPenMode_W, 'Mode');
    RegisterPropertyHelper(@TPenStyle_R, @TPenStyle_W, 'Style');
    RegisterPropertyHelper(@TPenWidth_R, @TPenWidth_W, 'Width');
  end;
end;

procedure RIRegister_TFont(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TFont) do
  begin
    RegisterConstructor(@TFont.Create, 'Create');
    RegisterPropertyHelper(@TFontHandle_R, @TFontHandle_W, 'Handle');
    RegisterPropertyHelper(@TFontPixelsPerInch_R, @TFontPixelsPerInch_W, 'PixelsPerInch');
    RegisterPropertyHelper(@TFontCharset_R, @TFontCharset_W, 'Charset');
    RegisterPropertyHelper(@TFontColor_R, @TFontColor_W, 'Color');
    RegisterPropertyHelper(@TFontHeight_R, @TFontHeight_W, 'Height');
    RegisterPropertyHelper(@TFontName_R, @TFontName_W, 'Name');
    RegisterPropertyHelper(@TFontPitch_R, @TFontPitch_W, 'Pitch');
    RegisterPropertyHelper(@TFontSize_R, @TFontSize_W, 'Size');
    RegisterPropertyHelper(@TFontStyle_R, @TFontStyle_W, 'Style');
  end;
end;

procedure RIRegister_TGraphicsObject(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TGraphicsObject) do
  begin
    RegisterPropertyHelper(@TGraphicsObjectOnChange_R, @TGraphicsObjectOnChange_W, 'OnChange');
  end;
end;

procedure RIRegister_Graphics(CL: TPSRuntimeClassImporter);
begin
  CL.Add(TGraphic);
  CL.Add(TBitmap);
  CL.Add(TIcon);
  CL.Add(TMetafile);
  RIRegister_TGraphicsObject(CL);
  RIRegister_TFont(CL);
  RIRegister_TPen(CL);
  RIRegister_TBrush(CL);
  RIRegister_TCanvas(CL);
  RIRegister_TGraphic(CL);
  RIRegister_TPicture(CL);
  RIRegister_TBitmap(CL);
  RIRegister_TIcon(CL);
end;

{ TPSImport_Graphics }

procedure TPSImport_Graphics.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Graphics(CompExec.Comp);
end;

procedure TPSImport_Graphics.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_Graphics(ri);
  RIRegister_Graphics_Routines(CompExec.Exec); // comment it if no routines
end;

end.







