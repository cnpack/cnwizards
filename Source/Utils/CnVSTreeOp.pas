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

unit CnVSTreeOp;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：封装 Delphi 10.3 及以上版本的部分对话框左侧目录树的 TVirtualStringList 操作
* 单元作者：CnPack 开发组
* 备    注：使用新 RTTI，低版本不可用也无需用
* 开发平台：PWin7 + Delphi 10.3
* 兼容测试：Windows + Delphi 10.3 以上版本包括 64 位
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2026.03.28 V1.0
*               实现功能，包括普通文字修改，及 OnGetText 事件响应式文字修改
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, TypInfo, Controls, CnClasses, CnHashMap, CnNative
  {$IFDEF SUPPORT_ENHANCED_RTTI}, Rtti{$ENDIF}, CnEventHook;

type
  TCnVSTNodeProc = procedure(Sender: TObject; Node: Pointer; var CanContinue: Boolean) of object;

  TCnVSTNodeTextProc = procedure(Sender: TObject; Node: Pointer; const Text: string;
    var NewText: string; var UpdateText: Boolean; var CanContinue: Boolean) of object;

  TCnVSTOnGetTextEvent = procedure(Sender: TObject; Node: Pointer; Column: Integer;
    TextType: Integer; var CellText: WideString) of object;
  {* TVirtualStringTree 自己的 OnGetText 事件}

  TCnVSTTranslateTextEvent = procedure(Sender: TObject; const AText: string;
    var ATranslated: string) of object;
  {* 实时翻译回调，用于解决懒加载场景下预遍历时节点为空的问题}

  TCnVSTOnGetTextHook = class
  {* 封装的对 TVirtualStringTree 的 OnGetText 的处理工具类}
  private
    FTree: TComponent;
    FHook: TCnEventHook;
    FFreeNotify: TCnFreeNotificationWrapper;
    FTextMap: TCnStrToStrHashMap;
    FOnTranslateText: TCnVSTTranslateTextEvent;
    function MakeKey(Node: Pointer; Column: Integer): string;
    function FindOverride(Node: Pointer; Column: Integer; out AText: string): Boolean;
    procedure CallOriginalOnGetText(Sender: TObject; Node: Pointer; Column: Integer;
      TextType: Integer; var CellText: WideString);
    procedure DoOnGetText(Sender: TObject; Node: Pointer; Column: Integer;
      TextType: Integer; var CellText: WideString);
  protected
    procedure TreeFreeNotification(Sender: TObject; ACompToFree: TComponent);
  public
    constructor Create(ATree: TComponent);
    destructor Destroy; override;

    function Install: Boolean;
    procedure Uninstall;
    function Hooked: Boolean;
    procedure SetOverrideText(Node: Pointer; Column: Integer; const AText: string);
    procedure RemoveOverrideText(Node: Pointer; Column: Integer);
    procedure ClearOverrideTexts;
    procedure RefreshTree;

    property OnTranslateText: TCnVSTTranslateTextEvent read FOnTranslateText write FOnTranslateText;
    {* 设置实时翻译回调，有此回调时 DoOnGetText 会对原始文本实时翻译，无需预遍历}

    property Tree: TComponent read FTree;
    function TextMapSize: Integer;
  end;

  TCnVSTreeOperator = class
  private
    FTree: TComponent;
{$IFDEF SUPPORT_ENHANCED_RTTI}
    FRttiContext: TRttiContext;
    FRttiType: TRttiType;
    FGetFirstMethod: TRttiMethod;
    FGetNextMethod: TRttiMethod;
    FGetTextMethod: TRttiMethod;
    FSetTextMethod: TRttiMethod;
    FReinitNodeMethod: TRttiMethod;
    FInvalidateNodeMethod: TRttiMethod;
    FTotalCountProperty: TRttiProperty;
    function FindMethod(const AName: string; AParamCount: Integer): TRttiMethod;
    function FindProperty(const AName: string): TRttiProperty;
    function InvokePointerMethod(AMethod: TRttiMethod; const AArgs: array of TValue): Pointer;
    function InvokeStringMethod(AMethod: TRttiMethod; const AArgs: array of TValue): string;
    procedure InvokeProcedure(AMethod: TRttiMethod; const AArgs: array of TValue);
    class function ValueToPointer(const AValue: TValue): Pointer; static;
    class function ValueToCardinal(const AValue: TValue): Cardinal; static;
{$ENDIF}
  public
    constructor Create(ATree: TComponent);
    destructor Destroy; override;

    function IsReady: Boolean;
    function GetTotalCount: Cardinal;
    function GetFirstNode: Pointer;
    function GetNextNode(ANode: Pointer): Pointer;
    function GetNodeText(ANode: Pointer; AColumn: Integer = 0): string;
    function SetNodeText(ANode: Pointer; const AText: string; AColumn: Integer = 0): Boolean;
    procedure TraverseNodes(AProc: TCnVSTNodeProc);
    procedure TraverseNodeTexts(AColumn: Integer; AProc: TCnVSTNodeTextProc);
    property Tree: TComponent read FTree;
  end;

