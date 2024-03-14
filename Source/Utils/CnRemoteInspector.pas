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

unit CnRemoteInspector;
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

uses
  SysUtils, Classes, Windows, CnWizDebuggerNotifier, CnPropSheetFrm;

function EvaluateRemoteExpression(const Expression: string;
  AForm: TCnPropSheetForm = nil; SyncMode: Boolean = True;
  AParentSheet: TCnPropSheetForm = nil): TCnPropSheetForm;
{* 执行被调试的远程进程中的求值查看}

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

type
  TCnRemoteEvaluationInspector = class(TCnObjectInspector)
  private
    FObjectExpr: string;
    FEvaluator: TCnRemoteProcessEvaluator;
  protected
    procedure SetObjectAddr(const Value: Pointer); override;

    procedure DoEvaluate; override;
  public
    constructor Create(Data: Pointer); override;
    destructor Destroy; override;

{$IFDEF SUPPORT_ENHANCED_RTTI}
    function ChangeFieldValue(const FieldName, Value: string;
      FieldObj: TCnFieldObject): Boolean; override;
{$ENDIF}
    function ChangePropertyValue(const PropName, Value: string;
      PropObj: TCnPropertyObject): Boolean; override;

    property ObjectExpr: string read FObjectExpr;
  end;

function EvaluateRemoteExpression(const Expression: string;
  AForm: TCnPropSheetForm; SyncMode: Boolean;
  AParentSheet: TCnPropSheetForm): TCnPropSheetForm;
var
  Eval: TCnRemoteProcessEvaluator;
begin
  Result := nil;
  if Trim(Expression) = '' then Exit;

  if AForm = nil then
    AForm := TCnPropSheetForm.Create(nil);
CnDebugger.LogMsg('EvaluateRemoteExpression 1');
  AForm.ObjectPointer := nil;
  AForm.ObjectExpr := Trim(Expression); // 注意此时 ObjectPointer 必须为 nil，内部判断使用
  AForm.Clear;
  AForm.ParentSheetForm := AParentSheet;
CnDebugger.LogMsg('EvaluateRemoteExpression 2');
  AForm.SyncMode := SyncMode;
  AForm.InspectorClass := TCnRemoteEvaluationInspector;
CnDebugger.LogMsg('EvaluateRemoteExpression 3');

  Eval := TCnRemoteProcessEvaluator.Create;
  if SyncMode then
  begin
    AForm.DoEvaluateBegin;
    try
      AForm.InspectParam := Eval;
      AForm.InspectObject(AForm.InspectParam);
CnDebugger.LogMsg('EvaluateRemoteExpression 4');
    finally
      AForm.DoEvaluateEnd;
      AForm.Show;  // After Evaluation. Show the form.
    end;
  end
  else
    PostMessage(AForm.Handle, CN_INSPECTOBJECT, WParam(Eval), 0);

  Result := AForm;
end;

{ TCnRemoteEvaluationInspector }

{$IFDEF SUPPORT_ENHANCED_RTTI}

function TCnRemoteEvaluationInspector.ChangeFieldValue(const FieldName,
  Value: string; FieldObj: TCnFieldObject): Boolean;
begin

end;

{$ENDIF}

function TCnRemoteEvaluationInspector.ChangePropertyValue(const PropName,
  Value: string; PropObj: TCnPropertyObject): Boolean;
begin

end;

constructor TCnRemoteEvaluationInspector.Create(Data: Pointer);
begin
CnDebugger.LogMsg('TCnRemoteEvaluationInspector.Create');
  inherited Create(Data);
if Data = nil then
  CnDebugger.TraceCurrentStack('Data nil')
else
  CnDebugger.TraceCurrentStack('Data NOT nil');

  FEvaluator := TCnRemoteProcessEvaluator(Data);
end;

destructor TCnRemoteEvaluationInspector.Destroy;
begin
  FEvaluator.Free;
  inherited;
end;

procedure TCnRemoteEvaluationInspector.DoEvaluate;
var
  C, I: Integer;
  V, S: string;
  Hies: TStringList;
  AProp: TCnPropertyObject;
begin
  if FObjectExpr = '' then
  begin
    InspectComplete := True;
    Exit;
  end;

  if not IsRefresh then
  begin
    Properties.Clear;
    Fields.Clear;
    Events.Clear;
    Methods.Clear;
    Components.Clear;
    Controls.Clear;
    CollectionItems.Clear;
    Strings.Clear;
    MenuItems.Clear;
    Graphics.Graphic := nil;
  end;

