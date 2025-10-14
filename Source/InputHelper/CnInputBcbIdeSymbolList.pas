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

unit CnInputBcbIdeSymbolList;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��������� BCB IDE �����б��ඨ�嵥Ԫ
* ��Ԫ���ߣ�Johnson Zhong zhongs@tom.com http://www.longator.com
*           �ܾ��� zjy@cnpack.org
* ��    ע��IDE ��ʶ���б���
* ����ƽ̨��PWinXP SP2 + Delphi 5.01
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2013.07.15
*               ʵ�ֹ��ܣ�����֧�� BCB5/6
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
  Windows, SysUtils, Classes, Controls, ToolsApi, Math, Dialogs, Contnrs, TypInfo,
  Forms, CnCommon, CnWizConsts, CnWizCompilerConst, CnWizUtils, CnWizMethodHook,
  CnPasCodeParser, CnInputSymbolList, CnEditControlWrapper, CnWizNotifier;

{$IFDEF BCB5}
  {$DEFINE SUPPORT_IDESYMBOLLIST}
  {$DEFINE SUPPORT_KIBITZCOMPILE}
{$ELSE}
  {$IFDEF BCB6}
  {$DEFINE SUPPORT_IDESYMBOLLIST}
  {$DEFINE SUPPORT_KIBITZCOMPILE}
  {$ENDIF}
{$ENDIF}

type

//==============================================================================
// �� IDE �л�õı�ʶ���б�
//==============================================================================

{ TCnBcbIDESymbolList }

  TCnBcbIDESymbolList = class(TCnSymbolList)
  private
  {$IFDEF SUPPORT_KIBITZCOMPILE}
    procedure OnFileNotify(NotifyCode: TOTAFileNotification; const FileName: string);
    procedure OnIdleExecute(Sender: TObject);
    function Reload_KibitzCompile(Editor: IOTAEditBuffer;
      const InputText: string; PosInfo: TCodePosInfo): Boolean;
  {$ENDIF}
  public
    constructor Create; override;
    destructor Destroy; override;
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo; Data: Integer = 0): Boolean; override;
  end;

const
  SupportMultiIDESymbolList = False;

{$IFDEF SUPPORT_KibitzCompile}
  SupportKibitzCompile = True;
{$ELSE}
  SupportKibitzCompile = False;
{$ENDIF}

  SupportKibitzCompileThread = False;

var
  UseKibitzCompileThread: Boolean = False;
  {* �Ƿ�ʹ�ú�̨�߳�Ԥ������� }

{$IFDEF SUPPORT_KIBITZCOMPILE}

procedure CnIDEEnableKibitzing(AParam: Integer); stdcall;

{$ENDIF}

function KibitzCompileThreadRunning: Boolean;

{$ENDIF CNWIZARDS_CNINPUTHELPER}

implementation

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizEditFiler, mPasLex;

var
  FBcbIdeSymbolList: TCnBcbIDESymbolList = nil;

//==============================================================================
// �� IDE �л�õı�ʶ���б�
//==============================================================================

{ TCnBcbIDESymbolList }

function MyMessageDlgPosHelp(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string): Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('MyMessageDlgPosHelp called');
{$ENDIF}
  Result := mrOk;
end;

{$IFDEF SUPPORT_KIBITZCOMPILE}

{******************************************************************************}
{ Code Note:                                                                   }
{    Some code below is derived from GExperts 1.2                              }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

type
  TSymbols = packed array[0..(MaxInt div SizeOf(Integer))-1] of Integer;
  PSymbols = ^TSymbols;
  TUnknowns = packed array [0..(MaxInt div SizeOf(Byte))-1] of Byte;
  PUnknowns = ^TUnknowns;

  // ����������� TKibitzResult ��¼�� RTTI ��Ϣ����BCB�в�һ������
  TKibitzResult = packed record
  {$IFDEF COMPILER7_UP}
    KibitzDataArray: array [0..82] of Integer;
  {$ELSE}
    KibitzDataArray: array [0..81] of Integer;
  {$ENDIF}
  {$IFDEF COMPILER6_UP}
    KibitzDataStr: string; // RTTI ��ʾ�����λ����һ�� string ����
  {$ENDIF}
    KibitzReserveArray: array[0..255] of Integer; // �ٶ���һ�������鱸��
  end;

