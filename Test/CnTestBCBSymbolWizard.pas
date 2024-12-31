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

unit CnTestBCBSymbolWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：获取 BCB 的 IDE 内符号列表的封装测试用例单元
* 单元作者：CnPack 开发组
* 备    注：该单元对 BCB 内获得符号列表的方法进行测试，只支持 BCB 5/6。
*           摸索得出的思路是，先通过 GetProcAddress 获得 bcbide50 中的全局变量
*           Cppcodcmplt::CodeCompletionManager的值，再以此参数调用 bcbide50 中的
*           GetKibitzInfo 以触发语法分析和弹出自动完成窗口。在掉这个函数之前之前
*           先 Hook 掉 bccide 的 IDEENABLEKIBITZING，在其中调用 GetValidSymbols
*           与 CppGetSymbolText 来得到符号列表，再 Hook 掉 GetValidSymbols 让其
*           返回 0 来屏蔽弹出的自动完成窗口。
*           BCB6 的原理类似，但它没有可用的 GetKibitzInfo，只能跑到更上层调用
*           coride60 中的 TCustomEditControl::CodeCompletion，后面的机制类似，但
*           调它有个限制，不能从菜单中调，当前焦点与光标必须在当前编辑器里才行。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2013.07.15 V1.1
*               实现 BCB6 下的符号获取
*           2013.07.10 V1.0
*               创建单元，实现 BCB5 下的符号获取
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizIdeUtils,
  CnWizCompilerConst, CnWizMethodHook;

type

//==============================================================================
// 测试 BCB IDE 符号列表的菜单专家
//==============================================================================

{ TCnTestBCBSymbolWizard }

  TCnTestBCBSymbolWizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

procedure CnIDEEnableKibitzing(AParam: Integer); stdcall;

implementation

uses
  CnDebug, mPasLex, CnWizEditFiler;

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

  TCppGetSymbolTextProc = procedure(Symbol: Integer {Comtypes::TSymbol*};
    Bif: PChar; TextType: Word); stdcall;

  TCppGetSymbolFlagsProc = function(Symbol: Integer): Integer; stdcall;

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
  // corideXX.bpl
  CppGetSymbolTextName = 'CppGetSymbolText';
  CppGetSymbolFlagsName = 'CppGetSymbolFlags';

  csMaxSymbolCount = 32768;

var
  CorIdeModule: HModule = 0;
  DphIdeModule: HModule = 0;
  bccModule: HModule = 0;
  
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
  CppGetSymbolText: TCppGetSymbolTextProc;
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
    if not Assigned(GetKibitzInfo) then
      CnDebugger.LogMsg('Failed to load GetKibitzInfo from DphIdeModule');

    // Only for BCB5
    P := GetProcAddress(DphIdeModule, CodeCompletionManagerName);
    if P <> nil then
    begin
      GlobalCodeCompletionManager := Integer(P^);
      CnDebugger.LogFmt('Get Global CodeCompletionManager Address %8.8x, Value %8.8x.',
        [Integer(P), GlobalCodeCompletionManager]);
    end;
{$ENDIF}
    bccModule := LoadLibrary(bccLibName);
    Assert(bccModule <> 0, 'Failed to load dccModule');

    KibitzGetValidSymbols := GetProcAddress(bccModule, KibitzGetValidSymbolsName);
    if not Assigned(KibitzGetValidSymbols) then
      CnDebugger.LogMsg('Failed to load KibitzGetValidSymbols from dccModule');

    IDEEnableKibitzing := GetProcAddress(bccModule, IDEEnableKibitzingName);
    if not Assigned(IDEEnableKibitzing) then
      CnDebugger.LogMsg('Failed to load IDEEnableKibitzing from dccModule');

{$IFDEF BCB6}
    CorIdeModule := LoadLibrary(CorIdeLibName);
    Assert(CorIdeModule <> 0, 'Failed to load CorIdeModule');

    CustomEditControlCodeCompletion := GetProcAddress(CorIdeModule, CustomEditControlCodeCompletionName);
    if not Assigned(CustomEditControlCodeCompletion) then
      CnDebugger.LogMsg('Failed to load CustomEditControlCodeCompletion from CoreIdeModule');
{$ENDIF}

    CppGetSymbolText := GetProcAddress(bccModule, CppGetSymbolTextName);
    if not Assigned(CppGetSymbolText) then
      CnDebugger.LogMsg('Failed to load CppGetSymbolText');

    CppGetSymbolFlags := GetProcAddress(bccModule, CppGetSymbolFlagsName);
    if not Assigned(CppGetSymbolFlags) then
      CnDebugger.LogMsg('Failed to load CppGetSymbolFlags');

    Result := True;
    CnDebugger.LogMsg('TCnTestBCBSymbolWizard KibitzInitialize succ');
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

{$IFDEF BCB6}

function MyMessageDlgPosHelp(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string): Integer;
begin
  Result := mrOk;
end;

{$ENDIF}

