{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

unit CnWizMultiLang;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家包多语控制单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2009.01.07
*               加入位置保存功能
*           2004.11.19 V1.4
*               修正因多语切换引起的Scaled=False时字体还是会Scaled的BUG (shenloqi)
*           2004.11.18 V1.3
*               将TCnTranslateForm.FScaler由Private变为Protected (shenloqi)
*           2003.10.30 V1.2
*               增加返回 F1 显示帮助主题的虚拟方法 GetHelpTopic
*           2003.10.20 V1.1
*               增加无语言文件时的处理
*           2003.08.23 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF DELPHI2007}
// RAD Studio 2007 下开启 AutoComplete 会导致输入中文后退格乱码
{$DEFINE COMBOBOX_CHS_BUG}
{$ENDIF}

{$IFDEF COMPILER12}
// RAD Studio 2009 下 CreateParams 中可能导致死循环
{$DEFINE CREATE_PARAMS_BUG}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Forms, ActnList, Controls, Menus,
  IniFiles, StdCtrls,
{$IFNDEF STAND_ALONE}
  CnConsts, CnWizClasses, CnWizManager, CnWizUtils, CnWizOptions, CnDesignEditor,
  CnWizTranslate, CnLangUtils,
{$ELSE}
  CnWizLangID,
{$ENDIF}
  CnWizConsts, CnCommon, CnLangMgr, CnHashLangStorage, CnLangStorage, CnWizHelp,
  CnFormScaler, CnWizIni;

type

{$IFNDEF STAND_ALONE}

{ TCnWizMultiLang }

  TCnWizMultiLang = class(TCnSubMenuWizard)
  private
    Indexes: array of Integer;
  protected
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    class procedure OnLanguageChanged(Sender: TObject);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AcquireSubActions; override;
    procedure RefreshSubActions; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    class function IsInternalWizard: Boolean; override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

{$ENDIF}

  TCnTranslateForm = class(TForm)
  private
    FActionList: TActionList;
    FHelpAction: TAction;
    procedure OnLanguageChanged(Sender: TObject);
    procedure OnHelp(Sender: TObject);
  protected
    FScaler: TCnFormScaler;

    procedure Loaded; override;
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure DoHelpError; virtual;

{$IFDEF CREATE_PARAMS_BUG}
    procedure CreateParams(var Params: TCreateParams); override;
{$ENDIF}

    procedure InitFormControls; virtual;
    {* 初始化窗体子控件}
    procedure DoLanguageChanged(Sender: TObject); virtual;
    {* 当前语言变更通知}
    function GetHelpTopic: string; virtual;
    {* 子类窗体重载此方法返回 F1 对应的帮助主题名称}
    function GetNeedPersistentPosition: Boolean; virtual;
    {* 子类窗体重载此方法返回是否需要保存窗体大小和位置供下次重启后恢复，默认不需要}
    procedure ShowFormHelp;
  public
    procedure Translate; virtual;
    {* 进行全窗体翻译}
  end;

function CnLangMgr: TCnCustomLangManager;
{* CnLanguageManager 的简略封装，保证返回的管理器能进行翻译 }

procedure InitLangManager;

function GetFileFromLang(const FileName: string): string;

implementation

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF DEBUG}

const
  csLanguage = 'Language';
  csEnglishID = 1033;

{$IFDEF STAND_ALONE}
  csLangDir = 'Lang\';
  csHelpDir = 'Help\';
{$ENDIF}

var
  FStorage: TCnHashLangFileStorage;

procedure InitLangManager;
var
  LangID: Cardinal;