{$IFDEF BCB5}
  TGetKibitzInfoProc = procedure(CCMgrSelf: Integer; XPos, YPos: Integer;
    var KibitzResult: TKibitzResult); register;
{$ENDIF}
{$IFDEF BCB6}
  TCustomEditControlCodeCompletionProc = procedure(ASelf: TObject);
{$ENDIF}

  TIDEEnableKibitzingProc = procedure(AParam: Integer); stdcall;

  TKibitzGetValidSymbolsProc = function(AParam: Integer;
    Symbols: PSymbols; Unknowns: PUnknowns; SymbolCount: Integer): Integer; stdcall;

  TCompGetSymbolTextProc = procedure(Symbol: Integer {Comtypes::TSymbol*};
    Bif: PChar; TextType: Word); stdcall;

  TCppGetSymbolFlagsProc = function(Symbol: Integer): Integer; stdcall;

  TKibitzThread = class(TThread)
  private
    FFileName: AnsiString;
    FX, FY: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(const FileName: AnsiString; X, Y: Integer);
    destructor Destroy; override;
  end;

const
  bccLibName = 'bccide.dll';

{$IFDEF BCB5}
  // bcbide50.bpl ��ȫ�ֵ�CodeCompletionManagerʵ���ĵ������ƣ��Ǻ���
  CodeCompletionManagerName = '@Cppcodcmplt@CodeCompletionManager';
  GetKibitzInfoName = '@Cppcodcmplt@TCodeCompletionManager@GetKibitzInfo$qqriir22Comtypes@TKibitzResult';
{$ENDIF}
{$IFDEF BCB6}
  // BCB6�Ĵ������������
  CustomEditControlCodeCompletionName = '@Editors@TCustomEditControl@CodeCompletion$qqrc';
{$ENDIF}
  IDEEnableKibitzingName = 'IDEENABLEKIBITZING';

  KibitzGetValidSymbolsName = 'CppGetValidSymbols';

  CppGetSymbolTextName = 'CppGetSymbolText';
  CppGetSymbolFlagsName = 'CppGetSymbolFlags';

  csMaxSymbolCount = 32768;

var
  CorIdeModule: HModule = 0;
  DphIdeModule: HModule = 0;
  bccModule: HModule = 0;

  KibitzThread: TKibitzThread = nil;
  IDEEnableKibitzingRun: Boolean = False;

  GlobalCodeCompletionManager: Integer = 0;
  KibitzEnabled: Boolean = False;
{$IFDEF BCB5}
  GetKibitzInfo: TGetKibitzInfoProc;
{$ENDIF}
{$IFDEF BCB6}
  CustomEditControlCodeCompletion: TCustomEditControlCodeCompletionProc;
{$ENDIF}
  IDEEnableKibitzing: TIDEEnableKibitzingProc;
  KibitzGetValidSymbols: TKibitzGetValidSymbolsProc;
  CppGetSymbolText: TCompGetSymbolTextProc;
  CppGetSymbolFlags: TCppGetSymbolFlagsProc;

  IDEEnableKibitzingHook: TCnMethodHook = nil;
  KibitzGetValidSymbolsHook: TCnMethodHook = nil;

