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
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPasCodeDoc;
{* |<PRE>
================================================================================
* 软件名称：CnPack 公共单元
* 单元名称：从 CnPack 的代码中抽取注释形成文档的工具单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin7 + Delphi 5
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2022.04.02 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

{$I CnPack.inc}

interface

uses
  Classes, SysUtils, Contnrs, CnPascalAst;

type
  ECnPasCodeDocException = class(Exception);
  {* 解析代码文档异常}

  TCnDocType = (dtUnit, dtConst, dtType, dtProcedure, dtVar, dtField, dtProperty);
  {* 支持文档的元素类型}

  TCnDocScope = (dsNone, dsPrivate, dsProtected, dsPublic, dsPublished);
  {* 元素的可见性，无可见性的为 dsNone}

  TCnScanProcDeclEvent = procedure (ProcLeaf: TCnPasAstLeaf; Visibility: TCnDocScope;
    const CurrentTypeName: string) of object;
  {* 扫描 Pascal 源文件时遇到函数过程声明时的回调，其中 ProcLeaf 下的结构类似如下：
    function
      <FunctionName>
      FormalParameters
        (
          FormalParam
            IdentList
              A
              ,
              B
            :
            CommonType
              TypeID
                Int64
          ;
          FormalParam
            ...
          FormalParam
            ...
        )
      :
      COMMONTYPE
        TypeID
          Boolean
  }

  TCnDocBaseItem = class(TObject)
  {* 描述文档元素的基类}
  private
    FItems: TObjectList;
    FDeclareName: string;
    FDeclareType: string;
    FComment: string;
    FOwner: TCnDocBaseItem;
    FScope: TCnDocScope;
    FDocType: TCnDocType;
    function GetItem(Index: Integer): TCnDocBaseItem;
    procedure SetItem(Index: Integer; const Value: TCnDocBaseItem);
    function GetCount: Integer;
  protected
    procedure Sort; virtual;
    {* 内部排序}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function AddItem(Item: TCnDocBaseItem): Integer;
    {* 添加一个外部已经创建好的文档对象到内部列表并持有它}
    procedure Exchange(Index1, Index2: Integer);
    {* 根据索引交换两个子对象}
    procedure Delete(Index: Integer);
    {* 根据索引删除子对象}
    function Extract(Item: TCnDocBaseItem): TCnDocBaseItem;
    {* 从列表中抽离子对象，但不释放它}

    procedure DumpToStrings(Strs: TStrings; Indent: Integer = 0);
    {* 将内容保存到字符串列表中}

    function GetScopeStr: string;
    {* 返回 FScope 对应的字符串}

    property DocType: TCnDocType read FDocType;
    {* 文档元素类型}

    property DeclareName: string read FDeclareName write FDeclareName;
    {* 待解释的对象名称，不同的子类有不同的规定}
    property DeclareType: string read FDeclareType write FDeclareType;
    {* 待解释的对象类型，不同的子类也有不同的用途，常用于存储完整声明}
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
  private
    FUnitBrief: string;
  protected
    procedure Sort; override;
    {* 按常量、类型声明、函数过程、变量排序}
  public
    constructor Create; override;
    {* 构造函数}

    procedure ParseBrief;
    {* 从注释中解析出单元简介，以及用备注字段内容替换 Comment 属性内容}
    property UnitBrief: string read FUnitBrief write FUnitBrief;
    {* 单元简介，也就是注释头部的单元名称字段内容}
  end;

  TCnConstDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的常量对象}
  public
    constructor Create; override;
  end;

  TCnVarDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的变量对象}
  public
    constructor Create; override;
  end;

  TCnProcedureDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的函数过程对象}
  public
    constructor Create; override;
  end;

  TCnTypeDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的类型对象}
  public
    constructor Create; override;
  end;

  TCnPropertyDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的属性对象}
  public
    constructor Create; override;
  end;

  TCnFieldDocItem = class(TCnDocBaseItem)
  {* 描述一代码帮助文档中的字段对象}
  public
    constructor Create; override;
  end;

function CnCreateUnitDocFromFileName(const FileName: string): TCnDocUnit;
{* 根据源码文件，分析内部的代码注释，返回新创建的单元注释对象供输出}

procedure CnScanFileProcDecls(const FileName: string; OnScan: TCnScanProcDeclEvent);
{* 扫描 Pascal 源文件中的函数过程，包括独立的及类中的，并调用回调，传入 procedure 的 Leaf 供自定义处理
  目前处理了以下两种情况：

一：
  interface
    type
      TYPEDECL 多个
        TypeName
        =
        RESTRICTTYPE
          class
            CLASSBODY
              CLASSHERITAGE
              public
                procedure/function/constructor/destructor -- 返回这个

二：
  interface
    function                                              -- 返回这个
    procedure                                             -- 返回这个
}

implementation