begin
  CnLanguageManager.AutoTranslate := False;
  CnLanguageManager.TranslateTreeNode := True;
  CnLanguageManager.UseDefaultFont := True;
  FStorage := TCnHashLangFileStorage.Create(nil);
  FStorage.FileName := SCnWizLangFile;
  FStorage.StorageMode := smByDirectory;

  try
{$IFNDEF STAND_ALONE}
    FStorage.LanguagePath := WizOptions.LangPath;
{$ELSE}
    FStorage.LanguagePath := ExtractFilePath(ParamStr(0)) + csLangDir;
{$ENDIF}
  except
    ; // 屏蔽自动检测语言文件时可能出的错
{$IFDEF DEBUG}
    CnDebugger.LogMsgError('Language Storage Initialization Error.');
{$ENDIF DEBUG}
  end;
  CnLanguageManager.LanguageStorage := FStorage;

{$IFNDEF STAND_ALONE}
  LangID := WizOptions.CurrentLangID;
{$ELSE}
  LangID := GetWizardsLanguageID;
{$ENDIF}

  if FStorage.Languages.Find(LangID) >= 0 then
    CnLanguageManager.CurrentLanguageIndex := FStorage.Languages.Find(LangID)
  else
  begin
{$IFNDEF STAND_ALONE}
    // 在设置的 LangID 不存在的时候，默认设置成英文
    WizOptions.CurrentLangID := csEnglishID;
{$ENDIF}
    CnLanguageManager.CurrentLanguageIndex := FStorage.Languages.Find(csEnglishID);
  end;
end;

// CnLanguageManager 的简略封装，保证返回的管理器不为nil且能进行翻译
function CnLangMgr: TCnCustomLangManager;
begin
  if CnLanguageManager = nil then
    CreateLanguageManager;
  if CnLanguageManager.LanguageStorage = nil then
    InitLangManager;

  Result := CnLanguageManager;
end;

function GetFileFromLang(const FileName: string): string;
begin
  Result := CnWizHelp.GetFileFromLang(FileName);
end;

{$IFNDEF STAND_ALONE}

{ TCnWizMultiLang }

constructor TCnWizMultiLang.Create;
begin
  if CnLanguageManager <> nil then
    CnLanguageManager.OnLanguageChanged := Self.OnLanguageChanged;

  inherited;
  // 因为本 Wizard 不会被 Loaded调用，故需要手工 AcquireSubActions;
  if (CnLanguageManager.LanguageStorage <> nil)
    and (CnLanguageManager.LanguageStorage.LanguageCount > 0) then
    AcquireSubActions
  else
    Self.Active := False;
end;

procedure TCnWizMultiLang.AcquireSubActions;
var
  I: Integer;
  S: string;
begin
  if FStorage.LanguageCount > 0 then
    SetLength(Self.Indexes, FStorage.LanguageCount);
  for I := 0 to FStorage.LanguageCount - 1 do
  begin
    S := CnLanguages.NameFromLocaleID[FStorage.Languages[I].LanguageID];
    S := StringReplace(S, '台湾', '中国台湾', [rfReplaceAll]);
    Self.Indexes[I] := RegisterASubAction(csLanguage + InttoStr(I) + FStorage.
      Languages[I].Abbreviation, FStorage.Languages[I].LanguageName + ' - ' +
      S, 0, FStorage.Languages[I].LanguageName);
  end;
end;

destructor TCnWizMultiLang.Destroy;
begin
  if FStorage <> nil then
    FreeAndNil(FStorage);
  inherited;
end;

function TCnWizMultiLang.GetCaption: string;
begin
  Result := SCnWizMultiLangCaption;
end;

function TCnWizMultiLang.GetHint: string;
begin
  Result := SCnWizMultiLangHint;
end;

class procedure TCnWizMultiLang.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnWizMultiLangName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnWizMultiLangComment;
end;

class function TCnWizMultiLang.IsInternalWizard: Boolean;
begin
  Result := True;
end;

// 语言事件改变的处理事件
class procedure TCnWizMultiLang.OnLanguageChanged(Sender: TObject);
begin
  if (CnLanguageManager <> nil) and (CnLanguageManager.LanguageStorage <> nil)
    and (CnLanguageManager.LanguageStorage.LanguageCount > 0) then
  begin
    CnTranslateConsts(Sender);
    CnWizardMgr.RefreshLanguage;
    CnWizardMgr.ChangeWizardLanguage;
    CnDesignEditorMgr.LanguageChanged(Sender);
  end;
