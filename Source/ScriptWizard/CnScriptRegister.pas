{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnScriptRegister;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��ű���չ��ע�ᵥԪ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWinXP SP2 + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����ô����е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2006.12.11 V1.0
*               ������Ԫ
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
