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

unit CnIDETranslator;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Delphi 菜单翻译
* 单元作者：Robinttt
* 备    注：
* 开发平台：PWin7 + Delphi 5
* 兼容测试：Windows + Delphi 所有版本
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2026.02.24 V1.2
*               移植入专家包。重构插件，主菜单（直接写）、弹出菜单（事件挂钩）、活动窗体菜单（子类化窗口）
*           2025.12.21 V1.1
*               添加编辑区弹出菜单翻译支持，直接写菜单项标题和对应动作的标题
*           2025.12.17 V1.0
*               提供主菜单中英文翻译支持，直接写菜单项标题
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Contnrs, SysUtils, ActnList, // Vcl.CategoryButtons,
  Controls, Forms, Menus, CnJSON, CnWizUtils, CnWizIdeUtils, CnWizMethodHook, CnHashLangStorage,
  {$IFDEF COMPILER7_UP} ActnPopup, {$ENDIF}
  {$IFDEF BDS} CategoryButtons, {$ENDIF} // 2005 及以上才有新组件板的 CategoryButtons
  {$IFDEF COMPILER6_UP} DesignIntf, DesignEditors, DesignMenus,{$ELSE}
  DsgnIntf, {$ENDIF} ToolsAPI;

type
  TCn2DStringArray = array of array of string;

  TCnAttachedPopupMenu = class
  {* 事件挂钩的弹出菜单项集合 }
  public
    PopupMenu: TPopupMenu;
    MenuPath: string;
    OriginalOnPopup: TNotifyEvent;
  end;

  TCnAttachedMenuItem = class
  {* 事件挂钩的主菜单项集合 }
  public
    MenuItem: TMenuItem;
    MenuPath: string;
    OriginalOnClick: TNotifyEvent;
  end;

  TCnActiveProjectInfo = packed record
  {* 活动项目的文件名称 }
    FileName: string;
    FileNameNoExt: string;
  end;

  TCnLParamObjectInfo = packed record
  {* 消息参数对象的信息 }
    Name: string;
    ClassName: string;
  end;

  TCnPaletteButtonInfo = packed record
  {* 控件区按钮组的名称 }
    CateGoryCaption: string;
    ButtonCaption: string;
  end;

  TCnMenuFormTranslator = class
  {* 菜单及窗体翻译器}
  private
    FActive: Boolean;
    FStorageRef: TCnHashLangFileStorage;
    FAddtionalLanguageFileLoad: Boolean;
    FAlreadyChinese: Boolean;
    FTransQueue: TComponentList;
    FTranFormsList: TComponentList;
    FOld2Array, FNew2Array: TStringList;
    FTranslationMap: TCnJSONObject;
    FMainMenu: TMainMenu;
    FMainMenuPath: string;
    FAttachedPopupMenuHooks: TObjectList; // MenuHooks
    FAttachedMenuItems: TObjectList;

    { 插件公用函数 }
    function FindComponentByNameDeep(const ARootComp: TComponent; const AName: string): TComponent; overload;
    function FindComponentByNameDeep(const ARootComp: TComponent; const AName: string; ComponentResult: TObjectList): Boolean; overload;
    function FindControlByNameDeep(const ARootControl: TControl; const AName: string): TControl; overload;
    function FindControlByNameDeep(const ARootControl: TControl; const AName: string; ControlResult: TObjectList): Boolean; overload;
    function FindFormsInControlDeep(const ARootControl: TControl; FormList: TObjectList): Boolean;
    function FindComponentByClassDeep(const ARootComp: TComponent; const AClassName: string): TComponent;
    function FindControlByClassDeep(const ARootControl: TControl; const AClassName: string): TControl;
    function FindMenuItemByNameDeep(const ARootMenuItem: TMenuItem; const AName: string): TMenuItem;
    function FindMainMenuItemByNameDeep(const AMainMenu: TMainMenu; const AName: string): TMenuItem;
    function FindPopupMenuByName(const AForm: TForm; const AOwnerName, AMenuName: string): TPopupMenu;
    {* AOwnerName 支持通配符 *}

    function FindScreenFormByName(const AFormName: string): TForm; overload;
    function FindScreenFormByName(const AFormName: string; FormResult: TObjectList): Boolean; overload;
    function GetActiveProjectInfo: TCnActiveProjectInfo;

    function IsPopupMenuHooked(Menu: TPopupMenu): Boolean;
{$IFDEF BDS}
    function GetPaletteButtonInfo: TCnPaletteButtonInfo;
{$ENDIF}
    function GetTranslationMenuPaths(const AMenuCategory, AMechanism: string;
      const APrefix: string = ''): TCn2DStringArray;
    function GetTranslationItemCaptions(const AMenuCategory, AMechanism,
      AMenuPath: string): TCn2DStringArray;
    function ReturnTranslateCaption(const AItemCaption: string; const ACaptions:
      TCn2DStringArray): string;

    procedure TranslateMenuItem(const AMenuItem: TMenuItem; const ACaptions: TCn2DStringArray);

    // 主菜单处理过程
    procedure TranslateMainMenuDynamicItem(const AMenuCategory, AMechanism, AMenuPath: string);
    {* 翻译主菜单中的其他动态条目}
    procedure TranslateStaticMainMenu;
    {* 翻译主菜单中的静态条目}
    procedure TranslateMainMenuProjectItems;
    {* 翻译主菜单中工程相关的动态条目，注意需在当前工程切换时通知调用}
    procedure HookMainMenuDynamicItems;
    {* 部分主菜单的主菜单项内容是动态生成的，需要通过 Hook 这几个 Item 的 OnClick 来处理}

    procedure HookedMenuItemOnClick(Sender: TObject);
    {* 用来挂接的新点击事件处理器}
    procedure UnHookMainMenuDynamicItems;
    {* 解除挂接主菜单}

    // 弹出菜单处理过程
    procedure TranslatePopupMenu(const AMenuCategory, AMechanism, AMenuPath: string);
    {* 翻译一个弹出菜单，可弹出时动态调用，也可直接调用}
    procedure TranslatePopupMenuPaletteItems;
    {* 翻译控件板的弹出菜单}
    procedure TranslateStaticPopupMenus(OnlyCurrent: Boolean = False);
    {* 翻译其他静态弹出菜单，OnlyCurrent 为 True 表示只翻译最靠前窗体的}
    procedure HookPopupMenus;
    {* 挂接所有现有的弹出菜单以在弹出后进行翻译}
    procedure HookPopupMenuOnCurrentEditWindow;
    {* 挂接当前活动编辑器窗口上的菜单控件}

    procedure AfterPopupMenuOnPopup(Sender: TObject; Menu: TPopupMenu);
    {* 用来挂接的新弹出事件处理器}
    procedure UnHookPopupMenus;
    {* 解除挂接所有弹出菜单}

    // 插件处理过程
    procedure LoadTranslationMenus(const AMenuLangFile: string);
    procedure LoadMenuItemLanguages;
    procedure UpdateWholeMenus;
    procedure TranslateAllExistingForms;
    {* 翻译现有 IDE 的窗体。以下几种情况下会被调用：
      中文状态下汉化功能启用或禁用时（SetActive 中调用），内部检查 FActive 以决定翻成中文还是英文，
      切换语言到中文时且汉化功能启用时调用（LanguageChanged 中调用，内部翻成中文）
      切换语言到非中文语言时（LanguageChanged 中调用，内部翻译成英文}

  protected
    function GetAdditionalLangMainFileName: string;
    function GetAdditionalLangExtraFileName: string;
    function GetAdditionalLangID: Cardinal;
    // 只有当前语言为中文，且启用了汉化功能的情况下，额外语言文件才要加载中文的，其他情况都是加载英文的

    procedure LoadAdditionalLangFile(ALangID: Cardinal);

    procedure DelayActivate(Sender: TObject);
    procedure SetActive(const Value: Boolean);

    procedure LangaugeChanged(Sender: TObject);
    procedure ActiveProjectChanged(Sender: TObject);
    procedure ActiveFormChanged(Sender: TObject);
    procedure DesignerMenuBuild(Sender: TObject; PopupMenu: TPopupMenu);
    procedure TranslateQueue(Sender: TObject);
  public
    constructor Create(AStorage: TCnHashLangFileStorage);
    destructor Destroy; override;

    procedure DebugCommand(Cmds: TStrings; Results: TStrings);

    property Active: Boolean read FActive write SetActive;
    {* 是否启用英译中功能}
  end;

implementation

