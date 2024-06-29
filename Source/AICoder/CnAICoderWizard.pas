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

unit CnAICoderWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：AI 辅助编码专家单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin7 + Delphi 5
* 兼容测试：PWin7/10/11 + Delphi + C++Builder
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.04.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles,ComCtrls, StdCtrls, CnConsts, CnWizClasses, CnWizUtils,
  CnWizConsts, CnCommon, CnAICoderConfig, CnThreadPool, CnAICoderEngine,
  CnFrmAICoderOption, CnAICoderChatFrm, CnWizMultiLang;

type
  TCnAICoderConfigForm = class(TCnTranslateForm)
    lblActiveEngine: TLabel;
    cbbActiveEngine: TComboBox;
    pgcAI: TPageControl;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    chkProxy: TCheckBox;
    edtProxy: TEdit;
    procedure cbbActiveEngineChange(Sender: TObject);
  private
    FTabsheets: array of TTabSheet;
    FOptionFrames: array of TCnAICoderOptionFrame;
  public
    procedure LoadFromOptions;
    procedure SaveToOptions;
  end;
 
//==============================================================================
// AI 辅助编码子菜单专家
//==============================================================================

{ TCnAICoderWizard }

  TCnAICoderWizard = class(TCnSubMenuWizard)
  private
    FIdExplainCode: Integer;
    FIdShowChatWindow: Integer;
    FIdConfig: Integer;
    function ValidateAIEngines: Boolean;
    {* 调用各个功能前检查 AI 引擎及配置}
    procedure ExplainCodeAnswer(Success: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    procedure EnsureChatWindowVisible;
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

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

{$R *.DFM}

uses
  CnWizOptions, CnChatBox {$IFDEF DEBUG} , CnDebug {$ENDIF};

//==============================================================================
// AI 辅助编码菜单专家
//==============================================================================

{ TCnAICoderWizard }

procedure TCnAICoderWizard.Config;
begin
  with TCnAICoderConfigForm.Create(nil) do
  begin
    LoadFromOptions;
    if ShowModal = mrOK then
    begin
      SaveToOptions;

      DoSaveSettings;
    end;
    Free;
  end;
end;

constructor TCnAICoderWizard.Create;
begin
  inherited;

end;

destructor TCnAICoderWizard.Destroy;
begin
  inherited;

end;

// 必须重载该方法来创建子菜单专家项
procedure TCnAICoderWizard.AcquireSubActions;
begin
  FIdExplainCode := RegisterASubAction(SCnAICoderWizardExplainCode,
    SCnAICoderWizardExplainCodeCaption, 0,
    SCnAICoderWizardExplainCodeHint, SCnAICoderWizardExplainCode);

  // 创建分隔菜单
  AddSepMenu;

  FIdShowChatWindow := RegisterASubAction(SCnAICoderWizardChatWindow,
    SCnAICoderWizardChatWindowCaption, 0,
    SCnAICoderWizardChatWindowHint, SCnAICoderWizardChatWindow);

  FIdConfig := RegisterASubAction(SCnAICoderWizardConfig,
    SCnAICoderWizardConfigCaption, 0, SCnAICoderWizardConfigHint, SCnAICoderWizardConfig);
end;

function TCnAICoderWizard.GetCaption: string;
begin
  Result := SCnAICoderWizardMenuCaption;
end;

function TCnAICoderWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnAICoderWizard.GetHint: string;
begin
  Result := SCnAICoderWizardMenuHint;
end;

function TCnAICoderWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnAICoderWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnAICoderWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnAICoderWizardComment;
end;

procedure TCnAICoderWizard.LoadSettings(Ini: TCustomIniFile);
begin
  CnAIEngineManager.LoadFromWizOptions;

  // 这句很重要，手动设置存储的活动引擎名称
  CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('CnAIEngineOptionManager Load %d Options.', [CnAIEngineOptionManager.OptionCount]);
{$ENDIF}
end;

procedure TCnAICoderWizard.SaveSettings(Ini: TCustomIniFile);
begin
  CnAIEngineManager.SaveToWizOptions;
end;

procedure TCnAICoderWizard.SubActionExecute(Index: Integer);
var
  S: string;
  Msg: TCnChatMessage;
begin
  if not Active then Exit;

  if Index = FIdConfig then
    Config
  else if Index = FIdShowChatWindow then
  begin
    if CnAICoderChatForm = nil then
      CnAICoderChatForm := TCnAICoderChatForm.Create(Application);

    CnAICoderChatForm.Visible := not CnAICoderChatForm.Visible;
  end
  else
  begin
    if not ValidateAIEngines then
    begin
      Config;
      Exit;
    end;

    if Index = FIdExplainCode then
    begin
      S := CnOtaGetCurrentSelection;
      if Trim(S) <> '' then
      begin
        EnsureChatWindowVisible;
        Msg := CnAICoderChatForm.ChatBox.Items.AddMessage;
        Msg.From := CnAIEngineManager.CurrentEngineName;
        Msg.FromType := cmtYou;
        Msg.Text := '...';

        CnAIEngineManager.CurrentEngine.AskAIEngineExplainCode(S, Msg, ExplainCodeAnswer);
      end;
    end;
  end;
end;

procedure TCnAICoderWizard.SubActionUpdate(Index: Integer);
begin
  if Index = FIdConfig then
    SubActions[Index].Enabled := Active
  else if Index = FIdShowChatWindow then
    SubActions[Index].Checked := (CnAICoderChatForm <> nil) and CnAICoderChatForm.Visible
  else
    SubActions[Index].Enabled := Active and (CnOtaGetCurrentSelection <> '');
end;

function TCnAICoderWizard.ValidateAIEngines: Boolean;
begin
  Result := False;
  if (CnAIEngineManager.CurrentEngine = nil) or
    (CnAIEngineManager.CurrentEngine.Option = nil) then
  begin
    ErrorDlg(SCnAICoderWizardErrorNoEngine);
    Exit;
  end;
  if (Trim(CnAIEngineManager.CurrentEngine.Option.URL) = '') then
  begin
    ErrorDlg(Format(SCnAICoderWizardErrorURLFmt, [CnAIEngineManager.CurrentEngine.EngineName]));
    Exit;
  end;
  if (Trim(CnAIEngineManager.CurrentEngine.Option.ApiKey) = '') then
  begin
    ErrorDlg(Format(SCnAICoderWizardErrorAPIKeyFmt, [CnAIEngineManager.CurrentEngine.EngineName]));
    Exit;
  end;

  Result := True;
end;

procedure TCnAICoderConfigForm.LoadFromOptions;
var
  I: Integer;
  SL: TStringList;
begin
  chkProxy.Checked := CnAIEngineOptionManager.UseProxy;
  edtProxy.Text := CnAIEngineOptionManager.ProxyServer;

  cbbActiveEngine.Items.Clear;
  for I := 0 to CnAIEngineManager.EngineCount - 1 do
    cbbActiveEngine.Items.Add(CnAIEngineManager.Engines[I].EngineName);

  cbbActiveEngine.ItemIndex := CnAIEngineManager.CurrentIndex;

  // 给每个 Options 创建一个 Tab，每个 Tab 里塞一个 Frame，给 Frame 里的东西塞 Option 内容
  SetLength(FTabsheets, CnAIEngineOptionManager.OptionCount);
  SetLength(FOptionFrames, CnAIEngineOptionManager.OptionCount);

  SL := TStringList.Create;
  try
    for I := 0 to CnAIEngineOptionManager.OptionCount - 1 do
    begin
      // 给每个 Options 创建一个 Tab
      FTabsheets[I] := TTabSheet.Create(pgcAI);
      FTabsheets[I].Caption := CnAIEngineOptionManager.Options[I].EngineName + Format(' (&%d)', [I + 1]);
      FTabsheets[I].PageControl := pgcAI;

      // 给每个 Tab 里塞一个 Frame
      FOptionFrames[I] := TCnAICoderOptionFrame.Create(FTabsheets[I]);
      FOptionFrames[I].Name := 'CnAICoderOptionFrame' + IntToStr(I);
      FOptionFrames[I].Parent := FTabsheets[I];
      FOptionFrames[I].Top := 0;
      FOptionFrames[I].Left := 0;
      FOptionFrames[I].Align := alClient;

      // 给每个 Frame 里的东西塞 Option 内容
      FOptionFrames[I].edtURL.Text := CnAIEngineOptionManager.Options[I].URL;
      FOptionFrames[I].edtAPIKey.Text := CnAIEngineOptionManager.Options[I].APIKey;
      FOptionFrames[I].cbbModel.Text := CnAIEngineOptionManager.Options[I].Model;

      SL.Clear;
      ExtractStrings([','], [' '], PChar(CnAIEngineOptionManager.Options[I].ModelList), SL);
      if SL.Count > 0 then
        FOptionFrames[I].cbbModel.Items.Assign(SL);

      // 网址申请给塞上，供点击打开
      FOptionFrames[I].WebAddr := CnAIEngineOptionManager.Options[I].WebAddress;
    end;
  finally
    SL.Free;
  end;
  pgcAI.ActivePageIndex := CnAIEngineManager.CurrentIndex;
end;

procedure TCnAICoderConfigForm.SaveToOptions;
var
  I: Integer;
begin
  for I := 0 to Length(FOptionFrames) - 1 do
  begin
    CnAIEngineOptionManager.Options[I].URL := FOptionFrames[I].edtURL.Text;
    CnAIEngineOptionManager.Options[I].APIKey := FOptionFrames[I].edtAPIKey.Text;
    CnAIEngineOptionManager.Options[I].Model := FOptionFrames[I].cbbModel.Text;
  end;

  CnAIEngineOptionManager.ActiveEngine := cbbActiveEngine.Text;
  CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;

  CnAIEngineOptionManager.UseProxy := chkProxy.Checked;
  CnAIEngineOptionManager.ProxyServer := edtProxy.Text;
end;

procedure TCnAICoderWizard.ExplainCodeAnswer(Success: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
begin
  EnsureChatWindowVisible;

  if (Tag <> nil) and (Tag is TCnChatMessage) then
  begin
    if Success then
      TCnChatMessage(Tag).Text := Answer
    else
      TCnChatMessage(Tag).Text := Format('%d %s', [ErrorCode, Answer]);
  end
  else
  begin
    if Success then
      CnAICoderChatForm.AddMessage(Answer, CnAIEngineManager.CurrentEngineName)
    else
      CnAICoderChatForm.AddMessage(Format('%d %s', [ErrorCode, Answer]), CnAIEngineManager.CurrentEngineName);
  end;
end;

procedure TCnAICoderWizard.EnsureChatWindowVisible;
begin
  if CnAICoderChatForm = nil then
    CnAICoderChatForm := TCnAICoderChatForm.Create(Application);

  CnAICoderChatForm.Visible := True;
  CnAICoderChatForm.BringToFront;
end;

procedure TCnAICoderConfigForm.cbbActiveEngineChange(Sender: TObject);
begin
  if (cbbActiveEngine.ItemIndex >= 0) and (cbbActiveEngine.ItemIndex < pgcAI.PageCount) then
    pgcAI.ActivePageIndex := cbbActiveEngine.ItemIndex;
end;

initialization
  RegisterCnWizard(TCnAICoderWizard); // 注册专家

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
