{******************************************************************************}
{                                                                              }
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

unit TestProjectGroupWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：测试工程组信息的子菜单专家测试单元
* 单元作者：CnPack 开发组
* 备    注：该单元测试 Lazarus 中的 CnOtaGetProjectGroup。
* 开发平台：Win7 + Lazarus 4
* 兼容测试：Win7 + Lazarus 4
* 本 地 化：该单元中的字符串暂不支持本地化处理方式
* 修改记录：2026.10.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon, CnWideStrings,
  SrcEditorIntf, LazIDEIntf, ProjectGroupIntf, ProjectGroup;

type

//==============================================================================
// 测试工程组信息的子菜单专家
//==============================================================================

{ TCnTestProjectGroupWizard }

  TCnTestProjectGroupWizard = class(TCnSubMenuWizard)
  private
    FIdPrintProjectGroup: Integer;
    FIdPrintProjectGroupProjects: Integer;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
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

//==============================================================================
// 测试工程组信息的子菜单专家
//==============================================================================

{ TCnTestProjectGroupWizard }

procedure TCnTestProjectGroupWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestProjectGroupWizard.Create;
begin
  inherited;

end;

procedure TCnTestProjectGroupWizard.AcquireSubActions;
begin
  FIdPrintProjectGroup := RegisterASubAction('CnLazPrintProjectGroup',
    'Test CnLazPrintProjectGroup', 0, 'Test CnLazPrintProjectGroup',
    'CnLazPrintProjectGroup');
  FIdPrintProjectGroupProjects := RegisterASubAction('CnLazPrintProjectGroupProjects',
    'Test CnLazPrintProjectGroupProjects', 0, 'Test CnLazPrintProjectGroupProjects',
    'CnLazPrintProjectGroupProjects');
end;

function TCnTestProjectGroupWizard.GetCaption: string;
begin
  Result := 'Test Project Group';
end;

function TCnTestProjectGroupWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestProjectGroupWizard.GetHint: string;
begin
  Result := 'Test Project Group Wizard';
end;

function TCnTestProjectGroupWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestProjectGroupWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Project Group Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test for CnOtaGetProjectGroup under Lazarus';
end;

procedure TCnTestProjectGroupWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestProjectGroupWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestProjectGroupWizard.SubActionExecute(Index: Integer);
var
  ProjectGroup: TCnIDEProjectGroupInterface;
  Target: TPGCompileTarget;
  I: Integer;
begin
  if not Active then Exit;

  ProjectGroup := CnOtaGetProjectGroup;
  if ProjectGroup = nil then
  begin
    CnDebugger.TraceMsg('No Project Group');
    ShowMessage('No Project Group');
    Exit;
  end;

  if Index = FIdPrintProjectGroup then
  begin
    if ProjectGroup.FileName = '' then
      CnDebugger.TraceMsg('Project Group FileName: <empty>')
    else
    begin
      CnDebugger.TraceMsg('Project Group FileName:');
      CnDebugger.TraceMsg(ProjectGroup.FileName);
    end;

    CnDebugger.TraceFmt('Project Group ProjectCount: %d',
      [ProjectGroup.TargetCount]);
  end
  else if Index = FIdPrintProjectGroupProjects then
  begin
    for I := 0 to ProjectGroup.TargetCount - 1 do
    begin
      Target := ProjectGroup.Targets[I];
      if (Target.TargetType in [ttProject, ttPackage]) then
        CnDebugger.TraceFmt('#%d %s - TargetFile: %s', [I, Target.ClassName, Target.Filename]);
    end;
  end;
end;

procedure TCnTestProjectGroupWizard.SubActionUpdate(Index: Integer);
begin

end;

initialization
  RegisterCnWizard(TCnTestProjectGroupWizard); // 注册专家

end.
