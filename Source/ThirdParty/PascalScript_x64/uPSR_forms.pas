
unit uPSR_forms;

{$I PascalScript.inc}
interface
uses
  uPSRuntime, uPSUtils;

procedure RIRegisterTCONTROLSCROLLBAR(Cl: TPSRuntimeClassImporter);
{$IFNDEF FPC} procedure RIRegisterTSCROLLINGWINCONTROL(Cl: TPSRuntimeClassImporter);{$ENDIF}
procedure RIRegisterTSCROLLBOX(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTFORM(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTAPPLICATION(Cl: TPSRuntimeClassImporter);

procedure RIRegister_Forms(Cl: TPSRuntimeClassImporter);

implementation
uses
  sysutils, classes, {$IFDEF CLX}QControls, QForms, QGraphics{$ELSE}Controls, Forms, Graphics{$ENDIF};

{$IFDEF DELPHI10UP}{$REGION 'TControlScrollBar'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TControlScrollBar_PSHelper = class helper for TControlScrollBar
  public
    procedure KIND_R(var T: TSCROLLBARKIND);
    procedure SCROLLPOS_R(var T: INTEGER);
  end;

procedure  TControlScrollBar_PSHelper.KIND_R(var T: TSCROLLBARKIND); begin T := Self.KIND; end;
procedure  TControlScrollBar_PSHelper.SCROLLPOS_R(var T: INTEGER); begin t := Self.SCROLLPOS; end;

procedure RIRegisterTCONTROLSCROLLBAR(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TControlScrollBar) do
  begin
    RegisterPropertyHelper(@TControlScrollBar.KIND_R, nil, 'Kind');
    RegisterPropertyHelper(@TControlScrollBar.SCROLLPOS_R, nil, 'ScrollPos');
  end;
end;

{$ELSE}
procedure TCONTROLSCROLLBARKIND_R(Self: TCONTROLSCROLLBAR; var T: TSCROLLBARKIND); begin T := Self.KIND; end;
procedure TCONTROLSCROLLBARSCROLLPOS_R(Self: TCONTROLSCROLLBAR; var T: INTEGER); begin t := Self.SCROLLPOS; end;

procedure RIRegisterTCONTROLSCROLLBAR(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TControlScrollBar) do
  begin
    RegisterPropertyHelper(@TCONTROLSCROLLBARKIND_R, nil, 'Kind');
    RegisterPropertyHelper(@TCONTROLSCROLLBARSCROLLPOS_R, nil, 'ScrollPos');
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TScrollingWinControl'}{$ENDIF}
{$IFNDEF FPC}
procedure RIRegisterTSCROLLINGWINCONTROL(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TScrollingWinControl) do
  begin
    RegisterMethod(@TSCROLLINGWINCONTROL.SCROLLINVIEW, 'ScrollInView');
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TScrollBox'}{$ENDIF}
procedure RIRegisterTSCROLLBOX(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TScrollBox);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TForm'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TForm_PSHelper = class helper for TForm
  public
    {$IFNDEF FPC}
    {$IFNDEF CLX}
    procedure ACTIVEOLECONTROL_W(T: TWINCONTROL);
    procedure ACTIVEOLECONTROL_R(var T: TWINCONTROL);
    procedure TILEMODE_W(T: TTILEMODE);
    procedure TILEMODE_R(var T: TTILEMODE);
    {$ENDIF}{CLX}
    procedure ACTIVEMDICHILD_R(var T: TFORM);
    procedure DROPTARGET_W(T: BOOLEAN);
    procedure DROPTARGET_R(var T: BOOLEAN);
    procedure MDICHILDCOUNT_R(var T: INTEGER);
    procedure MDICHILDREN_R(var T: TFORM; t1: INTEGER);
    {$ENDIF}{FPC}

    procedure MODALRESULT_W(T: TMODALRESULT);
    procedure MODALRESULT_R(var T: TMODALRESULT);
    procedure ACTIVE_R(var T: BOOLEAN);
    procedure CANVAS_R(var T: TCANVAS);
    {$IFNDEF CLX}
    procedure CLIENTHANDLE_R(var T: Longint);
    {$ENDIF}
  end;

{$IFNDEF FPC}
{$IFNDEF CLX}
procedure TForm_PSHelper.ACTIVEOLECONTROL_W(T: TWINCONTROL); begin Self.ACTIVEOLECONTROL := T; end;
procedure TForm_PSHelper.ACTIVEOLECONTROL_R(var T: TWINCONTROL); begin T := Self.ACTIVEOLECONTROL;
end;
procedure TForm_PSHelper.TILEMODE_W(T: TTILEMODE); begin Self.TILEMODE := T; end;
procedure TForm_PSHelper.TILEMODE_R(var T: TTILEMODE); begin T := Self.TILEMODE; end;
{$ENDIF}{CLX}
procedure TForm_PSHelper.ACTIVEMDICHILD_R(var T: TFORM); begin T := Self.ACTIVEMDICHILD; end;
procedure TForm_PSHelper.DROPTARGET_W(T: BOOLEAN); begin Self.DROPTARGET := T; end;
procedure TForm_PSHelper.DROPTARGET_R(var T: BOOLEAN); begin T := Self.DROPTARGET; end;
procedure TForm_PSHelper.MDICHILDCOUNT_R(var T: INTEGER); begin T := Self.MDICHILDCOUNT; end;
procedure TForm_PSHelper.MDICHILDREN_R(var T: TFORM; t1: INTEGER); begin T := Self.MDICHILDREN[T1];
end;
{$ENDIF}{FPC}

procedure TForm_PSHelper.MODALRESULT_W(T: TMODALRESULT); begin Self.MODALRESULT := T; end;
procedure TForm_PSHelper.MODALRESULT_R(var T: TMODALRESULT); begin T := Self.MODALRESULT; end;
procedure TForm_PSHelper.ACTIVE_R(var T: BOOLEAN); begin T := Self.ACTIVE; end;
procedure TForm_PSHelper.CANVAS_R(var T: TCANVAS); begin T := Self.CANVAS; end;
{$IFNDEF CLX}
procedure TForm_PSHelper.CLIENTHANDLE_R(var T: Longint); begin T := Self.CLIENTHANDLE; end;
{$ENDIF}

{ Innerfuse Pascal Script Class Import Utility (runtime) }

procedure RIRegisterTFORM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TForm) do
  begin
    {$IFDEF DELPHI4UP}
    RegisterVirtualConstructor(@TForm.CREATENEW, 'CreateNew');
    {$ELSE}
    RegisterConstructor(@TForm.CREATENEW, 'CreateNew');
    {$ENDIF}
    RegisterMethod(@TForm.CLOSE, 'Close');
    RegisterMethod(@TForm.HIDE, 'Hide');
    RegisterMethod(@TForm.SHOW, 'Show');
    RegisterMethod(@TForm.SHOWMODAL, 'ShowModal');
    RegisterMethod(@TForm.RELEASE, 'Release');
    RegisterPropertyHelper(@TForm.ACTIVE_R, nil, 'Active');

    {$IFNDEF PS_MINIVCL}
 {$IFNDEF FPC}
{$IFNDEF CLX}
    RegisterMethod(@TForm.ARRANGEICONS, 'ArrangeIcons');
    RegisterMethod(@TForm.GETFORMIMAGE, 'GetFormImage');
    RegisterMethod(@TForm.PRINT, 'Print');
    RegisterMethod(@TForm.SENDCANCELMODE, 'SendCancelMode');
    RegisterPropertyHelper(@TForm.ACTIVEOLECONTROL_R, @TForm.ACTIVEOLECONTROL_W, 'ActiveOleControl');
    RegisterPropertyHelper(@TForm.CLIENTHANDLE_R, nil, 'ClientHandle');
    RegisterPropertyHelper(@TForm.TILEMODE_R, @TForm.TILEMODE_W, 'TileMode');
{$ENDIF}{CLX}
    RegisterMethod(@TForm.CASCADE, 'Cascade');
    RegisterMethod(@TForm.NEXT, 'Next');
    RegisterMethod(@TForm.PREVIOUS, 'Previous');
    RegisterMethod(@TForm.TILE, 'Tile');
    RegisterPropertyHelper(@TForm.ACTIVEMDICHILD_R, nil, 'ActiveMDIChild');
    RegisterPropertyHelper(@TForm.DROPTARGET_R, @TForm.DROPTARGET_W, 'DropTarget');
    RegisterPropertyHelper(@TForm.MDICHILDCOUNT_R, nil, 'MDIChildCount');
    RegisterPropertyHelper(@TForm.MDICHILDREN_R, nil, 'MDIChildren');
 {$ENDIF}{FPC}
    RegisterMethod(@TForm.CLOSEQUERY, 'CloseQuery');
    RegisterMethod(@TForm.DEFOCUSCONTROL, 'DefocusControl');
    RegisterMethod(@TForm.FOCUSCONTROL, 'FocusControl');
    RegisterMethod(@TForm.SETFOCUSEDCONTROL, 'SetFocusedControl');
    RegisterPropertyHelper(@TForm.CANVAS_R, nil, 'Canvas');
    RegisterPropertyHelper(@TForm.MODALRESULT_R, @TForm.MODALRESULT_W, 'ModalResult');
    {$ENDIF}{PS_MINIVCL}
  end;
end;

{$ELSE}
{$IFNDEF FPC}
{$IFNDEF CLX}
procedure TFORMACTIVEOLECONTROL_W(Self: TForm; T: TWINCONTROL); begin Self.ACTIVEOLECONTROL := T; end;
procedure TFORMACTIVEOLECONTROL_R(Self: TFORM; var T: TWINCONTROL); begin T := Self.ACTIVEOLECONTROL;
end;
procedure TFORMTILEMODE_W(Self: TFORM; T: TTILEMODE); begin Self.TILEMODE := T; end;
procedure TFORMTILEMODE_R(Self: TFORM; var T: TTILEMODE); begin T := Self.TILEMODE; end;
{$ENDIF}{CLX}
procedure TFORMACTIVEMDICHILD_R(Self: TFORM; var T: TFORM); begin T := Self.ACTIVEMDICHILD; end;
procedure TFORMDROPTARGET_W(Self: TFORM; T: BOOLEAN); begin Self.DROPTARGET := T; end;
procedure TFORMDROPTARGET_R(Self: TFORM; var T: BOOLEAN); begin T := Self.DROPTARGET; end;
procedure TFORMMDICHILDCOUNT_R(Self: TFORM; var T: INTEGER); begin T := Self.MDICHILDCOUNT; end;
procedure TFORMMDICHILDREN_R(Self: TFORM; var T: TFORM; t1: INTEGER); begin T := Self.MDICHILDREN[T1];
end;
{$ENDIF}{FPC}

procedure TFORMMODALRESULT_W(Self: TFORM; T: TMODALRESULT); begin Self.MODALRESULT := T; end;
procedure TFORMMODALRESULT_R(Self: TFORM; var T: TMODALRESULT); begin T := Self.MODALRESULT; end;
procedure TFORMACTIVE_R(Self: TFORM; var T: BOOLEAN); begin T := Self.ACTIVE; end;
procedure TFORMCANVAS_R(Self: TFORM; var T: TCANVAS); begin T := Self.CANVAS; end;
{$IFNDEF CLX}
procedure TFORMCLIENTHANDLE_R(Self: TFORM; var T: Longint); begin T := Self.CLIENTHANDLE; end;
{$ENDIF}

{ Innerfuse Pascal Script Class Import Utility (runtime) }

procedure RIRegisterTFORM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TFORM) do
  begin
    {$IFDEF DELPHI4UP}
    RegisterVirtualConstructor(@TFORM.CREATENEW, 'CreateNew');
    {$ELSE}
    RegisterConstructor(@TFORM.CREATENEW, 'CreateNew');
    {$ENDIF}
    RegisterMethod(@TFORM.CLOSE, 'Close');
    RegisterMethod(@TFORM.HIDE, 'Hide');
    RegisterMethod(@TFORM.SHOW, 'Show');
    {$IFDEF DELPHI_SEATTLE_UP}
    RegisterVirtualMethod(@TFORM.SHOWMODAL, 'ShowModal');
    {$ELSE}
    RegisterMethod(@TFORM.SHOWMODAL, 'ShowModal');
    {$ENDIF}
    RegisterMethod(@TFORM.RELEASE, 'Release');
    RegisterPropertyHelper(@TFORMACTIVE_R, nil, 'Active');

    {$IFNDEF PS_MINIVCL}
 {$IFNDEF FPC}
{$IFNDEF CLX}
    RegisterMethod(@TFORM.ARRANGEICONS, 'ArrangeIcons');
    RegisterMethod(@TFORM.GETFORMIMAGE, 'GetFormImage');
    RegisterMethod(@TFORM.PRINT, 'Print');
    RegisterMethod(@TFORM.SENDCANCELMODE, 'SendCancelMode');
    RegisterPropertyHelper(@TFORMACTIVEOLECONTROL_R, @TFORMACTIVEOLECONTROL_W, 'ActiveOleControl');
    RegisterPropertyHelper(@TFORMCLIENTHANDLE_R, nil, 'ClientHandle');
    RegisterPropertyHelper(@TFORMTILEMODE_R, @TFORMTILEMODE_W, 'TileMode');
{$ENDIF}{CLX}
    RegisterMethod(@TFORM.CASCADE, 'Cascade');
    RegisterMethod(@TFORM.NEXT, 'Next');
    RegisterMethod(@TFORM.PREVIOUS, 'Previous');
    RegisterMethod(@TFORM.TILE, 'Tile');
    RegisterPropertyHelper(@TFORMACTIVEMDICHILD_R, nil, 'ActiveMDIChild');
    RegisterPropertyHelper(@TFORMDROPTARGET_R, @TFORMDROPTARGET_W, 'DropTarget');
    RegisterPropertyHelper(@TFORMMDICHILDCOUNT_R, nil, 'MDIChildCount');
    RegisterPropertyHelper(@TFORMMDICHILDREN_R, nil, 'MDIChildren');
 {$ENDIF}{FPC}
    RegisterMethod(@TFORM.CLOSEQUERY, 'CloseQuery');
    RegisterMethod(@TFORM.DEFOCUSCONTROL, 'DefocusControl');
    RegisterMethod(@TFORM.FOCUSCONTROL, 'FocusControl');
    RegisterMethod(@TFORM.SETFOCUSEDCONTROL, 'SetFocusedControl');
    RegisterPropertyHelper(@TFORMCANVAS_R, nil, 'Canvas');
    RegisterPropertyHelper(@TFORMMODALRESULT_R, @TFORMMODALRESULT_W, 'ModalResult');
    {$ENDIF}{PS_MINIVCL}
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TApplication'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TApplication_PSHelper = class helper for TApplication
  public
    {$IFNDEF FPC}
    procedure ACTIVE_R(var T: BOOLEAN);
    {$IFNDEF CLX}
    procedure DIALOGHANDLE_R(var T: Longint);
    procedure DIALOGHANDLE_W(T: Longint);
    procedure HANDLE_R(var T: Longint);
    procedure HANDLE_W(T: Longint);
    procedure UPDATEFORMATSETTINGS_R(var T: BOOLEAN);
    procedure UPDATEFORMATSETTINGS_W(T: BOOLEAN);
    {$ENDIF}
    {$ENDIF}{FPC}


    procedure EXENAME_R(var T: STRING);
    procedure HELPFILE_R(var T: STRING);
    procedure HELPFILE_W(T: STRING);
    procedure HINT_R(var T: STRING);
    procedure HINT_W(T: STRING);
    procedure HINTCOLOR_R(var T: TCOLOR);
    procedure HINTCOLOR_W(T: TCOLOR);
    procedure HINTPAUSE_R(var T: INTEGER);
    procedure HINTPAUSE_W(T: INTEGER);
    procedure HINTSHORTPAUSE_R(var T: INTEGER);
    procedure HINTSHORTPAUSE_W(T: INTEGER);
    procedure HINTHIDEPAUSE_R(var T: INTEGER);
    procedure HINTHIDEPAUSE_W(T: INTEGER);
    procedure MAINFORM_R(var T: {$IFDEF DELPHI3UP}TCustomForm{$ELSE}TFORM{$ENDIF});
    procedure SHOWHINT_R(var T: BOOLEAN);
    procedure SHOWHINT_W(T: BOOLEAN);
    procedure SHOWMAINFORM_R(var T: BOOLEAN);
    procedure SHOWMAINFORM_W(T: BOOLEAN);
    procedure TERMINATED_R(var T: BOOLEAN);
    procedure TITLE_R(var T: STRING);
    procedure TITLE_W(T: STRING);

    {$IFNDEF FPC}
    procedure ONACTIVATE_R(var T: TNOTIFYEVENT);
    procedure ONACTIVATE_W(T: TNOTIFYEVENT);
    procedure ONDEACTIVATE_R(var T: TNOTIFYEVENT);
    procedure ONDEACTIVATE_W(T: TNOTIFYEVENT);
    {$ENDIF}

    procedure ONIDLE_R(var T: TIDLEEVENT);
    procedure ONIDLE_W(T: TIDLEEVENT);
    procedure ONHELP_R(var T: THELPEVENT);
    procedure ONHELP_W(T: THELPEVENT);
    procedure ONHINT_R(var T: TNOTIFYEVENT);
    procedure ONHINT_W(T: TNOTIFYEVENT);

    {$IFNDEF FPC}
    procedure ONMINIMIZE_R(var T: TNOTIFYEVENT);
    procedure ONMINIMIZE_W(T: TNOTIFYEVENT);

    procedure ONRESTORE_R(var T: TNOTIFYEVENT);
    procedure ONRESTORE_W(T: TNOTIFYEVENT);
    {$ENDIF}
  end;

{$IFNDEF FPC}
procedure TApplication_PSHelper.ACTIVE_R(var T: BOOLEAN); begin T := Self.ACTIVE; end;
{$IFNDEF CLX}
procedure TApplication_PSHelper.DIALOGHANDLE_R(var T: Longint); begin T := Self.DIALOGHANDLE; end;
procedure TApplication_PSHelper.DIALOGHANDLE_W(T: Longint); begin Self.DIALOGHANDLE := T; end;
procedure TApplication_PSHelper.HANDLE_R(var T: Longint); begin T := Self.HANDLE; end;
procedure TApplication_PSHelper.HANDLE_W(T: Longint); begin Self.HANDLE := T; end;
procedure TApplication_PSHelper.UPDATEFORMATSETTINGS_R(var T: BOOLEAN); begin T := Self.UPDATEFORMATSETTINGS; end;
procedure TApplication_PSHelper.UPDATEFORMATSETTINGS_W(T: BOOLEAN); begin Self.UPDATEFORMATSETTINGS := T; end;
{$ENDIF}
{$ENDIF}{FPC}


procedure TApplication_PSHelper.EXENAME_R(var T: STRING); begin T := Self.EXENAME; end;
procedure TApplication_PSHelper.HELPFILE_R(var T: STRING); begin T := Self.HELPFILE; end;
procedure TApplication_PSHelper.HELPFILE_W(T: STRING); begin Self.HELPFILE := T; end;
procedure TApplication_PSHelper.HINT_R(var T: STRING); begin T := Self.HINT; end;
procedure TApplication_PSHelper.HINT_W(T: STRING); begin Self.HINT := T; end;
procedure TApplication_PSHelper.HINTCOLOR_R(var T: TCOLOR); begin T := Self.HINTCOLOR; end;
procedure TApplication_PSHelper.HINTCOLOR_W(T: TCOLOR); begin Self.HINTCOLOR := T; end;
procedure TApplication_PSHelper.HINTPAUSE_R(var T: INTEGER); begin T := Self.HINTPAUSE; end;
procedure TApplication_PSHelper.HINTPAUSE_W(T: INTEGER); begin Self.HINTPAUSE := T; end;
procedure TApplication_PSHelper.HINTSHORTPAUSE_R(var T: INTEGER); begin T := Self.HINTSHORTPAUSE; end;
procedure TApplication_PSHelper.HINTSHORTPAUSE_W(T: INTEGER); begin Self.HINTSHORTPAUSE := T; end;
procedure TApplication_PSHelper.HINTHIDEPAUSE_R(var T: INTEGER); begin T := Self.HINTHIDEPAUSE; end;
procedure TApplication_PSHelper.HINTHIDEPAUSE_W(T: INTEGER); begin Self.HINTHIDEPAUSE := T; end;
procedure TApplication_PSHelper.MAINFORM_R(var T: {$IFDEF DELPHI3UP}TCustomForm{$ELSE}TFORM{$ENDIF}); begin T := Self.MAINFORM; end;
procedure TApplication_PSHelper.SHOWHINT_R(var T: BOOLEAN); begin T := Self.SHOWHINT; end;
procedure TApplication_PSHelper.SHOWHINT_W(T: BOOLEAN); begin Self.SHOWHINT := T; end;
procedure TApplication_PSHelper.SHOWMAINFORM_R(var T: BOOLEAN); begin T := Self.SHOWMAINFORM; end;
procedure TApplication_PSHelper.SHOWMAINFORM_W(T: BOOLEAN); begin Self.SHOWMAINFORM := T; end;
procedure TApplication_PSHelper.TERMINATED_R(var T: BOOLEAN); begin T := Self.TERMINATED; end;
procedure TApplication_PSHelper.TITLE_R(var T: STRING); begin T := Self.TITLE; end;
procedure TApplication_PSHelper.TITLE_W(T: STRING); begin Self.TITLE := T; end;

{$IFNDEF FPC}
procedure TApplication_PSHelper.ONACTIVATE_R(var T: TNOTIFYEVENT); begin T := Self.ONACTIVATE; end;
procedure TApplication_PSHelper.ONACTIVATE_W(T: TNOTIFYEVENT); begin Self.ONACTIVATE := T; end;
procedure TApplication_PSHelper.ONDEACTIVATE_R(var T: TNOTIFYEVENT); begin T := Self.ONDEACTIVATE; end;
procedure TApplication_PSHelper.ONDEACTIVATE_W(T: TNOTIFYEVENT); begin Self.ONDEACTIVATE := T; end;
{$ENDIF}

procedure TApplication_PSHelper.ONIDLE_R(var T: TIDLEEVENT); begin T := Self.ONIDLE; end;
procedure TApplication_PSHelper.ONIDLE_W(T: TIDLEEVENT); begin Self.ONIDLE := T; end;
procedure TApplication_PSHelper.ONHELP_R(var T: THELPEVENT); begin T := Self.ONHELP; end;
procedure TApplication_PSHelper.ONHELP_W(T: THELPEVENT); begin Self.ONHELP := T; end;
procedure TApplication_PSHelper.ONHINT_R(var T: TNOTIFYEVENT); begin T := Self.ONHINT; end;
procedure TApplication_PSHelper.ONHINT_W(T: TNOTIFYEVENT); begin Self.ONHINT := T; end;

{$IFNDEF FPC}
procedure TApplication_PSHelper.ONMINIMIZE_R(var T: TNOTIFYEVENT); begin T := Self.ONMINIMIZE; end;
procedure TApplication_PSHelper.ONMINIMIZE_W(T: TNOTIFYEVENT); begin Self.ONMINIMIZE := T; end;

procedure TApplication_PSHelper.ONRESTORE_R(var T: TNOTIFYEVENT); begin T := Self.ONRESTORE; end;
procedure TApplication_PSHelper.ONRESTORE_W(T: TNOTIFYEVENT); begin Self.ONRESTORE := T; end;
{$ENDIF}

procedure RIRegisterTAPPLICATION(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TApplication) do
  begin
 {$IFNDEF FPC}
    RegisterMethod(@TApplication.MINIMIZE, 'Minimize');
    RegisterMethod(@TApplication.RESTORE, 'Restore');
    RegisterPropertyHelper(@TApplication.ACTIVE_R, nil, 'Active');
    RegisterPropertyHelper(@TApplication.ONACTIVATE_R, @TApplication.ONACTIVATE_W, 'OnActivate');
    RegisterPropertyHelper(@TApplication.ONDEACTIVATE_R, @TApplication.ONDEACTIVATE_W, 'OnDeactivate');
    RegisterPropertyHelper(@TApplication.ONMINIMIZE_R, @TApplication.ONMINIMIZE_W, 'OnMinimize');
    RegisterPropertyHelper(@TApplication.ONRESTORE_R, @TApplication.ONRESTORE_W, 'OnRestore');
    RegisterPropertyHelper(@TApplication.DIALOGHANDLE_R, @TApplication.DIALOGHANDLE_W, 'DialogHandle');
    RegisterMethod(@TApplication.CREATEHANDLE, 'CreateHandle');
    RegisterMethod(@TApplication.NORMALIZETOPMOSTS, 'NormalizeTopMosts');
    RegisterMethod(@TApplication.RESTORETOPMOSTS, 'RestoreTopMosts');
    {$IFNDEF CLX}
    RegisterPropertyHelper(@TApplication.HANDLE_R, @TApplication.HANDLE_W, 'Handle');
    RegisterPropertyHelper(@TApplication.UPDATEFORMATSETTINGS_R, @TApplication.UPDATEFORMATSETTINGS_W, 'UpdateFormatSettings');
    {$ENDIF}
 {$ENDIF}
    RegisterMethod(@TApplication.BRINGTOFRONT, 'BringToFront');
    RegisterMethod(@TApplication.MESSAGEBOX, 'MessageBox');
    RegisterMethod(@TApplication.PROCESSMESSAGES, 'ProcessMessages');
    RegisterMethod(@TApplication.TERMINATE, 'Terminate');
    RegisterPropertyHelper(@TApplication.EXENAME_R, nil, 'ExeName');
    RegisterPropertyHelper(@TApplication.HINT_R, @TApplication.HINT_W, 'Hint');
    RegisterPropertyHelper(@TApplication.MAINFORM_R, nil, 'MainForm');
    RegisterPropertyHelper(@TApplication.SHOWHINT_R, @TApplication.SHOWHINT_W, 'ShowHint');
    RegisterPropertyHelper(@TApplication.SHOWMAINFORM_R, @TApplication.SHOWMAINFORM_W, 'ShowMainForm');
    RegisterPropertyHelper(@TApplication.TERMINATED_R, nil, 'Terminated');
    RegisterPropertyHelper(@TApplication.TITLE_R, @TApplication.TITLE_W, 'Title');
    RegisterPropertyHelper(@TApplication.ONIDLE_R, @TApplication.ONIDLE_W, 'OnIdle');
    RegisterPropertyHelper(@TApplication.ONHINT_R, @TApplication.ONHINT_W, 'OnHint');
    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TApplication.CONTROLDESTROYED, 'ControlDestroyed');
    RegisterMethod(@TApplication.CANCELHINT, 'CancelHint');
    {$IFNDEF CLX}
    {$IFNDEF FPC}
    RegisterMethod(@TApplication.HELPCOMMAND, 'HelpCommand');
    {$ENDIF}
    RegisterMethod(@TApplication.HELPCONTEXT, 'HelpContext');
    {$IFNDEF FPC}
    RegisterMethod(@TApplication.HELPJUMP, 'HelpJump');
    {$ENDIF}
    {$ENDIF}
