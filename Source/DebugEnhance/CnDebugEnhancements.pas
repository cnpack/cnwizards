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

unit CnDebugEnhancements;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����Թ�����չ��Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��IDE_HAS_DEBUGGERVISUALIZER �� XE �������У���ʾ����ǿ Hint �Լ��鿴��
*           FULL_IOTADEBUGGERVISUALIZER_250 �� 10.3 ������֧�ַ��͵���ǿ�鿴��
*           IDE_HAS_MEMORY_VISUALIZAER �� 110 �������У���ʾ���ض��� TBytes �鿴��
* ����ƽ̨��PWin7Pro + Delphi 10.3
* ���ݲ��ԣ�����
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2023.09.05 V1.0
*               ʵ�ֵ�Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNDEBUGENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ToolWin,
  Dialogs, IniFiles, ComCtrls, StdCtrls, ToolsAPI, Contnrs, ActnList, CnConsts,
  CnHashMap, CnWizConsts, CnWizClasses, CnWizOptions, CnWizDebuggerNotifier,
  CnDataSetVisualizer, CnStringsVisualizer, CnBytesVisualizer, CnWideVisualizer,
  CnMemoryStreamVisualizer, CnWizMultiLang, CnWizShareImages, CnWizUtils,
  CnWizManager, CnWizNotifier, CnActionListHook;

type
  TCnDebugEnhanceWizard = class(TCnSubMenuWizard)
  private
    FIdEvalObj: Integer;
    FIdEvalAsStrings: Integer;
    FIdEvalAsBytes: Integer;
    FIdEvalAsWide: Integer;
    FIdEvalAsMemoryStream: Integer;
    FIdEvalAsDataSet: Integer;
    FIdConfig: Integer;
    FAutoClose: Boolean;
    FAutoReset: Boolean;
    FAutoBreakpoint: Boolean;
    FResetAction: TAction;
    FHooks: TCnActionListHook;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    FReplaceManager: IOTADebuggerVisualizerValueReplacer;
    FReplaceRegistered: Boolean;
    FDataSetViewer: IOTADebuggerVisualizer;
    FDataSetRegistered: Boolean;
    FEnableDataSet: Boolean;
    FStringsViewer: IOTADebuggerVisualizer;
    FStringsRegistered: Boolean;
    FEnableStrings: Boolean;
    FBytesViewer: IOTADebuggerVisualizer;
    FBytesRegistered: Boolean;
    FEnableBytes: Boolean;
    FWideViewer: IOTADebuggerVisualizer;
    FWideRegistered: Boolean;
    FEnableWide: Boolean;
    FMemoryStreamViewer: IOTADebuggerVisualizer;
    FMemoryStreamRegistered: Boolean;
    FEnableMemoryStream: Boolean;
    FEnableFloat: Boolean;
    procedure SetEnableDataSet(const Value: Boolean);
    procedure SetEnableStrings(const Value: Boolean);
    procedure SetEnableBytes(const Value: Boolean);
    procedure SetEnableWide(const Value: Boolean);
    procedure SetEnableMemoryStream(const Value: Boolean);
    procedure SetEnableFloat(const Value: Boolean);
    procedure CheckViewersRegistration;
{$ENDIF}
    procedure BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean;
      var Cancel: Boolean);
    procedure UpdateHooks;
    procedure EnableHooks;
    procedure DisableHooks;
    procedure SetAutoReset(const Value: Boolean);
    procedure NewExecute(Sender: TObject);
    function FindSection(Ini: TCustomIniFile; const FileName: string;
      var Section: string): Boolean;
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;

    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure SourceEditorNotifier(SourceEditor: TCnSourceEditorInterface;
      NotifyType: TCnWizSourceEditorNotifyType {$IFDEF DELPHI_OTA}; EditView: IOTAEditView {$ENDIF});

    procedure LoadBreakpoints(SourceEditor: TCnSourceEditorInterface);
    procedure SaveBreakpoints(SourceEditor: TCnSourceEditorInterface);
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;

    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;

    function GetCaption: string; override;
    function GetHint: string; override;
    procedure Config; override;

    procedure AcquireSubActions; override;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    property EnableDataSet: Boolean read FEnableDataSet write SetEnableDataSet;
    {* �Ƿ����� DataSet Viewer}
    property EnableStrings: Boolean read FEnableStrings write SetEnableStrings;
    {* �Ƿ����� Strings Viewer}
    property EnableBytes: Boolean read FEnableBytes write SetEnableBytes;
    {* �Ƿ����� Bytes Viewer}
    property EnableWide: Boolean read FEnableWide write SetEnableWide;
    {* �Ƿ����� UnicodeString Viewer}
    property EnableMemoryStream: Boolean read FEnableMemoryStream write SetEnableMemoryStream;
    {* �Ƿ����� MemoryStream Viewer}
    property EnableFloat: Boolean read FEnableFloat write SetEnableFloat;
    {* �Ƿ���չ Float ����������ʾ}
 {$ENDIF}
    procedure DebugComand(Cmds: TStrings; Results: TStrings); override;

    property AutoClose: Boolean read FAutoClose write FAutoClose;
    {* ����ǰ�Ƿ��Զ�ɱ�������е�Ŀ����̣����Ƕ������е� Exe}
    property AutoReset: Boolean read FAutoReset write SetAutoReset;
    {* ����ǰ�Ƿ��Զ��ر��ڵ��Ե�Ŀ����̣����ǷǶ������е� Exe}
    property AutoBreakpoint: Boolean read FAutoBreakpoint write FAutoBreakpoint;
    {* �Ƿ��Զ����ر���Դ�ļ��еĶϵ�}
  end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

  TCnDebuggerBaseValueReplacer = class(TObject)
  {* ��װ�� ValueReplacer �������滻�ͻ��࣬����һЩ�ڲ�����}
  private
    FActive: Boolean;
  protected
    function GetActive: Boolean; virtual;
    {* ���������ؿ����Ƿ�ʹ��}
    procedure SetActive(const Value: Boolean); virtual;
    {* ���������ؿ����Ƿ�ʹ��}

    function GetEvalType: string; virtual; abstract;
    {* ����֧�ֵ����������� T ǰ׺}
    function GetNewExpression(const Expression, TypeName,
      OldEvalResult: string): string; virtual; abstract;
    {* ������ֵǰ���ã�����������±��ʽ��������ֵ}
    function GetFinalResult(const OldExpression, TypeName, OldEvalResult,
      NewEvalResult: string): string; virtual;
    {* ������ֵ�ɹ�����ã�������һ��������ʾ�Ļ��ᡣĬ��ʵ���ǡ���: �¡�}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property Active: Boolean read GetActive write SetActive;
    {* �Ƿ�����}
  end;

  TCnDebuggerBaseValueReplacerClass = class of TCnDebuggerBaseValueReplacer;

  TCnDebuggerValueReplaceManager = class(TInterfacedObject,
    {$IFDEF FULL_IOTADEBUGGERVISUALIZER_250} IOTADebuggerVisualizer250, {$ENDIF}
    IOTADebuggerVisualizerValueReplacer)
  {* ���е����͵���ֵ�滻��Ĺ����࣬����ۺϳɵ�����ע���� Delphi}
  private
    FWizard: TCnDebugEnhanceWizard;
    FReplaceItems: TStringList;
    FReplacers: TObjectList;
    FMap: TCnStrToPtrHashMap;
    FEvaluator: TCnRemoteProcessEvaluator;
  protected
    procedure CreateVisualizers;
  public
    constructor Create(AWizard: TCnDebugEnhanceWizard);
    destructor Destroy; override;

    procedure LoadSettings;
    {* װ������}
    procedure SaveSettings;
    {* ��������}
    procedure ResetSettings;
    {* ��������}

    // IOTADebuggerVisualizer
    function GetSupportedTypeCount: Integer;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean); {$IFDEF FULL_IOTADEBUGGERVISUALIZER_250} overload; {$ENDIF}
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;
{$IFDEF FULL_IOTADEBUGGERVISUALIZER_250}
    { IOTADebuggerVisualizer250 }
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean; var IsGeneric: Boolean); overload;
{$ENDIF}

    // IOTADebuggerVisualizerValueReplacer
    function GetReplacementValue(const Expression, TypeName, EvalResult: string): string;

    property ReplaceItems: TStringList read FReplaceItems;
  end;

