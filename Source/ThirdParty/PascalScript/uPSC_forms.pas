{ Compiletime Forms support }
unit uPSC_forms;
{$I PascalScript.inc}

interface
uses
  uPSCompiler, uPSUtils;

procedure SIRegister_Forms_TypesAndConsts(Cl: TPSPascalCompiler);


procedure SIRegisterTCONTROLSCROLLBAR(Cl: TPSPascalCompiler);
procedure SIRegisterTSCROLLINGWINCONTROL(Cl: TPSPascalCompiler);
procedure SIRegisterTSCROLLBOX(Cl: TPSPascalCompiler);
procedure SIRegisterTFORM(Cl: TPSPascalCompiler);
procedure SIRegisterTAPPLICATION(Cl: TPSPascalCompiler);

procedure SIRegister_Forms(Cl: TPSPascalCompiler);

implementation

procedure SIRegisterTCONTROLSCROLLBAR(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TPERSISTENT'), 'TCONTROLSCROLLBAR') do
  begin
    RegisterProperty('KIND', 'TSCROLLBARKIND', iptr);
    RegisterProperty('SCROLLPOS', 'INTEGER', iptr);
    RegisterProperty('MARGIN', 'WORD', iptrw);
    RegisterProperty('INCREMENT', 'TSCROLLBARINC', iptrw);
    RegisterProperty('RANGE', 'INTEGER', iptrw);
    RegisterProperty('POSITION', 'INTEGER', iptrw);
    RegisterProperty('TRACKING', 'BOOLEAN', iptrw);
    RegisterProperty('VISIBLE', 'BOOLEAN', iptrw);
  end;
end;

procedure SIRegisterTSCROLLINGWINCONTROL(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TWINCONTROL'), 'TSCROLLINGWINCONTROL') do
  begin
    RegisterMethod('procedure SCROLLINVIEW(ACONTROL:TCONTROL)');
    RegisterProperty('HORZSCROLLBAR', 'TCONTROLSCROLLBAR', iptrw);
    RegisterProperty('VERTSCROLLBAR', 'TCONTROLSCROLLBAR', iptrw);
  end;
end;

procedure SIRegisterTSCROLLBOX(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TSCROLLINGWINCONTROL'), 'TSCROLLBOX') do
  begin
    RegisterProperty('BORDERSTYLE', 'TBORDERSTYLE', iptrw);
    RegisterProperty('COLOR', 'TCOLOR', iptrw);
    RegisterProperty('FONT', 'TFONT', iptrw);                    
    RegisterProperty('AUTOSCROLL', 'BOOLEAN', iptrw);
    RegisterProperty('PARENTCOLOR', 'BOOLEAN', iptrw);
    RegisterProperty('PARENTFONT', 'BOOLEAN', iptrw);
    RegisterProperty('ONCLICK', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONDBLCLICK', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONENTER', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONEXIT', 'TNOTIFYEVENT', iptrw);

    {$IFNDEF PS_MINIVCL}
    RegisterProperty('ONRESIZE', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('DRAGCURSOR', 'TCURSOR', iptrw);
    RegisterProperty('DRAGMODE', 'TDRAGMODE', iptrw);
    RegisterProperty('PARENTSHOWHINT', 'BOOLEAN', iptrw);
    RegisterProperty('POPUPMENU', 'TPOPUPMENU', iptrw);
    RegisterProperty('CTL3D', 'BOOLEAN', iptrw);
    RegisterProperty('PARENTCTL3D', 'BOOLEAN', iptrw);
    RegisterProperty('ONDRAGDROP', 'TDRAGDROPEVENT', iptrw);
    RegisterProperty('ONDRAGOVER', 'TDRAGOVEREVENT', iptrw);
    RegisterProperty('ONENDDRAG', 'TENDDRAGEVENT', iptrw);
    RegisterProperty('ONMOUSEDOWN', 'TMOUSEEVENT', iptrw);
    RegisterProperty('ONMOUSEMOVE', 'TMOUSEMOVEEVENT', iptrw);
    RegisterProperty('ONMOUSEUP', 'TMOUSEEVENT', iptrw);
    {$ENDIF}
  end;
end;

procedure SIRegisterTFORM(Cl: TPSPascalCompiler);
begin
 with Cl.AddClassN(cl.FindClass('TSCROLLINGWINCONTROL'), 'TFORM') do
  begin
    {$IFDEF DELPHI4UP}
    RegisterMethod('constructor CREATENEW(AOWNER:TCOMPONENT; Dummy: Integer)');
    {$ELSE}
    RegisterMethod('constructor CREATENEW(AOWNER:TCOMPONENT)');
    {$ENDIF}
    RegisterMethod('procedure CLOSE');
    RegisterMethod('procedure HIDE');
    RegisterMethod('procedure SHOW');
    RegisterMethod('function SHOWMODAL:INTEGER');
    RegisterMethod('procedure RELEASE');
    RegisterProperty('ACTIVE', 'BOOLEAN', iptr);
    RegisterProperty('ACTIVECONTROL', 'TWINCONTROL', iptrw);
    RegisterProperty('BORDERICONS', 'TBorderIcons', iptrw);
    RegisterProperty('BORDERSTYLE', 'TFORMBORDERSTYLE', iptrw);
    RegisterProperty('CAPTION', 'NativeString', iptrw);
    RegisterProperty('AUTOSCROLL', 'BOOLEAN', iptrw);
    RegisterProperty('COLOR', 'TCOLOR', iptrw);
    RegisterProperty('FONT', 'TFONT', iptrw);
    RegisterProperty('FORMSTYLE', 'TFORMSTYLE', iptrw);
    RegisterProperty('KEYPREVIEW', 'BOOLEAN', iptrw);
    RegisterProperty('POSITION', 'TPOSITION', iptrw);
    RegisterProperty('ONACTIVATE', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONCLICK', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONDBLCLICK', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONCLOSE', 'TCLOSEEVENT', iptrw);
    RegisterProperty('ONCLOSEQUERY', 'TCLOSEQUERYEVENT', iptrw);
    RegisterProperty('ONCREATE', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONDESTROY', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONDEACTIVATE', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONHIDE', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONKEYDOWN', 'TKEYEVENT', iptrw);
    RegisterProperty('ONKEYPRESS', 'TKEYPRESSEVENT', iptrw);
    RegisterProperty('ONKEYUP', 'TKEYEVENT', iptrw);
    RegisterProperty('ONRESIZE', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONSHOW', 'TNOTIFYEVENT', iptrw);


    {$IFNDEF PS_MINIVCL}
    {$IFNDEF CLX}
    RegisterMethod('procedure ARRANGEICONS');
//    RegisterMethod('function GETFORMIMAGE:TBITMAP');
    RegisterMethod('procedure PRINT');
    RegisterMethod('procedure SENDCANCELMODE(SENDER:TCONTROL)');
    RegisterProperty('ACTIVEOLECONTROL', 'TWINCONTROL', iptrw);
    RegisterProperty('OLEFORMOBJECT', 'TOLEFORMOBJECT', iptrw);
    RegisterProperty('CLIENTHANDLE', 'LONGINT', iptr);
    RegisterProperty('TILEMODE', 'TTILEMODE', iptrw);
    {$ENDIF}
    RegisterMethod('procedure CASCADE');
    RegisterMethod('function CLOSEQUERY:BOOLEAN');
    RegisterMethod('procedure DEFOCUSCONTROL(CONTROL:TWINCONTROL;REMOVING:BOOLEAN)');
    RegisterMethod('procedure FOCUSCONTROL(CONTROL:TWINCONTROL)');
    RegisterMethod('procedure NEXT');
    RegisterMethod('procedure PREVIOUS');
    RegisterMethod('function SETFOCUSEDCONTROL(CONTROL:TWINCONTROL):BOOLEAN');
    RegisterMethod('procedure TILE');
    RegisterProperty('ACTIVEMDICHILD', 'TFORM', iptr);
    RegisterProperty('CANVAS', 'TCANVAS', iptr);
    RegisterProperty('DROPTARGET', 'BOOLEAN', iptrw);
    RegisterProperty('MODALRESULT', 'Longint', iptrw);
    RegisterProperty('MDICHILDCOUNT', 'INTEGER', iptr);
    RegisterProperty('MDICHILDREN', 'TFORM INTEGER', iptr);
    RegisterProperty('ICON', 'TICON', iptrw);
    RegisterProperty('MENU', 'TMAINMENU', iptrw);
    RegisterProperty('OBJECTMENUITEM', 'TMENUITEM', iptrw);
    RegisterProperty('PIXELSPERINCH', 'INTEGER', iptrw);
    RegisterProperty('PRINTSCALE', 'TPRINTSCALE', iptrw);
    RegisterProperty('SCALED', 'BOOLEAN', iptrw);
    RegisterProperty('WINDOWSTATE', 'TWINDOWSTATE', iptrw);
    RegisterProperty('WINDOWMENU', 'TMENUITEM', iptrw);
    RegisterProperty('CTL3D', 'BOOLEAN', iptrw);
    RegisterProperty('POPUPMENU', 'TPOPUPMENU', iptrw);
    RegisterProperty('ONDRAGDROP', 'TDRAGDROPEVENT', iptrw);
    RegisterProperty('ONDRAGOVER', 'TDRAGOVEREVENT', iptrw);
    RegisterProperty('ONMOUSEDOWN', 'TMOUSEEVENT', iptrw);
    RegisterProperty('ONMOUSEMOVE', 'TMOUSEMOVEEVENT', iptrw);
    RegisterProperty('ONMOUSEUP', 'TMOUSEEVENT', iptrw);
    RegisterProperty('ONPAINT', 'TNOTIFYEVENT', iptrw);
    {$ENDIF}
  end;
end;

procedure SIRegisterTAPPLICATION(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TCOMPONENT'), 'TAPPLICATION') do
  begin
    RegisterMethod('procedure BRINGTOFRONT');
{$IFDEF PS_PANSICHAR}
    RegisterMethod('function MESSAGEBOX(TEXT,CAPTION:PANSICHAR;FLAGS:WORD):INTEGER');
{$ELSE}
    RegisterMethod('function MESSAGEBOX(TEXT,CAPTION:PCHAR;FLAGS:WORD):INTEGER');
{$ENDIF}
    RegisterMethod('procedure MINIMIZE');
    RegisterMethod('procedure PROCESSMESSAGES');
    RegisterMethod('procedure RESTORE');
    RegisterMethod('procedure TERMINATE');
    RegisterProperty('ACTIVE', 'BOOLEAN', iptr);
    RegisterProperty('EXENAME', 'NativeString', iptr);
    {$IFNDEF CLX}
    RegisterProperty('HANDLE', 'LONGINT', iptrw);
    RegisterProperty('UPDATEFORMATSETTINGS', 'BOOLEAN', iptrw);
    {$ENDIF}
    RegisterProperty('HINT', 'NativeString', iptrw);
    RegisterProperty('MAINFORM', 'TFORM', iptr);
    RegisterProperty('SHOWHINT', 'BOOLEAN', iptrw);
    RegisterProperty('SHOWMAINFORM', 'BOOLEAN', iptrw);
    RegisterProperty('TERMINATED', 'BOOLEAN', iptr);
    RegisterProperty('TITLE', 'NativeString', iptrw);
    RegisterProperty('ONACTIVATE', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONDEACTIVATE', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONIDLE', 'TIDLEEVENT', iptrw);
    RegisterProperty('ONHINT', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONMINIMIZE', 'TNOTIFYEVENT', iptrw);
    RegisterProperty('ONRESTORE', 'TNOTIFYEVENT', iptrw);

    {$IFNDEF PS_MINIVCL}
    RegisterMethod('procedure CONTROLDESTROYED(CONTROL:TCONTROL)');
    RegisterMethod('procedure CANCELHINT');
    RegisterMethod('procedure HANDLEEXCEPTION(SENDER:TOBJECT)');
    RegisterMethod('procedure HANDLEMESSAGE');
    RegisterMethod('procedure HIDEHINT');
//    RegisterMethod('procedure HINTMOUSEMESSAGE(CONTROL:TCONTROL;var MESSAGE:TMESSAGE)');
    RegisterMethod('procedure INITIALIZE');
    RegisterMethod('procedure NORMALIZETOPMOSTS');
    RegisterMethod('procedure RESTORETOPMOSTS');
    RegisterMethod('procedure RUN');
//    RegisterMethod('procedure SHOWEXCEPTION(E:EXCEPTION)');
    {$IFNDEF CLX}
    RegisterMethod('function HELPCOMMAND(COMMAND:INTEGER;DATA:LONGINT):BOOLEAN');
    RegisterMethod('function HELPCONTEXT(CONTEXT:THELPCONTEXT):BOOLEAN');
    RegisterMethod('function HELPJUMP(JUMPID:NativeString):BOOLEAN');
    RegisterProperty('DIALOGHANDLE', 'LONGINT', iptrw);
    RegisterMethod('procedure CREATEHANDLE');
//    RegisterMethod('procedure HOOKMAINWINDOW(HOOK:TWINDOWHOOK)');
//    RegisterMethod('procedure UNHOOKMAINWINDOW(HOOK:TWINDOWHOOK)');
    {$ENDIF}
    RegisterProperty('HELPFILE', 'NativeString', iptrw);
    RegisterProperty('HINTCOLOR', 'TCOLOR', iptrw);
    RegisterProperty('HINTPAUSE', 'INTEGER', iptrw);
    RegisterProperty('HINTSHORTPAUSE', 'INTEGER', iptrw);
    RegisterProperty('HINTHIDEPAUSE', 'INTEGER', iptrw);
    RegisterProperty('ICON', 'TICON', iptrw);
    RegisterProperty('ONHELP', 'THELPEVENT', iptrw);
    {$ENDIF}
  end;
end;

procedure SIRegister_Forms_TypesAndConsts(Cl: TPSPascalCompiler);
begin
  Cl.AddTypeS('TIdleEvent', 'procedure (Sender: TObject; var Done: Boolean)');
  cl.AddTypeS('TScrollBarKind', '(sbHorizontal, sbVertical)');
  cl.AddTypeS('TScrollBarInc', 'SmallInt');
  cl.AddTypeS('TFormBorderStyle', '(bsNone, bsSingle, bsSizeable, bsDialog, bsToolWindow, bsSizeToolWin)');
  cl.AddTypeS('TBorderStyle', 'TFormBorderStyle');
  cl.AddTypeS('TWindowState', '(wsNormal, wsMinimized, wsMaximized)');
  cl.AddTypeS('TFormStyle', '(fsNormal, fsMDIChild, fsMDIForm, fsStayOnTop)');
  cl.AddTypeS('TPosition', '(poDesigned, poDefault, poDefaultPosOnly, poDefaultSizeOnly, poScreenCenter, poDesktopCenter, poMainFormCenter, poOwnerFormCenter)');
  cl.AddTypeS('TPrintScale', '(poNone, poProportional, poPrintToFit)');
  cl.AddTypeS('TCloseAction', '(caNone, caHide, caFree, caMinimize)');
  cl.AddTypeS('TCloseEvent' ,'procedure(Sender: TObject; var Action: TCloseAction)');
  cl.AddTypeS('TCloseQueryEvent' ,'procedure(Sender: TObject; var CanClose: Boolean)');
  cl.AddTypeS('TBorderIcon' ,'(biSystemMenu, biMinimize, biMaximize, biHelp)');
  cl.AddTypeS('TBorderIcons', 'set of TBorderIcon');
  cl.AddTypeS('THELPCONTEXT', 'Longint');
end;

procedure SIRegister_Forms(Cl: TPSPascalCompiler);
begin
  SIRegister_Forms_TypesAndConsts(cl);

  {$IFNDEF PS_MINIVCL}
  SIRegisterTCONTROLSCROLLBAR(cl);
  {$ENDIF}
  SIRegisterTScrollingWinControl(cl);
  {$IFNDEF PS_MINIVCL}
  SIRegisterTSCROLLBOX(cl);
  {$ENDIF}
  SIRegisterTForm(Cl);
  {$IFNDEF PS_MINIVCL}
  SIRegisterTApplication(Cl);
  {$ENDIF}
end;

// PS_MINIVCL changes by Martijn Laan (mlaan at wintax _dot_ nl)


end.

