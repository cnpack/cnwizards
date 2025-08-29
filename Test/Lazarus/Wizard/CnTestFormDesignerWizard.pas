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

unit CnTestFormDesignerWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�������������Ӳ˵�ר�Ҳ��Ե�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ���� Lazarus ���������
* ����ƽ̨��Win7 + Lazarus 4
* ���ݲ��ԣ�Win7 + Lazarus 4
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.08.29 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon, CnWideStrings,
  PropEdits, FormEditingIntf;

type

//==============================================================================
// �����������ع��ܵ��Ӳ˵�ר��
//==============================================================================

{ TCnTestFormDesignerWizard }

  TCnTestFormDesignerWizard = class(TCnSubMenuWizard)
  private
    FIdFormDesigner: Integer;
    FIdGlobalDesignHook: Integer;
    FIdLookupRoot: Integer;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
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

//==============================================================================
// �����������ع��ܵ��Ӳ˵�ר��
//==============================================================================

{ TCnTestFormDesignerWizard }

procedure TCnTestFormDesignerWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestFormDesignerWizard.Create;
begin
  inherited;

end;

procedure TCnTestFormDesignerWizard.AcquireSubActions;
begin
  FIdFormDesigner := RegisterASubAction('CnLazFormDesigner',
    'Test CnLazFormDesigner', 0, 'Test CnLazFormDesigner',
    'CnLazFormDesigner');
  FIdGlobalDesignHook := RegisterASubAction('CnLazGlobalDesignHook',
    'Test CnLazGlobalDesignHook', 0, 'Test CnLazGlobalDesignHook',
    'CnLazGlobalDesignHook');
  FIdLookupRoot := RegisterASubAction('CnLazLookupRoot',
    'Test CnLazLookupRoot', 0, 'Test CnLazGlobalLookupRoot',
    'CnLazLookupRoot');
end;

function TCnTestFormDesignerWizard.GetCaption: string;
begin
  Result := 'Test Form Designer';
end;

function TCnTestFormDesignerWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestFormDesignerWizard.GetHint: string;
begin
  Result := 'Test Form Designer';
end;

function TCnTestFormDesignerWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestFormDesignerWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Form Designer Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Form Designer Wizard';
end;

procedure TCnTestFormDesignerWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestFormDesignerWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestFormDesignerWizard.SubActionExecute(Index: Integer);
var
  Designer: TIDesigner;
  DesignForm: TCustomForm;
  List: TPersistentSelectionList;
  I: Integer;
begin
  if not Active then Exit;

  if FormEditingHook = nil then
    Exit;

  if Index = FIdFormDesigner then
  begin
    CnDebugger.TraceMsg('Designer Count ' + IntToStr(FormEditingHook.DesignerCount));
    Designer := FormEditingHook.GetCurrentDesigner;
    if Designer <> nil then
      CnDebugger.TraceMsg('Current Designer is ' + Designer.ClassName);
      
    CnDebugger.TraceMsg('Designer Mediator Count ' + IntToStr(FormEditingHook.DesignerMediatorCount));

    DesignForm := FormEditingHook.GetDesignerForm(nil);
    if DesignForm <> nil then
      CnDebugger.TraceMsg('A Design Form is ' + DesignForm.ClassName);
  end
  else if Index = FIdGlobalDesignHook then
  begin
    List := TPersistentSelectionList.Create;
    try
      GlobalDesignHook.GetSelection(List);
      CnDebugger.TraceMsg('Selected Count ' + IntToStr(List.Count));

      for I := 0 to List.Count - 1 do
      begin
        if List[I] is TComponent then
          CnDebugger.TraceFmt(' #%d %s:%s', [I, List[I].ClassName, TComponent(List[I]).Name])
        else
          CnDebugger.TraceFmt(' #%d %s', [I, List[I].ClassName]);
      end;
    finally
      List.Free;
    end;
  end
  else if Index = FIdLookupRoot then
  begin
    if GlobalDesignHook.LookupRoot <> nil then
    begin
      if GlobalDesignHook.LookupRoot is TComponent then
        CnDebugger.TraceFmt(' LookupRoot %s:%s', [GlobalDesignHook.LookupRoot.ClassName, TComponent(GlobalDesignHook.LookupRoot).Name])
      else
        CnDebugger.TraceFmt(' LookupRoot %s', [GlobalDesignHook.LookupRoot.ClassName]);
    end;
  end;
end;

procedure TCnTestFormDesignerWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestFormDesignerWizard); // ע��ר��

end.
