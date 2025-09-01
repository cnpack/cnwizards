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

unit CnCodingToolsetWizard;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����빤�߼�ר�ҵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2002.12.03 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, ComCtrls, IniFiles, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF}
  {$IFDEF FPC} LCLProc, CnHotKey, {$ENDIF}
  Registry, CnWizClasses, CnConsts, CnIni, CnWizConsts, CnWizMenuAction,
  ExtCtrls, CnWizMultiLang, CnWizManager, CnHashMap, CnWizIni;

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
    FAction: TCnWizMenuAction;  // �Բ˵� Action ������
    FDefaultsMap: TCnStrToVariantHashMap;
  protected
    function GetIDStr: string;
    procedure SetActive(Value: Boolean); virtual;
    {* Active ����д�������������ظ÷������� Active ���Ա���¼�}
    function GetHasConfig: Boolean; virtual;
    {* HasConfig ���Զ��������������ظ÷��������Ƿ���ڿ���������}
    function GetCaption: string; virtual; abstract;
    {* ���ع��ߵı���}
    function GetHint: string; virtual;
    {* ���ع��ߵ� Hint ��ʾ}
    function GetDefShortCut: TShortCut; virtual;
    {* ���ع��ߵ�Ĭ�Ͽ�ݼ���ʵ��ʹ��ʱ���ߵĿ�ݼ�������ɹ��������趨������
       ֻ��Ҫ����Ĭ�ϵľ����ˡ�}
    function CreateIniFile: TCustomIniFile;
    {* ����һ�����ڴ�ȡ�������ò����� INI �����û�ʹ�ú����Լ��ͷ�}
    property Owner: TCnCodingToolsetWizard read FOwner;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); virtual;
    destructor Destroy; override;

    function GetToolsetName: string;
    {* ���ع�������}
    procedure LoadSettings(Ini: TCustomIniFile); virtual;
    {* װ�ع������÷������������ش˷����� INI �����ж�ȡר�Ҳ���}
    procedure SaveSettings(Ini: TCustomIniFile); virtual;
    {* ���湤�����÷�������������Щ������ר�Ҳ������浽 INI ������}
    function GetState: TWizardState; virtual;
    {* ���ع���״̬��IOTAWizard �������������ظ÷������ع���״̬}
    procedure Execute; virtual; abstract;
    {* ���û�ִ�б�����ʱ�����ø÷���}
    procedure Config; virtual;
    {* ���÷������ɹ����������ý����е��ã��� HasConfig Ϊ��ʱ��Ч}
    procedure Loaded; virtual;
    {* IDE ������ɺ���ø÷���}
    procedure GetToolsetInfo(var Name, Author, Email: string); virtual; abstract;
    {* ȡ������Ϣ�������ṩ���ߵ�˵���Ͱ�Ȩ��Ϣ�����󷽷����������ʵ�֡�
     |<PRE>
       var AName: string      - �������ƣ�������֧�ֱ��ػ����ַ���
       var Author: string     - �������ߣ�����ж�����ߣ��÷ֺŷָ�
       var Email: string      - �����������䣬����ж�����ߣ��÷ֺŷָ�
     |</PRE>}
    procedure RefreshAction; virtual;
    {* ���¸��� Action ������}
    procedure ParentActiveChanged(ParentActive: Boolean); virtual;
    {* �༭��ר��״̬�ı�ʱ������}
    property Active: Boolean read FActive write SetActive;
    {* ��Ծ���ԣ��������ߵ�ǰ�Ƿ����}
    property HasConfig: Boolean read GetHasConfig;
    {* ��ʾ�����Ƿ�������ý��������}
  end;

{$M-}

  TCnCodingToolsetClass = class of TCnBaseCodingToolset;

{ TCnCodingToolsetWizard }

  TCnCodingToolsetWizard = class(TCnSubMenuWizard)
  private
    FConfigIndex: Integer;
    FToolIndex: Integer;
    FCodingTools: TList;
    procedure UpdateActions;
    function GetCodingTools(Index: Integer): TCnBaseCodingToolset;
    function GetCodingToolCount: Integer;
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

    function CodingToolByClass(ToolClass: TCnCodingToolsetClass): TCnBaseCodingToolset;
    {* �������������ӹ���ʵ��}

    property CodingTools[Index: Integer]: TCnBaseCodingToolset read GetCodingTools;
    property CodingToolCount: Integer read GetCodingToolCount;
  end;

