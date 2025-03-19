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

unit CnTestScriptCompileWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestScriptCompileWizard
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：Windows 7 + Delphi 5
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2025.03.19 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, FileCtrl, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon;

type

//==============================================================================
// CnTestScriptCompileWizard 菜单专家
//==============================================================================

{ TCnTestScriptCompileWizard }

  TCnTestScriptCompileWizard = class(TCnMenuWizard)
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
  CnDebug, CnScriptClasses;

//==============================================================================
// CnTestScriptCompileWizard 菜单专家
//==============================================================================

{ TCnTestScriptCompileWizard }

procedure TCnTestScriptCompileWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestScriptCompileWizard.Execute;
var
  I: Integer;
  Dir, Msg: string;
  Files, Sl: TStringList;
  Exec: TCnScriptExec;
begin
  if SelectDirectory('Select Script Directory', 'C:\', Dir) then
  begin
    Files := TStringList.Create;
    try
      GetDirFiles(Dir, Files);

      for I := 0 to Files.Count - 1 do
      begin
        Sl := nil;
        Exec := nil;

        try
          Sl := TStringList.Create;
          Sl.LoadFromFile(Files[I]);
          Exec := TCnScriptExec.Create;

          Msg := '';
          if Exec.CompileScript(Sl.Text, Msg) = erSucc then
            CnDebugger.LogMsg('OK: ' + Files[I])
          else
          begin
            CnDebugger.LogMsgError('Fail: ' + Files[I]);
            CnDebugger.LogMsgError(Msg);
          end;
        finally
          Exec.Free;
        end;
      end;
    finally
      Files.Free;
    end;
  end;
end;

function TCnTestScriptCompileWizard.GetCaption: string;
begin
  Result := 'Test Script Compile';
end;

function TCnTestScriptCompileWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestScriptCompileWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestScriptCompileWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestScriptCompileWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestScriptCompileWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Script Compile Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Script Files Compiling';
end;

procedure TCnTestScriptCompileWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestScriptCompileWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestScriptCompileWizard); // 注册此测试专家

end.
