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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnDebugEnhancements;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：调试功能扩展单元
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：
* 开发平台：PWin7Pro + Delphi 10.3
* 兼容测试：暂无
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2023.09.05 V1.0
*               实现单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNDEBUGENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ToolWin,
  Dialogs, IniFiles, ComCtrls, StdCtrls, ToolsAPI, Contnrs, ActnList, CnConsts,
  CnHashMap, CnWizConsts, CnWizClasses, CnWizOptions, CnWizDebuggerNotifier,
  CnDataSetVisualizer, CnStringsVisualizer, CnBytesVisualizer, CnWizMultiLang,
  CnWizShareImages, CnWizUtils, CnWizNotifier, CnActionListHook;

type
  TCnDebugEnhanceWizard = class(TCnSubMenuWizard)
  private
    FIdEvalObj: Integer;
    FIdEvalAsStrings: Integer;
    FIdEvalAsBytes: Integer;
    FIdEvalAsDataSet: Integer;
    FIdConfig: Integer;
    FAutoClose: Boolean;
    FAutoReset: Boolean;
    FResetAction: TAction;
    FHooks: TCnActionListHook;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    FReplaceManager: IOTADebuggerVisualizerValueReplacer;
    FDataSetViewer: IOTADebuggerVisualizer;
    FDataSetRegistered: Boolean;
    FEnableDataSet: Boolean;
    FStringsViewer: IOTADebuggerVisualizer;
    FStringsRegistered: Boolean;
    FEnableStrings: Boolean;
    FBytesViewer: IOTADebuggerVisualizer;
    FBytesRegistered: Boolean;
    FEnableBytes: Boolean;
    procedure SetEnableDataSet(const Value: Boolean);
    procedure SetEnableStrings(const Value: Boolean);
    procedure SetEnableBytes(const Value: Boolean);
    procedure CheckViewersRegistration;
{$ENDIF}
    procedure BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean;
      var Cancel: Boolean);
    procedure UpdateHooks;
    procedure EnableHooks;
    procedure DisableHooks;
    procedure SetAutoReset(const Value: Boolean);
    procedure NewExecute(Sender: TObject);
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;

    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;

    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;

    function GetCaption: string; override;
    function GetHint: string; override;
    procedure Config; override;

    procedure AcquireSubActions; override;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    property EnableDataSet: Boolean read FEnableDataSet write SetEnableDataSet;
    {* 是否启用 DataSet Viewer}
    property EnableStrings: Boolean read FEnableStrings write SetEnableStrings;
    {* 是否启用 Strings Viewer}
    property EnableBytes: Boolean read FEnableBytes write SetEnableBytes;
    {* 是否启用 Strings Viewer}
 {$ENDIF}
    procedure DebugComand(Cmds: TStrings; Results: TStrings); override;

    property AutoClose: Boolean read FAutoClose write FAutoClose;
    {* 编译前是否自动杀掉在运行的目标进程，需是独立运行的 Exe}
    property AutoReset: Boolean read FAutoReset write SetAutoReset;
    {* 编译前是否自动关闭在调试的目标进程，需是非独立运行的 Exe}
  end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

  TCnDebuggerBaseValueReplacer = class(TObject)
  {* 封装的 ValueReplacer 单类型替换型基类，简化了一些内部操作}
  private
    FActive: Boolean;
  protected
    function GetEvalType: string; virtual; abstract;
    {* 返回支持的类型名，带 T 前缀}
    function GetNewExpression(const Expression, TypeName,
      OldEvalResult: string): string; virtual; abstract;
    {* 重新求值前调用，让子类给出新表达式供重新求值}
    function GetFinalResult(const OldExpression, TypeName, OldEvalResult,
      NewEvalResult: string): string; virtual;
    {* 重新求值成功后调用，给子类一个调整显示的机会。默认实现是“旧: 新”}
  public
    property Active: Boolean read FActive write FActive;
    {* 是否启用}
  end;

  TCnDebuggerBaseValueReplacerClass = class of TCnDebuggerBaseValueReplacer;

  TCnDebuggerValueReplaceManager = class(TInterfacedObject, IOTADebuggerVisualizerValueReplacer)
  {* 所有单类型调试值替换类的管理类，自身聚合成单个类注册至 Delphi}
  private
    FWizard: TCnDebugEnhanceWizard;
    FReplaceItems: TStringList;
    FReplacers: TObjectList;
    FMap: TCnStrToPtrHashMap;
    FEvaluator: TCnRemoteProcessEvaluator;
  protected
    procedure CreateVisualizers;
  public
    constructor Create(AWizard: TCnDebugEnhanceWizard);
    destructor Destroy; override;

    procedure LoadSettings;
    {* 装载设置}
    procedure SaveSettings;
    {* 保存设置}
    procedure ResetSettings;
    {* 重置设置}

    // IOTADebuggerVisualizer
    function GetSupportedTypeCount: Integer;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean); overload;
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;

    // IOTADebuggerVisualizerValueReplacer
    function GetReplacementValue(const Expression, TypeName, EvalResult: string): string;

    property ReplaceItems: TStringList read FReplaceItems;
  end;