function CnVSTGetTotalNodeCount(ATree: TComponent): Cardinal;

procedure CnVSTTraverseNodeTexts(ATree: TComponent; AColumn: Integer; AProc: TCnVSTNodeTextProc);

function CnVSTHasOnGetTextHandler(ATree: TComponent): Boolean;

function CnVSTProbeOnGetTextSource(ATree: TComponent; AColumn: Integer;
  out BeforeText, AfterText: string): Boolean;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

constructor TCnVSTreeOperator.Create(ATree: TComponent);
begin
  inherited Create;
  FTree := ATree;
{$IFDEF SUPPORT_ENHANCED_RTTI}
  if FTree <> nil then
  begin
    FRttiType := FRttiContext.GetType(FTree.ClassType);
    if FRttiType <> nil then
    begin
      FGetFirstMethod := FindMethod('GetFirst', 0);
      FGetNextMethod := FindMethod('GetNext', 1);
      FGetTextMethod := FindMethod('GetText', 2);
      FSetTextMethod := FindMethod('SetText', 3);
      FReinitNodeMethod := FindMethod('ReinitNode', 2);
      FInvalidateNodeMethod := FindMethod('InvalidateNode', 1);
      FTotalCountProperty := FindProperty('TotalCount');
      if FTotalCountProperty = nil then
        FTotalCountProperty := FindProperty('VisibleCount');
      if FTotalCountProperty = nil then
        FTotalCountProperty := FindProperty('RootNodeCount');
    end;
  end;
{$ENDIF}
end;

destructor TCnVSTreeOperator.Destroy;
begin
{$IFDEF SUPPORT_ENHANCED_RTTI}
  FRttiContext.Free;
{$ENDIF}
  inherited;
end;

function TCnVSTreeOperator.IsReady: Boolean;
begin
{$IFDEF SUPPORT_ENHANCED_RTTI}
  Result := (FTree <> nil) and (FRttiType <> nil) and (FGetFirstMethod <> nil) and
    (FGetNextMethod <> nil) and (FGetTextMethod <> nil) and (FSetTextMethod <> nil);
{$ELSE}
  Result := False;
{$ENDIF}
end;

function TCnVSTreeOperator.GetTotalCount: Cardinal;
begin
  Result := 0;
{$IFDEF SUPPORT_ENHANCED_RTTI}
  if (FTree = nil) or (FTotalCountProperty = nil) then
    Exit;

  Result := ValueToCardinal(FTotalCountProperty.GetValue(FTree));
{$ENDIF}
end;

function TCnVSTreeOperator.GetFirstNode: Pointer;
begin
  Result := nil;
{$IFDEF SUPPORT_ENHANCED_RTTI}
  if (FTree = nil) or (FGetFirstMethod = nil) then
    Exit;

  Result := InvokePointerMethod(FGetFirstMethod, []);
{$ENDIF}
end;

function TCnVSTreeOperator.GetNextNode(ANode: Pointer): Pointer;
begin
  Result := nil;
{$IFDEF SUPPORT_ENHANCED_RTTI}
  if (FTree = nil) or (FGetNextMethod = nil) then
    Exit;

  Result := InvokePointerMethod(FGetNextMethod, [TValue.From<Pointer>(ANode)]);
{$ENDIF}
end;

function TCnVSTreeOperator.GetNodeText(ANode: Pointer; AColumn: Integer): string;
begin
  Result := '';
{$IFDEF SUPPORT_ENHANCED_RTTI}
  if (FTree = nil) or (ANode = nil) or (FGetTextMethod = nil) then
    Exit;

  Result := InvokeStringMethod(FGetTextMethod, [TValue.From<Pointer>(ANode), TValue.From<Integer>(AColumn)]);
{$ENDIF}
end;

function TCnVSTreeOperator.SetNodeText(ANode: Pointer; const AText: string; AColumn: Integer): Boolean;
var
  OldText: string;
  NewText: string;