uses
  mPasLex;

resourcestring
  SCnErrorSkipCommentToNode = 'Skip Comment To Node Error.';
  SCnErrorNoConstSemicolonExists = 'NO Const Semicolon Exists.';
  SCnErrorNoVarSemicolonExists = 'NO Var Semicolon Exists.';
  SCnErrorNoProcedureFunctionIdentExists = 'NO Procedure/Function Ident Exists.';
  SCnErrorNoProcedureFunctionSemicolonExists = 'NO Procedure/Function Semicolon Exists.';
  SCnErrorNoPropertyIdentExists = 'NO Property Ident Exists.';
  SCnErrorNoPropertySemicolonExists = 'NO Property Semicolon Exists.';
  SCnErrorNoClassFieldIdentExists = 'NO Class Field Ident Exists.';
  SCnErrorNoClassFieldSemicolonExists = 'NO Class Field Semicolon Exists.';
  SCnErrorNoClassInterfaceSemicolonExists = 'NO Class/Interface SemiColon Exists.';
  SCnErrorNoTypeSemicolonExists = 'NO Type Semicolon Exists.';
  SCnErrorNoUnitExists = 'NO Unit Exists.';
  SCnErrorNoUnitSemicolonExists = 'NO Unit Semicolon Exists.';
  SCnErrorNoInterfacesectionPartExists = 'NO InterfaceSection Part Exists.';
  SCnBrBr = '<br><br>';

const
  COMMENT_NODE_TYPE = [cntBlockComment, cntCRLFInComment];
  COMMENT_SKIP_NODE_TYPE = [cntBlockComment, cntLineComment, cntCRLFInComment];
  COMMENT_NONE = '<none>';

  SCOPE_STRS: array[TCnDocScope] of string =
    ('', 'private', 'protected', 'public', 'published');

function VisibilityTokenKindToDocScope(Token: TTokenKind): TCnDocScope;
begin
  case Token of
    tkPrivate:   Result := dsPrivate;
    tkProtected: Result := dsProtected;
    tkPublic:    Result := dsPublic;
    tkPublished: Result := dsPublished;
  else
    Result := dsNone;
  end;
end;

// 从 ParentLeaf 的第 0 个子节点开始越过注释找符合的节点，返回符合的节点，不符合则抛出异常且返回 nil
function DocSkipCommentToChild(ParentLeaf: TCnPasAstLeaf;
  MatchedNodeTypes: TCnPasNodeTypes; NeedRaise: Boolean = True): TCnPasAstLeaf;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ParentLeaf.Count - 1 do
  begin
    if ParentLeaf[I].NodeType in MatchedNodeTypes then
    begin
      Result := ParentLeaf[I];
      Exit;
    end;

    if not (ParentLeaf[I].NodeType in COMMENT_SKIP_NODE_TYPE) then
      if NeedRaise then
        raise ECnPasCodeDocException.Create(SCnErrorSkipCommentToNode);
  end;
end;

// 从 ParentLeaf 的第 Index 个子节点开始找符合的节点，返回符合的节点以及更新后的 Index，不符合则返回 nil。Index 均会步进
function DocSkipToChild(ParentLeaf: TCnPasAstLeaf; var Index: Integer;
  MatchedNodeTypes: TCnPasNodeTypes; MatchedTokenKinds: TTokenKinds): TCnPasAstLeaf;
begin
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

// 如果 ParentLeaf 的第 Index 个子节点是分号或 Directive，就跳过，直到非 Directive 且非分号的地方，再回退一
// 进入时 Index 应该指向 Directive 之前的分号
procedure DocSkipDirective(ParentLeaf: TCnPasAstLeaf; var Index: Integer);
begin
  Inc(Index);
  while Index < ParentLeaf.Count do
  begin
    if not (ParentLeaf[Index].NodeType in [cntSemiColon, cntDirective, cntDefault]) then
      Break;    // 可能还有其他不包括在 cntDirective 中的关键字

    Inc(Index);
  end;
  Dec(Index);
end;

// 从 ParentLeaf 的第 Index 个子节点起收集注释并拼一块。
// 如果 Index 是注释处，则 Index 会步进到最后一个注释处，否则 Index 减一
function DocCollectComments(ParentLeaf: TCnPasAstLeaf; var Index: Integer): string;
var
  S: string;
  SL: TStrings;
  PrevType: TCnPasNodeType;
