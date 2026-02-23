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
  Controls, Forms, Menus, CnJSON, CnWizUtils, CnWizIdeUtils,
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

  TCnMenuTranslator = class
  {* 菜单翻译器}
  private
    FActive: Boolean;
    FOld2Array, FNew2Array: TStringList;
    FTranslationMap: TCnJSONObject;
    FMainMenu: TMainMenu;
    FMainMenuPath: string;
    FAttachedPopupMenuHooks: TObjectList; // MenuHooks
    FAttachedMenuItems: TObjectList;

    { 插件公用函数 }
    function FindComponentByNameDeep(const ARootComp: TComponent; const AName: string): TComponent;
    function FindControlByNameDeep(const ARootControl: TControl; const AName: string): TControl;
    function FindComponentByClassDeep(const ARootComp: TComponent; const AClassName: string): TComponent;
    function FindControlByClassDeep(const ARootControl: TControl; const AClassName: string): TControl;
    function FindMenuItemByNameDeep(const ARootMenuItem: TMenuItem; const AName: string): TMenuItem;
    function FindMainMenuItemByNameDeep(const AMainMenu: TMainMenu; const AName: string): TMenuItem;
    function FindPopupMenuByName(const AForm: TForm; const AOwnerName, AMenuName: string): TPopupMenu;
    function FindScreenFormByName(const AFormName: string): TForm;
    function GetActiveProjectInfo: TCnActiveProjectInfo;

