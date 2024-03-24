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

unit CnTestBreakpointWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnWizDebuggerNotifier 中断点相关的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：该单元对 CnWizDebuggerNotifier 单元提供的获取断点的接口进行测试
            只需将此单元加入专家包源码工程后重编译加载即可进行测试，
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2015.06.03 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnEditControlWrapper,
  CnWizDebuggerNotifier;

type

//==============================================================================
// 测试 CnWizDebuggerNotifier 的获取断点的菜单专家
//==============================================================================

{ TCnTestBreakpointMenuWizard }

  TCnTestBreakpointMenuWizard = class(TCnMenuWizard)
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

uses
  CnDebug;

//==============================================================================
// 测试 CnWizDebuggerNotifier 中的获取断点的菜单专家
//==============================================================================

{ TCnTestBreakpointMenuWizard }

procedure TCnTestBreakpointMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestBreakpointMenuWizard.Execute;
var
  List: TList;
  I: Integer;
  S: string;
begin
  List := TList.Create;
  try
    CnOtaGetCurrentBreakpoints(List);

    if List.Count = 0 then
      ShowMessage('No Breakpoints.')
    else
    begin
      for I := 0 to List.Count - 1 do
        S := S + TCnBreakpointDescriptor(List[I]).ToString + #13#10;
      ShowMessage(S);
    end;

    ShowMessage('To Add a Breakpoint at Line 15');
    if EditControlWrapper.ClickBreakpointAtActualLine(15) then
      ShowMessage('Breakpoint Clicked.')
    else
      ShowMessage('Breakpoint Click Fail.');
  finally
    List.Free;
  end;
end;

function TCnTestBreakpointMenuWizard.GetCaption: string;
begin
  Result := 'Get Current Breakpoints';
end;

function TCnTestBreakpointMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestBreakpointMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestBreakpointMenuWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestBreakpointMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestBreakpointMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Breakpoints Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Get Breakpoints';
end;

procedure TCnTestBreakpointMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBreakpointMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestBreakpointMenuWizard); // 注册此测试专家

end.