{$ENDIF}

  TCnDebugEnhanceForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pgc1: TPageControl;
    tsDebugHint: TTabSheet;
    lblEnhanceHint: TLabel;
    lvReplacers: TListView;
    actlstDebug: TActionList;
    actAddHint: TAction;
    actRemoveHint: TAction;
    tlbHint: TToolBar;
    btnAddHint: TToolButton;
    btnRemoveHint: TToolButton;
    tsViewer: TTabSheet;
    grpExternalViewer: TGroupBox;
    chkDataSetViewer: TCheckBox;
    tsOthers: TTabSheet;
    grpOthers: TGroupBox;
    chkAutoClose: TCheckBox;
    chkAutoReset: TCheckBox;
    chkStringsViewer: TCheckBox;
    chkBytesViewer: TCheckBox;
    lblHint: TLabel;
    chkWideViewer: TCheckBox;
    chkMemoryStreamViewer: TCheckBox;
    chkEnhanceFloat: TCheckBox;
    chkAutoBreakpoint: TCheckBox;
    procedure actRemoveHintExecute(Sender: TObject);
    procedure actlstDebugUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure actAddHintExecute(Sender: TObject);
    procedure lvReplacersDblClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public
    procedure LoadReplacersFromStrings(List: TStringList);
    procedure SaveReplacersToStrings(List: TStringList);
  end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
{* ������ TCnDebuggerBaseValueReplacer ����ע�ᣬʵ������ض����͵ĵ�������ʾ���ݵ�ֵ���滻}

{$ENDIF}

{$ENDIF CNWIZARDS_CNDEBUGENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNDEBUGENHANCEWIZARD}

{$R *.DFM}

