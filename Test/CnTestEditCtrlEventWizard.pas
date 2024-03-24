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

unit CnTestEditCtrlEventWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试编辑器控件事件挂接单元
* 单元作者：CnPack 开发组
* 备    注：可挂接成功，但事件处理函数不会被调用，目测 MouseMove 等被 override
* 开发平台：PWinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2015.07.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnEventHook, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// 测试挂接 EditControl 事件的菜单专家
//==============================================================================

{ TCnTestEditCtrlEventWizard }

  TCnTestEditCtrlEventWizard = class(TCnMenuWizard)
  private
    FHookMouseUp: TCnEventHook;
    FHookMouseDown: TCnEventHook;
    FHookMouseMove: TCnEventHook;
    
    procedure HookMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HookMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HookMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
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

//==============================================================================
// 测试挂接 EditControl 事件的菜单专家
//==============================================================================

{ TCnTestEditCtrlEventWizard }

procedure TCnTestEditCtrlEventWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditCtrlEventWizard.Create;
begin
  inherited;

end;

destructor TCnTestEditCtrlEventWizard.Destroy;
begin
  FHookMouseUp.Free;
  FHookMouseDown.Free;
  FHookMouseMove.Free;
  inherited;
end;

procedure TCnTestEditCtrlEventWizard.Execute;
var
  Edit: TControl;
begin
  Edit := CnOtaGetCurrentEditControl;
  if Edit = nil then
  begin
    ErrorDlg('No EditControl Found.');
    Exit;
  end;

  CnDebugger.TraceFmt('Will Hook EditControl %8.8x', [Integer(Edit)]);
  InfoDlg(Format('Will Hook EditControl %8.8x', [Integer(Edit)]));

  if FHookMouseUp = nil then
    FHookMouseUp := TCnEventHook.Create(Edit, 'OnMouseUp', Self,
      @TCnTestEditCtrlEventWizard.HookMouseUp);
  if FHookMouseDown = nil then
    FHookMouseDown := TCnEventHook.Create(Edit, 'OnMouseDown', Self,
      @TCnTestEditCtrlEventWizard.HookMouseDown);
  if FHookMouseMove = nil then
    FHookMouseMove := TCnEventHook.Create(Edit, 'OnMouseMove', Self,
      @TCnTestEditCtrlEventWizard.HookMouseMove);

  CnDebugger.TraceFmt('EditControl Hook Result %d. Old MouseUp %8.8x',
    [Integer(FHookMouseUp.Hooked), Integer(FHookMouseUp.Trampoline)]);
  CnDebugger.TraceFmt('EditControl Hook Result %d. Old MouseDown %8.8x',
    [Integer(FHookMouseDown.Hooked), Integer(FHookMouseDown.Trampoline)]);
  CnDebugger.TraceFmt('EditControl Hook Result %d. Old MouseMove %8.8x',
    [Integer(FHookMouseMove.Hooked), Integer(FHookMouseMove.Trampoline)]);
end;

function TCnTestEditCtrlEventWizard.GetCaption: string;
begin
  Result := 'Test EditControl Event Hook';
end;

function TCnTestEditCtrlEventWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditCtrlEventWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditCtrlEventWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditCtrlEventWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditCtrlEventWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test EditControl Event Hook Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for EditControl Event Hook';
end;

procedure TCnTestEditCtrlEventWizard.HookMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CnDebugger.TraceFmt('MouseDown at X %d, Y %d. Button %d.', [X, Y, Ord(Button)]);
end;

procedure TCnTestEditCtrlEventWizard.HookMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  CnDebugger.TraceFmt('MouseMove at X %d, Y %d.', [X, Y]);
end;

procedure TCnTestEditCtrlEventWizard.HookMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CnDebugger.TraceFmt('MouseUp at X %d, Y %d. Button %d.', [X, Y, Ord(Button)]);
end;

procedure TCnTestEditCtrlEventWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditCtrlEventWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestEditCtrlEventWizard); // 注册此测试专家

end.
