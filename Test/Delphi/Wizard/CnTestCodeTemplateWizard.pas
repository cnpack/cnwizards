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

unit CnTestCodeTemplateWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestCodeTemplateWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ 2006 �����ṩ�� CodeTemplateAPI.pas �ӿ�
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2016.04.24 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFNDEF OTA_CODE_TEMPLATE_API}
  {$MESSAGE ERROR 'CodeTemplateAPI NOT Supported.'}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CodeTemplateAPI, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// CnTestCodeTemplateWizard �˵�ר��
//==============================================================================

{ TCnTestCodeTemplateWizard }

  TCnTestCodeTemplateWizard = class(TCnMenuWizard)
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
// CnTestCodeTemplateWizard �˵�ר��
//==============================================================================

{ TCnTestCodeTemplateWizard }

procedure TCnTestCodeTemplateWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestCodeTemplateWizard.Execute;
var
  I: Integer;
  View: IOTAEditView;
  CT: IOTACodeTemplate;
  CTS: IOTACodeTemplateServices;

  procedure DumpCodeTemplate(Idx: Integer);
  begin
    CnDebugger.LogEnter('DumpCodeTemplate: ' + IntToStr(Idx));
    with CT do
    begin
      CnDebugger.LogFmt('ScriptCount %d', [ScriptCount]);
      CnDebugger.LogFmt('Format %s', [Format]);
      CnDebugger.LogFmt('Title %s', [Title]);
      CnDebugger.LogFmt('HelpUrl %s', [HelpUrl]);
      CnDebugger.LogFmt('Delimiter %s', [Delimiter]);
      CnDebugger.LogFmt('Kind %d', [Ord(Kind)]);
      CnDebugger.LogFmt('Language %s', [Language]);
      CnDebugger.LogFmt('EditorOpts %s', [EditorOpts]);
      CnDebugger.LogFmt('Code %s', [Code]);
      CnDebugger.LogFmt('Description %s', [Description]);
      CnDebugger.LogFmt('ReferencesCount %d', [ReferencesCount]);
      CnDebugger.LogFmt('NamespaceCount %d', [NamespaceCount]);
      CnDebugger.LogFmt('Author %s', [Author]);
      CnDebugger.LogFmt('PointsCount %d', [PointsCount]);
      CnDebugger.LogFmt('KeywordsCount %d', [KeywordsCount]);
      CnDebugger.LogFmt('Shortcut %s', [Shortcut]);
      CnDebugger.LogFmt('InvokeKind %d', [Ord(InvokeKind)]);
      CnDebugger.LogFmt('FileName %s', [FileName]);
    end;
    CnDebugger.LogLeave('DumpCodeTemplate: ' + IntToStr(Idx));
  end;

begin
  // CTS := BorlandIDEServices as IOTACodeTemplateServices;
  if not Supports(BorlandIDEServices, IOTACodeTemplateServices, CTS) then
    Exit;

  if CTS = nil then
  begin
    ShowMessage('No IOTACodeTemplateServices');
    Exit;
  end;

  ShowMessage(IntToStr(CTS.CodeObjectCount));
  for I := 0 to CTS.CodeObjectCount - 1 do
  begin
    CT := CTS.CodeObjects[I];
    DumpCodeTemplate(I);
  end;

  View := CnOtaGetTopMostEditView;
  if (View <> nil) and (CTS.CodeObjectCount > 0) then
    CTS.InsertCode(0, View, False);
end;

function TCnTestCodeTemplateWizard.GetCaption: string;
begin
  Result := 'Test CodeTempalteAPI';
end;

function TCnTestCodeTemplateWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestCodeTemplateWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestCodeTemplateWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestCodeTemplateWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestCodeTemplateWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test CodeTempalteAPI';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Test CodeTempalteAPI under 2006 and Above.';
end;

procedure TCnTestCodeTemplateWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestCodeTemplateWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestCodeTemplateWizard); // ע��˲���ר��

end.
