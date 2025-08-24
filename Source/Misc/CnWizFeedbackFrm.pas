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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is derived from GExperts 1.2                                    }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnWizFeedbackFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：错误报告及建议窗体单元
* 单元作者：CnPack 开发组
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元移植处理 GExperts 1.2a Src 的 GX_FeedbackWizard 单元。
*           其原始内容受 GExperts License 的保护
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.08.09 V1.1
*               修正显示该窗体时关闭IDE出错的问题
*           2003.04.06 V1.0
*               创建单元，移植修改而来
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, CnWizardImage, StdCtrls, ComCtrls, Registry, Math, TypInfo,
  Clipbrd, ActnList, ShellAPI,
  {$IFDEF DELPHI_OTA} ToolsAPI, CnEditControlWrapper, {$ENDIF}
  CnConsts, CnWizConsts, CnWizOptions, CnWizUtils, CnWizCompilerConst,
  CnCommon, CnWizIdeUtils, CnLangMgr, CnWizMultiLang, CnWizManager;

type
  TFeedbackType = (fbBug, fbFeature);

  TCnWizFeedbackForm = class(TCnTranslateForm)
    Panel1: TPanel;
    Label1: TLabel;
    Panel2: TPanel;
    btnPrev: TButton;
    btnNext: TButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    btnCancel: TButton;
    Panel3: TPanel;
    Panel4: TPanel;
    CnWizardImage: TCnWizardImage;
    Notebook: TNotebook;
    PageControl: TPageControl;
    tsExample: TTabSheet;
    tsHelp: TTabSheet;
    lblTitle: TLabel;
    memExample: TMemo;
    memHelp: TMemo;
    memDesc: TMemo;
    Panel5: TPanel;
    rgFeedbackType: TRadioGroup;
    gbxBugDetails: TGroupBox;
    lblPercent: TLabel;
    cbProjectSpecific: TCheckBox;
    cbMultipleMachines: TCheckBox;
    edtPercent: TEdit;
    cbReproducible: TCheckBox;
    memBugSteps: TMemo;
    gbConfigurationData: TGroupBox;
    cbCnPackVer: TCheckBox;
    cbOS: TCheckBox;
    cbExperts: TCheckBox;
    cbIdeVer: TCheckBox;
    cbPackages: TCheckBox;
    cbLocaleKeyboard: TCheckBox;
    cbCpu: TCheckBox;
    cbCnPackSettings: TCheckBox;
    pnlReportButtons: TPanel;
    btnSave: TButton;
    btnCopy: TButton;
    btnEmail: TButton;
    memReport: TMemo;
    Image1: TImage;
    ActionList: TActionList;
    actPrev: TAction;
    actNext: TAction;
    dlgSaveReport: TSaveDialog;
    chkKeyMapping: TCheckBox;
    chkEditorInfo: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actPrevUpdate(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actPrevExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbReproducibleClick(Sender: TObject);
    procedure edtPercentKeyPress(Sender: TObject; var Key: Char);
    procedure btnCancelClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure InfoMemoEnter(Sender: TObject);
    procedure rgpFeedbackTypeClick(Sender: TObject);
    procedure NotebookPageChanged(Sender: TObject);
    procedure CnWizardImageChanging(Sender: TObject; NewItemIndex: Integer;
      var AllowChange: Boolean);
    procedure CnWizardImageChange(Sender: TObject);
  private
    function GetFeedbackType: TFeedbackType;
    function GetDestinationEmail: string;
    procedure SetDescriptionInfo;
    procedure SetExampleInfo;
    procedure UpdateForNewPage;
    function CanProceed(Idx: Integer): Boolean;
    procedure GenerateReport;
    function GetBugDetailsString: string;
    function GetFeedbackTypeString: string;
    function GetNextIndex: Integer;
    function GetPrevIndex: Integer;
    function GetSystemConfigurationString: string;
    function GetPageReportText(Idx: Integer): string;
    procedure InitializePageControls;
    function OnFirstPage: Boolean;
    function OnLastPage: Boolean;
    procedure SetDefaultConfigurationData;
    procedure UpdateInfo;
    function IsValidPage(Idx: Integer): Boolean;
  protected
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    property FeedbackType: TFeedbackType read GetFeedbackType;
  end;

procedure ShowFeedbackForm;

implementation

{$R *.DFM}

uses
  CnIDEVersion;

const
  IdType = 0;
  IdDesc = 1;
  IdBugDetails = 2;
  IdBugSteps = 3;
  IdConfig = 4;
  IdFinished = 5;

  SCRLF = #13#10;

var
  FeedbackForm: TCnWizFeedbackForm;

procedure ShowFeedbackForm;
begin
  if not Assigned(FeedbackForm) then
    FeedbackForm := TCnWizFeedbackForm.Create(nil);
  FeedbackForm.Show;
end;

function GetLocaleChar(Locale, LocaleType: Integer; Default: Char): Char;
{$IFDEF FPC}
var
  Buffer: array[0..1] of Char;
{$ENDIF}
begin
{$IFDEF FPC}
  if GetLocaleInfo(Locale, LocaleType, Buffer, 2) > 0 then
    Result := Buffer[0]
  else
    Result := Default;
{$ELSE}
  Result := SysUtils.GetLocaleChar(Locale, LocaleType, Default);
{$ENDIF}
end;

function GetLocaleStr(Locale, LocaleType: Integer; const Default: string): string;
{$IFDEF FPC}
var
  L: Integer;
  Buffer: array[0..255] of Char;
{$ENDIF}
begin
{$IFDEF FPC}
  L := GetLocaleInfo(Locale, LocaleType, Buffer, SizeOf(Buffer));
  if L > 0 then
    SetString(Result, Buffer, L - 1)
  else
    Result := Default;
{$ELSE}
  Result := SysUtils.GetLocaleStr(Locale, LocaleType, Default);
{$ENDIF}
end;

{ TCnWizFeedBackForm }

procedure TCnWizFeedbackForm.FormCreate(Sender: TObject);
begin
  Notebook.PageIndex := 0;
  NotebookPageChanged(nil);
  rgpFeedbackTypeClick(nil);
  UpdateInfo;
end;

procedure TCnWizFeedbackForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FeedbackForm := nil;
  Action := caFree;
end;

function TCnWizFeedbackForm.GetFeedbackType: TFeedbackType;
begin
  if rgFeedbackType.ItemIndex = 1 then
    Result := fbFeature
  else
    Result := fbBug;
end;

procedure TCnWizFeedbackForm.SetDescriptionInfo;
var
  Lines: TStrings;
begin
  Lines := memHelp.Lines;
  Lines.Text := '';

  case Notebook.PageIndex of
    IdType:
      Lines.Text := SCnTypeDescription;
    IdDesc:
      if FeedbackType = fbBug then
        Lines.Text := SCnBugDescriptionDescription
      else
        Lines.Text := SCnFeatureDescriptionDescription;
    IdBugDetails:
      Lines.Text := SCnDetailsDescription;
    IdBugSteps:
      Lines.Text := SCnStepsDescription;
    IdConfig:
      if FeedbackType = fbBug then
        Lines.Text := SCnBugConfigurationDescription
      else
        Lines.Text := SCnFeatureConfigurationDescription;
    IdFinished:
      Lines.Text := Format(SCnReportDescription, [GetDestinationEmail]);
  end;
end;

procedure TCnWizFeedbackForm.SetExampleInfo;
var
  Lines: TStrings;
begin
  Lines := memExample.Lines;
  Lines.Text := '';

  case Notebook.PageIndex of
    IdType:
      Lines.Text := SCnTypeExample;
    IdDesc:
      if FeedbackType = fbBug then
        Lines.Text := SCnBugDescriptionExample
      else
        Lines.Text := SCnFeatureDescriptionExample;
    IdBugDetails:
      Lines.Text := SCnDetailsExample;
    IdBugSteps:
      Lines.Text := Format(SCnStepsExample, [CompilerName, CompilerName, CompilerName]);
    IdConfig:
      Lines.Text := SConfigurationExample;
    IdFinished:
      Lines.Text := SReportExample;
  end;
end;

function TCnWizFeedbackForm.GetDestinationEmail: string;
begin
  if FeedBackType = fbBug then
    Result := SCnPackBugEmail
  else
    Result := SCnPackSuggestionsEmail;
end;

procedure TCnWizFeedbackForm.actPrevUpdate(Sender: TObject);
begin
  actPrev.Enabled := not OnFirstPage;
end;

procedure TCnWizFeedbackForm.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled := CanProceed(Notebook.PageIndex);
  if OnLastPage then
    actNext.Caption := SCnFinish
  else
    actNext.Caption := SCnNext;
end;

procedure TCnWizFeedbackForm.actPrevExecute(Sender: TObject);
begin
  Notebook.PageIndex := GetPrevIndex;
  UpdateForNewPage;
end;

procedure TCnWizFeedbackForm.actNextExecute(Sender: TObject);
begin
  if OnLastPage then
  begin
    Clipboard.AsText := memReport.Lines.Text;
    btnEmail.Click;
    Close;
  end
  else
  begin
    Notebook.PageIndex := GetNextIndex;
    UpdateForNewPage;
  end;
end;

procedure TCnWizFeedbackForm.cbReproducibleClick(Sender: TObject);
begin
  edtPercent.Enabled := cbReproducible.Checked;
  lblPercent.Enabled := cbReproducible.Checked;
end;

procedure TCnWizFeedbackForm.UpdateForNewPage;
begin
  UpdateInfo;
  InitializePageControls;
end;

procedure TCnWizFeedbackForm.rgpFeedbackTypeClick(Sender: TObject);
begin
  SetDefaultConfigurationData;
  CnWizardImage.Items[IdBugDetails].Visible := FeedbackType = fbBug;
  CnWizardImage.Items[IdBugSteps].Visible := FeedbackType = fbBug;
end;

procedure TCnWizFeedbackForm.SetDefaultConfigurationData;
var
  I: Integer;
  CheckBox: TCheckBox;
begin
  CheckBox := nil;
  for I := 0 to gbConfigurationData.ControlCount - 1 do
  begin
    if gbConfigurationData.Controls[I] is TCheckBox then
      CheckBox := gbConfigurationData.Controls[I] as TCheckBox
    else
      Continue;

    if FeedbackType = fbBug then
      CheckBox.Checked := True
    else
      CheckBox.Checked := not CheckBox.Enabled;
  end;
end;

function TCnWizFeedbackForm.GetNextIndex: Integer;
begin
  Assert(not OnLastPage);
  Result := Notebook.PageIndex;
  Inc(Result);
  while not IsValidPage(Result) do
    Inc(Result);
end;

function TCnWizFeedbackForm.GetPrevIndex: Integer;
begin
  Assert(not OnFirstPage);
  Result := Notebook.PageIndex;
  Dec(Result);
  if (FeedbackType = fbFeature) and (Result in [IdBugDetails, IdBugSteps]) then
    Result := IdDesc;
end;

function TCnWizFeedbackForm.CanProceed(Idx: Integer): Boolean;
begin
  Result := True;
  if Idx = IdDesc then
    Result := Length(Trim(memDesc.Text)) > 0
  else if Idx = IdBugSteps then
    Result := memBugSteps.Modified;
end;

function TCnWizFeedbackForm.OnFirstPage: Boolean;
begin
  Result := Notebook.PageIndex = 0;
end;

function TCnWizFeedbackForm.OnLastPage: Boolean;
begin
  Result := Notebook.PageIndex = Notebook.Pages.Count - 1;
end;

procedure TCnWizFeedbackForm.btnEmailClick(Sender: TObject);
var
  Execute: string;
  Address: string;
  Subject: string;
  Body: string;
begin
  // 请不要本地化
  Subject := 'CnPack IDE Wizards ' + GetFeedbackTypeString;
  Address := GetDestinationEmail;
  if dlgSaveReport.FileName <> '' then
    Body := Format(SCnFillInReminderAttach, [dlgSaveReport.FileName])
  else
    Body := SCnFillInReminderPaste;

  // 请不要本地化
  Execute := Format('mailto:%s?Subject=%s&Body=%s', [Address, Subject, Body]);
  ShellExecute(Self.Handle, 'open', PChar(Execute), nil,
    PChar(_CnExtractFilePath(Application.ExeName)), SW_SHOWNORMAL);
end;

procedure TCnWizFeedbackForm.btnCopyClick(Sender: TObject);
begin
  Clipboard.AsText := memReport.Lines.Text;
end;

procedure TCnWizFeedbackForm.btnSaveClick(Sender: TObject);
begin
  if dlgSaveReport.Execute then
    memReport.Lines.SaveToFile(dlgSaveReport.FileName);
end;

procedure TCnWizFeedbackForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

function TCnWizFeedbackForm.IsValidPage(Idx: Integer): Boolean;
begin
  Result := False;
  case FeedbackType of
    fbBug:
      Result := Idx in [IdType..IdFinished];
    fbFeature:
      Result := Idx in [IdType, IdDesc, IdConfig, IdFinished];
  end;
end;

procedure TCnWizFeedbackForm.InitializePageControls;
begin
  if Notebook.PageIndex = IdFinished then
    GenerateReport;

  if (Notebook.PageIndex = IdBugSteps) and (not memBugSteps.Modified) then
    memBugSteps.Lines.Text := Format(SCnBugSteps, [CompilerName]);
end;

procedure TCnWizFeedbackForm.GenerateReport;
var
  Report: string;
  I: Integer;
begin
  Report := '';
  for I := 0 to Notebook.Pages.Count - 1 do
    if IsValidPage(I) then
      Report := Report + GetPageReportText(I);
  memReport.Lines.Text := Report;
end;

procedure TCnWizFeedbackForm.edtPercentKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8]) then
    Key := #0;
