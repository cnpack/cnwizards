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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestAIPluginWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestAIPluginWizard
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：Windows 7 + Delphi 5
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.09.21 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  {$IFDEF OTA_HAS_AISERVICE} ToolsAPI.AI, {$ENDIF} ToolsAPI, IniFiles,
   CnWizClasses, CnWizUtils, CnWizConsts, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TCnTestAIPluginFrame = class(TFrame, IOTAAIPluginSetting)
    edtTest: TEdit;
  private

  public
    procedure SaveSettings;
    procedure LoadSettings;
    function GetModified: Boolean;
    function GetPluginEnabled: Boolean;
    function ParameterValidations(var AErrorMsg: string): Boolean;
  end;

  TCnTestAIPluginSample = class(TInterfacedObject, IOTAAIPlugin)
  private
    FNotifiers: TInterfaceList;
    FChatGuid: TGUID;
    FTimer: TTimer;
  protected
    procedure NotifyAnswer;
    procedure AITimer(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;

    function AddNotifier(const ANotifier: IOTAAIServicesNotifier): Integer;
    procedure RemoveNotifier(const AIndex: Integer);
    function Chat(const AQuestion: string): TGUID;
    function LoadModels: TGUID;
    function Instruction(const AInput: string; const AInstruction: string): TGUID;
    function Moderation(const AInput: string): TGUID;
    function GenerateImage(const APrompt: string; const ASize: string; const AFormat: string): TGUID;
    function GenerateSpeechFromText(const AText: string; const AVoice: string): TGUID;
    function GenerateTextFromAudioFile(const AAudioFilePath: string): TGUID;
    procedure Cancel;
    function GetName: string;
    function GetSettingFrame(AOwner: TComponent): IOTAAIPluginSetting;
    function GetFeatures: TAIFeatures;
    function GetEnabled: Boolean;
  end;

//==============================================================================
// CnTestAIPluginWizard 菜单专家
//==============================================================================

{ TCnTestAIPluginWizard }

  TCnTestAIPluginWizard = class(TCnMenuWizard)
  private
    FPlugin: IOTAAIPlugin;
    FIndex: Integer;
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

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$R *.dfm}

//==============================================================================
// CnTestAIPluginWizard 菜单专家
//==============================================================================

{ TCnTestAIPluginWizard }

procedure TCnTestAIPluginWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

constructor TCnTestAIPluginWizard.Create;
begin
  inherited;
  FIndex := -1;
end;

destructor TCnTestAIPluginWizard.Destroy;
begin
  if (FPlugin <> nil) and (FIndex >= 0) then
  begin
    AIEngineService.UnregisterPlugin(FIndex);
    FIndex := -1;
    FPlugin := nil;
  end;
  inherited;
end;

procedure TCnTestAIPluginWizard.Execute;
{$IFDEF OTA_HAS_AISERVICE}
  procedure ShowPlugins;
  var
    I: Integer;
    SL: TStringList;
  begin
    ShowMessage('AIEngineService PluginCount: ' + IntToStr(AIEngineService.PluginCount));
    SL := TStringList.Create;
    try
      for I := 0 to AIEngineService.PluginCount - 1 do
        SL.Add(AIEngineService.GetPluginByIndex(I).Name);

      ShowMessage(SL.Text);
    finally
      SL.Free;
    end;
  end;
{$ENDIF}
begin
{$IFDEF OTA_HAS_AISERVICE}
  ShowPlugins;

  if FPlugIn = nil then
  begin
    FPlugIn := TCnTestAIPluginSample.Create;
    FIndex := AIEngineService.RegisterPlugin(FPlugin);
    ShowMessage('AI Plugin Registered at ' + IntToStr(FIndex));
  end
  else
  begin
    if FIndex >= 0 then
    begin
      AIEngineService.UnregisterPlugin(FIndex);
      FIndex := -1;
      FPlugin := nil;
      ShowMessage('AI Plugin UnRegistered.');
    end;
  end;

  ShowPlugins;
{$ELSE}
  ShowMessage('NO AI Engine Support.');
{$ENDIF}
end;

function TCnTestAIPluginWizard.GetCaption: string;
begin
  Result := 'Test AIPlugin';
end;

function TCnTestAIPluginWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestAIPluginWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestAIPluginWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestAIPluginWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestAIPluginWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test AIPlugin Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := '';
end;

procedure TCnTestAIPluginWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestAIPluginWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

{ TCnTestAIPluginSample }

function TCnTestAIPluginSample.AddNotifier(
  const ANotifier: IOTAAIServicesNotifier): Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.AddNotifier');
{$ENDIF}
  FNotifiers.Add(ANotifier);
  Result := FNotifiers.Count - 1;
