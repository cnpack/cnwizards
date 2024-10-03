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

unit CnInputIdeSymbolList;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：输入助手 IDE 符号列表类定义单元
* 单元作者：Johnson Zhong zhongs@tom.com http://www.longator.com
*           周劲羽 zjy@cnpack.org
* 备    注：IDE 标识符列表类
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2022.04.02
*               基本支持 LSP 的异步符号获取
*           2005.06.03
*               从 CnInputHelper 中分离出来
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
  Windows, SysUtils, Classes, Controls, ToolsApi, Math, Dialogs, Contnrs, TypInfo,
  Forms, CnHashMap, CnCommon, CnWizConsts, CnWizCompilerConst, CnWizUtils, CnWizMethodHook,
  CnPasCodeParser, CnInputSymbolList, CnEditControlWrapper, CnWizNotifier;

{$IFDEF DELPHI}
  {$DEFINE SUPPORT_IDESYMBOLLIST}
{$ENDIF}

{$IFDEF SUPPORT_IDESYMBOLLIST}
{$IFDEF COMPILER7_UP}
  {$DEFINE SUPPORT_IOTACodeInsightManager}  // D7 及以上支持 IOTACodeInsightManager
{$ENDIF}

{$IFNDEF COMPILER8_UP}
  {$DEFINE SUPPORT_KibitzCompile}           // D567 支持 KibitzCompile
{$ENDIF}

{$IFDEF SUPPORT_IOTACodeInsightManager}
  {$IFDEF SUPPORT_KibitzCompile}
    {$DEFINE SUPPORT_MULTI_IDESymbolList}   // D7 俩都支持
  {$ENDIF}
{$ENDIF}

{$ENDIF SUPPORT_IDESYMBOLLIST}

{$IFDEF IDE_WIDECONTROL}
  {$IFNDEF UNICODE_STRING}
    {$DEFINE UTF8_SYMBOL}  // D2005/2006/2007 的 Symbol 是 Utf8
  {$ENDIF}
{$ENDIF}

{$IFDEF BDS4_UP}
  // BDS 2006 在执行 IOTACodeInsightServices.SetQueryContext(nil, nil)
  // 后再调用自动完成会导致 IDE 异常
  {$DEFINE IDE_SetQueryContext_Bug}
{$ENDIF}

{$IFDEF DELPHI2007_UP}
  {$DEFINE SYMBOL_LOCKHOOK}
{$ENDIF}

{$IFDEF IDE_SUPPORT_LSP}
  {$UNDEF SYMBOL_LOCKHOOK}
{$ENDIF}

type

//==============================================================================
// 从 IDE 中获得的标识符列表
//==============================================================================

{ TIDESymbolList }

  TIDESymbolList = class(TSymbolList)
  private
  {$IFDEF IDE_SUPPORT_LSP}
     FKeepUnique: Boolean; // Name 是否可重复
     FHashList: TCnStrToStrHashMap;
     FAsyncResultGot: Boolean;
     FAsyncManagerObj: TObject;
     FAsyncIsPascal: Boolean;
     FAsyncWaiting: Boolean;
     FAnsycCancel: Boolean;
     procedure AsyncCodeCompletionCallBack(Sender: TObject; AId: Integer;
       AError: Boolean; const AMessage: string);
  {$ENDIF}
  {$IFDEF SUPPORT_IOTACodeInsightManager}
    function Reload_CodeInsightManager(Editor: IOTAEditBuffer;
      const InputText: string; PosInfo: TCodePosInfo): Boolean;
  {$ENDIF SUPPORT_IOTACodeInsightManager}
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

    // 以下俩函数在 LSP 模式下会做防重处理，注意 Add(Item: TSymbolItem) 未做
    function Add(const AName: string; AKind: TSymbolKind; AScope: Integer; const
      ADescription: string = ''; const AText: string = ''; AAutoIndent: Boolean = 
      True; AMatchFirstOnly: Boolean = False; AAlwaysDisp: Boolean = False;
      ADescIsUtf8: Boolean = False): Integer; overload; override;
    procedure Clear; override;

    procedure Cancel; override;
    // 供外界按需通知中止异步等待
  end;

const
{$IFDEF SUPPORT_MULTI_IDESymbolList}
  SupportMultiIDESymbolList = True;
{$ELSE}
  SupportMultiIDESymbolList = False;
{$ENDIF}

{$IFDEF SUPPORT_KibitzCompile}
  SupportKibitzCompile = True;
{$ELSE}
  SupportKibitzCompile = False;
{$ENDIF}

{$IFDEF DELPHI5}
  SupportKibitzCompileThread = True;
{$ELSE}
  SupportKibitzCompileThread = False;
{$ENDIF}

var
  UseCodeInsightMgr: Boolean = False;
  {* 在 D7 中是否使用兼容性较好的方式取得符号列表，较慢}
  UseKibitzCompileThread: Boolean = False;
  {* 是否使用后台线程预处理符号 }

function KibitzCompileThreadRunning: Boolean;

{$ENDIF CNWIZARDS_CNINPUTHELPER}

implementation

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizEditFiler, mPasLex;

const
  csCIMgrNames = ';pascal;';

{$IFDEF IDE_SUPPORT_LSP}
const
  HashSize = 4096;
  SDelphiLspGetCount = '@Lspcodcmplt@TLSPKibitzManager@GetCount$qqrv';
  SDelphiLspGetCodeCompEntry = '@Lspcodcmplt@TLSPKibitzManager@GetCodeCompEntry$qqri';

  SBcbLspGetCount = '@Cppcodcmplt2@TCppKibitzManager2@GetCount$qqrv';
  SBcbLspGetCodeCompEntry = '@Cppcodcmplt2@TCppKibitzManager2@GetCodeCompEntry$qqri';

