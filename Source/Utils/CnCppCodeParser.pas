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

unit CnCppCodeParser;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：C/C++ 源代码分析器
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2016.03.15
*               增加解析并获取源文件中 include 内容的功能
*           2012.02.07
*               UTF8 的位置转换去除后仍有问题，恢复之
*           2011.11.29
*               XE/XE2 的位置解析无需 UTF8 的位置转换
*           2011.05.29
*               修正 BDS 下对汉字 UTF8 未处理而导致解析出错的问题
*           2009.04.10
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Contnrs, CnPasCodeParser, 
  mwBCBTokenList, CnCommon, {$IFDEF IDE_WIDECONTROL} CnWideStrings, {$ENDIF} CnFastList;

const
  CN_CPP_BRACKET_NAMESPACE = 1;

type

//==============================================================================
// C/C++ 解析器封装类，目前只实现解析大括号层次与普通标识符位置的功能
//==============================================================================

{ TCnCppStructureParser }

  TCnCppToken = class(TCnPasToken)
  {* 描述一 Token 的结构高亮信息}
  private
    FIsNameSpace: Boolean;
  public
    constructor Create;

    procedure Clear; override;
  published
    // 注意父类 Pas 解析出来的 LineNumber 与 CharIndex 都是 0 开始的，
    // 现在 Cpp 解析器解析出来的 LineNumber 与 CharIndex 也是 0 开始的

    property IsNameSpace: Boolean read FIsNameSpace write FIsNameSpace;
    {* 是否是 namespace 的对应大括号}
  end;

  TCnCppStructureParser = class(TObject)
  {* 利用 CParser 进行语法解析得到各个 Token 和位置信息}
  private
    FSupportUnicodeIdent: Boolean;
    FBlockCloseToken: TCnCppToken;
    FBlockStartToken: TCnCppToken;
    FChildCloseToken: TCnCppToken;
    FChildStartToken: TCnCppToken;
    FNonNamespaceCloseToken: TCnCppToken;
    FNonNamespaceStartToken: TCnCppToken;
    FCurrentChildMethod: AnsiString;
    FCurrentMethod: AnsiString;
    FList: TCnList;
    FInnerBlockCloseToken: TCnCppToken;
    FInnerBlockStartToken: TCnCppToken;
    FCurrentClass: AnsiString;
    FSource: AnsiString;
    FBlockIsNamespace: Boolean;
    FUseTabKey: Boolean;
    FTabWidth: Integer;
    function GetCount: Integer;
    function GetToken(Index: Integer): TCnCppToken;
  protected
    function NewToken(CParser: TBCBTokenList; Layer: Integer = 0): TCnCppToken;
  public
    constructor Create(SupportUnicodeIdent: Boolean = False);
    destructor Destroy; override;
    procedure Clear;
    procedure ParseSource(ASource: PAnsiChar; Size: Integer; CurrLine: Integer = 0;
      CurCol: Integer = 0; ParseCurrent: Boolean = False; NeedRoundSquare: Boolean = False);
    {* 解析代码结构，行列均以 1 开始。ParseCurrent 指是否解析当前函数等内容，
      NeedRoundSquare 表示需要解析小括号和中括号以及分号}

    procedure ParseString(ASource: PAnsiChar; Size: Integer);
    {* 对代码进行针对字符串的解析，只生成字符串内容}

    function IndexOfToken(Token: TCnCppToken): Integer;
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TCnCppToken read GetToken;

    property ChildStartToken: TCnCppToken read FChildStartToken;
    property ChildCloseToken: TCnCppToken read FChildCloseToken;
    {* 当前层次为 2 的大括号，注意虽然一般是函数，
     但当有多个 namespace 嵌套时也可能是 namespace，因而不太可靠
     得用 NonNamespaceStartToken 和 NonNamespaceCloseToken 代替}

    property BlockStartToken: TCnCppToken read FBlockStartToken;
    property BlockCloseToken: TCnCppToken read FBlockCloseToken;
    {* 当前层次为 1 的大括号，注意可能是 namespace 或函数}
    property BlockIsNamespace: Boolean read FBlockIsNamespace;
    {* 当前层次为 1 的大括号是否是 namespace，注意没有其他层次的类似标志}

    property NonNamespaceStartToken: TCnCppToken read FNonNamespaceStartToken;
    property NonNamespaceCloseToken: TCnCppToken read FNonNamespaceCloseToken;
    {* 最外层非 namespace 的大括号}

    property InnerBlockStartToken: TCnCppToken read FInnerBlockStartToken;
    property InnerBlockCloseToken: TCnCppToken read FInnerBlockCloseToken;
    {* 当前最内层次的大括号}

    property CurrentMethod: AnsiString read FCurrentMethod;
    property CurrentClass: AnsiString read FCurrentClass;
    property CurrentChildMethod: AnsiString read FCurrentChildMethod;

    property UseTabKey: Boolean read FUseTabKey write FUseTabKey;
    {* 是否排版处理 Tab 键的宽度，如不处理，则将 Tab 键当作宽为 1 处理。
      注意不能把 IDE 编辑器设置里的 "Use Tab Character" 的值赋值过来。
      IDE 设置只控制代码中是否在按 Tab 时出现 Tab 字符还是用空格补全。}
    property TabWidth: Integer read FTabWidth write FTabWidth;
    {* Tab 键的宽度}

    property Source: AnsiString read FSource;
  end;

