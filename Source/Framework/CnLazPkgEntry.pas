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

unit CnLazPkgEntry;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizard 专家 Lazarus 注册入口单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin7Pro + Lazarus 4.0
* 兼容测试：PWin9X/2000/XP + Lazarus 4.0
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2025.06.23 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Classes, LCLType, Forms, Controls,
  IDEWindowIntf, IDEOptionsIntf, IDEOptEditorIntf, MenuIntf, IDEImagesIntf,
  LazIDEIntf, IDECommands;

procedure Register;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

procedure MenuExecute(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.EvaluateControlUnderPos(Mouse.CursorPos);
{$ENDIF}
end;

procedure Register;
var
  Catgory: TIDECommandCategory;
  Cmd: TIDECommand;
  SC: TIDEShortCut;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Laz Register Unit');
{$ENDIF}
  SC := IDEShortCut(VK_1, [ssAlt]);
  Catgory := RegisterIDECommandCategory(nil, 'CnPack', 'CnPack Category');
  Cmd := RegisterIDECommand(Catgory, 'Test', 'Test Entry', nil, @MenuExecute);

  RegisterIDEMenuCommand(itmSecondaryTools{ mnuTools}, 'CnPackTest', 'CnPack Test...', nil, nil, Cmd);
  // CnWizardMgr := TCnWizardMgr.Create;
end;

initialization

finalization
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Laz CnLazPkgEntry Finalization');
{$ENDIF}
  // FreeAndNil(CnWizardMgr);

end.
