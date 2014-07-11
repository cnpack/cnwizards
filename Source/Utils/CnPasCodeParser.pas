{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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

unit CnPasCodeParser;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Pas 源代码分析器
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnPasCodeParser.pas 1385 2013-12-31 15:39:02Z liuxiaoshanzhashu@gmail.com $
* 修改记录：2012.02.07
*               UTF8的位置转换去除后仍有问题，恢复之
*           2011.11.29
*               XE/XE2 的位置解析无需UTF8的位置转换
*           2011.11.03
*               优化对带点的引用单元名的支持
*           2011.05.29
*               修正BDS下对汉字UTF8未处理而导致解析出错的问题
*           2004.11.07
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, mPasLex, mwBCBTokenList,
  Contnrs, CnCommon, CnFastList;

const
  CN_TOKEN_MAX_SIZE = 63;

type
  TCnUseToken = class(TObject)
  private
    FIsImpl: Boolean;
    FTokenPos: Integer;
    FToken: string;
    FTokenID: TTokenKind;
  public
    property Token: string read FToken write FToken;
    property IsImpl: Boolean read FIsImpl write FIsImpl;
    property TokenPos: Integer read FTokenPos write FTokenPos;
    property TokenID: TTokenKind read FTokenID write FTokenID;
  end;

  TCnPasToken = class(TPersistent)
  {* 描述一 Token 的结构高亮信息}
  private
    function GetToken: PAnsiChar;
  
  protected
    FCppTokenKind: TCTokenKind;
    FCharIndex: Integer;
    FEditCol: Integer;
    FEditLine: Integer;
    FItemIndex: Integer;
    FItemLayer: Integer;
    FLineNumber: Integer;
    FMethodLayer: Integer;
    FToken: array[0..CN_TOKEN_MAX_SIZE] of AnsiChar;
    FTokenID: TTokenKind;
    FTokenPos: Integer;
    FIsMethodStart: Boolean;
    FIsMethodClose: Boolean;
    FIsBlockStart: Boolean;
    FIsBlockClose: Boolean;
    FUseAsC: Boolean;
  public
    procedure Clear;

    property UseAsC: Boolean read FUseAsC;
    {* 是否是 C 方式的解析，默认不是}
    property CharIndex: Integer read FCharIndex; // Start 0
    {* 从本行开始数的字符位置，从零开始 }
    property EditCol: Integer read FEditCol write FEditCol;
    {* 所在列，从一开始 }
    property EditLine: Integer read FEditLine write FEditLine;
    {* 所在行，从一开始 }
    property ItemIndex: Integer read FItemIndex;
    {* 在整个 Parser 中的序号 }
    property ItemLayer: Integer read FItemLayer;
    {* 所在高亮的层次 }
    property LineNumber: Integer read FLineNumber; // Start 0
    {* 所在行号，从零开始 }
    property MethodLayer: Integer read FMethodLayer;
    {* 所在函数的嵌套层次，最外层为一 }
    property Token: PAnsiChar read GetToken;
    {* 该 Token 的字符串内容 }
    property TokenID: TTokenKind read FTokenID;
    {* Token 的语法类型 }
    property CppTokenKind: TCTokenKind read FCppTokenKind;
    {* 作为 C 的 Token 使用时的 CToken 类型}
    property TokenPos: Integer read FTokenPos;
    {* Token 在整个文件中的线性位置 }
    property IsBlockStart: Boolean read FIsBlockStart;
    {* 是否是一块可匹配代码区域的开始 }
    property IsBlockClose: Boolean read FIsBlockClose;
    {* 是否是一块可匹配代码区域的结束 }
    property IsMethodStart: Boolean read FIsMethodStart;
    {* 是否是函数过程的开始，包括 function 和 begin/asm 的情况 }
    property IsMethodClose: Boolean read FIsMethodClose;
    {* 是否是函数过程的结束 }
  end;

//==============================================================================
// Pascal 文件结构高亮解析器
//==============================================================================

  { TCnPasStructureParser }

  TCnPasStructureParser = class(TObject)
  {* 利用 Lex 进行语法解析得到各个 Token 和位置信息}
  private
    FBlockCloseToken: TCnPasToken;
    FBlockStartToken: TCnPasToken;
    FChildMethodCloseToken: TCnPasToken;
    FChildMethodStartToken: TCnPasToken;
    FCurrentChildMethod: AnsiString;
    FCurrentMethod: AnsiString;
    FKeyOnly: Boolean;
    FList: TCnList;
    FMethodCloseToken: TCnPasToken;
    FMethodStartToken: TCnPasToken;
    FSource: AnsiString;
    FInnerBlockCloseToken: TCnPasToken;
    FInnerBlockStartToken: TCnPasToken;
    FUseTabKey: Boolean;
    FTabWidth: Integer;
    function GetCount: Integer;
    function GetToken(Index: Integer): TCnPasToken;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ParseSource(ASource: PAnsiChar; AIsDpr, AKeyOnly: Boolean);
    function FindCurrentDeclaration(LineNumber, CharIndex: Integer): AnsiString;
    procedure FindCurrentBlock(LineNumber, CharIndex: Integer);
    function IndexOfToken(Token: TCnPasToken): Integer;
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TCnPasToken read GetToken;
    property MethodStartToken: TCnPasToken read FMethodStartToken;
    {* 当前最外层的过程或函数}
    property MethodCloseToken: TCnPasToken read FMethodCloseToken;
    {* 当前最外层的过程或函数}
    property ChildMethodStartToken: TCnPasToken read FChildMethodStartToken;
    {* 当前最内层的过程或函数，用于有嵌套过程或函数定义的情况}
    property ChildMethodCloseToken: TCnPasToken read FChildMethodCloseToken;
    {* 当前最内层的过程或函数，用于有嵌套过程或函数定义的情况}
    property BlockStartToken: TCnPasToken read FBlockStartToken;
    {* 当前最外层块}
    property BlockCloseToken: TCnPasToken read FBlockCloseToken;
    {* 当前最外层块}
    property InnerBlockStartToken: TCnPasToken read FInnerBlockStartToken;
    {* 当前最内层块}
    property InnerBlockCloseToken: TCnPasToken read FInnerBlockCloseToken;
    {* 当前最内层块}
    property CurrentMethod: AnsiString read FCurrentMethod;
    {* 当前最外层的过程或函数名}
    property CurrentChildMethod: AnsiString read FCurrentChildMethod;
    {* 当前最内层的过程或函数名，用于有嵌套过程或函数定义的情况}
    property Source: AnsiString read FSource;
    property KeyOnly: Boolean read FKeyOnly;
    {* 是否只处理出关键字}

    property UseTabKey: Boolean read FUseTabKey write FUseTabKey;
    {* 是否排版处理 Tab 键的宽度，如不处理，则将 Tab 键当作宽为 1 处理}
    property TabWidth: Integer read FTabWidth write FTabWidth;
    {* Tab 键的宽度}
  end;

//==============================================================================
// 源码位置信息分析
//==============================================================================

  // 源代码区域类型
  TCodeAreaKind = (
    akUnknown,         // 未知无效区
    akHead,            // 单元声明之前
    akUnit,            // 单元声明区
    akProgram,         // 程序或库声明区
    akInterface,       // interface 区
    akIntfUses,        // interface 的 uses 区
    akImplementation,  // implementation 区
    akImplUses,        // implementation 的 uses 区
    akInitialization,  // initialization 区
    akFinalization,    // finalization 区
    akEnd);            // end. 之后的区域

  TCodeAreaKinds = set of TCodeAreaKind;

  // 源代码位置类型，同时支持 Pascal 和 C/C++
  TCodePosKind = (
    pkUnknown,         // 未知无效区，Pascal 和 C/C++ 都有效
    pkFlat,            // 单元空白区
    pkComment,         // 注释块内部，Pascal 和 C/C++ 都有效
    pkIntfUses,        // Pascal interface 的 uses 内部
    pkImplUses,        // Pascal implementation 的 uses 内部
    pkClass,           // Pascal class 声明内部
    pkInterface,       // Pascal interface 声明内部
    pkType,            // Pascal type 定义区
    pkConst,           // Pascal const 定义区
    pkResourceString,  // Pascal resourcestring 定义区
    pkVar,             // Pascal var 定义区
    pkCompDirect,      // 编译指令内部{$...}，C/C++ 则是指 #include 等内部
    pkString,          // 字符串内部，Pascal 和 C/C++ 都有效
    pkField,           // 标识符. 后面的域内部，属性、方法、事件、记录项等，Pascal 和 C/C++ 都有效
    pkProcedure,       // 过程内部
    pkFunction,        // 函数内部
    pkConstructor,     // 构造器内部
    pkDestructor,      // 析构器内部
    pkFieldDot,        // 连接域的点，包括C/C++的->

    pkDeclaration);    // C中的变量声明区，指类型之后的变量名部分，一般无需弹出

  TCodePosKinds = set of TCodePosKind;

  // 当前代码位置信息，同时支持 Pascal 和 C/C++
  PCodePosInfo = ^TCodePosInfo;
  TCodePosInfo = record
    IsPascal: Boolean;         // 是否是 Pascal 文件
    LastIdentPos: Integer;     // 上一处标识符位置
    LastNoSpace: TTokenKind;   // 上一处非空记号类型
    LastNoSpacePos: Integer;   // 上一次非空记号位置
    LineNumber: Integer;       // 行号
    LinePos: Integer;          // 行位置
    TokenPos: Integer;         // 当前记号位置
    Token: AnsiString;         // 当前记号内容
    TokenID: TTokenKind;       // 当前Pascal记号类型
    CTokenID: TCTokenKind;     // 当前C记号类型
    AreaKind: TCodeAreaKind;   // 当前区域类型
    PosKind: TCodePosKind;     // 当前位置类型
  end;

const
  // 所有的位置集合
  csAllPosKinds = [Low(TCodePosKind)..High(TCodePosKind)];
  // 非代码区域位置集合
  csNonCodePosKinds = [pkUnknown, pkComment, pkIntfUses, pkImplUses,
    pkCompDirect, pkString];
  // 对象域位置集合
  csFieldPosKinds = [pkField, pkFieldDot];
  // 常规代码区域
  csNormalPosKinds = csAllPosKinds - csNonCodePosKinds - csFieldPosKinds;

function ParsePasCodePosInfo(const Source: AnsiString; CurrPos: Integer;
  FullSource: Boolean = True; IsUtf8: Boolean = False): TCodePosInfo;
{* 分析源代码中当前位置的信息}

procedure ParseUnitUses(const Source: AnsiString; UsesList: TStrings);
{* 分析源代码中引用的单元}

implementation

var
  TokenPool: TCnList;

// 用池方式来管理 PasTokens 以提高性能
function CreatePasToken: TCnPasToken;
begin
  if TokenPool.Count > 0 then
  begin
    Result := TCnPasToken(TokenPool.Last);
    TokenPool.Delete(TokenPool.Count - 1);
  end
  else
    Result := TCnPasToken.Create;
end;

procedure FreePasToken(Token: TCnPasToken);
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

// NextNoJunk仅仅只跳过注释，而没跳过编译指令的情况。加此函数可过编译指令
procedure LexNextNoJunkWithoutCompDirect(Lex: TmwPasLex);
begin
  repeat
    Lex.Next;
  until not (Lex.TokenID in [tkSlashesComment, tkAnsiComment, tkBorComment, tkCRLF,
    tkCRLFCo, tkSpace, tkCompDirect]);
end;

//==============================================================================
// 结构高亮解析器
//==============================================================================

{ TCnPasStructureParser }

constructor TCnPasStructureParser.Create;
begin
  FList := TCnList.Create;
  FTabWidth := 2;
end;

destructor TCnPasStructureParser.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

procedure TCnPasStructureParser.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FreePasToken(TCnPasToken(FList[I]));
  FList.Clear;

  FMethodStartToken := nil;
  FMethodCloseToken := nil;
  FChildMethodStartToken := nil;
  FChildMethodCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';
  FSource := '';
end;

function TCnPasStructureParser.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnPasStructureParser.GetToken(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FList[Index]);
end;

procedure TCnPasStructureParser.ParseSource(ASource: PAnsiChar; AIsDpr, AKeyOnly:
  Boolean);
var
  Lex: TmwPasLex;
  MethodStack, BlockStack, MidBlockStack: TObjectStack;
  Token, CurrMethod, CurrBlock, CurrMidBlock: TCnPasToken;
  SavePos, SaveLineNumber, SaveLinePos: Integer;
  IsClassOpen, IsClassDef, IsImpl, IsHelper: Boolean;
  IsRecordHelper, IsSealed, IsRecord: Boolean;
  DeclareWithEndLevel: Integer;
  PrevTokenID: TTokenKind;

  function CalcCharIndex(): Integer;
{$IFDEF BDS2009_UP}
  var
    I, Len: Integer;
{$ENDIF}
  begin
{$IFDEF BDS2009_UP}
    if FUseTabKey and (FTabWidth >= 2) then
    begin
      // 遍历当前行内容进行 Tab 键展开
      I := Lex.LinePos;
      Len := 0;
      while ( I < Lex.TokenPos ) do
      begin
        if (ASource[I] = #09) then
          Len := ((Len div FTabWidth) + 1) * FTabWidth
        else
          Inc(Len);
        Inc(I);
      end;
      Result := Len;
    end
    else
{$ENDIF}
      Result := Lex.TokenPos - Lex.LinePos;
  end;

  procedure NewToken;
  var
    Len: Integer;
  begin
    Token := CreatePasToken;
    Token.FTokenPos := Lex.TokenPos;
    
    Len := Lex.TokenLength;
    if Len > CN_TOKEN_MAX_SIZE then
      Len := CN_TOKEN_MAX_SIZE;
    FillChar(Token.FToken[0], SizeOf(Token.FToken), 0);
    CopyMemory(@Token.FToken[0], Lex.TokenAddr, Len);

    // Token.FToken := AnsiString(Lex.Token);
    
    Token.FLineNumber := Lex.LineNumber;
    Token.FCharIndex := CalcCharIndex();
    Token.FTokenID := Lex.TokenID;
    Token.FItemIndex := FList.Count;
    if CurrBlock <> nil then
      Token.FItemLayer := CurrBlock.FItemLayer;
    if CurrMethod <> nil then
      Token.FMethodLayer := CurrMethod.FMethodLayer;
    FList.Add(Token);
  end;

  procedure DiscardToken(Forced: Boolean = False);
  begin
    if AKeyOnly or Forced then
    begin
      FreePasToken(FList[FList.Count - 1]);
      FList.Delete(FList.Count - 1);
    end;
  end;
begin
  Clear;
  Lex := nil;
  MethodStack := nil;
  BlockStack := nil;
  MidBlockStack := nil;
  PrevTokenID := tkProgram;
  
  try
    FSource := ASource;
    FKeyOnly := AKeyOnly;

    MethodStack := TObjectStack.Create;
    BlockStack := TObjectStack.Create;
    MidBlockStack := TObjectStack.Create;

    Lex := TmwPasLex.Create;
    Lex.Origin := PAnsiChar(ASource);

    DeclareWithEndLevel := 0; // 嵌套的需要end的定义层数
    Token := nil;
    CurrMethod := nil;
    CurrBlock := nil;
    CurrMidBlock := nil;
    IsImpl := AIsDpr;
    IsHelper := False;
    IsRecordHelper := False;

    while Lex.TokenID <> tkNull do
    begin
      if {IsImpl and } (Lex.TokenID in
        [tkProcedure, tkFunction, tkConstructor, tkDestructor,
        tkInitialization, tkFinalization,
        tkBegin, tkAsm,
        tkCase, tkTry, tkRepeat, tkIf, tkFor, tkWith, tkOn, tkWhile,
        tkRecord, tkObject, tkOf, tkEqual,
        tkClass, tkInterface, tkDispInterface,
        tkExcept, tkFinally, tkElse,
        tkEnd, tkUntil, tkThen, tkDo]) then
      begin
        NewToken;
        case Lex.TokenID of
          tkProcedure, tkFunction, tkConstructor, tkDestructor:
            begin
              // 不处理 procedure/function 类型定义，前面是 = 号
              // 也不处理 procedure/function 变量声明，前面是 : 号
              // 也不处理匿名方法声明，前面是 to
              // 也不处理匿名方法实现，前面是 := 赋值或 ( , 做参数，但可能不完全
              if IsImpl and ((not (Lex.TokenID in [tkProcedure, tkFunction]))
                or (not (PrevTokenID in [tkEqual, tkColon, tkTo, tkAssign, tkRoundOpen, tkComma])))
                and (DeclareWithEndLevel <= 0) then
              begin
                // DeclareWithEndLevel <= 0 表示只处理 class/record 外的声明，内部不管
                while BlockStack.Count > 0 do
                  BlockStack.Pop;
                CurrBlock := nil;
                Token.FItemLayer := 0;
                Token.FIsMethodStart := True;

                if CurrMethod <> nil then
                begin
                  Token.FMethodLayer := CurrMethod.FMethodLayer + 1;
                  MethodStack.Push(CurrMethod);
                end
                else
                  Token.FMethodLayer := 1;
                CurrMethod := Token;
              end;
            end;
          tkInitialization, tkFinalization:
            begin
              while BlockStack.Count > 0 do
                BlockStack.Pop;
              CurrBlock := nil;
              while MethodStack.Count > 0 do
                MethodStack.Pop;
              CurrMethod := nil;
            end;
          tkBegin, tkAsm:
            begin
              Token.FIsBlockStart := True;
              if (CurrBlock = nil) and (CurrMethod <> nil) then
                Token.FIsMethodStart := True;
              if CurrBlock <> nil then
              begin
                Token.FItemLayer := CurrBlock.FItemLayer + 1;
                BlockStack.Push(CurrBlock);
              end
              else
                Token.FItemLayer := 1;
              CurrBlock := Token;
            end;
          tkCase:
            begin
              if (CurrBlock = nil) or (CurrBlock.TokenID <> tkRecord) then
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  BlockStack.Push(CurrBlock);
                end
                else
                  Token.FItemLayer := 1;
                CurrBlock := Token;
              end
              else
                DiscardToken(True);
            end;
          tkTry, tkRepeat, tkIf, tkFor, tkWith, tkOn, tkWhile,
          tkRecord, tkObject:
            begin
              IsRecord := Lex.TokenID = tkRecord;
              if IsRecord then
              begin
                // 处理 record helper for 的情形，但在implementation部分其end会被
                // record内部的function/procedure给干掉，暂无解决方案。
                IsRecordHelper := False;
                SavePos := Lex.RunPos;
                SaveLineNumber := Lex.LineNumber;
                SaveLinePos := Lex.LinePos;

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID in [tkSymbol, tkIdentifier] then
                begin
                  if LowerCase(Lex.Token) = 'helper' then
                    IsRecordHelper := True;
                end;

                Lex.LineNumber := SaveLineNumber;
                Lex.LinePos := SaveLinePos;
                Lex.RunPos := SavePos;
              end;

              // 不处理 of object 的字样；不处理前面是 @@ 型的label的情形
              // 额外用 IsRecord 变量因为 Lex.RunPos 恢复后，TokenID 可能会变
              if ((Lex.TokenID <> tkObject) or (PrevTokenID <> tkOf))
                and not (PrevTokenID in [tkAt, tkDoubleAddressOp])
                and not ((Lex.TokenID = tkFor) and (IsHelper or IsRecordHelper)) then
                // 不处理 helper 中的 for
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  BlockStack.Push(CurrBlock);
                  if (CurrBlock.TokenID = tkTry) and (Token.TokenID = tkTry)
                    and (CurrMidBlock <> nil) then
                  begin
                    MidBlockStack.Push(CurrMidBlock);
                    CurrMidBlock := nil;
                  end;
                end
                else
                  Token.FItemLayer := 1;
                CurrBlock := Token;

                if IsRecord then
                begin
                  // 独立记录 record，因为 record 可以在函数体的 begin end 之外配 end
                  // IsInDeclareWithEnd := True;
                  Inc(DeclareWithEndLevel);
                end;
              end;
              
              if Lex.TokenID = tkFor then
              begin
                if IsHelper then
                  IsHelper := False;
                if IsRecordHelper then
                  IsRecordHelper := False;
              end;
            end;
          tkClass, tkInterface, tkDispInterface:
            begin
              IsHelper := False;
              IsSealed := False;
              IsClassDef := ((Lex.TokenID = tkClass) and Lex.IsClass)
                or ((Lex.TokenID = tkInterface) and Lex.IsInterface) or
                (Lex.TokenID = tkDispInterface);

              // 处理不是 classdef 但是 class helper for TObject 的情形
              if not IsClassDef and (Lex.TokenID = tkClass) and not Lex.IsClass then
              begin
                SavePos := Lex.RunPos;
                SaveLineNumber := Lex.LineNumber;
                SaveLinePos := Lex.LinePos;

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID in [tkSymbol, tkIdentifier] then
                begin
                  if LowerCase(Lex.Token) = 'helper' then
                  begin
                    IsClassDef := True;
                    IsHelper := True;
                  end
                  else if LowerCase(Lex.Token) = 'sealed' then
                  begin
                    IsClassDef := True;
                    IsSealed := True;
                  end;
                end;
                Lex.LineNumber := SaveLineNumber;
                Lex.LinePos := SaveLinePos;
                Lex.RunPos := SavePos;
              end;

              IsClassOpen := False;
              if IsClassDef then
              begin
                IsClassOpen := True;
                SavePos := Lex.RunPos;
                SaveLineNumber := Lex.LineNumber;
                SaveLinePos := Lex.LinePos;

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID = tkSemiColon then // 是个 class; 不需要 end;
                  IsClassOpen := False
                else if IsHelper or IsSealed then
                  LexNextNoJunkWithoutCompDirect(Lex);

                if Lex.TokenID = tkRoundOpen then // 有括号，看是不是();
                begin
                  while not (Lex.TokenID in [tkNull, tkRoundClose]) do
                    LexNextNoJunkWithoutCompDirect(Lex);
                  if Lex.TokenID = tkRoundClose then
                    LexNextNoJunkWithoutCompDirect(Lex);
                end;

                if Lex.TokenID = tkSemiColon then
                  IsClassOpen := False
                else if Lex.TokenID = tkFor then
                  IsClassOpen := True;

                // RunPos 重新赋值不会导致已经下移的 LineNumber 回归，是个 Bug
                // 如果给 Lex 的 LineNumber 以及 LinePos 直接赋值，又不知道会有啥问题
                Lex.LineNumber := SaveLineNumber;
                Lex.LinePos := SaveLinePos;
                Lex.RunPos := SavePos;
              end;

              if IsClassOpen then // 有后续内容，需要一个 end
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  BlockStack.Push(CurrBlock);
                end
                else
                  Token.FItemLayer := 1;
                CurrBlock := Token;
                // 局部声明，需要 end 来结尾
                // IsInDeclareWithEnd := True;
                Inc(DeclareWithEndLevel);
              end
              else // 硬修补，免得 unit 的 interface 以及 class procedure 等被高亮
                DiscardToken(Token.TokenID in [tkClass, tkInterface]);
            end;
          tkExcept, tkFinally:
            begin
              if (CurrBlock = nil) or (CurrBlock.TokenID <> tkTry) then
                DiscardToken
              else if CurrMidBlock = nil then
              begin
                CurrMidBlock := Token;
              end
              else
                DiscardToken;
            end;
          tkElse:
            begin
              if (CurrBlock = nil) or (PrevTokenID in [tkAt, tkDoubleAddressOp]) then
                DiscardToken
              else if (CurrBlock.TokenID = tkTry) and (CurrMidBlock <> nil) and
                (CurrMidBlock.TokenID = tkExcept) and
                (PrevTokenID in [tkSemiColon, tkExcept]) then
                Token.FItemLayer := CurrBlock.FItemLayer
              else if not ((CurrBlock.TokenID = tkCase)
                and (PrevTokenID = tkSemiColon)) then
                Token.FItemLayer := Token.FItemLayer + 1;
            end;
          tkEnd, tkUntil, tkThen, tkDo:
            begin
              if (CurrBlock <> nil) and not (PrevTokenID in [tkPoint, tkAt, tkDoubleAddressOp]) then
              begin
                if ((Lex.TokenID = tkUntil) and (CurrBlock.TokenID <> tkRepeat))
                  or ((Lex.TokenID = tkThen) and (CurrBlock.TokenID <> tkIf))
                  or ((Lex.TokenID = tkDo) and not (CurrBlock.TokenID in
                  [tkOn, tkWhile, tkWith, tkFor])) then
                begin
                  DiscardToken;
                end
                else
                begin
                  // 避免部分关键字做变量名的情形，但只是一个小 patch，处理并不完善
                  Token.FItemLayer := CurrBlock.FItemLayer;
                  Token.FIsBlockClose := True;
                  if (CurrBlock.TokenID = tkTry) and (CurrMidBlock <> nil) then
                  begin
                    if MidBlockStack.Count > 0 then
                      CurrMidBlock := TCnPasToken(MidBlockStack.Pop)
                    else
                      CurrMidBlock := nil;
                  end;
                  if BlockStack.Count > 0 then
                  begin
                    CurrBlock := TCnPasToken(BlockStack.Pop);
                  end
                  else
                  begin
                    CurrBlock := nil;
                    if (CurrMethod <> nil) and (Lex.TokenID = tkEnd) and (DeclareWithEndLevel <= 0) then
                    begin
                      Token.FIsMethodClose := True;
                      if MethodStack.Count > 0 then
                        CurrMethod := TCnPasToken(MethodStack.Pop)
                      else
                        CurrMethod := nil;
                    end;
                  end;
                end;
              end
              else // 硬修补，免得 unit 的 End 也高亮
                DiscardToken(Token.TokenID = tkEnd);

              if (DeclareWithEndLevel > 0) and (Lex.TokenID = tkEnd) then // 跳出了局部声明
                Dec(DeclareWithEndLevel);
            end;
        end;
      end
      else
      begin
        if not IsImpl and (Lex.TokenID = tkImplementation) then
          IsImpl := True;

        if (CurrMethod <> nil) and // forward, external 无实现部分，前面必须是分号
          (Lex.TokenID in [tkForward, tkExternal]) and (PrevTokenID = tkSemicolon) then
        begin
          CurrMethod.FIsMethodStart := False;
          if AKeyOnly and (CurrMethod.FItemIndex = FList.Count - 1) then
          begin
            FreePasToken(FList[FList.Count - 1]);
            FList.Delete(FList.Count - 1);
          end;
          if MethodStack.Count > 0 then
            CurrMethod := TCnPasToken(MethodStack.Pop)
          else
            CurrMethod := nil;
        end;

        if not AKeyOnly then
          NewToken;
      end;

      PrevTokenID := Lex.TokenID;
      LexNextNoJunkWithoutCompDirect(Lex);
    end;
  finally
    Lex.Free;
    MethodStack.Free;
    BlockStack.Free;
    MidBlockStack.Free;
  end;
end;

procedure TCnPasStructureParser.FindCurrentBlock(LineNumber, CharIndex:
  Integer);
var
  Token: TCnPasToken;
  CurrIndex: Integer;

  procedure _BackwardFindDeclarePos;
  var
    Level: Integer;
    i, NestedProcs: Integer;
    StartInner: Boolean;
  begin
    Level := 0;
    StartInner := True;
    NestedProcs := 1;
    for i := CurrIndex - 1 downto 0 do
    begin
      Token := Tokens[i];
      if Token.IsBlockStart then
      begin
        if StartInner and (Level = 0) then
        begin
          FInnerBlockStartToken := Token;
          StartInner := False;
        end;

        if Level = 0 then
          FBlockStartToken := Token
        else
          Dec(Level);
      end
      else if Token.IsBlockClose then
      begin
        Inc(Level);
      end;

      if Token.IsMethodStart then
      begin
        if Token.TokenID in [tkProcedure, tkFunction, tkConstructor, tkDestructor] then
        begin
          // 由于 procedure 与其对应的 begin 都可能是 MethodStart，因此需要这样处理
          Dec(NestedProcs);
          if (NestedProcs = 0) and (FChildMethodStartToken = nil) then
            FChildMethodStartToken := Token;
          if Token.MethodLayer = 1 then
          begin
            FMethodStartToken := Token;
            Exit;
          end;
        end
        else if Token.TokenID in [tkBegin, tkAsm] then
        begin
          // 在可嵌套声明函数过程的地区，暂时无需其他处理
        end;
      end
      else if Token.IsMethodClose then
        Inc(NestedProcs);

      if Token.TokenID in [tkImplementation] then
      begin
        Exit;
      end;
    end;
  end;

  procedure _ForwardFindDeclarePos;
  var
    Level: Integer;
    i, NestedProcs: Integer;
    EndInner: Boolean;
  begin
    Level := 0;
    EndInner := True;
    NestedProcs := 1;
    for i := CurrIndex to Count - 1 do
    begin
      Token := Tokens[i];
      if Token.IsBlockClose then
      begin
        if EndInner and (Level = 0) then
        begin
          FInnerBlockCloseToken := Token;
          EndInner := False;
        end;

        if Level = 0 then
          FBlockCloseToken := Token
        else
          Dec(Level);
      end
      else if Token.IsBlockStart then
      begin
        Inc(Level);
      end;

      if Token.IsMethodClose then
      begin
        Dec(NestedProcs);
        if Token.MethodLayer = 1 then // 碰到的最近的 Layer 为 1 的，必然是最外层
        begin
          FMethodCloseToken := Token;
          Exit;
        end
        else if (NestedProcs = 0) and (FChildMethodCloseToken = nil) then
          FChildMethodCloseToken := Token;
          // 最近的同层次的，才是 ChildMethodClose  
      end
      else if Token.IsMethodStart and (Token.TokenID in [tkProcedure, tkFunction,
        tkConstructor, tkDestructor]) then
      begin
        Inc(NestedProcs);
      end;

      if Token.TokenID in [tkInitialization, tkFinalization] then
      begin
        Exit;
      end;
    end;
  end;

  procedure _FindInnerBlockPos;
  var
    I, Level: Integer;
  begin
    // 此函数在 _ForwardFindDeclarePos 和 _BackwardFindDeclarePos 后调用
    if (FInnerBlockStartToken <> nil) and (FInnerBlockCloseToken <> nil) then
    begin
      // 层次一样则退出
      if FInnerBlockStartToken.ItemLayer = FInnerBlockCloseToken.ItemLayer then
        Exit;
      // 上下方临近的 Block 可能层次不一样，需要找个一样层次的，以最外层为准

      if FInnerBlockStartToken.ItemLayer > FInnerBlockCloseToken.ItemLayer then
        Level := FInnerBlockCloseToken.ItemLayer
      else
        Level := FInnerBlockStartToken.ItemLayer;

      for I := CurrIndex - 1 downto 0 do
      begin
        Token := Tokens[I];
        if Token.IsBlockStart and (Token.ItemLayer = Level) then
          FInnerBlockStartToken := Token;
      end;
      for i := CurrIndex to Count - 1 do
      begin
        Token := Tokens[i];
        if Token.IsBlockClose and (Token.ItemLayer = Level) then
          FInnerBlockCloseToken := Token;
      end;
    end;
  end;

  function _GetMethodName(StartToken, CloseToken: TCnPasToken): AnsiString;
  var
    i: Integer;
  begin
    Result := '';
    if Assigned(StartToken) and Assigned(CloseToken) then
      for i := StartToken.ItemIndex + 1 to CloseToken.ItemIndex do
      begin
        Token := Tokens[i];
        if (Token.Token = '(') or (Token.Token = ':') or (Token.Token = ';') then
          Break;
        Result := Result + AnsiTrim(Token.Token);
      end;
  end;

begin
  FMethodStartToken := nil;
  FMethodCloseToken := nil;
  FChildMethodStartToken := nil;
  FChildMethodCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FInnerBlockCloseToken := nil;
  FInnerBlockStartToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';
  
  CurrIndex := 0;
  while CurrIndex < Count do
  begin
    // 前者从 0 开始，后者从 1 开始，因此需要减 1
    if (Tokens[CurrIndex].LineNumber > LineNumber - 1) then
      Break;

    // 根据不同的起始 Token，判断条件也有所不同
    if Tokens[CurrIndex].LineNumber = LineNumber - 1 then
    begin
      if (Tokens[CurrIndex].TokenID in [tkBegin, tkAsm, tkTry, tkRepeat, tkIf,
        tkFor, tkWith, tkOn, tkWhile, tkCase, tkRecord, tkObject, tkClass,
        tkInterface, tkDispInterface]) and
        (Tokens[CurrIndex].CharIndex > CharIndex ) then // 起始的这样判断
        Break
      else if (Tokens[CurrIndex].TokenID in [tkEnd, tkUntil, tkThen, tkDo]) and
        (Tokens[CurrIndex].CharIndex + Length(Tokens[CurrIndex].Token) > CharIndex ) then
        Break;  //结束的这样判断
    end;

    Inc(CurrIndex);
  end;

  if (CurrIndex > 0) and (CurrIndex < Count) then
  begin
    _BackwardFindDeclarePos;
    _ForwardFindDeclarePos;

    _FindInnerBlockPos;
    if not FKeyOnly then
    begin
      FCurrentMethod := _GetMethodName(FMethodStartToken, FMethodCloseToken);
      FCurrentChildMethod := _GetMethodName(FChildMethodStartToken, FChildMethodCloseToken);
    end;
  end;
end;

function TCnPasStructureParser.IndexOfToken(Token: TCnPasToken): Integer;
begin
  Result := FList.IndexOf(Token);
end;

function TCnPasStructureParser.FindCurrentDeclaration(LineNumber, CharIndex: Integer): AnsiString;
var
  Idx: Integer;
begin
  Result := '';
  FindCurrentBlock(LineNumber, CharIndex);
  
  if InnerBlockStartToken <> nil then
  begin
    if InnerBlockStartToken.TokenID in [tkClass, tkInterface, tkRecord,
      tkDispInterface] then
    begin
      // 往前找等号以前的标识符
      Idx := IndexOfToken(InnerBlockStartToken);
      if Idx > 3 then
      begin
        if (InnerBlockStartToken.TokenID = tkRecord)
          and (Tokens[Idx - 1].TokenID = tkPacked) then
          Dec(Idx);
        if Tokens[Idx - 1].TokenID = tkEqual then
          Dec(Idx);
        if Tokens[Idx - 1].TokenID = tkIdentifier then
          Result := Tokens[Idx - 1].Token;
      end;
    end;
  end;
end;

//==============================================================================
// Pascal 源码位置信息分析
//==============================================================================

function ParsePasCodePosInfo(const Source: AnsiString; CurrPos: Integer;
  FullSource: Boolean = True; IsUtf8: Boolean = False): TCodePosInfo;
var
  IsProgram: Boolean;
  InClass: Boolean;
  ProcStack: TStack;
  ProcIndent: Integer;
  SavePos: TCodePosKind;
  Lex: TmwPasLex;
  Text: AnsiString;

  procedure DoNext(NoJunk: Boolean = False);
  begin
    Result.LastIdentPos := Lex.LastIdentPos;
    Result.LastNoSpace := Lex.LastNoSpace;
    Result.LastNoSpacePos := Lex.LastNoSpacePos;
    Result.LineNumber := Lex.LineNumber;
    Result.LinePos := Lex.LinePos;
    Result.TokenPos := Lex.TokenPos;
    Result.Token := AnsiString(Lex.Token);
    Result.TokenID := Lex.TokenID;
    if NoJunk then
      Lex.NextNoJunk
    else
      Lex.Next;
  end;
begin
  if CurrPos <= 0 then
    CurrPos := MaxInt;
  Lex := nil;
  ProcStack := nil;
  Result.IsPascal := True;

  try
    Lex := TmwPasLex.Create;
    ProcStack := TStack.Create;
{$IFDEF BDS}
    if IsUtf8 then
    begin
      Text := CnUtf8ToAnsi(PAnsiChar(Source));
//{$IFNDEF BDS2009_UP}
      // XE/XE2 下的CurrPos 已经是 UTF8 的位置，无需再次转换，否则出错。2009 未知。
      CurrPos := Length(CnUtf8ToAnsi(Copy(Source, 1, CurrPos)));
      // 不转换会导致其他问题如字符串里弹出代码助手，还是得转。
//{$ENDIF}
    end
    else
      Text := Source;
{$ELSE}
    Text := Source;
{$ENDIF}
    Lex.Origin := PAnsiChar(Text);

    if FullSource then
    begin
      Result.AreaKind := akHead;
      Result.PosKind := pkUnknown;
    end
    else
    begin
      Result.AreaKind := akImplementation;
      Result.PosKind := pkUnknown;
    end;
    SavePos := pkUnknown;
    IsProgram := False;
    InClass := False;
    ProcIndent := 0;
    while (Lex.TokenPos < CurrPos) and (Lex.TokenID <> tkNull) do
    begin
      // CnDebugger.LogFmt('Token ID %d, Pos %d, %s',[Integer(Lex.TokenID), Lex.TokenPos, Lex.Token]);
      case Lex.TokenID of
        tkUnit:
          begin
            IsProgram := False;
            Result.AreaKind := akUnit;
            Result.PosKind := pkFlat;
          end;
        tkProgram, tkLibrary:
          begin
            IsProgram := True;
            Result.AreaKind := akProgram;
            Result.PosKind := pkFlat;
          end;
        tkInterface:
          begin
            if (Result.AreaKind in [akUnit, akProgram]) and not IsProgram then
            begin
              Result.AreaKind := akInterface;
              Result.PosKind := pkFlat;
            end
            else if Lex.IsInterface then
            begin
              Result.PosKind := pkInterface;
              DoNext(True);
              if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
                Result.PosKind := pkType
              else if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkRoundOpen) then
              begin
                while (Lex.TokenPos < CurrPos) and not (Lex.TokenID in
                  [tkNull, tkRoundClose]) do
                  DoNext;
                if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkRoundClose) then
                begin
                  DoNext(True);
                  if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
                    Result.PosKind := pkType;
                end;
              end;
              if Result.PosKind = pkInterface then
                InClass := True;
            end;
          end;
        tkUses:
          begin
            if Result.AreaKind in [akProgram, akInterface] then
            begin
              Result.AreaKind := akIntfUses;
              Result.PosKind := pkIntfUses;
            end
            else if Result.AreaKind = akImplementation then
            begin
              Result.AreaKind := akImplUses;
              Result.PosKind := pkIntfUses;
            end;
            if Result.AreaKind in [akIntfUses, akImplUses] then
            begin
              while (Lex.TokenPos < CurrPos) and not (Lex.TokenID in [tkNull, tkSemiColon]) do
                DoNext;
              if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
              begin
                if Result.AreaKind = akIntfUses then
                  Result.AreaKind := akInterface
                else
                  Result.AreaKind := akImplementation;
                Result.PosKind := pkFlat;
              end;
            end;
          end;
        tkImplementation:
          if not IsProgram then
          begin
            Result.AreaKind := akImplementation;
            Result.PosKind := pkFlat;
          end;
        tkInitialization:
          begin
            Result.AreaKind := akInitialization;
            Result.PosKind := pkFlat;
          end;
        tkFinalization:
          begin
            Result.AreaKind := akFinalization;
            Result.PosKind := pkFlat;
          end;
        tkSquareClose:
          if (Lex.Token = '.)') and (Lex.LastNoSpace in [tkIdentifier,
            tkPointerSymbol, tkSquareClose, tkRoundClose]) then
          begin
            if not (Result.PosKind in [pkFieldDot, pkField]) then
              SavePos := Result.PosKind;
            Result.PosKind := pkFieldDot;
          end;
        tkPoint:
          if Lex.LastNoSpace = tkEnd then
          begin
            Result.AreaKind := akEnd;
            Result.PosKind := pkUnknown;
          end
          else if Lex.LastNoSpace in [tkIdentifier, tkPointerSymbol, {$IFDEF DelphiXE3_UP} tkString, {$ENDIF} // Delphi XE3 Supports function invoke on string
            tkSquareClose, tkRoundClose] then
          begin
            if not (Result.PosKind in [pkFieldDot, pkField]) then
              SavePos := Result.PosKind;
            Result.PosKind := pkFieldDot;
          end;
        tkAnsiComment, tkBorComment, tkSlashesComment:
          begin
            if Result.PosKind <> pkComment then
            begin
              SavePos := Result.PosKind;
              Result.PosKind := pkComment;
            end;
          end;
        tkClass:
          begin
            if Lex.IsClass then
            begin
              Result.PosKind := pkClass;
              DoNext(True);
              if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
                Result.PosKind := pkType
              else if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkRoundOpen) then
              begin
                while (Lex.TokenPos < CurrPos) and not (Lex.TokenID in
                  [tkNull, tkRoundClose]) do
                  DoNext;
                if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkRoundClose) then
                begin
                  DoNext(True);
                  if (Lex.TokenPos < CurrPos) and (Lex.TokenID = tkSemiColon) then
                    Result.PosKind := pkType
                  else
                  begin
                    InClass := True;
                    Continue;
                  end;
                end;
              end
              else
              begin
                InClass := True;
                Continue;
              end;
            end;
          end;
        tkType:
          Result.PosKind := pkType;
        tkConst:
          if not InClass then
            Result.PosKind := pkConst;
        tkResourceString:
          Result.PosKind := pkResourceString;
        tkVar:
          if not InClass then
            Result.PosKind := pkVar;
        tkCompDirect:
          begin
            if Result.PosKind <> pkCompDirect then
            begin
              SavePos := Result.PosKind;
              Result.PosKind := pkCompDirect;
            end;
          end;
        tkString:
          begin
            if not SameText(string(Lex.Token), 'String') and (Result.PosKind <> pkString) then
            begin
              SavePos := Result.PosKind;
              Result.PosKind := pkString;
            end;
          end;
        tkIdentifier, tkMessage, tkRead, tkWrite, tkDefault, tkIndex:
          if (Lex.LastNoSpace = tkPoint) and (Result.PosKind = pkFieldDot) then
          begin
            Result.PosKind := pkField;
          end;
        tkProcedure, tkFunction, tkConstructor, tkDestructor:
          begin
            if not InClass and (Result.AreaKind in [akProgram, akImplementation]) then
            begin
              ProcIndent := 0;
              if Lex.TokenID = tkProcedure then
                Result.PosKind := pkProcedure
              else if Lex.TokenID = tkFunction then
                Result.PosKind := pkFunction
              else if Lex.TokenID = tkConstructor then
                Result.PosKind := pkConstructor
              else
                Result.PosKind := pkDestructor;
              ProcStack.Push(Pointer(Result.PosKind));
            end;
            // todo: 处理单独声明的函数
          end;
        tkBegin, tkTry, tkCase, tkAsm, tkRecord:
          begin
            if ProcStack.Count > 0 then
            begin
              Inc(ProcIndent);
              Result.PosKind := TCodePosKind(ProcStack.Peek);
            end;
          end;
        tkEnd:
          begin
            if InClass then
            begin
              Result.PosKind := pkType;
              InClass := False;
            end
            else if ProcStack.Count > 0 then
            begin
              Dec(ProcIndent);
              if ProcIndent <= 0 then
              begin
                ProcStack.Pop;
                Result.PosKind := pkFlat;
              end;
            end;
          end;
      else
        if Result.PosKind in [pkCompDirect, pkComment, pkString, pkField,
          pkFieldDot] then
          Result.PosKind := SavePos;
      end;

      DoNext;
    end;
  finally
    if Lex <> nil then
      Lex.Free;
    if ProcStack <> nil then
      ProcStack.Free;
  end;
