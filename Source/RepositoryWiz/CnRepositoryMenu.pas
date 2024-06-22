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

unit CnRepositoryMenu;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家引导工具
* 单元作者：LiuXiao  （master@cnpack.org）
* 备    注：将 Repository 专家加入到子菜单中。
* 开发平台：Windows 2000 + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2003.10.15 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNREPOSITORYMENUWIZARD}

uses
  SysUtils, Classes, ToolsApi, IniFiles,
  CnConsts, CnWizClasses, CnWizManager, CnWizConsts;

type
  TCnRepositoryMenuWizard = class(TCnSubMenuWizard)
  private
    Indexes: array of Integer;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    {* 类构造器 }
    destructor Destroy; override;
    {* 类析构器 }
    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure Execute; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;    
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

{$ENDIF CNWIZARDS_CNREPOSITORYMENUWIZARD}

implementation

{$IFDEF CNWIZARDS_CNREPOSITORYMENUWIZARD}

{ TCnRepositoryMenu }

constructor TCnRepositoryMenuWizard.Create;
begin
  inherited;
end;

procedure TCnRepositoryMenuWizard.AcquireSubActions;
var
  I: Integer;
begin
  if CnWizardMgr <> nil then
  begin
    SetLength(Indexes, CnWizardMgr.RepositoryWizardCount);
    for I := Low(Indexes) to High(Indexes) do
      Indexes[I] := RegisterASubAction(SCnRepositoryMenuCommand + InttoStr(I) +
        CnWizardMgr.RepositoryWizards[I].GetIDStr,
        CnWizardMgr.RepositoryWizards[I].WizardName, 0,
        CnWizardMgr.RepositoryWizards[I].GetComment,
        CnWizardMgr.RepositoryWizards[I].ClassName);
  end;
end;

destructor TCnRepositoryMenuWizard.Destroy;
begin
  SetLength(Indexes, 0);
  inherited;
end;

procedure TCnRepositoryMenuWizard.Execute;
begin

end;

function TCnRepositoryMenuWizard.GetCaption: string;
begin
  Result := SCnRepositoryMenuCaption;
end;

function TCnRepositoryMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnRepositoryMenuWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnRepositoryMenuWizard.GetHint: string;
begin
  Result := SCnRepositoryMenuHint;
end;

function TCnRepositoryMenuWizard.GetState: TWizardState;
begin
  if Active then
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnRepositoryMenuWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnRepositoryMenuName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnRepositoryMenuComment;
end;

procedure TCnRepositoryMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnRepositoryMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnRepositoryMenuWizard.SubActionExecute(Index: Integer);
var
  I: Integer;
begin
  for I := Low(Indexes) to High(Indexes) do
    if Indexes[I] = Index then
    begin
      CnWizardMgr.RepositoryWizards[I].Execute;
      Exit;
    end;
end;

procedure TCnRepositoryMenuWizard.SubActionUpdate(Index: Integer);
var
  I: Integer;
begin
  for I := Low(Indexes) to High(Indexes) do
    if Indexes[I] = Index then
      SubActions[Index].Enabled := CnWizardMgr.RepositoryWizards[Index].Active;
end;

initialization
  RegisterCnWizard(TCnRepositoryMenuWizard);

{$ENDIF CNWIZARDS_CNREPOSITORYMENUWIZARD}
end.