begin
  if (Index < ParentLeaf.Count) and (ParentLeaf[Index].NodeType in COMMENT_NODE_TYPE) then
  begin
    S := ParentLeaf[Index].Text;
    if (Length(S) > 2) and (S[1] = '{') and (S[2] = '*') then
    begin
      // 表示有符合要求的注释，批量添加到一起
      SL := TStringList.Create;
      try
        PrevType := cntInvalid;
        repeat
          if (PrevType = cntCRLFInComment) and (ParentLeaf[Index].NodeType = cntCRLFInComment) then // 本身是块注释后的换行，且上一个也是，就添加一个空行
            SL.Add('')
          else if ParentLeaf[Index].NodeType <> cntCRLFInComment then // 单独的 cntCRLFInComment 不增加空行也不增加回车换行本身
            SL.Add(ParentLeaf[Index].Text);

          PrevType := ParentLeaf[Index].NodeType;
          Inc(Index);
        until (Index >= ParentLeaf.Count) or not (ParentLeaf[Index].NodeType in COMMENT_NODE_TYPE);
        Dec(Index); // 回到最后一个注释处

        Result := Trim(SL.Text);
        Exit;
      finally
        SL.Free;
      end;
    end;
  end;

  Result := '';
  if Index > 0 then
    Dec(Index);
end;

// 传入 const 节点，下属子节点三个一组排列：CONSTDECL（子节点是名称）、分号、单个注释块
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
    begin
      Inc(K);
      Continue;
    end;
    //  raise ECnPasCodeDocException.Create('NO Const Decl Exists.');

    Item := TCnConstDocItem.Create;
    if Leaf.Count > 0 then
    begin
      Item.DeclareName := Leaf[0].Text; // 常量名
      Item.DeclareType := Leaf.GetPascalCode; // 拿常量的完整声明，包括有类型和无类型两种
    end;

    Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create(SCnErrorNoConstSemicolonExists);

    Inc(K); // 步进到下一个可能是注释的地方，如果是注释，K 指向注释末尾，如果不是，K 会减一以抵消此次步进
    Item.Comment := DocCollectComments(ParentLeaf, K);
    OwnerItem.AddItem(Item);
    Inc(K);
  end;
end;

// var 下属子节点三个一组排列：VARDECL（子节点是名称）、分号、单个注释块
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
    begin
      Inc(K);
      Continue;
    end;
    // raise ECnPasCodeDocException.Create('NO Var Decl Exists.');

    Item := TCnVarDocItem.Create;
    if Leaf.Count > 0 then
    begin
      if Leaf[0].Count > 0 then
        Item.DeclareName := Leaf[0][0].Text; // IDENTList 的第一个变量名
      Item.DeclareType := Leaf.GetPascalCode; // 拿完整声明
    end;

    Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create(SCnErrorNoVarSemicolonExists);

    Inc(K); // 步进到下一个可能是注释的地方，如果是注释，K 指向注释末尾，如果不是，K 会减一以抵消此次步进
    Item.Comment := DocCollectComments(ParentLeaf, K);
    OwnerItem.AddItem(Item);
    Inc(K);
  end;
end;

// 与同级节点三个一组：procedure/function（子节点是名称）、分号、单个注释块
// 注意这里 ParentLeaf 是 procedure/function 节点，Index 是该节点在父节点中的索引
procedure DocFindProcedure(ParentLeaf: TCnPasAstLeaf; var Index: Integer;
  OwnerItem: TCnDocBaseItem; AScope: TCnDocScope = dsNone);
var
  K: Integer;
  Leaf, P: TCnPasAstLeaf;
  Item: TCnProcedureDocItem;
begin
  K := 0;
  Leaf := DocSkipToChild(ParentLeaf, K, [cntIdent], [tkIdentifier]);
  if Leaf = nil then
    raise ECnPasCodeDocException.Create(SCnErrorNoProcedureFunctionIdentExists);

  Item := TCnProcedureDocItem.Create;
  Item.DeclareName := Leaf.Text; // 独立过程名
  Item.Scope := AScope;
  Item.DeclareType := ParentLeaf.GetPascalCode; // 获取完整过程声明，无 Directives

  // 往父一层去找分号与注释
  P := ParentLeaf.Parent;
  Leaf := DocSkipToChild(P, Index, [cntSemiColon], [tkSemiColon]);
  if Leaf = nil then
    raise ECnPasCodeDocException.Create(SCnErrorNoProcedureFunctionSemicolonExists);

  // 此处再跳过可能存在的 Directives 到最后一个分号
  DocSkipDirective(P, Index);

  Inc(Index); // 步进到下一个可能是注释的地方，如果是注释，Index 指向注释末尾，如果不是，Index 会减一以抵消此次步进
  Item.Comment := DocCollectComments(P, Index);
  OwnerItem.AddItem(Item);
end;

// 解析一个 property，ParentLeaf 是 Property 节点，Index 是 ParentLeaf 在其父节点中的索引，
// Property 节点后面并列分号和 default 等，需遍历其子节点
procedure DocFindProperty(ParentLeaf: TCnPasAstLeaf; Index: Integer; OwnerItem: TCnDocBaseItem;
  AScope: TCnDocScope = dsNone);
var
  K: Integer;
  Leaf, P: TCnPasAstLeaf;
  Item: TCnPropertyDocItem;