function KibitzInitialize: Boolean;
{$IFDEF BCB5}
var
  P: PInteger;
{$ENDIF}
begin
  Result := False;
  try
    DphIdeModule := LoadLibrary(DphIdeLibName);
    Assert(DphIdeModule <> 0, 'Failed to load DphIdeModule');
{$IFDEF BCB5}
    GetKibitzInfo := GetProcAddress(DphIdeModule, GetKibitzInfoName);
    Assert(Assigned(GetKibitzInfo), 'Failed to load GetKibitzInfo from DphIdeModule');

    P := GetProcAddress(DphIdeModule, CodeCompletionManagerName);
    if P <> nil then
    begin
      GlobalCodeCompletionManager := Integer(P^);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Get Global CodeCompletionManager Address %8.8x, Value %8.8x.',
        [Integer(P), GlobalCodeCompletionManager]);
{$ENDIF}
    end;
{$ENDIF}

    bccModule := LoadLibrary(bccLibName);
    Assert(bccModule <> 0, 'Failed to load dccModule');

    KibitzGetValidSymbols := GetProcAddress(bccModule, KibitzGetValidSymbolsName);
    Assert(Assigned(KibitzGetValidSymbols), 'Failed to load KibitzGetValidSymbols from dccModule');

    IDEEnableKibitzing := GetProcAddress(bccModule, IDEEnableKibitzingName);
    Assert(Assigned(IDEEnableKibitzing), 'Failed to load IDEEnableKibitzing from dccModule');

{$IFDEF BCB6}
    CorIdeModule := LoadLibrary(CorIdeLibName);
    Assert(CorIdeModule <> 0, 'Failed to load CorIdeModule');

    CustomEditControlCodeCompletion := GetProcAddress(CorIdeModule, CustomEditControlCodeCompletionName);
    if not Assigned(CustomEditControlCodeCompletion) then
    begin
  {$IFDEF DEBUG}
      CnDebugger.LogMsg('Failed to load CustomEditControlCodeCompletion from CoreIdeModule');
  {$ENDIF}
    end;
{$ENDIF}

    CppGetSymbolText := GetProcAddress(bccModule, CppGetSymbolTextName);
    Assert(Assigned(CppGetSymbolText), 'Failed to load CppGetSymbolText');

    CppGetSymbolFlags := GetProcAddress(bccModule, CppGetSymbolFlagsName);
    Assert(Assigned(CppGetSymbolFlags), 'Failed to load CppGetSymbolFlags');

    Result := True;
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnTestBCBSymbolWizard KibitzInitialize succ');
  {$ENDIF}
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;
end;

procedure KibitzFinalize;
begin
  if CorIdeModule <> 0 then
  begin
    FreeLibrary(CorIdeModule);
    CorIdeModule := 0;
  end;

  if bccModule <> 0 then
  begin
    FreeLibrary(bccModule);
    bccModule := 0;
  end;

  if DphIdeModule <> 0 then
  begin
    FreeLibrary(DphIdeModule);
    DphIdeModule := 0;
  end;
end;

procedure FakeDoKibitzCompile(FileName: AnsiString; XPos, YPos: Integer;
  var KibitzResult: TKibitzResult); register;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('FakeDoKibitzCompile');
{$ENDIF}
  FillChar(KibitzResult.KibitzDataArray, SizeOf(KibitzResult.KibitzDataArray), 0);
end;

function FakeKibitzGetValidSymbols(var KibitzResult: TKibitzResult;
  Symbols: PSymbols; Unknowns: PUnknowns; SymbolCount: Integer): Integer; stdcall;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('FakeKibitzGetValidSymbols');
{$ENDIF}
  Result := 0;
end;

function ParseSymbolFlags(AFlags: Integer): TCnSymbolKind;
begin
  AFlags := AFlags and $0000000F; // ȡ�����λ
  case AFlags of
    0: Result := skUnknown;   // vsfUnknown
    1: Result := skConstant;  // vsfConstant
    2: Result := skType;      // vsfType
    3: Result := skVariable;  // vsfVariable
    4: Result := skProcedure; // vsfProcedure
    5: Result := skFunction;  // vsfFunction
    6: Result := skUnit;      // vsfUnit
    7: Result := skLabel;     // vsfLabel
    8: Result := skProperty;  // vsfProperty
    9: Result := skConstructor; // vsfConstructor
    10: Result := skDestructor; // vsfDestructor
    11: Result := skInterface; // vsfInterfac
    12: Result := skEvent;      // vsfEvent
  else
    Result := skUnknown;
  end;
