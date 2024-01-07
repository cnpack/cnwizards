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

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, ComCtrls, StdCtrls, ToolsAPI, Contnrs,
  CnConsts, CnHashMap, CnWizConsts, CnWizClasses, CnWizOptions;

type
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  TCnDebuggerValueReplaceManager = class;
{$ENDIF}

  TCnDebugEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    FReplacer: TCnDebuggerValueReplaceManager;
{$ENDIF}
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class function IsInternalWizard: Boolean; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;

    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;

    procedure Config; override;
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

  TCnDebuggerValueReplaceManager = class(TInterfacedObject, IOTAThreadNotifier,
    IOTADebuggerVisualizerValueReplacer)
  {* 所有单类型调试值替换类的管理类，自身聚合成单个类注册至 Delphi}
  private
    FRes: array[0..2047] of Char;
    FWizard: TCnDebugEnhanceWizard;
    FNotifierIndex: Integer;
    FEvalComplete: Boolean;
    FEvalSuccess: Boolean;
    FCanModify: Boolean;
    FEvalResult: string;
    FReplaceItems: TStringList;
    FReplacers: TObjectList;
    FMap: TCnStrToPtrHashMap;
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

    procedure RegisterToService;
    {* 由外界调用注册至 Delphi}
    procedure UnregisterFromService;
    {* 由外界调用从 Delphi 中反注册}

    // IOTANotifier
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;

    // IOTAThreadNotifier
    procedure ThreadNotify(Reason: TOTANotifyReason);
    procedure EvaluteComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
     procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);

    // IOTADebuggerVisualizer
    function GetSupportedTypeCount: Integer;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean); overload;
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;

    // IOTADebuggerVisualizerValueReplacer
    function GetReplacementValue(const Expression, TypeName, EvalResult: string): string;
  end;

{$ENDIF}

  TCnDebugEnhanceForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pgc1: TPageControl;
    tsDebugHint: TTabSheet;
    lblEnhanceHint: TLabel;
    lvVisualCalls: TListView;
  private

  public

  end;

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
{* 供外界的 TCnDebuggerBaseValueReplacer 子类注册，实现针对特定类型的调试期显示内容的值的替换}

implementation

{$R *.dfm}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

var
  FDebuggerValueReplacerClass: TList = nil;

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
begin
  if FDebuggerValueReplacerClass.IndexOf(ReplacerClass) < 0 then
    FDebuggerValueReplacerClass.Add(ReplacerClass);
end;

{ TCnDebugEnhanceWizard }

procedure TCnDebugEnhanceWizard.Config;
begin
  with TCnDebugEnhanceForm.Create(nil) do
  begin
    if ShowModal = mrOK then
    begin
      DoSaveSettings;
    end;
    Free;
  end;
end;

constructor TCnDebugEnhanceWizard.Create;
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FReplacer := TCnDebuggerValueReplaceManager.Create(Self);

{$ENDIF}
end;

destructor TCnDebugEnhanceWizard.Destroy;
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FReplacer.Free;
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

class function TCnDebugEnhanceWizard.IsInternalWizard: Boolean;
begin
  Result := True;
end;

procedure TCnDebugEnhanceWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FReplacer.LoadSettings;
{$ENDIF}
end;

procedure TCnDebugEnhanceWizard.ResetSettings(Ini: TCustomIniFile);
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FReplacer.ResetSettings;
{$ENDIF}
end;

procedure TCnDebugEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FReplacer.SaveSettings;
{$ENDIF}
end;

procedure TCnDebugEnhanceWizard.SetActive(Value: Boolean);
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  if Active then
    FReplacer.RegisterToService
  else
    FReplacer.UnRegisterFromService;
{$ENDIF}
end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

{ TCnDebuggerValueReplaceManager }

constructor TCnDebuggerValueReplaceManager.Create(AWizard: TCnDebugEnhanceWizard);
begin
  inherited Create;
  FWizard := AWizard;
  FReplaceItems := TStringList.Create;
  CreateVisualizers;
end;

destructor TCnDebuggerValueReplaceManager.Destroy;
begin
  FMap.Free;
  FReplaceItems.Free;
  FReplacers.Free;
  inherited;
end;

function TCnDebuggerValueReplaceManager.GetReplacementValue(const Expression,
  TypeName, EvalResult: string): string;