uses
  CnCommon, CnMenuHook, CnControlHook, CnWizNotifier, CnStrings, CnWizOptions,
  CnWizMultiLang, CnLangMgr, CnWizCompilerConst, CnWideStrings, CnLangCollection
  {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  csEnglishID = 1033;
  csChineseID = 2052;

  csMenuTransFile = 'TransMenu.json';
  INDEX_ENU = 0;
  INDEX_CHS = 1;

  // 翻译的菜单类型
  RT_CATEGORY_MAINMENU: string = 'MainMenu';
  RT_CATEGORY_POPUPMENUS: string = 'PopupMenus';

  // 翻译的翻译机制
  RT_MECHANISM_DIRECTACCESS: string = 'DirectAccess';
  RT_MECHANISM_EVENTHANDLER: string = 'EventHandler';
  RT_MECHANISM_WINDOWPROC: string = 'WindowProc';

type
  TCnHackHashLangStorage = class(TCnCustomHashLangStorage);

{$IFDEF DEBUG}

procedure Dump2DStringArray(const Arr: TCn2DStringArray);
var
  I, J: Integer;
  RowCount, ColCount: Integer;
  Line: string;
begin
  RowCount := Length(Arr);
  if RowCount = 0 then
  begin
    CnDebugger.LogMsg('2D String Array is empty (no rows).');
    Exit;
  end;

  for I := 0 to RowCount - 1 do
  begin
    ColCount := Length(Arr[I]);
    if ColCount = 0 then
    begin
      CnDebugger.LogMsg(Format('Row %d: empty', [I]));
      Continue;
    end;

    Line := Format('Row %d: ', [I]);
    for J := 0 to ColCount - 1 do
    begin
      if J > 0 then
        Line := Line + ', ';
      Line := Line + Format('[%d,%d]="%s"', [I, J, Arr[I, J]]);
    end;
    CnDebugger.LogMsg(Line);
  end;
end;

{$ENDIF}

function StrEqualOrMatchStartWithStar(const APattern, AStr: string): Boolean;
var
  J: Integer;
  Prefix: string;
begin
  Result := True;
  if AStr = APattern then
    Exit;

  J := Pos('*', APattern);
  if J > 1 then
  begin
    Prefix := Copy(APattern, 1, J - 1);
    Result := Pos(Prefix, AStr) = 1;
  end
  else
    Result := False;
end;

procedure ChangeLangPrefix(AMap: TCnLangHashMap; const OldPrefix, NewPrefix: string);
var
  Key, Value: TCnLangString;
  OldKeys: TCnWideStringList;
  OldValues: TCnWideStringList;
  I: Integer;
  NewKey: string;
begin
  OldKeys := TCnWideStringList.Create;
  OldValues := TCnWideStringList.Create;
  try
    AMap.StartEnum;
    while AMap.GetNext(Key, Value) do
    begin
      if Pos(OldPrefix, Key) = 1 then
      begin
        OldKeys.Add(Key);
        OldValues.Add(Value);
      end;
    end;

    for I := 0 to OldKeys.Count - 1 do
      AMap.Delete(OldKeys[I]);

    for I := 0 to OldKeys.Count - 1 do
    begin
      NewKey := NewPrefix + Copy(OldKeys[I], Length(OldPrefix) + 1, MaxInt);
      AMap.Add(NewKey, OldValues[I]);
    end;
  finally
    OldKeys.Free;
    OldValues.Free;
  end;
end;

// 根据名称遍历查找组件
function TCnMenuFormTranslator.FindComponentByNameDeep(const ARootComp: TComponent;
  const AName: string): TComponent;
var
  I: Integer;
  Component: TComponent;
begin
  Result := nil;
  if not Assigned(ARootComp) then
    Exit;

  if StrEqualOrMatchStartWithStar(AName, ARootComp.Name) then
  begin
    Result := ARootComp;
    Exit;
  end;

  for I := 0 to ARootComp.ComponentCount - 1 do
  begin
    Component := ARootComp.Components[I];
    if StrEqualOrMatchStartWithStar(AName, Component.Name) then
    begin
      Result := Component;
      Exit;
    end;

    Result := FindComponentByNameDeep(Component, AName);
    if Result <> nil then
      Exit;
  end;
end;

// 根据名称遍历查找控件
function TCnMenuFormTranslator.FindControlByNameDeep(const ARootControl: TControl;
  const AName: string): TControl;
var
  I: Integer;
  Control: TControl;
  WinControl: TWinControl;
begin
  Result := nil;
  if not Assigned(ARootControl) then
    Exit;

  if StrEqualOrMatchStartWithStar(AName, ARootControl.Name) then
  begin
    Result := ARootControl;
    Exit;
  end;

  if not (ARootControl is TWinControl) then
    Exit;

  WinControl := TWinControl(ARootControl);
  for I := 0 to WinControl.ControlCount - 1 do
  begin
    Control := WinControl.Controls[I];
    if StrEqualOrMatchStartWithStar(AName, Control.Name) then
    begin
      Result := Control;
      Exit;
    end;

    Result := FindControlByNameDeep(Control, AName);
    if Result <> nil then
      Exit;
  end;
end;

// 根据类名遍历查找组件
function TCnMenuFormTranslator.FindComponentByClassDeep(const ARootComp: TComponent;
  const AClassName: string): TComponent;
var
  I: Integer;
  Component: TComponent;
begin
  Result := nil;
  if not Assigned(ARootComp) then
    Exit;
  if SameText(ARootComp.ClassName, AClassName) then
  begin
    Result := ARootComp;
    Exit;
  end;

  for I := 0 to ARootComp.ComponentCount - 1 do
  begin
    Component := ARootComp.Components[I];
    if SameText(Component.ClassName, AClassName) then
    begin
      Result := Component;
      Exit;
    end;
    Result := FindComponentByClassDeep(Component, AClassName);
    if Result <> nil then
      Exit;
  end;
end;

// 根据类名遍历查找控件
function TCnMenuFormTranslator.FindControlByClassDeep(const ARootControl: TControl;
  const AClassName: string): TControl;
var
  I: Integer;
  Control: TControl;
  WinControl: TWinControl;
begin
  Result := nil;
  if not Assigned(ARootControl) then
    Exit;
  if SameText(ARootControl.ClassName, AClassName) then
  begin
    Result := ARootControl;
    Exit;
  end;

  if not (ARootControl is TWinControl) then
    Exit;
  WinControl := TWinControl(ARootControl);
  for I := 0 to WinControl.ControlCount - 1 do
  begin
    Control := WinControl.Controls[I];
    if SameText(Control.ClassName, AClassName) then
    begin
      Result := Control;
      Exit;
    end;
    Result := FindControlByClassDeep(Control, AClassName);
    if Result <> nil then
      Exit;
  end;
end;

function TCnMenuFormTranslator.FindScreenFormByName(const AFormName: string): TForm;
var
  I: Integer;
  Form: TForm;
begin
  for I := 0 to Screen.FormCount - 1 do
  begin
    Form := Screen.Forms[I];
    if (Form.Name <> '') and SameText(Form.Name, AFormName) then
    begin
      Result := Form;
      Exit;
    end;
  end;
  Result := nil;
end;

// 根据名称查找顶层窗体
function TCnMenuFormTranslator.FindScreenFormByName(const AFormName: string; FormResult: TObjectList): Boolean;
var
  I: Integer;
  Form: TForm;
  Prefix: string;
begin
  Result := False;
  I := Pos('*', AFormName);
  if I > 1 then
  begin
    Prefix := Copy(AFormName, 1, I - 1); // 有通配符，截取通配符前面的
    for I := 0 to Screen.FormCount - 1 do
    begin
      Form := Screen.Forms[I];
      if Pos(Prefix, Form.Name) = 1 then // 从头匹配
      begin
        FormResult.Add(Form);
        Result := True;
      end;
    end;
  end
  else // 没通配符，直接找
  begin
    for I := 0 to Screen.FormCount - 1 do
    begin
      Form := Screen.Forms[I];
      if SameText(Form.Name, AFormName) then
      begin
        FormResult.Add(Form);
        Result := True;
      end;
    end;
  end;
end;

// 根据名称查找多个子组件（支持通配符）
function TCnMenuFormTranslator.FindComponentByNameDeep(const ARootComp: TComponent;
  const AName: string; ComponentResult: TObjectList): Boolean;
var
  I, PosWildcard: Integer;
  Component: TComponent;
  Prefix: string;

  procedure SearchComponents(AComp: TComponent);
  var
    J: Integer;
    SubComp: TComponent;
  begin
    if not Assigned(AComp) then
      Exit;

    for J := 0 to AComp.ComponentCount - 1 do
    begin
      SubComp := AComp.Components[J];
      if PosWildcard > 1 then
      begin
        // 有通配符，使用首匹配
        if Pos(Prefix, SubComp.Name) = 1 then
        begin
          ComponentResult.Add(SubComp);
          Result := True;
        end;
      end
      else
      begin
        // 没通配符，精确匹配
        if SameText(SubComp.Name, AName) then
        begin
          ComponentResult.Add(SubComp);
          Result := True;
        end;
      end;
      // 递归查找子组件
      SearchComponents(SubComp);
    end;
  end;

begin
  Result := False;
  if not Assigned(ARootComp) then
    Exit;

  PosWildcard := Pos('*', AName);
  if PosWildcard > 1 then
    Prefix := Copy(AName, 1, PosWildcard - 1)
  else
    Prefix := '';

  // 先检查根组件自身
  if PosWildcard > 1 then
  begin
    if Pos(Prefix, ARootComp.Name) = 1 then
    begin
      ComponentResult.Add(ARootComp);
      Result := True;
    end;
  end
  else
  begin
    if SameText(ARootComp.Name, AName) then
    begin
      ComponentResult.Add(ARootComp);
      Result := True;
    end;
  end;

  // 递归查找所有子组件
  SearchComponents(ARootComp);
end;

// 根据名称查找多个子控件（支持通配符）
function TCnMenuFormTranslator.FindControlByNameDeep(const ARootControl: TControl;
  const AName: string; ControlResult: TObjectList): Boolean;
var
  I, PosWildcard: Integer;
  Control: TControl;
  WinControl: TWinControl;
  Prefix: string;

  procedure SearchControls(AControl: TControl);
  var
    J: Integer;
    SubControl: TControl;
    SubWinControl: TWinControl;
  begin
    if not Assigned(AControl) then
      Exit;

    if not (AControl is TWinControl) then
      Exit;

    SubWinControl := TWinControl(AControl);
    for J := 0 to SubWinControl.ControlCount - 1 do
    begin
      SubControl := SubWinControl.Controls[J];
      if PosWildcard > 1 then
      begin
        // 有通配符，使用首匹配
        if Pos(Prefix, SubControl.Name) = 1 then
        begin
          ControlResult.Add(SubControl);
          Result := True;
        end;
      end
      else
      begin
        // 没通配符，精确匹配
        if SameText(SubControl.Name, AName) then
        begin
          ControlResult.Add(SubControl);
          Result := True;
        end;
      end;
      // 递归查找子控件
      SearchControls(SubControl);
    end;
  end;

begin
  Result := False;
  if not Assigned(ARootControl) then
    Exit;

  PosWildcard := Pos('*', AName);
  if PosWildcard > 1 then
    Prefix := Copy(AName, 1, PosWildcard - 1)
  else
    Prefix := '';

  // 先检查根控件自身
  if PosWildcard > 1 then
  begin
    if Pos(Prefix, ARootControl.Name) = 1 then
    begin
      ControlResult.Add(ARootControl);
      Result := True;
    end;
  end
  else
  begin
    if SameText(ARootControl.Name, AName) then
    begin
      ControlResult.Add(ARootControl);
      Result := True;
    end;
  end;

  // 递归查找所有子控件
  SearchControls(ARootControl);
end;

// 递归查找控件树中的所有窗体
function TCnMenuFormTranslator.FindFormsInControlDeep(const ARootControl: TControl;
  FormList: TObjectList): Boolean;
var
  I: Integer;
  WinControl: TWinControl;

  procedure SearchForms(AControl: TControl);
  var
    J: Integer;
    SubControl: TControl;
    SubWinControl: TWinControl;
  begin
    if not Assigned(AControl) then
      Exit;

    // 检查当前控件是否是 TForm 或其子类
    if AControl is TForm then
      FormList.Add(AControl);

    // 如果是 TWinControl，递归搜索其子控件
    if AControl is TWinControl then
    begin
      SubWinControl := TWinControl(AControl);
      for J := 0 to SubWinControl.ControlCount - 1 do
      begin
        SubControl := SubWinControl.Controls[J];
        SearchForms(SubControl);
      end;
    end;
  end;

begin
  Result := False;
  if not Assigned(ARootControl) then
    Exit;

  // 不检查根控件自身，直接递归搜索所有子控件
  SearchForms(ARootControl);
  Result := FormList.Count > 0;
end;

// 根据名称遍历查找菜单的子菜单
function TCnMenuFormTranslator.FindMenuItemByNameDeep(const ARootMenuItem: TMenuItem;
  const AName: string): TMenuItem;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(ARootMenuItem) then
    Exit;

  if SameText(ARootMenuItem.Name, AName) then
  begin
    Result := ARootMenuItem;
    Exit;
  end;

  for I := 0 to ARootMenuItem.Count - 1 do
  begin
    Result := FindMenuItemByNameDeep(ARootMenuItem.Items[I], AName);
    if Assigned(Result) then
      Exit;
  end;
end;

// 根据名称遍历查找主菜单的子菜单
function TCnMenuFormTranslator.FindMainMenuItemByNameDeep(const AMainMenu: TMainMenu;
  const AName: string): TMenuItem;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AMainMenu) then
    Exit;

  for I := 0 to AMainMenu.Items.Count - 1 do
  begin
    Result := FindMenuItemByNameDeep(AMainMenu.Items[I], AName);
    if Assigned(Result) then
      Exit;
  end;
