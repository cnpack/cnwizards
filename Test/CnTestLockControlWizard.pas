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

unit CnTestLockControlWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试 LockControl 菜单项更新机制的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：挂接 LockControl 菜单项以查看何时更新了状态。
            需要在 2005 以及以上的版本中测试通过。
* 开发平台：WinXP + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi All
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2016.01.31 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnEventHook,
  CnWizMethodHook, ActnList, ActnMenus, ActnMan;

type

//==============================================================================
// 测试 LockControl MenuItem 的菜单专家
//==============================================================================

{ TCnTestLockControlWizard }

  TCnTestLockControlWizard = class(TCnMenuWizard)
  private

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
    procedure Execute; override;
  end;

implementation

uses
  CnDebug;

const
  SIDELockControlsMenuName = 'EditLockControlsItem';
  SIDELockControlsActionName = 'EditLockControlsCommand';

type
  TMenuItemSetCheckedProc = procedure (Self: TObject; Value: Boolean);

  TMenuItemHack = class(TMenuItem);

  TCustomActionMenuBarHack = class(TCustomActionMenuBar);

var
  FHooked: Boolean = False;
  FMenuItem: TMenuItem = nil;
  FAction: TAction = nil;
  FEventHook: TCnEventHook = nil;
  FMenuItemMethodHook: TCnMethodHook = nil;
  FBasicActionUpdateHook: TCnMethodHook = nil;
  FActionMenuBarDoPopupHook: TCnMethodHook = nil;

procedure MyMenuItemSetChecked(Self: TObject; Value: Boolean);
begin
  CnDebugger.LogMsg('MyMenuItemSetChecked: ' + TMenuItem(Self).Caption);
  if Self = FMenuItem then
  begin
    CnDebugger.LogCurrentStack('MyMenuItemSetChecked');

// Get the Result for XE8:
//Dump Call Stack: MyMenuItemSetChecked
//[09F59B3A]{CnWizards_DXE8.dll} CnTestLockControlWizard.MyMenuItemSetChecked$qqrp14System.TObjecto (Line 101, "CnTestLockControlWizard.pas" + 4) + $A
//[507ABFD6]{vcl220.bpl  } Vcl.Menus.TMenuActionLink.SetChecked (Line 867, "Vcl.Menus.pas" + 1) + $10
//[004249E1]{bds.exe     } AppMain.TAppBuilder.EditCommandUpdate (Line 4693, "AppMain.pas" + 24) + $10
//[5017203F]{rtl220.bpl  } System.Classes.TBasicAction.Update (Line 16388, "System.Classes.pas" + 3) + $7
//[0042AD9E]{bds.exe     } AppMain.TAppBuilder.MenuBarPopup (Line 7055, "AppMain.pas" + 12) + $21
//[2185563B]{vclactnband220.bpl} Vcl.ActnMenus.TCustomActionMenuBar.DoPopup (Line 1238, "Vcl.ActnMenus.pas" + 2) + $C

  end;

  FMenuItemMethodHook.UnhookMethod;
  TMenuItemHack(Self).SetChecked(Value);
  FMenuItemMethodHook.HookMethod;
end;

procedure MyBasicActionUpdate(Self: TObject);
begin
  if Self is TCustomAction then
    CnDebugger.LogMsg('MyBasicActionUpdate: ' + TCustomAction(Self).Name);
  // Action is the Action named SIDELockControlsActionName

  FBasicActionUpdateHook.UnhookMethod;
  TBasicAction(Self).Update;
  FBasicActionUpdateHook.HookMethod;
end;

procedure MyCustomActionMenuBarDoPopup(Self: TObject; Item: TCustomActionControl);
begin
  CnDebugger.LogMsg('MyCustomActionMenuBarDoPopup Item: ' + Item.Caption); // Name is Empty, Caption is '&Edit'
  if Item.Owner <> nil then
  begin
    CnDebugger.LogMsg('MyCustomActionMenuBarDoPopup Item Owner: ' + Item.Owner.Name); // MenuBar
    if Item.Owner.Owner <> nil then
      CnDebugger.LogMsg('MyCustomActionMenuBarDoPopup Item Owner^2: ' + Item.Owner.Owner.Name); // AppBuilder
  end;

  FActionMenuBarDoPopupHook.UnhookMethod;
  TCustomActionMenuBarHack(Self).DoPopup(Item);
  FActionMenuBarDoPopupHook.HookMethod;
end;

//==============================================================================
// 测试 LockControl MenuItem 的菜单专家
//==============================================================================

{ TCnTestLockControlWizard }

procedure TCnTestLockControlWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestLockControlWizard.Create;
begin
  inherited;

end;

destructor TCnTestLockControlWizard.Destroy;
begin
  FreeAndNil(FMenuItemMethodHook);
  FreeAndNil(FBasicActionUpdateHook);
  FreeAndNil(FActionMenuBarDoPopupHook);
  inherited;
end;

procedure TCnTestLockControlWizard.Execute;
begin
  if not FHooked then
  begin
    FMenuItem := TMenuItem(Application.MainForm.FindComponent(SIDELockControlsMenuName));
    FAction := TAction(FindIDEAction(SIDELockControlsActionName));

    FMenuItemMethodHook := TCnMethodHook.Create(GetBplMethodAddress(@TMenuItemHack.SetChecked), @MyMenuItemSetChecked);

    // FBasicActionUpdateHook := TCnMethodHook.Create(GetBplMethodAddress(@TBasicAction.Update), @MyBasicActionUpdate);

    FActionMenuBarDoPopupHook := TCnMethodHook.Create(GetBplMethodAddress(@TCustomActionMenuBarHack.DoPopup), @MyCustomActionMenuBarDoPopup);
    FHooked := True;

    InfoDlg('TMenuItem.SetChecked Hooked: ' + FMenuItem.Caption);
  end
  else
    InfoDlg('Already Hooked. Do Nothing.');
end;

function TCnTestLockControlWizard.GetCaption: string;
begin
  Result := 'Test LockControl MenuItem';
end;

function TCnTestLockControlWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestLockControlWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestLockControlWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestLockControlWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestLockControlWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test LockControl MenuItem Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for LockControl MenuItem under All Delphi';
end;

procedure TCnTestLockControlWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestLockControlWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestLockControlWizard); // 注册此测试专家

end.
