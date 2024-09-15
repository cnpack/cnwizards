{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnCodingToolsetWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：编码工具集专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2002.12.03 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, ComCtrls, IniFiles, ToolsAPI, Registry, CnWizClasses, CnConsts, CnIni,
  CnWizConsts, CnWizMenuAction, ExtCtrls, CnWizMultiLang, CnWizManager, CnHashMap,
  CnWizIni;

type

{ TCnEditorToolsForm }

  TCnCodingToolsetWizard = class;

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
    FWizard: TCnCodingToolsetWizard;
    procedure InitTools;
    procedure UpdateToolItem(Index: Integer);
  protected
    function GetHelpTopic: string; override;
  public

  end;

{ TCnBaseCodingToolset }

{$M+}

  TCnBaseCodingToolset = class(TObject)
  private
    FActive: Boolean;
    FOwner: TCnCodingToolsetWizard;
    FAction: TCnWizMenuAction;  // 对菜单 Action 的引用
    FDefaultsMap: TCnStrToVariantHashMap;
  protected
    function GetIDStr: string;
    procedure SetActive(Value: Boolean); virtual;
    {* Active 属性写方法，子类重载该方法处理 Active 属性变更事件}
    function GetHasConfig: Boolean; virtual;
    {* HasConfig 属性读方法，子类重载该方法返回是否存在可配置内容}
    function GetCaption: string; virtual; abstract;
    {* 返回工具的标题}
    function GetHint: string; virtual;
    {* 返回工具的 Hint 提示}
    function GetDefShortCut: TShortCut; virtual;
    {* 返回工具的默认快捷键，实际使用时工具的快捷键会可能由管理器来设定，这里
       只需要返回默认的就行了。}
    function CreateIniFile: TCustomIniFile;
    {* 返回一个用于存取工具设置参数的 INI 对象，用户使用后须自己释放}
    property Owner: TCnCodingToolsetWizard read FOwner;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); virtual;
    destructor Destroy; override;

    function GetToolsetName: string;
    {* 返回工具名称}
    procedure LoadSettings(Ini: TCustomIniFile); virtual;
    {* 装载工具设置方法，子类重载此方法从 INI 对象中读取专家参数}
    procedure SaveSettings(Ini: TCustomIniFile); virtual;
    {* 保存工具设置方法，子类重载些方法将专家参数保存到 INI 对象中}
    function GetState: TWizardState; virtual;
    {* 返回工具状态，IOTAWizard 方法，子类重载该方法返回工具状态}
    procedure Execute; virtual; abstract;
    {* 当用户执行本工具时将调用该方法}
    procedure Config; virtual;
    {* 配置方法，由管理器在配置界面中调用，当 HasConfig 为真时有效}
    procedure Loaded; virtual;
    {* IDE 启动完成后调用该方法}
    procedure GetToolsetInfo(var Name, Author, Email: string); virtual; abstract;
    {* 取工具信息，用于提供工具的说明和版权信息。抽象方法，子类必须实现。
     |<PRE>
       var AName: string      - 工具名称，可以是支持本地化的字符串
       var Author: string     - 工具作者，如果有多个作者，用分号分隔
       var Email: string      - 工具作者邮箱，如果有多个作者，用分号分隔
     |</PRE>}
    procedure RefreshAction; virtual;
    {* 重新更新 Action 的内容}
    procedure ParentActiveChanged(ParentActive: Boolean); virtual;
    {* 编辑器专家状态改变时被调用}
    property Active: Boolean read FActive write SetActive;
    {* 活跃属性，表明工具当前是否可用}
    property HasConfig: Boolean read GetHasConfig;
    {* 表示工具是否存在配置界面的属性}
  end;

{$M-}

  TCnCodingToolsetClass = class of TCnBaseCodingToolset;

{ TCnCodingToolsetWizard }

  TCnCodingToolsetWizard = class(TCnSubMenuWizard)
  private
    FConfigIndex: Integer;
    FEditorIndex: Integer;
    FEditorTools: TList;
    procedure UpdateActions;
    function GetEditorTools(Index: Integer): TCnBaseCodingToolset;
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
    procedure ClearSubActions; override;
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
    property EditorTools[Index: Integer]: TCnBaseCodingToolset read GetEditorTools;
    property EditorToolCount: Integer read GetEditorToolCount;
  end;

procedure RegisterCnCodingToolset(const AClass: TCnCodingToolsetClass);
{* 注册一个 CnCodingToolset 编码工具类引用，每个编码工具类实现单元
   应在该单元的 initialization 节调用该过程注册编码工具类}

function GetCnCodingToolsetClass(const ClassName: string): TCnCodingToolsetClass;
{* 根据编码工具类名取指定的编码工具类引用}