end;

procedure TCnWizMultiLang.RefreshSubActions;
begin
// 什么也不做，也不 inherited, 以阻止子 Action 被刷新。
end;

procedure TCnWizMultiLang.SubActionExecute(Index: Integer);
var
  i: Integer;
begin
  for i := Low(Indexes) to High(Indexes) do
    if Indexes[i] = Index then
    begin
      CnLanguageManager.CurrentLanguageIndex := i;
      WizOptions.CurrentLangID := FStorage.Languages[i].LanguageID;
    end;
end;

procedure TCnWizMultiLang.SubActionUpdate(Index: Integer);
var
  i: Integer;
begin
  for i := Low(Indexes) to High(Indexes) do
    SubActions[i].Checked := WizOptions.CurrentLangID =
      FStorage.Languages[i].LanguageID;
end;

{$ENDIF}

{ TCnTranslateForm }

procedure TCnTranslateForm.DoCreate;
begin
  FActionList := TActionList.Create(Self);
  FHelpAction := TAction.Create(Self);
  FHelpAction.ShortCut := ShortCut(VK_F1, []);
  FHelpAction.OnExecute := OnHelp;
  FHelpAction.ActionList := FActionList;
  DisableAlign;
  try
    Translate;
    if not Scaled then
      Font.Height := MulDiv(Font.Height, FScaler.DesignPPI, PixelsPerInch);
  finally
    EnableAlign;
  end;
  DoLanguageChanged(CnLanguageManager);
  inherited;
end;

procedure TCnTranslateForm.DoDestroy;
{$IFNDEF STAND_ALONE}
var
  Ini: TCustomIniFile;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  // 保存位置，但停靠不保存
  if (Parent = nil) and GetNeedPersistentPosition and (Position in [poDesigned,
    poDefault, poDefaultPosOnly, poDefaultSizeOnly]) then
  begin
    Ini := WizOptions.CreateRegIniFile;
    try
      Ini.WriteInteger(SCnFormPosition, ClassName + SCnFormPositionTop, Top);
      Ini.WriteInteger(SCnFormPosition, ClassName + SCnFormPositionLeft, Left);
      Ini.WriteInteger(SCnFormPosition, ClassName + SCnFormPositionWidth, Width);
      Ini.WriteInteger(SCnFormPosition, ClassName + SCnFormPositionHeight, Height);
    finally
      Ini.Free;
    end;
  end;
{$ENDIF}

  FScaler.Free;
  FHelpAction.Free;
  FActionList.Free;
  if CnLanguageManager <> nil then
    CnLanguageManager.RemoveChangeNotifier(OnLanguageChanged);
  inherited;
end;

procedure TCnTranslateForm.DoHelpError;
begin
  ErrorDlg(SCnNoHelpofThisLang);
end;

procedure TCnTranslateForm.DoLanguageChanged(Sender: TObject);
begin
  // 基类啥都不干
end;

function TCnTranslateForm.GetHelpTopic: string;
begin
  Result := '';
end;

procedure TCnTranslateForm.InitFormControls;
{$IFDEF COMBOBOX_CHS_BUG}
var
  i: Integer;
{$ENDIF}
begin
{$IFDEF COMBOBOX_CHS_BUG}
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TCustomComboBox then
      TComboBox(Components[i]).AutoComplete := False;
{$ENDIF}
end;

procedure TCnTranslateForm.Loaded;
{$IFNDEF STAND_ALONE}
var
  Ini: TCustomIniFile;
  I: Integer;
{$ENDIF}
begin
  inherited;
  FScaler := TCnFormScaler.Create(Self);
  FScaler.DoEffects;
  InitFormControls;