uses
  CnCommon, CnFloat, CnNative, CnRemoteInspector {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  csAutoClose = 'AutoClose';
  csAutoReset = 'AutoReset';
  csAutoBreakpoint = 'AutoBreakpoint';
  csEnableFloat = 'EnableFloat';

  csBreakpoint = 'Breakpoint';
  csFileName = 'FileName';
  csItem = 'Item';

  SCnRunResetActionName = 'RunResetCommand';
  SCnCompileActionNames: array[0..4] of string = ('ProjectCompileCommand',
    'ProjectBuildCommand', 'ProjectSyntaxCommand', 'ProjectCompileAllCommand',
    'ProjectBuildAllCommand'
  );
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  csEnableDataSet = 'EnableDataSet';
  csEnableStrings = 'EnableStrings';
  csEnableBytes = 'EnableBytes';
  csEnableWide = 'EnableWide';
  csEnableMemoryStream = 'EnableMemoryStream';

var
  FDebuggerValueReplacerClass: TList = nil;

procedure RegisterCnDebuggerValueReplacer(ReplacerClass: TCnDebuggerBaseValueReplacerClass);
begin
  if FDebuggerValueReplacerClass.IndexOf(ReplacerClass) < 0 then
    FDebuggerValueReplacerClass.Add(ReplacerClass);
end;

type
  TCnDebuggerFloatSingleValueReplacer = class(TCnDebuggerBaseValueReplacer)
  {* �����ȸ�����������ʾ��չ}
  protected
    function GetActive: Boolean; override;
    function GetEvalType: string; override;
    function GetNewExpression(const Expression, TypeName,
      OldEvalResult: string): string; override;
    function GetFinalResult(const OldExpression, TypeName, OldEvalResult,
      NewEvalResult: string): string; override;
  end;

  TCnDebuggerFloatDoubleValueReplacer = class(TCnDebuggerBaseValueReplacer)
  {* ˫���ȸ�����������ʾ��չ}
  protected
    function GetActive: Boolean; override;
    function GetEvalType: string; override;
    function GetNewExpression(const Expression, TypeName,
      OldEvalResult: string): string; override;
    function GetFinalResult(const OldExpression, TypeName, OldEvalResult,
      NewEvalResult: string): string; override;
  end;

  TCnDebuggerFloatExtendedValueReplacer = class(TCnDebuggerBaseValueReplacer)
  {* ��չ���ȸ�����������ʾ��չ}
  private
    FExtSize: Integer;
    procedure CheckExtendedSize;
  protected
    function GetActive: Boolean; override;
    function GetEvalType: string; override;
    function GetNewExpression(const Expression, TypeName,
      OldEvalResult: string): string; override;
    function GetFinalResult(const OldExpression, TypeName, OldEvalResult,
      NewEvalResult: string): string; override;
  end;

{$ENDIF}

{ TCnDebugEnhanceWizard }

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

procedure TCnDebugEnhanceWizard.SetEnableDataSet(const Value: Boolean);
begin
  FEnableDataSet := Value;
  CheckViewersRegistration;
end;

procedure TCnDebugEnhanceWizard.SetEnableStrings(const Value: Boolean);
begin
  FEnableStrings := Value;
  CheckViewersRegistration;
end;

procedure TCnDebugEnhanceWizard.SetEnableBytes(const Value: Boolean);
begin
  FEnableBytes := Value;
  CheckViewersRegistration;
end;

procedure TCnDebugEnhanceWizard.SetEnableWide(const Value: Boolean);
begin
  FEnableWide := Value;
  CheckViewersRegistration;
end;

procedure TCnDebugEnhanceWizard.SetEnableMemoryStream(const Value: Boolean);
begin
  FEnableMemoryStream := Value;
  CheckViewersRegistration;
end;

procedure TCnDebugEnhanceWizard.SetEnableFloat(const Value: Boolean);
begin
  FEnableFloat := Value;
  // �� Float �������ж�ʹ��
end;

procedure TCnDebugEnhanceWizard.CheckViewersRegistration;
var
  ID: IOTADebuggerServices;
begin
  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  if Active then
  begin
    if FEnableDataSet then
    begin
      if not FDataSetRegistered then
      begin
        ID.RegisterDebugVisualizer(FDataSetViewer);
        FDataSetRegistered := True;
      end;
    end;
    if FEnableStrings then
    begin
      if not FStringsRegistered then
      begin
        ID.RegisterDebugVisualizer(FStringsViewer);
        FStringsRegistered := True;
      end;
    end;
{$IFNDEF IDE_HAS_MEMORY_VISUALIZAER}
    if FEnableBytes then
    begin
      if not FBytesRegistered then
      begin
        ID.RegisterDebugVisualizer(FBytesViewer);
        FBytesRegistered := True;
      end;
    end;
    if FEnableMemoryStream then
    begin
      if not FMemoryStreamRegistered then
      begin
        ID.RegisterDebugVisualizer(FMemoryStreamViewer);
        FMemoryStreamRegistered := True;
      end;
    end;
{$ENDIF}
    if FEnableWide then
    begin
      if not FWideRegistered then
      begin
        ID.RegisterDebugVisualizer(FWideViewer);
        FWideRegistered := True;
      end;
    end;
  end
  else
  begin
    if FDataSetRegistered then
    begin
      ID.UnregisterDebugVisualizer(FDataSetViewer);
      FDataSetRegistered := False;
    end;
    if FStringsRegistered then
    begin
      ID.UnregisterDebugVisualizer(FStringsViewer);
      FStringsRegistered := False;
    end;
{$IFNDEF IDE_HAS_MEMORY_VISUALIZAER}
    if FBytesRegistered then
    begin
      ID.UnregisterDebugVisualizer(FBytesViewer);
      FBytesRegistered := False;
    end;
    if FMemoryStreamRegistered then
    begin
      ID.UnregisterDebugVisualizer(FMemoryStreamViewer);
      FMemoryStreamRegistered := False;
    end;
{$ENDIF}
    if FWideRegistered then
    begin
      ID.UnregisterDebugVisualizer(FWideViewer);
      FWideRegistered := False;
    end;
  end;
end;

{$ENDIF}

procedure TCnDebugEnhanceWizard.Config;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  ID: IOTADebuggerServices;
{$ENDIF}
begin
  with TCnDebugEnhanceForm.Create(nil) do
  begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    LoadReplacersFromStrings((FReplaceManager as TCnDebuggerValueReplaceManager).ReplaceItems);
    chkDataSetViewer.Checked := FEnableDataSet;
    chkStringsViewer.Checked := FEnableStrings;
    chkStringsViewer.Visible := False; // IDE �Դ��ˣ�Ҳû���滻�������ز�������
    chkBytesViewer.Checked := FEnableBytes;
    chkWideViewer.Checked := FEnableWide;
    chkMemoryStreamViewer.Checked := FEnableMemoryStream;
  {$IFDEF IDE_HAS_MEMORY_VISUALIZAER}  // �߰汾 IDE �Դ����Ȳ��滻������
    chkBytesViewer.Checked := False;
    chkBytesViewer.Enabled := False;
    chkMemoryStreamViewer.Checked := False;
    chkMemoryStreamViewer.Enabled := False;
  {$ELSE}
    chkBytesViewer.Checked := FEnableBytes;
  {$ENDIF}
    chkEnhanceFloat.Checked := FEnableFloat;
{$ELSE}
    lblEnhanceHint.Enabled := False;
    lvReplacers.Enabled := False;
    grpExternalViewer.Enabled := False;
    chkDataSetViewer.Enabled := False;
    chkStringsViewer.Enabled := False;
    chkBytesViewer.Enabled := False;
    chkWideViewer.Enabled := False;
    chkMemoryStreamViewer.Enabled := False;
    chkEnhanceFloat.Enabled := False;
{$ENDIF}
    chkAutoClose.Checked := AutoClose;
    chkAutoReset.Checked := AutoReset;
    chkAutoBreakpoint.Checked := AutoBreakpoint;

    if ShowModal = mrOK then
    begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
      EnableDataSet := chkDataSetViewer.Checked;
      EnableStrings := chkStringsViewer.Checked;
      EnableBytes := chkBytesViewer.Checked;
      EnableWide := chkWideViewer.Checked;
      EnableMemoryStream := chkMemoryStreamViewer.Checked;
      EnableFloat := chkEnhanceFloat.Checked;

      SaveReplacersToStrings((FReplaceManager as TCnDebuggerValueReplaceManager).ReplaceItems);
      if Active and FReplaceRegistered then // ����ע����������Ŀ��Ч
      begin
        if Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
        begin
          ID.UnregisterDebugVisualizer(FReplaceManager);
          ID.RegisterDebugVisualizer(FReplaceManager);
        end;
      end;
{$ENDIF}
      AutoClose := chkAutoClose.Checked;
      AutoReset := chkAutoReset.Checked;
      AutoBreakpoint := chkAutoBreakpoint.Checked;
      DoSaveSettings;
    end;
    Free;
  end;
end;

constructor TCnDebugEnhanceWizard.Create;
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FReplaceManager := TCnDebuggerValueReplaceManager.Create(Self);
  FDataSetViewer := TCnDebuggerDataSetVisualizer.Create;
  FStringsViewer := TCnDebuggerStringsVisualizer.Create;
  FBytesViewer := TCnDebuggerBytesVisualizer.Create;
  FWideViewer := TCnDebuggerWideVisualizer.Create;
  FMemoryStreamViewer := TCnDebuggerMemoryStreamVisualizer.Create;
{$ENDIF}

  FHooks := TCnActionListHook.Create(nil);
  FResetAction := TAction(GetIDEActionFromName(SCnRunResetActionName));
  CnWizNotifierServices.AddBeforeCompileNotifier(BeforeCompile);
  CnWizNotifierServices.AddSourceEditorNotifier(SourceEditorNotifier);
end;

procedure TCnDebugEnhanceWizard.DebugComand(Cmds, Results: TStrings);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  Mgr: TCnDebuggerValueReplaceManager;
{$ENDIF}
begin
  inherited;

  Results.Add(Format('AutoClose %d', [Ord(FAutoClose)]));
  Results.Add(Format('AutoReset %d', [Ord(FAutoReset)]));
  Results.Add(Format('AutoBreakpoint %d', [Ord(FAutoBreakpoint)]));

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  Results.Add(Format('DataSet Viewer Registered: %d', [Ord(FDataSetRegistered)]));
  Results.Add(Format('Bytes Viewer Registered: %d', [Ord(FBytesRegistered)]));
  Results.Add(Format('Wide Viewer Registered: %d', [Ord(FWideRegistered)]));
  Results.Add(Format('MemoryStream Viewer Registered: %d', [Ord(FMemoryStreamRegistered)]));

  Mgr := FReplaceManager as TCnDebuggerValueReplaceManager;
  Results.Add('Replace Item Count: ' + IntToStr(Mgr.FReplaceItems.Count));
  Results.AddStrings(Mgr.FReplaceItems);
{$ENDIF}
end;

destructor TCnDebugEnhanceWizard.Destroy;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  ID: IOTADebuggerServices;
{$ENDIF}
begin
  CnWizNotifierServices.RemoveSourceEditorNotifier(SourceEditorNotifier);
  CnWizNotifierServices.RemoveBeforeCompileNotifier(BeforeCompile);
  FHooks.Free;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  if Active then
  begin
    if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
      Exit;

    if FReplaceRegistered then
      ID.UnregisterDebugVisualizer(FReplaceManager);

    if FDataSetRegistered then
      ID.UnregisterDebugVisualizer(FDataSetViewer);
    if FStringsRegistered then
      ID.UnregisterDebugVisualizer(FStringsViewer);
    if FBytesRegistered then
      ID.UnregisterDebugVisualizer(FBytesViewer);
    if FWideRegistered then
      ID.UnregisterDebugVisualizer(FWideViewer);
    if FMemoryStreamRegistered then
      ID.UnregisterDebugVisualizer(FMemoryStreamViewer);
  end;

  FReplaceManager := nil;
  FDataSetViewer := nil;
  FStringsViewer := nil;
  FBytesViewer := nil;
  FWideViewer := nil;
  FMemoryStreamViewer := nil;
{$ENDIF}
  inherited;
end;

function TCnDebugEnhanceWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnDebugEnhanceWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := SCnDebugEnhanceWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnDebugEnhanceWizardComment;
end;

procedure TCnDebugEnhanceWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  (FReplaceManager as TCnDebuggerValueReplaceManager).LoadSettings;
  FEnableDataSet := Ini.ReadBool('', csEnableDataSet, True);
  FEnableStrings := Ini.ReadBool('', csEnableStrings, False); // IDE �Դ��ˣ�Ҳû���滻
{$IFDEF IDE_HAS_MEMORY_VISUALIZAER}
  FEnableBytes := Ini.ReadBool('', csEnableBytes, False);     // �߰汾 IDE �Դ�
  FEnableMemoryStream := Ini.ReadBool('', csEnableMemoryStream, False);
{$ELSE}
  FEnableBytes := Ini.ReadBool('', csEnableBytes, True);
  FEnableMemoryStream := Ini.ReadBool('', csEnableMemoryStream, True);
{$ENDIF}
  FEnableWide := Ini.ReadBool('', csEnableWide, True);
  FEnableFloat := Ini.ReadBool('', csEnableFloat, False);
{$ENDIF}
  FAutoClose := Ini.ReadBool('', csAutoClose, False);
  FAutoReset := Ini.ReadBool('', csAutoReset, False);
  FAutoBreakpoint := Ini.ReadBool('', csAutoBreakpoint, True);
end;

procedure TCnDebugEnhanceWizard.ResetSettings(Ini: TCustomIniFile);
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  (FReplaceManager as TCnDebuggerValueReplaceManager).ResetSettings;
{$ENDIF}
end;

procedure TCnDebugEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  (FReplaceManager as TCnDebuggerValueReplaceManager).SaveSettings;
  Ini.WriteBool('', csEnableDataSet, FEnableDataSet);
  Ini.WriteBool('', csEnableStrings, FEnableStrings);
  Ini.WriteBool('', csEnableBytes, FEnableBytes);
  Ini.WriteBool('', csEnableWide, FEnableWide);
  Ini.WriteBool('', csEnableMemoryStream, FEnableMemoryStream);
  Ini.WriteBool('', csEnableFloat, FEnableFloat);
{$ENDIF}
  Ini.WriteBool('', csAutoClose, FAutoClose);
  Ini.WriteBool('', csAutoReset, FAutoReset);
  Ini.WriteBool('', csAutoBreakpoint, FAutoBreakpoint);
end;

procedure TCnDebugEnhanceWizard.SetActive(Value: Boolean);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  ID: IOTADebuggerServices;
{$ENDIF}
begin
  inherited;
  UpdateHooks;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  if Active  then
  begin
    if not FReplaceRegistered then
    begin
      ID.RegisterDebugVisualizer(FReplaceManager);
      FReplaceRegistered := True;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnDebugEnhanceWizard Register Viewers');
{$ENDIF}
    end;
  end
  else
  begin
    if FReplaceRegistered then
    begin
      ID.UnregisterDebugVisualizer(FReplaceManager);
      FReplaceRegistered := False;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnDebugEnhanceWizard Unregister Viewers');
{$ENDIF}
    end;
  end;
  CheckViewersRegistration;
{$ENDIF}
end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

{ TCnDebuggerValueReplaceManager }

constructor TCnDebuggerValueReplaceManager.Create(AWizard: TCnDebugEnhanceWizard);
begin
  inherited Create;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager Create');
{$ENDIF}
  FWizard := AWizard;
  FReplaceItems := TStringList.Create;
  FReplacers := TObjectList.Create(True);
  FEvaluator := TCnRemoteProcessEvaluator.Create;
  CreateVisualizers;
end;

destructor TCnDebuggerValueReplaceManager.Destroy;
begin
  FEvaluator.Free;
  FMap.Free;
  FReplaceItems.Free;
  FReplacers.Free;
  inherited;
end;

function TCnDebuggerValueReplaceManager.GetReplacementValue(const Expression,
  TypeName, EvalResult: string): string;
var
  ID: IOTADebuggerServices;
  CP: IOTAProcess;
  CT: IOTAThread;
  S, NewExpr: string;
  P: Pointer;
  Replacer: TCnDebuggerBaseValueReplacer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnDebuggerValueReplacer get %s: %s, Display %s',
    [Expression, TypeName, EvalResult]);
{$ENDIF}
  Result := EvalResult;

  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  CP := ID.CurrentProcess;
  if CP = nil then
    Exit;

  CT := CP.CurrentThread;
  if CT = nil then
    Exit;

  Replacer := nil;
  S := FReplaceItems.Values[TypeName];
  if Length(S) > 0 then
  begin
    // �滻��ʽ�ַ�����Ч���� TypeName �ڼ��滻���б���
    if Pos('%s', S) > 0 then
      NewExpr := Format(S, [Expression])
    else
      NewExpr := S;
  end
  else if FMap.Find(TypeName, P) then
  begin
    Replacer := TCnDebuggerBaseValueReplacer(P);
    if Replacer.Active then
      NewExpr := Replacer.GetNewExpression(Expression, TypeName, EvalResult)
    else
      Exit;
  end
  else
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager to Evaluate: ' + NewExpr);
{$ENDIF}

  if NewExpr <> '' then // ������ʽ�գ���ʾ��������ֵ
  begin
    S := FEvaluator.EvaluateExpression(NewExpr);

    if Replacer <> nil then
      Result := Replacer.GetFinalResult(Expression, TypeName, EvalResult, S)
    else
      Result := EvalResult + ': ' + S;
  end;
