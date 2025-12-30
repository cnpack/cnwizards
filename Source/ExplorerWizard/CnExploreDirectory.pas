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

unit CnExploreDirectory;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：文件管理器专家单元
* 单元作者：Hhha（Hhha） Hhha@eyou.con
* 备    注：
* 开发平台：PWin2000Pro + Delphi 7
* 兼容测试：未测试
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2004-01-18
*               移植创建单元，修改部分问题。
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEXPLORERWIZARD}

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
  ExtCtrls, ComCtrls, ToolWin, CnWizConsts, CnWizMultiLang, CnWizShareImages;

type
  TCnExploreDirctoryForm = class(TCnTranslateForm)
    tlb: TToolBar;
    btnNew: TToolButton;
    btnDelete: TToolButton;
    btn4: TToolButton;
    btnClear: TToolButton;
    btn3: TToolButton;
    btnExit: TToolButton;
    lst: TListBox;
    stat: TStatusBar;
    procedure btnExitClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure lstDblClick(Sender: TObject);
  private

  public

  end;

var
  CnExploreDirctoryForm: TCnExploreDirctoryForm;

{$ENDIF CNWIZARDS_CNEXPLORERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEXPLORERWIZARD}

{$R *.DFM}

uses
  ShellAPI, ShlObj;

procedure TCnExploreDirctoryForm.btnExitClick(Sender: TObject);
begin
  Self.ModalResult := mrCancel;
end;

procedure TCnExploreDirctoryForm.btnClearClick(Sender: TObject);
begin
  Self.ModalResult := mrOK;
end;

procedure TCnExploreDirctoryForm.btnDeleteClick(Sender: TObject);
var
  i: Integer;
begin
  for i := lst.Items.Count - 1 downto 0 do
  begin
    if lst.Selected[i] then
      lst.Items.Delete(i);
  end;
end;

procedure TCnExploreDirctoryForm.btnNewClick(Sender: TObject);
var
  lpbi: TBrowseInfo;
  pidlResult: PItemIDList;
  sResult: string;
begin
  with lpbi do
  begin
    hwndOwner := Handle;
    GetMem(pszDisplayName, MAX_PATH);
    lpszTitle := PChar(SCnSelectDir);
    ulFlags := 1;
    SHGetSpecialFolderLocation(Handle, 17, pidlRoot);
    lpfn := nil;
  end;
  pidlResult := SHBrowseForFolder(lpbi);
  if SHGetPathFromIDList(pidlResult, lpbi.pszDisplayName) then
    sResult := StrPas(lpbi.pszDisplayName);
  FreeMem(lpbi.pszDisplayName);
  if (sResult <> '') and (lst.Items.IndexOf(sResult) < 0) then
    lst.Items.Add(sResult);
end;

procedure TCnExploreDirctoryForm.lstDblClick(Sender: TObject);
begin
  Self.ModalResult := mrOK;
end;

{$ENDIF CNWIZARDS_CNEXPLORERWIZARD}
end.

