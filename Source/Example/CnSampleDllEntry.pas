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

unit CnSampleDllEntry;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizard ר�� DLL ���ʾ����Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2019.01.21 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

uses
  SysUtils, Classes, Menus, ImgList, Dialogs, ToolsAPI;

// ר�� DLL ��ʼ����ں���
function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
{* ר�� DLL ��ʼ����ں���}

exports
  InitWizard name WizardEntryPoint;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  InvalidIndex = -1;

type
  TSampleWizard = class(TNotifierObject, IOTAWizard)
  private
    FMenu: TMenuItem;
    procedure MenuClick(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;

    // IOTAWizard methods
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
  end;

var
  FWizardIndex: Integer = InvalidIndex;
  SampleWizard: TSampleWizard = nil;

// ר�� DLL �ͷŹ���
procedure FinalizeWizard;
var
  WizardServices: IOTAWizardServices;
begin
  if FWizardIndex <> InvalidIndex then
  begin
    Assert(Assigned(BorlandIDEServices));
    WizardServices := BorlandIDEServices as IOTAWizardServices;
    Assert(Assigned(WizardServices));
{$IFDEF DEBUG}
    CnDebugger.LogMsg('SampleWizard Remove at ' + IntToStr(FWizardIndex));
{$ENDIF}
    WizardServices.RemoveWizard(FWizardIndex);
    FWizardIndex := InvalidIndex;
  end;
end;

// ר�� DLL ��ʼ����ں���
function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
var
  WizardServices: IOTAWizardServices;
  AWizard: IOTAWizard;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Sample Wizard Dll Entry');
{$ENDIF}

  Result := BorlandIDEServices <> nil;
  if Result then
  begin
    Assert(ToolsAPI.BorlandIDEServices = BorlandIDEServices);
    Terminate := FinalizeWizard;
    WizardServices := BorlandIDEServices as IOTAWizardServices;
    Assert(Assigned(WizardServices));

    SampleWizard := TSampleWizard.Create;
    if Supports(TObject(SampleWizard), IOTAWizard, AWizard) then
    begin
      FWizardIndex := WizardServices.AddWizard(AWizard);
      Result := (FWizardIndex >= 0);
{$IFDEF DEBUG}
      CnDebugger.LogBoolean(Result, 'SampleWizard Registered at ' + IntToStr(FWizardIndex));
{$ENDIF}
    end
    else
    begin
      Result := True;
{$IFDEF DEBUG}
      CnDebugger.LogBoolean(Result, 'SampleWizard Created');
{$ENDIF}
    end;
  end;
end;

function GetIDEMainMenu: TMainMenu;
var
  Svcs40: INTAServices40;
begin
  if Supports(BorlandIDEServices, INTAServices40, Svcs40) then
    Result := Svcs40.MainMenu
  else
    Result := nil;
end;

function GetIDEImageList: TCustomImageList;
var
  Svcs40: INTAServices40;
begin
  if Supports(BorlandIDEServices, INTAServices40, Svcs40) then
    Result := Svcs40.ImageList
  else
    Result := nil;
end;

{ TSampleWizard }

constructor TSampleWizard.Create;
var
  MainMenu: TMainMenu;
begin
  inherited;
  FMenu := TMenuItem.Create(nil);
  FMenu.Name := 'CnPackSampleMenuItem';
  FMenu.Caption := 'CnPackSample';
  FMenu.AutoHotkeys := maManual;
  FMenu.OnClick := MenuClick;

  MainMenu := GetIDEMainMenu;
  if MainMenu <> nil then
    MainMenu.Items.Add(FMenu);
end;

destructor TSampleWizard.Destroy;
begin
  FMenu.Free;
  inherited;
end;

procedure TSampleWizard.Execute;
begin

end;

function TSampleWizard.GetIDString: string;
begin
  Result := 'CnSampleWizard';
end;

function TSampleWizard.GetName: string;
begin
  Result := 'CnSampleWizardName';
end;

function TSampleWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure TSampleWizard.MenuClick(Sender: TObject);
begin
  ShowMessage('CnPack Sample Wizard Menu Item Clicked.');
end;

end.

