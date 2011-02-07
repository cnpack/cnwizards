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

program CnConfigIO;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家包设置导入导出工具
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：支持命令行参数的不显示主窗口的导入导出方式
*           命令行参数中第一个不以 / 或 - 开头的，是文件名参数
*           -i 或 /i 导入
*           -o 或 /o 导出
*           -r 或 /r 恢复默认设置
*           -n 或 /n 或 -NoMsg 或 /NoMsg 不弹出成功的提示信息
*           -? 或 /? ; -h 或 /h 命令行参数帮助
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnConfigIO.dpr,v 1.11 2009/01/02 08:36:30 liuxiao Exp $
* 修改记录：2008.06.10 V1.0
*               增加命令行处理方式
*           2003.05.20 V1.0
*               创建单元
================================================================================
|</PRE>}

uses
  Forms,
  SysUtils,
  CnCommon,
  ConfigIO in 'ConfigIO.pas' {FrmConfigIO};

{$R *.RES}

begin
  Application.Initialize;
  if FindCmdLineSwitch('i', ['-', '/'], True) or
     FindCmdLineSwitch('o', ['-', '/'], True) or
     FindCmdLineSwitch('r', ['-', '/'], True) then
  begin
    Application.ShowMainForm := False;
  end;
  Application.CreateForm(TFrmConfigIO, FrmConfigIO);
  Application.Run;
end.
