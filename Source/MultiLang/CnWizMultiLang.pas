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

unit CnWizMultiLang;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�ר�Ұ�������Ƶ�Ԫ
* ��Ԫ���ߣ�CnPack ������ master@cnpack.org
* ��    ע��OldCreateOrder ����Ϊ False���������������߾�
*           AutoScroll ����Ϊ False��������������
*           ����Ҫ��鷲�� Sizable �� Form��AutoScroll�Զ�Ϊ True��Ҫ�ֹ��Ļ�����
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2018.07.10
*               �����ֶ����ŵĻ��ƣ�������ʱ��Ӧ�� CnFormScaler��
*           2018.02.07
*               ���������ⲻͬ���¿ͻ����ߴ�仯�������½ǿؼ���ʾ����ȫ�����⡣
*           2012.11.30
*               ��ʹ�� CnFormScaler ���������壬���ù̶���96/72��������ߴ���㡣
*           2009.01.07
*               ����λ�ñ��湦��
*           2004.11.19 V1.4
*               ����������л������ Scaled=False ʱ���廹�ǻ� Scaled �� BUG (shenloqi)
*           2004.11.18 V1.3
*               �� TCnTranslateForm.FScaler �� Private ��Ϊ Protected (shenloqi)
*           2003.10.30 V1.2
*               ���ӷ��� F1 ��ʾ������������ⷽ�� GetHelpTopic
*           2003.10.20 V1.1
*               �����������ļ�ʱ�Ĵ���
*           2003.08.23 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF TEST_APP}           // �Ƕ������Գ��򣬱�Ȼ�Ƕ���Ӧ�ã�����Ԫ���ﲹһ��
  {$DEFINE STAND_ALONE}
{$ENDIF}

// TEST_APP    ��ʾ����ɶ���Ӧ�õĲ��Գ���
// STAND_ALONE ��ʾ����ɶ���Ӧ�ã�Ӧ�ð������Գ�������������ѡ����Ӧ��ע��

uses
  Windows, Messages, SysUtils, Classes, Forms, ActnList, Controls, Menus, Contnrs,
{$IFNDEF STAND_ALONE}
  CnDesignEditor, CnWizScaler,
  {$IFDEF IDE_SUPPORT_THEMING} ToolsAPI, CnIDEMirrorIntf, {$ENDIF}
{$ELSE}
  CnWizLangID, 
{$ENDIF}
  CnConsts, CnWizClasses, CnLangUtils, CnWizTranslate, CnWizManager, CnWizOptions,
  CnWizConsts, CnCommon, CnLangMgr, CnHashLangStorage, CnLangStorage, CnWizHelp,
  CnWizUtils, CnWizIdeUtils, CnFormScaler, CnWizIni, CnLangCollection,
  StdCtrls, ComCtrls, IniFiles;

type

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

  { TCnTranslateForm }

  TCnTranslateForm = class(TForm)
  private
    FEnlarge: TCnWizSizeEnlarge;
    FActionList: TActionList;
    FHelpAction: TAction;
    procedure LanguageChanged(Sender: TObject);
    procedure OnHelp(Sender: TObject);
    procedure CheckDefaultFontSize;
    // ���� Win7 �����������½ǳ������������ԭ���� ClientHeight/ClientWidth
    // ����Ϊ�������С�������޸���ע������ Anchors ʱ��� FormCreate �¼����޸�
    // �˳ߴ磬�����Ϊ����� Explicit Bounds ���³ߴ縴ԭ����Ҫ���⴦��
    // ��������� NeedAdjustRightBottomMargin �Բ�����
    procedure AdjustRightBottomMargin;

    procedure ProcessSizeEnlarge;
    procedure ProcessGlyphForHDPI(AControl: TControl);
    procedure ProcessLazarusFormClientSize;
    {* �ú�����Ϊ�� FPC �и��� Delphi ��ƵĴ��������е��޲���
       Delphi ��ƴ����ڲ�������»Ὣ�ߴ籣���� ClientHeight �� ClientWidth �����У�
       ������ Width �� Height���� FPC ����ʹ�� DFM/LFM �м�¼�� ClientHeight �� ClientWidth����
       ����������ߴ磬���´������ഴ����ĳߴ���Զ�ǻ���ߴ硣
       �˴���һ���޲����ڴ��� Loading ��ɺ������ٶ�ȡ����һ�±������ DFM ��Դ�ַ�����
       �ҳ����е� ClientHeight �� ClientWidth ���Ե�ֵ���Դ���� Width �� Height �������¸�ֵ��}
    procedure ProcessLazarusGroupBoxOffset;
    {* Delphi �� Lazarus �� TGroupBox���ڲ��ؼ��� Y ������ƫ���Լ 16����Ҫ��ȥ}

    function GetEnlarged: Boolean;

  protected
    FScaler: TCnFormScaler;

    procedure Loaded; override;
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure ReadState(Reader: TReader); override;

    function NeedAdjustRightBottomMargin: Boolean; virtual;
    {* ���������Ƿ�Ҫ�������·���߾�}

