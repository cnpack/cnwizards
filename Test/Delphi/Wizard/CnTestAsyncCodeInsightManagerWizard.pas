{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnTestAsyncCodeInsightManagerWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestAsyncCodeInsightManagerWizard
* 单元作者：CnPack 开发组
* 备    注：只支持 D10.4 或以上版本，测试异步 CodeInsightManager 用
* 开发平台：Windows 10 + Delphi 10.4
* 兼容测试：
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2020.05.30 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizCompilerConst;

type

//==============================================================================
// CnTestAsyncCodeInsightManagerWizard 菜单专家
//==============================================================================

{ TCnTestAsyncCodeInsightManagerWizard }

  TCnTestAsyncCodeInsightManagerWizard = class(TCnMenuWizard)
  private
    FLSPH: THandle;
    FAsyncManager: TObject;
    FManager: TObject;
    procedure AsyncCodeCompletionCallBack(Sender: TObject; AId: Integer;
      AError: Boolean; const AMessage: string);
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

implementation

uses
  CnDebug;

const
  SLspGetSymbolList = '@Lspcodcmplt@TLSPKibitzManager@GetSymbolList$qqrr61System@%DelphiInterface$34Toolsapi@IOTACodeInsightSymbolList%';

type
  TLSPKibitzManagerGetSymbolList = procedure (ASelf: TObject; var SymbolList: IOTACodeInsightSymbolList);

var
  LspGetSymbolList: TLSPKibitzManagerGetSymbolList = nil;

//==============================================================================
// CnTestAsyncCodeInsightManagerWizard 菜单专家
//==============================================================================

{ TCnTestAsyncCodeInsightManagerWizard }

procedure TCnTestAsyncCodeInsightManagerWizard.AsyncCodeCompletionCallBack(
  Sender: TObject; AId: Integer; AError: Boolean; const AMessage: string);
var
  I: Integer;
  SymbolList: IOTACodeInsightSymbolList;
  SL80: IOTACodeInsightSymbolList80;
  CIPL: IOTACodeInsightParameterList;
  Mgr: IOTACodeInsightManager;
begin
  CnDebugger.TraceCurrentStack;

  if (FManager <> nil) and Supports(FManager, IOTACodeInsightManager, Mgr) then
  begin
    Mgr.GetParameterList(CIPL); // 还是返回 0
    CnDebugger.LogMsg('Call back GetParameterList Returns Proc Count ' + IntToStr(CIPL.GetProcedureCount));

  end;

  if (FAsyncManager <> nil) and Assigned(LspGetSymbolList) then
  begin
    LspGetSymbolList(FAsyncManager, SymbolList);
    // Get some Count in Async call back
    CnDebugger.LogMsg('Call back LspGetSymbolList Returns Count ' + IntToStr(SymbolList.Count));

    for I := 0 to SymbolList.Count - 1  do
    begin
      CnDebugger.LogFmt('#%d: %s - %s : %s | Flag %d', [I, SymbolList.SymbolText[I],
        SymbolList.SymbolTypeText[I], SymbolList.SymbolClassText[I],
        Integer(SymbolList.SymbolFlags[I])]);
    end;

    if Supports(SymbolList, IOTACodeInsightSymbolList80, SL80) then
    begin
      CnDebugger.LogSeparator;
      for I := 0 to SL80.Count - 1 do
        CnDebugger.LogFmt('#%d: Documentation: %s', [I, SL80.SymbolDocumentation[I]]);
    end
    else
      CnDebugger.LogMsg('NOT 80'); // 会到这里
  end;

  ShowMessage(Format('CallBack AId: %d. Error %d. Message %s',
    [AId, Integer(AError), AMessage]));
end;

procedure TCnTestAsyncCodeInsightManagerWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

constructor TCnTestAsyncCodeInsightManagerWizard.Create;
begin
  inherited;
  FLSPH := GetModuleHandle(IdeLspLibName);
  if FLSPH <> 0 then
    LspGetSymbolList := TLSPKibitzManagerGetSymbolList(GetProcAddress(FLSPH, SLspGetSymbolList));
end;

destructor TCnTestAsyncCodeInsightManagerWizard.Destroy;
begin

  inherited;
end;

procedure TCnTestAsyncCodeInsightManagerWizard.Execute;
var
  I: Integer;
  Str: string;
  Allow: Boolean;
  View: IOTAEditView;
  CIS: IOTACodeInsightServices;
  CIM: IOTACodeInsightManager;
  ACIM: IOTAAsyncCodeInsightManager;
  SymbolList: IOTACodeInsightSymbolList;
  CIPL: IOTACodeInsightParameterList;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  CIS := (BorlandIDEServices as IOTACodeInsightServices);
  for I := 0 to CIS.CodeInsightManagerCount - 1 do
  begin
    CIM := CIS.CodeInsightManager[I];
    if CIM = nil then
      Continue;

    CnDebugger.LogFmt('CodeInsightManager: %d. Enabled: %d - %s - %s',
      [I, Integer(CIM.Enabled), CIM.GetIDString, CIM.Name]);

    if not CIM.Enabled then
      Continue;

    if not CIM.HandlesFile(View.Buffer.FileName) then       // 不能处理当前文件
    begin
      CnDebugger.LogFmt('CodeInsightManager %d - %s Can NOT Handle - %s',
        [I, CIM.GetIDString, View.Buffer.FileName]);

      Continue;
    end;

    CIS.SetQueryContext(View, CIM);
    FManager := CIM as TObject;

    if Supports(CIM, IOTAAsyncCodeInsightManager, ACIM) then
    begin
      CnDebugger.LogFmt('CodeInsightManager: %d Is Async.', [I]);

      // 调用异步方法
      ACIM.AsyncAllowCodeInsight(Allow, #0);
      if not Allow then
      begin
        ShowMessage('NOT Allow.');
        Continue;
      end;

      if not ACIM.AsyncCanInvoke(citCodeInsight) then
      begin
        ShowMessage('Can NOT Invoke');
        Continue;
      end;

      // CnDebugger.LogInterface(ACIM);
      Str := '';
      ACIM.AsyncInvokeCodeCompletion(itManual, Str, View.CursorPos.Line,
        View.CursorPos.Col, AsyncCodeCompletionCallBack);
      CnDebugger.LogMsg('AsyncInvokeCodeCompletion Called.');

      FAsyncManager := ACIM as TObject;
      if (FAsyncManager <> nil) and Assigned(LspGetSymbolList) then
      begin
        LspGetSymbolList(FAsyncManager, SymbolList);
        // Get 0 Count for Async
        CnDebugger.LogMsg('Call LspGetSymbolList Returns Count ' + IntToStr(SymbolList.Count));

        CIM.GetParameterList(CIPL); // 返回 0
        CnDebugger.LogMsg('Call GetParameterList Returns Proc Count ' + IntToStr(CIPL.ProcedureCount));
      end;
    end;

    CIS.SetQueryContext(nil, nil);
  end;
end;

function TCnTestAsyncCodeInsightManagerWizard.GetCaption: string;
begin
  Result := 'Test Async CodeInsightManager';
end;

function TCnTestAsyncCodeInsightManagerWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestAsyncCodeInsightManagerWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestAsyncCodeInsightManagerWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestAsyncCodeInsightManagerWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestAsyncCodeInsightManagerWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Async CodeInsightManager Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Async CodeInsightManager for LSP';
end;

procedure TCnTestAsyncCodeInsightManagerWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestAsyncCodeInsightManagerWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestAsyncCodeInsightManagerWizard); // 注册此测试专家

end.