type
  TDelphiLSPKibitzManagerGetCount = function (ASelf: TObject): Integer;
  TBcbLSPKibitzManagerGetCount = function (ASelf: TObject): Integer;

  TDelphiLSPKibitzManagerGetCodeCompEntry = function (ASelf: TObject; Index: Integer): Pointer;
  TBcbLSPKibitzManagerGetCodeCompEntry = function (ASelf: TObject; Index: Integer): Pointer;

  TCnDelphiLspCodeCompEntry = packed record
  {* 反编译而来，LSPKibitzManager 每一项是一个结构，一个结构共 12 个四字节内容}
    SymbolName: PChar;            // 名称
    SymbolFlag: LongWord;
    SymbolType: PChar;            // 类型字符串，如 method 等
    SymbolTypeFlag: LongWord;
    SymbolParam: PChar;           // 参数字符串！以前是拿不着的
    SymbolDummy6: LongWord;
    SymbolDummy7: LongWord;
    SymbolDummy8: LongWord;
    SymbolDummy9: LongWord;
    SymbolDummy10: LongWord;
    SymbolDummy11: LongWord;
    SymbolDummy12: PChar;
  end;
  PCnDelphiLspCodeCompEntry = ^TCnDelphiLspCodeCompEntry;

  TCnBcbLspCodeCompEntry = packed record
  {* 反编译而来，CppKibitzManager2 每一项是一个结构，一个结构共 7 个四字节内容}
    SymbolName: PAnsiChar;        // 名称
    SymbolLength: LongWord;       // 名称长度
    SymbolTypeFlag: LongWord;
    SymbolParam: PAnsiChar;       // 详情字符串
    SymbolParamLength: LongWord;  // 详情字符串长度
    SymbolDummy6: PAnsiChar;
  end;
  PCnBcbLspCodeCompEntry = ^TCnBcbLspCodeCompEntry;

var
  FDelphiLspHandle: THandle = 0;
  FBcbLspHandle: THandle = 0;

  DelphiLspGetCount: TDelphiLSPKibitzManagerGetCount = nil;
  DelphiLspGetCodeCompEntry: TDelphiLSPKibitzManagerGetCodeCompEntry = nil;

  BcbLspGetCount: TBcbLSPKibitzManagerGetCount = nil;
  BcbLspGetCodeCompEntry: TBcbLSPKibitzManagerGetCodeCompEntry = nil;
{$ENDIF}

//==============================================================================
// 从 IDE 中获得的标识符列表
//==============================================================================

{ TIDESymbolList }

{$IFDEF SUPPORT_IOTACodeInsightManager}

const
  ComtypesLockName = '@Comtypes@Lock$qqsv';
  ComtypesUnLockName = '@Comtypes@UnLock$qqsv';

function MyMessageDlgPosHelp(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string): Integer;
begin
{$IFDEF Debug}
  CnDebugger.LogMsg('MyMessageDlgPosHelp called');
{$ENDIF Debug}
  Result := mrOk;
end;

{$IFDEF SYMBOL_LOCKHOOK}
type
  TComtypesLockProc = procedure; stdcall;

var
  DphIdeModule1: HMODULE;
  LockHook: TCnMethodHook;
  UnLockHook: TCnMethodHook;
  ComtypesLock: TComtypesLockProc;
  ComtypesUnLock: TComtypesLockProc;

procedure MyComtypesUnLock; stdcall;
begin
end;

procedure MyComtypesLock; stdcall;
begin
end;
{$ENDIF SYMBOL_LOCKHOOK}

{$IFDEF IDE_SUPPORT_LSP}

function SymbolClassTextToKind(const ClassText: string): TSymbolKind;
begin
  Result := skUnknown;
  if Length(ClassText) >= 3 then
  begin
    case Ord(ClassText[1]) of
      107: // k eyword
        Result := skKeyword;
      114, 115: // r eference / s truct
        Result := skType;
      118: // v ariable
        Result := skVariable;
      102: // f unction / fi le / fi eld
        begin
          if ClassText[2] = 'u' then
            Result := skFunction
          else if ClassText[3] = 'l' then
            Result := skUnit
          else
            Result := skVariable; // Field
        end;
      109: // m ethod
        Result := skFunction;
      112: // p roperty
        Result := skProperty;
      105: // i nterface
        Result := skInterface;
      99:  // c lass / const ant / const ructor
        begin
          if ClassText[2] = 'l' then
            Result := skClass
          else if Length(ClassText) >= 6 then
          begin
            if ClassText[6] = 'a' then
              Result := skConstant
            else
              Result := skConstructor;
          end;
        end;
      101: // e vent / e num / e numM
        begin
          if ClassText[2] = 'v' then
            Result := skEvent
          else
            Result := skConstant;
        end;
    end;
  end;
end;

procedure TIDESymbolList.AsyncCodeCompletionCallBack(Sender: TObject; AId: Integer;
  AError: Boolean; const AMessage: string);
