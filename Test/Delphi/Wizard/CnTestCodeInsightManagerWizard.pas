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

unit CnTestCodeInsightManagerWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestCodeInsightManagerWizard
* 单元作者：CnPack 开发组
* 备    注：测试通过 IOTACodeInsightServices.AddCodeInsightManager 注册
*           自定义 CodeInsightManager，用于测试 GetCount 等方法
* 开发平台：Windows 10 + Delphi 10.4+
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2026.02.28 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// 测试 CodeInsightManager 注册的菜单专家
//==============================================================================

{ TCnTestCodeInsightManagerWizard }

  TCnTestCodeInsightManagerWizard = class(TCnMenuWizard)
  private
    FCustomIndex: Integer;
    FCustomManager: IOTACodeInsightManager;
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

  // 自定义 CodeInsightManager 实现
  TCnCustomCodeInsightManager = class(TInterfacedObject, IOTACodeInsightManager)
  private
    FEnabled: Boolean;
    FName: string;
    FIDString: string;
    function GetCount: Integer;
  public
    constructor Create;
    
    // IOTACodeInsightManager 接口实现
    function GetEnabled: Boolean;
    procedure SetEnabled(Value: Boolean);
    function GetIDString: string;
    function GetName: string;
    function EditorTokenValidChars(PreValidating: Boolean): TSysCharSet;
    function PreValidateCodeInsight(const Str: string): Boolean;
    function GetLongestItem: string;
    procedure GetParameterList(out ParameterList: IOTACodeInsightParameterList);
    procedure GetSymbolList(out SymbolList: IOTACodeInsightSymbolList);
        function GotoDefinition(out AFileName: string; out ALineNum: Integer; Index: Integer = -1): Boolean;
    function HandlesFile(const AFileName: string): Boolean;
    function InvokeCodeCompletion(HowInvoked: TOTAInvokeType; var Str: string): Boolean;
    function InvokeParameterCodeInsight(HowInvoked: TOTAInvokeType; var SelectedIndex: Integer): Boolean;
    procedure ParameterCodeInsightAnchorPos(var EdPos: TOTAEditPos);

    procedure AllowCodeInsight(var Allow: Boolean; const Key: Char);
    function IsViewerBrowsable(Index: Integer): Boolean;
    function GetMultiSelect: Boolean;
    procedure OnEditorKey(Key: Char; var CloseViewer: Boolean; var Accept: Boolean);
    procedure GetCodeInsightType(AChar: Char; AElement: Integer; out CodeInsightType: TOTACodeInsightType;
      out InvokeType: TOTAInvokeType);
    function ParameterCodeInsightParamIndex(EdPos: TOTAEditPos): Integer;
    function GetHintText(HintLine, HintCol: Integer): string;
    procedure Done(Accepted: Boolean; out DisplayParams: Boolean);
    function GetOptionSetName: string;
    
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property Name: string read GetName;
    property IDString: string read GetIDString;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// TCnCustomCodeInsightManager 实现
//==============================================================================

{ TCnCustomCodeInsightManager }

procedure TCnCustomCodeInsightManager.AllowCodeInsight(var Allow: Boolean;
  const Key: Char);
begin

end;

constructor TCnCustomCodeInsightManager.Create;
begin
  inherited Create;
  FEnabled := True;
  FName := 'CnPack Test CodeInsight Manager';
  FIDString := 'CnPack.TestCodeInsightManager';
  CnDebugger.LogMsg('TCnCustomCodeInsightManager Created');
end;

procedure TCnCustomCodeInsightManager.Done(Accepted: Boolean;
  out DisplayParams: Boolean);
begin

end;

function TCnCustomCodeInsightManager.EditorTokenValidChars(
  PreValidating: Boolean): TSysCharSet;
begin
  Result := ['A'..'Z', 'a'..'z', '0'..'9', '_'];
end;

procedure TCnCustomCodeInsightManager.GetCodeInsightType(AChar: Char;
  AElement: Integer; out CodeInsightType: TOTACodeInsightType;
  out InvokeType: TOTAInvokeType);
begin

end;

function TCnCustomCodeInsightManager.GetCount: Integer;
begin
  // 这是测试的关键方法
  Result := 0;
  CnDebugger.LogMsg('TCnCustomCodeInsightManager.GetCount called, returning 0');
end;

function TCnCustomCodeInsightManager.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TCnCustomCodeInsightManager.GetHintText(HintLine,
  HintCol: Integer): string;
begin

end;

function TCnCustomCodeInsightManager.GetIDString: string;
begin
  Result := FIDString;
end;

function TCnCustomCodeInsightManager.GetLongestItem: string;
begin
  Result := '';
end;

function TCnCustomCodeInsightManager.GetMultiSelect: Boolean;
begin

end;

function TCnCustomCodeInsightManager.GetName: string;
begin
  Result := FName;
end;

function TCnCustomCodeInsightManager.GetOptionSetName: string;
begin

end;

procedure TCnCustomCodeInsightManager.GetParameterList(
  out ParameterList: IOTACodeInsightParameterList);
begin
  // 不实现具体功能
  ParameterList := nil;
end;

procedure TCnCustomCodeInsightManager.GetSymbolList(
  out SymbolList: IOTACodeInsightSymbolList);
