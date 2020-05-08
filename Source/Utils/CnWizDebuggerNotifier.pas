{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2020 CnPack ������                       }
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
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizDebuggerNotifier;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE Debugger ֪ͨ����Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע���õ�Ԫ�ṩ�� IDE Debugger ֪ͨ�¼�����
            Debugger ϵ��֪ͨ������Ϊ�ṹ�ĸ����ԣ���д�ɶ�����Ԫ�еĶ�������ӿ�
* ����ƽ̨��PWin2000Pro + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2013.06.03
*               ���ӻ�ȡ��ǰ�ϵ���Ϣ�ķ���
*           2006.11.10
*               ���� Evaluate �������ֵ����
*           2006.10.06
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, ToolsAPI, AppEvnts,
  Contnrs, Consts, CnWizUtils, CnClasses;

type
  // ����֪ͨ�����ͣ��Զ���
  TCnProcessNotifyReason = (cprCreated, cprDestroyed);

  // �߳�֪ͨ�����ͣ��� TOTANotifyReason �����Զ���ĺ�����
  TCnThreadNotifyReason = (ctrOther, ctrRunning, ctrStopped, ctrException,
    ctrFault, ctrCreated, ctrDestroyed);

  // �ϵ�֪ͨ�����ͣ��Զ���
  TCnBreakpointNotifyReason = (cbrAdded, cbrDeleted);

  // ����֪ͨ���¼�ԭ��
  TCnProcessNotifier = procedure (Process: IOTAProcess;
    Reason: TCnProcessNotifyReason) of object;

  // �߳�֪ͨ���¼�ԭ��
  TCnThreadNotifier = procedure (Process: IOTAProcess; Thread: IOTAThread;
    Reason: TCnThreadNotifyReason) of object;

  // �ϵ�֪ͨ���¼�ԭ��
  TCnBreakpointNotifier = procedure (Breakpoint: IOTABreakpoint;
    Reason: TCnBreakpointNotifyReason) of object;

  ICnWizDebuggerNotifierServices = interface(IUnknown)
  {* IDE Debugger ֪ͨ����ӿ�}
    ['{DB7A86E5-71AB-4095-B34E-F4C1985F703C}']
    procedure AddProcessNotifier(Notify: TCnProcessNotifier);
    {* ����һ�������Խ��̵�֪ͨ�¼�}
    procedure RemoveProcessNotifier(Notify: TCnProcessNotifier);
    {* ɾ��һ�������Խ��̵�֪ͨ�¼�}
    procedure AddThreadNotifier(Notify: TCnThreadNotifier);
    {* ����һ���������̵߳�֪ͨ�¼�}
    procedure RemoveThreadNotifier(Notify: TCnThreadNotifier);
    {* ɾ��һ���������̵߳�֪ͨ�¼�}
    procedure AddBreakpointNotifier(Notify: TCnBreakpointNotifier);
    {* ����һ���ϵ��֪ͨ�¼�}
    procedure RemoveBreakpointNotifier(Notify: TCnBreakpointNotifier);
    {* ɾ��һ���ϵ�֪ͨ�¼�}

    procedure RetrieveBreakpoints(Results: TList; const FileName: string = '');
    {* ��ȡָ���ļ��е�ȫ���ϵ��б����ļ���δָ������ǰ���жϵ��б�
       ע�� List �����ɵ��� TCnBreakpointDescriptor ʵ�����ڲ������ⲿ�����ͷ�}
  end;

  TCnBreakpointDescriptor = class(TPersistent)
  {* ���ڱ� Service �б���ϵ�Ļ�����Ϣ}
  private
    FEnabled: Boolean;
    FLineNumber: Integer;
    FFileName: string;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}

    property FileName: string read FFileName write FFileName;
    property Enabled: Boolean read FEnabled write FEnabled;
    property LineNumber: Integer read FLineNumber write FLineNumber;
  end;

function CnWizDebuggerNotifierServices: ICnWizDebuggerNotifierServices;
{* ��ȡ IDE Debugger ֪ͨ����ӿ�}