function GetCnCodingToolsetClassCount: Integer;
{* 返回已注册的编码工具类总数}

function GetCnCodingToolsetClassByIndex(const Index: Integer): TCnCodingToolsetClass;
{* 根据索引号取指定的编码工具类引用}

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizOptions, CnWizUtils, CnWizShortCut, CnCommon, CnWizCommentFrm;

{$R *.DFM}

type
  TControlHack = class(TControl);

var
  CnCodingToolsetClassList: TList = nil; // 编辑器工具类引用列表

// 注册一个 CnCodingToolset 编辑器工具类引用
procedure RegisterCnCodingToolset(const AClass: TCnCodingToolsetClass);
begin
  Assert(CnCodingToolsetClassList <> nil, 'CnEditorClassList is nil!');
  if CnCodingToolsetClassList.IndexOf(AClass) < 0 then
    CnCodingToolsetClassList.Add(AClass);
end;

// 根据编辑器工具类名取指定的编辑器工具类引用
function GetCnCodingToolsetClass(const ClassName: string): TCnCodingToolsetClass;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to CnCodingToolsetClassList.Count - 1 do
  begin
    Result := CnCodingToolsetClassList[I];
    if Result.ClassNameIs(ClassName) then Exit;
  end;
end;

// 返回已注册的编辑器工具类总数
function GetCnCodingToolsetClassCount: Integer;
begin
  Result := CnCodingToolsetClassList.Count;
end;

// 根据索引号取指定的编辑器工具类引用
function GetCnCodingToolsetClassByIndex(const Index: Integer): TCnCodingToolsetClass;
begin
  Result := nil;
  if (Index >= 0) and (Index <= CnCodingToolsetClassList.Count - 1) then
    Result := CnCodingToolsetClassList[Index];
end;

{ TCnBaseEditorTool }

procedure TCnBaseCodingToolset.Config;
begin

end;

constructor TCnBaseCodingToolset.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited Create;
  Assert(Assigned(AOwner));
  FOwner := AOwner;
  FActive := True;
  FAction := nil;
end;