end;

// 根据名称查找弹出菜单，需要 AOwnerName 支持通配符
function TCnMenuFormTranslator.FindPopupMenuByName(const AForm: TForm; const AOwnerName,
  AMenuName: string): TPopupMenu;
var
  I: Integer;
  MenuOwner, Component: TComponent;
begin
  Result := nil;
  if not Assigned(AForm) then
    Exit;

  MenuOwner := FindComponentByNameDeep(AForm, AOwnerName);
  if not Assigned(MenuOwner) then
    MenuOwner := FindControlByNameDeep(AForm, AOwnerName);
  if not Assigned(MenuOwner) then
    Exit;

  for I := 0 to MenuOwner.ComponentCount - 1 do
  begin
    Component := MenuOwner.Components[I];
    if (Component is TPopupMenu) and SameText(Component.Name, AMenuName) then
    begin
      Result := TPopupMenu(Component);
      Exit;
    end;
  end;
end;

// 获取活动项目的文件名称
function TCnMenuFormTranslator.GetActiveProjectInfo: TCnActiveProjectInfo;
var
  Project: IOTAProject;
begin
  Project := CnOtaGetCurrentProject;
  if Assigned(Project) then
  begin
    Result.FileName := ExtractFileName(Project.FileName);
    Result.FileNameNoExt := ChangeFileExt(Result.FileName, '');
  end
  else
  begin
    Result.FileName := '[None]';
    Result.FileNameNoExt := '[None]';
  end;
end;

{$IFDEF BDS}

// 获取控件区光标所在位置的按钮信息
function TCnMenuFormTranslator.GetPaletteButtonInfo: TCnPaletteButtonInfo;
var
  Form: TForm;
  Control: TControl;
  Buttons: TCategoryButtons;
  Category: TButtonCategory;
  ButtonItem: TButtonItem;
  Point: TPoint;
begin
  Result.CateGoryCaption := '';
  Result.ButtonCaption := '';

  Form := FindScreenFormByName('ToolForm');
  if not Assigned(Form) then
    Exit;

  Control := FindControlByClassDeep(Form, 'TIDECategoryButtons');
  if Assigned(Control) and (Control is TCategoryButtons) then
  begin
    Buttons := TCategoryButtons(Control);
    GetCursorPos(Point);
    Point := Buttons.ScreenToClient(Point);
    Category := Buttons.GetCategoryAt(Point.X, Point.Y);
    if Assigned(Category) then
    begin
      Result.CateGoryCaption := Category.Caption;
      ButtonItem := Buttons.GetButtonAt(Point.X, Point.Y);
      if Assigned(ButtonItem) then
        Result.ButtonCaption := ButtonItem.Caption;
    end;
  end;
end;

{$ENDIF}

// 根据菜单类型查找菜单路径
function TCnMenuFormTranslator.GetTranslationMenuPaths(const AMenuCategory,
  AMechanism: string; const APrefix: string): TCn2DStringArray;
var
  I, Count: Integer;
  JsonValue: TCnJSONValue;
  JsonArray: TCnJSONArray;
  JsonObject: TCnJSONObject;