end;

procedure TCnWizFeedbackForm.NotebookPageChanged(Sender: TObject);
begin
  CnWizardImage.ItemIndex := Notebook.PageIndex;
  lblTitle.Caption := SCnTitle + CnWizardImage.Items[Notebook.PageIndex].Caption;
end;

procedure TCnWizFeedbackForm.CnWizardImageChanging(Sender: TObject;
  NewItemIndex: Integer; var AllowChange: Boolean);
var
  I: Integer;
begin
  if NewItemIndex < Notebook.PageIndex then
    AllowChange := True
  else
  begin
    AllowChange := True;
    for I := Notebook.PageIndex to NewItemIndex - 1 do
    begin
      if IsValidPage(I) and not CanProceed(I) then
      begin
        AllowChange := False;
        Exit;
      end;
    end;
  end;
end;

procedure TCnWizFeedbackForm.CnWizardImageChange(Sender: TObject);
begin
  Notebook.PageIndex := CnWizardImage.ItemIndex;
  InitializePageControls;
end;

procedure TCnWizFeedbackForm.UpdateInfo;
var
  IsVisible: Boolean;
begin
  SetDescriptionInfo;
  SetExampleInfo;
  IsVisible := memHelp.Lines.Text <> '';
  tsHelp.TabVisible := IsVisible;
  IsVisible := memExample.Lines.Text <> '';
  tsExample.TabVisible := IsVisible;
  IsVisible := tsHelp.TabVisible or tsExample.TabVisible;
  PageControl.Visible := IsVisible;