{$IFDEF CREATE_PARAMS_BUG}
    procedure CreateParams(var Params: TCreateParams); override;
{$ENDIF}

    procedure DoHelpError; virtual;
    procedure InitFormControls; virtual;
    {* ��ʼ�������ӿؼ�}
    procedure DoLanguageChanged(Sender: TObject); virtual;
    {* ��ǰ���Ա��֪ͨ}
    function GetHelpTopic: string; virtual;
    {* ���ര�����ش˷������� F1 ��Ӧ�İ�����������}
    function GetNeedPersistentPosition: Boolean; virtual;
    {* ���ര�����ش˷��������Ƿ���Ҫ���洰���С��λ�ù��´�������ָ���Ĭ�ϲ���Ҫ}
    procedure ShowFormHelp;
    {* ��ʾ��������}

    procedure EnlargeListViewColumns(ListView: TListView);
    {* ����������� ListView�������ô˷������Ŵ� ListView ���п�}

    function CalcIntEnlargedValue(Value: Integer): Integer;
    {* ����ԭʼ�ߴ����Ŵ��ĳߴ磬�������õ�}
    function CalcIntUnEnlargedValue(Value: Integer): Integer;
    {* ���ݷŴ��ĳߴ����ԭʼ�ߴ磬�������õ�}

    property Enlarge: TCnWizSizeEnlarge read FEnlarge;
    {* ��ר�Ұ����ര��ʹ�õ����ű���}
    property Enlarged: Boolean read GetEnlarged;
    {* �Ƿ�������}

  public
    constructor Create(AOwner: TComponent); override;

    procedure Translate; virtual;
    {* ����ȫ���巭��}
  end;

function CnWizLangMgr: TCnCustomLangManager;
{* CnLanguageManager �ļ��Է�װ����֤���صĹ������ܽ��з��� }

procedure InitLangManager;

function GetFileFromLang(const FileName: string): string;

procedure RegisterThemeClass;

implementation

{$R *.DFM}

uses
  CnWizShareImages {$IFDEF DEBUG}, CnDebug {$ENDIF};

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
    ; // �����Զ���������ļ�ʱ���ܳ��Ĵ�
{$IFDEF DEBUG}
    CnDebugger.LogMsgError('Language Storage Initialization Error.');
{$ENDIF}
  end;

  // �� 2052 ��������λ
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
    // �����õ� LangID �����ڵ�ʱ��Ĭ�����ó�Ӣ��
    WizOptions.CurrentLangID := csEnglishID;
{$ENDIF}
    CnLanguageManager.CurrentLanguageIndex := FStorage.Languages.Find(csEnglishID);
  end;
end;

// CnLanguageManager �ļ��Է�װ����֤���صĹ�������Ϊ nil ���ܽ��з���
function CnWizLangMgr: TCnCustomLangManager;
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

{ TCnWizMultiLang }

constructor TCnWizMultiLang.Create;
begin
  if CnLanguageManager <> nil then
    CnLanguageManager.OnLanguageChanged := WizLanguageChanged;

  inherited;
  // ��Ϊ�� Wizard ���ᱻ Loaded���ã�����Ҫ�ֹ� AcquireSubActions;
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
    if Pos('�й�', S) <= 0 then
      S := StringReplace(S, '̨��', '�й�̨��', [rfReplaceAll]);
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

// �����¼��ı�Ĵ����¼�
procedure TCnWizMultiLang.WizLanguageChanged(Sender: TObject);
begin
  if (CnLanguageManager <> nil) and (CnLanguageManager.LanguageStorage <> nil)
    and (CnLanguageManager.LanguageStorage.LanguageCount > 0) then
  begin
    CnTranslateConsts(Sender);
    CnWizardMgr.RefreshLanguage;
    CnWizardMgr.ChangeWizardLanguage;
{$IFNDEF STAND_ALONE}
    CnDesignEditorMgr.LanguageChanged(Sender);
{$ENDIF}
  end;
