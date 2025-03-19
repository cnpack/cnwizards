
Unit uPSR_menus;
{$I PascalScript.inc}
Interface
Uses uPSRuntime;

procedure RIRegister_Menus_Routines(S: TPSExec);
{$IFNDEF FPC}
procedure RIRegisterTMENUITEMSTACK(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTPOPUPLIST(Cl: TPSRuntimeClassImporter);
{$ENDIF}
procedure RIRegisterTPOPUPMENU(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTMAINMENU(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTMENU(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTMENUITEM(Cl: TPSRuntimeClassImporter);
procedure RIRegister_Menus(CL: TPSRuntimeClassImporter);

implementation
{$IFDEF LINUX}
{$IFNDEF FPC}
Uses
  Libc, SysUtils, Classes, QControls, QMenus, QGraphics;
{$ELSE}
Uses
  SysUtils, Classes, Controls, Menus, Graphics, LCLType, ImgList;
{$ENDIF}
{$ELSE}
Uses {$IFNDEF FPC}WINDOWS,{$ELSE} LCLType,{$ENDIF} SYSUTILS, CLASSES, CONTNRS, MESSAGES, GRAPHICS, IMGLIST, ACTNLIST, Menus;
{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TPopupList'}{$ENDIF}
{$IFNDEF FPC}
{$IFDEF class_helper_present}
type
  TPopupList_PSHelper = class helper for TPopupList
  public
    procedure WINDOW_R(var T: HWND);
  end;

procedure TPopupList_PSHelper.WINDOW_R(var T: HWND);
begin T := Self.WINDOW; end;

procedure RIRegisterTPOPUPLIST(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TPOPUPLIST) do
	begin
		RegisterPropertyHelper(@TPOPUPLIST.WINDOW_R,nil,'Window');
		RegisterMethod(@TPOPUPLIST.ADD, 'Add');
		RegisterMethod(@TPOPUPLIST.REMOVE, 'Remove');
	end;
end;

{$ELSE}
procedure TPOPUPLISTWINDOW_R(Self: TPopupList; var T: HWND);
begin T := Self.WINDOW; end;

procedure RIRegisterTPOPUPLIST(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TPOPUPLIST) do
	begin
		RegisterPropertyHelper(@TPOPUPLISTWINDOW_R,nil,'Window');
		RegisterMethod(@TPOPUPLIST.ADD, 'Add');
		RegisterMethod(@TPOPUPLIST.REMOVE, 'Remove');
	end;
end;

{$ENDIF class_helper_present}
{$ENDIF FPC}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TPopupMenu'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TPopupMenu_PSHelper = class helper for TPopupMenu
  public
    procedure ONPOPUP_W(const T: TNOTIFYEVENT);
    procedure ONPOPUP_R(var T: TNOTIFYEVENT);
    {$IFNDEF FPC}
    procedure TRACKBUTTON_W(const T: TTRACKBUTTON);
    procedure TRACKBUTTON_R(var T: TTRACKBUTTON);
    procedure MENUANIMATION_W(const T: TMENUANIMATION);
    procedure MENUANIMATION_R(var T: TMENUANIMATION);
    procedure HELPCONTEXT_W(const T: THELPCONTEXT);
    procedure HELPCONTEXT_R(var T: THELPCONTEXT);
    {$ENDIF}
    procedure AUTOPOPUP_W(const T: BOOLEAN);
    procedure AUTOPOPUP_R(var T: BOOLEAN);
    {$IFNDEF FPC}
    procedure ALIGNMENT_W(const T: TPOPUPALIGNMENT);
    procedure ALIGNMENT_R(var T: TPOPUPALIGNMENT);
    {$ENDIF}
    procedure POPUPCOMPONENT_W(const T: TCOMPONENT);
    procedure POPUPCOMPONENT_R(var T: TCOMPONENT);
  end;

procedure TPopupMenu_PSHelper.ONPOPUP_W(const T: TNOTIFYEVENT);
begin Self.ONPOPUP := T; end;

procedure TPopupMenu_PSHelper.ONPOPUP_R(var T: TNOTIFYEVENT);
begin T := Self.ONPOPUP; end;

{$IFNDEF FPC}
procedure TPopupMenu_PSHelper.TRACKBUTTON_W(const T: TTRACKBUTTON);
begin Self.TRACKBUTTON := T; end;

procedure TPopupMenu_PSHelper.TRACKBUTTON_R(var T: TTRACKBUTTON);
begin T := Self.TRACKBUTTON; end;


procedure TPopupMenu_PSHelper.MENUANIMATION_W(const T: TMENUANIMATION);
begin Self.MENUANIMATION := T; end;

procedure TPopupMenu_PSHelper.MENUANIMATION_R(var T: TMENUANIMATION);
begin T := Self.MENUANIMATION; end;

procedure TPopupMenu_PSHelper.HELPCONTEXT_W(const T: THELPCONTEXT);
begin Self.HELPCONTEXT := T; end;

procedure TPopupMenu_PSHelper.HELPCONTEXT_R(var T: THELPCONTEXT);
begin T := Self.HELPCONTEXT; end;
{$ENDIF}

procedure TPopupMenu_PSHelper.AUTOPOPUP_W(const T: BOOLEAN);
begin Self.AUTOPOPUP := T; end;

procedure TPopupMenu_PSHelper.AUTOPOPUP_R(var T: BOOLEAN);
begin T := Self.AUTOPOPUP; end;

{$IFNDEF FPC}
procedure TPopupMenu_PSHelper.ALIGNMENT_W(const T: TPOPUPALIGNMENT);
begin Self.ALIGNMENT := T; end;

procedure TPopupMenu_PSHelper.ALIGNMENT_R(var T: TPOPUPALIGNMENT);
begin T := Self.ALIGNMENT; end;
{$ENDIF}

procedure TPopupMenu_PSHelper.POPUPCOMPONENT_W(const T: TCOMPONENT);
begin Self.POPUPCOMPONENT := T; end;

procedure TPopupMenu_PSHelper.POPUPCOMPONENT_R(var T: TCOMPONENT);
begin T := Self.POPUPCOMPONENT; end;

procedure RIRegisterTPOPUPMENU(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TPopupMenu) do
  begin
		RegisterConstructor(@TPopupMenu.CREATE, 'Create');
		RegisterVirtualMethod(@TPopupMenu.POPUP, 'Popup');
		RegisterPropertyHelper(@TPopupMenu.POPUPCOMPONENT_R,@TPopupMenu.POPUPCOMPONENT_W,'PopupComponent');
		RegisterEventPropertyHelper(@TPopupMenu.ONPOPUP_R,@TPopupMenu.ONPOPUP_W,'OnPopup');
{$IFNDEF FPC}
		RegisterPropertyHelper(@TPopupMenu.ALIGNMENT_R,@TPopupMenu.ALIGNMENT_W,'Alignment');
		RegisterPropertyHelper(@TPopupMenu.AUTOPOPUP_R,@TPopupMenu.AUTOPOPUP_W,'AutoPopup');
		RegisterPropertyHelper(@TPopupMenu.HELPCONTEXT_R,@TPopupMenu.HELPCONTEXT_W,'HelpContext');
		RegisterPropertyHelper(@TPopupMenu.MENUANIMATION_R,@TPopupMenu.MENUANIMATION_W,'MenuAnimation');
		RegisterPropertyHelper(@TPopupMenu.TRACKBUTTON_R,@TPopupMenu.TRACKBUTTON_W,'TrackButton');
{$ENDIF}
	end;
end;

{$ELSE}
procedure TPOPUPMENUONPOPUP_W(Self: TPopupMenu; const T: TNOTIFYEVENT);
begin Self.ONPOPUP := T; end;

procedure TPOPUPMENUONPOPUP_R(Self: TPOPUPMENU; var T: TNOTIFYEVENT);
begin T := Self.ONPOPUP; end;

{$IFNDEF FPC}
procedure TPOPUPMENUTRACKBUTTON_W(Self: TPOPUPMENU; const T: TTRACKBUTTON);
begin Self.TRACKBUTTON := T; end;

procedure TPOPUPMENUTRACKBUTTON_R(Self: TPOPUPMENU; var T: TTRACKBUTTON);
begin T := Self.TRACKBUTTON; end;


procedure TPOPUPMENUMENUANIMATION_W(Self: TPOPUPMENU; const T: TMENUANIMATION);
begin Self.MENUANIMATION := T; end;

procedure TPOPUPMENUMENUANIMATION_R(Self: TPOPUPMENU; var T: TMENUANIMATION);
begin T := Self.MENUANIMATION; end;

procedure TPOPUPMENUHELPCONTEXT_W(Self: TPOPUPMENU; const T: THELPCONTEXT);
begin Self.HELPCONTEXT := T; end;

procedure TPOPUPMENUHELPCONTEXT_R(Self: TPOPUPMENU; var T: THELPCONTEXT);
begin T := Self.HELPCONTEXT; end;
{$ENDIF}

procedure TPOPUPMENUAUTOPOPUP_W(Self: TPOPUPMENU; const T: BOOLEAN);
begin Self.AUTOPOPUP := T; end;

procedure TPOPUPMENUAUTOPOPUP_R(Self: TPOPUPMENU; var T: BOOLEAN);
begin T := Self.AUTOPOPUP; end;

{$IFNDEF FPC}
procedure TPOPUPMENUALIGNMENT_W(Self: TPOPUPMENU; const T: TPOPUPALIGNMENT);
begin Self.ALIGNMENT := T; end;

procedure TPOPUPMENUALIGNMENT_R(Self: TPOPUPMENU; var T: TPOPUPALIGNMENT);
begin T := Self.ALIGNMENT; end;
{$ENDIF}

procedure TPOPUPMENUPOPUPCOMPONENT_W(Self: TPOPUPMENU; const T: TCOMPONENT);
begin Self.POPUPCOMPONENT := T; end;

procedure TPOPUPMENUPOPUPCOMPONENT_R(Self: TPOPUPMENU; var T: TCOMPONENT);
begin T := Self.POPUPCOMPONENT; end;
procedure RIRegisterTPOPUPMENU(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TPOPUPMENU) do
  begin
		RegisterConstructor(@TPOPUPMENU.CREATE, 'Create');
		RegisterVirtualMethod(@TPOPUPMENU.POPUP, 'Popup');
		RegisterPropertyHelper(@TPOPUPMENUPOPUPCOMPONENT_R,@TPOPUPMENUPOPUPCOMPONENT_W,'PopupComponent');
		RegisterEventPropertyHelper(@TPOPUPMENUONPOPUP_R,@TPOPUPMENUONPOPUP_W,'OnPopup');
{$IFNDEF FPC}
		RegisterPropertyHelper(@TPOPUPMENUALIGNMENT_R,@TPOPUPMENUALIGNMENT_W,'Alignment');
		RegisterPropertyHelper(@TPOPUPMENUAUTOPOPUP_R,@TPOPUPMENUAUTOPOPUP_W,'AutoPopup');
		RegisterPropertyHelper(@TPOPUPMENUHELPCONTEXT_R,@TPOPUPMENUHELPCONTEXT_W,'HelpContext');
		RegisterPropertyHelper(@TPOPUPMENUMENUANIMATION_R,@TPOPUPMENUMENUANIMATION_W,'MenuAnimation');
		RegisterPropertyHelper(@TPOPUPMENUTRACKBUTTON_R,@TPOPUPMENUTRACKBUTTON_W,'TrackButton');
{$ENDIF}
	end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TMainMenu'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TMainMenu_PSHelper = class helper for TMainMenu
  public
    {$IFNDEF FPC}
    procedure AUTOMERGE_W(const T: BOOLEAN);
    procedure AUTOMERGE_R(var T: BOOLEAN);
    {$ENDIF}
  end;

{$IFNDEF FPC}
procedure TMainMenu_PSHelper.AUTOMERGE_W(const T: BOOLEAN);
begin Self.AUTOMERGE := T; end;

procedure TMainMenu_PSHelper.AUTOMERGE_R(var T: BOOLEAN);
begin T := Self.AUTOMERGE; end;
{$ENDIF}
procedure RIRegisterTMAINMENU(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TMAINMENU) do
	begin
{$IFNDEF FPC}
		RegisterMethod(@TMAINMENU.MERGE, 'Merge');
		RegisterMethod(@TMAINMENU.UNMERGE, 'Unmerge');
		RegisterMethod(@TMAINMENU.POPULATEOLE2MENU, 'PopulateOle2Menu');
		RegisterMethod(@TMAINMENU.GETOLE2ACCELERATORTABLE, 'GetOle2AcceleratorTable');
		RegisterMethod(@TMAINMENU.SETOLE2MENUHANDLE, 'SetOle2MenuHandle');
		RegisterPropertyHelper(@TMAINMENU.AUTOMERGE_R,@TMAINMENU.AUTOMERGE_W,'AutoMerge');
{$ENDIF}
	end;
end;

{$ELSE}
{$IFNDEF FPC}
procedure TMAINMENUAUTOMERGE_W(Self: TMainMenu; const T: BOOLEAN);
begin Self.AUTOMERGE := T; end;

procedure TMAINMENUAUTOMERGE_R(Self: TMAINMENU; var T: BOOLEAN);
begin T := Self.AUTOMERGE; end;
{$ENDIF}
procedure RIRegisterTMAINMENU(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TMAINMENU) do
	begin
{$IFNDEF FPC}
		RegisterMethod(@TMAINMENU.MERGE, 'Merge');
		RegisterMethod(@TMAINMENU.UNMERGE, 'Unmerge');
		RegisterMethod(@TMAINMENU.POPULATEOLE2MENU, 'PopulateOle2Menu');
		RegisterMethod(@TMAINMENU.GETOLE2ACCELERATORTABLE, 'GetOle2AcceleratorTable');
		RegisterMethod(@TMAINMENU.SETOLE2MENUHANDLE, 'SetOle2MenuHandle');
		RegisterPropertyHelper(@TMAINMENUAUTOMERGE_R,@TMAINMENUAUTOMERGE_W,'AutoMerge');
{$ENDIF}
	end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TMenu'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TMenu_PSHelper = class helper for TMenu
  public
    procedure ITEMS_R(var T: TMENUITEM);
    {$IFNDEF FPC}
    procedure WINDOWHANDLE_W(const T: HWND);
    procedure WINDOWHANDLE_R(var T: HWND);
    procedure PARENTBIDIMODE_W(const T: BOOLEAN);
    procedure PARENTBIDIMODE_R(var T: BOOLEAN);
    procedure OWNERDRAW_W(const T: BOOLEAN);
    procedure OWNERDRAW_R(var T: BOOLEAN);
    procedure BIDIMODE_W(const T: TBIDIMODE);
    procedure BIDIMODE_R(var T: TBIDIMODE);
    procedure AUTOLINEREDUCTION_W(const T: TMENUAUTOFLAG);
    procedure AUTOLINEREDUCTION_R(var T: TMENUAUTOFLAG);
    procedure AUTOHOTKEYS_W(const T: TMENUAUTOFLAG);
    procedure AUTOHOTKEYS_R(var T: TMENUAUTOFLAG);
    {$ENDIF}
    procedure HANDLE_R(var T: HMENU);
    procedure IMAGES_W(const T: TCUSTOMIMAGELIST);
    procedure IMAGES_R(var T: TCUSTOMIMAGELIST);
  end;

procedure TMenu_PSHelper.ITEMS_R(var T: TMENUITEM);
begin T := Self.ITEMS; end;

{$IFNDEF FPC}
procedure TMenu_PSHelper.WINDOWHANDLE_W(const T: HWND);
begin Self.WINDOWHANDLE := T; end;

procedure TMenu_PSHelper.WINDOWHANDLE_R(var T: HWND);
begin T := Self.WINDOWHANDLE; end;

procedure TMenu_PSHelper.PARENTBIDIMODE_W(const T: BOOLEAN);
begin Self.PARENTBIDIMODE := T; end;

procedure TMenu_PSHelper.PARENTBIDIMODE_R(var T: BOOLEAN);
begin T := Self.PARENTBIDIMODE; end;

procedure TMenu_PSHelper.OWNERDRAW_W(const T: BOOLEAN);
begin Self.OWNERDRAW := T; end;

procedure TMenu_PSHelper.OWNERDRAW_R(var T: BOOLEAN);
begin T := Self.OWNERDRAW; end;

procedure TMenu_PSHelper.BIDIMODE_W(const T: TBIDIMODE);
begin Self.BIDIMODE := T; end;

procedure TMenu_PSHelper.BIDIMODE_R(var T: TBIDIMODE);
begin T := Self.BIDIMODE; end;

procedure TMenu_PSHelper.AUTOLINEREDUCTION_W(const T: TMENUAUTOFLAG);
begin Self.AUTOLINEREDUCTION := T; end;

procedure TMenu_PSHelper.AUTOLINEREDUCTION_R(var T: TMENUAUTOFLAG);
begin T := Self.AUTOLINEREDUCTION; end;

procedure TMenu_PSHelper.AUTOHOTKEYS_W(const T: TMENUAUTOFLAG);
begin Self.AUTOHOTKEYS := T; end;

procedure TMenu_PSHelper.AUTOHOTKEYS_R(var T: TMENUAUTOFLAG);
begin T := Self.AUTOHOTKEYS; end;
{$ENDIF}

procedure TMenu_PSHelper.HANDLE_R(var T: HMENU);
begin T := Self.HANDLE; end;

procedure TMenu_PSHelper.IMAGES_W(const T: TCUSTOMIMAGELIST);
begin Self.IMAGES := T; end;

procedure TMenu_PSHelper.IMAGES_R(var T: TCUSTOMIMAGELIST);
begin T := Self.IMAGES; end;

procedure RIRegisterTMENU(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TMENU) do
	begin
		RegisterConstructor(@TMENU.CREATE, 'Create');
		RegisterMethod(@TMENU.DISPATCHCOMMAND, 'DispatchCommand');
		RegisterMethod(@TMENU.FINDITEM, 'FindItem');
		RegisterPropertyHelper(@TMENU.IMAGES_R,@TMENU.IMAGES_W,'Images');
		RegisterMethod(@TMENU.ISRIGHTTOLEFT, 'IsRightToLeft');
		RegisterPropertyHelper(@TMENU.HANDLE_R,nil,'Handle');
		RegisterPropertyHelper(@TMENU.ITEMS_R,nil,'Items');
{$IFNDEF FPC}
		RegisterMethod(@TMENU.DISPATCHPOPUP, 'DispatchPopup');
		RegisterMethod(@TMENU.PARENTBIDIMODECHANGED, 'ParentBiDiModeChanged');
		RegisterMethod(@TMENU.PROCESSMENUCHAR, 'ProcessMenuChar');
		RegisterPropertyHelper(@TMENU.AUTOHOTKEYS_R,@TMENU.AUTOHOTKEYS_W,'AutoHotkeys');
		RegisterPropertyHelper(@TMENU.AUTOLINEREDUCTION_R,@TMENU.AUTOLINEREDUCTION_W,'AutoLineReduction');
		RegisterPropertyHelper(@TMENU.BIDIMODE_R,@TMENU.BIDIMODE_W,'BiDiMode');
		RegisterMethod(@TMENU.GETHELPCONTEXT, 'GetHelpContext');
		RegisterPropertyHelper(@TMENU.OWNERDRAW_R,@TMENU.OWNERDRAW_W,'OwnerDraw');
		RegisterPropertyHelper(@TMENU.PARENTBIDIMODE_R,@TMENU.PARENTBIDIMODE_W,'ParentBiDiMode');
		RegisterPropertyHelper(@TMENU.WINDOWHANDLE_R,@TMENU.WINDOWHANDLE_W,'WindowHandle');
{$ENDIF}
	end;
end;
{$ELSE}
procedure TMENUITEMS_R(Self: TMenu; var T: TMENUITEM);
begin T := Self.ITEMS; end;

{$IFNDEF FPC}
procedure TMENUWINDOWHANDLE_W(Self: TMENU; const T: HWND);
begin Self.WINDOWHANDLE := T; end;

procedure TMENUWINDOWHANDLE_R(Self: TMENU; var T: HWND);
begin T := Self.WINDOWHANDLE; end;

procedure TMENUPARENTBIDIMODE_W(Self: TMENU; const T: BOOLEAN);
begin Self.PARENTBIDIMODE := T; end;

procedure TMENUPARENTBIDIMODE_R(Self: TMENU; var T: BOOLEAN);
begin T := Self.PARENTBIDIMODE; end;

procedure TMENUOWNERDRAW_W(Self: TMENU; const T: BOOLEAN);
begin Self.OWNERDRAW := T; end;

procedure TMENUOWNERDRAW_R(Self: TMENU; var T: BOOLEAN);
begin T := Self.OWNERDRAW; end;

procedure TMENUBIDIMODE_W(Self: TMENU; const T: TBIDIMODE);
begin Self.BIDIMODE := T; end;

procedure TMENUBIDIMODE_R(Self: TMENU; var T: TBIDIMODE);
begin T := Self.BIDIMODE; end;

procedure TMENUAUTOLINEREDUCTION_W(Self: TMENU; const T: TMENUAUTOFLAG);
begin Self.AUTOLINEREDUCTION := T; end;

procedure TMENUAUTOLINEREDUCTION_R(Self: TMENU; var T: TMENUAUTOFLAG);
begin T := Self.AUTOLINEREDUCTION; end;

procedure TMENUAUTOHOTKEYS_W(Self: TMENU; const T: TMENUAUTOFLAG);
begin Self.AUTOHOTKEYS := T; end;

procedure TMENUAUTOHOTKEYS_R(Self: TMENU; var T: TMENUAUTOFLAG);
begin T := Self.AUTOHOTKEYS; end;

{$ENDIF}


procedure TMENUHANDLE_R(Self: TMENU; var T: HMENU);
begin T := Self.HANDLE; end;




procedure TMENUIMAGES_W(Self: TMENU; const T: TCUSTOMIMAGELIST);
begin Self.IMAGES := T; end;

procedure TMENUIMAGES_R(Self: TMENU; var T: TCUSTOMIMAGELIST);
begin T := Self.IMAGES; end;

procedure RIRegisterTMENU(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TMENU) do
	begin
		RegisterConstructor(@TMENU.CREATE, 'Create');
		RegisterMethod(@TMENU.DISPATCHCOMMAND, 'DispatchCommand');
		RegisterMethod(@TMENU.FINDITEM, 'FindItem');
		RegisterPropertyHelper(@TMENUIMAGES_R,@TMENUIMAGES_W,'Images');
		RegisterMethod(@TMENU.ISRIGHTTOLEFT, 'IsRightToLeft');
		RegisterPropertyHelper(@TMENUHANDLE_R,nil,'Handle');
		RegisterPropertyHelper(@TMENUITEMS_R,nil,'Items');
{$IFNDEF FPC}
		RegisterMethod(@TMENU.DISPATCHPOPUP, 'DispatchPopup');
		RegisterMethod(@TMENU.PARENTBIDIMODECHANGED, 'ParentBiDiModeChanged');
		RegisterMethod(@TMENU.PROCESSMENUCHAR, 'ProcessMenuChar');
		RegisterPropertyHelper(@TMENUAUTOHOTKEYS_R,@TMENUAUTOHOTKEYS_W,'AutoHotkeys');
		RegisterPropertyHelper(@TMENUAUTOLINEREDUCTION_R,@TMENUAUTOLINEREDUCTION_W,'AutoLineReduction');
		RegisterPropertyHelper(@TMENUBIDIMODE_R,@TMENUBIDIMODE_W,'BiDiMode');
		RegisterMethod(@TMENU.GETHELPCONTEXT, 'GetHelpContext');
		RegisterPropertyHelper(@TMENUOWNERDRAW_R,@TMENUOWNERDRAW_W,'OwnerDraw');
		RegisterPropertyHelper(@TMENUPARENTBIDIMODE_R,@TMENUPARENTBIDIMODE_W,'ParentBiDiMode');
		RegisterPropertyHelper(@TMENUWINDOWHANDLE_R,@TMENUWINDOWHANDLE_W,'WindowHandle');
{$ENDIF}
	end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TMenuItem'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TMenuItem_PSHelper = class helper for TMenuItem
  public
    {$IFNDEF FPC}
    procedure ONMEASUREITEM_W(const T: TMENUMEASUREITEMEVENT);
    procedure ONMEASUREITEM_R(var T: TMENUMEASUREITEMEVENT);
    procedure ONADVANCEDDRAWITEM_W(const T: TADVANCEDMENUDRAWITEMEVENT);
    procedure ONADVANCEDDRAWITEM_R(var T: TADVANCEDMENUDRAWITEMEVENT);
    procedure ONDRAWITEM_W(const T: TMENUDRAWITEMEVENT);
    procedure ONDRAWITEM_R(var T: TMENUDRAWITEMEVENT);
    {$ENDIF}
    procedure ONCLICK_W(const T: TNOTIFYEVENT);
    procedure ONCLICK_R(var T: TNOTIFYEVENT);
    procedure VISIBLE_W(const T: BOOLEAN);
    procedure VISIBLE_R(var T: BOOLEAN);
    procedure SHORTCUT_W(const T: TSHORTCUT);
    procedure SHORTCUT_R(var T: TSHORTCUT);
    procedure RADIOITEM_W(const T: BOOLEAN);
    procedure RADIOITEM_R(var T: BOOLEAN);
    procedure IMAGEINDEX_W(const T: TIMAGEINDEX);
    procedure IMAGEINDEX_R(var T: TIMAGEINDEX);
    procedure HINT_W(const T: STRING);
    procedure HINT_R(var T: STRING);
    procedure HELPCONTEXT_W(const T: THELPCONTEXT);
    procedure HELPCONTEXT_R(var T: THELPCONTEXT);
    procedure GROUPINDEX_W(const T: BYTE);
    procedure GROUPINDEX_R(var T: BYTE);
    procedure ENABLED_W(const T: BOOLEAN);
    procedure ENABLED_R(var T: BOOLEAN);
    procedure DEFAULT_W(const T: BOOLEAN);
    procedure DEFAULT_R(var T: BOOLEAN);
    procedure SUBMENUIMAGES_W(const T: TCUSTOMIMAGELIST);
    procedure SUBMENUIMAGES_R(var T: TCUSTOMIMAGELIST);
    procedure CHECKED_W(const T: BOOLEAN);
    procedure CHECKED_R(var T: BOOLEAN);
    procedure CAPTION_W(const T: STRING);
    procedure CAPTION_R(var T: STRING);
    procedure BITMAP_W(const T: TBITMAP);
    procedure BITMAP_R(var T: TBITMAP);
    {$IFNDEF FPC}
    procedure AUTOLINEREDUCTION_W(const T: TMENUITEMAUTOFLAG);
    procedure AUTOLINEREDUCTION_R(var T: TMENUITEMAUTOFLAG);
    procedure AUTOHOTKEYS_W(const T: TMENUITEMAUTOFLAG);
    procedure AUTOHOTKEYS_R(var T: TMENUITEMAUTOFLAG);
    {$ENDIF}
    procedure ACTION_W(const T: TBASICACTION);
    procedure ACTION_R(var T: TBASICACTION);
    procedure PARENT_R(var T: TMENUITEM);
    procedure MENUINDEX_W(const T: INTEGER);
    procedure MENUINDEX_R(var T: INTEGER);
    procedure ITEMS_R(var T: TMENUITEM; const t1: INTEGER);
    procedure COUNT_R(var T: INTEGER);
    procedure HANDLE_R(var T: HMENU);
    procedure COMMAND_R(var T: WORD);
  end;
{$IFNDEF FPC}
procedure TMenuItem_PSHelper.ONMEASUREITEM_W(const T: TMENUMEASUREITEMEVENT);
begin Self.ONMEASUREITEM := T; end;

procedure TMenuItem_PSHelper.ONMEASUREITEM_R(var T: TMENUMEASUREITEMEVENT);
begin T := Self.ONMEASUREITEM; end;

procedure TMenuItem_PSHelper.ONADVANCEDDRAWITEM_W(const T: TADVANCEDMENUDRAWITEMEVENT);
begin Self.ONADVANCEDDRAWITEM := T; end;

procedure TMenuItem_PSHelper.ONADVANCEDDRAWITEM_R(var T: TADVANCEDMENUDRAWITEMEVENT);
begin T := Self.ONADVANCEDDRAWITEM; end;

procedure TMenuItem_PSHelper.ONDRAWITEM_W(const T: TMENUDRAWITEMEVENT);
begin Self.ONDRAWITEM := T; end;

procedure TMenuItem_PSHelper.ONDRAWITEM_R(var T: TMENUDRAWITEMEVENT);
begin T := Self.ONDRAWITEM; end;
{$ENDIF}

procedure TMenuItem_PSHelper.ONCLICK_W(const T: TNOTIFYEVENT);
begin Self.ONCLICK := T; end;

procedure TMenuItem_PSHelper.ONCLICK_R(var T: TNOTIFYEVENT);
begin T := Self.ONCLICK; end;

procedure TMenuItem_PSHelper.VISIBLE_W(const T: BOOLEAN);
begin Self.VISIBLE := T; end;

procedure TMenuItem_PSHelper.VISIBLE_R(var T: BOOLEAN);
begin T := Self.VISIBLE; end;

procedure TMenuItem_PSHelper.SHORTCUT_W(const T: TSHORTCUT);
begin Self.SHORTCUT := T; end;

procedure TMenuItem_PSHelper.SHORTCUT_R(var T: TSHORTCUT);
begin T := Self.SHORTCUT; end;

procedure TMenuItem_PSHelper.RADIOITEM_W(const T: BOOLEAN);
begin Self.RADIOITEM := T; end;

procedure TMenuItem_PSHelper.RADIOITEM_R(var T: BOOLEAN);
begin T := Self.RADIOITEM; end;

procedure TMenuItem_PSHelper.IMAGEINDEX_W(const T: TIMAGEINDEX);
begin Self.IMAGEINDEX := T; end;

procedure TMenuItem_PSHelper.IMAGEINDEX_R(var T: TIMAGEINDEX);
begin T := Self.IMAGEINDEX; end;

procedure TMenuItem_PSHelper.HINT_W(const T: STRING);
begin Self.HINT := T; end;

procedure TMenuItem_PSHelper.HINT_R(var T: STRING);
begin T := Self.HINT; end;

procedure TMenuItem_PSHelper.HELPCONTEXT_W(const T: THELPCONTEXT);
begin Self.HELPCONTEXT := T; end;

procedure TMenuItem_PSHelper.HELPCONTEXT_R(var T: THELPCONTEXT);
begin T := Self.HELPCONTEXT; end;

procedure TMenuItem_PSHelper.GROUPINDEX_W(const T: BYTE);
begin Self.GROUPINDEX := T; end;

procedure TMenuItem_PSHelper.GROUPINDEX_R(var T: BYTE);
begin T := Self.GROUPINDEX; end;

procedure TMenuItem_PSHelper.ENABLED_W(const T: BOOLEAN);
begin Self.ENABLED := T; end;

procedure TMenuItem_PSHelper.ENABLED_R(var T: BOOLEAN);
begin T := Self.ENABLED; end;

procedure TMenuItem_PSHelper.DEFAULT_W(const T: BOOLEAN);
begin Self.DEFAULT := T; end;

procedure TMenuItem_PSHelper.DEFAULT_R(var T: BOOLEAN);
begin T := Self.DEFAULT; end;

procedure TMenuItem_PSHelper.SUBMENUIMAGES_W(const T: TCUSTOMIMAGELIST);
begin Self.SUBMENUIMAGES := T; end;

procedure TMenuItem_PSHelper.SUBMENUIMAGES_R(var T: TCUSTOMIMAGELIST);
begin T := Self.SUBMENUIMAGES; end;

procedure TMenuItem_PSHelper.CHECKED_W(const T: BOOLEAN);
begin Self.CHECKED := T; end;

procedure TMenuItem_PSHelper.CHECKED_R(var T: BOOLEAN);
begin T := Self.CHECKED; end;

procedure TMenuItem_PSHelper.CAPTION_W(const T: STRING);
begin Self.CAPTION := T; end;

procedure TMenuItem_PSHelper.CAPTION_R(var T: STRING);
begin T := Self.CAPTION; end;

procedure TMenuItem_PSHelper.BITMAP_W(const T: TBITMAP);
begin Self.BITMAP := T; end;

procedure TMenuItem_PSHelper.BITMAP_R(var T: TBITMAP);
begin T := Self.BITMAP; end;

{$IFNDEF FPC}
procedure TMenuItem_PSHelper.AUTOLINEREDUCTION_W(const T: TMENUITEMAUTOFLAG);
begin Self.AUTOLINEREDUCTION := T; end;

procedure TMenuItem_PSHelper.AUTOLINEREDUCTION_R(var T: TMENUITEMAUTOFLAG);
begin T := Self.AUTOLINEREDUCTION; end;

procedure TMenuItem_PSHelper.AUTOHOTKEYS_W(const T: TMENUITEMAUTOFLAG);
begin Self.AUTOHOTKEYS := T; end;

procedure TMenuItem_PSHelper.AUTOHOTKEYS_R(var T: TMENUITEMAUTOFLAG);
begin T := Self.AUTOHOTKEYS; end;
{$ENDIF}

procedure TMenuItem_PSHelper.ACTION_W(const T: TBASICACTION);
begin Self.ACTION := T; end;

procedure TMenuItem_PSHelper.ACTION_R(var T: TBASICACTION);
begin T := Self.ACTION; end;

procedure TMenuItem_PSHelper.PARENT_R(var T: TMENUITEM);
begin T := Self.PARENT; end;

procedure TMenuItem_PSHelper.MENUINDEX_W(const T: INTEGER);
begin Self.MENUINDEX := T; end;

procedure TMenuItem_PSHelper.MENUINDEX_R(var T: INTEGER);
begin T := Self.MENUINDEX; end;

procedure TMenuItem_PSHelper.ITEMS_R(var T: TMENUITEM; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

procedure TMenuItem_PSHelper.COUNT_R(var T: INTEGER);
begin T := Self.COUNT; end;

procedure TMenuItem_PSHelper.HANDLE_R(var T: HMENU);
begin T := Self.HANDLE; end;

procedure TMenuItem_PSHelper.COMMAND_R(var T: WORD);
begin T := Self.COMMAND; end;


procedure RIRegisterTMENUITEM(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TMenuItem) do
	begin
		RegisterConstructor(@TMenuItem.CREATE, 'Create');
		RegisterVirtualMethod(@TMenuItem.INITIATEACTION, 'InitiateAction');
		RegisterMethod(@TMenuItem.INSERT, 'Insert');
		RegisterMethod(@TMenuItem.DELETE, 'Delete');
		RegisterMethod(@TMenuItem.CLEAR, 'Clear');
		RegisterVirtualMethod(@TMenuItem.CLICK, 'Click');
{$IFNDEF FPC}
		RegisterMethod(@TMenuItem.FIND, 'Find');
		RegisterMethod(@TMenuItem.NEWTOPLINE, 'NewTopLine');
		RegisterMethod(@TMenuItem.NEWBOTTOMLINE, 'NewBottomLine');
		RegisterMethod(@TMenuItem.INSERTNEWLINEBEFORE, 'InsertNewLineBefore');
		RegisterMethod(@TMenuItem.INSERTNEWLINEAFTER, 'InsertNewLineAfter');
		RegisterMethod(@TMenuItem.RETHINKHOTKEYS, 'RethinkHotkeys');
		RegisterMethod(@TMenuItem.RETHINKLINES, 'RethinkLines');
		RegisterMethod(@TMenuItem.ISLINE, 'IsLine');
{$ENDIF}
		RegisterMethod(@TMenuItem.INDEXOF, 'IndexOf');
		RegisterMethod(@TMenuItem.GETIMAGELIST, 'GetImageList');
		RegisterMethod(@TMenuItem.GETPARENTCOMPONENT, 'GetParentComponent');
		RegisterMethod(@TMenuItem.GETPARENTMENU, 'GetParentMenu');
		RegisterMethod(@TMenuItem.HASPARENT, 'HasParent');
		RegisterMethod(@TMenuItem.ADD, 'Add');
		RegisterMethod(@TMenuItem.REMOVE, 'Remove');
{$IFNDEF FPC}
		RegisterPropertyHelper(@TMenuItem.AUTOHOTKEYS_R,@TMenuItem.AUTOHOTKEYS_W,'AutoHotkeys');
		RegisterPropertyHelper(@TMenuItem.AUTOLINEREDUCTION_R,@TMenuItem.AUTOLINEREDUCTION_W,'AutoLineReduction');
		RegisterEventPropertyHelper(@TMenuItem.ONDRAWITEM_R,@TMenuItem.ONDRAWITEM_W,'OnDrawItem');
		RegisterEventPropertyHelper(@TMenuItem.ONADVANCEDDRAWITEM_R,@TMenuItem.ONADVANCEDDRAWITEM_W,'OnAdvancedDrawItem');
		RegisterEventPropertyHelper(@TMenuItem.ONMEASUREITEM_R,@TMenuItem.ONMEASUREITEM_W,'OnMeasureItem');
{$ENDIF}
		RegisterPropertyHelper(@TMenuItem.COMMAND_R,nil,'Command');
		RegisterPropertyHelper(@TMenuItem.HANDLE_R,nil,'Handle');
		RegisterPropertyHelper(@TMenuItem.COUNT_R,nil,'Count');
		RegisterPropertyHelper(@TMenuItem.ITEMS_R,nil,'Items');
		RegisterPropertyHelper(@TMenuItem.MENUINDEX_R,@TMenuItem.MENUINDEX_W,'MenuIndex');
		RegisterPropertyHelper(@TMenuItem.PARENT_R,nil,'Parent');
		RegisterPropertyHelper(@TMenuItem.ACTION_R,@TMenuItem.ACTION_W,'Action');
		RegisterPropertyHelper(@TMenuItem.BITMAP_R,@TMenuItem.BITMAP_W,'Bitmap');
		RegisterPropertyHelper(@TMenuItem.CAPTION_R,@TMenuItem.CAPTION_W,'Caption');
		RegisterPropertyHelper(@TMenuItem.CHECKED_R,@TMenuItem.CHECKED_W,'Checked');
		RegisterPropertyHelper(@TMenuItem.SUBMENUIMAGES_R,@TMenuItem.SUBMENUIMAGES_W,'SubMenuImages');
		RegisterPropertyHelper(@TMenuItem.DEFAULT_R,@TMenuItem.DEFAULT_W,'Default');
		RegisterPropertyHelper(@TMenuItem.ENABLED_R,@TMenuItem.ENABLED_W,'Enabled');
		RegisterPropertyHelper(@TMenuItem.GROUPINDEX_R,@TMenuItem.GROUPINDEX_W,'GroupIndex');
		RegisterPropertyHelper(@TMenuItem.HELPCONTEXT_R,@TMenuItem.HELPCONTEXT_W,'HelpContext');
		RegisterPropertyHelper(@TMenuItem.HINT_R,@TMenuItem.HINT_W,'Hint');
		RegisterPropertyHelper(@TMenuItem.IMAGEINDEX_R,@TMenuItem.IMAGEINDEX_W,'ImageIndex');
		RegisterPropertyHelper(@TMenuItem.RADIOITEM_R,@TMenuItem.RADIOITEM_W,'RadioItem');
		RegisterPropertyHelper(@TMenuItem.SHORTCUT_R,@TMenuItem.SHORTCUT_W,'ShortCut');
		RegisterPropertyHelper(@TMenuItem.VISIBLE_R,@TMenuItem.VISIBLE_W,'Visible');
		RegisterEventPropertyHelper(@TMenuItem.ONCLICK_R,@TMenuItem.ONCLICK_W,'OnClick');
	end;
end;

{$ELSE}
{$IFNDEF FPC}
procedure TMENUITEMONMEASUREITEM_W(Self: TMenuItem; const T: TMENUMEASUREITEMEVENT);
begin Self.ONMEASUREITEM := T; end;

procedure TMENUITEMONMEASUREITEM_R(Self: TMENUITEM; var T: TMENUMEASUREITEMEVENT);
begin T := Self.ONMEASUREITEM; end;

procedure TMENUITEMONADVANCEDDRAWITEM_W(Self: TMENUITEM; const T: TADVANCEDMENUDRAWITEMEVENT);
begin Self.ONADVANCEDDRAWITEM := T; end;

procedure TMENUITEMONADVANCEDDRAWITEM_R(Self: TMENUITEM; var T: TADVANCEDMENUDRAWITEMEVENT);
begin T := Self.ONADVANCEDDRAWITEM; end;

procedure TMENUITEMONDRAWITEM_W(Self: TMENUITEM; const T: TMENUDRAWITEMEVENT);
begin Self.ONDRAWITEM := T; end;

procedure TMENUITEMONDRAWITEM_R(Self: TMENUITEM; var T: TMENUDRAWITEMEVENT);
begin T := Self.ONDRAWITEM; end;
{$ENDIF}

procedure TMENUITEMONCLICK_W(Self: TMENUITEM; const T: TNOTIFYEVENT);
begin Self.ONCLICK := T; end;

procedure TMENUITEMONCLICK_R(Self: TMENUITEM; var T: TNOTIFYEVENT);
begin T := Self.ONCLICK; end;

procedure TMENUITEMVISIBLE_W(Self: TMENUITEM; const T: BOOLEAN);
begin Self.VISIBLE := T; end;

procedure TMENUITEMVISIBLE_R(Self: TMENUITEM; var T: BOOLEAN);
begin T := Self.VISIBLE; end;

procedure TMENUITEMSHORTCUT_W(Self: TMENUITEM; const T: TSHORTCUT);
begin Self.SHORTCUT := T; end;

procedure TMENUITEMSHORTCUT_R(Self: TMENUITEM; var T: TSHORTCUT);
begin T := Self.SHORTCUT; end;

procedure TMENUITEMRADIOITEM_W(Self: TMENUITEM; const T: BOOLEAN);
begin Self.RADIOITEM := T; end;

procedure TMENUITEMRADIOITEM_R(Self: TMENUITEM; var T: BOOLEAN);
begin T := Self.RADIOITEM; end;

procedure TMENUITEMIMAGEINDEX_W(Self: TMENUITEM; const T: TIMAGEINDEX);
begin Self.IMAGEINDEX := T; end;

procedure TMENUITEMIMAGEINDEX_R(Self: TMENUITEM; var T: TIMAGEINDEX);
begin T := Self.IMAGEINDEX; end;

procedure TMENUITEMHINT_W(Self: TMENUITEM; const T: STRING);
begin Self.HINT := T; end;

procedure TMENUITEMHINT_R(Self: TMENUITEM; var T: STRING);
begin T := Self.HINT; end;

procedure TMENUITEMHELPCONTEXT_W(Self: TMENUITEM; const T: THELPCONTEXT);
begin Self.HELPCONTEXT := T; end;

procedure TMENUITEMHELPCONTEXT_R(Self: TMENUITEM; var T: THELPCONTEXT);
begin T := Self.HELPCONTEXT; end;

procedure TMENUITEMGROUPINDEX_W(Self: TMENUITEM; const T: BYTE);
begin Self.GROUPINDEX := T; end;

procedure TMENUITEMGROUPINDEX_R(Self: TMENUITEM; var T: BYTE);
begin T := Self.GROUPINDEX; end;

procedure TMENUITEMENABLED_W(Self: TMENUITEM; const T: BOOLEAN);
begin Self.ENABLED := T; end;

procedure TMENUITEMENABLED_R(Self: TMENUITEM; var T: BOOLEAN);
begin T := Self.ENABLED; end;

procedure TMENUITEMDEFAULT_W(Self: TMENUITEM; const T: BOOLEAN);
begin Self.DEFAULT := T; end;

procedure TMENUITEMDEFAULT_R(Self: TMENUITEM; var T: BOOLEAN);
begin T := Self.DEFAULT; end;

procedure TMENUITEMSUBMENUIMAGES_W(Self: TMENUITEM; const T: TCUSTOMIMAGELIST);
begin Self.SUBMENUIMAGES := T; end;

procedure TMENUITEMSUBMENUIMAGES_R(Self: TMENUITEM; var T: TCUSTOMIMAGELIST);
begin T := Self.SUBMENUIMAGES; end;

procedure TMENUITEMCHECKED_W(Self: TMENUITEM; const T: BOOLEAN);
begin Self.CHECKED := T; end;

procedure TMENUITEMCHECKED_R(Self: TMENUITEM; var T: BOOLEAN);
begin T := Self.CHECKED; end;

procedure TMENUITEMCAPTION_W(Self: TMENUITEM; const T: STRING);
begin Self.CAPTION := T; end;

procedure TMENUITEMCAPTION_R(Self: TMENUITEM; var T: STRING);
begin T := Self.CAPTION; end;

procedure TMENUITEMBITMAP_W(Self: TMENUITEM; const T: TBITMAP);
begin Self.BITMAP := T; end;

procedure TMENUITEMBITMAP_R(Self: TMENUITEM; var T: TBITMAP);
begin T := Self.BITMAP; end;

{$IFNDEF FPC}
procedure TMENUITEMAUTOLINEREDUCTION_W(Self: TMENUITEM; const T: TMENUITEMAUTOFLAG);
begin Self.AUTOLINEREDUCTION := T; end;

procedure TMENUITEMAUTOLINEREDUCTION_R(Self: TMENUITEM; var T: TMENUITEMAUTOFLAG);
begin T := Self.AUTOLINEREDUCTION; end;

procedure TMENUITEMAUTOHOTKEYS_W(Self: TMENUITEM; const T: TMENUITEMAUTOFLAG);
begin Self.AUTOHOTKEYS := T; end;

procedure TMENUITEMAUTOHOTKEYS_R(Self: TMENUITEM; var T: TMENUITEMAUTOFLAG);
begin T := Self.AUTOHOTKEYS; end;
{$ENDIF}

procedure TMENUITEMACTION_W(Self: TMENUITEM; const T: TBASICACTION);
begin Self.ACTION := T; end;

procedure TMENUITEMACTION_R(Self: TMENUITEM; var T: TBASICACTION);
begin T := Self.ACTION; end;

procedure TMENUITEMPARENT_R(Self: TMENUITEM; var T: TMENUITEM);
begin T := Self.PARENT; end;

procedure TMENUITEMMENUINDEX_W(Self: TMENUITEM; const T: INTEGER);
begin Self.MENUINDEX := T; end;

procedure TMENUITEMMENUINDEX_R(Self: TMENUITEM; var T: INTEGER);
begin T := Self.MENUINDEX; end;

procedure TMENUITEMITEMS_R(Self: TMENUITEM; var T: TMENUITEM; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

procedure TMENUITEMCOUNT_R(Self: TMENUITEM; var T: INTEGER);
begin T := Self.COUNT; end;

procedure TMENUITEMHANDLE_R(Self: TMENUITEM; var T: HMENU);
begin T := Self.HANDLE; end;

procedure TMENUITEMCOMMAND_R(Self: TMENUITEM; var T: WORD);
begin T := Self.COMMAND; end;


procedure RIRegisterTMENUITEM(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TMENUITEM) do
	begin
		RegisterConstructor(@TMENUITEM.CREATE, 'Create');
		RegisterVirtualMethod(@TMENUITEM.INITIATEACTION, 'InitiateAction');
		RegisterMethod(@TMENUITEM.INSERT, 'Insert');
		RegisterMethod(@TMENUITEM.DELETE, 'Delete');
		RegisterMethod(@TMENUITEM.CLEAR, 'Clear');
		RegisterVirtualMethod(@TMENUITEM.CLICK, 'Click');
{$IFNDEF FPC}
		RegisterMethod(@TMENUITEM.FIND, 'Find');
		RegisterMethod(@TMENUITEM.NEWTOPLINE, 'NewTopLine');
		RegisterMethod(@TMENUITEM.NEWBOTTOMLINE, 'NewBottomLine');
		RegisterMethod(@TMENUITEM.INSERTNEWLINEBEFORE, 'InsertNewLineBefore');
		RegisterMethod(@TMENUITEM.INSERTNEWLINEAFTER, 'InsertNewLineAfter');
		RegisterMethod(@TMENUITEM.RETHINKHOTKEYS, 'RethinkHotkeys');
		RegisterMethod(@TMENUITEM.RETHINKLINES, 'RethinkLines');
		RegisterMethod(@TMENUITEM.ISLINE, 'IsLine');
{$ENDIF}
		RegisterMethod(@TMENUITEM.INDEXOF, 'IndexOf');
		RegisterMethod(@TMENUITEM.GETIMAGELIST, 'GetImageList');
		RegisterMethod(@TMENUITEM.GETPARENTCOMPONENT, 'GetParentComponent');
		RegisterMethod(@TMENUITEM.GETPARENTMENU, 'GetParentMenu');
		RegisterMethod(@TMENUITEM.HASPARENT, 'HasParent');
		RegisterMethod(@TMENUITEM.ADD, 'Add');
		RegisterMethod(@TMENUITEM.REMOVE, 'Remove');
{$IFNDEF FPC}
		RegisterPropertyHelper(@TMENUITEMAUTOHOTKEYS_R,@TMENUITEMAUTOHOTKEYS_W,'AutoHotkeys');
		RegisterPropertyHelper(@TMENUITEMAUTOLINEREDUCTION_R,@TMENUITEMAUTOLINEREDUCTION_W,'AutoLineReduction');
		RegisterEventPropertyHelper(@TMENUITEMONDRAWITEM_R,@TMENUITEMONDRAWITEM_W,'OnDrawItem');
		RegisterEventPropertyHelper(@TMENUITEMONADVANCEDDRAWITEM_R,@TMENUITEMONADVANCEDDRAWITEM_W,'OnAdvancedDrawItem');
		RegisterEventPropertyHelper(@TMENUITEMONMEASUREITEM_R,@TMENUITEMONMEASUREITEM_W,'OnMeasureItem');
{$ENDIF}
		RegisterPropertyHelper(@TMENUITEMCOMMAND_R,nil,'Command');
		RegisterPropertyHelper(@TMENUITEMHANDLE_R,nil,'Handle');
		RegisterPropertyHelper(@TMENUITEMCOUNT_R,nil,'Count');
		RegisterPropertyHelper(@TMENUITEMITEMS_R,nil,'Items');
		RegisterPropertyHelper(@TMENUITEMMENUINDEX_R,@TMENUITEMMENUINDEX_W,'MenuIndex');
		RegisterPropertyHelper(@TMENUITEMPARENT_R,nil,'Parent');
		RegisterPropertyHelper(@TMENUITEMACTION_R,@TMENUITEMACTION_W,'Action');
		RegisterPropertyHelper(@TMENUITEMBITMAP_R,@TMENUITEMBITMAP_W,'Bitmap');
		RegisterPropertyHelper(@TMENUITEMCAPTION_R,@TMENUITEMCAPTION_W,'Caption');
		RegisterPropertyHelper(@TMENUITEMCHECKED_R,@TMENUITEMCHECKED_W,'Checked');
		RegisterPropertyHelper(@TMENUITEMSUBMENUIMAGES_R,@TMENUITEMSUBMENUIMAGES_W,'SubMenuImages');
		RegisterPropertyHelper(@TMENUITEMDEFAULT_R,@TMENUITEMDEFAULT_W,'Default');
		RegisterPropertyHelper(@TMENUITEMENABLED_R,@TMENUITEMENABLED_W,'Enabled');
		RegisterPropertyHelper(@TMENUITEMGROUPINDEX_R,@TMENUITEMGROUPINDEX_W,'GroupIndex');
		RegisterPropertyHelper(@TMENUITEMHELPCONTEXT_R,@TMENUITEMHELPCONTEXT_W,'HelpContext');
		RegisterPropertyHelper(@TMENUITEMHINT_R,@TMENUITEMHINT_W,'Hint');
		RegisterPropertyHelper(@TMENUITEMIMAGEINDEX_R,@TMENUITEMIMAGEINDEX_W,'ImageIndex');
		RegisterPropertyHelper(@TMENUITEMRADIOITEM_R,@TMENUITEMRADIOITEM_W,'RadioItem');
		RegisterPropertyHelper(@TMENUITEMSHORTCUT_R,@TMENUITEMSHORTCUT_W,'ShortCut');
		RegisterPropertyHelper(@TMENUITEMVISIBLE_R,@TMENUITEMVISIBLE_W,'Visible');
		RegisterEventPropertyHelper(@TMENUITEMONCLICK_R,@TMENUITEMONCLICK_W,'OnClick');
	end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

procedure RIRegister_Menus_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@SHORTCUT, 'ShortCut', cdRegister);
	S.RegisterDelphiFunction(@SHORTCUTTOKEY, 'ShortCutToKey', cdRegister);
{$IFNDEF FPC}
  S.RegisterDelphiFunction(@SHORTCUTTOTEXT, 'ShortCutToText', cdRegister);
  S.RegisterDelphiFunction(@TEXTTOSHORTCUT, 'TextToShortCut', cdRegister);
  S.RegisterDelphiFunction(@NEWMENU, 'NewMenu', cdRegister);
  S.RegisterDelphiFunction(@NEWPOPUPMENU, 'NewPopupMenu', cdRegister);
  S.RegisterDelphiFunction(@NEWSUBMENU, 'NewSubMenu', cdRegister);
  S.RegisterDelphiFunction(@NEWITEM, 'NewItem', cdRegister);
  S.RegisterDelphiFunction(@NEWLINE, 'NewLine', cdRegister);
	S.RegisterDelphiFunction(@DRAWMENUITEM, 'DrawMenuItem', cdRegister);
{$ENDIF}	
end;

{$IFDEF DELPHI10UP}{$REGION 'TMenuItemStack'}{$ENDIF}
{$IFNDEF FPC}
procedure RIRegisterTMENUITEMSTACK(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(TMenuItemStack) do
	begin
		RegisterMethod(@TMENUITEMSTACK.CLEARITEM, 'ClearItem');
	end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

procedure RIRegister_Menus(CL: TPSRuntimeClassImporter);
begin
	RIRegisterTMENUITEM(Cl);
	RIRegisterTMENU(Cl);
	RIRegisterTPOPUPMENU(Cl);
	RIRegisterTMAINMENU(Cl);
	{$IFNDEF FPC}
	RIRegisterTPOPUPLIST(Cl);
	RIRegisterTMENUITEMSTACK(Cl);
	{$ENDIF}
end;

end.
