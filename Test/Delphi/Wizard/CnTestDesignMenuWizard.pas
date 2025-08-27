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

unit CnTestDesignMenuWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�����������Ҽ��˵����������Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��WinXP + Delphi 7
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 7 ����
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2021.04.07 V1.1
*               ����ɾ���Ҽ��˵���Ŀ
*           2015.05.20 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager;

type

//==============================================================================
// ����������Ҽ��˵����������Ĳ˵�ר��
//==============================================================================

{ TCnTestDesignMenuWizard }

  TCnTestDesignMenuWizard = class(TCnSubMenuWizard)
  private
    FIdMenu: Integer;
    FIdCreate: Integer;
    FExecutor: TCnContextMenuExecutor;
    FE1, FE2, FE3: TCnBaseMenuExecutor;
    procedure MenuExecute;
    procedure Executor2Execute(Sender: TObject);
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

    procedure AcquireSubActions; override;
    procedure SubActionExecute(Index: Integer); override;
  end;

  TCnTestDesignMenu1 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

  TCnTestDesignMenu2 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

  TCnTestDesignMenu3 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

implementation

uses
  CnDebug, CnWizIdeUtils;

const
  SCnTestDesignMenuCommand = 'CnTestDesignMenuCommand';
  SCnTestDesignMenuCaption = 'Toggle Designer Menu';
  SCnTestDesignMenuHint = 'Toggle Designer Menu';
  SCnTestDesignCreateCommand = 'CnTestDesignCreateCommand';
  SCnTestDesignCreateCaption = 'Create All Components to Form';
  SCnTestDesignCreateHint = 'Create All Components to Current Form';

//==============================================================================
// ����������Ҽ��˵����������Ĳ˵�ר��
//==============================================================================

{ TCnTestDesignMenuWizard }

procedure TCnTestDesignMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestDesignMenuWizard.MenuExecute;
begin
  if FE1 = nil then
  begin
    FE1 := TCnTestDesignMenu1.Create(Self);
    FE2 := TCnTestDesignMenu2.Create(Self);
    FE3 := TCnTestDesignMenu3.Create(Self);

    RegisterBaseDesignMenuExecutor(FE1);
    RegisterBaseDesignMenuExecutor(FE2);
    RegisterBaseDesignMenuExecutor(FE3);

    ShowMessage('3 Menu Items Registered using TCnBaseMenuExecutor.' + #13#10
      + '1 Hidden, 1 Disabled and 1 Enabled. Please Check Designer Context Menu.');
  end
  else
  begin
    UnregisterBaseDesignMenuExecutor(FE1);
    UnregisterBaseDesignMenuExecutor(FE2);
    UnregisterBaseDesignMenuExecutor(FE3);
    FE1 := nil;
    FE2 := nil;
    FE3 := nil;

    ShowMessage('3 Menu Items UnRegistered using TCnBaseMenuExecutor.');
  end;

  if FExecutor = nil then
  begin
    FExecutor := TCnContextMenuExecutor.Create;
    FExecutor.Active := True;
    FExecutor.Enabled := True;
    FExecutor.Caption := '2 Caption';
    FExecutor.Hint := '2 Hint';
    FExecutor.OnExecute := Executor2Execute;
    RegisterDesignMenuExecutor(FExecutor);
  end
  else
  begin
    UnregisterDesignMenuExecutor(FExecutor);
    FExecutor := nil;
  end;
end;

procedure TCnTestDesignMenuWizard.Executor2Execute(Sender: TObject);
begin
  ShowMessage('Executor 2 Run Here.');
end;

function TCnTestDesignMenuWizard.GetCaption: string;
begin
  Result := 'Test Designer Menu';
end;

function TCnTestDesignMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestDesignMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestDesignMenuWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestDesignMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestDesignMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Designer Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Designer Context Menu';
end;

