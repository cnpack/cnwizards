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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit IdeInstComp;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 IdeInstComp 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：
* 修改记录：2006.12.30 V1.0
*               创建单元
================================================================================
|</PRE>}

{$R-,H+,X+}

// 当脚本在 uses 列表中指定了 IdeInstComp 时，脚本可以使用在 IDE 中安装的所有组件。
// 但对于没有在 PSDecl 目录下的声明文件中列出的组件，即使 uses 了 IdeInstComp，
// 也只能访问其 published 的属性。

// 其它没有特别声明的单元如 Windows, Classes，不需要 uses 即可使用其声明的内容，
// 不过如果 uses 他们，在 IDE 代码编辑器中编辑脚本时，可以使用 IDE 的代码自动完成。
// 不将 IdeInstComp 直接导入，是因为当 IDE 安装了很多包时，导入的速度可能较慢

{ Example:

program Test;

uses
  Windows, SysUtils, IdeInstComp; // uses IdeInstComp is needed.

var
  DB: TDataBase;    // TDataBase is not imported by script engine expressly.
  Timer: TCnTimer;  // TCnTimer is a 3rd component (in CnPack) installed in IDE.

begin
  DB := TDataBase.Create(nil);
  try
    DB.AliasName := 'Test';  // You can access published properties only!!!
  finally
    DB.Free;
  end;

  Timer := TCnTimer.Create(nil);
  try
    Timer.Enabled := True;
  finally
    Timer.Free;
  end;
end.

}

interface

implementation

end.