begin
  K := 0;
  Leaf := DocSkipToChild(ParentLeaf, K, [cntIdent], [tkIdentifier]);
  if Leaf = nil then
    raise ECnPasCodeDocException.Create(SCnErrorNoPropertyIdentExists);

  Item := TCnPropertyDocItem.Create;
  Item.DeclareName := Leaf.Text;   // 属性名
  Item.Scope := AScope;
  Item.DeclareType := ParentLeaf.GetPascalCode; // 完整属性声明

  // 往父一层去找分号与注释
  P := ParentLeaf.Parent;
  Leaf := DocSkipToChild(P, Index, [cntSemiColon], [tkSemiColon]);
  if Leaf = nil then
    raise ECnPasCodeDocException.Create(SCnErrorNoPropertySemicolonExists);

  // 此处再跳过可能存在的 Directives 到最后一个分号
  DocSkipDirective(P, Index);

  Inc(Index);
  Item.Comment := DocCollectComments(P, Index);
  OwnerItem.AddItem(Item);
end;

// ParentLeaf 是 Class 节点的 ClassField 字段节点，收集其单个 Field 的注释。Index 是 ParentLeaf 在其 Parent 中的索引
procedure DocFindField(ParentLeaf: TCnPasAstLeaf; Index: Integer; OwnerItem: TCnDocBaseItem; AScope: TCnDocScope = dsPublic);
var
  Leaf, P: TCnPasAstLeaf;
  Item: TCnFieldDocItem;
begin
  Leaf := nil;
  if (ParentLeaf.Count > 0) and (ParentLeaf[0].Count > 0) then
    Leaf := ParentLeaf[0][0];
  if (Leaf = nil) or (Leaf.NodeType <> cntIdent) then
    raise ECnPasCodeDocException.Create(SCnErrorNoClassFieldIdentExists);

  Item := TCnFieldDocItem.Create;
  Item.DeclareName := Leaf.Text; // 字段名
  Item.Scope := AScope;
  Item.DeclareType := ParentLeaf.GetPascalCode; // 完整字段声明

  // 往父一层去找分号与注释
  P := ParentLeaf.Parent;
  Leaf := DocSkipToChild(P, Index, [cntSemiColon], [tkSemiColon]);
  if Leaf = nil then
    raise ECnPasCodeDocException.Create(SCnErrorNoClassFieldSemicolonExists);

  Inc(Index); // 步进到下一个可能是注释的地方，如果是注释，Index 指向注释末尾，如果不是，Index 会减一以抵消此次步进
  Item.Comment := DocCollectComments(P, Index);
  OwnerItem.AddItem(Item);
end;

// record 节点的子节点，收集其 Field 的注释
procedure DocFindRecordFields(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem; AScope: TCnDocScope = dsPublic);
var
  K: Integer;
  Leaf: TCnPasAstLeaf;
begin
  if ParentLeaf.Count > 0 then
  begin
    ParentLeaf := DocSkipCommentToChild(ParentLeaf, [cntFieldList]); // record 到 FieldList

    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := ParentLeaf[K];
      if Leaf.NodeType = cntFieldDecl then
        DocFindField(Leaf, K, OwnerItem, AScope);
      Inc(K);
    end;
  end;
end;

// 解析 interface 或 class 的成员，包括函数/过程、Field、属性等。ParentLeaf 是 ClassBody 或 interface
procedure DocFindMembers(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem; AScope: TCnDocScope = dsNone);
var
  K: Integer;
  Leaf: TCnPasAstLeaf;
  MyScope: TCnDocScope;
begin
  K := 0;
  while K < ParentLeaf.Count do
  begin
    Leaf := ParentLeaf[K];
    if Leaf.NodeType in [cntProcedure, cntFunction] then
    begin
      DocFindProcedure(Leaf, K, OwnerItem, AScope);
      Inc(K);
    end
    else if Leaf.NodeType = cntProperty then
    begin
      DocFindProperty(Leaf, K, OwnerItem, AScope);
      Inc(K);
    end
    else if Leaf.NodeType = cntClassField then
    begin
      DocFindField(Leaf, K, OwnerItem, AScope);
      Inc(K);
    end
    else if (Leaf.NodeType = cntVisibility) and (Leaf.TokenKind in [tkProtected, tkPublic, tkPublished]) then
    begin
      MyScope := VisibilityTokenKindToDocScope(Leaf.TokenKind);
      DocFindMembers(Leaf, OwnerItem, MyScope);
      Inc(K);
    end
    else
    begin
      Inc(K);
    end;
  end;
end;

// 递归调用，深度优先遍历，遇到注释时中止。常用于获取声明中注释前的部分
function InternalGetPascalCodeFromLeafUntilComment(ALeaf: TCnPasAstLeaf; var ToAbort: Boolean): string;
var
  I: Integer;
  S: string;
  Son: TTokenKind;
