{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2016 CnPack 开发组                       }
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

unit CnWidePasParser;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Pas 源代码分析器的 Unicode 版本
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：改写自 CnPasCodeParser，去掉了一个无需改造的函数
* 开发平台：Win7 + Delphi 2009
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnPasCodeParser.pas 1385 2013-12-31 15:39:02Z liuxiaoshanzhashu@gmail.com $
* 修改记录：2015.04.25 V1.1
*               增加 WideString 实现
*           2015.04.10
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, mPasLex, CnPasWideLex, mwBCBTokenList,
  Contnrs, CnCommon, CnFastList, CnPasCodeParser;

type
{$IFDEF UNICODE}
  CnWideString = string;
{$ELSE}
  CnWideString = WideString;
{$ENDIF}

  TCnWidePasToken = class(TPersistent)
  {* 描述一 Token 的结构高亮信息}
  private
    function GetToken: PWideChar;
  protected
    FCppTokenKind: TCTokenKind;
    FCompDirectiveType: TCnCompDirectiveType;
    FCharIndex: Integer;
    FEditCol: Integer;
    FEditLine: Integer;
    FItemIndex: Integer;
    FItemLayer: Integer;
    FLineNumber: Integer;
    FMethodLayer: Integer;
    FToken: array[0..CN_TOKEN_MAX_SIZE] of Char;
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
    property LineNumber: Integer read FLineNumber; // Start 0
    {* 所在行号，从零开始，由 ParseSource 计算而来 }
    property CharIndex: Integer read FCharIndex; // Start 0
    {* 从本行开始数的字符位置，从零开始，由 ParseSource 内据需展开 Tab 计算而来 }

    property EditCol: Integer read FEditCol write FEditCol;
    {* 所在列，从一开始，由外界转换而来 }
    property EditLine: Integer read FEditLine write FEditLine;
    {* 所在行，从一开始，由外界转换而来 }

    property ItemIndex: Integer read FItemIndex;
    {* 在整个 Parser 中的序号 }
    property ItemLayer: Integer read FItemLayer;
    {* 所在高亮的层次 }
    property MethodLayer: Integer read FMethodLayer;
    {* 所在函数的嵌套层次，最外层为一 }
    property Token: PWideChar read GetToken;
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
    property CompDirectivtType: TCnCompDirectiveType read FCompDirectiveType write FCompDirectiveType;
    {* 当其类型是 Pascal 编译指令时，此域代表其详细类型，但不解析，由外部按需解析}
  end;

