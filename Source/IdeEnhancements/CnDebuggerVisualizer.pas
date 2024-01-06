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

unit CnDebuggerVisualizer;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：调试值可视化基类管理单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：Win7 + Delphi XE2
* 兼容测试：Win7/10/11 + Delphi All
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.01.06 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Contnrs, ToolsAPI, CnHashMap;

type
  TCnDebuggerBaseValueReplacer = class(TObject)
  {* 封装的 ValueReplacer 单类型替换型基类，简化了一些内部操作}
  private

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

  end;

  TCnDebuggerBaseValueReplacerClass = class of TCnDebuggerBaseValueReplacer;

  TCnDebuggerValueReplacerManager = class(TInterfacedObject,
    IOTAThreadNotifier, IOTADebuggerVisualizerValueReplacer)
  {* 所有单类型调试值替换类的管理类，自身聚合成单个类注册至 Delphi}
  private
    FRes: array[0..2047] of Char;
    FNotifierIndex: Integer;
    FEvalComplete: Boolean;
    FEvalSuccess: Boolean;
    FCanModify: Boolean;
    FEvalResult: string;
    FReplacers: TObjectList;
    FMap: TCnStrToPtrHashMap;
  protected
    procedure CreateVisualizers;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure RegisterToService;
    {* 由外界调用注册至 Delphi}
    procedure UnregisterFromService;
    {* 由外界调用从 Delphi 中反注册但一般没人调用}

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
      var AllDescendants: Boolean);
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;

    // IOTADebuggerVisualizerValueReplacer
    function GetReplacementValue(const Expression, TypeName, EvalResult: string): string;
  end;

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
{* 供外界的 TCnDebuggerBaseValueReplacer 子类注册，实现针对特定类型的调试期显示内容的值的替换}

implementation

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

{ TCnDebuggerBaseValueReplacer }

function TCnDebuggerBaseValueReplacer.GetFinalResult(const OldExpression, TypeName,
  OldEvalResult, NewEvalResult: string): string;
begin
  Result := OldEvalResult + ': ' + NewEvalResult;
end;

{ TCnDebuggerValueReplacerManager }

procedure TCnDebuggerValueReplacerManager.AfterSave;
begin

end;

procedure TCnDebuggerValueReplacerManager.BeforeSave;
begin

end;

constructor TCnDebuggerValueReplacerManager.Create;
begin
  inherited;
  CreateVisualizers;
end;

procedure TCnDebuggerValueReplacerManager.CreateVisualizers;
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

destructor TCnDebuggerValueReplacerManager.Destroy;
begin
  FMap.Free;
  FReplacers.Free;
  inherited;
end;

procedure TCnDebuggerValueReplacerManager.Destroyed;
begin

end;

procedure TCnDebuggerValueReplacerManager.EvaluteComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress, ResultSize: LongWord;
  ReturnCode: Integer);
begin
  // Defer 的结果 Evaluate 完毕，如果 ReturnCode 不等于 0，ResultStr 里可能是出错信息
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DebuggerVisualizerValueReplacer EvaluteComplete for %s: %d, %s',
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

function TCnDebuggerValueReplacerManager.GetReplacementValue(const Expression,
  TypeName, EvalResult: string): string;
var
  ID: IOTADebuggerServices;
  CP: IOTAProcess;
  CT: IOTAThread;
  NewExpr: string;
  EvalRes: TOTAEvaluateResult;
  ResultAddr: TOTAAddress;
  ResultSize, ResultVal: Cardinal;
  P: Pointer;
  Replacer: TCnDebuggerBaseValueReplacer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DebugValueReplacerManager get %s: %s, Display %s',
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

  if FMap.Find(TypeName, P) then
  begin
    Replacer := TCnDebuggerBaseValueReplacer(P);
    NewExpr := Replacer.GetNewExpression(Expression, TypeName, EvalResult);
  end
  else
    Exit;

  EvalRes := CT.Evaluate(NewExpr, @FRes[0], SizeOf(FRes), FCanModify, True,
    '', ResultAddr, ResultSize, ResultVal);

  case EvalRes of
{$IFDEF DEBUG}
    erError: CnDebugger.LogMsg('DebugValueReplacerManager Evaluate Error');
    erBusy: CnDebugger.LogMsg('DebugValueReplacerManager Evaluate Busy');
{$ENDIF}
    erOK: Result := EvalResult + ': ' + FRes;
    erDeferred:
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('DebugValueReplacerManager Evaluate Deferred. Wait for Events.');
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
          CnDebugger.LogMsg('DebugValueReplacerManager Evaluate Deferred Success.');
{$ENDIF}
          Result := Replacer.GetFinalResult(Expression, TypeName, EvalResult, FEvalResult);
        end;
      end;
  end;
end;

procedure TCnDebuggerValueReplacerManager.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants: Boolean);
begin
  AllDescendants := True;
  TypeName := (FReplacers[Index] as TCnDebuggerBaseValueReplacer).GetEvalType;
end;

function TCnDebuggerValueReplacerManager.GetSupportedTypeCount: Integer;
begin
  Result := FReplacers.Count;
end;

function TCnDebuggerValueReplacerManager.GetVisualizerDescription: string;
begin

end;

function TCnDebuggerValueReplacerManager.GetVisualizerIdentifier: string;
begin
  Result := 'CnWizardsDebugValueReplacer';
end;

function TCnDebuggerValueReplacerManager.GetVisualizerName: string;
begin

end;

procedure TCnDebuggerValueReplacerManager.Modified;
begin

end;

procedure TCnDebuggerValueReplacerManager.ModifyComplete(const ExprStr,
  ResultStr: string; ReturnCode: Integer);
begin

end;

procedure TCnDebuggerValueReplacerManager.RegisterToService;
begin

end;

procedure TCnDebuggerValueReplacerManager.ThreadNotify(Reason: TOTANotifyReason);
begin

end;

procedure TCnDebuggerValueReplacerManager.UnregisterFromService;
begin

end;

initialization
  FDebuggerValueReplacerClass := TList.Create;

finalization
  FDebuggerValueReplacerClass.Free;

end.