end;

procedure TCnTestAIPluginSample.AITimer(Sender: TObject);
begin
  NotifyAnswer;
  FTimer.Enabled := False;
end;

procedure TCnTestAIPluginSample.Cancel;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.Cancel');
{$ENDIF}
end;

function TCnTestAIPluginSample.Chat(const AQuestion: string): TGUID;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.Chat: ' + AQuestion);
{$ENDIF}
  CreateGUID(FChatGuid);
  Result := FChatGuid;
  FTimer.Enabled := True;
end;

constructor TCnTestAIPluginSample.Create;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.Create');
{$ENDIF}
  FNotifiers := TInterfaceList.Create;
  FTimer := TTimer.Create(Application);
  FTimer.Interval := 500;
  FTimer.Enabled := False;
  FTimer.OnTimer := AITimer;
end;

destructor TCnTestAIPluginSample.Destroy;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.Destroy');
{$ENDIF}
  FNotifiers.Free;
  inherited;
end;

function TCnTestAIPluginSample.GenerateImage(const APrompt, ASize,
  AFormat: string): TGUID;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnTestAIPluginSample.GenerateImage Format %s. Size %s. Prompt %s',
    [AFormat, ASize, APrompt]);
{$ENDIF}
end;

function TCnTestAIPluginSample.GenerateSpeechFromText(const AText,
  AVoice: string): TGUID;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnTestAIPluginSample.GenerateSpeechFromText Voice %s. Text %s',
    [AVoice, AText]);
{$ENDIF}
end;

function TCnTestAIPluginSample.GenerateTextFromAudioFile(
  const AAudioFilePath: string): TGUID;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.GenerateTextFromAudioFile ' + AAudioFilePath);
{$ENDIF}
end;

function TCnTestAIPluginSample.GetEnabled: Boolean;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.GetEnabled');
{$ENDIF}
  Result := True;
end;

function TCnTestAIPluginSample.GetFeatures: TAIFeatures;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.GetFeatures');
{$ENDIF}
  Result := [afChat];
end;

function TCnTestAIPluginSample.GetName: string;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.GetName');
{$ENDIF}
  Result := '胡说八道';
end;

function TCnTestAIPluginSample.GetSettingFrame(
  AOwner: TComponent): IOTAAIPluginSetting;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.GetSettingFrame');
  CnDebugger.LogComponent(AOwner);
{$ENDIF}
  Result := TCnTestAIPluginFrame.Create(AOwner);
end;

function TCnTestAIPluginSample.Instruction(const AInput,
  AInstruction: string): TGUID;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnTestAIPluginSample.Instruction %s %s', [AInput, AInstruction]);
{$ENDIF}
end;

function TCnTestAIPluginSample.LoadModels: TGUID;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginSample.LoadModels');
{$ENDIF}
end;

function TCnTestAIPluginSample.Moderation(const AInput: string): TGUID;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnTestAIPluginSample.Moderation %s', [AInput]);
{$ENDIF}
end;

procedure TCnTestAIPluginSample.NotifyAnswer;
var
  I: Integer;
  Ans: IOTAAIServicesNotifier;
begin
  for I := 0 to FNotifiers.Count - 1 do
  begin
    Ans := FNotifiers[I] as IOTAAIServicesNotifier;
    Ans.Answer('别问了，俺啥都不知道。', FChatGuid);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('NotifyAnswer ' + GUIDToString(FChatGuid));
{$ENDIF}
  end;
end;

procedure TCnTestAIPluginSample.RemoveNotifier(const AIndex: Integer);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnTestAIPluginSample.RemoveNotifier %d', [AIndex]);
{$ENDIF}
  FNotifiers.Delete(AIndex);
end;

{ TCnTestAIPluginFrame }

function TCnTestAIPluginFrame.GetModified: Boolean;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginFrame.GetModified');
{$ENDIF}
  Result := True;
end;

function TCnTestAIPluginFrame.GetPluginEnabled: Boolean;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginFrame.GetPluginEnabled');
{$ENDIF}
  Result := True;
end;

procedure TCnTestAIPluginFrame.LoadSettings;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginFrame.LoadSettings');
{$ENDIF}
end;

function TCnTestAIPluginFrame.ParameterValidations(
  var AErrorMsg: string): Boolean;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginFrame.ParameterValidations');
{$ENDIF}
  Result := True;
end;

procedure TCnTestAIPluginFrame.SaveSettings;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTestAIPluginFrame.SaveSettings');
{$ENDIF}
end;

initialization
  RegisterCnWizard(TCnTestAIPluginWizard); // 注册此测试专家

end.
