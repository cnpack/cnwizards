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

unit CnTestOutOfLineEndWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestOutOfLineEndWizard
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：Windows 7 + Delphi 5
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2016.04.24 V1.0
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
// CnTestOutOfLineEndWizard 菜单专家
//==============================================================================

{ TCnTestOutOfLineEndWizard }

  TCnTestOutOfLineEndWizard = class(TCnMenuWizard)
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

//==============================================================================
// CnTestOutOfLineEndWizard 菜单专家
//==============================================================================

{ TCnTestOutOfLineEndWizard }

procedure TCnTestOutOfLineEndWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestOutOfLineEndWizard.Execute;
var
  View: IOTAEditView;
  Text, S: string;
  OutOf: Boolean;
  EdPos: TOTAEditPos;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  EdPos := View.CursorPos;
  OutOf := CnOtaIsEditPosOutOfLine(EdPos, View);
  Text := CnOtaGetLineText(EdPos.Line);

  if OutOf then
    S := Format('Out! Line %d Col %d Text:'#13#10#13#10, [EdPos.Line, EdPos.Col]) + Text
  else
    S := Format('No! Line %d Col %d Text:'#13#10#13#10, [EdPos.Line, EdPos.Col]) + Text;

  S := S + #13#10#13#10 + 'Text Length is ' + IntToStr(Length(AnsiString(Text)));
  ShowMessage(S);
end;

function TCnTestOutOfLineEndWizard.GetCaption: string;
begin
  Result := 'Test Out of Line End';
end;

function TCnTestOutOfLineEndWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestOutOfLineEndWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestOutOfLineEndWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestOutOfLineEndWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestOutOfLineEndWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Out of Line End Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Out of Line End';
end;

procedure TCnTestOutOfLineEndWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestOutOfLineEndWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestOutOfLineEndWizard); // 注册此测试专家

end.
