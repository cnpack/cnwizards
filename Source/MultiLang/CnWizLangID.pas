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

unit CnWizLangID;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：多语 ID 公共单元
* 单元作者：CnPack开发组
* 备    注：该单元用来获取 CnWizards 的当前语言 ID，
            此文件无需并且不能加入专家包的工程文件中，只供其他工具使用。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2005.01.14 V1.0
*               LiuXiao: 创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Windows, Registry, CnCommon, CnConsts;

function GetWizardsLanguageID: DWORD;
{* 从注册表中读取当前 CnWizards 的语言 ID }

procedure SetWizardsLanguageID(LangID: DWORD);
{* 设置注册表中的当前 CnWizards 的语言 ID }

implementation

const
  csWizardRegPath = 'CnWizards';
  csOptionSection = 'Option';
  csLangID = 'CurrentLangID';

// 从注册表中读取当前 CnWizards 的语言 ID
function GetWizardsLanguageID: DWORD;
begin
  with TRegistryIniFile.Create(MakePath(MakePath(SCnPackRegPath) + csWizardRegPath)) do
  begin
    Result := ReadInteger(csOptionSection, csLangID, GetSystemDefaultLCID);
    Free;
  end;
end;

// 设置注册表中的当前 CnWizards 的语言 ID
procedure SetWizardsLanguageID(LangID: DWORD);
begin
  with TRegistryIniFile.Create(MakePath(MakePath(SCnPackRegPath) + csWizardRegPath)) do
  begin
    WriteInteger(csOptionSection, csLangID, LangID);
    Free;
  end;
end; 

end.