begin
  SetLength(Result, 0, 0);
  if not Assigned(FTranslationMap) then
    Exit;

  JsonValue := FTranslationMap[AMenuCategory];
  if not (JsonValue is TCnJSONObject) then
    Exit;

  JsonObject := TCnJSONObject(JsonValue);
  JsonValue := JsonObject[AMechanism];
  if not (JsonValue is TCnJSONArray) then
    Exit;
  JsonArray := TCnJSONArray(JsonValue);
  if JsonArray.Count = 0 then
    Exit;

  Count := 0;
  for I := 0 to JsonArray.Count - 1 do
  begin
    if JsonArray[I] is TCnJSONObject then
      Inc(Count);
  end;
  if Count = 0 then
    Exit;

  SetLength(Result, Count, 2);
  Count := 0;

  if APrefix = '' then
  begin
    for I := 0 to JsonArray.Count - 1 do
    begin
      if not (JsonArray[I] is TCnJSONObject) then
        Continue;

      JsonObject := TCnJSONObject(JsonArray[I]);
      if (APrefix <> '') and (Pos(APrefix, JsonObject['MenuPath'].AsString) <> 1) then
        Continue;

      Result[Count, 0] := JsonObject['MenuPath'].AsString;
      Result[Count, 1] := JsonObject['ForceEnglish'].AsString;
      Inc(Count);
    end;
  end
  else
  begin
    // 统计匹配数量
    for I := 0 to JsonArray.Count - 1 do
    begin
      if not (JsonArray[I] is TCnJSONObject) then
        Continue;

      JsonObject := TCnJSONObject(JsonArray[I]);
      if Pos(APrefix, JsonObject['MenuPath'].AsString) <> 1 then
        Continue;

      Inc(Count);
    end;

    SetLength(Result, Count, 2);

    // 有匹配的，才真正赋值
    if Count > 0 then
    begin
      Count := 0;

      for I := 0 to JsonArray.Count - 1 do
      begin
        if not (JsonArray[I] is TCnJSONObject) then
          Continue;

        JsonObject := TCnJSONObject(JsonArray[I]);
        if Pos(APrefix, JsonObject['MenuPath'].AsString) <> 1 then
          Continue;

        Result[Count, 0] := JsonObject['MenuPath'].AsString;
        Result[Count, 1] := JsonObject['ForceEnglish'].AsString;
        Inc(Count);
      end;
    end;
  end;
end;

// 根据菜单路径获取标题集合
function TCnMenuFormTranslator.GetTranslationItemCaptions(const AMenuCategory, AMechanism,
  AMenuPath: string): TCn2DStringArray;
var
  I, Count: Integer;
  JsonValue: TCnJSONValue;
  JsonObject: TCnJSONObject;
  JsonArray, ItemArray: TCnJSONArray;
  IsFromEnglish: Boolean;
begin
  if not Assigned(FTranslationMap) then
    Exit;

  SetLength(Result, 0, 0);
  JsonValue := FTranslationMap[AMenuCategory];
  if not (JsonValue is TCnJSONObject) then
    Exit;

  JsonObject := TCnJSONObject(JsonValue);
  JsonValue := JsonObject[AMechanism];
  if not (JsonValue is TCnJSONArray) then
    Exit;

  JsonArray := TCnJSONArray(JsonValue);
  JsonObject := nil;
  for I := 0 to JsonArray.Count - 1 do
  begin
    JsonObject := TCnJSONObject(JsonArray[I]);
    if SameText(JsonObject['MenuPath'].AsString, AMenuPath) then
    begin
      if SameText(JsonObject['ForceEnglish'].AsString, 'True') then
        IsFromEnglish := True;
      Break;
    end;
    // 如果某菜单项本身会被 IDE 动态强行设为英文，则翻译时就应取先英后中的内容
  end;

  if not Assigned(JsonObject) then
    Exit;

  JsonValue := JsonObject['ItemCaption'];
  if not (JsonValue is TCnJSONArray) then
    Exit;

  JsonArray := TCnJSONArray(JsonValue);
  if JsonArray.Count = 0 then
    Exit;

  Count := 0;
  for I := 0 to JsonArray.Count - 1 do
  begin
    if JsonArray[I] is TCnJSONArray then
      Inc(Count);
  end;

  if Count = 0 then
    Exit;

  SetLength(Result, Count, 2);
  Count := 0;
  if FActive then
  begin // 启用时返回英文到中文
    for I := 0 to JsonArray.Count - 1 do
    begin
      if JsonArray[I] is TCnJSONArray then
      begin
        ItemArray := TCnJSONArray(JsonArray[I]);
        Result[Count, 0] := ItemArray[INDEX_ENU].AsString;
        Result[Count, 1] := ItemArray[INDEX_CHS].AsString;
        Inc(Count);
      end;
    end;
  end
  else
  begin
    for I := 0 to JsonArray.Count - 1 do
    begin // 关闭时，返回中文到英文
      if JsonArray[I] is TCnJSONArray then
      begin
        ItemArray := TCnJSONArray(JsonArray[I]);
        Result[Count, 0] := ItemArray[INDEX_CHS].AsString;
        Result[Count, 1] := ItemArray[INDEX_ENU].AsString;
        Inc(Count);
      end;
    end;
  end;
end;

// 返回翻译后的菜单标题
function TCnMenuFormTranslator.ReturnTranslateCaption(const AItemCaption: string;
  const ACaptions: TCn2DStringArray): string;
var
  I, Position: Integer;
  ReducedCaption, NewCaption, AccessKey, Ellipsis: string;

  function RestoreAccessKeyAndEllipsis: string;
  begin
    // 如有访问键和省略号，则替换并赋值菜单
    if AccessKey <> '' then
    begin
      if not FActive then
      begin
        Position := Pos(AccessKey, UpperCase(NewCaption));
        Insert('&', NewCaption, Position);
      end
      else
      begin
        NewCaption := NewCaption + '(&' + AccessKey + ')';
      end;
    end;
    if Ellipsis <> '' then
      NewCaption := NewCaption + Ellipsis;
    Result := NewCaption;
  end;

begin
  Result := AItemCaption;

  // 检查访问键和省略号，同时保存至新字符串
  ReducedCaption := AItemCaption;
  AccessKey := '';
  Ellipsis := '';
  Position := Pos('(&', ReducedCaption);

  if Position > 0 then
  begin
    AccessKey := UpperCase(Copy(ReducedCaption, Position + 2, 1));
    Delete(ReducedCaption, Position, 4);
  end
  else
  begin
    Position := Pos('&', ReducedCaption);
    if Position > 0 then
    begin
      AccessKey := UpperCase(Copy(ReducedCaption, Position + 1, 1));
      Delete(ReducedCaption, Position, 1);
    end;
  end;

  Position := Pos('...', ReducedCaption);
  if Position > 0 then
  begin
    Ellipsis := '...';
    Delete(ReducedCaption, Position, 3);
  end;

  // 通过新字符串查找并翻译标题
  for I := 0 to Length(ACaptions) - 1 do
  begin
    if SameText(ACaptions[I, 0], ReducedCaption) then
    begin
      NewCaption := ACaptions[I, 1];
      Result := RestoreAccessKeyAndEllipsis;
      Break;
    end
    else if Pos('||', ACaptions[I, 0]) > 0 then
    begin
      // 翻译地图中如有分隔符 || ，则切割>检查>翻译>合并
      NewCaption := ACaptions[I, 1];

      if FOld2Array = nil then
        FOld2Array := TStringList.Create;
      if FNew2Array = nil then
        FNew2Array := TStringList.Create;

      CnSplitString('||', ACaptions[I, 0], FOld2Array);
      CnSplitString('||', ACaptions[I, 1], FNew2Array);

      if (FOld2Array[0] <> '') and (FOld2Array[1] = '') then
      begin // 仅左替换
        if SameText(FOld2Array[0], Copy(ReducedCaption, 1, Length(FOld2Array[0]))) then
        begin
          NewCaption := FNew2Array[0] + StrRight(ReducedCaption, Length(ReducedCaption)
            - Length(FOld2Array[0]));
          Result := RestoreAccessKeyAndEllipsis;
          Break;
        end;
      end
      else if (FOld2Array[0] = '') and (FOld2Array[1] <> '') then
      begin // 仅右替换
        if SameText(FOld2Array[1], StrRight(ReducedCaption, Length(FOld2Array[1]))) then
        begin
          NewCaption := Copy(ReducedCaption, 1, Length(ReducedCaption) - Length(FOld2Array
            [1])) + FNew2Array[1];
          Result := RestoreAccessKeyAndEllipsis;
          Break;
        end;
      end
      else if (FOld2Array[0] <> '') and (FOld2Array[1] <> '') then
      begin // 左右均替换
        if SameText(FOld2Array[0], Copy(ReducedCaption, 1, Length(FOld2Array[0])))
          and SameText(FOld2Array[1], StrRight(ReducedCaption, Length(FOld2Array[1]))) then
        begin
          NewCaption := FNew2Array[0] + StrRight(ReducedCaption, Length(ReducedCaption)
            - Length(FOld2Array[0]));
          NewCaption := Copy(NewCaption, 1, Length(NewCaption) - Length(FOld2Array
            [1])) + FNew2Array[1];
          Result := RestoreAccessKeyAndEllipsis;
          Break;
        end;
      end;
    end;
  end;
end;

// 递归重写各级子菜单
procedure TCnMenuFormTranslator.TranslateMenuItem(const AMenuItem: TMenuItem; const ACaptions:
  TCn2DStringArray);
var
  I: Integer;
