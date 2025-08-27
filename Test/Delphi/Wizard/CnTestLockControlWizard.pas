{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestLockControlWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����� LockControl �˵�����»��ƵĲ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���ҽ� LockControl �˵����Բ鿴��ʱ������״̬��
            ��Ҫ�� 2005 �Լ����ϵİ汾�в���ͨ����
* ����ƽ̨��WinXP + Delphi 5
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi All
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2016.01.31 V1.0
*               ������Ԫ
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
// ���� LockControl MenuItem �Ĳ˵�ר��
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
// ���� LockControl MenuItem �Ĳ˵�ר��
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
  RegisterCnWizard(TCnTestLockControlWizard); // ע��˲���ר��

end.
