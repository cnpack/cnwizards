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

unit CnIdeBRWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在 IDE 中运行 IDE 辅助备份/恢复工具
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2006.08.23 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNIDEBRWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles,
  CnWizClasses, CnWizUtils, CnWizConsts, CnConsts, CnWizOptions;

type

{ TCnIdeBRWizard }

  TCnIdeBRWizard = class(TCnMenuWizard)
  private
  
  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNIDEBRWIZARD}

implementation

{$IFDEF CNWIZARDS_CNIDEBRWIZARD}

uses
  CnCommon;

{ TCnIdeBRWizard }

procedure TCnIdeBRWizard.Execute;
var
  FileName, Param: string;
begin
  FileName := WizOptions.DllPath + SCnIdeBRToolName;
  if FileExists(FileName) then
  begin
    Param := '';
{$IFDEF DELPHI5}
    Param := '-IDelphi5';
{$ELSE}
  {$IFDEF DELPHI6}
    Param := '-IDelphi6';
  {$ELSE}
    {$IFDEF DELPHI7}
    Param := '-IDelphi7';
    {$ELSE}
      {$IFDEF DELPHI8}
    Param := '-IDelphi8';
      {$ELSE}
        {$IFDEF DELPHI9}
    Param := '-IBDS2005';
        {$ELSE}
          {$IFDEF DELPHI10}
    Param := '-IBDS2006';
          {$ELSE}
            {$IFDEF DELPHI11}
    Param := '-IRADStudio2007';
            {$ELSE}
              {$IFDEF BCB5}
    Param := '-IBCB5';
              {$ELSE}
                {$IFDEF BCB6}
    Param := '-IBCB6';
                {$ENDIF}
              {$ENDIF}
            {$ENDIF}
          {$ENDIF}
        {$ENDIF}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
    RunFile(FileName, 0, Param);
  end
  else
    ErrorDlg(SCnIdeBRToolNotExists);
end;

function TCnIdeBRWizard.GetCaption: string;
begin
  Result := SCnIdeBRWizardMenuCaption;
end;

function TCnIdeBRWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnIdeBRWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnIdeBRWizard.GetHint: string;
begin
  Result := SCnDfm6To5WizardMenuHint;
end;

function TCnIdeBRWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnIdeBRWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnIdeBRWizardName;
  Author := SCnPack_ccRun + ';' + SCnPack_LiuXiao;
  Email := SCnPack_ccRunEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnIdeBRWizardComment;
end;

initialization
  RegisterCnWizard(TCnIdeBRWizard); // 注册专家

{$ENDIF CNWIZARDS_CNIDEBRWIZARD}
end.
