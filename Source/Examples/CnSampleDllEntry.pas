{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnSampleDllEntry;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizard 专家 DLL 入口示例单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2019.01.21 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  SysUtils, Classes, Menus, ImgList, Dialogs, ToolsAPI;

// 专家 DLL 初始化入口函数
function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
{* 专家 DLL 初始化入口函数}

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

// 专家 DLL 释放过程
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

// 专家 DLL 初始化入口函数
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

