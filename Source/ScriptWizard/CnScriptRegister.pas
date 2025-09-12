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

unit CnScriptRegister;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展库注册单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

implementation

{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}

{$IFDEF SUPPORT_PASCAL_SCRIPT}

uses
  uPSComponent, CnScriptClasses, CnScript_System, CnScript_Windows,
  CnScript_Messages, CnScript_SysUtils, CnScript_Classes, CnScript_TypInfo,
  CnScript_Graphics, CnScript_Controls, CnScript_Clipbrd, CnScript_Printers,
  CnScript_IniFiles, CnScript_Registry, CnScript_Menus, CnScript_ActnList,
  CnScript_Forms, CnScript_StdCtrls, CnScript_ExtCtrls, CnScript_ComCtrls,
  CnScript_Buttons, CnScript_Dialogs, CnScript_ExtDlgs, CnScript_ComObj,
{$IFDEF COMPILER6_UP}
  CnScript_DesignIntf,
{$ELSE}
  CnScript_DsgnIntf,
{$ENDIF}
  {$IFDEF DELPHI5} CnScript_ToolsAPI_D5, {$ENDIF}
  {$IFDEF DELPHI6} CnScript_ToolsAPI_D6, {$ENDIF}
  {$IFDEF DELPHI7} CnScript_ToolsAPI_D7, {$ENDIF}
  {$IFDEF DELPHI2005} CnScript_ToolsAPI_D2005, {$ENDIF}
  {$IFDEF DELPHI2006} CnScript_ToolsAPI_D2006, {$ENDIF}
  {$IFDEF DELPHI2007} CnScript_ToolsAPI_D2007, {$ENDIF}
  {$IFDEF DELPHI2009} CnScript_ToolsAPI_D2009, {$ENDIF}
  {$IFDEF DELPHI2010} CnScript_ToolsAPI_D2010, {$ENDIF}
  {$IFDEF DELPHIXE} CnScript_ToolsAPI_DXE, {$ENDIF}
  {$IFDEF DELPHIXE2} CnScript_ToolsAPI_DXE2, {$ENDIF}
  {$IFDEF DELPHIXE3} CnScript_ToolsAPI_DXE3, {$ENDIF}
  {$IFDEF DELPHIXE4} CnScript_ToolsAPI_DXE4, {$ENDIF}
  {$IFDEF DELPHIXE5} CnScript_ToolsAPI_DXE5, {$ENDIF}
  {$IFDEF DELPHIXE6} CnScript_ToolsAPI_DXE6, {$ENDIF}
  {$IFDEF DELPHIXE7} CnScript_ToolsAPI_DXE7, {$ENDIF}
  {$IFDEF DELPHIXE8} CnScript_ToolsAPI_DXE8, {$ENDIF}
  {$IFDEF DELPHI10_SEATTLE} CnScript_ToolsAPI_D10S, {$ENDIF}
  {$IFDEF DELPHI101_BERLIN} CnScript_ToolsAPI_D101B, {$ENDIF}
  {$IFDEF DELPHI102_TOKYO} CnScript_ToolsAPI_D102T, {$ENDIF}
  {$IFDEF DELPHI103_RIO} CnScript_ToolsAPI_D103R, {$ENDIF}
  {$IFDEF DELPHI104_SYDNEY} CnScript_ToolsAPI_D104S, {$ENDIF}
  {$IFDEF DELPHI110_ALEXANDRIA} CnScript_ToolsAPI_D110A, {$ENDIF}
  {$IFDEF DELPHI120_ATHENS} CnScript_ToolsAPI_D120A, CnScript_ToolsAPI_WelcomePage_D120A, {$ENDIF}
  {$IFDEF DELPHI130_FLORENCE} CnScript_ToolsAPI_D130F, CnScript_ToolsAPI_Editor_D130F,
  CnScript_ToolsAPI_WelcomePage_D130F, {$ENDIF}
  {$IFDEF DELPHI120_ATHENS_UP} CnScript_ToolsAPI_UI_D120A, {$ENDIF}
  {$IFDEF BCB5} CnScript_ToolsAPI_D5, {$ENDIF}
  {$IFDEF BCB6} CnScript_ToolsAPI_D6, {$ENDIF}
  CnScript_IdeInstComp, CnScript_CnCommon, CnScript_CnDebug, CnScript_CnWizUtils,
  CnScript_CnWizIdeUtils, CnScript_CnWizOptions, CnScript_ScriptEvent,
  CnScript_AsRegExpr, CnScript_CnWizClasses, CnScript_CnWizManager, CnScript_CnWizShortCut;

