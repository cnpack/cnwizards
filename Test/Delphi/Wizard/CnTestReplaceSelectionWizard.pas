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

unit CnTestReplaceSelectionWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�������ָ�������滻�༭����ѡ��������ؽӿڵĲ˵�ר��
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�ԪӦ�������� Delphi �汾��������
            ֻ�轫�˵�Ԫ����ר�Ұ�Դ�빤�̺��ر�����ؼ��ɽ��в��ԣ�
* ����ƽ̨��PWinXP + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.09.04 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// ������ָ�������滻�༭����ѡ��������ؽӿڵĲ˵�ר��
//==============================================================================

{ TCnTestReplaceSelectionWizard }

  TCnTestReplaceSelectionWizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

const
  Content: string =
    'EditView := CnOtaGetTopMostEditView;' + #13#10 +
    'if not Assigned(EditView) then' + #13#10 +
      'Exit;' + #13#10 +
      '' + #13#10 +
    'EditBlock := EditView.Block;' + #13#10 + 
    'if Assigned(EditBlock) then' + #13#10 + 
      'EditBlock.Delete;';

//==============================================================================
// ������ָ�������滻�༭����ѡ��������ؽӿڵĲ˵�ר��
//==============================================================================

{ TCnTestReplaceSelectionWizard }

procedure TCnTestReplaceSelectionWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestReplaceSelectionWizard.Execute;
var
  Res: string;
begin
  Res := Content;
  Application.MessageBox(PChar(Res), 'Will Replace Current Selection with Below:',
    MB_OK + MB_ICONINFORMATION);

{$IFDEF IDE_STRING_ANSI_UTF8}
  CnOtaReplaceCurrentSelectionUtf8(Res, True, True, True);
{$ELSE}
  // Ansi/Unicode ������
  CnOtaReplaceCurrentSelection(Res, True, True, True);
{$ENDIF}
end;

function TCnTestReplaceSelectionWizard.GetCaption: string;
begin
  Result := 'Test Replace Current Selection';
end;

function TCnTestReplaceSelectionWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestReplaceSelectionWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestReplaceSelectionWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestReplaceSelectionWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestReplaceSelectionWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := 'Test Replace Current Selection Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Replace Current Selection under All Delphi.';
end;

procedure TCnTestReplaceSelectionWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestReplaceSelectionWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestReplaceSelectionWizard); // ע��˲���ר��

end.
