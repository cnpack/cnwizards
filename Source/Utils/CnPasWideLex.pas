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
 |
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

unit CnPasWideLex; 
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：mwPasLex 的 Unicode 版本实现，专门解析 UTF16 字符串
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：此单元自 mwPasLex 移植而来并改为 Unicode/WideString 实现，保留原始版权声明
*           当 SupportUnicodeIdent 为 False 时，Unicode 字符挨个作为 tkUnknown 解析
*           为 True 时整个作为 Identifier 解析。支持 Unicode/非 Unicode 编译器。
* 开发平台：Windows 7 + Delphi XE
* 兼容测试：PWin9X/2000/XP/7 + Delphi 2009 ~
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2022.10.19 V1.7
*               增加几个关键字的支持，修正 tkKeyString 和 tkString 的混淆
*               修正 #$0A 的判断错误，修正字符串内单引号的判断错误，均同步 mPasLex
*           2022.09.09 V1.6
*               Unicode 标识符模式下增加对全角空格的识别
*           2021.08.20 V1.5
*               增加对 dpk 中 requires 与 contains 的识别
*           2019.03.16 V1.4
*               增加 LastNoSpaceCRLF 属性以指明上一个非空格非换行的 Token
*           2016.07.13 V1.3
*               修正一处 Unicode 标识符解析错误的问题
*           2016.01.13 V1.2
*               增加 Unicode 标识符的实现，可控制是否支持 Unicode 标识符
*           2015.04.25 V1.1
*               增加 WideString 实现
*           2015.04.05 V1.0
*               移植单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Controls, mPasLex;

