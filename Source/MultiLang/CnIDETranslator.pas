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
* 修改记录：2026.04.03 V1.4
*               加入资源字符串 Hook 的机制，仅少数版本启用，待测试
*           2026.04.01 V1.3
*               加入大量界面翻译机制，待不断完善中
*           2026.02.24 V1.2
*               移植入专家包。重构插件，主菜单（直接写）、弹出菜单（事件挂钩）、活动窗体菜单（子类化窗口）
*           2025.12.21 V1.1
*               添加编辑区弹出菜单翻译支持，直接写菜单项标题和对应动作的标题
*           2025.12.17 V1.0
*               提供主菜单中英文翻译支持，直接写菜单项标题
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFNDEF UNICODE}
//  {$DEFINE ENABLE_RESSTRING_HOOK} // 不完善，暂时屏蔽
{$ENDIF}

uses
  Windows, Messages, Classes, Contnrs, SysUtils, ActnList, Graphics, // Vcl.CategoryButtons,
  Controls, Forms, Menus, Clipbrd, ComCtrls, Tabs, {$IFDEF COMPILER7_UP} ActnMenus, {$ENDIF}
  CnJSON, CnHashMap, CnWizUtils, CnWizIdeUtils, CnWizMethodHook, CnHashLangStorage,
  CnWizCmdNotify, CnWizCmdMsg, CnWizCompilerConst, CnWizNotifier,
  {$IFDEF COMPILER7_UP} ActnPopup, {$ENDIF}
  {$IFDEF UNICODE} CnControlHook, {$ENDIF}
  CnEditControlWrapper, {$IFDEF BDS} CategoryButtons, {$ENDIF} // 2005 及以上才有新组件板的 CategoryButtons
  {$IFDEF COMPILER6_UP} DesignIntf, DesignEditors, DesignMenus,{$ELSE}
  DsgnIntf, {$ENDIF} ToolsAPI;

type
  TCn1DStringArray = array of string;
  TCn2DStringArray = array of array of string;

  TCnMenuCaptionPrefixSuffix = record
  {* 含 || 的前缀/后缀替换规则，预解析后存储 }
    OldPrefix: string;
    OldSuffix: string;
    NewPrefix: string;
    NewSuffix: string;
  end;

  TCnMenuCaptionEntry = class
  {* 单个 MenuPath 的翻译缓存：精确匹配用 HashMap，|| 规则单独列表 }
  public
    ExactMap: TCnStrToStrHashMap;       // LowerCase(英文) -> 译文
    OriginalENUMap: TCnStrToStrHashMap; // LowerCase(英文) -> 原始大小写英文（用于切回英文时还原）
    PrefixSuffixRules: array of TCnMenuCaptionPrefixSuffix;
    constructor Create;
    destructor Destroy; override;
  end;

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
    FOldFont: TFont;
    FLangTransFlag: Boolean;
    FTransQueue: TComponentList;
    FTranedCompList: TComponentList;      // 记录已经翻译过的窗体、容器等，避免重复
    FOld2Array, FNew2Array: TStringList;
    FTranslationMap: TCnJSONObject;
    FMenuCaptionIndex: TStringList;   // Sorted，key=Category|Mechanism|MenuPath，Object=TCnMenuCaptionEntry
    FMainMenu: TMainMenu;
    FMainMenuPath: string;
    FAttachedPopupMenuHooks: TObjectList; // 容纳 TCnMenuHookWrapper
    FAttachedMenuItems: TObjectList;
    // 注意不能记录已经静态翻译过的 PopupMenu 来避免重复，因为 IDE 自身会老改
{$IFDEF COMPILER7_UP}
    FIDEMainMenuBar: TActionMainMenuBar;
{$ENDIF}
{$IFDEF ENABLE_RESSTRING_HOOK}
    FLoadResStringHook: TCnMethodHook;
{$ENDIF}
{$IFDEF UNICODE}
    FDrawingInspListBoxes: TObjectList;        // 当前正在 WM_PAINT 处理中的 InspListBox
    FPendingRemoveInspListBoxes: TObjectList;  // WM_PAINT After 后待移除（延迟移除，覆盖补绘）
    FInspListBoxControlHook: TCnControlHook;
    FTextDrawHook: TCnMethodHook;
{$IFDEF IDE_CATALOG_VIRTUALTREE}
    FVirtualTreeHooks: TObjectList;
{$ENDIF}
{$ENDIF}
{$IFDEF IDE_OPTION_DYNCREATE}
    FPropertySheetControlHook: TCnControlHook;
{$ENDIF}
    function CanTranslateToChinese: Boolean;
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
    function FindPopupMenuByName(const AForm: TComponent; const AOwnerName, AMenuName: string): TPopupMenu;
    {* AOwnerName 支持通配符 *}

    function FindScreenFormByName(const AFormName: string): TForm; overload;
    function FindScreenFormByName(const AFormName: string; FormResult: TObjectList): Boolean; overload;
    function GetActiveProjectInfo: TCnActiveProjectInfo;

    function IsPopupMenuHooked(Menu: TPopupMenu): Boolean;
{$IFDEF BDS}
    function GetPaletteButtonInfo: TCnPaletteButtonInfo;
    procedure SourceEditorNotify(SourceEditor: TCnSourceEditorInterface;
      NotifyType: TCnWizSourceEditorNotifyType {$IFDEF DELPHI_OTA}; EditView: IOTAEditView {$ENDIF});
{$ENDIF}
    function GetTranslationMenuPaths(const AMenuCategory, AMechanism: string;
      const APrefix: string = ''): TCn1DStringArray;
    function GetTranslationItemCaptions(const AMenuCategory, AMechanism,
      AMenuPath: string): TCn2DStringArray;
    function ReturnTranslateCaption(const AItemCaption: string; const ACaptions:
      TCn2DStringArray): string;
    function ReturnTranslateCaptionFromCache(const AItemCaption: string;
      Entry: TCnMenuCaptionEntry): string;
    {* 直接从缓存 Entry 查找译文，比 ReturnTranslateCaption 更高效 }

    procedure TranslateMenuItem(const AMenuItem: TMenuItem; const ACaptions: TCn2DStringArray);
    procedure TranslateMenuItemFromCache(const AMenuItem: TMenuItem; Entry: TCnMenuCaptionEntry);
    {* 直接从缓存 Entry 翻译菜单项，避免构造临时二维数组 }

    // 主菜单处理过程
    procedure TranslateMainMenuDynamicItem(const AMenuCategory, AMechanism, AMenuPath: string);
    {* 翻译主菜单中的其他动态条目}
    procedure TranslateStaticMainMenu;
    {* 翻译主菜单中的静态条目}
    procedure TranslateMainMenuProjectItems;
    {* 翻译主菜单中工程相关的动态条目，注意需在当前工程切换时通知调用}

    procedure TranslateStaticEditorTab;
    {* 单独翻译编辑器 Tab，内部不能控制防重}
    procedure TranslateStaticEditorSubViews;
    {* 单独翻译编辑器的 SubView 们，目前只翻译 CPU}

    procedure HookMainMenuDynamicItems;
    {* 部分主菜单的主菜单项内容是动态生成的，需要通过 Hook 这几个 Item 的 OnClick 来处理}

    procedure HookedMenuItemOnClick(Sender: TObject);
    {* 用来挂接的新点击事件处理器}
    procedure UnHookMainMenuDynamicItems;
    {* 解除挂接主菜单}

    // 弹出菜单处理过程
    procedure TranslatePopupMenu(const AMenuCategory, AMechanism, AMenuPath: string;
      Container: TComponent = nil);
    {* 翻译一个弹出菜单，可弹出时动态调用，也可直接调用，
       默认从匹配 AMenuPath 的 Screen 里找 Form 们的菜单，如 Container 不为 nil 则从 Container 里找菜单}
    procedure TranslatePopupMenuPaletteItems;
    {* 翻译控件板的弹出菜单}
    procedure TranslateStaticPopupMenus(OnlyCurrent: Boolean = False);
    {* 翻译其他静态弹出菜单，OnlyCurrent 为 True 表示只翻译最靠前窗体的}
    procedure TranslateStaticPopupMenusForContainer(Container: TComponent);
    {* 翻译指定容器的其他静态弹出菜单，MenuPath 采用 Container 的名字}
    procedure HookPopupMenus(OnlyCurrent: Boolean = False);
    {* 挂接所有现有的弹出菜单以在弹出后进行翻译，OnlyCurrent 为 True 表示只挂当前窗口的}
    procedure HookPopupMenuOnCurrentEditWindow;
    {* 挂接当前活动编辑器窗口上的弹出菜单控件}
{$IFDEF BDS}
    procedure HookPopupMenuOnSubView(SubView: TComponent);
    {* 挂接当前活动 SubView 中的弹出菜单控件}
{$ENDIF}
    procedure AfterPopupMenuOnPopup(Sender: TObject; Menu: TPopupMenu);
    {* 用来挂接的新弹出事件处理器}
    procedure UnHookPopupMenus;
    {* 解除挂接所有弹出菜单}

    // 插件处理过程
    procedure LoadTranslationMenus(const AMenuLangFile: string);
    procedure BuildCaptionCache;
    {* 将 FTranslationMap 中所有 ItemCaption 预处理为 HashMap 缓存，加速运行时查找 }
    procedure LoadMenuItemLanguages;
    procedure UpdateWholeMenus;
    procedure TranslateAllExistingForms(const ClassNamePattern: string = '');
    {* 翻译现有 IDE 的窗体。以下几种情况下会被调用：
      中文状态下汉化功能启用或禁用时（SetActive 中调用），内部检查 FActive 以决定翻成中文还是英文，
      切换语言到中文时且汉化功能启用时调用（LanguageChanged 中调用，内部翻成中文）
      切换语言到非中文语言时（LanguageChanged 中调用，内部翻译成英文}

{$IFDEF IDE_CATALOG_VIRTUALTREE}
    procedure ClearUnusedVirtualTreeHooks;
    procedure VSTTranslateText(Sender: TObject; const AText: string; var ATranslated: string);
{$ENDIF}
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

    procedure MultiLangTranslateObject(AObject: TObject; var Translate: Boolean);
    procedure MultiLangTranslateObjectProperty(AObject: TObject;
      const PropName: string; var Translate: Boolean);

    procedure CommandNotify(const Command: Cardinal; const SourceID: PAnsiChar;
      const DestID: PAnsiChar; const IDESets: TCnCompilers; const Params: TStrings);

    procedure CheckSubViewPopupMenus(Sender: TObject);
    procedure CheckSubViewTranslation(Sender: TObject);
    procedure EditorChange(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);
{$IFDEF BDS}
    function TranslateTreeViewCatalog(AComponent: TComponent): Boolean;
    {* 手动翻译树节点，包括 TTreeView 和 TVirtualStringList 两种情况}
{$ENDIF}
{$IFDEF UNICODE}
    procedure ClearTextDrawMessageHooks;
    procedure HookMessagesInControl(ARootControl: TControl);
    procedure InstallTextDrawHook;
    procedure UninstallTextDrawHook;

    procedure InspListBoxControlBeforeMessage(Sender: TObject; Control: TControl;
      var Msg: TMessage; var Handled: Boolean);
    procedure InspListBoxControlAfterMessage(Sender: TObject; Control: TControl;
      var Msg: TMessage; var Handled: Boolean);
    procedure InspListBoxUnHook(Sender: TObject; Control: TControl);
{$ENDIF}
{$IFDEF IDE_OPTION_DYNCREATE}
    procedure IdleTranslatePage(Sender: TObject);
    procedure PropertySheetAfterMessage(Sender: TObject; Control: TControl;
      var Msg: TMessage; var Handled: Boolean);
{$ENDIF}
{$IFDEF COMPILER7_UP}
    procedure OnApplicationIdle(Sender: TObject);
    procedure CheckActionMainMenuBarPersistentHotKeys;
    {* 汉化状态下，一空闲就改 PersistentHotKeys 为 True}
{$ENDIF}
  public
    constructor Create(AStorage: TCnHashLangFileStorage);
    destructor Destroy; override;

    procedure DebugCommand(Cmds: TStrings; Results: TStrings);

    property Active: Boolean read FActive write SetActive;
    {* 是否启用英译中功能}
  end;

