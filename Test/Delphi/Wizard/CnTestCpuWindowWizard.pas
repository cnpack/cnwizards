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

unit CnTestCpuWindowWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：简单的专家演示单元
* 单元作者：CnPack 开发组
* 备    注：该单元用来测试 CPU 调试窗口
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2021.06.13 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ToolsAPI, IniFiles, Grids, TypInfo, Clipbrd,
  CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnMenuHook;

type

//==============================================================================
// CPU 窗口测试子菜单专家
//==============================================================================

{ TCnTestCpuWindowWizard }

  TCnTestCpuWindowWizard = class(TCnSubMenuWizard)
  private
    FIdDumpView: Integer;
    FDumpMenuHook: TCnMenuHook;
    FDumpMenuDef: TCnMenuItemDef;
    procedure TestDumpView;
    procedure OnCopyMemory(Sender: TObject);
  protected
    function FindCpuForm: TCustomForm;
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
  SCnDumpViewCommand = 'CnDumpViewCommand';

  SCnDumpViewCaption = 'Show DumpView Memory Content';

  SCnDumpPopupMenu = 'DumpPopupMenu';
  SCnDisassemblyViewClass = 'TDisassemblyView';

  SCnDisassemblerViewClass = 'TDisassemblerView';
  SCnDumpViewClass = 'TDumpView';
  SCnDumpViewName = 'DumpView';
  SCnStackViewName = 'StackView';

//==============================================================================
// CPU 窗口测试子菜单专家
//==============================================================================

{ TCnTestCpuWindowWizard }

procedure TCnTestCpuWindowWizard.AcquireSubActions;
begin
  FIdDumpView := RegisterASubAction(SCnDumpViewCommand, SCnDumpViewCaption);
end;

procedure TCnTestCpuWindowWizard.Config;
begin

end;

procedure TCnTestCpuWindowWizard.TestDumpView;
var
  CpuForm: TCustomForm;
  PopupMenu: TPopupMenu;
begin
  CpuForm := FindCpuForm;
  if CpuForm <> nil then
  begin
    PopupMenu := TPopupMenu(CpuForm.FindComponent(SCnDumpPopupMenu));
    Assert(Assigned(PopupMenu));

    if not FDumpMenuHook.IsHooked(PopupMenu) then
    begin
      FDumpMenuHook.HookMenu(PopupMenu);
      ShowMessage('PopupMenu ' + PopupMenu.Name + ' Hooked.');
    end;
  end;
end;

function TCnTestCpuWindowWizard.GetCaption: string;
begin
  Result := 'Test Cpu Window';
end;

function TCnTestCpuWindowWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestCpuWindowWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestCpuWindowWizard.GetHint: string;
begin
  Result := 'Test Cpu Window';
end;

function TCnTestCpuWindowWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestCpuWindowWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Cpu Window Menu Wizard';
  Author := 'CnPack Team';
  Email := 'liuxiao@cnpack.org';
  Comment := 'Test Cpu Window Menu Wizard';
end;

procedure TCnTestCpuWindowWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestCpuWindowWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestCpuWindowWizard.SubActionExecute(Index: Integer);
begin
  if Index = FIdDumpView then
    TestDumpView;
end;

function TCnTestCpuWindowWizard.FindCpuForm: TCustomForm;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if Screen.CustomForms[I].ClassNameIs(SCnDisassemblyViewClass) then
    begin
      Result := Screen.CustomForms[I];
      Exit;
    end;
  end;
end;

constructor TCnTestCpuWindowWizard.Create;
begin
  inherited;
  FDumpMenuHook := TCnMenuHook.Create(nil);
  FDumpMenuDef := TCnMenuItemDef.Create('CnCopyMemoryContent', 'Copy',
    OnCopyMemory, ipLast);

  FDumpMenuHook.AddMenuItemDef(FDumpMenuDef);
end;

destructor TCnTestCpuWindowWizard.Destroy;
begin
  FDumpMenuHook.Free;
  inherited;
end;

procedure TCnTestCpuWindowWizard.OnCopyMemory(Sender: TObject);
var
  I: Integer;
  CpuForm: TCustomForm;
  DumpView: TCustomGrid;
  S: string;
begin
  ShowMessage('Copy Memory on ' + Sender.ClassName);

  CpuForm := FindCpuForm;
  if CpuForm <> nil then
  begin
    DumpView := nil;
    for I := 0 to CpuForm.ComponentCount - 1 do
    begin
      if CpuForm.Components[I].ClassNameIs(SCnDumpViewClass)
        and (CpuForm.Components[I].Name = SCnDumpViewName)
        and (CpuForm.Components[I] is TCustomGrid) then
      begin
        DumpView := TCustomGrid(CpuForm.Components[I]);
        Break;
      end;
    end;
    Assert(Assigned(DumpView));

    // Copy Selected Memory Content
    S := GetStrProp(DumpView, 'SelectedData');
    if S <> '' then
      Clipboard.AsText := S;
  end;
end;

initialization
{$IFNDEF BDS}
  RegisterCnWizard(TCnTestCpuWindowWizard); // 注册专家
{$ENDIF}

end.
