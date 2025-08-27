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

unit CnTestCurTokenWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试光标下当前标识符函数的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：测试 CnOtaGetCurPosToken/W 以查看是否获得了正确的光标
            所在处的位置类型与文字，需要在 D5/2007/2009 等测试通过。
* 开发平台：WinXP + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi All
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2015.03.05 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// 测试 CnOtaGetCurrPosTokenW 函数的菜单专家
//==============================================================================

{ TCnTestCurTokenWizard }

  TCnTestCurTokenWizard = class(TCnMenuWizard)
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
// 测试 CnOtaGetCurrPosTokenW 函数的菜单专家
//==============================================================================

{ TCnTestCurTokenWizard }

procedure TCnTestCurTokenWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestCurTokenWizard.Execute;
var
  Idx: Integer;
{$IFDEF IDE_STRING_ANSI_UTF8}
  W: WideString;
{$ENDIF}
  S: string;
  Res: Boolean;
begin
{$IFDEF UNICODE}
  Res := CnOtaGetCurrPosTokenW(S, Idx, True, [], [], nil, True);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  Res := CnOtaGetCurrPosTokenUtf8(W, Idx, True, [], [], nil, True);
  S := W;
  {$ELSE}
  Res := CnOtaGetCurrPosToken(S, Idx, True, [], [], nil, True);
  {$ENDIF}
{$ENDIF}

  if not Res then
    InfoDlg('No Token under Cursor.')
  else
  begin
    InfoDlg(S);
    InfoDlg(IntToStr(Idx));
  end;
end;

function TCnTestCurTokenWizard.GetCaption: string;
begin
  Result := 'Test CnOtaGetCurrPosToken/Utf8/W';
end;

function TCnTestCurTokenWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestCurTokenWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestCurTokenWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestCurTokenWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestCurTokenWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test NtaGetCurrLineText Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for CnOtaGetCurrPosToken/W under All Delphi';
end;

procedure TCnTestCurTokenWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestCurTokenWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestCurTokenWizard); // 注册此测试专家

end.