type
{$IFDEF UNICODE}
  CnIndexChar = Char;
  CnWideString = string;
{$ELSE}
  CnIndexChar = AnsiChar;
  CnWideString = WideString;
{$ENDIF}

  TCnPasWideBookmark = class(TObject)
  private
    FRunBookmark: LongInt;
    FLineNumberBookmark: Integer;
    FColumnNumberBookmark: Integer;
    FColumnBookmark: Integer;
    FCommentBookmark: TCommentState;
    FLastNoSpacePosBookmark: Integer;
    FStringLenBookmark: Integer;
    FRoundCountBookmark: Integer;
    FLastNoSpaceBookmark: TTokenKind;
    FToIdentBookmark: PWideChar;
    FIsClassBookmark: Boolean;
    FTokenIDBookmark: TTokenKind;
    FTokenPosBookmark: Integer;
    FIsInterfaceBookmark: Boolean;
    FSquareCountBookmark: Integer;
    FLastIdentPosBookmark: Integer;
    FLineStartOffsetBookmark: Integer;
    FLastNoSpaceCRLFPosBookmark: Integer;
    FLastNoSpaceCRLFBookmark: TTokenKind;
    FMultiLineOffsetBookmark: Integer;
    FMultiLineStartBookmark: Integer;
  public
    property RunBookmark: LongInt read FRunBookmark write FRunBookmark;
    property LineNumberBookmark: Integer read FLineNumberBookmark write FLineNumberBookmark;
    property ColumnNumberBookmark: Integer read FColumnNumberBookmark write FColumnNumberBookmark;
    property ColumnBookmark: Integer read FColumnBookmark write FColumnBookmark;
    property CommentBookmark: TCommentState read FCommentBookmark write FCommentBookmark;
    property RoundCountBookmark: Integer read FRoundCountBookmark write FRoundCountBookmark;
    property SquareCountBookmark: Integer read FSquareCountBookmark write FSquareCountBookmark;
    property TokenIDBookmark: TTokenKind read FTokenIDBookmark write FTokenIDBookmark;
    property LastIdentPosBookmark: Integer read FLastIdentPosBookmark write FLastIdentPosBookmark;
    property LastNoSpaceBookmark: TTokenKind read FLastNoSpaceBookmark write FLastNoSpaceBookmark;
    property LastNoSpacePosBookmark: Integer read FLastNoSpacePosBookmark write FLastNoSpacePosBookmark;
    property LastNoSpaceCRLFBookmark: TTokenKind read FLastNoSpaceCRLFBookmark write FLastNoSpaceCRLFBookmark;
    property LastNoSpaceCRLFPosBookmark: Integer read FLastNoSpaceCRLFPosBookmark write FLastNoSpaceCRLFPosBookmark;
    property LineStartOffsetBookmark: Integer read FLineStartOffsetBookmark write FLineStartOffsetBookmark;
    property IsInterfaceBookmark: Boolean read FIsInterfaceBookmark write FIsInterfaceBookmark;
    property IsClassBookmark: Boolean read FIsClassBookmark write FIsClassBookmark;
    property StringLenBookmark: Integer read FStringLenBookmark write FStringLenBookmark;
    property TokenPosBookmark: Integer read FTokenPosBookmark write FTokenPosBookmark;
    property ToIdentBookmark: PWideChar read FToIdentBookmark write FToIdentBookmark;
    property MultiLineOffsetBookmark: Integer read FMultiLineOffsetBookmark write FMultiLineOffsetBookmark;
    property MultiLineStartBookmark: Integer read FMultiLineStartBookmark write FMultiLineStartBookmark;
  end;

  TCnPasWideLex = class(TObject)
  {* 支持宽字符串解析的 Pascal 语法解析器，支持 Unicode 与非 Unicode 编译器}
  private
    FSupportUnicodeIdent: Boolean;
    FRun: LongInt;       // 步进变量，解析过程中变化，从 0 开始，1 代表一字符长度
    FColumn: Integer;    // 步进变量，解析过程中变化
    FLineNumber: Integer;
    FColumnNumber: Integer;
    FComment: TCommentState;
    FRoundCount: Integer;
    FSquareCount: Integer;
    FTokenID: TTokenKind;
    FLastIdentPos: Integer;
    FLastNoSpace: TTokenKind;
    FLastNoSpacePos: Integer;
    FLastNoSpaceCRLF: TTokenKind;
    FLastNoSpaceCRLFPos: Integer;
    FLineStartOffset: Integer;
    FIsInterface: Boolean;
    FIsClass: Boolean;
    FStringLen: Integer; // 当前字符串的字符长度
    FTokenPos: Integer;
    FToIdent: PWideChar;
    FMultiLineOffset: Integer;
    FMultiLineStart: Integer;

    FOrigin: PWideChar;
    FProcTable: array[#0..#255] of procedure of object;
    FIdentFuncTable: array[0..191] of function: TTokenKind of object;

    function KeyHash(ToHash: PWideChar): Integer;
    // 往前搜索到标识符尾并计算一个散列值供比对
    function KeyComp(const aKey: CnWideString): Boolean;
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
    function Func108: TTokenKind;
    function Func112: TTokenKind;
    function Func117: TTokenKind;
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
    function IdentKind(MayBe: PWideChar): TTokenKind;
    procedure SetOrigin(NewValue: PWideChar);
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
    function GetToken: CnWideString;
    function InSymbols(aChar: WideChar): Boolean;  // 用来判断关键字后的有效字符是否符合一定条件以进一步确定是否关键字
    function InSymbols1(aChar: WideChar): Boolean; // 去除了上面函数的引号操作
    function GetTokenAddr: PWideChar;
    function GetTokenLength: Integer;
    function GetWideColumnNumber: Integer;
    procedure ResetLine;
  protected
    procedure StepRun(Count: Integer = 1; CalcColumn: Boolean = False);
  public
    constructor Create(SupportUnicodeIdent: Boolean = False);
    destructor Destroy; override;
    function CharAhead(Count: Integer): WideChar;
    procedure Next;
    procedure NextID(ID: TTokenKind);
    procedure NextNoJunk;
    procedure NextClass;

    procedure SaveToBookmark(out Bookmark: TCnPasWideBookmark);
    procedure LoadFromBookmark(var Bookmark: TCnPasWideBookmark);

    property IsClass: Boolean read FIsClass;
    property IsInterface: Boolean read FIsInterface;
    property LastIdentPos: Integer read FLastIdentPos;
    property LastNoSpace: TTokenKind read FLastNoSpace;
    {* 上一个非 Space 的 Token，别的都算}
    property LastNoSpacePos: Integer read FLastNoSpacePos;
    {* 上一个非 Space 的 Token 的位置}
    property LastNoSpaceCRLF: TTokenKind read FLastNoSpaceCRLF;
    {* 上一个非 Space 与回车换行的 Token，别的都算}
    property LastNoSpaceCRLFPos: Integer read FLastNoSpaceCRLFPos;
    {* 上一个非 Space 与回车换行的 Token 的位置}
    property LineNumber: Integer read FLineNumber write FLineNumber;
    {* 当前行号，从 1 开始。注意！这里和 TmwPasLex 的 0 开始不一样！}
    property ColumnNumber: Integer read FColumnNumber write FColumnNumber;
    {* 当前直观列号，从 1 开始，类似于 Ansi，不展开 Tab}
    property WideColumnNumber: Integer read GetWideColumnNumber;
    {* 当前原始列号，以字符为单位，从 1 开始，不展开 Tab。目前已知问题：针对行尾的回车换行，此属性不准}
    property LineStartOffset: Integer read FLineStartOffset write FLineStartOffset;
    {* 当前行行首所在的线性位置，相对 FOrigin 的线性偏移量，单位为字符数，0 开始}
    property Origin: PWideChar read FOrigin write SetOrigin;
    {* 待解析内容的起始地址}
    property RunPos: Integer read FRun write SetRunPos;
    {* 当前处理位置相对于 FOrigin 的线性偏移量，单位为字符数，0 开始}
    property TokenPos: Integer read FTokenPos;
    {* 当前 Token 首相对于 FOrigin 的线性偏移量，0 开始，单位为字符数，减去 LineStartOffset 即是当前原始列位置
    （原始列：每个双字节字符占一列，0 开始，不展开 Tab），另外和 IDE 中的编辑器线性位置有 Tab 键以及 Utf8 的区别，不能随意通用}
    property TokenID: TTokenKind read FTokenID;
    {* 当前 Token 类型}
    property Token: CnWideString read GetToken;
    {* 当前 Token 的 Unicode 字符串}
    property TokenAddr: PWideChar read GetTokenAddr;
    {* 当前 Token 的 Unicode 字符串地址}
    property TokenLength: Integer read GetTokenLength;
    {* 当前 Token 的 Unicode 字符长度}

    property RoundCount: Integer read FRoundCount;
    {* 左小括号数目，开放出来供外界使用}
    property SquareCount: Integer read FSquareCount;
    {* 左中括号数目，开放出来供外界使用}
  end;

implementation

type
  TAnsiCharSet = set of AnsiChar;

var
  Identifiers: array[#0..#255] of ByteBool;
  // 用来直接判断某开始字符是否 idenetifier，包括数字字母下划线

  mHashTable: array[#0..#255] of Integer;
  // 用来存储大小写比较的，大写字母和对应小写字母的位置存储的值相同
  // 注意下标虽然是 Char，Unicode 环境下仍只能限于 #255 内，否则超界

function _WideCharInSet(C: WideChar; CharSet: TAnsiCharSet): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
  if Ord(C) <= $FF then
    Result := AnsiChar(C) in CharSet
  else
    Result := False;
end;

function _IndexChar(C: WideChar): CnIndexChar; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
{$IFDEF UNICODE}
  Result := C;
{$ELSE}
  Result := CnIndexChar(C);
{$ENDIF}
end;

procedure MakeIdentTable;
var
  I, J: AnsiChar;
begin
  for I := #0 to #255 do
  begin
    case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z':
        Identifiers[I] := True;
    else
      Identifiers[I] := False;
    end;
    case I of
      'a'..'z', 'A'..'Z', '_':
        begin
          J := AnsiChar(UpperCase(string(I))[1]);
          mHashTable[I] := Ord(J) - 64;
        end;
    else
      mHashTable[AnsiChar(I)] := 0;
    end;
  end;
end;

// 封装的取 mHashTable 值的函数，防止 WideChar 超界
function GetHashTableValue(C: WideChar): Integer;  {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
  if Ord(C) > Ord(High(mHashTable)) then
    Result := 0
  else
    Result := mHashTable[_IndexChar(C)];
end;

procedure TCnPasWideLex.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 191 do
    case I of
      15:
        FIdentFuncTable[I] := Func15;
      19:
        FIdentFuncTable[I] := Func19;
      20:
        FIdentFuncTable[I] := Func20;
      21:
        FIdentFuncTable[I] := Func21;
      23:
        FIdentFuncTable[I] := Func23;
      25:
        FIdentFuncTable[I] := Func25;
      27:
        FIdentFuncTable[I] := Func27;
      28:
        FIdentFuncTable[I] := Func28;
      29:
        FIdentFuncTable[I] := Func29;
      32:
        FIdentFuncTable[I] := Func32;
      33:
        FIdentFuncTable[I] := Func33;
      35:
        FIdentFuncTable[I] := Func35;
      37:
        FIdentFuncTable[I] := Func37;
      38:
        FIdentFuncTable[I] := Func38;
      39:
        FIdentFuncTable[I] := Func39;
      40:
        FIdentFuncTable[I] := Func40;
      41:
        FIdentFuncTable[I] := Func41;
      42:
        FIdentFuncTable[I] := Func42;
      44:
        FIdentFuncTable[I] := Func44;
      45:
        FIdentFuncTable[I] := Func45;
      46:
        FIdentFuncTable[I] := Func46;
      47:
        FIdentFuncTable[I] := Func47;
      49:
        FIdentFuncTable[I] := Func49;
      52:
        FIdentFuncTable[I] := Func52;
      54:
        FIdentFuncTable[I] := Func54;
      55:
        FIdentFuncTable[I] := Func55;
      56:
        FIdentFuncTable[I] := Func56;
      57:
        FIdentFuncTable[I] := Func57;
      59:
        FIdentFuncTable[I] := Func59;
      60:
        FIdentFuncTable[I] := Func60;
      61:
        FIdentFuncTable[I] := Func61;
      63:
        FIdentFuncTable[I] := Func63;
      64:
        FIdentFuncTable[I] := Func64;
      65:
        FIdentFuncTable[I] := Func65;
      66:
        FIdentFuncTable[I] := Func66;
      69:
        FIdentFuncTable[I] := Func69;
      71:
        FIdentFuncTable[I] := Func71;
      72:
        FIdentFuncTable[I] := Func72;
      73:
        FIdentFuncTable[I] := Func73;
      75:
        FIdentFuncTable[I] := Func75;
      76:
        FIdentFuncTable[I] := Func76;
      79:
        FIdentFuncTable[I] := Func79;
      81:
        FIdentFuncTable[I] := Func81;
      84:
        FIdentFuncTable[I] := Func84;
      85:
        FIdentFuncTable[I] := Func85;
      87:
        FIdentFuncTable[I] := Func87;
      88:
        FIdentFuncTable[I] := Func88;
      89:
        FIdentFuncTable[I] := Func89;
      91:
        FIdentFuncTable[I] := Func91;
      92:
        FIdentFuncTable[I] := Func92;
      94:
        FIdentFuncTable[I] := Func94;
      95:
        FIdentFuncTable[I] := Func95;
      96:
        FIdentFuncTable[I] := Func96;
      97:
        FIdentFuncTable[I] := Func97;
      98:
        FIdentFuncTable[I] := Func98;
      99:
        FIdentFuncTable[I] := Func99;
      100:
        FIdentFuncTable[I] := Func100;
      101:
        FIdentFuncTable[I] := Func101;
      102:
        FIdentFuncTable[I] := Func102;
      103:
        FIdentFuncTable[I] := Func103;
      105:
        FIdentFuncTable[I] := Func105;
      106:
        FIdentFuncTable[I] := Func106;
      108:
        FIdentFuncTable[I] := Func108;
      112:
        FIdentFuncTable[I] := Func112;
      117:
        FIdentFuncTable[I] := Func117;
      126:
        FIdentFuncTable[I] := Func126;
      129:
        FIdentFuncTable[I] := Func129;
      132:
        FIdentFuncTable[I] := Func132;
      133:
        FIdentFuncTable[I] := Func133;
      136:
        FIdentFuncTable[I] := Func136;
      141:
        FIdentFuncTable[I] := Func141;
      143:
        FIdentFuncTable[I] := Func143;
      166:
        FIdentFuncTable[I] := Func166;
      168:
        FIdentFuncTable[I] := Func168;
      191:
        FIdentFuncTable[I] := Func191;
    else
      FIdentFuncTable[I] := AltFunc;
    end;
end;

function TCnPasWideLex.KeyHash(ToHash: PWideChar): Integer;
begin
  Result := 0;
  while (_WideCharInSet(ToHash^, ['a'..'z', 'A'..'Z'])) or
    (FSupportUnicodeIdent and (Ord(ToHash^) > 127) and (ToHash^ <> '　')) do
  begin
    Inc(Result, GetHashTableValue(ToHash^));
    Inc(ToHash);
  end;
  if _WideCharInSet(ToHash^, ['_', '0'..'9']) then
    Inc(ToHash);
  FStringLen := ToHash - FToIdent;
end;  { KeyHash }

function TCnPasWideLex.KeyComp(const aKey: CnWideString): Boolean;
var
  I: Integer;
  P: PWideChar;
begin
  P := FToIdent;
  if Length(aKey) = FStringLen then
  begin
    Result := True;
    for I := 1 to FStringLen do
    begin
      if GetHashTableValue(P^) <> GetHashTableValue(aKey[I]) then
      begin
        Result := False;
        Break;
      end;
      Inc(P);
    end;
  end
  else
    Result := False;
end;  { KeyComp }

function TCnPasWideLex.Func15: TTokenKind;
begin
  if KeyComp('If') then
    Result := tkIf
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func19: TTokenKind;
begin
  if KeyComp('Do') then
    Result := tkDo
  else if KeyComp('And') then
    Result := tkAnd
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func20: TTokenKind;
begin
  if KeyComp('As') then
    Result := tkAs
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func21: TTokenKind;
begin
  if KeyComp('Of') then
    Result := tkOf
  else if KeyComp('At') then
    Result := tkAt
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func23: TTokenKind;
begin
  if KeyComp('End') then
    Result := tkEnd
  else if KeyComp('In') then
    Result := tkIn
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func25: TTokenKind;
begin
  if KeyComp('Far') then
    Result := tkFar
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func27: TTokenKind;
begin
  if KeyComp('Cdecl') then
    Result := tkCdecl
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func28: TTokenKind;
begin
  if KeyComp('Read') then
  begin
    if InSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkRead
  end
  else if KeyComp('Case') then
    Result := tkCase
  else if KeyComp('Is') then
    Result := tkIs
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func29: TTokenKind;
begin
  if KeyComp('On') then
    Result := tkOn
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func32: TTokenKind;
begin
  if KeyComp('File') then
    Result := tkFile
  else if KeyComp('Label') then
    Result := tkLabel
  else if KeyComp('Mod') then
    Result := tkMod
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func33: TTokenKind;
begin
  if KeyComp('Or') then
    Result := tkOr
  else if KeyComp('Name') then
  begin
    if InSymbols1(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkName
  end
  else if KeyComp('Asm') then
    Result := tkAsm
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func35: TTokenKind;
begin
  if KeyComp('To') then
    Result := tkTo
  else if KeyComp('Nil') then
    Result := tkNil
  else if KeyComp('Div') then
    Result := tkDiv
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func37: TTokenKind;
begin
  if KeyComp('Begin') then
    Result := tkBegin
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func38: TTokenKind;
begin
  if KeyComp('Near') then
    Result := tkNear
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func39: TTokenKind;
begin
  if KeyComp('For') then
    Result := tkFor
  else if KeyComp('Shl') then
    Result := tkShl
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func40: TTokenKind;
begin
  if KeyComp('Packed') then
    Result := tkPacked
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func41: TTokenKind;
begin
  if KeyComp('Else') then
    Result := tkElse
  else if KeyComp('Var') then
    Result := tkVar
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func42: TTokenKind;
begin
  if KeyComp('Final') then
    Result := tkElse
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func44: TTokenKind;
begin
  if KeyComp('Set') then
    Result := tkSet
  else if KeyComp('Package') then
    Result := tkPackage
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func45: TTokenKind;
begin
  if KeyComp('Shr') then
    Result := tkShr
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func46: TTokenKind;
begin
  if KeyComp('Sealed') then
    Result := tkSealed
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func47: TTokenKind;
begin
  if KeyComp('Then') then
    Result := tkThen
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func49: TTokenKind;
begin
  if KeyComp('Not') then
    Result := tkNot
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func52: TTokenKind;
begin
  if KeyComp('Raise') then
    Result := tkRaise
  else if KeyComp('Pascal') then
    Result := tkPascal
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func54: TTokenKind;
begin
  if KeyComp('Class') then
  begin
    Result := tkClass;
    if FLastNoSpace = tkEqual then
    begin
      FIsClass := True;
      if Identifiers[_IndexChar(CharAhead(FStringLen))] then
        FIsClass := False;
    end
    else
      FIsClass := False;
  end
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func55: TTokenKind;
begin
  if KeyComp('Object') then
    Result := tkObject
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func56: TTokenKind;
begin
  if KeyComp('Index') then
  begin
    if InSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkIndex
  end
  else if KeyComp('Out') then
    Result := tkOut
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func57: TTokenKind;
begin
  if KeyComp('While') then
    Result := tkWhile
  else if KeyComp('Goto') then
    Result := tkGoto
  else if KeyComp('Xor') then
    Result := tkXor
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func59: TTokenKind;
begin
  if KeyComp('Safecall') then
    Result := tkSafecall
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func60: TTokenKind;
begin
  if KeyComp('With') then
    Result := tkWith
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func61: TTokenKind;
begin
  if KeyComp('Dispid') then
    Result := tkDispid
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func63: TTokenKind;
begin
  if KeyComp('Public') then
  begin
    if InSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkPublic
  end
  else if KeyComp('Record') then
    Result := tkRecord
  else if KeyComp('Try') then
    Result := tkTry
  else if KeyComp('Array') then
    Result := tkArray
  else if KeyComp('Inline') then
    Result := tkInline
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func64: TTokenKind;
begin
  if KeyComp('Uses') then
    Result := tkUses
  else if KeyComp('Unit') then
    Result := tkUnit
  else if KeyComp('Helper') then
    Result := tkHelper
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func65: TTokenKind;
begin
  if KeyComp('Repeat') then
    Result := tkRepeat
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func66: TTokenKind;
begin
  if KeyComp('Type') then
    Result := tkType
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func69: TTokenKind;
begin
  if KeyComp('Dynamic') then
    Result := tkDynamic
  else if KeyComp('Default') then
    Result := tkDefault
  else if KeyComp('Message') then
    Result := tkMessage
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func71: TTokenKind;
begin
  if KeyComp('Stdcall') then
    Result := tkStdcall
  else if KeyComp('Const') then
    Result := tkConst
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func72: TTokenKind;
begin
  if KeyComp('Static') then
    Result := tkStatic
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func73: TTokenKind;
begin
  if KeyComp('Except') then
    Result := tkExcept
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func75: TTokenKind;
begin
  if KeyComp('Write') then
  begin
    if InSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkWrite
  end
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func76: TTokenKind;
begin
  if KeyComp('Until') then
    Result := tkUntil
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func79: TTokenKind;
begin
  if KeyComp('Finally') then
    Result := tkFinally
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func81: TTokenKind;
begin
  if KeyComp('Interface') then
  begin
    Result := tkInterface;
    if FLastNoSpace = tkEqual then
      FIsInterface := True
    else
      FIsInterface := False;
  end
  else if KeyComp('Stored') then
    Result := tkStored
  else if KeyComp('Deprecated') then
    Result := tkDeprecated
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func84: TTokenKind;
begin
  if KeyComp('Abstract') then
    Result := tkAbstract
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func85: TTokenKind;
begin
  if KeyComp('Library') then
    Result := tkLibrary
  else if KeyComp('Forward') then
    Result := tkForward
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func87: TTokenKind;
begin
  if KeyComp('String') then
    Result := tkKeyString
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func88: TTokenKind;
begin
  if KeyComp('Program') then
    Result := tkProgram
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func89: TTokenKind;
begin
  if KeyComp('Strict') then
    Result := tkStrict
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func91: TTokenKind;
begin
  if KeyComp('Private') then
  begin
    if InSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkPrivate
  end
  else if KeyComp('Downto') then
    Result := tkDownto
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func92: TTokenKind;
begin
  if KeyComp('overload') then
    Result := tkOverload
  else if KeyComp('Inherited') then
    Result := tkInherited
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func94: TTokenKind;
begin
  if KeyComp('Resident') then
    Result := tkResident
  else if KeyComp('Readonly') then
    Result := tkReadonly
  else if KeyComp('Assembler') then
    Result := tkAssembler
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func95: TTokenKind;
begin
  if KeyComp('Absolute') then
    Result := tkAbsolute
  else if KeyComp('Contains') then
    Result := tkContains
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func96: TTokenKind;
begin
  if KeyComp('Published') then
  begin
    if InSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkPublished
  end
  else if KeyComp('Override') then
    Result := tkOverride
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func97: TTokenKind;
begin
  if KeyComp('Threadvar') then
    Result := tkThreadvar
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func98: TTokenKind;
begin
  if KeyComp('Export') then
    Result := tkExport
  else if KeyComp('Nodefault') then
    Result := tkNodefault
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func99: TTokenKind;
begin
  if KeyComp('External') then
    Result := tkExternal
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func100: TTokenKind;
begin
  if KeyComp('Automated') then
  begin
    if InSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkAutomated
  end
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func101: TTokenKind;
begin
  if KeyComp('Register') then
    Result := tkRegister
  else if KeyComp('Platform') then
    Result := tkPlatform
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func102: TTokenKind;
begin
  if KeyComp('Function') then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func103: TTokenKind;
begin
  if KeyComp('Virtual') then
    Result := tkVirtual
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func105: TTokenKind;
begin
  if KeyComp('Procedure') then
    Result := tkProcedure
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func106: TTokenKind;
begin
  if KeyComp('Protected') then
  begin
    if InSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkProtected
  end
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func108: TTokenKind;
begin
  if KeyComp('Operator') then
    Result := tkOperator
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func112: TTokenKind;
begin
  if KeyComp('Requires') then
    Result := tkRequires
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func117: TTokenKind;
begin
  if KeyComp('Exports') then
    Result := tkExports
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func126: TTokenKind;
begin
  if KeyComp('Implements') then
    Result := tkImplements
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func129: TTokenKind;
begin
  if KeyComp('Dispinterface') then
    Result := tkDispinterface
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func132: TTokenKind;
begin
  if KeyComp('Reintroduce') then
    Result := tkReintroduce
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func133: TTokenKind;
begin
  if KeyComp('Property') then
    Result := tkProperty
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func136: TTokenKind;
begin
  if KeyComp('Finalization') then
    Result := tkFinalization
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func141: TTokenKind;
begin
  if KeyComp('Writeonly') then
    Result := tkWriteonly
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func143: TTokenKind;
begin
  if KeyComp('Destructor') then
    Result := tkDestructor
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func166: TTokenKind;
begin
  if KeyComp('Constructor') then
    Result := tkConstructor
  else if KeyComp('Implementation') then
    Result := tkImplementation
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func168: TTokenKind;
begin
  if KeyComp('Initialization') then
    Result := tkInitialization
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.Func191: TTokenKind;
begin
  if KeyComp('Resourcestring') then
    Result := tkResourcestring
  else if KeyComp('Stringresource') then
    Result := tkStringresource
  else
    Result := tkIdentifier;
end;

function TCnPasWideLex.AltFunc: TTokenKind;
begin
  Result := tkIdentifier
end;

function TCnPasWideLex.IdentKind(MayBe: PWideChar): TTokenKind;
var
  HashKey: Integer;
begin
  FToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 192 then
    Result := FIdentFuncTable[HashKey]
  else
    Result := tkIdentifier;
end;

procedure TCnPasWideLex.MakeMethodTables;
var
  I: AnsiChar;
begin
  for I := #0 to #255 do
    case I of
      #0:
        FProcTable[I] := NullProc;
      #10:
        FProcTable[I] := LFProc;
      #13:
        FProcTable[I] := CRProc;
      #1..#9, #11, #12, #14..#32:
        FProcTable[I] := SpaceProc;
      '#':
        FProcTable[I] := AsciiCharProc;
      '$':
        FProcTable[I] := IntegerProc;
      #39:
        FProcTable[I] := StringProc;
      '0'..'9':
        FProcTable[I] := NumberProc;
      'A'..'Z', 'a'..'z', '_':
        FProcTable[I] := IdentProc;
      '{':
        FProcTable[I] := BraceOpenProc;
      '}':
        FProcTable[I] := BraceCloseProc;
      '!', '"', '%', '&', '('..'/', ':'..'@', '['..'^', '`', '~':
        begin
          case I of
            '(':
              FProcTable[I] := RoundOpenProc;
            ')':
              FProcTable[I] := RoundCloseProc;
            '*':
              FProcTable[I] := StarProc;
            '+':
              FProcTable[I] := PlusProc;
            ',':
              FProcTable[I] := CommaProc;
            '-':
              FProcTable[I] := MinusProc;
            '.':
              FProcTable[I] := PointProc;
            '/':
              FProcTable[I] := SlashProc;
            ':':
              FProcTable[I] := ColonProc;
            ';':
              FProcTable[I] := SemiColonProc;
            '<':
              FProcTable[I] := LowerProc;
            '=':
              FProcTable[I] := EqualProc;
            '>':
              FProcTable[I] := GreaterProc;
            '@':
              FProcTable[I] := AddressOpProc;
            '[':
              FProcTable[I] := SquareOpenProc;
            ']':
              FProcTable[I] := SquareCloseProc;
            '^':
              FProcTable[I] := PointerSymbolProc;
            '"':
              FProcTable[I] := BadStringProc;
            '&':
              FProcTable[I] := AmpersandProc;
          else
            FProcTable[I] := SymbolProc;
          end;
        end;
    else
      FProcTable[I] := UnknownProc;
    end;
end;

constructor TCnPasWideLex.Create(SupportUnicodeIdent: Boolean);
begin
  inherited Create;
  FSupportUnicodeIdent := SupportUnicodeIdent;
  InitIdent;
  MakeMethodTables;
end;  { Create }

destructor TCnPasWideLex.Destroy;
begin
  inherited Destroy;
end;  { Destroy }

procedure TCnPasWideLex.SetOrigin(NewValue: PWideChar);
begin
  FOrigin := NewValue;
  FComment := csNo;
  FLineNumber := 1;
  FColumn := 1;

  FLineStartOffset := 0;
  FRun := 0;
  Next;
end;  { SetOrigin }

procedure TCnPasWideLex.SetRunPos(Value: Integer);
begin
  FRun := Value;
  Next;
end;

procedure TCnPasWideLex.AddressOpProc;
begin
  case FOrigin[FRun + 1] of
    '@':
      begin
        FTokenID := tkDoubleAddressOp;
        StepRun(2);
      end;
  else
    begin
      FTokenID := tkAddressOp;
      StepRun;
    end;
  end;
end;

procedure TCnPasWideLex.AsciiCharProc;
begin
  FTokenID := tkAsciiChar;
  StepRun;

  if FOrigin[FRun] = '$' then
  begin
    StepRun;
    while _WideCharInSet(FOrigin[FRun], ['0'..'9', 'A'..'F', 'a'..'f']) do
      StepRun;
  end
  else
    while _WideCharInSet(FOrigin[FRun], ['0'..'9']) do
      StepRun;
end;

procedure TCnPasWideLex.BraceCloseProc;
begin
  StepRun;
  FTokenID := tkError;
end;

procedure TCnPasWideLex.BorProc;
begin
  FTokenID := tkBorComment;
  case FOrigin[FRun] of
    #0:
      begin
        NullProc;
        Exit;
      end;

    #10:
      begin
        LFProc;
        Exit;
      end;

    #13:
      begin
        CRProc;
        Exit;
      end;
  end;

  while FOrigin[FRun] <> #0 do
    case FOrigin[FRun] of
      '}':
        begin
          FComment := csNo;
          StepRun;
          Break;
        end;
      #10:
        Break;

      #13:
        Break;
    else
      StepRun;
    end;
end;

procedure TCnPasWideLex.BraceOpenProc;
begin
  case FOrigin[FRun + 1] of
    '$':
      FTokenID := tkCompDirect;
  else
    begin
      FTokenID := tkBorComment;
      FComment := csBor;
    end;
  end;
  StepRun(1, True); // 注释部分需要处理双字节字符
  while FOrigin[FRun] <> #0 do
    case FOrigin[FRun] of
      '}':
        begin
          FComment := csNo;
          StepRun;
          Break;
        end;
      #10:
        Break;

      #13:
        Break;
    else
      StepRun(1, True);
    end;
end;

procedure TCnPasWideLex.ColonProc;
begin
  case FOrigin[FRun + 1] of
    '=':
      begin
        StepRun(2);
        FTokenID := tkAssign;
      end;
  else
    begin
      StepRun;
      FTokenID := tkColon;
    end;
  end;
end;

procedure TCnPasWideLex.CommaProc;
begin
  StepRun;
  FTokenID := tkComma;
end;

procedure TCnPasWideLex.CRProc;
begin
  case FComment of
    csBor:
      FTokenID := tkCRLFCo;
    csAnsi:
      FTokenID := tkCRLFCo;
  else
    FTokenID := tkCRLF;
  end;

  case FOrigin[FRun + 1] of
    #10:
      StepRun(2);
  else
    StepRun;
  end;
  ResetLine;
end;

procedure TCnPasWideLex.EqualProc;
begin
  StepRun;
  FTokenID := tkEqual;
end;

procedure TCnPasWideLex.GreaterProc;
begin
  case FOrigin[FRun + 1] of
    '=':
      begin
        StepRun(2);
        FTokenID := tkGreaterEqual;
      end;
  else
    begin
      StepRun;
      FTokenID := tkGreater;
    end;
  end;
end;

function TCnPasWideLex.InSymbols(aChar: WideChar): Boolean;
begin
  if _WideCharInSet(aChar, ['#', '$', '&', #39, '(', ')', '*', '+', ',', '?', '.', '/', ':', ';', '<', '=', '>', '@', '[', ']', '^']) then
    Result := True
  else
    Result := False;
end;

function TCnPasWideLex.InSymbols1(aChar: WideChar): Boolean;
begin
  if _WideCharInSet(aChar, ['#', '$', '&', '(', ')', '*', '+', ',', '?', '.', '/', ':', ';', '<', '=', '>', '@', '[', ']', '^']) then
    Result := True
  else
    Result := False;
end;

function TCnPasWideLex.CharAhead(Count: Integer): WideChar;
var
  P: PWideChar;
begin
  P := FOrigin + FRun + Count;
  while _WideCharInSet(P^, [#1..#9, #11, #12, #14..#32]) do
    Inc(P);
  Result := P^;
end;

procedure TCnPasWideLex.IdentProc;
begin
  FTokenID := IdentKind((FOrigin + FRun));
  StepRun(FStringLen, True);
  while Identifiers[_IndexChar(FOrigin[FRun])] or
    (FSupportUnicodeIdent and (Ord(_IndexChar(FOrigin[FRun])) > 127) and (FOrigin[FRun] <> '　')) do
    StepRun(1, FSupportUnicodeIdent); // 支持宽字符标识符时需要计算步进
end;

procedure TCnPasWideLex.IntegerProc;
begin
  StepRun;
  FTokenID := tkInteger;
  while _WideCharInSet(FOrigin[FRun], ['0'..'9', 'A'..'F', 'a'..'f']) do
    StepRun;
end;

procedure TCnPasWideLex.LFProc;
begin
  case FComment of
    csBor:
      FTokenID := tkCRLFCo;
    csAnsi:
      FTokenID := tkCRLFCo;
  else
    FTokenID := tkCRLF;
  end;

  case FOrigin[FRun + 1] of
    #13:
      StepRun(2);
  else
    StepRun;
  end;
  ResetLine;
end;

procedure TCnPasWideLex.LoadFromBookmark(var Bookmark: TCnPasWideBookmark);
begin
  if Bookmark <> nil then
    with Bookmark do
    begin
      FRun := RunBookmark;
      FLineNumber := LineNumberBookmark;
      FColumnNumber := ColumnNumberBookmark;
      FColumn := ColumnBookmark;
      FComment := CommentBookmark;
      FLastNoSpacePos := LastNoSpacePosBookmark;
      FLastNoSpaceCRLFPos := LastNoSpaceCRLFPosBookmark;
      FStringLen := StringLenBookmark;
      FRoundCount := RoundCountBookmark;
      FLastNoSpace := LastNoSpaceBookmark;
      FLastNoSpaceCRLF := LastNoSpaceCRLFBookmark;
      FToIdent := ToIdentBookmark;
      FIsClass := IsClassBookmark;
      FTokenID := TokenIDBookmark;
      FTokenPos := TokenPosBookmark;
      FIsInterface := IsInterfaceBookmark;
      FSquareCount := SquareCountBookmark;
      FLastIdentPos := LastIdentPosBookmark;
      FLineStartOffset := LineStartOffsetBookmark;
      FMultiLineOffset := FMultiLineOffsetBookmark;
      FMultiLineStart := FMultiLineStartBookmark;

      FreeAndNil(Bookmark);
    end;
end;

procedure TCnPasWideLex.LowerProc;
begin
  case FOrigin[FRun + 1] of
    '=':
      begin
        StepRun(2);
        FTokenID := tkLowerEqual;
      end;
    '>':
      begin
        StepRun(2);
        FTokenID := tkNotEqual;
      end
  else
    begin
      StepRun;
      FTokenID := tkLower;
    end;
  end;
end;

procedure TCnPasWideLex.MinusProc;
begin
  StepRun;
  FTokenID := tkMinus;
end;

procedure TCnPasWideLex.NullProc;
begin
  FTokenID := tkNull;
end;

procedure TCnPasWideLex.NumberProc;
begin
  StepRun;
  FTokenID := tkNumber;
  while _WideCharInSet(FOrigin[FRun], ['0'..'9', '.', 'e', 'E']) do
  begin
    case FOrigin[FRun] of
      '.':
        if FOrigin[FRun + 1] = '.' then
          Break
        else
          FTokenID := tkFloat
    end;
    StepRun;
  end;
end;

procedure TCnPasWideLex.PlusProc;
begin
  StepRun;
  FTokenID := tkPlus;
end;

procedure TCnPasWideLex.PointerSymbolProc;
begin
  StepRun;
  FTokenID := tkPointerSymbol;
end;

procedure TCnPasWideLex.PointProc;
begin
  case FOrigin[FRun + 1] of
    '.':
      begin
        StepRun(2);
        FTokenID := tkDotDot;
      end;
    ')':
      begin
        StepRun(2);
        FTokenID := tkSquareClose;
        Dec(FSquareCount);
      end;
  else
    begin
      StepRun;
      FTokenID := tkPoint;
    end;
  end;
end;

procedure TCnPasWideLex.RoundCloseProc;
begin
  StepRun;
  FTokenID := tkRoundClose;
  Dec(FRoundCount);
end;

procedure TCnPasWideLex.AnsiProc;
begin
  FTokenID := tkAnsiComment;
  case FOrigin[FRun] of
    #0:
      begin
        NullProc;
        Exit;
      end;

    #10:
      begin
        LFProc;
        Exit;
      end;

    #13:
      begin
        CRProc;
        Exit;
      end;
  end;

  while FOrigin[FRun] <> #0 do
    case FOrigin[FRun] of
      '*':
        if FOrigin[FRun + 1] = ')' then
        begin
          FComment := csNo;
          StepRun(2);
          Break;
        end
        else
          StepRun;
      #10:
        Break;

      #13:
        Break;
    else
      StepRun;
    end;
end;

procedure TCnPasWideLex.RoundOpenProc;
begin
  StepRun;
  case FOrigin[FRun] of
    '*':
      begin
        FTokenID := tkAnsiComment;
        if FOrigin[FRun + 1] = '$' then
          FTokenID := tkCompDirect
        else
          FComment := csAnsi;
        StepRun(1, True);
        while FOrigin[FRun] <> #0 do
          case FOrigin[FRun] of
            '*':
              if FOrigin[FRun + 1] = ')' then
              begin
                FComment := csNo;
                StepRun(2);
                Break;
              end
              else
                StepRun(1, True);
            #10:
              Break;
            #13:
              Break;
          else
            StepRun(1, True);
          end;
      end;
    '.':
      begin
        StepRun;
        FTokenID := tkSquareOpen;
        Inc(FSquareCount);
      end;
  else
    begin
      FTokenID := tkRoundOpen;
      Inc(FRoundCount);
    end;
  end;
end;

procedure TCnPasWideLex.SaveToBookmark(out Bookmark: TCnPasWideBookmark);
begin
  Bookmark := TCnPasWideBookmark.Create;
  with Bookmark do
  begin
    RunBookmark := FRun;
    LineNumberBookmark := FLineNumber;
    ColumnNumberBookmark := FColumnNumber;
    ColumnBookmark := FColumn;
    CommentBookmark := FComment;
    LastNoSpacePosBookmark := FLastNoSpacePos;
    LastNoSpaceCRLFPosBookmark := FLastNoSpaceCRLFPos;
    StringLenBookmark := FStringLen;
    RoundCountBookmark := FRoundCount;
    LastNoSpaceBookmark := FLastNoSpace;
    LastNoSpaceCRLFBookmark := FLastNoSpaceCRLF;
    ToIdentBookmark := FToIdent;
    IsClassBookmark := FIsClass;
    TokenIDBookmark := FTokenID;
    TokenPosBookmark := FTokenPos;
    IsInterfaceBookmark := FIsInterface;
    SquareCountBookmark := FSquareCount;
    LastIdentPosBookmark := FLastIdentPos;
    LineStartOffsetBookmark := FLineStartOffset;
    MultiLineOffsetBookmark := FMultiLineOffset;
    MultiLineStartBookmark := FMultiLineStart;
  end;
end;

procedure TCnPasWideLex.SemiColonProc;
begin
  StepRun;
  FTokenID := tkSemiColon;
end;

procedure TCnPasWideLex.SlashProc;
begin
  case FOrigin[FRun + 1] of
    '/':
      begin
        StepRun(2);
        FTokenID := tkSlashesComment;
        while FOrigin[FRun] <> #0 do
        begin
          case FOrigin[FRun] of
            #10, #13:
              Break;
          end;
          StepRun;
        end;
      end;
  else
    begin
      StepRun;
      FTokenID := tkSlash;
    end;
  end;
end;

procedure TCnPasWideLex.SpaceProc;
begin
  StepRun;
  FTokenID := tkSpace;
  while _WideCharInSet(FOrigin[FRun], [#1..#9, #11, #12, #14..#32])
    or (FOrigin[FRun] = '　') do
    StepRun;
end;

procedure TCnPasWideLex.SquareCloseProc;
begin
  StepRun;
  FTokenID := tkSquareClose;
  Dec(FSquareCount);
end;

procedure TCnPasWideLex.SquareOpenProc;
begin
  StepRun;
  FTokenID := tkSquareOpen;
  Inc(FSquareCount);
end;

procedure TCnPasWideLex.StarProc;
begin
  StepRun;
  FTokenID := tkStar;
end;

procedure TCnPasWideLex.StepRun(Count: Integer; CalcColumn: Boolean);
var
  I: Integer;
begin
  if not CalcColumn then
    Inc(FColumn, Count)
  else
  begin
    // 根据 FRun 处 Count 个字符的内容计算需要增加的列数
    for I := 0 to Count - 1 do
    begin
      // 真正精确判断需要跟具体字体度量宽度有关，这里姑且认为值大的占两列
      if Ord(FOrigin[FRun + I]) > $900 then
        Inc(FColumn, SizeOf(WideChar))
      else // 小的部分只占一列
        Inc(FColumn, SizeOf(AnsiChar));
    end;
  end;
  Inc(FRun, Count);
end;

procedure TCnPasWideLex.StringProc;
begin
  FTokenID := tkString;
  if (FOrigin[FRun + 1] = #39) and (FOrigin[FRun + 2] = #39) and
    ((FOrigin[FRun + 3] = #13) or (FOrigin[FRun + 3] = #10)) then // 出现仨单引号且后面是回车换行说明是多行字符串的新语法
  begin
    StepRun(2);
    FTokenID := tkMultiLineString;
    FMultiLineOffset := 0;
    FMultiLineStart := 0;

    repeat
      if FOrigin[FRun] = #13 then // 多行字符串内如果有换行要额外计算
      begin
        if FOrigin[FRun + 1]= #10 then
          StepRun;

        FColumn := 1;
        Inc(FMultiLineOffset);
        FMultiLineStart := FRun; // 要正确指向下一行行首，注意和 mPasLex 不同
      end
      else if FOrigin[FRun] = #10 then
      begin
        FColumn := 1;
        Inc(FMultiLineOffset);
        FMultiLineStart := FRun; // 要正确指向下一行行首，注意和 mPasLex 不同
      end
      else if FOrigin[FRun] = #0 then
        Break;

      StepRun(1, True);
    until (FOrigin[FRun - 1] <> #39) and (FOrigin[FRun] = #39) and (FOrigin[FRun + 1] = #39)
      and (FOrigin[FRun + 2] = #39) and (FOrigin[FRun + 3] <> #39);
    // 结束时需要三连续的单引号且前后不能是单引号

    if FOrigin[FRun]<>#0 then
      StepRun(3);
  end
  else
  begin
    repeat
      if (FOrigin[FRun + 1] = #39) and (FOrigin[FRun + 2] = #39) then
        StepRun(2);

      case FOrigin[FRun] of
        #0, #10, #13:
          Break;
      end;
      StepRun(1, True); // 目前只在字符串内部进行宽字符宽度计算
    until FOrigin[FRun] = #39;
    if FOrigin[FRun] <> #0 then
      StepRun;
  end;
end;

procedure TCnPasWideLex.BadStringProc;
begin
  FTokenID := tkBadString;
  repeat
    case FOrigin[FRun] of
      #0, #10, #13:
        Break;
    end;
    StepRun(1, True); // 目前只在字符串内部进行宽字符宽度计算
  until FOrigin[FRun] = '"';
  if FOrigin[FRun] <> #0 then
    StepRun;
end;

procedure TCnPasWideLex.SymbolProc;
begin
  StepRun;
  FTokenID := tkSymbol;
end;

procedure TCnPasWideLex.AmpersandProc;
begin
  StepRun;
  FTokenID := tkAmpersand;
end;

procedure TCnPasWideLex.UnknownProc;
begin
  StepRun;
  FTokenID := tkUnknown;
end;

procedure TCnPasWideLex.Next;
var
  W: WideChar;
  C: CnIndexChar;
begin
  if FMultiLineOffset > 0 then  // Add by LiuXiao for MultiLine String
  begin
    Inc(FLineNumber, FMultiLineOffset);
    FMultiLineOffset := 0;
  end;
  if FMultiLineStart > 0 then
  begin
    FLineStartOffset := FMultiLineStart;
    FMultiLineStart := 0;
  end;

  case FTokenID of
    tkIdentifier:
      begin
        FLastIdentPos := FTokenPos;
        FLastNoSpace := FTokenID;
        FLastNoSpacePos := FTokenPos;
        FLastNoSpaceCRLF := FTokenID;
        FLastNoSpaceCRLFPos := FTokenPos;
      end;
    tkSpace:
      ;
  else
    begin
      FLastNoSpace := FTokenID;
      FLastNoSpacePos := FTokenPos;
      if FTokenID <> tkCRLF then
      begin
        FLastNoSpaceCRLF := FTokenID;
        FLastNoSpaceCRLFPos := FTokenPos;
      end;
    end;
  end;
  FTokenPos := FRun;
  FColumnNumber := FColumn;

  case FComment of
    csNo:
    begin
      W := FOrigin[FRun];
      C := _IndexChar(W);
      if FSupportUnicodeIdent then
      begin
        if (Ord(W) > 127) and (W <> '　') then
          IdentProc
        else if W = '　' then
          SpaceProc
        else
          FProcTable[C];
      end
      else
      begin
{$IFDEF UNICODE}
        if Ord(W) > 255 then
          UnknownProc
        else
{$ENDIF}
          FProcTable[C];
      end;
    end;
  else
    case FComment of
      csBor:
        BorProc;
      csAnsi:
        AnsiProc;
    end;
  end;
end;

function TCnPasWideLex.GetToken: CnWideString;
var
  Len: LongInt;
  OutStr: CnWideString;
begin
  Len := FRun - FTokenPos;                         // 两个偏移量之差，单位为字符数
  SetString(OutStr, (FOrigin + FTokenPos), Len);   // 以指定内存地址与长度构造字符串
  Result := OutStr;
end;

procedure TCnPasWideLex.NextID(ID: TTokenKind);
begin
  repeat
    case FTokenID of
      tkNull:
        Break;
    else
      Next;
    end;
  until FTokenID = ID;
end;

procedure TCnPasWideLex.NextNoJunk;
begin
  repeat
    Next;
  until not (FTokenID in [tkSlashesComment, tkAnsiComment, tkBorComment, tkCRLF,
    tkCRLFCo, tkSpace]);
end;

procedure TCnPasWideLex.NextClass;
begin
  if FTokenID <> tkNull then
    next;
  repeat
    case FTokenID of
      tkNull:
        Break;
    else
      Next;
    end;
  until(FTokenID = tkClass) and (IsClass);
end;

function TCnPasWideLex.GetTokenAddr: PWideChar;
begin
  Result := FOrigin + FTokenPos;
end;

function TCnPasWideLex.GetTokenLength: Integer;
begin
  Result := FRun - FTokenPos;
end;

function TCnPasWideLex.GetWideColumnNumber: Integer;
begin
  Result := FTokenPos - FLineStartOffset + 1;
end;

procedure TCnPasWideLex.ResetLine;
begin
  Inc(FLineNumber);
  FColumn := 1;
  FLineStartOffset := FRun;
end;

initialization
  MakeIdentTable;

end.