//    RegisterMethod(@TApplication.HANDLEEXCEPTION, 'HandleException');
//    RegisterMethod(@TApplication.HOOKMAINWINDOW, 'HookMainWindow');
//    RegisterMethod(@TApplication.UNHOOKMAINWINDOW, 'UnhookMainWindow');

    RegisterMethod(@TApplication.HANDLEMESSAGE, 'HandleMessage');
    RegisterMethod(@TApplication.HIDEHINT, 'HideHint');
    RegisterMethod(@TApplication.HINTMOUSEMESSAGE, 'HintMouseMessage');
    RegisterMethod(@TApplication.INITIALIZE, 'Initialize');
    RegisterMethod(@TApplication.RUN, 'Run');
//    RegisterMethod(@TApplication.SHOWEXCEPTION, 'ShowException');
    RegisterPropertyHelper(@TApplication.HELPFILE_R, @TApplication.HELPFILE_W, 'HelpFile');
    RegisterPropertyHelper(@TApplication.HINTCOLOR_R, @TApplication.HINTCOLOR_W, 'HintColor');
    RegisterPropertyHelper(@TApplication.HINTPAUSE_R, @TApplication.HINTPAUSE_W, 'HintPause');
    RegisterPropertyHelper(@TApplication.HINTSHORTPAUSE_R, @TApplication.HINTSHORTPAUSE_W, 'HintShortPause');
    RegisterPropertyHelper(@TApplication.HINTHIDEPAUSE_R, @TApplication.HINTHIDEPAUSE_W, 'HintHidePause');
    RegisterPropertyHelper(@TApplication.ONHELP_R, @TApplication.ONHELP_W, 'OnHelp');
    {$ENDIF}
  end;