procedure ParseCppCodePosInfo(const Source: AnsiString; CurrPos: Integer;
  var PosInfo: TCodePosInfo; FullSource: Boolean = True; SourceIsUtf8: Boolean = False);
{* 分析 C/C++ 代码中当前位置的信息，如果 SourceIsUtf8 为 True，内部会转为 Ansi
  CurrPos 应当是文件的线性位置（Ansi/Utf8/Utf8）
  但如果 Unicode 环境下取到的线性位置当有宽字符时有偏差的话此函数便不适用，
  需要使用 ParseCppCodePosInfoW
  另外注意 D567/BCB56 下 SourceIsUtf8 参数不起作用}

procedure ParseUnitIncludes(const Source: AnsiString; IncludeList: TStrings);
{* 分析源代码中引用的头文件}

implementation

var
  TokenPool: TCnList = nil;

// 用池方式来管理 CppTokens 以提高性能
function CreateCppToken: TCnCppToken;
begin
  if TokenPool.Count > 0 then
  begin
    Result := TCnCppToken(TokenPool.Last);
    TokenPool.Delete(TokenPool.Count - 1);
  end
  else
    Result := TCnCppToken.Create;
end;

procedure FreeCppToken(Token: TCnCppToken);
begin
  if Token <> nil then
  begin
    Token.Clear;
    TokenPool.Add(Token);
  end;
end;

procedure ClearTokenPool;
var
  I: Integer;
begin
  for I := 0 to TokenPool.Count - 1 do
    TObject(TokenPool[I]).Free;
end;

//==============================================================================
// C/C++ 解析器封装类
//==============================================================================

{ TCnCppStructureParser }

constructor TCnCppStructureParser.Create(SupportUnicodeIdent: Boolean);
begin
  FList := TCnList.Create;
  FSupportUnicodeIdent := SupportUnicodeIdent;
end;

destructor TCnCppStructureParser.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TCnCppStructureParser.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FreeCppToken(TCnCppToken(FList[I]));
  FList.Clear;

  FNonNamespaceStartToken := nil;
  FNonNamespaceCloseToken := nil;
  FChildStartToken := nil;
  FChildCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';
end;

function TCnCppStructureParser.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnCppStructureParser.GetToken(Index: Integer): TCnCppToken;
begin
  Result := TCnCppToken(FList[Index]);
end;

