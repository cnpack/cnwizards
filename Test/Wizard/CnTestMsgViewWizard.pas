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

unit CnTestMsgViewWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnMessageViewWrapper 封装测试用例单元
* 单元作者：CnPack 开发组
* 备    注：该单元对 CnWizIdeUtils 单元中 CnMessageViewWrapper 封装的信息窗口内容
            进行测试，只需将此单元加入专家包源码工程后重编译加载即可进行测试，
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2002.11.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizIdeUtils;

type

//==============================================================================
// 测试 CnMessageViewWrapper 菜单专家
//==============================================================================

{ TCnTestMessageViewMenuWizard }

  TCnTestMessageViewMenuWizard = class(TCnMenuWizard)
  private
    procedure ShowAndLog(const Msg: string);
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
// 测试 CnMessageViewWrapper 菜单专家
//==============================================================================

{ TCnTestMessageViewMenuWizard }

procedure TCnTestMessageViewMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestMessageViewMenuWizard.Execute;
begin
  if CnMessageViewWrapper.MessageViewForm <> nil then
  begin
    ShowAndLog('MessageView Got. Show It');
    CnOtaMakeSourceVisible(CnOtaGetCurrentSourceFile());

    CnMessageViewWrapper.MessageViewForm.Show;

    if CnMessageViewWrapper.TabSet <> nil then
    begin
      ShowAndLog(Format('TabSet Got. Visible %d.', [Integer(CnMessageViewWrapper.TabSetVisible)]));
      ShowAndLog(Format('%d of %d Tabs Selected: %s',
        [CnMessageViewWrapper.TabIndex,
         CnMessageViewWrapper.TabCount,
         CnMessageViewWrapper.TabCaption]));
    end;

    if CnMessageViewWrapper.TreeView <> nil then
    begin
      ShowAndLog('TreeView Got.');
{$IFDEF BDS}
      ShowAndLog('BDS: Can NOT got message from Virtual TreeView.');
{$ELSE}
      ShowAndLog(Format('MessageCount: %d. Number %d Selected:  %s',
        [CnMessageViewWrapper.MessageCount,
         CnMessageViewWrapper.SelectedIndex,
         CnMessageViewWrapper.CurrentMessage]));
{$ENDIF}
    end;

{$IFNDEF BDS}
    if CnMessageViewWrapper.SelectedIndex < CnMessageViewWrapper.MessageCount then
    begin
      ShowAndLog('To Select Message Next to ' + IntToStr(CnMessageViewWrapper.SelectedIndex));
      CnMessageViewWrapper.SelectedIndex := CnMessageViewWrapper.SelectedIndex + 1;
    end;
{$ENDIF}
    CnMessageViewWrapper.EditMessageSource;
    ShowAndLog('EditSource Called. Jump to Line if Possible.');
  end;
end;

function TCnTestMessageViewMenuWizard.GetCaption: string;
begin
  Result := 'Test MessageViewWrapper';
end;

function TCnTestMessageViewMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestMessageViewMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestMessageViewMenuWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestMessageViewMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestMessageViewMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test MessageViewWrapper Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for MessageViewWrapper';
end;

procedure TCnTestMessageViewMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestMessageViewMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestMessageViewMenuWizard.ShowAndLog(const Msg: string);
begin
  ShowMessage(Msg);
  CnDebugger.TraceMsg(Msg);
end;

initialization
  RegisterCnWizard(TCnTestMessageViewMenuWizard); // 注册此测试专家

end.
