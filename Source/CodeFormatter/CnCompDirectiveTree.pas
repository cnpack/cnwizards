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

unit CnCompDirectiveTree;
{* |<PRE>
================================================================================
* 软件名称：CnPack 专家包
* 单元名称：实现代码根据 IFDEF 分树的单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：该单元为使用 TCnTree 和 TCnLeaf 的派生类进行代码的 IFDEF 分树实现单元。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串均符合本地化处理方式
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
    SliceNode 0     -- 前缀：无。内容：begin 1111
      SliceNode 1   -- 前缀：{$IFDEF DEBUG}。内容：22222
        SliceNode 2 -- 前缀：{$IFDEF NDEBUG}。内容：3333
      SliceNode 3   -- 前缀：{$ENDIF}。内容：4444
      SliceNode 4   -- 前缀：{$ELSE}。内容：5555
    SliceNode 5     -- 前缀：{$ENDIF}。内容：END;
  
  规则是见IFDEF就进一层并把IFDEF和后面代码塞进去，
  见ENDIF退一层把ENDIF和后面代码塞进去，
  见ELSE/ELIF等同级生成个新的。

  分树完毕后，查找树中直属子节点排除 ENDIF/IFEND外数目大于等于两个的节点的直属子节点
  针对每一个子节点，生成头到这个节点的源码字符串，可拿来格式化。
  这个节点对应生成的源码字符串需要对应到格式化后的内容。
*)

uses
  SysUtils, Classes, Windows,
  CnTree, CnScanners, CnCodeFormatRules, CnTokens;

type
  TCnSliceNode = class(TCnLeaf)
  {* IFDEF 分树的子节点实现类，其 Child 也是 TCnSliceNode}
  private
    FCompDirectiveStream: TMemoryStream;
    FNormalCodeStream: TMemoryStream;
    FCompDirectiveType: TPascalCompDirectiveType;
    FStartOffset: Integer;
    FReachingStart: Integer;
    FEndBlankLength: Integer;
    FKeepFlag: Boolean;
    FProcessed: Boolean;
    function GetItems(Index: Integer): TCnSliceNode;
    function GetLength: Integer;
    function GetReachingEnd: Integer;

    function BuildString: string;
    procedure SetKeepFlag(const Value: Boolean);
  protected

  public
    constructor Create(ATree: TCnTree); override;
    destructor Destroy; override;

    function IsSingleSlice: Boolean;

    property CompDirectiveStream: TMemoryStream read FCompDirectiveStream write FCompDirectiveStream;
    property NormalCodeStream: TMemoryStream read FNormalCodeStream write FNormalCodeStream;
    property CompDirectivtType: TPascalCompDirectiveType read FCompDirectiveType write FCompDirectiveType;

    property StartOffset: Integer read FStartOffset write FStartOffset;
    {* 本分片在原始源码中的起始偏移，根据实际情况看可以是编译指令的也可以是代码的}
    property ReachingStart: Integer read FReachingStart write FReachingStart;
    {* 本分片在直达源码中的起始偏移，根据实际情况看可以是编译指令的也可以是代码的}
    property Length: Integer read GetLength;
    {* 本分片包含的代码与编译指令的字符长度}
    property ReachingEnd: Integer read GetReachingEnd;
    {* 本分片在直达源码中的终点偏移，是上述俩相加}
    property EndBlankLength: Integer read FEndBlankLength write FEndBlankLength;
    {* 分片末尾的空白字符串长度，格式化时需要用到，用 ReachingEnd 减本段}
    
    property Items[Index: Integer]: TCnSliceNode read GetItems; default;
    {* 直属叶节点数组 }

    property KeepFlag: Boolean read FKeepFlag write SetKeepFlag;
    property Processed: Boolean read FProcessed write FProcessed;
  end;

  TCnCompDirectiveTree = class(TCnTree)
  private
    FScanner: TAbstractScanner;
    function GetItems(AbsoluteIndex: Integer): TCnSliceNode;

    procedure SyncTexts;
    {* 将分树的内容赋值到 Text 属性中供多次使用}
    procedure ClearFlags;
    {* 清除 KeepFlag 标记}
    procedure PruneDuplicated;
    {* 通过广度优先遍历的方式做标记，把凡是并列的区域保留得只剩一个}

    procedure WidthFirstTravelSlice(Sender: TObject);
  public
    constructor Create(AStream: TStream);
    destructor Destroy; override;

    procedure ParseTree;
    {* 生成编译指令分树}

    procedure SearchMultiNodes(Results: TList);
    {* 查找树中直属子节点数目大于等于两个的节点的直属子节点，并且要排除 ENDIF/IFEND}

    function ReachNode(EndNode: TCnSliceNode): string;
    {* 深度优先遍历，生成从头到此节点的直达源码字符串，保证凡是并列的区域只选一个。
      规则是如果前一个 Node 和本 Node 同级，则本 Node 跳过（本 Node 以下的子节点均跳过），
      直到 EndNode 的 Parent 为止，再加 EndNode 本身，同时给 EndNode 设置 ReachingOffset}

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