var
  I: Integer;
  Found: Boolean;
  ID: IOTADebuggerServices;
  CP: IOTAProcess;
  CT: IOTAThread;
  S, NewExpr: string;
  EvalRes: TOTAEvaluateResult;
  ResultAddr: TOTAAddress;
  ResultSize, ResultVal: Cardinal;
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
      NewExpr := Format(S, [TypeName])
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

  EvalRes := CT.Evaluate(NewExpr, @FRes[0], SizeOf(FRes), FCanModify, True,
    '', ResultAddr, ResultSize, ResultVal);

  case EvalRes of
{$IFDEF DEBUG}
    erError: CnDebugger.LogMsg('TCnDebuggerValueReplaceManager Evaluate Error');
    erBusy: CnDebugger.LogMsg('TCnDebuggerValueReplaceManager Evaluate Busy');
{$ENDIF}
    erOK: Result := EvalResult + ': ' + FRes;
    erDeferred:
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnDebuggerValueReplaceManager Evaluate Deferred. Wait for Events.');
{$ENDIF}
        FEvalComplete := False;
        FEvalSuccess := False;
        FEvalResult := '';

        FNotifierIndex := CT.AddNotifier(Self);
        while not FEvalComplete do
          ID.ProcessDebugEvents;
        CT.RemoveNotifier(FNotifierIndex);

        if FEvalSuccess then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('TCnDebuggerValueReplaceManager Evaluate Deferred Success.');
{$ENDIF}
          if Replacer <> nil then
            Result := Replacer.GetFinalResult(Expression, TypeName, EvalResult, FEvalResult)
          else
            Result := EvalResult + ': ' + FEvalResult;
        end;
      end;
  end;
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


procedure TCnDebuggerValueReplaceManager.AfterSave;
begin

end;

procedure TCnDebuggerValueReplaceManager.BeforeSave;
begin

end;

procedure TCnDebuggerValueReplaceManager.Destroyed;
begin

end;

procedure TCnDebuggerValueReplaceManager.EvaluteComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress,
  ResultSize: LongWord; ReturnCode: Integer);
begin
  // Defer 的结果 Evaluate 完毕，如果 ReturnCode 不等于 0，ResultStr 里可能是出错信息
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnDebuggerValueReplacer EvaluteComplete for %s: %d, %s',
    [ExprStr, ReturnCode, ResultStr]);
{$ENDIF}

  FEvalSuccess := ReturnCode = 0;

  if FEvalSuccess then
  begin
    FEvalResult := AnsiDequotedStr(ResultStr, '''');
  end
  else
    FEvalResult := '';

  FEvalComplete := True;
end;

procedure TCnDebuggerValueReplaceManager.Modified;
begin

end;

procedure TCnDebuggerValueReplaceManager.ModifyComplete(const ExprStr,
  ResultStr: string; ReturnCode: Integer);
begin

end;

procedure TCnDebuggerValueReplaceManager.ThreadNotify(Reason: TOTANotifyReason);
begin

end;

{$ENDIF}

procedure TCnDebuggerValueReplaceManager.CreateVisualizers;
var
  I: Integer;
  Clz: TCnDebuggerBaseValueReplacerClass;
  Obj: TCnDebuggerBaseValueReplacer;
begin
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
end;

procedure TCnDebuggerValueReplaceManager.RegisterToService;
var
  ID: IOTADebuggerServices;
begin
  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  ID.RegisterDebugVisualizer(Self as IOTADebuggerVisualizer);
end;

procedure TCnDebuggerValueReplaceManager.UnregisterFromService;
var
  ID: IOTADebuggerServices;
begin
  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  ID.UnRegisterDebugVisualizer(Self as IOTADebuggerVisualizer);
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

{ TCnDebuggerBaseValueReplacer }

function TCnDebuggerBaseValueReplacer.GetFinalResult(const OldExpression,
  TypeName, OldEvalResult, NewEvalResult: string): string;
begin
  Result := OldEvalResult + ': ' + NewEvalResult;
end;

initialization
  FDebuggerValueReplacerClass := TList.Create;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  RegisterCnWizard(TCnDebugEnhanceWizard);
{$ENDIF}

finalization
  FDebuggerValueReplacerClass.Free;

end.