procedure RegisterCnCodingToolset(const AClass: TCnCodingToolsetClass);
{* ע��һ�� CnCodingToolset ���빤�������ã�ÿ�����빤����ʵ�ֵ�Ԫ
   Ӧ�ڸõ�Ԫ�� initialization �ڵ��øù���ע����빤����}

function GetCnCodingToolsetClass(const ClassName: string): TCnCodingToolsetClass;
{* ���ݱ��빤������ȡָ���ı��빤��������}

function GetCnCodingToolsetClassCount: Integer;
{* ������ע��ı��빤��������}

function GetCnCodingToolsetClassByIndex(const Index: Integer): TCnCodingToolsetClass;
{* ����������ȡָ���ı��빤��������}

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
  CnCodingToolsetClassList: TList = nil; // �༭�������������б�

// ע��һ�� CnCodingToolset �༭������������
procedure RegisterCnCodingToolset(const AClass: TCnCodingToolsetClass);
begin
  Assert(CnCodingToolsetClassList <> nil, 'CnEditorClassList is nil!');
  if CnCodingToolsetClassList.IndexOf(AClass) < 0 then
    CnCodingToolsetClassList.Add(AClass);
end;

// ���ݱ༭����������ȡָ���ı༭������������
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

// ������ע��ı༭������������
function GetCnCodingToolsetClassCount: Integer;
begin
  Result := CnCodingToolsetClassList.Count;
end;

// ����������ȡָ���ı༭������������
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
  FCodingTools := TList.Create;
  ActiveIni := CreateIniFile;
  try
    Editor := nil;
    for I := 0 to GetCnCodingToolsetClassCount - 1 do
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('CodingTool Creating: ' + GetCnCodingToolsetClassByIndex(I).ClassName);
    {$ENDIF}
      try
        Editor := GetCnCodingToolsetClassByIndex(I).Create(Self);
      except
        on E: Exception do
        begin
          DoHandleException('CodingTool Creating: ' + E.Message);
          Continue;
        end;
      end;
      Editor.Active := ActiveIni.ReadBool(SCnActiveSection,
        Editor.GetIDStr, Editor.Active);
      FCodingTools.Add(Editor);
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('CodingTool Created: ' + GetCnCodingToolsetClassByIndex(I).ClassName);
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
    for I := 0 to CodingToolCount - 1 do
    with CodingTools[I] do
    begin
      ActiveIni.WriteBool(SCnActiveSection, GetIDStr, Active);
      Free;
    end;
  finally
    ActiveIni.Free;
  end;
  FreeAndNil(FCodingTools);
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
  for I := 0 to CodingToolCount - 1 do
    CodingTools[I].Loaded;
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

function TCnCodingToolsetWizard.GetCodingTools(Index: Integer): TCnBaseCodingToolset;
begin
  Result := TCnBaseCodingToolset(FCodingTools[Index]);
end;

function TCnCodingToolsetWizard.GetCodingToolCount: Integer;
begin
  Result := FCodingTools.Count;
end;

procedure TCnCodingToolsetWizard.LoadSettings(Ini: TCustomIniFile);
var
  I: Integer;
  AIni: TCustomIniFile;
begin
  inherited;

  for I := 0 to CodingToolCount - 1 do
  begin
    AIni := CodingTools[I].CreateIniFile;
    try
      CodingTools[I].LoadSettings(AIni);
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

  for I := 0 to CodingToolCount - 1 do
  begin
    AIni := CodingTools[I].CreateIniFile;
    try
      CodingTools[I].SaveSettings(AIni);
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
    for I := 0 to CodingToolCount - 1 do
    begin
      with CodingTools[I] do
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
  for I := 0 to CodingToolCount - 1 do
  begin
    if CodingTools[I].FAction = SubActions[Index] then
    begin
      State := CodingTools[I].GetState;
      SubActions[Index].Visible := Active and CodingTools[I].Active;
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
    if CodingToolCount > 0 then
      AddSepMenu;
    FToolIndex := FConfigIndex + 1;

    for I := 0 to CodingToolCount - 1 do
    begin
      with CodingTools[I] do
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
begin // ������������ͬ����˲��� inherited ���� AcquireSubActions��
  for I := 0 to GetCodingToolCount - 1 do
    CodingTools[I].RefreshAction;

  inherited;
  UpdateActions;
