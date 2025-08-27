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

unit CnTestBuildConfigWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnWizDebuggerNotifier 测试用例单元
* 单元作者：CnPack 开发组
* 备    注：该单元只支持 Delphi 2009 及后续版本
            只需将此单元加入专家包源码工程后重编译加载即可进行测试，
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2002.11.07 V1.0
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
// 测试 D2009 下 BuildConfiguration 相关接口的菜单专家
//==============================================================================

{ TCnTestBuildConfigWizard }

  TCnTestBuildConfigWizard = class(TCnMenuWizard)
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
// 测试 D2009 下 BuildConfiguration 相关接口的菜单专家
//==============================================================================

{ TCnTestBuildConfigWizard }

procedure TCnTestBuildConfigWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestBuildConfigWizard.Execute;
var
  BC: IOTAProjectOptionsConfigurations;
  I: Integer;
begin
  BC := CnOtaGetActiveProjectOptionsConfigurations();
  if BC <> nil then
  begin
    ShowMessage('Current Project''s Configuration Count: ' + IntToStr(BC.ConfigurationCount));
    for I := 0 to BC.ConfigurationCount - 1 do
    begin
      if BC.Configurations[I] = BC.ActiveConfiguration then
        ShowMessage(Format('Cofiguration %d: %s. Active.', [I, BC.Configurations[I].Name]))
      else
        ShowMessage(Format('Cofiguration %d: %s', [I, BC.Configurations[I].Name]));
    end;
  end;
end;

function TCnTestBuildConfigWizard.GetCaption: string;
begin
  Result := 'Test Build Configuration';
end;

function TCnTestBuildConfigWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestBuildConfigWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestBuildConfigWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestBuildConfigWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestBuildConfigWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Build Configuration Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Build Configuration under Delphi 2009';
end;

procedure TCnTestBuildConfigWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBuildConfigWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestBuildConfigWizard); // 注册此测试专家

end.
