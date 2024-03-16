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

unit CnWizMultiLang;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家包多语控制单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：OldCreateOrder 必须为 False，才能正常调整边距
*           AutoScroll 必须为 False，才能正常缩放
*           所以要检查凡是 Sizable 的 Form，AutoScroll自动为 True，要手工改回来。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2018.07.10
*               增加手动缩放的机制，不缩放时才应用 CnFormScaler。
*           2018.02.07
*               调整因主题不同导致客户区尺寸变化导致右下角控件显示不完全的问题。
*           2012.11.30
*               不使用 CnFormScaler 来处理字体，改用固定的96/72进行字体尺寸计算。
*           2009.01.07
*               加入位置保存功能
*           2004.11.19 V1.4
*               修正因多语切换引起的 Scaled=False 时字体还是会 Scaled 的 BUG (shenloqi)
*           2004.11.18 V1.3
*               将 TCnTranslateForm.FScaler 由 Private 变为 Protected (shenloqi)
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

{$IFDEF TEST_APP}           // 是独立测试程序，必然是独立应用，本单元这里补一个
  {$DEFINE STAND_ALONE}
{$ENDIF}

// TEST_APP    表示编译成独立应用的测试程序
// STAND_ALONE 表示编译成独立应用，应该包含测试程序的情况，工程选项里应该注意

uses
  Windows, Messages, SysUtils, Classes, Forms, ActnList, Controls, Menus, Contnrs,
{$IFNDEF TEST_APP}
{$IFNDEF STAND_ALONE}
  CnConsts, CnWizClasses, CnWizManager, CnWizUtils, CnWizOptions, CnDesignEditor,
  CnWizTranslate, CnLangUtils, CnWizScaler,
  {$IFDEF IDE_SUPPORT_THEMING} ToolsAPI, CnIDEMirrorIntf, {$ENDIF}
{$ELSE}
  CnWizLangID,
{$ENDIF}
  CnWizConsts, CnCommon, CnLangMgr, CnHashLangStorage, CnLangStorage, CnWizHelp,
  CnFormScaler, CnWizIni, CnLangCollection,
{$ENDIF}
  StdCtrls, ComCtrls, IniFiles;

type

{$IFNDEF STAND_ALONE}  // 非独立模式才定义 TCnWizMultiLang

{ TCnWizMultiLang }

  TCnWizMultiLang = class(TCnSubMenuWizard)
  private
    FIndexes: array of Integer;
  protected
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure WizLanguageChanged(Sender: TObject);
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
{$IFNDEF TEST_APP}
  private
{$IFNDEF STAND_ALONE}
    FEnlarge: TCnWizSizeEnlarge;
{$ENDIF}
    FActionList: TActionList;
    FHelpAction: TAction;
    procedure LanguageChanged(Sender: TObject);
    procedure OnHelp(Sender: TObject);
    procedure CheckDefaultFontSize;
    // 部分 Win7 主题会出现右下角超出窗体的现象，原因是 ClientHeight/ClientWidth
    // 会因为主题而缩小，遍历修复。注意重设 Anchors 时如果 FormCreate 事件里修改
    // 了尺寸，则会因为组件的 Explicit Bounds 导致尺寸复原，需要特殊处理，
    // 子类可重载 NeedAdjustRightBottomMargin 以不处理
    procedure AdjustRightBottomMargin;

    procedure ProcessSizeEnlarge;
    procedure ProcessGlyphForHDPI(AControl: TControl);
{$IFNDEF STAND_ALONE}
    function GetEnlarged: Boolean;
{$ENDIF}
{$ENDIF}
  protected
{$IFNDEF TEST_APP}
    FScaler: TCnFormScaler;

    procedure Loaded; override;
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure ReadState(Reader: TReader); override;
{$ENDIF}

    function NeedAdjustRightBottomMargin: Boolean; virtual;
    {* 控制子类是否要调整右下方向边距}