end;

{$ELSE}
{$IFNDEF FPC}
procedure TAPPLICATIONACTIVE_R(Self: TApplication; var T: BOOLEAN); begin T := Self.ACTIVE; end;
{$IFNDEF CLX}
procedure TAPPLICATIONDIALOGHANDLE_R(Self: TAPPLICATION; var T: Longint); begin T := Self.DIALOGHANDLE; end;
procedure TAPPLICATIONDIALOGHANDLE_W(Self: TAPPLICATION; T: Longint); begin Self.DIALOGHANDLE := T; end;
procedure TAPPLICATIONHANDLE_R(Self: TAPPLICATION; var T: Longint); begin T := Self.HANDLE; end;
procedure TAPPLICATIONHANDLE_W(Self: TAPPLICATION; T: Longint); begin Self.HANDLE := T; end;
procedure TAPPLICATIONUPDATEFORMATSETTINGS_R(Self: TAPPLICATION; var T: BOOLEAN); begin T := Self.UPDATEFORMATSETTINGS; end;
procedure TAPPLICATIONUPDATEFORMATSETTINGS_W(Self: TAPPLICATION; T: BOOLEAN); begin Self.UPDATEFORMATSETTINGS := T; end;
{$ENDIF}
{$ENDIF}{FPC}


procedure TAPPLICATIONEXENAME_R(Self: TAPPLICATION; var T: STRING); begin T := Self.EXENAME; end;
procedure TAPPLICATIONHELPFILE_R(Self: TAPPLICATION; var T: STRING); begin T := Self.HELPFILE; end;
procedure TAPPLICATIONHELPFILE_W(Self: TAPPLICATION; T: STRING); begin Self.HELPFILE := T; end;
procedure TAPPLICATIONHINT_R(Self: TAPPLICATION; var T: STRING); begin T := Self.HINT; end;
procedure TAPPLICATIONHINT_W(Self: TAPPLICATION; T: STRING); begin Self.HINT := T; end;
procedure TAPPLICATIONHINTCOLOR_R(Self: TAPPLICATION; var T: TCOLOR); begin T := Self.HINTCOLOR; end;
procedure TAPPLICATIONHINTCOLOR_W(Self: TAPPLICATION; T: TCOLOR); begin Self.HINTCOLOR := T; end;
procedure TAPPLICATIONHINTPAUSE_R(Self: TAPPLICATION; var T: INTEGER); begin T := Self.HINTPAUSE; end;
procedure TAPPLICATIONHINTPAUSE_W(Self: TAPPLICATION; T: INTEGER); begin Self.HINTPAUSE := T; end;
procedure TAPPLICATIONHINTSHORTPAUSE_R(Self: TAPPLICATION; var T: INTEGER); begin T := Self.HINTSHORTPAUSE; end;
procedure TAPPLICATIONHINTSHORTPAUSE_W(Self: TAPPLICATION; T: INTEGER); begin Self.HINTSHORTPAUSE := T; end;
procedure TAPPLICATIONHINTHIDEPAUSE_R(Self: TAPPLICATION; var T: INTEGER); begin T := Self.HINTHIDEPAUSE; end;
procedure TAPPLICATIONHINTHIDEPAUSE_W(Self: TAPPLICATION; T: INTEGER); begin Self.HINTHIDEPAUSE := T; end;
procedure TAPPLICATIONMAINFORM_R(Self: TAPPLICATION; var T: {$IFDEF DELPHI3UP}TCustomForm{$ELSE}TFORM{$ENDIF}); begin T := Self.MAINFORM; end;
procedure TAPPLICATIONSHOWHINT_R(Self: TAPPLICATION; var T: BOOLEAN); begin T := Self.SHOWHINT; end;
procedure TAPPLICATIONSHOWHINT_W(Self: TAPPLICATION; T: BOOLEAN); begin Self.SHOWHINT := T; end;
procedure TAPPLICATIONSHOWMAINFORM_R(Self: TAPPLICATION; var T: BOOLEAN); begin T := Self.SHOWMAINFORM; end;
procedure TAPPLICATIONSHOWMAINFORM_W(Self: TAPPLICATION; T: BOOLEAN); begin Self.SHOWMAINFORM := T; end;
procedure TAPPLICATIONTERMINATED_R(Self: TAPPLICATION; var T: BOOLEAN); begin T := Self.TERMINATED; end;
procedure TAPPLICATIONTITLE_R(Self: TAPPLICATION; var T: STRING); begin T := Self.TITLE; end;
procedure TAPPLICATIONTITLE_W(Self: TAPPLICATION; T: STRING); begin Self.TITLE := T; end;