begin
  if not Assigned(AMenuItem) or (Length(ACaptions) = 0) then
    Exit;

  if (AMenuItem.Caption = '-') or (AMenuItem.Caption = '') then
    Exit;

  AMenuItem.Caption := ReturnTranslateCaption(AMenuItem.Caption, ACaptions);

  for I := 0 to AMenuItem.Count - 1 do
    TranslateMenuItem(AMenuItem.Items[I], ACaptions);
end;

// 主菜单重写单个子菜单
procedure TCnMenuFormTranslator.TranslateMainMenuDynamicItem(const AMenuCategory,
  AMechanism, AMenuPath: string);
var
  MenuItem: TMenuItem;
  Captions: TCn2DStringArray;
begin
  if not Assigned(FMainMenu) then
    Exit;

  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, AMenuPath);
  Captions := GetTranslationItemCaptions(AMenuCategory, AMechanism, AMenuPath);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TranslateDynamicMainMenu %s Get Captions %d', [AMenuPath, Length(Captions)]);
{$ENDIF}
  TranslateMenuItem(MenuItem, Captions);
end;

// 重写主菜单的静态子菜单集合
procedure TCnMenuFormTranslator.TranslateStaticMainMenu;
var
  I: Integer;
  Captions: TCn2DStringArray;
begin
  if not Assigned(FMainMenu) then
    Exit;

  for I := 0 to FMainMenu.Items.Count - 1 do
  begin
    Captions := GetTranslationItemCaptions(RT_CATEGORY_MAINMENU,
      RT_MECHANISM_DIRECTACCESS, FMainMenu.Items[I].Name);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TranslateStaticMainMenu %s Get Captions %d', [FMainMenu.Items[I].Name, Length(Captions)]);
{$ENDIF}
    if Length(Captions) > 0 then
      TranslateMenuItem(FMainMenu.Items[I], Captions);
  end;
end;

// 专门重写项目菜单下指定子菜单
procedure TCnMenuFormTranslator.TranslateMainMenuProjectItems;
var
  ActiveProjectInfo: TCnActiveProjectInfo;
  MenuItem: TMenuItem;
  Captions: TCn2DStringArray;
begin
  if not Assigned(FMainMenu) then
    Exit;

  ActiveProjectInfo := GetActiveProjectInfo;
  // 重写项目菜单下指定子菜单
  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, 'ProjectBuildItem');
  if Assigned(MenuItem) then
  begin
    Captions := GetTranslationItemCaptions(RT_CATEGORY_MAINMENU,
      RT_MECHANISM_DIRECTACCESS, 'ProjectBuildItem');
    if Length(Captions) > 0 then
      MenuItem.Caption := Captions[0, 1] + ' ' + ActiveProjectInfo.FileNameNoExt;
  end;

  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, 'ProjectCompileItem');
  if Assigned(MenuItem) then
  begin
    Captions := GetTranslationItemCaptions(RT_CATEGORY_MAINMENU,
      RT_MECHANISM_DIRECTACCESS, 'ProjectCompileItem');
    if Length(Captions) > 0 then
      MenuItem.Caption := Captions[0, 1] + ' ' + ActiveProjectInfo.FileNameNoExt;
  end;

  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, 'ProjectDeployItem');
  if Assigned(MenuItem) then
  begin
    Captions := GetTranslationItemCaptions(RT_CATEGORY_MAINMENU,
      RT_MECHANISM_DIRECTACCESS, 'ProjectDeployItem');
    if Length(Captions) > 0 then
      MenuItem.Caption := Captions[0, 1] + ' ' + ActiveProjectInfo.FileName;
  end;

  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, 'ProjectInformationItem');
  if Assigned(MenuItem) then
  begin
    Captions := GetTranslationItemCaptions(RT_CATEGORY_MAINMENU,
      RT_MECHANISM_DIRECTACCESS, 'ProjectInformationItem');
    if Length(Captions) > 0 then
      MenuItem.Caption := Captions[0, 1] + ' ' + ActiveProjectInfo.FileNameNoExt;
  end;

  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, 'ProjectSyntaxItem');
  if Assigned(MenuItem) then
  begin
    Captions := GetTranslationItemCaptions(RT_CATEGORY_MAINMENU,
      RT_MECHANISM_DIRECTACCESS, 'ProjectSyntaxItem');
    if Length(Captions) > 0 then
      MenuItem.Caption := Captions[0, 1] + ' ' + ActiveProjectInfo.FileNameNoExt;
  end;
end;

// 事件挂钩动态子菜单
procedure TCnMenuFormTranslator.HookMainMenuDynamicItems;
var
  I, J: Integer;
  MenuPaths: TCn2DStringArray;
  MenuItem: TMenuItem;
  ItemHooked: Boolean;
  ItemInfo: TCnAttachedMenuItem;
begin
  UnHookMainMenuDynamicItems;

  MenuPaths := GetTranslationMenuPaths(RT_CATEGORY_MAINMENU, RT_MECHANISM_EVENTHANDLER);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnMenuTranslator.HookMainMenuItems %d', [Length(MenuPaths)]);
{$ENDIF}

  for I := 0 to Length(MenuPaths) - 1 do
  begin
    MenuItem := FindMainMenuItemByNameDeep(FMainMenu, MenuPaths[I, 0]);
    if not Assigned(MenuItem) then
      Continue;

    ItemHooked := False;
    for J := 0 to FAttachedMenuItems.Count - 1 do
    begin
      if TCnAttachedMenuItem(FAttachedMenuItems[J]).MenuItem = MenuItem then
      begin
        ItemHooked := True;
        Break;
      end;
    end;

    if not ItemHooked then
    begin
      ItemInfo := TCnAttachedMenuItem.Create;
      ItemInfo.MenuItem := MenuItem;
      ItemInfo.MenuPath := MenuPaths[I, 0];
      ItemInfo.OriginalOnClick := MenuItem.OnClick;
      MenuItem.OnClick := HookedMenuItemOnClick;
      FAttachedMenuItems.Add(ItemInfo);
    end;
  end;
end;

// 动态子菜单挂钩事件
procedure TCnMenuFormTranslator.HookedMenuItemOnClick(Sender: TObject);
var
  I: Integer;
  MenuItem: TMenuItem;
  ItemInfo: TCnAttachedMenuItem;
begin
  if not (Sender is TMenuItem) then
    Exit;

  MenuItem := TMenuItem(Sender);
  for I := 0 to FAttachedMenuItems.Count - 1 do
  begin
    ItemInfo := TCnAttachedMenuItem(FAttachedMenuItems[I]);
    if ItemInfo.MenuItem = MenuItem then
    begin
      if Assigned(ItemInfo.OriginalOnClick) then
        ItemInfo.OriginalOnClick(Sender);

      TranslateMainMenuDynamicItem(RT_CATEGORY_MAINMENU, RT_MECHANISM_EVENTHANDLER,
        ItemInfo.MenuPath);
      Exit;
    end;
  end;
end;

// 主菜单处理过程-，卸载动态子菜单集合
procedure TCnMenuFormTranslator.UnHookMainMenuDynamicItems;
var
  I: Integer;
  ItemInfo: TCnAttachedMenuItem;
begin
  if FAttachedMenuItems.Count = 0 then
    Exit;

  for I := FAttachedMenuItems.Count - 1 downto 0 do
  begin
    ItemInfo := TCnAttachedMenuItem(FAttachedMenuItems[I]);
    if Assigned(ItemInfo) and Assigned(ItemInfo.MenuItem) then
      ItemInfo.MenuItem.OnClick := ItemInfo.OriginalOnClick;
  end;
  FAttachedMenuItems.Clear;
end;

// 弹出菜单处理过程，重写单个弹出菜单
procedure TCnMenuFormTranslator.TranslatePopupMenu(const AMenuCategory, AMechanism,
  AMenuPath: string);
var
  I, J: Integer;
  Form: TForm;
  FS: TObjectList;
  PopupMenu: TPopupMenu;
  Names: TStringList;
  Captions: TCn2DStringArray;
begin
  Names := nil;
  FS := nil;

  try
    Names := TStringList.Create;
    FS := TObjectList.Create(False);

    ExtractStrings(['.'], [' '], PChar(AMenuPath), Names);
    if not FindScreenFormByName(Names[0], FS) then
      Exit;

    if Names.Count = 3 then
    begin
      Captions := GetTranslationItemCaptions(AMenuCategory, AMechanism, AMenuPath);
      if Length(Captions) = 0 then
        Exit;

      for I := 0 to FS.Count - 1 do
      begin
        PopupMenu := FindPopupMenuByName(TForm(FS[I]), Names[1], Names[2]);
        if not Assigned(PopupMenu) then
          Continue;

        for J := 0 to PopupMenu.Items.Count - 1 do
          TranslateMenuItem(PopupMenu.Items[J], Captions);
      end;
    end;
  finally
    FS.Free;
    Names.Free;
  end;
