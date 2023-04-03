{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2023 CnPack 开发组                       }
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

unit CnPasCodeDoc;

{$I CnPack.inc}

interface

uses
  Classes, SysUtils, Contnrs;

type
  ECnPasCodeDocException = class(Exception);
  {* 解析代码文档异常}

  TCnDocType = (dtUnit, dtConst, dtVar, dtProcedure, dtProperty, dtClass, dtInterface, dtRecord);
  {* 支持文档的元素类型}

  TCnDocScope = (dsNone, dsPrivate, dsProtected, dsPublic, dsPublished);
  {* 元素的可见性，无可见性的为 dsNone}

  TCnDocBaseItem = class(TObject)
  {* 描述文档元素的基类}
  private
    FItems: TObjectList;
    FDeclareName: string;
    FDeclareType: string;
    FComment: string;
    FOwner: TCnDocBaseItem;
    FScope: TCnDocScope;
    function GetItem(Index: Integer): TCnDocBaseItem;
    procedure SetItem(Index: Integer; const Value: TCnDocBaseItem);
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function AddItem(Item: TCnDocBaseItem): Integer;
    {* 添加一个外部已经创建好的文档对象到内部列表并持有它}

    procedure DumpToStrings(Strs: TStrings; Indent: Integer = 0);
    {* 将内容保存到字符串列表中}

    property DeclareName: string read FDeclareName write FDeclareName;
    {* 待解释的对象名称，不同的子类有不同的规定}
    property DeclareType: string read FDeclareType write FDeclareType;
    {* 待解释的对象类型，不同的子类也有不同的用途}
    property Comment: string read FComment write FComment;
    {* 该元素的注释文档}
    property Scope: TCnDocScope read FScope write FScope;
    {* 该元素的可见性}
    property Owner: TCnDocBaseItem read FOwner write FOwner;
    {* 该元素从属哪一个父元素}

    property Items[Index: Integer]: TCnDocBaseItem read GetItem write SetItem; default;
    {* 该元素的子元素列表}
    property Count: Integer read GetCount;
    {* 该元素的子元素数量}
  end;

  TCnDocUnit = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的单元的对象}
  end;

  TCnConstDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的常量对象}
  end;

  TCnVarDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的变量对象}
  end;

  TCnProcedureDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的函数过程对象}
  end;

  TCnTypeDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的类型对象}
  end;

  TCnPropertyDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的属性对象}
  end;

function CreateUnitDocFromFileName(const FileName: string): TCnDocUnit;
{* 根据源码文件，分析内部的代码注释，返回新创建的单元注释对象供输出}

implementation

uses
  CnPascalAst, mPasLex;

const
  COMMENT_NODE_TYPE = [cntLineComment, cntBlockComment];
  COMMENT_NONE = '<none>';

{ TCnDocBaseItem }

function TCnDocBaseItem.AddItem(Item: TCnDocBaseItem): Integer;
begin
  FItems.Add(Item);
  Item.Owner := Self;
  Result := FItems.Count;
end;

constructor TCnDocBaseItem.Create;
begin
  FItems := TObjectList.Create(True);
end;

destructor TCnDocBaseItem.Destroy;
begin
  inherited;
  FItems.Free;
end;

procedure TCnDocBaseItem.DumpToStrings(Strs: TStrings; Indent: Integer);
var
  I: Integer;

  function Spcs(Cnt: Integer): string;
  begin
    if Cnt < 0 then
      Result := ''
    else
    begin
      SetLength(Result, Cnt);
      FillChar(Result[1], Cnt, 32);
    end;
  end;

begin
  if Indent < 0 then
    Indent := 0;

  Strs.Add(Spcs(Indent * 2) + FDeclareName);
//  Strs.Add(Spcs(Indent * 2) + FDeclareType);
  Strs.Add(Spcs(Indent * 2) + FComment);
  Strs.Add('');

  for I := 0 to FItems.Count - 1 do
    Items[I].DumpToStrings(Strs, Indent + 1);
end;

function TCnDocBaseItem.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TCnDocBaseItem.GetItem(Index: Integer): TCnDocBaseItem;
begin
  Result := TCnDocBaseItem(FItems[Index]);
end;

procedure TCnDocBaseItem.SetItem(Index: Integer;
  const Value: TCnDocBaseItem);
begin
  FItems[Index] := Value;
end;

