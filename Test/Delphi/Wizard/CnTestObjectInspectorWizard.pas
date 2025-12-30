{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestObjectInspectorWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：测试对象查看器的子菜单专家测试单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：Win7 + Delphi 5.01
* 兼容测试：Win7 + D5/2007/2009
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2025.01.05 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon;

type

//==============================================================================
// 测试对象查看器的子菜单专家测试单元
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
// 测试对象查看器的子菜单专家测试单元
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
  if Clz = '' then // 可能选中了多个
    Exit;

  Prop := ObjectInspectorWrapper.ActivePropName;

  CT := GetClass(Clz); // 这里竟然拿不到设计器窗体，只能拿到窗体内的组件，得换其他办法拿设计器里的窗体
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
  RegisterCnWizard(TCnTestObjectInspectorWizard); // 注册专家

end.
