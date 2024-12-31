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

unit CnVclToFmxIntf;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：VCL 至 FMX 转换功能的对外接口
* 单元作者：CnPack开发组
* 备    注：该单元声明 VCL 至 FMX 转换功能的对外接口
* 开发平台：Win7 + Delphi 5.0
* 兼容测试：各种平台
* 本 地 化：不需要
* 修改记录：2022.05.11 V1.0
*               创建单元。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Windows;

type
  ICnVclToFmxIntf = interface
    ['{E4ED753F-A196-4815-B366-BD44213EDEE8}']
    function OpenAndConvertFile(InDfmFile: PWideChar): Boolean;
    {* 传入 DFM 窗体文件名供转换，返回转换是否成功}
    function SaveNewFile(InNewFile: PWideChar): Boolean;
    {* 转换成功后调用此方法保存新文件}
  end;

  TCnGetVclToFmxConverter = function: ICnVclToFmxIntf; stdcall;
  {* DLL 中输出的函数类型}

implementation

end.
