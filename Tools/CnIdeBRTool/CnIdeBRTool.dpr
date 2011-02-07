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

program CnIdeBRTool;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家辅助备份/恢复工具
* 单元名称：CnWizards 辅助备份/恢复工具工程文件
* 单元作者：ccRun(老妖)
* 备    注：CnWizards 专家辅助备份/恢复工具工程文件
* 开发平台：PWinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnIdeBRTool.dpr,v 1.6 2009/01/02 08:36:30 liuxiao Exp $
* 修改记录：2006.08.23 V1.0
*               Passion 移植此单元
================================================================================
|</PRE>}

uses
  Forms,
  CnBHMain in 'CnBHMain.pas' {CnIdeBRMainForm},
  CnAppBuilderInfo in 'CnAppBuilderInfo.pas',
  CnCompressor in 'CnCompressor.pas',
  CnBHConst in 'CnBHConst.pas',
  CleanClass in 'CleanClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TCnIdeBRMainForm, CnIdeBRMainForm);
  Application.Run;
end.
