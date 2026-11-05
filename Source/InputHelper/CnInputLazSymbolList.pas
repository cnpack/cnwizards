{******************************************************************************}
{                                                                              }
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

unit CnInputLazSymbolList;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：输入助手 Lazarus IDE 符号列表类定义单元
* 单元作者：CnPack 开发组
* 备    注：基于 codetools 的 IDE 标识符列表类，替代 Delphi 下的
*           CnInputIdeSymbolList（ToolsAPI 无法移植），仅 Lazarus 有效。
*           调研细节与设计决策详见同目录 CnInputLazSymbolList.md
* 开发平台：Win32/Win64 + Lazarus 4.x (FPC 3.2.2)
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2026.11.05
*               创建单元，经 CodeToolBoss.GatherIdentifiers 收集光标处可见符号
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
  SysUtils, Classes, Controls, Forms, Math,
  CnCommon, CnWizConsts, CnPasCodeParser, CnWizUtils, CnInputSymbolList;

type

  //============================================================================
  // 基于 codetools 从 IDE 中获得的标识符列表
  //============================================================================

  { TLazIDESymbolList }

  TLazIDESymbolList = class(TCnSymbolList)
  public
    class function GetListName: string; override;
    function Reload(Editor: TCnEditBufferInterface; const InputText: string;
      PosInfo: TCodePosInfo; Data: Integer = 0): Boolean; override;
    {* 同步调用 codetools 收集光标处可见符号。Data 未使用，保持与 Delphi 版签名一致}
  end;

{$ENDIF CNWIZARDS_CNINPUTHELPER}

implementation

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  LCLType, CodeCache, CodeTree, CodeToolManager, IdentCompletionTool,
  PascalParserTool, SrcEditorIntf, SynCompletion;

{ TLazIDESymbolList }

// IDE 自带补全框打开时，弹窗正以惰性方式引用全局 IdentifierList，
// 此时禁止 Gather，否则会砸掉 IDE 补全框的数据导致选词越界异常
function IsIdeCompletionFormVisible: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if (Screen.CustomForms[I] is TSynBaseCompletionForm) and
      Screen.CustomForms[I].Visible then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

// 根据 codetools 的标识符项判断 CnPack 符号类型，对照 IDE 绘制逻辑
// （ide/sourceeditprocs.pas PaintCompletionItem）
function ExtractLazIdentKind(Item: TIdentifierListItem): TCnSymbolKind;
var
  ANode: TCodeTreeNode;
begin
  Result := skUnknown;
  if Item = nil then
    Exit;
  try
    if iliKeyword in Item.Flags then
      Result := skKeyword
    else
      case Item.GetDesc of
        ctnVarDefinition, ctnRecordCase:
          Result := skVariable;
        ctnTypeDefinition, ctnEnumerationType:
          begin
            Result := skType;
            if (Item.Node <> nil) and (Item.Tool <> nil) then
            begin
              ANode := Item.Tool.FindTypeNodeOfDefinition(Item.Node);
              if ANode <> nil then
              begin
                if ANode.Desc = ctnClass then
                  Result := skClass
                else if ANode.Desc in [ctnClassInterface, ctnObjCProtocol,
                  ctnDispinterface] then
                  Result := skInterface;
              end;
            end;
          end;
        ctnConstDefinition, ctnConstant, ctnEnumIdentifier:
          Result := skConstant;
        ctnProcedure:
          begin
            if Item.IsFunction then
              Result := skFunction
            else if Item.IsConstructor then
              Result := skConstructor
            else if Item.IsDestructor then
              Result := skDestructor
            else
              Result := skProcedure;
          end;
        ctnProperty, ctnGlobalProperty:
          Result := skProperty;
        ctnLabel:
          Result := skLabel;
        ctnUnit, ctnUseUnitClearName, ctnUseUnitNamespace:
          Result := skUnit;
      end;
  except
    Result := skUnknown;
  end;
end;

// 提取符号描述文本，照 IDE 弹窗的类型/参数/结果类型显示方式，
// 单项失败不影响整体，返回空即可
function ExtractLazIdentDesc(Item: TIdentifierListItem): string;
var
  ANode: TCodeTreeNode;