{$ENDIF}

  TCnDebugEnhanceForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pgc1: TPageControl;
    tsDebugHint: TTabSheet;
    lblEnhanceHint: TLabel;
    lvReplacers: TListView;
    actlstDebug: TActionList;
    actAddHint: TAction;
    actRemoveHint: TAction;
    tlbHint: TToolBar;
    btnAddHint: TToolButton;
    btnRemoveHint: TToolButton;
    tsViewer: TTabSheet;
    grpExternalViewer: TGroupBox;
    chkDataSetViewer: TCheckBox;
    tsOthers: TTabSheet;
    grpOthers: TGroupBox;
    chkAutoClose: TCheckBox;
    chkAutoReset: TCheckBox;
    chkStringsViewer: TCheckBox;
    chkBytesViewer: TCheckBox;
    lblHint: TLabel;
    procedure actRemoveHintExecute(Sender: TObject);
    procedure actlstDebugUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure actAddHintExecute(Sender: TObject);
    procedure lvReplacersDblClick(Sender: TObject);
  private

  public
    procedure LoadReplacersFromStrings(List: TStringList);
    procedure SaveReplacersToStrings(List: TStringList);
  end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
{* 供外界的 TCnDebuggerBaseValueReplacer 子类注册，实现针对特定类型的调试期显示内容的值的替换}

{$ENDIF}

{$ENDIF CNWIZARDS_CNDEBUGENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNDEBUGENHANCEWIZARD}

{$R *.DFM}

