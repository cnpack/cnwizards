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

unit CnInputBcbIdeSymbolList;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：输入助手 BCB IDE 符号列表类定义单元
* 单元作者：Johnson Zhong zhongs@tom.com http://www.longator.com
*           周劲羽 zjy@cnpack.org
* 备    注：IDE 标识符列表类
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2013.07.15
*               实现功能，基本支持 BCB5/6
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
  {$DEFINE SUPPORT_IDESymbolList}
  {$DEFINE SUPPORT_KibitzCompile}
{$ELSE}
  {$IFDEF BCB6}
  {$DEFINE SUPPORT_IDESymbolList}
  {$DEFINE SUPPORT_KibitzCompile}
  {$ENDIF}
{$ENDIF}

type

//==============================================================================
// 从 IDE 中获得的标识符列表
//==============================================================================

{ TBcbIDESymbolList }

  TBcbIDESymbolList = class(TSymbolList)
  private
  {$IFDEF SUPPORT_KibitzCompile}
    procedure OnFileNotify(NotifyCode: TOTAFileNotification; const FileName: string);
    procedure OnIdleExecute(Sender: TObject);
    function Reload_KibitzCompile(Editor: IOTAEditBuffer;
      const InputText: string; PosInfo: TCodePosInfo): Boolean;
  {$ENDIF SUPPORT_KibitzCompile}
  public
    constructor Create; override;
    destructor Destroy; override;
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
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
  {* 是否使用后台线程预处理符号 }

{$IFDEF SUPPORT_KibitzCompile}

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
  FBcbIdeSymbolList: TBcbIDESymbolList = nil;
  
//==============================================================================
// 从 IDE 中获得的标识符列表
//==============================================================================

{ TBcbIDESymbolList }

function MyMessageDlgPosHelp(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string): Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('MyMessageDlgPosHelp called');
{$ENDIF}
  Result := mrOk;
end;

{$IFDEF SUPPORT_KibitzCompile}

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
  // 这个声明来自 TKibitzResult 记录的 RTTI 信息，在BCB中不一定有用
  TKibitzResult = packed record
  {$IFDEF COMPILER7_UP}
    KibitzDataArray: array [0..82] of Integer;
  {$ELSE}
    KibitzDataArray: array [0..81] of Integer;
  {$ENDIF}
  {$IFDEF COMPILER6_UP}
    KibitzDataStr: string; // RTTI 显示在这个位置有一个 string 变量
  {$ENDIF}
    KibitzReserveArray: array[0..255] of Integer; // 再定义一个大数组备用
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
  // bcbide50.bpl 中全局的CodeCompletionManager实例的导出名称，非函数
  CodeCompletionManagerName = '@Cppcodcmplt@CodeCompletionManager';
  GetKibitzInfoName = '@Cppcodcmplt@TCodeCompletionManager@GetKibitzInfo$qqriir22Comtypes@TKibitzResult';
{$ENDIF}
{$IFDEF BCB6}
  // BCB6的触发代码分析的
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

function ParseSymbolFlags(AFlags: Integer): TSymbolKind;
begin
  AFlags := AFlags and $0000000F; // 取最低四位
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
    Sk: TSymbolKind;
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
    // 分配临时内存
    GetMem(Symbols, csMaxSymbolCount * SizeOf(Integer));
    GetMem(Unknowns, csMaxSymbolCount * SizeOf(Byte));

    // 取得有效的符号表及总数
    SymbolCount := KibitzGetValidSymbols(AParam, Symbols, Unknowns, csMaxSymbolCount);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Enter CnIDEEnableKibitzing. SymbolCount is %d', [SymbolCount]);
{$ENDIF}
    // 获得符号项
    FBcbIdeSymbolList.List.Capacity := SymbolCount;
    for I := 0 to SymbolCount - 1 do
    begin
      CppGetSymbolText(Symbols^[I], @(SymbolName[0]), 0);  // 0 代表名字，8代表类型，1代表俩都要。IDE中是用0和8组合。
      CppGetSymbolText(Symbols^[I], @(SymbolDecl[0]), 8);
      SymbolFlag := CppGetSymbolFlags(Symbols^[I]);
//    CnDebugger.LogFmt('TCnTestBCBSymbolWizard, Get Symbol %d, Name: %s, Flag %8.8x, Type %s',
//      [I, SymbolName, SymbolFlag, SymbolType]);

      // 添加符号到 FBcbIdeSymbolList 中。
      AddItem(@(SymbolName[0]), @(SymbolDecl[0]), SymbolFlag, I);
    end;

    // 然后Hook掉GetValidSymbol，防止弹出代码自动完成
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
  // TODO: 跑一次编译，但无需获得 Symbol
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
  // TODO: 解析 Cpp 工程文件获得入口。
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
  // TODO: 创建并运行线程
  end;
end;

procedure TBcbIDESymbolList.OnIdleExecute(Sender: TObject);
var
  Tick: Cardinal;