end;

procedure TCnWizFeedbackForm.InfoMemoEnter(Sender: TObject);
begin
  Notebook.SetFocus;
end;

function TCnWizFeedbackForm.GetPageReportText(Idx: Integer): string;
begin
  Result := '';
  case Idx of
    IdType:
      Result := 'CnPack IDE Wizards ' + GetFeedbackTypeString + SCRLF + SCRLF;
    IdDesc:
      Result := SCnDescription + SCRLF + memDesc.Lines.Text + SCRLF + SCRLF;
    IdBugDetails:
      Result := GetBugDetailsString;
    IdBugSteps:
      Result := SCnSteps + SCRLF + memBugSteps.Lines.Text + SCRLF + SCRLF;
    IdConfig:
      Result := GetSystemConfigurationString;
  end;
end;

function TCnWizFeedbackForm.GetFeedbackTypeString: string;
begin
  if FeedbackType = fbBug then
    Result := SCnBugReport
  else
    Result := SCnFeatureRequest;
end;

function TCnWizFeedbackForm.GetBugDetailsString: string;
begin
  Result := SCnBugDetails + SCRLF;
  if cbReproducible.Checked then
    Result := Result + Format(SCnBugIsReproducible + SCRLF, [edtPercent.Text])
  else
    Result := Result + SCnBugIsNotReproducible + SCRLF;
  if cbMultipleMachines.Checked then
    Result := Result + '  ' + cbMultipleMachines.Caption + SCRLF; // Do not localize.
  if cbProjectSpecific.Checked then
    Result := Result + '  ' + cbProjectSpecific.Caption + SCRLF;  // Do not localize.
  Result := Result + SCRLF;
