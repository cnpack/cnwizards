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

unit CnWideCppParser;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：C/C++ 源代码分析器
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：CnCppCodeParser 的 Unicode/WideString 版本
* 开发平台：PWin2000Pro + Delphi 2009
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2015.04.25 V1.1
*               增加 WideString 实现
*           2015.04.11
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Contnrs, CnPasCodeParser, CnWidePasParser,
  CnCppCodeParser, mwBCBTokenList, CnBCBWideTokenList, CnCommon, CnFastList;
  
type
//==============================================================================
// C/C++ 解析器封装类，目前只实现解析大括号层次与普通标识符位置的功能
//==============================================================================

{ TCnWideCppStructParser }

  TCnWideCppToken = class(TCnWidePasToken)
  {* 描述一 Token 的结构高亮信息}
  private
    FIsNameSpace: Boolean;
  public
    constructor Create;
    procedure Clear; override;
  published
    // 注意父类 WidePas 解析出来的 LineNumber 与 CharIndex 都是 0 开始的
    // WideCpp 解析器解析出来的 LineNumber 与 CharIndex 也是 0 开始的

    property IsNameSpace: Boolean read FIsNameSpace write FIsNameSpace;
    {* 是否是 namespace 的对应大括号}
  end;

  TCnWideCppStructParser = class(TObject)
  {* 利用 CParser 进行语法解析得到各个 Token 和位置信息}
  private
    FSupportUnicodeIdent: Boolean;
    FBlockCloseToken: TCnWideCppToken;
    FBlockStartToken: TCnWideCppToken;
    FChildCloseToken: TCnWideCppToken;
    FChildStartToken: TCnWideCppToken;
    FCurrentChildMethod: CnWideString;
    FCurrentMethod: CnWideString;
    FList: TCnList;
    FNonNamespaceCloseToken: TCnWideCppToken;
    FNonNamespaceStartToken: TCnWideCppToken;
    FInnerBlockCloseToken: TCnWideCppToken;
    FInnerBlockStartToken: TCnWideCppToken;
    FCurrentClass: CnWideString;
    FSource: CnWideString;
    FBlockIsNamespace: Boolean;
    FUseTabKey: Boolean;
    FTabWidth: Integer;
    function GetCount: Integer;
    function GetToken(Index: Integer): TCnWideCppToken;
  protected
    procedure CalcCharIndexes(out ACharIndex: Integer; out AnAnsiIndex: Integer;
      CParser: TCnBCBWideTokenList; ASource: PWideChar);
    function NewToken(CParser: TCnBCBWideTokenList; Source: PWideChar; Layer: Integer = 0): TCnWideCppToken;
  public
    constructor Create(SupportUnicodeIdent: Boolean = True);
    destructor Destroy; override;
    procedure Clear;
    procedure ParseSource(ASource: PWideChar; Size: Integer; CurrLine: Integer = 0;
      CurCol: Integer = 0; ParseCurrent: Boolean = False; NeedRoundSquare: Boolean = False);
    {* 解析代码结构，行列均以 1 开始。ParseCurrent 指是否解析当前函数等内容，
      NeedRoundSquare 表示需要解析小括号和中括号以及分号}

    procedure ParseString(ASource: PWideChar; Size: Integer);
    {* 对代码进行针对字符串的解析，只生成字符串内容}

    function IndexOfToken(Token: TCnWideCppToken): Integer;
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TCnWideCppToken read GetToken;

    property ChildStartToken: TCnWideCppToken read FChildStartToken;
    property ChildCloseToken: TCnWideCppToken read FChildCloseToken;
    {* 当前层次为 2 的大括号，注意虽然一般是函数，
     但当有多个 namespace 嵌套时也可能是 namespace，因而不太可靠
     得用 NonNamespaceStartToken 和 NonNamespaceCloseToken 代替}

    property BlockStartToken: TCnWideCppToken read FBlockStartToken;
    property BlockCloseToken: TCnWideCppToken read FBlockCloseToken;
    {* 当前层次为 1 的大括号，注意可能是 namespace 或函数}
    property BlockIsNamespace: Boolean read FBlockIsNamespace;
    {* 当前层次为 1 的大括号是否是 namespace，注意没有其他层次的类似标志}

    property NonNamespaceStartToken: TCnWideCppToken read FNonNamespaceStartToken;
    property NonNamespaceCloseToken: TCnWideCppToken read FNonNamespaceCloseToken;
    {* 最外层非 namespace 的大括号}

    property InnerBlockStartToken: TCnWideCppToken read FInnerBlockStartToken;
    property InnerBlockCloseToken: TCnWideCppToken read FInnerBlockCloseToken;
    {* 当前最内层次的大括号}

    property CurrentMethod: CnWideString read FCurrentMethod;
    property CurrentClass: CnWideString read FCurrentClass;
    property CurrentChildMethod: CnWideString read FCurrentChildMethod;

    property UseTabKey: Boolean read FUseTabKey write FUseTabKey;
    {* 是否排版处理 Tab 键的宽度，如不处理，则将 Tab 键当作宽为 1 处理。
      注意不能把 IDE 编辑器设置里的 "Use Tab Character" 的值赋值过来。
      IDE 设置只控制代码中是否在按 Tab 时出现 Tab 字符还是用空格补全。}
    property TabWidth: Integer read FTabWidth write FTabWidth;
    {* Tab 键的宽度}

    property Source: CnWideString read FSource;
  end;