end;

procedure TCnDebuggerValueReplaceManager.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants: Boolean);
begin
  if Index < FReplaceItems.Count then
    TypeName := FReplaceItems.Names[Index]
  else if Index < FReplaceItems.Count + FReplacers.Count then
    TypeName := (FReplacers[Index - FReplaceItems.Count] as TCnDebuggerBaseValueReplacer).GetEvalType;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnDebuggerValueReplaceManager.GetSupportedType #%d: %s', [Index, TypeName]);
{$ENDIF}

  AllDescendants := False; // �ۺ��˵���û��֧�����࣬��֪����ηַ�
end;

{$IFDEF FULL_IOTADEBUGGERVISUALIZER_250}

procedure TCnDebuggerValueReplaceManager.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants: Boolean; var IsGeneric: Boolean);
begin
  GetSupportedType(Index, TypeName, AllDescendants);
  IsGeneric := False;
end;

{$ENDIF}

function TCnDebuggerValueReplaceManager.GetSupportedTypeCount: Integer;
begin
  Result := FReplaceItems.Count + FReplacers.Count;
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnDebuggerValueReplaceManager.GetSupportedTypeCount %d', [Result]);
{$ENDIF}
end;

function TCnDebuggerValueReplaceManager.GetVisualizerDescription: string;
begin
  Result := SCnDebugVisualizerDescription;
