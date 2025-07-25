{+--------------------------------------------------------------------------+
 | Class:       TmwPasLex
 | Created:     07.98 - 10.98
 | Author:      Martin Waldenburg
 | Description: A very fast Pascal tokenizer.
 | Version:     1.32
 | Copyright (c) 1998, 1999 Martin Waldenburg
 | All rights reserved.
 |
 | LICENCE CONDITIONS
 |
 | USE OF THE ENCLOSED SOFTWARE
 | INDICATES YOUR ASSENT TO THE
 | FOLLOWING LICENCE CONDITIONS.
 |
 | These Licence Conditions are exlusively
 | governed by the Law and Rules of the
 | Federal Republic of Germany.
 |
 | Redistribution and use in source and binary form, with or without
 | modification, are permitted provided that the following conditions
 | are met:
 |
 | 1. Redistributions of source code must retain the above copyright
 |    notice, this list of conditions and the following disclaimer.
 |    If the source is modified, the complete original and unmodified
 |    source code has to distributed with the modified version.
 |
 | 2. Redistributions in binary form must reproduce the above
 |    copyright notice, these licence conditions and the disclaimer
 |    found at the end of this licence agreement in the documentation
 |    and/or other materials provided with the distribution.
 |
 | 3. Software using this code must contain a visible line of credit.
 |
 | 4. If my code is used in a "for profit" product, you have to donate
 |    to a registered charity in an amount that you feel is fair.
 |    You may use it in as many of your products as you like.
 |    Proof of this donation must be provided to the author of
 |    this software.
 |
 | 5. If you for some reasons don't want to give public credit to the
 |    author, you have to donate three times the price of your software
 |    product, or any other product including this component in any way,
 |    but no more than $500 US and not less than $200 US, or the
 |    equivalent thereof in other currency, to a registered charity.
 |    You have to do this for every of your products, which uses this
 |    code separately.
 |    Proof of this donations must be provided to the author of
 |    this software.
 |
 | DISCLAIMER:
 |
 | THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS'.
 |
 | ALL EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 | THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 | PARTICULAR PURPOSE ARE DISCLAIMED.
 |
 | IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 | INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 | (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 | OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 | INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 | WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 | NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 | THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 |
 |  Martin.Waldenburg@T-Online.de
 +--------------------------------------------------------------------------+}

unit mPasLex;

{$I CnWizards.inc}

interface

uses
  SysUtils, Classes, Controls;

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable: array[#0..#255] of Integer;

type
  TTokenKind=(tkAbsolute, tkAbstract, tkAddressOp, tkAmpersand, tkAnd, tkAnsiComment,
    tkArray, tkAs, tkAt, tkAsciiChar, tkAsm, tkAssembler, tkAssign, tkAutomated,
    tkBegin, tkBadString, tkBorComment, tkCase, tkCdecl, tkClass, tkColon,
    tkComma, tkCompDirect, tkContains, tkConst, tkConstructor, tkCRLF, tkCRLFCo, tkDefault,
    tkDeprecated, tkDestructor, tkDispid, tkDispinterface, tkDiv, tkDo, tkDoubleAddressOp,
    tkDotDot, tkDownto, tkDynamic, tkElse, tkEnd, tkEqual, tkError, tkExcept,
    tkExport, tkExports, tkExternal, tkFar, tkFile, tkFinalization, tkFinal, tkFinally,
    tkFloat, tkFor, tkForward, tkFunction, tkGoto, tkGreater, tkGreaterEqual,
    tkHelper, tkIdentifier, tkIf, tkImplementation, tkImplements, tkIn, tkIndex,
    tkInherited, tkInitialization, tkInline, tkInteger, tkInterface, tkIs,
    tkKeyString, tkLabel, tkLibrary, tkLower, tkLowerEqual, tkMessage, tkMinus,
    tkMod, tkMultiLineString, tkName, tkNear, tkNil, tkNodefault, tkNone, tkNoReturn,
    tkNot, tkNotEqual, tkNull, tkNumber, tkObject, tkOf, tkOn, tkOperator, tkOr,
    tkOut, tkOverload, tkOverride, tkPackage, tkPacked, tkPascal, tkPlatform,
    tkPlus, tkPoint, tkPointerSymbol, tkPrivate, tkProcedure, tkProgram,
    tkProperty, tkProtected, tkPublic, tkPublished, tkRaise, tkRead, tkReadonly,
    tkRecord, tkRegister, tkReintroduce, tkRepeat, tkRequires, tkResident,
    tkResourcestring, tkRoundClose, tkRoundOpen, tkSafecall, tkSealed, tkSemiColon, tkSet,
    tkShl, tkShr, tkSlash, tkSlashesComment, tkStatic, tkStrict, tkSquareClose, tkSquareOpen,
    tkSpace, tkStar, tkStdcall, tkStored, tkString, tkStringresource, tkSymbol,
    tkThen, tkThreadvar, tkTo, tkTry, tkType, tkUnit, tkUnknown, tkUntil, tkUses,
    tkVar, tkVirtual, tkWhile, tkWith, tkWrite, tkWriteonly, tkXor);

  {***
    原有问题一：Pascal 字符串和 string 关键字混为一谈了，都是 tkString，
      解决方案：已将后者修改成 tkKeyString
    原有问题二：字符串不支持内部的单引号，会错误拆分解析成连续字符串
      解决方案：已修复 StringProc 中的问题
    原有问题三：#$0A 这种本应是 tkAsciiChar 的会被解析成一个井号的 tkAsciiChar 加上 $0A 的 tkInteger
      解决方案：已修复 AsciiCharProc 中的问题
    原有问题四：不支持 tkRequires, tkContains, tkStrict，tkOperator, tkPlatform, tkDeprecated, tkFinal, tkStatic, tkSealed, tkHelper, tkPackage
      解决方案：都加上了
    原有问题五：IsClass 的判断用 class 前面有等号且后面不是合法标识符来判断，对于 class sealed/helper 以及不换行的 class public 等声明判断有误
      解决方案：暂无
    新问题六：不支持新语法中的三个单引号括起来的多行字符串新语法
      解决方案：加上了 tkMultiLineString
    新问题七：不支持新语法中的 noreturn
      解决方案：加上了 tkNoReturn
  ***}

  TTokenKinds = set of TTokenKind;

  TCommentState=(csAnsi, csBor, csNo);

{$IFDEF BCB5}
  PAnsiChar = PChar;
{$ENDIF}

  TmwPasLexBookmark = packed record
  {* 书签，保存 Lex 的临时状态供恢复，为了简便起见使用 record，Added by LiuXiao}
    SupportWideCharIdentBookmark: Boolean;
    CommentBookmark: TCommentState;
    OriginBookmark: PAnsiChar;
    RunBookmark: LongInt;
    TempBookmark: PAnsiChar;
    RoundCountBookmark: Integer;
    SquareCountBookmark: Integer;
    StringLenBookmark: Integer;
    ToIdentBookmark: PAnsiChar;
    TokenPosBookmark: Integer;
    LineNumberBookmark: Integer;
    TokenIDBookmark: TTokenKind;
    LastIdentPosBookmark: Integer;
    LastNoSpaceBookmark: TTokenKind;
    LastNoSpacePosBookmark: Integer;
    LastNoSpaceCRLFBookmark: TTokenKind;
    LastNoSpaceCRLFPosBookmark: Integer;
    LinePosBookmark: Integer;
    IsInterfaceBookmark: Boolean;
    IsClassBookmark: Boolean;
    MultiLineOffsetBookmark: Integer;
    MultiLineStartBookmark: Integer;
  end;

  TmwPasLex=class(TObject)
  private
    FSupportWideCharIdent: Boolean;
    fComment: TCommentState;
    fOrigin: PAnsiChar;
    fProcTable: array[#0..#255]of procedure of Object;
    Run: LongInt;
    Temp: PAnsiChar;
    FRoundCount: Integer;
    FSquareCount: Integer;
    fStringLen: Integer;
    fMultiLineOffset: Integer;  // Added by LiuXiao
    fMultiLineStart: Integer;   // Added by LiuXiao
    fToIdent: PAnsiChar;
    fIdentFuncTable: array[0..191]of function: TTokenKind of Object;
    fTokenPos: Integer;
    fLineNumber: Integer;
    FTokenID: TTokenKind;
    fLastIdentPos: Integer;
    fLastNoSpace: TTokenKind;
    fLastNoSpacePos: Integer;
    fLastNoSpaceCRLF: TTokenKind;  // Added by LiuXiao
    fLastNoSpaceCRLFPos: Integer;  // Added by LiuXiao
    fLinePos: Integer;
    fIsInterface: Boolean;
    fIsClass: Boolean;
    function KeyHash(ToHash: PAnsiChar): Integer;
    function KeyComp(const aKey: AnsiString): Boolean;
    function Func15: TTokenKind;
    function Func19: TTokenKind;
    function Func20: TTokenKind;
    function Func21: TTokenKind;
    function Func23: TTokenKind;
    function Func25: TTokenKind;
    function Func27: TTokenKind;
    function Func28: TTokenKind;
    function Func29: TTokenKind;
    function Func32: TTokenKind;
    function Func33: TTokenKind;
    function Func35: TTokenKind;
    function Func37: TTokenKind;
    function Func38: TTokenKind;
    function Func39: TTokenKind;
    function Func40: TTokenKind;
    function Func41: TTokenKind;
    function Func42: TTokenKind;
    function Func44: TTokenKind;
    function Func45: TTokenKind;
    function Func46: TTokenKind;
    function Func47: TTokenKind;
    function Func49: TTokenKind;
    function Func52: TTokenKind;
    function Func54: TTokenKind;
    function Func55: TTokenKind;
    function Func56: TTokenKind;
    function Func57: TTokenKind;
    function Func59: TTokenKind;
    function Func60: TTokenKind;
    function Func61: TTokenKind;
    function Func63: TTokenKind;
    function Func64: TTokenKind;
    function Func65: TTokenKind;
    function Func66: TTokenKind;
    function Func69: TTokenKind;
    function Func71: TTokenKind;
    function Func72: TTokenKind;
    function Func73: TTokenKind;
    function Func75: TTokenKind;
    function Func76: TTokenKind;
    function Func79: TTokenKind;
    function Func81: TTokenKind;
    function Func84: TTokenKind;
    function Func85: TTokenKind;
    function Func87: TTokenKind;
    function Func88: TTokenKind;
    function Func89: TTokenKind;
    function Func91: TTokenKind;
    function Func92: TTokenKind;
    function Func94: TTokenKind;
    function Func95: TTokenKind;
    function Func96: TTokenKind;
    function Func97: TTokenKind;
    function Func98: TTokenKind;
    function Func99: TTokenKind;
    function Func100: TTokenKind;
    function Func101: TTokenKind;
    function Func102: TTokenKind;
    function Func103: TTokenKind;
    function Func105: TTokenKind;
    function Func106: TTokenKind;
    function Func108: TTokenKind; // Added by LiuXiao
    function Func112: TTokenKind; // Added by LiuXiao
    function Func117: TTokenKind;
    function Func125: TTokenKind; // Added by LiuXiao
    function Func126: TTokenKind;
    function Func129: TTokenKind;
    function Func132: TTokenKind;
    function Func133: TTokenKind;
    function Func136: TTokenKind;
    function Func141: TTokenKind;
    function Func143: TTokenKind;
    function Func166: TTokenKind;
    function Func168: TTokenKind;
    function Func191: TTokenKind;
    function AltFunc: TTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PAnsiChar): TTokenKind;
    procedure SetOrigin(NewValue: PAnsiChar);
    procedure SetRunPos(Value: Integer);
    procedure MakeMethodTables;
    procedure AddressOpProc;
    procedure AsciiCharProc;
    procedure AnsiProc;
    procedure BorProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
    procedure ColonProc;
    procedure CommaProc;
    procedure CRProc;
    procedure EqualProc;
    procedure GreaterProc;
    procedure IdentProc;
    procedure IntegerProc;
    procedure LFProc;
    procedure LowerProc;
    procedure MinusProc;
    procedure NullProc;
    procedure NumberProc;
    procedure PlusProc;
    procedure PointerSymbolProc;
    procedure PointProc;
    procedure RoundCloseProc;
    procedure RoundOpenProc;
    procedure SemiColonProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure SquareCloseProc;
    procedure SquareOpenProc;
    procedure StarProc;
    procedure StringProc;
    procedure BadStringProc; // 代替双引号字符串
    procedure SymbolProc;
    procedure AmpersandProc; // &
    procedure UnknownProc;
    function GetToken: AnsiString;
    function InSymbols(aChar: AnsiChar): Boolean;
    function InSymbols1(aChar: AnsiChar): Boolean;
    function GetTokenAddr: PAnsiChar;
    function GetTokenLength: Integer;
  protected
  public
    constructor Create(SupportWideCharIdent: Boolean = False);
    destructor Destroy; override;
    function CharAhead(Count: Integer): AnsiChar;
    procedure Next;
    procedure NextID(ID: TTokenKind);
    procedure NextNoJunk;
    procedure NextClass;

    procedure SaveToBookmark(var Bookmark: TmwPasLexBookmark);
    procedure LoadFromBookmark(var Bookmark: TmwPasLexBookmark);

    property IsClass: Boolean read fIsClass;
    property IsInterface: Boolean read fIsInterface;
    property LastIdentPos: Integer read fLastIdentPos;
    property LastNoSpaceCRLF: TTokenKind read fLastNoSpaceCRLF;
    {* 上一个非 Space 与回车换行的 Token，别的都算}
    property LastNoSpaceCRLFPos: Integer read fLastNoSpaceCRLFPos;
    property LastNoSpace: TTokenKind read fLastNoSpace;
    {* 上一个非 Space 的 Token，别的都算}
    property LastNoSpacePos: Integer read fLastNoSpacePos;
    property LineNumber: Integer read fLineNumber write fLineNumber;
    {* 当前行号，从 0 开始}
    property LinePos: Integer read fLinePos write fLinePos;
    {* 当前行行首所在的线性位置，0 开始，单位是字节}
    property Origin: PAnsiChar read fOrigin write SetOrigin;
    {* 待解析的字符串地址}
    property RunPos: Integer read Run write SetRunPos;
    {* 解析线性位置，一般指向当前 Token 的尾巴后}
    property TokenPos: Integer read fTokenPos;
    {* 当前 Token 所在的线性位置，0 开始，单位是字节，减去 LinePos 即是当前列位置
      注意：和 IDE 中的编辑器线性位置有 Tab 键以及 Utf8（高版本 Delphi）的区别，不能随意通用}
    property Token: AnsiString read GetToken;
    {* 当前 Token 的字符串值}

    property TokenAddr: PAnsiChar read GetTokenAddr;
    property TokenLength: Integer read GetTokenLength;
    {* 此俩属性为 PAnsiChar 方式使用，以避免 D2010 下性能问题}

    property TokenID: TTokenKind read FTokenID;
     {* 当前 Token 的类型}
  end;

implementation

procedure MakeIdentTable;
var
  I, J: AnsiChar;
begin
  for I:=#0 to #255 do
  begin
    Case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z', #128..#255: Identifiers[I]:=True;
      // Allows WideChar Identifier
    else Identifiers[I]:=False;
    end;
    Case I of
      'a'..'z', 'A'..'Z', '_':
      begin
        J:=AnsiChar(UpperCase(string(I))[1]);
        mHashTable[I]:=Ord(J)-64;
      end;
    else mHashTable[AnsiChar(I)]:=0;
    end;
  end;
end;

procedure TmwPasLex.InitIdent;
var
  I: Integer;
begin
  for I:=0 to 191 do
    Case I of
      15: fIdentFuncTable[I]:=Func15;
      19: fIdentFuncTable[I]:=Func19;
      20: fIdentFuncTable[I]:=Func20;
      21: fIdentFuncTable[I]:=Func21;
      23: fIdentFuncTable[I]:=Func23;
      25: fIdentFuncTable[I]:=Func25;
      27: fIdentFuncTable[I]:=Func27;
      28: fIdentFuncTable[I]:=Func28;
      29: fIdentFuncTable[I]:=Func29;
      32: fIdentFuncTable[I]:=Func32;
      33: fIdentFuncTable[I]:=Func33;
      35: fIdentFuncTable[I]:=Func35;
      37: fIdentFuncTable[I]:=Func37;
      38: fIdentFuncTable[I]:=Func38;
      39: fIdentFuncTable[I]:=Func39;
      40: fIdentFuncTable[I]:=Func40;
      41: fIdentFuncTable[I]:=Func41;
      42: fIdentFuncTable[I]:=Func42;
      44: fIdentFuncTable[I]:=Func44;
      45: fIdentFuncTable[I]:=Func45;
      46: fIdentFuncTable[I]:=Func46;
      47: fIdentFuncTable[I]:=Func47;
      49: fIdentFuncTable[I]:=Func49;
      52: fIdentFuncTable[I]:=Func52;
      54: fIdentFuncTable[I]:=Func54;
      55: fIdentFuncTable[I]:=Func55;
      56: fIdentFuncTable[I]:=Func56;
      57: fIdentFuncTable[I]:=Func57;
      59: fIdentFuncTable[I]:=Func59;
      60: fIdentFuncTable[I]:=Func60;
      61: fIdentFuncTable[I]:=Func61;
      63: fIdentFuncTable[I]:=Func63;
      64: fIdentFuncTable[I]:=Func64;
      65: fIdentFuncTable[I]:=Func65;
      66: fIdentFuncTable[I]:=Func66;
      69: fIdentFuncTable[I]:=Func69;
      71: fIdentFuncTable[I]:=Func71;
      72: fIdentFuncTable[I]:=Func72;
      73: fIdentFuncTable[I]:=Func73;
      75: fIdentFuncTable[I]:=Func75;
      76: fIdentFuncTable[I]:=Func76;
      79: fIdentFuncTable[I]:=Func79;
      81: fIdentFuncTable[I]:=Func81;
      84: fIdentFuncTable[I]:=Func84;
      85: fIdentFuncTable[I]:=Func85;
      87: fIdentFuncTable[I]:=Func87;
      88: fIdentFuncTable[I]:=Func88;
      89: fIdentFuncTable[I]:=Func89;
      91: fIdentFuncTable[I]:=Func91;
      92: fIdentFuncTable[I]:=Func92;
      94: fIdentFuncTable[I]:=Func94;
      95: fIdentFuncTable[I]:=Func95;
      96: fIdentFuncTable[I]:=Func96;
      97: fIdentFuncTable[I]:=Func97;
      98: fIdentFuncTable[I]:=Func98;
      99: fIdentFuncTable[I]:=Func99;
      100: fIdentFuncTable[I]:=Func100;
      101: fIdentFuncTable[I]:=Func101;
      102: fIdentFuncTable[I]:=Func102;
      103: fIdentFuncTable[I]:=Func103;
      105: fIdentFuncTable[I]:=Func105;
      106: fIdentFuncTable[I]:=Func106;
      108: fIdentFuncTable[I]:=Func108;
      112: fIdentFuncTable[I]:=Func112;
      117: fIdentFuncTable[I]:=Func117;
      125: fIdentFuncTable[I]:=Func125;
      126: fIdentFuncTable[I]:=Func126;
      129: fIdentFuncTable[I]:=Func129;
      132: fIdentFuncTable[I]:=Func132;
      133: fIdentFuncTable[I]:=Func133;
      136: fIdentFuncTable[I]:=Func136;
      141: fIdentFuncTable[I]:=Func141;
      143: fIdentFuncTable[I]:=Func143;
      166: fIdentFuncTable[I]:=Func166;
      168: fIdentFuncTable[I]:=Func168;
      191: fIdentFuncTable[I]:=Func191;
    else fIdentFuncTable[I]:=AltFunc;
    end;
end;

function TmwPasLex.KeyHash(ToHash: PAnsiChar): Integer;
begin
  Result:=0;
  while ToHash^in ['a'..'z', 'A'..'Z']do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  if ToHash^in ['_', '0'..'9']then inc(ToHash);
  fStringLen:=ToHash-fToIdent;
end; { KeyHash }

function TmwPasLex.KeyComp(const aKey: AnsiString): Boolean;
var
  I: Integer;
begin
  Temp:=fToIdent;
  if Length(aKey)=fStringLen then
  begin
    Result:=True;
    for i:=1 to fStringLen do
    begin
      if mHashTable[Temp^]<>mHashTable[aKey[i]]then
      begin
        Result:=False;
        break;
      end;
      inc(Temp);
    end;
  end else Result:=False;
end; { KeyComp }

function TmwPasLex.Func15: TTokenKind;
begin
  if KeyComp('If')then Result:=tkIf else Result:=tkIdentifier;
end;

function TmwPasLex.Func19: TTokenKind;
begin
  if KeyComp('Do')then Result:=tkDo else
    if KeyComp('And')then Result:=tkAnd else Result:=tkIdentifier;
end;

function TmwPasLex.Func20: TTokenKind;
begin
  if KeyComp('As')then Result:=tkAs else Result:=tkIdentifier;
end;

function TmwPasLex.Func21: TTokenKind;
begin
  if KeyComp('Of')then Result:=tkOf else
    if KeyComp('At')then Result:=tkAt else Result:=tkIdentifier;
end;

function TmwPasLex.Func23: TTokenKind;
begin
  if KeyComp('End')then Result:=tkEnd else
    if KeyComp('In')then Result:=tkIn else Result:=tkIdentifier;
end;

function TmwPasLex.Func25: TTokenKind;
begin
  if KeyComp('Far')then Result:=tkFar else Result:=tkIdentifier;
end;

function TmwPasLex.Func27: TTokenKind;
begin
  if KeyComp('Cdecl')then Result:=tkCdecl else Result:=tkIdentifier;
end;

function TmwPasLex.Func28: TTokenKind;
begin
  if KeyComp('Read')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkRead
  end else
    if KeyComp('Case')then Result:=tkCase else
      if KeyComp('Is')then Result:=tkIs else Result:=tkIdentifier;
end;

function TmwPasLex.Func29: TTokenKind;
begin
  if KeyComp('On')then Result:=tkOn else Result:=tkIdentifier;
end;

function TmwPasLex.Func32: TTokenKind;
begin
  if KeyComp('File')then Result:=tkFile else
    if KeyComp('Label')then Result:=tkLabel else
      if KeyComp('Mod')then Result:=tkMod else Result:=tkIdentifier;
end;

function TmwPasLex.Func33: TTokenKind;
begin
  if KeyComp('Or')then Result:=tkOr else
    if KeyComp('Name')then
    begin
      if inSymbols1(CharAhead(fStringLen))then Result:=tkIdentifier else
        Result:=tkName
    end else
      if KeyComp('Asm')then Result:=tkAsm else Result:=tkIdentifier;
end;

function TmwPasLex.Func35: TTokenKind;
begin
  if KeyComp('To')then Result:=tkTo else
    if KeyComp('Nil')then Result:=tkNil else
      if KeyComp('Div')then Result:=tkDiv else Result:=tkIdentifier;
end;

function TmwPasLex.Func37: TTokenKind;
begin
  if KeyComp('Begin')then Result:=tkBegin else Result:=tkIdentifier;
end;

function TmwPasLex.Func38: TTokenKind;
begin
  if KeyComp('Near')then Result:=tkNear else Result:=tkIdentifier;
end;

function TmwPasLex.Func39: TTokenKind;
begin
  if KeyComp('For')then Result:=tkFor else
    if KeyComp('Shl')then Result:=tkShl else Result:=tkIdentifier;
end;

function TmwPasLex.Func40: TTokenKind;
begin
  if KeyComp('Packed')then Result:=tkPacked else Result:=tkIdentifier;
end;

function TmwPasLex.Func41: TTokenKind;
begin
  if KeyComp('Else')then Result:=tkElse else
    if KeyComp('Var')then Result:=tkVar else Result:=tkIdentifier;
end;

function TmwPasLex.Func42: TTokenKind;
begin
  if KeyComp('Final')then Result:=tkFinal else Result:=tkIdentifier;
end;

function TmwPasLex.Func44: TTokenKind;
begin
  if KeyComp('Set')then Result:=tkSet else
    if KeyComp('Package')then Result:=tkPackage else Result:=tkIdentifier;
end;

function TmwPasLex.Func45: TTokenKind;
begin
  if KeyComp('Shr')then Result:=tkShr else Result:=tkIdentifier;
end;

function TmwPasLex.Func46: TTokenKind;
begin
  if KeyComp('Sealed')then Result:=tkSealed else Result:=tkIdentifier;
end;

function TmwPasLex.Func47: TTokenKind;
begin
  if KeyComp('Then')then Result:=tkThen else Result:=tkIdentifier;
end;

function TmwPasLex.Func49: TTokenKind;
begin
  if KeyComp('Not')then Result:=tkNot else Result:=tkIdentifier;
end;

function TmwPasLex.Func52: TTokenKind;
begin
  if KeyComp('Raise')then Result:=tkRaise else
    if KeyComp('Pascal')then Result:=tkPascal else Result:=tkIdentifier;
end;

function TmwPasLex.Func54: TTokenKind;
begin
  if KeyComp('Class')then
  begin
    Result:=tkClass;
    if fLastNoSpace=tkEqual then
    begin
      fIsClass:=True;
      if Identifiers[CharAhead(fStringLen)]then fIsClass:=False;
    end else fIsClass:=False;
  end else Result:=tkIdentifier;
end;

function TmwPasLex.Func55: TTokenKind;
begin
  if KeyComp('Object')then Result:=tkObject else Result:=tkIdentifier;
end;

function TmwPasLex.Func56: TTokenKind;
begin
  if KeyComp('Index')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkIndex
  end else
    if KeyComp('Out')then Result:=tkOut else Result:=tkIdentifier;
end;

function TmwPasLex.Func57: TTokenKind;
begin
  if KeyComp('While')then Result:=tkWhile else
    if KeyComp('Goto')then Result:=tkGoto else
      if KeyComp('Xor')then Result:=tkXor else Result:=tkIdentifier;
end;

function TmwPasLex.Func59: TTokenKind;
begin
  if KeyComp('Safecall')then Result:=tkSafecall else Result:=tkIdentifier;
end;

function TmwPasLex.Func60: TTokenKind;
begin
  if KeyComp('With')then Result:=tkWith else Result:=tkIdentifier;
end;

function TmwPasLex.Func61: TTokenKind;
begin
  if KeyComp('Dispid')then Result:=tkDispid else Result:=tkIdentifier;
end;

function TmwPasLex.Func63: TTokenKind;
begin
  if KeyComp('Public')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkPublic
  end else
    if KeyComp('Record')then Result:=tkRecord else
      if KeyComp('Try')then Result:=tkTry else
        if KeyComp('Array')then Result:=tkArray else
          if KeyComp('Inline')then Result:=tkInline else Result:=tkIdentifier;
end;

function TmwPasLex.Func64: TTokenKind;
begin
  if KeyComp('Uses')then Result:=tkUses else
    if KeyComp('Unit')then Result:=tkUnit else
      if KeyComp('Helper')then Result:=tkHelper else Result:=tkIdentifier;
end;

function TmwPasLex.Func65: TTokenKind;
begin
  if KeyComp('Repeat')then Result:=tkRepeat else Result:=tkIdentifier;
end;

function TmwPasLex.Func66: TTokenKind;
begin
  if KeyComp('Type')then Result:=tkType else Result:=tkIdentifier;
end;

function TmwPasLex.Func69: TTokenKind;
begin
  if KeyComp('Dynamic')then Result:=tkDynamic else
    if KeyComp('Default')then Result:=tkDefault else
      if KeyComp('Message')then Result:=tkMessage else Result:=tkIdentifier;
end;

function TmwPasLex.Func71: TTokenKind;
begin
  if KeyComp('Stdcall')then Result:=tkStdcall else
    if KeyComp('Const')then Result:=tkConst else Result:=tkIdentifier;
end;

function TmwPasLex.Func72: TTokenKind;
begin
  if KeyComp('Static')then Result:=tkStatic else Result:=tkIdentifier;
end;

function TmwPasLex.Func73: TTokenKind;
begin
  if KeyComp('Except')then Result:=tkExcept else Result:=tkIdentifier;
end;

function TmwPasLex.Func75: TTokenKind;
begin
  if KeyComp('Write')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkWrite
  end else Result:=tkIdentifier;
end;

function TmwPasLex.Func76: TTokenKind;
begin
  if KeyComp('Until')then Result:=tkUntil else Result:=tkIdentifier;
end;

function TmwPasLex.Func79: TTokenKind;
begin
  if KeyComp('Finally')then Result:=tkFinally else Result:=tkIdentifier;
end;

function TmwPasLex.Func81: TTokenKind;
begin
  if KeyComp('Interface')then
  begin
    Result:=tkInterface;
    if fLastNoSpace=tkEqual then
      fIsInterface:=True else fIsInterface:=False;
  end else
    if KeyComp('Stored')then Result:=tkStored
      else if KeyComp('Deprecated')then Result:=tkDeprecated else Result:=tkIdentifier;
end;

function TmwPasLex.Func84: TTokenKind;
begin
  if KeyComp('Abstract')then Result:=tkAbstract else Result:=tkIdentifier;
end;

function TmwPasLex.Func85: TTokenKind;
begin
  if KeyComp('Library')then Result:=tkLibrary else
    if KeyComp('Forward')then Result:=tkForward else Result:=tkIdentifier;
end;

function TmwPasLex.Func87: TTokenKind;
begin
  if KeyComp('String')then Result:=tkKeyString else Result:=tkIdentifier;
end;

function TmwPasLex.Func88: TTokenKind;
begin
  if KeyComp('Program')then Result:=tkProgram else Result:=tkIdentifier;
end;

function TmwPasLex.Func89: TTokenKind;
begin
  if KeyComp('Strict')then Result:=tkStrict else Result:=tkIdentifier;
end;

function TmwPasLex.Func91: TTokenKind;
begin
  if KeyComp('Private')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkPrivate
  end else
    if KeyComp('Downto')then Result:=tkDownto else Result:=tkIdentifier;
end;

function TmwPasLex.Func92: TTokenKind;
begin
  if KeyComp('overload') then
    Result:=tkOverload
  else
    if KeyComp('Inherited') then
      Result:=tkInherited
    else
      Result:=tkIdentifier;
end;

function TmwPasLex.Func94: TTokenKind;
begin
  if KeyComp('Resident')then Result:=tkResident else
    if KeyComp('Readonly')then Result:=tkReadonly else
      if KeyComp('Assembler')then Result:=tkAssembler else Result:=tkIdentifier;
end;

function TmwPasLex.Func95: TTokenKind;
begin
  if KeyComp('Absolute')then Result:=tkAbsolute else
    if KeyComp('Contains')then Result:=tkContains else Result:=tkIdentifier; // Added by LiuXiao
end;

function TmwPasLex.Func96: TTokenKind;
begin
  if KeyComp('Published')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkPublished
  end else
    if KeyComp('Override')then Result:=tkOverride else Result:=tkIdentifier;
end;

function TmwPasLex.Func97: TTokenKind;
begin
  if KeyComp('Threadvar')then Result:=tkThreadvar else Result:=tkIdentifier;
end;

function TmwPasLex.Func98: TTokenKind;
begin
  if KeyComp('Export')then Result:=tkExport else
    if KeyComp('Nodefault')then Result:=tkNodefault else Result:=tkIdentifier;
end;

function TmwPasLex.Func99: TTokenKind;
begin
  if KeyComp('External')then Result:=tkExternal else Result:=tkIdentifier;
end;

function TmwPasLex.Func100: TTokenKind;
begin
  if KeyComp('Automated')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkAutomated
  end else Result:=tkIdentifier;
end;

function TmwPasLex.Func101: TTokenKind;
begin
  if KeyComp('Register')then Result:=tkRegister
  else if KeyComp('Platform')then Result:=tkPlatform
  else Result:=tkIdentifier;
end;

function TmwPasLex.Func102: TTokenKind;
begin
  if KeyComp('Function')then Result:=tkFunction else Result:=tkIdentifier;
end;

function TmwPasLex.Func103: TTokenKind;
begin
  if KeyComp('Virtual')then Result:=tkVirtual else Result:=tkIdentifier;
end;

function TmwPasLex.Func105: TTokenKind;
begin
  if KeyComp('Procedure')then Result:=tkProcedure else Result:=tkIdentifier;
end;

function TmwPasLex.Func106: TTokenKind;
begin
  if KeyComp('Protected')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkProtected
  end else Result:=tkIdentifier;
end;

// Added by LiuXiao
function TmwPasLex.Func108: TTokenKind;
begin
  if KeyComp('Operator')then Result:=tkOperator else Result:=tkIdentifier;
end;

function TmwPasLex.Func112: TTokenKind;
begin
  if KeyComp('Requires')then Result:=tkRequires else Result:=tkIdentifier;
end;

function TmwPasLex.Func117: TTokenKind;
begin
  if KeyComp('Exports')then Result:=tkExports else Result:=tkIdentifier;
end;

function TmwPasLex.Func125: TTokenKind;
begin
  if KeyComp('NoReturn') then
    Result:=tkNoReturn
  else
    Result:=tkIdentifier;
end;

function TmwPasLex.Func126: TTokenKind;
begin
  if KeyComp('Implements') then
    Result:=tkImplements
  else
  Result:=tkIdentifier;
end;

function TmwPasLex.Func129: TTokenKind;
begin
  if KeyComp('Dispinterface')then Result:=tkDispinterface else Result:=tkIdentifier;
end;

function TmwPasLex.Func132: TTokenKind;
begin
  if KeyComp('Reintroduce') then
    Result:=tkReintroduce
  else
  Result:=tkIdentifier;
end;

function TmwPasLex.Func133: TTokenKind;
begin
  if KeyComp('Property')then Result:=tkProperty else Result:=tkIdentifier;
end;

function TmwPasLex.Func136: TTokenKind;
begin
  if KeyComp('Finalization')then Result:=tkFinalization else Result:=tkIdentifier;
end;

function TmwPasLex.Func141: TTokenKind;
begin
  if KeyComp('Writeonly')then Result:=tkWriteonly else Result:=tkIdentifier;
end;

function TmwPasLex.Func143: TTokenKind;
begin
  if KeyComp('Destructor')then Result:=tkDestructor else Result:=tkIdentifier;
end;

function TmwPasLex.Func166: TTokenKind;
begin
  if KeyComp('Constructor')then Result:=tkConstructor else
    if KeyComp('Implementation')then Result:=tkImplementation else Result:=tkIdentifier;
end;

function TmwPasLex.Func168: TTokenKind;
begin
  if KeyComp('Initialization')then Result:=tkInitialization else Result:=tkIdentifier;
end;

function TmwPasLex.Func191: TTokenKind;
begin
  if KeyComp('Resourcestring')then Result:=tkResourcestring else
    if KeyComp('Stringresource')then Result:=tkStringresource else Result:=tkIdentifier;
end;

function TmwPasLex.AltFunc: TTokenKind;
begin
  Result:=tkIdentifier;
end;

function TmwPasLex.IdentKind(MayBe: PAnsiChar): TTokenKind;
var
  HashKey: Integer;
begin
  fToIdent:=MayBe;
  HashKey:=KeyHash(MayBe);
  if HashKey<192 then Result:=fIdentFuncTable[HashKey]else Result:=tkIdentifier;
end;

procedure TmwPasLex.MakeMethodTables;
var
  I: AnsiChar;
begin
  for I:=#0 to #255 do
    case I of
      #0: fProcTable[I]:=NullProc;
      #10: fProcTable[I]:=LFProc;
      #13: fProcTable[I]:=CRProc;
      #1..#9, #11, #12, #14..#32:
        fProcTable[I]:=SpaceProc;
      '#': fProcTable[I]:=AsciiCharProc;
      '$': fProcTable[I]:=IntegerProc;
      #39: fProcTable[I]:=StringProc;
      '0'..'9': fProcTable[I]:=NumberProc;
      'A'..'Z', 'a'..'z', '_', #127..#255:
        fProcTable[I]:=IdentProc;
      '{': fProcTable[I]:=BraceOpenProc;
      '}': fProcTable[I]:=BraceCloseProc;
      '!', '"', '%', '&', '('..'/', ':'..'@', '['..'^', '`', '~':
        begin
          case I of
            '(': fProcTable[I]:=RoundOpenProc;
            ')': fProcTable[I]:=RoundCloseProc;
            '*': fProcTable[I]:=StarProc;
            '+': fProcTable[I]:=PlusProc;
            ',': fProcTable[I]:=CommaProc;
            '-': fProcTable[I]:=MinusProc;
            '.': fProcTable[I]:=PointProc;
            '/': fProcTable[I]:=SlashProc;
            ':': fProcTable[I]:=ColonProc;
            ';': fProcTable[I]:=SemiColonProc;
            '<': fProcTable[I]:=LowerProc;
            '=': fProcTable[I]:=EqualProc;
            '>': fProcTable[I]:=GreaterProc;
            '@': fProcTable[I]:=AddressOpProc;
            '[': fProcTable[I]:=SquareOpenProc;
            ']': fProcTable[I]:=SquareCloseProc;
            '^': fProcTable[I]:=PointerSymbolProc;
            '"': fProcTable[I]:=BadStringProc;
            '&': fProcTable[I]:=AmpersandProc;
          else fProcTable[I]:=SymbolProc;
          end;
        end;
    else fProcTable[I]:=UnknownProc;
    end;
end;

constructor TmwPasLex.Create(SupportWideCharIdent: Boolean);
begin
  inherited Create;
  FSupportWideCharIdent := SupportWideCharIdent;
  InitIdent;
  MakeMethodTables;
end; { Create }

destructor TmwPasLex.Destroy;
begin
  inherited Destroy;
end; { Destroy }

procedure TmwPasLex.SetOrigin(NewValue: PAnsiChar);
begin
  fOrigin:=NewValue;
  fComment:=csNo;
  fLineNumber:=0;
  fLinePos:=0;
  Run:=0;
  Next;
end; { SetOrigin }

procedure TmwPasLex.SetRunPos(Value: Integer);
begin
  Run:=Value;
  Next;
end;

procedure TmwPasLex.AddressOpProc;
begin
  Case FOrigin[Run+1]of
    '@':
      begin
        fTokenID:=tkDoubleAddressOp;
        inc(Run, 2);
      end;
  else
    begin
      fTokenID:=tkAddressOp;
      inc(Run);
    end;
  end;
end;

procedure TmwPasLex.AsciiCharProc;
begin
  fTokenID:=tkAsciiChar;
  inc(Run);
  if FOrigin[Run] = '$' then
  begin
    inc(Run);
    while FOrigin[Run]in ['0'..'9', 'A'..'F', 'a'..'f']do inc(Run);
  end
  else
    while FOrigin[Run]in ['0'..'9']do inc(Run);
end;

procedure TmwPasLex.BraceCloseProc;
begin
  inc(Run);
  fTokenId:=tkError;
end;

procedure TmwPasLex.BorProc;
begin
  fTokenID:=tkBorComment;
  case FOrigin[Run]of
    #0:
      begin
        NullProc;
        exit;
      end;

    #10:
      begin
        LFProc;
        exit;
      end;

    #13:
      begin
        CRProc;
        exit;
      end;
  end;

  while FOrigin[Run]<>#0 do
    case FOrigin[Run]of
      '}':
        begin
          fComment:=csNo;
          inc(Run);
          break;
        end;
      #10: break;

      #13: break;
    else
      // LiuXiao add Multi Byte AnsiChar
      if SysLocale.FarEast and (FOrigin[Run] in LeadBytes) then
        Inc(Run, 2)
      else
        Inc(Run);
    end;
end;

procedure TmwPasLex.BraceOpenProc;
begin
  Case FOrigin[Run+1]of
    '$': fTokenID:=tkCompDirect;
  else
    begin
      fTokenID:=tkBorComment;
      fComment:=csBor;
    end;
  end;
  inc(Run);
  while FOrigin[Run]<>#0 do
    case FOrigin[Run]of
      '}':
        begin
          fComment:=csNo;
          inc(Run);
          break;
        end;
      #10: break;

      #13: break;
    else inc(Run);
    end;
end;

procedure TmwPasLex.ColonProc;
begin
  Case FOrigin[Run+1]of
    '=':
      begin
        inc(Run, 2);
        fTokenID:=tkAssign;
      end;
  else
    begin
      inc(Run);
      fTokenID:=tkColon;
    end;
  end;
end;

procedure TmwPasLex.CommaProc;
begin
  inc(Run);
  fTokenID:=tkComma;
end;

procedure TmwPasLex.CRProc;
begin
  Case fComment of
    csBor: fTokenID:=tkCRLFCo;
    csAnsi: fTokenID:=tkCRLFCo;
  else fTokenID:=tkCRLF;
  end;

  Case FOrigin[Run+1]of
    #10: inc(Run, 2);
  else inc(Run);
  end;
  inc(fLineNumber);
  fLinePos:=Run;
end;

procedure TmwPasLex.EqualProc;
begin
  inc(Run);
  fTokenID:=tkEqual;
end;

procedure TmwPasLex.GreaterProc;
begin
  Case FOrigin[Run+1]of
    '=':
      begin
        inc(Run, 2);
        fTokenID:=tkGreaterEqual;
      end;
  else
    begin
      inc(Run);
      fTokenID:=tkGreater;
    end;
  end;
end;

function TmwPasLex.InSymbols(aChar: AnsiChar): Boolean;
begin
  if aChar in ['#', '$', '&', #39, '(', ')', '*', '+', ',', '?', '.', '/', ':',
    ';', '<', '=', '>', '@', '[', ']', '^']then Result:=True else Result:=False;
end;

function TmwPasLex.InSymbols1(aChar: AnsiChar): Boolean;
begin
  if aChar in ['#', '$', '&', '(', ')', '*', '+', ',', '?', '.', '/', ':',
    ';', '<', '=', '>', '@', '[', ']', '^']then Result:=True else Result:=False;
end;

function TmwPasLex.CharAhead(Count: Integer): AnsiChar;
begin
  Temp:=fOrigin+Run+Count;
  while Temp^in [#1..#9, #11, #12, #14..#32]do inc(Temp);
  Result:=Temp^;
end;

procedure TmwPasLex.IdentProc;
begin
  fTokenID:=IdentKind((fOrigin+Run));
  inc(Run, fStringLen);
  while (Identifiers[fOrigin[Run]]) or
    (FSupportWideCharIdent and (Ord(FOrigin[Run]) > 127)) do
    inc(Run);
end;

procedure TmwPasLex.IntegerProc;
begin
  inc(Run);
  fTokenID:=tkInteger;
  while FOrigin[Run]in ['0'..'9', 'A'..'F', 'a'..'f']do inc(Run);
end;

procedure TmwPasLex.LFProc;
begin
  Case fComment of
    csBor: fTokenID:=tkCRLFCo;
    csAnsi: fTokenID:=tkCRLFCo;
  else fTokenID:=tkCRLF;
  end;

  Case FOrigin[Run+1]of
    #13: inc(Run, 2);
  else inc(Run);
  end;
  inc(fLineNumber);
  fLinePos:=Run;
end;

procedure TmwPasLex.LowerProc;
begin
  case FOrigin[Run+1]of
    '=':
      begin
        inc(Run, 2);
        fTokenID:=tkLowerEqual;
      end;
    '>':
      begin
        inc(Run, 2);
        fTokenID:=tkNotEqual;
      end
  else
    begin
      inc(Run);
      fTokenID:=tkLower;
    end;
  end;
end;

procedure TmwPasLex.MinusProc;
begin
  inc(Run);
  fTokenID:=tkMinus;
end;

procedure TmwPasLex.NullProc;
begin
  fTokenID:=tkNull;
end;

procedure TmwPasLex.NumberProc;
begin
  inc(Run);
  fTokenID:=tkNumber;
  while FOrigin[Run]in ['0'..'9', '.', 'e', 'E']do
  begin
    case FOrigin[Run]of
      '.':
        if FOrigin[Run+1]='.' then break else fTokenID:=tkFloat
    end;
    inc(Run);
  end;
end;

procedure TmwPasLex.PlusProc;
begin
  inc(Run);
  fTokenID:=tkPlus;
end;

procedure TmwPasLex.PointerSymbolProc;
begin
  inc(Run);
  fTokenID:=tkPointerSymbol;
end;

procedure TmwPasLex.PointProc;
begin
  case FOrigin[Run+1]of
    '.':
      begin
        inc(Run, 2);
        fTokenID:=tkDotDot;
      end;
    ')':
      begin
        inc(Run, 2);
        fTokenID:=tkSquareClose;
        dec(FSquareCount);
      end;
  else
    begin
      inc(Run);
      fTokenID:=tkPoint;
    end;
  end;
end;

procedure TmwPasLex.RoundCloseProc;
begin
  inc(Run);
  fTokenID:=tkRoundClose;
  dec(FRoundCount);
end;

procedure TmwPasLex.AnsiProc;
begin
  fTokenID:=tkAnsiComment;
  case FOrigin[Run]of
    #0:
      begin
        NullProc;
        exit;
      end;

    #10:
      begin
        LFProc;
        exit;
      end;

    #13:
      begin
        CRProc;
        exit;
      end;
  end;

  while fOrigin[Run]<>#0 do
    case fOrigin[Run]of
      '*':
        if fOrigin[Run+1]=')' then
        begin
          fComment:=csNo;
          inc(Run, 2);
          break;
        end else inc(Run);
      #10: break;

      #13: break;
    else
      // LiuXiao add Multi Byte AnsiChar
      if SysLocale.FarEast and (FOrigin[Run] in LeadBytes) then
        Inc(Run, 2)
      else
        Inc(Run);
    end;
end;

procedure TmwPasLex.RoundOpenProc;
begin
  inc(Run);
  case fOrigin[Run]of
    '*':
      begin
        fTokenID:=tkAnsiComment;
        if FOrigin[Run+1]='$' then fTokenID:=tkCompDirect else fComment:=csAnsi;
        inc(Run);
        while fOrigin[Run]<>#0 do
          case fOrigin[Run]of
            '*':
              if fOrigin[Run+1]=')' then
              begin
                fComment:=csNo;
                inc(Run, 2);
                break;
              end else inc(Run);
            #10: break;
            #13: break;
          else inc(Run);
          end;
      end;
    '.':
      begin
        inc(Run);
        fTokenID:=tkSquareOpen;
        inc(FSquareCount);
      end;
  else
    begin
      FTokenID:=tkRoundOpen;
      inc(FRoundCount);
    end;
  end;
end;

procedure TmwPasLex.SemiColonProc;
begin
  inc(Run);
  fTokenID:=tkSemiColon;
end;

procedure TmwPasLex.SlashProc;
begin
  case FOrigin[Run+1]of
    '/':
      begin
        inc(Run, 2);
        fTokenID:=tkSlashesComment;
        while FOrigin[Run]<>#0 do
        begin
          case FOrigin[Run]of
            #10, #13: break;
          end;
          inc(Run);
        end;
      end;
  else
    begin
      inc(Run);
      fTokenID:=tkSlash;
    end;
  end;
end;

procedure TmwPasLex.SpaceProc;
begin
  inc(Run);
  fTokenID:=tkSpace;
  while FOrigin[Run]in [#1..#9, #11, #12, #14..#32]do inc(Run);
end;

procedure TmwPasLex.SquareCloseProc;
begin
  inc(Run);
  fTokenID:=tkSquareClose;
  dec(FSquareCount);
end;

procedure TmwPasLex.SquareOpenProc;
begin
  inc(Run);
  fTokenID:=tkSquareOpen;
  inc(FSquareCount);
end;

procedure TmwPasLex.StarProc;
begin
  inc(Run);
  fTokenID:=tkStar;
end;

procedure TmwPasLex.StringProc;
begin
  fTokenID:=tkString;
  if(FOrigin[Run+1]=#39)and(FOrigin[Run+2]=#39)and(FOrigin[Run+3]in[#13,#10]) then // 出现仨单引号且后面是回车或换行说明是多行字符串的新语法
  begin
    inc(Run, 2);
    FTokenID := tkMultiLineString;
    fMultiLineOffset := 0;
    fMultiLineStart := 0;
    repeat
      if FOrigin[Run] = #13 then // 多行字符串内如果有换行要额外计算
      begin
        if FOrigin[Run+1]= #10 then
          inc(Run);

        inc(fMultiLineOffset);
        fMultiLineStart := Run+1; // 要正确指向下一行行首
      end
      else if FOrigin[Run] = #10 then
      begin
        inc(fMultiLineOffset);
        fMultiLineStart := Run+1; // 要正确指向下一行行首
      end
      else if FOrigin[Run] = #0 then
        Break;

      inc(Run);
    until (FOrigin[Run-1]<>#39) and (FOrigin[Run]=#39) and (FOrigin[Run+1]=#39) and (FOrigin[Run+2]=#39) and (FOrigin[Run+3]<>#39);
    // 结束时需要三连续的单引号且前后不能是单引号

    if FOrigin[Run]<>#0 then inc(Run, 3);
  end
  else
  begin
    repeat
      if(FOrigin[Run+1]=#39)and(FOrigin[Run+2]=#39)then inc(Run, 2); // Moved by Liu Xiao
      case FOrigin[Run]of
        #0, #10, #13: break;
      end;
      inc(Run);
    until FOrigin[Run]=#39;
    if FOrigin[Run]<>#0 then inc(Run);
  end;
end;

procedure TmwPasLex.BadStringProc;
begin
  fTokenID:=tkBadString;
  repeat
    case FOrigin[Run]of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FOrigin[Run]='"';
  if FOrigin[Run]<>#0 then inc(Run);
end;

procedure TmwPasLex.SymbolProc;
begin
  inc(Run);
  fTokenID:=tkSymbol;
end;

procedure TmwPasLex.AmpersandProc;
begin
  inc(Run);
  fTokenID:=tkAmpersand;
end;

procedure TmwPasLex.UnknownProc;
begin
  inc(Run);
  fTokenID:=tkUnknown;
end;

procedure TmwPasLex.Next;
var
  C: AnsiChar;
begin
  if fMultiLineOffset > 0 then  // Add by LiuXiao for MultiLine String
  begin
    inc(fLineNumber, fMultiLineOffset);
    fMultiLineOffset := 0;
  end;
  if fMultiLineStart > 0 then
  begin
    fLinePos := fMultiLineStart;
    fMultiLineStart := 0;
  end;

  Case fTokenID of
    tkIdentifier:
      begin
        fLastIdentPos:=fTokenPos;
        fLastNoSpace:=fTokenID;
        fLastNoSpacePos:=fTokenPos;
        fLastNoSpaceCRLF:=fTokenID;  // Add by liuxiao for fLastNoSpaceCRLF
        fLastNoSpaceCRLFPos:=fTokenPos;
      end;
    tkSpace: ;
  else
    begin
      fLastNoSpace:=fTokenID;
      fLastNoSpacePos:=fTokenPos;
      if FTokenID <> tkCRLF then  // Add by liuxiao for fLastNoSpaceCRLF
      begin
        fLastNoSpaceCRLF:=fTokenID;
        fLastNoSpaceCRLFPos:=fTokenPos;
      end;
    end;
  end;
  fTokenPos:=Run;
  Case fComment of
    csNo:
    begin
      C := FOrigin[Run];
      if FSupportWideCharIdent and (Ord(C) > 127) then
        IdentProc
      else
        FProcTable[C];
    end;
  else
    Case fComment of
      csBor: BorProc;
      csAnsi: AnsiProc;
    end;
  end;
end;

function TmwPasLex.GetToken: AnsiString;
var
  Len: LongInt;
  OutStr: AnsiString;
begin
  Len:=Run-fTokenPos;
  SetString(OutStr, (FOrigin+fTokenPos), Len);
  Result := OutStr;
end;

procedure TmwPasLex.NextID(ID: TTokenKind);
begin
  repeat
    Case fTokenID of
      tkNull: break;
    else Next;
    end;
  until fTokenID=ID;
end;

procedure TmwPasLex.NextNoJunk;
begin
  repeat
    Next;
  until not(fTokenID in [tkSlashesComment, tkAnsiComment, tkBorComment, tkCRLF, tkCRLFCo, tkSpace]);
end;

procedure TmwPasLex.NextClass;
begin
  if fTokenID<>tkNull then next;
  repeat
    Case fTokenID of
      tkNull: break;
    else Next;
    end;
  until(fTokenID=tkClass)and(IsClass);
end;

function TmwPasLex.GetTokenAddr: PAnsiChar;
begin
  Result := FOrigin + fTokenPos;
end;

function TmwPasLex.GetTokenLength: Integer;
begin
  Result := Run - fTokenPos;
end;

procedure TmwPasLex.LoadFromBookmark(var Bookmark: TmwPasLexBookmark);
begin
  FSupportWideCharIdent := Bookmark.SupportWideCharIdentBookmark;
  FComment := Bookmark.CommentBookmark;
  FOrigin := Bookmark.OriginBookmark;
  Run := Bookmark.RunBookmark;
  Temp := Bookmark.TempBookmark;
  FRoundCount := Bookmark.RoundCountBookmark;
  FSquareCount := Bookmark.SquareCountBookmark;
  FStringLen := Bookmark.StringLenBookmark;
  FToIdent := Bookmark.ToIdentBookmark;
  FTokenPos := Bookmark.TokenPosBookmark;
  FLineNumber := Bookmark.LineNumberBookmark;
  FTokenID := Bookmark.TokenIDBookmark;
  FLastIdentPos := Bookmark.LastIdentPosBookmark;
  FLastNoSpace := Bookmark.LastNoSpaceBookmark;
  FLastNoSpacePos := Bookmark.LastNoSpacePosBookmark;
  FLastNoSpaceCRLF := Bookmark.LastNoSpaceCRLFBookmark;
  FLastNoSpaceCRLFPos := Bookmark.LastNoSpaceCRLFPosBookmark;
  FLinePos := Bookmark.LinePosBookmark;
  FIsInterface := Bookmark.IsInterfaceBookmark;
  FIsClass := Bookmark.IsClassBookmark;
  fMultiLineOffset := Bookmark.MultiLineOffsetBookmark;
  fMultiLineStart := Bookmark.MultiLineStartBookmark;
end;

procedure TmwPasLex.SaveToBookmark(var Bookmark: TmwPasLexBookmark);
begin
  Bookmark.SupportWideCharIdentBookmark := FSupportWideCharIdent;
  Bookmark.CommentBookmark := FComment;
  Bookmark.OriginBookmark := FOrigin;
  Bookmark.RunBookmark := Run;
  Bookmark.TempBookmark := Temp;
  Bookmark.RoundCountBookmark := FRoundCount;
  Bookmark.SquareCountBookmark := FSquareCount;
  Bookmark.StringLenBookmark := FStringLen;
  Bookmark.ToIdentBookmark := FToIdent;
  Bookmark.TokenPosBookmark := FTokenPos;
  Bookmark.LineNumberBookmark := FLineNumber;
  Bookmark.TokenIDBookmark := FTokenID;
  Bookmark.LastIdentPosBookmark := FLastIdentPos;
  Bookmark.LastNoSpaceBookmark := FLastNoSpace;
  Bookmark.LastNoSpacePosBookmark := FLastNoSpacePos;
  Bookmark.LastNoSpaceCRLFBookmark := FLastNoSpaceCRLF;
  Bookmark.LastNoSpaceCRLFPosBookmark := FLastNoSpaceCRLFPos;
  Bookmark.LinePosBookmark := FLinePos;
  Bookmark.IsInterfaceBookmark := FIsInterface;
  Bookmark.IsClassBookmark := FIsClass;
  Bookmark.MultiLineOffsetBookmark := FMultiLineOffset;
  Bookmark.MultiLineStartBookmark := FMultiLineStart;
end;

initialization
  MakeIdentTable;

end.