end;

// 弹出菜单处理过程，重写控件区指定弹出菜单
procedure TCnMenuFormTranslator.TranslatePopupMenuPaletteItems;
var
  I: Integer;
  MenuPath: string;
  Form: TForm;
  PopupMenu: TPopupMenu;
{$IFDEF BDS}
  TempCaption: string;
  MenuItem: TMenuItem;
  PaletteButtonInfo: TCnPaletteButtonInfo;
{$ENDIF}
  Names: TStringList;
  Captions: TCn2DStringArray;
begin
  MenuPath := 'ToolForm.ToolForm.popPalette';
  // 重写控件区弹出菜单的固定标题子菜单

  Names := TStringList.Create;
  try
    ExtractStrings(['.'], [' '], PChar(MenuPath), Names);
    Form := FindScreenFormByName(Names[0]);
    if not Assigned(Form) then
      Exit;

    PopupMenu := FindPopupMenuByName(Form, Names[1], Names[2]);
    if not Assigned(PopupMenu) then
      Exit;

    Captions := GetTranslationItemCaptions(RT_CATEGORY_POPUPMENUS,
      RT_MECHANISM_EVENTHANDLER, MenuPath);
    if Length(Captions) > 0 then
    begin
      for I := 0 to PopupMenu.Items.Count - 1 do
        TranslateMenuItem(PopupMenu.Items[I], Captions);
    end;

    // 重写控件区弹出菜单的动态标题子菜单
{$IFDEF BDS}
    PaletteButtonInfo := GetPaletteButtonInfo;
    MenuItem := FindMenuItemByNameDeep(PopupMenu.Items, 'actnRemoveCategory1');
    if Assigned(MenuItem) then
    begin
      if PaletteButtonInfo.CateGoryCaption = '' then
      begin
        TempCaption := '&Delete Category...';
      end
      else
      begin
        TempCaption := '&Delete "' + PaletteButtonInfo.CateGoryCaption + '" Category...';
      end;
      Captions := GetTranslationItemCaptions(RT_CATEGORY_POPUPMENUS,
        RT_MECHANISM_EVENTHANDLER, MenuPath + '.actnRemoveCategory1');
      MenuItem.Caption := ReturnTranslateCaption(TempCaption, Captions);
    end;

    MenuItem := FindMenuItemByNameDeep(PopupMenu.Items, 'mnuRenameCategory');
    if Assigned(MenuItem) then
    begin
      if PaletteButtonInfo.CateGoryCaption = '' then
      begin
        TempCaption := 'Re&name Category';
      end
      else
      begin
        TempCaption := 'Re&name "' + PaletteButtonInfo.CateGoryCaption + '" Category';
      end;
      Captions := GetTranslationItemCaptions(RT_CATEGORY_POPUPMENUS,
        RT_MECHANISM_EVENTHANDLER, MenuPath + '.mnuRenameCategory');
      MenuItem.Caption := ReturnTranslateCaption(TempCaption, Captions);
    end;

    MenuItem := FindMenuItemByNameDeep(PopupMenu.Items, 'DeleteButton1');
    if Assigned(MenuItem) then
    begin
      if PaletteButtonInfo.ButtonCaption = '' then
      begin
        TempCaption := 'De&lete Button';
      end
      else
      begin
        TempCaption := 'De&lete "' + PaletteButtonInfo.ButtonCaption + '" Button';
      end;
      Captions := GetTranslationItemCaptions(RT_CATEGORY_POPUPMENUS,
        RT_MECHANISM_EVENTHANDLER, MenuPath + '.DeleteButton1');
      MenuItem.Caption := ReturnTranslateCaption(TempCaption, Captions);
    end;

    MenuItem := FindMenuItemByNameDeep(PopupMenu.Items, 'HideButton1');
    if Assigned(MenuItem) then
    begin
      if PaletteButtonInfo.ButtonCaption = '' then
      begin
        TempCaption := '&Hide Button';
      end
      else
      begin
        TempCaption := '&Hide "' + PaletteButtonInfo.ButtonCaption + '" Button';
      end;
      Captions := GetTranslationItemCaptions(RT_CATEGORY_POPUPMENUS,
        RT_MECHANISM_EVENTHANDLER, MenuPath + '.HideButton1');
      MenuItem.Caption := ReturnTranslateCaption(TempCaption, Captions);
    end;

    MenuItem := FindMenuItemByNameDeep(PopupMenu.Items, 'mnuShowButton');
    if Assigned(MenuItem) then
    begin
      TempCaption := 'Unhide &Button';
      Captions := GetTranslationItemCaptions(RT_CATEGORY_POPUPMENUS,
        RT_MECHANISM_EVENTHANDLER, MenuPath + '.mnuShowButton');
      MenuItem.Caption := ReturnTranslateCaption(TempCaption, Captions);
    end;
{$ENDIF}
  finally
    Names.Free;
  end;
end;

// 重写弹出菜单集合
procedure TCnMenuFormTranslator.TranslateStaticPopupMenus(OnlyCurrent: Boolean);
var
  I, J: Integer;
  MenuPaths: TCn2DStringArray;
  F: TCustomForm;
  S: string;
  FS: TObjectList;
begin
  if OnlyCurrent then
  begin
    F := Screen.ActiveCustomForm;
    if (F <> nil) and (F.Name <> '') then
    begin
      S := F.Name + '.';
      MenuPaths := GetTranslationMenuPaths(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_DIRECTACCESS, S);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnMenuTranslator.TranslateStaticPopupMenus for %s Get %d', [F.Name, Length(MenuPaths)]);
{$ENDIF}

      for I := 0 to Length(MenuPaths) - 1 do
      begin
        if Pos(S, MenuPaths[I, 0]) = 1 then
          TranslatePopupMenu(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_DIRECTACCESS,
           MenuPaths[I, 0]);
      end;

{$IFNDEF BDS}
      // 找 F 的深层 Controls 里有 TForm 的也进行类似翻译，以处理新的编辑器里停靠过来的情形，
      // 但为了性能，暂时不处理 TAppBuilder，且只低版本浮动有效
      if F.ClassNameIs('TAppBuilder') then
        Exit;

      FS := TObjectList.Create(False);
      try
        if FindFormsInControlDeep(F, FS) then
        begin
          for I := 0 to FS.Count - 1 do
          begin
            F := TForm(FS[I]);
            if (F <> nil) and (F.Name <> '') then
            begin
              S := F.Name + '.';
              MenuPaths := GetTranslationMenuPaths(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_DIRECTACCESS, S);
{$IFDEF DEBUG}
              CnDebugger.LogFmt('TCnMenuTranslator.TranslateStaticPopupMenus for Dock %s Get %d', [F.Name, Length(MenuPaths)]);
{$ENDIF}

              for J := 0 to Length(MenuPaths) - 1 do
              begin
                if Pos(S, MenuPaths[J, 0]) = 1 then
                  TranslatePopupMenu(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_DIRECTACCESS,
                   MenuPaths[J, 0]);
              end;
            end;
          end;
        end;
      finally
        FS.Free;
      end;
{$ENDIF}
    end;
  end
  else
  begin
    MenuPaths := GetTranslationMenuPaths(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_DIRECTACCESS);
    for I := 0 to Length(MenuPaths) - 1 do
      TranslatePopupMenu(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_DIRECTACCESS,
        MenuPaths[I, 0]);
  end;
end;

// 挂接当前活动编辑器窗口上的菜单控件
procedure TCnMenuFormTranslator.HookPopupMenuOnCurrentEditWindow;
const
  EDITWINDOW_PREFIX = 'EditWindow_';
var
  I: Integer;
  F: TForm;
  MenuPaths: TCn2DStringArray;
  Names: TStringList;
  PopupMenu: TPopupMenu;
  Hook: TCnMenuHook;
begin
  F := Screen.ActiveForm;
  if (F = nil) or (Pos(EDITWINDOW_PREFIX, F.Name) <> 1) then
    Exit;

  MenuPaths := GetTranslationMenuPaths(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_EVENTHANDLER);
  Names := TStringList.Create;
  try
    for I := 0 to Length(MenuPaths) - 1 do
    begin
      if Pos(EDITWINDOW_PREFIX, MenuPaths[I, 0]) <> 1 then
        Continue;

      Names.Clear;
      ExtractStrings(['.'], [' '], PChar(MenuPaths[I, 0]), Names);
      if Names.Count <> 3 then
        Continue;

      if StrEqualOrMatchStartWithStar(Names[0], F.Name) then
      begin
        PopupMenu := FindPopupMenuByName(F, Names[1], Names[2]);
        if not Assigned(PopupMenu) then
          Continue;

        if not IsPopupMenuHooked(PopupMenu) then
        begin
          Hook := TCnMenuHook.Create(nil);
          Hook.Text := MenuPaths[I, 0];
          Hook.HookMenu(PopupMenu);
          Hook.OnAfterPopup := AfterPopupMenuOnPopup;
          FAttachedPopupMenuHooks.Add(Hook);
        end;
      end;
    end;
  finally
    Names.Free;
  end;
