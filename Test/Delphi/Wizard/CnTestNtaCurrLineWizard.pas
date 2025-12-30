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

unit CnTestNtaCurrLineWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试 CnNtaGetCurrLineText 函数的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：测试 CnNtaGetCurrLineText 以查看是否获得了正确的光标
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
// 测试 CnNtaGetCurrLineText 函数的菜单专家
//==============================================================================

{ TCnTestNtaCurrLineWizard }

  TCnTestNtaCurrLineWizard = class(TCnMenuWizard)
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
// 测试 CnNtaGetCurrLineText 函数的菜单专家
//==============================================================================

{ TCnTestNtaCurrLineWizard }

procedure TCnTestNtaCurrLineWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestNtaCurrLineWizard.Execute;
var
  LineNo: Integer;
  CharIndex: Integer;
  LineText: string;
  EditView: IOTAEditView;
  S: string;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView <> nil then
    InfoDlg('View.CursorPos.Col - 1 = ' + IntToStr(EditView.CursorPos.Col - 1));
    
  if (EditView <> nil) and CnNtaGetCurrLineText(LineText, LineNo, CharIndex) and
    (LineText <> '') then
  begin
    S := Format('Get Text at Line %d and CharIndex is %d.', [LineNo, CharIndex]);
    S := S + #13#10#13#10 + '''';
    // Insert('|', LineText, CharIndex);
    // LineText 必须转换成 AnsiString 并做 UTF8 解码（如果UTF8编码过），才能和 CharIndex 对上号
    
    S := S + LineText + '''';
    InfoDlg(S);
  end
  else
  begin
    ErrorDlg('Can NOT NtaGetCurrLineText');
    Exit;
  end;

  if (EditView <> nil) and CnOtaGetCurrPosToken(S, CharIndex) then
    InfoDlg(Format('Current Token Under Cursor is: %s. Offset %d.', [S, CharIndex]))
  else
    ErrorDlg('Can NOT OtaGetCurrPosToken');
end;

function TCnTestNtaCurrLineWizard.GetCaption: string;
begin
  Result := 'Test NtaGetCurrLineText';
end;

function TCnTestNtaCurrLineWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestNtaCurrLineWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestNtaCurrLineWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestNtaCurrLineWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestNtaCurrLineWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test NtaGetCurrLineText Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for NtaGetCurrLineText under All Delphi';
end;

procedure TCnTestNtaCurrLineWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestNtaCurrLineWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestNtaCurrLineWizard); // 注册此测试专家

end.