begin
  Result := False;
{$IFDEF SUPPORT_ENHANCED_RTTI}
  if (FTree = nil) or (ANode = nil) or (FSetTextMethod = nil) then
    Exit;

  OldText := GetNodeText(ANode, AColumn);
  InvokeProcedure(FSetTextMethod, [TValue.From<Pointer>(ANode), TValue.From<Integer>(AColumn), AText]);
  NewText := GetNodeText(ANode, AColumn);
  Result := SameText(NewText, AText);
  if Result then
  begin
    if FReinitNodeMethod <> nil then
      InvokeProcedure(FReinitNodeMethod, [TValue.From<Pointer>(ANode), TValue.From<Boolean>(False)]);
    if FInvalidateNodeMethod <> nil then
      InvokeProcedure(FInvalidateNodeMethod, [TValue.From<Pointer>(ANode)]);
  end;
{$IFDEF DEBUG}
  if (not Result) and (OldText <> AText) then
    CnDebugger.LogMsg(Format('TCnVSTreeOperator.SetNodeText Failed. Old="%s", New="%s".',
      [OldText, AText]));
{$ENDIF}
{$ENDIF}
end;

procedure TCnVSTreeOperator.TraverseNodes(AProc: TCnVSTNodeProc);
var
  Node: Pointer;
  Cont: Boolean;
begin
  if not Assigned(AProc) then
    Exit;

  Node := GetFirstNode;
  Cont := True;
  while (Node <> nil) and Cont do
  begin
    AProc(FTree, Node, Cont);
    if Cont then
      Node := GetNextNode(Node);
  end;
end;

procedure TCnVSTreeOperator.TraverseNodeTexts(AColumn: Integer; AProc: TCnVSTNodeTextProc);
var
  Node: Pointer;
  Cont: Boolean;
  Text: string;
  NewText: string;
  UpdateText: Boolean;
begin
  if not Assigned(AProc) then
    Exit;

  Node := GetFirstNode;
  Cont := True;
  while (Node <> nil) and Cont do
  begin
    Text := GetNodeText(Node, AColumn);
    NewText := '';
    UpdateText := False;
    AProc(FTree, Node, Text, NewText, UpdateText, Cont);

    if UpdateText then
      SetNodeText(Node, NewText, AColumn);
    if Cont then
      Node := GetNextNode(Node);
  end;
end;

function CnVSTGetTotalNodeCount(ATree: TComponent): Cardinal;
var
  Op: TCnVSTreeOperator;
begin
  Op := TCnVSTreeOperator.Create(ATree);
  try
    Result := Op.GetTotalCount;
  finally
    Op.Free;
  end;
end;

procedure CnVSTTraverseNodeTexts(ATree: TComponent; AColumn: Integer; AProc: TCnVSTNodeTextProc);
var
  Op: TCnVSTreeOperator;
begin
  Op := TCnVSTreeOperator.Create(ATree);
  try
    Op.TraverseNodeTexts(AColumn, AProc);
  finally
    Op.Free;
  end;
end;

function CnVSTHasOnGetTextHandler(ATree: TComponent): Boolean;
var
  PropInfo: PPropInfo;
  M: TMethod;
begin
  Result := False;
  if ATree = nil then
    Exit;

  PropInfo := GetPropInfo(ATree.ClassInfo, 'OnGetText');
  if (PropInfo = nil) or (PropInfo^.PropType^.Kind <> tkMethod) then
    Exit;

  M := GetMethodProp(ATree, PropInfo);
  Result := Assigned(M.Code) and Assigned(M.Data);
end;

function CnVSTProbeOnGetTextSource(ATree: TComponent; AColumn: Integer;
  out BeforeText, AfterText: string): Boolean;
var
  PropInfo: PPropInfo;
  SavedMethod: TMethod;
  EmptyMethod: TMethod;
  Op: TCnVSTreeOperator;
  Node: Pointer;