//==============================================================================
// Pascal Unicode 文件结构高亮解析器
//==============================================================================

  { TCnPasStructureParser }

  TCnWidePasStructParser = class(TObject)
  {* 利用 TCnPasWideLex 进行语法解析得到各个 Token 和位置信息}
  private
    FSupportUnicodeIdent: Boolean;
    FBlockCloseToken: TCnWidePasToken;
    FBlockStartToken: TCnWidePasToken;
    FChildMethodCloseToken: TCnWidePasToken;
    FChildMethodStartToken: TCnWidePasToken;
    FCurrentChildMethod: CnWideString;
    FCurrentMethod: CnWideString;
    FKeyOnly: Boolean;
    FList: TCnList;
    FMethodCloseToken: TCnWidePasToken;
    FMethodStartToken: TCnWidePasToken;
    FSource: CnWideString;
    FInnerBlockCloseToken: TCnWidePasToken;
    FInnerBlockStartToken: TCnWidePasToken;
    FUseTabKey: Boolean;
    FTabWidth: Integer;
    function GetCount: Integer;
    function GetToken(Index: Integer): TCnWidePasToken;
  public
    constructor Create(SupportUnicodeIdent: Boolean = False);
    destructor Destroy; override;
    procedure Clear;
    procedure ParseSource(ASource: PWideChar; AIsDpr, AKeyOnly: Boolean);
    function FindCurrentDeclaration(LineNumber, CharIndex: Integer): CnWideString;
    procedure FindCurrentBlock(LineNumber, CharIndex: Integer);
    function IndexOfToken(Token: TCnWidePasToken): Integer;
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TCnWidePasToken read GetToken;
    property MethodStartToken: TCnWidePasToken read FMethodStartToken;
    {* 当前最外层的过程或函数}
    property MethodCloseToken: TCnWidePasToken read FMethodCloseToken;
    {* 当前最外层的过程或函数}
    property ChildMethodStartToken: TCnWidePasToken read FChildMethodStartToken;
    {* 当前最内层的过程或函数，用于有嵌套过程或函数定义的情况}
    property ChildMethodCloseToken: TCnWidePasToken read FChildMethodCloseToken;
    {* 当前最内层的过程或函数，用于有嵌套过程或函数定义的情况}
    property BlockStartToken: TCnWidePasToken read FBlockStartToken;
    {* 当前最外层块}
    property BlockCloseToken: TCnWidePasToken read FBlockCloseToken;
    {* 当前最外层块}
    property InnerBlockStartToken: TCnWidePasToken read FInnerBlockStartToken;
    {* 当前最内层块}
    property InnerBlockCloseToken: TCnWidePasToken read FInnerBlockCloseToken;
    {* 当前最内层块}
    property CurrentMethod: CnWideString read FCurrentMethod;
    {* 当前最外层的过程或函数名}
    property CurrentChildMethod: CnWideString read FCurrentChildMethod;
    {* 当前最内层的过程或函数名，用于有嵌套过程或函数定义的情况}
    property Source: CnWideString read FSource;
    property KeyOnly: Boolean read FKeyOnly;
    {* 是否只处理出关键字}

    property UseTabKey: Boolean read FUseTabKey write FUseTabKey;
    {* 是否排版处理 Tab 键的宽度，如不处理，则将 Tab 键当作宽为 1 处理}
    property TabWidth: Integer read FTabWidth write FTabWidth;
    {* Tab 键的宽度}
  end;

procedure ParseUnitUsesW(const Source: CnWideString; UsesList: TStrings;
  SupportUnicodeIdent: Boolean = False);
{* 分析源代码中引用的单元}

implementation

var
  TokenPool: TCnList;

// 用池方式来管理 PasTokens 以提高性能
function CreatePasToken: TCnWidePasToken;
begin
  if TokenPool.Count > 0 then
  begin
    Result := TCnWidePasToken(TokenPool.Last);
    TokenPool.Delete(TokenPool.Count - 1);
  end
  else
    Result := TCnWidePasToken.Create;
end;

procedure FreePasToken(Token: TCnWidePasToken);
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
procedure LexNextNoJunkWithoutCompDirect(Lex: TCnPasWideLex);
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

constructor TCnWidePasStructParser.Create(SupportUnicodeIdent: Boolean);
begin
  inherited Create;
  FList := TCnList.Create;
  FTabWidth := 2;
  FSupportUnicodeIdent := SupportUnicodeIdent;
end;

destructor TCnWidePasStructParser.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

procedure TCnWidePasStructParser.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FreePasToken(TCnWidePasToken(FList[I]));
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

function TCnWidePasStructParser.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnWidePasStructParser.GetToken(Index: Integer): TCnWidePasToken;
begin
  Result := TCnWidePasToken(FList[Index]);
end;

procedure TCnWidePasStructParser.ParseSource(ASource: PWideChar; AIsDpr, AKeyOnly:
  Boolean);
