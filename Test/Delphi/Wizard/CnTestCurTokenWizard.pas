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

unit CnTestCurTokenWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Թ���µ�ǰ��ʶ�������Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ CnOtaGetCurPosToken/W �Բ鿴�Ƿ�������ȷ�Ĺ��
            ���ڴ���λ�����������֣���Ҫ�� D5/2007/2009 �Ȳ���ͨ����
* ����ƽ̨��WinXP + Delphi 5
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi All
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.03.05 V1.0
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
// ���� CnOtaGetCurrPosTokenW �����Ĳ˵�ר��
//==============================================================================

{ TCnTestCurTokenWizard }

  TCnTestCurTokenWizard = class(TCnMenuWizard)
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

//==============================================================================
// ���� CnOtaGetCurrPosTokenW �����Ĳ˵�ר��
//==============================================================================

{ TCnTestCurTokenWizard }

procedure TCnTestCurTokenWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestCurTokenWizard.Execute;
var
  Idx: Integer;
{$IFDEF IDE_STRING_ANSI_UTF8}
  W: WideString;
{$ENDIF}
  S: string;
  Res: Boolean;
begin
{$IFDEF UNICODE}
  Res := CnOtaGetCurrPosTokenW(S, Idx, True, [], [], nil, True);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  Res := CnOtaGetCurrPosTokenUtf8(W, Idx, True, [], [], nil, True);
  S := W;
  {$ELSE}
  Res := CnOtaGetCurrPosToken(S, Idx, True, [], [], nil, True);
  {$ENDIF}
{$ENDIF}

  if not Res then
    InfoDlg('No Token under Cursor.')
  else
  begin
    InfoDlg(S);
    InfoDlg(IntToStr(Idx));
  end;
end;

function TCnTestCurTokenWizard.GetCaption: string;
begin
  Result := 'Test CnOtaGetCurrPosToken/Utf8/W';
end;

function TCnTestCurTokenWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestCurTokenWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestCurTokenWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestCurTokenWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestCurTokenWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test NtaGetCurrLineText Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for CnOtaGetCurrPosToken/W under All Delphi';
end;

procedure TCnTestCurTokenWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestCurTokenWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestCurTokenWizard); // ע��˲���ר��

end.
