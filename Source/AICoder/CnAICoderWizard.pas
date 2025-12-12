{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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
  {$IFNDEF STAND_ALONE} {$IFDEF LAZARUS} SrcEditorIntf, {$ELSE} ToolsAPI, {$ENDIF} {$ENDIF}
  IniFiles,ComCtrls, StdCtrls, CnConsts, CnWizClasses, CnWizUtils,
  CnWizConsts, CnCommon, CnAICoderConfig, CnThreadPool, CnAICoderEngine,
  CnFrmAICoderOption, CnWizMultiLang, CnWizManager;

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
    lblTimeout: TLabel;
    edtTimeout: TEdit;
    udTimeout: TUpDown;
    lblHisCount: TLabel;
    edtHisCount: TEdit;
    udHisCount: TUpDown;
    edtMaxFav: TEdit;
    lblMaxFav: TLabel;
    udMaxFav: TUpDown;
    chkAltEnterContCode: TCheckBox;
    btnShortCut: TButton;
    procedure cbbActiveEngineChange(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnShortCutClick(Sender: TObject);
  private
    FTabsheets: array of TTabSheet;
    FOptionFrames: array of TCnAICoderOptionFrame;
  protected
    function GetHelpTopic: string; override;
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
    FIdReviewCode: Integer;
    FIdGenTestCase: Integer;
    FIdContinueCoding: Integer;
    FIdShowChatWindow: Integer;
    FIdConfig: Integer;
    FNeedUpgradeGemini: Boolean;
    FFirstAnswer: Boolean;
    function ValidateAIEngines: Boolean;
    {* 调用各个功能前检查 AI 引擎及配置}
    procedure EnsureChatWindowVisible(OnlyCreate: Boolean = False);
    {* 确保创建 ChatWindow 且其 Visible 为 True 及其所有 Parent 的 Visible 全为 True
      以确保聊天窗口可见}
    procedure EditorSysKeyDown(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);

    procedure ContinueCurrentFile(UseChat: Boolean = False);
    {* 续写当前代码的入口}
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;

    procedure SetActive(Value: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure ForCodeAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean;
      SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    {* 返回文字的回调}
    procedure ForCodeGen(StreamMode, Partly, Success, IsStreamEnd: Boolean;
      SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    {* 返回代码的回调}

    procedure ForContinueAnswerToEditor(StreamMode, Partly, Success, IsStreamEnd: Boolean;
      SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    {* 续写代码的回调，输出至编辑器}
    procedure ForContinueAnswerToChat(StreamMode, Partly, Success, IsStreamEnd: Boolean;
      SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    {* 续写代码的回调，输出至聊天窗口}

    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;

    procedure VersionFirstRun; override;
  end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

{$R *.DFM}

uses
  CnWizOptions, CnAICoderNetClient, CnAICoderChatFrm, CnChatBox, CnWizIdeDock,
  CnStrings, CnIDEStrings, CnEditControlWrapper {$IFDEF DEBUG} , CnDebug {$ENDIF};

const
  MSG_WAITING = '...';
  csAICoderChatForm = 'CnAICoderChatForm';

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

      if CnAICoderChatForm <> nil then
        CnAICoderChatForm.NotifySettingChanged;
    end;
    Free;
  end;
end;

constructor TCnAICoderWizard.Create;
begin
  inherited;
  EditControlWrapper.AddKeyDownNotifier(EditorKeyDown);
  EditControlWrapper.AddSysKeyDownNotifier(EditorSysKeyDown);
{$IFDEF DELPHI_OTA}
  IdeDockManager.RegisterDockableForm(TCnAICoderChatForm, CnAICoderChatForm,
    csAICoderChatForm);
{$ENDIF}
end;

destructor TCnAICoderWizard.Destroy;
begin
{$IFDEF DELPHI_OTA}
  IdeDockManager.UnRegisterDockableForm(CnAICoderChatForm, csAICoderChatForm);
{$ENDIF}
  EditControlWrapper.RemoveKeyDownNotifier(EditorKeyDown);
  EditControlWrapper.RemoveSysKeyDownNotifier(EditorSysKeyDown);
  FreeAndNil(CnAICoderChatForm);
  inherited;
end;

// 必须重载该方法来创建子菜单专家项
procedure TCnAICoderWizard.AcquireSubActions;
begin
  FIdExplainCode := RegisterASubAction(SCnAICoderWizardExplainCode,
    SCnAICoderWizardExplainCodeCaption, 0,
    SCnAICoderWizardExplainCodeHint, SCnAICoderWizardExplainCode);

  FIdReviewCode := RegisterASubAction(SCnAICoderWizardReviewCode,
    SCnAICoderWizardReviewCodeCaption, 0,
    SCnAICoderWizardReviewCodeHint, SCnAICoderWizardReviewCode);

  FIdGenTestCase := RegisterASubAction(SCnAICoderWizardGenTestCase,
    SCnAICoderWizardGenTestCaseCaption, 0,
    SCnAICoderWizardGenTestCaseHint, SCnAICoderWizardGenTestCase);

  FIdContinueCoding := RegisterASubAction(SCnAICoderWizardContinueCoding,
    SCnAICoderWizardContinueCodingCaption, 0,
    SCnAICoderWizardContinueCodingHint, SCnAICoderWizardContinueCoding);

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
const
  UPGRADE_GEMINIIDNAME = 'Gemini'; // 引擎 ID 和 NAME 都是它
var
  NewGerminiOption: TCnAIEngineOption;
  S: string;
begin
  CnAIEngineManager.LoadFromWizOptions;

  // 这句很重要，手动设置存储的活动引擎名称
  CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;

  if FNeedUpgradeGemini then
  begin
    // 手动更新 Gemini 的设置的 URL 为专家包自带的配置的 URL
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnAICoderWizard Load Settings for 161. Upgrade Gemini.');
{$ENDIF}

    S := WizOptions.GetDataFileName(Format(SCnAICoderEngineOptionFileFmt, [UPGRADE_GEMINIIDNAME]));
    NewGerminiOption := CnAIEngineOptionManager.CreateOptionFromFile(UPGRADE_GEMINIIDNAME, S, nil, False);

    try
      if CnAIEngineOptionManager.GetOptionByEngine(UPGRADE_GEMINIIDNAME) <> nil then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('TCnAICoderWizard Upgrade Gemini from %s to %s',
          [CnAIEngineOptionManager.GetOptionByEngine(UPGRADE_GEMINIIDNAME).URL, NewGerminiOption.URL]);
{$ENDIF}
        CnAIEngineOptionManager.GetOptionByEngine(UPGRADE_GEMINIIDNAME).URL := NewGerminiOption.URL;
      end;
    finally
      NewGerminiOption.Free;
    end;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('CnAIEngineOptionManager Load %d Options.', [CnAIEngineOptionManager.OptionCount]);
{$ENDIF}
end;

procedure TCnAICoderWizard.SaveSettings(Ini: TCustomIniFile);
begin
  CnAIEngineManager.SaveToWizOptions;
end;

procedure TCnAICoderWizard.ResetSettings(Ini: TCustomIniFile);
begin
  CnAIEngineManager.ResetWizOptions;
end;

procedure TCnAICoderWizard.SubActionExecute(Index: Integer);
var
  S: string;
  Msg: TCnChatMessage;
begin
  if not Active then
    Exit;

  if Index = FIdConfig then
    Config
  else if Index = FIdShowChatWindow then
  begin
    EnsureChatWindowVisible;
  end
  else
  begin
    if not ValidateAIEngines then
    begin
      Config;
      Exit;
    end;

    if (Index = FIdExplainCode) or (Index = FIdReviewCode) then
    begin
      S := CnOtaGetCurrentSelection;
      if Trim(S) <> '' then
      begin
        EnsureChatWindowVisible;
        Msg := CnAICoderChatForm.ChatBox.Items.AddMessage;
        Msg.From := UIStringToNativeString(CnAIEngineManager.CurrentEngineName);
        Msg.FromType := cmtYou;
        Msg.Text := MSG_WAITING;
        Msg.Waiting := True;

        if Index = FIdExplainCode then
          CnAIEngineManager.CurrentEngine.AskAIEngineForCode(S, nil, Msg, artExplainCode, ForCodeAnswer)
        else
          CnAIEngineManager.CurrentEngine.AskAIEngineForCode(S, nil, Msg, artReviewCode, ForCodeAnswer);
      end;
    end
    else if Index = FIdGenTestCase then
    begin
      S := CnOtaGetCurrentSelection;
      if Trim(S) <> '' then
      begin
        EnsureChatWindowVisible;

        Msg := CnAICoderChatForm.ChatBox.Items.AddMessage;
        Msg.From := UIStringToNativeString(CnAIEngineManager.CurrentEngineName);
        Msg.FromType := cmtYou;
        Msg.Text := '...';
        Msg.Waiting := True;

        CnAIEngineManager.CurrentEngine.AskAIEngineForCode(S, nil, Msg, artGenTestCase, ForCodeGen);
      end;
    end
    else if Index = FIdContinueCoding then
      ContinueCurrentFile;
  end;
end;

procedure TCnAICoderWizard.SubActionUpdate(Index: Integer);
begin
  if (Index = FIdConfig) or (Index = FIdShowChatWindow) then
    SubActions[Index].Enabled := Active
  else if Index = FIdContinueCoding then
    SubActions[Index].Enabled := Active and CurrentIsSource
  else
    SubActions[Index].Enabled := Active and (CnOtaGetCurrentSelection <> '');
end;

procedure TCnAICoderWizard.SetActive(Value: Boolean);
var
  Old: Boolean;
begin
  Old := Active;
  inherited;
  if Old <> Active then
  begin
{$IFDEF DELPHI_OTA}
    if Active then
    begin
      IdeDockManager.RegisterDockableForm(TCnAICoderChatForm, CnAICoderChatForm,
        'CnAICoderChatForm');
    end
    else
    begin
      IdeDockManager.UnRegisterDockableForm(CnAICoderChatForm, 'CnAICoderChatForm');
      FreeAndNil(CnAICoderChatForm);
    end;
{$ENDIF}
  end;
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
  if CnAIEngineManager.CurrentEngine.NeedApiKey and (Trim(CnAIEngineManager.CurrentEngine.Option.ApiKey) = '') then
  begin
    ErrorDlg(Format(SCnAICoderWizardErrorAPIKeyFmt, [CnAIEngineManager.CurrentEngine.EngineName]));
    Exit;
  end;

  Result := True;
end;

procedure TCnAICoderConfigForm.LoadFromOptions;
var
  I, J, C: Integer;
  SL: TStringList;
  Eng: TCnAIBaseEngine;
begin
  chkProxy.Checked := CnAIEngineOptionManager.UseProxy;
  edtProxy.Text := CnAIEngineOptionManager.ProxyServer;

  cbbActiveEngine.Items.Clear;
  for I := 0 to CnAIEngineManager.EngineCount - 1 do
    cbbActiveEngine.Items.Add(CnAIEngineManager.Engines[I].EngineName);

  cbbActiveEngine.ItemIndex := CnAIEngineManager.CurrentIndex;

  udTimeout.Position := CnAIEngineOptionManager.TimeoutSec;
  udHisCount.Position := CnAIEngineOptionManager.HistoryCount;
  udMaxFav.Position := CnAIEngineOptionManager.MaxFavCount;
  chkAltEnterContCode.Checked := CnAIEngineOptionManager.ContCodeKey1 or CnAIEngineOptionManager.ContCodeKey2;

  // 给每个 Options 创建一个 Tab，每个 Tab 里塞一个 Frame，给 Frame 里的东西塞 Option 内容
  SetLength(FTabsheets, CnAIEngineOptionManager.OptionCount);
  SetLength(FOptionFrames, CnAIEngineOptionManager.OptionCount);

  SL := TStringList.Create;
  try
    for I := 0 to CnAIEngineOptionManager.OptionCount - 1 do
    begin
      Eng := CnAIEngineManager.GetEngineByOption(CnAIEngineOptionManager.Options[I]);

      // 给每个 Options 创建一个 Tab
      FTabsheets[I] := TTabSheet.Create(pgcAI);
      if I < 10 then
        FTabsheets[I].Caption := CnAIEngineOptionManager.Options[I].EngineName + Format(' (&%d)', [I])
      else
        FTabsheets[I].Caption := CnAIEngineOptionManager.Options[I].EngineName
          + Format(' (&%s)', [Chr(Ord('A') + I - 10)]);
      FTabsheets[I].PageControl := pgcAI;

      // 给每个 Tab 里塞一个 Frame
      FOptionFrames[I] := TCnAICoderOptionFrame.Create(FTabsheets[I]);
      FOptionFrames[I].Engine := Eng;
      FOptionFrames[I].Name := 'CnAICoderOptionFrame' + IntToStr(I);
      FOptionFrames[I].Parent := FTabsheets[I];
      FOptionFrames[I].Top := 0;
      FOptionFrames[I].Left := 0;
      FOptionFrames[I].Align := alClient;

      // 给每个 Frame 里的东西塞 Option 内容
      FOptionFrames[I].LoadFromAnOption(CnAIEngineOptionManager.Options[I]);

      // 如果不需要 APIKey 就禁用
      if (Eng <> nil) and not Eng.NeedApiKey then
      begin
        FOptionFrames[I].lblAPIKey.Enabled := False;
        FOptionFrames[I].edtAPIKey.Enabled := False;
      end;

      // 把该 Option 里的额外参数塞给 Frame 实例，并加载值
      C := CnAIEngineOptionManager.Options[I].GetExtraOptionCount;
      if C > 0 then
      begin
        for J := 0 to C - 1 do
        begin
          FOptionFrames[I].RegisterExtraOption(CnAIEngineOptionManager.Options[I],
            CnAIEngineOptionManager.Options[I].GetExtraOptionName(J),
            CnAIEngineOptionManager.Options[I].GetExtraOptionType(J));
        end;
        FOptionFrames[I].BuildExtraOptionElements;
      end;

      SL.Clear;
      ExtractStrings([','], [' '], PChar(CnAIEngineOptionManager.Options[I].ModelList), SL);
      if SL.Count > 0 then
        FOptionFrames[I].cbbModel.Items.Assign(SL);

      // 有的话，网址申请给塞上，供点击打开
      if CnAIEngineOptionManager.Options[I].WebAddress <> '' then
        FOptionFrames[I].WebAddr := CnAIEngineOptionManager.Options[I].WebAddress
      else
        FOptionFrames[I].lblApply.Visible := False;

      CnEnlargeButtonGlyphForHDPI(FOptionFrames[I].btnReset);
      CnEnlargeButtonGlyphForHDPI(FOptionFrames[I].btnFetchModel);
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
    // 存标准属性
    FOptionFrames[I].SaveToAnOption(CnAIEngineOptionManager.Options[I]);

    // 存额外属性
    FOptionFrames[I].SaveExtraOptions;
  end;

  CnAIEngineOptionManager.ActiveEngine := cbbActiveEngine.Text;
  CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;

  CnAIEngineOptionManager.TimeoutSec := udTimeout.Position;
  CnAIEngineOptionManager.HistoryCount := udHisCount.Position;
  CnAIEngineOptionManager.MaxFavCount := udMaxFav.Position;
  CnAIEngineOptionManager.ContCodeKey1 := chkAltEnterContCode.Checked;
  CnAIEngineOptionManager.ContCodeKey2 := chkAltEnterContCode.Checked;

  CnAIEngineOptionManager.UseProxy := chkProxy.Checked;
  CnAIEngineOptionManager.ProxyServer := edtProxy.Text;
end;

procedure TCnAICoderWizard.ForCodeAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
begin
  EnsureChatWindowVisible;

  if (Tag <> nil) and (Tag is TCnChatMessage) then
  begin
    TCnChatMessage(Tag).Waiting := False;
    if Success then
    begin
      if Partly and (TCnChatMessage(Tag).Text <> MSG_WAITING) then
        TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer
      else
        TCnChatMessage(Tag).Text := Answer;
    end
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

procedure TCnAICoderWizard.ForCodeGen(StreamMode, Partly, Success, IsStreamEnd: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
var
  S: string;
begin
  if (Tag <> nil) and (Tag is TCnChatMessage) then
  begin
    TCnChatMessage(Tag).Waiting := False;
    if Success then
    begin
      if Partly and (TCnChatMessage(Tag).Text <> MSG_WAITING)then
        TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer
      else
        TCnChatMessage(Tag).Text := Answer;

      // 结束再挑出代码
      if not Partly or IsStreamEnd then
      begin
        S := TCnAICoderChatForm.ExtractCode(TCnChatMessage(Tag));
        if S <> '' then
        begin
          // 判断有无选择区，避免覆盖选择区内容
          if CnOtaGetCurrentSelection <> '' then // 取消选择，并下移光标
            CnOtaDeSelection(True);

          CnOtaInsertTextIntoEditor(#13#10 + S + #13#10);
        end;
      end;
    end
    else
    begin
      EnsureChatWindowVisible;
      TCnChatMessage(Tag).Text := Format('%d %s', [ErrorCode, Answer]);
    end;
  end
  else
  begin
    EnsureChatWindowVisible;
    if Success then
      CnAICoderChatForm.AddMessage(Answer, CnAIEngineManager.CurrentEngineName)
    else
      CnAICoderChatForm.AddMessage(Format('%d %s', [ErrorCode, Answer]), CnAIEngineManager.CurrentEngineName);
  end;
end;

procedure TCnAICoderWizard.EnsureChatWindowVisible(OnlyCreate: Boolean);
begin
  if CnAICoderChatForm = nil then
  begin
    CnAICoderChatForm := TCnAICoderChatForm.Create(nil);
    CnAICoderChatForm.Wizard := Self;
  end;

  if OnlyCreate then
    Exit;

{$IFDEF DELPHI_OTA}
  CnAICoderChatForm.VisibleWithParent := True;
{$ELSE}
  CnAICoderChatForm.Visible := True;
{$ENDIF}
  CnAICoderChatForm.BringToFront;
end;

procedure TCnAICoderConfigForm.cbbActiveEngineChange(Sender: TObject);
begin
  if (cbbActiveEngine.ItemIndex >= 0) and (cbbActiveEngine.ItemIndex < pgcAI.PageCount) then
    pgcAI.ActivePageIndex := cbbActiveEngine.ItemIndex;
end;

procedure TCnAICoderConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnAICoderConfigForm.GetHelpTopic: string;
begin
  Result := 'CnAICoderWizard';
end;

procedure TCnAICoderWizard.VersionFirstRun;
begin
  if (CnWizardMgr.ProductVersion >= 161) and // 161 版开始的部分 AI 参数要升级，如 Gemini 的地址
    (WizOptions.ReadInteger(SCnVersionFirstRun, Self.ClassName, 0) < 161) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnAICoderWizard.VersionFirstRun for 161. To Upgrade Setting.');
{$ENDIF}
    FNeedUpgradeGemini := True;
  end;
end;

procedure TCnAICoderWizard.EditorKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
begin
  if not Active or not CnAIEngineOptionManager.ContCodeKey2 then
    Exit;

  if (Key = VK_RETURN) and (ssCtrl in Shift) and (ssAlt in Shift) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Ctrl+Alt+Enter Pressed to Continue AI Coding');
{$ENDIF}
    if not ValidateAIEngines then
    begin
      Config;
      Exit;
    end;

    ContinueCurrentFile(True);
    Handled := True;
  end;
end;

procedure TCnAICoderWizard.EditorSysKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
begin
  if not Active or not CnAIEngineOptionManager.ContCodeKey1 then
    Exit;

  if Key = VK_RETURN then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Alt+Enter Pressed to Continue AI Coding');
{$ENDIF}
    if not ValidateAIEngines then
    begin
      Config;
      Exit;
    end;

    ContinueCurrentFile;
    Handled := True;
  end;
end;

procedure TCnAICoderWizard.ContinueCurrentFile(UseChat: Boolean);
{$IFNDEF STAND_ALONE}
var
  I, LastLine: Integer;
  S: string;
  PIde: PCnIdeTokenChar;
  SL: TStringList;
  Mem: TMemoryStream;
{$IFDEF DELPHI_OTA}
  View: IOTAEditView;
{$ENDIF}
  P: TOTAEditPos;
  Msg: TCnChatMessage;
  PasParser: TCnGeneralPasStructParser;
  CppParser: TCnGeneralCppStructParser;
  CurIsPas, CurIsCpp: Boolean;
  CharPos: TOTACharPos;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  // 收集本文件从开始到光标这行的内容，并发送，并编辑器接收回应
{$IFDEF LAZARUS}
  if SourceEditorManagerIntf.ActiveEditor = nil then
    Exit;
{$ELSE}
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;
{$ENDIF}

  S := '';
  Mem := nil;
  SL := nil;
  PasParser := nil;
  CppParser := nil;
  LastLine := -1;

  try
    Mem := TMemoryStream.Create;
    SL := TStringList.Create;
    CnGeneralSaveEditorToStream(nil, Mem);

    // 找光标外的最外层
{$IFDEF LAZARUS}
    CurIsPas := IsDprOrPas(SourceEditorManagerIntf.ActiveEditor.FileName) or IsInc(SourceEditorManagerIntf.ActiveEditor.FileName);
    CurIsCpp := IsCppSourceModule(SourceEditorManagerIntf.ActiveEditor.FileName);
{$ELSE}
    CurIsPas := IsDprOrPas(View.Buffer.FileName) or IsInc(View.Buffer.FileName);
    CurIsCpp := IsCppSourceModule(View.Buffer.FileName);
{$ENDIF}

    // 解析
    if CurIsPas then
    begin
      PasParser := TCnGeneralPasStructParser.Create;
  {$IFDEF BDS}
      PasParser.UseTabKey := True;
      PasParser.TabWidth := EditControlWrapper.GetTabWidth;
  {$ENDIF}
    end;

    if CurIsCpp then
    begin
      CppParser := TCnGeneralCppStructParser.Create;
  {$IFDEF BDS}
      CppParser.UseTabKey := True;
      CppParser.TabWidth := EditControlWrapper.GetTabWidth;
  {$ENDIF}
    end;

    // 解析当前显示的源文件
    if CurIsPas then
    begin
{$IFDEF LAZARUS}
      CnGeneralPasParserParseSource(PasParser, Mem, IsDpr(SourceEditorManagerIntf.ActiveEditor.FileName)
        or IsInc(SourceEditorManagerIntf.ActiveEditor.FileName), False);
{$ELSE}
      CnGeneralPasParserParseSource(PasParser, Mem, IsDpr(View.Buffer.FileName)
        or IsInc(View.Buffer.FileName), False);
{$ENDIF}

      // 解析后再查找当前光标所在的块，不直接使用 CursorPos，因为 Parser 所需偏移可能不同
      CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
      PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

      if PasParser.BlockCloseToken <> nil then
        LastLine := PasParser.BlockCloseToken.LineNumber;
    end
    else if CurIsCpp then
    begin
{$IFDEF LAZARUS}
      CnGeneralCppParserParseSource(CppParser, Mem, SourceEditorManagerIntf.ActiveEditor.CursorTextXY.Y,
        SourceEditorManagerIntf.ActiveEditor.CursorTextXY.X, True, True);
{$ELSE}
      CnGeneralCppParserParseSource(CppParser, Mem, View.CursorPos.Line,
        View.CursorPos.Col, True, True);
{$ENDIF}
      if CppParser.BlockCloseToken <> nil then
        LastLine := CppParser.BlockCloseToken.LineNumber;
    end;

    PIde := PCnIdeTokenChar(Mem.Memory);
    SL.Text := string(PIde);
{$IFDEF LAZARUS}
    P.Line := SourceEditorManagerIntf.ActiveEditor.CursorTextXY.Y;
    P.Col := SourceEditorManagerIntf.ActiveEditor.CursorTextXY.X;
{$ELSE}
    P := View.CursorPos;
{$ENDIF}

    // 如果没拿到，光标所在最外层的 Token 尾，则硬性搜索 end
    if (LastLine < 0) and (P.Line <= SL.Count) then
    begin
      for I := P.Line + 1 to SL.Count - 1 do
      begin
        S := SL[I];
        if Length(S) = 4 then
        begin
          if (LowerCase(S) = 'end;') or (LowerCase(S) = 'end.') then
          begin
            LastLine := I;
            Break;
          end
          else if Length(S) > 4 then
          begin
            if (LowerCase(Copy(S, 1, 4)) = 'end;') or (LowerCase(Copy(S, 1, 4)) = 'end.')
              and (S[5] in [' ', '/', '{']) then // end; 或 end. 后是空格注释之类的
            begin
              LastLine := I;
              Break;
            end;
          end;
        end;
      end;
    end;

    // 找到末尾行
    if (LastLine > 0) and (LastLine > P.Line) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Continue Current File, Find Last Line at ' + IntToStr(LastLine));
{$ENDIF}
      for I := SL.Count - 1 downto LastLine + 1 do
        SL.Delete(SL.Count - 1);
    end;

    // 加入代码插入位置的标记
    if P.Line <= SL.Count then
    begin
      SL.Insert(P.Line, '');
      SL.Insert(P.Line, SCnAICoderWizardFlagContinueCoding);
      SL.Insert(P.Line, '');
    end
    else
    begin
      SL.Add('');
      SL.Add(SCnAICoderWizardFlagContinueCoding);
      SL.Add('');
    end;

    S := SL.Text;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Continue Current File. Sending Code Chars ' + IntToStr(Length(S)));
{$ENDIF}
  finally
    CppParser.Free;
    PasParser.Free;
    SL.Free;
    Mem.Free;
  end;

  EnsureChatWindowVisible(not UseChat);
  Msg := CnAICoderChatForm.ChatBox.Items.AddMessage;
  Msg.From := UIStringToNativeString(CnAIEngineManager.CurrentEngineName);
  Msg.FromType := cmtYou;
  Msg.Text := MSG_WAITING;
  Msg.Waiting := True;
  FFirstAnswer := True;

  if UseChat then
    CnAIEngineManager.CurrentEngine.AskAIEngineForCode(S, nil, Msg, artContinueCoding, ForContinueAnswerToChat)
  else
    CnAIEngineManager.CurrentEngine.AskAIEngineForCode(S, nil, Msg, artContinueCoding, ForContinueAnswerToEditor);
{$ENDIF}
end;

procedure TCnAICoderWizard.ForContinueAnswerToEditor(StreamMode, Partly, Success,
  IsStreamEnd: Boolean; SendId: Integer; const Answer: string;
  ErrorCode: Cardinal; Tag: TObject);
begin
  if (Tag <> nil) and (Tag is TCnChatMessage) then
  begin
    TCnChatMessage(Tag).Waiting := False;
    if Success then
    begin
      if Partly and (TCnChatMessage(Tag).Text <> MSG_WAITING)then
        TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer
      else
        TCnChatMessage(Tag).Text := Answer;

      // 本回调要写入编辑区
      if Answer <> '' then
      begin
        // 判断有无选择区，避免覆盖选择区内容
        if CnOtaGetCurrentSelection <> '' then // 取消选择，并下移光标
          CnOtaDeSelection(True);

        if FFirstAnswer then // 第一个回应前加个回车，避免在本行续写代码
          CnOtaInsertTextIntoEditor(#13#10 + Answer)
        else
          CnOtaInsertTextIntoEditor(Answer);
        FFirstAnswer := False;
      end;
    end
    else
    begin
      EnsureChatWindowVisible;
      TCnChatMessage(Tag).Text := Format('%d %s', [ErrorCode, Answer]);
    end;
  end
  else
  begin
    EnsureChatWindowVisible;
    if Success then
      CnAICoderChatForm.AddMessage(Answer, CnAIEngineManager.CurrentEngineName)
    else
      CnAICoderChatForm.AddMessage(Format('%d %s', [ErrorCode, Answer]), CnAIEngineManager.CurrentEngineName);
  end;
end;

procedure TCnAICoderWizard.ForContinueAnswerToChat(StreamMode, Partly,
  Success, IsStreamEnd: Boolean; SendId: Integer; const Answer: string;
  ErrorCode: Cardinal; Tag: TObject);
begin
  if (Tag <> nil) and (Tag is TCnChatMessage) then
  begin
    TCnChatMessage(Tag).Waiting := False;
    if Success then
    begin
      if Partly and (TCnChatMessage(Tag).Text <> MSG_WAITING)then
        TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer
      else
        TCnChatMessage(Tag).Text := Answer;
    end
    else
    begin
      EnsureChatWindowVisible;
      TCnChatMessage(Tag).Text := Format('%d %s', [ErrorCode, Answer]);
    end;
  end
  else
  begin
    EnsureChatWindowVisible;
    if Success then
      CnAICoderChatForm.AddMessage(Answer, CnAIEngineManager.CurrentEngineName)
    else
      CnAICoderChatForm.AddMessage(Format('%d %s', [ErrorCode, Answer]), CnAIEngineManager.CurrentEngineName);
  end;
end;

procedure TCnAICoderConfigForm.btnShortCutClick(Sender: TObject);
var
  AWizard: TCnAICoderWizard;
begin
  AWizard := TCnAICoderWizard(CnWizardMgr.WizardByClass(TCnAICoderWizard));
  if (AWizard <> nil) and AWizard.ShowShortCutDialog(GetHelpTopic) then
    AWizard.DoSaveSettings;
end;

initialization
  RegisterCnWizard(TCnAICoderWizard); // 注册专家

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
