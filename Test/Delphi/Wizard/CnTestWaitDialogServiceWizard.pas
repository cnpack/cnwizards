{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnTestWaitDialogServiceWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：测试 10.4.2 下新增的 WaitDialogService 的专家
* 单元作者：CnPack 开发组
* 备    注：该单元只能在 10.4.2 或以上版本中编译。
* 开发平台：Win10 + Delphi 10.4.2
* 兼容测试：
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2021.03.15 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon,
  CnWizCompilerConst, CnWizMethodHook;

type

//==============================================================================
// 测试 10.4.2 下新增的 WaitDialogService 的专家
//==============================================================================

{ TCnTestWaitDialogServiceWizard }

  TCnTestWaitDialogServiceWizard = class(TCnSubMenuWizard)
  private
    FDesignIdeHandle: THandle;
    FHook: TCnMethodHook;
    FIdShowWaitDialogServiceState: Integer;
    FIdWaitDialogShow: Integer;
    FIdWaitDialogClose: Integer;
    FIdHookWaitDialogShow: Integer;
    FIdUnHookWaitDialogShow: Integer;
    procedure HookShow;
    procedure UnhookShow;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

implementation

uses
  CnDebug;

const
  SCnWaitDialogShow = '@Waitdialog@TIDEWaitDialog@Show$qqrx20System@UnicodeStringt1o';

type
  TCnWaitDialogShowProc = procedure (ASelfClass: Pointer; const Caption: string; const TitleMessage: string; LockDrawing: Boolean);

var
  OldWaitDialogShowProc: TCnWaitDialogShowProc = nil;

procedure MyWaitDialogShow(ASelfClass: Pointer; const Caption: string; const TitleMessage: string; LockDrawing: Boolean);
begin
  // 啥都不做
  CnDebugger.LogMsg('MyWaitDialogShow Called. Do Nothing.');
end;

//==============================================================================
// 测试 10.4.2 下新增的 WaitDialogService 的专家
//==============================================================================

{ TCnTestWaitDialogServiceWizard }

procedure TCnTestWaitDialogServiceWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestWaitDialogServiceWizard.Create;
begin
  inherited;

end;

destructor TCnTestWaitDialogServiceWizard.Destroy;
begin
  if FDesignIdeHandle <> 0 then
    FreeLibrary(FDesignIdeHandle);

  FHook.Free;
  inherited;
end;

procedure TCnTestWaitDialogServiceWizard.AcquireSubActions;
begin
  FIdShowWaitDialogServiceState := RegisterASubAction('CnShowWaitDialogServiceState',
    'Show Wait Dialog Service State', 0, 'Show Wait Dialog Service State',
    'CnShowWaitDialogServiceState');
  FIdWaitDialogShow := RegisterASubAction('CnWaitDialogShow',
    'Show Wait Dialog', 0, 'Show Wait Dialog',
    'CnWaitDialogShow');
  FIdWaitDialogClose := RegisterASubAction('CnWaitDialogClose',
    'Close Wait Dialog', 0, 'Close Wait Dialog',
    'CnWaitDialogClose');

  FIdHookWaitDialogShow := RegisterASubAction('CnHookWaitDialogShow',
    'Hook WaitDialogShow Function', 0, 'Hook WaitDialogShow Function',
    'CnHookWaitDialogShow');
  FIdUnhookWaitDialogShow := RegisterASubAction('CnUnhookWaitDialogClose',
    'UnhHook WaitDialogShow Function', 0, 'Unhook WaitDialogShow Function',
    'CnUnhookWaitDialogClose')
end;

function TCnTestWaitDialogServiceWizard.GetCaption: string;
begin
  Result := 'Test Wait Dialog Service';
end;

function TCnTestWaitDialogServiceWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestWaitDialogServiceWizard.GetHint: string;
begin
  Result := 'Test Wait Dialog Service';
end;

function TCnTestWaitDialogServiceWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestWaitDialogServiceWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Wait Dialog Service Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Wait Dialog Service Wizard';
end;

procedure TCnTestWaitDialogServiceWizard.HookShow;
begin
  if FHook = nil then
  begin
    FDesignIdeHandle := LoadLibrary(DesignIdeLibName);
    OldWaitDialogShowProc := GetBplMethodAddress(GetProcAddress(FDesignIdeHandle, SCnWaitDialogShow));

    FHook := TCnMethodHook.Create(@OldWaitDialogShowProc, @MyWaitDialogShow);
  end;
  FHook.HookMethod;
  ShowMessage('Hooked.');
end;

procedure TCnTestWaitDialogServiceWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestWaitDialogServiceWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestWaitDialogServiceWizard.SubActionExecute(Index: Integer);
var
  WD: IOTAIDEWaitDialogServices;
begin
  if not Active then Exit;
  if not Supports(BorlandIDEServices, IOTAIDEWaitDialogServices, WD) then
    Exit;

  if Index = FIdShowWaitDialogServiceState then
  begin
    CnDebugger.LogFmt('WaitDialogService: Visible %d, InputEnabled %d.',
      [Integer(WD.IsVisible), Integer(WD.IsInputEnabled)]);
    CnDebugger.LogInterface(WD);
    CnDebugger.EvaluateInterfaceInstance(WD);
  end
  else if Index = FIdWaitDialogShow then
    WD.Show('Test Caption', 'Test Message')
  else if Index = FIdWaitDialogClose then
    WD.CloseDialog
  else if Index = FIdHookWaitDialogShow then
    HookShow
  else if Index = FIdUnHookWaitDialogShow then
    UnHookShow;
end;

procedure TCnTestWaitDialogServiceWizard.SubActionUpdate(Index: Integer);
begin 

end;

procedure TCnTestWaitDialogServiceWizard.UnhookShow;
begin
  if FHook <> nil then
  begin
    FHook.UnhookMethod;
    ShowMessage('UnHooked.');
  end;
end;

initialization
  RegisterCnWizard(TCnTestWaitDialogServiceWizard); // 注册专家

end.