{$IFDEF CREATE_PARAMS_BUG}
    procedure CreateParams(var Params: TCreateParams); override;
{$ENDIF}

    procedure DoHelpError; virtual;
    procedure InitFormControls; virtual;
    {* 初始化窗体子控件}
    procedure DoLanguageChanged(Sender: TObject); virtual;
    {* 当前语言变更通知}
    function GetHelpTopic: string; virtual;
    {* 子类窗体重载此方法返回 F1 对应的帮助主题名称}
    function GetNeedPersistentPosition: Boolean; virtual;
    {* 子类窗体重载此方法返回是否需要保存窗体大小和位置供下次重启后恢复，默认不需要}
    procedure ShowFormHelp;
    {* 显示帮助内容}

{$IFNDEF STAND_ALONE}
    procedure EnlargeListViewColumns(ListView: TListView);
    {* 如果子类中有 ListView，可以用此方法来放大 ListView 的列宽}

    function CalcIntEnlargedValue(Value: Integer): Integer;
    {* 根据原始尺寸计算放大后的尺寸，给子类用的}
    function CalcIntUnEnlargedValue(Value: Integer): Integer;
    {* 根据放大后的尺寸计算原始尺寸，给子类用的}

    property Enlarge: TCnWizSizeEnlarge read FEnlarge;
    {* 供专家包子类窗口使用的缩放比例}
    property Enlarged: Boolean read GetEnlarged;
    {* 是否有缩放}
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;

    procedure Translate; virtual;
    {* 进行全窗体翻译}
  end;

  TCnTranslateFrame = class(TFrame)
  {* 拥有翻译功能的 TFrame 类，可独立翻译，不依赖于放置的宿主}
  protected
    procedure LanguageChanged(Sender: TObject);
    procedure Translate;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{$IFNDEF TEST_APP}
function CnLangMgr: TCnCustomLangManager;
{* CnLanguageManager 的简略封装，保证返回的管理器能进行翻译 }

procedure InitLangManager;

function GetFileFromLang(const FileName: string): string;

procedure RegisterThemeClass;
{$ENDIF}

implementation

{$R *.DFM}

{$IFNDEF STAND_ALONE}
uses
  CnWizShareImages {$IFDEF DEBUG}, CnDebug {$ENDIF};
{$ELSE}
{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}
{$ENDIF}

type
  TControlHack = class(TControl);

const
  csLanguage = 'Language';
  csEnglishID = 1033;

  csFixPPI = 96;
  csFixPerInch = 72;
  csRightBottomMargin = 8;

{$IFDEF STAND_ALONE}
  csLangDir = 'Lang\';
  csHelpDir = 'Help\';
{$ENDIF}

{$IFNDEF TEST_APP}
var
  FStorage: TCnHashLangFileStorage;
  FDefaultFontSize: Integer = 8;

procedure RegisterThemeClass;
{$IFDEF IDE_SUPPORT_THEMING}
var
  {$IFDEF DELPHI102_TOKYO}
  Theming: ICnOTAIDEThemingServices250;
  {$ELSE}
  Theming: IOTAIDEThemingServices250;
  {$ENDIF}
{$ENDIF}
begin
{$IFDEF IDE_SUPPORT_THEMING}
  if Supports(BorlandIDEServices, StringToGUID(GUID_IOTAIDETHEMINGSERVICES250), Theming) then
  begin
    Theming.RegisterFormClass(TCnTranslateForm);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('RegisterThemeClass to TCnTranslateForm.');
{$ENDIF}
  end;
{$ENDIF}
end;

procedure InitLangManager;
var
  LangID: Cardinal;
  Idx: Integer;
  Item: TCnLanguageItem;
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
    FStorage.LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangDir;
{$ENDIF}
  except
    ; // 屏蔽自动检测语言文件时可能出的错
{$IFDEF DEBUG}
    CnDebugger.LogMsgError('Language Storage Initialization Error.');
{$ENDIF DEBUG}
  end;

  // 将 2052 调整至首位
  Idx := FStorage.Languages.Find(2052);
  if Idx > 0 then
  begin
    Item := FStorage.Languages.Add;
    Item.Assign(FStorage.Languages.Items[Idx]);
    FStorage.Languages.Items[Idx].Assign(FStorage.Languages.Items[0]);
    FStorage.Languages.Items[0].Assign(Item);
    Item.Free;
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

// CnLanguageManager 的简略封装，保证返回的管理器不为 nil 且能进行翻译
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
{$ENDIF}