begin
  if not SupportKibitzCompileThread or not UseKibitzCompileThread then
    Exit;

  // 工程切换时等待线程结束
  Tick := GetTickCount;
  while KibitzCompileThreadRunning do
  begin
    if GetTickCount - Tick > 500 then
      Break;
    Sleep(100);
  end;
  InvokeKibitzCompileInThread;
end;

procedure TBcbIDESymbolList.OnFileNotify(NotifyCode: TOTAFileNotification;
  const FileName: string);
begin
  if not SupportKibitzCompileThread or not UseKibitzCompileThread then
    Exit;
    
  if (NotifyCode = ofnFileOpened) and IsDpr(FileName) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('TBcbIDESymbolList.OnFileNotify: %s', [FileName]);
  {$ENDIF}
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnIdleExecute);
  end;
end;

function TBcbIDESymbolList.Reload_KibitzCompile(Editor: IOTAEditBuffer;
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

// 准备触发 IDE 自身的代码分析。
{$IFDEF BCB5}
  FillChar(KibitzResult, SizeOf(KibitzResult), 0);
  CharPos := CnOtaGetCurrCharPos(nil);
  if PosInfo.PosKind in [pkClass, pkInterface, pkField] then
    Offset := -Length(InputText)
  else
    Offset := 0;

  // CodeCompletionManager 全局实例中可能没有当前EditControl的值，塞上
  (PInteger(GlobalCodeCompletionManager + SizeOf(Integer)))^ := Integer(EditControl);

  // CodeCompletionManager 全局实例中可能没有当前文件是Cpp的标记，也塞上
  if CurrentIsCSource then
  begin
    IsC := (PInteger(GlobalCodeCompletionManager + $C8))^;
    IsC := IsC or 1;
    (PInteger(GlobalCodeCompletionManager + $C8))^ := IsC;
  end;
{$ENDIF}

{$IFDEF BCB6} // BCB6 没法子，选择直接触发IDE的自动完成
  HookMessageDlgPos := nil;
  if Assigned(EditControl) then
  begin
    // IDE 在无法进行 CodeInsight 时会弹出一个错误框（不是异常）
    // 此处临时替换掉显示错误框的函数 MessageDlgPosHelp，使之不显示出来
    // 待调用完成后再恢复。
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
  // 执行符号信息编译，在被Hook的过程中拿到符号列表
  GetKibitzInfo(GlobalCodeCompletionManager, CharPos.CharIndex + Offset,
    CharPos.Line, KibitzResult);
{$ENDIF}

{$IFDEF BCB6} // BCB6 通过触发 IDE 的自动完成的方式执行编译，同样在被Hook的过程中拿符号列表
   CustomEditControlCodeCompletion(EditControl);
   HookMessageDlgPos.Free;
{$ENDIF}

  IDEEnableKibitzingHook.UnhookMethod;
  IDEEnableKibitzingRun := False;

  if KibitzGetValidSymbolsHook = nil then
    KibitzGetValidSymbolsHook := TCnMethodHook.Create(@KibitzGetValidSymbols, @FakeKibitzGetValidSymbols);
  KibitzGetValidSymbolsHook.UnhookMethod; // 让被屏蔽的恢复正常
  
  Result := Count > 0;
end;

{$ENDIF SUPPORT_KibitzCompile}

function KibitzCompileThreadRunning: Boolean;
begin
{$IFDEF SUPPORT_KibitzCompile}
  Result := KibitzThread <> nil;
{$ELSE}
  Result := False;
{$ENDIF SUPPORT_KibitzCompile}
end;

constructor TBcbIDESymbolList.Create;
begin
  inherited;
  FBcbIdeSymbolList := Self;
{$IFDEF SUPPORT_KibitzCompile}
  KibitzEnabled := KibitzInitialize;
//  InitializeCriticalSection(HookCS);
  InvokeKibitzCompileInThread;
  CnWizNotifierServices.AddFileNotifier(OnFileNotify);
{$ENDIF SUPPORT_KibitzCompile}
end;

destructor TBcbIDESymbolList.Destroy;
begin
{$IFDEF SUPPORT_KibitzCompile}
  CnWizNotifierServices.RemoveFileNotifier(OnFileNotify);
  KibitzFinalize;
{$ENDIF SUPPORT_KibitzCompile}
  FBcbIdeSymbolList := nil;
  inherited;
end;

class function TBcbIDESymbolList.GetListName: string;
begin
  Result := SCnInputHelperIDESymbolList;
end;

function TBcbIDESymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
{$IFDEF SUPPORT_IDESymbolList}
{$IFDEF SUPPORT_KibitzCompile}
  Result := Reload_KibitzCompile(Editor, InputText, PosInfo);
{$ENDIF SUPPORT_KibitzCompile}
{$ELSE}
  Result := False;
{$ENDIF SUPPORT_IDESymbolList}
end;

initialization
{$IFDEF SUPPORT_IDESymbolList}
{$IFDEF BCB5OR6}
  RegisterSymbolList(TBcbIDESymbolList); // BCB5、6下注册
{$ENDIF}
{$ENDIF}

{$ENDIF CNWIZARDS_CNINPUTHELPER}
end.