uses
  CnCommon, CnRemoteInspector {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  csAutoClose = 'AutoClose';
  csAutoReset = 'AutoReset';

  SCnRunResetActionName = 'RunResetCommand';
  SCnCompileActionNames: array[0..4] of string = ('ProjectCompileCommand',
    'ProjectBuildCommand', 'ProjectSyntaxCommand', 'ProjectCompileAllCommand',
    'ProjectBuildAllCommand'
  );
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  csEnableDataSet = 'EnableDataSet';
  csEnableStrings = 'EnableStrings';
  csEnableBytes = 'EnableBytes';

var
  FDebuggerValueReplacerClass: TList = nil;

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
begin
  if FDebuggerValueReplacerClass.IndexOf(ReplacerClass) < 0 then
    FDebuggerValueReplacerClass.Add(ReplacerClass);
end;

{$ENDIF}

{ TCnDebugEnhanceWizard }

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

procedure TCnDebugEnhanceWizard.SetEnableDataSet(const Value: Boolean);
begin
  FEnableDataSet := Value;
  CheckViewersRegistration;
end;

procedure TCnDebugEnhanceWizard.SetEnableStrings(const Value: Boolean);
begin
  FEnableStrings := Value;
  CheckViewersRegistration;
end;

procedure TCnDebugEnhanceWizard.SetEnableBytes(const Value: Boolean);
begin
  FEnableBytes := Value;
  CheckViewersRegistration;
end;

procedure TCnDebugEnhanceWizard.CheckViewersRegistration;
var
  ID: IOTADebuggerServices;
begin
  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  if Active then
  begin
    if FEnableDataSet then
    begin
      if not FDataSetRegistered then
      begin
        ID.RegisterDebugVisualizer(FDataSetViewer);
        FDataSetRegistered := True;
      end;
    end;
    if FEnableStrings then
    begin
      if not FStringsRegistered then
      begin
        ID.RegisterDebugVisualizer(FStringsViewer);
        FStringsRegistered := True;
      end;
    end;
{$IFDEF IDE_HAS_MEMORY_VISUALIZAER}
    if FEnableBytes then
    begin
      if not FBytesRegistered then
      begin
        ID.RegisterDebugVisualizer(FBytesViewer);
        FBytesRegistered := True;
      end;
    end;
{$ENDIF}
  end
  else
  begin
    if FDataSetRegistered then
    begin
      ID.UnregisterDebugVisualizer(FDataSetViewer);
      FDataSetRegistered := False;
    end;
    if FStringsRegistered then
    begin
      ID.UnregisterDebugVisualizer(FStringsViewer);
      FStringsRegistered := False;
    end;
{$IFDEF IDE_HAS_MEMORY_VISUALIZAER}
    if FBytesRegistered then
    begin
      ID.UnregisterDebugVisualizer(FBytesViewer);
      FBytesRegistered := False;
    end;
{$ENDIF}
  end;
end;

{$ENDIF}

procedure TCnDebugEnhanceWizard.Config;
begin
  with TCnDebugEnhanceForm.Create(nil) do
  begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    LoadReplacersFromStrings((FReplaceManager as TCnDebuggerValueReplaceManager).ReplaceItems);
    chkDataSetViewer.Checked := FEnableDataSet;
    chkStringsViewer.Checked := FEnableStrings;
    chkStringsViewer.Visible := False; // IDE 自带了，也没法替换，先隐藏不让设置
    chkBytesViewer.Checked := FEnableBytes;
  {$IFDEF IDE_HAS_MEMORY_VISUALIZAER}  // 高版本 IDE 自带，先不替换，禁用
    chkBytesViewer.Checked := False;
    chkBytesViewer.Enabled := False;
  {$ELSE}
    chkBytesViewer.Checked := FEnableBytes;
  {$ENDIF}
{$ELSE}
    lblEnhanceHint.Enabled := False;
    lvReplacers.Enabled := False;
    grpExternalViewer.Enabled := False;
    chkDataSetViewer.Enabled := False;
    chkStringsViewer.Enabled := False;
    chkBytesViewer.Enabled := False;
{$ENDIF}
    chkAutoClose.Checked := AutoClose;
    chkAutoReset.Checked := AutoReset;

    if ShowModal = mrOK then
    begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
      EnableDataSet := chkDataSetViewer.Checked;
      EnableStrings := chkStringsViewer.Checked;
      EnableBytes := chkBytesViewer.Checked;
      SaveReplacersToStrings((FReplaceManager as TCnDebuggerValueReplaceManager).ReplaceItems);
{$ENDIF}
      AutoClose := chkAutoClose.Checked;
      AutoReset := chkAutoReset.Checked;
      DoSaveSettings;
    end;
    Free;
  end;
end;

constructor TCnDebugEnhanceWizard.Create;
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FReplaceManager := TCnDebuggerValueReplaceManager.Create(Self);
  FDataSetViewer := TCnDebuggerDataSetVisualizer.Create;
  FStringsViewer := TCnDebuggerStringsVisualizer.Create;
  FBytesViewer := TCnDebuggerBytesVisualizer.Create;
{$ENDIF}

  FHooks := TCnActionListHook.Create(nil);
  FResetAction := TAction(GetIDEActionFromName(SCnRunResetActionName));
  CnWizNotifierServices.AddBeforeCompileNotifier(BeforeCompile);
end;

procedure TCnDebugEnhanceWizard.DebugComand(Cmds, Results: TStrings);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  Mgr: TCnDebuggerValueReplaceManager;
{$ENDIF}
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  Mgr := FReplaceManager as TCnDebuggerValueReplaceManager;
  Results.Add('Replace Item Count: ' + IntToStr(Mgr.FReplaceItems.Count));
  Results.AddStrings(Mgr.FReplaceItems);
{$ENDIF}
end;

destructor TCnDebugEnhanceWizard.Destroy;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  ID: IOTADebuggerServices;
{$ENDIF}
begin
  CnWizNotifierServices.RemoveBeforeCompileNotifier(BeforeCompile);
  FHooks.Free;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  if Active then
  begin
    if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
      Exit;

    ID.UnregisterDebugVisualizer(FReplaceManager);

    if FDataSetRegistered then
      ID.UnregisterDebugVisualizer(FDataSetViewer);
    if FStringsRegistered then
      ID.UnregisterDebugVisualizer(FStringsViewer);
    if FBytesRegistered then
      ID.UnregisterDebugVisualizer(FBytesViewer);
  end;

  FReplaceManager := nil;
  FDataSetViewer := nil;
  FStringsViewer := nil;
  FBytesViewer := nil;
{$ENDIF}
  inherited;
end;

function TCnDebugEnhanceWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnDebugEnhanceWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := SCnDebugEnhanceWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnDebugEnhanceWizardComment;
end;

procedure TCnDebugEnhanceWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  (FReplaceManager as TCnDebuggerValueReplaceManager).LoadSettings;
  EnableDataSet := Ini.ReadBool('', csEnableDataSet, True);
  EnableStrings := Ini.ReadBool('', csEnableStrings, False); // IDE 自带了，也没法替换
{$IFDEF IDE_HAS_MEMORY_VISUALIZAER}
  EnableBytes := Ini.ReadBool('', csEnableBytes, False);     // 高版本 IDE 自带
{$ELSE}
  EnableBytes := Ini.ReadBool('', csEnableBytes, True);
{$ENDIF}
{$ENDIF}
  AutoClose := Ini.ReadBool('', csAutoClose, False);
  AutoReset := Ini.ReadBool('', csAutoReset, False);
end;

procedure TCnDebugEnhanceWizard.ResetSettings(Ini: TCustomIniFile);
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  (FReplaceManager as TCnDebuggerValueReplaceManager).ResetSettings;
{$ENDIF}
end;

procedure TCnDebugEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  (FReplaceManager as TCnDebuggerValueReplaceManager).SaveSettings;
  Ini.WriteBool('', csEnableDataSet, FEnableDataSet);
  Ini.WriteBool('', csEnableStrings, FEnableStrings);
  Ini.WriteBool('', csEnableBytes, FEnableBytes);
{$ENDIF}
  Ini.WriteBool('', csAutoClose, FAutoClose);
  Ini.WriteBool('', csAutoReset, FAutoReset);
end;

procedure TCnDebugEnhanceWizard.SetActive(Value: Boolean);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  ID: IOTADebuggerServices;
{$ENDIF}
begin
  inherited;
  UpdateHooks;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  CheckViewersRegistration;
  if Active then
  begin
    ID.RegisterDebugVisualizer(FReplaceManager);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnDebugEnhanceWizard Register Viewers');
{$ENDIF}
  end
  else
  begin
    ID.UnregisterDebugVisualizer(FReplaceManager);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnDebugEnhanceWizard Unregister Viewers');
{$ENDIF}
  end;
{$ENDIF}
end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

{ TCnDebuggerValueReplaceManager }

constructor TCnDebuggerValueReplaceManager.Create(AWizard: TCnDebugEnhanceWizard);
begin
  inherited Create;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager Create');
{$ENDIF}
  FWizard := AWizard;
  FReplaceItems := TStringList.Create;
  FReplacers := TObjectList.Create(True);
  FEvaluator := TCnRemoteProcessEvaluator.Create;
  CreateVisualizers;
end;

destructor TCnDebuggerValueReplaceManager.Destroy;
begin
  FEvaluator.Free;
  FMap.Free;
  FReplaceItems.Free;
  FReplacers.Free;
  inherited;
end;

function TCnDebuggerValueReplaceManager.GetReplacementValue(const Expression,
  TypeName, EvalResult: string): string;
var
  ID: IOTADebuggerServices;
  CP: IOTAProcess;
  CT: IOTAThread;
  S, NewExpr: string;
  P: Pointer;
  Replacer: TCnDebuggerBaseValueReplacer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnDebuggerValueReplacer get %s: %s, Display %s',
    [Expression, TypeName, EvalResult]);
{$ENDIF}
  Result := EvalResult;

  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  CP := ID.CurrentProcess;
  if CP = nil then
    Exit;

  CT := CP.CurrentThread;
  if CT = nil then
    Exit;

  Replacer := nil;
  S := FReplaceItems.Values[TypeName];
  if Length(S) > 0 then
  begin
    // 替换格式字符串有效，该 TypeName 在简单替换的列表中
    if Pos('%s', S) > 0 then
      NewExpr := Format(S, [Expression])
    else
      NewExpr := S;
  end
  else if FMap.Find(TypeName, P) then
  begin
    Replacer := TCnDebuggerBaseValueReplacer(P);
    if Replacer.Active then
      NewExpr := Replacer.GetNewExpression(Expression, TypeName, EvalResult)
    else
      Exit;
  end
  else
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager to Evaluate: ' + NewExpr);
{$ENDIF}

  S := FEvaluator.EvaluateExpression(NewExpr);

  if Replacer <> nil then
    Result := Replacer.GetFinalResult(Expression, TypeName, EvalResult, S)
  else
    Result := EvalResult + ': ' + S;