end;

function TCnDebuggerValueReplaceManager.GetVisualizerIdentifier: string;
begin
  Result := SCnDebugVisualizerIdentifier;
end;

function TCnDebuggerValueReplaceManager.GetVisualizerName: string;
begin
  Result := SCnDebugVisualizerName;
end;

procedure TCnDebuggerValueReplaceManager.CreateVisualizers;
var
  I: Integer;
  Clz: TCnDebuggerBaseValueReplacerClass;
  Obj: TCnDebuggerBaseValueReplacer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager CreateVisualizers');
{$ENDIF}
  for I := 0 to FDebuggerValueReplacerClass.Count - 1 do
  begin
    Clz := TCnDebuggerBaseValueReplacerClass(FDebuggerValueReplacerClass[I]);
    Obj := TCnDebuggerBaseValueReplacer(Clz.NewInstance);
    Obj.Create;
    FReplacers.Add(Obj);
  end;

  FMap := TCnStrToPtrHashMap.Create;
  for I := 0 to FReplacers.Count - 1 do
    FMap.Add((FReplacers[I] as TCnDebuggerBaseValueReplacer).GetEvalType, FReplacers[I]);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebuggerValueReplaceManager CreateVisualizers Complete');
{$ENDIF}
end;

procedure TCnDebuggerValueReplaceManager.LoadSettings;
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnDebugReplacerDataName, True);
  if FileExists(F) then
    FReplaceItems.LoadFromFile(F);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnDebuggerValueReplaceManager Load %d Items.', [FReplaceItems.Count]);
{$ENDIF}
end;

procedure TCnDebuggerValueReplaceManager.ResetSettings;
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnDebugReplacerDataName, False);
  if FileExists(F) then
    DeleteFile(F);
end;

procedure TCnDebuggerValueReplaceManager.SaveSettings;
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnDebugReplacerDataName, False);
  FReplaceItems.SaveToFile(F);
  WizOptions.CheckUserFile(SCnDebugReplacerDataName);
end;

{$ENDIF}

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

{ TCnDebuggerBaseValueReplacer }

constructor TCnDebuggerBaseValueReplacer.Create;
begin
  inherited;
  FActive := True;
end;

destructor TCnDebuggerBaseValueReplacer.Destroy;
begin

  inherited;
end;

function TCnDebuggerBaseValueReplacer.GetActive: Boolean;
begin
  Result := FActive;
end;

function TCnDebuggerBaseValueReplacer.GetFinalResult(const OldExpression,
  TypeName, OldEvalResult, NewEvalResult: string): string;
begin
  Result := OldEvalResult + ': ' + NewEvalResult;
end;

procedure TCnDebuggerBaseValueReplacer.SetActive(const Value: Boolean);
begin
  FActive := Value;
end;

{$ENDIF}

{ TCnDebugEnhanceForm }

procedure TCnDebugEnhanceForm.LoadReplacersFromStrings(List: TStringList);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  I: Integer;
  Item: TListItem;
{$ENDIF}
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  lvReplacers.Items.Clear;
  for I := 0 to List.Count - 1 do
  begin
    Item := lvReplacers.Items.Add;
    Item.Caption := List.Names[I];
    Item.SubItems.Add(List.Values[Item.Caption]);
  end;
{$ENDIF}
end;

procedure TCnDebugEnhanceForm.SaveReplacersToStrings(List: TStringList);
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
var
  I: Integer;
{$ENDIF}
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
   List.Clear;
   for I := 0 to lvReplacers.Items.Count - 1 do
     List.Add(lvReplacers.Items[I].Caption + '=' + lvReplacers.Items[I].SubItems[0]);
{$ENDIF}
end;

procedure TCnDebugEnhanceForm.actRemoveHintExecute(Sender: TObject);
begin
  if lvReplacers.Selected <> nil then
    if QueryDlg(SCnDebugRemoveReplacerHint) then
      lvReplacers.Items.Delete(lvReplacers.Selected.Index);
end;

procedure TCnDebugEnhanceForm.actlstDebugUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if Action = actRemoveHint then
    (Action as TCustomAction).Enabled := lvReplacers.Selected <> nil
  else
  begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    (Action as TCustomAction).Enabled := True;
{$ELSE}
    (Action as TCustomAction).Enabled := False;
{$ENDIF}
  end;

  Handled := True;
end;

procedure TCnDebugEnhanceForm.actAddHintExecute(Sender: TObject);
var
  S, S1, S2: string;
  Idx: Integer;
  Item: TListItem;
begin
  S := 'TSample=%s.ToString';
  if CnWizInputQuery(SCnDebugAddReplacerCaption, SCnDebugAddReplacerHint, S) then
  begin
    Idx := Pos('=', S);
    if Idx > 1 then
    begin
      S1 := Copy(S, 1, Idx - 1);
      S2 := Copy(S, Idx + 1, MaxInt);
      if Pos('%s', S2) > 0 then
      begin
        Item := lvReplacers.Items.Add;
        Item.Caption := S1;
        Item.SubItems.Add(S2);
        Exit;
      end;
    end;

    ErrorDlg(SCnDebugErrorReplacerFormat);
  end;
end;

procedure TCnDebugEnhanceForm.lvReplacersDblClick(Sender: TObject);
var
  S, S1, S2: string;
  Idx: Integer;
  Item: TListItem;
begin
  Item := lvReplacers.Selected;
  if Item = nil then
    Exit;

  S := Item.Caption + '=' + Item.SubItems[0];
  if CnWizInputQuery(SCnDebugAddReplacerCaption, SCnDebugAddReplacerHint, S) then
  begin
    Idx := Pos('=', S);
    if Idx > 1 then
    begin
      S1 := Copy(S, 1, Idx - 1);
      S2 := Copy(S, Idx + 1, MaxInt);
      if Pos('%s', S2) > 0 then
      begin
        Item.Caption := S1;
        Item.SubItems[0] := S2;
        Exit;
      end;
    end;

    ErrorDlg(SCnDebugErrorReplacerFormat);
  end;
end;

procedure TCnDebugEnhanceForm.FormCreate(Sender: TObject);
begin
  WizOptions.ResetToolbarWithLargeIcons(tlbHint);
end;

function TCnDebugEnhanceForm.GetHelpTopic: string;
begin
  Result := 'CnDebugEnhanceWizard';
