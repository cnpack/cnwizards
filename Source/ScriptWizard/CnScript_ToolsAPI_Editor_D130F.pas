{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnScript_ToolsAPI_Editor_D130F;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��ű���չ ToolsAPI.Editor ע����
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ�� UnitParser v0.7 �Զ����ɵ��ļ��޸Ķ���
* ����ƽ̨��PWin7 + Delphi 13
* ���ݲ��ԣ�PWin7/10 + Delphi 13
* �� �� �����ô����е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.09.12 V1.0
*               ������Ԫ
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
procedure SIRegister_INTACodeEditorServices290(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorScrollbarAnnotation(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorServices280(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorOptions(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorOptions280(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorEvents370(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorEvents(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorPaintContext(CL: TPSPascalCompiler);
procedure SIRegister_INTACodeEditorPaintContext290(CL: TPSPascalCompiler);
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
    RegisterProperty('OnEditorMouseDown', 'TEditorMouseEvent', iptrw);
    RegisterProperty('OnEditorMouseUp', 'TEditorMouseEvent', iptrw);
    RegisterProperty('OnEditorMouseMove', 'TEditorMouseMoveEvent', iptrw);
    RegisterProperty('OnEditorMouseDownEx', 'TEditorMouseExEvent', iptrw);
    RegisterProperty('OnEditorMouseUpEx', 'TEditorMouseExEvent', iptrw);
    RegisterProperty('OnEditorKeyDown', 'TEditorKeyboardEvent', iptrw);
    RegisterProperty('OnEditorKeyUp', 'TEditorKeyboardEvent', iptrw);
    RegisterProperty('OnEditorSetCaretPos', 'TEditorCaretPosEvent', iptrw);
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
  //with RegInterfaceS(CL,'INTACodeEditorServices290', 'INTACodeEditorServices') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorServices290'),INTACodeEditorServices, 'INTACodeEditorServices') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorServices290(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTACodeEditorServices280', 'INTACodeEditorServices290') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorServices280'),INTACodeEditorServices290, 'INTACodeEditorServices290') do
  begin
    RegisterMethod('Function RegisterScrollbarAnnotation( const AScrollbarAnnotation : INTACodeEditorScrollbarAnnotation) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveScrollbarAnnotation( AIndex : Integer)', cdRegister);
    RegisterMethod('Procedure AddScrollbarAnnotationEntry( const AEditor : TWinControl; AIndex, ALineNumber : Integer; AColor : TColor)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorScrollbarAnnotation(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'INTACodeEditorScrollbarAnnotation') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),INTACodeEditorScrollbarAnnotation, 'INTACodeEditorScrollbarAnnotation') do
  begin
    RegisterMethod('Function GetEnabled : Boolean', cdRegister);
    RegisterMethod('Procedure SetEnabled( const Value : Boolean)', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Function GetWidth : Integer', cdRegister);
    RegisterMethod('Procedure SetWidth( const Value : Integer)', cdRegister);
    RegisterMethod('Function GetStart : Integer', cdRegister);
    RegisterMethod('Procedure SetStart( const Value : Integer)', cdRegister);
    RegisterMethod('Function GetColor : TColor', cdRegister);
    RegisterMethod('Function GetCustomDraw : Boolean', cdRegister);
    RegisterMethod('Procedure DrawMark( const AEditor : TWinControl; LineNum : Integer; ACanvas : TCanvas; ARect : TRect)', cdRegister);
    RegisterMethod('Procedure GetScrollbarAnnotations( const AEditor : TWinControl)', cdRegister);
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
procedure SIRegister_INTACodeEditorEvents370(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTACodeEditorEvents', 'INTACodeEditorEvents370') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorEvents'),INTACodeEditorEvents370, 'INTACodeEditorEvents370') do
  begin
    RegisterMethod('Procedure EditorMouseDown( const Editor : TWinControl; Button : TMouseButton; Shift : TShiftState; X, Y : Integer; var Handled : Boolean)', cdRegister);
    RegisterMethod('Procedure EditorMouseUp( const Editor : TWinControl; Button : TMouseButton; Shift : TShiftState; X, Y : Integer; var Handled : Boolean)', cdRegister);
    RegisterMethod('Procedure EditorKeyDown( const Editor : TWinControl; Key : Word; Shift : TShiftState; var Handled : Boolean)', cdRegister);
    RegisterMethod('Procedure EditorKeyUp( const Editor : TWinControl; Key : Word; Shift : TShiftState; var Handled : Boolean)', cdRegister);
    RegisterMethod('Procedure EditorSetCaretPos( const Editor : TWinControl; X, Y : Integer)', cdRegister);
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
  //with RegInterfaceS(CL,'INTACodeEditorPaintContext290', 'INTACodeEditorPaintContext') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorPaintContext290'),INTACodeEditorPaintContext, 'INTACodeEditorPaintContext') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACodeEditorPaintContext290(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTACodeEditorPaintContext280', 'INTACodeEditorPaintContext290') do
  with CL.AddInterface(CL.FindInterface('INTACodeEditorPaintContext280'),INTACodeEditorPaintContext290, 'INTACodeEditorPaintContext290') do
  begin
    RegisterMethod('Function GetCellSize : TSize', cdRegister);
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
   +'s, cevKeyboardEvents )');
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
  SIRegister_INTACodeEditorPaintContext290(CL);
  SIRegister_INTACodeEditorPaintContext(CL);
  SIRegister_INTACodeEditorEvents(CL);
  SIRegister_INTACodeEditorEvents370(CL);
  SIRegister_INTACodeEditorOptions280(CL);
  SIRegister_INTACodeEditorOptions(CL);
  SIRegister_INTACodeEditorServices280(CL);
  SIRegister_INTACodeEditorScrollbarAnnotation(CL);
  SIRegister_INTACodeEditorServices290(CL);
  SIRegister_INTACodeEditorServices(CL);
  CL.AddTypeS('TEditorScrolledEvent', 'Procedure ( const Editor : TWinControl; '
   +'const Direction : TCodeEditorScrollDirection)');
  CL.AddTypeS('TEditorResizedEvent', 'Procedure ( const Editor : TWinControl)');
  CL.AddTypeS('TEditorElidedEvent', 'Procedure ( const Editor : TWinControl; co'
   +'nst LogicalLineNum : Integer)');
  CL.AddTypeS('TEditorMouseEvent', 'Procedure ( const Editor : TWinControl; But'
   +'ton : TMouseButton; Shift : TShiftState; X, Y : Integer)');
  CL.AddTypeS('TEditorMouseExEvent', 'Procedure ( const Editor : TWinControl; B'
   +'utton : TMouseButton; Shift : TShiftState; X, Y : Integer; var Handled : B'
   +'oolean)');
  CL.AddTypeS('TEditorMouseMoveEvent', 'Procedure ( const Editor : TWinControl;'
   +' Shift : TShiftState; X, Y : Integer)');
  CL.AddTypeS('TEditorKeyboardEvent', 'Procedure ( const Editor : TWinControl; '
   +'Key : Word; Shift : TShiftState; var Handled : Boolean)');
  CL.AddTypeS('TEditorCaretPosEvent', 'Procedure ( const Editor : TWinControl; '
   +'X, Y : Integer)');
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
procedure TNTACodeEditorNotifierOnEditorSetCaretPos_W(Self: TNTACodeEditorNotifier; const T: TEditorCaretPosEvent);
begin Self.OnEditorSetCaretPos := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorSetCaretPos_R(Self: TNTACodeEditorNotifier; var T: TEditorCaretPosEvent);
begin T := Self.OnEditorSetCaretPos; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorKeyUp_W(Self: TNTACodeEditorNotifier; const T: TEditorKeyboardEvent);
begin Self.OnEditorKeyUp := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorKeyUp_R(Self: TNTACodeEditorNotifier; var T: TEditorKeyboardEvent);
begin T := Self.OnEditorKeyUp; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorKeyDown_W(Self: TNTACodeEditorNotifier; const T: TEditorKeyboardEvent);
begin Self.OnEditorKeyDown := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorKeyDown_R(Self: TNTACodeEditorNotifier; var T: TEditorKeyboardEvent);
begin T := Self.OnEditorKeyDown; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseUpEx_W(Self: TNTACodeEditorNotifier; const T: TEditorMouseExEvent);
begin Self.OnEditorMouseUpEx := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseUpEx_R(Self: TNTACodeEditorNotifier; var T: TEditorMouseExEvent);
begin T := Self.OnEditorMouseUpEx; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseDownEx_W(Self: TNTACodeEditorNotifier; const T: TEditorMouseExEvent);
begin Self.OnEditorMouseDownEx := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseDownEx_R(Self: TNTACodeEditorNotifier; var T: TEditorMouseExEvent);
begin T := Self.OnEditorMouseDownEx; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseMove_W(Self: TNTACodeEditorNotifier; const T: TEditorMouseMoveEvent);
begin Self.OnEditorMouseMove := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseMove_R(Self: TNTACodeEditorNotifier; var T: TEditorMouseMoveEvent);
begin T := Self.OnEditorMouseMove; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseUp_W(Self: TNTACodeEditorNotifier; const T: TEditorMouseEvent);
begin Self.OnEditorMouseUp := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseUp_R(Self: TNTACodeEditorNotifier; var T: TEditorMouseEvent);
begin T := Self.OnEditorMouseUp; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseDown_W(Self: TNTACodeEditorNotifier; const T: TEditorMouseEvent);
begin Self.OnEditorMouseDown := T; end;

(*----------------------------------------------------------------------------*)
procedure TNTACodeEditorNotifierOnEditorMouseDown_R(Self: TNTACodeEditorNotifier; var T: TEditorMouseEvent);
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
Procedure TNTACodeEditorNotifierEditorMouseUp1_P(Self: TNTACodeEditorNotifier;  const Editor : TWinControl; Button : TMouseButton; Shift : TShiftState; X, Y : Integer; var Handled : Boolean);
Begin Self.EditorMouseUp(Editor, Button, Shift, X, Y, Handled); END;

(*----------------------------------------------------------------------------*)
Procedure TNTACodeEditorNotifierEditorMouseDown1_P(Self: TNTACodeEditorNotifier;  const Editor : TWinControl; Button : TMouseButton; Shift : TShiftState; X, Y : Integer; var Handled : Boolean);
Begin Self.EditorMouseDown(Editor, Button, Shift, X, Y, Handled); END;

(*----------------------------------------------------------------------------*)
Procedure TNTACodeEditorNotifierEditorMouseUp_P(Self: TNTACodeEditorNotifier;  const Editor : TWinControl; Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
Begin Self.EditorMouseUp(Editor, Button, Shift, X, Y); END;

(*----------------------------------------------------------------------------*)
Procedure TNTACodeEditorNotifierEditorMouseDown_P(Self: TNTACodeEditorNotifier;  const Editor : TWinControl; Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
Begin Self.EditorMouseDown(Editor, Button, Shift, X, Y); END;

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
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorMouseDownEx_R,@TNTACodeEditorNotifierOnEditorMouseDownEx_W,'OnEditorMouseDownEx');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorMouseUpEx_R,@TNTACodeEditorNotifierOnEditorMouseUpEx_W,'OnEditorMouseUpEx');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorKeyDown_R,@TNTACodeEditorNotifierOnEditorKeyDown_W,'OnEditorKeyDown');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorKeyUp_R,@TNTACodeEditorNotifierOnEditorKeyUp_W,'OnEditorKeyUp');
    RegisterPropertyHelper(@TNTACodeEditorNotifierOnEditorSetCaretPos_R,@TNTACodeEditorNotifierOnEditorSetCaretPos_W,'OnEditorSetCaretPos');
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
