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

unit ScriptEvent;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 ScriptEvent 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：
* 修改记录：2007.09.30 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, Classes, Graphics, Controls, SysUtils, IniFiles, Forms,
  ToolsAPI;

type
  TCnScriptMode = (smManual, smIDELoaded, smFileNotify, smBeforeCompile,
    smAfterCompile, smSourceEditorNotify, smFormEditorNotify, smApplicationEvent,
    smActiveFormChanged);
  TCnScriptModeSet = set of TCnScriptMode;

{$M+} // Generate RTTI
  TCnScriptEvent = class
  private
    FMode: TCnScriptMode;
  published
    property Mode: TCnScriptMode read FMode;
  end;
{$M-}

  TCnScriptManual = class(TCnScriptEvent)
  end;

  TCnScriptIDELoaded = class(TCnScriptEvent)
  end;

  TCnScriptFileNotify = class(TCnScriptEvent)
  private
    FFileName: string;
    FFileNotifyCode: TOTAFileNotification;
  published
    property FileNotifyCode: TOTAFileNotification read FFileNotifyCode;
    property FileName: string read FFileName;
  end;

  TCnScriptBeforeCompile = class(TCnScriptEvent)
  private
    FIsCodeInsight: Boolean;
    FCancel: Boolean;
    FProject: IOTAProject;
  published
    property Project: IOTAProject read FProject;
    property IsCodeInsight: Boolean read FIsCodeInsight;
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TCnScriptAfterCompile = class(TCnScriptEvent)
  private
    FSucceeded: Boolean;
    FIsCodeInsight: Boolean;
  published
    property Succeeded: Boolean read FSucceeded;
    property IsCodeInsight: Boolean read FIsCodeInsight;
  end;

  TCnWizSourceEditorNotifyType = (setOpened, setClosing, setModified,
    setEditViewInsert, setEditViewRemove, setEditViewActivated);

  TCnScriptSourceEditorNotify = class(TCnScriptEvent)
  private
    FEditView: IOTAEditView;
    FSourceEditor: IOTASourceEditor;
    FNotifyType: TCnWizSourceEditorNotifyType;
  published
    property SourceEditor: IOTASourceEditor read FSourceEditor;
    property NotifyType: TCnWizSourceEditorNotifyType read FNotifyType;
    property EditView: IOTAEditView read FEditView;
  end;

  TCnWizFormEditorNotifyType = (fetOpened, fetClosing, fetModified,
    fetActivated, fetSaving, fetComponentCreating, fetComponentCreated,
    fetComponentDestorying, fetComponentRenamed);

  TCnScriptFormEditorNotify = class(TCnScriptEvent)
  private
    FFormEditor: IOTAFormEditor;
    FOldName: string;
    FNewName: string;
    FNotifyType: TCnWizFormEditorNotifyType;
    FComponent: TComponent;
  published
    property FormEditor: IOTAFormEditor read FFormEditor;
    property NotifyType: TCnWizFormEditorNotifyType read FNotifyType;
    property Component: TComponent read FComponent;
    property OldName: string read FOldName;
    property NewName: string read FNewName;
  end;
  
  TCnScriptApplicationEventNotify = class(TCnScriptEvent)
  private
    FAppEventType: TCnWizAppEventType;
  published
    property AppEventType: TCnWizAppEventType read FAppEventType;
  end;

  TCnScriptActiveFormChanged = class(TCnScriptEvent)

  end;

  TCnScriptEditorFlatButton = class(TCnScriptEvent)

  end;

  TCnScriptDesignerContextMenu = class(TCnScriptEvent)

  end;

function Event: TCnScriptEvent;

implementation

function Event: TCnScriptEvent;
begin

end;


end.
