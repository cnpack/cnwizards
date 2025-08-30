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

unit CnFastCodeWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�FastCode ר��
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע����ר��ʹ�� FastCode/FastMove ������ IDE ������
* ����ƽ̨��PWinXP SP2 + Delphi 7.1
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2006.09.25 V1.0 by zjy
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFASTCODEWIZARD}

{$IFDEF COMPILER6_UP}

uses
  Windows, SysUtils, Classes, Registry, CnWizConsts, CnConsts, CnWizClasses,
  CnWizOptions;

type

//==============================================================================
// FastCode ר��
//==============================================================================

{ TCnFastCodeWizard }

  TCnFastCodeWizard = class(TCnIDEEnhanceWizard)
  protected
    procedure SetActive(Value: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email,
      Comment: string); override;
    function GetSearchContent: string; override;
  end;

{$ENDIF}

{$ENDIF CNWIZARDS_CNFASTCODEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFASTCODEWIZARD}

{$IFDEF COMPILER6_UP}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}  
  FastMove{$IFDEF COMPILER6_UP}, CnFastCode{$ENDIF};

{ TCnFastCodeWizard }

var
  FDSUInstalled: Boolean = False;

// Check DelphiSpeedUp
function GetModuleProc(HInst: Integer; Data: Pointer): Boolean;
var
  FileName: array[0..MAX_PATH] of Char;
begin
  Result := True;
  if not FDSUInstalled then
  begin
    GetModuleFileName(HInst, FileName, MAX_PATH);
    if Pos(UpperCase('DelphiSpeedUp'), UpperCase(FileName)) > 0 then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Found DelphiSpeedUp');
    {$ENDIF}
      FDSUInstalled := True;
      Result := False;
    end;
  end;
end;

constructor TCnFastCodeWizard.Create;
begin
  inherited;
  EnumModules(GetModuleProc, nil);
end;

destructor TCnFastCodeWizard.Destroy;
begin
  inherited;
end;

procedure TCnFastCodeWizard.SetActive(Value: Boolean);
begin
  inherited;
{$IFDEF COMPILER6_UP}
  if Value and not FDSUInstalled then
    InstallFastCode
  else
    UninstallFastCode;
{$ENDIF}
end;

class procedure TCnFastCodeWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnFastCodeWizardName;
  Author := 'FastCode Project' + ';' + SCnPack_Zjy;
  Email := '' + ';' + SCnPack_ZjyEmail;
  Comment := SCnFastCodeWizardComment;
end;

function TCnFastCodeWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent;
  Result := '����,�Ż�,����,' + 'fastcode,';
end;

initialization
  RegisterCnWizard(TCnFastCodeWizard);

{$ENDIF}

{$ENDIF CNWIZARDS_CNFASTCODEWIZARD}
end.


