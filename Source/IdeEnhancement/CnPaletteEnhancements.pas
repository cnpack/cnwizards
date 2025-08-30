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

unit CnPaletteEnhancements;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ���������չר�ң�ԭ��������չ����Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2021.05.08 V1.6 by LiuXiao
*               XE3 ��� FMX �������֧�ֵĸ���ճ���ȹ����� -np �ر���������ʱ
*               ��� AV������ Hook �����Ա�׼ Action �ĵ��ô����ݼ����á�
*           2014.10.07 V1.5 by LiuXiao
*               �����˳�ʱ�ӳٸ��� %TEMP%\EditorLineEnds.ttr �Ĺ����Զ�� IDE ��
*               ��ĳЩ Windows Update ����ͻ�Ӷ��޷��������⡣
*           2006.09.11 V1.4 by LiuXiao
*               ���Ӳ�������Ĺ���
*           2005.05.31 V1.4 by LiuXiao
*               �����Զ����� D7 ���� IDE �����˵��»��ߵĹ���
*           2005.03.09 V1.3 by LiuXiao
*               �����Զ�������������λ�õĹ���
*           2003.10.28 V1.2 by ����(QSoft)
*               �������/���з�ʽ�л�ʱ�������������¼�������
*           2003.06.23 V1.1
*               �޸�Ϊר��ע�᷽ʽ
*           2003.05.14 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPALETTEENHANCEWIZARD}

{$IFDEF COMPILER8_UP}
  {$DEFINE FIX_EDITORLINEENDS_BUG}
{$ENDIF}

{$IFDEF IDE_NP_FMX_DESIGN_BUG}
  {$DEFINE FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}
  // �� -np �������� IDE ʱ��FMX ��������尴 Ctrl+X/C/V ����� AV
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, ExtCtrls, Menus, ComCtrls, Contnrs, StdCtrls, Buttons, ActnList,
  CnWizMethodHook, Registry,
  CnCommon, CnWizUtils, CnWizNotifier, CnWizIdeUtils, CnWizConsts, CnMenuHook,
  CnConsts, CnCompUtils, CnWizClasses, CnWizMenuAction, CnWizManager, 
  {$IFDEF COMPILER7_UP}
  ActnMenus,
  {$ENDIF}
  CnWizCompilerConst, CnWizOptions;

type

//==============================================================================
// ��������չר�ң�ԭ��������չר�ң�
//==============================================================================

{ TCnPaletteEnhanceWizard }

  TCnPaletteEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
    FMenuLine: Boolean;
    FLockToolbar: Boolean;
    FClearRegSession: Boolean;
    FTempDisableLock: Boolean;
    FHookedToolbarMouseDown: Boolean;
    FOldMouseDown: TMouseEvent;
    FMainControlBar: TControlBar;
    FControlBarMenuHook: TCnMenuHook;
    FLockMenuItem: TCnMenuItemDef;

  {$IFDEF COMPILER7_UP}
    FMenuBar: TActionMainMenuBar;
  {$ENDIF}

    FEnableWizMenu: Boolean;
    FWizMenuNames: TStringList;
    FWizMenu: TMenuItem;          // һ���������������˵��Ľ�Ϊ��ʱ�����Ҫʱ�Ų������˵�
    FWizOptionMenu: TMenuItem;
    FWizSepMenu: TMenuItem;

  {$IFDEF FIX_EDITORLINEENDS_BUG}
    FFixEditorLineEndsBug: Boolean;
  {$ENDIF}

  {$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}
    FFixNPFmxDesignCopyPasteBug: Boolean;
  {$ENDIF}

