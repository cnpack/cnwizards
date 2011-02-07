{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizSubActionShortCutFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家子菜单快捷键设置对话框单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2003.05.02 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Menus, CnWizClasses, CnWizUtils, CnWizShortCut,
  CnWizMenuAction, CnWizConsts, CnWizMultiLang;

type
  TCnWizSubActionShortCutForm = class(TCnTranslateForm)
    grp1: TGroupBox;
    ListView: TListView;
    lbl2: TLabel;
    HotKey: THotKey;
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure HotKeyExit(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FWizard: TCnSubMenuWizard;
    FHelpStr: string;
    FShortCuts: array of TShortCut;
    procedure GetShortCutsFromWizard;
    procedure SetShortCutsToWizard;
    function GetShortCut(Index: Integer): TShortCut;
    procedure SetShortCut(Index: Integer; const Value: TShortCut);
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
    property Wizard: TCnSubMenuWizard read FWizard;
    property ShortCuts[Index: Integer]: TShortCut read GetShortCut write SetShortCut;
  end;

function SubActionShortCutConfig(AWizard: TCnSubMenuWizard;
  const HelpStr: string = ''): Boolean;

implementation

{$R *.DFM}

function SubActionShortCutConfig(AWizard: TCnSubMenuWizard;
  const HelpStr: string): Boolean;
begin
  with TCnWizSubActionShortCutForm.Create(nil) do
  try
    FWizard := AWizard;
    if HelpStr <> '' then
      FHelpStr := HelpStr;
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

procedure TCnWizSubActionShortCutForm.FormCreate(Sender: TObject);
begin
  FHelpStr := 'CnWizSubActionShortCutForm';
  ListView.SmallImages := GetIDEImageList;
end;

procedure TCnWizSubActionShortCutForm.FormShow(Sender: TObject);
begin
  GetShortCutsFromWizard;
  Caption := Format(SCnWizSubActionShortCutFormCaption, [Wizard.WizardName]);
end;

procedure TCnWizSubActionShortCutForm.FormDestroy(Sender: TObject);
begin
  FShortCuts := nil;
  inherited;
end;

procedure TCnWizSubActionShortCutForm.btnOKClick(Sender: TObject);
begin
  SetShortCutsToWizard;
  ModalResult := mrOk;
end;

procedure TCnWizSubActionShortCutForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnWizSubActionShortCutForm.GetHelpTopic: string;
begin
  Result := FHelpStr;
end;

function TCnWizSubActionShortCutForm.GetShortCut(
  Index: Integer): TShortCut;
begin
  Result := FShortCuts[Index];
end;

procedure TCnWizSubActionShortCutForm.SetShortCut(Index: Integer;
  const Value: TShortCut);
begin
  FShortCuts[Index] := Value;
  if ListView.Items[Index].SubItems.Count > 0 then
    ListView.Items[Index].SubItems[0] := ShortCutToText(Value)
  else
    ListView.Items[Index].SubItems.Add(ShortCutToText(Value));
end;

procedure TCnWizSubActionShortCutForm.GetShortCutsFromWizard;
var
  i: Integer;
begin
  ListView.Items.Clear;
  SetLength(FShortCuts, Wizard.SubActionCount);
  for i := 0 to Wizard.SubActionCount - 1 do
    with ListView.Items.Add do
    begin
      Caption := StripHotkey(Wizard.SubActions[i].Caption);
      ImageIndex := Wizard.SubActions[i].ImageIndex;
      Data := Wizard.SubActions[i];
      ShortCuts[i] := Wizard.SubActions[i].ShortCut;
    end;
end;

procedure TCnWizSubActionShortCutForm.SetShortCutsToWizard;
var
  i: Integer;
begin
  WizShortCutMgr.BeginUpdate;
  try
    for i := 0 to ListView.Items.Count - 1 do
      TCnWizMenuAction(ListView.Items[i].Data).ShortCut := ShortCuts[i];
  finally
    WizShortCutMgr.EndUpdate;
  end;
end;

procedure TCnWizSubActionShortCutForm.ListViewChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if Assigned(ListView.Selected) then
    HotKey.HotKey := ShortCuts[ListView.Selected.Index]
  else
    HotKey.HotKey := 0;
end;

procedure TCnWizSubActionShortCutForm.HotKeyExit(Sender: TObject);
begin
  if Assigned(ListView.Selected) then
    ShortCuts[ListView.Selected.Index] := HotKey.HotKey;
end;

end.