function TCnSliceNode.GetLength: Integer;
begin
  Result := 0;
  if FCompDirectiveStream <> nil then
    Inc(Result, FCompDirectiveStream.Size div SizeOf(Char));
  if FNormalCodeStream <> nil then
    Inc(Result, FNormalCodeStream.Size div SizeOf(Char));
end;

function TCnSliceNode.GetReachingEnd: Integer;
begin
  Result := FReachingStart + GetLength;
end;

function TCnSliceNode.IsSingleSlice: Boolean;
begin
  Result := not GetHasChildren;
end;

procedure TCnSliceNode.SetKeepFlag(const Value: Boolean);
begin
  FKeepFlag := Value;
{$IFDEF DEBUG}
  Data := Integer(Value);
{$ENDIF}
end;

function TCnSliceNode.BuildString: string;
var
  Len: Integer;
begin
  Result := '';
  if (FCompDirectiveStream = nil) and (FNormalCodeStream = nil) then
    Exit;

  Len := 0;
  if FCompDirectiveStream <> nil then
    Len := FCompDirectiveStream.Size div SizeOf(Char);
  if FNormalCodeStream <> nil then
    Inc(Len, FNormalCodeStream.Size div SizeOf(Char));

  SetLength(Result, Len);
  if FCompDirectiveStream <> nil then
    CopyMemory(@(Result[1]), FCompDirectiveStream.Memory,
      FCompDirectiveStream.Size);

  if FNormalCodeStream <> nil then
  begin
    Len := 0;
    if FCompDirectiveStream <> nil then
      Len := FCompDirectiveStream.Size div SizeOf(Char);
    CopyMemory(@(Result[1 + Len]),
      FNormalCodeStream.Memory, FNormalCodeStream.Size);
  end;
end;

{ TCnCompDirectiveTree }

procedure TCnCompDirectiveTree.ClearFlags;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Items[I].KeepFlag := False;
    Items[I].Processed := False;
  end;
end;

constructor TCnCompDirectiveTree.Create(AStream: TStream);
begin
  inherited Create(TCnSliceNode);
  FScanner := TScanner.Create(AStream, nil, cdmNone);
  FScanner.NextToken;
end;