function TCnBaseCodingToolset.CreateIniFile: TCustomIniFile;
begin
  if FDefaultsMap = nil then
    FDefaultsMap := TCnStrToVariantHashMap.Create;

  Result := TCnWizIniFile.Create(MakePath(WizOptions.RegPath) + Owner.GetIDStr +
    '\' + GetIDStr, KEY_ALL_ACCESS, FDefaultsMap);
end;

destructor TCnBaseCodingToolset.Destroy;
begin
  FDefaultsMap.Free;
  inherited;
end;

procedure TCnBaseCodingToolset.Loaded;
begin

end;

procedure TCnBaseCodingToolset.LoadSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    ReadObject('', Self);
  finally
    Free;
  end;   
end;

procedure TCnBaseCodingToolset.SaveSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteObject('', Self);
  finally
    Free;
  end;   
end;

function TCnBaseCodingToolset.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnBaseCodingToolset.GetIDStr: string;
begin
  Result := ClassName;
  if UpperCase(Result[1]) = 'T' then
    Delete(Result, 1, 1);
end;

function TCnBaseCodingToolset.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnBaseCodingToolset.GetHint: string;
begin
  Result := '';
end;

function TCnBaseCodingToolset.GetToolsetName: string;
var
  Author, Email: string;
begin
  GetToolsetInfo(Result, Author, Email);
end;

function TCnBaseCodingToolset.GetState: TWizardState;
begin
  if Owner.Active and Active then
    Result := [wsEnabled]
  else
    Result := [];
end;

procedure TCnBaseCodingToolset.SetActive(Value: Boolean);
begin
  FActive := Value;
end;

procedure TCnBaseCodingToolset.RefreshAction;
begin
  if FAction <> nil then
  begin
    FAction.Caption := GetCaption;
    FAction.Hint := GetHint;
  end;
end;

procedure TCnBaseCodingToolset.ParentActiveChanged(ParentActive: Boolean);
begin

end;

{ TCnCodingToolsetWizard }

procedure TCnCodingToolsetWizard.Config;
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

constructor TCnCodingToolsetWizard.Create;
var
  I: Integer;
  Editor: TCnBaseCodingToolset;
  ActiveIni: TCustomIniFile;
begin
  inherited;
  FEditorTools := TList.Create;
  ActiveIni := CreateIniFile;
  try
    Editor := nil;
    for I := 0 to GetCnCodingToolsetClassCount - 1 do
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('EditorTool Creating: ' + GetCnCodingToolsetClassByIndex(I).ClassName);
    {$ENDIF}
      try
        Editor := GetCnCodingToolsetClassByIndex(I).Create(Self);
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
      CnDebugger.LogMsg('EditorTool Created: ' + GetCnCodingToolsetClassByIndex(I).ClassName);
    {$ENDIF}
    end;
  finally
    ActiveIni.Free;
  end;
end;

destructor TCnCodingToolsetWizard.Destroy;
var
  I: Integer;
  ActiveIni: TCustomIniFile;
begin
  ActiveIni := CreateIniFile;
  try
    for I := 0 to EditorToolCount - 1 do
    with EditorTools[I] do
    begin
      ActiveIni.WriteBool(SCnActiveSection, GetIDStr, Active);
      Free;
    end;
  finally
    ActiveIni.Free;
  end;
  FreeAndNil(FEditorTools);
  inherited;
end;

procedure TCnCodingToolsetWizard.Execute;
begin

end;

procedure TCnCodingToolsetWizard.Loaded;
var
  I: Integer;
begin
  inherited;
  for I := 0 to EditorToolCount - 1 do
    EditorTools[I].Loaded;
end;

function TCnCodingToolsetWizard.GetCaption: string;
begin
  Result := SCnCodingToolsetWizardMenuCaption;
end;

function TCnCodingToolsetWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnCodingToolsetWizard.GetHint: string;
begin
  Result := SCnCodingToolsetWizardMenuHint;
end;

function TCnCodingToolsetWizard.GetState: TWizardState;
begin
  if Active then 
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnCodingToolsetWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnCodingToolsetWizardName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnCodingToolsetWizardComment;
end;

function TCnCodingToolsetWizard.GetEditorTools(Index: Integer): TCnBaseCodingToolset;
begin
  Result := TCnBaseCodingToolset(FEditorTools[Index]);
end;

function TCnCodingToolsetWizard.GetEditorToolCount: Integer;
begin
  Result := FEditorTools.Count;
end;

procedure TCnCodingToolsetWizard.LoadSettings(Ini: TCustomIniFile);
var
  I: Integer;
  AIni: TCustomIniFile;
begin
  inherited;

  for I := 0 to EditorToolCount - 1 do
  begin
    AIni := EditorTools[I].CreateIniFile;
    try
      EditorTools[I].LoadSettings(AIni);
    finally
      AIni.Free;
    end;
  end;
end;

procedure TCnCodingToolsetWizard.SaveSettings(Ini: TCustomIniFile);
var
  I: Integer;
  AIni: TCustomIniFile;
begin
  inherited;

  for I := 0 to EditorToolCount - 1 do
  begin
    AIni := EditorTools[I].CreateIniFile;
    try
      EditorTools[I].SaveSettings(AIni);
    finally
      AIni.Free;
    end;
  end;
end;

procedure TCnCodingToolsetWizard.SubActionExecute(Index: Integer);
var
  I: Integer;
begin
  inherited;
  if Index = FConfigIndex then
  begin
    Config;
  end
  else
  begin
    for I := 0 to EditorToolCount - 1 do
    begin
      with EditorTools[I] do
      begin
        if Active and (FAction = SubActions[Index]) then
        begin
          Execute;
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TCnCodingToolsetWizard.SubActionUpdate(Index: Integer);
var
  I: Integer;
  State: TWizardState;
begin
  for I := 0 to EditorToolCount - 1 do
  begin
    if EditorTools[I].FAction = SubActions[Index] then
    begin
      State := EditorTools[I].GetState;
      SubActions[Index].Visible := Active and EditorTools[I].Active;
      SubActions[Index].Enabled := Action.Enabled and (wsEnabled in State);
      SubActions[Index].Checked := wsChecked in State;
      Exit;
    end;
  end;
  inherited;
end;

procedure TCnCodingToolsetWizard.AcquireSubActions;
var
  I, Idx: Integer;
begin
  WizShortCutMgr.BeginUpdate;
  try
    FConfigIndex := RegisterASubAction(SCnCodingToolsetWizardConfigName,
      SCnCodingToolsetWizardConfigCaption, 0, SCnCodingToolsetWizardConfigHint,
      SCnCodingToolsetWizardConfigName);
    if EditorToolCount > 0 then
      AddSepMenu;
    FEditorIndex := FConfigIndex + 1;

    for I := 0 to EditorToolCount - 1 do
    begin
      with EditorTools[I] do
      begin
        Idx := RegisterASubAction(GetIDStr, GetCaption, GetDefShortCut, GetHint);
        FAction := SubActions[Idx];
        FAction.Visible := Self.Active and Active;
      end;
    end;
  finally
    WizShortCutMgr.EndUpdate;
  end;
  UpdateActions;
end;

procedure TCnCodingToolsetWizard.RefreshSubActions;
var
  I: Integer;
begin // 处理方法有稍许不同，因此不能 inherited 来用 AcquireSubActions。
  for I := 0 to GetEditorToolCount - 1 do
    EditorTools[I].RefreshAction;

  inherited;
  UpdateActions;
end;

procedure TCnCodingToolsetWizard.UpdateActions;
var
  I: Integer;
begin
  for I := 0 to EditorToolCount - 1 do
  begin
    if EditorTools[I].FAction <> nil then
      EditorTools[I].FAction.Visible := Active and EditorTools[I].Active;
  end;
end;

procedure TCnCodingToolsetWizard.SetActive(Value: Boolean);
var
  I: Integer;
  Old: Boolean;
begin
  Old := Active;
  inherited;
  if Value <> Old then
  begin
    for I := 0 to EditorToolCount - 1 do
      EditorTools[I].ParentActiveChanged(Active);
  end;
end;

procedure TCnCodingToolsetWizard.ClearSubActions;
var
  I: Integer;
begin
  inherited;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnCodingToolsetWizard.ClearSubActions');
{$ENDIF}
  // 清除 Action 时要清除引用
  if FEditorTools <> nil then
  begin
    for I := 0 to GetEditorToolCount - 1 do
      EditorTools[I].FAction := nil;
  end;
end;

{ TCnEditorToolsForm }

procedure TCnEditorToolsForm.FormCreate(Sender: TObject);
begin
  FWizard := TCnCodingToolsetWizard(CnWizardMgr.WizardByClass(TCnCodingToolsetWizard));
  Assert(Assigned(FWizard));
  EnlargeListViewColumns(lvTools);
  InitTools;
end;

procedure TCnEditorToolsForm.UpdateToolItem(Index: Integer);
var
  AName, AAuthor, AEmail: string;
begin
  with lvTools.Items[Index] do
  begin
    FWizard.EditorTools[Index].GetToolsetInfo(AName, AAuthor, AEmail);
    Caption := AName;
    SubItems.Clear;
    if FWizard.EditorTools[Index].Active then
      SubItems.Add(SCnEnabled)
    else
      SubItems.Add(SCnDisabled);

    if FWizard.EditorTools[Index].FAction <> nil then
      SubItems.Add(ShortCutToText(FWizard.EditorTools[Index].FAction.ShortCut));
  end;
end;

procedure TCnEditorToolsForm.InitTools;
var
  I: Integer;
begin
  lvTools.Items.Clear;
  for I := 0 to FWizard.EditorToolCount - 1 do
  begin
    lvTools.Items.Add;
    UpdateToolItem(I);
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
  if CheckQueryShortCutDuplicated(HotKey.HotKey,
    FWizard.EditorTools[Idx].FAction) <> sdDuplicatedStop then
  begin
    if FWizard.EditorTools[Idx].FAction <> nil then
      FWizard.EditorTools[Idx].FAction.ShortCut := HotKey.HotKey;
    UpdateToolItem(Idx);
  end;
end;

procedure TCnEditorToolsForm.chkEnabledClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then
    Exit;
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
  Result := 'CnCodingToolsetWizard';
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
    FWizard.EditorTools[Idx].GetToolsetInfo(AName, AAuthor, AEmail);

    // Action.Icon 改为 16x16 后，不能再直接 Assign 了否则过小，需放大绘制
    imgIcon.Canvas.Brush.Style := bsSolid;
    imgIcon.Canvas.Brush.Color := TControlHack(imgIcon.Parent).Color;
    imgIcon.Canvas.FillRect(Rect(0, 0, imgIcon.Width, imgIcon.Height));

    if FWizard.EditorTools[Idx].FAction <> nil then
    DrawIconEx(imgIcon.Canvas.Handle, 0, 0, FWizard.EditorTools[Idx].FAction.Icon.Handle,
      imgIcon.Width, imgIcon.Height, 0, 0, DI_NORMAL);

    lblToolName.Caption := AName;
    lblToolAuthor.Caption := CnAuthorEmailToStr(AAuthor, AEmail);

    if FWizard.EditorTools[Idx].FAction <> nil then
      HotKey.HotKey := FWizard.EditorTools[Idx].FAction.ShortCut
    else
      HotKey.HotKey := 0;

    chkEnabled.Checked := FWizard.EditorTools[Idx].Active;
    btnConfig.Visible := FWizard.EditorTools[Idx].HasConfig;
    mmoComment.Lines.Text := GetCommandComment(FWizard.EditorTools[Idx].GetIDStr);
  end
end;

initialization
  CnCodingToolsetClassList := TList.Create;
  RegisterCnWizard(TCnCodingToolsetWizard); // 注册专家

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnCodingToolsetWizard finalization.');
{$ENDIF}

  FreeAndNil(CnCodingToolsetClassList);

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnCodingToolsetWizard finalization.');
{$ENDIF}

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