var
  Lex: TCnPasWideLex;
  MethodStack, BlockStack, MidBlockStack: TObjectStack;
  Token, CurrMethod, CurrBlock, CurrMidBlock: TCnWidePasToken;
  SavePos, SaveLineNumber, SaveLinePos: Integer;
  IsClassOpen, IsClassDef, IsImpl, IsHelper: Boolean;
  IsRecordHelper, IsSealed, IsAbstract, IsRecord, IsForFunc: Boolean;
  DeclareWithEndLevel: Integer;
  PrevTokenID: TTokenKind;
  PrevTokenStr: CnWideString;

  function CalcCharIndex(): Integer;
  var
    I, Len: Integer;
  begin
    if FUseTabKey and (FTabWidth >= 2) then
    begin
      // 遍历当前行内容进行 Tab 键展开
      I := Lex.LineStartOffset;
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
      Result := Lex.TokenPos - Lex.LineStartOffset;
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
    CopyMemory(@Token.FToken[0], Lex.TokenAddr, Len * SizeOf(WideChar));

    Token.FLineNumber := Lex.LineNumber - 1; // 1 开始变成 0 开始
    Token.FCharIndex := CalcCharIndex();     // 不使用 Col 属性，而是据需 Tab 展开，也会由 1 开始变成 0 开始
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

    Lex := TCnPasWideLex.Create(FSupportUnicodeIdent);
    Lex.Origin := PWideChar(ASource);

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
      if {IsImpl and } (Lex.TokenID in [tkCompDirect, // Allow CompDirect
        tkProcedure, tkFunction, tkConstructor, tkDestructor,
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
              IsForFunc := (PrevTokenID in [tkPoint]) or
                ((PrevTokenID = tkSymbol) and (PrevTokenStr = '&'));
              if IsRecord then
              begin
                // 处理 record helper for 的情形，但在implementation部分其end会被
                // record内部的function/procedure给干掉，暂无解决方案。
                IsRecordHelper := False;
                SavePos := Lex.RunPos;
                SaveLineNumber := Lex.LineNumber;
                SaveLinePos := Lex.LineStartOffset;

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID in [tkSymbol, tkIdentifier] then
                begin
                  if LowerCase(Lex.Token) = 'helper' then
                    IsRecordHelper := True;
                end;

                Lex.LineNumber := SaveLineNumber;
                Lex.LineStartOffset := SaveLinePos;
                Lex.RunPos := SavePos;
              end;

              // 不处理 of object 的字样；不处理前面是 @@ 型的label的情形
              // 额外用 IsRecord 变量因为 Lex.RunPos 恢复后，TokenID 可能会变
              if ((Lex.TokenID <> tkObject) or (PrevTokenID <> tkOf))
                and not (PrevTokenID in [tkAt, tkDoubleAddressOp])
                and not IsForFunc        // 不处理 TParalle.For 以及 .&For 这种函数
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
              IsAbstract := False;
              IsClassDef := ((Lex.TokenID = tkClass) and Lex.IsClass)
                or ((Lex.TokenID = tkInterface) and Lex.IsInterface) or
                (Lex.TokenID = tkDispInterface);

              // 处理不是 classdef 但是 class helper for TObject 的情形
              if not IsClassDef and (Lex.TokenID = tkClass) and not Lex.IsClass then
              begin
                SavePos := Lex.RunPos;
                SaveLineNumber := Lex.LineNumber;
                SaveLinePos := Lex.LineStartOffset;

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID in [tkSymbol, tkIdentifier, tkSealed, tkAbstract] then
                begin
                  if LowerCase(Lex.Token) = 'helper' then
                  begin
                    IsClassDef := True;
                    IsHelper := True;
                  end
                  else if Lex.TokenID = tkSealed then
                  begin
                    IsClassDef := True;
                    IsSealed := True;
                  end
                  else if Lex.TokenID = tkAbstract then
                  begin
                    IsClassDef := True;
                    IsAbstract := True;
                  end;
                end;
                Lex.LineNumber := SaveLineNumber;
                Lex.LineStartOffset := SaveLinePos;
                Lex.RunPos := SavePos;
              end;

              IsClassOpen := False;
              if IsClassDef then
              begin
                IsClassOpen := True;
                SavePos := Lex.RunPos;
                SaveLineNumber := Lex.LineNumber;
                SaveLinePos := Lex.LineStartOffset;

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID = tkSemiColon then // 是个 class; 不需要 end;
                  IsClassOpen := False
                else if IsHelper or IsSealed or IsAbstract then
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
                Lex.LineStartOffset := SaveLinePos;
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
                      CurrMidBlock := TCnWidePasToken(MidBlockStack.Pop)
                    else
                      CurrMidBlock := nil;
                  end;
                  if BlockStack.Count > 0 then
                  begin
                    CurrBlock := TCnWidePasToken(BlockStack.Pop);
                  end
                  else
                  begin
                    CurrBlock := nil;
                    if (CurrMethod <> nil) and (Lex.TokenID = tkEnd) and (DeclareWithEndLevel <= 0) then
                    begin
                      Token.FIsMethodClose := True;
                      if MethodStack.Count > 0 then
                        CurrMethod := TCnWidePasToken(MethodStack.Pop)
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
            CurrMethod := TCnWidePasToken(MethodStack.Pop)
          else
            CurrMethod := nil;
        end;

        if not AKeyOnly then
          NewToken;
      end;

      PrevTokenID := Lex.TokenID;
      PrevTokenStr := Lex.Token;
      //LexNextNoJunkWithoutCompDirect(Lex);
      Lex.NextNoJunk;
    end;
  finally
    Lex.Free;
    MethodStack.Free;
    BlockStack.Free;
    MidBlockStack.Free;
  end;
end;

procedure TCnWidePasStructParser.FindCurrentBlock(LineNumber, CharIndex:
  Integer);
var
  Token: TCnWidePasToken;
  CurrIndex: Integer;

  procedure _BackwardFindDeclarePos;
  var
    Level: Integer;
    I, NestedProcs: Integer;
    StartInner: Boolean;
  begin
    Level := 0;
    StartInner := True;
    NestedProcs := 1;
    for I := CurrIndex - 1 downto 0 do
    begin
      Token := Tokens[I];
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
    I, NestedProcs: Integer;
    EndInner: Boolean;
  begin
    Level := 0;
    EndInner := True;
    NestedProcs := 1;
    for I := CurrIndex to Count - 1 do
    begin
      Token := Tokens[I];
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

  function _GetMethodName(StartToken, CloseToken: TCnWidePasToken): CnWideString;
  var
    I: Integer;
  begin
    Result := '';
    if Assigned(StartToken) and Assigned(CloseToken) then
      for I := StartToken.ItemIndex + 1 to CloseToken.ItemIndex do
      begin
        Token := Tokens[I];
        if (Token.Token^ = '(') or (Token.Token^ = ':') or (Token.Token^ = ';') then
          Break;
        Result := Result + Trim(Token.Token);
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

function TCnWidePasStructParser.IndexOfToken(Token: TCnWidePasToken): Integer;
begin
  Result := FList.IndexOf(Token);
end;

function TCnWidePasStructParser.FindCurrentDeclaration(LineNumber, CharIndex: Integer): CnWideString;
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

// 分析源代码中引用的单元
procedure ParseUnitUsesW(const Source: CnWideString; UsesList: TStrings;
  SupportUnicodeIdent: Boolean);
var
  Lex: TCnPasWideLex;
  Flag: Integer;
  S: CnWideString;
begin
  UsesList.Clear;
  Lex := TCnPasWideLex.Create(SupportUnicodeIdent);

  Flag := 0;
  S := '';
  try
    Lex.Origin := PWideChar(Source);
    while Lex.TokenID <> tkNull do
    begin
      if Lex.TokenID = tkUses then
      begin
        while not (Lex.TokenID in [tkNull, tkSemiColon]) do
        begin
          Lex.Next;
          if Lex.TokenID = tkIdentifier then
          begin
            S := S + CnWideString(Lex.Token);
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

{ TCnWidePasToken }

procedure TCnWidePasToken.Clear;
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

function TCnWidePasToken.GetToken: PWideChar;
begin
  Result := @FToken[0];
end;

initialization
  TokenPool := TCnList.Create;

finalization
  ClearTokenPool;
  FreeAndNil(TokenPool);

end.