end;

function GetCnPackVersionString: string;
begin
  Result := Format('%s Ver: %s.%s Build %s' + SCRLF, [_CnExtractFileName(WizOptions.DllName),
    SCnWizardMajorVersion, SCnWizardMinorVersion, SCnWizardBuildDate]);
  Result := Result + '  CnWizards Language Index: ' + IntToStr(CnLanguageManager.CurrentLanguageIndex)  + SCRLF;
end;

// 请不要本地化
const
  cKeynamePath = '\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\';
  cKeyCodePath = '\SYSTEM\CurrentControlSet\Control\Keyboard Layout\DosKeybCodes';
  cKeySubCodes: array[0..7] of string = ('Unknown',
    'IBM PC/XT or compatible (83-key) keyboard',
    'Olivetti "ICO" (102-key) keyboard',
    'IBM PC/AT (84-key) or similar keyboard',
    'IBM enhanced (101- or 102-key) keyboard',
    'Nokia 1050 and similar keyboards',
    'Nokia 9140 and similar keyboards',
    'Japanese keyboard');
  cKeyNumFKeys: array[0..7] of string = ('Unknown', '10', '12 (18)', '10', '12', '10', '24', 'OEM');
  cSysInfoProcessorText: array[0..4] of string = ('Intel', 'MIPS', 'ALPHA', 'PPC', 'UNKNOWN');

