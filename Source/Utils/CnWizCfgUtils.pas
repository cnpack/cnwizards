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

unit CnWizCfgUtils;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：配置公共单元
* 单元作者：CnPack开发组
* 备    注：该单元用来获取 CnWizards 的相关配置，
            此文件无需并且不能加入专家包的工程文件中，只供其他工具使用。
* 开发平台：PWinXP + Delphi 7.1
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnWizLangID.pas 138 2009-07-14 03:23:28Z zhoujingyu $
* 修改记录：2009.09.09 V1.0
*               ZhouJingYu: 创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Windows, Registry, CnCommon, CnConsts;

function GetCWUseCustomUserDir: Boolean;
function GetCWUserPath: string;
{* 从注册表中读取当前 CnWizards 用户数据路径 }

implementation

const
  SCnWizUserPath = 'User';
  SCnOptionSection = 'Option';
  csWizardRegPath = 'CnWizards';
  csUseCustomUserDir = 'UseCustomUserDir';
  csCustomUserDir = 'CustomUserDir';

function GetCWUseCustomUserDir: Boolean;
begin
  with TRegistryIniFile.Create(MakePath(MakePath(SCnPackRegPath) + csWizardRegPath)) do
  try
    Result := ReadBool(SCnOptionSection, csUseCustomUserDir, CheckWinVista);
  finally
    Free;
  end;
end;

// 从注册表中读取当前 CnWizards 用户数据路径
function GetCWUserPath: string;
begin
  Result := MakePath(ModulePath + SCnWizUserPath);

  with TRegistryIniFile.Create(MakePath(MakePath(SCnPackRegPath) + csWizardRegPath)) do
  try
    if ReadBool(SCnOptionSection, csUseCustomUserDir, CheckWinVista) then
      Result := MakePath(ReadString(SCnOptionSection, csCustomUserDir, Result));
  finally
    Free;
  end;
end;

end.