{$IFNDEF FPC}
procedure TAPPLICATIONONACTIVATE_R(Self: TAPPLICATION; var T: TNOTIFYEVENT); begin T := Self.ONACTIVATE; end;
procedure TAPPLICATIONONACTIVATE_W(Self: TAPPLICATION; T: TNOTIFYEVENT); begin Self.ONACTIVATE := T; end;
procedure TAPPLICATIONONDEACTIVATE_R(Self: TAPPLICATION; var T: TNOTIFYEVENT); begin T := Self.ONDEACTIVATE; end;
procedure TAPPLICATIONONDEACTIVATE_W(Self: TAPPLICATION; T: TNOTIFYEVENT); begin Self.ONDEACTIVATE := T; end;
{$ENDIF}

procedure TAPPLICATIONONIDLE_R(Self: TAPPLICATION; var T: TIDLEEVENT); begin T := Self.ONIDLE; end;
procedure TAPPLICATIONONIDLE_W(Self: TAPPLICATION; T: TIDLEEVENT); begin Self.ONIDLE := T; end;
procedure TAPPLICATIONONHELP_R(Self: TAPPLICATION; var T: THELPEVENT); begin T := Self.ONHELP; end;
procedure TAPPLICATIONONHELP_W(Self: TAPPLICATION; T: THELPEVENT); begin Self.ONHELP := T; end;
procedure TAPPLICATIONONHINT_R(Self: TAPPLICATION; var T: TNOTIFYEVENT); begin T := Self.ONHINT; end;
procedure TAPPLICATIONONHINT_W(Self: TAPPLICATION; T: TNOTIFYEVENT); begin Self.ONHINT := T; end;