end;

// 挂钩弹出菜单集合
procedure TCnMenuFormTranslator.HookPopupMenus;
var
  I, J: Integer;
  MenuPaths: TCn2DStringArray;
  Names: TStringList;
  FS: TObjectList;
  Form: TForm;
  PopupMenu: TPopupMenu;
  Hook: TCnMenuHook;
begin
  UnHookPopupMenus;
  MenuPaths := GetTranslationMenuPaths(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_EVENTHANDLER);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnMenuTranslator.HookPopupMenus %d', [Length(MenuPaths)]);
{$ENDIF}

  Names := nil;
  FS := nil;

  try
    Names := TStringList.Create;
    FS := TObjectList.Create(False);

    for I := 0 to Length(MenuPaths) - 1 do
    begin
      Names.Clear;
      ExtractStrings(['.'], [' '], PChar(MenuPaths[I, 0]), Names);
      if Names.Count <> 3 then
        Continue;

      FS.Clear;
      if not FindScreenFormByName(Names[0], FS) then
        Continue;

      for J := 0 to FS.Count - 1 do
      begin
        PopupMenu := FindPopupMenuByName(TForm(FS[J]), Names[1], Names[2]);
        if not Assigned(PopupMenu) then
          Continue;

        if not IsPopupMenuHooked(PopupMenu) then
        begin
          Hook := TCnMenuHook.Create(nil);
          Hook.Text := MenuPaths[I, 0];
          Hook.HookMenu(PopupMenu);
          Hook.OnAfterPopup := AfterPopupMenuOnPopup;
          FAttachedPopupMenuHooks.Add(Hook);
        end;
      end;
    end;
  finally
    FS.Free;
    Names.Free;
  end;
end;

// 动态弹出菜单挂钩事件
procedure TCnMenuFormTranslator.AfterPopupMenuOnPopup(Sender: TObject; Menu: TPopupMenu);
var
  I: Integer;
  Hook: TCnMenuHook;
begin
  for I := 0 to FAttachedPopupMenuHooks.Count - 1 do
  begin
    Hook := TCnMenuHook(FAttachedPopupMenuHooks[I]);
    if Hook.IsHooked(Menu) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('AfterPopupMenuOnPopup for a Hooked PopupMenu with Count ' + IntToStr(Menu.Items.Count));
{$ENDIF}
      if SameText(Menu.Name, 'popPalette') then
      begin
        TranslatePopupMenuPaletteItems;
      end
      else
      begin
        TranslatePopupMenu(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_EVENTHANDLER,
          Hook.Text);
      end;
      Exit;
    end;
  end;
end;

// 卸载弹出菜单集合
procedure TCnMenuFormTranslator.UnHookPopupMenus;
var
  I: Integer;
  Info: TCnAttachedPopupMenu;
begin
  // 卸载接管
  if FAttachedPopupMenuHooks.Count = 0 then
    Exit;

  for I := FAttachedPopupMenuHooks.Count - 1 downto 0 do
  begin
    Info := TCnAttachedPopupMenu(FAttachedPopupMenuHooks[I]);
    if Assigned(Info) and Assigned(Info.PopupMenu) then
      Info.PopupMenu.OnPopup := Info.OriginalOnPopup;
  end;
  FAttachedPopupMenuHooks.Clear;
end;

// 加载翻译数据
procedure TCnMenuFormTranslator.LoadTranslationMenus(const AMenuLangFile: string);
var
  StringList: TCnAnsiStringList;
  S: AnsiString;
