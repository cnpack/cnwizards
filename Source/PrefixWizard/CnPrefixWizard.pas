{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2014 CnPack ������                       }
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
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPrefixWizard;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����ǰ׺ר�ҵ�Ԫ
* ��Ԫ���ߣ���ʡ��Hubdog�� hubdog@263.com
*           �ܾ��� (zjy@cnpack.org)
* ��    ע�����ǰ׺ר�ҵ�Ԫ
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2006.08.09 V1.6 ZJY
*               ���Ӹ��� Action, DataField �������Ĺ��� 
*           2004.06.14 V1.5 LiuXiao
*               ����ǰ׺�Ƿ��Сд���е�ѡ�Ĭ��Ϊ���С�
*           2004.03.24 V1.4 ��Х(LiuXiao)
*               ��������ڿ��ܻ��̳� WM_LBUTTONUP ��Ϣ�Ӷ������϶�״̬��ȱ��
*           2003.09.27 V1.3 ����(QSoft)
*               �������һ���¿ؼ�ʱ��α�����TObjectList�е�BUG
*           2003.05.11 V1.2
*               LiuXiao:�����»���ѡ��
��          2003.04.28 V1.1
*               ʹ���µĴ���֪ͨ����ȥ���˴�������
*           2003.04.26 V1.0
*               ������Ԫ
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
// ���ǰ׺ר��
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
  FWizard: TCnPrefixWizard;

procedure CnPrefixRenameProc(AComp: TComponent);
var
  PrefixWizard: TCnPrefixWizard;
begin
  PrefixWizard := TCnPrefixWizard(CnWizardMgr.WizardByClass(TCnPrefixWizard));
  if Assigned(PrefixWizard) {and PrefixWizard.Active} then
    PrefixWizard.ExecuteRename(AComp, True);
end;

// Hook �� TBasicAction.SetAction ����
procedure MySetAction(Self: TBasicActionLink; Value: TBasicAction);
var
  Client: TObject;
begin
  // ����ԭ���ķ���
  TSetActionProc(FWizard.FSetActionHook.Trampoline)(Self, Value);

  // �ж��Ƿ���Ҫ�Զ���������������д������ǰ�����쳣����������
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
end;

// Hook �� TStringProperty.SetValue ����
procedure MySetValue(Self: TStringProperty; const Value: string);
var
  i: Integer;
  Client: TComponent;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('MySetValue: ' + Value);
{$ENDIF}

  // ����ԭ���ķ���
  TSetValueProc(FWizard.FSetValueHook.Trampoline)(Self, Value);

  // �ж��Ƿ���Ҫ�Զ���������������д������ǰ�����쳣����������
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
// ���ǰ׺ר��
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

  FSetActionHook := TCnMethodHook.Create(@TBasicActionLinkAccess.SetAction, @MySetAction);

  FSetValueHook := TCnMethodHook.Create(@TStringProperty.SetValue, @MySetValue);

  RenameProc := @CnPrefixRenameProc;
  if GetIDEActionFromShortCut(ShortCut(VK_F2, [])) = nil then
  begin
    // �����ǰ IDE ���� F2 ��ݼ������� Action����ע��˿�ݼ�������
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
// �Զ���������
//------------------------------------------------------------------------------

function TCnPrefixWizard.HasPrefix(const Prefix, Name: string): Boolean;
begin
  if FPrefixCaseSensitive then
    Result := Pos(Prefix, Name) = 1
  else
    Result := Pos(UpperCase(Prefix), UpperCase(Name)) = 1;
end;

// ����ǰ׺����Ĭ�ϵ����������
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
  // ���ԭ����Ϊ IDE Ĭ���������ȥ��ǰ���������ƺͺ��������
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
    // ����Ƿ��д�д��ĸ
    while (i <= Length(OldName)) and CharInSet(OldName[i], ['a'..'z']) do
      Inc(i);
    // ɾ��ԭ����ǰ׺
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

// Note: �� OnComponentRenamed ʱ��Component �п��ܻ�û����������
// ��˻�ò��� NTAComponent
procedure TCnPrefixWizard.OnComponentRenamed(FormEditor: IOTAFormEditor;
  NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
  Component: TComponent; const OldName, NewName: string);