end;

procedure TCnDebugEnhanceForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnDebugEnhanceWizard.AcquireSubActions;
begin
  FIdEvalObj := RegisterASubAction('EvalAsObj',
    'Evaluate As Object...', 0, '');

  // ��ʱ������
  SubActions[FIdEvalObj].Visible := False;

  FIdEvalAsStrings := RegisterASubAction(SCnDebugEvalAsStrings,
    SCnDebugEvalAsStringsCaption, 0, SCnDebugEvalAsStringsHint);
  FIdEvalAsBytes := RegisterASubAction(SCnDebugEvalAsBytes,
    SCnDebugEvalAsBytesCaption, 0, SCnDebugEvalAsBytesHint);
  FIdEvalAsWide := RegisterASubAction(SCnDebugEvalAsWide,
    SCnDebugEvalAsWideCaption, 0, SCnDebugEvalAsWideHint);
  FIdEvalAsMemoryStream := RegisterASubAction(SCnDebugEvalAsMemoryStream,
    SCnDebugEvalAsMemoryStreamCaption, 0, SCnDebugEvalAsMemoryStreamHint);
  FIdEvalAsDataSet := RegisterASubAction(SCnDebugEvalAsDataSet,
    SCnDebugEvalAsDataSetCaption, 0, SCnDebugEvalAsDataSetHint);
  AddSepMenu;
  FIdConfig := RegisterASubAction(SCnDebugConfig, SCnDebugConfigCaption, 0,
    SCnDebugConfigHint);
end;

procedure TCnDebugEnhanceWizard.SubActionExecute(Index: Integer);
var
  S: string;
  I1: Integer;

  function InputExpr: string;
  var
    T: string;
  begin
    Result := '';
    T := Trim(CnOtaGetCurrentSelection);
    if T = '' then
    begin
      CnOtaGetCurrPosToken(T, I1);
      T := Trim(T);
    end;

    if CnWizInputQuery(SCnInformation, SCnDebugEnterExpression, T) then
      Result := Trim(T);
  end;

begin
  if Index = FIdEvalObj then
  begin
    S := InputExpr;
    if S <> '' then
      EvaluateRemoteExpression(S);
  end
  else if Index = FIdEvalAsStrings then
  begin
    S := InputExpr;
    if S <> '' then
      ShowStringsExternalViewer(S);
  end
  else if Index = FIdEvalAsBytes then
  begin
    S := InputExpr;
    if S <> '' then
      ShowBytesExternalViewer(S);
  end
  else if Index = FIdEvalAsWide then
  begin
    S := InputExpr;
    if S <> '' then
      ShowWideExternalViewer(S);
  end
  else if Index = FIdEvalAsMemoryStream then
  begin
    S := InputExpr;
    if S <> '' then
      ShowMemoryStreamExternalViewer(S);
  end
  else if Index = FIdEvalAsDataSet then
  begin
    S := InputExpr;
    if S <> '' then
      ShowDataSetExternalViewer(S);
  end
  else if Index = FIdConfig then
    Config;
end;

procedure TCnDebugEnhanceWizard.SubActionUpdate(Index: Integer);
begin
  if (Index = FIdEvalObj) or (Index = FIdEvalAsDataSet) or (Index = FIdEvalAsStrings)
    or (Index = FIdEvalAsBytes) or (Index = FIdEvalAsWide) or (Index = FIdEvalAsMemoryStream) then
    SubActions[Index].Enabled := CnOtaIsDebugging;
end;

function TCnDebugEnhanceWizard.GetCaption: string;
begin
  Result := SCnDebugEnhanceWizardCaption;
end;

function TCnDebugEnhanceWizard.GetHint: string;
begin
  Result := SCnDebugEnhanceWizardHint;
end;

procedure TCnDebugEnhanceWizard.BeforeCompile(const Project: IOTAProject;
  IsCodeInsight: Boolean; var Cancel: Boolean);
var
  Exe: string;
begin
  if not Active or not AutoClose or IsCodeInsight then
    Exit;

  // ��ǰ���̵Ŀ�ִ���ļ������������ɱ��
  Exe := CnOtaGetProjectOutputTarget(Project);
  if (Exe <> '') and FileExists(Exe) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnDebugEnhanceWizard.BeforeCompile to Kill: ' + Exe);
{$ENDIF}
    KillProcessByFullFileName(Exe);
  end;
end;

procedure TCnDebugEnhanceWizard.SetAutoReset(const Value: Boolean);
begin
  if FAutoReset <> Value then
  begin
    FAutoReset := Value;
    UpdateHooks;
  end;
end;

procedure TCnDebugEnhanceWizard.DisableHooks;
var
  I: Integer;
  Ast: TActionList;
  Act: TAction;
begin
  Ast := TActionList(GetIDEActionList);
  if (Ast = nil) or not FHooks.IsHooked(Ast) then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebugEnhanceWizard DisableHooks.');
{$ENDIF}

  for I := High(SCnCompileActionNames) downto Low(SCnCompileActionNames) do
  begin
    Act := TAction(GetIDEActionFromName(SCnCompileActionNames[I]));
    if (Act <> nil) and FHooks.IsActionHooked(Act) then
      FHooks.RemoveNotifiler(Act);
  end;
  FHooks.UnHookActionList(Ast);
end;

procedure TCnDebugEnhanceWizard.EnableHooks;
var
  I: Integer;
  Ast: TActionList;
  Act: TAction;
begin
  Ast := TActionList(GetIDEActionList);
  if (Ast = nil) or FHooks.IsHooked(Ast) then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDebugEnhanceWizard EnableHookes.');
{$ENDIF}

  FHooks.HookActionList(Ast);
  for I := Low(SCnCompileActionNames) to High(SCnCompileActionNames) do
  begin
    Act := TAction(GetIDEActionFromName(SCnCompileActionNames[I]));
    if (Act <> nil) and not FHooks.IsActionHooked(Act) then
      FHooks.AddActionNotifier(Act, NewExecute, nil);
  end;
end;

procedure TCnDebugEnhanceWizard.UpdateHooks;
begin
  if Active and FAutoReset then
    EnableHooks
  else
    DisableHooks;
end;

procedure TCnDebugEnhanceWizard.NewExecute(Sender: TObject);
var
  Exe: TNotifyEvent;
begin
  if CnOtaIsDebugging and (FResetAction <> nil) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Hooked Actions Enter. Is Debugging. To Reset.');
{$ENDIF}
    FResetAction.Execute;
  end;

  // �ҵ� Sender ��Ӧ�� Action �� Obj���ҵ���� Execute
  Exe := FHooks.GetActionOldExecute(Sender as TAction);
  if Assigned(Exe) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Hooked Actions Enter. Call Old.');
{$ENDIF}
    Exe(Sender);
  end;
end;

procedure TCnDebugEnhanceWizard.SourceEditorNotifier(SourceEditor: TCnSourceEditorInterface;
  NotifyType: TCnWizSourceEditorNotifyType {$IFDEF DELPHI_OTA}; EditView: IOTAEditView {$ENDIF});