begin
  if ToAbort then
  begin
    Result := '';
    Exit;
  end;

  Result := ALeaf.Text;
  for I := 0 to ALeaf.Count - 1 do
  begin
    Son := ALeaf.Items[I].TokenKind;
    if Son in [tkBorComment, tkAnsiComment, tkSlashesComment] then
    begin
      ToAbort := True;
      Exit;
    end;

    S := InternalGetPascalCodeFromLeafUntilComment(ALeaf.Items[I], ToAbort);
    if Result = '' then
      Result := S
    else if S <> '' then
    begin
      if ALeaf.NoSpaceBehind or ALeaf.Items[I].NoSpaceBefore or    // 如果本节点后面不要空格，或子节点前面不要空格
        (ALeaf.TokenKind in [tkRoundOpen, tkSquareOpen, tkPoint]) or       // 本节点这些后面不要空格
        (Son in [tkPoint, tkDotdot, tkPointerSymbol, tkSemiColon, tkColon, // 子节点这些前面不要空格
        tkRoundClose, tkSquareOpen, tkSquareClose, tkComma]) then
        Result := Result + S
      else
        Result := Result + ' ' + S;
    end;
  end;
end;

function GetPascalCodeFromLeafUntilComment(ALeaf: TCnPasAstLeaf): string;
var
  ToAbort: Boolean;
begin
  ToAbort := False;
  Result := InternalGetPascalCodeFromLeafUntilComment(ALeaf, ToAbort);
end;

// 获取接口与类声明本身的注释，ParentLeaf 指向高层的 TYPEDECL，各分四种情况
procedure DocGetClassIntfNameComments(ParentLeaf: TCnPasAstLeaf; IsClass: Boolean;
  var Comment: string; var FullType: string);
var
  I: Integer;
  Leaf, TmpLeaf: TCnPasAstLeaf;
begin
  // 有声明体 end 的，分有无显式基类两种情况寻找其注释
{
  Class 无显式基类      Class 有显式基类        Interface 无显式基类   Interface 有显式基类

  TYPEDECL              TYPEDECL                TYPEDECL               TYPEDECL
    Ident                 Ident                   Ident                  Ident
    =                     =                       =                      =
    RESTRICTEDTYPE        RESTRICTEDTYPE          RESTRICTEDTYPE         RESTRICTEDTYPE
      class                 class                   interface              interface
        注释                  CLASSBODY               注释                   INTERFACEHERITAGE
                                CLASSHERITAGE                                  (
                                  (                                            )
                                  )                                            注释
                                  注释
}

  Comment := '';
  FullType := GetPascalCodeFromLeafUntilComment(ParentLeaf);

  if ParentLeaf.Count > 2 then
  begin
    Leaf := ParentLeaf[2];
    if Leaf.Count > 0 then
    begin
      Leaf := Leaf[0]; // class/interface
      if (Leaf.Count > 0) and (Leaf[0].NodeType in COMMENT_NODE_TYPE) then
      begin
        I := 0;
        Comment := DocCollectComments(Leaf, I); // 两种无显式基类的处理
      end
      else // 两种有显式基类
      begin
        if IsClass then
        begin
          if Leaf.Count > 0 then // class 是前向声明时后面没东西
          begin
            Leaf := Leaf[0]; // ClassBody
            if Leaf.Count > 0 then
              Leaf := Leaf[0]; // CLASSHERITAGE
          end;
        end
        else if Leaf.Count > 0 then // interface 是前向声明时后面没东西
        begin
          Leaf := Leaf[0]; // INTERFACEHERITAGE
        end;

        I := 0; // 寻找右括号
        TmpLeaf := DocSkipToChild(Leaf, I, [cntRoundClose], [tkRoundClose]);
        if TmpLeaf <> nil then //
        begin
          Inc(I);
          Comment := DocCollectComments(Leaf, I);
        end;
      end;
    end;
  end;

  if Comment <> '' then
    Exit;

  // 无声明体 end 的，无论有无显式基类两种情况，都直接寻找其注释
  Leaf := ParentLeaf.Parent;
  I := ParentLeaf.Index;
  TmpLeaf := DocSkipToChild(Leaf, I, [cntSemiColon], [tkSemiColon]);
  if TmpLeaf = nil then
    raise ECnPasCodeDocException.Create(SCnErrorNoClassInterfaceSemicolonExists);

  Inc(I);
  Comment := DocCollectComments(Leaf, I);
end;

