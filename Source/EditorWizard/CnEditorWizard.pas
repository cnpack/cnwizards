{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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

unit CnEditorWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：编辑器专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2002.12.03 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, ComCtrls, IniFiles, ToolsAPI, Registry, CnWizClasses, CnConsts, CnIni,
  CnWizConsts, CnWizMenuAction, ExtCtrls, CnWizMultiLang, CnWizManager;

type

{ TCnEditorForm }

  TCnEditorWizard = class;

  TCnEditorToolsForm = class(TCnTranslateForm)
    btnHelp: TButton;
    btnOK: TButton;
    grp1: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    lblToolName: TLabel;
    imgIcon: TImage;
    bvlWizard: TBevel;
    lbl3: TLabel;
    lblToolAuthor: TLabel;
    lvTools: TListView;
    mmoComment: TMemo;
    chkEnabled: TCheckBox;
    HotKey: THotKey;
    btnConfig: TButton;
    procedure FormCreate(Sender: TObject);
    procedure lvToolsDblClick(Sender: TObject);
    procedure HotKeyExit(Sender: TObject);
    procedure chkEnabledClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure lvToolsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  private
    { Private declarations }
    FWizard: TCnEditorWizard;
    procedure InitTools;
    procedure UpdateToolItem(Index: Integer);
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

{ TCnEditorWizard }

{$M+}

  TCnBaseEditorTool = class(TObject)
  private
    FActive: Boolean;
    FOwner: TCnEditorWizard;
    FAction: TCnWizMenuAction;
  protected
    function GetIDStr: string;
    procedure SetActive(Value: Boolean); virtual;
    {* Active 属性写方法，子类重载该方法处理 Active 属性变更事件}
    function GetHasConfig: Boolean; virtual;
    {* HasConfig 属性读方法，子类重载该方法返回是否存在可配置内容}
    function GetCaption: string; virtual; abstract;
    {* 返回工具的标题}
    function GetHint: string; virtual;
    {* 返回工具的Hint提示}
    function GetDefShortCut: TShortCut; virtual;
    {* 返回工具的默认快捷键，实际使用时工具的快捷键会可能由管理器来设定，这里
       只需要返回默认的就行了。}
    function CreateIniFile: TCustomIniFile;
    {* 返回一个用于存取工具设置参数的 INI 对象，用户使用后须自己释放}
    property Owner: TCnEditorWizard read FOwner;
  public
    constructor Create(AOwner: TCnEditorWizard); virtual;
    destructor Destroy; override;
    function GetEditorName: string;
    procedure LoadSettings(Ini: TCustomIniFile); virtual;
    {* 装载工具设置方法，子类重载此方法从 INI 对象中读取专家参数 }
    procedure SaveSettings(Ini: TCustomIniFile); virtual;
    {* 保存工具设置方法，子类重载些方法将专家参数保存到 INI 对象中 }
    function GetState: TWizardState; virtual;
    {* 返回工具状态，IOTAWizard 方法，子类重载该方法返回工具状态}
    procedure Execute; virtual; abstract;
    {* 当用户执行一个工具时，将调用该方法。}
    procedure Config; virtual;
    {* 配置方法，由管理器在配置界面中调用，当 HasConfig 为真时有效}
    procedure Loaded; virtual;
    {* IDE 启动完成后调用该方法}
    procedure GetEditorInfo(var Name, Author, Email: string); virtual; abstract;
    {* 取工具信息，用于提供工具的说明和版权信息。抽象方法，子类必须实现。
     |<PRE>
       var AName: string      - 工具名称，可以是支持本地化的字符串
       var Author: string     - 工具作者，如果有多个作者，用分号分隔
       var Email: string      - 工具作者邮箱，如果有多个作者，用分号分隔
     |</PRE>}
    procedure RefreshAction; virtual;
    {* 重新更新 Action 的内容 }
    procedure ParentActiveChanged(ParentActive: Boolean); virtual;
    {* 编辑器专家状态改变时被调用 }
    property Active: Boolean read FActive write SetActive;
    {* 活跃属性，表明工具当前是否可用}
    property HasConfig: Boolean read GetHasConfig;
    {* 表示工具是否存在配置界面的属性}
  end;

{$M-}

  TCnEditorToolClass = class of TCnBaseEditorTool;

{ TCnEditorWizard }

  TCnEditorWizard = class(TCnSubMenuWizard)
  private
    FConfigIndex: Integer;
    FEditorIndex: Integer;
    FEditorTools: TList;

    procedure UpdateActions;
    function GetEditorTools(Index: Integer): TCnBaseEditorTool;
    function GetEditorToolCount: Integer;
  protected
    function GetHasConfig: Boolean; override;
    procedure SetActive(Value: Boolean); override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AcquireSubActions; override;
    procedure RefreshSubActions; override;
    procedure Execute; override;
    procedure Config; override;
    procedure Loaded; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    property EditorTools[Index: Integer]: TCnBaseEditorTool read GetEditorTools;
    property EditorToolCount: Integer read GetEditorToolCount;
  end;

procedure RegisterCnEditor(const AClass: TCnEditorToolClass);
{* 注册一个 CnEditorTool 编辑器工具类引用，每个编辑器工具类实现单元
   应在该单元的 initialization 节调用该过程注册编辑器工具类}

function GetCnEditorToolClass(const ClassName: string): TCnEditorToolClass;
{* 根据编辑器工具类名取指定的编辑器工具类引用}

function GetCnEditorToolClassCount: Integer;
{* 返回已注册的编辑器工具类总数}

function GetCnEditorToolClassByIndex(const Index: Integer): TCnEditorToolClass;
{* 根据索引号取指定的编辑器工具类引用}

{$ENDIF CNWIZARDS_CNEDITORWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizOptions, CnWizUtils, CnWizShortCut, CnCommon, CnWizCommentFrm;

{$R *.DFM}

var
  CnEditorClassList: TList = nil; // 编辑器工具类引用列表

// 注册一个 CnEditorTool 编辑器工具类引用
procedure RegisterCnEditor(const AClass: TCnEditorToolClass);
begin
  Assert(CnEditorClassList <> nil, 'CnEditorClassList is nil!');
  if CnEditorClassList.IndexOf(AClass) < 0 then
    CnEditorClassList.Add(AClass);
end;

// 根据编辑器工具类名取指定的编辑器工具类引用
function GetCnEditorToolClass(const ClassName: string): TCnEditorToolClass;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to CnEditorClassList.Count - 1 do
  begin
    Result := CnEditorClassList[i];
    if Result.ClassNameIs(ClassName) then Exit;
  end;
end;

// 返回已注册的编辑器工具类总数
function GetCnEditorToolClassCount: Integer;
begin
  Result := CnEditorClassList.Count;
end;

// 根据索引号取指定的编辑器工具类引用
function GetCnEditorToolClassByIndex(const Index: Integer): TCnEditorToolClass;
begin
  Result := nil;
  if (Index >= 0) and (Index <= CnEditorClassList.Count - 1) then
    Result := CnEditorClassList[Index];
end;

{ TCnBaseEditorTool }

procedure TCnBaseEditorTool.Config;
begin

end;

constructor TCnBaseEditorTool.Create(AOwner: TCnEditorWizard);
begin
  inherited Create;
  Assert(Assigned(AOwner));
  FOwner := AOwner;
  FActive := True;
  FAction := nil;
end;

function TCnBaseEditorTool.CreateIniFile: TCustomIniFile;
begin
  Result := TRegistryIniFile.Create(MakePath(WizOptions.RegPath) + Owner.GetIDStr +
    '\' + GetIDStr, KEY_ALL_ACCESS);
end;

destructor TCnBaseEditorTool.Destroy;
begin
  inherited;

end;

procedure TCnBaseEditorTool.Loaded;
begin

end;

procedure TCnBaseEditorTool.LoadSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    ReadObject('', Self);
  finally
    Free;
  end;   
end;

procedure TCnBaseEditorTool.SaveSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteObject('', Self);
  finally
    Free;
  end;   
end;

function TCnBaseEditorTool.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnBaseEditorTool.GetIDStr: string;
begin
  Result := ClassName;
  if UpperCase(Result[1]) = 'T' then
    Delete(Result, 1, 1);
end;

function TCnBaseEditorTool.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnBaseEditorTool.GetHint: string;
begin
  Result := '';
end;

function TCnBaseEditorTool.GetEditorName: string;
var
  Author, Email: string;
begin
  GetEditorInfo(Result, Author, Email);
end;

function TCnBaseEditorTool.GetState: TWizardState;
begin
  if Owner.Active and Active then
    Result := [wsEnabled]
  else
    Result := [];
end;

procedure TCnBaseEditorTool.SetActive(Value: Boolean);
begin
  FActive := Value;
end;

procedure TCnBaseEditorTool.RefreshAction;
begin
  if FAction <> nil then
  begin
    FAction.Caption := GetCaption;
    FAction.Hint := GetHint;
  end;
end;

procedure TCnBaseEditorTool.ParentActiveChanged(ParentActive: Boolean);
begin

end;

{ TCnEditorWizard }

procedure TCnEditorWizard.Config;
begin
  inherited;
  with TCnEditorToolsForm.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
  DoSaveSettings;
  UpdateActions;
end;

constructor TCnEditorWizard.Create;
var
  i: Integer;
  Editor: TCnBaseEditorTool;
  ActiveIni: TCustomIniFile;
begin
  inherited;
  FEditorTools := TList.Create;
  ActiveIni := CreateIniFile;
  try
    Editor := nil;
    for i := 0 to GetCnEditorToolClassCount - 1 do
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('EditorTool Creating: ' + GetCnEditorToolClassByIndex(i).ClassName);
    {$ENDIF}
      try
        Editor := GetCnEditorToolClassByIndex(i).Create(Self);
      except
        on E: Exception do
        begin
          DoHandleException(E.Message);
          Continue;
        end;
      end;
      Editor.Active := ActiveIni.ReadBool(SCnActiveSection,
        Editor.GetIDStr, Editor.Active);
      FEditorTools.Add(Editor);
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('EditorTool Created: ' + GetCnEditorToolClassByIndex(i).ClassName);
    {$ENDIF}
    end;
  finally
    ActiveIni.Free;
  end;
end;

destructor TCnEditorWizard.Destroy;
var
  i: Integer;
  ActiveIni: TCustomIniFile;
begin
  ActiveIni := CreateIniFile;
  try
    for i := 0 to EditorToolCount - 1 do
    with EditorTools[i] do
    begin
      ActiveIni.WriteBool(SCnActiveSection, GetIDStr, Active);
      Free;
    end;
  finally
    ActiveIni.Free;
  end;
  FEditorTools.Free;
  inherited;
end;

// APos返回宏在当前行中的位置。
procedure TCnEditorWizard.Execute;
begin

end;

procedure TCnEditorWizard.Loaded;
var
  i: Integer;
begin
  inherited;
  for i := 0 to EditorToolCount - 1 do
    EditorTools[i].Loaded;
end;

function TCnEditorWizard.GetCaption: string;
begin
  Result := SCnEditorWizardMenuCaption;
end;

function TCnEditorWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnEditorWizard.GetHint: string;
begin
  Result := SCnEditorWizardMenuHint;
end;

function TCnEditorWizard.GetState: TWizardState;
begin
  if Active then 
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnEditorWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnEditorWizardName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnEditorWizardComment;
end;

function TCnEditorWizard.GetEditorTools(Index: Integer): TCnBaseEditorTool;
begin
  Result := TCnBaseEditorTool(FEditorTools[Index]);
end;

function TCnEditorWizard.GetEditorToolCount: Integer;
begin
  Result := FEditorTools.Count;
end;

procedure TCnEditorWizard.LoadSettings(Ini: TCustomIniFile);
var
  i: Integer;
  AIni: TCustomIniFile;
begin
  inherited;

  for i := 0 to EditorToolCount - 1 do
  begin
    AIni := EditorTools[i].CreateIniFile;
    try
      EditorTools[i].LoadSettings(AIni);
    finally
      AIni.Free;
    end;
  end;
end;

procedure TCnEditorWizard.SaveSettings(Ini: TCustomIniFile);
var
  i: Integer;
  AIni: TCustomIniFile;
begin
  inherited;

  for i := 0 to EditorToolCount - 1 do
  begin
    AIni := EditorTools[i].CreateIniFile;
    try
      EditorTools[i].SaveSettings(AIni);
    finally
      AIni.Free;
    end;
  end;
end;

procedure TCnEditorWizard.SubActionExecute(Index: Integer);
var
  i: Integer;
begin
  inherited;
  if Index = FConfigIndex then
  begin
    Config;
  end
  else
  begin
    for i := 0 to EditorToolCount - 1 do
      with EditorTools[i] do
        if Active and (FAction = SubActions[Index]) then
        begin
          Execute;
          Exit;
        end;
  end;
end;

procedure TCnEditorWizard.SubActionUpdate(Index: Integer);
var
  i: Integer;
  State: TWizardState;
begin
  for i := 0 to EditorToolCount - 1 do
  begin
    if EditorTools[i].FAction = SubActions[Index] then
    begin
      State := EditorTools[i].GetState;
      SubActions[Index].Visible := Active and EditorTools[i].Active;
      SubActions[Index].Enabled := Action.Enabled and (wsEnabled in State);
      SubActions[Index].Checked := wsChecked in State;
      Exit;
    end;
  end;
  inherited;
end;

procedure TCnEditorWizard.AcquireSubActions;
var
  i: Integer;
begin
  WizShortCutMgr.BeginUpdate;
  try
    FConfigIndex := RegisterASubAction(SCnEditorWizardConfigName,
      SCnEditorWizardConfigCaption, 0, SCnEditorWizardConfigHint,
      SCnEditorWizardConfigName);
    if EditorToolCount > 0 then
      AddSepMenu;
    FEditorIndex := FConfigIndex + 1;
    for i := 0 to EditorToolCount - 1 do
      with EditorTools[i] do
      begin
        FAction := SubActions[RegisterASubAction(GetIDStr, GetCaption, GetDefShortCut, GetHint)];
        FAction.Visible := Self.Active and Active;
      end;
  finally
    WizShortCutMgr.EndUpdate;
  end;
  UpdateActions;
end;

procedure TCnEditorWizard.RefreshSubActions;
var
  i: Integer;
begin // 处理方法有稍许不同，因此不能 inherited 来用 AcquireSubActions。
  for i := 0 to GetEditorToolCount - 1 do
    EditorTools[i].RefreshAction;

  inherited;
  UpdateActions;
end;

procedure TCnEditorWizard.UpdateActions;
var
  i: Integer;
begin
  for i := 0 to EditorToolCount - 1 do
    EditorTools[i].FAction.Visible := Active and EditorTools[i].Active;
end;

procedure TCnEditorWizard.SetActive(Value: Boolean);
var
  I: Integer;
begin
  if Value <> Active then
  begin
    inherited;
    for i := 0 to EditorToolCount - 1 do
      EditorTools[i].ParentActiveChanged(Active);
  end;
end;

{ TCnEditorToolsForm }

procedure TCnEditorToolsForm.FormCreate(Sender: TObject);
begin
  FWizard := TCnEditorWizard(CnWizardMgr.WizardByClass(TCnEditorWizard));
  Assert(Assigned(FWizard));
  InitTools;
end;

procedure TCnEditorToolsForm.UpdateToolItem(Index: Integer);
var
  AName, AAuthor, AEmail: string;
begin
  with lvTools.Items[Index] do
  begin
    FWizard.EditorTools[Index].GetEditorInfo(AName, AAuthor, AEmail);
    Caption := AName;
    SubItems.Clear;
    if FWizard.EditorTools[Index].Active then
      SubItems.Add(SCnEnabled)
    else
      SubItems.Add(SCnDisabled);
    SubItems.Add(ShortCutToText(FWizard.EditorTools[Index].FAction.ShortCut));
  end;
end;

procedure TCnEditorToolsForm.InitTools;
var
  i: Integer;
begin
  lvTools.Items.Clear;
  for i := 0 to FWizard.EditorToolCount - 1 do
  begin
    lvTools.Items.Add;
    UpdateToolItem(i);
  end;
  lvTools.Selected := lvTools.TopItem;
  lvTools.OnChange(lvTools, lvTools.TopItem, ctState);
end;

procedure TCnEditorToolsForm.lvToolsDblClick(Sender: TObject);
begin
  btnConfigClick(btnConfig);
end;

procedure TCnEditorToolsForm.HotKeyExit(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then Exit;
  Idx := lvTools.Selected.Index;
  FWizard.EditorTools[Idx].FAction.ShortCut := HotKey.HotKey;
  UpdateToolItem(Idx);
end;

procedure TCnEditorToolsForm.chkEnabledClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then Exit;
  Idx := lvTools.Selected.Index;
  FWizard.EditorTools[Idx].Active := chkEnabled.Checked;
  UpdateToolItem(Idx);
end;

procedure TCnEditorToolsForm.btnConfigClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then Exit;
  Idx := lvTools.Selected.Index;
  if FWizard.EditorTools[Idx].HasConfig then
    FWizard.EditorTools[Idx].Config;
  UpdateToolItem(Idx);
end;

procedure TCnEditorToolsForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnEditorToolsForm.GetHelpTopic: string;
begin
  Result := 'CnEditorWizard';
end;

procedure TCnEditorToolsForm.lvToolsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  Idx: Integer;
  AName, AAuthor, AEmail: string;
begin
  if Assigned(lvTools.Selected) then
  begin
    Idx := lvTools.Selected.Index;
    FWizard.EditorTools[Idx].GetEditorInfo(AName, AAuthor, AEmail);
    imgIcon.Picture.Assign(FWizard.EditorTools[Idx].FAction.Icon);
    lblToolName.Caption := AName;
    lblToolAuthor.Caption := CnAuthorEmailToStr(AAuthor, AEmail);
    HotKey.HotKey := FWizard.EditorTools[Idx].FAction.ShortCut;
    chkEnabled.Checked := FWizard.EditorTools[Idx].Active;
    btnConfig.Visible := FWizard.EditorTools[Idx].HasConfig;
    mmoComment.Lines.Text := GetCommandComment(FWizard.EditorTools[Idx].GetIDStr);
  end
end;

initialization
  CnEditorClassList := TList.Create;
  RegisterCnWizard(TCnEditorWizard); // 注册专家

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnEditorWizard finalization.');
{$ENDIF}

  FreeAndNil(CnEditorClassList);

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnEditorWizard finalization.');
{$ENDIF}

{$ENDIF CNWIZARDS_CNEDITORWIZARD}
end.