end;

procedure TCnWizMultiLang.RefreshSubActions;
begin
// ʲôҲ������Ҳ�� inherited, ����ֹ�� Action ��ˢ�¡�
end;

procedure TCnWizMultiLang.SubActionExecute(Index: Integer);
var
  I: Integer;
begin
  for I := Low(FIndexes) to High(FIndexes) do
  begin
    if FIndexes[I] = Index then
    begin
      CnLanguageManager.CurrentLanguageIndex := I;
      WizOptions.CurrentLangID := FStorage.Languages[I].LanguageID;
    end;
  end;
end;

procedure TCnWizMultiLang.SubActionUpdate(Index: Integer);
var
  I: Integer;
begin
  for I := Low(FIndexes) to High(FIndexes) do
  begin
    SubActions[I].Checked := WizOptions.CurrentLangID =
      FStorage.Languages[I].LanguageID;
  end;
end;

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
{$IFDEF DELPHI_IDE_WITH_HDPI}
  if Menu <> nil then
  begin
    if Menu.Images = dmCnSharedImages.Images then
      Menu.Images := dmCnSharedImages.VirtualImages;
  end;
{$ENDIF}
{$ENDIF}

  ProcessSizeEnlarge;
  ProcessGlyphForHDPI(Self);

  ProcessLazarusFormClientSize;
  ProcessLazarusGroupBoxOffset;

  if NeedAdjustRightBottomMargin then
    AdjustRightBottomMargin;   // inherited �л���� FormCreate �¼����п��ܸı��� Width/Height
end;

procedure TCnTranslateForm.DoDestroy;
{$IFNDEF STAND_ALONE}
var
  Ini: TCustomIniFile;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  // ����λ�ã���ͣ��������
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
  if not GetEnlarged then // ���Ŵ�ʱ�Ŵ���
    FScaler.DoEffects;
{$ELSE}
  FScaler.DoEffects;
{$ENDIF}
  InitFormControls;

{$IFNDEF STAND_ALONE}
  // ��ȡ���ָ�λ��
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

  inherited; // �ȴ����굱ǰ���ڵķ������ԭ���̣�֮��ָ�

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
      // List �еĿؼ�����Ҫ������ Anchors��Ȼ������ Left/Top
      // Ȼ����� MinW/MinH ���贰���ߣ�Ȼ�� Anchors ���û���
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
  // ����ɶ������
end;

function TCnTranslateForm.GetHelpTopic: string;
begin
  Result := '';
end;

procedure TCnTranslateForm.DoHelpError;
begin
  ErrorDlg(SCnNoHelpofThisLang);
end;

procedure TCnTranslateForm.ShowFormHelp;
begin
  FHelpAction.Execute;
end;

procedure TCnTranslateForm.Translate;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter(ClassName + '|TCnTranslateForm.Translate');
{$ENDIF}
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
{$ENDIF}
    // ���ʼ��ʧ�ܶ���������Ŀ����ԭʼ������Ӣ�ģ�������ΪӢ������
    Font.Charset := DEFAULT_CHARSET;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave(ClassName + '|TCnTranslateForm.Translate');
{$ENDIF}
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
  // ���� Loaded ʱ��δ��� FEnlarge ֵ
end;

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
    // �жϵ���ʾ������£���ǰ�ķŴ����Ƿ�ᳬ�� Screen �ĳߴ磬���򽵵�
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
      FEnlarge := AEnlarge; // �����޼����ķŴ���
    end;

    ScaleForm(Self, Factor);
  end;
{$ENDIF}
end;

procedure TCnTranslateForm.EnlargeListViewColumns(ListView: TListView);
var
  I: Integer;
begin
  if (FEnlarge = wseOrigin) or (ListView = nil) or (ListView.ViewStyle <> vsReport) then
    Exit;

  for I := 0 to ListView.Columns.Count - 1 do
  begin
    if ListView.Columns[I].Width > 0 then
      ListView.Columns[I].Width := Round(ListView.Columns[I].Width * GetFactorFromSizeEnlarge(FEnlarge));
  end;
end;

function TCnTranslateForm.CalcIntEnlargedValue(Value: Integer): Integer;
begin
  Result := WizOptions.CalcIntEnlargedValue(FEnlarge, Value);
end;

function TCnTranslateForm.CalcIntUnEnlargedValue(Value: Integer): Integer;
begin
  Result := WizOptions.CalcIntUnEnlargedValue(FEnlarge, Value);