destructor TCnCompDirectiveTree.Destroy;
begin
  FScanner.Free;
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
    if (CurNode.CompDirectiveStream = nil) and (CurNode.NormalCodeStream = nil) then
      CurNode.StartOffset := FScanner.SourcePos;
      
    if CurNode.NormalCodeStream = nil then
      CurNode.NormalCodeStream := TMemoryStream.Create;

    if FScanner.BlankStringLength > 0 then
    begin
      Blank := FScanner.BlankString;
      CurNode.NormalCodeStream.Write((PChar(Blank))^, FScanner.BlankStringLength * SizeOf(Char));
    end;
    CurNode.NormalCodeStream.Write(FScanner.TokenPtr^, FScanner.TokenStringLength * SizeOf(Char));
  end;

  procedure PutBlankToNode;
  var
    Blank: string;
  begin
    if FScanner.BlankStringLength > 0 then
    begin
      CurNode.EndBlankLength := FScanner.BlankStringLength;
      Blank := FScanner.BlankString;
      if CurNode.NormalCodeStream = nil then
        CurNode.NormalCodeStream := TMemoryStream.Create;
      CurNode.NormalCodeStream.Write((PChar(Blank))^, FScanner.BlankStringLength * SizeOf(Char));
    end;
  end;

  procedure PutCompDirectiveToNode;
  begin
    if CurNode.CompDirectiveStream = nil then
    begin
      CurNode.CompDirectiveStream := TMemoryStream.Create;
      CurNode.StartOffset := FScanner.SourcePos;
    end;
    // 之前的空白与回车由 PutBlankToNode 写入上一个末尾，保证节点是 CompDirective 开头
    CurNode.CompDirectiveStream.Write(FScanner.TokenPtr^, FScanner.TokenStringLength * SizeOf(Char));
  end;

begin
  Clear;
  CurNode := nil;
  if FScanner.Token <> tokEOF then
    CurNode := TCnSliceNode(AddChildFirst(Root));

  while FScanner.Token <> tokEOF do
  begin
    if FScanner.Token = tokCompDirective then
    begin
      TokenStr := UpperCase(FScanner.TokenString);
      CompDirectType := CalcPascalCompDirectiveType;

      case CompDirectType of
        cdtIf, cdtIfDef, cdtIfNDef:
          begin
            // 进一层并把本编译指令塞进去
            PutBlankToNode;
            CurNode := TCnSliceNode(AddChild(CurNode));
            CurNode.CompDirectivtType := CompDirectType;
            PutCompDirectiveToNode;
          end;
        cdtElse:
          begin
            // 同级生成个新的并把本编译指令塞进去
            PutBlankToNode;
            CurNode := TCnSliceNode(AddChild(CurNode.Parent));
            CurNode.CompDirectivtType := CompDirectType;
            PutCompDirectiveToNode;
          end;
        cdtIfEnd, cdtEndIf:
          begin
            // 退一层并把本编译指令塞进去
            if CurNode.Parent <> nil then
            begin
              PutBlankToNode;
              CurNode := TCnSliceNode(Add(CurNode.Parent));
              CurNode.CompDirectivtType := CompDirectType;
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

    FScanner.NextToken;
  end;
  SyncTexts;
end;

procedure TCnCompDirectiveTree.PruneDuplicated;
begin
  OnWidthFirstTravelLeaf := WidthFirstTravelSlice;
  WidthFirstTravel;
end;

function TCnCompDirectiveTree.ReachNode(EndNode: TCnSliceNode): string;
var
  I: Integer;
  Node: TCnSliceNode;
begin
  Result := '';
  if EndNode = nil then
    Exit;

  if Count <= 1 then // Only root，no content
    Exit;

  ClearFlags;
  Node := EndNode;
  while Node <> nil do
  begin
    Node.KeepFlag := True;
    Node.Processed := False;
    Node := TCnSliceNode(Node.Parent);
  end;

  PruneDuplicated;
  for I := 0 to Count - 1 do
  begin
    if Items[I].KeepFlag then
    begin
      if Items[I] = EndNode then
        EndNode.ReachingStart := Length(Result); // 记录此分片在直达源码中的起始位置
      Result := Result + Items[I].Text;
    end;
  end;
end;

procedure TCnCompDirectiveTree.SearchMultiNodes(Results: TList);
var
  I, J, Cnt: Integer;
  Node, Node2: TCnSliceNode;
