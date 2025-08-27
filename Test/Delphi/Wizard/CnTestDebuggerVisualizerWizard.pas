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

unit CnTestDebuggerVisualizerWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����� DebuggerVisualizer �Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ DebuggerVisualizer �Ը��ĵ���������ʾ����
            ���ڴ���λ�����������֣���Ҫ�� D5/2007/2009 �Ȳ���ͨ����
* ����ƽ̨��Win7 + Delphi XE2
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi All
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2022.06.24 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts,
  CnDataSetVisualizer;

type

//==============================================================================
// ���� DebuggerVisualizer �Ĳ˵�ר��
//==============================================================================

{ TCnTestDebuggerVisualizerWizard }

  TCnTestDebuggerVisualizerWizard = class(TCnMenuWizard)
  private
    FRegistered: Boolean;
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
    FVisualizer: IOTADebuggerVisualizerValueReplacer;
{$ENDIF}
  protected
    function GetHasConfig: Boolean; override;
  public
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

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

  TCnTestDebuggerVisualizerValueReplacer = class(TInterfacedObject,
    IOTAThreadNotifier, IOTADebuggerVisualizerValueReplacer)
  private
    FRes: array[0..1023] of Char;
    FNotifierIndex: Integer;
    FEvalComplete: Boolean;
    FEvalSuccess: Boolean;
    FCanModify: Boolean;
    FEvalResult: string;
  public
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;

    procedure ThreadNotify(Reason: TOTANotifyReason);
    procedure EvaluteComplete(const ExprStr, ResultStr: string; CanModify: Boolean;
      ResultAddress, ResultSize: LongWord; ReturnCode: Integer);
     procedure ModifyComplete(const ExprStr, ResultStr: string; ReturnCode: Integer);

    function GetSupportedTypeCount: Integer;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean);
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;

    function GetReplacementValue(const Expression, TypeName, EvalResult: string): string;
  end;

{$ENDIF}

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

type
  TCnVisualClasses = (vcBigNumber, vcBigNumberPolynomial, vcBigNumberRationalPolynomial,
    vcEccPoint, vcEcc3Point, vcInt128, vcUInt128);

const
  SCnVisualClasses: array[Low(TCnVisualClasses)..High(TCnVisualClasses)] of string =
    ('TCnBigNumber', 'TCnBigNumberPolynomial', 'TCnBigNumberRationalPolynomial',
     'TCnEccPoint', 'TCnEcc3Point', 'TCnInt128', 'TCnUInt128');

//==============================================================================
// ���� DebuggerVisualizer �Ĳ˵�ר��
//==============================================================================

{ TCnTestDebuggerVisualizerWizard }

procedure TCnTestDebuggerVisualizerWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

destructor TCnTestDebuggerVisualizerWizard.Destroy;
var
  ID: IOTADebuggerServices;
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  if FRegistered and (FVisualizer <> nil) then
  begin
    if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
      Exit;
    ID.UnregisterDebugVisualizer(FVisualizer);
    FVisualizer := nil;
  end;
{$ENDIF}
  inherited;
end;

procedure TCnTestDebuggerVisualizerWizard.Execute;
var
  ID: IOTADebuggerServices;
begin
{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}
  if not Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    Exit;

  if FVisualizer = nil then
    FVisualizer := TCnTestDebuggerVisualizerValueReplacer.Create;

  if not FRegistered then
  begin
    ID.RegisterDebugVisualizer(FVisualizer);
    FRegistered := True;
    ShowMessage('Debugger Visualizer Registered');
  end
  else
  begin
    ID.UnregisterDebugVisualizer(FVisualizer);
    FRegistered := False;
    ShowMessage('Debugger Visualizer UnRegistered');
  end;
{$ENDIF}

  ShowDataSetExternalViewer('ADOTable1');
end;

function TCnTestDebuggerVisualizerWizard.GetCaption: string;
begin
  Result := 'Test DebuggerVisualizer';
end;

function TCnTestDebuggerVisualizerWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestDebuggerVisualizerWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestDebuggerVisualizerWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestDebuggerVisualizerWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestDebuggerVisualizerWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test DebuggerVisualizer Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for DebuggerVisualizer under Delphi XE or above';
end;

procedure TCnTestDebuggerVisualizerWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestDebuggerVisualizerWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

{$IFDEF IDE_HAS_DEBUGGERVISUALIZER}

{ TCnTestDebuggerVisualizerValueReplacer }

procedure TCnTestDebuggerVisualizerValueReplacer.AfterSave;
begin

end;

procedure TCnTestDebuggerVisualizerValueReplacer.BeforeSave;
begin

end;

procedure TCnTestDebuggerVisualizerValueReplacer.Destroyed;
begin

end;