{$IFDEF SUPPORT_PALETTE_ENHANCE}
    FCompFilter: Boolean;
    FCompFilterShortCut: TShortCut;
    FCompFilterPnl: TPanel;
    FCompFilterBtn: TSpeedButton;
    FCompFilterAction: TCnWizAction;

    FShowPrefix: Boolean;
    FUseSmallImg: Boolean;
    FShowDetails: Boolean;
    FAutoSelect: Boolean;
    FSearchCompMenuItem: TCnMenuItemDef;
    FSettingsMenuItem: TCnMenuItemDef;

  {$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    FComponentPalette: TTabControl;
    FMultiLine: Boolean;
    FButtonStyle: Boolean;
    FTabsMenu: Boolean;
    FHooked: Boolean;
    FMenuHook: TCnMenuHook;
    {$IFDEF COMPILER5}
    FTabMenuItem: TCnMenuItemDef;
    {$ENDIF}
    FMultiLineMenuItem: TCnMenuItemDef;
    FSepMenuItem: TCnSepMenuItemDef;

    FDivTab: Boolean;
    {$IFDEF COMPILER6_UP}
    FTabPopupItem: TMenuItem;
    FTabOnClick: TNotifyEvent;
    {$ENDIF}
  {$ELSE}
    FNewComponentPalette: TWinControl;
  {$ENDIF}

    procedure SetCompFilter(const Value: Boolean);
    procedure SetCompFilterShortCut(const Value: TShortCut);
    procedure UpdateCompFilterButton(Sender: TObject);
    procedure OnCompFilterActionExecute(Sender: TObject);
    procedure OnCompFilterActionUpdate(Sender: TObject);
    procedure OnCompFilterStyleChanged(Sender: TObject);
    procedure OnSettingChanged(Sender: TObject);
    procedure OnSearchCompItemClick(Sender: TObject);
    procedure OnSearchCompMenuCreated(Sender: TObject; MenuItem: TMenuItem);

  {$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}  // D7 �����°汾��֧�ֶ����Լ� Tab ��صĲ˵��ҽ�
  {$IFDEF COMPILER5}
    procedure OnMenuItemClick(Sender: TObject);
    procedure OnTabMenuCreated(Sender: TObject; MenuItem: TMenuItem);
  {$ELSE}
    procedure OnMenuAfterPopup(Sender: TObject; Menu: TPopupMenu);
  {$ENDIF}

    procedure OnActiveFormChanged(Sender: TObject);
    procedure OnMultiLineItemClick(Sender: TObject);
    procedure OnMultiLineMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure DoUpdateComponentPalette(AMultiLine: Boolean; AButtonStyle: Boolean);
    procedure OnSettingsItemClick(Sender: TObject);
    // ʹ���෽������Ϊ�÷������ܻ��ڶ����ͷź����
    class procedure ResizeComponentPalette(Sender: TObject);
    procedure SetTabsMenu(const Value: Boolean);
    procedure UpdateOtherWindows(OldHeight: Integer);
    procedure RegisterUserMenuItems;

    function GetComponentPalette: TTabControl;
  {$ELSE}
    function GetNewComponentPalette: TWinControl;
  {$ENDIF}
{$ENDIF}

    procedure OnIdle(Sender: TObject);
    procedure OnLockMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure OnLockToolbarItemClick(Sender: TObject);
  {$IFDEF COMPILER7_UP}
    procedure InitMenuBar;
    procedure FinalMenuBar;
  {$ENDIF}

  {$IFDEF FIX_EDITORLINEENDS_BUG}
    procedure SetFixEditorLineEndsBug(const Value: Boolean);
  {$ENDIF}
{$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}
    procedure SetFixNPFmxDesignCopyPasteBug(const Value: Boolean);
    function CheckNPFmxDesignClipboardBugExists: Boolean;
{$ENDIF}
    procedure DoConfig(Sender: TObject);
    procedure OnConfig(Sender: TObject);
    function GetMenuInsertIndex: Integer;  // ���� Tools �˵���λ�ú���
    procedure InitWizMenus;
    procedure FinalWizMenus;
    procedure RestoreWizMenus;  // �� FWizMenu �����˵���ժ�����ȸ���
    procedure AdjustMainMenuBar;
    procedure UpdateWizMenus;
    procedure InitControlBarMenu;
    procedure SetLockToolbar(const Value: Boolean);
    procedure SetTempDisableLock(const Value: Boolean);
    procedure UpdateToolbarLock;
    procedure MainControlBarOnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
{$IFDEF SUPPORT_PALETTE_ENHANCE}
  {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    property NewComponentPalette: TWinControl read GetNewComponentPalette;
  {$ELSE}
    property ComponentPalette: TTabControl read GetComponentPalette;
  {$ENDIF}
{$ENDIF}
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Loaded; override;
    class procedure GetWizardInfo(var Name, Author, Email,
      Comment: string); override;
    procedure LanguageChanged(Sender: TObject); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;
    procedure UpdateCompPalette;

{$IFDEF SUPPORT_PALETTE_ENHANCE}

  {$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    property TabsMenu: Boolean read FTabsMenu write SetTabsMenu;
    property MultiLine: Boolean read FMultiLine write FMultiLine;
    property ButtonStyle: Boolean read FButtonStyle write FButtonStyle;
    property DivTab: Boolean read FDivTab write FDivTab;
  {$ENDIF}

    property CompFilter: Boolean read FCompFilter write SetCompFilter;
    property CompFilterShortCut: TShortCut read FCompFilterShortCut write SetCompFilterShortCut;

    property ShowPrefix: Boolean read FShowPrefix write FShowPrefix;
    property UseSmallImg: Boolean read FUseSmallImg write FUseSmallImg;
    property ShowDetails: Boolean read FShowDetails write FShowDetails;
    property AutoSelect: Boolean read FAutoSelect write FAutoSelect;
{$ENDIF}

  {$IFDEF FIX_EDITORLINEENDS_BUG}
    property FixEditorLineEndsBug: Boolean read FFixEditorLineEndsBug write SetFixEditorLineEndsBug;
  {$ENDIF}

  {$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}
    property FixNPFmxDesignCopyPasteBug: Boolean read FFixNPFmxDesignCopyPasteBug write SetFixNPFmxDesignCopyPasteBug;
  {$ENDIF}
    property MenuLine: Boolean read FMenuLine write FMenuLine;
    property LockToolbar: Boolean read FLockToolbar write SetLockToolbar;
    property ClearRegSession: Boolean read FClearRegSession write FClearRegSession;
  published
    property TempDisableLock: Boolean read FTempDisableLock write SetTempDisableLock;
    {* �ⲿ����ģ��ʹ�ã����޲���������ʾ��ȫ�����⣬�����Ÿ��û�}
  end;

{$ENDIF CNWIZARDS_CNPALETTEENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPALETTEENHANCEWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnPaletteEnhanceFrm
{$IFDEF SUPPORT_PALETTE_ENHANCE}
  , CnCompFilterFrm
{$ENDIF}
  ;

const
  SCnCompFilterBtnName = 'CnCompFilterBtn';
  
  csPalEnhActive = 'PalEnhActive';
  csTabsMenuActive = 'TabsMenuActive';
  csPalMultiLine = 'PaletteMultiLine';
  csPalButtonStyle = 'PaletteButtonStyle';
  csTabsItemMenuName = 'TabsItem';
  csIDEMenuLine = 'IDEMenuLine';
  csEnableWizMenu = 'EnableWizMenu';
  csWizMenuNames = 'WizMenuNames';
  csWizMenuCaption = 'WizMenuCaption';
  csDivTabMenu = 'DivTabMenu';
  csLockToolbar = 'LockToolbar';

  // D7 �����°汾��D2010 �����ϰ汾�����÷ֿ�����Ϊ��������Ϊ��һ�£��߰汾��Ĭ�Ϲر�
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  csCompFilter = 'CompFilterInNewStyle';
{$ELSE}
  csCompFilter = 'CompFilter';
{$ENDIF}
  csCompFilterShortCut = 'CompFilterShortCut';
  csShowPrefix = 'ShowPrefix';
  csUseSmallImg = 'UseSmallImg';
  csShowDetails = 'ShowDetails';
  csAutoSelect = 'AutoSelect';
  csClearRegSession = 'ClearRegSession';

  SCN_EDITORLINEENDS_FILE = 'EditorLineEnds.ttr';

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  CompFilterDef = False;
{$ELSE}
  CompFilterDef = True;
{$ENDIF}

{$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}
  SCnEditorActionsTEditorActionListsEditCutItemExecute = '@Editoractions@TEditorActionLists@EditCutItemExecute$qqrp14System@TObject';
  SCnEditorActionsTEditorActionListsEditCopyItemExecute = '@Editoractions@TEditorActionLists@EditCopyItemExecute$qqrp14System@TObject';
  SCnEditorActionsTEditorActionListsEditPasteItemExecute = '@Editoractions@TEditorActionLists@EditPasteItemExecute$qqrp14System@TObject';

  SCnEditCutCommand = 'EditCutCommand';
  SCnEditCopyCommand = 'EditCopyCommand';
  SCnEditPasteCommand = 'EditPasteCommand';
{$ENDIF}

type
  TControlHack = class(TControl);

{$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}
  TCnEditClipboardProc = procedure(ASelf, ASender: TObject);
{$ENDIF}

{$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}
var
  EditCutProc: TCnEditClipboardProc = nil;
  EditCopyProc: TCnEditClipboardProc = nil;
  EditPasteProc: TCnEditClipboardProc = nil;

  FCutMethodHook: TCnMethodHook = nil;
  FCopyMethodHook: TCnMethodHook = nil;
  FPasteMethodHook: TCnMethodHook = nil;
{$ENDIF}

{$IFDEF FIX_EDITORLINEENDS_BUG}
var
  FixEditorLineEndsBugGlobal: Boolean = True;
{$ENDIF}

var
  GlobalClearRegSession: Boolean = False;

{$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}

procedure MyEditCut(ASelf, ASender: TObject);
var
  A: TCustomAction;
begin
  if FCutMethodHook <> nil then
  begin
    FCutMethodHook.UnhookMethod;
    try
      try
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE Main Form Enhancement. Hook Enter Cut.');
{$ENDIF}
        EditCutProc(ASelf, ASender);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE Main Form Enhancement. Hook Cut Execute OK.');
{$ENDIF}
      except
        // FMX �¿��ܳ�������
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE Main Form Enhancement. Cut Exception! Call Alternative Action.');
{$ENDIF}
        A := GetIDEActionFromName(SCnEditCutCommand);
        if A <> nil then
          A.Execute;
      end;
    finally
      FCutMethodHook.HookMethod;
    end;
  end;
end;

procedure MyEditCopy(ASelf, ASender: TObject);
var
  A: TCustomAction;
begin
  if FCopyMethodHook <> nil then
  begin
    FCopyMethodHook.UnhookMethod;
    try
      try
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE Main Form Enhancement. Hook Enter Copy.');
{$ENDIF}
        EditCopyProc(ASelf, ASender);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE Main Form Enhancement. Hook Copy Execute OK.');
{$ENDIF}
      except
        // FMX �¿��ܳ�������
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE Main Form Enhancement. Copy Exception! Call Alternative Action.');
{$ENDIF}
        A := GetIDEActionFromName(SCnEditCopyCommand);
        if A <> nil then
          A.Execute;
      end;
    finally
      FCopyMethodHook.HookMethod;
    end;
  end;
end;

procedure MyEditPaste(ASelf, ASender: TObject);
var
  A: TCustomAction;
begin
  if FPasteMethodHook <> nil then
  begin
    FPasteMethodHook.UnhookMethod;
    try
      try
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE Main Form Enhancement. Hook Enter Paste.');
{$ENDIF}
        EditPasteProc(ASelf, ASender);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE Main Form Enhancement. Hook Paste Execute OK.');
{$ENDIF}
      except
        // FMX �¿��ܳ�������
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE Main Form Enhancement. Paste Exception! Call Alternative Action.');
{$ENDIF}
        A := GetIDEActionFromName(SCnEditPasteCommand);
        if A <> nil then
          A.Execute;
      end;
    finally
      FPasteMethodHook.HookMethod;
    end;
  end;
end;

{$ENDIF}

{$IFDEF FIX_EDITORLINEENDS_BUG}

procedure FixEditorLineEndsTtrBug;
var
  Src, Dst, Bat: string;
  Bats: TStrings;
begin
  if not FixEditorLineEndsBugGlobal then
    Exit;

  Src := MakePath(GetWindowsTempPath) + SCN_EDITORLINEENDS_FILE;
  Dst := _CnChangeFileExt(SCN_EDITORLINEENDS_FILE,
    '.cnw' + FormatDateTime('yyyymmddhhnnsszzz', Now));
  if FileExists(Src) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('FixEditorLineEndsTtrBug will Rename %s to %s', [Src, Dst]);
{$ENDIF}
//    MoveFile(Src, Dst);  // Will cause IDE hang
    Bats := TStringList.Create;
    try
      Bats.Add('choice /t 2 /d y /n >nul');
      Bats.Add('REN "' + Src + '" "' + Dst + '"');
      Bats.Add('DEL "' + MakePath(GetWindowsTempPath) +
        _CnChangeFileExt(SCN_EDITORLINEENDS_FILE, '.cnw') + '*"');
      Bat := MakePath(GetWindowsTempPath) + 'CNW_FIX.bat';
      Bats.SaveToFile(Bat);
      WinExecute(Bat, SW_HIDE);
    finally
      Bats.Free;
    end;
  end;
end;

{$ENDIF}

procedure ClearRegistrySessionProject;
const
  SCnProject = 'Project';
var
  S: string;
  Reg: TRegistry;
begin
  if not GlobalClearRegSession then
    Exit;

  S := SCnIDERegPaths[Compiler] + '\Session';
{$IFDEF DEBUG}
  CnDebugger.LogFmt('To ClearRegistrySessionProject: %s', [S]);
{$ENDIF}

  Reg := nil;

  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;

    if Reg.OpenKey(S, False) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('ClearRegistrySessionProject to Delete Value %s', [SCnProject]);
{$ENDIF}
      if Reg.ValueExists(SCnProject) then
        Reg.DeleteValue(SCnProject);
    end;
  finally
    Reg.Free;
  end;
end;

//==============================================================================
// ��������չר��
//==============================================================================

{ TCnPaletteEnhanceWizard }

constructor TCnPaletteEnhanceWizard.Create;
begin
  inherited;
  InitWizMenus;
  InitControlBarMenu;

{$IFDEF SUPPORT_PALETTE_ENHANCE}
  FCompFilterAction := WizActionMgr.AddAction('CnCompFilter',
    SCnSearchComponent, 0, OnCompFilterActionExecute,
    'CnCompFilter', SCnSearchComponent);
  if FCompFilterAction <> nil then
    FCompFilterAction.OnUpdate := OnCompFilterActionUpdate;
{$ENDIF}

{$IFNDEF COMPILER8_UP}
  FMenuHook := TCnMenuHook.Create(nil);
  CnWizNotifierServices.AddActiveFormNotifier(OnActiveFormChanged);
{$IFDEF COMPILER6_UP}
  FDivTab := True;
{$ENDIF}
{$ENDIF COMPILER8_UP}

{$IFDEF FIX_EDITORLINEENDS_BUG}
  FixEditorLineEndsBug := True;
{$ENDIF}

{$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}
  FixNPFmxDesignCopyPasteBug := CheckNPFmxDesignClipboardBugExists;
{$ENDIF}
  CnWizNotifierServices.AddApplicationIdleNotifier(OnIdle);
end;

destructor TCnPaletteEnhanceWizard.Destroy;
begin
{$IFDEF COMPILER7_UP}
  CnWizNotifierServices.RemoveApplicationIdleNotifier(OnIdle);
  FinalMenuBar;
{$ENDIF COMPILER7_UP}

{$IFNDEF COMPILER8_UP}
  CnWizNotifierServices.RemoveActiveFormNotifier(OnActiveFormChanged);
  FMenuHook.Free;
{$ENDIF COMPILER8_UP}

{$IFDEF SUPPORT_PALETTE_ENHANCE}
  if FCompFilterAction <> nil then
    WizActionMgr.DeleteAction(FCompFilterAction);
{$ENDIF}

  FControlBarMenuHook.Free;
  FinalWizMenus;
  GlobalClearRegSession := FClearRegSession;
  inherited;
end;

{$IFDEF SUPPORT_PALETTE_ENHANCE}
{$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}

function TCnPaletteEnhanceWizard.GetComponentPalette: TTabControl;
begin
  if not Assigned(FComponentPalette) then
    FComponentPalette := GetComponentPaletteTabControl;

  Assert(Assigned(FComponentPalette));
  Result := FComponentPalette;
end;

{$ELSE}

function TCnPaletteEnhanceWizard.GetNewComponentPalette: TWinControl;
begin
  if not Assigned(FNewComponentPalette) then
    FNewComponentPalette := GetNewComponentPaletteComponentPanel;

  // Do NOT Terminate for New ComponentPalette may be Created Later then CnPack Init.
  // Assert(Assigned(FNewComponentPalette));
  Result := FNewComponentPalette;
end;

{$ENDIF}
{$ENDIF}

//------------------------------------------------------------------------------
// ����������л�
//------------------------------------------------------------------------------

{$IFDEF SUPPORT_PALETTE_ENHANCE}

{$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}

procedure TCnPaletteEnhanceWizard.OnActiveFormChanged(Sender: TObject);
var
  PopupMenu: TPopupMenu;
begin
  if FHooked then Exit;

  PopupMenu := GetComponentPalettePopupMenu;
  Assert(Assigned(PopupMenu));

  // �ҽ��������Ҽ��˵�
  if not FMenuHook.IsHooked(PopupMenu) then
  begin
    FMenuHook.HookMenu(PopupMenu);
    if PopupMenu.Images = nil then
      PopupMenu.Images := GetIDEImageList;
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Hooked ComponentPalette''s PopupMenu.');
  {$ENDIF}
  end;

  UpdateCompPalette;
  FHooked := True;
end;

class procedure TCnPaletteEnhanceWizard.ResizeComponentPalette(Sender: TObject);
var
  H : Integer;
begin
  with (Sender as TTabControl) do
  begin
    H := Height + DisplayRect.Top - DisplayRect.Bottom + 29;
    Constraints.MinHeight := H;
    Parent.Constraints.MaxHeight := H;
  end;
end;

procedure TCnPaletteEnhanceWizard.DoUpdateComponentPalette(AMultiLine: Boolean;
  AButtonStyle: Boolean);
var
  H: Integer;
  AForm: TCustomForm;
begin
  if Assigned(ComponentPalette) then
  begin
    H := 0;
    AForm := GetIDEMainForm;
    if AForm <> nil then
      H := AForm.Height;

    if FButtonStyle <> (ComponentPalette.Style = tsFlatButtons) then
    begin
      if FButtonStyle then
        ComponentPalette.Style := tsFlatButtons
      else
        ComponentPalette.Style := tsTabs;

      UpdateOtherWindows(H);        
    end;

    if ComponentPalette.MultiLine <> AMultiLine then
    begin
      ComponentPalette.MultiLine := AMultiLine;

      if AMultiLine then
      begin
        ComponentPalette.OnResize := ResizeComponentPalette;
        ComponentPalette.OnResize(ComponentPalette);
      end
      else
        ComponentPalette.OnResize := nil;

      UpdateOtherWindows(H);
    end;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnMultiLineItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    MultiLine := not MultiLine;
    (Sender as TMenuItem).Checked := MultiLine;
    DoUpdateComponentPalette(MultiLine, FButtonStyle);

    // �������/���з�ʽ�л�ʱ�������������¼�������
    if ComponentPalette.Visible and ComponentPalette.Enabled then
      ComponentPalette.SetFocus;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnMultiLineMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
begin
  MenuItem.Checked := MultiLine;
end;

procedure TCnPaletteEnhanceWizard.OnSettingsItemClick(Sender: TObject);
begin
  Config;
end;

procedure TCnPaletteEnhanceWizard.UpdateOtherWindows(OldHeight: Integer);
const
  WinClasses: array[0..2] of string = ('TObjectTreeView',
    'TPropertyInspector', 'TEditWindow');
var
  AForm: TCustomForm;
  I, J, MainTop, HeightDelta: Integer;
begin
  AForm := GetIDEMainForm;
  if AForm = nil then Exit;
  HeightDelta := AForm.Height - OldHeight;
  if HeightDelta = 0 then Exit;
  MainTop := AForm.Top;

  for I := Low(WinClasses) to High(WinClasses) do
  begin
    for J := 0 to Screen.CustomFormCount - 1 do
    begin
      if Screen.CustomForms[J].ClassNameIs(WinClasses[I]) then
      begin
        AForm := Screen.CustomForms[J];
        if Abs(AForm.Top - (MainTop + OldHeight)) < 10 then // ����ԭ�������� IDE ����������
        begin
          AForm.Top := AForm.Top + HeightDelta;
          AForm.Height := AForm.Height - HeightDelta;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// ���� Tabs �˵���
//------------------------------------------------------------------------------

procedure TCnPaletteEnhanceWizard.RegisterUserMenuItems;
begin
  FSepMenuItem := TCnSepMenuItemDef.Create(ipFirst, '');
  FMenuHook.AddMenuItemDef(FSepMenuItem);

{$IFDEF COMPILER5}
  FMultiLineMenuItem := TCnMenuItemDef.Create(SCnPaletteMutiLineMenuName,
    SCnPaletteMultiLineMenuCaption, OnMultiLineItemClick, ipFirst, '');
{$ELSE}
  FMultiLineMenuItem := TCnMenuItemDef.Create(SCnPaletteMutiLineMenuName,
    SCnPaletteMultiLineMenuCaption, OnMultiLineItemClick, ipAfter, csTabsItemMenuName);
{$ENDIF COMPILER5}
  FMultiLineMenuItem.OnCreated := OnMultiLineMenuCreated;
  FMenuHook.AddMenuItemDef(FMultiLineMenuItem);

{$IFDEF SUPPORT_PALETTE_ENHANCE}
  FSearchCompMenuItem := TCnMenuItemDef.Create(SCnPaletteSearchCompMenuName,
    SCnSearchComponent, OnSearchCompItemClick, ipAfter, SCnPaletteMutiLineMenuName);

  FSearchCompMenuItem.OnCreated := OnSearchCompMenuCreated;
  FMenuHook.AddMenuItemDef(FSearchCompMenuItem);
{$ENDIF}

  FSettingsMenuItem := TCnMenuItemDef.Create(SCnPaletteSettingsMenuName,
    SCnPalSettingsCaption, OnSettingsItemClick, ipAfter, SCnPaletteSearchCompMenuName);
  FSettingsMenuItem.SetImageIndex(CnWizardMgr.ImageIndexByWizardClassNameAndCommand(
    'TCnIdeEnhanceMenuWizard', SCnIdeEnhanceMenuCommand + 'TCnPaletteEnhanceWizard'));

  FMenuHook.AddMenuItemDef(FSettingsMenuItem);
{$IFDEF COMPILER5}
  FTabMenuItem := TCnMenuItemDef.Create(SCnPaletteTabsMenuName,
    SCnPaletteTabsMenuCaption, nil, ipFirst, '');
  FTabMenuItem.OnCreated := OnTabMenuCreated;
  FMenuHook.AddMenuItemDef(FTabMenuItem);
{$ELSE}
  FMenuHook.OnAfterPopup := OnMenuAfterPopup;
{$ENDIF COMPILER5}
end;

{$IFDEF COMPILER5}
procedure TCnPaletteEnhanceWizard.OnTabMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
var
  I: Integer;
  AItem: TMenuItem;
  List: TStringList;
  Tab: string;
  IndexTab, DivCount: Integer;
begin
  MenuItem.Visible := TabsMenu;
  DivCount := (Screen.Height - TForm(GetIDEMainForm).Height) div GetMainMenuItemHeight;
  if TabsMenu then
  begin
    List := TStringList.Create;
    try
      List.Assign(ComponentPalette.Tabs);
      for I := 0 to ComponentPalette.Tabs.Count - 1 do
        List.Objects[I] := TObject(I);

      Tab := List.Strings[ComponentPalette.TabIndex];
      List.Sort;
      IndexTab := List.IndexOf(Tab);

      for I := 0 to List.Count - 1 do
      begin
        AItem := TMenuItem.Create(nil);
        AItem.Caption := List[I];
        AItem.Tag := Integer(List.Objects[I]);
        if I = IndexTab then
          AItem.Checked := True;

        if FDivTab and (I > 0) and (I mod DivCount = 0) then
          AItem.Break := mbBarBreak;
        AItem.OnClick := OnMenuItemClick;
        MenuItem.Add(AItem);
      end;
    finally
      List.Free;
    end;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnMenuItemClick(Sender: TObject);
begin
  ComponentPalette.TabIndex := (Sender as TMenuItem).Tag;
  if Assigned(ComponentPalette.OnChange) then
    ComponentPalette.OnChange(ComponentPalette);
end;

{$ELSE}

procedure TCnPaletteEnhanceWizard.OnMenuAfterPopup(Sender: TObject;
  Menu: TPopupMenu);
const
  csTabsItem = 'TabsItem';
var
  I, DivCount: Integer;
{$IFDEF DELPHI7}
  J, TabArrayLen: Integer;
  RemovedItem: TMenuItem;
  TabStartArray, TabEndArray: array of Integer;
  MoreItems, SepItems: array of TMenuItem;
{$ENDIF}
begin
  if FTabPopupItem = nil then
  begin
    for I := 0 to Menu.Items.Count - 1 do
    begin
      if Menu.Items.Items[I].Name = csTabsItem then
        FTabPopupItem := Menu.Items.Items[I];
    end;
  end;

  if FTabPopupItem = nil then
    Exit;

  if FDivTab then
  begin
    if Assigned(FTabPopupItem.OnClick) then // Old Item
    begin
      FTabOnClick := FTabPopupItem.OnClick;
      FTabPopupItem.OnClick := nil;
    end;
    FTabOnClick(FTabPopupItem);
    // �˲����Tabs �Ӳ˵��Ѵ�����ע�����������ר��Ҳ�ҽӴ��¼������ͻ
    DivCount := (Screen.Height - TForm(GetIDEMainForm).Height - 75) div GetMainMenuItemHeight - 1;

    if FTabPopupItem.Count > DivCount then // ��ҳ
    begin
{$IFDEF DELPHI7}
      TabArrayLen := (FTabPopupItem.Count div DivCount) + 1;
      SetLength(MoreItems, TabArrayLen - 1);
      SetLength(SepItems, TabArrayLen - 1);

      SetLength(TabStartArray, TabArrayLen);
      SetLength(TabEndArray, TabArrayLen);

      // ��¼��Ҫ�������ʼλ�ã������ҳʱ TabArrayLen = 1
      for I := 0 to TabArrayLen - 1 do
      begin
        // TabArrayLen �����飬�� 0 �� TabArrayLen - 1
        TabStartArray[I] := I * DivCount;
        if I < TabArrayLen - 1 then
          TabEndArray[I] := (I + 1) * DivCount - 1
        else
          TabEndArray[I] := FTabPopupItem.Count - 1;

        // TabArrayLen - 1 �����飬�� 0 �� TabArrayLen - 2
        if I <= High(MoreItems) then
        begin
          MoreItems[I] := TMenuItem.Create(Application);
          MoreItems[I].Caption := SCnPaletteMoreCaption;

          SepItems[I] := TMenuItem.Create(Application);
          SepItems[I].Caption := '-';
        end;
      end;

      for I := TabArrayLen - 1 downto 1 do
      begin
        // Start[I] �� End[I] ��Ĳ˵��ƶ��� More[I-1] ��ͷȥ
        for J := TabEndArray[I] downto TabStartArray[I] do
        begin
          RemovedItem := FTabPopupItem.Items[J];
          FTabPopupItem.Remove(RemovedItem);
          MoreItems[I - 1].Insert(0, RemovedItem);
        end;
      end;

      // ��װ More �˵�
      for I := 0 to High(MoreItems) - 1 do
      begin
        MoreItems[I].Insert(0, SepItems[I + 1]);
        MoreItems[I].Insert(0, MoreItems[I + 1]);
      end;

      // Ȼ��� More �� Sep �ӵ��Ӳ˵���ͷ
      FTabPopupItem.Insert(0, SepItems[0]);
      FTabPopupItem.Insert(0, MoreItems[0]);

      SetLength(TabStartArray, 0);
      SetLength(TabEndArray, 0);
      SetLength(MoreItems, 0);
      SetLength(SepItems, 0);

{$ELSE}  // Delphi 6 or BCB 6, ֱ�Ӹ� Break ����
      for I := 1 to FTabPopupItem.Count div DivCount do
        FTabPopupItem.Items[I * DivCount].Break := mbBarBreak;
          // �벻�� D7 ���� Break ����Ч���ǵ�������һ������
{$ENDIF}
    end;
  end
  else
  begin
    if not Assigned(FTabPopupItem.OnClick) then
      FTabPopupItem.OnClick := FTabOnClick;
  end;
end;

{$ENDIF COMPILER5}

procedure TCnPaletteEnhanceWizard.SetTabsMenu(const Value: Boolean);
begin
  FTabsMenu := Value;
end;

{$ENDIF}

{$ENDIF}

//------------------------------------------------------------------------------
// ���Ӳ˵��»���
//------------------------------------------------------------------------------

{$IFDEF COMPILER7_UP}
procedure TCnPaletteEnhanceWizard.InitMenuBar;
var
  AForm: TCustomForm;
  I: Integer;
begin
  AForm := GetIDEMainForm;
  FMenuBar := nil;
  if AForm <> nil then
  begin
    for I := 0 to AForm.ComponentCount - 1 do
    begin
      if AForm.Components[I] is TActionMainMenuBar then
      begin
        FMenuBar := TActionMainMenuBar(AForm.Components[I]);
        Break;
      end;
    end;
  end;
  AddComponentFreeNotify(TComponent(FMenuBar), nil);
end;

procedure TCnPaletteEnhanceWizard.FinalMenuBar;
begin
  RemoveComponentFreeNotify(TComponent(FMenuBar));
end;
{$ENDIF COMPILER7_UP}

procedure TCnPaletteEnhanceWizard.OnIdle(Sender: TObject);
begin
{$IFDEF COMPILER7_UP}
  if Active and MenuLine and Assigned(FMenuBar) then
  begin
    if not FMenuBar.PersistentHotKeys then
      FMenuBar.PersistentHotKeys := True;
  end;
{$ENDIF COMPILER7_UP}

{$IFDEF SUPPORT_PALETTE_ENHANCE}
  if Active and FCompFilter and (FCompFilterBtn <> nil)
    and (CnCompFilterForm <> nil) then
    FCompFilterBtn.Down := not (CnCompFilterForm.FilterFormStyle = fsHidden);
{$ENDIF}
end;

//------------------------------------------------------------------------------
// �ƶ�ר�Ҳ˵���
//------------------------------------------------------------------------------

procedure TCnPaletteEnhanceWizard.InitWizMenus;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InitWizMenus');
{$ENDIF}

  FEnableWizMenu := False;
  FWizMenuNames := TStringList.Create;
  FWizMenu := TMenuItem.Create(nil);
  FWizMenu.Name := SCnWizMenuName;
  FWizMenu.Caption := SCnDefWizMenuCaption;
  FWizSepMenu := AddSepMenuItem(FWizMenu);
  FWizOptionMenu := AddMenuItem(FWizMenu, SCnWizConfigCaption, OnConfig);
  FWizOptionMenu.Name := SCnWizOptionMenuName;
end;

procedure TCnPaletteEnhanceWizard.FinalWizMenus;
begin
  RestoreWizMenus;
  FWizSepMenu.Free;
  FWizOptionMenu.Free;
  FWizMenu.Free;
  FWizMenuNames.Free;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('FinalWizMenus');
{$ENDIF}
end;

function TCnPaletteEnhanceWizard.GetMenuInsertIndex: Integer;
var
  MainMenu: TMainMenu;
  ToolsMenu: TMenuItem;
begin
  Result := 0;
  MainMenu := GetIDEMainMenu;
  if Assigned(MainMenu) then
  begin
    ToolsMenu := GetIDEToolsMenu;
    if Assigned(ToolsMenu) then
      Result := MainMenu.Items.IndexOf(ToolsMenu)
    else
      Result := MainMenu.Items.Count - 1;
  end;      
end;

procedure TCnPaletteEnhanceWizard.RestoreWizMenus;
var
  MainMenu: TMainMenu;
  MenuItem: TMenuItem;
  Idx: Integer;
begin
  MainMenu := GetIDEMainMenu;
  if Assigned(MainMenu) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('RestoreWizMenus');
  {$ENDIF}

    Idx := GetMenuInsertIndex;
    while FWizMenu.Count > 2 do
    begin
      MenuItem := FWizMenu[0];
      FWizMenu.Remove(MenuItem);
      MainMenu.Items.Insert(Idx + 1, MenuItem);
    end;
    if FWizMenu.Parent = MainMenu.Items then
      MainMenu.Items.Remove(FWizMenu);
  end;    
end;

procedure TCnPaletteEnhanceWizard.AdjustMainMenuBar;
const
  sMenuBar = 'MenuBar';
var
  List: TList;
  I, J: Integer;
  ViewBar, MenuBar: TToolBar;
  ControlBar: TControlBar;
  LeftCtrl: TControl;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('AdjustMainMenuBar');
{$ENDIF}

  ViewBar := (BorlandIDEServices as INTAServices).ToolBar[sViewToolBar];
  if Assigned(ViewBar) and (ViewBar.Parent is TControlBar) then
  begin
    ControlBar := TControlBar(ViewBar.Parent);
    MenuBar := nil;
    for I := 0 to ControlBar.ControlCount - 1 do
    begin
      if SameText(ControlBar.Controls[I].Name, sMenuBar) then
      begin
        MenuBar := TToolBar(ControlBar.Controls[I]);
        Break;
      end;
    end;

    if not Assigned(MenuBar) then
      Exit;

    // �Ѳ˵���ͬ���߶ȵ��ұߵĿؼ����󼷹�ȥ��������ֿ�϶
    List := TList.Create;
    try
      for I := 0 to ControlBar.ControlCount - 1 do
      begin
        if (ControlBar.Controls[I] <> MenuBar) and
          (ControlBar.Controls[I].Top = MenuBar.Top) then
        begin
          J := 0;
          while (J < List.Count) and (ControlBar.Controls[I].Left >
            TControl(List[J]).Left) do
            Inc(J);
          List.Insert(J, ControlBar.Controls[I]);
        end;
      end;

      for I := 0 to List.Count - 1 do
      begin
        if I = 0 then
          LeftCtrl := MenuBar
        else
          LeftCtrl := TControl(List[I - 1]);
        TControl(List[I]).Left := LeftCtrl.Left + LeftCtrl.Width;
      end;  
    finally
      List.Free;
    end;                  
  end;
end;

procedure TCnPaletteEnhanceWizard.UpdateWizMenus;
var
  MainMenu: TMainMenu;
  I: Integer;

  procedure DoInsertMenu(AMenu: TMenuItem; const AName: string);
  var
    I: Integer;
    MenuItem: TMenuItem;
  begin
    for I := MainMenu.Items.Count - 1 downto 0 do
    begin
      if SameText(MainMenu.Items[I].Name, AName) then
      begin
        MenuItem := MainMenu.Items[I];
        MainMenu.Items.Remove(MenuItem);
        AMenu.Insert(0, MenuItem);
        Break;
      end;
    end;
  end;
begin
  RestoreWizMenus;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('UpdateWizMenus');
{$ENDIF}

  MainMenu := GetIDEMainMenu;
  if Assigned(MainMenu) and Active and FEnableWizMenu and
    (FWizMenuNames.Count > 0) then
  begin
    for I := FWizMenuNames.Count - 1 downto 0 do    // ��������Ҫ���������Ĳ˵������������� FWizMenu ��
      DoInsertMenu(FWizMenu, FWizMenuNames[I]);

    MainMenu.Items.Insert(GetMenuInsertIndex + 1, FWizMenu); // �ٰ� FWizMenu �����˵���
    AdjustMainMenuBar; // �˵��������¶�գ�Ҫ�Ѳ˵���ͬ���߶ȵ��ұ߿ؼ�����
  end;
end;

//------------------------------------------------------------------------------
// ��������
//------------------------------------------------------------------------------

procedure TCnPaletteEnhanceWizard.UpdateCompPalette;
begin
{$IFNDEF COMPILER8_UP}
  FMenuHook.Active := Active;
  DoUpdateComponentPalette(Active and MultiLine, Active and ButtonStyle);
{$ENDIF COMPILER8_UP}
end;

//------------------------------------------------------------------------------
// ��������
//------------------------------------------------------------------------------

procedure TCnPaletteEnhanceWizard.LoadSettings(Ini: TCustomIniFile);
begin
{$IFNDEF COMPILER8_UP}
  FTabsMenu := Ini.ReadBool('', csTabsMenuActive, True);
  FMultiLine := Ini.ReadBool('', csPalMultiLine, False);
  FButtonStyle := Ini.ReadBool('', csPalButtonStyle, False);
  FDivTab := Ini.ReadBool('', csDivTabMenu, True);
{$ENDIF COMPILER8_UP}

{$IFDEF SUPPORT_PALETTE_ENHANCE}
  FCompFilter := Ini.ReadBool('', csCompFilter, CompFilterDef);
  FCompFilterShortCut := Ini.ReadInteger('', csCompFilterShortCut, 0);
  FShowPrefix := Ini.ReadBool('', csShowPrefix, False);
  FUseSmallImg := Ini.ReadBool('', csUseSmallImg, False);
  FShowDetails := Ini.ReadBool('',  csShowDetails, True);
  FAutoSelect := Ini.ReadBool('', csAutoSelect, True);
{$ENDIF}
  FMenuLine := Ini.ReadBool('', csIDEMenuLine, False);
  FLockToolbar := Ini.ReadBool('', csLockToolbar, False);
  FClearRegSession := Ini.ReadBool('', csClearRegSession, False);

  FEnableWizMenu := Ini.ReadBool(WizOptions.CompilerID, csEnableWizMenu, FEnableWizMenu);
  FWizMenuNames.CommaText := Ini.ReadString(WizOptions.CompilerID, csWizMenuNames, FWizMenuNames.CommaText);
  FWizMenu.Caption := Ini.ReadString(WizOptions.CompilerID, csWizMenuCaption, FWizMenu.Caption);
  if Trim(FWizMenu.Caption) = '' then
    FWizMenu.Caption := SCnDefWizMenuCaption; // ��ֹ�յ�

  UpdateCompPalette;
  if FLockToolbar then
    UpdateToolbarLock;

  if FClearRegSession then
  begin
    GlobalClearRegSession := True;
    ClearRegistrySessionProject; // �������ˣ�����ʱҲ���һ��
  end;
end;

procedure TCnPaletteEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
begin
{$IFNDEF COMPILER8_UP}
  Ini.WriteBool('', csTabsMenuActive, FMenuHook.Active);
  Ini.WriteBool('', csPalMultiLine, FMultiLine);
  Ini.WriteBool('', csPalButtonStyle, FButtonStyle);
  Ini.WriteBool('', csDivTabMenu, FDivTab);
{$ENDIF}

{$IFDEF SUPPORT_PALETTE_ENHANCE}
  Ini.WriteBool('', csCompFilter, FCompFilter);
  Ini.WriteInteger('', csCompFilterShortCut, FCompFilterShortCut);
  Ini.WriteBool('', csShowPrefix, FShowPrefix);
  Ini.WriteBool('', csUseSmallImg, FUseSmallImg);
  Ini.WriteBool('',  csShowDetails, FShowDetails);
  Ini.WriteBool('', csAutoSelect, FAutoSelect);
{$ENDIF}

  Ini.WriteBool('', csIDEMenuLine, FMenuLine);
  Ini.WriteBool('', csLockToolbar, FLockToolbar);
  Ini.WriteBool('', csClearRegSession, FClearRegSession);

  Ini.WriteBool(WizOptions.CompilerID, csEnableWizMenu, FEnableWizMenu);
  Ini.WriteString(WizOptions.CompilerID, csWizMenuNames, FWizMenuNames.CommaText);
  if SameText(FWizMenu.Caption, SCnDefWizMenuCaption) then
    Ini.DeleteKey(WizOptions.CompilerID, csWizMenuCaption)
  else
    Ini.WriteString(WizOptions.CompilerID, csWizMenuCaption, FWizMenu.Caption);
end;

class procedure TCnPaletteEnhanceWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := SCnPaletteEnhanceWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnPaletteEnhanceWizardComment;
end;

function TCnPaletteEnhanceWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

procedure TCnPaletteEnhanceWizard.OnConfig(Sender: TObject);
begin
  Config;
end;

procedure TCnPaletteEnhanceWizard.Config;
begin
  // ���ͨ���˵����ø÷���������δ֪��ԭ��FWizMenu.Count Ϊ 0 ���޷���������
  // �˴��ĳ�ͨ�� Idle ��ִ�� Config �����Խ��������
  CnWizNotifierServices.ExecuteOnApplicationIdle(DoConfig);
end;

procedure TCnPaletteEnhanceWizard.DoConfig(Sender: TObject);
begin
  with TCnPalEnhanceForm.Create(nil) do
  try
  {$IFNDEF COMPILER8_UP}
    chkAddTabs.Checked := TabsMenu;
    chkMultiLine.Checked := MultiLine;
    chkButtonStyle.Checked := ButtonStyle;
    chkDivTabMenu.Checked := DivTab;
  {$ENDIF COMPILER8_UP}

  {$IFDEF SUPPORT_PALETTE_ENHANCE}
    chkCompFilter.Checked := CompFilter;
    hkCompFilter.HotKey := CompFilterShortCut;
  {$ELSE}
    chkCompFilter.Enabled := False;
    hkCompFilter.Enabled := False;
  {$ENDIF}

    chkMenuLine.Checked := MenuLine;
    chkLockToolbar.Checked := LockToolbar;
    chkClearRegSessionProject.Checked := ClearRegSession;

    chkMoveWizMenus.Checked := FEnableWizMenu;
    edtMoveToUser.Text := FWizMenu.Caption;
    SetWizMenuNames(FWizMenuNames, FWizMenu);

    if ShowModal = mrOK then
    begin
    {$IFNDEF COMPILER8_UP}
      TabsMenu := chkAddTabs.Checked;
      MultiLine := chkMultiLine.Checked;
      ButtonStyle := chkButtonStyle.Checked;
      DivTab := chkDivTabMenu.Checked;
    {$ENDIF COMPILER8_UP}

    {$IFDEF SUPPORT_PALETTE_ENHANCE}
      CompFilter := chkCompFilter.Checked;
      CompFilterShortCut := hkCompFilter.HotKey;
    {$ENDIF}

      MenuLine := chkMenuLine.Checked;
      LockToolbar := chkLockToolbar.Checked;
      ClearRegSession := chkClearRegSessionProject.Checked;

      FEnableWizMenu := chkMoveWizMenus.Checked;
      FWizMenu.Caption := edtMoveToUser.Text;
      if Trim(FWizMenu.Caption) = '' then
        FWizMenu.Caption := SCnDefWizMenuCaption; // ��ֹ�յ�

      GetWizMenuNames(FWizMenuNames);

      DoSaveSettings;

      UpdateCompPalette;
      UpdateWizMenus;
    end;
  finally
    Free;
  end;
end;

procedure TCnPaletteEnhanceWizard.SetActive(Value: Boolean);
begin
  inherited;
  UpdateCompPalette;
  UpdateWizMenus;
{$IFDEF SUPPORT_PALETTE_ENHANCE}
  {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  CnWizNotifierServices.ExecuteOnApplicationIdle(UpdateCompFilterButton);
  {$ELSE}
  UpdateCompFilterButton(nil);
  {$ENDIF}
{$ENDIF}
end;

procedure TCnPaletteEnhanceWizard.LanguageChanged(Sender: TObject);
begin
  FWizOptionMenu.Caption := SCnWizConfigCaption;
{$IFDEF SUPPORT_PALETTE_ENHANCE}
  {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  CnWizNotifierServices.ExecuteOnApplicationIdle(UpdateCompFilterButton);
  {$ELSE}
  UpdateCompFilterButton(nil);
  {$ENDIF}
  if FSearchCompMenuItem <> nil then
    FSearchCompMenuItem.SetCaption(SCnSearchComponent);
  if FSettingsMenuItem <> nil then
    FSettingsMenuItem.SetCaption(SCnPalSettingsCaption);
{$ENDIF}

{$IFNDEF COMPILER8_UP}
  if FMultiLineMenuItem <> nil then
    FMultiLineMenuItem.SetCaption(SCnPaletteMultiLineMenuCaption);
{$ENDIF}
  FWizOptionMenu.Hint := StripHotkey(SCnWizConfigCaption);
  if FLockMenuItem <> nil then
    FLockMenuItem.SetCaption(SCnLockToolbarMenuCaption);
end;

procedure TCnPaletteEnhanceWizard.Loaded;
begin
  inherited;
{$IFNDEF COMPILER8_UP}
  RegisterUserMenuItems;
{$ENDIF COMPILER8_UP}

{$IFDEF SUPPORT_PALETTE_ENHANCE}
  {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  CnWizNotifierServices.ExecuteOnApplicationIdle(UpdateCompFilterButton);
  {$ELSE}
  UpdateCompFilterButton(nil);
  {$ENDIF}
{$ENDIF}

{$IFDEF COMPILER7_UP}
  InitMenuBar;
{$ENDIF COMPILER7_UP}

  UpdateWizMenus;
end;

{$IFDEF SUPPORT_PALETTE_ENHANCE}

procedure TCnPaletteEnhanceWizard.SetCompFilter(const Value: Boolean);
begin
  if FCompFilter <> Value then
  begin
    FCompFilter := Value;
    {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    CnWizNotifierServices.ExecuteOnApplicationIdle(UpdateCompFilterButton);
    {$ELSE}
    UpdateCompFilterButton(nil);
    {$ENDIF}
  end;
end;

procedure TCnPaletteEnhanceWizard.SetCompFilterShortCut(
  const Value: TShortCut);
begin
  FCompFilterShortCut := Value;
  if FCompFilterAction <> nil then
    FCompFilterAction.ShortCut := Value;
end;

procedure TCnPaletteEnhanceWizard.UpdateCompFilterButton(Sender: TObject);
begin
  if Active and FCompFilter then
  begin
    if FCompFilterAction <> nil then
      FCompFilterAction.ShortCut := FCompFilterShortCut;

    if FCompFilterPnl = nil then
    begin
      FCompFilterPnl := TPanel.Create(Application);
      FCompFilterPnl.Name := 'CnCompFilterPnl';
      FCompFilterPnl.Caption := '';
    {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
      FCompFilterPnl.Parent := NewComponentPalette;
    {$ELSE}
      FCompFilterPnl.Parent := ComponentPalette;
    {$ENDIF}
      FCompFilterPnl.BorderWidth := 0;
      FCompFilterPnl.BevelInner := bvNone;
      FCompFilterPnl.BevelOuter := bvNone;
      FCompFilterPnl.Anchors := [akRight, akBottom];
      FCompFilterPnl.Height := 12;
      FCompFilterPnl.Width := 12;
    {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
      FCompFilterPnl.Left := NewComponentPalette.Width - FCompFilterPnl.Width - 1;
      FCompFilterPnl.Top := NewComponentPalette.Height - FCompFilterPnl.Height - 1;
    {$ELSE}
      FCompFilterPnl.Left := ComponentPalette.Width - FCompFilterPnl.Width - 1;
      FCompFilterPnl.Top := ComponentPalette.Height - FCompFilterPnl.Height - 1;
    {$ENDIF}
    end;

    if FCompFilterBtn = nil then
    begin
      FCompFilterBtn := TSpeedButton.Create(Application);
      FCompFilterBtn.Name := 'CnCompFilterBtn';

      FCompFilterBtn.Parent := FCompFilterPnl;
      FCompFilterBtn.Flat := True;
      FCompFilterBtn.Action := FCompFilterAction;
      FCompFilterBtn.Top := 1;
      FCompFilterBtn.Left := 1;
      FCompFilterBtn.Height := 11;
      FCompFilterBtn.Width := 11;
      FCompFilterBtn.GroupIndex := 1;
      FCompFilterBtn.AllowAllUp := True;
      FCompFilterBtn.ShowHint := True;
      FCompFilterBtn.Font.Name := 'Wingdings'; {Do NOT localize.}
      FCompFilterBtn.Font.Size := 8;
      FCompFilterBtn.Font.Color := clTeal;
      FCompFilterBtn.BringToFront;
    end;
    
    FCompFilterBtn.Caption := '';
    CnWizLoadBitmap(FCompFilterBtn.Glyph, SCnCompFilterBtnName);

    FCompFilterBtn.Hint := SCnSearchComponent;
    FCompFilterPnl.BringToFront;
    FCompFilterBtn.Visible := True;
  end
  else
  begin
    if FCompFilterBtn <> nil then
      FCompFilterBtn.Visible := False;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnCompFilterActionUpdate(Sender: TObject);
begin
  (Sender as TCnWizAction).Enabled := FCompFilter;
end;

procedure TCnPaletteEnhanceWizard.OnCompFilterActionExecute(Sender: TObject);
var
  P: TPoint;
begin
  if CnCompFilterForm = nil then
  begin
    CnCompFilterForm := TCnCompFilterForm.Create(nil);
    CnCompFilterForm.ShowPrefix := FShowPrefix;
    CnCompFilterForm.ShowDetails := FShowDetails;
    CnCompFilterForm.AutoSelect := FAutoSelect;
    CnCompFilterForm.UseSmallImg := FUseSmallImg;

    CnCompFilterForm.OnSettingChanged := OnSettingChanged;
    CnCompFilterForm.OnStyleChanged := OnCompFilterStyleChanged;
  end;

  P.x := FCompFilterBtn.Width;
  P.y := FCompFilterBtn.Height;
  CnCompFilterForm.BasePoint := FCompFilterBtn.ClientToScreen(P);

  case CnCompFilterForm.FilterFormStyle of
    fsDropped:
      begin
        CnCompFilterForm.FilterFormStyle := fsHidden;
      end;
    fsHidden:
      begin
        if not CnCompFilterForm.JustHide then // �رպ�Ҫһ����ʱ�������
        begin
          CnCompFilterForm.FilterFormStyle := fsDropped;
          CnCompFilterForm.edtSearch.SetFocus;
        end;
      end;
    fsFloat:
      begin
        CnCompFilterForm.FilterFormStyle := fsHidden;
      end;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnCompFilterStyleChanged(
  Sender: TObject);
begin

end;

procedure TCnPaletteEnhanceWizard.OnSettingChanged(Sender: TObject);
begin
  if CnCompFilterForm <> nil then
  begin
    FShowPrefix := CnCompFilterForm.ShowPrefix;
    FShowDetails := CnCompFilterForm.ShowDetails;
    FAutoSelect := CnCompFilterForm.AutoSelect;
    FUseSmallImg := CnCompFilterForm.UseSmallImg;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnSearchCompMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
begin
  MenuItem.Checked := FCompFilter;
end;

procedure TCnPaletteEnhanceWizard.OnSearchCompItemClick(Sender: TObject);
begin
  CompFilter := not CompFilter;
end;

{$ENDIF}

procedure TCnPaletteEnhanceWizard.SetLockToolbar(const Value: Boolean);
begin
  if FLockToolbar <> Value then
  begin
    FLockToolbar := Value;
    UpdateToolbarLock;
  end;
end;

// ���¹�����������״��
procedure TCnPaletteEnhanceWizard.UpdateToolbarLock;
var
  I: Integer;
  Main: TCustomForm;
begin
  Main := GetIDEMainForm;
  if Main <> nil then
  begin
    for I := 0 to Main.ControlCount - 1 do
    begin
      if Main.Controls[I] is TControlBar then
      begin
        FMainControlBar := (Main.Controls[I] as TControlBar);

        if FLockToolbar then
        begin
          if not FHookedToolbarMouseDown then
          begin
            FOldMouseDown := FMainControlBar.OnMouseDown;
            FMainControlBar.OnMouseDown := MainControlBarOnMouseDown;
            FHookedToolbarMouseDown := True;
          end;
        end
        else
        begin
          if FHookedToolbarMouseDown then
          begin
            FMainControlBar.OnMouseDown := FOldMouseDown;
            FOldMouseDown := nil;
            FHookedToolbarMouseDown := False;
          end;
        end;
        
        // ��Ϊ��һ�� ControlBar �������ɹ������� ControlBar
        Exit;
      end;
    end;
  end;
end;

procedure TCnPaletteEnhanceWizard.MainControlBarOnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TControlBar then
  begin
    if FLockToolbar and not FTempDisableLock then
      TControlHack(Sender).MouseCapture := False
    else if Assigned(FOldMouseDown) then
      FOldMouseDown(Sender, Button, Shift, X, Y);
  end;
end;

procedure TCnPaletteEnhanceWizard.InitControlBarMenu;
var
  I: Integer;
  Main: TCustomForm;
begin
  Main := GetIDEMainForm;
  if Main <> nil then
  begin
    for I := 0 to Main.ControlCount - 1 do
    begin
      if Main.Controls[I] is TControlBar then
      begin
        FMainControlBar := (Main.Controls[I] as TControlBar);
        if FMainControlBar.PopupMenu <> nil then
        begin
          if FControlBarMenuHook = nil then
            FControlBarMenuHook := TCnMenuHook.Create(nil);
          if not FControlBarMenuHook.IsHooked(FMainControlBar.PopupMenu) then
            FControlBarMenuHook.HookMenu(FMainControlBar.PopupMenu);
          
          FLockMenuItem := TCnMenuItemDef.Create(SCnLockToolbarMenuName,
            SCnLockToolbarMenuCaption, OnLockToolbarItemClick, ipLast, '');
          FLockMenuItem.OnCreated := OnLockMenuCreated;
          FControlBarMenuHook.AddMenuItemDef(FLockMenuItem);
        end;  
        Exit;
      end;
    end;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnLockToolbarItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    LockToolbar := not LockToolbar;
    (Sender as TMenuItem).Checked := FLockToolbar;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnLockMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
begin
  MenuItem.Checked := FLockToolbar;
end;

procedure TCnPaletteEnhanceWizard.SetTempDisableLock(const Value: Boolean);
begin
  FTempDisableLock := Value;
end;

{$IFDEF FIX_EDITORLINEENDS_BUG}
procedure TCnPaletteEnhanceWizard.SetFixEditorLineEndsBug(
  const Value: Boolean);
begin
  FFixEditorLineEndsBug := Value;
  FixEditorLineEndsBugGlobal := Value;
end;
{$ENDIF}

{$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}

procedure InitEditorClipboardsProcs;
var
  H: THandle;
begin
  H := GetModuleHandle(CorIdeLibName);
  if H <> 0 then
  begin
    EditCutProc := GetBplMethodAddress(GetProcAddress(H, SCnEditorActionsTEditorActionListsEditCutItemExecute));
    EditCopyProc := GetBplMethodAddress(GetProcAddress(H, SCnEditorActionsTEditorActionListsEditCopyItemExecute));
    EditPasteProc := GetBplMethodAddress(GetProcAddress(H, SCnEditorActionsTEditorActionListsEditPasteItemExecute));
  end;
end;

procedure TCnPaletteEnhanceWizard.SetFixNPFmxDesignCopyPasteBug(
  const Value: Boolean);
begin
  FFixNPFmxDesignCopyPasteBug := Value;
  if FFixNPFmxDesignCopyPasteBug then
  begin
    if FCutMethodHook = nil then
      FCutMethodHook := TCnMethodHook.Create(@EditCutProc, @MyEditCut);
    if FCopyMethodHook = nil then
      FCopyMethodHook := TCnMethodHook.Create(@EditCopyProc, @MyEditCopy);
    if FPasteMethodHook = nil then
      FPasteMethodHook := TCnMethodHook.Create(@EditPasteProc, @MyEditPaste);

    FCutMethodHook.HookMethod;
    FCopyMethodHook.HookMethod;
    FPasteMethodHook.HookMethod;
  end
  else
  begin
    if FCutMethodHook <> nil then
      FCutMethodHook.UnhookMethod;
    if FCopyMethodHook <> nil then
      FCopyMethodHook.UnhookMethod;
    if FPasteMethodHook <> nil then
      FPasteMethodHook.UnhookMethod;
  end;
end;

function TCnPaletteEnhanceWizard.CheckNPFmxDesignClipboardBugExists: Boolean;
begin
  // �ж������������� -np ѡ����ܻ��������ж�
  Result := FindCmdLineSwitch('np', ['/', '-'], True);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('IDE Main Form Enhancement. CheckNPFmxDesignCopyPasteBugExists: Has -np Switch.');
{$ENDIF}
end;

{$ENDIF}

initialization
  RegisterCnWizard(TCnPaletteEnhanceWizard);

{$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}
  InitEditorClipboardsProcs;
{$ENDIF};

finalization

{$IFDEF FIX_EDITORLINEENDS_BUG}
  try
    FixEditorLineEndsTtrBug;
  except
    ;
  end;
{$ENDIF}

  ClearRegistrySessionProject; // �˳�ʱҲ���һ��

{$IFDEF FIX_NP_FMX_DESIGN_CLIPBOARD_BUG}
  FreeAndNil(FCutMethodHook);
  FreeAndNil(FCopyMethodHook);
  FreeAndNil(FPasteMethodHook);
{$ENDIF}

{$ENDIF CNWIZARDS_CNPALETTEENHANCEWIZARD}
end.

