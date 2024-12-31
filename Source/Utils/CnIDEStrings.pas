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
* 备    注：
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
  SysUtils, Classes, CnWideStrings;

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

function IDEWideCharIsWideLength(const AWChar: WideChar): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* 粗略判断一个 Unicode 宽字符是否占两个字符宽度，行为尽量朝 IDE 靠近}

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
      ((C >= $2550) and (C <= $256D)) or
      ((C >= $25A0) and (C <= $25BF) and (C <> $25B3) and (C <> $25BD)) then
      Result := False;
  end;
{$ENDIF}
end;

end.
