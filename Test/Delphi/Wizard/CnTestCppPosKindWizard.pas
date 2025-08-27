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

unit CnTestCppPosKindWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����� CnCppCodeParser �� ParseCppCodePosInfo �Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ CnCppCodeParser �� ParseCppCodePosInfo �Բ鿴�Ƿ����˹��
            ���ڴ���λ�����͡�����ʱ��ǰ���ڴ� C/C++ �ļ����ɲ��ԡ�
* ����ƽ̨��WinXP + BCB 5/6
* ���ݲ��ԣ�PWin9X/2000/XP + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2013.07.16 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnPasCodeParser,
  CnCppCodeParser, TypInfo, mPasLex, mwBCBTokenList;

type

//==============================================================================
// ���� CnCppCodeParser �� ParseCppCodePosInfo �Ĳ˵�ר��
//==============================================================================

{ TCnTestCppPosKindWizard }

  TCnTestCppPosKindWizard = class(TCnMenuWizard)
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
// ���� CnCppCodeParser �� ParseCppCodePosInfo �Ĳ˵�ר��
//==============================================================================

{ TCnTestCppPosKindWizard }

procedure TCnTestCppPosKindWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestCppPosKindWizard.Execute;
var
  Stream: TMemoryStream;
  View: IOTAEditView;
  CurrPos: Integer;
  PosInfo: TCodePosInfo;
begin
  View := CnOtaGetTopMostEditView;
  if not Assigned(View) then
    Exit;

  Stream := TMemoryStream.Create;
  CurrPos := CnOtaGetCurrLinearPos(View.Buffer);
  CnDebugger.LogMsg('CurrPos: ' + IntToStr(CurrPos));
  
  CnOtaSaveCurrentEditorToStream(Stream, False, False);
  // ���� C++ �ļ����жϹ��������λ������
  PosInfo := ParseCppCodePosInfo(PAnsiChar(Stream.Memory), CurrPos, True, True);
  with PosInfo do
    CnDebugger.LogMsg(
        'CTokenID: ' + GetEnumName(TypeInfo(TCTokenKind), Ord(CTokenID)) + #13#10 +
        ' AreaKind: ' + GetEnumName(TypeInfo(TCodeAreaKind), Ord(AreaKind)) + #13#10 +
        ' PosKind: ' + GetEnumName(TypeInfo(TCodePosKind), Ord(PosKind)) + #13#10 +
        ' LineNumber: ' + IntToStr(LineNumber) + #13#10 +
        ' LinePos: ' + IntToStr(LinePos) + #13#10 +
        ' LastToken: ' + GetEnumName(TypeInfo(TTokenKind), Ord(LastNoSpace)) + #13#10 +
        ' Token: ' + string(Token));
        
  Stream.Free;
end;

function TCnTestCppPosKindWizard.GetCaption: string;
begin
  Result := 'Test ParseCppCodePosInfo';
end;

function TCnTestCppPosKindWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestCppPosKindWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestCppPosKindWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestCppPosKindWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestCppPosKindWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test CppCodePosInfo Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for ParseCppCodePosInfo under C++Builder';
end;

procedure TCnTestCppPosKindWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestCppPosKindWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestCppPosKindWizard); // ע��˲���ר��

end.