initialization
  RegisterCnScriptPlugin(TPSDllPlugin);
  RegisterCnScriptPlugin(TPSImport_System);
  RegisterCnScriptPlugin(TPSImport_Windows);
  RegisterCnScriptPlugin(TPSImport_Messages);
  RegisterCnScriptPlugin(TPSImport_SysUtils);
  RegisterCnScriptPlugin(TPSImport_Classes);
  RegisterCnScriptPlugin(TPSImport_TypInfo);
  RegisterCnScriptPlugin(TPSImport_Graphics);
  RegisterCnScriptPlugin(TPSImport_Controls);
  RegisterCnScriptPlugin(TPSImport_Clipbrd);
  RegisterCnScriptPlugin(TPSImport_Printers);
  RegisterCnScriptPlugin(TPSImport_IniFiles);
  RegisterCnScriptPlugin(TPSImport_Registry);
  RegisterCnScriptPlugin(TPSImport_Menus);
  RegisterCnScriptPlugin(TPSImport_ActnList);
  RegisterCnScriptPlugin(TPSImport_Forms);
  RegisterCnScriptPlugin(TPSImport_StdCtrls);
  RegisterCnScriptPlugin(TPSImport_ExtCtrls);
  RegisterCnScriptPlugin(TPSImport_ComCtrls);
  RegisterCnScriptPlugin(TPSImport_Buttons);
  RegisterCnScriptPlugin(TPSImport_Dialogs);
  RegisterCnScriptPlugin(TPSImport_ExtDlgs);
  RegisterCnScriptPlugin(TPSImport_ComObj);
{$IFDEF COMPILER6_UP}
  RegisterCnScriptPlugin(TPSImport_DesignIntf);
{$ELSE}
  RegisterCnScriptPlugin(TPSImport_DsgnIntf);
{$ENDIF}
  RegisterCnScriptPlugin(TPSImport_ToolsAPI);
{$IFDEF DELPHI120_ATHENS_UP}
  RegisterCnScriptPlugin(TPSImport_ToolsAPI_WelcomePage);
  RegisterCnScriptPlugin(TPSImport_ToolsAPI_Editor);
  RegisterCnScriptPlugin(TPSImport_ToolsAPI_UI);
{$ENDIF}
  RegisterCnScriptPlugin(TPSImport_IdeInstComp);
  RegisterCnScriptPlugin(TPSImport_CnCommon);
  RegisterCnScriptPlugin(TPSImport_CnDebug);
  RegisterCnScriptPlugin(TPSImport_CnWizUtils);
  RegisterCnScriptPlugin(TPSImport_CnWizIdeUtils);
  RegisterCnScriptPlugin(TPSImport_CnWizOptions);
  RegisterCnScriptPlugin(TPSImport_ScriptEvent);
  RegisterCnScriptPlugin(TPSImport_AsRegExpr);
  RegisterCnScriptPlugin(TPSImport_CnWizClasses);
  RegisterCnScriptPlugin(TPSImport_CnWizManager);
  RegisterCnScriptPlugin(TPSImport_CnWizShortCut);

{$ENDIF}

{$ENDIF CNWIZARDS_CNSCRIPTWIZARD}
end.