function TCnCppStructureParser.NewToken(CParser: TBCBTokenList; Layer: Integer): TCnCppToken;
var
  Len: Integer;
begin
  Result := CreateCppToken;
  Result.FTokenPos := CParser.RunPosition;

  Len := CParser.TokenLength;
  Result.TokenLength := Len;
  if Len > CN_TOKEN_MAX_SIZE then
    Len := CN_TOKEN_MAX_SIZE;

  Move(CParser.TokenAddr^, Result.FToken[0], Len);
  Result.FToken[Len] := #0;

  Result.FLineNumber := CParser.RunLineNumber - 1; // 1 开始变成 0 开始
  Result.FCharIndex := CParser.RunColNumber - 1;   // 暂未做 Ansi 的 Tab 展开功能
  Result.FCppTokenKind := CParser.RunID;
  Result.FItemLayer := Layer;
  Result.FItemIndex := FList.Count;
  Result.Tag := 0;
  FList.Add(Result);
end;

procedure TCnCppStructureParser.ParseSource(ASource: PAnsiChar; Size: Integer;
  CurrLine: Integer; CurCol: Integer; ParseCurrent: Boolean; NeedRoundSquare: Boolean);
const
  IdentToIgnore: array[0..2] of string = ('CATCH', 'CATCH_ALL', 'AND_CATCH_ALL');
