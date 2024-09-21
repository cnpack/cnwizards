{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnTestAIPluginWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestAIPluginWizard
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：Windows 7 + Delphi 5
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.09.21 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  {$IFDEF OTA_HAS_AISERVICE} ToolsAPI.AI, {$ENDIF}
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// CnTestAIPluginWizard 菜单专家
//==============================================================================

{ TCnTestAIPluginWizard }

  TCnTestAIPluginWizard = class(TCnMenuWizard)
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
// CnTestAIPluginWizard 菜单专家
//==============================================================================

{ TCnTestAIPluginWizard }

procedure TCnTestAIPluginWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestAIPluginWizard.Execute;
{$IFDEF OTA_HAS_AISERVICE}
var
  I: Integer;
  SL: TStringList;
{$ENDIF}
begin
{$IFDEF OTA_HAS_AISERVICE}
  ShowMessage('AIEngineService PluginCount: ' + IntToStr(AIEngineService.PluginCount));
  SL := TStringList.Create;
  try
    for I := 0 to AIEngineService.PluginCount - 1 do
      SL.Add(AIEngineService.GetPluginByIndex(I).Name);

    ShowMessage(SL.Text);
  finally
    SL.Free;
  end;
{$ENDIF}
end;

function TCnTestAIPluginWizard.GetCaption: string;
begin
  Result := 'Test AIPlugin';
end;

function TCnTestAIPluginWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestAIPluginWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestAIPluginWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestAIPluginWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestAIPluginWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test AIPlugin Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := '';
end;

procedure TCnTestAIPluginWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestAIPluginWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestAIPluginWizard); // 注册此测试专家

end.