end;

procedure TCnCodingToolsetWizard.UpdateActions;
var
  I: Integer;
begin
  for I := 0 to CodingToolCount - 1 do
  begin
    if CodingTools[I].FAction <> nil then
      CodingTools[I].FAction.Visible := Active and CodingTools[I].Active;
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
    for I := 0 to CodingToolCount - 1 do
      CodingTools[I].ParentActiveChanged(Active);
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
  // ��� Action ʱҪ�������
  if FCodingTools <> nil then
  begin
    for I := 0 to GetCodingToolCount - 1 do
      CodingTools[I].FAction := nil;
  end;
end;

function TCnCodingToolsetWizard.CodingToolByClass(
  ToolClass: TCnCodingToolsetClass): TCnBaseCodingToolset;
var
  I: Integer;
begin
  for I := 0 to GetCodingToolCount - 1 do
  begin
    if CodingTools[I].ClassNameIs(ToolClass.ClassName) then
    begin
      Result := CodingTools[I];
      Exit;
    end;
  end;
  Result := nil;
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
    FWizard.CodingTools[Index].GetToolsetInfo(AName, AAuthor, AEmail);
    Caption := AName;
    SubItems.Clear;
    if FWizard.CodingTools[Index].Active then
      SubItems.Add(SCnEnabled)
    else
      SubItems.Add(SCnDisabled);

    if FWizard.CodingTools[Index].FAction <> nil then
      SubItems.Add(ShortCutToText(FWizard.CodingTools[Index].FAction.ShortCut));
  end;
end;

procedure TCnEditorToolsForm.InitTools;
var
  I: Integer;
begin
  lvTools.Items.Clear;
  for I := 0 to FWizard.CodingToolCount - 1 do
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
    FWizard.CodingTools[Idx].FAction) <> sdDuplicatedStop then
  begin
    if FWizard.CodingTools[Idx].FAction <> nil then
      FWizard.CodingTools[Idx].FAction.ShortCut := HotKey.HotKey;
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
  FWizard.CodingTools[Idx].Active := chkEnabled.Checked;
  UpdateToolItem(Idx);
end;

procedure TCnEditorToolsForm.btnConfigClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then Exit;
  Idx := lvTools.Selected.Index;
  if FWizard.CodingTools[Idx].HasConfig then
    FWizard.CodingTools[Idx].Config;
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
    FWizard.CodingTools[Idx].GetToolsetInfo(AName, AAuthor, AEmail);

    // Action.Icon ��Ϊ 16x16 �󣬲�����ֱ�� Assign �˷����С����Ŵ����
    imgIcon.Canvas.Brush.Style := bsSolid;
    imgIcon.Canvas.Brush.Color := TControlHack(imgIcon.Parent).Color;
    imgIcon.Canvas.FillRect(Rect(0, 0, imgIcon.Width, imgIcon.Height));

    if FWizard.CodingTools[Idx].FAction <> nil then
    DrawIconEx(imgIcon.Canvas.Handle, 0, 0, FWizard.CodingTools[Idx].FAction.Icon.Handle,
      imgIcon.Width, imgIcon.Height, 0, 0, DI_NORMAL);

    lblToolName.Caption := AName;
    lblToolAuthor.Caption := CnAuthorEmailToStr(AAuthor, AEmail);

    if FWizard.CodingTools[Idx].FAction <> nil then
      HotKey.HotKey := FWizard.CodingTools[Idx].FAction.ShortCut
    else
      HotKey.HotKey := 0;

    chkEnabled.Checked := FWizard.CodingTools[Idx].Active;
    btnConfig.Visible := FWizard.CodingTools[Idx].HasConfig;
    mmoComment.Lines.Text := GetCommandComment(FWizard.CodingTools[Idx].GetIDStr);
  end
end;

initialization
  CnCodingToolsetClassList := TList.Create;
  RegisterCnWizard(TCnCodingToolsetWizard); // ע��ר��

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