var
  I, C, Idx: Integer;
  SName, SDesc, S3: string;
  PasEntry: PCnDelphiLspCodeCompEntry;
  CppEntry: PCnBcbLspCodeCompEntry;

  function ExtractStr(CppPtr: PAnsiChar; Len: Integer): string;
  const
    MAX_LEN = 128;
  var
    S: AnsiString;
  begin
    // 从 CppStr 扫描 " 号，把前面的拿出来返回为 string
    Result := '';
    if (CppPtr = nil) or (Len <= 0) then
      Exit;

    if Len > MAX_LEN then
      Len := MAX_LEN;

    SetLength(S, Len);
    Move(CppPtr^, S[1], Len);
    Result := string(S);
  end;

  function CppTypeToKind(V: Integer; const SName: string): TSymbolKind;
  begin
    case V of
      1: Result := skKeyword;
      2,3: Result := skFunction; // method & global function
      4:
        begin
          if SName[1] = '~' then
            Result := skDestructor
          else
            Result := skConstructor
        end;
      5: Result := skVariable;
      6: Result := skConstant;
      7: Result := skType;
      8: Result := skConstant;
      9: Result := skUnit;
      10: Result := skProperty;
      13,20: Result := skConstant; // enum
      22: Result := skType;
    else
      Result := skUnknown;
    end;
  end;

begin
  try
    if not Assigned(FAsyncManagerObj) then
      Exit;

    if FAsyncIsPascal then
    begin
      if Assigned(DelphiLspGetCount) and Assigned(DelphiLspGetCodeCompEntry) then
      begin
        // Delphi 下 FAsyncManagerObj 似乎是个 TLSPKibitzManager 实例，有俩方法获得个数与元素
        C := DelphiLspGetCount(FAsyncManagerObj);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Callback DelphiLspGetCount %s Returns Count %d',
          [FAsyncManagerObj.ClassName, C]);
{$ENDIF}

        if C <= 0 then
          Exit;

        for I := 0 to C - 1 do
        begin
          PasEntry := DelphiLspGetCodeCompEntry(FAsyncManagerObj, I);
          if (PasEntry <> nil) and (PasEntry^.SymbolName <> nil) then
          begin
            Idx := Add(PasEntry^.SymbolName, SymbolClassTextToKind(PasEntry^.SymbolType),
              Round(MaxInt / C * I), PasEntry^.SymbolParam, '', True, False, False, False);

            // 根据源文件的类型设置符号项的适用范围
            if Idx >= 0 then
            begin
              Items[Idx].ForPascal := True;
              Items[Idx].ForCpp := False;
            end;
          end;
        end;
      end;
    end
    else
    begin
      // BCB 下，FAsyncManagerObj 是一个 TCppKibitzManager2 实例，处理方式完全不同
      if Assigned(BcbLspGetCount) and Assigned(BcbLspGetCodeCompEntry) then
      begin
        C := BcbLspGetCount(FAsyncManagerObj);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Callback BcbLspGetCount %s Returns Count %d',
          [FAsyncManagerObj.ClassName, C]);
{$ENDIF}

        if C <= 0 then
          Exit;

        for I := 0 to C - 1 do
        begin
          CppEntry := BcbLspGetCodeCompEntry(FAsyncManagerObj, I);
          if (CppEntry <> nil) and (CppEntry^.SymbolName <> nil) then
          begin;
            SName := ExtractStr(CppEntry^.SymbolName, CppEntry^.SymbolLength);
            if SName = '' then
              Continue;

            SDesc := ExtractStr(CppEntry^.SymbolParam, CppEntry^.SymbolParamLength);
            Idx := Add(SName, CppTypeToKind(CppEntry^.SymbolTypeFlag, SName),
              Round(MaxInt / C * I), SDesc, '', True, False, False, False);

            // 根据源文件的类型设置符号项的适用范围
            if Idx >= 0 then
            begin
              Items[Idx].ForPascal := False;
              Items[Idx].ForCpp := True;
            end;
          end;
        end;
      end;
    end;
  finally
    FAsyncResultGot := True; // 最后才放，比较保险
  end;
end;

{$ENDIF}