{$IFNDEF FPC}
procedure TAPPLICATIONONMINIMIZE_R(Self: TAPPLICATION; var T: TNOTIFYEVENT); begin T := Self.ONMINIMIZE; end;
procedure TAPPLICATIONONMINIMIZE_W(Self: TAPPLICATION; T: TNOTIFYEVENT); begin Self.ONMINIMIZE := T; end;

procedure TAPPLICATIONONRESTORE_R(Self: TAPPLICATION; var T: TNOTIFYEVENT); begin T := Self.ONRESTORE; end;
procedure TAPPLICATIONONRESTORE_W(Self: TAPPLICATION; T: TNOTIFYEVENT); begin Self.ONRESTORE := T; end;
{$ENDIF}

procedure RIRegisterTAPPLICATION(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TAPPLICATION) do
  begin
 {$IFNDEF FPC}
    RegisterMethod(@TAPPLICATION.MINIMIZE, 'Minimize');
    RegisterMethod(@TAPPLICATION.RESTORE, 'Restore');
    RegisterPropertyHelper(@TAPPLICATIONACTIVE_R, nil, 'Active');
    RegisterPropertyHelper(@TAPPLICATIONONACTIVATE_R, @TAPPLICATIONONACTIVATE_W, 'OnActivate');
    RegisterPropertyHelper(@TAPPLICATIONONDEACTIVATE_R, @TAPPLICATIONONDEACTIVATE_W, 'OnDeactivate');
    RegisterPropertyHelper(@TAPPLICATIONONMINIMIZE_R, @TAPPLICATIONONMINIMIZE_W, 'OnMinimize');
    RegisterPropertyHelper(@TAPPLICATIONONRESTORE_R, @TAPPLICATIONONRESTORE_W, 'OnRestore');
    RegisterPropertyHelper(@TAPPLICATIONDIALOGHANDLE_R, @TAPPLICATIONDIALOGHANDLE_W, 'DialogHandle');
    RegisterMethod(@TAPPLICATION.CREATEHANDLE, 'CreateHandle');
    RegisterMethod(@TAPPLICATION.NORMALIZETOPMOSTS, 'NormalizeTopMosts');
    RegisterMethod(@TAPPLICATION.RESTORETOPMOSTS, 'RestoreTopMosts');
    {$IFNDEF CLX}
    RegisterPropertyHelper(@TAPPLICATIONHANDLE_R, @TAPPLICATIONHANDLE_W, 'Handle');
    RegisterPropertyHelper(@TAPPLICATIONUPDATEFORMATSETTINGS_R, @TAPPLICATIONUPDATEFORMATSETTINGS_W, 'UpdateFormatSettings');
    {$ENDIF}
 {$ENDIF}
    RegisterMethod(@TAPPLICATION.BRINGTOFRONT, 'BringToFront');
    RegisterMethod(@TAPPLICATION.MESSAGEBOX, 'MessageBox');
    RegisterMethod(@TAPPLICATION.PROCESSMESSAGES, 'ProcessMessages');
    RegisterMethod(@TAPPLICATION.TERMINATE, 'Terminate');
    RegisterPropertyHelper(@TAPPLICATIONEXENAME_R, nil, 'ExeName');
    RegisterPropertyHelper(@TAPPLICATIONHINT_R, @TAPPLICATIONHINT_W, 'Hint');
    RegisterPropertyHelper(@TAPPLICATIONMAINFORM_R, nil, 'MainForm');
    RegisterPropertyHelper(@TAPPLICATIONSHOWHINT_R, @TAPPLICATIONSHOWHINT_W, 'ShowHint');
    RegisterPropertyHelper(@TAPPLICATIONSHOWMAINFORM_R, @TAPPLICATIONSHOWMAINFORM_W, 'ShowMainForm');
    RegisterPropertyHelper(@TAPPLICATIONTERMINATED_R, nil, 'Terminated');
    RegisterPropertyHelper(@TAPPLICATIONTITLE_R, @TAPPLICATIONTITLE_W, 'Title');
    RegisterPropertyHelper(@TAPPLICATIONONIDLE_R, @TAPPLICATIONONIDLE_W, 'OnIdle');
    RegisterPropertyHelper(@TAPPLICATIONONHINT_R, @TAPPLICATIONONHINT_W, 'OnHint');
    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TAPPLICATION.CONTROLDESTROYED, 'ControlDestroyed');
    RegisterMethod(@TAPPLICATION.CANCELHINT, 'CancelHint');
    {$IFNDEF CLX}
    {$IFNDEF FPC}
    RegisterMethod(@TAPPLICATION.HELPCOMMAND, 'HelpCommand');
    {$ENDIF}
    RegisterMethod(@TAPPLICATION.HELPCONTEXT, 'HelpContext');
    {$IFNDEF FPC}
    RegisterMethod(@TAPPLICATION.HELPJUMP, 'HelpJump');
    {$ENDIF}
    {$ENDIF}
