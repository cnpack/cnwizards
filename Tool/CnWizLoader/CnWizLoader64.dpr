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

library CnWizLoader64;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizard 专家 DLL 加载器实现单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin11 + Delphi 12
* 兼容测试：64 位版本的 Delphi
* 本 地 化：该单元无需本地化
* 修改记录：2025.02.03 V1.1
*               创建单元
================================================================================
|</PRE>}

uses
  SysUtils,
  Classes,
  Windows,
  Forms,
  CnWizLoadUtils in 'CnWizLoadUtils.pas';

{$R *.RES}

// 加载器 DLL 初始化入口函数，加载对应版本的专家包 DLL
function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
var
  Dll: string;
  Entry: TWizardEntryPoint;
begin
  if FindCmdLineSwitch(SCnNoCnWizardsSwitch, ['/', '-'], True) then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  Dll := GetWizardDll;

  if (Dll <> '') and FileExists(Dll) then
  begin
    OutputDebugString(PChar(Format('Get 64 Bit DLL: %s', [Dll])));

    DllInst := LoadLibraryW(PChar(Dll));
    if DllInst <> 0 then
    begin
      OutputDebugString(PChar('64 Bit DLL Loading OK. To Get Entry.'));
      Entry := TWizardEntryPoint(GetProcAddress(DllInst, WizardEntryPoint));
      if Assigned(Entry) then
      begin
        // 调用真正的 DLL 初始化，并接收其卸载过程的指针
        OutputDebugString(PChar(Format('64 Bit DLL Entry Got, to Call %s', [WizardEntryPoint])));
        Result := Entry(BorlandIDEServices, RegisterProc, LoaderTerminateProc);

        OutputDebugString(PChar('64 Bit DLL Entry Called.'));
        // IDE 的卸载过程则指给我们的
        Terminate := LoaderTerminate;
      end
      else
        OutputDebugString(PChar(Format('64 Bit DLL Corrupted! No Entry %s', [WizardEntryPoint])));
    end
    else
      OutputDebugString(PChar(Format('64 Bit DLL Loading Error! %d', [GetLastError])));
  end
  else
    OutputDebugString(PChar(Format('64 Bit DLL %s NOT Found!', [Dll])));
end;

exports
  InitWizard name WizardEntryPoint;

begin
end.