implementation

uses
  CnCommon, CnMenuHook, CnStrings, CnWizOptions,
  {$IFDEF IDE_CATALOG_VIRTUALTREE} CnVSTreeOp, {$ENDIF}
  CnWizMultiLang, CnLangMgr, CnWideStrings, CnLangCollection, CnLangStorage
  {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  csEnglishID = 1033;
  csChineseID = 2052;

  csMenuTransFile = 'TransMenu.json';
  INDEX_ENU = 0;
  INDEX_CHS = 1;

  // 翻译的菜单类型
  SCN_CATEGORY_MAINMENU: string = 'MainMenu';
  SCN_CATEGORY_POPUPMENUS: string = 'PopupMenus';
  SCN_CATEGORY_SCREENFORMS: string = 'ScreenForms';

  // 翻译的翻译机制
  SCN_MECHANISM_DIRECTACCESS: string = 'DirectAccess';
  SCN_MECHANISM_EVENTHANDLER: string = 'EventHandler';
  SCN_MECHANISM_WINDOWPROC: string = 'WindowProc';

  SCN_INSP_LIST_BOX = 'TInspListBox';
  SCN_TREE_NAME = 'trvwPageNodes';

type
  TCnMenuHookWrapper = class
  private
    FContainer: TComponent;
    FHook: TCnMenuHook;
    FText: string;
  public
    constructor Create;
    destructor Destroy; override;

    property Hook: TCnMenuHook read FHook;
    property Text: string read FText write FText;
    property Container: TComponent read FContainer write FContainer;
  end;

  TCnHackHashLangStorage = class(TCnCustomHashLangStorage);

  TLoadResStringFunc = function(ResStringRec: PResStringRec): string;

{$IFDEF UNICODE}

  TCanvasTextRectMethod = procedure (Rect: TRect; X, Y: Integer; const Text: string) of object;

  TCanvasTextRectProc = procedure (ASelf: TCanvas; Rect: TRect; X, Y: Integer; const Text: string);

{$ENDIF}

var
  FUITranslator: TCnMenuFormTranslator = nil;
{$IFDEF UNICODE}
  FOldCanvasTextRect: TCanvasTextRectProc = nil;
{$IFDEF DEBUG}
  FHookedStringHashMap: TCnLangHashMap = nil;
{$ENDIF}
{$ENDIF}

{ TCnMenuCaptionEntry }

constructor TCnMenuCaptionEntry.Create;
begin
  inherited;
  ExactMap := TCnStrToStrHashMap.Create(64);
  OriginalENUMap := TCnStrToStrHashMap.Create(64);
end;

destructor TCnMenuCaptionEntry.Destroy;
begin
  ExactMap.Free;
  OriginalENUMap.Free;
  inherited;
end;

{$IFDEF UNICODE}

procedure MyHookedCanvasTextRect(ASelf: TCanvas; Rect: TRect; X, Y: Integer; const Text: string);
var
  OldProc: TCanvasTextRectProc;
  S: string;
begin
{$IFDEF DEBUG}
//  if Text <> '' then
//    CnDebugger.LogFmt('CnIDETranslator InspListBox Painting Count %d. Canvas.TextRect Left %d, Top %d: %s',
//      [FUITranslator.FDrawingInspListBoxes.Count, Rect.Left, Rect.Top, Text]);
{$ENDIF}

{$IFDEF DEBUG}
//   Left < 100 的字符串，都记下来
//   if (FUITranslator.FDrawingInspListBoxes.Count > 0) and (Rect.Left < 100) then
//   begin
//     if FHookedStringHashMap = nil then
//       FHookedStringHashMap := TCnLangHashMap.Create;
//
//     FHookedStringHashMap.Add(Text, '');
//   end;
{$ENDIF}

  if (FUITranslator.FDrawingInspListBoxes.Count > 0) and (Rect.Left < 120) then  // 靠左绘制的才翻译，免得右边的值串区域也翻译了
  begin
    S := CnLanguageManager.Translate(Text);
    if S = '' then
      S := Text;
  end
  else
    S := Text;

  if FUITranslator.FTextDrawHook.UseDDteours then
  begin
    OldProc := TCanvasTextRectProc(FUITranslator.FTextDrawHook.Trampoline);
    OldProc(ASelf, Rect, X, Y, S);
  end
  else
  begin
    FUITranslator.FTextDrawHook.UnhookMethod;
    try
      ASelf.TextRect(Rect, X, Y, S);
    finally
      FUITranslator.FTextDrawHook.HookMethod;
    end;
  end;
end;

{$ENDIF}

{$IFDEF ENABLE_RESSTRING_HOOK}

// LoadResString Hook 函数：输出字符串内容，预留翻译替换机制，原封不动返回
function MyHookedLoadResString(ResStringRec: PResStringRec): string;
var
  S: string;
begin
  // 先调用原始函数获取字符串
  if FUITranslator.FLoadResStringHook.UseDDteours then
  begin
    S := TLoadResStringFunc(FUITranslator.FLoadResStringHook.Trampoline)(ResStringRec);
  end
  else
  begin
    FUITranslator.FLoadResStringHook.UnhookMethod;
    try
      S := System.LoadResString(ResStringRec);
    finally
      FUITranslator.FLoadResStringHook.HookMethod;
    end;
  end;

{$IFDEF DEBUG}
// 输出字符串内容，便于收集需要翻译的资源字符串
//  if (S <> '') and (Pos('Cn', S) <> 1) then
//    CnDebugger.LogFmt('CnIDETranslator LoadResString: %s', [S]);
{$ENDIF}

  Result := CnLanguageManager.Translate(S);
  if Result = '' then
    Result := S;
end;

{$ENDIF}

function StrEqualOrMatchStartWithStar(const APattern, AStr: string): Boolean;
var
  I: Integer;
  Prefix: string;
begin
  Result := True;
  if AStr = APattern then
    Exit;

  I := Pos('*', APattern);
  if I > 1 then
  begin
    Prefix := Copy(APattern, 1, I - 1);
    Result := Pos(Prefix, AStr) = 1;
  end
  else
    Result := False;
end;

// 判断名字或@类名是否与对应组件匹配
function MatchNamedOrClassPattern(const APattern: string; const AComponent: TComponent): Boolean;
var
  ClassNamePattern: string;
begin
  Result := False;
  if not Assigned(AComponent) then
    Exit;

  if (APattern <> '') and (APattern[1] = '@') then
  begin
    ClassNamePattern := Copy(APattern, 2, MaxInt);
    Result := (ClassNamePattern <> '') and (AComponent.Name = '') and
      SameText(AComponent.ClassName, ClassNamePattern);
  end
  else
    Result := StrEqualOrMatchStartWithStar(APattern, AComponent.Name);
end;

// 如果 NewPrefix 为空则代表删除 OldPrefix 开头的所有条目
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

{$IFDEF DEBUG}
    CnDebugger.LogFmt('MenuForm Translator ChangeLangPrefix %d from %s to %s',
      [OldKeys.Count, OldPrefix, NewPrefix]);
{$ENDIF}

    for I := 0 to OldKeys.Count - 1 do
      AMap.Delete(OldKeys[I]);

    if NewPrefix <> '' then
    begin
      for I := 0 to OldKeys.Count - 1 do
      begin
        NewKey := NewPrefix + Copy(OldKeys[I], Length(OldPrefix) + 1, MaxInt);
        AMap.Add(NewKey, OldValues[I]);
      end;
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

  if MatchNamedOrClassPattern(AName, ARootComp) then
  begin
    Result := ARootComp;
    Exit;
  end;

  for I := 0 to ARootComp.ComponentCount - 1 do
  begin
    Component := ARootComp.Components[I];
    if MatchNamedOrClassPattern(AName, Component) then
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

  if MatchNamedOrClassPattern(AName, ARootControl) then
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
    if MatchNamedOrClassPattern(AName, Control) then
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

// 根据名称查找顶层窗体，如果名称是 Application 则加入 Application
function TCnMenuFormTranslator.FindScreenFormByName(const AFormName: string; FormResult: TObjectList): Boolean;
var
  I: Integer;
  Form: TForm;
  Prefix: string;
begin
  Result := False;
  if AFormName = 'Application' then
  begin
    FormResult.Add(Application);
    Exit;                       // 不考虑叫 Application 的窗体
  end;

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

// 根据名称查找多个子组件（支持@类名及 * 通配符）
function TCnMenuFormTranslator.FindComponentByNameDeep(const ARootComp: TComponent;
  const AName: string; ComponentResult: TObjectList): Boolean;

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
      if MatchNamedOrClassPattern(AName, SubComp) then
      begin
        ComponentResult.Add(SubComp);
        Result := True;
      end;
      // 递归查找子组件
      SearchComponents(SubComp);
    end;
  end;

begin
  Result := False;
  if not Assigned(ARootComp) then
    Exit;


  // 先检查根组件自身
  if MatchNamedOrClassPattern(AName, ARootComp) then
  begin
    ComponentResult.Add(ARootComp);
    Result := True;
  end;

  // 递归查找所有子组件
  SearchComponents(ARootComp);
end;

// 根据名称查找多个子控件（支持通配符）
function TCnMenuFormTranslator.FindControlByNameDeep(const ARootControl: TControl;
  const AName: string; ControlResult: TObjectList): Boolean;

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
      if MatchNamedOrClassPattern(AName, SubControl) then
      begin
        ControlResult.Add(SubControl);
        Result := True;
      end;
      // 递归查找子控件
      SearchControls(SubControl);
    end;
  end;

begin
  Result := False;
  if not Assigned(ARootControl) then
    Exit;

  if MatchNamedOrClassPattern(AName, ARootControl) then
  begin
    ControlResult.Add(ARootControl);
    Result := True;
  end;

  // 递归查找所有子控件
  SearchControls(ARootControl);
end;

// 递归查找控件树中的所有窗体
function TCnMenuFormTranslator.FindFormsInControlDeep(const ARootControl: TControl;
  FormList: TObjectList): Boolean;

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

// 根据名称在指定组件里查找弹出菜单，需要 AOwnerName 支持通配符及@类名
function TCnMenuFormTranslator.FindPopupMenuByName(const AForm: TComponent;
  const AOwnerName, AMenuName: string): TPopupMenu;
var
  I: Integer;
  MenuOwner, Component: TComponent;
begin
  Result := nil;
  if not Assigned(AForm) then
    Exit;

  // 这里找 MenuOwner 支持 @类名，避免 Owner 没名字的情况下找不着
  MenuOwner := FindComponentByNameDeep(AForm, AOwnerName);
  if not Assigned(MenuOwner) and (AForm is TControl) then
    MenuOwner := FindControlByNameDeep(TControl(AForm), AOwnerName);
  if not Assigned(MenuOwner) then
    Exit;

  for I := 0 to MenuOwner.ComponentCount - 1 do
  begin
    Component := MenuOwner.Components[I];

    // 名字匹配，或者没名字但 @类名匹配
    if Component is TPopupMenu then
    begin
      if SameText(Component.Name, AMenuName) then
      begin
        Result := TPopupMenu(Component);
        Exit;
      end
      else if (Component.Name = '') and (AMenuName = '@' + Component.ClassName) then
      begin
        Result := TPopupMenu(Component);
        Exit;
      end;
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

procedure TCnMenuFormTranslator.SourceEditorNotify(SourceEditor: TCnSourceEditorInterface;
  NotifyType: TCnWizSourceEditorNotifyType {$IFDEF DELPHI_OTA}; EditView: IOTAEditView {$ENDIF});
begin
  if NotifyType = setEditViewActivated then
    TranslateStaticEditorTab;
end;

{$ENDIF}

// 根据菜单类型查找菜单路径
function TCnMenuFormTranslator.GetTranslationMenuPaths(const AMenuCategory,
  AMechanism: string; const APrefix: string): TCn1DStringArray;
var
  I, Count: Integer;
  JsonValue: TCnJSONValue;
  JsonArray: TCnJSONArray;
  JsonObject: TCnJSONObject;
begin
  SetLength(Result, 0);
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

  SetLength(Result, Count);
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

      Result[Count] := JsonObject['MenuPath'].AsString;
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

    SetLength(Result, Count);

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

        Result[Count] := JsonObject['MenuPath'].AsString;
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
  CacheKey: string;
  CacheIdx: Integer;
  Entry: TCnMenuCaptionEntry;
  ENU, CHS: string;
  RuleIdx: Integer;
begin
  SetLength(Result, 0, 0);

  // Try cache first: O(log N) binary search + O(1) HashMap lookup
  if Assigned(FMenuCaptionIndex) then
  begin
    CacheKey := LowerCase(AMenuCategory + '|' + AMechanism + '|' + AMenuPath);
    CacheIdx := FMenuCaptionIndex.IndexOf(CacheKey);
    if CacheIdx >= 0 then
    begin
      Entry := TCnMenuCaptionEntry(FMenuCaptionIndex.Objects[CacheIdx]);
      Count := Entry.ExactMap.Size + Length(Entry.PrefixSuffixRules);
      if Count = 0 then
        Exit;

      SetLength(Result, Count, 2);
      Count := 0;

      Entry.ExactMap.StartEnum;
      if FActive then
      begin
        while Entry.ExactMap.GetNext(ENU, CHS) do
        begin
          Result[Count, 0] := ENU;
          Result[Count, 1] := CHS;
          Inc(Count);
        end;
        for RuleIdx := 0 to Length(Entry.PrefixSuffixRules) - 1 do
        begin
          Result[Count, 0] := Entry.PrefixSuffixRules[RuleIdx].OldPrefix + '||'
            + Entry.PrefixSuffixRules[RuleIdx].OldSuffix;
          Result[Count, 1] := Entry.PrefixSuffixRules[RuleIdx].NewPrefix + '||'
            + Entry.PrefixSuffixRules[RuleIdx].NewSuffix;
          Inc(Count);
        end;
      end
      else
      begin
        while Entry.ExactMap.GetNext(ENU, CHS) do
        begin
          // ENU 此时是小写 key，需要从 OriginalENUMap 取回原始大小写
          Result[Count, 0] := CHS;
          if not Entry.OriginalENUMap.Find(ENU, Result[Count, 1]) then
          Result[Count, 1] := ENU;
          Inc(Count);
        end;
        for RuleIdx := 0 to Length(Entry.PrefixSuffixRules) - 1 do
        begin
          Result[Count, 0] := Entry.PrefixSuffixRules[RuleIdx].NewPrefix + '||'
            + Entry.PrefixSuffixRules[RuleIdx].NewSuffix;
          Result[Count, 1] := Entry.PrefixSuffixRules[RuleIdx].OldPrefix + '||'
            + Entry.PrefixSuffixRules[RuleIdx].OldSuffix;
          Inc(Count);
        end;
      end;
      SetLength(Result, Count, 2);
      Exit;
    end;
  end;

  // Fallback to JSON scan when cache is not available
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
      Break;
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

// Translate a menu item recursively using the pre-built cache entry (fast path)
// Fast caption translation using pre-built cache entry.
// For the active (ENU->CHS) path: O(1) HashMap lookup.
// For the inactive (CHS->ENU) path: falls back to ReturnTranslateCaption.
function TCnMenuFormTranslator.ReturnTranslateCaptionFromCache(const AItemCaption: string;
  Entry: TCnMenuCaptionEntry): string;
var
  Position, RuleIdx: Integer;
  ReducedCaption, NewCaption, AccessKey, Ellipsis, LowReduced: string;
  Rule: TCnMenuCaptionPrefixSuffix;

  function RestoreAccessKeyAndEllipsis: string;
  begin
    if AccessKey <> '' then
      NewCaption := NewCaption + '(&' + AccessKey + ')';
    if Ellipsis <> '' then
      NewCaption := NewCaption + Ellipsis;
    Result := NewCaption;
  end;

begin
  Result := AItemCaption;
  if not Assigned(Entry) then
    Exit;

  // Inactive path is rare (language switch back to English); use original slow path
  if not FActive then
  begin
    Result := ReturnTranslateCaption(AItemCaption,
      GetTranslationItemCaptions('', '', ''));
    // GetTranslationItemCaptions with empty keys returns empty array,
    // so ReturnTranslateCaption returns AItemCaption unchanged.
    // The caller (TranslateMenuItemFromCache) should not be called when FActive=False.
    Exit;
  end;

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

  // O(1) exact match: ExactMap stores LowerCase(ENU) -> CHS
  LowReduced := LowerCase(ReducedCaption);
  if Entry.ExactMap.Find(LowReduced, NewCaption) then
  begin
    Result := RestoreAccessKeyAndEllipsis;
    Exit;
  end;

  // Check prefix/suffix rules
  for RuleIdx := 0 to Length(Entry.PrefixSuffixRules) - 1 do
  begin
    Rule := Entry.PrefixSuffixRules[RuleIdx];
    if (Rule.OldPrefix <> '') and (Rule.OldSuffix = '') then
    begin
      if SameText(Rule.OldPrefix, Copy(ReducedCaption, 1, Length(Rule.OldPrefix))) then
      begin
        NewCaption := Rule.NewPrefix + StrRight(ReducedCaption,
          Length(ReducedCaption) - Length(Rule.OldPrefix));
        Result := RestoreAccessKeyAndEllipsis;
        Exit;
      end;
    end
    else if (Rule.OldPrefix = '') and (Rule.OldSuffix <> '') then
    begin
      if SameText(Rule.OldSuffix, StrRight(ReducedCaption, Length(Rule.OldSuffix))) then
      begin
        NewCaption := Copy(ReducedCaption, 1, Length(ReducedCaption) - Length(Rule.OldSuffix))
          + Rule.NewSuffix;
        Result := RestoreAccessKeyAndEllipsis;
        Exit;
      end;
    end
    else if (Rule.OldPrefix <> '') and (Rule.OldSuffix <> '') then
    begin
      if SameText(Rule.OldPrefix, Copy(ReducedCaption, 1, Length(Rule.OldPrefix)))
        and SameText(Rule.OldSuffix, StrRight(ReducedCaption, Length(Rule.OldSuffix))) then
      begin
        NewCaption := Rule.NewPrefix + StrRight(ReducedCaption,
          Length(ReducedCaption) - Length(Rule.OldPrefix));
        NewCaption := Copy(NewCaption, 1, Length(NewCaption) - Length(Rule.OldSuffix))
          + Rule.NewSuffix;
        Result := RestoreAccessKeyAndEllipsis;
        Exit;
      end;
    end;
  end;
end;

procedure TCnMenuFormTranslator.TranslateMenuItemFromCache(const AMenuItem: TMenuItem;
  Entry: TCnMenuCaptionEntry);
var
  I: Integer;
begin
  if not Assigned(AMenuItem) or not Assigned(Entry) then
    Exit;
  if (AMenuItem.Caption = '-') or (AMenuItem.Caption = '') then
    Exit;

  AMenuItem.Caption := ReturnTranslateCaptionFromCache(AMenuItem.Caption, Entry);

  for I := 0 to AMenuItem.Count - 1 do
    TranslateMenuItemFromCache(AMenuItem.Items[I], Entry);
end;


// Translate a menu item recursively using the 2D array (compatibility path)
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
  CacheKey: string;
  CacheIdx: Integer;
  Entry: TCnMenuCaptionEntry;
begin
  if not Assigned(FMainMenu) then
    Exit;

  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, AMenuPath);
  if not Assigned(MenuItem) then
    Exit;

  // Fast path: use pre-built cache entry when active (ENU->CHS)
  if FActive and Assigned(FMenuCaptionIndex) then
  begin
    CacheKey := LowerCase(AMenuCategory + '|' + AMechanism + '|' + AMenuPath);
    CacheIdx := FMenuCaptionIndex.IndexOf(CacheKey);
    if CacheIdx >= 0 then
    begin
      Entry := TCnMenuCaptionEntry(FMenuCaptionIndex.Objects[CacheIdx]);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TranslateDynamicMainMenu %s (cache hit)', [AMenuPath]);
{$ENDIF}
      TranslateMenuItemFromCache(MenuItem, Entry);
      Exit;
    end;
  end;

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
  CacheKey: string;
  CacheIdx: Integer;
  Entry: TCnMenuCaptionEntry;