// Invoke delphi code completion, load symbol list
function TIDESymbolList.Reload_CodeInsightManager(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
var
  CodeInsightServices: IOTACodeInsightServices;
  CodeInsightManager: IOTACodeInsightManager;
  EditView: IOTAEditView;
  Element, LineFlag: Integer;
  Index: Integer;

  function SymbolFlagsToKind(Flags: TOTAViewerSymbolFlags; const Description: string):
    TSymbolKind;
  begin
    Result := TSymbolKind(Flags);
    if (Flags = vsfType) then
    begin
      if Copy(Description, 1, 8) = ' : class' then
        Result := skClass;
      if Copy(Description, 1, 12) = ' : interface' then
        Result := skInterface;
    end;
  end;

  function MyInvokeCodeCompletion(Manager: IOTACodeInsightManager): Boolean;
  var
    Hook: TCnMethodHook;
    Filter: string;
  begin
    try
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Before InvokeCodeCompletion');
    {$ENDIF}
      // IDE 在无法进行 CodeInsight 时会弹出一个错误框（不是异常）
      // 此处临时替换掉显示错误框的函数 MessageDlgPosHelp，使之不显示出来
      // 待调用完成后再恢复。
      Hook := TCnMethodHook.Create(GetBplMethodAddress(@MessageDlgPosHelp),
        @MyMessageDlgPosHelp);
      try
        Filter := '';
        Result := Manager.InvokeCodeCompletion(itManual, Filter);
      finally
        Hook.Free;
      end;
    {$IFDEF DEBUG}
      CnDebugger.LogBoolean(Result, 'After InvokeCodeCompletion');
    {$ENDIF}
    except
      Result := False;
    end;
  end;

  procedure AddToSymbolList(Manager: IOTACodeInsightManager);
  var
    DisplayParams: Boolean;
    I, Idx: Integer;
    SymbolList: IOTACodeInsightSymbolList;
    Desc: string;
    Kind: TSymbolKind;
    Allow: Boolean;
    ValidChars: TSysCharSet;
    Name: string;
 {$IFDEF IDE_SUPPORT_LSP}
    Filter: string;
    Tick: Cardinal;
    AsyncManager: IOTAAsyncCodeInsightManager;
 {$ENDIF}
  begin
{$IFDEF IDE_SUPPORT_LSP}
    if Supports(Manager, IOTAAsyncCodeInsightManager, AsyncManager) then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Is an IOTAAsyncCodeInsightManager.');
    {$ENDIF}
      if not Assigned(AsyncManager) or not AsyncManager.AsyncEnabled then   // 未启用
        Exit;

      if not Manager.HandlesFile(Editor.FileName) then       // 不能处理当前文件
        Exit;

      CodeInsightServices.SetQueryContext(EditView, Manager);
      try
        Allow := True;
        AsyncManager.AsyncAllowCodeInsight(Allow, #0);
        if not Allow then
          Exit;

        ValidChars := Manager.EditorTokenValidChars(False);
        Filter := '';
        FAsyncResultGot := False;
        FAsyncManagerObj := AsyncManager as TObject;
        FAsyncIsPascal := PosInfo.IsPascal;
    {$IFDEF DEBUG}
        CnDebugger.LogFmt('To Async Invoke %s.', [FAsyncManagerObj.ClassName]);
    {$ENDIF}
        FKeepUnique := True;
        FAnsycCancel := False;
        FAsyncWaiting := True;
        // 标记开始异步等待

        AsyncManager.AsyncInvokeCodeCompletion(itAuto, Filter, EditView.CursorPos.Line,
          EditView.CursorPos.Col - 1, AsyncCodeCompletionCallBack);

        Tick := GetTickCount;
        try
          // 得异步等待，注意外头的代码输入助手会继续处理 KeyDown 和 KeyUp 等事件
          // 因此外头加了 Symbol 正在 Reloading 时的防重入，但没有主动 Cancel 本次
          // 异步等待的机制
          while not FAnsycCancel and not FAsyncResultGot and (GetTickCount - Tick < 2000) do
            Application.ProcessMessages;
        except
{$IFDEF DEBUG}
          CnDebugger.LogMsgError('Async Result Exception when Waiting.');
{$ENDIF}
        end;

        FAsyncWaiting := False; // 标记异步等待结束
{$IFDEF DEBUG}
        if FAsyncResultGot then
          CnDebugger.LogMsg('Async Result Got. Cost ms ' + IntToStr(GetTickCount - Tick))
        else if FAnsycCancel then
          CnDebugger.LogMsg('Async Result Canceled after ms ' + IntToStr(GetTickCount - Tick))
        else
          CnDebugger.LogMsg('Async Result Time out. Fail to Get Symbol List.');
{$ENDIF}
      finally
        CodeInsightServices.SetQueryContext(nil, nil);
      {$IFDEF DEBUG}
        CnDebugger.LogMsg('End Async AddToSymbolList');
      {$ENDIF}
      end;
      Exit;
    end;
{$ENDIF}

    // 普通的 CodeInsight
    if not Assigned(Manager) or not Manager.Enabled then   // 未启用
      Exit;

    if not Manager.HandlesFile(Editor.FileName) then       // 不能处理当前文件
      Exit;

  {$IFDEF SYMBOL_LOCKHOOK}
    if DphIdeModule1 = 0 then
      DphIdeModule1 := LoadLibrary(DphIdeLibName);
    ComtypesLock := TComtypesLockProc(GetProcAddress(DphIdeModule1, ComtypesLockName));
    ComtypesUnLock := TComtypesLockProc(GetProcAddress(DphIdeModule1, ComtypesUnLockName));
    ComtypesLock;
    LockHook := TCnMethodHook.Create(@ComtypesLock, @MyComtypesLock);
    UnLockHook := TCnMethodHook.Create(@ComtypesUnLock, @MyComtypesUnLock);
  {$ENDIF SYMBOL_LOCKHOOK}

    CodeInsightServices.SetQueryContext(EditView, Manager);
    try
      // Allow: otherwise you will get an AV in 'InvokeCodeCompletion'
      Allow := True;
      Manager.AllowCodeInsight(Allow, #0);
      if not Allow then
        Exit;

{$IFDEF IDE_SUPPORT_LSP}
      FKeepUnique := False; // 无需去重
{$ENDIF}

      // Not used, but the IDE calls it in this order, and the calling order might be important.
      ValidChars := Manager.EditorTokenValidChars(False);

      if not MyInvokeCodeCompletion(Manager) then
        Exit;

      try
        SymbolList := nil;
      {$IFDEF DEBUG}
        CnDebugger.LogMsg('Before Manager.GetSymbolList');
      {$ENDIF}
        Manager.GetSymbolList(SymbolList);
        if Assigned(SymbolList) then
        begin
        {$IFDEF DEBUG}
          CnDebugger.LogInteger(SymbolList.Count, 'IDE SymbolList.Count');
        {$ENDIF}

          try
            for I := 0 to SymbolList.Count - 1 do
            begin
              // follow code maybe raise exception, but disabled.
            {$IFDEF UTF8_SYMBOL}
              Name := string(FastUtf8ToAnsi(AnsiString(SymbolList.SymbolText[I])));
            {$ELSE}
              Name := SymbolList.SymbolText[I];
            {$ENDIF}
              Desc := SymbolList.SymbolTypeText[I];
              Kind := SymbolFlagsToKind(SymbolList.SymbolFlags[I], Desc);
              // Description is Utf-8 format under BDS.
              Idx := Add(Name, Kind, Round(MaxInt / SymbolList.Count * I), Desc, '', True,
                False, False, {$IFDEF UTF8_SYMBOL}True{$ELSE}False{$ENDIF});

              // 根据源文件的类型设置符号项的适用范围
              Items[Idx].ForPascal := PosInfo.IsPascal;
              Items[Idx].ForCpp := not PosInfo.IsPascal;
            end;
          except
          {$IFDEF DEBUG}
            on E: Exception do
            begin
              CnDebugger.LogMsg('Exception: ' + E.ClassName + ' ' + E.Message);
            end;
          {$ENDIF}
          end;
        end;
      finally
        DisplayParams := False;
        Manager.Done(False, DisplayParams);
      end;
    finally
    {$IFDEF SYMBOL_LOCKHOOK}
      LockHook.Free;
      UnLockHook.Free;
      ComtypesUnLock;
    {$ENDIF SYMBOL_LOCKHOOK}

      CodeInsightServices.SetQueryContext(nil, nil);
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('End AddToSymbolList');
    {$ENDIF}
    end;
  end;

begin
  Result := False;
  if PosInfo.PosKind in csNonCodePosKinds then
    Exit;

  EditView := Editor.TopView;
  if not Assigned(EditView) then
    Exit;

  // debug or comment will exit
  EditControlWrapper.GetAttributeAtPos(CnOtaGetCurrentEditControl,
    EditView.CursorPos, False, Element, LineFlag);
  if (LineFlag = lfCurrentEIP) or (Element = atComment) then
    Exit;

  Clear;
  CodeInsightServices := (BorlandIDEServices as IOTACodeInsightServices);
  if CodeInsightServices <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('IDE SymbolList Reload: CodeInsightManager Count '
      + IntToStr(CodeInsightServices.CodeInsightManagerCount));
{$ENDIF}

  {$IFDEF IDE_SetQueryContext_Bug}
    for Index := 0 to CodeInsightServices.CodeInsightManagerCount - 1 do
    begin
      CodeInsightManager := CodeInsightServices.CodeInsightManager[Index];
      if CodeInsightManager = nil then
        Continue;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('IDE SymbolList Reload: Add From CodeInsightManager: %d. Enabled: %d - %s - %s',
        [Index, Integer(CodeInsightManager.Enabled), CodeInsightManager.GetIDString, CodeInsightManager.Name]);
{$ENDIF}
      AddToSymbolList(CodeInsightManager);
    end;

    for Index := 0 to CodeInsightServices.CodeInsightManagerCount - 1 do
    begin
      CodeInsightManager := CodeInsightServices.CodeInsightManager[Index];
      // BDS2006/2007 下 SetQueryContext(nil, nil) 会导致 IDE 异常
      if CodeInsightManager.Enabled and CodeInsightManager.HandlesFile(Editor.FileName)
        and (Pos(UpperCase(CodeInsightManager.Name), UpperCase(csCIMgrNames)) > 0) then
      begin
        CodeInsightServices.SetQueryContext(nil, CodeInsightManager);
        Break;
      end;
    end;
  {$ELSE}
    CodeInsightServices.GetCurrentCodeInsightManager(CodeInsightManager);
    if (CodeInsightManager = nil) then
    begin
      for Index := 0 to CodeInsightServices.CodeInsightManagerCount - 1 do
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE SymbolList Reload: Current is NIL. Add From CodeInsightManager: Index ' + IntToStr(Index));
{$ENDIF}
        CodeInsightManager := CodeInsightServices.CodeInsightManager[Index];
        AddToSymbolList(CodeInsightManager);
      end;
    end
    else
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('IDE SymbolList Reload: Add From Current CodeInsightManager.');
{$ENDIF}
      AddToSymbolList(CodeInsightManager);
    end;
  {$ENDIF}
  end;

  Result := Count > 0;
end;

{$ENDIF SUPPORT_IOTACodeInsightManager}

{$IFDEF SUPPORT_KibitzCompile}

{******************************************************************************}
{ Code Note:                                                                   }
{    The code below is derived from GExperts 1.2                               }
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
  // 这个声明来自 TKibitzResult 记录的 RTTI 信息
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

const
  // dphideXX.bpl
  // DoKibitzCompile(FileName: AnsiString; XPos, YPos: Integer; var KibitzResult: TKibitzResult);
{$IFDEF COMPILER7_UP}
  DoKibitzCompileName = '@Pascodcmplt@DoKibitzCompile$qqrx17System@AnsiStringiir22Comtypes@TKibitzResult';
{$ELSE}
  DoKibitzCompileName = '@Codcmplt@DoKibitzCompile$qqrx17System@AnsiStringiir22Comtypes@TKibitzResult';
{$ENDIF COMPILER7_UP}
  // dccXX.dll
  // KibitzGetValidSymbols(var KibitzResult: TKibitzResult; Symbols: PSymbols; Unknowns: PUnknowns; SymbolCount: Integer): Integer; stdcall;
  KibitzGetValidSymbolsName = 'KibitzGetValidSymbols';
  // corideXX.bpl
  // Comdebug.CompGetSymbolText(Symbol: PSymbols; var S: string; Unknown: Word); stdcall;
  CompGetSymbolTextName = '@Comdebug@CompGetSymbolText$qqsp16Comtypes@TSymbolr17System@AnsiStringus';

type
  TDoKibitzCompileProc = procedure(FileName: AnsiString; XPos, YPos: Integer;
    var KibitzResult: TKibitzResult); register;

  TKibitzGetValidSymbolsProc = function(var KibitzResult: TKibitzResult;
    Symbols: PSymbols; Unknowns: PUnknowns; SymbolCount: Integer): Integer; stdcall;

  TCompGetSymbolTextProc = procedure(Symbol: Integer {Comtypes::TSymbol*};
    var S: string; Unknown: Word); stdcall;

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

var
  DoKibitzCompile: TDoKibitzCompileProc;
  KibitzGetValidSymbols: TKibitzGetValidSymbolsProc;
  CompGetSymbolText: TCompGetSymbolTextProc;
  KibitzEnabled: Boolean;

  KibitzThread: TKibitzThread;
  HookCS: TRTLCriticalSection;
  KibitzFinished: Boolean = False;
  Hook1: TCnMethodHook;
  Hook2: TCnMethodHook;

  CorIdeModule: HModule;
  DphIdeModule: HModule;
  dccModule: HModule;

function KibitzInitialize: Boolean;
begin
  Result := False;
  try
    DphIdeModule := LoadLibrary(DphIdeLibName);
    CnWizAssert(DphIdeModule <> 0, 'Load DphIdeModule');

    DoKibitzCompile := GetProcAddress(DphIdeModule, DoKibitzCompileName);
    CnWizAssert(Assigned(DoKibitzCompile), 'Load DoKibitzCompile from DphIdeModule');

    dccModule := LoadLibrary(dccLibName);
    CnWizAssert(dccModule <> 0, 'Load dccModule');

    KibitzGetValidSymbols := GetProcAddress(dccModule, KibitzGetValidSymbolsName);
    CnWizAssert(Assigned(KibitzGetValidSymbols), 'Load KibitzGetValidSymbols from dccModule');

    CorIdeModule := LoadLibrary(CorIdeLibName);
    CnWizAssert(CorIdeModule <> 0, 'Load CorIdeModule');

    CompGetSymbolText := GetProcAddress(CorIdeModule, CompGetSymbolTextName);
    CnWizAssert(Assigned(CompGetSymbolText), 'Load CompGetSymbolText');

    Result := True;
  {$IFDEF Debug}
    CnDebugger.LogMsg('KibitzInitialize succ');
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

  if dccModule <> 0 then
  begin
    FreeLibrary(dccModule);
    dccModule := 0;
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
{$IFDEF Debug}
  CnDebugger.LogMsg('FakeDoKibitzCompile');
{$ENDIF}
  FillChar(KibitzResult.KibitzDataArray, SizeOf(KibitzResult.KibitzDataArray), 0);
end;

function FakeKibitzGetValidSymbols(var KibitzResult: TKibitzResult;
  Symbols: PSymbols; Unknowns: PUnknowns; SymbolCount: Integer): Integer; stdcall;
begin
{$IFDEF Debug}
  CnDebugger.LogMsg('FakeKibitzGetValidSymbols');
{$ENDIF}
  Result := 0;
end;

{ TKibitzThread }

constructor TKibitzThread.Create(const FileName: AnsiString; X, Y: Integer);
begin
{$IFDEF Debug}
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
{$IFDEF Debug}
  CnDebugger.LogMsg('TKibitzThread.Destroy');
{$ENDIF}
  KibitzThread := nil;
  inherited;
end;

procedure TKibitzThread.Execute;
var
  KibitzResult: TKibitzResult;
begin
{$IFDEF Debug}
  CnDebugger.LogMsg('TKibitzThread.Execute');
{$ENDIF}
  try
    FillChar(KibitzResult, SizeOf(KibitzResult), 0);
    DoKibitzCompile(FFileName, FX, FY, KibitzResult);
  finally
    EnterCriticalSection(HookCS);
    try
      KibitzFinished := True;
      // 调用完成后恢复被 Hook 的函数
      FreeAndNil(Hook1);
      FreeAndNil(Hook2);
    finally
      LeaveCriticalSection(HookCS);
    end;
  end;
end;

function ParseProjectBegin(var FileName: AnsiString; var X, Y: Integer): Boolean;
var
  Stream: TMemoryStream;
  Lex: TCnGeneralPasLex; // Ansi/Ansi/Utf16
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ParseProjectBegin');
{$ENDIF}

  Result := False;
  FileName := CnOtaGetCurrentProjectFileName;
  Stream := nil;
  Lex := nil;

  try
    Stream := TMemoryStream.Create;
    EditFilerSaveFileToStream(FileName, Stream, True); // Ansi/Ansi/Utf16，符合 Lex

    Lex := TCnGeneralPasLex.Create;
    Lex.Origin := PChar(Stream.Memory);

    while Lex.TokenID <> tkNull do
    begin
      if Lex.TokenID = tkBegin then
      begin
        Lex.Next;
        X := 0;
{$IFDEF UNICODE}
        Y := Lex.LineNumber; // Wide 的 Lex 的行号本来就从 1 开始
{$ELSE}
        Y := Lex.LineNumber + 1;
{$ENDIF}
        Result := True;
        Break;
      end;
      Lex.Next;
    end;
  finally
    Lex.Free;
    Stream.Free;
  end;
end;

procedure InvokeKibitzCompileInThread;
var
  Save: TCursor;
  FileName: AnsiString;
  X, Y: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('CreateKibitzThread');
{$ENDIF}
  if not SupportKibitzCompileThread or not UseKibitzCompileThread or KibitzCompileThreadRunning then
    Exit;

  if ParseProjectBegin(FileName, X, Y) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('FileName: %s X: %d Y: %d', [FileName, X, Y]);
  {$ENDIF}

    Save := Screen.Cursor;
    KibitzFinished := False;
    KibitzThread := TKibitzThread.Create(FileName, X, Y);
    Sleep(50);  // 等待线程运行一会后再 Hook Kibitz 函数
    Screen.Cursor := Save; // 恢复原来的光标

    EnterCriticalSection(HookCS);
    try
      // 确保线程还没有结束前 Hook
      if not KibitzFinished then
      begin
        Hook1 := TCnMethodHook.Create(@DoKibitzCompile, @FakeDoKibitzCompile);
        Hook2 := TCnMethodHook.Create(@KibitzGetValidSymbols, @FakeKibitzGetValidSymbols);
      end;
    finally
      LeaveCriticalSection(HookCS);
    end;
  end;
end;

procedure TIDESymbolList.OnIdleExecute(Sender: TObject);
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

procedure TIDESymbolList.OnFileNotify(NotifyCode: TOTAFileNotification;
  const FileName: string);
begin
  if not SupportKibitzCompileThread or not UseKibitzCompileThread then
    Exit;

  if (NotifyCode = ofnFileOpened) and IsDpr(FileName) then
  begin
  {$IFDEF Debug}
    CnDebugger.LogFmt('TIDESymbolList.OnFileNotify: %s', [FileName]);
  {$ENDIF}
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnIdleExecute);
  end;
end;

function TIDESymbolList.Reload_KibitzCompile(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
const
  csMaxSymbolCount = 32768;
var
  KibitzResult: TKibitzResult;
  SymbolCount: Integer;
  Unknowns: PUnknowns;
  Symbols: PSymbols;
  CharPos: TOTACharPos;
  Text: string;
  I, Offset: Integer;

  procedure AddItem(const AText: string; Index: Integer);
  var
    Idx, Len: Integer;
    AName, ADesc: string;
    AKind: TSymbolKind;
  begin
    if Length(AText) > 6 then
    begin
      // 判断标识符的类型，简单判断以提高性能
      case AText[1] of
        'v':
          AKind := skVariable;       // 'var '
        'p':
          begin
            if AText[4] = 'c' then   // 'proc '
              AKind := skProcedure
            else                     // 'prop '
              AKind := skProperty;
          end;
        'f':
          AKind := skFunction;       // 'func '
        't':
          begin                      // 'type '
            if Pos(' = class', AText) > 0 then
              AKind := skClass
            else if Pos(' = interface', AText) > 0 then
              AKind := skInterface
            else
              AKind := skType;
          end;
        'c':
          AKind := skConstant;       // 'const '
        'r':
          AKind := skConstant;       // 'rstrg '
        '?':
          AKind := skKeyword;        // '??? '
      else
        begin
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('Unknown decl: ' + AText);
        {$ENDIF}
          AKind := skUnknown;
        end;
      end;

      // 取标识符名称
      Idx := 1;
      while AText[Idx] <> ' ' do     // 跳过类型声明
        Inc(Idx);
      while AText[Idx] = ' ' do      // 跳过空格
        Inc(Idx);
      Len := 0;
      while AText[Idx + Len] in ['a'..'z', 'A'..'Z', '0'..'9', '_'] do
        Inc(Len);
      AName := Copy(AText, Idx, Len);

      // 取描述信息
      while AText[Idx + Len] = ' ' do
        Inc(Len);
      ADesc := Copy(AText, Idx + Len, MaxInt);

      // 错误的变量
      if (AKind = skVariable) and (CompareStr(ADesc, ': erroneous type') = 0) then
        Exit;

      // 增加新项
      Add(AName, AKind, Round(MaxInt / SymbolCount * Index), ADesc);
    end;
  end;

begin
  Result := False;
  if not KibitzEnabled or (PosInfo.PosKind in csNonCodePosKinds)
    or KibitzCompileThreadRunning then
    Exit;

  Clear;
  try
    FillChar(KibitzResult, SizeOf(KibitzResult), 0);
    CharPos := CnOtaGetCurrCharPos(nil);
    if PosInfo.PosKind in [pkClass, pkInterface, pkField] then
      Offset := -Length(InputText)
    else
      Offset := 0;

    // 执行符号信息编译
    DoKibitzCompile(Editor.FileName, CharPos.CharIndex + Offset, CharPos.Line,
      KibitzResult);

    // 以下代码在 GExperts 中使用，用途未明。使用后会导致某些枚举值出不来，此处禁用
    //if Byte(KibitzResult.KibitzDataArray[0]) in [$0B, $08, $09] then
    //  Exit;

    Symbols := nil;
    Unknowns := nil;
    try
      // 分配临时内存
      GetMem(Symbols, csMaxSymbolCount * SizeOf(Integer));
      GetMem(Unknowns, csMaxSymbolCount * SizeOf(Byte));

      // 取得有效的符号表及总数
      SymbolCount := KibitzGetValidSymbols(KibitzResult, Symbols, Unknowns,
        csMaxSymbolCount);

      // 增加符号项
      List.Capacity := SymbolCount;
      for I := 0 to SymbolCount - 1 do
      begin
        CompGetSymbolText(Symbols^[I], Text, 1);
        AddItem(Text, I);
      end;

      Result := Count > 0;
{$IFDEF DEBUG}
      CnDebugger.LogMsg(Format('TIDESymbolList.Reload, Count: %d', [Count]));
{$ENDIF}
    finally
      if Unknowns <> nil then
        FreeMem(Unknowns);
      if Symbols <> nil then
        FreeMem(Symbols);
    end;
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;
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

constructor TIDESymbolList.Create;
begin
  inherited;
{$IFDEF IDE_SUPPORT_LSP}
  FHashList := TCnStrToStrHashMap.Create(HashSize);
{$ENDIF}

{$IFDEF SUPPORT_KibitzCompile}
  KibitzEnabled := KibitzInitialize;
  InitializeCriticalSection(HookCS);
  InvokeKibitzCompileInThread;
  CnWizNotifierServices.AddFileNotifier(OnFileNotify);
{$ENDIF SUPPORT_KibitzCompile}
end;

destructor TIDESymbolList.Destroy;
begin
{$IFDEF SUPPORT_KibitzCompile}
  CnWizNotifierServices.RemoveFileNotifier(OnFileNotify);
  KibitzFinalize;
{$ENDIF SUPPORT_KibitzCompile}

{$IFDEF IDE_SUPPORT_LSP}
  FHashList.Free;
{$ENDIF}
  inherited;
end;

class function TIDESymbolList.GetListName: string;
begin
  Result := SCnInputHelperIDESymbolList;
end;

function TIDESymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
{$IFDEF SUPPORT_IDESYMBOLLIST}

{$IFDEF SUPPORT_MULTI_IDESymbolList}
  if UseCodeInsightMgr then
    Result := Reload_CodeInsightManager(Editor, InputText, PosInfo)
  else
    Result := Reload_KibitzCompile(Editor, InputText, PosInfo);
{$ELSE}

{$IFDEF SUPPORT_IOTACodeInsightManager}
  Result := Reload_CodeInsightManager(Editor, InputText, PosInfo);
{$ENDIF SUPPORT_IOTACodeInsightManager}

{$IFDEF SUPPORT_KibitzCompile}
  Result := Reload_KibitzCompile(Editor, InputText, PosInfo);
{$ENDIF SUPPORT_KibitzCompile}

{$ENDIF SUPPORT_MULTI_IDESymbolList}

{$ELSE}
  Result := False;
{$ENDIF SUPPORT_IDESYMBOLLIST}
end;

function TIDESymbolList.Add(const AName: string; AKind: TSymbolKind;
  AScope: Integer; const ADescription, AText: string; AAutoIndent,
  AMatchFirstOnly, AAlwaysDisp, ADescIsUtf8: Boolean): Integer;
{$IFDEF IDE_SUPPORT_LSP}
var
  Res: string;
{$ENDIF}
begin
{$IFDEF IDE_SUPPORT_LSP}
  Result := -1;
  if FKeepUnique and FHashList.Find(AName + ADescription, Res) then
  begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('IDE SymbolList Found Duplicated: %s. Do NOT Add.',
//      [AName]);
{$ENDIF}
    Exit;
  end;
  FHashList.Add(AName + ADescription, AName);
{$ENDIF}

  Result := inherited Add(AName, AKind, AScope, ADescription, AText, AAutoIndent,
    AMatchFirstOnly, AAlwaysDisp, ADescIsUtf8);
end;

procedure TIDESymbolList.Cancel;
begin
{$IFDEF IDE_SUPPORT_LSP}
  FAnsycCancel := True;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('IDE SymbolList Cancel.');
{$ENDIF}
{$ENDIF}
end;

procedure TIDESymbolList.Clear;
begin
{$IFDEF IDE_SUPPORT_LSP}
  FHashList.Free;
  FHashList := TCnStrToStrHashMap.Create(HashSize);
{$ENDIF}
  inherited;
end;

initialization
{$IFDEF SUPPORT_IDESYMBOLLIST}
{$IFNDEF BCB5}  // 支持 BCB5/6 的 IDE 符号列表差异较大，放另外一个单元。
{$IFNDEF BCB6}
  RegisterSymbolList(TIDESymbolList);

  {$IFDEF IDE_SUPPORT_LSP}
  FDelphiLspHandle := GetModuleHandle(IdeLspLibName);
  if FDelphiLspHandle <> 0 then
  begin
    DelphiLspGetCount := TDelphiLSPKibitzManagerGetCount(GetProcAddress(FDelphiLspHandle, SDelphiLspGetCount));
    DelphiLspGetCodeCompEntry := TDelphiLSPKibitzManagerGetCodeCompEntry(GetProcAddress(FDelphiLspHandle, SDelphiLspGetCodeCompEntry));
  end;

  FBcbLspHandle := GetModuleHandle(IdeBcbLspLibName);
  if FBcbLspHandle <> 0 then
  begin
    BcbLspGetCount := TBcbLSPKibitzManagerGetCount(GetProcAddress(FBcbLspHandle, SBcbLspGetCount));
    BcbLspGetCodeCompEntry := TBcbLSPKibitzManagerGetCodeCompEntry(GetProcAddress(FBcbLspHandle, SBcbLspGetCodeCompEntry));
  end;
  {$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}

{$ENDIF CNWIZARDS_CNINPUTHELPER}
end.
