{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2012 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPrefixWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件前缀专家单元
* 单元作者：陈省（Hubdog） hubdog@263.com
*           周劲羽 (zjy@cnpack.org)
* 备    注：组件前缀专家单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2006.08.09 V1.6 ZJY
*               增加根据 Action, DataField 重命名的功能 
*           2004.06.14 V1.5 LiuXiao
*               增加前缀是否大小写敏感的选项，默认为敏感。
*           2004.03.24 V1.4 刘啸(LiuXiao)
*               修正设计期可能会吞吃 WM_LBUTTONUP 消息从而产生拖动状态的缺陷
*           2003.09.27 V1.3 何清(QSoft)
*               修正添加一个新控件时多次被加入TObjectList中的BUG
*           2003.05.11 V1.2
*               LiuXiao:增加下划线选项
×          2003.04.28 V1.1
*               使用新的窗体通知器，去掉了大量代码
*           2003.04.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, StrUtils,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  ToolsAPI, TypInfo, IniFiles, Menus, Contnrs, CnWizClasses, CnWizUtils,
  CnWizConsts, CnWizMethodHook, CnPrefixList, CnConsts, CnWizOptions, CnCommon,
  CnWizNotifier, CnPrefixExecuteFrm, CnWizShortCut, CnWizMenuAction;

type

//==============================================================================
// 组件前缀专家
//==============================================================================

{ TCnPrefixWizard }

  TCnPrefixWizard = class(TCnMenuWizard)
  private
    FAutoPrefix: Boolean;
    FAllowClassName: Boolean;
    FAutoPopSuggestDlg: Boolean;
    FPopPrefixDefine: Boolean;
    FDelOldPrefix: Boolean;
    FUseUnderLine: Boolean;
    FUseActionName: Boolean;
    FWatchActionLink: Boolean;
    FUseFieldName: Boolean;
    FWatchFieldLink: Boolean;
    FPrefixCaseSensitive: Boolean;
    FCompKind: TPrefixCompKind;
    FUpdating: Boolean;

    FPrefixList: TPrefixList;
    FRenameList: TList;
    FOnRenameListAdded: TNotifyEvent;
    FInModify: Boolean;
    FModNotifierList: TStringList;
    FFormNotifierList: TStringList;
    FSetActionHook: TCnMethodHook;
    FSetValueHook: TCnMethodHook;
    FF2Rename: Boolean;
    FRenameAction: TCnWizAction;
    procedure OnConfig(Sender: TObject);
    procedure AddFormToList(const ProjectName: string; FormEditor: IOTAFormEditor;
      List: TCompList);
    procedure AddProjectToList(Project: IOTAProject; List: TCompList);
    procedure CreateSelCompList(List: TCompList);
    procedure CreateCurrFormList(List: TCompList);
    procedure CreateOpenedFormList(List: TCompList);
    procedure CreateCurrProjectList(List: TCompList);
    procedure CreateProjectGroupList(List: TCompList);
    function GetNewName(const ComponentType, Prefix,
      OldName: string): string;
    function IsUnnamed(APrefix, AName: string): Boolean;
    function HasPrefix(const Prefix, Name: string): Boolean;
    function IsValidComponent(AObj: TObject): Boolean;
    function NeedRename(AObj: TObject): Boolean;
    function NeedCustomRename(Component: TComponent): Boolean;
    function NeedActionRename(Component: TComponent): Boolean;
    function NeedFieldRename(Component: TComponent): Boolean;
    function ExtractIdentName(const AName: string): string;
    procedure SetF2Rename(const Value: Boolean);
    procedure OnRenameShortCutExec(Sender: TObject);
  protected
    procedure DoRenameComponent(Component: TComponent; const NewName: string;
      FormEditor: IOTAFormEditor);
    procedure OnIdle(Sender: TObject);
    function GetHasConfig: Boolean; override;
    procedure OnComponentRenamed(FormEditor: IOTAFormEditor;
      NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
      Component: TComponent; const OldName, NewName: string);
    function GetRuleComponentName(Component: TComponent; const CompText: string;
      var NewName: string; FormEditor: IOTAFormEditor; UserMode: Boolean;
      FromObjectInspector: Boolean = False): Boolean;
    procedure RenameList(AList: TCompList);
    procedure RenameComponent(Component: TComponent; FormEditor: IOTAFormEditor);
    property Updating: Boolean read FUpdating;
  public
    procedure AddCompToList(const ProjectName: string; FormEditor: IOTAFormEditor;
      Component: TComponent; List: TCompList);
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure ExecuteRename(Component: TComponent; FromObjectInspector: Boolean = False);

    property AutoPrefix: Boolean read FAutoPrefix write FAutoPrefix;
    property AutoPopSuggestDlg: Boolean read FAutoPopSuggestDlg write FAutoPopSuggestDlg;
    property PopPrefixDefine: Boolean read FPopPrefixDefine write FPopPrefixDefine;
    property AllowClassName: Boolean read FAllowClassName write FAllowClassName;
    property DelOldPrefix: Boolean read FDelOldPrefix write FDelOldPrefix;
    property UseUnderLine: Boolean read FUseUnderLine write FUseUnderLine;
    property UseActionName: Boolean read FUseActionName write FUseActionName;
    property WatchActionLink: Boolean read FWatchActionLink write FWatchActionLink;
    property UseFieldName: Boolean read FUseFieldName write FUseFieldName;
    property WatchFieldLink: Boolean read FWatchFieldLink write FWatchFieldLink;
    property CompKind: TPrefixCompKind read FCompKind write FCompKind;
    property PrefixCaseSensitive: Boolean read FPrefixCaseSensitive write FPrefixCaseSensitive;
    property F2Rename: Boolean read FF2Rename write SetF2Rename;

    property PrefixList: TPrefixList read FPrefixList;
    property FormNotifierList: TStringList read FFormNotifierList;
    property ModNotifierList: TStringList read FModNotifierList;
  end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

uses
  {$IFDEF DEBUG}CnDebug, {$ENDIF}
  CnWizManager, CnPrefixNewFrm, CnPrefixEditFrm, CnPrefixConfigFrm, CnPrefixCompFrm;

const
  csDataField = 'DataField';

type
  TControlAccess = class(TControl);
  TMenuActionLinkAccess = class(TMenuActionLink);
  TControlActionLinkAccess = class(TControlActionLink);
  TBasicActionLinkAccess = class(TBasicActionLink);

  TSetActionProc = procedure(Self: TBasicActionLink; Value: TBasicAction);
  TSetValueProc = procedure(Self: TStringProperty; const Value: string);
     
var
  OldSetActionProc: TSetActionProc;
  OldSetValueProc: TSetValueProc;

  FWizard: TCnPrefixWizard;

procedure CnPrefixRenameProc(AComp: TComponent);
var
  PrefixWizard: TCnPrefixWizard;
begin
  PrefixWizard := TCnPrefixWizard(CnWizardMgr.WizardByClass(TCnPrefixWizard));
  if Assigned(PrefixWizard) {and PrefixWizard.Active} then
    PrefixWizard.ExecuteRename(AComp, True);
end;

// Hook 的 TBasicAction.SetAction 方法
procedure MySetAction(Self: TBasicActionLink; Value: TBasicAction);
var
  Client: TObject;
begin
  // 调用原来的方法
  FWizard.FSetActionHook.UnhookMethod;
  try
    OldSetActionProc(Self, Value);

    // 判断是否需要自动重命名组件并进行处理，如果前面有异常则跳过处理
    if (Value <> nil) and (FWizard <> nil) and FWizard.Active and
      FWizard.FAutoPrefix and FWizard.FUseActionName and FWizard.FWatchActionLink then
    begin
      if Self is TMenuActionLink then
        Client := TMenuActionLinkAccess(Self).FClient
      else if Self is TControlActionLink then
        Client := TControlActionLinkAccess(Self).FClient
      else
        Client := nil;

      if FWizard.NeedRename(Client) and
        FWizard.NeedActionRename(TComponent(Client)) then
      begin
        FWizard.FRenameList.Add(Client);
      {$IFDEF DEBUG}
        CnDebugger.LogFmt('TBasicAction.SetAction: %s: %s',
          [TComponent(Client).Name, Client.ClassName]);
      {$ENDIF}
      end;
    end;
  finally
    FWizard.FSetActionHook.HookMethod;
  end;
end;

// Hook 的 TStringProperty.SetValue 方法
procedure MySetValue(Self: TStringProperty; const Value: string);
var
  i: Integer;
  Client: TComponent;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('MySetValue: ' + Value);
{$ENDIF}

  // 调用原来的方法
  FWizard.FSetValueHook.UnhookMethod;
  try
    OldSetValueProc(Self, Value);

    // 判断是否需要自动重命名组件并进行处理，如果前面有异常则跳过处理
    if (Value <> '') and (FWizard <> nil) and FWizard.Active and
      FWizard.FAutoPrefix and FWizard.FUseFieldName and FWizard.FWatchFieldLink and
      AnsiSameStr(Self.GetName, csDataField) then
    begin
      for i := 0 to Self.PropCount - 1 do
      begin
        if Self.GetComponent(i) is TComponent then
        begin
          Client := TComponent(Self.GetComponent(i));
          if FWizard.NeedRename(Client) and
            FWizard.NeedFieldRename(Client) then
          begin
            FWizard.FRenameList.Add(Client);
          {$IFDEF DEBUG}
            CnDebugger.LogFmt('TStringProperty.SetValue: (%s: %s) %s => %s ',
              [Client.Name, Client.ClassName, Self.GetName, Value]);
          {$ENDIF}
          end;
        end;
      end;
    end;
  finally
    FWizard.FSetValueHook.HookMethod;
  end;
end;

type
  TDefPreInfo = record
    ClassName: string;
    Contain: string;
    Prefix: string;
  end;

const
  DefPreInfo: array[0..16] of TDefPreInfo =
   ((ClassName: 'TBasicAction'; Contain: 'Action'; Prefix: 'act'),
    (ClassName: 'TControl'; Contain: 'RadioButton'; Prefix: 'rb'),
    (ClassName: 'TCustomCheckBox'; Contain: 'CheckBox'; Prefix: 'chk'),
    (ClassName: 'TCustomLabel'; Contain: 'Label'; Prefix: 'lbl'),
    (ClassName: 'TControl'; Contain: 'Button'; Prefix: 'btn'),
    (ClassName: 'TCustomEdit'; Contain: 'Edit'; Prefix: 'edt'),
    (ClassName: 'TCustomMemo'; Contain: 'Memo'; Prefix: 'mmo'),
    (ClassName: 'TControl'; Contain: 'Image'; Prefix: 'img'),
    (ClassName: 'TControl'; Contain: 'ComboBox'; Prefix: 'cbb'),
    (ClassName: 'TCustomTreeView'; Contain: 'TreeView'; Prefix: 'tv'),
    (ClassName: 'TCustomListView'; Contain: 'ListView'; Prefix: 'lv'),
    (ClassName: 'TCustomGroupBox'; Contain: 'GroupBox'; Prefix: 'grp'),
    (ClassName: 'TControl'; Contain: 'List'; Prefix: 'lst'),
    (ClassName: 'TDataSource'; Contain: 'DataSource'; Prefix: 'ds'),
    (ClassName: 'TDatabase'; Contain: 'Database'; Prefix: 'db'),
    (ClassName: 'TComponent'; Contain: 'Connection'; Prefix: 'con'),
    (ClassName: 'TCommonDialog'; Contain: 'Dialog'; Prefix: 'dlg')
    );

function GenDefPrefix(const CName: string): string;
var
  i: Integer;
begin
  for i := Low(DefPreInfo) to High(DefPreInfo) do
    if AnsiContainsText(CName, DefPreInfo[i].Contain) and
      InheritsFromClassName(GetClass(CName), DefPreInfo[i].ClassName) then
    begin
      Result := DefPreInfo[i].Prefix;
      Exit;
    end;

  Result := LowerCase(RemoveClassPrefix(Trim(CName)));
  for i := Length(Result) downto 2 do
    if CharInSet(Result[i], ['a', 'e', 'o', 'i', 'u']) then
      Delete(Result, i, 1);
  for i := Length(Result) downto 2 do
    if Result[i] = Result[i - 1] then
      Delete(Result, i, 1);
end;

//==============================================================================
// 组件前缀专家
//==============================================================================

{ TCnPrefixWizard }

constructor TCnPrefixWizard.Create;
begin
  inherited;
  FPrefixList := TPrefixList.Create;
  FRenameList := TList.Create;
  CnWizNotifierServices.AddFormEditorNotifier(OnComponentRenamed);
  CnWizNotifierServices.AddApplicationIdleNotifier(OnIdle);
  FWizard := Self;

  OldSetActionProc := GetBplMethodAddress(@TBasicActionLinkAccess.SetAction);
  FSetActionHook := TCnMethodHook.Create(@OldSetActionProc, @MySetAction);

  OldSetValueProc := GetBplMethodAddress(@TStringProperty.SetValue);
  FSetValueHook := TCnMethodHook.Create(@OldSetValueProc, @MySetValue);

  RenameProc := @CnPrefixRenameProc;
  if GetIDEActionFromShortCut(ShortCut(VK_F2, [])) = nil then
  begin
    // 如果当前 IDE 中无 F2 快捷键的其它 Action，则注册此快捷键来更改
    FRenameAction := WizActionMgr.AddAction('CnPrefixRename',
      'Rename Select Component', ShortCut(VK_F2, []), OnRenameShortCutExec,
      'CnPrefixRename', 'Rename Select Component');
    FRenameAction.Visible := False;
  end
  else
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('CnPrefix Action: F2 Exists. NOT Register.');
{$ENDIF}
  end;  
end;

destructor TCnPrefixWizard.Destroy;
begin
  if FRenameAction <> nil then
    WizActionMgr.DeleteAction(FRenameAction);
  RenameProc := nil;
  FWizard := nil;
  FreeAndNil(FSetActionHook);
  if FSetValueHook <> nil then
    FreeAndNil(FSetValueHook);
  CnWizNotifierServices.RemoveFormEditorNotifier(OnComponentRenamed);
  CnWizNotifierServices.RemoveApplicationIdleNotifier(OnIdle);
  FreeAndNil(FPrefixList);
  FreeAndNil(FRenameList);
  inherited;
end;

//------------------------------------------------------------------------------
// 自动更名部分
//------------------------------------------------------------------------------

function TCnPrefixWizard.HasPrefix(const Prefix, Name: string): Boolean;
begin
  if FPrefixCaseSensitive then
    Result := Pos(Prefix, Name) = 1
  else
    Result := Pos(UpperCase(Prefix), UpperCase(Name)) = 1;
end;

// 根据前缀计算默认的新组件名称
function TCnPrefixWizard.GetNewName(const ComponentType, Prefix, OldName: string): string;
var
  CName: string;
  i: Integer;

  function RemoveAfterNum(const Value: string): string;
  begin
    Result := Value;
    while (Result <> '') and CharInSet(Result[Length(Result)], ['0'..'9']) do
      Delete(Result, Length(Result), 1);
  end;
begin
  CName := RemoveClassPrefix(ComponentType);
  // 如果原名称为 IDE 默认组件名，去掉前面的组件名称和后面的数字
  if Pos(UpperCase(CName), UpperCase(OldName)) = 1 then
  begin
    if Self.FUseUnderLine then
      Result := RemoveAfterNum(Prefix + '_' + Copy(OldName, Length(CName) + 1, MaxInt))
    else
      Result := RemoveAfterNum(Prefix + Copy(OldName, Length(CName) + 1, MaxInt));
  end
  else if HasPrefix(Prefix, OldName) then
    Result := OldName
  else if FDelOldPrefix then
  begin
    i := 1;
    // 检查是否有大写字母
    while (i <= Length(OldName)) and CharInSet(OldName[i], ['a'..'z']) do
      Inc(i);
    // 删除原来的前缀
    if (i <= Length(OldName)) and CharInSet(OldName[i], ['A'..'Z', '_']) then
    begin
      if Self.FUseUnderLine then
        Result := Prefix + '_' + Copy(OldName, i, MaxInt)
      else
        Result := Prefix + Copy(OldName, i, MaxInt)
    end
    else
    begin
      if Self.FUseUnderLine then
        Result := Prefix + '_' + OldName
      else
        Result := Prefix + OldName;
    end;
  end
  else
  begin
    if Self.FUseUnderLine then
      Result := Prefix + '_' + OldName
    else
      Result := Prefix + OldName;
  end;

  if Result[Length(Result)] = '_' then
    Result := Result + '1';
end;

// Note: 在 OnComponentRenamed 时候，Component 有可能还没创建出来，
// 因此获得不了 NTAComponent
procedure TCnPrefixWizard.OnComponentRenamed(FormEditor: IOTAFormEditor;
  NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
  Component: TComponent; const OldName, NewName: string);
begin
  if not Active or not AutoPrefix or Updating then
    Exit;

  // 当前处于删除控件状态，无须记录
  if not (NotifyType in [fetComponentRenamed, fetComponentCreated])
    or (Trim(NewName) = '') then
    Exit;

  // 添加组件
  if NeedRename(TObject(ComponentHandle)) then
  begin
    FRenameList.Add(ComponentHandle);
    if Assigned(FOnRenameListAdded) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Prefix: Later Incoming component created notify, updating...');
{$ENDIF}
      FOnRenameListAdded(FRenameList);
    end;
  end;
end;

procedure TCnPrefixWizard.OnIdle(Sender: TObject);
var
  FormEditor: IOTAFormEditor;
  ProjectName: string;
  Comp: TComponent;
  List: TCompList;
  i: Integer;
begin
  if FInModify or (FRenameList.Count = 0) then
    Exit;

  FInModify := True;
  try
    if AutoPrefix then
    begin
      FormEditor := CnOtaGetCurrentFormEditor;
      if not Assigned(FormEditor) then Exit;
      
      if (FRenameList.Count > 1) and AutoPopSuggestDlg then
      begin
        // 取工程名
        if Assigned(FormEditor.Module) and (FormEditor.Module.OwnerCount > 0) then
          ProjectName := _CnExtractFileName(FormEditor.Module.Owners[0].FileName)
        else
          ProjectName := '';

        List := TCompList.Create;
        try
          // 处理选择的控件
          for i := 0 to FRenameList.Count - 1 do
          begin
            // 只有当前窗体上存在的组件才处理
            if Assigned(FormEditor.GetComponentFromHandle(FRenameList[i])) then
              AddCompToList(ProjectName, FormEditor, TComponent(FRenameList[i]), List);
          end;

          if List.Count > 0 then
            RenameList(List);
        finally
          List.Free;
        end;
      end
      else
      begin
        FormEditor := CnOtaGetCurrentFormEditor;
        if not Assigned(FormEditor) then
          Exit;
          
        while FRenameList.Count > 0 do
        begin
          Comp := TComponent(FRenameList.Extract(FRenameList[0]));
          // 只有当前窗体上存在的组件才处理
          if Assigned(FormEditor.GetComponentFromHandle(Comp)) then
            RenameComponent(Comp, FormEditor);
        end;
      end;
    end;
  finally
    FRenameList.Clear;
    FInModify := False;
  end;          
end;

function TCnPrefixWizard.IsValidComponent(AObj: TObject): Boolean;
var
  Comp: TComponent;
begin
  Result := False;
  // 粘贴的控件包含csLoading，因此此处不能加它，否则会被忽略
  // 但是控件的 Owner 不应该包括 csLoading，否则可能是窗体在加载期
  if (AObj <> nil) and (AObj is TComponent) then
  begin
    Comp := TComponent(AObj);
    if (csDesigning in Comp.ComponentState) and
      ([csReading, csWriting, csAncestor, csDestroying, csUpdating] *
      Comp.ComponentState = []) and (Comp.Owner <> nil) and
      (csDesigning in Comp.Owner.ComponentState) and
      ([csReading, csWriting, csLoading, csDestroying, csUpdating] *
      Comp.Owner.ComponentState = []) and
      not (AObj is TCustomForm) and not (AObj is TCustomModule) then
    begin
      Result := True;
    end;  
  end;
end;

function TCnPrefixWizard.NeedRename(AObj: TObject): Boolean;
begin
  Result := IsValidComponent(AObj) and (FRenameList.IndexOf(AObj) < 0);
end;

function TCnPrefixWizard.NeedCustomRename(Component: TComponent): Boolean;
var
  Prefix: string;
begin
  Result := False;
  Prefix := PrefixList.Prefixs[Component.ClassName];
  
  // 组件前缀未定义且不要求定义
  if (Prefix = '') and not PopPrefixDefine then
    Exit;

  // 组件未命名或前缀不正确时需要自定义命名
  if ((Prefix = '') or not HasPrefix(Prefix, Component.Name) or
    IsUnnamed(Prefix, Component.Name)) then
    Result := True;
end;

function TCnPrefixWizard.NeedActionRename(Component: TComponent): Boolean;
var
  Action: TBasicAction;
  Prefix: string;
begin
  Result := False;
  if FUseActionName then
  begin
    Action := CnGetComponentAction(Component);
    if Action <> nil then
    begin
      Prefix := PrefixList.Prefixs[Action.ClassName];
      // Action 前缀已定义且已命名时才使用 Action 命名
      if NeedCustomRename(Component) and (Prefix <> '') and
        not IsUnnamed(Prefix, Action.Name) then
        Result := True;
    end;
  end;    
end;

function TCnPrefixWizard.ExtractIdentName(const AName: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(AName) do
    if CharInSet(AName[i], Alpha) or (Result <> '') and
      CharInSet(AName[i], AlphaNumeric) then
      Result := Result + AName[i]; 
end;

function TCnPrefixWizard.NeedFieldRename(Component: TComponent): Boolean;
var
  PropInfo: PPropInfo;
  Field: string;
begin
  Result := False;
  if FUseFieldName then
  begin
    PropInfo := GetPropInfo(Component, csDataField);
    if (PropInfo <> nil) and (PropInfo.PropType <> nil) and
      (PropInfo.PropType^.Kind in [tkString, tkLString, tkWString
      {$IFDEF UNICODE_STRING}, tkUString{$ENDIF}]) then
    begin
      Field := ExtractIdentName(GetStrProp(Component, csDataField));
      if Field <> '' then
      begin
        // 组件前缀不正确或未命名时才使用 Field 命名
        if NeedCustomRename(Component) then
          Result := True;
      end;
    end;      
  end;
end;

function TCnPrefixWizard.GetRuleComponentName(Component: TComponent;
  const CompText: string; var NewName: string; FormEditor: IOTAFormEditor;
  UserMode: Boolean; FromObjectInspector: Boolean): Boolean;
var
  OldName: string;
  OldClassName, ClassName: string;
  Action: TBasicAction;
  Prefix: string;
  Ignore: Boolean;
  Succ: Boolean;
  DoRename: Boolean;
  OutStr: string;
  OutNum: Integer;

  procedure DisableDesignerDrag;
  var
    AForm: TComponent;
  begin
    if CnOtaGetFormDesigner <> nil then
    begin
      AForm := CnOtaGetFormDesigner.GetRoot;
      if not (AForm is TWinControl) then
        AForm := AForm.Owner; // 对于设计期的 TDataModule 来说，Owner 是 TDataModuleForm
      if (AForm <> nil) and (AForm is TWinControl) then
        PostMessage(TWinControl(AForm).Handle, WM_LBUTTONUP, 0, 0);
    end;
  end;

  function GetActionName(Action: TBasicAction): string;
  var
    APrefix: string;
  begin
    APrefix := PrefixList.Prefixs[Action.ClassName];
    Result := Action.Name;
    if (APrefix <> '') and (Pos(APrefix, Result) = 1) then
      Delete(Result, 1, Length(APrefix));
    while (Result <> '') and (Result[1] = '_') do
      Delete(Result, 1, 1);
  end;

  function GetFieldName(Component: TComponent): string;
  begin
    Result := ExtractIdentName(GetStrProp(Component, csDataField));
  end;
begin
  Result := False;
  if not (Component is TComponent) then Exit;

  OldName := Component.Name;
  ClassName := Component.ClassName;
  Action := CnGetComponentAction(Component);

  // 取控件前缀。对于 Form/DataModule，应该特殊处理，不应该根据变化的类名来
  OldClassName := ClassName;
  if Component is TCustomForm then
    ClassName := 'TForm'
  else if Component is TDataModule then
    ClassName := 'TDataModule'
  else if (Component is TCustomFrame) and ((Component as TControl).Parent = nil) then
    ClassName := 'TFrame'; // 是一个在设计期的独立 Frame

  Prefix := PrefixList.Prefixs[ClassName];
  if (Prefix = '') and (PopPrefixDefine or UserMode) then
  begin
    DisableDesignerDrag; // 弥补设计期可能会吞吃WM_LBUTTONUP消息从而产生拖动状态的缺陷
    // 如果未定义弹出定义前缀的界面

    if Prefix = '' then
      Prefix := GenDefPrefix(ClassName);
    Succ := GetNewComponentPrefix(ClassName, Prefix, False, Ignore, FPopPrefixDefine);
    PrefixList.Ignore[ClassName] := Ignore;

    if Succ then
    begin
      PrefixList.Prefixs[ClassName] := Prefix;
      DoSaveSettings;
    end;

    if Ignore or not Succ then
      Exit;
  end;

  ClassName := OldClassName; // 恢复

  if Prefix <> '' then
  begin
    DoRename := True;

    // 正确的前缀名
    if HasPrefix(Prefix, OldName) then
    begin
      // 前缀正确时还要检查 Action 和 Field 命名
      DoRename := NeedActionRename(Component) or NeedFieldRename(Component);
    end;

    // 组件名等于类名
    if AllowClassName and (RemoveClassPrefix(ClassName) = OldName) then
    begin
      DoRename := False;

      // 但如果是从 ObjectInspector 中点击组件编辑器改名，此时不该忽略类名为组件名的情形
      if FromObjectInspector then
        DoRename := True;
    end;

    if DoRename then
    begin
      // 菜单项刚创建时如果有 Action，则忽略原来的名称
      if (Component is TMenuItem) and Assigned(Action) and
        not HasPrefix(Prefix, OldName) then
        OldName := '';

      // 取新的名称
      NewName := GetNewName(ClassName, Prefix, OldName);

      if NeedFieldRename(Component) then
      begin
        // 检查关联的 DataField 属性
        if FUseUnderLine then
          NewName := Prefix + '_' + GetFieldName(Component)
        else
          NewName := Prefix + GetFieldName(Component);
      end
      else if NeedActionRename(Component) then
      begin
        // 检查关联的 Action
        if FUseUnderLine then
          NewName := Prefix + '_' + GetActionName(Action)
        else
          NewName := Prefix + GetActionName(Action);
      end;

      // 取一个唯一的名字
      if NewName = Prefix then
        NewName := (FormEditor as INTAFormEditor).FormDesigner.UniqueName(NewName);

      // 不用 IDE 来取，避免出现 pnl_11 之类的前缀。
      SeparateStrAndNum(NewName, OutStr, OutNum);
      if (Pos(Prefix, NewName) <> 1) and (Pos(Prefix + '_', NewName) <> 1) then
      begin
        if FUseUnderLine then
          OutStr := Prefix + '_'
        else
          OutStr := Prefix;
      end;

      while Assigned(FormEditor.FindComponent(NewName)) do
      begin
        if (OutNum = 0) or (OutNum = -1) then
          OutNum := 1; // 不使用 pnl_Top0 这样的命名方法。
        NewName := OutStr + IntToStr(OutNum);
        Inc(OutNum);
      end;
    end
    else if UserMode then
    begin
      NewName := OldName;
    end
    else
    begin
      Exit;
    end;

    // 弹出改名窗口
    if AutoPopSuggestDlg or UserMode then
    begin
      while True do
      begin
        DisableDesignerDrag; // 弥补设计期可能会吞吃WM_LBUTTONUP消息从而产生拖动状态的缺陷

        Succ := GetNewComponentName(_CnExtractFileName(FormEditor.GetFileName),
          ClassName, CompText, OldName, Prefix, NewName, UserMode, Ignore,
          FAutoPopSuggestDlg, FUseUnderLine);
        PrefixList.Prefixs[ClassName] := Prefix;
        PrefixList.Ignore[ClassName] := Ignore;

        if Succ then
          DoSaveSettings;
        if Ignore or not Succ then
          Exit;

        // 更名前后的名称一样
        if CompareStr(OldName, NewName) = 0 then
          Exit;

        if Assigned(FormEditor.FindComponent(NewName)) and // 新旧只大小写不同时不出错
          (CompareStr(UpperCase(OldName), UpperCase(NewName)) <> 0) then
          ErrorDlg(SCnPrefixDupName)
        else
        begin
          Result := True;
          Break;
        end;
      end;
    end
    else
      Result := True;
  end;
end;

procedure TCnPrefixWizard.ExecuteRename(Component: TComponent;
  FromObjectInspector: Boolean);
var
  NewName: string;
  FormEditor: IOTAFormEditor;
  
  function GetCompText: string;
  begin
    if Component is TControl then
      Result := TControlAccess(Component).Text
    else
      Result := '';
  end;
begin
  FormEditor := CnOtaGetCurrentFormEditor;
  if Assigned(FormEditor) then
  begin
    if GetRuleComponentName(Component, GetCompText, NewName, FormEditor, True,
      FromObjectInspector) then
    begin
      Component.Name := NewName;
      CnOtaNotifyFormDesignerModified(FormEditor);
    end;
  end;
end;

procedure TCnPrefixWizard.RenameComponent(Component: TComponent;
  FormEditor: IOTAFormEditor);
var
  NewName: string;
begin
  if FUpdating or not Active or not AutoPrefix then
    Exit;

  // 被忽略的组件类型
  if PrefixList.Ignore[Component.ClassName] then
    Exit;

  FUpdating := True;
  try
    if GetRuleComponentName(Component, CnGetComponentText(Component), NewName,
      FormEditor, False) then
    begin
      DoRenameComponent(Component, NewName, FormEditor);
    end;
  finally
    FUpdating := False;
  end;
end;

//------------------------------------------------------------------------------
// 专家执行部分
//------------------------------------------------------------------------------

procedure TCnPrefixWizard.DoRenameComponent(Component: TComponent; const
  NewName: string; FormEditor: IOTAFormEditor);
begin
  // todo: 修改名称时同时修改源代码
  Component.Name := NewName;
  
  // PopupMenu 等某些控件的设计器在设计结束后并没有调用 Modified 方法，需要手工调用一下
  CnOtaNotifyFormDesignerModified(FormEditor);
end;

procedure TCnPrefixWizard.RenameList(AList: TCompList);
var
  IniFile: TCustomIniFile;
  APrefix, ANewName: string;
  AIgnore, AAutoDlg: Boolean;
begin
  // 显示组件更名列表
  IniFile := CreateIniFile;
  try
    try
      if not ShowPrefixCompForm(AList, IniFile, FOnRenameListAdded) then
        Exit;
    finally
      FOnRenameListAdded := nil;
    end;

    FUpdating := True;
    try
      while AList.Count > 0 do
      begin
        with AList[0] do
        begin
          while True do
          begin
            // 如果同名则不修改
            if SameText(OldName, NewName) then
              Break;

            // 存在同名组件
            if Assigned(FormEditor.FindComponent(NewName)) then
            begin
              ErrorDlg(SCnPrefixDupName);
              APrefix := Prefix;
              ANewName := NewName;

              // 弹出对话框要求输入新组件名
              if GetNewComponentName(_CnExtractFileName(FormEditor.GetFileName),
                Component.ClassName, CnGetComponentText(Component),
                OldName, APrefix, ANewName, True, AIgnore, AAutoDlg,
                FUseUnderLine) then
              begin
                Prefix := APrefix;
                NewName := ANewName;

                DoSaveSettings;
              end
              else
                Break;
            end
            else
            begin
              // 设置组件名称
              DoRenameComponent(Component, NewName, FormEditor);
              Break;
            end;
          end;
        end;
        AList.Delete(0);
      end;
    finally
      FUpdating := False;
    end;
  finally
    IniFile.Free;
  end;
end;

procedure TCnPrefixWizard.Execute;
var
  Kind: TPrefixExeKind;
  List: TCompList;
begin
  if Updating then Exit;

  if Active and ShowPrefixExecuteForm(OnConfig, Kind, FCompKind) then
  begin
    List := TCompList.Create;
    try
      // 创建要更名的组件列表
      case Kind of
        pkSelComp: CreateSelCompList(List);
        pkCurrForm: CreateCurrFormList(List);
        pkOpenedForm: CreateOpenedFormList(List);
        pkCurrProject: CreateCurrProjectList(List);
        pkProjectGroup: CreateProjectGroupList(List);
      else
        Exit;
      end;

      if List.Count <= 0 then
      begin
        InfoDlg(SCnPrefixNoComp);
        Exit;
      end;

      RenameList(List);
    finally
      List.Free;
    end;
  end;
end;

function TCnPrefixWizard.IsUnnamed(APrefix, AName: string): Boolean;
begin
  Result := False;
  if HasPrefix(APrefix, AName) then
  begin
    Delete(AName, 1, Length(APrefix));
    if UseUnderLine and (AName[1] = '_') then
      Delete(AName, 1, 1);
    Result := (AName = '') or (StrToIntDef(AName, -MaxInt) <> -MaxInt);
  end;
end;

procedure TCnPrefixWizard.AddCompToList(const ProjectName: string; FormEditor:
  IOTAFormEditor; Component: TComponent; List: TCompList);
var
  Ignore, Succ: Boolean;
  Prefix: string;
  CompType: string;
  OldName, NewBase, NewName: string;
  i: Integer;
begin
  if not Assigned(FormEditor) or not IsValidComponent(Component) then Exit;

  // 取组件名称
  OldName := Component.Name;
  if OldName = '' then
    Exit;

  // 判断是否被忽略的组件
  if (FCompKind = pcIncorrect) and PrefixList.Ignore[Component.ClassName] then
    Exit;

  // 取组件前缀
  Ignore := False;
  Prefix := PrefixList.Prefixs[Component.ClassName];
  if (Prefix = '') and PopPrefixDefine then
  begin
    // 如果未定义弹出定义前缀的界面
    if Prefix = '' then
      Prefix := GenDefPrefix(Component.ClassName);
    Succ := GetNewComponentPrefix(Component.ClassName, Prefix,
      False, Ignore, FPopPrefixDefine);
    PrefixList.Ignore[Component.ClassName] := Ignore;
    if Succ then
      PrefixList.Prefixs[Component.ClassName] := Prefix
    else
      Prefix := '';
  end;

  if (FCompKind = pcIncorrect) and (Ignore or (Prefix = '')) then
    Exit;

  CompType := RemoveClassPrefix(Component.ClassName);
  if (Prefix = '') or HasPrefix(Prefix, OldName) or
    AllowClassName and SameText(CompType, OldName) then
  begin
    case FCompKind of
      pcIncorrect:
        Exit;
      pcUnnamed:
        if (Prefix = '') or AllowClassName and SameText(CompType, OldName)
          or not IsUnnamed(Prefix, OldName) then
          Exit;
    end;
    NewName := OldName;
  end
  else
  begin
    // 计算新名称
    NewBase := GetNewName(Component.ClassName, Prefix, OldName);

    // 取一个唯一的名字
    i := 1;
    if SameText(NewBase, Prefix) then
      NewName := NewBase + '1'
    else
      NewName := NewBase;
    while Assigned(FormEditor.FindComponent(NewName)) or
      (List.IndexOfNewName(FormEditor, NewName) >= 0) do
    begin
      NewName := NewBase + IntToStr(i);
      Inc(i);
    end;
  end;

  // 增加新记录
  List.Add(ProjectName, FormEditor, Component, Prefix, OldName, NewName);
end;

procedure TCnPrefixWizard.AddFormToList(const ProjectName: string;
  FormEditor: IOTAFormEditor; List: TCompList);
var
  i: Integer;
  AProjectName: string;
  AComponent: IOTAComponent;
begin
  if not Assigned(FormEditor) then Exit;

  // 判断是否重复处理的窗体
  for i := 0 to List.Count - 1 do
    if SameText(List[i].FormEditor.FileName, FormEditor.FileName) then
      Exit;

  // 取工程名
  if (ProjectName = '') and Assigned(FormEditor.Module) and
    (FormEditor.Module.OwnerCount > 0) then
    AProjectName := _CnExtractFileName(FormEditor.Module.Owners[0].FileName)
  else
    AProjectName := ProjectName;

  // 处理窗体上所有组件
  AComponent := FormEditor.GetRootComponent;
  for i := 0 to AComponent.GetComponentCount - 1 do
    AddCompToList(AProjectName, FormEditor,
      TComponent(AComponent.GetComponent(i).GetComponentHandle), List);
end;

procedure TCnPrefixWizard.AddProjectToList(Project: IOTAProject;
  List: TCompList);
var
  i: Integer;
  FormEditor: IOTAFormEditor;
  ProjectName: string;
  ModuleInfo: IOTAModuleInfo;
  Module: IOTAModule;
begin
  if not Assigned(Project) then Exit;

  ProjectName := _CnExtractFileName(Project.FileName);
  for i := 0 to Project.GetModuleCount - 1 do
  begin
    ModuleInfo := Project.GetModule(i);
    if not Assigned(ModuleInfo) then
      Continue;

    // 判断是否有窗体存在
    if Trim(ModuleInfo.FormName) = '' then
      Continue;

    Module := ModuleInfo.OpenModule;
    if not Assigned(Module) then
      Continue;

    FormEditor := CnOtaGetFormEditorFromModule(Module);
    if Assigned(FormEditor) then
      AddFormToList(ProjectName, FormEditor, List);
  end;
end;

procedure TCnPrefixWizard.CreateCurrFormList(List: TCompList);
begin
  List.Clear;
  AddFormToList('', CnOtaGetCurrentFormEditor, List);
end;

procedure TCnPrefixWizard.CreateCurrProjectList(List: TCompList);
begin
  List.Clear;
  AddProjectToList(CnOtaGetCurrentProject, List);
end;

procedure TCnPrefixWizard.CreateOpenedFormList(List: TCompList);
var
  i: Integer;
  FormEditor: IOTAFormEditor;
  ModuleServices: IOTAModuleServices;
begin
  List.Clear;
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);

  for i := 0 to ModuleServices.GetModuleCount - 1 do
  begin
    FormEditor := CnOtaGetFormEditorFromModule(ModuleServices.GetModule(i));
    if Assigned(FormEditor) then
      AddFormToList('', FormEditor, List);
  end;
end;

procedure TCnPrefixWizard.CreateProjectGroupList(List: TCompList);
var
  i: Integer;
  ProjectGroup: IOTAProjectGroup;
begin
  List.Clear;

  ProjectGroup := CnOtaGetProjectGroup;
  if not Assigned(ProjectGroup) then Exit;

  for i := 0 to ProjectGroup.ProjectCount - 1 do
    AddProjectToList(ProjectGroup.Projects[i], List);
end;

procedure TCnPrefixWizard.CreateSelCompList(List: TCompList);
var
  FormEditor: IOTAFormEditor;
  ProjectName: string;
  i: Integer;
begin
  List.Clear;
  FormEditor := CnOtaGetCurrentFormEditor;
  if not Assigned(FormEditor) then Exit;

  if FormEditor.GetSelCount > 0 then
  begin
    // 取工程名
    if Assigned(FormEditor.Module) and (FormEditor.Module.OwnerCount > 0) then
      ProjectName := _CnExtractFileName(FormEditor.Module.Owners[0].FileName)
    else
      ProjectName := '';

    // 处理选择的控件
    for i := 0 to FormEditor.GetSelCount - 1 do
      AddCompToList(ProjectName, FormEditor,
        TComponent(FormEditor.GetSelComponent(i).GetComponentHandle), List);
  end;
end;

//------------------------------------------------------------------------------
// 参数设置、存取部分
//------------------------------------------------------------------------------

const
  csAutoPrefix = 'AutoPrefix';
  csAllowClassName = 'AllowClassName';
  csAutoPopSuggestDlg = 'AutoPopSuggestDlg';
  csPopPrefixDefine = 'PopPrefixDefine';
  csDelOldPrefix = 'DelOldPrefix';
  csUseUnderLine = 'UseUnderLine';
  csUseActionName = 'UseActionName';
  csWatchActionLink = 'WatchActionLink';
  csUseFieldName = 'UseFieldName';
  csWatchFieldLink = 'WatchFieldLink';
  csPrefixCaseSensitive = 'PrefixCaseSensitive';
  csCompKind = 'CompKind';
  csF2Rename = 'F2Rename';

procedure TCnPrefixWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  FAutoPrefix := Ini.ReadBool('', csAutoPrefix, True);
  FAllowClassName := Ini.ReadBool('', csAllowClassName, True);
  FDelOldPrefix := Ini.ReadBool('', csDelOldPrefix, True);
  FAutoPopSuggestDlg := Ini.ReadBool('', csAutoPopSuggestDlg, True);
  FPopPrefixDefine := Ini.ReadBool('', csPopPrefixDefine, True);
  FUseUnderLine := Ini.ReadBool('', csUseUnderLine, False);
  FUseActionName := Ini.ReadBool('', csUseActionName, True);
  FWatchActionLink := Ini.ReadBool('', csWatchActionLink, True);
  FUseFieldName := Ini.ReadBool('', csUseFieldName, True);
  FWatchFieldLink := Ini.ReadBool('', csWatchFieldLink, True);
  FCompKind := TPrefixCompKind(Ini.ReadInteger('', csCompKind, 0));
  FPrefixCaseSensitive := Ini.ReadBool('', csPrefixCaseSensitive, True);
  F2Rename := Ini.ReadBool('', csF2Rename, True);

  FPrefixList.LoadFromFile(WizOptions.GetUserFileName(SCnPrefixDataName, True));
end;

procedure TCnPrefixWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  Ini.WriteBool('', csAutoPrefix, FAutoPrefix);
  Ini.WriteBool('', csAllowClassName, FAllowClassName);
  Ini.WriteBool('', csAutoPopSuggestDlg, FAutoPopSuggestDlg);
  Ini.WriteBool('', csDelOldPrefix, FDelOldPrefix);
  Ini.WriteBool('', csPopPrefixDefine, FPopPrefixDefine);
  Ini.WriteBool('', csUseUnderLine, FUseUnderLine);
  Ini.WriteBool('', csUseActionName, FUseActionName);
  Ini.WriteBool('', csWatchActionLink, FWatchActionLink);
  Ini.WriteBool('', csUseFieldName, FUseFieldName);
  Ini.WriteBool('', csWatchFieldLink, FWatchFieldLink);
  Ini.WriteInteger('', csCompKind, Ord(FCompKind));
  Ini.WriteBool('', csPrefixCaseSensitive, FPrefixCaseSensitive);
  Ini.WriteBool('', csF2Rename, FF2Rename);
  FPrefixList.SaveToFile(WizOptions.GetUserFileName(SCnPrefixDataName, False));
  WizOptions.CheckUserFile(SCnPrefixDataName);
end;

procedure TCnPrefixWizard.Config;
begin
  if ShowPrefixConfigForm(Self) then
  begin
    DoSaveSettings;
    FPrefixList.SaveToFile(WizOptions.GetUserFileName(SCnPrefixDataName, False));
    WizOptions.CheckUserFile(SCnPrefixDataName);
  end;
end;

procedure TCnPrefixWizard.OnConfig(Sender: TObject);
begin
  Config;
end;

//------------------------------------------------------------------------------
// 辅助代码
//------------------------------------------------------------------------------

function TCnPrefixWizard.GetCaption: string;
begin
  Result := SCnPrefixWizardMenuCaption;
end;

function TCnPrefixWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnPrefixWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnPrefixWizard.GetHint: string;
begin
  Result := SCnPrefixWizardMenuHint;
end;

function TCnPrefixWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnPrefixWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnPrefixWizardName;
  Author := SCnPack_Hubdog + ';' + SCnPack_Zjy + ';' + SCnPack_LiuXiao;
  Email := SCnPack_HubdogEmail + ';' + SCnPack_ZjyEmail + ';'
    + SCnPack_LiuXiaoEmail;
  Comment := SCnPrefixWizardComment;
end;

procedure TCnPrefixWizard.OnRenameShortCutExec(Sender: TObject);
var
  List: TList;
  FormEditor: IOTAFormEditor;
  IComponent: IOTAComponent;
begin
  // 检查并调用 ExecuteRename(SelectedComponent(0), True)
  if Active and CurrentIsForm then
  begin
    List := TList.Create;
    try
      FormEditor := CnOtaGetCurrentFormEditor;
      if FormEditor <> nil then
      begin
        if FormEditor.GetSelCount = 1 then // 选中单个时的处理
        begin
          IComponent := FormEditor.GetSelComponent(0);
          if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
            (TObject(IComponent.GetComponentHandle) is TComponent) then
            ExecuteRename(TComponent(IComponent.GetComponentHandle), True);
        end
        else if FormEditor.GetSelCount > 1 then
        begin
          // TODO: 选中多个的处理
        end
        else if (FormEditor.GetRootComponent <> nil) and
          (FormEditor.GetRootComponent.GetComponentHandle <> nil) then
          ExecuteRename(TComponent(FormEditor.GetRootComponent.GetComponentHandle), True);
      end;
    finally
      List.Free;
    end;
  end;
end;

procedure TCnPrefixWizard.SetF2Rename(const Value: Boolean);
begin
  FF2Rename := Value;
  if FRenameAction <> nil then
    FRenameAction.Enabled := Value;
end;

initialization
  RegisterCnWizard(TCnPrefixWizard); // 注册专家

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
end.
