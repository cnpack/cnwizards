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
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestToolBarImageFix;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：编辑器工具栏测试修复IDE图标显示不完整的问题
* 单元作者：CnPack 开发组
* 备    注：该单元是编辑器外部工具栏的附属测试单元，BDS或以上版本中执行
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

{ TCnTestToolBarImageFix }

  TCnTestToolBarImageFix = class(TCnMenuWizard)
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

{ TCnTestIdeTookBarFix }

procedure TCnTestToolBarImageFix.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : 在此显示配置窗口 }
end;

destructor TCnTestToolBarImageFix.Destroy;
begin
  inherited;
end;

procedure TCnTestToolBarImageFix.Execute;
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
  { TODO -oAnyone : 该专家的主执行过程 }
end;

function TCnTestToolBarImageFix.GetCaption: string;
begin
  Result := 'Fix IDE Toolbar Image';
  { TODO -oAnyone : 返回专家菜单的标题，字符串请进行本地化处理 }
end;

function TCnTestToolBarImageFix.GetDefShortCut: TShortCut;
begin
  Result := 0;
  { TODO -oAnyone : 返回默认的快捷键 }
end;

function TCnTestToolBarImageFix.GetHasConfig: Boolean;
begin
  Result := False;
  { TODO -oAnyone : 返回专家是否有配置窗口 }
end;

function TCnTestToolBarImageFix.GetHint: string;
begin
  Result := 'Register an Editor ToolBar Type';
  { TODO -oAnyone : 返回专家菜单提示信息，字符串请进行本地化处理 }
end;

function TCnTestToolBarImageFix.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : 返回专家菜单状态，可根据指定条件来设定 }
end;

class procedure TCnTestToolBarImageFix.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'TestToolBarImageFix';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Fix IDE Toolbar Image';
  { TODO -oAnyone : 返回专家的名称、作者、邮箱及备注，字符串请进行本地化处理 }
end;

procedure TCnTestToolBarImageFix.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此装载专家内部用到的参数，专家创建时自动被调用 }
end;

procedure TCnTestToolBarImageFix.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此保存专家内部用到的参数，专家释放时自动被调用 }
end;

initialization
  RegisterCnWizard(TCnTestToolBarImageFix); // 注册专家

end.