begin
  Result := False;
  BeforeText := '';
  AfterText := '';
  if ATree = nil then
    Exit;

  PropInfo := GetPropInfo(ATree.ClassInfo, 'OnGetText');
  if (PropInfo = nil) or (PropInfo^.PropType^.Kind <> tkMethod) then
    Exit;

  SavedMethod := GetMethodProp(ATree, PropInfo);
  if (not Assigned(SavedMethod.Code)) or (not Assigned(SavedMethod.Data)) then
    Exit;

  Op := TCnVSTreeOperator.Create(ATree);
  try
    Node := Op.GetFirstNode;
    if Node = nil then
      Exit;

    BeforeText := Op.GetNodeText(Node, AColumn);
    EmptyMethod.Code := nil;
    EmptyMethod.Data := nil;
    SetMethodProp(ATree, PropInfo, EmptyMethod);
    try
      AfterText := Op.GetNodeText(Node, AColumn);
    finally
      SetMethodProp(ATree, PropInfo, SavedMethod);
    end;
  finally
    Op.Free;
  end;

  Result := BeforeText <> AfterText;
end;

constructor TCnVSTOnGetTextHook.Create(ATree: TComponent);
begin
  inherited Create;
  FTree := ATree;
  FTextMap := TCnStrToStrHashMap.Create;

  FFreeNotify := TCnFreeNotificationWrapper.Create(nil);
  FFreeNotify.OnFreeNotification := TreeFreeNotification;
  FFreeNotify.FreeNotification(ATree);
end;

destructor TCnVSTOnGetTextHook.Destroy;
begin
  FFreeNotify.Free;
  Uninstall;
  FTextMap.Free;
  inherited;
end;

function TCnVSTOnGetTextHook.MakeKey(Node: Pointer; Column: Integer): string;
var
  P: Pointer;
begin
  P := Node;
  Result := DataToHex(@P, SizeOf(Pointer)) + ':' + IntToStr(Column);
end;

function TCnVSTOnGetTextHook.FindOverride(Node: Pointer; Column: Integer; out AText: string): Boolean;
var
  Key: string;
begin
  AText := '';
  // 先精确匹配 Node:Column，找不到再尝试通配键 Node:-1
  Key := MakeKey(Node, Column);
  Result := FTextMap.Find(Key, AText);

  // 兜个底
  if not Result then
  begin
    Key := MakeKey(Node, -1);
    Result := FTextMap.Find(Key, AText);
  end;
end;

procedure TCnVSTOnGetTextHook.CallOriginalOnGetText(Sender: TObject; Node: Pointer; Column: Integer;
  TextType: Integer; var CellText: WideString);
var
  M: TMethod;
  E: TCnVSTOnGetTextEvent;
begin
  if FHook = nil then
    Exit;

  M.Data := FHook.TrampolineData;
  M.Code := FHook.Trampoline;
  if Assigned(M.Code) and Assigned(M.Data) then
  begin
    E := TCnVSTOnGetTextEvent(M);
    E(Sender, Node, Column, TextType, CellText);
  end;
end;

procedure TCnVSTOnGetTextHook.DoOnGetText(Sender: TObject; Node: Pointer; Column: Integer;
  TextType: Integer; var CellText: WideString);
var
  OverrideText: string;
  Translated: string;
