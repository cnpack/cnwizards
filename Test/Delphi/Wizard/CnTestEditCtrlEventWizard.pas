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

unit CnTestEditCtrlEventWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Ա༭���ؼ��¼��ҽӵ�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���ɹҽӳɹ������¼����������ᱻ���ã�Ŀ�� MouseMove �ȱ� override
* ����ƽ̨��PWinXP + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.07.11 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnEventHook, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// ���Թҽ� EditControl �¼��Ĳ˵�ר��
//==============================================================================

{ TCnTestEditCtrlEventWizard }

  TCnTestEditCtrlEventWizard = class(TCnMenuWizard)
  private
    FHookMouseUp: TCnEventHook;
    FHookMouseDown: TCnEventHook;
    FHookMouseMove: TCnEventHook;
    
    procedure HookMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HookMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HookMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
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
    procedure Execute; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// ���Թҽ� EditControl �¼��Ĳ˵�ר��
//==============================================================================

{ TCnTestEditCtrlEventWizard }

procedure TCnTestEditCtrlEventWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditCtrlEventWizard.Create;
begin
  inherited;

end;

destructor TCnTestEditCtrlEventWizard.Destroy;
begin
  FHookMouseUp.Free;
  FHookMouseDown.Free;
  FHookMouseMove.Free;
  inherited;
end;

procedure TCnTestEditCtrlEventWizard.Execute;
var
  Edit: TControl;
begin
  Edit := CnOtaGetCurrentEditControl;
  if Edit = nil then
  begin
    ErrorDlg('No EditControl Found.');
    Exit;
  end;

  CnDebugger.TraceFmt('Will Hook EditControl %8.8x', [Integer(Edit)]);
  InfoDlg(Format('Will Hook EditControl %8.8x', [Integer(Edit)]));

  if FHookMouseUp = nil then
    FHookMouseUp := TCnEventHook.Create(Edit, 'OnMouseUp', Self,
      @TCnTestEditCtrlEventWizard.HookMouseUp);
  if FHookMouseDown = nil then
    FHookMouseDown := TCnEventHook.Create(Edit, 'OnMouseDown', Self,
      @TCnTestEditCtrlEventWizard.HookMouseDown);
  if FHookMouseMove = nil then
    FHookMouseMove := TCnEventHook.Create(Edit, 'OnMouseMove', Self,
      @TCnTestEditCtrlEventWizard.HookMouseMove);

  CnDebugger.TraceFmt('EditControl Hook Result %d. Old MouseUp %8.8x',
    [Integer(FHookMouseUp.Hooked), Integer(FHookMouseUp.Trampoline)]);
  CnDebugger.TraceFmt('EditControl Hook Result %d. Old MouseDown %8.8x',
    [Integer(FHookMouseDown.Hooked), Integer(FHookMouseDown.Trampoline)]);
  CnDebugger.TraceFmt('EditControl Hook Result %d. Old MouseMove %8.8x',
    [Integer(FHookMouseMove.Hooked), Integer(FHookMouseMove.Trampoline)]);
end;

function TCnTestEditCtrlEventWizard.GetCaption: string;
begin
  Result := 'Test EditControl Event Hook';
end;

function TCnTestEditCtrlEventWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditCtrlEventWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditCtrlEventWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditCtrlEventWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditCtrlEventWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test EditControl Event Hook Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for EditControl Event Hook';
end;

procedure TCnTestEditCtrlEventWizard.HookMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CnDebugger.TraceFmt('MouseDown at X %d, Y %d. Button %d.', [X, Y, Ord(Button)]);
end;

procedure TCnTestEditCtrlEventWizard.HookMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  CnDebugger.TraceFmt('MouseMove at X %d, Y %d.', [X, Y]);
end;

procedure TCnTestEditCtrlEventWizard.HookMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CnDebugger.TraceFmt('MouseUp at X %d, Y %d. Button %d.', [X, Y, Ord(Button)]);
end;

procedure TCnTestEditCtrlEventWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditCtrlEventWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestEditCtrlEventWizard); // ע��˲���ר��

end.
