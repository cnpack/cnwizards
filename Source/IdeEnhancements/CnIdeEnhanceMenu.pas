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

unit CnIdeEnhanceMenu;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE 扩展专家设置工具
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：将 IDE 扩展专家设置加入到子菜单中。
* 开发平台：Windows 2000 + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2005.09.05 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNIDEENHANCEMENUWIZARD}

uses
  SysUtils, Classes, ToolsApi, IniFiles,
  CnConsts, CnWizClasses, CnWizManager, CnWizConsts;

type
  TCnIdeEnhanceMenuWizard = class(TCnSubMenuWizard)
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

{$ENDIF CNWIZARDS_CNIDEENHANCEMENUWIZARD}

implementation

{$IFDEF CNWIZARDS_CNIDEENHANCEMENUWIZARD}

{ TCnIdeEnhanceMenu }

constructor TCnIdeEnhanceMenuWizard.Create;
begin
  inherited;
end;

procedure TCnIdeEnhanceMenuWizard.AcquireSubActions;
var
  I: Integer;
begin
  if CnWizardMgr <> nil then
  begin
    SetLength(Indexes, CnWizardMgr.IdeEnhanceWizardCount);
    for I := Low(Indexes) to High(Indexes) do
    begin
      if not CnWizardMgr.IdeEnhanceWizards[I].IsInternalWizard and // 内部的不显示
        CnWizardMgr.IdeEnhanceWizards[I].HasConfig then
      begin
        // 修改子菜单的 Command 命名方式，以便外界找到
        Indexes[I] := RegisterASubAction(SCnIdeEnhanceMenuCommand +
          CnWizardMgr.IdeEnhanceWizards[I].ClassName,
          StringReplace(CnWizardMgr.IdeEnhanceWizards[I].WizardName, '&', '&&',
          [rfReplaceAll]), 0,
          CnWizardMgr.IdeEnhanceWizards[I].GetComment,
          CnWizardMgr.IdeEnhanceWizards[I].ClassName);
      end
      else
        Indexes[I] := -1;
    end;
  end;
end;

destructor TCnIdeEnhanceMenuWizard.Destroy;
begin
  SetLength(Indexes, 0);
  inherited;
end;

procedure TCnIdeEnhanceMenuWizard.Execute;
begin

end;

function TCnIdeEnhanceMenuWizard.GetCaption: string;
begin
  Result := SCnIdeEnhanceMenuCaption;
end;

function TCnIdeEnhanceMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnIdeEnhanceMenuWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnIdeEnhanceMenuWizard.GetHint: string;
begin
  Result := SCnIdeEnhanceMenuHint;
end;

function TCnIdeEnhanceMenuWizard.GetState: TWizardState;
begin
  if Active then
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnIdeEnhanceMenuWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnIdeEnhanceMenuName;
  Author := SCnPack_Zjy;
  Email := SCnPack_Zjy;
  Comment := SCnIdeEnhanceMenuComment;
end;

procedure TCnIdeEnhanceMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnIdeEnhanceMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnIdeEnhanceMenuWizard.SubActionExecute(Index: Integer);
var
  I: Integer;
begin
  for I := Low(Indexes) to High(Indexes) do
    if Indexes[I] = Index then
    begin
      CnWizardMgr.IdeEnhanceWizards[I].Config;
      Exit;
    end;
end;

procedure TCnIdeEnhanceMenuWizard.SubActionUpdate(Index: Integer);
var
  I: Integer;
begin
  for I := Low(Indexes) to High(Indexes) do
    if Indexes[I] = Index then
      SubActions[Index].Enabled := CnWizardMgr.IdeEnhanceWizards[I].Active;
end;

initialization
  RegisterCnWizard(TCnIdeEnhanceMenuWizard);

{$ENDIF CNWIZARDS_CNIDEENHANCEMENUWIZARD}
end.
 
