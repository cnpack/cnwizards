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

unit CnTestIDEOptionWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����� IDE ѡ����Ӳ˵�ר�Ҳ��Ե�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ���� Lazarus �е� IDE ѡ�
* ����ƽ̨��Win7 + Lazarus 4
* ���ݲ��ԣ�Win7 + Lazarus 4
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.09.04 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon, CnWideStrings,
  SrcEditorIntf, LazIDEIntf, IDEOptEditorIntf, IDEOptionsIntf, CompOptsIntf;

type

//==============================================================================
// ���� IDE ѡ����Ӳ˵�ר��
//==============================================================================

{ TCnTestIDEOptionWizard }

  TCnTestIDEOptionWizard = class(TCnSubMenuWizard)
  private
    FIdPrintIDEGroup: Integer;
    FIdPrintEditorOption: Integer;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// ���� IDE ѡ����Ӳ˵�ר��
//==============================================================================

{ TCnTestIDEOptionWizard }

procedure TCnTestIDEOptionWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestIDEOptionWizard.Create;
begin
  inherited;

end;

procedure TCnTestIDEOptionWizard.AcquireSubActions;
begin
  FIdPrintIDEGroup := RegisterASubAction('CnLazPrintIDEGroup',
    'Test CnLazPrintIDEGroup', 0, 'Test CnLazPrintIDEGroup',
    'CnLazPrintIDEGroup');
  FIdPrintEditorOption := RegisterASubAction('CnLazPrintEditorOption',
    'Test CnLazPrintEditorOption', 0, 'Test CnLazPrintEditorOption',
    'CnLazPrintEditorOption');
end;

function TCnTestIDEOptionWizard.GetCaption: string;
begin
  Result := 'Test IDE Option';
end;

function TCnTestIDEOptionWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestIDEOptionWizard.GetHint: string;
begin
  Result := 'Test IDE Option Wizard';
end;

function TCnTestIDEOptionWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestIDEOptionWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test IDE Option Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test IDE Option Wizard';
end;

procedure TCnTestIDEOptionWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestIDEOptionWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestIDEOptionWizard.SubActionExecute(Index: Integer);
var
  I: Integer;
  Rec: PIDEOptionsGroupRec;

  procedure PrintEditorRecs(ARec: PIDEOptionsEditorRec; Indent: Integer);
  begin
    CnDebugger.TraceFmt('%sIndex %d Editor %s', [StringOfChar(' ', Indent),
      ARec^.Index, ARec^.EditorClass.ClassName]);
  end;

  procedure PrintGroupRecs(ARec: PIDEOptionsGroupRec; Indent: Integer);
  var
    J: Integer;
  begin
    CnDebugger.TraceFmt('%sIndex %d Group %s', [StringOfChar(' ', Indent), ARec^.Index, ARec^.GroupClass.ClassName]);
    if ARec^.Items <> nil then
    begin
      for J := 0 to ARec^.Items.Count - 1 do
        PrintEditorRecs(ARec^.Items[J], Indent + 4);
    end;
  end;

begin
  if not Active then Exit;

  if Index = FIdPrintIDEGroup then
  begin
    CnDebugger.TraceMsg('IDEEditorGroups Count ' + IntToStr(IDEEditorGroups.Count));
    for I := 0 to IDEEditorGroups.Count - 1 do
    begin
      Rec := IDEEditorGroups[I];
      PrintGroupRecs(Rec, 0);
    end;
  end
  else if Index = FIdPrintEditorOption then
  begin
    CnDebugger.TraceMsg('IDEEditorOptions TabPosition ' + IntToStr(Ord(IDEEditorOptions.TabPosition)));
    CnDebugger.TraceMsg('IDEEditorOptions ClassName ' + IDEEditorOptions.ClassName);
    if IDEEditorOptions.GetInstance <> nil then
      CnDebugger.TraceMsg('IDEEditorOptions GetInstance ClassName ' + IDEEditorOptions.GetInstance.ClassName);

    CnDebugger.EvaluateObject(IDEEditorOptions);
  end;
end;

procedure TCnTestIDEOptionWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestIDEOptionWizard); // ע��ר��

end.
