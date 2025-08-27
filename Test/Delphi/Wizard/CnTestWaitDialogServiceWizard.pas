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

unit CnTestWaitDialogServiceWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����� 10.4.2 �������� WaitDialogService ��ר��
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫֻ���� 10.4.2 �����ϰ汾�б��롣
* ����ƽ̨��Win10 + Delphi 10.4.2
* ���ݲ��ԣ�
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2021.03.15 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon,
  CnWizCompilerConst, CnWizMethodHook;

type

//==============================================================================
// ���� 10.4.2 �������� WaitDialogService ��ר��
//==============================================================================

{ TCnTestWaitDialogServiceWizard }

  TCnTestWaitDialogServiceWizard = class(TCnSubMenuWizard)
  private
    FDesignIdeHandle: THandle;
    FHook: TCnMethodHook;
    FIdShowWaitDialogServiceState: Integer;
    FIdWaitDialogShow: Integer;
    FIdWaitDialogClose: Integer;
    FIdHookWaitDialogShow: Integer;
    FIdUnHookWaitDialogShow: Integer;
    procedure HookShow;
    procedure UnhookShow;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;

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

const
  SCnWaitDialogShow = '@Waitdialog@TIDEWaitDialog@Show$qqrx20System@UnicodeStringt1o';

type
  TCnWaitDialogShowProc = procedure (ASelfClass: Pointer; const Caption: string; const TitleMessage: string; LockDrawing: Boolean);

var
  OldWaitDialogShowProc: TCnWaitDialogShowProc = nil;

procedure MyWaitDialogShow(ASelfClass: Pointer; const Caption: string; const TitleMessage: string; LockDrawing: Boolean);
begin
  // ɶ������
  CnDebugger.LogMsg('MyWaitDialogShow Called. Do Nothing.');
end;

//==============================================================================
// ���� 10.4.2 �������� WaitDialogService ��ר��
//==============================================================================

{ TCnTestWaitDialogServiceWizard }

procedure TCnTestWaitDialogServiceWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestWaitDialogServiceWizard.Create;
begin
  inherited;

end;

destructor TCnTestWaitDialogServiceWizard.Destroy;
begin
  if FDesignIdeHandle <> 0 then
    FreeLibrary(FDesignIdeHandle);

  FHook.Free;
  inherited;
end;

procedure TCnTestWaitDialogServiceWizard.AcquireSubActions;
begin
  FIdShowWaitDialogServiceState := RegisterASubAction('CnShowWaitDialogServiceState',
    'Show Wait Dialog Service State', 0, 'Show Wait Dialog Service State',
    'CnShowWaitDialogServiceState');
  FIdWaitDialogShow := RegisterASubAction('CnWaitDialogShow',
    'Show Wait Dialog', 0, 'Show Wait Dialog',
    'CnWaitDialogShow');
  FIdWaitDialogClose := RegisterASubAction('CnWaitDialogClose',
    'Close Wait Dialog', 0, 'Close Wait Dialog',
    'CnWaitDialogClose');

  FIdHookWaitDialogShow := RegisterASubAction('CnHookWaitDialogShow',
    'Hook WaitDialogShow Function', 0, 'Hook WaitDialogShow Function',
    'CnHookWaitDialogShow');
  FIdUnhookWaitDialogShow := RegisterASubAction('CnUnhookWaitDialogClose',
    'UnhHook WaitDialogShow Function', 0, 'Unhook WaitDialogShow Function',
    'CnUnhookWaitDialogClose')
end;

function TCnTestWaitDialogServiceWizard.GetCaption: string;
begin
  Result := 'Test Wait Dialog Service';
end;

function TCnTestWaitDialogServiceWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestWaitDialogServiceWizard.GetHint: string;
begin
  Result := 'Test Wait Dialog Service';
end;

function TCnTestWaitDialogServiceWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestWaitDialogServiceWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Wait Dialog Service Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Wait Dialog Service Wizard';
end;

procedure TCnTestWaitDialogServiceWizard.HookShow;
begin
  if FHook = nil then
  begin
    FDesignIdeHandle := LoadLibrary(DesignIdeLibName);
    OldWaitDialogShowProc := GetBplMethodAddress(GetProcAddress(FDesignIdeHandle, SCnWaitDialogShow));

    FHook := TCnMethodHook.Create(@OldWaitDialogShowProc, @MyWaitDialogShow);
  end;
  FHook.HookMethod;
  ShowMessage('Hooked.');
end;

procedure TCnTestWaitDialogServiceWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestWaitDialogServiceWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestWaitDialogServiceWizard.SubActionExecute(Index: Integer);
var
  WD: IOTAIDEWaitDialogServices;
begin
  if not Active then Exit;
  if not Supports(BorlandIDEServices, IOTAIDEWaitDialogServices, WD) then
    Exit;

  if Index = FIdShowWaitDialogServiceState then
  begin
    CnDebugger.LogFmt('WaitDialogService: Visible %d, InputEnabled %d.',
      [Integer(WD.IsVisible), Integer(WD.IsInputEnabled)]);
    CnDebugger.LogInterface(WD);
    CnDebugger.EvaluateInterfaceInstance(WD);
  end
  else if Index = FIdWaitDialogShow then
    WD.Show('Test Caption', 'Test Message')
  else if Index = FIdWaitDialogClose then
    WD.CloseDialog
  else if Index = FIdHookWaitDialogShow then
    HookShow
  else if Index = FIdUnHookWaitDialogShow then
    UnHookShow;
end;

procedure TCnTestWaitDialogServiceWizard.SubActionUpdate(Index: Integer);
begin 

end;

procedure TCnTestWaitDialogServiceWizard.UnhookShow;
begin
  if FHook <> nil then
  begin
    FHook.UnhookMethod;
    ShowMessage('UnHooked.');
  end;
end;

initialization
  RegisterCnWizard(TCnTestWaitDialogServiceWizard); // ע��ר��

end.
