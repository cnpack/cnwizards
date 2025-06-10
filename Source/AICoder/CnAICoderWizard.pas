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
  ToolsAPI, IniFiles,ComCtrls, StdCtrls, CnConsts, CnWizClasses, CnWizUtils,
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
    procedure cbbActiveEngineChange(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
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
    function ValidateAIEngines: Boolean;
    {* 调用各个功能前检查 AI 引擎及配置}
    procedure EnsureChatWindowVisible(OnlyCreate: Boolean = False);
    {* 确保创建 ChatWindow 且其 Visible 为 True 及其所有 Parent 的 Visible 全为 True
      以确保聊天窗口可见}
    procedure EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);

    procedure ContinueCurrentFile;
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

    procedure ForContinueAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean;
      SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    {* 续写代码的回调}

    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
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
  CnEditControlWrapper {$IFDEF DEBUG} , CnDebug {$ENDIF};

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
  EditControlWrapper.AddSysKeyDownNotifier(EditorKeyDown);
  IdeDockManager.RegisterDockableForm(TCnAICoderChatForm, CnAICoderChatForm,
    csAICoderChatForm);
end;

destructor TCnAICoderWizard.Destroy;
begin
  IdeDockManager.UnRegisterDockableForm(CnAICoderChatForm, csAICoderChatForm);
  EditControlWrapper.RemoveSysKeyDownNotifier(EditorKeyDown);
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
        Msg.From := CnAIEngineManager.CurrentEngineName;
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
        Msg.From := CnAIEngineManager.CurrentEngineName;
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

  CnAICoderChatForm.VisibleWithParent := True;
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
  if not Active then
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

procedure TCnAICoderWizard.ContinueCurrentFile;
var
  S: string;
  SL: TStringList;
  Mem: TMemoryStream;
  View: IOTAEditView;
  P: TOTAEditPos;
  Msg: TCnChatMessage;
begin
  // 收集本文件从开始到光标这行的内容，并发送，并编辑器接收回应
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  S := '';
  Mem := nil;
  SL := nil;

  try
    Mem := TMemoryStream.Create;
    SL := TStringList.Create;
    CnGeneralSaveEditorToStream(nil, Mem);
    Mem.Position := 0;

    SL.LoadFromStream(Mem);
    P := View.CursorPos;

    while SL.Count > P.Line do
      SL.Delete(SL.Count - 1);

    S := SL.Text;
  finally
    SL.Free;
    Mem.Free;
  end;

  EnsureChatWindowVisible(True);
  Msg := CnAICoderChatForm.ChatBox.Items.AddMessage;
  Msg.From := CnAIEngineManager.CurrentEngineName;
  Msg.FromType := cmtYou;
  Msg.Text := MSG_WAITING;
  Msg.Waiting := True;

  CnAIEngineManager.CurrentEngine.AskAIEngineForCode(S, nil, Msg, artContinueCoding, ForContinueAnswer);
end;

procedure TCnAICoderWizard.ForContinueAnswer(StreamMode, Partly, Success,
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

      if Answer <> '' then
      begin
        // 判断有无选择区，避免覆盖选择区内容
        if CnOtaGetCurrentSelection <> '' then // 取消选择，并下移光标
          CnOtaDeSelection(True);

        CnOtaInsertTextIntoEditor(Answer);
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

initialization
  RegisterCnWizard(TCnAICoderWizard); // 注册专家

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