function CreateUnitDocFromFileName(const FileName: string): TCnDocUnit;
var
  AST: TCnPasAstGenerator;
  SL: TStrings;
  TempLeaf, UnitLeaf, IntfLeaf: TCnPasAstLeaf;
  I: Integer;

  function DocSkipToChild(ParentLeaf: TCnPasAstLeaf; var Index: Integer;
    MatchedNodeTypes: TCnPasNodeTypes; MatchedTokenKinds: TTokenKinds): TCnPasAstLeaf;
  begin
    // 从 ParentLeaf 的第 Index 个子节点开始找符合的节点，返回符合的，或者 nil
    Result := nil;
    if Index >= ParentLeaf.Count then
      Exit;

    while Index < ParentLeaf.Count do
    begin
      if (ParentLeaf[Index].NodeType in MatchedNodeTypes) and
        (ParentLeaf[Index].TokenKind in MatchedTokenKinds) then
      begin
        Result := ParentLeaf[Index];
        Exit;
      end;
      Inc(Index);
    end;
  end;

  // 从 ParentLeaf 的第 Index 个子节点起收集注释并拼一块。
  // 如果 Index 是注释处，则 Index 会步进到最后一个注释处，否则 Index 减一
  function DocCollectComments(ParentLeaf: TCnPasAstLeaf; var Index: Integer): string;
  begin
    if (Index < ParentLeaf.Count) and (ParentLeaf[Index].NodeType in COMMENT_NODE_TYPE) then
    begin
      // 表示有注释，批量添加到一起
      SL.Clear;
      repeat
        SL.Add(ParentLeaf[Index].Text);
        Inc(Index);
      until (Index >= ParentLeaf.Count) or not (ParentLeaf[Index].NodeType in COMMENT_NODE_TYPE);
      Dec(Index); // 回到最后一个注释处

      Result := Trim(SL.Text);
    end
    else
    begin
      Result := COMMENT_NONE;
      if Index > 0 then
        Dec(Index);
    end;
  end;

  // 下属子节点三个一组排列：CONSTDECL（子节点是名称）、分号、单个注释块
  procedure DocFindConsts(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf: TCnPasAstLeaf;
    Item: TCnConstDocItem;
  begin
    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := DocSkipToChild(ParentLeaf, K, [cntConstDecl], [tkNone]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Const Decl Exists.');

      Item := TCnConstDocItem.Create;
      if Leaf.Count > 0 then
        Item.DeclareName := Leaf[0].Text; // 常量名

      Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Const Semicolon Exists.');

      Inc(K); // 步进到下一个可能是注释的地方，如果是注释，K 指向注释末尾，如果不是，K 会减一以抵消此次步进
      Item.Comment := DocCollectComments(ParentLeaf, K);
      OwnerItem.AddItem(Item);
      Inc(K);
    end;
  end;

  // 下属子节点三个一组排列：VARDECL（子节点是名称）、分号、单个注释块
  procedure DocFindVars(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf: TCnPasAstLeaf;
    Item: TCnVarDocItem;
  begin
    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := DocSkipToChild(ParentLeaf, K, [cntVarDecl], [tkNone]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Var Decl Exists.');

      Item := TCnVarDocItem.Create;
      if Leaf.Count > 0 then
        if Leaf[0].Count > 0 then
          Item.DeclareName := Leaf[0][0].Text; // IDENTList 的第一个变量名

      Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Var Semicolon Exists.');

      Inc(K); // 步进到下一个可能是注释的地方，如果是注释，K 指向注释末尾，如果不是，K 会减一以抵消此次步进
      Item.Comment := DocCollectComments(ParentLeaf, K);
      OwnerItem.AddItem(Item);
      Inc(K);
    end;
  end;

  // 与同级节点三个一组：procedure/function（子节点是名称）、分号、单个注释块
  // 注意这里 ParentLeaf 是 procedure/function 节点，Index 是该节点在父节点中的索引
  procedure DocFindProcedures(ParentLeaf: TCnPasAstLeaf; var Index: Integer; OwnerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf, P: TCnPasAstLeaf;
    Item: TCnProcedureDocItem;
  begin
    K := 0;
    Leaf := DocSkipToChild(ParentLeaf, K, [cntIdent], [tkIdentifier]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Procedure/Function Ident Exists.');

    Item := TCnProcedureDocItem.Create;
    Item.DeclareName := Leaf.Text; // 独立过程名

    // 往父一层去找分号与注释
    P := ParentLeaf.Parent;
    Leaf := DocSkipToChild(P, Index, [cntSemiColon], [tkSemiColon]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Procedure/Function Semicolon Exists.');

    Inc(Index); // 步进到下一个可能是注释的地方，如果是注释，Index 指向注释末尾，如果不是，Index 会减一以抵消此次步进
    Item.Comment := DocCollectComments(P, Index);
    OwnerItem.AddItem(Item);
  end;

  // 解析一个 property，ParentLeaf 是 Property 的唯一父节点，需遍历其子节点
  procedure DocFindProperty(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf: TCnPasAstLeaf;
    Item: TCnPropertyDocItem;
  begin
    K := 0;
    Leaf := DocSkipToChild(ParentLeaf, K, [cntIdent], [tkIdentifier]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Property Ident Exists.');

    Item := TCnPropertyDocItem.Create;
    Item.DeclareName := Leaf.Text;

    Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Property Semicolon Exists.');

    Inc(K);
    Item.Comment := DocCollectComments(ParentLeaf, K);
    OwnerItem.AddItem(Item);
  end;

  // 解析 interface 或 class 的成员，包括函数/过程、Field、属性等
  procedure DocFindMembers(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
  var
    K: Integer;
    Leaf: TCnPasAstLeaf;
  begin
    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := ParentLeaf[K];
      if Leaf.NodeType in [cntProcedure, cntFunction] then
      begin
        DocFindProcedures(Leaf, K, OwnerItem);
        Inc(K);
      end
      else if Leaf.NodeType = cntProperty then
      begin
        DocFindProperty(Leaf, OwnerItem);
        Inc(K);
      end
      else
      begin
        Inc(K);
      end;
    end;
  end;

  // 下属子节点三个一组排列：TYPEDECL（子节点是名称）、分号、可能有的单个注释块
  procedure DocFindTypes(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
  var
    K, J: Integer;
    Leaf, ClassIntfRoot: TCnPasAstLeaf;
    Item: TCnTypeDocItem;
    IsIntf, IsClass: Boolean;
  begin
    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := DocSkipToChild(ParentLeaf, K, [cntTypeDecl], [tkNone]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Type Decl Exists.');

      Item := TCnTypeDocItem.Create;
      if Leaf.Count > 0 then
        Item.DeclareName := Leaf[0].Text; // 先拿到类型名

      // 判断 Leaf 的下标为 2 的子节点类型，如果是 RESTRICTEDTYPE，则表示是 interface、class 额外处理
      // 如果是 COMMMONTYPE 且再后面的俩子节点是 packed record 或一个 record，也要额外处理
      IsIntf := False;
      IsClass := False;
      if (Leaf.Count >= 2) and (Leaf[2].NodeType = cntRestrictedType) then
      begin
        if Leaf[2].Count > 0 then
        begin
          ClassIntfRoot := Leaf[2][0];
          if Leaf[2][0].NodeType = cntInterfaceType then
          begin
            IsIntf := True;
            J := 0;
            if (ClassIntfRoot.Count > 0) and (ClassIntfRoot[0].NodeType in COMMENT_NODE_TYPE) then
            begin
              // 无继承关系时，该接口的注释可能在 Leaf[2][0] 的第 0 个子节点
              Item.Comment := DocCollectComments(ClassIntfRoot, J);
            end
            else if (ClassIntfRoot.Count > 0) and (ClassIntfRoot[0].NodeType = cntInterfaceHeritage) then
            begin
              // 有继承关系时，该接口的注释可能在 Leaf[2][0] 的第 0 个子节点的子节点里右括号后的
              Leaf := ClassIntfRoot[0];
              if Leaf.Count > 0 then
              begin
                J := 0;
                Leaf := DocSkipToChild(Leaf, J, [cntRoundClose], [tkRoundClose]);
                if Leaf <> nil then
                begin
                  Inc(J);
                  Item.Comment := DocCollectComments(Leaf, J);
                end;
              end;
            end;
          end
          else if Leaf[2][0].NodeType = cntClassType then
          begin
            IsClass := True;
            J := 0;
            if (ClassIntfRoot.Count > 0) and (ClassIntfRoot[0].NodeType in COMMENT_NODE_TYPE) then
            begin
              // 无继承关系时，该类的注释可能在 Leaf[2][0] 的第 0 个子节点
              Item.Comment := DocCollectComments(ClassIntfRoot, J);
            end
            else if (ClassIntfRoot.Count > 0) and (ClassIntfRoot[0].NodeType = cntClassBody) then
            begin
              // 有继承关系时，该接口的注释可能在 Leaf[2][0] 的第 0 个子节点的第 0 个子节点里的右括号后的
              ClassIntfRoot := ClassIntfRoot[0]; // Class Body
              if ClassIntfRoot.Count > 0 then
                Leaf := ClassIntfRoot[0];        // Class Heritage

              if Leaf.Count > 0 then
              begin
                J := 0;
                Leaf := DocSkipToChild(Leaf, J, [cntRoundClose], [tkRoundClose]);
                if Leaf <> nil then
                begin
                  Inc(J);
                  Item.Comment := DocCollectComments(Leaf, J);
                end;
              end;
            end;
          end;
        end;
      end;

      if IsIntf or IsClass then
      begin
        // ClassIntfRoot 指向比较通用的一个父节点，ClassBody 或 interface
        // 解析完其下属内容，把 K 步进到完毕的位置
        DocFindMembers(ClassIntfRoot, Item);
        OwnerItem.AddItem(Item);

        Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
        if Leaf = nil then
          raise ECnPasCodeDocException.Create('NO Type Semicolon Exists.');
        // 找分号，后没注释了
        Inc(K);
      end
      else // 其他普通类型
      begin
        Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
        if Leaf = nil then
          raise ECnPasCodeDocException.Create('NO Type Semicolon Exists.');

        Inc(K); // 步进到下一个可能是注释的地方，如果是注释，K 指向注释末尾，如果不是，K 会减一以抵消此次步进
        Item.Comment := DocCollectComments(ParentLeaf, K);
        OwnerItem.AddItem(Item);
        Inc(K);
      end;
    end;
  end;


begin
  Result := nil;
  if not FileExists(FileName) then
    Exit;

  AST := nil;
  SL := nil;

  try
    SL := TStringList.Create;
    SL.LoadFromFile(FileName);

    AST := TCnPasAstGenerator.Create(SL.Text);
    AST.Build;

    // Root 下面找直属的 Unit 节点，Unit 的子节点是分号、名字、之后的所有注释拼成注释。
    // 之后找 interface 节点。以 interface 节点为父节点分别找直属的 const、type、var、procedure、function 等直属节点
    // 针对每个节点，解析其所有子节点并拿注释。
    UnitLeaf := nil;
    for I := 0 to AST.Tree.Root.Count - 1 do
    begin
      if (AST.Tree.Root.Items[I].NodeType = cntUnit) and (AST.Tree.Root.Items[I].TokenKind = tkUnit) then
      begin
        UnitLeaf := AST.Tree.Root.Items[I];
        Break;
      end;
    end;

    if UnitLeaf = nil then
      raise ECnPasCodeDocException.Create('NO Unit Exists.');

    Result := TCnDocUnit.Create;

    // 找 Unit 名
    I := 0;
    TempLeaf := DocSkipToChild(UnitLeaf, I, [cntIdent], [tkIdentifier]);
    if TempLeaf <> nil then
      Result.DeclareName := TempLeaf.Text;

    // 找分号
    TempLeaf := DocSkipToChild(UnitLeaf, I, [cntSemiColon], [tkSemiColon]);
    if TempLeaf = nil then
      raise ECnPasCodeDocException.Create('NO Unit Semicolon Exists.');

    // 找分号后的一批注释
    Inc(I);
    Result.Comment := DocCollectComments(UnitLeaf, I);

    // 找 interface 节点
    IntfLeaf := DocSkipToChild(UnitLeaf, I, [cntInterfaceSection], [tkInterface]);
    if IntfLeaf = nil then
      raise ECnPasCodeDocException.Create('NO InterfaceSection Part Exists.');

    // 找 interface 节点下的直属节点们并解析
    I := 0;
    while I < IntfLeaf.Count do
    begin
      case IntfLeaf[I].NodeType of
        cntConstSection: // 包括 const 和 resourcestring
          begin
            DocFindConsts(IntfLeaf[I], Result);
          end;
        cntVarSection:   // var 区
          begin
            DocFindVars(IntfLeaf[I], Result);
          end;
        cntTypeSection:  // 类型区
          begin
            // 下属子节点两种情况：
            // 简单类型，三个一组排列：TYPEDECL（子节点是名称）、分号、单个注释块
            // 但 class/record/interface 等的 TYPEDECL，注释块在其内部
            DocFindTypes(IntfLeaf[I], Result);
          end;
        cntProcedure, cntFunction:
          begin
            DocFindProcedures(IntfLeaf[I], I, Result);
          end;
      end;
      Inc(I);
    end;
  finally
    SL.Free;
    AST.Free;
  end;
end;

end.
