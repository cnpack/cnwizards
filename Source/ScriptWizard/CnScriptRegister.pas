{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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
* 单元标识：$Id$
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
  CnScript_ToolsAPI,
{$ELSE}
  CnScript_DsgnIntf,
  CnScript_ToolsAPI_D5,
{$ENDIF}
  CnScript_IdeInstComp, CnScript_CnCommon, CnScript_CnDebug, CnScript_CnWizUtils,
  CnScript_CnWizIdeUtils, CnScript_CnWizOptions, CnScript_ScriptEvent;

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
  RegisterCnScriptPlugin(TPSImport_IdeInstComp);
  RegisterCnScriptPlugin(TPSImport_CnCommon);
  RegisterCnScriptPlugin(TPSImport_CnDebug);
  RegisterCnScriptPlugin(TPSImport_CnWizUtils);
  RegisterCnScriptPlugin(TPSImport_CnWizIdeUtils);
  RegisterCnScriptPlugin(TPSImport_CnWizOptions);
  RegisterCnScriptPlugin(TPSImport_ScriptEvent);

{$ENDIF}

{$ENDIF CNWIZARDS_CNSCRIPTWIZARD}
end.