begin
  if not Assigned(FMainMenu) then
    Exit;

  for I := 0 to FMainMenu.Items.Count - 1 do
  begin
    // Fast path: use pre-built cache entry when active (ENU->CHS)
    if FActive and Assigned(FMenuCaptionIndex) then
    begin
      CacheKey := LowerCase(SCN_CATEGORY_MAINMENU + '|' + SCN_MECHANISM_DIRECTACCESS
        + '|' + FMainMenu.Items[I].Name);
      CacheIdx := FMenuCaptionIndex.IndexOf(CacheKey);
      if CacheIdx >= 0 then
      begin
        Entry := TCnMenuCaptionEntry(FMenuCaptionIndex.Objects[CacheIdx]);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('TranslateStaticMainMenu %s (cache hit)', [FMainMenu.Items[I].Name]);
{$ENDIF}
        TranslateMenuItemFromCache(FMainMenu.Items[I], Entry);
        Continue;
      end;
    end;

    Captions := GetTranslationItemCaptions(SCN_CATEGORY_MAINMENU,
      SCN_MECHANISM_DIRECTACCESS, FMainMenu.Items[I].Name);
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
    Captions := GetTranslationItemCaptions(SCN_CATEGORY_MAINMENU,
      SCN_MECHANISM_DIRECTACCESS, 'ProjectBuildItem');
    if Length(Captions) > 0 then
      MenuItem.Caption := Captions[0, 1] + ' ' + ActiveProjectInfo.FileNameNoExt;
  end;

  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, 'ProjectCompileItem');
  if Assigned(MenuItem) then
  begin
    Captions := GetTranslationItemCaptions(SCN_CATEGORY_MAINMENU,
      SCN_MECHANISM_DIRECTACCESS, 'ProjectCompileItem');
    if Length(Captions) > 0 then
      MenuItem.Caption := Captions[0, 1] + ' ' + ActiveProjectInfo.FileNameNoExt;
  end;

  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, 'ProjectDeployItem');
  if Assigned(MenuItem) then
  begin
    Captions := GetTranslationItemCaptions(SCN_CATEGORY_MAINMENU,
      SCN_MECHANISM_DIRECTACCESS, 'ProjectDeployItem');
    if Length(Captions) > 0 then
      MenuItem.Caption := Captions[0, 1] + ' ' + ActiveProjectInfo.FileName;
  end;

  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, 'ProjectInformationItem');
  if Assigned(MenuItem) then
  begin
    Captions := GetTranslationItemCaptions(SCN_CATEGORY_MAINMENU,
      SCN_MECHANISM_DIRECTACCESS, 'ProjectInformationItem');
    if Length(Captions) > 0 then
      MenuItem.Caption := Captions[0, 1] + ' ' + ActiveProjectInfo.FileNameNoExt;
  end;

  MenuItem := FindMainMenuItemByNameDeep(FMainMenu, 'ProjectSyntaxItem');
  if Assigned(MenuItem) then
  begin
    Captions := GetTranslationItemCaptions(SCN_CATEGORY_MAINMENU,
      SCN_MECHANISM_DIRECTACCESS, 'ProjectSyntaxItem');
    if Length(Captions) > 0 then
      MenuItem.Caption := Captions[0, 1] + ' ' + ActiveProjectInfo.FileNameNoExt;
  end;
end;

// 事件挂钩动态子菜单
procedure TCnMenuFormTranslator.HookMainMenuDynamicItems;
var
  I, J: Integer;
  MenuPaths: TCn1DStringArray;
  MenuItem: TMenuItem;
  ItemHooked: Boolean;
  ItemInfo: TCnAttachedMenuItem;
