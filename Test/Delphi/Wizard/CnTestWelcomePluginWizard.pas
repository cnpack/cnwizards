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

unit CnTestWelcomePluginWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��򵥵�ר����ʾ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�������� ToolsAPI.WelcomePage���� D120A ��������Ч
* ����ƽ̨��PWin11 + Delphi 12
* ���ݲ��ԣ�PWin11 + Delphi 12
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.05.02 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ToolsAPI, IniFiles, Grids, TypInfo, Clipbrd, ToolsAPI.WelcomePage,
  CnCommon, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// ��ӭҳ�����Ӳ˵�ר��
//==============================================================================

{ TCnTestWelcomePluginWizard }

  TCnTestWelcomePluginWizard = class(TCnSubMenuWizard)
  private
    FIdDumpWelcomes: Integer;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

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

implementation

uses
  CnDebug;

const
  SCnDumpWelcomeCommand = 'CnDumpWelcomeCommand';

  SCnDumpWelcomeCaption = 'Show Welcome Plugins';

//==============================================================================
// ��ӭҳ�����Ӳ˵�ר��
//==============================================================================

{ TCnTestWelcomePluginWizard }

procedure TCnTestWelcomePluginWizard.AcquireSubActions;
begin
  FIdDumpWelcomes := RegisterASubAction(SCnDumpWelcomeCommand, SCnDumpWelcomeCaption);
end;

procedure TCnTestWelcomePluginWizard.Config;
begin

end;

function TCnTestWelcomePluginWizard.GetCaption: string;
begin
  Result := 'Test Welcome Page';
end;

function TCnTestWelcomePluginWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestWelcomePluginWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestWelcomePluginWizard.GetHint: string;
begin
  Result := 'Test Welcome Page';
end;

function TCnTestWelcomePluginWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestWelcomePluginWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Welcome Page Menu Wizard';
  Author := 'CnPack Team';
  Email := 'liuxiao@cnpack.org';
  Comment := 'Test Welcome Page Menu Wizard';
end;

procedure TCnTestWelcomePluginWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestWelcomePluginWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestWelcomePluginWizard.SubActionExecute(Index: Integer);
var
  I: Integer;
begin
  if Index = FIdDumpWelcomes then
  begin
    ShowMessage(IntToStr(WelcomePagePluginService.PluginCount));
    for I := 0 to WelcomePagePluginService.PluginCount - 1 do
    begin
      ShowMessage(WelcomePagePluginService.PluginID[I]);
    end;
  end;
end;

constructor TCnTestWelcomePluginWizard.Create;
begin
  inherited;

end;

destructor TCnTestWelcomePluginWizard.Destroy;
begin

  inherited;
end;

initialization
  RegisterCnWizard(TCnTestWelcomePluginWizard); // ע��ר��

end.