function GetKeyboardLayoutNameFromReg: string;
var
  Reg: TRegistry;
  Name, Code, Dll: string;
  Layout: string;
begin
  Result := SCnUnknown;
  SetLength(Layout, KL_NAMELENGTH);
  if not GetKeyboardLayoutName(PChar(Layout)) then
    Exit;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(CKeyNamePath + Layout, False) then
    begin
      Name := Reg.ReadString('Layout Text');
      Dll := Reg.ReadString('Layout File');
    end;
    Reg.CloseKey;

    if Reg.OpenKey(cKeyCodePath, False) then
      Code := Reg.ReadString(Layout);
    Reg.CloseKey;

    Result := Format('%s (%s) in %s', [Name, Code, Dll]);
  finally
    Reg.Free;
  end;
end;

function GetLocaleKeyboardString: string;
var
  Data: TStrings;
begin
  Data := TStringList.Create;
  try
    Data.Add(SCnOutKeyboard);
    Data.Add(Format('  Type %d: %s with %s FKeys', [GetKeyboardType(1),
      cKeySubCodes[Min(GetKeyboardType(0), 7)],
        cKeyNumFKeys[Min(GetKeyboardType(2), 7)]]));
    Data.Add(Format('  Layout: %s', [GetKeyboardLayoutNameFromReg]));
    Data.Add('');

    Data.Add(SCnOutLocale);
    Data.Add(Format('  Number of Digits: ''%s''', [GetLocaleChar(0, LOCALE_IDIGITS, '.')]));
    Data.Add(Format('  Leading Zero: ''%s''', [GetLocaleStr(0, LOCALE_ITLZERO, '0')]));
    Data.Add(Format('  List Separators: ''%s''', [GetLocaleStr(0, LOCALE_SLIST, '0')]));
    Data.Add(Format('  Grouping: ''%s''', [GetLocaleStr(0, LOCALE_SGROUPING, '0')]));
    Data.Add(Format('  Decimal Separator: ''%s''', [GetLocaleStr(0, LOCALE_SDECIMAL, '.')]));
    Data.Add(Format('  Group Separator: ''%s''', [GetLocaleStr(0, LOCALE_STHOUSAND, ',')]));
    Data.Add(Format('  Monetary Grouping: ''%s''', [GetLocaleStr(0, LOCALE_SMONGROUPING, '0')]));
    Data.Add(Format('  Monetary Decimal Separator: ''%s''', [GetLocaleStr(0, LOCALE_SMONDECIMALSEP, '0')]));
    Data.Add(Format('  Monetary Group Separator: ''%s''', [GetLocaleStr(0, LOCALE_SMONTHOUSANDSEP, '0')]));
  finally
    Result := Data.Text + SCRLF;
    Data.Free;
  end;