{$IFNDEF STAND_ALONE}

{ TCnWizMultiLang }

constructor TCnWizMultiLang.Create;
begin
  if CnLanguageManager <> nil then
    CnLanguageManager.OnLanguageChanged := WizLanguageChanged;

  inherited;
  // 因为本 Wizard 不会被 Loaded调用，故需要手工 AcquireSubActions;
  if (CnLanguageManager.LanguageStorage <> nil)
    and (CnLanguageManager.LanguageStorage.LanguageCount > 0) then
    AcquireSubActions
  else
    Active := False;
end;

procedure TCnWizMultiLang.AcquireSubActions;
var
  I: Integer;
  S: string;
begin
  if FStorage.LanguageCount > 0 then
    SetLength(FIndexes, FStorage.LanguageCount);
  for I := 0 to FStorage.LanguageCount - 1 do
  begin
    S := CnLanguages.NameFromLocaleID[FStorage.Languages[I].LanguageID];
    S := StringReplace(S, '台湾', '中国台湾', [rfReplaceAll]);
    FIndexes[I] := RegisterASubAction(csLanguage + InttoStr(I) + FStorage.
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
procedure TCnWizMultiLang.WizLanguageChanged(Sender: TObject);
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
  I: Integer;
begin
  for I := Low(FIndexes) to High(FIndexes) do
    if FIndexes[I] = Index then
    begin
      CnLanguageManager.CurrentLanguageIndex := I;
      WizOptions.CurrentLangID := FStorage.Languages[I].LanguageID;
    end;
end;

procedure TCnWizMultiLang.SubActionUpdate(Index: Integer);
var
  I: Integer;
begin
  for I := Low(FIndexes) to High(FIndexes) do
    SubActions[I].Checked := WizOptions.CurrentLangID =
      FStorage.Languages[I].LanguageID;
end;

{$ENDIF}

{$IFNDEF TEST_APP}

{ TCnTranslateForm }

procedure TCnTranslateForm.DoCreate;
{$IFDEF IDE_SUPPORT_THEMING}
var
  Theming: IOTAIDEThemingServices;
{$ENDIF}
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
    begin
      CheckDefaultFontSize;
      Font.Height := -MulDiv(FDefaultFontSize, csFixPPI, csFixPerInch);
    end;
  finally
    EnableAlign;
  end;
  DoLanguageChanged(CnLanguageManager);
  inherited;

{$IFDEF IDE_SUPPORT_THEMING}
  try
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, Theming) then
    if (Theming <> nil) and Theming.IDEThemingEnabled then
    begin
      Theming.ApplyTheme(Self);
{$IFDEF DEBUG}
      CnDebugger.LogMsg(ClassName + ' Apply Theme.');
{$ENDIF}
    end;
  except
    ; // Maybe cause NullPointer Exception in IDEServices.TIDEServices.ApplyTheme, Only catch it
{$IFDEF DEBUG}
    CnDebugger.LogMsg(ClassName + ' Apply Theme Error!');
{$ENDIF}
  end;
{$ENDIF}

{$IFNDEF STAND_ALONE}
{$IFDEF IDE_SUPPORT_HDPI}
  if Menu <> nil then
  begin
    if Menu.Images = dmCnSharedImages.Images then
      Menu.Images := dmCnSharedImages.VirtualImages;
  end;
{$ENDIF}
{$ENDIF}

  ProcessSizeEnlarge;
  ProcessGlyphForHDPI(Self);

  if NeedAdjustRightBottomMargin then
    AdjustRightBottomMargin;   // inherited 中会调用 FormCreate 事件，有可能改变了 Width/Height
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

  FHelpAction.Free;
  FActionList.Free;
  FScaler.Free;
  if CnLanguageManager <> nil then
    CnLanguageManager.RemoveChangeNotifier(LanguageChanged);
  inherited;
end;

procedure TCnTranslateForm.Loaded;
{$IFNDEF STAND_ALONE}
var
  Ini: TCustomIniFile;
  I: Integer;
{$ENDIF}
begin
{$IFDEF IDE_SUPPORT_HDPI}
  Scaled := True;
{$ENDIF}

  inherited;
  FScaler := TCnFormScaler.Create(Self);
{$IFNDEF STAND_ALONE}
  if not GetEnlarged then // 不放大时才处理
    FScaler.DoEffects;
{$ELSE}
  FScaler.DoEffects;
{$ENDIF}
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