{$IFNDEF STAND_ALONE}
  // 读取并恢复位置
  if GetNeedPersistentPosition then
  begin
    Ini := WizOptions.CreateRegIniFile;
    try
      I := Ini.ReadInteger(SCnFormPosition, ClassName + SCnFormPositionTop, -1);
      if I <> -1 then Top := I;
      I := Ini.ReadInteger(SCnFormPosition, ClassName + SCnFormPositionLeft, -1);
      if I <> -1 then Left := I;
      I := Ini.ReadInteger(SCnFormPosition, ClassName + SCnFormPositionWidth, -1);
      if I <> -1 then Width := I;
      I := Ini.ReadInteger(SCnFormPosition, ClassName + SCnFormPositionHeight, -1);
      if I <> -1 then Height := I;

      Position := poDesigned;
    finally
      Ini.Free;
    end;
  end;
{$ENDIF}
end;

{$IFDEF CREATE_PARAMS_BUG}

procedure TCnTranslateForm.CreateParams(var Params: TCreateParams);
var
  OldLong: Longint;
  AHandle: THandle;
  NeedChange: Boolean;
begin
  NeedChange := False;
  OldLong := 0;
  AHandle := Application.ActiveFormHandle;
  if AHandle <> 0 then
  begin
    OldLong := GetWindowLong(AHandle, GWL_EXSTYLE);
    NeedChange := OldLong and WS_EX_TOOLWINDOW = WS_EX_TOOLWINDOW;
    if NeedChange then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnTranslateForm: D2009 Bug fix: HWnd for WS_EX_TOOLWINDOW style.');
{$ENDIF}
      SetWindowLong(AHandle, GWL_EXSTYLE, OldLong and not WS_EX_TOOLWINDOW);
    end;
  end;

  inherited; // 先处理完当前窗口的风格后调用原例程，之后恢复

  if NeedChange and (OldLong <> 0) then
    SetWindowLong(AHandle, GWL_EXSTYLE, OldLong);
end;

{$ENDIF}

procedure TCnTranslateForm.OnHelp(Sender: TObject);
var
  Topic: string;
begin
  Topic := GetHelpTopic;
  if Topic <> '' then
  begin
{$IFDEF STAND_ALONE}
    if not CnWizHelp.ShowHelp(Topic) then
      DoHelpError;
{$ELSE}
    CnWizUtils.ShowHelp(Topic);
{$ENDIF}
  end;
end;

procedure TCnTranslateForm.OnLanguageChanged(Sender: TObject);
begin
  DisableAlign;
  try
    CnLanguageManager.TranslateForm(Self);
    if not Scaled then
      Font.Height := MulDiv(Font.Height, FScaler.DesignPPI, PixelsPerInch);
  finally
    EnableAlign;
  end;
  DoLanguageChanged(Sender);
end;

procedure TCnTranslateForm.ShowFormHelp;
begin
  FHelpAction.Execute;
end;

procedure TCnTranslateForm.Translate;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnTranslateForm.Translate');
{$ENDIF DEBUG}
  if (CnLanguageManager <> nil) and (CnLanguageManager.LanguageStorage <> nil)
    and (CnLanguageManager.LanguageStorage.LanguageCount > 0) then
  begin
    CnLanguageManager.AddChangeNotifier(OnLanguageChanged);
    Screen.Cursor := crHourGlass;
    try
      CnLanguageManager.TranslateForm(Self);
    finally
      Screen.Cursor := crDefault;
    end;
  end
  else
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsgError('MultiLang Initialization Error. Use Chinese Font as default.');
{$ENDIF DEBUG}
    // 因初始化失败而无语言条目，因原始窗体是中文，故设置为中文字体
    Font.Charset := GB2312_CHARSET;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnTranslateForm.Translate');
{$ENDIF DEBUG}
end;

function TCnTranslateForm.GetNeedPersistentPosition: Boolean;
begin
  Result := False;
end;

initialization
{$IFDEF STAND_ALONE}
  CreateLanguageManager;
  InitLangManager;
{$ENDIF}

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnWizMultiLang finalization.');
{$ENDIF DEBUG}

  if FStorage <> nil then
    FreeAndNil(FStorage);

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnWizMultiLang finalization.');
{$ENDIF DEBUG}
end.