end;

function GetCPUSpeed: Extended;
{$IFNDEF WIN64}
const
  DelayTime = 250;
var
  TimerHi, TimerLo: DWORD;
  PriorityClass, Priority: Integer;
{$ENDIF}
begin
  Result := 0;
{$IFNDEF WIN64}
  try
    PriorityClass := GetPriorityClass(GetCurrentProcess());
    Priority := GetThreadPriority(GetCurrentThread());

    SetPriorityClass(GetCurrentProcess(), REALTIME_PRIORITY_CLASS);
    SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_TIME_CRITICAL);

    Sleep(10);
    asm
      dw 310Fh // rdtsc
      mov TimerLo, eax
      mov TimerHi, edx
    end;
    Sleep(DelayTime);
    asm
      dw 310Fh // rdtsc
      sub eax, TimerLo
      sbb edx, TimerHi
      mov TimerLo, eax
      mov TimerHi, edx
    end;

    SetThreadPriority(GetCurrentThread(), Priority);
    SetPriorityClass(GetCurrentProcess(), PriorityClass);

    Result := (TimerLo / DelayTime) * 999.1; // Inaccuracy in sleep
  except
    ;
  end;
{$ENDIF}
end;

function GetCpuInfoString: string;
var
  Data: TStringList;
  SysInfo: TSystemInfo;
begin
  GetSystemInfo(SysInfo);
  Data := TStringList.Create;
  try
    Data.Add('CPU:');
    Data.Add(Format('  # Processors: %d', [SysInfo.dwNumberOfProcessors]));
    Data.Add(Format('  Type: %s %d model %d Stepping %d',
      [cSysInfoProcessorText[SysInfo.wProcessorArchitecture], SysInfo.dwProcessorType,
      Integer(SysInfo.wProcessorRevision shr 8), Integer(SysInfo.wProcessorRevision and $00FF)]));
    Data.Add(Format('  Speed: %.2f MHz', [GetCpuSpeed / 1000000]));
  finally
    Result := Data.Text + SCRLF;
    Data.Free;
  end;
end;

function ReportItemsInRegistryKey(const Header, Key: string; Invert: Boolean = False): string;
var
  Reg: TRegistry;
  Names: TStringList;
  I: Integer;
  Value: string;
begin
  Result := '';
  Reg := TRegistry.Create(KEY_READ);
  try
    if Reg.OpenKey(Key, False) then
    begin
      Names := TStringList.Create;
      try
        Reg.GetValueNames(Names);
        Result := Result + Header + SCRLF;
        for I := 0 to Names.Count - 1 do
        begin
          try
            Value := Reg.ReadString(Names[I]);
            if Invert then
              Result := Result + Format('  %s = %s', [Names[I], Value]) + SCRLF
            else
              Result := Result + Format('  %s = %s', [Value, Names[I]]) + SCRLF;
          except
            on E: ERegistryException do
            begin
              Value := IntToStr(Reg.ReadInteger(Names[I]));
              if Invert then
                Result := Result + Format('  %s = %s', [Names[I], Value]) + SCRLF
              else
                Result := Result + Format('  %s = %s', [Value, Names[I]]) + SCRLF;
            end;
          end;
        end;
      finally
        Names.Free;
      end;
    end
    else
      Result := 'No data for ' + Key + SCRLF + SCRLF;
  finally
    Reg.Free;
  end;
end;

