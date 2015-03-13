{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2015 CnPack 开发组                       }
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

unit CnCompDirectiveTree;
{* |<PRE>
================================================================================
* 软件名称：CnPack 专家包
* 单元名称：实现代码根据 IFDEF 分树的单元
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：该单元为使用 TCnTree 和 TCnLeaf 的派生类进行代码的 IFDEF 分树实现单元。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2015.03.13 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

(*
  基本思想：将代码被 IFDEF/ELSEIF/ENDIF 分开的区域拆分成树状结构。
  如代码（未画出回车换行）：
  begin 1111 {$IFDEF DEBUG} 22222 {$ELSEIF NDEBUG} 33333 {ELSE} 4444 {ENDIF} end;

  Root:
    SliceNode 0    -- 前缀：无。内容：begin 1111
      SliceNode 1  -- 前缀：{$IFDEF DEBUG}。内容：22222
      SliceNode 2  -- 前缀：{$ELSEIF NDEBUG}。内容：33333
      SliceNode 3  -- 前缀：{$ELSE}。内容：4444。
    SliceNode 5    -- 前缀：{$ENDIF}。内容：end;

  如果嵌套：
  begin 111
  {$IFDEF DEBUG}
    2222
    {IFDEF NDEBUG}
       3333
    {$ENDIF}
    4444
  {$ELSE}
    5555
  {$ENDIF}
  end;

  则：
  Root:
    SliceNode 0    -- 前缀：无。内容：begin 1111
      SliceNode 1  -- 前缀：{$IFDEF DEBUG}。内容：22222
        SliceNode 2-- 前缀：{$IFDEF NDEBUG}。内容：3333
      SliceNode 3  -- 前缀：{$ENDIF}。内容：4444
      SliceNode 4  -- 前缀：{$ELSE}。内容：5555
    SliceNode 5    -- 前缀：{$ENDIF}。内容：END;
  
  规则是见IFDEF就进一层并把IFDEF和后面代码塞进去，
  见ENDIF退一层把ENDIF和后面代码塞进去，
  见ELSE/ELIF等同级生成个新的。
*)

uses
  SysUtils, Classes, Windows,
  CnTree, CnScaners, CnCodeFormatRules, CnTokens;

type
  TCnSliceNode = class(TCnLeaf)
  {* IFDEF 分树的子节点实现类，其 Child 也是 TCnSliceNode}
  private
    FCompDirectiveStream: TMemoryStream;
    FNormalCodeStream: TMemoryStream;
    function GetItems(Index: Integer): TCnSliceNode;
  protected

  public
    constructor Create(ATree: TCnTree); override;
    destructor Destroy; override;

    function IsSingleSlice: Boolean;
    function ToString: string;

    property CompDirectiveStream: TMemoryStream read FCompDirectiveStream write FCompDirectiveStream;
    property NormalCodeStream: TMemoryStream read FNormalCodeStream write FNormalCodeStream;
    
    property Items[Index: Integer]: TCnSliceNode read GetItems; default;
    {* 直属叶节点数组 }
  end;

  TCnCompDirectiveTree = class(TCnTree)
  private
    FScaner: TAbstractScaner;
    function GetItems(AbsoluteIndex: Integer): TCnSliceNode;
  public
    constructor Create(AStream: TStream);
    destructor Destroy; override;

    procedure ParseTree;

    property Items[AbsoluteIndex: Integer]: TCnSliceNode read GetItems; 
  end;

implementation

const
  ACnPasCompDirectiveTokenStr: array[0..5] of AnsiString =
    ('{$IF ', '{$IFDEF ', '{$IFNDEF ', '{$ELSE', '{$ENDIF', '{$IFEND');

  ACnPasCompDirectiveTypes: array[0..5] of TPascalCompDirectiveType =
    (cdtIf, cdtIfDef, cdtIfNDef, cdtElse, cdtEndIf, cdtIfEnd);

{ TCnSliceNode }

constructor TCnSliceNode.Create(ATree: TCnTree);
begin
  inherited;

end;

destructor TCnSliceNode.Destroy;
begin
  FreeAndNil(FCompDirectiveStream);
  FreeAndNil(FNormalCodeStream);
  inherited;
end;

function TCnSliceNode.GetItems(Index: Integer): TCnSliceNode;
begin
  Result := TCnSliceNode(inherited GetItems(Index));
end;

function TCnSliceNode.IsSingleSlice: Boolean;
begin
  Result := not GetHasChildren;
end;

function TCnSliceNode.ToString: string;
var
  Len: Integer;
begin
  Result := '';
  if (FCompDirectiveStream = nil) and (FNormalCodeStream = nil) then
    Exit;

  Len := 0;
  if FCompDirectiveStream <> nil then
    Len := FCompDirectiveStream.Size;
  if FNormalCodeStream <> nil then
    Inc(Len, FNormalCodeStream.Size);

  SetLength(Result, Len);
  if FCompDirectiveStream <> nil then
    CopyMemory(@(Result[1]), FCompDirectiveStream.Memory,
      FCompDirectiveStream.Size);

  if FNormalCodeStream <> nil then
  begin
    Len := 0;
    if FCompDirectiveStream <> nil then
      Len := FCompDirectiveStream.Size;
    CopyMemory(@(Result[1 + Len]),
      FNormalCodeStream.Memory, FNormalCodeStream.Size);
  end;
end;

{ TCnCompDirectiveTree }

constructor TCnCompDirectiveTree.Create(AStream: TStream);
begin
  inherited Create(TCnSliceNode);
  FScaner := TScaner.Create(AStream, nil, cdmNone);
end;

destructor TCnCompDirectiveTree.Destroy;
begin
  FScaner.Free;
  inherited;
end;

function TCnCompDirectiveTree.GetItems(
  AbsoluteIndex: Integer): TCnSliceNode;
begin
  Result := TCnSliceNode(inherited GetItems(AbsoluteIndex));
end;

procedure TCnCompDirectiveTree.ParseTree;
var
  CurNode: TCnSliceNode;
  TokenStr: string;
  CompDirectType: TPascalCompDirectiveType;

  function CalcPascalCompDirectiveType: TPascalCompDirectiveType;
  var
    I: Integer;
  begin
    for I := Low(ACnPasCompDirectiveTokenStr) to High(ACnPasCompDirectiveTokenStr) do
    begin
      if Pos(ACnPasCompDirectiveTokenStr[I], TokenStr) = 1 then
      begin
        Result := ACnPasCompDirectiveTypes[I];
        Exit;
      end;
    end;
    Result := cdtUnknown;
  end;

  procedure PutNormalCodeToNode;
  var
    Blank: string;
  begin
    if CurNode.NormalCodeStream = nil then
      CurNode.NormalCodeStream := TMemoryStream.Create;

    if FScaner.BlankStringLength > 0 then
    begin
      Blank := FScaner.BlankString;
      CurNode.NormalCodeStream.Write((PChar(Blank))^, FScaner.BlankStringLength);
    end;
    CurNode.NormalCodeStream.Write(FScaner.TokenPtr^, FScaner.TokenStringLength);
  end;

  procedure PutCompDirectiveToNode;
  var
    Blank: string;
  begin
    if CurNode.CompDirectiveStream = nil then
      CurNode.CompDirectiveStream := TMemoryStream.Create;

    if FScaner.BlankStringLength > 0 then
    begin
      Blank := FScaner.BlankString;
      CurNode.CompDirectiveStream.Write((PChar(Blank))^, FScaner.BlankStringLength);
    end;
    CurNode.CompDirectiveStream.Write(FScaner.TokenPtr^, FScaner.TokenStringLength);
  end;

begin
  Clear;
  CurNode := nil;
  if FScaner.Token <> tokEOF then
    CurNode := TCnSliceNode(AddChildFirst(Root));

  while FScaner.Token <> tokEOF do
  begin
    if FScaner.Token = tokCompDirective then
    begin
      TokenStr := UpperCase(FScaner.TokenString);
      CompDirectType := CalcPascalCompDirectiveType;

      case CompDirectType of
        cdtIf, cdtIfDef, cdtIfNDef:
          begin
            // 进一层并把本编译指令塞进去
            CurNode := TCnSliceNode(AddChild(CurNode));
            PutCompDirectiveToNode;
          end;
        cdtElse:
          begin
            // 同级生成个新的并把本编译指令塞进去
            CurNode := TCnSliceNode(AddChild(CurNode.Parent));
            PutCompDirectiveToNode;
          end;
        cdtIfEnd, cdtEndIf:
          begin
            // 退一层并把本编译指令塞进去
            if CurNode.Parent <> nil then
            begin
              CurNode := TCnSliceNode(Add(CurNode.Parent));
              PutCompDirectiveToNode;
            end;
          end;
      else
        // As other token
        PutNormalCodeToNode;
      end;
    end
    else
      PutNormalCodeToNode;

    FScaner.NextToken;
  end;
end;

end.