end;

function TCnTranslateForm.GetEnlarged: Boolean;
begin
  Result := FEnlarge <> wseOrigin;
end;

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

procedure TCnTranslateForm.ProcessLazarusFormClientSize;
{$IFDEF FPC}
var
  ResName, Head, S: string;
  ResInstance: HRSRC;
  Stream: TResourceStream;
  Mem: TMemoryStream;
  Ref: TCustomMemoryStream;
  DFMs: TStringList;
  I, V: Integer;

  function ParseIntValue(const Line: string; const NeedPropName: string;
    out IntValue: Integer): Boolean;
  var
    E: Integer;
    H, T: string;
  begin
    Result := False;
    E := Pos('=', Line);
    if E > 0 then
    begin
      H := Trim(Copy(Line, 1, E - 1));
      if H = NeedPropName then
      begin
        T := Trim(Copy(Line, E + 1, MaxInt));
        Val(T, IntValue, E);
        Result := E = 0;
      end;
    end;
  end;

{$ENDIF}
begin
{$IFDEF FPC}
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTranslateForm.ProcessLazarusFormClientSize');
{$ENDIF}

  ResName := UpperCase(ClassName);
  ResInstance := FindResource(HInstance, PChar(ResName), RT_RCDATA);
  if ResInstance <> 0 then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnTranslateForm.ProcessLazarusFormClientSize. Found Resoure Instance.');
{$ENDIF}
    Mem := nil;
    Stream := nil;
    DFMs := nil;

    try
      Stream := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
      if Stream.Size > 4 then
      begin
        // �ж� TPF0
        SetLength(Head, 4);
        Move(Stream.Memory^, Head[1], 4);
        if Head = 'TPF0' then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('TCnTranslateForm.ProcessLazarusFormClientSize. Binary Stream to Convert.');
{$ENDIF}
          Mem := TMemoryStream.Create;
          ObjectBinaryToText(Stream, Mem);
          Mem.Position := 0;
          Ref := Mem;
        end
        else
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('TCnTranslateForm.ProcessLazarusFormClientSize. Text Stream.');
{$ENDIF}
          Ref := Stream;
        end;
        SetLength(S, Ref.Size);
        Move(Ref.Memory^, S[1], Ref.Size);

        DFMs := TStringList.Create;
        DFMs.Text := S;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnTranslateForm.ProcessLazarusFormClientSize. DFM Lines ' + IntToStr(DFMs.Count));
{$ENDIF}
        for I := 1 to DFMs.Count - 1 do // ��һ�� object �� inherited ������������
        begin
          if ParseIntValue(DFMs[I], 'ClientHeight', V) then
          begin
            Height := V; // + GetSystemMetrics(SM_CYCAPTION);
{$IFDEF DEBUG}
            CnDebugger.LogMsg('TCnTranslateForm.ProcessLazarusFormClientSize. Set Height to ' + IntToStr(V));
{$ENDIF}
          end
          else if ParseIntValue(DFMs[I], 'ClientWidth', V) then
          begin
            Width := V;
{$IFDEF DEBUG}
            CnDebugger.LogMsg('TCnTranslateForm.ProcessLazarusFormClientSize. Set Width to ' + IntToStr(V));
{$ENDIF}
          end;
          if Copy(Trim(DFMs[I]), 1, Length('object')) = 'object' then
            Break;
        end;
      end;
    finally
      DFMs.Free;
      Stream.Free;
      Mem.Free;
    end;
  end;
{$ENDIF}
end;

procedure TCnTranslateForm.ProcessLazarusGroupBoxOffset;
{$IFDEF FPC}
const
  OFFSET = 16;
var
  I, J: Integer;
  G: TGroupBox;
{$ENDIF}
begin
{$IFDEF FPC}
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TGroupBox then
    begin
      G := TGroupBox(Components[I]);
      for J := 0 to G.ControlCount - 1 do // �ݲ�Ƕ�״���
      begin
        if G.Controls[J].Top >= OFFSET then
          G.Controls[J].Top := G.Controls[J].Top - OFFSET;
      end;
    end;
  end;
{$ENDIF}
end;

function TCnTranslateForm.NeedAdjustRightBottomMargin: Boolean;
begin
{$IFDEF LAZARUS}
  Result := False;
{$ELSE}
  Result := True;
{$ENDIF}
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
{$ENDIF}

  if FStorage <> nil then
    FreeAndNil(FStorage);

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnWizMultiLang finalization.');
{$ENDIF}
end.
