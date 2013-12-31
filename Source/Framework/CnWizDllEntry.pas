{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizDllEntry;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizard 专家 DLL 入口单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2002.12.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, ToolsAPI, CnWizConsts;

// 专家DLL初始化入口函数
function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
{* 专家DLL初始化入口函数}

exports
  InitWizard name WizardEntryPoint;

implementation

uses
{$IFDEF Debug}
  CnDebug,
{$ENDIF Debug}
  CnWizManager;

const
  InvalidIndex = -1;

var
  FWizardIndex: Integer = InvalidIndex;

// 专家DLL释放过程
procedure FinalizeWizard;
var
  WizardServices: IOTAWizardServices;
begin
  if FWizardIndex <> InvalidIndex then
  begin
    Assert(Assigned(BorlandIDEServices));
    WizardServices := BorlandIDEServices as IOTAWizardServices;
    Assert(Assigned(WizardServices));
    WizardServices.RemoveWizard(FWizardIndex);
    FWizardIndex := InvalidIndex;
  end;
end;

// 专家DLL初始化入口函数
function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
var
  WizardServices: IOTAWizardServices;
begin
  if FindCmdLineSwitch(SCnNoCnWizardsSwitch, ['/', '-'], True) then
  begin
    Result := True;
  {$IFDEF Debug}
    CnDebugger.LogMsg('Do NOT Load CnWizards');
  {$ENDIF Debug}
    Exit;
  end;

{$IFDEF Debug}
  CnDebugger.LogMsg('Wizard dll entry');
{$ENDIF Debug}

  Result := BorlandIDEServices <> nil;
  if Result then
  begin
    Assert(ToolsAPI.BorlandIDEServices = BorlandIDEServices);
    Terminate := FinalizeWizard;
    WizardServices := BorlandIDEServices as IOTAWizardServices;
    Assert(Assigned(WizardServices));
    CnWizardMgr := TCnWizardMgr.Create;
    FWizardIndex := WizardServices.AddWizard(CnWizardMgr as IOTAWizard);
    Result := (FWizardIndex >= 0);
  {$IFDEF Debug}
    CnDebugger.LogBoolean(Result, 'WizardMgr registered');
  {$ENDIF Debug}
  end;
end;

end.