procedure TCnTestDebuggerVisualizerValueReplacer.EvaluteComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress, ResultSize: LongWord;
  ReturnCode: Integer);
begin
  // Defer �Ľ�� Evaluate ��ϣ���� ReturnCode ������ 0��ResultStr ������ǳ�����Ϣ
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DebuggerVisualizerValueReplacer EvaluteComplete for %s: %d, %s',
    [ExprStr, ReturnCode, ResultStr]);
{$ENDIF}

  FEvalSuccess := ReturnCode = 0;

  if FEvalSuccess then
  begin
    FEvalResult := AnsiDequotedStr(ResultStr, '''');
  end
  else
    FEvalResult := '';

  FEvalComplete := True;
end;

function TCnTestDebuggerVisualizerValueReplacer.GetReplacementValue(
  const Expression, TypeName, EvalResult: string): string;
var
  ID: IOTADebuggerServices;
  CP: IOTAProcess;
  CT: IOTAThread;
  NewExpr: string;
  EvalRes: TOTAEvaluateResult;
  ResultAddr: TOTAAddress;
  ResultSize, ResultVal: Cardinal;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DebuggerVisualizerValueReplacer get %s: %s, Display %s',
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

  if TypeName = SCnVisualClasses[vcBigNumber] then
  begin
    NewExpr := Expression + '.ToHex';
  end
  else if TypeName = SCnVisualClasses[vcBigNumberPolynomial] then
  begin
    NewExpr := Expression + '.ToString';
  end
  else if TypeName = SCnVisualClasses[vcBigNumberRationalPolynomial] then
  begin
    NewExpr := Expression + '.ToString';
  end
  else if TypeName = SCnVisualClasses[vcEccPoint] then
  begin
    NewExpr := Expression + '.ToString';
  end
  else if TypeName = SCnVisualClasses[vcEcc3Point] then
  begin
    NewExpr := Expression + '.ToString';
  end
  else if TypeName = SCnVisualClasses[vcInt128] then
  begin
    NewExpr := 'Int128ToStr(' + Expression + ')';
  end
  else if TypeName = SCnVisualClasses[vcUInt128] then
  begin
    NewExpr := 'UInt128ToStr(' + Expression + ')';
  end;

  EvalRes := CT.Evaluate(NewExpr, @FRes[0], SizeOf(FRes), FCanModify, True,
    '', ResultAddr, ResultSize, ResultVal);

  case EvalRes of
{$IFDEF DEBUG}
    erError: CnDebugger.LogMsg('Evaluate Error');
    erBusy: CnDebugger.LogMsg('Evaluate Busy');
{$ENDIF}
    erOK: Result := EvalResult + ': ' + FRes;
    erDeferred:
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Evaluate Deferred. Wait for Events.');
{$ENDIF}
        FEvalComplete := False;
        FEvalSuccess := False;
        FEvalResult := '';

        FNotifierIndex := CT.AddNotifier(Self);
        while not FEvalComplete do
          ID.ProcessDebugEvents;
        CT.RemoveNotifier(FNotifierIndex);

        if FEvalSuccess then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('Evaluate Deferred Success.');
{$ENDIF}
          Result := EvalResult + ': ' + FEvalResult;
        end;
      end;
  end;
end;

procedure TCnTestDebuggerVisualizerValueReplacer.GetSupportedType(
  Index: Integer; var TypeName: string; var AllDescendants: Boolean);
begin
  AllDescendants := False;
  TypeName := SCnVisualClasses[TCnVisualClasses(Index)];
end;

function TCnTestDebuggerVisualizerValueReplacer.GetSupportedTypeCount: Integer;
begin
  Result := 1 + Ord(High(TCnVisualClasses)) - Ord(Low(TCnVisualClasses));
end;

function TCnTestDebuggerVisualizerValueReplacer.GetVisualizerDescription: string;
begin
  Result := 'CnPack CnVcl Debugger Visualizer for some Types.'
end;

function TCnTestDebuggerVisualizerValueReplacer.GetVisualizerIdentifier: string;
begin
  Result := 'CnVclVisualizer';
end;

function TCnTestDebuggerVisualizerValueReplacer.GetVisualizerName: string;
begin
  Result := 'CnPack CnVcl Visualizer'
end;

procedure TCnTestDebuggerVisualizerValueReplacer.Modified;
begin

end;

procedure TCnTestDebuggerVisualizerValueReplacer.ModifyComplete(const ExprStr,
  ResultStr: string; ReturnCode: Integer);
begin

end;

procedure TCnTestDebuggerVisualizerValueReplacer.ThreadNotify(
  Reason: TOTANotifyReason);
begin

end;

{$ENDIF}

initialization
  RegisterCnWizard(TCnTestDebuggerVisualizerWizard); // ע��˲���ר��

end.