end;

procedure CnIDEEnableKibitzing(AParam: Integer); stdcall;
var
  I, SymbolCount: Integer;
  Unknowns: PUnknowns;
  Symbols: PSymbols;
  SymbolName: array[0..255] of Char;
  SymbolDecl: array[0..1023] of Char;
  SymbolFlag: Integer;

  procedure AddItem(const AName: PChar; const AType: PChar; Flag, Index: Integer);
  var
    Idx: Integer;
    Sk: TCnSymbolKind;
  begin
    if FBcbIdeSymbolList = nil then
      Exit;
    Sk := ParseSymbolFlags(Flag);
    Idx := FBcbIdeSymbolList.Add(AName, Sk, Round(MaxInt / SymbolCount * Index), AType);
    FBcbIdeSymbolList.Items[Idx].ForCpp := True;
  end;

begin
  if IDEEnableKibitzingRun then
  begin
    if Assigned(IDEEnableKibitzing) then
    begin
      IDEEnableKibitzingHook.UnhookMethod;
      IDEEnableKibitzing(AParam);
      Exit;
    end;
  end;
  IDEEnableKibitzingRun := True;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('Enter CnIDEEnableKibitzing. AParam is %8.8x', [AParam]);
{$ENDIF}

  Symbols := nil;
  Unknowns := nil;
  try
    // ������ʱ�ڴ�
    GetMem(Symbols, csMaxSymbolCount * SizeOf(Integer));
    GetMem(Unknowns, csMaxSymbolCount * SizeOf(Byte));

    // ȡ����Ч�ķ��ű�����
    SymbolCount := KibitzGetValidSymbols(AParam, Symbols, Unknowns, csMaxSymbolCount);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Enter CnIDEEnableKibitzing. SymbolCount is %d', [SymbolCount]);
{$ENDIF}
    // ��÷�����
    FBcbIdeSymbolList.List.Capacity := SymbolCount;
    for I := 0 to SymbolCount - 1 do
    begin
      CppGetSymbolText(Symbols^[I], @(SymbolName[0]), 0);  // 0 �������֣�8�������ͣ�1��������Ҫ��IDE������0��8��ϡ�
      CppGetSymbolText(Symbols^[I], @(SymbolDecl[0]), 8);
      SymbolFlag := CppGetSymbolFlags(Symbols^[I]);
//    CnDebugger.LogFmt('TCnTestBCBSymbolWizard, Get Symbol %d, Name: %s, Flag %8.8x, Type %s',
//      [I, SymbolName, SymbolFlag, SymbolType]);

      // ��ӷ��ŵ� FBcbIdeSymbolList �С�
      AddItem(@(SymbolName[0]), @(SymbolDecl[0]), SymbolFlag, I);
    end;

    // Ȼ��Hook��GetValidSymbol����ֹ���������Զ����
    if KibitzGetValidSymbolsHook = nil then
      KibitzGetValidSymbolsHook := TCnMethodHook.Create(@KibitzGetValidSymbols, @FakeKibitzGetValidSymbols)
    else
      KibitzGetValidSymbolsHook.HookMethod;
  finally
    if Unknowns <> nil then
      FreeMem(Unknowns);
    if Symbols <> nil then
      FreeMem(Symbols);
  end;

  if Assigned(IDEEnableKibitzing) then
  begin
    IDEEnableKibitzingHook.UnhookMethod;
    IDEEnableKibitzing(AParam);
  end;
end;

{ TKibitzThread }

constructor TKibitzThread.Create(const FileName: AnsiString; X, Y: Integer);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TKibitzThread.Create');
{$ENDIF}
  inherited Create(False);
  FFileName := FileName;
  FX := X;
  FY := Y;
  FreeOnTerminate := True;
end;

destructor TKibitzThread.Destroy;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TKibitzThread.Destroy');
{$ENDIF}
  KibitzThread := nil;
  inherited;
