{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2015 CnPack 开发组                       }
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

unit CnTestEditorMenuWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试编辑器右键菜单项的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：WinXP + Delphi 7
* 兼容测试：PWin9X/2000/XP + Delphi 7 以上
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 单元标识：$Id:  CnTestEditorMenuWizard 1146 2012-10-24 06:25:41Z liuxiaoshanzhashu@gmail.com $
* 修改记录：2015.08.17 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager;

type

//==============================================================================
// 测试编辑器右键菜单项的菜单专家
//==============================================================================

{ TCnTestEditorMenuWizard }

  TCnTestEditorMenuWizard = class(TCnMenuWizard)
  private
    FExecutor: TCnContextMenuExecutor;
    procedure Executor2Execute(Sender: TObject);
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;

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

  TCnTestEditorMenu1 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

  TCnTestEditorMenu2 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

  TCnTestEditorMenu3 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// 测试编辑器右键菜单项的菜单专家
//==============================================================================

{ TCnTestEditorMenuWizard }

procedure TCnTestEditorMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditorMenuWizard.Create;
begin
  inherited;
  RegisterBaseEditorMenuExecutor(TCnTestEditorMenu1.Create(Self));
  RegisterBaseEditorMenuExecutor(TCnTestEditorMenu2.Create(Self));
  RegisterBaseEditorMenuExecutor(TCnTestEditorMenu3.Create(Self));
end;

procedure TCnTestEditorMenuWizard.Execute;
begin
  ShowMessage('3 Menu Items Registered using TCnBaseMenuExecutor.' + #13#10
    + '1 Hidden, 1 Disabled and 1 Enabled. Please Check Editor Context Menu.');
end;

procedure TCnTestEditorMenuWizard.Executor2Execute(Sender: TObject);
begin
  ShowMessage('Executor 2 Run Here.');
end;

function TCnTestEditorMenuWizard.GetCaption: string;
begin
  Result := 'Test Editor Menu';
end;

function TCnTestEditorMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditorMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditorMenuWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditorMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Editor Context Menu';
end;

procedure TCnTestEditorMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

{ TCnTestEditorMenu1 }

function TCnTestEditorMenu1.Execute: Boolean;
begin
  ShowMessage('Should NOT Run Here.');
  Result := True;
end;

function TCnTestEditorMenu1.GetActive: Boolean;
begin
  Result := False;
end;

function TCnTestEditorMenu1.GetCaption: string;
begin
  Result := 'Hidden Caption';
end;

function TCnTestEditorMenu1.GetEnabled: Boolean;
begin
  Result := True;
end;

{ TCnTestEditorMenu2 }

function TCnTestEditorMenu2.Execute: Boolean;
begin
  ShowMessage('Should NOT Run Here.');
  Result := True;
end;

function TCnTestEditorMenu2.GetActive: Boolean;
begin
  Result := True;
end;

function TCnTestEditorMenu2.GetCaption: string;
begin
  Result := 'Disabled Caption'
end;

function TCnTestEditorMenu2.GetEnabled: Boolean;
begin
  Result := False;
end;

{ TCnTestEditorMenu3 }

function TCnTestEditorMenu3.Execute: Boolean;
begin
  ShowMessage('Should Run Here.');
  Result := True;
end;

function TCnTestEditorMenu3.GetActive: Boolean;
begin
  Result := True;
end;

function TCnTestEditorMenu3.GetCaption: string;
begin
  Result := 'Enabled Caption';
end;

function TCnTestEditorMenu3.GetEnabled: Boolean;
begin
  Result := True;
end;

initialization
  RegisterCnWizard(TCnTestEditorMenuWizard); // 注册此测试专家

end.
