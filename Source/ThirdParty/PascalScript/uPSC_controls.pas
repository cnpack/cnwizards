{ Compiletime Controls support }
unit uPSC_controls;
{$I PascalScript.inc}
interface
uses
  uPSCompiler, uPSUtils;

{
  Will register files from:
    Controls
 
  Register the STD, Classes (at least the types&consts) and Graphics libraries first
 
}

procedure SIRegister_Controls_TypesAndConsts(Cl: TPSPascalCompiler);

procedure SIRegisterTControl(Cl: TPSPascalCompiler);
procedure SIRegisterTWinControl(Cl: TPSPascalCompiler); 
procedure SIRegisterTGraphicControl(cl: TPSPascalCompiler); 
procedure SIRegisterTCustomControl(cl: TPSPascalCompiler); 
procedure SIRegisterTDragObject(cl: TPSPascalCompiler);

procedure SIRegister_Controls(Cl: TPSPascalCompiler);


implementation

procedure SIRegisterTControl(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TComponent'), 'TCONTROL') do
  begin
    RegisterMethod('constructor Create(AOwner: TComponent);');
    RegisterMethod('procedure BringToFront;');
    RegisterMethod('procedure Hide;');
    RegisterMethod('procedure Invalidate;virtual;');
    RegisterMethod('procedure refresh;');
    RegisterMethod('procedure Repaint;virtual;');
    RegisterMethod('procedure SendToBack;');
    RegisterMethod('procedure Show;');
    RegisterMethod('procedure Update;virtual;');
    RegisterMethod('procedure SetBounds(x,y,w,h: Integer);virtual;');
    RegisterProperty('Left', 'Integer', iptRW);
    RegisterProperty('Top', 'Integer', iptRW);
    RegisterProperty('Width', 'Integer', iptRW);
    RegisterProperty('Height', 'Integer', iptRW);
    RegisterProperty('Hint', 'String', iptRW);
    RegisterProperty('Align', 'TAlign', iptRW);
    RegisterProperty('ClientHeight', 'Longint', iptRW);
    RegisterProperty('ClientWidth', 'Longint', iptRW);
    RegisterProperty('ShowHint', 'Boolean', iptRW);
    RegisterProperty('Visible', 'Boolean', iptRW);
    RegisterProperty('ENABLED', 'BOOLEAN', iptrw);
    RegisterProperty('CURSOR', 'TCURSOR', iptrw);

    {$IFNDEF PS_MINIVCL}
    RegisterMethod('function Dragging: Boolean;');
    RegisterMethod('function HasParent: Boolean');
    RegisterMethod('procedure BEGINDRAG(IMMEDIATE:BOOLEAN)');
    RegisterMethod('function CLIENTTOSCREEN(POINT:TPOINT):TPOINT');
    RegisterMethod('procedure ENDDRAG(DROP:BOOLEAN)');
    {$IFNDEF CLX}
    RegisterMethod('function GETTEXTBUF(BUFFER:PCHAR;BUFSIZE:INTEGER):INTEGER');
    RegisterMethod('function GETTEXTLEN:INTEGER');
    RegisterMethod('procedure SETTEXTBUF(BUFFER:PCHAR)');
    RegisterMethod('function PERFORM(MSG:CARDINAL;WPARAM,LPARAM:LONGINT):LONGINT');
    {$ENDIF}
    RegisterMethod('function SCREENTOCLIENT(POINT:TPOINT):TPOINT');
    {$ENDIF}
  end;
end;

procedure SIRegisterTWinControl(Cl: TPSPascalCompiler); // requires TControl
begin
  with Cl.AddClassN(cl.FindClass('TControl'), 'TWINCONTROL') do
  begin

    with Cl.FindClass('TControl') do
    begin
      RegisterProperty('Parent', 'TWinControl', iptRW);
    end;

    {$IFNDEF CLX}
    RegisterProperty('Handle', 'Longint', iptR);
    {$ENDIF}
    RegisterProperty('Showing', 'Boolean', iptR);
    RegisterProperty('TabOrder', 'Integer', iptRW);
    RegisterProperty('TabStop', 'Boolean', iptRW);
    RegisterMethod('function CANFOCUS:BOOLEAN');
    RegisterMethod('function FOCUSED:BOOLEAN');
    RegisterProperty('CONTROLS', 'TCONTROL INTEGER', iptr);
    RegisterProperty('CONTROLCOUNT', 'INTEGER', iptr);

    {$IFNDEF PS_MINIVCL}
    RegisterMethod('function HandleAllocated: Boolean;');
    RegisterMethod('procedure HandleNeeded;');
    RegisterMethod('procedure EnableAlign;');
    RegisterMethod('procedure RemoveControl(AControl: TControl);');
    RegisterMethod('procedure InsertControl(AControl: TControl);');
    RegisterMethod('procedure Realign;');
    RegisterMethod('procedure ScaleBy(M, D: Integer);');
    RegisterMethod('procedure ScrollBy(DeltaX, DeltaY: Integer);');
    RegisterMethod('procedure SetFocus; virtual;');
    {$IFNDEF CLX}
    RegisterMethod('procedure PAINTTO(DC:Longint;X,Y:INTEGER)');
    {$ENDIF}

    RegisterMethod('function CONTAINSCONTROL(CONTROL:TCONTROL):BOOLEAN');
    RegisterMethod('procedure DISABLEALIGN');
    RegisterMethod('procedure UPDATECONTROLSTATE');

    RegisterProperty('BRUSH', 'TBRUSH', iptr);
    RegisterProperty('HELPCONTEXT', 'LONGINT', iptrw);
    {$ENDIF}
  end;
end;
procedure SIRegisterTGraphicControl(cl: TPSPascalCompiler); // requires TControl
begin
  Cl.AddClassN(cl.FindClass('TControl'), 'TGRAPHICCONTROL');
end;

procedure SIRegisterTCustomControl(cl: TPSPascalCompiler); // requires TWinControl
begin
  Cl.AddClassN(cl.FindClass('TWinControl'), 'TCUSTOMCONTROL');
end;

procedure SIRegister_Controls_TypesAndConsts(Cl: TPSPascalCompiler);
begin
{$IFNDEF FPC}
  Cl.addTypeS('TEShiftState','(ssShift, ssAlt, ssCtrl, ssLeft, ssRight, ssMiddle, ssDouble)');
  {$ELSE}
  Cl.addTypeS('TEShiftState','(ssShift, ssAlt, ssCtrl, ssLeft, ssRight, ssMiddle, ssDouble,' +
  'ssMeta, ssSuper, ssHyper, ssAltGr, ssCaps, ssNum,ssScroll,ssTriple,ssQuad)');
  {$ENDIF}
  Cl.addTypeS('TShiftState','set of TEShiftState');
  cl.AddTypeS('TMouseButton', '(mbLeft, mbRight, mbMiddle)');
  cl.AddTypeS('TDragMode', '(dmManual, dmAutomatic)');
  cl.AddTypeS('TDragState', '(dsDragEnter, dsDragLeave, dsDragMove)');
  cl.AddTypeS('TDragKind', '(dkDrag, dkDock)');
  cl.AddTypeS('TMouseEvent', 'procedure (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);');
  cl.AddTypeS('TMouseMoveEvent', 'procedure(Sender: TObject; Shift: TShiftState; X, Y: Integer);');
  cl.AddTypeS('TKeyEvent', 'procedure (Sender: TObject; var Key: Word; Shift: TShiftState);');
  cl.AddTypeS('TKeyPressEvent', 'procedure(Sender: TObject; var Key: Char);');
  cl.AddTypeS('TDragOverEvent', 'procedure(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean)');
  cl.AddTypeS('TDragDropEvent', 'procedure(Sender, Source: TObject;X, Y: Integer)');
  cl.AddTypeS('HWND', 'Longint');

  cl.AddTypeS('TEndDragEvent', 'procedure(Sender, Target: TObject; X, Y: Integer)');

  cl.addTypeS('TAlign', '(alNone, alTop, alBottom, alLeft, alRight, alClient)');

  cl.addTypeS('TAnchorKind', '(akTop, akLeft, akRight, akBottom)');
  cl.addTypeS('TAnchors','set of TAnchorKind');
  cl.AddTypeS('TModalResult', 'Integer');
  cl.AddTypeS('TCursor', 'Integer');
  cl.AddTypeS('TPoint', 'record x,y: Longint; end;');

  cl.AddConstantN('mrNone', 'Integer').Value.ts32 := 0;
  cl.AddConstantN('mrOk', 'Integer').Value.ts32 := 1;
  cl.AddConstantN('mrCancel', 'Integer').Value.ts32 := 2;
  cl.AddConstantN('mrAbort', 'Integer').Value.ts32 := 3;
  cl.AddConstantN('mrRetry', 'Integer').Value.ts32 := 4;
  cl.AddConstantN('mrIgnore', 'Integer').Value.ts32 := 5;
  cl.AddConstantN('mrYes', 'Integer').Value.ts32 := 6;
  cl.AddConstantN('mrNo', 'Integer').Value.ts32 := 7;
  cl.AddConstantN('mrAll', 'Integer').Value.ts32 := 8;
  cl.AddConstantN('mrNoToAll', 'Integer').Value.ts32 := 9;
  cl.AddConstantN('mrYesToAll', 'Integer').Value.ts32 := 10;
  cl.AddConstantN('crDefault', 'Integer').Value.ts32 := 0;
  cl.AddConstantN('crNone', 'Integer').Value.ts32 := -1;
  cl.AddConstantN('crArrow', 'Integer').Value.ts32 := -2;
  cl.AddConstantN('crCross', 'Integer').Value.ts32 := -3;
  cl.AddConstantN('crIBeam', 'Integer').Value.ts32 := -4;
  cl.AddConstantN('crSizeNESW', 'Integer').Value.ts32 := -6;
  cl.AddConstantN('crSizeNS', 'Integer').Value.ts32 := -7;
  cl.AddConstantN('crSizeNWSE', 'Integer').Value.ts32 := -8;
  cl.AddConstantN('crSizeWE', 'Integer').Value.ts32 := -9;
  cl.AddConstantN('crUpArrow', 'Integer').Value.ts32 := -10;
  cl.AddConstantN('crHourGlass', 'Integer').Value.ts32 := -11;
  cl.AddConstantN('crDrag', 'Integer').Value.ts32 := -12;
  cl.AddConstantN('crNoDrop', 'Integer').Value.ts32 := -13;
  cl.AddConstantN('crHSplit', 'Integer').Value.ts32 := -14;
  cl.AddConstantN('crVSplit', 'Integer').Value.ts32 := -15;
  cl.AddConstantN('crMultiDrag', 'Integer').Value.ts32 := -16;
  cl.AddConstantN('crSQLWait', 'Integer').Value.ts32 := -17;
  cl.AddConstantN('crNo', 'Integer').Value.ts32 := -18;
  cl.AddConstantN('crAppStart', 'Integer').Value.ts32 := -19;
  cl.AddConstantN('crHelp', 'Integer').Value.ts32 := -20;
{$IFDEF DELPHI3UP}
  cl.AddConstantN('crHandPoint', 'Integer').Value.ts32 := -21;
{$ENDIF}
{$IFDEF DELPHI4UP}
  cl.AddConstantN('crSizeAll', 'Integer').Value.ts32 := -22;
{$ENDIF}
end;

procedure SIRegisterTDragObject(cl: TPSPascalCompiler);
begin
  with CL.AddClassN(CL.FindClass('TObject'),'TDragObject') do
  begin
{$IFNDEF PS_MINIVCL}
{$IFDEF DELPHI4UP}
    RegisterMethod('Procedure Assign( Source : TDragObject)');
{$ENDIF}
{$IFNDEF FPC}
    RegisterMethod('Function GetName : String');
    RegisterMethod('Function Instance : Longint');
{$ENDIF}
    RegisterMethod('Procedure HideDragImage');
    RegisterMethod('Procedure ShowDragImage');
{$IFDEF DELPHI4UP}
    RegisterProperty('Cancelling', 'Boolean', iptrw);
    RegisterProperty('DragHandle', 'Longint', iptrw);
    RegisterProperty('DragPos', 'TPoint', iptrw);
    RegisterProperty('DragTargetPos', 'TPoint', iptrw);
    RegisterProperty('MouseDeltaX', 'Double', iptr);
    RegisterProperty('MouseDeltaY', 'Double', iptr);
{$ENDIF}
{$ENDIF}
  end;
  Cl.AddTypeS('TStartDragEvent', 'procedure (Sender: TObject; var DragObject: TDragObject)');
end;

procedure SIRegister_Controls(Cl: TPSPascalCompiler);
begin
  SIRegister_Controls_TypesAndConsts(cl);
  SIRegisterTDragObject(cl);
  SIRegisterTControl(Cl);
  SIRegisterTWinControl(Cl);
  SIRegisterTGraphicControl(cl);
  SIRegisterTCustomControl(cl);
end;

// PS_MINIVCL changes by Martijn Laan (mlaan at wintax _dot_ nl)

end.
