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

unit CnTestToolBarWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��༭������������ר����ʾ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�Ǳ༭���ⲿ�������Ĳ��Ե�Ԫ
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2002.11.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, StdCtrls, ComCtrls,
  CnWizClasses, CnWizUtils, CnWizConsts, CnEditControlWrapper;

type

//==============================================================================
// �༭�������������ò˵�ר��
//==============================================================================

{ TCnTestToolBarWizard }

  TCnTestToolBarWizard = class(TCnMenuWizard)
  private
    FCombo: TControl;
    FRegistered: Boolean;
  protected
    function GetHasConfig: Boolean; override;
    procedure EditorChanged(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);
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

    procedure CreateToolBar(const ToolBarType: string; EditControl: TControl;
      ToolBar: TToolBar);
    procedure InitToolBar(const ToolBarType: string; EditControl: TControl;
      ToolBar: TToolBar);
  end;

implementation

uses
  CnSrcEditorToolBar;

//==============================================================================
// �༭�������������ò˵�ר��
//==============================================================================

{ TCnTestToolBarWizard }

procedure TCnTestToolBarWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : �ڴ���ʾ���ô��� }
end;

procedure TCnTestToolBarWizard.CreateToolBar(const ToolBarType: string;
  EditControl: TControl; ToolBar: TToolBar);
begin
  if ToolBar <> nil then
  begin
    FCombo := TComboBox.Create(ToolBar as TComponent);
    FCombo.Parent := ToolBar as TWinControl;

    (ToolBar as TControl).Top := 50;
  end;
end;

destructor TCnTestToolBarWizard.Destroy;
begin
  if FRegistered then
    EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  inherited;
end;

procedure TCnTestToolBarWizard.EditorChanged(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
var
  S: string;
begin
  if ChangeType * [ctView, ctWindow, ctCurrLine, ctCurrCol, ctModified] <> [] then
  begin
    S := CnOtaGetCurrentProcedure;
    if S = '' then
      S := CnOtaGetCurrentOuterBlock;

    if FCombo <> nil then
      (FCombo as TComboBox).Text := S;
  end;
end;

procedure TCnTestToolBarWizard.Execute;
begin
  if CnEditorToolBarService <> nil then
  begin
    CnEditorToolBarService.RegisterToolBarType('TestToolBar',
      CreateToolBar, InitToolBar, nil);
    EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
    FRegistered := True;
  end;
  { TODO -oAnyone : ��ר�ҵ���ִ�й��� }
end;

function TCnTestToolBarWizard.GetCaption: string;
begin
  Result := 'Register a ToolBar Type';
  { TODO -oAnyone : ����ר�Ҳ˵��ı��⣬�ַ�������б��ػ����� }
end;

function TCnTestToolBarWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
  { TODO -oAnyone : ����Ĭ�ϵĿ�ݼ� }
end;

function TCnTestToolBarWizard.GetHasConfig: Boolean;
begin
  Result := False;
  { TODO -oAnyone : ����ר���Ƿ������ô��� }
end;

function TCnTestToolBarWizard.GetHint: string;
begin
  Result := 'Register an Editor ToolBar Type';
  { TODO -oAnyone : ����ר�Ҳ˵���ʾ��Ϣ���ַ�������б��ػ����� }
end;

function TCnTestToolBarWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : ����ר�Ҳ˵�״̬���ɸ���ָ���������趨 }
end;

class procedure TCnTestToolBarWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'TestEditorToolBarWizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Editor ToolBar Wizard';
  { TODO -oAnyone : ����ר�ҵ����ơ����ߡ����估��ע���ַ�������б��ػ����� }
end;

procedure TCnTestToolBarWizard.InitToolBar(const ToolBarType: string;
  EditControl: TControl; ToolBar: TToolBar);
begin
  (FCombo as TComboBox).Items.Add('Test1');
  (FCombo as TComboBox).Items.Add('Test2');
end;

procedure TCnTestToolBarWizard.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : �ڴ�װ��ר���ڲ��õ��Ĳ�����ר�Ҵ���ʱ�Զ������� }
end;

procedure TCnTestToolBarWizard.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : �ڴ˱���ר���ڲ��õ��Ĳ�����ר���ͷ�ʱ�Զ������� }
end;

initialization
  RegisterCnWizard(TCnTestToolBarWizard); // ע��ר��

end.