procedure TCnTranslateForm.ReadState(Reader: TReader);
begin
  inherited;
  {$IFNDEF NO_OLDCREATEORDER}
  OldCreateOrder := False;
  {$ENDIF}
end;

{$IFDEF CREATE_PARAMS_BUG}

procedure TCnTranslateForm.CreateParams(var Params: TCreateParams);
var
  OldLong: LongInt;
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

{$ENDIF CREATE_PARAMS_BUG}

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

procedure TCnTranslateForm.AdjustRightBottomMargin;
var
  I, V, MinH, MinW, RightBottomMargin: Integer;
  AControl: TControlHack;
  List: TObjectList;
  AnchorsArray: array of TAnchors;
  Added: Boolean;
{$IFDEF DEBUG}
  C1, C2: Integer;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  RightBottomMargin := Round(csRightBottomMargin * GetFactorFromSizeEnlarge(FEnlarge));
{$ELSE}
  RightBottomMargin := csRightBottomMargin;
{$ENDIF}
  MinH := RightBottomMargin;
  MinW := RightBottomMargin;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('AdjustRightBottomMargin. Original Width %d, Height %d. ClientWidth %d, ClientHeight %d, BorderWidth %d.',
    [Width, Height, ClientWidth, ClientHeight, BorderWidth]);
{$ENDIF}

  List := TObjectList.Create(False);
  try
    for I := ControlCount - 1 downto 0 do
    begin
      if Controls[I].Align <> alNone then
        Continue;

      Added := False;
      V := ClientWidth - BorderWidth - Controls[I].Left - Controls[I].Width;
      if V < RightBottomMargin then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('AdjustRightBottomMargin. Found Width Beyond Controls: %s, %d. Left %d, Width %d.',
          [Controls[I].Name, V, Controls[I].Left, Controls[I].Width]);
{$ENDIF}

        List.Add(Controls[I]);
        Added := True;

        if V < MinW then
          MinW := V;
      end;

      V := ClientHeight - BorderWidth - Controls[I].Top - Controls[I].Height;
      if V < RightBottomMargin then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('AdjustRightBottomMargin. Found Height Beyond Controls: %s, %d. Top %d, Height %d.',
          [Controls[I].Name, V, Controls[I].Top, Controls[I].Height]);
{$ENDIF}
        if not Added then
          List.Add(Controls[I]);

        if V < MinH then
          MinH := V;
      end;
    end;

{$IFDEF DEBUG}
    C1 := 0;
    C2 := 0;
{$ENDIF}

    if List.Count > 0 then
    begin
      // List 中的控件，需要保存其 Anchors，然后设置 Left/Top
      // 然后根据 MinW/MinH 重设窗体宽高，然后将 Anchors 设置回来
      SetLength(AnchorsArray, List.Count);
      for I := 0 to List.Count - 1 do
      begin
        AControl := TControlHack(List[I]);
        AnchorsArray[I] := AControl.Anchors;
        if AControl.Anchors <> [akTop, akLeft] then
        begin
{$IFDEF TCONTROL_HAS_EXPLICIT_BOUNDS}
          AControl.UpdateExplicitBounds;
{$ENDIF}
          AControl.Anchors := [akTop, akLeft];
{$IFDEF DEBUG}
          Inc(C1);
{$ENDIF}
        end;
      end;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('AdjustRightBottomMargin Before Change Form Width %d, Height %d. %d Controls to Adjust.',
        [Width, Height, C1]);
{$ENDIF}

      if MinW < RightBottomMargin then
        Width := Width + (RightBottomMargin - MinW);
      if MinH < RightBottomMargin then
        Height := Height + (RightBottomMargin - MinH);

{$IFDEF DEBUG}
      CnDebugger.LogFmt('AdjustRightBottomMargin Changed Form to Width %d, Height %d.',
        [Width, Height]);
{$ENDIF}

      for I := 0 to List.Count - 1 do
      begin
        AControl := TControlHack(List[I]);
        if AControl.Anchors <> AnchorsArray[I] then
        begin
          AControl.Anchors := AnchorsArray[I];
{$IFDEF DEBUG}
          Inc(C2);
{$ENDIF}
        end;
      end;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('AdjustRightBottomMargin %d Controls Restored after Changing Form Size.',
        [C2]);
{$ENDIF}
    end;
  finally
    List.Free;
  end;
