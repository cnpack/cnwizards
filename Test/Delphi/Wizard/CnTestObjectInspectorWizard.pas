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

unit CnTestObjectInspectorWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����Զ���鿴�����Ӳ˵�ר�Ҳ��Ե�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��Win7 + Delphi 5.01
* ���ݲ��ԣ�Win7 + D5/2007/2009
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.01.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon;

type

//==============================================================================
// ���Զ���鿴�����Ӳ˵�ר�Ҳ��Ե�Ԫ
//==============================================================================

{ TCnTestObjectInspectorWizard }

  TCnTestObjectInspectorWizard = class(TCnSubMenuWizard)
  private
    FIdShowInfo: Integer;
    FIdToggleGrid: Integer;
    FIdToggleNotifier: Integer;
    FNotifierRegistered: Boolean;
    procedure SelectItemChange(Sender: TObject);
    procedure DumpObjectInspector;
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
  CnDebug, CnObjectInspectorWrapper;

//==============================================================================
// ���Զ���鿴�����Ӳ˵�ר�Ҳ��Ե�Ԫ
//==============================================================================

{ TCnTestObjectInspectorWizard }

procedure TCnTestObjectInspectorWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestObjectInspectorWizard.Create;
begin
  inherited;

end;

procedure TCnTestObjectInspectorWizard.AcquireSubActions;
begin
  FIdShowInfo := RegisterASubAction('CnTestObjectInspectorShowInfo',
    'Show Object Inspector Information', 0, 'CnTestObjectInspectorShowInfo',
    'CnTestObjectInspectorShowInfo');

  FIdToggleGrid := RegisterASubAction('CnTestObjectInspectorToggleGrid',
    'Object Inspector Toggle Grid', 0, 'CnTestObjectInspectorToggleGrid',
    'CnTestObjectInspectorToggleGrid');

  AddSepMenu;

  FIdToggleNotifier := RegisterASubAction('CnTestObjectInspectorToggleNotifier',
    'Register/Unregister Select Item Change', 0, 'CnTestObjectInspectorToggleNotifier',
    'CnTestObjectInspectorToggleNotifier');
end;

function TCnTestObjectInspectorWizard.GetCaption: string;
begin
  Result := 'Test ObjectInspector Wizard';
end;

function TCnTestObjectInspectorWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestObjectInspectorWizard.GetHint: string;
begin
  Result := 'Test ObjectInspector';
end;

function TCnTestObjectInspectorWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestObjectInspectorWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test ObjectInspector Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test ObjectInspector Wizard';
end;

procedure TCnTestObjectInspectorWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestObjectInspectorWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestObjectInspectorWizard.SubActionExecute(Index: Integer);
var
  B: Boolean;
begin
  if not Active then Exit;

  if Index = FIdShowInfo then
  begin
    DumpObjectInspector;
  end
  else if Index = FIdToggleGrid then
  begin
    ObjectInspectorWrapper.ShowGridLines := not ObjectInspectorWrapper.ShowGridLines;
  end
  else if Index = FIdToggleNotifier then
  begin
    if FNotifierRegistered then
    begin
      ObjectInspectorWrapper.RemoveSelectionChangeNotifier(SelectItemChange);
      FNotifierRegistered := False;
      ShowMessage('Notification UnRegistered');
    end
    else
    begin
      ObjectInspectorWrapper.AddSelectionChangeNotifier(SelectItemChange);
      FNotifierRegistered := True;
      ShowMessage('Notification Registered');
    end;
  end;
end;

procedure TCnTestObjectInspectorWizard.SubActionUpdate(Index: Integer);
begin
  if Index = FIdToggleNotifier then
    SubActions[Index].Checked := FNotifierRegistered;
end;

procedure TCnTestObjectInspectorWizard.SelectItemChange(Sender: TObject);
var
  Clz, Prop: string;
  CT, OrigCT: TClass;
begin
  CnDebugger.LogMsg('TCnTestObjectInspectorWizard.SelectItemChange');
  DumpObjectInspector;

  Clz := ObjectInspectorWrapper.ActiveComponentType;
  if Clz = '' then // ����ѡ���˶��
    Exit;

  Prop := ObjectInspectorWrapper.ActivePropName;

  CT := GetClass(Clz); // ���ﾹȻ�ò�����������壬ֻ���õ������ڵ�������û������취���������Ĵ���
  if CT <> nil then
  begin
    OrigCT := GetOriginalClassFromProperty(CT, Prop);
    if OrigCT <> nil then
      CnDebugger.LogFmt('Get Orig %s.%s', [OrigCT.ClassName, Prop])
    else
      CnDebugger.LogFmt('Get %s.%s', [CT.ClassName, Prop]);
  end
  else
    CnDebugger.LogMsg('Get NO Class for ' + Clz);
end;

procedure TCnTestObjectInspectorWizard.DumpObjectInspector;
begin
  CnDebugger.LogFmt('Object Inspector Active Component Type: %s',
    [ObjectInspectorWrapper.ActiveComponentType]);
  CnDebugger.LogFmt('Object Inspector Active Component Name: %s',
    [ObjectInspectorWrapper.ActiveComponentName]);
  CnDebugger.LogFmt('Object Inspector Active Property Name: %s',
    [ObjectInspectorWrapper.ActivePropName]);
  CnDebugger.LogFmt('Object Inspector Active Property Value: %s',
    [ObjectInspectorWrapper.ActivePropValue]);

  CnDebugger.LogBoolean(ObjectInspectorWrapper.ShowGridLines, 'Object Inspector ShowGridLines');
end;

destructor TCnTestObjectInspectorWizard.Destroy;
begin
  if FNotifierRegistered then
  begin
    ObjectInspectorWrapper.RemoveSelectionChangeNotifier(SelectItemChange);
    FNotifierRegistered := False;
  end;
  inherited;
end;

initialization
  RegisterCnWizard(TCnTestObjectInspectorWizard); // ע��ר��

end.