procedure TCnTestDesignMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestDesignMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestDesignMenuWizard.SubActionExecute(Index: Integer);
var
  I, Suc, Fail: Integer;
  C: TStringList;
  FormEditor: IOTAFormEditor;
  Res: IOTAComponent;
{$IFDEF COMPILER6_UP}
  Root: TPersistent;
  OldGroup: TPersistentClass;
{$ENDIF}
begin
  if Index = FIdMenu then
    MenuExecute
  else if Index = FIdCreate then
  begin
    C := TStringList.Create;
    try
      GetInstalledComponents(nil, C);
      FormEditor := CnOtaGetCurrentFormEditor;
      if FormEditor <> nil then
      begin
        ShowMessage(Format('Will Create %d Components', [C.Count]));

{$IFDEF COMPILER6_UP}
        OldGroup := nil;
        if FormEditor.GetSelComponent(0) <> nil then
        begin
          Root := TPersistent(FormEditor.GetSelComponent(0).GetComponentHandle);
          if Root <> nil then
            OldGroup := ActivateClassGroup(TPersistentClass(Root.ClassType));
        end;
{$ENDIF}

        Suc := 0;
        Fail := 0;

        for I := 0 to C.Count - 1 do
        begin
          Res := nil;
          try
            CnDebugger.LogMsg('TestDesign To Create ' + C[I]);
            Res := FormEditor.CreateComponent(nil, C[I], 0, 0, 0, 0);
          except
            ;
          end;

          if Res <> nil then
            Inc(Suc)
          else
            Inc(Fail);
        end;

{$IFDEF COMPILER6_UP}
      if OldGroup <> nil then
        ActivateClassGroup(OldGroup);
{$ENDIF}

        ShowMessage(Format('Create %d Success. %d Fail.', [Suc, Fail]));
      end;
    finally
      C.Free;
    end;
  end;
end;

procedure TCnTestDesignMenuWizard.AcquireSubActions;
begin
  FIdMenu := RegisterASubAction(SCnTestDesignMenuCommand, SCnTestDesignMenuCaption,
    0, SCnTestDesignMenuHint, SCnTestDesignMenuCommand);
  FIdCreate := RegisterASubAction(SCnTestDesignCreateCommand, SCnTestDesignCreateCaption,
    0, SCnTestDesignCreateHint, SCnTestDesignCreateCommand);
end;

{ TCnTestDesignMenu1 }

function TCnTestDesignMenu1.Execute: Boolean;
begin
  ShowMessage('Should NOT Run Here.');
  Result := True;
end;

function TCnTestDesignMenu1.GetActive: Boolean;
begin
  Result := False;
end;

function TCnTestDesignMenu1.GetCaption: string;
begin
  Result := 'Hidden Caption - ' + DateTimeToStr(Now);
end;

function TCnTestDesignMenu1.GetEnabled: Boolean;
begin
  Result := True;
end;

{ TCnTestDesignMenu2 }

function TCnTestDesignMenu2.Execute: Boolean;
begin
  ShowMessage('Should NOT Run Here.');
  Result := True;
end;

function TCnTestDesignMenu2.GetActive: Boolean;
begin
  Result := True;
end;

function TCnTestDesignMenu2.GetCaption: string;
begin
  Result := 'Disabled Caption - ' + DateTimeToStr(Now);
end;

function TCnTestDesignMenu2.GetEnabled: Boolean;
begin
  Result := False;
end;

{ TCnTestDesignMenu3 }

function TCnTestDesignMenu3.Execute: Boolean;
begin
  ShowMessage('Should Run Here.');
  Result := True;
end;

function TCnTestDesignMenu3.GetActive: Boolean;
begin
  Result := True;
end;

function TCnTestDesignMenu3.GetCaption: string;
begin
  Result := 'Enabled Caption - ' + DateTimeToStr(Now);
end;

function TCnTestDesignMenu3.GetEnabled: Boolean;
begin
  Result := True;
end;

initialization
  RegisterCnWizard(TCnTestDesignMenuWizard); // ע��˲���ר��

end.
