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

program CnDebugViewer64;

{$IFNDEF WIN64}
  {$MESSAGE ERROR 'CnDebugViewer64 Compiled Only by Delphi 64-Bit Compiler.'}
{$ENDIF}

uses
  SysUtils,
  Forms,
  CnViewMain in 'CnViewMain.pas' {CnMainViewer},
  CnDebugIntf in 'CnDebugIntf.pas',
  CnMsgClasses in 'CnMsgClasses.pas',
  CnGetThread in 'CnGetThread.pas',
  CnViewCore in 'CnViewCore.pas',
  CnMdiView in 'CnMdiView.pas' {CnMsgChild},
  CnMsgFiler in 'CnMsgFiler.pas',
  CnFilterFrm in 'CnFilterFrm.pas' {CnSenderFilterFrm},
  CnViewOption in 'CnViewOption.pas' {CnViewerOptionsFrm},
  CnWatchFrm in 'CnWatchFrm.pas' {CnWatchForm},
  CnWizCfgUtils in '..\..\Source\Utils\CnWizCfgUtils.pas';

{$R *.RES}
{$R ..\WindowsXP.RES}

begin
  if GetCWUseCustomUserDir then
    LoadOptions(GetCWUserPath + SCnOptionFileName)
  else
    LoadOptions(ExtractFilePath(Application.ExeName) + SCnOptionFileName);

  if FindCmdLineSwitch('global', ['-', '/'], True) then
  begin
    // Global Switch first, using Global Mode
    IsLocalMode := False;
  end
  else if CnViewerOptions.LocalSession or FindCmdLineSwitch('local', ['-', '/'], True) then
  begin
    ReInitLocalConsts; // If Local Switch or Settings, using Local Mode
    IsLocalMode := True;
  end;

  if CheckRunning then Exit;
  Application.Initialize;
  Application.CreateForm(TCnMainViewer, CnMainViewer);
  CnMainViewer.LaunchThread;
  Application.Run;
end.