end;

procedure TCnDebuggerValueReplaceManager.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants: Boolean);
begin
  if Index < FReplaceItems.Count then
    TypeName := FReplaceItems.Names[Index]
  else if Index < FReplaceItems.Count + FReplacers.Count then
    TypeName := (FReplacers[Index] as TCnDebuggerBaseValueReplacer).GetEvalType;

  AllDescendants := False; // 聚合了导致没法支持子类，不知道如何分发
end;

function TCnDebuggerValueReplaceManager.GetSupportedTypeCount: Integer;
begin
  Result := FReplaceItems.Count + FReplacers.Count;
end;

function TCnDebuggerValueReplaceManager.GetVisualizerDescription: string;
begin
  Result := SCnDebugVisualizerDescription;
end;

function TCnDebuggerValueReplaceManager.GetVisualizerIdentifier: string;
begin
  Result := SCnDebugVisualizerIdentifier;
end;

function TCnDebuggerValueReplaceManager.GetVisualizerName: string;
begin
  Result := SCnDebugVisualizerName;
end;

procedure TCnDebuggerValueReplaceManager.CreateVisualizers;
var
  I: Integer;
  Clz: TCnDebuggerBaseValueReplacerClass;
  Obj: TCnDebuggerBaseValueReplacer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager CreateVisualizers');
{$ENDIF}
  for I := 0 to FDebuggerValueReplacerClass.Count - 1 do
  begin
    Clz := TCnDebuggerBaseValueReplacerClass(FDebuggerValueReplacerClass[I]);
    Obj := TCnDebuggerBaseValueReplacer(Clz.NewInstance);
    Obj.Create;
    FReplacers.Add(Obj);
  end;

  FMap := TCnStrToPtrHashMap.Create;
  for I := 0 to FReplacers.Count - 1 do
    FMap.Add((FReplacers[I] as TCnDebuggerBaseValueReplacer).GetEvalType, FReplacers[I]);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager CreateVisualizers OK');
{$ENDIF}
end;

