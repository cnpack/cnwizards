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

unit CnTestFormDesignerWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：测试设计器的子菜单专家测试单元
* 单元作者：CnPack 开发组
* 备    注：该单元测试 Lazarus 的设计器。
* 开发平台：Win7 + Lazarus 4
* 兼容测试：Win7 + Lazarus 4
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2025.08.29 V1.0
*               创建单元
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
// 测试设计器相关功能的子菜单专家
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
// 测试设计器相关功能的子菜单专家
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
  RegisterCnWizard(TCnTestFormDesignerWizard); // 注册专家

end.