procedure ParseCppCodePosInfoW(const Source: CnWideString; Line, Col: Integer;
  var PosInfo: TCodePosInfo; TabWidth: Integer = 2; FullSource: Boolean = True);
{* UNICODE 环境下的解析光标所在代码的位置，只用于 D2009 或以上
  非 Unicode 编译器下貌似也行，Line/Col 对应 View 的 CursorPos，均为 1 开始}

implementation

uses
  CnIDEStrings;

var
  TokenPool: TCnList = nil;

// 用池方式来管理 CppTokens 以提高性能
function CreateCppToken: TCnWideCppToken;
begin
  if TokenPool.Count > 0 then
  begin
    Result := TCnWideCppToken(TokenPool.Last);
    TokenPool.Delete(TokenPool.Count - 1);
  end
  else
    Result := TCnWideCppToken.Create;
end;

procedure FreeCppToken(Token: TCnWideCppToken);
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

{ TCnWideCppStructParser }

constructor TCnWideCppStructParser.Create(SupportUnicodeIdent: Boolean);
begin
  inherited Create;
  FList := TCnList.Create;
  FSupportUnicodeIdent := SupportUnicodeIdent;
end;

destructor TCnWideCppStructParser.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TCnWideCppStructParser.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FreeCppToken(TCnWideCppToken(FList[I]));
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

function TCnWideCppStructParser.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnWideCppStructParser.GetToken(Index: Integer): TCnWideCppToken;
begin
  Result := TCnWideCppToken(FList[Index]);
end;

procedure TCnWideCppStructParser.CalcCharIndexes(out ACharIndex: Integer;
  out AnAnsiIndex: Integer; CParser: TCnBCBWideTokenList; ASource: PWideChar);
var
  I, AnsiLen, WideLen: Integer;
