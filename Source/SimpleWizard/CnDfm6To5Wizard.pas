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

unit CnDfm6To5Wizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��� Delphi5 �д� D6 ����ר��
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2004.08.22 V1.1
*               �޸� PAS��CPP ��չ��ΪСд
*           2002.11.17 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNDFM6TO5WIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnConsts;

type

//==============================================================================
// �� Delphi5 �д� D6 ����ר��
//==============================================================================

{ TCnDfm6To5Wizard }

  TCnDfm6To5Wizard = class(TCnMenuWizard)
  private
  
  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNDFM6TO5WIZARD}

implementation

{$IFDEF CNWIZARDS_CNDFM6TO5WIZARD}

uses
  CnWizDfm6To5, CnCommon;

//==============================================================================
// �� Delphi5 �д� D6 ����ר��
//==============================================================================

{ TCnDfm6To5Wizard }

procedure TCnDfm6To5Wizard.Execute;
var
  OpenDialog: TOpenDialog;
  I: Integer;
  Fn: string;
  ActionSvcs: IOTAActionServices;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    with OpenDialog do
    begin
      DefaultExt := 'dfm';
      FilterIndex := 1;
      Filter := 'Delphi/C++Builder Form (*.dfm)|*.dfm';
      Options := [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing];
      Title := 'Open';
    end;

    if OpenDialog.Execute then
    begin
      QuerySvcs(BorlandIDEServices, IOTAActionServices, ActionSvcs);
      for I := 0 to OpenDialog.Files.Count - 1 do
      begin
        if IsDfm(OpenDialog.Files[I]) then
        begin
          case DFM6To5(OpenDialog.Files[I]) of
            crSucc:
              begin
                Fn := _CnChangeFileExt(OpenDialog.Files[I], '.pas');   // ��ص� Pas �ļ�
                if not FileExists(Fn) then
                  Fn := _CnChangeFileExt(OpenDialog.Files[I], '.cpp'); // ��ص� Cpp �ļ�
                if not FileExists(Fn) then
                  Fn := OpenDialog.Files[I]; // û����صĵ�Ԫ�ļ����򿪴��屾��
                ActionSvcs.CloseFile(Fn);    // �ȹر���ص�Ԫ
                ActionSvcs.OpenFile(Fn);     // �����´�
              end;
            crOpenError:
              ErrorDlg(Format(SCnDfm6To5OpenError, [OpenDialog.Files[I]]));
            crSaveError:
              ErrorDlg(Format(SCnDfm6To5SaveError, [OpenDialog.Files[I]]));
            crInvalidFormat:
              ErrorDlg(Format(SCnDfm6To5InvalidFormat, [OpenDialog.Files[I]]))
          end;
        end;
      end;
    end;
  finally
    OpenDialog.Free;
  end;
end;

function TCnDfm6To5Wizard.GetCaption: string;
begin
  Result := SCnDfm6To5WizardMenuCaption;
end;

function TCnDfm6To5Wizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnDfm6To5Wizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnDfm6To5Wizard.GetHint: string;
begin
  Result := SCnDfm6To5WizardMenuHint;
end;

function TCnDfm6To5Wizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + 'dfm,';
end;

function TCnDfm6To5Wizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnDfm6To5Wizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnDfm6To5WizardName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnDfm6To5WizardComment;
end;

initialization

{$IFDEF COMPILER5}
  RegisterCnWizard(TCnDfm6To5Wizard); // ���� Delphi5/BCB5 �²�ע���ר��
{$ENDIF}

{$ENDIF CNWIZARDS_CNDFM6TO5WIZARD}
end.