//    RegisterMethod(@TAPPLICATION.HANDLEEXCEPTION, 'HandleException');
//    RegisterMethod(@TAPPLICATION.HOOKMAINWINDOW, 'HookMainWindow');
//    RegisterMethod(@TAPPLICATION.UNHOOKMAINWINDOW, 'UnhookMainWindow');

    RegisterMethod(@TAPPLICATION.HANDLEMESSAGE, 'HandleMessage');
    RegisterMethod(@TAPPLICATION.HIDEHINT, 'HideHint');
    RegisterMethod(@TAPPLICATION.HINTMOUSEMESSAGE, 'HintMouseMessage');
    RegisterMethod(@TAPPLICATION.INITIALIZE, 'Initialize');
    RegisterMethod(@TAPPLICATION.RUN, 'Run');
//    RegisterMethod(@TAPPLICATION.SHOWEXCEPTION, 'ShowException');
    RegisterPropertyHelper(@TAPPLICATIONHELPFILE_R, @TAPPLICATIONHELPFILE_W, 'HelpFile');
    RegisterPropertyHelper(@TAPPLICATIONHINTCOLOR_R, @TAPPLICATIONHINTCOLOR_W, 'HintColor');
    RegisterPropertyHelper(@TAPPLICATIONHINTPAUSE_R, @TAPPLICATIONHINTPAUSE_W, 'HintPause');
    RegisterPropertyHelper(@TAPPLICATIONHINTSHORTPAUSE_R, @TAPPLICATIONHINTSHORTPAUSE_W, 'HintShortPause');
    RegisterPropertyHelper(@TAPPLICATIONHINTHIDEPAUSE_R, @TAPPLICATIONHINTHIDEPAUSE_W, 'HintHidePause');
    RegisterPropertyHelper(@TAPPLICATIONONHELP_R, @TAPPLICATIONONHELP_W, 'OnHelp');
    {$ENDIF}
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}


procedure RIRegister_Forms(Cl: TPSRuntimeClassImporter);
begin
  {$IFNDEF PS_MINIVCL}
  RIRegisterTCONTROLSCROLLBAR(cl);
  RIRegisterTSCROLLBOX(cl);
  {$ENDIF}
{$IFNDEF FPC}  RIRegisterTScrollingWinControl(cl);{$ENDIF}
  RIRegisterTForm(Cl);
  {$IFNDEF PS_MINIVCL}
  RIRegisterTApplication(Cl);
  {$ENDIF}
end;


// PS_MINIVCL changes by Martijn Laan
// FPC changes by Boguslaw brandys (brandys at o2 _dot_ pl)

end.