begin
  if FUseTabKey and (FTabWidth >= 2) then
  begin
    // 遍历当前行内容进行 Tab 键展开
    I := CParser.LineStartOffset;
    AnsiLen := 0;
    WideLen := 0;
    while (I < CParser.RunPosition) do
    begin
      if (ASource[I] = #09) then
      begin
        AnsiLen := ((AnsiLen div FTabWidth) + 1) * FTabWidth;
        WideLen := ((WideLen div FTabWidth) + 1) * FTabWidth;
        // TODO: Wide 字符串的 Tab 展开规则是否是这样？
      end
      else
      begin
        Inc(WideLen);
        if IDEWideCharIsWideLength(Source[I]) then
          Inc(AnsiLen, SizeOf(WideChar))
        else
          Inc(AnsiLen, SizeOf(AnsiChar));
      end;
      Inc(I);
    end;
    ACharIndex := WideLen;
    AnAnsiIndex := AnsiLen;
  end
  else
  begin
    ACharIndex := CParser.RawColNumber - 1;
    AnAnsiIndex := CParser.ColumnNumber - 1;
  end;
end;

function TCnWideCppStructParser.NewToken(CParser: TCnBCBWideTokenList;
  Source: PWideChar; Layer: Integer): TCnWideCppToken;
var
  Len: Integer;
begin
  Result := CreateCppToken;
  Result.FTokenPos := CParser.RunPosition;

  Len := CParser.TokenLength;
  Result.TokenLength := Len;
  if Len > CN_TOKEN_MAX_SIZE then
    Len := CN_TOKEN_MAX_SIZE;

  Move(CParser.TokenAddr^, Result.FToken[0], Len * SizeOf(WideChar));
  Result.FToken[Len] := #0;

  Result.FLineNumber := CParser.LineNumber - 1;    // 1 开始变成 0 开始
  Result.Tag := 0;
  CalcCharIndexes(Result.FCharIndex, Result.FAnsiIndex, CParser, Source);
  Result.FCppTokenKind := CParser.RunID;
  Result.FItemLayer := Layer;
  Result.FItemIndex := FList.Count;
  FList.Add(Result);
end;

procedure TCnWideCppStructParser.ParseSource(ASource: PWideChar; Size: Integer;
  CurrLine: Integer; CurCol: Integer; ParseCurrent: Boolean; NeedRoundSquare: Boolean);
const
  IdentToIgnore: array[0..2] of string = ('CATCH', 'CATCH_ALL', 'AND_CATCH_ALL');
var
  CParser: TCnBCBWideTokenList;
  Token: TCnWideCppToken;
  Layer: Integer;
  HasNamespace: Boolean;
  BraceStack: TStack;
  Brace1Stack: TStack;  // 用来配对 OuterBlock
  Brace2Stack: TStack;  // 用来配对 ChildBlock
  Brace3Stack: TStack;  // 用来配对 NonNamespaceBlock
  BraceStartToken: TCnWideCppToken;
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

  // 碰到 () 时往回越过
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

  // 碰到<>时往回越过
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

    CParser := TCnBCBWideTokenList.Create(FSupportUnicodeIdent);
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
              NewToken(CParser, ASource, Layer);
          end;
        ctkbraceopen:
          begin
            Inc(Layer);
            Token := NewToken(CParser, ASource, Layer);
            if HasNamespace then
            begin
              Token.Tag := CN_CPP_BRACKET_NAMESPACE;
              // 用 Tag 等于 CN_CPP_BRACKET_NAMESPACE 来表示是 namespace 对应的左括号供外界快速判断
              Token.IsNameSpace := True; // 是一 namespace 对应的左括号
              HasNamespace := False;
            end;

            if CompareLineCol(CParser.LineNumber, CurrLine,
              CParser.ColumnNumber, CurCol) <= 0 then // 在光标前
            begin
              BraceStack.Push(Token);
              if Layer = 1 then // 如果是第一层，又是 OuterBlock 的 Begin
                Brace1Stack.Push(Token)
              else if Layer = 2 then
                Brace2Stack.Push(Token);
              if not Token.IsNameSpace  and (Brace3Stack.Count = 0) then // 非 namespace 的第一个左大括号也参与配对
                Brace3Stack.Push(Token);
            end
            else // // 一旦在光标后了碰到左括号，说明之前堆积的 Start 可以确定了。但如果没碰到左括号，则在碰到右括号时处理
            begin
              if (FInnerBlockStartToken = nil) and (BraceStack.Count > 0) then
                FInnerBlockStartToken := TCnWideCppToken(BraceStack.Pop);
              if (FBlockStartToken = nil) and (Brace1Stack.Count > 0) then
                FBlockStartToken := TCnWideCppToken(Brace1Stack.Pop);
              if (FChildStartToken = nil) and (Brace2Stack.Count > 0) then
                FChildStartToken := TCnWideCppToken(Brace2Stack.Pop);
              if (FNonNamespaceStartToken = nil) and (Brace3Stack.Count > 0) then
                FNonNamespaceStartToken := TCnWideCppToken(Brace3Stack.Pop);
            end;
          end;
        ctkbraceclose:
          begin
            Token := NewToken(CParser, ASource, Layer);
            if CompareLineCol(CParser.LineNumber, CurrLine,
              CParser.ColumnNumber, CurCol) >= 0 then // 一旦在光标后了就可判断
            begin
              if (FInnerBlockStartToken = nil) and (BraceStack.Count > 0) then
                FInnerBlockStartToken := TCnWideCppToken(BraceStack.Pop);
              if (FBlockStartToken = nil) and (Brace1Stack.Count > 0) then
                FBlockStartToken := TCnWideCppToken(Brace1Stack.Pop);
              if (FChildStartToken = nil) and (Brace2Stack.Count > 0) then
                FChildStartToken := TCnWideCppToken(Brace2Stack.Pop);
              if (FNonNamespaceStartToken = nil) and (Brace3Stack.Count > 0) then
                FNonNamespaceStartToken := TCnWideCppToken(Brace3Stack.Pop);

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
                if TCnWideCppToken(Brace3Stack.Peek).ItemLayer = Layer then
                  Brace3Stack.Pop;
              end;
            end;
            Dec(Layer);
          end;
        ctkidentifier,        // Need these for flow control in source highlight
        ctkreturn, ctkgoto, ctkbreak, ctkcontinue:
          begin
            NewToken(CParser, ASource, Layer);
          end;
        ctkdirif, ctkdirifdef, // Need these for conditional compile directive
        ctkdirifndef, ctkdirelif, ctkdirelse, ctkdirendif, ctkdirpragma:
          begin
            NewToken(CParser, ASource, Layer);
          end;
      else
        // 如果外界需要解析小中括号，则判断后加入
        if NeedRoundSquare and (CParser.RunID in [ctkroundopen, ctkroundclose,
          ctkroundpair, ctksquareopen, ctksquareclose]) then
          NewToken(CParser, ASource, Layer);
      end;

      CParser.NextNonJunk;
    end;

    if ParseCurrent then
    begin
      // 处理第一层或第二层（如果第一层是 namespace 的话）的内容
      if FBlockStartToken <> nil then
      begin
        if FNonNamespaceStartToken <> nil then
          BraceStartToken := FNonNamespaceStartToken
        else // 以下暂时保留以前寻找处理第一层或第二层的代码
        begin
          BraceStartToken := FBlockStartToken;

          // 先到达最外层括号处
          if CParser.RunPosition > FBlockStartToken.TokenPos then
          begin
            while CParser.RunPosition > FBlockStartToken.TokenPos do
              CParser.PreviousNonJunk;
          end
          else if CParser.RunPosition < FBlockStartToken.TokenPos then
            while CParser.RunPosition < FBlockStartToken.TokenPos do
              CParser.NextNonJunk;

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
                FCurrentClass := string(CParser.RunToken); // 找到类名或者结构名
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
              FCurrentClass := string(OwnerClass);
            end;
            if OwnerClass <> '' then
              FCurrentMethod := string(OwnerClass + '::' + FunctionName)
            else
              FCurrentMethod := string(FunctionName);
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

function TCnWideCppStructParser.IndexOfToken(Token: TCnWideCppToken): Integer;
begin
  Result := FList.IndexOf(Token);
end;

procedure TCnWideCppStructParser.ParseString(ASource: PWideChar;
  Size: Integer);
var
  TokenList: TCnBCBWideTokenList;
begin
  Clear;
  TokenList := nil;

  try
    FSource := ASource;

    TokenList := TCnBCBWideTokenList.Create(FSupportUnicodeIdent);
    TokenList.SetOrigin(ASource, Size);

    while TokenList.RunID <> ctknull do
    begin
      if TokenList.RunID in [ctkstring] then
        NewToken(TokenList, ASource);
      TokenList.NextNonJunk;
    end;
  finally
    TokenList.Free;
  end;
end;

procedure ParseCppCodePosInfoW(const Source: CnWideString; Line, Col: Integer;
  var PosInfo: TCodePosInfo; TabWidth: Integer; FullSource: Boolean);
var
  CanExit: Boolean;
  CParser: TCnBCBWideTokenList;
  ExpandCol: Integer;

  function CParserStillBeforeCursor: Boolean;
  begin
    if CParser.LineNumber < Line then
      Result := True
    else if CParser.LineNumber > Line then
      Result := False
    else if CParser.LineNumber = Line then
      Result := ExpandCol < Col
    else
      Result := False;
  end;

  procedure DoNext;
  var
    OldPosition: Integer;
  begin
    PosInfo.LineNumber := CParser.LineNumber - 1; // 从 1 开始变成从 0 开始
    PosInfo.LinePos := CParser.LineStartOffset;
    PosInfo.TokenPos := CParser.RunPosition;
    PosInfo.Token := AnsiString(CParser.RunToken);
    PosInfo.CTokenID := CParser.RunID;

    OldPosition := CParser.RunPosition;
    CParser.Next;

    CanExit := CParser.RunPosition = OldPosition;
    // 当 Next 再也前进不了的时候，就是该撤了
    // 这样做的原因是，CParser 在结尾时，有时候不会进行到ctknull，而一直打转

    if CParser.LineNumber = Line then
    begin
      // TODO: 如果是当前行，则展开 Tab
      // 并把当前 Token 的展开 Col 给 ExpandCol

      ExpandCol := CParser.ColumnNumber;
    end
    else
      ExpandCol := CParser.ColumnNumber;
  end;

begin
  CParser := nil;
  PosInfo.IsPascal := False;

  try
    CParser := TCnBCBWideTokenList.Create;
    CParser.DirectivesAsComments := False;

    CParser.SetOrigin(PWideChar(Source), Length(Source));
    if FullSource then
    begin
      PosInfo.AreaKind := akHead; // 未使用
      PosInfo.PosKind := pkField; // 常规空白区，以pkField
    end
    else
    begin

    end;

    while CParserStillBeforeCursor and (CParser.RunID <> ctknull) do
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
            // #后的编译指令未完成时
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

{ TCnWideCppToken }

procedure TCnWideCppToken.Clear;
begin
  inherited;
  FIsNameSpace := False;
end;

constructor TCnWideCppToken.Create;
begin
  inherited;
  FUseAsC := True;
end;

initialization
  TokenPool := TCnList.Create;

finalization
  ClearTokenPool;
  FreeAndNil(TokenPool);

end.