if FEvaluator = nil then
  CnDebugger.LogMsg('TCnRemoteEvaluationInspector.DoEvaluate 0 nil')
else
  CnDebugger.LogMsg('TCnRemoteEvaluationInspector.DoEvaluate 0');
CnDebugger.LogCurrentStack('Do Eval '+FObjectExpr);

  if not CnWizDebuggerObjectInheritsFrom(FObjectExpr, 'TObject', FEvaluator) then
  begin
    InspectComplete := True;
    Exit;
  end;

CnDebugger.LogMsg('TCnRemoteEvaluationInspector.DoEvaluate 1');
  // 是一个对象，开始求值
  ContentTypes := [pctHierarchy];
  Hies := TStringList.Create;
  try
    V := FObjectExpr;
    while True do
    begin
      S := FEvaluator.EvaluateExpression(V + '.ClassName');
CnDebugger.LogMsg('TCnRemoteEvaluationInspector.DoEvaluate 1' + S);
      if (S = '') or (S = 'nil') then
        Break;

      Hies.Add(S);
      if S = 'TObject' then
        Break;

      V := V + '.ClassParent';
    end;
    Hierarchy := Hies.Text;
CnDebugger.LogMsg('TCnRemoteEvaluationInspector.DoEvaluate 2' + Hies.Text);
  finally
    Hies.Free;
  end;
  DoAfterEvaluateHierarchy;

  if CnWizDebuggerObjectInheritsFrom(FObjectExpr, 'TStrings', FEvaluator) then
  begin
    ContentTypes := ContentTypes + [pctStrings];
    S := FEvaluator.EvaluateExpression('(' + FObjectExpr + ' as TStrings).Text');
    if Strings.DisplayValue <> S then
    begin
      Strings.Changed := True;
      Strings.DisplayValue := S;
    end;
  end;
CnDebugger.LogMsg('TCnRemoteEvaluationInspector.DoEvaluate 3');
//  C := StrToIntDef(CnInProcessEvaluator.EvaluateExpression(
//    Format('GetTypeData(PTypeInfo(%s.ClassInfo))^.PropCount', [FObjectExpr])), 0);
//CnDebugger.LogMsg('TCnRemoteEvaluationInspector.DoEvaluate 4 ' + IntToStr(C));
//  if C > 0 then
//  begin
//
//  end;

{$IFDEF SUPPORT_ENHANCED_RTTI}
  S := FEvaluator.EvaluateExpression(Format('Length(TRttiContext.Create.GetType(%s.ClassInfo).GetProperties)', [FObjectExpr]));
CnDebugger.LogMsg('TCnRemoteEvaluationInspector.DoEvaluate 4 ' + S);

  C := StrToIntDef(S, 0);
  if C > 0 then
  begin
    for I := 0 to C - 1 do
    begin
      S := FEvaluator.EvaluateExpression(Format('TRttiContext.Create.GetType(%s.ClassInfo).GetProperties[%d].PropertyType.TypeKind', [FObjectExpr, I]));
      // 拿到类型名称
      if (S <> 'tkMethod') and (S <> 'tkUnknown') then
      begin
        // 是属性
        V := FEvaluator.EvaluateExpression(Format('TRttiContext.Create.GetType(%s.ClassInfo).GetProperties[%d].Name', [FObjectExpr, I]));

        // V 拿到名称
        if not IsRefresh then
        begin
          AProp := TCnPropertyObject.Create;
          AProp.IsNewRTTI := True;
        end
        else
          AProp := IndexOfProperty(Properties, V);

        AProp.PropName := V;
        // AProp.PropType := S;

        S := FEvaluator.EvaluateExpression(Format('TRttiContext.Create.GetType(%s.ClassInfo).GetProperties[%d].GetValue(%s)', [FObjectExpr, I, FObjectExpr]));
        if S <> AProp.DisplayValue then
        begin
          AProp.DisplayValue := S;
          AProp.Changed := True;
        end
        else
          AProp.Changed := False;

        if not IsRefresh then
          Properties.Add(AProp);

        ContentTypes := ContentTypes + [pctProps];

      end;
    end;
  end;

{$ENDIF}

  InspectComplete := True;
end;

procedure TCnRemoteEvaluationInspector.SetObjectAddr(const Value: Pointer);
var
  L: Integer;
begin
  inherited;
  if Value = nil then
    FObjectExpr := ''
  else
  begin
    L := StrLen(PChar(Value));
    if L > 0 then
    begin
      SetLength(FObjectExpr, L);
      Move(Value^, FObjectExpr[1], L * SizeOf(Char));
    end;
  end;
end;

end.