procedure FakeDoKibitzCompile(FileName: AnsiString; XPos, YPos: Integer;
  var KibitzResult: TKibitzResult); register;
begin
  CnDebugger.LogMsg('TestBCBSymbol FakeDoKibitzCompile');
  FillChar(KibitzResult.KibitzDataArray, SizeOf(KibitzResult.KibitzDataArray), 0);
end;

function FakeKibitzGetValidSymbols(var KibitzResult: TKibitzResult;
  Symbols: PSymbols; Unknowns: PUnknowns; SymbolCount: Integer): Integer; stdcall;
begin
  CnDebugger.LogMsg('TestBCBSymbol FakeKibitzGetValidSymbols');
  Result := 0;
end;

procedure CnIDEEnableKibitzing(AParam: Integer); stdcall;
var
  I, SymbolCount: Integer;
  Unknowns: PUnknowns;
  Symbols: PSymbols;
  SymbolName: array[0..255] of Char;
  SymbolType: array[0..1023] of Char;
  SymbolFlag: Integer;
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

  CnDebugger.LogFmt('Enter CnIDEEnableKibitzing. AParam is %8.8x', [AParam]);
  Symbols := nil;
  Unknowns := nil;
  try
    // 分配临时内存
    GetMem(Symbols, csMaxSymbolCount * SizeOf(Integer));
    GetMem(Unknowns, csMaxSymbolCount * SizeOf(Byte));

    // 取得有效的符号表及总数
    SymbolCount := KibitzGetValidSymbols(AParam, Symbols, Unknowns, csMaxSymbolCount);
    CnDebugger.LogFmt('Enter CnIDEEnableKibitzing. SymbolCount is %d', [SymbolCount]);

    // 获得符号项
    for I := 0 to SymbolCount - 1 do
    begin
      CppGetSymbolText(Symbols^[I], @(SymbolName[0]), 0);  // 0 代表名字，8代表类型，1代表俩都要。
      CppGetSymbolText(Symbols^[I], @(SymbolType[0]), 8);
      SymbolFlag := CppGetSymbolFlags(Symbols^[I]);
      CnDebugger.LogFmt('TCnTestBCBSymbolWizard, Get Symbol %d, Name: %s, Flag %8.8x, Type %s',
        [I, SymbolName, SymbolFlag, SymbolType]);
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


//==============================================================================
// 测试 BCB IDE 符号列表的菜单专家 菜单专家
//==============================================================================

{ TCnTestBCBSymbolWizard }

procedure TCnTestBCBSymbolWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestBCBSymbolWizard.Create;
begin
  inherited;
  KibitzEnabled := KibitzInitialize;
end;

destructor TCnTestBCBSymbolWizard.Destroy;
begin
  KibitzFinalize;
  inherited;
end;

procedure TCnTestBCBSymbolWizard.Execute;
var
  KibitzResult: TKibitzResult;
  CharPos: TOTACharPos;
  EditControl: TControl;
{$IFDEF BCB5}
  IsC: Integer;
{$ENDIF}
{$IFDEF BCB6}
  HookMessageDlgPos: TCnMethodHook;
{$ENDIF}
begin
  if not KibitzEnabled then
  begin
    ShowMessage('Kibitz NOT Enabled. Can NOT Get Symbols.');
    Exit;
  end;

  CnDebugger.LogMsg('TCnTestBCBSymbolWizard To prepare for compile.');

  FillChar(KibitzResult, SizeOf(KibitzResult), 0);
  CharPos := CnOtaGetCurrCharPos(nil);
  EditControl := CnOtaGetCurrentEditControl;

  // 准备触发 IDE 自身的代码分析。
{$IFDEF BCB5}
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

{$IFDEF BCB6} // BCB6没法子，选择直接触发IDE的自动完成
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

  CnDebugger.LogMsg('TCnTestBCBSymbolWizard To call for compile and wait for hook.');
{$IFDEF BCB5}
  // 执行符号信息编译，在被Hook的过程中拿到符号列表
  GetKibitzInfo(GlobalCodeCompletionManager, CharPos.CharIndex, CharPos.Line, KibitzResult);
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
  CnDebugger.LogMsg('TCnTestBCBSymbolWizard End call.');  
end;

function TCnTestBCBSymbolWizard.GetCaption: string;
begin
  Result := 'Test BCB IDE Symbol';
end;

function TCnTestBCBSymbolWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestBCBSymbolWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestBCBSymbolWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestBCBSymbolWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestBCBSymbolWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test BCB IDE Symbols Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for BCB IDE Symbols';
end;

procedure TCnTestBCBSymbolWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBCBSymbolWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
{$IFDEF BCB6}
  RegisterCnWizard(TCnTestBCBSymbolWizard); // BCB6下注册此测试专家，暂未测试过
{$ELSE}
  {$IFDEF BCB5}
  RegisterCnWizard(TCnTestBCBSymbolWizard); // BCB5下注册此测试专家
  {$ENDIF}
{$ENDIF}

end.
