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

unit CnIDEStrings;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE 相关的字符串定义与处理单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：该单元务必要与 IDE 脱离编译关系以做到独立测试
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2024.08.01
*               创建单元，独立出内容移至此处
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Contnrs, CnWideStrings, mPasLex, CnPasWideLex, mwBCBTokenList,
  CnBCBWideTokenList, CnPasCodeParser, CnCppCodeParser, CnWidePasParser,
  CnWideCppParser;

type
{$IFDEF IDE_STRING_ANSI_UTF8}
  TCnIdeTokenString = WideString; // WideString for Utf8 Conversion
  PCnIdeTokenChar = PWideChar;
  TCnIdeTokenChar = WideChar;
  TCnIdeStringList = TCnWideStringList;
  TCnIdeTokenInt = Word;
{$ELSE}
  TCnIdeTokenString = string;     // Ansi/Utf16
  PCnIdeTokenChar = PChar;
  TCnIdeTokenChar = Char;
  TCnIdeStringList = TStringList;
  {$IFDEF UNICODE}
  TCnIdeTokenInt = Word;
  {$ELSE}
  TCnIdeTokenInt = Byte;
  {$ENDIF}
{$ENDIF}
  PCnIdeTokenInt = ^TCnIdeTokenInt;

  // Ansi/Utf16/Utf16，配合 CnGeneralSaveEditorToStream 系列使用，对应 Ansi/Utf16/Utf16
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}  // 2005 以上
  TCnGeneralPasToken = TCnWidePasToken;
  TCnGeneralCppToken = TCnWideCppToken;
  TCnGeneralPasStructParser = TCnWidePasStructParser;
  TCnGeneralCppStructParser = TCnWideCppStructParser;
  TCnGeneralWidePasLex = TCnPasWideLex;
  TCnGeneralWideBCBTokenList = TCnBCBWideTokenList;
{$ELSE}                               // 5 6 7
  TCnGeneralPasToken = TCnPasToken;
  TCnGeneralCppToken = TCnCppToken;
  TCnGeneralPasStructParser = TCnPasStructureParser;
  TCnGeneralCppStructParser = TCnCppStructureParser;
  TCnGeneralWidePasLex = TmwPasLex;
  TCnGeneralWideBCBTokenList = TBCBTokenList;
{$ENDIF}

{$IFDEF UNICODE}
  TCnGeneralPasLex = TCnPasWideLex;             // TCnGeneralPasLex 在 2005~2007 下仍用 TmwPasLex
  TCnGeneralBCBTokenList = TCnBCBWideTokenList; // TCnGeneralBCBTokenList 也类似
{$ELSE}
  TCnGeneralPasLex = TmwPasLex;                 // 配合 EditFilerSaveFileToStream 系列使用，Ansi/Ansi/Utf16
  TCnGeneralBCBTokenList = TBCBTokenList;
{$ENDIF}

{$IFDEF STAND_ALONE}

  // 独立运行时，把 ToolsAPI 里的一些基础定义搬移过来

  TOTAEditPos = packed record
    Col: SmallInt;       // 1 开始
    Line: Longint;       // 1 开始
  end;

  TOTACharPos = packed record
    CharIndex: SmallInt; // 0 开始
    Line: Longint;       // 1 开始
  end;
{$ENDIF}

function IDEWideCharIsWideLength(const AWChar: WideChar): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* 粗略判断一个 Unicode 宽字符是否占两个字符宽度，行为尽量朝 IDE 靠近}

function GetTokenAnsiEditCol(AToken: TCnGeneralPasToken): Integer;
{* 获取一个 GeneralPasToken 的 AnsiCol，可以是 C/C++ 的 TCnGeneralCppToken}

procedure RemovePasMatchedBraces(Tokens: TList; IsSmall, IsReverse: Boolean);
{* 删除一 Pascal Token 列表中配对的小括号或中括号，IsSmall 表示小括号或中括号，
  IsReverse 为 False 表示左括号入栈，碰到右括号删，True 则反之}

procedure RemoveCppMatchedBraces(Tokens: TList; IsSmall, IsReverse: Boolean);
{* 删除一 C/C++ Token 列表中配对的小括号或中括号，IsSmall 表示小括号或中括号，
  IsReverse 为 False 表示左括号入栈，碰到右括号删，True 则反之}

implementation