end;

procedure TCnTranslateForm.CheckDefaultFontSize;
var
  Storage: TCnCustomLangStorage;
  Language: TCnLanguageItem;
begin
  Storage := CnLanguageManager.LanguageStorage;
  Language := nil;
  if Storage <> nil then
  begin
    Language := Storage.CurrentLanguage;
    if Storage.FontInited and (Storage.DefaultFont <> nil) then
      FDefaultFontSize := Storage.DefaultFont.Size;
  end;

  if (Language <> nil) and (Language.DefaultFont <> nil) then
    FDefaultFontSize := Language.DefaultFont.Size;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTranslateForm.CheckDefaultFontSize. Get Default Font Size: ' + IntToStr(FDefaultFontSize));
{$ENDIF}        
end;

procedure TCnTranslateForm.LanguageChanged(Sender: TObject);
begin
  DisableAlign;
  try
    CnLanguageManager.TranslateForm(Self);
    if not Scaled then
    begin
      CheckDefaultFontSize;
      Font.Height := -MulDiv(FDefaultFontSize, csFixPPI, csFixPerInch);
    end;
  finally
    EnableAlign;
  end;
  DoLanguageChanged(Sender);
end;

{$ENDIF TEST_APP}

procedure TCnTranslateForm.InitFormControls;
{$IFDEF COMBOBOX_CHS_BUG}
var
  I: Integer;
{$ENDIF}
begin
{$IFDEF COMBOBOX_CHS_BUG}
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TCustomComboBox then
      TComboBox(Components[I]).AutoComplete := False;
{$ENDIF}
end;

procedure TCnTranslateForm.DoLanguageChanged(Sender: TObject);
begin
  // 基类啥都不干
end;

function TCnTranslateForm.GetHelpTopic: string;
begin
  Result := '';
end;

procedure TCnTranslateForm.DoHelpError;
begin
{$IFNDEF TEST_APP}
  ErrorDlg(SCnNoHelpofThisLang);
{$ENDIF TEST_APP}
end;

procedure TCnTranslateForm.ShowFormHelp;
begin
{$IFNDEF TEST_APP}
  FHelpAction.Execute;
{$ENDIF TEST_APP}
end;

procedure TCnTranslateForm.Translate;
begin
{$IFNDEF TEST_APP}
{$IFDEF DEBUG}
  CnDebugger.LogEnter(ClassName + '|TCnTranslateForm.Translate');
{$ENDIF DEBUG}
  if (CnLanguageManager <> nil) and (CnLanguageManager.LanguageStorage <> nil)
    and (CnLanguageManager.LanguageStorage.LanguageCount > 0) then
  begin
    CnLanguageManager.AddChangeNotifier(LanguageChanged);
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
    CnDebugger.LogMsgError('CnWizards Form MultiLang Initialization Error. Use English Font as default.');
{$ENDIF DEBUG}
    // 因初始化失败而无语言条目，因原始窗体是英文，故设置为英文字体
    Font.Charset := DEFAULT_CHARSET;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave(ClassName + '|TCnTranslateForm.Translate');
{$ENDIF DEBUG}
{$ENDIF TEST_APP}
end;

function TCnTranslateForm.GetNeedPersistentPosition: Boolean;
begin
  Result := False;
end;

constructor TCnTranslateForm.Create(AOwner: TComponent);
begin
{$IFNDEF STAND_ALONE}
  FEnlarge := WizOptions.SizeEnlarge;
{$ENDIF}
  inherited;
  // 避免 Loaded 时还未获得 FEnlarge 值
end;

{$IFNDEF TEST_APP}