begin
  UnHookMainMenuDynamicItems;

  MenuPaths := GetTranslationMenuPaths(SCN_CATEGORY_MAINMENU, SCN_MECHANISM_EVENTHANDLER);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnMenuTranslator.HookMainMenuItems %d', [Length(MenuPaths)]);
{$ENDIF}

  for I := 0 to Length(MenuPaths) - 1 do
  begin
    MenuItem := FindMainMenuItemByNameDeep(FMainMenu, MenuPaths[I]);
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
      ItemInfo.MenuPath := MenuPaths[I];
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

      TranslateMainMenuDynamicItem(SCN_CATEGORY_MAINMENU, SCN_MECHANISM_EVENTHANDLER,
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

// 弹出菜单处理过程，从 Screen 里找 Form 们的菜单并重写单个弹出菜单
procedure TCnMenuFormTranslator.TranslatePopupMenu(const AMenuCategory, AMechanism,
  AMenuPath: string; Container: TComponent);
var
  I, J: Integer;
  FS: TObjectList;
  PopupMenu: TPopupMenu;
  Names: TStringList;
  Captions: TCn2DStringArray;
  CacheKey: string;
  CacheIdx: Integer;
  Entry: TCnMenuCaptionEntry;
begin
  Names := nil;
  FS := nil;

  try
    Names := TStringList.Create;
    FS := TObjectList.Create(False);

    ExtractStrings(['.'], [' '], PChar(AMenuPath), Names);
    if Container = nil then
    begin
      if not FindScreenFormByName(Names[0], FS) then
        Exit;
    end
    else
      FS.Add(Container);

    if Names.Count = 3 then
    begin
      // Fast path: use pre-built cache entry when active (ENU->CHS)
      if FActive and Assigned(FMenuCaptionIndex) then
      begin
        CacheKey := LowerCase(AMenuCategory + '|' + AMechanism + '|' + AMenuPath);
        CacheIdx := FMenuCaptionIndex.IndexOf(CacheKey);
        if CacheIdx >= 0 then
        begin
          Entry := TCnMenuCaptionEntry(FMenuCaptionIndex.Objects[CacheIdx]);
          for I := 0 to FS.Count - 1 do
          begin
            PopupMenu := FindPopupMenuByName(TForm(FS[I]), Names[1], Names[2]);
            if not Assigned(PopupMenu) then
              Continue;
            for J := 0 to PopupMenu.Items.Count - 1 do
              TranslateMenuItemFromCache(PopupMenu.Items[J], Entry);
          end;
          Exit;
        end;
      end;

      Captions := GetTranslationItemCaptions(AMenuCategory, AMechanism, AMenuPath);
      if Length(Captions) = 0 then
        Exit;

      for I := 0 to FS.Count - 1 do
      begin
        PopupMenu := FindPopupMenuByName(TComponent(FS[I]), Names[1], Names[2]);
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

    Captions := GetTranslationItemCaptions(SCN_CATEGORY_POPUPMENUS,
      SCN_MECHANISM_EVENTHANDLER, MenuPath);
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
      Captions := GetTranslationItemCaptions(SCN_CATEGORY_POPUPMENUS,
        SCN_MECHANISM_EVENTHANDLER, MenuPath + '.actnRemoveCategory1');
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
      Captions := GetTranslationItemCaptions(SCN_CATEGORY_POPUPMENUS,
        SCN_MECHANISM_EVENTHANDLER, MenuPath + '.mnuRenameCategory');
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
      Captions := GetTranslationItemCaptions(SCN_CATEGORY_POPUPMENUS,
        SCN_MECHANISM_EVENTHANDLER, MenuPath + '.DeleteButton1');
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
      Captions := GetTranslationItemCaptions(SCN_CATEGORY_POPUPMENUS,
        SCN_MECHANISM_EVENTHANDLER, MenuPath + '.HideButton1');
      MenuItem.Caption := ReturnTranslateCaption(TempCaption, Captions);
    end;

    MenuItem := FindMenuItemByNameDeep(PopupMenu.Items, 'mnuShowButton');
    if Assigned(MenuItem) then
    begin
      TempCaption := 'Unhide &Button';
      Captions := GetTranslationItemCaptions(SCN_CATEGORY_POPUPMENUS,
        SCN_MECHANISM_EVENTHANDLER, MenuPath + '.mnuShowButton');
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
  MenuPaths: TCn1DStringArray;
  F: TCustomForm;
  S: string;
  FS: TObjectList;
begin
  if OnlyCurrent then
  begin
    F := Screen.ActiveCustomForm;
    if (F <> nil) and (F.Name <> '') and // 不找专家包的窗体
      (Pos('TCn', F.ClassName) <> 1) and (Pos('Cn', F.Name) <> 1) then
    begin
      S := F.Name + '.';
      MenuPaths := GetTranslationMenuPaths(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_DIRECTACCESS, S);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnMenuTranslator.TranslateStaticPopupMenus for %s Get %d', [F.Name, Length(MenuPaths)]);
{$ENDIF}

      for I := 0 to Length(MenuPaths) - 1 do
      begin
        if Pos(S, MenuPaths[I]) = 1 then
          TranslatePopupMenu(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_DIRECTACCESS,
           MenuPaths[I]);
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
              MenuPaths := GetTranslationMenuPaths(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_DIRECTACCESS, S);
{$IFDEF DEBUG}
              CnDebugger.LogFmt('TCnMenuTranslator.TranslateStaticPopupMenus for Dock %s Get %d', [F.Name, Length(MenuPaths)]);
{$ENDIF}

              for J := 0 to Length(MenuPaths) - 1 do
              begin
                if Pos(S, MenuPaths[J]) = 1 then
                  TranslatePopupMenu(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_DIRECTACCESS,
                    MenuPaths[J]);
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
    MenuPaths := GetTranslationMenuPaths(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_DIRECTACCESS);
    for I := 0 to Length(MenuPaths) - 1 do
      TranslatePopupMenu(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_DIRECTACCESS,
        MenuPaths[I]);
  end;
end;

// 翻译指定容器的其他静态弹出菜单，MenuPath 采用 Container 的名字，也支持 Application
procedure TCnMenuFormTranslator.TranslateStaticPopupMenusForContainer(Container: TComponent);
var
  I: Integer;
  S: string;
  MenuPaths: TCn1DStringArray;
begin
  S := '';
  if Container <> nil then
  begin
    if Container = Application then
      S := 'Application.'
    else if Container.Name <> '' then
      S := Container.Name + '.';
  end;

  if S <> '' then
  begin
    MenuPaths := GetTranslationMenuPaths(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_DIRECTACCESS, S);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnMenuTranslator.TranslateStaticPopupMenusForContainer %s Get %d', [S, Length(MenuPaths)]);
{$ENDIF}

    for I := 0 to Length(MenuPaths) - 1 do
    begin
      if Pos(S, MenuPaths[I]) = 1 then
        TranslatePopupMenu(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_DIRECTACCESS,
         MenuPaths[I], Container);
    end;
  end;
end;

procedure TCnMenuFormTranslator.TranslateStaticEditorTab;
var
  I, J: Integer;
  FS: TObjectList;
  Form: TForm;
  Control: TControl;
  TabSet: TTabSet;
  Captions: TCn2DStringArray;
begin
  FS := TObjectList.Create(False);
  try
    if not FindScreenFormByName('EditWindow_*', FS) then
      Exit;

    for I := 0 to FS.Count - 1 do
    begin
      Form := TForm(FS[I]);

      Control := FindControlByNameDeep(Form, 'ViewBar');
      if Assigned(Control) then
      begin
        Captions := GetTranslationItemCaptions(SCN_CATEGORY_SCREENFORMS,
          SCN_MECHANISM_DIRECTACCESS, 'EditWindow_*.ViewBar');
        if Length(Captions) > 0 then
        begin
          TabSet := TTabSet(Control);
          for J := 0 to TabSet.Tabs.Count - 1 do
            TabSet.Tabs[J] := ReturnTranslateCaption(TabSet.Tabs[J], Captions);
        end;
      end;
    end;
  finally
    FS.Free;
  end;
end;

procedure TCnMenuFormTranslator.TranslateStaticEditorSubViews;
var
  I: Integer;
  C: TWinControl;
begin
  C := CnOtaGetCurrentEditWindowSubViewContainer;
  if C = nil then
    Exit;

  for I := 0 to C.ControlCount - 1 do
  begin
    // TODO: 翻各种现存的、非动态创建的 SubView 的 Frame，记得判断是否已翻译，并去掉下面的 Exit

    if C.Controls[I].ClassNameIs(SCnDisassemblyViewClassName) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnMenuFormTranslator TranslateEditorSubViews: CPU PopupMenu');
{$ENDIF}
      // 翻 CPU 中的右键菜单，界面没啥东西因而不用翻
      TranslateStaticPopupMenusForContainer(C.Controls[I]);
      Exit;
    end
    else if C.Controls[I].ClassNameIs(SCnFileHistoryFrameClassName) and (C.Controls[I] is TFrame) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnMenuFormTranslator TranslateStaticEditorSubViews: History Frame');
{$ENDIF}
      CnLanguageManager.TranslateFrame(TFrame(C.Controls[I]));
    end;
  end;
end;

// 挂接当前活动编辑器窗口上的菜单控件
procedure TCnMenuFormTranslator.HookPopupMenuOnCurrentEditWindow;
const
  EDITWINDOW_PREFIX = 'EditWindow_';
var
  I: Integer;
  F: TForm;
  MenuPaths: TCn1DStringArray;
  Names: TStringList;
  PopupMenu: TPopupMenu;
  Hook: TCnMenuHookWrapper;
begin
  F := Screen.ActiveForm;
  if (F = nil) or (Pos(EDITWINDOW_PREFIX, F.Name) <> 1) then
    Exit;

  MenuPaths := GetTranslationMenuPaths(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_EVENTHANDLER);
  Names := TStringList.Create;
  try
    for I := 0 to Length(MenuPaths) - 1 do
    begin
      if Pos(EDITWINDOW_PREFIX, MenuPaths[I]) <> 1 then
        Continue;

      Names.Clear;
      ExtractStrings(['.'], [' '], PChar(MenuPaths[I]), Names);
      if Names.Count <> 3 then
        Continue;

      if StrEqualOrMatchStartWithStar(Names[0], F.Name) then
      begin
        PopupMenu := FindPopupMenuByName(F, Names[1], Names[2]);
        if not Assigned(PopupMenu) then
          Continue;

        if not IsPopupMenuHooked(PopupMenu) then
        begin
          Hook := TCnMenuHookWrapper.Create;
          Hook.Text := MenuPaths[I];
          Hook.Hook.HookMenu(PopupMenu);
          Hook.Hook.OnAfterPopup := AfterPopupMenuOnPopup;
          FAttachedPopupMenuHooks.Add(Hook);
{$IFDEF DEBUG}
          CnDebugger.LogMsg('TCnMenuFormTranslator.HookPopupMenuOnEditWindow. Hooked Popup ' + PopupMenu.Name);
{$ENDIF}
        end;
      end;
    end;
  finally
    Names.Free;
  end;
end;

{$IFDEF BDS}

procedure TCnMenuFormTranslator.HookPopupMenuOnSubView(SubView: TComponent);
var
  I: Integer;
  MenuPaths: TCn1DStringArray;
  Names: TStringList;
  PopupMenu: TPopupMenu;
  Hook: TCnMenuHookWrapper;
begin
  if (SubView = nil) or (SubView.Name = '') then
    Exit;

  MenuPaths := GetTranslationMenuPaths(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_EVENTHANDLER, SubView.Name);
  Names := TStringList.Create;
  try
    for I := 0 to Length(MenuPaths) - 1 do
    begin
      if Pos(SubView.Name, MenuPaths[I]) <> 1 then
        Continue;

      Names.Clear;
      ExtractStrings(['.'], [' '], PChar(MenuPaths[I]), Names);
      if Names.Count <> 3 then
        Continue;

      if StrEqualOrMatchStartWithStar(Names[0], SubView.Name) then
      begin
        PopupMenu := FindPopupMenuByName(SubView, Names[1], Names[2]);
        if not Assigned(PopupMenu) then
          Continue;

        if not IsPopupMenuHooked(PopupMenu) then
        begin
          Hook := TCnMenuHookWrapper.Create;
          Hook.Text := MenuPaths[I];
          Hook.Container := SubView;
          Hook.Hook.HookMenu(PopupMenu);
          Hook.Hook.OnAfterPopup := AfterPopupMenuOnPopup;
          FAttachedPopupMenuHooks.Add(Hook);
{$IFDEF DEBUG}
          CnDebugger.LogMsg('TCnMenuFormTranslator.HookPopupMenuOnSubView. Hooked Popup ' + PopupMenu.Name);
{$ENDIF}
        end;
      end;
    end;
  finally
    Names.Free;
  end;
end;

{$ENDIF}

// 挂钩弹出菜单集合
procedure TCnMenuFormTranslator.HookPopupMenus(OnlyCurrent: Boolean);
var
  I, J: Integer;
  S: string;
  MenuPaths: TCn1DStringArray;
  Names: TStringList;
  F: TCustomForm;
  FS: TObjectList;
  PopupMenu: TPopupMenu;
  Hook: TCnMenuHookWrapper;
begin
  if OnlyCurrent then
  begin
    F := Screen.ActiveCustomForm;
    if (F <> nil) and (F.Name <> '') and // 不找专家包的窗体
      (Pos('TCn', F.ClassName) <> 1) and (Pos('Cn', F.Name) <> 1) then
    begin
      S := F.Name + '.';
      MenuPaths := GetTranslationMenuPaths(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_EVENTHANDLER, S);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnMenuTranslator.HookPopupMenus for Current %s Get %d', [F.Name, Length(MenuPaths)]);
{$ENDIF}

      try
        Names := TStringList.Create;

        for I := 0 to Length(MenuPaths) - 1 do
        begin
          if Pos(S, MenuPaths[I]) = 1 then
          begin
            Names.Clear;
            ExtractStrings(['.'], [' '], PChar(MenuPaths[I]), Names);
            if Names.Count <> 3 then
              Continue;

            PopupMenu := FindPopupMenuByName(F, Names[1], Names[2]);
            if not Assigned(PopupMenu) then
              Continue;

            if not IsPopupMenuHooked(PopupMenu) then
            begin
              Hook := TCnMenuHookWrapper.Create;
              Hook.Text := MenuPaths[I];
              Hook.Hook.HookMenu(PopupMenu);
              Hook.Hook.OnAfterPopup := AfterPopupMenuOnPopup;
              FAttachedPopupMenuHooks.Add(Hook);
{$IFDEF DEBUG}
              CnDebugger.LogMsg('TCnMenuFormTranslator.HookPopups for Current Form. Hooked Popup ' + PopupMenu.Name);
{$ENDIF}
            end;
          end;
        end;
      finally
        Names.Free;
      end;
    end;
  end
  else
  begin
    UnHookPopupMenus;
    MenuPaths := GetTranslationMenuPaths(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_EVENTHANDLER);
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
        ExtractStrings(['.'], [' '], PChar(MenuPaths[I]), Names);
        if Names.Count <> 3 then
          Continue;

        FS.Clear;
        if not FindScreenFormByName(Names[0], FS) then
          Continue;

        for J := 0 to FS.Count - 1 do
        begin
          PopupMenu := FindPopupMenuByName(TComponent(FS[J]), Names[1], Names[2]);
          if not Assigned(PopupMenu) then
            Continue;

          if not IsPopupMenuHooked(PopupMenu) then
          begin
            Hook := TCnMenuHookWrapper.Create;
            Hook.Text := MenuPaths[I];
            Hook.Hook.HookMenu(PopupMenu);
            Hook.Hook.OnAfterPopup := AfterPopupMenuOnPopup;
            FAttachedPopupMenuHooks.Add(Hook);
{$IFDEF DEBUG}
            CnDebugger.LogMsg('TCnMenuFormTranslator.HookPopups. Hooked Popup ' + PopupMenu.Name);
{$ENDIF}
          end;
        end;
      end;
    finally
      FS.Free;
      Names.Free;
    end
  end;
end;

// 动态弹出菜单挂钩事件
procedure TCnMenuFormTranslator.AfterPopupMenuOnPopup(Sender: TObject; Menu: TPopupMenu);
var
  I: Integer;
  Hook: TCnMenuHookWrapper;
begin
  for I := 0 to FAttachedPopupMenuHooks.Count - 1 do
  begin
    Hook := TCnMenuHookWrapper(FAttachedPopupMenuHooks[I]);
    if Hook.Hook.IsHooked(Menu) then
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
        TranslatePopupMenu(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_EVENTHANDLER,
          Hook.Text, Hook.Container);
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
  BuildCaptionCache;
end;

// 将 FTranslationMap 中所有 ItemCaption 预处理为 HashMap 缓存
procedure TCnMenuFormTranslator.BuildCaptionCache;
var
  CatIdx, MechIdx, PathIdx, CapIdx: Integer;
  CatNames: array[0..2] of string;
  MechNames: array[0..2] of string;
  CatValue, MechValue, PathValue, CapValue: TCnJSONValue;
  CatObj, PathObj: TCnJSONObject;
  MechArray, CapArray, ItemArray: TCnJSONArray;
  CacheKey: string;
  Entry: TCnMenuCaptionEntry;
  ENU, CHS: string;
  RuleIdx: Integer;
  OldParts, NewParts: TStringList;
  Rule: TCnMenuCaptionPrefixSuffix;
  SepPos: Integer;
begin
  // 清理旧缓存
  if FMenuCaptionIndex <> nil then
  begin
    for CatIdx := 0 to FMenuCaptionIndex.Count - 1 do
      FMenuCaptionIndex.Objects[CatIdx].Free;
    FMenuCaptionIndex.Clear;
  end
  else
  begin
    FMenuCaptionIndex := TStringList.Create;
    FMenuCaptionIndex.Sorted := True;
    FMenuCaptionIndex.Duplicates := dupIgnore;
  end;

  if not Assigned(FTranslationMap) then
    Exit;

  CatNames[0] := SCN_CATEGORY_MAINMENU;
  CatNames[1] := SCN_CATEGORY_POPUPMENUS;
  CatNames[2] := SCN_CATEGORY_SCREENFORMS;
  MechNames[0] := SCN_MECHANISM_DIRECTACCESS;
  MechNames[1] := SCN_MECHANISM_EVENTHANDLER;
  MechNames[2] := SCN_MECHANISM_WINDOWPROC;

  OldParts := TStringList.Create;
  NewParts := TStringList.Create;
  try
    for CatIdx := 0 to 2 do
    begin
      CatValue := FTranslationMap[CatNames[CatIdx]];
      if not (CatValue is TCnJSONObject) then
        Continue;
      CatObj := TCnJSONObject(CatValue);

      for MechIdx := 0 to 2 do
      begin
        MechValue := CatObj[MechNames[MechIdx]];
        if not (MechValue is TCnJSONArray) then
          Continue;
        MechArray := TCnJSONArray(MechValue);

        for PathIdx := 0 to MechArray.Count - 1 do
        begin
          if not (MechArray[PathIdx] is TCnJSONObject) then
            Continue;
          PathObj := TCnJSONObject(MechArray[PathIdx]);

          PathValue := PathObj['MenuPath'];
          if not Assigned(PathValue) then
            Continue;

          // 构造缓存 key：Category|Mechanism|MenuPath（全小写）
          CacheKey := LowerCase(CatNames[CatIdx] + '|' + MechNames[MechIdx] + '|'
            + PathValue.AsString);

          Entry := TCnMenuCaptionEntry.Create;

          CapValue := PathObj['ItemCaption'];
          if CapValue is TCnJSONArray then
          begin
            CapArray := TCnJSONArray(CapValue);
            RuleIdx := 0;
            for CapIdx := 0 to CapArray.Count - 1 do
            begin
              if not (CapArray[CapIdx] is TCnJSONArray) then
                Continue;
              ItemArray := TCnJSONArray(CapArray[CapIdx]);
              if ItemArray.Count < 2 then
                Continue;

              ENU := ItemArray[INDEX_ENU].AsString;
              CHS := ItemArray[INDEX_CHS].AsString;

              SepPos := Pos('||', ENU);
              if SepPos > 0 then
              begin
                // 预解析 || 规则
                OldParts.Clear;
                NewParts.Clear;
                CnSplitString('||', ENU, OldParts);
                CnSplitString('||', CHS, NewParts);
                if (OldParts.Count >= 2) and (NewParts.Count >= 2) then
                begin
                  Rule.OldPrefix := OldParts[0];
                  Rule.OldSuffix := OldParts[1];
                  Rule.NewPrefix := NewParts[0];
                  Rule.NewSuffix := NewParts[1];
                  SetLength(Entry.PrefixSuffixRules, RuleIdx + 1);
                  Entry.PrefixSuffixRules[RuleIdx] := Rule;
                  Inc(RuleIdx);
                end;
              end
              else
              begin
                // 精确匹配：key 存小写，查找时也转小写
                Entry.ExactMap.Add(LowerCase(ENU), CHS);
                Entry.OriginalENUMap.Add(LowerCase(ENU), ENU); // 保存原始大小写，用于切回英文时还原
              end;
            end;
          end;

          FMenuCaptionIndex.AddObject(CacheKey, Entry);
        end;
      end;
    end;
  finally
    OldParts.Free;
    NewParts.Free;
  end;
end;

// ???????????????????????
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
  JsonValue := FTranslationMap[SCN_CATEGORY_MAINMENU];
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
  FUITranslator := Self;

  FStorageRef := AStorage;
  if FStorageRef <> nil then
    LoadAdditionalLangFile(GetAdditionalLangID);

  FTransQueue := TComponentList.Create(False);
  FTranedCompList := TComponentList.Create(False);

  // 初始化参数对象
  FAttachedPopupMenuHooks := TObjectList.Create(True);
  FAttachedMenuItems := TObjectList.Create(True);
{$IFDEF UNICODE}
  // 准备好 Hook 工具对象，但此时不实际进行 Hook
  FInspListBoxControlHook := TCnControlHook.Create(nil);
  FInspListBoxControlHook.BeforeMessage := InspListBoxControlBeforeMessage;
  FInspListBoxControlHook.AfterMessage := InspListBoxControlAfterMessage;
  FInspListBoxControlHook.OnUnhooked := InspListBoxUnHook;

  FDrawingInspListBoxes := TObjectList.Create(False); // 只存引用
  FPendingRemoveInspListBoxes := TObjectList.Create(False);

  // 注意此处同样不用调用 InstallTextDrawHook，要延迟 Hook

{$IFDEF IDE_CATALOG_VIRTUALTREE}
  FVirtualTreeHooks := TObjectList.Create(True);
{$ENDIF}
{$ENDIF}

{$IFDEF IDE_OPTION_DYNCREATE}
  FPropertySheetControlHook := TCnControlHook.Create(nil);
  FPropertySheetControlHook.AfterMessage := PropertySheetAfterMessage;
{$ENDIF}

  // 注意同样不用安装 LoadResString Hook，要延迟

  // 加载翻译内容
  TranslationMapPath := WizOptions.GetDataFileName(csMenuTransFile);
  LoadTranslationMenus(TranslationMapPath);

  // 设置事件通知，注意通知非独占但事件独占了
  CnLanguageManager.OnTranslateObject := MultiLangTranslateObject;
  CnLanguageManager.OnTranslateObjectProperty := MultiLangTranslateObjectProperty;
  CnLanguageManager.AddChangeNotifier(LangaugeChanged);

  CnWizNotifierServices.AddActiveProjectChangedNotifier(ActiveProjectChanged);
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
  CnWizNotifierServices.AddDesignerMenuBuildNotifier(DesignerMenuBuild);

{$IFDEF COMPILER7_UP}
   CnWizNotifierServices.AddApplicationIdleNotifier(OnApplicationIdle);
{$ENDIF}
{$IFDEF BDS}
  CnWizNotifierServices.AddSourceEditorNotifier(SourceEditorNotify);
{$ENDIF}
  EditControlWrapper.AddEditorChangeNotifier(EditorChange);

  CnWizCmdNotifier.AddCmdNotifier(CommandNotify);
end;

destructor TCnMenuFormTranslator.Destroy;
begin
  CnWizCmdNotifier.RemoveCmdNotifier(CommandNotify);

  EditControlWrapper.RemoveEditorChangeNotifier(EditorChange);
{$IFDEF BDS}
  CnWizNotifierServices.RemoveSourceEditorNotifier(SourceEditorNotify);
{$ENDIF}

{$IFDEF COMPILER7_UP}
   CnWizNotifierServices.RemoveApplicationIdleNotifier(OnApplicationIdle);
{$ENDIF}

  CnWizNotifierServices.RemoveDesignerMenuBuildNotifier(DesignerMenuBuild);
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  CnWizNotifierServices.RemoveActiveProjectChangedNotifier(ActiveProjectChanged);

  CnLanguageManager.RemoveChangeNotifier(LangaugeChanged);

  FOld2Array.Free;
  FNew2Array.Free;
  FreeAndNil(FTranslationMap);
  // 释放缓存索引（每个 Object 是 TCnMenuCaptionEntry，需要逐个释放）
  if FMenuCaptionIndex <> nil then
  begin
    while FMenuCaptionIndex.Count > 0 do
    begin
      FMenuCaptionIndex.Objects[0].Free;
      FMenuCaptionIndex.Delete(0);
    end;
    FreeAndNil(FMenuCaptionIndex);
  end;
  FreeAndNil(FAttachedPopupMenuHooks);
  FreeAndNil(FAttachedMenuItems);
{$IFDEF IDE_OPTION_DYNCREATE}
  FreeAndNil(FPropertySheetControlHook);
{$ENDIF}

{$IFDEF ENABLE_RESSTRING_HOOK}
  // 卸载 LoadResString Hook
  FreeAndNil(FLoadResStringHook);
{$ENDIF}

{$IFDEF UNICODE}
{$IFDEF IDE_CATALOG_VIRTUALTREE}
  FVirtualTreeHooks.Free;
{$ENDIF}
  UninstallTextDrawHook;
  ClearTextDrawMessageHooks;
  FreeAndNil(FInspListBoxControlHook);

  FreeAndNil(FDrawingInspListBoxes);
  FreeAndNil(FPendingRemoveInspListBoxes);
{$ENDIF}

  FUITranslator := nil;
  FOldFont.Free;

  FreeAndNil(FTranedCompList);
  FreeAndNil(FTransQueue);
  inherited;
end;

function TCnMenuFormTranslator.GetAdditionalLangMainFileName: string;
begin
  Result := '<None.txt>';
{$IFDEF BDS}
  {$IFDEF UNICODE}
  Result := 'RADStudio.txt';     // 2009 到 13
  {$ELSE}
  Result := 'BDS.txt';           // 2005 到 2007
  {$ENDIF}
{$ELSE}
  Result := 'Delphi.txt';        // D 5 6 7 和 CB 5 6
{$ENDIF}
end;

function TCnMenuFormTranslator.GetAdditionalLangExtraFileName: string;
begin
  Result := CompilerShortName + '.txt';
end;

procedure TCnMenuFormTranslator.LoadAdditionalLangFile(ALangID: Cardinal);
var
  I: Integer;
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
    // 先加载全部字符串内容文件，不区分版本
    S := MakePath(MakePath(FStorageRef.LanguagePath) + D) + 'Resource.txt';
    if FileExists(S) then
    begin
      FStorageRef.AddExtraItemsFromFile(S);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('CnMenuFormTranslator Load Resoure String File to %d',
        [TCnHackHashLangStorage(FStorageRef).HashMap.Size]);
{$ENDIF}
    end;

    // 大版本语言界面文件
    S := MakePath(MakePath(FStorageRef.LanguagePath) + D) + GetAdditionalLangMainFileName;
    if FileExists(S) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('CnMenuFormTranslator Before LoadAdditionalLangFile. %d',
        [TCnHackHashLangStorage(FStorageRef).HashMap.Size]);
{$ENDIF}

      FStorageRef.AddExtraItemsFromFile(S);
      FAddtionalLanguageFileLoad := True;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('CnMenuFormTranslator.LoadAdditionalLangFile %d from %s',
        [TCnHackHashLangStorage(FStorageRef).HashMap.Size, S]);
{$ENDIF}
    end
    else
      Exit; // 没大版本语言文件则不加载小版本补充文件

    // 不同版本的 Delphi，可在此针对当前语言的条目进行进一步处理：
    if Compiler in [cnDelphi2005, cnDelphi2006] then
    begin
      // 将语言条目中的 TDelphiProjectOptionsDialog 替换为低版本中的 TProjectOptionsDialog
      ChangeLangPrefix(TCnHackHashLangStorage(FStorageRef).HashMap,
        'TDelphiProjectOptionsDialog.', 'TProjectOptionsDialog.');
    end;

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

  TranslateStaticEditorTab;
  TranslateStaticEditorSubViews;

{$IFDEF COMPILER7_UP}
  CheckActionMainMenuBarPersistentHotKeys;
{$ENDIF}

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

      // 第一次翻译前，记录主窗体旧字体备用
      if WizOptions.UseChineseFont and (FOldFont = nil) then
      begin
        FOldFont := TFont.Create;
        if GetIDEMainForm <> nil then
          FOldFont := GetIDEMainForm.Font;
      end;
      TranslateAllExistingForms;

{$IFDEF ENABLE_RESSTRING_HOOK}
      FLoadResStringHook := TCnMethodHook.Create(GetBplMethodAddress(@System.LoadResString),
        @MyHookedLoadResString);
{$ENDIF}

{$IFDEF UNICODE}
      InstallTextDrawHook;
{$ENDIF}

      // 延迟加载
      CnWizNotifierServices.ExecuteOnApplicationIdle(DelayActivate);
    end
    else
    begin
      if not Application.Terminated then
      begin
        // 非 IDE 关闭情况下，恢复英文菜单等
        TranslateStaticMainMenu;
        TranslateMainMenuProjectItems;
        TranslateStaticPopupMenus;
        TranslatePopupMenuPaletteItems;
        UpdateWholeMenus;

        // 根据需要将当前已存在的窗体翻译回英语
        LoadAdditionalLangFile(GetAdditionalLangID);
        TranslateAllExistingForms;

        TranslateStaticEditorTab;
        TranslateStaticEditorSubViews;
      end;

      // 卸载事件挂钩
      UnHookPopupMenus;
      UnHookMainMenuDynamicItems;
{$IFDEF UNICODE}
      ClearTextDrawMessageHooks;
      UninstallTextDrawHook;
{$ENDIF}

{$IFDEF ENABLE_RESSTRING_HOOK}
      FreeAndNil(FLoadResStringHook);
{$ENDIF}
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
    if TCnMenuHookWrapper(FAttachedPopupMenuHooks[I]).Hook.IsHooked(Menu) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TCnMenuFormTranslator.DebugCommand(Cmds, Results: TStrings);
var
  I: Integer;
  Hook: TCnMenuHookWrapper;
begin
  Results.Add(Format('CnMenuTranslator PopupMenu Hooks %d', [FAttachedPopupMenuHooks.Count]));
  for I := 0 to FAttachedPopupMenuHooks.Count - 1 do
  begin
    Hook := TCnMenuHookWrapper(FAttachedPopupMenuHooks[I]);
    if Hook.Hook.HookedMenuCount = 1 then
      Results.Add(Format('  %s: %s|%s', [Hook.Text, Hook.Hook.HookedMenu[0].Name,
        Hook.Hook.HookedMenu[0].ClassName]))
    else
      Results.Add(Format('  Error Get %d Menus', [Hook.Hook.HookedMenuCount]));
  end;
end;

procedure TCnMenuFormTranslator.TranslateQueue(Sender: TObject);
var
  F: TCustomForm;
begin
  while FTransQueue.Count > 0 do
  begin
    F := TCustomForm(FTransQueue[0]);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Delayed To TranslateQueue ' + F.ClassName);
{$ENDIF}

    CnLanguageManager.TranslateForm(F, True);
    if CanTranslateToChinese and WizOptions.UseChineseFont and (fsModal in F.FormState) then
      F.Font := WizOptions.ChineseFont;

    if F.Visible then
      F.Update;

    FTransQueue.Delete(0);
    FTranedCompList.Add(F);
  end;
end;

procedure TCnMenuFormTranslator.ActiveFormChanged(Sender: TObject);
var
  F: TCustomForm;
begin
  TranslateStaticPopupMenus(True);
  HookPopupMenus(True);
  HookPopupMenuOnCurrentEditWindow;

{$IFDEF UNICODE}
  ClearTextDrawMessageHooks;
{$ENDIF}

{$IFDEF BDS}
  if FActive and (Screen.ActiveCustomForm <> nil) and (WizOptions.CurrentLangID = csChineseID) and
    (Screen.ActiveCustomForm.ClassNameIs('TDelphiProjectOptionsDialog')
    or Screen.ActiveCustomForm.ClassNameIs('TCppProjectOptionsDialog')
    or Screen.ActiveCustomForm.ClassNameIs('TCppProjOptsDlg')
    or Screen.ActiveCustomForm.ClassNameIs('TProjectOptionsDialog')
    or Screen.ActiveCustomForm.ClassNameIs(SCnEnvOptionDlgClassName)) then
  begin
{$IFDEF UNICODE}
    HookMessagesInControl(Screen.ActiveCustomForm);
{$ENDIF}
    // 手动翻译工程选项、环境选项等部分对话框左侧的树目录节点
    if CanTranslateToChinese then
      TranslateTreeViewCatalog(Screen.ActiveCustomForm);
  end;
{$ENDIF}

  if CanTranslateToChinese and (Screen.ActiveCustomForm <> nil) then
  begin
    F := Screen.ActiveCustomForm;
    if {not F.ClassNameIs('TAppBuilder') and} (Pos('TCn', F.ClassName) <> 1) then
    begin
      if not (csDesigning in F.ComponentState) and (FTranedCompList.IndexOf(F) < 0) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('CnMultiLang ActiveFormChanged. To Translate ' + F.ClassName);
{$ENDIF}
        CnLanguageManager.TranslateForm(F, True);

        // 只改 Modal 窗体的字体
        if WizOptions.UseChineseFont and (fsModal in F.FormState) then
          F.Font := WizOptions.ChineseFont;
        if F.Visible then
          F.Update;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('CnMultiLang ActiveFormChanged. Translate OK ' + F.ClassName);
{$ENDIF}

        if (Compiler >= cnDelphi2009) and F.ClassNameIs(SCnEnvOptionDlgClassName) then
        begin
          // 特殊窗体要等其延迟初始化完毕后再翻译一次
          FTransQueue.Add(F);
          CnWizNotifierServices.ExecuteOnApplicationIdle(TranslateQueue);
        end
        else
          FTranedCompList.Add(F);
      end
      else
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('CnMultiLang ActiveFormChanged. ' + F.ClassName + ' Already Translated. Do Nothing.');
{$ENDIF}
      end;
    end;
  end;

{$IFDEF COMPILER7_UP}
  if CanTranslateToChinese then
    CheckActionMainMenuBarPersistentHotKeys;
{$ENDIF}
end;

procedure TCnMenuFormTranslator.EditorChange(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);
begin
  if ctTopEditorChanged in ChangeType then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnMenuFormTranslator TopEditor Changed.');
{$ENDIF}
    CnWizNotifierServices.ExecuteOnApplicationIdle(CheckSubViewPopupMenus);
    CnWizNotifierServices.ExecuteOnApplicationIdle(CheckSubViewTranslation);
  end;
end;

procedure TCnMenuFormTranslator.CheckSubViewPopupMenus(Sender: TObject);
var
  C: TControl;
begin
  // 检查当前是否切到了 CPU 或其他能翻的 SubView
  C := CnOtaGetCurrentEditWindowSubViewControl;
  if (C <> nil) and
    (C.ClassNameIs(SCnDisassemblyViewClassName) or C.ClassNameIs(SCnModuleViewClassName)
    or C.ClassNameIs(SCnDiagramViewFrameClassName)) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnMenuFormTranslator CheckSubViewPopupMenus. Switch to ' + C.Name);
{$ENDIF}
    // 静态翻该 SubView 中的右键菜单
    TranslateStaticPopupMenusForContainer(C);

{$IFDEF BDS}
    // 挂接该 SubView 中的右键菜单准备动态翻，目前只有 BDS 下有
    HookPopupMenuOnSubView(C);
{$ELSE}
    // 特殊情况，D7 的图表菜单的 Owner 是 Application。
    // 本该如此处理，但后来发现该 TPopupActionBar 在右键点击时才创建，于是没用了，代码先留着
    if C.ClassNameIs(SCnDiagramViewFrameClassName) then
      TranslateStaticPopupMenusForContainer(Application);
{$ENDIF}
  end;
end;

procedure TCnMenuFormTranslator.CheckSubViewTranslation(Sender: TObject);
var
  I: Integer;
  C: TControl;
  Captions: TCn2DStringArray;
  TabSet: TTabSet;
begin
  // 检查当前是否切到了 CPU 或其他能翻的 SubView
  C := CnOtaGetCurrentEditWindowSubViewControl;
  if (C <> nil) and (C is TFrame) and C.ClassNameIs(SCnFileHistoryFrameClassName) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnMenuFormTranslator CheckSubViewTranslation. Switch to ' + C.Name);
{$ENDIF}
    // 翻该 SubView
    CnLanguageManager.TranslateFrame(TFrame(C));

    // 针对历史 Frame 翻译其 Tab
    C := FindControlByNameDeep(C, 'TabSet1');
    if Assigned(C) then
    begin
      Captions := GetTranslationItemCaptions(SCN_CATEGORY_SCREENFORMS,
        SCN_MECHANISM_DIRECTACCESS, 'EditWindow_*.FileHistoryFrame.TabSet1');
      if Length(Captions) > 0 then
      begin
        TabSet := TTabSet(C);
        for I := 0 to TabSet.Tabs.Count - 1 do
          TabSet.Tabs[I] := ReturnTranslateCaption(TabSet.Tabs[I], Captions);
      end;
    end;
  end;
end;

{$IFDEF BDS}

function TCnMenuFormTranslator.TranslateTreeViewCatalog(AComponent: TComponent): Boolean;
var
  I: Integer;
  AChild: TComponent;
  ATreeView: TTreeView;
  S: string;
{$IFDEF IDE_CATALOG_VIRTUALTREE}
  Hook: TCnVSTOnGetTextHook;
{$ENDIF}
begin
  Result := False;
  if AComponent = nil then
    Exit;

  if (AComponent is TTreeView) and (AComponent.Name = 'trvwPageNodes') then
  begin
    ATreeView := TTreeView(AComponent);
    if ATreeView.Items.Count > 0 then
    begin
      for I := 0 to ATreeView.Items.Count - 1 do
      begin
        S := CnLanguageManager.Translate(ATreeView.Items[I].Text);
        if S <> '' then
          ATreeView.Items[I].Text := S;
      end;
    end;
    Result := True;
    Exit;
  end;

{$IFDEF IDE_CATALOG_VIRTUALTREE}

  ClearUnusedVirtualTreeHooks;
  if AComponent.ClassNameIs('TVirtualStringTree') and (AComponent.Name = 'VirtualStringTree1') then
  begin
    Hook := TCnVSTOnGetTextHook.Create(AComponent);
    try
      Hook.OnTranslateText := VSTTranslateText;
      if not Hook.Install then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TranslateTreeViewCatalog Hook.Install Failed, Exit.');
{$ENDIF}
        Hook.Free;
        Exit;
      end;

      Hook.RefreshTree;
      FVirtualTreeHooks.Add(Hook);
    except
      Hook.Free;
      raise;
    end;

    Result := True;
    Exit;
  end;

{$ENDIF}

  for I := 0 to AComponent.ComponentCount - 1 do
  begin
    AChild := AComponent.Components[I];
    if TranslateTreeViewCatalog(AChild) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

{$ENDIF}

// 递归遍历菜单项，将 Caption 去掉 & 和 ... 后逐行加入列表
procedure DumpPopupMenuItems(AItem: TMenuItem; AList: TStrings);
var
  I: Integer;
  Cap: string;
begin
  for I := 0 to AItem.Count - 1 do
  begin
    Cap := AItem.Items[I].Caption;
    if Cap = '-' then
      Continue;

    Cap := StringReplace(Cap, '&', '', [rfReplaceAll]);
    Cap := StringReplace(Cap, '...', '', [rfReplaceAll]);
    Cap := Trim(Cap);

    if Cap <> '' then
      AList.Add(Cap);
    if AItem.Items[I].Count > 0 then
      DumpPopupMenuItems(AItem.Items[I], AList);
  end;
end;

// 遍历窗体的所有 Components，找到每个 PopupMenu 并输出标题行和菜单项
procedure DumpFormPopupMenus(AForm: TCustomForm; AList: TStrings);
var
  I: Integer;
  Comp: TComponent;
  PM: TPopupMenu;
  OwnerName, PopupCtrlName: string;
begin
  for I := 0 to AForm.ComponentCount - 1 do
  begin
    Comp := AForm.Components[I];
    if Comp is TPopupMenu then
    begin
      PM := TPopupMenu(Comp);
      if (PM.Owner <> nil) and (PM.Owner is TComponent) then
        OwnerName := TComponent(PM.Owner).Name
      else
        OwnerName := '';
      if (PM.PopupComponent <> nil) and (PM.PopupComponent is TComponent) then
        PopupCtrlName := TComponent(PM.PopupComponent).Name
      else
        PopupCtrlName := '';

      // 标题行：Owner名.弹出控件名.菜单名
      AList.Add(OwnerName + '.' + PopupCtrlName + '.' + PM.Name);
      // 递归输出所有菜单项
      DumpPopupMenuItems(PM.Items, AList);
    end;
  end;
end;

procedure TCnMenuFormTranslator.CommandNotify(const Command: Cardinal;
  const SourceID, DestID: PAnsiChar; const IDESets: TCnCompilers;
  const Params: TStrings);
var
  SL: TStringList;
  Key, Value, Prefix: string;
  C: TComponent;
begin
  if Command = CN_WIZ_CMD_INSP_DUMP_HOOK then
  begin
{$IFDEF UNICODE}
{$IFDEF DEBUG}
    if FHookedStringHashMap <> nil then
    begin
      SL := TStringList.Create;
      try
        FHookedStringHashMap.StartEnum;
        while FHookedStringHashMap.GetNext(Key, Value) do
          SL.Add(Key + '=' + Key);

      CnDebugger.LogFmt('CnIDETranslator Get Command CN_WIZ_CMD_INSP_DUMP_HOOK. Dump %d',
        [FHookedStringHashMap.Size]);

        SL.Sort;
        Clipboard.AsText := SL.Text;
      finally
        SL.Free;
      end;
    end;
{$ENDIF}
{$ENDIF}
  end
  else if Command = CN_WIZ_CMD_INSP_RESTART_HOOK then
  begin
{$IFDEF UNICODE}
{$IFDEF DEBUG}
    if FHookedStringHashMap <> nil then
    begin
      FHookedStringHashMap.Clear;
      CnDebugger.LogFmt('CnIDETranslator Get Command CN_WIZ_CMD_INSP_RESTART_HOOK. Clear to %d',
        [FHookedStringHashMap.Size]);
    end;
{$ENDIF}
{$ENDIF}
  end
  else if Command = CN_WIZ_CMD_DUMP_LANGSTORAGE then
  begin
{$IFDEF UNICODE}
    if FStorageRef <> nil then
    begin
      SL := TStringList.Create;
      if Params.Count > 0 then
        Prefix := Trim(Params[0])
      else
        Prefix := '';

      try
        TCnHackHashLangStorage(FStorageRef).HashMap.StartEnum;
        while TCnHackHashLangStorage(FStorageRef).HashMap.GetNext(Key, Value) do
        begin
          if (Prefix = '') or (Pos(Prefix, Key) = 1)  then
            SL.Add(Key + '=' + Value);
        end;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('CnIDETranslator Get Command CN_WIZ_CMD_DUMP_LANGSTORAGE. Dump %d',
          [SL.Count]);
{$ENDIF}
        SL.Sort;
        if SL.Count > 0 then
          Clipboard.AsText := SL.Text;
      finally
        SL.Free;
      end;
    end;
{$ENDIF}
  end
  else if Command = CN_WIZ_CMD_TRAN_TREEVIEW then
  begin
{$IFDEF UNICODE}
{$IFDEF DEBUG}
    CnDebugger.LogFmt('CnIDETranslator Get Command CN_WIZ_CMD_TRAN_TREEVIEW in %s',
      [Screen.ActiveCustomForm.ClassName]);
{$ENDIF}
    TranslateTreeViewCatalog(Screen.ActiveCustomForm);
{$ENDIF}
  end
  else if Command = CN_WIZ_CMD_DUMP_POPUPMENU then
  begin
    // 针对当前活动窗体，递归寻找所有 PopupMenu，输出其 Owner.PopupComponent.Name 及菜单项 Caption
    if Screen.ActiveCustomForm <> nil then
    begin
      SL := TStringList.Create;
      try
        DumpFormPopupMenus(Screen.ActiveCustomForm, SL);

{$IFDEF DEBUG}
        CnDebugger.LogFmt('CnIDETranslator Get Command CN_WIZ_CMD_DUMP_POPUPMENU. Dump %d Lines',
          [SL.Count]);
{$ENDIF}
        if SL.Count > 0 then
          Clipboard.AsText := SL.Text;
      finally
        SL.Free;
      end;
    end;
  end
  else if Command = CN_WIZ_CMD_TRANS_CURSHEET then
  begin
    if (Screen.ActiveCustomForm <> nil) and (Screen.ActiveCustomForm.ClassNameIs(SCnEnvOptionDlgClassName)) then
    begin
      C := Screen.ActiveCustomForm.FindComponent(SCnEnvOptionDlgPropSheetControlName);
{$IFDEF DEBUG}
      if C <> nil then
        CnDebugger.LogFmt('CnIDETranslator Get Command CN_WIZ_CMD_TRANS_CURSHEET. Get %s', [C.ClassName])
      else
        CnDebugger.LogMsg('CnIDETranslator Get Command CN_WIZ_CMD_TRANS_CURSHEET. Not Found.');
{$ENDIF}
      if (C <> nil) and (C is TPageControl) then
      begin
        C := TPageControl(C).ActivePage;
        if C <> nil then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogFmt('CnIDETranslator Translate Current Sheet %s', [C.ClassName]);
{$ENDIF}
          CnLanguageManager.TranslateComponent(C);
        end;
      end;
    end;
  end;
end;

{$IFDEF UNICODE}

procedure TCnMenuFormTranslator.InstallTextDrawHook;
var
  M: TCanvasTextRectMethod;
  C: TCanvas;
begin
  if FTextDrawHook = nil then
  begin
    C := TCanvas.Create;
    M := C.TextRect;
    FOldCanvasTextRect := GetBplMethodAddress(TMethod(M).Code);
    C.Free;
    FTextDrawHook := TCnMethodHook.Create(@FOldCanvasTextRect, @MyHookedCanvasTextRect);
  end;
end;

procedure TCnMenuFormTranslator.UninstallTextDrawHook;
begin
  FreeAndNil(FTextDrawHook);
  FOldCanvasTextRect := nil;
end;

procedure TCnMenuFormTranslator.ClearTextDrawMessageHooks;
var
  I: Integer;
begin
  if FInspListBoxControlHook = nil then
    Exit;

  for I := FInspListBoxControlHook.Items.Count - 1 downto 0 do
  begin
    if FInspListBoxControlHook.Items[I].Control <> nil then
      FInspListBoxControlHook.UnHook(FInspListBoxControlHook.Items[I].Control)
    else
      FInspListBoxControlHook.Items[I].Free;
      // CollectionItem 的 Destroy 会从 Collection 里 Remove 自己
  end;

  FDrawingInspListBoxes.Clear;
  FPendingRemoveInspListBoxes.Clear;
end;

procedure TCnMenuFormTranslator.HookMessagesInControl(ARootControl: TControl);
var
  I: Integer;
  C: TControl;
  W: TWinControl;
  OwnerName: string;
begin
  if (ARootControl = nil) or (FInspListBoxControlHook = nil)
    {$IFDEF IDE_OPTION_DYNCREATE} or (FpropertySheetControlHook = nil) {$ENDIF}
    then
    Exit;

  if ARootControl.ClassNameIs(SCN_INSP_LIST_BOX) then
  begin
    if not FInspListBoxControlHook.IsHooked(ARootControl) then
    begin
      FInspListBoxControlHook.Hook(ARootControl);
{$IFDEF DEBUG}
      if ARootControl.Owner <> nil then
        OwnerName := ARootControl.Owner.Name
      else
        OwnerName := '<nil>';
      CnDebugger.LogFmt('CnIDETranslator Hook InspListBox: %s.%s',
        [OwnerName, ARootControl.Name]);
{$ENDIF}
    end;
    Exit;
  end;

{$IFDEF IDE_OPTION_DYNCREATE}

  if ARootControl.Name = SCnEnvOptionDlgPropSheetControlName then
  begin
    if not FpropertySheetControlHook.IsHooked(ARootControl) then
    begin
      FpropertySheetControlHook.Hook(ARootControl);

{$IFDEF DEBUG}
      if ARootControl.Owner <> nil then
        OwnerName := ARootControl.Owner.Name
      else
        OwnerName := '<nil>';
      CnDebugger.LogFmt('CnIDETranslator Hook PropertySheet: %s.%s',
        [OwnerName, ARootControl.Name]);
{$ENDIF}
    end;
    // 注意不能 Exit; 其子 Control 可能还有 InspListBox
  end;

{$ENDIF}

  if ARootControl is TWinControl then
  begin
    W := TWinControl(ARootControl);
    for I := 0 to W.ControlCount - 1 do
    begin
      C := W.Controls[I];
      HookMessagesInControl(C);
    end;
  end;
end;

{$IFDEF IDE_CATALOG_VIRTUALTREE}

procedure TCnMenuFormTranslator.ClearUnusedVirtualTreeHooks;
var
  I: Integer;
  Hook: TCnVSTOnGetTextHook;
begin
  for I := FVirtualTreeHooks.Count - 1 downto 0 do
  begin
    Hook := TCnVSTOnGetTextHook(FVirtualTreeHooks[I]);
    if (Hook <> nil) and not Hook.Hooked then
      FVirtualTreeHooks.Remove(Hook);
  end;
end;

procedure TCnMenuFormTranslator.VSTTranslateText(Sender: TObject; const AText: string;
  var ATranslated: string);
begin
  ATranslated := CnLanguageManager.Translate(AText);
end;

{$ENDIF}

procedure TCnMenuFormTranslator.InspListBoxControlBeforeMessage(Sender: TObject;
  Control: TControl; var Msg: TMessage; var Handled: Boolean);
var
  OwnerName: string;
begin
  if Msg.Msg = WM_PAINT then
  begin
    // 延迟移除：把上一轮 After 放入待移除列表的控件真正移除
    while FPendingRemoveInspListBoxes.Count > 0 do
    begin
      FDrawingInspListBoxes.Remove(FPendingRemoveInspListBoxes[0]);
      FPendingRemoveInspListBoxes.Delete(0);
    end;
    // 把当前控件加入正在绘制集合
    if FDrawingInspListBoxes.IndexOf(Control) < 0 then
      FDrawingInspListBoxes.Add(Control);

{$IFDEF DEBUG}
    if Control.Owner <> nil then
      OwnerName := Control.Owner.Name
    else
      OwnerName := '<nil>';
    CnDebugger.LogFmt('CnIDETranslator InspListBox Control Before WM_PAINT: %s.%s',
      [OwnerName, Control.Name]);
{$ENDIF}
  end;
end;

procedure TCnMenuFormTranslator.InspListBoxControlAfterMessage(Sender: TObject;
  Control: TControl; var Msg: TMessage; var Handled: Boolean);
var
  OwnerName: string;
begin
  if Msg.Msg = WM_PAINT then
  begin
    // InspListBox 有多余的缓冲绘制，WM_PAINT 处理完后还在绘制
    // 不得不延迟取消标志，副作用则是可能会多余覆盖绘制本窗体上其他组件的字符串
    // 具体做法：WM_PAINT 结束后不立刻移除，放入待移除列表，
    // 等下一个 WM_PAINT 的 Before 到来时才真正移除，覆盖 WM_PAINT 后的补绘
    if FPendingRemoveInspListBoxes.IndexOf(Control) < 0 then
      FPendingRemoveInspListBoxes.Add(Control);

{$IFDEF DEBUG}
    if Control.Owner <> nil then
      OwnerName := Control.Owner.Name
    else
      OwnerName := '<nil>';
    CnDebugger.LogFmt('CnIDETranslator InspListBox Control After WM_PAINT: %s.%s',
      [OwnerName, Control.Name]);
{$ENDIF}
  end;
end;

procedure TCnMenuFormTranslator.InspListBoxUnHook(Sender: TObject; Control: TControl);
begin
  // 只要有取消挂接事件就从两个列表里移除，防止残留
  FDrawingInspListBoxes.Remove(Control);
  FPendingRemoveInspListBoxes.Remove(Control);
end;

{$ENDIF}

{$IFDEF IDE_OPTION_DYNCREATE}

procedure TCnMenuFormTranslator.IdleTranslatePage(Sender: TObject);
begin
  while FTransQueue.Count > 0 do
  begin
    CnLanguageManager.TranslateComponent(FTransQueue[0]);
    FTransQueue.Delete(0);
  end;
end;

procedure TCnMenuFormTranslator.PropertySheetAfterMessage(Sender: TObject; Control: TControl;
  var Msg: TMessage; var Handled: Boolean);
var
  C: TControl;
begin
  if Msg.Msg = CM_CONTROLCHANGE then
  begin
    if TCMControlChange(Msg).Inserting and (TCMControlChange(Msg).Control <> nil) then
    begin
      C := TCMControlChange(Msg).Control;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('CnMenuFormTranslator Get Control %s:%s inserted to Propsheet.',
        [C.ClassName, C.Name]);
{$ENDIF}
      // 延迟翻译该 Control，避免其内部组件还没创建完毕，复用 FTransQueue 应该没啥问题
      FTransQueue.Add(C);
      CnWizNotifierServices.ExecuteOnApplicationIdle(IdleTranslatePage);
    end;
  end;
end;

{$ENDIF}

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
    Captions := GetTranslationItemCaptions(SCN_CATEGORY_POPUPMENUS, SCN_MECHANISM_WINDOWPROC,
      'Application.TFormContainerForm.TPopupActionBar');
    if Length(Captions) = 0 then
      Exit;

    for I := 0 to PopupMenu.Items.Count - 1 do
      TranslateMenuItem(PopupMenu.Items[I], Captions);
  end;
end;

procedure TCnMenuFormTranslator.TranslateAllExistingForms(const ClassNamePattern: string);
var
  I: Integer;
  F: TCustomForm;
begin
  FTranedCompList.Clear;
  FLangTransFlag := False;

  // 当前要翻译为中文、且当前语言是中文，且加载了 IDE 的中文语言文件，则翻译所有已经存在的窗体为中文
  if CanTranslateToChinese then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('CnMultiLang LangaugeChanged. Current Translate to Chinese UI.');
{$ENDIF}
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      F := Screen.CustomForms[I];
      if (Pos('TCn', F.ClassName) <> 1) and (F.ClassName <> 'TTabDockHostForm')
        and ((ClassNamePattern = '') or (Pos(ClassNamePattern, F.ClassName) > 0)) then // 有匹配条件时就得匹配类名
      begin
        if FTranedCompList.IndexOf(F) < 0 then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('CnMultiLang LangaugeChanged. Translate to Chinese ' + F.ClassName);
{$ENDIF}
          try
            CnLanguageManager.TranslateForm(F, True);
          except
            ;
          end;

          // 只改 Modal 窗口
          if WizOptions.UseChineseFont and (fsModal in F.FormState) then
            F.Font := WizOptions.ChineseFont;

          if F.Visible then
            F.Update;
          FTranedCompList.Add(F);
        end
        else
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('CnMultiLang LangaugeChanged. ' + F.ClassName + ' Already Translated. Do Nothing.');
{$ENDIF}
        end;
      end;
    end;

    TranslateStaticEditorTab;
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
        if FTranedCompList.IndexOf(F) < 0 then
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
          FTranedCompList.Add(F);
        end;
      end;
    end;

    TranslateStaticEditorTab;
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

procedure TCnMenuFormTranslator.MultiLangTranslateObject(AObject: TObject;
  var Translate: Boolean);
begin
  if ( // 注意此处不能加 FActive 判断，否则从中翻英时会进不来从而导致该属性被破坏出错
    ((Compiler >= cnDelphi2007) and (AObject.ClassName = 'TWatchWindow')) or
    ((Compiler in [cnDelphi7]) and (AObject.ClassName = 'TMessageViewForm'))
    ) then
    FLangTransFlag := True;

  // 原本已创建但隐藏，基于某事件（如编译运行）出现的特定窗体，里头有 TTabSet 的，
  // 其 Tabs: TTabList 属性不能去访问，更别说翻译了，容易出错，因而在此过滤掉。
end;

procedure TCnMenuFormTranslator.MultiLangTranslateObjectProperty(
  AObject: TObject; const PropName: string; var Translate: Boolean);
begin
  // 构建事件对话框里的时机相关的 ComBoBox 不能翻译，哪怕没条目也不知怎么会丢 ItemIndex
  if (Compiler in [cnDelphi2009, cnDelphi2010, cnDelphiXE]) and
    (PropName = 'Items') and (AObject is TComponent) and
    AObject.ClassNameIs('TComboBox') and
    (TComponent(AObject).Name = 'ModeCombobox') and
    (TComponent(AObject).Owner <> nil) and
    TComponent(TComponent(AObject).Owner).ClassNameIs('TBuildEventEditor') then
  begin
    Translate := False;
    Exit;
  end;

  // 注意此处不能加 FActive 判断，否则从中翻英时会进不来从而导致该属性被破坏出错
  if FLangTransFlag and ((Compiler = cnDelphi7) or (Compiler >= cnDelphi2007))
    and AObject.ClassNameIs('TTabList') then
  begin
    Translate := False;

// 只能挨个翻，而且只能根据值翻，不能 Text 整体赋值，否则会破坏其 Objects 导致出错
// 但这样翻似乎也会出错，先屏蔽
//    if CanTranslateToChinese and (AObject is TStrings) then
//    begin
//      SL := TStrings(AObject);
//      for I := 0 to SL.Count - 1 do
//      begin
//        S := CnLanguageManager.TranslateString(SL[I]);
//        if S <> '' then
//          SL[I] := S;
//      end;
//    end;

    FLangTransFlag := False;
  end;
end;

{$IFDEF COMPILER7_UP}

procedure TCnMenuFormTranslator.OnApplicationIdle(Sender: TObject);
begin
  if CanTranslateToChinese then
    CheckActionMainMenuBarPersistentHotKeys;
end;

procedure TCnMenuFormTranslator.CheckActionMainMenuBarPersistentHotKeys;
var
  Bar: TComponent;
begin
  if FIDEMainMenuBar = nil then
  begin
    Bar := GetIDEMainMenuBar;
    if (Bar <> nil) and (Bar is TActionMainMenuBar) then
      FIDEMainMenuBar := TActionMainMenuBar(Bar);
  end;

  if (FIDEMainMenuBar <> nil) and not FIDEMainMenuBar.PersistentHotKeys then
    FIDEMainMenuBar.PersistentHotKeys := True;
end;

{$ENDIF}

function TCnMenuFormTranslator.CanTranslateToChinese: Boolean;
begin
  Result := FActive and FAddtionalLanguageFileLoad and (WizOptions.CurrentLangID = csChineseID);
end;

{ TCnMenuHookWrapper }

constructor TCnMenuHookWrapper.Create;
begin
  FHook := TCnMenuHook.Create(nil);
end;

destructor TCnMenuHookWrapper.Destroy;
begin
  FHook.Free;
  inherited;
end;

initialization

finalization
{$IFDEF UNICODE}
{$IFDEF DEBUG}
  FHookedStringHashMap.Free;
{$ENDIF}
{$ENDIF}

end.