begin
  if Results = nil then
    Exit;
  Results.Clear;

  if Count <= 1 then // Only root，no content
    Exit;

  for I := 1 to Count - 1 do
  begin
    Node := Items[I];
    if Node.Count > 1 then
    begin
      Cnt := Node.Count;
      // 内部任何一个 ENDIF/IFEND 可能是属于内层嵌套块而退出来的
      // 如果有 ENDIF/IFEND，则把这个除外，数量减一
      for J := 0 to Node.Count - 1 do
      begin
        Node2 := TCnSliceNode(Node.Items[J]);
        if Node2.CompDirectivtType in [cdtEndIf, cdtIfEnd] then
          Dec(Cnt);
      end;

      if Cnt > 1 then // 去掉内层退出的 ENDIF/IFEND 后如数量还足够，则重新加
      begin
        for J := 0 to Node.Count - 1 do
        begin
          Node2 := TCnSliceNode(Node.Items[J]);
          if not (Node2.CompDirectivtType in [cdtEndIf, cdtIfEnd]) then
            Results.Add(Node2);
        end;
      end;
    end;
  end;
end;

procedure TCnCompDirectiveTree.SyncTexts;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Text := Items[I].BuildString;
end;

procedure TCnCompDirectiveTree.WidthFirstTravelSlice(Sender: TObject);
var
  Node, Node2: TCnSliceNode;
  I, Cnt, KeepIdx: Integer;
  HasKeep: Boolean;

  procedure RecursiveSetKeepFlag(ANode: TCnSliceNode; Value: Boolean);
  var
    I: Integer;
  begin
    ANode.KeepFlag := Value;
    for I := 0 to ANode.Count - 1 do
      RecursiveSetKeepFlag(ANode.Items[I], Value);
  end;

  procedure RecursiveSetProcessed(ANode: TCnSliceNode; Value: Boolean);
  var
    I: Integer;
  begin
    ANode.Processed := Value;
    for I := 0 to ANode.Count - 1 do
      RecursiveSetProcessed(ANode.Items[I], Value);
  end;

begin
  // 剪枝处理
  Node := TCnSliceNode(Sender);
  if Node.Processed then  // Root 得处理，用来区分第一层代码
    Exit;

  if Node.Count > 1 then
  begin
    Cnt := Node.Count;
    // 如果直属子节点有 ENDIF/IFEND，则把这个除外，数量减一
    for I := 0 to Node.Count - 1 do
    begin
      Node2 := TCnSliceNode(Node.Items[I]);
      if Node2.CompDirectivtType in [cdtEndIf, cdtIfEnd] then
        Dec(Cnt);
    end;

    if Cnt > 1 then // 去掉内层退出的 ENDIF/IFEND 后如数量还超过2，则开始剪枝
    begin
      HasKeep := False;
      KeepIdx := -1;
      for I := 0 to Node.Count - 1 do
      begin
        if Node.Items[I].KeepFlag then
        begin
          HasKeep := True;
          KeepIdx := I;
          Break;
        end;
      end;

      if not HasKeep then
        KeepIdx := 0;

      // 子中有个已先设为 Keep 的就用 KeepIdx 所指的，否则用第一个
      // 凡是设置了 KeepFlag 的节点，其子还得再次处理，所以必须 Processed 设为 False
      for I := 0 to Node.Count - 1 do
      begin
        if I = KeepIdx then
        begin
          Node.Items[I].KeepFlag := True;
          Node.Items[I].Processed := False;
        end
        else if (I = KeepIdx + 1) and (Node.Items[I].CompDirectivtType in
          [cdtIfEnd, cdtEndIf]) then
        begin
          Node.Items[I].KeepFlag := True;
          Node.Items[I].Processed := False;
        end
        else
        begin
          RecursiveSetKeepFlag(Node.Items[I], False);
          RecursiveSetProcessed(Node.Items[I], True);
          // 递归设置其属性，并包括其所有子节点
          // 凡是 KeepFlag 设为 False的，其子全部抛弃
        end;
      end;
    end
    else // 如果子节点数量大于一，但只有一个有效的，则取它，但不包括孙子
    begin
      for I := 0 to Node.Count - 1 do
      begin
        Node.Items[I].KeepFlag := True;
        Node.Items[I].Processed := False;
      end;
    end;
  end
  else if Node.Count = 1 then // 如果子节点数量等于一，则取它，但不包括孙子
  begin
    Node.Items[0].KeepFlag := True;
    Node.Items[0].Processed := False;
  end;
  Node.Processed := True; // 本节点处理过了
end;

end.
