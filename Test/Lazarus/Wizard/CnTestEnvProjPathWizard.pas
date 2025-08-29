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

unit CnTestEnvProjPathWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：测试环境工程路径的子菜单专家测试单元
* 单元作者：CnPack 开发组
* 备    注：该单元测试 Lazarus 中的环境工程路径。
* 开发平台：Win7 + Lazarus 4
* 兼容测试：Win7 + Lazarus 4
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2025.08.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon, CnWideStrings,
  SrcEditorIntf, LazIDEIntf, IDEOptionsIntf, CompOptsIntf;

type

//==============================================================================
// 测试环境工程路径的子菜单专家
//==============================================================================

{ TCnTestEnvProjPathWizard }

  TCnTestEnvProjPathWizard = class(TCnSubMenuWizard)
  private
    FIdPrintSysPath: Integer;
    FIdPrintProjPath: Integer;
    FIdPrintProjFile: Integer;
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
// 测试环境工程路径功能的子菜单专家
//==============================================================================

{ TCnTestEnvProjPathWizard }

procedure TCnTestEnvProjPathWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestEnvProjPathWizard.Create;
begin
  inherited;

end;

procedure TCnTestEnvProjPathWizard.AcquireSubActions;
begin
  FIdPrintSysPath := RegisterASubAction('CnLazPrintSysPaths',
    'Test CnLazPrintSysPaths', 0, 'Test CnLazPrintSysPaths',
    'CnLazPrintSysPaths');
  FIdPrintProjPath := RegisterASubAction('CnLazPrintProjPaths',
    'Test CnLazPrintProjPaths', 0, 'Test CnLazPrintProjPaths',
    'CnLazPrintProjPaths');
  FIdPrintProjFile := RegisterASubAction('CnLazPrintProjFiles',
    'Test CnLazPrintProjFiles', 0, 'Test CnLazPrintProjFiles',
    'CnLazPrintProjFiles');
end;

function TCnTestEnvProjPathWizard.GetCaption: string;
begin
  Result := 'Test Env Proj Path';
end;

function TCnTestEnvProjPathWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEnvProjPathWizard.GetHint: string;
begin
  Result := 'Test Path Wizard';
end;

function TCnTestEnvProjPathWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEnvProjPathWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Env Proj Path Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Env Proj Path Wizard';
end;

procedure TCnTestEnvProjPathWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEnvProjPathWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEnvProjPathWizard.SubActionExecute(Index: Integer);
var
  I: Integer;
begin
  if not Active then Exit;

  if Index = FIdPrintSysPath then
  begin
    CnDebugger.TraceMsg('ParsedLazarusDirectory:');
    CnDebugger.TraceMsg(IDEEnvironmentOptions.GetParsedLazarusDirectory);
    // C:\lazarus\

    CnDebugger.TraceMsg('ParsedCompilerFilename:');
    CnDebugger.TraceMsg(IDEEnvironmentOptions.GetParsedCompilerFilename);
    // C:\lazarus\fpc\3.2.2\bin\i386-win32\fpc.exe

    CnDebugger.TraceMsg('ParsedFppkgConfig:');
    CnDebugger.TraceMsg(IDEEnvironmentOptions.GetParsedFppkgConfig);
  end
  else if Index = FIdPrintProjPath then
  begin
    if (LazarusIDE.ActiveProject <> nil) and (LazarusIDE.ActiveProject.LazCompilerOptions <> nil) then
    begin
      CnDebugger.TraceMsg('Directory:');
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.Directory);

      CnDebugger.TraceMsg('Filename:');
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.MainFile.Filename);

      CnDebugger.TraceMsg('IncludePath:');
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.IncludePath);
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.GetIncludePath(True));

      CnDebugger.TraceMsg('Libraries:');
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.Libraries);
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.GetLibraryPath(True, coptParsed, False));

      CnDebugger.TraceMsg('OtherUnitFiles:');
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.OtherUnitFiles);
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.GetUnitPath(True));

      CnDebugger.TraceMsg('Namespaces:');
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.Namespaces);

      CnDebugger.TraceMsg('ObjectPath:');
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.ObjectPath);
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.GetObjectPath(True));

      CnDebugger.TraceMsg('SrcPath:');
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.SrcPath);
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.GetSrcPath(True));

      CnDebugger.TraceMsg('DebugPath:');
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.DebugPath);
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.GetDebugPath(True));

      CnDebugger.TraceMsg('UnitOutputDirectory:');
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.UnitOutputDirectory);
      CnDebugger.TraceMsg(LazarusIDE.ActiveProject.LazCompilerOptions.GetUnitOutputDirectory(True));
    end
    else
      ShowMessage('NO Project');
  end
  else if Index = FIdPrintProjFile then
  begin
    if LazarusIDE.ActiveProject <> nil then
    begin
      for I := 0 to LazarusIDE.ActiveProject.FileCount - 1 do
      begin
        if CnOtaIsFileOpen(LazarusIDE.ActiveProject.Files[I].Filename) then
          CnDebugger.TraceFmt('# %d * %s', [I, LazarusIDE.ActiveProject.Files[I].Filename])
        else
          CnDebugger.TraceFmt('# %d   %s', [I, LazarusIDE.ActiveProject.Files[I].Filename]);
      end;
    end;
  end;
end;

procedure TCnTestEnvProjPathWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestEnvProjPathWizard); // 注册专家

end.
