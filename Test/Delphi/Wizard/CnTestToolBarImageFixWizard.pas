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

unit CnTestToolBarImageFixWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��༭�������������޸� IDE ͼ����ʾ������������
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�Ǳ༭���ⲿ�������ĸ������Ե�Ԫ��BDS �����ϰ汾��ִ��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2014.09.22 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, StdCtrls, ComCtrls, TypInfo, CnWizIdeUtils, CnWizManager,
  CnWizClasses, CnWizUtils, CnWizConsts, CnEditControlWrapper;

type

//==============================================================================
// �༭���������޸�ͼ����ʾ����Ĳ˵�ר��
//==============================================================================

{ TCnTestToolBarImageFixWizard }

  TCnTestToolBarImageFixWizard = class(TCnMenuWizard)
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

    destructor Destroy; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// �༭���������޸�ͼ����ʾ����Ĳ˵�ר��
//==============================================================================

{ TCnTestToolBarImageFixWizard }

procedure TCnTestToolBarImageFixWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : �ڴ���ʾ���ô��� }
end;

destructor TCnTestToolBarImageFixWizard.Destroy;
begin
  inherited;
end;

procedure TCnTestToolBarImageFixWizard.Execute;
var
  BrowserToolbar: TToolBar;
  ToolbarParent: TWinControl;
  P: TPoint;
  Wizard: TCnBaseWizard;
begin
  BrowserToolbar := TToolBar(GetIdeMainForm.FindComponent('BrowserToolBar'));
  if BrowserToolbar <> nil then
  begin
    CnDebugger.LogFmt('BrowserToolbar Top %d Left %d Width %d Height %d',
      [BrowserToolbar.Top, BrowserToolbar.Left, BrowserToolbar.Width, BrowserToolbar.Height]);

    ToolbarParent := BrowserToolbar.Parent;
    if ToolbarParent <> nil then
    begin
    CnDebugger.LogFmt('ToolbarParent Top %d Left %d Width %d Height %d',
      [ToolbarParent.Top, ToolbarParent.Left, ToolbarParent.Width, ToolbarParent.Height]);

      P.X := 5;
      P.Y := BrowserToolbar.Height div 2;
      P := BrowserToolbar.ClientToParent(P);
      CnDebugger.LogPoint(P, 'Click in Parent.');

      Wizard := CnWizardMgr.WizardByClassName('TCnPaletteEnhanceWizard');
      if Wizard <> nil then
      try
        SetPropValue(Wizard, 'TempDisableLock', True);
      except
        CnDebugger.LogMsg('Error set TempDisableLock True');
      end;
      SendMessage(ToolbarParent.Handle, WM_LBUTTONDOWN, 0, MakeLParam(P.X, P.Y));
      SendMessage(ToolbarParent.Handle, WM_MOUSEMOVE, 0, MakeLParam(P.X + 1, P.Y));
      SendMessage(ToolbarParent.Handle, WM_MOUSEMOVE, 0, MakeLParam(P.X, P.Y));
      SendMessage(ToolbarParent.Handle, WM_LBUTTONUP, 0, MakeLParam(P.X, P.Y));
      if Wizard <> nil then
      try
        SetPropValue(Wizard, 'TempDisableLock', False);
      except
        CnDebugger.LogMsg('Error set TempDisableLock False');
      end;
    end;
  end;
end;

function TCnTestToolBarImageFixWizard.GetCaption: string;
begin
  Result := 'Fix IDE Toolbar Image';
end;

function TCnTestToolBarImageFixWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestToolBarImageFixWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestToolBarImageFixWizard.GetHint: string;
begin
  Result := 'Register an Editor ToolBar Type';
end;

function TCnTestToolBarImageFixWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestToolBarImageFixWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'TestToolBarImageFix';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Fix IDE Toolbar Image';
end;

procedure TCnTestToolBarImageFixWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestToolBarImageFixWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestToolBarImageFixWizard); // ע��ר��

end.