function GetInstalledExpertsString: string;
begin
  Result := ReportItemsInRegistryKey(SCnOutExperts,
    WizOptions.CompilerRegPath + '\Experts') + SCRLF;
end;

function GetInstalledPackagesString: string;
begin
  Result := ReportItemsInRegistryKey(SCnOutPackages,
    WizOptions.CompilerRegPath + '\Known Packages') + SCRLF;
  Result := Result + ReportItemsInRegistryKey(SCnOutIDEPackages,
    WizOptions.CompilerRegPath + '\Known IDE Packages') + SCRLF;
end;

function GetCnPackSettingsString: string;
begin
  Result := ReportItemsInRegistryKey(SCnOutCnWizardsActive,
    WizOptions.RegPath + SCnActiveSection) + SCRLF;
  Result := Result + ReportItemsInRegistryKey(SCnOutCnWizardsCreated,
    WizOptions.RegPath + SCnCreateSection) + SCRLF;
end;

function GetKeyMappingString: string;
var
  List: TStrings;
  I: Integer;
begin
  Result := '';
  List := TStringList.Create;
  try
    if GetKeysInRegistryKey(WizOptions.CompilerRegPath + KEY_MAPPING_REG, List) then
    begin
      for I := 0 to List.Count - 1 do
      begin
        Result := Result + ReportItemsInRegistryKey(List[I],
          WizOptions.CompilerRegPath + KEY_MAPPING_REG + '\' + List[I], True);
      end;
    end;
  finally
    List.Free;
  end;
  Result := Result + SCRLF;
end;

function GetEditorSettingString: string;
{$IFDEF DELPHI_OTA}
var
  Option: IOTAEditOptions;
{$ENDIF}
begin
  Result := SOutEditorSettings + SCRLF;
{$IFDEF DELPHI_OTA}
  Option := CnOtaGetEditOptions;
  if Option <> nil then
  begin
    Result := Result + '  Editor Font: ' + Option.FontName + SCRLF;
    Result := Result + '  Font Size: ' + IntToStr(Option.FontSize) + SCRLF;
  end;
  Result := Result + '  Char Height: ' + IntToStr(Integer(EditControlWrapper.GetCharHeight)) + SCRLF;
  Result := Result + '  Char Width: ' + IntToStr(Integer(EditControlWrapper.GetCharWidth)) + SCRLF;
  Result := Result + '  Use Tab: ' + IntToStr(Integer(EditControlWrapper.GetUseTabKey)) + SCRLF;
  Result := Result + '  Tab Width: ' + IntToStr(EditControlWrapper.GetTabWidth) + SCRLF;
{$ENDIF}
end;

function TCnWizFeedbackForm.GetSystemConfigurationString: string;
begin
  Result := SCnOutConfig + SCRLF;
  Result := Result + '  OS: ' + GetOSString + SCRLF;
  Result := Result + '  CnWizards: ' + GetCnPackVersionString;
  Result := Result + '  IDE: ' + GetIdeExeVersion + SCRLF;
  Result := Result + '  ComCtl32: ' + GetFileVersionStr(MakePath(GetSystemDir)
    + 'comctl32.dll') + SCRLF + SCRLF;

  if cbExperts.Checked then
    Result := Result + GetInstalledExpertsString;
  if cbPackages.Checked then
    Result := Result + GetInstalledPackagesString;
  if cbCnPackSettings.Checked then
    Result := Result + GetCnPackSettingsString;
  if cbCpu.Checked then
    Result := Result + GetCpuInfoString;
  if cbLocaleKeyboard.Checked then
    Result := Result + GetLocaleKeyboardString;
  if chkKeyMapping.Checked then
    Result := Result + GetKeyMappingString;
  if chkEditorInfo.Checked then
    Result := Result + GetEditorSettingString;
end;

procedure TCnWizFeedbackForm.DoLanguageChanged(Sender: TObject);
begin
  // 修改其他字符串。
  SetDescriptionInfo;
  SetExampleInfo;
  NotebookPageChanged(Notebook);
end;

initialization

finalization
  if Assigned(FeedbackForm) then
    FreeAndNil(FeedbackForm);

end.
