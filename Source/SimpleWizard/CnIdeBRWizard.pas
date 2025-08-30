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

unit CnIdeBRWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��� IDE ������ IDE ��������/�ָ�����
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2006.08.23 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNIDEBRWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles,
  CnWizClasses, CnWizUtils, CnWizConsts, CnConsts, CnWizOptions;

type

{ TCnIdeBRWizard }

  TCnIdeBRWizard = class(TCnMenuWizard)
  private
  
  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNIDEBRWIZARD}

implementation

{$IFDEF CNWIZARDS_CNIDEBRWIZARD}

uses
  CnCommon;

{ TCnIdeBRWizard }

procedure TCnIdeBRWizard.Execute;
var
  FileName, Param: string;
begin
  FileName := WizOptions.DllPath + SCnIdeBRToolName;
  if FileExists(FileName) then
  begin
    Param := '';
{$IFDEF DELPHI5}
    Param := '-IDelphi5';
{$ELSE}
  {$IFDEF DELPHI6}
    Param := '-IDelphi6';
  {$ELSE}
    {$IFDEF DELPHI7}
    Param := '-IDelphi7';
    {$ELSE}
      {$IFDEF DELPHI8}
    Param := '-IDelphi8';
      {$ELSE}
        {$IFDEF DELPHI9}
    Param := '-IBDS2005';
        {$ELSE}
          {$IFDEF DELPHI10}
    Param := '-IBDS2006';
          {$ELSE}
            {$IFDEF DELPHI11}
    Param := '-IRADStudio2007';
            {$ELSE}
              {$IFDEF BCB5}
    Param := '-IBCB5';
              {$ELSE}
                {$IFDEF BCB6}
    Param := '-IBCB6';
                {$ENDIF}
              {$ENDIF}
            {$ENDIF}
          {$ENDIF}
        {$ENDIF}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
    RunFile(FileName, 0, Param);
  end
  else
    ErrorDlg(SCnIdeBRToolNotExists);
end;

function TCnIdeBRWizard.GetCaption: string;
begin
  Result := SCnIdeBRWizardMenuCaption;
end;

function TCnIdeBRWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnIdeBRWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnIdeBRWizard.GetHint: string;
begin
  Result := SCnDfm6To5WizardMenuHint;
end;

function TCnIdeBRWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnIdeBRWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnIdeBRWizardName;
  Author := SCnPack_ccRun + ';' + SCnPack_LiuXiao;
  Email := SCnPack_ccRunEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnIdeBRWizardComment;
end;

initialization
  RegisterCnWizard(TCnIdeBRWizard); // ע��ר��

{$ENDIF CNWIZARDS_CNIDEBRWIZARD}
end.