procedure TCnDebuggerValueReplaceManager.LoadSettings;
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnDebugReplacerDataName, True);
  if FileExists(F) then
    FReplaceItems.LoadFromFile(F);
end;

procedure TCnDebuggerValueReplaceManager.ResetSettings;
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnDebugReplacerDataName, False);
  if FileExists(F) then
    DeleteFile(F);
end;

procedure TCnDebuggerValueReplaceManager.SaveSettings;
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnDebugReplacerDataName, False);
  FReplaceItems.SaveToFile(F);
  WizOptions.CheckUserFile(SCnDebugReplacerDataName);
end;

{$ENDIF}

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

{ TCnDebuggerBaseValueReplacer }

function TCnDebuggerBaseValueReplacer.GetFinalResult(const OldExpression,
  TypeName, OldEvalResult, NewEvalResult: string): string;
begin
  Result := OldEvalResult + ': ' + NewEvalResult;
end;

{$ENDIF}

{ TCnDebugEnhanceForm }

procedure TCnDebugEnhanceForm.LoadReplacersFromStrings(List: TStringList);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  I: Integer;
  Item: TListItem;
{$ENDIF}
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  lvReplacers.Items.Clear;
  for I := 0 to List.Count - 1 do
  begin
    Item := lvReplacers.Items.Add;
    Item.Caption := List.Names[I];
    Item.SubItems.Add(List.Values[Item.Caption]);
  end;
{$ENDIF}
end;

procedure TCnDebugEnhanceForm.SaveReplacersToStrings(List: TStringList);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  I: Integer;
{$ENDIF}
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
   List.Clear;
   for I := 0 to lvReplacers.Items.Count - 1 do
     List.Add(lvReplacers.Items[I].Caption + '=' + lvReplacers.Items[I].SubItems[0]);
{$ENDIF}
end;

