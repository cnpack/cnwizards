{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit CnRemoteInspector;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：调试功能扩展单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
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

uses
  CnNative {$IFDEF DEBUG}, CnDebug {$ENDIF};

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

  // ClassInfo 指向该结构
  TCnTypeInfoRec = packed record
    TypeKind: Byte;
    NameLength: Byte;
    // NameLength 个 Byte 是 ClassName，再后面是 TCnTypeDataRec32/64
  end;
  PCnTypeInfoRec = ^TCnTypeInfoRec;

  TCnTypeDataRec32 = packed record
    ClassType: Cardinal;
    ParentInfo: Cardinal;
    PropCount: SmallInt;
    UnitNameLength: Byte;
    // UnitNameLength 个 Byte 是 UnitName，再后面是 TCnPropDataRec
  end;
  PCnTypeDataRec32 = ^TCnTypeDataRec32;

  TCnTypeDataRec64 = packed record
    ClassType: Int64;
    ParentInfo: Int64;
    PropCount: SmallInt;
    UnitNameLength: Byte;
    // UnitNameLength 个 Byte 是 UnitName，再后面是 TCnPropDataRec
  end;
  PCnTypeDataRec64 = ^TCnTypeDataRec64;

  TCnPropDataRec = packed record
    PropCount: Word;
    // 再后面是 TCnPropInfoRec32/64 列表
  end;
  PCnPropDataRec = ^TCnPropDataRec;

  TCnPropInfoRec32 = packed record
    PropType: Cardinal;
    GetProc: Cardinal;
    SetProc: Cardinal;
    StoredProc: Cardinal;
    Index: Integer;
    Default: Longint;
    NameIndex: SmallInt;
    NameLength: Byte;
    // NameLength 个 Byte 是 PropName
  end;
  PCnPropInfoRec32 = ^TCnPropInfoRec32;

  TCnPropInfoRec64 = packed record
    PropType: Int64;
    GetProc: Int64;
    SetProc: Int64;
    StoredProc: Int64;
    Index: Integer;
    Default: Longint;
    NameIndex: SmallInt;
    NameLength: Byte;
    // NameLength 个 Byte 是 PropName
  end;
  PCnPropInfoRec64 = ^TCnPropInfoRec64;

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

  AForm.ObjectPointer := nil;
  AForm.ObjectExpr := Trim(Expression); // 注意此时 ObjectPointer 必须为 nil，内部判断使用
  AForm.Clear;
  AForm.ParentSheetForm := AParentSheet;

  AForm.SyncMode := SyncMode;
  AForm.InspectorClass := TCnRemoteEvaluationInspector;

  Eval := TCnRemoteProcessEvaluator.Create;
  if SyncMode then
  begin
    AForm.DoEvaluateBegin;
    try
      AForm.InspectParam := Eval;
      AForm.InspectObject(AForm.InspectParam);
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
  inherited Create(Data);
  FEvaluator := TCnRemoteProcessEvaluator(Data);
end;

destructor TCnRemoteEvaluationInspector.Destroy;
begin
  FEvaluator.Free;
  inherited;
end;

{
  如果表达式是对象，则求其 ClassInfo 得到地址指针，第一次复制 256 + 256 字节，用以拿到类名、父类 Info 指针与属性总数
  再根据属性总数，读本次 ClassInfo 的 256 * （属性数 + 1）字节，得到本类属性数，遍历获取
  再额外求其父类 Info 指针，再读 256 * （属性数 + 1）字节，得到父类名、父类属性数，遍历获取
  总共读到足够属性数或到了 TObject 就停，大概要读该对象的层级数那么多次的地址空间内容
}
procedure TCnRemoteEvaluationInspector.DoEvaluate;
var
  I, Len, Ret, APCnt, PCnt: Integer;
  BufLen: Integer;
  RemPtr: TCnOTAAddress;
  Base, S: string;
  Buf: TBytes;
  BufPtr: PByte;
  Hies: TStringList;
  AProp: TCnPropertyObject;
  Is32: Boolean;
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

  if not CnWizDebuggerObjectInheritsFrom(FObjectExpr, 'TObject', FEvaluator) then
  begin
    InspectComplete := True;
    Exit;
  end;

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

  Base := Format('(%s)', [FObjectExpr]);
  S := Format('Pointer(%s.ClassInfo)', [Base]);
  S := FEvaluator.EvaluateExpression(S);
  if LowerCase(S) = 'nil' then
    RemPtr := 0
  else
    RemPtr := StrToUInt64(S);

  if RemPtr <> 0 then
  begin
    ContentTypes := [pctHierarchy];
    Hies := TStringList.Create;
    try
      BufLen := 512;
      SetLength(Buf, BufLen);
      Ret := FEvaluator.ReadProcessMemory(RemPtr, BufLen, Buf[0]);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('FEvaluator.ReadProcessMemory %d Return %d', [BufLen, Ret]);
      CnDebugger.LogMemDump(@Buf[0], Ret);
{$ENDIF}

      BufPtr := @Buf[0];
      Len := PCnTypeInfoRec(BufPtr)^.NameLength;
      Inc(BufPtr, SizeOf(TCnTypeInfoRec));                      // 跳过俩字节指向 ClassName
      Inc(BufPtr, Len);                                         // 再跳过字符串长度指向 TypeData

      // 先拿属性总数，Buf 是 TCnTypeInfoRec
      Is32 := FEvaluator.CurrentProcessIs32;
{$IFDEF DEBUG}
      if Is32 then
        CnDebugger.LogMsg('Remote Process is 32.')
      else
        CnDebugger.LogMsg('Remote Process is 64.');
{$ENDIF}

      if Is32 then
        APCnt := PCnTypeDataRec32(BufPtr)^.PropCount
      else
        APCnt := PCnTypeDataRec64(BufPtr)^.PropCount;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('All Properties Count: %d', [APCnt]);
{$ENDIF}

      if APCnt > 0 then
      begin
        // 拿到属性总数后，BufLen 基本确定，重新读入 Buf，并准备好 BufPtr，开始循环
        BufLen := (APCnt + 1) * 256; // 预留尽可能大的空间
        SetLength(Buf, BufLen);
        Ret := FEvaluator.ReadProcessMemory(RemPtr, BufLen, Buf[0]);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('FEvaluator.ReadProcessMemory %d Return %d', [BufLen, Ret]);
{$ENDIF}
        // Buf 是本类的 PCnTypeInfoRec
        BufPtr := @Buf[0];

        repeat
          Len := PCnTypeInfoRec(BufPtr)^.NameLength;
          Inc(BufPtr, SizeOf(TCnTypeInfoRec));                      // 跳过俩字节指向 ClassName

          SetLength(S, Len);
          Move(BufPtr^, S[1], Len);
{$IFDEF DEBUG}
          CnDebugger.LogFmt('ClassName: %s', [S]);
{$ENDIF}
          Hies.Add(S);

          Inc(BufPtr, Len);                                         // 再跳过字符串长度指向 TypeData

          Is32 := FEvaluator.CurrentProcessIs32;
          RemPtr := 0;

          Base := Base + '.ClassParent';                            // 先拿父类的 ClassInfo 数字
          S := Format('Pointer(%s.ClassInfo)', [Base]);
          S := FEvaluator.EvaluateExpression(S);
          if LowerCase(S) <> 'nil' then
            RemPtr := StrToUInt64(S);

          if Is32 then
          begin
            // APCnt := PCnTypeDataRec32(BufPtr)^.PropCount;           // 拿到本类到所有子类的属性总数
            Len := PCnTypeDataRec32(BufPtr)^.UnitNameLength;
            Inc(BufPtr, SizeOf(TCnTypeDataRec32));                  // 指向 UnitName 字符串
            SetLength(S, Len);
            Move(BufPtr^, S[1], Len);
{$IFDEF DEBUG}
            CnDebugger.LogFmt('UnitName: %s', [S]);
{$ENDIF}
          end
          else
          begin
            // APCnt := PCnTypeDataRec64(BufPtr)^.PropCount;
            Len := PCnTypeDataRec64(BufPtr)^.UnitNameLength;
            Inc(BufPtr, SizeOf(TCnTypeDataRec64));                  // 指向 UnitName 字符串
            SetLength(S, Len);
            Move(BufPtr^, S[1], Len);
{$IFDEF DEBUG}
            CnDebugger.LogFmt('UnitName: %s', [S]);
{$ENDIF}
          end;

          Inc(BufPtr, Len);                                         // 跳过 UnitName 指向 PropData
          PCnt := PCnPropDataRec(BufPtr)^.PropCount;                // 拿到本类的属性数
{$IFDEF DEBUG}
          CnDebugger.LogFmt('Properties Count: %d', [PCnt]);
{$ENDIF}
          Inc(BufPtr, SizeOf(TCnPropDataRec));                      // 指向 PropInfo，如果有的话

          if PCnt > 0 then
          begin
            for I := 0 to PCnt - 1 do
            begin
              if Is32 then
              begin
                Len := PCnPropInfoRec32(BufPtr)^.NameLength;        // 拿到属性名的长度
                Inc(BufPtr, SizeOf(TCnPropInfoRec32));              // BufPtr 指向属性名
                SetLength(S, Len);
                Move(BufPtr^, S[1], Len);                           // 复制属性名
                Inc(BufPtr, Len);                                   // BufPtr 跳过名称，指向下一个
              end
              else
              begin
                Len := PCnPropInfoRec64(BufPtr)^.NameLength;        // 拿到属性名的长度
                Inc(BufPtr, SizeOf(TCnPropInfoRec64));              // BufPtr 指向属性名
                SetLength(S, Len);
                Move(BufPtr^, S[1], Len);                           // 复制属性名
                Inc(BufPtr, Len);                                   // BufPtr 跳过名称，指向下一个
              end;
              // 拿到属性名在 S 里
{$IFDEF DEBUG}
              CnDebugger.LogFmt('Property %d: %s', [I + 1, S]);
{$ENDIF}
            end;
          end;

          // 如果拿到了父类信息的远程指针，则重新读进一块内存
          if RemPtr <> 0 then
          begin
            Ret := FEvaluator.ReadProcessMemory(RemPtr, BufLen, Buf[0]);
{$IFDEF DEBUG}
            CnDebugger.LogFmt('FEvaluator.ReadProcessMemory %d Return %d', [BufLen, Ret]);
{$ENDIF}
            BufPtr := @Buf[0];                                        // 指向父类，重新开始循环
          end
          else
            BufPtr := nil;
        until BufPtr = nil;
      end;

      Hierarchy := Hies.Text;
      DoAfterEvaluateHierarchy;
    finally
      Hies.Free;
    end;
  end;

//{$IFDEF SUPPORT_ENHANCED_RTTI}
//  S := Format('Length(TRttiContext.Create.GetType(%s.ClassInfo).GetProperties)', [FObjectExpr]);
//  S := FEvaluator.EvaluateExpression(S);
//  C := StrToIntDef(S, 0);
//  if C > 0 then
//  begin
//    for I := 0 to C - 1 do
//    begin
//      S := FEvaluator.EvaluateExpression(Format('TRttiContext.Create.GetType(%s.ClassInfo).GetProperties[%d].PropertyType.TypeKind', [FObjectExpr, I]));
//      // 拿到类型名称
//      if (S <> 'tkMethod') and (S <> 'tkUnknown') then
//      begin
//        // 是属性
//        V := FEvaluator.EvaluateExpression(Format('TRttiContext.Create.GetType(%s.ClassInfo).GetProperties[%d].Name', [FObjectExpr, I]));
//
//        // V 拿到名称
//        if not IsRefresh then
//        begin
//          AProp := TCnPropertyObject.Create;
//          AProp.IsNewRTTI := True;
//        end
//        else
//          AProp := IndexOfProperty(Properties, V);
//
//        AProp.PropName := V;
//        // AProp.PropType := S;
//
//        S := FEvaluator.EvaluateExpression(Format('TRttiContext.Create.GetType(%s.ClassInfo).GetProperties[%d].GetValue(%s)', [FObjectExpr, I, FObjectExpr]));
//        if S <> AProp.DisplayValue then
//        begin
//          AProp.DisplayValue := S;
//          AProp.Changed := True;
//        end
//        else
//          AProp.Changed := False;
//
//        if not IsRefresh then
//          Properties.Add(AProp);
//
//        ContentTypes := ContentTypes + [pctProps];
//      end;
//    end;
//  end;
//{$ENDIF}

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
