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

unit CnNamePropEditor;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ���������Ա༭��
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���������ǰ׺ר�����޸��������
* ����ƽ̨��PWinXP SP2 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����õ�Ԫ�ʹ����е��ַ����Ѿ����ػ�����ʽ
* �޸ļ�¼��2005.04.07
*             ������Ԫ
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