begin
  CallOriginalOnGetText(Sender, Node, Column, TextType, CellText);

  // 先查预存的覆盖文本（由 SetOverrideText 存入）
  if FindOverride(Node, Column, OverrideText) then
    CellText := OverrideText
  else if (CellText <> '') and Assigned(FOnTranslateText) then
  begin
    // 没有预存覆盖文本时，通过回调实时翻译原始文本
    // 这解决了 D10.4 懒加载导致预遍历时节点为空的问题
    Translated := '';
    FOnTranslateText(Self, string(CellText), Translated);
    if Translated <> '' then
    begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('CnVSTOnGetTextHook.DoOnGetText RealTime Translate: "%s" -> "%s"',
//      [string(CellText), Translated]);
{$ENDIF}
      CellText := Translated;
    end;
  end;
end;

function TCnVSTOnGetTextHook.Install: Boolean;
begin
  if Hooked then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  if FTree = nil then
    Exit;

  FHook := TCnEventHook.Create(FTree, 'OnGetText', Self, @TCnVSTOnGetTextHook.DoOnGetText);
  Result := (FHook <> nil) and FHook.Hooked;
{$IFDEF DEBUG}
  if FHook <> nil then
    CnDebugger.LogFmt(
      'TCnVSTOnGetTextHook.Install Result=%s Hook=%p Hooked=%s Trampoline=%p TrampolineData=%p',
      [BoolToStr(Result, True), Pointer(FHook), BoolToStr(FHook.Hooked, True),
       FHook.Trampoline, Pointer(FHook.TrampolineData)])
  else
    CnDebugger.LogFmt(
      'TCnVSTOnGetTextHook.Install Result=%s Hook=nil',
      [BoolToStr(Result, True)]);
{$ENDIF}
  if not Result then
    FreeAndNil(FHook);
end;

procedure TCnVSTOnGetTextHook.Uninstall;
begin
  FreeAndNil(FHook);
end;

function TCnVSTOnGetTextHook.Hooked: Boolean;
begin
  Result := (FHook <> nil) and FHook.Hooked;
end;

procedure TCnVSTOnGetTextHook.SetOverrideText(Node: Pointer; Column: Integer; const AText: string);
var
  Key: string;
begin
  if not Hooked then
    Install;

  Key := MakeKey(Node, Column);
  FTextMap.Add(Key, AText);
end;

procedure TCnVSTOnGetTextHook.TreeFreeNotification(Sender: TObject;
  ACompToFree: TComponent);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnVSTOnGetTextHook.TreeFreeNotification ' + ACompToFree.Name);
{$ENDIF}
  Uninstall;
end;

procedure TCnVSTOnGetTextHook.RemoveOverrideText(Node: Pointer; Column: Integer);
var
  Key: string;
  Idx: Integer;
begin
  Key := MakeKey(Node, Column);
  FTextMap.Delete(Key);
end;

procedure TCnVSTOnGetTextHook.ClearOverrideTexts;
begin
  FTextMap.Clear;
end;

procedure TCnVSTOnGetTextHook.RefreshTree;
begin
  if FTree is TControl then
  begin
    TControl(FTree).Invalidate;
    TControl(FTree).Update;
  end;
end;

function TCnVSTOnGetTextHook.TextMapSize: Integer;
begin
  Result := FTextMap.Size;
end;
{$IFDEF SUPPORT_ENHANCED_RTTI}

function TCnVSTreeOperator.FindMethod(const AName: string; AParamCount: Integer): TRttiMethod;
var
  Method: TRttiMethod;
begin
  Result := nil;
  if FRttiType = nil then
    Exit;

  for Method in FRttiType.GetMethods do
  begin
    if SameText(Method.Name, AName) and (Length(Method.GetParameters) = AParamCount) then
    begin
      Result := Method;
      Exit;
    end;
  end;
end;

function TCnVSTreeOperator.FindProperty(const AName: string): TRttiProperty;
var
  Prop: TRttiProperty;
begin
  Result := nil;
  if FRttiType = nil then
    Exit;

  for Prop in FRttiType.GetProperties do
  begin
    if SameText(Prop.Name, AName) then
    begin
      Result := Prop;
      Exit;
    end;
  end;
end;

function TCnVSTreeOperator.InvokePointerMethod(AMethod: TRttiMethod; const AArgs: array of TValue): Pointer;
begin
  Result := nil;
  if (FTree = nil) or (AMethod = nil) then
    Exit;

  Result := ValueToPointer(AMethod.Invoke(FTree, AArgs));
end;

function TCnVSTreeOperator.InvokeStringMethod(AMethod: TRttiMethod; const AArgs: array of TValue): string;
var
  Value: TValue;
begin
  Result := '';
  if (FTree = nil) or (AMethod = nil) then
    Exit;

  Value := AMethod.Invoke(FTree, AArgs);
  if not Value.IsEmpty then
    Result := Value.ToString;
end;

procedure TCnVSTreeOperator.InvokeProcedure(AMethod: TRttiMethod; const AArgs: array of TValue);
begin
  if (FTree = nil) or (AMethod = nil) then
    Exit;

  AMethod.Invoke(FTree, AArgs);
end;

class function TCnVSTreeOperator.ValueToPointer(const AValue: TValue): Pointer;
begin
  Result := nil;
  if AValue.IsEmpty then
    Exit;

  case AValue.Kind of
    tkPointer, tkClass, tkClassRef, tkProcedure:
      Result := AValue.AsType<Pointer>;
    tkInteger, tkInt64, tkEnumeration:
      Result := Pointer(NativeUInt(AValue.AsOrdinal));
  else
    Result := nil;
  end;
end;

class function TCnVSTreeOperator.ValueToCardinal(const AValue: TValue): Cardinal;
begin
  Result := 0;
  if AValue.IsEmpty then
    Exit;

  case AValue.Kind of
    tkInteger, tkInt64, tkEnumeration:
      Result := Cardinal(AValue.AsOrdinal);
    tkUString, tkWString, tkString, tkLString:
      Result := Cardinal(StrToIntDef(AValue.ToString, 0));
  end;
end;

{$ENDIF}

end.

  