begin
  StringList := TCnAnsiStringList.Create;
  if FileExists(AMenuLangFile) then
  begin
    StringList.LoadFromFile(AMenuLangFile);
    S := StringList.Text;
    if Length(S) > 3 then
      if (S[1] = #$EF) and (S[2] = #$BB) and (S[3] = #$BF) then
        Delete(S, 1, 3); // 去除 UTF8 的 BOM

    FTranslationMap := CnJSONParse(S);
  end;
  FreeAndNil(StringList);
end;

// 加载语言数据并初始化主菜单
procedure TCnMenuFormTranslator.LoadMenuItemLanguages;
var
  MainArray: TStringList;
  Form: TForm;
  Component: TComponent;
  JsonValue: TCnJSONValue;
  JsonObject: TCnJSONObject;
begin
  if not Assigned(FTranslationMap) then
    Exit;

  // 查找主菜单
  JsonValue := FTranslationMap[RT_CATEGORY_MAINMENU];
  if not (JsonValue is TCnJSONObject) then
    Exit;

  JsonObject := TCnJSONObject(JsonValue);
  FMainMenuPath := JsonObject['MainPath'].AsString;

  MainArray := TStringList.Create;
  try
    ExtractStrings(['.'], [' '], PChar(FMainMenuPath), MainArray);
    if MainArray.Count <> 2 then
      Exit;
    Form := FindScreenFormByName(MainArray[0]);
    if not Assigned(Form) then
      Exit;

    Component := Form.FindComponent(MainArray[1]);
    if not Assigned(Component) or not (Component is TMainMenu) then
      Exit;
  finally
    MainArray.Free;
  end;

  FMainMenu := TMainMenu(Component);
  if FMainMenu = nil then
    FMainMenu := GetIDEMainMenu;
end;

// 刷新所有菜单
procedure TCnMenuFormTranslator.UpdateWholeMenus;
var
  NTAServices: INTAServices;
begin
  if Supports(BorlandIDEServices, INTAServices, NTAServices) then
  begin
{$IFDEF BDS}
    NTAServices.MenuBeginUpdate;
    NTAServices.MenuEndUpdate;
{$ENDIF}
  end;
end;

constructor TCnMenuFormTranslator.Create(AStorage: TCnHashLangFileStorage);
var
  TranslationMapPath: string;
begin
  inherited Create;

  FStorageRef := AStorage;
  if FStorageRef <> nil then
    LoadAdditionalLangFile(GetAdditionalLangID);

  FTransQueue := TComponentList.Create(False);
  FTranFormsList := TComponentList.Create(False);

  // 初始化参数对象
  FAttachedPopupMenuHooks := TObjectList.Create(True);
  FAttachedMenuItems := TObjectList.Create(True);

  // 加载翻译内容
  TranslationMapPath := WizOptions.GetDataFileName(csMenuTransFile);
  LoadTranslationMenus(TranslationMapPath);

  CnLanguageManager.AddChangeNotifier(LangaugeChanged);

  CnWizNotifierServices.AddActiveProjectChangedNotifier(ActiveProjectChanged);
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
  CnWizNotifierServices.AddDesignerMenuBuildNotifier(DesignerMenuBuild);
end;

destructor TCnMenuFormTranslator.Destroy;
begin
  CnWizNotifierServices.RemoveDesignerMenuBuildNotifier(DesignerMenuBuild);
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  CnWizNotifierServices.RemoveActiveProjectChangedNotifier(ActiveProjectChanged);

  CnLanguageManager.RemoveChangeNotifier(LangaugeChanged);

  FOld2Array.Free;
  FNew2Array.Free;
  FreeAndNil(FTranslationMap);
  FreeAndNil(FAttachedPopupMenuHooks);
  FreeAndNil(FAttachedMenuItems);

  FreeAndNil(FTranFormsList);
  FreeAndNil(FTransQueue);
  inherited;
end;

function TCnMenuFormTranslator.GetAdditionalLangMainFileName: string;
begin
  Result := '<None.txt>';
{$IFDEF BDS}
  {$IFNDEF UNICODE}
  Result := 'RADStudio2007.txt';
  {$ENDIF}
{$ELSE}
  Result := 'Delphi7.txt';
{$ENDIF}
end;

function TCnMenuFormTranslator.GetAdditionalLangExtraFileName: string;
begin
  Result := CompilerShortName + '.txt';
end;

procedure TCnMenuFormTranslator.LoadAdditionalLangFile(ALangID: Cardinal);
var
  S, D: string;
begin
  FAddtionalLanguageFileLoad := False;
  if ALangID = 0 then
    D := FStorageRef.CurrentLanguage.LanguageDirName
  else
    D := IntToStr(ALangID);

  // 注意加载的额外语言文件，和专家包的当前语言不一定相同
  if FStorageRef.CurrentLanguage <> nil then
  begin
    // 大版本语言文件
    S := MakePath(MakePath(FStorageRef.LanguagePath) + D) + GetAdditionalLangMainFileName;
    if FileExists(S) then
    begin
      FStorageRef.AddExtraItemsFromFile(S);
      FAddtionalLanguageFileLoad := True;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('CnMenuFormTranslator.LoadAdditionalLangFile from ' + S);
{$ENDIF}
    end
    else
      Exit; // 没大版本语言文件则不加载小版本补充文件

    // 自身版本独特的语言文件
    if GetAdditionalLangExtraFileName <> '' then
    begin
      S := MakePath(MakePath(FStorageRef.LanguagePath) + D) + GetAdditionalLangExtraFileName;
      if FileExists(S) then
      begin
        FStorageRef.AddExtraItemsFromFile(S);
        FAddtionalLanguageFileLoad := True;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('CnMenuFormTranslator.LoadAdditionalLangFile for Self from ' + S);
{$ENDIF}
      end;
    end;

    // 不同版本的 Delphi，可在此针对当前语言的条目进行进一步处理：
    if Compiler in [cnDelphi2005, cnDelphi2006] then
    begin
      // 将语言条目中的 TDelphiProjectOptionsDialog 替换为低版本中的 TProjectOptionsDialog
      ChangeLangPrefix(TCnHackHashLangStorage(FStorageRef).HashMap,
        'TDelphiProjectOptionsDialog.', 'TProjectOptionsDialog.');
    end;
  end;
end;

procedure TCnMenuFormTranslator.DelayActivate(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnMenuTranslator.DelayActivate');
{$ENDIF}

  TranslateStaticMainMenu;
  TranslateMainMenuProjectItems;
  TranslateStaticPopupMenus;
  TranslatePopupMenuPaletteItems;
  HookMainMenuDynamicItems;
  HookPopupMenus;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnMenuTranslator.DelayActivate');
{$ENDIF}
end;

procedure TCnMenuFormTranslator.SetActive(const Value: Boolean);
begin
  if Value <> FActive then
  begin
    FActive := Value;
    if FActive then
    begin
      // 加载语言菜单
      LoadMenuItemLanguages;

      // 根据需要加载中文或英文翻译当前已存在的所有窗体
      LoadAdditionalLangFile(GetAdditionalLangID);
      TranslateAllExistingForms;

      // 延时挂载菜单和窗体容器
      CnWizNotifierServices.ExecuteOnApplicationIdle(DelayActivate);
    end
    else
    begin
      if not Application.Terminated then
      begin
        // 非 IDE 关闭情况下，恢复英文菜单
        TranslateStaticMainMenu;
        TranslateMainMenuProjectItems;
        TranslateStaticPopupMenus;
        TranslatePopupMenuPaletteItems;
        UpdateWholeMenus;

        // 根据需要将当前已存在的窗体翻译回英语
        LoadAdditionalLangFile(GetAdditionalLangID);
        TranslateAllExistingForms;
      end;

      // 卸载事件挂钩
      UnHookPopupMenus;
      UnHookMainMenuDynamicItems;
    end;
  end;
end;

procedure TCnMenuFormTranslator.ActiveProjectChanged(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnMenuTranslator.ActiveProjectChanged');
{$ENDIF}
  TranslateMainMenuProjectItems;
end;

function TCnMenuFormTranslator.IsPopupMenuHooked(Menu: TPopupMenu): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FAttachedPopupMenuHooks.Count - 1 do
  begin
    if TCnMenuHook(FAttachedPopupMenuHooks[I]).IsHooked(Menu) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TCnMenuFormTranslator.DebugCommand(Cmds, Results: TStrings);
var
  I: Integer;
  Hook: TCnMenuHook;
begin
  Results.Add(Format('CnMenuTranslator PopupMenu Hooks %d', [FAttachedPopupMenuHooks.Count]));
  for I := 0 to FAttachedPopupMenuHooks.Count - 1 do
  begin
    Hook := TCnMenuHook(FAttachedPopupMenuHooks[I]);
    if Hook.HookedMenuCount = 1 then
      Results.Add(Format('  %s: %s|%s', [Hook.Text, Hook.HookedMenu[0].Name, Hook.HookedMenu[0].ClassName]))
    else
      Results.Add(Format('  Error Get %d Menus', [Hook.HookedMenuCount]));
  end;
end;

procedure TCnMenuFormTranslator.TranslateQueue(Sender: TObject);
var
  F: TCustomForm;
begin
  while FTransQueue.Count > 0 do
  begin
    F := TCustomForm(FTransQueue[0]);
    CnLanguageManager.TranslateForm(F, True);
    if F.Visible then
      F.Update;

    FTransQueue.Delete(0);
    FTranFormsList.Add(F);
  end;
end;

procedure TCnMenuFormTranslator.ActiveFormChanged(Sender: TObject);
var
  F: TCustomForm;
begin
  TranslateStaticPopupMenus(True);
  HookPopupMenuOnCurrentEditWindow;

  if FActive and FAddtionalLanguageFileLoad and (WizOptions.CurrentLangID = csChineseID)
    and (Screen.ActiveCustomForm <> nil) then
  begin
    F := Screen.ActiveCustomForm;
    if {not F.ClassNameIs('TAppBuilder') and} (Pos('TCn', F.ClassName) <> 1) then
    begin
      if FTranFormsList.IndexOf(F) < 0 then
      begin
        if False {F.ClassNameIs('TProjectOptionsDialog')} then
        begin
          // 特殊窗体要等其延迟初始化完毕后再翻译，先留这么个口子
          FTransQueue.Add(F);
          CnWizNotifierServices.ExecuteOnApplicationIdle(TranslateQueue);
        end
        else
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('CnMultiLang ActiveFormChanged. Translate ' + F.ClassName);
{$ENDIF}
          CnLanguageManager.TranslateForm(F, True);
          if F.Visible then
            F.Update;
          FTranFormsList.Add(F);
        end;
      end
      else
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('CnMultiLang ActiveFormChanged. ' + F.ClassName + ' Already Translated. Do Nothing.');
{$ENDIF}
      end;
    end;
  end;
end;

procedure TCnMenuFormTranslator.LangaugeChanged(Sender: TObject);
begin
  LoadAdditionalLangFile(GetAdditionalLangID);
  TranslateAllExistingForms;
end;

procedure TCnMenuFormTranslator.DesignerMenuBuild(Sender: TObject; PopupMenu: TPopupMenu);
var
  I: Integer;
  Captions: TCn2DStringArray;
begin
  if FActive then
  begin
    Captions := GetTranslationItemCaptions(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_WINDOWPROC,
      'Application.TFormContainerForm.TPopupActionBar');
    if Length(Captions) = 0 then
      Exit;

    for I := 0 to PopupMenu.Items.Count - 1 do
      TranslateMenuItem(PopupMenu.Items[I], Captions);
  end;
end;

procedure TCnMenuFormTranslator.TranslateAllExistingForms;
var
  I: Integer;
  F: TCustomForm;
begin
  FTranFormsList.Clear;

  // 当前要翻译为中文、且当前语言是中文，且加载了 IDE 的中文语言文件，则翻译所有已经存在的窗体为中文
  if FActive and FAddtionalLanguageFileLoad and (WizOptions.CurrentLangID = csChineseID) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('CnMultiLang LangaugeChanged. Current Translate to Chinese UI.');
{$ENDIF}
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      F := Screen.CustomForms[I];
      if Pos('TCn', F.ClassName) <> 1 then
      begin
        if FTranFormsList.IndexOf(F) < 0 then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('CnMultiLang LangaugeChanged. Translate to Chinese ' + F.ClassName);
{$ENDIF}
          try
            CnLanguageManager.TranslateForm(F, True);
          except
            ;
          end;

          if F.Visible then
            F.Update;
          FTranFormsList.Add(F);
        end
        else
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('CnMultiLang LangaugeChanged. ' + F.ClassName + ' Already Translated. Do Nothing.');
{$ENDIF}
        end;
      end;
    end;
    FAlreadyChinese := True;
  end
  else if FAlreadyChinese then // 其他情况，只要曾经中文了，就翻译回英文一次
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('CnMultiLang LangaugeChanged. Current Already Chinese UI. Translate back to English.');
{$ENDIF}
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      F := Screen.CustomForms[I];
      if Pos('TCn', F.ClassName) <> 1 then
      begin
        if FTranFormsList.IndexOf(F) < 0 then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('CnMultiLang LangaugeChanged. Translate to English ' + F.ClassName);
{$ENDIF}
          try
            CnLanguageManager.TranslateForm(F, True);
          except
            ;
          end;

          if F.Visible then
            F.Update;
          FTranFormsList.Add(F);
        end;
      end;
    end;
    FAlreadyChinese := False;
  end;
end;

function TCnMenuFormTranslator.GetAdditionalLangID: Cardinal;
begin
  if FActive and (WizOptions.CurrentLangID = csChineseID) then
    Result := csChineseID
  else
    Result := csEnglishID;
end;

end.