procedure TCnTranslateForm.ProcessSizeEnlarge;
{$IFNDEF STAND_ALONE}
var
  Factor: Single;
  AEnlarge: TCnWizSizeEnlarge;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  if Enlarged then
  begin
    // 判断单显示器情况下，当前的放大倍数是否会超出 Screen 的尺寸，超则降档
    Factor := GetFactorFromSizeEnlarge(FEnlarge);
    if Screen.MonitorCount = 1 then
    begin
      AEnlarge := FEnlarge;
      while (Width * Factor >= Screen.Width - 30) or
        (Height * Factor >= Screen.Height - 30) do
      begin
        AEnlarge := TCnWizSizeEnlarge(Ord(AEnlarge) - 1);
        Factor := GetFactorFromSizeEnlarge(AEnlarge);

        if AEnlarge = wseOrigin then
          Exit;

{$IFDEF DEBUG}
        CnDebugger.LogFmt('Form %s Width %d Height %d Bigger Than Screen if Enlarged. Shrink it.',
          [ClassName, Width, Height]);
{$ENDIF}
      end;
      FEnlarge := AEnlarge; // 保存修剪过的放大倍数
    end;

    ScaleForm(Self, Factor);
  end;
{$ENDIF}
end;

{$IFNDEF STAND_ALONE}

procedure TCnTranslateForm.EnlargeListViewColumns(ListView: TListView);
var
  I: Integer;
begin
  if (FEnlarge = wseOrigin) or (ListView = nil) or (ListView.ViewStyle <> vsReport) then
    Exit;

  for I := 0 to ListView.Columns.Count - 1 do
    if ListView.Columns[I].Width > 0 then
      ListView.Columns[I].Width := Round(ListView.Columns[I].Width * GetFactorFromSizeEnlarge(FEnlarge));
end;

function TCnTranslateForm.CalcIntEnlargedValue(Value: Integer): Integer;
begin
  Result := WizOptions.CalcIntEnlargedValue(FEnlarge, Value);
end;

function TCnTranslateForm.CalcIntUnEnlargedValue(Value: Integer): Integer;
begin
  Result := WizOptions.CalcIntUnEnlargedValue(FEnlarge, Value);
end;

{$ENDIF}

{$IFNDEF STAND_ALONE}

function TCnTranslateForm.GetEnlarged: Boolean;
begin
  Result := FEnlarge <> wseOrigin;
end;

{$ENDIF}

procedure TCnTranslateForm.ProcessGlyphForHDPI(AControl: TControl);
{$IFDEF IDE_SUPPORT_HDPI}
var
  I: Integer;
  W: TWinControl;
{$ENDIF}
begin
{$IFDEF IDE_SUPPORT_HDPI}
  if AControl.ClassNameIs('TSpeedButton') or AControl.ClassNameIs('TBitBtn') then
    CnEnlargeButtonGlyphForHDPI(AControl);

  if AControl is TWinControl then
  begin
    W := AControl as TWinControl;
    for I := 0 to W.ControlCount - 1 do
      ProcessGlyphForHDPI(W.Controls[I]);
  end;
{$ENDIF}
end;

function TCnTranslateForm.NeedAdjustRightBottomMargin: Boolean;
begin
  Result := True;
end;

{ TCnTranslateFrame }

constructor TCnTranslateFrame.Create(AOwner: TComponent);
begin
  inherited;
  DisableAlign;
  try
    Translate;
  finally
    EnableAlign;
  end;
  CnLanguageManager.AddChangeNotifier(LanguageChanged);
end;

destructor TCnTranslateFrame.Destroy;
begin
  CnLanguageManager.RemoveChangeNotifier(LanguageChanged);
  inherited;
end;

procedure TCnTranslateFrame.LanguageChanged(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTranslateFrame.LanguageChanged');
{$ENDIF}
  DisableAlign;
  try
    CnLanguageManager.TranslateFrame(Self);
  finally
    EnableAlign;
  end;
end;

procedure TCnTranslateFrame.Translate;
begin
  if (CnLanguageManager <> nil) and (CnLanguageManager.LanguageStorage <> nil)
    and (CnLanguageManager.LanguageStorage.LanguageCount > 0) then
  begin
    Screen.Cursor := crHourGlass;
    try
      CnLanguageManager.TranslateFrame(Self);
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

initialization
{$IFDEF STAND_ALONE}
  CreateLanguageManager;
  InitLangManager;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnWizMultiLang.');
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

{$ENDIF TEST_APP}
end.