end;

procedure TKibitzThread.Execute;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TKibitzThread.Execute');
{$ENDIF}
  // TODO: ��һ�α��룬�������� Symbol
end;

function ParseBcbProjectBegin(var FileName: AnsiString; var X, Y: Integer): Boolean;
var
  Stream: TMemoryStream;
  Source: AnsiString;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ParseBcbProjectBegin');
{$ENDIF}

  Result := False;
  FileName := CnOtaGetCurrentProjectFileName;
  Stream := TMemoryStream.Create;
  try
    EditFilerSaveFileToStream(FileName, Stream, False);
    Source := PAnsiChar(Stream.Memory);
  finally
    Stream.Free;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogMsg(FileName + #13#10 + Source);
{$ENDIF}
  // TODO: ���� Cpp �����ļ������ڡ�
end;

procedure InvokeKibitzCompileInThread;
var
  FileName: AnsiString;
  X, Y: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('CreateKibitzThread');
{$ENDIF}
  if not SupportKibitzCompileThread or not UseKibitzCompileThread or KibitzCompileThreadRunning then
    Exit;

  if ParseBcbProjectBegin(FileName, X, Y) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('FileName: %s X: %d Y: %d', [FileName, X, Y]);
{$ENDIF}
  // TODO: �����������߳�
  end;
end;

procedure TCnBcbIDESymbolList.OnIdleExecute(Sender: TObject);
var
  Tick: Cardinal;
begin
  if not SupportKibitzCompileThread or not UseKibitzCompileThread then
    Exit;

  // �����л�ʱ�ȴ��߳̽���
  Tick := GetTickCount;
  while KibitzCompileThreadRunning do
  begin
    if GetTickCount - Tick > 500 then
      Break;
    Sleep(100);
  end;
  InvokeKibitzCompileInThread;
end;

procedure TCnBcbIDESymbolList.OnFileNotify(NotifyCode: TOTAFileNotification;
  const FileName: string);
begin
  if not SupportKibitzCompileThread or not UseKibitzCompileThread then
    Exit;

  if (NotifyCode = ofnFileOpened) and IsDpr(FileName) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnBcbIDESymbolList.OnFileNotify: %s', [FileName]);
  {$ENDIF}
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnIdleExecute);
  end;
end;