begin
  if not Active then
    Exit;

  if FAutoBreakpoint then
  begin
    if NotifyType = setOpened then
    begin
      // ���������� SourceEditor �ļ���Ӧ�Ķϵ���Ϣ�����ý��ñ༭��
      LoadBreakpoints(SourceEditor);
    end
    else if NotifyType in [setEditViewRemove, setClosing] then
    begin
      // �� SourceEditor ��Ķϵ㱣������
      SaveBreakpoints(SourceEditor);
    end;
  end;
end;

procedure TCnDebugEnhanceWizard.LoadBreakpoints(
  SourceEditor: TCnSourceEditorInterface);
var
  I, J, L: Integer;
  Ini: TCustomIniFile;
  S, Section: string;
  DebugSvcs: IOTADebuggerServices;
  B: IOTABreakpoint;
begin
  if Active and FileExists(SourceEditor.FileName) and
    Supports(BorlandIDEServices, IOTADebuggerServices, DebugSvcs) then
  begin
    Ini := CreateIniFile;
    try
      if FindSection(Ini, SourceEditor.FileName, Section) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Load Breakpoint from Section %s to File %s', [Section, SourceEditor.FileName]);
{$ENDIF}
      end;

      for I := 0 to 19 do // ����һ���ļ����� 20 ���ϵ�
      begin
        S := Ini.ReadString(Section, csBreakpoint + IntToStr(I), '');

        // �� S �н���ϵ����ݲ��½��ڱ��ļ���
        if S <> '' then
        begin
          J := Pos(',', S);
          if J > 1 then
          begin
            L := StrToIntDef(Copy(S, 1, J - 1), 0);
            if L > 0 then
            begin
              B := DebugSvcs.NewSourceBreakpoint(SourceEditor.FileName, L, DebugSvcs.CurrentProcess);
{$IFDEF DEBUG}
              CnDebugger.LogFmt('Restore Breakpoint at Line %d', [L]);
{$ENDIF}
              try
                if B <> nil then
                begin
                  Delete(S, 1, J);
                  if S = '0' then
                    B.Enabled := False;
                end;
              except
                ;
              end;
            end;
          end;
        end;
      end;
    finally
      Ini.Free;
    end;
  end;
end;

procedure TCnDebugEnhanceWizard.SaveBreakpoints(
  SourceEditor: TCnSourceEditorInterface);
var
  I, J: Integer;
  Ini: TCustomIniFile;
  Section: string;
  FileNameSaved: Boolean;
  DebugSvcs: IOTADebuggerServices;
  B: IOTASourceBreakpoint;

  function BreakpointToStr(BP: IOTASourceBreakpoint): string;
  begin
    if BP.Enabled then
      Result := Format('%d,1',[BP.LineNumber])
    else
      Result := Format('%d,1',[BP.LineNumber]);
  end;

begin
  if Active and FileExists(SourceEditor.FileName) and
    Supports(BorlandIDEServices, IOTADebuggerServices, DebugSvcs) then
  begin
    Ini := CreateIniFile;
    try
      if FindSection(Ini, SourceEditor.FileName, Section) then
        Ini.EraseSection(Section); // ����Ѿ���������ɾ��

      FileNameSaved := False;
      J := 0;
      for I := 0 to DebugSvcs.GetSourceBkptCount - 1 do
      begin
        B := DebugSvcs.GetSourceBkpt(I);
        if B.FileName <> SourceEditor.FileName then
          Continue;

        if not FileNameSaved then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogFmt('Save Breakpoint to Section %s from File %s ', [Section, SourceEditor.FileName]);
{$ENDIF}
          Ini.WriteString(Section, csFileName, SourceEditor.FileName);
          FileNameSaved := True;
        end;

        Ini.WriteString(Section, csBreakpoint + IntToStr(J), BreakpointToStr(B));
        Inc(J);
      end;
    finally
      Ini.Free;
    end;
  end;
end;

function TCnDebugEnhanceWizard.FindSection(Ini: TCustomIniFile;
  const FileName: string; var Section: string): Boolean;
var
  Sections: TStrings;
  I: Integer;
begin
  Result := False;
  Sections := TStringList.Create;
  try
    Ini.ReadSections(Sections);
    for I := 0 to Sections.Count - 1 do
    begin
      if Pos(csItem, Sections[I]) > 0 then
      begin
        if SameFileName(Ini.ReadString(Sections[I], csFileName, ''), FileName) then
        begin
          Section := Sections[I];
          Result := True;
          Break;
        end;
      end;
    end;

    if not Result then
    begin
      I := 0;
      while True do
      begin
        Section := csItem + IntToStr(I);
        if Ini.SectionExists(Section) then
          Inc(I)
        else
          Break;
      end;
    end;
  finally
    Sections.Free;
  end;
end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

function HexTrimZero(N: TUInt64): string;
begin
  Result := UInt64ToHex(N);
  while (Length(Result) > 0) and (Result[1] = '0') do
    Delete(Result, 1, 1);
end;

function GetDebugEnhanceFloatEnable: Boolean;
var
  W: TCnBaseWizard;
begin
  Result := False;
  W := CnWizardMgr.WizardByClass(TCnDebugEnhanceWizard);
  if (W <> nil) and (W is TCnDebugEnhanceWizard) then
    Result := TCnDebugEnhanceWizard(W).Active and TCnDebugEnhanceWizard(W).EnableFloat;
end;

{ TCnDebuggerFloatSingleValueReplacer }

function TCnDebuggerFloatSingleValueReplacer.GetActive: Boolean;
begin
  Result := GetDebugEnhanceFloatEnable;
end;

function TCnDebuggerFloatSingleValueReplacer.GetEvalType: string;
begin
  Result := 'Single';
end;

function TCnDebuggerFloatSingleValueReplacer.GetFinalResult(
  const OldExpression, TypeName, OldEvalResult,
  NewEvalResult: string): string;
var
{$IFDEF WIN64}
  Ar: TCnOTAAddress;
  Buf: array[0..15] of Byte;
{$ELSE}
  C: Cardinal;
{$ENDIF}
  F: Single;
  Sign: Boolean;
  E: Integer;
  M: Cardinal;
begin
  Result := OldEvalResult;
  if NewEvalResult <> '' then
  begin
{$IFDEF WIN64}
    // NewEvalResult Ӧ�����õ�һ����ַ�� $ ��ͷ��ʮ������������ʽ
    Ar := TCnOTAAddress(StrToUInt64(NewEvalResult));
    if CnRemoteProcessEvaluator.ReadProcessMemory(Ar, SizeOf(Single), Buf[0]) <> SizeOf(Single) then
      Exit;

    Move(Buf[0], F, SizeOf(Single));
{$ELSE}
    C := StrToUInt(NewEvalResult);
    Move(C, F, SizeOf(Single));
{$IFDEF DEBUG}
    CnDebugger.LogFmt('FloatSingleValueReplacer GetFinalResult. New Value %s. Cardinal %d, Float %f',
      [NewEvalResult, C, F]);
{$ENDIF}
{$ENDIF}

    ExtractFloatSingle(F, Sign, E, M);
    if Sign then
      Result := OldEvalResult + ' | ' + '-^' + IntToStr(E) + ': ' + HexTrimZero(M)
    else
      Result := OldEvalResult + ' | ' + '+^' + IntToStr(E) + ': ' + HexTrimZero(M);
  end;
