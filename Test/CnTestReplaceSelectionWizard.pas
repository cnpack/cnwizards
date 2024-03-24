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

unit CnTestReplaceSelectionWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试用指定内容替换编辑器的选择区的相关接口的菜单专家
* 单元作者：CnPack 开发组
* 备    注：该单元应该在所有 Delphi 版本上运行像话
            只需将此单元加入专家包源码工程后重编译加载即可进行测试，
* 开发平台：PWinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2015.09.04 V1.0
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
// 测试用指定内容替换编辑器的选择区的相关接口的菜单专家
//==============================================================================

{ TCnTestReplaceSelectionWizard }

  TCnTestReplaceSelectionWizard = class(TCnMenuWizard)
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

const
  Content: string =
    'EditView := CnOtaGetTopMostEditView;' + #13#10 +
    'if not Assigned(EditView) then' + #13#10 +
      'Exit;' + #13#10 +
      '' + #13#10 +
    'EditBlock := EditView.Block;' + #13#10 + 
    'if Assigned(EditBlock) then' + #13#10 + 
      'EditBlock.Delete;';

//==============================================================================
// 测试用指定内容替换编辑器的选择区的相关接口的菜单专家
//==============================================================================

{ TCnTestReplaceSelectionWizard }

procedure TCnTestReplaceSelectionWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestReplaceSelectionWizard.Execute;
var
  Res: string;
begin
  Res := Content;
  Application.MessageBox(PChar(Res), 'Will Replace Current Selection with Below:',
    MB_OK + MB_ICONINFORMATION);

{$IFDEF IDE_STRING_ANSI_UTF8}
  CnOtaReplaceCurrentSelectionUtf8(Res, True, True, True);
{$ELSE}
  // Ansi/Unicode 均可用
  CnOtaReplaceCurrentSelection(Res, True, True, True);
{$ENDIF}
end;

function TCnTestReplaceSelectionWizard.GetCaption: string;
begin
  Result := 'Test Replace Current Selection';
end;

function TCnTestReplaceSelectionWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestReplaceSelectionWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestReplaceSelectionWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestReplaceSelectionWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestReplaceSelectionWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := 'Test Replace Current Selection Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Replace Current Selection under All Delphi.';
end;

procedure TCnTestReplaceSelectionWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestReplaceSelectionWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestReplaceSelectionWizard); // 注册此测试专家

end.