begin
  if not Active or not AutoPrefix or Updating then
    Exit;

  // ��ǰ����ɾ���ؼ�״̬�������¼
  if not (NotifyType in [fetComponentRenamed, fetComponentCreated])
    or (Trim(NewName) = '') then
    Exit;

  // ������
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
        // ȡ������
        if Assigned(FormEditor.Module) and (FormEditor.Module.OwnerCount > 0) then
          ProjectName := _CnExtractFileName(FormEditor.Module.Owners[0].FileName)
        else
          ProjectName := '';

        List := TCompList.Create;
        try
          // ����ѡ��Ŀؼ�
          for i := 0 to FRenameList.Count - 1 do
          begin
            // ֻ�е�ǰ�����ϴ��ڵ�����Ŵ���
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
          // ֻ�е�ǰ�����ϴ��ڵ�����Ŵ���
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
  // ճ���Ŀؼ�����csLoading����˴˴����ܼ���������ᱻ����
  // ���ǿؼ��� Owner ��Ӧ�ð��� csLoading����������Ǵ����ڼ�����
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
  
  // ���ǰ׺δ�����Ҳ�Ҫ����
  if (Prefix = '') and not PopPrefixDefine then
    Exit;

  // ���δ������ǰ׺����ȷʱ��Ҫ�Զ�������
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
      // Action ǰ׺�Ѷ�����������ʱ��ʹ�� Action ����
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
        // ���ǰ׺����ȷ��δ����ʱ��ʹ�� Field ����
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
        AForm := AForm.Owner; // ��������ڵ� TDataModule ��˵��Owner �� TDataModuleForm
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

  // ȡ�ؼ�ǰ׺������ Form/DataModule��Ӧ�����⴦����Ӧ�ø��ݱ仯��������
  OldClassName := ClassName;
  if Component is TCustomForm then
    ClassName := 'TForm'
  else if Component is TDataModule then
    ClassName := 'TDataModule'
  else if (Component is TCustomFrame) and ((Component as TControl).Parent = nil) then
    ClassName := 'TFrame'; // ��һ��������ڵĶ��� Frame

  Prefix := PrefixList.Prefixs[ClassName];
  if (Prefix = '') and (PopPrefixDefine or UserMode) then
  begin
    DisableDesignerDrag; // �ֲ�����ڿ��ܻ��̳�WM_LBUTTONUP��Ϣ�Ӷ������϶�״̬��ȱ��
    // ���δ���嵯������ǰ׺�Ľ���

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

  ClassName := OldClassName; // �ָ�

  if Prefix <> '' then
  begin
    DoRename := True;

    // ��ȷ��ǰ׺��
    if HasPrefix(Prefix, OldName) then
    begin
      // ǰ׺��ȷʱ��Ҫ��� Action �� Field ����
      DoRename := NeedActionRename(Component) or NeedFieldRename(Component);
    end;

    // �������������
    if AllowClassName and (RemoveClassPrefix(ClassName) = OldName) then
    begin
      DoRename := False;

      // ������Ǵ� ObjectInspector �е������༭����������ʱ���ú�������Ϊ�����������
      if FromObjectInspector then
        DoRename := True;
    end;

    if DoRename then
    begin
      // �˵���մ���ʱ����� Action�������ԭ��������
      if (Component is TMenuItem) and Assigned(Action) and
        not HasPrefix(Prefix, OldName) then
        OldName := '';

      // ȡ�µ�����
      NewName := GetNewName(ClassName, Prefix, OldName);

      if NeedFieldRename(Component) then
      begin
        // �������� DataField ����
        if FUseUnderLine then
          NewName := Prefix + '_' + GetFieldName(Component)
        else
          NewName := Prefix + GetFieldName(Component);
      end
      else if NeedActionRename(Component) then
      begin
        // �������� Action
        if FUseUnderLine then
          NewName := Prefix + '_' + GetActionName(Action)
        else
          NewName := Prefix + GetActionName(Action);
      end;

      // ȡһ��Ψһ������
      if NewName = Prefix then
        NewName := (FormEditor as INTAFormEditor).FormDesigner.UniqueName(NewName);

      // ���� IDE ��ȡ��������� pnl_11 ֮���ǰ׺��
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
          OutNum := 1; // ��ʹ�� pnl_Top0 ����������������
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

    // ������������
    if AutoPopSuggestDlg or UserMode then
    begin
      while True do
      begin
        DisableDesignerDrag; // �ֲ�����ڿ��ܻ��̳�WM_LBUTTONUP��Ϣ�Ӷ������϶�״̬��ȱ��

        Succ := GetNewComponentName(_CnExtractFileName(FormEditor.GetFileName),
          ClassName, CompText, OldName, Prefix, NewName, UserMode, Ignore,
          FAutoPopSuggestDlg, FUseUnderLine);
        PrefixList.Prefixs[ClassName] := Prefix;
        PrefixList.Ignore[ClassName] := Ignore;

        if Succ then
          DoSaveSettings;
        if Ignore or not Succ then
          Exit;

        // ����ǰ�������һ��
        if CompareStr(OldName, NewName) = 0 then
          Exit;

        if Assigned(FormEditor.FindComponent(NewName)) and // �¾�ֻ��Сд��ͬʱ������
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

  // �����Ե��������
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
// ר��ִ�в���
//------------------------------------------------------------------------------

