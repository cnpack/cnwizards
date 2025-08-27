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

unit CnTestEditPosMoveWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����Ա༭���в����ַ������Ӳ˵�ר�Ҳ��Ե�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�����ڱ༭���в����ַ������� Ansi/Utf8/Unicode ���֡�
* ����ƽ̨��Win7 + Delphi 5.01
* ���ݲ��ԣ�Win7 + D5/2007/2009
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.04.21 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon;

type

//==============================================================================
// ���Ա༭�� EditPosition �ƶ����Ӳ˵�ר��
//==============================================================================

{ TCnTestEditPosMoveWizard }

  TCnTestEditPosMoveWizard = class(TCnSubMenuWizard)
  private
    FIdCnOtaGotoEditPosAndRepaint: Integer;
    FIdMove: Integer;
    FIdMoveReal: Integer;
    FIdMoveRelative: Integer;
    FIdDelete: Integer;
    FIdBackspaceDelete: Integer;
    FIdDeSelectionBegin: Integer;
    FIdDeSelectionEnd: Integer;
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

//==============================================================================
// ���Ա༭�� EditPosition �ƶ����Ӳ˵�ר��
//==============================================================================

{ TCnTestEditPosMoveWizard }

procedure TCnTestEditPosMoveWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestEditPosMoveWizard.Create;
begin
  inherited;

end;

procedure TCnTestEditPosMoveWizard.AcquireSubActions;
begin
  FIdCnOtaGotoEditPosAndRepaint := RegisterASubAction('CnOtaGotoEditPosAndRepaint',
    'Test CnOtaGotoEditPosAndRepaint', 0, 'Test CnOtaGotoEditPosAndRepaint',
    'CnOtaGotoEditPosAndRepaint');
  FIdMove := RegisterASubAction('CnTestEditPositionMove',
    'Test EditPosition Move', 0, 'Test EditPosition Move',
    'CnTestEditPositionMove');
  FIdMoveReal := RegisterASubAction('CnTestEditPositionMoveReal',
    'Test EditPosition MoveReal', 0, 'Test EditPosition MoveReal',
    'CnTestEditPositionMoveReal');
  FIdMoveRelative := RegisterASubAction('CnTestEditPositionMoveRelative',
    'Test EditPosition MoveRelative', 0, 'Test EditPosition MoveRelative',
    'CnTestEditPositionMoveRelative');
  FIdDelete := RegisterASubAction('CnTestEditPositionDelete',
    'Test EditPosition Delete', 0, 'Test EditPosition Delete',
    'CnTestEditPositionDelete');
  FIdBackspaceDelete := RegisterASubAction('CnTestEditPositionBackspaceDelete',
    'Test EditPosition BackspaceDelete', 0, 'Test EditPosition BackspaceDelete',
    'CnTestEditPositionBackspaceDelete');

  AddSepMenu;
  FIdDeSelectionBegin := RegisterASubAction('CnTestEditViewDeSelectionBegin',
    'Test EditView DeSelection Begin', 0, 'Test EditView DeSelection Begin',
    'CnTestEditViewDeSelectionBegin');
  FIdDeSelectionEnd := RegisterASubAction('CnTestEditViewDeSelectionEnd',
    'Test EditView DeSelection End', 0, 'Test EditView DeSelection End',
    'CnTestEditViewDeSelectionEnd');
end;

function TCnTestEditPosMoveWizard.GetCaption: string;
begin
  Result := 'Test EditPosition Move';
end;

function TCnTestEditPosMoveWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEditPosMoveWizard.GetHint: string;
begin
  Result := 'Test EditPosition Move';
end;

function TCnTestEditPosMoveWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditPosMoveWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test EditPosition Move Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test EditPosition Move Wizard';
end;

procedure TCnTestEditPosMoveWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditPosMoveWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditPosMoveWizard.SubActionExecute(Index: Integer);
var
  S: string;
  Line, Col: Integer;
  EditView: IOTAEditView;
  EditPosition: IOTAEditPosition;
begin
  if not Active then Exit;

  if Index = FIdDeSelectionBegin then
  begin
    CnOtaDeSelection(False);
    Exit;
  end
  else if Index = FIdDeSelectionEnd then
  begin
    CnOtaDeSelection(True);
    Exit;
  end;

  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  Line := EditView.CursorPos.Line;
  S := CnInputBox('Enter Column', 'Enter Column Value:', '3');
  Col := StrToIntDef(S, 3);

  if Index = FIdCnOtaGotoEditPosAndRepaint then
  begin
    CnOtaGotoEditPosAndRepaint(EditView, Line, Col);
  end
  else
  begin
    EditPosition := CnOtaGetEditPosition;
    if Assigned(EditPosition) then
    begin
      if Index = FIdMove then
        EditPosition.Move(Line, Col)
      else if Index = FIdMoveReal then
        EditPosition.MoveReal(Line, Col)
      else if Index = FIdMoveRelative then
        EditPosition.MoveRelative(0, Col)
      else if Index = FIdDelete then
        EditPosition.Delete(Col)
      else if Index = FIdBackspaceDelete then
        EditPosition.BackspaceDelete(Col);

      EditView.Paint;
    end;
  end;
end;

procedure TCnTestEditPosMoveWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestEditPosMoveWizard); // ע��ר��

end.
