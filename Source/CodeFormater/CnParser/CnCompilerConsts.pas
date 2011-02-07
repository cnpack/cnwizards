{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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

unit CnCompilerConsts;

{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：运行期错误提示资源
* 单元作者：CnPack开发组
* 备    注：运行期错误提示资源
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：should be work
* 修改记录：
*   2003-12-16 V0.1
        建立。
================================================================================
|</PRE>}

interface

resourcestring
  SIdentifierExpected = 'Identifier expected';
  SStringExpected = 'String expected';
  SNumberExpected = 'Number expected';
  SCharExpected = '''''%d'''' expected';
  SSymbolExpected = '%s expected, but "%s" found';
  SParseError = '%s on line %d:%d';
  SInvalidBinary = 'Invalid binary value';
  SInvalidString = 'Invalid string constant';
  SInvalidBookmark = 'Invalid Bookmark';
  SLineTooLong = 'Line too long';
  SEndOfCommentExpected = 'Comment end ''}'' or ''*)'' expected';
  SNotSurpport = 'Not Surport %s now';

implementation

end.

