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

unit CnWizAbout;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�ר�Ұ����������ڵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.02.20 V1.2
*               ����ÿ��һ��
*           2004.03.24 V1.1
*               ����ÿ��һ��
*           2003.04.29 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF DEBUG}
{$IFDEF WIN64}
{$IFNDEF SUPPORT_PASCAL_SCRIPT}
  // 64 λ�� Debug ״̬�£�û�ű�֧�ֵĻ��ͼ�һ���ڲ��鿴��������ʹ��
  {$DEFINE CN_INTERNAL_EVAL}
{$ENDIF}
{$ENDIF}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, IniFiles, Menus, Forms, Controls,
  {$IFDEF FPC} LCLProc, {$ENDIF}
  CnConsts, CnWizClasses, CnWizManager, CnWizConsts, CnWizUtils, CnCommon,
  CnWizOptions, CnWizIdeUtils;

type

{$IFDEF DEBUG}

  TCnEvaluationExecutor = class(TCnContextMenuExecutor)
  {* ���һ��ѡ������Ĳ鿴�˵���}
  public
    function GetActive: Boolean; override;
    function GetCaption: string; override;
  end;

{$ENDIF}

{ TCnWizAbout }

  TCnWizAbout = class(TCnSubMenuWizard)
  private
    FIdHelp: Integer;
    FIdHistory: Integer;
    FIdTipOfDay: Integer;
    FIdBugReport: Integer;
    FIdUpgrade: Integer;
    FIdConfigIO: Integer;
    FIdUrl: Integer;
    FIdBbs: Integer;
    FIdMail: Integer;
    FIdDonate: Integer;
{$IFDEF CN_INTERNAL_EVAL}
    FIdEval: Integer;
{$ENDIF}
    FIdAbout: Integer;
{$IFDEF DELPHI_OTA}
{$IFDEF DEBUG}
    FEvaluationExecutor: TCnEvaluationExecutor;
    procedure EvalExecute(Sender: TObject);
{$ENDIF}
{$ENDIF}
  protected
    procedure ConfigIO;
    procedure SubActionExecute(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure AcquireSubActions; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    class function IsInternalWizard: Boolean; override;

    function GetCaption: string; override;
    function GetHint: string; override;
  end;

implementation

uses
  CnWizAboutFrm, CnWizFeedbackFrm, CnWizUpgradeFrm, CnWizTipOfDayFrm
  {$IFDEF DEBUG}, CnDebug {$ENDIF};

{ TCnWizAbout }

procedure TCnWizAbout.ConfigIO;
var
  FileName: string;
begin
  FileName := WizOptions.DllPath + SCnConfigIOName;
  if FileExists(FileName) then
    RunFile(FileName)
  else
    ErrorDlg(SCnConfigIONotExists);
end;

constructor TCnWizAbout.Create;
begin
  inherited;
  // ��Ϊ�� Wizard ���ᱻ Loaded���ã�����Ҫ�ֹ� AcquireSubActions;
  AcquireSubActions;

{$IFDEF DELPHI_OTA}
{$IFDEF DEBUG}
  FEvaluationExecutor := TCnEvaluationExecutor.Create;
  FEvaluationExecutor.OnExecute := EvalExecute;
  RegisterDesignMenuExecutor(FEvaluationExecutor);
{$ENDIF}
{$ENDIF}
end;

destructor TCnWizAbout.Destroy;
begin
{$IFDEF DELPHI_OTA}
{$IFDEF DEBUG}
  UnRegisterDesignMenuExecutor(FEvaluationExecutor);
  FEvaluationExecutor := nil;
{$ENDIF}
{$ENDIF}
  inherited;
end;

{$IFDEF DELPHI_OTA}
{$IFDEF DEBUG}

procedure TCnWizAbout.EvalExecute(Sender: TObject);
var
  Sel: TList;
begin
  Sel := TList.Create;
  try
    IdeGetFormSelection(Sel);
    if Sel.Count > 0 then
      CnDebugger.EvaluateObject(Sel[0])
    else
      CnDebugger.EvaluateObject(IdeGetDesignedForm);
  finally
    Sel.Free;
  end;
end;

{$ENDIF}
{$ENDIF}

procedure TCnWizAbout.AcquireSubActions;
begin
  FIdHelp := RegisterASubAction(SCnWizAboutHelp, SCnWizAboutHelpCaption, 0, SCnWizAboutHelpHint);
  FIdHistory := RegisterASubAction(SCnWizAboutHistory, SCnWizAboutHistoryCaption, 0, SCnWizAboutHistoryHint);
  FIdTipOfDay := RegisterASubAction(SCnWizAboutTipOfDay, SCnWizAboutTipOfDaysCaption, 0, SCnWizAboutTipOfDayHint, SCnWizAboutTipOfDay);
  AddSepMenu;
  FIdBugReport := RegisterASubAction(SCnWizAboutBugReport, SCnWizAboutBugReportCaption, 0, SCnWizAboutBugReportHint);
  FIdUpgrade := RegisterASubAction(SCnWizAboutUpgrade, SCnWizAboutUpgradeCaption, 0, SCnWizAboutUpgradeHint);
  FIdConfigIO := RegisterASubAction(SCnWizAboutConfigIO, SCnWizAboutConfigIOCaption, 0, SCnWizAboutConfigIOHint);
  AddSepMenu;
  FIdUrl := RegisterASubAction(SCnWizAboutUrl, SCnWizAboutUrlCaption, 0, SCnWizAboutUrlHint);
  FIdBbs := RegisterASubAction(SCnWizAboutBbs, SCnWizAboutBbsCaption, 0, SCnWizAboutBbsHint);
  FIdMail := RegisterASubAction(SCnWizAboutMail, SCnWizAboutMailCaption, 0, SCnWizAboutMailHint);
  FIdDonate := RegisterASubAction(SCnWizAboutDonate, SCnWizAboutDonateCaption, 0, SCnWizAboutDonateHint);
  AddSepMenu;
{$IFDEF CN_INTERNAL_EVAL}
  FIdEval := RegisterASubAction('CnInternalEvaluate', 'Evaluate Control Under Cursor', TextToShortCut('Alt+1'),
    '', '');
{$ENDIF}
  FIdAbout := RegisterASubAction(SCnWizAboutAbout, SCnWizAboutAboutCaption, 0, SCnWizAboutAboutHint, ClassName);
end;

function TCnWizAbout.GetCaption: string;
begin
  Result := SCnWizAboutCaption;
end;

function TCnWizAbout.GetHint: string;
begin
  Result := SCnWizAboutHint;
end;

class procedure TCnWizAbout.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin

end;

class function TCnWizAbout.IsInternalWizard: Boolean;
begin
  Result := True;
end;

procedure TCnWizAbout.SubActionExecute(Index: Integer);
begin
  if Index = FIdHelp then
    ShowHelp('Index')
  else if Index = FIdHistory then
    ShowHelp('History')
  else if Index = FIdTipOfDay then
    ShowCnWizTipOfDayForm(True)
  else if Index = FIdBugReport then
    ShowFeedbackForm
  else if Index = FIdUpgrade then
    CheckUpgrade(True)
  else if Index = FIdConfigIO then
    ConfigIO
  else if Index = FIdUrl then
    OpenUrl(SCnPackUrl)
  else if Index = FIdBbs then
    OpenUrl(SCnPackBbsUrl)
  else if Index = FIdMail then
    MailTo(SCnPackEmail, SCnWizMailSubject)
  else if Index = FIdDonate then
    ShowHelp('Donation')
{$IFDEF CN_INTERNAL_EVAL}
  else if Index = FIdEval then
    CnDebugger.EvaluateControlUnderPos(Mouse.CursorPos)
{$ENDIF}
  else if Index = FIdAbout then
    ShowCnWizAboutForm;
end;

{$IFDEF DEBUG}

{ TCnEvaluationExecutor }

function TCnEvaluationExecutor.GetActive: Boolean;
begin
  Result := True;
end;

function TCnEvaluationExecutor.GetCaption: string;
begin
  Result := 'Evaluate Selected Component';
end;

{$ENDIF}

end.