// ParentLeaf 是 type，下属子节点三个一组排列：TYPEDECL（子节点是名称）、分号、可能有的单个注释块
procedure DocFindTypes(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
var
  K, M: Integer;
  Leaf, DeclLeaf, CIRRoot, Tmp: TCnPasAstLeaf;
  Item: TCnTypeDocItem;
  IsIntf, IsClass, IsRecord: Boolean;
begin
  K := 0;
  while K < ParentLeaf.Count do
  begin
    Leaf := DocSkipToChild(ParentLeaf, K, [cntTypeDecl], [tkNone]);
    if Leaf = nil then // 没找到可能说明到尾巴了可能碰上注释了？
    begin
      Inc(K);
      Continue;
    end;
    // raise ECnPasCodeDocException.Create('NO Type Decl Exists.');

    DeclLeaf := Leaf;
    Item := TCnTypeDocItem.Create;
    if Leaf.Count > 0 then
      Item.DeclareName := Leaf[0].Text; // 类型名

    // 判断 Leaf 的下标为 2 的子节点类型，如果是 RESTRICTEDTYPE，则表示是 interface、class，要额外处理
    // 如果是 COMMMONTYPE 且再后面的俩子节点是 packed record 或一个 record，也要额外处理
    IsIntf := False;
    IsClass := False;
    IsRecord := False;
    CIRRoot := nil;

    if (Leaf.Count >= 2) and (Leaf[2].NodeType = cntRestrictedType) then
    begin
      if Leaf[2].Count > 0 then
      begin
        CIRRoot := Leaf[2][0];
        if CIRRoot.NodeType = cntInterfaceType then
          IsIntf := True
        else if CIRRoot.NodeType = cntClassType then
        begin
          IsClass := True;
          if CIRRoot.Count > 0 then
          begin
            Tmp := DocSkipCommentToChild(CIRRoot, [cntClassBody], False);
            if Tmp <> nil then
              CIRRoot := Tmp
            else
            begin
              // 返回 nil 表示是 class of xxxx 这种，似乎也不用做啥
            end;
          end;
        end;

        if IsIntf or IsClass then
          DocGetClassIntfNameComments(Leaf, IsClass, Item.FComment, Item.FDeclareType);
      end;
    end
    else if (Leaf.Count >= 2) and (Leaf[2].NodeType = cntCommonType) then
    begin
      Leaf := Leaf[2]; // 要判断 Leaf[2] 的子节点是否有 record
      M := 0;
      Leaf := DocSkipToChild(Leaf, M, [cntRecord], [tkRecord]);
      if Leaf <> nil then
      begin
        IsRecord := True;
        CIRRoot := Leaf;
        M := 0;
        Item.Comment := DocCollectComments(Leaf, M);
        Item.DeclareType := GetPascalCodeFromLeafUntilComment(DeclLeaf); // Record 类型的完整声明
      end;
    end;

    // 到此处，应该判断好 IsIntf 和 IsClass，并且 ClassIntfRoot 指向比较通用的一个父节点
    if (CIRRoot <> nil) and (IsIntf or IsClass or IsRecord) then
    begin
      // CIRRoot 指向比较通用的一个父节点，ClassBody 或 interface 或 record
      // 解析完其下属内容，把 K 步进到完毕的位置
      if IsIntf or IsClass then
      begin
        DocFindMembers(CIRRoot, Item);
        OwnerItem.AddItem(Item);
      end
      else
      begin
        DocFindRecordFields(CIRRoot, Item);
        OwnerItem.AddItem(Item);
      end;

      Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create(SCnErrorNoTypeSemicolonExists);
      // 找分号，后没注释了
      Inc(K);
    end
    else // 其他普通类型
    begin
      Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create(SCnErrorNoTypeSemicolonExists);

      Item.DeclareType := DeclLeaf.GetPascalCode; // 简单类型的完整声明

      Inc(K); // 步进到下一个可能是注释的地方，如果是注释，K 指向注释末尾，如果不是，K 会减一以抵消此次步进
      Item.Comment := DocCollectComments(ParentLeaf, K);
      OwnerItem.AddItem(Item);
      Inc(K);
    end;
  end;
end;

function CnCreateUnitDocFromFileName(const FileName: string): TCnDocUnit;
var
  AST: TCnPasAstGenerator;
  SL: TStrings;
  TempLeaf, UnitLeaf, IntfLeaf: TCnPasAstLeaf;
  I: Integer;
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
      raise ECnPasCodeDocException.Create(SCnErrorNoUnitExists);

    Result := TCnDocUnit.Create;

    // 找 Unit 名
    I := 0;
    TempLeaf := DocSkipToChild(UnitLeaf, I, [cntIdent], [tkIdentifier]);
    if TempLeaf <> nil then
      Result.DeclareName := TempLeaf.Text;

    // 找分号
    TempLeaf := DocSkipToChild(UnitLeaf, I, [cntSemiColon], [tkSemiColon]);
    if TempLeaf = nil then
      raise ECnPasCodeDocException.Create(SCnErrorNoUnitSemicolonExists);

    // 找分号后的一批注释
    Inc(I);
    Result.Comment := DocCollectComments(UnitLeaf, I);

    // 找 interface 节点
    IntfLeaf := DocSkipToChild(UnitLeaf, I, [cntInterfaceSection], [tkInterface]);
    if IntfLeaf = nil then
      raise ECnPasCodeDocException.Create(SCnErrorNoInterfacesectionPartExists);

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
            DocFindProcedure(IntfLeaf[I], I, Result);
          end;
      end;
      Inc(I);
    end;

    Result.Sort;
    Result.ParseBrief;
  finally
    SL.Free;
    AST.Free;
  end;
end;

procedure DocTypeBubbleSort(RootItem: TCnDocUnit);
var
  I, J: Integer;
begin
  for I := 0 to RootItem.Count - 1 do
    for J := 0 to RootItem.Count - I - 2 do
      if Ord(RootItem[J].DocType) > Ord(RootItem[J + 1].DocType) then
        RootItem.Exchange(J, J + 1);
end;

procedure DocScopeBubbleSort(RootItem: TCnDocBaseItem);
var
  I, J: Integer;
begin
  for I := 0 to RootItem.Count - 1 do
    for J := 0 to RootItem.Count - I - 2 do
      if Ord(RootItem[J].Scope) > Ord(RootItem[J + 1].Scope) then
        RootItem.Exchange(J, J + 1);
end;

procedure SortDocUnit(RootItem: TCnDocUnit);
var
  I: Integer;
begin
  // Unit 的下一级，0 到 Count - 1 个，按 const、type、procedure、var 的顺序排序合并
  DocTypeBubbleSort(RootItem); // 用冒泡而不用快排是因为需要保持原位稳定

  // 每个类或接口，下面的按 Scope 排序
  for I := 0 to RootItem.Count - 1 do
  begin
    if RootItem[I].Count > 1 then
      DocScopeBubbleSort(RootItem[I]);
  end;
end;

procedure CnScanFileProcDecls(const FileName: string; OnScan: TCnScanProcDeclEvent);
var
  AST: TCnPasAstGenerator;
  SL, Pars: TStringList;
  UnitLeaf, IntfLeaf, TypeLeaf, ClassLeaf, VisibilityLeaf: TCnPasAstLeaf;
  I, I1, I2, I3, I4: Integer;
  CurrTypeName: string;
begin
  SL := nil;
  AST := nil;
  Pars := nil;

  try
    SL := TStringList.Create;
    SL.LoadFromFile(FileName);

    AST := TCnPasAstGenerator.Create(SL.Text);
    AST.Build;

    UnitLeaf := nil;
    Pars := TStringList.Create;
    for I := 0 to AST.Tree.Root.Count - 1 do
    begin
      if (AST.Tree.Root.Items[I].NodeType = cntUnit) and (AST.Tree.Root.Items[I].TokenKind = tkUnit) then
      begin
        UnitLeaf := AST.Tree.Root.Items[I];
        Break;
      end;
    end;

    if UnitLeaf = nil then
      Exit;

    // 找 interface 节点
    IntfLeaf := nil;
    I := 0;
    while I < UnitLeaf.Count do
    begin
      if (UnitLeaf[I].NodeType in [cntInterfaceSection]) and
        (UnitLeaf[I].TokenKind in [tkInterface]) then
      begin
        IntfLeaf := UnitLeaf[I];
        Break;
      end;
      Inc(I);
    end;

    if IntfLeaf = nil then
      Exit;

    // 找 interface 节点下的直属节点们并解析
    I := 0;
    while I < IntfLeaf.Count do
    begin
      case IntfLeaf[I].NodeType of
        cntTypeSection:  // 类型区
          begin
            TypeLeaf := IntfLeaf[I];
            for I1 := 0 to TypeLeaf.Count - 1 do
            begin
              if (TypeLeaf[I1].NodeType = cntTypeDecl) and (TypeLeaf[I1].Count >= 3) then
              begin
                // 记录 TypeName
                CurrTypeName := TypeLeaf[I1][0].Text;
                for I2 := 0 to TypeLeaf[I1].Count - 1 do
                begin
                  if (TypeLeaf[I1][I2].NodeType = cntRestrictedType) and (TypeLeaf[I1][I2].Count >= 1)
                    and (TypeLeaf[I1][I2][0].NodeType = cntClassType) then
                  begin
                    ClassLeaf := TypeLeaf[I1][I2][0];
                    if ((ClassLeaf.Count > 0) and (ClassLeaf[0].NodeType = cntClassBody)) or // 可能 0 是一个注释
                      ((ClassLeaf.Count > 1) and (ClassLeaf[1].NodeType = cntClassBody))then
                    begin
                      if (ClassLeaf.Count > 0) and (ClassLeaf[0].NodeType = cntClassBody) then
                        ClassLeaf := ClassLeaf[0]
                      else
                        ClassLeaf := ClassLeaf[1];

                      for I3 := 0 to ClassLeaf.Count - 1 do
                      begin
                        if (ClassLeaf[I3].NodeType = cntVisibility) {and (ClassLeaf[I3].TokenKind = tkPublic)} then
                        begin
                          VisibilityLeaf := ClassLeaf[I3];
                          for I4 := 0 to VisibilityLeaf.Count - 1 do
                          begin
                            if VisibilityLeaf[I4].NodeType in [cntProcedure, cntFunction] then
                              OnScan(VisibilityLeaf[I4], VisibilityTokenKindToDocScope(VisibilityLeaf.TokenKind), CurrTypeName);
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        cntProcedure, cntFunction:
          begin
            OnScan(IntfLeaf[I], dsNone, '');
          end;
      end;
      Inc(I);
    end;
  finally
    Pars.Free;
    AST.Free;
    SL.Free;
  end;
end;

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

procedure TCnDocBaseItem.Delete(Index: Integer);
begin
  FItems.Delete(Index);
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
  if FScope <> dsNone then
    Strs.Add(Spcs(Indent * 2) + SCOPE_STRS[FScope]);
  Strs.Add(Spcs(Indent * 2) + FDeclareType);
  Strs.Add(Spcs(Indent * 2) + FComment);
  Strs.Add('');

  for I := 0 to FItems.Count - 1 do
    Items[I].DumpToStrings(Strs, Indent + 1);
end;

procedure TCnDocBaseItem.Exchange(Index1, Index2: Integer);
begin
  FItems.Exchange(Index1, Index2);
end;

function TCnDocBaseItem.Extract(Item: TCnDocBaseItem): TCnDocBaseItem;
begin
  Result := TCnDocBaseItem(FItems.Extract(Item));
end;

function TCnDocBaseItem.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TCnDocBaseItem.GetItem(Index: Integer): TCnDocBaseItem;
begin
  Result := TCnDocBaseItem(FItems[Index]);
end;

function TCnDocBaseItem.GetScopeStr: string;
begin
  Result := SCOPE_STRS[FScope];
end;

procedure TCnDocBaseItem.SetItem(Index: Integer;
  const Value: TCnDocBaseItem);
begin
  FItems[Index] := Value;
end;

procedure TCnDocBaseItem.Sort;
begin
  // 基类啥都不做
end;

{ TCnDocUnit }

constructor TCnDocUnit.Create;
begin
  inherited;
  FDocType := dtUnit;
end;

procedure TCnDocUnit.ParseBrief;
const
  UNIT_NAME = '* 单元名称：';
  MEMO_START = '* 备    注：';
  MEMO_BODY = '*   ';
var
  I: Integer;
  SL, MO: TStringList;
  MF: Boolean;
begin
  // Comment 属性里找合适的内容
  SL := TStringList.Create;
  MO := TStringList.Create;

  try
    SL.Text := FComment;
    MF := False;

    for I := 0 to SL.Count - 1 do
    begin
      if Pos(UNIT_NAME, SL[I]) = 1 then
        FDeclareType := Copy(SL[I], Length(UNIT_NAME) + 1, MaxInt)
      else if Pos(MEMO_START, SL[I]) = 1 then
      begin
        MO.Add(Copy(SL[I], Length(MEMO_START) + 1, MaxInt));
        MF := True;
      end
      else if MF then
      begin
        if Pos(MEMO_BODY, SL[I]) = 1 then
          MO.Add(Copy(SL[I], Length(MEMO_BODY) + 1, MaxInt))
        else if Trim(SL[I]) = '*' then // 注释中的空行，留着做硬回车
          MO.Add('')
        else
          Break;
      end;
    end;

    FComment := MO.Text;
    FComment := StringReplace(FComment, #13#10#13#10, SCnBrBr, [rfReplaceAll]);
  finally
    MO.Free;
    SL.Free;
  end;
end;

procedure TCnDocUnit.Sort;
begin
  SortDocUnit(Self);
end;

{ TCnConstDocItem }

constructor TCnConstDocItem.Create;
begin
  inherited;
  FDocType := dtConst;
end;

{ TCnVarDocItem }

constructor TCnVarDocItem.Create;
begin
  inherited;
  FDocType := dtVar;
end;

{ TCnProcedureDocItem }

constructor TCnProcedureDocItem.Create;
begin
  inherited;
  FDocType := dtProcedure;
end;

{ TCnTypeDocItem }

constructor TCnTypeDocItem.Create;
begin
  inherited;
  FDocType := dtType;
end;

{ TCnPropertyDocItem }

constructor TCnPropertyDocItem.Create;
begin
  inherited;
  FDocType := dtProperty;
end;

{ TCnFieldDocItem }

constructor TCnFieldDocItem.Create;
begin
  inherited;
  FDocType := dtField;
end;

end.
