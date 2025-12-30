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

unit  CnTestProjectGroupWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试 CnOtaGetProjectGroup 函数的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：测试 CnOtaGetProjectGroup 在各 IDE 下的兼容性。
            需要在 D5/2007/2009 等测试通过。
* 开发平台：WinXP + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi All
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2015.03.17 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// 测试 CnOtaGetProjectGroup 函数的菜单专家
//==============================================================================

{ TCnTestProjectGroupWizard }

  TCnTestProjectGroupWizard = class(TCnMenuWizard)
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

type
  TGetProjectCount = function: Integer of object;

function IOTAProjectGroupGetProjectCountOffset: Cardinal;
asm
  MOV EAX, VMTOFFSET IOTAProjectGroup.GetProjectCount
end;

//==============================================================================
// 测试 CnOtaGetProjectGroup 函数的菜单专家
//==============================================================================

{ TCnTestProjectGroupWizard }

procedure TCnTestProjectGroupWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestProjectGroupWizard.Execute;
var
  ProjectGroup: IOTAProjectGroup;
  Method: TGetProjectCount;
begin
  ProjectGroup := CnOtaGetProjectGroup;
  InfoDlg(IntToStr(Integer(ProjectGroup)));
  if ProjectGroup <> nil then
  begin
    InfoDlg('Projecg Group Got.');
    TMethod(Method).Code := PPointer(Integer(Pointer(ProjectGroup)^) +
      IOTAProjectGroupGetProjectCountOffset)^;

    TMethod(Method).Data := Pointer(ProjectGroup);
    InfoDlg('Address: ' + IntToStr(Integer(TMethod(Method).Code)));
    InfoDlg('Call Result: ' + IntToStr(Method()));
  end
  else
    ShowMessage('No Project Group');
end;

function TCnTestProjectGroupWizard.GetCaption: string;
begin
  Result := 'Test CnOtaGetProjectGroup';
end;

function TCnTestProjectGroupWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestProjectGroupWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestProjectGroupWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestProjectGroupWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestProjectGroupWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test CnOtaGetProjectGroup Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for CnOtaGetProjectGroup under All Delphi';
end;

procedure TCnTestProjectGroupWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestProjectGroupWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestProjectGroupWizard); // 注册此测试专家

end.