function EvaluateExpression(AThreadIntf: IOTAThread; const ExprStr: string;
  ResultStr: PChar; ResultStrSize: LongWord; out CanModify: Boolean;
  AllowSideEffects: Boolean; FormatSpecifiers: PAnsiChar; out ResultAddr: LongWord;
  out ResultSize, ResultVal: LongWord; WaitMilliSec: Cardinal = 1000): Boolean;
{* ��������ʽ��Ŀ���߳��ڵı��ʽֵ�����صĽ�����£�
   ����Ƕ��������ַ�� ResultAddr �У�([csInheritable]) ֮��ķ��� ResultStr
   ������ַ���ֵ����ֵ���������ѱ�ת�����ַ�������ڴ���� ResultStr ��������
   ������ʽ������ ResultAddr �ᱻ��ֵ�� -1, ResultStr ��ֵΪ Inaccessable...}

implementation

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF}CnWizNotifier;

type
  TCnEvaluateResult = packed record
    EvaluateCompleted: Boolean;
    ExprStr: string;
    ResultStr: string;
    CanModify: Boolean;
    ResultAddress: LongWord;
    ResultSize: LongWord;
    ReturnCode: Integer;
  end;

  TCnOTAProcess = class;
  TCnOTAThread = class;
  TCnWizDebuggerNotifierServices = class;

  TCnOTAProcessNotifier = class(TNotifierObject, IOTAProcessNotifier)
  {* ʵ�ֱ����Խ���֪ͨ����˽����}
  private
    FDebuggerNotifierServices: TCnWizDebuggerNotifierServices;

    FProcess: TCnOTAProcess;
    FProcessIntf: IOTAProcess;
  public
    constructor Create(AProcess: TCnOTAProcess);
    destructor Destroy; override;

    procedure ThreadCreated({$IFDEF BDS} const {$ENDIF} Thread: IOTAThread);
    procedure ThreadDestroyed({$IFDEF BDS} const {$ENDIF}Thread: IOTAThread);
    procedure ProcessModuleCreated({$IFDEF BDS} const {$ENDIF}ProcessModule: IOTAProcessModule);
    procedure ProcessModuleDestroyed({$IFDEF BDS} const {$ENDIF}ProcessModule: IOTAProcessModule);
  end;

  TCnOTAThreadNotifier = class(TNotifierObject, IOTAThreadNotifier)
  {* ʵ�ֱ������߳�֪ͨ����˽����}
  private
    FDebuggerNotifierServices: TCnWizDebuggerNotifierServices;

    FThread: TCnOTAThread;
    FThreadIntf: IOTAThread;
    FProcess: TCnOTAProcess;
    FProcessIntf: IOTAProcess;
  public
    constructor Create(AThread: TCnOTAThread);
    destructor Destroy; override;

    procedure ThreadNotify(Reason: TOTANotifyReason);
    procedure EvaluateComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
    procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);
  end;

  TCnOTAProcess = class(TObject)
  {* ����һ�����Խ��̵�˽���࣬�ڿɺ�����߳�}
  private
    FDebuggerNotifierServices: TCnWizDebuggerNotifierServices;

    FProcess: IOTAProcess;
    FProcessNotifierIndex: Integer;
    FProcessNotifier: TCnOTAProcessNotifier;
    FThreads: TList; // Contains TCnOTAThread
  public
    constructor Create(Process: IOTAProcess;
      ADebuggerNotifierServices: TCnWizDebuggerNotifierServices);
    destructor Destroy; override;

    procedure AddThread(Thread: IOTAThread);
    procedure RemoveThread(Thread: IOTAThread);

    property Process: IOTAProcess read FProcess write FProcess;
    property ProcessNotifierIndex: Integer read FProcessNotifierIndex;
  end;

  TCnOTAThread = class(TObject)
  {* ����һ�������̵߳�˽����}
  private
    FDebuggerNotifierServices: TCnWizDebuggerNotifierServices;
    FProcess: TCnOTAProcess;

    FThread: IOTAThread;
    FThreadNotifierIndex: Integer;
    FThreadNotifier: TCnOTAThreadNotifier;

  public
    constructor Create(AProcess: TCnOTAProcess; Thread: IOTAThread;
      ADebuggerNotifierServices: TCnWizDebuggerNotifierServices);
    destructor Destroy; override;

    property Process: TCnOTAProcess read FProcess;
    property Thread: IOTAThread read FThread;
    property ThreadNotifierIndex: Integer read FThreadNotifierIndex;
  end;

  TCnWizDebuggerNotifierServices = class(TSingletonInterfacedObject,
    ICnWizDebuggerNotifierServices)
  {* ʵ�� IDE �� Debugger �¼�֪ͨ����ӿڵ�˽����}
  private
    FProcesses: TList;         // Contains TCnOTAProcess
    FBreakpoints: TObjectList; // Contains Breakpoints
    FThreadNotifiers: TList;
    FProcessNotifiers: TList;
    FBreakpointNotifiers: TList;

    function IndexOf(List: TList; Notifier: TMethod): Integer;
    procedure AddNotifier(List: TList; Notifier: TMethod);
    procedure RemoveNotifier(List: TList; Notifier: TMethod);
    procedure ClearAndFreeList(var List: TList);

    procedure AddBreakpointDescriptor(const FileName: string; LineNumber: Integer;
      Enabled: Boolean);
    function FindBreakpointDescriptor(const FileName: string; LineNumber: Integer): TCnBreakpointDescriptor;
    procedure RemoveBreakpointDescriptor(const FileName: string; LineNumber: Integer);
  protected
    // ע�ᵽ ICnWizNotifierService �ı�֪ͨ��
    procedure ProcessCreated(Process: IOTAProcess);
    procedure ProcessDestroyed(Process: IOTAProcess);
    procedure BreakpointAdded(Breakpoint: IOTABreakpoint);
    procedure BreakpointDeleted(Breakpoint: IOTABreakpoint);

    // ������֪ͨ�����ܵ��õ��߳��¼�֪ͨ
    procedure ThreadNotify(Process: IOTAProcess; Thread: IOTAThread;
      Reason: TCnThreadNotifyReason);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddThreadNotifier(Notify: TCnThreadNotifier);
    procedure RemoveThreadNotifier(Notify: TCnThreadNotifier);
    procedure AddProcessNotifier(Notify: TCnProcessNotifier);
    procedure RemoveProcessNotifier(Notify: TCnProcessNotifier);
    procedure AddBreakpointNotifier(Notify: TCnBreakpointNotifier);
    procedure RemoveBreakpointNotifier(Notify: TCnBreakpointNotifier);

    procedure RetrieveBreakpoints(Results: TList; const FileName: string = '');
  end;