var
  CParser: TBCBTokenList;
  Token: TCnCppToken;
  Layer: Integer;
  HasNamespace: Boolean;
  BraceStack: TStack;
  Brace1Stack: TStack; // 用来配对 OuterBlock
  Brace2Stack: TStack; // 用来配对 ChildBlock
  Brace3Stack: TStack; // 用来配对 NonNamespaceBlock
  BraceStartToken: TCnCppToken;
  BeginBracePosition: Integer;
  FunctionName, OwnerClass: string;
  PrevIsOperator, RunReachedZero: Boolean;

  function CompareLineCol(Line1, Line2, Col1, Col2: Integer): Integer;
  begin
    if Line1 < Line2 then
      Result := -1
    else if Line1 = Line2 then
    begin
      if Col1 < Col2 then
        Result := -1
      else if Col1 > Col2 then
        Result := 1
      else
        Result := 0;
    end
    else
      Result := 1;
  end;

  // 碰到()时往回越过
  procedure SkipProcedureParameters;
  var
    RoundCount: Integer;
  begin
    RoundCount := 0;
    repeat
      CParser.Previous;
      case CParser.RunID of
        ctkroundclose: Inc(RoundCount);
        ctkroundopen: Dec(RoundCount);
        ctknull: Exit;
      end;
    until ((RoundCount <= 0) and ((CParser.RunID = ctkroundopen) or
      (CParser.RunID = ctkroundpair)));
    CParser.PreviousNonJunk; // 往回跳过圆括号中的声明
  end;

  function IdentCanbeIgnore(const Name: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := Low(IdentToIgnore) to High(IdentToIgnore) do
    begin
      if Name = IdentToIgnore[I] then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  // 碰到 <> 时往回越过
  procedure SkipTemplateArgs;
  var
    TemplateCount: Integer;
  begin
    if CParser.RunID <> ctkGreater then Exit;
    TemplateCount := 1;
    repeat
      CParser.Previous;
      case CParser.RunID of
        ctkGreater: Inc(TemplateCount);
        ctklower: Dec(TemplateCount);
        ctknull: Exit;
      end;
    until (((TemplateCount = 0) and (CParser.RunID = ctklower)) or
      (CParser.RunIndex = 0));
    CParser.PreviousNonJunk;
  end;

begin
  Clear;
  CParser := nil;
  BraceStack := nil;
  Brace1Stack := nil;
  Brace2Stack := nil;
  Brace3Stack := nil;

  FInnerBlockStartToken := nil;
  FInnerBlockCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FNonNamespaceStartToken := nil;
  FNonNamespaceCloseToken := nil;
  FBlockIsNamespace := False;

  FCurrentClass := '';
  FCurrentMethod := '';

  try
    BraceStack := TStack.Create;
    Brace1Stack := TStack.Create;
    Brace2Stack := TStack.Create;
    Brace3Stack := TStack.Create;
    FSource := ASource;

    CParser := TBCBTokenList.Create(FSupportUnicodeIdent);
    CParser.DirectivesAsComments := False;
    CParser.SetOrigin(ASource, Size);

    Layer := 0; // 初始层次，最外层为 0
    HasNamespace := False;

    while CParser.RunID <> ctknull do
    begin
      case CParser.RunID of
        ctknamespace:
          begin
            HasNamespace := True; // 记录遇到了 namespace
          end;
        ctksemicolon:
          begin
            if HasNamespace then
              HasNamespace := False; // 如果有分号则表示不是 namespace 声明
            if NeedRoundSquare then
              NewToken(CParser, Layer);
          end;
        ctkbraceopen:
          begin
            Inc(Layer);
            Token := NewToken(CParser, Layer);
            if HasNamespace then
            begin
              Token.Tag := CN_CPP_BRACKET_NAMESPACE;
              // 用 Tag 等于 CN_CPP_BRACKET_NAMESPACE 来表示是 namespace 对应的左括号供外界快速判断
              Token.IsNameSpace := True; // 是一 namespace 对应的左括号
              HasNamespace := False;
            end;

            if CompareLineCol(CParser.RunLineNumber, CurrLine,
              CParser.RunColNumber, CurCol) <= 0 then // 在光标前
            begin
              BraceStack.Push(Token);
              if Layer = 1 then // 如果是第一层，又是 OuterBlock 的 Begin
                Brace1Stack.Push(Token)
              else if Layer = 2 then
                Brace2Stack.Push(Token);
              if not Token.IsNameSpace and (Brace3Stack.Count = 0) then // 非 namespace 的第一个左大括号也参与配对
                Brace3Stack.Push(Token);
            end
            else // 一旦在光标后了碰到左括号，说明之前堆积的 Start 可以确定了。但如果没碰到左括号，则在碰到右括号时处理
            begin
              if (FInnerBlockStartToken = nil) and (BraceStack.Count > 0) then
                FInnerBlockStartToken := TCnCppToken(BraceStack.Pop);
              if (FBlockStartToken = nil) and (Brace1Stack.Count > 0) then
                FBlockStartToken := TCnCppToken(Brace1Stack.Pop);
              if (FChildStartToken = nil) and (Brace2Stack.Count > 0) then
                FChildStartToken := TCnCppToken(Brace2Stack.Pop);
              if (FNonNamespaceStartToken = nil) and (Brace3Stack.Count > 0) then
                FNonNamespaceStartToken := TCnCppToken(Brace3Stack.Pop);
            end;
          end;
        ctkbraceclose:
          begin
            Token := NewToken(CParser, Layer);
            if CompareLineCol(CParser.RunLineNumber, CurrLine,
              CParser.RunColNumber, CurCol) >= 0 then // 右括号在光标后了，就可与之前的左括号配对判断
            begin
              if (FInnerBlockStartToken = nil) and (BraceStack.Count > 0) then
                FInnerBlockStartToken := TCnCppToken(BraceStack.Pop);
              if (FBlockStartToken = nil) and (Brace1Stack.Count > 0) then
                FBlockStartToken := TCnCppToken(Brace1Stack.Pop);
              if (FChildStartToken = nil) and (Brace2Stack.Count > 0) then
                FChildStartToken := TCnCppToken(Brace2Stack.Pop);
              if (FNonNamespaceStartToken = nil) and (Brace3Stack.Count > 0) then
                FNonNamespaceStartToken := TCnCppToken(Brace3Stack.Pop);

              if (FInnerBlockCloseToken = nil) and (FInnerBlockStartToken <> nil) then
              begin
                if Layer = FInnerBlockStartToken.ItemLayer then
                  FInnerBlockCloseToken := Token;
              end;

              if (FNonNamespaceCloseToken = nil) and (FNonNamespaceStartToken <> nil) then
              begin
                if Layer = FNonNamespaceStartToken.ItemLayer then // 如果层次等于之前的
                  FNonNamespaceCloseToken := Token;
              end;

              if Layer = 1  then // 第一层，为 OuterBlock 的 End
              begin
                if FBlockCloseToken = nil then
                  FBlockCloseToken := Token;
              end
              else if Layer = 2 then  // 第二层的也记着
              begin
                if FChildCloseToken = nil then
                  FChildCloseToken := Token;
              end;
            end
            else // 在光标前
            begin
              if BraceStack.Count > 0 then
                BraceStack.Pop;
              if (Layer = 1) and (Brace1Stack.Count > 0) then
                Brace1Stack.Pop;
              if (Layer = 2) and (Brace2Stack.Count > 0) then
                Brace2Stack.Pop;

              if Brace3Stack.Count > 0 then
              begin
                if TCnCppToken(Brace3Stack.Peek).ItemLayer = Layer then
                  Brace3Stack.Pop;
              end;
            end;
            Dec(Layer);
          end;
        ctkidentifier,        // Need these for flow control in source highlight
        ctkreturn, ctkgoto, ctkbreak, ctkcontinue:
          begin
            NewToken(CParser, Layer);
          end;
        ctkdirif, ctkdirifdef, // Need these for conditional compile directive
        ctkdirifndef, ctkdirelif, ctkdirelse, ctkdirendif, ctkdirpragma:
          begin
            NewToken(CParser, Layer);
          end;
      else
        // 如果外界需要解析小中括号分号，则判断后加入
        if NeedRoundSquare and (CParser.RunID in [ctkroundopen, ctkroundclose,
          ctkroundpair, ctksquareopen, ctksquareclose]) then
          NewToken(CParser, Layer);
      end;

      CParser.NextNonJunk;
    end;

    if ParseCurrent then
    begin
      // 处理最外层的非 Namespace 的，保留内部第一层或第二层（如果第一层是 namespace 的话）的内容
      if FBlockStartToken <> nil then
      begin
        if FNonNamespaceStartToken <> nil then
          BraceStartToken := FNonNamespaceStartToken
        else // 以下暂时保留以前寻找处理第一层或第二层的代码
        begin
          BraceStartToken := FBlockStartToken;

          // 先到达最外层左大括号处
          if CParser.RunPosition > FBlockStartToken.TokenPos then
          begin
            while CParser.RunPosition > FBlockStartToken.TokenPos do
              CParser.PreviousNonJunk;
          end
          else if CParser.RunPosition < FBlockStartToken.TokenPos then
            while CParser.RunPosition < FBlockStartToken.TokenPos do
              CParser.NextNonJunk;

          // 找非 Namespace 的最外层
          RunReachedZero := False;
          while not (CParser.RunID in [ctkNull, ctkbraceclose, ctksemicolon])
            and (CParser.RunPosition >= 0) do               //  防止 using namespace std; 这种
          begin
            if RunReachedZero and (CParser.RunPosition = 0) then
              Break; // 曾经到 0，现在还是 0，表示出现了死循环
            if CParser.RunPosition = 0 then
              RunReachedZero := True;

            // 如果 namespace 是最开头，则 RunPosition 可以是 0
            if CParser.RunID in [ctknamespace] then
            begin
              // 本层是 namespace，处理第二层去
              BraceStartToken := FChildStartToken;
              FBlockIsNamespace := True;
              Break;
            end;
            CParser.PreviousNonJunk;
          end;
        end;

        // BraceStartToken 是最外层的非 Namespace 的左大括号
        if BraceStartToken = nil then
          Exit;

        // 回到最外层括号处
        if CParser.RunPosition > BraceStartToken.TokenPos then
        begin
          while CParser.RunPosition > BraceStartToken.TokenPos do
            CParser.PreviousNonJunk;
        end
        else if CParser.RunPosition < BraceStartToken.TokenPos then
          while CParser.RunPosition < BraceStartToken.TokenPos do
            CParser.NextNonJunk;

        // 查找这个需要的大括号之前的声明，类或函数等
        BeginBracePosition := CParser.RunPosition;
        // 记录左大括号的位置
        CParser.PreviousNonJunk;
        if CParser.RunID = ctkidentifier then // 如果左大括号前是标识符
        begin
          while not (CParser.RunID in [ctkNull, ctkbraceclose])
            and (CParser.RunPosition > 0) do
          begin
            if CParser.RunID in [ctkclass, ctkstruct] then
            begin
              // 找到个 class 或 struct，那么名称是紧靠 : 或 { 前的东西
              while not (CParser.RunID in [ctkcolon, ctkbraceopen, ctknull]) do
              begin
                FCurrentClass := AnsiString(CParser.RunToken); // 找到类名或者结构名
                CParser.NextNonJunk;
              end;
              if FCurrentClass <> '' then // 找到类名了，不会有其它名称了，退出
                Exit;
            end;
            CParser.PreviousNonJunk;
          end;
        end
        else if CParser.RunID in [ctkroundclose, ctkroundpair, ctkconst,
          ctkvolatile, ctknull] then
        begin
          // 左大括号前不是标识符而是这几个，则可能到达了一个函数体的末尾，大括号开头
          // 往回走，解出函数来
          CParser.Previous;

          // 往回找圆括号等
          while not ((CParser.RunID in [ctkSemiColon, ctkbraceclose,
            ctkbraceopen, ctkbracepair]) or (CParser.RunID in IdentDirect) or
            (CParser.RunIndex = 0)) do
          begin
            CParser.PreviousNonJunk;
            // 同时处理函数中的冒号，如 __fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner)
            if CParser.RunID = ctkcolon then
            begin
              CParser.PreviousNonJunk;
              if CParser.RunID in [ctkroundclose, ctkroundpair] then
                CParser.NextNonJunk
              else
              begin
                CParser.NextNonJunk;
                Break;
              end;
            end;
          end;

          // 这儿应该停在圆括号处
          if CParser.RunID in [ctkcolon, ctkSemiColon, ctkbraceclose,
            ctkbraceopen, ctkbracepair] then
            CParser.NextNonComment
          else if CParser.RunIndex = 0 then
          begin
            if CParser.IsJunk then
              CParser.NextNonJunk;
          end
          else // 越过编译指令
          begin
            while CParser.RunID <> ctkcrlf do
            begin
              if (CParser.RunID = ctknull) then
                Exit;
              CParser.Next;
            end;
            CParser.NextNonJunk;
          end;

          // 到达一个具体的函数开头
          while (CParser.RunPosition < BeginBracePosition) and
            (CParser.RunID <> ctkcolon) do
          begin
            if CParser.RunID = ctknull then
              Exit;
            CParser.NextNonComment;
          end;

          FunctionName := '';
          OwnerClass := '';
          SkipProcedureParameters;

          if CParser.RunID = ctknull then
            Exit
          else if CParser.RunID = ctkthrow then
            SkipProcedureParameters;

          CParser.PreviousNonJunk;
          PrevIsOperator := CParser.RunID = ctkoperator;
          CParser.NextNonJunk;

          if ((CParser.RunID = ctkidentifier) or (PrevIsOperator)) and not
            IdentCanbeIgnore(CParser.RunToken) then
          begin
            if PrevIsOperator then
              FunctionName := 'operator ';
            FunctionName := FunctionName + CParser.RunToken;
            CParser.PreviousNonJunk;

            if CParser.RunID = ctktilde then // 加上析构函数
            begin
              FunctionName := '~' + FunctionName;
              CParser.PreviousNonJunk;
            end;
            if CParser.RunID = ctkcoloncolon then
            begin
              FCurrentClass := '';
              while CParser.RunID = ctkcoloncolon do
              begin
                CParser.PreviousNonJunk; // 类名或类名带尖括号
                if CParser.RunID = ctkGreater then
                  SkipTemplateArgs;

                OwnerClass := CParser.RunToken + OwnerClass;
                CParser.PreviousNonJunk;
                if CParser.RunID = ctkcoloncolon then
                  OwnerClass := CParser.RunToken + OwnerClass;
              end;
              FCurrentClass := AnsiString(OwnerClass);
            end;
            if OwnerClass <> '' then
              FCurrentMethod := AnsiString(OwnerClass + '::' + FunctionName)
            else
              FCurrentMethod := AnsiString(FunctionName);
          end;
        end;
      end;
    end;
  finally
    Brace3Stack.Free;
    Brace2Stack.Free;
    Brace1Stack.Free;
    BraceStack.Free;
    CParser.Free;
  end;
end;

function TCnCppStructureParser.IndexOfToken(Token: TCnCppToken): Integer;
begin
  Result := FList.IndexOf(Token);
end;

procedure TCnCppStructureParser.ParseString(ASource: PAnsiChar; Size: Integer);
var
  TokenList: TBCBTokenList;
begin
  Clear;
  TokenList := nil;

  try
    FSource := ASource;

    TokenList := TBCBTokenList.Create(FSupportUnicodeIdent);
    TokenList.SetOrigin(ASource, Size);

    while TokenList.RunID <> ctknull do
    begin
      if TokenList.RunID in [ctkstring] then
        NewToken(TokenList);
      TokenList.NextNonJunk;
    end;
  finally
    TokenList.Free;
  end;
end;

{ TCnCppToken }

procedure TCnCppToken.Clear;
begin
  inherited;
  FIsNameSpace := False;
end;

constructor TCnCppToken.Create;
begin
  inherited;
  FUseAsC := True;
end;

// 分析 C/C++ 代码中当前位置的信息
procedure ParseCppCodePosInfo(const Source: AnsiString; CurrPos: Integer;
  var PosInfo: TCodePosInfo; FullSource: Boolean; SourceIsUtf8: Boolean);
var
  CanExit: Boolean;
  CParser: TBCBTokenList;
  Text: AnsiString;

  procedure DoNext;
  var
    OldPosition: Integer;
  begin
    PosInfo.LineNumber := CParser.RunLineNumber - 1;
    PosInfo.LinePos := CParser.LineStartOffset;
    PosInfo.TokenPos := CParser.RunPosition;
    PosInfo.Token := AnsiString(CParser.RunToken);
    PosInfo.CTokenID := CParser.RunID;

    OldPosition := CParser.RunPosition;
    CParser.Next;

    CanExit := CParser.RunPosition = OldPosition;
    // 当 Next 再也前进不了的时候，就是该撤了
    // 这样做的原因是，CParser 在结尾时，有时候不会进行到 ctknull，而一直打转
  end;

begin
  if CurrPos <= 0 then
    CurrPos := MaxInt;
  CParser := nil;
  PosInfo.IsPascal := False;

  // BDS 下 CurrPos 与 Text 都必须转成 Ansi 才能比较
  try
    CParser := TBCBTokenList.Create;
    CParser.DirectivesAsComments := False;
{$IFDEF IDE_WIDECONTROL}
    if SourceIsUtf8 then
    begin
      Text := CnUtf8ToAnsi(PAnsiChar(Source));
      CurrPos := Length(CnUtf8ToAnsi(Copy(Source, 1, CurrPos)));
    end
    else
      Text := Source;
{$ELSE}
    Text := Source;
{$ENDIF}
    CParser.SetOrigin(PAnsiChar(Text), Length(Text));

    if FullSource then
    begin
      PosInfo.AreaKind := akHead; // 未使用
      PosInfo.PosKind := pkField; // 常规空白区，以 pkField 为准
    end
    else
    begin

    end;

    while (CParser.RunPosition < CurrPos) and (CParser.RunID <> ctknull) do
    begin
      // 至少要区分出字符（串）、注释、->或.后、标识符、编译指令等
      case CParser.RunID of
        ctkansicomment, ctkslashescomment:
          begin
            PosInfo.PosKind := pkComment;
          end;
        ctkstring:
          begin
            PosInfo.PosKind := pkString;
          end;
        ctkcrlf:
          begin
            // 行注释与#编译指令，以回车结尾
            if (PosInfo.PosKind = pkCompDirect) or (PosInfo.CTokenID = ctkslashescomment) then
              PosInfo.PosKind := pkField;
          end;
//        ctksemicolon, ctkbraceopen, ctkbraceclose, ctkbracepair,
//        ctkint, ctkfloat, ctkdouble, ctkchar,
//        ctkidentifier, ctkcoloncolon,
//        ctkroundopen, ctkroundpair, ctksquareopen, ctksquarepair,
//        ctkcomma, ctkequal, ctknumber:
//          begin
//            Result.PosKind := pkField;
//          end;
        ctkselectelement:
          begin
            PosInfo.PosKind := pkFieldDot; // -> 视作 . 处理
          end;
        ctkpoint:
          begin
            if PosInfo.CTokenID = ctkidentifier then
              PosInfo.PosKind := pkFieldDot; // 上一个标识符后的点才算
          end;
        ctkdirdefine, ctkdirelif, ctkdirelse, ctkdirendif, ctkdirerror, ctkdirif,
        ctkdirifdef, ctkdirifndef, ctkdirinclude, ctkdirline, ctkdirnull,
        ctkdirpragma, ctkdirundef:
          begin
            PosInfo.PosKind := pkCompDirect;
          end;
        ctkUnknown:
          begin
            // # 后的编译指令未完成时
            if (Length(CParser.RunToken) >= 1 ) and (CParser.RunToken[1] = '#') then
            begin
              PosInfo.PosKind := pkCompDirect;
            end
            else
              PosInfo.PosKind := pkField;
          end;
      else
        PosInfo.PosKind := pkField;
      end;

      DoNext;
      if CanExit then
        Break;
    end;
  finally
    CParser.Free;
  end;
end;

// 分析源代码中引用的头文件
procedure ParseUnitIncludes(const Source: AnsiString; IncludeList: TStrings);
var
  S: string;
  CParser: TBCBTokenList;
begin
  IncludeList.Clear;

  CParser := TBCBTokenList.Create;
  CParser.DirectivesAsComments := False;

  try
    CParser.SetOrigin(PAnsiChar(Source), Length(Source));

    while CParser.RunID <> ctknull do
    begin
      if CParser.RunID = ctkdirinclude then
      begin
        CParser.NextNonJunk;
        if CParser.RunID = ctkstring then
        begin
          S := CParser.RunToken;
          if S <> '' then
          begin
            // 去除字符串两端的引号
            if S[1] = '"' then
              Delete(S, 1, 1);
            if (S <> '') and (S[Length(S)] = '"') then
              Delete(S, Length(S), 1);

            IncludeList.Add(S);
          end;
        end
        else if CParser.RunID = ctklower then
        begin
          CParser.NextNonJunk;
          S := '';
          while CParser.RunID in [ctkidentifier, ctkpoint] do
          begin
            S := S + CParser.RunToken;
            CParser.Next;
          end;
          IncludeList.Add(S);
        end;
      end;

      CParser.NextNonJunk;
    end;
  finally
    CParser.Free;
  end;
end;

initialization
  TokenPool := TCnList.Create;

finalization
  ClearTokenPool;
  FreeAndNil(TokenPool);

end.
