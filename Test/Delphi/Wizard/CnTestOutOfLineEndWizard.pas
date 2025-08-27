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

unit CnTestOutOfLineEndWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestOutOfLineEndWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2016.04.24 V1.0
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
// CnTestOutOfLineEndWizard �˵�ר��
//==============================================================================

{ TCnTestOutOfLineEndWizard }

  TCnTestOutOfLineEndWizard = class(TCnMenuWizard)
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

//==============================================================================
// CnTestOutOfLineEndWizard �˵�ר��
//==============================================================================

{ TCnTestOutOfLineEndWizard }

procedure TCnTestOutOfLineEndWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestOutOfLineEndWizard.Execute;
var
  View: IOTAEditView;
  Text, S: string;
  OutOf: Boolean;
  EdPos: TOTAEditPos;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  EdPos := View.CursorPos;
  OutOf := CnOtaIsEditPosOutOfLine(EdPos, View);
  Text := CnOtaGetLineText(EdPos.Line);

  if OutOf then
    S := Format('Out! Line %d Col %d Text:'#13#10#13#10, [EdPos.Line, EdPos.Col]) + Text
  else
    S := Format('No! Line %d Col %d Text:'#13#10#13#10, [EdPos.Line, EdPos.Col]) + Text;

  S := S + #13#10#13#10 + 'Text Length is ' + IntToStr(Length(AnsiString(Text)));
  ShowMessage(S);
end;

function TCnTestOutOfLineEndWizard.GetCaption: string;
begin
  Result := 'Test Out of Line End';
end;

function TCnTestOutOfLineEndWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestOutOfLineEndWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestOutOfLineEndWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestOutOfLineEndWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestOutOfLineEndWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Out of Line End Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Out of Line End';
end;

procedure TCnTestOutOfLineEndWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestOutOfLineEndWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestOutOfLineEndWizard); // ע��˲���ר��

end.
