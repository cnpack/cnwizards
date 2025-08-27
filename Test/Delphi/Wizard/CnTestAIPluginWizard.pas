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

unit CnTestAIPluginWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestAIPluginWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע���ò���ר�ҽ�֧�� D12.2 �����ϰ汾����
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.09.21 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  {$IFDEF OTA_HAS_AISERVICE} ToolsAPI.AI, {$ENDIF} ToolsAPI, IniFiles,
  CnWizClasses, CnWizUtils, CnWizConsts, StdCtrls, ExtCtrls;

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
// CnTestAIPluginWizard �˵�ר��
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
// CnTestAIPluginWizard �˵�ר��
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
  Result := '��˵�˵�';
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
    Ans.Answer('�����ˣ���ɶ����֪����', FChatGuid);
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
  RegisterCnWizard(TCnTestAIPluginWizard); // ע��˲���ר��

end.
