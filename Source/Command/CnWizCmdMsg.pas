{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnWizCmdMsg;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家工具包
* 单元名称：CnWizards 命令机制的消息定义
* 单元作者：CnPack开发组 CnPack 开发组 (master@cnpack.org)
* 备    注：该单元定义了 CnWizards 命令机制的消息格式与常量定义
*           外部程序使用命令消息格式时需要使用到本单元
* 开发平台：WinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2017.11.14 V1.1
*               适配 Unicode 编译器
*           2008.04.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows;

const
  CN_WIZ_MAX_ID = 31;
  {* 接收端 ID 的最大长度}

  SCN_WIZ_CMD_WINDOW_NAME = 'TCnWizCmdWindow';
  {* 内部注册的窗口类名，供接收消息用}

  //========= 以下是全局命令 ID 定义，一般用于框架，可在开发过程中扩展 =========

  CN_WIZ_CMD_BEGIN           = $CCB;
  {* 命令字起始号，一般保留而不使用}

  CN_WIZ_CMD_TEST            = $CCB + $1;
  {* 测试命令号，一般不做正式用途}

  CN_WIZ_CMD_ECHO            = $CCB + $2;
  {* 呼叫的命令号，用于通讯测试}

  CN_WIZ_CMD_ECHO_REPLY      = $CCB + $3;
  {* 回应的命令号，收到呼叫时应返回}

  CN_WIZ_CMD_SAVE_SETTINGS   = $CCB + $4;
  {* 保存设置命令号，收到时专家应保存设置}

  CN_WIZ_CMD_RELOAD_SETTINGS = $CCB + $5;
  {* 重载设置命令号，收到时专家应重新载入设置}

  CN_WIZ_CMD_DEBUG_LOG       = $CCB + $6;
  {* 调试输出命令号，收到时应调用 CnDebugger 发送一调试字符串}

  //========= 以下是自定义命令 ID，一般用于具体专家，可在开发过程中扩展 ========

  CN_WIZ_CMD_USER_BEGIN      = $CCB + $100;
  {* 自定义命令字起始号，一般保留而不使用}

  CN_WIZ_CMD_USER_TEST       = $CCB + $101;
  {* 自定义测试命令号，一般不做正式用途}

  CN_WIZ_CMD_RELOAD_SCRIPT   = $CCB + $102;
  {* 通知脚本专家重新载入脚本的命令号}

  //================= 以上是命令 ID 定义，可在开发过程中扩展 ===================

type
  PCnWizMessage = ^TCnWizMessage;
  {* CnWizards 命令消息结构指针}
  
  TCnWizMessage = packed record
  {* CnWizards 命令消息结构}
    Command:  Cardinal;
    {* 命令 ID}
    IDESets:  Cardinal;
    {* 接收端的 IDE 版本 Set 集合，set of TCnCompiler，空为不限制}
    SourceID: array[0..CN_WIZ_MAX_ID] of AnsiChar;
    {* 发送端的 ID，字符串形式。专家实例以自己的专家 ID 注册。空为匿名。}
    DestID:   array[0..CN_WIZ_MAX_ID] of AnsiChar;
    {* 接收端的 ID，字符串形式。专家实例以自己的专家 ID 注册。空为所有目标。}
    DataLength: Cardinal;
    {* 命令的其他数据长度，字节为单位，不包括 DataLength 以及前面的内容}
    Data:     array[0..SizeOf(Cardinal) - 1] of Byte;
    {* 命令的其他数据，可扩展}
  end;

implementation

end.
