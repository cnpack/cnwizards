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

unit CnScript_ExtCtrls;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 ExtCtrls 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Graphics, Classes, Controls, ExtCtrls, Forms, uPSComponent,
  uPSRuntime, uPSCompiler;

type
  TPSImport_ExtCtrls = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TControlBar(CL: TPSPascalCompiler);
procedure SIRegister_TCustomControlBar(CL: TPSPascalCompiler);
procedure SIRegister_TSplitter(CL: TPSPascalCompiler);
procedure SIRegister_TRadioGroup(CL: TPSPascalCompiler);
procedure SIRegister_TCustomRadioGroup(CL: TPSPascalCompiler);
procedure SIRegister_THeader(CL: TPSPascalCompiler);
procedure SIRegister_TNotebook(CL: TPSPascalCompiler);
procedure SIRegister_TPage(CL: TPSPascalCompiler);
procedure SIRegister_TPanel(CL: TPSPascalCompiler);
procedure SIRegister_TCustomPanel(CL: TPSPascalCompiler);
procedure SIRegister_TTimer(CL: TPSPascalCompiler);
procedure SIRegister_TBevel(CL: TPSPascalCompiler);
procedure SIRegister_TImage(CL: TPSPascalCompiler);
procedure SIRegister_TPaintBox(CL: TPSPascalCompiler);
procedure SIRegister_TShape(CL: TPSPascalCompiler);
procedure SIRegister_ExtCtrls(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_ExtCtrls_Routines(S: TPSExec);
procedure RIRegister_TControlBar(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomControlBar(CL: TPSRuntimeClassImporter);
procedure RIRegister_TSplitter(CL: TPSRuntimeClassImporter);
procedure RIRegister_TRadioGroup(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomRadioGroup(CL: TPSRuntimeClassImporter);
procedure RIRegister_THeader(CL: TPSRuntimeClassImporter);
procedure RIRegister_TNotebook(CL: TPSRuntimeClassImporter);
procedure RIRegister_TPage(CL: TPSRuntimeClassImporter);
procedure RIRegister_TPanel(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomPanel(CL: TPSRuntimeClassImporter);
procedure RIRegister_TTimer(CL: TPSRuntimeClassImporter);
procedure RIRegister_TBevel(CL: TPSRuntimeClassImporter);
procedure RIRegister_TImage(CL: TPSRuntimeClassImporter);
procedure RIRegister_TPaintBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_TShape(CL: TPSRuntimeClassImporter);
procedure RIRegister_ExtCtrls(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TControlBar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomControlBar', 'TControlBar') do
  with CL.AddClass(CL.FindClass('TCustomControlBar'), TControlBar) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomControlBar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomControl', 'TCustomControlBar') do
  with CL.AddClass(CL.FindClass('TCustomControl'), TCustomControlBar) do
  begin
    RegisterMethod('Procedure StickControls');
    RegisterProperty('Picture', 'TPicture', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TSplitter(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicControl', 'TSplitter') do
  with CL.AddClass(CL.FindClass('TGraphicControl'), TSplitter) do
  begin
    RegisterProperty('AutoSnap', 'Boolean', iptrw);
    RegisterProperty('Beveled', 'Boolean', iptrw);
    RegisterProperty('MinSize', 'NaturalNumber', iptrw);
    RegisterProperty('ResizeStyle', 'TResizeStyle', iptrw);
    RegisterProperty('OnCanResize', 'TCanResizeEvent', iptrw);
    RegisterProperty('OnMoved', 'TNotifyEvent', iptrw);
    RegisterProperty('OnPaint', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TRadioGroup(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomRadioGroup', 'TRadioGroup') do
  with CL.AddClass(CL.FindClass('TCustomRadioGroup'), TRadioGroup) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomRadioGroup(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomGroupBox', 'TCustomRadioGroup') do
  with CL.AddClass(CL.FindClass('TCustomGroupBox'), TCustomRadioGroup) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_THeader(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomControl', 'THeader') do
  with CL.AddClass(CL.FindClass('TCustomControl'), THeader) do
  begin
    RegisterProperty('SectionWidth', 'Integer Integer', iptrw);
    RegisterProperty('AllowResize', 'Boolean', iptrw);
    RegisterProperty('BorderStyle', 'TBorderStyle', iptrw);
    RegisterProperty('Sections', 'TStrings', iptrw);
    RegisterProperty('OnSizing', 'TSectionEvent', iptrw);
    RegisterProperty('OnSized', 'TSectionEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TNotebook(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomControl', 'TNotebook') do
  with CL.AddClass(CL.FindClass('TCustomControl'), TNotebook) do
  begin
    RegisterProperty('ActivePage', 'string', iptrw);
    RegisterProperty('PageIndex', 'Integer', iptrw);
    RegisterProperty('Pages', 'TStrings', iptrw);
    RegisterProperty('OnPageChanged', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TPage(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomControl', 'TPage') do
  with CL.AddClass(CL.FindClass('TCustomControl'), TPage) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TPanel(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomPanel', 'TPanel') do
  with CL.AddClass(CL.FindClass('TCustomPanel'), TPanel) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomPanel(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomControl', 'TCustomPanel') do
  with CL.AddClass(CL.FindClass('TCustomControl'), TCustomPanel) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TTimer(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TTimer') do
  with CL.AddClass(CL.FindClass('TComponent'), TTimer) do
  begin
    RegisterProperty('Enabled', 'Boolean', iptrw);
    RegisterProperty('Interval', 'Cardinal', iptrw);
    RegisterProperty('OnTimer', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TBevel(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicControl', 'TBevel') do
  with CL.AddClass(CL.FindClass('TGraphicControl'), TBevel) do
  begin
    RegisterProperty('Shape', 'TBevelShape', iptrw);
    RegisterProperty('Style', 'TBevelStyle', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TImage(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicControl', 'TImage') do
  with CL.AddClass(CL.FindClass('TGraphicControl'), TImage) do
  begin
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('Center', 'Boolean', iptrw);
    RegisterProperty('IncrementalDisplay', 'Boolean', iptrw);
    RegisterProperty('Picture', 'TPicture', iptrw);
    RegisterProperty('Stretch', 'Boolean', iptrw);
    RegisterProperty('Transparent', 'Boolean', iptrw);
    RegisterProperty('OnProgress', 'TProgressEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TPaintBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicControl', 'TPaintBox') do
  with CL.AddClass(CL.FindClass('TGraphicControl'), TPaintBox) do
  begin
    RegisterProperty('OnPaint', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TShape(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicControl', 'TShape') do
  with CL.AddClass(CL.FindClass('TGraphicControl'), TShape) do
  begin
    RegisterMethod('Procedure StyleChanged( Sender : TObject)');
    RegisterProperty('Brush', 'TBrush', iptrw);
    RegisterProperty('Pen', 'TPen', iptrw);
    RegisterProperty('Shape', 'TShapeType', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_ExtCtrls(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TShapeType', '( stRectangle, stSquare, stRoundRect, stRoundSquar'
    + 'e, stEllipse, stCircle )');
  SIRegister_TShape(CL);
  SIRegister_TPaintBox(CL);
  SIRegister_TImage(CL);
  CL.AddTypeS('TBevelStyle', '( bsLowered, bsRaised )');
  CL.AddTypeS('TBevelShape', '( bsBox, bsFrame, bsTopLine, bsBottomLine, bsLeft'
    + 'Line, bsRightLine, bsSpacer )');
  SIRegister_TBevel(CL);
  SIRegister_TTimer(CL);
  CL.AddTypeS('TPanelBevel', 'TBevelCut');
  SIRegister_TCustomPanel(CL);
  SIRegister_TPanel(CL);
  SIRegister_TPage(CL);
  SIRegister_TNotebook(CL);
  CL.AddTypeS('TSectionEvent', 'Procedure ( Sender : TObject; ASection, AWidth '
    + ': Integer)');
  SIRegister_THeader(CL);
  SIRegister_TCustomRadioGroup(CL);
  SIRegister_TRadioGroup(CL);
  CL.AddTypeS('NaturalNumber', 'Integer');
  CL.AddTypeS('TCanResizeEvent', 'Procedure ( Sender : TObject; var NewSize : I'
    + 'nteger; var Accept : Boolean)');
  CL.AddTypeS('TResizeStyle', '( rsNone, rsLine, rsUpdate, rsPattern )');
  SIRegister_TSplitter(CL);
  CL.AddTypeS('TBandPaintOption', '( bpoGrabber, bpoFrame )');
  CL.AddTypeS('TBandPaintOptions', 'set of TBandPaintOption');
  CL.AddTypeS('TBandDragEvent', 'Procedure ( Sender : TObject; Control : TContr'
    + 'ol; var Drag : Boolean)');
  CL.AddTypeS('TBandInfoEvent', 'Procedure ( Sender : TObject; Control : TContr'
    + 'ol; var Insets : TRect; var PreferredSize, RowCount : Integer)');
  CL.AddTypeS('TBandMoveEvent', 'Procedure ( Sender : TObject; Control : TContr'
    + 'ol; var ARect : TRect)');
  CL.AddTypeS('TBandPaintEvent', 'Procedure ( Sender : TObject; Control : TCont'
    + 'rol; Canvas : TCanvas; var ARect : TRect; var Options : TBandPaintOptions)');
  CL.AddTypeS('TRowSize', 'Integer');
  SIRegister_TCustomControlBar(CL);
  SIRegister_TControlBar(CL);
  CL.AddDelphiFunction('Procedure Frame3D( Canvas : TCanvas; var Rect : TRect; TopColor, BottomColor : TColor; Width : Integer)');
  CL.AddDelphiFunction('Procedure NotebookHandlesNeeded( Notebook : TNotebook)');
end;

(* === run-time registration functions === *)

procedure TCustomControlBarPicture_W(Self: TCustomControlBar; const T: TPicture);
begin
  Self.Picture := T;
end;

procedure TCustomControlBarPicture_R(Self: TCustomControlBar; var T: TPicture);
begin
  T := Self.Picture;
end;

procedure TSplitterOnPaint_W(Self: TSplitter; const T: TNotifyEvent);
begin
  Self.OnPaint := T;
end;

procedure TSplitterOnPaint_R(Self: TSplitter; var T: TNotifyEvent);
begin
  T := Self.OnPaint;
end;

procedure TSplitterOnMoved_W(Self: TSplitter; const T: TNotifyEvent);
begin
  Self.OnMoved := T;
end;

procedure TSplitterOnMoved_R(Self: TSplitter; var T: TNotifyEvent);
begin
  T := Self.OnMoved;
end;

procedure TSplitterOnCanResize_W(Self: TSplitter; const T: TCanResizeEvent);
begin
  Self.OnCanResize := T;
end;

procedure TSplitterOnCanResize_R(Self: TSplitter; var T: TCanResizeEvent);
begin
  T := Self.OnCanResize;
end;

procedure TSplitterResizeStyle_W(Self: TSplitter; const T: TResizeStyle);
begin
  Self.ResizeStyle := T;
end;

procedure TSplitterResizeStyle_R(Self: TSplitter; var T: TResizeStyle);
begin
  T := Self.ResizeStyle;
end;

procedure TSplitterMinSize_W(Self: TSplitter; const T: NaturalNumber);
begin
  Self.MinSize := T;
end;

procedure TSplitterMinSize_R(Self: TSplitter; var T: NaturalNumber);
begin
  T := Self.MinSize;
end;

procedure TSplitterBeveled_W(Self: TSplitter; const T: Boolean);
begin
  Self.Beveled := T;
end;

procedure TSplitterBeveled_R(Self: TSplitter; var T: Boolean);
begin
  T := Self.Beveled;
end;

procedure TSplitterAutoSnap_W(Self: TSplitter; const T: Boolean);
begin
  Self.AutoSnap := T;
end;

procedure TSplitterAutoSnap_R(Self: TSplitter; var T: Boolean);
begin
  T := Self.AutoSnap;
end;

procedure THeaderOnSized_W(Self: THeader; const T: TSectionEvent);
begin
  Self.OnSized := T;
end;

procedure THeaderOnSized_R(Self: THeader; var T: TSectionEvent);
begin
  T := Self.OnSized;
end;

procedure THeaderOnSizing_W(Self: THeader; const T: TSectionEvent);
begin
  Self.OnSizing := T;
end;

procedure THeaderOnSizing_R(Self: THeader; var T: TSectionEvent);
begin
  T := Self.OnSizing;
end;

procedure THeaderSections_W(Self: THeader; const T: TStrings);
begin
  Self.Sections := T;
end;

procedure THeaderSections_R(Self: THeader; var T: TStrings);
begin
  T := Self.Sections;
end;

procedure THeaderBorderStyle_W(Self: THeader; const T: TBorderStyle);
begin
  Self.BorderStyle := T;
end;

procedure THeaderBorderStyle_R(Self: THeader; var T: TBorderStyle);
begin
  T := Self.BorderStyle;
end;

procedure THeaderAllowResize_W(Self: THeader; const T: Boolean);
begin
  Self.AllowResize := T;
end;

procedure THeaderAllowResize_R(Self: THeader; var T: Boolean);
begin
  T := Self.AllowResize;
end;

procedure THeaderSectionWidth_W(Self: THeader; const T: Integer; const t1: Integer);
begin
  Self.SectionWidth[t1] := T;
end;

procedure THeaderSectionWidth_R(Self: THeader; var T: Integer; const t1: Integer);
begin
  T := Self.SectionWidth[t1];
end;

procedure TNotebookOnPageChanged_W(Self: TNotebook; const T: TNotifyEvent);
begin
  Self.OnPageChanged := T;
end;

procedure TNotebookOnPageChanged_R(Self: TNotebook; var T: TNotifyEvent);
begin
  T := Self.OnPageChanged;
end;

procedure TNotebookPages_W(Self: TNotebook; const T: TStrings);
begin
  Self.Pages := T;
end;

procedure TNotebookPages_R(Self: TNotebook; var T: TStrings);
begin
  T := Self.Pages;
end;

procedure TNotebookPageIndex_W(Self: TNotebook; const T: Integer);
begin
  Self.PageIndex := T;
end;

procedure TNotebookPageIndex_R(Self: TNotebook; var T: Integer);
begin
  T := Self.PageIndex;
end;

procedure TNotebookActivePage_W(Self: TNotebook; const T: string);
begin
  Self.ActivePage := T;
end;

procedure TNotebookActivePage_R(Self: TNotebook; var T: string);
begin
  T := Self.ActivePage;
end;

procedure TTimerOnTimer_W(Self: TTimer; const T: TNotifyEvent);
begin
  Self.OnTimer := T;
end;

procedure TTimerOnTimer_R(Self: TTimer; var T: TNotifyEvent);
begin
  T := Self.OnTimer;
end;

procedure TTimerInterval_W(Self: TTimer; const T: Cardinal);
begin
  Self.Interval := T;
end;

procedure TTimerInterval_R(Self: TTimer; var T: Cardinal);
begin
  T := Self.Interval;
end;

procedure TTimerEnabled_W(Self: TTimer; const T: Boolean);
begin
  Self.Enabled := T;
end;

procedure TTimerEnabled_R(Self: TTimer; var T: Boolean);
begin
  T := Self.Enabled;
end;

procedure TBevelStyle_W(Self: TBevel; const T: TBevelStyle);
begin
  Self.Style := T;
end;

procedure TBevelStyle_R(Self: TBevel; var T: TBevelStyle);
begin
  T := Self.Style;
end;

procedure TBevelShape_W(Self: TBevel; const T: TBevelShape);
begin
  Self.Shape := T;
end;

procedure TBevelShape_R(Self: TBevel; var T: TBevelShape);
begin
  T := Self.Shape;
end;

procedure TImageOnProgress_W(Self: TImage; const T: TProgressEvent);
begin
  Self.OnProgress := T;
end;

procedure TImageOnProgress_R(Self: TImage; var T: TProgressEvent);
begin
  T := Self.OnProgress;
end;

procedure TImageTransparent_W(Self: TImage; const T: Boolean);
begin
  Self.Transparent := T;
end;

procedure TImageTransparent_R(Self: TImage; var T: Boolean);
begin
  T := Self.Transparent;
end;

procedure TImageStretch_W(Self: TImage; const T: Boolean);
begin
  Self.Stretch := T;
end;

procedure TImageStretch_R(Self: TImage; var T: Boolean);
begin
  T := Self.Stretch;
end;

procedure TImagePicture_W(Self: TImage; const T: TPicture);
begin
  Self.Picture := T;
end;

procedure TImagePicture_R(Self: TImage; var T: TPicture);
begin
  T := Self.Picture;
end;

procedure TImageIncrementalDisplay_W(Self: TImage; const T: Boolean);
begin
  Self.IncrementalDisplay := T;
end;

procedure TImageIncrementalDisplay_R(Self: TImage; var T: Boolean);
begin
  T := Self.IncrementalDisplay;
end;

procedure TImageCenter_W(Self: TImage; const T: Boolean);
begin
  Self.Center := T;
end;

procedure TImageCenter_R(Self: TImage; var T: Boolean);
begin
  T := Self.Center;
end;

procedure TImageCanvas_R(Self: TImage; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure TPaintBoxOnPaint_W(Self: TPaintBox; const T: TNotifyEvent);
begin
  Self.OnPaint := T;
end;

procedure TPaintBoxOnPaint_R(Self: TPaintBox; var T: TNotifyEvent);
begin
  T := Self.OnPaint;
end;

procedure TShapeShape_W(Self: TShape; const T: TShapeType);
begin
  Self.Shape := T;
end;

procedure TShapeShape_R(Self: TShape; var T: TShapeType);
begin
  T := Self.Shape;
end;

procedure TShapePen_W(Self: TShape; const T: TPen);
begin
  Self.Pen := T;
end;

procedure TShapePen_R(Self: TShape; var T: TPen);
begin
  T := Self.Pen;
end;

procedure TShapeBrush_W(Self: TShape; const T: TBrush);
begin
  Self.Brush := T;
end;

procedure TShapeBrush_R(Self: TShape; var T: TBrush);
begin
  T := Self.Brush;
end;

procedure RIRegister_ExtCtrls_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@Frame3D, 'Frame3D', cdRegister);
  S.RegisterDelphiFunction(@NotebookHandlesNeeded, 'NotebookHandlesNeeded', cdRegister);
end;

procedure RIRegister_TControlBar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TControlBar) do
  begin
  end;
end;

procedure RIRegister_TCustomControlBar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomControlBar) do
  begin
    RegisterVirtualMethod(@TCustomControlBar.StickControls, 'StickControls');
    RegisterPropertyHelper(@TCustomControlBarPicture_R, @TCustomControlBarPicture_W, 'Picture');
  end;
end;

procedure RIRegister_TSplitter(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TSplitter) do
  begin
    RegisterPropertyHelper(@TSplitterAutoSnap_R, @TSplitterAutoSnap_W, 'AutoSnap');
    RegisterPropertyHelper(@TSplitterBeveled_R, @TSplitterBeveled_W, 'Beveled');
    RegisterPropertyHelper(@TSplitterMinSize_R, @TSplitterMinSize_W, 'MinSize');
    RegisterPropertyHelper(@TSplitterResizeStyle_R, @TSplitterResizeStyle_W, 'ResizeStyle');
    RegisterPropertyHelper(@TSplitterOnCanResize_R, @TSplitterOnCanResize_W, 'OnCanResize');
    RegisterPropertyHelper(@TSplitterOnMoved_R, @TSplitterOnMoved_W, 'OnMoved');
    RegisterPropertyHelper(@TSplitterOnPaint_R, @TSplitterOnPaint_W, 'OnPaint');
  end;
end;

procedure RIRegister_TRadioGroup(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TRadioGroup) do
  begin
  end;
end;

procedure RIRegister_TCustomRadioGroup(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomRadioGroup) do
  begin
  end;
end;

procedure RIRegister_THeader(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(THeader) do
  begin
    RegisterPropertyHelper(@THeaderSectionWidth_R, @THeaderSectionWidth_W, 'SectionWidth');
    RegisterPropertyHelper(@THeaderAllowResize_R, @THeaderAllowResize_W, 'AllowResize');
    RegisterPropertyHelper(@THeaderBorderStyle_R, @THeaderBorderStyle_W, 'BorderStyle');
    RegisterPropertyHelper(@THeaderSections_R, @THeaderSections_W, 'Sections');
    RegisterPropertyHelper(@THeaderOnSizing_R, @THeaderOnSizing_W, 'OnSizing');
    RegisterPropertyHelper(@THeaderOnSized_R, @THeaderOnSized_W, 'OnSized');
  end;
end;

procedure RIRegister_TNotebook(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TNotebook) do
  begin
    RegisterPropertyHelper(@TNotebookActivePage_R, @TNotebookActivePage_W, 'ActivePage');
    RegisterPropertyHelper(@TNotebookPageIndex_R, @TNotebookPageIndex_W, 'PageIndex');
    RegisterPropertyHelper(@TNotebookPages_R, @TNotebookPages_W, 'Pages');
    RegisterPropertyHelper(@TNotebookOnPageChanged_R, @TNotebookOnPageChanged_W, 'OnPageChanged');
  end;
end;

procedure RIRegister_TPage(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TPage) do
  begin
  end;
end;

procedure RIRegister_TPanel(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TPanel) do
  begin
  end;
end;

procedure RIRegister_TCustomPanel(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomPanel) do
  begin
  end;
end;

procedure RIRegister_TTimer(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TTimer) do
  begin
    RegisterPropertyHelper(@TTimerEnabled_R, @TTimerEnabled_W, 'Enabled');
    RegisterPropertyHelper(@TTimerInterval_R, @TTimerInterval_W, 'Interval');
    RegisterPropertyHelper(@TTimerOnTimer_R, @TTimerOnTimer_W, 'OnTimer');
  end;
end;

procedure RIRegister_TBevel(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TBevel) do
  begin
    RegisterPropertyHelper(@TBevelShape_R, @TBevelShape_W, 'Shape');
    RegisterPropertyHelper(@TBevelStyle_R, @TBevelStyle_W, 'Style');
  end;
end;

procedure RIRegister_TImage(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TImage) do
  begin
    RegisterPropertyHelper(@TImageCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@TImageCenter_R, @TImageCenter_W, 'Center');
    RegisterPropertyHelper(@TImageIncrementalDisplay_R, @TImageIncrementalDisplay_W, 'IncrementalDisplay');
    RegisterPropertyHelper(@TImagePicture_R, @TImagePicture_W, 'Picture');
    RegisterPropertyHelper(@TImageStretch_R, @TImageStretch_W, 'Stretch');
    RegisterPropertyHelper(@TImageTransparent_R, @TImageTransparent_W, 'Transparent');
    RegisterPropertyHelper(@TImageOnProgress_R, @TImageOnProgress_W, 'OnProgress');
  end;
end;

procedure RIRegister_TPaintBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TPaintBox) do
  begin
    RegisterPropertyHelper(@TPaintBoxOnPaint_R, @TPaintBoxOnPaint_W, 'OnPaint');
  end;
end;

procedure RIRegister_TShape(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TShape) do
  begin
    RegisterMethod(@TShape.StyleChanged, 'StyleChanged');
    RegisterPropertyHelper(@TShapeBrush_R, @TShapeBrush_W, 'Brush');
    RegisterPropertyHelper(@TShapePen_R, @TShapePen_W, 'Pen');
    RegisterPropertyHelper(@TShapeShape_R, @TShapeShape_W, 'Shape');
  end;
end;

procedure RIRegister_ExtCtrls(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TShape(CL);
  RIRegister_TPaintBox(CL);
  RIRegister_TImage(CL);
  RIRegister_TBevel(CL);
  RIRegister_TTimer(CL);
  RIRegister_TCustomPanel(CL);
  RIRegister_TPanel(CL);
  RIRegister_TPage(CL);
  RIRegister_TNotebook(CL);
  RIRegister_THeader(CL);
  RIRegister_TCustomRadioGroup(CL);
  RIRegister_TRadioGroup(CL);
  RIRegister_TSplitter(CL);
  RIRegister_TCustomControlBar(CL);
  RIRegister_TControlBar(CL);
end;

{ TPSImport_ExtCtrls }

procedure TPSImport_ExtCtrls.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ExtCtrls(CompExec.Comp);
end;

procedure TPSImport_ExtCtrls.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_ExtCtrls(ri);
  RIRegister_ExtCtrls_Routines(CompExec.Exec); // comment it if no routines
end;

end.




