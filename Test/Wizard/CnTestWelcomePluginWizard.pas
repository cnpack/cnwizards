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

unit CnTestWelcomePluginWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：简单的专家演示单元
* 单元作者：CnPack 开发组
* 备    注：该单元用来测试 ToolsAPI.WelcomePage，仅 D120A 或以上有效
* 开发平台：PWin11 + Delphi 12
* 兼容测试：PWin11 + Delphi 12
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2025.05.02 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ToolsAPI, IniFiles, Grids, TypInfo, Clipbrd, ToolsAPI.WelcomePage,
  CnCommon, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// 欢迎页测试子菜单专家
//==============================================================================

{ TCnTestWelcomePluginWizard }

  TCnTestWelcomePluginWizard = class(TCnSubMenuWizard)
  private
    FIdDumpWelcomes: Integer;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;

    procedure AcquireSubActions; override;
    procedure SubActionExecute(Index: Integer); override;
  end;

implementation

uses
  CnDebug;

const
  SCnDumpWelcomeCommand = 'CnDumpWelcomeCommand';

  SCnDumpWelcomeCaption = 'Show Welcome Plugins';

//==============================================================================
// 欢迎页测试子菜单专家
//==============================================================================

{ TCnTestWelcomePluginWizard }

procedure TCnTestWelcomePluginWizard.AcquireSubActions;
begin
  FIdDumpWelcomes := RegisterASubAction(SCnDumpWelcomeCommand, SCnDumpWelcomeCaption);
end;

procedure TCnTestWelcomePluginWizard.Config;
begin

end;

function TCnTestWelcomePluginWizard.GetCaption: string;
begin
  Result := 'Test Welcome Page';
end;

function TCnTestWelcomePluginWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestWelcomePluginWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestWelcomePluginWizard.GetHint: string;
begin
  Result := 'Test Welcome Page';
end;

function TCnTestWelcomePluginWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestWelcomePluginWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Welcome Page Menu Wizard';
  Author := 'CnPack Team';
  Email := 'liuxiao@cnpack.org';
  Comment := 'Test Welcome Page Menu Wizard';
end;

procedure TCnTestWelcomePluginWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestWelcomePluginWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestWelcomePluginWizard.SubActionExecute(Index: Integer);
var
  I: Integer;
begin
  if Index = FIdDumpWelcomes then
  begin
    ShowMessage(IntToStr(WelcomePagePluginService.PluginCount));
    for I := 0 to WelcomePagePluginService.PluginCount - 1 do
    begin
      ShowMessage(WelcomePagePluginService.PluginID[I]);
    end;
  end;
end;

constructor TCnTestWelcomePluginWizard.Create;
begin
  inherited;

end;

destructor TCnTestWelcomePluginWizard.Destroy;
begin

  inherited;
end;

initialization
  RegisterCnWizard(TCnTestWelcomePluginWizard); // 注册专家

end.