end;

// 分析源代码中引用的单元
procedure ParseUnitUses(const Source: AnsiString; UsesList: TStrings);
var
  Lex: TmwPasLex;
  Flag: Integer;
  S: string;
begin
  UsesList.Clear;
  Lex := TmwPasLex.Create;

  Flag := 0;
  S := '';
  try
    Lex.Origin := PAnsiChar(Source);
    while Lex.TokenID <> tkNull do
    begin
      if Lex.TokenID = tkUses then
      begin
        while not (Lex.TokenID in [tkNull, tkSemiColon]) do
        begin
          Lex.Next;
          if Lex.TokenID = tkIdentifier then
          begin
            S := S + string(Lex.Token);
          end
          else if Lex.TokenID = tkPoint then
          begin
            S := S + '.';
          end
          else if Trim(S) <> '' then
          begin
            UsesList.AddObject(S, TObject(Flag));
            S := '';
          end;
        end;
      end
      else if Lex.TokenID = tkImplementation then
      begin
        Flag := 1;
        // 用 Flag 来表示 interface 还是 implementation
      end;
      Lex.Next;
    end;
  finally
    Lex.Free;
  end;
end;

{ TCnPasToken }

procedure TCnPasToken.Clear;
begin
  FCppTokenKind := TCTokenKind(0);
  FCharIndex := 0;
  FEditCol := 0;
  FEditLine := 0;
  FItemIndex := 0;
  FItemLayer := 0;
  FLineNumber := 0;
  FMethodLayer := 0;
  FillChar(FToken[0], SizeOf(FToken), 0);
  FTokenID := TTokenKind(0);
  FTokenPos := 0;
  FIsMethodStart := False;
  FIsMethodClose := False;
  FIsBlockStart := False;
  FIsBlockClose := False;
end;

function TCnPasToken.GetToken: PAnsiChar;
begin
  Result := @FToken[0];
end;

initialization
  TokenPool := TCnList.Create;

finalization
  ClearTokenPool;
  FreeAndNil(TokenPool);

end.
