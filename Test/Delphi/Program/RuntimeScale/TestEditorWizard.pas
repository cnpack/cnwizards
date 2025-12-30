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

unit TestEditorWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：编辑器专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2002.12.03 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, ComCtrls, IniFiles, Registry, ExtCtrls;

type

{ TCnEditorForm }

  TEditorToolsForm = class(TForm)
    btnHelp: TButton;
    btnOK: TButton;
    grp1: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    lblToolName: TLabel;
    imgIcon: TImage;
    bvlWizard: TBevel;
    lbl3: TLabel;
    lblToolAuthor: TLabel;
    lvTools: TListView;
    mmoComment: TMemo;
    chkEnabled: TCheckBox;
    HotKey: THotKey;
    btnConfig: TButton;
    procedure FormCreate(Sender: TObject);
    procedure lvToolsDblClick(Sender: TObject);
    procedure HotKeyExit(Sender: TObject);
    procedure chkEnabledClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitTools;
    procedure UpdateToolItem(Index: Integer);
  protected
    function GetHelpTopic: string;
  public
    { Public declarations }
  end;


implementation

uses
  UnitRuntimeSale, CnWizScaler;

{$R *.DFM}

{ TCnEditorToolsForm }

procedure TEditorToolsForm.FormCreate(Sender: TObject);
begin
  InitTools;
  if GlobalScaleFactor <> 1.0 then
    ScaleForm(Self, GlobalScaleFactor);
end;

procedure TEditorToolsForm.UpdateToolItem(Index: Integer);
begin
  with lvTools.Items[Index] do
  begin

  end;
end;

procedure TEditorToolsForm.InitTools;
begin
  lvTools.Items.Clear;
end;

procedure TEditorToolsForm.lvToolsDblClick(Sender: TObject);
begin
  btnConfigClick(btnConfig);
end;

procedure TEditorToolsForm.HotKeyExit(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then Exit;
  Idx := lvTools.Selected.Index;
  UpdateToolItem(Idx);
end;

procedure TEditorToolsForm.chkEnabledClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then Exit;
  Idx := lvTools.Selected.Index;
  UpdateToolItem(Idx);
end;

procedure TEditorToolsForm.btnConfigClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then Exit;
  Idx := lvTools.Selected.Index;
  UpdateToolItem(Idx);
end;

function TEditorToolsForm.GetHelpTopic: string;
begin
  Result := 'CnEditorWizard';
end;

end.
