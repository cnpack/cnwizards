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

unit CnSourceDiffWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：源代码比较专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2003.03.11 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEDIFFWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnConsts,
  CnSourceDiffFrm;

type

//==============================================================================
// 源代码比较专家
//==============================================================================

{ TCnSourceDiffWizard }

  TCnSourceDiffWizard = class(TCnMenuWizard)
  private
    FIni: TCustomIniFile;
  protected
    procedure SetActive(Value: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNSOURCEDIFFWIZARD}

implementation

{$IFDEF CNWIZARDS_CNSOURCEDIFFWIZARD}

//==============================================================================
// 源代码比较专家
//==============================================================================

{ TCnSourceDiffWizard }

constructor TCnSourceDiffWizard.Create;
begin
  inherited;
  FIni := CreateIniFile;
end;

destructor TCnSourceDiffWizard.Destroy;
begin
  FreeSourceDiffForm;
  FIni.Free;
  inherited;
end;

procedure TCnSourceDiffWizard.Execute;
begin
  ShowSourceDiffForm(FIni, Self.Icon);
end;

function TCnSourceDiffWizard.GetCaption: string;
begin
  Result := SCnSourceDiffWizardMenuCaption;
end;

function TCnSourceDiffWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnSourceDiffWizard.GetHint: string;
begin
  Result := SCnSourceDiffWizardMenuHint;
end;

class procedure TCnSourceDiffWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnSourceDiffWizardName;
  Author := 'Angus Johnson' + ';' + SCnPack_Zjy;
  Email := 'ajohnson@rpi.net.au' + ';' + SCnPack_ZjyEmail;
  Comment := SCnSourceDiffWizardComment;
end;

procedure TCnSourceDiffWizard.SetActive(Value: Boolean);
begin
  inherited;
  if not Active then
  begin
    if CnSourceDiffForm <> nil then
      FreeAndNil(CnSourceDiffForm);
  end;
end;

initialization
  RegisterCnWizard(TCnSourceDiffWizard); // 注册专家

{$ENDIF CNWIZARDS_CNSOURCEDIFFWIZARD}
end.
