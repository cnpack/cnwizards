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
* 修改记录：2021.05.21 V1.1
*               加入关闭时检测快捷键是否和 IDE 中重复的机制
*           2003.05.02 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Menus, ActnList, CnWizMultiLang, CnWizClasses, CnWizUtils,
  CnWizShortCut, CnWizMenuAction, CnWizConsts;

type
  TCnShortCutHolder = class(TObject)
  private
    FImageIndex: Integer;
    FCaption: string;
    FWizShortCut: TCnWizShortCut;
  public
    constructor Create(const ACaption: string; AWizShortCut: TCnWizShortCut; AImageIndex: Integer = -1);
    destructor Destroy; override;

    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property WizShortCut: TCnWizShortCut read FWizShortCut write FWizShortCut;
    property Caption: string read FCaption write FCaption;
  end;

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
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FWizard: TCnSubMenuWizard;
    FHelpStr: string;
    FHolders: TList;
    FWizardName: string;

    FShortCuts: array of TShortCut;
    procedure GetShortCutsFromWizard;
    procedure GetShortCutsFromHolders;
    function GetShortCut(Index: Integer): TShortCut;
    procedure SetShortCut(Index: Integer; const Value: TShortCut);
  protected
    function GetHelpTopic: string; override;
  public
    procedure SetShortCutsToWizard;
    procedure SetShortCutsToHolders;

    property Wizard: TCnSubMenuWizard read FWizard;
    property ShortCuts[Index: Integer]: TShortCut read GetShortCut write SetShortCut;
  end;

function SubActionShortCutConfig(AWizard: TCnSubMenuWizard;
  const HelpStr: string = ''): Boolean;
{* 供一子菜单专家显示其子菜单项的快捷键设置对话框}

function ShowShortCutConfigForHolders(Holders: TList; const WizardName: string;
  const HelpStr: string = ''): Boolean;
{* 供外部显示指定一批快捷键设置对话框，Holders 列表中应该存放 TCnShortCutHolder
  的实例，其 WizShortCut 属性应该指向要配置的属性}

implementation

{$R *.DFM}

function SubActionShortCutConfig(AWizard: TCnSubMenuWizard;
  const HelpStr: string): Boolean;
begin
  with TCnWizSubActionShortCutForm.Create(nil) do
  try
    FHolders := nil;
    FWizard := AWizard;

    if HelpStr <> '' then
      FHelpStr := HelpStr;
    Result := ShowModal = mrOk;

    if Result then
    begin
      SetShortCutsToWizard;
      SetShortCutsToHolders;
    end;
  finally
    Free;
  end;
end;

function ShowShortCutConfigForHolders(Holders: TList; const WizardName: string;
  const HelpStr: string = ''): Boolean;
begin
  with TCnWizSubActionShortCutForm.Create(nil) do
  try
    FWizard := nil;
    FHolders := Holders;
    FWizardName := WizardName;

    if HelpStr <> '' then
      FHelpStr := HelpStr;
    Result := ShowModal = mrOk;

    if Result then
    begin
      SetShortCutsToWizard;
      SetShortCutsToHolders;
    end;
  finally
    Free;
  end;
end;

procedure TCnWizSubActionShortCutForm.FormCreate(Sender: TObject);
begin
  FHelpStr := 'CnWizSubActionShortCutForm';
  ListView.SmallImages := GetIDEImageList;
  EnlargeListViewColumns(ListView);
end;

procedure TCnWizSubActionShortCutForm.FormShow(Sender: TObject);
begin
  if FWizard <> nil then
  begin
    GetShortCutsFromWizard;
    Caption := Format(SCnWizSubActionShortCutFormCaption, [Wizard.WizardName]);
  end
  else if FHolders <> nil then
  begin
    GetShortCutsFromHolders;
    Caption := Format(SCnWizSubActionShortCutFormCaption, [FWizardName]);
  end;

  if ListView.Items.Count > 0 then
    ListView.Items[0].Selected := True;
end;

procedure TCnWizSubActionShortCutForm.FormDestroy(Sender: TObject);
begin
  FShortCuts := nil;
  inherited;
end;

procedure TCnWizSubActionShortCutForm.btnOKClick(Sender: TObject);
begin
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
  I: Integer;
begin
  ListView.Items.Clear;
  SetLength(FShortCuts, Wizard.SubActionCount);
  for I := 0 to Wizard.SubActionCount - 1 do
    with ListView.Items.Add do
    begin
      Caption := StripHotkey(Wizard.SubActions[I].Caption);
      ImageIndex := Wizard.SubActions[I].ImageIndex;
      Data := Wizard.SubActions[I];
      ShortCuts[I] := Wizard.SubActions[I].ShortCut;
    end;
end;

procedure TCnWizSubActionShortCutForm.SetShortCutsToWizard;
var
  I: Integer;
begin
  if FWizard = nil then
    Exit;

  WizShortCutMgr.BeginUpdate;
  try
    for I := 0 to ListView.Items.Count - 1 do
      TCnWizMenuAction(ListView.Items[I].Data).ShortCut := ShortCuts[I];
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

procedure TCnWizSubActionShortCutForm.GetShortCutsFromHolders;
var
  I: Integer;
begin
  ListView.Items.Clear;
  SetLength(FShortCuts, FHolders.Count);
  for I := 0 to FHolders.Count - 1 do
  begin
    with ListView.Items.Add do
    begin
      Caption := StripHotkey(TCnShortCutHolder(FHolders[I]).Caption);
      ImageIndex := TCnShortCutHolder(FHolders[I]).ImageIndex;
      Data := TCnShortCutHolder(FHolders[I]);
      ShortCuts[I] := TCnShortCutHolder(FHolders[I]).WizShortCut.ShortCut;
    end;
  end;
end;

procedure TCnWizSubActionShortCutForm.SetShortCutsToHolders;
var
  I: Integer;
begin
  if FHolders = nil then
    Exit;

  WizShortCutMgr.BeginUpdate;
  try
    for I := 0 to ListView.Items.Count - 1 do
      TCnShortCutHolder(ListView.Items[I].Data).WizShortCut.ShortCut := ShortCuts[I];
  finally
    WizShortCutMgr.EndUpdate;
  end;
end;

{ TCnShortCutHolder }

constructor TCnShortCutHolder.Create(const ACaption: string;
  AWizShortCut: TCnWizShortCut; AImageIndex: Integer = -1);
begin
  inherited Create;
  FImageIndex := AImageIndex;
  FCaption := ACaption;
  FWizShortCut := AWizShortCut;
end;

destructor TCnShortCutHolder.Destroy;
begin

  inherited;
end;

procedure TCnWizSubActionShortCutForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  I: Integer;
begin
  CanClose := True;
  if (ModalResult <> mrOK) or (Length(FShortCuts) = 0) then
    Exit;

  for I := Low(FShortCuts) to High(FShortCuts) do
  begin
    // 对于每一个快捷键，都要判断是否没重复，或者有重复但用户选择了忽略，才能关闭
    if CheckQueryShortCutDuplicated(FShortCuts[I],
      TCustomAction(ListView.Items[I].Data)) = sdDuplicatedStop then
    begin
      CanClose := False;
      Exit;
    end;
  end;
end;

end.
