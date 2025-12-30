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

unit CnScript_ToolsAPI_Editor_D120A;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 ToolsAPI.Editor 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWin7 + Delphi 12
* 兼容测试：PWin7/10 + Delphi 12
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2025.05.01 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
   SysUtils
  ,Classes
  ,uPSComponent
  ,uPSRuntime
  ,uPSCompiler
  ;

type
(*----------------------------------------------------------------------------*)
  TPSImport_ToolsAPI_Editor = class(TPSPlugin)
  protected
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;


{ compile-time registration functions }
procedure SIRegister_TNTACodeEditorNotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorServices(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorServices280(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorOptions(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorOptions280(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorEvents(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorPaintContext(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorPaintContext280(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorState(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorState290(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorState280(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorLineState(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorLineState290(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorLineState280(CL: TPSPascalCompiler);
procedure SIRegister_ToolsAPI_Editor(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_ToolsAPI_Editor_Routines(S: TPSExec);
procedure RIRegister_TNTACodeEditorNotifier(CL: TPSRuntimeClassImporter);
procedure RIRegister_ToolsAPI_Editor(CL: TPSRuntimeClassImporter);

procedure Register;

implementation


uses
   Types
  ,ToolsAPI
  ,Controls
  ,Graphics
  ,ToolsAPI.Editor
  ;

procedure Register;
begin
  RegisterComponents('Pascal Script', [TPSImport_ToolsAPI_Editor]);
end;

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_TNTACodeEditorNotifier(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TNotifierObject', 'TNTACodeEditorNotifier') do
  with CL.AddClassN(CL.FindClass('TNotifierObject'),'TNTACodeEditorNotifier') do
  begin
    RegisterProperty('OnEditorScrolled', 'TEditorScrolledEvent', iptrw);
    RegisterProperty('OnEditorResized', 'TEditorResizedEvent', iptrw);
    RegisterProperty('OnEditorElided', 'TEditorElidedEvent', iptrw);
    RegisterProperty('OnEditorUnElided', 'TEditorElidedEvent', iptrw);
    RegisterProperty('OnEditorMouseDown', 'TEditorMouseDownEvent', iptrw);
    RegisterProperty('OnEditorMouseUp', 'TEditorMouseUpEvent', iptrw);
    RegisterProperty('OnEditorMouseMove', 'TEditorMouseMoveEvent', iptrw);
    RegisterProperty('OnEditorBeginPaint', 'TEditorBeginPaintEvent', iptrw);
    RegisterProperty('OnEditorEndPaint', 'TEditorEndPaintEvent', iptrw);
    RegisterProperty('OnEditorPaintGutter', 'TEditorPaintGutterEvent', iptrw);
    RegisterProperty('OnEditorPaintLine', 'TEditorPaintLineEvent', iptrw);
    RegisterProperty('OnEditorPaintText', 'TEditorPaintTextEvent', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTACodeEditorServices280', 'INTACodeEditorServices') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorServices280'),INTACodeEditorServices, 'INTACodeEditorServices') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorServices280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTACodeEditorServices280') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTACodeEditorServices280, 'INTACodeEditorServices280') do
  begin
    RegisterMethod('Function GetViewForEditor( const Editor : TWinControl) : IOTAEditView', cdRegister);
    RegisterMethod('Function GetEditorForView( const View : IOTAEditView) : TWinControl', cdRegister);
    RegisterMethod('Procedure FocusTopEditor', cdRegister);
    RegisterMethod('Function GetTopEditor : TWinControl', cdRegister);
    RegisterMethod('Function IsIDEEditor( const Control : TWinControl) : Boolean', cdRegister);
    RegisterMethod('Function GetEditorState( const Editor : TWinControl) : INTACodeEditorState', cdRegister);
    RegisterMethod('Function GetKnownEditors : TList', cdRegister);
    RegisterMethod('Function GetKnownViews : TList', cdRegister);
    RegisterMethod('Function AddEditorEventsNotifier( const ANotifier : INTACodeEditorEvents) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveEditorEventsNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Function GetCodeEditorOptions : INTACodeEditorOptions', cdRegister);
    RegisterMethod('Function RequestGutterColumn( const NotifierIndex, Size : Integer; Position : TGutterColumnPosition) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveGutterColumn( const ColumnIndex : Integer)', cdRegister);
    RegisterMethod('Procedure InvalidateEditor( const Editor : TWinControl);', cdRegister);
    RegisterMethod('Procedure InvalidateEditorRect( const Editor : TWinControl; ARect : TRect);', cdRegister);
    RegisterMethod('Procedure InvalidateEditorLogicalLine( const Editor : TWinControl; const LogicalLine : Integer);', cdRegister);
    RegisterMethod('Procedure InvalidateTopEditor', cdRegister);
    RegisterMethod('Procedure InvalidateTopEditorRect( ARect : TRect)', cdRegister);
    RegisterMethod('Procedure InvalidateTopEditorLogicalLine( const LogicalLine : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTACodeEditorOptions280', 'INTACodeEditorOptions') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorOptions280'),INTACodeEditorOptions, 'INTACodeEditorOptions') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorOptions280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTACodeEditorOptions280') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTACodeEditorOptions280, 'INTACodeEditorOptions280') do
  begin
    RegisterMethod('Function GetFontColor( Kind : TOTASyntaxCode) : TColor', cdRegister);
    RegisterMethod('Function GetBackgroundColor( Kind : TOTASyntaxCode) : TColor', cdRegister);
    RegisterMethod('Function GetGutterVisible : Boolean', cdRegister);
    RegisterMethod('Function GetGutterWidth : Integer', cdRegister);
    RegisterMethod('Function GetRightMarginVisible : Boolean', cdRegister);
    RegisterMethod('Function GetRightMarginChars : Integer', cdRegister);
    RegisterMethod('Function GetFontStyles( Kind : TOTASyntaxCode) : TFontStyles', cdRegister);
    RegisterMethod('Procedure GetEditorFont( var Font : TFont)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorEvents(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'INTACodeEditorEvents') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),INTACodeEditorEvents, 'INTACodeEditorEvents') do
  begin
    RegisterMethod('Procedure EditorScrolled( const Editor : TWinControl; const Direction : TCodeEditorScrollDirection)', cdRegister);
    RegisterMethod('Procedure EditorResized( const Editor : TWinControl)', cdRegister);
    RegisterMethod('Procedure EditorElided( const Editor : TWinControl; const LogicalLineNum : Integer)', cdRegister);
    RegisterMethod('Procedure EditorUnElided( const Editor : TWinControl; const LogicalLineNum : Integer)', cdRegister);
    RegisterMethod('Procedure EditorMouseDown( const Editor : TWinControl; Button : TMouseButton; Shift : TShiftState; X, Y : Integer)', cdRegister);
    RegisterMethod('Procedure EditorMouseMove( const Editor : TWinControl; Shift : TShiftState; X, Y : Integer)', cdRegister);
    RegisterMethod('Procedure EditorMouseUp( const Editor : TWinControl; Button : TMouseButton; Shift : TShiftState; X, Y : Integer)', cdRegister);
    RegisterMethod('Procedure BeginPaint( const Editor : TWinControl; const ForceFullRepaint : Boolean)', cdRegister);
    RegisterMethod('Procedure EndPaint( const Editor : TWinControl)', cdRegister);
    RegisterMethod('Procedure PaintLine( const Rect : TRect; const Stage : TPaintLineStage; const BeforeEvent : Boolean; var AllowDefaultPainting : Boolean; const Context : INTACodeEditorPaintContext)', cdRegister);
    RegisterMethod('Procedure PaintGutter( const Rect : TRect; const Stage : TPaintGutterStage; const BeforeEvent : Boolean; var AllowDefaultPainting : Boolean; const Context : INTACodeEditorPaintContext)', cdRegister);
    RegisterMethod('Procedure PaintText( const Rect : TRect; const ColNum : SmallInt; const Text : string; const SyntaxCode : TOTASyntaxCode; const Hilight, BeforeEvent : Boolean; var AllowDefaultPainting : Boolean; const Context : INTACodeEditorPaintContext)', cdRegister);
    RegisterMethod('Function AllowedEvents : TCodeEditorEvents', cdRegister);
    RegisterMethod('Function AllowedGutterStages : TPaintGutterStages', cdRegister);
    RegisterMethod('Function AllowedLineStages : TPaintLineStages', cdRegister);
    RegisterMethod('Function UIOptions : TCodeEditorUIOptions', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorPaintContext(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTACodeEditorPaintContext280', 'INTACodeEditorPaintContext') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorPaintContext280'),INTACodeEditorPaintContext, 'INTACodeEditorPaintContext') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorPaintContext280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTACodeEditorPaintContext280') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTACodeEditorPaintContext280, 'INTACodeEditorPaintContext280') do
  begin
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetEditView : IOTAEditView', cdRegister);
    RegisterMethod('Function GetEditControl : TWinControl', cdRegister);
    RegisterMethod('Function GetEditorLineNum : Integer', cdRegister);
    RegisterMethod('Function GetLogicalLineNum : Integer', cdRegister);
    RegisterMethod('Function GetCanvas : TCanvas', cdRegister);
    RegisterMethod('Function GetEditorState : INTACodeEditorState', cdRegister);
    RegisterMethod('Function GetLineState : INTACodeEditorLineState', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorState(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTACodeEditorState290', 'INTACodeEditorState') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorState290'),INTACodeEditorState, 'INTACodeEditorState') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorState290(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTACodeEditorState280', 'INTACodeEditorState290') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorState280'),INTACodeEditorState290, 'INTACodeEditorState290') do
  begin
    RegisterMethod('Function GetEditorToken : string', cdRegister);
    RegisterMethod('Function GetCharWidth : Integer', cdRegister);
    RegisterMethod('Function GetCharHeight : Integer', cdRegister);
    RegisterMethod('Procedure Refresh', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorState280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTACodeEditorState280') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTACodeEditorState280, 'INTACodeEditorState280') do
  begin
    RegisterMethod('Function GetLineState( VisibleLine : Integer) : INTACodeEditorLineState', cdRegister);
    RegisterMethod('Function GetLogicalLineState( LogicalLine : Integer) : INTACodeEditorLineState', cdRegister);
    RegisterMethod('Function IsLineVisible( const LogicalLine : Integer) : Boolean', cdRegister);
    RegisterMethod('Function IsLogicalLineVisible( const LogicalLineNum : Integer) : Boolean', cdRegister);
    RegisterMethod('Function GetLineForElidedLogicalLine( const InvisibleLogicalLine : Integer) : Integer', cdRegister);
    RegisterMethod('Function GetTopLine : Integer', cdRegister);
    RegisterMethod('Function GetBottomLine : Integer', cdRegister);
    RegisterMethod('Function GetEditorRect : TRect', cdRegister);
    RegisterMethod('Function GetGutterWidth : Integer', cdRegister);
    RegisterMethod('Function GetCodeLeftEdge : Integer', cdRegister);
    RegisterMethod('Function GetCodeEditor : TWinControl', cdRegister);
    RegisterMethod('Function GetView : IOTAEditView', cdRegister);
    RegisterMethod('Function GetCharacterPosPx( const Column, VisibleLine : Integer) : TRect', cdRegister);
    RegisterMethod('Function PointToCharacterPos( const ClientPos : TPoint; out Column, VisibleLine : Integer) : Boolean', cdRegister);
    RegisterMethod('Function LineFromY( const Y : SmallInt; const VisibleLine : Boolean) : Integer', cdRegister);
    RegisterMethod('Function ColFromX( const X : SmallInt) : Integer', cdRegister);
    RegisterMethod('Function GetLeftColumn : Integer', cdRegister);
    RegisterMethod('Function GetRightColumn : Integer', cdRegister);
    RegisterMethod('Function GetLargestVisibleLineChars : Integer', cdRegister);
    RegisterMethod('Function GetGutterColumnLeft( const Editor : TWinControl; const ColumnIndex : Integer) : Integer', cdRegister);
    RegisterMethod('Function GetGutterColumnRect( const Editor : TWinControl; const VisibleLine, ColumnIndex : Integer) : TRect', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorLineState(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTACodeEditorLineState290', 'INTACodeEditorLineState') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorLineState290'),INTACodeEditorLineState, 'INTACodeEditorLineState') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorLineState290(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTACodeEditorLineState280', 'INTACodeEditorLineState290') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorLineState280'),INTACodeEditorLineState290, 'INTACodeEditorLineState290') do
  begin
    RegisterMethod('Function GetCellState( Column : Integer) : TCodeEditorCellStates', cdRegister);
    RegisterMethod('Function GetState : TCodeEditorLineStates', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorLineState280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTACodeEditorLineState280') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTACodeEditorLineState280, 'INTACodeEditorLineState280') do
  begin
    RegisterMethod('Function IsElidedLine : Boolean', cdRegister);
    RegisterMethod('Function IsLogicalLineInElidedSection( const LogicalLine : Integer) : Boolean', cdRegister);
    RegisterMethod('Function GetEditorLineNum : Integer', cdRegister);
    RegisterMethod('Function GetLogicalLineNum : Integer', cdRegister);
    RegisterMethod('Function GetElidedLineStart : Integer', cdRegister);
    RegisterMethod('Function GetElidedLineEnd : Integer', cdRegister);
    RegisterMethod('Function GetWholeRect : TRect', cdRegister);
    RegisterMethod('Function GetGutterRect : TRect', cdRegister);
    RegisterMethod('Function GetGutterLineDataRect : TRect', cdRegister);
    RegisterMethod('Function GetCodeRect : TRect', cdRegister);
    RegisterMethod('Function GetText : string', cdRegister);
    RegisterMethod('Function GetVisibleText : string', cdRegister);
    RegisterMethod('Function GetVisibleTextRect : TRect', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_ToolsAPI_Editor(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TCodeEditorLineState', '( eleLineHighlight, eleErrorLine, eleExe'
   +'cution, eleBreakpoint, eleInvalidBreakpoint, eleDisabledBreakpoint, eleCom'
   +'piled )');
  CL.AddTypeS('TCodeEditorLineStates', 'set of TCodeEditorLineState');
  CL.AddTypeS('TCodeEditorCellState', '( eceSelected, eceHotLink, eceHotLinkabl'
   +'e, eceSyncEditBackground, eceSyncEditSearch, eceSyncEditMatch, eceSearchMa'
   +'tch, eceExtraMatch, eceBraceMatch, eceHint, eceWarning, eceError, eceDisab'
   +'ledCode, eceFoldBox )');
  CL.AddTypeS('TCodeEditorCellStates', 'set of TCodeEditorCellState');
  SIRegister_INTACodeEditorLineState280(CL);
  SIRegister_INTACodeEditorLineState290(CL);
  SIRegister_INTACodeEditorLineState(CL);
  SIRegister_INTACodeEditorState280(CL);
  SIRegister_INTACodeEditorState290(CL);
  SIRegister_INTACodeEditorState(CL);
  CL.AddTypeS('TCodeEditorEvent', '( cevWindowEvents, cevMouseEvents, cevBeginE'
   +'ndPaintEvents, cevPaintLineEvents, cevPaintGutterEvents, cevPaintTextEvent'
   +'s )');
  CL.AddTypeS('TCodeEditorEvents', 'set of TCodeEditorEvent');
  CL.AddTypeS('TPaintLineStage', '( plsBeginPaint, plsEndPaint, plsBackground, '
   +'plsMarks, plsHighlightPairChars, plsRightMargin, plsFoldedBox )');
  CL.AddTypeS('TPaintLineStages', 'set of TPaintLineStage');
  CL.AddTypeS('TPaintGutterStage', '( pgsBeginPaint, pgsEndPaint, pgsBookMarks,'
   +' pgsCSIP, pgsBreakpoint, pgsGutterEdge, pgsElision, pgsLineNumber, pgsAnno'
   +'tate, pgsModifiedLines )');
  CL.AddTypeS('TPaintGutterStages', 'set of TPaintGutterStage');
  CL.AddTypeS('TCodeEditorScrollDirection', '( sdHorizontal, sdVertical )');
  CL.AddTypeS('TCodeEditorUIOption', '( ceoDisableScrollDC, ceoDisableFontScali'
   +'ng )');
  CL.AddTypeS('TCodeEditorUIOptions', 'set of TCodeEditorUIOption');
  CL.AddTypeS('TGutterColumnPosition', '( gclBeforeBreakPoint, gclAfterBreakPoi'
   +'nt, gclBeforeLineNumbers, gclAfterLineNumbers )');
  CL.AddTypeS('TGutterColumnPositions', 'set of TGutterColumnPosition');
  SIRegister_INTACodeEditorPaintContext280(CL);
  SIRegister_INTACodeEditorPaintContext(CL);
  SIRegister_INTACodeEditorEvents(CL);
  SIRegister_INTACodeEditorOptions280(CL);
  SIRegister_INTACodeEditorOptions(CL);
  SIRegister_INTACodeEditorServices280(CL);
  SIRegister_INTACodeEditorServices(CL);
  CL.AddTypeS('TEditorScrolledEvent', 'Procedure ( const Editor : TWinControl; '
   +'const Direction : TCodeEditorScrollDirection)');
  CL.AddTypeS('TEditorResizedEvent', 'Procedure ( const Editor : TWinControl)');
  CL.AddTypeS('TEditorElidedEvent', 'Procedure ( const Editor : TWinControl; co'
   +'nst LogicalLineNum : Integer)');
  CL.AddTypeS('TEditorMouseDownEvent', 'Procedure ( const Editor : TWinControl;'
   +' Button : TMouseButton; Shift : TShiftState; X, Y : Integer)');
  CL.AddTypeS('TEditorMouseUpEvent', 'Procedure ( const Editor : TWinControl; B'
   +'utton : TMouseButton; Shift : TShiftState; X, Y : Integer)');
  CL.AddTypeS('TEditorMouseMoveEvent', 'Procedure ( const Editor : TWinControl;'
   +' Shift : TShiftState; X, Y : Integer)');
  CL.AddTypeS('TEditorBeginPaintEvent', 'Procedure ( const Editor : TWinControl'
   +'; const ForceFullRepaint : Boolean)');
  CL.AddTypeS('TEditorEndPaintEvent', 'Procedure ( const Editor : TWinControl)');
  CL.AddTypeS('TEditorPaintLineEvent', 'Procedure ( const Rect : TRect; const S'
   +'tage : TPaintLineStage; const BeforeEvent : Boolean; var AllowDefaultPaint'
   +'ing : Boolean; const Context : INTACodeEditorPaintContext)');
  CL.AddTypeS('TEditorPaintGutterEvent', 'Procedure ( const Rect : TRect; const'
   +' Stage : TPaintGutterStage; const BeforeEvent : Boolean; var AllowDefaultP'
   +'ainting : Boolean; const Context : INTACodeEditorPaintContext)');
  CL.AddTypeS('TEditorPaintTextEvent', 'Procedure ( const Rect : TRect; const C'
   +'olNum : SmallInt; const Text : string; const SyntaxCode : TOTASyntaxCode; '
   +'const Hilight, BeforeEvent : Boolean; var AllowDefaultPainting : Boolean; '
   +'const Context : INTACodeEditorPaintContext)');
  SIRegister_TNTACodeEditorNotifier(CL);
 CL.AddConstantN('cGutterColumnAllPositions','LongInt').Value.ts32 := ord(gclBeforeBreakPoint) or ord(gclAfterBreakPoint) or ord(gclBeforeLineNumbers) or ord(gclAfterLineNumbers);
 CL.AddDelphiFunction('Function OTASyntaxCodeToStr( SyntaxCode : TOTASyntaxCode) : string');
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorPaintText_W(Self: TNTACodeEditorNotifier; const T: TEditorPaintTextEvent);
begin Self.OnEditorPaintText := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorPaintText_R(Self: TNTACodeEditorNotifier; var T: TEditorPaintTextEvent);
begin T := Self.OnEditorPaintText; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorPaintLine_W(Self: TNTACodeEditorNotifier; const T: TEditorPaintLineEvent);
begin Self.OnEditorPaintLine := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorPaintLine_R(Self: TNTACodeEditorNotifier; var T: TEditorPaintLineEvent);
begin T := Self.OnEditorPaintLine; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorPaintGutter_W(Self: TNTACodeEditorNotifier; const T: TEditorPaintGutterEvent);
begin Self.OnEditorPaintGutter := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorPaintGutter_R(Self: TNTACodeEditorNotifier; var T: TEditorPaintGutterEvent);
begin T := Self.OnEditorPaintGutter; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorEndPaint_W(Self: TNTACodeEditorNotifier; const T: TEditorEndPaintEvent);
begin Self.OnEditorEndPaint := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorEndPaint_R(Self: TNTACodeEditorNotifier; var T: TEditorEndPaintEvent);
begin T := Self.OnEditorEndPaint; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorBeginPaint_W(Self: TNTACodeEditorNotifier; const T: TEditorBeginPaintEvent);
begin Self.OnEditorBeginPaint := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorBeginPaint_R(Self: TNTACodeEditorNotifier; var T: TEditorBeginPaintEvent);
begin T := Self.OnEditorBeginPaint; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseMove_W(Self: TNTACodeEditorNotifier; const T: TEditorMouseMoveEvent);
begin Self.OnEditorMouseMove := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseMove_R(Self: TNTACodeEditorNotifier; var T: TEditorMouseMoveEvent);
begin T := Self.OnEditorMouseMove; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseUp_W(Self: TNTACodeEditorNotifier; const T: TEditorMouseUpEvent);
begin Self.OnEditorMouseUp := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseUp_R(Self: TNTACodeEditorNotifier; var T: TEditorMouseUpEvent);
begin T := Self.OnEditorMouseUp; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseDown_W(Self: TNTACodeEditorNotifier; const T: TEditorMouseDownEvent);
begin Self.OnEditorMouseDown := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseDown_R(Self: TNTACodeEditorNotifier; var T: TEditorMouseDownEvent);
begin T := Self.OnEditorMouseDown; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorUnElided_W(Self: TNTACodeEditorNotifier; const T: TEditorElidedEvent);
begin Self.OnEditorUnElided := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorUnElided_R(Self: TNTACodeEditorNotifier; var T: TEditorElidedEvent);
begin T := Self.OnEditorUnElided; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorElided_W(Self: TNTACodeEditorNotifier; const T: TEditorElidedEvent);
begin Self.OnEditorElided := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorElided_R(Self: TNTACodeEditorNotifier; var T: TEditorElidedEvent);
begin T := Self.OnEditorElided; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorResized_W(Self: TNTACodeEditorNotifier; const T: TEditorResizedEvent);
begin Self.OnEditorResized := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorResized_R(Self: TNTACodeEditorNotifier; var T: TEditorResizedEvent);
begin T := Self.OnEditorResized; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorScrolled_W(Self: TNTACodeEditorNotifier; const T: TEditorScrolledEvent);
begin Self.OnEditorScrolled := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorScrolled_R(Self: TNTACodeEditorNotifier; var T: TEditorScrolledEvent);
begin T := Self.OnEditorScrolled; end;

(*----------------------------------------------------------------------------*)
Procedure INTACodeEditorServices280InvalidateEditorLogicalLine_P(Self: INTACodeEditorServices280;  const Editor : TWinControl; const LogicalLine : Integer);
Begin Self.InvalidateEditorLogicalLine(Editor, LogicalLine); END;

(*----------------------------------------------------------------------------*)
Procedure INTACodeEditorServices280InvalidateEditorRect_P(Self: INTACodeEditorServices280;  const Editor : TWinControl; ARect : TRect);
Begin Self.InvalidateEditorRect(Editor, ARect); END;

(*----------------------------------------------------------------------------*)
Procedure INTACodeEditorServices280InvalidateEditor_P(Self: INTACodeEditorServices280;  const Editor : TWinControl);
Begin Self.InvalidateEditor(Editor); END;

(*----------------------------------------------------------------------------*)
procedure RIRegister_ToolsAPI_Editor_Routines(S: TPSExec);
begin
 S.RegisterDelphiFunction(@OTASyntaxCodeToStr, 'OTASyntaxCodeToStr', cdRegister);
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TNTACodeEditorNotifier(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TNTACodeEditorNotifier) do
  begin
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorScrolled_R,@TNTACodeEditorNotifierOnEditorScrolled_W,'OnEditorScrolled');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorResized_R,@TNTACodeEditorNotifierOnEditorResized_W,'OnEditorResized');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorElided_R,@TNTACodeEditorNotifierOnEditorElided_W,'OnEditorElided');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorUnElided_R,@TNTACodeEditorNotifierOnEditorUnElided_W,'OnEditorUnElided');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorMouseDown_R,@TNTACodeEditorNotifierOnEditorMouseDown_W,'OnEditorMouseDown');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorMouseUp_R,@TNTACodeEditorNotifierOnEditorMouseUp_W,'OnEditorMouseUp');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorMouseMove_R,@TNTACodeEditorNotifierOnEditorMouseMove_W,'OnEditorMouseMove');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorBeginPaint_R,@TNTACodeEditorNotifierOnEditorBeginPaint_W,'OnEditorBeginPaint');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorEndPaint_R,@TNTACodeEditorNotifierOnEditorEndPaint_W,'OnEditorEndPaint');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorPaintGutter_R,@TNTACodeEditorNotifierOnEditorPaintGutter_W,'OnEditorPaintGutter');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorPaintLine_R,@TNTACodeEditorNotifierOnEditorPaintLine_W,'OnEditorPaintLine');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorPaintText_R,@TNTACodeEditorNotifierOnEditorPaintText_W,'OnEditorPaintText');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_ToolsAPI_Editor(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TNTACodeEditorNotifier(CL);
end;



{ TPSImport_ToolsAPI_Editor }
(*----------------------------------------------------------------------------*)
procedure TPSImport_ToolsAPI_Editor.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ToolsAPI_Editor(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_ToolsAPI_Editor.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_ToolsAPI_Editor_Routines(CompExec.Exec); // comment it if no routines
end;
(*----------------------------------------------------------------------------*)


end.
