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

unit CnTestNtaCurrLineWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����� CnNtaGetCurrLineText �����Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ CnNtaGetCurrLineText �Բ鿴�Ƿ�������ȷ�Ĺ��
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
// ���� CnNtaGetCurrLineText �����Ĳ˵�ר��
//==============================================================================

{ TCnTestNtaCurrLineWizard }

  TCnTestNtaCurrLineWizard = class(TCnMenuWizard)
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
// ���� CnNtaGetCurrLineText �����Ĳ˵�ר��
//==============================================================================

{ TCnTestNtaCurrLineWizard }

procedure TCnTestNtaCurrLineWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestNtaCurrLineWizard.Execute;
var
  LineNo: Integer;
  CharIndex: Integer;
  LineText: string;
  EditView: IOTAEditView;
  S: string;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView <> nil then
    InfoDlg('View.CursorPos.Col - 1 = ' + IntToStr(EditView.CursorPos.Col - 1));
    
  if (EditView <> nil) and CnNtaGetCurrLineText(LineText, LineNo, CharIndex) and
    (LineText <> '') then
  begin
    S := Format('Get Text at Line %d and CharIndex is %d.', [LineNo, CharIndex]);
    S := S + #13#10#13#10 + '''';
    // Insert('|', LineText, CharIndex);
    // LineText ����ת���� AnsiString ���� UTF8 ���루���UTF8������������ܺ� CharIndex ���Ϻ�
    
    S := S + LineText + '''';
    InfoDlg(S);
  end
  else
  begin
    ErrorDlg('Can NOT NtaGetCurrLineText');
    Exit;
  end;

  if (EditView <> nil) and CnOtaGetCurrPosToken(S, CharIndex) then
    InfoDlg(Format('Current Token Under Cursor is: %s. Offset %d.', [S, CharIndex]))
  else
    ErrorDlg('Can NOT OtaGetCurrPosToken');
end;

function TCnTestNtaCurrLineWizard.GetCaption: string;
begin
  Result := 'Test NtaGetCurrLineText';
end;

function TCnTestNtaCurrLineWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestNtaCurrLineWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestNtaCurrLineWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestNtaCurrLineWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestNtaCurrLineWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test NtaGetCurrLineText Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for NtaGetCurrLineText under All Delphi';
end;

procedure TCnTestNtaCurrLineWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestNtaCurrLineWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestNtaCurrLineWizard); // ע��˲���ר��

end.