procedure TCnDebugEnhanceForm.actRemoveHintExecute(Sender: TObject);
begin
  if lvReplacers.Selected <> nil then
    if QueryDlg(SCnDebugRemoveReplacerHint) then
      lvReplacers.Items.Delete(lvReplacers.Selected.Index);
end;

procedure TCnDebugEnhanceForm.actlstDebugUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if Action = actRemoveHint then
    (Action as TCustomAction).Enabled := lvReplacers.Selected <> nil
  else
  begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    (Action as TCustomAction).Enabled := True;
{$ELSE}
    (Action as TCustomAction).Enabled := False;
{$ENDIF}
  end;

  Handled := True;
end;

procedure TCnDebugEnhanceForm.actAddHintExecute(Sender: TObject);
var
  S, S1, S2: string;
  Idx: Integer;
  Item: TListItem;
begin
  S := 'TSample=%s.ToString';
  if CnWizInputQuery(SCnDebugAddReplacerCaption, SCnDebugAddReplacerHint, S) then
  begin
    Idx := Pos('=', S);
    if Idx > 1 then
    begin
      S1 := Copy(S, 1, Idx - 1);
      S2 := Copy(S, Idx + 1, MaxInt);
      if Pos('%s', S2) > 0 then
      begin
        Item := lvReplacers.Items.Add;
        Item.Caption := S1;
        Item.SubItems.Add(S2);
        Exit;
      end;
    end;

    ErrorDlg(SCnDebugErrorReplacerFormat);
  end;
end;

procedure TCnDebugEnhanceForm.lvReplacersDblClick(Sender: TObject);
var
  S, S1, S2: string;
  Idx: Integer;
  Item: TListItem;
begin
  Item := lvReplacers.Selected;
  if Item = nil then
    Exit;

  S := Item.Caption + '=' + Item.SubItems[0];
  if CnWizInputQuery(SCnDebugAddReplacerCaption, SCnDebugAddReplacerHint, S) then
  begin
    Idx := Pos('=', S);
    if Idx > 1 then
    begin
      S1 := Copy(S, 1, Idx - 1);
      S2 := Copy(S, Idx + 1, MaxInt);
      if Pos('%s', S2) > 0 then
      begin
        Item.Caption := S1;
        Item.SubItems[0] := S2;
        Exit;
      end;
    end;

    ErrorDlg(SCnDebugErrorReplacerFormat);
  end;
end;

procedure TCnDebugEnhanceWizard.AcquireSubActions;
begin
  FIdEvalObj := RegisterASubAction('EvalAsObj',
    'Evaluate As Object...', 0, '');

  // 暂时先隐藏
  SubActions[FIdEvalObj].Visible := False;

  FIdEvalAsStrings := RegisterASubAction(SCnDebugEvalAsStrings,
    SCnDebugEvalAsStringsCaption, 0, SCnDebugEvalAsStringsHint);
  FIdEvalAsBytes := RegisterASubAction(SCnDebugEvalAsBytes,
    SCnDebugEvalAsBytesCaption, 0, SCnDebugEvalAsBytesHint);
  FIdEvalAsDataSet := RegisterASubAction(SCnDebugEvalAsDataSet,
    SCnDebugEvalAsDataSetCaption, 0, SCnDebugEvalAsDataSetHint);
  AddSepMenu;
  FIdConfig := RegisterASubAction(SCnDebugConfig, SCnDebugConfigCaption, 0,
    SCnDebugConfigHint);
end;

procedure TCnDebugEnhanceWizard.SubActionExecute(Index: Integer);
var
  S: string;
  I1: Integer;

  function InputExpr: string;
  var
    T: string;
  begin
    Result := '';
    T := Trim(CnOtaGetCurrentSelection);
    if T = '' then
    begin
      CnOtaGetCurrPosToken(T, I1);
      T := Trim(T);
    end;

    if CnWizInputQuery(SCnInformation, SCnDebugEnterExpression, T) then
      Result := Trim(T);
  end;

begin
  if Index = FIdEvalObj then
  begin
    S := InputExpr;
    if S <> '' then
      EvaluateRemoteExpression(S);
  end
  else if Index = FIdEvalAsStrings then
  begin
    S := InputExpr;
    if S <> '' then
      ShowStringsExternalViewer(S);
  end
  else if Index = FIdEvalAsBytes then
  begin
    S := InputExpr;
    if S <> '' then
      ShowBytesExternalViewer(S);
  end
  else if Index = FIdEvalAsDataSet then
  begin
    S := InputExpr;
    if S <> '' then
      ShowDataSetExternalViewer(S);
  end
  else if Index = FIdConfig then
    Config;