function IDEWideCharIsWideLength(const AWChar: WideChar): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
const
  CN_UTF16_ANSI_WIDE_CHAR_SEP = $1100;
var
  C: Integer;
begin
  C := Ord(AWChar);
  Result := C > CN_UTF16_ANSI_WIDE_CHAR_SEP; // 姑且认为比 $1100 大的 Utf16 字符绘制宽度才占俩字节
{$IFDEF DELPHI110_ALEXANDRIA_UP}
  if Result then // 还有些特殊区间的，不完整，先这么写着
  begin
    if ((C >= $1470) and (C <= $14BF)) or
      ((C >= $16A0) and (C <= $16FF)) or
      ((C >= $1D00) and (C <= $1FFF)) or
      ((C >= $20A0) and (C <= $20BF)) or
      ((C >= $2100) and (C <= $24FF)) or  // 字母箭头数学符号等
      ((C >= $2550) and (C <= $256D)) or
      ((C >= $25A0) and (C <= $25BF) and (C <> $25B3) and (C <> $25BD)) then
      Result := False;
  end;
{$ENDIF}
end;

// 获取一个 GeneralPasToken 的 AnsiCol
function GetTokenAnsiEditCol(AToken: TCnGeneralPasToken): Integer;
begin
{$IFDEF IDE_STRING_ANSI_UTF8}
  Result := AToken.EditAnsiCol;
{$ELSE}
  Result := AToken.EditCol;
{$ENDIF}
end;

procedure RemoveCppMatchedBraces(Tokens: TList; IsSmall, IsReverse: Boolean);
var
  T: TCnGeneralCppToken;
  BT, B1, B2: TCTokenKind;
  I: Integer;
  Stack: TStack;
begin
  if (Tokens = nil) or (Tokens.Count <= 1) then
    Exit;

  if IsSmall then
  begin
    B1 := ctkroundopen;
    B2 := ctkroundclose;
  end
  else
  begin
    B1 := ctksquareopen;
    B2 := ctksquareclose;
  end;

  if IsReverse then
  begin
    BT := B1;
    B1 := B2;
    B2 := BT;
  end;

  // 从 List 的 0 往后找，先记录 B1 入堆栈，碰到 B2 则判断弹栈，有则两个都删
  I := 0;
  Stack := TStack.Create;
  try
    while I < Tokens.Count do
    begin
      T := TCnGeneralCppToken(Tokens[I]);
      if T.CppTokenKind = B1 then
        Stack.Push(T)
      else if T.CppTokenKind = B2 then
      begin
        if Stack.Count > 0 then
        begin
          Tokens.Delete(I); // 删了一个，不用 Inc了
          T := Stack.Pop;
          Tokens.Remove(T); // 又删了之前的一个，非但不 Inc，还得 Dec
          Dec(I);
          Continue;
        end;
      end;

      Inc(I);
    end;
  finally
    Stack.Free;
  end;
end;

procedure RemovePasMatchedBraces(Tokens: TList; IsSmall, IsReverse: Boolean);
var
  T: TCnGeneralPasToken;
  BT, B1, B2: TTokenKind;
  I: Integer;
  Stack: TStack;
begin
  if (Tokens = nil) or (Tokens.Count <= 1) then
    Exit;

  if IsSmall then
  begin
    B1 := tkRoundOpen;
    B2 := tkRoundClose;
  end
  else
  begin
    B1 := tkSquareOpen;
    B2 := tkSquareClose;
  end;

  if IsReverse then
  begin
    BT := B1;
    B1 := B2;
    B2 := BT;
  end;

  // 从 List 的 0 往后找，先记录 B1 入堆栈，碰到 B2 则判断弹栈，有则两个都删
  I := 0;
  Stack := TStack.Create;
  try
    while I < Tokens.Count do
    begin
      T := TCnGeneralPasToken(Tokens[I]);
      if T.TokenID = B1 then
        Stack.Push(T)
      else if T.TokenID = B2 then
      begin
        if Stack.Count > 0 then
        begin
          Tokens.Delete(I); // 删了一个，不用 Inc了
          T := Stack.Pop;
          Tokens.Remove(T); // 又删了之前的一个，非但不 Inc，还得 Dec
          Dec(I);
          Continue;
        end;
      end;

      Inc(I);
    end;
  finally
    Stack.Free;
  end;
end;

end.