{$IFDEF BDS}
    function GetPaletteButtonInfo: TCnPaletteButtonInfo;
{$ENDIF}
    function GetTranslationMenuPaths(const AMenuCategory, AMechanism: string): TCn2DStringArray;
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
    procedure TranslatePopupMenu(const AMenuCategory, AMechanism, AMenuPath,
      IsFromEnglish: string);
    {* 翻译一个弹出菜单，可弹出时动态调用，也可直接调用}
    procedure TranslatePopupMenuPaletteItems;
    {* 翻译控件板的弹出菜单}
    procedure TranslateStaticPopupMenus;
    {* 翻译其他静态弹出菜单}
    procedure HookPopupMenus;
    {* 挂接弹出菜单在弹出后进行翻译}

    procedure AfterPopupMenuOnPopup(Sender: TObject; Menu: TPopupMenu);
    {* 用来挂接的新弹出事件处理器}
    procedure UnHookPopupMenus;
    {* 解除挂接所有弹出菜单}

    // 插件处理过程
    procedure LoadTranslationMap(const AMapFile: string);
    procedure LoadMenuItemLanguages;
    procedure UpdateWholeMenus;

    procedure DelayActivate(Sender: TObject);
    procedure SetActive(const Value: Boolean);

    procedure ActiveProjectChanged(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;

    property Active: Boolean read FActive write SetActive;
    {* 是否启用英译中功能}
  end;

implementation

uses
  CnCommon, CnMenuHook, CnWizNotifier, CnStrings, CnWizOptions
  {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  csTransMapFile = 'TransMap.json';
  INDEX_ENU = 0;
  INDEX_CHS = 1;

  // 翻译的菜单类型
  RT_CATEGORY_MAINMENU: string = 'MainMenu';
  RT_CATEGORY_POPUPMENUS: string = 'PopupMenus';

  // 翻译的翻译机制
  RT_MECHANISM_DIRECTACCESS: string = 'DirectAccess';
  RT_MECHANISM_EVENTHANDLER: string = 'EventHandler';
  RT_MECHANISM_WINDOWPROC: string = 'WindowProc';

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

// 根据名称遍历查找组件
function TCnMenuTranslator.FindComponentByNameDeep(const ARootComp: TComponent;
  const AName: string): TComponent;
var
  I: Integer;
  Component: TComponent;
begin
  Result := nil;
  if not Assigned(ARootComp) then
    Exit;
  if SameText(ARootComp.Name, AName) then
  begin
    Result := ARootComp;
    Exit;
  end;

  for I := 0 to ARootComp.ComponentCount - 1 do
  begin
    Component := ARootComp.Components[I];
    if SameText(Component.Name, AName) then
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
function TCnMenuTranslator.FindControlByNameDeep(const ARootControl: TControl;
  const AName: string): TControl;
var
  I: Integer;
  Control: TControl;
  WinControl: TWinControl;
begin
  Result := nil;
  if not Assigned(ARootControl) then
    Exit;
  if SameText(ARootControl.Name, AName) then
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
    if SameText(Control.Name, AName) then
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
function TCnMenuTranslator.FindComponentByClassDeep(const ARootComp: TComponent;
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
function TCnMenuTranslator.FindControlByClassDeep(const ARootControl: TControl;
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

// 根据名称查找顶层窗体
function TCnMenuTranslator.FindScreenFormByName(const AFormName: string): TForm;
var
  I: Integer;
  Form: TForm;
begin
  Result := nil;
  for I := 0 to Screen.FormCount - 1 do
  begin
    Form := Screen.Forms[I];
    if SameText(Form.Name, AFormName) then
    begin
      Result := Form;
      Exit;
    end;
  end;
end;

// 根据名称遍历查找菜单的子菜单
function TCnMenuTranslator.FindMenuItemByNameDeep(const ARootMenuItem: TMenuItem;
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
function TCnMenuTranslator.FindMainMenuItemByNameDeep(const AMainMenu: TMainMenu;
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

// 根据名称查找弹出菜单
function TCnMenuTranslator.FindPopupMenuByName(const AForm: TForm; const AOwnerName,
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
function TCnMenuTranslator.GetActiveProjectInfo: TCnActiveProjectInfo;
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
function TCnMenuTranslator.GetPaletteButtonInfo: TCnPaletteButtonInfo;
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
function TCnMenuTranslator.GetTranslationMenuPaths(const AMenuCategory, AMechanism:
  string): TCn2DStringArray;
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
  for I := 0 to JsonArray.Count - 1 do
  begin
    if not (JsonArray[I] is TCnJSONObject) then
      Continue;

    JsonObject := TCnJSONObject(JsonArray[I]);
    Result[Count, 0] := JsonObject['MenuPath'].AsString;
    Result[Count, 1] := JsonObject['ForceEnglish'].AsString;
    Inc(Count);
  end;
end;

// 根据菜单路径获取标题集合
function TCnMenuTranslator.GetTranslationItemCaptions(const AMenuCategory, AMechanism,
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
function TCnMenuTranslator.ReturnTranslateCaption(const AItemCaption: string;
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
procedure TCnMenuTranslator.TranslateMenuItem(const AMenuItem: TMenuItem; const ACaptions:
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
procedure TCnMenuTranslator.TranslateMainMenuDynamicItem(const AMenuCategory,
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
procedure TCnMenuTranslator.TranslateStaticMainMenu;
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
procedure TCnMenuTranslator.TranslateMainMenuProjectItems;
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
procedure TCnMenuTranslator.HookMainMenuDynamicItems;
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
procedure TCnMenuTranslator.HookedMenuItemOnClick(Sender: TObject);
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

{ 主菜单处理过程->卸载动态子菜单集合 }
procedure TCnMenuTranslator.UnHookMainMenuDynamicItems;
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

{ 弹出菜单处理过程->重写单个弹出菜单 }
procedure TCnMenuTranslator.TranslatePopupMenu(const AMenuCategory, AMechanism, AMenuPath,
  IsFromEnglish: string);
var
  I: Integer;
  Form: TForm;
  PopupMenu: TPopupMenu;
  Names: TStringList;
  Captions: TCn2DStringArray;
begin
  Names := TStringList.Create;
  try
    ExtractStrings(['.'], [' '], PChar(AMenuPath), Names);

    Form := FindScreenFormByName(Names[0]);
    if not Assigned(Form) then
      Exit;
    PopupMenu := FindPopupMenuByName(Form, Names[1], Names[2]);
    if not Assigned(PopupMenu) then
      Exit;

    if Names.Count = 3 then
    begin
      Captions := GetTranslationItemCaptions(AMenuCategory, AMechanism, AMenuPath);
      if Length(Captions) = 0 then
        Exit;
  
      for I := 0 to PopupMenu.Items.Count - 1 do
      begin
        TranslateMenuItem(PopupMenu.Items[I], Captions);
      end;
    end;
  finally
    Names.Free;
  end;
end;

{ 弹出菜单处理过程->重写控件区指定弹出菜单 }
procedure TCnMenuTranslator.TranslatePopupMenuPaletteItems;
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
procedure TCnMenuTranslator.TranslateStaticPopupMenus;
var
  I: Integer;
  MenuPaths: TCn2DStringArray;
begin
  MenuPaths := GetTranslationMenuPaths(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_DIRECTACCESS);
  for I := 0 to Length(MenuPaths) - 1 do
  begin
    if SameText(MenuPaths[I, 1], 'False') then
    begin
      TranslatePopupMenu(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_DIRECTACCESS,
        MenuPaths[I, 0], MenuPaths[I, 1]);
    end;
  end;
end;

// 挂钩弹出菜单集合
procedure TCnMenuTranslator.HookPopupMenus;
var
  I, J: Integer;
  MenuPaths: TCn2DStringArray;
  Names: TStringList;
  Form: TForm;
  PopupMenu: TPopupMenu;
  MenuHooked: Boolean;
  Hook: TCnMenuHook;
begin
  UnHookPopupMenus;
  MenuPaths := GetTranslationMenuPaths(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_EVENTHANDLER);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnMenuTranslator.HookPopupMenus %d', [Length(MenuPaths)]);
{$ENDIF}

  for I := 0 to Length(MenuPaths) - 1 do
  begin
    Names := TStringList.Create;
    try
      ExtractStrings(['.'], [' '], PChar(MenuPaths[I, 0]), Names);
      if Names.Count <> 3 then
        Continue;
      Form := FindScreenFormByName(Names[0]);
      if not Assigned(Form) then
        Continue;
      PopupMenu := FindPopupMenuByName(Form, Names[1], Names[2]);
      if not Assigned(PopupMenu) then
        Continue;

      MenuHooked := False;
      for J := 0 to FAttachedPopupMenuHooks.Count - 1 do
      begin
        if TCnMenuHook(FAttachedPopupMenuHooks[J]).IsHooked(PopupMenu) then
        begin
          MenuHooked := True;
          Break;
        end;
      end;

      if not MenuHooked then
      begin
        Hook := TCnMenuHook.Create(nil);
        Hook.Text := MenuPaths[I, 0];
        Hook.HookMenu(PopupMenu);
        Hook.OnAfterPopup := AfterPopupMenuOnPopup;
        FAttachedPopupMenuHooks.Add(Hook);
      end;
    finally
      Names.Free;
    end;
  end;
end;

// 动态弹出菜单挂钩事件
procedure TCnMenuTranslator.AfterPopupMenuOnPopup(Sender: TObject; Menu: TPopupMenu);
var
  I: Integer;
  Hook: TCnMenuHook;
begin
  for I := 0 to FAttachedPopupMenuHooks.Count - 1 do
  begin
    Hook := TCnMenuHook(FAttachedPopupMenuHooks[I]);
    if Hook.IsHooked(Menu) then
    begin
      if SameText(Menu.Name, 'popPalette') then
      begin
        TranslatePopupMenuPaletteItems;
      end
      else
      begin
        TranslatePopupMenu(RT_CATEGORY_POPUPMENUS, RT_MECHANISM_EVENTHANDLER,
          Hook.Text, 'True');
      end;
      Exit;
    end;
  end;
end;

// 卸载弹出菜单集合
procedure TCnMenuTranslator.UnHookPopupMenus;
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
procedure TCnMenuTranslator.LoadTranslationMap(const AMapFile: string);
var
  StringList: TCnAnsiStringList;
  S: AnsiString;
begin
  StringList := TCnAnsiStringList.Create;
  if FileExists(AMapFile) then
  begin
    StringList.LoadFromFile(AMapFile);
    S := StringList.Text;
    if Length(S) > 3 then
      if (S[1] = #$EF) and (S[2] = #$BB) and (S[3] = #$BF) then
        Delete(S, 1, 3); // 去除 UTF8 的 BOM

    FTranslationMap := CnJSONParse(S);
  end;
  FreeAndNil(StringList);
end;

// 加载语言数据并初始化主菜单
procedure TCnMenuTranslator.LoadMenuItemLanguages;
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
procedure TCnMenuTranslator.UpdateWholeMenus;
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

constructor TCnMenuTranslator.Create;
var
  TranslationMapPath: string;
begin
  inherited Create;
  // 初始化参数对象
  FAttachedPopupMenuHooks := TObjectList.Create(True);
  FAttachedMenuItems := TObjectList.Create(True);

  // 加载翻译内容
  TranslationMapPath := WizOptions.GetDataFileName(csTransMapFile);
  LoadTranslationMap(TranslationMapPath);

  CnWizNotifierServices.AddActiveProjectChangedNotifier(ActiveProjectChanged);
end;

destructor TCnMenuTranslator.Destroy;
begin
  CnWizNotifierServices.RemoveActiveProjectChangedNotifier(ActiveProjectChanged);
  FOld2Array.Free;
  FNew2Array.Free;
  FreeAndNil(FTranslationMap);
  FreeAndNil(FAttachedPopupMenuHooks);
  FreeAndNil(FAttachedMenuItems);
  inherited;
end;

procedure TCnMenuTranslator.DelayActivate(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnMenuTranslator.DelayActivate');
{$ENDIF}

  TranslateStaticMainMenu;
  TranslateMainMenuProjectItems;
  HookMainMenuDynamicItems;
  HookPopupMenus;

//  HookFormDesigner;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnMenuTranslator.DelayActivate');
{$ENDIF}
end;

procedure TCnMenuTranslator.SetActive(const Value: Boolean);
begin
  if Value <> FActive then
  begin
    FActive := Value;
    if FActive then
    begin
      // 加载语言菜单
      LoadMenuItemLanguages;

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
      end;

      // 卸载事件挂钩
      UnHookPopupMenus;
      UnHookMainMenuDynamicItems;
    end;
  end;
end;

procedure TCnMenuTranslator.ActiveProjectChanged(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnMenuTranslator.ActiveProjectChanged');
{$ENDIF}
  TranslateMainMenuProjectItems;
end;

end.