end;

procedure TCnDebugEnhanceWizard.SubActionUpdate(Index: Integer);
begin
  if (Index = FIdEvalObj) or (Index = FIdEvalAsDataSet) or (Index = FIdEvalAsStrings)
    or (Index = FIdEvalAsBytes) then
    SubActions[Index].Enabled := CnOtaIsDebugging;
end;

function TCnDebugEnhanceWizard.GetCaption: string;
begin
  Result := SCnDebugEnhanceWizardCaption;
end;

function TCnDebugEnhanceWizard.GetHint: string;
begin
  Result := SCnDebugEnhanceWizardHint;
end;

procedure TCnDebugEnhanceWizard.BeforeCompile(const Project: IOTAProject;
  IsCodeInsight: Boolean; var Cancel: Boolean);
var
  Exe: string;
begin
  if not Active or not AutoClose or IsCodeInsight then
    Exit;

  // 当前工程的可执行文件如果在运行则杀掉
  Exe := CnOtaGetProjectOutputTarget(Project);
  if (Exe <> '') and FileExists(Exe) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnDebugEnhanceWizard.BeforeCompile to Kill: ' + Exe);
{$ENDIF}
    KillProcessByFullFileName(Exe);
  end;
end;

procedure TCnDebugEnhanceWizard.SetAutoReset(const Value: Boolean);
begin
  if FAutoReset <> Value then
  begin
    FAutoReset := Value;
    UpdateHooks;
  end;
end;

procedure TCnDebugEnhanceWizard.DisableHooks;
var
  I: Integer;
  Ast: TActionList;
  Act: TAction;
begin
  Ast := TActionList(GetIDEActionList);
  if (Ast = nil) or not FHooks.IsHooked(Ast) then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebugEnhanceWizard DisableHookes.');
{$ENDIF}

  for I := High(SCnCompileActionNames) downto Low(SCnCompileActionNames) do
  begin
    Act := TAction(GetIDEActionFromName(SCnCompileActionNames[I]));
    if (Act <> nil) and FHooks.IsActionHooked(Act) then
      FHooks.RemoveNotifiler(Act);
  end;
  FHooks.UnHookActionList(Ast);
end;

procedure TCnDebugEnhanceWizard.EnableHooks;
var
  I: Integer;
  Ast: TActionList;
  Act: TAction;
begin
  Ast := TActionList(GetIDEActionList);
  if (Ast = nil) or FHooks.IsHooked(Ast) then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebugEnhanceWizard EnableHookes.');
{$ENDIF}

  FHooks.HookActionList(Ast);
  for I := Low(SCnCompileActionNames) to High(SCnCompileActionNames) do
  begin
    Act := TAction(GetIDEActionFromName(SCnCompileActionNames[I]));
    if (Act <> nil) and not FHooks.IsActionHooked(Act) then
      FHooks.AddActionNotifier(Act, NewExecute, nil);
  end;
end;

procedure TCnDebugEnhanceWizard.UpdateHooks;
begin
  if Active and FAutoReset then
    EnableHooks
  else
    DisableHooks;
end;

procedure TCnDebugEnhanceWizard.NewExecute(Sender: TObject);
var
  Exe: TNotifyEvent;
begin
  if CnOtaIsDebugging and (FResetAction <> nil) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Hooked Actions Enter. Is Debugging. To Reset.');
{$ENDIF}
    FResetAction.Execute;
  end;

  // 找到 Sender 对应的 Action 的 Obj，找到其旧 Execute
  Exe := FHooks.GetActionOldExecute(Sender as TAction);
  if Assigned(Exe) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Hooked Actions Enter. Call Old.');
{$ENDIF}
    Exe(Sender);
  end;
end;

initialization
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FDebuggerValueReplacerClass := TList.Create;
{$ENDIF}

{$IFDEF DELPHI}
  RegisterCnWizard(TCnDebugEnhanceWizard); // BCB 5/6 下调试求值功能不靠谱，不能启用
{$ENDIF}

finalization
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FDebuggerValueReplacerClass.Free;
{$ENDIF}

{$ENDIF CNWIZARDS_CNDEBUGENHANCEWIZARD}
end.