function TCnBcbIDESymbolList.Reload_KibitzCompile(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
const
  csMaxSymbolCount = 32768;
var
  EditControl: TControl;
{$IFDEF BCB5}
  KibitzResult: TKibitzResult;
  CharPos: TOTACharPos;
  Offset: Integer;
  IsC: Integer;
{$ENDIF}
{$IFDEF BCB6}
  HookMessageDlgPos: TCnMethodHook;
{$ENDIF}
begin
  Result := False;
  if not KibitzEnabled or (PosInfo.PosKind in csNonCodePosKinds)
    or KibitzCompileThreadRunning then
    Exit;

  Clear;
  EditControl := CnOtaGetCurrentEditControl;

// ׼������ IDE ����Ĵ��������
{$IFDEF BCB5}
  FillChar(KibitzResult, SizeOf(KibitzResult), 0);
  CharPos := CnOtaGetCurrCharPos(nil);
  if PosInfo.PosKind in [pkClass, pkInterface, pkField] then
    Offset := -Length(InputText)
  else
    Offset := 0;

  // CodeCompletionManager ȫ��ʵ���п���û�е�ǰEditControl��ֵ������
  (PInteger(GlobalCodeCompletionManager + SizeOf(Integer)))^ := Integer(EditControl);

  // CodeCompletionManager ȫ��ʵ���п���û�е�ǰ�ļ���Cpp�ı�ǣ�Ҳ����
  if CurrentIsCSource then
  begin
    IsC := (PInteger(GlobalCodeCompletionManager + $C8))^;
    IsC := IsC or 1;
    (PInteger(GlobalCodeCompletionManager + $C8))^ := IsC;
  end;
{$ENDIF}

{$IFDEF BCB6} // BCB6 û���ӣ�ѡ��ֱ�Ӵ���IDE���Զ����
  HookMessageDlgPos := nil;
  if Assigned(EditControl) then
  begin
    // IDE ���޷����� CodeInsight ʱ�ᵯ��һ������򣨲����쳣��
    // �˴���ʱ�滻����ʾ�����ĺ��� MessageDlgPosHelp��ʹ֮����ʾ����
    // ��������ɺ��ٻָ���
    HookMessageDlgPos := TCnMethodHook.Create(GetBplMethodAddress(@MessageDlgPosHelp),
      @MyMessageDlgPosHelp);
  end;
{$ENDIF}
  IDEEnableKibitzingRun := False;
  if IDEEnableKibitzingHook = nil then
    IDEEnableKibitzingHook := TCnMethodHook.Create(@IDEEnableKibitzing, @CnIDEEnableKibitzing)
  else
    IDEEnableKibitzingHook.HookMethod;

{$IFDEF BCB5}
  // ִ�з�����Ϣ���룬�ڱ�Hook�Ĺ������õ������б�
  GetKibitzInfo(GlobalCodeCompletionManager, CharPos.CharIndex + Offset,
    CharPos.Line, KibitzResult);
{$ENDIF}

{$IFDEF BCB6} // BCB6 ͨ������ IDE ���Զ���ɵķ�ʽִ�б��룬ͬ���ڱ�Hook�Ĺ������÷����б�
   CustomEditControlCodeCompletion(EditControl);
   HookMessageDlgPos.Free;
{$ENDIF}

  IDEEnableKibitzingHook.UnhookMethod;
  IDEEnableKibitzingRun := False;

  if KibitzGetValidSymbolsHook = nil then
    KibitzGetValidSymbolsHook := TCnMethodHook.Create(@KibitzGetValidSymbols, @FakeKibitzGetValidSymbols);
  KibitzGetValidSymbolsHook.UnhookMethod; // �ñ����εĻָ�����

  Result := Count > 0;
end;

{$ENDIF}

function KibitzCompileThreadRunning: Boolean;
begin
{$IFDEF SUPPORT_KIBITZCOMPILE}
  Result := KibitzThread <> nil;
{$ELSE}
  Result := False;
{$ENDIF}
end;

constructor TCnBcbIDESymbolList.Create;
begin
  inherited;
  FBcbIdeSymbolList := Self;
{$IFDEF SUPPORT_KIBITZCOMPILE}
  KibitzEnabled := KibitzInitialize;
//  InitializeCriticalSection(HookCS);
  InvokeKibitzCompileInThread;
  CnWizNotifierServices.AddFileNotifier(OnFileNotify);
{$ENDIF}
end;

destructor TCnBcbIDESymbolList.Destroy;
begin
{$IFDEF SUPPORT_KIBITZCOMPILE}
  CnWizNotifierServices.RemoveFileNotifier(OnFileNotify);
  KibitzFinalize;
{$ENDIF}
  FBcbIdeSymbolList := nil;
  inherited;
end;

class function TCnBcbIDESymbolList.GetListName: string;
begin
  Result := SCnInputHelperIDESymbolList;
end;

function TCnBcbIDESymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo; Data: Integer): Boolean;
begin
{$IFDEF SUPPORT_IDESYMBOLLIST}
{$IFDEF SUPPORT_KIBITZCOMPILE}
  Result := Reload_KibitzCompile(Editor, InputText, PosInfo);
{$ENDIF}
{$ELSE}
  Result := False;
{$ENDIF}
end;

initialization
{$IFDEF SUPPORT_IDESYMBOLLIST}
{$IFDEF BCB5OR6}
  RegisterSymbolList(TCnBcbIDESymbolList); // BCB5��6��ע��
{$ENDIF}
{$ENDIF}

{$ENDIF CNWIZARDS_CNINPUTHELPER}
end.