procedure TCnPrefixWizard.DoRenameComponent(Component: TComponent; const
  NewName: string; FormEditor: IOTAFormEditor);
begin
  // todo: �޸�����ʱͬʱ�޸�Դ����
  Component.Name := NewName;
  
  // PopupMenu ��ĳЩ�ؼ������������ƽ�����û�е��� Modified ��������Ҫ�ֹ�����һ��
  CnOtaNotifyFormDesignerModified(FormEditor);
end;

procedure TCnPrefixWizard.RenameList(AList: TCompList);
var
  IniFile: TCustomIniFile;
  APrefix, ANewName: string;
  AIgnore, AAutoDlg: Boolean;
begin
  // ��ʾ��������б�
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
            // ���ͬ�����޸�
            if SameText(OldName, NewName) then
              Break;

            // ����ͬ�����
            if Assigned(FormEditor.FindComponent(NewName)) then
            begin
              ErrorDlg(SCnPrefixDupName);
              APrefix := Prefix;
              ANewName := NewName;

              // �����Ի���Ҫ�������������
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
              // �����������
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
      // ����Ҫ����������б�
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

  // ȡ�������
  OldName := Component.Name;
  if OldName = '' then
    Exit;

  // �ж��Ƿ񱻺��Ե����
  if (FCompKind = pcIncorrect) and PrefixList.Ignore[Component.ClassName] then
    Exit;

  // ȡ���ǰ׺
  Ignore := False;
  Prefix := PrefixList.Prefixs[Component.ClassName];
  if (Prefix = '') and PopPrefixDefine then
  begin
    // ���δ���嵯������ǰ׺�Ľ���
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
    // ����������
    NewBase := GetNewName(Component.ClassName, Prefix, OldName);

    // ȡһ��Ψһ������
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

  // �����¼�¼
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

  // �ж��Ƿ��ظ�����Ĵ���
  for i := 0 to List.Count - 1 do
    if SameText(List[i].FormEditor.FileName, FormEditor.FileName) then
      Exit;

  // ȡ������
  if (ProjectName = '') and Assigned(FormEditor.Module) and
    (FormEditor.Module.OwnerCount > 0) then
    AProjectName := _CnExtractFileName(FormEditor.Module.Owners[0].FileName)
  else
    AProjectName := ProjectName;

  // ���������������
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

    // �ж��Ƿ��д������
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
    // ȡ������
    if Assigned(FormEditor.Module) and (FormEditor.Module.OwnerCount > 0) then
      ProjectName := _CnExtractFileName(FormEditor.Module.Owners[0].FileName)
    else
      ProjectName := '';

    // ����ѡ��Ŀؼ�
    for i := 0 to FormEditor.GetSelCount - 1 do
      AddCompToList(ProjectName, FormEditor,
        TComponent(FormEditor.GetSelComponent(i).GetComponentHandle), List);
  end;
end;

//------------------------------------------------------------------------------
// �������á���ȡ����
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
// ��������
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
  // ��鲢���� ExecuteRename(SelectedComponent(0), True)
  if Active and CurrentIsForm then
  begin
    List := TList.Create;
    try
      FormEditor := CnOtaGetCurrentFormEditor;
      if FormEditor <> nil then
      begin
        if FormEditor.GetSelCount = 1 then // ѡ�е���ʱ�Ĵ���
        begin
          IComponent := FormEditor.GetSelComponent(0);
          if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
            (TObject(IComponent.GetComponentHandle) is TComponent) then
            ExecuteRename(TComponent(IComponent.GetComponentHandle), True);
        end
        else if FormEditor.GetSelCount > 1 then
        begin
          // TODO: ѡ�ж���Ĵ���
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
  RegisterCnWizard(TCnPrefixWizard); // ע��ר��

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
end.
