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

unit  CnTestProjectGroupWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����� CnOtaGetProjectGroup �����Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ CnOtaGetProjectGroup �ڸ� IDE �µļ����ԡ�
            ��Ҫ�� D5/2007/2009 �Ȳ���ͨ����
* ����ƽ̨��WinXP + Delphi 5
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi All
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.03.17 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// ���� CnOtaGetProjectGroup �����Ĳ˵�ר��
//==============================================================================

{ TCnTestProjectGroupWizard }

  TCnTestProjectGroupWizard = class(TCnMenuWizard)
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

uses
  CnDebug;

type
  TGetProjectCount = function: Integer of object;

function IOTAProjectGroupGetProjectCountOffset: Cardinal;
asm
  MOV EAX, VMTOFFSET IOTAProjectGroup.GetProjectCount
end;

//==============================================================================
// ���� CnOtaGetProjectGroup �����Ĳ˵�ר��
//==============================================================================

{ TCnTestProjectGroupWizard }

procedure TCnTestProjectGroupWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestProjectGroupWizard.Execute;
var
  ProjectGroup: IOTAProjectGroup;
  Method: TGetProjectCount;
begin
  ProjectGroup := CnOtaGetProjectGroup;
  InfoDlg(IntToStr(Integer(ProjectGroup)));
  if ProjectGroup <> nil then
  begin
    InfoDlg('Projecg Group Got.');
    TMethod(Method).Code := PPointer(Integer(Pointer(ProjectGroup)^) +
      IOTAProjectGroupGetProjectCountOffset)^;

    TMethod(Method).Data := Pointer(ProjectGroup);
    InfoDlg('Address: ' + IntToStr(Integer(TMethod(Method).Code)));
    InfoDlg('Call Result: ' + IntToStr(Method()));
  end
  else
    ShowMessage('No Project Group');
end;

function TCnTestProjectGroupWizard.GetCaption: string;
begin
  Result := 'Test CnOtaGetProjectGroup';
end;

function TCnTestProjectGroupWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestProjectGroupWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestProjectGroupWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestProjectGroupWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestProjectGroupWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test CnOtaGetProjectGroup Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for CnOtaGetProjectGroup under All Delphi';
end;

procedure TCnTestProjectGroupWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestProjectGroupWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestProjectGroupWizard); // ע��˲���ר��

end.
