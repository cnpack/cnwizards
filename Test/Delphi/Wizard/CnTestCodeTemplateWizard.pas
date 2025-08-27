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

unit CnTestCodeTemplateWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestCodeTemplateWizard
* 单元作者：CnPack 开发组
* 备    注：测试 2006 以上提供的 CodeTemplateAPI.pas 接口
* 开发平台：Windows 7 + Delphi 5
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2016.04.24 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFNDEF OTA_CODE_TEMPLATE_API}
  {$MESSAGE ERROR 'CodeTemplateAPI NOT Supported.'}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CodeTemplateAPI, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// CnTestCodeTemplateWizard 菜单专家
//==============================================================================

{ TCnTestCodeTemplateWizard }

  TCnTestCodeTemplateWizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
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

//==============================================================================
// CnTestCodeTemplateWizard 菜单专家
//==============================================================================

{ TCnTestCodeTemplateWizard }

procedure TCnTestCodeTemplateWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestCodeTemplateWizard.Execute;
var
  I: Integer;
  View: IOTAEditView;
  CT: IOTACodeTemplate;
  CTS: IOTACodeTemplateServices;

  procedure DumpCodeTemplate(Idx: Integer);
  begin
    CnDebugger.LogEnter('DumpCodeTemplate: ' + IntToStr(Idx));
    with CT do
    begin
      CnDebugger.LogFmt('ScriptCount %d', [ScriptCount]);
      CnDebugger.LogFmt('Format %s', [Format]);
      CnDebugger.LogFmt('Title %s', [Title]);
      CnDebugger.LogFmt('HelpUrl %s', [HelpUrl]);
      CnDebugger.LogFmt('Delimiter %s', [Delimiter]);
      CnDebugger.LogFmt('Kind %d', [Ord(Kind)]);
      CnDebugger.LogFmt('Language %s', [Language]);
      CnDebugger.LogFmt('EditorOpts %s', [EditorOpts]);
      CnDebugger.LogFmt('Code %s', [Code]);
      CnDebugger.LogFmt('Description %s', [Description]);
      CnDebugger.LogFmt('ReferencesCount %d', [ReferencesCount]);
      CnDebugger.LogFmt('NamespaceCount %d', [NamespaceCount]);
      CnDebugger.LogFmt('Author %s', [Author]);
      CnDebugger.LogFmt('PointsCount %d', [PointsCount]);
      CnDebugger.LogFmt('KeywordsCount %d', [KeywordsCount]);
      CnDebugger.LogFmt('Shortcut %s', [Shortcut]);
      CnDebugger.LogFmt('InvokeKind %d', [Ord(InvokeKind)]);
      CnDebugger.LogFmt('FileName %s', [FileName]);
    end;
    CnDebugger.LogLeave('DumpCodeTemplate: ' + IntToStr(Idx));
  end;

begin
  // CTS := BorlandIDEServices as IOTACodeTemplateServices;
  if not Supports(BorlandIDEServices, IOTACodeTemplateServices, CTS) then
    Exit;

  if CTS = nil then
  begin
    ShowMessage('No IOTACodeTemplateServices');
    Exit;
  end;

  ShowMessage(IntToStr(CTS.CodeObjectCount));
  for I := 0 to CTS.CodeObjectCount - 1 do
  begin
    CT := CTS.CodeObjects[I];
    DumpCodeTemplate(I);
  end;

  View := CnOtaGetTopMostEditView;
  if (View <> nil) and (CTS.CodeObjectCount > 0) then
    CTS.InsertCode(0, View, False);
end;

function TCnTestCodeTemplateWizard.GetCaption: string;
begin
  Result := 'Test CodeTempalteAPI';
end;

function TCnTestCodeTemplateWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestCodeTemplateWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestCodeTemplateWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestCodeTemplateWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestCodeTemplateWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test CodeTempalteAPI';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Test CodeTempalteAPI under 2006 and Above.';
end;

procedure TCnTestCodeTemplateWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestCodeTemplateWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestCodeTemplateWizard); // 注册此测试专家

end.
