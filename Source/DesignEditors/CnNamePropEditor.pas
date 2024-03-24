{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnNamePropEditor;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：组件名属性编辑器
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：调用组件前缀专家来修改组件名称
* 开发平台：PWinXP SP2 + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 修改记录：2005.04.07
*             创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}
{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

uses
  Windows, SysUtils, Classes, ToolsAPI, StdCtrls, Controls, Forms,
{$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  CnCommon, CnConsts, CnDesignEditor, CnDesignEditorConsts;

type

{ TCnNamePropEditor }

  TCnNamePropEditor = class(TStringProperty)
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    class procedure GetInfo(var Name, Author, Email, Comment: String);
    class procedure Register;
  end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}
{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

uses
  CnWizManager, CnPrefixWizard {$IFDEF DEBUG}, CnDebug {$ENDIF};

procedure TCnNamePropEditor.Edit;
var
  Wizard: TCnPrefixWizard;
begin
  Wizard := TCnPrefixWizard(CnWizardMgr.WizardByClass(TCnPrefixWizard));
  if Assigned(Wizard) and Wizard.Active then
  begin
    if (GetComponent(0) is TComponent) and
      (Trim(TComponent(GetComponent(0)).Name) <> '') then
    begin
      Wizard.ExecuteRename(TComponent(GetComponent(0)), True);
    end;
  end
  else
  begin
    ErrorDlg(SCnPrefixWizardNotExist);
  end;
end;

function TCnNamePropEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paRevertable, paDialog];
end;

class procedure TCnNamePropEditor.GetInfo(var Name, Author, Email,
  Comment: String);
begin
  Name := SCnNamePropEditorName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnNamePropEditorComment;
end;

class procedure TCnNamePropEditor.Register;
var
  Wizard: TCnPrefixWizard;
begin
  Wizard := TCnPrefixWizard(CnWizardMgr.WizardByClass(TCnPrefixWizard));
  if Assigned(Wizard) and Wizard.Active then
  begin
    RegisterPropertyEditor(TypeInfo(TComponentName), TControl, 'Name',
      TCnNamePropEditor);
    RegisterPropertyEditor(TypeInfo(TComponentName), TComponent, 'Name',
      TCnNamePropEditor);
  end;
end;

initialization
  CnDesignEditorMgr.RegisterPropEditor(TCnNamePropEditor,
    TCnNamePropEditor.GetInfo, TCnNamePropEditor.Register);

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnNamePropEditor.');
{$ENDIF}

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.