begin
  // 不实现具体功能
  SymbolList := nil;
end;

function TCnCustomCodeInsightManager.GotoDefinition(out AFileName: string;
  out ALineNum: Integer; Index: Integer): Boolean;
begin
  Result := False;
end;

function TCnCustomCodeInsightManager.HandlesFile(
  const AFileName: string): Boolean;
begin
  // 只处理 .pas 文件
  Result := SameText(ExtractFileExt(AFileName), '.pas');
end;

function TCnCustomCodeInsightManager.InvokeCodeCompletion(
  HowInvoked: TOTAInvokeType; var Str: string): Boolean;
begin
  // 不实现具体功能
end;

function TCnCustomCodeInsightManager.InvokeParameterCodeInsight(
  HowInvoked: TOTAInvokeType; var SelectedIndex: Integer): Boolean;
begin
  // 不实现具体功能
end;

function TCnCustomCodeInsightManager.IsViewerBrowsable(Index: Integer): Boolean;
begin

end;

procedure TCnCustomCodeInsightManager.OnEditorKey(Key: Char; var CloseViewer,
  Accept: Boolean);
begin

end;

procedure TCnCustomCodeInsightManager.ParameterCodeInsightAnchorPos(
  var EdPos: TOTAEditPos);
begin
  // 不实现具体功能
end;

function TCnCustomCodeInsightManager.ParameterCodeInsightParamIndex(
  EdPos: TOTAEditPos): Integer;
begin

end;

function TCnCustomCodeInsightManager.PreValidateCodeInsight(
  const Str: string): Boolean;
begin

end;

procedure TCnCustomCodeInsightManager.SetEnabled(Value: Boolean);
begin
  FEnabled := Value;
end;

//==============================================================================
// TCnTestCodeInsightManagerWizard 实现
//==============================================================================

{ TCnTestCodeInsightManagerWizard }

constructor TCnTestCodeInsightManagerWizard.Create;
begin
  inherited;
  FCustomManager := nil;
  FCustomIndex := -1;
end;

destructor TCnTestCodeInsightManagerWizard.Destroy;
var
  CIS: IOTACodeInsightServices;
begin
  // 清理：移除注册的 CodeInsightManager
  if (FCustomManager <> nil) and (FCustomIndex >= 0) then
  begin
    if Supports(BorlandIDEServices, IOTACodeInsightServices, CIS) then
    begin
      try
        CIS.RemoveCodeInsightManager(FCustomIndex);
        CnDebugger.LogMsg('Custom CodeInsightManager removed');
      except
        on E: Exception do
          CnDebugger.LogMsg('Error removing CodeInsightManager: ' + E.Message);
      end;
    end;
    FCustomManager := nil;
  end;
  
  inherited;
end;

procedure TCnTestCodeInsightManagerWizard.Config;
begin
  ShowMessage('本测试用例无配置选项。');
end;

procedure TCnTestCodeInsightManagerWizard.Execute;
var
  CIS: IOTACodeInsightServices;
  I, Count: Integer;
  CIM: IOTACodeInsightManager;
  CIM90: IOTACodeInsightManager90;
  Msg: string;
begin
  if not Supports(BorlandIDEServices, IOTACodeInsightServices, CIS) then
  begin
    ShowMessage('IOTACodeInsightServices 不可用');
    Exit;
  end;

  // 如果还没有注册，则注册自定义 CodeInsightManager
  if FCustomManager = nil then
  begin
    FCustomManager := TCnCustomCodeInsightManager.Create;
    FCustomIndex := CIS.AddCodeInsightManager(FCustomManager);
    CnDebugger.LogMsg('Custom CodeInsightManager registered at ' + IntToStr(FCustomIndex));
    ShowMessage('已注册自定义 CodeInsightManager: ' + FCustomManager.Name);
  end
  else
  begin
    ShowMessage('自定义 CodeInsightManager 已经注册');
  end;

  // 列出所有 CodeInsightManager 并测试 GetCount
  Msg := Format('当前共有 %d 个 CodeInsightManager：'#13#10#13#10, 
    [CIS.CodeInsightManagerCount]);

  for I := 0 to CIS.CodeInsightManagerCount - 1 do
  begin
    CIM := CIS.CodeInsightManager[I];
    Msg := Msg + CIM.GetIDString + #13#10;
  end;

  ShowMessage(Msg);
end;

function TCnTestCodeInsightManagerWizard.GetCaption: string;
begin
  Result := 'Test CodeInsightManager Registration';
end;

function TCnTestCodeInsightManagerWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestCodeInsightManagerWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestCodeInsightManagerWizard.GetHint: string;
begin
  Result := '测试 CodeInsightManager 注册和 GetCount 方法';
end;

function TCnTestCodeInsightManagerWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestCodeInsightManagerWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := 'Test CodeInsightManager Registration Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Test registering custom CodeInsightManager and calling GetCount';
end;

procedure TCnTestCodeInsightManagerWizard.LoadSettings(Ini: TCustomIniFile);
begin
  // 无需保存设置
end;

procedure TCnTestCodeInsightManagerWizard.SaveSettings(Ini: TCustomIniFile);
begin
  // 无需保存设置
end;

initialization
  RegisterCnWizard(TCnTestCodeInsightManagerWizard); // 注册此测试专家

end.
