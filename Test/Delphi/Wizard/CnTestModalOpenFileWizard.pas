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

unit CnTestModalOpenFileWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����� 10.4.2 �� ShowModal ���ڴ��ļ��ٹش���ʱ�л�ǰ��̨������
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 7 ����
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2016.04.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager,
  StdCtrls, ExtCtrls;

type
  TTestModalOpenFileForm = class(TForm)
    edtFileName: TEdit;
    btnOpenFile: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    btnOpen: TButton;
    dlgOpen1: TOpenDialog;
    procedure btnOpenFileClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//==============================================================================
// ����10.4.2 �� ShowModal ���ڴ��ļ��ٹش���ʱ�л�ǰ��̨������Ĳ�����ר��
//==============================================================================

{ TCnTestPaletteWizard }

  TCnTestModalOpenFile1042Wizard = class(TCnMenuWizard)
  private
    FTestForm: TTestModalOpenFileForm;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;

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
  CnWizIdeUtils, CnDebug;

{$R *.DFM}

//==============================================================================
// ����10.4.2 �� ShowModal ���ڴ��ļ��ٹش���ʱ�л�ǰ��̨������Ĳ�����ר��
//==============================================================================

{ TCnTestModalOpenFileWizard }

procedure TCnTestModalOpenFile1042Wizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestModalOpenFile1042Wizard.Create;
begin
  inherited;
  FTestForm := TTestModalOpenFileForm.Create(Application);
end;

procedure TCnTestModalOpenFile1042Wizard.Execute;
begin
  FTestForm.ShowModal;
  CnOtaOpenFile(FTestForm.edtFileName.Text); // �������ûɶ����
end;

function TCnTestModalOpenFile1042Wizard.GetCaption: string;
begin
  Result := 'Test ShowModal and OpenFile';
end;

function TCnTestModalOpenFile1042Wizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestModalOpenFile1042Wizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestModalOpenFile1042Wizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestModalOpenFile1042Wizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestModalOpenFile1042Wizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test ShowModal and OpenFile Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test ShowModal and OpenFile under 10.4.2';
end;

procedure TCnTestModalOpenFile1042Wizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestModalOpenFile1042Wizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TTestModalOpenFileForm.btnOpenClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
    edtFileName.Text := dlgOpen1.FileName;
end;

procedure TTestModalOpenFileForm.btnOpenFileClick(Sender: TObject);
begin
  //CnOtaOpenFile(edtFileName.Text);
  // ������������ȴ��ļ��ٹرմ��ڣ�10.4.2 �»ᵼ�´�����л�����̨
end;

initialization
  RegisterCnWizard(TCnTestModalOpenFile1042Wizard); // ע��˲���ר��

end.
