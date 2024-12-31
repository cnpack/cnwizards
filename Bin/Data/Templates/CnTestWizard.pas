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

unit CnTest<#ClassName>Wizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTest<#ClassName>Wizard
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：Windows 7 + Delphi 5
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：<#CreateTime> V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// CnTest<#ClassName>Wizard 菜单专家
//==============================================================================

{ TCnTest<#ClassName>Wizard }

  TCnTest<#ClassName>Wizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

//==============================================================================
// CnTest<#ClassName>Wizard 菜单专家
//==============================================================================

{ TCnTest<#ClassName>Wizard }

procedure TCnTest<#ClassName>Wizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTest<#ClassName>Wizard.Execute;
begin

end;

function TCnTest<#ClassName>Wizard.GetCaption: string;
begin
  Result := '<#WizardCaption>';
end;

function TCnTest<#ClassName>Wizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTest<#ClassName>Wizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTest<#ClassName>Wizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTest<#ClassName>Wizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTest<#ClassName>Wizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := '<#WizardCaption> Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := '<#WizardComment>';
end;

procedure TCnTest<#ClassName>Wizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTest<#ClassName>Wizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTest<#ClassName>Wizard); // 注册此测试专家

end.