begin
  Result := '';
  if Item = nil then
    Exit;
  try
    if (Item.Node <> nil) and (Item.Tool <> nil) then
    begin
      case Item.Node.Desc of
        ctnProcedure:
          Result := Item.Tool.ExtractProcHead(Item.Node,
            [phpWithoutClassName, phpWithoutName, phpWithVarModifiers,
             phpWithParameterNames, phpWithDefaultValues, phpWithResultType,
             phpWithOfObject, phpWithoutSemicolon]);
        ctnProperty, ctnGlobalProperty:
          Result := Item.Tool.ExtractProperty(Item.Node,
            [phpWithoutName, phpWithVarModifiers, phpWithParameterNames,
             phpWithDefaultValues, phpWithResultType]);
        ctnVarDefinition:
          begin
            ANode := Item.Tool.FindTypeNodeOfDefinition(Item.Node);
            if ANode <> nil then
              Result := ': ' + Item.Tool.ExtractNode(ANode, []);
          end;
        ctnRecordCase:
          Result := ': ' + Item.Tool.ExtractRecordCaseType(Item.Node);
        ctnTypeDefinition:
          begin
            ANode := Item.Tool.FindTypeNodeOfDefinition(Item.Node);
            if ANode <> nil then
            begin
              case ANode.Desc of
                ctnClass:           Result := ' = class';
                ctnObject:          Result := ' = object';
                ctnObjCClass:       Result := ' = objcclass';
                ctnObjCCategory:    Result := ' = objccategory';
                ctnCPPClass:        Result := ' = cppclass';
                ctnClassInterface:  Result := ' = interface';
                ctnObjCProtocol:    Result := ' = objcprotocol';
                ctnDispinterface:   Result := ' = dispinterface';
                ctnClassHelper:     Result := ' = class helper';
                ctnRecordHelper:    Result := ' = record helper';
                ctnTypeHelper:      Result := ' = type helper';
                ctnRecordType:      Result := ' = record';
                ctnEnumerationType: Result := ' = enum';
              else
                Result := ' = ' + Item.Tool.ExtractNode(ANode, []);
              end;
            end
            else
              Result := ' = ?';
          end;
        ctnConstDefinition:
          begin
            ANode := Item.Tool.FindTypeNodeOfDefinition(Item.Node);
            if ANode <> nil then
              Result := Copy(' = ' + Item.Tool.ExtractNode(ANode, []), 1, 50);
          end;
      end;
    end
    else
    begin
      // Node 为 nil 的编译器内置项，如编译器过程/函数/基础类型/常量/关键字
      case Item.GetDesc of
        ctnProcedure:
          begin
            Result := '(' + Item.ParamNameList + ')';
            if Item.IsFunction and (Item.ResultType <> '') then
              Result := Result + ': ' + Item.ResultType + ';';
          end;
      end;
    end;
  except
    Result := '';
  end;
end;

class function TLazIDESymbolList.GetListName: string;
begin
  // 与 Delphi 版 TIDESymbolList 共用同一资源串
  Result := SCnInputHelperIDESymbolList;
end;

function TLazIDESymbolList.Reload(Editor: TCnEditBufferInterface;
  const InputText: string; PosInfo: TCodePosInfo; Data: Integer): Boolean;
var
  CodeBuf: TCodeBuffer;
  CurrPos: TPoint;
  I, C: Integer;
  Item: TIdentifierListItem;
begin
  Result := False;
  // codetools 仅处理 Pascal，C/C++ 不支持
  if not PosInfo.IsPascal then
    Exit;

  // 常规代码区放行；uses 区在 Lazarus 下无单元名列表接管，也放行由
  // codetools 提供单元名（Delphi 版此区直接屏蔽，原因见维护文档）；
  // 其余非代码区（注释/编译指令/字符串）屏蔽，同 Delphi 版
  if not ((PosInfo.PosKind in csNormalPosKinds) or
    (PosInfo.PosKind in [pkIntfUses, pkImplUses])) then
    Exit;

  // IDE 自带补全框打开时不收集，保护共享的 IdentifierList
  if IsIdeCompletionFormVisible then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('LazIDESymbolList Skip: IDE Completion Form Visible.');
{$ENDIF}
    Exit;
  end;

  if Editor = nil then
    Exit;

  // 同步编辑器未保存内容到 codetools 缓冲区，否则拿到旧内容
  try
    if Editor.NeedsUpdateCodeBuffer then
      Editor.UpdateCodeBuffer;
  except
    Exit;
  end;

  if not (Editor.CodeToolsBuffer is TCodeBuffer) then
    Exit;
  CodeBuf := TCodeBuffer(Editor.CodeToolsBuffer);

  CurrPos := Editor.CursorTextXY;
  if (CurrPos.X < 1) or (CurrPos.Y < 1) then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('LazIDESymbolList Reload: ' + CodeBuf.Filename +
    ' at ' + IntToStr(CurrPos.Y) + ':' + IntToStr(CurrPos.X));
{$ENDIF}

  Clear;
  // 内部异常全吞（HandleException 仅记 ErrorMsg 不弹框），失败返回 False
  if not CodeToolBoss.GatherIdentifiers(CodeBuf, CurrPos.X, CurrPos.Y) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('LazIDESymbolList Gather Failed: ' + CodeToolBoss.ErrorMessage);
{$ENDIF}
    Exit;
  end;

  if CodeToolBoss.IdentifierList = nil then
    Exit;

  // 清掉残留前缀取全量列表，前缀匹配由输入助手负责
  CodeToolBoss.IdentifierList.Prefix := '';
  C := CodeToolBoss.IdentifierList.GetFilteredCount;
  if C <= 0 then
    Exit;

  List.Capacity := C;
  for I := 0 to C - 1 do
  begin
    Item := CodeToolBoss.IdentifierList.FilteredItems[I];
    if (Item = nil) or (Item.Identifier = '') then
      Continue;

    Add(Item.Identifier, ExtractLazIdentKind(Item),
      Round(MaxInt / C * I), ExtractLazIdentDesc(Item), '',
      True, False, False, False);
    // ForPascal 默认 True、ForCpp 默认 False，无需再设置
  end;

{$IFDEF DEBUG}
  CnDebugger.LogInteger(Count, 'LazIDESymbolList Count');
{$ENDIF}
  Result := Count > 0;
end;

initialization
  RegisterSymbolList(TLazIDESymbolList);

{$ENDIF CNWIZARDS_CNINPUTHELPER}
end.