var
  FCnWizDebuggerNotifierServices: TCnWizDebuggerNotifierServices = nil;

  EvaluateResult: TCnEvaluateResult;
  CSInited: Boolean = False;
  CSEvaluate: TRTLCriticalSection;

// ȥ�� PChar �ַ�������ͷ�ĵ���������
procedure CropQuota(Str: PChar);
var
  Len, I: Integer;
  // Idx: PChar;
begin
  if Str <> nil then
  begin
    // PChar ���±�� 0 ��ʼ����ͬ�� string �Ĵ� 1 ��ʼ
    Len := StrLen(Str);
    if (Str[0] = '''') and (Str[Len - 1] = '''') then // ����ͷ�������Ų���
    begin
      Str[Len - 1] := #0; // ȥ��ĩβ�ĵ�����
      Dec(Len);

      if Str[0] = '''' then  // �ƶ���ȥ��ͷ�ĵ�����
      begin
        Dec(Len);
        for I := 0 to Len - 1 do
          Str[I] := Str[I + 1];
        Str[Len] := #0;
      end;
    end;

{   Idx := StrPos(Str, '''''');
    while Idx <> nil do
    begin
      Len := StrLen(Idx);
      for I := 0 to Len - 1 do
        Idx[I] := Idx[I + 1];
      Idx[Len] := #0;

      Idx := StrPos(Str, '''''');

    end; }
    // �������������ĵ��������ƶ��Լ���һ������Ϊ IDE ���Ὣ�������Ż�������
  end;
end;

// ��ȡ IDE Debugger ֪ͨ����ӿ�
function CnWizDebuggerNotifierServices: ICnWizDebuggerNotifierServices;
begin
  if not Assigned(FCnWizDebuggerNotifierServices) then
    FCnWizDebuggerNotifierServices := TCnWizDebuggerNotifierServices.Create;
  Result := FCnWizDebuggerNotifierServices as ICnWizDebuggerNotifierServices;
end;

// ��������ʽ���߳��ڵı��ʽֵ
function EvaluateExpression(AThreadIntf: IOTAThread; const ExprStr: string;
  ResultStr: PChar; ResultStrSize: LongWord; out CanModify: Boolean;
  AllowSideEffects: Boolean; FormatSpecifiers: PAnsiChar; out ResultAddr: LongWord;
  out ResultSize, ResultVal: LongWord; WaitMilliSec: Cardinal): Boolean;
const
  SEvaluateTimeout = 'Evaluate Time Out.';
var
  Er: TOTAEvaluateResult;
  Len: LongWord;
  Ticks: DWORD;
begin
  Result := False;
  if (AThreadIntf <> nil) and (AThreadIntf.State in [tsStopped, tsBlocked]) then
  begin
    try
      EvaluateResult.EvaluateCompleted := False;
      Er := AThreadIntf.Evaluate(ExprStr, ResultStr, ResultStrSize, CanModify,
        AllowSideEffects, FormatSpecifiers, ResultAddr, ResultSize, ResultVal);

      Result := (Er <> erError);
      if Er = erOK then
      begin
        // OK, ȥ������ֵ��ͷ�ĵ����ź�ֱ�ӷ���
{$IFDEF DEBUG}
        CnDebugger.LogFmt('EvaluateExpression %s. Get the Result %s.', [ExprStr, ResultStr]);
{$ENDIF}
        CropQuota(ResultStr); 
        EvaluateResult.EvaluateCompleted := True;
      end
      else if Er = erDeferred then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('EvaluateExpression %s. Waiting For Result.', [ExprStr]);
{$ENDIF}
        EvaluateResult.EvaluateCompleted := False;

        // ��ʱ����
        if WaitMilliSec <= 0 then WaitMilliSec := 1000;
        Ticks := GetTickCount + WaitMilliSec;
        while not EvaluateResult.EvaluateCompleted and (GetTickCount < Ticks) do
          Application.ProcessMessages;

        if not EvaluateResult.EvaluateCompleted then
        begin
          Result := False;
          Len := Length(SEvaluateTimeout);
          if Len > ResultStrSize - 1 then Len := ResultStrSize - 1;
          StrLCopy(ResultStr, PChar(SEvaluateTimeout), Len);
          Exit;
        end;

{$IFDEF DEBUG}
        CnDebugger.LogMsg('Evaluate Result Comes.');
{$ENDIF DEBUG}

        // ����Ӧ����������
        CanModify := EvaluateResult.CanModify;
        ResultAddr := EvaluateResult.ResultAddress;
        ResultSize := EvaluateResult.ResultSize;
        ResultVal := EvaluateResult.ReturnCode;

        Len := Length(EvaluateResult.ResultStr);
        if Len > ResultStrSize - 1 then Len := ResultStrSize - 1;
        StrLCopy(ResultStr, PChar(EvaluateResult.ResultStr), Len);
        CropQuota(ResultStr); // ȥ����ͷ�ĵ�����
      end
      else
      begin
        ; // ����������Ϣ�վɷ��أ��˴������ɶ
{$IFDEF DEBUG}
        CnDebugger.LogErrorFmt('EvaluateExpression Error. %s.', [ExprStr]);
{$ENDIF DEBUG}
      end;
    except

    end;
  end;
end;

{ TCnWizDebuggerNotifierServices }

constructor TCnWizDebuggerNotifierServices.Create;
begin
  inherited;
  FProcesses := TList.Create;
  FProcessNotifiers := TList.Create;
  FThreadNotifiers := TList.Create;
  FBreakpointNotifiers := TList.Create;

  FBreakpoints := TObjectList.Create(True);

  CnWizNotifierServices.AddProcessCreatedNotifier(ProcessCreated);
  CnWizNotifierServices.AddProcessDestroyedNotifier(ProcessDestroyed);
  CnWizNotifierServices.AddBreakpointAddedNotifier(BreakpointAdded);
  CnWizNotifierServices.AddBreakpointDeletedNotifier(BreakpointDeleted);
end;

destructor TCnWizDebuggerNotifierServices.Destroy;
var
  I: Integer;
begin
  for I := FProcesses.Count - 1 downto 0 do
    if FProcesses[I] <> nil then
      TCnOTAProcess(FProcesses[I]).Free;

  FProcesses.Free;
  FBreakpoints.Free;
  ClearAndFreeList(FThreadNotifiers);
  ClearAndFreeList(FProcessNotifiers);
  ClearAndFreeList(FBreakpointNotifiers);

  CnWizNotifierServices.RemoveProcessCreatedNotifier(ProcessCreated);
  CnWizNotifierServices.RemoveProcessDestroyedNotifier(ProcessDestroyed);
  CnWizNotifierServices.RemoveBreakpointAddedNotifier(BreakpointAdded);
  CnWizNotifierServices.RemoveBreakpointDeletedNotifier(BreakpointDeleted);
  inherited;
end;

procedure TCnWizDebuggerNotifierServices.ProcessCreated(
  Process: IOTAProcess);
var
  AProcess: TCnOTAProcess;
  I: Integer;
begin
  AProcess := TCnOTAProcess.Create(Process, Self);
  AProcess.FProcess := Process;
  AProcess.FProcessNotifier.FProcessIntf := Process;
  AProcess.FProcessNotifierIndex := Process.AddNotifier(AProcess.FProcessNotifier as IOTAProcessNotifier);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnWizDebuggerNotifierServices ProcessCreated Called %d %d', [Integer(AProcess.FProcessNotifier), AProcess.FProcessNotifierIndex ]);
{$ENDIF DEBUG}
  FProcesses.Add(AProcess);

  if FProcessNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices ProcessNotified, Reason Created.');
{$ENDIF DEBUG}
    for I := FProcessNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FProcessNotifiers[I])^ do
        TCnProcessNotifier(Notifier)(Process, cprCreated);
    except
      DoHandleException('TCnWizDebuggerNotifierServices.ProcessNotified[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.ProcessDestroyed(
  Process: IOTAProcess);
var
  I: Integer;
begin
  for I := FProcesses.Count - 1 downto 0 do
  begin
    if TCnOTAProcess(FProcesses[I]).FProcess = Process then
    begin
      Process.RemoveNotifier(TCnOTAProcess(FProcesses[I]).FProcessNotifierIndex);
      TCnOTAProcess(FProcesses[I]).FProcessNotifierIndex := -1;
      TCnOTAProcess(FProcesses[I]).Free;
      FProcesses.Delete(I);
      Break;
    end;
  end;

  if FProcessNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices ProcessNotified, Reason Destroyed.');
{$ENDIF DEBUG}
    for I := FProcessNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FProcessNotifiers[I])^ do
        TCnProcessNotifier(Notifier)(Process, cprDestroyed);
    except
      DoHandleException('TCnWizDebuggerNotifierServices.ProcessNotified[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.BreakpointAdded(
  Breakpoint: IOTABreakpoint);
var
  I: Integer;
begin
  if FBreakpointNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices BreakpointNotified, Reason Added.');
{$ENDIF DEBUG}
    AddBreakpointDescriptor(Breakpoint.FileName, Breakpoint.LineNumber, Breakpoint.Enabled);

    for I := FBreakpointNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FBreakpointNotifiers[I])^ do
        TCnBreakpointNotifier(Notifier)(Breakpoint, cbrAdded);
    except
      DoHandleException('TCnWizDebuggerNotifierServices.BreakpointNotified[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.BreakpointDeleted(
  Breakpoint: IOTABreakpoint);
var
  I: Integer;
begin
  if FBreakpointNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices BreakpointNotified, Reason Deleted.');
{$ENDIF DEBUG}
    RemoveBreakpointDescriptor(Breakpoint.FileName, Breakpoint.LineNumber);

    for I := FBreakpointNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FBreakpointNotifiers[I])^ do
        TCnBreakpointNotifier(Notifier)(Breakpoint, cbrDeleted);
    except
      DoHandleException('TCnWizDebuggerNotifierServices.BreakpointNotified[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.AddNotifier(List: TList;
  Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
begin
  if IndexOf(List, Notifier) < 0 then
  begin
    New(Rec);
    Rec^.Notifier := TMethod(Notifier);
    List.Add(Rec);
  end;
end;

procedure TCnWizDebuggerNotifierServices.RemoveNotifier(List: TList;
  Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
  Idx: Integer;
begin
  Idx := IndexOf(List, Notifier);
  if Idx >= 0 then
  begin
    Rec := List[Idx];
    Dispose(Rec);
    List.Delete(Idx);
  end;
end;

procedure TCnWizDebuggerNotifierServices.ThreadNotify(Process: IOTAProcess;
  Thread: IOTAThread; Reason: TCnThreadNotifyReason);
var
  I: Integer;
begin
  if FThreadNotifiers <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnWizDebuggerNotifierServices ThreadNotified, Reason ' + IntToStr(Ord(Reason)));
{$ENDIF DEBUG}
    for I := FThreadNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FThreadNotifiers[I])^ do
        TCnThreadNotifier(Notifier)(Process, Thread, Reason);
    except
      DoHandleException('TCnWizDebuggerNotifierServices.ThreadNotify[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.ClearAndFreeList(var List: TList);
var
  Rec: PCnWizNotifierRecord;
begin
  while List.Count > 0 do
  begin
    Rec := List[0];
    Dispose(Rec);
    List.Delete(0);
  end;
  FreeAndNil(List);
end;

function TCnWizDebuggerNotifierServices.IndexOf(List: TList;
  Notifier: TMethod): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to List.Count - 1 do
    if CompareMem(List[I], @Notifier, SizeOf(TMethod)) then
    begin
      Result := I;
      Exit;
    end;
end;

procedure TCnWizDebuggerNotifierServices.AddProcessNotifier(
  Notify: TCnProcessNotifier);
begin
  AddNotifier(FProcessNotifiers, TMethod(Notify));
end;

procedure TCnWizDebuggerNotifierServices.RemoveProcessNotifier(
  Notify: TCnProcessNotifier);
begin
  RemoveNotifier(FProcessNotifiers, TMethod(Notify));
end;

procedure TCnWizDebuggerNotifierServices.AddThreadNotifier(
  Notify: TCnThreadNotifier);
begin
  AddNotifier(FThreadNotifiers, TMethod(Notify));
end;

procedure TCnWizDebuggerNotifierServices.RemoveThreadNotifier(
  Notify: TCnThreadNotifier);
begin
  RemoveNotifier(FThreadNotifiers, TMethod(Notify));
end;

procedure TCnWizDebuggerNotifierServices.AddBreakpointNotifier(
  Notify: TCnBreakpointNotifier);
begin
  AddNotifier(FBreakpointNotifiers, TMethod(Notify));
end;

procedure TCnWizDebuggerNotifierServices.RemoveBreakpointNotifier(
  Notify: TCnBreakpointNotifier);
begin
  RemoveNotifier(FBreakpointNotifiers, TMethod(Notify));
end;

function TCnWizDebuggerNotifierServices.FindBreakpointDescriptor(
  const FileName: string; LineNumber: Integer): TCnBreakpointDescriptor;
var
  I: Integer;
  B: TCnBreakpointDescriptor;
begin
  Result := nil;
  for I := 0 to FBreakpoints.Count - 1 do
  begin
    B := TCnBreakpointDescriptor(FBreakpoints[I]);
    if (B <> nil) and (B.FileName = FileName) and (B.LineNumber = LineNumber) then
    begin
      Result := B;
      Exit;
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.RemoveBreakpointDescriptor(
  const FileName: string; LineNumber: Integer);
var
  I: Integer;
  B: TCnBreakpointDescriptor;
begin
  for I := FBreakpoints.Count - 1 downto 0 do
  begin
    B := TCnBreakpointDescriptor(FBreakpoints[I]);
    if (B <> nil) and (B.FileName = FileName) and (B.LineNumber = LineNumber) then
    begin
      FBreakpoints.Delete(I);
      Exit;
    end;
  end;
end;

procedure TCnWizDebuggerNotifierServices.AddBreakpointDescriptor(
  const FileName: string; LineNumber: Integer; Enabled: Boolean);
var
  B: TCnBreakpointDescriptor;
begin
  B := FindBreakpointDescriptor(FileName, LineNumber);
  if B <> nil then
    B.Enabled := Enabled
  else
  begin
    B := TCnBreakpointDescriptor.Create;
    B.Enabled := Enabled;
    B.FileName := FileName;
    B.LineNumber := LineNumber;
    FBreakpoints.Add(B);
  end;
end;

procedure TCnWizDebuggerNotifierServices.RetrieveBreakpoints(
  Results: TList; const FileName: string);
var
  I: Integer;
begin
  if Results = nil then
    Exit;

  Results.Clear;
  for I := 0 to FBreakpoints.Count - 1 do
  begin
    if (FileName = '') or (TCnBreakpointDescriptor(FBreakpoints[I]).FileName = FileName) then
      Results.Add(FBreakpoints[I]);
  end;
end;

{ TCnOTAProcess }

procedure TCnOTAProcess.AddThread(Thread: IOTAThread);
var
  AThread: TCnOTAThread;
begin
  AThread := TCnOTAThread.Create(Self, Thread, FDebuggerNotifierServices);
  AThread.FThreadNotifierIndex := Thread.AddNotifier(AThread.FThreadNotifier as IOTAThreadNotifier);
  FThreads.Add(AThread);
end;

constructor TCnOTAProcess.Create(Process: IOTAProcess;
  ADebuggerNotifierServices: TCnWizDebuggerNotifierServices);
begin
  inherited Create;
  FDebuggerNotifierServices := ADebuggerNotifierServices;
  FThreads := TList.Create;
  FProcess := Process;
  FProcessNotifier := TCnOTAProcessNotifier.Create(Self);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAProcess.Created.');
{$ENDIF DEBUG}
end;

destructor TCnOTAProcess.Destroy;
var
  I: Integer;
begin
  if FProcessNotifierIndex >= 0 then
    FProcess.RemoveNotifier(FProcessNotifierIndex);

  for I := FThreads.Count - 1 downto 0 do
    if FThreads[I] <> nil then
      TCnOTAThread(FThreads[I]).Free;
      
  FThreads.Free;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAProcess.Destroyed.');
{$ENDIF DEBUG}
  inherited;
end;

procedure TCnOTAProcess.RemoveThread(Thread: IOTAThread);
var
  I: Integer;
begin
  for I := FThreads.Count - 1 downto 0 do
  begin
    if TCnOTAThread(FThreads[I]).Thread = Thread then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnOTAProcess.RemoveThread. ThreadNotifierIndex = '+ InttoStr(TCnOTAThread(FThreads[I]).FThreadNotifierIndex));
{$ENDIF DEBUG}
      Thread.RemoveNotifier(TCnOTAThread(FThreads[I]).FThreadNotifierIndex);
      // RemoveNotifier ���������ü������� FThreads[I] �� ThreadNotifier ���ͷ�
      TCnOTAThread(FThreads[I]).FThreadNotifierIndex := -1;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnOTAProcess.RemoveThread. To Free FThreads ' + InttoStr(I));
{$ENDIF DEBUG}
      TCnOTAThread(FThreads[I]).Free;
      FThreads.Delete(I);
      Break;
    end;
  end;
end;

{ TCnOTAProcessNotifier }

constructor TCnOTAProcessNotifier.Create(AProcess: TCnOTAProcess);
begin
  inherited Create;
  FProcess := AProcess;
  FProcessIntf := AProcess.Process;
  FDebuggerNotifierServices := AProcess.FDebuggerNotifierServices;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAProcessNotifier Created. Process Intf '+ InttoStr(Integer(FProcessIntf)));
{$ENDIF DEBUG}
  // ��֤ Notifier �õ�����·ŵĽӿ�ʵ��
end;

destructor TCnOTAProcessNotifier.Destroy;
begin
  FProcess := nil;
  FProcessIntf := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAProcessNotifier Destroyed.');
{$ENDIF DEBUG}
  inherited;
end;

procedure TCnOTAProcessNotifier.ProcessModuleCreated({$IFDEF BDS} const {$ENDIF}
  ProcessModule: IOTAProcessModule);
begin

end;

procedure TCnOTAProcessNotifier.ProcessModuleDestroyed({$IFDEF BDS} const {$ENDIF}
  ProcessModule: IOTAProcessModule);
begin

end;

procedure TCnOTAProcessNotifier.ThreadCreated({$IFDEF BDS} const {$ENDIF}Thread: IOTAThread);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnOTAProcessNotifier ThreadCreated. FProcess = %d', [Integer(FProcess)]);
{$ENDIF DEBUG}
  FProcess.AddThread(Thread);
  FDebuggerNotifierServices.ThreadNotify(FProcessIntf, Thread, ctrCreated);
end;

procedure TCnOTAProcessNotifier.ThreadDestroyed({$IFDEF BDS} const {$ENDIF}Thread: IOTAThread);
begin
  FDebuggerNotifierServices.ThreadNotify(FProcessIntf, Thread, ctrDestroyed);
  FProcess.RemoveThread(Thread);
end;

{ TCnOTAThread }

constructor TCnOTAThread.Create(AProcess: TCnOTAProcess; Thread: IOTAThread;
  ADebuggerNotifierServices: TCnWizDebuggerNotifierServices);
begin
  inherited Create;
  FProcess := AProcess;
  FDebuggerNotifierServices := ADebuggerNotifierServices;
  FThread := Thread;
  FThreadNotifier := TCnOTAThreadNotifier.Create(Self);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAThread Created.');
{$ENDIF DEBUG}
end;

destructor TCnOTAThread.Destroy;
begin
  if FThreadNotifierIndex >= 0 then
    FThread.RemoveNotifier(FThreadNotifierIndex);

  FThread := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAThread Destroyed.');
{$ENDIF DEBUG}
  inherited;
end;

{ TCnOTAThreadNotifier }

constructor TCnOTAThreadNotifier.Create(AThread: TCnOTAThread);
begin
  inherited Create;
  FThread := AThread;
  NoRefCount(FThreadIntf) := NoRefCount(AThread.Thread);
  FProcess := AThread.Process;
  NoRefCount(FProcessIntf) := NoRefCount(FProcess.Process);
  FDebuggerNotifierServices := AThread.FDebuggerNotifierServices;
  // ��֤ Notifier �õ�����·ŵĽӿ�ʵ��
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAThreadNotifier Created.');
{$ENDIF DEBUG}
end;

destructor TCnOTAThreadNotifier.Destroy;
begin
  NoRefCount(FThreadIntf) := nil;
  NoRefCount(FProcessIntf) := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnOTAThreadNotifier Destroyed.');
{$ENDIF DEBUG}
  inherited;
end;

procedure TCnOTAThreadNotifier.EvaluateComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress,
  ResultSize: LongWord; ReturnCode: Integer);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('EvaluateExpression Result Returned. %s.', [ExprStr]);
{$ENDIF DEBUG}
  // ��֧�ֶ�����ʽ�����߳̽������
  EvaluateResult.ExprStr := ExprStr;
  EvaluateResult.ResultStr := ResultStr;
  EvaluateResult.CanModify := CanModify;
  EvaluateResult.ResultAddress := ResultAddress;
  EvaluateResult.ResultSize := ResultSize;
  EvaluateResult.ReturnCode := ReturnCode;

  EvaluateResult.EvaluateCompleted := True;
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ResultStr %s, ResAddr %x, ResSize %x, ResVal %x.', [ResultStr, ResultAddress, ResultSize, ReturnCode]);
{$ENDIF DEBUG}
end;

procedure TCnOTAThreadNotifier.ModifyComplete(const ExprStr,
  ResultStr: string; ReturnCode: Integer);
begin

end;

procedure TCnOTAThreadNotifier.ThreadNotify(Reason: TOTANotifyReason);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('Thread Notified. Reason. %d.', [Ord(Reason)]);
{$ENDIF DEBUG}
  FDebuggerNotifierServices.ThreadNotify(FProcessIntf, FThreadIntf, TCnThreadNotifyReason(Ord(Reason)));
end;

{ TCnBreakpointDescriptor }

procedure TCnBreakpointDescriptor.AssignTo(Dest: TPersistent);
begin
  if Dest is TCnBreakpointDescriptor then
  begin
    TCnBreakpointDescriptor(Dest).Enabled := FEnabled;
    TCnBreakpointDescriptor(Dest).FileName := FFileName;
    TCnBreakpointDescriptor(Dest).LineNumber := FLineNumber;
  end;
end;

function TCnBreakpointDescriptor.ToString: string;
begin
  Result := Format('Enabled %d. Line: %d. File: %s', [Integer(FEnabled), FLineNumber, FFileName]);
end;

initialization

finalization
  if FCnWizDebuggerNotifierServices <> nil then
    FreeAndNil(FCnWizDebuggerNotifierServices);

  if CSInited then
    DeleteCriticalSection(CSEvaluate);

end.
