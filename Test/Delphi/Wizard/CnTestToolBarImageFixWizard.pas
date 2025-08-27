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

unit CnTestToolBarImageFixWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：编辑器工具栏测试修复 IDE 图标显示不完整的问题
* 单元作者：CnPack 开发组
* 备    注：该单元是编辑器外部工具栏的附属测试单元，BDS 或以上版本中执行
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2014.09.22 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, StdCtrls, ComCtrls, TypInfo, CnWizIdeUtils, CnWizManager,
  CnWizClasses, CnWizUtils, CnWizConsts, CnEditControlWrapper;

type

//==============================================================================
// 编辑器工具栏修复图标显示问题的菜单专家
//==============================================================================

{ TCnTestToolBarImageFixWizard }

  TCnTestToolBarImageFixWizard = class(TCnMenuWizard)
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

    destructor Destroy; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// 编辑器工具栏修复图标显示问题的菜单专家
//==============================================================================

{ TCnTestToolBarImageFixWizard }

procedure TCnTestToolBarImageFixWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : 在此显示配置窗口 }
end;

destructor TCnTestToolBarImageFixWizard.Destroy;
begin
  inherited;
end;

procedure TCnTestToolBarImageFixWizard.Execute;
var
  BrowserToolbar: TToolBar;
  ToolbarParent: TWinControl;
  P: TPoint;
  Wizard: TCnBaseWizard;
begin
  BrowserToolbar := TToolBar(GetIdeMainForm.FindComponent('BrowserToolBar'));
  if BrowserToolbar <> nil then
  begin
    CnDebugger.LogFmt('BrowserToolbar Top %d Left %d Width %d Height %d',
      [BrowserToolbar.Top, BrowserToolbar.Left, BrowserToolbar.Width, BrowserToolbar.Height]);

    ToolbarParent := BrowserToolbar.Parent;
    if ToolbarParent <> nil then
    begin
    CnDebugger.LogFmt('ToolbarParent Top %d Left %d Width %d Height %d',
      [ToolbarParent.Top, ToolbarParent.Left, ToolbarParent.Width, ToolbarParent.Height]);

      P.X := 5;
      P.Y := BrowserToolbar.Height div 2;
      P := BrowserToolbar.ClientToParent(P);
      CnDebugger.LogPoint(P, 'Click in Parent.');

      Wizard := CnWizardMgr.WizardByClassName('TCnPaletteEnhanceWizard');
      if Wizard <> nil then
      try
        SetPropValue(Wizard, 'TempDisableLock', True);
      except
        CnDebugger.LogMsg('Error set TempDisableLock True');
      end;
      SendMessage(ToolbarParent.Handle, WM_LBUTTONDOWN, 0, MakeLParam(P.X, P.Y));
      SendMessage(ToolbarParent.Handle, WM_MOUSEMOVE, 0, MakeLParam(P.X + 1, P.Y));
      SendMessage(ToolbarParent.Handle, WM_MOUSEMOVE, 0, MakeLParam(P.X, P.Y));
      SendMessage(ToolbarParent.Handle, WM_LBUTTONUP, 0, MakeLParam(P.X, P.Y));
      if Wizard <> nil then
      try
        SetPropValue(Wizard, 'TempDisableLock', False);
      except
        CnDebugger.LogMsg('Error set TempDisableLock False');
      end;
    end;
  end;
end;

function TCnTestToolBarImageFixWizard.GetCaption: string;
begin
  Result := 'Fix IDE Toolbar Image';
end;

function TCnTestToolBarImageFixWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestToolBarImageFixWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestToolBarImageFixWizard.GetHint: string;
begin
  Result := 'Register an Editor ToolBar Type';
end;

function TCnTestToolBarImageFixWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestToolBarImageFixWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'TestToolBarImageFix';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Fix IDE Toolbar Image';
end;

procedure TCnTestToolBarImageFixWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestToolBarImageFixWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestToolBarImageFixWizard); // 注册专家

end.
