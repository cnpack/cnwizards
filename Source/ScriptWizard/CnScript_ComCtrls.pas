{******************************************************************************}
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

unit CnScript_ComCtrls;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 ComCtrls 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Graphics, Classes, Controls, ImgList, Menus, ComCtrls,
  CommCtrl, Forms, uPSComponent, uPSRuntime, uPSCompiler;

type
  TPSImport_ComCtrls = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TPageScroller(CL: TPSPascalCompiler);
procedure SIRegister_TDateTimePicker(CL: TPSPascalCompiler);
procedure SIRegister_TMonthCalendar(CL: TPSPascalCompiler);
procedure SIRegister_TCommonCalendar(CL: TPSPascalCompiler);
procedure SIRegister_TMonthCalColors(CL: TPSPascalCompiler);
procedure SIRegister_TCoolBar(CL: TPSPascalCompiler);
procedure SIRegister_TCoolBands(CL: TPSPascalCompiler);
procedure SIRegister_TCoolBand(CL: TPSPascalCompiler);
procedure SIRegister_TToolBar(CL: TPSPascalCompiler);
procedure SIRegister_TToolButton(CL: TPSPascalCompiler);
procedure SIRegister_TAnimate(CL: TPSPascalCompiler);
procedure SIRegister_TListView(CL: TPSPascalCompiler);
procedure SIRegister_TCustomListView(CL: TPSPascalCompiler);
procedure SIRegister_TIconOptions(CL: TPSPascalCompiler);
procedure SIRegister_TWorkAreas(CL: TPSPascalCompiler);
procedure SIRegister_TWorkArea(CL: TPSPascalCompiler);
procedure SIRegister_TListItems(CL: TPSPascalCompiler);
procedure SIRegister_TListItem(CL: TPSPascalCompiler);
procedure SIRegister_TListColumns(CL: TPSPascalCompiler);
procedure SIRegister_TListColumn(CL: TPSPascalCompiler);
procedure SIRegister_THotKey(CL: TPSPascalCompiler);
procedure SIRegister_TCustomHotKey(CL: TPSPascalCompiler);
procedure SIRegister_TUpDown(CL: TPSPascalCompiler);
procedure SIRegister_TCustomUpDown(CL: TPSPascalCompiler);
procedure SIRegister_TRichEdit(CL: TPSPascalCompiler);
procedure SIRegister_TCustomRichEdit(CL: TPSPascalCompiler);
procedure SIRegister_TConversion(CL: TPSPascalCompiler);
procedure SIRegister_TParaAttributes(CL: TPSPascalCompiler);
procedure SIRegister_TTextAttributes(CL: TPSPascalCompiler);
procedure SIRegister_TProgressBar(CL: TPSPascalCompiler);
procedure SIRegister_TTrackBar(CL: TPSPascalCompiler);
procedure SIRegister_TTreeView(CL: TPSPascalCompiler);
procedure SIRegister_TCustomTreeView(CL: TPSPascalCompiler);
procedure SIRegister_TTreeNodes(CL: TPSPascalCompiler);
procedure SIRegister_TTreeNode(CL: TPSPascalCompiler);
procedure SIRegister_THeaderControl(CL: TPSPascalCompiler);
procedure SIRegister_THeaderSections(CL: TPSPascalCompiler);
procedure SIRegister_THeaderSection(CL: TPSPascalCompiler);
procedure SIRegister_TStatusBar(CL: TPSPascalCompiler);
procedure SIRegister_TStatusPanels(CL: TPSPascalCompiler);
procedure SIRegister_TStatusPanel(CL: TPSPascalCompiler);
procedure SIRegister_TPageControl(CL: TPSPascalCompiler);
procedure SIRegister_TTabSheet(CL: TPSPascalCompiler);
procedure SIRegister_TTabControl(CL: TPSPascalCompiler);
procedure SIRegister_TCustomTabControl(CL: TPSPascalCompiler);
procedure SIRegister_ComCtrls(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_ComCtrls_Routines(S: TPSExec);
procedure RIRegister_TPageScroller(CL: TPSRuntimeClassImporter);
procedure RIRegister_TDateTimePicker(CL: TPSRuntimeClassImporter);
procedure RIRegister_TMonthCalendar(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCommonCalendar(CL: TPSRuntimeClassImporter);
procedure RIRegister_TMonthCalColors(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCoolBar(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCoolBands(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCoolBand(CL: TPSRuntimeClassImporter);
procedure RIRegister_TToolBar(CL: TPSRuntimeClassImporter);
procedure RIRegister_TToolButton(CL: TPSRuntimeClassImporter);
procedure RIRegister_TAnimate(CL: TPSRuntimeClassImporter);
procedure RIRegister_TListView(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomListView(CL: TPSRuntimeClassImporter);
procedure RIRegister_TIconOptions(CL: TPSRuntimeClassImporter);
procedure RIRegister_TWorkAreas(CL: TPSRuntimeClassImporter);
procedure RIRegister_TWorkArea(CL: TPSRuntimeClassImporter);
procedure RIRegister_TListItems(CL: TPSRuntimeClassImporter);
procedure RIRegister_TListItem(CL: TPSRuntimeClassImporter);
procedure RIRegister_TListColumns(CL: TPSRuntimeClassImporter);
procedure RIRegister_TListColumn(CL: TPSRuntimeClassImporter);
procedure RIRegister_THotKey(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomHotKey(CL: TPSRuntimeClassImporter);
procedure RIRegister_TUpDown(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomUpDown(CL: TPSRuntimeClassImporter);
procedure RIRegister_TRichEdit(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomRichEdit(CL: TPSRuntimeClassImporter);
procedure RIRegister_TConversion(CL: TPSRuntimeClassImporter);
procedure RIRegister_TParaAttributes(CL: TPSRuntimeClassImporter);
procedure RIRegister_TTextAttributes(CL: TPSRuntimeClassImporter);
procedure RIRegister_TProgressBar(CL: TPSRuntimeClassImporter);
procedure RIRegister_TTrackBar(CL: TPSRuntimeClassImporter);
procedure RIRegister_TTreeView(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomTreeView(CL: TPSRuntimeClassImporter);
procedure RIRegister_TTreeNodes(CL: TPSRuntimeClassImporter);
procedure RIRegister_TTreeNode(CL: TPSRuntimeClassImporter);
procedure RIRegister_THeaderControl(CL: TPSRuntimeClassImporter);
procedure RIRegister_THeaderSections(CL: TPSRuntimeClassImporter);
procedure RIRegister_THeaderSection(CL: TPSRuntimeClassImporter);
procedure RIRegister_TStatusBar(CL: TPSRuntimeClassImporter);
procedure RIRegister_TStatusPanels(CL: TPSRuntimeClassImporter);
procedure RIRegister_TStatusPanel(CL: TPSRuntimeClassImporter);
procedure RIRegister_TPageControl(CL: TPSRuntimeClassImporter);
procedure RIRegister_TTabSheet(CL: TPSRuntimeClassImporter);
procedure RIRegister_TTabControl(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomTabControl(CL: TPSRuntimeClassImporter);
procedure RIRegister_ComCtrls(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TPageScroller(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TPageScroller') do
  with CL.AddClass(CL.FindClass('TWinControl'), TPageScroller) do
  begin
    RegisterMethod('Function GetButtonState( Button : TPageScrollerButton) : TPageScrollerButtonState');
    RegisterProperty('AutoScroll', 'Boolean', iptrw);
    RegisterProperty('ButtonSize', 'Integer', iptrw);
    RegisterProperty('Control', 'TWinControl', iptrw);
    RegisterProperty('DragScroll', 'Boolean', iptrw);
    RegisterProperty('Margin', 'Integer', iptrw);
    RegisterProperty('Orientation', 'TPageScrollerOrientation', iptrw);
    RegisterProperty('Position', 'Integer', iptrw);
    RegisterProperty('OnScroll', 'TPageScrollEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TDateTimePicker(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCommonCalendar', 'TDateTimePicker') do
  with CL.AddClass(CL.FindClass('TCommonCalendar'), TDateTimePicker) do
  begin
    RegisterProperty('DroppedDown', 'Boolean', iptr);
    RegisterProperty('CalAlignment', 'TDTCalAlignment', iptrw);
    RegisterProperty('Time', 'TTime', iptrw);
    RegisterProperty('ShowCheckbox', 'Boolean', iptrw);
    RegisterProperty('Checked', 'Boolean', iptrw);
    RegisterProperty('DateFormat', 'TDTDateFormat', iptrw);
    RegisterProperty('DateMode', 'TDTDateMode', iptrw);
    RegisterProperty('Kind', 'TDateTimeKind', iptrw);
    RegisterProperty('ParseInput', 'Boolean', iptrw);
    RegisterProperty('OnCloseUp', 'TNotifyEvent', iptrw);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
    RegisterProperty('OnDropDown', 'TNotifyEvent', iptrw);
    RegisterProperty('OnUserInput', 'TDTParseInputEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TMonthCalendar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCommonCalendar', 'TMonthCalendar') do
  with CL.AddClass(CL.FindClass('TCommonCalendar'), TMonthCalendar) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCommonCalendar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCommonCalendar') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCommonCalendar) do
  begin
    RegisterMethod('Procedure BoldDays( Days : array of LongWord; var MonthBoldInfo : LongWord)');
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TMonthCalColors(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TMonthCalColors') do
  with CL.AddClass(CL.FindClass('TPersistent'), TMonthCalColors) do
  begin
    RegisterMethod('Constructor Create( AOwner : TCommonCalendar)');
    RegisterProperty('BackColor', 'TColor', iptrw);
    RegisterProperty('TextColor', 'TColor', iptrw);
    RegisterProperty('TitleBackColor', 'TColor', iptrw);
    RegisterProperty('TitleTextColor', 'TColor', iptrw);
    RegisterProperty('MonthBackColor', 'TColor', iptrw);
    RegisterProperty('TrailingTextColor', 'TColor', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCoolBar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TToolWindow', 'TCoolBar') do
  with CL.AddClass(CL.FindClass('TToolWindow'), TCoolBar) do
  begin
    RegisterProperty('BandBorderStyle', 'TBorderStyle', iptrw);
    RegisterProperty('BandMaximize', 'TCoolBandMaximize', iptrw);
    RegisterProperty('Bands', 'TCoolBands', iptrw);
    RegisterProperty('FixedSize', 'Boolean', iptrw);
    RegisterProperty('FixedOrder', 'Boolean', iptrw);
    RegisterProperty('Images', 'TCustomImageList', iptrw);
    RegisterProperty('Bitmap', 'TBitmap', iptrw);
    RegisterProperty('ShowText', 'Boolean', iptrw);
    RegisterProperty('Vertical', 'Boolean', iptrw);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCoolBands(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCollection', 'TCoolBands') do
  with CL.AddClass(CL.FindClass('TCollection'), TCoolBands) do
  begin
    RegisterMethod('Constructor Create( CoolBar : TCoolBar)');
    RegisterMethod('Function Add : TCoolBand');
    RegisterMethod('Function FindBand( AControl : TControl) : TCoolBand');
    RegisterProperty('CoolBar', 'TCoolBar', iptr);
    RegisterProperty('Items', 'TCoolBand Integer', iptrw);
    SetDefaultPropery('Items');
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCoolBand(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCollectionItem', 'TCoolBand') do
  with CL.AddClass(CL.FindClass('TCollectionItem'), TCoolBand) do
  begin
    RegisterProperty('Height', 'Integer', iptr);
    RegisterProperty('Bitmap', 'TBitmap', iptrw);
    RegisterProperty('BorderStyle', 'TBorderStyle', iptrw);
    RegisterProperty('Break', 'Boolean', iptrw);
    RegisterProperty('Color', 'TColor', iptrw);
    RegisterProperty('Control', 'TWinControl', iptrw);
    RegisterProperty('FixedBackground', 'Boolean', iptrw);
    RegisterProperty('FixedSize', 'Boolean', iptrw);
    RegisterProperty('HorizontalOnly', 'Boolean', iptrw);
    RegisterProperty('ImageIndex', 'TImageIndex', iptrw);
    RegisterProperty('MinHeight', 'Integer', iptrw);
    RegisterProperty('MinWidth', 'Integer', iptrw);
    RegisterProperty('ParentColor', 'Boolean', iptrw);
    RegisterProperty('ParentBitmap', 'Boolean', iptrw);
    RegisterProperty('Text', 'string', iptrw);
    RegisterProperty('Visible', 'Boolean', iptrw);
    RegisterProperty('Width', 'Integer', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TToolBar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TToolWindow', 'TToolBar') do
  with CL.AddClass(CL.FindClass('TToolWindow'), TToolBar) do
  begin
    RegisterMethod('Function TrackMenu( Button : TToolButton) : Boolean');
    RegisterProperty('ButtonCount', 'Integer', iptr);
    RegisterProperty('Buttons', 'TToolButton Integer', iptr);
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('RowCount', 'Integer', iptr);
    RegisterProperty('ButtonHeight', 'Integer', iptrw);
    RegisterProperty('ButtonWidth', 'Integer', iptrw);
    RegisterProperty('DisabledImages', 'TCustomImageList', iptrw);
    RegisterProperty('Flat', 'Boolean', iptrw);
    RegisterProperty('HotImages', 'TCustomImageList', iptrw);
    RegisterProperty('Images', 'TCustomImageList', iptrw);
    RegisterProperty('Indent', 'Integer', iptrw);
    RegisterProperty('List', 'Boolean', iptrw);
    RegisterProperty('ShowCaptions', 'Boolean', iptrw);
    RegisterProperty('Transparent', 'Boolean', iptrw);
    RegisterProperty('Wrapable', 'Boolean', iptrw);
    RegisterProperty('OnAdvancedCustomDraw', 'TTBAdvancedCustomDrawEvent', iptrw);
    RegisterProperty('OnAdvancedCustomDrawButton', 'TTBAdvancedCustomDrawBtnEvent', iptrw);
    RegisterProperty('OnCustomDraw', 'TTBCustomDrawEvent', iptrw);
    RegisterProperty('OnCustomDrawButton', 'TTBCustomDrawBtnEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TToolButton(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicControl', 'TToolButton') do
  with CL.AddClass(CL.FindClass('TGraphicControl'), TToolButton) do
  begin
    RegisterMethod('Function CheckMenuDropdown : Boolean');
    RegisterProperty('Index', 'Integer', iptr);
    RegisterProperty('AllowAllUp', 'Boolean', iptrw);
    RegisterProperty('AutoSize', 'Boolean', iptrw);
    RegisterProperty('Down', 'Boolean', iptrw);
    RegisterProperty('DropdownMenu', 'TPopupMenu', iptrw);
    RegisterProperty('Grouped', 'Boolean', iptrw);
    RegisterProperty('ImageIndex', 'TImageIndex', iptrw);
    RegisterProperty('Indeterminate', 'Boolean', iptrw);
    RegisterProperty('Marked', 'Boolean', iptrw);
    RegisterProperty('MenuItem', 'TMenuItem', iptrw);
    RegisterProperty('Wrap', 'Boolean', iptrw);
    RegisterProperty('Style', 'TToolButtonStyle', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TAnimate(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TAnimate') do
  with CL.AddClass(CL.FindClass('TWinControl'), TAnimate) do
  begin
    RegisterProperty('FrameCount', 'Integer', iptr);
    RegisterProperty('FrameHeight', 'Integer', iptr);
    RegisterProperty('FrameWidth', 'Integer', iptr);
    RegisterProperty('Open', 'Boolean', iptrw);
    RegisterMethod('Procedure Play( FromFrame, ToFrame : Word; Count : Integer)');
    RegisterMethod('Procedure Reset');
    RegisterMethod('Procedure Seek( Frame : Smallint)');
    RegisterMethod('Procedure Stop');
    RegisterProperty('ResHandle', 'THandle', iptrw);
    RegisterProperty('ResId', 'Integer', iptrw);
    RegisterProperty('ResName', 'string', iptrw);
    RegisterProperty('Active', 'Boolean', iptrw);
    RegisterProperty('Center', 'Boolean', iptrw);
    RegisterProperty('CommonAVI', 'TCommonAVI', iptrw);
    RegisterProperty('FileName', 'string', iptrw);
    RegisterProperty('Repetitions', 'Integer', iptrw);
    RegisterProperty('StartFrame', 'Smallint', iptrw);
    RegisterProperty('StopFrame', 'Smallint', iptrw);
    RegisterProperty('Timers', 'Boolean', iptrw);
    RegisterProperty('Transparent', 'Boolean', iptrw);
    RegisterProperty('OnOpen', 'TNotifyEvent', iptrw);
    RegisterProperty('OnClose', 'TNotifyEvent', iptrw);
    RegisterProperty('OnStart', 'TNotifyEvent', iptrw);
    RegisterProperty('OnStop', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TListView(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomListView', 'TListView') do
  with CL.AddClass(CL.FindClass('TCustomListView'), TListView) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomListView(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCustomListView') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCustomListView) do
  begin
    RegisterMethod('Function AlphaSort : Boolean');
    RegisterMethod('Procedure Arrange( Code : TListArrangement)');
    RegisterMethod('Function FindCaption( StartIndex : Integer; Value : string; Partial, Inclusive, Wrap : Boolean) : TListItem');
    RegisterMethod('Function FindData( StartIndex : Integer; Value : Pointer; Inclusive, Wrap : Boolean) : TListItem');
    RegisterMethod('Function GetHitTestInfoAt( X, Y : Integer) : THitTests');
    RegisterMethod('Function GetItemAt( X, Y : Integer) : TListItem');
    RegisterMethod('Function GetNearestItem( Point : TPoint; Direction : TSearchDirection) : TListItem');
    RegisterMethod('Function GetNextItem( StartItem : TListItem; Direction : TSearchDirection; States : TItemStates) : TListItem');
    RegisterMethod('Function GetSearchString : string');
    RegisterMethod('Function IsEditing : Boolean');
    RegisterMethod('Procedure Scroll( DX, DY : Integer)');
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('Checkboxes', 'Boolean', iptrw);
    RegisterProperty('Column', 'TListColumn Integer', iptr);
    RegisterProperty('DropTarget', 'TListItem', iptrw);
    RegisterProperty('FlatScrollBars', 'Boolean', iptrw);
    RegisterProperty('FullDrag', 'Boolean', iptrw);
    RegisterProperty('GridLines', 'Boolean', iptrw);
    RegisterProperty('HotTrack', 'Boolean', iptrw);
    RegisterProperty('HotTrackStyles', 'TListHotTrackStyles', iptrw);
    RegisterProperty('ItemFocused', 'TListItem', iptrw);
    RegisterProperty('RowSelect', 'Boolean', iptrw);
    RegisterProperty('SelCount', 'Integer', iptr);
    RegisterProperty('Selected', 'TListItem', iptrw);
    RegisterMethod('Function CustomSort( SortProc : TLVCompare; lParam : Longint) : Boolean');
    RegisterMethod('Function StringWidth( S : string) : Integer');
    RegisterMethod('Procedure UpdateItems( FirstIndex, LastIndex : Integer)');
    RegisterProperty('TopItem', 'TListItem', iptr);
    RegisterProperty('ViewOrigin', 'TPoint', iptr);
    RegisterProperty('VisibleRowCount', 'Integer', iptr);
    RegisterProperty('BoundingRect', 'TRect', iptr);
    RegisterProperty('WorkAreas', 'TWorkAreas', iptr);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TIconOptions(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TIconOptions') do
  with CL.AddClass(CL.FindClass('TPersistent'), TIconOptions) do
  begin
    RegisterMethod('Constructor Create( AOwner : TCustomListView)');
    RegisterProperty('Arrangement', 'TIconArrangement', iptrw);
    RegisterProperty('AutoArrange', 'Boolean', iptrw);
    RegisterProperty('WrapText', 'Boolean', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TWorkAreas(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOwnedCollection', 'TWorkAreas') do
  with CL.AddClass(CL.FindClass('TOwnedCollection'), TWorkAreas) do
  begin
    RegisterMethod('Function Add : TWorkArea');
    RegisterMethod('Procedure Delete( Index : Integer)');
    RegisterMethod('Function Insert( Index : Integer) : TWorkArea');
    RegisterProperty('Items', 'TWorkArea Integer', iptrw);
    SetDefaultPropery('Items');
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TWorkArea(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCollectionItem', 'TWorkArea') do
  with CL.AddClass(CL.FindClass('TCollectionItem'), TWorkArea) do
  begin
    RegisterProperty('Rect', 'TRect', iptrw);
    RegisterProperty('Color', 'TColor', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TListItems(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TListItems') do
  with CL.AddClass(CL.FindClass('TPersistent'), TListItems) do
  begin
    RegisterMethod('Constructor Create( AOwner : TCustomListView)');
    RegisterMethod('Function Add : TListItem');
    RegisterMethod('Procedure BeginUpdate');
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure Delete( Index : Integer)');
    RegisterMethod('Procedure EndUpdate');
    RegisterMethod('Function IndexOf( Value : TListItem) : Integer');
    RegisterMethod('Function Insert( Index : Integer) : TListItem');
    RegisterProperty('Count', 'Integer', iptrw);
    RegisterProperty('Handle', 'HWND', iptr);
    RegisterProperty('Item', 'TListItem Integer', iptrw);
    SetDefaultPropery('Item');
    RegisterProperty('Owner', 'TCustomListView', iptr);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TListItem(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TListItem') do
  with CL.AddClass(CL.FindClass('TPersistent'), TListItem) do
  begin
    RegisterMethod('Constructor Create( AOwner : TListItems)');
    RegisterMethod('Procedure CancelEdit');
    RegisterMethod('Procedure Delete');
    RegisterMethod('Function DisplayRect( Code : TDisplayCode) : TRect');
    RegisterMethod('Function EditCaption : Boolean');
    RegisterMethod('Function GetPosition : TPoint');
    RegisterMethod('Procedure MakeVisible( PartialOK : Boolean)');
    RegisterMethod('Procedure Update');
    RegisterMethod('Procedure SetPosition( const Value : TPoint)');
    RegisterMethod('Function WorkArea : Integer');
    RegisterProperty('Caption', 'string', iptrw);
    RegisterProperty('Checked', 'Boolean', iptrw);
    RegisterProperty('Cut', 'Boolean', iptrw);
    RegisterProperty('Data', 'Pointer', iptrw);
    RegisterProperty('DropTarget', 'Boolean', iptrw);
    RegisterProperty('Focused', 'Boolean', iptrw);
    RegisterProperty('Handle', 'HWND', iptr);
    RegisterProperty('ImageIndex', 'TImageIndex', iptrw);
    RegisterProperty('Indent', 'Integer', iptrw);
    RegisterProperty('Index', 'Integer', iptr);
    RegisterProperty('Left', 'Integer', iptrw);
    RegisterProperty('ListView', 'TCustomListView', iptr);
    RegisterProperty('Owner', 'TListItems', iptr);
    RegisterProperty('OverlayIndex', 'TImageIndex', iptrw);
    RegisterProperty('Position', 'TPoint', iptrw);
    RegisterProperty('Selected', 'Boolean', iptrw);
    RegisterProperty('StateIndex', 'TImageIndex', iptrw);
    RegisterProperty('SubItems', 'TStrings', iptrw);
    RegisterProperty('SubItemImages', 'Integer Integer', iptrw);
    RegisterProperty('Top', 'Integer', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TListColumns(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCollection', 'TListColumns') do
  with CL.AddClass(CL.FindClass('TCollection'), TListColumns) do
  begin
    RegisterMethod('Constructor Create( AOwner : TCustomListView)');
    RegisterMethod('Function Add : TListColumn');
    RegisterProperty('Owner', 'TCustomListView', iptr);
    RegisterProperty('Items', 'TListColumn Integer', iptrw);
    SetDefaultPropery('Items');
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TListColumn(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCollectionItem', 'TListColumn') do
  with CL.AddClass(CL.FindClass('TCollectionItem'), TListColumn) do
  begin
    RegisterProperty('WidthType', 'TWidth', iptr);
    RegisterProperty('Alignment', 'TAlignment', iptrw);
    RegisterProperty('AutoSize', 'Boolean', iptrw);
    RegisterProperty('Caption', 'string', iptrw);
    RegisterProperty('ImageIndex', 'TImageIndex', iptrw);
    RegisterProperty('MaxWidth', 'TWidth', iptrw);
    RegisterProperty('MinWidth', 'TWidth', iptrw);
    RegisterProperty('Tag', 'Integer', iptrw);
    RegisterProperty('Width', 'TWidth', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_THotKey(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomHotKey', 'THotKey') do
  with CL.AddClass(CL.FindClass('TCustomHotKey'), THotKey) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomHotKey(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCustomHotKey') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCustomHotKey) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TUpDown(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomUpDown', 'TUpDown') do
  with CL.AddClass(CL.FindClass('TCustomUpDown'), TUpDown) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomUpDown(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCustomUpDown') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCustomUpDown) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TRichEdit(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomRichEdit', 'TRichEdit') do
  with CL.AddClass(CL.FindClass('TCustomRichEdit'), TRichEdit) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomRichEdit(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomMemo', 'TCustomRichEdit') do
  with CL.AddClass(CL.FindClass('TCustomMemo'), TCustomRichEdit) do
  begin
    RegisterMethod('Function FindText( const SearchStr : string; StartPos, Length : Integer; Options : TSearchTypes) : Integer');
    RegisterMethod('Procedure Print( const Caption : string)');
    RegisterMethod('Procedure RegisterConversionFormat( const AExtension : string; AConversionClass : TConversionClass)');
    RegisterProperty('DefaultConverter', 'TConversionClass', iptrw);
    RegisterProperty('DefAttributes', 'TTextAttributes', iptrw);
    RegisterProperty('SelAttributes', 'TTextAttributes', iptrw);
    RegisterProperty('PageRect', 'TRect', iptrw);
    RegisterProperty('Paragraph', 'TParaAttributes', iptr);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TConversion(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TConversion') do
  with CL.AddClass(CL.FindClass('TObject'), TConversion) do
  begin
    RegisterMethod('Function ConvertReadStream( Stream : TStream; Buffer : PChar; BufSize : Integer) : Integer');
    RegisterMethod('Function ConvertWriteStream( Stream : TStream; Buffer : PChar; BufSize : Integer) : Integer');
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TParaAttributes(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TParaAttributes') do
  with CL.AddClass(CL.FindClass('TPersistent'), TParaAttributes) do
  begin
    RegisterMethod('Constructor Create( AOwner : TCustomRichEdit)');
    RegisterProperty('Alignment', 'TAlignment', iptrw);
    RegisterProperty('FirstIndent', 'Longint', iptrw);
    RegisterProperty('LeftIndent', 'Longint', iptrw);
    RegisterProperty('Numbering', 'TNumberingStyle', iptrw);
    RegisterProperty('RightIndent', 'Longint', iptrw);
    RegisterProperty('Tab', 'Longint Byte', iptrw);
    RegisterProperty('TabCount', 'Integer', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TTextAttributes(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TTextAttributes') do
  with CL.AddClass(CL.FindClass('TPersistent'), TTextAttributes) do
  begin
    RegisterMethod('Constructor Create( AOwner : TCustomRichEdit; AttributeType : TAttributeType)');
    RegisterProperty('Charset', 'TFontCharset', iptrw);
    RegisterProperty('Color', 'TColor', iptrw);
    RegisterProperty('ConsistentAttributes', 'TConsistentAttributes', iptr);
    RegisterProperty('Name', 'TFontName', iptrw);
    RegisterProperty('Pitch', 'TFontPitch', iptrw);
    RegisterProperty('Size', 'Integer', iptrw);
    RegisterProperty('Style', 'TFontStyles', iptrw);
    RegisterProperty('Height', 'Integer', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TProgressBar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TProgressBar') do
  with CL.AddClass(CL.FindClass('TWinControl'), TProgressBar) do
  begin
    RegisterMethod('Procedure StepIt');
    RegisterMethod('Procedure StepBy( Delta : Integer)');
    RegisterProperty('Min', 'Integer', iptrw);
    RegisterProperty('Max', 'Integer', iptrw);
    RegisterProperty('Orientation', 'TProgressBarOrientation', iptrw);
    RegisterProperty('Position', 'Integer', iptrw);
    RegisterProperty('Smooth', 'Boolean', iptrw);
    RegisterProperty('Step', 'Integer', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TTrackBar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TTrackBar') do
  with CL.AddClass(CL.FindClass('TWinControl'), TTrackBar) do
  begin
    RegisterMethod('Procedure SetTick( Value : Integer)');
    RegisterProperty('LineSize', 'Integer', iptrw);
    RegisterProperty('Max', 'Integer', iptrw);
    RegisterProperty('Min', 'Integer', iptrw);
    RegisterProperty('Orientation', 'TTrackBarOrientation', iptrw);
    RegisterProperty('PageSize', 'Integer', iptrw);
    RegisterProperty('Frequency', 'Integer', iptrw);
    RegisterProperty('Position', 'Integer', iptrw);
    RegisterProperty('SliderVisible', 'Boolean', iptrw);
    RegisterProperty('SelEnd', 'Integer', iptrw);
    RegisterProperty('SelStart', 'Integer', iptrw);
    RegisterProperty('ThumbLength', 'Integer', iptrw);
    RegisterProperty('TickMarks', 'TTickMark', iptrw);
    RegisterProperty('TickStyle', 'TTickStyle', iptrw);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TTreeView(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomTreeView', 'TTreeView') do
  with CL.AddClass(CL.FindClass('TCustomTreeView'), TTreeView) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomTreeView(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCustomTreeView') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCustomTreeView) do
  begin
    RegisterMethod('Function AlphaSort : Boolean');
    RegisterMethod('Function CustomSort( SortProc : TTVCompare; Data : Longint) : Boolean');
    RegisterMethod('Procedure FullCollapse');
    RegisterMethod('Procedure FullExpand');
    RegisterMethod('Function GetHitTestInfoAt( X, Y : Integer) : THitTests');
    RegisterMethod('Function GetNodeAt( X, Y : Integer) : TTreeNode');
    RegisterMethod('Function IsEditing : Boolean');
    RegisterMethod('Procedure LoadFromFile( const FileName : string)');
    RegisterMethod('Procedure LoadFromStream( Stream : TStream)');
    RegisterMethod('Procedure SaveToFile( const FileName : string)');
    RegisterMethod('Procedure SaveToStream( Stream : TStream)');
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('DropTarget', 'TTreeNode', iptrw);
    RegisterProperty('Selected', 'TTreeNode', iptrw);
    RegisterProperty('TopItem', 'TTreeNode', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TTreeNodes(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TTreeNodes') do
  with CL.AddClass(CL.FindClass('TPersistent'), TTreeNodes) do
  begin
    RegisterMethod('Constructor Create( AOwner : TCustomTreeView)');
    RegisterMethod('Function AddChildFirst( Node : TTreeNode; const S : string) : TTreeNode');
    RegisterMethod('Function AddChild( Node : TTreeNode; const S : string) : TTreeNode');
    RegisterMethod('Function AddChildObjectFirst( Node : TTreeNode; const S : string; Ptr : Pointer) : TTreeNode');
    RegisterMethod('Function AddChildObject( Node : TTreeNode; const S : string; Ptr : Pointer) : TTreeNode');
    RegisterMethod('Function AddFirst( Node : TTreeNode; const S : string) : TTreeNode');
    RegisterMethod('Function Add( Node : TTreeNode; const S : string) : TTreeNode');
    RegisterMethod('Function AddObjectFirst( Node : TTreeNode; const S : string; Ptr : Pointer) : TTreeNode');
    RegisterMethod('Function AddObject( Node : TTreeNode; const S : string; Ptr : Pointer) : TTreeNode');
    RegisterMethod('Procedure BeginUpdate');
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure Delete( Node : TTreeNode)');
    RegisterMethod('Procedure EndUpdate');
    RegisterMethod('Function GetFirstNode : TTreeNode');
    RegisterMethod('Function GetNode( ItemId : HTreeItem) : TTreeNode');
    RegisterMethod('Function Insert( Node : TTreeNode; const S : string) : TTreeNode');
    RegisterMethod('Function InsertObject( Node : TTreeNode; const S : string; Ptr : Pointer) : TTreeNode');
    RegisterProperty('Count', 'Integer', iptr);
    RegisterProperty('Handle', 'HWND', iptr);
    RegisterProperty('Item', 'TTreeNode Integer', iptr);
    SetDefaultPropery('Item');
    RegisterProperty('Owner', 'TCustomTreeView', iptr);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TTreeNode(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TTreeNode') do
  with CL.AddClass(CL.FindClass('TPersistent'), TTreeNode) do
  begin
    RegisterMethod('Constructor Create( AOwner : TTreeNodes)');
    RegisterMethod('Function AlphaSort : Boolean');
    RegisterMethod('Procedure Collapse( Recurse : Boolean)');
    RegisterMethod('Function CustomSort( SortProc : TTVCompare; Data : Longint) : Boolean');
    RegisterMethod('Procedure Delete');
    RegisterMethod('Procedure DeleteChildren');
    RegisterMethod('Function DisplayRect( TextOnly : Boolean) : TRect');
    RegisterMethod('Function EditText : Boolean');
    RegisterMethod('Procedure EndEdit( Cancel : Boolean)');
    RegisterMethod('Procedure Expand( Recurse : Boolean)');
    RegisterMethod('Function getFirstChild : TTreeNode');
    RegisterMethod('Function GetHandle : HWND');
    RegisterMethod('Function GetLastChild : TTreeNode');
    RegisterMethod('Function GetNext : TTreeNode');
    RegisterMethod('Function GetNextChild( Value : TTreeNode) : TTreeNode');
    RegisterMethod('Function getNextSibling : TTreeNode');
    RegisterMethod('Function GetNextVisible : TTreeNode');
    RegisterMethod('Function GetPrev : TTreeNode');
    RegisterMethod('Function GetPrevChild( Value : TTreeNode) : TTreeNode');
    RegisterMethod('Function getPrevSibling : TTreeNode');
    RegisterMethod('Function GetPrevVisible : TTreeNode');
    RegisterMethod('Function HasAsParent( Value : TTreeNode) : Boolean');
    RegisterMethod('Function IndexOf( Value : TTreeNode) : Integer');
    RegisterMethod('Procedure MakeVisible');
    RegisterMethod('Procedure MoveTo( Destination : TTreeNode; Mode : TNodeAttachMode)');
    RegisterProperty('AbsoluteIndex', 'Integer', iptr);
    RegisterProperty('Count', 'Integer', iptr);
    RegisterProperty('Cut', 'Boolean', iptrw);
    RegisterProperty('Data', 'Pointer', iptrw);
    RegisterProperty('Deleting', 'Boolean', iptr);
    RegisterProperty('Focused', 'Boolean', iptrw);
    RegisterProperty('DropTarget', 'Boolean', iptrw);
    RegisterProperty('Selected', 'Boolean', iptrw);
    RegisterProperty('Expanded', 'Boolean', iptrw);
    RegisterProperty('Handle', 'HWND', iptr);
    RegisterProperty('HasChildren', 'Boolean', iptrw);
    RegisterProperty('ImageIndex', 'TImageIndex', iptrw);
    RegisterProperty('Index', 'Integer', iptr);
    RegisterProperty('IsVisible', 'Boolean', iptr);
    RegisterProperty('Item', 'TTreeNode Integer', iptrw);
    SetDefaultPropery('Item');
    RegisterProperty('ItemId', 'HTreeItem', iptr);
    RegisterProperty('Level', 'Integer', iptr);
    RegisterProperty('OverlayIndex', 'Integer', iptrw);
    RegisterProperty('Owner', 'TTreeNodes', iptr);
    RegisterProperty('Parent', 'TTreeNode', iptr);
    RegisterProperty('SelectedIndex', 'Integer', iptrw);
    RegisterProperty('StateIndex', 'Integer', iptrw);
    RegisterProperty('Text', 'string', iptrw);
    RegisterProperty('TreeView', 'TCustomTreeView', iptr);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_THeaderControl(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'THeaderControl') do
  with CL.AddClass(CL.FindClass('TWinControl'), THeaderControl) do
  begin
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('DragReorder', 'Boolean', iptrw);
    RegisterProperty('FullDrag', 'Boolean', iptrw);
    RegisterProperty('HotTrack', 'Boolean', iptrw);
    RegisterProperty('Images', 'TCustomImageList', iptrw);
    RegisterProperty('Sections', 'THeaderSections', iptrw);
    RegisterProperty('Style', 'THeaderStyle', iptrw);
    RegisterProperty('OnDrawSection', 'TDrawSectionEvent', iptrw);
    RegisterProperty('OnSectionClick', 'TSectionNotifyEvent', iptrw);
    RegisterProperty('OnSectionDrag', 'TSectionDragEvent', iptrw);
    RegisterProperty('OnSectionEndDrag', 'TNotifyEvent', iptrw);
    RegisterProperty('OnSectionResize', 'TSectionNotifyEvent', iptrw);
    RegisterProperty('OnSectionTrack', 'TSectionTrackEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_THeaderSections(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCollection', 'THeaderSections') do
  with CL.AddClass(CL.FindClass('TCollection'), THeaderSections) do
  begin
    RegisterMethod('Constructor Create( HeaderControl : THeaderControl)');
    RegisterMethod('Function Add : THeaderSection');
    RegisterProperty('Items', 'THeaderSection Integer', iptrw);
    SetDefaultPropery('Items');
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_THeaderSection(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCollectionItem', 'THeaderSection') do
  with CL.AddClass(CL.FindClass('TCollectionItem'), THeaderSection) do
  begin
    RegisterMethod('Procedure ParentBiDiModeChanged');
    RegisterMethod('Function UseRightToLeftAlignment : Boolean');
    RegisterMethod('Function UseRightToLeftReading : Boolean');
    RegisterProperty('Left', 'Integer', iptr);
    RegisterProperty('Right', 'Integer', iptr);
    RegisterProperty('Alignment', 'TAlignment', iptrw);
    RegisterProperty('AllowClick', 'Boolean', iptrw);
    RegisterProperty('AutoSize', 'Boolean', iptrw);
    RegisterProperty('BiDiMode', 'TBiDiMode', iptrw);
    RegisterProperty('ImageIndex', 'TImageIndex', iptrw);
    RegisterProperty('MaxWidth', 'Integer', iptrw);
    RegisterProperty('MinWidth', 'Integer', iptrw);
    RegisterProperty('ParentBiDiMode', 'Boolean', iptrw);
    RegisterProperty('Style', 'THeaderSectionStyle', iptrw);
    RegisterProperty('Text', 'string', iptrw);
    RegisterProperty('Width', 'Integer', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TStatusBar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TStatusBar') do
  with CL.AddClass(CL.FindClass('TWinControl'), TStatusBar) do
  begin
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('AutoHint', 'Boolean', iptrw);
    RegisterProperty('Panels', 'TStatusPanels', iptrw);
    RegisterProperty('SimplePanel', 'Boolean', iptrw);
    RegisterProperty('SimpleText', 'string', iptrw);
    RegisterProperty('SizeGrip', 'Boolean', iptrw);
    RegisterProperty('UseSystemFont', 'Boolean', iptrw);
    RegisterProperty('OnHint', 'TNotifyEvent', iptrw);
    RegisterProperty('OnDrawPanel', 'TDrawPanelEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TStatusPanels(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCollection', 'TStatusPanels') do
  with CL.AddClass(CL.FindClass('TCollection'), TStatusPanels) do
  begin
    RegisterMethod('Constructor Create( StatusBar : TStatusBar)');
    RegisterMethod('Function Add : TStatusPanel');
    RegisterProperty('Items', 'TStatusPanel Integer', iptrw);
    SetDefaultPropery('Items');
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TStatusPanel(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCollectionItem', 'TStatusPanel') do
  with CL.AddClass(CL.FindClass('TCollectionItem'), TStatusPanel) do
  begin
    RegisterMethod('Procedure ParentBiDiModeChanged');
    RegisterMethod('Function UseRightToLeftAlignment : Boolean');
    RegisterMethod('Function UseRightToLeftReading : Boolean');
    RegisterProperty('Alignment', 'TAlignment', iptrw);
    RegisterProperty('Bevel', 'TStatusPanelBevel', iptrw);
    RegisterProperty('BiDiMode', 'TBiDiMode', iptrw);
    RegisterProperty('ParentBiDiMode', 'Boolean', iptrw);
    RegisterProperty('Style', 'TStatusPanelStyle', iptrw);
    RegisterProperty('Text', 'string', iptrw);
    RegisterProperty('Width', 'Integer', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TPageControl(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomTabControl', 'TPageControl') do
  with CL.AddClass(CL.FindClass('TCustomTabControl'), TPageControl) do
  begin
    RegisterMethod('Function FindNextPage( CurPage : TTabSheet; GoForward, CheckTabVisible : Boolean) : TTabSheet');
    RegisterMethod('Procedure SelectNextPage( GoForward : Boolean)');
    RegisterProperty('ActivePageIndex', 'Integer', iptrw);
    RegisterProperty('PageCount', 'Integer', iptr);
    RegisterProperty('Pages', 'TTabSheet Integer', iptr);
    RegisterProperty('ActivePage', 'TTabSheet', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TTabSheet(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TTabSheet') do
  with CL.AddClass(CL.FindClass('TWinControl'), TTabSheet) do
  begin
    RegisterProperty('PageControl', 'TPageControl', iptrw);
    RegisterProperty('TabIndex', 'Integer', iptr);
    RegisterProperty('Highlighted', 'Boolean', iptrw);
    RegisterProperty('ImageIndex', 'TImageIndex', iptrw);
    RegisterProperty('PageIndex', 'Integer', iptrw);
    RegisterProperty('TabVisible', 'Boolean', iptrw);
    RegisterProperty('OnHide', 'TNotifyEvent', iptrw);
    RegisterProperty('OnShow', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TTabControl(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomTabControl', 'TTabControl') do
  with CL.AddClass(CL.FindClass('TCustomTabControl'), TTabControl) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomTabControl(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCustomTabControl') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCustomTabControl) do
  begin
    RegisterMethod('Function IndexOfTabAt( X, Y : Integer) : Integer');
    RegisterMethod('Function GetHitTestInfoAt( X, Y : Integer) : THitTests');
    RegisterMethod('Function TabRect( Index : Integer) : TRect');
    RegisterMethod('Function RowCount : Integer');
    RegisterMethod('Procedure ScrollTabs( Delta : Integer)');
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_ComCtrls(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('THitTest', '( htAbove, htBelow, htNowhere, htOnItem, htOnButton,'
    + ' htOnIcon, htOnIndent, htOnLabel, htOnRight, htOnStateIcon, htToLeft, htTo'
    + 'Right )');
  CL.AddTypeS('THitTests', 'set of THitTest');
  CL.AddClass(CL.FindClass('TWinControl'), TCustomTabControl);
  CL.AddTypeS('TTabChangingEvent', 'Procedure ( Sender : TObject; var AllowChan'
    + 'ge : Boolean)');
  CL.AddTypeS('TTabPosition', '( tpTop, tpBottom, tpLeft, tpRight )');
  CL.AddTypeS('TTabStyle', '( tsTabs, tsButtons, tsFlatButtons )');
  CL.AddTypeS('TDrawTabEvent', 'Procedure ( Control : TCustomTabControl; TabInd'
    + 'ex : Integer; const Rect : TRect; Active : Boolean)');
  CL.AddTypeS('TTabGetImageEvent', 'Procedure ( Sender : TObject; TabIndex : In'
    + 'teger; var ImageIndex : Integer)');
  SIRegister_TCustomTabControl(CL);
  SIRegister_TTabControl(CL);
  CL.AddClass(CL.FindClass('TCustomTabControl'), TPageControl);
  SIRegister_TTabSheet(CL);
  SIRegister_TPageControl(CL);
  CL.AddClass(CL.FindClass('TWinControl'), TStatusBar);
  CL.AddTypeS('TStatusPanelStyle', '( psText, psOwnerDraw )');
  CL.AddTypeS('TStatusPanelBevel', '( pbNone, pbLowered, pbRaised )');
  SIRegister_TStatusPanel(CL);
  SIRegister_TStatusPanels(CL);
  CL.AddTypeS('TDrawPanelEvent', 'Procedure ( StatusBar : TStatusBar; Panel : T'
    + 'StatusPanel; const Rect : TRect)');
  SIRegister_TStatusBar(CL);
  CL.AddTypeS('TCustomDrawTarget', '( dtControl, dtItem, dtSubItem )');
  CL.AddTypeS('TCustomDrawStage', '( cdPrePaint, cdPostPaint, cdPreErase, cdPos'
    + 'tErase )');
  CL.AddTypeS('TCustomDrawStateE', '( cdsSelected, cdsGrayed, cdsDisabled, cdsC'
    + 'hecked, cdsFocused, cdsDefault, cdsHot, cdsMarked, cdsIndeterminate )');
  CL.AddTypeS('TCustomDrawState', 'set of TCustomDrawStateE');
  CL.AddClass(CL.FindClass('TWinControl'), THeaderControl);
  CL.AddTypeS('THeaderSectionStyle', '( hsText, hsOwnerDraw )');
  SIRegister_THeaderSection(CL);
  SIRegister_THeaderSections(CL);
  CL.AddTypeS('TSectionTrackState', '( tsTrackBegin, tsTrackMove, tsTrackEnd )');
  CL.AddTypeS('TDrawSectionEvent', 'Procedure ( HeaderControl : THeaderControl;'
    + ' Section : THeaderSection; const Rect : TRect; Pressed : Boolean)');
  CL.AddTypeS('TSectionNotifyEvent', 'Procedure ( HeaderControl : THeaderContro'
    + 'l; Section : THeaderSection)');
  CL.AddTypeS('TSectionTrackEvent', 'Procedure ( HeaderControl : THeaderControl'
    + '; Section : THeaderSection; Width : Integer; State : TSectionTrackState)');
  CL.AddTypeS('TSectionDragEvent', 'Procedure ( Sender : TObject; FromSection, '
    + 'ToSection : THeaderSection; var AllowDrag : Boolean)');
  CL.AddTypeS('THeaderStyle', '( hsButtons, hsFlat )');
  SIRegister_THeaderControl(CL);
  CL.AddClass(CL.FindClass('TWinControl'), TCustomTreeView);
  CL.AddClass(CL.FindClass('TPersistent'), TTreeNodes);
  CL.AddTypeS('HTreeItem', 'Pointer');
  CL.AddTypeS('TNodeState', '( nsCut, nsDropHilited, nsFocused, nsSelected, nsE'
    + 'xpanded )');
  CL.AddTypeS('TNodeAttachMode', '( naAdd, naAddFirst, naAddChild, naAddChildFi'
    + 'rst, naInsert )');
  CL.AddTypeS('TAddMode', '( taAddFirst, taAdd, taInsert )');
  SIRegister_TTreeNode(CL);
  SIRegister_TTreeNodes(CL);
  CL.AddTypeS('TSortType', '( stNone, stData, stText, stBoth )');
  CL.AddTypeS('TTVChangingEvent', 'Procedure ( Sender : TObject; Node : TTreeNo'
    + 'de; var AllowChange : Boolean)');
  CL.AddTypeS('TTVChangedEvent', 'Procedure ( Sender : TObject; Node : TTreeNod'
    + 'e)');
  CL.AddTypeS('TTVEditingEvent', 'Procedure ( Sender : TObject; Node : TTreeNod'
    + 'e; var AllowEdit : Boolean)');
  CL.AddTypeS('TTVEditedEvent', 'Procedure ( Sender : TObject; Node : TTreeNode'
    + '; var S : string)');
  CL.AddTypeS('TTVExpandingEvent', 'Procedure ( Sender : TObject; Node : TTreeN'
    + 'ode; var AllowExpansion : Boolean)');
  CL.AddTypeS('TTVCollapsingEvent', 'Procedure ( Sender : TObject; Node : TTree'
    + 'Node; var AllowCollapse : Boolean)');
  CL.AddTypeS('TTVExpandedEvent', 'Procedure ( Sender : TObject; Node : TTreeNo'
    + 'de)');
  CL.AddTypeS('TTVCompareEvent', 'Procedure ( Sender : TObject; Node1, Node2 : '
    + 'TTreeNode; Data : Integer; var Compare : Integer)');
  CL.AddTypeS('TTVCustomDrawEvent', 'Procedure ( Sender : TCustomTreeView; cons'
    + 't ARect : TRect; var DefaultDraw : Boolean)');
  CL.AddTypeS('TTVCustomDrawItemEvent', 'Procedure ( Sender : TCustomTreeView; '
    + 'Node : TTreeNode; State : TCustomDrawState; var DefaultDraw : Boolean)');
  CL.AddTypeS('TTVAdvancedCustomDrawEvent', 'Procedure ( Sender : TCustomTreeVi'
    + 'ew; const ARect : TRect; Stage : TCustomDrawStage; var DefaultDraw : Boole'
    + 'an)');
  CL.AddTypeS('TTVAdvancedCustomDrawItemEvent', 'Procedure ( Sender : TCustomTr'
    + 'eeView; Node : TTreeNode; State : TCustomDrawState; Stage : TCustomDrawSta'
    + 'ge; var PaintImages, DefaultDraw : Boolean)');
  SIRegister_TCustomTreeView(CL);
  SIRegister_TTreeView(CL);
  CL.AddTypeS('TTrackBarOrientation', '( trHorizontal, trVertical )');
  CL.AddTypeS('TTickMark', '( tmBottomRight, tmTopLeft, tmBoth )');
  CL.AddTypeS('TTickStyle', '( tsNone, tsAuto, tsManual )');
  SIRegister_TTrackBar(CL);
  CL.AddTypeS('TProgressRange', 'Integer');
  CL.AddTypeS('TProgressBarOrientation', '( pbHorizontal, pbVertical )');
  SIRegister_TProgressBar(CL);
  CL.AddClass(CL.FindClass('TCustomMemo'), TCustomRichEdit);
  CL.AddTypeS('TAttributeType', '( atSelected, atDefaultText )');
  CL.AddTypeS('TConsistentAttribute', '( caBold, caColor, caFace, caItalic, caS'
    + 'ize, caStrikeOut, caUnderline, caProtected )');
  CL.AddTypeS('TConsistentAttributes', 'set of TConsistentAttribute');
  SIRegister_TTextAttributes(CL);
  CL.AddTypeS('TNumberingStyle', '( nsNone, nsBullet )');
  SIRegister_TParaAttributes(CL);
  CL.AddTypeS('TRichEditResizeEvent', 'Procedure ( Sender : TObject; Rect : TRe'
    + 'ct)');
  CL.AddTypeS('TRichEditProtectChange', 'Procedure ( Sender : TObject; StartPos'
    + ', EndPos : Integer; var AllowChange : Boolean)');
  CL.AddTypeS('TRichEditSaveClipboard', 'Procedure ( Sender : TObject; NumObjec'
    + 'ts, NumChars : Integer; var SaveClipboard : Boolean)');
  CL.AddTypeS('TSearchType', '( stWholeWord, stMatchCase )');
  CL.AddTypeS('TSearchTypes', 'set of TSearchType');
  SIRegister_TConversion(CL);
  //CL.AddTypeS('TConversionClass', 'class of TConversion');
  SIRegister_TCustomRichEdit(CL);
  SIRegister_TRichEdit(CL);
  CL.AddTypeS('TUDAlignButton', '( udLeft, udRight )');
  CL.AddTypeS('TUDOrientation', '( udHorizontal, udVertical )');
  CL.AddTypeS('TUDBtnType', '( btNext, btPrev )');
  CL.AddTypeS('TUpDownDirection', '( updNone, updUp, updDown )');
  CL.AddTypeS('TUDClickEvent', 'Procedure ( Sender : TObject; Button : TUDBtnTy'
    + 'pe)');
  CL.AddTypeS('TUDChangingEvent', 'Procedure ( Sender : TObject; var AllowChang'
    + 'e : Boolean)');
  CL.AddTypeS('TUDChangingEventEx', 'Procedure ( Sender : TObject; var AllowCha'
    + 'nge : Boolean; NewValue : SmallInt; Direction : TUpDownDirection)');
  SIRegister_TCustomUpDown(CL);
  SIRegister_TUpDown(CL);
  CL.AddTypeS('THKModifier', '( hkShift, hkCtrl, hkAlt, hkExt )');
  CL.AddTypeS('THKModifiers', 'set of THKModifier');
  CL.AddTypeS('THKInvalidKey', '( hcNone, hcShift, hcCtrl, hcAlt, hcShiftCtrl, '
    + 'hcShiftAlt, hcCtrlAlt, hcShiftCtrlAlt )');
  CL.AddTypeS('THKInvalidKeys', 'set of THKInvalidKey');
  SIRegister_TCustomHotKey(CL);
  SIRegister_THotKey(CL);
  CL.AddClass(CL.FindClass('TCollection'), TListColumns);
  CL.AddClass(CL.FindClass('TPersistent'), TListItems);
  CL.AddClass(CL.FindClass('TWinControl'), TCustomListView);
  CL.AddTypeS('TWidth', 'Integer');
  SIRegister_TListColumn(CL);
  SIRegister_TListColumns(CL);
  CL.AddTypeS('TDisplayCode', '( drBounds, drIcon, drLabel, drSelectBounds )');
  SIRegister_TListItem(CL);
  SIRegister_TListItems(CL);
  SIRegister_TWorkArea(CL);
  SIRegister_TWorkAreas(CL);
  CL.AddTypeS('TIconArrangement', '( iaTop, iaLeft )');
  SIRegister_TIconOptions(CL);
  CL.AddTypeS('TListArrangement', '( arAlignBottom, arAlignLeft, arAlignRight, '
    + 'arAlignTop, arDefault, arSnapToGrid )');
  CL.AddTypeS('TViewStyle', '( vsIcon, vsSmallIcon, vsList, vsReport )');
  CL.AddTypeS('TItemState', '( isNone, isCut, isDropHilited, isFocused, isSelec'
    + 'ted, isActivating )');
  CL.AddTypeS('TItemStates', 'set of TItemState');
  CL.AddTypeS('TItemChange', '( ctText, ctImage, ctState )');
  CL.AddTypeS('TItemFind', '( ifData, ifPartialString, ifExactString, ifNearest'
    + ' )');
  CL.AddTypeS('TSearchDirection', '( sdLeft, sdRight, sdAbove, sdBelow, sdAll )');
  CL.AddTypeS('TListHotTrackStyle', '( htHandPoint, htUnderlineCold, htUnderlin'
    + 'eHot )');
  CL.AddTypeS('TListHotTrackStyles', 'set of TListHotTrackStyle');
  CL.AddTypeS('TItemRequests', '( irText, irImage, irParam, irState, irIndent )');
  CL.AddTypeS('TItemRequest', 'set of TItemRequests');
  CL.AddTypeS('TLVDeletedEvent', 'Procedure ( Sender : TObject; Item : TListIte'
    + 'm)');
  CL.AddTypeS('TLVEditingEvent', 'Procedure ( Sender : TObject; Item : TListIte'
    + 'm; var AllowEdit : Boolean)');
  CL.AddTypeS('TLVEditedEvent', 'Procedure ( Sender : TObject; Item : TListItem'
    + '; var S : string)');
  CL.AddTypeS('TLVChangeEvent', 'Procedure ( Sender : TObject; Item : TListItem'
    + '; Change : TItemChange)');
  CL.AddTypeS('TLVChangingEvent', 'Procedure ( Sender : TObject; Item : TListIt'
    + 'em; Change : TItemChange; var AllowChange : Boolean)');
  CL.AddTypeS('TLVColumnClickEvent', 'Procedure ( Sender : TObject; Column : TL'
    + 'istColumn)');
  CL.AddTypeS('TLVColumnRClickEvent', 'Procedure ( Sender : TObject; Column : T'
    + 'ListColumn; Point : TPoint)');
  CL.AddTypeS('TLVCompareEvent', 'Procedure ( Sender : TObject; Item1, Item2 : '
    + 'TListItem; Data : Integer; var Compare : Integer)');
  CL.AddTypeS('TLVNotifyEvent', 'Procedure ( Sender : TObject; Item : TListItem'
    + ')');
  CL.AddTypeS('TLVSelectItemEvent', 'Procedure ( Sender : TObject; Item : TList'
    + 'Item; Selected : Boolean)');
  CL.AddTypeS('TLVDrawItemEvent', 'Procedure ( Sender : TCustomListView; Item :'
    + ' TListItem; Rect : TRect; State : TOwnerDrawState)');
  CL.AddTypeS('TLVCustomDrawEvent', 'Procedure ( Sender : TCustomListView; cons'
    + 't ARect : TRect; var DefaultDraw : Boolean)');
  CL.AddTypeS('TLVCustomDrawItemEvent', 'Procedure ( Sender : TCustomListView; '
    + 'Item : TListItem; State : TCustomDrawState; var DefaultDraw : Boolean)');
  CL.AddTypeS('TLVCustomDrawSubItemEvent', 'Procedure ( Sender : TCustomListVie'
    + 'w; Item : TListItem; SubItem : Integer; State : TCustomDrawState; var Defa'
    + 'ultDraw : Boolean)');
  CL.AddTypeS('TLVAdvancedCustomDrawEvent', 'Procedure ( Sender : TCustomListVi'
    + 'ew; const ARect : TRect; Stage : TCustomDrawStage; var DefaultDraw : Boole'
    + 'an)');
  CL.AddTypeS('TLVAdvancedCustomDrawItemEvent', 'Procedure ( Sender : TCustomLi'
    + 'stView; Item : TListItem; State : TCustomDrawState; Stage : TCustomDrawSta'
    + 'ge; var DefaultDraw : Boolean)');
  CL.AddTypeS('TLVAdvancedCustomDrawSubItemEvent', 'Procedure ( Sender : TCusto'
    + 'mListView; Item : TListItem; SubItem : Integer; State : TCustomDrawState; '
    + 'Stage : TCustomDrawStage; var DefaultDraw : Boolean)');
  CL.AddTypeS('TLVOwnerDataEvent', 'Procedure ( Sender : TObject; Item : TListI'
    + 'tem)');
  CL.AddTypeS('TLVOwnerDataFindEvent', 'Procedure ( Sender : TObject; Find : TI'
    + 'temFind; const FindString : string; const FindPosition : TPoint; FindData '
    + ': Pointer; StartIndex : Integer; Direction : TSearchDirection; Wrap : Bool'
    + 'ean; var Index : Integer)');
  CL.AddTypeS('TLVOwnerDataHintEvent', 'Procedure ( Sender : TObject; StartInde'
    + 'x, EndIndex : Integer)');
  CL.AddTypeS('TLVOwnerDataStateChangeEvent', 'Procedure ( Sender : TObject; St'
    + 'artIndex, EndIndex : Integer; OldState, NewState : TItemStates)');
  CL.AddTypeS('TLVSubItemImageEvent', 'Procedure ( Sender : TObject; Item : TLi'
    + 'stItem; SubItem : Integer; var ImageIndex : Integer)');
  CL.AddTypeS('TLVInfoTipEvent', 'Procedure ( Sender : TObject; Item : TListIte'
    + 'm; var InfoTip : string)');
  SIRegister_TCustomListView(CL);
  SIRegister_TListView(CL);
  CL.AddTypeS('TCommonAVI', '( aviNone, aviFindFolder, aviFindFile, aviFindComp'
    + 'uter, aviCopyFiles, aviCopyFile, aviRecycleFile, aviEmptyRecycle, aviDelet'
    + 'eFile )');
  SIRegister_TAnimate(CL);
  CL.AddTypeS('TToolButtonStyle', '( tbsButton, tbsCheck, tbsDropDown, tbsSepar'
    + 'ator, tbsDivider )');
  CL.AddTypeS('TToolButtonState', '( tbsChecked, tbsPressed, tbsEnabled, tbsHid'
    + 'den, tbsIndeterminate, tbsWrap, tbsEllipses, tbsMarked )');
  CL.AddClass(CL.FindClass('TToolWindow'), TToolBar);
  CL.AddClass(CL.FindClass('TGraphicControl'), TToolButton);
  SIRegister_TToolButton(CL);
  CL.AddTypeS('TTBCustomDrawFlagsE', '( tbNoEdges, tbHiliteHotTrack, tbNoOffset'
    + ', tbNoMark, tbNoEtchedEffect )');
  CL.AddTypeS('TTBCustomDrawFlags', 'set of TTBCustomDrawFlagsE');
  CL.AddTypeS('TTBCustomDrawEvent', 'Procedure ( Sender : TToolBar; const ARect'
    + ' : TRect; var DefaultDraw : Boolean)');
  CL.AddTypeS('TTBCustomDrawBtnEvent', 'Procedure ( Sender : TToolBar; Button :'
    + ' TToolButton; State : TCustomDrawState; var DefaultDraw : Boolean)');
  CL.AddTypeS('TTBAdvancedCustomDrawEvent', 'Procedure ( Sender : TToolBar; con'
    + 'st ARect : TRect; Stage : TCustomDrawStage; var DefaultDraw : Boolean)');
  CL.AddTypeS('TTBAdvancedCustomDrawBtnEvent', 'Procedure ( Sender : TToolBar; '
    + 'Button : TToolButton; State : TCustomDrawState; Stage : TCustomDrawStage; '
    + 'var Flags : TTBCustomDrawFlags; var DefaultDraw : Boolean)');
  SIRegister_TToolBar(CL);
  CL.AddClass(CL.FindClass('TToolWindow'), TCoolBar);
  SIRegister_TCoolBand(CL);
  SIRegister_TCoolBands(CL);
  CL.AddTypeS('TCoolBandMaximize', '( bmNone, bmClick, bmDblClick )');
  SIRegister_TCoolBar(CL);
  CL.AddClass(CL.FindClass('TWinControl'), TCommonCalendar);
  SIRegister_TMonthCalColors(CL);
  CL.AddTypeS('TCalDayOfWeek', '( dowMonday, dowTuesday, dowWednesday, dowThurs'
    + 'day, dowFriday, dowSaturday, dowSunday, dowLocaleDefault )');
  CL.AddTypeS('TOnGetMonthInfoEvent', 'Procedure ( Sender : TObject; Month : Lo'
    + 'ngWord; var MonthBoldInfo : LongWord)');
  SIRegister_TCommonCalendar(CL);
  SIRegister_TMonthCalendar(CL);
  CL.AddTypeS('TDateTimeKind', '( dtkDate, dtkTime )');
  CL.AddTypeS('TDTDateMode', '( dmComboBox, dmUpDown )');
  CL.AddTypeS('TDTDateFormat', '( dfShort, dfLong )');
  CL.AddTypeS('TDTCalAlignment', '( dtaLeft, dtaRight )');
  CL.AddTypeS('TDTParseInputEvent', 'Procedure ( Sender : TObject; const UserSt'
    + 'ring : string; var DateAndTime : TDateTime; var AllowChange : Boolean)');
  CL.AddTypeS('TDateTimeColors', 'TMonthCalColors');
  SIRegister_TDateTimePicker(CL);
  CL.AddTypeS('TPageScrollerOrientation', '( soHorizontal, soVertical )');
  CL.AddTypeS('TPageScrollerButton', '( sbFirst, sbLast )');
  CL.AddTypeS('TPageScrollerButtonState', '( bsNormal, bsInvisible, bsGrayed, b'
    + 'sDepressed, bsHot )');
  CL.AddTypeS('TPageScrollEvent', 'Procedure ( Sender : TObject; Shift : TShift'
    + 'State; X, Y : Integer; Orientation : TPageScrollerOrientation; var Delta :'
    + ' Integer)');
  SIRegister_TPageScroller(CL);
  CL.AddConstantN('ComCtlVersionIE3', 'LongWord').SetUInt($00040046);
  CL.AddConstantN('ComCtlVersionIE4', 'LongWord').SetUInt($00040047);
  CL.AddConstantN('ComCtlVersionIE401', 'LongWord').SetUInt($00040048);
  CL.AddConstantN('ComCtlVersionIE5', 'LongWord').SetUInt($00050050);
  CL.AddDelphiFunction('Function GetComCtlVersion : Integer');
  CL.AddDelphiFunction('Procedure CheckToolMenuDropdown( ToolButton : TToolButton)');
end;

(* === run-time registration functions === *)

procedure TPageScrollerOnScroll_W(Self: TPageScroller; const T: TPageScrollEvent);
begin
  Self.OnScroll := T;
end;

procedure TPageScrollerOnScroll_R(Self: TPageScroller; var T: TPageScrollEvent);
begin
  T := Self.OnScroll;
end;

procedure TPageScrollerPosition_W(Self: TPageScroller; const T: Integer);
begin
  Self.Position := T;
end;

procedure TPageScrollerPosition_R(Self: TPageScroller; var T: Integer);
begin
  T := Self.Position;
end;

procedure TPageScrollerOrientation_W(Self: TPageScroller; const T: TPageScrollerOrientation);
begin
  Self.Orientation := T;
end;

procedure TPageScrollerOrientation_R(Self: TPageScroller; var T: TPageScrollerOrientation);
begin
  T := Self.Orientation;
end;

procedure TPageScrollerMargin_W(Self: TPageScroller; const T: Integer);
begin
  Self.Margin := T;
end;

procedure TPageScrollerMargin_R(Self: TPageScroller; var T: Integer);
begin
  T := Self.Margin;
end;

procedure TPageScrollerDragScroll_W(Self: TPageScroller; const T: Boolean);
begin
  Self.DragScroll := T;
end;

procedure TPageScrollerDragScroll_R(Self: TPageScroller; var T: Boolean);
begin
  T := Self.DragScroll;
end;

procedure TPageScrollerControl_W(Self: TPageScroller; const T: TWinControl);
begin
  Self.Control := T;
end;

procedure TPageScrollerControl_R(Self: TPageScroller; var T: TWinControl);
begin
  T := Self.Control;
end;

procedure TPageScrollerButtonSize_W(Self: TPageScroller; const T: Integer);
begin
  Self.ButtonSize := T;
end;

procedure TPageScrollerButtonSize_R(Self: TPageScroller; var T: Integer);
begin
  T := Self.ButtonSize;
end;

procedure TPageScrollerAutoScroll_W(Self: TPageScroller; const T: Boolean);
begin
  Self.AutoScroll := T;
end;

procedure TPageScrollerAutoScroll_R(Self: TPageScroller; var T: Boolean);
begin
  T := Self.AutoScroll;
end;

procedure TDateTimePickerOnUserInput_W(Self: TDateTimePicker; const T: TDTParseInputEvent);
begin
  Self.OnUserInput := T;
end;

procedure TDateTimePickerOnUserInput_R(Self: TDateTimePicker; var T: TDTParseInputEvent);
begin
  T := Self.OnUserInput;
end;

procedure TDateTimePickerOnDropDown_W(Self: TDateTimePicker; const T: TNotifyEvent);
begin
  Self.OnDropDown := T;
end;

procedure TDateTimePickerOnDropDown_R(Self: TDateTimePicker; var T: TNotifyEvent);
begin
  T := Self.OnDropDown;
end;

procedure TDateTimePickerOnChange_W(Self: TDateTimePicker; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TDateTimePickerOnChange_R(Self: TDateTimePicker; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TDateTimePickerOnCloseUp_W(Self: TDateTimePicker; const T: TNotifyEvent);
begin
  Self.OnCloseUp := T;
end;

procedure TDateTimePickerOnCloseUp_R(Self: TDateTimePicker; var T: TNotifyEvent);
begin
  T := Self.OnCloseUp;
end;

procedure TDateTimePickerParseInput_W(Self: TDateTimePicker; const T: Boolean);
begin
  Self.ParseInput := T;
end;

procedure TDateTimePickerParseInput_R(Self: TDateTimePicker; var T: Boolean);
begin
  T := Self.ParseInput;
end;

procedure TDateTimePickerKind_W(Self: TDateTimePicker; const T: TDateTimeKind);
begin
  Self.Kind := T;
end;

procedure TDateTimePickerKind_R(Self: TDateTimePicker; var T: TDateTimeKind);
begin
  T := Self.Kind;
end;

procedure TDateTimePickerDateMode_W(Self: TDateTimePicker; const T: TDTDateMode);
begin
  Self.DateMode := T;
end;

procedure TDateTimePickerDateMode_R(Self: TDateTimePicker; var T: TDTDateMode);
begin
  T := Self.DateMode;
end;

procedure TDateTimePickerDateFormat_W(Self: TDateTimePicker; const T: TDTDateFormat);
begin
  Self.DateFormat := T;
end;

procedure TDateTimePickerDateFormat_R(Self: TDateTimePicker; var T: TDTDateFormat);
begin
  T := Self.DateFormat;
end;

procedure TDateTimePickerChecked_W(Self: TDateTimePicker; const T: Boolean);
begin
  Self.Checked := T;
end;

procedure TDateTimePickerChecked_R(Self: TDateTimePicker; var T: Boolean);
begin
  T := Self.Checked;
end;

procedure TDateTimePickerShowCheckbox_W(Self: TDateTimePicker; const T: Boolean);
begin
  Self.ShowCheckbox := T;
end;

procedure TDateTimePickerShowCheckbox_R(Self: TDateTimePicker; var T: Boolean);
begin
  T := Self.ShowCheckbox;
end;

procedure TDateTimePickerTime_W(Self: TDateTimePicker; const T: TTime);
begin
  Self.Time := T;
end;

procedure TDateTimePickerTime_R(Self: TDateTimePicker; var T: TTime);
begin
  T := Self.Time;
end;

procedure TDateTimePickerCalAlignment_W(Self: TDateTimePicker; const T: TDTCalAlignment);
begin
  Self.CalAlignment := T;
end;

procedure TDateTimePickerCalAlignment_R(Self: TDateTimePicker; var T: TDTCalAlignment);
begin
  T := Self.CalAlignment;
end;

procedure TDateTimePickerDroppedDown_R(Self: TDateTimePicker; var T: Boolean);
begin
  T := Self.DroppedDown;
end;

procedure TMonthCalColorsTrailingTextColor_W(Self: TMonthCalColors; const T: TColor);
begin
  Self.TrailingTextColor := T;
end;

procedure TMonthCalColorsTrailingTextColor_R(Self: TMonthCalColors; var T: TColor);
begin
  T := Self.TrailingTextColor;
end;

procedure TMonthCalColorsMonthBackColor_W(Self: TMonthCalColors; const T: TColor);
begin
  Self.MonthBackColor := T;
end;

procedure TMonthCalColorsMonthBackColor_R(Self: TMonthCalColors; var T: TColor);
begin
  T := Self.MonthBackColor;
end;

procedure TMonthCalColorsTitleTextColor_W(Self: TMonthCalColors; const T: TColor);
begin
  Self.TitleTextColor := T;
end;

procedure TMonthCalColorsTitleTextColor_R(Self: TMonthCalColors; var T: TColor);
begin
  T := Self.TitleTextColor;
end;

procedure TMonthCalColorsTitleBackColor_W(Self: TMonthCalColors; const T: TColor);
begin
  Self.TitleBackColor := T;
end;

procedure TMonthCalColorsTitleBackColor_R(Self: TMonthCalColors; var T: TColor);
begin
  T := Self.TitleBackColor;
end;

procedure TMonthCalColorsTextColor_W(Self: TMonthCalColors; const T: TColor);
begin
  Self.TextColor := T;
end;

procedure TMonthCalColorsTextColor_R(Self: TMonthCalColors; var T: TColor);
begin
  T := Self.TextColor;
end;

procedure TMonthCalColorsBackColor_W(Self: TMonthCalColors; const T: TColor);
begin
  Self.BackColor := T;
end;

procedure TMonthCalColorsBackColor_R(Self: TMonthCalColors; var T: TColor);
begin
  T := Self.BackColor;
end;

procedure TCoolBarOnChange_W(Self: TCoolBar; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TCoolBarOnChange_R(Self: TCoolBar; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TCoolBarVertical_W(Self: TCoolBar; const T: Boolean);
begin
  Self.Vertical := T;
end;

procedure TCoolBarVertical_R(Self: TCoolBar; var T: Boolean);
begin
  T := Self.Vertical;
end;

procedure TCoolBarShowText_W(Self: TCoolBar; const T: Boolean);
begin
  Self.ShowText := T;
end;

procedure TCoolBarShowText_R(Self: TCoolBar; var T: Boolean);
begin
  T := Self.ShowText;
end;

procedure TCoolBarBitmap_W(Self: TCoolBar; const T: TBitmap);
begin
  Self.Bitmap := T;
end;

procedure TCoolBarBitmap_R(Self: TCoolBar; var T: TBitmap);
begin
  T := Self.Bitmap;
end;

procedure TCoolBarImages_W(Self: TCoolBar; const T: TCustomImageList);
begin
  Self.Images := T;
end;

procedure TCoolBarImages_R(Self: TCoolBar; var T: TCustomImageList);
begin
  T := Self.Images;
end;

procedure TCoolBarFixedOrder_W(Self: TCoolBar; const T: Boolean);
begin
  Self.FixedOrder := T;
end;

procedure TCoolBarFixedOrder_R(Self: TCoolBar; var T: Boolean);
begin
  T := Self.FixedOrder;
end;

procedure TCoolBarFixedSize_W(Self: TCoolBar; const T: Boolean);
begin
  Self.FixedSize := T;
end;

procedure TCoolBarFixedSize_R(Self: TCoolBar; var T: Boolean);
begin
  T := Self.FixedSize;
end;

procedure TCoolBarBands_W(Self: TCoolBar; const T: TCoolBands);
begin
  Self.Bands := T;
end;

procedure TCoolBarBands_R(Self: TCoolBar; var T: TCoolBands);
begin
  T := Self.Bands;
end;

procedure TCoolBarBandMaximize_W(Self: TCoolBar; const T: TCoolBandMaximize);
begin
  Self.BandMaximize := T;
end;

procedure TCoolBarBandMaximize_R(Self: TCoolBar; var T: TCoolBandMaximize);
begin
  T := Self.BandMaximize;
end;

procedure TCoolBarBandBorderStyle_W(Self: TCoolBar; const T: TBorderStyle);
begin
  Self.BandBorderStyle := T;
end;

procedure TCoolBarBandBorderStyle_R(Self: TCoolBar; var T: TBorderStyle);
begin
  T := Self.BandBorderStyle;
end;

procedure TCoolBandsItems_W(Self: TCoolBands; const T: TCoolBand; const t1: Integer);
begin
  Self.Items[t1] := T;
end;

procedure TCoolBandsItems_R(Self: TCoolBands; var T: TCoolBand; const t1: Integer);
begin
  T := Self.Items[t1];
end;

procedure TCoolBandsCoolBar_R(Self: TCoolBands; var T: TCoolBar);
begin
  T := Self.CoolBar;
end;

procedure TCoolBandWidth_W(Self: TCoolBand; const T: Integer);
begin
  Self.Width := T;
end;

procedure TCoolBandWidth_R(Self: TCoolBand; var T: Integer);
begin
  T := Self.Width;
end;

procedure TCoolBandVisible_W(Self: TCoolBand; const T: Boolean);
begin
  Self.Visible := T;
end;

procedure TCoolBandVisible_R(Self: TCoolBand; var T: Boolean);
begin
  T := Self.Visible;
end;

procedure TCoolBandText_W(Self: TCoolBand; const T: string);
begin
  Self.Text := T;
end;

procedure TCoolBandText_R(Self: TCoolBand; var T: string);
begin
  T := Self.Text;
end;

procedure TCoolBandParentBitmap_W(Self: TCoolBand; const T: Boolean);
begin
  Self.ParentBitmap := T;
end;

procedure TCoolBandParentBitmap_R(Self: TCoolBand; var T: Boolean);
begin
  T := Self.ParentBitmap;
end;

procedure TCoolBandParentColor_W(Self: TCoolBand; const T: Boolean);
begin
  Self.ParentColor := T;
end;

procedure TCoolBandParentColor_R(Self: TCoolBand; var T: Boolean);
begin
  T := Self.ParentColor;
end;

procedure TCoolBandMinWidth_W(Self: TCoolBand; const T: Integer);
begin
  Self.MinWidth := T;
end;

procedure TCoolBandMinWidth_R(Self: TCoolBand; var T: Integer);
begin
  T := Self.MinWidth;
end;

procedure TCoolBandMinHeight_W(Self: TCoolBand; const T: Integer);
begin
  Self.MinHeight := T;
end;

procedure TCoolBandMinHeight_R(Self: TCoolBand; var T: Integer);
begin
  T := Self.MinHeight;
end;

procedure TCoolBandImageIndex_W(Self: TCoolBand; const T: TImageIndex);
begin
  Self.ImageIndex := T;
end;

procedure TCoolBandImageIndex_R(Self: TCoolBand; var T: TImageIndex);
begin
  T := Self.ImageIndex;
end;

procedure TCoolBandHorizontalOnly_W(Self: TCoolBand; const T: Boolean);
begin
  Self.HorizontalOnly := T;
end;

procedure TCoolBandHorizontalOnly_R(Self: TCoolBand; var T: Boolean);
begin
  T := Self.HorizontalOnly;
end;

procedure TCoolBandFixedSize_W(Self: TCoolBand; const T: Boolean);
begin
  Self.FixedSize := T;
end;

procedure TCoolBandFixedSize_R(Self: TCoolBand; var T: Boolean);
begin
  T := Self.FixedSize;
end;

procedure TCoolBandFixedBackground_W(Self: TCoolBand; const T: Boolean);
begin
  Self.FixedBackground := T;
end;

procedure TCoolBandFixedBackground_R(Self: TCoolBand; var T: Boolean);
begin
  T := Self.FixedBackground;
end;

procedure TCoolBandControl_W(Self: TCoolBand; const T: TWinControl);
begin
  Self.Control := T;
end;

procedure TCoolBandControl_R(Self: TCoolBand; var T: TWinControl);
begin
  T := Self.Control;
end;

procedure TCoolBandColor_W(Self: TCoolBand; const T: TColor);
begin
  Self.Color := T;
end;

procedure TCoolBandColor_R(Self: TCoolBand; var T: TColor);
begin
  T := Self.Color;
end;

procedure TCoolBandBreak_W(Self: TCoolBand; const T: Boolean);
begin
  Self.Break := T;
end;

procedure TCoolBandBreak_R(Self: TCoolBand; var T: Boolean);
begin
  T := Self.Break;
end;

procedure TCoolBandBorderStyle_W(Self: TCoolBand; const T: TBorderStyle);
begin
  Self.BorderStyle := T;
end;

procedure TCoolBandBorderStyle_R(Self: TCoolBand; var T: TBorderStyle);
begin
  T := Self.BorderStyle;
end;

procedure TCoolBandBitmap_W(Self: TCoolBand; const T: TBitmap);
begin
  Self.Bitmap := T;
end;

procedure TCoolBandBitmap_R(Self: TCoolBand; var T: TBitmap);
begin
  T := Self.Bitmap;
end;

procedure TCoolBandHeight_R(Self: TCoolBand; var T: Integer);
begin
  T := Self.Height;
end;

procedure TToolBarOnCustomDrawButton_W(Self: TToolBar; const T: TTBCustomDrawBtnEvent);
begin
  Self.OnCustomDrawButton := T;
end;

procedure TToolBarOnCustomDrawButton_R(Self: TToolBar; var T: TTBCustomDrawBtnEvent);
begin
  T := Self.OnCustomDrawButton;
end;

procedure TToolBarOnCustomDraw_W(Self: TToolBar; const T: TTBCustomDrawEvent);
begin
  Self.OnCustomDraw := T;
end;

procedure TToolBarOnCustomDraw_R(Self: TToolBar; var T: TTBCustomDrawEvent);
begin
  T := Self.OnCustomDraw;
end;

procedure TToolBarOnAdvancedCustomDrawButton_W(Self: TToolBar; const T: TTBAdvancedCustomDrawBtnEvent);
begin
  Self.OnAdvancedCustomDrawButton := T;
end;

procedure TToolBarOnAdvancedCustomDrawButton_R(Self: TToolBar; var T: TTBAdvancedCustomDrawBtnEvent);
begin
  T := Self.OnAdvancedCustomDrawButton;
end;

procedure TToolBarOnAdvancedCustomDraw_W(Self: TToolBar; const T: TTBAdvancedCustomDrawEvent);
begin
  Self.OnAdvancedCustomDraw := T;
end;

procedure TToolBarOnAdvancedCustomDraw_R(Self: TToolBar; var T: TTBAdvancedCustomDrawEvent);
begin
  T := Self.OnAdvancedCustomDraw;
end;

procedure TToolBarWrapable_W(Self: TToolBar; const T: Boolean);
begin
  Self.Wrapable := T;
end;

procedure TToolBarWrapable_R(Self: TToolBar; var T: Boolean);
begin
  T := Self.Wrapable;
end;

procedure TToolBarTransparent_W(Self: TToolBar; const T: Boolean);
begin
  Self.Transparent := T;
end;

procedure TToolBarTransparent_R(Self: TToolBar; var T: Boolean);
begin
  T := Self.Transparent;
end;

procedure TToolBarShowCaptions_W(Self: TToolBar; const T: Boolean);
begin
  Self.ShowCaptions := T;
end;

procedure TToolBarShowCaptions_R(Self: TToolBar; var T: Boolean);
begin
  T := Self.ShowCaptions;
end;

procedure TToolBarList_W(Self: TToolBar; const T: Boolean);
begin
  Self.List := T;
end;

procedure TToolBarList_R(Self: TToolBar; var T: Boolean);
begin
  T := Self.List;
end;

procedure TToolBarIndent_W(Self: TToolBar; const T: Integer);
begin
  Self.Indent := T;
end;

procedure TToolBarIndent_R(Self: TToolBar; var T: Integer);
begin
  T := Self.Indent;
end;

procedure TToolBarImages_W(Self: TToolBar; const T: TCustomImageList);
begin
  Self.Images := T;
end;

procedure TToolBarImages_R(Self: TToolBar; var T: TCustomImageList);
begin
  T := Self.Images;
end;

procedure TToolBarHotImages_W(Self: TToolBar; const T: TCustomImageList);
begin
  Self.HotImages := T;
end;

procedure TToolBarHotImages_R(Self: TToolBar; var T: TCustomImageList);
begin
  T := Self.HotImages;
end;

procedure TToolBarFlat_W(Self: TToolBar; const T: Boolean);
begin
  Self.Flat := T;
end;

procedure TToolBarFlat_R(Self: TToolBar; var T: Boolean);
begin
  T := Self.Flat;
end;

procedure TToolBarDisabledImages_W(Self: TToolBar; const T: TCustomImageList);
begin
  Self.DisabledImages := T;
end;

procedure TToolBarDisabledImages_R(Self: TToolBar; var T: TCustomImageList);
begin
  T := Self.DisabledImages;
end;

procedure TToolBarButtonWidth_W(Self: TToolBar; const T: Integer);
begin
  Self.ButtonWidth := T;
end;

procedure TToolBarButtonWidth_R(Self: TToolBar; var T: Integer);
begin
  T := Self.ButtonWidth;
end;

procedure TToolBarButtonHeight_W(Self: TToolBar; const T: Integer);
begin
  Self.ButtonHeight := T;
end;

procedure TToolBarButtonHeight_R(Self: TToolBar; var T: Integer);
begin
  T := Self.ButtonHeight;
end;

procedure TToolBarRowCount_R(Self: TToolBar; var T: Integer);
begin
  T := Self.RowCount;
end;

procedure TToolBarCanvas_R(Self: TToolBar; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure TToolBarButtons_R(Self: TToolBar; var T: TToolButton; const t1: Integer);
begin
  T := Self.Buttons[t1];
end;

procedure TToolBarButtonCount_R(Self: TToolBar; var T: Integer);
begin
  T := Self.ButtonCount;
end;

procedure TToolButtonStyle_W(Self: TToolButton; const T: TToolButtonStyle);
begin
  Self.Style := T;
end;

procedure TToolButtonStyle_R(Self: TToolButton; var T: TToolButtonStyle);
begin
  T := Self.Style;
end;

procedure TToolButtonWrap_W(Self: TToolButton; const T: Boolean);
begin
  Self.Wrap := T;
end;

procedure TToolButtonWrap_R(Self: TToolButton; var T: Boolean);
begin
  T := Self.Wrap;
end;

procedure TToolButtonMenuItem_W(Self: TToolButton; const T: TMenuItem);
begin
  Self.MenuItem := T;
end;

procedure TToolButtonMenuItem_R(Self: TToolButton; var T: TMenuItem);
begin
  T := Self.MenuItem;
end;

procedure TToolButtonMarked_W(Self: TToolButton; const T: Boolean);
begin
  Self.Marked := T;
end;

procedure TToolButtonMarked_R(Self: TToolButton; var T: Boolean);
begin
  T := Self.Marked;
end;

procedure TToolButtonIndeterminate_W(Self: TToolButton; const T: Boolean);
begin
  Self.Indeterminate := T;
end;

procedure TToolButtonIndeterminate_R(Self: TToolButton; var T: Boolean);
begin
  T := Self.Indeterminate;
end;

procedure TToolButtonImageIndex_W(Self: TToolButton; const T: TImageIndex);
begin
  Self.ImageIndex := T;
end;

procedure TToolButtonImageIndex_R(Self: TToolButton; var T: TImageIndex);
begin
  T := Self.ImageIndex;
end;

procedure TToolButtonGrouped_W(Self: TToolButton; const T: Boolean);
begin
  Self.Grouped := T;
end;

procedure TToolButtonGrouped_R(Self: TToolButton; var T: Boolean);
begin
  T := Self.Grouped;
end;

procedure TToolButtonDropdownMenu_W(Self: TToolButton; const T: TPopupMenu);
begin
  Self.DropdownMenu := T;
end;

procedure TToolButtonDropdownMenu_R(Self: TToolButton; var T: TPopupMenu);
begin
  T := Self.DropdownMenu;
end;

procedure TToolButtonDown_W(Self: TToolButton; const T: Boolean);
begin
  Self.Down := T;
end;

procedure TToolButtonDown_R(Self: TToolButton; var T: Boolean);
begin
  T := Self.Down;
end;

procedure TToolButtonAutoSize_W(Self: TToolButton; const T: Boolean);
begin
  Self.AutoSize := T;
end;

procedure TToolButtonAutoSize_R(Self: TToolButton; var T: Boolean);
begin
  T := Self.AutoSize;
end;

procedure TToolButtonAllowAllUp_W(Self: TToolButton; const T: Boolean);
begin
  Self.AllowAllUp := T;
end;

procedure TToolButtonAllowAllUp_R(Self: TToolButton; var T: Boolean);
begin
  T := Self.AllowAllUp;
end;

procedure TToolButtonIndex_R(Self: TToolButton; var T: Integer);
begin
  T := Self.Index;
end;

procedure TAnimateOnStop_W(Self: TAnimate; const T: TNotifyEvent);
begin
  Self.OnStop := T;
end;

procedure TAnimateOnStop_R(Self: TAnimate; var T: TNotifyEvent);
begin
  T := Self.OnStop;
end;

procedure TAnimateOnStart_W(Self: TAnimate; const T: TNotifyEvent);
begin
  Self.OnStart := T;
end;

procedure TAnimateOnStart_R(Self: TAnimate; var T: TNotifyEvent);
begin
  T := Self.OnStart;
end;

procedure TAnimateOnClose_W(Self: TAnimate; const T: TNotifyEvent);
begin
  Self.OnClose := T;
end;

procedure TAnimateOnClose_R(Self: TAnimate; var T: TNotifyEvent);
begin
  T := Self.OnClose;
end;

procedure TAnimateOnOpen_W(Self: TAnimate; const T: TNotifyEvent);
begin
  Self.OnOpen := T;
end;

procedure TAnimateOnOpen_R(Self: TAnimate; var T: TNotifyEvent);
begin
  T := Self.OnOpen;
end;

procedure TAnimateTransparent_W(Self: TAnimate; const T: Boolean);
begin
  Self.Transparent := T;
end;

procedure TAnimateTransparent_R(Self: TAnimate; var T: Boolean);
begin
  T := Self.Transparent;
end;

procedure TAnimateTimers_W(Self: TAnimate; const T: Boolean);
begin
  Self.Timers := T;
end;

procedure TAnimateTimers_R(Self: TAnimate; var T: Boolean);
begin
  T := Self.Timers;
end;

procedure TAnimateStopFrame_W(Self: TAnimate; const T: Smallint);
begin
  Self.StopFrame := T;
end;

procedure TAnimateStopFrame_R(Self: TAnimate; var T: Smallint);
begin
  T := Self.StopFrame;
end;

procedure TAnimateStartFrame_W(Self: TAnimate; const T: Smallint);
begin
  Self.StartFrame := T;
end;

procedure TAnimateStartFrame_R(Self: TAnimate; var T: Smallint);
begin
  T := Self.StartFrame;
end;

procedure TAnimateRepetitions_W(Self: TAnimate; const T: Integer);
begin
  Self.Repetitions := T;
end;

procedure TAnimateRepetitions_R(Self: TAnimate; var T: Integer);
begin
  T := Self.Repetitions;
end;

procedure TAnimateFileName_W(Self: TAnimate; const T: string);
begin
  Self.FileName := T;
end;

procedure TAnimateFileName_R(Self: TAnimate; var T: string);
begin
  T := Self.FileName;
end;

procedure TAnimateCommonAVI_W(Self: TAnimate; const T: TCommonAVI);
begin
  Self.CommonAVI := T;
end;

procedure TAnimateCommonAVI_R(Self: TAnimate; var T: TCommonAVI);
begin
  T := Self.CommonAVI;
end;

procedure TAnimateCenter_W(Self: TAnimate; const T: Boolean);
begin
  Self.Center := T;
end;

procedure TAnimateCenter_R(Self: TAnimate; var T: Boolean);
begin
  T := Self.Center;
end;

procedure TAnimateActive_W(Self: TAnimate; const T: Boolean);
begin
  Self.Active := T;
end;

procedure TAnimateActive_R(Self: TAnimate; var T: Boolean);
begin
  T := Self.Active;
end;

procedure TAnimateResName_W(Self: TAnimate; const T: string);
begin
  Self.ResName := T;
end;

procedure TAnimateResName_R(Self: TAnimate; var T: string);
begin
  T := Self.ResName;
end;

procedure TAnimateResId_W(Self: TAnimate; const T: Integer);
begin
  Self.ResId := T;
end;

procedure TAnimateResId_R(Self: TAnimate; var T: Integer);
begin
  T := Self.ResId;
end;

procedure TAnimateResHandle_W(Self: TAnimate; const T: THandle);
begin
  Self.ResHandle := T;
end;

procedure TAnimateResHandle_R(Self: TAnimate; var T: THandle);
begin
  T := Self.ResHandle;
end;

procedure TAnimateOpen_W(Self: TAnimate; const T: Boolean);
begin
  Self.Open := T;
end;

procedure TAnimateOpen_R(Self: TAnimate; var T: Boolean);
begin
  T := Self.Open;
end;

procedure TAnimateFrameWidth_R(Self: TAnimate; var T: Integer);
begin
  T := Self.FrameWidth;
end;

procedure TAnimateFrameHeight_R(Self: TAnimate; var T: Integer);
begin
  T := Self.FrameHeight;
end;

procedure TAnimateFrameCount_R(Self: TAnimate; var T: Integer);
begin
  T := Self.FrameCount;
end;

procedure TCustomListViewWorkAreas_R(Self: TCustomListView; var T: TWorkAreas);
begin
  T := Self.WorkAreas;
end;

procedure TCustomListViewBoundingRect_R(Self: TCustomListView; var T: TRect);
begin
  T := Self.BoundingRect;
end;

procedure TCustomListViewVisibleRowCount_R(Self: TCustomListView; var T: Integer);
begin
  T := Self.VisibleRowCount;
end;

procedure TCustomListViewViewOrigin_R(Self: TCustomListView; var T: TPoint);
begin
  T := Self.ViewOrigin;
end;

procedure TCustomListViewTopItem_R(Self: TCustomListView; var T: TListItem);
begin
  T := Self.TopItem;
end;

procedure TCustomListViewSelected_W(Self: TCustomListView; const T: TListItem);
begin
  Self.Selected := T;
end;

procedure TCustomListViewSelected_R(Self: TCustomListView; var T: TListItem);
begin
  T := Self.Selected;
end;

procedure TCustomListViewSelCount_R(Self: TCustomListView; var T: Integer);
begin
  T := Self.SelCount;
end;

procedure TCustomListViewRowSelect_W(Self: TCustomListView; const T: Boolean);
begin
  Self.RowSelect := T;
end;

procedure TCustomListViewRowSelect_R(Self: TCustomListView; var T: Boolean);
begin
  T := Self.RowSelect;
end;

procedure TCustomListViewItemFocused_W(Self: TCustomListView; const T: TListItem);
begin
  Self.ItemFocused := T;
end;

procedure TCustomListViewItemFocused_R(Self: TCustomListView; var T: TListItem);
begin
  T := Self.ItemFocused;
end;

procedure TCustomListViewHotTrackStyles_W(Self: TCustomListView; const T: TListHotTrackStyles);
begin
  Self.HotTrackStyles := T;
end;

procedure TCustomListViewHotTrackStyles_R(Self: TCustomListView; var T: TListHotTrackStyles);
begin
  T := Self.HotTrackStyles;
end;

procedure TCustomListViewHotTrack_W(Self: TCustomListView; const T: Boolean);
begin
  Self.HotTrack := T;
end;

procedure TCustomListViewHotTrack_R(Self: TCustomListView; var T: Boolean);
begin
  T := Self.HotTrack;
end;

procedure TCustomListViewGridLines_W(Self: TCustomListView; const T: Boolean);
begin
  Self.GridLines := T;
end;

procedure TCustomListViewGridLines_R(Self: TCustomListView; var T: Boolean);
begin
  T := Self.GridLines;
end;

procedure TCustomListViewFullDrag_W(Self: TCustomListView; const T: Boolean);
begin
  Self.FullDrag := T;
end;

procedure TCustomListViewFullDrag_R(Self: TCustomListView; var T: Boolean);
begin
  T := Self.FullDrag;
end;

procedure TCustomListViewFlatScrollBars_W(Self: TCustomListView; const T: Boolean);
begin
  Self.FlatScrollBars := T;
end;

procedure TCustomListViewFlatScrollBars_R(Self: TCustomListView; var T: Boolean);
begin
  T := Self.FlatScrollBars;
end;

procedure TCustomListViewDropTarget_W(Self: TCustomListView; const T: TListItem);
begin
  Self.DropTarget := T;
end;

procedure TCustomListViewDropTarget_R(Self: TCustomListView; var T: TListItem);
begin
  T := Self.DropTarget;
end;

procedure TCustomListViewColumn_R(Self: TCustomListView; var T: TListColumn; const t1: Integer);
begin
  T := Self.Column[t1];
end;

procedure TCustomListViewCheckboxes_W(Self: TCustomListView; const T: Boolean);
begin
  Self.Checkboxes := T;
end;

procedure TCustomListViewCheckboxes_R(Self: TCustomListView; var T: Boolean);
begin
  T := Self.Checkboxes;
end;

procedure TCustomListViewCanvas_R(Self: TCustomListView; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure TIconOptionsWrapText_W(Self: TIconOptions; const T: Boolean);
begin
  Self.WrapText := T;
end;

procedure TIconOptionsWrapText_R(Self: TIconOptions; var T: Boolean);
begin
  T := Self.WrapText;
end;

procedure TIconOptionsAutoArrange_W(Self: TIconOptions; const T: Boolean);
begin
  Self.AutoArrange := T;
end;

procedure TIconOptionsAutoArrange_R(Self: TIconOptions; var T: Boolean);
begin
  T := Self.AutoArrange;
end;

procedure TIconOptionsArrangement_W(Self: TIconOptions; const T: TIconArrangement);
begin
  Self.Arrangement := T;
end;

procedure TIconOptionsArrangement_R(Self: TIconOptions; var T: TIconArrangement);
begin
  T := Self.Arrangement;
end;

procedure TWorkAreasItems_W(Self: TWorkAreas; const T: TWorkArea; const t1: Integer);
begin
  Self.Items[t1] := T;
end;

procedure TWorkAreasItems_R(Self: TWorkAreas; var T: TWorkArea; const t1: Integer);
begin
  T := Self.Items[t1];
end;

procedure TWorkAreaColor_W(Self: TWorkArea; const T: TColor);
begin
  Self.Color := T;
end;

procedure TWorkAreaColor_R(Self: TWorkArea; var T: TColor);
begin
  T := Self.Color;
end;

procedure TWorkAreaRect_W(Self: TWorkArea; const T: TRect);
begin
  Self.Rect := T;
end;

procedure TWorkAreaRect_R(Self: TWorkArea; var T: TRect);
begin
  T := Self.Rect;
end;

procedure TListItemsOwner_R(Self: TListItems; var T: TCustomListView);
begin
  T := Self.Owner;
end;

procedure TListItemsItem_W(Self: TListItems; const T: TListItem; const t1: Integer);
begin
  Self.Item[t1] := T;
end;

procedure TListItemsItem_R(Self: TListItems; var T: TListItem; const t1: Integer);
begin
  T := Self.Item[t1];
end;

procedure TListItemsHandle_R(Self: TListItems; var T: HWND);
begin
  T := Self.Handle;
end;

procedure TListItemsCount_W(Self: TListItems; const T: Integer);
begin
  Self.Count := T;
end;

procedure TListItemsCount_R(Self: TListItems; var T: Integer);
begin
  T := Self.Count;
end;

procedure TListItemTop_W(Self: TListItem; const T: Integer);
begin
  Self.Top := T;
end;

procedure TListItemTop_R(Self: TListItem; var T: Integer);
begin
  T := Self.Top;
end;

procedure TListItemSubItemImages_W(Self: TListItem; const T: Integer; const t1: Integer);
begin
  Self.SubItemImages[t1] := T;
end;

procedure TListItemSubItemImages_R(Self: TListItem; var T: Integer; const t1: Integer);
begin
  T := Self.SubItemImages[t1];
end;

procedure TListItemSubItems_W(Self: TListItem; const T: TStrings);
begin
  Self.SubItems := T;
end;

procedure TListItemSubItems_R(Self: TListItem; var T: TStrings);
begin
  T := Self.SubItems;
end;

procedure TListItemStateIndex_W(Self: TListItem; const T: TImageIndex);
begin
  Self.StateIndex := T;
end;

procedure TListItemStateIndex_R(Self: TListItem; var T: TImageIndex);
begin
  T := Self.StateIndex;
end;

procedure TListItemSelected_W(Self: TListItem; const T: Boolean);
begin
  Self.Selected := T;
end;

procedure TListItemSelected_R(Self: TListItem; var T: Boolean);
begin
  T := Self.Selected;
end;

procedure TListItemPosition_W(Self: TListItem; const T: TPoint);
begin
  Self.Position := T;
end;

procedure TListItemPosition_R(Self: TListItem; var T: TPoint);
begin
  T := Self.Position;
end;

procedure TListItemOverlayIndex_W(Self: TListItem; const T: TImageIndex);
begin
  Self.OverlayIndex := T;
end;

procedure TListItemOverlayIndex_R(Self: TListItem; var T: TImageIndex);
begin
  T := Self.OverlayIndex;
end;

procedure TListItemOwner_R(Self: TListItem; var T: TListItems);
begin
  T := Self.Owner;
end;

procedure TListItemListView_R(Self: TListItem; var T: TCustomListView);
begin
  T := Self.ListView;
end;

procedure TListItemLeft_W(Self: TListItem; const T: Integer);
begin
  Self.Left := T;
end;

procedure TListItemLeft_R(Self: TListItem; var T: Integer);
begin
  T := Self.Left;
end;

procedure TListItemIndex_R(Self: TListItem; var T: Integer);
begin
  T := Self.Index;
end;

procedure TListItemIndent_W(Self: TListItem; const T: Integer);
begin
  Self.Indent := T;
end;

procedure TListItemIndent_R(Self: TListItem; var T: Integer);
begin
  T := Self.Indent;
end;

procedure TListItemImageIndex_W(Self: TListItem; const T: TImageIndex);
begin
  Self.ImageIndex := T;
end;

procedure TListItemImageIndex_R(Self: TListItem; var T: TImageIndex);
begin
  T := Self.ImageIndex;
end;

procedure TListItemHandle_R(Self: TListItem; var T: HWND);
begin
  T := Self.Handle;
end;

procedure TListItemFocused_W(Self: TListItem; const T: Boolean);
begin
  Self.Focused := T;
end;

procedure TListItemFocused_R(Self: TListItem; var T: Boolean);
begin
  T := Self.Focused;
end;

procedure TListItemDropTarget_W(Self: TListItem; const T: Boolean);
begin
  Self.DropTarget := T;
end;

procedure TListItemDropTarget_R(Self: TListItem; var T: Boolean);
begin
  T := Self.DropTarget;
end;

procedure TListItemData_W(Self: TListItem; const T: Pointer);
begin
  Self.Data := T;
end;

procedure TListItemData_R(Self: TListItem; var T: Pointer);
begin
  T := Self.Data;
end;

procedure TListItemCut_W(Self: TListItem; const T: Boolean);
begin
  Self.Cut := T;
end;

procedure TListItemCut_R(Self: TListItem; var T: Boolean);
begin
  T := Self.Cut;
end;

procedure TListItemChecked_W(Self: TListItem; const T: Boolean);
begin
  Self.Checked := T;
end;

procedure TListItemChecked_R(Self: TListItem; var T: Boolean);
begin
  T := Self.Checked;
end;

procedure TListItemCaption_W(Self: TListItem; const T: string);
begin
  Self.Caption := T;
end;

procedure TListItemCaption_R(Self: TListItem; var T: string);
begin
  T := Self.Caption;
end;

procedure TListColumnsItems_W(Self: TListColumns; const T: TListColumn; const t1: Integer);
begin
  Self.Items[t1] := T;
end;

procedure TListColumnsItems_R(Self: TListColumns; var T: TListColumn; const t1: Integer);
begin
  T := Self.Items[t1];
end;

procedure TListColumnsOwner_R(Self: TListColumns; var T: TCustomListView);
begin
  T := Self.Owner;
end;

procedure TListColumnWidth_W(Self: TListColumn; const T: TWidth);
begin
  Self.Width := T;
end;

procedure TListColumnWidth_R(Self: TListColumn; var T: TWidth);
begin
  T := Self.Width;
end;

procedure TListColumnTag_W(Self: TListColumn; const T: Integer);
begin
  Self.Tag := T;
end;

procedure TListColumnTag_R(Self: TListColumn; var T: Integer);
begin
  T := Self.Tag;
end;

procedure TListColumnMinWidth_W(Self: TListColumn; const T: TWidth);
begin
  Self.MinWidth := T;
end;

procedure TListColumnMinWidth_R(Self: TListColumn; var T: TWidth);
begin
  T := Self.MinWidth;
end;

procedure TListColumnMaxWidth_W(Self: TListColumn; const T: TWidth);
begin
  Self.MaxWidth := T;
end;

procedure TListColumnMaxWidth_R(Self: TListColumn; var T: TWidth);
begin
  T := Self.MaxWidth;
end;

procedure TListColumnImageIndex_W(Self: TListColumn; const T: TImageIndex);
begin
  Self.ImageIndex := T;
end;

procedure TListColumnImageIndex_R(Self: TListColumn; var T: TImageIndex);
begin
  T := Self.ImageIndex;
end;

procedure TListColumnCaption_W(Self: TListColumn; const T: string);
begin
  Self.Caption := T;
end;

procedure TListColumnCaption_R(Self: TListColumn; var T: string);
begin
  T := Self.Caption;
end;

procedure TListColumnAutoSize_W(Self: TListColumn; const T: Boolean);
begin
  Self.AutoSize := T;
end;

procedure TListColumnAutoSize_R(Self: TListColumn; var T: Boolean);
begin
  T := Self.AutoSize;
end;

procedure TListColumnAlignment_W(Self: TListColumn; const T: TAlignment);
begin
  Self.Alignment := T;
end;

procedure TListColumnAlignment_R(Self: TListColumn; var T: TAlignment);
begin
  T := Self.Alignment;
end;

procedure TListColumnWidthType_R(Self: TListColumn; var T: TWidth);
begin
  T := Self.WidthType;
end;

procedure TCustomRichEditParagraph_R(Self: TCustomRichEdit; var T: TParaAttributes);
begin
  T := Self.Paragraph;
end;

procedure TCustomRichEditPageRect_W(Self: TCustomRichEdit; const T: TRect);
begin
  Self.PageRect := T;
end;

procedure TCustomRichEditPageRect_R(Self: TCustomRichEdit; var T: TRect);
begin
  T := Self.PageRect;
end;

procedure TCustomRichEditSelAttributes_W(Self: TCustomRichEdit; const T: TTextAttributes);
begin
  Self.SelAttributes := T;
end;

procedure TCustomRichEditSelAttributes_R(Self: TCustomRichEdit; var T: TTextAttributes);
begin
  T := Self.SelAttributes;
end;

procedure TCustomRichEditDefAttributes_W(Self: TCustomRichEdit; const T: TTextAttributes);
begin
  Self.DefAttributes := T;
end;

procedure TCustomRichEditDefAttributes_R(Self: TCustomRichEdit; var T: TTextAttributes);
begin
  T := Self.DefAttributes;
end;

procedure TCustomRichEditDefaultConverter_W(Self: TCustomRichEdit; const T: TConversionClass);
begin
  Self.DefaultConverter := T;
end;

procedure TCustomRichEditDefaultConverter_R(Self: TCustomRichEdit; var T: TConversionClass);
begin
  T := Self.DefaultConverter;
end;

procedure TParaAttributesTabCount_W(Self: TParaAttributes; const T: Integer);
begin
  Self.TabCount := T;
end;

procedure TParaAttributesTabCount_R(Self: TParaAttributes; var T: Integer);
begin
  T := Self.TabCount;
end;

procedure TParaAttributesTab_W(Self: TParaAttributes; const T: Longint; const t1: Byte);
begin
  Self.Tab[t1] := T;
end;

procedure TParaAttributesTab_R(Self: TParaAttributes; var T: Longint; const t1: Byte);
begin
  T := Self.Tab[t1];
end;

procedure TParaAttributesRightIndent_W(Self: TParaAttributes; const T: Longint);
begin
  Self.RightIndent := T;
end;

procedure TParaAttributesRightIndent_R(Self: TParaAttributes; var T: Longint);
begin
  T := Self.RightIndent;
end;

procedure TParaAttributesNumbering_W(Self: TParaAttributes; const T: TNumberingStyle);
begin
  Self.Numbering := T;
end;

procedure TParaAttributesNumbering_R(Self: TParaAttributes; var T: TNumberingStyle);
begin
  T := Self.Numbering;
end;

procedure TParaAttributesLeftIndent_W(Self: TParaAttributes; const T: Longint);
begin
  Self.LeftIndent := T;
end;

procedure TParaAttributesLeftIndent_R(Self: TParaAttributes; var T: Longint);
begin
  T := Self.LeftIndent;
end;

procedure TParaAttributesFirstIndent_W(Self: TParaAttributes; const T: Longint);
begin
  Self.FirstIndent := T;
end;

procedure TParaAttributesFirstIndent_R(Self: TParaAttributes; var T: Longint);
begin
  T := Self.FirstIndent;
end;

procedure TParaAttributesAlignment_W(Self: TParaAttributes; const T: TAlignment);
begin
  Self.Alignment := T;
end;

procedure TParaAttributesAlignment_R(Self: TParaAttributes; var T: TAlignment);
begin
  T := Self.Alignment;
end;

procedure TTextAttributesHeight_W(Self: TTextAttributes; const T: Integer);
begin
  Self.Height := T;
end;

procedure TTextAttributesHeight_R(Self: TTextAttributes; var T: Integer);
begin
  T := Self.Height;
end;

procedure TTextAttributesStyle_W(Self: TTextAttributes; const T: TFontStyles);
begin
  Self.Style := T;
end;

procedure TTextAttributesStyle_R(Self: TTextAttributes; var T: TFontStyles);
begin
  T := Self.Style;
end;

procedure TTextAttributesSize_W(Self: TTextAttributes; const T: Integer);
begin
  Self.Size := T;
end;

procedure TTextAttributesSize_R(Self: TTextAttributes; var T: Integer);
begin
  T := Self.Size;
end;

procedure TTextAttributesPitch_W(Self: TTextAttributes; const T: TFontPitch);
begin
  Self.Pitch := T;
end;

procedure TTextAttributesPitch_R(Self: TTextAttributes; var T: TFontPitch);
begin
  T := Self.Pitch;
end;

procedure TTextAttributesName_W(Self: TTextAttributes; const T: TFontName);
begin
  Self.Name := T;
end;

procedure TTextAttributesName_R(Self: TTextAttributes; var T: TFontName);
begin
  T := Self.Name;
end;

procedure TTextAttributesConsistentAttributes_R(Self: TTextAttributes; var T: TConsistentAttributes);
begin
  T := Self.ConsistentAttributes;
end;

procedure TTextAttributesColor_W(Self: TTextAttributes; const T: TColor);
begin
  Self.Color := T;
end;

procedure TTextAttributesColor_R(Self: TTextAttributes; var T: TColor);
begin
  T := Self.Color;
end;

procedure TTextAttributesCharset_W(Self: TTextAttributes; const T: TFontCharset);
begin
  Self.Charset := T;
end;

procedure TTextAttributesCharset_R(Self: TTextAttributes; var T: TFontCharset);
begin
  T := Self.Charset;
end;

procedure TProgressBarStep_W(Self: TProgressBar; const T: Integer);
begin
  Self.Step := T;
end;

procedure TProgressBarStep_R(Self: TProgressBar; var T: Integer);
begin
  T := Self.Step;
end;

procedure TProgressBarSmooth_W(Self: TProgressBar; const T: Boolean);
begin
  Self.Smooth := T;
end;

procedure TProgressBarSmooth_R(Self: TProgressBar; var T: Boolean);
begin
  T := Self.Smooth;
end;

procedure TProgressBarPosition_W(Self: TProgressBar; const T: Integer);
begin
  Self.Position := T;
end;

procedure TProgressBarPosition_R(Self: TProgressBar; var T: Integer);
begin
  T := Self.Position;
end;

procedure TProgressBarOrientation_W(Self: TProgressBar; const T: TProgressBarOrientation);
begin
  Self.Orientation := T;
end;

procedure TProgressBarOrientation_R(Self: TProgressBar; var T: TProgressBarOrientation);
begin
  T := Self.Orientation;
end;

procedure TProgressBarMax_W(Self: TProgressBar; const T: Integer);
begin
  Self.Max := T;
end;

procedure TProgressBarMax_R(Self: TProgressBar; var T: Integer);
begin
  T := Self.Max;
end;

procedure TProgressBarMin_W(Self: TProgressBar; const T: Integer);
begin
  Self.Min := T;
end;

procedure TProgressBarMin_R(Self: TProgressBar; var T: Integer);
begin
  T := Self.Min;
end;

procedure TTrackBarOnChange_W(Self: TTrackBar; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TTrackBarOnChange_R(Self: TTrackBar; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TTrackBarTickStyle_W(Self: TTrackBar; const T: TTickStyle);
begin
  Self.TickStyle := T;
end;

procedure TTrackBarTickStyle_R(Self: TTrackBar; var T: TTickStyle);
begin
  T := Self.TickStyle;
end;

procedure TTrackBarTickMarks_W(Self: TTrackBar; const T: TTickMark);
begin
  Self.TickMarks := T;
end;

procedure TTrackBarTickMarks_R(Self: TTrackBar; var T: TTickMark);
begin
  T := Self.TickMarks;
end;

procedure TTrackBarThumbLength_W(Self: TTrackBar; const T: Integer);
begin
  Self.ThumbLength := T;
end;

procedure TTrackBarThumbLength_R(Self: TTrackBar; var T: Integer);
begin
  T := Self.ThumbLength;
end;

procedure TTrackBarSelStart_W(Self: TTrackBar; const T: Integer);
begin
  Self.SelStart := T;
end;

procedure TTrackBarSelStart_R(Self: TTrackBar; var T: Integer);
begin
  T := Self.SelStart;
end;

procedure TTrackBarSelEnd_W(Self: TTrackBar; const T: Integer);
begin
  Self.SelEnd := T;
end;

procedure TTrackBarSelEnd_R(Self: TTrackBar; var T: Integer);
begin
  T := Self.SelEnd;
end;

procedure TTrackBarSliderVisible_W(Self: TTrackBar; const T: Boolean);
begin
  Self.SliderVisible := T;
end;

procedure TTrackBarSliderVisible_R(Self: TTrackBar; var T: Boolean);
begin
  T := Self.SliderVisible;
end;

procedure TTrackBarPosition_W(Self: TTrackBar; const T: Integer);
begin
  Self.Position := T;
end;

procedure TTrackBarPosition_R(Self: TTrackBar; var T: Integer);
begin
  T := Self.Position;
end;

procedure TTrackBarFrequency_W(Self: TTrackBar; const T: Integer);
begin
  Self.Frequency := T;
end;

procedure TTrackBarFrequency_R(Self: TTrackBar; var T: Integer);
begin
  T := Self.Frequency;
end;

procedure TTrackBarPageSize_W(Self: TTrackBar; const T: Integer);
begin
  Self.PageSize := T;
end;

procedure TTrackBarPageSize_R(Self: TTrackBar; var T: Integer);
begin
  T := Self.PageSize;
end;

procedure TTrackBarOrientation_W(Self: TTrackBar; const T: TTrackBarOrientation);
begin
  Self.Orientation := T;
end;

procedure TTrackBarOrientation_R(Self: TTrackBar; var T: TTrackBarOrientation);
begin
  T := Self.Orientation;
end;

procedure TTrackBarMin_W(Self: TTrackBar; const T: Integer);
begin
  Self.Min := T;
end;

procedure TTrackBarMin_R(Self: TTrackBar; var T: Integer);
begin
  T := Self.Min;
end;

procedure TTrackBarMax_W(Self: TTrackBar; const T: Integer);
begin
  Self.Max := T;
end;

procedure TTrackBarMax_R(Self: TTrackBar; var T: Integer);
begin
  T := Self.Max;
end;

procedure TTrackBarLineSize_W(Self: TTrackBar; const T: Integer);
begin
  Self.LineSize := T;
end;

procedure TTrackBarLineSize_R(Self: TTrackBar; var T: Integer);
begin
  T := Self.LineSize;
end;

procedure TCustomTreeViewTopItem_W(Self: TCustomTreeView; const T: TTreeNode);
begin
  Self.TopItem := T;
end;

procedure TCustomTreeViewTopItem_R(Self: TCustomTreeView; var T: TTreeNode);
begin
  T := Self.TopItem;
end;

procedure TCustomTreeViewSelected_W(Self: TCustomTreeView; const T: TTreeNode);
begin
  Self.Selected := T;
end;

procedure TCustomTreeViewSelected_R(Self: TCustomTreeView; var T: TTreeNode);
begin
  T := Self.Selected;
end;

procedure TCustomTreeViewDropTarget_W(Self: TCustomTreeView; const T: TTreeNode);
begin
  Self.DropTarget := T;
end;

procedure TCustomTreeViewDropTarget_R(Self: TCustomTreeView; var T: TTreeNode);
begin
  T := Self.DropTarget;
end;

procedure TCustomTreeViewCanvas_R(Self: TCustomTreeView; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure TTreeNodesOwner_R(Self: TTreeNodes; var T: TCustomTreeView);
begin
  T := Self.Owner;
end;

procedure TTreeNodesItem_R(Self: TTreeNodes; var T: TTreeNode; const t1: Integer);
begin
  T := Self.Item[t1];
end;

procedure TTreeNodesHandle_R(Self: TTreeNodes; var T: HWND);
begin
  T := Self.Handle;
end;

procedure TTreeNodesCount_R(Self: TTreeNodes; var T: Integer);
begin
  T := Self.Count;
end;

procedure TTreeNodeTreeView_R(Self: TTreeNode; var T: TCustomTreeView);
begin
  T := Self.TreeView;
end;

procedure TTreeNodeText_W(Self: TTreeNode; const T: string);
begin
  Self.Text := T;
end;

procedure TTreeNodeText_R(Self: TTreeNode; var T: string);
begin
  T := Self.Text;
end;

procedure TTreeNodeStateIndex_W(Self: TTreeNode; const T: Integer);
begin
  Self.StateIndex := T;
end;

procedure TTreeNodeStateIndex_R(Self: TTreeNode; var T: Integer);
begin
  T := Self.StateIndex;
end;

procedure TTreeNodeSelectedIndex_W(Self: TTreeNode; const T: Integer);
begin
  Self.SelectedIndex := T;
end;

procedure TTreeNodeSelectedIndex_R(Self: TTreeNode; var T: Integer);
begin
  T := Self.SelectedIndex;
end;

procedure TTreeNodeParent_R(Self: TTreeNode; var T: TTreeNode);
begin
  T := Self.Parent;
end;

procedure TTreeNodeOwner_R(Self: TTreeNode; var T: TTreeNodes);
begin
  T := Self.Owner;
end;

procedure TTreeNodeOverlayIndex_W(Self: TTreeNode; const T: Integer);
begin
  Self.OverlayIndex := T;
end;

procedure TTreeNodeOverlayIndex_R(Self: TTreeNode; var T: Integer);
begin
  T := Self.OverlayIndex;
end;

procedure TTreeNodeLevel_R(Self: TTreeNode; var T: Integer);
begin
  T := Self.Level;
end;

procedure TTreeNodeItemId_R(Self: TTreeNode; var T: HTreeItem);
begin
  T := Self.ItemId;
end;

procedure TTreeNodeItem_W(Self: TTreeNode; const T: TTreeNode; const t1: Integer);
begin
  Self.Item[t1] := T;
end;

procedure TTreeNodeItem_R(Self: TTreeNode; var T: TTreeNode; const t1: Integer);
begin
  T := Self.Item[t1];
end;

procedure TTreeNodeIsVisible_R(Self: TTreeNode; var T: Boolean);
begin
  T := Self.IsVisible;
end;

procedure TTreeNodeIndex_R(Self: TTreeNode; var T: Integer);
begin
  T := Self.Index;
end;

procedure TTreeNodeImageIndex_W(Self: TTreeNode; const T: TImageIndex);
begin
  Self.ImageIndex := T;
end;

procedure TTreeNodeImageIndex_R(Self: TTreeNode; var T: TImageIndex);
begin
  T := Self.ImageIndex;
end;

procedure TTreeNodeHasChildren_W(Self: TTreeNode; const T: Boolean);
begin
  Self.HasChildren := T;
end;

procedure TTreeNodeHasChildren_R(Self: TTreeNode; var T: Boolean);
begin
  T := Self.HasChildren;
end;

procedure TTreeNodeHandle_R(Self: TTreeNode; var T: HWND);
begin
  T := Self.Handle;
end;

procedure TTreeNodeExpanded_W(Self: TTreeNode; const T: Boolean);
begin
  Self.Expanded := T;
end;

procedure TTreeNodeExpanded_R(Self: TTreeNode; var T: Boolean);
begin
  T := Self.Expanded;
end;

procedure TTreeNodeSelected_W(Self: TTreeNode; const T: Boolean);
begin
  Self.Selected := T;
end;

procedure TTreeNodeSelected_R(Self: TTreeNode; var T: Boolean);
begin
  T := Self.Selected;
end;

procedure TTreeNodeDropTarget_W(Self: TTreeNode; const T: Boolean);
begin
  Self.DropTarget := T;
end;

procedure TTreeNodeDropTarget_R(Self: TTreeNode; var T: Boolean);
begin
  T := Self.DropTarget;
end;

procedure TTreeNodeFocused_W(Self: TTreeNode; const T: Boolean);
begin
  Self.Focused := T;
end;

procedure TTreeNodeFocused_R(Self: TTreeNode; var T: Boolean);
begin
  T := Self.Focused;
end;

procedure TTreeNodeDeleting_R(Self: TTreeNode; var T: Boolean);
begin
  T := Self.Deleting;
end;

procedure TTreeNodeData_W(Self: TTreeNode; const T: Pointer);
begin
  Self.Data := T;
end;

procedure TTreeNodeData_R(Self: TTreeNode; var T: Pointer);
begin
  T := Self.Data;
end;

procedure TTreeNodeCut_W(Self: TTreeNode; const T: Boolean);
begin
  Self.Cut := T;
end;

procedure TTreeNodeCut_R(Self: TTreeNode; var T: Boolean);
begin
  T := Self.Cut;
end;

procedure TTreeNodeCount_R(Self: TTreeNode; var T: Integer);
begin
  T := Self.Count;
end;

procedure TTreeNodeAbsoluteIndex_R(Self: TTreeNode; var T: Integer);
begin
  T := Self.AbsoluteIndex;
end;

procedure THeaderControlOnSectionTrack_W(Self: THeaderControl; const T: TSectionTrackEvent);
begin
  Self.OnSectionTrack := T;
end;

procedure THeaderControlOnSectionTrack_R(Self: THeaderControl; var T: TSectionTrackEvent);
begin
  T := Self.OnSectionTrack;
end;

procedure THeaderControlOnSectionResize_W(Self: THeaderControl; const T: TSectionNotifyEvent);
begin
  Self.OnSectionResize := T;
end;

procedure THeaderControlOnSectionResize_R(Self: THeaderControl; var T: TSectionNotifyEvent);
begin
  T := Self.OnSectionResize;
end;

procedure THeaderControlOnSectionEndDrag_W(Self: THeaderControl; const T: TNotifyEvent);
begin
  Self.OnSectionEndDrag := T;
end;

procedure THeaderControlOnSectionEndDrag_R(Self: THeaderControl; var T: TNotifyEvent);
begin
  T := Self.OnSectionEndDrag;
end;

procedure THeaderControlOnSectionDrag_W(Self: THeaderControl; const T: TSectionDragEvent);
begin
  Self.OnSectionDrag := T;
end;

procedure THeaderControlOnSectionDrag_R(Self: THeaderControl; var T: TSectionDragEvent);
begin
  T := Self.OnSectionDrag;
end;

procedure THeaderControlOnSectionClick_W(Self: THeaderControl; const T: TSectionNotifyEvent);
begin
  Self.OnSectionClick := T;
end;

procedure THeaderControlOnSectionClick_R(Self: THeaderControl; var T: TSectionNotifyEvent);
begin
  T := Self.OnSectionClick;
end;

procedure THeaderControlOnDrawSection_W(Self: THeaderControl; const T: TDrawSectionEvent);
begin
  Self.OnDrawSection := T;
end;

procedure THeaderControlOnDrawSection_R(Self: THeaderControl; var T: TDrawSectionEvent);
begin
  T := Self.OnDrawSection;
end;

procedure THeaderControlStyle_W(Self: THeaderControl; const T: THeaderStyle);
begin
  Self.Style := T;
end;

procedure THeaderControlStyle_R(Self: THeaderControl; var T: THeaderStyle);
begin
  T := Self.Style;
end;

procedure THeaderControlSections_W(Self: THeaderControl; const T: THeaderSections);
begin
  Self.Sections := T;
end;

procedure THeaderControlSections_R(Self: THeaderControl; var T: THeaderSections);
begin
  T := Self.Sections;
end;

procedure THeaderControlImages_W(Self: THeaderControl; const T: TCustomImageList);
begin
  Self.Images := T;
end;

procedure THeaderControlImages_R(Self: THeaderControl; var T: TCustomImageList);
begin
  T := Self.Images;
end;

procedure THeaderControlHotTrack_W(Self: THeaderControl; const T: Boolean);
begin
  Self.HotTrack := T;
end;

procedure THeaderControlHotTrack_R(Self: THeaderControl; var T: Boolean);
begin
  T := Self.HotTrack;
end;

procedure THeaderControlFullDrag_W(Self: THeaderControl; const T: Boolean);
begin
  Self.FullDrag := T;
end;

procedure THeaderControlFullDrag_R(Self: THeaderControl; var T: Boolean);
begin
  T := Self.FullDrag;
end;

procedure THeaderControlDragReorder_W(Self: THeaderControl; const T: Boolean);
begin
  Self.DragReorder := T;
end;

procedure THeaderControlDragReorder_R(Self: THeaderControl; var T: Boolean);
begin
  T := Self.DragReorder;
end;

procedure THeaderControlCanvas_R(Self: THeaderControl; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure THeaderSectionsItems_W(Self: THeaderSections; const T: THeaderSection; const t1: Integer);
begin
  Self.Items[t1] := T;
end;

procedure THeaderSectionsItems_R(Self: THeaderSections; var T: THeaderSection; const t1: Integer);
begin
  T := Self.Items[t1];
end;

procedure THeaderSectionWidth_W(Self: THeaderSection; const T: Integer);
begin
  Self.Width := T;
end;

procedure THeaderSectionWidth_R(Self: THeaderSection; var T: Integer);
begin
  T := Self.Width;
end;

procedure THeaderSectionText_W(Self: THeaderSection; const T: string);
begin
  Self.Text := T;
end;

procedure THeaderSectionText_R(Self: THeaderSection; var T: string);
begin
  T := Self.Text;
end;

procedure THeaderSectionStyle_W(Self: THeaderSection; const T: THeaderSectionStyle);
begin
  Self.Style := T;
end;

procedure THeaderSectionStyle_R(Self: THeaderSection; var T: THeaderSectionStyle);
begin
  T := Self.Style;
end;

procedure THeaderSectionParentBiDiMode_W(Self: THeaderSection; const T: Boolean);
begin
  Self.ParentBiDiMode := T;
end;

procedure THeaderSectionParentBiDiMode_R(Self: THeaderSection; var T: Boolean);
begin
  T := Self.ParentBiDiMode;
end;

procedure THeaderSectionMinWidth_W(Self: THeaderSection; const T: Integer);
begin
  Self.MinWidth := T;
end;

procedure THeaderSectionMinWidth_R(Self: THeaderSection; var T: Integer);
begin
  T := Self.MinWidth;
end;

procedure THeaderSectionMaxWidth_W(Self: THeaderSection; const T: Integer);
begin
  Self.MaxWidth := T;
end;

procedure THeaderSectionMaxWidth_R(Self: THeaderSection; var T: Integer);
begin
  T := Self.MaxWidth;
end;

procedure THeaderSectionImageIndex_W(Self: THeaderSection; const T: TImageIndex);
begin
  Self.ImageIndex := T;
end;

procedure THeaderSectionImageIndex_R(Self: THeaderSection; var T: TImageIndex);
begin
  T := Self.ImageIndex;
end;

procedure THeaderSectionBiDiMode_W(Self: THeaderSection; const T: TBiDiMode);
begin
  Self.BiDiMode := T;
end;

procedure THeaderSectionBiDiMode_R(Self: THeaderSection; var T: TBiDiMode);
begin
  T := Self.BiDiMode;
end;

procedure THeaderSectionAutoSize_W(Self: THeaderSection; const T: Boolean);
begin
  Self.AutoSize := T;
end;

procedure THeaderSectionAutoSize_R(Self: THeaderSection; var T: Boolean);
begin
  T := Self.AutoSize;
end;

procedure THeaderSectionAllowClick_W(Self: THeaderSection; const T: Boolean);
begin
  Self.AllowClick := T;
end;

procedure THeaderSectionAllowClick_R(Self: THeaderSection; var T: Boolean);
begin
  T := Self.AllowClick;
end;

procedure THeaderSectionAlignment_W(Self: THeaderSection; const T: TAlignment);
begin
  Self.Alignment := T;
end;

procedure THeaderSectionAlignment_R(Self: THeaderSection; var T: TAlignment);
begin
  T := Self.Alignment;
end;

procedure THeaderSectionRight_R(Self: THeaderSection; var T: Integer);
begin
  T := Self.Right;
end;

procedure THeaderSectionLeft_R(Self: THeaderSection; var T: Integer);
begin
  T := Self.Left;
end;

procedure TStatusBarOnDrawPanel_W(Self: TStatusBar; const T: TDrawPanelEvent);
begin
  Self.OnDrawPanel := T;
end;

procedure TStatusBarOnDrawPanel_R(Self: TStatusBar; var T: TDrawPanelEvent);
begin
  T := Self.OnDrawPanel;
end;

procedure TStatusBarOnHint_W(Self: TStatusBar; const T: TNotifyEvent);
begin
  Self.OnHint := T;
end;

procedure TStatusBarOnHint_R(Self: TStatusBar; var T: TNotifyEvent);
begin
  T := Self.OnHint;
end;

procedure TStatusBarUseSystemFont_W(Self: TStatusBar; const T: Boolean);
begin
  Self.UseSystemFont := T;
end;

procedure TStatusBarUseSystemFont_R(Self: TStatusBar; var T: Boolean);
begin
  T := Self.UseSystemFont;
end;

procedure TStatusBarSizeGrip_W(Self: TStatusBar; const T: Boolean);
begin
  Self.SizeGrip := T;
end;

procedure TStatusBarSizeGrip_R(Self: TStatusBar; var T: Boolean);
begin
  T := Self.SizeGrip;
end;

procedure TStatusBarSimpleText_W(Self: TStatusBar; const T: string);
begin
  Self.SimpleText := T;
end;

procedure TStatusBarSimpleText_R(Self: TStatusBar; var T: string);
begin
  T := Self.SimpleText;
end;

procedure TStatusBarSimplePanel_W(Self: TStatusBar; const T: Boolean);
begin
  Self.SimplePanel := T;
end;

procedure TStatusBarSimplePanel_R(Self: TStatusBar; var T: Boolean);
begin
  T := Self.SimplePanel;
end;

procedure TStatusBarPanels_W(Self: TStatusBar; const T: TStatusPanels);
begin
  Self.Panels := T;
end;

procedure TStatusBarPanels_R(Self: TStatusBar; var T: TStatusPanels);
begin
  T := Self.Panels;
end;

procedure TStatusBarAutoHint_W(Self: TStatusBar; const T: Boolean);
begin
  Self.AutoHint := T;
end;

procedure TStatusBarAutoHint_R(Self: TStatusBar; var T: Boolean);
begin
  T := Self.AutoHint;
end;

procedure TStatusBarCanvas_R(Self: TStatusBar; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure TStatusPanelsItems_W(Self: TStatusPanels; const T: TStatusPanel; const t1: Integer);
begin
  Self.Items[t1] := T;
end;

procedure TStatusPanelsItems_R(Self: TStatusPanels; var T: TStatusPanel; const t1: Integer);
begin
  T := Self.Items[t1];
end;

procedure TStatusPanelWidth_W(Self: TStatusPanel; const T: Integer);
begin
  Self.Width := T;
end;

procedure TStatusPanelWidth_R(Self: TStatusPanel; var T: Integer);
begin
  T := Self.Width;
end;

procedure TStatusPanelText_W(Self: TStatusPanel; const T: string);
begin
  Self.Text := T;
end;

procedure TStatusPanelText_R(Self: TStatusPanel; var T: string);
begin
  T := Self.Text;
end;

procedure TStatusPanelStyle_W(Self: TStatusPanel; const T: TStatusPanelStyle);
begin
  Self.Style := T;
end;

procedure TStatusPanelStyle_R(Self: TStatusPanel; var T: TStatusPanelStyle);
begin
  T := Self.Style;
end;

procedure TStatusPanelParentBiDiMode_W(Self: TStatusPanel; const T: Boolean);
begin
  Self.ParentBiDiMode := T;
end;

procedure TStatusPanelParentBiDiMode_R(Self: TStatusPanel; var T: Boolean);
begin
  T := Self.ParentBiDiMode;
end;

procedure TStatusPanelBiDiMode_W(Self: TStatusPanel; const T: TBiDiMode);
begin
  Self.BiDiMode := T;
end;

procedure TStatusPanelBiDiMode_R(Self: TStatusPanel; var T: TBiDiMode);
begin
  T := Self.BiDiMode;
end;

procedure TStatusPanelBevel_W(Self: TStatusPanel; const T: TStatusPanelBevel);
begin
  Self.Bevel := T;
end;

procedure TStatusPanelBevel_R(Self: TStatusPanel; var T: TStatusPanelBevel);
begin
  T := Self.Bevel;
end;

procedure TStatusPanelAlignment_W(Self: TStatusPanel; const T: TAlignment);
begin
  Self.Alignment := T;
end;

procedure TStatusPanelAlignment_R(Self: TStatusPanel; var T: TAlignment);
begin
  T := Self.Alignment;
end;

procedure TPageControlActivePage_W(Self: TPageControl; const T: TTabSheet);
begin
  Self.ActivePage := T;
end;

procedure TPageControlActivePage_R(Self: TPageControl; var T: TTabSheet);
begin
  T := Self.ActivePage;
end;

procedure TPageControlPages_R(Self: TPageControl; var T: TTabSheet; const t1: Integer);
begin
  T := Self.Pages[t1];
end;

procedure TPageControlPageCount_R(Self: TPageControl; var T: Integer);
begin
  T := Self.PageCount;
end;

procedure TPageControlActivePageIndex_W(Self: TPageControl; const T: Integer);
begin
  Self.ActivePageIndex := T;
end;

procedure TPageControlActivePageIndex_R(Self: TPageControl; var T: Integer);
begin
  T := Self.ActivePageIndex;
end;

procedure TTabSheetOnShow_W(Self: TTabSheet; const T: TNotifyEvent);
begin
  Self.OnShow := T;
end;

procedure TTabSheetOnShow_R(Self: TTabSheet; var T: TNotifyEvent);
begin
  T := Self.OnShow;
end;

procedure TTabSheetOnHide_W(Self: TTabSheet; const T: TNotifyEvent);
begin
  Self.OnHide := T;
end;

procedure TTabSheetOnHide_R(Self: TTabSheet; var T: TNotifyEvent);
begin
  T := Self.OnHide;
end;

procedure TTabSheetTabVisible_W(Self: TTabSheet; const T: Boolean);
begin
  Self.TabVisible := T;
end;

procedure TTabSheetTabVisible_R(Self: TTabSheet; var T: Boolean);
begin
  T := Self.TabVisible;
end;

procedure TTabSheetPageIndex_W(Self: TTabSheet; const T: Integer);
begin
  Self.PageIndex := T;
end;

procedure TTabSheetPageIndex_R(Self: TTabSheet; var T: Integer);
begin
  T := Self.PageIndex;
end;

procedure TTabSheetImageIndex_W(Self: TTabSheet; const T: TImageIndex);
begin
  Self.ImageIndex := T;
end;

procedure TTabSheetImageIndex_R(Self: TTabSheet; var T: TImageIndex);
begin
  T := Self.ImageIndex;
end;

procedure TTabSheetHighlighted_W(Self: TTabSheet; const T: Boolean);
begin
  Self.Highlighted := T;
end;

procedure TTabSheetHighlighted_R(Self: TTabSheet; var T: Boolean);
begin
  T := Self.Highlighted;
end;

procedure TTabSheetTabIndex_R(Self: TTabSheet; var T: Integer);
begin
  T := Self.TabIndex;
end;

procedure TTabSheetPageControl_W(Self: TTabSheet; const T: TPageControl);
begin
  Self.PageControl := T;
end;

procedure TTabSheetPageControl_R(Self: TTabSheet; var T: TPageControl);
begin
  T := Self.PageControl;
end;

procedure TCustomTabControlCanvas_R(Self: TCustomTabControl; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure RIRegister_ComCtrls_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@GetComCtlVersion, 'GetComCtlVersion', cdRegister);
  S.RegisterDelphiFunction(@CheckToolMenuDropdown, 'CheckToolMenuDropdown', cdRegister);
end;

procedure RIRegister_TPageScroller(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TPageScroller) do
  begin
    RegisterMethod(@TPageScroller.GetButtonState, 'GetButtonState');
    RegisterPropertyHelper(@TPageScrollerAutoScroll_R, @TPageScrollerAutoScroll_W, 'AutoScroll');
    RegisterPropertyHelper(@TPageScrollerButtonSize_R, @TPageScrollerButtonSize_W, 'ButtonSize');
    RegisterPropertyHelper(@TPageScrollerControl_R, @TPageScrollerControl_W, 'Control');
    RegisterPropertyHelper(@TPageScrollerDragScroll_R, @TPageScrollerDragScroll_W, 'DragScroll');
    RegisterPropertyHelper(@TPageScrollerMargin_R, @TPageScrollerMargin_W, 'Margin');
    RegisterPropertyHelper(@TPageScrollerOrientation_R, @TPageScrollerOrientation_W, 'Orientation');
    RegisterPropertyHelper(@TPageScrollerPosition_R, @TPageScrollerPosition_W, 'Position');
    RegisterPropertyHelper(@TPageScrollerOnScroll_R, @TPageScrollerOnScroll_W, 'OnScroll');
  end;
end;

procedure RIRegister_TDateTimePicker(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TDateTimePicker) do
  begin
    RegisterPropertyHelper(@TDateTimePickerDroppedDown_R, nil, 'DroppedDown');
    RegisterPropertyHelper(@TDateTimePickerCalAlignment_R, @TDateTimePickerCalAlignment_W, 'CalAlignment');
    RegisterPropertyHelper(@TDateTimePickerTime_R, @TDateTimePickerTime_W, 'Time');
    RegisterPropertyHelper(@TDateTimePickerShowCheckbox_R, @TDateTimePickerShowCheckbox_W, 'ShowCheckbox');
    RegisterPropertyHelper(@TDateTimePickerChecked_R, @TDateTimePickerChecked_W, 'Checked');
    RegisterPropertyHelper(@TDateTimePickerDateFormat_R, @TDateTimePickerDateFormat_W, 'DateFormat');
    RegisterPropertyHelper(@TDateTimePickerDateMode_R, @TDateTimePickerDateMode_W, 'DateMode');
    RegisterPropertyHelper(@TDateTimePickerKind_R, @TDateTimePickerKind_W, 'Kind');
    RegisterPropertyHelper(@TDateTimePickerParseInput_R, @TDateTimePickerParseInput_W, 'ParseInput');
    RegisterPropertyHelper(@TDateTimePickerOnCloseUp_R, @TDateTimePickerOnCloseUp_W, 'OnCloseUp');
    RegisterPropertyHelper(@TDateTimePickerOnChange_R, @TDateTimePickerOnChange_W, 'OnChange');
    RegisterPropertyHelper(@TDateTimePickerOnDropDown_R, @TDateTimePickerOnDropDown_W, 'OnDropDown');
    RegisterPropertyHelper(@TDateTimePickerOnUserInput_R, @TDateTimePickerOnUserInput_W, 'OnUserInput');
  end;
end;

procedure RIRegister_TMonthCalendar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TMonthCalendar) do
  begin
  end;
end;

procedure RIRegister_TCommonCalendar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCommonCalendar) do
  begin
    RegisterMethod(@TCommonCalendar.BoldDays, 'BoldDays');
  end;
end;

procedure RIRegister_TMonthCalColors(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TMonthCalColors) do
  begin
    RegisterConstructor(@TMonthCalColors.Create, 'Create');
    RegisterPropertyHelper(@TMonthCalColorsBackColor_R, @TMonthCalColorsBackColor_W, 'BackColor');
    RegisterPropertyHelper(@TMonthCalColorsTextColor_R, @TMonthCalColorsTextColor_W, 'TextColor');
    RegisterPropertyHelper(@TMonthCalColorsTitleBackColor_R, @TMonthCalColorsTitleBackColor_W, 'TitleBackColor');
    RegisterPropertyHelper(@TMonthCalColorsTitleTextColor_R, @TMonthCalColorsTitleTextColor_W, 'TitleTextColor');
    RegisterPropertyHelper(@TMonthCalColorsMonthBackColor_R, @TMonthCalColorsMonthBackColor_W, 'MonthBackColor');
    RegisterPropertyHelper(@TMonthCalColorsTrailingTextColor_R, @TMonthCalColorsTrailingTextColor_W, 'TrailingTextColor');
  end;
end;

procedure RIRegister_TCoolBar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCoolBar) do
  begin
    RegisterPropertyHelper(@TCoolBarBandBorderStyle_R, @TCoolBarBandBorderStyle_W, 'BandBorderStyle');
    RegisterPropertyHelper(@TCoolBarBandMaximize_R, @TCoolBarBandMaximize_W, 'BandMaximize');
    RegisterPropertyHelper(@TCoolBarBands_R, @TCoolBarBands_W, 'Bands');
    RegisterPropertyHelper(@TCoolBarFixedSize_R, @TCoolBarFixedSize_W, 'FixedSize');
    RegisterPropertyHelper(@TCoolBarFixedOrder_R, @TCoolBarFixedOrder_W, 'FixedOrder');
    RegisterPropertyHelper(@TCoolBarImages_R, @TCoolBarImages_W, 'Images');
    RegisterPropertyHelper(@TCoolBarBitmap_R, @TCoolBarBitmap_W, 'Bitmap');
    RegisterPropertyHelper(@TCoolBarShowText_R, @TCoolBarShowText_W, 'ShowText');
    RegisterPropertyHelper(@TCoolBarVertical_R, @TCoolBarVertical_W, 'Vertical');
    RegisterPropertyHelper(@TCoolBarOnChange_R, @TCoolBarOnChange_W, 'OnChange');
  end;
end;

procedure RIRegister_TCoolBands(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCoolBands) do
  begin
    RegisterConstructor(@TCoolBands.Create, 'Create');
    RegisterMethod(@TCoolBands.Add, 'Add');
    RegisterMethod(@TCoolBands.FindBand, 'FindBand');
    RegisterPropertyHelper(@TCoolBandsCoolBar_R, nil, 'CoolBar');
    RegisterPropertyHelper(@TCoolBandsItems_R, @TCoolBandsItems_W, 'Items');
  end;
end;

procedure RIRegister_TCoolBand(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCoolBand) do
  begin
    RegisterPropertyHelper(@TCoolBandHeight_R, nil, 'Height');
    RegisterPropertyHelper(@TCoolBandBitmap_R, @TCoolBandBitmap_W, 'Bitmap');
    RegisterPropertyHelper(@TCoolBandBorderStyle_R, @TCoolBandBorderStyle_W, 'BorderStyle');
    RegisterPropertyHelper(@TCoolBandBreak_R, @TCoolBandBreak_W, 'Break');
    RegisterPropertyHelper(@TCoolBandColor_R, @TCoolBandColor_W, 'Color');
    RegisterPropertyHelper(@TCoolBandControl_R, @TCoolBandControl_W, 'Control');
    RegisterPropertyHelper(@TCoolBandFixedBackground_R, @TCoolBandFixedBackground_W, 'FixedBackground');
    RegisterPropertyHelper(@TCoolBandFixedSize_R, @TCoolBandFixedSize_W, 'FixedSize');
    RegisterPropertyHelper(@TCoolBandHorizontalOnly_R, @TCoolBandHorizontalOnly_W, 'HorizontalOnly');
    RegisterPropertyHelper(@TCoolBandImageIndex_R, @TCoolBandImageIndex_W, 'ImageIndex');
    RegisterPropertyHelper(@TCoolBandMinHeight_R, @TCoolBandMinHeight_W, 'MinHeight');
    RegisterPropertyHelper(@TCoolBandMinWidth_R, @TCoolBandMinWidth_W, 'MinWidth');
    RegisterPropertyHelper(@TCoolBandParentColor_R, @TCoolBandParentColor_W, 'ParentColor');
    RegisterPropertyHelper(@TCoolBandParentBitmap_R, @TCoolBandParentBitmap_W, 'ParentBitmap');
    RegisterPropertyHelper(@TCoolBandText_R, @TCoolBandText_W, 'Text');
    RegisterPropertyHelper(@TCoolBandVisible_R, @TCoolBandVisible_W, 'Visible');
    RegisterPropertyHelper(@TCoolBandWidth_R, @TCoolBandWidth_W, 'Width');
  end;
end;

procedure RIRegister_TToolBar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TToolBar) do
  begin
    RegisterVirtualMethod(@TToolBar.TrackMenu, 'TrackMenu');
    RegisterPropertyHelper(@TToolBarButtonCount_R, nil, 'ButtonCount');
    RegisterPropertyHelper(@TToolBarButtons_R, nil, 'Buttons');
    RegisterPropertyHelper(@TToolBarCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@TToolBarRowCount_R, nil, 'RowCount');
    RegisterPropertyHelper(@TToolBarButtonHeight_R, @TToolBarButtonHeight_W, 'ButtonHeight');
    RegisterPropertyHelper(@TToolBarButtonWidth_R, @TToolBarButtonWidth_W, 'ButtonWidth');
    RegisterPropertyHelper(@TToolBarDisabledImages_R, @TToolBarDisabledImages_W, 'DisabledImages');
    RegisterPropertyHelper(@TToolBarFlat_R, @TToolBarFlat_W, 'Flat');
    RegisterPropertyHelper(@TToolBarHotImages_R, @TToolBarHotImages_W, 'HotImages');
    RegisterPropertyHelper(@TToolBarImages_R, @TToolBarImages_W, 'Images');
    RegisterPropertyHelper(@TToolBarIndent_R, @TToolBarIndent_W, 'Indent');
    RegisterPropertyHelper(@TToolBarList_R, @TToolBarList_W, 'List');
    RegisterPropertyHelper(@TToolBarShowCaptions_R, @TToolBarShowCaptions_W, 'ShowCaptions');
    RegisterPropertyHelper(@TToolBarTransparent_R, @TToolBarTransparent_W, 'Transparent');
    RegisterPropertyHelper(@TToolBarWrapable_R, @TToolBarWrapable_W, 'Wrapable');
    RegisterPropertyHelper(@TToolBarOnAdvancedCustomDraw_R, @TToolBarOnAdvancedCustomDraw_W, 'OnAdvancedCustomDraw');
    RegisterPropertyHelper(@TToolBarOnAdvancedCustomDrawButton_R, @TToolBarOnAdvancedCustomDrawButton_W, 'OnAdvancedCustomDrawButton');
    RegisterPropertyHelper(@TToolBarOnCustomDraw_R, @TToolBarOnCustomDraw_W, 'OnCustomDraw');
    RegisterPropertyHelper(@TToolBarOnCustomDrawButton_R, @TToolBarOnCustomDrawButton_W, 'OnCustomDrawButton');
  end;
end;

procedure RIRegister_TToolButton(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TToolButton) do
  begin
    RegisterVirtualMethod(@TToolButton.CheckMenuDropdown, 'CheckMenuDropdown');
    RegisterPropertyHelper(@TToolButtonIndex_R, nil, 'Index');
    RegisterPropertyHelper(@TToolButtonAllowAllUp_R, @TToolButtonAllowAllUp_W, 'AllowAllUp');
    RegisterPropertyHelper(@TToolButtonAutoSize_R, @TToolButtonAutoSize_W, 'AutoSize');
    RegisterPropertyHelper(@TToolButtonDown_R, @TToolButtonDown_W, 'Down');
    RegisterPropertyHelper(@TToolButtonDropdownMenu_R, @TToolButtonDropdownMenu_W, 'DropdownMenu');
    RegisterPropertyHelper(@TToolButtonGrouped_R, @TToolButtonGrouped_W, 'Grouped');
    RegisterPropertyHelper(@TToolButtonImageIndex_R, @TToolButtonImageIndex_W, 'ImageIndex');
    RegisterPropertyHelper(@TToolButtonIndeterminate_R, @TToolButtonIndeterminate_W, 'Indeterminate');
    RegisterPropertyHelper(@TToolButtonMarked_R, @TToolButtonMarked_W, 'Marked');
    RegisterPropertyHelper(@TToolButtonMenuItem_R, @TToolButtonMenuItem_W, 'MenuItem');
    RegisterPropertyHelper(@TToolButtonWrap_R, @TToolButtonWrap_W, 'Wrap');
    RegisterPropertyHelper(@TToolButtonStyle_R, @TToolButtonStyle_W, 'Style');
  end;
end;

procedure RIRegister_TAnimate(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TAnimate) do
  begin
    RegisterPropertyHelper(@TAnimateFrameCount_R, nil, 'FrameCount');
    RegisterPropertyHelper(@TAnimateFrameHeight_R, nil, 'FrameHeight');
    RegisterPropertyHelper(@TAnimateFrameWidth_R, nil, 'FrameWidth');
    RegisterPropertyHelper(@TAnimateOpen_R, @TAnimateOpen_W, 'Open');
    RegisterMethod(@TAnimate.Play, 'Play');
    RegisterMethod(@TAnimate.Reset, 'Reset');
    RegisterMethod(@TAnimate.Seek, 'Seek');
    RegisterMethod(@TAnimate.Stop, 'Stop');
    RegisterPropertyHelper(@TAnimateResHandle_R, @TAnimateResHandle_W, 'ResHandle');
    RegisterPropertyHelper(@TAnimateResId_R, @TAnimateResId_W, 'ResId');
    RegisterPropertyHelper(@TAnimateResName_R, @TAnimateResName_W, 'ResName');
    RegisterPropertyHelper(@TAnimateActive_R, @TAnimateActive_W, 'Active');
    RegisterPropertyHelper(@TAnimateCenter_R, @TAnimateCenter_W, 'Center');
    RegisterPropertyHelper(@TAnimateCommonAVI_R, @TAnimateCommonAVI_W, 'CommonAVI');
    RegisterPropertyHelper(@TAnimateFileName_R, @TAnimateFileName_W, 'FileName');
    RegisterPropertyHelper(@TAnimateRepetitions_R, @TAnimateRepetitions_W, 'Repetitions');
    RegisterPropertyHelper(@TAnimateStartFrame_R, @TAnimateStartFrame_W, 'StartFrame');
    RegisterPropertyHelper(@TAnimateStopFrame_R, @TAnimateStopFrame_W, 'StopFrame');
    RegisterPropertyHelper(@TAnimateTimers_R, @TAnimateTimers_W, 'Timers');
    RegisterPropertyHelper(@TAnimateTransparent_R, @TAnimateTransparent_W, 'Transparent');
    RegisterPropertyHelper(@TAnimateOnOpen_R, @TAnimateOnOpen_W, 'OnOpen');
    RegisterPropertyHelper(@TAnimateOnClose_R, @TAnimateOnClose_W, 'OnClose');
    RegisterPropertyHelper(@TAnimateOnStart_R, @TAnimateOnStart_W, 'OnStart');
    RegisterPropertyHelper(@TAnimateOnStop_R, @TAnimateOnStop_W, 'OnStop');
  end;
end;

procedure RIRegister_TListView(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TListView) do
  begin
  end;
end;

procedure RIRegister_TCustomListView(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomListView) do
  begin
    RegisterMethod(@TCustomListView.AlphaSort, 'AlphaSort');
    RegisterMethod(@TCustomListView.Arrange, 'Arrange');
    RegisterMethod(@TCustomListView.FindCaption, 'FindCaption');
    RegisterMethod(@TCustomListView.FindData, 'FindData');
    RegisterMethod(@TCustomListView.GetHitTestInfoAt, 'GetHitTestInfoAt');
    RegisterMethod(@TCustomListView.GetItemAt, 'GetItemAt');
    RegisterMethod(@TCustomListView.GetNearestItem, 'GetNearestItem');
    RegisterMethod(@TCustomListView.GetNextItem, 'GetNextItem');
    RegisterMethod(@TCustomListView.GetSearchString, 'GetSearchString');
    RegisterMethod(@TCustomListView.IsEditing, 'IsEditing');
    RegisterMethod(@TCustomListView.Scroll, 'Scroll');
    RegisterPropertyHelper(@TCustomListViewCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@TCustomListViewCheckboxes_R, @TCustomListViewCheckboxes_W, 'Checkboxes');
    RegisterPropertyHelper(@TCustomListViewColumn_R, nil, 'Column');
    RegisterPropertyHelper(@TCustomListViewDropTarget_R, @TCustomListViewDropTarget_W, 'DropTarget');
    RegisterPropertyHelper(@TCustomListViewFlatScrollBars_R, @TCustomListViewFlatScrollBars_W, 'FlatScrollBars');
    RegisterPropertyHelper(@TCustomListViewFullDrag_R, @TCustomListViewFullDrag_W, 'FullDrag');
    RegisterPropertyHelper(@TCustomListViewGridLines_R, @TCustomListViewGridLines_W, 'GridLines');
    RegisterPropertyHelper(@TCustomListViewHotTrack_R, @TCustomListViewHotTrack_W, 'HotTrack');
    RegisterPropertyHelper(@TCustomListViewHotTrackStyles_R, @TCustomListViewHotTrackStyles_W, 'HotTrackStyles');
    RegisterPropertyHelper(@TCustomListViewItemFocused_R, @TCustomListViewItemFocused_W, 'ItemFocused');
    RegisterPropertyHelper(@TCustomListViewRowSelect_R, @TCustomListViewRowSelect_W, 'RowSelect');
    RegisterPropertyHelper(@TCustomListViewSelCount_R, nil, 'SelCount');
    RegisterPropertyHelper(@TCustomListViewSelected_R, @TCustomListViewSelected_W, 'Selected');
    RegisterMethod(@TCustomListView.CustomSort, 'CustomSort');
    RegisterMethod(@TCustomListView.StringWidth, 'StringWidth');
    RegisterMethod(@TCustomListView.UpdateItems, 'UpdateItems');
    RegisterPropertyHelper(@TCustomListViewTopItem_R, nil, 'TopItem');
    RegisterPropertyHelper(@TCustomListViewViewOrigin_R, nil, 'ViewOrigin');
    RegisterPropertyHelper(@TCustomListViewVisibleRowCount_R, nil, 'VisibleRowCount');
    RegisterPropertyHelper(@TCustomListViewBoundingRect_R, nil, 'BoundingRect');
    RegisterPropertyHelper(@TCustomListViewWorkAreas_R, nil, 'WorkAreas');
  end;
end;

procedure RIRegister_TIconOptions(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TIconOptions) do
  begin
    RegisterConstructor(@TIconOptions.Create, 'Create');
    RegisterPropertyHelper(@TIconOptionsArrangement_R, @TIconOptionsArrangement_W, 'Arrangement');
    RegisterPropertyHelper(@TIconOptionsAutoArrange_R, @TIconOptionsAutoArrange_W, 'AutoArrange');
    RegisterPropertyHelper(@TIconOptionsWrapText_R, @TIconOptionsWrapText_W, 'WrapText');
  end;
end;

procedure RIRegister_TWorkAreas(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TWorkAreas) do
  begin
    RegisterMethod(@TWorkAreas.Add, 'Add');
    RegisterMethod(@TWorkAreas.Delete, 'Delete');
    RegisterMethod(@TWorkAreas.Insert, 'Insert');
    RegisterPropertyHelper(@TWorkAreasItems_R, @TWorkAreasItems_W, 'Items');
  end;
end;

procedure RIRegister_TWorkArea(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TWorkArea) do
  begin
    RegisterPropertyHelper(@TWorkAreaRect_R, @TWorkAreaRect_W, 'Rect');
    RegisterPropertyHelper(@TWorkAreaColor_R, @TWorkAreaColor_W, 'Color');
  end;
end;

procedure RIRegister_TListItems(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TListItems) do
  begin
    RegisterConstructor(@TListItems.Create, 'Create');
    RegisterMethod(@TListItems.Add, 'Add');
    RegisterMethod(@TListItems.BeginUpdate, 'BeginUpdate');
    RegisterMethod(@TListItems.Clear, 'Clear');
    RegisterMethod(@TListItems.Delete, 'Delete');
    RegisterMethod(@TListItems.EndUpdate, 'EndUpdate');
    RegisterMethod(@TListItems.IndexOf, 'IndexOf');
    RegisterMethod(@TListItems.Insert, 'Insert');
    RegisterPropertyHelper(@TListItemsCount_R, @TListItemsCount_W, 'Count');
    RegisterPropertyHelper(@TListItemsHandle_R, nil, 'Handle');
    RegisterPropertyHelper(@TListItemsItem_R, @TListItemsItem_W, 'Item');
    RegisterPropertyHelper(@TListItemsOwner_R, nil, 'Owner');
  end;
end;

procedure RIRegister_TListItem(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TListItem) do
  begin
    RegisterConstructor(@TListItem.Create, 'Create');
    RegisterMethod(@TListItem.CancelEdit, 'CancelEdit');
    RegisterMethod(@TListItem.Delete, 'Delete');
    RegisterMethod(@TListItem.DisplayRect, 'DisplayRect');
    RegisterMethod(@TListItem.EditCaption, 'EditCaption');
    RegisterMethod(@TListItem.GetPosition, 'GetPosition');
    RegisterMethod(@TListItem.MakeVisible, 'MakeVisible');
    RegisterMethod(@TListItem.Update, 'Update');
    RegisterMethod(@TListItem.SetPosition, 'SetPosition');
    RegisterMethod(@TListItem.WorkArea, 'WorkArea');
    RegisterPropertyHelper(@TListItemCaption_R, @TListItemCaption_W, 'Caption');
    RegisterPropertyHelper(@TListItemChecked_R, @TListItemChecked_W, 'Checked');
    RegisterPropertyHelper(@TListItemCut_R, @TListItemCut_W, 'Cut');
    RegisterPropertyHelper(@TListItemData_R, @TListItemData_W, 'Data');
    RegisterPropertyHelper(@TListItemDropTarget_R, @TListItemDropTarget_W, 'DropTarget');
    RegisterPropertyHelper(@TListItemFocused_R, @TListItemFocused_W, 'Focused');
    RegisterPropertyHelper(@TListItemHandle_R, nil, 'Handle');
    RegisterPropertyHelper(@TListItemImageIndex_R, @TListItemImageIndex_W, 'ImageIndex');
    RegisterPropertyHelper(@TListItemIndent_R, @TListItemIndent_W, 'Indent');
    RegisterPropertyHelper(@TListItemIndex_R, nil, 'Index');
    RegisterPropertyHelper(@TListItemLeft_R, @TListItemLeft_W, 'Left');
    RegisterPropertyHelper(@TListItemListView_R, nil, 'ListView');
    RegisterPropertyHelper(@TListItemOwner_R, nil, 'Owner');
    RegisterPropertyHelper(@TListItemOverlayIndex_R, @TListItemOverlayIndex_W, 'OverlayIndex');
    RegisterPropertyHelper(@TListItemPosition_R, @TListItemPosition_W, 'Position');
    RegisterPropertyHelper(@TListItemSelected_R, @TListItemSelected_W, 'Selected');
    RegisterPropertyHelper(@TListItemStateIndex_R, @TListItemStateIndex_W, 'StateIndex');
    RegisterPropertyHelper(@TListItemSubItems_R, @TListItemSubItems_W, 'SubItems');
    RegisterPropertyHelper(@TListItemSubItemImages_R, @TListItemSubItemImages_W, 'SubItemImages');
    RegisterPropertyHelper(@TListItemTop_R, @TListItemTop_W, 'Top');
  end;
end;

procedure RIRegister_TListColumns(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TListColumns) do
  begin
    RegisterConstructor(@TListColumns.Create, 'Create');
    RegisterMethod(@TListColumns.Add, 'Add');
    RegisterPropertyHelper(@TListColumnsOwner_R, nil, 'Owner');
    RegisterPropertyHelper(@TListColumnsItems_R, @TListColumnsItems_W, 'Items');
  end;
end;

procedure RIRegister_TListColumn(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TListColumn) do
  begin
    RegisterPropertyHelper(@TListColumnWidthType_R, nil, 'WidthType');
    RegisterPropertyHelper(@TListColumnAlignment_R, @TListColumnAlignment_W, 'Alignment');
    RegisterPropertyHelper(@TListColumnAutoSize_R, @TListColumnAutoSize_W, 'AutoSize');
    RegisterPropertyHelper(@TListColumnCaption_R, @TListColumnCaption_W, 'Caption');
    RegisterPropertyHelper(@TListColumnImageIndex_R, @TListColumnImageIndex_W, 'ImageIndex');
    RegisterPropertyHelper(@TListColumnMaxWidth_R, @TListColumnMaxWidth_W, 'MaxWidth');
    RegisterPropertyHelper(@TListColumnMinWidth_R, @TListColumnMinWidth_W, 'MinWidth');
    RegisterPropertyHelper(@TListColumnTag_R, @TListColumnTag_W, 'Tag');
    RegisterPropertyHelper(@TListColumnWidth_R, @TListColumnWidth_W, 'Width');
  end;
end;

procedure RIRegister_THotKey(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(THotKey) do
  begin
  end;
end;

procedure RIRegister_TCustomHotKey(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomHotKey) do
  begin
  end;
end;

procedure RIRegister_TUpDown(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TUpDown) do
  begin
  end;
end;

procedure RIRegister_TCustomUpDown(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomUpDown) do
  begin
  end;
end;

procedure RIRegister_TRichEdit(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TRichEdit) do
  begin
  end;
end;

procedure RIRegister_TCustomRichEdit(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomRichEdit) do
  begin
    RegisterMethod(@TCustomRichEdit.FindText, 'FindText');
    RegisterVirtualMethod(@TCustomRichEdit.Print, 'Print');
    RegisterMethod(@TCustomRichEdit.RegisterConversionFormat, 'RegisterConversionFormat');
    RegisterPropertyHelper(@TCustomRichEditDefaultConverter_R, @TCustomRichEditDefaultConverter_W, 'DefaultConverter');
    RegisterPropertyHelper(@TCustomRichEditDefAttributes_R, @TCustomRichEditDefAttributes_W, 'DefAttributes');
    RegisterPropertyHelper(@TCustomRichEditSelAttributes_R, @TCustomRichEditSelAttributes_W, 'SelAttributes');
    RegisterPropertyHelper(@TCustomRichEditPageRect_R, @TCustomRichEditPageRect_W, 'PageRect');
    RegisterPropertyHelper(@TCustomRichEditParagraph_R, nil, 'Paragraph');
  end;
end;

procedure RIRegister_TConversion(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TConversion) do
  begin
    RegisterVirtualMethod(@TConversion.ConvertReadStream, 'ConvertReadStream');
    RegisterVirtualMethod(@TConversion.ConvertWriteStream, 'ConvertWriteStream');
  end;
end;

procedure RIRegister_TParaAttributes(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TParaAttributes) do
  begin
    RegisterConstructor(@TParaAttributes.Create, 'Create');
    RegisterPropertyHelper(@TParaAttributesAlignment_R, @TParaAttributesAlignment_W, 'Alignment');
    RegisterPropertyHelper(@TParaAttributesFirstIndent_R, @TParaAttributesFirstIndent_W, 'FirstIndent');
    RegisterPropertyHelper(@TParaAttributesLeftIndent_R, @TParaAttributesLeftIndent_W, 'LeftIndent');
    RegisterPropertyHelper(@TParaAttributesNumbering_R, @TParaAttributesNumbering_W, 'Numbering');
    RegisterPropertyHelper(@TParaAttributesRightIndent_R, @TParaAttributesRightIndent_W, 'RightIndent');
    RegisterPropertyHelper(@TParaAttributesTab_R, @TParaAttributesTab_W, 'Tab');
    RegisterPropertyHelper(@TParaAttributesTabCount_R, @TParaAttributesTabCount_W, 'TabCount');
  end;
end;

procedure RIRegister_TTextAttributes(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TTextAttributes) do
  begin
    RegisterConstructor(@TTextAttributes.Create, 'Create');
    RegisterPropertyHelper(@TTextAttributesCharset_R, @TTextAttributesCharset_W, 'Charset');
    RegisterPropertyHelper(@TTextAttributesColor_R, @TTextAttributesColor_W, 'Color');
    RegisterPropertyHelper(@TTextAttributesConsistentAttributes_R, nil, 'ConsistentAttributes');
    RegisterPropertyHelper(@TTextAttributesName_R, @TTextAttributesName_W, 'Name');
    RegisterPropertyHelper(@TTextAttributesPitch_R, @TTextAttributesPitch_W, 'Pitch');
    RegisterPropertyHelper(@TTextAttributesSize_R, @TTextAttributesSize_W, 'Size');
    RegisterPropertyHelper(@TTextAttributesStyle_R, @TTextAttributesStyle_W, 'Style');
    RegisterPropertyHelper(@TTextAttributesHeight_R, @TTextAttributesHeight_W, 'Height');
  end;
end;

procedure RIRegister_TProgressBar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TProgressBar) do
  begin
    RegisterMethod(@TProgressBar.StepIt, 'StepIt');
    RegisterMethod(@TProgressBar.StepBy, 'StepBy');
    RegisterPropertyHelper(@TProgressBarMin_R, @TProgressBarMin_W, 'Min');
    RegisterPropertyHelper(@TProgressBarMax_R, @TProgressBarMax_W, 'Max');
    RegisterPropertyHelper(@TProgressBarOrientation_R, @TProgressBarOrientation_W, 'Orientation');
    RegisterPropertyHelper(@TProgressBarPosition_R, @TProgressBarPosition_W, 'Position');
    RegisterPropertyHelper(@TProgressBarSmooth_R, @TProgressBarSmooth_W, 'Smooth');
    RegisterPropertyHelper(@TProgressBarStep_R, @TProgressBarStep_W, 'Step');
  end;
end;

procedure RIRegister_TTrackBar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TTrackBar) do
  begin
    RegisterMethod(@TTrackBar.SetTick, 'SetTick');
    RegisterPropertyHelper(@TTrackBarLineSize_R, @TTrackBarLineSize_W, 'LineSize');
    RegisterPropertyHelper(@TTrackBarMax_R, @TTrackBarMax_W, 'Max');
    RegisterPropertyHelper(@TTrackBarMin_R, @TTrackBarMin_W, 'Min');
    RegisterPropertyHelper(@TTrackBarOrientation_R, @TTrackBarOrientation_W, 'Orientation');
    RegisterPropertyHelper(@TTrackBarPageSize_R, @TTrackBarPageSize_W, 'PageSize');
    RegisterPropertyHelper(@TTrackBarFrequency_R, @TTrackBarFrequency_W, 'Frequency');
    RegisterPropertyHelper(@TTrackBarPosition_R, @TTrackBarPosition_W, 'Position');
    RegisterPropertyHelper(@TTrackBarSliderVisible_R, @TTrackBarSliderVisible_W, 'SliderVisible');
    RegisterPropertyHelper(@TTrackBarSelEnd_R, @TTrackBarSelEnd_W, 'SelEnd');
    RegisterPropertyHelper(@TTrackBarSelStart_R, @TTrackBarSelStart_W, 'SelStart');
    RegisterPropertyHelper(@TTrackBarThumbLength_R, @TTrackBarThumbLength_W, 'ThumbLength');
    RegisterPropertyHelper(@TTrackBarTickMarks_R, @TTrackBarTickMarks_W, 'TickMarks');
    RegisterPropertyHelper(@TTrackBarTickStyle_R, @TTrackBarTickStyle_W, 'TickStyle');
    RegisterPropertyHelper(@TTrackBarOnChange_R, @TTrackBarOnChange_W, 'OnChange');
  end;
end;

procedure RIRegister_TTreeView(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TTreeView) do
  begin
  end;
end;

procedure RIRegister_TCustomTreeView(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomTreeView) do
  begin
    RegisterMethod(@TCustomTreeView.AlphaSort, 'AlphaSort');
    RegisterMethod(@TCustomTreeView.CustomSort, 'CustomSort');
    RegisterMethod(@TCustomTreeView.FullCollapse, 'FullCollapse');
    RegisterMethod(@TCustomTreeView.FullExpand, 'FullExpand');
    RegisterMethod(@TCustomTreeView.GetHitTestInfoAt, 'GetHitTestInfoAt');
    RegisterMethod(@TCustomTreeView.GetNodeAt, 'GetNodeAt');
    RegisterMethod(@TCustomTreeView.IsEditing, 'IsEditing');
    RegisterMethod(@TCustomTreeView.LoadFromFile, 'LoadFromFile');
    RegisterMethod(@TCustomTreeView.LoadFromStream, 'LoadFromStream');
    RegisterMethod(@TCustomTreeView.SaveToFile, 'SaveToFile');
    RegisterMethod(@TCustomTreeView.SaveToStream, 'SaveToStream');
    RegisterPropertyHelper(@TCustomTreeViewCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@TCustomTreeViewDropTarget_R, @TCustomTreeViewDropTarget_W, 'DropTarget');
    RegisterPropertyHelper(@TCustomTreeViewSelected_R, @TCustomTreeViewSelected_W, 'Selected');
    RegisterPropertyHelper(@TCustomTreeViewTopItem_R, @TCustomTreeViewTopItem_W, 'TopItem');
  end;
end;

procedure RIRegister_TTreeNodes(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TTreeNodes) do
  begin
    RegisterConstructor(@TTreeNodes.Create, 'Create');
    RegisterMethod(@TTreeNodes.AddChildFirst, 'AddChildFirst');
    RegisterMethod(@TTreeNodes.AddChild, 'AddChild');
    RegisterMethod(@TTreeNodes.AddChildObjectFirst, 'AddChildObjectFirst');
    RegisterMethod(@TTreeNodes.AddChildObject, 'AddChildObject');
    RegisterMethod(@TTreeNodes.AddFirst, 'AddFirst');
    RegisterMethod(@TTreeNodes.Add, 'Add');
    RegisterMethod(@TTreeNodes.AddObjectFirst, 'AddObjectFirst');
    RegisterMethod(@TTreeNodes.AddObject, 'AddObject');
    RegisterMethod(@TTreeNodes.BeginUpdate, 'BeginUpdate');
    RegisterMethod(@TTreeNodes.Clear, 'Clear');
    RegisterMethod(@TTreeNodes.Delete, 'Delete');
    RegisterMethod(@TTreeNodes.EndUpdate, 'EndUpdate');
    RegisterMethod(@TTreeNodes.GetFirstNode, 'GetFirstNode');
    RegisterMethod(@TTreeNodes.GetNode, 'GetNode');
    RegisterMethod(@TTreeNodes.Insert, 'Insert');
    RegisterMethod(@TTreeNodes.InsertObject, 'InsertObject');
    RegisterPropertyHelper(@TTreeNodesCount_R, nil, 'Count');
    RegisterPropertyHelper(@TTreeNodesHandle_R, nil, 'Handle');
    RegisterPropertyHelper(@TTreeNodesItem_R, nil, 'Item');
    RegisterPropertyHelper(@TTreeNodesOwner_R, nil, 'Owner');
  end;
end;

procedure RIRegister_TTreeNode(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TTreeNode) do
  begin
    RegisterConstructor(@TTreeNode.Create, 'Create');
    RegisterMethod(@TTreeNode.AlphaSort, 'AlphaSort');
    RegisterMethod(@TTreeNode.Collapse, 'Collapse');
    RegisterMethod(@TTreeNode.CustomSort, 'CustomSort');
    RegisterMethod(@TTreeNode.Delete, 'Delete');
    RegisterMethod(@TTreeNode.DeleteChildren, 'DeleteChildren');
    RegisterMethod(@TTreeNode.DisplayRect, 'DisplayRect');
    RegisterMethod(@TTreeNode.EditText, 'EditText');
    RegisterMethod(@TTreeNode.EndEdit, 'EndEdit');
    RegisterMethod(@TTreeNode.Expand, 'Expand');
    RegisterMethod(@TTreeNode.getFirstChild, 'getFirstChild');
    RegisterMethod(@TTreeNode.GetHandle, 'GetHandle');
    RegisterMethod(@TTreeNode.GetLastChild, 'GetLastChild');
    RegisterMethod(@TTreeNode.GetNext, 'GetNext');
    RegisterMethod(@TTreeNode.GetNextChild, 'GetNextChild');
    RegisterMethod(@TTreeNode.getNextSibling, 'getNextSibling');
    RegisterMethod(@TTreeNode.GetNextVisible, 'GetNextVisible');
    RegisterMethod(@TTreeNode.GetPrev, 'GetPrev');
    RegisterMethod(@TTreeNode.GetPrevChild, 'GetPrevChild');
    RegisterMethod(@TTreeNode.getPrevSibling, 'getPrevSibling');
    RegisterMethod(@TTreeNode.GetPrevVisible, 'GetPrevVisible');
    RegisterMethod(@TTreeNode.HasAsParent, 'HasAsParent');
    RegisterMethod(@TTreeNode.IndexOf, 'IndexOf');
    RegisterMethod(@TTreeNode.MakeVisible, 'MakeVisible');
    RegisterVirtualMethod(@TTreeNode.MoveTo, 'MoveTo');
    RegisterPropertyHelper(@TTreeNodeAbsoluteIndex_R, nil, 'AbsoluteIndex');
    RegisterPropertyHelper(@TTreeNodeCount_R, nil, 'Count');
    RegisterPropertyHelper(@TTreeNodeCut_R, @TTreeNodeCut_W, 'Cut');
    RegisterPropertyHelper(@TTreeNodeData_R, @TTreeNodeData_W, 'Data');
    RegisterPropertyHelper(@TTreeNodeDeleting_R, nil, 'Deleting');
    RegisterPropertyHelper(@TTreeNodeFocused_R, @TTreeNodeFocused_W, 'Focused');
    RegisterPropertyHelper(@TTreeNodeDropTarget_R, @TTreeNodeDropTarget_W, 'DropTarget');
    RegisterPropertyHelper(@TTreeNodeSelected_R, @TTreeNodeSelected_W, 'Selected');
    RegisterPropertyHelper(@TTreeNodeExpanded_R, @TTreeNodeExpanded_W, 'Expanded');
    RegisterPropertyHelper(@TTreeNodeHandle_R, nil, 'Handle');
    RegisterPropertyHelper(@TTreeNodeHasChildren_R, @TTreeNodeHasChildren_W, 'HasChildren');
    RegisterPropertyHelper(@TTreeNodeImageIndex_R, @TTreeNodeImageIndex_W, 'ImageIndex');
    RegisterPropertyHelper(@TTreeNodeIndex_R, nil, 'Index');
    RegisterPropertyHelper(@TTreeNodeIsVisible_R, nil, 'IsVisible');
    RegisterPropertyHelper(@TTreeNodeItem_R, @TTreeNodeItem_W, 'Item');
    RegisterPropertyHelper(@TTreeNodeItemId_R, nil, 'ItemId');
    RegisterPropertyHelper(@TTreeNodeLevel_R, nil, 'Level');
    RegisterPropertyHelper(@TTreeNodeOverlayIndex_R, @TTreeNodeOverlayIndex_W, 'OverlayIndex');
    RegisterPropertyHelper(@TTreeNodeOwner_R, nil, 'Owner');
    RegisterPropertyHelper(@TTreeNodeParent_R, nil, 'Parent');
    RegisterPropertyHelper(@TTreeNodeSelectedIndex_R, @TTreeNodeSelectedIndex_W, 'SelectedIndex');
    RegisterPropertyHelper(@TTreeNodeStateIndex_R, @TTreeNodeStateIndex_W, 'StateIndex');
    RegisterPropertyHelper(@TTreeNodeText_R, @TTreeNodeText_W, 'Text');
    RegisterPropertyHelper(@TTreeNodeTreeView_R, nil, 'TreeView');
  end;
end;

procedure RIRegister_THeaderControl(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(THeaderControl) do
  begin
    RegisterPropertyHelper(@THeaderControlCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@THeaderControlDragReorder_R, @THeaderControlDragReorder_W, 'DragReorder');
    RegisterPropertyHelper(@THeaderControlFullDrag_R, @THeaderControlFullDrag_W, 'FullDrag');
    RegisterPropertyHelper(@THeaderControlHotTrack_R, @THeaderControlHotTrack_W, 'HotTrack');
    RegisterPropertyHelper(@THeaderControlImages_R, @THeaderControlImages_W, 'Images');
    RegisterPropertyHelper(@THeaderControlSections_R, @THeaderControlSections_W, 'Sections');
    RegisterPropertyHelper(@THeaderControlStyle_R, @THeaderControlStyle_W, 'Style');
    RegisterPropertyHelper(@THeaderControlOnDrawSection_R, @THeaderControlOnDrawSection_W, 'OnDrawSection');
    RegisterPropertyHelper(@THeaderControlOnSectionClick_R, @THeaderControlOnSectionClick_W, 'OnSectionClick');
    RegisterPropertyHelper(@THeaderControlOnSectionDrag_R, @THeaderControlOnSectionDrag_W, 'OnSectionDrag');
    RegisterPropertyHelper(@THeaderControlOnSectionEndDrag_R, @THeaderControlOnSectionEndDrag_W, 'OnSectionEndDrag');
    RegisterPropertyHelper(@THeaderControlOnSectionResize_R, @THeaderControlOnSectionResize_W, 'OnSectionResize');
    RegisterPropertyHelper(@THeaderControlOnSectionTrack_R, @THeaderControlOnSectionTrack_W, 'OnSectionTrack');
  end;
end;

procedure RIRegister_THeaderSections(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(THeaderSections) do
  begin
    RegisterConstructor(@THeaderSections.Create, 'Create');
    RegisterMethod(@THeaderSections.Add, 'Add');
    RegisterPropertyHelper(@THeaderSectionsItems_R, @THeaderSectionsItems_W, 'Items');
  end;
end;

procedure RIRegister_THeaderSection(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(THeaderSection) do
  begin
    RegisterMethod(@THeaderSection.ParentBiDiModeChanged, 'ParentBiDiModeChanged');
    RegisterMethod(@THeaderSection.UseRightToLeftAlignment, 'UseRightToLeftAlignment');
    RegisterMethod(@THeaderSection.UseRightToLeftReading, 'UseRightToLeftReading');
    RegisterPropertyHelper(@THeaderSectionLeft_R, nil, 'Left');
    RegisterPropertyHelper(@THeaderSectionRight_R, nil, 'Right');
    RegisterPropertyHelper(@THeaderSectionAlignment_R, @THeaderSectionAlignment_W, 'Alignment');
    RegisterPropertyHelper(@THeaderSectionAllowClick_R, @THeaderSectionAllowClick_W, 'AllowClick');
    RegisterPropertyHelper(@THeaderSectionAutoSize_R, @THeaderSectionAutoSize_W, 'AutoSize');
    RegisterPropertyHelper(@THeaderSectionBiDiMode_R, @THeaderSectionBiDiMode_W, 'BiDiMode');
    RegisterPropertyHelper(@THeaderSectionImageIndex_R, @THeaderSectionImageIndex_W, 'ImageIndex');
    RegisterPropertyHelper(@THeaderSectionMaxWidth_R, @THeaderSectionMaxWidth_W, 'MaxWidth');
    RegisterPropertyHelper(@THeaderSectionMinWidth_R, @THeaderSectionMinWidth_W, 'MinWidth');
    RegisterPropertyHelper(@THeaderSectionParentBiDiMode_R, @THeaderSectionParentBiDiMode_W, 'ParentBiDiMode');
    RegisterPropertyHelper(@THeaderSectionStyle_R, @THeaderSectionStyle_W, 'Style');
    RegisterPropertyHelper(@THeaderSectionText_R, @THeaderSectionText_W, 'Text');
    RegisterPropertyHelper(@THeaderSectionWidth_R, @THeaderSectionWidth_W, 'Width');
  end;
end;

procedure RIRegister_TStatusBar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TStatusBar) do
  begin
    RegisterPropertyHelper(@TStatusBarCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@TStatusBarAutoHint_R, @TStatusBarAutoHint_W, 'AutoHint');
    RegisterPropertyHelper(@TStatusBarPanels_R, @TStatusBarPanels_W, 'Panels');
    RegisterPropertyHelper(@TStatusBarSimplePanel_R, @TStatusBarSimplePanel_W, 'SimplePanel');
    RegisterPropertyHelper(@TStatusBarSimpleText_R, @TStatusBarSimpleText_W, 'SimpleText');
    RegisterPropertyHelper(@TStatusBarSizeGrip_R, @TStatusBarSizeGrip_W, 'SizeGrip');
    RegisterPropertyHelper(@TStatusBarUseSystemFont_R, @TStatusBarUseSystemFont_W, 'UseSystemFont');
    RegisterPropertyHelper(@TStatusBarOnHint_R, @TStatusBarOnHint_W, 'OnHint');
    RegisterPropertyHelper(@TStatusBarOnDrawPanel_R, @TStatusBarOnDrawPanel_W, 'OnDrawPanel');
  end;
end;

procedure RIRegister_TStatusPanels(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TStatusPanels) do
  begin
    RegisterConstructor(@TStatusPanels.Create, 'Create');
    RegisterMethod(@TStatusPanels.Add, 'Add');
    RegisterPropertyHelper(@TStatusPanelsItems_R, @TStatusPanelsItems_W, 'Items');
  end;
end;

procedure RIRegister_TStatusPanel(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TStatusPanel) do
  begin
    RegisterMethod(@TStatusPanel.ParentBiDiModeChanged, 'ParentBiDiModeChanged');
    RegisterMethod(@TStatusPanel.UseRightToLeftAlignment, 'UseRightToLeftAlignment');
    RegisterMethod(@TStatusPanel.UseRightToLeftReading, 'UseRightToLeftReading');
    RegisterPropertyHelper(@TStatusPanelAlignment_R, @TStatusPanelAlignment_W, 'Alignment');
    RegisterPropertyHelper(@TStatusPanelBevel_R, @TStatusPanelBevel_W, 'Bevel');
    RegisterPropertyHelper(@TStatusPanelBiDiMode_R, @TStatusPanelBiDiMode_W, 'BiDiMode');
    RegisterPropertyHelper(@TStatusPanelParentBiDiMode_R, @TStatusPanelParentBiDiMode_W, 'ParentBiDiMode');
    RegisterPropertyHelper(@TStatusPanelStyle_R, @TStatusPanelStyle_W, 'Style');
    RegisterPropertyHelper(@TStatusPanelText_R, @TStatusPanelText_W, 'Text');
    RegisterPropertyHelper(@TStatusPanelWidth_R, @TStatusPanelWidth_W, 'Width');
  end;
end;

procedure RIRegister_TPageControl(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TPageControl) do
  begin
    RegisterMethod(@TPageControl.FindNextPage, 'FindNextPage');
    RegisterMethod(@TPageControl.SelectNextPage, 'SelectNextPage');
    RegisterPropertyHelper(@TPageControlActivePageIndex_R, @TPageControlActivePageIndex_W, 'ActivePageIndex');
    RegisterPropertyHelper(@TPageControlPageCount_R, nil, 'PageCount');
    RegisterPropertyHelper(@TPageControlPages_R, nil, 'Pages');
    RegisterPropertyHelper(@TPageControlActivePage_R, @TPageControlActivePage_W, 'ActivePage');
  end;
end;

procedure RIRegister_TTabSheet(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TTabSheet) do
  begin
    RegisterPropertyHelper(@TTabSheetPageControl_R, @TTabSheetPageControl_W, 'PageControl');
    RegisterPropertyHelper(@TTabSheetTabIndex_R, nil, 'TabIndex');
    RegisterPropertyHelper(@TTabSheetHighlighted_R, @TTabSheetHighlighted_W, 'Highlighted');
    RegisterPropertyHelper(@TTabSheetImageIndex_R, @TTabSheetImageIndex_W, 'ImageIndex');
    RegisterPropertyHelper(@TTabSheetPageIndex_R, @TTabSheetPageIndex_W, 'PageIndex');
    RegisterPropertyHelper(@TTabSheetTabVisible_R, @TTabSheetTabVisible_W, 'TabVisible');
    RegisterPropertyHelper(@TTabSheetOnHide_R, @TTabSheetOnHide_W, 'OnHide');
    RegisterPropertyHelper(@TTabSheetOnShow_R, @TTabSheetOnShow_W, 'OnShow');
  end;
end;

procedure RIRegister_TTabControl(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TTabControl) do
  begin
  end;
end;

procedure RIRegister_TCustomTabControl(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomTabControl) do
  begin
    RegisterMethod(@TCustomTabControl.IndexOfTabAt, 'IndexOfTabAt');
    RegisterMethod(@TCustomTabControl.GetHitTestInfoAt, 'GetHitTestInfoAt');
    RegisterMethod(@TCustomTabControl.TabRect, 'TabRect');
    RegisterMethod(@TCustomTabControl.RowCount, 'RowCount');
    RegisterMethod(@TCustomTabControl.ScrollTabs, 'ScrollTabs');
    RegisterPropertyHelper(@TCustomTabControlCanvas_R, nil, 'Canvas');
  end;
end;

procedure RIRegister_ComCtrls(CL: TPSRuntimeClassImporter);
begin
  CL.Add(TCustomTabControl);
  RIRegister_TCustomTabControl(CL);
  RIRegister_TTabControl(CL);
  CL.Add(TPageControl);
  RIRegister_TTabSheet(CL);
  RIRegister_TPageControl(CL);
  CL.Add(TStatusBar);
  RIRegister_TStatusPanel(CL);
  RIRegister_TStatusPanels(CL);
  RIRegister_TStatusBar(CL);
  CL.Add(THeaderControl);
  RIRegister_THeaderSection(CL);
  RIRegister_THeaderSections(CL);
  RIRegister_THeaderControl(CL);
  CL.Add(TCustomTreeView);
  CL.Add(TTreeNodes);
  RIRegister_TTreeNode(CL);
  RIRegister_TTreeNodes(CL);
  CL.Add(ETreeViewError);
  RIRegister_TCustomTreeView(CL);
  RIRegister_TTreeView(CL);
  RIRegister_TTrackBar(CL);
  RIRegister_TProgressBar(CL);
  CL.Add(TCustomRichEdit);
  RIRegister_TTextAttributes(CL);
  RIRegister_TParaAttributes(CL);
  RIRegister_TConversion(CL);
  RIRegister_TCustomRichEdit(CL);
  RIRegister_TRichEdit(CL);
  RIRegister_TCustomUpDown(CL);
  RIRegister_TUpDown(CL);
  RIRegister_TCustomHotKey(CL);
  RIRegister_THotKey(CL);
  CL.Add(TListColumns);
  CL.Add(TListItems);
  CL.Add(TCustomListView);
  RIRegister_TListColumn(CL);
  RIRegister_TListColumns(CL);
  RIRegister_TListItem(CL);
  RIRegister_TListItems(CL);
  RIRegister_TWorkArea(CL);
  RIRegister_TWorkAreas(CL);
  RIRegister_TIconOptions(CL);
  RIRegister_TCustomListView(CL);
  RIRegister_TListView(CL);
  RIRegister_TAnimate(CL);
  CL.Add(TToolBar);
  CL.Add(TToolButton);
  RIRegister_TToolButton(CL);
  RIRegister_TToolBar(CL);
  CL.Add(TCoolBar);
  RIRegister_TCoolBand(CL);
  RIRegister_TCoolBands(CL);
  RIRegister_TCoolBar(CL);
  CL.Add(TCommonCalendar);
  RIRegister_TMonthCalColors(CL);
  RIRegister_TCommonCalendar(CL);
  RIRegister_TMonthCalendar(CL);
  RIRegister_TDateTimePicker(CL);
  RIRegister_TPageScroller(CL);
end;

{ TPSImport_ComCtrls }

procedure TPSImport_ComCtrls.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ComCtrls(CompExec.Comp);
end;

procedure TPSImport_ComCtrls.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_ComCtrls(ri);
  RIRegister_ComCtrls_Routines(CompExec.Exec); // comment it if no routines
end;

end.