end;

function TCnDebuggerFloatSingleValueReplacer.GetNewExpression(
  const Expression, TypeName, OldEvalResult: string): string;
begin
{$IFDEF WIN64}
  // 64 λ IDE �²�֧�ֶԷ�^ȡֵ��ֻ�����õ�ַ
  if IsValidDotIdentifier(Expression) then
    Result := Format('@%s', [Expression]);
{$ELSE}
  // �� PCardinal(@Expression)^ ��ֵ��ȥ�õ�һ���������ֽ��޷���������ʮ����ֵ
  Result := Format('PCardinal(@%s)^', [Expression]);
{$ENDIF}
end;

{ TCnDebuggerFloatDoubleValueReplacer }

function TCnDebuggerFloatDoubleValueReplacer.GetActive: Boolean;
begin
  Result := GetDebugEnhanceFloatEnable;
end;

function TCnDebuggerFloatDoubleValueReplacer.GetEvalType: string;
begin
  Result := 'Double';
end;

function TCnDebuggerFloatDoubleValueReplacer.GetFinalResult(
  const OldExpression, TypeName, OldEvalResult,
  NewEvalResult: string): string;
var
{$IFDEF WIN64}
  Ar: TCnOTAAddress;
  Buf: array[0..15] of Byte;
{$ELSE}
  C: UInt64;
{$ENDIF}
  F: Double;
  Sign: Boolean;
  E: Integer;
  M: UInt64;
begin
  Result := OldEvalResult;
  if NewEvalResult <> '' then
  begin
{$IFDEF WIN64}
    // NewEvalResult Ӧ�����õ�һ����ַ�� $ ��ͷ��ʮ������������ʽ
    Ar := TCnOTAAddress(StrToUInt64(NewEvalResult));
    if CnRemoteProcessEvaluator.ReadProcessMemory(Ar, SizeOf(Double), Buf[0]) <> SizeOf(Double) then
      Exit;

    Move(Buf[0], F, SizeOf(Double));
{$ELSE}
    C := StrToUInt64(NewEvalResult);
    Move(C, F, SizeOf(UInt64));
{$IFDEF DEBUG}
    CnDebugger.LogFmt('FloatDoubleValueReplacer GetFinalResult. New Value %s. Cardinal %d, Float %f',
      [NewEvalResult, C, F]);
{$ENDIF}
{$ENDIF}

    ExtractFloatDouble(F, Sign, E, M);
    if Sign then
      Result := OldEvalResult + ' | ' + '-^' + IntToStr(E) + ': ' + HexTrimZero(M)
    else
      Result := OldEvalResult + ' | ' + '+^' + IntToStr(E) + ': ' + HexTrimZero(M);
  end;
end;

function TCnDebuggerFloatDoubleValueReplacer.GetNewExpression(
  const Expression, TypeName, OldEvalResult: string): string;
begin
{$IFDEF WIN64}
  // 64 λ IDE �²�֧�ֶԷ�^ȡֵ��ֻ�����õ�ַ
  if IsValidDotIdentifier(Expression) then
    Result := Format('@%s', [Expression]);
{$ELSE}
  // �� PUInt64(@Expression)^ ��ֵ��ȥ�õ�һ��������ֽ��޷���������ʮ����ֵ
  Result := Format('PUInt64(@%s)^', [Expression]);
{$ENDIF}
end;

{ TCnDebuggerFloatExtendedValueReplacer }

function TCnDebuggerFloatExtendedValueReplacer.GetActive: Boolean;
begin
  Result := GetDebugEnhanceFloatEnable;
end;

function TCnDebuggerFloatExtendedValueReplacer.GetEvalType: string;
begin
  Result := 'Extended';
end;

procedure TCnDebuggerFloatExtendedValueReplacer.CheckExtendedSize;
var
  S: string;
begin
  S := CnRemoteProcessEvaluator.EvaluateExpression('SizeOf(Extended)');
  if S <> '' then
  begin
    FExtSize := StrToIntDef(S, 0);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnDebuggerFloatExtendedValueReplacer Get Extended Size %d', [FExtSize]);
{$ENDIF}
  end;
end;

function TCnDebuggerFloatExtendedValueReplacer.GetFinalResult(
  const OldExpression, TypeName, OldEvalResult,
  NewEvalResult: string): string;
var
  Ar: TCnOTAAddress;
  Buf: array[0..15] of Byte;
  Sign: Boolean;
  E: Integer;
  M: UInt64;
  S: string;
  V: Extended;
begin
  Result := OldEvalResult;

  if NewEvalResult <> '' then
  begin
    CheckExtendedSize;

    // NewEvalResult Ӧ�����õ�һ����ַ�� $ ��ͷ��ʮ������������ʽ
    Ar := TCnOTAAddress(StrToUInt64(NewEvalResult));

    if (FExtSize > 0) and (FExtSize = CnRemoteProcessEvaluator.ReadProcessMemory(Ar, FExtSize, Buf[0])) then
    begin
      S := OldEvalResult;
      if (FExtSize = CN_EXTENDED_SIZE_10) and (SizeOf(Extended) = CN_EXTENDED_SIZE_10) then
      begin
        // ��Ŀ����̺���������չ���ȶ��� 10 ʱ�����ø���ȷ������
        Move(Buf[0], V, SizeOf(Extended));
        S := ExtendedToStr(V);
      end;

      ExtractFloatExtended(@Buf[0], FExtSize, Sign, E, M);
      if Sign then
        Result := S + ' | ' + '-^' + IntToStr(E) + ': ' + HexTrimZero(M)
      else
        Result := S + ' | ' + '+^' + IntToStr(E) + ': ' + HexTrimZero(M);
    end;
  end;
end;

function TCnDebuggerFloatExtendedValueReplacer.GetNewExpression(
  const Expression, TypeName, OldEvalResult: string): string;
begin
{$IFDEF WIN64}
  if IsValidDotIdentifier(Expression) then
    Result := Format('@%s', [Expression]);
{$ELSE}
  Result := Format('@(%s)', [Expression]); // ȥȡ��ַ׼�����ڴ�
{$ENDIF}
end;

{$ENDIF}

initialization
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FDebuggerValueReplacerClass := TList.Create;
  RegisterCnDebuggerValueReplacer(TCnDebuggerFloatSingleValueReplacer);
  RegisterCnDebuggerValueReplacer(TCnDebuggerFloatDoubleValueReplacer);
  RegisterCnDebuggerValueReplacer(TCnDebuggerFloatExtendedValueReplacer);
{$ENDIF}

{$IFDEF DELPHI}
  RegisterCnWizard(TCnDebugEnhanceWizard); // BCB 5/6 �µ�����ֵ���ܲ����ף���������
{$ENDIF}

finalization
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  FDebuggerValueReplacerClass.Free;
{$ENDIF}

{$ENDIF CNWIZARDS_CNDEBUGENHANCEWIZARD}
end.
